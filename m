Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4A156830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:38:38 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id c200so15930734wme.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:38:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si12498658wjz.111.2016.02.08.05.38.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:38:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking up kcompactd
Date: Mon,  8 Feb 2016 14:38:10 +0100
Message-Id: <1454938691-2197-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

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
goes to sleep. We pass kswapd's order and classzone_idx, so kcompactd can apply
the same criteria to determine which zones are worth compacting. Note that we
use the classzone_idx from wakeup_kswapd(), not balanced_classzone_idx which
can include higher zones that kswapd tried to balance too, but didn't consider
them in pgdat_balanced().

Since kswapd now cannot create high-order pages itself, we need to adjust how
it determines the zones to be balanced. The key element here is adding a
"highorder" parameter to zone_balanced, which, when set to false, makes it
consider only order-0 watermark instead of the desired higher order (this was
done previously by kswapd_shrink_zone(), but not elsewhere).  This false is
passed for example in pgdat_balanced(). Importantly, wakeup_kswapd() uses true
to make sure kswapd and thus kcompactd are woken up for a high-order allocation
failure.

For testing, I used stress-highalloc configured to do order-9 allocations with
GFP_NOWAIT|__GFP_HIGH|__GFP_COMP, so they relied just on kswapd/kcompactd
reclaim/compaction (the interfering kernel builds in phases 1 and 2 work as
usual):

stress-highalloc
                              4.5-rc1               4.5-rc1
                               3-test                4-test
Success 1 Min          1.00 (  0.00%)        3.00 (-200.00%)
Success 1 Mean         1.40 (  0.00%)        4.00 (-185.71%)
Success 1 Max          2.00 (  0.00%)        6.00 (-200.00%)
Success 2 Min          1.00 (  0.00%)        3.00 (-200.00%)
Success 2 Mean         1.80 (  0.00%)        4.20 (-133.33%)
Success 2 Max          3.00 (  0.00%)        6.00 (-100.00%)
Success 3 Min         34.00 (  0.00%)       63.00 (-85.29%)
Success 3 Mean        41.80 (  0.00%)       64.60 (-54.55%)
Success 3 Max         53.00 (  0.00%)       67.00 (-26.42%)

             4.5-rc1     4.5-rc1
              3-test      4-test
User         3166.67     3088.82
System       1153.37     1142.01
Elapsed      1768.53     1780.91

                                  4.5-rc1     4.5-rc1
                                   3-test      4-test
Minor Faults                    106940795   106582816
Major Faults                          829         813
Swap Ins                              482         311
Swap Outs                            6278        5598
Allocation stalls                     128         184
DMA allocs                            145          32
DMA32 allocs                     74646161    74843238
Normal allocs                    26090955    25886668
Movable allocs                          0           0
Direct pages scanned                32938       31429
Kswapd pages scanned              2183166     2185293
Kswapd pages reclaimed            2152359     2134389
Direct pages reclaimed              32735       31234
Kswapd efficiency                     98%         97%
Kswapd velocity                  1243.877    1228.666
Direct efficiency                     99%         99%
Direct velocity                    18.767      17.671
Percentage direct scans                1%          1%
Zone normal velocity              299.981     291.409
Zone dma32 velocity               962.522     954.928
Zone dma velocity                   0.142       0.000
Page writes by reclaim           6278.800    5598.600
Page writes file                        0           0
Page writes anon                     6278        5598
Page reclaim immediate                 93          96
Sector Reads                      4357114     4307161
Sector Writes                    11053628    11053091
Page rescued immediate                  0           0
Slabs scanned                     1592829     1555770
Direct inode steals                  1557        2025
Kswapd inode steals                 46056       45418
Kswapd skipped wait                     0           0
THP fault alloc                       579         614
THP collapse alloc                    304         324
THP splits                              0           0
THP fault fallback                    793         730
THP collapse fail                      11          14
Compaction stalls                    1013         959
Compaction success                     92          69
Compaction failures                   920         890
Page migrate success               238457      662054
Page migrate failure                23021       32846
Compaction pages isolated          504695     1370326
Compaction migrate scanned         661390     7025772
Compaction free scanned          13476658    73302642
Compaction cost                       262         762

After this patch we see improvements in allocation success rate (especially for
phase 3) along with increased compaction activity. The compaction stalls
(direct compaction) in the interfering kernel builds (probably THP's) also
decreased somewhat to kcompactd activity, yet THP alloc successes improved a
bit.

We can also configure stress-highalloc to perform both direct
reclaim/compaction and wakeup kswapd/kcompactd, by using
GFP_KERNEL|__GFP_HIGH|__GFP_COMP:

stress-highalloc
                              4.5-rc1               4.5-rc1
                              3-test2               4-test2
Success 1 Min          4.00 (  0.00%)        6.00 (-50.00%)
Success 1 Mean         8.00 (  0.00%)        8.40 ( -5.00%)
Success 1 Max         12.00 (  0.00%)       13.00 ( -8.33%)
Success 2 Min          4.00 (  0.00%)        6.00 (-50.00%)
Success 2 Mean         8.20 (  0.00%)        8.60 ( -4.88%)
Success 2 Max         13.00 (  0.00%)       12.00 (  7.69%)
Success 3 Min         75.00 (  0.00%)       75.00 (  0.00%)
Success 3 Mean        75.60 (  0.00%)       75.60 (  0.00%)
Success 3 Max         77.00 (  0.00%)       76.00 (  1.30%)

             4.5-rc1     4.5-rc1
             3-test2     4-test2
User         3344.73     3258.62
System       1194.24     1177.92
Elapsed      1838.04     1837.02

                                  4.5-rc1     4.5-rc1
                                  3-test2     4-test2
Minor Faults                    111269736   109392253
Major Faults                          806         755
Swap Ins                              671         155
Swap Outs                            5390        5790
Allocation stalls                    4610        4562
DMA allocs                            250          34
DMA32 allocs                     78091501    76901680
Normal allocs                    27004414    26587089
Movable allocs                          0           0
Direct pages scanned               125146      108854
Kswapd pages scanned              2119757     2131589
Kswapd pages reclaimed            2073183     2090937
Direct pages reclaimed             124909      108699
Kswapd efficiency                     97%         98%
Kswapd velocity                  1161.027    1160.870
Direct efficiency                     99%         99%
Direct velocity                    68.545      59.283
Percentage direct scans                5%          4%
Zone normal velocity              296.678     294.389
Zone dma32 velocity               932.841     925.764
Zone dma velocity                   0.053       0.000
Page writes by reclaim           5392.000    5790.600
Page writes file                        1           0
Page writes anon                     5390        5790
Page reclaim immediate                104         218
Sector Reads                      4350232     4376989
Sector Writes                    11126496    11102113
Page rescued immediate                  0           0
Slabs scanned                     1705294     1692486
Direct inode steals                  8700       16266
Kswapd inode steals                 36352       28364
Kswapd skipped wait                     0           0
THP fault alloc                       599         567
THP collapse alloc                    323         326
THP splits                              0           0
THP fault fallback                    806         805
THP collapse fail                      17          18
Compaction stalls                    2457        2070
Compaction success                    906         527
Compaction failures                  1551        1543
Page migrate success              2031423     2423657
Page migrate failure                32845       28790
Compaction pages isolated         4129761     4916017
Compaction migrate scanned       11996712    19370264
Compaction free scanned         214970969   360662356
Compaction cost                      2271        2745

Here, this patch doesn't change the success rate as direct compaction already
tries what it can. There's however significant reduction in direct compaction
stalls, made entirely of the successful stalls. This means the offload to
kcompactd is working as expected, and direct compaction is reduced either due
to detecting contention, or compaction deferred by kcompactd. In the previous
version of this patchset there was some apparent reduction of success rate,
but the changes in this version (such as using sync compaction only), new
baseline kernel, and/or averaging results from 5 executions (my bet), made this
go away.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 146 ++++++++++++++++++++----------------------------------------
 1 file changed, 48 insertions(+), 98 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c67df4831565..b8478a737ef5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2951,18 +2951,23 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
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
@@ -3012,7 +3017,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 			continue;
 		}
 
-		if (zone_balanced(zone, order, 0, i))
+		if (zone_balanced(zone, order, false, 0, i))
 			balanced_pages += zone->managed_pages;
 		else if (!order)
 			return false;
@@ -3066,8 +3071,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  */
 static bool kswapd_shrink_zone(struct zone *zone,
 			       int classzone_idx,
-			       struct scan_control *sc,
-			       unsigned long *nr_attempted)
+			       struct scan_control *sc)
 {
 	int testorder = sc->order;
 	unsigned long balance_gap;
@@ -3077,17 +3081,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
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
@@ -3101,15 +3094,12 @@ static bool kswapd_shrink_zone(struct zone *zone,
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
@@ -3119,7 +3109,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * waits.
 	 */
 	if (zone_reclaimable(zone) &&
-	    zone_balanced(zone, testorder, 0, classzone_idx)) {
+	    zone_balanced(zone, testorder, false, 0, classzone_idx)) {
 		clear_bit(ZONE_CONGESTED, &zone->flags);
 		clear_bit(ZONE_DIRTY, &zone->flags);
 	}
@@ -3131,7 +3121,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
  *
- * Returns the final order kswapd was reclaiming at
+ * Returns the highest zone idx kswapd was reclaiming at
  *
  * There is special handling here for zones which are full of pinned pages.
  * This can happen if the pages are all mlocked, or if they are all used by
@@ -3148,8 +3138,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
-							int *classzone_idx)
+static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -3166,9 +3155,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	count_vm_event(PAGEOUTRUN);
 
 	do {
-		unsigned long nr_attempted = 0;
 		bool raise_priority = true;
-		bool pgdat_needs_compaction = (order > 0);
 
 		sc.nr_reclaimed = 0;
 
@@ -3203,7 +3190,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, true, 0, 0)) {
 				end_zone = i;
 				break;
 			} else {
@@ -3219,24 +3206,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
@@ -3280,8 +3249,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * that that high watermark would be met at 100%
 			 * efficiency.
 			 */
-			if (kswapd_shrink_zone(zone, end_zone,
-					       &sc, &nr_attempted))
+			if (kswapd_shrink_zone(zone, end_zone, &sc))
 				raise_priority = false;
 		}
 
@@ -3294,49 +3262,29 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
+static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
+				int classzone_idx, int balanced_classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
@@ -3347,7 +3295,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
-	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining,
+						balanced_classzone_idx)) {
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -3357,7 +3306,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining,
+						balanced_classzone_idx)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
@@ -3378,6 +3328,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		reset_isolation_suitable(pgdat);
 
+		/*
+		 * We have freed the memory, now we should compact it to make
+		 * allocation of the requested order possible.
+		 */
+		wakeup_kcompactd(pgdat, order, classzone_idx);
+
 		if (!kthread_should_stop())
 			schedule();
 
@@ -3407,7 +3363,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 static int kswapd(void *p)
 {
 	unsigned long order, new_order;
-	unsigned balanced_order;
 	int classzone_idx, new_classzone_idx;
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
@@ -3440,23 +3395,19 @@ static int kswapd(void *p)
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
@@ -3466,7 +3417,7 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, balanced_order,
+			kswapd_try_to_sleep(pgdat, order, classzone_idx,
 						balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
@@ -3486,9 +3437,8 @@ static int kswapd(void *p)
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
 
@@ -3518,7 +3468,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
