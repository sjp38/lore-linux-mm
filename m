Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4CBB6B0261
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so13188797lfn.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d185si3472433lfe.262.2016.10.19.10.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:48 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/5] lib: radix-tree: internal tags
Date: Wed, 19 Oct 2016 13:24:25 -0400
Message-Id: <20161019172428.7649-3-hannes@cmpxchg.org>
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

To make the radix tree implementation aware of and be able to handle
the special shadow entries in the page cache, it needs tags that go
beyond the freely allocatable tag bits that we have right now; it
needs native tags that can influence radix tree behavior.

Turn the existing RADIX_TREE_MAX_TAGS definition into an enum that
starts out with the number of freely allocatable user tags and is
followed by internal tags that we can tie radix tree behavior to.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h      |  9 +++++++--
 lib/dma-debug.c                 |  6 +++---
 lib/radix-tree.c                | 21 ++++++++++++---------
 tools/testing/radix-tree/test.c |  4 ++--
 4 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index dc261da5096c..756b2909467e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -64,7 +64,12 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 3
+enum radix_tree_tags {
+	/* Freely allocatable radix tree user tags */
+	RADIX_TREE_NR_USER_TAGS = 3,
+	/* Radix tree internal tags */
+	RADIX_TREE_NR_TAGS = RADIX_TREE_NR_USER_TAGS,
+};
 
 #ifndef RADIX_TREE_MAP_SHIFT
 #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
@@ -101,7 +106,7 @@ struct radix_tree_node {
 	/* For tree user */
 	struct list_head private_list;
 	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
-	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
+	unsigned long	tags[RADIX_TREE_NR_TAGS][RADIX_TREE_TAG_LONGS];
 };
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 8971370bfb16..b0798a6a5b8a 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -464,7 +464,7 @@ EXPORT_SYMBOL(debug_dma_dump_mappings);
  */
 static RADIX_TREE(dma_active_cacheline, GFP_NOWAIT);
 static DEFINE_SPINLOCK(radix_lock);
-#define ACTIVE_CACHELINE_MAX_OVERLAP ((1 << RADIX_TREE_MAX_TAGS) - 1)
+#define ACTIVE_CACHELINE_MAX_OVERLAP ((1 << RADIX_TREE_NR_USER_TAGS) - 1)
 #define CACHELINE_PER_PAGE_SHIFT (PAGE_SHIFT - L1_CACHE_SHIFT)
 #define CACHELINES_PER_PAGE (1 << CACHELINE_PER_PAGE_SHIFT)
 
@@ -478,7 +478,7 @@ static int active_cacheline_read_overlap(phys_addr_t cln)
 {
 	int overlap = 0, i;
 
-	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
+	for (i = RADIX_TREE_NR_USER_TAGS - 1; i >= 0; i--)
 		if (radix_tree_tag_get(&dma_active_cacheline, cln, i))
 			overlap |= 1 << i;
 	return overlap;
@@ -491,7 +491,7 @@ static int active_cacheline_set_overlap(phys_addr_t cln, int overlap)
 	if (overlap > ACTIVE_CACHELINE_MAX_OVERLAP || overlap < 0)
 		return overlap;
 
-	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
+	for (i = RADIX_TREE_NR_USER_TAGS - 1; i >= 0; i--)
 		if (overlap & 1 << i)
 			radix_tree_tag_set(&dma_active_cacheline, cln, i);
 		else
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d04d0938d7b7..bb6ddfb60557 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -321,7 +321,7 @@ static void radix_tree_node_rcu_free(struct rcu_head *head)
 	 * can leave us with a non-NULL entry in the first slot, so clear
 	 * that here to make sure.
 	 */
-	for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
+	for (i = 0; i < RADIX_TREE_NR_TAGS; i++)
 		tag_clear(node, i, 0);
 
 	node->slots[0] = NULL;
@@ -512,7 +512,7 @@ static int radix_tree_extend(struct radix_tree_root *root,
 			return -ENOMEM;
 
 		/* Propagate the aggregated tag info into the new root */
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
+		for (tag = 0; tag < RADIX_TREE_NR_TAGS; tag++) {
 			if (root_tag_get(root, tag))
 				tag_set(node, tag, 0);
 		}
@@ -803,7 +803,7 @@ void __radix_tree_clear_tags(struct radix_tree_root *root,
 {
 	unsigned int tag;
 
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+	for (tag = 0; tag < RADIX_TREE_NR_TAGS; tag++)
 		__radix_tree_tag_clear(root, node, slot, tag);
 }
 
@@ -813,7 +813,7 @@ void __radix_tree_clear_tags(struct radix_tree_root *root,
  *	@index:		index key
  *	@tag:		tag index
  *
- *	Set the search tag (which must be < RADIX_TREE_MAX_TAGS)
+ *	Set the search tag (which must be < RADIX_TREE_NR_TAGS)
  *	corresponding to @index in the radix tree.  From
  *	the root all the way down to the leaf node.
  *
@@ -850,7 +850,7 @@ EXPORT_SYMBOL(radix_tree_tag_set);
  *	@index:		index key
  *	@tag:		tag index
  *
- *	Clear the search tag (which must be < RADIX_TREE_MAX_TAGS)
+ *	Clear the search tag (which must be < RADIX_TREE_NR_TAGS)
  *	corresponding to @index in the radix tree.  If this causes
  *	the leaf node to have no tags set then clear the tag in the
  *	next-to-leaf node, etc.
@@ -887,7 +887,7 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  * radix_tree_tag_get - get a tag on a radix tree node
  * @root:		radix tree root
  * @index:		index key
- * @tag:		tag index (< RADIX_TREE_MAX_TAGS)
+ * @tag:		tag index (< RADIX_TREE_NR_TAGS)
  *
  * Return values:
  *
@@ -1262,7 +1262,7 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
  *	@results:	where the results of the lookup are placed
  *	@first_index:	start the lookup from this key
  *	@max_items:	place up to this many items at *results
- *	@tag:		the tag index (< RADIX_TREE_MAX_TAGS)
+ *	@tag:		the tag index (< RADIX_TREE_NR_TAGS)
  *
  *	Performs an index-ascending scan of the tree for present items which
  *	have the tag indexed by @tag set.  Places the items at *@results and
@@ -1303,7 +1303,7 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
  *	@results:	where the results of the lookup are placed
  *	@first_index:	start the lookup from this key
  *	@max_items:	place up to this many items at *results
- *	@tag:		the tag index (< RADIX_TREE_MAX_TAGS)
+ *	@tag:		the tag index (< RADIX_TREE_NR_TAGS)
  *
  *	Performs an index-ascending scan of the tree for present items which
  *	have the tag indexed by @tag set.  Places the slots at *@results and
@@ -1592,7 +1592,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	offset = get_slot_offset(node, slot);
 
 	/* Clear all tags associated with the item to be deleted.  */
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+	for (tag = 0; tag < RADIX_TREE_NR_TAGS; tag++)
 		node_tag_clear(root, node, tag, offset);
 
 	delete_sibling_entries(node, node_to_entry(slot), offset);
@@ -1687,6 +1687,9 @@ static int radix_tree_callback(struct notifier_block *nfb,
 
 void __init radix_tree_init(void)
 {
+	/* Root tags have to squeeze into radix_tree_root->gfp_mask */
+	BUILD_BUG_ON(RADIX_TREE_NR_TAGS + __GFP_BITS_SHIFT > sizeof(gfp_t) * 8);
+
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index a6e8099eaf4f..2cebba63a1a2 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -161,7 +161,7 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 	if (tagged != anyset) {
 		printf("tag: %u, shift %u, tagged: %d, anyset: %d\n",
 			tag, slot->shift, tagged, anyset);
-		for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
+		for (j = 0; j < RADIX_TREE_NR_USER_TAGS; j++) {
 			printf("tag %d: ", j);
 			for (i = 0; i < RADIX_TREE_TAG_LONGS; i++)
 				printf("%016lx ", slot->tags[j][i]);
@@ -178,7 +178,7 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 				if (verify_node(slot->slots[i], tag,
 					    !!test_bit(i, slot->tags[tag]))) {
 					printf("Failure at off %d\n", i);
-					for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
+					for (j = 0; j < RADIX_TREE_NR_USER_TAGS; j++) {
 						printf("tag %d: ", j);
 						for (i = 0; i < RADIX_TREE_TAG_LONGS; i++)
 							printf("%016lx ", slot->tags[j][i]);
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
