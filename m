Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 807D26B0038
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:51:19 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so1010317lbv.7
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:51:18 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o8si5615404lal.3.2014.05.30.06.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 06:51:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/8] memcg/slab: reintroduce dead cache self-destruction
Date: Fri, 30 May 2014 17:51:03 +0400
Message-ID: <cover.1401457502.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

When a memcg is turned offline, some of its kmem caches can still have
active objects and therefore cannot be destroyed immediately. Currently,
we simply leak such caches along with the owner memcg, which is bad and
should be resolved.

It would be perfect if we could move all slab pages of such dead caches
to the root/parent cache on memcg offline. However, when I tried to
implement such re-parenting, I was pointed out by Christoph that the
overhead of this would be unacceptable, at least for SLUB (see
https://lkml.org/lkml/2014/5/13/446)

The problem with re-parenting of individual slabs is that it requires
tracking of all slabs allocated to a cache, but SLUB doesn't track full
slabs if !debug. Changing this behavior would result in significant
performance degradation of regular alloc/free paths, because it would
make alloc/free take per node list locks more often.

After pondering about this problem for some time, I think we should
return to dead caches self-destruction, i.e. scheduling cache
destruction work when the last slab page is freed.

This is the behavior we had before commit 5bd93da9917f ("memcg, slab:
simplify synchronization scheme"). The reason why it was removed was that
it simply didn't work, because SL[AU]B are implemented in such a way
that they don't discard empty slabs immediately, but prefer keeping them
cached for indefinite time to speed up further allocations.

However, we can change this w/o noticeable performance impact for both
SLAB and SLUB. For SLAB, we can make internal cache reaper shrink dead
caches aggressively so that they will die quickly after the last object
is freed. For SLUB, we can make free path drop free slabs as soon as
they become empty. Since dead caches should never be allocated from,
removing empty slabs from them shouldn't degrade performance.

So, this patch set reintroduces dead cache self-destruction and adds
some tweaks to SL[AU]B to prevent dead caches from hanging around
indefinitely. It is organized as follows:

 - patches 1-3 reintroduce dead memcg cache self-destruction;
 - patches 4-5 do some cleanup in kmem_cache_shrink;
 - patch 6 is a minor optimization for SLUB, which makes the following
   work a bit easier for me;
 - patches 7 and 8 solves the problem with dead memcg caches for SLUB
   and SLAB respectively.

Even if the whole approach is NAK'ed, patches 4, 5, and 6 are worth
applying, IMO, provided Christoph doesn't mind, of course. They don't
depend on the rest of the set, BTW.

Note, this doesn't resolve the problem of memcgs pinned by dead kmem
caches. I'm planning to solve this by re-parenting dead kmem caches to
the parent memcg.

Thanks,

Vladimir Davydov (8):
  memcg: cleanup memcg_cache_params refcnt usage
  memcg: destroy kmem caches when last slab is freed
  memcg: mark caches that belong to offline memcgs as dead
  slub: never fail kmem_cache_shrink
  slab: remove kmem_cache_shrink retval
  slub: do not use cmpxchg for adding cpu partials when irqs disabled
  slub: make dead caches discard free slabs immediately
  slab: reap dead memcg caches aggressively

 include/linux/slab.h |   10 ++-
 mm/memcontrol.c      |   25 +++++-
 mm/slab.c            |   28 +++++--
 mm/slab.h            |   12 ++-
 mm/slab_common.c     |    8 +-
 mm/slob.c            |    3 +-
 mm/slub.c            |  212 ++++++++++++++++++++++++++++++++++----------------
 7 files changed, 207 insertions(+), 91 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
