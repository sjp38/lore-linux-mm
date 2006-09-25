Date: Mon, 25 Sep 2006 13:47:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/9] mm: speculative get page
Message-ID: <20060925114739.GA31148@wotan.suse.de>
References: <20060922172042.22370.62513.sendpatchset@linux.site> <20060922172110.22370.33715.sendpatchset@linux.site> <Pine.LNX.4.64.0609241802400.7935@blonde.wat.veritas.com> <4517382E.8010308@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4517382E.8010308@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2006 at 12:00:14PM +1000, Nick Piggin wrote:
> Hugh Dickins wrote:
> 
> >On Fri, 22 Sep 2006, Nick Piggin wrote:
> >
> >>Index: linux-2.6/include/linux/page-flags.h
> >>===================================================================
> >>--- linux-2.6.orig/include/linux/page-flags.h
> >>+++ linux-2.6/include/linux/page-flags.h
> >>@@ -86,6 +86,8 @@
> >>#define PG_nosave_free		18	/* Free, should not be 
> >>written */
> >>#define PG_buddy		19	/* Page is free, on buddy lists */
> >>
> >>+#define PG_nonewrefs		20	/* Block concurrent 
> >>pagecache lookups
> >>+					 * while testing refcount */
> >>
> >
> >Something I didn't get around to mentioning last time: I could well
> >be mistaken, but it seemed that you could get along without all the
> >PageNoNewRefs stuff, at cost of using something (too expensive?)
> >like atomic_cmpxchg(&page->_count, 2, 0) in remove_mapping() and
> >migrate_page_move_mapping(); compensated by simplification at the
> >other end in page_cache_get_speculative(), which is already
> >expected to be the hotter path.
> >
> 
> Wow. That's amazing, why didn't I think of that? ;) Now that
> we have a PG_buddy, this is going to work nicely.

OK, so one reason I think is that I was worried about adding pages
to swap/page cache that are not "new" pages.

In which case, I didn't want to be messing around with things like
page->mapping or page flags if the page wasn't actually able to be
added to the cache.

Swapcache is OK, because PageSwapCache seems to be always serialised
by PG_lock. With pagecache, this only happens via shmem but if you
think that's OK, then fine by me.

The result (appended) is incredibly fast on my P4, where it takes 
about 70% of the time required by the nonewrefs version to perform
a find_get_page. The cmpxchg takes only 5ns longer than lock ; inc
so I'd say this would have to be about as fast as you could
implement a find_get_page ;)

This is what it looks like (after a small patch to ensure
__add_to_swap_cache is always called with PG_locked, so it does
not need to unconditionally set PG_locked). What do you think?
Things are still open coded ATM, but I'll clean that up.

--
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -11,6 +11,7 @@
 #include <linux/compiler.h>
 #include <asm/uaccess.h>
 #include <linux/gfp.h>
+#include <linux/hardirq.h> /* for in_interrupt() */
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -51,6 +52,83 @@ static inline void mapping_set_gfp_mask(
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
 #ifdef CONFIG_NUMA
 extern struct page *page_cache_alloc(struct address_space *x);
 extern struct page *page_cache_alloc_cold(struct address_space *x);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -387,9 +387,9 @@ int remove_mapping(struct address_space 
 	 * PageDirty _after_ making sure that the page is freeable and
 	 * not in use by anybody. 	(pagecache + us == 2)
 	 */
-	if (unlikely(page_count(page) != 2))
+	if (unlikely(atomic_cmpxchg(&page->_count, 0, 2) != 2))
 		goto cannot_free;
-	smp_rmb();
+	/* note: atomic_cmpxchg provides a barrier */
 	if (unlikely(PageDirty(page)))
 		goto cannot_free;
 
@@ -398,13 +398,14 @@ int remove_mapping(struct address_space 
 		__delete_from_swap_cache(page);
 		write_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
-		__put_page(page);	/* The pagecache ref */
-		return 1;
+		goto free_it;
 	}
 
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
-	__put_page(page);
+
+free_it:
+	set_page_count(page, 1); /* Effectively drop the pagecache ref */
 	return 1;
 
 cannot_free:
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -440,18 +440,25 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
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
 		}
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
+
+		if (unlikely(error)) {
+			page->mapping = NULL;
+			ClearPageLocked(page);
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
 	BUG_ON(!PageLocked(page));
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
@@ -308,12 +309,19 @@ static int migrate_page_move_mapping(str
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	if (page_count(page) != 2 + !!PagePrivate(page) ||
+	expected_count = 2 + !!PagePrivate(page);
+	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
 
+	if (unlikely(atomic_cmpxchg(&page->_count, 0, expected_count)
+							!= expected_count) {
+		write_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
 	/*
 	 * Now we know that no one else is looking at the page.
 	 */
@@ -326,14 +334,15 @@ static int migrate_page_move_mapping(str
 #endif
 
 	radix_tree_replace_slot(pslot, newpage);
+	page->mapping = NULL;
+
+  	write_unlock_irq(&mapping->tree_lock);
 
 	/*
-	 * Drop cache reference from old page.
+	 * Effectively drop the pagecache reference from old page.
 	 * We know this isn't the last reference.
 	 */
-	__put_page(page);
-
-	write_unlock_irq(&mapping->tree_lock);
+	set_page_count(page, expected_count-1);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
