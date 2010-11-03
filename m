Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C3108D0017
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:15 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 66] Transparent Hugepage Support #32
Message-Id: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Some of some relevant user of the project:

KVM Virtualization
GCC (kernel build included, requires a few liner patch to enable)
JVM
VMware Workstation
HPC

It would be great if it could go in -mm.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=blob;f=Documentation/vm/transhuge.txt
http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.37-rc1/transparent_hugepage-32/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.37-rc1/transparent_hugepage-32.gz

Diff #31 -> #32:

 b/clear_copy_huge_page             |   59 ++++++++--------

hugetlbfs.c copy_huge_page was renamed to copy_user_huge_page.

 b/kvm_transparent_hugepage         |   38 +++++-----

Adjust hva_to_pfn interface change.

 b/lumpy-compaction                 |   48 +++++++++++++

Disable lumpy reclaim when CONFIG_COMPACTION is enabled. Agreed with Mel @
Kernel Summit. Mel wants to defer the full removal of lumpy reclaim of a few
releases. Disabling lumpy reclaim is needed to prevent THP to render the system
totally unusable when reclaim starts.

 b/pmd_trans_huge_migrate           |   31 +++-----

Migrate can now migrate hugetlb pages. This has a chance to break on THP but it
seems all the "magic hugetlbfs code paths" are activeted by the "destination"
page to be huge. That never happens with THP that in fact would split the page
making the source not huge either. So it seems the current code may co-exist
with THP too without further changes.

This update also fixes a false positive BUG_ON in remove_migration_pte that
could materialize after handling the CPU errata(s) that shows the CPU don't
like 4k and 2M simultaneous TLB entries. To implement the workaround without
increasing the TLB flush cost of split_huge_page I had to set the hugepmd as
non-present during the TLB flush (so opening a micro-window for a false
positive in the BUG_ON check). The BUG_ON simply can be safely removed now, in
turn solving the false positive.

 remove-lumpy_reclaim               |  131 -------------------------------------

lumpy reclaim not removed anymore but it gets disabled at runtime by enabling
CONFIG_COMPACTION=y at compile time (and setting CONFIG_TRANSPARENT_HUGEPAGE=y
implicitly selects CONFIG_COMPACTION=y of course).

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
 mm/huge_memory.c                      | 2290 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   52 
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |  138 +-
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  199 ++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |    7 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |    7 
 mm/mmu_notifier.c                     |   20 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    9 
 mm/page_alloc.c                       |   31 
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  115 -
 mm/sparse.c                           |    4 
 mm/swap.c                             |  117 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   43 
 mm/vmstat.c                           |    1 
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   56 
 73 files changed, 4485 insertions(+), 362 deletions(-)

FAQ:

Q: When will 1G pages be supported? (by far the most frequently asked question
   in the last two days)
A: Not any time soon but it's not entirly impossible... The benefit of going
   from 2M to 1G is likely much lower than the benefit of going from 4k to 2M
   so it's unlikely to be a worthwhile effort for a while.

Q: When this will work on filebacked pages? (pagecache/swapcache/tmpfs)
A: Not until it's merged in mainline. It's already feature complete for many
   usages and the moment we expand into pagecache the patch would grow
   significantly.

Q: When will KSM will scan inside Transparent Hugepages?
A: Working on that, this should materialize soon enough.

Q: What is the next place where to remove split_huge_page_pmd()?
A: mremap. JVM uses mremap in the garbage collector so the ~18% boost (no virt)
   has further margin for optimizations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
