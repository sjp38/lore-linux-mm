Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1217C6B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 00:16:49 -0500 (EST)
Date: Wed, 15 Dec 2010 06:15:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #33
Message-ID: <20101215051540.GP5638@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
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

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.37-rc5/transparent_hugepage-33/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.37-rc5/transparent_hugepage-33.gz

Diff #32 -> #33:

 b/THP-disable-on-small-systems               |    4 

Improved header.

 b/clear_copy_huge_page                       |   60 +--

Update after upstream changes.

 b/compaction-add-trace-events                |  179 +++++++++
 b/compaction-instead-of-lumpy                |  415 ++++++++++++++++++++++
 b/compaction-lumpy_mode                      |  169 +++++++++
 b/compaction-migrate-async                   |  388 +++++++++++++++++++++
 b/compaction-migrate_pages-api-bool          |  133 +++++++
 b/compaction-movable-pageblocks              |   56 +++
 b/compaction-reclaim_mode                    |  248 +++++++++++++
 b/zone_watermark_ok_safe                     |  372 ++++++++++++++++++++

Mel's lumpy compaction (disables lumpy and uses compaction instead
when CONFIG_COMPACTION=y) allows proper runtime when there are
frequent hugepage allocations like with THP on. Picked from mmotm
broken-out patchset to allow easy -mm integration and to test it out
in combination of THP.

 b/compaction-all-orders                      |   23 +
 b/compaction-kswapd                          |  104 +++--

Split the compaction-all-orders part off compaction-kswapd.

 b/compound_get_put                           |   39 +-

Cleanups.

 b/compound_get_put_fix                       |   28 +

While reading code I think there was a super tiny race (never
reproduced) in the put_page of a tail page in case split_huge_page
would run on the head page after put_page releases the compound lock
but before put_page_testzero is called (only after put_page_testzero returns
true we're sure split_huge_page can't run from under us anymore as it
requires a reference on the head page to run, rechecking PageHead is
enough to fix it).

 b/compound_lock                              |   13 

Change the API to return flags instead of void.

 b/compound_trans_order                       |  120 ++++++

Be safe while reading compound_order on transparent hugepages that may
be under split_huge_page.

 b/gfp_no_kswapd                              |   17 

Define ___GFP_NO_KSWAPD.

 b/khugepaged-mmap_sem                        |  113 ++++++

Some user reported deadlocks after days of load with pvfs.

Allocate memory inside mmap_sem read mode (not anymore inside mmap_sem
write mode) within khugepaged collapse_huge_page to satisfy certain
filesystems in userland that may benefit from THP (so they don't need
to use MADV_NOHUGEPAGE). Not sure if this bugfix was really required
from a theoretical standpoint (as far as the deadlock is concerned
this may actually hide bugs), but it makes the code more scalable so
it actually makes the code better and it's a no brainer.

Still investigating the page lock usage in khugepaged vs fuse.

 b/ksm-swapcache                              |   64 ---

Use Hugh's equivalent one liner fix.

 b/kvm_transparent_hugepage                   |   38 +-

Adjust for hva_to_pfn interface change.

 b/madv_nohugepage                            |  157 ++++++++
 b/madv_nohugepage_define                     |   64 +++

Add MADV_NOHUGEPAGE to disable THP on low priority vmas (needed
especially now that KSM won't scan inside THP, later it will be less
important but maybe still useful to leave hugepages available for
higher priority virtual machines).

 b/memcg_compound                             |   71 ++-

Don't batch hugepage releasing in __do_uncharge.

 b/memcg_huge_memory                          |   12 

Optimize with mem_cgroup_uncharge_start/stop().

 b/memory-failure-thp-vs-hugetlbfs            |   44 ++

The new hugetlbfs memory-failure code merged upstream collided with
THP (reported by some users running
mce-test.git/hwpoison/run-huge-test.sh on aa.git).

Use PageHuge to differentiate between THP pages and hugetlbfs pages in
common paths that can run into any of the two types. PageTransHuge
will still return 1 for hugetlbfs pages because PageTransHuge must
only be used in the core VM paths where hugetlbfs pages can't be
processed. In any place where hugetlbfs shared the common paths with
the core VM code, PageHuge should be used to differentiate the
two. Usually PageHuge is only needed in THP context in slow paths
(memory-failure is not just a slow but even an error path), so it's
ok and we don't want to slowdown PageTransHuge considering PageHuge
already is there for this.

 b/pagetranscompound                          |   30 -

Cleanups.

 b/pmd_mangling_generic                       |  488 +++++++++++++++++++--------

Cleanups to save icache by moving slow common methods to
mm/pgtable-generic.c.

 b/pmd_mangling_x86                           |   41 --

Update header and undo a noop change.

 b/pmd_paravirt_ops                           |   12 

Fix x86 32bit build with PAE off and paravirt on.

 b/pmd_trans                                  |   13 

macro -> inline cleanups.

 b/pmd_trans_huge_migrate                     |   31 -

Remove false positive bug on.

 b/pte_alloc_trans_splitting                  |   13 

Add BUG_ON matching the issue in pmd_trans_huge_migrate (pmd must be
null to call __pte_alloc, pmd_present is not enough if pmd_trans_huge
can be set). The reason is that very temporarily to optimize away one
unnecessary IPI for every split_huge_page we mark the pmd not present
but still huge for the duration of the IPI (this is to prevent
simultaneous 4k and 2M tlb entries that would machine check some CPU
with erratas).

 b/set-recommended-min_free_kbytes            |   10 

Explicit call setup_per_zone_wmarks even if min_free_kbytes is already
bigger than recommended_min (otherwise the reserved pageblocks won't
be enabled on huge systems). This brings the kernel version of
set_recommended_min_free_kbytes fully equivalent to the hugeadm
--set-recommended-min_free_kbytes command line.

 b/transhuge-enable-direct-defrag             |    3 

Header update.

 b/transhuge-selects-compaction               |   15 

Header update to explain why THP selects compaction.

 b/transparent_hugepage                       |  114 ++++--

Make PageTransHuge inline and move it from huge_mm.h to page-flags.h.

Add BUG_ON if is_vma_temporary_stack is set during split_huge_page (we
can't fail, it shall never trigger because mremap done on the initial
kernel stack during execve that sets the temporary stack flag for its
duration, shouldn't work on hugepages). The BUG_ON makes sure it won't
break silently if the user stack is ever born huge. 

Use assert_spin_locked instead of VM_BUG_ON.

Remove potentially false positive bugcheck for not present pmd, same
as pte_alloc_trans_splitting.

 b/transparent_hugepage-doc                   |   67 ++-

Doc improvement from Mel.

 b/transparent_hugepage-numa                  |   50 +-

Fix memleak if memcg fails charge during khugepaged collapse_huge_page
with CONFIG_NUMA=y.

 b/transparent_hugepage_vmstat-anon_vma-chain |   16 


 memcg_consume_stock                          |   56 ---
 remove-lumpy_reclaim                         |  131 -------
 exec-migrate-race-anon_vma-chain

removed.

FAQ:

Q: When will 1G pages be supported? (by far the most frequently asked question
   in the last two days)
A: Not any time soon but it's not entirly impossible... The benefit of going
   from 2M to 1G is likely much lower than the benefit of going from 4k to 2M
   so it's unlikely to be a worthwhile effort for a while. And some CPUs
   won't have 1G TLB so it only speedup a bit the tlb miss handler but
   it won't actually decrease the tlb miss rate.

Q: When this will work on filebacked pages? (pagecache/swapcache/tmpfs)
A: Not until it's merged in mainline. It's already feature complete for many
   usages and the moment we expand into pagecache the patch would grow
   significantly.

Q: When will KSM will scan inside Transparent Hugepages?
A: Working on that, this should materialize soon enough.

Q: What is the next place where to remove split_huge_page_pmd()?
A: mremap. JVM uses mremap in the garbage collector so the ~18% boost (no virt)
   has further margin for optimizations.

Full diffstat:

 Documentation/vm/transhuge.txt        |  298 ++++
 arch/alpha/include/asm/mman.h         |    3 
 arch/mips/include/asm/mman.h          |    3 
 arch/parisc/include/asm/mman.h        |    3 
 arch/powerpc/mm/gup.c                 |   12 
 arch/x86/include/asm/kvm_host.h       |    1 
 arch/x86/include/asm/paravirt.h       |   25 
 arch/x86/include/asm/paravirt_types.h |    6 
 arch/x86/include/asm/pgtable-2level.h |    9 
 arch/x86/include/asm/pgtable-3level.h |   23 
 arch/x86/include/asm/pgtable.h        |  143 ++
 arch/x86/include/asm/pgtable_64.h     |   28 
 arch/x86/include/asm/pgtable_types.h  |    3 
 arch/x86/kernel/paravirt.c            |    3 
 arch/x86/kernel/tboot.c               |    2 
 arch/x86/kernel/vm86_32.c             |    1 
 arch/x86/kvm/mmu.c                    |   60 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   28 
 arch/x86/mm/pgtable.c                 |   66 
 arch/xtensa/include/asm/mman.h        |    3 
 drivers/base/node.c                   |   21 
 fs/Kconfig                            |    2 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    3 
 include/asm-generic/pgtable.h         |  225 ++-
 include/linux/compaction.h            |   25 
 include/linux/gfp.h                   |   15 
 include/linux/huge_mm.h               |  159 ++
 include/linux/kernel.h                |    7 
 include/linux/khugepaged.h            |   67 
 include/linux/kvm_host.h              |    4 
 include/linux/memory_hotplug.h        |   14 
 include/linux/migrate.h               |   12 
 include/linux/mm.h                    |  137 +
 include/linux/mm_inline.h             |   19 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   66 
 include/linux/mmzone.h                |   11 
 include/linux/page-flags.h            |   65 
 include/linux/rmap.h                  |    2 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    2 
 include/linux/vmstat.h                |    5 
 include/trace/events/compaction.h     |   74 +
 include/trace/events/vmscan.h         |    6 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   55 
 mm/Kconfig                            |   38 
 mm/Makefile                           |    3 
 mm/compaction.c                       |  174 +-
 mm/huge_memory.c                      | 2331 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   70 -
 mm/internal.h                         |    4 
 mm/ksm.c                              |   29 
 mm/madvise.c                          |   10 
 mm/memcontrol.c                       |  129 +
 mm/memory-failure.c                   |   22 
 mm/memory.c                           |  199 ++
 mm/memory_hotplug.c                   |   17 
 mm/mempolicy.c                        |   20 
 mm/migrate.c                          |   29 
 mm/mincore.c                          |    7 
 mm/mmap.c                             |    7 
 mm/mmu_notifier.c                     |   20 
 mm/mmzone.c                           |   21 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    9 
 mm/page_alloc.c                       |   98 +
 mm/pagewalk.c                         |    1 
 mm/pgtable-generic.c                  |  123 +
 mm/rmap.c                             |   87 -
 mm/sparse.c                           |    4 
 mm/swap.c                             |  131 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |  210 ++-
 mm/vmstat.c                           |   69 -
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   56 
 81 files changed, 5189 insertions(+), 523 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
