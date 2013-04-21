Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A45796B0032
	for <linux-mm@kvack.org>; Sun, 21 Apr 2013 04:55:07 -0400 (EDT)
Received: by mail-ia0-f175.google.com with SMTP id i38so390780iae.6
        for <linux-mm@kvack.org>; Sun, 21 Apr 2013 01:55:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130421022321.GE19097@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
	<20130420031611.GA4695@dhcp22.suse.cz>
	<20130421022321.GE19097@mtj.dyndns.org>
Date: Sun, 21 Apr 2013 01:55:06 -0700
Message-ID: <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
Subject: Re: memcg: softlimit on internal nodes
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

Hi Tejun,

I don't remember exactly when you left - during the session I
expressed to Michal that while I think his proposal is an improvement
over the current situation, I think his handling of internal nodes is
confus(ed/ing).

On Sat, Apr 20, 2013 at 7:23 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Michal.
>
> On Fri, Apr 19, 2013 at 08:16:11PM -0700, Michal Hocko wrote:
>> > For example, please consider the following hierarchy where s denotes
>> > the "softlimit" and h hardlimit.
>> >
>> >       A (h:8G s:4G)
>> >      /            \
>> >     /              \
>> >  B (h:5G s:1G)    C (h:5G s:1G)
> ...
>> > It must not be any different for "softlimit".  If B or C are
>> > individually under 1G, they won't be targeted by the reclaimer and
>> > even if B and C are over 1G, let's say 2G, as long as the sum is under
>> > A's "softlimit" - 4G, reclaimer won't look at them.

I completely agree with you here. This is important to ensure
composability - someone that was using cgroups within a 4GB system can
be moved to use cgroups within a hierarchy with a 4GB soft limit on
the root, and still have its performance isolated from tasks running
in other cgroups in the system.

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

Now the above is a very interesting case.

One thing some people worry about is that B and C's configuration
might be under a different administrator's control than A's. That is,
we could have a situation where the machine's sysadmin set up A for
someone else to play with, and that other person set up B and C within
his cgroup. In this scenario, one of the issues has to be how do we
prevent B and C's configuration settings from reserving (or protecting
from reclaim) more memory than the machine's admin intended when he
configured A.

Michal's proposal resolves this by saying that A,B and C all become
reclaimable as soon as A goes over its soft limit.

Tejun's proposal (as I understand it) is that B and C protected from
reclaim until they grow to 5G each, as their soft limits indicate.

I have a third view, which I talked about during Michal's
presentation. I think that when A's usage goes over 4G, we should be
able to reclaim from A's subtree. If B or C's usage are above their
soft limits, then we should reclaim from these cgroups; however if
both B and C have usage below their soft limits, then we are in a
situation where the soft limits can't be obeyed so we should ignore
them and reclaim from both B and C instead.

The idea is that I think soft limits should follow these design principles:
- Soft limits are used to steer reclaim. We should try to avoid
reclaiming from cgroups that are under their soft limits. However,
soft limits can't completely prevent reclaim - if all cgroups are
under their soft limits, then the soft limits become meaningless and
all cgroups become eligible for being reclaimed from (this is a
situation that the sysadmin can largely avoid by not over-committing
the soft limits).
- A child cgroup should not be able to grab more resources than its
parent (this is for the situation where the parent and child cgroups
might be under separate administrative control). So when a parent
cgroup hits its soft limit, the child cgroup soft limits should not be
able to prevent us from reclaiming from that hierarchy. The child
cgroup soft limits should still be obeyed to steer reclaim within the
hierarchy when possible, though.


Regardless about these differences, I still want to stress out that
Michal's proposal is a clear improvement over what we have, so I see
it as a large step in the right direction.

> Now I'm confused.  You're saying softlimit currently doesn't guarantee
> anything and what it means, even for flat hierarchy, isn't clearly
> defined?

The largest problem with softlimit today is that global reclaim
doesn't take it into account at all... So yes, I would say that
softlimit is very badly defined today (which may be why people have
such trouble agreeing about what it should mean in the first place).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
