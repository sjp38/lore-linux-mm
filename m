Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 746816B0022
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 96so382592wrk.12
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:00:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m5si460157edd.209.2018.03.13.11.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:00:42 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DHsprZ034304
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:40 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpjjrah66-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:39 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 18:00:35 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v9 14/24] mm: Introduce __maybe_mkwrite()
Date: Tue, 13 Mar 2018 18:59:44 +0100
In-Reply-To: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1520963994-28477-15-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

The current maybe_mkwrite() is getting passed the pointer to the vma
structure to fetch the vm_flags field.

When dealing with the speculative page fault handler, it will be better to
rely on the cached vm_flags value stored in the vm_fault structure.

This patch introduce a __maybe_mkwrite() service which can be called by
passing the value of the vm_flags field.

There is no change functional changes expected for the other callers of
maybe_mkwrite().

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h | 9 +++++++--
 mm/memory.c        | 6 +++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dfa81a638b7c..a84ddc218bbd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -684,13 +684,18 @@ void free_compound_page(struct page *page);
  * pte_mkwrite.  But get_user_pages can cause write faults for mappings
  * that do not have writing enabled, when used by access_process_vm.
  */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+static inline pte_t __maybe_mkwrite(pte_t pte, unsigned long vma_flags)
 {
-	if (likely(vma->vm_flags & VM_WRITE))
+	if (likely(vma_flags & VM_WRITE))
 		pte = pte_mkwrite(pte);
 	return pte;
 }
 
+static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+{
+	return __maybe_mkwrite(pte, vma->vm_flags);
+}
+
 int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
 int finish_fault(struct vm_fault *vmf);
diff --git a/mm/memory.c b/mm/memory.c
index 0a0a483d9a65..af0338fbc34d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2472,7 +2472,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2549,8 +2549,8 @@ static int wp_page_copy(struct vm_fault *vmf)
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = mk_pte(new_page, vmf->vma_page_prot);
+		entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
-- 
2.7.4
