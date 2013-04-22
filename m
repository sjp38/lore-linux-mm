Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 54B116B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 00:24:52 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bg4so607788pad.23
        for <linux-mm@kvack.org>; Sun, 21 Apr 2013 21:24:51 -0700 (PDT)
Date: Sun, 21 Apr 2013 21:24:45 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422042445.GA25089@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

Hey, Michel.

> I don't remember exactly when you left - during the session I
> expressed to Michal that while I think his proposal is an improvement
> over the current situation, I think his handling of internal nodes is
> confus(ed/ing).

I think I stayed until near the end of the hierarchy discussion and
yeap I heard you saying that.

> I completely agree with you here. This is important to ensure
> composability - someone that was using cgroups within a 4GB system can
> be moved to use cgroups within a hierarchy with a 4GB soft limit on
> the root, and still have its performance isolated from tasks running
> in other cgroups in the system.

And for basic sanity.  As you look down through the hierarchy of
nested cgroups, the pressure exerted by a limit can only be increased
(IOW, the specificity of the control increases) as the level deepens,
regardless of the direction of such pressure, which is the only
logical thing to do for nested limits.

>> > Now, let's consider the following hierarchy just to be sure.  Let's
>> > assume that A itself doesn't have any tasks for simplicity.
>     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> >
>> >       A (h:16G s:4G)
>> >      /            \
>> >     /              \
>> >  B (h:7G s:5G)    C (h:7G s:5G)
>> >
>> > For hardlimit, it is clear that A's limit won't do anything.
>
> Now the above is a very interesting case.

It shouldn't be interesting at all.  It should be exactly the same.
If "softlimit" means actual soft limit prioritizing reclaim down to
that point under pressure, it works in the same direction as hardlimit
and the limits should behave the same.

If "softlimit" means allocation guarantee where a cgroup is exempt
from reclaim while under the limit, a knob defining allowance rather
than limit, the direction of specificity is flipped.  While the
direction is flipped, how it behaves should be the same.  Otherwise,
it ends up breaking the very basics of nesting.  Not a particularly
bright idea.

> One thing some people worry about is that B and C's configuration
> might be under a different administrator's control than A's. That is,
> we could have a situation where the machine's sysadmin set up A for
> someone else to play with, and that other person set up B and C within
> his cgroup. In this scenario, one of the issues has to be how do we
> prevent B and C's configuration settings from reserving (or protecting
> from reclaim) more memory than the machine's admin intended when he
> configured A.

Cgroup doesn't and will not support delegation of subtrees to
different security domains.  Please refer to the following thread.

  http://thread.gmane.org/gmane.linux.kernel.cgroups/6638

In fact, I'm planning to disallow changing ownership of cgroup files
when "sane_behavior" is specified.  We're having difficult time
identifying our own asses as it is and I have no intention of adding
the huge extra burden of security policing on top.  Delegation, if
necessary, will happen from userland.

> Michal's proposal resolves this by saying that A,B and C all become
> reclaimable as soon as A goes over its soft limit.

This makes me doubly upset and reminds me strongly of the
.use_hierarchy mess.  It's so myopic in coming up with a solution for
the problem immediately at hand, it ends up ignoring basic rules and
implementing something which is fundamentally broken and confused.
Don't twist basic nesting rules to accomodate half-assed delegation
mechanism.  It's never gonna work properly and we'll need
"really_sane_behavior" flag eventually to clean up the mess again, and
we'll probably have to clarify that for memcg the 'c' stands for
"confused" instead of "control".

And I don't even get the delegation argument.  Isn't that already
covered by hardlimit?  Sure, reclaimer won't look at it but if you
don't trust a cgroup it of course will be put under certain hardlimit
from parent and smacked when it misbehaves.  Hardlimit of course
should have priority over allocation guarantee and the system wouldn't
be in jeopardy due to a delegated cgroup misbehaving.  If each knob is
given a clear meaning, these things should come naturally.  You just
need a sane pecking order among the controls.  It almost feels surreal
that this is suggested as a rationale for creating this chimera of a
knob.  What the hell is going on here?

> I have a third view, which I talked about during Michal's
> presentation. I think that when A's usage goes over 4G, we should be
> able to reclaim from A's subtree. If B or C's usage are above their
> soft limits, then we should reclaim from these cgroups; however if
> both B and C have usage below their soft limits, then we are in a
> situation where the soft limits can't be obeyed so we should ignore
> them and reclaim from both B and C instead.

No, the config is valid and *exactly* the same as hardlimit case.
It's just in the opposite direction.  Don't twist it.  It's exactly
the same mechanics.  Flipping the direction should not change what
nesting means.  That's what you get and should get when cgroup nesting
is used for something which "guarantees" rather than "limits".

Whatever twsit you think is a good idea for "softlimit", try to flip
the direction and apply it the same to "hardlimit" and see how messed
up it gets.

> Regardless about these differences, I still want to stress out that
> Michal's proposal is a clear improvement over what we have, so I see
> it as a large step in the right direction.

I'm afraid I don't agree with that.  If the current situation is
ambiguous, moving to a definite wrong state makes the situation worse,
so we need to figure out what this thing actually means first, and
it's not like it is a difficult choice to make.  It's either actual
soft limit or allocation guarantee.  It cannot be some random
combination of the two.  Just pick one and stick with it.

>> Now I'm confused.  You're saying softlimit currently doesn't guarantee
>> anything and what it means, even for flat hierarchy, isn't clearly
>> defined?
>
> The largest problem with softlimit today is that global reclaim
> doesn't take it into account at all... So yes, I would say that
> softlimit is very badly defined today (which may be why people have
> such trouble agreeing about what it should mean in the first place).

So, in that case, let's please make "softlimit" an actual soft limit
working in the same direction as hardlimit but works in terms of
reclaim pressure rather than OOM killing, and please don't tell me how
"softlimit" working in the opposite direction of "hardlimit" actually
makes sense in the wonderland of memcg.  Please have at least some
common sense. :(

If people need "don't reclaim under this limit", IOW allocation
guarantee, please introduce another knob with proper name and properly
flipped hierarchy behavior.

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
