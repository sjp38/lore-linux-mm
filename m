Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3D36B0274
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:17:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x204-v6so17082745qka.6
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:17:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p14-v6sor8271766qki.17.2018.08.01.08.17.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 08:17:14 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/9] psi: pressure stall information for CPU, memory, and IO v3
Date: Wed,  1 Aug 2018 11:19:49 -0400
Message-Id: <20180801151958.32590-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

[ Resend after butchering the message headers in the first attempt, sorry ]

This is version 3 of the PSI series. It incorporates again a ton of
feedback from Peter; more details at the very bottom of this email.

I've added benchmark results from the v2 thread in the FAQ below. I
also re-ran the memcache test that showed a 1% CPU utilization
increase with v2, but with v3 that difference is no longer detectable.

		Overview

PSI reports the overall wallclock time in which the tasks in a system
(or cgroup) wait for (contended) hardware resources.

This helps users understand the resource pressure their workloads are
under, which allows them to rootcause and fix throughput and latency
problems caused by overcommitting, underprovisioning, suboptimal job
placement in a grid; as well as anticipate major disruptions like OOM.

		Real-world applications

We're using the data collected by PSI (and its previous incarnation,
memdelay) quite extensively at Facebook, and with several success
stories.

One usecase is avoiding OOM hangs/livelocks. The reason these happen
is because the OOM killer is triggered by reclaim not being able to
free pages, but with fast flash devices there is *always* some clean
and uptodate cache to reclaim; the OOM killer never kicks in, even as
tasks spend 90% of the time thrashing the cache pages of their own
executables. There is no situation where this ever makes sense in
practice. We wrote a <100 line POC python script to monitor memory
pressure and kill stuff way before such pathological thrashing leads
to full system losses that would require forcible hard resets.

We've since extended and deployed this code into other places to
guarantee latency and throughput SLAs, since they're usually violated
way before the kernel OOM killer would ever kick in.

It is available here: https://github.com/facebookincubator/oomd

Eventually we probably want to trigger the in-kernel OOM killer based
on extreme sustained pressure as well, so that Linux can avoid memory
livelocks - which technically aren't deadlocks, but to the user
indistinguishable from them - out of the box. We'd continue using OOMD
as the first line of defense to ensure workload health and implement
complex kill policies that are beyond the scope of the kernel.

We also use PSI memory pressure for loadshedding. Our batch job
infrastructure used to use heuristics based on various VM stats to
anticipate OOM situations, with lackluster success. We switched it to
PSI and managed to anticipate and avoid OOM kills and lockups fairly
reliably. The reduction of OOM outages in the worker pool raised the
pool's aggregate productivity, and we were able to switch that service
to smaller machines.

Lastly, we use cgroups to isolate a machine's main workload from
maintenance crap like package upgrades, logging, configuration, as
well as to prevent multiple workloads on a machine from stepping on
each others' toes. We were not able to configure this properly without
the pressure metrics; we would see latency or bandwidth drops, but it
would often be hard to impossible to rootcause it post-mortem.

We now log and graph pressure for the containers in our fleet and can
trivially link latency spikes and throughput drops to shortages of
specific resources after the fact, and fix the job config/scheduling.

PSI has also received testing, feedback, and feature requests from
Android and EndlessOS for the purpose of low-latency OOM killing, to
intervene in pressure situations before the UI starts hanging.

		How do you use this feature?

A kernel with CONFIG_PSI=y will create a /proc/pressure directory with
3 files: cpu, memory, and io. If using cgroup2, cgroups will also have
cpu.pressure, memory.pressure and io.pressure files, which simply
aggregate task stalls at the cgroup level instead of system-wide.

The cpu file contains one line:

	some avg10=2.04 avg60=0.75 avg300=0.40 total=157656722

The averages give the percentage of walltime in which one or more
tasks are delayed on the runqueue while another task has the
CPU. They're recent averages over 10s, 1m, 5m windows, so you can tell
short term trends from long term ones, similarly to the load average.

The total= value gives the absolute stall time in microseconds. This
allows detecting latency spikes that might be too short to sway the
running averages. It also allows custom time averaging in case the
10s/1m/5m windows aren't adequate for the usecase (or are too coarse
with future hardware).

What to make of this "some" metric? If CPU utilization is at 100% and
CPU pressure is 0, it means the system is perfectly utilized, with one
runnable thread per CPU and nobody waiting. At two or more runnable
tasks per CPU, the system is 100% overcommitted and the pressure
average will indicate as much. From a utilization perspective this is
a great state of course: no CPU cycles are being wasted, even when 50%
of the threads were to go idle (as most workloads do vary). From the
perspective of the individual job it's not great, however, and they
would do better with more resources. Depending on what your priority
and options are, raised "some" numbers may or may not require action.

The memory file contains two lines:

some avg10=70.24 avg60=68.52 avg300=69.91 total=3559632828
full avg10=57.59 avg60=58.06 avg300=60.38 total=3300487258

The some line is the same as for cpu, the time in which at least one
task is stalled on the resource. In the case of memory, this includes
waiting on swap-in, page cache refaults and page reclaim.

The full line, however, indicates time in which *nobody* is using the
CPU productively due to pressure: all non-idle tasks are waiting for
memory in one form or another. Significant time spent in there is a
good trigger for killing things, moving jobs to other machines, or
dropping incoming requests, since neither the jobs nor the machine
overall are making too much headway.

The io file is similar to memory. Because the block layer doesn't have
a concept of hardware contention right now (how much longer is my IO
request taking due to other tasks?), it reports CPU potential lost on
all IO delays, not just the potential lost due to competition.

		FAQ

Q: How is PSI's CPU component different from the load average?

A: There are several quirks in the load average that make it hard to
   impossible to tell how overcommitted the CPU really is.

   1. The load average is reported as a raw number of active tasks.
      You need to know how many CPUs there are in the system, how many
      CPUs the workload is allowed to use, then think about what the
      proportion between load and the number of CPUs mean for the
      tasks trying to run.

      PSI reports the percentage of wallclock time in which tasks are
      waiting for a CPU to run on. It doesn't matter how many CPUs are
      present or usable. The number always tells the quality of life
      of tasks in the system or in a particular cgroup.

   2. The shortest averaging window is 1m, which is extremely coarse,
      and it's sampled in 5s intervals. A *lot* can happen on a CPU in
      5 seconds. This *may* be able to identify persistent long-term
      trends and very clear and obvious overloads, but it's unusable
      for latency spikes and more subtle overutilization.

      PSI's shortest window is 10s. It also exports the cumulative
      stall times (in microseconds) of synchronously recorded events.

   3. On Linux, the load average for historical reasons includes all
      TASK_UNINTERRUPTIBLE tasks. This gives a broader sense of how
      busy the system is, but on the flipside it doesn't distinguish
      whether tasks are likely to contend over the CPU or IO - which
      obviously requires very different interventions from a sys admin
      or a job scheduler.

      PSI reports independent metrics for CPU and IO. You can tell
      which resource is making the tasks wait, but in conjunction
      still see how overloaded the system is overall.

Q: What's the cost / performance impact of this feature?

A: PSI's primary cost is in the scheduler, in particular task wakeups
   and sleeps.

   I benchmarked this code using Facebook's two most scheduling
   sensitive workloads: memcache and webserver. They handle a ton of
   small requests - lots of wakeups and sleeps with little actual work
   in between - so they tend to be canaries for scheduler regressions.

   In the tests, the boxes were handling live traffic over the course
   of several hours. Half the machines, the control, ran with
   CONFIG_PSI=n.

   For memcache I used eight machines total. They're 2-socket, 14
   core, 56 thread boxes. The test runs for half the test period,
   flips the test and control kernels on the hardware to rule out HW
   factors, DC location etc., then runs the other half of the test.

   For the webservers, I used 32 machines total. They're single
   socket, 16 core, 32 thread machines.

   During the memcache test, CPU load was nopsi=78.05% psi=78.98% in
   the first half and nopsi=77.52% psi=78.25%, so PSI added between
   0.7 and 0.9 percentage points to the CPU load, a difference of
   about 1%.

   UPDATE: I re-ran this test with the v3 version of this patch set
   and the CPU utilization was equivalent between test and control.

   As far as end-to-end request latency from the client perspective
   goes, we don't sample those finely enough to capture the requests
   going to those particular machines during the test, but we know the
   p50 turnaround time in this workload is 54us, and perf bench sched
   pipe on those machines show nopsi=5.232666 us/op and psi=5.587347
   us/op, so this doesn't add much here either.

   The profile for the pipe benchmark shows:

        0.87%  sched-pipe  [kernel.vmlinux]    [k] psi_group_change
        0.83%  perf.real   [kernel.vmlinux]    [k] psi_group_change
        0.82%  perf.real   [kernel.vmlinux]    [k] psi_task_change
        0.58%  sched-pipe  [kernel.vmlinux]    [k] psi_task_change


   The webserver load is running inside 4 nested cgroup levels. The
   CPU load with both nopsi and psi kernels was indistinguishable at
   81%.

   For comparison, we had to disable the cgroup cpu controller on the
   webservers because it added 4 percentage points to the CPU% during
   this same exact test.

   Versions of this accounting code now run on 80% of our fleet. None
   of our workloads have reported regressions during the rollout.

These patches are against v4.17. They're maintained against upstream
here as well: http://git.cmpxchg.org/cgit.cgi/linux-psi.git

 Documentation/accounting/psi.txt                |  73 +++
 Documentation/cgroup-v2.txt                     |  18 +
 arch/powerpc/platforms/cell/cpufreq_spudemand.c |   2 +-
 arch/powerpc/platforms/cell/spufs/sched.c       |   9 +-
 arch/s390/appldata/appldata_os.c                |   4 -
 drivers/cpuidle/governors/menu.c                |   4 -
 fs/proc/loadavg.c                               |   3 -
 include/linux/cgroup-defs.h                     |   4 +
 include/linux/cgroup.h                          |  15 +
 include/linux/delayacct.h                       |  23 +
 include/linux/mmzone.h                          |   1 +
 include/linux/page-flags.h                      |   5 +-
 include/linux/psi.h                             |  52 ++
 include/linux/psi_types.h                       |  87 +++
 include/linux/sched.h                           |  10 +
 include/linux/sched/loadavg.h                   |  24 +-
 include/linux/swap.h                            |   2 +-
 include/trace/events/mmflags.h                  |   1 +
 include/uapi/linux/taskstats.h                  |   6 +-
 init/Kconfig                                    |  19 +
 kernel/cgroup/cgroup.c                          |  45 +-
 kernel/debug/kdb/kdb_main.c                     |   7 +-
 kernel/delayacct.c                              |  15 +
 kernel/fork.c                                   |   4 +
 kernel/sched/Makefile                           |   1 +
 kernel/sched/core.c                             |  15 +-
 kernel/sched/loadavg.c                          | 139 ++---
 kernel/sched/psi.c                              | 720 ++++++++++++++++++++++
 kernel/sched/sched.h                            | 178 +++---
 kernel/sched/stats.h                            |  80 +++
 mm/compaction.c                                 |   5 +
 mm/filemap.c                                    |  27 +-
 mm/huge_memory.c                                |   1 +
 mm/memcontrol.c                                 |   2 +
 mm/migrate.c                                    |   2 +
 mm/page_alloc.c                                 |  10 +
 mm/swap_state.c                                 |   1 +
 mm/vmscan.c                                     |  14 +
 mm/vmstat.c                                     |   1 +
 mm/workingset.c                                 | 113 ++--
 tools/accounting/getdelays.c                    |   8 +-
 41 files changed, 1503 insertions(+), 247 deletions(-)

Changes in v2:
- Extensive documentation and comment update. Per everybody.
  In particular, I've added a much more detailed explanation
  of the SMP model, which caused some misunderstandings last time.
- Uninlined calc_load_n(), as it was just too fat. Per Peter.
- Split kernel/sched/stats.h churn into its own commit to
  avoid noise in the main patch and explain the reshuffle. Per Peter.
- Abstracted this_rq_lock_irq(). Per Peter.
- Eliminated cumulative clock drift error. Per Peter.
- Packed the per-cpu datastructure. Per Peter.
- Fixed 64-bit divisions on 32 bit. Per Peter.
- Added outer-most psi_disabled checks. Per Peter.
- Fixed some coding style issues. Per Peter.
- Fixed a bug in the lazy clock. Per Suren.
- On-demand stat aggregation when user reads. Per Suren.
- Fixed task state corruption on preemption race. Per Suren.
- Fixed a CONFIG_PSI=n build error.
- Minor cleanups, optimizations.

Changes in v3:
- Packed scheduler hotpath data into one cacheline, as per Peter and Linus
- Implemented live state aggregation without the rq lock, as per Peter
- do_div -> div64_ul and some other cleanups, as per Peter
- Dropped unnecessary SCHED_INFO dependency, as per Peter
- Realtime sampling period and slipped sample handling, as per Tejun
- Fixed 64-bit divsion on 32 bit & checkpatch warnings, as per Andrew
