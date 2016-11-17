Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED2406B034B
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:31:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so57297022wmd.6
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:31:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s9si4106098wmf.36.2016.11.17.11.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:31:37 -0800 (PST)
Date: Thu, 17 Nov 2016 14:31:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/9] lib: radix-tree: update callback for changing leaf nodes
Message-ID: <20161117193134.GD23430@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Support handing __radix_tree_replace() a callback that gets invoked
for all leaf nodes that change or get freed as a result of the slot
replacement, to assist users tracking nodes with node->private_list.

This prepares for putting page cache shadow entries into the radix
tree root again and drastically simplifying the shadow tracking.

Suggested-by: Jan Kara <jack@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/dax.c                   |  3 ++-
 include/linux/radix-tree.h |  4 +++-
 lib/radix-tree.c           | 42 +++++++++++++++++++++++++++++-------------
 mm/shmem.c                 |  3 ++-
 4 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 85930c2a2749..6916ed37d463 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -649,7 +649,8 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 
 		ret = __radix_tree_lookup(page_tree, index, &node, &slot);
 		WARN_ON_ONCE(ret != entry);
-		__radix_tree_replace(page_tree, node, slot, new_entry);
+		__radix_tree_replace(page_tree, node, slot,
+				     new_entry, NULL, NULL);
 	}
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 2d1b9b8be983..15c972ea9510 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -263,9 +263,11 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
+typedef void (*radix_tree_update_node_t)(struct radix_tree_node *, void *);
 void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
-			  void **slot, void *item);
+			  void **slot, void *item,
+			  radix_tree_update_node_t update_node, void *private);
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item);
 bool __radix_tree_delete_node(struct radix_tree_root *root,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 5d8930f3b3d8..df4ff18dd63c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -325,7 +325,6 @@ static void radix_tree_node_rcu_free(struct rcu_head *head)
 		tag_clear(node, i, 0);
 
 	node->slots[0] = NULL;
-	node->count = 0;
 
 	kmem_cache_free(radix_tree_node_cachep, node);
 }
@@ -542,7 +541,9 @@ static int radix_tree_extend(struct radix_tree_root *root,
  *	radix_tree_shrink    -    shrink radix tree to minimum height
  *	@root		radix tree root
  */
-static inline bool radix_tree_shrink(struct radix_tree_root *root)
+static inline bool radix_tree_shrink(struct radix_tree_root *root,
+				     radix_tree_update_node_t update_node,
+				     void *private)
 {
 	bool shrunk = false;
 
@@ -597,8 +598,12 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 		 * also results in a stale slot). So tag the slot as indirect
 		 * to force callers to retry.
 		 */
-		if (!radix_tree_is_internal_node(child))
+		node->count = 0;
+		if (!radix_tree_is_internal_node(child)) {
 			node->slots[0] = RADIX_TREE_RETRY;
+			if (update_node)
+				update_node(node, private);
+		}
 
 		radix_tree_node_free(node);
 		shrunk = true;
@@ -608,7 +613,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 }
 
 static bool delete_node(struct radix_tree_root *root,
-			struct radix_tree_node *node)
+			struct radix_tree_node *node,
+			radix_tree_update_node_t update_node, void *private)
 {
 	bool deleted = false;
 
@@ -617,7 +623,8 @@ static bool delete_node(struct radix_tree_root *root,
 
 		if (node->count) {
 			if (node == entry_to_node(root->rnode))
-				deleted |= radix_tree_shrink(root);
+				deleted |= radix_tree_shrink(root, update_node,
+							     private);
 			return deleted;
 		}
 
@@ -880,17 +887,20 @@ static void replace_slot(struct radix_tree_root *root,
 
 /**
  * __radix_tree_replace		- replace item in a slot
- * @root:	radix tree root
- * @node:	pointer to tree node
- * @slot:	pointer to slot in @node
- * @item:	new item to store in the slot.
+ * @root:		radix tree root
+ * @node:		pointer to tree node
+ * @slot:		pointer to slot in @node
+ * @item:		new item to store in the slot.
+ * @update_node:	callback for changing leaf nodes
+ * @private:		private data to pass to @update_node
  *
  * For use with __radix_tree_lookup().  Caller must hold tree write locked
  * across slot lookup and replacement.
  */
 void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
-			  void **slot, void *item)
+			  void **slot, void *item,
+			  radix_tree_update_node_t update_node, void *private)
 {
 	/*
 	 * This function supports replacing exceptional entries and
@@ -900,7 +910,13 @@ void __radix_tree_replace(struct radix_tree_root *root,
 	replace_slot(root, node, slot, item,
 		     !node && slot != (void **)&root->rnode);
 
-	delete_node(root, node);
+	if (!node)
+		return;
+
+	if (update_node)
+		update_node(node, private);
+
+	delete_node(root, node, update_node, private);
 }
 
 /**
@@ -1585,7 +1601,7 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
 bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node)
 {
-	return delete_node(root, node);
+	return delete_node(root, node, NULL, NULL);
 }
 
 static inline void delete_sibling_entries(struct radix_tree_node *node,
@@ -1642,7 +1658,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 		node_tag_clear(root, node, tag, offset);
 
 	delete_sibling_entries(node, node_to_entry(slot), offset);
-	__radix_tree_replace(root, node, slot, NULL);
+	__radix_tree_replace(root, node, slot, NULL, NULL, NULL);
 
 	return entry;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 7f3a08df25c9..62ac381069fc 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -311,7 +311,8 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
 		return -ENOENT;
 	if (item != expected)
 		return -ENOENT;
-	__radix_tree_replace(&mapping->page_tree, node, pslot, replacement);
+	__radix_tree_replace(&mapping->page_tree, node, pslot,
+			     replacement, NULL, NULL);
 	return 0;
 }
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
