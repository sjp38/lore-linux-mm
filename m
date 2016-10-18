Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 973276B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:04:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so3561178pfz.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 16:04:13 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q199si34268236pgq.205.2016.10.18.16.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 16:04:12 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id s8so4037167pfj.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 16:04:12 -0700 (PDT)
Date: Tue, 18 Oct 2016 16:04:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: avoid unlikely branches for split_huge_pmd
Message-ID: <alpine.DEB.2.10.1610181600300.84525@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

While doing MADV_DONTNEED on a large area of thp memory, I noticed we 
encountered many unlikely() branches in profiles for each backing 
hugepage.  This is because zap_pmd_range() would call split_huge_pmd(), 
which rechecked the conditions that were already validated, but as part of 
an unlikely() branch.

Avoid the unlikely() branch when in a context where pmd is known to be 
good for __split_huge_pmd() directly.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/huge_mm.h | 2 ++
 mm/memory.c             | 4 ++--
 mm/mempolicy.c          | 2 +-
 mm/mprotect.c           | 2 +-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -189,6 +189,8 @@ static inline void deferred_split_huge_page(struct page *page) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 
+static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address, bool freeze, struct page *page) {}
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
 		unsigned long address, bool freeze, struct page *page) {}
 
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1240,7 +1240,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 			if (next - addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
 				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
-				split_huge_pmd(vma, pmd, addr);
+				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
@@ -3454,7 +3454,7 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
 
 	/* COW handled on pte level: split pmd */
 	VM_BUG_ON_VMA(fe->vma->vm_flags & VM_SHARED, fe->vma);
-	split_huge_pmd(fe->vma, fe->pmd, fe->address);
+	__split_huge_pmd(fe->vma, fe->pmd, fe->address, false, NULL);
 
 	return VM_FAULT_FALLBACK;
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -496,7 +496,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			page = pmd_page(*pmd);
 			if (is_huge_zero_page(page)) {
 				spin_unlock(ptl);
-				split_huge_pmd(vma, pmd, addr);
+				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
 				get_page(page);
 				spin_unlock(ptl);
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -164,7 +164,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-				split_huge_pmd(vma, pmd, addr);
+				__split_huge_pmd(vma, pmd, addr, false, NULL);
 				if (pmd_trans_unstable(pmd))
 					continue;
 			} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
