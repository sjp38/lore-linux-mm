Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF116B005A
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:19:56 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id n7so8193952lam.35
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:19:55 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si20083532lby.52.2013.12.02.03.19.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:19:55 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 00/18] kmemcg shrinkers
Date: Mon, 2 Dec 2013 15:19:35 +0400
Message-ID: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com

Hi,

This is the 12th iteration of Glauber Costa's patchset implementing targeted
shrinking for memory cgroups when kmem limits are present. So far, we've been
accounting kernel objects but failing allocations when short of memory. This is
because our only option would be to call the global shrinker, depleting objects
from all caches and breaking isolation.

The main idea is to make LRU lists used by FS slab shrinkers per-memcg. When
adding or removing an element from from the LRU, we use the page information to
figure out which memory cgroup it belongs to and relay it to the appropriate
list. This allows scanning kmem objects accounted to different memory cgroups
independently.

The patchset is based on top of Linux 3.13-rc2 and organized as follows:

 * patches 1-8 are for cleanup/preparation;
 * patch 9 introduces infrastructure for memcg-aware shrinkers;
 * patches 10 and 11 implement the per-memcg LRU list structure;
 * patch 12 uses per-memcg LRU lists to make dcache and icache shrinkers
   memcg-aware;
 * patch 13 implements kmem-only shrinking;
 * patches 14-18 issue kmem shrinking on limit resize, global pressure.

Known issues:

 * Since FS shrinkers can't be executed on __GFP_FS allocations, such
   allocations will fail if memcg kmem limit is less than the user limit and
   the memcg kmem usage is close to its limit. Glauber proposed to schedule a
   worker which would shrink kmem in the background on such allocations.
   However, this approach does not eliminate failures completely, it just makes
   them rarer. I'm thinking on implementing soft limits for memcg kmem so that
   striking the soft limit will trigger the reclaimer, but won't fail the
   allocation. I would appreciate any other proposals on how this can be fixed.

 * Only dcache and icache are reclaimed on memcg pressure. Other FS objects are
   left for global pressure only. However, it should not be a serious problem
   to make them reclaimable too by passing on memcg to the FS-layer and letting
   each FS decide if its internal objects are shrinkable on memcg pressure.

Changelog:

Changes in v12:
 * Do not prune all slabs on kmem-only pressure.
 * Count all on-LRU pages eligible for reclaim to pass to shrink_slab().
 * Fix isolation issue due to using shrinker->nr_deferred on memcg pressure.
 * Add comments to memcg_list_lru functions.
 * Code cleanup/refactoring.

Changes in v11:
 * Rework per-memcg list_lru infrastructure.

Glauber Costa (7):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id
  memcg: move initialization to memcg creation
  memcg: allow kmem limit to be resized down
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure
  memcg: flush memcg items upon memcg destruction

Vladimir Davydov (11):
  memcg: move several kmemcg functions upper
  fs: do not use destroy_super() in alloc_super() fail path
  vmscan: rename shrink_slab() args to make it more generic
  vmscan: move call to shrink_slab() to shrink_zones()
  vmscan: do_try_to_free_pages(): remove shrink_control argument
  vmscan: shrink slab on memcg pressure
  memcg,list_lru: add per-memcg LRU list infrastructure
  memcg,list_lru: add function walking over all lists of a per-memcg
    LRU
  fs: make icache, dcache shrinkers memcg-aware
  memcg: per-memcg kmem shrinking
  vmscan: take at least one pass with shrinkers

 fs/dcache.c                   |   25 +-
 fs/inode.c                    |   16 +-
 fs/internal.h                 |    9 +-
 fs/super.c                    |   48 ++-
 include/linux/fs.h            |    4 +-
 include/linux/list_lru.h      |   83 +++++
 include/linux/memcontrol.h    |   22 ++
 include/linux/mm.h            |    3 +-
 include/linux/shrinker.h      |   10 +-
 include/linux/swap.h          |    2 +
 include/linux/vmpressure.h    |    5 +
 include/trace/events/vmscan.h |   20 +-
 mm/memcontrol.c               |  728 ++++++++++++++++++++++++++++++++++++-----
 mm/vmpressure.c               |   53 ++-
 mm/vmscan.c                   |  249 +++++++++-----
 15 files changed, 1054 insertions(+), 223 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
