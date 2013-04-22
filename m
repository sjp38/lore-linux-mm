Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E3BD16B0034
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:37:32 -0400 (EDT)
Date: Mon, 22 Apr 2013 17:37:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422153730.GG18286@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
 <20130422042445.GA25089@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422042445.GA25089@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

On Sun 21-04-13 21:24:45, Tejun Heo wrote:
[...]
> Cgroup doesn't and will not support delegation of subtrees to
> different security domains.  Please refer to the following thread.
> 
>   http://thread.gmane.org/gmane.linux.kernel.cgroups/6638
> 
> In fact, I'm planning to disallow changing ownership of cgroup files
> when "sane_behavior" is specified. 

I would be wildly oposing this. Enabling user to play on its own ground
while above levels of the groups enforce the reasonable behavior is very
important use case.

> We're having difficult time identifying our own asses as it is and I
> have no intention of adding the huge extra burden of security policing
> on top.  Delegation, if necessary, will happen from userland.

> > Michal's proposal resolves this by saying that A,B and C all become
> > reclaimable as soon as A goes over its soft limit.
> 
> This makes me doubly upset and reminds me strongly of the
> .use_hierarchy mess.  It's so myopic in coming up with a solution for
> the problem immediately at hand, it ends up ignoring basic rules and
> implementing something which is fundamentally broken and confused.

Tejun, stop this, finally! Current soft limit same as the reworked
version follow the basic nesting rule we use for the hard limit which
says that parent setting is always more strict than its children.
So if you parent says you are hitting the hardlimit (resp. over soft
limit) then children are reclaimed regardless their hard/soft limit
setting.

> Don't twist basic nesting rules to accomodate half-assed delegation
> mechanism.  It's never gonna work properly and we'll need
> "really_sane_behavior" flag eventually to clean up the mess again, and
> we'll probably have to clarify that for memcg the 'c' stands for
> "confused" instead of "control".
> 
> And I don't even get the delegation argument.  Isn't that already
> covered by hardlimit?

No it's not, because you want to overcommit the memory between different
groups. And soft limit is a way how to handle memory pressure gracefully
in contented situations.

> Sure, reclaimer won't look at it but if you don't trust a cgroup
> it of course will be put under certain hardlimit from parent and
> smacked when it misbehaves.  Hardlimit of course should have priority
> over allocation guarantee and the system wouldn't be in jeopardy due
> to a delegated cgroup misbehaving.  If each knob is given a clear
> meaning, these things should come naturally.  You just need a sane
> pecking order among the controls.  It almost feels surreal that this
> is suggested as a rationale for creating this chimera of a knob.  What
> the hell is going on here?

It is you being confused and refuse to open the damn documentation and
read what the hack is soft limit and what it is used for. Read the patch
series I was talking about and you will hardly find anything regarding
_guarantee_.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
