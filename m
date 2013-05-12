Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3CD466B0034
	for <linux-mm@kvack.org>; Sun, 12 May 2013 14:13:27 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v6 00/31] kmemcg shrinkers
Date: Sun, 12 May 2013 22:13:21 +0400
Message-Id: <1368382432-25462-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

Initial notes:
==============

Mel, Dave, this is the last round of fixes I have for the series. The fixes are
few, and I was mostly interested in getting this out based on an up2date tree
so Dave can verify it. This should apply fine ontop of Friday's linux-next.
Alternatively, please grab from branch "kmemcg-lru-shrinker" at:

	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git

Main changes from *v5:
* Rebased to linux-next, and fix the conflicts with the dcache.
* Make sure LRU_RETRY only retry once
* Prevent the bcache shrinker to scan the caches when disabled (by returning
  0 in the count function)
* Fix i915 return code when mutex cannot be acquired.
* Only scan less-than-batch objects in memcg scenarios

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

Glauber Costa (14):
  super: fix calculation of shrinkable objects for small numbers
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
 fs/dcache.c                               | 240 ++++++++++-------
 fs/drop_caches.c                          |   1 +
 fs/ext4/extents_status.c                  |  30 ++-
 fs/gfs2/glock.c                           |  30 ++-
 fs/gfs2/main.c                            |   3 +-
 fs/gfs2/quota.c                           |  14 +-
 fs/gfs2/quota.h                           |   4 +-
 fs/inode.c                                | 175 +++++-------
 fs/internal.h                             |   5 +
 fs/mbcache.c                              |  53 ++--
 fs/nfs/dir.c                              |  20 +-
 fs/nfs/internal.h                         |   4 +-
 fs/nfs/super.c                            |   3 +-
 fs/nfsd/nfscache.c                        |  31 ++-
 fs/quota/dquot.c                          |  39 ++-
 fs/super.c                                | 107 +++++---
 fs/ubifs/shrinker.c                       |  20 +-
 fs/ubifs/super.c                          |   3 +-
 fs/ubifs/ubifs.h                          |   3 +-
 fs/xfs/xfs_buf.c                          | 169 ++++++------
 fs/xfs/xfs_buf.h                          |   5 +-
 fs/xfs/xfs_dquot.c                        |   7 +-
 fs/xfs/xfs_icache.c                       |   4 +-
 fs/xfs/xfs_icache.h                       |   2 +-
 fs/xfs/xfs_qm.c                           | 275 +++++++++----------
 fs/xfs/xfs_qm.h                           |   4 +-
 fs/xfs/xfs_super.c                        |  12 +-
 include/linux/dcache.h                    |   4 +
 include/linux/fs.h                        |  25 +-
 include/linux/list_lru.h                  | 145 ++++++++++
 include/linux/memcontrol.h                |  45 ++++
 include/linux/shrinker.h                  |  44 ++-
 include/linux/swap.h                      |   2 +
 include/linux/vmpressure.h                |   6 +
 include/trace/events/vmscan.h             |   4 +-
 lib/Makefile                              |   2 +-
 lib/list_lru.c                            | 433 ++++++++++++++++++++++++++++++
 mm/huge_memory.c                          |  17 +-
 mm/memcontrol.c                           | 430 +++++++++++++++++++++++++----
 mm/memory-failure.c                       |   2 +
 mm/slab_common.c                          |   1 -
 mm/vmpressure.c                           |  52 +++-
 mm/vmscan.c                               | 325 +++++++++++++++-------
 net/sunrpc/auth.c                         |  45 +++-
 55 files changed, 2339 insertions(+), 937 deletions(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 lib/list_lru.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
