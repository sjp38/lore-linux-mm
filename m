Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8035F6B003D
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 11:39:02 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so7635157pab.41
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:39:02 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 1 Oct 2013 09:38:40 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9FADA19D8036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 09:38:32 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91FcUFI177582
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 09:38:33 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91FfZMW028355
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 09:41:36 -0600
Date: Tue, 1 Oct 2013 08:38:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001153829.GE5790@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130925155515.GA17447@redhat.com>
 <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130929135646.GA3743@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130929135646.GA3743@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Sun, Sep 29, 2013 at 03:56:46PM +0200, Oleg Nesterov wrote:
> On 09/27, Oleg Nesterov wrote:
> >
> > I tried hard to find any hole in this version but failed, I believe it
> > is correct.
> 
> And I still believe it is. But now I am starting to think that we
> don't need cpuhp_seq. (and imo cpuhp_waitcount, but this is minor).

Here is one scenario that I believe requires cpuhp_seq:

1.	Task 0 on CPU 0 increments its counter on entry.

2.	Task 1 on CPU 1 starts summing the counters and gets to
	CPU 4.  The sum thus far is 1 (Task 0).

3.	Task 2 on CPU 2 increments its counter on entry.
	Upon completing its entry code, it re-enables preemption.

4.	Task 2 is preempted, and starts running on CPU 5.

5.	Task 2 decrements its counter on exit.

6.	Task 1 continues summing.  Due to the fact that it saw Task 2's
	exit but not its entry, the sum is zero.

One of cpuhp_seq's jobs is to prevent this scenario.

That said, bozo here still hasn't gotten to look at Peter's newest patch,
so perhaps it prevents this scenario some other way, perhaps by your
argument below.

> > We need to ensure 2 things:
> >
> > 1. The reader should notic state = BLOCK or the writer should see
> >    inc(__cpuhp_refcount). This is guaranteed by 2 mb's in
> >    __get_online_cpus() and in cpu_hotplug_begin().
> >
> >    We do not care if the writer misses some inc(__cpuhp_refcount)
> >    in per_cpu_sum(__cpuhp_refcount), that reader(s) should notice
> >    state = readers_block (and inc(cpuhp_seq) can't help anyway).
> 
> Yes!

OK, I will look over the patch with this in mind.

> > 2. If the writer sees the result of this_cpu_dec(__cpuhp_refcount)
> >    from __put_online_cpus() (note that the writer can miss the
> >    corresponding inc() if it was done on another CPU, so this dec()
> >    can lead to sum() == 0),
> 
> But this can't happen in this version? Somehow I forgot that
> __get_online_cpus() does inc/get under preempt_disable(), always on
> the same CPU. And thanks to mb's the writer should not miss the
> reader which has already passed the "state != BLOCK" check.
> 
> To simplify the discussion, lets ignore the "readers_fast" state,
> synchronize_sched() logic looks obviously correct. IOW, lets discuss
> only the SLOW -> BLOCK transition.
> 
> 	cput_hotplug_begin()
> 	{
> 		state = BLOCK;
> 
> 		mb();
> 
> 		wait_event(cpuhp_writer,
> 				per_cpu_sum(__cpuhp_refcount) == 0);
> 	}
> 
> should work just fine? Ignoring all details, we have
> 
> 	get_online_cpus()
> 	{
> 	again:
> 		preempt_disable();
> 
> 		__this_cpu_inc(__cpuhp_refcount);
> 
> 		mb();
> 
> 		if (state == BLOCK) {
> 
> 			mb();
> 
> 			__this_cpu_dec(__cpuhp_refcount);
> 			wake_up_all(cpuhp_writer);
> 
> 			preempt_enable();
> 			wait_event(state != BLOCK);
> 			goto again;
> 		}
> 
> 		preempt_enable();
> 	}
> 
> It seems to me that these mb's guarantee all we need, no?
> 
> It looks really simple. The reader can only succed if it doesn't see
> BLOCK, in this case per_cpu_sum() should see the change,
> 
> We have
> 
> 	WRITER					READER on CPU X
> 
> 	state = BLOCK;				__cpuhp_refcount[X]++;
> 
> 	mb();					mb();
> 
> 	...
> 	count += __cpuhp_refcount[X];		if (state != BLOCK)
> 	...						return;
> 
> 						mb();
> 						__cpuhp_refcount[X]--;
> 
> Either reader or writer should notice the STORE we care about.
> 
> If a reader can decrement __cpuhp_refcount, we have 2 cases:
> 
> 	1. It is the reader holding this lock. In this case we
> 	   can't miss the corresponding inc() done by this reader,
> 	   because this reader didn't see BLOCK in the past.
> 
> 	   It is just the
> 
> 			A == B == 0
> 	   	CPU_0			CPU_1
> 	   	-----			-----
> 	   	A = 1;			B = 1;
> 	   	mb();			mb();
> 	   	b = B;			a = A;
> 
> 	   pattern, at least one CPU should see 1 in its a/b.
> 
> 	2. It is the reader which tries to take this lock and
> 	   noticed state == BLOCK. We could miss the result of
> 	   its inc(), but we do not care, this reader is going
> 	   to block.
> 
> 	   _If_ the reader could migrate between inc/dec, then
> 	   yes, we have a problem. Because that dec() could make
> 	   the result of per_cpu_sum() = 0. IOW, we could miss
> 	   inc() but notice dec(). But given that it does this
> 	   on the same CPU this is not possible.
> 
> So why do we need cpuhp_seq?

Good question, I will look again.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
