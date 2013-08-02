Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BB0886B0033
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 11:37:52 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch v2 1/3] mm: vmscan: fix numa reclaim balance problem in kswapd
Date: Fri,  2 Aug 2013 11:37:24 -0400
Message-Id: <1375457846-21521-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When the page allocator fails to get a page from all zones in its
given zonelist, it wakes up the per-node kswapds for all zones that
are at their low watermark.

However, with a system under load the free pages in a zone can
fluctuate enough that the allocation fails but the kswapd wakeup is
also skipped while the zone is still really close to the low
watermark.

When one node misses a wakeup like this, it won't be aged before all
the other node's zones are down to their low watermarks again.  And
skipping a full aging cycle is an obvious fairness problem.

Kswapd runs until the high watermarks are restored, so it should also
be woken when the high watermarks are not met.  This ages nodes more
equally and creates a safety margin for the page counter fluctuation.

By using zone_balanced(), it will now check, in addition to the
watermark, if compaction requires more order-0 pages to create a
higher order page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..758540d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3237,7 +3237,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
+	if (zone_balanced(zone, order, 0, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
