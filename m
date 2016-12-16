Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B01B46B0069
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:49:55 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id p127so92498080iop.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:49:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k23si6183050iod.140.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 29/42] userfaultfd: shmem: introduce vma_is_shmem
Date: Fri, 16 Dec 2016 15:48:08 +0100
Message-Id: <20161216144821.5183-30-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

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
index f9914ba..c1444c0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1355,6 +1355,16 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
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
index 11b24a8..58e20ff 100644
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
