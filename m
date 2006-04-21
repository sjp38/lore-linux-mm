Date: Fri, 21 Apr 2006 13:18:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] split zonelist and use nodemask for page allocation [4/4]
 build zonelist
Message-Id: <20060421131832.82eb8201.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: clameter@sgi.com
List-ID: <linux-mm.kvack.org>

build_zonelist() also has to be modified.
nodes_list() is created in the same way of old zonelist.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc1-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/page_alloc.c	2006-04-21 12:08:22.000000000 +0900
+++ linux-2.6.17-rc1-mm2/mm/page_alloc.c	2006-04-21 12:15:06.000000000 +0900
@@ -1695,19 +1695,13 @@
 	return best_node;
 }
 
-static void __init build_zonelists(pg_data_t *pgdat)
+static void __init build_nodelists(pg_data_t *pgdat)
 {
-	int i, j, k, node, local_node;
+	int index, node, local_node;
 	int prev_node, load;
 	struct zonelist *zonelist;
 	nodemask_t used_mask;
 
-	/* initialize zonelists */
-	for (i = 0; i < GFP_ZONETYPES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
-	}
-
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
 	load = num_online_nodes();
@@ -1723,6 +1717,10 @@
 		if (distance > RECLAIM_DISTANCE)
 			zone_reclaim_mode = 1;
 
+		/* avoid memory less node */
+		if (NODE_DATA(node)->node_present_pages == 0)
+			continue;
+
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
@@ -1733,25 +1731,47 @@
 			node_load[node] += load;
 		prev_node = node;
 		load--;
-		for (i = 0; i < GFP_ZONETYPES; i++) {
-			zonelist = pgdat->node_zonelists + i;
-			for (j = 0; zonelist->zones[j] != NULL; j++);
+		pgdat->nodes_list[index++] = node;
+	}
+	/* end of list */
+	pgdat->nodes_list[index] = -1;
+}
 
-			k = highest_zone(i);
+#elif defined(CONFIG_NEED_MULTIPLE_NODES)
 
-	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
-			zonelist->zones[j] = NULL;
-		}
+/* not NUMA but have multiple nodes */
+static void __init build_nodelists(pg_data_t *pgdat)
+{
+	int local_node = pgdat->node_id;
+	int node,index;
+
+	if (pgdat->node_present_pages != 0)
+		pgdat->nodes_list[index++] = local_node;
+
+	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
+		if (!node_online(node))
+			continue;
+		pgdat->nodes_list[index++] = node;
+	}
+	for (node = 0; node < local_node; node++) {
+		if (!node_online(node))
+			continue;
+		pgdat->nodes_list[index++] = node;
 	}
+	pgdat->node_list[index] = -1;
 }
-
-#else	/* CONFIG_NUMA */
+#else /* there is only one pgdat */
+static void __init build_nodelists(pg_data_t *pgdat)
+{
+	pgdat->nodes_list[0] = pgdat->node_id;
+	pgdat->nodes_list[1] = 0;
+}
+#endif
 
 static void __init build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, k, node, local_node;
+	int i, j, k;
 
-	local_node = pgdat->node_id;
 	for (i = 0; i < GFP_ZONETYPES; i++) {
 		struct zonelist *zonelist;
 
@@ -1760,30 +1780,11 @@
 		j = 0;
 		k = highest_zone(i);
  		j = build_zonelists_node(pgdat, zonelist, j, k);
- 		/*
- 		 * Now we build the zonelist so that it contains the zones
- 		 * of all the other nodes.
- 		 * We don't want to pressure a particular node, so when
- 		 * building the zones for node N, we make sure that the
- 		 * zones coming right after the local ones are those from
- 		 * node N+1 (modulo N)
- 		 */
-		for (node = local_node + 1; node < MAX_NUMNODES; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
-		}
-		for (node = 0; node < local_node; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
-		}
-
 		zonelist->zones[j] = NULL;
 	}
+	build_nodelists(pgdat);
 }
 
-#endif	/* CONFIG_NUMA */
 
 void __init build_all_zonelists(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
