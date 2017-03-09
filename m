Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A82036B0414
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:56:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n11so18715114wma.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:56:59 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id c12si7712575wrb.13.2017.03.08.23.56.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 23:56:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 150F199813
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:56:58 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/3] mm, vmscan: Only clear pgdat congested/dirty/writeback state when balanced
Date: Thu,  9 Mar 2017 07:56:56 +0000
Message-Id: <20170309075657.25121-3-mgorman@techsingularity.net>
In-Reply-To: <20170309075657.25121-1-mgorman@techsingularity.net>
References: <20170309075657.25121-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

A pgdat tracks if recent reclaim encountered too many dirty, writeback
or congested pages. The flags control whether kswapd writes pages back
from reclaim context, tags pages for immediate reclaim when IO completes,
whether processes block on wait_iff_congested and whether kswapd blocks
when too many pages marked for immediate reclaim are encountered.

The state is cleared in a check function with side-effects. With the patch
"mm, vmscan: fix zone balance check in prepare_kswapd_sleep", the timing
of when the bits get cleared changed. Due to the way the check works,
it'll clear the bits if ZONE_DMA is balanced for a GFP_DMA allocation
because it does not account for lowmem reserves properly.

For the simoop workload, kswapd is not stalling when it should due to
the premature clearing, writing pages from reclaim context like crazy and
generally being unhelpful.

This patch resets the pgdat bits related to page reclaim only when kswapd
is going to sleep. The comparison with simoop is then

                                         4.11.0-rc1            4.11.0-rc1            4.11.0-rc1
                                            vanilla           fixcheck-v2              clear-v2
Amean    p50-Read             21670074.18 (  0.00%) 20464344.18 (  5.56%) 19786774.76 (  8.69%)
Amean    p95-Read             25456267.64 (  0.00%) 25721423.64 ( -1.04%) 24101956.27 (  5.32%)
Amean    p99-Read             29369064.73 (  0.00%) 30174230.76 ( -2.74%) 27691872.71 (  5.71%)
Amean    p50-Write                1390.30 (  0.00%)     1395.28 ( -0.36%)     1011.91 ( 27.22%)
Amean    p95-Write              412901.57 (  0.00%)    37737.74 ( 90.86%)    34874.98 ( 91.55%)
Amean    p99-Write             6668722.09 (  0.00%)   666489.04 ( 90.01%)   575449.60 ( 91.37%)
Amean    p50-Allocation          78714.31 (  0.00%)    86286.22 ( -9.62%)    84246.26 ( -7.03%)
Amean    p95-Allocation         175533.51 (  0.00%)   351812.27 (-100.42%)   400058.43 (-127.91%)
Amean    p99-Allocation         247003.02 (  0.00%)  6291171.56 (-2447.00%) 10905600.00 (-4315.17%)

Read latency is improved, write latency is mostly improved but allocation
latency is regressed.  kswapd is still reclaiming inefficiently,
pages are being written back from writeback context and a host of other
issues. However, given the change, it needed to be spelled out why the
side-effect was moved.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4ea444142c2e..17b1afbce88e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3091,17 +3091,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
 		return false;
 
-	/*
-	 * If any eligible zone is balanced then the node is not considered
-	 * to be congested or dirty
-	 */
-	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
-	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
-	clear_bit(PGDAT_WRITEBACK, &zone->zone_pgdat->flags);
-
 	return true;
 }
 
+/* Clear pgdat state for congested, dirty or under writeback. */
+static void clear_pgdat_congested(pg_data_t *pgdat)
+{
+	clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+	clear_bit(PGDAT_DIRTY, &pgdat->flags);
+	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
+}
+
 /*
  * Prepare kswapd for sleeping. This verifies that there are no processes
  * waiting in throttle_direct_reclaim() and that watermarks have been met.
@@ -3134,8 +3134,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		if (!managed_zone(zone))
 			continue;
 
-		if (zone_balanced(zone, order, classzone_idx))
+		if (zone_balanced(zone, order, classzone_idx)) {
+			clear_pgdat_congested(pgdat);
 			return true;
+		}
 	}
 
 	return false;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
