Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E038F8296C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:17 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so5624229pab.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.38.58
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 04/41] radix-tree: Add radix_tree_split
Date: Fri, 12 Aug 2016 21:37:47 +0300
Message-Id: <1471027104-115213-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This new function splits a larger multiorder entry into smaller entries
(potentially multi-order entries).  These entries are initialised to
RADIX_TREE_RETRY to ensure that RCU walkers who see this state aren't
confused.  The caller should then call radix_tree_for_each_slot() and
radix_tree_replace_slot() in order to turn these retry entries into the
intended new entries.  Tags are replicated from the original multiorder
entry into each new entry.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/radix-tree.h            |   6 +-
 lib/radix-tree.c                      | 109 ++++++++++++++++++++++++++++++++--
 tools/testing/radix-tree/multiorder.c |  26 ++++++++
 3 files changed, 135 insertions(+), 6 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 75ae4648d13d..459e8a152c8a 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -280,8 +280,7 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
-struct radix_tree_node *radix_tree_replace_clear_tags(
-				struct radix_tree_root *root,
+struct radix_tree_node *radix_tree_replace_clear_tags(struct radix_tree_root *,
 				unsigned long index, void *entry);
 unsigned int radix_tree_gang_lookup(struct radix_tree_root *root,
 			void **results, unsigned long first_index,
@@ -319,8 +318,11 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+int radix_tree_split(struct radix_tree_root *, unsigned long index,
+			unsigned new_order);
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
+
 /**
  * struct radix_tree_iter - radix tree iterator state
  *
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 00830dd77086..e69f1053cd78 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -231,7 +231,10 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		void *entry = node->slots[i];
 		if (!entry)
 			continue;
-		if (is_sibling_entry(node, entry)) {
+		if (entry == RADIX_TREE_RETRY) {
+			pr_debug("radix retry offset %ld indices %ld-%ld\n",
+					i, first, last);
+		} else if (is_sibling_entry(node, entry)) {
 			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
 					entry, i,
 					*(void **)entry_to_node(entry),
@@ -635,7 +638,10 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
 	unsigned i, n, tag, offset, tags = 0;
 
 	if (node) {
-		n = 1 << (order - node->shift);
+		if (order > node->shift)
+			n = 1 << (order - node->shift);
+		else
+			n = 1;
 		offset = get_slot_offset(node, slot);
 	} else {
 		n = 1;
@@ -674,7 +680,8 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
 					tag_set(node, tag, offset);
 		}
 		if (radix_tree_is_internal_node(old) &&
-					!is_sibling_entry(node, old))
+					!is_sibling_entry(node, old) &&
+					(old != RADIX_TREE_RETRY))
 			radix_tree_free_nodes(old);
 	}
 	if (node)
@@ -837,6 +844,98 @@ int radix_tree_join(struct radix_tree_root *root, unsigned long index,
 
 	return error;
 }
+
+int radix_tree_split(struct radix_tree_root *root, unsigned long index,
+				unsigned order)
+{
+	struct radix_tree_node *parent, *node, *child;
+	void **slot;
+	unsigned int offset, end;
+	unsigned n, tag, tags = 0;
+
+	if (!__radix_tree_lookup(root, index, &parent, &slot))
+		return -ENOENT;
+	if (!parent)
+		return -ENOENT;
+
+	offset = get_slot_offset(parent, slot);
+
+	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+		if (tag_get(parent, tag, offset))
+			tags |= 1 << tag;
+
+	for (end = offset + 1; end < RADIX_TREE_MAP_SIZE; end++) {
+		if (!is_sibling_entry(parent, parent->slots[end]))
+			break;
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			if (tags & (1 << tag))
+				tag_set(parent, tag, end);
+		/* tags must be set before RETRY is set */
+		rcu_assign_pointer(parent->slots[end], RADIX_TREE_RETRY);
+	}
+
+	if (order == parent->shift)
+		return 0;
+	if (order > parent->shift) {
+		while (offset < end)
+			offset += insert_entries(parent, &parent->slots[offset],
+					RADIX_TREE_RETRY, order, true);
+		return 0;
+	}
+
+	node = parent;
+
+	for (;;) {
+		if (node->shift > order) {
+			child = radix_tree_node_alloc(root);
+			if (!child)
+				goto nomem;
+			child->shift = node->shift - RADIX_TREE_MAP_SHIFT;
+			child->offset = offset;
+			child->count = 0;
+			child->parent = node;
+			if (node != parent) {
+				node->count++;
+				node->slots[offset] = node_to_entry(child);
+				for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+					if (tags & (1 << tag))
+						tag_set(node, tag, offset);
+			}
+
+			node = child;
+			offset = 0;
+			continue;
+		}
+
+		n = insert_entries(node, &node->slots[offset],
+					RADIX_TREE_RETRY, order, false);
+		BUG_ON(n > RADIX_TREE_MAP_SIZE);
+
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			if (tags & (1 << tag))
+				tag_set(node, tag, offset);
+		offset += n;
+
+		while (offset == RADIX_TREE_MAP_SIZE) {
+			if (node == parent)
+				break;
+			offset = node->offset;
+			child = node;
+			node = node->parent;
+			rcu_assign_pointer(node->slots[offset],
+						node_to_entry(child));
+			offset++;
+		}
+		if ((node == parent) && (offset == end))
+			return 0;
+	}
+
+ nomem:
+	/* Shouldn't happen; did user forget to preload? */
+	/* TODO: free all the allocated nodes */
+	WARN_ON(1);
+	return -ENOMEM;
+}
 #endif
 
 /**
@@ -1075,8 +1174,10 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 			child = rcu_dereference_raw(node->slots[offset]);
 		}
 
-		if ((child == NULL) || (child == RADIX_TREE_RETRY))
+		if (!child)
 			goto restart;
+		if (child == RADIX_TREE_RETRY)
+			break;
 	} while (radix_tree_is_internal_node(child));
 
 	/* Update the iterator state */
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index f917da164b00..9d27a4dd7b2a 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -348,6 +348,31 @@ static void multiorder_join(void)
 	}
 }
 
+static void __multiorder_split(int old_order, int new_order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	void **slot;
+	struct radix_tree_iter iter;
+
+	item_insert_order(&tree, 0, old_order);
+	radix_tree_tag_set(&tree, 0, 2);
+	radix_tree_split(&tree, 0, new_order);
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		radix_tree_replace_slot(slot, item_create(iter.index));
+	}
+
+	item_kill_tree(&tree);
+}
+
+static void multiorder_split(void)
+{
+	int i, j;
+
+	for (i = 9; i < 19; i++)
+		for (j = 0; j < i; j++)
+			__multiorder_split(i, j);
+}
+
 void multiorder_checks(void)
 {
 	int i;
@@ -366,4 +391,5 @@ void multiorder_checks(void)
 	multiorder_iteration();
 	multiorder_tagged_iteration();
 	multiorder_join();
+	multiorder_split();
 }
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
