Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5TEDN0L047490
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 14:13:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5TEDN7t2072770
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5TEDNFG015999
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Message-Id: <20070629141527.557443600@de.ibm.com>
References: <20070629135530.912094590@de.ibm.com>
Date: Fri, 29 Jun 2007 15:55:31 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/5] avoid tlb gather restarts.
Content-Disposition: inline; filename=002-flush-restarts.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

If need_resched() is false it is unnecessary to call tlb_finish_mmu()
and tlb_gather_mmu() for each vma in unmap_vmas(). Moving the tlb gather
restart under the if that contains the cond_resched() will avoid
unnecessary tlb flush operations that are triggered by tlb_finish_mmu() 
and tlb_gather_mmu().

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 mm/memory.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-29 15:44:08.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-29 15:44:08.000000000 +0200
@@ -851,19 +851,18 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
-
 			if (need_resched() ||
 				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
+				tlb_finish_mmu(*tlbp, tlb_start, start);
 				if (i_mmap_lock) {
 					*tlbp = NULL;
 					goto out;
 				}
 				cond_resched();
+				*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+				tlb_start_valid = 0;
 			}
 
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
-			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
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
