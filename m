Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8B11E6B0035
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 11:44:39 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so8539516wgh.2
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 08:44:39 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qn1si5472895wjc.117.2014.06.04.08.44.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 08:44:35 -0700 (PDT)
Date: Wed, 4 Jun 2014 11:44:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140604154408.GT2878@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140604144658.GB17612@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> On Tue 03-06-14 10:22:49, Johannes Weiner wrote:
> > On Tue, Jun 03, 2014 at 01:07:43PM +0200, Michal Hocko wrote:
> [...]
> > > If we consider that memcg and its limits are not zone aware while the
> > > page allocator and reclaim are zone oriented then I can see a problem
> > > of unexpected reclaim failure although there is no over commit on the
> > > low_limit globally. And we do not have in-kernel effective measures to
> > > mitigate this inherent problem. At least not now and I am afraid it is
> > > a long route to have something that would work reasonably well in such
> > > cases.
> > 
> > Which "inherent problem"?
> 
> zone unawareness of the limit vs. allocation/reclaim which are zone
> oriented.

This is a quote from another subthread where you haven't responded:

---

> > > > But who actually cares if an individual zone can be reclaimed?
> > > > 
> > > > Userspace allocations can fall back to any other zone.  Unless there
> > > > are hard bindings, but hopefully nobody binds a memcg to a node that
> > > > is smaller than that memcg's guarantee. 
> > > 
> > > The protected group might spill over to another group and eat it when
> > > another group would be simply pushed out from the node it is bound to.
> > 
> > I don't really understand the point you're trying to make.
> 
> I was just trying to show a case where individual zone matters. To make
> it more specific consider 2 groups A (with low-limit 60% RAM) and B
> (say with low-limit 10% RAM) and bound to a node X (25% of RAM). Now
> having 70% of RAM reserved for guarantee makes some sense, right? B is
> not over-committing the node it is bound to. Yet the A's allocations
> might make pressure on X regardless that the whole system is still doing
> good. This can lead to a situation where X gets depleted and nothing
> would be reclaimable leading to an OOM condition.

Once you assume control of memory *placement* in the system like this,
you can not also pretend to be clueless and have unreclaimable memory
of this magnitude spread around into nodes used by other bound tasks.

If we were to actively support such configurations, we should be doing
direct NUMA balancing and migrate these pages out of node X when B
needs to allocate.  That would fix the problem for all unevictable
memory, not just memcg guarantees, and would prefer node-offloading
over swapping in cases where swap is available.

But really, this whole scenario sounds contrived to me.  And there is
nothing specific about memcg guarantees in there.

---

> > > So to me it sounds more responsible to promise only as much as we can
> > > handle. I think that fallback mode is not crippling the semantic of
> > > the knob as it triggers only for limit overcommit or strange corner
> > > cases. We have agreed that we do not care about the first one and
> > > handling the later one by potentially fatal action doesn't sounds very
> > > user friendly to me.
> > 
> > It *absolutely* cripples the semantics.  Think about the security use
> > cases of mlock for example, where certain memory may never hit the
> > platter.  This wouldn't be possible with your watered down guarantees.
> 
> Is this really a use case? It sounds like a weak one to me. Because
> any sudden memory consumption above the limit can reclaim your
> to-protect-page it will hit the platter and you cannot do anything about
> this. So yeah, this is not mlock.

You are right, that is a weak usecase.

It doesn't change the fact that it does severely weaken the semantics
and turns it into another best-effort mechanism that the user can't
count on.  This sucks.  It sucked with soft limits and it will suck
again.  The irony is that Greg even pointed out you should be doing
soft limits if you want this sort of behavior.

> > And it's the user who makes the promise, not us.  I'd rather have the
> > responsibility with the user.  Provide mechanism, not policy.
> 
> And that user is the application writer, not its administrator. And
> memcg is more of an admin interface than a development API.
> 
> > > For example, if we get back to the NUMA case then a graceful fallback
> > > allows to migrate offending tasks off the node and reduce reclaim on the
> > > protected group. This can be done simply by watching the breach counter
> > > and act upon it. On the other hand if the default policy is OOM then
> > > the possible actions are much more reduced (action would have to be
> > > pro-active with hopes that they are faster than OOM).
> > 
> > It's really frustrating that you just repeat arguments to which I
> > already responded.
> 
> No you haven't responded. You are dismissing the issue in the first
> place. Can you guarantee that there is no OOM when low_limits do not
> overcommit the machine and node bound tasks live in a group which
> doesn't overcommit the node?

I was referring to the quote on NUMA configurations above.

You can not make this guarantee even *without* the low limit set
because of other sources of unreclaimable memory.

> > Again, how is this different from mlock?
> 
> Sigh. The first thing is that this is not mlock. You are operating on
> per-group basis. You are running a load which can make its own decisions
> on the NUMA placement etc... With mlock you are explicit about which
> memory is locked (potentially even the placement). So the situation is
> very much different I would say.

It is still unreclaimable memory, just like mlock and anon without
swap.  I still don't see how it's different, and making unfounded
claims that it is won't change that.  Provide an example.

> > And again, if this really is a problem (which I doubt), we should fix
> > it at the root and implement direct migration, rather than design an
> > interface around it.
> 
> Why would we do something like that in the kernel when we have tools to
> migrate tasks from the userspace?

This is again in reference to partial NUMA bindings.  We can not
reclaim guaranteed memory, but we could direct-migrate unbound
unreclaimable memory to another node at allocation time as part of the
reclaim cycle.

If unbound unreclaimable memory spilling into random nodes making them
unreclaimable and causing OOMs for node-bound tasks truly is a
problem, then a) it's not a new one because of mlock and swapless anon
and b) it shouldn't be solved by weakening guarantee semantics, but by
something like direct migrate.

> > > > > So call me a chicken but I would sleep calmer if we start weaker and add
> > > > > an additional guarantees later when somebody really insists on rseeing
> > > > > an OOM rather than get reclaimed.
> > > > > The proposed counter can tell us more how good we are at not touching
> > > > > groups with the limit and we can eventually debug those corner cases
> > > > > without affecting the loads too much.
> > > > 
> > > > More realistically, potential bugs are never reported with a silent
> > > > counter, which further widens the gap between our assumptions on how
> > > > the VM behaves and what happens in production.
> > > 
> > > OOM driven reports are arguably worse and without easy workaround on the
> > > other hand.
> > 
> > The workaround is obviously to lower the guarantees and/or fix the
> > NUMA bindings in such cases.
> 
> How? Do not use low_limit on node bound loads? Use cumulative low_limit
> smaller than any node which has bindings? How is the feature still
> useful?

You completely lost me.  Why can I not use the low limit in
combination with hard bindings?  And yes, the low limit of a group of
tasks would have to be smaller than the nodes that group is bound to.

> > I really don't think you have a point here, because there is not a
> > single concrete example backing up your arguments.
> > 
> > Please remove the fallback code from your changes.  They weaken the
> > feature and add more complexity without reasonable justification - at
> > least you didn't convince anybody else involved in the discussion.
> 
> OK, so you are simply ignoring the usecase I've provided to you and then
> claim the usefulness of the OOM default without providing any usecases
> (we are still talking about setups which do not overcommit low_limit).

I'm not ignoring it, I think I addressed all usecases that you
mentioned.  If I'm missing one, please point it out to me.

> > Because this is user-visible ABI that we are stuck with once released,
> > the patches should not be merged until we agree on the behavior.
> 
> In the other email I have suggested to add a knob with the configurable
> default. Would you be OK with that?

No, I want to agree on whether we need that fallback code or not.  I'm
not interested in merging code that you can't convince anybody else is
needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
