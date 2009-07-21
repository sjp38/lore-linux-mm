Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B52CB6B005D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 04:57:38 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/4] mm: introduce page_lru_type()
Date: Tue, 21 Jul 2009 10:56:32 +0200
Message-Id: <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of abusing page_is_file_cache() for LRU list index arithmetic,
add another helper with a more appropriate name and convert the
non-boolean users of page_is_file_cache() accordingly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm_inline.h |   19 +++++++++++++++++--
 mm/swap.c                 |    4 ++--
 mm/vmscan.c               |    6 +++---
 3 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 7fbb972..ec975f2 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -60,6 +60,21 @@ del_page_from_lru(struct zone *zone, struct page *page)
 }
 
 /**
+ * page_lru_type - which LRU list type should a page be on?
+ * @page: the page to test
+ *
+ * Used for LRU list index arithmetic.
+ *
+ * Returns the base LRU type - file or anon - @page should be on.
+ */
+static enum lru_list page_lru_type(struct page *page)
+{
+	if (page_is_file_cache(page))
+		return LRU_INACTIVE_FILE;
+	return LRU_INACTIVE_ANON;
+}
+
+/**
  * page_lru - which LRU list should a page be on?
  * @page: the page to test
  *
@@ -68,14 +83,14 @@ del_page_from_lru(struct zone *zone, struct page *page)
  */
 static inline enum lru_list page_lru(struct page *page)
 {
-	enum lru_list lru = LRU_BASE;
+	enum lru_list lru;
 
 	if (PageUnevictable(page))
 		lru = LRU_UNEVICTABLE;
 	else {
+		lru = page_lru_type(page);
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
-		lru += page_is_file_cache(page);
 	}
 
 	return lru;
diff --git a/mm/swap.c b/mm/swap.c
index cb29ae5..8f84638 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -118,7 +118,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_is_file_cache(page);
+			int lru = page_lru_type(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
 			pgmoved++;
 		}
@@ -181,7 +181,7 @@ void activate_page(struct page *page)
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
-		int lru = LRU_BASE + file;
+		int lru = page_lru_type(page);
 		del_page_from_lru_list(zone, page, lru);
 
 		SetPageActive(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 46ec6a5..758f628 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -531,7 +531,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
-		lru = active + page_is_file_cache(page);
+		lru = active + page_lru_type(page);
 		lru_cache_add_lru(page, lru);
 	} else {
 		/*
@@ -981,7 +981,7 @@ static unsigned long clear_active_flags(struct list_head *page_list,
 	struct page *page;
 
 	list_for_each_entry(page, page_list, lru) {
-		lru = page_is_file_cache(page);
+		lru = page_lru_type(page);
 		if (PageActive(page)) {
 			lru += LRU_ACTIVE;
 			ClearPageActive(page);
@@ -2645,7 +2645,7 @@ static void check_move_unevictable_page(struct page *page, struct zone *zone)
 retry:
 	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
-		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
+		enum lru_list l = page_lru_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
 		list_move(&page->lru, &zone->lru[l].list);
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
