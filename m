Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34D7D6B002A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i4so16636506wrh.4
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y22si68826edi.278.2018.04.17.07.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:39 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HEStDk035179
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:38 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdj3sauew-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:37 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:33 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 15/25] mm: introduce __vm_normal_page()
Date: Tue, 17 Apr 2018 16:33:21 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-16-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
 include/linux/mm.h | 18 +++++++++++++++---
 mm/memory.c        | 25 ++++++++++++++++---------
 2 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c65205c8c558..f967bf84094f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1275,9 +1275,21 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
 #endif
 }
 
-struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t pte, bool with_public_device);
-#define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
+struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			      pte_t pte, bool with_public_device,
+			      unsigned long vma_flags);
+static inline struct page *_vm_normal_page(struct vm_area_struct *vma,
+					    unsigned long addr, pte_t pte,
+					    bool with_public_device)
+{
+	return __vm_normal_page(vma, addr, pte, with_public_device,
+				vma->vm_flags);
+}
+static inline struct page *vm_normal_page(struct vm_area_struct *vma,
+					  unsigned long addr, pte_t pte)
+{
+	return _vm_normal_page(vma, addr, pte, false);
+}
 
 struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 				pmd_t pmd);
diff --git a/mm/memory.c b/mm/memory.c
index 47af9e97f02a..d9146a0c3d25 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -780,7 +780,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 }
 
 /*
- * vm_normal_page -- This function gets the "struct page" associated with a pte.
+ * __vm_normal_page -- This function gets the "struct page" associated with
+ * a pte.
  *
  * "Special" mappings do not wish to be associated with a "struct page" (either
  * it doesn't exist, or it exists but they don't want to touch it). In this
@@ -826,8 +827,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 #else
 # define HAVE_PTE_SPECIAL 0
 #endif
-struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t pte, bool with_public_device)
+struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			      pte_t pte, bool with_public_device,
+			      unsigned long vma_flags)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -836,7 +838,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			goto check_pfn;
 		if (vma->vm_ops && vma->vm_ops->find_special_page)
 			return vma->vm_ops->find_special_page(vma, addr);
-		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+		if (vma_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
 		if (is_zero_pfn(pfn))
 			return NULL;
@@ -867,9 +869,13 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	}
 
 	/* !HAVE_PTE_SPECIAL case follows: */
+	/*
+	 * This part should never get called when CONFIG_SPECULATIVE_PAGE_FAULT
+	 * is set. This is mainly because we can't rely on vm_start.
+	 */
 
-	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
-		if (vma->vm_flags & VM_MIXEDMAP) {
+	if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
 				return NULL;
 			goto out;
@@ -878,7 +884,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			off = (addr - vma->vm_start) >> PAGE_SHIFT;
 			if (pfn == vma->vm_pgoff + off)
 				return NULL;
-			if (!is_cow_mapping(vma->vm_flags))
+			if (!is_cow_mapping(vma_flags))
 				return NULL;
 		}
 	}
@@ -2743,7 +2749,8 @@ static int do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
+	vmf->page = __vm_normal_page(vma, vmf->address, vmf->orig_pte, false,
+				     vmf->vma_flags);
 	if (!vmf->page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -3853,7 +3860,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	ptep_modify_prot_commit(vma->vm_mm, vmf->address, vmf->pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
-	page = vm_normal_page(vma, vmf->address, pte);
+	page = __vm_normal_page(vma, vmf->address, pte, false, vmf->vma_flags);
 	if (!page) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
-- 
2.7.4
