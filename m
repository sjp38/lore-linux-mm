Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2F94C6B0038
	for <linux-mm@kvack.org>; Sun, 12 May 2013 22:11:02 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/4] mm: free reclaimed pages instantly without depending next reclaim
Date: Mon, 13 May 2013 11:10:48 +0900
Message-Id: <1368411048-3753-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1368411048-3753-1-git-send-email-minchan@kernel.org>
References: <1368411048-3753-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

Normally, file I/O for reclaiming is asynchronous so that
when page writeback is completed, reclaimed page will be
rotated into LRU tail for fast reclaiming in next turn.
But it makes unnecessary CPU overhead and more iteration with higher
priority of reclaim could reclaim too many pages than needed
pages.

This patch frees reclaimed pages by paging out instantly without
rotating back them into LRU's tail when the I/O is completed so
that we can get out of reclaim loop as soon as poosbile and avoid
unnecessary CPU overhead for moving them.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/filemap.c |  6 +++---
 mm/swap.c    | 14 +++++++++++++-
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7905fe7..8e2017b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -618,12 +618,12 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (TestClearPageReclaim(page))
-		rotate_reclaimable_page(page);
-
 	if (!test_clear_page_writeback(page))
 		BUG();
 
+	if (TestClearPageReclaim(page))
+		rotate_reclaimable_page(page);
+
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_writeback);
 }
diff --git a/mm/swap.c b/mm/swap.c
index dfd7d71..87f21632 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -324,7 +324,19 @@ static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
 	int *pgmoved = arg;
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		enum lru_list lru = page_lru_base_type(page);
+		enum lru_list lru;
+
+		if (!trylock_page(page))
+			goto move_tail;
+
+		if (!remove_mapping(page_mapping(page), page, true)) {
+			unlock_page(page);
+			goto move_tail;
+		}
+		unlock_page(page);
+		return;
+move_tail:
+		lru = page_lru_base_type(page);
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
