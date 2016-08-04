Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 146996B0260
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:14:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so140913519wmz.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:14:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ld7si12384900wjb.76.2016.08.04.01.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:14:57 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748Ds18095681
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:14:55 -0400
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkahy21x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:14:55 -0400
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:53 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0CF6217D8024
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:27 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748EonF36110462
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:50 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748En6w003069
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:50 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/7] userfaultfd: shmem: introduce vma_is_shmem
Date: Thu,  4 Aug 2016 11:14:14 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Currently userfault relies on vma_is_anonymous and vma_is_hugetlb to ensure
compatibility of a VMA with userfault. Introduction of vma_is_shmem allows
detection if tmpfs backed VMAs, so that they may be used with userfaultfd.
Current implementation presumes usage of vma_is_shmem only by slow path
routines in userfaultfd, therefore the vma_is_shmem is not made inline to
leave the few remaining free bits in vm_flags.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/mm.h | 10 ++++++++++
 mm/shmem.c         |  5 +++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1dedeb8..7a20398 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1343,6 +1343,16 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 	return !vma->vm_ops;
 }
 
+#ifdef CONFIG_SHMEM
+/*
+ * The vma_is_shmem is not inline because it is used only by slow
+ * paths in userfault.
+ */
+bool vma_is_shmem(struct vm_area_struct *vma);
+#else
+static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }
+#endif
+
 static inline int stack_guard_page_start(struct vm_area_struct *vma,
 					     unsigned long addr)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index fcf560c..881b7a0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -194,6 +194,11 @@ static const struct inode_operations shmem_dir_inode_operations;
 static const struct inode_operations shmem_special_inode_operations;
 static const struct vm_operations_struct shmem_vm_ops;
 
+bool vma_is_shmem(struct vm_area_struct *vma)
+{
+	return vma->vm_ops == &shmem_vm_ops;
+}
+
 static LIST_HEAD(shmem_swaplist);
 static DEFINE_MUTEX(shmem_swaplist_mutex);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
