Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 079B16B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 04:02:20 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x3so2222279wes.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 01:02:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ia1si31586809wjb.155.2015.01.20.01.02.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 01:02:18 -0800 (PST)
Message-ID: <54BE1995.5090803@suse.cz>
Date: Tue, 20 Jan 2015 10:02:13 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] compaction: changing initial position of scanners
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

On 01/19/2015 11:05 AM, Vlastimil Babka wrote:
> Preliminary testing with THP-like allocations has shown similar improvements,
> which is somewhat surprising, because THP allocations do not use sync
> and thus do not defer compaction; but changing the pivot is currently tied
> to restarting from deferred compaction. Possibly this is due to the other
> allocation activity than the stress-highalloc test itself. I will post these
> results when full measurements are done.

So here are the full results, before patch 5:

                             3.19-rc4              3.19-rc4              3.19-rc4
                              4-thp-1               4-thp-2               4-thp-3
Success 1 Min         24.00 (  0.00%)       14.00 ( 41.67%)       16.00 ( 33.33%)
Success 1 Mean        29.80 (  0.00%)       17.00 ( 42.95%)       19.80 ( 33.56%)
Success 1 Max         33.00 (  0.00%)       25.00 ( 24.24%)       29.00 ( 12.12%)
Success 2 Min         26.00 (  0.00%)       15.00 ( 42.31%)       17.00 ( 34.62%)
Success 2 Mean        32.60 (  0.00%)       19.20 ( 41.10%)       21.20 ( 34.97%)
Success 2 Max         37.00 (  0.00%)       28.00 ( 24.32%)       30.00 ( 18.92%)
Success 3 Min         85.00 (  0.00%)       82.00 (  3.53%)       80.00 (  5.88%)
Success 3 Mean        86.20 (  0.00%)       83.20 (  3.48%)       81.20 (  5.80%)
Success 3 Max         87.00 (  0.00%)       84.00 (  3.45%)       82.00 (  5.75%)

            3.19-rc4    3.19-rc4    3.19-rc4
             4-thp-1     4-thp-2     4-thp-3
User         6798.70     6905.43     6941.09
System       1064.04     1062.94     1062.76
Elapsed      2108.98     2026.84     2039.40

                              3.19-rc4    3.19-rc4    3.19-rc4
                               4-thp-1     4-thp-2     4-thp-3
Minor Faults                 198099852   197531505   197503750
Major Faults                       483         422         490
Swap Ins                            86          55         113
Swap Outs                         3138         887         399
Allocation stalls                 6523        4619        4816
DMA allocs                          20          21          29
DMA32 allocs                 124645618   123937328   123927500
Normal allocs                 58904757    58753982    58818313                                                                                                                                                 
Movable allocs                       0           0           0                                                                                                                                                 
Direct pages scanned            428919      361735      402238                                                                                                                                                 
Kswapd pages scanned           2110062     2070576     2042000                                                                                                                                                 
Kswapd pages reclaimed         2104207     2067640     2026147                                                                                                                                                 
Direct pages reclaimed          427965      361045      401398                                                                                                                                                 
Kswapd efficiency                  99%         99%         99%                                                                                                                                                 
Kswapd velocity               1019.443    1032.145    1015.507                                                                                                                                                 
Direct efficiency                  99%         99%         99%                                                                                                                                                 
Direct velocity                207.225     180.319     200.037                                                                                                                                                 
Percentage direct scans            16%         14%         16%                                                                                                                                                 
Zone normal velocity           408.313     391.138     385.933                                                                                                                                                 
Zone dma32 velocity            818.355     821.320     829.605                                                                                                                                                 
Zone dma velocity                0.000       0.006       0.006                                                                                                                                                 
Page writes by reclaim        3352.000     963.000     517.000                                                                                                                                                 
Page writes file                   213          75         117                                                                                                                                                 
Page writes anon                  3138         887         399                                                                                                                                                 
Page reclaim immediate            1144        1066       14181                                                                                                                                                 
Sector Reads                   4628816     4522758     4532221                                                                                                                                                 
Sector Writes                 12767080    12671744    12651826                                                                                                                                                 
Page rescued immediate               0           0           0                                                                                                                                                 
Slabs scanned                  1697125     1504150     1497662                                                                                                                                                 
Direct inode steals              18505       12670       12166
Kswapd inode steals              34595       31472       30069
Kswapd skipped wait                  0           0           0
THP fault alloc                    239         220         235
THP collapse alloc                 507         406         478
THP splits                          14          13          12
THP fault fallback                  28          25           6
THP collapse fail                   16          21          19
Compaction stalls                 2661        1953        2062
Compaction success                1005         738         832
Compaction failures               1656        1215        1229
Page migrate success           2137343     1941288     1984697
Page migrate failure              9345        5923        7109
Compaction pages isolated      4630988     4169422     4271015
Compaction migrate scanned    42109445    35090957    37926766
Compaction free scanned      150533970   131933800   126682354
Compaction cost                   2601        2339        2406

After patch 5:

                             3.19-rc4              3.19-rc4              3.19-rc4
                              5-thp-1               5-thp-2               5-thp-3
Success 1 Min         43.00 (  0.00%)       35.00 ( 18.60%)       33.00 ( 23.26%)
Success 1 Mean        44.80 (  0.00%)       37.20 ( 16.96%)       36.40 ( 18.75%)
Success 1 Max         46.00 (  0.00%)       38.00 ( 17.39%)       41.00 ( 10.87%)
Success 2 Min         53.00 (  0.00%)       44.00 ( 16.98%)       40.00 ( 24.53%)
Success 2 Mean        55.60 (  0.00%)       47.60 ( 14.39%)       43.60 ( 21.58%)
Success 2 Max         58.00 (  0.00%)       50.00 ( 13.79%)       46.00 ( 20.69%)
Success 3 Min         85.00 (  0.00%)       81.00 (  4.71%)       79.00 (  7.06%)
Success 3 Mean        86.40 (  0.00%)       83.40 (  3.47%)       80.20 (  7.18%)
Success 3 Max         88.00 (  0.00%)       85.00 (  3.41%)       82.00 (  6.82%)

            3.19-rc4    3.19-rc4    3.19-rc4
             5-thp-1     5-thp-2     5-thp-3
User         6690.38     6734.92     6772.31
System       1065.54     1063.26     1064.48
Elapsed      2172.84     2153.99     2162.77

                              3.19-rc4    3.19-rc4    3.19-rc4
                               5-thp-1     5-thp-2     5-thp-3
Minor Faults                 196642124   197072025   196458816
Major Faults                       712         629         663
Swap Ins                           112          89         119
Swap Outs                         2425        1615         955
Allocation stalls                10987        8689        8072
DMA allocs                          13          13          12
DMA32 allocs                 124048790   124176073   123636557
Normal allocs                 58641381    58758990    58548760
Movable allocs                       0           0           0
Direct pages scanned            607943      519167      491800
Kswapd pages scanned           2091239     2093530     2080230
Kswapd pages reclaimed         2085935     2090069     2076784
Direct pages reclaimed          607103      518178      490870
Kswapd efficiency                  99%         99%         99%
Kswapd velocity                953.698     980.452     978.692
Direct efficiency                  99%         99%         99%
Direct velocity                277.249     243.139     231.379
Percentage direct scans            22%         19%         19%
Zone normal velocity           411.137     400.519     393.191
Zone dma32 velocity            819.809     823.068     816.877
Zone dma velocity                0.000       0.004       0.004
Page writes by reclaim        2568.800    1735.400    1112.200
Page writes file                   143         120         156
Page writes anon                  2425        1615         955
Page reclaim immediate            1316        1240        1460
Sector Reads                   4801026     4810421     4766392
Sector Writes                 12521168    12599312    12490746
Page rescued immediate               0           0           0
Slabs scanned                  1998998     1873533     1826614
Direct inode steals              39894       44540       29447
Kswapd inode steals              34313       24112       32393
Kswapd skipped wait                  0           0           0
THP fault alloc                    204         227         190
THP collapse alloc                 554         555         463
THP splits                          14          16          11
THP fault fallback                   3           3           0
THP collapse fail                   15          16          20
Compaction stalls                 3742        3350        3257
Compaction success                1427        1298        1262
Compaction failures               2315        2051        1995
Page migrate success           2557969     2615986     2766293
Page migrate failure             11532        7297        8779
Compaction pages isolated      5601557     5698249     6044777
Compaction migrate scanned    16776380    20331554    22910553
Compaction free scanned      213184847   172781034   169740956
Compaction cost                   2879        2966        3146

Success rates are still worse on second iteration compared to first, but much better overal.

Let's repeat compaction stats before patch 5, for easier comparison:

Compaction stalls                 2661        1953        2062
Compaction success                1005         738         832
Compaction failures               1656        1215        1229
Page migrate success           2137343     1941288     1984697
Page migrate failure              9345        5923        7109
Compaction pages isolated      4630988     4169422     4271015
Compaction migrate scanned    42109445    35090957    37926766
Compaction free scanned      150533970   131933800   126682354
Compaction cost                   2601        2339        2406

Again, migrate scanned went actually down after patch 5, the rest went up as
compaction was more successful and less deferred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
