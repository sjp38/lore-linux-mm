Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 795896B0273
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so26448611wmu.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h37si6987592ede.19.2017.10.09.03.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:57 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A8m0Q110424
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:56 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dg5t8bp9p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:55 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:54 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 16/20] mm: Adding speculative page fault failure trace events
Date: Mon,  9 Oct 2017 12:07:48 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-17-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This patch a set of new trace events to collect the speculative page fault
event failures.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/trace/events/pagefault.h | 87 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                      | 59 ++++++++++++++++++++++-----
 2 files changed, 135 insertions(+), 11 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

diff --git a/include/trace/events/pagefault.h b/include/trace/events/pagefault.h
new file mode 100644
index 000000000000..d7d56f8102d1
--- /dev/null
+++ b/include/trace/events/pagefault.h
@@ -0,0 +1,87 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM pagefault
+
+#if !defined(_TRACE_PAGEFAULT_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGEFAULT_H
+
+#include <linux/tracepoint.h>
+#include <linux/mm.h>
+
+DECLARE_EVENT_CLASS(spf,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, caller)
+		__field(unsigned long, vm_start)
+		__field(unsigned long, vm_end)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->caller		= caller;
+		__entry->vm_start	= vma->vm_start;
+		__entry->vm_end		= vma->vm_end;
+		__entry->address	= address;
+	),
+
+	TP_printk("ip:%lx vma:%lu-%lx address:%lx",
+		  __entry->caller, __entry->vm_start, __entry->vm_end,
+		  __entry->address)
+);
+
+DEFINE_EVENT(spf, spf_pte_lock,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_changed,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_dead,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_noanon,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_notsup,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_access,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+#endif /* _TRACE_PAGEFAULT_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/memory.c b/mm/memory.c
index 8abfc0e12e25..82bce69e6843 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -81,6 +81,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/pagefault.h>
+
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
@@ -2472,15 +2475,20 @@ static bool pte_spinlock(struct vm_fault *vmf)
 	}
 
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
-	if (unlikely(!spin_trylock(vmf->ptl)))
+	if (unlikely(!spin_trylock(vmf->ptl))) {
+		trace_spf_pte_lock(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	if (vma_has_changed(vmf)) {
 		spin_unlock(vmf->ptl);
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
 	}
 
@@ -2519,8 +2527,10 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	 * block on the PTL and thus we're safe.
 	 */
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	/*
 	 * Same as pte_offset_map_lock() except that we call
@@ -2533,11 +2543,13 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	pte = pte_offset_map(vmf->pmd, vmf->address);
 	if (unlikely(!spin_trylock(ptl))) {
 		pte_unmap(pte);
+		trace_spf_pte_lock(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
 	}
 
 	if (vma_has_changed(vmf)) {
 		pte_unmap_unlock(pte, ptl);
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
 	}
 
@@ -4255,32 +4267,45 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * Validate the VMA found by the lockless lookup.
 	 */
 	dead = RB_EMPTY_NODE(&vma->vm_rb);
+	if (dead) {
+		trace_spf_vma_dead(_RET_IP_, vma, address);
+		goto unlock;
+	}
+
 	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
-	if ((seq & 1) || dead)
+	if (seq & 1) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	/*
 	 * Can't call vm_ops service has we don't know what they would do
 	 * with the VMA.
 	 * This include huge page from hugetlbfs.
 	 */
-	if (vma->vm_ops)
+	if (vma->vm_ops) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	/*
 	 * __anon_vma_prepare() requires the mmap_sem to be held
 	 * because vm_next and vm_prev must be safe. This can't be guaranteed
 	 * in the speculative path.
 	 */
-	if (unlikely(!vma->anon_vma))
+	if (unlikely(!vma->anon_vma)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	vmf.vma_flags = READ_ONCE(vma->vm_flags);
 	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
 
 	/* Can't call userland page fault handler in the speculative path */
-	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
+	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 #ifdef CONFIG_NUMA
 	/*
@@ -4290,25 +4315,32 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	pol = __get_vma_policy(vma, address);
 	if (!pol)
 		pol = get_task_policy(current);
-	if (pol && pol->mode == MPOL_INTERLEAVE)
+	if (pol && pol->mode == MPOL_INTERLEAVE) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto unlock;
+	}
 #endif
 
-	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
+	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
 		/*
 		 * This could be detected by the check address against VMA's
 		 * boundaries but we want to trace it as not supported instead
 		 * of changed.
 		 */
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	if (address < READ_ONCE(vma->vm_start)
-	    || READ_ONCE(vma->vm_end) <= address)
+	    || READ_ONCE(vma->vm_end) <= address) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 				       flags & FAULT_FLAG_INSTRUCTION,
 				       flags & FAULT_FLAG_REMOTE)) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto unlock;
 	}
@@ -4316,10 +4348,12 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	/* This is one is required to check that the VMA has write access set */
 	if (flags & FAULT_FLAG_WRITE) {
 		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
+			trace_spf_vma_access(_RET_IP_, vma, address);
 			ret = VM_FAULT_SIGSEGV;
 			goto unlock;
 		}
 	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto unlock;
 	}
@@ -4377,8 +4411,10 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
 	 */
-	if (read_seqcount_retry(&vma->vm_sequence, seq))
+	if (read_seqcount_retry(&vma->vm_sequence, seq)) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto unlock;
+	}
 
 	mem_cgroup_oom_enable();
 	ret = handle_pte_fault(&vmf);
@@ -4401,6 +4437,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	return ret;
 
 out_walk:
+	trace_spf_vma_notsup(_RET_IP_, vma, address);
 	local_irq_enable();
 unlock:
 	srcu_read_unlock(&vma_srcu, idx);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
