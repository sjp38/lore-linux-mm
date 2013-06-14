Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3FE306B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 18:44:26 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <1371226197.27102.594.camel@schen9-DESK>
	 <1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 Jun 2013 15:44:28 -0700
Message-ID: <1371249868.27102.607.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


> 
> Unfortunately this patch didn't make any difference, in fact it hurt
> several of the workloads even more. I also tried disabling preemption
> when spinning on owner to actually resemble spinlocks, which was my
> original plan, yet not much difference. 
> 

That's also similar to the performance I got.  There are things about
optimistic spinning that I missed that results in the better mutex
performance.  So I'm scratching my head.

> A few ideas that come to mind are avoiding taking the ->wait_lock and
> avoid dealing with waiters when doing the optimistic spinning (just like
> mutexes do).
> 

For my patch, we actually spin without the wait_lock.

> I agree that we should first deal with the optimistic spinning before
> adding the MCS complexity.
> 
> > Matthew and I have also discussed possibly introducing some 
> > limited spinning for writer when semaphore is held by read.  
> > His idea was to have readers as well as writers set ->owner.  
> > Writers, as now, unconditionally clear owner.  Readers clear 
> > owner if sem->owner == current.  Writers spin on ->owner if ->owner 
> > is non-NULL and still active. That gives us a reasonable chance 
> > to spin since we'll be spinning on
> > the most recent acquirer of the lock.
> 
> I also tried implementing this concept on top of your patch, didn't make
> much of a difference with or without it. 
> 

It also didn't make a difference for me.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
