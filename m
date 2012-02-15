Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0D6E96B00F1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:54 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:54 -0800 (PST)
Subject: [PATCH RFC 12/15] mm: optimize books in update_page_reclaim_stat()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:50 +0400
Message-ID: <20120215225750.22050.37818.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Push book pointer into update_page_reclaim_stat()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/swap.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 677b529..e57c4c6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -267,12 +267,10 @@ void rotate_reclaimable_page(struct page *page)
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
+static void update_page_reclaim_stat(struct book *book, struct page *page,
 				     int file, int rotated)
 {
-	struct zone_reclaim_stat *reclaim_stat;
-
-	reclaim_stat = &page_book(page)->reclaim_stat;
+	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
 
 	reclaim_stat->recent_scanned[file]++;
 	if (rotated)
@@ -281,8 +279,6 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 
 static void __activate_page(struct page *page, void *arg)
 {
-	struct zone *zone = page_zone(page);
-
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
@@ -295,7 +291,7 @@ static void __activate_page(struct page *page, void *arg)
 		add_page_to_lru_list(book, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		update_page_reclaim_stat(zone, page, file, 1);
+		update_page_reclaim_stat(book, page, file, 1);
 	}
 }
 
@@ -432,7 +428,6 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 {
 	int lru, file;
 	bool active;
-	struct zone *zone = page_zone(page);
 	struct book *book;
 
 	if (!PageLRU(page))
@@ -473,7 +468,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	update_page_reclaim_stat(zone, page, file, 0);
+	update_page_reclaim_stat(book, page, file, 0);
 }
 
 /*
@@ -650,7 +645,7 @@ void lru_add_page_tail(struct zone* zone,
 			active = 0;
 			lru = LRU_INACTIVE_ANON;
 		}
-		update_page_reclaim_stat(zone, page_tail, file, active);
+		update_page_reclaim_stat(book, page_tail, file, active);
 	} else {
 		SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;
@@ -677,7 +672,6 @@ void lru_add_page_tail(struct zone* zone,
 static void __pagevec_lru_add_fn(struct page *page, void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
-	struct zone *zone = page_zone(page);
 	struct book *book = page_book(page);
 	int file = is_file_lru(lru);
 	int active = is_active_lru(lru);
@@ -689,7 +683,7 @@ static void __pagevec_lru_add_fn(struct page *page, void *arg)
 	SetPageLRU(page);
 	if (active)
 		SetPageActive(page);
-	update_page_reclaim_stat(zone, page, file, active);
+	update_page_reclaim_stat(book, page, file, active);
 	add_page_to_lru_list(book, page, lru);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
