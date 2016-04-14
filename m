Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93B688295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so132303186pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 85si7769514pfn.180.2016.04.14.07.37.44
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:44 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 13/19] radix-tree: Tidy up next_chunk
Date: Thu, 14 Apr 2016 10:37:16 -0400
Message-Id: <1460644642-30642-14-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Convert radix_tree_next_chunk to use 'child' instead of 'slot' as the name
of the child node.  Also use node_maxindex() where it makes sense.

The 'rnode' variable was unnecessary; it doesn't overlap in usage with
'node', so we can just use 'node' the whole way through the function.

Improve the testcase to start the walk from every index in the carefully
constructed tree, and to accept any index within the range covered by
the entry.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c                      | 53 +++++++------------
 tools/testing/radix-tree/multiorder.c | 99 +++++++++++++++++++----------------
 2 files changed, 74 insertions(+), 78 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 094dfc0..fab4485 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -876,7 +876,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 			     struct radix_tree_iter *iter, unsigned flags)
 {
 	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
-	struct radix_tree_node *rnode, *node;
+	struct radix_tree_node *node, *child;
 	unsigned long index, offset, maxindex;
 
 	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
@@ -896,38 +896,29 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		return NULL;
 
  restart:
-	shift = radix_tree_load_root(root, &rnode, &maxindex);
+	shift = radix_tree_load_root(root, &child, &maxindex);
 	if (index > maxindex)
 		return NULL;
+	if (!child)
+		return NULL;
 
-	if (radix_tree_is_internal_node(rnode)) {
-		rnode = entry_to_node(rnode);
-	} else if (rnode) {
+	if (!radix_tree_is_internal_node(child)) {
 		/* Single-slot tree */
 		iter->index = index;
 		iter->next_index = maxindex + 1;
 		iter->tags = 1;
-		__set_iter_shift(iter, shift);
+		__set_iter_shift(iter, 0);
 		return (void **)&root->rnode;
-	} else
-		return NULL;
-
-	shift -= RADIX_TREE_MAP_SHIFT;
-	offset = index >> shift;
-
-	node = rnode;
-	while (1) {
-		struct radix_tree_node *slot;
-		unsigned new_off = radix_tree_descend(node, &slot, offset);
+	}
 
-		if (new_off < offset) {
-			offset = new_off;
-			index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
-			index |= offset << shift;
-		}
+	do {
+		node = entry_to_node(child);
+		shift -= RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		offset = radix_tree_descend(node, &child, offset);
 
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
-				!tag_get(node, tag, offset) : !slot) {
+				!tag_get(node, tag, offset) : !child) {
 			/* Hole detected */
 			if (flags & RADIX_TREE_ITER_CONTIG)
 				return NULL;
@@ -945,29 +936,23 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 					if (slot)
 						break;
 				}
-			index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
+			index &= ~node_maxindex(node);
 			index += offset << shift;
 			/* Overflow after ~0UL */
 			if (!index)
 				return NULL;
 			if (offset == RADIX_TREE_MAP_SIZE)
 				goto restart;
-			slot = rcu_dereference_raw(node->slots[offset]);
+			child = rcu_dereference_raw(node->slots[offset]);
 		}
 
-		if ((slot == NULL) || (slot == RADIX_TREE_RETRY))
+		if ((child == NULL) || (child == RADIX_TREE_RETRY))
 			goto restart;
-		if (!radix_tree_is_internal_node(slot))
-			break;
-
-		node = entry_to_node(slot);
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-	}
+	} while (radix_tree_is_internal_node(child));
 
 	/* Update the iterator state */
-	iter->index = index & ~((1 << shift) - 1);
-	iter->next_index = (index | ((RADIX_TREE_MAP_SIZE << shift) - 1)) + 1;
+	iter->index = (index &~ node_maxindex(node)) | (offset << node->shift);
+	iter->next_index = (index | node_maxindex(node)) + 1;
 	__set_iter_shift(iter, shift);
 
 	/* Construct iter->tags bit-mask from node->tags[tag] array */
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index c061f4b..39d9b95 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -202,7 +202,7 @@ void multiorder_iteration(void)
 	RADIX_TREE(tree, GFP_KERNEL);
 	struct radix_tree_iter iter;
 	void **slot;
-	int i, err;
+	int i, j, err;
 
 	printf("Multiorder iteration test\n");
 
@@ -215,29 +215,21 @@ void multiorder_iteration(void)
 		assert(!err);
 	}
 
-	i = 0;
-	/* start from index 1 to verify we find the multi-order entry at 0 */
-	radix_tree_for_each_slot(slot, &tree, &iter, 1) {
-		int height = order[i] / RADIX_TREE_MAP_SHIFT;
-		int shift = height * RADIX_TREE_MAP_SHIFT;
-
-		assert(iter.index == index[i]);
-		assert(iter.shift == shift);
-		i++;
-	}
-
-	/*
-	 * Now iterate through the tree starting at an elevated multi-order
-	 * entry, beginning at an index in the middle of the range.
-	 */
-	i = 8;
-	radix_tree_for_each_slot(slot, &tree, &iter, 70) {
-		int height = order[i] / RADIX_TREE_MAP_SHIFT;
-		int shift = height * RADIX_TREE_MAP_SHIFT;
-
-		assert(iter.index == index[i]);
-		assert(iter.shift == shift);
-		i++;
+	for (j = 0; j < 256; j++) {
+		for (i = 0; i < NUM_ENTRIES; i++)
+			if (j <= (index[i] | ((1 << order[i]) - 1)))
+				break;
+
+		radix_tree_for_each_slot(slot, &tree, &iter, j) {
+			int height = order[i] / RADIX_TREE_MAP_SHIFT;
+			int shift = height * RADIX_TREE_MAP_SHIFT;
+			int mask = (1 << order[i]) - 1;
+
+			assert(iter.index >= (index[i] &~ mask));
+			assert(iter.index <= (index[i] | mask));
+			assert(iter.shift == shift);
+			i++;
+		}
 	}
 
 	item_kill_tree(&tree);
@@ -249,7 +241,7 @@ void multiorder_tagged_iteration(void)
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned long first = 0;
-	int i;
+	int i, j;
 
 	printf("Multiorder tagged iteration test\n");
 
@@ -268,30 +260,49 @@ void multiorder_tagged_iteration(void)
 	for (i = 0; i < TAG_ENTRIES; i++)
 		assert(radix_tree_tag_set(&tree, tag_index[i], 1));
 
-	i = 0;
-	/* start from index 1 to verify we find the multi-order entry at 0 */
-	radix_tree_for_each_tagged(slot, &tree, &iter, 1, 1) {
-		assert(iter.index == tag_index[i]);
-		i++;
-	}
-
-	/*
-	 * Now iterate through the tree starting at an elevated multi-order
-	 * entry, beginning at an index in the middle of the range.
-	 */
-	i = 4;
-	radix_tree_for_each_slot(slot, &tree, &iter, 70) {
-		assert(iter.index == tag_index[i]);
-		i++;
+	for (j = 0; j < 256; j++) {
+		int mask, k;
+
+		for (i = 0; i < TAG_ENTRIES; i++) {
+			for (k = i; index[k] < tag_index[i]; k++)
+				;
+			if (j <= (index[k] | ((1 << order[k]) - 1)))
+				break;
+		}
+
+		radix_tree_for_each_tagged(slot, &tree, &iter, j, 1) {
+			for (k = i; index[k] < tag_index[i]; k++)
+				;
+			mask = (1 << order[k]) - 1;
+
+			assert(iter.index >= (tag_index[i] &~ mask));
+			assert(iter.index <= (tag_index[i] | mask));
+			i++;
+		}
 	}
 
 	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
 					MT_NUM_ENTRIES, 1, 2);
 
-	i = 0;
-	radix_tree_for_each_tagged(slot, &tree, &iter, 1, 2) {
-		assert(iter.index == tag_index[i]);
-		i++;
+	for (j = 0; j < 256; j++) {
+		int mask, k;
+
+		for (i = 0; i < TAG_ENTRIES; i++) {
+			for (k = i; index[k] < tag_index[i]; k++)
+				;
+			if (j <= (index[k] | ((1 << order[k]) - 1)))
+				break;
+		}
+
+		radix_tree_for_each_tagged(slot, &tree, &iter, j, 2) {
+			for (k = i; index[k] < tag_index[i]; k++)
+				;
+			mask = (1 << order[k]) - 1;
+
+			assert(iter.index >= (tag_index[i] &~ mask));
+			assert(iter.index <= (tag_index[i] | mask));
+			i++;
+		}
 	}
 
 	first = 1;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
