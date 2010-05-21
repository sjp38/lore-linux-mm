Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 586C46B01B4
	for <linux-mm@kvack.org>; Thu, 20 May 2010 20:07:00 -0400 (EDT)
Date: Fri, 21 May 2010 02:05:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #25
Message-ID: <20100521000539.GA5733@random.random>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZPt4rx8FFjLCG7dd"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

If you're running scientific applications, JVM or large gcc builds
(see attached patch for gcc), and you want to run from 2.5% faster for
kernel build (on bare metal), or 8% faster in translate.o of qemu (on
bare metal), 15% faster or more with virt and Intel EPT/ AMD NPT
(depending on the workload), you should apply and run the transparent
hugepage support on your systems.

Awesome results have already been posted on lkml, if you test and
benchmark it, please provide any positive/negative real-life result on
lkml (or privately to me if you prefer). The more testing the better.

By running your scientific apps up to ~10% faster (or more if you use
virt), and in turn by boosting the performance of the virtualized
cloud, you will save energy. NOTE: it can cost memory in some cases,
but this is why a madvise(MADV_HUGEPAGE) exists, so THP can be
selectively enabled on the regions where the app knows there will be
zero memory waste in boosting performance (like KVM).

If you have more memory than you need as filesystem cache you can
choose "always" mode, while if you're ram constrained or you need as
much filesystem cache as possible but you still want a CPU boost in
the madvise regions without risking reducing the cache you should
choose "madvise". All settings can be later tuned with sysfs after
boot in /sys/kernel/mm/transparent_hugepage/ . You can monitor the
THP utilization system-wide with "grep Anon /proc/meminfo".

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog;h=refs/heads/anon_vma_chain

first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later: git fetch; git checkout -f origin/master
or to run the new anon_vma_chain: git fetch; git checkout -f origin/anon_vma_chain

I am currently running the origin/anon_vma_chain branch on all my
systems here (keeping master around only in case of troubles with the
new anon-vma code).

The tree is rebased and git pull won't work.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-25/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-25.gz
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34/transparent_hugepage-25-anon_vma_chain.gz

Diff #24 -> #25:

 b/exec-migrate-race-anon_vma-chain                       |  198 ++++++---------

Return to the cleaner fix that really allows the rmap_walk to succeed
at all times (and it also allows migrate and split_huge_page at all
times) without modifying the rmap_walk for this corner in execve. This
is also more robust for the long term in case the user stack starts
huge and we teach mremap to migrate without splitting hugepages (the
stack may have to be splitted by some other operation in the
VM).

 b/gfp_nomemalloc_wait                                    |   19 -

Fix: still clear ALLOC_CPUSET if the allocation is atomic.

 b/memory-compaction-anon-migrate-anon-vma-chain          |   49 +++
 b/memory-compaction-anon-vma-refcount-anon-vma-chain     |  161 ++++++++----
 b/memory-compaction-migrate-swapcache-anon-vma-chain     |  107 ++++++++
 memory-compaction-anon-vma-share-refcount-anon-vma-chain |  166 ------------

Fix: the anon_vma_chain branch must use drop_anon_vma to be safe with
the anon_vma->root->lock and avoid leaking root anon_vmas.

 b/pte_alloc_trans_splitting                              |   13 

use pmd_none instead of pmd_present in pte_alloc_map to be consistent
with __pte_alloc (pmd_none shall be a bit faster too, and it's
stricter too).

 b/transparent_hugepage                                   |   63 +++-

Race fix in initial huge pmd page fault (virtio-blk+THP was crashing
the host by running "cp /dev/vda /dev/null" in guest, with a 6G ram
guest and 4G ram + 4G swap host, immediately after host started
swapping). I never reproduced it with any other workload apparently so
it went unnoticed for a while (using the default ide emulation instead
of virtio-blk also didn't show any problem at all probably because of
different threading model or different timings). But it's not fixed.

 b/root_anon_vma-mm_take_all_locks                        |   81 ++++++

Prevent deadlock in root-anon-vma locking when registering in mmu
notifier (i.e. starting kvm, but it only has been triggering with
the -daemonize param for some reason, so it was unnoticed before as I
normally run kvm in the foreground).

Diffstat:

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
 fs/exec.c                             |   37 
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
 include/linux/mm.h                    |   92 +
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
 mm/huge_memory.c                      | 2172 ++++++++++++++++++++++++++++++++++
 mm/hugetlb.c                          |   69 -
 mm/ksm.c                              |   77 -
 mm/madvise.c                          |    8 
 mm/memcontrol.c                       |   88 -
 mm/memory-failure.c                   |    2 
 mm/memory.c                           |  196 ++-
 mm/memory_hotplug.c                   |   14 
 mm/mempolicy.c                        |   14 
 mm/migrate.c                          |   73 +
 mm/mincore.c                          |  302 ++--
 mm/mmap.c                             |   57 
 mm/mprotect.c                         |   20 
 mm/mremap.c                           |    8 
 mm/page_alloc.c                       |  133 +-
 mm/pagewalk.c                         |    1 
 mm/rmap.c                             |  181 ++
 mm/sparse.c                           |    4 
 mm/swap.c                             |  116 +
 mm/swap_state.c                       |    6 
 mm/swapfile.c                         |    2 
 mm/vmscan.c                           |   42 
 mm/vmstat.c                           |  256 +++-
 virt/kvm/iommu.c                      |    2 
 virt/kvm/kvm_main.c                   |   39 
 76 files changed, 5620 insertions(+), 522 deletions(-)

--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=gcc-align

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

--- /var/tmp/portage/sys-devel/gcc-4.4.2/work/gcc-4.4.2/gcc/ggc-page.c	2008=
-07-28 16:33:56.000000000 +0200
+++ /tmp/gcc-4.4.2/gcc/ggc-page.c	2010-04-25 06:01:32.829753566 +0200
@@ -450,6 +450,11 @@
 #define BITMAP_SIZE(Num_objects) \
   (CEIL ((Num_objects), HOST_BITS_PER_LONG) * sizeof(long))
=20
+#ifdef __x86_64__
+#define HPAGE_SIZE (2*1024*1024)
+#define GGC_QUIRE_SIZE 512
+#endif
+
 /* Allocate pages in chunks of this size, to throttle calls to memory
    allocation routines.  The first page is used, the rest go onto the
    free list.  This cannot be larger than HOST_BITS_PER_INT for the
@@ -654,6 +659,23 @@
 #ifdef HAVE_MMAP_ANON
   char *page =3D (char *) mmap (pref, size, PROT_READ | PROT_WRITE,
 			      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+#ifdef HPAGE_SIZE
+  if (!(size & (HPAGE_SIZE-1)) &&
+      page !=3D (char *) MAP_FAILED && (size_t) page & (HPAGE_SIZE-1)) {
+	  char *old_page;
+	  munmap(page, size);
+	  page =3D (char *) mmap (pref, size + HPAGE_SIZE-1,
+				PROT_READ | PROT_WRITE,
+				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	  old_page =3D page;
+	  page =3D (char *) (((size_t)page + HPAGE_SIZE-1)
+			   & ~(HPAGE_SIZE-1));
+	  if (old_page !=3D page)
+		  munmap(old_page, page-old_page);
+	  if (page !=3D old_page + HPAGE_SIZE-1)
+		  munmap(page+size, old_page+HPAGE_SIZE-1-page);
+  }
+#endif
 #endif
 #ifdef HAVE_MMAP_DEV_ZERO
   char *page =3D (char *) mmap (pref, size, PROT_READ | PROT_WRITE,

--ZPt4rx8FFjLCG7dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
