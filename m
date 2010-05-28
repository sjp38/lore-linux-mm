Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8EBCF6B01BB
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:39:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S5dMsx014670
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 14:39:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9706545DE51
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:39:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AC3445DE54
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:39:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F83F1DB8041
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:39:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D671F1DB8054
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:39:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <AANLkTilimqXmhOSEvL7DKW9rmsczkv-u2p4vwAX3aPdd@mail.gmail.com>
References: <20100528134133.7E24.A69D9226@jp.fujitsu.com> <AANLkTilimqXmhOSEvL7DKW9rmsczkv-u2p4vwAX3aPdd@mail.gmail.com>
Message-Id: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 28 May 2010 14:39:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi

> Hi, Kosaki.
> 
> On Fri, May 28, 2010 at 1:46 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> * Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:
> >>
> >> > @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> >> > A  */
> >> > A static void __oom_kill_task(struct task_struct *p, int verbose)
> >> > A {
> >> > + A  struct sched_param param;
> >> > +
> >> > A  A  if (is_global_init(p)) {
> >> > A  A  A  A  A  A  WARN_ON(1);
> >> > A  A  A  A  A  A  printk(KERN_WARNING "tried to kill init!\n");
> >> > @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >> > A  A  A */
> >> > A  A  p->rt.time_slice = HZ;
> >> > A  A  set_tsk_thread_flag(p, TIF_MEMDIE);
> >> > -
> >> > A  A  force_sig(SIGKILL, p);
> >> > + A  param.sched_priority = MAX_RT_PRIO-1;
> >> > + A  sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> >> > A }
> >> >
> >>
> >> I would like to understand the visible benefits of this patch. Have
> >> you seen an OOM kill tasked really get bogged down. Should this task
> >> really be competing with other important tasks for run time?
> >
> > What you mean important? Until OOM victim task exit completely, the system have no memory.
> > all of important task can't do anything.
> >
> > In almost kernel subsystems, automatically priority boost is really bad idea because
> > it may break RT task's deterministic behavior. but OOM is one of exception. The deterministic
> > was alread broken by memory starvation.
> 
> Yes or No.
> 
> IMHO, normally RT tasks shouldn't use dynamic allocation(ie,
> non-deterministic functions or system calls) in place which is needed
> deterministic. So memory starvation might not break real-time
> deterministic.

I think It's impossible. Normally RT task use mlock and it prevent almost page
allocation. but every syscall internally call kmalloc(). They can't avoid
it practically.

How do you perfectly avoid dynamic allocation?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
