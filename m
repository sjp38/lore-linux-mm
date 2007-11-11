Date: Sun, 11 Nov 2007 09:50:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 3/6] mm: speculative get page
Message-ID: <20071111085004.GF19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

If we can be sure that elevating the page_count on a pagecache
page will pin it, we can speculatively run this operation, and
subsequently check to see if we hit the right page rather than
relying on holding a lock or otherwise pinning a reference to the
page.

This can be done if get_page/put_page behaves consistently
throughout the whole tree (ie. if we "get" the page after it has
been used for something else, we must be able to free it with a
put_page).

Actually, there is a period where the count behaves differently:
when the page is free or if it is a constituent page of a compound
page. We need an atomic_inc_not_zero operation to ensure we don't
try to grab the page in either case.

This patch introduces the core locking protocol to the pagecache
(ie. adds page_cache_get_speculative, and tweaks some update-side
code to make it work).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -12,6 +12,7 @@
 #include <asm/uaccess.h>
 #include <linux/gfp.h>
 #include <linux/bitops.h>
+#include <linux/hardirq.h> /* for in_interrupt() */
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -62,6 +63,96 @@ static inline void mapping_set_gfp_mask(
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
+/*
+ * speculatively take a reference to a page.
+ * If the page is free (_count == 0), then _count is untouched, and 0
+ * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
+ *
+ * This function must be run in the same rcu_read_lock() section as has
+ * been used to lookup the page in the pagecache radix-tree: this allows
+ * allocators to use a synchronize_rcu() to stabilize _count.
+ *
+ * Unless an RCU grace period has passed, the count of all pages coming out
+ * of the allocator must be considered unstable. page_count may return higher
+ * than expected, and put_page must be able to do the right thing when the
+ * page has been finished with (because put_page is what is used to drop an
+ * invalid speculative reference).
+ *
+ * This forms the core of the lockless pagecache locking protocol, where
+ * the lookup-side (eg. find_get_page) has the following pattern:
+ * 1. find page in radix tree
+ * 2. conditionally increment refcount
+ * 3. check the page is still in pagecache (if no, goto 1)
+ *
+ * Remove-side that cares about stability of _count (eg. reclaim) has the
+ * following (with tree_lock held for write):
+ * A. atomically check refcount is correct and set it to 0 (atomic_cmpxchg)
+ * B. remove page from pagecache
+ * C. free the page
+ *
+ * There are 2 critical interleavings that matter:
+ * - 2 runs before A: in this case, A sees elevated refcount and bails out
+ * - A runs before 2: in this case, 2 sees zero refcount and retries;
+ *   subsequently, B will complete and 1 will find no page, causing the
+ *   lookup to return NULL.
+ *
+ * It is possible that between 1 and 2, the page is removed then the exact same
+ * page is inserted into the same position in pagecache. That's OK: the
+ * old find_get_page using tree_lock could equally have run before or after
+ * such a re-insertion, depending on order that locks are granted.
+ *
+ * Lookups racing against pagecache insertion isn't a big problem: either 1
+ * will find the page or it will not. Likewise, the old find_get_page could run
+ * either before the insertion or afterwards, depending on timing.
+ */
+static inline int page_cache_get_speculative(struct page *page)
+{
+	VM_BUG_ON(in_interrupt());
+
+#ifndef CONFIG_SMP
+# ifdef CONFIG_PREEMPT
+	VM_BUG_ON(!in_atomic());
+# endif
+	/*
+	 * Preempt must be disabled here - we rely on rcu_read_lock doing
+	 * this for us.
+	 *
+	 * Pagecache won't be truncated from interrupt context, so if we have
+	 * found a page in the radix tree here, we have pinned its refcount by
+	 * disabling preempt, and hence no need for the "speculative get" that
+	 * SMP requires.
+	 */
+	VM_BUG_ON(page_count(page) == 0);
+	atomic_inc(&page->_count);
+
+#else
+	if (unlikely(!get_page_unless_zero(page))) {
+		/*
+		 * Either the page has been freed, or will be freed.
+		 * In either case, retry here and the caller should
+		 * do the right thing (see comments above).
+		 */
+		return 0;
+	}
+#endif
+	VM_BUG_ON(PageCompound(page) && (struct page *)page_private(page) != page);
+
+	return 1;
+}
+
+static inline int page_freeze_refs(struct page *page, int count)
+{
+	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+}
+
+static inline void page_unfreeze_refs(struct page *page, int count)
+{
+	VM_BUG_ON(page_count(page) != 0);
+	VM_BUG_ON(count == 0);
+
+	atomic_set(&page->_count, count);
+}
+
 #ifdef CONFIG_NUMA
 extern struct page *__page_cache_alloc(gfp_t gfp);
 #else
@@ -155,14 +246,11 @@ extern void FASTCALL(unlock_page(struct 
 
 static inline void __set_page_locked(struct page *page)
 {
-	/* concurrent access would cause data loss with non-atomic bitop */
-	VM_BUG_ON(page_count(page) != 1);
 	__set_bit(PG_locked, &page->flags);
 }
 
 static inline void __clear_page_locked(struct page *page)
 {
-	VM_BUG_ON(page_count(page) != 1);
 	__clear_bit(PG_locked, &page->flags);
 }
 
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -374,12 +374,10 @@ static pageout_t pageout(struct page *pa
 }
 
 /*
- * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
- * someone else has a ref on the page, abort and return 0.  If it was
- * successfully detached, return 1.  Assumes the caller has a single ref on
- * this page.
+ * Save as remove_mapping, but if the page is removed from the mapping, it
+ * gets returned with a refcount of 0.
  */
-int remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping, struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -410,9 +408,9 @@ int remove_mapping(struct address_space 
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
-	if (unlikely(page_count(page) != 2))
+	if (!page_freeze_refs(page, 2))
 		goto cannot_free;
-	smp_rmb();
+	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page)))
 		goto cannot_free;
 
@@ -421,13 +419,12 @@ int remove_mapping(struct address_space 
 		__delete_from_swap_cache(page);
 		write_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
-		__put_page(page);	/* The pagecache ref */
-		return 1;
+	} else {
+		__remove_from_page_cache(page);
+		write_unlock_irq(&mapping->tree_lock);
 	}
 
-	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
-	__put_page(page);
+free_it:
 	return 1;
 
 cannot_free:
@@ -436,6 +433,26 @@ cannot_free:
 }
 
 /*
+ * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
+ * someone else has a ref on the page, abort and return 0.  If it was
+ * successfully detached, return 1.  Assumes the caller has a single ref on
+ * this page.
+ */
+int remove_mapping(struct address_space *mapping, struct page *page)
+{
+	if (__remove_mapping(mapping, page)) {
+		/*
+		 * Unfreezing the refcount with 1 rather than 2 effectively
+		 * drops the pagecache ref for us without requiring another
+		 * atomic operation.
+		 */
+		page_unfreeze_refs(page, 1);
+		return 1;
+	}
+	return 0;
+}
+
+/*
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
@@ -581,11 +598,18 @@ static unsigned long shrink_page_list(st
 		if (PagePrivate(page)) {
 			if (!try_to_release_page(page, sc->gfp_mask))
 				goto activate_locked;
-			if (!mapping && page_count(page) == 1)
-				goto free_it;
+			if (!mapping && page_count(page) == 1) {
+				unlock_page(page);
+				if (put_page_testzero(page))
+					goto free_it;
+				else {
+					nr_reclaimed++;
+					continue;
+				}
+			}
 		}
 
-		if (!mapping || !remove_mapping(mapping, page))
+		if (!mapping || !__remove_mapping(mapping, page))
 			goto keep_locked;
 
 free_it:
@@ -598,8 +622,10 @@ free_it:
 		 */
 		__clear_page_locked(page);
 		nr_reclaimed++;
-		if (!pagevec_add(&freed_pvec, page))
-			__pagevec_release_nonlru(&freed_pvec);
+		if (!pagevec_add(&freed_pvec, page)) {
+			__pagevec_free(&freed_pvec);
+			pagevec_reinit(&freed_pvec);
+		}
 		continue;
 
 activate_locked:
@@ -613,7 +639,7 @@ keep:
 	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
-		__pagevec_release_nonlru(&freed_pvec);
+		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -444,17 +444,23 @@ int add_to_page_cache_locked(struct page
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
+		page_cache_get(page);
+		page->mapping = mapping;
+		page->index = offset;
+
 		write_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
-		if (!error) {
-			page_cache_get(page);
-			page->mapping = mapping;
-			page->index = offset;
+		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
+
+		if (unlikely(error)) {
+			page->mapping = NULL;
+			page_cache_release(page);
+		}
 	}
 	return error;
 }
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -79,18 +79,25 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
+		page_cache_get(page);
+		SetPageSwapCache(page);
+		set_page_private(page, entry.val);
+
 		write_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
-		if (!error) {
-			page_cache_get(page);
-			SetPageSwapCache(page);
-			set_page_private(page, entry.val);
+		if (likely(!error)) {
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
+
+		if (unlikely(error)) {
+			set_page_private(page, 0UL);
+			ClearPageSwapCache(page);
+			page_cache_release(page);
+		}
 	}
 	return error;
 }
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -294,6 +294,7 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
+	int expected_count;
 	void **pslot;
 
 	if (!mapping) {
@@ -308,12 +309,18 @@ static int migrate_page_move_mapping(str
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	if (page_count(page) != 2 + !!PagePrivate(page) ||
+	expected_count = 2 + !!PagePrivate(page);
+	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
 
+	if (!page_freeze_refs(page, expected_count))
+		write_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
 	/*
 	 * Now we know that no one else is looking at the page.
 	 */
@@ -327,6 +334,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 
+	page_unfreeze_refs(page, expected_count);
 	/*
 	 * Drop cache reference from old page.
 	 * We know this isn't the last reference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
