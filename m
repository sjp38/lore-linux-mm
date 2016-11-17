Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63EA56B0309
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:35:20 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n68so72386128itn.4
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:35:20 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id x132si249997itf.70.2016.11.16.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:35:19 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 11/29] radix-tree: Add radix_tree_split
Date: Wed, 16 Nov 2016 16:17:14 -0800
Message-Id: <1479341856-30320-50-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

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
 include/linux/radix-tree.h            |   3 +
 lib/radix-tree.c                      | 109 ++++++++++++++++++++++++++++++++--
 tools/testing/radix-tree/multiorder.c |  26 ++++++++
 3 files changed, 134 insertions(+), 4 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 1efd81f..f5518f1 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -319,8 +319,11 @@ static inline void radix_tree_preload_end(void)
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
index 6a76252..eaf0f353 100644
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
@@ -641,7 +644,10 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
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
@@ -680,7 +686,8 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
 					tag_set(node, tag, offset);
 		}
 		if (radix_tree_is_internal_node(old) &&
-					!is_sibling_entry(node, old))
+					!is_sibling_entry(node, old) &&
+					(old != RADIX_TREE_RETRY))
 			radix_tree_free_nodes(old);
 	}
 	if (node)
@@ -843,6 +850,98 @@ int radix_tree_join(struct radix_tree_root *root, unsigned long index,
 
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
+		/* rcu_assign_pointer ensures tags are set before RETRY */
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
@@ -1081,8 +1180,10 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
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
index 4c66acc..d9e8155 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -356,6 +356,31 @@ static void multiorder_join(void)
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
@@ -374,4 +399,5 @@ void multiorder_checks(void)
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
