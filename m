Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id EA2816B0035
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:07 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id ep20so1269096lab.6
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:07 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y7si3282441lal.44.2013.12.09.00.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:06 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 00/16] kmemcg shrinkers
Date: Mon, 9 Dec 2013 12:05:41 +0400
Message-ID: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com

Hi,

This is the 13th iteration of Glauber Costa's patch-set implementing slab
shrinking on memcg pressure. The main idea is to make the list_lru structure
used by most FS shrinkers per-memcg. When adding or removing an element from a
list_lru, we use the page information to figure out which memcg it belongs to
and relay it to the appropriate list. This allows scanning kmem objects
accounted to different memcgs independently.

Please note that in contrast to previous versions this patch-set implements
slab shrinking only when we hit the user memory limit so that kmem allocations
will still fail if we are below the user memory limit, but close to the kmem
limit. This is, because the implementation of kmem-only reclaim was rather
incomplete - we had to fail GFP_NOFS allocations since everything we could
reclaim was only FS data. I will try to improve this and send in a separate
patch-set, but currently it is only worthwhile setting the kmem limit to be
greater than the user mem limit just to enable per-memcg slab accounting and
reclaim.

The patch-set is based on top of Linux-3.13-rc3 and organized as follows:
 - patches 1-9 prepare vmscan, memcontrol, list_lru to kmemcg reclaim;
 - patch 10 implements the kmemcg reclaim core;
 - patch 11 makes the list_lru struct per-memcg and patch 12 marks all
   list_lru-based shrinkers as memcg-aware;
 - patches 13-16 slightly improve memcontrol behavior regarding mem reclaim.

Changes in v13:
 - fix NUMA-unaware shrinkers not being called when node 0 is not set in the
   nodemask;
 - rework list_lru API to require a shrink_control
 - make list_lru automatically handle memcgs w/o introducing a separate struct;
 - simplify walk over all memcg LRUs of a list_lru;
 - cleanup shrink_slab()
 - remove kmem-only reclaim as explained above;

Previous iterations of this patch-set can be found here:
 - https://lkml.org/lkml/2013/12/2/141
 - https://lkml.org/lkml/2013/11/25/214

Thanks.

Glauber Costa (7):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id
  memcg: move initialization to memcg creation
  vmscan: take at least one pass with shrinkers
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure
  memcg: flush memcg items upon memcg destruction

Vladimir Davydov (9):
  memcg: move memcg_caches_array_size() function
  vmscan: move call to shrink_slab() to shrink_zones()
  vmscan: remove shrink_control arg from do_try_to_free_pages()
  vmscan: call NUMA-unaware shrinkers irrespective of nodemask
  mm: list_lru: require shrink_control in count, walk functions
  fs: consolidate {nr,free}_cached_objects args in shrink_control
  vmscan: shrink slab on memcg pressure
  mm: list_lru: add per-memcg lists
  fs: mark list_lru based shrinkers memcg aware

 fs/dcache.c                |   17 +-
 fs/gfs2/quota.c            |   10 +-
 fs/inode.c                 |    8 +-
 fs/internal.h              |    9 +-
 fs/super.c                 |   24 ++-
 fs/xfs/xfs_buf.c           |   16 +-
 fs/xfs/xfs_qm.c            |    8 +-
 fs/xfs/xfs_super.c         |    6 +-
 include/linux/fs.h         |    6 +-
 include/linux/list_lru.h   |   83 ++++++----
 include/linux/memcontrol.h |   35 ++++
 include/linux/shrinker.h   |   10 +-
 include/linux/vmpressure.h |    5 +
 mm/list_lru.c              |  263 +++++++++++++++++++++++++++---
 mm/memcontrol.c            |  384 +++++++++++++++++++++++++++++++++++++++-----
 mm/vmpressure.c            |   53 +++++-
 mm/vmscan.c                |  172 +++++++++++++-------
 17 files changed, 888 insertions(+), 221 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
