Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 857A86B004F
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 09:00:28 -0400 (EDT)
From: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Subject: [RFC PATCH 2/2] ARM: tlb: Use range in tlb_start_vma() and tlb_end_vma()
Date: Mon,  9 Mar 2009 14:59:57 +0200
Message-Id: <1236603597-1646-2-git-send-email-Aaro.Koskinen@nokia.com>
In-Reply-To: <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com>
References: <49B511E9.8030405@nokia.com>
 <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Flush only the pages that were unmapped.

Signed-off-by: Aaro Koskinen <Aaro.Koskinen@nokia.com>
---
 arch/arm/include/asm/tlb.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index d10c9c3..a034b6d 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -68,14 +68,14 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
+ * the range is adjusted to only cover the region to be torn down.
  */
 static inline void
 tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	      unsigned long range_start, unsigned long range_end)
 {
 	if (!tlb->fullmm)
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
+		flush_cache_range(vma, range_start, range_end);
 }
 
 static inline void
@@ -83,7 +83,7 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	    unsigned long range_start, unsigned long range_end)
 {
 	if (!tlb->fullmm)
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end);
+		flush_tlb_range(vma, range_start, range_end);
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
