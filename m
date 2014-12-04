Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4C66B0072
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 12:13:19 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so23305243wgh.9
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:13:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si26382203wix.0.2014.12.04.09.13.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 09:13:16 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/3] page stealing tweaks
Date: Thu,  4 Dec 2014 18:12:55 +0100
Message-Id: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

When studying page stealing, I noticed some weird looking decisions in
try_to_steal_freepages(). The first I assume is a bug (Patch 1), the following
two patches were driven by evaluation.

Testing was done with stress-highalloc of mmtests, using the
mm_page_alloc_extfrag tracepoint and postprocessing to get counts of how often
page stealing occurs for individual migratetypes, and what migratetypes are
used for fallbacks. Arguably, the worst case of page stealing is when
UNMOVABLE allocation steals from MOVABLE pageblock. RECLAIMABLE allocation
stealing from MOVABLE allocation is also not ideal, so the goal is to minimize
these two cases.

For some reason, the first patch increased the number of page stealing events
for MOVABLE allocations, and I am still not sure why. In theory these events
are not as bad, and the third patch does more than just to correct this.

Here are the results, baseline (column 26) is 3.17-rc7 with compaction patches
from -mm. First, the results with benchmark set to mimic non-THP-like
whole-pageblock allocations. Discussion below:

stress-highalloc
                             3.17-rc7              3.17-rc7              3.17-rc7              3.17-rc7
                             26-nothp              27-nothp              28-nothp              29-nothp
Success 1 Min         20.00 (  0.00%)       31.00 (-55.00%)       33.00 (-65.00%)       23.00 (-15.00%)
Success 1 Mean        32.70 (  0.00%)       39.00 (-19.27%)       39.10 (-19.57%)       35.80 ( -9.48%)
Success 1 Max         42.00 (  0.00%)       44.00 ( -4.76%)       46.00 ( -9.52%)       45.00 ( -7.14%)
Success 2 Min         20.00 (  0.00%)       33.00 (-65.00%)       36.00 (-80.00%)       24.00 (-20.00%)
Success 2 Mean        33.90 (  0.00%)       41.30 (-21.83%)       41.70 (-23.01%)       36.80 ( -8.55%)
Success 2 Max         44.00 (  0.00%)       49.00 (-11.36%)       49.00 (-11.36%)       45.00 ( -2.27%)
Success 3 Min         84.00 (  0.00%)       86.00 ( -2.38%)       86.00 ( -2.38%)       85.00 ( -1.19%)
Success 3 Mean        86.40 (  0.00%)       87.20 ( -0.93%)       87.20 ( -0.93%)       86.80 ( -0.46%)
Success 3 Max         88.00 (  0.00%)       89.00 ( -1.14%)       89.00 ( -1.14%)       88.00 (  0.00%)

            3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
            26-nothp    27-nothp    28-nothp    29-nothp
User         6818.93     6775.23     6759.60     6783.81
System       1055.97     1056.31     1055.37     1057.36
Elapsed      2150.18     2211.63     2196.91     2201.93

                              3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
                              26-nothp    27-nothp    28-nothp    29-nothp
Minor Faults                 198162003   197936707   197750617   198414323
Major Faults                       462         511         533         490
Swap Ins                            29          31          42          21
Swap Outs                         2142        2225        2616        2276
Allocation stalls                 6030        7716        6856        6175
DMA allocs                         112         102         128          73
DMA32 allocs                 124578777   124503016   124372538   124840569
Normal allocs                 59157970    59165895    59160083    59154005
Movable allocs                       0           0           0           0
Direct pages scanned            353190      424846      395619      359421
Kswapd pages scanned           2201775     2221571     2223699     2254336
Kswapd pages reclaimed         2196630     2216042     2218175     2242737
Direct pages reclaimed          352402      423989      394801      358321
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1011.483    1019.369    1016.418    1010.895
Direct efficiency                  99%         99%         99%         99%
Direct velocity                162.253     194.941     180.832     161.173
Percentage direct scans            13%         16%         15%         13%
Zone normal velocity           381.505     402.030     393.093     376.382
Zone dma32 velocity            792.218     812.269     804.143     795.679
Zone dma velocity                0.012       0.011       0.014       0.007
Page writes by reclaim        2316.900    2366.600    2791.300    2492.700
Page writes file                   174         141         174         216
Page writes anon                  2142        2225        2616        2276
Page reclaim immediate            1381        1586        1314        8126
Sector Reads                   4703932     4775640     4750501     4747452
Sector Writes                 12758092    12720075    12695676    12790100
Page rescued immediate               0           0           0           0
Slabs scanned                  1750170     1871811     1847197     1822608
Direct inode steals              14468       14838       14872       14241
Kswapd inode steals              38766       40510       40353       40442
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    262         221         239         239
THP collapse alloc                 506         494         535         491
THP splits                          14          12          14          14
THP fault fallback                   7          33          10          39
THP collapse fail                   17          18          16          18
Compaction stalls                 2746        3359        3185        2981
Compaction success                1025        1188        1153        1097
Compaction failures               1721        2170        2032        1884
Page migrate success           3889927     4512417     4340044     4128768
Page migrate failure             14551       17660       17096       14686
Compaction pages isolated      8058458     9337143     8974871     8554984
Compaction migrate scanned   156216179   187390755   178241572   163503245
Compaction free scanned      317797413   388387641   361523988   341521402
Compaction cost                   5284        6173        5923        5592
NUMA alloc hit               181314344   181142494   180975258   181531369
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             181314344   181142494   180975258   181531369
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                       3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
                                                       26-nothp    27-nothp    28-nothp    29-nothp
Page alloc extfrag event                                7223461    10651213    10274135     3785074
Extfrag fragmenting                                     7221775    10648719    10272431     3782605
Extfrag fragmenting for unmovable                         20264       16784        2668        2768
Extfrag fragmenting unmovable stealing from movable       10814        7531        2231        2091
Extfrag fragmenting for reclaimable                        1937        1114        1138        1268
Extfrag fragmenting reclaimable stealing from movable      1731         882         914         973
Extfrag fragmenting for movable                         7199574    10630821    10268625     3778569

As can be seen, success rates are not very much affected, or perhaps the first
patch improves them slightly. But the reduction of extfrag events is quite
prominent, especially for unmovable allocations polluting (potentially
permanently) movable pageblocks.

For completeness, the results with benchark set to mimic THP allocations are
below. It's not so different, so no extra discussion.

stress-highalloc
                             3.17-rc7              3.17-rc7              3.17-rc7              3.17-rc7
                               26-thp                27-thp                28-thp                29-thp
Success 1 Min         20.00 (  0.00%)       27.00 (-35.00%)       26.00 (-30.00%)       22.00 (-10.00%)
Success 1 Mean        28.90 (  0.00%)       33.00 (-14.19%)       31.90 (-10.38%)       29.60 ( -2.42%)
Success 1 Max         36.00 (  0.00%)       40.00 (-11.11%)       39.00 ( -8.33%)       35.00 (  2.78%)
Success 2 Min         20.00 (  0.00%)       28.00 (-40.00%)       30.00 (-50.00%)       23.00 (-15.00%)
Success 2 Mean        31.20 (  0.00%)       36.70 (-17.63%)       35.20 (-12.82%)       32.50 ( -4.17%)
Success 2 Max         39.00 (  0.00%)       43.00 (-10.26%)       42.00 ( -7.69%)       43.00 (-10.26%)
Success 3 Min         85.00 (  0.00%)       86.00 ( -1.18%)       87.00 ( -2.35%)       86.00 ( -1.18%)
Success 3 Mean        86.90 (  0.00%)       87.30 ( -0.46%)       87.70 ( -0.92%)       87.20 ( -0.35%)
Success 3 Max         88.00 (  0.00%)       88.00 (  0.00%)       90.00 ( -2.27%)       89.00 ( -1.14%)

            3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
              26-thp      27-thp      28-thp      29-thp
User         6819.54     6791.98     6817.78     6780.39
System       1060.01     1061.72     1059.55     1060.22
Elapsed      2143.61     2169.23     2151.94     2164.37

                              3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
                                26-thp      27-thp      28-thp      29-thp
Minor Faults                 197991650   197731531   197676212   198108344
Major Faults                       467         517         485         463
Swap Ins                            55          42          55          37
Swap Outs                         2743        2628        2848        2423
Allocation stalls                 5674        6859        5830        5430
DMA allocs                          21          19          18          20
DMA32 allocs                 124822788   124717762   124599426   124998427
Normal allocs                 58689613    58661322    58715465    58613337
Movable allocs                       0           0           0           0
Direct pages scanned            425873      497589      437964      440959
Kswapd pages scanned           2106472     2092938     2123314     2137886
Kswapd pages reclaimed         2100750     2087313     2117523     2124031
Direct pages reclaimed          424875      496616      437006      439572
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity                986.439     999.617    1016.928     984.321
Direct efficiency                  99%         99%         99%         99%
Direct velocity                199.432     237.656     209.756     203.025
Percentage direct scans            16%         19%         17%         17%
Zone normal velocity           396.728     411.978     412.730     391.261
Zone dma32 velocity            789.143     825.294     813.954     796.086
Zone dma velocity                0.000       0.000       0.000       0.000
Page writes by reclaim        2963.000    2735.600    2981.900    2640.500
Page writes file                   219         107         133         217
Page writes anon                  2743        2628        2848        2423
Page reclaim immediate            1504        1609        1622        9672
Sector Reads                   4638068     4700778     4687436     4690935
Sector Writes                 12744701    12689336    12685726    12742547
Page rescued immediate               0           0           0           0
Slabs scanned                  1612929     1704964     1659159     1670590
Direct inode steals              15564       17989       16063       17179
Kswapd inode steals              31322       31013       31563       31266
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    250         227         246         223
THP collapse alloc                 517         515         504         487
THP splits                          15          13          14          11
THP fault fallback                  10          24           5          38
THP collapse fail                   17          18          16          18
Compaction stalls                 2482        2794        2687        2608
Compaction success                 894        1016         995         972
Compaction failures               1588        1778        1692        1636
Page migrate success           2306759     2283240     2298373     2228802
Page migrate failure             10645       12648       10681       10023
Compaction pages isolated      4906442     4878707     4907827     4768580
Compaction migrate scanned    40396525    46362656    44372629    42315303
Compaction free scanned      134008519   146858466   131814222   132434783
Compaction cost                   2770        2787        2789        2700
NUMA alloc hit               181150856   180941682   180895401   181254771
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             181150856   180941682   180895401   181254771
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                       3.17-rc7    3.17-rc7    3.17-rc7    3.17-rc7
                                                         26-thp      27-thp      28-thp      29-thp
Page alloc extfrag event                                4270316     5661910     5018754     2062787
Extfrag fragmenting                                     4268643     5660158     5016977     2061077
Extfrag fragmenting for unmovable                         21632       17627        1985        1984
Extfrag fragmenting unmovable placed with movable         12428        9011        1663        1506
Extfrag fragmenting for reclaimable                        1682        1106        1290        1401
Extfrag fragmenting reclaimable placed with movable        1480         917        1072        1132
Extfrag fragmenting for movable                         4245329     5641425     5013702     2057692


Vlastimil Babka (3):
  mm: when stealing freepages, also take pages created by splitting
    buddy page
  mm: more aggressive page stealing for UNMOVABLE allocations
  mm: always steal split buddies in fallback allocations

 mm/page_alloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
