Date: Wed, 2 Jan 2008 18:17:26 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 00/19] VM pageout scalability - one big patch
Message-ID: <20080102181726.0a9417e7@bree.surriel.com>
In-Reply-To: <20080102224144.885671949@redhat.com>
References: <20080102224144.885671949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernelporg
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

By popular request, here are all the VM pageout scalability patches rolled
up into one big patch.

Signed-off-by: Rik van Riel <riel@redhat.com>

 drivers/base/node.c        |   65 +-
 drivers/block/brd.c        |   13 
 fs/cifs/file.c             |    4 
 fs/nfs/dir.c               |    2 
 fs/ntfs/file.c             |    4 
 fs/proc/proc_misc.c        |   78 +-
 fs/ramfs/file-nommu.c      |    4 
 fs/ramfs/inode.c           |    1 
 include/linux/memcontrol.h |   19 
 include/linux/migrate.h    |    3 
 include/linux/mm_inline.h  |  136 ++++-
 include/linux/mmzone.h     |   66 ++
 include/linux/page-flags.h |   43 +
 include/linux/pagemap.h    |   28 +
 include/linux/pagevec.h    |   22 
 include/linux/rmap.h       |   12 
 include/linux/swap.h       |   44 +
 include/linux/vmstat.h     |   10 
 kernel/sysctl.c            |   10 
 mm/Kconfig                 |   24 
 mm/filemap.c               |   19 
 mm/internal.h              |   57 ++
 mm/memcontrol.c            |  170 ++----
 mm/memory.c                |   13 
 mm/mempolicy.c             |   12 
 mm/migrate.c               |   87 +--
 mm/mlock.c                 |  290 ++++++++++
 mm/mmap.c                  |   42 +
 mm/mremap.c                |    8 
 mm/page-writeback.c        |    8 
 mm/page_alloc.c            |  110 +++-
 mm/readahead.c             |    2 
 mm/rmap.c                  |  160 +++++
 mm/shmem.c                 |    8 
 mm/swap.c                  |  249 ++++++++-
 mm/swap_state.c            |    6 
 mm/truncate.c              |    4 
 mm/vmscan.c                |  939 ++++++++++++++++++++++++-----------
 mm/vmstat.c                |   25 
 39 files changed, 2171 insertions(+), 626 deletions(-)

Index: linux-2.6.24-rc6-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/migrate.h	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/migrate.h	2008-01-02 12:37:14.000000000 -0500
@@ -25,7 +25,6 @@ static inline int vma_migratable(struct 
 	return 1;
 }
 
-extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -42,8 +41,6 @@ extern int migrate_vmas(struct mm_struct
 static inline int vma_migratable(struct vm_area_struct *vma)
 					{ return 0; }
 
-static inline int isolate_lru_page(struct page *p, struct list_head *list)
-					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private) { return -ENOSYS; }
Index: linux-2.6.24-rc6-mm1/mm/internal.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/internal.h	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/internal.h	2008-01-02 17:08:17.000000000 -0500
@@ -34,9 +34,66 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+extern int isolate_lru_page(struct page *page);
+
 extern void __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * in mm/vmscan.c -- currently only used for NORECLAIM_MLOCK
+ */
+extern void putback_lru_page(struct page *page);
+
+/*
+ * called only for new pages in fault path
+ */
+extern int is_mlocked_vma(struct vm_area_struct *, struct page *);
+
+/*
+ * must be called with vma's mmap_sem held for read, and page locked.
+ */
+extern void mlock_vma_page(struct page *page);
+
+extern int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock);
+
+/*
+ * mlock all pages in this vma range.  For mmap()/mremap()/...
+ */
+extern int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+
+/*
+ * munlock range of pages.   For munmap() and exit().
+ * Always called to operate on a full vma that is being unmapped.
+ */
+static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+// TODO:  verify my assumption.  Should we just drop the start/end args?
+	VM_BUG_ON(start != vma->vm_start || end != vma->vm_end);
+
+	vma->vm_flags &= ~VM_LOCKED;    /* try_to_unlock() needs this */
+	return __mlock_vma_pages_range(vma, start, end, 0);
+}
+
+extern void clear_page_mlock(struct page *page);
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
+{
+	return 0;
+}
+static inline void clear_page_mlock(struct page *page) { }
+static inline void mlock_vma_page(struct page *page) { }
+static inline int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { return 0; }
+static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { return 0; }
+
+#endif /* CONFIG_NORECLAIM_MLOCK */
+
 /*
  * function for dealing with page's order in buddy system.
  * zone->lock is already acquired when we use these.
Index: linux-2.6.24-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/migrate.c	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/migrate.c	2008-01-02 17:08:17.000000000 -0500
@@ -36,36 +36,6 @@
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
- * Isolate one page from the LRU lists. If successful put it onto
- * the indicated list with elevated page count.
- *
- * Result:
- *  -EBUSY: page not on LRU list
- *  0: page removed from LRU list and added to the specified list.
- */
-int isolate_lru_page(struct page *page, struct list_head *pagelist)
-{
-	int ret = -EBUSY;
-
-	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
-
-		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page) && get_page_unless_zero(page)) {
-			ret = 0;
-			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-			list_add_tail(&page->lru, pagelist);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-	}
-	return ret;
-}
-
-/*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page().
  */
@@ -82,17 +52,33 @@ int migrate_prep(void)
 	return 0;
 }
 
+/*
+ * move_to_lru() - place @page onto appropriate lru list
+ * based on preserved page flags:  active, noreclaim, none
+ */
 static inline void move_to_lru(struct page *page)
 {
-	if (PageActive(page)) {
+	if (PageNoreclaim(page)) {
+		VM_BUG_ON(PageActive(page));
+		ClearPageNoreclaim(page);
+		lru_cache_add_noreclaim(page);
+	} else if (PageActive(page)) {
+		VM_BUG_ON(PageNoreclaim(page));	/* race ? */
 		/*
 		 * lru_cache_add_active checks that
 		 * the PG_active bit is off.
 		 */
 		ClearPageActive(page);
-		lru_cache_add_active(page);
+		if (page_file_cache(page))
+			lru_cache_add_active_file(page);
+		else
+			lru_cache_add_active_anon(page);
 	} else {
-		lru_cache_add(page);
+		VM_BUG_ON(PageNoreclaim(page));	/* race ? */
+		if (page_file_cache(page))
+			lru_cache_add_file(page);
+		else
+			lru_cache_add_anon(page);
 	}
 	put_page(page);
 }
@@ -365,8 +351,11 @@ static void migrate_page_copy(struct pag
 		SetPageReferenced(newpage);
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
-	if (PageActive(page))
+	if (TestClearPageActive(page)) {
+		VM_BUG_ON(PageNoreclaim(page));
 		SetPageActive(newpage);
+	} else if (TestClearPageNoreclaim(page))
+		SetPageNoreclaim(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
@@ -377,10 +366,19 @@ static void migrate_page_copy(struct pag
 		set_page_dirty(newpage);
  	}
 
+	if (TestClearPageMlocked(page)) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		__dec_zone_page_state(page, NR_MLOCK);
+		SetPageMlocked(newpage);
+		__inc_zone_page_state(newpage, NR_MLOCK);
+		local_irq_restore(flags);
+	}
+
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
 #endif
-	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
@@ -576,6 +574,8 @@ static int move_to_new_page(struct page 
 	/* Prepare mapping for the new page.*/
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
+	if (PageSwapBacked(page))
+		SetPageSwapBacked(newpage);
 
 	mapping = page_mapping(page);
 	if (!mapping)
@@ -853,14 +853,17 @@ static int do_move_pages(struct mm_struc
 				!migrate_all)
 			goto put_and_set;
 
-		err = isolate_lru_page(page, &pagelist);
+		err = isolate_lru_page(page);
+		if (err) {
 put_and_set:
-		/*
-		 * Either remove the duplicate refcount from
-		 * isolate_lru_page() or drop the page ref if it was
-		 * not isolated.
-		 */
-		put_page(page);
+			/*
+			 * Either remove the duplicate refcount from
+			 * isolate_lru_page() or drop the page ref if it was
+			 * not isolated.
+			 */
+			put_page(page);
+		} else
+			list_add_tail(&page->lru, &pagelist);
 set_status:
 		pp->status = err;
 	}
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 17:08:17.000000000 -0500
@@ -39,6 +39,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
+#include <linux/sysctl.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -71,6 +72,9 @@ struct scan_control {
 
 	int order;
 
+	/* The number of pages moved to the active list this pass. */
+	int activated;
+
 	/*
 	 * Pages that have (or should have) IO pending.  If we run into
 	 * a lot of these, we're better off waiting a little for IO to
@@ -85,7 +89,7 @@ struct scan_control {
 	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
 			unsigned long *scanned, int order, int mode,
 			struct zone *z, struct mem_cgroup *mem_cont,
-			int active);
+			int active, int file);
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -243,27 +247,6 @@ unsigned long shrink_slab(unsigned long 
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -498,6 +481,11 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (!page_reclaimable(page, NULL)) {
+			SetPageNoreclaim(page);
+			goto keep_locked;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -527,8 +515,7 @@ static unsigned long shrink_page_list(st
 
 		referenced = page_referenced(page, 1, sc->mem_cgroup);
 		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page))
+		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -553,14 +540,16 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				ClearPageActive(page);
+				SetPageNoreclaim(page);
+				goto keep_locked;	/* to noreclaim list */
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
-				goto keep_locked;
 			if (!may_enter_fs) {
 				sc->nr_io_pages++;
 				goto keep_locked;
@@ -603,7 +592,7 @@ static unsigned long shrink_page_list(st
 		 * possible for a page to have PageDirty set, but it is actually
 		 * clean (all its buffers are clean).  This happens if the
 		 * buffers were written out directly, with submit_bh(). ext3
-		 * will do this, as well as the blockdev mapping. 
+		 * will do this, as well as the blockdev mapping.
 		 * try_to_release_page() will discover that cleanness and will
 		 * drop the buffers and mark the page clean - it can be freed.
 		 *
@@ -632,6 +621,10 @@ free_it:
 		continue;
 
 activate_locked:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && vm_swap_full())
+			remove_exclusive_swap_page(page);
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -644,6 +637,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	sc->activated = pgactivate;
 	return nr_reclaimed;
 }
 
@@ -662,7 +656,7 @@ keep:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode)
+int __isolate_lru_page(struct page *page, int mode, int file)
 {
 	int ret = -EINVAL;
 
@@ -678,6 +672,17 @@ int __isolate_lru_page(struct page *page
 	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
 		return ret;
 
+	if (mode != ISOLATE_BOTH && (!page_file_cache(page) != !file))
+		return ret;
+
+	/*
+	 * Non-reclaimable pages shouldn't make it onto either the active
+	 * nor the inactive list. However, when doing lumpy reclaim of
+	 * higher order pages we can still run into them.
+	 */
+	if (PageNoreclaim(page))
+		return ret;
+
 	ret = -EBUSY;
 	if (likely(get_page_unless_zero(page))) {
 		/*
@@ -708,12 +713,13 @@ int __isolate_lru_page(struct page *page
  * @scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
  * @mode:	One of the LRU isolation modes
+ * @file:	True [1] if isolating file [!anon] pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode)
+		unsigned long *scanned, int order, int mode, int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long scan;
@@ -730,7 +736,7 @@ static unsigned long isolate_lru_pages(u
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode)) {
+		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
 			list_move(&page->lru, dst);
 			nr_taken++;
@@ -773,10 +779,11 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			cursor_page = pfn_to_page(pfn);
+
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			switch (__isolate_lru_page(cursor_page, mode)) {
+			switch (__isolate_lru_page(cursor_page, mode, file)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
@@ -787,7 +794,7 @@ static unsigned long isolate_lru_pages(u
 				/* else it is being freed elsewhere */
 				list_move(&cursor_page->lru, src);
 			default:
-				break;
+				break;	/* ! on LRU or wrong list */
 			}
 		}
 	}
@@ -801,40 +808,133 @@ static unsigned long isolate_pages_globa
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
+	int lru = LRU_BASE;
 	if (active)
-		return isolate_lru_pages(nr, &z->active_list, dst,
-						scanned, order, mode);
-	else
-		return isolate_lru_pages(nr, &z->inactive_list, dst,
-						scanned, order, mode);
+		lru += LRU_ACTIVE;
+	if (file)
+		lru += LRU_FILE;
+	return isolate_lru_pages(nr, &z->list[lru], dst, scanned, order,
+								mode, !!file);
 }
 
 /*
  * clear_active_flags() is a helper for shrink_active_list(), clearing
  * any active bits from the pages in the list.
  */
-static unsigned long clear_active_flags(struct list_head *page_list)
+static unsigned long clear_active_flags(struct list_head *page_list,
+					unsigned int *count)
 {
 	int nr_active = 0;
+	int lru;
 	struct page *page;
 
-	list_for_each_entry(page, page_list, lru)
+	list_for_each_entry(page, page_list, lru) {
+		lru = page_file_cache(page);
 		if (PageActive(page)) {
+			lru += LRU_ACTIVE;
 			ClearPageActive(page);
 			nr_active++;
 		}
+		count[lru]++;
+	}
 
 	return nr_active;
 }
 
+/**
+ * isolate_lru_page(@page)
+ *
+ * Isolate one @page from the LRU lists. Must be called with an elevated
+ * refcount on the page, which is a fundamentnal difference from
+ * isolate_lru_pages (which is called without a stable reference).
+ *
+ * The returned page will have the PageLru() cleared, and the PageActive or
+ * PageNoreclaim will be set, if it was found on the active or noreclaim list,
+ * respectively. This flag generally will need to be cleared by the caller
+ * before letting the page go.
+ *
+ * The vmstat page counts corresponding to the list on which the page was
+ * found will be decremented.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ *
+ * Returns:
+ *  -EBUSY: page not on LRU list
+ *  0: page removed from LRU list.
+ */
+int isolate_lru_page(struct page *page)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page) && get_page_unless_zero(page)) {
+			int lru = LRU_BASE;
+			ret = 0;
+			ClearPageLRU(page);
+
+			/* Calculate the LRU list for normal pages ... */
+			lru += page_file_cache(page) + !!PageActive(page);
+
+			/* ... except NoReclaim, which has its own list. */
+			if (PageNoreclaim(page))
+				lru = LRU_NORECLAIM;
+
+			del_page_from_lru_list(zone, page, lru);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	return ret;
+}
+
+#ifdef CONFIG_NORECLAIM_MLOCK
+/**
+ * putback_lru_page(@page)
+ *
+ * Add previously isolated @page to appropriate LRU list.
+ * Page may still be non-reclaimable for other reasons.
+ *
+ * The vmstat page counts corresponding to the list on which the page
+ * will be placed will be incremented.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ */
+void putback_lru_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	int lru = LRU_INACTIVE_ANON;
+
+	VM_BUG_ON(PageLRU(page));
+
+	ClearPageNoreclaim(page);
+	ClearPageActive(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	if (page_reclaimable(page, NULL)) {
+		lru += page_file_cache(page);
+	} else {
+		lru = LRU_NORECLAIM;
+		SetPageNoreclaim(page);
+	}
+
+	SetPageLRU(page);
+	add_page_to_lru_list(zone, page, lru);
+	put_page(page);		/* drop ref from isolate */
+
+	spin_unlock_irq(&zone->lru_lock);
+}
+#endif
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+			struct zone *zone, struct scan_control *sc, int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -851,18 +951,25 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 		unsigned long nr_active;
+		unsigned int count[NR_LRU_LISTS] = { 0, };
+		int mode = (sc->order > PAGE_ALLOC_COSTLY_ORDER) ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
-			     &page_list, &nr_scan, sc->order,
-			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
-					     ISOLATE_BOTH : ISOLATE_INACTIVE,
-				zone, sc->mem_cgroup, 0);
-		nr_active = clear_active_flags(&page_list);
+			     &page_list, &nr_scan, sc->order, mode,
+				zone, sc->mem_cgroup, 0, file);
+		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 
-		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
-		__mod_zone_page_state(zone, NR_INACTIVE,
-						-(nr_taken - nr_active));
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+						-count[LRU_ACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+						-count[LRU_INACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+						-count[LRU_ACTIVE_ANON]);
+		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+						-count[LRU_INACTIVE_ANON]);
+
 		if (scan_global_lru(sc))
 			zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
@@ -884,7 +991,7 @@ static unsigned long shrink_inactive_lis
 			 * The attempt at page out may have made some
 			 * of the pages active, mark them inactive again.
 			 */
-			nr_active = clear_active_flags(&page_list);
+			nr_active = clear_active_flags(&page_list, count);
 			count_vm_events(PGDEACTIVATE, nr_active);
 
 			nr_freed += shrink_page_list(&page_list, sc,
@@ -909,14 +1016,25 @@ static unsigned long shrink_inactive_lis
 		 * Put back any unfreeable pages.
 		 */
 		while (!list_empty(&page_list)) {
+			int lru = LRU_BASE;
 			page = lru_to_page(&page_list);
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			if (PageNoreclaim(page)) {
+				VM_BUG_ON(PageActive(page));
+				lru = LRU_NORECLAIM;
+			} else {
+				if (page_file_cache(page)) {
+					lru += LRU_FILE;
+					zone->recent_rotated_file++;
+				} else {
+					zone->recent_rotated_anon++;
+				}
+				if (PageActive(page))
+					lru += LRU_ACTIVE;
+			}
+			add_page_to_lru_list(zone, page, lru);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -947,115 +1065,7 @@ static inline void note_zone_scanning_pr
 
 static inline int zone_is_near_oom(struct zone *zone)
 {
-	return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE))*3;
-}
-
-/*
- * Determine we should try to reclaim mapped pages.
- * This is called only when sc->mem_cgroup is NULL.
- */
-static int calc_reclaim_mapped(struct scan_control *sc, struct zone *zone,
-				int priority)
-{
-	long mapped_ratio;
-	long distress;
-	long swap_tendency;
-	long imbalance;
-	int reclaim_mapped = 0;
-	int prev_priority;
-
-	if (scan_global_lru(sc) && zone_is_near_oom(zone))
-		return 1;
-	/*
-	 * `distress' is a measure of how much trouble we're having
-	 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-	 */
-	if (scan_global_lru(sc))
-		prev_priority = zone->prev_priority;
-	else
-		prev_priority = mem_cgroup_get_reclaim_priority(sc->mem_cgroup);
-
-	distress = 100 >> min(prev_priority, priority);
-
-	/*
-	 * The point of this algorithm is to decide when to start
-	 * reclaiming mapped memory instead of just pagecache.  Work out
-	 * how much memory
-	 * is mapped.
-	 */
-	if (scan_global_lru(sc))
-		mapped_ratio = ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
-	else
-		mapped_ratio = mem_cgroup_calc_mapped_ratio(sc->mem_cgroup);
-
-	/*
-	 * Now decide how much we really want to unmap some pages.  The
-	 * mapped ratio is downgraded - just because there's a lot of
-	 * mapped memory doesn't necessarily mean that page reclaim
-	 * isn't succeeding.
-	 *
-	 * The distress ratio is important - we don't want to start
-	 * going oom.
-	 *
-	 * A 100% value of vm_swappiness overrides this algorithm
-	 * altogether.
-	 */
-	swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
-
-	/*
-	 * If there's huge imbalance between active and inactive
-	 * (think active 100 times larger than inactive) we should
-	 * become more permissive, or the system will take too much
-	 * cpu before it start swapping during memory pressure.
-	 * Distress is about avoiding early-oom, this is about
-	 * making swappiness graceful despite setting it to low
-	 * values.
-	 *
-	 * Avoid div by zero with nr_inactive+1, and max resulting
-	 * value is vm_total_pages.
-	 */
-	if (scan_global_lru(sc)) {
-		imbalance  = zone_page_state(zone, NR_ACTIVE);
-		imbalance /= zone_page_state(zone, NR_INACTIVE) + 1;
-	} else
-		imbalance = mem_cgroup_reclaim_imbalance(sc->mem_cgroup);
-
-	/*
-	 * Reduce the effect of imbalance if swappiness is low,
-	 * this means for a swappiness very low, the imbalance
-	 * must be much higher than 100 for this logic to make
-	 * the difference.
-	 *
-	 * Max temporary value is vm_total_pages*100.
-	 */
-	imbalance *= (vm_swappiness + 1);
-	imbalance /= 100;
-
-	/*
-	 * If not much of the ram is mapped, makes the imbalance
-	 * less relevant, it's high priority we refill the inactive
-	 * list with mapped pages only in presence of high ratio of
-	 * mapped pages.
-	 *
-	 * Max temporary value is vm_total_pages*100.
-	 */
-	imbalance *= mapped_ratio;
-	imbalance /= 100;
-
-	/* apply imbalance feedback to swap_tendency */
-	swap_tendency += imbalance;
-
-	/*
-	 * Now use this metric to decide whether to start moving mapped
-	 * memory onto the inactive list.
-	 */
-	if (swap_tendency >= 100)
-		reclaim_mapped = 1;
-
-	return reclaim_mapped;
+	return zone->pages_scanned >= (zone_lru_pages(zone) * 3);
 }
 
 /*
@@ -1075,73 +1085,95 @@ static int calc_reclaim_mapped(struct sc
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
  */
-
-
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc, int priority)
+				struct scan_control *sc, int priority, int file)
 {
-	unsigned long pgmoved;
+	unsigned long pgmoved = 0;
 	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
-	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
-	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
+	struct list_head list[NR_LRU_LISTS];
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
+	enum lru_list lru;
 
-	if (sc->may_swap)
-		reclaim_mapped = calc_reclaim_mapped(sc, zone, priority);
+	for_each_lru(lru)
+		INIT_LIST_HEAD(&list[lru]);
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
 					ISOLATE_ACTIVE, zone,
-					sc->mem_cgroup, 1);
+					sc->mem_cgroup, 1, file);
 	/*
 	 * zone->pages_scanned is used for detect zone's oom
 	 * mem_cgroup remembers nr_scan by itself.
 	 */
 	if (scan_global_lru(sc))
 		zone->pages_scanned += pgscanned;
-
-	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
+	if (file)
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
+	else
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
+	/*
+	 * For sorting active vs inactive pages, we'll use the 'anon'
+	 * elements of the local list[] array and sort out the file vs
+	 * anon pages below.
+	 */
 	while (!list_empty(&l_hold)) {
+		lru = LRU_INACTIVE_ANON;
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, sc->mem_cgroup)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
-		} else if (TestClearPageReferenced(page)) {
-			list_add(&page->lru, &l_active);
+
+		if (!page_reclaimable(page, NULL)) {
+			/* Non-reclaimable pages go onto their own list. */
+			list_add(&page->lru, &list[LRU_NORECLAIM]);
 			continue;
 		}
-		list_add(&page->lru, &l_inactive);
+
+		if (page_referenced(page, 0, sc->mem_cgroup)) {
+			if (file)
+				/* Referenced file pages stay active. */
+				lru = LRU_ACTIVE_ANON;
+			else
+				/* Anonymous pages always get deactivated. */
+				pgmoved++;
+		}
+		list_add(&page->lru, &list[lru]);
 	}
 
+	/*
+	 * Count the referenced anon pages as rotated, to balance pageout
+	 * scan pressure between file and anonymous pages in get_scan_ratio.
+	 */
+	if (!file)
+		zone->recent_rotated_anon += pgmoved;
+
+	/*
+	 * Now put the pages back to the appropriate [file or anon] inactive
+	 * and active lists.
+	 */
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
+	lru = LRU_BASE + file * LRU_FILE;
 	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&l_inactive)) {
-		page = lru_to_page(&l_inactive);
-		prefetchw_prev_lru_page(page, &l_inactive, flags);
+	while (!list_empty(&list[LRU_INACTIVE_ANON])) {
+		page = lru_to_page(&list[LRU_INACTIVE_ANON]);
+		prefetchw_prev_lru_page(page, &list[LRU_INACTIVE_ANON], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->inactive_list);
+		list_move(&page->lru, &zone->list[lru]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru,
+								pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -1151,7 +1183,7 @@ static void shrink_active_list(unsigned 
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -1160,91 +1192,200 @@ static void shrink_active_list(unsigned 
 	}
 
 	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
+	lru = LRU_ACTIVE + file * LRU_FILE;
+	while (!list_empty(&list[LRU_ACTIVE_ANON])) {
+		page = lru_to_page(&list[LRU_ACTIVE_ANON]);
+		prefetchw_prev_lru_page(page, &list[LRU_ACTIVE_ANON], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		list_move(&page->lru, &zone->list[lru]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru,
+								pgmoved);
+			pgmoved = 0;
+			spin_unlock_irq(&zone->lru_lock);
+			if (vm_swap_full())
+				pagevec_swap_free(&pvec);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru, pgmoved);
+	if (file) {
+		zone->recent_rotated_file += pgmoved;
+	} else {
+		zone->recent_rotated_anon += pgmoved;
+	}
+
+#ifdef CONFIG_NORECLAIM
+	pgmoved = 0;
+	while (!list_empty(&list[LRU_NORECLAIM])) {
+		page = lru_to_page(&list[LRU_NORECLAIM]);
+		prefetchw_prev_lru_page(page, &list[LRU_NORECLAIM], flags);
+
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(!PageActive(page));
+		ClearPageActive(page);
+		VM_BUG_ON(PageNoreclaim(page));
+		SetPageNoreclaim(page);
+
+		list_move(&page->lru, &zone->list[LRU_NORECLAIM]);
+		pgmoved++;
+		if (!pagevec_add(&pvec, page)) {
+			__mod_zone_page_state(zone, NR_NORECLAIM, pgmoved);
+//TODO:  count these as deactivations?
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_NORECLAIM, pgmoved);
+#endif
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
 	spin_unlock_irq(&zone->lru_lock);
+	if (vm_swap_full())
+		pagevec_swap_free(&pvec);
 
 	pagevec_release(&pvec);
 }
 
+static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
+	struct zone *zone, struct scan_control *sc, int priority)
+{
+	int file = is_file_lru(lru);
+
+	if (lru == LRU_ACTIVE_FILE) {
+		shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		return 0;
+	}
+	if (lru == LRU_ACTIVE_ANON && inactive_anon_low(zone)) {
+		shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		return 0;
+	}
+	return shrink_inactive_list(nr_to_scan, zone, sc, file);
+}
+
+/*
+ * The utility of the anon and file memory corresponds to the fraction
+ * of pages that were recently referenced in each category.  Pageout
+ * pressure is distributed according to the size of each set, the fraction
+ * of recently referenced pages (except used-once file pages) and the
+ * swappiness parameter.
+ *
+ * We return the relative pressures as percentages so shrink_zone can
+ * easily use them.
+ */
+static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
+					unsigned long *percent)
+{
+	unsigned long anon, file;
+	unsigned long anon_prio, file_prio;
+	unsigned long rotate_sum;
+	unsigned long ap, fp;
+
+	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+		zone_page_state(zone, NR_INACTIVE_ANON);
+	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+		zone_page_state(zone, NR_INACTIVE_FILE);
+
+	rotate_sum = zone->recent_rotated_file + zone->recent_rotated_anon;
+
+	/* Keep a floating average of RECENT references. */
+	if (unlikely(rotate_sum > min(anon, file))) {
+		spin_lock_irq(&zone->lru_lock);
+		zone->recent_rotated_file /= 2;
+		zone->recent_rotated_anon /= 2;
+		spin_unlock_irq(&zone->lru_lock);
+		rotate_sum /= 2;
+	}
+
+	/*
+	 * With swappiness at 100, anonymous and file have the same priority.
+	 * This scanning priority is essentially the inverse of IO cost.
+	 */
+	anon_prio = sc->swappiness;
+	file_prio = 200 - sc->swappiness;
+
+	/*
+	 *                  anon       recent_rotated_anon
+	 * %anon = 100 * ----------- / ------------------- * IO cost
+	 *               anon + file       rotate_sum
+	 */
+	ap = (anon_prio * anon) / (anon + file + 1);
+	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
+	if (ap == 0)
+		ap = 1;
+	else if (ap > 100)
+		ap = 100;
+	percent[0] = ap;
+
+	fp = (file_prio * file) / (anon + file + 1);
+	fp *= rotate_sum / (zone->recent_rotated_file + 1);
+	if (fp == 0)
+		fp = 1;
+	else if (fp > 100)
+		fp = 100;
+	percent[1] = fp;
+}
+
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
 				struct scan_control *sc)
 {
-	unsigned long nr_active;
-	unsigned long nr_inactive;
+	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	unsigned long percent[2];       /* anon @ 0; file @ 1 */
+	enum lru_list l;
 
-	if (scan_global_lru(sc)) {
-		/*
-		 * Add one to nr_to_scan just to make sure that the kernel
-		 * will slowly sift through the active list.
-		 */
-		zone->nr_scan_active +=
-			(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-		nr_active = zone->nr_scan_active;
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-		nr_inactive = zone->nr_scan_inactive;
-		if (nr_inactive >= sc->swap_cluster_max)
-			zone->nr_scan_inactive = 0;
-		else
-			nr_inactive = 0;
-
-		if (nr_active >= sc->swap_cluster_max)
-			zone->nr_scan_active = 0;
-		else
-			nr_active = 0;
-	} else {
-		/*
-		 * This reclaim occurs not because zone memory shortage but
-		 * because memory controller hits its limit.
-		 * Then, don't modify zone reclaim related data.
-		 */
-		nr_active = mem_cgroup_calc_reclaim_active(sc->mem_cgroup,
-					zone, priority);
+	get_scan_ratio(zone, sc, percent);
 
-		nr_inactive = mem_cgroup_calc_reclaim_inactive(sc->mem_cgroup,
-					zone, priority);
+	for_each_reclaimable_lru(l) {
+		if (scan_global_lru(sc)) {
+			int file = is_file_lru(l);
+			/*
+			 * Add one to nr_to_scan just to make sure that the
+			 * kernel will slowly sift through the active list.
+			 */
+			zone->nr_scan[l] += (zone_page_state(zone,
+				NR_INACTIVE_ANON + l) >> priority) + 1;
+			nr[l] = zone->nr_scan[l] * percent[file] / 100;
+			if (nr[l] >= sc->swap_cluster_max)
+				zone->nr_scan[l] = 0;
+			else
+				nr[l] = 0;
+		} else {
+			/*
+			 * This reclaim occurs not because zone memory shortage
+			 * but because memory controller hits its limit.
+			 * Then, don't modify zone reclaim related data.
+			 */
+		nr[l] = mem_cgroup_calc_reclaim(sc->mem_cgroup, zone,
+							priority, l);
+		}
 	}
 
-
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			nr_to_scan = min(nr_active,
+	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
+					nr[LRU_INACTIVE_FILE]) {
+		for_each_reclaimable_lru(l) {
+			if (nr[l]) {
+				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
-			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, priority);
-		}
+				nr[l] -= nr_to_scan;
 
-		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= nr_to_scan;
-			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+				nr_reclaimed += shrink_list(l, nr_to_scan,
+							zone, sc, priority);
+			}
 		}
 	}
 
@@ -1309,7 +1450,7 @@ static unsigned long shrink_zones(int pr
 
 	return nr_reclaimed;
 }
- 
+
 /*
  * This is the main entry point to direct page reclaim.
  *
@@ -1346,8 +1487,7 @@ static unsigned long do_try_to_free_page
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_lru_pages(zone);
 		}
 	}
 
@@ -1540,6 +1680,14 @@ loop_again:
 			    priority != DEF_PRIORITY)
 				continue;
 
+			/*
+			 * Do some background aging of the anon list, to give
+			 * pages a chance to be referenced before reclaiming.
+			 */
+			if (inactive_anon_low(zone))
+				shrink_active_list(SWAP_CLUSTER_MAX, zone,
+							&sc, priority, 0);
+
 			if (!zone_watermark_ok(zone, order, zone->pages_high,
 					       0, 0)) {
 				end_zone = i;
@@ -1552,8 +1700,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_lru_pages(zone);
 		}
 
 		/*
@@ -1597,8 +1744,7 @@ loop_again:
 			if (zone_is_all_unreclaimable(zone))
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				(zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE)) * 6)
+						(zone_lru_pages(zone) * 6))
 					zone_set_flag(zone,
 						      ZONE_ALL_UNRECLAIMABLE);
 			/*
@@ -1653,7 +1799,7 @@ out:
 
 /*
  * The background pageout daemon, started as a kernel thread
- * from the init process. 
+ * from the init process.
  *
  * This basically trickles out pages so that we have _some_
  * free memory available even if there is no other activity
@@ -1761,6 +1907,7 @@ static unsigned long shrink_all_zones(un
 {
 	struct zone *zone;
 	unsigned long nr_to_scan, ret = 0;
+	enum lru_list l;
 
 	for_each_zone(zone) {
 
@@ -1770,36 +1917,37 @@ static unsigned long shrink_all_zones(un
 		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
-		/* For pass = 0 we don't shrink the active list */
-		if (pass > 0) {
-			zone->nr_scan_active +=
-				(zone_page_state(zone, NR_ACTIVE) >> prio) + 1;
-			if (zone->nr_scan_active >= nr_pages || pass > 3) {
-				zone->nr_scan_active = 0;
+		for_each_reclaimable_lru(l) {
+			/* For pass = 0, we don't shrink the active list */
+			if (pass == 0 &&
+				(l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE))
+				continue;
+
+			zone->nr_scan[l] +=
+				(zone_page_state(zone, NR_INACTIVE_ANON + l)
+								>> prio) + 1;
+			if (zone->nr_scan[l] >= nr_pages || pass > 3) {
+				zone->nr_scan[l] = 0;
 				nr_to_scan = min(nr_pages,
-					zone_page_state(zone, NR_ACTIVE));
-				shrink_active_list(nr_to_scan, zone, sc, prio);
+					zone_page_state(zone,
+							NR_INACTIVE_ANON + l));
+				ret += shrink_list(l, nr_to_scan, zone,
+								sc, prio);
+				if (ret >= nr_pages)
+					return ret;
 			}
 		}
-
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> prio) + 1;
-		if (zone->nr_scan_inactive >= nr_pages || pass > 3) {
-			zone->nr_scan_inactive = 0;
-			nr_to_scan = min(nr_pages,
-				zone_page_state(zone, NR_INACTIVE));
-			ret += shrink_inactive_list(nr_to_scan, zone, sc);
-			if (ret >= nr_pages)
-				return ret;
-		}
 	}
 
 	return ret;
 }
 
-static unsigned long count_lru_pages(void)
+unsigned long global_lru_pages(void)
 {
-	return global_page_state(NR_ACTIVE) + global_page_state(NR_INACTIVE);
+	return global_page_state(NR_ACTIVE_ANON)
+		+ global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_ANON)
+		+ global_page_state(NR_INACTIVE_FILE);
 }
 
 /*
@@ -1827,7 +1975,7 @@ unsigned long shrink_all_memory(unsigned
 
 	current->reclaim_state = &reclaim_state;
 
-	lru_pages = count_lru_pages();
+	lru_pages = global_lru_pages();
 	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
@@ -1870,7 +2018,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1887,7 +2035,7 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -2116,3 +2264,246 @@ int zone_reclaim(struct zone *zone, gfp_
 	return ret;
 }
 #endif
+
+#ifdef CONFIG_NORECLAIM
+/*
+ * page_reclaimable(struct page *page, struct vm_area_struct *vma)
+ * Test whether page is reclaimable--i.e., should be placed on active/inactive
+ * lists vs noreclaim list.
+ *
+ * @page       - page to test
+ * @vma        - vm area in which page is/will be mapped.  May be NULL.
+ *               If !NULL, called from fault path for a new page.
+ *
+ * Reasons page might not be reclaimable:
+ * 1) page's mapping marked non-reclaimable
+ * 2) page is mlock'ed into memory.
+ * TODO - later patches
+ *
+ * TODO:  specify locking assumptions
+ */
+int page_reclaimable(struct page *page, struct vm_area_struct *vma)
+{
+
+	VM_BUG_ON(PageNoreclaim(page));
+
+	if (mapping_non_reclaimable(page_mapping(page)))
+		return 0;
+
+#ifdef CONFIG_NORECLAIM_MLOCK
+	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+		return 0;
+#endif
+
+	/* TODO:  test page [!]reclaimable conditions */
+
+	return 1;
+}
+
+/*
+ * check_move_noreclaim_page() -- check @page for reclaimability and move
+ * to appropriate @zone lru list.
+ * @zone->lru_lock held on entry/exit.
+ * @page is on LRU and has PageNoreclaim true
+ */
+static void check_move_noreclaim_page(struct page *page, struct zone* zone)
+{
+
+	ClearPageNoreclaim(page); /* for page_reclaimable() */
+	if(page_reclaimable(page, NULL)) {
+		enum lru_list l = LRU_INACTIVE_ANON + page_file_cache(page);
+		__dec_zone_state(zone, NR_NORECLAIM);
+		list_move(&page->lru, &zone->list[l]);
+		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
+	} else {
+		/*
+		 * rotate noreclaim list
+		 */
+		SetPageNoreclaim(page);
+		list_move(&page->lru, &zone->list[LRU_NORECLAIM]);
+	}
+}
+
+/**
+ * scan_zone_noreclaim_pages(@zone)
+ * @zone - zone to scan
+ *
+ * Scan @zone's noreclaim LRU lists to check for pages that have become
+ * reclaimable.  Move those that have to @zone's inactive list where they
+ * become candidates for reclaim, unless shrink_inactive_zone() decides
+ * to reactivate them.  Pages that are still non-reclaimable are rotated
+ * back onto @zone's noreclaim list.
+ */
+#define SCAN_NORECLAIM_BATCH_SIZE 16UL	/* arbitrary lock hold batch size */
+void scan_zone_noreclaim_pages(struct zone *zone)
+{
+	struct list_head *l_noreclaim = &zone->list[LRU_NORECLAIM];
+	unsigned long scan;
+	unsigned long nr_to_scan = zone_page_state(zone, NR_NORECLAIM);
+
+	while (nr_to_scan > 0) {
+		unsigned long batch_size = min(nr_to_scan,
+						SCAN_NORECLAIM_BATCH_SIZE);
+
+		spin_lock_irq(&zone->lru_lock);
+		for (scan = 0;  scan < batch_size; scan++) {
+			struct page* page = lru_to_page(l_noreclaim);
+
+			if (TestSetPageLocked(page))
+				continue;
+
+			prefetchw_prev_lru_page(page, l_noreclaim, flags);
+
+			if (likely(PageLRU(page) && PageNoreclaim(page)))
+				check_move_noreclaim_page(page, zone);
+
+			unlock_page(page);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+
+		nr_to_scan -= batch_size;
+	}
+}
+
+
+/**
+ * scan_all_zones_noreclaim_pages()
+ *
+ * A really big hammer:  scan all zones' noreclaim LRU lists to check for
+ * pages that have become reclaimable.  Move those back to the zones'
+ * inactive list where they become candidates for reclaim.
+ * This occurs when, e.g., we have unswappable pages on the noreclaim lists,
+ * and we add swap to the system.  As such, it runs in the context of a task
+ * that has possibly/probably made some previously non-reclaimable pages
+ * reclaimable.
+//TODO:  or as a last resort under extreme memory pressure--before OOM?
+ */
+void scan_all_zones_noreclaim_pages(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		scan_zone_noreclaim_pages(zone);
+	}
+}
+
+/**
+ * scan_mapping_noreclaim_pages(mapping)
+ * @mapping - struct address_space to scan for reclaimable pages
+ *
+ * scan all pages in mapping.  check non-reclaimable pages for
+ * reclaimabililty and move them to the appropriate zone lru list.
+ */
+void scan_mapping_noreclaim_pages(struct address_space *mapping)
+{
+	pgoff_t next = 0;
+	pgoff_t end   = i_size_read(mapping->host);
+	struct zone *zone;
+	struct pagevec pvec;
+
+	if (mapping->nrpages == 0)
+		return;
+
+	pagevec_init(&pvec, 0);
+	while (next < end &&
+		pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		int i;
+
+		zone = NULL;
+
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			pgoff_t page_index = page->index;
+			struct zone *pagezone = page_zone(page);
+
+			if (page_index > next)
+				next = page_index;
+			next++;
+
+			if (TestSetPageLocked(page))
+				continue;
+
+			if (pagezone != zone) {
+				if (zone)
+					spin_unlock(&zone->lru_lock);
+				zone = pagezone;
+				spin_lock(&zone->lru_lock);
+			}
+
+			if (PageLRU(page) && PageNoreclaim(page))
+				check_move_noreclaim_page(page, zone);
+
+			unlock_page(page);
+
+		}
+		if (zone)
+			spin_unlock(&zone->lru_lock);
+		pagevec_release(&pvec);
+	}
+
+}
+
+/*
+ * scan_noreclaim_pages [vm] sysctl handler.  On demand re-scan of
+ * all nodes' noreclaim lists for reclaimable pages
+ */
+unsigned long scan_noreclaim_pages;
+
+int scan_noreclaim_handler( struct ctl_table *table, int write,
+			   struct file *file, void __user *buffer,
+			   size_t *length, loff_t *ppos)
+{
+	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+
+	if (write && *(unsigned long *)table->data)
+		scan_all_zones_noreclaim_pages();
+
+	scan_noreclaim_pages = 0;
+	return 0;
+}
+
+/*
+ * per node 'scan_noreclaim_pages' attribute.  On demand re-scan of
+ * a specified node's per zone noreclaim lists for reclaimable pages.
+ */
+
+static ssize_t read_scan_noreclaim_node(struct sys_device *dev, char *buf)
+{
+	return sprintf(buf, "0\n");	/* always zero; should fit... */
+}
+
+static ssize_t write_scan_noreclaim_node(struct sys_device *dev,
+                                       const char *buf, size_t count)
+{
+	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
+	struct zone *zone;
+	unsigned long req = simple_strtoul(buf, NULL, 10);
+
+	if (!req)
+		return 1;	/* zero is no-op */
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+		scan_zone_noreclaim_pages(zone);
+	}
+	return 1;
+}
+
+
+static SYSDEV_ATTR(scan_noreclaim_pages, S_IRUGO | S_IWUSR,
+			read_scan_noreclaim_node,
+			write_scan_noreclaim_node);
+
+int scan_noreclaim_register_node(struct node *node)
+{
+	return sysdev_create_file(&node->sysdev, &attr_scan_noreclaim_pages);
+}
+
+void scan_noreclaim_unregister_node(struct node *node)
+{
+	sysdev_remove_file(&node->sysdev, &attr_scan_noreclaim_pages);
+}
+
+
+#endif
Index: linux-2.6.24-rc6-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mempolicy.c	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mempolicy.c	2008-01-02 16:01:21.000000000 -0500
@@ -93,6 +93,8 @@
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -603,8 +605,12 @@ static void migrate_page_add(struct page
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
-		isolate_lru_page(page, pagelist);
+	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
+		if (!isolate_lru_page(page)) {
+			get_page(page);
+			list_add_tail(&page->lru, pagelist);
+		}
+	}
 }
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
@@ -1906,7 +1912,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		md->active++;
 
 	if (PageWriteback(page))
Index: linux-2.6.24-rc6-mm1/mm/swap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap.c	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap.c	2008-01-02 17:08:17.000000000 -0500
@@ -34,8 +34,10 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
-static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_anon_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_anon_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs) = { 0, };
 
 /*
@@ -117,8 +119,15 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page)) {
-			list_move_tail(&page->lru, &zone->inactive_list);
+	 	if (PageLRU(page) && !PageActive(page) && \
+					!PageNoreclaim(page)) {
+			if (page_file_cache(page)) {
+				list_move_tail(&page->lru,
+						&zone->list[LRU_INACTIVE_FILE]);
+			} else {
+				list_move_tail(&page->lru,
+						&zone->list[LRU_INACTIVE_ANON]);
+			}
 			pgmoved++;
 		}
 	}
@@ -145,7 +154,7 @@ int rotate_reclaimable_page(struct page 
 		return 1;
 	if (PageDirty(page))
 		return 1;
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		return 1;
 	if (!PageLRU(page))
 		return 1;
@@ -171,10 +180,14 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
+	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
+		int lru = LRU_BASE;
+		lru += page_file_cache(page);
+		del_page_from_lru_list(zone, page, lru);
+
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		lru += LRU_ACTIVE;
+		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
 	}
@@ -190,7 +203,8 @@ void activate_page(struct page *page)
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && !PageNoreclaim(page) &&
+			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
@@ -204,26 +218,90 @@ EXPORT_SYMBOL(mark_page_accessed);
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
  */
-void lru_cache_add(struct page *page)
+void lru_cache_add_anon(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_anon_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_anon(pvec);
+	put_cpu_var(lru_add_anon_pvecs);
+}
+
+void lru_cache_add_file(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_file_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvecs);
+		__pagevec_lru_add_file(pvec);
+	put_cpu_var(lru_add_file_pvecs);
 }
 
-void lru_cache_add_active(struct page *page)
+void lru_cache_add_active_anon(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_anon_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add_active(pvec);
-	put_cpu_var(lru_add_active_pvecs);
+		__pagevec_lru_add_active_anon(pvec);
+	put_cpu_var(lru_add_active_anon_pvecs);
+}
+
+void lru_cache_add_active_file(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_file_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_active_file(pvec);
+	put_cpu_var(lru_add_active_file_pvecs);
+}
+
+#ifdef CONFIG_NORECLAIM
+static DEFINE_PER_CPU(struct pagevec, lru_add_noreclaim_pvecs) = { 0, };
+
+void fastcall lru_cache_add_noreclaim(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_noreclaim_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_noreclaim(pvec);
+	put_cpu_var(lru_add_noreclaim_pvecs);
+}
+
+void fastcall lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma)
+{
+	if (page_reclaimable(page, vma)) {
+		if (page_file_cache(page))
+			lru_cache_add_active_file(page);
+		else
+			lru_cache_add_active_anon(page);
+	} else
+		lru_cache_add_noreclaim(page);
+}
+
+static inline void __drain_noreclaim_pvec(struct pagevec **pvec, int cpu)
+{
+	*pvec = &per_cpu(lru_add_noreclaim_pvecs, cpu);
+	if (pagevec_count(*pvec))
+		__pagevec_lru_add_noreclaim(*pvec);
+}
+#else
+void fastcall lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma)
+{
+	if (page_file_cache(page))
+		lru_cache_add_active_file(page);
+	else
+		lru_cache_add_active_anon(page);
 }
 
+static inline void __drain_noreclaim_pvec(struct pagevec **pvec, int cpu) { }
+#endif
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -233,13 +311,21 @@ static void drain_cpu_pagevecs(int cpu)
 {
 	struct pagevec *pvec;
 
-	pvec = &per_cpu(lru_add_pvecs, cpu);
+	pvec = &per_cpu(lru_add_file_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_file(pvec);
+
+	pvec = &per_cpu(lru_add_anon_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_anon(pvec);
 
-	pvec = &per_cpu(lru_add_active_pvecs, cpu);
+	pvec = &per_cpu(lru_add_active_file_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_lru_add_active_file(pvec);
+
+	pvec = &per_cpu(lru_add_active_anon_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_active_anon(pvec);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
@@ -250,6 +336,8 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	__drain_noreclaim_pvec(&pvec, cpu);
 }
 
 void lru_add_drain(void)
@@ -258,7 +346,7 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) || defined(CONFIG_NORECLAIM_MLOCK)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
@@ -321,6 +409,8 @@ void release_pages(struct page **pages, 
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+			int is_lru_page;
+
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irqrestore(&zone->lru_lock,
@@ -328,8 +418,10 @@ void release_pages(struct page **pages, 
 				zone = pagezone;
 				spin_lock_irqsave(&zone->lru_lock, flags);
 			}
-			VM_BUG_ON(!PageLRU(page));
-			__ClearPageLRU(page);
+			is_lru_page = PageLRU(page);
+			VM_BUG_ON(!(is_lru_page));
+			if (is_lru_page)
+				__ClearPageLRU(page);
 			del_page_from_lru(zone, page);
 		}
 
@@ -393,7 +485,34 @@ void __pagevec_release_nonlru(struct pag
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void __pagevec_lru_add(struct pagevec *pvec)
+void __pagevec_lru_add_file(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_file_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+EXPORT_SYMBOL(__pagevec_lru_add_file);
+void __pagevec_lru_add_active_file(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -410,7 +529,9 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
+		SetPageActive(page);
+		add_page_to_active_file_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
@@ -418,9 +539,32 @@ void __pagevec_lru_add(struct pagevec *p
 	pagevec_reinit(pvec);
 }
 
-EXPORT_SYMBOL(__pagevec_lru_add);
+void __pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
 
-void __pagevec_lru_add_active(struct pagevec *pvec)
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_anon_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -439,7 +583,7 @@ void __pagevec_lru_add_active(struct pag
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_anon_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
@@ -447,6 +591,35 @@ void __pagevec_lru_add_active(struct pag
 	pagevec_reinit(pvec);
 }
 
+#ifdef CONFIG_NORECLAIM
+void __pagevec_lru_add_noreclaim(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
+		SetPageNoreclaim(page);
+		add_page_to_noreclaim_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+#endif
+
 /*
  * Try to drop buffers from the pages in a pagevec
  */
@@ -465,6 +638,24 @@ void pagevec_strip(struct pagevec *pvec)
 	}
 }
 
+/*
+ * Try to free swap space from the pages in a pagevec
+ */
+void pagevec_swap_free(struct pagevec *pvec)
+{
+	int i;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+
+		if (PageSwapCache(page) && !TestSetPageLocked(page)) {
+			if (PageSwapCache(page))
+				remove_exclusive_swap_page(page);
+			unlock_page(page);
+		}
+	}
+}
+
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
Index: linux-2.6.24-rc6-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/pagevec.h	2008-01-02 12:37:12.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/pagevec.h	2008-01-02 16:01:21.000000000 -0500
@@ -23,9 +23,17 @@ struct pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec);
-void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_file(struct pagevec *pvec);
+void __pagevec_lru_add_active_file(struct pagevec *pvec);
+void __pagevec_lru_add_anon(struct pagevec *pvec);
+void __pagevec_lru_add_active_anon(struct pagevec *pvec);
+#ifdef CONFIG_NORECLAIM
+void __pagevec_lru_add_noreclaim(struct pagevec *pvec);
+#else
+static inline void __pagevec_lru_add_noreclaim(struct pagevec *pvec) { }
+#endif
 void pagevec_strip(struct pagevec *pvec);
+void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -81,10 +89,16 @@ static inline void pagevec_free(struct p
 		__pagevec_free(pvec);
 }
 
-static inline void pagevec_lru_add(struct pagevec *pvec)
+static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_file(pvec);
+}
+
+static inline void pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_anon(pvec);
 }
 
 #endif /* _LINUX_PAGEVEC_H */
Index: linux-2.6.24-rc6-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mm_inline.h	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mm_inline.h	2008-01-02 16:01:21.000000000 -0500
@@ -1,40 +1,144 @@
-static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+#ifndef LINUX_MM_INLINE_H
+#define LINUX_MM_INLINE_H
+
+#include <linux/fs.h>  /* for struct address_space */
+
+/**
+ * page_file_cache(@page)
+ * Returns !0 if @page is page cache page backed by a regular filesystem,
+ * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
+ *
+ * We would like to get this info without a page flag, but the state
+ * needs to survive until the page is last deleted from the LRU, which
+ * could be as far down as __page_cache_release.
+ */
+extern const struct address_space_operations shmem_aops;
+static inline int page_file_cache(struct page *page)
 {
-	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	struct address_space * mapping = page_mapping(page);
+
+	if (PageSwapBacked(page))
+		return 0;
+
+	/* These pages should all be marked PG_swapbacked */
+	WARN_ON(PageAnon(page));
+	WARN_ON(PageSwapCache(page));
+	WARN_ON(mapping && mapping->a_ops && mapping->a_ops == &shmem_aops);
+
+	/* The page is page cache backed by a normal filesystem. */
+	return LRU_FILE;
 }
 
 static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
+add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	list_add(&page->lru, &zone->list[l]);
+	__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
+//TODO:  eventually these can all go away?  just use above 2 fcns?
 static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
+add_page_to_active_anon_list(struct zone *zone, struct page *page)
 {
-	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_ANON);
+}
+
+static inline void
+add_page_to_inactive_anon_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_ANON);
+}
+
+static inline void
+del_page_from_active_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_ACTIVE_ANON);
+}
+
+static inline void
+del_page_from_inactive_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_ANON);
+}
+
+static inline void
+add_page_to_active_file_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_FILE);
+}
+
+static inline void
+add_page_to_inactive_file_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
+}
+
+static inline void
+del_page_from_active_file_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_ACTIVE_FILE);
+}
+
+static inline void
+del_page_from_inactive_file_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
+}
+
+#ifdef CONFIG_NORECLAIM
+static inline void
+add_page_to_noreclaim_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_NORECLAIM);
 }
 
 static inline void
+del_page_from_noreclaim_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_NORECLAIM);
+}
+#else
+static inline void
+add_page_to_noreclaim_list(struct zone *zone, struct page *page) { }
+
+static inline void
+del_page_from_noreclaim_list(struct zone *zone, struct page *page) { }
+#endif
+
+static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
+	enum lru_list l = LRU_INACTIVE_ANON;
+
 	list_del(&page->lru);
-	if (PageActive(page)) {
+	if (PageNoreclaim(page)) {
+		__ClearPageNoreclaim(page);
+		l = LRU_NORECLAIM;
+	} else if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
-	} else {
-		__dec_zone_state(zone, NR_INACTIVE);
+		l = LRU_ACTIVE_ANON;
 	}
+	l += page_file_cache(page);
+	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
+static inline int inactive_anon_low(struct zone *zone)
+{
+	unsigned long active, inactive;
+
+	active = zone_page_state(zone, NR_ACTIVE_ANON);
+	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+
+	if (inactive * zone->inactive_ratio < active)
+		return 1;
+
+	return 0;
+}
+#endif
Index: linux-2.6.24-rc6-mm1/mm/shmem.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/shmem.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/shmem.c	2008-01-02 17:08:17.000000000 -0500
@@ -179,7 +179,7 @@ static inline void shmem_unacct_blocks(u
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
+const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -1377,6 +1377,7 @@ repeat:
 				goto failed;
 			}
 
+			SetPageSwapBacked(filepage);
 			spin_lock(&info->lock);
 			entry = shmem_swp_alloc(info, idx, sgp);
 			if (IS_ERR(entry))
@@ -1467,10 +1468,13 @@ int shmem_lock(struct file *file, int lo
 		if (!user_shm_lock(inode->i_size, user))
 			goto out_nomem;
 		info->flags |= VM_LOCKED;
+		mapping_set_noreclaim(file->f_mapping);
 	}
 	if (!lock && (info->flags & VM_LOCKED) && user) {
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
+		mapping_clear_noreclaim(file->f_mapping);
+		scan_mapping_noreclaim_pages(file->f_mapping);
 	}
 	retval = 0;
 out_nomem:
@@ -2343,7 +2347,7 @@ static void destroy_inodecache(void)
 	kmem_cache_destroy(shmem_inode_cachep);
 }
 
-static const struct address_space_operations shmem_aops = {
+const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
Index: linux-2.6.24-rc6-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/page-flags.h	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/page-flags.h	2008-01-02 17:08:17.000000000 -0500
@@ -89,10 +89,12 @@
 #define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_buddy		19	/* Page is free, on buddy lists */
+#define PG_swapbacked		20	/* Page is backed by RAM/swap */
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 #define PG_readahead		PG_reclaim /* Reminder to do async read-ahead */
 
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 #define PG_pinned		PG_owner_priv_1	/* Xen pinned pagetable */
@@ -106,6 +108,9 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+
+#define PG_noreclaim		30	/* Page is "non-reclaimable"  */
+#define PG_mlocked		29	/* Page is vma mlocked */
 #endif
 
 /*
@@ -159,6 +164,8 @@ static inline void SetPageUptodate(struc
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
+#define TestSetPageActive(page) test_and_set_bit(PG_active, &(page)->flags)
+#define TestClearPageActive(page) test_and_clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
@@ -216,6 +223,10 @@ static inline void SetPageUptodate(struc
 #define ClearPageReclaim(page)	clear_bit(PG_reclaim, &(page)->flags)
 #define TestClearPageReclaim(page) test_and_clear_bit(PG_reclaim, &(page)->flags)
 
+#define PageSwapBacked(page)	test_bit(PG_swapbacked, &(page)->flags)
+#define SetPageSwapBacked(page)	set_bit(PG_swapbacked, &(page)->flags)
+#define __ClearPageSwapBacked(page)	__clear_bit(PG_swapbacked, &(page)->flags)
+
 #define PageCompound(page)	test_bit(PG_compound, &(page)->flags)
 #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
 #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
@@ -256,6 +267,38 @@ static inline void __ClearPageTail(struc
 #define PageSwapCache(page)	0
 #endif
 
+#ifdef CONFIG_NORECLAIM
+#define PageNoreclaim(page)	test_bit(PG_noreclaim, &(page)->flags)
+#define SetPageNoreclaim(page)	set_bit(PG_noreclaim, &(page)->flags)
+#define ClearPageNoreclaim(page) clear_bit(PG_noreclaim, &(page)->flags)
+#define __ClearPageNoreclaim(page) __clear_bit(PG_noreclaim, &(page)->flags)
+#define TestClearPageNoreclaim(page) \
+				test_and_clear_bit(PG_noreclaim, &(page)->flags)
+#ifdef CONFIG_NORECLAIM_MLOCK
+#define PageMlocked(page)	test_bit(PG_mlocked, &(page)->flags)
+#define SetPageMlocked(page)	set_bit(PG_mlocked, &(page)->flags)
+#define ClearPageMlocked(page) clear_bit(PG_mlocked, &(page)->flags)
+#define __ClearPageMlocked(page) __clear_bit(PG_mlocked, &(page)->flags)
+#define TestSetPageMlocked(page) test_and_set_bit(PG_mlocked, &(page)->flags)
+#define TestClearPageMlocked(page) \
+				test_and_clear_bit(PG_mlocked, &(page)->flags)
+#endif
+#else
+#define PageNoreclaim(page)	0
+#define SetPageNoreclaim(page)
+#define ClearPageNoreclaim(page)
+#define __ClearPageNoreclaim(page)
+#define TestClearPageNoreclaim(page) 0
+#endif
+#ifndef CONFIG_NORECLAIM_MLOCK
+#define PageMlocked(page)	0
+#define SetPageMlocked(page)
+#define ClearPageMlocked(page)
+#define __ClearPageMlocked(page)
+#define TestSetPageMlocked(page) 0
+#define TestClearPageMlocked(page) 0
+#endif
+
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
Index: linux-2.6.24-rc6-mm1/mm/memory.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/memory.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/memory.c	2008-01-02 17:11:28.000000000 -0500
@@ -1664,7 +1664,8 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
+		SetPageSwapBacked(new_page);
+		lru_cache_add_active_or_noreclaim(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2131,7 +2132,8 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
+	SetPageSwapBacked(page);
+	lru_cache_add_active_or_noreclaim(page, vma);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2283,9 +2285,10 @@ static int __do_fault(struct mm_struct *
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-                        inc_mm_counter(mm, anon_rss);
-                        lru_cache_add_active(page);
-                        page_add_new_anon_rmap(page, vma, address);
+			inc_mm_counter(mm, anon_rss);
+			SetPageSwapBacked(page);
+			lru_cache_add_active_or_noreclaim(page, vma);
+			page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(page);
Index: linux-2.6.24-rc6-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap_state.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap_state.c	2008-01-02 17:11:28.000000000 -0500
@@ -82,6 +82,7 @@ int add_to_swap_cache(struct page *page,
 		if (!error) {
 			page_cache_get(page);
 			SetPageSwapCache(page);
+			SetPageSwapBacked(page);
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
@@ -299,7 +300,10 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			if (!page_reclaimable(new_page, vma))
+				lru_cache_add_noreclaim(new_page);
+			else
+				lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-02 17:08:17.000000000 -0500
@@ -248,11 +248,16 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
+			1 << PG_swapbacked |
+			1 << PG_mlocked |
 			1 << PG_buddy );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
@@ -481,10 +486,18 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim |
+#endif
+// TODO:  always trip this under heavy workloads.
+//  Why isn't this being cleared on last unmap/unlock?
+//  			1 << PG_mlocked |
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
+	if (PageSwapBacked(page))
+		__ClearPageSwapBacked(page);
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
@@ -626,11 +639,17 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+			1 << PG_swapbacked |
+//TODO:  why hitting this?
+//			1 << PG_mlocked |
 			1 << PG_buddy ))))
 		bad_page(page);
 
@@ -643,7 +662,9 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk |
+//TODO take care of it here, for now.
+			1 << PG_mlocked );
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
@@ -1885,10 +1906,21 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
+		" inactive_file:%lu"
+//TODO:  check/adjust line lengths
+#ifdef CONFIG_NORECLAIM
+		" noreclaim:%lu"
+#endif
+		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
-		global_page_state(NR_ACTIVE),
-		global_page_state(NR_INACTIVE),
+		global_page_state(NR_ACTIVE_ANON),
+		global_page_state(NR_ACTIVE_FILE),
+		global_page_state(NR_INACTIVE_ANON),
+		global_page_state(NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM
+		global_page_state(NR_NORECLAIM),
+#endif
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1911,8 +1943,13 @@ void show_free_areas(void)
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
-			" active:%lukB"
-			" inactive:%lukB"
+			" active_anon:%lukB"
+			" inactive_anon:%lukB"
+			" active_file:%lukB"
+			" inactive_file:%lukB"
+#ifdef CONFIG_NORECLAIM
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1922,8 +1959,13 @@ void show_free_areas(void)
 			K(zone->pages_min),
 			K(zone->pages_low),
 			K(zone->pages_high),
-			K(zone_page_state(zone, NR_ACTIVE)),
-			K(zone_page_state(zone, NR_INACTIVE)),
+			K(zone_page_state(zone, NR_ACTIVE_ANON)),
+			K(zone_page_state(zone, NR_INACTIVE_ANON)),
+			K(zone_page_state(zone, NR_ACTIVE_FILE)),
+			K(zone_page_state(zone, NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM
+			K(zone_page_state(zone, NR_NORECLAIM)),
+#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
@@ -3409,6 +3451,7 @@ static void __meminit free_area_init_cor
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
+		enum lru_list l;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -3458,10 +3501,13 @@ static void __meminit free_area_init_cor
 		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
-		zone->nr_scan_active = 0;
-		zone->nr_scan_inactive = 0;
+		for_each_lru(l) {
+			INIT_LIST_HEAD(&zone->list[l]);
+			zone->nr_scan[l] = 0;
+		}
+		zone->recent_rotated_anon = 0;
+		zone->recent_rotated_file = 0;
+//TODO recent_scanned_* ???
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
@@ -4215,6 +4261,45 @@ void setup_per_zone_pages_min(void)
 	calculate_totalreserve_pages();
 }
 
+/**
+ * setup_per_zone_inactive_ratio - called when min_free_kbytes changes.
+ *
+ * The inactive anon list should be small enough that the VM never has to
+ * do too much work, but large enough that each inactive page has a chance
+ * to be referenced again before it is swapped out.
+ *
+ * The inactive_anon ratio is the ratio of active to inactive anonymous
+ * pages.  Ie. a ratio of 3 means 3:1 or 25% of the anonymous pages are
+ * on the inactive list.
+ *
+ * total     return    max
+ * memory    value     inactive anon
+ * -------------------------------------
+ *   10MB       1         5MB
+ *  100MB       1        50MB
+ *    1GB       3       250MB
+ *   10GB      10       0.9GB
+ *  100GB      31         3GB
+ *    1TB     101        10GB
+ *   10TB     320        32GB
+ */
+void setup_per_zone_inactive_ratio(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		unsigned int gb, ratio;
+
+		/* Zone size in gigabytes */
+		gb = zone->present_pages >> (30 - PAGE_SHIFT);
+		ratio = int_sqrt(10 * gb);
+		if (!ratio)
+			ratio = 1;
+
+		zone->inactive_ratio = ratio;
+	}
+}
+
 /*
  * Initialise min_free_kbytes.
  *
@@ -4252,6 +4337,7 @@ static int __init init_per_zone_pages_mi
 		min_free_kbytes = 65536;
 	setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
+	setup_per_zone_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_pages_min)
Index: linux-2.6.24-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mmzone.h	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mmzone.h	2008-01-02 17:08:17.000000000 -0500
@@ -80,21 +80,32 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_INACTIVE,
-	NR_ACTIVE,
+	NR_INACTIVE_ANON,	/* must match order of LRU_[IN]ACTIVE_* */
+	NR_ACTIVE_ANON,		/*  "     "     "   "       "           */
+	NR_INACTIVE_FILE,	/*  "     "     "   "       "           */
+	NR_ACTIVE_FILE,		/*  "     "     "   "       "           */
+#ifdef CONFIG_NORECLAIM
+	NR_NORECLAIM,	/*  "     "     "   "       "         */
+#ifdef CONFIG_NORECLAIM_MLOCK
+	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
+#endif
+#else
+	NR_NORECLAIM=NR_ACTIVE_FILE,	/* avoid compiler errors in dead code */
+	NR_MLOCK=NR_ACTIVE_FILE,	/* avoid compiler errors... */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
-	/* Second 128 byte cacheline */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
+	/* Second 128 byte cacheline */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
@@ -105,6 +116,40 @@ enum zone_stat_item {
 #endif
 	NR_VM_ZONE_STAT_ITEMS };
 
+/*
+ * We do arithmetic on the LRU lists in various places in the code,
+ * so it is important to keep the active lists LRU_ACTIVE higher in
+ * the array than the corresponding inactive lists, and to keep
+ * the *_FILE lists LRU_FILE higher than the corresponding _ANON lists.
+ */
+#define LRU_BASE 0
+#define LRU_ANON LRU_BASE
+#define LRU_ACTIVE 1
+#define LRU_FILE 2
+
+enum lru_list {
+	LRU_INACTIVE_ANON = LRU_BASE,
+	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
+	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
+	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
+#ifdef CONFIG_NORECLAIM
+	LRU_NORECLAIM,
+#else
+	LRU_NORECLAIM=LRU_ACTIVE_FILE,	/* avoid compiler errors in dead code */
+#endif
+	NR_LRU_LISTS
+};
+
+#define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
+
+#define for_each_reclaimable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+
+static inline int is_file_lru(enum lru_list l)
+{
+	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
+	return (l/2 == 1);
+}
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
@@ -258,10 +303,12 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
+	struct list_head	list[NR_LRU_LISTS];
+	unsigned long		nr_scan[NR_LRU_LISTS];
+
+	unsigned long		recent_rotated_anon;
+	unsigned long		recent_rotated_file;
+
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
@@ -283,6 +330,11 @@ struct zone {
 	 */
 	int prev_priority;
 
+	/*
+	 * The ratio of active to inactive pages.
+	 */
+	unsigned int inactive_ratio;
+
 
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
Index: linux-2.6.24-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmstat.c	2008-01-02 12:37:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmstat.c	2008-01-02 17:09:20.000000000 -0500
@@ -686,8 +686,16 @@ const struct seq_operations pagetypeinfo
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_free_pages",
-	"nr_inactive",
-	"nr_active",
+	"nr_inactive_anon",
+	"nr_active_anon",
+	"nr_inactive_file",
+	"nr_active_file",
+#ifdef CONFIG_NORECLAIM
+	"nr_noreclaim",
+#endif
+#ifdef CONFIG_NORECLAIM_MLOCK
+	"nr_mlock",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
@@ -750,7 +758,7 @@ static void zoneinfo_show_print(struct s
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        scanned  %lu (aa: %lu ia: %lu af: %lu if: %lu)"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
@@ -758,7 +766,10 @@ static void zoneinfo_show_print(struct s
 		   zone->pages_low,
 		   zone->pages_high,
 		   zone->pages_scanned,
-		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->nr_scan[LRU_ACTIVE_ANON],
+		   zone->nr_scan[LRU_INACTIVE_ANON],
+		   zone->nr_scan[LRU_ACTIVE_FILE],
+		   zone->nr_scan[LRU_INACTIVE_FILE],
 		   zone->spanned_pages,
 		   zone->present_pages);
 
@@ -795,10 +806,12 @@ static void zoneinfo_show_print(struct s
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
 		   "\n  prev_priority:     %i"
-		   "\n  start_pfn:         %lu",
+		   "\n  start_pfn:         %lu"
+		   "\n  inactive_ratio:    %u",
 			   zone_is_all_unreclaimable(zone),
 		   zone->prev_priority,
-		   zone->zone_start_pfn);
+		   zone->zone_start_pfn,
+		   zone->inactive_ratio);
 	seq_putc(m, '\n');
 }
 
Index: linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/proc/proc_misc.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c	2008-01-02 17:08:17.000000000 -0500
@@ -153,43 +153,59 @@ static int meminfo_read_proc(char *page,
 	 * Tagged format, for easy grepping and expansion.
 	 */
 	len = sprintf(page,
-		"MemTotal:     %8lu kB\n"
-		"MemFree:      %8lu kB\n"
-		"Buffers:      %8lu kB\n"
-		"Cached:       %8lu kB\n"
-		"SwapCached:   %8lu kB\n"
-		"Active:       %8lu kB\n"
-		"Inactive:     %8lu kB\n"
+		"MemTotal:       %8lu kB\n"
+		"MemFree:        %8lu kB\n"
+		"Buffers:        %8lu kB\n"
+		"Cached:         %8lu kB\n"
+		"SwapCached:     %8lu kB\n"
+		"Active(anon):   %8lu kB\n"
+		"Inactive(anon): %8lu kB\n"
+		"Active(file):   %8lu kB\n"
+		"Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		"Noreclaim:    %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		"Mlocked:      %8lu kB\n"
+#endif
+#endif
 #ifdef CONFIG_HIGHMEM
-		"HighTotal:    %8lu kB\n"
-		"HighFree:     %8lu kB\n"
-		"LowTotal:     %8lu kB\n"
-		"LowFree:      %8lu kB\n"
-#endif
-		"SwapTotal:    %8lu kB\n"
-		"SwapFree:     %8lu kB\n"
-		"Dirty:        %8lu kB\n"
-		"Writeback:    %8lu kB\n"
-		"AnonPages:    %8lu kB\n"
-		"Mapped:       %8lu kB\n"
-		"Slab:         %8lu kB\n"
-		"SReclaimable: %8lu kB\n"
-		"SUnreclaim:   %8lu kB\n"
-		"PageTables:   %8lu kB\n"
-		"NFS_Unstable: %8lu kB\n"
-		"Bounce:       %8lu kB\n"
-		"CommitLimit:  %8lu kB\n"
-		"Committed_AS: %8lu kB\n"
-		"VmallocTotal: %8lu kB\n"
-		"VmallocUsed:  %8lu kB\n"
-		"VmallocChunk: %8lu kB\n",
+		"HighTotal:      %8lu kB\n"
+		"HighFree:       %8lu kB\n"
+		"LowTotal:       %8lu kB\n"
+		"LowFree:        %8lu kB\n"
+#endif
+		"SwapTotal:      %8lu kB\n"
+		"SwapFree:       %8lu kB\n"
+		"Dirty:          %8lu kB\n"
+		"Writeback:      %8lu kB\n"
+		"AnonPages:      %8lu kB\n"
+		"Mapped:         %8lu kB\n"
+		"Slab:           %8lu kB\n"
+		"SReclaimable:   %8lu kB\n"
+		"SUnreclaim:     %8lu kB\n"
+		"PageTables:     %8lu kB\n"
+		"NFS_Unstable:   %8lu kB\n"
+		"Bounce:         %8lu kB\n"
+		"CommitLimit:    %8lu kB\n"
+		"Committed_AS:   %8lu kB\n"
+		"VmallocTotal:   %8lu kB\n"
+		"VmallocUsed:    %8lu kB\n"
+		"VmallocChunk:   %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
 		K(cached),
 		K(total_swapcache_pages),
-		K(global_page_state(NR_ACTIVE)),
-		K(global_page_state(NR_INACTIVE)),
+		K(global_page_state(NR_ACTIVE_ANON)),
+		K(global_page_state(NR_INACTIVE_ANON)),
+		K(global_page_state(NR_ACTIVE_FILE)),
+		K(global_page_state(NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM
+		K(global_page_state(NR_NORECLAIM)),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		K(global_page_state(NR_MLOCK)),
+#endif
+#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: linux-2.6.24-rc6-mm1/fs/cifs/file.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/cifs/file.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/cifs/file.c	2008-01-02 15:55:33.000000000 -0500
@@ -1783,7 +1783,7 @@ static void cifs_copy_cache_pages(struct
 		SetPageUptodate(page);
 		unlock_page(page);
 		if (!pagevec_add(plru_pvec, page))
-			__pagevec_lru_add(plru_pvec);
+			__pagevec_lru_add_file(plru_pvec);
 		data += PAGE_CACHE_SIZE;
 	}
 	return;
@@ -1921,7 +1921,7 @@ static int cifs_readpages(struct file *f
 		bytes_read = 0;
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 
 /* need to free smb_read_data buf before exit */
 	if (smb_read_data) {
Index: linux-2.6.24-rc6-mm1/fs/ntfs/file.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ntfs/file.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/ntfs/file.c	2008-01-02 15:55:33.000000000 -0500
@@ -439,7 +439,7 @@ static inline int __ntfs_grab_cache_page
 			pages[nr] = *cached_page;
 			page_cache_get(*cached_page);
 			if (unlikely(!pagevec_add(lru_pvec, *cached_page)))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_lru_add_file(lru_pvec);
 			*cached_page = NULL;
 		}
 		index++;
@@ -2084,7 +2084,7 @@ err_out:
 						OSYNC_METADATA|OSYNC_DATA);
 		}
   	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
Index: linux-2.6.24-rc6-mm1/fs/nfs/dir.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/nfs/dir.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/nfs/dir.c	2008-01-02 15:55:33.000000000 -0500
@@ -1497,7 +1497,7 @@ static int nfs_symlink(struct inode *dir
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
 		pagevec_add(&lru_pvec, page);
-		pagevec_lru_add(&lru_pvec);
+		pagevec_lru_add_file(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
Index: linux-2.6.24-rc6-mm1/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ramfs/file-nommu.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/ramfs/file-nommu.c	2008-01-02 15:55:33.000000000 -0500
@@ -111,12 +111,12 @@ static int ramfs_nommu_expand_for_mappin
 			goto add_error;
 
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_lru_add_file(&lru_pvec);
 
 		unlock_page(page);
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	return 0;
 
  fsize_exceeded:
Index: linux-2.6.24-rc6-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/base/node.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/base/node.c	2008-01-02 17:08:17.000000000 -0500
@@ -13,6 +13,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/swap.h>
 
 static struct sysdev_class node_class = {
 	.name = "node",
@@ -45,33 +46,49 @@ static ssize_t node_read_meminfo(struct 
 	si_meminfo_node(&i, nid);
 
 	n = sprintf(buf, "\n"
-		       "Node %d MemTotal:     %8lu kB\n"
-		       "Node %d MemFree:      %8lu kB\n"
-		       "Node %d MemUsed:      %8lu kB\n"
-		       "Node %d Active:       %8lu kB\n"
-		       "Node %d Inactive:     %8lu kB\n"
+		       "Node %d MemTotal:       %8lu kB\n"
+		       "Node %d MemFree:        %8lu kB\n"
+		       "Node %d MemUsed:        %8lu kB\n"
+		       "Node %d Active(anon):   %8lu kB\n"
+		       "Node %d Inactive(anon): %8lu kB\n"
+		       "Node %d Active(file):   %8lu kB\n"
+		       "Node %d Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		       "Node %d Noreclaim:    %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       "Node %d Mlocked:       %8lu kB\n"
+#endif
+#endif
 #ifdef CONFIG_HIGHMEM
-		       "Node %d HighTotal:    %8lu kB\n"
-		       "Node %d HighFree:     %8lu kB\n"
-		       "Node %d LowTotal:     %8lu kB\n"
-		       "Node %d LowFree:      %8lu kB\n"
+		       "Node %d HighTotal:      %8lu kB\n"
+		       "Node %d HighFree:       %8lu kB\n"
+		       "Node %d LowTotal:       %8lu kB\n"
+		       "Node %d LowFree:        %8lu kB\n"
 #endif
-		       "Node %d Dirty:        %8lu kB\n"
-		       "Node %d Writeback:    %8lu kB\n"
-		       "Node %d FilePages:    %8lu kB\n"
-		       "Node %d Mapped:       %8lu kB\n"
-		       "Node %d AnonPages:    %8lu kB\n"
-		       "Node %d PageTables:   %8lu kB\n"
-		       "Node %d NFS_Unstable: %8lu kB\n"
-		       "Node %d Bounce:       %8lu kB\n"
-		       "Node %d Slab:         %8lu kB\n"
-		       "Node %d SReclaimable: %8lu kB\n"
-		       "Node %d SUnreclaim:   %8lu kB\n",
+		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d Writeback:      %8lu kB\n"
+		       "Node %d FilePages:      %8lu kB\n"
+		       "Node %d Mapped:         %8lu kB\n"
+		       "Node %d AnonPages:      %8lu kB\n"
+		       "Node %d PageTables:     %8lu kB\n"
+		       "Node %d NFS_Unstable:   %8lu kB\n"
+		       "Node %d Bounce:         %8lu kB\n"
+		       "Node %d Slab:           %8lu kB\n"
+		       "Node %d SReclaimable:   %8lu kB\n"
+		       "Node %d SUnreclaim:     %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, node_page_state(nid, NR_ACTIVE),
-		       nid, node_page_state(nid, NR_INACTIVE),
+		       nid, node_page_state(nid, NR_ACTIVE_ANON),
+		       nid, node_page_state(nid, NR_INACTIVE_ANON),
+		       nid, node_page_state(nid, NR_ACTIVE_FILE),
+		       nid, node_page_state(nid, NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM
+		       nid, node_page_state(nid, NR_NORECLAIM),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       nid, K(node_page_state(nid, NR_MLOCK)),
+#endif
+#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
@@ -152,6 +169,8 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+
+		scan_noreclaim_register_node(node);
 	}
 	return error;
 }
@@ -170,6 +189,8 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
+	scan_noreclaim_unregister_node(node);
+
 	sysdev_unregister(&node->sysdev);
 }
 
Index: linux-2.6.24-rc6-mm1/mm/readahead.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/readahead.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/readahead.c	2008-01-02 15:55:33.000000000 -0500
@@ -229,7 +229,7 @@ int do_page_cache_readahead(struct addre
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
+	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
Index: linux-2.6.24-rc6-mm1/mm/filemap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/filemap.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/filemap.c	2008-01-02 17:08:17.000000000 -0500
@@ -34,6 +34,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/mm_inline.h> /* for page_file_cache() */
 #include "internal.h"
 
 /*
@@ -493,8 +494,12 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t offset, gfp_t gfp_mask)
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
-	if (ret == 0)
-		lru_cache_add(page);
+	if (ret == 0) {
+		if (page_file_cache(page))
+			lru_cache_add_file(page);
+		else
+			lru_cache_add_active_anon(page);
+	}
 	return ret;
 }
 
@@ -2520,8 +2525,16 @@ generic_file_direct_IO(int rw, struct ki
 	if (rw == WRITE) {
 		write_len = iov_length(iov, nr_segs);
 		end = (offset + write_len - 1) >> PAGE_CACHE_SHIFT;
-	       	if (mapping_mapped(mapping))
+		if (mapping_mapped(mapping)) {
+			/*
+			 * Calling unmap_mapping_range like this is wrong,
+			 * because it can lead to mlocked pages being
+			 * discarded (this is true even before the Noreclaim
+			 * mlock work). direct-IO vs pagecache is a load of
+			 * junk anyway, so who cares.
+			 */
 			unmap_mapping_range(mapping, offset, write_len, 0);
+		}
 	}
 
 	retval = filemap_write_and_wait(mapping);
Index: linux-2.6.24-rc6-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/vmstat.h	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/vmstat.h	2008-01-02 15:55:33.000000000 -0500
@@ -149,6 +149,16 @@ static inline unsigned long zone_page_st
 	return x;
 }
 
+extern unsigned long global_lru_pages(void);
+
+static inline unsigned long zone_lru_pages(struct zone *zone)
+{
+	return (zone_page_state(zone, NR_ACTIVE_ANON)
+		+ zone_page_state(zone, NR_ACTIVE_FILE)
+		+ zone_page_state(zone, NR_INACTIVE_ANON)
+		+ zone_page_state(zone, NR_INACTIVE_FILE));
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Determine the per node value of a stat item. This function
Index: linux-2.6.24-rc6-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page-writeback.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page-writeback.c	2008-01-02 15:55:33.000000000 -0500
@@ -270,9 +270,7 @@ static unsigned long highmem_dirtyable_m
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES)
-			+ zone_page_state(z, NR_INACTIVE)
-			+ zone_page_state(z, NR_ACTIVE);
+		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -290,9 +288,7 @@ static unsigned long determine_dirtyable
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES)
-		+ global_page_state(NR_INACTIVE)
-		+ global_page_state(NR_ACTIVE);
+	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
Index: linux-2.6.24-rc6-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/swap.h	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/swap.h	2008-01-02 17:08:17.000000000 -0500
@@ -7,6 +7,7 @@
 #include <linux/list.h>
 #include <linux/sched.h>
 #include <linux/memcontrol.h>
+#include <linux/node.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -171,8 +172,17 @@ extern unsigned int nr_free_pagecache_pa
 
 
 /* linux/mm/swap.c */
-extern void FASTCALL(lru_cache_add(struct page *));
-extern void FASTCALL(lru_cache_add_active(struct page *));
+extern void FASTCALL(lru_cache_add_file(struct page *));
+extern void FASTCALL(lru_cache_add_anon(struct page *));
+extern void FASTCALL(lru_cache_add_active_file(struct page *));
+extern void FASTCALL(lru_cache_add_active_anon(struct page *));
+extern void FASTCALL(lru_cache_add_active_or_noreclaim(struct page *page,
+						struct vm_area_struct *vma));
+#ifdef CONFIG_NORECLAIM
+extern void FASTCALL(lru_cache_add_noreclaim(struct page *page));
+#else
+static inline void lru_cache_add_noreclaim(struct page *page) { }
+#endif
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
@@ -185,7 +195,7 @@ extern unsigned long try_to_free_pages(s
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 							gfp_t gfp_mask);
-extern int __isolate_lru_page(struct page *page, int mode);
+extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
@@ -204,6 +214,34 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM
+extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+extern void scan_zone_noreclaim_pages(struct zone *);
+extern void scan_all_zones_noreclaim_pages(void);
+extern void scan_mapping_noreclaim_pages(struct address_space *);
+extern unsigned long scan_noreclaim_pages;
+extern int scan_noreclaim_handler(struct ctl_table *, int, struct file *,
+					void __user *, size_t *, loff_t *);
+extern int scan_noreclaim_register_node(struct node *node);
+extern void scan_noreclaim_unregister_node(struct node *node);
+#else
+static inline int page_reclaimable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return 1;
+}
+static inline void scan_zone_noreclaim_pages(struct zone *z) { }
+static inline void scan_all_zones_noreclaim_pages(void) { }
+static inline void scan_mapping_noreclaim_pages(struct address_space *mapping)
+{
+}
+static inline int scan_noreclaim_register_node(struct node *node)
+{
+	return 0;
+}
+static inline void scan_noreclaim_unregister_node(struct node *node) { }
+#endif
+
 extern int kswapd_run(int nid);
 
 #ifdef CONFIG_MMU
Index: linux-2.6.24-rc6-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/memcontrol.h	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/memcontrol.h	2008-01-02 15:56:00.000000000 -0500
@@ -42,7 +42,7 @@ extern unsigned long mem_cgroup_isolate_
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active);
+					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
@@ -69,10 +69,8 @@ extern void mem_cgroup_note_reclaim_prio
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
 
-extern long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
-extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
+extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+					int priority, enum lru_list lru);
 
 #else /* CONFIG_CGROUP_MEM_CONT */
 static inline void mm_init_cgroup(struct mm_struct *mm,
@@ -170,14 +168,9 @@ static inline void mem_cgroup_record_rec
 {
 }
 
-static inline long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
-{
-	return 0;
-}
-
-static inline long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
+static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
+					struct zone *zone, int priority,
+					int active, int file)
 {
 	return 0;
 }
Index: linux-2.6.24-rc6-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/memcontrol.c	2008-01-02 15:55:29.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/memcontrol.c	2008-01-02 16:01:21.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/mm_inline.h>
 
 #include <asm/uaccess.h>
 
@@ -80,22 +81,13 @@ static s64 mem_cgroup_read_stat(struct m
 /*
  * per-zone information in memory controller.
  */
-
-enum mem_cgroup_zstat_index {
-	MEM_CGROUP_ZSTAT_ACTIVE,
-	MEM_CGROUP_ZSTAT_INACTIVE,
-
-	NR_MEM_CGROUP_ZSTAT,
-};
-
 struct mem_cgroup_per_zone {
 	/*
 	 * spin_lock to protect the per cgroup LRU
 	 */
 	spinlock_t		lru_lock;
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long count[NR_MEM_CGROUP_ZSTAT];
+	struct list_head	lists[NR_LRU_LISTS];
+	unsigned long		count[NR_LRU_LISTS];
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -160,6 +152,7 @@ struct page_cgroup {
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
 
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -220,7 +213,7 @@ page_cgroup_zoneinfo(struct page_cgroup 
 }
 
 static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
-					enum mem_cgroup_zstat_index idx)
+					enum lru_list idx)
 {
 	int nid, zid;
 	struct mem_cgroup_per_zone *mz;
@@ -346,13 +339,15 @@ static struct page_cgroup *clear_page_cg
 
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
-	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int lru = LRU_BASE;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
-	if (from)
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
-	else
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
+	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
+
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
 	list_del_init(&pc->lru);
@@ -360,38 +355,37 @@ static void __mem_cgroup_remove_list(str
 
 static void __mem_cgroup_add_list(struct page_cgroup *pc)
 {
-	int to = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+	int lru = LRU_BASE;
+
+	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
+
+	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	list_add(&pc->lru, &mz->lists[lru]);
 
-	if (!to) {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
-		list_add(&pc->lru, &mz->inactive_list);
-	} else {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
-		list_add(&pc->lru, &mz->active_list);
-	}
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int file = pc->flags & PAGE_CGROUP_FLAG_FILE;
+	int lru = LRU_FILE * !!file + !!from;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
-	if (from)
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
-	else
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
-	if (active) {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
+	if (active)
 		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
-		list_move(&pc->lru, &mz->active_list);
-	} else {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
+	else
 		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		list_move(&pc->lru, &mz->inactive_list);
-	}
+
+	lru = LRU_FILE * !!file + !!active;
+	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	list_move(&pc->lru, &mz->lists[lru]);
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -437,20 +431,6 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
-/*
- * This function is called from vmscan.c. In page reclaiming loop. balance
- * between active and inactive list is calculated. For memory controller
- * page reclaiming, we should use using mem_cgroup's imbalance rather than
- * zone's global lru imbalance.
- */
-long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
-{
-	unsigned long active, inactive;
-	/* active and inactive are the number of pages. 'long' is ok.*/
-	active = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_ACTIVE);
-	inactive = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_INACTIVE);
-	return (long) (active / (inactive + 1));
-}
 
 /*
  * prev_priority control...this will be used in memory reclaim path.
@@ -479,29 +459,16 @@ void mem_cgroup_record_reclaim_priority(
  * (see include/linux/mmzone.h)
  */
 
-long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-				   struct zone *zone, int priority)
-{
-	long nr_active;
-	int nid = zone->zone_pgdat->node_id;
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
-
-	nr_active = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE);
-	return (nr_active >> priority);
-}
-
-long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
+long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+				int priority, enum lru_list lru)
 {
-	long nr_inactive;
+	long nr_pages;
 	int nid = zone->zone_pgdat->node_id;
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
-	return (nr_inactive >> priority);
+	nr_pages = MEM_CGROUP_ZSTAT(mz, lru);
+	return (nr_pages >> priority);
 }
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -509,7 +476,7 @@ unsigned long mem_cgroup_isolate_pages(u
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
 	unsigned long nr_taken = 0;
 	struct page *page;
@@ -519,13 +486,12 @@ unsigned long mem_cgroup_isolate_pages(u
 	struct page_cgroup *pc, *tmp;
 	int nid = z->zone_pgdat->node_id;
 	int zid = zone_idx(z);
+	int lru = LRU_FILE * !!file + !!active;
 	struct mem_cgroup_per_zone *mz;
 
+	/* TODO: split file and anon LRUs - Rik */
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	if (active)
-		src = &mz->active_list;
-	else
-		src = &mz->inactive_list;
+	src = &mz->lists[lru];
 
 
 	spin_lock(&mz->lru_lock);
@@ -539,6 +505,9 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (unlikely(!PageLRU(page)))
 			continue;
 
+		/*
+		 * TODO: play better with lumpy reclaim, grabbing anything.
+		 */
 		if (PageActive(page) && !active) {
 			__mem_cgroup_move_lists(pc, true);
 			continue;
@@ -551,7 +520,11 @@ unsigned long mem_cgroup_isolate_pages(u
 		scan++;
 		list_move(&pc->lru, &pc_list);
 
-		if (__isolate_lru_page(page, mode) == 0) {
+//TODO:  for now, don't isolate non-reclaimable pages.  When/if
+// mem controller supports a noreclaim list, we'll need to make
+// at least ISOLATE_ACTIVE visible outside of vm_scan and pass
+// the 'take_nonreclaimable' flag accordingly.
+		if (__isolate_lru_page(page, mode, file) == 0) {
 			list_move(&page->lru, dst);
 			nr_taken++;
 		}
@@ -664,6 +637,8 @@ retry:
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	if (page_file_cache(page))
+		pc->flags |= PAGE_CGROUP_FLAG_FILE;
 
 	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
 		/*
@@ -833,18 +808,17 @@ retry:
 static void
 mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
-			    int active)
+			    int active, int file)
 {
 	struct page_cgroup *pc;
 	struct page *page;
 	int count;
 	unsigned long flags;
 	struct list_head *list;
+	int lru;
 
-	if (active)
-		list = &mz->active_list;
-	else
-		list = &mz->inactive_list;
+	lru = LRU_FILE * !!file + !!active;
+	list = &mz->lists[lru];
 
 	if (list_empty(list))
 		return;
@@ -895,10 +869,14 @@ int mem_cgroup_force_empty(struct mem_cg
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				struct mem_cgroup_per_zone *mz;
 				mz = mem_cgroup_zoneinfo(mem, node, zid);
-				/* drop all page_cgroup in active_list */
-				mem_cgroup_force_empty_list(mem, mz, 1);
-				/* drop all page_cgroup in inactive_list */
-				mem_cgroup_force_empty_list(mem, mz, 0);
+				/* drop all page_cgroup in ACTIVE_ANON */
+				mem_cgroup_force_empty_list(mem, mz, 1, 0);
+				/* drop all page_cgroup in INACTIVE_ANON */
+				mem_cgroup_force_empty_list(mem, mz, 0, 0);
+				/* drop all page_cgroup in ACTIVE_FILE */
+				mem_cgroup_force_empty_list(mem, mz, 1, 1);
+				/* drop all page_cgroup in INACTIVE_FILE */
+				mem_cgroup_force_empty_list(mem, mz, 0, 1);
 			}
 	}
 	ret = 0;
@@ -991,14 +969,21 @@ static int mem_control_stat_show(struct 
 	}
 	/* showing # of active pages */
 	{
-		unsigned long active, inactive;
+		unsigned long active_anon, inactive_anon;
+		unsigned long active_file, inactive_file;
 
-		inactive = mem_cgroup_get_all_zonestat(mem_cont,
-						MEM_CGROUP_ZSTAT_INACTIVE);
-		active = mem_cgroup_get_all_zonestat(mem_cont,
-						MEM_CGROUP_ZSTAT_ACTIVE);
-		seq_printf(m, "active %ld\n", (active) * PAGE_SIZE);
-		seq_printf(m, "inactive %ld\n", (inactive) * PAGE_SIZE);
+		inactive_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_ANON);
+		active_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_ANON);
+		inactive_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_FILE);
+		active_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_FILE);
+		seq_printf(m, "active_anon %ld\n", (active_anon) * PAGE_SIZE);
+		seq_printf(m, "inactive_anon %ld\n", (inactive_anon) * PAGE_SIZE);
+		seq_printf(m, "active_file %ld\n", (active_file) * PAGE_SIZE);
+		seq_printf(m, "inactive_file %ld\n", (inactive_file) * PAGE_SIZE);
 	}
 	return 0;
 }
@@ -1052,6 +1037,7 @@ static int alloc_mem_cgroup_per_zone_inf
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
+	int i;
 	int zone;
 	/*
 	 * This routine is called against possible nodes.
@@ -1073,8 +1059,8 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		INIT_LIST_HEAD(&mz->active_list);
-		INIT_LIST_HEAD(&mz->inactive_list);
+		for (i = 0; i < NR_LRU_LISTS ; i++)
+			INIT_LIST_HEAD(&mz->lists[i]);
 		spin_lock_init(&mz->lru_lock);
 	}
 	return 0;
Index: linux-2.6.24-rc6-mm1/mm/Kconfig
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/Kconfig	2008-01-02 16:01:13.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/Kconfig	2008-01-02 17:08:17.000000000 -0500
@@ -193,3 +193,27 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config NORECLAIM
+	bool "Track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
+	depends on EXPERIMENTAL && 64BIT
+	help
+	  Supports tracking of non-reclaimable pages off the [in]active lists
+	  to avoid excessive reclaim overhead on large memory systems.  Pages
+	  may be non-reclaimable because:  they are locked into memory, they
+	  are anonymous pages for which no swap space exists, or they are anon
+	  pages that are expensive to unmap [long anon_vma "related vma" list.]
+
+config NORECLAIM_MLOCK
+	bool "Exclude mlock'ed pages from reclaim"
+	depends on NORECLAIM
+	help
+	  Treats mlock'ed pages as no-reclaimable.  Removing these pages from
+	  the LRU [in]active lists avoids the overhead of attempting to reclaim
+	  them.  Pages marked non-reclaimable for this reason will become
+	  reclaimable again when the last mlock is removed.
+	  when no swap space exists.  Removing these pages from the LRU lists
+	  avoids the overhead of attempting to reclaim them.  Pages marked
+	  non-reclaimable for this reason will become reclaimable again when/if
+	  sufficient swap space is added to the system.
+
Index: linux-2.6.24-rc6-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/kernel/sysctl.c	2008-01-02 16:28:36.000000000 -0500
+++ linux-2.6.24-rc6-mm1/kernel/sysctl.c	2008-01-02 17:08:16.000000000 -0500
@@ -1151,6 +1151,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_NORECLAIM
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "scan_noreclaim_pages",
+		.data		= &scan_noreclaim_pages,
+		.maxlen		= sizeof(scan_noreclaim_pages),
+		.mode		= 0644,
+		.proc_handler	= &scan_noreclaim_handler,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: linux-2.6.24-rc6-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/pagemap.h	2008-01-02 16:28:36.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/pagemap.h	2008-01-02 17:08:17.000000000 -0500
@@ -30,6 +30,34 @@ static inline void mapping_set_error(str
 	}
 }
 
+#ifdef CONFIG_NORECLAIM
+#define AS_NORECLAIM	(__GFP_BITS_SHIFT + 2)	/* e.g., ramdisk, SHM_LOCK */
+
+static inline void mapping_set_noreclaim(struct address_space *mapping)
+{
+	set_bit(AS_NORECLAIM, &mapping->flags);
+}
+
+static inline void mapping_clear_noreclaim(struct address_space *mapping)
+{
+	clear_bit(AS_NORECLAIM, &mapping->flags);
+}
+
+static inline int mapping_non_reclaimable(struct address_space *mapping)
+{
+	if (mapping)
+		return test_bit(AS_NORECLAIM, &mapping->flags);
+	return 0;
+}
+#else
+static inline void mapping_set_noreclaim(struct address_space *mapping) { }
+static inline void mapping_clear_noreclaim(struct address_space *mapping) { }
+static inline int mapping_non_reclaimable(struct address_space *mapping)
+{
+	return 0;
+}
+#endif
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
Index: linux-2.6.24-rc6-mm1/fs/ramfs/inode.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ramfs/inode.c	2008-01-02 16:28:36.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/ramfs/inode.c	2008-01-02 17:08:17.000000000 -0500
@@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
 		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
+		mapping_set_noreclaim(inode->i_mapping);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
Index: linux-2.6.24-rc6-mm1/drivers/block/brd.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/block/brd.c	2008-01-02 16:28:36.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/block/brd.c	2008-01-02 17:08:17.000000000 -0500
@@ -373,8 +373,21 @@ static int brd_ioctl(struct inode *inode
 	return error;
 }
 
+/*
+ * brd_open():
+ * Just mark the mapping as containing non-reclaimable pages
+ */
+static int brd_open(struct inode *inode, struct file *filp)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	mapping_set_noreclaim(mapping);
+	return 0;
+}
+
 static struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
+	.open  =		brd_open,
 	.ioctl =		brd_ioctl,
 #ifdef CONFIG_BLK_DEV_XIP
 	.direct_access =	brd_direct_access,
Index: linux-2.6.24-rc6-mm1/mm/mlock.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mlock.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mlock.c	2008-01-02 17:08:17.000000000 -0500
@@ -8,10 +8,16 @@
 #include <linux/capability.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/rmap.h>
+#include <linux/mmzone.h>
+
+#include "internal.h"
 
 int can_do_mlock(void)
 {
@@ -23,19 +29,256 @@ int can_do_mlock(void)
 }
 EXPORT_SYMBOL(can_do_mlock);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * Mlocked pages are marked with PageMlocked() flag for efficient testing
+ * in vmscan and, possibly, the fault path.
+ *
+ * An mlocked page [PageMlocked(page)] is non-reclaimable.  As such, it will
+ * be placed on the LRU "noreclaim" list, rather than the [in]active lists.
+ * The noreclaim list is an LRU sibling list to the [in]active lists.
+ * PageNoreclaim is set to indicate the non-reclaimable state.
+ *
+//TODO:  no longer counting, but does this still apply to lazy setting
+// of PageMlocked() ??
+ * When lazy incrementing via vmscan, it is important to ensure that the
+ * vma's VM_LOCKED status is not concurrently being modified, otherwise we
+ * may have elevated mlock_count of a page that is being munlocked. So lazy
+ * mlocked must take the mmap_sem for read, and verify that the vma really
+ * is locked (see mm/rmap.c).
+ */
+
+/*
+ * Clear the page's PageMlocked().  This can be useful in a situation where
+ * we want to unconditionally remove a page from the pagecache.
+ *
+ * It is legal to call this function for any page, mlocked or not.
+ * If called for a page that is still mapped by mlocked vmas, all we do
+ * is revert to lazy LRU behaviour -- semantics are not broken.
+ */
+void clear_page_mlock(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (unlikely(TestClearPageMlocked(page))) {
+		dec_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * Mark page as mlocked if not already.
+ * If page on LRU, isolate and putback to move to noreclaim list.
+ */
+void mlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (!TestSetPageMlocked(page)) {
+		inc_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * called from munlock()/munmap() path with page supposedly on the LRU.
+ *
+ * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
+ * [in try_to_unlock()] and then attempt to isolate the page.  We must
+ * isolate the page() to keep others from messing with its noreclaim
+ * and mlocked state while trying to unlock.  However, we pre-clear the
+ * mlocked state anyway as we might lose the isolation race and we might
+ * not get another chance to clear PageMlocked.  If we successfully
+ * isolate the page and try_to_unlock() detects other VM_LOCKED vmas
+ * mapping the page, we just restore the PageMlocked state.  If we lose
+ * the isolation race, and the page is mapped by other VM_LOCKED vmas,
+ * we'll detect this in try_to_unmap() and we'll call mlock_vma_page()
+ * above, if/when we try to reclaim the page.
+ */
+static void munlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (TestClearPageMlocked(page)) {
+		dec_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page)) {
+			if (try_to_unlock(page) == SWAP_MLOCK) {
+				SetPageMlocked(page);	/* still VM_LOCKED */
+				inc_zone_page_state(page, NR_MLOCK);
+			}
+			putback_lru_page(page);
+		}
+		/*
+		 * Else we lost the race.  let try_to_unmap() deal with it.
+		 * At least we get the page state and mlock stats right.
+		 * However, page is still on the noreclaim list.  We'll fix
+		 * that up when the page is eventually freed or we scan the
+		 * noreclaim list.
+		 */
+	}
+}
+
+/*
+ * Called in fault path via page_reclaimable() for a new page
+ * to determine if it's being mapped into a LOCKED vma.
+ * If so, mark page as mlocked.
+ */
+int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
+{
+	VM_BUG_ON(PageMlocked(page));	// TODO:  needed?
+	VM_BUG_ON(PageLRU(page));
+
+	if (likely(!(vma->vm_flags & VM_LOCKED)))
+		return 0;
+
+	if (!TestSetPageMlocked(page))
+		inc_zone_page_state(page, NR_MLOCK);
+	return 1;
+}
+
+/*
+ * mlock or munlock a range of pages in the vma depending on whether
+ * @lock is 1 or 0, respectively.  @lock must match vm_flags VM_LOCKED
+ * state.
+TODO:   we don't really need @lock, as we can determine it from vm_flags
+ *
+ * This takes care of making the pages present too.
+ *
+ * vma->vm_mm->mmap_sem must be held for write.
+ */
+int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr = start;
+	struct page *pages[16]; /* 16 gives a reasonable batch */
+	int write = !!(vma->vm_flags & VM_WRITE);
+	int nr_pages;
+	int ret = 0;
+
+	BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
+	VM_BUG_ON(lock != !!(vma->vm_flags & VM_LOCKED));
+
+	if (vma->vm_flags & VM_IO)
+		return ret;
+
+	lru_add_drain_all();	/* push cached pages to LRU */
+
+	nr_pages = (end - start) / PAGE_SIZE;
+
+	while (nr_pages > 0) {
+		int i;
+
+		cond_resched();
+
+		/*
+		 * get_user_pages makes pages present if we are
+		 * setting mlock.
+		 */
+		ret = get_user_pages(current, mm, addr,
+				min_t(int, nr_pages, ARRAY_SIZE(pages)),
+				write, 0, pages, NULL);
+		if (ret < 0)
+			break;
+		if (ret == 0) {
+			/*
+			 * We know the vma is there, so the only time
+			 * we cannot get a single page should be an
+			 * error (ret < 0) case.
+			 */
+			WARN_ON(1);
+			ret = -EFAULT;
+			break;
+		}
+
+		lru_add_drain();	/* push cached pages to LRU */
+
+		for (i = 0; i < ret; i++) {
+			struct page *page = pages[i];
+
+			lock_page(page);
+			if (lock)
+				mlock_vma_page(page);
+			else
+				munlock_vma_page(page);
+			unlock_page(page);
+			put_page(page);		/* ref from get_user_pages() */
+
+			addr += PAGE_SIZE;	/* for next get_user_pages() */
+			nr_pages--;
+		}
+	}
+
+	lru_add_drain_all();	/* to update stats */
+
+	return ret;
+}
+
+/**
+ * mlock_vma_pages_range
+ * @vma - vm area to mlock into memory
+ * @start - start address in @vma of range to mlock,
+ * @end   - end address in @vma of range
+ *
+ * Called with current->mm->mmap_sem held write locked.  Downgrade to read
+ * for faulting in pages.  This can take a looong time for large segments.
+ *
+ * We need to restore the mmap_sem to write locked because our callers'
+ * callers expect this.	 However, because the mmap could have changed
+ * [in a multi-threaded process], we need to recheck.
+ */
+int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	downgrade_write(&mm->mmap_sem);
+	__mlock_vma_pages_range(vma, start, end, 1);
+
+	up_read(&mm->mmap_sem);
+	/* vma can change or disappear */
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	/* non-NULL vma must contain @start, but need to check @end */
+	if (!vma ||  end > vma->vm_end)
+		return -EAGAIN;
+	return 0;
+}
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+
+/*
+ * Just make pages present if @lock true.  No-op if unlocking.
+ */
+int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	int ret = 0;
+
+	if (!lock || vma->vm_flags & VM_IO)
+		return ret;
+
+	return make_pages_present(start, end);
+}
+#endif /* CONFIG_NORECLAIM_MLOCK */
+
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
 {
-	struct mm_struct * mm = vma->vm_mm;
+	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
-	int pages;
+	int nr_pages;
 	int ret = 0;
+	int lock;
 
 	if (newflags == vma->vm_flags) {
 		*prev = vma;
 		goto out;
 	}
 
+//TODO:  linear_page_index() ?   non-linear pages?
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma));
@@ -59,24 +302,49 @@ static int mlock_fixup(struct vm_area_st
 	}
 
 success:
+	lock = !!(newflags & VM_LOCKED);
+
+	/*
+	 * Keep track of amount of locked VM.
+	 */
+	nr_pages = (end - start) >> PAGE_SHIFT;
+	if (!lock)
+		nr_pages = -nr_pages;
+	mm->locked_vm += nr_pages;
+
 	/*
-	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * vm_flags is protected by the mmap_sem held for write.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
-	 * set VM_LOCKED, make_pages_present below will bring it back.
+	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 	vma->vm_flags = newflags;
 
 	/*
-	 * Keep track of amount of locked VM.
+	 * mmap_sem is currently held for write.  If we're locking pages,
+	 * downgrade the write lock to a read lock so that other faults,
+	 * mmap scans, ... while we fault in all pages.
 	 */
-	pages = (end - start) >> PAGE_SHIFT;
-	if (newflags & VM_LOCKED) {
-		pages = -pages;
-		if (!(newflags & VM_IO))
-			ret = make_pages_present(start, end);
+	if (lock)
+		downgrade_write(&mm->mmap_sem);
+
+	__mlock_vma_pages_range(vma, start, end, lock);
+
+	if (lock) {
+		/*
+		 * Need to reacquire mmap sem in write mode, as our callers
+		 * expect this.  We have no support for atomically upgrading
+		 * a sem to write, so we need to check for changes while sem
+		 * is unlocked.
+		 */
+		up_read(&mm->mmap_sem);
+		/* vma can change or disappear */
+		down_write(&mm->mmap_sem);
+		*prev = find_vma(mm, start);
+		/* non-NULL *prev must contain @start, but need to check @end */
+		if (!(*prev) || end > (*prev)->vm_end)
+			ret = -EAGAIN;
 	}
 
-	mm->locked_vm -= pages;
 out:
 	if (ret == -ENOMEM)
 		ret = -EAGAIN;
Index: linux-2.6.24-rc6-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/rmap.h	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/rmap.h	2008-01-02 17:08:17.000000000 -0500
@@ -109,6 +109,17 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * called in munlock()/munmap() path to check for other vmas holding
+ * the page mlocked.
+ */
+int try_to_unlock(struct page *);
+#define TRY_TO_UNLOCK 1
+#else
+#define TRY_TO_UNLOCK 0		/* for compiler -- dead code elimination */
+#endif
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
@@ -132,5 +143,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6.24-rc6-mm1/mm/rmap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/rmap.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/rmap.c	2008-01-02 17:08:17.000000000 -0500
@@ -52,6 +52,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 struct kmem_cache *anon_vma_cachep;
 
 /* This must be called under the mmap_sem. */
@@ -284,10 +286,17 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate referenced for mlocked page that gets this far,
+	 * in order that it progresses to try_to_unmap and is moved to the
+	 * noreclaim list.
+	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+		goto out_unmap;
+	}
+
+	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -296,6 +305,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -384,11 +394,6 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && (mm_cgroup(vma->vm_mm) != mem_cont))
 			continue;
-		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
-				  == (VM_LOCKED|VM_MAYSHARE)) {
-			referenced++;
-			break;
-		}
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -712,10 +717,15 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+	if (!migration) {
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
+		if (ptep_clear_flush_young(vma, address, pte)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
 	}
 
 	/* Nuke the page table entry. */
@@ -797,6 +807,10 @@ out:
  * For very sparsely populated VMAs this is a little inefficient - chances are
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
+ *
+TODO:  still accurate with noreclaim infrastructure?
+ * Mlocked pages also aren't handled very well at the moment: they aren't
+ * moved off the LRU like they are for linear pages.
  */
 #define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
@@ -868,10 +882,28 @@ static void try_to_unmap_cluster(unsigne
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static int try_to_unmap_anon(struct page *page, int migration)
+/**
+ * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
+ * rmap method
+ * @page: the page to unmap/unlock
+ * @unlock:  request for unlock rather than unmap [unlikely]
+ * @migration:  unmapping for migration - ignored if @unlock
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the anon_vma struct it points to.
+ *
+ * This function is only called from try_to_unmap/try_to_unlock for
+ * anonymous pages.
+ * When called from try_to_unlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * 'LOCKED.
+ */
+static int try_to_unmap_anon(struct page *page, int unlock, int migration)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned int mlocked = 0;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -879,25 +911,53 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, migration);
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			break;			/* no need to look further */
+		} else
+			ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
+		if (ret == SWAP_MLOCK) {
+			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+				if (vma->vm_flags & VM_LOCKED) {
+					mlock_vma_page(page);
+					mlocked++;
+				}
+				up_read(&vma->vm_mm->mmap_sem);
+			}
+		}
 	}
-
 	page_unlock_anon_vma(anon_vma);
+
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
+
 	return ret;
 }
 
 /**
- * try_to_unmap_file - unmap file page using the object-based rmap method
- * @page: the page to unmap
+ * try_to_unmap_file - unmap or unlock file page using the object-based
+ * rmap method
+ * @page: the page to unmap/unlock
+ * @unlock:  request for unlock rather than unmap [unlikely]
+ * @migration:  unmapping for migration - ignored if @unlock
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the address_space struct it points to.
  *
- * This function is only called from try_to_unmap for object-based pages.
+ * This function is only called from try_to_unmap/try_to_unlock for
+ * object-based pages.
+ * When called from try_to_unlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, int migration)
+static int try_to_unmap_file(struct page *page, int unlock, int migration)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -908,19 +968,46 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned int mlocked = 0;
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, migration);
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			break;			/* no need to look further */
+		} else
+			ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			goto out;
+		if (ret == SWAP_MLOCK) {
+			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+				if (vma->vm_flags & VM_LOCKED) {
+					mlock_vma_page(page);
+					mlocked++;
+				}
+				up_read(&vma->vm_mm->mmap_sem);
+			}
+			if (unlikely(unlock))
+				break;  /* stop on 1st mlocked vma */
+		}
 	}
 
+	if (mlocked)
+		goto out;
+
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			goto out;		/* no need to look further */
+		}
 		if ((vma->vm_flags & VM_LOCKED) && !migration)
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
@@ -955,8 +1042,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -981,6 +1066,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
 	return ret;
 }
 
@@ -995,6 +1084,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, int migration)
 {
@@ -1003,12 +1093,32 @@ int try_to_unmap(struct page *page, int 
 	BUG_ON(!PageLocked(page));
 
 	if (PageAnon(page))
-		ret = try_to_unmap_anon(page, migration);
+		ret = try_to_unmap_anon(page, 0, migration);
 	else
-		ret = try_to_unmap_file(page, migration);
-
-	if (!page_mapped(page))
+		ret = try_to_unmap_file(page, 0, migration);
+	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/**
+ * try_to_unlock - Check page's rmap for other vma's holding page locked.
+ * @page: the page to be unlocked.   will be returned with PG_mlocked
+ * cleared if no vmas are VM_LOCKED.
+ *
+ * Return values are:
+ *
+ * SWAP_SUCCESS	- no vma's holding page locked.
+ * SWAP_MLOCK	- page is mlocked.
+ */
+int try_to_unlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
+
+	if (PageAnon(page))
+		return(try_to_unmap_anon(page, 1, 0));
+	else
+		return(try_to_unmap_file(page, 1, 0));
+}
+#endif
Index: linux-2.6.24-rc6-mm1/mm/mmap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mmap.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mmap.c	2008-01-02 17:08:17.000000000 -0500
@@ -32,6 +32,8 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1201,9 +1203,13 @@ out:	
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
-	}
-	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+		/*
+		 * makes pages present; downgrades, drops, requires mmap_sem
+		 */
+		error = mlock_vma_pages_range(vma, addr, addr + len);
+		if (error)
+			return error;	/* vma gone! */
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
 
@@ -1886,6 +1892,19 @@ int do_munmap(struct mm_struct *mm, unsi
 	vma = prev? prev->vm_next: mm->mmap;
 
 	/*
+	 * unlock any mlock()ed ranges before detaching vmas
+	 */
+	if (mm->locked_vm) {
+		struct vm_area_struct *tmp = vma;
+		while (tmp && tmp->vm_start < end) {
+			if (tmp->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(tmp,
+						 tmp->vm_start, tmp->vm_end);
+			tmp = tmp->vm_next;
+		}
+	}
+
+	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
@@ -2021,7 +2040,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
@@ -2032,13 +2051,26 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
+	if (mm->locked_vm) {
+		vma = mm->mmap;
+		while (vma) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(vma,
+						vma->vm_start, vma->vm_end);
+			vma = vma->vm_next;
+		}
+	}
+
+	vma = mm->mmap;
+
+
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
Index: linux-2.6.24-rc6-mm1/mm/mremap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mremap.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mremap.c	2008-01-02 17:08:17.000000000 -0500
@@ -23,6 +23,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
@@ -232,8 +234,8 @@ static unsigned long move_vma(struct vm_
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
-			make_pages_present(new_addr + old_len,
-					   new_addr + new_len);
+			mlock_vma_pages_range(vma, new_addr + old_len,
+						   new_addr + new_len);
 	}
 
 	return new_addr;
@@ -373,7 +375,7 @@ unsigned long do_mremap(unsigned long ad
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-				make_pages_present(addr + old_len,
+				mlock_vma_pages_range(vma, addr + old_len,
 						   addr + new_len);
 			}
 			ret = addr;
Index: linux-2.6.24-rc6-mm1/mm/truncate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/truncate.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/truncate.c	2008-01-02 17:08:17.000000000 -0500
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -104,6 +105,7 @@ truncate_complete_page(struct address_sp
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	remove_from_page_cache(page);
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -128,6 +130,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -354,6 +357,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
