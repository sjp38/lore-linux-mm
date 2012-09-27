Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 2F47D6B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 13:46:26 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so4423461pbb.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:46:25 -0700 (PDT)
Date: Thu, 27 Sep 2012 10:46:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120927174605.GA2713@localhost>
References: <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
 <20120926221046.GA10453@mtj.dyndns.org>
 <506381B2.2060806@parallels.com>
 <20120926224235.GB10453@mtj.dyndns.org>
 <50638793.7060806@parallels.com>
 <20120926230807.GC10453@mtj.dyndns.org>
 <20120927142822.GG3429@suse.de>
 <20120927144942.GB4251@mtj.dyndns.org>
 <50646977.40300@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50646977.40300@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Thu, Sep 27, 2012 at 06:57:59PM +0400, Glauber Costa wrote:
> > Because we're not even trying to actually solve the problem but just
> > dumping it to userland.  If dentry/inode usage is the only case we're
> > being worried about, there can be better ways to solve it or at least
> > we should strive for that.
> 
> Not only it is not the only case we care about, this is not even touched
> in this series. (It is only touched in the next one). This one, for
> instance, cares about the stack. The reason everything is being dumped
> into "kmem", is precisely to make things simpler. I argue that at some
> point it makes sense to draw a line, and "kmem" is a much better line
> than any fine grained control - precisely because it is conceptually
> easier to grasp.

Can you please give other examples of cases where this type of issue
exists (plenty of shared kernel data structure which is inherent to
the workload at hand)?  Until now, this has been the only example for
this type of issues.

> > I think the cost isn't too prohibitive considering it's already using
> > memcg.  Charging / uncharging happens only as pages enter and leave
> > slab caches and the hot path overhead is essentially single
> > indirection.  Glauber's benchmark seemed pretty reasonable to me and I
> > don't yet think that warrants exposing this subtle tree of
> > configuration.
> 
> Only so we can get some numbers: the cost is really minor if this is all
> disabled. It this is fully enable, it can get to some 2 or 3 %, which
> may or may not be acceptable to an application. But for me this is not
> even about cost, and that's why I haven't brought it up so far

It seems like Mel's concern is mostly based on performance overhead
concerns tho.

> > The part I nacked is enabling kmemcg on a populated cgroup and then
> > starting accounting from then without any apparent indication that any
> > past allocation hasn't been considered.  You end up with numbers which
> > nobody can't tell what they really mean and there's no mechanism to
> > guarantee any kind of ordering between populating the cgroup and
> > configuring it and there's *no* way to find out what happened
> > afterwards neither.  This is properly crazy and definitely deserves a
> > nack.
> > 
> 
> Mel suggestion of not allowing this to happen once the cgroup has tasks
> takes care of this, and is something I thought of myself.

You mean Michal's?  It should also disallow switching if there are
children cgroups, right?

> This would remove this particular piece of objection, and maintain the
> per-subtree control.

Yeah, I don't see anything broken with that although I'll try to argue
for simpler one a bit more.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
