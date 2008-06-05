Message-Id: <20080605094825.699347000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
Date: Thu, 05 Jun 2008 19:43:03 +1000
From: npiggin@suse.de
Subject: [patch 3/7] mm: speculative page references
Content-Disposition: inline; filename=mm-speculative-get_page-hugh.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

If we can be sure that elevating the page_count on a pagecache page will pin
it, we can speculatively run this operation, and subsequently check to see if
we hit the right page rather than relying on holding a lock or otherwise
pinning a reference to the page.

This can be done if get_page/put_page behaves consistently throughout the whole
tree (ie. if we "get" the page after it has been used for something else, we
must be able to free it with a put_page).

Actually, there is a period where the count behaves differently: when the page
is free or if it is a constituent page of a compound page. We need an
atomic_inc_not_zero operation to ensure we don't try to grab the page in either
case.

This patch introduces the core locking protocol to the pagecache (ie. adds
page_cache_get_speculative, and tweaks some update-side code to make it work).

Thanks to Hugh for pointing out an improvement to the algorithm setting
page_count to zero when we have control of all references, in order to hold off
speculative getters.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
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
@@ -62,6 +63,98 @@ static inline void mapping_set_gfp_mask(
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
+/*
+ * speculatively take a reference to a page.
+ * If the page is free (_count == 0), then _count is untouched, and 0
+ * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
+ *
+ * This function must be called inside the same rcu_read_lock() section as has
+ * been used to lookup the page in the pagecache radix-tree (or page table):
+ * this allows allocators to use a synchronize_rcu() to stabilize _count.
+ *
+ * Unless an RCU grace period has passed, the count of all pages coming out
+ * of the allocator must be considered unstable. page_count may return higher
+ * than expected, and put_page must be able to do the right thing when the
+ * page has been finished with, no matter what it is subsequently allocated
+ * for (because put_page is what is used here to drop an invalid speculative
+ * reference).
+ *
+ * This is the interesting part of the lockless pagecache (and lockless
+ * get_user_pages) locking protocol, where the lookup-side (eg. find_get_page)
+ * has the following pattern:
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
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -390,12 +390,10 @@ static pageout_t pageout(struct page *pa
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
@@ -426,9 +424,9 @@ int remove_mapping(struct address_space 
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
 
@@ -437,13 +435,11 @@ int remove_mapping(struct address_space 
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
 	return 1;
 
 cannot_free:
@@ -452,6 +448,26 @@ cannot_free:
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
@@ -597,18 +613,27 @@ static unsigned long shrink_page_list(st
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
 		unlock_page(page);
 		nr_reclaimed++;
-		if (!pagevec_add(&freed_pvec, page))
-			__pagevec_release_nonlru(&freed_pvec);
+		if (!pagevec_add(&freed_pvec, page)) {
+			__pagevec_free(&freed_pvec);
+			pagevec_reinit(&freed_pvec);
+		}
 		continue;
 
 activate_locked:
@@ -622,7 +647,7 @@ keep:
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
@@ -466,17 +466,22 @@ int add_to_page_cache(struct page *page,
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
+		page_cache_get(page);
+		SetPageLocked(page);
+		page->mapping = mapping;
+		page->index = offset;
+
 		write_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
-		if (!error) {
-			page_cache_get(page);
-			SetPageLocked(page);
-			page->mapping = mapping;
-			page->index = offset;
+		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
-		} else
+		} else {
+			page->mapping = NULL;
+			ClearPageLocked(page);
 			mem_cgroup_uncharge_page(page);
+			page_cache_release(page);
+		}
 
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -76,19 +76,26 @@ int add_to_swap_cache(struct page *page,
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
 			INC_CACHE_INFO(add_total);
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
@@ -304,6 +304,7 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
+	int expected_count;
 	void **pslot;
 
 	if (!mapping) {
@@ -318,12 +319,18 @@ static int migrate_page_move_mapping(str
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	if (page_count(page) != 2 + !!PagePrivate(page) ||
+	expected_count = 2 + !!PagePrivate(page);
+	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
 
+	if (!page_freeze_refs(page, expected_count)) {
+		write_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
 	/*
 	 * Now we know that no one else is looking at the page.
 	 */
@@ -337,6 +344,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 
+	page_unfreeze_refs(page, expected_count);
 	/*
 	 * Drop cache reference from old page.
 	 * We know this isn't the last reference.
Index: linux-2.6/drivers/net/cassini.c
===================================================================
--- linux-2.6.orig/drivers/net/cassini.c
+++ linux-2.6/drivers/net/cassini.c
@@ -576,6 +576,18 @@ static void cas_spare_recover(struct cas
 	list_for_each_safe(elem, tmp, &list) {
 		cas_page_t *page = list_entry(elem, cas_page_t, list);
 
+		/*
+		 * With the lockless pagecache, cassini buffering scheme gets
+		 * slightly less accurate: we might find that a page has an
+		 * elevated reference count here, due to a speculative ref,
+		 * and skip it as in-use. Ideally we would be able to reclaim
+		 * it. However this would be such a rare case, it doesn't
+		 * matter too much as we should pick it up the next time round.
+		 *
+		 * Importantly, if we find that the page has a refcount of 1
+		 * here (our refcount), then we know it is definitely not inuse
+		 * so we can reuse it.
+		 */
 		if (page_count(page->buffer) > 1)
 			continue;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
