Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id CA6776B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:11:04 -0500 (EST)
Received: by wmec201 with SMTP id c201so11037837wme.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:11:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14si10582031wmf.113.2015.12.03.00.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 00:11:02 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/3] reduce latency of direct async compaction
Date: Thu,  3 Dec 2015 09:10:44 +0100
Message-Id: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Aaron Lu <aaron.lu@intel.com>
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

The goal is to reduce latency (and increase success) of direct async compaction
by making it focus more on the goal of creating a high-order page, at the
expense of thoroughness. This should be useful for example for THP allocations
where we still get reports of being too expensive, most recently [2].

This is based on an older attempt [1] which I didn't finish as it seemed that
it increased longer-term fragmentation. Now it seems it doesn't, but I'll have
to test more properly. This patch (2) makes migration scanner skip whole
order-aligned blocks where isolation fails, as it takes just one unmigrated
page to prevent a high-order page from merging.

Patch 3 tries to reduce the excessive freepage scanning (such as in [3]) by
allocating migration targets from freelist. We just need to be sure that the
pages are not from the same block as the migrated pages. This is also limited
to direct async compaction and is not meant to replace a (potentially
redesigned) free scanner for other scenarios.

Early tests with stress-highalloc configured to simulate THP allocations:

                              4.4-rc2               4.4-rc2               4.4-rc2               4.4-rc2
                               0-test                1-test                2-test                3-test
Success 1 Min          1.00 (  0.00%)        2.00 (-100.00%)       2.00 (-100.00%)       3.00 (-200.00%)
Success 1 Mean         3.00 (  0.00%)        3.00 (  0.00%)        2.80 (  6.67%)        4.80 (-60.00%)
Success 1 Max          6.00 (  0.00%)        4.00 ( 33.33%)        5.00 ( 16.67%)        7.00 (-16.67%)
Success 2 Min          1.00 (  0.00%)        3.00 (-200.00%)       4.00 (-300.00%)       8.00 (-700.00%)
Success 2 Mean         3.80 (  0.00%)        4.00 ( -5.26%)        5.20 (-36.84%)       11.00 (-189.47%)
Success 2 Max          8.00 (  0.00%)        7.00 ( 12.50%)        6.00 ( 25.00%)       13.00 (-62.50%)
Success 3 Min         58.00 (  0.00%)       69.00 (-18.97%)       53.00 (  8.62%)       66.00 (-13.79%)
Success 3 Mean        67.40 (  0.00%)       74.00 ( -9.79%)       58.20 ( 13.65%)       68.80 ( -2.08%)
Success 3 Max         74.00 (  0.00%)       78.00 ( -5.41%)       70.00 (  5.41%)       72.00 (  2.70%)

             4.4-rc2     4.4-rc2     4.4-rc2     4.4-rc2
              0-test      1-test      2-test      3-test
User         3167.23     3140.58     3198.77     3049.85
System       1166.65     1158.64     1171.06     1140.18
Elapsed      1827.63     1737.69     1750.62     1793.82

                                  4.4-rc2     4.4-rc2     4.4-rc2     4.4-rc2
                                   0-test      1-test      2-test      3-test
Minor Faults                    107184766   107311664   107366319   108425875
Major Faults                          753         730         746         817
Swap Ins                              188         346         243         287
Swap Outs                            7278        6186        6226        5702
Allocation stalls                     988         868        1104         846
DMA allocs                             25          18          15          13
DMA32 allocs                     75074785    75104070    75131502    76260816
Normal allocs                    26112454    26193770    26142374    26291337
Movable allocs                          0           0           0           0
Direct pages scanned                83996       82251       80523       93509
Kswapd pages scanned              2122511     2107947     2110599     2121951
Kswapd pages reclaimed            2031597     2006468     2011184     2052483
Direct pages reclaimed              83806       82162       80315       93275
Kswapd efficiency                     95%         95%         95%         96%
Kswapd velocity                  1217.211    1202.789    1211.116    1189.075
Direct efficiency                     99%         99%         99%         99%
Direct velocity                    48.170      46.932      46.206      52.400
Percentage direct scans                3%          3%          3%          4%
Zone normal velocity              301.196     301.273     297.286     308.598
Zone dma32 velocity               964.185     948.448     960.036     932.877
Zone dma velocity                   0.000       0.000       0.000       0.000
Page writes by reclaim           7296.200    6187.400    6226.800    5702.600
Page writes file                       18           1           0           0
Page writes anon                     7278        6186        6226        5702
Page reclaim immediate                259         225          41         180
Sector Reads                      4132945     4074422     4099737     4291996
Sector Writes                    11066128    11057103    11066448    11083256
Page rescued immediate                  0           0           0           0
Slabs scanned                     1539471     1521153     1518145     1776426
Direct inode steals                  8482        3717        6096        9832
Kswapd inode steals                 37735       42700       39976       43492
Kswapd skipped wait                     0           0           0           0
THP fault alloc                       593         610         680         778
THP collapse alloc                    340         294         335         393
THP splits                              4           2           4           3
THP fault fallback                    751         748         705         626
THP collapse fail                      14          16          14          12
Compaction stalls                    6464        6373        6743        6451
Compaction success                    518         688         575         972
Compaction failures                  5945        5684        6167        5479
Page migrate success               318176      313488      239637      595224
Page migrate failure                40983       46106       12171        2587
Compaction pages isolated          733684      735737      564719      713799
Compaction migrate scanned        1101427     1056870      603977      969346
Compaction free scanned          17736383    15328486    11999748     5269641
Compaction cost                       352         347         263         638
NUMA alloc hit                   99632716    99690283    99753018   100771746
NUMA alloc miss                         0           0           0           0
NUMA interleave hit                     0           0           0           0
NUMA alloc local                 99632716    99690283    99753018   100771746
NUMA base PTE updates                   0           0           0           0
NUMA huge PMD updates                   0           0           0           0
NUMA page range updates                 0           0           0           0
NUMA hint faults                        0           0           0           0
NUMA hint local faults                  0           0           0           0
NUMA hint local percent               100         100         100         100
NUMA pages migrated                     0           0           0           0
AutoNUMA cost                          0%          0%          0%          0%

Migrate scanned pages are reduced by patch 2 as expected thanks to the skipping.
Patch 3 reduces free scanned pages significantly, and improves compaction
success and THP fault allocs (of the interfering activity, not the alloc test
itself). That results in more migrate scanner activity, as more success means
less deferring, and time spent previously in free sacanner can now be used in
migration scanner.

"Success 3" is indication of long-term fragmentation (the interference is
ceased in this phase) and it looks quite unstable overall (there shouldn't be
such difference between base and patch 1) but it doesn't seem decreased. I'm
suspecting it's the lack of reset_isolation_suitable() when the only activity
is async compaction. Needs more evaluation.

Aaron, could you try this on your testcase?

[1] https://lkml.org/lkml/2014/7/16/988
[2] http://www.spinics.net/lists/linux-mm/msg97378.html
[3] http://www.spinics.net/lists/linux-mm/msg97475.html

Vlastimil Babka (3):
  mm, compaction: reduce spurious pcplist drains
  mm, compaction: make async direct compaction skip blocks where
    isolation fails
  mm, compaction: direct freepage allocation for async direct compaction

 include/linux/vm_event_item.h |   1 +
 mm/compaction.c               | 122 +++++++++++++++++++++++++++++++++++-------
 mm/internal.h                 |   4 ++
 mm/page_alloc.c               |  27 ++++++++++
 mm/vmstat.c                   |   2 +
 5 files changed, 137 insertions(+), 19 deletions(-)

-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
