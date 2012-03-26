Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 8DE0D6B00EC
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 15:08:57 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/39] [RFC] AutoNUMA alpha10
Date: Mon, 26 Mar 2012 19:45:47 +0200
Message-Id: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi everyone,

This is the result of the first round of cleanups of the AutoNUMA patch.

This can also be fetched through an autonuma-alpha10 branch.

git clone --reference linux -b autonuma-alpha10 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

A first attempt for an highlevel description of how this works can be
found in the comment of the patch "autonuma: core".

Some benchmark results can be found in the below document (updated to
include the SMT regression test, with only half of the cores loaded,
and half idle, page 7).

Page 9 measures the overhead of the knuma_scand pass during a kernel
build with its default 10sec knuma_scand pass interval.

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120322.pdf

TODO:

1) THP native migration
2) dynamically allocate the AutoNUMA struct page fields like memcg
   does it so they won't take any memory if the kernel is booted on
   not-NUMA hardware
3) write Documentation/vm/autonuma.txt with a kernel internal focus
4) possibly find a way to improve the kernel/sched/numa.c algorithm
   with an implementation that is more integrated in CFS

Andrea Arcangeli (36):
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
  mm: add unlikely to the mm allocation failure check
  autonuma: avoid CFS select_task_rq_fair to return -1
  autonuma: select_task_rq_fair cleanup new_cpu < 0 fix
  autonuma: teach CFS about autonuma affinity
  autonuma: select_idle_sibling cleanup target assignment
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
  autonuma: NUMA scheduler SMT awareness

Hillf Danton (3):
  autonuma: fix selecting task runqueue
  autonuma: fix finding idlest cpu
  autonuma: fix selecting idle sibling

 arch/x86/include/asm/paravirt.h      |    2 -
 arch/x86/include/asm/pgtable.h       |   51 ++-
 arch/x86/include/asm/pgtable_types.h |   22 +-
 arch/x86/mm/gup.c                    |    2 +-
 fs/exec.c                            |    3 +
 include/asm-generic/pgtable.h        |   12 +
 include/linux/autonuma.h             |   41 +
 include/linux/autonuma_flags.h       |   72 ++
 include/linux/autonuma_sched.h       |   61 ++
 include/linux/autonuma_types.h       |   54 ++
 include/linux/huge_mm.h              |    2 +
 include/linux/kthread.h              |    1 +
 include/linux/mm_types.h             |   30 +
 include/linux/mmzone.h               |    6 +
 include/linux/sched.h                |    3 +
 kernel/fork.c                        |   36 +-
 kernel/kthread.c                     |   23 +
 kernel/sched/Makefile                |    3 +-
 kernel/sched/core.c                  |   12 +-
 kernel/sched/fair.c                  |   68 ++-
 kernel/sched/numa.c                  |  320 ++++++++
 kernel/sched/sched.h                 |   12 +
 mm/Kconfig                           |   13 +
 mm/Makefile                          |    1 +
 mm/autonuma.c                        | 1444 ++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                     |   51 ++-
 mm/memory.c                          |   36 +-
 mm/mempolicy.c                       |   15 +-
 mm/mmu_context.c                     |    2 +
 mm/page_alloc.c                      |   19 +
 30 files changed, 2373 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/autonuma.h
 create mode 100644 include/linux/autonuma_flags.h
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 include/linux/autonuma_types.h
 create mode 100644 kernel/sched/numa.c
 create mode 100644 mm/autonuma.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
