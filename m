Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 06 of 12] Move the tlb flushing inside of unmap vmas. This
	saves us from passing
Message-Id: <fbce3fecb033eb3fba1d.1208872282@duo.random>
In-Reply-To: <patchbomb.1208872276@duo.random>
Date: Tue, 22 Apr 2008 15:51:22 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1208872186 -7200
# Node ID fbce3fecb033eb3fba1d9c2398ac74401ce0ecb5
# Parent  ee8c0644d5f67c1ef59142cce91b0bb6f34a53e0
Move the tlb flushing inside of unmap vmas. This saves us from passing
a pointer to the TLB structure around and simplifies the callers.

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
@@ -804,7 +804,6 @@
 
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
  * @vma: the starting vma
  * @start_addr: virtual address at which to start unmapping
  * @end_addr: virtual address at which to end unmapping
@@ -816,20 +815,13 @@
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
@@ -838,9 +830,14 @@
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
-	int fullmm = (*tlbp)->fullmm;
+	int fullmm;
+	struct mmu_gather *tlb;
 	struct mm_struct *mm = vma->vm_mm;
 
+	lru_add_drain();
+	tlb = tlb_gather_mmu(mm, 0);
+	update_hiwater_rss(mm);
+	fullmm = tlb->fullmm;
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -867,7 +864,7 @@
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -875,22 +872,23 @@
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
+			tlb_finish_mmu(tlb, tlb_start, start);
 
 			if (need_resched() ||
 				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
 				if (i_mmap_lock) {
-					*tlbp = NULL;
+					tlb = NULL;
 					goto out;
 				}
 				cond_resched();
 			}
 
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+			tlb = tlb_gather_mmu(vma->vm_mm, fullmm);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
+	tlb_finish_mmu(tlb, start_addr, end_addr);
 out:
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
@@ -906,18 +904,10 @@
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
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
-	return end;
+	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1744,15 +1744,10 @@
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, start, end);
 	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 }
@@ -2034,7 +2029,6 @@
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2045,12 +2039,11 @@
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
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
