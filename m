Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A95416B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 03:15:38 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1636047wgb.26
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 00:15:37 -0700 (PDT)
Date: Fri, 26 Oct 2012 09:15:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
Message-ID: <20121026071532.GC8141@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.467791319@chello.nl>
 <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Oct 25, 2012 at 5:16 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > +       /*
> > +        * Using runtime rather than walltime has the dual advantage that
> > +        * we (mostly) drive the selection from busy threads and that the
> > +        * task needs to have done some actual work before we bother with
> > +        * NUMA placement.
> > +        */
> 
> That explanation makes sense..
> 
> > +       now = curr->se.sum_exec_runtime;
> > +       period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
> > +
> > +       if (now - curr->node_stamp > period) {
> > +               curr->node_stamp = now;
> > +
> > +               if (!time_before(jiffies, curr->mm->numa_next_scan)) {
> 
> .. but then the whole "numa_next_scan" thing ends up being 
> about real-time anyway?
>
> So 'numa_scan_period' in in CPU time (msec, converted to nsec 
> at runtime rather than when setting it), but 'numa_next_scan' 
> is in wallclock time (jiffies)?
> 
> But *both* of them are based on the same 'numa_scan_period' 
> thing that the user sets in ms.
> 
> So numa_scan_period is interpreted as both wallclock *and* as 
> runtime?
> 
> Maybe this works, but it doesn't really make much sense.

So, the relationship between wall clock time and execution 
runtime is that on the limit they run at the same speed: when 
there's a single task running. In any other case execution 
runtime can only run slower than wall time.

So the bit you found weird:

> > +               if (!time_before(jiffies, curr->mm->numa_next_scan)) {

together with the task_numa_work() frequency limit:

        /*
         * Enforce maximal scan/migration frequency..
         */
        migrate = mm->numa_next_scan;
        if (time_before(now, migrate))
                return;

        next_scan = now + 2*msecs_to_jiffies(sysctl_sched_numa_scan_period_min);
        if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
                return;

puts an upper limit on the per mm scanning frequency.

This filters us from over-sampling if there are many threads: if 
all threads happen to come in at the same time we don't create a 
spike in overhead.

We also avoid multiple threads scanning at once in parallel to 
each other. Faults are nicely parallel, especially with all the 
preparatory patches in place, so the distributed nature of the 
faults itself is not a problem.

So we have to conflicting goals here: on one hand we have a 
quality of sampling goal which asks for per task runtime 
proportional scanning on all threads, but we also have a 
performance goal and don't actually want all threads running at 
the same time. This frequency limit avoids the over-sampling 
scenario while still fulfilling the per task sampling property, 
statistically on average.

If you agree that we should do it like that and if the 
implementation is correct and optimal, I will put a better 
explanation into the code.

[
  task_numa_work() performance side note:

  We are also *very* close to be able to use down_read() instead
  of down_write() in the sampling-unmap code in 
  task_numa_work(), as it should be safe in theory to call 
  change_protection(PROT_NONE) in parallel - but there's one 
  regression that disagrees with this theory so we use 
  down_write() at the moment.

  Maybe you could help us there: can you see a reason why the
  change_prot_none()->change_protection() call in
  task_numa_work() can not occur in parallel to a page fault in
  another thread on another CPU? It should be safe - yet if we 
  change it I can see occasional corruption of user-space state: 
  segfaults and register corruption.
]

> [...] And what is the impact of this on machines that run lots 
> of loads with delays (whether due to IO or timers)?

I've done sysbench OLTP measurements which showed no apparent 
regressions:

 #
 # Comparing { res-schednuma-NO_NUMA.txt } to { res-schednuma-+NUMA.txt }:
 #
 #  threads     improvement %       SysBench OLTP transactions/second
 #-------------------------------------------------------------------
         2:            2.11 %              #    2160.20  vs.  2205.80
         4:           -5.52 %              #    4202.04  vs.  3969.97
         8:            0.01 %              #    6894.45  vs.  6895.45
        16:           -0.31 %              #   11840.77  vs. 11804.30
        24:           -0.56 %              #   15053.98  vs. 14969.14
        30:            0.56 %              #   17043.23  vs. 17138.21
        32:           -1.08 %              #   17797.04  vs. 17604.67
        34:            1.04 %              #   18158.10  vs. 18347.22
        36:           -0.16 %              #   18125.42  vs. 18096.68
        40:            0.45 %              #   18218.73  vs. 18300.59
        48:           -0.39 %              #   18266.91  vs. 18195.26
        56:           -0.11 %              #   18285.56  vs. 18265.74
        64:            0.23 %              #   18304.74  vs. 18347.51
        96:            0.18 %              #   18268.44  vs. 18302.04
       128:            0.22 %              #   18058.92  vs. 18099.34
       256:            1.63 %              #   17068.55  vs. 17347.14
       512:            6.86 %              #   13452.18  vs. 14375.08

No regression is the best we can hope for I think, given that 
OLTP typically has huge global caches and global serialization, 
so any NUMA conscious will at most be a nuisance.

We've also done kbuild measurements - which too is a pretty 
sleepy workload that is too fast for any migration techniques to 
help.

But even sysbench isn't doing very long delays, so I will do 
more IO delay targeted measurements.

So I've been actively looking for and checking the worst-case 
loads for this feature. The feature obviously helps long-run, 
CPU-intense workloads, but those aren't the challenging ones 
really IMO: I spent 70% of the time analyzing workloads that are 
not expected to be friends with this feature.

We are also keeping CONFIG_SCHED_NUMA off by default for good 
measure.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
