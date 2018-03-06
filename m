Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 300FF6B027A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:24:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v3so8518407pfm.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:24:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q9si10224140pgc.401.2018.03.06.11.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:24:46 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v8 63/63] radix tree: Remove unused functions
Date: Tue,  6 Mar 2018 11:24:13 -0800
Message-Id: <20180306192413.5499-64-willy@infradead.org>
In-Reply-To: <20180306192413.5499-1-willy@infradead.org>
References: <20180306192413.5499-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The following functions are (now) unused:
 - __radix_tree_delete_node
 - radix_tree_gang_lookup_slot
 - radix_tree_join
 - radix_tree_maybe_preload_order
 - radix_tree_split
 - radix_tree_split_preload

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h |  16 +--
 lib/radix-tree.c           | 294 +--------------------------------------------
 2 files changed, 4 insertions(+), 306 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f64beb9ba175..eb2ae901f2ec 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -147,12 +147,11 @@ static inline unsigned int iter_shift(const struct radix_tree_iter *iter)
  * radix_tree_lookup_slot
  * radix_tree_tag_get
  * radix_tree_gang_lookup
- * radix_tree_gang_lookup_slot
  * radix_tree_gang_lookup_tag
  * radix_tree_gang_lookup_tag_slot
  * radix_tree_tagged
  *
- * The first 8 functions are able to be called locklessly, using RCU. The
+ * The first 7 functions are able to be called locklessly, using RCU. The
  * caller must ensure calls to these functions are made within rcu_read_lock()
  * regions. Other readers (lock-free or otherwise) and modifications may be
  * running concurrently.
@@ -254,9 +253,6 @@ void radix_tree_iter_replace(struct radix_tree_root *,
 		const struct radix_tree_iter *, void __rcu **slot, void *entry);
 void radix_tree_replace_slot(struct radix_tree_root *,
 			     void __rcu **slot, void *entry);
-void __radix_tree_delete_node(struct radix_tree_root *,
-			      struct radix_tree_node *,
-			      radix_tree_update_node_t update_node);
 void radix_tree_iter_delete(struct radix_tree_root *,
 			struct radix_tree_iter *iter, void __rcu **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
@@ -266,12 +262,8 @@ void radix_tree_clear_tags(struct radix_tree_root *, struct radix_tree_node *,
 unsigned int radix_tree_gang_lookup(const struct radix_tree_root *,
 			void **results, unsigned long first_index,
 			unsigned int max_items);
-unsigned int radix_tree_gang_lookup_slot(const struct radix_tree_root *,
-			void __rcu ***results, unsigned long *indices,
-			unsigned long first_index, unsigned int max_items);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
-int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *,
 			unsigned long index, unsigned int tag);
@@ -296,12 +288,6 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
-int radix_tree_split_preload(unsigned old_order, unsigned new_order, gfp_t);
-int radix_tree_split(struct radix_tree_root *, unsigned long index,
-			unsigned new_order);
-int radix_tree_join(struct radix_tree_root *, unsigned long index,
-			unsigned new_order, void *);
-
 void __rcu **idr_get_free(struct radix_tree_root *root,
 			      struct radix_tree_iter *iter, gfp_t gfp,
 			      unsigned long max);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 71697bd25140..20858120ac0b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -41,9 +41,6 @@
 #include <linux/xarray.h>
 
 
-/* Number of nodes in fully populated tree of given height */
-static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
-
 /*
  * Radix tree node cache.
  */
@@ -463,73 +460,6 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(radix_tree_maybe_preload);
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-/*
- * Preload with enough objects to ensure that we can split a single entry
- * of order @old_order into many entries of size @new_order
- */
-int radix_tree_split_preload(unsigned int old_order, unsigned int new_order,
-							gfp_t gfp_mask)
-{
-	unsigned top = 1 << (old_order % RADIX_TREE_MAP_SHIFT);
-	unsigned layers = (old_order / RADIX_TREE_MAP_SHIFT) -
-				(new_order / RADIX_TREE_MAP_SHIFT);
-	unsigned nr = 0;
-
-	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
-	BUG_ON(new_order >= old_order);
-
-	while (layers--)
-		nr = nr * RADIX_TREE_MAP_SIZE + 1;
-	return __radix_tree_preload(gfp_mask, top * nr);
-}
-#endif
-
-/*
- * The same as function above, but preload number of nodes required to insert
- * (1 << order) continuous naturally-aligned elements.
- */
-int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
-{
-	unsigned long nr_subtrees;
-	int nr_nodes, subtree_height;
-
-	/* Preloading doesn't help anything with this gfp mask, skip it */
-	if (!gfpflags_allow_blocking(gfp_mask)) {
-		preempt_disable();
-		return 0;
-	}
-
-	/*
-	 * Calculate number and height of fully populated subtrees it takes to
-	 * store (1 << order) elements.
-	 */
-	nr_subtrees = 1 << order;
-	for (subtree_height = 0; nr_subtrees > RADIX_TREE_MAP_SIZE;
-			subtree_height++)
-		nr_subtrees >>= RADIX_TREE_MAP_SHIFT;
-
-	/*
-	 * The worst case is zero height tree with a single item at index 0 and
-	 * then inserting items starting at ULONG_MAX - (1 << order).
-	 *
-	 * This requires RADIX_TREE_MAX_PATH nodes to build branch from root to
-	 * 0-index item.
-	 */
-	nr_nodes = RADIX_TREE_MAX_PATH;
-
-	/* Plus branch to fully populated subtrees. */
-	nr_nodes += RADIX_TREE_MAX_PATH - subtree_height;
-
-	/* Root node is shared. */
-	nr_nodes--;
-
-	/* Plus nodes required to build subtrees. */
-	nr_nodes += nr_subtrees * height_to_maxnodes[subtree_height];
-
-	return __radix_tree_preload(gfp_mask, nr_nodes);
-}
-
 static unsigned radix_tree_load_root(const struct radix_tree_root *root,
 		struct radix_tree_node **nodep, unsigned long *maxindex)
 {
@@ -1138,7 +1068,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
  * @slot:	pointer to slot
  * @item:	new item to store in the slot.
  *
- * For use with radix_tree_lookup_slot(), radix_tree_gang_lookup_slot(),
+ * For use with radix_tree_lookup_slot() and
  * radix_tree_gang_lookup_tag_slot().  Caller must hold tree write locked
  * across slot lookup and replacement.
  *
@@ -1161,8 +1091,8 @@ EXPORT_SYMBOL(radix_tree_replace_slot);
  * @slot:	pointer to slot
  * @item:	new item to store in the slot.
  *
- * For use with radix_tree_split() and radix_tree_for_each_slot().
- * Caller must hold tree write locked across split and replacement.
+ * For use with radix_tree_for_each_slot().
+ * Caller must hold tree write locked.
  */
 void radix_tree_iter_replace(struct radix_tree_root *root,
 				const struct radix_tree_iter *iter,
@@ -1171,151 +1101,6 @@ void radix_tree_iter_replace(struct radix_tree_root *root,
 	__radix_tree_replace(root, iter->node, slot, item, NULL);
 }
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-/**
- * radix_tree_join - replace multiple entries with one multiorder entry
- * @root: radix tree root
- * @index: an index inside the new entry
- * @order: order of the new entry
- * @item: new entry
- *
- * Call this function to replace several entries with one larger entry.
- * The existing entries are presumed to not need freeing as a result of
- * this call.
- *
- * The replacement entry will have all the tags set on it that were set
- * on any of the entries it is replacing.
- */
-int radix_tree_join(struct radix_tree_root *root, unsigned long index,
-			unsigned order, void *item)
-{
-	struct radix_tree_node *node;
-	void __rcu **slot;
-	int error;
-
-	BUG_ON(radix_tree_is_internal_node(item));
-
-	error = __radix_tree_create(root, index, order, &node, &slot);
-	if (!error)
-		error = insert_entries(node, slot, item, order, true);
-	if (error > 0)
-		error = 0;
-
-	return error;
-}
-
-/**
- * radix_tree_split - Split an entry into smaller entries
- * @root: radix tree root
- * @index: An index within the large entry
- * @order: Order of new entries
- *
- * Call this function as the first step in replacing a multiorder entry
- * with several entries of lower order.  After this function returns,
- * loop over the relevant portion of the tree using radix_tree_for_each_slot()
- * and call radix_tree_iter_replace() to set up each new entry.
- *
- * The tags from this entry are replicated to all the new entries.
- *
- * The radix tree should be locked against modification during the entire
- * replacement operation.  Lock-free lookups will see RADIX_TREE_RETRY which
- * should prompt RCU walkers to restart the lookup from the root.
- */
-int radix_tree_split(struct radix_tree_root *root, unsigned long index,
-				unsigned order)
-{
-	struct radix_tree_node *parent, *node, *child;
-	void __rcu **slot;
-	unsigned int offset, end;
-	unsigned n, tag, tags = 0;
-	gfp_t gfp = root_gfp_mask(root);
-
-	if (!__radix_tree_lookup(root, index, &parent, &slot))
-		return -ENOENT;
-	if (!parent)
-		return -ENOENT;
-
-	offset = get_slot_offset(parent, slot);
-
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-		if (tag_get(parent, tag, offset))
-			tags |= 1 << tag;
-
-	for (end = offset + 1; end < RADIX_TREE_MAP_SIZE; end++) {
-		if (!xa_is_sibling(rcu_dereference_raw(parent->slots[end])))
-			break;
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-			if (tags & (1 << tag))
-				tag_set(parent, tag, end);
-		/* rcu_assign_pointer ensures tags are set before RETRY */
-		rcu_assign_pointer(parent->slots[end], RADIX_TREE_RETRY);
-	}
-	rcu_assign_pointer(parent->slots[offset], RADIX_TREE_RETRY);
-	parent->nr_values -= (end - offset);
-
-	if (order == parent->shift)
-		return 0;
-	if (order > parent->shift) {
-		while (offset < end)
-			offset += insert_entries(parent, &parent->slots[offset],
-					RADIX_TREE_RETRY, order, true);
-		return 0;
-	}
-
-	node = parent;
-
-	for (;;) {
-		if (node->shift > order) {
-			child = radix_tree_node_alloc(gfp, node, root,
-					node->shift - RADIX_TREE_MAP_SHIFT,
-					offset, 0, 0);
-			if (!child)
-				goto nomem;
-			if (node != parent) {
-				node->count++;
-				rcu_assign_pointer(node->slots[offset],
-							node_to_entry(child));
-				for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-					if (tags & (1 << tag))
-						tag_set(node, tag, offset);
-			}
-
-			node = child;
-			offset = 0;
-			continue;
-		}
-
-		n = insert_entries(node, &node->slots[offset],
-					RADIX_TREE_RETRY, order, false);
-		BUG_ON(n > RADIX_TREE_MAP_SIZE);
-
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-			if (tags & (1 << tag))
-				tag_set(node, tag, offset);
-		offset += n;
-
-		while (offset == RADIX_TREE_MAP_SIZE) {
-			if (node == parent)
-				break;
-			offset = node->offset;
-			child = node;
-			node = node->parent;
-			rcu_assign_pointer(node->slots[offset],
-						node_to_entry(child));
-			offset++;
-		}
-		if ((node == parent) && (offset == end))
-			return 0;
-	}
-
- nomem:
-	/* Shouldn't happen; did user forget to preload? */
-	/* TODO: free all the allocated nodes */
-	WARN_ON(1);
-	return -ENOMEM;
-}
-#endif
-
 static void node_tag_set(struct radix_tree_root *root,
 				struct radix_tree_node *node,
 				unsigned int tag, unsigned int offset)
@@ -1772,48 +1557,6 @@ radix_tree_gang_lookup(const struct radix_tree_root *root, void **results,
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup);
 
-/**
- *	radix_tree_gang_lookup_slot - perform multiple slot lookup on radix tree
- *	@root:		radix tree root
- *	@results:	where the results of the lookup are placed
- *	@indices:	where their indices should be placed (but usually NULL)
- *	@first_index:	start the lookup from this key
- *	@max_items:	place up to this many items at *results
- *
- *	Performs an index-ascending scan of the tree for present items.  Places
- *	their slots at *@results and returns the number of items which were
- *	placed at *@results.
- *
- *	The implementation is naive.
- *
- *	Like radix_tree_gang_lookup as far as RCU and locking goes. Slots must
- *	be dereferenced with radix_tree_deref_slot, and if using only RCU
- *	protection, radix_tree_deref_slot may fail requiring a retry.
- */
-unsigned int
-radix_tree_gang_lookup_slot(const struct radix_tree_root *root,
-			void __rcu ***results, unsigned long *indices,
-			unsigned long first_index, unsigned int max_items)
-{
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-	unsigned int ret = 0;
-
-	if (unlikely(!max_items))
-		return 0;
-
-	radix_tree_for_each_slot(slot, root, &iter, first_index) {
-		results[ret] = slot;
-		if (indices)
-			indices[ret] = iter.index;
-		if (++ret == max_items)
-			break;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
-
 /**
  *	radix_tree_gang_lookup_tag - perform multiple lookup on a radix tree
  *	                             based on a tag
@@ -1890,23 +1633,6 @@ radix_tree_gang_lookup_tag_slot(const struct radix_tree_root *root,
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
@@ -2173,19 +1899,6 @@ static __init unsigned long __maxindex(unsigned int height)
 	return ~0UL >> shift;
 }
 
-static __init void radix_tree_init_maxnodes(void)
-{
-	unsigned long height_to_maxindex[RADIX_TREE_MAX_PATH + 1];
-	unsigned int i, j;
-
-	for (i = 0; i < ARRAY_SIZE(height_to_maxindex); i++)
-		height_to_maxindex[i] = __maxindex(i);
-	for (i = 0; i < ARRAY_SIZE(height_to_maxnodes); i++) {
-		for (j = i; j > 0; j--)
-			height_to_maxnodes[i] += height_to_maxindex[j - 1] + 1;
-	}
-}
-
 static int radix_tree_cpu_dead(unsigned int cpu)
 {
 	struct radix_tree_preload *rtp;
@@ -2215,7 +1928,6 @@ void __init radix_tree_init(void)
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 			radix_tree_node_ctor);
-	radix_tree_init_maxnodes();
 	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
 					NULL, radix_tree_cpu_dead);
 	WARN_ON(ret < 0);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
