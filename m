Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0C97A6B0037
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 10:47:03 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so8703682wiw.3
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 07:47:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si35130564wiv.41.2014.06.04.07.47.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 07:47:01 -0700 (PDT)
Date: Wed, 4 Jun 2014 16:46:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140604144658.GB17612@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140603142249.GP2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Tue 03-06-14 10:22:49, Johannes Weiner wrote:
> On Tue, Jun 03, 2014 at 01:07:43PM +0200, Michal Hocko wrote:
[...]
> > If we consider that memcg and its limits are not zone aware while the
> > page allocator and reclaim are zone oriented then I can see a problem
> > of unexpected reclaim failure although there is no over commit on the
> > low_limit globally. And we do not have in-kernel effective measures to
> > mitigate this inherent problem. At least not now and I am afraid it is
> > a long route to have something that would work reasonably well in such
> > cases.
> 
> Which "inherent problem"?

zone unawareness of the limit vs. allocation/reclaim which are zone
oriented.
 
> > So to me it sounds more responsible to promise only as much as we can
> > handle. I think that fallback mode is not crippling the semantic of
> > the knob as it triggers only for limit overcommit or strange corner
> > cases. We have agreed that we do not care about the first one and
> > handling the later one by potentially fatal action doesn't sounds very
> > user friendly to me.
> 
> It *absolutely* cripples the semantics.  Think about the security use
> cases of mlock for example, where certain memory may never hit the
> platter.  This wouldn't be possible with your watered down guarantees.

Is this really a use case? It sounds like a weak one to me. Because
any sudden memory consumption above the limit can reclaim your
to-protect-page it will hit the platter and you cannot do anything about
this. So yeah, this is not mlock.

> And it's the user who makes the promise, not us.  I'd rather have the
> responsibility with the user.  Provide mechanism, not policy.

And that user is the application writer, not its administrator. And
memcg is more of an admin interface than a development API.

> > For example, if we get back to the NUMA case then a graceful fallback
> > allows to migrate offending tasks off the node and reduce reclaim on the
> > protected group. This can be done simply by watching the breach counter
> > and act upon it. On the other hand if the default policy is OOM then
> > the possible actions are much more reduced (action would have to be
> > pro-active with hopes that they are faster than OOM).
> 
> It's really frustrating that you just repeat arguments to which I
> already responded.

No you haven't responded. You are dismissing the issue in the first
place. Can you guarantee that there is no OOM when low_limits do not
overcommit the machine and node bound tasks live in a group which
doesn't overcommit the node?

> Again, how is this different from mlock?

Sigh. The first thing is that this is not mlock. You are operating on
per-group basis. You are running a load which can make its own decisions
on the NUMA placement etc... With mlock you are explicit about which
memory is locked (potentially even the placement). So the situation is
very much different I would say.

> And again, if this really is a problem (which I doubt), we should fix
> it at the root and implement direct migration, rather than design an
> interface around it.

Why would we do something like that in the kernel when we have tools to
migrate tasks from the userspace?

> > > > > > > Stronger is the simpler definition, it's simpler code,
> > > > > > 
> > > > > > The code is not really that much simpler. The one you have posted will
> > > > > > not work I am afraid. I haven't tested it yet but I remember I had to do
> > > > > > some tweaks to the reclaim path to not end up in an endless loop in the
> > > > > > direct reclaim (http://marc.info/?l=linux-mm&m=138677140828678&w=2 and
> > > > > > http://marc.info/?l=linux-mm&m=138677141328682&w=2).
> > > > > 
> > > > > That's just a result of do_try_to_free_pages being stupid and using
> > > > > its own zonelist loop to check reclaimability by duplicating all the
> > > > > checks instead of properly using returned state of shrink_zones().
> > > > > Something that would be worth fixing regardless of memcg guarantees.
> > > > > 
> > > > > Or maybe we could add the guaranteed lru pages to sc->nr_scanned.
> > > > 
> > > > Fixes might be different than what I was proposing previously. I was
> > > > merely pointing out that removing the retry loop is not sufficient.
> > > 
> > > No, you were claiming that the hard limit implementation is not
> > > simpler.  It is.
> > 
> > Well, there are things you have to check anyway - short loops due to
> > racing reclaimers and quick priority drop down or even pre-mature OOM
> > in direct reclaim paths. kswapd shoudn't loop endlessly if it cannot
> > balance the zone because all groups are withing limit on the node.
> > So I fail to see it as that much simpler.
> 
> Could you please stop with the handwaving?  If there are bugs, we have
> to fix them.  These pages are unreclaimable, plain and simple, like
> anon without swap and mlocked pages.  None of this is new.

There is no handwaving. The above two patches describe what I mean.
You have just thrown a patch to remove retry loop claiming that the code
is easier that way and I've tried to explain to you that it is not that
simple. Full stop.

> > Anyway, the complexity of the retry&ignore loop doesn't seem to be
> > significant enough to dictate the default behavior. We should go with
> > the one which makes the most sense for users.
> 
> The point is that you are adding complexity to weaken the semantics
> and usefulness of this feature, with the only justification being
> potential misconfigurations and a

Which misconfiguration are you talking about?

> fear of unearthing kernel bugs.

This is not right! I didn't say I am afraid of bugs. I said that the
code is complicated enough that seeing all the potential corner cases is
really hard and so starting with weaker semantic makes some sense.

> This makes little sense for users, and even less sense for us.
> 
> > > > > > > your usecases are fine with it,
> > > > > > 
> > > > > > my usecases do not overcommit low_limit on the available memory, so far
> > > > > > so good, but once we hit a corner cases when limits are set properly but
> > > > > > we end up not being able to reclaim anybody in a zone then OOM sounds
> > > > > > too brutal.
> > > > > 
> > > > > What cornercases?
> > > > 
> > > > I have mentioned a case where NUMA placement and specific node bindings
> > > > interfering with other allocators can end up in unreclaimable zones.
> > > > While you might disagree about the setup I have seen different things
> > > > done out there.
> > > 
> > > If you have real usecases that might depend on weak guarantees, please
> > > make a rational argument for them and don't just handwave. 
> > 
> > As I've said above. Usecases I am interested in do not overcommit on
> > low_limit. The limit is used to protect group(s) from memory pressure
> > from other loads which are running on the same machine. Primarily
> > because the working set is quite expensive to build up. If we really
> > hit a corner case and OOM would trigger then the whole state has to be
> > rebuilt and that is much more expensive than ephemeral reclaim.
> 
> What corner cases?

Seriously? Come on Johannes, try to be little bit constructive.

> > > I know that there is every conceivable configuration out there, but
> > > it's unreasonable to design new features around the requirement of
> > > setups that are questionable to begin with.
> > 
> > I do agree but on the other hand I think we shouldn't ignore inherent
> > problems which might lead to problems mentioned above and provide an
> > interface which doesn't cause an unexpected behavior.
> 
> What inherent problems?
> 
> > > > Besides that the reclaim logic is complex enough and history thought me
> > > > that little buggers are hidden at places where you do not expect them.
> > > 
> > > So we introduce user interfaces designed around the fact that we don't
> > > trust our own code anymore?
> > 
> > No, we are talking about inherent problems here. And my experience
> > taught me to be careful and corner cases tend to show up in the real
> > life situations.
> 
> I'm not willing to base an interface on this level of vagueness.
> 
> > > There is being prudent and then there is cargo cult programming.
> > > 
> > > > So call me a chicken but I would sleep calmer if we start weaker and add
> > > > an additional guarantees later when somebody really insists on rseeing
> > > > an OOM rather than get reclaimed.
> > > > The proposed counter can tell us more how good we are at not touching
> > > > groups with the limit and we can eventually debug those corner cases
> > > > without affecting the loads too much.
> > > 
> > > More realistically, potential bugs are never reported with a silent
> > > counter, which further widens the gap between our assumptions on how
> > > the VM behaves and what happens in production.
> > 
> > OOM driven reports are arguably worse and without easy workaround on the
> > other hand.
> 
> The workaround is obviously to lower the guarantees and/or fix the
> NUMA bindings in such cases.

How? Do not use low_limit on node bound loads? Use cumulative low_limit
smaller than any node which has bindings? How is the feature still
useful?

> I really don't think you have a point here, because there is not a
> single concrete example backing up your arguments.
> 
> Please remove the fallback code from your changes.  They weaken the
> feature and add more complexity without reasonable justification - at
> least you didn't convince anybody else involved in the discussion.

OK, so you are simply ignoring the usecase I've provided to you and then
claim the usefulness of the OOM default without providing any usecases
(we are still talking about setups which do not overcommit low_limit).

> Because this is user-visible ABI that we are stuck with once released,
> the patches should not be merged until we agree on the behavior.

In the other email I have suggested to add a knob with the configurable
default. Would you be OK with that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
