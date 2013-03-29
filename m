Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id EFE326B0006
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:13:58 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 00/28] memcg-aware slab shrinking
Date: Fri, 29 Mar 2013 13:13:42 +0400
Message-Id: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com

Hi,

Notes:
======

This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
and it behaves well, at least from the isolation point of view. However,
I feel some more testing is needed before we commit to it. Still, this is
doing the job fairly well. Comments welcome.

Base work:
==========

Please note that this builds upon the recent work from Dave Chinner that
sanitizes the LRU shrinking API and make the shrinkers node aware. Node
awareness is not *strictly* needed for my work, but I still perceive it
as an advantage. The API unification is a major need, and I build upon it
heavily. That allows us to manipulate the LRUs without knowledge of the
underlying objects with ease. This time, I am including that work here as
a baseline.

Description:
============

This patchset implements targeted shrinking for memcg when kmem limits are
present. So far, we've been accounting kernel objects but failing allocations
when short of memory. This is because our only option would be to call the
global shrinker, depleting objects from all caches and breaking isolation.

The main idea is to associate per-memcg lists with each of the LRUs. The main
LRU still provides a single entry point and when adding or removing an element
from the LRU, we use the page information to figure out which memcg it belongs
to and relay it to the right list.

Patches:
========
1 and 2: improve handling of small number of shrinkable objects.
	 This is a scenario that is way more likely to appear under memcg,
         although it is not memcg-specific. Already sent separately, but not
         yet merged.

3 to 20: Dave's work to unify the LRU API and make it per-node. I had to make
         minor changes to the patches to reflect new code in the tree and due to
         build problems. I tried to keep them as unchanged as possible.

21 to 28: memcg targeted shrinking.

Main changes from *v1:
* merged comments from the mailing list
* reworked lru-memcg API
* effective proportional shrinking
* sanitized locking on the memcg side
* bill user memory first when kmem == umem
* various bugfixes

TODO:
* shrink dead memcgs when global pressure kicks in. (minor)

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

Glauber Costa (11):
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
  super: targeted memcg reclaim

 arch/x86/kvm/mmu.c                         |  35 ++-
 drivers/gpu/drm/i915/i915_dma.c            |   4 +-
 drivers/gpu/drm/i915/i915_drv.h            |   2 +-
 drivers/gpu/drm/i915/i915_gem.c            |  69 +++--
 drivers/gpu/drm/i915/i915_gem_evict.c      |  10 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |   2 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c       |  48 ++-
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c   |  55 ++--
 drivers/md/dm-bufio.c                      |  65 ++--
 drivers/staging/android/ashmem.c           |  44 ++-
 drivers/staging/android/lowmemorykiller.c  |  40 ++-
 drivers/staging/zcache/zcache-main.c       |  29 +-
 fs/dcache.c                                | 215 +++++++------
 fs/drop_caches.c                           |   1 +
 fs/ext4/extents_status.c                   |  30 +-
 fs/gfs2/glock.c                            |  30 +-
 fs/gfs2/main.c                             |   3 +-
 fs/gfs2/quota.c                            |  14 +-
 fs/gfs2/quota.h                            |   4 +-
 fs/inode.c                                 | 174 +++++------
 fs/internal.h                              |   5 +
 fs/mbcache.c                               |  53 ++--
 fs/nfs/dir.c                               |  20 +-
 fs/nfs/internal.h                          |   4 +-
 fs/nfs/super.c                             |   3 +-
 fs/nfsd/nfscache.c                         |  31 +-
 fs/quota/dquot.c                           |  39 ++-
 fs/super.c                                 | 107 ++++---
 fs/ubifs/shrinker.c                        |  20 +-
 fs/ubifs/super.c                           |   3 +-
 fs/ubifs/ubifs.h                           |   3 +-
 fs/xfs/xfs_buf.c                           | 167 +++++-----
 fs/xfs/xfs_buf.h                           |   5 +-
 fs/xfs/xfs_dquot.c                         |   7 +-
 fs/xfs/xfs_icache.c                        |   4 +-
 fs/xfs/xfs_icache.h                        |   2 +-
 fs/xfs/xfs_qm.c                            | 274 +++++++++--------
 fs/xfs/xfs_qm.h                            |   4 +-
 fs/xfs/xfs_super.c                         |  12 +-
 include/linux/dcache.h                     |   4 +
 include/linux/fs.h                         |  25 +-
 include/linux/list_lru.h                   | 112 +++++++
 include/linux/memcontrol.h                 |  41 +++
 include/linux/shrinker.h                   |  45 ++-
 include/linux/swap.h                       |   2 +
 include/trace/events/vmscan.h              |   4 +-
 lib/Makefile                               |   2 +-
 lib/list_lru.c                             | 474 +++++++++++++++++++++++++++++
 mm/huge_memory.c                           |  18 +-
 mm/memcontrol.c                            | 373 ++++++++++++++++++++---
 mm/memory-failure.c                        |   2 +
 mm/slab_common.c                           |   1 -
 mm/vmscan.c                                | 142 ++++++---
 net/sunrpc/auth.c                          |  45 ++-
 54 files changed, 2091 insertions(+), 836 deletions(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 lib/list_lru.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
