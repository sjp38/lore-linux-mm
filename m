Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8KHLsrH029360
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 13:21:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8KHNCOt541422
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8KHNBmq029834
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:11 -0600
Subject: [RFC][PATCH 2/4] build_zonelists(): abstract node_load[] operations
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 20 Sep 2005 10:23:10 -0700
References: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
In-Reply-To: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
Message-Id: <20050920172310.6FA82B0C@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

We're shortly going to use find_next_best_node() for both
NUMA and non-NUMA configurations.  So, take node_load[],
and hide it behind a couple of helper functions that are
noops when NUMA is off.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/page_alloc.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff -puN mm/page_alloc.c~B1.1-build_zonelists_unification mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~B1.1-build_zonelists_unification	2005-09-14 09:32:38.000000000 -0700
+++ memhotplug-dave/mm/page_alloc.c	2005-09-14 09:32:38.000000000 -0700
@@ -1463,9 +1463,25 @@ static inline zone_index_to_type(int ind
 }
 
 
-#ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
+
+#ifdef CONFIG_NUMA
 static int __initdata node_load[MAX_NUMNODES];
+static int __init get_node_load(int node)
+{
+	return node_load[node];
+}
+static void __init increment_node_load(int node, int load)
+{
+	node_load[node] += load;
+}
+#else
+static inline int get_node_load(int node)
+{
+	return 0;
+}
+static inline void increment_node_load(int node, int load) {}
+#endif
 /**
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
@@ -1512,7 +1528,7 @@ static int __init find_next_best_node(in
 
 		/* Slight preference for less loaded node */
 		val *= (MAX_NODE_LOAD*MAX_NUMNODES);
-		val += node_load[n];
+		val += get_node_load(n);
 
 		if (val < min_val) {
 			min_val = val;
@@ -1552,7 +1568,7 @@ static void __init build_zonelists(pg_da
 		 */
 		if (node_distance(local_node, node) !=
 				node_distance(local_node, prev_node))
-			node_load[node] += load;
+			increment_node_load(node, load);
 		prev_node = node;
 		load--;
 		for (i = 0; i < GFP_ZONETYPES; i++) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
