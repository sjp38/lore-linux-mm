Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 52EB26008FB
	for <linux-mm@kvack.org>; Wed, 19 May 2010 21:06:18 -0400 (EDT)
Date: Thu, 20 May 2010 03:04:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #24
Message-ID: <20100520010446.GA5965@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog;h=refs/heads/anon_vma_chain

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master

To test the anon_vma_chain branch, simply use origin/anon_vma_chain
instead of origin/master in the above checkout. I am currently running
the origin/anon_vma_chain branch here (keeping master only in case of
troubles with the new anon-vma code, so far no problem with the
anon-vma->root shared locking design).

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-24/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-24.gz
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-24-anon_vma_chain.gz

Diff #23 -> #24

 anon-vma-lock-fix                                          |  247 -------------

Removed and replaced by anon-vma-root shared lock.

 b/backout-anon_vma-chain                                   |   39 +-

Small change.

 b/exec-migrate-race-anon_vma-chain                         |  196 +++++-----

Replaced with the version that keeps migrate away instead of allowing
rmap at all times (so it won't require allocations in execve).

 b/khugepaged                                               |   19 -
 b/khugepaged-old-anon_vma                                  |   39 ++
 b/khugepaged-vma-merge-anon_vma-chain                      |   16 

Adapted to anon-vma-root locking.

 b/kvm_transparent_hugepage                                 |  132 ++++++

Speedup and avoid spurious warning.

 b/memory-compaction-anon-vma-refcount                      |   10 
 b/memory-compaction-anon-vma-refcount-anon-vma-chain       |  126 ++++++
 b/memory-compaction-anon-vma-share-refcount                |   14 
 b/memory-compaction-anon-vma-share-refcount-anon-vma-chain |  166 ++++++++

Adapt to anon-vma-root locking (two versions needed now).

 b/memory-compaction-migrate_prep                           |   84 +++-

drain local lru in migrate.

 b/mprotect-vma-arg                                         |   32 -

anon-vma-root locking adjustment.

 b/root_anon_vma-anon_vma_lock                              |  213 +++++++++++
 b/root_anon_vma-ksm_refcount                               |  169 ++++++++
 b/root_anon_vma-lock_root                                  |  118 ++++++
 b/root_anon_vma-oldest_root                                |   84 ++++
 b/root_anon_vma-vma_lock_anon_vma                          |   97 +++++

Rik's anon-vma-root shared locking implementation (only in
anon_vma_chain branch).

 b/split_huge_page-old-anon-vma                             |   42 ++

anon-vma-root locking adjustment for master branch.

 mincore-transhuge-anon_vma-chain                           |   69 ---
 mprotect-transhuge-anon_vma-chain                          |   21 -
 transparent_hugepage-anon_vma-chain                        |  203 ----------

anon-vma-root locking adjustment for anon_vma_chain branch.

Diff against 2.6.34 (anon_vma_chain branch):

 Documentation/cgroups/memory.txt      |    4 
 Documentation/sysctl/vm.txt           |   25 
 Documentation/vm/transhuge.txt        |  283 ++++
 arch/alpha/include/asm/mman.h         |    2 
 arch/mips/include/asm/mman.h          |    2 
 arch/parisc/include/asm/mman.h        |    2 
 arch/powerpc/mm/gup.c                 |   12 
 arch/x86/include/asm/paravirt.h       |   23 
 arch/x86/include/asm/paravirt_types.h |    6 
 arch/x86/include/asm/pgtable-2level.h |    9 
 arch/x86/include/asm/pgtable-3level.h |   23 
 arch/x86/include/asm/pgtable.h        |  144 ++
 arch/x86/include/asm/pgtable_64.h     |   14 
 arch/x86/include/asm/pgtable_types.h  |    3 
 arch/x86/kernel/paravirt.c            |    3 
 arch/x86/kernel/vm86_32.c             |    1 
 arch/x86/kvm/mmu.c                    |   26 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   25 
 arch/x86/mm/pgtable.c                 |   66 +
 arch/xtensa/include/asm/mman.h        |    2 
 drivers/base/node.c                   |    3 
 fs/Kconfig                            |    2 
 fs/exec.c                             |    7 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 ++
 include/linux/compaction.h            |   89 +
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  143 ++
 include/linux/khugepaged.h            |   66 +
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/migrate.h               |    2 
 include/linux/mm.h                    |   93 +
 include/linux/mm_inline.h             |   13 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   40 
 include/linux/mmzone.h                |   10 
 include/linux/page-flags.h            |   36 
 include/linux/rmap.h                  |   58 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    8 
 include/linux/vmstat.h                |    4 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   67 -
 kernel/sysctl.c                       |   25 
 mm/Kconfig                            |   56 
 mm/Makefile                           |    2 
 mm/compaction.c                       |  620 +++++++++
 mm/huge_memory.c                      | 2157 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   77 -
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |   88 -
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  179 ++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   77 +
 mm/mincore.c                          |  302 ++--
 mm/mmap.c                             |   37 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |  132 +-
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  211 ++-
 mm/sparse.c                           |    4 
 mm/swap.c                             |  116 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   42 
 mm/vmstat.c                           |  256 ++++
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   39 
 76 files changed, 5586 insertions(+), 508 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
