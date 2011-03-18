Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C68108D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 16:33:02 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p2IKWtqY026006
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:32:55 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe15.cbf.corp.google.com with ESMTP id p2IKVoaK005548
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:32:54 -0700
Received: by pxi19 with SMTP id 19so596041pxi.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:32:50 -0700 (PDT)
Date: Fri, 18 Mar 2011 13:32:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: give current access to memory reserves if it's
 trying to die
In-Reply-To: <20110317165319.07be118e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103181321580.27112@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
 <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
 <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com> <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
 <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com> <alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com> <20110317165319.07be118e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 17 Mar 2011, Andrew Morton wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -537,6 +537,17 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
> >  	unsigned int points = 0;
> >  	struct task_struct *p;
> >  
> > +	/*
> > +	 * If current has a pending SIGKILL, then automatically select it.  The
> > +	 * goal is to allow it to allocate so that it may quickly exit and free
> > +	 * its memory.
> > +	 */
> > +	if (fatal_signal_pending(current)) {
> > +		set_thread_flag(TIF_MEMDIE);
> > +		boost_dying_task_prio(current, NULL);
> > +		return;
> > +	}
> > +
> >  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
> >  	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
> >  	read_lock(&tasklist_lock);
> 
> The code duplication seems a bit gratuitous.
> 

I thought it was small enough to appear in two functions as opposed to 
doing something like

	static bool oom_current_has_sigkill(void)
	{
		if (fatal_signal_pending(current)) {
			set_thread_flag(TIF_MEMDIE);
			boost_dying_task_prio(current, NULL);
			return true;
		}
		return false;
	}

then doing

	if (oom_current_has_sigkill())
		return;

in mem_cgroup_out_of_memory() and out_of_memory().  If you'd prefer 
oom_current_has_sigkill(), let me know and I'll propose an alternate 
version.

> Was it deliberate that mem_cgroup_out_of_memory() ignores the oom
> notifier callbacks?
> 

Yes, the memory controller requires that something be killed (or, in the 
above case, simply allowing something to exit) to return under the hard 
limit; that's why we automatically kill current if nothing else eligible 
is found in select_bad_process().  Using oom notifier callbacks wouldn't 
guarantee there was freeing that would impact this memcg anyway.

> (Why does that notifier list exist at all?  Wouldn't it be better to do
> this via a vmscan shrinker?  Perhaps altered to be passed the scanning
> priority?)
> 

A vmscan shrinker seems more appropriate in the page allocator and not the 
oom killer before we call out_of_memory() and, as already mentioned, 
oom_notify_list doesn't do much at all (and is the wrong thing to do for 
cpusets or mempolicy ooms).  I've been reluctant to remove it because it 
doesn't have any impact for our systems but was obviously introduced for 
somebody's advantage in a rather unintrusive way. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
