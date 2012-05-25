Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 34C8B94000A
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:36 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/35] AutoNUMA alpha14
Date: Fri, 25 May 2012 19:02:04 +0200
Message-Id: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Hello everyone,

It's time for a new autonuma-alpha14 milestone.

Removed the [RFC] from Subject because 1) this is a release I'm quite
happy with (from the implementation side it allows the same kernel
image to boot optimally on NUMA and not-NUMA hardware and it avoids
altering the scheduler runtime most of the time) and 2) because of the
great benchmark results we got so far, showing this design so far has
been proved to perform best.

I believe (realistically speaking) nobody is going to change
applications to specify which thread is using which memory (for
threaded apps) with the only exception of QEMU and a few others.

For not threaded apps that fits in a NUMA node, there's no way a blind
home node can perform nearly as good as AutoNUMA: AutoNUMA monitor the
whole status of the memory of the running processes and it optimizes
the memory placement and CPU placement dynamically
accordingly. There's a small memory and CPU cost in collecting so much
information to be able to make smart decisions, but the benefits
largely outweight those costs.

If a big idle task was idle for a long while, but it suddenly start
computing, AutoNUMA may totally change the memory and CPU placement of
the other running tasks according to what's best, because it has
enough information to take optimal NUMA placement decisions.

git clone --reference linux -b autonuma-alpha14 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git autonuma-alpha14

Development autonuma branch (currently equal to autonuma-alpha14 ==
a49fedcc284a8e8b47175fbc23e9d3b075884e53):

git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
to update: git fetch; git checkout -f origin/autonuma

Changelog from alpha13 to alpha14:

o page_autonuma introduction, no memory wasted if the kernel is booted
  on not-NUMA hardware. Tested with flatmem/sparsemem on x86
  autonuma=y/n and sparsemem/vsparsemem on x86_64 with autonuma=y/n.

  The "noautonuma" kernel param disables autonuma permanently also
  when booted on NUMA hardware (no /sys/kernel/mm/autonuma, and no
  page_autonuma allocations, like cgroup_disable=memory)

o autonuma_balance only runs along with run_rebalance_domains, to
  avoid altering the scheduler runtime. autonuma_balance gives a
  "kick" to the scheduler only along the load balance events (it
  overrides the load balance activity if needed). This change has not
  yet been tested on specjbb or more schedule intensive benchmarks,
  but I don't expect measurable NUMA affinity regressions. For
  intensive compute loads not involving a flood of scheduling activity
  this has already been verified not to show any performance
  regression, and it will boost the scheduler performance compared to
  previous autonuma releases.

  Note: autonuma_balance still runs from normal context (not softirq
  context like run_rebalance_domains) to be able to wait on process
  migration (avoid _nowait), but most of the time it does nothing at
  all.

Changelog from alpha11 to alpha13:

o autonuma_balance optimization (take the fast path when process is in
  the preferred NUMA node)

TODO:

o THP native migration (orthogonal and also needed for
  cpuset/migrate_pages(2)/numa/sched).

o distribute pagecache to other nodes (and maybe shared memory or
  other movable memory) if knuma_migrated stops because the local node
  is full

Andrea Arcangeli (35):
  mm: add unlikely to the mm allocation failure check
  autonuma: make set_pmd_at always available
  xen: document Xen is using an unused bit for the pagetables
  autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
  autonuma: x86 pte_numa() and pmd_numa()
  autonuma: generic pte_numa() and pmd_numa()
  autonuma: teach gup_fast about pte_numa
  autonuma: introduce kthread_bind_node()
  autonuma: mm_autonuma and sched_autonuma data structures
  autonuma: define the autonuma flags
  autonuma: core autonuma.h header
  autonuma: CPU follow memory algorithm
  autonuma: add page structure fields
  autonuma: knuma_migrated per NUMA node queues
  autonuma: init knuma_migrated queues
  autonuma: autonuma_enter/exit
  autonuma: call autonuma_setup_new_exec()
  autonuma: alloc/free/init sched_autonuma
  autonuma: alloc/free/init mm_autonuma
  autonuma: avoid CFS select_task_rq_fair to return -1
  autonuma: teach CFS about autonuma affinity
  autonuma: sched_set_autonuma_need_balance
  autonuma: core
  autonuma: follow_page check for pte_numa/pmd_numa
  autonuma: default mempolicy follow AutoNUMA
  autonuma: call autonuma_split_huge_page()
  autonuma: make khugepaged pte_numa aware
  autonuma: retain page last_nid information in khugepaged
  autonuma: numa hinting page faults entry points
  autonuma: reset autonuma page data when pages are freed
  autonuma: initialize page structure fields
  autonuma: link mm/autonuma.o and kernel/sched/numa.o
  autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
  autonuma: boost khugepaged scanning rate
  autonuma: page_autonuma

 arch/x86/include/asm/paravirt.h      |    2 -
 arch/x86/include/asm/pgtable.h       |   51 ++-
 arch/x86/include/asm/pgtable_types.h |   22 +-
 arch/x86/mm/gup.c                    |    2 +-
 fs/exec.c                            |    3 +
 include/asm-generic/pgtable.h        |   12 +
 include/linux/autonuma.h             |   53 ++
 include/linux/autonuma_flags.h       |   68 ++
 include/linux/autonuma_sched.h       |   50 ++
 include/linux/autonuma_types.h       |   88 ++
 include/linux/huge_mm.h              |    2 +
 include/linux/kthread.h              |    1 +
 include/linux/mm_types.h             |    5 +
 include/linux/mmzone.h               |   18 +
 include/linux/page_autonuma.h        |   53 ++
 include/linux/sched.h                |    3 +
 init/main.c                          |    2 +
 kernel/fork.c                        |   36 +-
 kernel/kthread.c                     |   23 +
 kernel/sched/Makefile                |    1 +
 kernel/sched/core.c                  |   12 +-
 kernel/sched/fair.c                  |   72 ++-
 kernel/sched/numa.c                  |  281 +++++++
 kernel/sched/sched.h                 |   10 +
 mm/Kconfig                           |   13 +
 mm/Makefile                          |    1 +
 mm/autonuma.c                        | 1464 ++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                     |   58 ++-
 mm/memory.c                          |   36 +-
 mm/mempolicy.c                       |   15 +-
 mm/mmu_context.c                     |    2 +
 mm/page_alloc.c                      |    6 +-
 mm/page_autonuma.c                   |  234 ++++++
 mm/sparse.c                          |  126 +++-
 34 files changed, 2776 insertions(+), 49 deletions(-)
 create mode 100644 include/linux/autonuma.h
 create mode 100644 include/linux/autonuma_flags.h
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 include/linux/autonuma_types.h
 create mode 100644 include/linux/page_autonuma.h
 create mode 100644 kernel/sched/numa.c
 create mode 100644 mm/autonuma.c
 create mode 100644 mm/page_autonuma.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
