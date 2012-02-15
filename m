Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A10386B00EB
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:43 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903449bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:43 -0800 (PST)
Subject: [PATCH RFC 09/15] mm: handle book relocks on lumpy reclaim
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:40 +0400
Message-ID: <20120215225740.22050.35218.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Prepare for lock splitting in move_active_pages_to_lru() and putback_inactive_pages()
on lumpy reclaim they can put pages into different books.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0b973ff..9a3fb72 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1335,7 +1335,10 @@ static int too_many_isolated(struct zone *zone, int file,
 	return isolated > inactive;
 }
 
-static noinline_for_stack void
+/*
+ * Returns currently locked book
+ */
+static noinline_for_stack struct book *
 putback_inactive_pages(struct book *book,
 		       struct list_head *page_list)
 {
@@ -1386,6 +1389,8 @@ putback_inactive_pages(struct book *book,
 	 * To save our caller's stack, now use input list for pages to free.
 	 */
 	list_splice(&pages_to_free, page_list);
+
+	return book;
 }
 
 static noinline_for_stack void
@@ -1555,7 +1560,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(book, &page_list);
+	book = putback_inactive_pages(book, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1614,12 +1619,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
  *
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns currently locked book
  */
 
-static void move_active_pages_to_lru(struct book *book,
-				     struct list_head *list,
-				     struct list_head *pages_to_free,
-				     enum lru_list lru)
+static struct book *
+move_active_pages_to_lru(struct book *book,
+			 struct list_head *list,
+			 struct list_head *pages_to_free,
+			 enum lru_list lru)
 {
 	unsigned long pgmoved = 0;
 	struct page *page;
@@ -1667,6 +1675,8 @@ static void move_active_pages_to_lru(struct book *book,
 	__mod_zone_page_state(book_zone(book), NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	return book;
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
@@ -1755,9 +1765,9 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(book, &l_active, &l_hold,
+	book = move_active_pages_to_lru(book, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(book, &l_inactive, &l_hold,
+	book = move_active_pages_to_lru(book, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	unlock_book_irq(book);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
