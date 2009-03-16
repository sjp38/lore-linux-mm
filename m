Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5316B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:30:56 -0400 (EDT)
From: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Subject: [PATCH v2] [ARM] Flush only the needed range when unmapping a VMA
Date: Mon, 16 Mar 2009 15:30:01 +0200
Message-Id: <1237210201-27782-1-git-send-email-Aaro.Koskinen@nokia.com>
In-Reply-To: <49BE4D0E.8010006@nokia.com>
References: <49BE4D0E.8010006@nokia.com>
Sender: owner-linux-mm@kvack.org
To: linux@arm.linux.org.uk
Cc: linux-arm-kernel@lists.arm.linux.org.uk, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

When unmapping N pages (e.g. shared memory) the amount of TLB flushes
done can be (N*PAGE_SIZE/ZAP_BLOCK_SIZE)*N although it should be N at
maximum. With PREEMPT kernel ZAP_BLOCK_SIZE is 8 pages, so there is a
noticeable performance penalty when unmapping a large VMA and the system
is spending its time in flush_tlb_range().

The problem is that tlb_end_vma() is always flushing the full VMA
range. The subrange that needs to be flushed can be calculated by
tlb_remove_tlb_entry(). This approach was suggested by Hugh Dickins,
and is also used by other arches.

The speed increase is roughly 3x for 8M mappings and for larger mappings
even more.

Signed-off-by: Aaro Koskinen <Aaro.Koskinen@nokia.com>
---

v2: Patch description updated, no other changes.

 arch/arm/include/asm/tlb.h |   25 +++++++++++++++++++++----
 1 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 857f1df..321c83e 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -36,6 +36,8 @@
 struct mmu_gather {
 	struct mm_struct	*mm;
 	unsigned int		fullmm;
+	unsigned long		range_start;
+	unsigned long		range_end;
 };
 
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
@@ -63,7 +65,19 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 	put_cpu_var(mmu_gathers);
 }
 
-#define tlb_remove_tlb_entry(tlb,ptep,address)	do { } while (0)
+/*
+ * Memorize the range for the TLB flush.
+ */
+static inline void
+tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
+{
+	if (!tlb->fullmm) {
+		if (addr < tlb->range_start)
+			tlb->range_start = addr;
+		if (addr + PAGE_SIZE > tlb->range_end)
+			tlb->range_end = addr + PAGE_SIZE;
+	}
+}
 
 /*
  * In the case of tlb vma handling, we can optimise these away in the
@@ -73,15 +87,18 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 static inline void
 tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
-	if (!tlb->fullmm)
+	if (!tlb->fullmm) {
 		flush_cache_range(vma, vma->vm_start, vma->vm_end);
+		tlb->range_start = TASK_SIZE;
+		tlb->range_end = 0;
+	}
 }
 
 static inline void
 tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
-	if (!tlb->fullmm)
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end);
+	if (!tlb->fullmm && tlb->range_end > 0)
+		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
