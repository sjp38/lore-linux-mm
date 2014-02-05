Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9445B6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:36 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id z5so629759lbh.8
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:35 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q5si175119lbr.176.2014.02.05.10.39.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:34 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 00/13] kmemcg shrinkers
Date: Wed, 5 Feb 2014 22:39:16 +0400
Message-ID: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

This is the 15th iteration of Glauber Costa's patch-set implementing slab
shrinking on memcg pressure. The main idea is to make the list_lru structure
used by most FS shrinkers per-memcg. When adding or removing an element from a
list_lru, we use the page information to figure out which memcg it belongs to
and relay it to the appropriate list. This allows scanning kmem objects
accounted to different memcgs independently.

Please note that this patch-set implements slab shrinking only when we hit the
user memory limit so that kmem allocations will still fail if we are below the
user memory limit, but close to the kmem limit. I am going to fix this in a
separate patch-set, but currently it is only worthwhile setting the kmem limit
to be greater than the user mem limit just to enable per-memcg slab accounting
and reclaim.

The patch-set is based on top of v3.14-rc1-mmots-2014-02-04-16-48 (there are
some vmscan cleanups that I need committed there) and organized as follows:
 - patches 1-4 introduce some minor changes to memcg needed for this set;
 - patches 5-7 prepare fs for per-memcg list_lru;
 - patch 8 implement kmemcg reclaim core;
 - patch 9 make list_lru per-memcg and patch 10 marks sb shrinker memcg-aware;
 - patch 10 is trivial - it issues shrinkers on memcg destruction;
 - patches 12 and 13 introduce shrinking of dead kmem caches to facilitate
   memcg destruction.

Changes in v15:
 - remove patches that have been merged to -mm;
 - fix memory barrier usage in per-memcg list_lru implementation;
 - fix list_lru_destroy(), which might sleep for per-memcg lrus, called from
   atomic context (__put_super()).

Previous iterations of this patch-set can be found here:
 - https://lkml.org/lkml/2013/12/16/206 (v14)
 - https://lkml.org/lkml/2013/12/9/103 (v13)
 - https://lkml.org/lkml/2013/12/2/141 (v12)
 - https://lkml.org/lkml/2013/11/25/214 (v11)

Comments are highly appreciated.

Thanks.

Glauber Costa (6):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id
  memcg: move initialization to memcg creation
  memcg: flush memcg items upon memcg destruction
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure

Vladimir Davydov (7):
  memcg: make for_each_mem_cgroup macros public
  list_lru, shrinkers: introduce list_lru_shrink_{count,walk}
  fs: consolidate {nr,free}_cached_objects args in shrink_control
  fs: do not call destroy_super() in atomic context
  vmscan: shrink slab on memcg pressure
  list_lru: add per-memcg lists
  fs: make shrinker memcg aware

 fs/dcache.c                |   14 +-
 fs/gfs2/quota.c            |    6 +-
 fs/inode.c                 |    7 +-
 fs/internal.h              |    7 +-
 fs/super.c                 |   44 ++---
 fs/xfs/xfs_buf.c           |    7 +-
 fs/xfs/xfs_qm.c            |    7 +-
 fs/xfs/xfs_super.c         |    7 +-
 include/linux/fs.h         |    8 +-
 include/linux/list_lru.h   |  112 ++++++++++---
 include/linux/memcontrol.h |   50 ++++++
 include/linux/shrinker.h   |   10 +-
 include/linux/vmpressure.h |    5 +
 mm/list_lru.c              |  271 +++++++++++++++++++++++++++---
 mm/memcontrol.c            |  399 ++++++++++++++++++++++++++++++++++++++------
 mm/vmpressure.c            |   53 +++++-
 mm/vmscan.c                |   94 ++++++++---
 17 files changed, 926 insertions(+), 175 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
