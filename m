Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3D98680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:22:51 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so62847162wjc.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:22:51 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id g48si4277480wrg.164.2017.02.15.01.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 01:22:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id A229D1C1BCA
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 09:22:49 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/3] mm, vmscan: Only clear pgdat congested/dirty/writeback state when balanced
Date: Wed, 15 Feb 2017 09:22:46 +0000
Message-Id: <20170215092247.15989-3-mgorman@techsingularity.net>
In-Reply-To: <20170215092247.15989-1-mgorman@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

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

                                         4.10.0-rc7            4.10.0-rc7            4.10.0-rc7
                                     mmots-20170209           fixcheck-v1              clear-v1
Amean    p50-Read             22325202.49 (  0.00%) 20026926.55 ( 10.29%) 19491134.58 ( 12.69%)
Amean    p95-Read             26102988.80 (  0.00%) 27023360.00 ( -3.53%) 24294195.20 (  6.93%)
Amean    p99-Read             30935176.53 (  0.00%) 30994432.00 ( -0.19%) 30397053.16 (  1.74%)
Amean    p50-Write                 976.44 (  0.00%)     1905.28 (-95.12%)     1077.22 (-10.32%)
Amean    p95-Write               15471.29 (  0.00%)    36210.09 (-134.05%)    36419.56 (-135.40%)
Amean    p99-Write               35108.62 (  0.00%)   479494.96 (-1265.75%)   102000.36 (-190.53%)
Amean    p50-Allocation          76382.61 (  0.00%)    87603.20 (-14.69%)    87485.22 (-14.54%)
Amean    p95-Allocation         127777.39 (  0.00%)   244491.38 (-91.34%)   204588.52 (-60.11%)
Amean    p99-Allocation         187937.39 (  0.00%)  1745237.33 (-828.63%)   631657.74 (-236.10%)

Read latency is improved although write and allocation latency is
impacted.  Even with the patch, kswapd is still reclaiming inefficiently,
pages are being written back from writeback context and a host of other
issues. However, given the change, it needed to be spelled out why the
side-effect was moved.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 92fc66bd52bc..b47b430ca7ea 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3097,17 +3097,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
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
@@ -3140,8 +3140,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
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
