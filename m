Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 3F4036B00BE
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:01:21 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 00/32] memcg-aware slab shrinking with lasers and numbers
Date: Mon,  8 Apr 2013 18:00:27 +0400
Message-Id: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>

Hi,

This patchset implements targeted shrinking for memcg when kmem limits are
present. So far, we've been accounting kernel objects but failing allocations
when short of memory. This is because our only option would be to call the
global shrinker, depleting objects from all caches and breaking isolation.

The main idea is to associate per-memcg lists with each of the LRUs. The main
LRU still provides a single entry point and when adding or removing an element
from the LRU, we use the page information to figure out which memcg it belongs
to and relay it to the right list.

Base work:
==========

Please note that this builds upon the recent work from Dave Chinner that
sanitizes the LRU shrinking API and make the shrinkers node aware. Node
awareness is not *strictly* needed for my work, but I still perceive it
as an advantage. The API unification is a major need, and I build upon it
heavily. That allows us to manipulate the LRUs without knowledge of the
underlying objects with ease. This time, I am including that work here as
a baseline.

Main changes from *v2:
* shrink dead memcgs when global pressure kicks in. Uses the new lru API.
* bugfixes and comments from the mailing list.
* proper hierarchy-aware walk in shrink_slab.

Main changes from *v1:
* merged comments from the mailing list
* reworked lru-memcg API
* effective proportional shrinking
* sanitized locking on the memcg side
* bill user memory first when kmem == umem
* various bugfixes

Numbers:
========

I've run kernbench with 2Gb setups and 3 different kernels. All of them are
capable of cgroup kmem accounting,  but the first two ones won't be able to
shrink it.

Kernels
-------
base: the current -mm
davelru: that + dave's patches applied
fulllru: that + my patches applied.

I've ran all of them in a 1st level cgroup. Please note that the first
two kernels are not capable of shrinking metadata, so I had to select a
size that is enough to be in relatively constant pressure, but at the
same time not having that pressure to be exclusively from kernel memory.
2Gb did the job. This is a 2-node 24-way machine.

Results:
--------

Base:
Average Optimal load -j 24 Run (std deviation):
Elapsed Time 415.988 (8.37909)
User Time 4142 (759.964)
System Time 418.483 (62.0377)
Percent CPU 1030.7 (267.462)
Context Switches 391509 (268361)
Sleeps 738483 (149934)

Dave:
Average Optimal load -j 24 Run (std deviation):
Elapsed Time 424.486 (16.7365) ( + 2 % vs base)
User Time 4146.8 (764.012) ( + 0.84 % vs base)
System Time 419.24 (62.4507) (+ 0.18 % vs base)
Percent CPU 1012.1 (264.558) (-1.8 % vs base)
Context Switches 393363 (268899) (+ 0.47 % vs base)
Sleeps 739905 (147344) (+ 0.19 % vs base)


Full:
Average Optimal load -j 24 Run (std deviation):
Elapsed Time 456.644 (15.3567) ( + 9.7 % vs base)
User Time 4036.3 (645.261) ( - 2.5 % vs base)
System Time 438.134 (82.251) ( + 4.7 % vs base)
Percent CPU 973 (168.581) ( - 5.6 % vs base)
Context Switches 350796 (229700) ( - 10 % vs base)
Sleeps 728156 (138808) ( - 1.4 % vs base )

Discussion
-----------

First-level analysis: All figures fall within the std dev, except for
Full LRU wall time. It does fall within 2 std devs, though.
On the other hand, Full LRU kernel leads to better cpu utilization and
greater efficiency.

Details: The reclaim patterns in the three kernels are expected to be
different. User memory will always be the main driver, but in case of
pressure the first two kernels will shrink it while keeping the metadata
intact. This should lead to smaller system times figure at expense of
bigger user time figures, since user pages will be evicted more often.
This is consistent with the figures I've found.

Full LRU kernels have a 2.5 % better user time utilization, with 5.6 %
less CPU consumed and 10 % less context switches.

This comes at the expense of a 4.7 % loss of system time. Because we
will have to bring more dentry and inode objects back from caches, we
will stress more the slab code.

Because this is a benchmark that stresses a lot of metadata, it is
expected that this increase affects the end wall result proportionally.
We notice that the mere introduction of LRU code (Dave's Kernel) does
not affect the end wall time result outside the standard deviation.
Shrinking those objects, however, will lead to bigger wall times. This
is within the expected. No one would ever argue that the right kernel
behavior for all cases should keep the metadata in memory at expense of
user memory (and even if we should, we should do it the same way for the
cgroups).

My final conclusions is that performance wise the work is sound and
operates within expectations.

Dave Chinner (17):
  dcache: convert dentry_stat.nr_unused to per-cpu counters
  dentry: move to per-sb LRU locks
  dcache: remove dentries from LRU before putting on dispose list
  mm: new shrinker API
  shrinker: convert superblock shrinkers to new API
  list: add a new LRU list type
  inode: convert inode lru list to generic lru list code.
  dcache: convert to use new lru list infrastructure
  list_lru: per-node list infrastructure
  shrinker: add node awareness
  fs: convert inode and dentry shrinking to be node aware
  xfs: convert buftarg LRU to generic code
  xfs: convert dquot cache lru to list_lru
  fs: convert fs shrinkers to new scan/count API
  drivers: convert shrinkers to new count/scan API
  shrinker: convert remaining shrinkers to count/scan API
  shrinker: Kill old ->shrink API.

Glauber Costa (15):
  super: fix calculation of shrinkable objects for small numbers
  vmscan: take at least one pass with shrinkers
  hugepage: convert huge zero page shrinker to new shrinker API
  vmscan: also shrink slab in memcg pressure
  memcg,list_lru: duplicate LRUs upon kmemcg creation
  lru: add an element to a memcg list
  list_lru: also include memcg lists in counts and scans
  list_lru: per-memcg walks
  memcg: per-memcg kmem shrinking
  list_lru: reclaim proportionaly between memcgs and nodes
  memcg: scan cache objects hierarchically
  memcg: move initialization to memcg creation
  memcg: shrink dead memcgs upon global memory pressure.
  super: targeted memcg reclaim
  memcg: debugging facility to access dangling memcgs

 Documentation/cgroups/memory.txt           |  16 +
 arch/x86/kvm/mmu.c                         |  35 +-
 drivers/gpu/drm/i915/i915_dma.c            |   4 +-
 drivers/gpu/drm/i915/i915_drv.h            |   2 +-
 drivers/gpu/drm/i915/i915_gem.c            |  69 +++-
 drivers/gpu/drm/i915/i915_gem_evict.c      |  10 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |   2 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c       |  48 ++-
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c   |  55 ++-
 drivers/md/dm-bufio.c                      |  65 +--
 drivers/staging/android/ashmem.c           |  44 ++-
 drivers/staging/android/lowmemorykiller.c  |  40 +-
 drivers/staging/zcache/zcache-main.c       |  29 +-
 fs/dcache.c                                | 240 ++++++-----
 fs/drop_caches.c                           |   1 +
 fs/ext4/extents_status.c                   |  30 +-
 fs/gfs2/glock.c                            |  30 +-
 fs/gfs2/main.c                             |   3 +-
 fs/gfs2/quota.c                            |  14 +-
 fs/gfs2/quota.h                            |   4 +-
 fs/inode.c                                 | 174 ++++----
 fs/internal.h                              |   5 +
 fs/mbcache.c                               |  53 +--
 fs/nfs/dir.c                               |  20 +-
 fs/nfs/internal.h                          |   4 +-
 fs/nfs/super.c                             |   3 +-
 fs/nfsd/nfscache.c                         |  31 +-
 fs/quota/dquot.c                           |  39 +-
 fs/super.c                                 | 107 +++--
 fs/ubifs/shrinker.c                        |  20 +-
 fs/ubifs/super.c                           |   3 +-
 fs/ubifs/ubifs.h                           |   3 +-
 fs/xfs/xfs_buf.c                           | 167 ++++----
 fs/xfs/xfs_buf.h                           |   5 +-
 fs/xfs/xfs_dquot.c                         |   7 +-
 fs/xfs/xfs_icache.c                        |   4 +-
 fs/xfs/xfs_icache.h                        |   2 +-
 fs/xfs/xfs_qm.c                            | 275 ++++++-------
 fs/xfs/xfs_qm.h                            |   4 +-
 fs/xfs/xfs_super.c                         |  12 +-
 include/linux/dcache.h                     |   4 +
 include/linux/fs.h                         |  25 +-
 include/linux/list_lru.h                   | 121 ++++++
 include/linux/memcontrol.h                 |  51 +++
 include/linux/shrinker.h                   |  45 ++-
 include/linux/swap.h                       |   2 +
 include/trace/events/vmscan.h              |   4 +-
 init/Kconfig                               |  17 +
 lib/Makefile                               |   2 +-
 lib/list_lru.c                             | 498 +++++++++++++++++++++++
 mm/huge_memory.c                           |  18 +-
 mm/memcontrol.c                            | 612 ++++++++++++++++++++++++++---
 mm/memory-failure.c                        |   2 +
 mm/slab_common.c                           |   1 -
 mm/vmscan.c                                | 322 ++++++++++-----
 net/sunrpc/auth.c                          |  45 ++-
 56 files changed, 2529 insertions(+), 919 deletions(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 lib/list_lru.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
