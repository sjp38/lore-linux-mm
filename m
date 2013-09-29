Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 63F736B0031
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 10:03:48 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so4542675pdi.33
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 07:03:46 -0700 (PDT)
Date: Sun, 29 Sep 2013 15:56:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130929135646.GA3743@redhat.com>
References: <20130924202423.GW12926@twins.programming.kicks-ass.net> <20130925155515.GA17447@redhat.com> <20130925174307.GA3220@laptop.programming.kicks-ass.net> <20130925175055.GA25914@redhat.com> <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926165840.GA863@redhat.com> <20130926175016.GI3657@laptop.programming.kicks-ass.net> <20130927181532.GA8401@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130927181532.GA8401@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/27, Oleg Nesterov wrote:
>
> I tried hard to find any hole in this version but failed, I believe it
> is correct.

And I still believe it is. But now I am starting to think that we
don't need cpuhp_seq. (and imo cpuhp_waitcount, but this is minor).

> We need to ensure 2 things:
>
> 1. The reader should notic state = BLOCK or the writer should see
>    inc(__cpuhp_refcount). This is guaranteed by 2 mb's in
>    __get_online_cpus() and in cpu_hotplug_begin().
>
>    We do not care if the writer misses some inc(__cpuhp_refcount)
>    in per_cpu_sum(__cpuhp_refcount), that reader(s) should notice
>    state = readers_block (and inc(cpuhp_seq) can't help anyway).

Yes!

> 2. If the writer sees the result of this_cpu_dec(__cpuhp_refcount)
>    from __put_online_cpus() (note that the writer can miss the
>    corresponding inc() if it was done on another CPU, so this dec()
>    can lead to sum() == 0),

But this can't happen in this version? Somehow I forgot that
__get_online_cpus() does inc/get under preempt_disable(), always on
the same CPU. And thanks to mb's the writer should not miss the
reader which has already passed the "state != BLOCK" check.

To simplify the discussion, lets ignore the "readers_fast" state,
synchronize_sched() logic looks obviously correct. IOW, lets discuss
only the SLOW -> BLOCK transition.

	cput_hotplug_begin()
	{
		state = BLOCK;

		mb();

		wait_event(cpuhp_writer,
				per_cpu_sum(__cpuhp_refcount) == 0);
	}

should work just fine? Ignoring all details, we have

	get_online_cpus()
	{
	again:
		preempt_disable();

		__this_cpu_inc(__cpuhp_refcount);

		mb();

		if (state == BLOCK) {

			mb();

			__this_cpu_dec(__cpuhp_refcount);
			wake_up_all(cpuhp_writer);

			preempt_enable();
			wait_event(state != BLOCK);
			goto again;
		}

		preempt_enable();
	}

It seems to me that these mb's guarantee all we need, no?

It looks really simple. The reader can only succed if it doesn't see
BLOCK, in this case per_cpu_sum() should see the change,

We have

	WRITER					READER on CPU X

	state = BLOCK;				__cpuhp_refcount[X]++;

	mb();					mb();

	...
	count += __cpuhp_refcount[X];		if (state != BLOCK)
	...						return;

						mb();
						__cpuhp_refcount[X]--;

Either reader or writer should notice the STORE we care about.

If a reader can decrement __cpuhp_refcount, we have 2 cases:

	1. It is the reader holding this lock. In this case we
	   can't miss the corresponding inc() done by this reader,
	   because this reader didn't see BLOCK in the past.

	   It is just the

			A == B == 0
	   	CPU_0			CPU_1
	   	-----			-----
	   	A = 1;			B = 1;
	   	mb();			mb();
	   	b = B;			a = A;

	   pattern, at least one CPU should see 1 in its a/b.

	2. It is the reader which tries to take this lock and
	   noticed state == BLOCK. We could miss the result of
	   its inc(), but we do not care, this reader is going
	   to block.

	   _If_ the reader could migrate between inc/dec, then
	   yes, we have a problem. Because that dec() could make
	   the result of per_cpu_sum() = 0. IOW, we could miss
	   inc() but notice dec(). But given that it does this
	   on the same CPU this is not possible.

So why do we need cpuhp_seq?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
