Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2B4186B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 13:53:28 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130702064538.GB3143@gmail.com>
References: <20130626095108.GB29181@gmail.com>
	 <1372282560.22432.139.camel@schen9-DESK>
	 <1372292701.22432.152.camel@schen9-DESK> <20130627083651.GA3730@gmail.com>
	 <1372366385.22432.185.camel@schen9-DESK>
	 <1372375873.22432.200.camel@schen9-DESK> <20130628093809.GB29205@gmail.com>
	 <1372453461.22432.216.camel@schen9-DESK> <20130629071245.GA5084@gmail.com>
	 <1372710497.22432.224.camel@schen9-DESK>  <20130702064538.GB3143@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Jul 2013 10:53:15 -0700
Message-ID: <1373997195.22432.297.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-07-02 at 08:45 +0200, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > On Sat, 2013-06-29 at 09:12 +0200, Ingo Molnar wrote:
> > > * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > > 
> > > > > If my analysis is correct so far then it might be useful to add two 
> > > > > more stats: did rwsem_spin_on_owner() fail because lock->owner == NULL 
> > > > > [owner released the rwsem], or because owner_running() failed [owner 
> > > > > went to sleep]?
> > > > 
> > > > Ingo,
> > > > 
> > > > I tabulated the cases where rwsem_spin_on_owner returns false and causes 
> > > > us to stop spinning.
> > > > 
> > > > 97.12%  was due to lock's owner switching to another writer
> > > >  0.01% was due to the owner of the lock sleeping
> > > >  2.87%  was due to need_resched() 
> > > > 
> > > > I made a change to allow us to continue to spin even when lock's owner 
> > > > switch to another writer.  I did get the lock to be acquired now mostly 
> > > > (98%) via optimistic spin and lock stealing, but my benchmark's 
> > > > throughput actually got reduced by 30% (too many cycles spent on useless 
> > > > spinning?).
> > > 
> > > Hm, I'm running out of quick ideas :-/ The writer-ends-spinning sequence 
> > > is pretty similar in the rwsem and in the mutex case. I'd have a look at 
> > > one more detail: is the wakeup of another writer in the rwsem case 
> > > singular, is only a single writer woken? I suspect the answer is yes ...
> > 
> > Ingo, we can only wake one writer, right? In __rwsem_do_wake, that is 
> > indeed the case.  Or you are talking about something else?
> 
> Yeah, I was talking about that, and my understanding and reading of the 
> code says that too - I just wanted to make sure :-)
> 
> > >
> > > A quick glance suggests that the ordering of wakeups of waiters is the 
> > > same for mutexes and rwsems: FIFO, single waiter woken on 
> > > slowpath-unlock. So that shouldn't make a big difference.
> > 

Ingo,

I tried MCS locking to order the writers but
it didn't make much difference on my particular workload.
After thinking about this some more,  a likely explanation of the
performance difference between mutex and rwsem performance is:

1) Jobs acquiring mutex put itself on the wait list only after
optimistic spinning.  That's only 2% of the time on my
test workload so they access the wait list rarely.

2) Jobs acquiring rw-sem for write *always* put itself on the wait 
list first before trying lock stealing and optimistic spinning.  
This creates a bottleneck at the wait list, and also more 
cache bouncing.

One possible optimization is to delay putting the writer on the
wait list till after optimistic spinning, but we may need to keep
track of the number of writers waiting.  We could add a WAIT_BIAS 
to count for each write waiter and remove the WAIT_BIAS each time a
writer job completes.  This is tricky as I'm changing the
semantics of the count field and likely will require a number of changes
to rwsem code.  Your thoughts on a better way to do this?

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
