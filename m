From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 4/9] Remove tlb pointer from the parameters of
	unmap vmas
Date: Tue, 01 Apr 2008 13:55:35 -0700
Message-ID: <20080401205636.524832964@sgi.com>
References: <20080401205531.986291575@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=cleanup_unmap_vmas
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Hugh Dickins <hugh@veritas.com>
Cc: steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

We no longer abort unmapping in unmap vmas because we can reschedule while
unmapping since we are holding a semaphore. This would allow moving more
of the tlb flusing into unmap_vmas reducing code in various places.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    3 +--
 mm/memory.c        |   43 +++++++++++++++++--------------------------
 mm/mmap.c          |   18 +++---------------
 3 files changed, 21 insertions(+), 43 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-04-01 13:02:41.374608387 -0700
+++ linux-2.6/include/linux/mm.h	2008-04-01 13:02:43.898651546 -0700
@@ -723,8 +723,7 @@ struct zap_details {
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
-		struct vm_area_struct *start_vma, unsigned long start_addr,
+unsigned long unmap_vmas(struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-04-01 13:02:41.378608315 -0700
+++ linux-2.6/mm/memory.c	2008-04-01 13:02:43.902651345 -0700
@@ -806,7 +806,6 @@ static unsigned long unmap_page_range(st
 
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
  * @vma: the starting vma
  * @start_addr: virtual address at which to start unmapping
  * @end_addr: virtual address at which to end unmapping
@@ -818,20 +817,13 @@ static unsigned long unmap_page_range(st
  * Unmap all pages in the vma list.
  *
  * We aim to not hold locks for too long (for scheduling latency reasons).
- * So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
- * return the ending mmu_gather to the caller.
+ * So zap pages in ZAP_BLOCK_SIZE bytecounts.
  *
  * Only addresses between `start' and `end' will be unmapped.
  *
  * The VMA list must be sorted in ascending virtual address order.
- *
- * unmap_vmas() assumes that the caller will flush the whole unmapped address
- * range after unmap_vmas() returns.  So the only responsibility here is to
- * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
- * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
-		struct vm_area_struct *vma, unsigned long start_addr,
+unsigned long unmap_vmas(struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
@@ -839,7 +831,15 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	int fullmm = (*tlbp)->fullmm;
+	int fullmm;
+	struct mmu_gather *tlb;
+	struct mm_struct *mm = vma->vm_mm;
+
+	emm_notify(mm, emm_invalidate_start, start_addr, end_addr);
+	lru_add_drain();
+	tlb = tlb_gather_mmu(mm, 0);
+	update_hiwater_rss(mm);
+	fullmm = tlb->fullmm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -866,7 +866,7 @@ unsigned long unmap_vmas(struct mmu_gath
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -874,13 +874,15 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
+			tlb_finish_mmu(tlb, tlb_start, start);
 			cond_resched();
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+			tlb = tlb_gather_mmu(vma->vm_mm, fullmm);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
+	tlb_finish_mmu(tlb, start_addr, end_addr);
+	emm_notify(mm, emm_invalidate_end, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -894,21 +896,10 @@ unsigned long unmap_vmas(struct mmu_gath
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
-	emm_notify(mm, emm_invalidate_start, address, end);
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
-	emm_notify(mm, emm_invalidate_end, address, end);
-	return end;
+	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
 
 /*
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-04-01 13:02:41.378608315 -0700
+++ linux-2.6/mm/mmap.c	2008-04-01 13:03:19.627259624 -0700
@@ -1741,19 +1741,12 @@ static void unmap_region(struct mm_struc
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	emm_notify(mm, emm_invalidate_start, start, end);
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, start, end);
 	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
 /*
@@ -2033,7 +2026,6 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2041,15 +2033,11 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 	emm_notify(mm, emm_release, 0, TASK_SIZE);
-
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
-	/* Don't update_hiwater_rss(mm) here, do_exit already did */
-	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+
+	end = unmap_vmas(vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, 0, end);
 	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*

-- 

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
