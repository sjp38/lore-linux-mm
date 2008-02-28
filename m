Message-Id: <20080228192929.031646681@redhat.com>
References: <20080228192908.126720629@redhat.com>
Date: Thu, 28 Feb 2008 14:29:20 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 12/21] No Reclaim LRU Infrastructure
Content-Disposition: inline; filename=noreclaim-01.1-no-reclaim-infrastructure.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V1 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series
+ define NR_NORECLAIM and LRU_NORECLAIM to avoid errors when not
  configured.

V1 -> V2:
+  handle review comments -- various typos and errors.
+  extract "putback_all_noreclaim_pages()" into a separate patch
   and rework as "scan_all_zones_noreclaim_pages().

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

3.  TODO:  Memory Controllers maintain separate active and inactive lists.
    Need to consider whether they should also maintain a noreclaim list.  
    Also, convert to use Christoph's array of indexed lru variables?

    See //TODO note in mm/memcontrol.c re:  isolating non-reclaimable
    pages. 

4.  TODO:  more factoring of lru list handling.  But, I want to get this
    as close to functionally correct as possible before introducing those
    perturbations.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.25-rc2-mm1/mm/Kconfig
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/Kconfig	2008-02-19 16:23:09.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/Kconfig	2008-02-28 11:05:04.000000000 -0500
@@ -193,3 +193,13 @@ config NR_QUICK
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
Index: linux-2.6.25-rc2-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/page-flags.h	2008-02-28 00:26:04.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/page-flags.h	2008-02-28 12:18:48.000000000 -0500
@@ -107,6 +107,8 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+
+#define PG_noreclaim		30	/* Page is "non-reclaimable"  */
 #endif
 
 /*
@@ -196,6 +198,7 @@ static inline void SetPageUptodate(struc
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
+#define TestClearPageActive(page) test_and_clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
@@ -297,6 +300,21 @@ static inline void __ClearPageTail(struc
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
Index: linux-2.6.25-rc2-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/mmzone.h	2008-02-28 00:29:40.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/mmzone.h	2008-02-28 11:45:14.000000000 -0500
@@ -84,6 +84,11 @@ enum zone_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "           */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "           */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "           */
+#ifdef CONFIG_NORECLAIM
+	NR_NORECLAIM,	/*  "     "     "   "       "         */
+#else
+	NR_NORECLAIM=NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -122,10 +127,18 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-	NR_LRU_LISTS };
+#ifdef CONFIG_NORECLAIM
+	LRU_NORECLAIM,
+#else
+	LRU_NORECLAIM=LRU_ACTIVE_FILE,	/* avoid compiler errors in dead code */
+#endif
+	NR_LRU_LISTS
+};
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+#define for_each_reclaimable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+
 static inline int is_file_lru(enum lru_list l)
 {
 	if (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE)
@@ -140,6 +153,15 @@ static inline int is_active_lru(enum lru
 	return 0;
 }
 
+static inline int is_noreclaim_lru(enum lru_list l)
+{
+#ifdef CONFIG_NORECLAIM
+	if (l == LRU_NORECLAIM)
+		return 1;
+#endif
+	return 0;
+}
+
 enum lru_list page_lru(struct page *page);
 
 struct per_cpu_pages {
Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c	2008-02-28 00:29:40.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/page_alloc.c	2008-02-28 11:05:04.000000000 -0500
@@ -248,6 +248,9 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -482,6 +485,9 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim |
+#endif
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -629,6 +635,9 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
Index: linux-2.6.25-rc2-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/mm_inline.h	2008-02-28 00:29:35.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/mm_inline.h	2008-02-28 12:20:07.000000000 -0500
@@ -81,17 +81,42 @@ del_page_from_active_file_list(struct zo
 	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
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
 	enum lru_list l = LRU_INACTIVE_ANON;
 
 	list_del(&page->lru);
-	if (PageActive(page)) {
-		__ClearPageActive(page);
-		l += LRU_ACTIVE;
+	if (PageNoreclaim(page)) {
+		__ClearPageNoreclaim(page);
+		l = LRU_NORECLAIM;
+	} else {
+		 if (PageActive(page)) {
+			__ClearPageActive(page);
+			l += LRU_ACTIVE;
+		}
+		l += page_file_cache(page);
 	}
-	l += page_file_cache(page);
 	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
Index: linux-2.6.25-rc2-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/swap.h	2008-02-28 00:27:06.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/swap.h	2008-02-28 12:05:42.000000000 -0500
@@ -173,6 +173,8 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
+extern void lru_cache_add_active_or_noreclaim(struct page *,
+					struct vm_area_struct *);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
@@ -204,6 +206,18 @@ static inline void lru_cache_add_active_
 	__lru_cache_add(page, LRU_ACTIVE_FILE);
 }
 
+#ifdef CONFIG_NORECLAIM
+static inline void lru_cache_add_noreclaim(struct page *page)
+{
+	__lru_cache_add(page, LRU_NORECLAIM);
+}
+#else
+static inline void lru_cache_add_noreclaim(struct page *page)
+{
+	BUG("Noreclaim not configured, but page added anyway?!");
+}
+#endif
+
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zone **zones, int order,
 					gfp_t gfp_mask);
@@ -228,6 +242,16 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM
+extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+#else
+static inline int page_reclaimable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return 1;
+}
+#endif
+
 extern int kswapd_run(int nid);
 
 #ifdef CONFIG_MMU
Index: linux-2.6.25-rc2-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/pagevec.h	2008-02-28 00:27:06.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/pagevec.h	2008-02-28 11:54:34.000000000 -0500
@@ -101,6 +101,12 @@ static inline void __pagevec_lru_add_act
 	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
 }
 
+#ifdef CONFIG_NORECLAIM
+static inline void __pagevec_lru_add_noreclaim(struct pagevec *pvec)
+{
+	____pagevec_lru_add(pvec, LRU_NORECLAIM);
+}
+#endif
 
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
Index: linux-2.6.25-rc2-mm1/mm/swap.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/swap.c	2008-02-28 00:29:40.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/swap.c	2008-02-28 12:21:42.000000000 -0500
@@ -103,9 +103,13 @@ enum lru_list page_lru(struct page *page
 {
 	enum lru_list lru = LRU_BASE;
 
-	if (PageActive(page))
-		lru += LRU_ACTIVE;
-	lru += page_file_cache(page);
+	if (PageNoreclaim(page))
+		lru = LRU_NORECLAIM;
+	else {
+		if (PageActive(page))
+			lru += LRU_ACTIVE;
+		lru += page_file_cache(page);
+	}
 
 	return lru;
 }
@@ -130,7 +134,8 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page)) {
+	 	if (PageLRU(page) && !PageActive(page) &&
+					!PageNoreclaim(page)) {
 			if (page_file_cache(page)) {
 				list_move_tail(&page->lru,
 						&zone->list[LRU_INACTIVE_FILE]);
@@ -164,7 +169,7 @@ int rotate_reclaimable_page(struct page 
 		return 1;
 	if (PageDirty(page))
 		return 1;
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		return 1;
 	if (!PageLRU(page))
 		return 1;
@@ -190,7 +195,7 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
+	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
 		int file = page_file_cache(page);
 		int lru = LRU_BASE + file;
 		del_page_from_lru_list(zone, page, lru);
@@ -222,7 +227,8 @@ void activate_page(struct page *page)
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && !PageNoreclaim(page) &&
+			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
@@ -245,13 +251,29 @@ void __lru_cache_add(struct page *page, 
 void lru_cache_add_lru(struct page *page, enum lru_list lru)
 {
 	if (PageActive(page)) {
+		VM_BUG_ON(PageNoreclaim(page));
 		ClearPageActive(page);
+	} else if (PageNoreclaim(page)) {
+		VM_BUG_ON(PageActive(page));
+		ClearPageNoreclaim(page);
 	}
 
-	VM_BUG_ON(PageLRU(page) || PageActive(page));
+	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageNoreclaim(page));
 	__lru_cache_add(page, lru);
 }
 
+void lru_cache_add_active_or_noreclaim(struct page *page,
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
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -349,6 +371,8 @@ void release_pages(struct page **pages, 
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+			int is_lru_page;
+
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irqrestore(&zone->lru_lock,
@@ -356,8 +380,10 @@ void release_pages(struct page **pages, 
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
 
@@ -436,10 +462,13 @@ void ____pagevec_lru_add(struct pagevec 
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
+		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		if (is_active_lru(lru))
 			SetPageActive(page);
+		else if (is_noreclaim_lru(lru))
+			SetPageNoreclaim(page);
 		add_page_to_lru_list(zone, page, lru);
 	}
 	if (zone)
Index: linux-2.6.25-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/migrate.c	2008-02-28 00:26:04.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/migrate.c	2008-02-28 11:05:04.000000000 -0500
@@ -326,8 +326,11 @@ static void migrate_page_copy(struct pag
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
@@ -341,7 +344,6 @@ static void migrate_page_copy(struct pag
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
 #endif
-	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-28 00:29:55.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-28 11:05:04.000000000 -0500
@@ -480,6 +480,11 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (!page_reclaimable(page, NULL)) {
+			SetPageNoreclaim(page);
+			goto keep_locked;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -582,7 +587,7 @@ static unsigned long shrink_page_list(st
 		 * possible for a page to have PageDirty set, but it is actually
 		 * clean (all its buffers are clean).  This happens if the
 		 * buffers were written out directly, with submit_bh(). ext3
-		 * will do this, as well as the blockdev mapping. 
+		 * will do this, as well as the blockdev mapping.
 		 * try_to_release_page() will discover that cleanness and will
 		 * drop the buffers and mark the page clean - it can be freed.
 		 *
@@ -614,6 +619,7 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			remove_exclusive_swap_page(page);
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -664,6 +670,14 @@ int __isolate_lru_page(struct page *page
 	if (mode != ISOLATE_BOTH && (!page_file_cache(page) != !file))
 		return ret;
 
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
@@ -775,7 +789,7 @@ static unsigned long isolate_lru_pages(u
 				/* else it is being freed elsewhere */
 				list_move(&cursor_page->lru, src);
 			default:
-				break;
+				break;	/* ! on LRU or wrong list */
 			}
 		}
 	}
@@ -831,9 +845,10 @@ static unsigned long clear_active_flags(
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
@@ -857,7 +872,13 @@ int isolate_lru_page(struct page *page)
 			ret = 0;
 			ClearPageLRU(page);
 
+			/* Calculate the LRU list for normal pages ... */
 			lru += page_file_cache(page) + !!PageActive(page);
+
+			/* ... except NoReclaim, which has its own list. */
+			if (PageNoreclaim(page))
+				lru = LRU_NORECLAIM;
+
 			del_page_from_lru_list(zone, page, lru);
 		}
 		spin_unlock_irq(&zone->lru_lock);
@@ -974,16 +995,21 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (page_file_cache(page))
-				lru += LRU_FILE;
-			if (scan_global_lru(sc)) {
+			if (PageNoreclaim(page)) {
+				VM_BUG_ON(PageActive(page));
+				lru = LRU_NORECLAIM;
+			} else {
 				if (page_file_cache(page))
-					zone->recent_rotated_file++;
-				else
-					zone->recent_rotated_anon++;
+					lru += LRU_FILE;
+				if (scan_global_lru(sc)) {
+					if (page_file_cache(page))
+						zone->recent_rotated_file++;
+					else
+						zone->recent_rotated_anon++;
+				}
+				if (PageActive(page))
+					lru += LRU_ACTIVE;
 			}
-			if (PageActive(page))
-				lru += LRU_ACTIVE;
 			add_page_to_lru_list(zone, page, lru);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1082,6 +1108,13 @@ static void shrink_active_list(unsigned 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+
+		if (!page_reclaimable(page, NULL)) {
+			/* Non-reclaimable pages go onto their own list. */
+			list_add(&page->lru, &list[LRU_NORECLAIM]);
+			continue;
+		}
+
 		if (page_referenced(page, 0, sc->mem_cgroup)) {
 			if (file)
 				/* Referenced file pages stay active. */
@@ -1168,6 +1201,33 @@ static void shrink_active_list(unsigned 
 		zone->recent_rotated_anon += pgmoved;
 	}
 
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
@@ -1284,7 +1344,7 @@ static unsigned long shrink_zone(int pri
 
 	get_scan_ratio(zone, sc, percent);
 
-	for_each_lru(l) {
+	for_each_reclaimable_lru(l) {
 		if (scan_global_lru(sc)) {
 			int file = is_file_lru(l);
 			int scan;
@@ -1315,7 +1375,7 @@ static unsigned long shrink_zone(int pri
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-		for_each_lru(l) {
+		for_each_reclaimable_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
@@ -1871,8 +1931,8 @@ static unsigned long shrink_all_zones(un
 		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
-		for_each_lru(l) {
-			/* For pass = 0 we don't shrink the active list */
+		for_each_reclaimable_lru(l) {
+			/* For pass = 0, we don't shrink the active list */
 			if (pass == 0 &&
 				(l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE))
 				continue;
@@ -2210,3 +2270,29 @@ int zone_reclaim(struct zone *zone, gfp_
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
+#endif
Index: linux-2.6.25-rc2-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/mempolicy.c	2008-02-25 17:10:54.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/mempolicy.c	2008-02-28 11:05:04.000000000 -0500
@@ -1922,7 +1922,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		md->active++;
 
 	if (PageWriteback(page))
Index: linux-2.6.25-rc2-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/memcontrol.c	2008-02-28 00:27:41.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/memcontrol.c	2008-02-28 11:05:04.000000000 -0500
@@ -519,6 +519,10 @@ unsigned long mem_cgroup_isolate_pages(u
 		scan++;
 		list_move(&pc->lru, &pc_list);
 
+//TODO:  for now, don't isolate non-reclaimable pages.  When/if
+// mem controller supports a noreclaim list, we'll need to make
+// at least ISOLATE_ACTIVE visible outside of vm_scan and pass
+// the 'take_nonreclaimable' flag accordingly.
 		if (__isolate_lru_page(page, mode, file) == 0) {
 			list_move(&page->lru, dst);
 			nr_taken++;

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
