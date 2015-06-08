Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 417F76B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:36 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so87283639wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si1352753wif.13.2015.06.08.06.56.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:34 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/25] Move LRU page reclaim from zones to nodes
Date: Mon,  8 Jun 2015 14:56:06 +0100
Message-Id: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is an RFC series against 4.0 that moves LRUs from the zones to the
node. In concept, this is straight forward but there are a lot of details
so I'm posting it early to see what people think. The motivations are;

1. Currently, reclaim on node 0 behaves differently to node 1 with subtly different
   aging rules. Workloads may exhibit different behaviour depending on what node
   it was scheduled on as a result.

2. The residency of a page partially depends on what zone the page was
   allocated from.  This is partially combatted by the fair zone allocation
   policy but that is a partial solution that introduces overhead in the
   page allocator paths.

3. kswapd and the page allocator play special games with the order they scan zones
   to avoid interfering with each other but it's unpredictable.

4. The different scan activity and ordering for zone reclaim is very difficult
   to predict.

5. slab shrinkers are node-based which makes relating page reclaim to
   slab reclaim harder than it should be.

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

The series is very long and bisection will be hazardous due to being
misleading as infrastructure is reshuffled. The rational bisection points are

  [PATCH 01/25] mm, vmstat: Add infrastructure for per-node vmstats
  [PATCH 19/25] mm, vmscan: Account in vmstat for pages skipped during reclaim
  [PATCH 21/25] mm, page_alloc: Defer zlc_setup until it is known it is required
  [PATCH 23/25] mm, page_alloc: Delete the zonelist_cache
  [PATCH 25/25] mm: page_alloc: Take fewer passes when allocating to the low watermark

It was tested on a UMA (8 cores single socket) and a NUMA machine (48 cores,
4 sockets). The page allocator tests showed marginal differences in aim9,
page fault microbenchmark, page allocator micro-benchmark and ebizzy. This
was expected as the affected paths are small in comparison to the overall
workloads.

I also tested using fstest on zero-length files to stress slab reclaim. It
showed no major differences in performance or stats.

A THP-based test case that stresses compaction was inconclusive. It showed
differences in the THP allocation success rate and both gains and losses in
the time it takes to allocate THP depending on the number of threads running.

Tests did show there were differences in the pages allocated from each zone.
This is due to the fact the fair zone allocation policy is removed as with
node-based LRU reclaim, it *should* not be necessary. It would be preferable
if the original database workload that motivated the introduction of that
policy was retested with this series though.

The raw figures as such are not that interesting -- things perform more
or less the same which is what you'd hope.

 arch/s390/appldata/appldata_mem.c         |   2 +-
 arch/tile/mm/pgtable.c                    |  18 +-
 drivers/base/node.c                       |  73 +--
 drivers/staging/android/lowmemorykiller.c |  12 +-
 fs/fs-writeback.c                         |   8 +-
 fs/fuse/file.c                            |   8 +-
 fs/nfs/internal.h                         |   2 +-
 fs/nfs/write.c                            |   2 +-
 fs/proc/meminfo.c                         |  14 +-
 include/linux/backing-dev.h               |   2 +-
 include/linux/memcontrol.h                |  15 +-
 include/linux/mm_inline.h                 |   4 +-
 include/linux/mmzone.h                    | 224 ++++------
 include/linux/swap.h                      |  11 +-
 include/linux/topology.h                  |   2 +-
 include/linux/vm_event_item.h             |  11 +-
 include/linux/vmstat.h                    |  94 +++-
 include/linux/writeback.h                 |   2 +-
 include/trace/events/vmscan.h             |  10 +-
 include/trace/events/writeback.h          |   6 +-
 kernel/power/snapshot.c                   |  10 +-
 kernel/sysctl.c                           |   4 +-
 mm/backing-dev.c                          |  14 +-
 mm/compaction.c                           |  25 +-
 mm/filemap.c                              |  16 +-
 mm/huge_memory.c                          |  14 +-
 mm/internal.h                             |  11 +-
 mm/memcontrol.c                           |  37 +-
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   2 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  31 +-
 mm/mlock.c                                |  12 +-
 mm/mmap.c                                 |   4 +-
 mm/nommu.c                                |   4 +-
 mm/page-writeback.c                       | 109 ++---
 mm/page_alloc.c                           | 489 ++++++--------------
 mm/rmap.c                                 |  16 +-
 mm/shmem.c                                |  12 +-
 mm/swap.c                                 |  66 +--
 mm/swap_state.c                           |   4 +-
 mm/truncate.c                             |   2 +-
 mm/vmscan.c                               | 718 ++++++++++++++----------------
 mm/vmstat.c                               | 308 ++++++++++---
 mm/workingset.c                           |  49 +-
 45 files changed, 1225 insertions(+), 1258 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
