From: Andi Kleen <ak@suse.de>
Subject: [PATCH for 2.6.16] Handle holes in node mask in node fallback list setup
Date: Fri, 17 Feb 2006 20:38:21 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602172038.22073.ak@suse.de>
Sender: owner-linux-mm@kvack.org
From: Linus Torvalds <torvalds@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, clameter@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Written by Linus, tested by AK]

Change the find_next_best_node algorithm to correctly skip
over holes in the node online mask. Previously it would not handle
missing nodes correctly and cause crashes at boot.

Signed-off-by: Andi Kleen <ak@suse.de>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 62c1225..208812b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1541,29 +1541,29 @@ static int __initdata node_load[MAX_NUMN
  */
 static int __init find_next_best_node(int node, nodemask_t *used_node_mask)
 {
-	int i, n, val;
+	int n, val;
 	int min_val = INT_MAX;
 	int best_node = -1;
 
-	for_each_online_node(i) {
-		cpumask_t tmp;
+	/* Use the local node if we haven't already */
+	if (!node_isset(node, *used_node_mask)) {
+		node_set(node, *used_node_mask);
+		return node;
+	}
 
-		/* Start from local node */
-		n = (node+i) % num_online_nodes();
+	for_each_online_node(n) {
+		cpumask_t tmp;
 
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
 
+		/* Penalize nodes under us ("prefer the next node") */
+		val += (n < node);
+
 		/* Give preference to headless and unused nodes */
 		tmp = node_to_cpumask(n);
 		if (!cpus_empty(tmp))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
