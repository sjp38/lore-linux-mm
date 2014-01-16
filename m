Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4732D6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:12:21 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so1425817eek.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 02:12:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si252782eep.85.2014.01.16.02.12.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 02:12:15 -0800 (PST)
Date: Thu, 16 Jan 2014 11:12:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM
 access to memory reserves
Message-ID: <20140116101214.GD28157@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz>
 <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
 <20140108103319.GF27937@dhcp22.suse.cz>
 <20140109143048.GE27538@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401091335450.31538@chino.kir.corp.google.com>
 <20140110082302.GD9437@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401101327430.21486@chino.kir.corp.google.com>
 <20140115142603.GM8782@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401151304430.10727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401151304430.10727@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Wed 15-01-14 13:19:21, David Rientjes wrote:
> On Wed, 15 Jan 2014, Michal Hocko wrote:
> 
> > > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > > index b8dfed1b9d87..b86fbb04b7c6 100644
> > > > > > --- a/mm/memcontrol.c
> > > > > > +++ b/mm/memcontrol.c
> > > > > > @@ -2685,7 +2685,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > > > > >  	 * MEMDIE process.
> > > > > >  	 */
> > > > > >  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > > > > > -		     || fatal_signal_pending(current)))
> > > > > > +		     || fatal_signal_pending(current))
> > > > > > +		     || current->flags & PF_EXITING)
> > > > > >  		goto bypass;
> > > > > >  
> > > > > >  	if (unlikely(task_in_memcg_oom(current)))
> > > > > 
> > > > > This would become problematic if significant amount of memory is charged 
> > > > > in the exit() path. 
> > > > 
> > > > But this would hurt also for fatal_signal_pending tasks, wouldn't it?
> > > 
> > > Yes, and as I've said twice now, that should be removed. 
> > 
> > And you failed to provide any relevant data to back your suggestions. I
> > have told you that we have these heuristics for ages and we need a
> > strong justification to drop them. So if you really think that they are
> > not appropriate then back your statements with real data.
> > 
> > E.g. measure how much memory are we talking about.
> 
> The heuristic may have existed for ages, but the proposed memcg 
> configuration for preserving memory such that userspace oom handlers may 
> run such as
> 
> 			 _____root______
> 			/		\
> 		    user		 oom
> 		   /	\		/   \
> 		   A	B	 	a   b
> 
> where user/memory.limit_in_bytes == [amount of present RAM] + 
> oom/memory.limit_in_bytes - [some fudge] causes all bypasses to be 
> problematic, including Johannes' buggy bypass for charges in memcgs with 
> pending memcgs that has since been fixed after I identified it.  This 
> bypass is included.  Processes attached to "a" and "b" are userspace oom 
> handlers for processes attached to "A" and "B", respectively.
> 
> The amount of memory you're talking about is proportional to the number of 
> processes that have pending SIGKILLs (and now those with PF_EXITING set), 
> the former of which is obviously more concerning since they could be 
> charging memory at any point in the kernel that would succeed. 

I understand your concerns. Yes, excessive charges might be dangerous. I
haven't dismissed that when you mentioned it earlier. I am just
repeatedly asking how much memory are we talking about, how real is the
issue and what are all the other conseqeunces. And for some reason you
are not providing that information (or maybe I am just not seeing that
in your responses) and that is why we are stuck in circle.

For example your some_fudge needs to consider memory which is not
accounted for. That is rather hard to predict because it depends
on drivers (or whoever calls page allocator directly) you have and
the current load. Also all tasks living in the root memcg are not
accounted. So you would need to have some pillow to be safe. Do
fatal_signal_pending tasks allocate way much more than your pillow?

I am also not sure whether fatal_signal_pending failing charge (without
going via OOM which would set TIF_MEMDIE) could prevent exiting task.

Finally there is still a risk for regressions when a killed task causes a
pointless reclaim just to free few pages for a task which will free
memory few seconds later.

> The latter 
> is concerning only if future memory allocation post-PF_EXITING would be 
> become significant and nobody is going to think about oom memcg bypasses 
> in such a case.
> 
> To use the configuration suggested above, we need to prevent as many 
> bypasses as possible to the root memcg.  Otherwise, the memory protected 
> for the "oom" memcg from processes constrained by the limit of "user" is 
> no longer protected.  This isn't only a problem with the bypasses here in 
> the charging path, but also unaccounted kernel memory, for example.

Yes, and apart from GFP_NOFAIL we are allowing to bypass only those that
should terminate in a short time. I think that having a setup with a
guarantee of never triggering the global OOM is too ambitious and I am
even skeptical it would be achievable.

> For this to be usable, we need to ensure that the limit of the "oom" memcg 
> is protected for the userspace oom handlers that are attached.  With a 
> charge bypassed to the root memcg greater than or equal to the limit of 
> the "oom" memcg OR cumulative charges bypassed to the root memcg greater 
> than or equal to the limit of the "oom" memcg by processes with pending 
> SIGKILLs, userspace oom handlers cannot respond.  That's particuarly 
> dangerous without a memcg oom kill delay, as proposed before, since 
> userspace must disable oom killing entirely for both "A" and "B" for 
> userspace notification to be meaningful, since all processes are now 
> livelocked.
> 
> > > These bypasses should be given to one thread and one thread only,
> > > which would be the oom killed thread if it needs access to memory
> > > reserves to either allocate memory or charge memory.
> > 
> > There is no way to determine whether a task has been killed due to user
> > space OOM killer or by a regular kill.
> > 
> 
> I'm referring to only granting TIF_MEMDIE to a single process in any memcg 
> hierarchy at or below the memcg that has encountered its limit to avoid 

The point was that TIF_MEMDIE handling for user OOM killed tasks is
tricky if implementable at all. If you check for fatal_signal_pending
after schedule returns in mem_cgroup_oom_synchronize then you might get
access to other fatal_signal_pending tasks as well.

> granting it to many processes and bypassing their charges to the root 
> memcg; the same variation of the above code, but going through the memcg 
> oom killer to get TIF_MEMDIE first.  We must be vigilant and only grant 
> TIF_MEMDIE for the process that shall exit.
>
> > > If you are suggesting we use the "user" and "oom" top-level memcg 
> > > hierarchy for allowing memory to be available for userspace system oom 
> > > handlers, then this has become important when in the past it may have been 
> > > a minor point.
> > 
> > I am not sure it would be _that_ important and if that really becomes to
> > be the case then we should deal with it. So far I haven't see any
> > evidence there is a lot of memory charged on the exit path.
> > 
> 
> I'm debating both fatal_signal_pending() and PF_EXITING here since they 
> are now both bypasses, we need to remove fatal_signal_pending().  My 
> simple question with your patch: how do you guarantee memory to processes 
> attached to "a" and "b"?

The only way you can get that _guarantee_ is to account all the memory
allocations. And that is not implemented and I would even question
whether it is worthwhile. So we still have to live with a possibility
of triggering the global OOM killer. That's why I believe we need to be
able to tell the kernel what is the user policy for oom killer (that is
a different discussion though).

So it all boils down to have sufficient pillow when your above hierarchy
is configured. You would need it even without fatal_signal_pending
resp. PF_EXITING bypasses. If we want to get rid of any bypass heuristic
then we have to show that the pillow would be unreasonably high to
handle regular loads or that the code path which triggers that is not
fixable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
