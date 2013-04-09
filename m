Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 249B36B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/10] Reduce system disruption due to kswapd V2
Date: Tue,  9 Apr 2013 12:06:55 +0100
Message-Id: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Posting V2 of this series got delayed due to trying to pin down an unrelated
regression in 3.9-rc where interactive performance is shot to hell. That
problem still has not been identified as it's resisting attempts to be
reproducible by a script for the purposes of bisection.

For those that looked at V1, the most important difference in this version
is how patch 2 preserves the proportional scanning of anon/file LRUs.

The series is against 3.9-rc6.

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

Patch 8 shrinks slab just once per priority scanned or if a zone is otherwise
	unreclaimable to avoid hammering slab when kswapd has to skip a
	large number of pages.

Patches 9-10 are cosmetic but balance_pgdat() might be easier to follow.

This was tested using memcached+memcachetest while some background IO
was in progress as implemented by the parallel IO tests implement in MM
Tests. memcachetest benchmarks how many operations/second memcached can
service and it is run multiple times. It starts with no background IO and
then re-runs the test with larger amounts of IO in the background to roughly
simulate a large copy in progress.  The expectation is that the IO should
have little or no impact on memcachetest which is running entirely in memory.

                                         3.9.0-rc6                   3.9.0-rc6
                                           vanilla           lessdisrupt-v2r11
Ops memcachetest-0M             11106.00 (  0.00%)          10997.00 ( -0.98%)
Ops memcachetest-749M           10960.00 (  0.00%)          11032.00 (  0.66%)
Ops memcachetest-2498M           2588.00 (  0.00%)          10948.00 (323.03%)
Ops memcachetest-4246M           2401.00 (  0.00%)          10960.00 (356.48%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-749M               15.00 (  0.00%)              8.00 ( 46.67%)
Ops io-duration-2498M             112.00 (  0.00%)             25.00 ( 77.68%)
Ops io-duration-4246M             170.00 (  0.00%)             45.00 ( 73.53%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-749M             161678.00 (  0.00%)             16.00 ( 99.99%)
Ops swaptotal-2498M            471903.00 (  0.00%)            192.00 ( 99.96%)
Ops swaptotal-4246M            444010.00 (  0.00%)           1323.00 ( 99.70%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-749M                   789.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2498M               196496.00 (  0.00%)            192.00 ( 99.90%)
Ops swapin-4246M               168269.00 (  0.00%)            154.00 ( 99.91%)
Ops minorfaults-0M            1596126.00 (  0.00%)        1521332.00 (  4.69%)
Ops minorfaults-749M          1766556.00 (  0.00%)        1596350.00 (  9.63%)
Ops minorfaults-2498M         1661445.00 (  0.00%)        1598762.00 (  3.77%)
Ops minorfaults-4246M         1628375.00 (  0.00%)        1597624.00 (  1.89%)
Ops majorfaults-0M                  9.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-749M              154.00 (  0.00%)            101.00 ( 34.42%)
Ops majorfaults-2498M           27214.00 (  0.00%)            165.00 ( 99.39%)
Ops majorfaults-4246M           23229.00 (  0.00%)            114.00 ( 99.51%)

Note how the vanilla kernels performance collapses when there is enough IO
taking place in the background. This drop in performance is part of users
complain of when they start backups. Note how the swapin and major fault
figures indicate that processes were being pushed to swap prematurely. With
the series applied, there is no noticable performance drop and while there
is still some swap activity, it's tiny.

                             3.9.0-rc6   3.9.0-rc6
                               vanilla lessdisrupt-v2r11
Page Ins                       9094288      346092
Page Outs                     62897388    47599884
Swap Ins                       2243749       19389
Swap Outs                      3953966      142258
Direct pages scanned                 0     2262897
Kswapd pages scanned          55530838    75725437
Kswapd pages reclaimed         6682620     1814689
Direct pages reclaimed               0     2187167
Kswapd efficiency                  12%          2%
Kswapd velocity              10537.501   14377.501
Direct efficiency                 100%         96%
Direct velocity                  0.000     429.642
Percentage direct scans             0%          2%
Page writes by reclaim        10835163    72419297
Page writes file               6881197    72277039
Page writes anon               3953966      142258
Page reclaim immediate           11463        8199
Page rescued immediate               0           0
Slabs scanned                    38144       30592
Direct inode steals                  0           0
Kswapd inode steals              11383         791
Kswapd skipped wait                  0           0
THP fault alloc                     10         111
THP collapse alloc                2782        1779
THP splits                          10          27
THP fault fallback                   0           5
THP collapse fail                    0          21
Compaction stalls                    0          89
Compaction success                   0          53
Compaction failures                  0          36
Page migrate success                 0       37062
Page migrate failure                 0           0
Compaction pages isolated            0       83481
Compaction migrate scanned           0       80830
Compaction free scanned              0     2660824
Compaction cost                      0          40
NUMA PTE updates                     0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA pages migrated                  0           0
AutoNUMA cost                        0           0

Note that while there is no noticeable performance drop and swap activity is
massively reduced there are processes that direct reclaim as a consequence
of the series due to kswapd not reclaiming the world. ftrace was not enabled
for this particular test to avoid disruption but on a similar test with
ftrace I found that the vast bulk of the direct reclaims were in the dd
processes. The top direct reclaimers were;

     11 ps-13204
     12 top-13198
     15 memcachetest-11712
     20 gzip-3126
     67 tclsh-3124
     80 memcachetest-12924
    191 flush-8:0-292
    338 tee-3125
   2184 dd-12135
  10751 dd-13124

While processes did stall, it was mostly the "correct" processes that
stalled.

There is also still a risk that kswapd not reclaiming the world may mean
that it stays awake balancing zones, does not stall on the appropriate
events and continually scans pages it cannot reclaim consuming CPU. This
will be visible as continued high CPU usage but in my own tests I only
saw a single spike lasting less than a second and I did not observe any
problems related to reclaim while running the series on my desktop.

 include/linux/mmzone.h |  17 ++
 mm/vmscan.c            | 449 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 293 insertions(+), 173 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
