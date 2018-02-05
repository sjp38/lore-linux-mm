Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE056B029E
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:39 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j3so10038371pld.0
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si2015301plk.504.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 59/64] drivers/iommu: use mm locking helpers
Date: Mon,  5 Feb 2018 02:27:49 +0100
Message-Id: <20180205012754.23615-60-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/iommu/amd_iommu_v2.c | 4 ++--
 drivers/iommu/intel-svm.c    | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 15a7103fd84c..d3aee158d251 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -523,7 +523,7 @@ static void do_fault(struct work_struct *work)
 		flags |= FAULT_FLAG_WRITE;
 	flags |= FAULT_FLAG_REMOTE;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_extend_vma(mm, address, &mmrange);
 	if (!vma || address < vma->vm_start)
 		/* failed to get a vma in the right range */
@@ -535,7 +535,7 @@ static void do_fault(struct work_struct *work)
 
 	ret = handle_mm_fault(vma, address, flags, &mmrange);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	if (ret & VM_FAULT_ERROR)
 		/* failed to service fault */
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 6a74386ee83f..c4d0d2398052 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -643,7 +643,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		if (!is_canonical_address(address))
 			goto bad_req;
 
-		down_read(&svm->mm->mmap_sem);
+		mm_read_lock(svm->mm, &mmrange);
 		vma = find_extend_vma(svm->mm, address, &mmrange);
 		if (!vma || address < vma->vm_start)
 			goto invalid;
@@ -658,7 +658,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 
 		result = QI_RESP_SUCCESS;
 	invalid:
-		up_read(&svm->mm->mmap_sem);
+		mm_read_unlock(svm->mm, &mmrange);
 		mmput(svm->mm);
 	bad_req:
 		/* Accounting for major/minor faults? */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
