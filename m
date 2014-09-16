Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 45A106B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:32:24 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so8391635pab.29
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:32:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id za3si27873154pac.207.2014.09.16.01.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Sep 2014 01:31:48 -0700 (PDT)
Date: Tue, 16 Sep 2014 12:31:24 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: weak points of kmem accounting design
Message-ID: <20140916083124.GA32139@esperanza>
References: <20140915104437.GA11886@esperanza>
 <CABCjUKCkgoG07djfLEpqo0sBwgKts0iMepwNsh_RdNVTVtYH3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CABCjUKCkgoG07djfLEpqo0sBwgKts0iMepwNsh_RdNVTVtYH3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>

Hi Suleiman,

On Mon, Sep 15, 2014 at 12:13:33PM -0700, Suleiman Souhlal wrote:
> On Mon, Sep 15, 2014 at 3:44 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
> > Hi,
> >
> > I'd like to discuss downsides of the kmem accounting part of the memory
> > cgroup controller and a possible way to fix them. I'd really appreciate
> > if you could share your thoughts on it.
> >
> > The idea lying behind the kmem accounting design is to provide each
> > memory cgroup with its private copy of every kmem_cache and list_lru
> > it's going to use. This is implemented by bundling these structures with
> > arrays storing per-memcg copies. The arrays are referenced by css id.
> > When a process in a cgroup tries to allocate an object from a kmem cache
> > we first find out which cgroup the process resides in, then look up the
> > cache copy corresponding to the cgroup, and finally allocate a new
> > object from the private cache. Similarly, on addition/deletion of an
> > object from a list_lru, we first obtain the kmem cache the object was
> > allocated from, then look up the memory cgroup which the cache belongs
> > to, and finally add/remove the object from the private copy of the
> > list_lru corresponding to the cgroup.
> >
> > Though simple it looks from the first glance, it has a number of serious
> > weaknesses:
> >
> >  - Providing each memory cgroup with its own kmem cache increases
> >    external fragmentation.
> 
> I haven't seen any evidence of this being a problem (but that doesn't
> mean it doesn't exist).

Actually, it's rather speculative. For example, if we have say a hundred
of extra objects per cache (fragmented or in per-cpu stocks) of size 256
bytes, then for one cache the overhead would be 25K, which is
negligible. Now if there are thousand cgroups using the cache, we have
to pay 25M, which is noticeable. Anyway, to estimate this exactly, one
needs to run a typical workload inside a cgroup.

>
> >  - SLAB isn't ready to deal with thousands of caches: its algorithm
> >    walks over all system caches and shrinks them periodically, which may
> >    be really costly if we have thousands active memory cgroups.
> 
> This could be throttled.

It could be, but then we'd have more objects in per-cpu stocks, which
means more memory overhead.

> 
> >
> >  - Caches may now be created/destroyed frequently and from various
> >    places: on system cache destruction, on cgroup offline, from a work
> >    struct scheduled by kmalloc. Synchronizing them properly is really
> >    difficult. I've fixed some places, but it's still desperately buggy.
> 
> Agreed.
> 
> >  - It's hard to determine when we should destroy a cache that belongs to
> >    a dead memory cgroup. The point is both SLAB and SLUB implementations
> >    always keep some pages in stock for performance reasons, so just
> >    scheduling cache destruction work from kfree once the last slab page
> >    is freed isn't enough - it will normally never happen for SLUB and
> >    may take really long for SLAB. Of course, we can forbid SL[AU]B
> >    algorithm to stock pages in dead caches, but it looks ugly and has
> >    negative impact on performance (I did this, but finally decided to
> >    revert). Another approach could be scanning dead caches periodically
> >    or on memory pressure, but that would be ugly too.
> 
> Not sure about slub, but for SLAB doesn't cache_reap take care of that?

It is, but it takes some time. If we decide to throttle it, then it'll
take even longer. Anyway, SLUB has nothing like that, therefore we'd
have to handle different algorithms in different ways, which I
particularly dislike.

> 
> >
> >  - The arrays for storing per-memcg copies can get really large,
> >    especially if we finally decide to leave dead memory cgroups hanging
> >    until memory pressure reaps objects assigned to them and let them
> >    free. How can we deal with an array of, say, 20K elements? Simply
> >    allocating them with kmal^W vmalloc will result in memory wastes. It
> >    will be particularly funny if the user wants to provide each cgroup
> >    with a separate mount point: each super block will have a list_lru
> >    for every memory cgroup, but only one of them will be really used.
> >    That said we need a kind of dynamic reclaimable arrays. Radix trees
> >    would fit, but they are way slower than plain arrays, which is a
> >    no-go, because we want to look up on each kmalloc, list_lru_add/del,
> >    which are fast paths.
> 
> The initial design we had was to have an array indexed by "cache id"
> in struct memcg, instead of the current array indexed by "css id" in
> struct kmem_cache.
> The initial design doesn't have the problem you're describing here, as
> far as I can tell.

It is indexed by "cache id", not "css id", but it doesn't matter
actually. Suppose, when a cgroup is taken offline it still has kmem
objects accounted to it. Then we have to keep its "cache id" along with
the caches hosting the objects until all the objects are freed. All
caches and, what is worse, list_lru's will have to keep a spare slot for
this id then.

> 
> > The more I think about these issues the more confident I get that the
> > whole design is screwed up. So I'd like to discuss a possible
> > alternative to it.
> >
> > The alternative is dumb simple. Let's allocate objects of all memory
> > cgroups from the same cache. To determine which memory cgroup the object
> > is accounted to on kfree, a pointer to the owner memory cgroup or its
> > css id is stored with the object. For each kind of shrinkable object
> > (inodes, dentries) a separate list_lru is introduced per each memory
> > cgroup. To store inodes and dentries allocated by a memory cgroup in
> > those lists, we add an additional list_head to them.
> >
> > Obviously such an approach wouldn't be affected by any of the issues of
> > the current implementation I enumerated above, so these are the benefits
> > of it. The downsides would be:
> >
> >  - Memory wastes. Each kmalloc'ed object must have a pointer to the
> >    memory cgroup it's accounted to. Each shrinkable object must have an
> >    extra list_head with it. However, there wouldn't be external
> >    fragmentation like with per-memcg caches, which would probably
> >    compensate for that.
> 
> The extra memory overhead seems like it would be really bad for small objects.

I agree. That's why I'm far not sure about it and want to listen to what
others think. Any ideas how we could fix the issues of the current
design (mainly handling of per-memcg arrays) are more than welcome.

> 
> >  - Performance. We have to charge on each kmalloc, not on each slab page
> >    allocation as it's the case with per memcg caches. However, I think
> >    per cpu stocks would resolve this problem.
> 
> Maybe I'm wrong, but it seems like implementing per-memcg per-cpu
> stocks for this will be a non-trivial amount of code that would couple
> memcg and slab/slub pretty tightly.

I don't think so. We could encapsulate per-cpu stocks in memcontrol.c
publishing only charge/uncharge functions to slab internals. We would
have to write some extra code, but we'd be able to get rid of all that
synchronization stuff necessary for per-memcg cache creation/destruction
in return.

> 
> >  - Inflexibility. It wouldn't be easy to add a new kind of shrinkable
> >    object as it's the case with per memcg lru lists. We have to make the
> >    kmem cache used for the object allocations store list_head with each
> >    object and add yet another list_lru to the mem_cgroup struct. But do
> >    we really need such a level of flexibility? On memcg pressure we only
> >    want to shrink dentries and inodes. Will there be anything else?
> >
> > Any comments, thoughts, proposals are really welcome.
> 
> It also seems like with this approach, it would be difficult to have
> something like per-memcg slabinfo, which has been invaluable for
> diagnosing memory issues.

Yeah, there wouldn't be any per-memcg slabinfo then. At best, we could
show the number of objects used by a particular cgroup. However, do we
really need per-memcg slabinfo? I mean slab is something system-wide: if
there's a leak in it, it means something is wrong with a part of a
kernel, not a process in a cgroup. From this point all cgroups seem to
be equal.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
