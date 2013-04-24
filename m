Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 81C596B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 17:45:57 -0400 (EDT)
Date: Wed, 24 Apr 2013 17:45:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130424214531.GA18686@cmpxchg.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422183020.GF12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Mon, Apr 22, 2013 at 11:30:20AM -0700, Tejun Heo wrote:
> Hey,
> 
> On Mon, Apr 22, 2013 at 06:20:12PM +0200, Michal Hocko wrote:
> > Although the default limit is correct it is impractical for use
> > because it doesn't allow for "I behave do not reclaim me if you can"
> > cases. And we can implement such a behavior really easily with backward
> > compatibility and new interfaces (aka reuse the soft limit for that).
> 
> Okay, now we're back to square one and I'm reinstating all the mean
> things I said in this thread. :P No wonder everyone is so confused
> about this.  Michal, you can't overload two controls which exert
> pressure on the opposite direction onto a single knob and define a
> sane hierarchical behavior for it.  You're making it a point control
> rather than range one.  Maybe you can define some twisted rules
> serving certain specific use case, but it's gonna be confusing /
> broken for different use cases.

Historically soft limit meant prioritizing certain memcgs over others
and the memcgs over their soft limit should experience relatively more
reclaim pressure than the ones below their soft limit.

Now, if we go and say you are only reclaimed when you exceed your soft
limit we would retain the prioritization aspect.  Groups in excess of
their soft limits would still experience relatively more reclaim
pressure than their well-behaved peers.  But it would have the nice
side effect of acting more or less like a guarantee as well.

I don't think this approach is as unreasonable as you make it out to
be, but it does make things more complicated.  It could be argued that
we should add a separate guarantee knob because two simple knobs might
be better than a complicated one.

The question is whether this solves Google's problem, though.

Currently, when a memcg is selected for a certain type of reclaim, it
and all its children are treated as one single leaf entity in the
overall hierarchy: when a parent node hits its hard limit, we assume
equal fault of every member in the hierarchy for that situation and,
consequently, we reclaim all of them equally.  We do the same thing
for the soft limit: if the parent, whose memory consumption is defined
as the sum of memory consumed by all members of the hierarchy,
breaches the soft limit then all members are reclaimed equally because
no single member is more at fault than the others.  I would expect if
we added a guarantee knob, this would also mean that no individual
memcg can be treated as being within their guaranteed memory if the
hierarchy as a whole is in excess of its guarantee.

The root of the hierarchy represents the whole hierarchy.  Its memory
usage is the combined memory usage of all members.  The limit set to
the hierarchy root applies to the combined memory usage of the
hierarchy.  Breaching that limit has consequences for the hierarchy as
a whole.  Be it soft limit or guarantee.

This is how hierarchies have always worked and it allows limits to be
layered and apply depending on the source of pressure:

       root (physical memory = 32G)
      /    \
     A      B (hard limit = 25G, guarantee = 16G)
    / \    / \
   A1 A2  /   B2 (guarantee = 10G)
         /
        B1 (guarantee = 15G)

Remember that hard limits are usually overcommitted, so you allow B to
use more of the fair share of memory when A does not need it, but you
want to keep it capped to keep latency reasonable when A ramps up.

As long as B is hitting its own hard limit, you value B1's and B2's
guarantees in the context of pressure local to the hierarchy; in the
context of B having 25G worth of memory; in the context of B1
competing with B2 over the memory allowed by B.

However, as soon as global reclaim kicks in, the context changes and
the priorities shift.  Now, B does not have 25G anymore but only 16G
*in its competition with A*.  We absolutely do not want to respect the
guarantees made to B1 and B2.  Not only can they not be met anyway,
but they are utterly meaningless at this point.  They were set with
25G in mind.

[ It may be conceivable that you want different guarantees for B1 and
  B2 depending on where the pressure comes from.  One setting for when
  the 25G limit applies, one setting when the 32G physical memory
  limit applies.  Basically, every group would need a vector of
  guarantee settings with one setting per ancestor.

  That being said, I absolutely disagree with the idea of trying to
  adhere to individual memcg guarantees in the first reclaim cycle,
  regardless of context and then just ignore them on the second pass.
  It's a horrible way to guess which context the admin had in mind. ]

Now, there is of course the other scenario in which the current
hierarchical limit application can get in your way: when you give
intermediate nodes their own memory.  Because then you may see the
need to apply certain limits to that hierarchy root's local memory
only instead of all memory in the hierarchy.  But once we open that
door, you might expect this to be an option for every limit, where
even the hard limit of a hierarchy root only applies to that group's
local memory instead of the whole hierarchy.  I certainly do not want
to apply hierarchy semantics for some limits and not for others.  But
Google has basically asked for hierarchical hard limits and local soft
limits / guarantees.

In summary, we are now looking at both local and hierarchical limits
times number of ancestors PER MEMCG to support all those use cases
properly.

So I'm asking what I already asked a year ago: are you guys sure you
can not change your cgroup tree layout and that we have to solve it by
adding new limit semantics?!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
