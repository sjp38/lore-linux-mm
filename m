Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09889
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:55:39 -0800 (PST)
Date: Sun, 2 Feb 2003 02:55:46 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025546.2a29db61.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

6/4

hugetlbfs: fix truncate


- Opening a hugetlbfs file O_TRUNC calls the generic vmtruncate() functions
  and nukes the kernel.

  Give S_ISREG hugetlbfs files a inode_operations, and hence a setattr
  which know how to handle these files.

- Don't permit the user to truncate hugetlbfs files to sizes which are not
  a multiple of HPAGE_SIZE.

- We don't support expanding in ftruncate(), so remove that code.




 hugetlbfs/inode.c |   39 ++++++++++++++++-----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

diff -puN fs/hugetlbfs/inode.c~hugetlbfs-truncate-fix fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~hugetlbfs-truncate-fix	2003-02-02 01:17:04.000000000 -0800
+++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-02 01:17:04.000000000 -0800
@@ -34,6 +34,7 @@ static struct super_operations hugetlbfs
 static struct address_space_operations hugetlbfs_aops;
 struct file_operations hugetlbfs_file_operations;
 static struct inode_operations hugetlbfs_dir_inode_operations;
+static struct inode_operations hugetlbfs_inode_operations;
 
 static struct backing_dev_info hugetlbfs_backing_dev_info = {
 	.ra_pages	= 0,	/* No readahead */
@@ -326,44 +327,29 @@ static void hugetlb_vmtruncate_list(stru
 	}
 }
 
+/*
+ * Expanding truncates are not allowed.
+ */
 static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 {
 	unsigned long pgoff;
 	struct address_space *mapping = inode->i_mapping;
-	unsigned long limit;
 
-	pgoff = (offset + HPAGE_SIZE - 1) >> HPAGE_SHIFT;
+	if (offset > inode->i_size)
+		return -EINVAL;
 
-	if (inode->i_size < offset)
-		goto do_expand;
+	BUG_ON(offset & ~HPAGE_MASK);
+	pgoff = offset >> HPAGE_SHIFT;
 
 	inode->i_size = offset;
 	down(&mapping->i_shared_sem);
-	if (list_empty(&mapping->i_mmap) && list_empty(&mapping->i_mmap_shared))
-		goto out_unlock;
 	if (!list_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
 	if (!list_empty(&mapping->i_mmap_shared))
 		hugetlb_vmtruncate_list(&mapping->i_mmap_shared, pgoff);
-
-out_unlock:
 	up(&mapping->i_shared_sem);
 	truncate_hugepages(mapping, offset);
 	return 0;
-
-do_expand:
-	limit = current->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && offset > limit)
-		goto out_sig;
-	if (offset > inode->i_sb->s_maxbytes)
-		goto out;
-	inode->i_size = offset;
-	return 0;
-
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out:
-	return -EFBIG;
 }
 
 static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
@@ -390,7 +376,9 @@ static int hugetlbfs_setattr(struct dent
 		goto out;
 
 	if (ia_valid & ATTR_SIZE) {
-		error = hugetlb_vmtruncate(inode, attr->ia_size);
+		error = -EINVAL;
+		if (!(attr->ia_size & ~HPAGE_MASK))
+			error = hugetlb_vmtruncate(inode, attr->ia_size);
 		if (error)
 			goto out;
 		attr->ia_valid &= ~ATTR_SIZE;
@@ -425,6 +413,7 @@ hugetlbfs_get_inode(struct super_block *
 			init_special_inode(inode, mode, dev);
 			break;
 		case S_IFREG:
+			inode->i_op = &hugetlbfs_inode_operations;
 			inode->i_fop = &hugetlbfs_file_operations;
 			break;
 		case S_IFDIR:
@@ -525,6 +514,10 @@ static struct inode_operations hugetlbfs
 	.setattr	= hugetlbfs_setattr,
 };
 
+static struct inode_operations hugetlbfs_inode_operations = {
+	.setattr	= hugetlbfs_setattr,
+};
+
 static struct super_operations hugetlbfs_ops = {
 	.statfs		= simple_statfs,
 	.drop_inode	= hugetlbfs_drop_inode,

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
