Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D39DA6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 02:00:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v63so8079582pgv.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 23:00:50 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u26si430088pge.31.2017.02.21.23.00.38
        for <linux-mm@kvack.org>;
        Tue, 21 Feb 2017 23:00:39 -0800 (PST)
Date: Wed, 22 Feb 2017 16:00:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: fix zone balance check in
 prepare_kswapd_sleep
Message-ID: <20170222070036.GA17962@bbox>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170215092247.15989-2-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi,

On Wed, Feb 15, 2017 at 09:22:45AM +0000, Mel Gorman wrote:
> From: Shantanu Goel <sgoel01@yahoo.com>
> 
> The check in prepare_kswapd_sleep needs to match the one in balance_pgdat
> since the latter will return as soon as any one of the zones in the
> classzone is above the watermark.  This is specially important for higher
> order allocations since balance_pgdat will typically reset the order to
> zero relying on compaction to create the higher order pages.  Without this
> patch, prepare_kswapd_sleep fails to wake up kcompactd since the zone
> balance check fails.
> 
> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the
> zone balance check between balance_pgdat() and prepare_kswapd_sleep().
> balance_pgdat() returns as soon as a single zone satisfies the allocation
> but prepare_kswapd_sleep() requires all zones to do +the same.  This causes
> prepare_kswapd_sleep() to never succeed except in the order == 0 case and
> consequently, wakeup_kcompactd() is never called.  On my machine prior to
> apply this patch, the state of compaction from /proc/vmstat looked this
> way after a day and a half +of uptime:
> 
> compact_migrate_scanned 240496
> compact_free_scanned 76238632
> compact_isolated 123472
> compact_stall 1791
> compact_fail 29
> compact_success 1762
> compact_daemon_wake 0
> 
> After applying the patch and about 10 hours of uptime the state looks
> like this:
> 
> compact_migrate_scanned 59927299
> compact_free_scanned 2021075136
> compact_isolated 640926
> compact_stall 4
> compact_fail 2
> compact_success 2
> compact_daemon_wake 5160
> 
> Further notes from Mel that motivated him to pick this patch up and
> resend it;
> 
> It was observed for the simoop workload (pressures the VM similar to HADOOP)
> that kswapd was failing to keep ahead of direct reclaim. The investigation
> noted that there was a need to rationalise kswapd decisions to reclaim
> with kswapd decisions to sleep. With this patch on a 2-socket box, there
> was a 43% reduction in direct reclaim scanning.
> 
> However, the impact otherwise is extremely negative. Kswapd reclaim
> efficiency dropped from 98% to 76%. simoop has three latency-related
> metrics for read, write and allocation (an anonymous mmap and fault).
> 
>                                          4.10.0-rc7            4.10.0-rc7
>                                      mmots-20170209           fixcheck-v1
> Amean    p50-Read             22325202.49 (  0.00%) 20026926.55 ( 10.29%)
> Amean    p95-Read             26102988.80 (  0.00%) 27023360.00 ( -3.53%)
> Amean    p99-Read             30935176.53 (  0.00%) 30994432.00 ( -0.19%)
> Amean    p50-Write                 976.44 (  0.00%)     1905.28 (-95.12%)
> Amean    p95-Write               15471.29 (  0.00%)    36210.09 (-134.05%)
> Amean    p99-Write               35108.62 (  0.00%)   479494.96 (-1265.75%)
> Amean    p50-Allocation          76382.61 (  0.00%)    87603.20 (-14.69%)
> Amean    p95-Allocation         127777.39 (  0.00%)   244491.38 (-91.34%)
> Amean    p99-Allocation         187937.39 (  0.00%)  1745237.33 (-828.63%)
> 
> There are also more allocation stalls. One of the largest impacts was due
> to pages written back from kswapd context rising from 0 pages to 4516642
> pages during the hour the workload ran for. By and large, the patch has very
> bad behaviour but easily missed as the impact on a UMA machine is negligible.
> 
> This patch is included with the data in case a bisection leads to this area.
> This patch is also a pre-requisite for the rest of the series.
> 
> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Hmm, I don't understand why we should bind wakeup_kcompactd to kswapd's
short sleep point where every eligible zones are balanced.
What's the correlation between them?

Can't we wake up kcompactd once we found a zone has enough free pages
above high watermark like this?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 26c3b405ef34..f4f0ad0e9ede 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3346,13 +3346,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 		 * that pages and compaction may succeed so reset the cache.
 		 */
 		reset_isolation_suitable(pgdat);
-
-		/*
-		 * We have freed the memory, now we should compact it to make
-		 * allocation of the requested order possible.
-		 */
-		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
-
 		remaining = schedule_timeout(HZ/10);
 
 		/*
@@ -3451,6 +3444,14 @@ static int kswapd(void *p)
 		bool ret;
 
 kswapd_try_sleep:
+		/*
+		 * We have freed the memory, now we should compact it to make
+		 * allocation of the requested order possible.
+		 */
+		if (alloc_order > 0 && zone_balanced(zone, reclaim_order,
+							classzone_idx))
+			wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
+
 		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
 					classzone_idx);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
