Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3EC6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 23:51:55 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so11034509yha.37
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 20:51:54 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id r49si1999067yho.217.2013.12.03.20.51.52
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 20:51:54 -0800 (PST)
Date: Wed, 4 Dec 2013 15:51:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 09/18] vmscan: shrink slab on memcg pressure
Message-ID: <20131204045147.GN10988@dastard>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com>
 <20131203104849.GD8803@dastard>
 <529DCB7D.10205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529DCB7D.10205@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 03, 2013 at 04:15:57PM +0400, Vladimir Davydov wrote:
> On 12/03/2013 02:48 PM, Dave Chinner wrote:
> >> @@ -236,11 +236,17 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> >>  		return 0;
> >>  
> >>  	/*
> >> -	 * copy the current shrinker scan count into a local variable
> >> -	 * and zero it so that other concurrent shrinker invocations
> >> -	 * don't also do this scanning work.
> >> +	 * Do not touch global counter of deferred objects on memcg pressure to
> >> +	 * avoid isolation issues. Ideally the counter should be per-memcg.
> >>  	 */
> >> -	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> >> +	if (!shrinkctl->target_mem_cgroup) {
> >> +		/*
> >> +		 * copy the current shrinker scan count into a local variable
> >> +		 * and zero it so that other concurrent shrinker invocations
> >> +		 * don't also do this scanning work.
> >> +		 */
> >> +		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> >> +	}
> > That's ugly. Effectively it means that memcg reclaim is going to be
> > completely ineffective when large numbers of allocations and hence
> > reclaim attempts are done under GFP_NOFS context.
> >
> > The only thing that keeps filesystem caches in balance when there is
> > lots of filesystem work going on (i.e. lots of GFP_NOFS allocations)
> > is the deferal of reclaim work to a context that can do something
> > about it.
> 
> Imagine the situation: a memcg issues a GFP_NOFS allocation and goes to
> shrink_slab() where it defers them to the global counter; then another
> memcg issues a GFP_KERNEL allocation, also goes to shrink_slab() where
> it sees a huge number of deferred objects and starts shrinking them,
> which is not good IMHO.

That's exactly what the deferred mechanism is for - we know we have
to do the work, but we can't do it right now so let someone else do
it who can.

In most cases, deferral is handled by kswapd, because when a
filesystem workload is causing memory pressure then most allocations
are done in GFP_NOFS conditions. Hence the only memory reclaim that
can make progress here is kswapd.

Right now, you aren't deferring any of this memory pressure to some
other agent, so it just does not get done. That's a massive problem
- it's a design flaw - and instead I see lots of crazy hacks being
added to do stuff that should simply be deferred to kswapd like is
done for global memory pressure.

Hell, kswapd shoul dbe allowed to walk memcg LRU lists and trim
them, just like it does for the global lists. We only need a single
"deferred work" counter per node for that - just let kswapd
proportion the deferred work over the per-node LRU and the
memcgs....

> I understand that nr_deferred is necessary, but
> I think it should be per-memcg. What do you think about moving it to
> list_lru?

It's part of the shrinker state that is used to calculate how much
work the shrinker needs to do. We can't hold it in the LRU, because
there is no guarantee that a shrinker actually uses a list_lru, and
shrinkers can be memcg aware without using list_lru infrastructure.

So, no, moving it to the list-lru is not a solution....

> > So, if the memcg can't make progress, why wouldn't you defer the
> > work to the global scan? Or can't a global scan trim memcg LRUs?
> > And if it can't, then isn't that a major design flaw? Why not just
> > allow kswapd to walk memcg LRUs in the background?
> >
> > /me just looked at patch 13
> >
> > Yeah, this goes some way to explaining why something like patch 13
> > is necessary - slab shrinkers are not keeping up with page cache
> > reclaim because of GFP_NOFS allocations, and so the page cache
> > empties only leaving slab caches to be trimmed....
> >
> >
> >> +static unsigned long
> >> +shrink_slab_memcg(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> >> +		  unsigned long fraction, unsigned long denominator)
> > what's this function got to do with memcgs? Why did you rename it
> > from the self explanitory shrink_slab_one() name that Glauber gave
> > it?
> 
> When I sent the previous version, Johannes Weiner disliked the name that
> was why I renamed it, now you don't like the new name and ask for the
> old one :-) But why do you think that shrink_slab_one() is
> self-explanatory while shrink_slab_memcg() is not? I mean
> shrink_slab_memcg() means "shrink slab accounted to a memcg" just like

But it's not shrinking a slab accounted to a memcg - the memcg can
be null. All it's is doing is executing a shrinker scan...

> shrink_slab_node() means "shrink slab on the node" while seeing
> shrink_slab_one() I would ask "one what?".

It's running a shrinker scan on *one* shrinker. It doesn't matter if
the shrinker is memcg aware, or numa aware, it's just running one
shrinker....

So, while shrink_slab_one() might not be the best name, it's
certainly more correct than shrink_slab_memcg(). Perhaps it would be
better named run_shrinker()....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
