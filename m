Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7E6F76B017C
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 20:43:53 -0400 (EDT)
Date: Fri, 15 Oct 2010 02:42:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #31
Message-ID: <20101015004240.GI5770@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc/7transparent_hugepage-31/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc7/transparent_hugepage-31.gz

Diff #30 -> #31:

 b/ksmd-khugepaged-freeze                     |   35 ++++-

Sleep in wait_event_freezable.

 b/pte_alloc_trans_splitting                  |   24 +++-

Fix build problem with INTEL_TXT=y. (problem found by Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com>)

 b/transhuge_mapcount_debug                   |   34 +++++

Add two VM_BUG_ON to verify invariants.

 b/transparent-hugepage-per-node-meminfo      |   54 +++++++++

Provide per-node meminfo from David Rientjes <rientjes@google.com>.

 b/transparent_hugepage                       |   19 +--

Fix memleak in case of fork vs split_huge_page race.

Move a VM_BUG_ON inside a spinlock to avoid false positives.

 b/transparent_hugepage_vmstat-anon_vma-chain |   12 --

Fix /proc/vmstat when TRANSPARENT_HUGEPAGE=n (problem found by Anton
Blanchard <anton@samba.org>).

 b/vma_adjust_trans_huge                      |  161 +++++++++++++++++++++++++++

A race condition could occur if qemu-kvm extends the vma when at least
one ptes before vma-extension wasn't null, then khugepaged could
collapse an hugepage before the KSM madvise run. Unlike most madvise
that can work on anonymous memory (like MADV_DONTNEED calling
zap_page_range that in turn will call split_huge_page_pmd) there is no
pte mangling done whatsoever by the ksm_madvise, it just splits the
vma in a way that can't fit an hugepage anymore, but without calling
split_huge_page. That would then lead to a later fork to run
copy_huge_pmd twice on the same hugepage (so boosting the mapcount
twice). That would later trip a BUG_ON in split_huge_page when process
quits as the number of hugepmd found by the rmap walk would be lower
than the page_mapcount. No memory corruption or data corruption could
happen and in fact this would result in memleak if there wasn't such
BUG_ON. split_huge_page is very strict, changes for something to go
wrong unnoticed are very low.

For triggering it takes a combination of khugepaged just at the wrong
time plus a combination of KSM madvise, and finally fork.

Similar invariant breakage (leading to copy_huge_pmd running twice on
the same hugepage) could have happened in case things like munmap run
in the middle of a vma would succeed the first split_vma but fail the
second one (no pte mangling would be invoked and the effect of the
first succeeded split_vma wouldn't be rolled back).

Fixing this from inside vma_adjust takes care of every one of these
cases with a one liner change to mmap.c (that is optimized away at
compile time if TRANSPARENT_HUGEPAGE=n).

 compaction-migration-warning                 |   25 ----
 free_pages-count                             |   60 ----------
 free_pages-drain_all_pages                   |   62 ----------
 free_pages-vmstat                            |  156 --------------------------
 swapin-race-conditions                       |  152 -------------------------

merged upstream.

Full diffstat:

 Documentation/vm/transhuge.txt        |  283 ++++
 arch/alpha/include/asm/mman.h         |    2 
 arch/mips/include/asm/mman.h          |    2 
 arch/parisc/include/asm/mman.h        |    2 
 arch/powerpc/mm/gup.c                 |   12 
 arch/x86/include/asm/kvm_host.h       |    1 
 arch/x86/include/asm/paravirt.h       |   23 
 arch/x86/include/asm/paravirt_types.h |    6 
 arch/x86/include/asm/pgtable-2level.h |    9 
 arch/x86/include/asm/pgtable-3level.h |   23 
 arch/x86/include/asm/pgtable.h        |  149 ++
 arch/x86/include/asm/pgtable_64.h     |   28 
 arch/x86/include/asm/pgtable_types.h  |    3 
 arch/x86/kernel/paravirt.c            |    3 
 arch/x86/kernel/tboot.c               |    2 
 arch/x86/kernel/vm86_32.c             |    1 
 arch/x86/kvm/mmu.c                    |   60 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   28 
 arch/x86/mm/pgtable.c                 |   66 
 arch/xtensa/include/asm/mman.h        |    2 
 drivers/base/node.c                   |   21 
 fs/Kconfig                            |    2 
 fs/exec.c                             |   44 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 +
 include/linux/compaction.h            |   13 
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  170 ++
 include/linux/khugepaged.h            |   66 
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/mm.h                    |  114 +
 include/linux/mm_inline.h             |   19 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   66 
 include/linux/mmzone.h                |    1 
 include/linux/page-flags.h            |   36 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   55 
 mm/Kconfig                            |   38 
 mm/Makefile                           |    1 
 mm/compaction.c                       |   48 
 mm/huge_memory.c                      | 2291 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   52 
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  138 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  198 ++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   12 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |    7 
 mm/mmu_notifier.c                     |   20 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |   31 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  115 -
 mm/sparse.c                           |    4 
 mm/swap.c                             |  117 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   89 -
 mm/vmstat.c                           |    1 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   56 
 73 files changed, 4486 insertions(+), 411 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
