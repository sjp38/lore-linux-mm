Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 17A406B0033
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 02:45:43 -0400 (EDT)
Received: by mail-ea0-f170.google.com with SMTP id h10so2487975eaj.15
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 23:45:41 -0700 (PDT)
Date: Tue, 2 Jul 2013 08:45:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130702064538.GB3143@gmail.com>
References: <20130626095108.GB29181@gmail.com>
 <1372282560.22432.139.camel@schen9-DESK>
 <1372292701.22432.152.camel@schen9-DESK>
 <20130627083651.GA3730@gmail.com>
 <1372366385.22432.185.camel@schen9-DESK>
 <1372375873.22432.200.camel@schen9-DESK>
 <20130628093809.GB29205@gmail.com>
 <1372453461.22432.216.camel@schen9-DESK>
 <20130629071245.GA5084@gmail.com>
 <1372710497.22432.224.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372710497.22432.224.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Sat, 2013-06-29 at 09:12 +0200, Ingo Molnar wrote:
> > * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > 
> > > > If my analysis is correct so far then it might be useful to add two 
> > > > more stats: did rwsem_spin_on_owner() fail because lock->owner == NULL 
> > > > [owner released the rwsem], or because owner_running() failed [owner 
> > > > went to sleep]?
> > > 
> > > Ingo,
> > > 
> > > I tabulated the cases where rwsem_spin_on_owner returns false and causes 
> > > us to stop spinning.
> > > 
> > > 97.12%  was due to lock's owner switching to another writer
> > >  0.01% was due to the owner of the lock sleeping
> > >  2.87%  was due to need_resched() 
> > > 
> > > I made a change to allow us to continue to spin even when lock's owner 
> > > switch to another writer.  I did get the lock to be acquired now mostly 
> > > (98%) via optimistic spin and lock stealing, but my benchmark's 
> > > throughput actually got reduced by 30% (too many cycles spent on useless 
> > > spinning?).
> > 
> > Hm, I'm running out of quick ideas :-/ The writer-ends-spinning sequence 
> > is pretty similar in the rwsem and in the mutex case. I'd have a look at 
> > one more detail: is the wakeup of another writer in the rwsem case 
> > singular, is only a single writer woken? I suspect the answer is yes ...
> 
> Ingo, we can only wake one writer, right? In __rwsem_do_wake, that is 
> indeed the case.  Or you are talking about something else?

Yeah, I was talking about that, and my understanding and reading of the 
code says that too - I just wanted to make sure :-)

> >
> > A quick glance suggests that the ordering of wakeups of waiters is the 
> > same for mutexes and rwsems: FIFO, single waiter woken on 
> > slowpath-unlock. So that shouldn't make a big difference.
> 
> > If all last-ditch efforts to analyze it via counters fail then the way 
> > I'd approach it next is brute-force instrumentation:
> > 
> >  - First I'd create a workload 'steady state' that can be traced and 
> >    examined without worrying that that it ends or switches to some other 
> >    workload.
> > 
> >  - Then I'd create a relatively lightweight trace (maybe trace_printk() is
> >    lightweight enough), and capture key mutex and rwsem events.
> > 
> >  - I'd capture a 1-10 seconds trace in steady state, both with rwsems and 
> >    mutexes. I'd have a good look at which tasks take locks and schedule
> >    how and why. I'd try to eliminate any assymetries in behavior, i.e. 
> >    make rwsems behave like mutexes.
> 
> You mean adding trace points to record the events?  If you can be more 
> specific on what data to capture, that will be helpful.  It will be 
> holidays here in US so I may get around to this the following week.

Yeah, adding the relevant tracepoints (or trace_printk(), which is much 
simpler albeit a bit more expensive) - and capturing a 1-second 
steady-state traces via ftrace.

Then I'd compare the two traces and look at the biggest difference, and 
try to zoom in on to figure out why the difference occurs. More 
trace_printk()s can be added as you suspect specific areas or want to 
confirm various theories.

[ Assuming the phenomenon does not go away under tracing :-/ ]

[
  Another brute-force approach is to add a dynamic debug knob to switch 
  between a spinlock and an rwsem implementation for that lock: I'd do it 
  by adding both types of locks to the data structure, initializing both 
  but using a /proc/sys/kernel/ knob to decide whether to use spin_*() or
  rwsem facilities to utilize it. This way you could switch between the 
  two implementations without rebooting the system. In theory.
]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
