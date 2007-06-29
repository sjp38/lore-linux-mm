Subject: RFC "Noreclaim Infrastructure - patch 1/3 basic infrastructure"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070629141254.GA23310@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	 <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
	 <46814829.8090808@redhat.com>
	 <20070626105541.cd82c940.akpm@linux-foundation.org>
	 <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost>
	 <20070629141254.GA23310@v2.random>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 18:42:46 -0400
Message-Id: <1183156967.7012.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

Patch against 2.6.21-rc5/6

Infrastructure to manage pages excluded from reclaim--i.e., hidden
from vmscan.  Based on a patch by Larry Woodman of Red Hat.

Applies atop two patches from Nick Piggin's "mlock pages off the LRU"
series:  move-and-rework-isolate_lru_page and
move-and-rename-install_arg_page

Maintain "nonreclaimable" pages on a separate per-zone list, to 
"hide" them from vmscan. 

Although this patch series does not support it, the noreclaim list
could be scanned at a lower rate--for example to attempt to reclaim
the "difficult to reclaim" pages when pages are REALLY needed, such
as when reserves are exhausted and a critical need arises.

A new function 'page_reclaimable(page, vma)' in vmscan.c tests whether
or not a page is reclaimable.  Subsequent patches will add the various
!reclaimable tests.  Reclaimable pages are placed on the appropriate
LRU list; non-reclaimable pages on the new noreclaim list.

Notes:

1.  Not sure I need the 'vma' arg to page_reclaimable().  I did in an
    earlier incarnation.  Don't seem to now

2.  for now, use bit 20 in page flags.   Could restrict to 64-bit
    systems only and use one of bits 21-30 [ia64 uses bit 31; other
    archs ???].  

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm_inline.h  |   34 +++++++++++++++++++-
 include/linux/mmzone.h     |    6 +++
 include/linux/page-flags.h |   20 ++++++++++++
 include/linux/pagevec.h    |    5 +++
 include/linux/swap.h       |   11 ++++++
 mm/Kconfig                 |    8 ++++
 mm/mempolicy.c             |    2 -
 mm/migrate.c               |    8 ++++
 mm/page_alloc.c            |    6 +++
 mm/swap.c                  |   73 +++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                |   75 ++++++++++++++++++++++++++++++++++++++++++++-
 11 files changed, 237 insertions(+), 11 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-03-26 12:39:02.000000000 -0400
+++ Linux/mm/Kconfig	2007-03-26 13:14:05.000000000 -0400
@@ -163,3 +163,11 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config NORECLAIM
+	bool "Track non-reclaimable pages"
+	help
+	  Supports tracking of non-reclaimable pages off the [in]active lists
+	  to avoid excessive reclaim overhead on large memory systems.  Pages
+	  may be non-reclaimable because:  they are locked into memory, they
+	  are anonymous pages for which no swap space exists, or they are anon
+	  pages that are expensive to unmap [long anon_vma "related vma" list.]
Index: Linux/include/linux/page-flags.h
===================================================================
--- Linux.orig/include/linux/page-flags.h	2007-03-26 12:39:01.000000000 -0400
+++ Linux/include/linux/page-flags.h	2007-03-26 13:15:08.000000000 -0400
@@ -91,6 +91,9 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_noreclaim		20	/* Page is "non-reclaimable"  */
+
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -249,6 +252,23 @@ static inline void SetPageUptodate(struc
 #define PageSwapCache(page)	0
 #endif
 
+#ifdef CONFIG_NORECLAIM
+#define PageNoreclaim(page)	test_bit(PG_noreclaim, &(page)->flags)
+#define SetPageNoreclaim(page)	set_bit(PG_noreclaim, &(page)->flags)
+#define ClearPageNoreclaim(page) clear_bit(PG_noreclaim, &(page)->flags)
+#define __ClearPageNoreclaim(page) __clear_bit(PG_noreclaim, &(page)->flags)
+//TODO:   need test versions?
+#define TestSetPageNoreclaim(page) \
+				test_and_set_bit(PG_noreclaim, &(page)->flags)
+#define TestClearPageNoreclaim(page) \
+				test_and_clear_bit(PG_noreclaim, &(page)->flags)
+#else
+#define PageNoreclaim(page)	0
+#define SetPageNoreclaim(page)
+#define ClearPageNoreclaim(page)
+#define __ClearPageNoreclaim(page)
+#endif
+
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-03-26 12:39:01.000000000 -0400
+++ Linux/include/linux/mmzone.h	2007-03-26 13:23:10.000000000 -0400
@@ -51,6 +51,9 @@ enum zone_stat_item {
 	NR_FREE_PAGES,
 	NR_INACTIVE,
 	NR_ACTIVE,
+#ifdef CONFIG_NORECLAIM
+	NR_NORECLAIM,
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -217,6 +220,9 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
 	struct list_head	inactive_list;
+#ifdef CONFIG_NORECLAIM
+	struct list_head	noreclaim_list;
+#endif
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-03-26 12:39:02.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-03-26 13:17:49.000000000 -0400
@@ -198,6 +198,7 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+			1 << PG_noreclaim	|
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -433,6 +434,7 @@ static inline int free_pages_check(struc
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+			1 << PG_noreclaim	|
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
@@ -582,6 +584,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+			1 << PG_noreclaim	|
 			1 << PG_dirty	|
 			1 << PG_reclaim	|
 			1 << PG_slab    |
@@ -2673,6 +2676,9 @@ static void __meminit free_area_init_cor
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
+#ifdef CONFIG_NORECLAIM
+		INIT_LIST_HEAD(&zone->noreclaim_list);
+#endif
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
Index: Linux/include/linux/mm_inline.h
===================================================================
--- Linux.orig/include/linux/mm_inline.h	2007-03-26 12:39:01.000000000 -0400
+++ Linux/include/linux/mm_inline.h	2007-03-26 13:24:10.000000000 -0400
@@ -26,11 +26,43 @@ del_page_from_inactive_list(struct zone 
 	__dec_zone_state(zone, NR_INACTIVE);
 }
 
+#ifdef CONFIG_NORECLAIM
+static inline void __dec_zone_noreclaim(struct zone *zone)
+{
+	__dec_zone_state(zone, NR_NORECLAIM);
+}
+
+static inline void
+add_page_to_noreclaim_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->noreclaim_list);
+	__inc_zone_state(zone, NR_NORECLAIM);
+}
+
+static inline void
+del_page_from_noreclaim_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	__dec_zone_noreclaim(zone);
+}
+#else
+static inline void __dec_zone_noreclaim(struct zone *zone) { }
+
+static inline void
+add_page_to_noreclaim_list(struct zone *zone, struct page *page) { }
+
+static inline void
+del_page_from_noreclaim_list(struct zone *zone, struct page *page) { }
+#endif
+
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	if (PageActive(page)) {
+	if (PageNoreclaim(page)) {
+		__ClearPageNoreclaim(page);
+		__dec_zone_noreclaim(zone);
+	} else if (PageActive(page)) {
 		__ClearPageActive(page);
 		__dec_zone_state(zone, NR_ACTIVE);
 	} else {
Index: Linux/include/linux/swap.h
===================================================================
--- Linux.orig/include/linux/swap.h	2007-03-26 12:39:01.000000000 -0400
+++ Linux/include/linux/swap.h	2007-03-26 13:13:18.000000000 -0400
@@ -186,6 +186,11 @@ extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
+#ifdef CONFIG_NORECLAIM
+extern void FASTCALL(lru_cache_add_noreclaim(struct page *page));
+#else
+static inline void lru_cache_add_noreclaim(struct page *page) { }
+#endif
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zone **, gfp_t);
@@ -207,6 +212,12 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM
+extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+#else
+#define page_reclaimable(P, V) 1
+#endif
+
 extern int kswapd_run(int nid);
 
 #ifdef CONFIG_MMU
Index: Linux/include/linux/pagevec.h
===================================================================
--- Linux.orig/include/linux/pagevec.h	2007-02-04 13:44:54.000000000 -0500
+++ Linux/include/linux/pagevec.h	2007-03-26 13:13:18.000000000 -0400
@@ -25,6 +25,11 @@ void __pagevec_release_nonlru(struct pag
 void __pagevec_free(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
+#ifdef CONFIG_NORECLAIM
+void __pagevec_lru_add_noreclaim(struct pagevec *pvec);
+#else
+static inline void __pagevec_lru_add_noreclaim(struct pagevec *pvec) { }
+#endif
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
Index: Linux/mm/swap.c
===================================================================
--- Linux.orig/mm/swap.c	2007-02-04 13:44:54.000000000 -0500
+++ Linux/mm/swap.c	2007-03-26 13:13:18.000000000 -0400
@@ -117,14 +117,14 @@ int rotate_reclaimable_page(struct page 
 		return 1;
 	if (PageDirty(page))
 		return 1;
-	if (PageActive(page))
+	if (PageActive(page) | PageNoreclaim(page))
 		return 1;
 	if (!PageLRU(page))
 		return 1;
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lru_lock, flags);
-	if (PageLRU(page) && !PageActive(page)) {
+	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
 		list_move_tail(&page->lru, &zone->inactive_list);
 		__count_vm_event(PGROTATED);
 	}
@@ -142,7 +142,7 @@ void fastcall activate_page(struct page 
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
+	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
 		del_page_from_inactive_list(zone, page);
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
@@ -160,7 +160,8 @@ void fastcall activate_page(struct page 
  */
 void fastcall mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && !PageNoreclaim(page) &&
+			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
@@ -197,6 +198,29 @@ void fastcall lru_cache_add_active(struc
 	put_cpu_var(lru_add_active_pvecs);
 }
 
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
+static inline void __drain_noreclaim_pvec(struct pagevec **pvec, int cpu)
+{
+	*pvec = &per_cpu(lru_add_noreclaim_pvecs, cpu);
+	if (pagevec_count(*pvec))
+		__pagevec_lru_add_noreclaim(*pvec);
+}
+#else
+static inline void __drain_noreclaim_pvec(struct pagevec **pvec, int cpu) { }
+#endif
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -207,6 +231,8 @@ static void __lru_add_drain(int cpu)
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_active(pvec);
+
+	__drain_noreclaim_pvec(&pvec, cpu);
 }
 
 void lru_add_drain(void)
@@ -277,14 +303,18 @@ void release_pages(struct page **pages, 
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+			int is_lru_page;
+
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irq(&zone->lru_lock);
 				zone = pagezone;
 				spin_lock_irq(&zone->lru_lock);
 			}
-			VM_BUG_ON(!PageLRU(page));
-			__ClearPageLRU(page);
+			is_lru_page = PageLRU(page);
+			VM_BUG_ON(!(is_lru_page));
+			if (is_lru_page)
+				__ClearPageLRU(page);
 			del_page_from_lru(zone, page);
 		}
 
@@ -392,7 +422,7 @@ void __pagevec_lru_add_active(struct pag
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 	}
@@ -402,6 +432,35 @@ void __pagevec_lru_add_active(struct pag
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
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-03-26 13:11:51.000000000 -0400
+++ Linux/mm/migrate.c	2007-03-26 13:13:18.000000000 -0400
@@ -52,7 +52,10 @@ int migrate_prep(void)
 
 static inline void move_to_lru(struct page *page)
 {
-	if (PageActive(page)) {
+	if (PageNoreclaim(page)) {
+		ClearPageNoreclaim(page);
+		lru_cache_add_noreclaim(page);
+	} else if (PageActive(page)) {
 		/*
 		 * lru_cache_add_active checks that
 		 * the PG_active bit is off.
@@ -322,6 +325,9 @@ static void migrate_page_copy(struct pag
 		SetPageUptodate(newpage);
 	if (PageActive(page))
 		SetPageActive(newpage);
+	else
+		if (PageNoreclaim(page))
+			SetPageNoreclaim(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-03-26 13:11:51.000000000 -0400
+++ Linux/mm/vmscan.c	2007-03-26 13:24:56.000000000 -0400
@@ -473,6 +473,11 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (!page_reclaimable(page, NULL)) {
+			SetPageNoreclaim(page);
+			goto keep_locked;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -587,6 +592,7 @@ free_it:
 		continue;
 
 activate_locked:
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -682,6 +688,8 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			if (PageActive(page))
 				del_page_from_active_list(zone, page);
+			else if (PageNoreclaim(page))
+				del_page_from_noreclaim_list(zone, page);
 			else
 				del_page_from_inactive_list(zone, page);
 		}
@@ -742,8 +750,11 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
+			if (PageActive(page)) {
 				add_page_to_active_list(zone, page);
+				VM_BUG_ON(PageNoreclaim(page));
+			} else if (PageNoreclaim(page))
+				add_page_to_noreclaim_list(zone, page);
 			else
 				add_page_to_inactive_list(zone, page);
 			if (!pagevec_add(&pvec, page)) {
@@ -806,6 +817,9 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
+#ifdef CONFIG_NORECLAIM
+	LIST_HEAD(l_noreclaim);	/* Pages to go onto the noreclaim list */
+#endif
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
@@ -869,6 +883,14 @@ force_reclaim_mapped:
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+		if (!page_reclaimable(page, NULL)) {
+			/*
+			 * divert any non-reclaimable pages onto the
+			 * noreclaim list
+			 */
+			list_add(&page->lru, &l_noreclaim);
+			continue;
+		}
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
@@ -931,6 +953,30 @@ force_reclaim_mapped:
 	}
 	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 
+#ifdef CONFIG_NORECLAIM
+	pgmoved = 0;
+	while (!list_empty(&l_noreclaim)) {
+		page = lru_to_page(&l_noreclaim);
+		prefetchw_prev_lru_page(page, &l_noreclaim, flags);
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(!PageActive(page));
+		ClearPageActive(page);
+		VM_BUG_ON(PageNoreclaim(page));
+		SetPageNoreclaim(page);
+		list_move(&page->lru, &zone->noreclaim_list);
+		pgmoved++;
+		if (!pagevec_add(&pvec, page)) {
+			__mod_zone_page_state(zone, NR_NORECLAIM, pgmoved);
+			pgmoved = 0;
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_NORECLAIM, pgmoved);
+#endif
+
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
 	spin_unlock_irq(&zone->lru_lock);
@@ -1764,3 +1810,30 @@ int zone_reclaim(struct zone *zone, gfp_
 	return __zone_reclaim(zone, gfp_mask, order);
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
+ *               If !NULL, called from fault path.
+ *
+ * Reasons page might not be reclaimable:
+ * TODO - later patches
+ *
+ * TODO:  specify locking assumptions
+ */
+int page_reclaimable(struct page *page, struct vm_area_struct *vma)
+{
+	int reclaimable = 1;
+
+	VM_BUG_ON(PageNoreclaim(page));
+
+	/* TODO:  test page [!]reclaimable conditions */
+
+	return reclaimable;
+}
+#endif
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-03-26 13:11:51.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-03-26 13:13:18.000000000 -0400
@@ -1790,7 +1790,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		md->active++;
 
 	if (PageWriteback(page))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
