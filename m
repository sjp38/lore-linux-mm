Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BAE836B0254
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:44 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so359546366pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v86si47916903pfi.16.2016.01.19.06.25.39
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:39 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 3/8] radix-tree: Cleanups
Date: Tue, 19 Jan 2016 09:25:28 -0500
Message-Id: <1453213533-6040-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Fix various style issues including typos and some of the checkpatch
warnings.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 59 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 31 insertions(+), 28 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index fcf5d98..357b556 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -108,7 +108,8 @@ static inline void root_tag_set(struct radix_tree_root *root, unsigned int tag)
 	root->gfp_mask |= (__force gfp_t)(1 << (tag + __GFP_BITS_SHIFT));
 }
 
-static inline void root_tag_clear(struct radix_tree_root *root, unsigned int tag)
+static inline void root_tag_clear(struct radix_tree_root *root,
+					unsigned int tag)
 {
 	root->gfp_mask &= (__force gfp_t)~(1 << (tag + __GFP_BITS_SHIFT));
 }
@@ -120,7 +121,7 @@ static inline void root_tag_clear_all(struct radix_tree_root *root)
 
 static inline int root_tag_get(struct radix_tree_root *root, unsigned int tag)
 {
-	return (__force unsigned)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
+	return (__force int)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
 }
 
 /*
@@ -184,9 +185,9 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 	gfp_t gfp_mask = root_gfp_mask(root);
 
 	/*
-	 * Preload code isn't irq safe and it doesn't make sence to use
-	 * preloading in the interrupt anyway as all the allocations have to
-	 * be atomic. So just do normal allocation when in interrupt.
+	 * Preload code isn't irq safe and it doesn't make sense to use
+	 * preloading during an interrupt anyway as all the allocations have
+	 * to be atomic. So just do normal allocation when in interrupt.
 	 */
 	if (!gfpflags_allow_blocking(gfp_mask) && !in_interrupt()) {
 		struct radix_tree_preload *rtp;
@@ -342,7 +343,8 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
 
 	do {
 		unsigned int newheight;
-		if (!(node = radix_tree_node_alloc(root)))
+		node = radix_tree_node_alloc(root);
+		if (!node)
 			return -ENOMEM;
 
 		/* Propagate the aggregated tag info into the new root */
@@ -410,7 +412,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	while (height > 0) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
-			if (!(slot = radix_tree_node_alloc(root)))
+			slot = radix_tree_node_alloc(root);
+			if (!slot)
 				return -ENOMEM;
 			slot->path = height;
 			slot->parent = node;
@@ -580,7 +583,7 @@ EXPORT_SYMBOL(radix_tree_lookup);
  *	radix_tree_tag_set - set a tag on a radix tree node
  *	@root:		radix tree root
  *	@index:		index key
- *	@tag: 		tag index
+ *	@tag:		tag index
  *
  *	Set the search tag (which must be < RADIX_TREE_MAX_TAGS)
  *	corresponding to @index in the radix tree.  From
@@ -625,11 +628,11 @@ EXPORT_SYMBOL(radix_tree_tag_set);
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
  *	@index:		index key
- *	@tag: 		tag index
+ *	@tag:		tag index
  *
  *	Clear the search tag (which must be < RADIX_TREE_MAX_TAGS)
- *	corresponding to @index in the radix tree.  If
- *	this causes the leaf node to have no tags set then clear the tag in the
+ *	corresponding to @index in the radix tree.  If this causes
+ *	the leaf node to have no tags set then clear the tag in the
  *	next-to-leaf node, etc.
  *
  *	Returns the address of the tagged item on success, else NULL.  ie:
@@ -688,7 +691,7 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  * radix_tree_tag_get - get a tag on a radix tree node
  * @root:		radix tree root
  * @index:		index key
- * @tag: 		tag index (< RADIX_TREE_MAX_TAGS)
+ * @tag:		tag index (< RADIX_TREE_MAX_TAGS)
  *
  * Return values:
  *
@@ -1003,9 +1006,10 @@ EXPORT_SYMBOL(radix_tree_range_tag_if_tagged);
  *
  *	Like radix_tree_lookup, radix_tree_gang_lookup may be called under
  *	rcu_read_lock. In this case, rather than the returned results being
- *	an atomic snapshot of the tree at a single point in time, the semantics
- *	of an RCU protected gang lookup are as though multiple radix_tree_lookups
- *	have been issued in individual locks, and results stored in 'results'.
+ *	an atomic snapshot of the tree at a single point in time, the
+ *	semantics of an RCU protected gang lookup are as though multiple
+ *	radix_tree_lookups have been issued in individual locks, and results
+ *	stored in 'results'.
  */
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
@@ -1463,24 +1467,23 @@ static __init void radix_tree_init_maxindex(void)
 }
 
 static int radix_tree_callback(struct notifier_block *nfb,
-                            unsigned long action,
-                            void *hcpu)
+				unsigned long action, void *hcpu)
 {
-       int cpu = (long)hcpu;
-       struct radix_tree_preload *rtp;
-       struct radix_tree_node *node;
-
-       /* Free per-cpu pool of perloaded nodes */
-       if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
-               rtp = &per_cpu(radix_tree_preloads, cpu);
-               while (rtp->nr) {
+	int cpu = (long)hcpu;
+	struct radix_tree_preload *rtp;
+	struct radix_tree_node *node;
+
+	/* Free per-cpu pool of preloaded nodes */
+	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
+		rtp = &per_cpu(radix_tree_preloads, cpu);
+		while (rtp->nr) {
 			node = rtp->nodes;
 			rtp->nodes = node->private_data;
 			kmem_cache_free(radix_tree_node_cachep, node);
 			rtp->nr--;
-               }
-       }
-       return NOTIFY_OK;
+		}
+	}
+	return NOTIFY_OK;
 }
 
 void __init radix_tree_init(void)
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
