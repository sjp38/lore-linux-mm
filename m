From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:38 -0400
Message-Id: <20070914205438.6536.49500.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 06/14 Reclaim Scalability: "No Reclaim LRU Infrastructure"

Against:  2.6.23-rc4-mm1

Infrastructure to manage pages excluded from reclaim--i.e., hidden
from vmscan.  Based on a patch by Larry Woodman of Red Hat. Reworked
to maintain "nonreclaimable" pages on a separate per-zone LRU list,
to "hide" them from vmscan.  A separate noreclaim pagevec is provided
for shrink_active_list() to move nonreclaimable pages to the noreclaim
list without over burdening the zone lru_lock.

Pages on the noreclaim list have both PG_noreclaim and PG_lru set.
Thus, PG_noreclaim is analogous to and mutually exclusive with
PG_active--it specifies which LRU list the page is on.  

The noreclaim infrastructure is enabled by a new mm Kconfig option
[CONFIG_]NORECLAIM.

A new function 'page_reclaimable(page, vma)' in vmscan.c tests whether
or not a page is reclaimable.  Subsequent patches will add the various
!reclaimable tests.  We'll want to keep these tests light-weight for
use in shrink_active_list() and, possibly, the fault path.

Notes:

1.  for now, use bit 30 in page flags.  This restricts the no reclaim
    infrastructure to 64-bit systems.  [The mlock patch, later in this
    series, uses another of these 64-bit-system-only flags.]

    Rationale:  32-bit systems have no free page flags and are less
    likely to have the large amounts of memory that exhibit the problems
    this series attempts to solve.  [I'm sure someone will disabuse me
    of this notion.]

    Thus, NORECLAIM currently depends on [CONFIG_]64BIT.

2.  The pagevec to move pages to the noreclaim list results in another
    loop at the end of shrink_active_list().  If we ultimately adopt Rik
    van Riel's split lru approach, I think we'll need to find a way to
    factor all of these loops into some common code.

3.  Based on a suggestion from the developers at the VM summit, this
    patch adds a function--putback_all_noreclaim_pages()--to splice the
    per zone noreclaim list[s] back to the end of their respective active
    lists when conditions dictate rechecking the pages for reclaimability.
    This required some rework to '__isolate_pages()' in vmscan.c to allow
    nonreclaimable pages to be isolated from the active list, but only
    when scanning that list--i.e., not when lumpy reclaim is looking for
    adjacent pages.

    TODO:  This approach needs a lot of refinement.

4.  TODO:  Memory Controllers maintain separate active and inactive lists.
    Need to consider whether they should also maintain a noreclaim list.  
    Also, convert to use Christoph's array of indexed lru variables?

    See //TODO note in mm/memcontrol.c re:  isolating non-reclaimable
    pages. 

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm_inline.h  |   26 ++++++-
 include/linux/mmzone.h     |   12 ++-
 include/linux/page-flags.h |   18 +++++
 include/linux/pagevec.h    |    5 +
 include/linux/swap.h       |   27 +++++++
 mm/Kconfig                 |   10 ++
 mm/memcontrol.c            |    6 +
 mm/mempolicy.c             |    2 
 mm/migrate.c               |   16 ++++
 mm/page_alloc.c            |    3 
 mm/swap.c                  |   83 +++++++++++++++++++++--
 mm/vmscan.c                |  157 ++++++++++++++++++++++++++++++++++++++++-----
 12 files changed, 332 insertions(+), 33 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/Kconfig	2007-09-14 10:22:02.000000000 -0400
@@ -194,3 +194,13 @@ config NR_QUICK
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
Index: Linux/include/linux/page-flags.h
===================================================================
--- Linux.orig/include/linux/page-flags.h	2007-09-14 10:17:54.000000000 -0400
+++ Linux/include/linux/page-flags.h	2007-09-14 10:21:48.000000000 -0400
@@ -94,6 +94,7 @@
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 #define PG_readahead		PG_reclaim /* Reminder to do async read-ahead */
 
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 #define PG_pinned		PG_owner_priv_1	/* Xen pinned pagetable */
@@ -107,6 +108,8 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+
+#define PG_noreclaim		30	/* Page is "non-reclaimable"  */
 #endif
 
 /*
@@ -261,6 +264,21 @@ static inline void __ClearPageTail(struc
 #define PageSwapCache(page)	0
 #endif
 
+#ifdef CONFIG_NORECLAIM
+#define PageNoreclaim(page)	test_bit(PG_noreclaim, &(page)->flags)
+#define SetPageNoreclaim(page)	set_bit(PG_noreclaim, &(page)->flags)
+#define ClearPageNoreclaim(page) clear_bit(PG_noreclaim, &(page)->flags)
+#define __ClearPageNoreclaim(page) __clear_bit(PG_noreclaim, &(page)->flags)
+#define TestClearPageNoreclaim(page) test_and_clear_bit(PG_noreclaim, \
+							 &(page)->flags)
+#else
+#define PageNoreclaim(page)	0
+#define SetPageNoreclaim(page)
+#define ClearPageNoreclaim(page)
+#define __ClearPageNoreclaim(page)
+#define TestClearPageNoreclaim(page) 0
+#endif
+
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-09-14 10:21:45.000000000 -0400
+++ Linux/include/linux/mmzone.h	2007-09-14 10:21:48.000000000 -0400
@@ -81,8 +81,11 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
+	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE, ... */
 	NR_ACTIVE,	/*  "     "     "   "       "         */
+#ifdef CONFIG_NORECLAIM
+	NR_NORECLAIM,	/*  "     "     "   "       "         */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -107,12 +110,17 @@ enum zone_stat_item {
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum lru_list {
-	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE */
+	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE, ... */
 	LRU_ACTIVE,	/*  "     "     "   "       "        */
+#ifdef CONFIG_NORECLAIM
+	LRU_NORECLAIM,	/*  must be last -- i.e., NR_LRU_LISTS - 1 */
+#endif
 	NR_LRU_LISTS };
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+#define for_each_reclaimable_lru(l) for (l = 0; l <= LRU_ACTIVE; l++)
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-09-14 10:21:45.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-09-14 10:22:05.000000000 -0400
@@ -247,6 +247,7 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+			1 << PG_noreclaim	|
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -481,6 +482,7 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+			1 << PG_noreclaim |
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -626,6 +628,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+			1 << PG_noreclaim	|
 			1 << PG_dirty	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
Index: Linux/include/linux/mm_inline.h
===================================================================
--- Linux.orig/include/linux/mm_inline.h	2007-09-14 10:21:45.000000000 -0400
+++ Linux/include/linux/mm_inline.h	2007-09-14 10:21:48.000000000 -0400
@@ -65,15 +65,37 @@ del_page_from_inactive_list(struct zone 
 	del_page_from_lru_list(zone, page, LRU_INACTIVE);
 }
 
+#ifdef CONFIG_NORECLAIM
+static inline void
+add_page_to_noreclaim_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_NORECLAIM);
+}
+
+static inline void
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
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l = LRU_INACTIVE;
 
 	list_del(&page->lru);
-	if (PageActive(page)) {
+	if (PageNoreclaim(page)) {
+		__ClearPageNoreclaim(page);
+		l = NR_LRU_LISTS - 1;	/* == LRU_NORECLAIM, if config'd */
+	} else if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
 		l = LRU_ACTIVE;
 	}
 	__dec_zone_state(zone, NR_INACTIVE + l);
Index: Linux/include/linux/swap.h
===================================================================
--- Linux.orig/include/linux/swap.h	2007-09-14 10:17:54.000000000 -0400
+++ Linux/include/linux/swap.h	2007-09-14 10:22:02.000000000 -0400
@@ -187,12 +187,25 @@ extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
+#ifdef CONFIG_NORECLAIM
+extern void FASTCALL(lru_cache_add_noreclaim(struct page *page));
+extern void FASTCALL(lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma));
+#else
+static inline void lru_cache_add_noreclaim(struct page *page) { }
+static inline void lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma);
+{
+	lru_cache_add_active(page);
+}
+#endif
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zone **zones, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_container_pages(struct mem_container *mem);
-extern int __isolate_lru_page(struct page *page, int mode);
+extern int __isolate_lru_page(struct page *page, int mode,
+					int take_nonreclaimable);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
@@ -211,6 +224,18 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM
+extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+extern void putback_all_noreclaim_pages(void);
+#else
+static inline int page_reclaimable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return 1;
+}
+static inline void putback_all_noreclaim_pages(void) { }
+#endif
+
 extern int kswapd_run(int nid);
 
 #ifdef CONFIG_MMU
Index: Linux/include/linux/pagevec.h
===================================================================
--- Linux.orig/include/linux/pagevec.h	2007-09-14 10:17:54.000000000 -0400
+++ Linux/include/linux/pagevec.h	2007-09-14 10:21:48.000000000 -0400
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
--- Linux.orig/mm/swap.c	2007-09-14 10:21:45.000000000 -0400
+++ Linux/mm/swap.c	2007-09-14 10:21:48.000000000 -0400
@@ -116,14 +116,14 @@ int rotate_reclaimable_page(struct page 
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
 		list_move_tail(&page->lru, &zone->list[LRU_INACTIVE]);
 		__count_vm_event(PGROTATED);
 	}
@@ -141,7 +141,7 @@ void fastcall activate_page(struct page 
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
@@ -197,6 +198,38 @@ void fastcall lru_cache_add_active(struc
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
+void fastcall lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma)
+{
+	if (page_reclaimable(page, vma))
+		lru_cache_add_active(page);
+	else
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
+static inline void __drain_noreclaim_pvec(struct pagevec **pvec, int cpu) { }
+#endif
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -207,6 +240,8 @@ static void __lru_add_drain(int cpu)
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_active(pvec);
+
+	__drain_noreclaim_pvec(&pvec, cpu);
 }
 
 void lru_add_drain(void)
@@ -277,14 +312,18 @@ void release_pages(struct page **pages, 
 
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
 
@@ -363,6 +402,7 @@ void __pagevec_lru_add(struct pagevec *p
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
@@ -392,7 +432,7 @@ void __pagevec_lru_add_active(struct pag
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 	}
@@ -402,6 +442,35 @@ void __pagevec_lru_add_active(struct pag
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
--- Linux.orig/mm/migrate.c	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/migrate.c	2007-09-14 10:21:48.000000000 -0400
@@ -52,13 +52,22 @@ int migrate_prep(void)
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
 		/*
 		 * lru_cache_add_active checks that
 		 * the PG_active bit is off.
 		 */
+		VM_BUG_ON(PageNoreclaim(page));	/* race ? */
 		ClearPageActive(page);
 		lru_cache_add_active(page);
 	} else {
@@ -340,8 +349,11 @@ static void migrate_page_copy(struct pag
 		SetPageReferenced(newpage);
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
-	if (PageActive(page))
+	if (PageActive(page)) {
+		VM_BUG_ON(PageNoreclaim(page));
 		SetPageActive(newpage);
+	} else if (PageNoreclaim(page))
+		SetPageNoreclaim(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:21:45.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:23:46.000000000 -0400
@@ -485,6 +485,11 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (!page_reclaimable(page, NULL)) {
+			SetPageNoreclaim(page);
+			goto keep_locked;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -613,6 +618,7 @@ free_it:
 		continue;
 
 activate_locked:
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -640,10 +646,12 @@ keep:
  *
  * page:	page to consider
  * mode:	one of the LRU isolation modes defined above
+ * take_nonreclaimable:   isolate non-reclaimable pages -- i.e., from active
+ *              list
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode)
+int __isolate_lru_page(struct page *page, int mode, int take_nonreclaimable)
 {
 	int ret = -EINVAL;
 
@@ -652,12 +660,27 @@ int __isolate_lru_page(struct page *page
 		return ret;
 
 	/*
-	 * When checking the active state, we need to be sure we are
-	 * dealing with comparible boolean values.  Take the logical not
-	 * of each.
+	 * Non-reclaimable pages shouldn't make it onto the inactive list,
+	 * so if we encounter one, we should be scanning either the active
+	 * list--e.g., after splicing noreclaim list to end of active list--
+	 * or nearby pages [lumpy reclaim].  Take it only if scanning active
+	 * list.
 	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
-		return ret;
+	if (PageNoreclaim(page)) {
+		if (!take_nonreclaimable)
+			return -EBUSY;	/* lumpy reclaim -- skip this page */
+		/*
+		 * else fall thru' and try to isolate
+		 */
+	} else {
+		/*
+		 * When checking the active state, we need to be sure we are
+		 * dealing with comparible boolean values.  Take the logical
+		 * not of each.
+		 */
+		if ((mode != ISOLATE_BOTH && (!PageActive(page) != !mode)))
+			return ret;
+	}
 
 	ret = -EBUSY;
 	if (likely(get_page_unless_zero(page))) {
@@ -670,6 +693,8 @@ int __isolate_lru_page(struct page *page
 		ret = 0;
 	}
 
+	if (TestClearPageNoreclaim(page))
+		SetPageActive(page);	/* will recheck in shrink_active_list */
 	return ret;
 }
 
@@ -711,7 +736,8 @@ static unsigned long isolate_lru_pages(u
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode)) {
+		switch (__isolate_lru_page(page, mode,
+						 (mode == ISOLATE_ACTIVE))) {
 		case 0:
 			list_move(&page->lru, dst);
 			nr_taken++;
@@ -757,7 +783,7 @@ static unsigned long isolate_lru_pages(u
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			switch (__isolate_lru_page(cursor_page, mode)) {
+			switch (__isolate_lru_page(cursor_page, mode, 0)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
@@ -817,9 +843,10 @@ static unsigned long clear_active_flags(
  * refcount on the page, which is a fundamentnal difference from
  * isolate_lru_pages (which is called without a stable reference).
  *
- * The returned page will have PageLru() cleared, and PageActive set,
- * if it was found on the active list. This flag generally will need to be
- * cleared by the caller before letting the page go.
+ * The returned page will have the PageLru() cleared, and the PageActive or
+ * PageNoreclaim will be set, if it was found on the active or noreclaim list,
+ * respectively. This flag generally will need to be cleared by the caller
+ * before letting the page go.
  *
  * The vmstat page counts corresponding to the list on which the page was
  * found will be decremented.
@@ -843,6 +870,8 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			if (PageActive(page))
 				del_page_from_active_list(zone, page);
+			else if (PageNoreclaim(page))
+				del_page_from_noreclaim_list(zone, page);
 			else
 				del_page_from_inactive_list(zone, page);
 		}
@@ -933,14 +962,21 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			add_page_to_lru_list(zone, page, PageActive(page));
+			if (PageActive(page)) {
+				VM_BUG_ON(PageNoreclaim(page));
+				add_page_to_active_list(zone, page);
+			} else if (PageNoreclaim(page)) {
+				VM_BUG_ON(PageActive(page));
+				add_page_to_noreclaim_list(zone, page);
+			} else
+				add_page_to_inactive_list(zone, page);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
 				spin_lock_irq(&zone->lru_lock);
 			}
 		}
-  	} while (nr_scanned < max_scan);
+	} while (nr_scanned < max_scan);
 	spin_unlock(&zone->lru_lock);
 done:
 	local_irq_enable();
@@ -998,7 +1034,7 @@ static void shrink_active_list(unsigned 
 	int reclaim_mapped = 0;
 	enum lru_list l;
 
-	for_each_lru(l)
+	for_each_lru(l)				/* includes '_NORECLAIM */
 		INIT_LIST_HEAD(&list[l]);
 
 	if (sc->may_swap) {
@@ -1102,6 +1138,14 @@ force_reclaim_mapped:
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+		if (!page_reclaimable(page, NULL)) {
+			/*
+			 * divert any non-reclaimable pages onto the
+			 * noreclaim list
+			 */
+			list_add(&page->lru, &list[LRU_NORECLAIM]);
+			continue;
+		}
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
@@ -1169,6 +1213,30 @@ force_reclaim_mapped:
 	}
 	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 
+#ifdef CONFIG_NORECLAIM
+	pgmoved = 0;
+	while (!list_empty(&list[LRU_NORECLAIM])) {
+		page = lru_to_page(&list[LRU_NORECLAIM]);
+		prefetchw_prev_lru_page(page, &list[LRU_NORECLAIM], flags);
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(!PageActive(page));
+		ClearPageActive(page);
+		VM_BUG_ON(PageNoreclaim(page));
+		SetPageNoreclaim(page);
+		list_move(&page->lru, &zone->list[LRU_NORECLAIM]);
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
@@ -1203,7 +1271,7 @@ static unsigned long shrink_zone(int pri
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	for_each_lru(l) {
+	for_each_reclaimable_lru(l) {
 		zone->nr_scan[l] += (zone_page_state(zone, NR_INACTIVE + l)
 							>> priority) + 1;
 		nr[l] = zone->nr_scan[l];
@@ -1214,7 +1282,7 @@ static unsigned long shrink_zone(int pri
 	}
 
 	while (nr[LRU_ACTIVE] || nr[LRU_INACTIVE]) {
-		for_each_lru(l) {
+		for_each_reclaimable_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
@@ -1748,7 +1816,7 @@ static unsigned long shrink_all_zones(un
 		if (zone->all_unreclaimable && prio != DEF_PRIORITY)
 			continue;
 
-		for_each_lru(l) {
+		for_each_reclaimable_lru(l) {
 			/* For pass = 0 we don't shrink the active list */
 			if (pass == 0 && l == LRU_ACTIVE)
 				continue;
@@ -2084,3 +2152,58 @@ int zone_reclaim(struct zone *zone, gfp_
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
+
+	VM_BUG_ON(PageNoreclaim(page));
+
+	/* TODO:  test page [!]reclaimable conditions */
+
+	return 1;
+}
+
+/*
+ * putback_all_noreclaim_pages()
+ *
+ * A really big hammer:  put back all pages on each zone's noreclaim list
+ * to the zone's active list to give vmscan a chance to re-evaluate the
+ * reclaimability of the pages.  This occurs when, e.g., we have
+ * unswappable pages on the noreclaim lists, and we add swap to the
+ * system.
+//TODO:  or as a last resort under extreme memory pressure--before OOM?
+ */
+void putback_all_noreclaim_pages(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		spin_lock(&zone->lru_lock);
+
+		list_splice(&zone->list[LRU_NORECLAIM],
+				&zone->list[LRU_ACTIVE]);
+		INIT_LIST_HEAD(&zone->list[LRU_NORECLAIM]);
+
+		zone_page_state_add(zone_page_state(zone, NR_NORECLAIM), zone,
+								NR_ACTIVE);
+		atomic_long_set(&zone->vm_stat[NR_NORECLAIM], 0);
+
+		spin_unlock(&zone->lru_lock);
+	}
+}
+#endif
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-09-14 10:21:48.000000000 -0400
@@ -1831,7 +1831,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		md->active++;
 
 	if (PageWriteback(page))
Index: Linux/mm/memcontrol.c
===================================================================
--- Linux.orig/mm/memcontrol.c	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/memcontrol.c	2007-09-14 10:21:48.000000000 -0400
@@ -242,7 +242,11 @@ unsigned long mem_container_isolate_page
 		else
 			continue;
 
-		if (__isolate_lru_page(page, mode) == 0) {
+//TODO:  for now, don't isolate non-reclaimable pages.  When/if
+// mem controller supports a noreclaim list, we'll need to make
+// at least ISOLATE_ACTIVE visible outside of vm_scan and pass
+// the 'take_nonreclaimable' flag accordingly.
+		if (__isolate_lru_page(page, mode, 0) == 0) {
 			list_move(&page->lru, dst);
 			nr_taken++;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
