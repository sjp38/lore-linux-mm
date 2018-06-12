Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05A4D6B026F
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:16:45 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 89-v6so13558834plc.1
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:16:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33-v6sor78565ply.63.2018.06.12.00.16.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 00:16:43 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 1/3] Revert "mm: always flush VMA ranges affected by zap_page_range"
Date: Tue, 12 Jun 2018 17:16:19 +1000
Message-Id: <20180612071621.26775-2-npiggin@gmail.com>
In-Reply-To: <20180612071621.26775-1-npiggin@gmail.com>
References: <20180612071621.26775-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

This reverts commit 4647706ebeee6e50f7b9f922b095f4ec94d581c3.

Patch 99baac21e4585 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss
problem") provides a superset of the TLB flush coverage of this
commit, and even includes in the changelog "this patch supersedes
'mm: Always flush VMA ranges affected by zap_page_range v2'".

Reverting this avoids double flushing the TLB range, and the less
efficient flush_tlb_range() call (the mmu_gather API is more precise
about what ranges it invalidates).

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/memory.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..9d472e00fc2d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1603,20 +1603,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, NULL);
-
-		/*
-		 * zap_page_range does not specify whether mmap_sem should be
-		 * held for read or write. That allows parallel zap_page_range
-		 * operations to unmap a PTE and defer a flush meaning that
-		 * this call observes pte_none and fails to flush the TLB.
-		 * Rather than adding a complex API, ensure that no stale
-		 * TLB entries exist when this call returns.
-		 */
-		flush_tlb_range(vma, start, end);
-	}
-
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }
-- 
2.17.0
