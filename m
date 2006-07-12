From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:38:09 +0200
Message-Id: <20060712143809.16998.77765.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 6/39] mm: pgrep: generice __pagevec_*_add
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Since PG_active is already used to discriminate between active and inactive
lists, use it to collapse the two pagevec add functions and make it a generic
helper function.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_inline.h |    6 ++++
 mm/swap.c                 |   31 ++++++++++++++++++++
 mm/useonce.c              |   68 ++--------------------------------------------
 3 files changed, 41 insertions(+), 64 deletions(-)

Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:49.000000000 +0200
@@ -11,64 +11,6 @@
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 
-/*
- * Add the passed pages to the LRU, then drop the caller's refcount
- * on them.  Reinitialises the caller's pagevec.
- */
-void __pagevec_pgrep_add(struct pagevec *pvec)
-{
-	int i;
-	struct zone *zone = NULL;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
-EXPORT_SYMBOL(__pagevec_pgrep_add);
-
-static void __pagevec_lru_add_active(struct pagevec *pvec)
-{
-	int i;
-	struct zone *zone = NULL;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		BUG_ON(PageActive(page));
-		SetPageActive(page);
-		add_page_to_active_list(zone, page);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
 static inline void lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
@@ -85,18 +27,16 @@ static inline void lru_cache_add_active(
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_pgrep_add(pvec);
 	put_cpu_var(lru_add_active_pvecs);
 }
 
 void fastcall pgrep_add(struct page *page)
 {
-	if (PageActive(page)) {
-		ClearPageActive(page);
+	if (PageActive(page))
 		lru_cache_add_active(page);
-	} else {
+	else
 		lru_cache_add(page);
-	}
 }
 
 void __pgrep_add_drain(unsigned int cpu)
@@ -107,5 +47,5 @@ void __pgrep_add_drain(unsigned int cpu)
 		__pagevec_pgrep_add(pvec);
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_pgrep_add(pvec);
 }
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:11:50.000000000 +0200
@@ -335,6 +335,37 @@ unsigned pagevec_lookup_tag(struct pagev
 
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
+/*
+ * Add the passed pages to the LRU, then drop the caller's refcount
+ * on them.  Reinitialises the caller's pagevec.
+ */
+void __pagevec_pgrep_add(struct pagevec *pvec)
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
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		__pgrep_add(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+EXPORT_SYMBOL(__pagevec_pgrep_add);
+
 #ifdef CONFIG_SMP
 /*
  * We tolerate a little inaccuracy to avoid ping-ponging the counter between
Index: linux-2.6/include/linux/mm_inline.h
===================================================================
--- linux-2.6.orig/include/linux/mm_inline.h	2006-06-23 21:47:11.000000000 +0200
+++ linux-2.6/include/linux/mm_inline.h	2006-07-12 16:11:44.000000000 +0200
@@ -1,3 +1,7 @@
+#ifndef _LINUX_MM_INLINE_H_
+#define _LINUX_MM_INLINE_H_
+
+#ifdef __KERNEL__
 
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
@@ -39,3 +43,5 @@ del_page_from_lru(struct zone *zone, str
 	}
 }
 
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_INLINE_H_ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
