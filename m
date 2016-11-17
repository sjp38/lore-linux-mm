Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 525326B034D
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:32:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so56218932wms.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:32:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m7si1291472wjg.231.2016.11.17.11.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:32:14 -0800 (PST)
Date: Thu, 17 Nov 2016 14:32:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/9] mm: workingset: move shadow entry tracking to radix tree
 exceptional tracking
Message-ID: <20161117193211.GE23430@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Currently, we track the shadow entries in the page cache in the upper
bits of the radix_tree_node->count, behind the back of the radix tree
implementation. Because the radix tree code has no awareness of them,
we rely on random subtleties throughout the implementation (such as
the node->count != 1 check in the shrinking code, which is meant to
exclude multi-entry nodes but also happens to skip nodes with only one
shadow entry, as that's accounted in the upper bits). This is error
prone and has, in fact, caused the bug fixed in d3798ae8c6f3 ("mm:
filemap: don't plant shadow entries without radix tree node").

To remove these subtleties, this patch moves shadow entry tracking
from the upper bits of node->count to the existing counter for
exceptional entries. node->count goes back to being a simple counter
of valid entries in the tree node and can be shrunk to a single byte.

This vastly simplifies the page cache code. All accounting happens
natively inside the radix tree implementation, and maintaining the LRU
linkage of shadow nodes is consolidated into a single function in the
workingset code that is called for leaf nodes affected by a change in
the page cache tree.

This also removes the last user of the __radix_delete_node() return
value. Eliminate it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  8 ++-----
 include/linux/swap.h       | 34 +---------------------------
 lib/radix-tree.c           | 25 +++++----------------
 mm/filemap.c               | 54 +++++---------------------------------------
 mm/truncate.c              | 21 +++--------------
 mm/workingset.c            | 56 +++++++++++++++++++++++++++++++++++-----------
 6 files changed, 60 insertions(+), 138 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 15c972ea9510..744486057e9e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -80,14 +80,10 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
-/* Internally used bits of node->count */
-#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
-#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
-
 struct radix_tree_node {
 	unsigned char	shift;		/* Bits remaining in each slot */
 	unsigned char	offset;		/* Slot offset in parent */
-	unsigned int	count;		/* Total entry count */
+	unsigned char	count;		/* Total entry count */
 	unsigned char	exceptional;	/* Exceptional entry count */
 	union {
 		struct {
@@ -270,7 +266,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  radix_tree_update_node_t update_node, void *private);
 void radix_tree_replace_slot(struct radix_tree_root *root,
 			     void **slot, void *item);
-bool __radix_tree_delete_node(struct radix_tree_root *root,
+void __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a56523cefb9b..09b212d37f1d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -246,39 +246,7 @@ struct swap_info_struct {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
-extern struct list_lru workingset_shadow_nodes;
-
-static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
-{
-	return node->count & RADIX_TREE_COUNT_MASK;
-}
-
-static inline void workingset_node_pages_inc(struct radix_tree_node *node)
-{
-	node->count++;
-}
-
-static inline void workingset_node_pages_dec(struct radix_tree_node *node)
-{
-	VM_WARN_ON_ONCE(!workingset_node_pages(node));
-	node->count--;
-}
-
-static inline unsigned int workingset_node_shadows(struct radix_tree_node *node)
-{
-	return node->count >> RADIX_TREE_COUNT_SHIFT;
-}
-
-static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
-{
-	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
-}
-
-static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
-{
-	VM_WARN_ON_ONCE(!workingset_node_shadows(node));
-	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
-}
+void workingset_update_node(struct radix_tree_node *node, void *private);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index df4ff18dd63c..9dbfaac05e6c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -541,12 +541,10 @@ static int radix_tree_extend(struct radix_tree_root *root,
  *	radix_tree_shrink    -    shrink radix tree to minimum height
  *	@root		radix tree root
  */
-static inline bool radix_tree_shrink(struct radix_tree_root *root,
+static inline void radix_tree_shrink(struct radix_tree_root *root,
 				     radix_tree_update_node_t update_node,
 				     void *private)
 {
-	bool shrunk = false;
-
 	for (;;) {
 		struct radix_tree_node *node = root->rnode;
 		struct radix_tree_node *child;
@@ -606,26 +604,20 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		}
 
 		radix_tree_node_free(node);
-		shrunk = true;
 	}
-
-	return shrunk;
 }
 
-static bool delete_node(struct radix_tree_root *root,
+static void delete_node(struct radix_tree_root *root,
 			struct radix_tree_node *node,
 			radix_tree_update_node_t update_node, void *private)
 {
-	bool deleted = false;
-
 	do {
 		struct radix_tree_node *parent;
 
 		if (node->count) {
 			if (node == entry_to_node(root->rnode))
-				deleted |= radix_tree_shrink(root, update_node,
-							     private);
-			return deleted;
+				radix_tree_shrink(root, update_node, private);
+			return;
 		}
 
 		parent = node->parent;
@@ -638,12 +630,9 @@ static bool delete_node(struct radix_tree_root *root,
 		}
 
 		radix_tree_node_free(node);
-		deleted = true;
 
 		node = parent;
 	} while (node);
-
-	return deleted;
 }
 
 /**
@@ -1595,13 +1584,11 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
  *	After clearing the slot at @index in @node from radix tree
  *	rooted at @root, call this function to attempt freeing the
  *	node and shrinking the tree.
- *
- *	Returns %true if @node was freed, %false otherwise.
  */
-bool __radix_tree_delete_node(struct radix_tree_root *root,
+void __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node)
 {
-	return delete_node(root, node, NULL, NULL);
+	delete_node(root, node, NULL, NULL);
 }
 
 static inline void delete_sibling_entries(struct radix_tree_node *node,
diff --git a/mm/filemap.c b/mm/filemap.c
index eb463156f29a..7d92032277ff 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -132,37 +132,19 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		if (!dax_mapping(mapping)) {
 			if (shadowp)
 				*shadowp = p;
-			if (node)
-				workingset_node_shadows_dec(node);
 		} else {
 			/* DAX can replace empty locked entry with a hole */
 			WARN_ON_ONCE(p !=
 				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
 					 RADIX_DAX_ENTRY_LOCK));
-			/* DAX accounts exceptional entries as normal pages */
-			if (node)
-				workingset_node_pages_dec(node);
 			/* Wakeup waiters for exceptional entry lock */
 			dax_wake_mapping_entry_waiter(mapping, page->index,
 						      false);
 		}
 	}
-	radix_tree_replace_slot(&mapping->page_tree, slot, page);
+	__radix_tree_replace(&mapping->page_tree, node, slot, page,
+			     workingset_update_node, mapping);
 	mapping->nrpages++;
-	if (node) {
-		workingset_node_pages_inc(node);
-		/*
-		 * Don't track node that contains actual pages.
-		 *
-		 * Avoid acquiring the list_lru lock if already
-		 * untracked.  The list_empty() test is safe as
-		 * node->private_list is protected by
-		 * mapping->tree_lock.
-		 */
-		if (!list_empty(&node->private_list))
-			list_lru_del(&workingset_shadow_nodes,
-				     &node->private_list);
-	}
 	return 0;
 }
 
@@ -182,8 +164,6 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		__radix_tree_lookup(&mapping->page_tree, page->index + i,
 				    &node, &slot);
 
-		radix_tree_clear_tags(&mapping->page_tree, node, slot);
-
 		if (!node) {
 			VM_BUG_ON_PAGE(nr != 1, page);
 			/*
@@ -193,33 +173,9 @@ static void page_cache_tree_delete(struct address_space *mapping,
 			shadow = NULL;
 		}
 
-		radix_tree_replace_slot(&mapping->page_tree, slot, shadow);
-
-		if (!node)
-			break;
-
-		workingset_node_pages_dec(node);
-		if (shadow)
-			workingset_node_shadows_inc(node);
-		else
-			if (__radix_tree_delete_node(&mapping->page_tree, node))
-				continue;
-
-		/*
-		 * Track node that only contains shadow entries. DAX mappings
-		 * contain no shadow entries and may contain other exceptional
-		 * entries so skip those.
-		 *
-		 * Avoid acquiring the list_lru lock if already tracked.
-		 * The list_empty() test is safe as node->private_list is
-		 * protected by mapping->tree_lock.
-		 */
-		if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
-				list_empty(&node->private_list)) {
-			node->private_data = mapping;
-			list_lru_add(&workingset_shadow_nodes,
-					&node->private_list);
-		}
+		radix_tree_clear_tags(&mapping->page_tree, node, slot);
+		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
+				     workingset_update_node, mapping);
 	}
 
 	if (shadow) {
diff --git a/mm/truncate.c b/mm/truncate.c
index 6ae44571d4c7..7e5464a611db 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -44,28 +44,13 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * without the tree itself locked.  These unlocked entries
 	 * need verification under the tree lock.
 	 */
-	if (!__radix_tree_lookup(&mapping->page_tree, index, &node,
-				&slot))
+	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
 		goto unlock;
 	if (*slot != entry)
 		goto unlock;
-	radix_tree_replace_slot(&mapping->page_tree, slot, NULL);
+	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
+			     workingset_update_node, mapping);
 	mapping->nrexceptional--;
-	if (!node)
-		goto unlock;
-	workingset_node_shadows_dec(node);
-	/*
-	 * Don't track node without shadow entries.
-	 *
-	 * Avoid acquiring the list_lru lock if already untracked.
-	 * The list_empty() test is safe as node->private_list is
-	 * protected by mapping->tree_lock.
-	 */
-	if (!workingset_node_shadows(node) &&
-	    !list_empty(&node->private_list))
-		list_lru_del(&workingset_shadow_nodes,
-				&node->private_list);
-	__radix_tree_delete_node(&mapping->page_tree, node);
 unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 }
diff --git a/mm/workingset.c b/mm/workingset.c
index 3cfc61d84a52..111e06559892 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -10,6 +10,7 @@
 #include <linux/atomic.h>
 #include <linux/module.h>
 #include <linux/swap.h>
+#include <linux/dax.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 
@@ -334,18 +335,45 @@ void workingset_activation(struct page *page)
  * point where they would still be useful.
  */
 
-struct list_lru workingset_shadow_nodes;
+static struct list_lru shadow_nodes;
+
+void workingset_update_node(struct radix_tree_node *node, void *private)
+{
+	struct address_space *mapping = private;
+
+	/* Only regular page cache has shadow entries */
+	if (dax_mapping(mapping) || shmem_mapping(mapping))
+		return;
+
+	/*
+	 * Track non-empty nodes that contain only shadow entries;
+	 * unlink those that contain pages or are being freed.
+	 *
+	 * Avoid acquiring the list_lru lock when the nodes are
+	 * already where they should be. The list_empty() test is safe
+	 * as node->private_list is protected by &mapping->tree_lock.
+	 */
+	if (node->count && node->count == node->exceptional) {
+		if (list_empty(&node->private_list)) {
+			node->private_data = mapping;
+			list_lru_add(&shadow_nodes, &node->private_list);
+		}
+	} else {
+		if (!list_empty(&node->private_list))
+			list_lru_del(&shadow_nodes, &node->private_list);
+	}
+}
 
 static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 					struct shrink_control *sc)
 {
-	unsigned long shadow_nodes;
 	unsigned long max_nodes;
+	unsigned long nodes;
 	unsigned long pages;
 
 	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
-	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
+	nodes = list_lru_shrink_count(&shadow_nodes, sc);
 	local_irq_enable();
 
 	if (memcg_kmem_enabled()) {
@@ -372,10 +400,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 */
 	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
 
-	if (shadow_nodes <= max_nodes)
+	if (nodes <= max_nodes)
 		return 0;
 
-	return shadow_nodes - max_nodes;
+	return nodes - max_nodes;
 }
 
 static enum lru_status shadow_lru_isolate(struct list_head *item,
@@ -418,22 +446,25 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
+	if (WARN_ON_ONCE(!node->exceptional))
 		goto out_invalid;
-	if (WARN_ON_ONCE(workingset_node_pages(node)))
+	if (WARN_ON_ONCE(node->count != node->exceptional))
 		goto out_invalid;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
 				goto out_invalid;
+			if (WARN_ON_ONCE(!node->exceptional))
+				goto out_invalid;
 			if (WARN_ON_ONCE(!mapping->nrexceptional))
 				goto out_invalid;
 			node->slots[i] = NULL;
-			workingset_node_shadows_dec(node);
+			node->exceptional--;
+			node->count--;
 			mapping->nrexceptional--;
 		}
 	}
-	if (WARN_ON_ONCE(workingset_node_shadows(node)))
+	if (WARN_ON_ONCE(node->exceptional))
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node);
@@ -456,8 +487,7 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 
 	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
-	ret =  list_lru_shrink_walk(&workingset_shadow_nodes, sc,
-				    shadow_lru_isolate, NULL);
+	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
 	local_irq_enable();
 	return ret;
 }
@@ -496,7 +526,7 @@ static int __init workingset_init(void)
 	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
 	       timestamp_bits, max_order, bucket_order);
 
-	ret = list_lru_init_key(&workingset_shadow_nodes, &shadow_nodes_key);
+	ret = list_lru_init_key(&shadow_nodes, &shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);
@@ -504,7 +534,7 @@ static int __init workingset_init(void)
 		goto err_list_lru;
 	return 0;
 err_list_lru:
-	list_lru_destroy(&workingset_shadow_nodes);
+	list_lru_destroy(&shadow_nodes);
 err:
 	return ret;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
