Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 66230620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:48:46 -0400 (EDT)
Date: Tue, 3 Aug 2010 15:56:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #29
Message-ID: <20100803135615.GG6071@random.random>
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

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35/transparent_hugepage-29/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35/transparent_hugepage-29.gz

Diff #28 -> #29:

 THP-disable-on-small-systems    |   41 ++++++++

Disable THP on <500M systems, from Rik.

 compaction-kswapd               |  194 ++++++++++++++++++++++++++++++++++++++++

Add a compaction mode for kswapd to fully replace obsolete blind lumpy
reclaim.

 free_pages-count                |   60 ++++++++++++
 free_pages-drain_all_pages      |   62 ++++++++++++
 free_pages-vmstat               |  156 ++++++++++++++++++++++++++++++++

Make free page statistics more accurate from Mel.

 ksmd-khugepaged-freeze          |   97 ++++++++++++++++++++

kswapd uses set_freezing, so shall ksmd and khugepaged.

 transparent-hugepage-nr_rotated |   36 +++++++
 transparent-hugepage-stat       |  166 ++++++++++++++++++++++++++++++++++

Fix inactive/active stats and nr_rotated, from Rik.

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
 arch/x86/kvm/mmu.c                    |   68 -
 arch/x86/kvm/paging_tmpl.h            |    6 
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
 include/linux/res_counter.h           |   12 
 include/linux/rmap.h                  |   33 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 include/linux/vmstat.h                |    4 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   55 
 mm/Kconfig                            |   38 
 mm/Makefile                           |    1 
 mm/compaction.c                       |   48 
 mm/huge_memory.c                      | 2212 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   86 -
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  169 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  241 +++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   22 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |   57 
 mm/mmu_notifier.c                     |   20 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/oom_kill.c                         |    1 
 mm/page_alloc.c                       |   58 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  228 ++-
 mm/sparse.c                           |    4 
 mm/swap.c                             |  117 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |  102 -
 mm/vmstat.c                           |   31 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   56 
 76 files changed, 4680 insertions(+), 527 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
