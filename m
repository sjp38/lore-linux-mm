Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1569D6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 19:36:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52NafGQ026040
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 08:36:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6F945DE51
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 08:36:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA79245DE4D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 08:36:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C88D1DB803C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 08:36:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4889D1DB8037
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 08:36:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
References: <20100602220429.F51E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
Message-Id: <20100603083259.7231.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 08:36:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

> On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > > @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> > > >  		 * Otherwise we could get an easy OOM deadlock.
> > > >  		 */
> > > >  		if (p->flags & PF_EXITING) {
> > > > -			if (p != current)
> > > > +			if (p != current) {
> > > > +				boost_dying_task_prio(p, mem);
> > > >  				return ERR_PTR(-1UL);
> > > > -
> > > > +			}
> > > >  			chosen = p;
> > > >  			*ppoints = ULONG_MAX;
> > > >  		}
> > > 
> > > This has the potential to actually make it harder to free memory if p is 
> > > waiting to acquire a writelock on mm->mmap_sem in the exit path while the 
> > > thread holding mm->mmap_sem is trying to run.
> > 
> > if p is waiting, changing prio have no effect. It continue tol wait to release mmap_sem.
> > 
> 
> And that can reduce the runtime of the thread holding a writelock on 
> mm->mmap_sem, making the exit actually take longer than without the patch 
> if its priority is significantly higher, especially on smaller machines.

If p need mmap_sem, p is going to sleep to wait mmap_sem. if p doesn't,
quickly exit is good thing. In other word, task fairness is not our goal
when oom occur.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
