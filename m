Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 21A4C6B00A8
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:43 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/40] AutoNUMA19
Date: Thu, 28 Jun 2012 14:55:40 +0200
Message-Id: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hello everyone,

It's time for a new AutoNUMA19 release.

The objective of AutoNUMA is to be able to perform as close as
possible to (and sometime faster than) the NUMA hard CPU/memory
bindings setups, without requiring the administrator to manually setup
any NUMA hard bind.

https://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120530.pdf
(NOTE: the TODO slide is obsolete)

git clone --reference linux -b autonuma19 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git autonuma19

Development autonuma branch:

git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

To update:

git fetch
git checkout -f origin/autonuma

Changelog from AutoNUMA-alpha14 to AutoNUMA19:

o sched_autonuma_balance callout location removed from schedule() now it runs
  in the softirq along with CFS load_balancing

o lots of documentation about the math in the sched_autonuma_balance algorithm

o fixed a bug in the fast path detection in sched_autonuma_balance that could
  decrease performance with many nodes

o reduced the page_autonuma memory overhead to from 32 to 12 bytes per page

o fixed a crash in __pmd_numa_fixup

o knuma_numad won't scan VM_MIXEDMAP|PFNMAP (it never touched those ptes
  anyway)

o fixed a crash in autonuma_exit

o fixed a crash when split_huge_page returns 0 in knuma_migratedN as the page
  has been freed already

o assorted cleanups and probably more

Changelog from alpha13 to alpha14:

o page_autonuma introduction, no memory wasted if the kernel is booted
  on not-NUMA hardware. Tested with flatmem/sparsemem on x86
  autonuma=y/n and sparsemem/vsparsemem on x86_64 with autonuma=y/n.
  "noautonuma" kernel param disables autonuma permanently also when
  booted on NUMA hardware (no /sys/kernel/mm/autonuma, and no
  page_autonuma allocations, like cgroup_disable=memory)

o autonuma_balance only runs along with run_rebalance_domains, to
  avoid altering the usual scheduler runtime. autonuma_balance gives a
  "kick" to the scheduler after a rebalance (it overrides the load
  balance activity if needed). It's not yet tested on specjbb or more
  schedule intensive benchmark, hopefully there's no NUMA
  regression. For intensive compute loads not involving a flood of
  scheduling activity this doesn't show any performance regression,
  and it avoids altering the strict schedule performance. It goes in
  the direction of being less intrusive with the stock scheduler
  runtime.

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

o port to ppc64, Ben? Any arch able to support PROT_NONE can also support
  AutoNUMA, in short all archs should work fine with AutoNUMA.

Andrea Arcangeli (40):
  mm: add unlikely to the mm allocation failure check
  autonuma: make set_pmd_at always available
  autonuma: export is_vma_temporary_stack() even if
    CONFIG_TRANSPARENT_HUGEPAGE=n
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
  autonuma: page_autonuma change #include for sparse
  autonuma: autonuma_migrate_head[0] dynamic size
  autonuma: bugcheck page_autonuma fields on newly allocated pages
  autonuma: shrink the per-page page_autonuma struct size

 arch/x86/include/asm/paravirt.h      |    2 -
 arch/x86/include/asm/pgtable.h       |   51 ++-
 arch/x86/include/asm/pgtable_types.h |   22 +-
 arch/x86/mm/gup.c                    |    2 +-
 arch/x86/mm/numa.c                   |    6 +-
 arch/x86/mm/numa_32.c                |    3 +-
 fs/exec.c                            |    3 +
 include/asm-generic/pgtable.h        |   12 +
 include/linux/autonuma.h             |   64 ++
 include/linux/autonuma_flags.h       |   68 ++
 include/linux/autonuma_list.h        |   94 ++
 include/linux/autonuma_sched.h       |   50 ++
 include/linux/autonuma_types.h       |  130 +++
 include/linux/huge_mm.h              |    6 +-
 include/linux/kthread.h              |    1 +
 include/linux/memory_hotplug.h       |    3 +-
 include/linux/mm_types.h             |    5 +
 include/linux/mmzone.h               |   25 +
 include/linux/page_autonuma.h        |   59 ++
 include/linux/sched.h                |    5 +-
 init/main.c                          |    2 +
 kernel/fork.c                        |   36 +-
 kernel/kthread.c                     |   23 +
 kernel/sched/Makefile                |    1 +
 kernel/sched/core.c                  |    1 +
 kernel/sched/fair.c                  |   72 ++-
 kernel/sched/numa.c                  |  586 +++++++++++++
 kernel/sched/sched.h                 |   18 +
 mm/Kconfig                           |   13 +
 mm/Makefile                          |    1 +
 mm/autonuma.c                        | 1549 ++++++++++++++++++++++++++++++++++
 mm/autonuma_list.c                   |  167 ++++
 mm/huge_memory.c                     |   59 ++-
 mm/memory.c                          |   35 +-
 mm/memory_hotplug.c                  |    2 +-
 mm/mempolicy.c                       |   15 +-
 mm/mmu_context.c                     |    2 +
 mm/page_alloc.c                      |    5 +
 mm/page_autonuma.c                   |  236 ++++++
 mm/sparse.c                          |  126 +++-
 40 files changed, 3512 insertions(+), 48 deletions(-)
 create mode 100644 include/linux/autonuma.h
 create mode 100644 include/linux/autonuma_flags.h
 create mode 100644 include/linux/autonuma_list.h
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 include/linux/autonuma_types.h
 create mode 100644 include/linux/page_autonuma.h
 create mode 100644 kernel/sched/numa.c
 create mode 100644 mm/autonuma.c
 create mode 100644 mm/autonuma_list.c
 create mode 100644 mm/page_autonuma.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
