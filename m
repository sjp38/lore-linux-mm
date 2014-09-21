Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EE4D96B0036
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:10 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so1982564pac.17
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:10 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gz11si12008126pbd.58.2014.09.21.08.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:09 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 00/14] Per memcg slab shrinkers
Date: Sun, 21 Sep 2014 19:14:32 +0400
Message-ID: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

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

The main difference of this patch set from my previous attempts to push
memcg aware shrinkers is in how it handles css offline. Now we don't let
list_lrus corresponding to dead memory cgroups hang around till all
objects are freed. Instead we move lru items to the parent cgroup's lru
list. This is really important, because this allows us to release
memcg_cache_id used for indexing in per-memcg arrays. If we don't do
this, the arrays will grow uncontrollably, which is really bad. Note, in
comparison to user memory reparenting, which Johannes is going to get
rid of, it's not racy and much easier to implement although it does
impose some limitations on how list_lru locking can be implemented.
Another difference is that it doesn't reparent charges, only list_lru
entries - the css will be dangling until the last kmem object is freed.

As before, this patch set only enables per-memcg kmem reclaim when the
pressure goes from memory.limit, not from memory.kmem.limit. Handling
memory.kmem.limit is going to be tricky due to GFP_NOFS allocations, it
will probably require a sort of soft limit to work properly. I'm leaving
this for future work.

The patch set basically consists of three main parts and organized as
follows:

 - Patches 1-3 implement per-memcg shrinker core with patches 1 and 2
   preparing list_lru users for upcoming changes and patch 3 tuning
   shrink_slab.

 - Patches 4-10 make memcg core release cache ids on offline doing a bit
   of cleanup in the meanwhile. This is easy, because kmem_caches don't
   need the cache id after css offline since there can't be allocations
   going from a dead memcg. Note that most of these patches (namely 4-6,
   and 8) were once merged, but then I decided to drop them, because I
   didn't know how to deal with list_lrus at that time (see
   https://lkml.org/lkml/2014/7/23/218).

 - Finally patches 11-14 make list_lru per-memcg and mark FS shrinkers
   as memcg-aware. This is the most difficult part of this patch set
   with patch 13 (unlucky :-) doing the most important work.

Reviews are more than welcome.

Thanks,

Vladimir Davydov (14):
  list_lru: introduce list_lru_shrink_{count,walk}
  fs: consolidate {nr,free}_cached_objects args in shrink_control
  vmscan: shrink slab on memcg pressure
  memcg: use mem_cgroup_id for per memcg cache naming
  memcg: add pointer to owner cache to memcg_cache_params
  memcg: keep all children of each root cache on a list
  memcg: update memcg_caches array entries on the slab side
  memcg: release memcg_cache_id on css offline
  memcg: rename some cache id related variables
  memcg: add rwsem to sync against memcg_caches arrays relocation
  list_lru: get rid of ->active_nodes
  list_lru: organize all list_lrus to list
  list_lru: introduce per-memcg lists
  fs: make shrinker memcg aware

 fs/dcache.c                |   14 +-
 fs/gfs2/main.c             |    2 +-
 fs/gfs2/quota.c            |    6 +-
 fs/inode.c                 |    7 +-
 fs/internal.h              |    7 +-
 fs/super.c                 |   36 ++--
 fs/xfs/xfs_buf.c           |    9 +-
 fs/xfs/xfs_qm.c            |    9 +-
 fs/xfs/xfs_super.c         |    7 +-
 include/linux/fs.h         |    6 +-
 include/linux/list_lru.h   |   85 +++++----
 include/linux/memcontrol.h |   60 ++++--
 include/linux/shrinker.h   |   10 +-
 include/linux/slab.h       |    5 +-
 mm/list_lru.c              |  434 +++++++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c            |  254 +++++++++++++++++++-------
 mm/slab.c                  |   40 ++--
 mm/slab.h                  |   27 ++-
 mm/slab_common.c           |   65 +++----
 mm/slub.c                  |   41 +++--
 mm/vmscan.c                |   87 +++++++--
 mm/workingset.c            |    9 +-
 22 files changed, 925 insertions(+), 295 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
