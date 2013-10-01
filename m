Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 401FC6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 11:47:04 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so7463367pdj.29
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:47:03 -0700 (PDT)
Date: Tue, 1 Oct 2013 17:40:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001154006.GA3848@redhat.com>
References: <20130925174307.GA3220@laptop.programming.kicks-ass.net> <20130925175055.GA25914@redhat.com> <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926165840.GA863@redhat.com> <20130926175016.GI3657@laptop.programming.kicks-ass.net> <20130927181532.GA8401@redhat.com> <20130929135646.GA3743@redhat.com> <20131001153829.GE5790@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001153829.GE5790@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 10/01, Paul E. McKenney wrote:
>
> On Sun, Sep 29, 2013 at 03:56:46PM +0200, Oleg Nesterov wrote:
> > On 09/27, Oleg Nesterov wrote:
> > >
> > > I tried hard to find any hole in this version but failed, I believe it
> > > is correct.
> >
> > And I still believe it is. But now I am starting to think that we
> > don't need cpuhp_seq. (and imo cpuhp_waitcount, but this is minor).
>
> Here is one scenario that I believe requires cpuhp_seq:
>
> 1.	Task 0 on CPU 0 increments its counter on entry.
>
> 2.	Task 1 on CPU 1 starts summing the counters and gets to
> 	CPU 4.  The sum thus far is 1 (Task 0).
>
> 3.	Task 2 on CPU 2 increments its counter on entry.
> 	Upon completing its entry code, it re-enables preemption.

afaics at this stage it should notice state = BLOCK and decrement
the same counter on the same CPU before it does preempt_enable().

Because:

> > 	2. It is the reader which tries to take this lock and
> > 	   noticed state == BLOCK. We could miss the result of
> > 	   its inc(), but we do not care, this reader is going
> > 	   to block.
> >
> > 	   _If_ the reader could migrate between inc/dec, then
> > 	   yes, we have a problem. Because that dec() could make
> > 	   the result of per_cpu_sum() = 0. IOW, we could miss
> > 	   inc() but notice dec(). But given that it does this
> > 	   on the same CPU this is not possible.
> >
> > So why do we need cpuhp_seq?
>
> Good question, I will look again.

Thanks! much appreciated.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
