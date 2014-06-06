Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 808856B0038
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:53 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so1499115lab.26
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:52 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ji9si21314720lbc.48.2014.06.06.06.22.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:51 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 0/8] memcg/slab: reintroduce dead cache self-destruction
Date: Fri, 6 Jun 2014 17:22:37 +0400
Message-ID: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
SLAB and SLUB by making them drop free slabs as soon as they become
empty. Since dead caches should never be allocated from, removing empty
slabs from them shouldn't result in noticeable performance degradation.

So, this patch set reintroduces dead cache self-destruction and adds
some tweaks to SL[AU]B to prevent dead caches from hanging around
indefinitely. It is organized as follows:

 - patches 1-3 reintroduce dead memcg cache self-destruction;
 - patch 4 makes SLUB's version of kmem_cache_shrink always drop empty
   slabs, even if it fails to allocate a temporary array;
 - patches 5 and 6 fix possible use-after-free connected with
   asynchronous cache destruction;
 - patches 7 and 8 disable caching of empty slabs for dead memcg caches
   for SLUB and SLAB respectively.

Note, this doesn't resolve the problem of memcgs pinned by dead kmem
caches. I'm planning to solve this by re-parenting dead kmem caches to
the parent memcg.

v2:
 - fix use-after-free connected with asynchronous cache destruction;
 - less intrusive version of SLUB's kmem_cache_shrink fix;
 - simplify disabling of free slabs caching for SLUB (Joonsoo);
 - disable free slabs caching instead of using cache_reap for SLAB
   (Christoph).

v1: https://lkml.org/lkml/2014/5/30/264

Thanks,

Vladimir Davydov (8):
  memcg: cleanup memcg_cache_params refcnt usage
  memcg: destroy kmem caches when last slab is freed
  memcg: mark caches that belong to offline memcgs as dead
  slub: don't fail kmem_cache_shrink if slab placement optimization
    fails
  slub: make slab_free non-preemptable
  memcg: wait for kfree's to finish before destroying cache
  slub: make dead memcg caches discard free slabs immediately
  slab: make dead memcg caches discard free slabs immediately

 include/linux/slab.h |   14 +++++----
 mm/memcontrol.c      |   57 +++++++++++++++++++++++++++++++---
 mm/slab.c            |   83 +++++++++++++++++++++++++++++++++++++-------------
 mm/slab.h            |   10 ++++++
 mm/slub.c            |   49 +++++++++++++++++++++--------
 5 files changed, 170 insertions(+), 43 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
