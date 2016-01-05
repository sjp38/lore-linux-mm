Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3136B0007
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:30:18 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id do7so284720pab.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:30:18 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id h10si61187382pat.126.2016.01.05.10.30.14
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 10:30:14 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 1/8] mm: Convert an open-coded VM_BUG_ON_VMA
Date: Tue,  5 Jan 2016 13:30:03 -0500
Message-Id: <1452018610-26090-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

Spotted during PUD support review.

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/memory.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 416b129..8c6392c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1178,15 +1178,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
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
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
