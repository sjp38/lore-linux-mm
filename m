From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:39:52 +0200
Message-Id: <20060712143952.16998.5353.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 15/39] mm: pgrep: abstract page removal
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

API:

Remove the specified page from the page reclaim data structures.

	void __pgrep_remove(struct zone *zone, struct page *page);

NOTE: isolate_lru_page{,s}() become generic functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 include/linux/mm_page_replace.h    |    1 +
 include/linux/mm_use_once_policy.h |    9 +++++++++
 include/linux/swap.h               |    6 +++---
 mm/migrate.c                       |    5 +----
 mm/swap.c                          |    6 ++++--
 mm/useonce.c                       |    8 ++------
 mm/vmscan.c                        |   12 +++++-------
 7 files changed, 25 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:44.000000000 +0200
@@ -84,6 +84,7 @@ extern unsigned long pgrep_shrink_zone(i
 /* void pgrep_copy_state(struct page *, struct page *); */
 /* void pgrep_clear_state(struct page *); */
 /* int pgrep_is_active(struct page *); */
+/* void __pgrep_remove(struct zone *zone, struct page *page); */
 
 
 #ifdef CONFIG_MM_POLICY_USEONCE
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:44.000000000 +0200
@@ -120,5 +120,14 @@ static inline int pgrep_is_active(struct
 	return PageActive(page);
 }
 
+static inline void __pgrep_remove(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	if (PageActive(page))
+		zone->nr_active--;
+	else
+		zone->nr_inactive--;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/migrate.c	2006-07-12 16:11:44.000000000 +0200
@@ -53,10 +53,7 @@ int isolate_lru_page(struct page *page, 
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
+			__pgrep_remove(zone, page);
 			list_add_tail(&page->lru, pagelist);
 		}
 		spin_unlock_irq(&zone->lru_lock);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:11:44.000000000 +0200
@@ -140,7 +140,8 @@ void fastcall __page_cache_release(struc
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru(zone, page);
+		__pgrep_remove(zone, page);
+		pgrep_clear_state(page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 	free_hot_page(page);
@@ -191,7 +192,8 @@ void release_pages(struct page **pages, 
 			}
 			BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru(zone, page);
+			__pgrep_remove(zone, page);
+			pgrep_clear_state(page);
 		}
 
 		if (!pagevec_add(&pages_to_free, page)) {
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:43.000000000 +0200
@@ -73,11 +73,9 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
+		nr_taken = isolate_lru_pages(zone, sc->swap_cluster_max,
 					     &zone->inactive_list,
 					     &page_list, &nr_scan);
-		zone->nr_inactive -= nr_taken;
-		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
@@ -155,10 +153,8 @@ static void shrink_active_list(unsigned 
 
 	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
+	pgmoved = isolate_lru_pages(zone, nr_pages, &zone->active_list,
 				    &l_hold, &pgscanned);
-	zone->pages_scanned += pgscanned;
-	zone->nr_active -= pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:44.000000000 +0200
@@ -514,7 +514,7 @@ keep:
  *
  * returns how many pages were moved onto *@dst.
  */
-unsigned long isolate_lru_pages(unsigned long nr_to_scan,
+unsigned long isolate_lru_pages(struct zone *zone, unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
 		unsigned long *scanned)
 {
@@ -523,14 +523,11 @@ unsigned long isolate_lru_pages(unsigned
 	unsigned long scan;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
-		struct list_head *target;
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
 		BUG_ON(!PageLRU(page));
 
-		list_del(&page->lru);
-		target = src;
 		if (likely(get_page_unless_zero(page))) {
 			/*
 			 * Be careful not to clear PageLRU until after we're
@@ -538,14 +535,15 @@ unsigned long isolate_lru_pages(unsigned
 			 * page release code relies on it.
 			 */
 			ClearPageLRU(page);
-			target = dst;
+			__pgrep_remove(zone, page);
+			list_add(&page->lru, dst);
 			nr_taken++;
 		} /* else it is being freed elsewhere */
-
-		list_add(&page->lru, target);
+		else list_move(&page->lru, src);
 	}
 
 	*scanned = scan;
+	zone->pages_scanned += scan;
 	return nr_taken;
 }
 
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/swap.h	2006-07-12 16:09:18.000000000 +0200
@@ -174,9 +174,9 @@ extern void release_pages(struct page **
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc);
-extern unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned);
+extern unsigned long isolate_lru_pages(struct zone *zone,
+		unsigned long nr_to_scan, struct list_head *src,
+		struct list_head *dst, unsigned long *scanned);
 extern int should_reclaim_mapped(struct zone *zone);
 extern unsigned long try_to_free_pages(struct zone **, gfp_t);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
