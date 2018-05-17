Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 205FC6B04AD
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y7-v6so3544586qtn.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z17-v6si8911qtz.71.2018.05.17.04.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:07:07 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB56qm103332
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:06 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j17g8u5e2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:04 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:07:01 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 07/26] mm: make pte_unmap_same compatible with SPF
Date: Thu, 17 May 2018 13:06:14 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
 include/linux/mm.h |  4 +++-
 mm/memory.c        | 39 ++++++++++++++++++++++++++++-----------
 2 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 338b8a1afb02..113b572471ca 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1249,6 +1249,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
 					 * and needs fsync() to complete (for
 					 * synchronous page faults in DAX) */
+#define VM_FAULT_PTNOTSAME 0x4000	/* Page table entries have changed */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
@@ -1267,7 +1268,8 @@ static inline void clear_page_pfmemalloc(struct page *page)
 	{ VM_FAULT_RETRY,		"RETRY" }, \
 	{ VM_FAULT_FALLBACK,		"FALLBACK" }, \
 	{ VM_FAULT_DONE_COW,		"DONE_COW" }, \
-	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" }
+	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" },	\
+	{ VM_FAULT_PTNOTSAME,		"PTNOTSAME" }
 
 /* Encode hstate index for a hwpoisoned large page */
 #define VM_FAULT_SET_HINDEX(x) ((x) << 12)
diff --git a/mm/memory.c b/mm/memory.c
index fa0d9493acac..75163c145c76 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2319,21 +2319,29 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
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
@@ -2922,10 +2930,19 @@ int do_swap_page(struct vm_fault *vmf)
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
