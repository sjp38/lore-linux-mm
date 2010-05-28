Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C11E6B01C1
	for <linux-mm@kvack.org>; Fri, 28 May 2010 02:27:16 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp07.au.ibm.com (8.14.3/8.13.1) with ESMTP id o4S6RE8n008652
	for <linux-mm@kvack.org>; Fri, 28 May 2010 16:27:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4S6RAcd1589462
	for <linux-mm@kvack.org>; Fri, 28 May 2010 16:27:12 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4S6R9L9032514
	for <linux-mm@kvack.org>; Fri, 28 May 2010 16:27:10 +1000
Date: Fri, 28 May 2010 11:57:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528062701.GA3519@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100528035147.GD11364@uudg.org>
 <20100528043339.GZ3519@balbir.in.ibm.com>
 <20100528134133.7E24.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100528134133.7E24.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-05-28 13:46:53]:

> > * Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:
> > 
> > > @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> > >   */
> > >  static void __oom_kill_task(struct task_struct *p, int verbose)
> > >  {
> > > +	struct sched_param param;
> > > +
> > >  	if (is_global_init(p)) {
> > >  		WARN_ON(1);
> > >  		printk(KERN_WARNING "tried to kill init!\n");
> > > @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> > >  	 */
> > >  	p->rt.time_slice = HZ;
> > >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > > -
> > >  	force_sig(SIGKILL, p);
> > > +	param.sched_priority = MAX_RT_PRIO-1;
> > > +	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> > >  }
> > >
> > 
> > I would like to understand the visible benefits of this patch. Have
> > you seen an OOM kill tasked really get bogged down. Should this task
> > really be competing with other important tasks for run time?
> 
> What you mean important? Until OOM victim task exit completely, the system have no memory.
> all of important task can't do anything.
> 
> In almost kernel subsystems, automatically priority boost is really bad idea because
> it may break RT task's deterministic behavior. but OOM is one of exception. The deterministic
> was alread broken by memory starvation.
>

I am still not convinced, specially if we are running under mem
cgroup. Even setting SCHED_FIFO does not help, you could have other
things like cpusets that might restrict the CPUs you can run on, or
any other policy and we could end up contending anyway with other
SCHED_FIFO tasks.
 
> That's the reason I acked it.

If we could show faster recovery from OOM or anything else, I would be
more convinced.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
