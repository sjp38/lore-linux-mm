Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C814A6B000E
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:13 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id a129so2852742qkb.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:26:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e22si709052qkj.404.2018.02.16.07.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:26:12 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1GFNRND135059
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:12 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g603bctsx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:12 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Feb 2018 15:26:09 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v8 06/24] mm: make pte_unmap_same compatible with SPF
Date: Fri, 16 Feb 2018 16:25:20 +0100
In-Reply-To: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1518794738-4186-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 37 ++++++++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 51d950cac772..e869adec9023 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1197,6 +1197,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
 					 * and needs fsync() to complete (for
 					 * synchronous page faults in DAX) */
+#define VM_FAULT_PTNOTSAME 0x4000	/* Page table entries have changed */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
diff --git a/mm/memory.c b/mm/memory.c
index 1ca289f53dd6..a301b9003200 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2309,21 +2309,29 @@ static bool pte_map_lock(struct vm_fault *vmf)
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
@@ -2912,7 +2920,7 @@ int do_swap_page(struct vm_fault *vmf)
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
-	int ret = 0;
+	int ret;
 	bool vma_readahead = swap_use_vma_readahead();
 
 	if (vma_readahead) {
@@ -2920,9 +2928,16 @@ int do_swap_page(struct vm_fault *vmf)
 		swapcache = page;
 	}
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
+	ret = pte_unmap_same(vmf);
+	if (ret) {
 		if (page)
 			put_page(page);
+		/*
+		 * In the case the PTE are different, meaning that the
+		 * page has already been processed by another CPU, we return 0.
+		 */
+		if (ret == VM_FAULT_PTNOTSAME)
+			ret = 0;
 		goto out;
 	}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
