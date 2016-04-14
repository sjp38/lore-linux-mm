Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAC4828F3
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so131981421pfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 77si11496472pfq.237.2016.04.14.07.37.31
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:31 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 17/19] radix-tree: Make radix_tree_descend() more useful
Date: Thu, 14 Apr 2016 10:37:20 -0400
Message-Id: <1460644642-30642-18-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Now that the shift amount is stored in the node, radix_tree_descend()
can calculate offset itself from index, which removes several lines of
code from each of the tree walkers.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 78 +++++++++++++++++++-------------------------------------
 1 file changed, 26 insertions(+), 52 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4574848..8ee2447 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -94,9 +94,10 @@ static inline unsigned long get_slot_offset(struct radix_tree_node *parent,
 	return slot - parent->slots;
 }
 
-static unsigned radix_tree_descend(struct radix_tree_node *parent,
-				struct radix_tree_node **nodep, unsigned offset)
+static unsigned int radix_tree_descend(struct radix_tree_node *parent,
+			struct radix_tree_node **nodep, unsigned long index)
 {
+	unsigned int offset = (index >> parent->shift) & RADIX_TREE_MAP_MASK;
 	void **entry = rcu_dereference_raw(parent->slots[offset]);
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
@@ -536,8 +537,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 
 		/* Go a level down */
 		node = entry_to_node(child);
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(node, &child, offset);
+		offset = radix_tree_descend(node, &child, index);
 		slot = &node->slots[offset];
 	}
 
@@ -625,13 +625,12 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 {
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
-	unsigned int shift;
 	void **slot;
 
  restart:
 	parent = NULL;
 	slot = (void **)&root->rnode;
-	shift = radix_tree_load_root(root, &node, &maxindex);
+	radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return NULL;
 
@@ -641,9 +640,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 		if (node == RADIX_TREE_RETRY)
 			goto restart;
 		parent = entry_to_node(node);
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(parent, &node, offset);
+		offset = radix_tree_descend(parent, &node, index);
 		slot = parent->slots + offset;
 	}
 
@@ -713,19 +710,15 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 {
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
-	unsigned int shift;
 
-	shift = radix_tree_load_root(root, &node, &maxindex);
+	radix_tree_load_root(root, &node, &maxindex);
 	BUG_ON(index > maxindex);
 
 	while (radix_tree_is_internal_node(node)) {
 		unsigned offset;
 
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-
 		parent = entry_to_node(node);
-		offset = radix_tree_descend(parent, &node, offset);
+		offset = radix_tree_descend(parent, &node, index);
 		BUG_ON(!node);
 
 		if (!tag_get(parent, tag, offset))
@@ -779,21 +772,17 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 {
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
-	unsigned int shift;
 	int uninitialized_var(offset);
 
-	shift = radix_tree_load_root(root, &node, &maxindex);
+	radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return NULL;
 
 	parent = NULL;
 
 	while (radix_tree_is_internal_node(node)) {
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-
 		parent = entry_to_node(node);
-		offset = radix_tree_descend(parent, &node, offset);
+		offset = radix_tree_descend(parent, &node, index);
 	}
 
 	if (node)
@@ -823,25 +812,21 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 {
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
-	unsigned int shift;
 
 	if (!root_tag_get(root, tag))
 		return 0;
 
-	shift = radix_tree_load_root(root, &node, &maxindex);
+	radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return 0;
 	if (node == NULL)
 		return 0;
 
 	while (radix_tree_is_internal_node(node)) {
-		int offset;
-
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		unsigned offset;
 
 		parent = entry_to_node(node);
-		offset = radix_tree_descend(parent, &node, offset);
+		offset = radix_tree_descend(parent, &node, index);
 
 		if (!node)
 			return 0;
@@ -874,7 +859,7 @@ static inline void __set_iter_shift(struct radix_tree_iter *iter,
 void **radix_tree_next_chunk(struct radix_tree_root *root,
 			     struct radix_tree_iter *iter, unsigned flags)
 {
-	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
+	unsigned tag = flags & RADIX_TREE_ITER_TAG_MASK;
 	struct radix_tree_node *node, *child;
 	unsigned long index, offset, maxindex;
 
@@ -895,7 +880,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		return NULL;
 
  restart:
-	shift = radix_tree_load_root(root, &child, &maxindex);
+	radix_tree_load_root(root, &child, &maxindex);
 	if (index > maxindex)
 		return NULL;
 	if (!child)
@@ -912,9 +897,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 
 	do {
 		node = entry_to_node(child);
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(node, &child, offset);
+		offset = radix_tree_descend(node, &child, index);
 
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
 				!tag_get(node, tag, offset) : !child) {
@@ -936,7 +919,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 						break;
 				}
 			index &= ~node_maxindex(node);
-			index += offset << shift;
+			index += offset << node->shift;
 			/* Overflow after ~0UL */
 			if (!index)
 				return NULL;
@@ -952,7 +935,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	/* Update the iterator state */
 	iter->index = (index &~ node_maxindex(node)) | (offset << node->shift);
 	iter->next_index = (index | node_maxindex(node)) + 1;
-	__set_iter_shift(iter, shift);
+	__set_iter_shift(iter, node->shift);
 
 	/* Construct iter->tags bit-mask from node->tags[tag] array */
 	if (flags & RADIX_TREE_ITER_TAGGED) {
@@ -1010,10 +993,10 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 {
 	struct radix_tree_node *parent, *node, *child;
 	unsigned long maxindex;
-	unsigned int shift = radix_tree_load_root(root, &child, &maxindex);
 	unsigned long tagged = 0;
 	unsigned long index = *first_indexp;
 
+	radix_tree_load_root(root, &child, &maxindex);
 	last_index = min(last_index, maxindex);
 	if (index > last_index)
 		return 0;
@@ -1030,11 +1013,9 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 	}
 
 	node = entry_to_node(child);
-	shift -= RADIX_TREE_MAP_SHIFT;
 
 	for (;;) {
-		unsigned offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(node, &child, offset);
+		unsigned offset = radix_tree_descend(node, &child, index);
 		if (!child)
 			goto next;
 		if (!tag_get(node, iftag, offset))
@@ -1042,7 +1023,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		/* Sibling slots never have tags set on them */
 		if (radix_tree_is_internal_node(child)) {
 			node = entry_to_node(child);
-			shift -= RADIX_TREE_MAP_SHIFT;
 			continue;
 		}
 
@@ -1063,12 +1043,12 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			tag_set(parent, settag, offset);
 		}
  next:
-		/* Go to next item at level determined by 'shift' */
-		index = ((index >> shift) + 1) << shift;
+		/* Go to next entry in node */
+		index = ((index >> node->shift) + 1) << node->shift;
 		/* Overflow can happen when last_index is ~0UL... */
 		if (index > last_index || !index)
 			break;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		offset = (index >> node->shift) & RADIX_TREE_MAP_MASK;
 		while (offset == 0) {
 			/*
 			 * We've fully scanned this node. Go up. Because
@@ -1076,8 +1056,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			 * we do below cannot wander astray.
 			 */
 			node = node->parent;
-			shift += RADIX_TREE_MAP_SHIFT;
-			offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+			offset = (index >> node->shift) & RADIX_TREE_MAP_MASK;
 		}
 		if (is_sibling_entry(node, node->slots[offset]))
 			goto next;
@@ -1275,13 +1254,10 @@ struct locate_info {
 static unsigned long __locate(struct radix_tree_node *slot, void *item,
 			      unsigned long index, struct locate_info *info)
 {
-	unsigned int shift;
 	unsigned long base, i;
 
-	shift = slot->shift + RADIX_TREE_MAP_SHIFT;
-
 	do {
-		shift -= RADIX_TREE_MAP_SHIFT;
+		unsigned int shift = slot->shift;
 		base = index & ~((1UL << shift) - 1);
 
 		for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
@@ -1305,9 +1281,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 			slot = node;
 			break;
 		}
-		if (i == RADIX_TREE_MAP_SIZE)
-			break;
-	} while (shift);
+	} while (i < RADIX_TREE_MAP_SIZE);
 
 out:
 	if ((index == 0) && (i == RADIX_TREE_MAP_SIZE))
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
