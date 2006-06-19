Subject: [RFC][PATCH] inactive_clean
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Mon, 19 Jun 2006 14:20:06 +0200
Message-Id: <1150719606.28517.83.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Another (complementary) approach to avoiding the VM deadlock.

Nick's comment on that anonymous pages could be clean was of course
correct, and I smacked my head for not realising it sooner.

My previous efforts at tracking dirty pages focused on shared pages.
But shared pages are not all and, quite often even a small part of the
problem. Most 'normal' workloads are dominated by anonymous pages.

So, in order to guarantee easily freeable pages we also have to look
at anonymous memory. Thinking about it I arrived at something Rik
invented long ago: the inactive_clean list - a third LRU list consisting
of clean pages.

The thing I like least about the current impl. is that all clean pages
are unmapped; I'd like to have them mapped but read-only and trap the
write faults (next step?).

Also, setting the clean watermarks needs more thought.

Comments?

NOTE: this patch alone also makes my mad shared mmap write program
finish to completion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_inline.h  |   23 +++++++++
 include/linux/mmzone.h     |    3 +
 include/linux/page-flags.h |    6 ++
 include/linux/swap.h       |    1 
 mm/page_alloc.c            |   27 ++++++++++-
 mm/swap.c                  |   44 ++++++++++--------
 mm/swapfile.c              |    4 -
 mm/vmscan.c                |  108 ++++++++++++++++++++++++++++++++++++++-------
 8 files changed, 176 insertions(+), 40 deletions(-)

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/include/linux/swap.h	2006-06-19 14:09:16.000000000 +0200
@@ -165,7 +165,6 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
-extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/mm/swapfile.c	2006-06-19 14:09:16.000000000 +0200
@@ -496,7 +496,7 @@ static void unuse_pte(struct vm_area_str
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
 	 */
-	activate_page(page);
+	mark_page_accessed(page);
 }
 
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
@@ -598,7 +598,7 @@ static int unuse_mm(struct mm_struct *mm
 		 * Activate page so shrink_cache is unlikely to unmap its
 		 * ptes while lock is dropped, so swapoff can make progress.
 		 */
-		activate_page(page);
+		mark_page_accessed(page);
 		unlock_page(page);
 		down_read(&mm->mmap_sem);
 		lock_page(page);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-06-19 14:09:16.000000000 +0200
@@ -97,37 +97,45 @@ int rotate_reclaimable_page(struct page 
 }
 
 /*
- * FIXME: speed this up?
- */
-void fastcall activate_page(struct page *page)
-{
-	struct zone *zone = page_zone(page);
-
-	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
-		SetPageActive(page);
-		add_page_to_active_list(zone, page);
-		inc_page_state(pgactivate);
-	}
-	spin_unlock_irq(&zone->lru_lock);
-}
-
-/*
  * Mark a page as having seen activity.
  *
+ * clean -> inactive
+ *
  * inactive,unreferenced	->	inactive,referenced
  * inactive,referenced		->	active,unreferenced
  * active,unreferenced		->	active,referenced
+ *
+ * FIXME: speed this up?
  */
 void fastcall mark_page_accessed(struct page *page)
 {
+	struct zone *zone = NULL;
+	if (PageClean(page) && PageLRU(page)) {
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		if (PageClean(page) && PageLRU(page)) {
+			del_page_from_clean_list(zone, page);
+			ClearPageClean(page);
+			add_page_to_inactive_list(zone, page);
+		}
+	}
 	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
-		activate_page(page);
+		if (!zone) {
+			zone = page_zone(page);
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (PageLRU(page) && !PageActive(page)) {
+			del_page_from_inactive_list(zone, page);
+			SetPageActive(page);
+			add_page_to_active_list(zone, page);
+			inc_page_state(pgactivate);
+		}
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
 }
 
 EXPORT_SYMBOL(mark_page_accessed);
Index: linux-2.6/include/linux/mm_inline.h
===================================================================
--- linux-2.6.orig/include/linux/mm_inline.h	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/include/linux/mm_inline.h	2006-06-19 14:09:16.000000000 +0200
@@ -14,6 +14,13 @@ add_page_to_inactive_list(struct zone *z
 }
 
 static inline void
+add_page_to_clean_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->clean_list);
+	zone->nr_clean++;
+}
+
+static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
@@ -27,6 +34,17 @@ del_page_from_inactive_list(struct zone 
 	zone->nr_inactive--;
 }
 
+void wakeup_kswapd(struct zone *zone, int order);
+
+static inline void
+del_page_from_clean_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_clean--;
+	if (zone->nr_clean + zone->free_pages < zone->clean_low)
+		wakeup_kswapd(zone, 0);
+}
+
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
@@ -34,6 +52,11 @@ del_page_from_lru(struct zone *zone, str
 	if (PageActive(page)) {
 		__ClearPageActive(page);
 		zone->nr_active--;
+	} else if (PageClean(page)) {
+		__ClearPageClean(page);
+		zone->nr_clean--;
+		if (zone->nr_clean + zone->free_pages < zone->clean_low)
+			wakeup_kswapd(zone, 0);
 	} else {
 		zone->nr_inactive--;
 	}
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/include/linux/mmzone.h	2006-06-19 14:09:16.000000000 +0200
@@ -156,10 +156,13 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
 	struct list_head	inactive_list;
+	struct list_head	clean_list;
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
+	unsigned long		nr_clean;
+	unsigned long		clean_low, clean_high;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/include/linux/page-flags.h	2006-06-19 14:09:16.000000000 +0200
@@ -89,6 +89,7 @@
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_clean		21	/* Page is on the clean list */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -360,6 +361,11 @@ extern void __mod_page_state_offset(unsi
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageClean(page)		test_bit(PG_clean, &(page)->flags)
+#define SetPageClean(page)	set_bit(PG_clean, &(page)->flags)
+#define ClearPageClean(page)	clear_bit(PG_clean, &(page)->flags)
+#define __ClearPageClean(page)	__clear_bit(PG_clean, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-06-19 14:09:16.000000000 +0200
@@ -154,7 +154,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+		        1 << PG_clean );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -384,7 +385,8 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_clean ))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -533,7 +535,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_clean ))))
 		bad_page(page);
 
 	/*
@@ -1461,6 +1464,9 @@ void show_free_areas(void)
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
+			" clean: %lukB"
+			" low: %lukB"
+			" high: %lukB"
 			" active:%lukB"
 			" inactive:%lukB"
 			" present:%lukB"
@@ -1472,6 +1478,9 @@ void show_free_areas(void)
 			K(zone->pages_min),
 			K(zone->pages_low),
 			K(zone->pages_high),
+			K(zone->nr_clean),
+			K(zone->clean_low),
+			K(zone->clean_high),
 			K(zone->nr_active),
 			K(zone->nr_inactive),
 			K(zone->present_pages),
@@ -2102,10 +2111,12 @@ static void __init free_area_init_core(s
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
+		INIT_LIST_HEAD(&zone->clean_list);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+		zone->nr_clean = 0;
 		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
 			continue;
@@ -2261,6 +2272,9 @@ static int zoneinfo_show(struct seq_file
 			   "\n        min      %lu"
 			   "\n        low      %lu"
 			   "\n        high     %lu"
+			   "\n        clean    %lu"
+			   "\n        low      %lu"
+			   "\n        high     %lu"
 			   "\n        active   %lu"
 			   "\n        inactive %lu"
 			   "\n        scanned  %lu (a: %lu i: %lu)"
@@ -2270,6 +2284,9 @@ static int zoneinfo_show(struct seq_file
 			   zone->pages_min,
 			   zone->pages_low,
 			   zone->pages_high,
+			   zone->nr_clean,
+			   zone->clean_low,
+			   zone->clean_high,
 			   zone->nr_active,
 			   zone->nr_inactive,
 			   zone->pages_scanned,
@@ -2609,6 +2626,10 @@ void setup_per_zone_pages_min(void)
 
 		zone->pages_low   = zone->pages_min + (tmp >> 2);
 		zone->pages_high  = zone->pages_min + (tmp >> 1);
+
+		zone->clean_low   = zone->pages_low  << 3;
+		zone->clean_high  = zone->pages_high << 3;
+
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-06-19 14:09:02.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-06-19 14:09:16.000000000 +0200
@@ -532,8 +532,8 @@ static unsigned long shrink_page_list(st
 				goto free_it;
 		}
 
-		if (!remove_mapping(mapping, page))
-			goto keep_locked;
+		SetPageClean(page);
+		goto keep_locked;
 
 free_it:
 		unlock_page(page);
@@ -610,12 +610,14 @@ static unsigned long isolate_lru_pages(u
 	return nr_taken;
 }
 
-/*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
- * of reclaimed pages
- */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+typedef unsigned long (*shrink_func_t)(struct list_head *,
+		struct scan_control *);
+
+static unsigned long shrink_list(unsigned long max_scan,
+				struct zone *zone, struct scan_control *sc,
+				struct list_head *src_list,
+				unsigned long *src_count,
+			       	shrink_func_t shrink_func)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -633,14 +635,13 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
-					     &page_list, &nr_scan);
-		zone->nr_inactive -= nr_taken;
+				src_list, &page_list, &nr_scan);
+		*src_count -= nr_taken;
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc);
+		nr_freed = shrink_func(&page_list, sc);
 		nr_reclaimed += nr_freed;
 		local_irq_disable();
 		if (current_is_kswapd()) {
@@ -664,6 +665,8 @@ static unsigned long shrink_inactive_lis
 			list_del(&page->lru);
 			if (PageActive(page))
 				add_page_to_active_list(zone, page);
+			else if (PageClean(page))
+				add_page_to_clean_list(zone, page);
 			else
 				add_page_to_inactive_list(zone, page);
 			if (!pagevec_add(&pvec, page)) {
@@ -672,7 +675,7 @@ static unsigned long shrink_inactive_lis
 				spin_lock_irq(&zone->lru_lock);
 			}
 		}
-  	} while (nr_scanned < max_scan);
+	} while (nr_scanned < max_scan);
 	spin_unlock(&zone->lru_lock);
 done:
 	local_irq_enable();
@@ -681,6 +684,17 @@ done:
 }
 
 /*
+ * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
+ * of reclaimed pages
+ */
+static inline unsigned long shrink_inactive_list(unsigned long max_scan,
+		struct zone *zone, struct scan_control *sc)
+{
+	return shrink_list(max_scan, zone, sc, &zone->inactive_list,
+			&zone->nr_inactive, shrink_page_list);
+}
+
+/*
  * This moves pages from the active list to the inactive list.
  *
  * We move them the other way if the page is referenced by one or more
@@ -833,6 +847,59 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
+static unsigned long shrink_clean_page_list(struct list_head *page_list,
+		struct scan_control *sc)
+{
+	LIST_HEAD(ret_pages);
+	struct pagevec freed_pvec;
+	unsigned long nr_reclaimed = 0;
+
+	pagevec_init(&freed_pvec, 1);
+	while (!list_empty(page_list)) {
+		struct address_space *mapping;
+		struct page *page;
+
+		cond_resched();
+
+		page = lru_to_page(page_list);
+		prefetchw_prev_lru_page(page, page_list, flags);
+
+		list_del(&page->lru);
+
+		if (TestSetPageLocked(page))
+			goto keep;
+
+		mapping = page_mapping(page);
+
+		if (!remove_mapping(mapping, page))
+			goto keep_locked;
+
+		ClearPageClean(page);
+		unlock_page(page);
+		nr_reclaimed++;
+		if (!pagevec_add(&freed_pvec, page))
+			__pagevec_release_nonlru(&freed_pvec);
+		continue;
+
+keep_locked:
+		ClearPageClean(page);
+		unlock_page(page);
+keep:
+		list_add(&page->lru, &ret_pages);
+	}
+	list_splice(&ret_pages, page_list);
+	if (pagevec_count(&freed_pvec))
+		__pagevec_release_nonlru(&freed_pvec);
+	return nr_reclaimed;
+}
+
+static inline unsigned long shrink_clean_list(unsigned long max_scan,
+		struct zone *zone, struct scan_control *sc)
+{
+	return shrink_list(max_scan, zone, sc, &zone->clean_list,
+			&zone->nr_clean, shrink_clean_page_list);
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -846,6 +913,13 @@ static unsigned long shrink_zone(int pri
 
 	atomic_inc(&zone->reclaim_in_progress);
 
+	if (!priority || zone->nr_clean + zone->free_pages > zone->clean_high)
+		nr_reclaimed +=
+			shrink_clean_list(sc->swap_cluster_max, zone, sc);
+
+	if (nr_reclaimed && zone->nr_clean > zone->clean_high)
+		goto done;
+
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
@@ -883,6 +957,7 @@ static unsigned long shrink_zone(int pri
 
 	throttle_vm_writeout();
 
+done:
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;
 }
@@ -968,7 +1043,7 @@ unsigned long try_to_free_pages(struct z
 			continue;
 
 		zone->temp_priority = DEF_PRIORITY;
-		lru_pages += zone->nr_active + zone->nr_inactive;
+		lru_pages += zone->nr_active + zone->nr_inactive + zone->nr_clean;
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -1111,7 +1186,7 @@ scan:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone->nr_active + zone->nr_inactive;
+			lru_pages += zone->nr_active + zone->nr_inactive + zone->nr_clean;
 		}
 
 		/*
@@ -1277,7 +1352,8 @@ void wakeup_kswapd(struct zone *zone, in
 		return;
 
 	pgdat = zone->zone_pgdat;
-	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0))
+	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0) &&
+			zone->nr_clean + zone->free_pages > zone->clean_high)
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
