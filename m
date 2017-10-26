Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB666B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:21:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h200so3326779oib.18
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:21:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o62si1412090oif.392.2017.10.26.06.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 06:20:58 -0700 (PDT)
From: marcandre.lureau@redhat.com
Subject: [PATCH RFC] shmem: add hugetlbfs sealing
Date: Thu, 26 Oct 2017 15:20:52 +0200
Message-Id: <20171026132052.28504-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

From: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>

Hi,

Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
didn't need sealing support. One of the reasons to use memfd is to
have shared memory sealing when doing IPC. Qemu uses shared memory &
hugetables with vhost-user (used by dpdk). I am adding memfd support
in qemu, for convenience and security reasons. It would be great if
hugetlbfs had sealing support. I don't have much experience with
kernel & mm, but I came up with the following patch. It works with a
slightly modified memfd_test.c, enabling most tests again (only
pwrite() has to be skipped). I would like to have some early feedback
before I send a cleaned up series on the lkml.

Thanks!

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
---
 fs/hugetlbfs/inode.c     | 36 ++++++++++++++++++++++++----------
 include/linux/hugetlb.h  | 11 +++++++++++
 include/linux/shmem_fs.h |  2 --
 mm/shmem.c               | 51 +++++++++++++++++++++++++-----------------------
 4 files changed, 64 insertions(+), 36 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9f01a4..a39c315e6d0c 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -55,16 +55,6 @@ struct hugetlbfs_config {
 	umode_t			mode;
 };
 
-struct hugetlbfs_inode_info {
-	struct shared_policy policy;
-	struct inode vfs_inode;
-};
-
-static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
-{
-	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
-}
-
 int sysctl_hugetlb_shm_group;
 
 enum {
@@ -520,8 +510,16 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 
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
@@ -539,6 +537,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 				loff_t len)
 {
 	struct inode *inode = file_inode(file);
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 	struct address_space *mapping = inode->i_mapping;
 	struct hstate *h = hstate_inode(inode);
 	struct vm_area_struct pseudo_vma;
@@ -570,6 +569,12 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	if (error)
 		goto out;
 
+	/* do we need this if FL_KEEP_SIZE is mandatory? let's be careful */
+	if ((info->seals & F_SEAL_GROW) && offset + len > inode->i_size) {
+		error = -EPERM;
+		goto out;
+	}
+
 	/*
 	 * Initialize a pseudo vma as this is required by the huge page
 	 * allocation routines.  If NUMA is configured, use page index
@@ -660,6 +665,7 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 	struct hstate *h = hstate_inode(inode);
 	int error;
 	unsigned int ia_valid = attr->ia_valid;
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 
 	BUG_ON(!inode);
 
@@ -668,9 +674,16 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return error;
 
 	if (ia_valid & ATTR_SIZE) {
+		loff_t oldsize = inode->i_size;
+		loff_t newsize = attr->ia_size;
+
 		error = -EINVAL;
 		if (attr->ia_size & ~huge_page_mask(h))
 			return -EINVAL;
+		/* protected by i_mutex */
+		if ((newsize < oldsize && (info->seals & F_SEAL_SHRINK)) ||
+		    (newsize > oldsize && (info->seals & F_SEAL_GROW)))
+			return -EPERM;
 		error = hugetlb_vmtruncate(inode, attr->ia_size);
 		if (error)
 			return error;
@@ -723,6 +736,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 
 	inode = new_inode(sb);
 	if (inode) {
+		struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
+
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
 		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
@@ -730,6 +745,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
 		inode->i_mapping->private_data = resv_map;
+		info->seals = F_SEAL_SEAL;
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8bbbd37ab105..42945aa3bcc1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -44,6 +44,17 @@ extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
 #include <linux/shm.h>
 #include <asm/tlbflush.h>
 
+struct hugetlbfs_inode_info {
+    struct shared_policy policy;
+    struct inode vfs_inode;
+    unsigned int seals;
+};
+
+static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+{
+    return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+}
+
 struct hugepage_subpool {
 	spinlock_t lock;
 	long count;
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index b6c3540e07bc..557d0c3b6eca 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -109,8 +109,6 @@ extern void shmem_uncharge(struct inode *inode, long pages);
 
 #ifdef CONFIG_TMPFS
 
-extern int shmem_add_seals(struct file *file, unsigned int seals);
-extern int shmem_get_seals(struct file *file);
 extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 
 #else
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22807be..6ceb5f43cb10 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2722,10 +2722,10 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		     F_SEAL_GROW | \
 		     F_SEAL_WRITE)
 
-int shmem_add_seals(struct file *file, unsigned int seals)
+static int memfd_add_seals(struct file *file, unsigned int seals)
 {
 	struct inode *inode = file_inode(file);
-	struct shmem_inode_info *info = SHMEM_I(inode);
+	unsigned int *info_seals;
 	int error;
 
 	/*
@@ -2758,8 +2758,13 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 	 * other file types.
 	 */
 
-	if (file->f_op != &shmem_file_operations)
+	if (file->f_op == &shmem_file_operations)
+		info_seals = &SHMEM_I(inode)->seals;
+	else if (file->f_op == &hugetlbfs_file_operations)
+		info_seals = &HUGETLBFS_I(inode)->seals;
+	else
 		return -EINVAL;
+
 	if (!(file->f_mode & FMODE_WRITE))
 		return -EPERM;
 	if (seals & ~(unsigned int)F_ALL_SEALS)
@@ -2767,12 +2772,12 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 
 	inode_lock(inode);
 
-	if (info->seals & F_SEAL_SEAL) {
+	if (*info_seals & F_SEAL_SEAL) {
 		error = -EPERM;
 		goto unlock;
 	}
 
-	if ((seals & F_SEAL_WRITE) && !(info->seals & F_SEAL_WRITE)) {
+	if ((seals & F_SEAL_WRITE) && !(*info_seals & F_SEAL_WRITE)) {
 		error = mapping_deny_writable(file->f_mapping);
 		if (error)
 			goto unlock;
@@ -2784,23 +2789,24 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 		}
 	}
 
-	info->seals |= seals;
+	*info_seals |= seals;
 	error = 0;
 
 unlock:
 	inode_unlock(inode);
 	return error;
 }
-EXPORT_SYMBOL_GPL(shmem_add_seals);
 
-int shmem_get_seals(struct file *file)
+static int memfd_get_seals(struct file *file)
 {
-	if (file->f_op != &shmem_file_operations)
-		return -EINVAL;
+	if (file->f_op == &shmem_file_operations)
+		return SHMEM_I(file_inode(file))->seals;
+
+	if (file->f_op == &hugetlbfs_file_operations)
+		return HUGETLBFS_I(file_inode(file))->seals;
 
-	return SHMEM_I(file_inode(file))->seals;
+	return -EINVAL;
 }
-EXPORT_SYMBOL_GPL(shmem_get_seals);
 
 long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -2812,10 +2818,10 @@ long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (arg > UINT_MAX)
 			return -EINVAL;
 
-		error = shmem_add_seals(file, arg);
+		error = memfd_add_seals(file, arg);
 		break;
 	case F_GET_SEALS:
-		error = shmem_get_seals(file);
+		error = memfd_get_seals(file);
 		break;
 	default:
 		error = -EINVAL;
@@ -3659,19 +3665,16 @@ SYSCALL_DEFINE2(memfd_create,
 		const char __user *, uname,
 		unsigned int, flags)
 {
-	struct shmem_inode_info *info;
 	struct file *file;
 	int fd, error;
 	char *name;
 	long len;
+	unsigned int *info_seals;
 
 	if (!(flags & MFD_HUGETLB)) {
 		if (flags & ~(unsigned int)MFD_ALL_FLAGS)
 			return -EINVAL;
 	} else {
-		/* Sealing not supported in hugetlbfs (MFD_HUGETLB) */
-		if (flags & MFD_ALLOW_SEALING)
-			return -EINVAL;
 		/* Allow huge page size encoding in flags. */
 		if (flags & ~(unsigned int)(MFD_ALL_FLAGS |
 				(MFD_HUGE_MASK << MFD_HUGE_SHIFT)))
@@ -3723,13 +3726,13 @@ SYSCALL_DEFINE2(memfd_create,
 	file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
 	file->f_flags |= O_RDWR | O_LARGEFILE;
 
+	if (flags & MFD_HUGETLB)
+		info_seals = &HUGETLBFS_I(file_inode(file))->seals;
+	else
+		info_seals = &SHMEM_I(file_inode(file))->seals;
+
 	if (flags & MFD_ALLOW_SEALING) {
-		/*
-		 * flags check at beginning of function ensures
-		 * this is not a hugetlbfs (MFD_HUGETLB) file.
-		 */
-		info = SHMEM_I(file_inode(file));
-		info->seals &= ~F_SEAL_SEAL;
+		*info_seals &= ~F_SEAL_SEAL;
 	}
 
 	fd_install(fd, file);
-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
