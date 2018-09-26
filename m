Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB518E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 23:19:46 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id s69-v6so30088352ota.13
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 20:19:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n63-v6si1667221oif.143.2018.09.25.20.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 20:19:44 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8Q3Jgce144629
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 23:19:44 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mqye6nabx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 23:19:42 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 25 Sep 2018 21:19:07 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2] mm: Recheck page table entry with page table lock held
Date: Wed, 26 Sep 2018 08:48:58 +0530
Message-Id: <20180926031858.9692-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

We clear the pte temporarily during read/modify/write update of the pte. If we
take a page fault while the pte is cleared, the application can get SIGBUS. One
such case is with remap_pfn_range without a backing vm_ops->fault callback.
do_fault will return SIGBUS in that case.

cpu 0		 				cpu1
mprotect()
ptep_modify_prot_start()/pte cleared.
.
.						page fault.
.
.
prep_modify_prot_commit()

Fix this by taking page table lock and rechecking for pte_none.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
V1:
* update commit message.

 mm/memory.c | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..c2f933184303 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3745,10 +3745,33 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	vm_fault_t ret;
 
-	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
-	if (!vma->vm_ops->fault)
-		ret = VM_FAULT_SIGBUS;
-	else if (!(vmf->flags & FAULT_FLAG_WRITE))
+	/*
+	 * The VMA was not fully populated on mmap() or missing VM_DONTEXPAND
+	 */
+	if (!vma->vm_ops->fault) {
+
+		/*
+		 * pmd entries won't be marked none during a R/M/W cycle.
+		 */
+		if (unlikely(pmd_none(*vmf->pmd)))
+			ret = VM_FAULT_SIGBUS;
+		else {
+			vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+			/*
+			 * Make sure this is not a temporary clearing of pte
+			 * by holding ptl and checking again. A R/M/W update
+			 * of pte involves: take ptl, clearing the pte so that
+			 * we don't have concurrent modification by hardware
+			 * followed by an update.
+			 */
+			spin_lock(vmf->ptl);
+			if (unlikely(pte_none(*vmf->pte)))
+				ret = VM_FAULT_SIGBUS;
+			else
+				ret = VM_FAULT_NOPAGE;
+			spin_unlock(vmf->ptl);
+		}
+	} else if (!(vmf->flags & FAULT_FLAG_WRITE))
 		ret = do_read_fault(vmf);
 	else if (!(vma->vm_flags & VM_SHARED))
 		ret = do_cow_fault(vmf);
-- 
2.17.1
