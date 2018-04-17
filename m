Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F48F6B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id e15so16619917wrj.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g35si1676250edc.40.2018.04.17.07.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:11 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HET9ub101678
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:10 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdhth36us-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:09 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:33:59 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 05/25] mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
Date: Tue, 17 Apr 2018 16:33:11 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When handling page fault without holding the mmap_sem the fetch of the
pte lock pointer and the locking will have to be done while ensuring
that the VMA is not touched in our back.

So move the fetch and locking operations in a dedicated function.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4528bd584b7a..0b9a51f80e0e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2288,6 +2288,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+static inline bool pte_spinlock(struct vm_fault *vmf)
+{
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+	return true;
+}
+
 static inline bool pte_map_lock(struct vm_fault *vmf)
 {
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
@@ -3804,8 +3811,8 @@ static int do_numa_page(struct vm_fault *vmf)
 	 * validation through pte_unmap_same(). It's of NUMA type but
 	 * the pfn may be screwed if the read is non atomic.
 	 */
-	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
-	spin_lock(vmf->ptl);
+	if (!pte_spinlock(vmf))
+		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		goto out;
@@ -3998,8 +4005,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
 		return do_numa_page(vmf);
 
-	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
-	spin_lock(vmf->ptl);
+	if (!pte_spinlock(vmf))
+		return VM_FAULT_RETRY;
 	entry = vmf->orig_pte;
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
-- 
2.7.4
