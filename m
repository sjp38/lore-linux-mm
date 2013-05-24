Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 36B706B0036
	for <linux-mm@kvack.org>; Fri, 24 May 2013 06:32:06 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v8 00/34] kmemcg shrinkers
Date: Fri, 24 May 2013 15:58:54 +0530
Message-Id: <1369391368-31562-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>

Initial notes
=============

Main changes from *v7:
* Fixed races for memcg
* Enhanced memcg hierarchy walks during global pressure (we were walking only
  the global list, not all memcgs)

Dave still reports some problems in XFS, but he is himself not sure if they are
due to this series. I am travelling right now, so I won't investigate it so
deeply. Dave, if you could take a look at this, I would be much obliged.  I did
want to send a new version with some memcg-side fixes, though. I am now always
creating the LRUs before I create the caches. This gets rid of a race where an
object can be created and go to the LRU very quickly, in a point where the LRU
does not yet exist.

If you want, you can also grab from branch "kmemcg-lru-shrinker" at:

	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git

The performance seems to be fine. My testing now shows a smoother and steady
state for the objects during the lifetime of the workload, and the NUMA
performance seems improved.

=========
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

Main changes from *v7:
* Fixed races for memcg
* Enhanced memcg hierarchy walks during global pressure (we were walking only
  the global list, not all memcgs)

Main changes from *v6:
* Change nr_unused_dentry to long, Dave reported an int not being enough
* Fixed shrink_list leak, by Dave
* LRU API now gets a node id, instead of a node mask.
* per-node deferred work, leading to smoother behavior

Main changes from *v5:
* Rebased to linux-next, and fix the conflicts with the dcache.
* Make sure LRU_RETRY only retry once
* Prevent the bcache shrinker to scan the caches when disabled (by returning
  0 in the count function)
* Fix i915 return code when mutex cannot be acquired.
* Only scan less-than-batch objects in memcg scenarios

Main changes from *v4:
* Fixed a bug in user-generated memcg pressure
* Fixed overly-agressive slab shrinker behavior spotted by Mel Gorman
* Various other fixes and comments by Mel Gorman

Main changes from *v3:
* Merged suggestions from mailing list.
* Removed the memcg-walking code from LRU. vmscan now drives all the hierarchy
  decisions, which makes more sense
* lazily free the old memcg arrays (needs now to be saved in struct lru). Since
  we need to call synchronize_rcu, calling it for every LRU can become expensive
* Moved the dead memcg shrinker to vmpressure. Already independently sent to
  linux-mm for review.
* Changed locking convention for LRU_RETRY. It now needs to return locked, which
  silents warnings about possible lock unbalance (although previous code was
  correct)

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

Glauber Costa (17):
  fs: bump inode and dentry counters to long
  super: fix calculation of shrinkable objects for small numbers
  vmscan: per-node deferred work
  list_lru: per-node API
  i915: bail out earlier when shrinker cannot acquire mutex
  hugepage: convert huge zero page shrinker to new shrinker API
  vmscan: also shrink slab in memcg pressure
  memcg,list_lru: duplicate LRUs upon kmemcg creation
  lru: add an element to a memcg list
  list_lru: per-memcg walks
  memcg: per-memcg kmem shrinking
  memcg: scan cache objects hierarchically
  vmscan: take at least one pass with shrinkers
  super: targeted memcg reclaim
  memcg: move initialization to memcg creation
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure.

 arch/x86/kvm/mmu.c                        |  28 +-
 drivers/gpu/drm/i915/i915_dma.c           |   4 +-
 drivers/gpu/drm/i915/i915_gem.c           |  71 +++--
 drivers/gpu/drm/ttm/ttm_page_alloc.c      |  48 ++--
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c  |  55 ++--
 drivers/md/bcache/btree.c                 |  43 +--
 drivers/md/bcache/sysfs.c                 |   2 +-
 drivers/md/dm-bufio.c                     |  65 +++--
 drivers/staging/android/ashmem.c          |  46 +++-
 drivers/staging/android/lowmemorykiller.c |  40 +--
 drivers/staging/zcache/zcache-main.c      |  29 +-
 fs/dcache.c                               | 259 +++++++++++-------
 fs/drop_caches.c                          |   1 +
 fs/ext4/extents_status.c                  |  30 ++-
 fs/gfs2/glock.c                           |  30 ++-
 fs/gfs2/main.c                            |   3 +-
 fs/gfs2/quota.c                           |  14 +-
 fs/gfs2/quota.h                           |   4 +-
 fs/inode.c                                | 194 ++++++-------
 fs/internal.h                             |   7 +-
 fs/mbcache.c                              |  53 ++--
 fs/nfs/dir.c                              |  20 +-
 fs/nfs/internal.h                         |   4 +-
 fs/nfs/super.c                            |   3 +-
 fs/nfsd/nfscache.c                        |  31 ++-
 fs/quota/dquot.c                          |  39 ++-
 fs/super.c                                | 104 ++++---
 fs/ubifs/shrinker.c                       |  20 +-
 fs/ubifs/super.c                          |   3 +-
 fs/ubifs/ubifs.h                          |   3 +-
 fs/xfs/xfs_buf.c                          | 170 ++++++------
 fs/xfs/xfs_buf.h                          |   5 +-
 fs/xfs/xfs_dquot.c                        |   7 +-
 fs/xfs/xfs_icache.c                       |   4 +-
 fs/xfs/xfs_icache.h                       |   2 +-
 fs/xfs/xfs_qm.c                           | 277 +++++++++----------
 fs/xfs/xfs_qm.h                           |   4 +-
 fs/xfs/xfs_super.c                        |  12 +-
 include/linux/dcache.h                    |  14 +-
 include/linux/fs.h                        |  25 +-
 include/linux/list_lru.h                  | 162 +++++++++++
 include/linux/memcontrol.h                |  45 ++++
 include/linux/shrinker.h                  |  72 ++++-
 include/linux/swap.h                      |   2 +
 include/linux/vmpressure.h                |   6 +
 include/trace/events/vmscan.h             |   4 +-
 include/uapi/linux/fs.h                   |   6 +-
 kernel/sysctl.c                           |   6 +-
 lib/Makefile                              |   2 +-
 lib/list_lru.c                            | 406 ++++++++++++++++++++++++++++
 mm/huge_memory.c                          |  17 +-
 mm/memcontrol.c                           | 433 ++++++++++++++++++++++++++----
 mm/memory-failure.c                       |   2 +
 mm/slab_common.c                          |   1 -
 mm/vmpressure.c                           |  52 +++-
 mm/vmscan.c                               | 381 +++++++++++++++++++-------
 net/sunrpc/auth.c                         |  45 +++-
 57 files changed, 2457 insertions(+), 958 deletions(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 lib/list_lru.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
