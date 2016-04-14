Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 466F86B027E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t124so132119037pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ui4si2771828pab.203.2016.04.14.07.37.27
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:27 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 02/19] radix-tree: Miscellaneous fixes
Date: Thu, 14 Apr 2016 10:37:05 -0400
Message-Id: <1460644642-30642-3-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Typos, whitespace, grammar, line length, using the correct types, etc.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 70 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 36 insertions(+), 34 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index cd7dc59..746a240 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -66,7 +66,7 @@ static struct kmem_cache *radix_tree_node_cachep;
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
-	int nr;
+	unsigned nr;
 	/* nodes->private_data points to next preallocated node */
 	struct radix_tree_node *nodes;
 };
@@ -147,7 +147,7 @@ static inline void root_tag_set(struct radix_tree_root *root, unsigned int tag)
 	root->gfp_mask |= (__force gfp_t)(1 << (tag + __GFP_BITS_SHIFT));
 }
 
-static inline void root_tag_clear(struct radix_tree_root *root, unsigned int tag)
+static inline void root_tag_clear(struct radix_tree_root *root, unsigned tag)
 {
 	root->gfp_mask &= (__force gfp_t)~(1 << (tag + __GFP_BITS_SHIFT));
 }
@@ -159,7 +159,7 @@ static inline void root_tag_clear_all(struct radix_tree_root *root)
 
 static inline int root_tag_get(struct radix_tree_root *root, unsigned int tag)
 {
-	return (__force unsigned)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
+	return (__force int)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
 }
 
 static inline unsigned root_tags_get(struct radix_tree_root *root)
@@ -173,7 +173,7 @@ static inline unsigned root_tags_get(struct radix_tree_root *root)
  */
 static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
 {
-	int idx;
+	unsigned idx;
 	for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
 		if (node->tags[tag][idx])
 			return 1;
@@ -273,9 +273,9 @@ radix_tree_node_alloc(struct radix_tree_root *root)
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
@@ -448,7 +448,6 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
 static int radix_tree_extend(struct radix_tree_root *root,
 				unsigned long index)
 {
-	struct radix_tree_node *node;
 	struct radix_tree_node *slot;
 	unsigned int height;
 	int tag;
@@ -465,7 +464,9 @@ static int radix_tree_extend(struct radix_tree_root *root,
 
 	do {
 		unsigned int newheight;
-		if (!(node = radix_tree_node_alloc(root)))
+		struct radix_tree_node *node = radix_tree_node_alloc(root);
+
+		if (!node)
 			return -ENOMEM;
 
 		/* Propagate the aggregated tag info into the new root */
@@ -542,7 +543,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	while (shift > order) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
-			if (!(slot = radix_tree_node_alloc(root)))
+			slot = radix_tree_node_alloc(root);
+			if (!slot)
 				return -ENOMEM;
 			slot->path = height;
 			slot->parent = node;
@@ -722,13 +724,13 @@ EXPORT_SYMBOL(radix_tree_lookup);
  *	radix_tree_tag_set - set a tag on a radix tree node
  *	@root:		radix tree root
  *	@index:		index key
- *	@tag: 		tag index
+ *	@tag:		tag index
  *
  *	Set the search tag (which must be < RADIX_TREE_MAX_TAGS)
  *	corresponding to @index in the radix tree.  From
  *	the root all the way down to the leaf node.
  *
- *	Returns the address of the tagged item.   Setting a tag on a not-present
+ *	Returns the address of the tagged item.  Setting a tag on a not-present
  *	item is a bug.
  */
 void *radix_tree_tag_set(struct radix_tree_root *root,
@@ -767,11 +769,11 @@ EXPORT_SYMBOL(radix_tree_tag_set);
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
@@ -829,7 +831,7 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  * radix_tree_tag_get - get a tag on a radix tree node
  * @root:		radix tree root
  * @index:		index key
- * @tag: 		tag index (< RADIX_TREE_MAX_TAGS)
+ * @tag:		tag index (< RADIX_TREE_MAX_TAGS)
  *
  * Return values:
  *
@@ -1035,7 +1037,7 @@ EXPORT_SYMBOL(radix_tree_next_chunk);
  * set is outside the range we are scanning. This reults in dangling tags and
  * can lead to problems with later tag operations (e.g. livelocks on lookups).
  *
- * The function returns number of leaves where the tag was set and sets
+ * The function returns the number of leaves where the tag was set and sets
  * *first_indexp to the first unscanned index.
  * WARNING! *first_indexp can wrap if last_index is ULONG_MAX. Caller must
  * be prepared to handle that.
@@ -1153,9 +1155,10 @@ EXPORT_SYMBOL(radix_tree_range_tag_if_tagged);
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
@@ -1461,7 +1464,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * their slot to become empty sooner or later.
 		 *
 		 * For example, lockless pagecache will look up a slot, deref
-		 * the page pointer, and if the page is 0 refcount it means it
+		 * the page pointer, and if the page has 0 refcount it means it
 		 * was concurrently deleted from pagecache so try the deref
 		 * again. Fortunately there is already a requirement for logic
 		 * to retry the entire slot lookup -- the indirect pointer
@@ -1650,24 +1653,23 @@ static __init void radix_tree_init_maxindex(void)
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
