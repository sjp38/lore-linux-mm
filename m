Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 47B806B0072
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 04:05:27 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so8266806wiv.2
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 01:05:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hj1si15909494wib.65.2014.12.15.01.05.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 01:05:25 -0800 (PST)
Message-ID: <548EA452.50706@suse.cz>
Date: Mon, 15 Dec 2014 10:05:22 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] page stealing tweaks
References: <1418400085-3622-1-git-send-email-vbabka@suse.cz> <20141215075017.GB4898@js1304-P5Q-DELUXE>
In-Reply-To: <20141215075017.GB4898@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 12/15/2014 08:50 AM, Joonsoo Kim wrote:
> On Fri, Dec 12, 2014 at 05:01:22PM +0100, Vlastimil Babka wrote:
>> Changes since v1:
>> o Reorder patch 2 and 3, Cc stable for patch 1
>> o Fix tracepoint in patch 1 (Joonsoo Kim)
>> o Cleanup in patch 2 (suggested by Minchan Kim)
>> o Improved comments and changelogs per Minchan and Mel.
>> o Considered /proc/pagetypeinfo in evaluation with 3.18 as baseline
>> 
>> When studying page stealing, I noticed some weird looking decisions in
>> try_to_steal_freepages(). The first I assume is a bug (Patch 1), the following
>> two patches were driven by evaluation.
>> 
>> Testing was done with stress-highalloc of mmtests, using the
>> mm_page_alloc_extfrag tracepoint and postprocessing to get counts of how often
>> page stealing occurs for individual migratetypes, and what migratetypes are
>> used for fallbacks. Arguably, the worst case of page stealing is when
>> UNMOVABLE allocation steals from MOVABLE pageblock. RECLAIMABLE allocation
>> stealing from MOVABLE allocation is also not ideal, so the goal is to minimize
>> these two cases.
>> 
>> For some reason, the first patch increased the number of page stealing events
>> for MOVABLE allocations in the former evaluation with 3.17-rc7 + compaction
>> patches. In theory these events are not as bad, and the second patch does more
>> than just to correct this. In v2 evaluation based on 3.18, the weird result
>> was gone completely.
>> 
>> In v2 I also checked if /proc/pagetypeinfo has shown an increase of the number
>> of unmovable/reclaimable pageblocks during and after the test, and it didn't.
>> The test was repeated 25 times with reboot only after each 5 to show
>> longer-term differences in the state of the system, which also wasn't the case.
>> 
>> Extfrag events summed over first iteration after reboot (5 repeats)
>>                                                         3.18            3.18            3.18            3.18
>>                                                    0-nothp-1       1-nothp-1       2-nothp-1       3-nothp-1
>> Page alloc extfrag event                                4547160     4593415     2343438     2198189
>> Extfrag fragmenting                                     4546361     4592610     2342595     2196611
>> Extfrag fragmenting for unmovable                          5725        9196        5720        1093
>> Extfrag fragmenting unmovable placed with movable          3877        4091        1330         859
>> Extfrag fragmenting for reclaimable                         770         628         511         616
>> Extfrag fragmenting reclaimable placed with movable         679         520         407         492
>> Extfrag fragmenting for movable                         4539866     4582786     2336364     2194902
>> 
>> Compared to v1 this looks like a regression for patch 1 wrt unmovable events,
>> but I blame noise and less repeats (it was 10 in v1). On the other hand, the
>> the mysterious increase in movable allocation events in v1 is gone (due to
>> different baseline?)
> 
> Hmm... the result on patch 2 looks odd.
> Because you reorder patches, patch 2 have some effects on unmovable
> stealing and I expect that 'Extfrag fragmenting for unmovable' decreases.
> But, the result looks not. Is there any reason you think?

Hm, I don't see any obvious reason. 

> And, could you share compaction success rate and allocation success
> rate on each iteration? In fact, reducing Extfrag event isn't our goal.
> It is natural result of this patchset because we steal pages more
> aggressively. Our utimate goal is to make the system less fragmented
> and to get more high order freepage, so I'd like to know this results.

I don't think there's much significant difference. Could be a limitation
of the benchmark. But even if there's no difference, it means the reduction
of fragmenting events at least saves time on allocations.
But you'll see that for the long-term fragmentation damage, we still have
long way to go...

Iteration 1 after reboot:

                                 3.18                  3.18                  3.18                  3.18
                            0-nothp-1             1-nothp-1             2-nothp-1             3-nothp-1
Success 1 Min         30.00 (  0.00%)       33.00 (-10.00%)       37.00 (-23.33%)       35.00 (-16.67%)
Success 1 Mean        38.60 (  0.00%)       37.60 (  2.59%)       41.00 ( -6.22%)       38.40 (  0.52%)
Success 1 Max         44.00 (  0.00%)       48.00 ( -9.09%)       48.00 ( -9.09%)       41.00 (  6.82%)
Success 2 Min         29.00 (  0.00%)       34.00 (-17.24%)       36.00 (-24.14%)       36.00 (-24.14%)
Success 2 Mean        40.40 (  0.00%)       38.20 (  5.45%)       41.40 ( -2.48%)       39.20 (  2.97%)
Success 2 Max         46.00 (  0.00%)       49.00 ( -6.52%)       49.00 ( -6.52%)       43.00 (  6.52%)
Success 3 Min         83.00 (  0.00%)       85.00 ( -2.41%)       84.00 ( -1.20%)       84.00 ( -1.20%)
Success 3 Mean        84.80 (  0.00%)       85.60 ( -0.94%)       84.80 (  0.00%)       84.60 (  0.24%)
Success 3 Max         86.00 (  0.00%)       86.00 (  0.00%)       86.00 (  0.00%)       86.00 (  0.00%)

                3.18        3.18        3.18        3.18
           0-nothp-1   1-nothp-1   2-nothp-1   3-nothp-1
User         6791.07     6777.88     6751.22     6746.16
System       1060.23     1062.19     1059.84     1056.64
Elapsed      2185.24     2228.84     2199.19     2191.76

                                  3.18        3.18        3.18        3.18
                             0-nothp-1   1-nothp-1   2-nothp-1   3-nothp-1
Minor Faults                 198068318   197804720   198505004   198482880
Major Faults                       501         498         496         494
Swap Ins                            46          48          11          11
Swap Outs                         2634        2651        2086        1823
Allocation stalls                 7323        7117        5970        6309
DMA allocs                          97         100         134         149
DMA32 allocs                 124755567   124289054   124952178   125027538
Normal allocs                 59002004    59130550    59196697    59072554
Movable allocs                       0           0           0           0
Direct pages scanned            392695      414090      328733      378168
Kswapd pages scanned           2214189     2207526     2311158     2262640
Kswapd pages reclaimed         2208768     2202066     2305968     2257781
Direct pages reclaimed          391894      413055      328084      377401
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1002.608    1000.655    1052.761    1017.141
Direct efficiency                  99%         99%         99%         99%
Direct velocity                177.816     187.704     149.742     170.001
Percentage direct scans            15%         15%         12%         14%
Zone normal velocity           387.887     388.497     387.885     376.085
Zone dma32 velocity            792.526     799.852     814.604     811.042
Zone dma velocity                0.011       0.011       0.014       0.014
Page writes by reclaim        2809.200    2858.800    2275.200    2011.600
Page writes file                   174         207         188         188
Page writes anon                  2634        2651        2086        1823
Page reclaim immediate            1324        1426        1392        1323
Sector Reads                   4742548     4728116     4804282     4801711
Sector Writes                 12763776    12706886    12803965    12789351
Page rescued immediate               0           0           0           0
Slabs scanned                  1830284     1842439     1863519     1859570
Direct inode steals              15479       14389       15666       14788
Kswapd inode steals              40155       40175       41128       42042
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    264         204         254         232
THP collapse alloc                 505         466         458         530
THP splits                          15          11          15          13
THP fault fallback                   5          43          28          45
THP collapse fail                   17          20          18          16
Compaction stalls                 2390        2333        2258        2276
Compaction success                 562         538         563         551
Compaction failures               1827        1794        1694        1724
Page migrate success           4263304     4045115     3862467     4028949
Page migrate failure             24367       16795       16593       17187
Compaction pages isolated      8732910     8286990     7906654     8249551
Compaction migrate scanned   132231829   123280022   130556442   132772831
Compaction free scanned      352820881   350707097   321784049   332591031
Compaction cost                   5517        5219        5073        5268
NUMA alloc hit               181237842   180977135   181620892   181590876
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             181237842   180977135   181620892   181590876
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                               3.18            3.18            3.18            3.18
                                                          0-nothp-1       1-nothp-1       2-nothp-1       3-nothp-1
Page alloc extfrag event                                4547160     4593415     2343438     2198189
Extfrag fragmenting                                     4546361     4592610     2342595     2196611
Extfrag fragmenting for unmovable                          5725        9196        5720        1093
Extfrag fragmenting unmovable placed with movable          3877        4091        1330         859
Extfrag fragmenting for reclaimable                         770         628         511         616
Extfrag fragmenting reclaimable placed with movable         679         520         407         492
Extfrag fragmenting for movable                         4539866     4582786     2336364     2194902



Iteration 2 after reboot:
Yup, those success rates suck. Wonder why. Could it be that there's still
long-term pollution by unmovable allocations? That wouldn't show on pagetypeinfo.

                                 3.18                  3.18                  3.18                  3.18
                            0-nothp-2             1-nothp-2             2-nothp-2             3-nothp-2
Success 1 Min          9.00 (  0.00%)       13.00 (-44.44%)       16.00 (-77.78%)       14.00 (-55.56%)
Success 1 Mean        14.80 (  0.00%)       18.80 (-27.03%)       20.80 (-40.54%)       18.00 (-21.62%)
Success 1 Max         20.00 (  0.00%)       25.00 (-25.00%)       28.00 (-40.00%)       23.00 (-15.00%)
Success 2 Min         12.00 (  0.00%)       20.00 (-66.67%)       23.00 (-91.67%)       19.00 (-58.33%)
Success 2 Mean        19.00 (  0.00%)       22.60 (-18.95%)       26.00 (-36.84%)       22.40 (-17.89%)
Success 2 Max         25.00 (  0.00%)       25.00 (  0.00%)       31.00 (-24.00%)       29.00 (-16.00%)
Success 3 Min         80.00 (  0.00%)       82.00 ( -2.50%)       80.00 (  0.00%)       81.00 ( -1.25%)
Success 3 Mean        82.20 (  0.00%)       82.40 ( -0.24%)       81.00 (  1.46%)       81.60 (  0.73%)
Success 3 Max         84.00 (  0.00%)       83.00 (  1.19%)       82.00 (  2.38%)       83.00 (  1.19%)

                3.18        3.18        3.18        3.18
           0-nothp-2   1-nothp-2   2-nothp-2   3-nothp-2
User         7004.37     6967.43     6956.83     6963.24
System       1055.53     1059.64     1057.10     1051.08
Elapsed      2055.20     2221.28     2083.53     2064.32

                                  3.18        3.18        3.18        3.18
                             0-nothp-2   1-nothp-2   2-nothp-2   3-nothp-2
Minor Faults                 197246131   197529492   197805972   197409194
Major Faults                       398         466         445         384
Swap Ins                            23          59          21          13
Swap Outs                          929         891        1046        1168
Allocation stalls                 4968        4816        4601        4524
DMA allocs                         100         102         168         141
DMA32 allocs                 123655788   124150784   124204923   124032735
Normal allocs                 58759141    58579320    58833935    58598639
Movable allocs                       0           0           0           0
Direct pages scanned            225672      232579      201836      196913
Kswapd pages scanned           2026634     2073933     2064589     2076511
Kswapd pages reclaimed         2022720     2070878     2061164     2072427
Direct pages reclaimed          224845      231656      201126      195774
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1003.135    1018.907     983.086    1005.648
Direct efficiency                  99%         99%         99%         99%
Direct velocity                111.702     114.265      96.108      95.365
Percentage direct scans            10%         10%          8%          8%
Zone normal velocity           363.005     361.000     351.299     353.425
Zone dma32 velocity            751.821     772.159     727.879     747.573
Zone dma velocity                0.012       0.012       0.016       0.015
Page writes by reclaim        1026.800    1018.600    1189.000    1389.600
Page writes file                    97         126         142         221
Page writes anon                   929         891        1046        1168
Page reclaim immediate            2368        1680        1750        2717
Sector Reads                   4459287     4515880     4549344     4521904
Sector Writes                 12631248    12678313    12707720    12655388
Page rescued immediate               0           0           0           0
Slabs scanned                  1955590     1889819     2091926     1975239
Direct inode steals              19201       17306       21977       17822
Kswapd inode steals             172857      145147      205146      174587
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    232         244         260         243
THP collapse alloc                 340         302         332         364
THP splits                          12          13          12          12
THP fault fallback                   6           5           0           1
THP collapse fail                   24          25          23          23
Compaction stalls                 1795        1812        1891        1719
Compaction success                 287         315         348         303
Compaction failures               1508        1497        1543        1415
Page migrate success           3660128     3527715     3695452     3482429
Page migrate failure             10746       10903        9716        9459
Compaction pages isolated      7468799     7198253     7541268     7113943
Compaction migrate scanned    69039767    76820644    86198799    76076461
Compaction free scanned      296178645   293352136   292601706   264948833
Compaction cost                   4424        4336        4582        4282
NUMA alloc hit               180446569   180703255   180947345   180593203
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             180446569   180703255   180947345   180593203
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                               3.18            3.18            3.18            3.18
                                                          0-nothp-2       1-nothp-2       2-nothp-2       3-nothp-2
Page alloc extfrag event                                1960806     1682705      868136      602097
Extfrag fragmenting                                     1960268     1682153      867624      601608
Extfrag fragmenting for unmovable                         14373       13973       12275        2158
Extfrag fragmenting unmovable placed with movable         10465        7233        8814        1821
Extfrag fragmenting for reclaimable                        2268        1244        1122        1284
Extfrag fragmenting reclaimable placed with movable        2092        1010         940        1033
Extfrag fragmenting for movable                         1943627     1666936      854227      598166


Iteration 3 after reboot. Again a bit worse.

                                 3.18                  3.18                  3.18                  3.18
                            0-nothp-3             1-nothp-3             2-nothp-3             3-nothp-3
Success 1 Min         12.00 (  0.00%)       12.00 (  0.00%)       16.00 (-33.33%)       13.00 ( -8.33%)
Success 1 Mean        17.20 (  0.00%)       18.00 ( -4.65%)       18.40 ( -6.98%)       17.20 (  0.00%)
Success 1 Max         25.00 (  0.00%)       23.00 (  8.00%)       22.00 ( 12.00%)       21.00 ( 16.00%)
Success 2 Min         17.00 (  0.00%)       17.00 (  0.00%)       21.00 (-23.53%)       18.00 ( -5.88%)
Success 2 Mean        21.20 (  0.00%)       22.60 ( -6.60%)       24.00 (-13.21%)       22.40 ( -5.66%)
Success 2 Max         28.00 (  0.00%)       28.00 (  0.00%)       27.00 (  3.57%)       25.00 ( 10.71%)
Success 3 Min         77.00 (  0.00%)       78.00 ( -1.30%)       78.00 ( -1.30%)       79.00 ( -2.60%)
Success 3 Mean        78.60 (  0.00%)       79.40 ( -1.02%)       79.40 ( -1.02%)       79.60 ( -1.27%)
Success 3 Max         80.00 (  0.00%)       81.00 ( -1.25%)       81.00 ( -1.25%)       81.00 ( -1.25%)

                3.18        3.18        3.18        3.18
           0-nothp-3   1-nothp-3   2-nothp-3   3-nothp-3
User         6969.43     6943.72     6971.01     6957.16
System       1052.91     1057.03     1056.81     1051.51
Elapsed      2075.96     2137.93     2066.80     2050.85

                                  3.18        3.18        3.18        3.18
                             0-nothp-3   1-nothp-3   2-nothp-3   3-nothp-3
Minor Faults                 198002094   197799251   197671808   197131275
Major Faults                       481         452         430         440
Swap Ins                            84          75          58          69
Swap Outs                          485         512         617         797
Allocation stalls                 5130        4895        4369        4198
DMA allocs                         131         112         168         147
DMA32 allocs                 124297093   124088280   124075970   123837281
Normal allocs                 58843460    58836194    58764835    58477182
Movable allocs                       0           0           0           0
Direct pages scanned            215029      207548      161207      156133
Kswapd pages scanned           2063367     2056503     2083316     2064295
Kswapd pages reclaimed         2060617     2053632     2080418     2061267
Direct pages reclaimed          214064      206675      160724      155420
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1016.447    1001.068    1000.844     994.439
Direct efficiency                  99%         99%         99%         99%
Direct velocity                105.927     101.031      77.446      75.214
Percentage direct scans             9%          9%          7%          7%
Zone normal velocity           362.943     352.065     341.152     336.018
Zone dma32 velocity            759.419     750.021     737.124     733.616
Zone dma velocity                0.013       0.013       0.014       0.020
Page writes by reclaim         593.000     648.200     718.200    1011.600
Page writes file                   107         135         101         214
Page writes anon                   485         512         617         797
Page reclaim immediate            1496        1554        1226        1362
Sector Reads                   4509982     4470464     4521328     4490060
Sector Writes                 12730210    12693418    12678674    12570993
Page rescued immediate               0           0           0           0
Slabs scanned                  2004683     1996351     2093517     2070616
Direct inode steals              22399       22594       21935       19771
Kswapd inode steals             177424      186779      221443      220300
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    249         253         249         227
THP collapse alloc                 401         309         276         326
THP splits                          13          14          12          13
THP fault fallback                  14           5           0           0
THP collapse fail                   20          24          26          24
Compaction stalls                 1864        1896        1882        1804
Compaction success                 326         332         321         294
Compaction failures               1537        1564        1560        1510
Page migrate success           3779905     3591736     3710886     3603691
Page migrate failure             10248       12087        9537        9811
Compaction pages isolated      7725248     7336155     7570704     7354030
Compaction migrate scanned    81291471    81714847    82830202    79307459
Compaction free scanned      285896115   288986961   286083443   276906989
Compaction cost                   4639        4439        4575        4435
NUMA alloc hit               181116213   180919428   180842690   180328118
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             181116213   180919428   180842690   180328118
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                               3.18            3.18            3.18            3.18
                                                          0-nothp-3       1-nothp-3       2-nothp-3       3-nothp-3
Page alloc extfrag event                                1485930     1858687      831967      777544
Extfrag fragmenting                                     1485545     1858248      831574      777153
Extfrag fragmenting for unmovable                         14710       15110       10055        3106
Extfrag fragmenting unmovable placed with movable          8294        8117        7059        2709
Extfrag fragmenting for reclaimable                        2253        1292        1258        1239
Extfrag fragmenting reclaimable placed with movable        2070        1050        1050         972
Extfrag fragmenting for movable                         1468582     1841846      820261      772808


Iteration 4:

                                 3.18                  3.18                  3.18                  3.18
                            0-nothp-4             1-nothp-4             2-nothp-4             3-nothp-4
Success 1 Min         11.00 (  0.00%)       15.00 (-36.36%)       15.00 (-36.36%)       11.00 (  0.00%)
Success 1 Mean        14.60 (  0.00%)       17.20 (-17.81%)       18.80 (-28.77%)       16.80 (-15.07%)
Success 1 Max         19.00 (  0.00%)       18.00 (  5.26%)       25.00 (-31.58%)       28.00 (-47.37%)
Success 2 Min         16.00 (  0.00%)       16.00 (  0.00%)       22.00 (-37.50%)       17.00 ( -6.25%)
Success 2 Mean        18.80 (  0.00%)       22.40 (-19.15%)       24.20 (-28.72%)       22.40 (-19.15%)
Success 2 Max         21.00 (  0.00%)       28.00 (-33.33%)       27.00 (-28.57%)       31.00 (-47.62%)
Success 3 Min         76.00 (  0.00%)       77.00 ( -1.32%)       78.00 ( -2.63%)       77.00 ( -1.32%)
Success 3 Mean        77.60 (  0.00%)       77.80 ( -0.26%)       78.80 ( -1.55%)       78.40 ( -1.03%)
Success 3 Max         80.00 (  0.00%)       80.00 (  0.00%)       80.00 (  0.00%)       80.00 (  0.00%)

                3.18        3.18        3.18        3.18
           0-nothp-4   1-nothp-4   2-nothp-4   3-nothp-4
User         7014.11     6945.27     6957.40     6963.31
System       1055.82     1054.82     1053.90     1055.12
Elapsed      2058.53     2058.56     2075.28     2048.52

                                  3.18        3.18        3.18        3.18
                             0-nothp-4   1-nothp-4   2-nothp-4   3-nothp-4
Minor Faults                 197873509   198398469   197895081   197535790
Major Faults                       407         419         427         402
Swap Ins                            37          50          37          30
Swap Outs                          338         371         439         388
Allocation stalls                 5195        4652        4513        4325
DMA allocs                          99         107         145         133
DMA32 allocs                 124092064   124319488   124167239   123944556
Normal allocs                 58773824    59100526    58883054    58700006
Movable allocs                       0           0           0           0
Direct pages scanned            216998      190534      174921      155459
Kswapd pages scanned           2040693     2087853     2082845     2077534
Kswapd pages reclaimed         2037419     2085208     2080120     2074709
Direct pages reclaimed          216518      189914      174192      154957
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1000.384     996.128     991.642    1026.049
Direct efficiency                  99%         99%         99%         99%
Direct velocity                106.377      90.905      83.280      76.778
Percentage direct scans             9%          8%          7%          6%
Zone normal velocity           347.776     345.668     342.893     350.841
Zone dma32 velocity            758.972     741.345     732.009     751.972
Zone dma velocity                0.013       0.020       0.020       0.015
Page writes by reclaim         399.800     452.800     631.400     568.000
Page writes file                    61          81         191         179
Page writes anon                   338         371         439         388
Page reclaim immediate            1704        1090        1217        1245
Sector Reads                   4461358     4478920     4516170     4505277
Sector Writes                 12698146    12785845    12720364    12645422
Page rescued immediate               0           0           0           0
Slabs scanned                  1976614     1994349     2077089     2081061
Direct inode steals              22948       15954       17649       20023
Kswapd inode steals             175854      186992      208169      216263
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    246         262         264         240
THP collapse alloc                 255         265         327         310
THP splits                          14          13          13          13
THP fault fallback                   5          15           0           2
THP collapse fail                   27          27          25          25
Compaction stalls                 1778        1873        1859        1824
Compaction success                 275         318         319         299
Compaction failures               1502        1555        1540        1524
Page migrate success           3633014     3657877     3634074     3598224
Page migrate failure              9804        8803        9796        9708
Compaction pages isolated      7420349     7474113     7419569     7342056
Compaction migrate scanned    72131019    83649881    82656970    81781759
Compaction free scanned      285190682   294019483   273748735   275195864
Compaction cost                   4417        4524        4491        4447
NUMA alloc hit               180976412   181453188   181021959   180675563
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             180976412   181453188   181021959   180675563
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

                                                               3.18            3.18            3.18            3.18
                                                          0-nothp-4       1-nothp-4       2-nothp-4       3-nothp-4
Page alloc extfrag event                                1952436     1661151      738877      773695
Extfrag fragmenting                                     1952086     1660760      738488      773341
Extfrag fragmenting for unmovable                         20531       14360        7780        8540
Extfrag fragmenting unmovable placed with movable         14937        7515        4644        7982
Extfrag fragmenting for reclaimable                        2372        1458        1559        1349
Extfrag fragmenting reclaimable placed with movable        2163        1184        1229        1084
Extfrag fragmenting for movable                         1929183     1644942      729149      763452


Iteration 5:

                                 3.18                  3.18                  3.18                  3.18
                            0-nothp-5             1-nothp-5             2-nothp-5             3-nothp-5
Success 1 Min         11.00 (  0.00%)       12.00 ( -9.09%)       12.00 ( -9.09%)       13.00 (-18.18%)
Success 1 Mean        14.80 (  0.00%)       14.80 (  0.00%)       17.60 (-18.92%)       15.00 ( -1.35%)
Success 1 Max         19.00 (  0.00%)       17.00 ( 10.53%)       24.00 (-26.32%)       18.00 (  5.26%)
Success 2 Min         14.00 (  0.00%)       17.00 (-21.43%)       18.00 (-28.57%)       19.00 (-35.71%)
Success 2 Mean        18.80 (  0.00%)       19.80 ( -5.32%)       23.20 (-23.40%)       21.20 (-12.77%)
Success 2 Max         24.00 (  0.00%)       22.00 (  8.33%)       29.00 (-20.83%)       24.00 (  0.00%)
Success 3 Min         75.00 (  0.00%)       76.00 ( -1.33%)       76.00 ( -1.33%)       75.00 (  0.00%)
Success 3 Mean        76.80 (  0.00%)       77.20 ( -0.52%)       77.20 ( -0.52%)       77.00 ( -0.26%)
Success 3 Max         78.00 (  0.00%)       79.00 ( -1.28%)       79.00 ( -1.28%)       78.00 (  0.00%)

                3.18        3.18        3.18        3.18
           0-nothp-5   1-nothp-5   2-nothp-5   3-nothp-5
User         7010.91     6975.75     6915.14     6970.45
System       1055.83     1056.19     1053.80     1052.33
Elapsed      2052.31     2048.28     2050.12     2053.89

                                  3.18        3.18        3.18        3.18
                             0-nothp-5   1-nothp-5   2-nothp-5   3-nothp-5
Minor Faults                 197030140   197319524   197489685   197695270
Major Faults                       429         411         415         390
Swap Ins                            49          55          36          30
Swap Outs                          305         228         332         381
Allocation stalls                 5108        4659        4490        4328
DMA allocs                          99         134         141         122
DMA32 allocs                 123508440   123843605   123873130   124099102
Normal allocs                 58622667    58573504    58761770    58652867
Movable allocs                       0           0           0           0
Direct pages scanned            220984      190063      158418      149760
Kswapd pages scanned           2043404     2049188     2073308     2067291
Kswapd pages reclaimed         2031444     2046517     2067186     2064528
Direct pages reclaimed          218557      189225      157980      149287
Kswapd efficiency                  99%         99%         99%         99%
Kswapd velocity               1012.674    1015.123    1022.432    1008.494
Direct efficiency                  98%         99%         99%         99%
Direct velocity                109.516      94.153      78.122      73.058
Percentage direct scans             9%          8%          7%          6%
Zone normal velocity           354.483     355.563     345.106     347.632
Zone dma32 velocity            767.696     753.701     755.430     733.904
Zone dma velocity                0.011       0.013       0.018       0.016
Page writes by reclaim         431.000     315.200     527.200     540.000
Page writes file                   125          87         194         158
Page writes anon                   305         228         332         381
Page reclaim immediate           12115        1719        4469        1280
Sector Reads                   4487948     4453748     4502543     4490908
Sector Writes                 12621033    12653866    12659975    12687881
Page rescued immediate               0           0           0           0
Slabs scanned                  1956286     1958388     2088099     2073000
Direct inode steals              15390       20539       24285       29811
Kswapd inode steals             185143      183428      219000      210892
Kswapd skipped wait                  0           0           0           0
THP fault alloc                    230         248         243         253
THP collapse alloc                 278         335         340         280
THP splits                          12          13          12          12
THP fault fallback                   5           2           2           1
THP collapse fail                   25          25          23          26
Compaction stalls                 1780        1797        1877        1859
Compaction success                 283         281         324         305
Compaction failures               1497        1516        1553        1554
Page migrate success           3670577     3519806     3645951     3783349
Page migrate failure              8559        9771       11186        9559
Compaction pages isolated      7495004     7189748     7444082     7722521
Compaction migrate scanned    75257058    74119179    84933954    80371020
Compaction free scanned      282720327   290434359   282089729   300987492
Compaction cost                   4479        4309        4520        4636
NUMA alloc hit               180250566   180484746   180642086   180827624
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local             180250566   180484746   180642086   180827624
NUMA base PTE updates                0           0           0           0
NUMA huge PMD updates                0           0           0           0
NUMA page range updates              0           0           0           0
NUMA hint faults                     0           0           0           0
NUMA hint local faults               0           0           0           0
NUMA hint local percent            100         100         100         100
NUMA pages migrated                  0           0           0           0
AutoNUMA cost                       0%          0%          0%          0%

WARNING: CPU:3 [LOST 7268 EVENTS]
WARNING: CPU:2 [LOST 10396 EVENTS]
- those were in 0-nothp-5, that's why it looks so good
- on the other hand, events for 1-nothp-5 look absurdly high
                                                               3.18            3.18            3.18            3.18
                                                          0-nothp-5       1-nothp-5       2-nothp-5       3-nothp-5
Page alloc extfrag event                                1532339     2043456      659360      824401
Extfrag fragmenting                                     1532007     2043095      658942      824041
Extfrag fragmenting for unmovable                         12148      143580        8546        3232
Extfrag fragmenting unmovable placed with movable          9266      139803        5350        2915
Extfrag fragmenting for reclaimable                        2159        1374        1319        1298
Extfrag fragmenting reclaimable placed with movable        1988        1165        1047        1096
Extfrag fragmenting for movable                         1517700     1898141      649077      819511

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
