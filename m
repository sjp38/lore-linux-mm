Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 456CA6B0070
	for <linux-mm@kvack.org>; Tue, 12 May 2015 02:09:31 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so134052434pac.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 23:09:31 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id fd5si21026232pab.145.2015.05.11.23.09.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 23:09:30 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 12 May 2015 11:39:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2CA951258053
	for <linux-mm@kvack.org>; Tue, 12 May 2015 11:41:35 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4C69NE463897744
	for <linux-mm@kvack.org>; Tue, 12 May 2015 11:39:23 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4C5Wosh018573
	for <linux-mm@kvack.org>; Tue, 12 May 2015 11:02:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V4 2/3] powerpc/mm: Use generic version of pmdp_clear_flush
Date: Tue, 12 May 2015 11:38:33 +0530
Message-Id: <1431410914-21102-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1431410914-21102-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431410914-21102-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Also move the pmd_trans_huge check to generic code.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h |  4 ----
 arch/powerpc/mm/pgtable_64.c             | 11 -----------
 mm/pgtable-generic.c                     |  1 +
 3 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index b8d99227a0ac..3d7e898d6b5e 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -557,10 +557,6 @@ extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
 extern pmd_t pmdp_get_and_clear(struct mm_struct *mm,
 				unsigned long addr, pmd_t *pmdp);
 
-#define __HAVE_ARCH_PMDP_CLEAR_FLUSH
-extern pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
-			      pmd_t *pmdp);
-
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
 static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pmd_t *pmdp)
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 049d961802aa..f7775193d745 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -554,17 +554,6 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 	return old;
 }
 
-pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
-		       pmd_t *pmdp)
-{
-	pmd_t pmd;
-
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(!pmd_trans_huge(*pmdp));
-	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
-	return pmd;
-}
-
 pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c25f94b33811..dd9d04f17749 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -126,6 +126,7 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 {
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG_ON(!pmd_trans_huge(*pmdp));
 	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
