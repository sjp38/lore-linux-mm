Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 278196B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 06:37:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ABD543EE0BD
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:37:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F52345DF5A
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:37:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A73C45DF53
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:37:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4445BE08002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:37:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3A0C1DB803A
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:37:15 +0900 (JST)
Date: Thu, 26 May 2011 19:30:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 7/10] workqueue: add WQ_IDLEPRI
Message-Id: <20110526193018.12b3ddea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526093808.GE9715@htj.dyndns.org>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526093808.GE9715@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 26 May 2011 11:38:08 +0200
Tejun Heo <tj@kernel.org> wrote:

> Hello, KAMEZAWA.
> 
> On Thu, May 26, 2011 at 02:30:24PM +0900, KAMEZAWA Hiroyuki wrote:
> > When this idea came to me, I wonder which is better to maintain
> > memcg's thread pool or add support in workqueue for generic use. In
> > genral, I feel enhancing genric one is better...so, wrote this one.
> 
> Sure, if it's something which can be useful for other users, it makes
> sense to make it generic.
> 
Thank you for review.


> > Index: memcg_async/include/linux/workqueue.h
> > ===================================================================
> > --- memcg_async.orig/include/linux/workqueue.h
> > +++ memcg_async/include/linux/workqueue.h
> > @@ -56,7 +56,8 @@ enum {
> >  
> >  	/* special cpu IDs */
> >  	WORK_CPU_UNBOUND	= NR_CPUS,
> > -	WORK_CPU_NONE		= NR_CPUS + 1,
> > +	WORK_CPU_IDLEPRI	= NR_CPUS + 1,
> > +	WORK_CPU_NONE		= NR_CPUS + 2,
> >  	WORK_CPU_LAST		= WORK_CPU_NONE,
> 
> Hmmm... so, you're defining another fake CPU a la unbound CPU.  I'm
> not sure whether it's really necessary to create its own worker pool
> tho.  The reason why SCHED_OTHER is necessary is because it may
> consume large amount of CPU cycles.  Workqueue already has UNBOUND -
> for an unbound one, workqueue code simply acts as generic worker pool
> provider and everything other than work item dispatching and worker
> management are deferred to scheduler and the workqueue user.
> 
yes.

> Is there any reason memcg can't just use UNBOUND workqueue and set
> scheduling priority when the work item starts and restore it when it's
> done? 

I thought of that. But I didn't do that because I wasn't sure how others
will think about changing exisitng workqueue priority...and I was curious
to know how workqueue works.

> If it's gonna be using UNBOUND at all, I don't think changing
> scheduling policy would be a noticeable overhead and I find having
> separate worker pools depending on scheduling priority somewhat silly.
> 
ok.

> We can add a mechanism to manage work item scheduler priority to
> workqueue if necessary tho, I think.  But that would be per-workqueue
> attribute which is applied during execution, not something per-gcwq.
> 

In the next version, I'll try some like..
==
	process_one_work(...) {
		.....
		spin_unlock_irq(&gcwq->lock);
		.....
		if (cwq->wq->flags & WQ_IDLEPRI) {
			set_scheduler(...SCHED_IDLE...)
			cond_resched();
			scheduler_switched = true;
		}
		f(work) 
		if (scheduler_switched)
			set_scheduler(...SCHED_OTHER...)
		spin_lock_irq(&gcwq->lock);
	}
==
Patch size will be much smaller. (Should I do this in memcg's code ??)

Thank you for your advices.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
