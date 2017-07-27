Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5591D6B04A2
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:30:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so11825512wmg.3
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:30:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s1si12380610edj.531.2017.07.27.08.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 08:30:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/3] memdelay: memory health metric for systems and workloads
Date: Thu, 27 Jul 2017 11:30:07 -0400
Message-Id: <20170727153010.23347-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This patch series implements a fine-grained metric for memory
health. It builds on top of the refault detection code to quantify the
time lost on VM events that occur exclusively due a lack of memory and
maps it into a percentage of lost walltime for the system and cgroups.

Rationale

When presented with a Linux system or container executing a workload,
it's hard to judge the health of its memory situation.

The statistics exported by the memory management subsystem can reveal
smoking guns: page reclaim activity, major faults and refaults can be
indicative of an unhealthy memory situation. But they don't actually
quantify the cost a memory shortage imposes on the system or workload.

How bad is it when 2000 pages are refaulting each second? If the data
is stored contiguously on a fast flash drive, it might be okay. If the
data is spread out all over a rotating disk, it could be a problem -
unless the CPUs are still fully utilized, in which case adding memory
wouldn't make things move faster, but instead wait for CPU time.

A previous attempt to provide a health signal from the VM was the
vmpressure interface, 70ddf637eebe ("memcg: add memory.pressure_level
events"). This derives its pressure levels from recently observed
reclaim efficiency. As pages are scanned but not reclaimed, the ratio
is translated into levels of low, medium, and critical pressure.

However, the vmpressure scale is too coarse for today's systems. The
accuracy relies on storage being relatively slow compared to how fast
the CPU can go through the LRUs, so that when LRU scan cycles outstrip
IO completion rates the reclaim code runs into pages that are still
reading from disk. But as solid state devices close this speed gap,
and memory sizes are in the hundreds of gigabytes, this effect has
almost completely disappeared. By the time the reclaim scanner runs
into in-flight pages, the tasks in the system already spend a
significant part of their runtime waiting for refaulting pages. The
vmpressure range is compressed into the split second before OOM and
misses large, practically relevant parts of the pressure spectrum.

Knowing the exact time penalty that the kernel's paging activity is
imposing on a workload is a powerful tool. It allows users to finetune
a workload to available memory, but also detect and quantify minute
regressions and improvements in the reclaim and caching algorithms.

Structure

The first patch cleans up the different loadavg callsites and macros
as the memdelay averages are going to be tracked using these.

The second patch adds a distinction between page cache transitions
(inactive list refaults) and page cache thrashing (active list
refaults), since only the latter are unproductive refaults.

The third patch finally adds the memdelay accounting and interface:
its scheduler side identifies productive and unproductive task states,
and the VM side aggregates them into system and cgroup domain states
and calculates moving averages of the time spent in each state.

 arch/powerpc/platforms/cell/spufs/sched.c |   3 -
 arch/s390/appldata/appldata_os.c          |   4 -
 drivers/cpuidle/governors/menu.c          |   4 -
 fs/proc/array.c                           |   8 +
 fs/proc/base.c                            |   2 +
 fs/proc/internal.h                        |   2 +
 fs/proc/loadavg.c                         |   3 -
 include/linux/cgroup.h                    |  14 ++
 include/linux/memcontrol.h                |  14 ++
 include/linux/memdelay.h                  | 174 +++++++++++++++++
 include/linux/mmzone.h                    |   1 +
 include/linux/page-flags.h                |   5 +-
 include/linux/sched.h                     |  10 +-
 include/linux/sched/loadavg.h             |   3 +
 include/linux/swap.h                      |   2 +-
 include/trace/events/mmflags.h            |   1 +
 kernel/cgroup/cgroup.c                    |   4 +-
 kernel/debug/kdb/kdb_main.c               |   7 +-
 kernel/fork.c                             |   4 +
 kernel/sched/Makefile                     |   2 +-
 kernel/sched/core.c                       |  20 ++
 kernel/sched/memdelay.c                   | 112 +++++++++++
 mm/Makefile                               |   2 +-
 mm/compaction.c                           |   4 +
 mm/filemap.c                              |  18 +-
 mm/huge_memory.c                          |   1 +
 mm/memcontrol.c                           |  25 +++
 mm/memdelay.c                             | 289 ++++++++++++++++++++++++++++
 mm/migrate.c                              |   2 +
 mm/page_alloc.c                           |  11 +-
 mm/swap_state.c                           |   1 +
 mm/vmscan.c                               |  10 +
 mm/vmstat.c                               |   1 +
 mm/workingset.c                           |  98 ++++++----
 34 files changed, 792 insertions(+), 69 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
