From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:22 -0400
Message-Id: <20070727194322.18614.68855.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 1/14] NUMA: Generic management of nodemasks for various purposes

Preparation for memoryless node patches.

Provide a generic way to keep nodemasks describing various characteristics
of NUMA nodes.

Remove the node_online_map and the node_possible map and realize the whole
thing using two nodes stats: N_POSSIBLE and N_ONLINE.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 include/linux/nodemask.h |   87 ++++++++++++++++++++++++++++++++++++++---------
 mm/page_alloc.c          |   13 +++----
 2 files changed, 78 insertions(+), 22 deletions(-)

Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-07-08 19:32:17.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-07-25 11:36:25.000000000 -0400
@@ -338,31 +338,81 @@ static inline void __nodes_remap(nodemas
 #endif /* MAX_NUMNODES */
 
 /*
+ * Bitmasks that are kept for all the nodes.
+ */
+enum node_states {
+	N_POSSIBLE,	/* The node could become online at some point */
+	N_ONLINE,	/* The node is online */
+	NR_NODE_STATES
+};
+
+/*
  * The following particular system nodemasks and operations
  * on them manage all possible and online nodes.
  */
 
-extern nodemask_t node_online_map;
-extern nodemask_t node_possible_map;
+extern nodemask_t node_states[NR_NODE_STATES];
 
 #if MAX_NUMNODES > 1
-#define num_online_nodes()	nodes_weight(node_online_map)
-#define num_possible_nodes()	nodes_weight(node_possible_map)
-#define node_online(node)	node_isset((node), node_online_map)
-#define node_possible(node)	node_isset((node), node_possible_map)
-#define first_online_node	first_node(node_online_map)
-#define next_online_node(nid)	next_node((nid), node_online_map)
+static inline int node_state(int node, enum node_states state)
+{
+	return node_isset(node, node_states[state]);
+}
+
+static inline void node_set_state(int node, enum node_states state)
+{
+	__node_set(node, &node_states[state]);
+}
+
+static inline void node_clear_state(int node, enum node_states state)
+{
+	__node_clear(node, &node_states[state]);
+}
+
+static inline int num_node_state(enum node_states state)
+{
+	return nodes_weight(node_states[state]);
+}
+
+#define for_each_node_state(__node, __state) \
+	for_each_node_mask((__node), node_states[__state])
+
+#define first_online_node	first_node(node_states[N_ONLINE])
+#define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
+
 extern int nr_node_ids;
 #else
-#define num_online_nodes()	1
-#define num_possible_nodes()	1
-#define node_online(node)	((node) == 0)
-#define node_possible(node)	((node) == 0)
+
+static inline int node_state(int node, enum node_states state)
+{
+	return node == 0;
+}
+
+static inline void node_set_state(int node, enum node_states state)
+{
+}
+
+static inline void node_clear_state(int node, enum node_states state)
+{
+}
+
+static inline int num_node_state(enum node_states state)
+{
+	return 1;
+}
+
+#define for_each_node_state(node, __state) \
+	for ( (node) = 0; (node) != 0; (node) = 1)
+
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
+
 #endif
 
+#define node_online_map 	node_states[N_ONLINE]
+#define node_possible_map 	node_states[N_POSSIBLE]
+
 #define any_online_node(mask)			\
 ({						\
 	int node;				\
@@ -372,10 +422,15 @@ extern int nr_node_ids;
 	node;					\
 })
 
-#define node_set_online(node)	   set_bit((node), node_online_map.bits)
-#define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
+#define num_online_nodes()	num_node_state(N_ONLINE)
+#define num_possible_nodes()	num_node_state(N_POSSIBLE)
+#define node_online(node)	node_state((node), N_ONLINE)
+#define node_possible(node)	node_state((node), N_POSSIBLE)
+
+#define node_set_online(node)	   node_set_state((node), N_ONLINE)
+#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
 
-#define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
-#define for_each_online_node(node) for_each_node_mask((node), node_online_map)
+#define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
+#define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
 
 #endif /* __LINUX_NODEMASK_H */
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-25 11:36:25.000000000 -0400
@@ -48,13 +48,14 @@
 #include "internal.h"
 
 /*
- * MCD - HACK: Find somewhere to initialize this EARLY, or make this
- * initializer cleaner
+ * Array of node states.
  */
-nodemask_t node_online_map __read_mostly = { { [0] = 1UL } };
-EXPORT_SYMBOL(node_online_map);
-nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
-EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
+	[N_POSSIBLE] = NODE_MASK_ALL,
+	[N_ONLINE] = { { [0] = 1UL } }
+};
+EXPORT_SYMBOL(node_states);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
