Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 94E876B0099
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 12:36:28 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/11] Reduce compaction-related stalls and improve asynchronous migration of dirty pages v5
Date: Thu,  1 Dec 2011 17:36:10 +0000
Message-Id: <1322760981-28719-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Short summary: Stalls when a USB stick using VFAT is used are reduced
by this series. If you are experiencing this problem, please test
and report back.

Changelog since V4
o Added reviewed-bys, credited Andrea properly for sync-light
o Allow dirty pages without mappings to be considered for migration
o Bound the number of pages freed for compaction
o Isolate PageReclaim pages on their own LRU list

This is against 3.2-rc3 and follows on from discussions on "mm: Do
not stall in synchronous compaction for THP allocations" and "[RFC
PATCH 0/5] Reduce compaction-related stalls". Initially, the proposed
patch eliminated stalls due to compaction which sometimes resulted in
user-visible interactivity problems on browsers by simply never using
sync compaction. The downside was that THP success allocation rates
were lower because dirty pages were not being migrated as reported by
Andrea. His approach at fixing this was nacked on the grounds that
it reverted fixes from Rik merged that reduced the amount of pages
reclaimed as it severely impacted his workloads performance.

This series attempts to reconcile the requirements of maximising THP
usage, without stalling in a user-visible fashion due to compaction
or cheating by reclaiming an excessive number of pages.

Patch 1 partially reverts commit 39deaf85 to allow migration to isolate
	dirty pages. This is because migration can move some dirty
	pages without blocking.

Patch 2 notes that the /proc/sys/vm/compact_memory handler is not using
	synchronous compaction when it should be. This is unrelated
	to the reported stalls but is worth fixing.

Patch 3 checks if we isolated a compound page during lumpy scan and
	account for it properly. For the most part, this affects
	tracing so it's unrelated to the stalls but worth fixing.

Patch 4 notes that it is possible to abort reclaim early for compaction
	and return 0 to the page allocator potentially entering the
	"may oom" path. This has not been observed in practice but
	the rest of the series potentially makes it easier to happen.

Patch 5 adds a sync parameter to the migratepage callback and gives
	the callback responsibility for migrating the page without
	blocking if sync==false. For example, fallback_migrate_page
	will not call writepage if sync==false. This increases the
	number of pages that can be handled by asynchronous compaction
	thereby reducing stalls.

Patch 6 restores filter-awareness to isolate_lru_page for migration.
	In practice, it means that pages under writeback and pages
	without a ->migratepage callback will not be isolated
	for migration.

Patch 7 avoids calling direct reclaim if compaction is deferred but
	makes sure that compaction is only deferred if sync
	compaction was used.

Patch 8 introduces a sync-light migration mechanism that sync compaction
	uses. The objective is to allow some stalls but to not call
	->writepage which can lead to significant user-visible stalls.

Patch 9 notes that while we want to abort reclaim ASAP to allow
	compation to go ahead that we leave a very small window of
	opportunity for compaction to run. This patch allows more pages
	to be freed by reclaim but bounds the number to a reasonable
	level based on the high watermark on each zone.

Patch 10 allows slabs to be shrunk even after compaction_ready() is
	true for one zone. This is to avoid a problem whereby a single
	small zone can abort reclaim even though no pages have been
	reclaimed and no suitably large zone is in a usable state.

Patch 11 fixes a problem with the rate of page scanning. As reclaim is
	rarely stalling on pages under writeback it means that scan
	rates are very high. This is particularly true for direct
	reclaim which is not calling writepage. The vmstat figures
	implied that much of this was busy work with PageReclaim pages
	marked for immediate reclaim. This patch is a prototype that
	moves these pages to their own LRU list.

This has been tested and other than 2 USB keys getting trashed,
nothing horrible fell out.  That said, patch 11 was hacked together
pretty quickly and alternative ideas on how it could be implemented
better are welcome. I'm unhappy with the rescue logic in particular
but did not want to delay the rest of the series because of it and
wanted to include it to illustrate what it does to System CPU time.

What is of critical importance is that stalls due to compaction
are massively reduced even though sync compaction was still
allowed. Testing from people complaining about stalls copying to USBs
with THP enabled are particularly welcome.

The following tests all involve THP usage and USB keys in some
way. Each test follows this type of pattern

1. Read from some fast fast storage, be it raw device or file. Each time
   the copy finishes, start again until the test ends
2. Write a large file to a filesystem on a USB stick. Each time the copy
   finishes, start again until the test ends
3. When memory is low, start an alloc process that creates a mapping
   the size of physical memory to stress THP allocation. This is the
   "real" part of the test and the part that is meant to trigger
   stalls when THP is enabled. Copying continues in the background.
4. Record the CPU usage and time to execute of the alloc process
5. Record the number of THP allocs and fallbacks as well as the number of THP
   pages in use a the end of the test just before alloc exited
6. Run the test 5 times to get an idea of variability
7. Between each run, sync is run and caches dropped and the test
   waits until nr_dirty is a small number to avoid interference
   or caching between iterations that would skew the figures.

The individual tests were then

writebackCPDeviceBasevfat
	Disable THP, read from a raw device (sda), vfat on USB stick
writebackCPDeviceBaseext4
	Disable THP, read from a raw device (sda), ext4 on USB stick
writebackCPDevicevfat
	THP enabled, read from a raw device (sda), vfat on USB stick
writebackCPDeviceext4
	THP enabled, read from a raw device (sda), ext4 on USB stick
writebackCPFilevfat
	THP enabled, read from a file on fast storage and USB, both vfat
writebackCPFileext4
	THP enabled, read from a file on fast storage and USB, both ext4

The kernels tested were

vanilla		3.2-rc3
lessdirect	Patches 1-7
synclight	Patches 1-8
freemore	Patches 1-9
revertAbort	Patches 1-10 (The name revert is misleading in retrospect)
immediate	Patches 1-11
andrea		The 8 patches Andrea posted as a basis of comparison

The results are very long unfortunately. I'll start with the case
where we are not using THP at all

writebackCPDeviceBasevfat
                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
System Time        47.95 (    0.00%)   51.55 (   -7.50%)   48.72 (   -1.61%)   48.19 (   -0.49%)   51.82 (   -8.06%)    4.73 (   90.13%)   48.08 (   -0.26%)
+/-                 5.27 (    0.00%)    4.59 (   12.91%)    4.82 (    8.60%)    4.67 (   11.44%)    4.89 (    7.20%)    7.56 (  -43.40%)    5.73 (   -8.68%)
User Time           0.05 (    0.00%)    0.06 (  -11.11%)    0.06 (  -14.81%)    0.07 (  -22.22%)    0.08 (  -40.74%)    0.06 (  -11.11%)    0.06 (  -11.11%)
+/-                 0.01 (    0.00%)    0.02 (  -23.36%)    0.02 (  -17.95%)    0.02 (  -78.15%)    0.01 (   41.02%)    0.01 (    6.75%)    0.01 (   53.37%)
Elapsed Time       50.60 (    0.00%)   52.36 (   -3.48%)   50.68 (   -0.15%)   51.00 (   -0.79%)   53.72 (   -6.15%)   11.48 (   77.31%)   50.45 (    0.30%)
+/-                 5.53 (    0.00%)    4.57 (   17.34%)    4.47 (   19.18%)    5.03 (    9.08%)    4.80 (   13.11%)    6.59 (  -19.17%)    5.51 (    0.33%)
THP Active          0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
Fault Alloc         0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
Fault Fallback      0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        644.51    702.99    662.61    643.68    708.07     68.34    651.44
Total Elapsed Time (seconds)                408.30    414.63    415.78    419.48    438.63    209.57    426.63

                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
System Time         1.28 (    0.00%)    1.63 (  -27.19%)    1.20 (    5.94%)    1.38 (   -7.50%)    1.34 (   -4.53%)    0.91 (   29.06%)    1.50 (  -17.34%)
+/-                 0.72 (    0.00%)    0.16 (   78.24%)    0.33 (   54.54%)    0.54 (   24.48%)    0.38 (   47.33%)    0.11 (   84.30%)    0.45 (   37.83%)
User Time           0.08 (    0.00%)    0.07 (   15.00%)    0.08 (    2.50%)    0.07 (   17.50%)    0.07 (   12.50%)    0.07 (    7.50%)    0.07 (   15.00%)
+/-                 0.01 (    0.00%)    0.02 (  -21.66%)    0.01 (    6.19%)    0.02 (  -31.15%)    0.01 (   10.56%)    0.01 (   15.15%)    0.01 (   17.54%)
Elapsed Time      143.00 (    0.00%)   50.97 (   64.36%)  131.85 (    7.80%)  113.76 (   20.45%)  140.47 (    1.76%)   14.12 (   90.12%)   90.66 (   36.60%)
+/-                55.83 (    0.00%)   44.46 (   20.37%)   11.70 (   79.05%)   64.86 (  -16.16%)   18.42 (   67.02%)    5.94 (   89.36%)   66.22 (  -18.61%)
THP Active          0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
Fault Alloc         0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
Fault Fallback      0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
+/-                 0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)    0.00 (    0.00%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         23.25     25.42     21.45     22.21     20.48     15.27     26.22
Total Elapsed Time (seconds)               1219.15    775.84   1225.77   1345.05   1128.21    734.50   1119.47

The THP figures are obviously all 0 because THP was enabled. The
main thing to watch is the elapsed times and how they compare to
times when THP is enabled later. One may note that vfat completed far
faster than ext4 but you may also note that the system CPU usage for
vfat was way higher. Looking at the vmstat figures, vfat is scanning
far more aggressively so I expect what is happening is that ext4 is
getting stalled on writing back pages.

writebackCPDevicevfat
                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
System Time         2.42 (    0.00%)    4.64 (  -92.06%)   48.13 (-1890.57%)   48.06 (-1887.43%)   46.05 (-1804.47%)    4.07 (  -68.24%)   46.78 (-1834.57%)
+/-                 3.17 (    0.00%)    6.34 (  -99.91%)    4.33 (  -36.54%)    3.89 (  -22.58%)    3.21 (   -1.16%)    5.83 (  -83.70%)    9.85 ( -210.54%)
User Time           0.06 (    0.00%)    0.06 (    0.00%)    0.07 (  -13.79%)    0.06 (   -3.45%)    0.04 (   24.14%)    0.07 (  -17.24%)    0.03 (   41.38%)
+/-                 0.00 (    0.00%)    0.01 (  -87.08%)    0.02 ( -483.10%)    0.00 (    0.00%)    0.01 ( -154.95%)    0.02 ( -330.12%)    0.01 ( -100.00%)
Elapsed Time     1627.12 (    0.00%) 2187.36 (  -34.43%)   51.04 (   96.86%)   49.16 (   96.98%)   74.48 (   95.42%)   18.53 (   98.86%)  453.58 (   72.12%)
+/-                77.40 (    0.00%)  561.41 ( -625.30%)    4.57 (   94.10%)    3.75 (   95.16%)   16.18 (   79.09%)   10.44 (   86.52%)   64.07 (   17.23%)
THP Active         12.20 (    0.00%)   20.00 (  163.93%)   49.40 (  404.92%)   61.00 (  500.00%)   62.00 (  508.20%)   39.40 (  322.95%)   78.00 (  639.34%)
+/-                 7.55 (    0.00%)   15.94 (  211.17%)   23.10 (  306.03%)   37.12 (  491.79%)   42.53 (  563.52%)   31.10 (  412.12%)   47.80 (  633.40%)
Fault Alloc        28.80 (    0.00%)   44.80 (  155.56%)  142.60 (  495.14%)  140.20 (  486.81%)  161.60 (  561.11%)  181.20 (  629.17%)  329.60 ( 1144.44%)
+/-                13.17 (    0.00%)    5.46 (   41.43%)   32.38 (  245.90%)   35.37 (  268.63%)   89.29 (  678.12%)   59.04 (  448.43%)  111.90 (  849.90%)
Fault Fallback    974.40 (    0.00%)  958.60 (    1.62%)  860.40 (   11.70%)  862.80 (   11.45%)  841.60 (   13.63%)  822.00 (   15.64%)  673.80 (   30.85%)
+/-                12.94 (    0.00%)    5.35 (   58.64%)   32.38 ( -150.21%)   35.37 ( -173.33%)   88.89 ( -586.98%)   59.17 ( -357.25%)  111.96 ( -765.26%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1228.79   1683.09    656.72    644.92    731.17     56.95   1804.35
Total Elapsed Time (seconds)               8314.20  11126.44    428.74    410.35    525.44    246.16   2459.52

The first thing to note is the "Elapsed Time" for the vanilla kernels
of 1627 seconds versus 50 with THP disabled which might explain
the reports of USB stalls with THP enabled. Moving to synclight and
avoiding writeback in compaction brings THP in line with base pages
but at the cost of System CPU usage. Isolating PageReclaim pages on
their own LRU cuts the System CPU usage down.

It is very interesting to note that with the "immediate" kernel that
the completion time is better than the base page case. I do not know
exactly why that is but it may be due to batch reclaiming more pages
when THP is used.

The "Fault Alloc" success rate figures are also improved. The vanilla
kernel only managed to allocate 28.8 pages on average over the course
of 5 iterations. synclight brings that up to 142.6 while immediate
brings it up to 181.20. Of course, there is a lot of variability
which is to be expected with all the IO going on , particularly when
reading from a raw device backing a live filesystem (which is hostile
to fragmentation avoidance).

Andrea's series had a higher success rate for THP allocations but
at a severe cost to elapsed time which is still better than vanilla
but still much worse than disabling THP altogether. One can bring my
series close to Andrea's by removing this check

        /*
         * If compaction is deferred for high-order allocations, it is because
         * sync compaction recently failed. In this is the case and the caller
         * has requested the system not be heavily disrupted, fail the
         * allocation now instead of entering direct reclaim
         */
        if (deferred_compaction && (gfp_mask & __GFP_NO_KSWAPD))
                goto nopage;

If that is done the average time to complete the test increases from
18.53 seconds (immediate kernel) to 367.44 seconds but brings THP
allocation success rates close to in line with Andreas series. It
could probably be pushed higher by deferring compaction less and
combining aggressive reclaim with aggressive compaction but all at
the cost of overall performance.

I didn't include a patch that removed the above check because hurting
overall performance to improve the THP figure is not what the average
user wants. It's something to consider though if someone really wants
to maximise THP usage no matter what it does to the workload initially.

                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
MMTests Statistics: vmstat
Page Ins                                   849238418  1112644112    11522374    10078704    19644823    11465123   153979370
Page Outs                                   20589862    25868815     3455835     3406331     3673611     3981797     7824154
Swap Ins                                        3812        3481        7076        5377        5966        5691        4961
Swap Outs                                     255283      352820      624734      620676      616675      862611      700161
Direct pages scanned                      1350821305  2228775837  1547403976  1560132463  1840632272    98025275  5448209970
Kswapd pages scanned                        10182797    15963121     2364959     2114433     1560570     2164608     2036422
Kswapd pages reclaimed                       7068564    12342958     1449634     1274347      971730     1426735     1648304
Direct pages reclaimed                     210120758   271789656     1902991     1902799     4580919     1946606    38478437
Kswapd efficiency                                69%         77%         61%         60%         62%         65%         80%
Kswapd velocity                             1224.748    1434.702    5516.068    5152.755    2970.025    8793.500     827.975
Direct efficiency                                15%         12%          0%          0%          0%          1%          0%
Direct velocity                           162471.591  200313.473 3609189.663 3801955.557 3503030.359  398217.724 2215151.725
Percentage direct scans                          99%         99%         99%         99%         99%         97%         99%
Page writes by reclaim                        256842      355827      624879      620803      616744      862730      702252
Page writes file                                1559        3007         145         127          69         119        2091
Page writes anon                              255283      352820      624734      620676      616675      862611      700161
Page reclaim immediate                    1066897311  1818638577  1436791650  1448010323  1705255453    95383606  5081414834
Page rescued immediate                             0           0           0           0           0      104874           0
Slabs scanned                                   9216       10240        9216        8192        8192        8192        9216
Direct inode steals                                0           0           0           0           0           0           0
Kswapd inode steals                                0           0           0           0           0           0           0
Kswapd skipped wait                             1176         400           1           1           2          15           8
THP fault alloc                                  144         224         713         701         808         906        1648
THP collapse alloc                                 3          18           0           0           0           0           0
THP splits                                        85         132         468         396         503         713        1286
THP fault fallback                              4872        4793        4302        4314        4208        4110        3369
THP collapse fail                                 91          37           0           0           0           0           1
Compaction stalls                                417        2527         540         527         740         637        3240
Compaction success                                44         232          58          45          71         102         276
Compaction failures                              373        2295         482         482         669         535        2964
Compaction pages moved                         69404      144762      166506      183062      213251      223125      436501
Compaction move failure                         9124       11395        8757       15337       17023       20845       67949

This is summary of vmstat figures from the same test. Sorry about
the formatting. The main things to look at are

1. Page In/out figures are much reduced by the series.

2. Direct page scanning is incredibly high (162471.591 pages scanned
   per second on the vanilla kernel) but isolating PageReclaim pages
   on their own list reduces the number of pages scanned by 95% (Direct
   pages scanned line).

3. The fact that "Page rescued immediate" is a positive number implies
   that we sometimes race removing pages from the LRU_IMMEDIATE list
   that need to be put back on a normal LRU but it happens only for
   0.1% of the pages marked for immediate reclaim.

writebackCPDeviceext4
                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
System Time         1.94 (    0.00%)    2.11 (   -8.54%)    1.54 (   20.68%)    1.54 (   20.99%)    1.58 (   18.62%)    1.20 (   38.17%)    1.71 (   12.04%)
+/-                 0.55 (    0.00%)    0.29 (   47.94%)    0.42 (   24.45%)    0.36 (   35.63%)    0.30 (   45.20%)    0.21 (   61.75%)    0.22 (   60.50%)
User Time           0.06 (    0.00%)    0.04 (   35.71%)    0.06 (   -3.57%)    0.05 (   14.29%)    0.03 (   42.86%)    0.06 (  -10.71%)    0.03 (   50.00%)
+/-                 0.02 (    0.00%)    0.01 (   56.28%)    0.02 (   12.55%)    0.01 (   57.99%)    0.01 (   67.92%)    0.02 (   31.40%)    0.01 (   67.92%)
Elapsed Time       62.39 (    0.00%)   98.66 (  -58.14%)  101.12 (  -62.08%)  114.45 (  -83.45%)   94.62 (  -51.68%)   42.73 (   31.51%)  226.70 ( -263.38%)
+/-                55.11 (    0.00%)   47.33 (   14.12%)   54.36 (    1.36%)   26.80 (   51.37%)   56.09 (   -1.79%)    6.76 (   87.74%)  149.78 ( -171.80%)
THP Active         99.80 (    0.00%)   95.40 (   95.59%)   72.40 (   72.55%)  120.60 (  120.84%)  145.60 (  145.89%)   44.20 (   44.29%)   94.60 (   94.79%)
+/-                54.95 (    0.00%)   35.71 (   64.98%)   19.28 (   35.09%)   27.08 (   49.28%)   77.75 (  141.48%)   31.31 (   56.98%)   49.08 (   89.32%)
Fault Alloc       244.20 (    0.00%)  250.60 (  102.62%)  152.80 (   62.57%)  217.60 (   89.11%)  272.00 (  111.38%)  167.20 (   68.47%)  396.40 (  162.33%)
+/-                22.82 (    0.00%)   47.58 (  208.52%)   42.23 (  185.11%)   30.57 (  133.99%)  135.52 (  593.95%)  100.20 (  439.15%)  104.59 (  458.40%)
Fault Fallback    758.80 (    0.00%)  752.80 (    0.79%)  850.20 (  -12.05%)  785.80 (   -3.56%)  731.40 (    3.61%)  836.00 (  -10.17%)  606.80 (   20.03%)
+/-                22.82 (    0.00%)   47.49 ( -108.15%)   42.23 (  -85.11%)   30.80 (  -34.99%)  135.83 ( -495.31%)  100.24 ( -339.33%)  104.43 ( -357.73%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         34.47     34.29     26.27     24.76     32.13     32.67    104.88
Total Elapsed Time (seconds)                993.38   1217.66   1021.32   1030.08   1026.61    758.28   1688.14

Similar test but the USB stick is using ext4 instead of vfat. As
ext4 does not use writepage for migration, the large stalls due to
compaction when THP is enabled are not observed. Still, isolating
PageReclaim pages on their own list helped completion time largely
by reducing the number of pages scanned by direct reclaim although
time spend in congestion_wait could also be a factor.

Again, Andrea's series had far higher success rates for THP allocation
at the cost of elapsed time. I didn't look too closely but a quick
look at the vmstat figures tells me kswapd reclaimed 6 times more
pages than "immediate" and direct reclaim reclaimed roughly twice
as many pages. It follows that if memory is aggressively reclaimed,
there will be more available for THP.

writebackCPFilevfat
                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5      synclight-v5      freemore-v5   revertAbort-v5     immediate-v5         andrea-v1r1
System Time        47.67 (    0.00%)   27.95 (   41.37%)   39.35 (   17.46%)   45.70 (    4.14%)   46.49 (    2.48%)    4.91 (   89.69%)   54.42 (  -14.17%)
+/-                17.29 (    0.00%)   26.04 (  -50.62%)   19.21 (  -11.12%)    1.15 (   93.33%)    3.67 (   78.78%)    7.01 (   59.46%)   10.31 (   40.39%)
User Time           0.08 (    0.00%)    0.05 (   34.21%)    0.07 (    5.26%)    0.05 (   28.95%)    0.04 (   42.11%)    0.06 (   18.42%)    0.05 (   36.84%)
+/-                 0.02 (    0.00%)    0.01 (   31.32%)    0.01 (   28.63%)    0.01 (   50.47%)    0.01 (   27.32%)    0.01 (   35.57%)    0.01 (   35.57%)
Elapsed Time     1013.87 (    0.00%) 2009.56 (  -98.21%)   96.54 (   90.48%)   54.48 (   94.63%)   76.83 (   92.42%)   23.04 (   97.73%)  252.74 (   75.07%)
+/-              1164.19 (    0.00%) 1833.78 (  -57.52%)   82.29 (   92.93%)    5.59 (   99.52%)   27.40 (   97.65%)    7.76 (   99.33%)   45.62 (   96.08%)
THP Active          1.20 (    0.00%)   27.60 ( 2300.00%)   25.80 ( 2150.00%)   24.20 ( 2016.67%)   24.20 ( 2016.67%)   18.20 ( 1516.67%)   24.40 ( 2033.33%)
+/-                 1.94 (    0.00%)   24.63 ( 1270.20%)   33.27 ( 1715.82%)   34.65 ( 1786.89%)   28.17 ( 1452.58%)   10.07 (  519.21%)   47.31 ( 2439.61%)
Fault Alloc        42.80 (    0.00%)   87.20 (  203.74%)   71.80 (  167.76%)  147.40 (  344.39%)  110.00 (  257.01%)  123.40 (  288.32%)  152.00 (  355.14%)
+/-                23.71 (    0.00%)   37.49 (  158.11%)   23.45 (   98.89%)   50.07 (  211.18%)   35.29 (  148.83%)   55.19 (  232.77%)   76.58 (  322.97%)
Fault Fallback    960.40 (    0.00%)  916.40 (    4.58%)  931.40 (    3.02%)  855.60 (   10.91%)  893.20 (    7.00%)  879.60 (    8.41%)  851.00 (   11.39%)
+/-                23.81 (    0.00%)   37.31 (  -56.67%)   23.48 (    1.39%)   50.07 ( -110.27%)   35.23 (  -47.96%)   55.19 ( -131.76%)   76.58 ( -221.58%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2240.06    2527.8    553.11    625.51    748.34     74.92   1271.33
Total Elapsed Time (seconds)               5289.06  10250.24    689.22    483.55    605.43    342.07   1472.99

In this case, the test is reading/writing only from filesystems but as
it's vfat, it's slow due to calling writepage during compaction. Little
to observe really - the time to complete the test goes way down with
the series applied and THP allocation success rates go up.

As before, Andrea's series allocates more THPs at the cost of overall
performance. Again I did not look too closely but it paged in a lot
more and scanned a lot more pages (see system CPU time) although
the actual reclaim figures look similar. It might be getting stuck
in congestion_wait but the tests that would have confirmed that did
not get the chance to run.

writebackCPFileext4
                  thpavail-3.2.0           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3           3.2.0-rc3
                     rc3-vanilla     lessdirect-v5r8      synclight-v5r8      freemore-v5r20   revertAbort-v5r20     immediate-v5r20         andrea-v1r1
System Time         2.14 (    0.00%)    2.31 (   -8.04%)    1.78 (   16.84%)    2.38 (  -11.23%)    2.02 (    5.43%)    1.50 (   29.84%)    1.79 (   16.46%)
+/-                 0.42 (    0.00%)    0.41 (    2.49%)    0.47 (  -12.67%)    0.99 ( -136.58%)    0.34 (   19.14%)    0.34 (   19.84%)    0.27 (   35.84%)
User Time           0.06 (    0.00%)    0.04 (   35.48%)    0.05 (   19.35%)    0.05 (   19.35%)    0.06 (    9.68%)    0.04 (   35.48%)    0.05 (   22.58%)
+/-                 0.02 (    0.00%)    0.01 (   27.07%)    0.02 (   20.11%)    0.02 (   13.71%)    0.01 (   47.41%)    0.00 (    0.00%)    0.02 (   11.27%)
Elapsed Time       65.66 (    0.00%)  105.82 (  -61.16%)  110.34 (  -68.04%)   91.03 (  -38.64%)  122.48 (  -86.53%)   28.35 (   56.82%)  245.87 ( -274.45%)
+/-                52.07 (    0.00%)   50.31 (    3.37%)   75.33 (  -44.67%)   55.36 (   -6.32%)   53.90 (   -3.53%)    7.39 (   85.80%)   91.44 (  -75.63%)
THP Active         35.20 (    0.00%)  122.40 (  347.73%)   80.80 (  229.55%)   73.80 (  209.66%)  130.40 (  370.45%)   82.00 (  232.95%)   14.80 (   42.05%)
+/-                17.03 (    0.00%)   74.02 (  434.53%)   92.15 (  540.99%)   40.95 (  240.38%)   44.21 (  259.55%)   68.21 (  400.46%)   18.73 (  109.98%)
Fault Alloc        90.80 (    0.00%)  293.80 (  323.57%)  258.40 (  284.58%)  216.40 (  238.33%)  330.00 (  363.44%)  346.60 (  381.72%)  165.80 (  182.60%)
+/-                22.66 (    0.00%)   67.76 (  299.05%)  109.14 (  481.69%)  138.36 (  610.66%)   76.60 (  338.06%)  122.98 (  542.77%)  120.34 (  531.14%)
Fault Fallback    912.20 (    0.00%)  709.20 (   22.25%)  745.00 (   18.33%)  786.60 (   13.77%)  673.40 (   26.18%)  656.80 (   28.00%)  837.40 (    8.20%)
+/-                22.66 (    0.00%)   67.76 ( -199.05%)  108.89 ( -380.60%)  138.36 ( -510.66%)   76.72 ( -238.63%)  123.07 ( -443.18%)  120.51 ( -431.86%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         47.14     51.17     41.11     45.13     46.68     33.81    125.39
Total Elapsed Time (seconds)               1032.94   1203.01   1287.99   1085.57   1008.24    764.42   1939.48

This is interesting in that the Elapsed Time goes up for parts of
the series until PageReclaim pages are isolated from the LRU. This
may be because the stalls were not that bad in the first place for
ext4 which may explain why this was missed in earlier testing but was
severe once someone plugged in a USB stick with VFAT on it. What is
interesting in this test is that unlike other tests the allocation
success rate for Andrea's series was lower while Elapsed Time is
still high but am not sure why that is.

Overall the series does reduce latencies and while the tests are
inherency racy as alloc competes with the cp processes, the variability
was included. The THP allocation rates are not as high as they could
be but that is because we would have to be more aggressive about
reclaim and compaction impacting overall performance. Any comments
on what is required to get this into a suitable shape for merging
are welcome. Testing is also welcome.

 fs/btrfs/disk-io.c            |    5 +-
 fs/nfs/internal.h             |    2 +-
 fs/nfs/write.c                |    4 +-
 include/linux/fs.h            |   11 ++-
 include/linux/migrate.h       |   23 +++++-
 include/linux/mmzone.h        |    4 +
 include/linux/vm_event_item.h |    1 +
 mm/compaction.c               |    5 +-
 mm/memory-failure.c           |    2 +-
 mm/memory_hotplug.c           |    2 +-
 mm/mempolicy.c                |    2 +-
 mm/migrate.c                  |  171 ++++++++++++++++++++++++++++-------------
 mm/page_alloc.c               |   50 +++++++++---
 mm/swap.c                     |   74 +++++++++++++++++-
 mm/vmscan.c                   |  114 ++++++++++++++++++++++++----
 mm/vmstat.c                   |    2 +
 16 files changed, 369 insertions(+), 103 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
