Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BCD926B00F2
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:07 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so12294672pdj.0
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yl3si16117128pbb.152.2014.11.03.13.00.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:06 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/8] memcg: reuse per cgroup kmem caches
Date: Mon, 3 Nov 2014 23:59:38 +0300
Message-ID: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Currently, each kmem active memory cgroup has its own set of kmem
caches. The caches are only used by the memory cgroup they were created
for, so when the cgroup is taken offline they must be destroyed.
However, we can't easily destroy all the caches on css offline, because
they still may contain objects accounted to the cgroup. Actually, we
don't bother destroying busy caches on css offline at all, effectively
leaking them. To make this scheme work as it was intended to, we have to
introduce a kind of asynchronous caches destruction, which is going to
be quite a complex stuff, because we'd have to handle a lot of various
race conditions. And even if we manage to solve them all, kmem caches
created for memory cgroups that are now dead will be dangling
indefinitely long wasting memory.

In this patch set I implement a different approach, which can be
described by the following statements:

 1. Never destroy per memcg kmem caches (except the root cache is
    destroyed, of course).

 2. Reuse kmemcg_id and therefore the set of per memcg kmem caches left
    from a dead memory cgroup.

 3. After allocating a kmem object, check if the slab is accounted to
    the proper (i.e. current) memory cgroup. If it doesn't recharge it.

The benefits are:

 - It's much simpler than what we have now, even though the current
   implementation is incomplete.

 - The number of per cgroup caches of the same kind cannot be be greater
   than the maximal number of online kmem active memory cgroups that
   have ever existed simultaneously. Currently it is unlimited, which is
   really bad.

 - Once a new memory cgroup starts using a cache that was used by a dead
   cgroup before, it will be recharging slabs accounted to the dead
   cgroup while allocating objects from the cache. Therefore all
   references to the old cgroup will be put sooner or later, and it will
   be freed. Currently, cgroups that have kmem objects accounted to them
   on css offline leak for good.

This patch set is based on v3.18-rc2-mmotm-2014-10-29-14-19 with the
following patches by Johannes applied on top:

[patch] mm: memcontrol: remove stale page_cgroup_lock comment
[patch 1/3] mm: embed the memcg pointer directly into struct page
[patch 2/3] mm: page_cgroup: rename file to mm/swap_cgroup.c
[patch 3/3] mm: move page->mem_cgroup bad page handling into generic code

Thanks,

Vladimir Davydov (8):
  memcg: do not destroy kmem caches on css offline
  slab: charge slab pages to the current memory cgroup
  memcg: decouple per memcg kmem cache from the owner memcg
  memcg: zap memcg_{un}register_cache
  memcg: free kmem cache id on css offline
  memcg: introduce memcg_kmem_should_charge helper
  slab: introduce slab_free helper
  slab: recharge slab pages to the allocating memory cgroup

 include/linux/memcontrol.h |   63 ++++++-----
 include/linux/slab.h       |   12 +-
 mm/memcontrol.c            |  260 ++++++++++++++------------------------------
 mm/slab.c                  |   62 +++++++----
 mm/slab.h                  |   28 -----
 mm/slab_common.c           |   66 ++++++++---
 mm/slub.c                  |   26 +++--
 7 files changed, 228 insertions(+), 289 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
