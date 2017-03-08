Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 06727831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 08:09:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g2so55658141pge.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 05:09:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m63si3258762pld.36.2017.03.08.05.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 05:09:33 -0800 (PST)
Date: Wed, 8 Mar 2017 05:09:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] radix-tree: Remove 'private' parameter to functions
Message-ID: <20170308130932.GY16328@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org


Hey Johannes, could I get your Acked-by on this?

For the xarray, I'm thinking about moving some of this logic into the
xarray (controlled by a bit on the xarray so it's opt-in per xarray),
so that we can defrag nodes which are on the LRU lists.

-----8<-----

Now that radix_tree_node carries a pointer to the root, we no longer
have to pass the mapping pointer into workingset_update_node().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c                              |  2 +-
 include/linux/radix-tree.h            |  7 +++----
 include/linux/swap.h                  |  2 +-
 lib/idr.c                             |  2 +-
 lib/radix-tree.c                      | 34 +++++++++++++++-------------------
 mm/filemap.c                          |  4 ++--
 mm/shmem.c                            |  2 +-
 mm/truncate.c                         |  2 +-
 mm/workingset.c                       | 11 +++++++----
 tools/testing/radix-tree/multiorder.c |  2 +-
 10 files changed, 33 insertions(+), 35 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 3af2da5..cdf31cb 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -656,7 +656,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		ret = __radix_tree_lookup(page_tree, index, &node, &slot);
 		WARN_ON_ONCE(ret != entry);
 		__radix_tree_replace(page_tree, node, slot,
-				     new_entry, NULL, NULL);
+				     new_entry, NULL);
 	}
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index e505efa..a66e9d8 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -301,19 +301,18 @@ void *__radix_tree_lookup(const struct radix_tree_root *, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(const struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(const struct radix_tree_root *, unsigned long);
-typedef void (*radix_tree_update_node_t)(struct radix_tree_node *, void *);
+typedef void (*radix_tree_update_node_t)(struct radix_tree_node *);
 void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
 			  void **slot, void *item,
-			  radix_tree_update_node_t update_node, void *private);
+			  radix_tree_update_node_t update_node);
 void radix_tree_iter_replace(struct radix_tree_root *,
 		const struct radix_tree_iter *, void **slot, void *item);
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item);
 void __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node,
-			      radix_tree_update_node_t update_node,
-			      void *private);
+			      radix_tree_update_node_t update_node);
 void radix_tree_iter_delete(struct radix_tree_root *,
 				struct radix_tree_iter *iter, void **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7f47b70..b9c37c9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -247,7 +247,7 @@ struct swap_info_struct {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
-void workingset_update_node(struct radix_tree_node *node, void *private);
+void workingset_update_node(struct radix_tree_node *node);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/lib/idr.c b/lib/idr.c
index 8472fb7..0e31267 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -163,7 +163,7 @@ void *idr_replace(struct idr *idr, void *ptr, int id)
 	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
 		return ERR_PTR(-ENOENT);
 
-	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL, NULL);
+	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL);
 
 	return entry;
 }
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 5eef432..5007015 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -668,12 +668,12 @@ out:
 }
 
 /**
- *	radix_tree_shrink    -    shrink radix tree to minimum height
- *	@root		radix tree root
+ * radix_tree_shrink - shrink radix tree to minimum height
+ * @root: radix tree root
+ * @update_node: Callback if we free the node
  */
 static inline bool radix_tree_shrink(struct radix_tree_root *root,
-				     radix_tree_update_node_t update_node,
-				     void *private)
+				     radix_tree_update_node_t update_node)
 {
 	bool shrunk = false;
 
@@ -734,7 +734,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		if (!radix_tree_is_internal_node(child)) {
 			node->slots[0] = RADIX_TREE_RETRY;
 			if (update_node)
-				update_node(node, private);
+				update_node(node);
 		}
 
 		WARN_ON_ONCE(!list_empty(&node->private_list));
@@ -747,7 +747,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 
 static bool delete_node(struct radix_tree_root *root,
 			struct radix_tree_node *node,
-			radix_tree_update_node_t update_node, void *private)
+			radix_tree_update_node_t update_node)
 {
 	bool deleted = false;
 
@@ -756,8 +756,7 @@ static bool delete_node(struct radix_tree_root *root,
 
 		if (node->count) {
 			if (node == entry_to_node(root->rnode))
-				deleted |= radix_tree_shrink(root, update_node,
-								private);
+				deleted |= radix_tree_shrink(root, update_node);
 			return deleted;
 		}
 
@@ -1167,7 +1166,6 @@ static int calculate_count(struct radix_tree_root *root,
  * @slot:		pointer to slot in @node
  * @item:		new item to store in the slot.
  * @update_node:	callback for changing leaf nodes
- * @private:		private data to pass to @update_node
  *
  * For use with __radix_tree_lookup().  Caller must hold tree write locked
  * across slot lookup and replacement.
@@ -1175,7 +1173,7 @@ static int calculate_count(struct radix_tree_root *root,
 void __radix_tree_replace(struct radix_tree_root *root,
 			  struct radix_tree_node *node,
 			  void **slot, void *item,
-			  radix_tree_update_node_t update_node, void *private)
+			  radix_tree_update_node_t update_node)
 {
 	void *old = rcu_dereference_raw(*slot);
 	int exceptional = !!radix_tree_exceptional_entry(item) -
@@ -1195,9 +1193,9 @@ void __radix_tree_replace(struct radix_tree_root *root,
 		return;
 
 	if (update_node)
-		update_node(node, private);
+		update_node(node);
 
-	delete_node(root, node, update_node, private);
+	delete_node(root, node, update_node);
 }
 
 /**
@@ -1219,7 +1217,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item)
 {
-	__radix_tree_replace(root, NULL, slot, item, NULL, NULL);
+	__radix_tree_replace(root, NULL, slot, item, NULL);
 }
 
 /**
@@ -1234,7 +1232,7 @@ void radix_tree_replace_slot(struct radix_tree_root *root,
 void radix_tree_iter_replace(struct radix_tree_root *root,
 		const struct radix_tree_iter *iter, void **slot, void *item)
 {
-	__radix_tree_replace(root, iter->node, slot, item, NULL, NULL);
+	__radix_tree_replace(root, iter->node, slot, item, NULL);
 }
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
@@ -1961,7 +1959,6 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
  *	@root:		radix tree root
  *	@node:		node containing @index
  *	@update_node:	callback for changing leaf nodes
- *	@private:	private data to pass to @update_node
  *
  *	After clearing the slot at @index in @node from radix tree
  *	rooted at @root, call this function to attempt freeing the
@@ -1969,10 +1966,9 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
  */
 void __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node,
-			      radix_tree_update_node_t update_node,
-			      void *private)
+			      radix_tree_update_node_t update_node)
 {
-	delete_node(root, node, update_node, private);
+	delete_node(root, node, update_node);
 }
 
 static bool __radix_tree_delete(struct radix_tree_root *root,
@@ -1990,7 +1986,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 			node_tag_clear(root, node, tag, offset);
 
 	replace_slot(slot, NULL, node, -1, exceptional);
-	return node && delete_node(root, node, NULL, NULL);
+	return node && delete_node(root, node, NULL);
 }
 
 /**
diff --git a/mm/filemap.c b/mm/filemap.c
index b772a33..bb53277 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -142,7 +142,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		}
 	}
 	__radix_tree_replace(&mapping->page_tree, node, slot, page,
-			     workingset_update_node, mapping);
+			     workingset_update_node);
 	mapping->nrpages++;
 	return 0;
 }
@@ -170,7 +170,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 
 		radix_tree_clear_tags(&mapping->page_tree, node, slot);
 		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
-				     workingset_update_node, mapping);
+				     workingset_update_node);
 	}
 
 	if (shadow) {
diff --git a/mm/shmem.c b/mm/shmem.c
index bb53285..0ef377c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -312,7 +312,7 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
 	if (item != expected)
 		return -ENOENT;
 	__radix_tree_replace(&mapping->page_tree, node, pslot,
-			     replacement, NULL, NULL);
+			     replacement, NULL);
 	return 0;
 }
 
diff --git a/mm/truncate.c b/mm/truncate.c
index dd7b24e..7b83cce 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -41,7 +41,7 @@ static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
 	if (*slot != entry)
 		goto unlock;
 	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
-			     workingset_update_node, mapping);
+			     workingset_update_node);
 	mapping->nrexceptional--;
 unlock:
 	spin_unlock_irq(&mapping->tree_lock);
diff --git a/mm/workingset.c b/mm/workingset.c
index 80c913c..5734ad3 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -337,9 +337,12 @@ out:
 
 static struct list_lru shadow_nodes;
 
-void workingset_update_node(struct radix_tree_node *node, void *private)
+#define node_mapping(node)	\
+	container_of(node->root, struct address_space, page_tree)
+
+void workingset_update_node(struct radix_tree_node *node)
 {
-	struct address_space *mapping = private;
+	struct address_space *mapping = node_mapping(node);
 
 	/* Only regular page cache has shadow entries */
 	if (dax_mapping(mapping) || shmem_mapping(mapping))
@@ -433,7 +436,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 */
 
 	node = container_of(item, struct radix_tree_node, private_list);
-	mapping = container_of(node->root, struct address_space, page_tree);
+	mapping = node_mapping(node);
 
 	/* Coming from the list, invert the lock order */
 	if (!spin_trylock(&mapping->tree_lock)) {
@@ -472,7 +475,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
-				 workingset_update_node, mapping);
+				 workingset_update_node);
 
 out_invalid:
 	spin_unlock(&mapping->tree_lock);
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 06c7117..59245b3 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -618,7 +618,7 @@ static void multiorder_account(void)
 	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
 	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
 	assert(node->count == node->exceptional * 2);
-	__radix_tree_replace(&tree, node, slot, NULL, NULL, NULL);
+	__radix_tree_replace(&tree, node, slot, NULL, NULL);
 	assert(node->exceptional == 0);
 
 	item_kill_tree(&tree);
-- 
2.9.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
