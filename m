From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103254.5564.84494.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 6/9] mm: speculative get page
Date: Thu, 12 Apr 2007 14:45:45 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
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


[Hugh notices that PG_nonewrefs might be dispensed with entirely
 if current set_page_nonewrefs instead atomically save the page count
 and temporarily set it to zero. 

 This is a nice idea, and simplifies find_get_page very much, but
 cannot be applied to all current SetPageNoNewRefs sites. Need to
 verify that add_to_page_cache and add_to_swap_cache can cope
 without it or make do some other way. Also, migration pages with
 PagePrivate set means that the filesystem has a ref on the page,
 so it might muck with page count, which is a big problem.  ]

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -91,6 +91,9 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_nonewrefs		20	/* Block concurrent pagecache lookups
+					 * while testing refcount */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -253,6 +256,11 @@ static inline void SetPageUptodate(struc
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageNoNewRefs(page)	test_bit(PG_nonewrefs, &(page)->flags)
+#define SetPageNoNewRefs(page)	set_bit(PG_nonewrefs, &(page)->flags)
+#define ClearPageNoNewRefs(page) clear_bit(PG_nonewrefs, &(page)->flags)
+#define __ClearPageNoNewRefs(page) __clear_bit(PG_nonewrefs, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
@@ -265,4 +273,25 @@ static inline void set_page_writeback(st
 	test_set_page_writeback(page);
 }
 
+static inline void set_page_nonewrefs(struct page *page)
+{
+	preempt_disable();
+	SetPageNoNewRefs(page);
+	smp_wmb();
+}
+
+static inline void __clear_page_nonewrefs(struct page *page)
+{
+	smp_wmb();
+	__ClearPageNoNewRefs(page);
+	preempt_enable();
+}
+
+static inline void clear_page_nonewrefs(struct page *page)
+{
+	smp_wmb();
+	ClearPageNoNewRefs(page);
+	preempt_enable();
+}
+
 #endif	/* PAGE_FLAGS_H */
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -11,6 +11,8 @@
 #include <linux/compiler.h>
 #include <asm/uaccess.h>
 #include <linux/gfp.h>
+#include <linux/page-flags.h>
+#include <linux/hardirq.h> /* for in_interrupt() */
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -51,6 +53,109 @@ static inline void mapping_set_gfp_mask(
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
+ * After incrementing the refcount, this function spins until PageNoNewRefs
+ * is clear, then a read memory barrier is issued.
+ *
+ * This forms the core of the lockless pagecache locking protocol, where
+ * the lookup-side (eg. find_get_page) has the following pattern:
+ * 1. find page in radix tree
+ * 2. conditionally increment refcount
+ * 3. wait for PageNoNewRefs
+ * 4. check the page is still in pagecache
+ *
+ * Remove-side (that cares about _count, eg. reclaim) has the following:
+ * A. SetPageNoNewRefs
+ * B. check refcount is correct
+ * C. remove page
+ * D. ClearPageNoNewRefs
+ *
+ * There are 2 critical interleavings that matter:
+ * - 2 runs before B: in this case, B sees elevated refcount and bails out
+ * - B runs before 2: in this case, 3 ensures 4 will not run until *after* C
+ *   (after D, even). In which case, 4 will notice C and lookup side can retry
+ *
+ * It is possible that between 1 and 2, the page is removed then the exact same
+ * page is inserted into the same position in pagecache. That's OK: the
+ * old find_get_page using tree_lock could equally have run before or after
+ * the write-side, depending on timing.
+ *
+ * Pagecache insertion isn't a big problem: either 1 will find the page or
+ * it will not. Likewise, the old find_get_page could run either before the
+ * insertion or afterwards, depending on timing.
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
+	if (unlikely(!get_page_unless_zero(page)))
+		return 0; /* page has been freed */
+
+	/*
+	 * Note that get_page_unless_zero provides a memory barrier.
+	 * This is needed to ensure PageNoNewRefs is evaluated after the
+	 * page refcount has been raised. See below comment.
+	 */
+
+	while (unlikely(PageNoNewRefs(page)))
+		cpu_relax();
+
+	/*
+	 * smp_rmb is to ensure the load of page->flags (for PageNoNewRefs())
+	 * is performed before a future load used to ensure the page is
+	 * the correct on (usually: page->mapping and page->index).
+	 *
+	 * Those places that set PageNoNewRefs have the following pattern:
+	 * 	SetPageNoNewRefs(page)
+	 * 	wmb();
+	 * 	if (page_count(page) == X)
+	 * 		remove page from pagecache
+	 * 	wmb();
+	 * 	ClearPageNoNewRefs(page)
+	 *
+	 * If the load was out of order, page->mapping might be loaded before
+	 * the page is removed from pagecache but PageNoNewRefs evaluated
+	 * after the ClearPageNoNewRefs().
+	 */
+	smp_rmb();
+
+#endif
+	VM_BUG_ON(PageCompound(page) && (struct page *)page_private(page) != page);
+
+	return 1;
+}
+
 #ifdef CONFIG_NUMA
 extern struct page *__page_cache_alloc(gfp_t gfp);
 #else
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -390,6 +390,7 @@ int remove_mapping(struct address_space 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
+	set_page_nonewrefs(page);
 	write_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
@@ -427,17 +428,20 @@ int remove_mapping(struct address_space 
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
+	__clear_page_nonewrefs(page);
+	__put_page(page); /* The pagecache ref */
 	return 1;
 
 cannot_free:
 	write_unlock_irq(&mapping->tree_lock);
+	clear_page_nonewrefs(page);
 	return 0;
 }
 
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -440,6 +440,7 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
 	if (error == 0) {
+		set_page_nonewrefs(page);
 		write_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
@@ -451,6 +452,7 @@ int add_to_page_cache(struct page *page,
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&mapping->tree_lock);
+		clear_page_nonewrefs(page);
 		radix_tree_preload_end();
 	}
 	return error;
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -79,6 +79,7 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
+		set_page_nonewrefs(page);
 		write_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
@@ -90,6 +91,7 @@ static int __add_to_swap_cache(struct pa
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&swapper_space.tree_lock);
+		clear_page_nonewrefs(page);
 		radix_tree_preload_end();
 	}
 	return error;
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -303,6 +303,7 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
+	set_page_nonewrefs(page);
 	write_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
@@ -311,6 +312,7 @@ static int migrate_page_move_mapping(str
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
+		clear_page_nonewrefs(page);
 		return -EAGAIN;
 	}
 
@@ -326,6 +328,9 @@ static int migrate_page_move_mapping(str
 #endif
 
 	radix_tree_replace_slot(pslot, newpage);
+	page->mapping = NULL;
+  	write_unlock_irq(&mapping->tree_lock);
+	clear_page_nonewrefs(page);
 
 	/*
 	 * Drop cache reference from old page.
@@ -333,8 +338,6 @@ static int migrate_page_move_mapping(str
 	 */
 	__put_page(page);
 
-	write_unlock_irq(&mapping->tree_lock);
-
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
