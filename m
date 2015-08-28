Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD576B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:32:48 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so73235419pab.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:32:48 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yg10si11684896pbc.222.2015.08.28.13.32.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 13:32:47 -0700 (PDT)
Date: Fri, 28 Aug 2015 23:32:31 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828203231.GL9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
 <20150828164819.GL26785@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828164819.GL26785@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Fri, Aug 28, 2015 at 12:48:19PM -0400, Tejun Heo wrote:
...
> > > * If the allocation doesn't have __GFP_WAIT, direct reclaim is
> > >   skipped.  If a process performs only speculative allocations, it can
> > >   blow way past the high limit.  This is actually easily reproducible
> > >   by simply doing "find /".  VFS tries speculative !__GFP_WAIT
> > >   allocations first, so as long as there's memory which can be
> > >   consumed without blocking, it can keep allocating memory regardless
> > >   of the high limit.
> > 
> > I think there shouldn't normally occur a lot of !__GFP_WAIT allocations
> > in a row - they should still alternate with normal __GFP_WAIT
> > allocations. Yes, that means we can breach memory.high threshold for a
> > short period of time, but it isn't a hard limit, so it looks perfectly
> > fine to me.
> > 
> > I tried to run `find /` over ext4 in a cgroup with memory.high set to
> > 32M and kmem accounting enabled. With such a setup memory.current never
> > got higher than 33152K, which is only 384K greater than the memory.high.
> > Which FS did you use?
> 
> ext4.  Here, it goes onto happily consuming hundreds of megabytes with
> limit set at 32M.  We have quite a few places where !__GFP_WAIT
> allocations are performed speculatively in hot paths with fallback
> slow paths, so this is bound to happen somewhere.

What kind of workload should it be then? `find` will constantly invoke
d_alloc, which issues a GFP_KERNEL allocation and therefore is allowed
to perform reclaim...

OK, I tried to reproduce the issue on the latest mainline kernel and ...
succeeded - memory.current did occasionally jump up to ~55M although
memory.high was set to 32M. Hmm, strange... Started to investigate.
Printed stack traces and found that we don't invoke memcg reclaim on
normal GFP_KERNEL allocations! How is that? The thing is there was a
commit that made SLUB (not VFS or any other kmem user, but core SLUB)
try to allocate high order slab pages w/o __GFP_WAIT for performance
reasons. That broke kmemcg case. Here it goes:

commit 6af3142bed1f520b90f4cdb6cd10bbd16906ce9a
Author: Joonsoo Kim <js1304@gmail.com>
Date:   Tue Aug 25 00:03:52 2015 +0000

    mm/slub: don't wait for high-order page allocation

I suspect your kernel has this commit included, because w/o it I haven't
managed to catch anything nearly as bad as you describe: the memory.high
excess reached 1-2 Mb at max, but never "hundreds of megabytes". If so,
we'd better fix that instead. Actually, it's worth fixing anyway. What
about the patch below?
---
From: Vladimir Davydov <vdavydov@parallels.com>
Date: Fri, 28 Aug 2015 23:17:19 +0300
Subject: [PATCH] mm/slub: don't bypass memcg reclaim for high-order page
 allocation

Commit 6af3142bed1f52 ("mm/slub: don't wait for high-order page
allocation") made allocate_slab() try to allocate high order slab pages
w/o __GFP_WAIT in order to avoid invoking reclaim/compaction when we can
fall back on low order pages. However, it broke kmemcg/memory.high
logic. The latter works as a soft limit: an allocation won't fail if it
is breached, but we call direct reclaim to compensate the excess. W/o
__GFP_WAIT we can't invoke reclaimer and therefore we will just go on,
exceeding memory.high more and more until a normal __GFP_WAIT allocation
is issued.

Since memcg reclaim never triggers compaction, we can pass __GFP_WAIT to
memcg_charge_slab() even on high order page allocations w/o any
performance impact. So let's fix this problem by excluding __GFP_WAIT
only from alloc_pages() while still forwarding it to memcg_charge_slab()
if the context allows.

Fixes: 6af3142bed1f52 ("mm/slub: don't wait for high-order page allocation")
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/mm/slub.c b/mm/slub.c
index e180f8dcd06d..1b9dbad40272 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1333,6 +1333,9 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (memcg_charge_slab(s, flags, order))
 		return NULL;
 
+	if ((flags & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
+		flags = (flags | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
+
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
@@ -1364,8 +1367,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * so we fall-back to the minimum order allocation.
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
-	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
-		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
