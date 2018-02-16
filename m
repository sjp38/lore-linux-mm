Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3656B0033
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:58 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id 78so2819469qky.17
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:26:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a17si389293qtg.297.2018.02.16.07.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:26:57 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1GFNKgw080678
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:56 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g60v4b4tu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:54 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Feb 2018 15:26:51 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v8 19/24] mm: Adding speculative page fault failure trace events
Date: Fri, 16 Feb 2018 16:25:33 +0100
In-Reply-To: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1518794738-4186-20-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This patch a set of new trace events to collect the speculative page fault
event failures.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/trace/events/pagefault.h | 87 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                      | 62 ++++++++++++++++++++++------
 2 files changed, 136 insertions(+), 13 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

diff --git a/include/trace/events/pagefault.h b/include/trace/events/pagefault.h
new file mode 100644
index 000000000000..1d793f8c739b
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
+	TP_printk("ip:%lx vma:%lx-%lx address:%lx",
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
+DEFINE_EVENT(spf, spf_pmd_changed,
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
index efc32173264e..2ef686405154 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -80,6 +80,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/pagefault.h>
+
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
@@ -2310,23 +2313,30 @@ static bool pte_spinlock(struct vm_fault *vmf)
 	}
 
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	/*
 	 * We check if the pmd value is still the same to ensure that there
 	 * is a huge collapse operation in progress in our back.
 	 */
 	pmdval = READ_ONCE(*vmf->pmd);
-	if (!pmd_same(pmdval, vmf->orig_pmd))
+	if (!pmd_same(pmdval, vmf->orig_pmd)) {
+		trace_spf_pmd_changed(_RET_IP_, vmf->vma, vmf->address);
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
 
@@ -2357,16 +2367,20 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	 * block on the PTL and thus we're safe.
 	 */
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	/*
 	 * We check if the pmd value is still the same to ensure that there
 	 * is a huge collapse operation in progress in our back.
 	 */
 	pmdval = READ_ONCE(*vmf->pmd);
-	if (!pmd_same(pmdval, vmf->orig_pmd))
+	if (!pmd_same(pmdval, vmf->orig_pmd)) {
+		trace_spf_pmd_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 	/*
 	 * Same as pte_offset_map_lock() except that we call
@@ -2379,11 +2393,13 @@ static bool pte_map_lock(struct vm_fault *vmf)
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
 
@@ -4320,47 +4336,60 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 		return ret;
 
 	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
-	if (seq & 1)
+	if (seq & 1) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	/*
 	 * Can't call vm_ops service has we don't know what they would do
 	 * with the VMA.
 	 * This include huge page from hugetlbfs.
 	 */
-	if (vma->vm_ops)
+	if (vma->vm_ops) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	/*
 	 * __anon_vma_prepare() requires the mmap_sem to be held
 	 * because vm_next and vm_prev must be safe. This can't be guaranteed
 	 * in the speculative path.
 	 */
-	if (unlikely(!vma->anon_vma))
+	if (unlikely(!vma->anon_vma)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	vmf.vma_flags = READ_ONCE(vma->vm_flags);
 	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
 
 	/* Can't call userland page fault handler in the speculative path */
-	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
+	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
-	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
+	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
 		/*
 		 * This could be detected by the check address against VMA's
 		 * boundaries but we want to trace it as not supported instead
 		 * of changed.
 		 */
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	if (address < READ_ONCE(vma->vm_start)
-	    || READ_ONCE(vma->vm_end) <= address)
+	    || READ_ONCE(vma->vm_end) <= address) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 				       flags & FAULT_FLAG_INSTRUCTION,
 				       flags & FAULT_FLAG_REMOTE)) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto out_put;
 	}
@@ -4368,10 +4397,12 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	/* This is one is required to check that the VMA has write access set */
 	if (flags & FAULT_FLAG_WRITE) {
 		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
+			trace_spf_vma_access(_RET_IP_, vma, address);
 			ret = VM_FAULT_SIGSEGV;
 			goto out_put;
 		}
 	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto out_put;
 	}
@@ -4384,8 +4415,10 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	pol = __get_vma_policy(vma, address);
 	if (!pol)
 		pol = get_task_policy(current);
-	if (pol && pol->mode == MPOL_INTERLEAVE)
+	if (pol && pol->mode == MPOL_INTERLEAVE) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 #endif
 
 	/*
@@ -4458,8 +4491,10 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
 	 */
-	if (read_seqcount_retry(&vma->vm_sequence, seq))
+	if (read_seqcount_retry(&vma->vm_sequence, seq)) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	mem_cgroup_oom_enable();
 	ret = handle_pte_fault(&vmf);
@@ -4478,6 +4513,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	return ret;
 
 out_walk:
+	trace_spf_vma_notsup(_RET_IP_, vma, address);
 	local_irq_enable();
 out_put:
 	put_vma(vma);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
