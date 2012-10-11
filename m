Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EDF636B006C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 12:07:49 -0400 (EDT)
Date: Thu, 11 Oct 2012 18:07:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01/33] autonuma: add Documentation/vm/autonuma.txt
Message-ID: <20121011160702.GJ1818@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-2-git-send-email-aarcange@redhat.com>
 <20121011105036.GN3317@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011105036.GN3317@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi,

On Thu, Oct 11, 2012 at 11:50:36AM +0100, Mel Gorman wrote:
> On Thu, Oct 04, 2012 at 01:50:43AM +0200, Andrea Arcangeli wrote:
> > +The AutoNUMA logic is a chain reaction resulting from the actions of
> > +the AutoNUMA daemon, knum_scand. The knuma_scand daemon periodically
> 
> s/knum_scand/knuma_scand/

Applied.

> > +scans the mm structures of all active processes. It gathers the
> > +AutoNUMA mm statistics for each "anon" page in the process's working
> 
> Ok, so this will not make a different to file-based workloads but as I
> mentioned in the leader this would be a difficult proposition anyway
> because if it's read/write based, you'll have no statistics.

Oops sorry for the confusion but the the doc is wrong on this one: it
actually tracks anything with a page_mapcount == 1, even if that is
pagecache or even .text as long as it's only mapped in a single
process. So if you've a threaded database doing a gigantic MAP_SHARED,
it'll track and move around the whole MAP_SHARED as well as anonymous
memory or anything that can be moved.

Changed to:

+AutoNUMA mm statistics for each not shared page in the process's

> > +set. While scanning, knuma_scand also sets the NUMA bit and clears the
> > +present bit in each pte or pmd that was counted. This triggers NUMA
> > +hinting page faults described next.
> > +
> > +The mm statistics are expentially decayed by dividing the total memory
> > +in half and adding the new totals to the decayed values for each
> > +knuma_scand pass. This causes the mm statistics to resemble a simple
> > +forecasting model, taking into account some past working set data.
> > +
> > +=== NUMA hinting fault ===
> > +
> > +A NUMA hinting fault occurs when a task running on a CPU thread
> > +accesses a vma whose pte or pmd is not present and the NUMA bit is
> > +set. The NUMA hinting page fault handler returns the pte or pmd back
> > +to its present state and counts the fault's occurance in the
> > +task_autonuma structure.
> > +
> 
> So, minimally one source of System CPU overhead will be increased traps.

Correct.

It takes down 128M every 100msec, and then when it finished taking
down everything it sleeps 10sec, then increases the pass_counter and
restarts. It's not measurable, even if I do a kernel build with -j128
in tmpfs the performance is identical with autonuma running or not.

> I haven't seen the code yet obviously but I wonder if this gets accounted
> for as a minor fault? If it does, how can we distinguish between minor
> faults and numa hinting faults? If not, is it possible to get any idea of
> how many numa hinting faults were incurred? Mention it here.

Yes, it's surely accounted as minor fault. To monitor it normally I
use:

perf probe numa_hinting_fault
perf record -e probe:numa_hinting_fault -aR -g sleep 10
perf report -g

# Samples: 345  of event 'probe:numa_hinting_fault'
# Event count (approx.): 345
#
# Overhead  Command      Shared Object                  Symbol
# ........  .......  .................  ......................
#
    64.64%     perf  [kernel.kallsyms]  [k] numa_hinting_fault
               |
               --- numa_hinting_fault
                   handle_mm_fault
                   do_page_fault
                   page_fault
                  |          
                  |--57.40%-- sig_handler
                  |          |          
                  |          |--62.50%-- run_builtin
                  |          |          main
                  |          |          __libc_start_main
                  |          |          
                  |           --37.50%-- 0x7f47f7c6cba0
                  |                     run_builtin
                  |                     main
                  |                     __libc_start_main
                  |          
                  |--16.59%-- __poll
                  |          run_builtin
                  |          main
                  |          __libc_start_main
                  |          
                  |--9.87%-- 0x7f47f7c6cba0
                  |          run_builtin
                  |          main
                  |          __libc_start_main
                  |          
                  |--9.42%-- save_i387_xstate
                  |          do_signal
                  |          do_notify_resume
                  |          int_signal
                  |          __poll
                  |          run_builtin
                  |          main
                  |          __libc_start_main
                  |          
                   --6.73%-- sys_poll
                             system_call_fastpath
                             __poll

    21.45%     ntpd  [kernel.kallsyms]  [k] numa_hinting_fault
               |
               --- numa_hinting_fault
                   handle_mm_fault
                   do_page_fault
                   page_fault
                  |          
                  |--66.22%-- 0x42b910
                  |          0x0
                  |          
                  |--24.32%-- __select
                  |          0x0
                  |          
                  |--4.05%-- do_signal
                  |          do_notify_resume
                  |          int_signal
                  |          __select
                  |          0x0
                  |          
                  |--2.70%-- 0x7f88827b3ba0
                  |          0x0
                  |          
                   --2.70%-- clock_gettime
                             0x1a1eb808

     7.83%     init  [kernel.kallsyms]  [k] numa_hinting_fault
               |
               --- numa_hinting_fault
                   handle_mm_fault
                   do_page_fault
                   page_fault
                  |          
                  |--33.33%-- __select
                  |          0x0
                  |          
                  |--29.63%-- 0x404e0c
                  |          0x0
                  |          
                  |--18.52%-- 0x405820
                  |          
                  |--11.11%-- sys_select
                  |          system_call_fastpath
                  |          __select
                  |          0x0
                  |          
                   --7.41%-- 0x402528

     6.09%    sleep  [kernel.kallsyms]  [k] numa_hinting_fault
              |
              --- numa_hinting_fault
                  handle_mm_fault
                  do_page_fault
                  page_fault
                 |          
                 |--42.86%-- 0x7f0f67847fe0
                 |          0x7fff4cd6d42b
                 |          
                 |--28.57%-- 0x404007
                 |          
                 |--19.05%-- nanosleep
                 |          
                  --9.52%-- 0x4016d0
                            0x7fff4cd6d42b


Chances are we want to add more vmstat for this event.

> > +The NUMA hinting fault gathers the AutoNUMA task statistics as follows:
> > +
> > +- Increments the total number of pages faulted for this task
> > +
> > +- Increments the number of pages faulted on the current NUMA node
> > +
> 
> So, am I correct in assuming that the rate of NUMA hinting faults will be
> related to the scan rate of knuma_scand?

This is correct. They're identical.

There's a slight chance that two threads hit the fault on the same
pte/pmd_numa concurrently, but just one of the two will actually
invoke the numa_hinting_fault() function.

> > +- If the fault was for an hugepage, the number of subpages represented
> > +  by an hugepage is added to the task statistics above
> > +
> > +- Each time the NUMA hinting page fault discoveres that another
> 
> s/discoveres/discovers/

Fixed.

> 
> > +  knuma_scand pass has occurred, it divides the total number of pages
> > +  and the pages for each NUMA node in half. This causes the task
> > +  statistics to be exponentially decayed, just as the mm statistics
> > +  are. Thus, the task statistics also resemble a simple forcasting

Also noticed forecasting ;).

> > +  model, taking into account some past NUMA hinting fault data.
> > +
> > +If the page being accessed is on the current NUMA node (same as the
> > +task), the NUMA hinting fault handler only records the nid of the
> > +current NUMA node in the page_autonuma structure field last_nid and
> > +then it'd done.
> > +
> > +Othewise, it checks if the nid of the current NUMA node matches the
> > +last_nid in the page_autonuma structure. If it matches it means it's
> > +the second NUMA hinting fault for the page occurring (on a subsequent
> > +pass of the knuma_scand daemon) from the current NUMA node.
> 
> You don't spell it out, but this is effectively a migration threshold N
> where N is the number of remote NUMA hinting faults that must be
> incurred before migration happens. The default value of this threshold
> is 2.
> 
> Is that accurate? If so, why 2?

More like 1. It needs one confirmation the migrate request come from
the same node again (note: it is allowed to come from a different
threads as long as it's the same node and that is very important).

Why only 1 confirmation? It's the same as page aging. We could record
the number of pagecache lookup hits, and not just have a single bit as
reference count. But doing so, if the workload radically changes it
takes too much time to adapt to the new configuration and so I usually
don't like counting.

Plus I avoided as much as possible fixed numbers. I can explain why 0
or 1, but I can't as easily explain why 5 or 8, so if I can't explain
it, I avoid it.

> I don't have a better suggestion, it's just an obvious source of an
> adverse workload that could force a lot of migrations by faulting once
> per knuma_scand cycle and scheduling itself on a remote CPU every 2 cycles.

Correct, for certain workloads like single instance specjbb that
wasn't enough, but it is fixed in autonuma28, now it's faster even on
single instance.

> I'm assuming it must be async migration then. IO in progress would be
> a bit of a surprise though! It would have to be a mapped anonymous page
> being written to swap.

It's all migrate on fault now, but I'm using all methods you implemented to
avoid compaction to block in migrate_pages.

> > +=== Task exchange ===
> > +
> > +The following defines "weight" in the AutoNUMA balance routine's
> > +algorithm.
> > +
> > +If the tasks are threads of the same process:
> > +
> > +    weight = task weight for the NUMA node (since memory weights are
> > +             the same)
> > +
> > +If the tasks are not threads of the same process:
> > +
> > +    weight = memory weight for the NUMA node (prefer to move the task
> > +             to the memory)
> > +
> > +The following algorithm determines if the current task will be
> > +exchanged with a running task on a remote NUMA node:
> > +
> > +    this_diff: Weight of the current task on the remote NUMA node
> > +               minus its weight on the current NUMA node (only used if
> > +               a positive value). How much does the current task
> > +               prefer to run on the remote NUMA node.
> > +
> > +    other_diff: Weight of the current task on the remote NUMA node
> > +                minus the weight of the other task on the same remote
> > +                NUMA node (only used if a positive value). How much
> > +                does the current task prefer to run on the remote NUMA
> > +                node compared to the other task.
> > +
> > +    total_weight_diff = this_diff + other_diff
> > +
> > +    total_weight_diff: How favorable it is to exchange the two tasks.
> > +                       The pair of tasks with the highest
> > +                       total_weight_diff (if any) are selected for
> > +                       exchange.
> > +
> > +As mentioned above, if the two tasks are threads of the same process,
> > +the AutoNUMA balance routine uses the task_autonuma statistics. By
> > +using the task_autonuma statistics, each thread follows its own memory
> > +locality and they will not necessarily converge on the same node. This
> > +is often very desirable for processes with more threads than CPUs on
> > +each NUMA node.
> > +
> 
> What about the case where two threads on different CPUs are accessing

I assume on different nodes (different cpus if in the same node, the
above won't kick in).

> separate structures that are not page-aligned (base or huge page but huge
> page would be obviously worse). Does this cause a ping-pong effect or
> otherwise mess up the statistics?

Very good point! This is exactly what I call NUMA false sharing and
it's the biggest nightmare in this whole effort.

So if there's an huge amount of this over time the statistics will be
around 50/50 (the statistics just record the working set of the
thread).

So if there's another process (note: thread not) heavily computing the
50/50 won't be used and the mm statistics will be used instead to
balance the two threads against the other process. And the two threads
will converge in the same node, and then their thread statistics will
change from 50/50 to 0/100 matching the mm statistics.

If there are just threads and they're all doing what you describe
above with all their memory, well then the problem has no solution,
and the new stuff in autonuma28 will deal with that too.

Ideally we should do MADV_INTERLEAVE, I didn't get that far yet but I
probably could now.

Even without the new stuff it wasn't too bad but there were a bit too
many spurious migrations in that load with autonuma27 and previous. It
was less spurious on bigger systems with many nodes because last_nid
is implicitly more accurate there (as last_nid will have more possible
values than 0|1). With autonuma28 even on 2 nodes it's perfectly fine.

If it's just 1 page false sharing and all the rest is thread-local,
the statistics will be 99/1 and the false sharing will be lost in the
noise.

The false sharing spillover caused by alignments is minor if the
threads are really computing on a lot of local memory so it's not a
concern and it will be optimized away by the last_nid plus the new
stuff.

> Ok, very obviously this will never be an RT feature but that is hardly
> a surprise and anyone who tries to enable this for RT needs their head
> examined. I'm not suggesting you do it but people running detailed
> performance analysis on scheduler-intensive workloads might want to keep
> an eye on their latency and jitter figures and how they are affected by
> this exchanging. Does ftrace show a noticable increase in wakeup latencies
> for example?

If you do:

echo 1 >/sys/kernel/mm/autonuma/debug

you will get 1 printk every single time sched_autonuma_balance
triggers a task exchange.

With autonuma28 I resolved a lot of the jittering and now there are
6/7 printk for the whole 198 seconds of numa01. CFS runs in autopilot
all the time.

With specjbb x2 overcommit, the active balancing events are reduced to
one every few sec (vs several per sec with autonuma27). In fact the
specjbb x2 overcommit load jumped ahead too with autonuma28.

About tracing events, the git branch already has tracing events to
monitor all page and task migrations showed in an awesome "perf script
numatop" from Andrew. Likely we need one tracing event to see the task
exchange generated specifically by the autonuma balancing event (we're
running short in event columns to show it in numatop though ;). Right
now that is only available as the printk above.

> > +=== task_autonuma - per task AutoNUMA data ===
> > +
> > +The task_autonuma structure is used to hold AutoNUMA data required for
> > +each mm task (process/thread). Total size: 10 bytes + 8 * # of NUMA
> > +nodes.
> > +
> > +- selected_nid: preferred NUMA node as determined by the AutoNUMA
> > +                scheduler balancing code, -1 if none (2 bytes)
> > +
> > +- Task NUMA statistics for this thread/process:
> > +
> > +    Total number of NUMA hinting page faults in this pass of
> > +    knuma_scand (8 bytes)
> > +
> > +    Per NUMA node number of NUMA hinting page faults in this pass of
> > +    knuma_scand (8 bytes * # of NUMA nodes)
> > +
> 
> It might be possible to put a coarse ping-pong detection counter in here
> as well by recording a declaying average of number of pages migrated
> over a number of knuma_scand passes instead of just the last one.  If the
> value is too high, you're ping-ponging and the process should be ignored,
> possibly forever. It's not a requirement and it would be more memory
> overhead obviously but I'm throwing it out there as a suggestion if it
> ever turns out the ping-pong problem is real.

Yes, this is a problem where we've an enormous degree in trying
things, so your suggestions are very appreciated :).

About ping ponging of CPU I never seen it yet (even if it's 550/450,
it rarely switches over from 450/550, and even it does, it doesn't
really change anything because it's a fairly rare event and one node
is not more right than the other anyway).

Thanks a lot for the help!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
