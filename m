Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A47586B0038
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:48:01 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so2766882pad.40
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:48:01 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id qm15si8607921pab.185.2014.06.19.23.47.59
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 23:48:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFCv2 3/3] mm: Free reclaimed pages indepdent of next reclaim
Date: Fri, 20 Jun 2014 15:48:32 +0900
Message-Id: <1403246912-18237-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1403246912-18237-1-git-send-email-minchan@kernel.org>
References: <1403246912-18237-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

Invalidate dirty/writeback page and file/swap I/O for reclaiming
are asynchronous so that when page writeback is completed,
it will be rotated back into LRU tail for freeing in next reclaim.

But it would make unnecessary CPU overhead and more aging
with higher priority of reclaim than necessary thing.

This patch makes such pages instant release when I/O complete
without LRU movement so that we could reduce reclaim events.

This patch wakes up one waiting PG_writeback and then clear
PG_reclaim bit because the page could be released during
rotating so it makes slighly race with Readahead logic but
the chance would be small and no huge side-effect even though
that happens, I belive.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/filemap.c | 17 +++++++++++------
 mm/swap.c    | 21 +++++++++++++++++++++
 2 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c2f30ed8e95f..6e09de6cf510 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -752,23 +752,28 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
+	if (!test_clear_page_writeback(page))
+		BUG();
+
+	smp_mb__after_atomic();
+	wake_up_page(page, PG_writeback);
+
 	/*
 	 * TestClearPageReclaim could be used here but it is an atomic
 	 * operation and overkill in this particular case. Failing to
 	 * shuffle a page marked for immediate reclaim is too mild to
 	 * justify taking an atomic operation penalty at the end of
 	 * ever page writeback.
+	 *
+	 * Clearing PG_reclaim after waking up waiter is slightly racy.
+	 * Readahead might see PageReclaim as PageReadahead marker
+	 * so readahead logic might be broken temporally but it isn't
+	 * matter enough to care.
 	 */
 	if (PageReclaim(page)) {
 		ClearPageReclaim(page);
 		rotate_reclaimable_page(page);
 	}
-
-	if (!test_clear_page_writeback(page))
-		BUG();
-
-	smp_mb__after_atomic();
-	wake_up_page(page, PG_writeback);
 }
 EXPORT_SYMBOL(end_page_writeback);
 
diff --git a/mm/swap.c b/mm/swap.c
index 3074210f245d..d61b8783ccc3 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -443,6 +443,27 @@ static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
+		struct address_space *mapping;
+
+		if (!trylock_page(page))
+			goto move_tail;
+
+		mapping = page_mapping(page);
+		if (!mapping)
+			goto unlock;
+
+		/*
+		 * If it is successful, aotmic_remove_mapping
+		 * makes page->count one so the page will be
+		 * released when caller release his refcount.
+		 */
+		if (atomic_remove_mapping(mapping, page)) {
+			unlock_page(page);
+			return;
+		}
+unlock:
+		unlock_page(page);
+move_tail:
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
