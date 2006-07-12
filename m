From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:39:06 +0200
Message-Id: <20060712143906.16998.42974.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 11/39] mm: pgrep: replace mark_page_accessed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract the page activation.

API:

Mark a page as accessed.

	void pgrep_mark_accessed(struct page *);

XXX: go through tree and rename mark_page_accessed() ?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    1 +
 include/linux/mm_use_once_policy.h |   26 ++++++++++++++++++++++++++
 mm/swap.c                          |   28 +---------------------------
 3 files changed, 28 insertions(+), 27 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:47.000000000 +0200
@@ -24,6 +24,32 @@ __pgrep_add(struct zone *zone, struct pa
 		add_page_to_inactive_list(zone, page);
 }
 
+/*
+ * Mark a page as having seen activity.
+ *
+ * inactive,unreferenced	->	inactive,referenced
+ * inactive,referenced		->	active,unreferenced
+ * active,unreferenced		->	active,referenced
+ */
+static inline void pgrep_mark_accessed(struct page *page)
+{
+	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page) && !PageActive(page)) {
+			del_page_from_inactive_list(zone, page);
+			SetPageActive(page);
+			add_page_to_active_list(zone, page);
+			inc_page_state(pgactivate);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+		ClearPageReferenced(page);
+	} else if (!PageReferenced(page)) {
+		SetPageReferenced(page);
+	}
+}
+
 /* Called without lock on whether page is mapped, so answer is unstable */
 static inline int page_mapping_inuse(struct page *page)
 {
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:28.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:49.000000000 +0200
@@ -77,6 +77,7 @@ typedef enum {
 
 /* reclaim_t pgrep_reclaimable(struct page *); */
 /* int pgrep_activate(struct page *page); */
+/* void pgrep_mark_accessed(struct page *); */
 
 
 #ifdef CONFIG_MM_POLICY_USEONCE
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:11:47.000000000 +0200
@@ -98,37 +98,11 @@ int rotate_reclaimable_page(struct page 
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
- *
- * inactive,unreferenced	->	inactive,referenced
- * inactive,referenced		->	active,unreferenced
- * active,unreferenced		->	active,referenced
  */
 void fastcall mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
-		activate_page(page);
-		ClearPageReferenced(page);
-	} else if (!PageReferenced(page)) {
-		SetPageReferenced(page);
-	}
+	pgrep_mark_accessed(page);
 }
 
 EXPORT_SYMBOL(mark_page_accessed);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
