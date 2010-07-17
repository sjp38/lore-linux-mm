Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 042BD6B02A3
	for <linux-mm@kvack.org>; Sat, 17 Jul 2010 13:44:45 -0400 (EDT)
Date: Sat, 17 Jul 2010 19:43:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #28
Message-ID: <20100717174343.GA5852@random.random>
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

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc5/transparent_hugepage-28/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc5/transparent_hugepage-28.gz

Diff #27 -> #28:

 kvm-huge-spte-wrprotect    |   48 ++++++++

Fix guest corruption with no EPT and no NPT, when THP runs in guest,
and the same hugepage is mapped by two different huge spte
wrprotected.

 kvm-mmu-notifier-huge-spte |   29 ++++

Fix host corruption when THP runs on host, an off by one error was
making mmu notifier handler useless for mmu notifier for certain gfn.

 mmu_notifier_test_young    |  265 +++++++++++++++++++++++++++++++++++++++++++++

Fix khugepaged young bit check to be reliable (testing pte not enough,
gup-fast must set SetPageReferenced like gup does, and we need to test
PageReferenced in addition to the spte young bit on the
implementations with a young bit set in spte by hardware). Without
this khugepaged may get not effective as it should in collapsing huge
pages after a low-memory condition of the VM with KVM (only KVM or
other mmu notifier users were affected as normally after direct-io
with gup-fast the main cpu is going to touch the data anyway through
the pte, but with secondary mmus the primary mmu may never touch the
data again).

Full diff:

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
 include/linux/mmu_notifier.h          |   66 +
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
 mm/huge_memory.c                      | 2184 ++++++++++++++++++++++++++++++++++
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
 mm/mmu_notifier.c                     |   20 
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
 virt/kvm/kvm_main.c                   |   56 
 73 files changed, 4507 insertions(+), 498 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
