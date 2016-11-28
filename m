Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D39A6B02C9
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:32 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c21so252669360ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:32 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id m76si41571665iod.253.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 22/33] radix-tree: Delete radix_tree_range_tag_if_tagged()
Date: Mon, 28 Nov 2016 13:50:26 -0800
Message-Id: <1480369871-5271-23-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is an exceptionally complicated function with just one caller
(tag_pages_for_writeback).  We devote a large portion of the runtime
of the test suite to testing this one function which has one caller.
By introducing the new function radix_tree_iter_tag_set(), we
can eliminate all of the complexity while keeping the performance.
The caller can now use a fairly standard radix_tree_for_each() loop,
and it doesn't need to worry about tricksy things like 'start' wrapping.

The test suite continues to spend a large amount of time investigating
this function, but now it's testing the underlying primitives such as
radix_tree_iter_resume() and the radix_tree_for_each_tagged() iterator
which are also used by other parts of the kernel.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/radix-tree.h             |  74 ++++++++++-----------
 lib/radix-tree.c                       | 117 ++++++---------------------------
 mm/page-writeback.c                    |  28 +++++---
 tools/testing/radix-tree/main.c        |  12 ++--
 tools/testing/radix-tree/multiorder.c  |  13 ++--
 tools/testing/radix-tree/regression2.c |   3 +-
 tools/testing/radix-tree/tag_check.c   |   4 +-
 tools/testing/radix-tree/test.c        |  34 ++++++++++
 tools/testing/radix-tree/test.h        |   3 +
 9 files changed, 125 insertions(+), 163 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index a13d3f7c6c..7a8d251 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -121,6 +121,41 @@ static inline bool radix_tree_empty(struct radix_tree_root *root)
 }
 
 /**
+ * struct radix_tree_iter - radix tree iterator state
+ *
+ * @index:	index of current slot
+ * @next_index:	one beyond the last index for this chunk
+ * @tags:	bit-mask for tag-iterating
+ * @node:	node that contains current slot
+ * @shift:	shift for the node that holds our slots
+ *
+ * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
+ * subinterval of slots contained within one radix tree leaf node.  It is
+ * described by a pointer to its first slot and a struct radix_tree_iter
+ * which holds the chunk's position in the tree and its size.  For tagged
+ * iteration radix_tree_iter also holds the slots' bit-mask for one chosen
+ * radix tree tag.
+ */
+struct radix_tree_iter {
+	unsigned long	index;
+	unsigned long	next_index;
+	unsigned long	tags;
+	struct radix_tree_node *node;
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	unsigned int	shift;
+#endif
+};
+
+static inline unsigned int iter_shift(const struct radix_tree_iter *iter)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	return iter->shift;
+#else
+	return 0;
+#endif
+}
+
+/**
  * Radix-tree synchronization
  *
  * The radix-tree API requires that users provide all synchronisation (with
@@ -283,6 +318,8 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
 int radix_tree_tag_get(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
+void radix_tree_iter_tag_set(struct radix_tree_root *root,
+		const struct radix_tree_iter *iter, unsigned int tag);
 unsigned int
 radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 		unsigned long first_index, unsigned int max_items,
@@ -291,10 +328,6 @@ unsigned int
 radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag);
-unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
-		unsigned long *first_indexp, unsigned long last_index,
-		unsigned long nr_to_tag,
-		unsigned int fromtag, unsigned int totag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 
 static inline void radix_tree_preload_end(void)
@@ -302,39 +335,6 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
-/**
- * struct radix_tree_iter - radix tree iterator state
- *
- * @index:	index of current slot
- * @next_index:	one beyond the last index for this chunk
- * @tags:	bit-mask for tag-iterating
- * @shift:	shift for the node that holds our slots
- *
- * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
- * subinterval of slots contained within one radix tree leaf node.  It is
- * described by a pointer to its first slot and a struct radix_tree_iter
- * which holds the chunk's position in the tree and its size.  For tagged
- * iteration radix_tree_iter also holds the slots' bit-mask for one chosen
- * radix tree tag.
- */
-struct radix_tree_iter {
-	unsigned long	index;
-	unsigned long	next_index;
-	unsigned long	tags;
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	unsigned int	shift;
-#endif
-};
-
-static inline unsigned int iter_shift(struct radix_tree_iter *iter)
-{
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	return iter->shift;
-#else
-	return 0;
-#endif
-}
-
 #define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
 #define RADIX_TREE_ITER_TAGGED		0x0100	/* lookup tagged slots */
 #define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 54ef055..e1ed58b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -218,6 +218,11 @@ radix_tree_find_next_bit(struct radix_tree_node *node, unsigned int tag,
 	return RADIX_TREE_MAP_SIZE;
 }
 
+static unsigned int iter_offset(const struct radix_tree_iter *iter)
+{
+	return (iter->index >> iter_shift(iter)) & RADIX_TREE_MAP_MASK;
+}
+
 /*
  * The maximum index which can be stored in a radix tree
  */
@@ -1014,6 +1019,18 @@ static void node_tag_set(struct radix_tree_root *root,
 }
 
 /**
+ * radix_tree_iter_tag_set - set a tag on the current iterator entry
+ * @root:	radix tree root
+ * @iter:	iterator state
+ * @tag:	tag to set
+ */
+void radix_tree_iter_tag_set(struct radix_tree_root *root,
+			const struct radix_tree_iter *iter, unsigned int tag)
+{
+	node_tag_set(root, iter->node, tag, iter_offset(iter));
+}
+
+/**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
  *	@index:		index key
@@ -1163,6 +1180,7 @@ void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
 		if (node == RADIX_TREE_RETRY)
 			return slot;
 		node = entry_to_node(node);
+		iter->node = node;
 		iter->shift = node->shift;
 
 		if (flags & RADIX_TREE_ITER_TAGGED) {
@@ -1265,6 +1283,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 		iter->index = index;
 		iter->next_index = maxindex + 1;
 		iter->tags = 1;
+		iter->node = NULL;
 		__set_iter_shift(iter, 0);
 		return (void **)&root->rnode;
 	}
@@ -1307,6 +1326,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	/* Update the iterator state */
 	iter->index = (index &~ node_maxindex(node)) | (offset << node->shift);
 	iter->next_index = (index | node_maxindex(node)) + 1;
+	iter->node = node;
 	__set_iter_shift(iter, node->shift);
 
 	if (flags & RADIX_TREE_ITER_TAGGED)
@@ -1317,103 +1337,6 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_next_chunk);
 
 /**
- * radix_tree_range_tag_if_tagged - for each item in given range set given
- *				   tag if item has another tag set
- * @root:		radix tree root
- * @first_indexp:	pointer to a starting index of a range to scan
- * @last_index:		last index of a range to scan
- * @nr_to_tag:		maximum number items to tag
- * @iftag:		tag index to test
- * @settag:		tag index to set if tested tag is set
- *
- * This function scans range of radix tree from first_index to last_index
- * (inclusive).  For each item in the range if iftag is set, the function sets
- * also settag. The function stops either after tagging nr_to_tag items or
- * after reaching last_index.
- *
- * The tags must be set from the leaf level only and propagated back up the
- * path to the root. We must do this so that we resolve the full path before
- * setting any tags on intermediate nodes. If we set tags as we descend, then
- * we can get to the leaf node and find that the index that has the iftag
- * set is outside the range we are scanning. This reults in dangling tags and
- * can lead to problems with later tag operations (e.g. livelocks on lookups).
- *
- * The function returns the number of leaves where the tag was set and sets
- * *first_indexp to the first unscanned index.
- * WARNING! *first_indexp can wrap if last_index is ULONG_MAX. Caller must
- * be prepared to handle that.
- */
-unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
-		unsigned long *first_indexp, unsigned long last_index,
-		unsigned long nr_to_tag,
-		unsigned int iftag, unsigned int settag)
-{
-	struct radix_tree_node *node, *child;
-	unsigned long maxindex;
-	unsigned long tagged = 0;
-	unsigned long index = *first_indexp;
-
-	radix_tree_load_root(root, &child, &maxindex);
-	last_index = min(last_index, maxindex);
-	if (index > last_index)
-		return 0;
-	if (!nr_to_tag)
-		return 0;
-	if (!root_tag_get(root, iftag)) {
-		*first_indexp = last_index + 1;
-		return 0;
-	}
-	if (!radix_tree_is_internal_node(child)) {
-		*first_indexp = last_index + 1;
-		root_tag_set(root, settag);
-		return 1;
-	}
-
-	node = entry_to_node(child);
-
-	for (;;) {
-		unsigned offset = radix_tree_descend(node, &child, index);
-		if (!child)
-			goto next;
-		if (!tag_get(node, iftag, offset))
-			goto next;
-		/* Sibling slots never have tags set on them */
-		if (radix_tree_is_internal_node(child)) {
-			node = entry_to_node(child);
-			continue;
-		}
-
-		tagged++;
-		node_tag_set(root, node, settag, offset);
- next:
-		/* Go to next entry in node */
-		index = ((index >> node->shift) + 1) << node->shift;
-		/* Overflow can happen when last_index is ~0UL... */
-		if (index > last_index || !index)
-			break;
-		offset = (index >> node->shift) & RADIX_TREE_MAP_MASK;
-		while (offset == 0) {
-			/*
-			 * We've fully scanned this node. Go up. Because
-			 * last_index is guaranteed to be in the tree, what
-			 * we do below cannot wander astray.
-			 */
-			node = node->parent;
-			offset = (index >> node->shift) & RADIX_TREE_MAP_MASK;
-		}
-		if (is_sibling_entry(node, node->slots[offset]))
-			goto next;
-		if (tagged >= nr_to_tag)
-			break;
-	}
-
-	*first_indexp = index;
-
-	return tagged;
-}
-EXPORT_SYMBOL(radix_tree_range_tag_if_tagged);
-
-/**
  *	radix_tree_gang_lookup - perform multiple lookup on a radix tree
  *	@root:		radix tree root
  *	@results:	where the results of the lookup are placed
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 52e2f8e..290e8b7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2106,18 +2106,26 @@ void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end)
 {
 #define WRITEBACK_TAG_BATCH 4096
-	unsigned long tagged;
-
-	do {
-		spin_lock_irq(&mapping->tree_lock);
-		tagged = radix_tree_range_tag_if_tagged(&mapping->page_tree,
-				&start, end, WRITEBACK_TAG_BATCH,
-				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
+	unsigned long tagged = 0;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, start,
+							PAGECACHE_TAG_DIRTY) {
+		if (iter.index > end)
+			break;
+		radix_tree_iter_tag_set(&mapping->page_tree, &iter,
+							PAGECACHE_TAG_TOWRITE);
+		tagged++;
+		if ((tagged % WRITEBACK_TAG_BATCH) != 0)
+			continue;
+		slot = radix_tree_iter_resume(slot, &iter);
 		spin_unlock_irq(&mapping->tree_lock);
-		WARN_ON_ONCE(tagged > WRITEBACK_TAG_BATCH);
 		cond_resched();
-		/* We check 'start' to handle wrapping when end == ~0UL */
-	} while (tagged >= WRITEBACK_TAG_BATCH && start);
+		spin_lock_irq(&mapping->tree_lock);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
 }
 EXPORT_SYMBOL(tag_pages_for_writeback);
 
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index a028dae..170175c 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -205,8 +205,7 @@ void copy_tag_check(void)
 	}
 
 //	printf("\ncopying tags...\n");
-	cur = start;
-	tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, ITEMS, 0, 1);
+	tagged = tag_tagged_items(&tree, NULL, start, end, ITEMS, 0, 1);
 
 //	printf("checking copied tags\n");
 	assert(tagged == count);
@@ -214,16 +213,13 @@ void copy_tag_check(void)
 
 	/* Copy tags in several rounds */
 //	printf("\ncopying tags...\n");
-	cur = start;
-	do {
-		tmp = rand() % (count/10+2);
-		tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, tmp, 0, 2);
-	} while (tmp == tagged);
+	tmp = rand() % (count / 10 + 2);
+	tagged = tag_tagged_items(&tree, NULL, start, end, tmp, 0, 2);
+	assert(tagged == count);
 
 //	printf("%lu %lu %lu\n", tagged, tmp, count);
 //	printf("checking copied tags\n");
 	check_copied_tags(&tree, start, end, idx, ITEMS, 0, 2);
-	assert(tagged < tmp);
 	verify_tag_consistency(&tree, 0);
 	verify_tag_consistency(&tree, 1);
 	verify_tag_consistency(&tree, 2);
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index b9be885..86daf23 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -26,7 +26,6 @@ static void __multiorder_tag_test(int index, int order)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
 	int base, err, i;
-	unsigned long first = 0;
 
 	/* our canonical entry */
 	base = index & ~((1 << order) - 1);
@@ -60,7 +59,7 @@ static void __multiorder_tag_test(int index, int order)
 		assert(!radix_tree_tag_get(&tree, i, 1));
 	}
 
-	assert(radix_tree_range_tag_if_tagged(&tree, &first, ~0UL, 10, 0, 1) == 1);
+	assert(tag_tagged_items(&tree, NULL, 0, ~0UL, 10, 0, 1) == 1);
 	assert(radix_tree_tag_clear(&tree, index, 0));
 
 	for_each_index(i, base, order) {
@@ -251,7 +250,6 @@ void multiorder_tagged_iteration(void)
 	RADIX_TREE(tree, GFP_KERNEL);
 	struct radix_tree_iter iter;
 	void **slot;
-	unsigned long first = 0;
 	int i, j;
 
 	printf("Multiorder tagged iteration test\n");
@@ -296,8 +294,8 @@ void multiorder_tagged_iteration(void)
 		}
 	}
 
-	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
-					MT_NUM_ENTRIES, 1, 2);
+	assert(tag_tagged_items(&tree, NULL, 0, ~0UL, TAG_ENTRIES, 1, 2) ==
+				TAG_ENTRIES);
 
 	for (j = 0; j < 256; j++) {
 		int mask, k;
@@ -323,9 +321,8 @@ void multiorder_tagged_iteration(void)
 		}
 	}
 
-	first = 1;
-	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
-					MT_NUM_ENTRIES, 1, 0);
+	assert(tag_tagged_items(&tree, NULL, 1, ~0UL, MT_NUM_ENTRIES * 2, 1, 0)
+			== TAG_ENTRIES);
 	i = 0;
 	radix_tree_for_each_tagged(slot, &tree, &iter, 0, 0) {
 		assert(iter.index == tag_index[i]);
diff --git a/tools/testing/radix-tree/regression2.c b/tools/testing/radix-tree/regression2.c
index 63bf347..a41325d 100644
--- a/tools/testing/radix-tree/regression2.c
+++ b/tools/testing/radix-tree/regression2.c
@@ -50,6 +50,7 @@
 #include <stdio.h>
 
 #include "regression.h"
+#include "test.h"
 
 #define PAGECACHE_TAG_DIRTY     0
 #define PAGECACHE_TAG_WRITEBACK 1
@@ -90,7 +91,7 @@ void regression2_test(void)
 	/* 1. */
 	start = 0;
 	end = max_slots - 2;
-	radix_tree_range_tag_if_tagged(&mt_tree, &start, end, 1,
+	tag_tagged_items(&mt_tree, NULL, start, end, 1,
 				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
 
 	/* 2. */
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index 186f6e4..ed5f87d 100644
--- a/tools/testing/radix-tree/tag_check.c
+++ b/tools/testing/radix-tree/tag_check.c
@@ -23,7 +23,7 @@ __simple_checks(struct radix_tree_root *tree, unsigned long index, int tag)
 	item_tag_set(tree, index, tag);
 	ret = item_tag_get(tree, index, tag);
 	assert(ret != 0);
-	ret = radix_tree_range_tag_if_tagged(tree, &first, ~0UL, 10, tag, !tag);
+	ret = tag_tagged_items(tree, NULL, first, ~0UL, 10, tag, !tag);
 	assert(ret == 1);
 	ret = item_tag_get(tree, index, !tag);
 	assert(ret != 0);
@@ -320,7 +320,7 @@ static void single_check(void)
 	assert(ret == 0);
 	verify_tag_consistency(&tree, 0);
 	verify_tag_consistency(&tree, 1);
-	ret = radix_tree_range_tag_if_tagged(&tree, &first, 10, 10, 0, 1);
+	ret = tag_tagged_items(&tree, NULL, first, 10, 10, 0, 1);
 	assert(ret == 1);
 	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 0, BATCH, 1);
 	assert(ret == 1);
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 88bf57f..e5726e3 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -151,6 +151,40 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 	assert(nfound == 0);
 }
 
+/* Use the same pattern as tag_pages_for_writeback() in mm/page-writeback.c */
+int tag_tagged_items(struct radix_tree_root *root, pthread_mutex_t *lock,
+			unsigned long start, unsigned long end, unsigned batch,
+			unsigned iftag, unsigned thentag)
+{
+	unsigned long tagged = 0;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	if (batch == 0)
+		batch = 1;
+
+	if (lock)
+		pthread_mutex_lock(lock);
+	radix_tree_for_each_tagged(slot, root, &iter, start, iftag) {
+		if (iter.index > end)
+			break;
+		radix_tree_iter_tag_set(root, &iter, thentag);
+		tagged++;
+		if ((tagged % batch) != 0)
+			continue;
+		slot = radix_tree_iter_resume(slot, &iter);
+		if (lock) {
+			pthread_mutex_unlock(lock);
+			rcu_barrier();
+			pthread_mutex_lock(lock);
+		}
+	}
+	if (lock)
+		pthread_mutex_unlock(lock);
+
+	return tagged;
+}
+
 /* Use the same pattern as find_swap_entry() in mm/shmem.c */
 unsigned long find_item(struct radix_tree_root *root, void *item)
 {
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 3d9d1d3..e11e4d2 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -25,6 +25,9 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 			unsigned long nr, int chunk);
 void item_kill_tree(struct radix_tree_root *root);
 
+int tag_tagged_items(struct radix_tree_root *, pthread_mutex_t *,
+			unsigned long start, unsigned long end, unsigned batch,
+			unsigned iftag, unsigned thentag);
 unsigned long find_item(struct radix_tree_root *, void *item);
 
 void tag_check(void);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
