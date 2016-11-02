Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA0B6B02B1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l20so10728228qta.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s189si1940315qkh.34.2016.11.02.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 22/33] userfaultfd: shmem: introduce vma_is_shmem
Date: Wed,  2 Nov 2016 20:33:54 +0100
Message-Id: <1478115245-32090-23-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

Currently userfault relies on vma_is_anonymous and vma_is_hugetlb to ensure
compatibility of a VMA with userfault. Introduction of vma_is_shmem allows
detection if tmpfs backed VMAs, so that they may be used with userfaultfd.
Current implementation presumes usage of vma_is_shmem only by slow path
routines in userfaultfd, therefore the vma_is_shmem is not made inline to
leave the few remaining free bits in vm_flags.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h | 10 ++++++++++
 mm/shmem.c         |  5 +++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ec18964..fd98303 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1365,6 +1365,16 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
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
index 6e5fe90..66deb90 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -191,6 +191,11 @@ static const struct inode_operations shmem_special_inode_operations;
 static const struct vm_operations_struct shmem_vm_ops;
 static struct file_system_type shmem_fs_type;
 
+bool vma_is_shmem(struct vm_area_struct *vma)
+{
+	return vma->vm_ops == &shmem_vm_ops;
+}
+
 static LIST_HEAD(shmem_swaplist);
 static DEFINE_MUTEX(shmem_swaplist_mutex);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
