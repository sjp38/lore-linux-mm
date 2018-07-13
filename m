Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49FC76B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:15:18 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x26-v6so23812168qtb.2
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:15:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor7919203qkb.78.2018.07.13.09.15.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 09:15:12 -0700 (PDT)
Date: Fri, 13 Jul 2018 12:17:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180713161756.GA21168@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180713092153.GU2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180713092153.GU2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Peter,

On Fri, Jul 13, 2018 at 11:21:53AM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > +static inline void psi_ttwu_dequeue(struct task_struct *p)
> > +{
> > +	if (psi_disabled)
> > +		return;
> > +	/*
> > +	 * Is the task being migrated during a wakeup? Make sure to
> > +	 * deregister its sleep-persistent psi states from the old
> > +	 * queue, and let psi_enqueue() know it has to requeue.
> > +	 */
> > +	if (unlikely(p->in_iowait || (p->flags & PF_MEMSTALL))) {
> > +		struct rq_flags rf;
> > +		struct rq *rq;
> > +		int clear = 0;
> > +
> > +		if (p->in_iowait)
> > +			clear |= TSK_IOWAIT;
> > +		if (p->flags & PF_MEMSTALL)
> > +			clear |= TSK_MEMSTALL;
> > +
> > +		rq = __task_rq_lock(p, &rf);
> > +		update_rq_clock(rq);
> > +		psi_task_change(p, rq_clock(rq), clear, 0);
> > +		p->sched_psi_wake_requeue = 1;
> > +		__task_rq_unlock(rq, &rf);
> > +	}
> > +}
> 
> Still NAK, what happened to this here:
> 
>   https://lkml.kernel.org/r/20180514083353.GN12217@hirez.programming.kicks-ass.net

I did react to this in the v2 docs / code comments, but I should have
been more direct about addressing your points - sorry about that.

In that thread we disagree about exactly how to aggregate task stalls
to produce meaningful numbers, but your main issue is with the way we
track state per-CPU instead of globally, given the rq lock cost on
wake-migration and the meaning of task->cpu of a sleeping task.

First off, what I want to do can indeed be done without a strong link
of a sleeping task to a CPU. We don't rely on it, and it's something I
only figured out in v2. The important thing is not, as I previously
thought, that CPUs are tracked independently from each other, but that
we use potential execution threads as the baseline for potential that
could be wasted by resource delays. Tracking CPUs independently just
happens to do that implicitly, but it's not a requirement.

In v2 of psi.c I'm outlining a model that formulates the SOME and FULL
states from global state in a way that still produces meaningful
numbers on SMP machines by comparing the task state to the number of
possible concurrent execution threads. Here is the excerpt:

	threads = min(nr_nonidle_tasks, nr_cpus)
	   SOME = min(nr_delayed_tasks / threads, 1)
	   FULL = (threads - min(nr_running_tasks, threads)) / threads

It's followed in psi.c by examples of how/why it works, but whether
you agree with the exact formula or not, what you can see is that it
could be implemented exactly like the load average: use per-cpu
counters to construct global values for those task counts, fold and
sample that state periodically and feed it into the running averages.

So whytf is it still done with cpu-local task states?

The general problem with sampling here is that it's way too coarse to
capture the events we want to know about. The load average is okay-ish
for long term trends, but interactive things care about stalls in the
millisecond range each, and we cannot get those accurately with
second-long sampling intervals (and we cannot fold the CPU state much
more frequently than this before it gets prohibitively expensive).

Since our stall states are composed of multiple tasks, recording the
precise time spent in them requires some sort of serialization with
scheduling activity, and doing that globally would be a non-starter on
SMP. Hence still the CPU-local state tracking to approximate the
global state.

Now to your concern about relying on the task<->CPU association.

We don't *really* rely on a strict association, it's more of a hint or
historic correlation. It's fine if tasks move around on us, we just
want to approximate when CPUs go idle due to stalls or lack of work.
Let's take your quote from the thread:

: Note that a task doesn't sleep on a CPU. When it sleeps it is not
: strictly associated with a CPU, only when it runs does it have an
: association.
:
: What is the value of accounting a sleep state to a particular CPU
: if the task when wakes up on another? Where did the sleep take place?

Let's say you have a CPU running a task that then stalls on
memory. When it wakes back up it gets moved to another CPU.

We don't care so much about what happens after the task wakes up, we
just need to know where the task was running when it stalled. Even if
the task gets migrated on wakeup - *while* the stall is occuring, we
can say whether that task's old CPU goes idle due to that stall, and
has to report FULL; or something else can run on it, in which case it
only reports SOME. And even if the task bounced around CPUs while it
was running, and it was only briefly on the CPU on which it stalled -
what we care about is a CPU being idle because of stalls instead of a
genuine lack of work.

This is certainly susceptible to delayed tasks bunching up unevenly on
CPUs, like the comment in the referenced e33a9bba85a8 ("sched/core:
move IO scheduling accounting from io_schedule_timeout() into
scheduler") points out. I.e. a second task starts running on that CPU
with the delayed task, then gets delayed as itself; now you have two
delayed tasks on a single CPU and possibly none on some other CPU.

Does that mean we underreport pressure, or report "a lower bound of
pressure" in the words of e33a9bba85a8?

Not entirely. We average CPUs based on nonidle weight. If you have two
CPUs and one has two stalled tasks while the other CPU is idle, the
average still works out to 100% FULL since the idle CPU doesn't weigh
anything in the aggregation.

It's not perfect since the nonidle tracking is shared between all
three resources and, say, an iowait task tracked on the other CPU
would render that CPU "productive" from a *memory* stand point. We
*could* change that by splitting out nonidle tracking per resource,
but I'm honestly not convinced that this is an issue in practice - it
certainly hasn't been for us. Even if we said this *is* a legitimate
issue, reporting the lower bound of all stall events is a smaller
error than missing events entirely like periodic sampling would.

That's my thought process, anyway. I'd be more than happy to make this
more lightweight, but I don't see a way to do it without losing
significant functional precision.
