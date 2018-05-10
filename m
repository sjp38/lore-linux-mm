Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBCB16B0607
	for <linux-mm@kvack.org>; Thu, 10 May 2018 09:39:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r23-v6so1443160wrc.2
        for <linux-mm@kvack.org>; Thu, 10 May 2018 06:39:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c14-v6si1188555edj.417.2018.05.10.06.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 06:39:47 -0700 (PDT)
Date: Thu, 10 May 2018 09:41:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180510134132.GA19348@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509104618.GP12217@hirez.programming.kicks-ass.net>
 <20180509113849.GJ12235@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509113849.GJ12235@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 01:38:49PM +0200, Peter Zijlstra wrote:
> On Wed, May 09, 2018 at 12:46:18PM +0200, Peter Zijlstra wrote:
> > On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> > 
> > > @@ -2038,6 +2038,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
> > >  	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
> > >  	if (task_cpu(p) != cpu) {
> > >  		wake_flags |= WF_MIGRATED;
> > > +		psi_ttwu_dequeue(p);
> > >  		set_task_cpu(p, cpu);
> > >  	}
> > >  
> > 
> > > +static inline void psi_ttwu_dequeue(struct task_struct *p)
> > > +{
> > > +	/*
> > > +	 * Is the task being migrated during a wakeup? Make sure to
> > > +	 * deregister its sleep-persistent psi states from the old
> > > +	 * queue, and let psi_enqueue() know it has to requeue.
> > > +	 */
> > > +	if (unlikely(p->in_iowait || (p->flags & PF_MEMSTALL))) {
> > > +		struct rq_flags rf;
> > > +		struct rq *rq;
> > > +		int clear = 0;
> > > +
> > > +		if (p->in_iowait)
> > > +			clear |= TSK_IOWAIT;
> > > +		if (p->flags & PF_MEMSTALL)
> > > +			clear |= TSK_MEMSTALL;
> > > +
> > > +		rq = __task_rq_lock(p, &rf);
> > > +		update_rq_clock(rq);
> > > +		psi_task_change(p, rq_clock(rq), clear, 0);
> > > +		p->sched_psi_wake_requeue = 1;
> > > +		__task_rq_unlock(rq, &rf);
> > > +	}
> > > +}
> > 
> > Yeah, no... not happening.
> > 
> > We spend a lot of time to never touch the old rq->lock on wakeups. Mason
> > was the one pushing for that, so he should very well know this.
> > 
> > The one cross-cpu atomic (iowait) is already a problem (the whole iowait
> > accounting being useless makes it even worse), adding significant remote
> > prodding is just really bad.
> 
> Also, since all you need is the global number, I don't think you
> actually need any of this. See what we do for nr_uninterruptible.
> 
> In general I think you want to (re)read loadavg.c some more, and maybe
> reuse a bit more of that.

So there is a reason I'm tracking productivity states per-cpu and not
globally. Consider the following example periods on two CPUs:

    CPU 0
Task 1: | EXECUTING  | memstalled |
Task 2: | runqueued  | EXECUTING  |

    CPU 1
Task 3: | memstalled | EXECUTING  |

If we tracked only the global number of stalled tasks, similarly to
nr_uninterruptible, the number would be elevated throughout the whole
sampling period, giving a pressure value of 100% for "some stalled".
And, since there is always something executing, a "full stall" of 0%.

Now consider what happens when the Task 3 sequence is the other way
around:

    CPU 0
Task 1: | EXECUTING  | memstalled |
Task 2: | runqueued  | EXECUTING  |

    CPU 1
Task 3: | EXECUTING  | memstalled |

Here the number of stalled tasks is elevated only during half of the
sampling period, this time giving a pressure reading of 50% for "some"
(and again 0% for "full").

That's a different measurement, but in terms of workload progress, the
sequences are functionally equivalent. In both scenarios the same
amount of productive CPU cycles is spent advancing tasks 1, 2 and 3,
and the same amount of potentially productive CPU time is lost due to
the contention of memory. We really ought to read the same pressure.

So what I'm doing is calculating the productivity loss on each CPU in
a sampling period as if they were independent time slices. It doesn't
matter how you slice and dice the sequences within each one - if used
CPU time and lost CPU time have the same proportion, we have the same
pressure.

In both scenarios above, this method will give a pressure reading of
some=50% and full=25% of "normalized walltime", which is the time loss
the work would experience on a single CPU executing it serially.

To illustrate:

    CPU X
        1            2            3            4
Task 1: | EXECUTING  | memstalled | sleeping   | sleeping   |
Task 2: | runqueued  | EXECUTING  | sleeping   | sleeping   |
Task 3: | sleeping   | sleeping   | EXECUTING  | memstalled |

You can clearly see the 50% of walltime in which *somebody* isn't
advancing (2 and 4), and the 25% of walltime in which *no* tasks are
(3). Same amount of work, same memory stalls, same pressure numbers.

Globalized state tracking would produce those numbers on the single
CPU (obviously), but once concurrency gets into the mix, it's
questionable what its results mean. It certainly isn't able to
reliably detect equivalent slowdowns of individual tasks ("some" is
all over the place), and in this example wasn't able to capture the
impact of contention on overall work completion ("full" is 0%).

* CPU 0: some = 50%, full =  0%
  CPU 1: some = 50%, full = 50%
    avg: some = 50%, full = 25%
