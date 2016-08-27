Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A002830CD
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 10:14:44 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so70377479lfw.1
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:14:44 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id n185si11524107lfd.352.2016.08.27.07.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 07:14:41 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id g62so74150009lfe.3
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:14:41 -0700 (PDT)
Subject: [PATCH RFC 1/4] lib/radix: add universal radix_tree_fill_range
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Aug 2016 17:14:34 +0300
Message-ID: <147230727479.9957.1087787722571077339.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This patch adds function for filling and truncating ranges of slots:

radix_tree_node *radix_tree_fill_range(root, start, end, item, flags)

It fills slots in range "begin".."end" with "item" and returns pointer
to the last filled node. Filling with NULL truncates range.

This is intended for managing transparent huge pages in page cache where
all entries are aligned but this function can handle arbitrary unaligned
ranges. Might be useful for PAT or VMA-like extent trees.

By default filling range constructs shallow tree: entries are assigned
directly inner slots if possible. In worst case any range requires only
2 * RADIX_TREE_MAX_PATH nodes. If length is power of two and start index
is aligned then all slots are always in single node and requires at most
RADIX_TREE_MAX_PATH nodes.

Function accepts several flags:

RADIX_TREE_FILL_LEAVES  - build deep tree, insert entry into leaves.

RADIX_TREE_FILL_OVERWRITE - overwrite instead of failing with -EEXIST.

RADIX_TREE_FILL_ATOMIC - play well with concurrent RCU-protected lookup:
fill new nodes with RADIX_TREE_RETRY before inserting them into the tree.
At following iterations these slots are filled with @item or sub-nodes.

RADIX_TREE_FILL_CLEAR_TAGS - also clears all tags.

radix_tree_fill_range() returns pointer to the node which holds the last
slot in range, NULL if this is root slot, or ERR_PTR in case of error.

Thus, radix_tree_fill_range() can handle all operations required for THP:

* Insert
Fill range with pointer to head page.

radix_tree_fill_range(root, index, index + nr_pages - 1, head_page,
		      RADIX_TREE_FILL_ATOMIC)

* Remove
Fill range with NULL or shadow entry, returned value will be used for
linking completely shadow nodes into slab shrinker.

radix_tree_fill_range(root, index, index + nr_pages - 1, NULL,
		      RADIX_TREE_FILL_OVERWRITE)

* Merge
Fill range with overwrite to replace 0-order pages with THP.

radix_tree_fill_range(root, index, index + nr_pages - 1, head_page,
		      RADIX_TREE_FILL_OVERWRITE | RADIX_TREE_FILL_ATOMIC)

* Split
Two passes: first fill leaves with head_page entry and then replace each
slot with pointer to individual tail page. This could be done in single
pass but makes radix_tree_fill_range much more complicated.

radix_tree_fill_range(root, index, index + nr_pages - 1, head_page,
		      RADIX_TREE_FILL_LEAVES | RADIX_TREE_FILL_OVERWRITE |
		      RADIX_TREE_FILL_ATOMIC);
radix_tree_for_each_slot(...)
	radix_tree_replace_slot(slot, head + iter.index - head->index);


Page lookup and iterator will return pointer to head page for any index.


Code inside iterator loop could detect huge entry, handle all sub-pages
and jump to next index using new helper function radix_tree_iter_jump():

slot = radix_tree_iter_jump(&iter, page->index + hpage_nr_pages(page));

This helper has builtin protection against overflows: jump to index = 0
stops iterator. This uses existing logic in radix_tree_next_chunk():
if iter.next_index is zero then iter.index must be zero too.


Tags should be set only for last index of THP range: this way iterator
will find them regardless of starting index.

radix_tree_preload_range() pre-allocates nodes for filling range.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/radix-tree.h |   46 ++++++++
 lib/radix-tree.c           |  245 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 291 insertions(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 4613bf35c311..af33e8d93ec3 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -319,6 +319,35 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+#define RADIX_TREE_FILL_LEAVES		1 /* build full depth tree */
+#define RADIX_TREE_FILL_OVERWRITE	2 /* overwrite non-empty slots */
+#define RADIX_TREE_FILL_CLEAR_TAGS	4 /* clear all tags */
+#define RADIX_TREE_FILL_ATOMIC		8 /* play well with rcu lookup */
+
+struct radix_tree_node *
+radix_tree_fill_range(struct radix_tree_root *root, unsigned long start,
+		      unsigned long end, void *item, unsigned int flags);
+
+int radix_tree_preload_range(gfp_t gfp_mask, unsigned long start,
+			     unsigned long end, unsigned int flags);
+
+/**
+ * radix_tree_truncate_range  - remove everything in range
+ * @root:	radix tree root
+ * @start:	first index
+ * @end:	last index
+ *
+ * This function removes all items and tags within given range.
+ */
+static inline void
+radix_tree_truncate_range(struct radix_tree_root *root,
+			  unsigned long start, unsigned long end)
+{
+	radix_tree_fill_range(root, start, end, NULL,
+			      RADIX_TREE_FILL_OVERWRITE |
+			      RADIX_TREE_FILL_CLEAR_TAGS);
+}
+
 /**
  * struct radix_tree_iter - radix tree iterator state
  *
@@ -435,6 +464,23 @@ void **radix_tree_iter_next(struct radix_tree_iter *iter)
 }
 
 /**
+ * radix_tree_iter_jump - restart iterating from given index if it non-zero
+ * @iter:	iterator state
+ * @index:	next index
+ *
+ * If index is zero when iterator will stop. This protects from endless loop
+ * when index overflows after visiting last entry.
+ */
+static inline __must_check
+void **radix_tree_iter_jump(struct radix_tree_iter *iter, unsigned long index)
+{
+	iter->index = index - 1;
+	iter->next_index = index;
+	iter->tags = 0;
+	return NULL;
+}
+
+/**
  * radix_tree_chunk_size - get current chunk size
  *
  * @iter:	pointer to radix tree iterator
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1b7bf7314141..c46a60065a77 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -36,6 +36,7 @@
 #include <linux/bitops.h>
 #include <linux/rcupdate.h>
 #include <linux/preempt.h>		/* in_interrupt() */
+#include <linux/err.h>
 
 
 /* Number of nodes in fully populated tree of given height */
@@ -1014,6 +1015,250 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_next_chunk);
 
 /**
+ * radix_tree_preload_range  - preload nodes for filling range.
+ * @gfp_mask:
+ * @start:	first index
+ * @end:	last index
+ * @flags:	RADIX_TREE_FILL_*
+ */
+int radix_tree_preload_range(gfp_t gfp_mask, unsigned long start,
+			     unsigned long end, unsigned int flags)
+{
+	unsigned long length = end - start + 1;
+	int nr_nodes, shift;
+
+	/* Preloading doesn't help anything with this gfp mask, skip it */
+	if (!gfpflags_allow_blocking(gfp_mask)) {
+		preempt_disable();
+		return 0;
+	}
+
+	/*
+	 * For filling leaves tree must cover all indexes in range at all
+	 * levels plus RADIX_TREE_MAX_PATH required for growing tree depth
+	 * and only root node is shared for sure.
+	 *
+	 * If for aligned range we need RADIX_TREE_MAX_PATH for growing depth
+	 * and RADIX_TREE_MAX_PATH for path where all slots will be.
+	 *
+	 * For arbitrary range we need again RADIX_TREE_MAX_PATH for growing
+	 * depth and two RADIX_TREE_MAX_PATH chains for constructing arc of
+	 * slots from leaf to root and back. Only root node is shared.
+	 */
+	if (flags & RADIX_TREE_FILL_LEAVES) {
+		if (start > end)
+			return -EINVAL;
+		shift = 0;
+		nr_nodes = RADIX_TREE_MAX_PATH - 1;
+		do {
+			shift += RADIX_TREE_MAP_SHIFT;
+			nr_nodes += (end >> shift) - (start >> shift) + 1;
+		} while (shift < RADIX_TREE_INDEX_BITS);
+	} else if (is_power_of_2(length) && IS_ALIGNED(start, length))
+		nr_nodes = RADIX_TREE_MAX_PATH * 2 - 1;
+	else
+		nr_nodes = RADIX_TREE_MAX_PATH * 3 - 2;
+	return __radix_tree_preload(gfp_mask, nr_nodes);
+}
+EXPORT_SYMBOL(radix_tree_preload_range);
+
+/**
+ * radix_tree_fill_range - fill range of slots
+ * @root:	radix tree root
+ * @start:	first index
+ * @end:	last index
+ * @item:	value for filling, NULL for removing
+ * @flags:	RADIX_TREE_FILL_* flags
+ * Returns:	pointer last node or NULL, ERR_PTR for errors
+ *
+ * By default builds shallow tree: assign entry to inner slots if possible.
+ * In wost case range requires up to 2 * RADIX_TREE_MAX_PATH nodes plus
+ * RADIX_TREE_MAX_PATH for extending tree depth.
+ *
+ * If length is 2^n and start aligned to it then all slots are in one node.
+ *
+ * This function cannot fill or cut part of bugger range if this require
+ * spltting inner slots and insering new nodes: fails with -ERANGE.
+ *
+ * With flag RADIX_TREE_FILL_LEAVES builds deep tree and insert @item into
+ * leaf slots. This requires much more nodes.
+ *
+ * With flag RADIX_TREE_FILL_OVERWRITE removes everything in range and cut
+ * sub-tree if @item is NULL. Without that flag function undo all chandges
+ * and fails with code -EEXIST if finds any populated slot.
+ *
+ * With flag RADIX_TREE_FILL_ATOMIC function plays well with rcu-protected
+ * lookups: it fills new nodes with RADIX_TREE_RETRY before inserting them
+ * into the tree: lookup will see either old entry, @item or retry entry.
+ * At following iterations these slots are filled with @item or sub-nodes.
+ *
+ * With flag RADIX_TREE_FILL_CLEAR_TAGS also clears all tags.
+ *
+ * Function returns pointer to node which holds the last slot in range,
+ * NULL if that was root slot, or ERR_PTR: -ENOMEM, -EEXIST, -ERANGE.
+ */
+struct radix_tree_node *
+radix_tree_fill_range(struct radix_tree_root *root, unsigned long start,
+		      unsigned long end, void *item, unsigned int flags)
+{
+	unsigned long index = start, maxindex;
+	struct radix_tree_node *node, *child;
+	int error, root_shift, shift, tag, offset;
+	void *entry;
+
+	/* Sanity check */
+	if (start > end)
+		return ERR_PTR(-EINVAL);
+
+	/* Make sure the tree is high enough.  */
+	root_shift = radix_tree_load_root(root, &node, &maxindex);
+	if (end > maxindex) {
+		error = radix_tree_extend(root, end, root_shift);
+		if (error < 0)
+			return ERR_PTR(error);
+		root_shift = error;
+	}
+
+	/* Special case: single slot tree */
+	if (!root_shift) {
+		if (node && (!(flags & RADIX_TREE_FILL_OVERWRITE)))
+			return ERR_PTR(-EEXIST);
+		if (flags & RADIX_TREE_FILL_CLEAR_TAGS)
+			root_tag_clear_all(root);
+		rcu_assign_pointer(root->rnode, item);
+		return NULL;
+	}
+
+next_node:
+	node = NULL;
+	offset = 0;
+	entry = rcu_dereference_raw(root->rnode);
+	shift = root_shift;
+
+	/* Descend to the index. Do at least one step. */
+	do {
+		child = entry_to_node(entry);
+		shift -= RADIX_TREE_MAP_SHIFT;
+		if (!child || !radix_tree_is_internal_node(entry)) {
+			/* Entry wider than range */
+			if (child) {
+				error = -ERANGE;
+				goto undo;
+			}
+			/* Hole wider tnan truncated range */
+			if (!item)
+				goto skip_node;
+			child = radix_tree_node_alloc(root);
+			if (!child) {
+				error = -ENOMEM;
+				goto undo;
+			}
+			child->shift = shift;
+			child->offset = offset;
+			child->parent = node;
+			/* Populate range with retry entries. */
+			if (flags & RADIX_TREE_FILL_ATOMIC) {
+				int idx = (index >> shift) &
+					   RADIX_TREE_MAP_MASK;
+				int last = RADIX_TREE_MAP_SIZE;
+
+				if (end < (index | shift_maxindex(shift)))
+					last = (end >> shift) &
+						RADIX_TREE_MAP_MASK;
+				for (; idx <= last; idx++)
+					child->slots[idx] = RADIX_TREE_RETRY;
+			}
+			entry = node_to_entry(child);
+			if (node) {
+				rcu_assign_pointer(node->slots[offset], entry);
+				node->count++;
+			} else
+				rcu_assign_pointer(root->rnode, entry);
+		}
+		node = child;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		entry = rcu_dereference_raw(node->slots[offset]);
+
+		/* Stop if find leaf or slot inside range */
+	} while ((flags & RADIX_TREE_FILL_LEAVES) ? shift :
+			((index & ((1ul << shift) - 1)) ||
+			 (index | ((1ul << shift) - 1)) > end));
+
+next_slot:
+	/* NULL or retry entry */
+	if (entry <= RADIX_TREE_RETRY)
+		goto fill;
+
+	if (!(flags & RADIX_TREE_FILL_OVERWRITE)) {
+		error = -EEXIST;
+		goto undo;
+	}
+
+	/* Cut sub-tree */
+	if (unlikely(radix_tree_is_internal_node(entry))) {
+		rcu_assign_pointer(node->slots[offset], item);
+		child = entry_to_node(entry);
+		offset = 0;
+		do {
+			entry = rcu_dereference_raw(child->slots[offset]);
+			if (entry)
+				child->count--;
+			if (radix_tree_is_internal_node(entry)) {
+				child = entry_to_node(entry);
+				offset = 0;
+			} else if (++offset == RADIX_TREE_MAP_SIZE) {
+				offset = child->offset;
+				entry = child->parent;
+				WARN_ON_ONCE(child->count);
+				radix_tree_node_free(child);
+				child = entry;
+			}
+		} while (child != node);
+	}
+
+	if (flags & RADIX_TREE_FILL_CLEAR_TAGS) {
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			node_tag_clear(root, node, tag, offset);
+	}
+
+	/* Skip the rest if we're cleared class slot in node */
+	if (!--node->count && !item && __radix_tree_delete_node(root, node))
+		goto skip_node;
+
+
+fill:
+	rcu_assign_pointer(node->slots[offset], item);
+	if (item)
+		node->count++;
+
+	index += 1ul << shift;
+	if (index - 1 == end)
+		return node;
+
+	/* Next slot in this node and still in range */
+	if (index + (1ul << shift) - 1 <= end &&
+			++offset < RADIX_TREE_MAP_SIZE) {
+		entry = rcu_dereference_raw(node->slots[offset]);
+		goto next_slot;
+	}
+
+	goto next_node;
+
+skip_node:
+	index |= shift_maxindex(shift);
+	if (index++ >= end)
+		return node;
+	goto next_node;
+
+undo:
+	if (index > start)
+		radix_tree_fill_range(root, start, index - 1, NULL,
+				      RADIX_TREE_FILL_OVERWRITE);
+	return ERR_PTR(error);
+}
+EXPORT_SYMBOL(radix_tree_fill_range);
+
+/**
  * radix_tree_range_tag_if_tagged - for each item in given range set given
  *				   tag if item has another tag set
  * @root:		radix tree root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
