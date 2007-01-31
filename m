Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0VKHKQV011119
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:20 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKHKdS262682
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:20 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKHJe5010944
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:20 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 5/6] Abstract is_hugepage_only_range
Date: Wed, 31 Jan 2007 12:17:18 -0800
Message-Id: <20070131201717.13810.70579.stgit@localhost.localdomain>
In-Reply-To: <20070131201624.13810.45848.stgit@localhost.localdomain>
References: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

Some architectures define regions of the address space that can be used
exclusively for either normal pages or hugetlb pages.  Currently,
prepare_hugepage_range() is used to validate an unmapped_area for use with
hugepages and is_hugepage_only_range() is used to validate an unmapped_area for
normal pages.

Introduce a prepare_unmapped_area() file operation to abstract the validation
of unmapped areas.  If prepare_unmapped_area() is not specified, the default
behavior is to require the area to not overlap any "special" areas.

Buh-bye to another is_file_hugepages() call.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c |    1 +
 include/linux/fs.h   |    1 +
 mm/mmap.c            |   23 ++++++++++-------------
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b61592f..3eea7a5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -561,6 +561,7 @@ const struct file_operations hugetlbfs_file_operations = {
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= simple_sync_file,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
+	.prepare_unmapped_area	= prepare_hugepage_range,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1410e53..853a4f4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1094,6 +1094,7 @@ struct file_operations {
 	ssize_t (*sendfile) (struct file *, loff_t *, size_t, read_actor_t, void *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
+	int (*prepare_unmapped_area)(unsigned long addr, unsigned long len, pgoff_t pgoff);
 	int (*check_flags)(int);
 	int (*dir_notify)(struct file *filp, unsigned long arg);
 	int (*flock) (struct file *, int, struct file_lock *);
diff --git a/mm/mmap.c b/mm/mmap.c
index a5cb0a5..f8e0bd0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1374,20 +1374,17 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		return -ENOMEM;
 	if (addr & ~PAGE_MASK)
 		return -EINVAL;
-	if (file && is_file_hugepages(file))  {
-		/*
-		 * Check if the given range is hugepage aligned, and
-		 * can be made suitable for hugepages.
-		 */
-		ret = prepare_hugepage_range(addr, len, pgoff);
-	} else {
-		/*
-		 * Ensure that a normal request is not falling in a
-		 * reserved hugepage range.  For some archs like IA-64,
-		 * there is a separate region for hugepages.
-		 */
+	/*
+	 * This file may only be able to be mapped into special areas of the
+	 * addess space (eg. hugetlb pages).  If prepare_unmapped_area() is
+	 * specified, use it to validate the selected range.  If not, just
+	 * make sure the range does not overlap any special ranges.
+	 */
+	if (file && file->f_op && file->f_op->prepare_unmapped_area)
+		ret = file->f_op->prepare_unmapped_area(addr, len, pgoff);
+	else
 		ret = is_hugepage_only_range(current->mm, addr, len);
-	}
+
 	if (ret)
 		return -EINVAL;
 	return addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
