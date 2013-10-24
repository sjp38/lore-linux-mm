Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 69F166B00DC
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:13 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so2328466pdj.35
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id a10si1736994pac.337.2013.10.24.05.05.11
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:12 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 00/15] kmemcg shrinkers
Date: Thu, 24 Oct 2013 16:04:51 +0400
Message-ID: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patchset implements targeted shrinking for memcg when kmem limits are
present. So far, we've been accounting kernel objects but failing allocations
when short of memory. This is because our only option would be to call the
global shrinker, depleting objects from all caches and breaking isolation.

The main idea is to associate per-memcg lists with each of the LRUs. The main
LRU still provides a single entry point and when adding or removing an element
from the LRU, we use the page information to figure out which memcg it belongs
to and relay it to the right list.

The bulk of the code is written by Glauber Costa. The only change I introduced
myself in this iteration is reworking per-memcg LRU lists. Instead of extending
the existing list_lru structure, which seems to be neat as is, I introduced a
new one, memcg_list_lru, which aggregates list_lru objects for each kmem-active
memcg and keeps them uptodate as memcgs are created/destroyed. I hope this
simplified call paths and made the code easier to read.

The patchset is based on top of Linux 3.12-rc6.

Any comments and proposals are appreciated.

== Known issues ==

 * In case kmem limit is less than sum mem limit, reaching memcg kmem limit
   will result in an attempt to shrink all memcg slabs (see
   try_to_free_mem_cgroup_kmem()). Although this is better than simply failing
   allocation as it works now, it is still to be improved.

 * Since FS shrinkers can't be executed on __GFP_FS allocations, such
   allocations will fail if memcg kmem limit is less than sum mem limit and the
   memcg kmem usage is close to its limit. Glauber proposed to schedule a
   worker which would shrink kmem in the background on such allocations.
   However, this approach does not eliminate failures completely, it just makes
   them rarer. I'm thinking on implementing soft limits for memcg kmem so that
   striking the soft limit will trigger the reclaimer, but won't fail the
   allocation. I would appreciate any other proposals on how this can be fixed.

 * Only dcache and icache are reclaimed on memcg pressure. Other FS objects are
   left for global pressure only. However, it should not be a serious problem
   to make them reclaimable too by passing on memcg to the FS-layer and letting
   each FS decide if its internal objects are shrinkable on memcg pressure.

== Changes from v10 ==

 * Rework per-memcg list_lru infrastructure.

Previous iteration (with full changelog) can be found here:

http://www.spinics.net/lists/linux-fsdevel/msg66632.html

Glauber Costa (12):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id
  vmscan: also shrink slab in memcg pressure
  memcg: move initialization to memcg creation
  memcg: move stop and resume accounting functions
  memcg: per-memcg kmem shrinking
  memcg: scan cache objects hierarchically
  vmscan: take at least one pass with shrinkers
  memcg: allow kmem limit to be resized down
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure
  memcg: flush memcg items upon memcg destruction

Vladimir Davydov (3):
  memcg,list_lru: add per-memcg LRU list infrastructure
  memcg,list_lru: add function walking over all lists of a per-memcg
    LRU
  super: make icache, dcache shrinkers memcg-aware

 fs/dcache.c                |   25 +-
 fs/inode.c                 |   16 +-
 fs/internal.h              |    9 +-
 fs/super.c                 |   47 +--
 include/linux/fs.h         |    4 +-
 include/linux/list_lru.h   |   77 +++++
 include/linux/memcontrol.h |   23 ++
 include/linux/shrinker.h   |    6 +-
 include/linux/swap.h       |    2 +
 include/linux/vmpressure.h |    5 +
 mm/memcontrol.c            |  704 +++++++++++++++++++++++++++++++++++++++-----
 mm/vmpressure.c            |   53 +++-
 mm/vmscan.c                |  178 +++++++++--
 13 files changed, 1014 insertions(+), 135 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
