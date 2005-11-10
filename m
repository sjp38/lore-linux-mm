From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090946.8083.42039.sendpatchset@cherry.local>
In-Reply-To: <20051110090920.8083.54147.sendpatchset@cherry.local>
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 05/05] NUMA: find_next_best_node fix
Date: Thu, 10 Nov 2005 18:08:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Fix find_next_best_node() to support node masks with holes.

find_next_best_node() does currently not support node masks with holes. For 
instance, a node mask with nodes 1, 8 and 16 online will not work correctly.
The use of % num_online_nodes() in the code below hints that only a single 
contiguous range of nodes is supported without this patch.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 page_alloc.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

--- from-0002/mm/page_alloc.c
+++ to-work/mm/page_alloc.c	2005-11-09 17:48:24.000000000 +0900
@@ -1554,26 +1554,31 @@ static int __initdata node_load[MAX_NUMN
  */
 static int __init find_next_best_node(int node, nodemask_t *used_node_mask)
 {
-	int i, n, val;
+	int n, val;
 	int min_val = INT_MAX;
 	int best_node = -1;
+	int first_node = node;
 
-	for_each_online_node(i) {
+	/* Use the local node if we haven't already */
+	if (node_isset(node, *used_node_mask))
+		n = !first_node;
+	else {
+		n = first_node;
+		best_node = node;
+	}
+
+	for (; n != first_node; node = n) {
 		cpumask_t tmp;
 
-		/* Start from local node */
-		n = (node+i) % num_online_nodes();
+		n = next_node(node, node_online_map);
+
+		if (n == MAX_NUMNODES)
+			n = first_node(node_online_map);
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
 
-		/* Use the local node if we haven't already */
-		if (!node_isset(node, *used_node_mask)) {
-			best_node = node;
-			break;
-		}
-
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
