Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F22EE6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:13:23 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so24482889pab.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:13:23 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id lk8si5594924pab.151.2015.01.16.06.13.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:13:22 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/6] memcg: release kmemcg_id on css offline
Date: Fri, 16 Jan 2015 17:13:00 +0300
Message-ID: <cover.1421411660.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

There's one thing about kmemcg implementation that's bothering me. It's
about arrays holding per-memcg data (e.g. kmem_cache->memcg_params->
memcg_caches). On kmalloc or list_lru_{add,del} we want to quickly
lookup the copy of kmem_cache or list_lru corresponding to the current
cgroup. Currently, we hold all per-memcg caches/lists in an array
indexed by mem_cgroup->kmemcg_id. This allows us to lookup quickly, and
that's nice, but the arrays can grow indefinitely, because we reserve
slots for all cgroups, including offlined, and this is disastrous and
must be fixed.

There are several ways to fix this issue [1], but it seems the best we
can do is to free kmemcg_id on css offline (solution #2). The idea is
that we actually only need kmemcg_id on kmem cache allocations, in order
to lookup the kmem cache copy corresponding to the allocating memory
cgroup, while it is never used of kmem frees. We do rely on kmemcg_id
being unique for each cgroup in some places, but they are easy to fix.
And regarding per memcg list_lru, which are indexed by kmemcg_id, we can
easily reparent them - it is as simple as splicing lists. This patch set
therefore implements this approach.

It is organized as follows:
 - Currently, sl[AU]b core relies on kmemcg_id being unique per
   kmem_cache. Patches 1-3 fix that.
 - Patch 4 makes memcg_cache_params->memcg_caches entries released on
   css offline.
 - Patch 5 alters the list_lru API a bit to facilitate reparenting.
 - Patch 6 implements per memcg list_lru reparenting on css offline.
   After list_lrus have been reparented, there's no need to keep
   kmemcg_id any more, so we can free it on css offline.

[1] https://lkml.org/lkml/2015/1/13/107

Thanks,

Vladimir Davydov (6):
  slab: embed memcg_cache_params to kmem_cache
  slab: link memcg caches of the same kind into a list
  slab: use css id for naming per memcg caches
  memcg: free memcg_caches slot on css offline
  list_lru: add helpers to isolate items
  memcg: reparent list_lrus and free kmemcg_id on css offline

 fs/dcache.c              |   21 +++---
 fs/gfs2/quota.c          |    5 +-
 fs/inode.c               |    8 +--
 fs/xfs/xfs_buf.c         |    6 +-
 fs/xfs/xfs_qm.c          |    5 +-
 include/linux/list_lru.h |   12 +++-
 include/linux/slab.h     |   31 +++++----
 include/linux/slab_def.h |    2 +-
 include/linux/slub_def.h |    2 +-
 mm/list_lru.c            |   65 ++++++++++++++++--
 mm/memcontrol.c          |   86 ++++++++++++++++++-----
 mm/slab.c                |   13 ++--
 mm/slab.h                |   65 +++++++++++-------
 mm/slab_common.c         |  172 +++++++++++++++++++++++++++-------------------
 mm/slub.c                |   24 +++----
 mm/workingset.c          |    3 +-
 16 files changed, 336 insertions(+), 184 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
