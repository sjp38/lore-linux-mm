Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B421C6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:14:58 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/5] vmscan: sleep only if backingdev is congested
Date: Wed, 22 Aug 2012 16:15:14 +0900
Message-Id: <1345619717-5322-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-1-git-send-email-minchan@kernel.org>
References: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

In small high zone(ex, 40M movable zone), reclaim priority
could be raised easily so congestion_wait of balance_pgdat can make
kswapd sleep unnecessarily so process ends up entering into direct
reclaim path. It means processes's latency would be longer.

This patch changes congestion_wait with wait_iff_congested so kswapd
will sleep only if backdev really is congested.

==DRIVER                      mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Name                          mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Elapsed                       676                           663       (-13.00,  -1.92%)
nr_vmscan_write               91                            1341      (1250.00, 1373.63%)
nr_vmscan_immediate_reclaim   0                             0         (0.00,    0.00%)
pgpgin                        29932                         21668     (-8264.00,-27.61%)
pgpgout                       3652                          8392      (4740.00, 129.79%)
pswpin                        0                             22        (22.00,   0.00%)
pswpout                       91                            1341      (1250.00, 1373.63%)
pgactivate                    15686                         16217     (531.00,  3.39%)
pgdeactivate                  14171                         15431     (1260.00, 8.89%)
pgfault                       204523237                     204524355 (1118.00, 0.00%)
pgmajfault                    204472586                     204472528 (-58.00,  -0.00%)
pgsteal_kswapd_dma            149066                        466676    (317610.00,213.07%)
pgsteal_kswapd_normal         56219654                      49663877  (-6555777.00,-11.66%)
pgsteal_kswapd_high           92860817                      138182330 (45321513.00,48.81%)
pgsteal_kswapd_movable        1211389                       4236726   (3025337.00,249.74%)
pgsteal_direct_dma            35808                         9306      (-26502.00,-74.01%)
pgsteal_direct_normal         21270282                      123835    (-21146447.00,-99.42%)
pgsteal_direct_high           21051650                      274887    (-20776763.00,-98.69%)
pgsteal_direct_movable        250572                        38011     (-212561.00,-84.83%)
pgscan_kswapd_dma             325126                        947813    (622687.00,191.52%)
pgscan_kswapd_normal          111171753                     97902722  (-13269031.00,-11.94%)
pgscan_kswapd_high            178149789                     274337809 (96188020.00,53.99%)
pgscan_kswapd_movable         2537926                       8496474   (5958548.00,234.78%)
pgscan_direct_dma             56919                         22855     (-34064.00,-59.85%)
pgscan_direct_normal          45698152                      3604954   (-42093198.00,-92.11%)
pgscan_direct_high            51326549                      4504909   (-46821640.00,-91.22%)
pgscan_direct_movable         433830                        105418    (-328412.00,-75.70%)
pgscan_direct_throttle        0                             0         (0.00,    0.00%)
pginodesteal                  6721                          11111     (4390.00, 65.32%)
slabs_scanned                 57344                         56320     (-1024.00,-1.79%)
kswapd_inodesteal             36327                         31121     (-5206.00,-14.33%)
kswapd_low_wmark_hit_quickly  533                           4607      (4074.00, 764.35%)
kswapd_high_wmark_hit_quickly 39                            432       (393.00,  1007.69%)
kswapd_skip_congestion_wait   71505                         10254     (-61251.00,-85.66%)
pageoutrun                    2406110                       2879697   (473587.00,19.68%)
allocstall                    696424                        8222      (-688202.00,-98.82%)
pgrotated                     91                            1341      (1250.00, 1373.63%)
kswapd_totalscan              292184594                     381684818 (89500224.00,30.63%)
kswapd_totalsteal             150440926                     192549609 (42108683.00,27.99%)
Kswapd_efficiency             51.00                         50.00     (-1.00,   -1.96%)
direct_totalscan              97515450                      8238136   (-89277314.00,-91.55%)
direct_totalsteal             42608312                      446039    (-42162273.00,-98.95%)
direct_efficiency             43.00                         5.00      (-38.00,  -88.37%)
reclaim_velocity              576479.35                     588119.08 (11639.73,2.02%)

Elapsed time of test program is reduced by 13 second.
As I expected, kswapd scanning/reclaim ratio is increased about 30%
but kswapd's efficiency is still good. We reduced allocstall about 98%
so I think it's most important factor for reducing elapsed time of
test program.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f015d92..d1ebe69 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2705,8 +2705,16 @@ loop_again:
 		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
-			else
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+			else {
+				for (i = 0; i <= end_zone; i++) {
+					struct zone *zone = pgdat->node_zones
+								+ i;
+					if (!populated_zone(zone))
+						continue;
+					wait_iff_congested(zone, BLK_RW_ASYNC,
+								HZ/10);
+				}
+			}
 		}
 
 		/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
