Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 71A176B0087
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:21 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/36] AutoNUMA24
Date: Wed, 22 Aug 2012 16:58:44 +0200
Message-Id: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hello everyone,

Before the Kernel Summit, I think it's good idea to post a new
AutoNUMA24 and to go through a new review cycle. The last review cycle
has been fundamental in improving the patchset. Thanks!

The objective of AutoNUMA is to be able to perform as close as
possible to (and sometime faster than) the NUMA hard CPU/memory
bindings setups, without requiring the administrator to manually setup
any NUMA hard bind.

I hope everyone sees this is an hard problem, and what one thinks will
work great in theory, when tested in practice, it may not run so
great. But I'd like to remind that all research is good and valuable.
All approaches to solve the problem are worthwhile, regardless if they
work better/worse. sched-numa rewrite is also a very interesting
approach and I hope everyone agrees that it's wonderful that both ways
to solve the problem are being researched. Whatever will be merged
upstream in the end won't change the fact that all work done to try to
solve this hard problem is very valuable and worthwhile.

git clone --reference linux -b autonuma24 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Development autonuma branch:

git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

To update:

git fetch
git checkout -f origin/autonuma

PDF with some benchmark results:

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma-vs-sched-numa-rewrite-20120817.pdf
http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120530.pdf

Changelog from AutoNUMA19 to AutoNUMA24:

o Improved lots of comments and header commit messages.

o Rewritten from scratch the comment at the top of kernel/sched/numa.c
  as the old comment wasn't well received in upstream reviews. Tried
  to describe the algorithm from a global view now.

o Added ppc64 support.

o Improved patch splitup.

o Lots of code cleanups and variable renames to make the code more readable.

o Try to take advantage of task_autonuma_nid before the knuma_scand is
  complete.

o Moved some performance tuning sysfs tweaks under DEBUG_VM so they
  won't be visible on production kernels.

o Enabled by default the working set mode for the mm_autonuma data
  collection.

o Halved the size of the mm_autonuma structure.

o scan_sleep_pass_millisecs now is more intuitive (you can can set it
  to 10000 to mean one pass every 10 sec, in the previous release it had
  to be set to 5000 to one pass every 10 sec).

o Removed PF_THREAD_BOUND to allow CPU isolation. Turned the VM_BUG_ON
  verifying the hard binding into a WARN_ON_ONCE so the knuma_migrated
  can be moved by root anywhere safely.

o Optimized autonuma_possible() to avoid checking num_possible_nodes()
  every time.

o Added the math on the last_nid statistical effects from sched-numa
  rewrite which also introduced the last_nid logic of AutoNUMA.

o Now handle systems with holes in the NUMA nodemask. Lots of
  num_possible_nodes() replaced with nr_node_ids (nr_node_ids not so
  nice name for such information).

o Fixed a bug affecting KSM. KSM failed to merge pages mapped with a
  pte_numa pte, now it passes LTP fine. LTP found it.

o Fixed repeated CPU scheduler migrate in sched_autonuma_balance()
  (the idle load balancing sometime was faster and it put the task
  back to its previous CPU before it had a chance to be scheduled on
  the destination CPU).

o More...

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

Andrea Arcangeli (35):
  autonuma: make set_pmd_at always available
  autonuma: export is_vma_temporary_stack() even if
    CONFIG_TRANSPARENT_HUGEPAGE=n
  autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
  autonuma: pte_numa() and pmd_numa()
  autonuma: teach gup_fast about pmd_numa
  autonuma: introduce kthread_bind_node()
  autonuma: mm_autonuma and task_autonuma data structures
  autonuma: define the autonuma flags
  autonuma: core autonuma.h header
  autonuma: CPU follows memory algorithm
  autonuma: add page structure fields
  autonuma: knuma_migrated per NUMA node queues
  autonuma: autonuma_enter/exit
  autonuma: call autonuma_setup_new_exec()
  autonuma: alloc/free/init task_autonuma
  autonuma: alloc/free/init mm_autonuma
  autonuma: prevent select_task_rq_fair to return -1
  autonuma: teach CFS about autonuma affinity
  autonuma: memory follows CPU algorithm and task/mm_autonuma stats
    collection
  autonuma: default mempolicy follow AutoNUMA
  autonuma: call autonuma_split_huge_page()
  autonuma: make khugepaged pte_numa aware
  autonuma: retain page last_nid information in khugepaged
  autonuma: numa hinting page faults entry points
  autonuma: reset autonuma page data when pages are freed
  autonuma: link mm/autonuma.o and kernel/sched/numa.o
  autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
  autonuma: page_autonuma
  autonuma: autonuma_migrate_head[0] dynamic size
  autonuma: bugcheck page_autonuma fields on newly allocated pages
  autonuma: shrink the per-page page_autonuma struct size
  autonuma: boost khugepaged scanning rate
  autonuma: make the AUTONUMA_SCAN_PMD_FLAG conditional to
    CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
  autonuma: add knuma_migrated/allow_first_fault in sysfs
  autonuma: add mm_autonuma working set estimation

Vaidyanathan Srinivasan (1):
  autonuma: powerpc port

 arch/Kconfig                              |    6 +
 arch/powerpc/Kconfig                      |    6 +
 arch/powerpc/include/asm/pgtable.h        |   48 +-
 arch/powerpc/include/asm/pte-hash64-64k.h |    4 +-
 arch/powerpc/mm/numa.c                    |    3 +-
 arch/x86/Kconfig                          |    2 +
 arch/x86/include/asm/paravirt.h           |    2 -
 arch/x86/include/asm/pgtable.h            |   65 ++-
 arch/x86/include/asm/pgtable_types.h      |   28 +
 arch/x86/mm/gup.c                         |   13 +-
 arch/x86/mm/numa.c                        |    6 +-
 arch/x86/mm/numa_32.c                     |    3 +-
 fs/exec.c                                 |    7 +
 include/asm-generic/pgtable.h             |   12 +
 include/linux/autonuma.h                  |   72 ++
 include/linux/autonuma_flags.h            |  168 +++
 include/linux/autonuma_list.h             |  100 ++
 include/linux/autonuma_sched.h            |   50 +
 include/linux/autonuma_types.h            |  169 +++
 include/linux/huge_mm.h                   |    6 +-
 include/linux/kthread.h                   |    1 +
 include/linux/memory_hotplug.h            |    3 +-
 include/linux/mm_types.h                  |    5 +
 include/linux/mmzone.h                    |   38 +
 include/linux/page_autonuma.h             |   59 +
 include/linux/sched.h                     |    3 +
 init/main.c                               |    2 +
 kernel/fork.c                             |   18 +
 kernel/kthread.c                          |   21 +
 kernel/sched/Makefile                     |    1 +
 kernel/sched/core.c                       |    1 +
 kernel/sched/fair.c                       |   86 ++-
 kernel/sched/numa.c                       |  604 ++++++++++
 kernel/sched/sched.h                      |   19 +
 mm/Kconfig                                |   17 +
 mm/Makefile                               |    1 +
 mm/autonuma.c                             | 1727 +++++++++++++++++++++++++++++
 mm/autonuma_list.c                        |  169 +++
 mm/huge_memory.c                          |   78 ++-
 mm/memory.c                               |   31 +
 mm/memory_hotplug.c                       |    2 +-
 mm/mempolicy.c                            |   12 +-
 mm/mmu_context.c                          |    3 +
 mm/page_alloc.c                           |    7 +-
 mm/page_autonuma.c                        |  248 +++++
 mm/sparse.c                               |  126 ++-
 46 files changed, 4014 insertions(+), 38 deletions(-)
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
