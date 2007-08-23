Received: by wa-out-1112.google.com with SMTP id n4so996214wag
        for <linux-mm@kvack.org>; Thu, 23 Aug 2007 02:47:44 -0700 (PDT)
Message-ID: <4df04b840708230247l69d03112lc5b66ff3359eac2@mail.gmail.com>
Date: Thu, 23 Aug 2007 17:47:44 +0800
From: "yunfeng zhang" <zyf.zeroos@gmail.com>
Subject: Re: [PATCH 2.6.20-rc5 1/1] MM: enhance Linux swap subsystem
In-Reply-To: <4df04b840702241747ne903699w636d37b40351b752@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4df04b840701212309l2a283357jbdaa88794e5208a7@mail.gmail.com>
	 <4df04b840701301852i41687edfl1462c4ca3344431c@mail.gmail.com>
	 <Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
	 <4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
	 <4df04b840702200106q670ff944k118d218fed17b884@mail.gmail.com>
	 <4df04b840702211758t1906083x78fb53b6283349ca@mail.gmail.com>
	 <45DCFDBE.50209@redhat.com>
	 <4df04b840702221831x76626de1rfa70cb653b12f495@mail.gmail.com>
	 <45DE6080.6030904@redhat.com>
	 <4df04b840702241747ne903699w636d37b40351b752@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

The mayor change is
1) Using nail arithmetic to maximum SwapDevice performance.
2) Add PG_pps bit to sign every pps page.
3) Some discussion about NUMA.
See vm_pps.txt

Index: linux-2.6.22/Documentation/vm_pps.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.22/Documentation/vm_pps.txt	2007-08-23 17:04:12.051837322 +0800
@@ -0,0 +1,365 @@
+
+                         Pure Private Page System (pps)
+                              zyf.zeroos@gmail.com
+                              December 24-26, 2006
+                            Revised on Aug 23, 2007
+
+// Purpose <([{
+The file is used to document the idea which is published firstly at
+http://www.ussg.iu.edu/hypermail/linux/kernel/0607.2/0451.html, as a part of my
+OS -- main page http://blog.chinaunix.net/u/21764/index.php. In brief, the
+patch of the document is for enchancing the performance of Linux swap
+subsystem. You can find the overview of the idea in section <How to Reclaim
+Pages more Efficiently> and how I patch it into Linux 2.6.21 in section
+<Pure Private Page System -- pps>.
+// }])>
+
+// How to Reclaim Pages more Efficiently <([{
+OK! to modern OS, its memory subsystem can be divided into three layers
+1) Space layer (InodeSpace, UserSpace and CoreSpace).
+2) VMA layer (PrivateVMA and SharedVMA, memory architecture-independent layer).
+3) Memory inode and zone layer (architecture-dependent).
+
+Since the 2nd layer assembles the much statistic of page-acess information, so
+it's nature that swap subsystem should be deployed and implemented on the 2nd
+layer.
+
+Undoubtedly, there are some virtues about it
+1) SwapDaemon can collect the statistic of process acessing pages and by it
+   unmaps ptes, SMP specially benefits from it for we can use flush_tlb_range
+   to unmap ptes batchly rather than frequently TLB IPI interrupt per a page in
+   current Linux legacy swap subsystem, and the idea I got (dftlb) even can do
+   it better.
+2) Page-fault can issue better readahead requests since history data shows all
+   related pages have conglomerating affinity. In contrast, Linux page-fault
+   readaheads the pages relative to the SwapSpace position of current
+   page-fault page.
+3) It's conformable to POSIX madvise API family.
+4) It simplifies Linux memory model dramatically. Keep it in mind that new swap
+   strategy is from up to down. In fact, Linux legacy swap subsystem is maybe
+   the only one from down to up.
+
+Unfortunately, Linux 2.6.21 swap subsystem is based on the 3rd layer -- a
+system on memory node::active_list/inactive_list.
+
+The patch I done is mainly described in section <Pure Private Page System --
+pps>.
+// }])>
+
+// Pure Private Page System -- pps  <([{
+As I've referred in previous section, perfectly applying my idea need to unroot
+page-surrounging swap subsystem to migrate it on VMA, but a huge gap has
+defeated me -- active_list and inactive_list. In fact, you can find
+lru_add_active code anywhere ... It's IMPOSSIBLE to me to complete it only by
+myself. It also brings a design challenge that page should be in the charge of
+its new owner totally, however, to Linux, page management system is still
+tracing it by PG_active flag.
+
+The patch I've made is based on PrivateVMA, exactly, a special case. Current
+Linux core supports a trick -- COW which is used by fork API, the API should be
+used rarely, POSIX thread library, vfork/execve are enough to application, but
+as the result, it potentially makes PrivatePage shared, so I think it's
+unnecessary to Linux, do copy-on-calling (COC) if someone really need CLONE_MM.
+My patch implements an independent page-recycle system rooted on Linux legacy
+page system -- pps abbreviates from Pure Private (page) system. pps intercept
+all private pages belonging to (Stack/Data)VMA into pps, then use my pps to
+cycle them. Keep it in mind it's a one-to-one model -- PrivateVMA, (PresentPTE,
+UnmappedPTE, SwappedPTE) and (PrivatePage, DiskSwapPage). In fact, my patch
+doesn't change fork API at all, alternatively, if someone calls it, I migrate
+all pps-page back to Linux in migrate_back_legacy_linux(). If Pure PrivateVMA
+can be accepted totally in Linux, it will bring additional virtues
+1) Not SwapCache at all. UnmappedPTE + PrivatePage IS SwapCache of Linux.
+2) swap_info_struct::swap_map should be bitmap other than currently (short
+   int)map.
+
+In fact, pps is centered on how to better collect and unmap process private
+pages, the whole process is divided into stages -- <Stage Definition> and a new
+arithmetic are described in <SwapEntry Nail Arithmetic>. pps uses
+init_mm::mm_list to enumerate all swappable UserSpace (shrink_private_vma).
+Other sections show the remain aspects of pps
+1) <Data Definition> is basic data definition.
+2) <Concurrent racers of Shrinking pps> is focused on synchronization.
+3) <VMA Lifecycle of pps> which VMA is belonging to pps.
+4) <PTE of pps> which pte types are active during pps.
+5) <Private Page Lifecycle of pps> how private pages enter in/go off pps.
+6) <New core daemon -- kppsd> new daemon thread kppsd.
+
+I'm also glad to highlight my a new idea -- dftlb which is described in
+section <Delay to Flush TLB>.
+// }])>
+
+// Delay to Flush TLB (dftlb) <([{
+Delay to flush TLB is instroduced by me to enhance flushing TLB efficiency, in
+brief, new idea makes flushing-TLBs in batch without EVEN pausing other CPUs.
+The whole sample is vmscan.c:fill_in_tlb_tasks>>end_dftlb. Note, target CPU
+must support
+1) atomic cmpxchg instruction.
+2) atomically set the access bit after CPU touches a pte firstly.
+
+And I still wonder if dftlb can work on other architectures, especially some
+non-x86 concepts -- invalidate mmu etc. So there is no guanrantee in my dftlb
+code and EVEN my idea.
+// }])>
+
+// Stage Definition <([{
+Every pte-page pair undergoes six stages which are defined in get_series_stage
+of mm/vmscan.c.
+1) Clear present bit of PresentPTE.
+2) Using flush_tlb_range or dftlb to flush the untouched PTEs.
+3) Link or re-link SwapEntry to PrivatePage (nail arithmetic).
+4) Flushing PrivatePage to its SwapPage.
+5) Reclaimed the page and shift UnmappedPTE to SwappedPTE.
+6) SwappedPTE stage (Null operation).
+
+Stages are dealt in shrink_pvma_scan_ptes, the function is called by global
+kppsd thread (stage 1-2) and kswpd of every inode (3-6). So to every pte-page
+pair, it's thread-safe in the whole shrink_pvma_scan_ptes internal. By the way,
+current series_t instance is placed to core stack totally, it's maybe too large
+to 4K core stack.
+// }])>
+
+// Data Definition <([{
+New VMA flag (VM_PURE_PRIVATE) is appended into VMA in include/linux/mm.h.
+The flag is set/clear in mm/memory.c:{enter_pps, leave_pps} when write-lock
+mmap.
+
+New PTE type (UnmappedPTE) is appended into PTE system in
+include/asm-i386/pgtable.h. Its prototype is
+struct UnmappedPTE {
+    int present : 1; // must be 0.
+    ...
+    int pageNum : 20;
+};
+The new PTE has a feature, it keeps a link to its PrivatePage and prevent the
+page from being visited by CPU, so in <Stage Definition> its relatted page can
+still be available in stage3-5 even it's unmapped in stage 2. pte_lock to shift
+it.
+
+New PG_pps flag in include/linux/page-flags.h.
+A page belonging to pps is or-ed a new flag PG_pps which is set/cleared in
+pps_page_{construction, destruction}. The flag should be set/cleared/tested in
+pte_lock if you've read-lock mmap_sem, an exception is get_series_stage of
+vmscan.c. Its relatting pte must be PresentPTE/UnmappedPTE. But its contrary
+isn't true, see next paragraph.
+
+UnmappedPTE + non-PG_ppsPage.
+In fact, it's possible that UnmappedPTE links a page without PG_pps flag, the
+case occurs in pps_swapin_readahead. When a page is readaheaded into pps, it's
+linked not only into Linux SwapCache but also its relatting PTE by UnmappedPTE.
+Meanwhile, the page isn't or-ed PG_pps flag, which is done in do_unmapped_page
+when page fault.
+
+Readheaded PPSPage and SwapCache
+pps excludes SwapCache at all, but to remove it is a heavy job to me since
+currently, not only fork API (or Shared PrivatePage) but also shmem are using
+it! So I must keep compatible with Linux legacy code, when
+memory.c:swapin_readahead readaheads DiskPages into SwapCache according to the
+offset of fault-page, it also links it into active-list in
+read_swap_cache_async, some of them maybe ARE ppspages! I places some code into
+do_swap_page and pps_swapin_readahead to remove it from zone::(in)active_list,
+but the code degrades system performance if there's a race. The case is PPSPage
+residents in memory and SwapCache without UnmappedPTE.
+
+PresentPTE + ReservedPage (ZeroPage).
+To relieve memory pressure, there's a COW case in pps, when a reading fault
+occurs on NullPTE, do_anonymous_page links a ZeroPage to the pte, the PPSPage
+are delayed to create in do_wp_page. Meanwhile, ZeroPage isn't or-ed PG_pps.
+It's the only case, pps system uses Linux legacy page directly.
+
+Linux struct page definition in pps.
+Most fields of struct page are unused. Currently, only flags, _count and
+private fields are active in pps. Other fields are still set to keep compatible
+with Linux. In fact, we can discard _count field safely, if core want to share
+the PrivatePage (get_user_page and pps_swapoff_scan_ptes), add a new PG_kmap
+bit to flags field; And pps excludes with swap cache. A recommended definition
+by me is
+struct pps_page {
+        int flags;
+        int unmapped_age; // An advised code in shrink_pvma_scan_ptes.
+        swp_entry_t swp;
+        // the PG_lock/PG_writeback wait queue of the page.
+        wait_queue_head_t wq;
+        slist freePages; // (*)
+}
+*) Single list is enough to pps-page, when the page is flushed by pps_stage4,
+we can link it into a slist queue to make page-reclamation quicklier.
+
+New fields nr_pps_total, nr_present_pte, nr_unmapped_pte and nr_swapped_pte are
+appended into mmzone.h:pglist_data to trace the statistic of pps, which are
+outputed to /proc/zoneinfo in mm/vmstat.c.
+// }])>
+
+// Concurrent Racers of pps <([{
+shrink_private_vma of mm/vmscan.c uses init_mm.mmlist to scan all swappable
+mm_struct instances, during the process of scaning and reclamation, it
+readlocks mm_struct::mmap_sem, which brings some potential concurrent racers
+1) mm/swapfile.c pps_swapoff    (swapoff API)
+2) mm/memory.c   do_{anonymous, unmapped, wp, swap}_page (page-fault)
+3) mm/memory.c   get_user_pages (sometimes core need share PrivatePage with us)
+4) mm/vmscan.c   balance_pgdat  (kswapd/x can do stage 3-5 of its node pages,
+   while kppsd can do stage 1-2)
+5) mm/vmscan.c   kppsd          (new core daemon -- kppsd, see below)
+6) mm/migrate.c  ---            (migrate_entry is a special SwappedPTE, do
+   stage 6-1 and I didn't finish the job yet due to hardware restriction)
+
+Other cases making influence on pps are
+writelocks mmap_sem
+1) mm/memory.c   zap_pte_range  (free pages)
+2) mm/memory.c   migrate_back_legacy_linux  (exit from pps to Linux when fork)
+
+No influence on mmap_sem.
+1) mm/page_io.c  end_swap_bio_write (device asynchronous writeIO callback)
+2) mm/page_io.c  end_swap_bio_read (device asynchronous readIO callback)
+
+There isn't new lock order defined in pps, that is, it's compliable to Linux
+lock order. Locks in shrink_private_vma copied from shrink_list of 2.6.16.29
+(my initial version). The only exception is in pps_shrink_pgdata about locking
+the former and later pages of a series.
+// }])>
+
+// New core daemon -- kppsd <([{
+A new kernel thread -- kppsd is introduced in kppsd(void*) of mm/vmscan.c to
+unmap PrivatePage from its UnmappedPTE, it runs periodically.
+
+Two pps strategies are present for NUMA and UMA respectively. To UMA, pps
+daemon do stage 1-4, kswapd/x do stage 5. To NUMA, pps do stage 1-2 only,
+kswapd/x do stage 3-5 by pps lists of pglist_data. All are controlled by
+delivering pps command of scan_control to shrink_private_vma. Current only the
+later is completed.
+
+shrink_private_vma can be controlled by new fields -- reclaim_node and is_kppsd
+of scan_control. reclaim_node = (node number, -1 means all memory inode) is
+used when a memory node is low. Caller (kswapd/x), typically, set reclaim_node
+to make shrink_private_vma (vmscan.c:balance_pgdat) flushing and reclaiming
+pages. Note, only to kppsd is_kppsd = 1. Other alive legacy fields to pps are
+gfp_mask, may_writepage and may_swap.
+
+When a memory inode is low, kswapd/x can wake up kppsd and accelerate it by
+increasing global variable accelerate_kppsd (vmscan.c:balance_pgdat).
+
+To kppsd, it isn't all that unmaps PrivateVMA in shrink_private_vma, there're
+more tasks to be done (unimplemented)
+1) Some application maybe shows its memory inode affinity by mbind API, to pps
+   system, it's recommended to do the migration task at stage 2.
+2) If a memory inode is low, let's immediately migrate the page to other memory
+   inode at stage 2 -- balance NUMA memory inode.
+3) In fact, not only Pure PrivateVMA, Other SharedVMAs can also be scanned and
+   unmapped.
+4) madvise API-flag can be dealed here.
+1 and 2 can be implemented only when target CPU supports dftlb.
+// }])>
+
+// VMA Lifecycle of pps <([{
+When a PrivateVMA enters into pps, it's or-ed a new flag -- VM_PURE_PRIVATE in
+memory.c:enter_pps, you can also find which VMAs are fit with pps in it. The
+flag is used mainly in the shrink_private_vma of mm/vmscan.c. Other fields are
+left untouched.
+
+IN.
+1) fs/exec.c    setup_arg_pages         (StackVMA)
+2) mm/mmap.c    do_mmap_pgoff, do_brk   (DataVMA)
+3) mm/mmap.c    split_vma, copy_vma     (in some cases, we need copy a VMA from
+   an exist VMA)
+
+OUT.
+1) kernel/fork.c   dup_mmap               (if someone uses fork, return the vma
+   back to Linux legacy system)
+2) mm/mmap.c       remove_vma, vma_adjust (destroy VMA)
+3) mm/mmap.c       do_mmap_pgoff          (delete VMA when some errors occur)
+
+The VMAs of pps can coexist with madvise, mlock, mprotect, mmap and munmap,
+that is why new VMA created from mmap.c:split_vma can re-enter into pps.
+// }])>
+
+// PTE of pps <([{
+Active pte types are NullPTE, PresentPTE, UntouchedPTE, UnmappedPTE and
+SwappedPTE in pps.
+
+1) page-fault   {NullPTE, UnmappedPTE} >> PresentPTE    (Other such as
+   get_user_pages, pps_swapoff etc. also use page-fault indirectly)
+2) shrink_pvma_scan_ptes   PresentPTE >> UntouchedPTE >> UnmappedPTE >>
+   SwappedPTE   (In fact, the whole process is done by kppsd and kswapX
+   individually)
+3) -   MigrateEntryPTE >> PresentPTE   (migrate pages between memory inodes)
+// }])>
+
+// Private Page Lifecycle of pps <([{
+All pages belonging to pps are called as pure private page, its PTE type is
+PresentPTE or UnmappedPTE. Note, Linux fork API potentially make PrivatePage
+shared by multiple processes, so is excluded from pps.
+
+IN (NOTE, when a pure private page enters into pps, it's also trimmed from
+Linux legacy page system by commeting lru_cache_add_active clause)
+1) fs/exec.c    install_arg_page    (argument pages)
+2) mm/memory.c  do_{anonymous, unmapped, wp, swap}_page (page fault)
+3) mm/memory.c    pps_swapin_readahead    (readahead swap-pages) (*)
+*) In fact, it ins't exactly a ppspage, see <Data Definition>.
+
+OUT
+1) mm/vmscan.c  pps_stage5              (stage 5, reclaim a private page)
+2) mm/memory.c  zap_pte_range           (free a page)
+3) kernel/fork.c    dup_mmap>>leave_pps (if someone uses fork, migrate all pps
+   pages back to let Linux legacy page system manage them)
+4) mm/memory.c  do_{unmapped, swap}_page  (swapin pages encounter IO error) (*)
+*) In fact, it ins't exactly a ppspage, see <Data Definition>.
+
+struct pps_page in <Data Definition> has a pair of
+pps_page_(contruction/destruction) in memory.c. They're used to shift different
+fields between page and pps_page.
+// }])>
+
+// pps and NUMA <([{
+New memory model brings an up-to-down scanning strategy. The advantages of its
+are unmapping ptes batchly by flush_tlb_range or even dftlb and using nail
+arithmetic to manage SwapSpace. But to NUMA it's another pair of shoes.
+
+On NUMA, to balance memory inode, MPOL_INTERLEAVE policy is used in default,
+but the policy also scatters MemoryInodePage anywhere, so when an inode is low,
+new scanning strategy makes Linux unmap the whole page tables to reclaim THE
+inode to SwapDevice, which brings heavy pressure to SwapSpace.
+
+Here a new policy is recommended -- MPOL_STRIPINTERLEAVE, see mm/mempolicy.c.
+The policy tries to establish a strip-like region between linear-address and
+InodeSpace other than MPOL_(LINE)INTERLEAVE currently to make scanning and
+flushing more affinity. The disadvantages are
+1) The relationship can be broken easily by user by calling mbind with
+   different inodes-set.
+2) To page-fault, to maintain the fix relationship, new page must be allocated
+   from the referred memory inode even it's low.
+3) Note, to StackVMA (fs/exec.c:install_arg_page), the last pages are argument
+   pages, which maybe isn't belonging to our target memory-inode.
+
+Another policy is balancing memory inodes by dftlb in <kppsd> section.
+// }])>
+
+// SwapEntry Nail Arithmetic <([{
+Nail arithmetic is introduced by me to enhance the efficience of SwapSubsystem.
+There's no mysterious about it, in brief, to a typical series, some members of
+it are SwappedPTE (called nail SwapEntry), then other members should be
+relinked SwapEntries around these SwappedPTEs. The arithmetic is based on that
+the pages of the same series have a conglomerating affinity. Another virtue is
+the arithmetic also minimizes the fragment of SwapDevice.
+
+The arithmetic is mainly divided into two parts -- vmscan.c:{pps_shrink_pgdata,
+pps_stage3}.
+1) To pps_shrink_pgdata, its first task is cataloging the items of a series
+   into two genres, one called 'nail' represents their swap entries cann't be
+   re-allocated currently, other called 'realloc_pages' which should be
+   allocated again around the nails. Another task is maintaining
+   pglist_data::last_nail_swp which is used to extend the continuity of the
+   former series to the later. I also highlight series continuity rules which
+   is described in the function.
+2) To pps_stage3, it and its followers calc_realloc and realloc_around_nails
+   (re-)allocate swapentries for realloc_pages around nail_swps.
+
+I also append some new APIs in swap_state.c:pps_relink_swp and
+swapfile.c:{swap_try_alloc_batchly, swap_alloc_around_nail, swap_alloc_batchly,
+swap_free_batchly, scan_swap_map_batchly} to cater to the arithmetic. shm
+should also benefit from these APIs.
+// }])>
+
+// Miscellaneous <([{
+Due to hardware restriction, migrating between memory-inodes or migrate-entry
+aren't be completed!
+// }])>
+// vim: foldmarker=<([{,}])> foldmethod=marker et
Index: linux-2.6.22/fs/exec.c
===================================================================
--- linux-2.6.22.orig/fs/exec.c	2007-08-23 15:26:44.374380322 +0800
+++ linux-2.6.22/fs/exec.c	2007-08-23 15:30:09.555203322 +0800
@@ -326,11 +326,10 @@
 		pte_unmap_unlock(pte, ptl);
 		goto out;
 	}
+	pps_page_construction(page, vma, address);
 	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
-	page_add_new_anon_rmap(page, vma, address);
+	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(page,
+			    vma->vm_page_prot))));
 	pte_unmap_unlock(pte, ptl);

 	/* no need for flush_tlb */
@@ -440,6 +439,7 @@
 			kmem_cache_free(vm_area_cachep, mpnt);
 			return ret;
 		}
+		enter_pps(mm, mpnt);
 		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
 	}

Index: linux-2.6.22/include/asm-i386/pgtable-2level.h
===================================================================
--- linux-2.6.22.orig/include/asm-i386/pgtable-2level.h	2007-08-23
15:26:44.398381822 +0800
+++ linux-2.6.22/include/asm-i386/pgtable-2level.h	2007-08-23
15:30:09.559203572 +0800
@@ -73,21 +73,22 @@
 }

 /*
- * Bits 0, 6 and 7 are taken, split up the 29 bits of offset
+ * Bits 0, 5, 6 and 7 are taken, split up the 28 bits of offset
  * into this range:
  */
-#define PTE_FILE_MAX_BITS	29
+#define PTE_FILE_MAX_BITS	28

 #define pte_to_pgoff(pte) \
-	((((pte).pte_low >> 1) & 0x1f ) + (((pte).pte_low >> 8) << 5 ))
+	((((pte).pte_low >> 1) & 0xf ) + (((pte).pte_low >> 8) << 4 ))

 #define pgoff_to_pte(off) \
-	((pte_t) { (((off) & 0x1f) << 1) + (((off) >> 5) << 8) + _PAGE_FILE })
+	((pte_t) { (((off) & 0xf) << 1) + (((off) >> 4) << 8) + _PAGE_FILE })

 /* Encode and de-code a swap entry */
-#define __swp_type(x)			(((x).val >> 1) & 0x1f)
+#define __swp_type(x)			(((x).val >> 1) & 0xf)
 #define __swp_offset(x)			((x).val >> 8)
-#define __swp_entry(type, offset)	((swp_entry_t) { ((type) << 1) |
((offset) << 8) })
+#define __swp_entry(type, offset)	((swp_entry_t) { ((type & 0xf) << 1) |\
+	((offset) << 8) | _PAGE_SWAPPED })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { (pte).pte_low })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })

Index: linux-2.6.22/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.22.orig/include/asm-i386/pgtable.h	2007-08-23
15:26:44.422383322 +0800
+++ linux-2.6.22/include/asm-i386/pgtable.h	2007-08-23 15:30:09.559203572 +0800
@@ -120,7 +120,11 @@
 #define _PAGE_UNUSED3	0x800

 /* If _PAGE_PRESENT is clear, we use these: */
-#define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
+#define _PAGE_UNMAPPED	0x020	/* a special PTE type, hold its page reference
+				   even it's unmapped, see more from
+				   Documentation/vm_pps.txt. */
+#define _PAGE_SWAPPED 0x040 /* swapped PTE. */
+#define _PAGE_FILE	0x060	/* nonlinear file mapping, saved PTE; */
 #define _PAGE_PROTNONE	0x080	/* if the user mapped it with PROT_NONE;
 				   pte_present gives true */
 #ifdef CONFIG_X86_PAE
@@ -228,7 +232,12 @@
 /*
  * The following only works if pte_present() is not true.
  */
-static inline int pte_file(pte_t pte)		{ return (pte).pte_low & _PAGE_FILE; }
+static inline int pte_unmapped(pte_t pte)	{ return ((pte).pte_low & 0x60)
+    == _PAGE_UNMAPPED; }
+static inline int pte_swapped(pte_t pte)	{ return ((pte).pte_low & 0x60)
+    == _PAGE_SWAPPED; }
+static inline int pte_file(pte_t pte)		{ return ((pte).pte_low & 0x60)
+    == _PAGE_FILE; }

 static inline pte_t pte_rdprotect(pte_t pte)	{ (pte).pte_low &=
~_PAGE_USER; return pte; }
 static inline pte_t pte_exprotect(pte_t pte)	{ (pte).pte_low &=
~_PAGE_USER; return pte; }
@@ -241,6 +250,7 @@
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |=
_PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |=
_PAGE_RW; return pte; }
 static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |=
_PAGE_PSE; return pte; }
+static inline pte_t pte_mkunmapped(pte_t pte)	{ (pte).pte_low &=
~(_PAGE_PRESENT + 0x60); (pte).pte_low |= _PAGE_UNMAPPED; return pte;
}

 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
Index: linux-2.6.22/include/linux/mm.h
===================================================================
--- linux-2.6.22.orig/include/linux/mm.h	2007-08-23 15:26:44.450385072 +0800
+++ linux-2.6.22/include/linux/mm.h	2007-08-23 15:30:09.559203572 +0800
@@ -169,6 +169,9 @@
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
 #define VM_INSERTPAGE	0x02000000	/* The vma has had
"vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
+#define VM_PURE_PRIVATE	0x08000000	/* Is the vma is only belonging to a mm,
+									   see more from Documentation/vm_pps.txt
+									   */

 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -1210,5 +1213,16 @@

 __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma);

+void enter_pps(struct mm_struct* mm, struct vm_area_struct* vma);
+void leave_pps(struct vm_area_struct* vma, int migrate_flag);
+void pps_page_construction(struct page* page, struct vm_area_struct* vma,
+	unsigned long address);
+void pps_page_destruction(struct page* ppspage, struct vm_area_struct* vma,
+	unsigned long address, int migrate);
+
+#define numa_addr_to_nid(vma, addr) (0)
+
+#define SERIES_LENGTH 8
+#define SERIES_BOUND (SERIES_LENGTH + 1) // used for array declaration.
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
Index: linux-2.6.22/include/linux/mmzone.h
===================================================================
--- linux-2.6.22.orig/include/linux/mmzone.h	2007-08-23 15:26:44.470386322 +0800
+++ linux-2.6.22/include/linux/mmzone.h	2007-08-23 15:30:09.559203572 +0800
@@ -452,6 +452,15 @@
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
+
+	// pps fields, see Documentation/vm_pps.txt.
+	unsigned long last_nail_addr;
+	int last_nail_swp_type;
+	int last_nail_swp_offset;
+	atomic_t nr_pps_total; // = nr_present_pte + nr_unmapped_pte.
+	atomic_t nr_present_pte;
+	atomic_t nr_unmapped_pte;
+	atomic_t nr_swapped_pte;
 } pg_data_t;

 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
Index: linux-2.6.22/include/linux/page-flags.h
===================================================================
--- linux-2.6.22.orig/include/linux/page-flags.h	2007-08-23
15:26:44.494387822 +0800
+++ linux-2.6.22/include/linux/page-flags.h	2007-08-23 15:30:09.559203572 +0800
@@ -90,6 +90,8 @@
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_buddy		19	/* Page is free, on buddy lists */

+#define PG_pps			20	/* See Documentation/vm_pps.txt */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */

@@ -282,4 +284,8 @@
 	test_set_page_writeback(page);
 }

+// Hold PG_locked to set/clear PG_pps.
+#define PagePPS(page)		test_bit(PG_pps, &(page)->flags)
+#define SetPagePPS(page)	set_bit(PG_pps, &(page)->flags)
+#define ClearPagePPS(page)	clear_bit(PG_pps, &(page)->flags)
 #endif	/* PAGE_FLAGS_H */
Index: linux-2.6.22/include/linux/swap.h
===================================================================
--- linux-2.6.22.orig/include/linux/swap.h	2007-08-23 15:26:44.514389072 +0800
+++ linux-2.6.22/include/linux/swap.h	2007-08-23 15:30:09.559203572 +0800
@@ -227,6 +227,7 @@
 #define total_swapcache_pages  swapper_space.nrpages
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *, gfp_t);
+extern int pps_relink_swp(struct page*, swp_entry_t, swp_entry_t**);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern int move_to_swap_cache(struct page *, swp_entry_t);
@@ -238,6 +239,10 @@
 extern struct page * read_swap_cache_async(swp_entry_t, struct
vm_area_struct *vma,
 					   unsigned long addr);
 /* linux/mm/swapfile.c */
+extern void swap_free_batchly(swp_entry_t*);
+extern void swap_alloc_around_nail(swp_entry_t, int, swp_entry_t*);
+extern int swap_try_alloc_batchly(swp_entry_t, int, swp_entry_t*);
+extern int swap_alloc_batchly(int, swp_entry_t*, int);
 extern long total_swap_pages;
 extern unsigned int nr_swapfiles;
 extern void si_swapinfo(struct sysinfo *);
Index: linux-2.6.22/include/linux/swapops.h
===================================================================
--- linux-2.6.22.orig/include/linux/swapops.h	2007-08-23
15:26:44.538390572 +0800
+++ linux-2.6.22/include/linux/swapops.h	2007-08-23 15:30:09.559203572 +0800
@@ -50,7 +50,7 @@
 {
 	swp_entry_t arch_entry;

-	BUG_ON(pte_file(pte));
+	BUG_ON(!pte_swapped(pte));
 	arch_entry = __pte_to_swp_entry(pte);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
@@ -64,7 +64,7 @@
 	swp_entry_t arch_entry;

 	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
-	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
+	BUG_ON(!pte_swapped(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }

Index: linux-2.6.22/kernel/fork.c
===================================================================
--- linux-2.6.22.orig/kernel/fork.c	2007-08-23 15:26:44.562392072 +0800
+++ linux-2.6.22/kernel/fork.c	2007-08-23 15:30:09.559203572 +0800
@@ -241,6 +241,7 @@
 		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (!tmp)
 			goto fail_nomem;
+		leave_pps(mpnt, 1);
 		*tmp = *mpnt;
 		pol = mpol_copy(vma_policy(mpnt));
 		retval = PTR_ERR(pol);
Index: linux-2.6.22/mm/fremap.c
===================================================================
--- linux-2.6.22.orig/mm/fremap.c	2007-08-23 15:26:44.582393322 +0800
+++ linux-2.6.22/mm/fremap.c	2007-08-23 15:30:09.563203822 +0800
@@ -37,7 +37,7 @@
 			page_cache_release(page);
 		}
 	} else {
-		if (!pte_file(pte))
+		if (pte_swapped(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
 		pte_clear_not_present_full(mm, addr, ptep, 0);
 	}
Index: linux-2.6.22/mm/memory.c
===================================================================
--- linux-2.6.22.orig/mm/memory.c	2007-08-23 15:26:44.602394572 +0800
+++ linux-2.6.22/mm/memory.c	2007-08-23 15:30:09.563203822 +0800
@@ -435,7 +435,7 @@

 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
-		if (!pte_file(pte)) {
+		if (pte_swapped(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);

 			swap_duplicate(entry);
@@ -628,6 +628,7 @@
 	spinlock_t *ptl;
 	int file_rss = 0;
 	int anon_rss = 0;
+	struct pglist_data* node_data;

 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -637,6 +638,7 @@
 			(*zap_work)--;
 			continue;
 		}
+		node_data = NODE_DATA(numa_addr_to_nid(vma, addr));

 		(*zap_work) -= PAGE_SIZE;

@@ -672,6 +674,15 @@
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
+			if (vma->vm_flags & VM_PURE_PRIVATE) {
+				if (page != ZERO_PAGE(addr)) {
+					pps_page_destruction(page,vma,addr,0);
+					if (PageWriteback(page)) // WriteIOing.
+						lru_cache_add_active(page);
+					atomic_dec(&node_data->nr_present_pte);
+				}
+			} else
+				page_remove_rmap(page, vma);
 			if (PageAnon(page))
 				anon_rss--;
 			else {
@@ -681,7 +692,6 @@
 					SetPageReferenced(page);
 				file_rss--;
 			}
-			page_remove_rmap(page, vma);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -691,8 +701,31 @@
 		 */
 		if (unlikely(details))
 			continue;
-		if (!pte_file(ptent))
+		if (pte_unmapped(ptent)) {
+			struct page* page = pfn_to_page(pte_pfn(ptent));
+			BUG_ON(page == ZERO_PAGE(addr));
+			if (PagePPS(page)) {
+				pps_page_destruction(page, vma, addr, 0);
+				atomic_dec(&node_data->nr_unmapped_pte);
+				tlb_remove_page(tlb, page);
+			} else {
+				swp_entry_t entry;
+				entry.val = page_private(page);
+				atomic_dec(&node_data->nr_swapped_pte);
+				if (PageLocked(page)) // ReadIOing.
+					lru_cache_add_active(page);
+				else
+					free_swap_and_cache(entry);
+			}
+			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+			anon_rss--;
+			continue;
+		}
+		if (pte_swapped(ptent)) {
+			if (vma->vm_flags & VM_PURE_PRIVATE)
+				atomic_dec(&node_data->nr_swapped_pte);
 			free_swap_and_cache(pte_to_swp_entry(ptent));
+		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));

@@ -955,7 +988,8 @@
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
 			set_page_dirty(page);
-		mark_page_accessed(page);
+		if (!(vma->vm_flags & VM_PURE_PRIVATE))
+			mark_page_accessed(page);
 	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
@@ -1745,8 +1779,11 @@
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
-		page_add_new_anon_rmap(new_page, vma, address);
+		if (!(vma->vm_flags & VM_PURE_PRIVATE)) {
+			lru_cache_add_active(new_page);
+			page_add_new_anon_rmap(new_page, vma, address);
+		} else
+			pps_page_construction(new_page, vma, address);

 		/* Free the old page.. */
 		new_page = old_page;
@@ -2082,7 +2119,7 @@
 	for (i = 0; i < num; offset++, i++) {
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(swp_entry(swp_type(entry),
-							   offset), vma, addr);
+			    offset), vma, addr);
 		if (!new_page)
 			break;
 		page_cache_release(new_page);
@@ -2111,6 +2148,156 @@
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 }

+static pte_t* pte_offsetof_base(struct vm_area_struct* vma, pte_t* base,
+		unsigned long base_addr, int offset_index)
+{
+	unsigned long offset_addr;
+	offset_addr = base_addr + offset_index * PAGE_SIZE;
+	if (offset_addr < vma->vm_start || offset_addr >= vma->vm_end)
+		return NULL;
+	if (pgd_index(offset_addr) != pgd_index(base_addr))
+		return NULL;
+	// if (pud_index(offset_addr) != pud_index(base_addr))
+	// 	return NULL;
+	if (pmd_index(offset_addr) != pmd_index(base_addr))
+		return NULL;
+	return base - pte_index(base_addr) + pte_index(offset_addr);
+}
+
+/*
+ * New read ahead code, mainly for VM_PURE_PRIVATE only.
+ */
+static void pps_swapin_readahead(swp_entry_t entry, unsigned long addr, struct
+	vm_area_struct *vma, pte_t* pte, pmd_t* pmd)
+{
+	struct zone* zone;
+	struct page* page;
+	pte_t *prev, *next, orig, pte_unmapped;
+	swp_entry_t temp;
+	int swapType = swp_type(entry);
+	int swapOffset = swp_offset(entry);
+	int readahead = 0, i;
+	spinlock_t *ptl = pte_lockptr(vma->vm_mm, pmd);
+	unsigned long addr_temp;
+
+	if (!(vma->vm_flags & VM_PURE_PRIVATE)) {
+		swapin_readahead(entry, addr, vma);
+		return;
+	}
+
+	page = read_swap_cache_async(entry, vma, addr);
+	if (!page)
+		return;
+	page_cache_release(page);
+	lru_add_drain();
+
+	// pps readahead, first forward then backward, the whole range is +/-
+	// 16 ptes around fault-pte but at most 8 pages are readaheaded.
+	//
+	// The best solution is readaheading fault-cacheline +
+	// prev/next-cacheline. But I don't know how to get the size of
+	// CPU-cacheline.
+	//
+	// New readahead strategy is for the case -- PTE/UnmappedPTE is mixing
+	// with SwappedPTE which means the VMA is accessed randomly, so we
+	// don't stop when encounter a PTE/UnmappedPTE but continue to scan,
+	// all SwappedPTEs which close to fault-pte are readaheaded.
+	for (i = 1; i <= 16 && readahead < 8; i++) {
+		next = pte_offsetof_base(vma, pte, addr, i);
+		if (next == NULL)
+			break;
+		orig = *next;
+		if (pte_none(orig) || pte_present(orig) || !pte_swapped(orig))
+			continue;
+		temp = pte_to_swp_entry(orig);
+		if (swp_type(temp) != swapType)
+			continue;
+		if (abs(swp_offset(temp) - swapOffset) > 32)
+			// the two swap entries are too far, give up!
+			continue;
+		addr_temp = addr + i * PAGE_SIZE;
+		page = read_swap_cache_async(temp, vma, addr_temp);
+		if (!page)
+			return;
+		lru_add_drain();
+		// Add the page into pps, first remove it from (in)activelist.
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		while (1) {
+			if (!PageLRU(page)) {
+				// Shit! vmscan.c:isolate_lru_page is working
+				// on it!
+				spin_unlock_irq(&zone->lru_lock);
+				cond_resched();
+				spin_lock_irq(&zone->lru_lock);
+			} else {
+				list_del(&page->lru);
+				ClearPageActive(page);
+				ClearPageLRU(page);
+				break;
+			}
+		}
+		spin_unlock_irq(&zone->lru_lock);
+		page_cache_release(page);
+		pte_unmapped = mk_pte(page, vma->vm_page_prot);
+		pte_unmapped.pte_low &= ~_PAGE_PRESENT;
+		pte_unmapped.pte_low |= _PAGE_UNMAPPED;
+		spin_lock(ptl);
+		if (unlikely(pte_same(*next, orig))) {
+			set_pte_at(vma->vm_mm, addr_temp, next, pte_unmapped);
+			readahead++;
+		}
+		spin_unlock(ptl);
+	}
+	for (i = -1; i >= -16 && readahead < 8; i--) {
+		prev = pte_offsetof_base(vma, pte, addr, i);
+		if (prev == NULL)
+			break;
+		orig = *prev;
+		if (pte_none(orig) || pte_present(orig) || !pte_swapped(orig))
+			continue;
+		temp = pte_to_swp_entry(orig);
+		if (swp_type(temp) != swapType)
+			continue;
+		if (abs(swp_offset(temp) - swapOffset) > 32)
+			// the two swap entries are too far, give up!
+			continue;
+		addr_temp = addr + i * PAGE_SIZE;
+		page = read_swap_cache_async(temp, vma, addr_temp);
+		if (!page)
+			return;
+		lru_add_drain();
+		// Add the page into pps, first remove it from (in)activelist.
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		while (1) {
+			if (!PageLRU(page)) {
+				// Shit! vmscan.c:isolate_lru_page is working
+				// on it!
+				spin_unlock_irq(&zone->lru_lock);
+				cond_resched();
+				spin_lock_irq(&zone->lru_lock);
+			} else {
+				list_del(&page->lru);
+				ClearPageActive(page);
+				ClearPageLRU(page);
+				break;
+			}
+		}
+		spin_unlock_irq(&zone->lru_lock);
+		page_cache_release(page);
+		pte_unmapped = mk_pte(page, vma->vm_page_prot);
+		pte_unmapped.pte_low &= ~_PAGE_PRESENT;
+		pte_unmapped.pte_low |= _PAGE_UNMAPPED;
+		spin_lock(ptl);
+		if (unlikely(pte_same(*prev, orig))) {
+			set_pte_at(vma->vm_mm, addr_temp, prev, pte_unmapped);
+			readahead++;
+		}
+		spin_unlock(ptl);
+	}
+}
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2125,6 +2312,7 @@
 	swp_entry_t entry;
 	pte_t pte;
 	int ret = VM_FAULT_MINOR;
+	struct pglist_data* node_data;

 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2138,7 +2326,7 @@
 	page = lookup_swap_cache(entry);
 	if (!page) {
 		grab_swap_token(); /* Contend for token _before_ read-in */
- 		swapin_readahead(entry, address, vma);
+		pps_swapin_readahead(entry, address, vma, page_table, pmd);
  		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
 			/*
@@ -2161,6 +2349,26 @@
 	mark_page_accessed(page);
 	lock_page(page);

+	if (vma->vm_flags & VM_PURE_PRIVATE) {
+		// Add the page into pps, first remove it from (in)activelist.
+		struct zone* zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		while (1) {
+			if (!PageLRU(page)) {
+				// Shit! vmscan.c:isolate_lru_page is working
+				// on it!
+				spin_unlock_irq(&zone->lru_lock);
+				cond_resched();
+				spin_lock_irq(&zone->lru_lock);
+			} else {
+				list_del(&page->lru);
+				ClearPageActive(page);
+				ClearPageLRU(page);
+				break;
+			}
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
@@ -2170,6 +2378,8 @@

 	if (unlikely(!PageUptodate(page))) {
 		ret = VM_FAULT_SIGBUS;
+		if (vma->vm_flags & VM_PURE_PRIVATE)
+			lru_cache_add_active(page);
 		goto out_nomap;
 	}

@@ -2181,15 +2391,25 @@
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		write_access = 0;
 	}
+	if (vma->vm_flags & VM_PURE_PRIVATE) {
+		// To pps, there's no copy-on-write (COW).
+		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		write_access = 0;
+	}

 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
-	page_add_anon_rmap(page, vma, address);

 	swap_free(entry);
 	if (vm_swap_full())
 		remove_exclusive_swap_page(page);
 	unlock_page(page);
+	if (vma->vm_flags & VM_PURE_PRIVATE) {
+		node_data = NODE_DATA(page_to_nid(page));
+		pps_page_construction(page, vma, address);
+		atomic_dec(&node_data->nr_swapped_pte);
+	} else
+		page_add_anon_rmap(page, vma, address);

 	if (write_access) {
 		if (do_wp_page(mm, vma, address,
@@ -2241,9 +2461,12 @@
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto release;
+		if (!(vma->vm_flags & VM_PURE_PRIVATE)) {
+			lru_cache_add_active(page);
+			page_add_new_anon_rmap(page, vma, address);
+		} else
+			pps_page_construction(page, vma, address);
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
-		page_add_new_anon_rmap(page, vma, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
@@ -2508,6 +2731,76 @@
 	return VM_FAULT_MAJOR;
 }

+// pps special page-fault route, see Documentation/vm_pps.txt.
+static int do_unmapped_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access, pte_t orig_pte)
+{
+	spinlock_t* ptl = pte_lockptr(mm, pmd);
+	pte_t pte;
+	int ret = VM_FAULT_MINOR;
+	struct page* page;
+	swp_entry_t entry;
+	struct pglist_data* node_data;
+	BUG_ON(!(vma->vm_flags & VM_PURE_PRIVATE));
+
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*page_table, orig_pte)))
+		goto unlock;
+	page = pte_page(*page_table);
+	node_data = NODE_DATA(page_to_nid(page));
+	if (PagePPS(page)) {
+		// The page is a pure UnmappedPage done by pps_stage2.
+		pte = mk_pte(page, vma->vm_page_prot);
+		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		flush_icache_page(vma, page);
+		set_pte_at(mm, address, page_table, pte);
+		update_mmu_cache(vma, address, pte);
+		lazy_mmu_prot_update(pte);
+		atomic_dec(&node_data->nr_unmapped_pte);
+		atomic_inc(&node_data->nr_present_pte);
+		goto unlock;
+	}
+	entry.val = page_private(page);
+	page_cache_get(page);
+	spin_unlock(ptl);
+	// The page is a readahead page.
+	lock_page(page);
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*page_table, orig_pte)))
+		goto out_nomap;
+	if (unlikely(!PageUptodate(page))) {
+		ret = VM_FAULT_SIGBUS;
+		// If we encounter an IO error, unlink the page from
+		// UnmappedPTE to SwappedPTE to let Linux recycles it.
+		set_pte_at(mm, address, page_table, swp_entry_to_pte(entry));
+		lru_cache_add_active(page);
+		goto out_nomap;
+	}
+	inc_mm_counter(mm, anon_rss);
+	pte = mk_pte(page, vma->vm_page_prot);
+	pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+	flush_icache_page(vma, page);
+	set_pte_at(mm, address, page_table, pte);
+	pps_page_construction(page, vma, address);
+	swap_free(entry);
+	if (vm_swap_full())
+		remove_exclusive_swap_page(page);
+	update_mmu_cache(vma, address, pte);
+	lazy_mmu_prot_update(pte);
+	atomic_dec(&node_data->nr_swapped_pte);
+	unlock_page(page);
+
+unlock:
+	pte_unmap_unlock(page_table, ptl);
+	return ret;
+out_nomap:
+	pte_unmap_unlock(page_table, ptl);
+	unlock_page(page);
+	page_cache_release(page);
+	return ret;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -2530,6 +2823,9 @@

 	entry = *pte;
 	if (!pte_present(entry)) {
+		if (pte_unmapped(entry))
+			return do_unmapped_page(mm, vma, address, pte, pmd,
+					write_access, entry);
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (vma->vm_ops->nopage)
@@ -2817,3 +3113,147 @@

 	return buf - old_buf;
 }
+
+static void migrate_back_pte_range(struct mm_struct* mm, pmd_t *pmd, struct
+		vm_area_struct *vma, unsigned long addr, unsigned long end)
+{
+	struct page* page;
+	swp_entry_t swp;
+	pte_t entry;
+	pte_t *pte;
+	spinlock_t* ptl;
+	struct pglist_data* node_data;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	do {
+		node_data = NODE_DATA(numa_addr_to_nid(vma, addr));
+		if (pte_present(*pte)) {
+			page = pte_page(*pte);
+			if (page == ZERO_PAGE(addr))
+				continue;
+			pps_page_destruction(page, vma, addr, 1);
+			lru_cache_add_active(page);
+			atomic_dec(&node_data->nr_present_pte);
+		} else if (pte_unmapped(*pte)) {
+			page = pte_page(*pte);
+			BUG_ON(page == ZERO_PAGE(addr));
+			if (!PagePPS(page)) {
+				// the page is a readaheaded page, so convert
+				// UnmappedPTE to SwappedPTE.
+				swp.val = page_private(page);
+				entry = swp_entry_to_pte(swp);
+				atomic_dec(&node_data->nr_swapped_pte);
+			} else {
+				// UnmappedPTE to PresentPTE.
+				entry = mk_pte(page, vma->vm_page_prot);
+				entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+				pps_page_destruction(page, vma, addr, 1);
+				atomic_dec(&node_data->nr_unmapped_pte);
+			}
+			set_pte_at(mm, addr, pte, entry);
+			lru_cache_add_active(page);
+		} else if (pte_swapped(*pte))
+			atomic_dec(&node_data->nr_swapped_pte);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	lru_add_drain();
+}
+
+static void migrate_back_pmd_range(struct mm_struct* mm, pud_t *pud, struct
+		vm_area_struct *vma, unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		migrate_back_pte_range(mm, pmd, vma, addr, next);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void migrate_back_pud_range(struct mm_struct* mm, pgd_t *pgd, struct
+		vm_area_struct *vma, unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		migrate_back_pmd_range(mm, pud, vma, addr, next);
+	} while (pud++, addr = next, addr != end);
+}
+
+// migrate all pages of pure private vma back to Linux legacy memory
management.
+static void migrate_back_legacy_linux(struct mm_struct* mm, struct
vm_area_struct* vma)
+{
+	pgd_t* pgd;
+	unsigned long next;
+	unsigned long addr = vma->vm_start;
+	unsigned long end = vma->vm_end;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		migrate_back_pud_range(mm, pgd, vma, addr, next);
+	} while (pgd++, addr = next, addr != end);
+}
+
+void enter_pps(struct mm_struct* mm, struct vm_area_struct* vma)
+{
+	int condition = VM_READ | VM_WRITE | VM_EXEC | \
+		 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC | \
+		 VM_GROWSDOWN | VM_GROWSUP | \
+		 VM_LOCKED | VM_SEQ_READ | VM_RAND_READ | VM_DONTCOPY | \
+		 VM_ACCOUNT | VM_PURE_PRIVATE;
+	if (!(vma->vm_flags & ~condition) && vma->vm_file == NULL) {
+		vma->vm_flags |= VM_PURE_PRIVATE;
+		if (list_empty(&mm->mmlist)) {
+			spin_lock(&mmlist_lock);
+			if (list_empty(&mm->mmlist))
+				list_add(&mm->mmlist, &init_mm.mmlist);
+			spin_unlock(&mmlist_lock);
+		}
+	}
+}
+
+/*
+ * Caller must down_write mmap_sem.
+ */
+void leave_pps(struct vm_area_struct* vma, int migrate_flag)
+{
+	struct mm_struct* mm = vma->vm_mm;
+
+	if (vma->vm_flags & VM_PURE_PRIVATE) {
+		vma->vm_flags &= ~VM_PURE_PRIVATE;
+		if (migrate_flag)
+			migrate_back_legacy_linux(mm, vma);
+	}
+}
+
+void pps_page_construction(struct page* page, struct vm_area_struct* vma,
+	unsigned long address)
+{
+	struct pglist_data* node_data = NODE_DATA(page_to_nid(page));
+	atomic_inc(&node_data->nr_pps_total);
+	atomic_inc(&node_data->nr_present_pte);
+	SetPagePPS(page);
+	page_add_new_anon_rmap(page, vma, address);
+}
+
+void pps_page_destruction(struct page* ppspage, struct vm_area_struct* vma,
+	unsigned long address, int migrate)
+{
+	struct pglist_data* node_data = NODE_DATA(page_to_nid(page));
+	atomic_dec(&node_data->nr_pps_total);
+	if (!migrate)
+		page_remove_rmap(ppspage, vma);
+	ClearPagePPS(ppspage);
+}
Index: linux-2.6.22/mm/mempolicy.c
===================================================================
--- linux-2.6.22.orig/mm/mempolicy.c	2007-08-23 15:26:44.626396072 +0800
+++ linux-2.6.22/mm/mempolicy.c	2007-08-23 15:30:09.563203822 +0800
@@ -1166,7 +1166,8 @@
 		struct vm_area_struct *vma, unsigned long off)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
-	unsigned target = (unsigned)off % nnodes;
+	unsigned target = vma->vm_flags & VM_PURE_PRIVATE ? (off >> 6) % nnodes
+		: (unsigned) off % nnodes;
 	int c;
 	int nid = -1;

Index: linux-2.6.22/mm/migrate.c
===================================================================
--- linux-2.6.22.orig/mm/migrate.c	2007-08-23 15:26:44.658398072 +0800
+++ linux-2.6.22/mm/migrate.c	2007-08-23 15:30:09.567204072 +0800
@@ -117,7 +117,7 @@

 static inline int is_swap_pte(pte_t pte)
 {
-	return !pte_none(pte) && !pte_present(pte) && !pte_file(pte);
+	return !pte_none(pte) && !pte_present(pte) && pte_swapped(pte);
 }

 /*
Index: linux-2.6.22/mm/mincore.c
===================================================================
--- linux-2.6.22.orig/mm/mincore.c	2007-08-23 15:26:44.678399322 +0800
+++ linux-2.6.22/mm/mincore.c	2007-08-23 15:30:09.567204072 +0800
@@ -114,6 +114,13 @@
 			} else
 				present = 0;

+		} else if (pte_unmapped(pte)) {
+			struct page* page = pfn_to_page(pte_pfn(pte));
+			if (PagePPS(page))
+				present = 1;
+			else
+				present = PageUptodate(page);
+
 		} else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
 			present = mincore_page(vma->vm_file->f_mapping, pgoff);
Index: linux-2.6.22/mm/mmap.c
===================================================================
--- linux-2.6.22.orig/mm/mmap.c	2007-08-23 15:26:44.698400572 +0800
+++ linux-2.6.22/mm/mmap.c	2007-08-23 15:30:09.567204072 +0800
@@ -230,6 +230,7 @@
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
+	leave_pps(vma, 0);
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
 }
@@ -623,6 +624,7 @@
 			fput(file);
 		mm->map_count--;
 		mpol_free(vma_policy(next));
+		leave_pps(next, 0);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -1115,6 +1117,8 @@
 	if ((vm_flags & (VM_SHARED|VM_ACCOUNT)) == (VM_SHARED|VM_ACCOUNT))
 		vma->vm_flags &= ~VM_ACCOUNT;

+	enter_pps(mm, vma);
+
 	/* Can addr have changed??
 	 *
 	 * Answer: Yes, several device drivers can do it in their
@@ -1141,6 +1145,7 @@
 			fput(file);
 		}
 		mpol_free(vma_policy(vma));
+		leave_pps(vma, 0);
 		kmem_cache_free(vm_area_cachep, vma);
 	}
 out:	
@@ -1168,6 +1173,7 @@
 	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
+	leave_pps(vma, 0);
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
 	if (charged)
@@ -1745,6 +1751,10 @@

 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
+	if (new->vm_flags & VM_PURE_PRIVATE) {
+		new->vm_flags &= ~VM_PURE_PRIVATE;
+		enter_pps(mm, new);
+	}

 	if (new_below)
 		new->vm_end = addr;
@@ -1953,6 +1963,7 @@
 	vma->vm_flags = flags;
 	vma->vm_page_prot = protection_map[flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
+	enter_pps(mm, vma);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -2079,6 +2090,10 @@
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
+			if (new_vma->vm_flags & VM_PURE_PRIVATE) {
+				new_vma->vm_flags &= ~VM_PURE_PRIVATE;
+				enter_pps(mm, new_vma);
+			}
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
 		}
 	}
Index: linux-2.6.22/mm/mprotect.c
===================================================================
--- linux-2.6.22.orig/mm/mprotect.c	2007-08-23 15:26:44.718401822 +0800
+++ linux-2.6.22/mm/mprotect.c	2007-08-23 15:30:09.567204072 +0800
@@ -55,7 +55,7 @@
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
-		} else if (!pte_file(oldpte)) {
+		} else if (pte_swapped(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);

 			if (is_write_migration_entry(entry)) {
Index: linux-2.6.22/mm/page_alloc.c
===================================================================
--- linux-2.6.22.orig/mm/page_alloc.c	2007-08-23 15:26:44.738403072 +0800
+++ linux-2.6.22/mm/page_alloc.c	2007-08-23 15:30:09.567204072 +0800
@@ -598,7 +598,8 @@
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_pps))))
 		bad_page(page);

 	/*
Index: linux-2.6.22/mm/rmap.c
===================================================================
--- linux-2.6.22.orig/mm/rmap.c	2007-08-23 15:26:44.762404572 +0800
+++ linux-2.6.22/mm/rmap.c	2007-08-23 15:30:09.571204322 +0800
@@ -660,6 +660,8 @@
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;

+	BUG_ON(vma->vm_flags & VM_PURE_PRIVATE);
+
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
@@ -718,7 +720,7 @@
 #endif
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
-		BUG_ON(pte_file(*pte));
+		BUG_ON(!pte_swapped(*pte));
 	} else
 #ifdef CONFIG_MIGRATION
 	if (migration) {
Index: linux-2.6.22/mm/swap_state.c
===================================================================
--- linux-2.6.22.orig/mm/swap_state.c	2007-08-23 15:26:44.782405822 +0800
+++ linux-2.6.22/mm/swap_state.c	2007-08-23 15:30:09.571204322 +0800
@@ -136,6 +136,43 @@
 	INC_CACHE_INFO(del_total);
 }

+int pps_relink_swp(struct page* page, swp_entry_t entry, swp_entry_t** thrash)
+{
+	BUG_ON(!PageLocked(page));
+	ClearPageError(page);
+	if (radix_tree_preload(GFP_ATOMIC | __GFP_NOMEMALLOC | __GFP_NOWARN))
+		goto failed;
+	write_lock_irq(&swapper_space.tree_lock);
+	if (radix_tree_insert(&swapper_space.page_tree, entry.val, page))
+		goto preload_failed;
+	if (PageSwapCache(page)) {
+		(**thrash).val = page_private(page);
+		radix_tree_delete(&swapper_space.page_tree, (**thrash).val);
+		(*thrash)++;
+		INC_CACHE_INFO(del_total);
+	} else {
+		page_cache_get(page);
+		SetPageSwapCache(page);
+		total_swapcache_pages++;
+		__inc_zone_page_state(page, NR_FILE_PAGES);
+	}
+	INC_CACHE_INFO(add_total);
+	set_page_private(page, entry.val);
+	SetPageDirty(page);
+	SetPageUptodate(page);
+	write_unlock_irq(&swapper_space.tree_lock);
+	radix_tree_preload_end();
+	return 1;
+
+preload_failed:
+	write_unlock_irq(&swapper_space.tree_lock);
+	radix_tree_preload_end();
+failed:
+	**thrash = entry;
+	(*thrash)++;
+	return 0;
+}
+
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
Index: linux-2.6.22/mm/swapfile.c
===================================================================
--- linux-2.6.22.orig/mm/swapfile.c	2007-08-23 15:29:55.818344822 +0800
+++ linux-2.6.22/mm/swapfile.c	2007-08-23 15:30:09.571204322 +0800
@@ -501,6 +501,183 @@
 }
 #endif

+static int pps_test_swap_type(struct mm_struct* mm, pmd_t* pmd, pte_t* pte, int
+		type, struct page** ret_page)
+{
+	spinlock_t* ptl = pte_lockptr(mm, pmd);
+	swp_entry_t entry;
+	struct page* page;
+	int result = 1;
+
+	spin_lock(ptl);
+	if (pte_none(*pte))
+		result = 0;
+	else if (!pte_present(*pte) && pte_swapped(*pte)) { // SwappedPTE.
+		entry = pte_to_swp_entry(*pte);
+		if (swp_type(entry) == type)
+			*ret_page = NULL;
+		else
+			result = 0;
+	} else { // UnmappedPTE and (Present, Untouched)PTE.
+		page = pfn_to_page(pte_pfn(*pte));
+		if (!PagePPS(page)) { // The page is a readahead page.
+			if (PageSwapCache(page)) {
+				entry.val = page_private(page);
+				if (swp_type(entry) == type)
+					*ret_page = NULL;
+				else
+					result = 0;
+			} else
+				result = 0;
+		} else if (PageSwapCache(page)) {
+			entry.val = page_private(page);
+			if (swp_type(entry) == type) {
+				page_cache_get(page);
+				*ret_page = page;
+			} else
+				result = 0;
+		} else
+			result = 0;
+	}
+	spin_unlock(ptl);
+	return result;
+}
+
+static int pps_swapoff_scan_ptes(struct mm_struct* mm, struct vm_area_struct*
+		vma, pmd_t* pmd, unsigned long addr, unsigned long end, int type)
+{
+	pte_t *pte;
+	struct page* page = (struct page*) 0xffffffff;
+	swp_entry_t entry;
+	struct pglist_data* node_data;
+
+	pte = pte_offset_map(pmd, addr);
+	do {
+		while (pps_test_swap_type(mm, pmd, pte, type, &page)) {
+			if (page == NULL) {
+				switch (__handle_mm_fault(mm, vma, addr, 0)) {
+				case VM_FAULT_SIGBUS:
+				case VM_FAULT_OOM:
+					return -ENOMEM;
+				case VM_FAULT_MINOR:
+				case VM_FAULT_MAJOR:
+					break;
+				default:
+					BUG();
+				}
+			} else {
+				wait_on_page_locked(page);
+				wait_on_page_writeback(page);
+				lock_page(page);
+				if (!PageSwapCache(page))
+					goto done;
+				else {
+					entry.val = page_private(page);
+					if (swp_type(entry) != type)
+						goto done;
+				}
+				wait_on_page_writeback(page);
+				node_data = NODE_DATA(page_to_nid(page));
+				delete_from_swap_cache(page);
+				atomic_dec(&node_data->nr_swapped_pte);
+done:
+				unlock_page(page);
+				page_cache_release(page);
+				break;
+			}
+		}
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap(pte);
+	return 0;
+}
+
+static int pps_swapoff_pmd_range(struct mm_struct* mm, struct vm_area_struct*
+		vma, pud_t* pud, unsigned long addr, unsigned long end, int type)
+{
+	unsigned long next;
+	int ret;
+	pmd_t* pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		ret = pps_swapoff_scan_ptes(mm, vma, pmd, addr, next, type);
+		if (ret == -ENOMEM)
+			return ret;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static int pps_swapoff_pud_range(struct mm_struct* mm, struct vm_area_struct*
+		vma, pgd_t* pgd, unsigned long addr, unsigned long end, int type)
+{
+	unsigned long next;
+	int ret;
+	pud_t* pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		ret = pps_swapoff_pmd_range(mm, vma, pud, addr, next, type);
+		if (ret == -ENOMEM)
+			return ret;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static int pps_swapoff_pgd_range(struct mm_struct* mm, struct vm_area_struct*
+		vma, int type)
+{
+	unsigned long next;
+	unsigned long addr = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	int ret;
+	pgd_t* pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		ret = pps_swapoff_pud_range(mm, vma, pgd, addr, next, type);
+		if (ret == -ENOMEM)
+			return ret;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+static int pps_swapoff(int type)
+{
+	struct vm_area_struct* vma;
+	struct list_head *pos;
+	struct mm_struct *prev, *mm;
+	int ret = 0;
+
+	prev = mm = &init_mm;
+	pos = &init_mm.mmlist;
+	atomic_inc(&prev->mm_users);
+	spin_lock(&mmlist_lock);
+	while ((pos = pos->next) != &init_mm.mmlist) {
+		mm = list_entry(pos, struct mm_struct, mmlist);
+		if (!atomic_inc_not_zero(&mm->mm_users))
+			continue;
+		spin_unlock(&mmlist_lock);
+		mmput(prev);
+		prev = mm;
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
+			if (!(vma->vm_flags & VM_PURE_PRIVATE))
+				continue;
+			ret = pps_swapoff_pgd_range(mm, vma, type);
+			if (ret == -ENOMEM)
+				break;
+		}
+		up_read(&mm->mmap_sem);
+		spin_lock(&mmlist_lock);
+	}
+	spin_unlock(&mmlist_lock);
+	mmput(prev);
+	return ret;
+}
+
 /*
  * No need to decide whether this PTE shares the swap entry with others,
  * just let do_wp_page work it out if a write is requested later - to
@@ -694,6 +871,12 @@
 	int reset_overflow = 0;
 	int shmem;

+	// Let's first read all pps pages back! Note, it's one-to-one mapping.
+	retval = pps_swapoff(type);
+	if (retval == -ENOMEM) // something was wrong.
+		return -ENOMEM;
+	// Now, the remain pages are shared pages, go ahead!
+
 	/*
 	 * When searching mms for an entry, a good strategy is to
 	 * start at the first mm we freed the previous entry from
@@ -914,16 +1097,20 @@
  */
 static void drain_mmlist(void)
 {
-	struct list_head *p, *next;
+	// struct list_head *p, *next;
 	unsigned int i;

 	for (i = 0; i < nr_swapfiles; i++)
 		if (swap_info[i].inuse_pages)
 			return;
+	/*
+	 * Now, init_mm.mmlist list not only is used by SwapDevice but also is
+	 * used by PPS, see Documentation/vm_pps.txt.
 	spin_lock(&mmlist_lock);
 	list_for_each_safe(p, next, &init_mm.mmlist)
 		list_del_init(p);
 	spin_unlock(&mmlist_lock);
+	*/
 }

 /*
@@ -1796,3 +1983,235 @@
 	spin_unlock(&swap_lock);
 	return ret;
 }
+
+// Copy from scan_swap_map.
+// parameter SERIES_LENGTH >= count >= 1.
+static inline unsigned long scan_swap_map_batchly(struct swap_info_struct *si,
+		int type, int count, swp_entry_t avail_swps[SERIES_BOUND])
+{
+	unsigned long offset, last_in_cluster, result = 0;
+	int latency_ration = LATENCY_LIMIT;
+
+	si->flags += SWP_SCANNING;
+	if (unlikely(!si->cluster_nr)) {
+		si->cluster_nr = SWAPFILE_CLUSTER - 1;
+		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER)
+			goto lowest;
+		spin_unlock(&swap_lock);
+
+		offset = si->lowest_bit;
+		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
+
+		/* Locate the first empty (unaligned) cluster */
+		for (; last_in_cluster <= si->highest_bit; offset++) {
+			if (si->swap_map[offset])
+				last_in_cluster = offset + SWAPFILE_CLUSTER;
+			else if (offset == last_in_cluster) {
+				spin_lock(&swap_lock);
+				si->cluster_next = offset-SWAPFILE_CLUSTER+1;
+				goto cluster;
+			}
+			if (unlikely(--latency_ration < 0)) {
+				cond_resched();
+				latency_ration = LATENCY_LIMIT;
+			}
+		}
+		spin_lock(&swap_lock);
+		goto lowest;
+	}
+
+	si->cluster_nr--;
+cluster:
+	offset = si->cluster_next;
+	if (offset > si->highest_bit)
+lowest:		offset = si->lowest_bit;
+checks:	if (!(si->flags & SWP_WRITEOK))
+		goto no_page;
+	if (!si->highest_bit)
+		goto no_page;
+	if (!si->swap_map[offset]) {
+		int i;
+		for (i = 0; !si->swap_map[offset] && (result != count) &&
+				offset <= si->highest_bit; offset++, i++) {
+			si->swap_map[offset] = 1;
+			avail_swps[result++] = swp_entry(type, offset);
+		}
+		si->cluster_next = offset;
+		si->cluster_nr -= i;
+		if (offset - i == si->lowest_bit)
+			si->lowest_bit += i;
+		if (offset == si->highest_bit)
+			si->highest_bit -= i;
+		si->inuse_pages += i;
+		if (si->inuse_pages == si->pages) {
+			si->lowest_bit = si->max;
+			si->highest_bit = 0;
+		}
+		if (result == count)
+			goto no_page;
+	}
+
+	spin_unlock(&swap_lock);
+	while (++offset <= si->highest_bit) {
+		if (!si->swap_map[offset]) {
+			spin_lock(&swap_lock);
+			goto checks;
+		}
+		if (unlikely(--latency_ration < 0)) {
+			cond_resched();
+			latency_ration = LATENCY_LIMIT;
+		}
+	}
+	spin_lock(&swap_lock);
+	goto lowest;
+
+no_page:
+	avail_swps[result].val = 0;
+	si->flags -= SWP_SCANNING;
+	return result;
+}
+
+void swap_free_batchly(swp_entry_t entries[2 * SERIES_BOUND])
+{
+	struct swap_info_struct* p;
+	int i;
+
+	spin_lock(&swap_lock);
+	for (i = 0; entries[i].val != 0; i++) {
+		p = &swap_info[swp_type(entries[i])];
+		BUG_ON(p->swap_map[swp_offset(entries[i])] != 1);
+		if (p)
+			swap_entry_free(p, swp_offset(entries[i]));
+	}
+	spin_unlock(&swap_lock);
+}
+
+// parameter SERIES_LENGTH >= count >= 1.
+int swap_alloc_batchly(int count, swp_entry_t avail_swps[SERIES_BOUND], int
+		end_prio)
+{
+	int result = 0, type = swap_list.head, orig_count = count;
+	struct swap_info_struct* si;
+	spin_lock(&swap_lock);
+	if (nr_swap_pages <= 0)
+		goto done;
+	for (si = &swap_info[type]; type >= 0 && si->prio > end_prio;
+			type = si->next, si = &swap_info[type]) {
+		if (!si->highest_bit)
+			continue;
+		if (!(si->flags & SWP_WRITEOK))
+			continue;
+		result = scan_swap_map_batchly(si, type, count, avail_swps);
+		nr_swap_pages -= result;
+		avail_swps += result;
+		if (result == count) {
+			count = 0;
+			break;
+		}
+		count -= result;
+	}
+done:
+	avail_swps[0].val = 0;
+	spin_unlock(&swap_lock);
+	return orig_count - count;
+}
+
+// parameter SERIES_LENGTH >= count >= 1.
+void swap_alloc_around_nail(swp_entry_t nail_swp, int count, swp_entry_t
+		avail_swps[SERIES_BOUND])
+{
+	int i, result = 0, type, offset;
+	struct swap_info_struct *si = &swap_info[swp_type(nail_swp)];
+	spin_lock(&swap_lock);
+	if (nr_swap_pages <= 0)
+		goto done;
+	BUG_ON(nail_swp.val == 0);
+	// Always allocate from high priority (quicker) SwapDevice.
+	if (si->prio < swap_info[swap_list.head].prio) {
+		spin_unlock(&swap_lock);
+		result = swap_alloc_batchly(count, avail_swps, si->prio);
+		avail_swps += result;
+		if (result == count)
+			return;
+		count -= result;
+		spin_lock(&swap_lock);
+	}
+	type = swp_type(nail_swp);
+	offset = swp_offset(nail_swp);
+	result = 0;
+	if (!si->highest_bit)
+		goto done;
+	if (!(si->flags & SWP_WRITEOK))
+		goto done;
+	for (i = max_t(int, offset - 32, si->lowest_bit); i <= min_t(int,
+			offset + 32, si->highest_bit) && count != 0; i++) {
+		if (!si->swap_map[i]) {
+			count--;
+			avail_swps[result++] = swp_entry(type, i);
+			si->swap_map[i] = 1;
+		}
+	}
+	if (result != 0) {
+		nr_swap_pages -= result;
+		si->inuse_pages += result;
+		if (swp_offset(avail_swps[0]) == si->lowest_bit)
+			si->lowest_bit = swp_offset(avail_swps[result-1]) + 1;
+		if (swp_offset(avail_swps[result - 1]) == si->highest_bit)
+			si->highest_bit = swp_offset(avail_swps[0]) - 1;
+		if (si->inuse_pages == si->pages) {
+			si->lowest_bit = si->max;
+			si->highest_bit = 0;
+		}
+	}
+done:
+	spin_unlock(&swap_lock);
+	avail_swps[result].val = 0;
+}
+
+// parameter SERIES_LENGTH >= count >= 1.
+// avail_swps is set only when success.
+int swap_try_alloc_batchly(swp_entry_t central_swp, int count, swp_entry_t
+		avail_swps[SERIES_BOUND])
+{
+	int i, result = 0, type, offset, j = 0;
+	struct swap_info_struct *si = &swap_info[swp_type(central_swp)];
+	BUG_ON(central_swp.val == 0);
+	spin_lock(&swap_lock);
+	// Always allocate from high priority (quicker) SwapDevice.
+	if (nr_swap_pages <= 0 || si->prio < swap_info[swap_list.head].prio)
+		goto done;
+	type = swp_type(central_swp);
+	offset = swp_offset(central_swp);
+	if (!si->highest_bit)
+		goto done;
+	if (!(si->flags & SWP_WRITEOK))
+		goto done;
+	for (i = max_t(int, offset - 32, si->lowest_bit); i <= min_t(int,
+			offset + 32, si->highest_bit) && count != 0; i++) {
+		if (!si->swap_map[i]) {
+			count--;
+			avail_swps[j++] = swp_entry(type, i);
+			si->swap_map[i] = 1;
+		}
+	}
+	if (j == count) {
+		nr_swap_pages -= count;
+		avail_swps[j].val = 0;
+		si->inuse_pages += j;
+		if (swp_offset(avail_swps[0]) == si->lowest_bit)
+			si->lowest_bit = swp_offset(avail_swps[count - 1]) + 1;
+		if (swp_offset(avail_swps[count - 1]) == si->highest_bit)
+			si->highest_bit = swp_offset(avail_swps[0]) - 1;
+		if (si->inuse_pages == si->pages) {
+			si->lowest_bit = si->max;
+			si->highest_bit = 0;
+		}
+		result = 1;
+	} else {
+		for (i = 0; i < j; i++)
+			si->swap_map[swp_offset(avail_swps[i])] = 0;
+	}
+done:
+	spin_unlock(&swap_lock);
+	return result;
+}
Index: linux-2.6.22/mm/vmscan.c
===================================================================
--- linux-2.6.22.orig/mm/vmscan.c	2007-08-23 15:26:44.826408572 +0800
+++ linux-2.6.22/mm/vmscan.c	2007-08-23 16:25:37.003155822 +0800
@@ -66,6 +66,10 @@
 	int swappiness;

 	int all_unreclaimable;
+
+	/* pps control command. See Documentation/vm_pps.txt. */
+	int reclaim_node;
+	int is_kppsd;
 };

 /*
@@ -1097,6 +1101,746 @@
 	return ret;
 }

+// pps fields, see Documentation/vm_pps.txt.
+static int accelerate_kppsd = 0;
+static wait_queue_head_t kppsd_wait;
+
+struct series_t {
+	pte_t orig_ptes[SERIES_LENGTH];
+	pte_t* ptes[SERIES_LENGTH];
+	swp_entry_t swps[SERIES_LENGTH];
+	struct page* pages[SERIES_LENGTH];
+	int stages[SERIES_LENGTH];
+	unsigned long addrs[SERIES_LENGTH];
+	int series_length;
+	int series_stage;
+};
+
+/*
+ * Here, we take a snapshot from (Unmapped)PTE-Page pair for further stageX,
+ * before we use the snapshot, we must know some fields can be changed after
+ * the snapshot, so it's necessary to re-verify the fields in pps_stageX. See
+ * <Concurrent Racers of pps> section of Documentation/vm_pps.txt.
+ *
+ * Such as, UnmappedPTE/SwappedPTE can be remapped to PresentPTE, page->private
+ * can be freed after snapshot, but PresentPTE cann't shift to UnmappedPTE and
+ * page cann't be (re-)allocated swap entry.
+ */
+static int get_series_stage(struct series_t* series, pte_t* pte, unsigned long
+		addr, int index)
+{
+	struct page* page = NULL;
+	unsigned long flags;
+	series->addrs[index] = addr;
+	series->orig_ptes[index] = *pte;
+	series->ptes[index] = pte;
+	if (pte_present(series->orig_ptes[index])) {
+		page = pfn_to_page(pte_pfn(series->orig_ptes[index]));
+		if (page == ZERO_PAGE(addr)) // reserved page is excluded.
+			return -1;
+		if (pte_young(series->orig_ptes[index])) {
+			return 1;
+		} else
+			return 2;
+	} else if (pte_unmapped(series->orig_ptes[index])) {
+		page = pfn_to_page(pte_pfn(series->orig_ptes[index]));
+		series->pages[index] = page;
+		flags = page->flags;
+		series->swps[index].val = page_private(page);
+		if (series->swps[index].val == 0)
+			return 3;
+		if (!test_bit(PG_pps, &flags)) { // readaheaded page.
+			if (test_bit(PG_locked, &flags)) // ReadIOing.
+				return 4;
+			// Here, reclaim the page whether it encounters readIO
+			// error or not (PG_uptodate or not).
+			return 5;
+		} else {
+			if (test_bit(PG_writeback, &flags)) // WriteIOing.
+				return 4;
+			if (!test_bit(PG_dirty, &flags))
+				return 5;
+			// Here, one is the page encounters writeIO error,
+			// another is the dirty page linking with a SwapEntry
+			// should be relinked.
+			return 3;
+		}
+	} else if (pte_swapped(series->orig_ptes[index])) { // SwappedPTE
+		series->swps[index] =
+			pte_to_swp_entry(series->orig_ptes[index]);
+		return 6;
+	} else // NullPTE
+		return 0;
+}
+
+static void find_series(struct series_t* series, pte_t** start, unsigned long*
+		addr, unsigned long end)
+{
+	int i;
+	int series_stage = get_series_stage(series, (*start)++, *addr, 0);
+	*addr += PAGE_SIZE;
+
+	for (i = 1; i < SERIES_LENGTH && *addr < end; i++, (*start)++,
+		*addr += PAGE_SIZE) {
+		if (series_stage != get_series_stage(series, *start, *addr, i))
+			break;
+	}
+	series->series_stage = series_stage;
+	series->series_length = i;
+}
+
+#define DFTLB_CAPACITY 32
+struct {
+	struct mm_struct* mm;
+	int vma_index;
+	struct vm_area_struct* vma[DFTLB_CAPACITY];
+	pmd_t* pmd[DFTLB_CAPACITY];
+	unsigned long start[DFTLB_CAPACITY];
+	unsigned long end[DFTLB_CAPACITY];
+} dftlb_tasks = { 0 };
+
+// The prototype of the function is fit with the "func" of "int
+// smp_call_function (void (*func) (void *info), void *info, int retry, int
+// wait);" of include/linux/smp.h of 2.6.16.29. Call it with NULL.
+void flush_tlb_tasks(void* data)
+{
+#ifdef CONFIG_X86
+	local_flush_tlb();
+#else
+	int i;
+	for (i = 0; i < dftlb_tasks.vma_index; i++) {
+		// smp::local_flush_tlb_range(dftlb_tasks.{vma, start, end});
+	}
+#endif
+}
+
+static void __pps_stage2(void)
+{
+	int anon_rss = 0, file_rss = 0, unmapped_pte = 0, present_pte = 0, i;
+	unsigned long addr;
+	spinlock_t* ptl = pte_lockptr(dftlb_tasks.mm, dftlb_tasks.pmd[0]);
+	pte_t pte_orig, pte_unmapped, *pte;
+	struct page* page;
+	struct vm_area_struct* vma;
+	struct pglist_data* node_data = NULL;
+
+	spin_lock(ptl);
+	for (i = 0; i < dftlb_tasks.vma_index; i++) {
+		vma = dftlb_tasks.vma[i];
+		addr = dftlb_tasks.start[i];
+		if (i != 0 && dftlb_tasks.pmd[i] != dftlb_tasks.pmd[i - 1]) {
+			pte_unmap_unlock(pte, ptl);
+			ptl = pte_lockptr(dftlb_tasks.mm, dftlb_tasks.pmd[i]);
+			spin_lock(ptl);
+		}
+		pte = pte_offset_map(dftlb_tasks.pmd[i], addr);
+		for (; addr != dftlb_tasks.end[i]; addr += PAGE_SIZE, pte++) {
+			if (node_data != NULL && node_data !=
+					NODE_DATA(numa_addr_to_nid(vma, addr)))
+			{
+				atomic_add(unmapped_pte,
+						&node_data->nr_unmapped_pte);
+				atomic_sub(present_pte,
+						&node_data->nr_present_pte);
+			}
+			node_data = NODE_DATA(numa_addr_to_nid(vma, addr));
+			pte_orig = *pte;
+			if (pte_young(pte_orig))
+				continue;
+			if (vma->vm_flags & VM_PURE_PRIVATE) {
+				pte_unmapped = pte_mkunmapped(pte_orig);
+			} else
+				pte_unmapped = __pte(0);
+			// We're safe if target CPU supports two conditions
+			// listed in dftlb section.
+			if (cmpxchg(&pte->pte_low, pte_orig.pte_low,
+						pte_unmapped.pte_low) !=
+					pte_orig.pte_low)
+				continue;
+			page = pfn_to_page(pte_pfn(pte_orig));
+			if (pte_dirty(pte_orig))
+				set_page_dirty(page);
+			update_hiwater_rss(dftlb_tasks.mm);
+			if (vma->vm_flags & VM_PURE_PRIVATE) {
+				// anon_rss--, page_remove_rmap(page, vma) and
+				// page_cache_release(page) are done at stage5.
+				unmapped_pte++;
+				present_pte++;
+			} else {
+				page_remove_rmap(page, vma);
+				if (PageAnon(page))
+					anon_rss--;
+				else
+					file_rss--;
+				page_cache_release(page);
+			}
+		}
+	}
+	atomic_add(unmapped_pte, &node_data->nr_unmapped_pte);
+	atomic_sub(present_pte, &node_data->nr_present_pte);
+	pte_unmap_unlock(pte, ptl);
+	add_mm_counter(dftlb_tasks.mm, anon_rss, anon_rss);
+	add_mm_counter(dftlb_tasks.mm, file_rss, file_rss);
+}
+
+static void start_dftlb(struct mm_struct* mm)
+{
+	dftlb_tasks.mm = mm;
+	BUG_ON(dftlb_tasks.vma_index != 0);
+	BUG_ON(dftlb_tasks.vma[0] != NULL);
+}
+
+static void end_dftlb(void)
+{
+	// In fact, only those CPUs which have a trace in
+	// dftlb_tasks.mm->cpu_vm_mask should be paused by on_each_cpu, but
+	// current on_each_cpu doesn't support it.
+	if (dftlb_tasks.vma_index != 0 || dftlb_tasks.vma[0] != NULL) {
+		on_each_cpu(flush_tlb_tasks, NULL, 0, 1);
+
+		if (dftlb_tasks.vma_index != DFTLB_CAPACITY)
+			dftlb_tasks.vma_index++;
+		// Convert PresentPTE to UnmappedPTE batchly -- dftlb.
+		__pps_stage2();
+		dftlb_tasks.vma_index = 0;
+		memset(dftlb_tasks.vma, 0, sizeof(dftlb_tasks.vma));
+	}
+}
+
+static void fill_in_tlb_tasks(struct vm_area_struct* vma, pmd_t* pmd, unsigned
+		long addr, unsigned long end)
+{
+	// If target CPU doesn't support dftlb, flushes and unmaps PresentPTEs
+	// here!
+	// flush_tlb_range(vma, addr, end); //<-- and unmaps PresentPTEs.
+	// return;
+
+	// dftlb: place the unmapping task to a static region -- dftlb_tasks,
+	// if it's full, flush them batchly in end_dftlb().
+	if (dftlb_tasks.vma[dftlb_tasks.vma_index] != NULL &&
+			dftlb_tasks.vma[dftlb_tasks.vma_index] == vma &&
+			dftlb_tasks.pmd[dftlb_tasks.vma_index] == pmd &&
+			dftlb_tasks.end[dftlb_tasks.vma_index] == addr) {
+		dftlb_tasks.end[dftlb_tasks.vma_index] = end;
+	} else {
+		if (dftlb_tasks.vma[dftlb_tasks.vma_index] != NULL)
+			dftlb_tasks.vma_index++;
+		if (dftlb_tasks.vma_index == DFTLB_CAPACITY)
+			end_dftlb();
+		dftlb_tasks.vma[dftlb_tasks.vma_index] = vma;
+		dftlb_tasks.pmd[dftlb_tasks.vma_index] = pmd;
+		dftlb_tasks.start[dftlb_tasks.vma_index] = addr;
+		dftlb_tasks.end[dftlb_tasks.vma_index] = end;
+	}
+}
+
+static void pps_stage1(spinlock_t* ptl, struct vm_area_struct* vma, unsigned
+		long addr, struct series_t* series)
+{
+	int i;
+	spin_lock(ptl);
+	for (i = 0; i < series->series_length; i++)
+		ptep_clear_flush_young(vma, addr + i * PAGE_SIZE,
+				series->ptes[i]);
+	spin_unlock(ptl);
+}
+
+static void pps_stage2(struct vm_area_struct* vma, pmd_t* pmd, struct series_t*
+		series)
+{
+	fill_in_tlb_tasks(vma, pmd, series->addrs[0],
+			series->addrs[series->series_length - 1] + PAGE_SIZE);
+}
+
+// Which free_pages can be re-alloced around the nail_swp?
+static int calc_realloc(struct series_t* series, swp_entry_t nail_swp, int
+		realloc_pages[SERIES_BOUND], int remain_pages[SERIES_BOUND])
+{
+	int i, count = 0;
+	int swap_type = swp_type(nail_swp);
+	int swap_offset = swp_offset(nail_swp);
+	swp_entry_t temp;
+	for (i = 0; realloc_pages[i] != -1; i++) {
+		temp = series->swps[realloc_pages[i]];
+		if (temp.val != 0
+				// The swap entry is close to nail. Here,
+				// 'close' is disk-close, so Swapfile should
+				// provide an overload close function.
+				&& swp_type(temp) == swap_type &&
+				abs(swp_offset(temp) - swap_offset) < 32)
+			continue;
+		remain_pages[count++] = realloc_pages[i];
+	}
+	remain_pages[count] = -1;
+	return count;
+}
+
+static int realloc_around_nails(struct series_t* series, swp_entry_t nail_swp,
+		int realloc_pages[SERIES_BOUND],
+		int remain_pages[SERIES_BOUND],
+		swp_entry_t** thrash_cursor, int* boost, int tryit)
+{
+	int i, need_count;
+	swp_entry_t avail_swps[SERIES_BOUND];
+
+	need_count = calc_realloc(series, nail_swp, realloc_pages,
+			remain_pages);
+	if (!need_count)
+		return 0;
+	*boost = 0;
+	if (tryit) {
+		if (!swap_try_alloc_batchly(nail_swp, need_count, avail_swps))
+			return need_count;
+	} else
+		swap_alloc_around_nail(nail_swp, need_count, avail_swps);
+	for (i = 0; avail_swps[i].val != 0; i++) {
+		if (!pps_relink_swp(series->pages[remain_pages[(*boost)++]],
+					avail_swps[i], thrash_cursor)) {
+			for (++i; avail_swps[i].val != 0; i++) {
+				**thrash_cursor = avail_swps[i];
+				(*thrash_cursor)++;
+			}
+			return -1;
+		}
+	}
+	return need_count - *boost;
+}
+
+static void pps_stage3(struct series_t* series,
+		swp_entry_t nail_swps[SERIES_BOUND + 1],
+		int realloc_pages[SERIES_BOUND])
+{
+	int i, j, remain, boost = 0;
+	swp_entry_t thrash[SERIES_BOUND * 2];
+	swp_entry_t* thrash_cursor = &thrash[0];
+	int rotate_buffers[SERIES_BOUND * 2];
+	int *realloc_cursor = realloc_pages, *rotate_cursor;
+	swp_entry_t avail_swps[SERIES_BOUND];
+
+	// 1) realloc swap entries surrounding nail_ptes.
+	for (i = 0; nail_swps[i].val != 0; i++) {
+		rotate_cursor = i % 2 == 0 ? &rotate_buffers[0] :
+			&rotate_buffers[SERIES_BOUND];
+		remain = realloc_around_nails(series, nail_swps[i],
+				realloc_cursor, rotate_cursor, &thrash_cursor,
+				&boost, 0);
+		realloc_cursor = rotate_cursor + boost;
+		if (remain == 0 || remain == -1)
+			goto done;
+	}
+
+	// 2) allocate swap entries for remaining realloc_pages.
+	rotate_cursor = i % 2 == 0 ? &rotate_buffers[0] :
+		&rotate_buffers[SERIES_BOUND];
+	for (i = 0; *(realloc_cursor + i) != -1; i++) {
+		swp_entry_t entry = series->swps[*(realloc_cursor + i)];
+		if (entry.val == 0)
+			continue;
+		remain = realloc_around_nails(series, entry, realloc_cursor,
+				rotate_cursor, &thrash_cursor, &boost, 1);
+		if (remain == 0 || remain == -1)
+			goto done;
+	}
+	// Currently, priority -- (int) 0xf0000000 is enough safe to try to
+	// allocate all SwapDevices.
+	swap_alloc_batchly(i, avail_swps, (int) 0xf0000000);
+	for (i = 0, j = 0; avail_swps[i].val != 0; i++, j++) {
+		if (!pps_relink_swp(series->pages[*(realloc_cursor + j)],
+					avail_swps[i], &thrash_cursor)) {
+			for (++i; avail_swps[i].val != 0; i++) {
+				*thrash_cursor = avail_swps[i];
+				thrash_cursor++;
+			}
+			break;
+		}
+	}
+
+done:
+	(*thrash_cursor).val = 0;
+	swap_free_batchly(thrash);
+}
+
+/*
+ * A mini version pageout().
+ *
+ * Current swap space can't commit multiple pages together:(
+ */
+static void pps_stage4(struct page* page)
+{
+	int res;
+	struct address_space* mapping = &swapper_space;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = SWAP_CLUSTER_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 1,
+	};
+
+	if (!may_write_to_queue(mapping->backing_dev_info))
+		goto unlock_page;
+	if (!PageSwapCache(page))
+		goto unlock_page;
+	if (!clear_page_dirty_for_io(page))
+		goto unlock_page;
+	page_cache_get(page);
+	SetPageReclaim(page);
+	res = swap_writepage(page, &wbc); // << page is unlocked here.
+	if (res < 0) {
+		handle_write_error(mapping, page, res);
+		ClearPageReclaim(page);
+		page_cache_release(page);
+		return;
+	}
+	inc_zone_page_state(page, NR_VMSCAN_WRITE);
+	if (!PageWriteback(page))
+		ClearPageReclaim(page);
+	page_cache_release(page);
+	return;
+
+unlock_page:
+	unlock_page(page);
+}
+
+static int pps_stage5(spinlock_t* ptl, struct vm_area_struct* vma, struct
+		mm_struct* mm, struct series_t* series, int index, struct
+		pagevec* freed_pvec)
+{
+	swp_entry_t entry;
+	pte_t pte_swp;
+	struct page* page = series->pages[index];
+	struct pglist_data* node_data = NODE_DATA(page_to_nid(page));
+
+	if (TestSetPageLocked(page))
+		goto failed;
+	if (!PageSwapCache(page))
+		goto unlock_page;
+	BUG_ON(PageWriteback(page));
+	/* We're racing with get_user_pages. Copy from remove_mapping(). */
+	if (page_count(page) > 2)
+		goto unlock_page;
+	smp_rmb();
+	if (unlikely(PageDirty(page)))
+		goto unlock_page;
+	/* We're racing with get_user_pages. END */
+	spin_lock(ptl);
+	if (!pte_same(*series->ptes[index], series->orig_ptes[index])) {
+		spin_unlock(ptl);
+		goto unlock_page;
+	}
+	entry.val = page_private(page);
+	pte_swp = swp_entry_to_pte(entry);
+	set_pte_at(mm, series->addrs[index], series->ptes[index], pte_swp);
+	add_mm_counter(mm, anon_rss, -1);
+	if (PagePPS(page)) {
+		swap_duplicate(entry);
+		pps_page_destruction(page, vma, series->addrs[index], 0);
+		atomic_dec(&node_data->nr_unmapped_pte);
+		atomic_inc(&node_data->nr_swapped_pte);
+	} else
+		page_cache_get(page);
+	delete_from_swap_cache(page);
+	spin_unlock(ptl);
+	unlock_page(page);
+
+	if (!pagevec_add(freed_pvec, page))
+		__pagevec_release_nonlru(freed_pvec);
+	return 1;
+
+unlock_page:
+	unlock_page(page);
+failed:
+	return 0;
+}
+
+static void find_series_pgdata(struct series_t* series, pte_t** start, unsigned
+		long* addr, unsigned long end)
+{
+	int i;
+
+	for (i = 0; i < SERIES_LENGTH && *addr < end; i++, (*start)++, *addr +=
+			PAGE_SIZE)
+		series->stages[i] = get_series_stage(series, *start, *addr, i);
+	series->series_length = i;
+}
+
+// pps_stage 3 -- 4.
+static unsigned long pps_shrink_pgdata(struct scan_control* sc, struct
+		series_t* series, struct mm_struct* mm, struct vm_area_struct*
+		vma, struct pagevec* freed_pvec, spinlock_t* ptl)
+{
+	int i, nr_nail = 0, nr_realloc = 0;
+	unsigned long nr_reclaimed = 0;
+	struct pglist_data* node_data = NODE_DATA(sc->reclaim_node);
+	int realloc_pages[SERIES_BOUND];
+	swp_entry_t nail_swps[SERIES_BOUND + 1], prev, next;
+
+	// 1) Distinguish which are nail swap entries or not.
+	for (i = 0; i < series->series_length; i++) {
+		switch (series->stages[i]) {
+			case -1 ... 2:
+				break;
+			case 5:
+				nr_reclaimed += pps_stage5(ptl, vma, mm,
+						series, i, freed_pvec);
+				// Fall through!
+			case 4:
+			case 6:
+				nail_swps[nr_nail++] = series->swps[i];
+				break;
+			case 3:
+				// NOTE: here we lock all realloc-pages, which
+				// simplifies our code. But you should know,
+				// there isn't lock order that the former page
+				// of series takes priority of the later, only
+				// currently it's safe to pps.
+				if (!TestSetPageLocked(series->pages[i]))
+					realloc_pages[nr_realloc++] = i;
+				break;
+		}
+	}
+	realloc_pages[nr_realloc] = -1;
+
+	/* 2) series continuity rules.
+	 * In most cases, the first allocation from SwapDevice has the best
+	 * continuity, so our principle is
+	 * A) don't destroy the continuity of the remain serieses.
+	 * B) don't propagate the destroyed series to others!
+	 */
+	prev = series->swps[0];
+	if (prev.val != 0) {
+		for (i = 1; i < series->series_length; i++, prev = next) {
+			next = series->swps[i];
+			if (next.val == 0)
+				break;
+			if (swp_type(prev) != swp_type(next))
+				break;
+			if (abs(swp_offset(prev) - swp_offset(next)) > 2)
+				break;
+		}
+		if (i == series->series_length)
+			// The series has the best continuity, flush it
+			// directly.
+			goto flush_it;
+	}
+	/*
+	 * last_nail_swp represents the continuity of former series, which
+	 * maybe is re-positioned to somewhere-else due to SwapDevice shortage,
+	 * so according the rules, last_nail_swp should be placed at the tail
+	 * of nail_swps, not the head! It's IMPORTANT!
+	 */
+	if (node_data->last_nail_addr != 0) {
+		// Reset nail if it's too far from us.
+		if (series->addrs[0] - node_data->last_nail_addr > 8 *
+				PAGE_SIZE)
+			node_data->last_nail_addr = 0;
+	}
+	if (node_data->last_nail_addr != 0)
+		nail_swps[nr_nail++] = swp_entry(node_data->last_nail_swp_type,
+				node_data->last_nail_swp_offset);
+	nail_swps[nr_nail].val = 0;
+
+	// 3) nail arithmetic and flush them.
+	if (sc->may_swap && nr_realloc != 0)
+		pps_stage3(series, nail_swps, realloc_pages);
+flush_it:
+	if (sc->may_writepage && (sc->gfp_mask & (__GFP_FS | __GFP_IO))) {
+		for (i = 0; i < nr_realloc; i++)
+			// pages are unlocked in pps_stage4 >> swap_writepage.
+			pps_stage4(series->pages[realloc_pages[i]]);
+	} else {
+		for (i = 0; i < nr_realloc; i++)
+			unlock_page(series->pages[realloc_pages[i]]);
+	}
+
+	// 4) boost last_nail_swp.
+	for (i = series->series_length - 1; i >= 0; i--) {
+		pte_t pte = *series->ptes[i];
+		if (pte_none(pte))
+			continue;
+		else if ((!pte_present(pte) && pte_unmapped(pte)) ||
+				pte_present(pte)) {
+			struct page* page = pfn_to_page(pte_pfn(pte));
+			nail_swps[0].val = page_private(page);
+			if (nail_swps[0].val == 0)
+				continue;
+			node_data->last_nail_swp_type = swp_type(nail_swps[0]);
+			node_data->last_nail_swp_offset =
+				swp_offset(nail_swps[0]);
+		} else if (pte_swapped(pte)) {
+			nail_swps[0] = pte_to_swp_entry(pte);
+			node_data->last_nail_swp_type = swp_type(nail_swps[0]);
+			node_data->last_nail_swp_offset =
+				swp_offset(nail_swps[0]);
+		}
+		node_data->last_nail_addr = series->addrs[i];
+		break;
+	}
+
+	return nr_reclaimed;
+}
+
+static unsigned long shrink_pvma_scan_ptes(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pmd_t* pmd, unsigned
+		long addr, unsigned long end)
+{
+	spinlock_t* ptl = pte_lockptr(mm, pmd);
+	pte_t* pte = pte_offset_map(pmd, addr);
+	struct series_t series;
+	unsigned long nr_reclaimed = 0;
+	struct pagevec freed_pvec;
+	pagevec_init(&freed_pvec, 1);
+
+	do {
+		memset(&series, 0, sizeof(struct series_t));
+		if (sc->is_kppsd) {
+			find_series(&series, &pte, &addr, end);
+			BUG_ON(series.series_length == 0);
+			switch (series.series_stage) {
+				case 1: // PresentPTE -- untouched PTE.
+					pps_stage1(ptl, vma, addr, &series);
+					break;
+				case 2: // untouched PTE -- UnmappedPTE.
+					pps_stage2(vma, pmd, &series);
+					break;
+				case 3 ... 5:
+	/* We can collect unmapped_age defined in <stage definition> here by
+	 * the scanning count of global kppsd.
+	spin_lock(ptl);
+	for (i = 0; i < series.series_length; i++) {
+		if (pte_unmapped(series.ptes[i]))
+			((struct pps_page*) series.pages[i])->unmapped_age++;
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	*/
+					break;
+			}
+		} else {
+			find_series_pgdata(&series, &pte, &addr, end);
+			BUG_ON(series.series_length == 0);
+			nr_reclaimed += pps_shrink_pgdata(sc, &series, mm, vma,
+					&freed_pvec, ptl);
+		}
+	} while (addr < end);
+	pte_unmap(pte);
+	if (pagevec_count(&freed_pvec))
+		__pagevec_release_nonlru(&freed_pvec);
+	return nr_reclaimed;
+}
+
+static unsigned long shrink_pvma_pmd_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pud_t* pud, unsigned
+		long addr, unsigned long end)
+{
+	unsigned long next;
+	unsigned long nr_reclaimed = 0;
+	pmd_t* pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		nr_reclaimed += shrink_pvma_scan_ptes(sc, mm, vma, pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+	return nr_reclaimed;
+}
+
+static unsigned long shrink_pvma_pud_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma, pgd_t* pgd, unsigned
+		long addr, unsigned long end)
+{
+	unsigned long next;
+	unsigned long nr_reclaimed = 0;
+	pud_t* pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		nr_reclaimed += shrink_pvma_pmd_range(sc, mm, vma, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+	return nr_reclaimed;
+}
+
+static unsigned long shrink_pvma_pgd_range(struct scan_control* sc, struct
+		mm_struct* mm, struct vm_area_struct* vma)
+{
+	unsigned long addr, end, next;
+	unsigned long nr_reclaimed = 0;
+	pgd_t* pgd;
+#define sppr(from, to) \
+	pgd = pgd_offset(mm, from); \
+	do { \
+		next = pgd_addr_end(addr, to); \
+		if (pgd_none_or_clear_bad(pgd)) \
+			continue; \
+		nr_reclaimed+=shrink_pvma_pud_range(sc,mm,vma,pgd,from,next); \
+	} while (pgd++, from = next, from != to);
+
+	if (sc->is_kppsd) {
+		addr = vma->vm_start;
+		end = vma->vm_end;
+		sppr(addr, end)
+	} else {
+#ifdef CONFIG_NUMA
+		unsigned long start = end = -1;
+		// Enumerate all ptes of the memory-inode according to start
+		// and end, call sppr(start, end).
+#else
+		addr = vma->vm_start;
+		end = vma->vm_end;
+		sppr(addr, end)
+#endif
+	}
+#undef sppr
+	return nr_reclaimed;
+}
+
+static unsigned long shrink_private_vma(struct scan_control* sc)
+{
+	struct vm_area_struct* vma;
+	struct list_head *pos;
+	struct mm_struct *prev, *mm;
+	unsigned long nr_reclaimed = 0;
+
+	prev = mm = &init_mm;
+	pos = &init_mm.mmlist;
+	atomic_inc(&prev->mm_users);
+	spin_lock(&mmlist_lock);
+	while ((pos = pos->next) != &init_mm.mmlist) {
+		mm = list_entry(pos, struct mm_struct, mmlist);
+		if (!atomic_inc_not_zero(&mm->mm_users))
+			continue;
+		spin_unlock(&mmlist_lock);
+		mmput(prev);
+		prev = mm;
+		if (down_read_trylock(&mm->mmap_sem)) {
+			if (sc->is_kppsd) {
+				start_dftlb(mm);
+			} else {
+				struct pglist_data* node_data =
+					NODE_DATA(sc->reclaim_node);
+				node_data->last_nail_addr = 0;
+			}
+			for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
+				// More tasks can be done by kppsd on <New core daemon --
+				// kppsd> section.
+				if (!(vma->vm_flags & VM_PURE_PRIVATE))
+					continue;
+				if (vma->vm_flags & VM_LOCKED)
+					continue;
+				nr_reclaimed+=shrink_pvma_pgd_range(sc,mm,vma);
+			}
+			if (sc->is_kppsd)
+				end_dftlb();
+			up_read(&mm->mmap_sem);
+		}
+		spin_lock(&mmlist_lock);
+	}
+	spin_unlock(&mmlist_lock);
+	mmput(prev);
+	return nr_reclaimed;
+}
+
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
@@ -1131,6 +1875,8 @@
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
+		.reclaim_node = pgdat->node_id,
+		.is_kppsd = 0,
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which
@@ -1144,6 +1890,11 @@
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);

+	if (pgdat->nr_present_pte.counter > pgdat->nr_unmapped_pte.counter)
+		wake_up(&kppsd_wait);
+	accelerate_kppsd++;
+	nr_reclaimed += shrink_private_vma(&sc);
+
 	for (i = 0; i < pgdat->nr_zones; i++)
 		temp_priority[i] = DEF_PRIORITY;

@@ -1729,3 +2480,33 @@
 	return __zone_reclaim(zone, gfp_mask, order);
 }
 #endif
+
+static int kppsd(void* p)
+{
+	struct task_struct *tsk = current;
+	struct scan_control default_sc;
+	DEFINE_WAIT(wait);
+	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	default_sc.gfp_mask = GFP_KERNEL;
+	default_sc.may_swap = 1;
+	default_sc.reclaim_node = -1;
+	default_sc.is_kppsd = 1;
+
+	while (1) {
+		try_to_freeze();
+ 		accelerate_kppsd >>= 1;
+		wait_event_timeout(kppsd_wait, accelerate_kppsd != 0,
+				msecs_to_jiffies(16000));
+		shrink_private_vma(&default_sc);
+	}
+	return 0;
+}
+
+static int __init kppsd_init(void)
+{
+	init_waitqueue_head(&kppsd_wait);
+	kthread_run(kppsd, NULL, "kppsd");
+	return 0;
+}
+
+module_init(kppsd_init)
Index: linux-2.6.22/mm/vmstat.c
===================================================================
--- linux-2.6.22.orig/mm/vmstat.c	2007-08-23 15:26:44.854410322 +0800
+++ linux-2.6.22/mm/vmstat.c	2007-08-23 15:30:09.575204572 +0800
@@ -609,6 +609,17 @@
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
+	seq_printf(m,
+			"\n------------------------"
+			"\n  nr_pps_total:       %i"
+			"\n  nr_present_pte:     %i"
+			"\n  nr_unmapped_pte:    %i"
+			"\n  nr_swapped_pte:     %i",
+			pgdat->nr_pps_total.counter,
+			pgdat->nr_present_pte.counter,
+			pgdat->nr_unmapped_pte.counter,
+			pgdat->nr_swapped_pte.counter);
+	seq_putc(m, '\n');
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
