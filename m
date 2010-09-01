Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BC3D16B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:10:08 -0400 (EDT)
Date: Wed, 1 Sep 2010 21:08:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #30
Message-ID: <20100901190859.GA20316@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc3/transparent_hugepage-30/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc3/transparent_hugepage-30.gz

Diff #29 -> #30:

 b/compaction-migration-warning               |   25 +++

Avoid MIGRATION config warning when COMPACTION is selected but numa
and memhotplug aren't.

 do_swap_page-VM_FAULT_WRITE                  |   21 --
 kvm-huge-spte-wrprotect                      |   48 ------
 kvm-mmu-notifier-huge-spte                   |   29 ---
 root_anon_vma-anon_vma_lock                  |  208 ---------------------------
 root_anon_vma-avoid-ksm-hang                 |   30 ---
 root_anon_vma-bugchecks                      |   37 ----
 root_anon_vma-in_vma                         |   27 ---
 root_anon_vma-ksm_refcount                   |  169 ---------------------
 root_anon_vma-lock_root                      |  127 ----------------
 root_anon_vma-memory-compaction              |   36 ----
 root_anon_vma-mm_take_all_locks              |   81 ----------
 root_anon_vma-oldest_root                    |   81 ----------
 root_anon_vma-refcount                       |   29 ---
 root_anon_vma-swapin                         |   91 -----------
 root_anon_vma-use-root                       |   66 --------
 root_anon_vma-vma_lock_anon_vma              |   94 ------------

merged upstream.

 b/memcg_compound                             |  166 ++++++++++-----------
 b/memcg_compound_tail                        |   31 +---
 b/memcg_consume_stock                        |   31 ++--
 memcg_check_room                             |   88 -----------
 memcg_oom                                    |   34 ----

These had heavy rejects, the last two patches and other bits got
removed. memcg code is rewritten so fast it's hard to justify to keep
up with it. It's simpler and less time consuming to fix it just once
than over and over again. Likely memcg in this release isn't too
stable with THP on (it'll definitely work fine if you disable THP at
compile time or at boot time with the kernel parameter). Especially
all get_css/put_css will have to be re-audited after these new
changes. For now it builds just fine and the basics to support THP and
to show the direction are in. Nevertheless I welcome patches to fix
this up.

btw, memcg developers could already support THP inside memcg even if
THP is not included yet without any sort of problem, so it's also
partly up to them to want to support THP in memcg, but it's also
perfectly ok to catch up with memcg externally, but it'd be also nice
to know when memcg reaches a milestone and so when it's time to
re-audit it all for THP.

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
 arch/x86/kernel/vm86_32.c             |    1 
 arch/x86/kvm/mmu.c                    |   60 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   28 
 arch/x86/mm/pgtable.c                 |   66 +
 arch/xtensa/include/asm/mman.h        |    2 
 fs/Kconfig                            |    2 
 fs/exec.c                             |   44 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 +
 include/linux/compaction.h            |   13 
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  151 ++
 include/linux/khugepaged.h            |   66 +
 include/linux/ksm.h                   |   20 
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/mm.h                    |  114 +
 include/linux/mm_inline.h             |   19 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   66 +
 include/linux/mmzone.h                |    1 
 include/linux/page-flags.h            |   36 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 include/linux/vmstat.h                |    4 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   55 
 mm/Kconfig                            |   40 
 mm/Makefile                           |    1 
 mm/compaction.c                       |   48 
 mm/huge_memory.c                      | 2212 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   53 
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  138 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  235 +++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   12 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |    5 
 mm/mmu_notifier.c                     |   20 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/oom_kill.c                         |    1 
 mm/page_alloc.c                       |   58 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  115 -
 mm/sparse.c                           |    4 
 mm/swap.c                             |  117 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   98 -
 mm/vmstat.c                           |   31 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   56 
 74 files changed, 4468 insertions(+), 437 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
