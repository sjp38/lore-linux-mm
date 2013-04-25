Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D3C686B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 20:33:41 -0400 (EDT)
Received: by mail-qe0-f46.google.com with SMTP id nd7so1400239qeb.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 17:33:40 -0700 (PDT)
Date: Wed, 24 Apr 2013 17:33:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130425003335.GA32353@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
 <20130424214531.GA18686@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130424214531.GA18686@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

Hello, Johannes.

On Wed, Apr 24, 2013 at 05:45:31PM -0400, Johannes Weiner wrote:
> Historically soft limit meant prioritizing certain memcgs over others
> and the memcgs over their soft limit should experience relatively more
> reclaim pressure than the ones below their soft limit.
> 
> Now, if we go and say you are only reclaimed when you exceed your soft
> limit we would retain the prioritization aspect.  Groups in excess of
> their soft limits would still experience relatively more reclaim
> pressure than their well-behaved peers.  But it would have the nice
> side effect of acting more or less like a guarantee as well.

But, at the same time, it has the not-so-nice side-effect of losing
the ability to express negative prioritization.  It isn't difficult to
imagine use cases where the system doesn't want to partition the whole
system into discrete cgroups but wants to limit the amount of
resources consumed by low-priority workloads.

Also, in the long-term, I really want cgroup to become something
generally useful and automatically configurable (optional of course)
by the base system according to the types of workloads.  For something
like that to be possible, the control knobs shouldn't be fiddly,
complex, or require full partitioning of the system.

> I don't think this approach is as unreasonable as you make it out to
> be, but it does make things more complicated.  It could be argued that
> we should add a separate guarantee knob because two simple knobs might
> be better than a complicated one.

The problem that I see is that this is being done without clearing up
the definition of the knob.  The knob's role is being changed or at
least solidified into something which makes it inconsistent with
everything else in cgroup in a way which seems very reactive to me.

I can see such reactive customizations being useful in satisfying
certain specific use cases - google's primarily right now; however,
it's likely to come back and bite us when we want to do something
different or generic with cgroup.  It's gonna be something which ends
up being labeled as unusuable in other types of setups (e.g. where not
all workloads are put under active control or whatever) after causing
a lot of head-scratching and not-particularly-happy moments.  Cgroup
as a whole strongly needs consistency across its control knobs for it
to be generally useful.

Well, that and past frustrations over interface and implementations of
memcg, which seems to bear a lot of similarities with what's going on
now, probably have made me go over-board.  Sorry about that, but I
really hope memcg do better.

...
> no single member is more at fault than the others.  I would expect if
> we added a guarantee knob, this would also mean that no individual
> memcg can be treated as being within their guaranteed memory if the
> hierarchy as a whole is in excess of its guarantee.

I disagree here.  It should be symmetrical to how hardlimit works.
Let's say there's one parent - P - and child - C.  For hardlimit, if P
is over limit, it exerts pressure on its subtree regardless of C, and,
if P is under limit, it doesn't affect C.

For guarantee / protection, it should work the same but in the
opposite direction.  If P is under limit, it should protect the
subtree from reclaim regardless of C.  If P is over limit, it
shouldn't affect C.

As I draw in the other reply to Michal, each knob should be a starting
point of a single range in the pre-defined direction and composition
of those configurations across hierarchy should result in intersection
of them.  I can't see any reason to deviate from that here.

IOW, protection control shouldn't care about generating memory
pressure.  That's the job of soft and hard limits, both of which
should apparently override protection.  That way, each control knob
becomes fully consistent within itself across the hierarchy and the
questions become those of how soft limit should override protection
rather than the semantics of soft limit itself.

> The root of the hierarchy represents the whole hierarchy.  Its memory
> usage is the combined memory usage of all members.  The limit set to
> the hierarchy root applies to the combined memory usage of the
> hierarchy.  Breaching that limit has consequences for the hierarchy as
> a whole.  Be it soft limit or guarantee.
> 
> This is how hierarchies have always worked and it allows limits to be
> layered and apply depending on the source of pressure:

That's definitely true for soft and hard limits but flipped for
guarantees and I think that's the primary source of confusion -
guarantee being overloaded onto softlimit.

>        root (physical memory = 32G)
>       /    \
>      A      B (hard limit = 25G, guarantee = 16G)
>     / \    / \
>    A1 A2  /   B2 (guarantee = 10G)
>          /
>         B1 (guarantee = 15G)
> 
> Remember that hard limits are usually overcommitted, so you allow B to
> use more of the fair share of memory when A does not need it, but you
> want to keep it capped to keep latency reasonable when A ramps up.
> 
> As long as B is hitting its own hard limit, you value B1's and B2's
> guarantees in the context of pressure local to the hierarchy; in the
> context of B having 25G worth of memory; in the context of B1
> competing with B2 over the memory allowed by B.
> 
> However, as soon as global reclaim kicks in, the context changes and
> the priorities shift.  Now, B does not have 25G anymore but only 16G
> *in its competition with A*.  We absolutely do not want to respect the
> guarantees made to B1 and B2.  Not only can they not be met anyway,
> but they are utterly meaningless at this point.  They were set with
> 25G in mind.

I find the configuration confusing.  What does it mean?  Let's say B
doesn't consume memory itself and B1 is inactive.  Does that mean B2
is guaranteed upto 16G?  Or is it that B2 is still guaranteed only
upto 10G?

If former, what if the intention was just to prevent B's total going
past 16G and the configuration never meant to grant extra 6G to B2?

The latter makes more sense as softlimit, but what happens when B
itself consumes memory?  Is B's internal consumption guaranteed any
memory?  If so, what if the internal usage is mostly uninteresting and
the admin never meant them to get any guarantee and it unnecessarily
eats into B1's guarantee when it comes up?  If not, what happens when
B1 creates a sub-cgroup B11?  Do all internal usages of B1 lose the
guarantee?

If I'm not too confused, most of the confusions arise from the fact
that guarantee's specificity is towards max (as evidenced by its
default being zero) but composition through hierarchy happening in the
other direction (ie. guarantee in internal node exerts pressure
towards zero on its subtree).

Doesn't something like the following suit what you had in mind better?

 h: hardlimit, s: softlimit, g: guarantee

        root (physical memory = 32G)
       /    \
      A      B (h:25G, s:16G)
     / \    / \
    A1 A2  /   B2 (g:10G)
          /
         B1 (g:15G)

It doesn't solve any of the execution issues arising from having to
enforce 16G limit over 10G and 15G guarnatees but there is no room for
misinterpreting the intention of the configuration.  You could say
that this is just a convenient case because it doesn't actually have
nesting of the same params.  Let's add one then.

        root (physical memory = 32G)
       /    \
      A      B (h:25G, s:16G g:15G)
     / \    / \
    A1 A2  /   B2 (g:10G)
          /
         B1 (g:15G)

If we follow the rule of composition by intersection, the
interpretation of B's guarantee is clear.  If B's subtree is under
15G, regardless of individual usages of B1 and B2, they shouldn't feel
reclaim pressure.  When B's subtree goes over 15G, B1 and B2 will have
to fend off for themselves.  If the ones which are over their own
guarantee will feel the "normal" reclaim pressure; otherwise, they
will continue to evade reclaim.  When B's subtree goes over 16G,
someone in B's subtree have to pay, preferably the ones not guaranteed
anything first.

> [ It may be conceivable that you want different guarantees for B1 and
>   B2 depending on where the pressure comes from.  One setting for when
>   the 25G limit applies, one setting when the 32G physical memory
>   limit applies.  Basically, every group would need a vector of
>   guarantee settings with one setting per ancestor.

I don't get this.  If a cgroup is under the guarantee limit and none
of its parents are under hard/softlimit, it shouldn't feel any
pressure.  If a cgroup ia above guarantee, it should feel the same
pressure everyone else in that subtree is subject to.  If any of the
ancestors has triggered soft / hard limit, it's gonna have to give up
pages pretty quickly.

>   That being said, I absolutely disagree with the idea of trying to
>   adhere to individual memcg guarantees in the first reclaim cycle,
>   regardless of context and then just ignore them on the second pass.
>   It's a horrible way to guess which context the admin had in mind. ]

I think there needs to be a way to avoid penalizing sub-cgroups under
guarnatee amount when there are siblings which can give out pages over
guarantee.  I don't think I'm following the "guessing the intention"
part.  Can you please elaborate?

> Now, there is of course the other scenario in which the current
> hierarchical limit application can get in your way: when you give
> intermediate nodes their own memory.  Because then you may see the
> need to apply certain limits to that hierarchy root's local memory
> only instead of all memory in the hierarchy.  But once we open that
> door, you might expect this to be an option for every limit, where
> even the hard limit of a hierarchy root only applies to that group's
> local memory instead of the whole hierarchy.  I certainly do not want
> to apply hierarchy semantics for some limits and not for others.  But
> Google has basically asked for hierarchical hard limits and local soft
> limits / guarantees.

So, proportional controllers need this.  They need to be able to
configure the amount the tasks belonging to an inner node can consume
when competing against the children groups.  It isn't a particularly
pretty thing but a necessity given that we allow tasks and resource
consumptions in inner nodes.  I was wondering about this and asked
Michal whether anybody wants something like that and IIRC his answer
was negative.  Can you please expand on what google asked for?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
