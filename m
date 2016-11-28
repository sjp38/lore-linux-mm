Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8BE26B0275
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:39 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j65so260855679iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:39 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id d12si41417140iof.62.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 26/33] radix-tree: Fix replacement for multiorder entries
Date: Mon, 28 Nov 2016 13:51:04 -0800
Message-Id: <1480369871-5271-61-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

When replacing an entry with NULL, we need to delete any sibling entries.
Also account deleting exceptional entries properly.
Also fix a bug with radix_tree_iter_replace() where we would fail to
remove entirely freed nodes.
Also fix accounting bug when switching between normal and exceptional
entries with replace_slot.
Also add testcases for all these bugs.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 lib/radix-tree.c                      | 60 +++++++++++++++++-------
 tools/testing/radix-tree/multiorder.c | 87 ++++++++++++++++++++++++++++++-----
 2 files changed, 119 insertions(+), 28 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9d24bec..a227727 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -976,6 +976,24 @@ void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
+static inline int slot_count(struct radix_tree_node *node,
+						void **slot)
+{
+	int n = 1;
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	void *ptr = node_to_entry(slot);
+	unsigned offset = get_slot_offset(node, slot);
+	int i;
+
+	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[offset + i] != ptr)
+			break;
+		n++;
+	}
+#endif
+	return n;
+}
+
 static void replace_slot(struct radix_tree_root *root,
 			 struct radix_tree_node *node,
 			 void **slot, void *item,
@@ -994,12 +1012,35 @@ static void replace_slot(struct radix_tree_root *root,
 
 	if (node) {
 		node->count += count;
-		node->exceptional += exceptional;
+		if (exceptional) {
+			exceptional *= slot_count(node, slot);
+			node->exceptional += exceptional;
+		}
 	}
 
 	rcu_assign_pointer(*slot, item);
 }
 
+static inline void delete_sibling_entries(struct radix_tree_node *node,
+						void **slot)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	bool exceptional = radix_tree_exceptional_entry(*slot);
+	void *ptr = node_to_entry(slot);
+	unsigned offset = get_slot_offset(node, slot);
+	int i;
+
+	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[offset + i] != ptr)
+			break;
+		node->slots[offset + i] = NULL;
+		node->count--;
+		if (exceptional)
+			node->exceptional--;
+	}
+#endif
+}
+
 /**
  * __radix_tree_replace		- replace item in a slot
  * @root:		radix tree root
@@ -1017,6 +1058,8 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  void **slot, void *item,
 			  radix_tree_update_node_t update_node, void *private)
 {
+	if (!item)
+		delete_sibling_entries(node, slot);
 	/*
 	 * This function supports replacing exceptional entries and
 	 * deleting entries, but that needs accounting against the
@@ -1793,20 +1836,6 @@ void __radix_tree_delete_node(struct radix_tree_root *root,
 	delete_node(root, node, NULL, NULL);
 }
 
-static inline void delete_sibling_entries(struct radix_tree_node *node,
-					void *ptr, unsigned offset)
-{
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	int i;
-	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
-		if (node->slots[offset + i] != ptr)
-			break;
-		node->slots[offset + i] = NULL;
-		node->count--;
-	}
-#endif
-}
-
 /**
  *	radix_tree_delete_item    -    delete an item from a radix tree
  *	@root:		radix tree root
@@ -1846,7 +1875,6 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 		node_tag_clear(root, node, tag, offset);
 
-	delete_sibling_entries(node, node_to_entry(slot), offset);
 	__radix_tree_replace(root, node, slot, NULL, NULL, NULL);
 
 	return entry;
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 5421f01..9757b89 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -410,8 +410,6 @@ static void __multiorder_split(int old_order, int new_order)
 	RADIX_TREE(tree, GFP_ATOMIC);
 	void **slot;
 	struct radix_tree_iter iter;
-	struct radix_tree_node *node;
-	void *item;
 	unsigned alloc;
 
 	radix_tree_preload(GFP_KERNEL);
@@ -434,58 +432,122 @@ static void __multiorder_split(int old_order, int new_order)
 	radix_tree_preload_end();
 
 	item_kill_tree(&tree);
+}
+
+static void __multiorder_split2(int old_order, int new_order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	void **slot;
+	struct radix_tree_iter iter;
+	struct radix_tree_node *node;
+	void *item;
 
-	radix_tree_preload(GFP_KERNEL);
 	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
-	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x12);
 	assert(node->exceptional > 0);
 
-	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_iter_replace(&tree, &iter, slot,
 					item_create(iter.index, new_order));
 	}
-	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item != (void *)0x12);
 	assert(node->exceptional == 0);
 
 	item_kill_tree(&tree);
+}
+
+static void __multiorder_split3(int old_order, int new_order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	void **slot;
+	struct radix_tree_iter iter;
+	struct radix_tree_node *node;
+	void *item;
 
-	radix_tree_preload(GFP_KERNEL);
 	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
-	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x12);
 	assert(node->exceptional > 0);
 
-	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x16);
 	}
-	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x16);
 	assert(node->exceptional > 0);
 
 	item_kill_tree(&tree);
+
+	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+
+	item = __radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(item == (void *)0x12);
+	assert(node->exceptional > 0);
+
+	radix_tree_split(&tree, 0, new_order);
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		if (iter.index == (1 << new_order))
+			radix_tree_iter_replace(&tree, &iter, slot,
+						(void *)0x16);
+		else
+			radix_tree_iter_replace(&tree, &iter, slot, NULL);
+	}
+
+	item = __radix_tree_lookup(&tree, 1 << new_order, &node, NULL);
+	assert(item == (void *)0x16);
+	assert(node->count == node->exceptional);
+	do {
+		node = node->parent;
+		if (!node)
+			break;
+		assert(node->count == 1);
+		assert(node->exceptional == 0);
+	} while (1);
+
+	item_kill_tree(&tree);
 }
 
 static void multiorder_split(void)
 {
 	int i, j;
 
-	for (i = 9; i < 19; i++)
-		for (j = 0; j < i; j++)
+	for (i = 3; i < 11; i++)
+		for (j = 0; j < i; j++) {
 			__multiorder_split(i, j);
+			__multiorder_split2(i, j);
+			__multiorder_split3(i, j);
+		}
+}
+
+static void multiorder_account(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	struct radix_tree_node *node;
+	void **slot;
+
+	item_insert_order(&tree, 0, 5);
+
+	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
+	__radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(node->count == node->exceptional * 2);
+	radix_tree_delete(&tree, 1 << 5);
+	assert(node->exceptional == 0);
+
+	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
+	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
+	assert(node->count == node->exceptional * 2);
+	__radix_tree_replace(&tree, node, slot, NULL, NULL, NULL);
+	assert(node->exceptional == 0);
+
+	item_kill_tree(&tree);
 }
 
 void multiorder_checks(void)
@@ -507,6 +569,7 @@ void multiorder_checks(void)
 	multiorder_tagged_iteration();
 	multiorder_join();
 	multiorder_split();
+	multiorder_account();
 
 	radix_tree_cpu_dead(0);
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
