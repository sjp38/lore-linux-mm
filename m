Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6B526B025E
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 09:40:12 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 14so10363028oii.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 06:40:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z109si1571786otb.452.2017.11.06.06.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 06:40:11 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v2 4/9] hugetlbfs: implement memfd sealing
Date: Mon,  6 Nov 2017 15:39:39 +0100
Message-Id: <20171106143944.13821-5-marcandre.lureau@redhat.com>
In-Reply-To: <20171106143944.13821-1-marcandre.lureau@redhat.com>
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Implements memfd sealing, similar to shmem:
- WRITE: deny fallocate(PUNCH_HOLE). mmap() write is denied in
  memfd_add_seals(). write() doesn't exist for hugetlbfs.
- SHRINK: added similar check as shmem_setattr()
- GROW: added similar check as shmem_setattr() & shmem_fallocate()

Except write() operation that doesn't exist with hugetlbfs, that
should make sealing as close as it can be to shmem support.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 29 +++++++++++++++++++++++++++--
 include/linux/hugetlb.h |  1 +
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index f57aab929e41..01f5aa6ea57a 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -510,8 +510,16 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 
 	if (hole_end > hole_start) {
 		struct address_space *mapping = inode->i_mapping;
+		struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 
 		inode_lock(inode);
+
+		/* protected by i_mutex */
+		if (info->seals & F_SEAL_WRITE) {
+			inode_unlock(inode);
+			return -EPERM;
+		}
+
 		i_mmap_lock_write(mapping);
 		if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
 			hugetlb_vmdelete_list(&mapping->i_mmap,
@@ -529,6 +537,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 				loff_t len)
 {
 	struct inode *inode = file_inode(file);
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 	struct address_space *mapping = inode->i_mapping;
 	struct hstate *h = hstate_inode(inode);
 	struct vm_area_struct pseudo_vma;
@@ -560,6 +569,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	if (error)
 		goto out;
 
+	if ((info->seals & F_SEAL_GROW) && offset + len > inode->i_size) {
+		error = -EPERM;
+		goto out;
+	}
+
 	/*
 	 * Initialize a pseudo vma as this is required by the huge page
 	 * allocation routines.  If NUMA is configured, use page index
@@ -650,6 +664,7 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 	struct hstate *h = hstate_inode(inode);
 	int error;
 	unsigned int ia_valid = attr->ia_valid;
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 
 	BUG_ON(!inode);
 
@@ -658,10 +673,17 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return error;
 
 	if (ia_valid & ATTR_SIZE) {
+		loff_t oldsize = inode->i_size;
+		loff_t newsize = attr->ia_size;
+
 		error = -EINVAL;
-		if (attr->ia_size & ~huge_page_mask(h))
+		if (newsize & ~huge_page_mask(h))
 			return -EINVAL;
-		error = hugetlb_vmtruncate(inode, attr->ia_size);
+		/* protected by i_mutex */
+		if ((newsize < oldsize && (info->seals & F_SEAL_SHRINK)) ||
+		    (newsize > oldsize && (info->seals & F_SEAL_GROW)))
+			return -EPERM;
+		error = hugetlb_vmtruncate(inode, newsize);
 		if (error)
 			return error;
 	}
@@ -713,6 +735,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 
 	inode = new_inode(sb);
 	if (inode) {
+		struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
+
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
 		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
@@ -720,6 +744,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
 		inode->i_mapping->private_data = resv_map;
+		info->seals = F_SEAL_SEAL;
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 590a77433a14..2a21c59a9952 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -282,6 +282,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 struct hugetlbfs_inode_info {
 	struct shared_policy policy;
 	struct inode vfs_inode;
+	unsigned int seals;
 };
 
 static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
