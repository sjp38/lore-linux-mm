Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 862DE6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 05:26:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Reduce system disruption due to kswapd followup
Date: Thu, 23 May 2013 10:26:25 +0100
Message-Id: <1369301187-24934-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Further testing of the "Reduce system disruption due to kswapd" discovered
a few problems.  First, as pages were not being swapped, the file LRU was
being scanned faster and clean file pages were being reclaimed resulting
in some cases in larger amounts of read IO to re-read data from disk.
Second, more pages were being written from kswapd context which can
adversly affect IO performance. Lastly, it was observed that PageDirty
pages are not necessarily dirty on all filesystems (buffers can be clean
while PageDirty is set and ->writepage generates no IO) and not all
filesystems set PageWriteback when the page is being written (e.g. ext3).
This disconnect confuses the reclaim stalling logic. This follow-up series
is aimed at these problems.

The tests were based on three kernels

vanilla:	kernel 3.9 as that is what the current mmotm uses as a baseline
mmotm-20130522	is mmotm as of 22nd May with "Reduce system disruption due to
		kswapd" applied on top as per what should be in Andrew's tree
		right now
lessdisrupt-v5r4 is this follow-up series on top of the mmotm kernel

The first test used memcached+memcachetest while some background IO
was in progress as implemented by the parallel IO tests implement in
MM Tests. memcachetest benchmarks how many operations/second memcached
can service. It starts with no background IO on a freshly created ext4
filesystem and then re-runs the test with larger amounts of IO in the
background to roughly simulate a large copy in progress. The expectation
is that the IO should have little or no impact on memcachetest which is
running entirely in memory.

                                             3.9.0                       3.9.0                       3.9.0
                                           vanilla          mm1-mmotm-20130522        mm1-lessdisrupt-v5r4
Ops memcachetest-0M             23117.00 (  0.00%)          23088.00 ( -0.13%)          22815.00 ( -1.31%)
Ops memcachetest-715M           23774.00 (  0.00%)          23504.00 ( -1.14%)          23342.00 ( -1.82%)
Ops memcachetest-2385M           4208.00 (  0.00%)          23740.00 (464.16%)          24138.00 (473.62%)
Ops memcachetest-4055M           4104.00 (  0.00%)          24800.00 (504.29%)          24930.00 (507.46%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)              7.00 ( 41.67%)
Ops io-duration-2385M             116.00 (  0.00%)             21.00 ( 81.90%)             21.00 ( 81.90%)
Ops io-duration-4055M             160.00 (  0.00%)             37.00 ( 76.88%)             36.00 ( 77.50%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-715M             140138.00 (  0.00%)             18.00 ( 99.99%)             18.00 ( 99.99%)
Ops swaptotal-2385M            385682.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-4055M            418029.00 (  0.00%)              0.00 (  0.00%)              2.00 (100.00%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-715M                   144.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2385M               134227.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-4055M               125618.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M            1536429.00 (  0.00%)        1533759.00 (  0.17%)        1537248.00 ( -0.05%)
Ops minorfaults-715M          1786996.00 (  0.00%)        1606613.00 ( 10.09%)        1610854.00 (  9.86%)
Ops minorfaults-2385M         1757952.00 (  0.00%)        1608201.00 (  8.52%)        1614772.00 (  8.14%)
Ops minorfaults-4055M         1774460.00 (  0.00%)        1620493.00 (  8.68%)        1625930.00 (  8.37%)
Ops majorfaults-0M                  1.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-715M              184.00 (  0.00%)            159.00 ( 13.59%)            162.00 ( 11.96%)
Ops majorfaults-2385M           24444.00 (  0.00%)            108.00 ( 99.56%)            151.00 ( 99.38%)
Ops majorfaults-4055M           21357.00 (  0.00%)            218.00 ( 98.98%)            189.00 ( 99.12%)


memcachetest is the transactions/second reported by memcachetest. In
        the vanilla kernel note that performance drops from around
        23K/sec to just over 4K/second when there is 2385M of IO going
        on in the background. With current mmotm, there is no collapse
	in performance and with this follow-up series there is little
	change.

swaptotal is the total amount of swap traffic. With mmotm and the follow-up
	series, the total amount of swapping is much reduced.

                                 3.9.0       3.9.0       3.9.0
                               vanillamm1-mmotm-20130522mm1-lessdisrupt-v5r4
Minor Faults                  11160152    10592704    10620743
Major Faults                     46305         771         788
Swap Ins                        260249           0           0
Swap Outs                       683860          18          20
Direct pages scanned                 0           0         850
Kswapd pages scanned           6046108    18523180     1598979
Kswapd pages reclaimed         1081954     1182759     1093766
Direct pages reclaimed               0           0         800
Kswapd efficiency                  17%          6%         68%
Kswapd velocity               5217.560   16027.810    1382.231
Direct efficiency                 100%        100%         94%
Direct velocity                  0.000       0.000       0.735
Percentage direct scans             0%          0%          0%
Zone normal velocity          5105.086   15217.472     636.579
Zone dma32 velocity            112.473     810.338     746.387
Zone dma velocity                0.000       0.000       0.000
Page writes by reclaim     1929612.00016620834.000   43115.000
Page writes file               1245752    16620816       43095
Page writes anon                683860          18          20
Page reclaim immediate            7484          70         147
Sector Reads                   1130320       94964       97244
Sector Writes                 13508052    11356812    11469072
Page rescued immediate               0           0           0
Slabs scanned                    33536       27648       21120
Direct inode steals                  0           0           0
Kswapd inode steals               8641        1495           0
Kswapd skipped wait                  0           0           0
THP fault alloc                      8           9          39
THP collapse alloc                 508         476         378
THP splits                          24           0           0
THP fault fallback                   0           0           0
THP collapse fail                    0           0           0

There are a number of observations to make here

1. Swap outs are almost eliminated. Swap ins are 0 indicating that the
   pages swapped were really unused anonymous pages. Related to that,
   major faults are much reduced.

2. kswapd efficiency was impacted by the initial series but with these
   follow-up patches, the efficiency is now at 66% indicating that far
   fewer pages were skipped during scanning due to dirty or writeback
   pages.

3. kswapd velocity is reduced indicating that fewer pages are being scanned
   with the follow-up series as kswapd now stalls when the tail of the
   LRU queue is full of unqueued dirty pages. The stall gives flushers a
   chance to catch-up so kswapd can reclaim clean pages when it wakes

4. In light of Zlatko's recent reports about zone scanning imbalances,
   mmtests now reports scanning velocity on a per-zone basis. With mainline,
   you can see that the scanning activity is dominated by the Normal
   zone with over 45 times more scanning in Normal than the DMA32 zone.
   With the series currently in mmotm, the ratio is slightly better but it
   is still the case that the bulk of scanning is in the highest zone. With
   this follow-up series, the ratio of scanning between the Normal and
   DMA32 zone is roughly equal.

5. As Dave Chinner observed, the current patches in mmotm increased the
   number of pages written from kswapd context which is expected to adversly
   impact IO performance. With the follow-up patches, far fewer pages are
   written from kswapd context than the mainline kernel

6. With the series in mmotm, fewer inodes were reclaimed by kswapd. With
   the follow-up series, there is less slab shrinking activity and no inodes
   were reclaimed.

7. Note that "Sectors Read" is drastically reduced implying that the source
   data being used for the IO is not being aggressively discarded due to
   page reclaim skipping over dirty pages and reclaiming clean pages. Note
   that the reducion in reads could also be due to inode data not being
   re-read from disk after a slab shrink.

Overall, the system is getting less kicked in the face due to IO.

 fs/buffer.c                 | 34 ++++++++++++++++++++++++++++++++++
 fs/ext2/inode.c             |  1 +
 fs/ext3/inode.c             |  3 +++
 fs/ext4/inode.c             |  2 ++
 fs/gfs2/aops.c              |  2 ++
 fs/ntfs/aops.c              |  1 +
 fs/ocfs2/aops.c             |  1 +
 fs/xfs/xfs_aops.c           |  1 +
 include/linux/buffer_head.h |  3 +++
 include/linux/fs.h          |  1 +
 mm/vmscan.c                 | 45 ++++++++++++++++++++++++++++++++++++++-------
 11 files changed, 87 insertions(+), 7 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
