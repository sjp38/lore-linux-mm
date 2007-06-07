Date: Thu, 7 Jun 2007 10:17:01 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070607011701.GA14211@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, ak@suse.de, clameter@sgi.com, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

This is an alternative approach to the MPOL_INTERLEAVE across online
nodes as the system init policy. Andi suggested it might be worthwhile
trying to do this dynamically rather than as a command line option, so
that's what this tries to do.

With this, the online nodes are sized and packed in to an interleave map
if they're large enough for interleave to be worthwhile. I arbitrarily
chose 16MB as the node size to enable interleaving, but perhaps someone
has a better figure in mind?

In the case where all of the nodes are smaller than that, the largest
node is selected and placed in to the map by itself (if they're all the
same size, the first online node gets used).

If people prefer this approach, the previous patch adding mpolinit can be
dropped.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/mempolicy.c |   31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d76e8eb..a67c8f1 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1597,6 +1597,10 @@ void mpol_free_shared_policy(struct shared_policy *p)
 /* assumes fs == KERNEL_DS */
 void __init numa_policy_init(void)
 {
+	nodemask_t interleave_nodes;
+	unsigned long largest = 0;
+	int nid, prefer = 0;
+
 	policy_cache = kmem_cache_create("numa_policy",
 					 sizeof(struct mempolicy),
 					 0, SLAB_PANIC, NULL, NULL);
@@ -1605,10 +1609,31 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL, NULL);
 
-	/* Set interleaving policy for system init. This way not all
-	   the data structures allocated at system boot end up in node zero. */
+	/*
+	 * Set interleaving policy for system init. Interleaving is only
+	 * enabled across suitably sized nodes (default is >= 16MB), or
+	 * fall back to the largest node if they're all smaller.
+	 */
+	nodes_clear(interleave_nodes);
+	for_each_online_node(nid) {
+		unsigned long total_pages = node_present_pages(nid);
+
+		/* Preserve the largest node */
+		if (largest < total_pages) {
+			largest = total_pages;
+			prefer = nid;
+		}
+
+		/* Interleave this node? */
+		if ((total_pages << PAGE_SHIFT) >= (16 << 20))
+			node_set(nid, interleave_nodes);
+	}
+
+	/* All too small, use the largest */
+	if (unlikely(nodes_empty(interleave_nodes)))
+		node_set(prefer, interleave_nodes);
 
-	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
+	if (do_set_mempolicy(MPOL_INTERLEAVE, &interleave_nodes))
 		printk("numa_policy_init: interleaving failed\n");
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
