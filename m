From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:41:03 +0200
Message-Id: <20060712144103.16998.51584.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 21/39] mm: pgrep: per policy data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract the policy specific variables from struct zone.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace_data.h |   13 ++++++++
 include/linux/mm_use_once_data.h     |   16 ++++++++++
 include/linux/mm_use_once_policy.h   |   20 ++++++------
 include/linux/mmzone.h               |    8 +----
 mm/useonce.c                         |   54 +++++++++++++++++------------------
 5 files changed, 68 insertions(+), 43 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_data.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_use_once_data.h	2006-07-12 16:11:19.000000000 +0200
@@ -0,0 +1,16 @@
+#ifndef _LINUX_MM_USEONCE_DATA_H
+#define _LINUX_MM_USEONCE_DATA_H
+
+#ifdef __KERNEL__
+
+struct pgrep_data {
+	struct list_head	active_list;
+	struct list_head	inactive_list;
+	unsigned long		nr_scan_active;
+	unsigned long		nr_scan_inactive;
+	unsigned long		nr_active;
+	unsigned long		nr_inactive;
+};
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_USEONCE_DATA_H */
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:31.000000000 +0200
@@ -13,12 +13,12 @@ void __init pgrep_init(void)
 
 void __init pgrep_init_zone(struct zone *zone)
 {
-	INIT_LIST_HEAD(&zone->active_list);
-	INIT_LIST_HEAD(&zone->inactive_list);
-	zone->nr_scan_active = 0;
-	zone->nr_scan_inactive = 0;
-	zone->nr_active = 0;
-	zone->nr_inactive = 0;
+	INIT_LIST_HEAD(&zone->policy.active_list);
+	INIT_LIST_HEAD(&zone->policy.inactive_list);
+	zone->policy.nr_scan_active = 0;
+	zone->policy.nr_scan_inactive = 0;
+	zone->policy.nr_active = 0;
+	zone->policy.nr_inactive = 0;
 }
 
 /**
@@ -99,7 +99,7 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 
 		nr_taken = isolate_lru_pages(zone, sc->swap_cluster_max,
-					     &zone->inactive_list,
+					     &zone->policy.inactive_list,
 					     &page_list, &nr_scan);
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -178,7 +178,7 @@ static void shrink_active_list(unsigned 
 
 	pgrep_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(zone, nr_pages, &zone->active_list,
+	pgmoved = isolate_lru_pages(zone, nr_pages, &zone->policy.active_list,
 				    &l_hold, &pgscanned);
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -208,10 +208,10 @@ static void shrink_active_list(unsigned 
 		BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->inactive_list);
+		list_move(&page->lru, &zone->policy.inactive_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			zone->nr_inactive += pgmoved;
+			zone->policy.nr_inactive += pgmoved;
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -221,7 +221,7 @@ static void shrink_active_list(unsigned 
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	zone->nr_inactive += pgmoved;
+	zone->policy.nr_inactive += pgmoved;
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -236,17 +236,17 @@ static void shrink_active_list(unsigned 
 		BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		list_move(&page->lru, &zone->policy.active_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			zone->nr_active += pgmoved;
+			zone->policy.nr_active += pgmoved;
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	zone->nr_active += pgmoved;
+	zone->policy.nr_active += pgmoved;
 	spin_unlock(&zone->lru_lock);
 
 	__mod_page_state_zone(zone, pgrefill, pgscanned);
@@ -274,17 +274,17 @@ unsigned long pgrep_shrink_zone(int prio
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	zone->nr_scan_active += (zone->nr_active >> priority) + 1;
-	nr_active = zone->nr_scan_active;
+	zone->policy.nr_scan_active += (zone->policy.nr_active >> priority) + 1;
+	nr_active = zone->policy.nr_scan_active;
 	if (nr_active >= sc->swap_cluster_max)
-		zone->nr_scan_active = 0;
+		zone->policy.nr_scan_active = 0;
 	else
 		nr_active = 0;
 
-	zone->nr_scan_inactive += (zone->nr_inactive >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
+	zone->policy.nr_scan_inactive += (zone->policy.nr_inactive >> priority) + 1;
+	nr_inactive = zone->policy.nr_scan_inactive;
 	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
+		zone->policy.nr_scan_inactive = 0;
 	else
 		nr_inactive = 0;
 
@@ -331,8 +331,8 @@ void pgrep_show(struct zone *zone)
 	       K(zone->pages_min),
 	       K(zone->pages_low),
 	       K(zone->pages_high),
-	       K(zone->nr_active),
-	       K(zone->nr_inactive),
+	       K(zone->policy.nr_active),
+	       K(zone->policy.nr_inactive),
 	       K(zone->present_pages),
 	       zone->pages_scanned,
 	       (zone->all_unreclaimable ? "yes" : "no")
@@ -355,10 +355,10 @@ void pgrep_zoneinfo(struct zone *zone, s
 		   zone->pages_min,
 		   zone->pages_low,
 		   zone->pages_high,
-		   zone->nr_active,
-		   zone->nr_inactive,
+		   zone->policy.nr_active,
+		   zone->policy.nr_inactive,
 		   zone->pages_scanned,
-		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->policy.nr_scan_active, zone->policy.nr_scan_inactive,
 		   zone->spanned_pages,
 		   zone->present_pages);
 }
@@ -372,8 +372,8 @@ void __pgrep_counts(unsigned long *activ
 	*inactive = 0;
 	*free = 0;
 	for (i = 0; i < MAX_NR_ZONES; i++) {
-		*active += zones[i].nr_active;
-		*inactive += zones[i].nr_inactive;
+		*active += zones[i].policy.nr_active;
+		*inactive += zones[i].policy.nr_inactive;
 		*free += zones[i].free_pages;
 	}
 }
Index: linux-2.6/include/linux/mm_page_replace_data.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_page_replace_data.h	2006-07-12 16:11:29.000000000 +0200
@@ -0,0 +1,13 @@
+#ifndef _LINUX_MM_PAGE_REPLACE_DATA_H
+#define _LINUX_MM_PAGE_REPLACE_DATA_H
+
+#ifdef __KERNEL__
+
+#ifdef CONFIG_MM_POLICY_USEONCE
+#include <linux/mm_use_once_data.h>
+#else
+#error no mm policy
+#endif
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_PAGE_REPLACE_DATA_H */
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2006-07-12 16:07:29.000000000 +0200
+++ linux-2.6/include/linux/mmzone.h	2006-07-12 16:09:19.000000000 +0200
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
+#include <linux/mm_page_replace_data.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
 
@@ -154,12 +155,7 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
-	unsigned long		nr_active;
-	unsigned long		nr_inactive;
+	struct pgrep_data policy;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:37.000000000 +0200
@@ -9,29 +9,29 @@
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->active_list);
-	zone->nr_active++;
+	list_add(&page->lru, &zone->policy.active_list);
+	zone->policy.nr_active++;
 }
 
 static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	zone->nr_inactive++;
+	list_add(&page->lru, &zone->policy.inactive_list);
+	zone->policy.nr_inactive++;
 }
 
 static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	zone->nr_active--;
+	zone->policy.nr_active--;
 }
 
 static inline void
 del_page_from_inactive_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	zone->nr_inactive--;
+       zone->policy.nr_inactive--;
 }
 
 static inline void pgrep_hint_active(struct page *page)
@@ -126,7 +126,7 @@ static inline int pgrep_activate(struct 
 static inline void __pgrep_rotate_reclaimable(struct zone *zone, struct page *page)
 {
 	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
+		list_move_tail(&page->lru, &zone->policy.inactive_list);
 		inc_page_state(pgrotated);
 	}
 }
@@ -152,14 +152,14 @@ static inline void __pgrep_remove(struct
 {
 	list_del(&page->lru);
 	if (PageActive(page))
-		zone->nr_active--;
+		zone->policy.nr_active--;
 	else
-		zone->nr_inactive--;
+		zone->policy.nr_inactive--;
 }
 
 static inline unsigned long __pgrep_nr_pages(struct zone *zone)
 {
-	return zone->nr_active + zone->nr_inactive;
+	return zone->policy.nr_active + zone->policy.nr_inactive;
 }
 
 #endif /* __KERNEL__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
