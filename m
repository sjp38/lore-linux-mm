Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAC96B035A
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 14:07:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w12so3127343wrc.2
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 11:07:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d5si1859784wma.236.2017.09.08.11.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 11:07:26 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v88I4Q1v013569
	for <linux-mm@kvack.org>; Fri, 8 Sep 2017 14:07:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cux39p3uk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:07:25 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 8 Sep 2017 19:07:23 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 03/20] mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
Date: Fri,  8 Sep 2017 20:06:47 +0200
In-Reply-To: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1504894024-2750-4-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When handling page fault without holding the mmap_sem the fetch of the
pte lock pointer and the locking will have to be done while ensuring
that the VMA is not touched in our back.

So move the fetch and locking operations in a dedicated function.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 13c8c3c8b5e4..530d887ca885 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2408,6 +2408,13 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 }
 
+static bool pte_spinlock(struct vm_fault *vmf)
+{
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+	return true;
+}
+
 static bool pte_map_lock(struct vm_fault *vmf)
 {
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
@@ -3717,8 +3724,8 @@ static int do_numa_page(struct vm_fault *vmf)
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
@@ -3910,8 +3917,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
