Message-Id: <20080428181853.215965233@redhat.com>
References: <20080428181835.502876582@redhat.com>
Date: Mon, 28 Apr 2008 14:18:47 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 12/15] No Reclaim LRU Infrastructure
Content-Disposition: inline; filename=rvr-11-lts-noreclaim-lru-infrastructure.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lee.schermerhorn@hp.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V3 -> V6:
+ remove lru_cache_add_active_or_noreclaim().  Only used by
  optional patch to cull nonreclaimable pages in fault path.
  Will add back to that patch.
+ misc cleanup pointed out by review of V5

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
[CONFIG_]NORECLAIM_LRU.

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

    Thus, NORECLAIM_LRU currently depends on [CONFIG_]64BIT.

!!! We will need to revisit this if/when Christoph Lameter's page
    flag cleanup goes in.

2.  The pagevec to move pages to the noreclaim list results in another
    loop at the end of shrink_active_list().  If we ultimately adopt Rik
    van Riel's split lru approach, I think we'll need to find a way to
    factor all of these loops into some common code.

3.  TODO:  Memory Controllers maintain separate active and inactive lists,
    now split for anon and file pages.
    Need to consider whether they should also maintain a noreclaim list.  

4.  TODO:  more factoring of lru list handling?  But, I want to get this
    as close to functionally correct as possible before introducing those
    perturbations.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm_inline.h  |   33 +++++++++++-
 include/linux/mmzone.h     |   24 +++++++++
 include/linux/page-flags.h |   17 ++++++
 include/linux/pagevec.h    |    6 ++
 include/linux/swap.h       |   22 ++++++++
 mm/Kconfig                 |   10 +++
 mm/mempolicy.c             |    2 
 mm/migrate.c               |    6 +-
 mm/page_alloc.c            |    9 +++
 mm/swap.c                  |   30 ++++++++---
 mm/vmscan.c                |  115 ++++++++++++++++++++++++++++++++++++++-------
 11 files changed, 242 insertions(+), 32 deletions(-)

Index: linux-2.6.25-mm1/mm/Kconfig
===================================================================
--- linux-2.6.25-mm1.orig/mm/Kconfig	2008-04-22 10:33:45.000000000 -0400
+++ linux-2.6.25-mm1/mm/Kconfig	2008-04-24 12:03:54.000000000 -0400
@@ -205,3 +205,13 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config NORECLAIM_LRU
+	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL, 64BIT only)"
+	depends on EXPERIMENTAL && 64BIT
+	help
+	  Supports tracking of non-reclaimable pages off the [in]active lists
+	  to avoid excessive reclaim overhead on large memory systems.  Pages
+	  may be non-reclaimable because:  they are locked into memory, they
+	  are anonymous pages for which no swap space exists, or they are anon
+	  pages that are expensive to unmap [long anon_vma "related vma" list.]
Index: linux-2.6.25-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/page-flags.h	2008-04-24 12:00:01.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/page-flags.h	2008-04-24 12:03:54.000000000 -0400
@@ -94,6 +94,9 @@ enum pageflags {
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
+#ifdef CONFIG_NORECLAIM_LRU
+	PG_noreclaim,		/* Page is "non-reclaimable"  */
+#endif
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
@@ -155,6 +158,7 @@ PAGEFLAG(Referenced, referenced) TESTCLE
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
+	TESTCLEARFLAG(Active, active)
 __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, owner_priv_1)		/* Used by some filesystems */
 PAGEFLAG(Pinned, owner_priv_1) TESTSCFLAG(Pinned, owner_priv_1) /* Xen */
@@ -191,6 +195,17 @@ PAGEFLAG(SwapCache, swapcache)
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
+#ifdef CONFIG_NORECLAIM_LRU
+PAGEFLAG(Noreclaim, noreclaim) __CLEARPAGEFLAG(Noreclaim, noreclaim)
+TESTCLEARFLAG(Noreclaim, noreclaim)
+#else
+PAGEFLAG_FALSE(Noreclaim)
+#define SetPageNoreclaim(page)
+#define ClearPageNoreclaim(page)
+#define __ClearPageNoreclaim(page)
+#define TestClearPageNoreclaim(page) 0
+#endif
+
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 PAGEFLAG(Uncached, uncached)
 #else
Index: linux-2.6.25-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/mmzone.h	2008-04-24 12:03:40.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/mmzone.h	2008-04-24 12:03:54.000000000 -0400
@@ -85,6 +85,11 @@ enum zone_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "           */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "           */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "           */
+#ifdef CONFIG_NORECLAIM_LRU
+	NR_NORECLAIM,	/*  "     "     "   "       "         */
+#else
+	NR_NORECLAIM = NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -124,10 +129,18 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-	NR_LRU_LISTS };
+#ifdef CONFIG_NORECLAIM_LRU
+	LRU_NORECLAIM,
+#else
+	LRU_NORECLAIM = LRU_ACTIVE_FILE, /* avoid compiler errors in dead code */
+#endif
+	NR_LRU_LISTS
+};
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+#define for_each_reclaimable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+
 static inline int is_file_lru(enum lru_list l)
 {
 	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE);
@@ -138,6 +151,15 @@ static inline int is_active_lru(enum lru
 	return (l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE);
 }
 
+static inline int is_noreclaim_lru(enum lru_list l)
+{
+#ifdef CONFIG_NORECLAIM_LRU
+	return (l == LRU_NORECLAIM);
+#else
+	return 0;
+#endif
+}
+
 enum lru_list page_lru(struct page *page);
 
 struct per_cpu_pages {
Index: linux-2.6.25-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/page_alloc.c	2008-04-24 12:03:40.000000000 -0400
+++ linux-2.6.25-mm1/mm/page_alloc.c	2008-04-24 12:03:54.000000000 -0400
@@ -256,6 +256,9 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM_LRU
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -491,6 +494,9 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+#ifdef CONFIG_NORECLAIM_LRU
+			1 << PG_noreclaim |
+#endif
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -642,6 +648,9 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_NORECLAIM_LRU
+			1 << PG_noreclaim	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
Index: linux-2.6.25-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/mm_inline.h	2008-04-24 12:03:35.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/mm_inline.h	2008-04-24 12:03:54.000000000 -0400
@@ -83,17 +83,42 @@ del_page_from_active_file_list(struct zo
 	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
 }
 
+#ifdef CONFIG_NORECLAIM_LRU
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
 
Index: linux-2.6.25-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/swap.h	2008-04-24 12:01:36.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/swap.h	2008-04-24 12:03:54.000000000 -0400
@@ -204,6 +204,18 @@ static inline void lru_cache_add_active_
 	__lru_cache_add(page, LRU_ACTIVE_FILE);
 }
 
+#ifdef CONFIG_NORECLAIM_LRU
+static inline void lru_cache_add_noreclaim(struct page *page)
+{
+	__lru_cache_add(page, LRU_NORECLAIM);
+}
+#else
+static inline void lru_cache_add_noreclaim(struct page *page)
+{
+	BUG();
+}
+#endif
+
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
@@ -228,6 +240,16 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM_LRU
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
Index: linux-2.6.25-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/pagevec.h	2008-04-24 12:01:36.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/pagevec.h	2008-04-24 12:03:54.000000000 -0400
@@ -101,6 +101,12 @@ static inline void __pagevec_lru_add_act
 	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
 }
 
+#ifdef CONFIG_NORECLAIM_LRU
+static inline void __pagevec_lru_add_noreclaim(struct pagevec *pvec)
+{
+	____pagevec_lru_add(pvec, LRU_NORECLAIM);
+}
+#endif
 
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
Index: linux-2.6.25-mm1/mm/swap.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/swap.c	2008-04-24 12:03:40.000000000 -0400
+++ linux-2.6.25-mm1/mm/swap.c	2008-04-24 12:03:54.000000000 -0400
@@ -106,9 +106,13 @@ enum lru_list page_lru(struct page *page
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
@@ -133,7 +137,8 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page)) {
+		if (PageLRU(page) && !PageActive(page) &&
+					!PageNoreclaim(page)) {
 			int lru = page_file_cache(page);
 			list_move_tail(&page->lru, &zone->list[lru]);
 			pgmoved++;
@@ -154,7 +159,7 @@ static void pagevec_move_tail(struct pag
 void  rotate_reclaimable_page(struct page *page)
 {
 	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
-	    PageLRU(page)) {
+	    !PageNoreclaim(page) && PageLRU(page)) {
 		struct pagevec *pvec;
 		unsigned long flags;
 
@@ -175,7 +180,7 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
+	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
 		int file = page_file_cache(page);
 		int lru = LRU_BASE + file;
 		del_page_from_lru_list(zone, page, lru);
@@ -207,7 +212,8 @@ void activate_page(struct page *page)
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && !PageNoreclaim(page) &&
+			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
@@ -235,10 +241,14 @@ void __lru_cache_add(struct page *page, 
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
 
@@ -339,6 +349,7 @@ void release_pages(struct page **pages, 
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irqrestore(&zone->lru_lock,
@@ -426,10 +437,13 @@ void ____pagevec_lru_add(struct pagevec 
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
Index: linux-2.6.25-mm1/mm/migrate.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/migrate.c	2008-04-24 12:00:01.000000000 -0400
+++ linux-2.6.25-mm1/mm/migrate.c	2008-04-24 12:03:54.000000000 -0400
@@ -335,8 +335,11 @@ static void migrate_page_copy(struct pag
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
@@ -350,7 +353,6 @@ static void migrate_page_copy(struct pag
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
 #endif
-	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
Index: linux-2.6.25-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/vmscan.c	2008-04-24 12:03:49.000000000 -0400
+++ linux-2.6.25-mm1/mm/vmscan.c	2008-04-24 12:03:54.000000000 -0400
@@ -470,6 +470,11 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (!page_reclaimable(page, NULL)) {
+			SetPageNoreclaim(page);
+			goto keep_locked;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -566,7 +571,7 @@ static unsigned long shrink_page_list(st
 		 * possible for a page to have PageDirty set, but it is actually
 		 * clean (all its buffers are clean).  This happens if the
 		 * buffers were written out directly, with submit_bh(). ext3
-		 * will do this, as well as the blockdev mapping. 
+		 * will do this, as well as the blockdev mapping.
 		 * try_to_release_page() will discover that cleanness and will
 		 * drop the buffers and mark the page clean - it can be freed.
 		 *
@@ -598,6 +603,7 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			remove_exclusive_swap_page(page);
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -647,6 +653,14 @@ int __isolate_lru_page(struct page *page
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
@@ -758,7 +772,7 @@ static unsigned long isolate_lru_pages(u
 				/* else it is being freed elsewhere */
 				list_move(&cursor_page->lru, src);
 			default:
-				break;
+				break;	/* ! on LRU or wrong list */
 			}
 		}
 	}
@@ -818,8 +832,9 @@ static unsigned long clear_active_flags(
  * Returns -EBUSY if the page was not on an LRU list.
  *
  * The returned page will have PageLRU() cleared.  If it was found on
- * the active list, it will have PageActive set.  That flag may need
- * to be cleared by the caller before letting the page go.
+ * the active list, it will have PageActive set.  If it was found on
+ * the noreclaim list, it will have the PageNoreclaim bit set. That flag
+ * may need to be cleared by the caller before letting the page go.
  *
  * The vmstat statistic corresponding to the list on which the page was
  * found will be decremented.
@@ -844,7 +859,13 @@ int isolate_lru_page(struct page *page)
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
@@ -961,16 +982,21 @@ static unsigned long shrink_inactive_lis
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
@@ -1033,6 +1059,7 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
+	LIST_HEAD(l_noreclaim);
 	struct page *page;
 	struct pagevec pvec;
 	enum lru_list lru;
@@ -1064,6 +1091,13 @@ static void shrink_active_list(unsigned 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+
+		if (!page_reclaimable(page, NULL)) {
+			/* Non-reclaimable pages go onto their own list. */
+			list_add(&page->lru, &l_noreclaim);
+			continue;
+		}
+
 		if (page_referenced(page, 0, sc->mem_cgroup) && file) {
 			/* Referenced file pages stay active. */
 			list_add(&page->lru, &l_active);
@@ -1151,6 +1185,32 @@ static void shrink_active_list(unsigned 
 		zone->recent_rotated_anon += pgmoved;
 	}
 
+#ifdef CONFIG_NORECLAIM_LRU
+	pgmoved = 0;
+	while (!list_empty(&l_noreclaim)) {
+		page = lru_to_page(&l_noreclaim);
+		prefetchw_prev_lru_page(page, &l_noreclaim, flags);
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
@@ -1267,7 +1327,7 @@ static unsigned long shrink_zone(int pri
 
 	get_scan_ratio(zone, sc, percent);
 
-	for_each_lru(l) {
+	for_each_reclaimable_lru(l) {
 		if (scan_global_lru(sc)) {
 			int file = is_file_lru(l);
 			int scan;
@@ -1298,7 +1358,7 @@ static unsigned long shrink_zone(int pri
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-		for_each_lru(l) {
+		for_each_reclaimable_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
@@ -1851,8 +1911,8 @@ static unsigned long shrink_all_zones(un
 		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
-		for_each_lru(l) {
-			/* For pass = 0 we don't shrink the active list */
+		for_each_reclaimable_lru(l) {
+			/* For pass = 0, we don't shrink the active list */
 			if (pass == 0 &&
 				(l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE))
 				continue;
@@ -2190,3 +2250,26 @@ int zone_reclaim(struct zone *zone, gfp_
 	return ret;
 }
 #endif
+
+#ifdef CONFIG_NORECLAIM_LRU
+/*
+ * page_reclaimable - test whether a page is reclaimable
+ * @page: the page to test
+ * @vma: the VMA in which the page is or will be mapped, may be NULL
+ *
+ * Test whether page is reclaimable--i.e., should be placed on active/inactive
+ * lists vs noreclaim list.
+ *
+ * Reasons page might not be reclaimable:
+ * TODO - later patches
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
Index: linux-2.6.25-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/mempolicy.c	2008-04-23 17:31:13.000000000 -0400
+++ linux-2.6.25-mm1/mm/mempolicy.c	2008-04-24 12:03:54.000000000 -0400
@@ -2200,7 +2200,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageNoreclaim(page))
 		md->active++;
 
 	if (PageWriteback(page))

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
