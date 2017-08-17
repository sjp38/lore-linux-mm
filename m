Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4C1C6B03AB
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i59so15710954wri.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:06:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m10si3329046wrb.254.2017.08.17.15.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:06:20 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7HM3tLt110388
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:19 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cdg4qtrhr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:18 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 Aug 2017 23:06:15 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 12/20] mm: Introduce __vm_normal_page()
Date: Fri, 18 Aug 2017 00:05:11 +0200
In-Reply-To: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1503007519-26777-13-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When dealing with the speculative fault path we should use the VMA's field
cached value stored in the vm_fault structure.

Currently vm_normal_page() is using the pointer to the VMA to fetch the
vm_flags value. This patch provides a new __vm_normal_page() which is
receiving the vm_flags flags value as parameter.

Note: The speculative path is turned on for architecture providing support
for special PTE flag. So only the first block of vm_normal_page is used
during the speculative path.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ad7b6372d302..9f9e5bb7a556 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -820,8 +820,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 #else
 # define HAVE_PTE_SPECIAL 0
 #endif
-struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-				pte_t pte)
+static struct page *__vm_normal_page(struct vm_area_struct *vma,
+				     unsigned long addr,
+				     pte_t pte, unsigned long vma_flags)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -830,7 +831,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			goto check_pfn;
 		if (vma->vm_ops && vma->vm_ops->find_special_page)
 			return vma->vm_ops->find_special_page(vma, addr);
-		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+		if (vma_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
 		if (!is_zero_pfn(pfn))
 			print_bad_pte(vma, addr, pte, NULL);
@@ -839,8 +840,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* !HAVE_PTE_SPECIAL case follows: */
 
-	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
-		if (vma->vm_flags & VM_MIXEDMAP) {
+	if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
 				return NULL;
 			goto out;
@@ -849,7 +850,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			off = (addr - vma->vm_start) >> PAGE_SHIFT;
 			if (pfn == vma->vm_pgoff + off)
 				return NULL;
-			if (!is_cow_mapping(vma->vm_flags))
+			if (!is_cow_mapping(vma_flags))
 				return NULL;
 		}
 	}
@@ -870,6 +871,13 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	return pfn_to_page(pfn);
 }
 
+struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			    pte_t pte)
+{
+	return __vm_normal_page(vma, addr, pte, vma->vm_flags);
+}
+
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 				pmd_t pmd)
@@ -2548,7 +2556,8 @@ static int do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
+	vmf->page = __vm_normal_page(vma, vmf->address, vmf->orig_pte,
+				     vmf->vma_flags);
 	if (!vmf->page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -3575,7 +3584,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	ptep_modify_prot_commit(vma->vm_mm, vmf->address, vmf->pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
-	page = vm_normal_page(vma, vmf->address, pte);
+	page = __vm_normal_page(vma, vmf->address, pte, vmf->vma_flags);
 	if (!page) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
