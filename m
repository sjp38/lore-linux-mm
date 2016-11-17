Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7586B02AB
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:08 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b132so76817210iti.5
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:08 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id d67si252090ioe.67.2016.11.16.14.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:07 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 10/29] radix-tree: Add radix_tree_join
Date: Wed, 16 Nov 2016 16:16:37 -0800
Message-Id: <1479341856-30320-13-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This new function allows for the replacement of many smaller entries in
the radix tree with one larger multiorder entry.  From the point of view
of an RCU walker, they may see a mixture of the smaller entries and the
large entry during the same walk, but they will never see NULL for an
index which was populated before the join.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h            |   2 +
 lib/radix-tree.c                      | 159 +++++++++++++++++++++++++++-------
 tools/testing/radix-tree/multiorder.c |  32 +++++++
 3 files changed, 163 insertions(+), 30 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index af3581b..1efd81f 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -319,6 +319,8 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+int radix_tree_join(struct radix_tree_root *, unsigned long index,
+			unsigned new_order, void *);
 /**
  * struct radix_tree_iter - radix tree iterator state
  *
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8e6d552..6a76252 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -314,18 +314,14 @@ static void radix_tree_node_rcu_free(struct rcu_head *head)
 {
 	struct radix_tree_node *node =
 			container_of(head, struct radix_tree_node, rcu_head);
-	int i;
 
 	/*
-	 * must only free zeroed nodes into the slab. radix_tree_shrink
-	 * can leave us with a non-NULL entry in the first slot, so clear
-	 * that here to make sure.
+	 * Must only free zeroed nodes into the slab.  We can be left with
+	 * non-NULL entries by radix_tree_free_nodes, so clear the entries
+	 * and tags here.
 	 */
-	for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
-		tag_clear(node, i, 0);
-
-	node->slots[0] = NULL;
-	node->count = 0;
+	memset(node->slots, 0, sizeof(node->slots));
+	memset(node->tags, 0, sizeof(node->tags));
 
 	kmem_cache_free(radix_tree_node_cachep, node);
 }
@@ -563,14 +559,14 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	shift = radix_tree_load_root(root, &child, &maxindex);
 
 	/* Make sure the tree is high enough.  */
+	if (order > 0 && max == ((1UL << order) - 1))
+		max++;
 	if (max > maxindex) {
 		int error = radix_tree_extend(root, max, shift);
 		if (error < 0)
 			return error;
 		shift = error;
 		child = root->rnode;
-		if (order == shift)
-			shift += RADIX_TREE_MAP_SHIFT;
 	}
 
 	while (shift > order) {
@@ -582,6 +578,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 				return -ENOMEM;
 			child->shift = shift;
 			child->offset = offset;
+			child->count = 0;
 			child->parent = node;
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
@@ -595,31 +592,113 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		slot = &node->slots[offset];
 	}
 
+	if (nodep)
+		*nodep = node;
+	if (slotp)
+		*slotp = slot;
+	return 0;
+}
+
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
-	/* Insert pointers to the canonical entry */
-	if (order > shift) {
-		unsigned i, n = 1 << (order - shift);
+/*
+ * Free any nodes below this node.  The tree is presumed to not need
+ * shrinking, and any user data in the tree is presumed to not need a
+ * destructor called on it.  If we need to add a destructor, we can
+ * add that functionality later.  Note that we may not clear tags or
+ * slots from the tree as an RCU walker may still have a pointer into
+ * this subtree.  We could replace the entries with RADIX_TREE_RETRY,
+ * but we'll still have to clear those in rcu_free.
+ */
+static void radix_tree_free_nodes(struct radix_tree_node *node)
+{
+	unsigned offset = 0;
+	struct radix_tree_node *child = entry_to_node(node);
+
+	for (;;) {
+		void *entry = child->slots[offset];
+		if (radix_tree_is_internal_node(entry) &&
+					!is_sibling_entry(child, entry)) {
+			child = entry_to_node(entry);
+			offset = 0;
+			continue;
+		}
+		offset++;
+		while (offset == RADIX_TREE_MAP_SIZE) {
+			struct radix_tree_node *old = child;
+			offset = child->offset + 1;
+			child = child->parent;
+			radix_tree_node_free(old);
+			if (old == entry_to_node(node))
+				return;
+		}
+	}
+}
+
+static inline int insert_entries(struct radix_tree_node *node, void **slot,
+				void *ptr, unsigned order, bool replace)
+{
+	struct radix_tree_node *child;
+	unsigned i, n, tag, offset, tags = 0;
+
+	if (node) {
+		n = 1 << (order - node->shift);
+		offset = get_slot_offset(node, slot);
+	} else {
+		n = 1;
+		offset = 0;
+	}
+
+	if (n > 1) {
 		offset = offset & ~(n - 1);
 		slot = &node->slots[offset];
-		child = node_to_entry(slot);
-		for (i = 0; i < n; i++) {
-			if (slot[i])
+	}
+	child = node_to_entry(slot);
+
+	for (i = 0; i < n; i++) {
+		if (slot[i]) {
+			if (replace) {
+				node->count--;
+				for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+					if (tag_get(node, tag, offset + i))
+						tags |= 1 << tag;
+			} else
 				return -EEXIST;
 		}
+	}
 
-		for (i = 1; i < n; i++) {
+	for (i = 0; i < n; i++) {
+		struct radix_tree_node *old = slot[i];
+		if (i) {
 			rcu_assign_pointer(slot[i], child);
-			node->count++;
+			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+				if (tags & (1 << tag))
+					tag_clear(node, tag, offset + i);
+		} else {
+			rcu_assign_pointer(slot[i], ptr);
+			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+				if (tags & (1 << tag))
+					tag_set(node, tag, offset);
 		}
+		if (radix_tree_is_internal_node(old) &&
+					!is_sibling_entry(node, old))
+			radix_tree_free_nodes(old);
 	}
-#endif
-
-	if (nodep)
-		*nodep = node;
-	if (slotp)
-		*slotp = slot;
-	return 0;
+	if (node)
+		node->count += n;
+	return n;
+}
+#else
+static inline int insert_entries(struct radix_tree_node *node, void **slot,
+				void *ptr, unsigned order, bool replace)
+{
+	if (*slot)
+		return -EEXIST;
+	rcu_assign_pointer(*slot, ptr);
+	if (node)
+		node->count++;
+	return 1;
 }
+#endif
 
 /**
  *	__radix_tree_insert    -    insert into a radix tree
@@ -642,13 +721,13 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 	error = __radix_tree_create(root, index, order, &node, &slot);
 	if (error)
 		return error;
-	if (*slot != NULL)
-		return -EEXIST;
-	rcu_assign_pointer(*slot, item);
+
+	error = insert_entries(node, slot, item, order, false);
+	if (error < 0)
+		return error;
 
 	if (node) {
 		unsigned offset = get_slot_offset(node, slot);
-		node->count++;
 		BUG_ON(tag_get(node, 0, offset));
 		BUG_ON(tag_get(node, 1, offset));
 		BUG_ON(tag_get(node, 2, offset));
@@ -746,6 +825,26 @@ void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+int radix_tree_join(struct radix_tree_root *root, unsigned long index,
+			unsigned order, void *item)
+{
+	struct radix_tree_node *node;
+	void **slot;
+	int error;
+
+	BUG_ON(radix_tree_is_internal_node(item));
+
+	error = __radix_tree_create(root, index, order, &node, &slot);
+	if (!error)
+		error = insert_entries(node, slot, item, order, true);
+	if (error > 0)
+		error = 0;
+
+	return error;
+}
+#endif
+
 /**
  *	radix_tree_tag_set - set a tag on a radix tree node
  *	@root:		radix tree root
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 05d7bc4..4c66acc 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -325,6 +325,37 @@ void multiorder_tagged_iteration(void)
 	item_kill_tree(&tree);
 }
 
+static void __multiorder_join(unsigned long index,
+				unsigned order1, unsigned order2)
+{
+	unsigned long loc;
+	void *item, *item2 = item_create(index + 1);
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	item_insert_order(&tree, index, order2);
+	item = radix_tree_lookup(&tree, index);
+	radix_tree_join(&tree, index + 1, order1, item2);
+	loc = radix_tree_locate_item(&tree, item);
+	if (loc == -1)
+		free(item);
+	item = radix_tree_lookup(&tree, index + 1);
+	assert(item == item2);
+	item_kill_tree(&tree);
+}
+
+static void multiorder_join(void)
+{
+	int i, j, idx;
+
+	for (idx = 0; idx < 1024; idx = idx * 2 + 3) {
+		for (i = 1; i < 15; i++) {
+			for (j = 0; j < i; j++) {
+				__multiorder_join(idx, i, j);
+			}
+		}
+	}
+}
+
 void multiorder_checks(void)
 {
 	int i;
@@ -342,4 +373,5 @@ void multiorder_checks(void)
 	multiorder_tag_tests();
 	multiorder_iteration();
 	multiorder_tagged_iteration();
+	multiorder_join();
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
