Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A70F6B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:51:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r5so1398823wmr.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:51:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tp14si28627089wjb.162.2016.06.06.12.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:51:01 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 00/10] mm: balance LRU lists based on relative thrashing
Date: Mon,  6 Jun 2016 15:48:26 -0400
Message-Id: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

Hi everybody,

this series re-implements the LRU balancing between page cache and
anonymous pages to work better with fast random IO swap devices.

The LRU balancing code evolved under slow rotational disks with high
seek overhead, and it had to extrapolate the cost of reclaiming a list
based on in-memory reference patterns alone, which is error prone and,
in combination with the high IO cost of mistakes, risky. As a result,
the balancing code is now at a point where it mostly goes for page
cache and avoids the random IO of swapping altogether until the VM is
under significant memory pressure.

With the proliferation of fast random IO devices such as SSDs and
persistent memory, though, swap becomes interesting again, not just as
a last-resort overflow, but as an extension of memory that can be used
to optimize the in-memory balance between the page cache and the
anonymous workingset even during moderate load. Our current reclaim
choices don't exploit the potential of this hardware. This series sets
out to address this.

Having exact tracking of refault IO - the ultimate cost of reclaiming
the wrong pages - allows us to use an IO cost based balancing model
that is more aggressive about swapping on fast backing devices while
holding back on existing setups that still use rotational storage.

These patches base the LRU balancing on the rate of refaults on each
list, times the relative IO cost between swap device and filesystem
(swappiness), in order to optimize reclaim for least IO cost incurred.

---

The following postgres benchmark demonstrates the benefits of this new
model. The machine has 7G, the database is 5.6G with 1G for shared
buffers, and the system has a little over 1G worth of anonymous pages
from mostly idle processes and tmpfs files. The filesystem is on
spinning rust, the swap partition is on an SSD; swappiness is set to
115 to ballpark the relative IO cost between them. The test run is
preceded by 30 minutes of warmup using the same workload:

transaction type: TPC-B (sort of)
scaling factor: 420
query mode: simple
number of clients: 8
number of threads: 4
duration: 3600 s

vanilla:
number of transactions actually processed: 290360
latency average: 99.187 ms
latency stddev: 261.171 ms
tps = 80.654848 (including connections establishing)
tps = 80.654878 (excluding connections establishing)

patched:
number of transactions actually processed: 377960
latency average: 76.198 ms
latency stddev: 229.411 ms
tps = 104.987704 (including connections establishing)
tps = 104.987743 (excluding connections establishing)

The patched kernel shows a 30% increase in throughput, and a 23%
decrease in average latency. Latency variance is reduced as well.

The reclaim statistics explain the difference in behavior:

                         PGBENCH5.6G-vanilla      PGBENCH5.6G-lrucost
Real time                 3600.49 (  +0.00%)      3600.26 (   -0.01%)
User time                   17.85 (  +0.00%)        18.80 (   +5.05%)
System time                 17.52 (  +0.00%)        17.02 (   -2.72%)
Allocation stalls            3.00 (  +0.00%)         0.00 (  -75.00%)
Anon scanned              6579.00 (  +0.00%)    201845.00 (+2967.57%)
Anon reclaimed            3426.00 (  +0.00%)     86924.00 (+2436.48%)
Anon reclaim efficiency     52.07 (  +0.00%)        43.06 (  -16.98%)
File scanned            364444.00 (  +0.00%)     27706.00 (  -92.40%)
File reclaimed          363136.00 (  +0.00%)     27366.00 (  -92.46%)
File reclaim efficiency     99.64 (  +0.00%)        98.77 (   -0.86%)
Swap out                  3149.00 (  +0.00%)     86932.00 (+2659.78%)
Swap in                    313.00 (  +0.00%)       503.00 (  +60.51%)
File refault            222486.00 (  +0.00%)    101041.00 (  -54.59%)
Total refaults          222799.00 (  +0.00%)    101544.00 (  -54.42%)

The patched kernel works much harder to find idle anonymous pages in
order to alleviate the thrashing of the page cache. And it pays off:
overall, refault IO is cut in half, more time is spent in userspace,
less time is spent in the kernel.

---

The parallelio test from the mmtests package shows the backward
compatibility of the new model. It runs a memcache workload while
copying large files in parallel. The page cache isn't thrashing, so
the VM shouldn't swap except to relieve immediate memory pressure.
Swappiness is reset to the default setting of 60 as well.

parallelio Transactions
                                                vanilla                     lrucost
                                                     60                          60
Min      memcachetest-0M             83736.00 (  0.00%)          84376.00 (  0.76%)
Min      memcachetest-769M           83708.00 (  0.00%)          85038.00 (  1.59%)
Min      memcachetest-2565M          85419.00 (  0.00%)          85740.00 (  0.38%)
Min      memcachetest-4361M          85979.00 (  0.00%)          86746.00 (  0.89%)
Hmean    memcachetest-0M             84805.85 (  0.00%)          84852.31 (  0.05%)
Hmean    memcachetest-769M           84273.56 (  0.00%)          85160.52 (  1.05%)
Hmean    memcachetest-2565M          85792.43 (  0.00%)          85967.59 (  0.20%)
Hmean    memcachetest-4361M          86212.90 (  0.00%)          86891.87 (  0.79%)
Stddev   memcachetest-0M               959.16 (  0.00%)            339.07 ( 64.65%)
Stddev   memcachetest-769M             421.00 (  0.00%)            110.07 ( 73.85%)
Stddev   memcachetest-2565M            277.86 (  0.00%)            252.33 (  9.19%)
Stddev   memcachetest-4361M            193.55 (  0.00%)            106.30 ( 45.08%)
CoeffVar memcachetest-0M                 1.13 (  0.00%)              0.40 ( 64.66%)
CoeffVar memcachetest-769M               0.50 (  0.00%)              0.13 ( 74.13%)
CoeffVar memcachetest-2565M              0.32 (  0.00%)              0.29 (  9.37%)
CoeffVar memcachetest-4361M              0.22 (  0.00%)              0.12 ( 45.51%)
Max      memcachetest-0M             86067.00 (  0.00%)          85129.00 ( -1.09%)
Max      memcachetest-769M           84715.00 (  0.00%)          85305.00 (  0.70%)
Max      memcachetest-2565M          86084.00 (  0.00%)          86320.00 (  0.27%)
Max      memcachetest-4361M          86453.00 (  0.00%)          86996.00 (  0.63%)

parallelio Background IO
                                               vanilla                     lrucost
                                                    60                          60
Min      io-duration-0M                 0.00 (  0.00%)              0.00 (  0.00%)
Min      io-duration-769M               6.00 (  0.00%)              6.00 (  0.00%)
Min      io-duration-2565M             21.00 (  0.00%)             21.00 (  0.00%)
Min      io-duration-4361M             36.00 (  0.00%)             37.00 ( -2.78%)
Amean    io-duration-0M                 0.00 (  0.00%)              0.00 (  0.00%)
Amean    io-duration-769M               6.67 (  0.00%)              6.67 (  0.00%)
Amean    io-duration-2565M             21.67 (  0.00%)             21.67 (  0.00%)
Amean    io-duration-4361M             36.33 (  0.00%)             37.00 ( -1.83%)
Stddev   io-duration-0M                 0.00 (  0.00%)              0.00 (  0.00%)
Stddev   io-duration-769M               0.47 (  0.00%)              0.47 (  0.00%)
Stddev   io-duration-2565M              0.47 (  0.00%)              0.47 (  0.00%)
Stddev   io-duration-4361M              0.47 (  0.00%)              0.00 (100.00%)
CoeffVar io-duration-0M                 0.00 (  0.00%)              0.00 (  0.00%)
CoeffVar io-duration-769M               7.07 (  0.00%)              7.07 (  0.00%)
CoeffVar io-duration-2565M              2.18 (  0.00%)              2.18 (  0.00%)
CoeffVar io-duration-4361M              1.30 (  0.00%)              0.00 (100.00%)
Max      io-duration-0M                 0.00 (  0.00%)              0.00 (  0.00%)
Max      io-duration-769M               7.00 (  0.00%)              7.00 (  0.00%)
Max      io-duration-2565M             22.00 (  0.00%)             22.00 (  0.00%)
Max      io-duration-4361M             37.00 (  0.00%)             37.00 (  0.00%)

parallelio Swap totals
                                               vanilla                     lrucost
                                                    60                          60
Min      swapin-0M                 244169.00 (  0.00%)         281418.00 (-15.26%)
Min      swapin-769M               269973.00 (  0.00%)         231669.00 ( 14.19%)
Min      swapin-2565M              204356.00 (  0.00%)         188934.00 (  7.55%)
Min      swapin-4361M              178044.00 (  0.00%)         147799.00 ( 16.99%)
Min      swaptotal-0M              810441.00 (  0.00%)         832580.00 ( -2.73%)
Min      swaptotal-769M            827282.00 (  0.00%)         705879.00 ( 14.67%)
Min      swaptotal-2565M           690422.00 (  0.00%)         656948.00 (  4.85%)
Min      swaptotal-4361M           660507.00 (  0.00%)         582026.00 ( 11.88%)
Min      minorfaults-0M           2677904.00 (  0.00%)        2706086.00 ( -1.05%)
Min      minorfaults-769M         2731412.00 (  0.00%)        2606587.00 (  4.57%)
Min      minorfaults-2565M        2599647.00 (  0.00%)        2572429.00 (  1.05%)
Min      minorfaults-4361M        2573117.00 (  0.00%)        2514047.00 (  2.30%)
Min      majorfaults-0M             82864.00 (  0.00%)          98005.00 (-18.27%)
Min      majorfaults-769M           95047.00 (  0.00%)          78789.00 ( 17.11%)
Min      majorfaults-2565M          69486.00 (  0.00%)          65934.00 (  5.11%)
Min      majorfaults-4361M          60009.00 (  0.00%)          50955.00 ( 15.09%)
Amean    swapin-0M                 291429.67 (  0.00%)         290184.67 (  0.43%)
Amean    swapin-769M               294641.33 (  0.00%)         247553.33 ( 15.98%)
Amean    swapin-2565M              224398.67 (  0.00%)         199541.33 ( 11.08%)
Amean    swapin-4361M              188710.67 (  0.00%)         155103.67 ( 17.81%)
Amean    swaptotal-0M              877847.33 (  0.00%)         842476.33 (  4.03%)
Amean    swaptotal-769M            860593.67 (  0.00%)         765749.00 ( 11.02%)
Amean    swaptotal-2565M           724284.33 (  0.00%)         674759.67 (  6.84%)
Amean    swaptotal-4361M           669080.67 (  0.00%)         594949.33 ( 11.08%)
Amean    minorfaults-0M           2743339.00 (  0.00%)        2707815.33 (  1.29%)
Amean    minorfaults-769M         2740174.33 (  0.00%)        2656168.33 (  3.07%)
Amean    minorfaults-2565M        2624234.00 (  0.00%)        2579847.00 (  1.69%)
Amean    minorfaults-4361M        2582434.67 (  0.00%)        2525946.33 (  2.19%)
Amean    majorfaults-0M             99845.67 (  0.00%)         101007.33 ( -1.16%)
Amean    majorfaults-769M          101037.67 (  0.00%)          87706.00 ( 13.19%)
Amean    majorfaults-2565M          74771.67 (  0.00%)          68243.67 (  8.73%)
Amean    majorfaults-4361M          62557.33 (  0.00%)          52668.33 ( 15.81%)
Stddev   swapin-0M                  33554.61 (  0.00%)           6370.43 ( 81.01%)
Stddev   swapin-769M                18283.19 (  0.00%)          11586.05 ( 36.63%)
Stddev   swapin-2565M               14314.16 (  0.00%)           9023.96 ( 36.96%)
Stddev   swapin-4361M               11000.92 (  0.00%)           6770.47 ( 38.46%)
Stddev   swaptotal-0M               47680.16 (  0.00%)           8319.84 ( 82.55%)
Stddev   swaptotal-769M             23632.76 (  0.00%)          42426.42 (-79.52%)
Stddev   swaptotal-2565M            24761.63 (  0.00%)          14504.40 ( 41.42%)
Stddev   swaptotal-4361M             8173.20 (  0.00%)           9177.32 (-12.29%)
Stddev   minorfaults-0M             49578.82 (  0.00%)           1928.88 ( 96.11%)
Stddev   minorfaults-769M            7305.53 (  0.00%)          35084.61 (-380.25%)
Stddev   minorfaults-2565M          17393.80 (  0.00%)           5259.94 ( 69.76%)
Stddev   minorfaults-4361M           7780.48 (  0.00%)          10048.60 (-29.15%)
Stddev   majorfaults-0M             12102.64 (  0.00%)           2178.49 ( 82.00%)
Stddev   majorfaults-769M            4839.82 (  0.00%)           6313.49 (-30.45%)
Stddev   majorfaults-2565M           3748.79 (  0.00%)           2707.31 ( 27.78%)
Stddev   majorfaults-4361M           3292.87 (  0.00%)           1466.92 ( 55.45%)
CoeffVar swapin-0M                     11.51 (  0.00%)              2.20 ( 80.93%)
CoeffVar swapin-769M                    6.21 (  0.00%)              4.68 ( 24.58%)
CoeffVar swapin-2565M                   6.38 (  0.00%)              4.52 ( 29.10%)
CoeffVar swapin-4361M                   5.83 (  0.00%)              4.37 ( 25.12%)
CoeffVar swaptotal-0M                   5.43 (  0.00%)              0.99 ( 81.82%)
CoeffVar swaptotal-769M                 2.75 (  0.00%)              5.54 (-101.76%)
CoeffVar swaptotal-2565M                3.42 (  0.00%)              2.15 ( 37.12%)
CoeffVar swaptotal-4361M                1.22 (  0.00%)              1.54 (-26.28%)
CoeffVar minorfaults-0M                 1.81 (  0.00%)              0.07 ( 96.06%)
CoeffVar minorfaults-769M               0.27 (  0.00%)              1.32 (-395.44%)
CoeffVar minorfaults-2565M              0.66 (  0.00%)              0.20 ( 69.24%)
CoeffVar minorfaults-4361M              0.30 (  0.00%)              0.40 (-32.04%)
CoeffVar majorfaults-0M                12.12 (  0.00%)              2.16 ( 82.21%)
CoeffVar majorfaults-769M               4.79 (  0.00%)              7.20 (-50.28%)
CoeffVar majorfaults-2565M              5.01 (  0.00%)              3.97 ( 20.87%)
CoeffVar majorfaults-4361M              5.26 (  0.00%)              2.79 ( 47.09%)
Max      swapin-0M                 318760.00 (  0.00%)         296366.00 (  7.03%)
Max      swapin-769M               313685.00 (  0.00%)         258977.00 ( 17.44%)
Max      swapin-2565M              236882.00 (  0.00%)         210990.00 ( 10.93%)
Max      swapin-4361M              203852.00 (  0.00%)         164117.00 ( 19.49%)
Max      swaptotal-0M              913095.00 (  0.00%)         852936.00 (  6.59%)
Max      swaptotal-769M            879597.00 (  0.00%)         799103.00 (  9.15%)
Max      swaptotal-2565M           748943.00 (  0.00%)         692476.00 (  7.54%)
Max      swaptotal-4361M           680081.00 (  0.00%)         602448.00 ( 11.42%)
Max      minorfaults-0M           2797869.00 (  0.00%)        2710507.00 (  3.12%)
Max      minorfaults-769M         2749296.00 (  0.00%)        2682591.00 (  2.43%)
Max      minorfaults-2565M        2637180.00 (  0.00%)        2584036.00 (  2.02%)
Max      minorfaults-4361M        2592162.00 (  0.00%)        2538624.00 (  2.07%)
Max      majorfaults-0M            110188.00 (  0.00%)         103107.00 (  6.43%)
Max      majorfaults-769M          106900.00 (  0.00%)          92559.00 ( 13.42%)
Max      majorfaults-2565M          77770.00 (  0.00%)          72043.00 (  7.36%)
Max      majorfaults-4361M          67207.00 (  0.00%)          54538.00 ( 18.85%)

             vanilla     lrucost
                  60          60
User         1108.24     1122.37
System       4636.57     4650.63
Elapsed      6046.97     6047.82

                               vanilla     lrucost
                                    60          60
Minor Faults                  34022711    33360104
Major Faults                   1014895      929273
Swap Ins                       2997968     2677588
Swap Outs                      6397877     5956707
Allocation stalls                   27          31
DMA allocs                           0           0
DMA32 allocs                  15080196    14356136
Normal allocs                 26177871    26662120
Movable allocs                       0           0
Direct pages scanned             31625       27194
Kswapd pages scanned          33103442    27727713
Kswapd pages reclaimed        11817394    11598677
Direct pages reclaimed           21146       24043
Kswapd efficiency                  35%         41%
Kswapd velocity               5474.385    4584.745
Direct efficiency                  66%         88%
Direct velocity                  5.230       4.496
Percentage direct scans             0%          0%
Zone normal velocity          3786.073    3908.266
Zone dma32 velocity           1693.542     680.975
Zone dma velocity                0.000       0.000
Page writes by reclaim     6398557.000 5962129.000
Page writes file                   680        5422
Page writes anon               6397877     5956707
Page reclaim immediate            3750       12647
Sector Reads                  12608512    11624860
Sector Writes                 49304260    47539216
Page rescued immediate               0           0
Slabs scanned                   148322      164263
Direct inode steals                  0           0
Kswapd inode steals                  0          22
Kswapd skipped wait                  0           0
THP fault alloc                      6           3
THP collapse alloc                3490        3567
THP splits                           0           0
THP fault fallback                   0           0
THP collapse fail                   13          17
Compaction stalls                  431         446
Compaction success                 405         416
Compaction failures                 26          30
Page migrate success            199708      211181
Page migrate failure                71         121
Compaction pages isolated       425244      452352
Compaction migrate scanned      209471      226018
Compaction free scanned       20950979    23257076
Compaction cost                    216         229
NUMA alloc hit                38459351    38177612
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local              38455861    38174045
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

Both the memcache transactions and the background IO throughput are
unchanged.

Overall reclaim activity actually went down in the patched kernel,
since the VM is now deterred by the swapins, whereas previously a
successful swapout followed by a swapin would actually make the anon
LRU more attractive (swapout is a scanned but not rotated page; swapin
puts pages on the inactive list, which used to be a scan event too).

The changes are fairly straight-forward, but they do require a page
flag to tell inactive cache refaults (cache transition) from active
ones (existing cache needs more space). On x86-32 PAE, that bumps us
to 22 core flags + 7 section bits on x86 PAE + 2 zone bits = 31 bits.
With the configurable hwpoison flag 32, and thus the last page flag.
However, this is core VM functionality, and we can make new features
64-bit-only, like we did with the page idle tracking.

Thanks

 Documentation/sysctl/vm.txt    |  16 +++--
 fs/cifs/file.c                 |  10 +--
 fs/fuse/dev.c                  |   2 +-
 include/linux/mmzone.h         |  29 ++++----
 include/linux/page-flags.h     |   2 +
 include/linux/pagevec.h        |   2 +-
 include/linux/swap.h           |  11 ++-
 include/trace/events/mmflags.h |   1 +
 kernel/sysctl.c                |   3 +-
 mm/filemap.c                   |   9 +--
 mm/migrate.c                   |   4 ++
 mm/mlock.c                     |   2 +-
 mm/shmem.c                     |   4 +-
 mm/swap.c                      | 124 +++++++++++++++++++---------------
 mm/swap_state.c                |   3 +-
 mm/vmscan.c                    |  48 ++++++-------
 mm/vmstat.c                    |   6 +-
 mm/workingset.c                | 142 +++++++++++++++++++++++++++++----------
 18 files changed, 258 insertions(+), 160 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
