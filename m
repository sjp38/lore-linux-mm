Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3C06B02AB
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:19 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so12149245pld.11
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r67-v6si22786913pfr.134.2018.06.11.07.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:17 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 70/72] radix tree: Remove split/join code
Date: Mon, 11 Jun 2018 07:06:37 -0700
Message-Id: <20180611140639.17215-71-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

radix_tree_split and radix_tree_join were never used upstream.  Remove
them; if they're needed in future they will be replaced by XArray
equivalents.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h            |   6 -
 lib/radix-tree.c                      | 171 +-----------------
 tools/testing/radix-tree/benchmark.c  |  91 ----------
 tools/testing/radix-tree/multiorder.c | 247 --------------------------
 4 files changed, 2 insertions(+), 513 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index fc13c4b1afdb..b882d644cc47 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -284,12 +284,6 @@ static inline void radix_tree_preload_end(void)
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
index 001062d41f9f..c472ceeb6a97 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -463,28 +463,6 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
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
 /*
  * The same as function above, but preload number of nodes required to insert
  * (1 << order) continuous naturally-aligned elements.
@@ -1152,8 +1130,8 @@ EXPORT_SYMBOL(radix_tree_replace_slot);
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
@@ -1162,151 +1140,6 @@ void radix_tree_iter_replace(struct radix_tree_root *root,
 	__radix_tree_replace(root, iter->node, slot, item);
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
diff --git a/tools/testing/radix-tree/benchmark.c b/tools/testing/radix-tree/benchmark.c
index 99c40f3ed133..35741b9c2a4a 100644
--- a/tools/testing/radix-tree/benchmark.c
+++ b/tools/testing/radix-tree/benchmark.c
@@ -146,90 +146,6 @@ static void benchmark_size(unsigned long size, unsigned long step, int order)
 	rcu_barrier();
 }
 
-static long long  __benchmark_split(unsigned long index,
-				    int old_order, int new_order)
-{
-	struct timespec start, finish;
-	long long nsec;
-	RADIX_TREE(tree, GFP_ATOMIC);
-
-	item_insert_order(&tree, index, old_order);
-
-	clock_gettime(CLOCK_MONOTONIC, &start);
-	radix_tree_split(&tree, index, new_order);
-	clock_gettime(CLOCK_MONOTONIC, &finish);
-	nsec = (finish.tv_sec - start.tv_sec) * NSEC_PER_SEC +
-	       (finish.tv_nsec - start.tv_nsec);
-
-	item_kill_tree(&tree);
-
-	return nsec;
-
-}
-
-static void benchmark_split(unsigned long size, unsigned long step)
-{
-	int i, j, idx;
-	long long nsec = 0;
-
-
-	for (idx = 0; idx < size; idx += step) {
-		for (i = 3; i < 11; i++) {
-			for (j = 0; j < i; j++) {
-				nsec += __benchmark_split(idx, i, j);
-			}
-		}
-	}
-
-	printv(2, "Size %8ld, step %8ld, split time %10lld ns\n",
-			size, step, nsec);
-
-}
-
-static long long  __benchmark_join(unsigned long index,
-			     unsigned order1, unsigned order2)
-{
-	unsigned long loc;
-	struct timespec start, finish;
-	long long nsec;
-	void *item, *item2 = item_create(index + 1, order1);
-	RADIX_TREE(tree, GFP_KERNEL);
-
-	item_insert_order(&tree, index, order2);
-	item = radix_tree_lookup(&tree, index);
-
-	clock_gettime(CLOCK_MONOTONIC, &start);
-	radix_tree_join(&tree, index + 1, order1, item2);
-	clock_gettime(CLOCK_MONOTONIC, &finish);
-	nsec = (finish.tv_sec - start.tv_sec) * NSEC_PER_SEC +
-		(finish.tv_nsec - start.tv_nsec);
-
-	loc = find_item(&tree, item);
-	if (loc == -1)
-		free(item);
-
-	item_kill_tree(&tree);
-
-	return nsec;
-}
-
-static void benchmark_join(unsigned long step)
-{
-	int i, j, idx;
-	long long nsec = 0;
-
-	for (idx = 0; idx < 1 << 10; idx += step) {
-		for (i = 1; i < 15; i++) {
-			for (j = 0; j < i; j++) {
-				nsec += __benchmark_join(idx, i, j);
-			}
-		}
-	}
-
-	printv(2, "Size %8d, step %8ld, join time %10lld ns\n",
-			1 << 10, step, nsec);
-}
-
 void benchmark(void)
 {
 	unsigned long size[] = {1 << 10, 1 << 20, 0};
@@ -247,11 +163,4 @@ void benchmark(void)
 	for (c = 0; size[c]; c++)
 		for (s = 0; step[s]; s++)
 			benchmark_size(size[c], step[s] << 9, 9);
-
-	for (c = 0; size[c]; c++)
-		for (s = 0; step[s]; s++)
-			benchmark_split(size[c], step[s]);
-
-	for (s = 0; step[s]; s++)
-		benchmark_join(step[s]);
 }
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index fc7d0c4e812a..b26b1e82d626 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -356,251 +356,6 @@ void multiorder_tagged_iteration(void)
 	item_kill_tree(&tree);
 }
 
-/*
- * Basic join checks: make sure we can't find an entry in the tree after
- * a larger entry has replaced it
- */
-static void multiorder_join1(unsigned long index,
-				unsigned order1, unsigned order2)
-{
-	unsigned long loc;
-	void *item, *item2 = item_create(index + 1, order1);
-	RADIX_TREE(tree, GFP_KERNEL);
-
-	item_insert_order(&tree, index, order2);
-	item = radix_tree_lookup(&tree, index);
-	radix_tree_join(&tree, index + 1, order1, item2);
-	loc = find_item(&tree, item);
-	if (loc == -1)
-		free(item);
-	item = radix_tree_lookup(&tree, index + 1);
-	assert(item == item2);
-	item_kill_tree(&tree);
-}
-
-/*
- * Check that the accounting of inline data entries is handled correctly
- * by joining a data entry to a normal pointer.
- */
-static void multiorder_join2(unsigned order1, unsigned order2)
-{
-	RADIX_TREE(tree, GFP_KERNEL);
-	struct radix_tree_node *node;
-	void *item1 = item_create(0, order1);
-	void *item2;
-
-	item_insert_order(&tree, 0, order2);
-	radix_tree_insert(&tree, 1 << order2, xa_mk_value(5));
-	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
-	assert(item2 == xa_mk_value(5));
-	assert(node->nr_values == 1);
-
-	item2 = radix_tree_lookup(&tree, 0);
-	free(item2);
-
-	radix_tree_join(&tree, 0, order1, item1);
-	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
-	assert(item2 == item1);
-	assert(node->nr_values == 0);
-	item_kill_tree(&tree);
-}
-
-/*
- * This test revealed an accounting bug for inline data entries at one point.
- * Nodes were being freed back into the pool with an elevated exception count
- * by radix_tree_join() and then radix_tree_split() was failing to zero the
- * count of value entries.
- */
-static void multiorder_join3(unsigned int order)
-{
-	RADIX_TREE(tree, GFP_KERNEL);
-	struct radix_tree_node *node;
-	void **slot;
-	struct radix_tree_iter iter;
-	unsigned long i;
-
-	for (i = 0; i < (1 << order); i++) {
-		radix_tree_insert(&tree, i, xa_mk_value(5));
-	}
-
-	radix_tree_join(&tree, 0, order, xa_mk_value(7));
-	rcu_barrier();
-
-	radix_tree_split(&tree, 0, 0);
-
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot, xa_mk_value(5));
-	}
-
-	__radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(node->nr_values == node->count);
-
-	item_kill_tree(&tree);
-}
-
-static void multiorder_join(void)
-{
-	int i, j, idx;
-
-	for (idx = 0; idx < 1024; idx = idx * 2 + 3) {
-		for (i = 1; i < 15; i++) {
-			for (j = 0; j < i; j++) {
-				multiorder_join1(idx, i, j);
-			}
-		}
-	}
-
-	for (i = 1; i < 15; i++) {
-		for (j = 0; j < i; j++) {
-			multiorder_join2(i, j);
-		}
-	}
-
-	for (i = 3; i < 10; i++) {
-		multiorder_join3(i);
-	}
-}
-
-static void check_mem(unsigned old_order, unsigned new_order, unsigned alloc)
-{
-	struct radix_tree_preload *rtp = &radix_tree_preloads;
-	if (rtp->nr != 0)
-		printv(2, "split(%u %u) remaining %u\n", old_order, new_order,
-							rtp->nr);
-	/*
-	 * Can't check for equality here as some nodes may have been
-	 * RCU-freed while we ran.  But we should never finish with more
-	 * nodes allocated since they should have all been preloaded.
-	 */
-	if (nr_allocated > alloc)
-		printv(2, "split(%u %u) allocated %u %u\n", old_order, new_order,
-							alloc, nr_allocated);
-}
-
-static void __multiorder_split(int old_order, int new_order)
-{
-	RADIX_TREE(tree, GFP_ATOMIC);
-	void **slot;
-	struct radix_tree_iter iter;
-	unsigned alloc;
-	struct item *item;
-
-	radix_tree_preload(GFP_KERNEL);
-	assert(item_insert_order(&tree, 0, old_order) == 0);
-	radix_tree_preload_end();
-
-	/* Wipe out the preloaded cache or it'll confuse check_mem() */
-	radix_tree_cpu_dead(0);
-
-	item = radix_tree_tag_set(&tree, 0, 2);
-
-	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
-	alloc = nr_allocated;
-	radix_tree_split(&tree, 0, new_order);
-	check_mem(old_order, new_order, alloc);
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot,
-					item_create(iter.index, new_order));
-	}
-	radix_tree_preload_end();
-
-	item_kill_tree(&tree);
-	free(item);
-}
-
-static void __multiorder_split2(int old_order, int new_order)
-{
-	RADIX_TREE(tree, GFP_KERNEL);
-	void **slot;
-	struct radix_tree_iter iter;
-	struct radix_tree_node *node;
-	void *item;
-
-	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
-
-	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == xa_mk_value(5));
-	assert(node->nr_values > 0);
-
-	radix_tree_split(&tree, 0, new_order);
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot,
-					item_create(iter.index, new_order));
-	}
-
-	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item != xa_mk_value(5));
-	assert(node->nr_values == 0);
-
-	item_kill_tree(&tree);
-}
-
-static void __multiorder_split3(int old_order, int new_order)
-{
-	RADIX_TREE(tree, GFP_KERNEL);
-	void **slot;
-	struct radix_tree_iter iter;
-	struct radix_tree_node *node;
-	void *item;
-
-	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
-
-	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == xa_mk_value(5));
-	assert(node->nr_values > 0);
-
-	radix_tree_split(&tree, 0, new_order);
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot, xa_mk_value(7));
-	}
-
-	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == xa_mk_value(7));
-	assert(node->nr_values > 0);
-
-	item_kill_tree(&tree);
-
-	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
-
-	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == xa_mk_value(5));
-	assert(node->nr_values > 0);
-
-	radix_tree_split(&tree, 0, new_order);
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		if (iter.index == (1 << new_order))
-			radix_tree_iter_replace(&tree, &iter, slot,
-						xa_mk_value(7));
-		else
-			radix_tree_iter_replace(&tree, &iter, slot, NULL);
-	}
-
-	item = __radix_tree_lookup(&tree, 1 << new_order, &node, NULL);
-	assert(item == xa_mk_value(7));
-	assert(node->count == node->nr_values);
-	do {
-		node = node->parent;
-		if (!node)
-			break;
-		assert(node->count == 1);
-		assert(node->nr_values == 0);
-	} while (1);
-
-	item_kill_tree(&tree);
-}
-
-static void multiorder_split(void)
-{
-	int i, j;
-
-	for (i = 3; i < 11; i++)
-		for (j = 0; j < i; j++) {
-			__multiorder_split(i, j);
-			__multiorder_split2(i, j);
-			__multiorder_split3(i, j);
-		}
-}
-
 static void multiorder_account(void)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
@@ -702,8 +457,6 @@ void multiorder_checks(void)
 	multiorder_tag_tests();
 	multiorder_iteration();
 	multiorder_tagged_iteration();
-	multiorder_join();
-	multiorder_split();
 	multiorder_account();
 	multiorder_iteration_race();
 
-- 
2.17.1
