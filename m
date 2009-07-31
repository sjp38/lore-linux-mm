Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E75486B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:46:09 -0400 (EDT)
Received: by gxk3 with SMTP id 3so3701694gxk.14
        for <linux-mm@kvack.org>; Fri, 31 Jul 2009 09:46:14 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 1 Aug 2009 00:46:14 +0800
Message-ID: <dc46d49c0907310946m1c67e404n11947a5fe1d76fc4@mail.gmail.com>
Subject: [PATCH] rm unnecessary node_load[] during funtion build_zonelists()
From: Bob Liu <yjfpb04@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, All
           I think node_load[] is unnecessary during the funtion
build_zonelists(). Because when  find_next_best_node() return a
node,the node must have been added to used_node_mask. Then set
node_load[node] will not affect anything.
---
Thanks
Bob

Date: Sat, 1 Aug 2009 00:28:49 +0800
Subject: [PATCH] rm unnecessary node_load[] during funtion build_zonelists
 Signed-off-by: Bob Liu <bo-liu@hotmail.com>

---
 mm/page_alloc.c |   25 +++----------------------
 1 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..6e9682b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2331,8 +2331,6 @@ int numa_zonelist_order_handler(ctl_table
*table, int write,
 }


-#define MAX_NODE_LOAD (nr_online_nodes)
-static int node_load[MAX_NUMNODES];

 /**
  * find_next_best_node - find the next node that should appear in a
given node's fallback list
@@ -2378,10 +2376,6 @@ static int find_next_best_node(int node,
nodemask_t *used_node_mask)
 		if (!cpumask_empty(tmp))
 			val += PENALTY_FOR_NODE_WITH_CPUS;

-		/* Slight preference for less loaded node */
-		val *= (MAX_NODE_LOAD*MAX_NUMNODES);
-		val += node_load[n];
-
 		if (val < min_val) {
 			min_val = val;
 			best_node = n;
@@ -2524,10 +2518,10 @@ static void set_zonelist_order(void)

 static void build_zonelists(pg_data_t *pgdat)
 {
-	int j, node, load;
+	int j, node;
 	enum zone_type i;
 	nodemask_t used_mask;
-	int local_node, prev_node;
+	int local_node;
 	struct zonelist *zonelist;
 	int order = current_zonelist_order;

@@ -2540,11 +2534,8 @@ static void build_zonelists(pg_data_t *pgdat)

 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
-	load = nr_online_nodes;
-	prev_node = local_node;
 	nodes_clear(used_mask);

-	memset(node_load, 0, sizeof(node_load));
 	memset(node_order, 0, sizeof(node_order));
 	j = 0;

@@ -2557,17 +2548,7 @@ static void build_zonelists(pg_data_t *pgdat)
 		 */
 		if (distance > RECLAIM_DISTANCE)
 			zone_reclaim_mode = 1;
-
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
-		if (distance != node_distance(local_node, prev_node))
-			node_load[node] = load;
-
-		prev_node = node;
-		load--;
+		
 		if (order == ZONELIST_ORDER_NODE)
 			build_zonelists_in_node_order(pgdat, node);
 		else
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
