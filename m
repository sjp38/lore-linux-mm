Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 84D096B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 18:31:50 -0400 (EDT)
Message-ID: <1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Fri, 14 Jun 2013 15:31:44 -0700
In-Reply-To: <1371226197.27102.594.camel@schen9-DESK>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <1371226197.27102.594.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-06-14 at 09:09 -0700, Tim Chen wrote:
> Added copy to mailing list which I forgot in my previous reply:
> 
> On Thu, 2013-06-13 at 16:43 -0700, Davidlohr Bueso wrote:
> > On Thu, 2013-06-13 at 16:15 -0700, Tim Chen wrote:
> > > Ingo,
> > > 
> > > At the time of switching the anon-vma tree's lock from mutex to 
> > > rw-sem (commit 5a505085), we encountered regressions for fork heavy workload. 
> > > A lot of optimizations to rw-sem (e.g. lock stealing) helped to 
> > > mitigate the problem.  I tried an experiment on the 3.10-rc4 kernel 
> > > to compare the performance of rw-sem to one that uses mutex. I saw 
> > > a 8% regression in throughput for rw-sem vs a mutex implementation in
> > > 3.10-rc4.
> > 
> > Funny, just yesterday I was discussing this issue with Michel. While I
> > didn't measure the anon-vma mutex->rwem conversion, I did convert the
> > i_mmap_mutex to a rwsem and noticed a performance regression on a few
> > aim7 workloads on a 8 socket, 80 core box, when keeping all writers,
> > which should perform very similarly to a mutex. While some of these
> > workloads recovered when I shared the lock among readers (similar to
> > anon-vma), it left me wondering.
> > 
> > > For the experiments, I used the exim mail server workload in 
> > > the MOSBENCH test suite on 4 socket (westmere) and a 4 socket 
> > > (ivy bridge) with the number of clients sending mail equal 
> > > to number of cores.  The mail server will
> > > fork off a process to handle an incoming mail and put it into mail
> > > spool. The lock protecting the anon-vma tree is stressed due to
> > > heavy forking. On both machines, I saw that the mutex implementation 
> > > has 8% more throughput.  I've pinned the cpu frequency to maximum
> > > in the experiments.
> > 
> > I got some similar -8% throughput on high_systime and shared.
> > 
> 
> That's interesting. Another perspective on rwsem vs mutex.
> 
> > > 
> > > I've tried two separate tweaks to the rw-sem on 3.10-rc4.  I've tested 
> > > each tweak individually.
> > > 
> > > 1) Add an owner field when a writer holds the lock and introduce 
> > > optimistic spinning when an active writer is holding the semaphore.  
> > > It reduced the context switching by 30% to a level very close to the
> > > mutex implementation.  However, I did not see any throughput improvement
> > > of exim.
> > 
> > I was hoping that the lack of spin on owner was the main difference with
> > rwsems and am/was in the middle of implementing it. Could you send your
> > patch so I can give it a try on my workloads?
> > 
> > Note that there have been a few recent (3.10) changes to mutexes that
> > give a nice performance boost, specially on large systems, most
> > noticeably:
> > 
> > commit 2bd2c92c (mutex: Make more scalable by doing less atomic
> > operations)
> > 
> > commit 0dc8c730 (mutex: Queue mutex spinners with MCS lock to reduce
> > cacheline contention)
> > 
> > It might be worth looking into doing something similar to commit
> > 0dc8c730, in addition to the optimistic spinning.
> 
> Okay.  Here's my ugly experimental hack with some code lifted from optimistic spin 
> within mutex.  I've thought about doing the MCS lock thing but decided 
> to keep the first try on the optimistic spinning simple.

Unfortunately this patch didn't make any difference, in fact it hurt
several of the workloads even more. I also tried disabling preemption
when spinning on owner to actually resemble spinlocks, which was my
original plan, yet not much difference. 

A few ideas that come to mind are avoiding taking the ->wait_lock and
avoid dealing with waiters when doing the optimistic spinning (just like
mutexes do).

I agree that we should first deal with the optimistic spinning before
adding the MCS complexity.

> Matthew and I have also discussed possibly introducing some 
> limited spinning for writer when semaphore is held by read.  
> His idea was to have readers as well as writers set ->owner.  
> Writers, as now, unconditionally clear owner.  Readers clear 
> owner if sem->owner == current.  Writers spin on ->owner if ->owner 
> is non-NULL and still active. That gives us a reasonable chance 
> to spin since we'll be spinning on
> the most recent acquirer of the lock.

I also tried implementing this concept on top of your patch, didn't make
much of a difference with or without it. 

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
