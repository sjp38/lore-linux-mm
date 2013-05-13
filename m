Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 50D096B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 04:12:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/9] Reduce system disruption due to kswapd V4
Date: Mon, 13 May 2013 09:12:31 +0100
Message-Id: <1368432760-21573-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This series does not fix all the current known problems with reclaim but
it addresses one important swapping bug when there is background IO.

Changelog since V3
o Drop the slab shrink changes in light of Glaubers series and
  discussions highlighted that there were a number of potential
  problems with the patch.					(mel)
o Rebased to 3.10-rc1

Changelog since V2
o Preserve ratio properly for proportional scanning		(kamezawa)

Changelog since V1
o Rename ZONE_DIRTY to ZONE_TAIL_LRU_DIRTY			(andi)
o Reformat comment in shrink_page_list				(andi)
o Clarify some comments						(dhillf)
o Rework how the proportional scanning is preserved
o Add PageReclaim check before kswapd starts writeback
o Reset sc.nr_reclaimed on every full zone scan

Kswapd and page reclaim behaviour has been screwy in one way or the other
for a long time. Very broadly speaking it worked in the far past because
machines were limited in memory so it did not have that many pages to scan
and it stalled congestion_wait() frequently to prevent it going completely
nuts. In recent times it has behaved very unsatisfactorily with some of
the problems compounded by the removal of stall logic and the introduction
of transparent hugepage support with high-order reclaims.

There are many variations of bugs that are rooted in this area. One example
is reports of a large copy operations or backup causing the machine to
grind to a halt or applications pushed to swap. Sometimes in low memory
situations a large percentage of memory suddenly gets reclaimed. In other
cases an application starts and kswapd hits 100% CPU usage for prolonged
periods of time and so on. There is now talk of introducing features like
an extra free kbytes tunable to work around aspects of the problem instead
of trying to deal with it. It's compounded by the problem that it can be
very workload and machine specific.

This series aims at addressing some of the worst of these problems without
attempting to fundmentally alter how page reclaim works.

Patches 1-2 limits the number of pages kswapd reclaims while still obeying
	the anon/file proportion of the LRUs it should be scanning.

Patches 3-4 control how and when kswapd raises its scanning priority and
	deletes the scanning restart logic which is tricky to follow.

Patch 5 notes that it is too easy for kswapd to reach priority 0 when
	scanning and then reclaim the world. Down with that sort of thing.

Patch 6 notes that kswapd starts writeback based on scanning priority which
	is not necessarily related to dirty pages. It will have kswapd
	writeback pages if a number of unqueued dirty pages have been
	recently encountered at the tail of the LRU.

Patch 7 notes that sometimes kswapd should stall waiting on IO to complete
	to reduce LRU churn and the likelihood that it'll reclaim young
	clean pages or push applications to swap. It will cause kswapd
	to block on IO if it detects that pages being reclaimed under
	writeback are recycling through the LRU before the IO completes.

Patchies 8-9 are cosmetic but balance_pgdat() is easier to follow after they
	are applied.

This was tested using memcached+memcachetest while some background IO
was in progress as implemented by the parallel IO tests implement in MM
Tests. memcachetest benchmarks how many operations/second memcached can
service and it is run multiple times. It starts with no background IO and
then re-runs the test with larger amounts of IO in the background to roughly
simulate a large copy in progress.  The expectation is that the IO should
have little or no impact on memcachetest which is running entirely in memory.

                                        3.10.0-rc1                  3.10.0-rc1
                                           vanilla            lessdisrupt-v4
Ops memcachetest-0M             22155.00 (  0.00%)          22180.00 (  0.11%)
Ops memcachetest-715M           22720.00 (  0.00%)          22355.00 ( -1.61%)
Ops memcachetest-2385M           3939.00 (  0.00%)          23450.00 (495.33%)
Ops memcachetest-4055M           3628.00 (  0.00%)          24341.00 (570.92%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)
Ops io-duration-2385M             118.00 (  0.00%)             21.00 ( 82.20%)
Ops io-duration-4055M             162.00 (  0.00%)             36.00 ( 77.78%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-715M             140134.00 (  0.00%)             18.00 ( 99.99%)
Ops swaptotal-2385M            392438.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-4055M            449037.00 (  0.00%)          27864.00 ( 93.79%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-715M                     0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2385M               148031.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-4055M               135109.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M            1529984.00 (  0.00%)        1530235.00 ( -0.02%)
Ops minorfaults-715M          1794168.00 (  0.00%)        1613750.00 ( 10.06%)
Ops minorfaults-2385M         1739813.00 (  0.00%)        1609396.00 (  7.50%)
Ops minorfaults-4055M         1754460.00 (  0.00%)        1614810.00 (  7.96%)
Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-715M              185.00 (  0.00%)            180.00 (  2.70%)
Ops majorfaults-2385M           24472.00 (  0.00%)            101.00 ( 99.59%)
Ops majorfaults-4055M           22302.00 (  0.00%)            229.00 ( 98.97%)

Note how the vanilla kernels performance collapses when there is enough
IO taking place in the background. This drop in performance is part of
what users complain of when they start backups. Note how the swapin and
major fault figures indicate that processes were being pushed to swap
prematurely. With the series applied, there is no noticable performance
drop and while there is still some swap activity, it's tiny.

                            3.10.0-rc1  3.10.0-rc1
                               vanilla lessdisrupt-v4
Page Ins                       1234608      101892
Page Outs                     12446272    11810468
Swap Ins                        283406           0
Swap Outs                       698469       27882
Direct pages scanned                 0      136480
Kswapd pages scanned           6266537     5369364
Kswapd pages reclaimed         1088989      930832
Direct pages reclaimed               0      120901
Kswapd efficiency                  17%         17%
Kswapd velocity               5398.371    4635.115
Direct efficiency                 100%         88%
Direct velocity                  0.000     117.817
Percentage direct scans             0%          2%
Page writes by reclaim         1655843     4009929
Page writes file                957374     3982047
Page writes anon                698469       27882
Page reclaim immediate            5245        1745
Page rescued immediate               0           0
Slabs scanned                    33664       25216
Direct inode steals                  0           0
Kswapd inode steals              19409         778
Kswapd skipped wait                  0           0
THP fault alloc                     35          30
THP collapse alloc                 472         401
THP splits                          27          22
THP fault fallback                   0           0
THP collapse fail                    0           1
Compaction stalls                    0           4
Compaction success                   0           0
Compaction failures                  0           4
Page migrate success                 0           0
Page migrate failure                 0           0
Compaction pages isolated            0           0
Compaction migrate scanned           0           0
Compaction free scanned              0           0
Compaction cost                      0           0
NUMA PTE updates                     0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA pages migrated                  0           0
AutoNUMA cost                        0           0

Unfortunately, note that there is a small amount of direct reclaim due to
kswapd no longer reclaiming the world. ftrace indicates that the direct
reclaim stalls are mostly harmless with the vast bulk of the stalls incurred
by dd

     23 tclsh-3367
     38 memcachetest-13733
     49 memcachetest-12443
     57 tee-3368
   1541 dd-13826
   1981 dd-12539

A consequence of the direct reclaim for dd is that the processes for the
IO workload may show a higher system CPU usage. There is also a risk that
kswapd not reclaiming the world may mean that it stays awake balancing
zones, does not stall on the appropriate events and continually scans
pages it cannot reclaim consuming CPU. This will be visible as continued
high CPU usage but in my own tests I only saw a single spike lasting less
than a second and I did not observe any problems related to reclaim while
running the series on my desktop.

 include/linux/mmzone.h |  17 ++
 mm/vmscan.c            | 450 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 296 insertions(+), 171 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
