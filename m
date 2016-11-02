Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 396516B02BD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o68so24650677qkf.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w23si1916099qka.222.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for shared memory faults
Date: Wed,  2 Nov 2016 20:33:57 +0100
Message-Id: <1478115245-32090-26-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

When processing a page fault in shared memory area for not present page,
check the VMA determine if faults are to be handled by userfaultfd. If so,
delegate the page fault to handle_userfault.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 34 +++++++++++++++++++++++++++-------
 1 file changed, 27 insertions(+), 7 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index acf80c2..fe469e5 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -72,6 +72,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
 #include <uapi/linux/memfd.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/rmap.h>
 
 #include <asm/uaccess.h>
@@ -118,13 +119,14 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 				struct shmem_inode_info *info, pgoff_t index);
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
-		gfp_t gfp, struct mm_struct *fault_mm, int *fault_type);
+		gfp_t gfp, struct vm_area_struct *vma,
+		struct vm_fault *vmf, int *fault_type);
 
 int shmem_getpage(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp)
 {
 	return shmem_getpage_gfp(inode, index, pagep, sgp,
-		mapping_gfp_mask(inode->i_mapping), NULL, NULL);
+		mapping_gfp_mask(inode->i_mapping), NULL, NULL, NULL);
 }
 
 static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
@@ -1542,7 +1544,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
-	struct mm_struct *fault_mm, int *fault_type)
+	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info;
@@ -1597,7 +1599,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	 */
 	info = SHMEM_I(inode);
 	sbinfo = SHMEM_SB(inode->i_sb);
-	charge_mm = fault_mm ? : current->mm;
+	charge_mm = vma ? vma->vm_mm : current->mm;
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
@@ -1607,7 +1609,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			if (fault_type) {
 				*fault_type |= VM_FAULT_MAJOR;
 				count_vm_event(PGMAJFAULT);
-				mem_cgroup_count_vm_event(fault_mm, PGMAJFAULT);
+				mem_cgroup_count_vm_event(vma->vm_mm,
+							  PGMAJFAULT);
 			}
 			/* Here we actually start the io */
 			page = shmem_swapin(swap, gfp, info, index);
@@ -1676,6 +1679,23 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		swap_free(swap);
 
 	} else {
+		if (vma && userfaultfd_missing(vma)) {
+			struct fault_env fe = {
+				.vma = vma,
+				.address = (unsigned long)vmf->virtual_address,
+				.flags = vmf->flags,
+				/*
+				 * Hard to debug if it ends up being
+				 * used by a callee that assumes
+				 * something about the other
+				 * uninitialized fields... same as in
+				 * memory.c
+				 */
+			};
+			*fault_type = handle_userfault(&fe, VM_UFFD_MISSING);
+			return 0;
+		}
+
 		/* shmem_symlink() */
 		if (mapping->a_ops != &shmem_aops)
 			goto alloc_nohuge;
@@ -1927,7 +1947,7 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		sgp = SGP_NOHUGE;
 
 	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
-				  gfp, vma->vm_mm, &ret);
+				  gfp, vma, vmf, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 	return ret;
@@ -4212,7 +4232,7 @@ struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 
 	BUG_ON(mapping->a_ops != &shmem_aops);
 	error = shmem_getpage_gfp(inode, index, &page, SGP_CACHE,
-				  gfp, NULL, NULL);
+				  gfp, NULL, NULL, NULL);
 	if (error)
 		page = ERR_PTR(error);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
