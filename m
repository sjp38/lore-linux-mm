Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC4B56B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 00:34:33 -0500 (EST)
From: Cong Wang <amwang@redhat.com>
Subject: [V2 PATCH 2/2] fs: wire up .truncate_range and .fallocate
Date: Tue, 29 Nov 2011 13:33:13 +0800
Message-Id: <1322544793-2676-2-git-send-email-amwang@redhat.com>
In-Reply-To: <1322544793-2676-1-git-send-email-amwang@redhat.com>
References: <1322544793-2676-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, WANG Cong <amwang@redhat.com>, Matthew Wilcox <matthew@wil.cx>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

V1->V2:
Move tmpfs stuff into shmem_fallocate(), suggested by Christoph.

As Hugh suggested, with FALLOC_FL_PUNCH_HOLE, we can use do_fallocate()
to implement madvise_remove and finally remove .truncate_range call back.

Cc: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
 include/linux/fs.h |    1 -
 include/linux/mm.h |    2 +-
 mm/madvise.c       |    6 +++---
 mm/shmem.c         |   12 +++++++++++-
 mm/truncate.c      |   22 +++++-----------------
 5 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index e313022..266df73 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1635,7 +1635,6 @@ struct inode_operations {
 	ssize_t (*getxattr) (struct dentry *, const char *, void *, size_t);
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
-	void (*truncate_range)(struct inode *, loff_t, loff_t);
 	int (*fiemap)(struct inode *, struct fiemap_extent_info *, u64 start,
 		      u64 len);
 } ____cacheline_aligned;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3dc3a8c..0582ce8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -951,7 +951,7 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 extern void truncate_pagecache(struct inode *inode, loff_t old, loff_t new);
 extern void truncate_setsize(struct inode *inode, loff_t newsize);
 extern int vmtruncate(struct inode *inode, loff_t offset);
-extern int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end);
+extern int vmtruncate_file_range(struct file *file, loff_t offset, loff_t end);
 
 int truncate_inode_page(struct address_space *mapping, struct page *page);
 int generic_error_remove_page(struct address_space *mapping, struct page *page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 74bf193..3a281b7 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -194,7 +194,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 				struct vm_area_struct **prev,
 				unsigned long start, unsigned long end)
 {
-	struct address_space *mapping;
+	struct file *file;
 	loff_t offset, endoff;
 	int error;
 
@@ -211,7 +211,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	if ((vma->vm_flags & (VM_SHARED|VM_WRITE)) != (VM_SHARED|VM_WRITE))
 		return -EACCES;
 
-	mapping = vma->vm_file->f_mapping;
+	file = vma->vm_file;
 
 	offset = (loff_t)(start - vma->vm_start)
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
@@ -220,7 +220,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	/* vmtruncate_range needs to take i_mutex */
 	up_read(&current->mm->mmap_sem);
-	error = vmtruncate_range(mapping->host, offset, endoff);
+	error = vmtruncate_file_range(file, offset, endoff);
 	down_read(&current->mm->mmap_sem);
 	return error;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 90c835b..b435da8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1465,6 +1465,7 @@ static long shmem_fallocate(struct file *file, int mode,
 				loff_t offset, loff_t len)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
+	struct address_space *mapping = file->f_mapping;
 	pgoff_t start = offset >> PAGE_CACHE_SHIFT;
 	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
 	pgoff_t index = start;
@@ -1476,6 +1477,12 @@ static long shmem_fallocate(struct file *file, int mode,
 		return -ETXTBSY;
 
 	mutex_lock(&inode->i_mutex);
+
+	if (mapping) {
+		inode_dio_wait(mapping->host);
+		unmap_mapping_range(mapping, offset, len, 1);
+	}
+
 	i_size = inode->i_size;
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		if (!(offset > i_size || (end << PAGE_CACHE_SHIFT) > i_size))
@@ -1507,6 +1514,10 @@ static long shmem_fallocate(struct file *file, int mode,
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && (index << PAGE_CACHE_SHIFT) > i_size)
 		i_size_write(inode, index << PAGE_CACHE_SHIFT);
 
+	/* unmap again to remove racily COWed private pages */
+	if (mapping)
+		unmap_mapping_range(mapping, offset, len, 1);
+
 	goto unlock;
 
 undo:
@@ -2381,7 +2392,6 @@ static const struct file_operations shmem_file_operations = {
 
 static const struct inode_operations shmem_inode_operations = {
 	.setattr	= shmem_setattr,
-	.truncate_range	= shmem_truncate_range,
 #ifdef CONFIG_TMPFS_XATTR
 	.setxattr	= shmem_setxattr,
 	.getxattr	= shmem_getxattr,
diff --git a/mm/truncate.c b/mm/truncate.c
index 632b15e..5a7ddda 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -20,6 +20,7 @@
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
 #include <linux/cleancache.h>
+#include <linux/falloc.h>
 #include "internal.h"
 
 
@@ -602,27 +603,14 @@ int vmtruncate(struct inode *inode, loff_t newsize)
 }
 EXPORT_SYMBOL(vmtruncate);
 
-int vmtruncate_range(struct inode *inode, loff_t lstart, loff_t lend)
+int vmtruncate_file_range(struct file *file, loff_t lstart, loff_t lend)
 {
-	struct address_space *mapping = inode->i_mapping;
 	loff_t holebegin = round_up(lstart, PAGE_SIZE);
 	loff_t holelen = 1 + lend - holebegin;
 
-	/*
-	 * If the underlying filesystem is not going to provide
-	 * a way to truncate a range of blocks (punch a hole) -
-	 * we should return failure right now.
-	 */
-	if (!inode->i_op->truncate_range)
+	if (!file->f_op->fallocate)
 		return -ENOSYS;
 
-	mutex_lock(&inode->i_mutex);
-	inode_dio_wait(inode);
-	unmap_mapping_range(mapping, holebegin, holelen, 1);
-	inode->i_op->truncate_range(inode, lstart, lend);
-	/* unmap again to remove racily COWed private pages */
-	unmap_mapping_range(mapping, holebegin, holelen, 1);
-	mutex_unlock(&inode->i_mutex);
-
-	return 0;
+	return do_fallocate(file, FALLOC_FL_KEEP_SIZE|FALLOC_FL_PUNCH_HOLE,
+		     holebegin, holelen);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
