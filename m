Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2A26B04A7
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r23-v6so2861313wrc.2
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t2-v6si4673103edq.113.2018.05.17.04.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:06:59 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB4C6u054161
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:06:58 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j17kxaw30-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:06:58 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:06:55 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 05/26] mm: prepare for FAULT_FLAG_SPECULATIVE
Date: Thu, 17 May 2018 13:06:12 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
[move pte_map_lock()'s definition upper in the file]
[move the define of FAULT_FLAG_SPECULATIVE later in the series]
[review error path in do_swap_page(), do_anonymous_page() and
 wp_page_copy()]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 87 ++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 58 insertions(+), 29 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 14578158ed20..a55e72c8e469 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2298,6 +2298,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+static inline bool pte_map_lock(struct vm_fault *vmf)
+{
+	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+				       vmf->address, &vmf->ptl);
+	return true;
+}
+
 /*
  * handle_pte_fault chooses page fault handler according to an entry which was
  * read non-atomically.  Before making any commitment, on those architectures
@@ -2487,25 +2494,26 @@ static int wp_page_copy(struct vm_fault *vmf)
 	const unsigned long mmun_start = vmf->address & PAGE_MASK;
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
+	int ret = VM_FAULT_OOM;
 
 	if (unlikely(anon_vma_prepare(vma)))
-		goto oom;
+		goto out;
 
 	if (is_zero_pfn(pte_pfn(vmf->orig_pte))) {
 		new_page = alloc_zeroed_user_highpage_movable(vma,
 							      vmf->address);
 		if (!new_page)
-			goto oom;
+			goto out;
 	} else {
 		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 				vmf->address);
 		if (!new_page)
-			goto oom;
+			goto out;
 		cow_user_page(new_page, old_page, vmf->address, vma);
 	}
 
 	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false))
-		goto oom_free_new;
+		goto out_free_new;
 
 	__SetPageUptodate(new_page);
 
@@ -2514,7 +2522,10 @@ static int wp_page_copy(struct vm_fault *vmf)
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
+		goto out_uncharge;
+	}
 	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2601,12 +2612,14 @@ static int wp_page_copy(struct vm_fault *vmf)
 		put_page(old_page);
 	}
 	return page_copied ? VM_FAULT_WRITE : 0;
-oom_free_new:
+out_uncharge:
+	mem_cgroup_cancel_charge(new_page, memcg, false);
+out_free_new:
 	put_page(new_page);
-oom:
+out:
 	if (old_page)
 		put_page(old_page);
-	return VM_FAULT_OOM;
+	return ret;
 }
 
 /**
@@ -2627,8 +2640,8 @@ static int wp_page_copy(struct vm_fault *vmf)
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
@@ -2746,8 +2759,11 @@ static int do_wp_page(struct vm_fault *vmf)
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
@@ -2954,11 +2970,15 @@ int do_swap_page(struct vm_fault *vmf)
 
 		if (!page) {
 			/*
-			 * Back out if somebody else faulted in this pte
-			 * while we released the pte lock.
+			 * Back out if the VMA has changed in our back during
+			 * a speculative page fault or if somebody else
+			 * faulted in this pte while we released the pte lock.
 			 */
-			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-					vmf->address, &vmf->ptl);
+			if (!pte_map_lock(vmf)) {
+				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+				ret = VM_FAULT_RETRY;
+				goto out;
+			}
 			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -3011,10 +3031,13 @@ int do_swap_page(struct vm_fault *vmf)
 	}
 
 	/*
-	 * Back out if somebody else already faulted in this pte.
+	 * Back out if the VMA has changed in our back during a speculative
+	 * page fault or if somebody else already faulted in this pte.
 	 */
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
+		goto out_cancel_cgroup;
+	}
 	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte)))
 		goto out_nomap;
 
@@ -3092,8 +3115,9 @@ int do_swap_page(struct vm_fault *vmf)
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_cancel_charge(page, memcg, false);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
+out_cancel_cgroup:
+	mem_cgroup_cancel_charge(page, memcg, false);
 out_page:
 	unlock_page(page);
 out_release:
@@ -3144,8 +3168,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
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
@@ -3180,14 +3204,16 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
-	if (!pte_none(*vmf->pte))
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
 		goto release;
+	}
+	if (!pte_none(*vmf->pte))
+		goto unlock_and_release;
 
 	ret = check_stable_address_space(vma->vm_mm);
 	if (ret)
-		goto release;
+		goto unlock_and_release;
 
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
@@ -3209,10 +3235,12 @@ static int do_anonymous_page(struct vm_fault *vmf)
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return ret;
+unlock_and_release:
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
-	goto unlock;
+	return ret;
 oom_free_page:
 	put_page(page);
 oom:
@@ -3305,8 +3333,9 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
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
