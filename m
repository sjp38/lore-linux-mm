Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD91D6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 97so7542715iok.19
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u57si1375041qta.332.2017.10.09.03.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:14 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A7MfP080364
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:13 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dg617b3tv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:13 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:10 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 02/20] mm: Prepare for FAULT_FLAG_SPECULATIVE
Date: Mon,  9 Oct 2017 12:07:34 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

When speculating faults (without holding mmap_sem) we need to validate
that the vma against which we loaded pages is still valid when we're
ready to install the new PTE.

Therefore, replace the pte_offset_map_lock() calls that (re)take the
PTL with pte_map_lock() which can fail in case we find the VMA changed
since we started the fault.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Port to 4.12 kernel]
[Remove the comment about the fault_env structure which has been
 implemented as the vm_fault structure in the kernel]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 55 ++++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3cc407421f17..fb3477f7f742 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -291,6 +291,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
+#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
 
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
diff --git a/mm/memory.c b/mm/memory.c
index 4e4fe233d066..40dbf7efbcad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2451,6 +2451,12 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 }
 
+static bool pte_map_lock(struct vm_fault *vmf)
+{
+	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
+	return true;
+}
+
 /*
  * Handle the case of a page which we actually need to copy to a new page.
  *
@@ -2478,6 +2484,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 	const unsigned long mmun_start = vmf->address & PAGE_MASK;
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
+	int ret = VM_FAULT_OOM;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -2505,7 +2512,11 @@ static int wp_page_copy(struct vm_fault *vmf)
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		mem_cgroup_cancel_charge(new_page, memcg, false);
+		ret = VM_FAULT_RETRY;
+		goto oom_free_new;
+	}
 	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2593,7 +2604,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 oom:
 	if (old_page)
 		put_page(old_page);
-	return VM_FAULT_OOM;
+	return ret;
 }
 
 /**
@@ -2614,8 +2625,8 @@ static int wp_page_copy(struct vm_fault *vmf)
 int finish_mkwrite_fault(struct vm_fault *vmf)
 {
 	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
-	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
-				       &vmf->ptl);
+	if (!pte_map_lock(vmf))
+		return VM_FAULT_RETRY;
 	/*
 	 * We might have raced with another page fault while we released the
 	 * pte_offset_map_lock.
@@ -2733,8 +2744,11 @@ static int do_wp_page(struct vm_fault *vmf)
 			get_page(vmf->page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			lock_page(vmf->page);
-			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-					vmf->address, &vmf->ptl);
+			if (!pte_map_lock(vmf)) {
+				unlock_page(vmf->page);
+				put_page(vmf->page);
+				return VM_FAULT_RETRY;
+			}
 			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 				unlock_page(vmf->page);
 				pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2937,8 +2951,10 @@ int do_swap_page(struct vm_fault *vmf)
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-					vmf->address, &vmf->ptl);
+			if (!pte_map_lock(vmf)) {
+				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+				return VM_FAULT_RETRY;
+			}
 			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2994,8 +3010,11 @@ int do_swap_page(struct vm_fault *vmf)
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto out_page;
+	}
 	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte)))
 		goto out_nomap;
 
@@ -3124,8 +3143,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
 						vma->vm_page_prot));
-		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-				vmf->address, &vmf->ptl);
+		if (!pte_map_lock(vmf))
+			return VM_FAULT_RETRY;
 		if (!pte_none(*vmf->pte))
 			goto unlock;
 		ret = check_stable_address_space(vma->vm_mm);
@@ -3160,8 +3179,11 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		mem_cgroup_cancel_charge(page, memcg, false);
+		put_page(page);
+		return VM_FAULT_RETRY;
+	}
 	if (!pte_none(*vmf->pte))
 		goto release;
 
@@ -3285,8 +3307,9 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
 	 * pte_none() under vmf->ptl protection when we return to
 	 * alloc_set_pte().
 	 */
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf))
+		return VM_FAULT_RETRY;
+
 	return 0;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
