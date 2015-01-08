Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED8A6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:53:37 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so11059960pac.8
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:53:37 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ue3si7961684pab.125.2015.01.08.02.53.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 0/9] Per memcg slab shrinkers
Date: Thu, 8 Jan 2015 13:53:10 +0300
Message-ID: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Kmem accounting of memcg is unusable now, because it lacks slab shrinker
support. That means when we hit the limit we will get ENOMEM w/o any
chance to recover. What we should do then is to call shrink_slab, which
would reclaim old inode/dentry caches from this cgroup. This is what
this patch set is intended to do.

Basically, it does two things. First, it introduces the notion of
per-memcg slab shrinker. A shrinker that wants to reclaim objects per
cgroup should mark itself as SHRINKER_MEMCG_AWARE. Then it will be
passed the memory cgroup to scan from in shrink_control->memcg. For such
shrinkers shrink_slab iterates over the whole cgroup subtree under the
target cgroup and calls the shrinker for each kmem-active memory cgroup.

Secondly, this patch set makes the list_lru structure per-memcg. It's
done transparently to list_lru users - everything they have to do is to
tell list_lru_init that they want memcg-aware list_lru. Then the
list_lru will automatically distribute objects among per-memcg lists
basing on which cgroup the object is accounted to. This way to make FS
shrinkers (icache, dcache) memcg-aware we only need to make them use
memcg-aware list_lru, and this is what this patch set does.

As before, this patch set only enables per-memcg kmem reclaim when the
pressure goes from memory.limit, not from memory.kmem.limit. Handling
memory.kmem.limit is going to be tricky due to GFP_NOFS allocations, and
it is still unclear whether we will have this knob in the unified
hierarchy.

Changes in v3:
 - Removed extra walk over all memory cgroups for shrinking per memcg
   slab caches; shrink_slab is now called per memcg from the loop in
   shrink_zone, as suggested by Johannes
 - Reworked list_lru per memcg arrays init/destroy/update functions,
   hopefully making them more readable
 - Rebased on top of v3.19-rc3-mmotm-2015-01-07-17-07

v2: https://lkml.org/lkml/2014/10/24/219
v1: https://lkml.org/lkml/2014/9/21/64

The patch set is organized as follows:

 - Patches 1-3 implement per-memcg shrinker core with patches 1 and 2
   preparing list_lru users for upcoming changes and patch 3 tuning
   shrink_slab.

 - Patches 4 and 5 cleanup handling of max memcg_cache_id in the memcg
   core.

 - Patch 6 gets rid of the useless list_lru->active_nodes, and patch 7
   links all list_lrus to a list, which is required by memcg.

 - Patch 8 adds per-memcg lrus to the list_lru structure, and finally
   patch 9 marks fs shrinkers as memcg aware.

Thanks,

Vladimir Davydov (9):
  list_lru: introduce list_lru_shrink_{count,walk}
  fs: consolidate {nr,free}_cached_objects args in shrink_control
  vmscan: per memory cgroup slab shrinkers
  memcg: rename some cache id related variables
  memcg: add rwsem to synchronize against memcg_caches arrays
    relocation
  list_lru: get rid of ->active_nodes
  list_lru: organize all list_lrus to list
  list_lru: introduce per-memcg lists
  fs: make shrinker memcg aware

 fs/dcache.c                |   14 +-
 fs/drop_caches.c           |   14 --
 fs/gfs2/quota.c            |    6 +-
 fs/inode.c                 |    7 +-
 fs/internal.h              |    7 +-
 fs/super.c                 |   44 +++--
 fs/xfs/xfs_buf.c           |    7 +-
 fs/xfs/xfs_qm.c            |    7 +-
 fs/xfs/xfs_super.c         |    7 +-
 include/linux/fs.h         |    6 +-
 include/linux/list_lru.h   |   70 ++++++--
 include/linux/memcontrol.h |   37 +++-
 include/linux/mm.h         |    5 +-
 include/linux/shrinker.h   |    6 +-
 mm/list_lru.c              |  412 +++++++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c            |   68 +++++---
 mm/memory-failure.c        |   11 +-
 mm/slab_common.c           |   13 +-
 mm/vmscan.c                |   86 ++++++---
 mm/workingset.c            |    6 +-
 20 files changed, 657 insertions(+), 176 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
