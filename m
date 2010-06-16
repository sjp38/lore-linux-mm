Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FFDF6B01AF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:46:07 -0400 (EDT)
Date: Wed, 16 Jun 2010 19:44:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #26
Message-ID: <20100616174448.GK5816@random.random>
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

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc3/transparent_hugepage-26/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc3/transparent_hugepage-26.gz

Diff #25 -> #26:

 b/compound_mapping                                     |   20 

Clearing mapping on tail pages is wrong, fixed.

 b/exec-migrate-race-anon_vma-chain                     |   96 +

Allow rmap to run at all times also during initial execve.

 b/memcg_compound                                       |  105 -

memcg THP fixes from Daisuke Nishimura.

 b/memcg_compound_tail                                  |  120 +

More memcg THP fixes from Daisuke Nishimura.

 b/net-regress                                          |   72 +

backout to avoid net regression.

 b/remove-lumpy_reclaim                                 |  103 +

Removed the new lumpy reclaim changes too.

 b/root_anon_vma-anon_vma_lock                          |   29 
 b/root_anon_vma-avoid-ksm-hang                         |   30 
 b/root_anon_vma-bugchecks                              |   37 
 b/root_anon_vma-in_vma                                 |   27 
 b/root_anon_vma-ksm_refcount                           |   20 
 b/root_anon_vma-lock_root                              |   49 
 b/root_anon_vma-memory-compaction                      |   36 
 b/root_anon_vma-oldest_root                            |   17 
 b/root_anon_vma-refcount                               |   29 
 b/root_anon_vma-use-root                               |   66 
 b/root_anon_vma-vma_lock_anon_vma                      |   17 

anon vma fixes for migrate and THP.

Removed (old-anon-vma branch not needed anymore after the
root_anon_vma-avoid-ksm-hang fix and memory compaction and mincore
cleanups in mainline).

 backout-anon_vma-chain                                 | 1137 -----------------
 exec-migrate-race                                      |  144 --
 khugepaged-old-anon_vma                                |   39 
 khugepaged-vma-merge-anon_vma                          |   52 
 memory-compaction-anon-migrate                         |   49 
 memory-compaction-anon-migrate-anon-vma-chain          |   49 
 memory-compaction-anon-vma-refcount                    |  126 -
 memory-compaction-anon-vma-refcount-anon-vma-chain     |  191 --
 memory-compaction-anon-vma-share-refcount              |  159 --
 memory-compaction-config-migration-without-config-numa |   54 
 memory-compaction-core                                 |  552 --------
 memory-compaction-direct                               |  360 -----
 memory-compaction-exponential-backoff                  |  131 -
 memory-compaction-extfrag_index                        |  132 -
 memory-compaction-extfrag_threshold                    |  128 -
 memory-compaction-lru-header                           |   42 
 memory-compaction-migrate-swapcache                    |  107 -
 memory-compaction-migrate-swapcache-anon-vma-chain     |  107 -
 memory-compaction-migrate_prep                         |   77 -
 memory-compaction-proc-node-trigger                    |   99 -
 memory-compaction-proc-trigger                         |  160 --
 memory-compaction-unusable_index                       |  191 --
 mincore-break-do_mincore-into-logical-pieces           |  239 ---
 mincore-cleanups                                       |  174 --
 mincore-do-nested-page-table-walks                     |  116 -
 mincore-pass-ranges-as-startend-address-pairs          |  161 --
 split_huge_page-anon_vma-order                         |   59 
 split_huge_page-old-anon-vma                           |   77 -
 transparent_hugepage_vmstat                            |  129 -
 78 files changed, 851 insertions(+), 5353 deletions(-)

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
 fs/Kconfig                            |    2 
 fs/exec.c                             |   44 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 ++
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  143 ++
 include/linux/khugepaged.h            |   66 +
 include/linux/ksm.h                   |    2 
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/mm.h                    |   94 +
 include/linux/mm_inline.h             |   13 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   40 
 include/linux/mmzone.h                |    1 
 include/linux/page-flags.h            |   36 
 include/linux/rmap.h                  |   31 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   67 -
 mm/Kconfig                            |   38 
 mm/Makefile                           |    1 
 mm/compaction.c                       |   15 
 mm/huge_memory.c                      | 2172 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   77 -
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  134 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  196 ++-
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   22 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |   57 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |   31 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  215 ++-
 mm/sparse.c                           |    4 
 mm/swap.c                             |  116 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   54 
 mm/vmstat.c                           |    3 
 net/core/dev.c                        |   17 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   39 
 71 files changed, 4277 insertions(+), 466 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
