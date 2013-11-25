Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id A46A56B00B8
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:26:43 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so1978289bkb.26
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 06:26:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id uk7si5797082bkb.285.2013.11.25.06.26.42
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 06:26:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 0/5] Memory compaction efficiency improvements
Date: Mon, 25 Nov 2013 15:26:05 +0100
Message-Id: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

The broad goal of the series is to improve allocation success rates for huge
pages through memory compaction, while trying not to increase the compaction
overhead. The original objective was to reintroduce capturing of high-order
pages freed by the compaction, before they are split by concurrent activity.
However, several bugs and opportunities for simple improvements were found in
the current implementation, mostly through extra tracepoints (which are however
too ugly for now to be considered for sending).

The patches mostly deal with two mechanisms that reduce compaction overhead,
which is caching the progress of migrate and free scanners, and marking
pageblocks where isolation failed to be skipped during further scans.

Patch 1 encapsulates the some functionality for handling deferred compactions
        for better maintainability, without a functional change
        type is not determined without being actually needed.

Patch 2 fixes a bug where cached scanner pfn's are sometimes reset only after
        they have been read to initialize a compaction run.

Patch 3 fixes a bug where scanners meeting is sometimes not properly detected
        and can lead to multiple compaction attempts quitting early without
        doing any work.

Patch 4 improves the chances of sync compaction to process pageblocks that
        async compaction has skipped due to being !MIGRATE_MOVABLE.

Patch 5 improves the chances of sync direct compaction to actually do anything
        when called after async compaction fails during allocation slowpath.


Some preliminary results with mmtests's stress-highalloc benchmark on a x86_64
machine with 4GB memory. First, the default GFP_HIGHUSER_MOVABLE allocations,
with the patches stacked on top of mainline master as of Friday (commit
a5d6e633 merging fixes from Andrew). Patch 1 is OK to serve as baseline due to
no functional change. Comments below.

stress-highalloc
                         master                master                master                master                master
                        1-nothp               2-nothp               3-nothp               4-nothp               5-nothp
Success 1       34.00 (  0.00%)       20.00 ( 41.18%)       44.00 (-29.41%)       45.00 (-32.35%)       25.00 ( 26.47%)
Success 2       31.00 (  0.00%)       21.00 ( 32.26%)       47.00 (-51.61%)       47.00 (-51.61%)       28.00 (  9.68%)
Success 3       68.00 (  0.00%)       88.00 (-29.41%)       86.00 (-26.47%)       87.00 (-27.94%)       88.00 (-29.41%)

              master      master      master      master      master
             1-nothp     2-nothp     3-nothp     4-nothp     5-nothp
User         6334.04     6343.09     5938.15     5860.00     6674.38
System       1044.15     1035.84     1022.68     1021.11     1055.76
Elapsed      1787.06     1714.76     1829.14     1850.91     1789.83

                                master      master      master      master      master
                               1-nothp     2-nothp     3-nothp     4-nothp     5-nothp
Minor Faults                 248365069   244975796   247192462   243720231   248888409
Major Faults                       427         442         563         504         414
Swap Ins                             7           3           8           7           0
Swap Outs                          345         338         570         235         415
Direct pages scanned            239929      166220      276238      277310      202409
Kswapd pages scanned           1759082     1819998     1880477     1850421     1809928
Kswapd pages reclaimed         1756781     1813653     1877783     1847704     1806347
Direct pages reclaimed          239291      165988      276163      277048      202092
Kswapd efficiency                  99%         99%         99%         99%         99%
Kswapd velocity                984.344    1061.372    1028.066     999.736    1011.229
Direct efficiency                  99%         99%         99%         99%         99%
Direct velocity                134.259      96.935     151.021     149.824     113.088
Percentage direct scans            12%          8%         12%         13%         10%
Zone normal velocity           362.126     440.499     374.597     354.049     360.196
Zone dma32 velocity            756.478     717.808     804.490     795.511     764.122
Zone dma velocity                0.000       0.000       0.000       0.000       0.000
Page writes by reclaim         450.000     476.000     570.000     306.000     639.000
Page writes file                   105         138           0          71         224
Page writes anon                   345         338         570         235         415
Page reclaim immediate             660        4407         167         843        1553
Sector Reads                   2734844     2725576     2951744     2830472     2791216
Sector Writes                 11938520    11729108    11769760    11743120    11805320
Page rescued immediate               0           0           0           0           0
Slabs scanned                  1596544     1520768     1767552     1774720     1555584
Direct inode steals               9764        6640       14010       15320        8315
Kswapd inode steals              47445       42888       49705       51043       43283
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                     78          30          43          34          31
THP collapse alloc                 485         371         570         559         306
THP splits                           6           1           2           4           2
THP fault fallback                   0           0           0           0           0
THP collapse fail                   13          16          11          12          16
Compaction stalls                 1067        1072        1629        1578        1140
Compaction success                 339         275         568         595         329
Compaction failures                728         797        1061         983         811
Page migrate success           1115929     1113188     3966997     4076178     4220010
Page migrate failure                 0           0           0           0           0
Compaction pages isolated      2423867     2425024     8351264     8583856     8789144
Compaction migrate scanned    38956505    62526876   153906340   174085307   114170442
Compaction free scanned       83126040    51071610   396724121   358193857   389459415
Compaction cost                   1477        1639        5353        5612        5346
NUMA PTE updates                     0           0           0           0           0
NUMA hint faults                     0           0           0           0           0
NUMA hint local faults               0           0           0           0           0
NUMA hint local percent            100         100         100         100         100
NUMA pages migrated                  0           0           0           0           0
AutoNUMA cost                        0           0           0           0           0

Observations:
- The "Success 3" line is allocation success rate with system idle (phases 1
  and 2 are with background interference). I used to get values around 85%
  with vanilla 3.11 and observed occasional drop to around 65% in 3.12, with
  about 50% chance. This was bisected to commit 81c0a2bb ("mm: page_alloc:
  fair zone allocator policy") using 10 repeats of the benchmark and marking
  as 'bad' a commit as long as the bad result appeared at least once (to fight
  the uncertainty). As explained in comment for patch 3, I don't think the
  commit is wrong, but that it makes the effect of bugs worse. From patch 3
  onwards, the results are OK. Here it might seem that patch 2 helps, but
  that's just the uncertainty. I plan to add support for more iterations and
  statistical summarizing of the results to fight this...
- It might seem that patch 5 is regressing phases 1 and 2, but since that was
  not the case when testing against 3.12, I would say it's just different
  case of unstable results. Phases 1 and 2 are more amenable to that in
  general. However, I never seen unpatched 3.11 or 3.12 go above 40% as
  the patch 3 does.
- Compaction cost and number of scanned pages is higher, especially due to
  patch 3. However, keep in mind that patches 2 and 3 fix existing bugs in the
  current design of overhead mitigation, they do not change it. If overhead is
  found unacceptable, then it should be decreased differently (and consistently,
  not due to random conditions) than the current implementation does. In
  contrast, patches 4 and 5 (which are not strictly bug fixes) do not
  increase the overhead (but also not success rates).

Another set of preliminary results is when configuring stress-highalloc to
allocate with similar flags as THP uses:
 (GFP_HIGHUSER_MOVABLE|__GFP_NOMEMALLOC|__GFP_NORETRY|__GFP_NO_KSWAPD)

stress-highalloc
                         master                master                master                master                master
                          1-thp                 2-thp                 3-thp                 4-thp                 5-thp
Success 1       29.00 (  0.00%)        7.00 ( 75.86%)       25.00 ( 13.79%)       32.00 (-10.34%)       32.00 (-10.34%)
Success 2       30.00 (  0.00%)        7.00 ( 76.67%)       29.00 (  3.33%)       34.00 (-13.33%)       37.00 (-23.33%)
Success 3       70.00 (  0.00%)       70.00 (  0.00%)       85.00 (-21.43%)       85.00 (-21.43%)       85.00 (-21.43%)

              master      master      master      master      master
               1-thp       2-thp       3-thp       4-thp       5-thp
User         5915.36     6769.19     6350.04     6421.90     6571.80
System       1017.80     1053.70     1039.06     1051.84     1061.59
Elapsed      1757.87     1724.31     1744.66     1822.78     1841.42

                                master      master      master      master      master
                                 1-thp       2-thp       3-thp       4-thp       5-thp
Minor Faults                 246004967   248169249   244469991   248893104   245151725
Major Faults                       403         282         354         369         436
Swap Ins                             8           8          10           7           8
Swap Outs                          534         530         325         694         687
Direct pages scanned            106122       76339      168386      202576      170449
Kswapd pages scanned           1924013     1803706     1855293     1872408     1907170
Kswapd pages reclaimed         1920762     1800403     1852989     1869573     1904070
Direct pages reclaimed          105986       76291      168183      202440      170343
Kswapd efficiency                  99%         99%         99%         99%         99%
Kswapd velocity               1094.514    1046.045    1063.412    1027.227    1035.706
Direct efficiency                  99%         99%         99%         99%         99%
Direct velocity                 60.370      44.272      96.515     111.136      92.564
Percentage direct scans             5%          4%          8%          9%          8%
Zone normal velocity           362.047     386.497     361.529     371.628     369.295
Zone dma32 velocity            792.836     703.820     798.398     766.734     758.975
Zone dma velocity                0.000       0.000       0.000       0.000       0.000
Page writes by reclaim         741.000     751.000     325.000     694.000     924.000
Page writes file                   207         221           0           0         237
Page writes anon                   534         530         325         694         687
Page reclaim immediate             895         856         479         396         512
Sector Reads                   2769992     2627604     2735740     2828672     2836412
Sector Writes                 11748724    11660652    11598304    11800576    11753996
Page rescued immediate               0           0           0           0           0
Slabs scanned                  1485952     1233024     1457280     1492096     1544320
Direct inode steals               2565         537        3384        6389        3205
Kswapd inode steals              50112       42207       46892       45371       49542
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                     28           2          23          31          28
THP collapse alloc                 485         276         417         539         514
THP splits                           0           0           0           2           3
THP fault fallback                   0           0           0           0           0
THP collapse fail                   13          19          17          12          12
Compaction stalls                  813         474         964        1052        1050
Compaction success                 332          92         359         434         411
Compaction failures                481         382         605         617         639
Page migrate success            582816      359101      973579      950980     1085585
Page migrate failure                 0           0           0           0           0
Compaction pages isolated      1327894      806679     2256066     2195431     2461078
Compaction migrate scanned    13244945     7977159    21513942    23189436    30051866
Compaction free scanned       35192520    19254827    76152850    71159488    77702117
Compaction cost                    722         443        1204        1191        1383
NUMA PTE updates                     0           0           0           0           0
NUMA hint faults                     0           0           0           0           0
NUMA hint local faults               0           0           0           0           0
NUMA hint local percent            100         100         100         100         100
NUMA pages migrated                  0           0           0           0           0
AutoNUMA cost                        0           0           0           0           0

                      master      master      master      master      master
                       1-thp       2-thp       3-thp       4-thp       5-thp
Mean sda-avgqz         46.01       46.31       46.43       46.87       45.94
Mean sda-await        271.19      273.75      273.84      270.12      269.69
Mean sda-r_await       35.33       35.52       34.26       33.98       33.61
Mean sda-w_await      474.54      497.59      603.64      567.32      488.48
Max  sda-avgqz        158.33      168.62      166.68      165.51      165.82
Max  sda-await       1461.41     1374.49     1380.31     1427.35     1402.61
Max  sda-r_await      197.46      286.67      112.65      112.07      158.24
Max  sda-w_await     9986.97    11363.36    16119.59    12365.75    11706.65

There are some differences from the previous results for THP-like allocations:
 - Here, the bad result for unpatched kernel in phase 3 is much more consistent
   to be between 65-70% and not due to the "regression" in 3.12. Still there is
   the improvement from patch 3 onwards, which brings it on par with simple
   GFP_HIGHUSER_MOVABLE allocations.
 - Patch 2 is again not a regression but due to results variability.
 - The compaction overhead in patches 2 and 3 and arguments are similar as
   above.
 - Patch 5 increases the number of migrate-scanned pages significantly. This
   is most likely due to __GFP_NO_KSWAPD flag, which means the cached pfn's are
   not reset by kswapd, and the patch thus helps the sync-after-async
   compaction. It doesn't however show that the sync compaction would help with
   success rates. One of the further patches I'm considering for future
   versions is to ignore or clear pageblock skip information for sync
   compaction. But in that case, THP clearly should be changed so that it does
   not fallback to the sync compaction.




Vlastimil Babka (5):
  mm: compaction: encapsulate defer reset logic
  mm: compaction: reset cached scanner pfn's before reading them
  mm: compaction: detect when scanners meet in isolate_freepages
  mm: compaction: do not mark unmovable pageblocks as skipped in async
    compaction
  mm: compaction: reset scanner positions immediately when they meet

 include/linux/compaction.h | 12 +++++++++++
 mm/compaction.c            | 53 ++++++++++++++++++++++++++++++----------------
 mm/page_alloc.c            |  5 +----
 3 files changed, 48 insertions(+), 22 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
