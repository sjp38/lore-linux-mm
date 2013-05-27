Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2178F6B00FB
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:03:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Reduce system disruption due to kswapd followup
Date: Mon, 27 May 2013 14:02:54 +0100
Message-Id: <1369659778-6772-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

tldr; Overall the system is getting less kicked in the face. Scan rates
	between zones is often more balanced than it used to be. There are
	now fewer writes from reclaim context and a reduction in IO wait
	times. Performance on NFS could be further improved if it used a
	new aops callback to identify unstable pages as "dirty".

Further testing of the "Reduce system disruption due to kswapd" discovered
a few problems. First and foremost, it's possible for pages under writeback
to be freed which will lead to badness. Second, as pages were not being
swapped the file LRU was being scanned faster and clean file pages were
being reclaimed. In some cases this results in increased read IO to re-read
data from disk.  Third, more pages were being written from kswapd context
which can adversly affect IO performance. Lastly, it was observed that
PageDirty pages are not necessarily dirty on all filesystems (buffers can be
clean while PageDirty is set and ->writepage generates no IO) and not all
filesystems set PageWriteback when the page is being written (e.g. ext3).
This disconnect confuses the reclaim stalling logic. This follow-up series
is aimed at these problems.

The tests were based on three kernels

vanilla:	kernel 3.9 as that is what the current mmotm uses as a baseline
mmotm-20130522	is mmotm as of 22nd May with "Reduce system disruption due to
		kswapd" applied on top as per what should be in Andrew's tree
		right now
lessdisrupt-v6r4 is this follow-up series on top of the mmotm kernel

The first test used memcached+memcachetest while some background IO
was in progress as implemented by the parallel IO tests implement in
MM Tests. memcachetest benchmarks how many operations/second memcached
can service. It starts with no background IO on a freshly created ext4
filesystem and then re-runs the test with larger amounts of IO in the
background to roughly simulate a large copy in progress. The expectation
is that the IO should have little or no impact on memcachetest which is
running entirely in memory.

parallelio
                                             3.9.0                       3.9.0                       3.9.0
                                           vanilla          mm1-mmotm-20130522        mm1-lessdisrupt-v6r4
Ops memcachetest-0M             23117.00 (  0.00%)          22780.00 ( -1.46%)          22833.00 ( -1.23%)
Ops memcachetest-715M           23774.00 (  0.00%)          23299.00 ( -2.00%)          23188.00 ( -2.46%)
Ops memcachetest-2385M           4208.00 (  0.00%)          24154.00 (474.00%)          23728.00 (463.88%)
Ops memcachetest-4055M           4104.00 (  0.00%)          25130.00 (512.33%)          24220.00 (490.16%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)              7.00 ( 41.67%)
Ops io-duration-2385M             116.00 (  0.00%)             21.00 ( 81.90%)             21.00 ( 81.90%)
Ops io-duration-4055M             160.00 (  0.00%)             36.00 ( 77.50%)             35.00 ( 78.12%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-715M             140138.00 (  0.00%)             18.00 ( 99.99%)             18.00 ( 99.99%)
Ops swaptotal-2385M            385682.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-4055M            418029.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-715M                   144.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2385M               134227.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-4055M               125618.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M            1536429.00 (  0.00%)        1531632.00 (  0.31%)        1580984.00 ( -2.90%)
Ops minorfaults-715M          1786996.00 (  0.00%)        1612148.00 (  9.78%)        1609175.00 (  9.95%)
Ops minorfaults-2385M         1757952.00 (  0.00%)        1614874.00 (  8.14%)        1612031.00 (  8.30%)
Ops minorfaults-4055M         1774460.00 (  0.00%)        1633400.00 (  7.95%)        1617945.00 (  8.82%)
Ops majorfaults-0M                  1.00 (  0.00%)              0.00 (  0.00%)             22.00 (-2100.00%)
Ops majorfaults-715M              184.00 (  0.00%)            167.00 (  9.24%)            157.00 ( 14.67%)
Ops majorfaults-2385M           24444.00 (  0.00%)            155.00 ( 99.37%)            162.00 ( 99.34%)
Ops majorfaults-4055M           21357.00 (  0.00%)            147.00 ( 99.31%)            160.00 ( 99.25%)

memcachetest is the transactions/second reported by memcachetest. In
        the vanilla kernel note that performance drops from around
        23K/sec to just over 4K/second when there is 2385M of IO going
        on in the background. With current mmotm, there is no collapse
	in performance and with this follow-up series there is little
	change.

swaptotal is the total amount of swap traffic. With mmotm and the follow-up
	series, the total amount of swapping is much reduced.

                                 3.9.0       3.9.0       3.9.0
                               vanillamm1-mmotm-20130522mm1-lessdisrupt-v6r4
Minor Faults                  11160152    10706748    10728322
Major Faults                     46305         755         787
Swap Ins                        260249           0           0
Swap Outs                       683860          18          18
Direct pages scanned                 0         678       21756
Kswapd pages scanned           6046108     8814900     1673198
Kswapd pages reclaimed         1081954     1172267     1089195
Direct pages reclaimed               0         566       19835
Kswapd efficiency                  17%         13%         65%
Kswapd velocity               5217.560    7618.953    1446.740
Direct efficiency                 100%         83%         91%
Direct velocity                  0.000       0.586      18.811
Percentage direct scans             0%          0%          1%
Zone normal velocity          5105.086    6824.681     720.905
Zone dma32 velocity            112.473     794.858     744.646
Zone dma velocity                0.000       0.000       0.000
Page writes by reclaim     1929612.000 6861768.000   25772.000
Page writes file               1245752     6861750       25754
Page writes anon                683860          18          18
Page reclaim immediate            7484          40         507
Sector Reads                   1130320       93996      102788
Sector Writes                 13508052    10823500    10792360
Page rescued immediate               0           0           0
Slabs scanned                    33536       27136       36864
Direct inode steals                  0           0           0
Kswapd inode steals               8641        1035           0
Kswapd skipped wait                  0           0           0
THP fault alloc                      8          37          38
THP collapse alloc                 508         552         559
THP splits                          24           1           0
THP fault fallback                   0           0           0
THP collapse fail                    0           0           0
Compaction stalls                    0           0           3
Compaction success                   0           0           0
Compaction failures                  0           0           3
Page migrate success                 0           0           0
Page migrate failure                 0           0           0
Compaction pages isolated            0           0           0
Compaction migrate scanned           0           0           0
Compaction free scanned              0           0           0
Compaction cost                      0           0           0
NUMA PTE updates                     0           0           0
NUMA hint faults                     0           0           0
NUMA hint local faults               0           0           0
NUMA pages migrated                  0           0           0
AutoNUMA cost                        0           0           0

There are a number of observations to make here

1. Swap outs are almost eliminated. Swap ins are 0 indicating that the
   pages swapped were really unused anonymous pages. Related to that,
   major faults are much reduced.

2. kswapd efficiency was impacted by the initial series but with these
   follow-up patches, the efficiency is now at 65% indicating that far
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

                       3.9.0       3.9.0       3.9.0
                     vanillamm1-mmotm-20130522mm1-lessdisrupt-v6r4
Mean sda-avgqz        166.99       32.09       32.39
Mean sda-await        853.64      192.76      164.65
Mean sda-r_await        6.31        9.24        7.28
Mean sda-w_await     2992.81      202.65      171.99
Max  sda-avgqz       1409.91      718.75      693.31
Max  sda-await       6665.74     3538.00     2972.46
Max  sda-r_await       58.96      111.95       84.04
Max  sda-w_await    28458.94     3977.29     3002.72

In light of the changes in writes from reclaim context, the number of
reads and Dave Chinner's concerns about IO performance I took a closer
look at the IO stats for the test disk. Few observations

1. The average queue size is reduced by the initial series and roughly
   the same with this follow up.

2. Average wait times for writes are massively reduced and as the IO
   is completing faster it at least implies that the gain is because
   flushers are writing the files efficiently instead of page reclaim
   getting in the way.

3. The reduction in average write latency is staggering. 28 seconds down
   to 3 seconds.

Jan Kara asked how NFS is affected by all of this. There is an open question
on whether the VM is treating unstable questions correctly and the answer
is "no, it's not". As unstable pages cannot be reclaimed, they should
probably be treated as dirty. An initial patch to do this exists but will
be treated as a follow-up to this series if this series gets pulled in.
Tests indicate that current behaviour is not as good as it could be but
still an improvement.

Tests like postmark, fsmark and largedd showed up nothing useful. On my test
setup, pages are simply not being written back from reclaim context with or
without the patches and there are no changes in performance. My test setup
probably is just not strong enough network-wise to be really interesting.

I ran a longer-lived memcached test with IO going to NFS instead of a local disk

                                             3.9.0                       3.9.0                       3.9.0
                                           vanilla          mm1-mmotm-20130522        mm1-lessdisrupt-v6r4
Ops memcachetest-0M             23323.00 (  0.00%)          23241.00 ( -0.35%)          23281.00 ( -0.18%)
Ops memcachetest-715M           25526.00 (  0.00%)          24763.00 ( -2.99%)          23654.00 ( -7.33%)
Ops memcachetest-2385M           8814.00 (  0.00%)          26924.00 (205.47%)          24034.00 (172.68%)
Ops memcachetest-4055M           5835.00 (  0.00%)          26827.00 (359.76%)          25293.00 (333.47%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-715M               65.00 (  0.00%)             71.00 ( -9.23%)             14.00 ( 78.46%)
Ops io-duration-2385M             129.00 (  0.00%)             94.00 ( 27.13%)             43.00 ( 66.67%)
Ops io-duration-4055M             301.00 (  0.00%)            100.00 ( 66.78%)             75.00 ( 75.08%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-715M              14394.00 (  0.00%)            949.00 ( 93.41%)           2232.00 ( 84.49%)
Ops swaptotal-2385M            401483.00 (  0.00%)          24437.00 ( 93.91%)          34772.00 ( 91.34%)
Ops swaptotal-4055M            554123.00 (  0.00%)          35688.00 ( 93.56%)          38432.00 ( 93.06%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-715M                  4522.00 (  0.00%)            560.00 ( 87.62%)             32.00 ( 99.29%)
Ops swapin-2385M               169861.00 (  0.00%)           5026.00 ( 97.04%)          11844.00 ( 93.03%)
Ops swapin-4055M               192374.00 (  0.00%)          10056.00 ( 94.77%)          13630.00 ( 92.91%)
Ops minorfaults-0M            1445969.00 (  0.00%)        1520878.00 ( -5.18%)        1526865.00 ( -5.59%)
Ops minorfaults-715M          1557288.00 (  0.00%)        1528482.00 (  1.85%)        1529207.00 (  1.80%)
Ops minorfaults-2385M         1692896.00 (  0.00%)        1570523.00 (  7.23%)        1569154.00 (  7.31%)
Ops minorfaults-4055M         1654985.00 (  0.00%)        1581456.00 (  4.44%)        1514596.00 (  8.48%)
Ops majorfaults-0M                  0.00 (  0.00%)              1.00 (-99.00%)              2.00 (-99.00%)
Ops majorfaults-715M              763.00 (  0.00%)            265.00 ( 65.27%)             85.00 ( 88.86%)
Ops majorfaults-2385M           23861.00 (  0.00%)            894.00 ( 96.25%)           2241.00 ( 90.61%)
Ops majorfaults-4055M           27210.00 (  0.00%)           1569.00 ( 94.23%)           2543.00 ( 90.65%)

1. Performance does not collapse due to IO which is good. IO is also completing
   faster. Note with mmotm, IO completes in a third of the time and faster again
   with this series applied

2. Swapping is reduced, although not eliminated.

3. There are swapins, particularly with larger amounts of IO indicating
   that active pages are being reclaimed. However, the number of much
   reduced.

So the series helps even on NFS where the VM is not accounting for stable
pages but it's still an improvement. I'm not going through the vmstat figures
in detail but IO from reclaim context is a tenth of what it is in 3.9 with
balanced scanning between the zones.

                       3.9.0       3.9.0       3.9.0
                     vanillamm1-mmotm-20130522mm1-lessdisrupt-v6r4
Mean sda-avgqz         23.58        0.35        0.56
Mean sda-await        133.47       15.72       17.06
Mean sda-r_await        4.72        4.69        5.49
Mean sda-w_await      507.69       28.40       35.07
Max  sda-avgqz        680.60       12.25       71.45
Max  sda-await       3958.89      221.83      379.46
Max  sda-r_await       63.86       61.23       88.58
Max  sda-w_await    11710.38      883.57     1858.22

And as before, wait times are much reduced.

 fs/block_dev.c              |  1 +
 fs/buffer.c                 | 34 ++++++++++++++++++
 fs/ext3/inode.c             |  1 +
 include/linux/buffer_head.h |  3 ++
 include/linux/fs.h          |  1 +
 mm/vmscan.c                 | 86 +++++++++++++++++++++++++++++++++++----------
 6 files changed, 108 insertions(+), 18 deletions(-)

-- 
1.8.1.4

Mel Gorman (4):
  mm: vmscan: Block kswapd if it is encountering pages under writeback
    -fix
  mm: vmscan: Stall page reclaim and writeback pages based on
    dirty/writepage pages encountered
  mm: vmscan: Stall page reclaim after a list of pages have been
    processed
  mm: vmscan: Take page buffers dirty and locked state into account

 fs/block_dev.c              |  1 +
 fs/buffer.c                 | 34 +++++++++++++++++
 fs/ext3/inode.c             |  1 +
 include/linux/buffer_head.h |  3 ++
 include/linux/fs.h          |  1 +
 mm/vmscan.c                 | 89 +++++++++++++++++++++++++++++++++++----------
 6 files changed, 110 insertions(+), 19 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
