Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41F746B0256
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:39 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fe3so62437910pab.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e69si1448939pfd.66.2016.03.10.15.55.38
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:38 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 02/14] mm: Convert an open-coded VM_BUG_ON_VMA
Date: Thu, 10 Mar 2016 18:55:19 -0500
Message-Id: <1457654131-4562-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

Spotted during PUD support review.

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/memory.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index a975fd4..12fc10e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1182,15 +1182,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-#ifdef CONFIG_DEBUG_VM
-				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
-					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
-						__func__, addr, end,
-						vma->vm_start,
-						vma->vm_end);
-					BUG();
-				}
-#endif
+				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				split_huge_pmd(vma, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
