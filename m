From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:39:29 +0200
Message-Id: <20060712143929.16998.56637.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 13/39] mm: pgrep: abstract rotate_reclaimable_page()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Take out the knowledge of the rotation itself.

API:

rotate the page to the candidate end of the page scanner 
(when suitable for reclaim)

	void __pgrep_rotate_reclaimable(struct zone *, struct page *);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    1 +
 include/linux/mm_use_once_policy.h |    8 ++++++++
 mm/swap.c                          |    8 +-------
 3 files changed, 10 insertions(+), 7 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:46.000000000 +0200
@@ -95,5 +95,13 @@ static inline int pgrep_activate(struct 
 	return 1;
 }
 
+static inline void __pgrep_rotate_reclaimable(struct zone *zone, struct page *page)
+{
+	if (PageLRU(page) && !PageActive(page)) {
+		list_move_tail(&page->lru, &zone->inactive_list);
+		inc_page_state(pgrotated);
+	}
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:46.000000000 +0200
@@ -80,6 +80,7 @@ typedef enum {
 /* void pgrep_mark_accessed(struct page *); */
 extern unsigned long pgrep_shrink_zone(int priority, struct zone *zone,
 					struct scan_control *sc);
+/* void __pgrep_rotate_reclaimable(struct zone *, struct page *); */
 
 
 #ifdef CONFIG_MM_POLICY_USEONCE
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:11:45.000000000 +0200
@@ -79,18 +79,12 @@ int rotate_reclaimable_page(struct page 
 		return 1;
 	if (PageDirty(page))
 		return 1;
-	if (PageActive(page))
-		return 1;
 	if (!PageLRU(page))
 		return 1;
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lru_lock, flags);
-	if (PageLRU(page) && !PageActive(page)) {
-		list_del(&page->lru);
-		list_add_tail(&page->lru, &zone->inactive_list);
-		inc_page_state(pgrotated);
-	}
+	__pgrep_rotate_reclaimable(zone, page);
 	if (!test_clear_page_writeback(page))
 		BUG();
 	spin_unlock_irqrestore(&zone->lru_lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
