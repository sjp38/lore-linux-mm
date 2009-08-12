Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 800696B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:32:13 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mm: introduce page_lru_base_type()
Date: Wed, 12 Aug 2009 10:32:06 +0200
Message-Id: <1250065929-17392-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Instead of abusing page_is_file_cache() for LRU list index arithmetic,
add another helper with a more appropriate name and convert the
non-boolean users of page_is_file_cache() accordingly.

This new helper gives the LRU base type a page is supposed to live on,
inactive anon or inactive file.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/mm_inline.h |   19 +++++++++++++++++--
 mm/swap.c                 |    4 ++--
 mm/vmscan.c               |    6 +++---
 3 files changed, 22 insertions(+), 7 deletions(-)

v2: renamed from page_lru_type() [thanks, Minchan]

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 7fbb972..6c8118b 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -60,6 +60,21 @@ del_page_from_lru(struct zone *zone, struct page *page)
 }
 
 /**
+ * page_lru_base_type - which LRU list type should a page be on?
+ * @page: the page to test
+ *
+ * Used for LRU list index arithmetic.
+ *
+ * Returns the base LRU type - file or anon - @page should be on.
+ */
+static enum lru_list page_lru_base_type(struct page *page)
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
+		lru = page_lru_base_type(page);
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
-		lru += page_is_file_cache(page);
 	}
 
 	return lru;
diff --git a/mm/swap.c b/mm/swap.c
index cb29ae5..168d53e 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -118,7 +118,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_is_file_cache(page);
+			int lru = page_lru_base_type(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
 			pgmoved++;
 		}
@@ -181,7 +181,7 @@ void activate_page(struct page *page)
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
-		int lru = LRU_BASE + file;
+		int lru = page_lru_base_type(page);
 		del_page_from_lru_list(zone, page, lru);
 
 		SetPageActive(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a4c298..679c729 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -531,7 +531,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
-		lru = active + page_is_file_cache(page);
+		lru = active + page_lru_base_type(page);
 		lru_cache_add_lru(page, lru);
 	} else {
 		/*
@@ -981,7 +981,7 @@ static unsigned long clear_active_flags(struct list_head *page_list,
 	struct page *page;
 
 	list_for_each_entry(page, page_list, lru) {
-		lru = page_is_file_cache(page);
+		lru = page_lru_base_type(page);
 		if (PageActive(page)) {
 			lru += LRU_ACTIVE;
 			ClearPageActive(page);
@@ -2690,7 +2690,7 @@ static void check_move_unevictable_page(struct page *page, struct zone *zone)
 retry:
 	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
-		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
+		enum lru_list l = page_lru_base_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
 		list_move(&page->lru, &zone->lru[l].list);
-- 
1.6.4.13.ge6580

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
