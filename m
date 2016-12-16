Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6406B02C0
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:29 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n68so21077291itn.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i31si6178634ioo.48.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 32/42] userfaultfd: shmem: add userfaultfd hook for shared memory faults
Date: Fri, 16 Dec 2016 15:48:11 +0100
Message-Id: <20161216144821.5183-33-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

When processing a page fault in shared memory area for not present page,
check the VMA determine if faults are to be handled by userfaultfd. If so,
delegate the page fault to handle_userfault.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5cc1cb2..75866a3 100644
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
@@ -1571,7 +1573,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
-	struct mm_struct *fault_mm, int *fault_type)
+	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1625,7 +1627,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	 * bring it back from swap or allocate.
 	 */
 	sbinfo = SHMEM_SB(inode->i_sb);
-	charge_mm = fault_mm ? : current->mm;
+	charge_mm = vma ? vma->vm_mm : current->mm;
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
@@ -1635,7 +1637,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			if (fault_type) {
 				*fault_type |= VM_FAULT_MAJOR;
 				count_vm_event(PGMAJFAULT);
-				mem_cgroup_count_vm_event(fault_mm, PGMAJFAULT);
+				mem_cgroup_count_vm_event(charge_mm,
+							  PGMAJFAULT);
 			}
 			/* Here we actually start the io */
 			page = shmem_swapin(swap, gfp, info, index);
@@ -1704,6 +1707,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		swap_free(swap);
 
 	} else {
+		if (vma && userfaultfd_missing(vma)) {
+			*fault_type = handle_userfault(vmf, VM_UFFD_MISSING);
+			return 0;
+		}
+
 		/* shmem_symlink() */
 		if (mapping->a_ops != &shmem_aops)
 			goto alloc_nohuge;
@@ -1966,7 +1974,7 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		sgp = SGP_NOHUGE;
 
 	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
-				  gfp, vma->vm_mm, &ret);
+				  gfp, vma, vmf, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 	return ret;
@@ -4252,7 +4260,7 @@ struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 
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
