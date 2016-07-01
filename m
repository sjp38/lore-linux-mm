Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B02466B025E
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so204227153pfb.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ai12si908080pac.139.2016.06.30.17.12.29
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:29 -0700 (PDT)
Subject: [PATCH 3/6] mm: add force_batch_flush to mmu_gather
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:14 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001214.94D8F14C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Currently, zap_pte_range() has a local variable called
'force_flush'.  It is set when the zapping code runs in to an
entry that requires flushing before the ptl is released.

Currently, there are two reasons we might do that:
1. The TLB batching in __tlb_remove_page() has run out of
   space and can no longer record new pages being flushed.
2. An entry for a dirty page was flushed, and we need to
   ensure that software walking the page tables can not
   observe the cleared bit before we flush the TLB.

We need the x86 code to be able to force a flush for an
additional reason: if the PTE being cleared might have a stray
Accessed or Dirty bit set on it because of a hardware erratum.
For these purposes, we also need to flush before the ptl is
released.  So, we move the 'force_flush' variable into the
mmu_gather structure where we can set it from arch code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/arm/include/asm/tlb.h  |    1 +
 b/arch/ia64/include/asm/tlb.h |    1 +
 b/arch/s390/include/asm/tlb.h |    1 +
 b/arch/sh/include/asm/tlb.h   |    1 +
 b/arch/um/include/asm/tlb.h   |    1 +
 b/include/asm-generic/tlb.h   |    3 +++
 b/mm/memory.c                 |   22 ++++++++++++----------
 7 files changed, 20 insertions(+), 10 deletions(-)

diff -puN arch/arm/include/asm/tlb.h~knl-leak-30-tlb_force_flush arch/arm/include/asm/tlb.h
--- a/arch/arm/include/asm/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.021222437 -0700
+++ b/arch/arm/include/asm/tlb.h	2016-06-30 17:10:42.037223163 -0700
@@ -69,6 +69,7 @@ struct mmu_gather {
 	unsigned int		need_flush;
 #endif
 	unsigned int		fullmm;
+	unsigned int		force_batch_flush;
 	struct vm_area_struct	*vma;
 	unsigned long		start, end;
 	unsigned long		range_start;
diff -puN arch/ia64/include/asm/tlb.h~knl-leak-30-tlb_force_flush arch/ia64/include/asm/tlb.h
--- a/arch/ia64/include/asm/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.022222482 -0700
+++ b/arch/ia64/include/asm/tlb.h	2016-06-30 17:10:42.037223163 -0700
@@ -57,6 +57,7 @@ struct mmu_gather {
 	unsigned int		nr;
 	unsigned int		max;
 	unsigned char		fullmm;		/* non-zero means full mm flush */
+	unsigned int		force_batch_flush; /* stop batching and flush */
 	unsigned char		need_flush;	/* really unmapped some PTEs? */
 	unsigned long		start, end;
 	unsigned long		start_addr;
diff -puN arch/s390/include/asm/tlb.h~knl-leak-30-tlb_force_flush arch/s390/include/asm/tlb.h
--- a/arch/s390/include/asm/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.024222573 -0700
+++ b/arch/s390/include/asm/tlb.h	2016-06-30 17:10:42.038223208 -0700
@@ -32,6 +32,7 @@ struct mmu_gather {
 	struct mm_struct *mm;
 	struct mmu_table_batch *batch;
 	unsigned int fullmm;
+	unsigned int force_batch_flush; /* stop batching and flush */
 	unsigned long start, end;
 };
 
diff -puN arch/sh/include/asm/tlb.h~knl-leak-30-tlb_force_flush arch/sh/include/asm/tlb.h
--- a/arch/sh/include/asm/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.025222618 -0700
+++ b/arch/sh/include/asm/tlb.h	2016-06-30 17:10:42.038223208 -0700
@@ -21,6 +21,7 @@
 struct mmu_gather {
 	struct mm_struct	*mm;
 	unsigned int		fullmm;
+	unsigned int		force_batch_flush; /* stop batching and flush */
 	unsigned long		start, end;
 };
 
diff -puN arch/um/include/asm/tlb.h~knl-leak-30-tlb_force_flush arch/um/include/asm/tlb.h
--- a/arch/um/include/asm/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.027222709 -0700
+++ b/arch/um/include/asm/tlb.h	2016-06-30 17:10:42.039223253 -0700
@@ -20,6 +20,7 @@ struct mmu_gather {
 	unsigned long		start;
 	unsigned long		end;
 	unsigned int		fullmm; /* non-zero means full mm flush */
+	unsigned int		force_batch_flush; /* stop batching and flush */
 };
 
 static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
diff -puN include/asm-generic/tlb.h~knl-leak-30-tlb_force_flush include/asm-generic/tlb.h
--- a/include/asm-generic/tlb.h~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.028222754 -0700
+++ b/include/asm-generic/tlb.h	2016-06-30 17:10:42.039223253 -0700
@@ -102,6 +102,9 @@ struct mmu_gather {
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
 				need_flush_all : 1,
+	/* need to flush the tlb and stop batching
+	 * before we release ptl */
+				force_batch_flush : 1,
 	/* we cleared a PTE bit which may potentially
 	 * get set by hardware */
 				saw_unset_a_or_d: 1;
diff -puN mm/memory.c~knl-leak-30-tlb_force_flush mm/memory.c
--- a/mm/memory.c~knl-leak-30-tlb_force_flush	2016-06-30 17:10:42.031222890 -0700
+++ b/mm/memory.c	2016-06-30 17:10:42.040223299 -0700
@@ -225,6 +225,7 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->fullmm		= !(start | (end+1));
 	tlb->need_flush_all	= 0;
 	tlb->saw_unset_a_or_d	= 0;
+	tlb->force_batch_flush	= 0;
 
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
@@ -1105,7 +1106,6 @@ static unsigned long zap_pte_range(struc
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
-	int force_flush = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
 	pte_t *start_pte;
@@ -1151,7 +1151,7 @@ again:
 					 */
 					if (unlikely(details && details->ignore_dirty))
 						continue;
-					force_flush = 1;
+					tlb->force_batch_flush = 1;
 					set_page_dirty(page);
 				}
 				if (pte_young(ptent) &&
@@ -1163,7 +1163,7 @@ again:
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(!__tlb_remove_page(tlb, page))) {
-				force_flush = 1;
+				tlb->force_batch_flush = 1;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1191,18 +1191,20 @@ again:
 	arch_leave_lazy_mmu_mode();
 
 	/* Do the actual TLB flush before dropping ptl */
-	if (force_flush)
+	if (tlb->force_batch_flush)
 		tlb_flush_mmu_tlbonly(tlb);
 	pte_unmap_unlock(start_pte, ptl);
 
 	/*
-	 * If we forced a TLB flush (either due to running out of
-	 * batch buffers or because we needed to flush dirty TLB
-	 * entries before releasing the ptl), free the batched
-	 * memory too. Restart if we didn't do everything.
+	 * If we forced a TLB flush, free the batched
+	 * memory too.  Restart if we didn't do everything.
+	 *
+	 * We force this due to running out of batch buffers,
+	 * needing to flush dirty TLB entries before releasing
+	 * the ptl, or for arch-specific reasons.
 	 */
-	if (force_flush) {
-		force_flush = 0;
+	if (tlb->force_batch_flush) {
+		tlb->force_batch_flush = 0;
 		tlb_flush_mmu_free(tlb);
 
 		if (addr != end)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
