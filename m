Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF9BC6B02D2
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:34 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so262124229ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:34 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id x63si19963568itg.104.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 20/33] radix-tree: Improve multiorder iterators
Date: Mon, 28 Nov 2016 13:50:24 -0800
Message-Id: <1480369871-5271-21-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This fixes several interlinked problems with the iterators in the
presence of multiorder entries.

1. radix_tree_iter_next() would only advance by one slot, which would
result in the iterators returning the same entry more than once if there
were sibling entries.

2. radix_tree_next_slot() could return an internal pointer instead of
a user pointer if a tagged multiorder entry was immediately followed by
an entry of lower order.

3. radix_tree_next_slot() expanded to a lot more code than it used to
when multiorder support was compiled in.  And I wasn't comfortable with
entry_to_node() being in a header file.

Fixing radix_tree_iter_next() for the presence of sibling entries
necessarily involves examining the contents of the radix tree, so we now
need to pass 'slot' to radix_tree_iter_next(), and we need to change the
calling convention so it is called *before* dropping the lock which
protects the tree.  Also rename it to radix_tree_iter_resume(), as some
people thought it was necessary to call radix_tree_iter_next() each time
around the loop.

radix_tree_next_slot() becomes closer to how it looked before multiorder
support was introduced.  It only checks to see if the next entry in the
chunk is a sibling entry or a pointer to a node; this should be rare
enough that handling this case out of line is not a performance impact
(and such impact is amortised by the fact that the entry we just
processed was a multiorder entry).  Also, radix_tree_next_slot() used
to force a new chunk lookup for untagged entries, which is more
expensive than the out of line sibling entry skipping.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/tests/btrfs-tests.c               |   2 +-
 include/linux/radix-tree.h                 |  71 +++++++--------
 lib/radix-tree.c                           | 138 +++++++++++++++++++++++++----
 mm/khugepaged.c                            |   7 +-
 mm/shmem.c                                 |   6 +-
 tools/testing/radix-tree/iteration_check.c |  12 +--
 tools/testing/radix-tree/multiorder.c      |  28 ++++--
 tools/testing/radix-tree/regression3.c     |   8 +-
 tools/testing/radix-tree/test.h            |   1 +
 9 files changed, 188 insertions(+), 85 deletions(-)

diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index 73076a0..00ee006 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -162,7 +162,7 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 				slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
-		slot = radix_tree_iter_next(&iter);
+		slot = radix_tree_iter_resume(slot, &iter);
 		spin_unlock(&fs_info->buffer_lock);
 		free_extent_buffer_stale(eb);
 		spin_lock(&fs_info->buffer_lock);
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index d04073a..289d007 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -403,20 +403,17 @@ __radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
 }
 
 /**
- * radix_tree_iter_next - resume iterating when the chunk may be invalid
- * @iter:	iterator state
+ * radix_tree_iter_resume - resume iterating when the chunk may be invalid
+ * @slot: pointer to current slot
+ * @iter: iterator state
+ * Returns: New slot pointer
  *
  * If the iterator needs to release then reacquire a lock, the chunk may
  * have been invalidated by an insertion or deletion.  Call this function
- * to continue the iteration from the next index.
+ * before releasing the lock to continue the iteration from the next index.
  */
-static inline __must_check
-void **radix_tree_iter_next(struct radix_tree_iter *iter)
-{
-	iter->next_index = __radix_tree_iter_add(iter, 1);
-	iter->tags = 0;
-	return NULL;
-}
+void **__must_check radix_tree_iter_resume(void **slot,
+					struct radix_tree_iter *iter);
 
 /**
  * radix_tree_chunk_size - get current chunk size
@@ -430,10 +427,17 @@ radix_tree_chunk_size(struct radix_tree_iter *iter)
 	return (iter->next_index - iter->index) >> iter_shift(iter);
 }
 
-static inline struct radix_tree_node *entry_to_node(void *ptr)
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
+				unsigned flags);
+#else
+/* Can't happen without sibling entries, but the compiler can't tell that */
+static inline void ** __radix_tree_next_slot(void **slot,
+				struct radix_tree_iter *iter, unsigned flags)
 {
-	return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
+	return slot;
 }
+#endif
 
 /**
  * radix_tree_next_slot - find next slot in chunk
@@ -447,7 +451,7 @@ static inline struct radix_tree_node *entry_to_node(void *ptr)
  * For tagged lookup it also eats @iter->tags.
  *
  * There are several cases where 'slot' can be passed in as NULL to this
- * function.  These cases result from the use of radix_tree_iter_next() or
+ * function.  These cases result from the use of radix_tree_iter_resume() or
  * radix_tree_iter_retry().  In these cases we don't end up dereferencing
  * 'slot' because either:
  * a) we are doing tagged iteration and iter->tags has been set to 0, or
@@ -458,51 +462,31 @@ static __always_inline void **
 radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 {
 	if (flags & RADIX_TREE_ITER_TAGGED) {
-		void *canon = slot;
-
 		iter->tags >>= 1;
 		if (unlikely(!iter->tags))
 			return NULL;
-		while (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
-					radix_tree_is_internal_node(slot[1])) {
-			if (entry_to_node(slot[1]) == canon) {
-				iter->tags >>= 1;
-				iter->index = __radix_tree_iter_add(iter, 1);
-				slot++;
-				continue;
-			}
-			iter->next_index = __radix_tree_iter_add(iter, 1);
-			return NULL;
-		}
 		if (likely(iter->tags & 1ul)) {
 			iter->index = __radix_tree_iter_add(iter, 1);
-			return slot + 1;
+			slot++;
+			goto found;
 		}
 		if (!(flags & RADIX_TREE_ITER_CONTIG)) {
 			unsigned offset = __ffs(iter->tags);
 
-			iter->tags >>= offset;
-			iter->index = __radix_tree_iter_add(iter, offset + 1);
-			return slot + offset + 1;
+			iter->tags >>= offset++;
+			iter->index = __radix_tree_iter_add(iter, offset);
+			slot += offset;
+			goto found;
 		}
 	} else {
 		long count = radix_tree_chunk_size(iter);
-		void *canon = slot;
 
 		while (--count > 0) {
 			slot++;
 			iter->index = __radix_tree_iter_add(iter, 1);
 
-			if (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
-			    radix_tree_is_internal_node(*slot)) {
-				if (entry_to_node(*slot) == canon)
-					continue;
-				iter->next_index = iter->index;
-				break;
-			}
-
 			if (likely(*slot))
-				return slot;
+				goto found;
 			if (flags & RADIX_TREE_ITER_CONTIG) {
 				/* forbid switching to the next chunk */
 				iter->next_index = 0;
@@ -511,6 +495,11 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 		}
 	}
 	return NULL;
+
+ found:
+	if (unlikely(radix_tree_is_internal_node(*slot)))
+		return __radix_tree_next_slot(slot, iter, flags);
+	return slot;
 }
 
 /**
@@ -561,6 +550,6 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 	     slot || (slot = radix_tree_next_chunk(root, iter,		\
 			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
 	     slot = radix_tree_next_slot(slot, iter,			\
-				RADIX_TREE_ITER_TAGGED))
+				RADIX_TREE_ITER_TAGGED | tag))
 
 #endif /* _LINUX_RADIX_TREE_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 49b320e..f8fab01 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -68,6 +68,11 @@ struct radix_tree_preload {
 };
 static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
 
+static inline struct radix_tree_node *entry_to_node(void *ptr)
+{
+	return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
+}
+
 static inline void *node_to_entry(void *ptr)
 {
 	return (void *)((unsigned long)ptr | RADIX_TREE_INTERNAL_NODE);
@@ -1103,6 +1108,120 @@ static inline void __set_iter_shift(struct radix_tree_iter *iter,
 #endif
 }
 
+/* Construct iter->tags bit-mask from node->tags[tag] array */
+static void set_iter_tags(struct radix_tree_iter *iter,
+				struct radix_tree_node *node, unsigned offset,
+				unsigned tag)
+{
+	unsigned tag_long = offset / BITS_PER_LONG;
+	unsigned tag_bit  = offset % BITS_PER_LONG;
+
+	iter->tags = node->tags[tag][tag_long] >> tag_bit;
+
+	/* This never happens if RADIX_TREE_TAG_LONGS == 1 */
+	if (tag_long < RADIX_TREE_TAG_LONGS - 1) {
+		/* Pick tags from next element */
+		if (tag_bit)
+			iter->tags |= node->tags[tag][tag_long + 1] <<
+						(BITS_PER_LONG - tag_bit);
+		/* Clip chunk size, here only BITS_PER_LONG tags */
+		iter->next_index = __radix_tree_iter_add(iter, BITS_PER_LONG);
+	}
+}
+
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+static void **skip_siblings(struct radix_tree_node **nodep,
+			void **slot, struct radix_tree_iter *iter)
+{
+	void *sib = node_to_entry(slot - 1);
+
+	while (iter->index < iter->next_index) {
+		*nodep = rcu_dereference_raw(*slot);
+		if (*nodep && *nodep != sib)
+			return slot;
+		slot++;
+		iter->index = __radix_tree_iter_add(iter, 1);
+		iter->tags >>= 1;
+	}
+
+	*nodep = NULL;
+	return NULL;
+}
+
+void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
+					unsigned flags)
+{
+	unsigned tag = flags & RADIX_TREE_ITER_TAG_MASK;
+	struct radix_tree_node *node = rcu_dereference_raw(*slot);
+
+	slot = skip_siblings(&node, slot, iter);
+
+	while (radix_tree_is_internal_node(node)) {
+		unsigned offset;
+		unsigned long next_index;
+
+		if (node == RADIX_TREE_RETRY)
+			return slot;
+		node = entry_to_node(node);
+		iter->shift = node->shift;
+
+		if (flags & RADIX_TREE_ITER_TAGGED) {
+			offset = radix_tree_find_next_bit(node, tag, 0);
+			if (offset == RADIX_TREE_MAP_SIZE)
+				return NULL;
+			slot = &node->slots[offset];
+			iter->index = __radix_tree_iter_add(iter, offset);
+			set_iter_tags(iter, node, offset, tag);
+			node = rcu_dereference_raw(*slot);
+		} else {
+			offset = 0;
+			slot = &node->slots[0];
+			for (;;) {
+				node = rcu_dereference_raw(*slot);
+				if (node)
+					break;
+				slot++;
+				offset++;
+				if (offset == RADIX_TREE_MAP_SIZE)
+					return NULL;
+			}
+			iter->index = __radix_tree_iter_add(iter, offset);
+		}
+		if ((flags & RADIX_TREE_ITER_CONTIG) && (offset > 0))
+			goto none;
+		next_index = (iter->index | shift_maxindex(iter->shift)) + 1;
+		if (next_index < iter->next_index)
+			iter->next_index = next_index;
+	}
+
+	return slot;
+ none:
+	iter->next_index = 0;
+	return NULL;
+}
+EXPORT_SYMBOL(__radix_tree_next_slot);
+#else
+static void **skip_siblings(struct radix_tree_node **nodep,
+			void **slot, struct radix_tree_iter *iter)
+{
+	return slot;
+}
+#endif
+
+void **radix_tree_iter_resume(void **slot, struct radix_tree_iter *iter)
+{
+	struct radix_tree_node *node;
+
+	slot++;
+	iter->index = __radix_tree_iter_add(iter, 1);
+	node = rcu_dereference_raw(*slot);
+	skip_siblings(&node, slot, iter);
+	iter->next_index = iter->index;
+	iter->tags = 0;
+	return NULL;
+}
+EXPORT_SYMBOL(radix_tree_iter_resume);
+
 /**
  * radix_tree_next_chunk - find next chunk of slots for iteration
  *
@@ -1190,23 +1309,8 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	iter->next_index = (index | node_maxindex(node)) + 1;
 	__set_iter_shift(iter, node->shift);
 
-	/* Construct iter->tags bit-mask from node->tags[tag] array */
-	if (flags & RADIX_TREE_ITER_TAGGED) {
-		unsigned tag_long, tag_bit;
-
-		tag_long = offset / BITS_PER_LONG;
-		tag_bit  = offset % BITS_PER_LONG;
-		iter->tags = node->tags[tag][tag_long] >> tag_bit;
-		/* This never happens if RADIX_TREE_TAG_LONGS == 1 */
-		if (tag_long < RADIX_TREE_TAG_LONGS - 1) {
-			/* Pick tags from next element */
-			if (tag_bit)
-				iter->tags |= node->tags[tag][tag_long + 1] <<
-						(BITS_PER_LONG - tag_bit);
-			/* Clip chunk size, here only BITS_PER_LONG tags */
-			iter->next_index = index + BITS_PER_LONG;
-		}
-	}
+	if (flags & RADIX_TREE_ITER_TAGGED)
+		set_iter_tags(iter, node, offset, tag);
 
 	return node->slots + offset;
 }
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7434a63..e32389a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1446,7 +1446,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		radix_tree_replace_slot(&mapping->page_tree, slot,
 				new_page + (index % HPAGE_PMD_NR));
 
-		slot = radix_tree_iter_next(&iter);
+		slot = radix_tree_iter_resume(slot, &iter);
 		index++;
 		continue;
 out_lru:
@@ -1546,7 +1546,6 @@ static void collapse_shmem(struct mm_struct *mm,
 				/* Put holes back where they were */
 				radix_tree_delete(&mapping->page_tree,
 						  iter.index);
-				slot = radix_tree_iter_next(&iter);
 				continue;
 			}
 
@@ -1557,11 +1556,11 @@ static void collapse_shmem(struct mm_struct *mm,
 			page_ref_unfreeze(page, 2);
 			radix_tree_replace_slot(&mapping->page_tree,
 						slot, page);
+			slot = radix_tree_iter_resume(slot, &iter);
 			spin_unlock_irq(&mapping->tree_lock);
 			putback_lru_page(page);
 			unlock_page(page);
 			spin_lock_irq(&mapping->tree_lock);
-			slot = radix_tree_iter_next(&iter);
 		}
 		VM_BUG_ON(nr_none);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -1641,8 +1640,8 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 		present++;
 
 		if (need_resched()) {
+			slot = radix_tree_iter_resume(slot, &iter);
 			cond_resched_rcu();
-			slot = radix_tree_iter_next(&iter);
 		}
 	}
 	rcu_read_unlock();
diff --git a/mm/shmem.c b/mm/shmem.c
index f917b49..b9a785e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -661,8 +661,8 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 			swapped++;
 
 		if (need_resched()) {
+			slot = radix_tree_iter_resume(slot, &iter);
 			cond_resched_rcu();
-			slot = radix_tree_iter_next(&iter);
 		}
 	}
 
@@ -2435,8 +2435,8 @@ static void shmem_tag_pins(struct address_space *mapping)
 		}
 
 		if (need_resched()) {
+			slot = radix_tree_iter_resume(slot, &iter);
 			cond_resched_rcu();
-			slot = radix_tree_iter_next(&iter);
 		}
 	}
 	rcu_read_unlock();
@@ -2505,8 +2505,8 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 			spin_unlock_irq(&mapping->tree_lock);
 continue_resched:
 			if (need_resched()) {
+				slot = radix_tree_iter_resume(slot, &iter);
 				cond_resched_rcu();
-				slot = radix_tree_iter_next(&iter);
 			}
 		}
 		rcu_read_unlock();
diff --git a/tools/testing/radix-tree/iteration_check.c b/tools/testing/radix-tree/iteration_check.c
index df71cb8..f328a66 100644
--- a/tools/testing/radix-tree/iteration_check.c
+++ b/tools/testing/radix-tree/iteration_check.c
@@ -48,8 +48,8 @@ static void *add_entries_fn(void *arg)
 /*
  * Iterate over the tagged entries, doing a radix_tree_iter_retry() as we find
  * things that have been removed and randomly resetting our iteration to the
- * next chunk with radix_tree_iter_next().  Both radix_tree_iter_retry() and
- * radix_tree_iter_next() cause radix_tree_next_slot() to be called with a
+ * next chunk with radix_tree_iter_resume().  Both radix_tree_iter_retry() and
+ * radix_tree_iter_resume() cause radix_tree_next_slot() to be called with a
  * NULL 'slot' variable.
  */
 static void *tagged_iteration_fn(void *arg)
@@ -79,7 +79,7 @@ static void *tagged_iteration_fn(void *arg)
 			}
 
 			if (rand_r(&seeds[0]) % 50 == 0) {
-				slot = radix_tree_iter_next(&iter);
+				slot = radix_tree_iter_resume(slot, &iter);
 				rcu_read_unlock();
 				rcu_barrier();
 				rcu_read_lock();
@@ -96,8 +96,8 @@ static void *tagged_iteration_fn(void *arg)
 /*
  * Iterate over the entries, doing a radix_tree_iter_retry() as we find things
  * that have been removed and randomly resetting our iteration to the next
- * chunk with radix_tree_iter_next().  Both radix_tree_iter_retry() and
- * radix_tree_iter_next() cause radix_tree_next_slot() to be called with a
+ * chunk with radix_tree_iter_resume().  Both radix_tree_iter_retry() and
+ * radix_tree_iter_resume() cause radix_tree_next_slot() to be called with a
  * NULL 'slot' variable.
  */
 static void *untagged_iteration_fn(void *arg)
@@ -127,7 +127,7 @@ static void *untagged_iteration_fn(void *arg)
 			}
 
 			if (rand_r(&seeds[1]) % 50 == 0) {
-				slot = radix_tree_iter_next(&iter);
+				slot = radix_tree_iter_resume(slot, &iter);
 				rcu_read_unlock();
 				rcu_barrier();
 				rcu_read_lock();
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 8d5865c..b9be885 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -231,11 +231,14 @@ void multiorder_iteration(void)
 		radix_tree_for_each_slot(slot, &tree, &iter, j) {
 			int height = order[i] / RADIX_TREE_MAP_SHIFT;
 			int shift = height * RADIX_TREE_MAP_SHIFT;
-			int mask = (1 << order[i]) - 1;
+			unsigned long mask = (1UL << order[i]) - 1;
+			struct item *item = *slot;
 
-			assert(iter.index >= (index[i] &~ mask));
-			assert(iter.index <= (index[i] | mask));
+			assert((iter.index | mask) == (index[i] | mask));
 			assert(iter.shift == shift);
+			assert(!radix_tree_is_internal_node(item));
+			assert((item->index | mask) == (index[i] | mask));
+			assert(item->order == order[i]);
 			i++;
 		}
 	}
@@ -269,7 +272,7 @@ void multiorder_tagged_iteration(void)
 		assert(radix_tree_tag_set(&tree, tag_index[i], 1));
 
 	for (j = 0; j < 256; j++) {
-		int mask, k;
+		int k;
 
 		for (i = 0; i < TAG_ENTRIES; i++) {
 			for (k = i; index[k] < tag_index[i]; k++)
@@ -279,12 +282,16 @@ void multiorder_tagged_iteration(void)
 		}
 
 		radix_tree_for_each_tagged(slot, &tree, &iter, j, 1) {
+			unsigned long mask;
+			struct item *item = *slot;
 			for (k = i; index[k] < tag_index[i]; k++)
 				;
-			mask = (1 << order[k]) - 1;
+			mask = (1UL << order[k]) - 1;
 
-			assert(iter.index >= (tag_index[i] &~ mask));
-			assert(iter.index <= (tag_index[i] | mask));
+			assert((iter.index | mask) == (tag_index[i] | mask));
+			assert(!radix_tree_is_internal_node(item));
+			assert((item->index | mask) == (tag_index[i] | mask));
+			assert(item->order == order[k]);
 			i++;
 		}
 	}
@@ -303,12 +310,15 @@ void multiorder_tagged_iteration(void)
 		}
 
 		radix_tree_for_each_tagged(slot, &tree, &iter, j, 2) {
+			struct item *item = *slot;
 			for (k = i; index[k] < tag_index[i]; k++)
 				;
 			mask = (1 << order[k]) - 1;
 
-			assert(iter.index >= (tag_index[i] &~ mask));
-			assert(iter.index <= (tag_index[i] | mask));
+			assert((iter.index | mask) == (tag_index[i] | mask));
+			assert(!radix_tree_is_internal_node(item));
+			assert((item->index | mask) == (tag_index[i] | mask));
+			assert(item->order == order[k]);
 			i++;
 		}
 	}
diff --git a/tools/testing/radix-tree/regression3.c b/tools/testing/radix-tree/regression3.c
index 1f06ed7..b594841 100644
--- a/tools/testing/radix-tree/regression3.c
+++ b/tools/testing/radix-tree/regression3.c
@@ -5,7 +5,7 @@
  * In following radix_tree_next_slot current chunk size becomes zero.
  * This isn't checked and it tries to dereference null pointer in slot.
  *
- * Helper radix_tree_iter_next reset slot to NULL and next_index to index + 1,
+ * Helper radix_tree_iter_resume reset slot to NULL and next_index to index + 1,
  * for tagger iteraction it also must reset cached tags in iterator to abort
  * next radix_tree_next_slot and go to slow-path into radix_tree_next_chunk.
  *
@@ -88,7 +88,7 @@ void regression3_test(void)
 		printf("slot %ld %p\n", iter.index, *slot);
 		if (!iter.index) {
 			printf("next at %ld\n", iter.index);
-			slot = radix_tree_iter_next(&iter);
+			slot = radix_tree_iter_resume(slot, &iter);
 		}
 	}
 
@@ -96,7 +96,7 @@ void regression3_test(void)
 		printf("contig %ld %p\n", iter.index, *slot);
 		if (!iter.index) {
 			printf("next at %ld\n", iter.index);
-			slot = radix_tree_iter_next(&iter);
+			slot = radix_tree_iter_resume(slot, &iter);
 		}
 	}
 
@@ -106,7 +106,7 @@ void regression3_test(void)
 		printf("tagged %ld %p\n", iter.index, *slot);
 		if (!iter.index) {
 			printf("next at %ld\n", iter.index);
-			slot = radix_tree_iter_next(&iter);
+			slot = radix_tree_iter_resume(slot, &iter);
 		}
 	}
 
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 423c528..617416e 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -41,6 +41,7 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
 extern int nr_allocated;
 
 /* Normally private parts of lib/radix-tree.c */
+struct radix_tree_node *entry_to_node(void *ptr);
 void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
