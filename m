Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id CFF636B00F3
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:31 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:31 -0800 (PST)
Subject: [PATCH v2 14/22] mm: push lruvec into update_page_reclaim_stat()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:28 +0400
Message-ID: <20120220172328.22196.87852.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Push lruvec pointer into update_page_reclaim_stat()
* drop page argument
* drop active and file arguments, use lru instead

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/swap.c |   30 +++++++++---------------------
 1 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 0167d6f..a549f11 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -281,24 +281,19 @@ void rotate_reclaimable_page(struct page *page)
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
-				     int file, int rotated)
+static void update_page_reclaim_stat(struct lruvec *lruvec, enum lru_list lru)
 {
-	struct zone_reclaim_stat *reclaim_stat;
-
-	reclaim_stat = &page_lruvec(page)->reclaim_stat;
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	int file = is_file_lru(lru);
 
 	reclaim_stat->recent_scanned[file]++;
-	if (rotated)
+	if (is_active_lru(lru))
 		reclaim_stat->recent_rotated[file]++;
 }
 
 static void __activate_page(struct page *page, void *arg)
 {
-	struct zone *zone = page_zone(page);
-
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
 		struct lruvec *lruvec = page_lruvec(page);
 
@@ -309,7 +304,7 @@ static void __activate_page(struct page *page, void *arg)
 		add_page_to_lru_list(lruvec, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		update_page_reclaim_stat(zone, page, file, 1);
+		update_page_reclaim_stat(lruvec, lru);
 	}
 }
 
@@ -372,8 +367,6 @@ EXPORT_SYMBOL(mark_page_accessed);
 
 static void __lru_cache_add_list(struct list_head *pages, enum lru_list lru)
 {
-	int file = is_file_lru(lru);
-	int active = is_active_lru(lru);
 	struct page *page, *next;
 	struct lruvec *lruvec;
 	struct zone *pagezone, *zone = NULL;
@@ -392,10 +385,10 @@ static void __lru_cache_add_list(struct list_head *pages, enum lru_list lru)
 		VM_BUG_ON(PageUnevictable(page));
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		if (active)
+		if (is_active_lru(lru))
 			SetPageActive(page);
-		update_page_reclaim_stat(zone, page, file, active);
 		lruvec = page_lruvec(page);
+		update_page_reclaim_stat(lruvec, lru);
 		add_page_to_lru_list(lruvec, page, lru);
 		if (unlikely(put_page_testzero(page))) {
 			__ClearPageLRU(page);
@@ -519,7 +512,6 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 {
 	int lru, file;
 	bool active;
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 
 	if (!PageLRU(page))
@@ -560,7 +552,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	update_page_reclaim_stat(zone, page, file, 0);
+	update_page_reclaim_stat(lruvec, lru);
 }
 
 /*
@@ -727,9 +719,7 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct zone* zone,
 		       struct page *page, struct page *page_tail)
 {
-	int active;
 	enum lru_list lru;
-	const int file = 0;
 	struct lruvec *lruvec = page_lruvec(page);
 
 	VM_BUG_ON(!PageHead(page));
@@ -742,13 +732,11 @@ void lru_add_page_tail(struct zone* zone,
 	if (page_evictable(page_tail, NULL)) {
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
-			active = 1;
 			lru = LRU_ACTIVE_ANON;
 		} else {
-			active = 0;
 			lru = LRU_INACTIVE_ANON;
 		}
-		update_page_reclaim_stat(zone, page_tail, file, active);
+		update_page_reclaim_stat(lruvec, lru);
 	} else {
 		SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
