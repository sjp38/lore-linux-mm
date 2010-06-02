Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A4AC26B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:12:08 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o52LC3WD005492
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:12:03 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe20.cbf.corp.google.com with ESMTP id o52LC1OS011989
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:12:01 -0700
Received: by pxi19 with SMTP id 19so2547388pxi.3
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:12:01 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:11:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100602220429.F51E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
References: <20100601173535.GD23428@uudg.org> <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com> <20100602220429.F51E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:

> > > @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> > >  		 * Otherwise we could get an easy OOM deadlock.
> > >  		 */
> > >  		if (p->flags & PF_EXITING) {
> > > -			if (p != current)
> > > +			if (p != current) {
> > > +				boost_dying_task_prio(p, mem);
> > >  				return ERR_PTR(-1UL);
> > > -
> > > +			}
> > >  			chosen = p;
> > >  			*ppoints = ULONG_MAX;
> > >  		}
> > 
> > This has the potential to actually make it harder to free memory if p is 
> > waiting to acquire a writelock on mm->mmap_sem in the exit path while the 
> > thread holding mm->mmap_sem is trying to run.
> 
> if p is waiting, changing prio have no effect. It continue tol wait to release mmap_sem.
> 

And that can reduce the runtime of the thread holding a writelock on 
mm->mmap_sem, making the exit actually take longer than without the patch 
if its priority is significantly higher, especially on smaller machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
