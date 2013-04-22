Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 493226B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 10:48:32 -0400 (EDT)
Received: by mail-da0-f45.google.com with SMTP id v40so3172095dad.4
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 07:48:31 -0700 (PDT)
Date: Mon, 22 Apr 2013 07:48:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422144826.GA12543@htj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
 <20130422042445.GA25089@mtj.dyndns.org>
 <CANN689F7X1X4i1M=nteGan0POdVbBMu0xviuWN70f_BTv==3eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689F7X1X4i1M=nteGan0POdVbBMu0xviuWN70f_BTv==3eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

Hello, again.

On Mon, Apr 22, 2013 at 12:14:53AM -0700, Michel Lespinasse wrote:
> > I think I stayed until near the end of the hierarchy discussion and
> > yeap I heard you saying that.
> 
> All right. Too bad you had to leave - I think this is a discussion we
> really need to have, so it would have been the perfect occasion.

Eh well, it would have been better if I stayed but I think it served
its purpose.  Conferences are great for raising awareness.  I usually
find actual follow-up discussions done better in mailing lists.

> > Cgroup doesn't and will not support delegation of subtrees to
> > different security domains.  Please refer to the following thread.
> >
> >   http://thread.gmane.org/gmane.linux.kernel.cgroups/6638
> 
> Ah, good. This is news to me. To be clear, I don't care much for the
> delegation scenario myself, but it's always been mentioned as the
> reason I couldn't get what I want when we've talked about hierarchical
> soft limit behavior in the past. If the decision not to have subtree
> delegation sticks, I am perfectly happy with your proposal.

Oh, it's sticking. :)

> > And I don't even get the delegation argument.  Isn't that already
> > covered by hardlimit?  Sure, reclaimer won't look at it but if you
> > don't trust a cgroup it of course will be put under certain hardlimit
> > from parent and smacked when it misbehaves.  Hardlimit of course
> > should have priority over allocation guarantee and the system wouldn't
> > be in jeopardy due to a delegated cgroup misbehaving.  If each knob is
> > given a clear meaning, these things should come naturally.  You just
> > need a sane pecking order among the controls.  It almost feels surreal
> > that this is suggested as a rationale for creating this chimera of a
> > knob.  What the hell is going on here?
> 
> People often overcommit the cgroup hard limits so that one cgroup can
> make use of a larger share of the machine when the other cgroups are
> idle.
> This works well only if you can depend on soft limits to steer reclaim
> when the other cgroups get active again.

And that's fine too.  If you take a step back, it shouldn't be
difficult to recognize that what you want is an actual soft limit at
the parent level overriding the allocation guarantee (for the lack of
a better name).  Don't overload "alloc guarantee" with that extra
meaning messing up its fundamental properties.  Create a separate
plane of control which is consistent within itself and give it
priority over "alloc guarantee".  You sure can discuss the details of
the override - should it be round-robin or proportional to whatever or
what, but that's a separate discussion and can be firmly labeled as
implementation details rather than this twisting of the fundamental
semantics of "softlimit".

I really am not saying any of the use cases that have been described
are invalid.  They all sound pretty useful, but, to me, what seems to
be recurring is that people want two separate features - actual soft
limit and allocation guarantee, and for some reason that I can't
understand, fail to recognize they're two very different controls and
try to put both into this one poor knob.

It's like trying to combine accelerator and (flipped) clutch on a
manual car.  Sure, it'll work fine while you're accelerating.  Good
luck while cruising or on a long downhill.  You can try to tweak it
all you want but things of course will get "interesting" and
"questionable" as soon as the conditions change from the specific use
cases which the specific tuning is made for.

While car analogies can often be misleading, really, please stop
trying to combine two completely separate controls into one knob.  It
won't and can't work and is totally stupid.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
