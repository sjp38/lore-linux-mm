Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA3206B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 20:29:33 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s2-v6so5574494ioa.22
        for <linux-mm@kvack.org>; Fri, 25 May 2018 17:29:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f65-v6sor4227677itg.87.2018.05.25.17.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 17:29:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180507210135.1823-1-hannes@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 25 May 2018 17:29:30 -0700
Message-ID: <CAJuCfpF4q+1aSg4WQn_p-1-zEDhh-iqST6dc1DkxnDofSPBKGw@mail.gmail.com>
Subject: Re: [PATCH 0/7] psi: pressure stall information for CPU, memory, and IO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

Hi Johannes,
I tried your previous memdelay patches before this new set was posted
and results were promising for predicting when Android system is close
to OOM. I'm definitely going to try this one after I backport it to
4.9.

On Mon, May 7, 2018 at 2:01 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi,
>
> I previously submitted a version of this patch set called "memdelay",
> which translated delays from reclaim, swap-in, thrashing page cache
> into a pressure percentage of lost walltime. I've since extended this
> code to aggregate all delay states tracked by delayacct in order to
> have generalized pressure/overcommit levels for CPU, memory, and IO.
>
> There was feedback from Peter on the previous version that I have
> incorporated as much as possible and as it still applies to this code:
>
>         - got rid of the extra lock in the sched callbacks; all task
>           state changes we care about serialize through rq->lock
>
>         - got rid of ktime_get() inside the sched callbacks and
>           switched time measuring to rq_clock()
>
>         - got rid of all divisions inside the sched callbacks,
>           tracking everything natively in ns now
>
> I also moved this stuff into existing sched/stat.h callbacks, so it
> doesn't get in the way in sched/core.c, and of course moved the whole
> thing behind CONFIG_PSI since not everyone is going to want it.

Would it make sense to split CONFIG_PSI into CONFIG_PSI_CPU,
CONFIG_PSI_MEM and CONFIG_PSI_IO since one might need only specific
subset of this feature?

>
> Real-world applications
>
> Since the last posting, we've begun using the data collected by this
> code quite extensively at Facebook, and with several success stories.
>
> First we used it on systems that frequently locked up in low memory
> situations. The reason this happens is that the OOM killer is
> triggered by reclaim not being able to make forward progress, but with
> fast flash devices there is *always* some clean and uptodate cache to
> reclaim; the OOM killer never kicks in, even as tasks wait 80-90% of
> the time faulting executables. There is no situation where this ever
> makes sense in practice. We wrote a <100 line POC python script to
> monitor memory pressure and kill stuff manually, way before such
> pathological thrashing.
>
> We've since extended the python script into a more generic oomd that
> we use all over the place, not just to avoid livelocks but also to
> guarantee latency and throughput SLAs, since they're usually violated
> way before the kernel OOM killer would ever kick in.
>
> We also use the memory pressure info for loadshedding. Our batch job
> infrastructure used to refuse new requests on heuristics based on RSS
> and other existing VM metrics in an attempt to avoid OOM kills and
> maximize utilization. Since it was still plagued by frequent OOM
> kills, we switched it to shed load on psi memory pressure, which has
> turned out to be a much better bellwether, and we managed to reduce
> OOM kills drastically. Reducing the rate of OOM outages from the
> worker pool raised its aggregate productivity, and we were able to
> switch that service to smaller machines.
>
> Lastly, we use cgroups to isolate a machine's main workload from
> maintenance crap like package upgrades, logging, configuration, as
> well as to prevent multiple workloads on a machine from stepping on
> each others' toes. We were not able to do this properly without the
> pressure metrics; we would see latency or bandwidth drops, but it
> would often be hard to impossible to rootcause it post-mortem. We now
> log and graph the pressure metrics for all containers in our fleet and
> can trivially link service drops to resource pressure after the fact.
>
> How do you use this?
>
> A kernel with CONFIG_PSI=y will create a /proc/pressure directory with
> 3 files: cpu, memory, and io. If using cgroup2, cgroups will also have
> cpu.pressure, memory.pressure and io.pressure files, which simply
> calculate pressure at the cgroup level instead of system-wide.
>
> The cpu file contains one line:
>
>         some avg10=2.04 avg60=0.75 avg300=0.40 total=157656722
>
> The averages give the percentage of walltime in which some tasks are
> delayed on the runqueue while another task has the CPU. They're recent
> averages over 10s, 1m, 5m windows, so you can tell short term trends
> from long term ones, similarly to the load average.
>
> What to make of this number? If CPU utilization is at 100% and CPU
> pressure is 0, it means the system is perfectly utilized, with one
> runnable thread per CPU and nobody waiting. At two or more runnable
> tasks per CPU, the system is 100% overcommitted and the pressure
> average will indicate as much. From a utilization perspective this is
> a great state of course: no CPU cycles are being wasted, even when 50%
> of the threads were to go idle (and most workloads do vary). From the
> perspective of the individual job it's not great, however, and they
> might do better with more resources. Depending on what your priority
> is, an elevated "some" number may or may not require action.
>
> The memory file contains two lines:
>
> some avg10=70.24 avg60=68.52 avg300=69.91 total=3559632828
> full avg10=57.59 avg60=58.06 avg300=60.38 total=3300487258
>
> The some line is the same as for cpu: the time in which at least one
> task is stalled on the resource.
>
> The full line, however, indicates time in which *nobody* is using the
> CPU productively due to pressure: all non-idle tasks could be waiting
> on thrashing cache simultaneously. It can also happen when a single
> reclaimer occupies the CPU, since nothing else can make forward
> progress during that time. CPU cycles are being wasted. Significant
> time spent in there is a good trigger for killing, moving jobs to
> other machines, or dropping incoming requests, since neither the jobs
> nor the machine overall is making too much headway.
>
> The total= value gives the absolute stall time in microseconds. This
> allows detecting latency spikes that might be too short to sway the
> running averages. It also allows custom time averaging in case the
> 10s/1m/5m windows aren't adequate for the usecase (or are too coarse
> with future hardware).
>

Any reasons these specific windows were chosen (empirical
data/historical reasons)? I'm worried that with the smallest window
being 10s the signal might be too inert to detect fast memory pressure
buildup before OOM kill happens. I'll have to experiment with that
first, however if you have some insights into this already please
share them.

> The io file is similar to memory. However, unlike CPU and memory, the
> block layer doesn't have a concept of hardware contention. We cannot
> know if the IO a task is waiting on is being performed by the device
> or whether the device is busy with or slowed down other requests. As a
> result, we can tell how many CPU cycles go to waste due to IO delays,
> but we can not identify the competition factor in those delays.
>
> These patches are against v4.17-rc4.
>
>  Documentation/accounting/psi.txt                |  73 ++++
>  Documentation/cgroup-v2.txt                     |  18 +
>  arch/powerpc/platforms/cell/cpufreq_spudemand.c |   2 +-
>  arch/powerpc/platforms/cell/spufs/sched.c       |   9 +-
>  arch/s390/appldata/appldata_os.c                |   4 -
>  drivers/cpuidle/governors/menu.c                |   4 -
>  fs/proc/loadavg.c                               |   3 -
>  include/linux/cgroup-defs.h                     |   4 +
>  include/linux/cgroup.h                          |  15 +
>  include/linux/delayacct.h                       |  23 +
>  include/linux/mmzone.h                          |   1 +
>  include/linux/page-flags.h                      |   5 +-
>  include/linux/psi.h                             |  52 +++
>  include/linux/psi_types.h                       |  84 ++++
>  include/linux/sched.h                           |  10 +
>  include/linux/sched/loadavg.h                   |  90 +++-
>  include/linux/sched/stat.h                      |  10 +-
>  include/linux/swap.h                            |   2 +-
>  include/trace/events/mmflags.h                  |   1 +
>  include/uapi/linux/taskstats.h                  |   6 +-
>  init/Kconfig                                    |  20 +
>  kernel/cgroup/cgroup.c                          |  45 +-
>  kernel/debug/kdb/kdb_main.c                     |   7 +-
>  kernel/delayacct.c                              |  15 +
>  kernel/fork.c                                   |   4 +
>  kernel/sched/Makefile                           |   1 +
>  kernel/sched/core.c                             |   3 +
>  kernel/sched/loadavg.c                          |  84 ----
>  kernel/sched/psi.c                              | 499 ++++++++++++++++++++++
>  kernel/sched/sched.h                            | 166 +++----
>  kernel/sched/stats.h                            |  91 +++-
>  mm/compaction.c                                 |   5 +
>  mm/filemap.c                                    |  27 +-
>  mm/huge_memory.c                                |   1 +
>  mm/memcontrol.c                                 |   2 +
>  mm/migrate.c                                    |   2 +
>  mm/page_alloc.c                                 |  10 +
>  mm/swap_state.c                                 |   1 +
>  mm/vmscan.c                                     |  14 +
>  mm/vmstat.c                                     |   1 +
>  mm/workingset.c                                 | 113 +++--
>  tools/accounting/getdelays.c                    |   8 +-
>  42 files changed, 1279 insertions(+), 256 deletions(-)
>
>
>
>

Thanks,
Suren.
