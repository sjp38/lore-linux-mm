Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 49E546B0039
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:23:52 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id q59so6758322wes.24
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:23:51 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id p6si2576341wic.67.2014.06.03.07.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 07:23:50 -0700 (PDT)
Date: Tue, 3 Jun 2014 10:22:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140603142249.GP2878@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140603110743.GD1321@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Tue, Jun 03, 2014 at 01:07:43PM +0200, Michal Hocko wrote:
> On Wed 28-05-14 12:33:35, Johannes Weiner wrote:
> > On Wed, May 28, 2014 at 05:54:14PM +0200, Michal Hocko wrote:
> > > On Wed 28-05-14 11:28:54, Johannes Weiner wrote:
> > > > On Wed, May 28, 2014 at 04:21:44PM +0200, Michal Hocko wrote:
> > > > > On Wed 28-05-14 09:49:05, Johannes Weiner wrote:
> > > > > > On Wed, May 28, 2014 at 02:10:23PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > > > My main motivation for the weaker model is that it is hard to see all
> > > > > > > the corner case right now and once we hit them I would like to see a
> > > > > > > graceful fallback rather than fatal action like OOM killer. Besides that
> > > > > > > the usaceses I am mostly interested in are OK with fallback when the
> > > > > > > alternative would be OOM killer. I also feel that introducing a knob
> > > > > > > with a weaker semantic which can be made stronger later is a sensible
> > > > > > > way to go.
> > > > > > 
> > > > > > We can't make it stronger, but we can make it weaker. 
> > > > > 
> > > > > Why cannot we make it stronger by a knob/configuration option?
> > > > 
> > > > Why can't we make it weaker by a knob?
> > > 
> > > I haven't said we couldn't.
> > > 
> > > > Why should we design the default for unforeseeable cornercases
> > > > rather than make the default make sense for existing cases and give
> > > > cornercases a fallback once they show up?
> > > 
> > > Sure we can do that but it would be little bit lame IMO. We are
> > > promising something and once we find out it doesn't work we will make
> > > it weaker to workaround that.
> > >
> > > Besides that the default should reflect the usecases, no? Do we have any
> > > use case for the hard guarantee?
> > 
> > You're adding an extra layer of complexity so the burden of proof is
> > on you.  Do we have any usecases that require a graceful fallback?
> 
> As far as I am aware nobody (except for google) really loves OOM
> killer because there is nothing you can do once it strikes (in the
> global/cpuset memory case). You have no choice for clean up etc...
> 
> If we consider that memcg and its limits are not zone aware while the
> page allocator and reclaim are zone oriented then I can see a problem
> of unexpected reclaim failure although there is no over commit on the
> low_limit globally. And we do not have in-kernel effective measures to
> mitigate this inherent problem. At least not now and I am afraid it is
> a long route to have something that would work reasonably well in such
> cases.

Which "inherent problem"?

> So to me it sounds more responsible to promise only as much as we can
> handle. I think that fallback mode is not crippling the semantic of
> the knob as it triggers only for limit overcommit or strange corner
> cases. We have agreed that we do not care about the first one and
> handling the later one by potentially fatal action doesn't sounds very
> user friendly to me.

It *absolutely* cripples the semantics.  Think about the security use
cases of mlock for example, where certain memory may never hit the
platter.  This wouldn't be possible with your watered down guarantees.

And it's the user who makes the promise, not us.  I'd rather have the
responsibility with the user.  Provide mechanism, not policy.

> For example, if we get back to the NUMA case then a graceful fallback
> allows to migrate offending tasks off the node and reduce reclaim on the
> protected group. This can be done simply by watching the breach counter
> and act upon it. On the other hand if the default policy is OOM then
> the possible actions are much more reduced (action would have to be
> pro-active with hopes that they are faster than OOM).

It's really frustrating that you just repeat arguments to which I
already responded.

Again, how is this different from mlock?

And again, if this really is a problem (which I doubt), we should fix
it at the root and implement direct migration, rather than design an
interface around it.

> > > > > > Stronger is the simpler definition, it's simpler code,
> > > > > 
> > > > > The code is not really that much simpler. The one you have posted will
> > > > > not work I am afraid. I haven't tested it yet but I remember I had to do
> > > > > some tweaks to the reclaim path to not end up in an endless loop in the
> > > > > direct reclaim (http://marc.info/?l=linux-mm&m=138677140828678&w=2 and
> > > > > http://marc.info/?l=linux-mm&m=138677141328682&w=2).
> > > > 
> > > > That's just a result of do_try_to_free_pages being stupid and using
> > > > its own zonelist loop to check reclaimability by duplicating all the
> > > > checks instead of properly using returned state of shrink_zones().
> > > > Something that would be worth fixing regardless of memcg guarantees.
> > > > 
> > > > Or maybe we could add the guaranteed lru pages to sc->nr_scanned.
> > > 
> > > Fixes might be different than what I was proposing previously. I was
> > > merely pointing out that removing the retry loop is not sufficient.
> > 
> > No, you were claiming that the hard limit implementation is not
> > simpler.  It is.
> 
> Well, there are things you have to check anyway - short loops due to
> racing reclaimers and quick priority drop down or even pre-mature OOM
> in direct reclaim paths. kswapd shoudn't loop endlessly if it cannot
> balance the zone because all groups are withing limit on the node.
> So I fail to see it as that much simpler.

Could you please stop with the handwaving?  If there are bugs, we have
to fix them.  These pages are unreclaimable, plain and simple, like
anon without swap and mlocked pages.  None of this is new.

> Anyway, the complexity of the retry&ignore loop doesn't seem to be
> significant enough to dictate the default behavior. We should go with
> the one which makes the most sense for users.

The point is that you are adding complexity to weaken the semantics
and usefulness of this feature, with the only justification being
potential misconfigurations and a fear of unearthing kernel bugs.

This makes little sense for users, and even less sense for us.

> > > > > > your usecases are fine with it,
> > > > > 
> > > > > my usecases do not overcommit low_limit on the available memory, so far
> > > > > so good, but once we hit a corner cases when limits are set properly but
> > > > > we end up not being able to reclaim anybody in a zone then OOM sounds
> > > > > too brutal.
> > > > 
> > > > What cornercases?
> > > 
> > > I have mentioned a case where NUMA placement and specific node bindings
> > > interfering with other allocators can end up in unreclaimable zones.
> > > While you might disagree about the setup I have seen different things
> > > done out there.
> > 
> > If you have real usecases that might depend on weak guarantees, please
> > make a rational argument for them and don't just handwave. 
> 
> As I've said above. Usecases I am interested in do not overcommit on
> low_limit. The limit is used to protect group(s) from memory pressure
> from other loads which are running on the same machine. Primarily
> because the working set is quite expensive to build up. If we really
> hit a corner case and OOM would trigger then the whole state has to be
> rebuilt and that is much more expensive than ephemeral reclaim.

What corner cases?

> > I know that there is every conceivable configuration out there, but
> > it's unreasonable to design new features around the requirement of
> > setups that are questionable to begin with.
> 
> I do agree but on the other hand I think we shouldn't ignore inherent
> problems which might lead to problems mentioned above and provide an
> interface which doesn't cause an unexpected behavior.

What inherent problems?

> > > Besides that the reclaim logic is complex enough and history thought me
> > > that little buggers are hidden at places where you do not expect them.
> > 
> > So we introduce user interfaces designed around the fact that we don't
> > trust our own code anymore?
> 
> No, we are talking about inherent problems here. And my experience
> taught me to be careful and corner cases tend to show up in the real
> life situations.

I'm not willing to base an interface on this level of vagueness.

> > There is being prudent and then there is cargo cult programming.
> > 
> > > So call me a chicken but I would sleep calmer if we start weaker and add
> > > an additional guarantees later when somebody really insists on rseeing
> > > an OOM rather than get reclaimed.
> > > The proposed counter can tell us more how good we are at not touching
> > > groups with the limit and we can eventually debug those corner cases
> > > without affecting the loads too much.
> > 
> > More realistically, potential bugs are never reported with a silent
> > counter, which further widens the gap between our assumptions on how
> > the VM behaves and what happens in production.
> 
> OOM driven reports are arguably worse and without easy workaround on the
> other hand.

The workaround is obviously to lower the guarantees and/or fix the
NUMA bindings in such cases.

I really don't think you have a point here, because there is not a
single concrete example backing up your arguments.

Please remove the fallback code from your changes.  They weaken the
feature and add more complexity without reasonable justification - at
least you didn't convince anybody else involved in the discussion.

Because this is user-visible ABI that we are stuck with once released,
the patches should not be merged until we agree on the behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
