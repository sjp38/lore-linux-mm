Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 868876B0070
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 05:57:05 -0400 (EDT)
Date: Thu, 1 Nov 2012 09:56:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/31] sched, numa, mm: Describe the NUMA scheduling
 problem formally
Message-ID: <20121101095658.GM3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124832.621452204@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124832.621452204@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:19PM +0200, Peter Zijlstra wrote:
> This is probably a first: formal description of a complex high-level
> computing problem, within the kernel source.
> 

Who does not love the smell of formal methods first thing in the
morning?

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Mike Galbraith <efault@gmx.de>
> Rik van Riel <riel@redhat.com>
> [ Next step: generate the kernel source from such formal descriptions and retire to a tropical island! ]

You can use the computing award monies as a pension.

> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  Documentation/scheduler/numa-problem.txt |  230 +++++++++++++++++++++++++++++++
>  1 file changed, 230 insertions(+)
>  create mode 100644 Documentation/scheduler/numa-problem.txt
> 
> Index: tip/Documentation/scheduler/numa-problem.txt
> ===================================================================
> --- /dev/null
> +++ tip/Documentation/scheduler/numa-problem.txt
> @@ -0,0 +1,230 @@
> +
> +
> +Effective NUMA scheduling problem statement, described formally:
> +
> + * minimize interconnect traffic
> +
> +For each task 't_i' we have memory, this memory can be spread over multiple
> +physical nodes, let us denote this as: 'p_i,k', the memory task 't_i' has on
> +node 'k' in [pages].  
> +
> +If a task shares memory with another task let us denote this as:
> +'s_i,k', the memory shared between tasks including 't_i' residing on node
> +'k'.
> +

This does not take into account false sharing. T_0 and T_1 could map a
region MAP_SHARED that is not page-aligned. It is approximately, but not
quite, a shared page and how it is detected matters. For the purposes of
the optimisation, it sounds like it should not matter but as the NUMA01
test case is a worst-case scenario for false-sharing and sched-numa suffers
badly badly there, it might be important.

> +Let 'M' be the distribution that governs all 'p' and 's', ie. the page placement.
> +
> +Similarly, lets define 'fp_i,k' and 'fs_i,k' resp. as the (average) usage
> +frequency over those memory regions [1/s] such that the product gives an
> +(average) bandwidth 'bp' and 'bs' in [pages/s].
> +

We cannot directly measure this without using profiles all of the time.
I assume we will approximate this with sampling but it does mean we depend
very heavily on that sampling being representative to make the correct
decisions.

> +(note: multiple tasks sharing memory naturally avoid duplicat accounting
> +       because each task will have its own access frequency 'fs')
> +
> +(pjt: I think this frequency is more numerically consistent if you explicitly 
> +      restrict p/s above to be the working-set. (It also makes explicit the 
> +      requirement for <C0,M0> to change about a change in the working set.)
> +

Do you mean p+s? i.e. explicitly restrict p and s to be all task-local
and task-shared pages currently used by the system? If so, I agree that it
would be numerically more consistent. If p_i is all mapped pages instead
of the working set then depending on exactly how it is calculated, the
"average usage" can appear to drop if the process maps more regions. This
would be unhelpful because it sets of perverse incentives for tasks to
game the algorithm.

> +      Doing this does have the nice property that it lets you use your frequency
> +      measurement as a weak-ordering for the benefit a task would receive when
> +      we can't fit everything.
> +
> +      e.g. task1 has working set 10mb, f=90%
> +           task2 has working set 90mb, f=10%
> +
> +      Both are using 9mb/s of bandwidth, but we'd expect a much larger benefit
> +      from task1 being on the right node than task2. )
> +
> +Let 'C' map every task 't_i' to a cpu 'c_i' and its corresponding node 'n_i':
> +
> +  C: t_i -> {c_i, n_i}
> +
> +This gives us the total interconnect traffic between nodes 'k' and 'l',
> +'T_k,l', as:
> +
> +  T_k,l = \Sum_i bp_i,l + bs_i,l + \Sum bp_j,k + bs_j,k where n_i == k, n_j == l
> +

Task in this case must really mean a kernel task. It does not and should not
distinguish between processes and threads because for the purposes of p_i and
s_i, it doesn't matter. If this is right, there is no harm in clarifying it.

> +And our goal is to obtain C0 and M0 such that:
> +
> +  T_k,l(C0, M0) =< T_k,l(C, M) for all C, M where k != l
> +

You could add "Informally, the goal is to minimise interconnect
traffic".

> +(note: we could introduce 'nc(k,l)' as the cost function of accessing memory
> +       on node 'l' from node 'k', this would be useful for bigger NUMA systems
> +
> + pjt: I agree nice to have, but intuition suggests diminishing returns on more
> +      usual systems given factors like things like Haswell's enormous 35mb l3
> +      cache and QPI being able to do a direct fetch.)
> +

Besides, even if the NUMA distance is fixed that does not mean the cost
of a NUMA miss from the perspective of a process is fixed because it
could prefetched on one hand or cached locally in L1 or L2 cache on the
other. It's just not worth taking the weight into account.

> +(note: do we need a limit on the total memory per node?)
> +

It only needs to be taken into account if the task is using more memory
than fits into a node. You may be able to indirectly measure this in
practive using the numa_foreign counter.

If schednuma is enabled and numa_foreign is rapidly increasing it might
indiate that the total memory available and \Sum_i p_i,k + s_i,k has to
be taken into account. Hopefully such a thing can be avoided because it
would be expensive to calculate.

> +
> + * fairness
> +
> +For each task 't_i' we have a weight 'w_i' (related to nice), and each cpu
> +'c_n' has a compute capacity 'P_n', again, using our map 'C' we can formulate a
> +load 'L_n':
> +
> +  L_n = 1/P_n * \Sum_i w_i for all c_i = n
> +
> +using that we can formulate a load difference between CPUs
> +
> +  L_n,m = | L_n - L_m |
> +

This is showing a strong bias towards the scheduler. As you take w_i
into account, it potentially means that higher priority tasks can "push"
lower priority tasks and their memory off a node. This can lead to a
situation where a high priority task can starve a lower priority task as
the lower priority task now must dedicate cycles to moving its memory
around.

I understand your motivation for taking weight into account here but I
wonder if it's premature?

> +Which allows us to state the fairness goal like:
> +
> +  L_n,m(C0) =< L_n,m(C) for all C, n != m
> +
> +(pjt: It can also be usefully stated that, having converged at C0:
> +
> +   | L_n(C0) - L_m(C0) | <= 4/3 * | G_n( U(t_i, t_j) ) - G_m( U(t_i, t_j) ) |
> +
> +      Where G_n,m is the greedy partition of tasks between L_n and L_m. This is
> +      the "worst" partition we should accept; but having it gives us a useful 
> +      bound on how much we can reasonably adjust L_n/L_m at a Pareto point to 
> +      favor T_n,m. )
> +
> +Together they give us the complete multi-objective optimization problem:
> +
> +  min_C,M [ L_n,m(C), T_k,l(C,M) ]
> +

I admire the goal and the apparent simplicity but I think there are
potentially unexpected outcomes when you try to minimise both.

For example
  2-node machine, 24 cores, 4G per node
  1 compute process, 24 threads - workload is adaptive mesh computation
	of some sort that fits in 3G

  Early in the lifetime of this, it will be balanced between the two nodes
  (minimising interconnect traffic and CPU load). As it computes it might
  refine the mesh such that all 24 threads are operating on just 1G of
  memory on one node with a lot of false sharing within pages. In this case
  you effectively want the memory to be pinned on one node even if all
  threads are in use. As these pages are all probably in p (but maybe s,
  it's a gray area in this case) it potentially leads to a ping-pong effect
  when we minimise for L_n,m(C).  I know we would try to solve for both but
  as T_k,l is based on something we cannot accurately measure at runtime,
  there will be drift.

Another example
  2-node machine, 24 cores, 4G per node
  1 compute process, 2 threads, 1 thread needs 6G

  In this case we cannot minimise for T_k,l as spillover is inevitable and
  interconnect traffic will never be 0. To get around this, the scheduled
  CPU would always have to follow memory i.e. the thread uses cpu on node
  0 when operating on that memory and switching to a cpu on node 1 otherwise.
  I'm not sure how this can be modelled under the optimization problem
  as presented.

At this point I'm not proposing a solution - I'm just pointing out that
there are potential corner cases where this can get screwy.

FWIW, we still benefit from having this formally described even if it
cannot cover all the cases.

> +
> +
> +Notes:
> +
> + - the memory bandwidth problem is very much an inter-process problem, in
> +   particular there is no such concept as a process in the above problem.
> +

Yep.

> + - the naive solution would completely prefer fairness over interconnect
> +   traffic, the more complicated solution could pick another Pareto point using
> +   an aggregate objective function such that we balance the loss of work
> +   efficiency against the gain of running, we'd want to more or less suggest
> +   there to be a fixed bound on the error from the Pareto line for any
> +   such solution.
> +

I suspect that the Pareto point and objective function will depend on
the workload, whether it fits in the node and whether its usage of memory
between nodes and tasks is balanced or not.

It would be ideal though to have such a function.

> +References:
> +
> +  http://en.wikipedia.org/wiki/Mathematical_optimization
> +  http://en.wikipedia.org/wiki/Multi-objective_optimization
> +
> +
> +* warning, significant hand-waving ahead, improvements welcome *
> +
> +
> +Partial solutions / approximations:
> +
> + 1) have task node placement be a pure preference from the 'fairness' pov.
> +
> +This means we always prefer fairness over interconnect bandwidth. This reduces
> +the problem to:
> +
> +  min_C,M [ T_k,l(C,M) ]
> +

Is this not preferring interconnect bandwidth over fairness? i.e. always
reduce interconnect bandwidth regardless of how the CPUs are being used?

> + 2a) migrate memory towards 'n_i' (the task's node).
> +
> +This creates memory movement such that 'p_i,k for k != n_i' becomes 0 -- 
> +provided 'n_i' stays stable enough and there's sufficient memory (looks like
> +we might need memory limits for this).
> +

Not just memory limits, you may need to detect if p_i fits in k. Last thing
you need is an effect like zone_reclaim_mode==1 where t_i is reclaiming
its own memory to migrate pages to a local node. Such a thing could not
be happening currently as the benchmarks would have shown the scanning.

> +This does however not provide us with any 's_i' (shared) information. It does
> +however remove 'M' since it defines memory placement in terms of task
> +placement.
> +
> +XXX properties of this M vs a potential optimal
> +
> + 2b) migrate memory towards 'n_i' using 2 samples.
> +
> +This separates pages into those that will migrate and those that will not due
> +to the two samples not matching. We could consider the first to be of 'p_i'
> +(private) and the second to be of 's_i' (shared).
> +

When minimising for L_n,m this could cause problems. Lets say we are dealing
with the first example above. The memory should be effectively pinned on
one node. If we minimise for L_n, we are using CPUs on a remote node and
if it samples twice, it will migrate the memory setting up a potential
ping-pong effect if there is any false sharing of pages.

Of course, this is not a problem if the memory of a task can be partitioned
into s_i and p_i but it heavily depends on detecting s_i correctly.

> +This interpretation can be motivated by the previously observed property that
> +'p_i,k for k != n_i' should become 0 under sufficient memory, leaving only
> +'s_i' (shared). (here we loose the need for memory limits again, since it
> +becomes indistinguishable from shared).
> +
> +XXX include the statistical babble on double sampling somewhere near
> +

Minimally, I do not see an obvious way of describing why 3, 4, 7 or eleventy
samples would be better than 2. To high and it migrates too slowly. Too
low and it ping-pongs and the ideal number of samples is workload-dependant.

> +This reduces the problem further; we loose 'M' as per 2a, it further reduces
> +the 'T_k,l' (interconnect traffic) term to only include shared (since per the
> +above all private will be local):
> +
> +  T_k,l = \Sum_i bs_i,l for every n_i = k, l != k
> +
> +[ more or less matches the state of sched/numa and describes its remaining
> +  problems and assumptions. It should work well for tasks without significant
> +  shared memory usage between tasks. ]
> +
> +Possible future directions:
> +
> +Motivated by the form of 'T_k,l', try and obtain each term of the sum, so we
> +can evaluate it;
> +
> + 3a) add per-task per node counters
> +
> +At fault time, count the number of pages the task faults on for each node.
> +This should give an approximation of 'p_i' for the local node and 's_i,k' for
> +all remote nodes.
> +

Yes. The rate of sampling will determine how accurate it is.

> +While these numbers provide pages per scan, and so have the unit [pages/s] they
> +don't count repeat access and thus aren't actually representable for our
> +bandwidth numberes.
> +

Counting repeat accesses would require either continual profiling (and
hardware that can identify the data address not just the IP) or aggressive
sampling - neither which is appealing. In other words, an approximation
of p_i is as good as we are going to get.

> + 3b) additional frequency term
> +
> +Additionally (or instead if it turns out we don't need the raw 'p' and 's' 
> +numbers) we can approximate the repeat accesses by using the time since marking
> +the pages as indication of the access frequency.
> +

Risky. If the process blocks on IO this could skew in unexpected ways
because such an approximation assumes the task is CPU or memory bound.

> +Let 'I' be the interval of marking pages and 'e' the elapsed time since the
> +last marking, then we could estimate the number of accesses 'a' as 'a = I / e'.
> +If we then increment the node counters using 'a' instead of 1 we might get
> +a better estimate of bandwidth terms.
> +

Not keen on this one. It really assumes that there is more or less
constant use of the CPU.

> + 3c) additional averaging; can be applied on top of either a/b.
> +
> +[ Rik argues that decaying averages on 3a might be sufficient for bandwidth since
> +  the decaying avg includes the old accesses and therefore has a measure of repeat
> +  accesses.
> +

Minimally, it would be less vunerable to spikes.

> +  Rik also argued that the sample frequency is too low to get accurate access
> +  frequency measurements, I'm not entirely convinced, event at low sample 
> +  frequencies the avg elapsed time 'e' over multiple samples should still
> +  give us a fair approximation of the avg access frequency 'a'.
> +

Sampling too high also increases the risk of a ping-pong effect.

> +  So doing both b&c has a fair chance of working and allowing us to distinguish
> +  between important and less important memory accesses.
> +
> +  Experimentation has shown no benefit from the added frequency term so far. ]
> +

At this point, I prefer a&c over b&c but that could just be because I'm
wary of time-based heuristics having been bit by them once or twice.

> +This will give us 'bp_i' and 'bs_i,k' so that we can approximately compute
> +'T_k,l' Our optimization problem now reads:
> +
> +  min_C [ \Sum_i bs_i,l for every n_i = k, l != k ]
> +
> +And includes only shared terms, this makes sense since all task private memory
> +will become local as per 2.
> +
> +This suggests that if there is significant shared memory, we should try and
> +move towards it.
> +
> + 4) move towards where 'most' memory is
> +
> +The simplest significance test is comparing the biggest shared 's_i,k' against
> +the private 'p_i'. If we have more shared than private, move towards it.
> +

Depending on how s_i is calculated, this might also mitigate the ping-pong
problem.

> +This effectively makes us move towards where most our memory is and forms a
> +feed-back loop with 2. We migrate memory towards us and we migrate towards
> +where 'most' memory is.
> +
> +(Note: even if there were two tasks fully trashing the same shared memory, it
> +       is very rare for there to be an 50/50 split in memory, lacking a perfect
> +       split, the small will move towards the larger. In case of the perfect
> +       split, we'll tie-break towards the lower node number.)
> +
> + 5) 'throttle' 4's node placement
> +
> +Since per 2b our 's_i,k' and 'p_i' require at least two scans to 'stabilize'
> +and show representative numbers, we should limit node-migration to not be
> +faster than this.
> +
> + n) poke holes in previous that require more stuff and describe it.
> 

Even as it is, this is a helpful description of the problem! Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
