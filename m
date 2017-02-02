Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1DEC6B026B
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:35 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so198861wme.3
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e44si29690646wre.209.2017.02.02.11.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/7] mm: vmscan: move dirty pages out of the way until they're flushed
Date: Thu,  2 Feb 2017 14:19:56 -0500
Message-Id: <20170202191957.22872-7-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We noticed a performance regression when moving hadoop workloads from 3.10
kernels to 4.0 and 4.6.  This is accompanied by increased pageout activity
initiated by kswapd as well as frequent bursts of allocation stalls and
direct reclaim scans.  Even lowering the dirty ratios to the equivalent of
less than 1% of memory would not eliminate the issue, suggesting that
dirty pages concentrate where the scanner is looking.

This can be traced back to recent efforts of thrash avoidance.  Where 3.10
would not detect refaulting pages and continuously supply clean cache to
the inactive list, a thrashing workload on 4.0+ will detect and activate
refaulting pages right away, distilling used-once pages on the inactive
list much more effectively.  This is by design, and it makes sense for
clean cache.  But for the most part our workload's cache faults are
refaults and its use-once cache is from streaming writes.  We end up with
most of the inactive list dirty, and we don't go after the active cache as
long as we have use-once pages around.

But waiting for writes to avoid reclaiming clean cache that *might*
refault is a bad trade-off.  Even if the refaults happen, reads are faster
than writes.  Before getting bogged down on writeback, reclaim should
first look at *all* cache in the system, even active cache.

To accomplish this, activate pages that are dirty or under writeback
when they reach the end of the inactive LRU.  The pages are marked for
immediate reclaim, meaning they'll get moved back to the inactive LRU
tail as soon as they're written back and become reclaimable.  But in
the meantime, by reducing the inactive list to only immediately
reclaimable pages, we allow the scanner to deactivate and refill the
inactive list with clean cache from the active list tail to guarantee
forward progress.

Link: http://lkml.kernel.org/r/20170123181641.23938-6-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm_inline.h | 7 +++++++
 mm/swap.c                 | 9 +++++----
 mm/vmscan.c               | 6 +++---
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 41d376e7116d..e030a68ead7e 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -50,6 +50,13 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 	list_add(&page->lru, &lruvec->lists[lru]);
 }
 
+static __always_inline void add_page_to_lru_list_tail(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
+	list_add_tail(&page->lru, &lruvec->lists[lru]);
+}
+
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/mm/swap.c b/mm/swap.c
index aabf2e90fe32..c4910f14f957 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -209,9 +209,10 @@ static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
 {
 	int *pgmoved = arg;
 
-	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		enum lru_list lru = page_lru_base_type(page);
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+	if (PageLRU(page) && !PageUnevictable(page)) {
+		del_page_from_lru_list(page, lruvec, page_lru(page));
+		ClearPageActive(page);
+		add_page_to_lru_list_tail(page, lruvec, page_lru(page));
 		(*pgmoved)++;
 	}
 }
@@ -235,7 +236,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
  */
 void rotate_reclaimable_page(struct page *page)
 {
-	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
+	if (!PageLocked(page) && !PageDirty(page) &&
 	    !PageUnevictable(page) && PageLRU(page)) {
 		struct pagevec *pvec;
 		unsigned long flags;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 92e56cadceae..70103f411247 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1063,7 +1063,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			    PageReclaim(page) &&
 			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
 				nr_immediate++;
-				goto keep_locked;
+				goto activate_locked;
 
 			/* Case 2 above */
 			} else if (sane_reclaim(sc) ||
@@ -1081,7 +1081,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 */
 				SetPageReclaim(page);
 				nr_writeback++;
-				goto keep_locked;
+				goto activate_locked;
 
 			/* Case 3 above */
 			} else {
@@ -1174,7 +1174,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				inc_node_page_state(page, NR_VMSCAN_IMMEDIATE);
 				SetPageReclaim(page);
 
-				goto keep_locked;
+				goto activate_locked;
 			}
 
 			if (references == PAGEREF_RECLAIM_CLEAN)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
