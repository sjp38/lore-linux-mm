Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 9497C6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 09:04:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Date: Sun, 17 Mar 2013 13:04:06 +0000
Message-Id: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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

This RFC is aimed at investigating if kswapd can be address these various
problems in a relatively straight-forward fashion without a fundamental
rewrite.

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

Ordinarily this test is run a number of times for each amount of IO and
the worse result reported but these results are based on just one run as
a quick test. ftrace was also running so there was additional sources of
interference and the results would be more varaiable than normal. More
comprehensive tests are be queued but they'll take quite some time to
complete. Kernel baseline is v3.9-rc2 and the following kernels were tested

vanilla			3.9-rc2
flatten-v1r8		Patches 1-4
limitprio-v1r8		Patches 1-5
write-v1r8		Patches 1-6
block-v1r8		Patches 1-7
tidy-v1r8		Patches 1-10

                                         3.9.0-rc2                   3.9.0-rc2                   3.9.0-rc2                   3.9.0-rc2                   3.9.0-rc2
                                           vanilla                flatten-v1r8              limitprio-v1r8                  block-v1r8                   tidy-v1r8
Ops memcachetest-0M             10932.00 (  0.00%)          10898.00 ( -0.31%)          10903.00 ( -0.27%)          10911.00 ( -0.19%)          10916.00 ( -0.15%)
Ops memcachetest-749M            7816.00 (  0.00%)          10715.00 ( 37.09%)          11006.00 ( 40.81%)          10903.00 ( 39.50%)          10856.00 ( 38.89%)
Ops memcachetest-2498M           3974.00 (  0.00%)           3190.00 (-19.73%)          11623.00 (192.48%)          11142.00 (180.37%)          10930.00 (175.04%)
Ops memcachetest-4246M           2355.00 (  0.00%)           2915.00 ( 23.78%)          12619.00 (435.84%)          11212.00 (376.09%)          10904.00 (363.01%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-749M               31.00 (  0.00%)             16.00 ( 48.39%)              9.00 ( 70.97%)              9.00 ( 70.97%)              8.00 ( 74.19%)
Ops io-duration-2498M              89.00 (  0.00%)            111.00 (-24.72%)             27.00 ( 69.66%)             28.00 ( 68.54%)             27.00 ( 69.66%)
Ops io-duration-4246M             182.00 (  0.00%)            165.00 (  9.34%)             49.00 ( 73.08%)             46.00 ( 74.73%)             45.00 ( 75.27%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-749M             219394.00 (  0.00%)         162045.00 ( 26.14%)              0.00 (  0.00%)              0.00 (  0.00%)             16.00 ( 99.99%)
Ops swaptotal-2498M            312904.00 (  0.00%)         389809.00 (-24.58%)            334.00 ( 99.89%)           1233.00 ( 99.61%)              8.00 (100.00%)
Ops swaptotal-4246M            471517.00 (  0.00%)         395170.00 ( 16.19%)              0.00 (  0.00%)           1117.00 ( 99.76%)             29.00 ( 99.99%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-749M                 62057.00 (  0.00%)           5954.00 ( 90.41%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2498M               143617.00 (  0.00%)         154592.00 ( -7.64%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-4246M               160417.00 (  0.00%)         125904.00 ( 21.51%)              0.00 (  0.00%)             13.00 ( 99.99%)              0.00 (  0.00%)
Ops minorfaults-0M            1683549.00 (  0.00%)        1685771.00 ( -0.13%)        1675398.00 (  0.48%)        1723245.00 ( -2.36%)        1683717.00 ( -0.01%)
Ops minorfaults-749M          1788977.00 (  0.00%)        1871737.00 ( -4.63%)        1617193.00 (  9.60%)        1610892.00 (  9.95%)        1682760.00 (  5.94%)
Ops minorfaults-2498M         1836894.00 (  0.00%)        1796566.00 (  2.20%)        1677878.00 (  8.66%)        1685741.00 (  8.23%)        1609514.00 ( 12.38%)
Ops minorfaults-4246M         1797685.00 (  0.00%)        1819832.00 ( -1.23%)        1689258.00 (  6.03%)        1690695.00 (  5.95%)        1684430.00 (  6.30%)
Ops majorfaults-0M                  5.00 (  0.00%)              7.00 (-40.00%)              5.00 (  0.00%)             24.00 (-380.00%)              9.00 (-80.00%)
Ops majorfaults-749M            10310.00 (  0.00%)            876.00 ( 91.50%)             73.00 ( 99.29%)             63.00 ( 99.39%)             90.00 ( 99.13%)
Ops majorfaults-2498M           20809.00 (  0.00%)          22377.00 ( -7.54%)            102.00 ( 99.51%)            110.00 ( 99.47%)             55.00 ( 99.74%)
Ops majorfaults-4246M           23228.00 (  0.00%)          20270.00 ( 12.73%)            196.00 ( 99.16%)            222.00 ( 99.04%)            102.00 ( 99.56%)

Note how the vanilla kernel's performance is ruined by the parallel IO
with performance of 10932 ops/sec dropping to 2355 ops/sec. Note that
this is likely due to the swap activity and major faults as memcached
is pushed to swap prematurely.

flatten-v1r8 overall reduces the amount of reclaim but it's a minor
improvement.

limitprio-v1r8 almost eliminates the impact the parallel IO has on the
memcachetest workload. The ops/sec remain above 10K ops/sec and there is
no swapin activity.

The remainer of the series has very little impact on the memcachetest
workload but the impact on kswapd is visible in the vmstat figures.

                             3.9.0-rc2   3.9.0-rc2   3.9.0-rc2   3.9.0-rc2   3.9.0-rc2
                               vanillaflatten-v1r8limitprio-v1r8  block-v1r8   tidy-v1r8
Page Ins                       1567012     1238608       90388      103832       75684
Page Outs                     12837552    15223512    12726464    13613400    12668604
Swap Ins                        366362      286798           0          13           0
Swap Outs                       637724      660574         334        2337          53
Direct pages scanned                 0           0           0      196955      292532
Kswapd pages scanned          11763732     4389473   207629411    22337712     3885443
Kswapd pages reclaimed         1262812     1186228     1228379      971375      685338
Direct pages reclaimed               0           0           0      186053      267255
Kswapd efficiency                  10%         27%          0%          4%         17%
Kswapd velocity               9111.544    3407.923  161226.742   17342.002    3009.265
Direct efficiency                 100%        100%        100%         94%         91%
Direct velocity                  0.000       0.000       0.000     152.907     226.565
Percentage direct scans             0%          0%          0%          0%          7%
Page writes by reclaim         2858699     1159073    42498573    21198413     3018972
Page writes file               2220975      498499    42498239    21196076     3018919
Page writes anon                637724      660574         334        2337          53
Page reclaim immediate            6243         125       69598        1056        4370
Page rescued immediate               0           0           0           0           0
Slabs scanned                    35328       39296       32000       62080       25600
Direct inode steals                  0           0           0           0           0
Kswapd inode steals              16899        5491        6375       19957         907
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                     14           7          10          50           7
THP collapse alloc                 491         465         637         709         629
THP splits                          10          12           5           7           5
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0          81           3
Compaction success                   0           0           0          74           0
Compaction failures                  0           0           0           7           3
Page migrate success                 0           0           0       43855           0
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0       97582           0
Compaction migrate scanned           0           0           0      111419           0
Compaction free scanned              0           0           0      324617           0
Compaction cost                      0           0           0          48           0

While limitprio-v1r8 improves the performance of memcachetest, note what it
does to kswapd activity apparently scanning on average 162K pages/second. In
reality what happened was that there was spikes in reclaim activity but
nevertheless it's severe.

The patch that blocks kswapd when it encounters too many pages under
writeback severely reduces the amount of scanning activity. Note that the
full series also reduces the amount of slab shrinking heavily reduces the
amount of inodes reclaimed by kswapd.

Comments?

 include/linux/mmzone.h |  16 ++
 mm/vmscan.c            | 387 +++++++++++++++++++++++++++++--------------------
 2 files changed, 245 insertions(+), 158 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
