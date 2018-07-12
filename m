Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0410B6B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:27:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a22-v6so11597360eds.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:27:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u18-v6si1404030eda.251.2018.07.12.10.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:27:30 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/10] psi: pressure stall information for CPU, memory, and IO v2
Date: Thu, 12 Jul 2018 13:29:32 -0400
Message-Id: <20180712172942.10094-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

PSI aggregates and reports the overall wallclock time in which the
tasks in a system (or cgroup) wait for contended hardware resources.

This helps users understand the resource pressure their workloads are
under, which allows them to rootcause and fix throughput and latency
problems caused by overcommitting, underprovisioning, suboptimal job
placement in a grid, as well as anticipate major disruptions like OOM.

This version 2 of the series incorporates a ton of feedback from
PeterZ and SurenB; more details at the end of this email.

		Real-world applications

We're using the data collected by psi (and its previous incarnation,
memdelay) quite extensively at Facebook, with several success stories.

One usecase is avoiding OOM hangs/livelocks. The reason these happen
is because the OOM killer is triggered by reclaim not being able to
free pages, but with fast flash devices there is *always* some clean
and uptodate cache to reclaim; the OOM killer never kicks in, even as
tasks spend 90% of the time thrashing the cache pages of their own
executables. There is no situation where this ever makes sense in
practice. We wrote a <100 line POC python script to monitor memory
pressure and kill stuff way before such pathological thrashing leads
to full system losses that require forcible hard resets.

We've since extended and deployed this code into other places to
guarantee latency and throughput SLAs, since they're usually violated
way before the kernel OOM killer would ever kick in.

The idea is to eventually incorporate this back into the kernel, so
that Linux can avoid OOM livelocks (which TECHNICALLY aren't memory
deadlocks, but for the user indistinguishable) out of the box.

We also use psi memory pressure for loadshedding. Our batch job
infrastructure used to use heuristics based on various VM stats to
anticipate OOM situations, with lackluster success. We switched it to
psi and managed to anticipate and avoid OOM kills and hangs fairly
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

I've also recieved feedback and feature requests from Android for the
purpose of low-latency OOM killing. The on-demand stats aggregation in
the last patch of this series is for this purpose, to allow Android to
react to pressure before the system starts visibly hanging.

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
      proportion between load and the number of CPUs means for the
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
 include/linux/psi_types.h                       |  90 +++
 include/linux/sched.h                           |  10 +
 include/linux/sched/loadavg.h                   |  24 +-
 include/linux/sched/stat.h                      |  10 +-
 include/linux/swap.h                            |   2 +-
 include/trace/events/mmflags.h                  |   1 +
 include/uapi/linux/taskstats.h                  |   6 +-
 init/Kconfig                                    |  20 +
 kernel/cgroup/cgroup.c                          |  45 +-
 kernel/debug/kdb/kdb_main.c                     |   7 +-
 kernel/delayacct.c                              |  15 +
 kernel/fork.c                                   |   4 +
 kernel/sched/Makefile                           |   1 +
 kernel/sched/core.c                             |  11 +-
 kernel/sched/loadavg.c                          | 139 ++---
 kernel/sched/psi.c                              | 699 ++++++++++++++++++++++
 kernel/sched/sched.h                            | 178 +++---
 kernel/sched/stats.h                            | 102 +++-
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
 42 files changed, 1505 insertions(+), 256 deletions(-)

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
