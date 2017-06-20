Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A673B6B02F3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 132so56115851pgb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si7389861plm.55.2017.06.19.23.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:10 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6IkM5066879
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:10 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b6evay7ak-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:10 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:07 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/7] userfaultfd: shmem: add shmem_mfill_zeropage_pte for userfaultfd support
Date: Tue, 20 Jun 2017 09:20:48 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

shmem_mfill_zeropage_pte is the low level routine that implements the
userfaultfd UFFDIO_ZEROPAGE command. Since for shmem mappings zero pages are
always allocated and accounted, the new method is a slight extension of the
existing shmem_mcopy_atomic_pte.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/shmem_fs.h |  6 +++++
 mm/shmem.c               | 62 +++++++++++++++++++++++++++++++++++-------------
 2 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index a7d6bd2..b6c3540 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -137,9 +137,15 @@ extern int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm, pmd_t *dst_pmd,
 				  unsigned long dst_addr,
 				  unsigned long src_addr,
 				  struct page **pagep);
+extern int shmem_mfill_zeropage_pte(struct mm_struct *dst_mm,
+				    pmd_t *dst_pmd,
+				    struct vm_area_struct *dst_vma,
+				    unsigned long dst_addr);
 #else
 #define shmem_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
 			       src_addr, pagep)        ({ BUG(); 0; })
+#define shmem_mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma, \
+				 dst_addr)      ({ BUG(); 0; })
 #endif
 
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index a92e3d7..e775a49 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2197,12 +2197,13 @@ bool shmem_mapping(struct address_space *mapping)
 	return mapping->a_ops == &shmem_aops;
 }
 
-int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
-			   pmd_t *dst_pmd,
-			   struct vm_area_struct *dst_vma,
-			   unsigned long dst_addr,
-			   unsigned long src_addr,
-			   struct page **pagep)
+static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
+				  pmd_t *dst_pmd,
+				  struct vm_area_struct *dst_vma,
+				  unsigned long dst_addr,
+				  unsigned long src_addr,
+				  bool zeropage,
+				  struct page **pagep)
 {
 	struct inode *inode = file_inode(dst_vma->vm_file);
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -2225,17 +2226,22 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 		if (!page)
 			goto out_unacct_blocks;
 
-		page_kaddr = kmap_atomic(page);
-		ret = copy_from_user(page_kaddr, (const void __user *)src_addr,
-				     PAGE_SIZE);
-		kunmap_atomic(page_kaddr);
-
-		/* fallback to copy_from_user outside mmap_sem */
-		if (unlikely(ret)) {
-			*pagep = page;
-			shmem_inode_unacct_blocks(inode, 1);
-			/* don't free the page */
-			return -EFAULT;
+		if (!zeropage) {	/* mcopy_atomic */
+			page_kaddr = kmap_atomic(page);
+			ret = copy_from_user(page_kaddr,
+					     (const void __user *)src_addr,
+					     PAGE_SIZE);
+			kunmap_atomic(page_kaddr);
+
+			/* fallback to copy_from_user outside mmap_sem */
+			if (unlikely(ret)) {
+				*pagep = page;
+				shmem_inode_unacct_blocks(inode, 1);
+				/* don't free the page */
+				return -EFAULT;
+			}
+		} else {		/* mfill_zeropage_atomic */
+			clear_highpage(page);
 		}
 	} else {
 		page = *pagep;
@@ -2301,6 +2307,28 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	goto out;
 }
 
+int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
+			   pmd_t *dst_pmd,
+			   struct vm_area_struct *dst_vma,
+			   unsigned long dst_addr,
+			   unsigned long src_addr,
+			   struct page **pagep)
+{
+	return shmem_mfill_atomic_pte(dst_mm, dst_pmd, dst_vma,
+				      dst_addr, src_addr, false, pagep);
+}
+
+int shmem_mfill_zeropage_pte(struct mm_struct *dst_mm,
+			     pmd_t *dst_pmd,
+			     struct vm_area_struct *dst_vma,
+			     unsigned long dst_addr)
+{
+	struct page *page = NULL;
+
+	return shmem_mfill_atomic_pte(dst_mm, dst_pmd, dst_vma,
+				      dst_addr, 0, true, &page);
+}
+
 #ifdef CONFIG_TMPFS
 static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_short_symlink_operations;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
