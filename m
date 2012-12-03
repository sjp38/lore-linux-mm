Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 6D8736B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 05:44:00 -0500 (EST)
Date: Mon, 3 Dec 2012 10:43:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/10] Latest numa/core release, v18
Message-ID: <20121203104350.GH8218@suse.de>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

I was away for the weekend so did not see this until Sunday night. I
queued up tip/master as it looked at that time and ran it overnight. In
general, I have not looked closely at any of the patches.

As a heads-up, I'm also flying very early tomorrow morning and will be
travelling for the week. I'll have intermittent access to email and *should*
be able to access my test machine remotely but my responsiveness will vary.

On Fri, Nov 30, 2012 at 08:58:31PM +0100, Ingo Molnar wrote:
> I'm pleased to announce the latest, -v18 numa/core release.
> 
> This release fixes regressions and improves NUMA performance.
> It has the following main changes:
> 
>   - Introduce directed NUMA convergence, which is based on
>     the 'task buddy' relation introduced in -v17, and make
>     use of the new "task flipping" facility.
> 
>   - Add "related task group" balancing notion to the scheduler, to
>     be able to 'compress' and 'spread' NUMA workloads
>     based on which tasks relate to each other via their
>     working set (i.e. which tasks access the same memory areas).
> 
>   - Track the quality and strength of NUMA convergence and
>     create a feedback loop with the scheduler:
> 
>      - use it to direct migrations
> 
>      - use it to slow down and speed up the rate of the
>        NUMA hinting page faults
> 
>   - Turn 4K pte NUMA faults into effective hugepage ones
> 

This one spiked my interest and I took a closer look.

It does multiple things including a cleanup but at a glance it looks like it
has similar problems to the earlier version of this patch when I reviewed
it here https://lkml.org/lkml/2012/11/21/238.  It looks like you'll still
incur a PMDs-worth of work even if the workload has not converged within
that PMD boundary. The trylock, lock, unlock, put, refault is new as well
and it's not clear what it's for.  It's neither clear why you need the page
lock in this path or why you decide to always refault if it's contended
instead of rechecking the PTE.

I know the page lock is taken in the transhuge patch but it's a massive hack
and not required here as such. migration does take the page lock but
it's done later.

This was based on just a quick glance and I likely missed a bunch of
obvious things that may have alleviated my concerns after the last
review.

>   - Refine the 'shared tasks' memory interleaving logic
> 
>   - Improve CONFIG_NUMA_BALANCING=y OOM behavior
> 
> One key practical area of improvement are enhancements to
> the NUMA convergence of "multiple JVM" kind of workloads.
> 
> As a recap, this was -v17 performance with 4x SPECjbb instances
> on a 4-node system (32 CPUs, 4 instances, 8 warehouses each, 240
> seconds runtime, +THP):
> 
>      spec1.txt:           throughput =     177460.44 SPECjbb2005 bops
>      spec2.txt:           throughput =     176175.08 SPECjbb2005 bops
>      spec3.txt:           throughput =     175053.91 SPECjbb2005 bops
>      spec4.txt:           throughput =     171383.52 SPECjbb2005 bops
>                                       --------------------------
>            SUM:           throughput =     700072.95 SPECjbb2005 bops
> 
> The new -v18 figures are:
> 
>      spec1.txt:           throughput =     191415.52 SPECjbb2005 bops 
>      spec2.txt:           throughput =     193481.96 SPECjbb2005 bops 
>      spec3.txt:           throughput =     192865.30 SPECjbb2005 bops 
>      spec4.txt:           throughput =     191627.40 SPECjbb2005 bops 
>                                            --------------------------
>            SUM:           throughput =     769390.18 SPECjbb2005 bops
> 
> Which is 10% faster than -v17, 22% faster than mainline and it is
> within 1% of the hard-binding results (where each JVM is explicitly
> memory and CPU-bound to a single node each).
> 
> Occording to my measurements the -v18 NUMA kernel is also faster than
> AutoNUMA (+THP-fix):
> 
>      spec1.txt:           throughput =     184327.49 SPECjbb2005 bops
>      spec2.txt:           throughput =     187508.83 SPECjbb2005 bops
>      spec3.txt:           throughput =     186206.44 SPECjbb2005 bops
>      spec4.txt:           throughput =     188739.22 SPECjbb2005 bops
>                                            --------------------------
>            SUM:           throughput =     746781.98 SPECjbb2005 bops
> 
> Mainline has the following 4x JVM performance:
> 
>      spec1.txt:           throughput =     157839.25 SPECjbb2005 bops
>      spec2.txt:           throughput =     156969.15 SPECjbb2005 bops
>      spec3.txt:           throughput =     157571.59 SPECjbb2005 bops
>      spec4.txt:           throughput =     157873.86 SPECjbb2005 bops
>                                       --------------------------
>            SUM:           throughput =     630253.85 SPECjbb2005 bops
> 
> Another key area of improvement is !THP (4K pages) performance.
> 
> Mainline 4x SPECjbb !THP JVM results:
> 
>      spec1.txt:           throughput =     128575.47 SPECjbb2005 bops 
>      spec2.txt:           throughput =     125767.24 SPECjbb2005 bops 
>      spec3.txt:           throughput =     130042.30 SPECjbb2005 bops 
>      spec4.txt:           throughput =     128155.32 SPECjbb2005 bops 
>                                        --------------------------
>            SUM:           throughput =     512540.33 SPECjbb2005 bops
> 
> 
> numa/core -v18 4x SPECjbb JVM !THP results:
> 
>      spec1.txt:           throughput =     158023.05 SPECjbb2005 bops 
>      spec2.txt:           throughput =     156895.51 SPECjbb2005 bops 
>      spec3.txt:           throughput =     156158.11 SPECjbb2005 bops 
>      spec4.txt:           throughput =     157414.52 SPECjbb2005 bops 
>                                       --------------------------
>            SUM:           throughput =     628491.19 SPECjbb2005 bops
> 
> That too is roughly 22% faster than mainline - the !THP regression
> that was reported by Mel Gorman appears to be fixed.
> 

Ok, luckily I had queued a full set of tests over the weekend and adding
tip/master as of last night was not an issue. It looks like it completed
an hour ago so I'll go through it shortly and report what I see.

> AutoNUMA-benchmark comparison to the mainline kernel:
> 
>  ##############
>  # res-v3.6-vanilla.log vs res-numacore-v18b.log:
>  #------------------------------------------------------------------------------------>
>    autonuma benchmark                run time (lower is better)         speedup %
>  ------------------------------------------------------------------------------------->
>    numa01                           :   337.29  vs.  177.64   |           +89.8 %
>    numa01_THREAD_ALLOC              :   428.79  vs.  127.07   |          +237.4 %
>    numa02                           :    56.32  vs.   18.08   |          +211.5 %
>    ------------------------------------------------------------
> 
> (this is similar to -v17, within noise.)
> 
> Comparison to AutoNUMA-v28 (+THP-fix):
> 
>  ##############
>  # res-autonuma-v28-THP.log vs res-numacore-v18b.log:
>  #------------------------------------------------------------------------------------>
>    autonuma benchmark                run time (lower is better)         speedup %
>  ------------------------------------------------------------------------------------->
>    numa01                           :   235.77  vs.  177.64   |           +32.7 %
>    numa01_THREAD_ALLOC              :   134.53  vs.  127.07   |            +5.8 %
>    numa02                           :    19.49  vs.   18.08   |            +7.7 %
>    ------------------------------------------------------------
> 
> A few caveats: I'm still seeing problems on !THP.
> 
> Here's the analysis of one of the last regression sources I'm still
> seeing with it on larger systems. I have identified the source
> of the regression, and I see how the AutoNUMA and 'balancenuma' trees
> solved this problem - but I disagree with the solution.
> 
> When pushed hard enough via threaded workloads (for example via the
> numa02 test) then the upstream page migration code in mm/migration.c
> becomes unscalable, resulting in lot of scheduling on the anon vma
> mutex and a subsequent drop in performance.
> 
> When the points of scheduling are call-graph profiled, the
> unscalability appears to be due to interaction between the
> following page migration code paths:
> 
>     96.43%        process 0  [kernel.kallsyms]  [k] perf_trace_sched_switch
>                   |
>                   --- perf_trace_sched_switch
>                       __schedule
>                       schedule
>                       schedule_preempt_disabled
>                       __mutex_lock_common.isra.6
>                       __mutex_lock_slowpath
>                       mutex_lock
>                      |
>                      |--50.61%-- rmap_walk
>                      |          move_to_new_page
>                      |          migrate_pages
>                      |          migrate_misplaced_page
>                      |          __do_numa_page.isra.69
>                      |          handle_pte_fault
>                      |          handle_mm_fault
>                      |          __do_page_fault
>                      |          do_page_fault
>                      |          page_fault
>                      |          __memset_sse2
>                      |          |
>                      |           --100.00%-- worker_thread
>                      |                     |
>                      |                      --100.00%-- start_thread
>                      |
>                       --49.39%-- page_lock_anon_vma
>                                 try_to_unmap_anon
>                                 try_to_unmap
>                                 migrate_pages
>                                 migrate_misplaced_page
>                                 __do_numa_page.isra.69
>                                 handle_pte_fault
>                                 handle_mm_fault
>                                 __do_page_fault
>                                 do_page_fault
>                                 page_fault
>                                 __memset_sse2
>                                 |
>                                  --100.00%-- worker_thread
>                                            start_thread
> 
> From what I can see theAutoNUMA and 'balancenuma' kernels works
> around this !THP scalability issue by rate-limiting migrations.
> For example balancenuma rate-limits migrations to about 1.2 GB/sec
> bandwidth.
> 

This is not what rate limiting was concerned with. Rate limiting addressed
two concerns.

1. NUMA balancing should not consume a high percentage of memory
   bandwidth
2. If the policy encounters an adverse workload, the machine should not
   drastically slow down due to spending all its time migrating.

The two concerns are related. The first one is basically saying that
perfect balancing is pointless if the actual workload is not able to
access memory because the bus is congested. The second is more important
as I was basically assuming that no matter how smart a policy is that it
would eventually encounter a workload it simply could not handle properly
and broke down. When that happens, we do not want the users machine to
fall apart. Rate limiting is a backstop as to how *bad* we can get.

Consider a deliberately adverse workload that creates a process per node
and allocates an amount of memory per process. Every scan interval, it
binds its CPUs to the next node. The intention of this workload would
be to maximise the amount of migration NUMA balancing does. Without rate
limiting, a few instances of this workload could keep the memory bus filled
with migration traffic and potentially be a local DOS.

That said, I agree that getting bottlenecked here is unfortunate and
should be addressed but it does not obviate the need for rate limiting.

> Rate-limiting to solve scalability limits is not the right
> solution IMO, because it hurts cases where migration is justified.
> The migration of the working set itself is not a problem, it would
> in fact be beneficial - but our implementation of it does not scale
> beyond a certain rate.
> 

Which would be logical if scalability was the problem it was addressing
but it's not. It's to stop the machine going to pot if there is a hostile
user of a shared machine or the policy breaks down.

> ( THP, which has a 512 times lower natural rate of migration page
>   faults, does not run into this scalability limit. )
> 
> So this issue is still open and testers are encouraged to use THP
> if they can.
> 

As before not everything can use THP. For example, openMPI by default on
local machine communicates with shared mappings in /tmp/. Granted, this
is only important during communication so one would hope it's only a
factor during the initial setup and during the final reduction. Also
remember that THP is not always available due to fragmentation or
because the watermarks are not met if the NUMA node has most of its
memory allocated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
