Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F18666B02A4
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:46:37 -0400 (EDT)
Date: Fri, 9 Jul 2010 18:45:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #27
Message-ID: <20100709164530.GD5741@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc4/transparent_hugepage-27/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc4/transparent_hugepage-27.gz

Diff #26 -> #27:

 b/compound_futex                             |   39 ++----

Avoid taking compound_lock.

 b/compound_get_put                           |   13 +-

Take compound_lock_irqsave/irqrestore.

 b/compound_lock                              |   22 +++

Add compound_lock_irqsave/irqrestore.

 b/do_swap_page-VM_FAULT_WRITE                |   21 +++

Set VM_FAULT_WRITE when taking over the page in do_swap_page.

 b/has_transparent_hugepage                   |   45 +++++++

Auto disable THP if PSE not set (needed when running as Xen guest
paravirt and on 32bit kernels with THP enabled booted on old systems
without 2M pages).

 b/khugepaged                                 |    7 -

Fix khugepaged startup race condition.

 b/memcg_check_room                           |   88 +++++++++++++++
 b/memcg_consume_stock                        |   51 +++++++++
 b/memcg_oom                                  |   34 ++++++

memcg fixes from Johannes.

 b/pmd_mangling_x86                           |   38 +++++-

Build with CONFIG_SMP=n.

 b/remove-lumpy_reclaim                       |   24 ++--

Removed one leftover of lumpy reclaim.

 b/root_anon_vma-swapin                       |   91 ++++++++++++++++

Use local vma->anon_vma when taking over the page, from Rik.

 b/swapin-race-conditions                     |  152 +++++++++++++++++++++++++++

Fix two theoretical swapin race conditions (one only relevant for KSM
the other only relevant when >50% swap is full).

 b/transparent_hugepage                       |   21 +--

Robustness improvement to pmd_same checks, it wasn't a bug but let's
not relay on complex locking and hold the page pins to be sure the
pmd_same checks are reliable.

 net-regress                                  |   72 ------------

removed.

Full diff:

 Documentation/vm/transhuge.txt        |  283 ++++
 arch/alpha/include/asm/mman.h         |    2 
 arch/mips/include/asm/mman.h          |    2 
 arch/parisc/include/asm/mman.h        |    2 
 arch/powerpc/mm/gup.c                 |   12 
 arch/x86/include/asm/paravirt.h       |   23 
 arch/x86/include/asm/paravirt_types.h |    6 
 arch/x86/include/asm/pgtable-2level.h |    9 
 arch/x86/include/asm/pgtable-3level.h |   23 
 arch/x86/include/asm/pgtable.h        |  149 ++
 arch/x86/include/asm/pgtable_64.h     |   28 
 arch/x86/include/asm/pgtable_types.h  |    3 
 arch/x86/kernel/paravirt.c            |    3 
 arch/x86/kernel/vm86_32.c             |    1 
 arch/x86/kvm/mmu.c                    |   26 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   25 
 arch/x86/mm/pgtable.c                 |   66 +
 arch/xtensa/include/asm/mman.h        |    2 
 fs/Kconfig                            |    2 
 fs/exec.c                             |   44 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 ++
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  143 ++
 include/linux/khugepaged.h            |   66 +
 include/linux/ksm.h                   |   20 
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/mm.h                    |  114 +
 include/linux/mm_inline.h             |   13 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   40 
 include/linux/mmzone.h                |    1 
 include/linux/page-flags.h            |   36 
 include/linux/res_counter.h           |   12 
 include/linux/rmap.h                  |   33 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   55 
 mm/Kconfig                            |   38 
 mm/Makefile                           |    1 
 mm/compaction.c                       |   15 
 mm/huge_memory.c                      | 2182 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   80 -
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  167 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  241 +++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   22 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |   57 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |   31 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  228 ++-
 mm/sparse.c                           |    4 
 mm/swap.c                             |  117 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   56 
 mm/vmstat.c                           |    3 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   39 
 71 files changed, 4396 insertions(+), 496 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
