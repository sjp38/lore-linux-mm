Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 6 of 9] We no longer abort unmapping in unmap vmas because we
	can reschedule while
Message-Id: <b0cb674314534b9cc475.1207669449@duo.random>
In-Reply-To: <patchbomb.1207669443@duo.random>
Date: Tue, 08 Apr 2008 17:44:09 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1207666893 -7200
# Node ID b0cb674314534b9cc4759603f123474d38427b2d
# Parent  20e829e35dfeceeb55a816ef495afda10cd50b98
We no longer abort unmapping in unmap vmas because we can reschedule while
unmapping since we are holding a semaphore. This would allow moving more
of the tlb flusing into unmap_vmas reducing code in various places.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -723,8 +723,7 @@
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
-		struct vm_area_struct *start_vma, unsigned long start_addr,
+unsigned long unmap_vmas(struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -805,7 +805,6 @@
 
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
  * @vma: the starting vma
  * @start_addr: virtual address at which to start unmapping
  * @end_addr: virtual address at which to end unmapping
@@ -817,20 +816,13 @@
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
@@ -838,7 +830,15 @@
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	int fullmm = (*tlbp)->fullmm;
+	int fullmm;
+	struct mmu_gather *tlb;
+	struct mm_struct *mm = vma->vm_mm;
+
+	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	lru_add_drain();
+	tlb = tlb_gather_mmu(mm, 0);
+	update_hiwater_rss(mm);
+	fullmm = tlb->fullmm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -865,7 +865,7 @@
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -873,13 +873,15 @@
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
+	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -893,20 +895,10 @@
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	mmu_notifier_invalidate_range_end(mm, address, end);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
-	return end;
+	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1743,19 +1743,12 @@
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, start, end);
 	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 /*
@@ -2035,7 +2028,6 @@
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2046,12 +2038,9 @@
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
