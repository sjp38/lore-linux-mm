Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 123D96B026F
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:40 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id c21so252592419ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:40 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id w128si41574148iod.17.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 24/33] radix-tree: Add radix_tree_split
Date: Mon, 28 Nov 2016 13:51:02 -0800
Message-Id: <1480369871-5271-59-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This new function splits a larger multiorder entry into smaller entries
(potentially multi-order entries).  These entries are initialised to
RADIX_TREE_RETRY to ensure that RCU walkers who see this state aren't
confused.  The caller should then call radix_tree_for_each_slot() and
radix_tree_replace_slot() in order to turn these retry entries into the
intended new entries.  Tags are replicated from the original multiorder
entry into each new entry.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h            |  12 +++
 lib/radix-tree.c                      | 142 +++++++++++++++++++++++++++++++++-
 tools/testing/radix-tree/multiorder.c |  64 +++++++++++++++
 3 files changed, 214 insertions(+), 4 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 935293a..1f4b561 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -80,6 +80,14 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
+/*
+ * @count is the count of every non-NULL element in the ->slots array
+ * whether that is an exceptional entry, a retry entry, a user pointer,
+ * a sibling entry or a pointer to the next level of the tree.
+ * @exceptional is the count of every element in ->slots which is
+ * either radix_tree_exceptional_entry() or is a sibling entry for an
+ * exceptional entry.
+ */
 struct radix_tree_node {
 	unsigned char	shift;		/* Bits remaining in each slot */
 	unsigned char	offset;		/* Slot offset in parent */
@@ -293,6 +301,8 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
 			  void **slot, void *item,
 			  radix_tree_update_node_t update_node, void *private);
+void radix_tree_iter_replace(struct radix_tree_root *,
+		const struct radix_tree_iter *, void **slot, void *item);
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item);
 void __radix_tree_delete_node(struct radix_tree_root *root,
@@ -335,6 +345,8 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+int radix_tree_split(struct radix_tree_root *, unsigned long index,
+			unsigned new_order);
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
 
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 257ad9d..704201b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -22,6 +22,7 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#include <linux/cpu.h>
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -757,7 +758,10 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
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
@@ -796,7 +800,8 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
 					tag_set(node, tag, offset);
 		}
 		if (radix_tree_is_internal_node(old) &&
-					!is_sibling_entry(node, old))
+					!is_sibling_entry(node, old) &&
+					(old != RADIX_TREE_RETRY))
 			radix_tree_free_nodes(old);
 		if (radix_tree_exceptional_entry(old))
 			node->exceptional--;
@@ -1020,7 +1025,8 @@ void __radix_tree_replace(struct radix_tree_root *root,
  * NOTE: This cannot be used to switch between non-entries (empty slots),
  * regular entries, and exceptional entries, as that requires accounting
  * inside the radix tree node. When switching from one type of entry or
- * deleting, use __radix_tree_lookup() and __radix_tree_replace().
+ * deleting, use __radix_tree_lookup() and __radix_tree_replace() or
+ * radix_tree_iter_replace().
  */
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item)
@@ -1028,6 +1034,21 @@ void radix_tree_replace_slot(struct radix_tree_root *root,
 	replace_slot(root, NULL, slot, item, true);
 }
 
+/**
+ * radix_tree_iter_replace - replace item in a slot
+ * @root:	radix tree root
+ * @slot:	pointer to slot
+ * @item:	new item to store in the slot.
+ *
+ * For use with radix_tree_split() and radix_tree_for_each_slot().
+ * Caller must hold tree write locked across split and replacement.
+ */
+void radix_tree_iter_replace(struct radix_tree_root *root,
+		const struct radix_tree_iter *iter, void **slot, void *item)
+{
+	__radix_tree_replace(root, iter->node, slot, item, NULL, NULL);
+}
+
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 /**
  * radix_tree_join - replace multiple entries with one multiorder entry
@@ -1060,6 +1081,117 @@ int radix_tree_join(struct radix_tree_root *root, unsigned long index,
 
 	return error;
 }
+
+/**
+ * radix_tree_split - Split an entry into smaller entries
+ * @root: radix tree root
+ * @index: An index within the large entry
+ * @order: Order of new entries
+ *
+ * Call this function as the first step in replacing a multiorder entry
+ * with several entries of lower order.  After this function returns,
+ * loop over the relevant portion of the tree using radix_tree_for_each_slot()
+ * and call radix_tree_iter_replace() to set up each new entry.
+ *
+ * The tags from this entry are replicated to all the new entries.
+ *
+ * The radix tree should be locked against modification during the entire
+ * replacement operation.  Lock-free lookups will see RADIX_TREE_RETRY which
+ * should prompt RCU walkers to restart the lookup from the root.
+ */
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
+		/* rcu_assign_pointer ensures tags are set before RETRY */
+		rcu_assign_pointer(parent->slots[end], RADIX_TREE_RETRY);
+	}
+	rcu_assign_pointer(parent->slots[offset], RADIX_TREE_RETRY);
+	parent->exceptional -= (end - offset);
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
@@ -1440,8 +1572,10 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
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
index c9f656c..fa6effe 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -389,6 +389,69 @@ static void multiorder_join(void)
 	}
 }
 
+static void __multiorder_split(int old_order, int new_order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	void **slot;
+	struct radix_tree_iter iter;
+	struct radix_tree_node *node;
+	void *item;
+
+	item_insert_order(&tree, 0, old_order);
+	radix_tree_tag_set(&tree, 0, 2);
+	radix_tree_split(&tree, 0, new_order);
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		radix_tree_iter_replace(&tree, &iter, slot,
+					item_create(iter.index, new_order));
+	}
+
+	item_kill_tree(&tree);
+
+	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+
+	item = __radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(item == (void *)0x12);
+	assert(node->exceptional > 0);
+
+	radix_tree_split(&tree, 0, new_order);
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		radix_tree_iter_replace(&tree, &iter, slot,
+					item_create(iter.index, new_order));
+	}
+
+	item = __radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(item != (void *)0x12);
+	assert(node->exceptional == 0);
+
+	item_kill_tree(&tree);
+
+	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+
+	item = __radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(item == (void *)0x12);
+	assert(node->exceptional > 0);
+
+	radix_tree_split(&tree, 0, new_order);
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x16);
+	}
+
+	item = __radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(item == (void *)0x16);
+	assert(node->exceptional > 0);
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
@@ -407,4 +470,5 @@ void multiorder_checks(void)
 	multiorder_iteration();
 	multiorder_tagged_iteration();
 	multiorder_join();
+	multiorder_split();
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
