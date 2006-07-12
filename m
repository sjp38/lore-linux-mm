From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:44:16 +0200
Message-Id: <20060712144416.16998.97485.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 37/39] mm: use-once: cleanup of the use-once logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Explicit use-once implementation.
Based on ideas and code from Rik van Riel.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl

 include/linux/mm_use_once_policy.h |   70 +++++++++++--------------------------
 mm/useonce.c                       |    7 ++-
 2 files changed, 26 insertions(+), 51 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:19.000000000 +0200
@@ -8,12 +8,17 @@
 #include <linux/page-flags.h>
 
 #define PG_active	PG_reclaim1
+#define PG_new		PG_reclaim2
 
 #define PageActive(page)	test_bit(PG_active, &(page)->flags)
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
 
+#define PageNew(page)		test_bit(PG_new, &(page)->flags)
+#define SetPageNew(page)	set_bit(PG_new, &(page)->flags)
+#define ClearPageNew(page)	clear_bit(PG_new, &(page)->flags)
+
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
@@ -49,6 +54,7 @@ static inline void pgrep_hint_active(str
 
 static inline void pgrep_hint_use_once(struct page *page)
 {
+	SetPageNew(page);
 }
 
 static inline void
@@ -60,67 +66,31 @@ __pgrep_add(struct zone *zone, struct pa
 		add_page_to_inactive_list(zone, page);
 }
 
-/*
- * Mark a page as having seen activity.
- *
- * inactive,unreferenced	->	inactive,referenced
- * inactive,referenced		->	active,unreferenced
- * active,unreferenced		->	active,referenced
- */
 static inline void pgrep_mark_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
-		struct zone *zone = page_zone(page);
-
-		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page) && !PageActive(page)) {
-			del_page_from_inactive_list(zone, page);
-			SetPageActive(page);
-			add_page_to_active_list(zone, page);
-			inc_page_state(pgactivate);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-		ClearPageReferenced(page);
-	} else if (!PageReferenced(page)) {
+	if (!PageReferenced(page))
 		SetPageReferenced(page);
-	}
-}
-
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
 }
 
 static inline reclaim_t pgrep_reclaimable(struct page *page)
 {
-	int referenced;
+	int referenced, keep;
 
 	if (PageActive(page))
 		BUG();
 
 	referenced = page_referenced(page, 1, 0);
-	/* In active use or really unfreeable?  Activate it. */
-	if (referenced && page_mapping_inuse(page))
-		return RECLAIM_ACTIVATE;
 
-	if (referenced)
-		return RECLAIM_REFERENCED;
+	keep = PageNew(page);
+	if (keep)
+		ClearPageNew(page);
+
+	if (referenced) {
+		if (keep)
+			return RECLAIM_KEEP;
+
+		return RECLAIM_ACTIVATE;
+	}
 
 	return RECLAIM_OK;
 }
@@ -143,12 +113,16 @@ static inline void pgrep_copy_state(stru
 {
 	if (PageActive(spage))
 		SetPageActive(dpage);
+	if (PageNew(spage))
+		SetPageNew(dpage);
 }
 
 static inline void pgrep_clear_state(struct page *page)
 {
 	if (PageActive(page))
 		ClearPageActive(page);
+	if (PageNew(page))
+		ClearPageNew(page);
 }
 
 static inline int pgrep_is_active(struct page *page)
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:19.000000000 +0200
@@ -172,6 +172,7 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
 	struct page *page;
 	struct pagevec pvec;
+	int referenced;
 
 	if (!sc->may_swap)
 		reclaim_mapped = 0;
@@ -186,10 +187,10 @@ static void shrink_active_list(unsigned 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+		referenced = page_referenced(page, 0, 0);
 		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, 0)) {
+			if (referenced || !reclaim_mapped ||
+			    (total_swap_pages == 0 && PageAnon(page))) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
