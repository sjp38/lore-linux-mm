Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 989126B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 00:01:30 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so12000310yha.25
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 21:01:30 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id u45si48887802yhc.278.2013.12.04.21.01.28
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 21:01:29 -0800 (PST)
Date: Thu, 5 Dec 2013 16:01:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 09/18] vmscan: shrink slab on memcg pressure
Message-ID: <20131205050118.GM8803@dastard>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com>
 <20131203104849.GD8803@dastard>
 <529DCB7D.10205@parallels.com>
 <20131204045147.GN10988@dastard>
 <529ECC44.8040508@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529ECC44.8040508@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Dec 04, 2013 at 10:31:32AM +0400, Vladimir Davydov wrote:
> On 12/04/2013 08:51 AM, Dave Chinner wrote:
> > On Tue, Dec 03, 2013 at 04:15:57PM +0400, Vladimir Davydov wrote:
> >> On 12/03/2013 02:48 PM, Dave Chinner wrote:
> >>>> @@ -236,11 +236,17 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> >>>>  		return 0;
> >>>>  
> >>>>  	/*
> >>>> -	 * copy the current shrinker scan count into a local variable
> >>>> -	 * and zero it so that other concurrent shrinker invocations
> >>>> -	 * don't also do this scanning work.
> >>>> +	 * Do not touch global counter of deferred objects on memcg pressure to
> >>>> +	 * avoid isolation issues. Ideally the counter should be per-memcg.
> >>>>  	 */
> >>>> -	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> >>>> +	if (!shrinkctl->target_mem_cgroup) {
> >>>> +		/*
> >>>> +		 * copy the current shrinker scan count into a local variable
> >>>> +		 * and zero it so that other concurrent shrinker invocations
> >>>> +		 * don't also do this scanning work.
> >>>> +		 */
> >>>> +		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> >>>> +	}
> >>> That's ugly. Effectively it means that memcg reclaim is going to be
> >>> completely ineffective when large numbers of allocations and hence
> >>> reclaim attempts are done under GFP_NOFS context.
> >>>
> >>> The only thing that keeps filesystem caches in balance when there is
> >>> lots of filesystem work going on (i.e. lots of GFP_NOFS allocations)
> >>> is the deferal of reclaim work to a context that can do something
> >>> about it.
> >> Imagine the situation: a memcg issues a GFP_NOFS allocation and goes to
> >> shrink_slab() where it defers them to the global counter; then another
> >> memcg issues a GFP_KERNEL allocation, also goes to shrink_slab() where
> >> it sees a huge number of deferred objects and starts shrinking them,
> >> which is not good IMHO.
> > That's exactly what the deferred mechanism is for - we know we have
> > to do the work, but we can't do it right now so let someone else do
> > it who can.
> >
> > In most cases, deferral is handled by kswapd, because when a
> > filesystem workload is causing memory pressure then most allocations
> > are done in GFP_NOFS conditions. Hence the only memory reclaim that
> > can make progress here is kswapd.
> >
> > Right now, you aren't deferring any of this memory pressure to some
> > other agent, so it just does not get done. That's a massive problem
> > - it's a design flaw - and instead I see lots of crazy hacks being
> > added to do stuff that should simply be deferred to kswapd like is
> > done for global memory pressure.
> >
> > Hell, kswapd shoul dbe allowed to walk memcg LRU lists and trim
> > them, just like it does for the global lists. We only need a single
> > "deferred work" counter per node for that - just let kswapd
> > proportion the deferred work over the per-node LRU and the
> > memcgs....
> 
> Seems I misunderstand :-(
> 
> Let me try. You mean we have the only nr_deferred counter per-node, and
> kswapd scans
> 
> nr_deferred*memcg_kmem_size/total_kmem_size
> 
> objects in each memcg, right?
> 
> Then if there were a lot of objects deferred on memcg (not global)
> pressure due to a memcg issuing a lot of GFP_NOFS allocations, kswapd
> will reclaim objects from all, even unlimited, memcgs. This looks like
> an isolation issue :-/

Which, when you are running out of memory, is a much less of an
issue than not being able to make progress reclaiming memory.

Besides, the "isolation" argument runs both ways. e.g. when there
isn't memory available, it's entirely possible it's because there is
actually no free memory, not because we've hit a memcg limit. e.g.
all the memory has been consumed by an unlimited memcg, and we need to
reclaim from it so this memcg can make progress.

In those situations we need to reclaim from everyone, not
just the memcg that can't find free memory to allocate....

> Currently we have a per-node nr_deferred counter for each shrinker. If
> we add per-memcg reclaim, we have to make it per-memcg per-node, don't we?

Think about what you just said for a moment. We have how many memcg
shrinkers?  And we can support how many nodes? And we can support
how many memcgs? And when we multiply that all together, how much
memory do we need to track that?

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
