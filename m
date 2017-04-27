Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 262246B033C
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r3so3478807wrb.19
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p66si3190058wrb.57.2017.04.27.08.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:22 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFrD8C057787
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:21 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a34yd5fq2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:21 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:18 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 10/17] mm/spf: don't set fault entry's fields if locking failed
Date: Thu, 27 Apr 2017 17:52:49 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

In the case pte_map_lock failed to lock the pte or if the VMA is no
more valid, the fault entry's fields should not be set so that caller
won't try to unlock it.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index f8afd52f0d34..3b28de5838c7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2135,6 +2135,8 @@ static bool pte_spinlock(struct vm_fault *vmf)
 static bool pte_map_lock(struct vm_fault *vmf)
 {
 	bool ret = false;
+	pte_t *pte;
+	spinlock_t *ptl;
 
 	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
 		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
@@ -2159,18 +2161,20 @@ static bool pte_map_lock(struct vm_fault *vmf)
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
 
 	if (vma_is_dead(vmf->vma, vmf->sequence)) {
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
