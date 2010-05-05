Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C82836B028E
	for <linux-mm@kvack.org>; Tue,  4 May 2010 22:05:02 -0400 (EDT)
Date: Wed, 5 May 2010 02:11:44 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #23
Message-ID: <20100505001144.GB2034@random.random>
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
instead of origin/master in the above checkout.

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc6/transparent_hugepage-23/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc6/transparent_hugepage-23.gz
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc6/transparent_hugepage-23-anon_vma_chain.gz

1) Now there are two branches (origin/master and
   origin/anon_vma_chain) to checkout. origin/master uses the old
   anon_vma code but it also stopped using vma->anon_vma->lock
   anywhere in the huge_memory.c/huge_mm.h code, to exercise the new
   locking that now only uses the page->mapping/anon_vma->lock in both
   branches. So these patches are applied in both branches for more
   testing (even if they're only strictly needed in the anon_vma_chain
   branch).

   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=6fef4ed210f321a537fd452b20e9b19a0d55d954
   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=3578588348b3f14800a5a24f8e1cc965aee9d8d3
   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=403a5b09bf8544da183676c221d6ff225a87566b

2) both branches include the new fix for the exec vs migrate race as
   there was a little ordering detail noticed by Mel that had to be
   addressed to make it fully safe (likely the prev patch in #22 only
   decreased the race window, this seems to finally close it for real
   as Mel's initial testing also confirmed).

   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=171f9a34ece592c9e78549ce992bcef312b8ec78
   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=93a3a408115576075494decf2ae1bacb94181cda     

3) The anon_vma_chain branch includes Rik's patch to fix migration
   crashes and split_huge_page crashes without requiring the rmap_walk
   to take any more lock than the page->mapping/anon_vma->lock as
   usual. So thanks to this and thanks to the other changes to the
   locking in point1), split_huge_page has a chance to be safe on the
   anon_vma_chain code.

   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=03606d7ae00b148e01b604f7fce82c74e9566ea3

4) the transparent_hugepage= boot parameter now accepts
   always|madvise|never and no numbers anymore. it's simpler to use
   this way and less dependent on internal defines. removed the
   no_transparent_hugepage parameter, transparent_hugepage=never is
   simple enough. as usual set_recommended_min_free_kbytes if
   transparent_hugepage=never is passed at boot. Added the boot param
   doc to vm/transhuge.txt accordingly.

5) Minor doc cleanups.

So now that it should work safe with anon_vma_chain too, we're aligned
for merging into -mm or mainline when next window opens.

The big picture document with also the documentation on locking and
design here:

       http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=blob_plain;f=Documentation/vm/transhuge.txt;hb=HEAD

I left benchmarks out as there are a bit too many.

Let me know what else is needed to comply for future merging so I can
prepare it in advance. (only thing that comes to mind is to try the
kernel build with perf to provide further data on the very workload we
run all the time, and the MAP_ALIGN for mmap suggested by Ulrich but
it's an independent feature)

Thanks!
Andrea

----
Most of the diff from #22 in the source repo (as in the ftp directory)
involved duplicating some patches to generate a old-anon_vma and
new-anon_vma version and to add proper qguards to qselect to maintain
both trees at the same time.

 b/anon-vma-lock-fix                             |  247 ++++++++++++++++++++++++
 b/exec-migrate-race                             |   84 ++++++--
 b/exec-migrate-race-anon_vma-chain              |  146 ++++++++++++++
 b/khugepaged                                    |   43 ----
 b/khugepaged-vma-merge-anon_vma                 |   52 +++++
 b/khugepaged-vma-merge-anon_vma-chain           |   52 +++++
 b/mincore-break-do_mincore-into-logical-pieces  |    2 
 b/mincore-cleanups                              |    2 
 b/mincore-do-nested-page-table-walks            |    2 
 b/mincore-pass-ranges-as-startend-address-pairs |    2 
 b/mincore-transhuge-anon_vma-chain              |   69 ++++++
 b/mprotect-transhuge-anon_vma-chain             |   21 ++
 b/series                                        |   19 +
 b/split_huge_page-anon_vma-chain-order          |   58 +++++
 b/split_huge_page-old-anon-vma                  |   39 +++
 b/transparent_hugepage                          |   53 +++--
 b/transparent_hugepage-anon_vma-chain           |  203 +++++++++++++++++++
 b/transparent_hugepage-doc                      |   20 +
 b/transparent_hugepage_vmstat                   |   14 -
 b/transparent_hugepage_vmstat-anon_vma-chain    |  129 ++++++++++++
 page-anon-vma                                   |   39 ---
 21 files changed, 1166 insertions(+), 130 deletions(-)

anon_vma_chain version (so not to include the backout diff):

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
 arch/x86/kvm/mmu.c                    |   21 
 arch/x86/kvm/paging_tmpl.h            |    4 
 arch/x86/mm/gup.c                     |   25 
 arch/x86/mm/pgtable.c                 |   66 +
 arch/xtensa/include/asm/mman.h        |    2 
 drivers/base/node.c                   |    3 
 fs/Kconfig                            |    2 
 fs/exec.c                             |   37 
 fs/proc/meminfo.c                     |   14 
 fs/proc/page.c                        |   14 
 include/asm-generic/mman-common.h     |    2 
 include/asm-generic/pgtable.h         |  130 ++
 include/linux/compaction.h            |   89 +
 include/linux/gfp.h                   |   14 
 include/linux/huge_mm.h               |  132 ++
 include/linux/khugepaged.h            |   66 +
 include/linux/memory_hotplug.h        |   14 
 include/linux/mm.h                    |   90 +
 include/linux/mm_inline.h             |   13 
 include/linux/mm_types.h              |    3 
 include/linux/mmu_notifier.h          |   40 
 include/linux/mmzone.h                |   10 
 include/linux/page-flags.h            |   36 
 include/linux/rmap.h                  |   30 
 include/linux/sched.h                 |    1 
 include/linux/swap.h                  |    8 
 include/linux/vmstat.h                |    4 
 kernel/fork.c                         |   12 
 kernel/futex.c                        |   67 -
 kernel/sysctl.c                       |   25 
 mm/Kconfig                            |   56 
 mm/Makefile                           |    2 
 mm/compaction.c                       |  622 +++++++++
 mm/huge_memory.c                      | 2199 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   48 
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |   88 -
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  179 ++
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   66 -
 mm/mincore.c                          |  303 ++--
 mm/mmap.c                             |    5 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |  132 +-
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  120 +
 mm/sparse.c                           |    4 
 mm/swap.c                             |  116 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   42 
 mm/vmstat.c                           |  256 +++
 72 files changed, 5454 insertions(+), 458 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
