Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2B96B0343
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:21:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s74so25416037pfe.10
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:21:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b2si1104411plm.321.2017.06.09.07.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:21:40 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIib6139132
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:21:40 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ayvm1ab2g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:21:39 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:21:37 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 09/20] mm/spf: don't set fault entry's fields if locking failed
Date: Fri,  9 Jun 2017 16:20:58 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

In the case pte_map_lock failed to lock the pte or if the VMA is no
more valid, the fault entry's fields should not be set so that caller
won't try to unlock it.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index f05288797c60..75d24e74c4ff 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2275,6 +2275,8 @@ static bool pte_spinlock(struct vm_fault *vmf)
 static bool pte_map_lock(struct vm_fault *vmf)
 {
 	bool ret = false;
+	pte_t *pte;
+	spinlock_t *ptl;
 
 	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
 		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
@@ -2299,18 +2301,20 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	 * to invalidate TLB but this CPU has irq disabled.
 	 * Since we are in a speculative patch, accept it could fail
 	 */
-	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
-	vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
-	if (unlikely(!spin_trylock(vmf->ptl))) {
-		pte_unmap(vmf->pte);
+	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	pte = pte_offset_map(vmf->pmd, vmf->address);
+	if (unlikely(!spin_trylock(ptl))) {
+		pte_unmap(pte);
 		goto out;
 	}
 
 	if (vma_has_changed(vmf->vma, vmf->sequence)) {
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		pte_unmap_unlock(pte, ptl);
 		goto out;
 	}
 
+	vmf->pte = pte;
+	vmf->ptl = ptl;
 	ret = true;
 out:
 	local_irq_enable();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
