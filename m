Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4AABE6B027D
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:51:18 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id c20so18026129pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:51:18 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id n3si3657377pfb.123.2016.04.05.13.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:51:17 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id n1so17990671pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:51:17 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:51:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 07/10] huge mm: move_huge_pmd does not need new_vma
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051349410.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Remove move_huge_pmd()'s redundant new_vma arg: all it was used for was
a VM_NOHUGEPAGE check on new_vma flags, but the new_vma is cloned from
the old vma, so a trans_huge_pmd in the new_vma will be as acceptable
as it was in the old vma, alignment and size permitting.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/huge_mm.h |    4 +---
 mm/huge_memory.c        |    7 ++-----
 mm/mremap.c             |    5 ++---
 3 files changed, 5 insertions(+), 11 deletions(-)

--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -28,9 +28,7 @@ extern int zap_huge_pmd(struct mmu_gathe
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
-extern bool move_huge_pmd(struct vm_area_struct *vma,
-			 struct vm_area_struct *new_vma,
-			 unsigned long old_addr,
+extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 			 unsigned long new_addr, unsigned long old_end,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1704,20 +1704,17 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 	return 1;
 }
 
-bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
-		  unsigned long old_addr,
+bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
 {
 	spinlock_t *old_ptl, *new_ptl;
 	pmd_t pmd;
-
 	struct mm_struct *mm = vma->vm_mm;
 
 	if ((old_addr & ~HPAGE_PMD_MASK) ||
 	    (new_addr & ~HPAGE_PMD_MASK) ||
-	    old_end - old_addr < HPAGE_PMD_SIZE ||
-	    (new_vma->vm_flags & VM_NOHUGEPAGE))
+	    old_end - old_addr < HPAGE_PMD_SIZE)
 		return false;
 
 	/*
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -198,9 +198,8 @@ unsigned long move_page_tables(struct vm
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					anon_vma_lock_write(vma->anon_vma);
-				moved = move_huge_pmd(vma, new_vma, old_addr,
-						    new_addr, old_end,
-						    old_pmd, new_pmd);
+				moved = move_huge_pmd(vma, old_addr, new_addr,
+						    old_end, old_pmd, new_pmd);
 				if (need_rmap_locks)
 					anon_vma_unlock_write(vma->anon_vma);
 				if (moved) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
