Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 8D68F6B0075
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:08:23 -0400 (EDT)
Message-Id: <20121025124832.621452204@chello.nl>
Date: Thu, 25 Oct 2012 14:16:19 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/31] sched, numa, mm: Describe the NUMA scheduling problem formally
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0002-sched-numa-mm-Describe-the-NUMA-scheduling-problem-f.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@kernel.org>

This is probably a first: formal description of a complex high-level
computing problem, within the kernel source.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mike Galbraith <efault@gmx.de>
Rik van Riel <riel@redhat.com>
[ Next step: generate the kernel source from such formal descriptions and retire to a tropical island! ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 Documentation/scheduler/numa-problem.txt |  230 +++++++++++++++++++++++++++++++
 1 file changed, 230 insertions(+)
 create mode 100644 Documentation/scheduler/numa-problem.txt

Index: tip/Documentation/scheduler/numa-problem.txt
===================================================================
--- /dev/null
+++ tip/Documentation/scheduler/numa-problem.txt
@@ -0,0 +1,230 @@
+
+
+Effective NUMA scheduling problem statement, described formally:
+
+ * minimize interconnect traffic
+
+For each task 't_i' we have memory, this memory can be spread over multiple
+physical nodes, let us denote this as: 'p_i,k', the memory task 't_i' has on
+node 'k' in [pages].  
+
+If a task shares memory with another task let us denote this as:
+'s_i,k', the memory shared between tasks including 't_i' residing on node
+'k'.
+
+Let 'M' be the distribution that governs all 'p' and 's', ie. the page placement.
+
+Similarly, lets define 'fp_i,k' and 'fs_i,k' resp. as the (average) usage
+frequency over those memory regions [1/s] such that the product gives an
+(average) bandwidth 'bp' and 'bs' in [pages/s].
+
+(note: multiple tasks sharing memory naturally avoid duplicat accounting
+       because each task will have its own access frequency 'fs')
+
+(pjt: I think this frequency is more numerically consistent if you explicitly 
+      restrict p/s above to be the working-set. (It also makes explicit the 
+      requirement for <C0,M0> to change about a change in the working set.)
+
+      Doing this does have the nice property that it lets you use your frequency
+      measurement as a weak-ordering for the benefit a task would receive when
+      we can't fit everything.
+
+      e.g. task1 has working set 10mb, f=90%
+           task2 has working set 90mb, f=10%
+
+      Both are using 9mb/s of bandwidth, but we'd expect a much larger benefit
+      from task1 being on the right node than task2. )
+
+Let 'C' map every task 't_i' to a cpu 'c_i' and its corresponding node 'n_i':
+
+  C: t_i -> {c_i, n_i}
+
+This gives us the total interconnect traffic between nodes 'k' and 'l',
+'T_k,l', as:
+
+  T_k,l = \Sum_i bp_i,l + bs_i,l + \Sum bp_j,k + bs_j,k where n_i == k, n_j == l
+
+And our goal is to obtain C0 and M0 such that:
+
+  T_k,l(C0, M0) =< T_k,l(C, M) for all C, M where k != l
+
+(note: we could introduce 'nc(k,l)' as the cost function of accessing memory
+       on node 'l' from node 'k', this would be useful for bigger NUMA systems
+
+ pjt: I agree nice to have, but intuition suggests diminishing returns on more
+      usual systems given factors like things like Haswell's enormous 35mb l3
+      cache and QPI being able to do a direct fetch.)
+
+(note: do we need a limit on the total memory per node?)
+
+
+ * fairness
+
+For each task 't_i' we have a weight 'w_i' (related to nice), and each cpu
+'c_n' has a compute capacity 'P_n', again, using our map 'C' we can formulate a
+load 'L_n':
+
+  L_n = 1/P_n * \Sum_i w_i for all c_i = n
+
+using that we can formulate a load difference between CPUs
+
+  L_n,m = | L_n - L_m |
+
+Which allows us to state the fairness goal like:
+
+  L_n,m(C0) =< L_n,m(C) for all C, n != m
+
+(pjt: It can also be usefully stated that, having converged at C0:
+
+   | L_n(C0) - L_m(C0) | <= 4/3 * | G_n( U(t_i, t_j) ) - G_m( U(t_i, t_j) ) |
+
+      Where G_n,m is the greedy partition of tasks between L_n and L_m. This is
+      the "worst" partition we should accept; but having it gives us a useful 
+      bound on how much we can reasonably adjust L_n/L_m at a Pareto point to 
+      favor T_n,m. )
+
+Together they give us the complete multi-objective optimization problem:
+
+  min_C,M [ L_n,m(C), T_k,l(C,M) ]
+
+
+
+Notes:
+
+ - the memory bandwidth problem is very much an inter-process problem, in
+   particular there is no such concept as a process in the above problem.
+
+ - the naive solution would completely prefer fairness over interconnect
+   traffic, the more complicated solution could pick another Pareto point using
+   an aggregate objective function such that we balance the loss of work
+   efficiency against the gain of running, we'd want to more or less suggest
+   there to be a fixed bound on the error from the Pareto line for any
+   such solution.
+
+References:
+
+  http://en.wikipedia.org/wiki/Mathematical_optimization
+  http://en.wikipedia.org/wiki/Multi-objective_optimization
+
+
+* warning, significant hand-waving ahead, improvements welcome *
+
+
+Partial solutions / approximations:
+
+ 1) have task node placement be a pure preference from the 'fairness' pov.
+
+This means we always prefer fairness over interconnect bandwidth. This reduces
+the problem to:
+
+  min_C,M [ T_k,l(C,M) ]
+
+ 2a) migrate memory towards 'n_i' (the task's node).
+
+This creates memory movement such that 'p_i,k for k != n_i' becomes 0 -- 
+provided 'n_i' stays stable enough and there's sufficient memory (looks like
+we might need memory limits for this).
+
+This does however not provide us with any 's_i' (shared) information. It does
+however remove 'M' since it defines memory placement in terms of task
+placement.
+
+XXX properties of this M vs a potential optimal
+
+ 2b) migrate memory towards 'n_i' using 2 samples.
+
+This separates pages into those that will migrate and those that will not due
+to the two samples not matching. We could consider the first to be of 'p_i'
+(private) and the second to be of 's_i' (shared).
+
+This interpretation can be motivated by the previously observed property that
+'p_i,k for k != n_i' should become 0 under sufficient memory, leaving only
+'s_i' (shared). (here we loose the need for memory limits again, since it
+becomes indistinguishable from shared).
+
+XXX include the statistical babble on double sampling somewhere near
+
+This reduces the problem further; we loose 'M' as per 2a, it further reduces
+the 'T_k,l' (interconnect traffic) term to only include shared (since per the
+above all private will be local):
+
+  T_k,l = \Sum_i bs_i,l for every n_i = k, l != k
+
+[ more or less matches the state of sched/numa and describes its remaining
+  problems and assumptions. It should work well for tasks without significant
+  shared memory usage between tasks. ]
+
+Possible future directions:
+
+Motivated by the form of 'T_k,l', try and obtain each term of the sum, so we
+can evaluate it;
+
+ 3a) add per-task per node counters
+
+At fault time, count the number of pages the task faults on for each node.
+This should give an approximation of 'p_i' for the local node and 's_i,k' for
+all remote nodes.
+
+While these numbers provide pages per scan, and so have the unit [pages/s] they
+don't count repeat access and thus aren't actually representable for our
+bandwidth numberes.
+
+ 3b) additional frequency term
+
+Additionally (or instead if it turns out we don't need the raw 'p' and 's' 
+numbers) we can approximate the repeat accesses by using the time since marking
+the pages as indication of the access frequency.
+
+Let 'I' be the interval of marking pages and 'e' the elapsed time since the
+last marking, then we could estimate the number of accesses 'a' as 'a = I / e'.
+If we then increment the node counters using 'a' instead of 1 we might get
+a better estimate of bandwidth terms.
+
+ 3c) additional averaging; can be applied on top of either a/b.
+
+[ Rik argues that decaying averages on 3a might be sufficient for bandwidth since
+  the decaying avg includes the old accesses and therefore has a measure of repeat
+  accesses.
+
+  Rik also argued that the sample frequency is too low to get accurate access
+  frequency measurements, I'm not entirely convinced, event at low sample 
+  frequencies the avg elapsed time 'e' over multiple samples should still
+  give us a fair approximation of the avg access frequency 'a'.
+
+  So doing both b&c has a fair chance of working and allowing us to distinguish
+  between important and less important memory accesses.
+
+  Experimentation has shown no benefit from the added frequency term so far. ]
+
+This will give us 'bp_i' and 'bs_i,k' so that we can approximately compute
+'T_k,l' Our optimization problem now reads:
+
+  min_C [ \Sum_i bs_i,l for every n_i = k, l != k ]
+
+And includes only shared terms, this makes sense since all task private memory
+will become local as per 2.
+
+This suggests that if there is significant shared memory, we should try and
+move towards it.
+
+ 4) move towards where 'most' memory is
+
+The simplest significance test is comparing the biggest shared 's_i,k' against
+the private 'p_i'. If we have more shared than private, move towards it.
+
+This effectively makes us move towards where most our memory is and forms a
+feed-back loop with 2. We migrate memory towards us and we migrate towards
+where 'most' memory is.
+
+(Note: even if there were two tasks fully trashing the same shared memory, it
+       is very rare for there to be an 50/50 split in memory, lacking a perfect
+       split, the small will move towards the larger. In case of the perfect
+       split, we'll tie-break towards the lower node number.)
+
+ 5) 'throttle' 4's node placement
+
+Since per 2b our 's_i,k' and 'p_i' require at least two scans to 'stabilize'
+and show representative numbers, we should limit node-migration to not be
+faster than this.
+
+ n) poke holes in previous that require more stuff and describe it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
