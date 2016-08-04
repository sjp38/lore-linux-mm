Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA46D6B0264
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:15:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so140887202wmp.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:15:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w128si2784012wmf.25.2016.08.04.01.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:15:14 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748Dsxh060151
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:15:00 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkahy86d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:15:00 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:58 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 321DC2190023
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:14:21 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748Etoh2294166
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:55 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748EtsZ001740
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:55 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/7] userfaultfd: shmem: add userfaultfd hook for shared memory faults
Date: Thu,  4 Aug 2016 11:14:16 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

When processing a page fault in shared memory area for not present page,
check the VMA determine if faults are to be handled by userfaultfd. If so,
delegate the page fault to handle_userfault.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/shmem.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 881b7a0..7ed2a1a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -69,6 +69,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
 #include <uapi/linux/memfd.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/rmap.h>
 
 #include <asm/uaccess.h>
@@ -123,13 +124,14 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 				struct shmem_inode_info *info, pgoff_t index);
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
-		gfp_t gfp, struct mm_struct *fault_mm, int *fault_type);
+		gfp_t gfp, struct vm_area_struct *vma,
+		struct vm_fault *vmf, int *fault_type);
 
 static inline int shmem_getpage(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp)
 {
 	return shmem_getpage_gfp(inode, index, pagep, sgp,
-		mapping_gfp_mask(inode->i_mapping), NULL, NULL);
+		mapping_gfp_mask(inode->i_mapping), NULL, NULL, NULL);
 }
 
 static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
@@ -1129,7 +1131,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
-	struct mm_struct *fault_mm, int *fault_type)
+	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info;
@@ -1180,7 +1182,7 @@ repeat:
 	 */
 	info = SHMEM_I(inode);
 	sbinfo = SHMEM_SB(inode->i_sb);
-	charge_mm = fault_mm ? : current->mm;
+	charge_mm = vma ? vma->vm_mm : current->mm;
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
@@ -1190,7 +1192,8 @@ repeat:
 			if (fault_type) {
 				*fault_type |= VM_FAULT_MAJOR;
 				count_vm_event(PGMAJFAULT);
-				mem_cgroup_count_vm_event(fault_mm, PGMAJFAULT);
+				mem_cgroup_count_vm_event(vma->vm_mm,
+							  PGMAJFAULT);
 			}
 			/* Here we actually start the io */
 			page = shmem_swapin(swap, gfp, info, index);
@@ -1259,6 +1262,14 @@ repeat:
 		swap_free(swap);
 
 	} else {
+		if (vma && userfaultfd_missing(vma)) {
+			unsigned long addr =
+				(unsigned long)vmf->virtual_address;
+			*fault_type = handle_userfault(vma, addr, vmf->flags,
+						       VM_UFFD_MISSING);
+			return 0;
+		}
+
 		if (shmem_acct_block(info->flags)) {
 			error = -ENOSPC;
 			goto failed;
@@ -1432,7 +1443,7 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, SGP_CACHE,
-				  gfp, vma->vm_mm, &ret);
+				  gfp, vma, vmf, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 	return ret;
@@ -3601,7 +3612,7 @@ struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 
 	BUG_ON(mapping->a_ops != &shmem_aops);
 	error = shmem_getpage_gfp(inode, index, &page, SGP_CACHE,
-				  gfp, NULL, NULL);
+				  gfp, NULL, NULL, NULL);
 	if (error)
 		page = ERR_PTR(error);
 	else
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
