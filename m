Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 5D0D86B0070
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:15:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/5] vmscan: prevent excessive pageout of kswapd
Date: Wed, 22 Aug 2012 16:15:15 +0900
Message-Id: <1345619717-5322-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-1-git-send-email-minchan@kernel.org>
References: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

If higher zone is very small, priority could be raised easily
while lower zones have enough free pages. When one of lower zones
doesn't meet high watermark, the zone try to reclaim pages with
the high prioirty which is increased by higher small zone.
It ends up reclaiming excessive pages. I saw 8~16M pageout
in my KVM test although we need just a few Kbytes.

This patch decrease the priority temporally by average between
current and previous reclaim prioirty and if we can't reclaim
enough pages with the priority, we can use the big jumped high
priority continuosly.

==DRIVER                      mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Name                          mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Elapsed                       663                           665       (2.00,    0.30%)
nr_vmscan_write               1341                          849       (-492.00, -36.69%)
nr_vmscan_immediate_reclaim   0                             8         (8.00,    0.00%)
pgpgin                        21668                         30280     (8612.00, 39.75%)
pgpgout                       8392                          6396      (-1996.00,-23.78%)
pswpin                        22                            8         (-14.00,  -63.64%)
pswpout                       1341                          849       (-492.00, -36.69%)
pgactivate                    16217                         15959     (-258.00, -1.59%)
pgdeactivate                  15431                         15303     (-128.00, -0.83%)
pgfault                       204524355                     204524410 (55.00,   0.00%)
pgmajfault                    204472528                     204472602 (74.00,   0.00%)
pgsteal_kswapd_dma            466676                        475265    (8589.00, 1.84%)
pgsteal_kswapd_normal         49663877                      51289479  (1625602.00,3.27%)
pgsteal_kswapd_high           138182330                     135817904 (-2364426.00,-1.71%)
pgsteal_kswapd_movable        4236726                       4380123   (143397.00,3.38%)
pgsteal_direct_dma            9306                          11910     (2604.00, 27.98%)
pgsteal_direct_normal         123835                        165012    (41177.00,33.25%)
pgsteal_direct_high           274887                        309271    (34384.00,12.51%)
pgsteal_direct_movable        38011                         45638     (7627.00, 20.07%)
pgscan_kswapd_dma             947813                        972089    (24276.00,2.56%)
pgscan_kswapd_normal          97902722                      100850050 (2947328.00,3.01%)
pgscan_kswapd_high            274337809                     269039236 (-5298573.00,-1.93%)
pgscan_kswapd_movable         8496474                       8774392   (277918.00,3.27%)
pgscan_direct_dma             22855                         26410     (3555.00, 15.55%)
pgscan_direct_normal          3604954                       4186439   (581485.00,16.13%)
pgscan_direct_high            4504909                       5132110   (627201.00,13.92%)
pgscan_direct_movable         105418                        122790    (17372.00,16.48%)
pgscan_direct_throttle        0                             0         (0.00,    0.00%)
pginodesteal                  11111                         6836      (-4275.00,-38.48%)
slabs_scanned                 56320                         56320     (0.00,    0.00%)
kswapd_inodesteal             31121                         35904     (4783.00, 15.37%)
kswapd_low_wmark_hit_quickly  4607                          5193      (586.00,  12.72%)
kswapd_high_wmark_hit_quickly 432                           421       (-11.00,  -2.55%)
kswapd_skip_congestion_wait   10254                         12375     (2121.00, 20.68%)
pageoutrun                    2879697                       3071912   (192215.00,6.67%)
allocstall                    8222                          9727      (1505.00, 18.30%)
pgrotated                     1341                          850       (-491.00, -36.61%)
kswapd_totalscan              381684818                     379635767 (-2049051.00,-0.54%)
kswapd_totalsteal             192549609                     191962771 (-586838.00,-0.30%)
Kswapd_efficiency             50.00                         50.00     (0.00,    0.00%)
direct_totalscan              8238136                       9467749   (1229613.00,14.93%)
direct_totalsteal             446039                        531831    (85792.00,19.23%)
direct_efficiency             5.00                          5.00      (0.00,    0.00%)
reclaim_velocity              588119.08                     585118.06 (-3001.02,-0.51%)

Elapsed time of test program is rather increased compared to
previous patch[2/5] but the number of reclaimed pages is much decreased.

before-patch: 192995648  after-patch: 192494602 diff: 501046(about 2G)

Since kswapd reclaimed smaller pages per turn compared to old behavior,
kswapd's pageoutrun is increased and allocstall is also increased
by about 18%. Yeb. It's not good in this workload but old behavior
worked well by just *luck* which reclaimed too many pages than
necessary amount so we could avoid frequent reclaim path.
As downside of that, it might evict part of working set and this patch
will prevent that problem without big downside, I believe.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |   24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d1ebe69..0e2550c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2492,6 +2492,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
+	int prev_priority[MAX_NR_ZONES];
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
@@ -2513,6 +2514,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 loop_again:
 	total_scanned = 0;
 	sc.priority = DEF_PRIORITY;
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		prev_priority[i] = DEF_PRIORITY;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
@@ -2635,6 +2638,21 @@ loop_again:
 				    !zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
+				/*
+				 * If higher zone is very small, priority could
+				 * be raised easily while lower zones have
+				 * enough free pages. When one of lower zones
+				 * doesn't meet high watermark, the zone try to
+				 * reclaim pages with high prioirty which is
+				 * increased by higher small zone. It ends up
+				 * reclaiming excessive pages.
+				 * Let's decrease the priority temporally.
+				 */
+				int tmp_priority = sc.priority;
+				if ((prev_priority[i] - sc.priority) > 1)
+					sc.priority = (prev_priority[i] +
+							sc.priority) >> 1;
+
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
@@ -2644,7 +2662,11 @@ loop_again:
 
 				if (nr_slab == 0 && !zone_reclaimable(zone))
 					zone->all_unreclaimable = 1;
-			}
+
+				prev_priority[i] = tmp_priority;
+				sc.priority = tmp_priority;
+			} else
+				prev_priority[i] = DEF_PRIORITY;
 
 			/*
 			 * If we've done a decent amount of scanning and
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
