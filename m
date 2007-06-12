Date: Tue, 12 Jun 2007 12:51:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
In-Reply-To: <20070612194951.GC3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121250430.7983@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <1181657940.5592.19.camel@localhost> <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
 <1181675840.5592.123.camel@localhost> <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com>
 <20070612194951.GC3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I thought more along these lines?

NUMA: introduce node_memory_map

It is necessary to know if nodes have memory since we have recently
begun to add support for memoryless nodes. For that purpose we introduce
a new bitmap called

node_memory_map

A node has its bit in node_memory_map set if it has memory. If a node
has memory then it has at least one zone defined in its pgdat structure
that is located in the pgdat itself.

The node_memory_map can then be used in various places to insure that we
do the right thing when we encounter a memoryless node.

Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/include/linux/nodemask.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/nodemask.h	2007-06-12 12:07:29.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/nodemask.h	2007-06-12 12:09:35.000000000 -0700
@@ -64,12 +64,16 @@
  *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
+ * int node_memory(node)		Does a node have memory?
  *
  * int any_online_node(mask)		First online node in mask
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
  *
+ * node_set_memory(node)		set bit 'node' in node_memory_map
+ * node_clear_memoryd(node)		clear bit 'node' in node_memory_map
+ *
  * for_each_node(node)			for-loop node over node_possible_map
  * for_each_online_node(node)		for-loop node over node_online_map
  *
@@ -344,12 +348,14 @@ static inline void __nodes_remap(nodemas
 
 extern nodemask_t node_online_map;
 extern nodemask_t node_possible_map;
+extern nodemask_t node_memory_map;
 
 #if MAX_NUMNODES > 1
 #define num_online_nodes()	nodes_weight(node_online_map)
 #define num_possible_nodes()	nodes_weight(node_possible_map)
 #define node_online(node)	node_isset((node), node_online_map)
 #define node_possible(node)	node_isset((node), node_possible_map)
+#define node_memory(node)	node_isset((node), node_memory_map)
 #define first_online_node	first_node(node_online_map)
 #define next_online_node(nid)	next_node((nid), node_online_map)
 extern int nr_node_ids;
@@ -358,6 +364,7 @@ extern int nr_node_ids;
 #define num_possible_nodes()	1
 #define node_online(node)	((node) == 0)
 #define node_possible(node)	((node) == 0)
+#define node_populated(node)	((node) == 0)
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
@@ -375,6 +382,9 @@ extern int nr_node_ids;
 #define node_set_online(node)	   set_bit((node), node_online_map.bits)
 #define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
 
+#define node_set_memory(node)     set_bit((node), node_memory_map.bits)
+#define node_clear_memory(node)   clear_bit((node), node_memory_map.bits)
+
 #define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
 #define for_each_online_node(node) for_each_node_mask((node), node_online_map)
 
Index: linux-2.6.22-rc4-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/page_alloc.c	2007-06-12 12:07:29.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/page_alloc.c	2007-06-12 12:11:04.000000000 -0700
@@ -54,6 +54,9 @@ nodemask_t node_online_map __read_mostly
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_memory_map __read_mostly = NODE_MASK_NONE;
+EXPORT_SYMBOL(node_memory_map);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -2299,6 +2302,9 @@ static void build_zonelists(pg_data_t *p
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	if (pgdat->node_present_pages)
+		node_set_memory(local_node);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
