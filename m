Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6D63782F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:20:22 -0400 (EDT)
Received: by lbbwb3 with SMTP id wb3so56286lbb.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 01:20:21 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id xy7si27809058lbb.53.2015.10.28.01.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 01:20:20 -0700 (PDT)
Date: Wed, 28 Oct 2015 11:20:03 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151028082003.GK13221@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
 <20151027084320.GF13221@esperanza>
 <20151027155833.GB4665@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151027155833.GB4665@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 27, 2015 at 09:01:08AM -0700, Johannes Weiner wrote:
...
> > > But regardless of tcp window control, we need to account socket memory
> > > in the main memory accounting pool where pressure is shared (to the
> > > best of our abilities) between all accounted memory consumers.
> > > 
> > 
> > No objections to this point. However, I really don't like the idea to
> > charge tcp window size to memory.current instead of charging individual
> > pages consumed by the workload for storing socket buffers, because it is
> > inconsistent with what we have now. Can't we charge individual skb pages
> > as we do in case of other kmem allocations?
> 
> Absolutely, both work for me. I chose that route because it's where
> the networking code already tracks and accounts memory consumed, so it
> seemed like a better site to hook into.
> 
> But I understand your concerns. We want to track this stuff as close
> to the memory allocators as possible.

Exactly.

> 
> > > But also, there are people right now for whom the socket buffers cause
> > > system OOM, but the existing memcg's hard tcp window limitq that
> > > exists absolutely wrecks network performance for them. It's not usable
> > > the way it is. It'd be much better to have the socket buffers exert
> > > pressure on the shared pool, and then propagate the overall pressure
> > > back to individual consumers with reclaim, shrinkers, vmpressure etc.
> > 
> > This might or might not work. I'm not an expert to judge. But if you do
> > this only for memcg leaving the global case as it is, networking people
> > won't budge IMO. So could you please start such a major rework from the
> > global case? Could you please try to deprecate the tcp window limits not
> > only in the legacy memcg hierarchy, but also system-wide in order to
> > attract attention of networking experts?
> 
> I'm definitely interested in addressing this globally as well.
> 
> The idea behind this was to use the memcg part as a testbed. cgroup2
> is going to be new and people are prepared for hiccups when migrating
> their applications to it; and they can roll back to cgroup1 and tcp
> window limits at any time should they run into problems in production.

Then you'd better not touch existing tcp limits at all, because they
just work, and the logic behind them is very close to that of global tcp
limits. I don't think one can simplify it somehow. Moreover, frankly I
still have my reservations about this vmpressure propagation to skb
you're proposing. It might work, but I doubt it will allow us to throw
away explicit tcp limit, as I explained previously. So, even with your
approach I think we can still need per memcg tcp limit *unless* you get
rid of global tcp limit somehow.

> 
> So this seemed like a good way to prove a new mechanism before rolling
> it out to every single Linux setup, rather than switch everybody over
> after the limited scope testing I can do as a developer on my own.
> 
> Keep in mind that my patches are not committing anything in terms of
> interface, so we retain all the freedom to fix and tune the way this
> is implemented, including the freedom to re-add tcp window limits in
> case the pressure balancing is not a comprehensive solution.
> 

I really dislike this kind of proof. It looks like you're trying to push
something you think is right covertly, w/o having a proper discussion
with networking people and then say that it just works and hence should
be done globally, but what if it won't? Revert it? We already have a lot
of dubious stuff in memcg that should be reverted, so let's please try
to avoid this kind of mistakes in future. Note, I say "w/o having a
proper discussion with networking people", because I don't think they
will really care *unless* you change the global logic, simply because
most of them aren't very interested in memcg AFAICS.

That effectively means you loose a chance to listen to networking
experts, who could point you at design flaws and propose an improvement
right away. Let's please not miss such an opportunity. You said that
you'd seen this problem happen w/o cgroups, so you have a use case that
might need fixing at the global level. IMO it shouldn't be difficult to
prepare an RFC patch for the global case first and see what people think
about it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
