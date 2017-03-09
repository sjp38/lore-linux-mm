Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA3C76B0415
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:56:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so19994716wrc.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:56:59 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id d13si7662700wra.226.2017.03.08.23.56.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 23:56:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DCE1A997A5
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:56:57 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/3] mm, vmscan: fix zone balance check in prepare_kswapd_sleep
Date: Thu,  9 Mar 2017 07:56:55 +0000
Message-Id: <20170309075657.25121-2-mgorman@techsingularity.net>
In-Reply-To: <20170309075657.25121-1-mgorman@techsingularity.net>
References: <20170309075657.25121-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

From: Shantanu Goel <sgoel01@yahoo.com>

The check in prepare_kswapd_sleep needs to match the one in balance_pgdat
since the latter will return as soon as any one of the zones in the
classzone is above the watermark.  This is specially important for higher
order allocations since balance_pgdat will typically reset the order to
zero relying on compaction to create the higher order pages.  Without this
patch, prepare_kswapd_sleep fails to wake up kcompactd since the zone
balance check fails.

It was first reported against 4.9.7 that kswapd is failing to wake up
kcompactd due to a mismatch in the zone balance check between balance_pgdat()
and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single
zone satisfies the allocation but prepare_kswapd_sleep() requires all zones
to do +the same.  This causes prepare_kswapd_sleep() to never succeed except
in the order == 0 case and consequently, wakeup_kcompactd() is never called.
For the machine that originally motivated this patch, the state of compaction
from /proc/vmstat looked this way after a day and a half +of uptime:

compact_migrate_scanned 240496
compact_free_scanned 76238632
compact_isolated 123472
compact_stall 1791
compact_fail 29
compact_success 1762
compact_daemon_wake 0

After applying the patch and about 10 hours of uptime the state looks
like this:

compact_migrate_scanned 59927299
compact_free_scanned 2021075136
compact_isolated 640926
compact_stall 4
compact_fail 2
compact_success 2
compact_daemon_wake 5160

Further notes from Mel that motivated him to pick this patch up and
resend it;

It was observed for the simoop workload (pressures the VM similar to HADOOP)
that kswapd was failing to keep ahead of direct reclaim. The investigation
noted that there was a need to rationalise kswapd decisions to reclaim
with kswapd decisions to sleep. With this patch on a 2-socket box, there
was a 49% reduction in direct reclaim scanning.

However, the impact otherwise is extremely negative. Kswapd reclaim
efficiency dropped from 98% to 76%. simoop has three latency-related
metrics for read, write and allocation (an anonymous mmap and fault).

                                         4.11.0-rc1            4.11.0-rc1
                                            vanilla           fixcheck-v2
Amean    p50-Read             21670074.18 (  0.00%) 20464344.18 (  5.56%)
Amean    p95-Read             25456267.64 (  0.00%) 25721423.64 ( -1.04%)
Amean    p99-Read             29369064.73 (  0.00%) 30174230.76 ( -2.74%)
Amean    p50-Write                1390.30 (  0.00%)     1395.28 ( -0.36%)
Amean    p95-Write              412901.57 (  0.00%)    37737.74 ( 90.86%)
Amean    p99-Write             6668722.09 (  0.00%)   666489.04 ( 90.01%)
Amean    p50-Allocation          78714.31 (  0.00%)    86286.22 ( -9.62%)
Amean    p95-Allocation         175533.51 (  0.00%)   351812.27 (-100.42%)
Amean    p99-Allocation         247003.02 (  0.00%)  6291171.56 (-2447.00%)

Of greater concern is that the patch causes swapping and page writes
from kswapd context rose from 0 pages to 4189753 pages during the hour
the workload ran for. By and large, the patch has very bad behaviour but
easily missed as the impact on a UMA machine is negligible.

This patch is included with the data in case a bisection leads to this area.
This patch is also a pre-requisite for the rest of the series.

Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/vmscan.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031ef994d..4ea444142c2e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3134,11 +3134,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		if (!managed_zone(zone))
 			continue;
 
-		if (!zone_balanced(zone, order, classzone_idx))
-			return false;
+		if (zone_balanced(zone, order, classzone_idx))
+			return true;
 	}
 
-	return true;
+	return false;
 }
 
 /*
@@ -3331,7 +3331,13 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
-	/* Try to sleep for a short interval */
+	/*
+	 * Try to sleep for a short interval. Note that kcompactd will only be
+	 * woken if it is possible to sleep for a short interval. This is
+	 * deliberate on the assumption that if reclaim cannot keep an
+	 * eligible zone balanced that it's also unlikely that compaction will
+	 * succeed.
+	 */
 	if (prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
 		/*
 		 * Compaction records what page blocks it recently failed to
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
