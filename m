Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l63CADl2308710
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 12:10:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l63CADPO1032436
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l63CACA6019527
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:13 +0200
Message-Id: <20070703121228.254110263@de.ibm.com>
References: <20070703111822.418649776@de.ibm.com>
Date: Tue, 03 Jul 2007 13:18:23 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/5] avoid tlb gather restarts.
Content-Disposition: inline; filename=001-flush-restarts.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, hugh@veritas.com, peterz@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

If need_resched() is false in the inner loop of unmap_vmas it is
unnecessary to do a full blown tlb_finish_mmu / tlb_gather_mmu for
each ZAP_BLOCK_SIZE ptes. Do a tlb_flush_mmu() instead. That gives
architectures with a non-generic tlb flush implementation room for
optimization. The tlb_flush_mmu primitive is a available with the
generic tlb flush code, the ia64_tlb_flush_mm needs to be renamed
and a dummy function is added to arm and arm26.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/asm-arm/tlb.h   |    5 +++++
 include/asm-arm26/tlb.h |    5 +++++
 include/asm-ia64/tlb.h  |    6 +++---
 mm/memory.c             |   16 ++++++----------
 4 files changed, 19 insertions(+), 13 deletions(-)

diff -urpN linux-2.6/include/asm-arm/tlb.h linux-2.6-patched/include/asm-arm/tlb.h
--- linux-2.6/include/asm-arm/tlb.h	2006-11-08 10:45:43.000000000 +0100
+++ linux-2.6-patched/include/asm-arm/tlb.h	2007-07-03 12:56:46.000000000 +0200
@@ -52,6 +52,11 @@ tlb_gather_mmu(struct mm_struct *mm, uns
 }
 
 static inline void
+tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+{
+}
+
+static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	if (tlb->fullmm)
diff -urpN linux-2.6/include/asm-arm26/tlb.h linux-2.6-patched/include/asm-arm26/tlb.h
--- linux-2.6/include/asm-arm26/tlb.h	2006-11-08 10:45:43.000000000 +0100
+++ linux-2.6-patched/include/asm-arm26/tlb.h	2007-07-03 12:56:46.000000000 +0200
@@ -29,6 +29,11 @@ tlb_gather_mmu(struct mm_struct *mm, uns
 }
 
 static inline void
+tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+{
+}
+
+static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
         if (tlb->need_flush)
diff -urpN linux-2.6/include/asm-ia64/tlb.h linux-2.6-patched/include/asm-ia64/tlb.h
--- linux-2.6/include/asm-ia64/tlb.h	2006-11-08 10:45:45.000000000 +0100
+++ linux-2.6-patched/include/asm-ia64/tlb.h	2007-07-03 12:56:46.000000000 +0200
@@ -72,7 +72,7 @@ DECLARE_PER_CPU(struct mmu_gather, mmu_g
  * freed pages that where gathered up to this point.
  */
 static inline void
-ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	unsigned int nr;
 
@@ -160,7 +160,7 @@ tlb_finish_mmu (struct mmu_gather *tlb, 
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
 	 */
-	ia64_tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb, start, end);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
@@ -184,7 +184,7 @@ tlb_remove_page (struct mmu_gather *tlb,
 	}
 	tlb->pages[tlb->nr++] = page;
 	if (tlb->nr >= FREE_PTE_NR)
-		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+		tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
 }
 
 /*
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-07-03 12:56:46.000000000 +0200
@@ -853,18 +853,15 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
-
 			if (need_resched() ||
 				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
+				if (i_mmap_lock)
 					goto out;
-				}
+				tlb_finish_mmu(*tlbp, tlb_start, start);
 				cond_resched();
-			}
-
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+				*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+			} else
+				tlb_flush_mmu(*tlbp, tlb_start, start);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
@@ -892,8 +889,7 @@ unsigned long zap_page_range(struct vm_a
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
+	tlb_finish_mmu(tlb, address, end);
 	return end;
 }
 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
