Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4902B6B025E
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:38 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q185so5515006qke.2
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:27:38 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e64si8833623qtd.147.2018.01.12.09.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 09:27:37 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0CHOxk2126754
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:36 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fexkcjwg5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:35 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 12 Jan 2018 17:27:32 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v6 22/24] mm: Speculative page fault handler return VMA
Date: Fri, 12 Jan 2018 18:26:06 +0100
In-Reply-To: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1515777968-867-23-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |   5 +-
 mm/memory.c        | 136 +++++++++++++++++++++++++++++++++--------------------
 2 files changed, 88 insertions(+), 53 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4d8a7621da8a..02da17792f0d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1354,7 +1354,10 @@ extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags);
 #ifdef CONFIG_SPF
 extern int handle_speculative_fault(struct mm_struct *mm,
-				    unsigned long address, unsigned int flags);
+				    unsigned long address, unsigned int flags,
+				    struct vm_area_struct **vma);
+extern bool can_reuse_spf_vma(struct vm_area_struct *vma,
+			      unsigned long address);
 #endif /* CONFIG_SPF */
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
diff --git a/mm/memory.c b/mm/memory.c
index 6ccb1f45473a..e1f172ac2c90 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4284,13 +4284,22 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
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
 int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
-			     unsigned int flags)
+			     unsigned int flags, struct vm_area_struct **vma)
 {
 	struct vm_fault vmf = {
 		.address = address,
@@ -4299,7 +4308,6 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	p4d_t *p4d, p4dval;
 	pud_t pudval;
 	int seq, ret = VM_FAULT_RETRY;
-	struct vm_area_struct *vma;
 #ifdef CONFIG_NUMA
 	struct mempolicy *pol;
 #endif
@@ -4308,14 +4316,16 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
 	flags |= FAULT_FLAG_SPECULATIVE;
 
-	vma = get_vma(mm, address);
-	if (!vma)
+	*vma = get_vma(mm, address);
+	if (!*vma)
 		return ret;
+	vmf.vma = *vma;
 
-	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
+	/* rmb <-> seqlock,vma_rb_erase() */
+	seq = raw_read_seqcount(&vmf.vma->vm_sequence);
 	if (seq & 1) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return ret;
 	}
 
 	/*
@@ -4323,9 +4333,9 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * with the VMA.
 	 * This include huge page from hugetlbfs.
 	 */
-	if (vma->vm_ops) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+	if (vmf.vma->vm_ops) {
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return ret;
 	}
 
 	/*
@@ -4333,18 +4343,18 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * because vm_next and vm_prev must be safe. This can't be guaranteed
 	 * in the speculative path.
 	 */
-	if (unlikely(!vma->anon_vma)) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+	if (unlikely(!vmf.vma->anon_vma)) {
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return ret;
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
+		return ret;
 	}
 
 	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
@@ -4353,48 +4363,39 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		 * boundaries but we want to trace it as not supported instead
 		 * of changed.
 		 */
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return ret;
 	}
 
-	if (address < READ_ONCE(vma->vm_start)
-	    || READ_ONCE(vma->vm_end) <= address) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+	if (address < READ_ONCE(vmf.vma->vm_start)
+	    || READ_ONCE(vmf.vma->vm_end) <= address) {
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return ret;
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
 
 #ifdef CONFIG_NUMA
 	/*
 	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
 	 * are not compatible with the speculative page fault processing.
 	 */
-	pol = __get_vma_policy(vma, address);
+	pol = __get_vma_policy(vmf.vma, address);
 	if (!pol)
 		pol = get_task_policy(current);
 	if (pol && pol->mode == MPOL_INTERLEAVE) {
-		trace_spf_vma_notsup(_RET_IP_, vma, address);
-		goto out_put;
+		trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
+		return ret;
 	}
 #endif
 
@@ -4456,9 +4457,8 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		vmf.pte = NULL;
 	}
 
-	vmf.vma = vma;
-	vmf.pgoff = linear_page_index(vma, address);
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf.pgoff = linear_page_index(vmf.vma, address);
+	vmf.gfp_mask = __get_fault_gfp_mask(vmf.vma);
 	vmf.sequence = seq;
 	vmf.flags = flags;
 
@@ -4468,16 +4468,22 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
 	 */
-	if (read_seqcount_retry(&vma->vm_sequence, seq)) {
-		trace_spf_vma_changed(_RET_IP_, vma, address);
-		goto out_put;
+	if (read_seqcount_retry(&vmf.vma->vm_sequence, seq)) {
+		trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
+		return ret;
 	}
 
 	mem_cgroup_oom_enable();
 	ret = handle_pte_fault(&vmf);
 	mem_cgroup_oom_disable();
 
-	put_vma(vma);
+	/*
+	 * If there is no need to retry, don't return the vma to the caller.
+	 */
+	if (!(ret & VM_FAULT_RETRY)) {
+		put_vma(vmf.vma);
+		*vma = NULL;
+	}
 
 	/*
 	 * The task may have entered a memcg OOM situation but
@@ -4490,9 +4496,35 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	return ret;
 
 out_walk:
-	trace_spf_vma_notsup(_RET_IP_, vma, address);
+	trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
 	local_irq_enable();
-out_put:
+	return ret;
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
