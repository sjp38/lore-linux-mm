Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 320786B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:36:44 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l65so109179616wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:36:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w130si6176175wma.82.2016.01.26.07.36.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:36:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/3] mm, kswapd: stop performing compaction from kswapd
Date: Tue, 26 Jan 2016 16:36:15 +0100
Message-Id: <1453822575-20835-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
References: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

Similarly to direct reclaim/compaction, kswapd attempts to combine reclaim and
compaction to attempt making memory allocation of given order available. The
details differ from direct reclaim e.g. in having high watermark as a goal.
The code involved in kswapd's reclaim/compaction decisions has evolved to be
quite complex. Testing reveals that it doesn't actually work in at least one
scenario, and closer inspection suggests that it could be greatly simplified
without compromising on the goal (make high-order page available) or efficiency
(don't reclaim too much). The simplification relieas of doing all compaction in
kcompactd, which is simply woken up when high watermarks are reached by
kswapd's reclaim.

The scenario where kswapd compaction doesn't work was found with mmtests test
stress-highalloc configured to attempt order-9 allocations without direct
reclaim, just waking up kswapd. There was no compaction attempt from kswapd
during the whole test. Some added instrumentation shows what happens:

- balance_pgdat() sets end_zone to Normal, as it's not balanced
- reclaim is attempted on DMA zone, which sets nr_attempted to 99, but it
  cannot reclaim anything, so sc.nr_reclaimed is 0
- for zones DMA32 and Normal, kswapd_shrink_zone uses testorder=0, so it
  merely checks if high watermarks were reached for base pages. This is true,
  so no reclaim is attempted. For DMA, testorder=0 wasn't used, as
  compaction_suitable() returned COMPACT_SKIPPED
- even though the pgdat_needs_compaction flag wasn't set to false, no
  compaction happens due to the condition sc.nr_reclaimed > nr_attempted
  being false (as 0 < 99)
- priority-- due to nr_reclaimed being 0, repeat until priority reaches 0
  pgdat_balanced() is false as only the small zone DMA appears balanced
  (curiously in that check, watermark appears OK and compaction_suitable()
  returns COMPACT_PARTIAL, because a lower classzone_idx is used there)

Now, even if it was decided that reclaim shouldn't be attempted on the DMA
zone, the scenario would be the same, as (sc.nr_reclaimed=0 > nr_attempted=0)
is also false. The condition really should use >= as the comment suggests.
Then there is a mismatch in the check for setting pgdat_needs_compaction to
false using low watermark, while the rest uses high watermark, and who knows
what other subtlety. Hopefully this demonstrates that this is unsustainable.

Luckily we can simplify this a lot. The reclaim/compaction decisions make
sense for direct reclaim scenario, but in kswapd, our primary goal is to reach
high watermark in order-0 pages. Afterwards we can attempt compaction just
once. Unlike direct reclaim, we don't reclaim extra pages (over the high
watermark), the current code already disallows it for good reasons.

After this patch, we simply wake up kcompactd to process the pgdat, after we
have either succeeded or failed to reach the high watermarks in kswapd, which
goes to sleep. Kcompactd will apply the usual criteria to determine which
zones are worth compacting. The key element is adding a "highorder" parameter
to zone_balanced, which, when set to false, makes it consider only order-0
watermark instead of the desired higher order (this was done previously by
kswapd_shrink_zone(), but not elsewhere). This false is passed for example
in pgdat_balanced(). Importantly, wakeup_kswapd() uses true to make sure kswapd
and thus kcompactd are woken up for a high-order allocation failure.

For testing, I used stress-highalloc configured to do order-9 allocations with
GFP_NOWAIT|__GFP_HIGH|__GFP_COMP, so they relied just on kswapd/kcompactd
reclaim/compaction (the interfering kernel builds in phases 1 and 2 work as
usual):

stress-highalloc
                            4.4                   4.4                   4.4
                         1-test                2-test                3-test
Success 1        4.00 (  0.00%)        3.00 ( 25.00%)        9.00 (-125.00%)
Success 2        4.00 (  0.00%)        4.00 (  0.00%)       10.00 (-150.00%)
Success 3       38.00 (  0.00%)       38.00 (  0.00%)       76.00 (-100.00%)

                 4.4         4.4         4.4
              1-test      2-test      3-test
User         2953.35     3093.48     3093.42
System       1122.04     1143.88     1156.99
Elapsed      1868.16     1874.77     1899.16

                                      4.4         4.4         4.4
                                   1-test      2-test      3-test
Minor Faults                    108895488   109087527   109388744
Major Faults                          620         604         750
Swap Ins                              237         280         412
Swap Outs                            3722        4585        3691
Allocation stalls                     321         313         260
DMA allocs                            110         159           7
DMA32 allocs                     76286159    76181606    76855688
Normal allocs                    26568981    26483685    26719273
Movable allocs                          0           0           0
Direct pages scanned                53308       46054       47504
Kswapd pages scanned              2126926     2156583     2180757
Kswapd pages reclaimed            2119616     2134575     2173845
Direct pages reclaimed              53141       45355       47336
Kswapd efficiency                     99%         98%         99%
Kswapd velocity                  1138.514    1150.319    1148.275
Direct efficiency                     99%         98%         99%
Direct velocity                    28.535      24.565      25.013
Percentage direct scans                2%          2%          2%
Zone normal velocity              284.759     275.373     280.962
Zone dma32 velocity               882.278     899.486     892.326
Zone dma velocity                   0.012       0.025       0.000
Page writes by reclaim           3722.000    4585.000    3691.000
Page writes file                        0           0           0
Page writes anon                     3722        4585        3691
Page reclaim immediate                139         293         245
Sector Reads                      4392000     4389436     4434052
Sector Writes                    11082116    11088032    11102164
Page rescued immediate                  0           0           0
Slabs scanned                     1554185     1546949     1573151
Direct inode steals                 17675       27398        3110
Kswapd inode steals                 49005       38837       63606
Kswapd skipped wait                     0           0           0
THP fault alloc                       816         725         784
THP collapse alloc                    429         351         368
THP splits                              5           4           7
THP fault fallback                    583         619         561
THP collapse fail                      12          12          13
Compaction stalls                    1082        1064         924
Compaction success                    185         134         113
Compaction failures                   897         930         811
Page migrate success               547663      555349     1357157
Page migrate failure                23289        9299       23159
Compaction pages isolated         1143892     1146019     2810572
Compaction migrate scanned        1518500     1463701     7626063
Compaction free scanned          35478038    32735896   326240264
Compaction cost                       601         608        1515

We can see that just adding kcompactd (second column) didn't help, as kswapd
was failing to do anything and went sleep with balanced_order=0, therefore
kcompactd didn't receive the correct order=9. After this patch (third column)
we see improvements in allocation success rate along with increased compaction
activity. The compaction stalls (direct compaction) in the interfering kernel
builds (probably THP's) also decreased by 10% thanks to kcompactd activity.
THP alloc successes are somewhat unstable (there should be no difference
between patch 1 and 2) but it doesn't look like a regression for this patch.

We can also configure stress-highalloc to perform both direct
reclaim/compaction and wakeup kswapd/kcompactd, by using
GFP_KERNEL|__GFP_HIGH|__GFP_COMP:

stress-highalloc
                            4.4                   4.4                   4.4
                        1-test2               2-test2               3-test2
Success 1       13.00 (  0.00%)       11.00 ( 15.38%)        7.00 ( 46.15%)
Success 2       14.00 (  0.00%)       12.00 ( 14.29%)        7.00 ( 50.00%)
Success 3       77.00 (  0.00%)       80.00 ( -3.90%)       79.00 ( -2.60%)

                 4.4         4.4         4.4
             1-test2     2-test2     3-test2
User         3109.78     3160.65     3141.30
System       1156.71     1169.76     1164.30
Elapsed      1890.71     1931.35     1883.46

                                      4.4         4.4         4.4
                                  1-test2     2-test2     3-test2
Minor Faults                    110079446   111295014   110632582
Major Faults                          612         612         627
Swap Ins                              223         191         174
Swap Outs                            4829        4285        4796
Allocation stalls                    4516        4571        4577
DMA allocs                            129         164          12
DMA32 allocs                     77336335    78049863    77568017
Normal allocs                    26946355    27371021    26879992
Movable allocs                          0           0           0
Direct pages scanned               164893      159692      113793
Kswapd pages scanned              2115489     2076764     2099869
Kswapd pages reclaimed            2107476     2069146     2091612
Direct pages reclaimed             164268      158978      113527
Kswapd efficiency                     99%         99%         99%
Kswapd velocity                  1118.886    1075.291    1114.900
Direct efficiency                     99%         99%         99%
Direct velocity                    87.212      82.684      60.417
Percentage direct scans                7%          7%          5%
Zone normal velocity              289.128     301.114     280.090
Zone dma32 velocity               916.944     856.826     895.227
Zone dma velocity                   0.026       0.036       0.000
Page writes by reclaim           4829.000    4285.000    4796.000
Page writes file                        0           0           0
Page writes anon                     4829        4285        4796
Page reclaim immediate                274         379          30
Sector Reads                      4465640     4469740     4431932
Sector Writes                    11117364    11126004    11117220
Page rescued immediate                  0           0           0
Slabs scanned                     1677445     1882706     1655883
Direct inode steals                  8364       16551        5725
Kswapd inode steals                 65367       61029       67560
Kswapd skipped wait                     0           0           0
THP fault alloc                       769         686         685
THP collapse alloc                    332         356         368
THP splits                              3           2           2
THP fault fallback                    691         731         658
THP collapse fail                      20          20          21
Compaction stalls                    2686        2749        2256
Compaction success                    889         955         512
Compaction failures                  1797        1794        1744
Page migrate success              2442538     2396245     3044899
Page migrate failure                31276       32952       58085
Compaction pages isolated         4963155     4875568     6204653
Compaction migrate scanned       17004834    13387834    20155758
Compaction free scanned         269507706   259687893   437874337
Compaction cost                      2749        2674        3420

Here, this patch does lower the success rate for phases 1 and 2 with
interference, but importantly phase 3 (no interference) is the same.  There's
however significant reduction in direct compaction stalls, made entirely of the
successful stalls. This means the offload to kcompactd is working as expected,
and direct compaction is reduced either due to detecting contention, on
compaction deferred by kcompactd. The apparent regression of alloc success rate
is likely due to races - a direct compaction attempt immediately followed by
allocation attempt is more likely to succeed than when the allocation attempts
are asynchronous to kcompactd activity. This is the price for reduced
latencies.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 131 +++++++++++++++++-------------------------------------------
 1 file changed, 36 insertions(+), 95 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1449e21c55cc..dd4ccce93509 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2981,18 +2981,23 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	} while (memcg);
 }
 
-static bool zone_balanced(struct zone *zone, int order,
-			  unsigned long balance_gap, int classzone_idx)
+static bool zone_balanced(struct zone *zone, int order, bool highorder,
+			unsigned long balance_gap, int classzone_idx)
 {
-	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
-				    balance_gap, classzone_idx))
-		return false;
+	unsigned long mark = high_wmark_pages(zone) + balance_gap;
 
-	if (IS_ENABLED(CONFIG_COMPACTION) && order && compaction_suitable(zone,
-				order, 0, classzone_idx) == COMPACT_SKIPPED)
-		return false;
+	/*
+	 * When checking from pgdat_balanced(), kswapd should stop and sleep
+	 * when it reaches the high order-0 watermark and let kcompactd take
+	 * over. Other callers such as wakeup_kswapd() want to determine the
+	 * true high-order watermark.
+	 */
+	if (IS_ENABLED(CONFIG_COMPACTION) && !highorder) {
+		mark += (1UL << order);
+		order = 0;
+	}
 
-	return true;
+	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
 }
 
 /*
@@ -3042,7 +3047,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 			continue;
 		}
 
-		if (zone_balanced(zone, order, 0, i))
+		if (zone_balanced(zone, order, false, 0, i))
 			balanced_pages += zone->managed_pages;
 		else if (!order)
 			return false;
@@ -3096,8 +3101,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  */
 static bool kswapd_shrink_zone(struct zone *zone,
 			       int classzone_idx,
-			       struct scan_control *sc,
-			       unsigned long *nr_attempted)
+			       struct scan_control *sc)
 {
 	int testorder = sc->order;
 	unsigned long balance_gap;
@@ -3107,17 +3111,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
 
 	/*
-	 * Kswapd reclaims only single pages with compaction enabled. Trying
-	 * too hard to reclaim until contiguous free pages have become
-	 * available can hurt performance by evicting too much useful data
-	 * from memory. Do not reclaim more than needed for compaction.
-	 */
-	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
-			compaction_suitable(zone, sc->order, 0, classzone_idx)
-							!= COMPACT_SKIPPED)
-		testorder = 0;
-
-	/*
 	 * We put equal pressure on every zone, unless one zone has way too
 	 * many pages free already. The "too many pages" is defined as the
 	 * high wmark plus a "gap" where the gap is either the low
@@ -3131,15 +3124,12 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * reclaim is necessary
 	 */
 	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
-	if (!lowmem_pressure && zone_balanced(zone, testorder,
+	if (!lowmem_pressure && zone_balanced(zone, testorder, false,
 						balance_gap, classzone_idx))
 		return true;
 
 	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
 
-	/* Account for the number of pages attempted to reclaim */
-	*nr_attempted += sc->nr_to_reclaim;
-
 	clear_bit(ZONE_WRITEBACK, &zone->flags);
 
 	/*
@@ -3149,7 +3139,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * waits.
 	 */
 	if (zone_reclaimable(zone) &&
-	    zone_balanced(zone, testorder, 0, classzone_idx)) {
+	    zone_balanced(zone, testorder, false, 0, classzone_idx)) {
 		clear_bit(ZONE_CONGESTED, &zone->flags);
 		clear_bit(ZONE_DIRTY, &zone->flags);
 	}
@@ -3161,7 +3151,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
  *
- * Returns the final order kswapd was reclaiming at
+ * Returns the highest zone idx kswapd was reclaiming at
  *
  * There is special handling here for zones which are full of pinned pages.
  * This can happen if the pages are all mlocked, or if they are all used by
@@ -3178,8 +3168,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
-							int *classzone_idx)
+static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -3196,9 +3185,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	count_vm_event(PAGEOUTRUN);
 
 	do {
-		unsigned long nr_attempted = 0;
 		bool raise_priority = true;
-		bool pgdat_needs_compaction = (order > 0);
 
 		sc.nr_reclaimed = 0;
 
@@ -3233,7 +3220,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, true, 0, 0)) {
 				end_zone = i;
 				break;
 			} else {
@@ -3249,24 +3236,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		if (i < 0)
 			goto out;
 
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-
-			if (!populated_zone(zone))
-				continue;
-
-			/*
-			 * If any zone is currently balanced then kswapd will
-			 * not call compaction as it is expected that the
-			 * necessary pages are already available.
-			 */
-			if (pgdat_needs_compaction &&
-					zone_watermark_ok(zone, order,
-						low_wmark_pages(zone),
-						*classzone_idx, 0))
-				pgdat_needs_compaction = false;
-		}
-
 		/*
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
@@ -3310,8 +3279,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * that that high watermark would be met at 100%
 			 * efficiency.
 			 */
-			if (kswapd_shrink_zone(zone, end_zone,
-					       &sc, &nr_attempted))
+			if (kswapd_shrink_zone(zone, end_zone, &sc))
 				raise_priority = false;
 		}
 
@@ -3324,46 +3292,25 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up_all(&pgdat->pfmemalloc_wait);
 
-		/*
-		 * Fragmentation may mean that the system cannot be rebalanced
-		 * for high-order allocations in all zones. If twice the
-		 * allocation size has been reclaimed and the zones are still
-		 * not balanced then recheck the watermarks at order-0 to
-		 * prevent kswapd reclaiming excessively. Assume that a
-		 * process requested a high-order can direct reclaim/compact.
-		 */
-		if (order && sc.nr_reclaimed >= 2UL << order)
-			order = sc.order = 0;
-
 		/* Check if kswapd should be suspending */
 		if (try_to_freeze() || kthread_should_stop())
 			break;
 
 		/*
-		 * Compact if necessary and kswapd is reclaiming at least the
-		 * high watermark number of pages as requsted
-		 */
-		if (pgdat_needs_compaction && sc.nr_reclaimed > nr_attempted)
-			compact_pgdat(pgdat, order);
-
-		/*
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
 		if (raise_priority || !sc.nr_reclaimed)
 			sc.priority--;
 	} while (sc.priority >= 1 &&
-		 !pgdat_balanced(pgdat, order, *classzone_idx));
+			!pgdat_balanced(pgdat, order, classzone_idx));
 
 out:
 	/*
-	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
-	 * makes a decision on the order we were last reclaiming at. However,
-	 * if another caller entered the allocator slow path while kswapd
-	 * was awake, order will remain at the higher level
+	 * Return the highest zone idx we were reclaiming at so
+	 * prepare_kswapd_sleep() makes the same decisions as here.
 	 */
-	*classzone_idx = end_zone;
-	return order;
+	return end_zone;
 }
 
 static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
@@ -3443,7 +3390,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 static int kswapd(void *p)
 {
 	unsigned long order, new_order;
-	unsigned balanced_order;
 	int classzone_idx, new_classzone_idx;
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
@@ -3476,23 +3422,19 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = new_order = 0;
-	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
 	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		bool ret;
 
 		/*
-		 * If the last balance_pgdat was unsuccessful it's unlikely a
-		 * new request of a similar or harder type will succeed soon
-		 * so consider going to sleep on the basis we reclaimed at
+		 * While we were reclaiming, there might have been another
+		 * wakeup, so check the values.
 		 */
-		if (balanced_order == new_order) {
-			new_order = pgdat->kswapd_max_order;
-			new_classzone_idx = pgdat->classzone_idx;
-			pgdat->kswapd_max_order =  0;
-			pgdat->classzone_idx = pgdat->nr_zones - 1;
-		}
+		new_order = pgdat->kswapd_max_order;
+		new_classzone_idx = pgdat->classzone_idx;
+		pgdat->kswapd_max_order =  0;
+		pgdat->classzone_idx = pgdat->nr_zones - 1;
 
 		if (order < new_order || classzone_idx > new_classzone_idx) {
 			/*
@@ -3502,7 +3444,7 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, balanced_order,
+			kswapd_try_to_sleep(pgdat, order,
 						balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
@@ -3522,9 +3464,8 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balanced_classzone_idx = classzone_idx;
-			balanced_order = balance_pgdat(pgdat, order,
-						&balanced_classzone_idx);
+			balanced_classzone_idx = balance_pgdat(pgdat, order,
+								classzone_idx);
 		}
 	}
 
@@ -3554,7 +3495,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0))
+	if (zone_balanced(zone, order, true, 0, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
