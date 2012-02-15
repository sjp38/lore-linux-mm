Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D715D6B00F5
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:58:02 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:58:01 -0800 (PST)
Subject: [PATCH RFC 14/15] mm: optimize putback for 0-order reclaim
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:58 +0400
Message-ID: <20120215225758.22050.38109.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

At 0-order reclaim all pages are taken from one book,
thus we don't need to recheck and relock page_book on putback.

Maybe it would be better to collect lumpy-isolated pages into
separate list and handle them independently.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a3fb72..9fc814f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1340,6 +1340,7 @@ static int too_many_isolated(struct zone *zone, int file,
  */
 static noinline_for_stack struct book *
 putback_inactive_pages(struct book *book,
+		       struct scan_control *sc,
 		       struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
@@ -1364,7 +1365,9 @@ putback_inactive_pages(struct book *book,
 		lru = page_lru(page);
 
 		/* can differ only on lumpy reclaim */
-		book = __relock_page_book(book, page);
+		if (sc->order)
+			book = __relock_page_book(book, page);
+
 		add_page_to_lru_list(book, page, lru);
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
@@ -1560,7 +1563,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	book = putback_inactive_pages(book, &page_list);
+	book = putback_inactive_pages(book, sc, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1625,6 +1628,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 
 static struct book *
 move_active_pages_to_lru(struct book *book,
+			 struct scan_control *sc,
 			 struct list_head *list,
 			 struct list_head *pages_to_free,
 			 enum lru_list lru)
@@ -1653,7 +1657,9 @@ move_active_pages_to_lru(struct book *book,
 		SetPageLRU(page);
 
 		/* can differ only on lumpy reclaim */
-		book = __relock_page_book(book, page);
+		if (sc->order)
+			book = __relock_page_book(book, page);
+
 		list_move(&page->lru, &book->pages_lru[lru]);
 		numpages = hpage_nr_pages(page);
 		book->pages_count[lru] += numpages;
@@ -1765,9 +1771,9 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	book = move_active_pages_to_lru(book, &l_active, &l_hold,
+	book = move_active_pages_to_lru(book, sc, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	book = move_active_pages_to_lru(book, &l_inactive, &l_hold,
+	book = move_active_pages_to_lru(book, sc, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	unlock_book_irq(book);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
