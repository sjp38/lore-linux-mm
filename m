Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE916B0039
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 10:32:53 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x13so1227266wgg.22
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 07:32:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd1si11642761wjc.5.2014.06.05.07.32.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 07:32:42 -0700 (PDT)
Date: Thu, 5 Jun 2014 16:32:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140605143235.GC2926@dhcp22.suse.cz>
References: <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140604154408.GT2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed 04-06-14 11:44:08, Johannes Weiner wrote:
> On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> > On Tue 03-06-14 10:22:49, Johannes Weiner wrote:
> > > On Tue, Jun 03, 2014 at 01:07:43PM +0200, Michal Hocko wrote:
> > [...]
> > > > If we consider that memcg and its limits are not zone aware while the
> > > > page allocator and reclaim are zone oriented then I can see a problem
> > > > of unexpected reclaim failure although there is no over commit on the
> > > > low_limit globally. And we do not have in-kernel effective measures to
> > > > mitigate this inherent problem. At least not now and I am afraid it is
> > > > a long route to have something that would work reasonably well in such
> > > > cases.
> > > 
> > > Which "inherent problem"?
> > 
> > zone unawareness of the limit vs. allocation/reclaim which are zone
> > oriented.
> 
> This is a quote from another subthread where you haven't responded:
> 
> ---
> 
> > > > > But who actually cares if an individual zone can be reclaimed?
> > > > > 
> > > > > Userspace allocations can fall back to any other zone.  Unless there
> > > > > are hard bindings, but hopefully nobody binds a memcg to a node that
> > > > > is smaller than that memcg's guarantee. 
> > > > 
> > > > The protected group might spill over to another group and eat it when
> > > > another group would be simply pushed out from the node it is bound to.
> > > 
> > > I don't really understand the point you're trying to make.
> > 
> > I was just trying to show a case where individual zone matters. To make
> > it more specific consider 2 groups A (with low-limit 60% RAM) and B
> > (say with low-limit 10% RAM) and bound to a node X (25% of RAM). Now
> > having 70% of RAM reserved for guarantee makes some sense, right? B is
> > not over-committing the node it is bound to. Yet the A's allocations
> > might make pressure on X regardless that the whole system is still doing
> > good. This can lead to a situation where X gets depleted and nothing
> > would be reclaimable leading to an OOM condition.
> 
> Once you assume control of memory *placement* in the system like this,
> you can not also pretend to be clueless and have unreclaimable memory
> of this magnitude spread around into nodes used by other bound tasks.

You are still assuming that the administrator controls the placement.
The load running in your memcg might be a black box for admin. E.g. a
container which pays $$ to get a priority and not get reclaimed if that
is possible. Admin can make sure that the cumulative low_limits for
containers are sane but he doesn't have any control over what the loads
inside are doing and potential OOM when one tries to DOS the other is
definitely not welcome.
 
> If we were to actively support such configurations, we should be doing
> direct NUMA balancing and migrate these pages out of node X when B
> needs to allocate. 

Migration is certainly a way how to reduce the risk. It is a question
whether this is something to be done by the kernel implicitly or by
administrator.

> That would fix the problem for all unevictable
> memory, not just memcg guarantees, and would prefer node-offloading
> over swapping in cases where swap is available.

That would certainly lower the risk. But there still might be unmovable
memory sitting on the node so this will never be 100%.

> But really, this whole scenario sounds contrived to me.  And there is
> nothing specific about memcg guarantees in there.
> 
> ---
> 
> > > > So to me it sounds more responsible to promise only as much as we can
> > > > handle. I think that fallback mode is not crippling the semantic of
> > > > the knob as it triggers only for limit overcommit or strange corner
> > > > cases. We have agreed that we do not care about the first one and
> > > > handling the later one by potentially fatal action doesn't sounds very
> > > > user friendly to me.
> > > 
> > > It *absolutely* cripples the semantics.  Think about the security use
> > > cases of mlock for example, where certain memory may never hit the
> > > platter.  This wouldn't be possible with your watered down guarantees.
> > 
> > Is this really a use case? It sounds like a weak one to me. Because
> > any sudden memory consumption above the limit can reclaim your
> > to-protect-page it will hit the platter and you cannot do anything about
> > this. So yeah, this is not mlock.
> 
> You are right, that is a weak usecase.
> 
> It doesn't change the fact that it does severely weaken the semantics
> and turns it into another best-effort mechanism that the user can't
> count on.  This sucks.  It sucked with soft limits and it will suck
> again.  The irony is that Greg even pointed out you should be doing
> soft limits if you want this sort of behavior.

The question is whether we really _need_ hard guarantees. I came with
the low_limit as a replacement for soft_limit which really sucks. But it
sucks not because you cannot count on it. It is the way how it has
opposite semantic which sucks - and the implementation of course. I have
tried to fix it and that route was a no-go.

I think the hard guarantee makes some sense when we allow to overcommit
the limit. Somebody might really want to setup lowlimit == hardlimit
because reclaim would be more harmful than restart of the application.
I would however expect that this would be more of an exception rather
than regular use. Most users I can think of will set low_limit to an
effective working set size to be isolated from other loads and ephemeral
reclaim will not hurt them. OOM would on other hand would be really
harmful.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
