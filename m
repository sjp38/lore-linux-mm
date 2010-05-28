Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C7A8360032A
	for <linux-mm@kvack.org>; Fri, 28 May 2010 00:46:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S4kt2O024689
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 13:46:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC21E45DE55
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:46:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A665F45DE4E
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:46:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED70E08004
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:46:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 395F11DB803A
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:46:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100528043339.GZ3519@balbir.in.ibm.com>
References: <20100528035147.GD11364@uudg.org> <20100528043339.GZ3519@balbir.in.ibm.com>
Message-Id: <20100528134133.7E24.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 13:46:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

> * Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:
> 
> > @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> >   */
> >  static void __oom_kill_task(struct task_struct *p, int verbose)
> >  {
> > +	struct sched_param param;
> > +
> >  	if (is_global_init(p)) {
> >  		WARN_ON(1);
> >  		printk(KERN_WARNING "tried to kill init!\n");
> > @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >  	 */
> >  	p->rt.time_slice = HZ;
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > -
> >  	force_sig(SIGKILL, p);
> > +	param.sched_priority = MAX_RT_PRIO-1;
> > +	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> >  }
> >
> 
> I would like to understand the visible benefits of this patch. Have
> you seen an OOM kill tasked really get bogged down. Should this task
> really be competing with other important tasks for run time?

What you mean important? Until OOM victim task exit completely, the system have no memory.
all of important task can't do anything.

In almost kernel subsystems, automatically priority boost is really bad idea because
it may break RT task's deterministic behavior. but OOM is one of exception. The deterministic
was alread broken by memory starvation.

That's the reason I acked it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
