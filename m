Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 223F26B007B
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 23:02:18 -0500 (EST)
Message-Id: <20100202040212.903079000@alcatraz.americas.sgi.com>
Date: Mon, 01 Feb 2010 22:01:47 -0600
From: Robin Holt <holt@sgi.com>
Subject: [RFP-V2 2/3] Fix unmap_vma() bug related to mmu_notifiers
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=mmu_notifier_tlb_v1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


unmap_vmas() can fail to correctly flush the TLB if a
callout to mmu_notifier_invalidate_range_start() sleeps.
The mmu_gather list is initialized prior to the callout. If it is reused
while the thread is sleeping, the mm field may be invalid.

If the task migrates to a different cpu, the task may use the wrong
mmu_gather.

The patch changes unmap_vmas() to initialize the mmu_gather
AFTER the mmu_notifier completes.

Signed-off-by: Jack Steiner <steiner@sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org

---

 include/linux/mm.h |    2 +-
 mm/memory.c        |   11 +++++++----
 mm/mmap.c          |    6 ++----
 3 files changed, 10 insertions(+), 9 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2010-01-25 01:45:37.000000000 -0600
+++ linux/include/linux/mm.h	2010-01-25 11:32:21.000000000 -0600
@@ -761,7 +761,7 @@ unsigned long zap_page_range(struct vm_a
 unsigned long unmap_vmas(struct mmu_gather **tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *);
+		struct zap_details *, int fullmm);
 
 /**
  * mm_walk - callbacks for walk_page_range
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2010-01-25 01:45:37.000000000 -0600
+++ linux/mm/memory.c	2010-01-25 11:32:21.000000000 -0600
@@ -1010,17 +1010,21 @@ static unsigned long unmap_page_range(st
 unsigned long unmap_vmas(struct mmu_gather **tlbp,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *details)
+		struct zap_details *details, int fullmm)
 {
 	long zap_work = ZAP_BLOCK_SIZE;
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
-	int fullmm = (*tlbp)->fullmm;
 	struct mm_struct *mm = vma->vm_mm;
 
+	/*
+	 * mmu_notifier_invalidate_range_start can sleep. Don't initialize
+	 * mmu_gather until it completes
+	 */
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	*tlbp = tlb_gather_mmu(mm, fullmm);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
 
@@ -1108,9 +1112,8 @@ unsigned long zap_page_range(struct vm_a
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details, 0);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2010-01-25 01:45:37.000000000 -0600
+++ linux/mm/mmap.c	2010-01-25 11:35:55.000000000 -0600
@@ -1824,9 +1824,8 @@ static void unmap_region(struct mm_struc
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL, 0);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
@@ -2168,10 +2167,9 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL, 1);
 	vm_unacct_memory(nr_accounted);
 
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
