Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A79DB6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:35:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m7so16464640wrb.16
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:35:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m24si3928165edd.150.2018.04.17.07.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:35:02 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HEVfqc108182
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:35:00 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdjs2g5u4-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:35:00 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:56 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 22/25] mm: speculative page fault handler return VMA
Date: Tue, 17 Apr 2018 16:33:28 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-23-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When the speculative page fault handler is returning VM_RETRY, there is a
chance that VMA fetched without grabbing the mmap_sem can be reused by the
legacy page fault handler.  By reusing it, we avoid calling find_vma()
again. To achieve, that we must ensure that the VMA structure will not be
freed in our back. This is done by getting the reference on it (get_vma())
and by assuming that the caller will call the new service
can_reuse_spf_vma() once it has grabbed the mmap_sem.

can_reuse_spf_vma() is first checking that the VMA is still in the RB tree
, and then that the VMA's boundaries matched the passed address and release
the reference on the VMA so that it can be freed if needed.

In the case the VMA is freed, can_reuse_spf_vma() will have returned false
as the VMA is no more in the RB tree.

In the architecture page fault handler, the call to the new service
reuse_spf_or_find_vma() should be made in place of find_vma(), this will
handle the check on the spf_vma and if needed call find_vma().

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  22 +++++++--
 mm/memory.c        | 140 ++++++++++++++++++++++++++++++++---------------------
 2 files changed, 103 insertions(+), 59 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08540c98d63b..50b6fd3bf9e2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1382,25 +1382,37 @@ extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
 extern int __handle_speculative_fault(struct mm_struct *mm,
 				      unsigned long address,
-				      unsigned int flags);
+				      unsigned int flags,
+				      struct vm_area_struct **vma);
 static inline int handle_speculative_fault(struct mm_struct *mm,
 					   unsigned long address,
-					   unsigned int flags)
+					   unsigned int flags,
+					   struct vm_area_struct **vma)
 {
 	/*
 	 * Try speculative page fault for multithreaded user space task only.
 	 */
-	if (!(flags & FAULT_FLAG_USER) || atomic_read(&mm->mm_users) == 1)
+	if (!(flags & FAULT_FLAG_USER) || atomic_read(&mm->mm_users) == 1) {
+		*vma = NULL;
 		return VM_FAULT_RETRY;
-	return __handle_speculative_fault(mm, address, flags);
+	}
+	return __handle_speculative_fault(mm, address, flags, vma);
 }
+extern bool can_reuse_spf_vma(struct vm_area_struct *vma,
+			      unsigned long address);
 #else
 static inline int handle_speculative_fault(struct mm_struct *mm,
 					   unsigned long address,
-					   unsigned int flags)
+					   unsigned int flags,
+					   struct vm_area_struct **vma)
 {
 	return VM_FAULT_RETRY;
 }
+static inline bool can_reuse_spf_vma(struct vm_area_struct *vma,
+				     unsigned long address)
+{
+	return false;
+}
 #endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
 
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
diff --git a/mm/memory.c b/mm/memory.c
index 76178feff000..425f07e0bf38 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4311,13 +4311,22 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 /* This is required by vm_normal_page() */
 #error "Speculative page fault handler requires __HAVE_ARCH_PTE_SPECIAL"
 #endif
-
 /*
  * vm_normal_page() adds some processing which should be done while
  * hodling the mmap_sem.
  */
+
+/*
+ * Tries to handle the page fault in a speculative way, without grabbing the
+ * mmap_sem.
+ * When VM_FAULT_RETRY is returned, the vma pointer is valid and this vma must
+ * be checked later when the mmap_sem has been grabbed by calling
+ * can_reuse_spf_vma().
+ * This is needed as the returned vma is kept in memory until the call to
+ * can_reuse_spf_vma() is made.
+ */
 int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
-			       unsigned int flags)
+			       unsigned int flags, struct vm_area_struct **vma)
 {
 	struct vm_fault vmf = {
 		.address = address,
@@ -4325,21 +4334,22 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	pgd_t *pgd, pgdval;
 	p4d_t *p4d, p4dval;
 	pud_t pudval;
-	int seq, ret = VM_FAULT_RETRY;
-	struct vm_area_struct *vma;
+	int seq, ret;
 
 	/* Clear flags that may lead to release the mmap_sem to retry */
 	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
 	flags |= FAULT_FLAG_SPECULATIVE;
 
-	vma = get_vma(mm, address);
-	if (!vma)
-		return ret;
+	*vma = get_vma(mm, address);
+	if (!*vma)
+		return VM_FAULT_RETRY;
+	vmf.vma = *vma;
 
-	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
+	/* rmb <-> seqlock,vma_rb_erase() */
+	seq = raw_read_seqcount(&vmf.vma->vm_sequence);
 	if (seq & 1) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
 	/*
@@ -4347,9 +4357,9 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * with the VMA.
 	 * This include huge page from hugetlbfs.
 	 */
-	if (vma->vm_ops) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+	if (vmf.vma->vm_ops) {
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
 	/*
@@ -4357,18 +4367,18 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * because vm_next and vm_prev must be safe. This can't be guaranteed
 	 * in the speculative path.
 	 */
-	if (unlikely(!vma->anon_vma)) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+	if (unlikely(!vmf.vma->anon_vma)) {
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
-	vmf.vma_flags = READ_ONCE(vma->vm_flags);
-	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
+	vmf.vma_flags = READ_ONCE(vmf.vma->vm_flags);
+	vmf.vma_page_prot = READ_ONCE(vmf.vma->vm_page_prot);
 
 	/* Can't call userland page fault handler in the speculative path */
 	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING)) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
 	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
@@ -4377,36 +4387,27 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		 * boundaries but we want to trace it as not supported instead
 		 * of changed.
 		 */
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
-	if (address < READ_ONCE(vma->vm_start)
-	    || READ_ONCE(vma->vm_end) <= address) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+	if (address < READ_ONCE(vmf.vma->vm_start)
+	    || READ_ONCE(vmf.vma->vm_end) <= address) {
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
-	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+	if (!arch_vma_access_permitted(vmf.vma, flags & FAULT_FLAG_WRITE,
 				       flags & FAULT_FLAG_INSTRUCTION,
-				       flags & FAULT_FLAG_REMOTE)) {
-		trace_spf_vma_access(_RET_IP_, vma, address);
-		ret = VM_FAULT_SIGSEGV;
-		goto out_put;
-	}
+				       flags & FAULT_FLAG_REMOTE))
+		goto out_segv;
 
 	/* This is one is required to check that the VMA has write access set */
 	if (flags & FAULT_FLAG_WRITE) {
-		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
-			trace_spf_vma_access(_RET_IP_, vma, address);
-			ret = VM_FAULT_SIGSEGV;
-			goto out_put;
-		}
-	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
-		trace_spf_vma_access(_RET_IP_, vma, address);
-		ret = VM_FAULT_SIGSEGV;
-		goto out_put;
-	}
+		if (unlikely(!(vmf.vma_flags & VM_WRITE)))
+			goto out_segv;
+	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE))))
+		goto out_segv;
 
 	if (IS_ENABLED(CONFIG_NUMA)) {
 		struct mempolicy *pol;
@@ -4416,12 +4417,12 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		 * mpol_misplaced() which are not compatible with the
 		 *speculative page fault processing.
 		 */
-		pol = __get_vma_policy(vma, address);
+		pol = __get_vma_policy(vmf.vma, address);
 		if (!pol)
 			pol = get_task_policy(current);
 		if (pol && pol->mode == MPOL_INTERLEAVE) {
-			trace_spf_vma_notsup(_RET_IP_, vma, address);
-			goto out_put;
+			trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+			return VM_FAULT_RETRY;
 		}
 	}
 
@@ -4483,9 +4484,8 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		vmf.pte = NULL;
 	}
 
-	vmf.vma = vma;
-	vmf.pgoff = linear_page_index(vma, address);
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf.pgoff = linear_page_index(vmf.vma, address);
+	vmf.gfp_mask = __get_fault_gfp_mask(vmf.vma);
 	vmf.sequence = seq;
 	vmf.flags = flags;
 
@@ -4495,16 +4495,22 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
 	 */
-	if (read_seqcount_retry(&vma->vm_sequence, seq)) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+	if (read_seqcount_retry(&vmf.vma->vm_sequence, seq)) {
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return VM_FAULT_RETRY;
 	}
 
 	mem_cgroup_oom_enable();
 	ret = handle_pte_fault(&vmf);
 	mem_cgroup_oom_disable();
 
-	put_vma(vma);
+	/*
+	 * If there is no need to retry, don't return the vma to the caller.
+	 */
+	if (ret != VM_FAULT_RETRY) {
+		put_vma(vmf.vma);
+		*vma = NULL;
+	}
 
 	/*
 	 * The task may have entered a memcg OOM situation but
@@ -4517,9 +4523,35 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	return ret;
 
 out_walk:
-	trace_spf_vma_notsup(_RET_IP_, vma, address);
+	trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
 	local_irq_enable();
-out_put:
+	return VM_FAULT_RETRY;
+
+out_segv:
+	trace_spf_vma_access(_RET_IP_, vmf.vma, address);
+	/*
+	 * We don't return VM_FAULT_RETRY so the caller is not expected to
+	 * retrieve the fetched VMA.
+	 */
+	put_vma(vmf.vma);
+	*vma = NULL;
+	return VM_FAULT_SIGSEGV;
+}
+
+/*
+ * This is used to know if the vma fetch in the speculative page fault handler
+ * is still valid when trying the regular fault path while holding the
+ * mmap_sem.
+ * The call to put_vma(vma) must be made after checking the vma's fields, as
+ * the vma may be freed by put_vma(). In such a case it is expected that false
+ * is returned.
+ */
+bool can_reuse_spf_vma(struct vm_area_struct *vma, unsigned long address)
+{
+	bool ret;
+
+	ret = !RB_EMPTY_NODE(&vma->vm_rb) &&
+		vma->vm_start <= address && address < vma->vm_end;
 	put_vma(vma);
 	return ret;
 }
-- 
2.7.4
