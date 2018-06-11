Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C28A76B02A6
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z11-v6so6629911pgu.1
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k9-v6si19738266pfc.129.2018.06.11.07.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:16 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 69/72] radix tree: Remove radix_tree_update_node_t
Date: Mon, 11 Jun 2018 07:06:36 -0700
Message-Id: <20180611140639.17215-70-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

The only user of this functionality was the workingset code, and it's
now been converted to the XArray.  Remove __radix_tree_delete_node()
entirely as it was also only used by the workingset code.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h            |  7 +----
 lib/idr.c                             |  2 +-
 lib/radix-tree.c                      | 42 +++++----------------------
 tools/testing/radix-tree/multiorder.c |  2 +-
 4 files changed, 11 insertions(+), 42 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 081e68b4376b..fc13c4b1afdb 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -242,17 +242,12 @@ void *__radix_tree_lookup(const struct radix_tree_root *, unsigned long index,
 void *radix_tree_lookup(const struct radix_tree_root *, unsigned long);
 void __rcu **radix_tree_lookup_slot(const struct radix_tree_root *,
 					unsigned long index);
-typedef void (*radix_tree_update_node_t)(struct radix_tree_node *);
 void __radix_tree_replace(struct radix_tree_root *, struct radix_tree_node *,
-			  void __rcu **slot, void *entry,
-			  radix_tree_update_node_t update_node);
+			  void __rcu **slot, void *entry);
 void radix_tree_iter_replace(struct radix_tree_root *,
 		const struct radix_tree_iter *, void __rcu **slot, void *entry);
 void radix_tree_replace_slot(struct radix_tree_root *,
 			     void __rcu **slot, void *entry);
-void __radix_tree_delete_node(struct radix_tree_root *,
-			      struct radix_tree_node *,
-			      radix_tree_update_node_t update_node);
 void radix_tree_iter_delete(struct radix_tree_root *,
 			struct radix_tree_iter *iter, void __rcu **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
diff --git a/lib/idr.c b/lib/idr.c
index 0d7410d1fb7c..58b88f5eb672 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -303,7 +303,7 @@ void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
 	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
 		return ERR_PTR(-ENOENT);
 
-	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL);
+	__radix_tree_replace(&idr->idr_rt, node, slot, ptr);
 
 	return entry;
 }
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d0f44ea96945..001062d41f9f 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -610,8 +610,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
  *	radix_tree_shrink    -    shrink radix tree to minimum height
  *	@root		radix tree root
  */
-static inline bool radix_tree_shrink(struct radix_tree_root *root,
-				     radix_tree_update_node_t update_node)
+static inline bool radix_tree_shrink(struct radix_tree_root *root)
 {
 	bool shrunk = false;
 
@@ -671,8 +670,6 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		node->count = 0;
 		if (!radix_tree_is_internal_node(child)) {
 			node->slots[0] = (void __rcu *)RADIX_TREE_RETRY;
-			if (update_node)
-				update_node(node);
 		}
 
 		WARN_ON_ONCE(!list_empty(&node->private_list));
@@ -684,8 +681,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 }
 
 static bool delete_node(struct radix_tree_root *root,
-			struct radix_tree_node *node,
-			radix_tree_update_node_t update_node)
+			struct radix_tree_node *node)
 {
 	bool deleted = false;
 
@@ -695,7 +691,7 @@ static bool delete_node(struct radix_tree_root *root,
 		if (node->count) {
 			if (node_to_entry(node) ==
 					rcu_dereference_raw(root->xa_head))
-				deleted |= radix_tree_shrink(root, update_node);
+				deleted |= radix_tree_shrink(root);
 			return deleted;
 		}
 
@@ -1100,15 +1096,13 @@ static int calculate_count(struct radix_tree_root *root,
  * @node:		pointer to tree node
  * @slot:		pointer to slot in @node
  * @item:		new item to store in the slot.
- * @update_node:	callback for changing leaf nodes
  *
  * For use with __radix_tree_lookup().  Caller must hold tree write locked
  * across slot lookup and replacement.
  */
 void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
-			  void __rcu **slot, void *item,
-			  radix_tree_update_node_t update_node)
+			  void __rcu **slot, void *item)
 {
 	void *old = rcu_dereference_raw(*slot);
 	int values = !!xa_is_value(item) - !!xa_is_value(old);
@@ -1126,10 +1120,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 	if (!node)
 		return;
 
-	if (update_node)
-		update_node(node);
-
-	delete_node(root, node, update_node);
+	delete_node(root, node);
 }
 
 /**
@@ -1151,7 +1142,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void __rcu **slot, void *item)
 {
-	__radix_tree_replace(root, NULL, slot, item, NULL);
+	__radix_tree_replace(root, NULL, slot, item);
 }
 EXPORT_SYMBOL(radix_tree_replace_slot);
 
@@ -1168,7 +1159,7 @@ void radix_tree_iter_replace(struct radix_tree_root *root,
 				const struct radix_tree_iter *iter,
 				void __rcu **slot, void *item)
 {
-	__radix_tree_replace(root, iter->node, slot, item, NULL);
+	__radix_tree_replace(root, iter->node, slot, item);
 }
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
@@ -1848,23 +1839,6 @@ radix_tree_gang_lookup_tag_slot(const struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
 
-/**
- *	__radix_tree_delete_node    -    try to free node after clearing a slot
- *	@root:		radix tree root
- *	@node:		node containing @index
- *	@update_node:	callback for changing leaf nodes
- *
- *	After clearing the slot at @index in @node from radix tree
- *	rooted at @root, call this function to attempt freeing the
- *	node and shrinking the tree.
- */
-void __radix_tree_delete_node(struct radix_tree_root *root,
-			      struct radix_tree_node *node,
-			      radix_tree_update_node_t update_node)
-{
-	delete_node(root, node, update_node);
-}
-
 static bool __radix_tree_delete(struct radix_tree_root *root,
 				struct radix_tree_node *node, void __rcu **slot)
 {
@@ -1880,7 +1854,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 			node_tag_clear(root, node, tag, offset);
 
 	replace_slot(slot, NULL, node, -1, values);
-	return node && delete_node(root, node, NULL);
+	return node && delete_node(root, node);
 }
 
 /**
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index c659056340df..fc7d0c4e812a 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -618,7 +618,7 @@ static void multiorder_account(void)
 	__radix_tree_insert(&tree, 1 << 5, 5, xa_mk_value(5));
 	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
 	assert(node->count == node->nr_values * 2);
-	__radix_tree_replace(&tree, node, slot, NULL, NULL);
+	__radix_tree_replace(&tree, node, slot, NULL);
 	assert(node->nr_values == 0);
 
 	item_kill_tree(&tree);
-- 
2.17.1
