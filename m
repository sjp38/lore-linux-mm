Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9456B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:04:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so20871645lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:04:56 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id b199si39425462wme.74.2016.06.09.11.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 11:04:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 1B06C1C1935
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:04:54 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/27] Move LRU page reclaim from zones to nodes v6
Date: Thu,  9 Jun 2016 19:04:16 +0100
Message-Id: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is only lightly tested as I've had stability problems during boot
that have nothing to do with the series. It's based on mmots as of June
6th. Very little has changed with the big exception of "mm, vmscan:
Move LRU lists to node" because it had to adapt to per-zone changes in
should_reclaim_retry and compaction_zonelist_suitable.

Changelog since v5
o Rebase and adjust to changes

Changelog since v4
o Rebase on top of v3 of page allocator optimisation series

Changelog since v3
o Rebase on top of the page allocator optimisation series
o Remove RFC tag

This is the latest version of a series that moves LRUs from the zones to
the node that is based upon 4.6-rc3 plus the page allocator optimisation
series. Conceptually, this is simple but there are a lot of details. Some
of the broad motivations for this are;

1. The residency of a page partially depends on what zone the page was
   allocated from.  This is partially combatted by the fair zone allocation
   policy but that is a partial solution that introduces overhead in the
   page allocator paths.

2. Currently, reclaim on node 0 behaves slightly different to node 1. For
   example, direct reclaim scans in zonelist order and reclaims even if
   the zone is over the high watermark regardless of the age of pages
   in that LRU. Kswapd on the other hand starts reclaim on the highest
   unbalanced zone. A difference in distribution of file/anon pages due
   to when they were allocated results can result in a difference in 
   again. While the fair zone allocation policy mitigates some of the
   problems here, the page reclaim results on a multi-zone node will
   always be different to a single-zone node.
   it was scheduled on as a result.

3. kswapd and the page allocator scan zones in the opposite order to
   avoid interfering with each other but it's sensitive to timing.  This
   mitigates the page allocator using pages that were allocated very recently
   in the ideal case but it's sensitive to timing. When kswapd is allocating
   from lower zones then it's great but during the rebalancing of the highest
   zone, the page allocator and kswapd interfere with each other. It's worse
   if the highest zone is small and difficult to balance.

4. slab shrinkers are node-based which makes it harder to identify the exact
   relationship between slab reclaim and LRU reclaim.

The reason we have zone-based reclaim is that we used to have
large highmem zones in common configurations and it was necessary
to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
less of a concern as machines with lots of memory will (or should) use
64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
rare. Machines that do use highmem should have relatively low highmem:lowmem
ratios than we worried about in the past.

Conceptually, moving to node LRUs should be easier to understand. The
page allocator plays fewer tricks to game reclaim and reclaim behaves
similarly on all nodes. 

The series got basic testing this time on a UMA machine. The page allocator
microbenchmark highlights the gain from removing the fair zone allocation
policy

                                           4.7.0-rc2                  4.7.0-rc2
                                      mmotm-20160606               nodelru-v6r2
Min      total-odr0-1               500.00 (  0.00%)           475.00 (  5.00%)
Min      total-odr0-2               358.00 (  0.00%)           343.00 (  4.19%)
Min      total-odr0-4               292.00 (  0.00%)           279.00 (  4.45%)
Min      total-odr0-8               253.00 (  0.00%)           242.00 (  4.35%)
Min      total-odr0-16              275.00 (  0.00%)           226.00 ( 17.82%)
Min      total-odr0-32              225.00 (  0.00%)           215.00 (  4.44%)
Min      total-odr0-64              219.00 (  0.00%)           210.00 (  4.11%)
Min      total-odr0-128             216.00 (  0.00%)           207.00 (  4.17%)
Min      total-odr0-256             243.00 (  0.00%)           246.00 ( -1.23%)
Min      total-odr0-512             276.00 (  0.00%)           265.00 (  3.99%)
Min      total-odr0-1024            290.00 (  0.00%)           287.00 (  1.03%)
Min      total-odr0-2048            303.00 (  0.00%)           296.00 (  2.31%)
Min      total-odr0-4096            312.00 (  0.00%)           310.00 (  0.64%)
Min      total-odr0-8192            320.00 (  0.00%)           308.00 (  3.75%)
Min      total-odr0-16384           320.00 (  0.00%)           308.00 (  3.75%)
Min      total-odr1-1               737.00 (  0.00%)           707.00 (  4.07%)
Min      total-odr1-2               547.00 (  0.00%)           521.00 (  4.75%)
Min      total-odr1-4               620.00 (  0.00%)           418.00 ( 32.58%)
Min      total-odr1-8               386.00 (  0.00%)           367.00 (  4.92%)
Min      total-odr1-16              361.00 (  0.00%)           340.00 (  5.82%)
Min      total-odr1-32              352.00 (  0.00%)           328.00 (  6.82%)
Min      total-odr1-64              345.00 (  0.00%)           324.00 (  6.09%)
Min      total-odr1-128             347.00 (  0.00%)           328.00 (  5.48%)
Min      total-odr1-256             347.00 (  0.00%)           329.00 (  5.19%)
Min      total-odr1-512             354.00 (  0.00%)           332.00 (  6.21%)
Min      total-odr1-1024            355.00 (  0.00%)           337.00 (  5.07%)
Min      total-odr1-2048            358.00 (  0.00%)           345.00 (  3.63%)
Min      total-odr1-4096            360.00 (  0.00%)           346.00 (  3.89%)
Min      total-odr1-8192            360.00 (  0.00%)           347.00 (  3.61%)

A basic IO benchmark based on varying numbers of dd running in parallel
showed nothing interesting other than differences in what zones were
scanned due to the fair zone allocation policy being removed.

This series is not without its hazards. There are at least three areas
that I'm concerned with even though I could not reproduce any problems in
that area.

1. Reclaim/compaction is going to be affected because the amount of reclaim is
   no longer targetted at a specific zone. Compaction works on a per-zone basis
   so there is no guarantee that reclaiming a few THP's worth page pages will
   have a positive impact on compaction success rates.

2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
   are called is now different. This may or may not be a problem but if it
   is, it'll be because shrinkers are not called enough and some balancing
   is required.

3. The anon/file reclaim ratio may be affected. Pages about to be dirtied are
   distributed between zones and the fair zone allocation policy used to do
   something very similar for anon. The distribution is now different but not
   necessarily in any way that matters but it's still worth bearing in mind.

 Documentation/cgroup-v1/memcg_test.txt    |   4 +-
 Documentation/cgroup-v1/memory.txt        |   4 +-
 arch/s390/appldata/appldata_mem.c         |   2 +-
 arch/tile/mm/pgtable.c                    |  18 +-
 drivers/base/node.c                       |  73 +--
 drivers/staging/android/lowmemorykiller.c |  12 +-
 fs/fs-writeback.c                         |   4 +-
 fs/fuse/file.c                            |   8 +-
 fs/nfs/internal.h                         |   2 +-
 fs/nfs/write.c                            |   2 +-
 fs/proc/meminfo.c                         |  14 +-
 include/linux/backing-dev.h               |   2 +-
 include/linux/memcontrol.h                |  30 +-
 include/linux/mm_inline.h                 |   2 +-
 include/linux/mm_types.h                  |   2 +-
 include/linux/mmzone.h                    | 157 +++---
 include/linux/swap.h                      |  15 +-
 include/linux/topology.h                  |   2 +-
 include/linux/vm_event_item.h             |  14 +-
 include/linux/vmstat.h                    | 111 +++-
 include/linux/writeback.h                 |   2 +-
 include/trace/events/vmscan.h             |  40 +-
 include/trace/events/writeback.h          |  10 +-
 kernel/power/snapshot.c                   |  10 +-
 kernel/sysctl.c                           |   4 +-
 mm/backing-dev.c                          |  15 +-
 mm/compaction.c                           |  39 +-
 mm/filemap.c                              |  14 +-
 mm/huge_memory.c                          |  33 +-
 mm/internal.h                             |  11 +-
 mm/memcontrol.c                           | 235 ++++-----
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   7 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  35 +-
 mm/mlock.c                                |  12 +-
 mm/page-writeback.c                       | 124 +++--
 mm/page_alloc.c                           | 271 +++++-----
 mm/page_idle.c                            |   4 +-
 mm/rmap.c                                 |  15 +-
 mm/shmem.c                                |  12 +-
 mm/swap.c                                 |  66 +--
 mm/swap_state.c                           |   4 +-
 mm/util.c                                 |   4 +-
 mm/vmscan.c                               | 829 +++++++++++++++---------------
 mm/vmstat.c                               | 374 +++++++++++---
 mm/workingset.c                           |  52 +-
 47 files changed, 1489 insertions(+), 1217 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
