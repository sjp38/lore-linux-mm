Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id AF0BE6B0032
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 03:12:50 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id c10so1492119wiw.1
        for <linux-mm@kvack.org>; Sat, 29 Jun 2013 00:12:49 -0700 (PDT)
Date: Sat, 29 Jun 2013 09:12:45 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130629071245.GA5084@gmail.com>
References: <1371660831.27102.663.camel@schen9-DESK>
 <1372205996.22432.119.camel@schen9-DESK>
 <20130626095108.GB29181@gmail.com>
 <1372282560.22432.139.camel@schen9-DESK>
 <1372292701.22432.152.camel@schen9-DESK>
 <20130627083651.GA3730@gmail.com>
 <1372366385.22432.185.camel@schen9-DESK>
 <1372375873.22432.200.camel@schen9-DESK>
 <20130628093809.GB29205@gmail.com>
 <1372453461.22432.216.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372453461.22432.216.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> > If my analysis is correct so far then it might be useful to add two 
> > more stats: did rwsem_spin_on_owner() fail because lock->owner == NULL 
> > [owner released the rwsem], or because owner_running() failed [owner 
> > went to sleep]?
> 
> Ingo,
> 
> I tabulated the cases where rwsem_spin_on_owner returns false and causes 
> us to stop spinning.
> 
> 97.12%  was due to lock's owner switching to another writer
>  0.01% was due to the owner of the lock sleeping
>  2.87%  was due to need_resched() 
> 
> I made a change to allow us to continue to spin even when lock's owner 
> switch to another writer.  I did get the lock to be acquired now mostly 
> (98%) via optimistic spin and lock stealing, but my benchmark's 
> throughput actually got reduced by 30% (too many cycles spent on useless 
> spinning?).

Hm, I'm running out of quick ideas :-/ The writer-ends-spinning sequence 
is pretty similar in the rwsem and in the mutex case. I'd have a look at 
one more detail: is the wakeup of another writer in the rwsem case 
singular, is only a single writer woken? I suspect the answer is yes ...

A quick glance suggests that the ordering of wakeups of waiters is the 
same for mutexes and rwsems: FIFO, single waiter woken on slowpath-unlock. 
So that shouldn't make a big difference.

If all last-ditch efforts to analyze it via counters fail then the way I'd 
approach it next is brute-force instrumentation:

 - First I'd create a workload 'steady state' that can be traced and 
   examined without worrying that that it ends or switches to some other 
   workload.

 - Then I'd create a relatively lightweight trace (maybe trace_printk() is
   lightweight enough), and capture key mutex and rwsem events.

 - I'd capture a 1-10 seconds trace in steady state, both with rwsems and 
   mutexes. I'd have a good look at which tasks take locks and schedule
   how and why. I'd try to eliminate any assymetries in behavior, i.e. 
   make rwsems behave like mutexes.

The risk and difficulty is that tracing can easily skew locking patterns, 
so I'd first check whether with such new tracepoints enabled the assymetry 
in behavior and regression is still present.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
