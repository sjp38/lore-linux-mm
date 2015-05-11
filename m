Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 86A486B0070
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:36:05 -0400 (EDT)
Received: by wief7 with SMTP id f7so87823294wie.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:36:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gc5si78073wib.61.2015.05.11.07.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:36:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/4] Outsourcing page fault THP allocations to khugepaged
Date: Mon, 11 May 2015 16:35:36 +0200
Message-Id: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

This series is an updated subset of the "big khugepaged redesign" [1] which
was then discussed at LSF/MM [2]. Following some advice, I split the series
and this is supposedly the less controversial part :)

What it means that the patches don't move the collapse scanning to task_work
context (yet), but focus on reducing the reclaim and compaction done in page
fault context, by shifting this effort towards khugepaged. This is benefical
for two reasons:

- reclaim and compaction in page fault context adds to the page fault latency,
  which might offset any benefits of a THP, especially for short-lived
  allocations, which cannot be distinguished at the time of page fault anyway

- THP allocations in page fault use only asynchronous compaction, which
  reduces the latency, but also the probability of succeeding. Failures do not
  result in deferred compaction. Khugepaged will use the more thorough
  synchronous compaction, won't exit in the middle of the work due to
  need_resched() and will cooperate with the deferred compaction mechanism
  properly.

To achieve this:

* Patch 1 removes the THP preallocation from khugepaged in preparation for
  the next patch. It is restricted to !NUMA configurations and complicates the
  code.

* Patch 2 introduces a thp_avail_nodes nodemask where khugepaged clears bits
  for nodes where it failed to allocate a hugepage during collapse. Before
  scanning for collapse, it tries to allocate a hugepage from each such node
  and set the bit back. If all online nodes are cleared and cannot be re-set,
  it won't scan for collapse at all. In case the THP is going to be collapsed
  on one of the nodes that are cleared, it will skip such PMD ASAP.

* Patch 3 uses the nodemask introduced in Patch 2 also to determine whether
  page faults should skip the attempt to allocate THP. It will also clear the
  node where allocation is attempted and fails. Complementary, freeing of page
  of sufficient order from any context sets the node as THP-available.

* Patch 4 improves the reaction to THP page fault allocation attempts by waking
  khugepaged in case allocation is both failed or skipped due to cleared
  availability bit. The latter ensures that deferred compaction is tracked
  appropriately for each potentially-THP page fault.

For evaluation, the new thpscale benchmark from mmtests was used. This test
fragments memory between anonymous and file mappings and then tries to fault
aligned 2MB blocks in another anonymous mapping, using mincore(2) to determine
if the first fault has brought the whole block and thus it was a THP page
fault. The anonymous mappings should fit in the memory while the file mappings
are expected to be reclaimed during the process, The latency is measured for
the whole sequence of initial fault, mincore syscall, and memset of the whole
block. Latency is reported in microseconds, separately for blocks that were
faulted as THP and base pages. This is repeated with different numbers of
threads doing the faults in parallel.

The results are not particularly stable, but show the difference of this
patchset. This is on 4-core single-node machine:

thpscale Fault Latencies (microseconds)
                                     4.1-rc2               4.1-rc2
                                           0                     4
Min      fault-base-1      1562.00 (  0.00%)     1407.00 (  9.92%)
Min      fault-base-3      1855.00 (  0.00%)     1808.00 (  2.53%)
Min      fault-base-5      2091.00 (  0.00%)     1930.00 (  7.70%)
Min      fault-base-7      2082.00 (  0.00%)     2222.00 ( -6.72%)
Min      fault-base-12     2489.00 (  0.00%)     2292.00 (  7.91%)
Min      fault-base-16     2092.00 (  0.00%)     1928.00 (  7.84%)
Min      fault-huge-1       953.00 (  0.00%)     1282.00 (-34.52%)
Min      fault-huge-3      1319.00 (  0.00%)     1218.00 (  7.66%)
Min      fault-huge-5      1527.00 (  0.00%)     1268.00 ( 16.96%)
Min      fault-huge-7      1277.00 (  0.00%)     1276.00 (  0.08%)
Min      fault-huge-12     2286.00 (  0.00%)     1419.00 ( 37.93%)
Min      fault-huge-16     2395.00 (  0.00%)     2158.00 (  9.90%)
Amean    fault-base-1      3322.97 (  0.00%)     2130.35 ( 35.89%)
Amean    fault-base-3      3372.55 (  0.00%)     3331.46 (  1.22%)
Amean    fault-base-5      7684.34 (  0.00%)     4086.17 ( 46.82%)
Amean    fault-base-7     10010.14 (  0.00%)     5367.27 ( 46.38%)
Amean    fault-base-12    11000.00 (  0.00%)     8529.81 ( 22.46%)
Amean    fault-base-16    15021.71 (  0.00%)    14164.72 (  5.70%)
Amean    fault-huge-1      2534.19 (  0.00%)     2419.83 (  4.51%)
Amean    fault-huge-3      5312.42 (  0.00%)     4783.90 (  9.95%)
Amean    fault-huge-5      8086.82 (  0.00%)     7050.06 ( 12.82%)
Amean    fault-huge-7     11184.91 (  0.00%)     6359.74 ( 43.14%)
Amean    fault-huge-12    17218.58 (  0.00%)     9120.60 ( 47.03%)
Amean    fault-huge-16    18176.03 (  0.00%)    21161.54 (-16.43%)
Stddev   fault-base-1      3652.46 (  0.00%)     3197.59 ( 12.45%)
Stddev   fault-base-3      4960.05 (  0.00%)     5633.47 (-13.58%)
Stddev   fault-base-5      9309.31 (  0.00%)     6587.24 ( 29.24%)
Stddev   fault-base-7     11266.55 (  0.00%)     7629.93 ( 32.28%)
Stddev   fault-base-12    10899.31 (  0.00%)     9803.98 ( 10.05%)
Stddev   fault-base-16    17360.78 (  0.00%)    18654.45 ( -7.45%)
Stddev   fault-huge-1       764.26 (  0.00%)      379.14 ( 50.39%)
Stddev   fault-huge-3      6030.37 (  0.00%)     4231.11 ( 29.84%)
Stddev   fault-huge-5      5953.79 (  0.00%)     7069.40 (-18.74%)
Stddev   fault-huge-7      8557.60 (  0.00%)     5742.90 ( 32.89%)
Stddev   fault-huge-12    12563.23 (  0.00%)     7376.70 ( 41.28%)
Stddev   fault-huge-16    10370.34 (  0.00%)    14153.56 (-36.48%)
CoeffVar fault-base-1       109.92 (  0.00%)      150.10 (-36.56%)
CoeffVar fault-base-3       147.07 (  0.00%)      169.10 (-14.98%)
CoeffVar fault-base-5       121.15 (  0.00%)      161.21 (-33.07%)
CoeffVar fault-base-7       112.55 (  0.00%)      142.16 (-26.30%)
CoeffVar fault-base-12       99.08 (  0.00%)      114.94 (-16.00%)
CoeffVar fault-base-16      115.57 (  0.00%)      131.70 (-13.95%)
CoeffVar fault-huge-1        30.16 (  0.00%)       15.67 ( 48.05%)
CoeffVar fault-huge-3       113.51 (  0.00%)       88.44 ( 22.09%)
CoeffVar fault-huge-5        73.62 (  0.00%)      100.27 (-36.20%)
CoeffVar fault-huge-7        76.51 (  0.00%)       90.30 (-18.02%)
CoeffVar fault-huge-12       72.96 (  0.00%)       80.88 (-10.85%)
CoeffVar fault-huge-16       57.06 (  0.00%)       66.88 (-17.23%)
Max      fault-base-1     47334.00 (  0.00%)    49600.00 ( -4.79%)
Max      fault-base-3     65729.00 (  0.00%)    74554.00 (-13.43%)
Max      fault-base-5     64057.00 (  0.00%)    56862.00 ( 11.23%)
Max      fault-base-7     78693.00 (  0.00%)    63878.00 ( 18.83%)
Max      fault-base-12   129893.00 (  0.00%)    53485.00 ( 58.82%)
Max      fault-base-16   120831.00 (  0.00%)   155015.00 (-28.29%)
Max      fault-huge-1     12520.00 (  0.00%)     8713.00 ( 30.41%)
Max      fault-huge-3     56081.00 (  0.00%)    48753.00 ( 13.07%)
Max      fault-huge-5     37449.00 (  0.00%)    40032.00 ( -6.90%)
Max      fault-huge-7     46929.00 (  0.00%)    32946.00 ( 29.80%)
Max      fault-huge-12    73446.00 (  0.00%)    39423.00 ( 46.32%)
Max      fault-huge-16    51139.00 (  0.00%)    67562.00 (-32.11%)

The Amean lines show mostly reduction in latencies for both successful THP
faults and base page fallbacks, except for the 16-thread cases (on 4-core
machine) where the increased khugepaged activity might be usurping the CPU
time too much.

thpscale Percentage Faults Huge
                                 4.1-rc2               4.1-rc2
                                       0                     4
Percentage huge-1        78.23 (  0.00%)       71.27 ( -8.90%)
Percentage huge-3        11.41 (  0.00%)       35.23 (208.89%)
Percentage huge-5        57.72 (  0.00%)       28.99 (-49.78%)
Percentage huge-7        52.81 (  0.00%)       15.56 (-70.53%)
Percentage huge-12       22.69 (  0.00%)       51.03 (124.86%)
Percentage huge-16        7.65 (  0.00%)       12.50 ( 63.33%)

The THP success rates are too unstable to draw firm conclusions. Keep in mind
that reducing the page fault latency is likely more important than the THP
benefits, which can still be achieved for longer-running processes through
khugepaged collapses.

             4.1-rc2     4.1-rc2
                   0           4
User           15.14       14.93
System         56.75       51.12
Elapsed       199.85      196.71

                               4.1-rc2     4.1-rc2
                                     0           4
Minor Faults                   1721504     1891067
Major Faults                       315         317
Swap Ins                             0           0
Swap Outs                            0           0
Allocation stalls                 3191         691
DMA allocs                           0           0
DMA32 allocs                   7189739     7238693
Normal allocs                  2462965     2373646
Movable allocs                       0           0
Direct pages scanned            910953      619549
Kswapd pages scanned            302034      310422
Kswapd pages reclaimed           57791       89525
Direct pages reclaimed          182170       62029
Kswapd efficiency                  19%         28%
Kswapd velocity               1511.303    1578.069
Direct efficiency                  19%         10%
Direct velocity               4558.184    3149.555
Percentage direct scans            75%         66%
Zone normal velocity          1847.766    1275.426
Zone dma32 velocity           4221.721    3452.199
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate              20          11
Sector Reads                   4991812     4991228
Sector Writes                  3246508     3246912
Page rescued immediate               0           0
Slabs scanned                    62448       62080
Direct inode steals                 17          14
Kswapd inode steals                  0           0
Kswapd skipped wait                  0           0
THP fault alloc                  11385       11058
THP collapse alloc                   2         105
THP splits                        9568        9375
THP fault fallback                2937        3269
THP collapse fail                    0           1
Compaction stalls                 7551        1500
Compaction success                1611        1191
Compaction failures               5940         309
Page migrate success            569476      421021
Page migrate failure                 0           0
Compaction pages isolated      1451445      937675
Compaction migrate scanned     1416728      768084
Compaction free scanned        3800385     5859981
Compaction cost                    628         460
NUMA alloc hit                 3833019     3907129
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local               3833019     3907129
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

Note that the THP stats are not that useful as they include the preparatory
phases of the benchmark. But notice the much improved compaction success
ratio. It appears that the compaction for THP page faults is already so
crippled in order to reduce latencies, that it's mostly not worth attempting
it at all...

Next, the test was repeated with system configured to not pass GFP_WAIT for
THP page faults by:

echo never > /sys/kernel/mm/transparent_hugepage/defrag

This means no reclaim and compaction in page fault context, while khugepaged
keeps using GFP_WAIT per /sys/kernel/mm/transparent_hugepage/khugepaged/defrag


thpscale Fault Latencies
                                     4.1-rc2               4.1-rc2
                                        0-nd                  4-nd
Min      fault-base-1      1378.00 (  0.00%)     1390.00 ( -0.87%)
Min      fault-base-3      1479.00 (  0.00%)     1623.00 ( -9.74%)
Min      fault-base-5      1440.00 (  0.00%)     1415.00 (  1.74%)
Min      fault-base-7      1379.00 (  0.00%)     1434.00 ( -3.99%)
Min      fault-base-12     1946.00 (  0.00%)     2132.00 ( -9.56%)
Min      fault-base-16     1913.00 (  0.00%)     2007.00 ( -4.91%)
Min      fault-huge-1      1031.00 (  0.00%)      964.00 (  6.50%)
Min      fault-huge-3      1535.00 (  0.00%)     1037.00 ( 32.44%)
Min      fault-huge-5      1261.00 (  0.00%)     1282.00 ( -1.67%)
Min      fault-huge-7      1265.00 (  0.00%)     1464.00 (-15.73%)
Min      fault-huge-12     1275.00 (  0.00%)     1179.00 (  7.53%)
Min      fault-huge-16     1231.00 (  0.00%)     1231.00 (  0.00%)
Amean    fault-base-1      1573.16 (  0.00%)     2095.32 (-33.19%)
Amean    fault-base-3      2544.30 (  0.00%)     3256.53 (-27.99%)
Amean    fault-base-5      3412.16 (  0.00%)     3687.55 ( -8.07%)
Amean    fault-base-7      4633.68 (  0.00%)     5329.99 (-15.03%)
Amean    fault-base-12     7794.71 (  0.00%)     8441.45 ( -8.30%)
Amean    fault-base-16    13747.18 (  0.00%)    11033.65 ( 19.74%)
Amean    fault-huge-1      1279.44 (  0.00%)     1300.09 ( -1.61%)
Amean    fault-huge-3      2300.40 (  0.00%)     2267.17 (  1.44%)
Amean    fault-huge-5      1929.86 (  0.00%)     2899.17 (-50.23%)
Amean    fault-huge-7      1803.33 (  0.00%)     3549.11 (-96.81%)
Amean    fault-huge-12     2714.91 (  0.00%)     6106.21 (-124.91%)
Amean    fault-huge-16     5166.36 (  0.00%)     9565.15 (-85.14%)
Stddev   fault-base-1      1986.46 (  0.00%)     1377.20 ( 30.67%)
Stddev   fault-base-3      5293.92 (  0.00%)     5594.88 ( -5.69%)
Stddev   fault-base-5      5291.19 (  0.00%)     5583.54 ( -5.53%)
Stddev   fault-base-7      5861.45 (  0.00%)     7460.34 (-27.28%)
Stddev   fault-base-12    10754.38 (  0.00%)    11992.12 (-11.51%)
Stddev   fault-base-16    17183.11 (  0.00%)    12995.81 ( 24.37%)
Stddev   fault-huge-1        71.03 (  0.00%)       54.49 ( 23.29%)
Stddev   fault-huge-3       441.09 (  0.00%)      730.62 (-65.64%)
Stddev   fault-huge-5      3291.41 (  0.00%)     4308.06 (-30.89%)
Stddev   fault-huge-7       713.08 (  0.00%)     1226.08 (-71.94%)
Stddev   fault-huge-12     2667.32 (  0.00%)     7780.83 (-191.71%)
Stddev   fault-huge-16     4618.22 (  0.00%)     8364.24 (-81.11%)
CoeffVar fault-base-1       126.27 (  0.00%)       65.73 ( 47.95%)
CoeffVar fault-base-3       208.07 (  0.00%)      171.81 ( 17.43%)
CoeffVar fault-base-5       155.07 (  0.00%)      151.42 (  2.36%)
CoeffVar fault-base-7       126.50 (  0.00%)      139.97 (-10.65%)
CoeffVar fault-base-12      137.97 (  0.00%)      142.06 ( -2.97%)
CoeffVar fault-base-16      124.99 (  0.00%)      117.78 (  5.77%)
CoeffVar fault-huge-1         5.55 (  0.00%)        4.19 ( 24.50%)
CoeffVar fault-huge-3        19.17 (  0.00%)       32.23 (-68.07%)
CoeffVar fault-huge-5       170.55 (  0.00%)      148.60 ( 12.87%)
CoeffVar fault-huge-7        39.54 (  0.00%)       34.55 ( 12.64%)
CoeffVar fault-huge-12       98.25 (  0.00%)      127.42 (-29.70%)
CoeffVar fault-huge-16       89.39 (  0.00%)       87.44 (  2.18%)
Max      fault-base-1     56069.00 (  0.00%)    37361.00 ( 33.37%)
Max      fault-base-3     75921.00 (  0.00%)    74860.00 (  1.40%)
Max      fault-base-5     53708.00 (  0.00%)    60756.00 (-13.12%)
Max      fault-base-7     43282.00 (  0.00%)    58071.00 (-34.17%)
Max      fault-base-12    86499.00 (  0.00%)    95819.00 (-10.77%)
Max      fault-base-16   106264.00 (  0.00%)    81830.00 ( 22.99%)
Max      fault-huge-1      1387.00 (  0.00%)     1365.00 (  1.59%)
Max      fault-huge-3      2831.00 (  0.00%)     3395.00 (-19.92%)
Max      fault-huge-5     19345.00 (  0.00%)    23269.00 (-20.28%)
Max      fault-huge-7      2811.00 (  0.00%)     5935.00 (-111.13%)
Max      fault-huge-12    10869.00 (  0.00%)    36037.00 (-231.56%)
Max      fault-huge-16    13614.00 (  0.00%)    40513.00 (-197.58%)

With no reclaim/compaction from page fault context, there's nothing to improve
here. Indeed it can be only worse due to extra khugepaged activity.

thpscale Percentage Faults Huge
                                 4.1-rc2               4.1-rc2
                                    0-nd                  4-nd
Percentage huge-1         2.28 (  0.00%)        7.09 (211.11%)
Percentage huge-3         0.63 (  0.00%)        8.11 (1180.00%)
Percentage huge-5         3.67 (  0.00%)        4.56 ( 24.14%)
Percentage huge-7         0.38 (  0.00%)        1.15 (200.00%)
Percentage huge-12        1.41 (  0.00%)        3.08 (118.18%)
Percentage huge-16        1.79 (  0.00%)       10.97 (514.29%)

Khugepaged does manage to free some hugepages for page faults, but with the
maximum possible fault frequency the benchmark induces, it can't keep up
obviously.  Could be better in a more realistic scenario.

             4.1-rc2     4.1-rc2
                0-nd        4-nd
User           13.61       14.10
System         50.16       48.65
Elapsed       195.12      194.67

                               4.1-rc2     4.1-rc2
                                  0-nd        4-nd
Minor Faults                   2916846     2738269
Major Faults                       205         203
Swap Ins                             0           0
Swap Outs                            0           0
Allocation stalls                  586         329
DMA allocs                           0           0
DMA32 allocs                   6965325     7256686
Normal allocs                  2577724     2454522
Movable allocs                       0           0
Direct pages scanned            443280      263574
Kswapd pages scanned            314174      233582
Kswapd pages reclaimed          108029       60679
Direct pages reclaimed           27267       40383
Kswapd efficiency                  34%         25%
Kswapd velocity               1610.158    1199.887
Direct efficiency                   6%         15%
Direct velocity               2271.833    1353.953
Percentage direct scans            58%         53%
Zone normal velocity           925.390     757.764
Zone dma32 velocity           2956.601    1796.075
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate              13           9
Sector Reads                   4976736     4977540
Sector Writes                  3246536     3246076
Page rescued immediate               0           0
Slabs scanned                    61802       62034
Direct inode steals                  0           0
Kswapd inode steals                 16           0
Kswapd skipped wait                  0           0
THP fault alloc                   9022        9375
THP collapse alloc                   0         377
THP splits                        8939        9150
THP fault fallback                5300        4953
THP collapse fail                    0           2
Compaction stalls                    0         434
Compaction success                   0         291
Compaction failures                  0         143
Page migrate success                 0      287093
Page migrate failure                 0           1
Compaction pages isolated            0      608761
Compaction migrate scanned           0      365724
Compaction free scanned              0     3588885
Compaction cost                      0         312
NUMA alloc hit                 4932019     4727109
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local               4932019     4727109
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

Without the patchset, there's no compaction as the benchmark is too short for
the khugepaged collapses scanning to do anything. With the patchset, we wake
up khugepaged for the reclaim/compaction immediately.

To conclude, these results suggest that it's better tradeoff to keep page
faults attempt some light compaction, but the patchset reduces latencies and
improves compaction success rates by preventing these light attempts to
continue once they stop being successful. As much as I would like to see the
page faults to not use GFP_WAIT by default (i.e. echo never/madvise >
.../defrag), that test currently doesn't show much benefit, although I suspect
it's because the benchmark is too unrealistically fault-intensive as it is, so
khugepaged is doing much work and still can't keep up.

It probably also doesn't help that once khugepaged is woken up, it will try
both the THP allocations and then the scanning for collapses work, so that
scanning is done also more frequently than via the controlled sleeps. I'll
think about how to decouple that for the next version. Maybe just skip the
collapse scanning altogether when khugepaged was woken up for THP allocation,
since that is arguably higher priority.

It would be simpler if and more efficient if each node had own khugepaged just
for the THP allocation work, and scanning for collapse would be done in
task_work context. But that's for later. Thoughts?

[1] https://lwn.net/Articles/634384/
[2] https://lwn.net/Articles/636162/

Vlastimil Babka (4):
  mm, thp: stop preallocating hugepages in khugepaged
  mm, thp: khugepaged checks for THP allocability before scanning
  mm, thp: try fault allocations only if we expect them to succeed
  mm, thp: wake up khugepaged when huge page is not available

 mm/huge_memory.c | 216 +++++++++++++++++++++++++++++++------------------------
 mm/internal.h    |  36 ++++++++++
 mm/mempolicy.c   |  37 ++++++----
 mm/page_alloc.c  |   3 +
 4 files changed, 182 insertions(+), 110 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
