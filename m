Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1C2D56B01C1
	for <linux-mm@kvack.org>; Fri, 28 May 2010 02:38:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S6cPRN011918
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 15:38:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7545645DE4F
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5573E45DE4D
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4248DE08001
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB70D1DB803C
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100528062701.GA3519@balbir.in.ibm.com>
References: <20100528134133.7E24.A69D9226@jp.fujitsu.com> <20100528062701.GA3519@balbir.in.ibm.com>
Message-Id: <20100528153410.7E30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 15:38:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-05-28 13:46:53]:
> 
> > > * Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:
> > > 
> > > > @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> > > >   */
> > > >  static void __oom_kill_task(struct task_struct *p, int verbose)
> > > >  {
> > > > +	struct sched_param param;
> > > > +
> > > >  	if (is_global_init(p)) {
> > > >  		WARN_ON(1);
> > > >  		printk(KERN_WARNING "tried to kill init!\n");
> > > > @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> > > >  	 */
> > > >  	p->rt.time_slice = HZ;
> > > >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > > > -
> > > >  	force_sig(SIGKILL, p);
> > > > +	param.sched_priority = MAX_RT_PRIO-1;
> > > > +	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> > > >  }
> > > >
> > > 
> > > I would like to understand the visible benefits of this patch. Have
> > > you seen an OOM kill tasked really get bogged down. Should this task
> > > really be competing with other important tasks for run time?
> > 
> > What you mean important? Until OOM victim task exit completely, the system have no memory.
> > all of important task can't do anything.
> > 
> > In almost kernel subsystems, automatically priority boost is really bad idea because
> > it may break RT task's deterministic behavior. but OOM is one of exception. The deterministic
> > was alread broken by memory starvation.
> >
> 
> I am still not convinced, specially if we are running under mem
> cgroup. Even setting SCHED_FIFO does not help, you could have other
> things like cpusets that might restrict the CPUs you can run on, or
> any other policy and we could end up contending anyway with other
> SCHED_FIFO tasks.

Ah, right you are. I had missed mem-cgroup.
But I think memcgroup also don't need following two boost. Can we get rid of it?

	p->rt.time_slice = HZ;
	set_tsk_thread_flag(p, TIF_MEMDIE);


I mean we need distinguish global oom and memcg oom, perhapls. 


> > That's the reason I acked it.
> 
> If we could show faster recovery from OOM or anything else, I would be
> more convinced.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
