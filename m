Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4B4FD6B0062
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:49:30 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/5] mm: vmscan: Scale number of pages reclaimed by reclaim/compaction based on failures
Date: Thu,  9 Aug 2012 14:49:22 +0100
Message-Id: <1344520165-24419-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1344520165-24419-1-git-send-email-mgorman@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If allocation fails after compaction then compaction may be deferred for
a number of allocation attempts. If there are subsequent failures,
compact_defer_shift is increased to defer for longer periods. This patch
uses that information to scale the number of pages reclaimed with
compact_defer_shift until allocations succeed again. The rationale is
that reclaiming the normal number of pages still allowed compaction to
fail and its success depends on the number of pages. If it's failing,
reclaim more pages until it succeeds again.

Note that this is not implying that VM reclaim is not reclaiming enough
pages or that its logic is broken. try_to_free_pages() always asks for
SWAP_CLUSTER_MAX pages to be reclaimed regardless of order and that is
what it does. Direct reclaim stops normally with this check.

	if (sc->nr_reclaimed >= sc->nr_to_reclaim)
		goto out;

should_continue_reclaim delays when that check is made until a minimum number
of pages for reclaim/compaction are reclaimed. It is possible that this patch
could instead set nr_to_reclaim in try_to_free_pages() and drive it from
there but that's behaves differently and not necessarily for the better. If
driven from do_try_to_free_pages(), it is also possible that priorities
will rise. When they reach DEF_PRIORITY-2, it will also start stalling
and setting pages for immediate reclaim which is more disruptive than not
desirable in this case. That is a more wide-reaching change that could
cause another regression related to THP requests causing interactive jitter.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 66e4310..7a43fd8 100644
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
+	 * If compaction is deferred for sc->order then scale the number of
+	 * pages reclaimed based on the number of consecutive allocation
+	 * failures
+	 */
+	zone = lruvec_zone(lruvec);
+	if (zone->compact_order_failed <= sc->order)
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
