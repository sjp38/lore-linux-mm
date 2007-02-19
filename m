Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIWTmS028252
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:32:29 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIVk9d292748
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:46 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIVjSD011041
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:45 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/7] copy_vma for hugetlbfs
Date: Mon, 19 Feb 2007 10:31:44 -0800
Message-Id: <20070219183144.27318.64028.stgit@localhost.localdomain>
In-Reply-To: <20070219183123.27318.27319.stgit@localhost.localdomain>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c |    6 ++++++
 mm/memory.c          |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4f4cd13..c0a7984 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -36,6 +36,7 @@
 static struct super_operations hugetlbfs_ops;
 static const struct address_space_operations hugetlbfs_aops;
 const struct file_operations hugetlbfs_file_operations;
+static struct pagetable_operations_struct hugetlbfs_pagetable_ops;
 static struct inode_operations hugetlbfs_dir_inode_operations;
 static struct inode_operations hugetlbfs_inode_operations;
 
@@ -70,6 +71,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	 */
 	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
 	vma->vm_ops = &hugetlb_vm_ops;
+	vma->pagetable_ops = &hugetlbfs_pagetable_ops;
 
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
@@ -560,6 +562,10 @@ const struct file_operations hugetlbfs_file_operations = {
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
 };
 
+static struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
+	.copy_vma		= copy_hugetlb_page_range,
+};
+
 static struct inode_operations hugetlbfs_dir_inode_operations = {
 	.create		= hugetlbfs_create,
 	.lookup		= simple_lookup,
diff --git a/mm/memory.c b/mm/memory.c
index ef09f0a..80eafd5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -602,8 +602,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			return 0;
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+	if (has_pt_op(vma, copy_vma))
+		return pt_op(vma, copy_vma)(dst_mm, src_mm, vma);
 
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
