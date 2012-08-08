Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 579F16B005D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 15:08:49 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/5] mm: vmscan: Scale number of pages reclaimed by reclaim/compaction based on failures
Date: Wed,  8 Aug 2012 20:08:41 +0100
Message-Id: <1344452924-24438-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1344452924-24438-1-git-send-email-mgorman@suse.de>
References: <1344452924-24438-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If allocation fails after compaction then compaction may be deferred for
a number of allocation attempts. If there are subsequent failures,
compact_defer_shift is increased to defer for longer periods. This patch
uses that information to scale the number of pages reclaimed with
compact_defer_shift until allocations succeed again.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 66e4310..0cb2593 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1708,6 +1708,7 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
+	struct zone *zone;
 
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
@@ -1741,6 +1742,15 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
+
+	/*
+	 * If compaction is deferred for this order then scale the number of
+	 * pages reclaimed based on the number of consecutive allocation
+	 * failures
+	 */
+	zone = lruvec_zone(lruvec);
+	if (zone->compact_order_failed >= sc->order)
+		pages_for_compaction <<= zone->compact_defer_shift;
 	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
 	if (nr_swap_pages > 0)
 		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
