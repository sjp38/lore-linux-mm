Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id F2D206B0044
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:47 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/34] Memory management performance backports for -stable
Date: Thu, 19 Jul 2012 15:36:10 +0100
Message-Id: <1342708604-26540-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This series is related to the new addition to stable_kernel_rules.txt

 - Serious issues as reported by a user of a distribution kernel may also
   be considered if they fix a notable performance or interactivity issue.
   As these fixes are not as obvious and have a higher risk of a subtle
   regression they should only be submitted by a distribution kernel
   maintainer and include an addendum linking to a bugzilla entry if it
   exists and additional information on the user-visible impact.

All of these patches have been backported to a distribution kernel and
address some sort of performance issue in the VM. As they are not all
obvious, I've added a "Stable note" to the top of each patch giving
additional information on why the patch was backported. Lets see where
the boundaries lie on how this new rule is interpreted in practice :).

Patch 1	Performance fix for tmpfs
Patch 2 Memory hotadd fix
Patch 3 Reduce boot time on large machines
Patches 4-5 Reduce stalls for wait_iff_congested
Patches 6-8 Reduce excessive reclaim of slab objects which for some workloads
	will reduce the amount of IO required
Patches 9-10 limits the amount of page reclaim when THP/Compaction is active.
	Excessive reclaim in low memory situations can lead to stalls some
	of which are user visible.
Patches 11-19 reduce the amount of churn of the LRU lists. Poor reclaim
	decisions can impair workloads in different ways and there have
	been complaints recently the reclaim decisions of modern kernels
	are worse than older ones.
Patches 20-21 reduce the amount of CPU kswapd uses in some cases. This
	is harder to trigger but were developed due to bug reports about
	100% CPU usage from kswapd.
Patches 22-25 are mostly related to interactivity when THP is enabled.
Patches 26-30 are also related to page reclaim decisions, particularly
	the residency of mapped pages.
Patches 31-34 fix a major page allocator performance regression

All of the patches will apply to 3.0-stable but the ordering of the
patches is such that applying them to 3.2-stable and 3.4-stable should
be straight-forward.

I am bending or breaking the rules in places that needs examination.

1. Not all these patches have a bugzilla entry because in many cases I was
   doing the investigation based on my own testing. By rights, I should
   have been creating bugzilla entries for each of them but there only are
   so many hours in the day.
2. I will be duplicated in the signed-offs because I may both the author
   of the patch and now part of the submission path to -stable. I don't
   think there is anything wrong with this but it might look weird to
   some people.
3. Some patches are in the series only because they make later patches
   easier to backport.
4. Patch 30 stomps all over the rules. The upstream patch accidentally
   fixes a problem and was found through bisection but the full patch
   and the series itself is not a good -stable candidate.

I'm running tests against the backport as it's a unique combination but the
patches have been tested as part of the distribution backport already. It'll
be a few days before I have an exact comparison between 3.0.36 and the
backport but I have a few basic results against 3.0.23. I'm not going to
analyse them in detail but here a few points

http://www.csn.ul.ie/~mel/postings/stableport-20120719/global-dhp__pagealloc-performance/hydra/comparison.html

 o System CPU time reduced on kernbench
 o Page allocator latency reduced for the most part, there are
   counter-examples but it's mostly reduced
 o page_test, brk_test improved on aim9
 o 5% gain in page faults/sec in page fault micro benchmark

http://www.csn.ul.ie/~mel/postings/stableport-20120719/global-dhp__pagereclaim-performance-ext4/hydra/comparison.html
 o fsmark in single threaded mode completed faster and with higher operations/second
 o postmark looks slower but there are changes in ext4 between 3.0.23 and 3.0.36 that
   might account for this. kswapd scan rates were slightly reduced
 o In the micro benchmark, it took longer to complete but kswapd and direct
   reclaim activity were reduced

Alex,Shi (2):
  kswapd: avoid unnecessary rebalance after an unsuccessful balancing
  kswapd: assign new_order and new_classzone_idx after wakeup in
    sleeping

Dave Chinner (3):
  vmscan: add shrink_slab tracepoints
  vmscan: shrinker->nr updates race and go wrong
  vmscan: reduce wind up shrinker->nr when shrinker can't do work

David Rientjes (2):
  cpusets: avoid looping when storing to mems_allowed if one node
    remains set
  cpusets: stall when updating mems_allowed for mempolicy or disjoint
    nodemask

Dimitri Sivanich (1):
  mm: vmstat: cache align vm_stat

Hugh Dickins (1):
  mm: test PageSwapBacked in lumpy reclaim

Johannes Weiner (1):
  mm: vmscan: fix force-scanning small targets without swap

Konstantin Khlebnikov (3):
  vmscan: promote shared file mapped pages
  vmscan: activate executable pages after first usage
  mm/hugetlb: fix warning in alloc_huge_page/dequeue_huge_page_vma

Mel Gorman (14):
  mm: memory hotplug: Check if pages are correctly reserved on a
    per-section basis
  mm: Reduce the amount of work done when updating min_free_kbytes
  mm: Abort reclaim/compaction if compaction can proceed
  mm: migration: clean up unmap_and_move()
  mm: compaction: Allow compaction to isolate dirty pages
  mm: compaction: Determine if dirty pages can be migrated without
    blocking within ->migratepage
  mm: page allocator: Do not call direct reclaim for THP allocations
    while compaction is deferred
  mm: compaction: make isolate_lru_page() filter-aware again
  mm: compaction: Introduce sync-light migration for use by compaction
  mm: vmscan: When reclaiming for compaction, ensure there are
    sufficient free pages available
  mm: vmscan: Do not OOM if aborting reclaim to start compaction
  mm: vmscan: Check if reclaim should really abort even if
    compaction_ready() is true for one zone
  mm: vmscan: Do not force kswapd to scan small targets
  cpuset: mm: Reduce large amounts of memory barrier related damage v3

Minchan Kim (5):
  mm: compaction: trivial clean up in acct_isolated()
  mm: change isolate mode from #define to bitwise type
  mm: compaction: make isolate_lru_page() filter-aware
  mm: zone_reclaim: make isolate_lru_page() filter-aware
  mm/vmscan.c: consider swap space when deciding whether to continue
    reclaim

Rik van Riel (1):
  mm: limit direct reclaim for higher order allocations

Shaohua Li (1):
  vmscan: clear ZONE_CONGESTED for zone with good watermark

 .../trace/postprocess/trace-vmscan-postprocess.pl  |    8 +-
 drivers/base/memory.c                              |   58 ++--
 fs/btrfs/disk-io.c                                 |    5 +-
 fs/hugetlbfs/inode.c                               |    3 +-
 fs/nfs/internal.h                                  |    2 +-
 fs/nfs/write.c                                     |    4 +-
 include/linux/cpuset.h                             |   45 ++--
 include/linux/fs.h                                 |   11 +-
 include/linux/init_task.h                          |    8 +
 include/linux/memcontrol.h                         |    3 +-
 include/linux/migrate.h                            |   23 +-
 include/linux/mmzone.h                             |   14 +
 include/linux/sched.h                              |    2 +-
 include/linux/swap.h                               |    7 +-
 include/trace/events/vmscan.h                      |   85 +++++-
 kernel/cpuset.c                                    |   63 ++---
 kernel/fork.c                                      |    3 +
 mm/compaction.c                                    |   26 +-
 mm/filemap.c                                       |   11 +-
 mm/hugetlb.c                                       |   13 +-
 mm/memcontrol.c                                    |    3 +-
 mm/memory-failure.c                                |    2 +-
 mm/memory_hotplug.c                                |    2 +-
 mm/mempolicy.c                                     |   30 ++-
 mm/migrate.c                                       |  224 ++++++++++------
 mm/page_alloc.c                                    |  113 +++++---
 mm/slab.c                                          |   13 +-
 mm/slub.c                                          |   39 ++-
 mm/vmscan.c                                        |  280 ++++++++++++++++----
 mm/vmstat.c                                        |    2 +-
 30 files changed, 772 insertions(+), 330 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
