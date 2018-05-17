Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00B186B04C6
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:44 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p126-v6so3597129qke.6
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i10-v6si4829706qvi.78.2018.05.17.04.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:07:43 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB4E6a138478
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:42 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j18149pxu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:41 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:07:22 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 16/26] mm: introduce __vm_normal_page()
Date: Thu, 17 May 2018 13:06:23 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-17-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
 mm/memory.c        | 21 ++++++++++++---------
 2 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f385d721867d..bcebec117d4d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1317,9 +1317,21 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
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
index deac7f12d777..cc4e6221ee7b 100644
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
@@ -821,8 +822,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t pte, bool with_public_device)
+struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			      pte_t pte, bool with_public_device,
+			      unsigned long vma_flags)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -831,7 +833,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			goto check_pfn;
 		if (vma->vm_ops && vma->vm_ops->find_special_page)
 			return vma->vm_ops->find_special_page(vma, addr);
-		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+		if (vma_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
 		if (is_zero_pfn(pfn))
 			return NULL;
@@ -863,8 +865,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* !CONFIG_ARCH_HAS_PTE_SPECIAL case follows: */
 
-	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
-		if (vma->vm_flags & VM_MIXEDMAP) {
+	if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
 				return NULL;
 			goto out;
@@ -873,7 +875,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			off = (addr - vma->vm_start) >> PAGE_SHIFT;
 			if (pfn == vma->vm_pgoff + off)
 				return NULL;
-			if (!is_cow_mapping(vma->vm_flags))
+			if (!is_cow_mapping(vma_flags))
 				return NULL;
 		}
 	}
@@ -2753,7 +2755,8 @@ static int do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
+	vmf->page = __vm_normal_page(vma, vmf->address, vmf->orig_pte, false,
+				     vmf->vma_flags);
 	if (!vmf->page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -3863,7 +3866,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	ptep_modify_prot_commit(vma->vm_mm, vmf->address, vmf->pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
-	page = vm_normal_page(vma, vmf->address, pte);
+	page = __vm_normal_page(vma, vmf->address, pte, false, vmf->vma_flags);
 	if (!page) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
-- 
2.7.4
