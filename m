Date: Thu, 26 Apr 2007 19:53:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] change global zonelist order on NUMA v3
Message-Id: <20070426195348.6a4e5652.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
	<200704261147.44413.ak@suse.de>
	<20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Changelog V2 -> V3

- removed zone ordering selection knobs...

much simpler one. just changing zonelist ordering.
tested on ia64 NUMA works well as expected.

-Kame


change zonelist order on NUMA v3.

[Description]
Assume 2 node NUMA, only node(0) has ZONE_DMA.
(ia64's ZONE_DMA is below 4GB...x86_64's ZONE_DMA32)

In this case, current default (node0's) zonelist order is

Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.

This means Node(0)'s DMA will be used before Node(1)'s NORMAL.
This will cause OOM on ZONE_DMA easily.

This patch changes *default* zone order to

Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.

tested ia64 2-Node NUMA. works well.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-rc7-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/page_alloc.c
+++ linux-2.6.21-rc7-mm2/mm/page_alloc.c
@@ -2023,6 +2023,7 @@ void show_free_areas(void)
  *
  * Add all populated zones of a node to the zonelist.
  */
+#ifndef CONFIG_NUMA
 static int __meminit build_zonelists_node(pg_data_t *pgdat,
 			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
 {
@@ -2042,6 +2043,7 @@ static int __meminit build_zonelists_nod
 	} while (zone_type);
 	return nr_zones;
 }
+#endif
 
 #ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
@@ -2106,52 +2108,51 @@ static int __meminit find_next_best_node
 	return best_node;
 }
 
+/*
+ * Build zonelist based on zone priority.
+ */
+static int __meminitdata node_order[MAX_NUMNODES];
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
-	int j, node, local_node;
-	enum zone_type i;
-	int prev_node, load;
-	struct zonelist *zonelist;
+	int i, j, pos, zone_type, node, load;
 	nodemask_t used_mask;
+	int local_node, prev_node;
+	struct zone *z;
+	struct zonelist *zonelist;
 
-	/* initialize zonelists */
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
-
-	/* NUMA-aware ordering of nodes */
+	memset(node_order, 0, sizeof(node_order));
 	local_node = pgdat->node_id;
 	load = num_online_nodes();
 	prev_node = local_node;
 	nodes_clear(used_mask);
+	j = 0;
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
 		int distance = node_distance(local_node, node);
-
-		/*
-		 * If another node is sufficiently far away then it is better
-		 * to reclaim pages in a zone before going off node.
-		 */
 		if (distance > RECLAIM_DISTANCE)
 			zone_reclaim_mode = 1;
-
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
-
 		if (distance != node_distance(local_node, prev_node))
-			node_load[node] += load;
+			node_load[node] = load;
+		node_order[j++] = node;
 		prev_node = node;
 		load--;
-		for (i = 0; i < MAX_NR_ZONES; i++) {
-			zonelist = pgdat->node_zonelists + i;
-			for (j = 0; zonelist->zones[j] != NULL; j++);
-
-	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
-			zonelist->zones[j] = NULL;
+	}
+	/* calculate node order */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + i;
+		pos = 0;
+		for (zone_type = i; zone_type >= 0; zone_type--) {
+			for (j = 0; j < num_online_nodes(); j++) {
+				node = node_order[j];
+				z = &NODE_DATA(node)->node_zones[zone_type];
+				if (populated_zone(z))
+					zonelist->zones[pos++] = z;
+			}
 		}
+		zonelist->zones[pos] = NULL;
 	}
 }
 
@@ -2239,6 +2240,7 @@ void __meminit build_all_zonelists(void)
 		__build_all_zonelists(NULL);
 		cpuset_init_current_mems_allowed();
 	} else {
+		memset(node_load, 0, sizeof(node_load));
 		/* we have to stop all cpus to guaranntee there is no user
 		   of zonelist */
 		stop_machine_run(__build_all_zonelists, NULL, NR_CPUS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
