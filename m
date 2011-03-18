Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8A048D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:43:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB1E83EE0C0
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:43:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B260745DF47
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:43:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 91DF945DED9
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:43:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 806B4E08003
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:43:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A143E08001
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:43:32 +0900 (JST)
Date: Fri, 18 Mar 2011 13:35:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: give current access to memory reserves if it's
 trying to die
Message-Id: <20110318133534.818707d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110317165319.07be118e.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
	<20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
	<20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
	<20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
	<20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
	<20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
	<20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com>
	<20110317165319.07be118e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 17 Mar 2011 16:53:19 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 9 Mar 2011 13:27:50 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > When a memcg is oom and current has already received a SIGKILL, then give
> > it access to memory reserves with a higher scheduling priority so that it
> > may quickly exit and free its memory.
> > 
> > This is identical to the global oom killer and is done even before
> > checking for panic_on_oom: a pending SIGKILL here while panic_on_oom is
> > selected is guaranteed to have come from userspace; the thread only needs
> > access to memory reserves to exit and thus we don't unnecessarily panic
> > the machine until the kernel has no last resort to free memory.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |   11 +++++++++++
> >  1 files changed, 11 insertions(+), 0 deletions(-)
> > 
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
> 
> 
> Was it deliberate that mem_cgroup_out_of_memory() ignores the oom
> notifier callbacks?
> 

I'm not sure for what purpose notifier chain for oom exists.
At a loock, it's for s390/powerpc Collaborative Memory Manager.. ?

About memcg, notifier to userland already exists and I though I don't
need to call CMM callbacks (for now, there is no user with memcg, I guess.)

Thanks,
-kame

> (Why does that notifier list exist at all?  Wouldn't it be better to do
> this via a vmscan shrinker?  Perhaps altered to be passed the scanning
> priority?)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
