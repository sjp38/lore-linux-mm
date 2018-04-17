Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 010356B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p11so512175wrd.20
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 63si5874776edn.304.2018.04.17.07.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:06 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HESvP2100669
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:05 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdhth36wf-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:04 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:01 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 06/25] mm: make pte_unmap_same compatible with SPF
Date: Tue, 17 Apr 2018 16:33:12 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

pte_unmap_same() is making the assumption that the page table are still
around because the mmap_sem is held.
This is no more the case when running a speculative page fault and
additional check must be made to ensure that the final page table are still
there.

This is now done by calling pte_spinlock() to check for the VMA's
consistency while locking for the page tables.

This is requiring passing a vm_fault structure to pte_unmap_same() which is
containing all the needed parameters.

As pte_spinlock() may fail in the case of a speculative page fault, if the
VMA has been touched in our back, pte_unmap_same() should now return 3
cases :
	1. pte are the same (0)
	2. pte are different (VM_FAULT_PTNOTSAME)
	3. a VMA's changes has been detected (VM_FAULT_RETRY)

The case 2 is handled by the introduction of a new VM_FAULT flag named
VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
page fault while holding the mmap_sem.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 39 ++++++++++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4d1aff80669c..714da99d77a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1208,6 +1208,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
 					 * and needs fsync() to complete (for
 					 * synchronous page faults in DAX) */
+#define VM_FAULT_PTNOTSAME 0x4000	/* Page table entries have changed */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
diff --git a/mm/memory.c b/mm/memory.c
index 0b9a51f80e0e..f86efcb8e268 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2309,21 +2309,29 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
  * parts, do_swap_page must check under lock before unmapping the pte and
  * proceeding (but do_wp_page is only called after already making such a check;
  * and do_anonymous_page can safely check later on).
+ *
+ * pte_unmap_same() returns:
+ *	0			if the PTE are the same
+ *	VM_FAULT_PTNOTSAME	if the PTE are different
+ *	VM_FAULT_RETRY		if the VMA has changed in our back during
+ *				a speculative page fault handling.
  */
-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+static inline int pte_unmap_same(struct vm_fault *vmf)
 {
-	int same = 1;
+	int ret = 0;
+
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
+		if (pte_spinlock(vmf)) {
+			if (!pte_same(*vmf->pte, vmf->orig_pte))
+				ret = VM_FAULT_PTNOTSAME;
+			spin_unlock(vmf->ptl);
+		} else
+			ret = VM_FAULT_RETRY;
 	}
 #endif
-	pte_unmap(page_table);
-	return same;
+	pte_unmap(vmf->pte);
+	return ret;
 }
 
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
@@ -2912,10 +2920,19 @@ int do_swap_page(struct vm_fault *vmf)
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
-	int ret = 0;
+	int ret;
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
+	ret = pte_unmap_same(vmf);
+	if (ret) {
+		/*
+		 * If pte != orig_pte, this means another thread did the
+		 * swap operation in our back.
+		 * So nothing else to do.
+		 */
+		if (ret == VM_FAULT_PTNOTSAME)
+			ret = 0;
 		goto out;
+	}
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
-- 
2.7.4
