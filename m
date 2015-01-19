Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id BC2CA6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:10:47 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so6941262wes.10
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:10:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy4si20300235wib.47.2015.01.19.02.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 02:10:44 -0800 (PST)
Message-ID: <54BCD822.6050301@suse.cz>
Date: Mon, 19 Jan 2015 11:10:42 +0100
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

Looks like wrapping got busted in the results part. Let's try again:
-----

Even after all the patches compaction received in last several versions, it
turns out that its effectivneess degrades considerably as the system ages
after reboot. For example, see how success rates of stress-highalloc from
mmtests degrades when we re-execute it several times, first time being after
fresh reboot:
                             3.19-rc4              3.19-rc4              3.19-rc4
                            4-nothp-1             4-nothp-2             4-nothp-3
Success 1 Min         25.00 (  0.00%)       13.00 ( 48.00%)        9.00 ( 64.00%)
Success 1 Mean        36.20 (  0.00%)       23.40 ( 35.36%)       16.40 ( 54.70%)
Success 1 Max         41.00 (  0.00%)       34.00 ( 17.07%)       25.00 ( 39.02%)
Success 2 Min         25.00 (  0.00%)       15.00 ( 40.00%)       10.00 ( 60.00%)
Success 2 Mean        37.20 (  0.00%)       25.00 ( 32.80%)       17.20 ( 53.76%)
Success 2 Max         44.00 (  0.00%)       36.00 ( 18.18%)       25.00 ( 43.18%)
Success 3 Min         84.00 (  0.00%)       81.00 (  3.57%)       78.00 (  7.14%)
Success 3 Mean        85.80 (  0.00%)       82.80 (  3.50%)       80.40 (  6.29%)
Success 3 Max         87.00 (  0.00%)       84.00 (  3.45%)       82.00 (  5.75%)

Wouldn't it be much better, if it looked like this?

                           3.18                  3.18                  3.18
                             3.19-rc4              3.19-rc4              3.19-rc4
                            5-nothp-1             5-nothp-2             5-nothp-3
Success 1 Min         49.00 (  0.00%)       42.00 ( 14.29%)       41.00 ( 16.33%)
Success 1 Mean        51.00 (  0.00%)       45.00 ( 11.76%)       42.60 ( 16.47%)
Success 1 Max         55.00 (  0.00%)       51.00 (  7.27%)       46.00 ( 16.36%)
Success 2 Min         53.00 (  0.00%)       47.00 ( 11.32%)       44.00 ( 16.98%)
Success 2 Mean        59.60 (  0.00%)       50.80 ( 14.77%)       48.20 ( 19.13%)
Success 2 Max         64.00 (  0.00%)       56.00 ( 12.50%)       52.00 ( 18.75%)
Success 3 Min         84.00 (  0.00%)       82.00 (  2.38%)       78.00 (  7.14%)
Success 3 Mean        85.60 (  0.00%)       82.80 (  3.27%)       79.40 (  7.24%)
Success 3 Max         86.00 (  0.00%)       83.00 (  3.49%)       80.00 (  6.98%)

In my humble opinion, it would :) Much lower degradation, and a nice
improvement in the first iteration as a bonus.

So what sorcery is this? Nothing much, just a fundamental change of the
compaction scanners operation...

As everyone knows [1] the migration scanner starts at the first pageblock
of a zone, and goes towards the end, and the free scanner starts at the
last pageblock and goes towards the beginning. Somewhere in the middle of the
zone, the scanners meet:

   zone_start                                                   zone_end
       |                                                           |
       -------------------------------------------------------------
       MMMMMMMMMMMMM| =>                            <= |FFFFFFFFFFFF
               migrate_pfn                         free_pfn

In my tests, the scanners meet around the middle of the pageblock on the first
iteration, and around the 1/3 on subsequent iterations. Which means the
migration scanner doesn't see the larger part of the zone at all. For more
details why it's bad, see Patch 4 description.

To make sure we eventually scan the whole zone with the migration scanner, we
could e.g. reverse the directions after each run. But that would still be
biased, and with 1/3 of zone reachable from each side, we would still omit the
middle 1/3 of a zone.

Or we could stop terminating compaction when the scanners meet, and let them
continue to scan the whole zone. Mel told me it used to be the case long ago,
but that approach would result in migrating pages back and forth during single
compaction run, which wouldn't be cool.

So the approach taken by this patchset is to let scanners start at any
so-called pivot pfn within the zone, and keep their direction:

   zone_start                     pivot                         zone_end
       |                            |                              |
       -------------------------------------------------------------
                         <= |FFFFFFFMMMMMM| =>
                        free_pfn     migrate_pfn

Eventually, one of the scanners will reach the zone boundary and wrap around,
e.g. the in the case of the free scanner:

   zone_start                     pivot                         zone_end
       |                            |                              |
       -------------------------------------------------------------
       FFFFFFFFFFFFFFFFFFFFFFFFFFFFFMMMMMMMMMMMM| =>           <= |F
                                           migrate_pfn        free_pfn

Compaction will again terminate when the scanners meet.


As you can imagine, the required code changes made the termination detection
and the scanners themselves quite hairy. There are lots of corner cases and
the code is often hard to wrap one's head around [puns intended]. The scanner
functions isolate_migratepages() and isolate_freepages() were recently cleaned
up a lot, and this makes them messy again, as they can no longer rely on the
fact that they will meet the other scanner and not the zone boundary.

But the improvements seem to make these complications worth, and I hope
somebody can suggest more elegant solutions to the various parts of the code.
So here it is as a RFC. Patches 1-3 are cleanups that could be applied in any
case. Patch 4 implements the main changes, but leaves the pivot to be the
first zone's pfn, so that free scanner wraps immediately and there's no
actual change. Patch 5 updates the pivot in a conservative way, as explained
in the changelog.

Even with the conservative approach, stress-highalloc results are improved,
mainly on the 2+ iterations after fresh reboot. Here are again the results
before the patches, including compaction stats:

                             3.19-rc4              3.19-rc4              3.19-rc4
                            4-nothp-1             4-nothp-2             4-nothp-3
Success 1 Min         25.00 (  0.00%)       13.00 ( 48.00%)        9.00 ( 64.00%)
Success 1 Mean        36.20 (  0.00%)       23.40 ( 35.36%)       16.40 ( 54.70%)
Success 1 Max         41.00 (  0.00%)       34.00 ( 17.07%)       25.00 ( 39.02%)
Success 2 Min         25.00 (  0.00%)       15.00 ( 40.00%)       10.00 ( 60.00%)
Success 2 Mean        37.20 (  0.00%)       25.00 ( 32.80%)       17.20 ( 53.76%)
Success 2 Max         44.00 (  0.00%)       36.00 ( 18.18%)       25.00 ( 43.18%)
Success 3 Min         84.00 (  0.00%)       81.00 (  3.57%)       78.00 (  7.14%)
Success 3 Mean        85.80 (  0.00%)       82.80 (  3.50%)       80.40 (  6.29%)
Success 3 Max         87.00 (  0.00%)       84.00 (  3.45%)       82.00 (  5.75%)

            3.19-rc4    3.19-rc4    3.19-rc4
           4-nothp-1   4-nothp-2   4-nothp-3
User         6781.16     6931.44     6905.44
System       1073.97     1071.20     1067.92                                                                                                                                                                   
Elapsed      2349.71     2290.40     2255.59                                                                                                                                                                   
                                                                                                                                                                                                               
                              3.19-rc4    3.19-rc4    3.19-rc4                                                                                                                                                 
                             4-nothp-1   4-nothp-2   4-nothp-3                                                                                                                                                 
Minor Faults                 198270153   197020929   197146656                                                                                                                                                 
Major Faults                       498         470         527                                                                                                                                                 
Swap Ins                            60          34         105                                                                                                                                                 
Swap Outs                         2780        1011         425                                                                                                                                                 
Allocation stalls                 8325        4615        4769                                                                                                                                                 
DMA allocs                         161         177         141                                                                                                                                                 
DMA32 allocs                 124477754   123412713   123385291                                                                                                                                                 
Normal allocs                 59366406    59040066    58909035                                                                                                                                                 
Movable allocs                       0           0           0                                                                                                                                                 
Direct pages scanned            413858      280997      267341                                                                                                                                                 
Kswapd pages scanned           2204723     2184556     2147546                                                                                                                                                 
Kswapd pages reclaimed         2199430     2181305     2144395                                                                                                                                                 
Direct pages reclaimed          413062      280323      266557                                                                                                                                                 
Kswapd efficiency                  99%         99%         99%                                                                                                                                                 
Kswapd velocity                914.497     977.868     943.877                                                                                                                                                 
Direct efficiency                  99%         99%         99%                                                                                                                                                 
Direct velocity                171.664     125.782     117.500                                                                                                                                                 
Percentage direct scans            15%         11%         11%
Zone normal velocity           359.993     356.888     339.577
Zone dma32 velocity            726.152     746.745     721.784
Zone dma velocity                0.016       0.017       0.016
Page writes by reclaim        2893.000    1119.800     507.600
Page writes file                   112         108          81
Page writes anon                  2780        1011         425
Page reclaim immediate            1134        1197        1412
Sector Reads                   4747006     4606605     4524025
Sector Writes                 12759301    12562316    12629243
Page rescued immediate               0           0           0
Slabs scanned                  1807821     1528751     1498929
Direct inode steals              24428       12649       13346
Kswapd inode steals              33213       29804       30194
Kswapd skipped wait                  0           0           0
THP fault alloc                    217         207         222
THP collapse alloc                 500         539         373
THP splits                          13          14          13
THP fault fallback                  50           9          16
THP collapse fail                   16          17          22
Compaction stalls                 3136        2310        2072
Compaction success                1123         897         828
Compaction failures               2012        1413        1244
Page migrate success           4319697     3682666     3133699
Page migrate failure             19012        9964        7488
Compaction pages isolated      8974417     7634911     6528981
Compaction migrate scanned   182447073   122423031   127292737
Compaction free scanned      389193883   291257587   269516820
Compaction cost                   5931        4824        4267

As the allocation success rates degrade, so do the compaction success rates,
and so does the scanner activity.

Now after the series:

                             3.19-rc4              3.19-rc4              3.19-rc4
                            5-nothp-1             5-nothp-2             5-nothp-3
Success 1 Min         49.00 (  0.00%)       42.00 ( 14.29%)       41.00 ( 16.33%)
Success 1 Mean        51.00 (  0.00%)       45.00 ( 11.76%)       42.60 ( 16.47%)
Success 1 Max         55.00 (  0.00%)       51.00 (  7.27%)       46.00 ( 16.36%)
Success 2 Min         53.00 (  0.00%)       47.00 ( 11.32%)       44.00 ( 16.98%)
Success 2 Mean        59.60 (  0.00%)       50.80 ( 14.77%)       48.20 ( 19.13%)
Success 2 Max         64.00 (  0.00%)       56.00 ( 12.50%)       52.00 ( 18.75%)
Success 3 Min         84.00 (  0.00%)       82.00 (  2.38%)       78.00 (  7.14%)
Success 3 Mean        85.60 (  0.00%)       82.80 (  3.27%)       79.40 (  7.24%)
Success 3 Max         86.00 (  0.00%)       83.00 (  3.49%)       80.00 (  6.98%)

            3.19-rc4    3.19-rc4    3.19-rc4
           5-nothp-1   5-nothp-2   5-nothp-3
User         6675.75     6742.26     6707.92
System       1069.78     1070.77     1070.25
Elapsed      2450.31     2363.98     2442.21

                              3.19-rc4    3.19-rc4    3.19-rc4
                             5-nothp-1   5-nothp-2   5-nothp-3
Minor Faults                 197652452   197164571   197946824
Major Faults                       882         743         934
Swap Ins                           113          96         144
Swap Outs                         2144        1340        1799
Allocation stalls                10304        9060       10261
DMA allocs                         142         227         181
DMA32 allocs                 124497911   123947671   124010151                                                                                                                                                 
Normal allocs                 59233600    59160910    59669421                                                                                                                                                 
Movable allocs                       0           0           0                                                                                                                                                 
Direct pages scanned            591368      481119      525158                                                                                                                                                 
Kswapd pages scanned           2217381     2164036     2170388                                                                                                                                                 
Kswapd pages reclaimed         2212285     2160162     2166794                                                                                                                                                 
Direct pages reclaimed          590064      480297      524013                                                                                                                                                 
Kswapd efficiency                  99%         99%         99%                                                                                                                                                 
Kswapd velocity                921.119     937.864     936.558                                                                                                                                                 
Direct efficiency                  99%         99%         99%                                                                                                                                                 
Direct velocity                245.659     208.511     226.615                                                                                                                                                 
Percentage direct scans            21%         18%         19%                                                                                                                                                 
Zone normal velocity           378.957     376.819     383.604                                                                                                                                                 
Zone dma32 velocity            787.805     769.530     779.552                                                                                                                                                 
Zone dma velocity                0.015       0.025       0.016                                                                                                                                                 
Page writes by reclaim        2284.600    1432.400    1972.400                                                                                                                                                 
Page writes file                   140          92         173                                                                                                                                                 
Page writes anon                  2144        1340        1799                                                                                                                                                 
Page reclaim immediate            1689        1315        1440                                                                                                                                                 
Sector Reads                   4920699     4830343     4830263                                                                                                                                                 
Sector Writes                 12643658    12588410    12713518                                                                                                                                                 
Page rescued immediate               0           0           0                                                                                                                                                 
Slabs scanned                  2084358     1922421     1962867
Direct inode steals              35881       37170       45512
Kswapd inode steals              35973       35741       30339
Kswapd skipped wait                  0           0           0
THP fault alloc                    191         224         170
THP collapse alloc                 554         533         516
THP splits                          15          15          11
THP fault fallback                  45           0          76
THP collapse fail                   16          18          18
Compaction stalls                 4069        3746        3951
Compaction success                1507        1388        1366
Compaction failures               2562        2357        2585
Page migrate success           4533617     4912832     5278583
Page migrate failure             20127       15273       17862
Compaction pages isolated      9495626    10235697    10993942
Compaction migrate scanned    93585708    99204656    92052138
Compaction free scanned      510786018   503529022   541298357
Compaction cost                   5541        5988        6332

Less degradation in success rates and no degradation in activity.
Let's look again at compactions stats without the series:

Compaction stalls                 3136        2310        2072
Compaction success                1123         897         828
Compaction failures               2012        1413        1244
Page migrate success           4319697     3682666     3133699
Page migrate failure             19012        9964        7488
Compaction pages isolated      8974417     7634911     6528981
Compaction migrate scanned   182447073   122423031   127292737
Compaction free scanned      389193883   291257587   269516820
Compaction cost                   5931        4824        4267

Interestingly, the number of migrate scanned pages was higher before the
series, even twice in the first iteration. That suggests that the scanner
was indeed scanning in a limited number of pageblocks over and over, despite
their compaction potential "depleted". After the patches, it achieves better
results with less scanned blocks, as it has a better chance of encountering
non-depleted blocks. The free scanner activity has increased after the series,
which just means that higher success rates lead to less deferred compaction.
There is also some increase in page migrations, but it is likely also a
consequence of better success and not due to useless back and forth migrations
due to pivot changes.

Preliminary testing with THP-like allocations has shown similar improvements,
which is somewhat surprising, because THP allocations do not use sync
and thus do not defer compaction; but changing the pivot is currently tied
to restarting from deferred compaction. Possibly this is due to the other
allocation activity than the stress-highalloc test itself. I will post these
results when full measurements are done.

[1] http://lwn.net/Articles/368869/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
