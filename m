Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9E71E6B0062
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:38 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4763716eek.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:37 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [GIT TREE] Unified NUMA balancing tree, v3
Date: Fri,  7 Dec 2012 01:19:17 +0100
Message-Id: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

I'm pleased to announce the -v3 version of the unified NUMA tree,
which can be accessed at the following Git address:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

[ To test this tree, just pick up the Git tree and enable
  CONFIG_NUMA_BALANCING=y. On an at least 2 node NUMA system
  you should see speedups in many types of long-running,
  memory-intense user-space workloads with this feature enabled.
  Or a slowdown if the plan does not work out. Please report
  both cases. ]

The focus of the -v3 release is regression fixes. Half of the
regression fixed were related to the unification, half of them
were due prior bugs.

Main changes since -v2:

  - Implement last-CPU+PID hash tracking
  - Improve staggered convergence
  - Improve directed convergence
  - Fix !THP, 4K-pte "2M-emu" NUMA fault handling

In particular the new CPU+PID hashing code works very well, and
I'd be curious whether others can confirm that they are seeing
speedups as well.

Some performance figures. Here's the comparison to mainline:

 ##############
 # res-v3.6-vanilla.log vs res-numaunified-v3.log:
 #------------------------------------------------------------------------------------>
   autonuma benchmark                run time (lower is better)         speedup %
 ------------------------------------------------------------------------------------->
   numa01                           :   337.29  vs.  195.47   |           +72.5 %
   numa01_THREAD_ALLOC              :   428.79  vs.  119.97   |          +257.4 %
   numa02                           :    56.32  vs.   16.82   |          +234.8 %
   numa02_SMT                       :    56.55  vs.   16.98   |          +233.0 %
   ------------------------------------------------------------

Still much better, all around.

Comparison to the -v17, the last non-regressing pre-unification
tree:

 ##############
 # res-numacore-v18b.log vs res-numaunified-v3.log:
 #------------------------------------------------------------------------------------>
   autonuma benchmark                run time (lower is better)         speedup %
 ------------------------------------------------------------------------------------->
   numa01                           :   177.64  vs.  195.47   |            -9.1 %
   numa01_THREAD_ALLOC              :   127.07  vs.  119.97   |            +5.9 %
   numa02                           :    18.08  vs.   16.82   |            +7.4 %
   numa02_SMT                       :    36.97  vs.   16.98   |          +117.7 %
   ------------------------------------------------------------

[ Note: the 'numa01' result is a bit slower, due to us not
  taking node distances into account on larger than 2-node
  systems, and this run spreading the tasks in a A-B-A-B
  suboptimal order, instead of A-A-B-B. There's a 50% chance for
  that outcome and this run got the worse convergence layout.

  That behavior due to node assymetry will be improved in future
  versions. Note that even in the less ideal layout it's faster
  than mainline. ]

- The twice as fast numa02_SMT result is a regression fix.

- 'numa02' and 'numa01_THREAD_ALLOC' got genuinely faster - and
  that's good news because those are our prime target 'good'
  NUMA workloads.

The SPECjbb 4x JVM numbers are still very close to the
hard-binding results:

  Fri Dec  7 02:08:42 CET 2012
  spec1.txt:           throughput =     188667.94 SPECjbb2005 bops
  spec2.txt:           throughput =     190109.31 SPECjbb2005 bops
  spec3.txt:           throughput =     191438.13 SPECjbb2005 bops
  spec4.txt:           throughput =     192508.34 SPECjbb2005 bops
                                      --------------------------
        SUM:           throughput =     762723.72 SPECjbb2005 bops

And the same is true for !THP as well.

( In case you have sent a regression report please re-test this
  version - I'll try to work down some of my email backlog and
  reply to any mails I have not replied to yet. )

Reports, fixes, suggestions are welcome, as always!

Thanks,

	Ingo

------------------------------------------------->
Ingo Molnar (9):
  numa, sched: Fix NUMA tick ->numa_shared setting
  numa, sched: Add tracking of runnable NUMA tasks
  numa, sched: Implement wake-cpu migration support
  numa, mm, sched: Implement last-CPU+PID hash tracking
  numa, mm, sched: Fix NUMA affinity tracking logic
  numa, mm: Fix !THP, 4K-pte "2M-emu" NUMA fault handling
  numa, sched: Improve staggered convergence
  numa, sched: Improve directed convergence
  numa, sched: Streamline and fix numa_allow_migration() use

 include/linux/init_task.h         |   4 +-
 include/linux/mempolicy.h         |   4 +-
 include/linux/mm.h                |  79 +++++---
 include/linux/mm_types.h          |   4 +-
 include/linux/page-flags-layout.h |  23 ++-
 include/linux/sched.h             |   9 +-
 kernel/sched/core.c               |  29 ++-
 kernel/sched/fair.c               | 370 +++++++++++++++++++++++++++-----------
 kernel/sched/features.h           |   2 +
 kernel/sched/sched.h              |   4 +
 kernel/sysctl.c                   |   8 +
 mm/huge_memory.c                  |  25 +--
 mm/memory.c                       | 175 +++++++++++++-----
 mm/mempolicy.c                    |  50 ++++--
 mm/migrate.c                      |   4 +-
 mm/mprotect.c                     |   4 +-
 mm/page_alloc.c                   |   6 +-
 17 files changed, 574 insertions(+), 226 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
