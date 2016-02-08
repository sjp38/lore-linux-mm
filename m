Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id ACD37830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:38:40 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so116006425wmp.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:38:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xb7si42349408wjb.187.2016.02.08.05.38.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:38:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 5/5] mm, compaction: adapt isolation_suitable flushing to kcompactd
Date: Mon,  8 Feb 2016 14:38:11 +0100
Message-Id: <1454938691-2197-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

Compaction maintains a pageblock_skip bitmap to record pageblocks where
isolation recently failed. This bitmap can be reset by three ways:

1) direct compaction is restarting after going through the full deferred cycle

2) kswapd goes to sleep, and some other direct compaction has previously
   finished scanning the whole zone and set zone->compact_blockskip_flush.
   Note that a successful direct compaction clears this flag.

3) compaction was invoked manually via trigger in /proc

The case 2) is somewhat fuzzy to begin with, but after introducing kcompactd we
should update it. The check for direct compaction in 1), and to set the flush
flag in 2) use current_is_kswapd(), which doesn't work for kcompactd. Thus,
this patch adds bool direct_compaction to compact_control to use in 2). For
the case 1) we remove the check completely - unlike the former kswapd
compaction, kcompactd does use the deferred compaction functionality, so
flushing tied to restarting from deferred compaction makes sense here.

Note that when kswapd goes to sleep, kcompactd is woken up, so it will see the
flushed pageblock_skip bits. This is different from when the former kswapd
compaction observed the bits and I believe it makes more sense. Kcompactd can
afford to be more thorough than a direct compaction trying to limit allocation
latency, or kswapd whose primary goal is to reclaim.

To sum up, after this patch, the pageblock_skip flushing makes intuitively
more sense for kcompactd. Practially, the differences are minimal.
Stress-highalloc With order-9 allocations without direct reclaim/compaction:

stress-highalloc
                              4.5-rc1               4.5-rc1
                               4-test                5-test
Success 1 Min          3.00 (  0.00%)        5.00 (-66.67%)
Success 1 Mean         4.00 (  0.00%)        6.20 (-55.00%)
Success 1 Max          6.00 (  0.00%)        7.00 (-16.67%)
Success 2 Min          3.00 (  0.00%)        5.00 (-66.67%)
Success 2 Mean         4.20 (  0.00%)        6.40 (-52.38%)
Success 2 Max          6.00 (  0.00%)        7.00 (-16.67%)
Success 3 Min         63.00 (  0.00%)       62.00 (  1.59%)
Success 3 Mean        64.60 (  0.00%)       63.80 (  1.24%)
Success 3 Max         67.00 (  0.00%)       65.00 (  2.99%)

             4.5-rc1     4.5-rc1
              4-test      5-test
User         3088.82     3181.09
System       1142.01     1158.25
Elapsed      1780.91     1799.37

                                  4.5-rc1     4.5-rc1
                                   4-test      5-test
Minor Faults                    106582816   107907437
Major Faults                          813         734
Swap Ins                              311         235
Swap Outs                            5598        5485
Allocation stalls                     184         207
DMA allocs                             32          31
DMA32 allocs                     74843238    75757965
Normal allocs                    25886668    26130990
Movable allocs                          0           0
Direct pages scanned                31429       32797
Kswapd pages scanned              2185293     2202613
Kswapd pages reclaimed            2134389     2143524
Direct pages reclaimed              31234       32545
Kswapd efficiency                     97%         97%
Kswapd velocity                  1228.666    1218.536
Direct efficiency                     99%         99%
Direct velocity                    17.671      18.144
Percentage direct scans                1%          1%
Zone normal velocity              291.409     286.309
Zone dma32 velocity               954.928     950.371
Zone dma velocity                   0.000       0.000
Page writes by reclaim           5598.600    5485.600
Page writes file                        0           0
Page writes anon                     5598        5485
Page reclaim immediate                 96          60
Sector Reads                      4307161     4293509
Sector Writes                    11053091    11072127
Page rescued immediate                  0           0
Slabs scanned                     1555770     1549506
Direct inode steals                  2025        7018
Kswapd inode steals                 45418       40265
Kswapd skipped wait                     0           0
THP fault alloc                       614         612
THP collapse alloc                    324         316
THP splits                              0           0
THP fault fallback                    730         778
THP collapse fail                      14          16
Compaction stalls                     959        1007
Compaction success                     69          67
Compaction failures                   890         939
Page migrate success               662054      721374
Page migrate failure                32846       23469
Compaction pages isolated         1370326     1479924
Compaction migrate scanned        7025772     8812554
Compaction free scanned          73302642    84327916
Compaction cost                       762         838

With direct reclaim/compaction:

stress-highalloc
/home/vbabka/labs/mmtests-results/storm/2016-02-02_16-37/test2/1
                              4.5-rc1               4.5-rc1
                              4-test2               5-test2
Success 1 Min          6.00 (  0.00%)        9.00 (-50.00%)
Success 1 Mean         8.40 (  0.00%)       10.00 (-19.05%)
Success 1 Max         13.00 (  0.00%)       11.00 ( 15.38%)
Success 2 Min          6.00 (  0.00%)        9.00 (-50.00%)
Success 2 Mean         8.60 (  0.00%)       10.00 (-16.28%)
Success 2 Max         12.00 (  0.00%)       11.00 (  8.33%)
Success 3 Min         75.00 (  0.00%)       74.00 (  1.33%)
Success 3 Mean        75.60 (  0.00%)       75.20 (  0.53%)
Success 3 Max         76.00 (  0.00%)       76.00 (  0.00%)

             4.5-rc1     4.5-rc1
             4-test2     5-test2
User         3258.62     3246.04
System       1177.92     1172.29
Elapsed      1837.02     1836.76

                                  4.5-rc1     4.5-rc1
                                  4-test2     5-test2
Minor Faults                    109392253   109773220
Minor Faults                    109392253   109773220
Major Faults                          755         864
Swap Ins                              155         262
Swap Outs                            5790        5871
Allocation stalls                    4562        4540
DMA allocs                             34          39
DMA32 allocs                     76901680    77122082
Normal allocs                    26587089    26748274
Movable allocs                          0           0
Direct pages scanned               108854      120966
Kswapd pages scanned              2131589     2135012
Kswapd pages reclaimed            2090937     2108388
Direct pages reclaimed             108699      120577
Kswapd efficiency                     98%         98%
Kswapd velocity                  1160.870    1170.537
Direct efficiency                     99%         99%
Direct velocity                    59.283      66.321
Percentage direct scans                4%          5%
Zone normal velocity              294.389     293.821
Zone dma32 velocity               925.764     943.036
Zone dma velocity                   0.000       0.000
Page writes by reclaim           5790.600    5871.200
Page writes file                        0           0
Page writes anon                     5790        5871
Page reclaim immediate                218         225
Sector Reads                      4376989     4428264
Sector Writes                    11102113    11110668
Page rescued immediate                  0           0
Slabs scanned                     1692486     1709123
Direct inode steals                 16266        6898
Kswapd inode steals                 28364       38351
Kswapd skipped wait                     0           0
THP fault alloc                       567         652
THP collapse alloc                    326         354
THP splits                              0           0
THP fault fallback                    805         793
THP collapse fail                      18          16
Compaction stalls                    2070        2025
Compaction success                    527         518
Compaction failures                  1543        1507
Page migrate success              2423657     2360608
Page migrate failure                28790       40852
Compaction pages isolated         4916017     4802025
Compaction migrate scanned       19370264    21750613
Compaction free scanned         360662356   344372001
Compaction cost                      2745        2694

Singed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 10 +++++-----
 mm/internal.h   |  1 +
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c03715ba65c7..67bb651c56b1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1191,11 +1191,11 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
-		 * by kswapd when it goes to sleep. kswapd does not set the
+		 * by kswapd when it goes to sleep. kcompactd does not set the
 		 * flag itself as the decision to be clear should be directly
 		 * based on an allocation request.
 		 */
-		if (!current_is_kswapd())
+		if (cc->direct_compaction)
 			zone->compact_blockskip_flush = true;
 
 		return COMPACT_COMPLETE;
@@ -1338,10 +1338,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	/*
 	 * Clear pageblock skip if there were failures recently and compaction
-	 * is about to be retried after being deferred. kswapd does not do
-	 * this reset as it'll reset the cached information when going to sleep.
+	 * is about to be retried after being deferred.
 	 */
-	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+	if (compaction_restarting(zone, cc->order))
 		__reset_isolation_suitable(zone);
 
 	/*
@@ -1477,6 +1476,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.mode = mode,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
+		.direct_compaction = true,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
diff --git a/mm/internal.h b/mm/internal.h
index 17ae0b52534b..013a786fa37f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -181,6 +181,7 @@ struct compact_control {
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const int alloc_flags;		/* alloc flags of a direct compactor */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
