Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7077828F3
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t124so132127184pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n4si4760234pfj.132.2016.04.14.07.37.30
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:30 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 10/19] radix-tree: Rename indirect_to_ptr() to entry_to_node()
Date: Thu, 14 Apr 2016 10:37:13 -0400
Message-Id: <1460644642-30642-11-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Mirrors the earlier commit introducing node_to_entry().

Also change the type returned to be a struct radix_tree_node pointer.
That lets us simplify a couple of places in the radix tree shrink & extend
paths where we could convert an entry into a pointer, modify the node, then
convert the pointer back into an entry.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h      | 12 +++++------
 lib/radix-tree.c                | 48 ++++++++++++++++++-----------------------
 tools/testing/radix-tree/test.c |  4 ++--
 tools/testing/radix-tree/test.h |  1 -
 4 files changed, 28 insertions(+), 37 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c8cc879..b94aa19 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -442,7 +442,7 @@ radix_tree_chunk_size(struct radix_tree_iter *iter)
 	return (iter->next_index - iter->index) >> iter_shift(iter);
 }
 
-static inline void *indirect_to_ptr(void *ptr)
+static inline struct radix_tree_node *entry_to_node(void *ptr)
 {
 	return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
 }
@@ -469,7 +469,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 			return NULL;
 		while (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
 					radix_tree_is_indirect_ptr(slot[1])) {
-			if (indirect_to_ptr(slot[1]) == canon) {
+			if (entry_to_node(slot[1]) == canon) {
 				iter->tags >>= 1;
 				iter->index = __radix_tree_iter_add(iter, 1);
 				slot++;
@@ -499,12 +499,10 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 
 			if (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
 			    radix_tree_is_indirect_ptr(*slot)) {
-				if (indirect_to_ptr(*slot) == canon)
+				if (entry_to_node(*slot) == canon)
 					continue;
-				else {
-					iter->next_index = iter->index;
-					break;
-				}
+				iter->next_index = iter->index;
+				break;
 			}
 
 			if (likely(*slot))
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f7a0cf7..675e85f 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -230,13 +230,13 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		if (is_sibling_entry(node, entry)) {
 			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
 					entry, i,
-					*(void **)indirect_to_ptr(entry),
+					*(void **)entry_to_node(entry),
 					first, last);
 		} else if (!radix_tree_is_indirect_ptr(entry)) {
 			pr_debug("radix entry %p offset %ld indices %ld-%ld\n",
 					entry, i, first, last);
 		} else {
-			dump_node(indirect_to_ptr(entry), first);
+			dump_node(entry_to_node(entry), first);
 		}
 	}
 }
@@ -249,7 +249,7 @@ static void radix_tree_dump(struct radix_tree_root *root)
 			root->gfp_mask >> __GFP_BITS_SHIFT);
 	if (!radix_tree_is_indirect_ptr(root->rnode))
 		return;
-	dump_node(indirect_to_ptr(root->rnode), 0);
+	dump_node(entry_to_node(root->rnode), 0);
 }
 #endif
 
@@ -422,7 +422,7 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
 	*nodep = node;
 
 	if (likely(radix_tree_is_indirect_ptr(node))) {
-		node = indirect_to_ptr(node);
+		node = entry_to_node(node);
 		*maxindex = node_maxindex(node);
 		return node->shift + RADIX_TREE_MAP_SHIFT;
 	}
@@ -467,11 +467,8 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		node->offset = 0;
 		node->count = 1;
 		node->parent = NULL;
-		if (radix_tree_is_indirect_ptr(slot)) {
-			slot = indirect_to_ptr(slot);
-			slot->parent = node;
-			slot = node_to_entry(slot);
-		}
+		if (radix_tree_is_indirect_ptr(slot))
+			entry_to_node(slot)->parent = node;
 		node->slots[0] = slot;
 		slot = node_to_entry(node);
 		rcu_assign_pointer(root->rnode, slot);
@@ -542,7 +539,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			break;
 
 		/* Go a level down */
-		node = indirect_to_ptr(slot);
+		node = entry_to_node(slot);
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		offset = radix_tree_descend(node, &slot, offset);
 	}
@@ -645,7 +642,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 
 		if (node == RADIX_TREE_RETRY)
 			goto restart;
-		parent = indirect_to_ptr(node);
+		parent = entry_to_node(node);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		offset = radix_tree_descend(parent, &node, offset);
@@ -729,7 +726,7 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 
-		parent = indirect_to_ptr(node);
+		parent = entry_to_node(node);
 		offset = radix_tree_descend(parent, &node, offset);
 		BUG_ON(!node);
 
@@ -777,7 +774,7 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 
-		parent = indirect_to_ptr(node);
+		parent = entry_to_node(node);
 		offset = radix_tree_descend(parent, &node, offset);
 	}
 
@@ -844,7 +841,7 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 
-		parent = indirect_to_ptr(node);
+		parent = entry_to_node(node);
 		offset = radix_tree_descend(parent, &node, offset);
 
 		if (!node)
@@ -904,7 +901,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		return NULL;
 
 	if (radix_tree_is_indirect_ptr(rnode)) {
-		rnode = indirect_to_ptr(rnode);
+		rnode = entry_to_node(rnode);
 	} else if (rnode) {
 		/* Single-slot tree */
 		iter->index = index;
@@ -963,7 +960,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		if (!radix_tree_is_indirect_ptr(slot))
 			break;
 
-		node = indirect_to_ptr(slot);
+		node = entry_to_node(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 	}
@@ -1048,7 +1045,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		return 1;
 	}
 
-	node = indirect_to_ptr(slot);
+	node = entry_to_node(slot);
 	shift -= RADIX_TREE_MAP_SHIFT;
 
 	for (;;) {
@@ -1063,7 +1060,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			goto next;
 		/* Sibling slots never have tags set on them */
 		if (radix_tree_is_indirect_ptr(slot)) {
-			node = indirect_to_ptr(slot);
+			node = entry_to_node(slot);
 			shift -= RADIX_TREE_MAP_SHIFT;
 			continue;
 		}
@@ -1323,7 +1320,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 				}
 				continue;
 			}
-			node = indirect_to_ptr(node);
+			node = entry_to_node(node);
 			if (is_sibling_entry(slot, node))
 				continue;
 			slot = node;
@@ -1368,7 +1365,7 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
 			break;
 		}
 
-		node = indirect_to_ptr(node);
+		node = entry_to_node(node);
 
 		max_index = node_maxindex(node);
 		if (cur_index > max_index) {
@@ -1404,7 +1401,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 
 		if (!radix_tree_is_indirect_ptr(to_free))
 			break;
-		to_free = indirect_to_ptr(to_free);
+		to_free = entry_to_node(to_free);
 
 		/*
 		 * The candidate node has more than one child, or its child
@@ -1419,11 +1416,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 		if (!radix_tree_is_indirect_ptr(slot) && to_free->shift)
 			break;
 
-		if (radix_tree_is_indirect_ptr(slot)) {
-			slot = indirect_to_ptr(slot);
-			slot->parent = NULL;
-			slot = node_to_entry(slot);
-		}
+		if (radix_tree_is_indirect_ptr(slot))
+			entry_to_node(slot)->parent = NULL;
 
 		/*
 		 * We don't need rcu_assign_pointer(), since we are simply
@@ -1482,7 +1476,7 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 		struct radix_tree_node *parent;
 
 		if (node->count) {
-			if (node == indirect_to_ptr(root->rnode))
+			if (node == entry_to_node(root->rnode))
 				deleted |= radix_tree_shrink(root);
 			return deleted;
 		}
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 3004c58..7b0bc1f 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -149,7 +149,7 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 	int i;
 	int j;
 
-	slot = indirect_to_ptr(slot);
+	slot = entry_to_node(slot);
 
 	/* Verify consistency at this level */
 	for (i = 0; i < RADIX_TREE_TAG_LONGS; i++) {
@@ -227,7 +227,7 @@ void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
 		return;
 	}
 
-	node = indirect_to_ptr(node);
+	node = entry_to_node(node);
 	assert(maxindex <= node_maxindex(node));
 
 	shift = node->shift;
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 866c8c6..e851313 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -39,7 +39,6 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
 extern int nr_allocated;
 
 /* Normally private parts of lib/radix-tree.c */
-void *indirect_to_ptr(void *ptr);
 void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
