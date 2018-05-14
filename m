Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B35286B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:34:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 35-v6so10659367pla.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:34:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t17-v6si8554355plo.266.2018.05.14.01.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 May 2018 01:34:12 -0700 (PDT)
Date: Mon, 14 May 2018 10:33:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180514083353.GN12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509104618.GP12217@hirez.programming.kicks-ass.net>
 <20180509113849.GJ12235@hirez.programming.kicks-ass.net>
 <20180510134132.GA19348@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510134132.GA19348@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Thu, May 10, 2018 at 09:41:32AM -0400, Johannes Weiner wrote:
> So there is a reason I'm tracking productivity states per-cpu and not
> globally. Consider the following example periods on two CPUs:
> 
>     CPU 0
> Task 1: | EXECUTING  | memstalled |
> Task 2: | runqueued  | EXECUTING  |
> 
>     CPU 1
> Task 3: | memstalled | EXECUTING  |
> 
> If we tracked only the global number of stalled tasks, similarly to
> nr_uninterruptible, the number would be elevated throughout the whole
> sampling period, giving a pressure value of 100% for "some stalled".
> And, since there is always something executing, a "full stall" of 0%.

But if you read the comment about SMP IO-wait; see commit:

  e33a9bba85a8 ("sched/core: move IO scheduling accounting from io_schedule_timeout() into scheduler")

you'll see that per-cpu accounting has issues too.

Also, note that in your example above you have 1 memstalled task (at any
one time), but _2_ CPUs. So at most you should end up with a 50% value.
There is no way 1 task could consume 2 CPUs worth of time.

Furthermore, associating a blocked task to any particular CPU is
fundamentally broken and I'll hard NAK anything that relies on it.

> Now consider what happens when the Task 3 sequence is the other way
> around:
> 
>     CPU 0
> Task 1: | EXECUTING  | memstalled |
> Task 2: | runqueued  | EXECUTING  |
> 
>     CPU 1
> Task 3: | EXECUTING  | memstalled |
> 
> Here the number of stalled tasks is elevated only during half of the
> sampling period, this time giving a pressure reading of 50% for "some"
> (and again 0% for "full").

That entirely depends on your averaging; an exponentially decaying
average would not typically result in 50% for the above case. But I
think we can agree that this results in one 0% and one 100% sample -- we
have two stalled tasks and two CPUs.

> That's a different measurement, but in terms of workload progress, the
> sequences are functionally equivalent. In both scenarios the same
> amount of productive CPU cycles is spent advancing tasks 1, 2 and 3,
> and the same amount of potentially productive CPU time is lost due to
> the contention of memory. We really ought to read the same pressure.

And you do -- subject to the averaging used, as per the above.

The first gives two 50% samples, the second gives 0%, 100%.

> So what I'm doing is calculating the productivity loss on each CPU in
> a sampling period as if they were independent time slices. It doesn't
> matter how you slice and dice the sequences within each one - if used
> CPU time and lost CPU time have the same proportion, we have the same
> pressure.

I'm still thinking you can do basically the same without the stong CPU
relation.

> To illustrate:
> 
>     CPU X
>         1            2            3            4
> Task 1: | EXECUTING  | memstalled | sleeping   | sleeping   |
> Task 2: | runqueued  | EXECUTING  | sleeping   | sleeping   |
> Task 3: | sleeping   | sleeping   | EXECUTING  | memstalled |
> 
> You can clearly see the 50% of walltime in which *somebody* isn't
> advancing (2 and 4), and the 25% of walltime in which *no* tasks are
> (3). Same amount of work, same memory stalls, same pressure numbers.
> 
> Globalized state tracking would produce those numbers on the single
> CPU (obviously), but once concurrency gets into the mix, it's
> questionable what its results mean. It certainly isn't able to
> reliably detect equivalent slowdowns of individual tasks ("some" is
> all over the place), and in this example wasn't able to capture the
> impact of contention on overall work completion ("full" is 0%).
> 
> * CPU 0: some = 50%, full =  0%
>   CPU 1: some = 50%, full = 50%
>     avg: some = 50%, full = 25%

I'm not entirely sure I get your point here; but note that a task
doesn't sleep on a CPU. When it sleeps it is not strictly associated
with a CPU, only when it runs does it have an association.

What is the value of accounting a sleep state to a particular CPU if the
task when wakes up on another? Where did the sleep take place?

All we really can say is that a task slept, and if we can reduce the
reason for its sleeping (IO, reclaim, whatever) then it could've ran
sooner. And then you can make predictions based on the number of CPUs
and global idle time, how much that could improve things.
