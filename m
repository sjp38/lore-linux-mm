Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 75F526B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:33:06 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id j7so4623782qaq.13
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:33:06 -0800 (PST)
Received: from mail-gg0-x233.google.com (mail-gg0-x233.google.com [2607:f8b0:4002:c02::233])
        by mx.google.com with ESMTPS id k3si969845qaf.133.2014.01.10.13.33.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 13:33:05 -0800 (PST)
Received: by mail-gg0-f179.google.com with SMTP id e5so365643ggh.38
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:33:05 -0800 (PST)
Date: Fri, 10 Jan 2014 13:33:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM
 access to memory reserves
In-Reply-To: <20140110082302.GD9437@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401101327430.21486@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com> <20131217162342.GG28991@dhcp22.suse.cz> <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com> <20131218200434.GA4161@dhcp22.suse.cz> <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <20140108103319.GF27937@dhcp22.suse.cz> <20140109143048.GE27538@dhcp22.suse.cz> <alpine.DEB.2.02.1401091335450.31538@chino.kir.corp.google.com>
 <20140110082302.GD9437@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Fri, 10 Jan 2014, Michal Hocko wrote:

> > > ---
> > >  mm/memcontrol.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index b8dfed1b9d87..b86fbb04b7c6 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2685,7 +2685,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  	 * MEMDIE process.
> > >  	 */
> > >  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > > -		     || fatal_signal_pending(current)))
> > > +		     || fatal_signal_pending(current))
> > > +		     || current->flags & PF_EXITING)
> > >  		goto bypass;
> > >  
> > >  	if (unlikely(task_in_memcg_oom(current)))
> > 
> > This would become problematic if significant amount of memory is charged 
> > in the exit() path. 
> 
> But this would hurt also for fatal_signal_pending tasks, wouldn't it?

Yes, and as I've said twice now, that should be removed.  These bypasses 
should be given to one thread and one thread only, which would be the oom 
killed thread if it needs access to memory reserves to either allocate 
memory or charge memory.

If you are suggesting we use the "user" and "oom" top-level memcg 
hierarchy for allowing memory to be available for userspace system oom 
handlers, then this has become important when in the past it may have been 
a minor point.

> Besides that I do not see any source of allocation after exit_signals.
> 

That's fine for today but may not be in the future.  If memory allocation 
is done after PF_EXITING in the future, are people going to check memcg 
bypasses?  No.  And now we have additional memory bypass to root that will 
cause our userspace system oom hanlders to be oom themselves with the 
suggested configuration.

Using the "user" and "oom" top-level memcg hierarchy is a double edged 
sword, we must attempt to prevent all of these bypasses as much as 
possible.  The only relevant bypass here is for TIF_MEMDIE which would be 
set if necessary for the one thread that needs it.

> > I don't know of an egregious amount of memory being 
> > allocated and charged after PF_EXITING is set, but if it happens in the 
> > future then this could potentially cause system oom conditions even in 
> > memcg configurations 
> 
> Even if that happens then the global OOM killer would give the exiting
> task access to memory reserves and wouldn't kill anything else.
> 
> So I am not sure what problem do you see exactly.
> 

Userspace system oom handlers being able to handle memcg oom conditions in 
the top-level "user" memcg as proposed by Tejun.  If the global oom killer 
becomes a part of that discussion at all, then the userspace system oom 
handler never got a chance to handle the "user" oom.

> Besides that allocating egregious amount of memory after exit_signals
> sounds fundamentally broken to me.
> 

Egregious could be defined as allocating a few bytes multiplied by 
thousands of threads in PF_EXITING.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
