import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/screens/create_update_brand.dart';
import 'package:product_manager/screens/create_update_product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? generateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split("/");
    inspect(pathElements);

    if (pathElements[0] != "") return null;

    switch (pathElements[1]) {
      case 'create_update_brand':
        return PageRouteBuilder(
          pageBuilder: ((context, animation, secondaryAnimation) {
            return CreateUpdateBrand(
              data: Brand().fromMap(settings.arguments as Map<String, dynamic>),
            );
          }),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case 'create_update_product':
        return MaterialPageRoute(builder: ((context) {
          return CreateUpdateProduct(
            data: Product().fromMap(settings.arguments as Map<String, dynamic>),
          );
        }));
      default:
    }
    return null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder()
          })),
      onGenerateRoute: generateRoute,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, this.title});
  final String? title;
  final List<NavigationDestination> routes = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.history), label: 'History')
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIdx = 0;
  String title = "Demo";

  @override
  void initState() {
    setState(() {
      if (widget.title != null) {
        title = widget.title!;
      } else {
        title = widget.routes[currentPageIdx].label;
      }
    });
    super.initState();
  }

  Future<List<Map<String, Object?>>> fetchBrand() async {
    List<Map<String, Object?>> lstBrand = [];
    final db = await SQLiteHelper.open();
    if (db != null && db.isOpen == true) {
      await db.transaction((txn) async {
        lstBrand = await txn.query("Brand");
      });
    }
    // log('get db path: ${db!.path}');
    // await SQLiteHelper.delete();
    // inspect(lstBrand);
    return lstBrand;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: widget.routes,
        selectedIndex: currentPageIdx,
        onDestinationSelected: (value) {
          setState(() {
            currentPageIdx = value;
            title = widget.routes[value].label;
          });
        },
      ),
      body: [
        FutureBuilder(
          future: fetchBrand(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Text('Loading');
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12.0),
                child: ListView(children: <Widget>[
                  for (var i = 0; i < snapshot.data!.length; i++)
                    if (snapshot.data![i]["name"].toString().isEmpty)
                      const SizedBox.shrink()
                    else
                      GestureDetector(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(snapshot.data![i]["name"].toString()),
                                  Text(snapshot.data![i]["phone"].toString())
                                ],
                              )
                            ]),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/create_update_brand",
                                  arguments: snapshot.data![i])
                              .then((value) => setState(
                                    () {},
                                  ));
                        },
                      )
                ]),
              );
            }
          },
        )
      ][currentPageIdx],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CreateUpdateProduct()));
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
