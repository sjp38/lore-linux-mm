Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942C76B0266
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:26:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 81so3276682iog.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:26:14 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id g24si35165753ioj.134.2016.12.13.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:26:13 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 2/5] radix-tree: Ensure counts are initialised
Date: Tue, 13 Dec 2016 14:21:29 -0800
Message-Id: <1481667692-14500-3-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Tejun Heo <tj@kernel.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

radix_tree_join() was freeing nodes with a non-zero ->exceptional count,
and radix_tree_split() wasn't zeroing ->exceptional when it allocated
the new node.  Fix this by making all callers of radix_tree_node_alloc()
pass in the new counts (and some other always-initialised fields),
which will prevent the problem recurring if in future we decide to do
something similar.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 lib/radix-tree.c                      | 41 ++++++++++++++++---------------
 tools/testing/radix-tree/multiorder.c | 45 +++++++++++++++++++++++++++++++----
 2 files changed, 61 insertions(+), 25 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a227727..6f382e0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -287,7 +287,10 @@ static void radix_tree_dump(struct radix_tree_root *root)
  * that the caller has pinned this thread of control to the current CPU.
  */
 static struct radix_tree_node *
-radix_tree_node_alloc(struct radix_tree_root *root)
+radix_tree_node_alloc(struct radix_tree_root *root,
+			struct radix_tree_node *parent,
+			unsigned int shift, unsigned int offset,
+			unsigned int count, unsigned int exceptional)
 {
 	struct radix_tree_node *ret = NULL;
 	gfp_t gfp_mask = root_gfp_mask(root);
@@ -332,6 +335,13 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 out:
 	BUG_ON(radix_tree_is_internal_node(ret));
+	if (ret) {
+		ret->parent = parent;
+		ret->shift = shift;
+		ret->offset = offset;
+		ret->count = count;
+		ret->exceptional = exceptional;
+	}
 	return ret;
 }
 
@@ -537,8 +547,8 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		goto out;
 
 	do {
-		struct radix_tree_node *node = radix_tree_node_alloc(root);
-
+		struct radix_tree_node *node = radix_tree_node_alloc(root,
+							NULL, shift, 0, 1, 0);
 		if (!node)
 			return -ENOMEM;
 
@@ -549,16 +559,11 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		}
 
 		BUG_ON(shift > BITS_PER_LONG);
-		node->shift = shift;
-		node->offset = 0;
-		node->count = 1;
-		node->parent = NULL;
 		if (radix_tree_is_internal_node(slot)) {
 			entry_to_node(slot)->parent = node;
-		} else {
+		} else if (radix_tree_exceptional_entry(slot)) {
 			/* Moving an exceptional root->rnode to a node */
-			if (radix_tree_exceptional_entry(slot))
-				node->exceptional = 1;
+			node->exceptional = 1;
 		}
 		node->slots[0] = slot;
 		slot = node_to_entry(node);
@@ -711,14 +716,10 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		shift -= RADIX_TREE_MAP_SHIFT;
 		if (child == NULL) {
 			/* Have to add a child node.  */
-			child = radix_tree_node_alloc(root);
+			child = radix_tree_node_alloc(root, node, shift,
+							offset, 0, 0);
 			if (!child)
 				return -ENOMEM;
-			child->shift = shift;
-			child->offset = offset;
-			child->count = 0;
-			child->exceptional = 0;
-			child->parent = node;
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -1208,13 +1209,11 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 
 	for (;;) {
 		if (node->shift > order) {
-			child = radix_tree_node_alloc(root);
+			child = radix_tree_node_alloc(root, node,
+					node->shift - RADIX_TREE_MAP_SHIFT,
+					offset, 0, 0);
 			if (!child)
 				goto nomem;
-			child->shift = node->shift - RADIX_TREE_MAP_SHIFT;
-			child->offset = offset;
-			child->count = 0;
-			child->parent = node;
 			if (node != parent) {
 				node->count++;
 				node->slots[offset] = node_to_entry(child);
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 08b4e16..f79812a 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -355,7 +355,7 @@ void multiorder_tagged_iteration(void)
 	item_kill_tree(&tree);
 }
 
-static void __multiorder_join(unsigned long index,
+static void multiorder_join1(unsigned long index,
 				unsigned order1, unsigned order2)
 {
 	unsigned long loc;
@@ -373,7 +373,7 @@ static void __multiorder_join(unsigned long index,
 	item_kill_tree(&tree);
 }
 
-static void __multiorder_join2(unsigned order1, unsigned order2)
+static void multiorder_join2(unsigned order1, unsigned order2)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
 	struct radix_tree_node *node;
@@ -393,6 +393,39 @@ static void __multiorder_join2(unsigned order1, unsigned order2)
 	item_kill_tree(&tree);
 }
 
+/*
+ * This test revealed an accounting bug for exceptional entries at one point.
+ * Nodes were being freed back into the pool with an elevated exception count
+ * by radix_tree_join() and then radix_tree_split() was failing to zero the
+ * count of exceptional entries.
+ */
+static void multiorder_join3(unsigned int order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	struct radix_tree_node *node;
+	void **slot;
+	struct radix_tree_iter iter;
+	unsigned long i;
+
+	for (i = 0; i < (1 << order); i++) {
+		radix_tree_insert(&tree, i, (void *)0x12UL);
+	}
+
+	radix_tree_join(&tree, 0, order, (void *)0x16UL);
+	rcu_barrier();
+
+	radix_tree_split(&tree, 0, 0);
+
+	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
+		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x12UL);
+	}
+
+	__radix_tree_lookup(&tree, 0, &node, NULL);
+	assert(node->exceptional == node->count);
+
+	item_kill_tree(&tree);
+}
+
 static void multiorder_join(void)
 {
 	int i, j, idx;
@@ -400,16 +433,20 @@ static void multiorder_join(void)
 	for (idx = 0; idx < 1024; idx = idx * 2 + 3) {
 		for (i = 1; i < 15; i++) {
 			for (j = 0; j < i; j++) {
-				__multiorder_join(idx, i, j);
+				multiorder_join1(idx, i, j);
 			}
 		}
 	}
 
 	for (i = 1; i < 15; i++) {
 		for (j = 0; j < i; j++) {
-			__multiorder_join2(i, j);
+			multiorder_join2(i, j);
 		}
 	}
+
+	for (i = 3; i < 10; i++) {
+		multiorder_join3(i);
+	}
 }
 
 static void check_mem(unsigned old_order, unsigned new_order, unsigned alloc)
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
