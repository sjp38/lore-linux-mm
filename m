Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SJHMrv017555
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SJHM7S174202
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SJHMm3004932
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
From: Eric Munson <ebmunson@us.ibm.com>
Subject: [PATCH 2/5 V2] Add shared and reservation control to hugetlb_file_setup
Date: Mon, 28 Jul 2008 12:17:12 -0700
Message-Id: <dc484feb35ba0945ffd621c326fd325456d73789.1216928613.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, Eric Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are two kinds of "Shared" hugetlbfs mappings:
   1. using internal vfsmount use ipc/shm.c and shmctl()
   2. mmap() of /hugetlbfs/file with MAP_SHARED

There is one kind of private: mmap() of /hugetlbfs/file file with
MAP_PRIVATE

This patch adds a second class of "private" hugetlb-backed mapping.  But
we do it by sharing code with the ipc shm.  This is mostly because we
need to do our stack setup at execve() time and can't go opening files
from hugetlbfs.  The kernel-internal vfsmount for shm lets us get around
this.  We truly want anonymous memory, but MAP_PRIVATE is close enough
for now.

Currently, if the mapping on an internal mount is larger than a single
huge page, one page is allocated, one is reserved, and the rest are
faulted as needed.  For hugetlb backed stacks we do not want any
reserved pages.  This patch gives the caller of hugetlb_file_steup the
ability to control this behavior by specifying flags for private inodes
and page reservations.

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

---
Based on 2.6.26-rc8-mm1

Changes from V1:
Add creat_flags to struct hugetlbfs_inode_info
Check if space should be reserved in hugetlbfs_file_mmap
Rebase to 2.6.26-rc8-mm1

 fs/hugetlbfs/inode.c    |   52 ++++++++++++++++++++++++++++++----------------
 include/linux/hugetlb.h |   18 ++++++++++++---
 ipc/shm.c               |    2 +-
 3 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index dbd01d2..2e960d6 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -92,7 +92,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	 * way when do_mmap_pgoff unwinds (may be important on powerpc
 	 * and ia64).
 	 */
-	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
+	vma->vm_flags |= VM_HUGETLB;
 	vma->vm_ops = &hugetlb_vm_ops;
 
 	if (vma->vm_pgoff & ~(huge_page_mask(h) >> PAGE_SHIFT))
@@ -106,10 +106,13 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	ret = -ENOMEM;
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
-	if (hugetlb_reserve_pages(inode,
+	if (HUGETLBFS_I(inode)->creat_flags & HUGETLB_RESERVE) {
+		vma->vm_flags |= VM_RESERVED;
+		if (hugetlb_reserve_pages(inode,
 				vma->vm_pgoff >> huge_page_order(h),
 				len >> huge_page_shift(h), vma))
-		goto out;
+			goto out;
+	}
 
 	ret = 0;
 	hugetlb_prefault_arch_hook(vma->vm_mm);
@@ -496,7 +499,8 @@ out:
 }
 
 static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid, 
-					gid_t gid, int mode, dev_t dev)
+					gid_t gid, int mode, dev_t dev,
+					unsigned long creat_flags)
 {
 	struct inode *inode;
 
@@ -512,7 +516,9 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, NULL);
+		info->creat_flags = creat_flags;
+		if (!(creat_flags & HUGETLB_PRIVATE_INODE))
+			mpol_shared_policy_init(&info->policy, NULL);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -553,7 +559,8 @@ static int hugetlbfs_mknod(struct inode *dir,
 	} else {
 		gid = current->fsgid;
 	}
-	inode = hugetlbfs_get_inode(dir->i_sb, current->fsuid, gid, mode, dev);
+	inode = hugetlbfs_get_inode(dir->i_sb, current->fsuid, gid, mode, dev,
+					HUGETLB_RESERVE);
 	if (inode) {
 		dir->i_ctime = dir->i_mtime = CURRENT_TIME;
 		d_instantiate(dentry, inode);
@@ -589,7 +596,8 @@ static int hugetlbfs_symlink(struct inode *dir,
 		gid = current->fsgid;
 
 	inode = hugetlbfs_get_inode(dir->i_sb, current->fsuid,
-					gid, S_IFLNK|S_IRWXUGO, 0);
+					gid, S_IFLNK|S_IRWXUGO, 0,
+					HUGETLB_RESERVE);
 	if (inode) {
 		int l = strlen(symname)+1;
 		error = page_symlink(inode, symname, l);
@@ -693,7 +701,8 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
-	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	if (!(HUGETLBFS_I(inode)->creat_flags & HUGETLB_PRIVATE_INODE))
+		mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
 	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
 }
 
@@ -879,7 +888,8 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &hugetlbfs_ops;
 	sb->s_time_gran = 1;
 	inode = hugetlbfs_get_inode(sb, config.uid, config.gid,
-					S_IFDIR | config.mode, 0);
+					S_IFDIR | config.mode, 0,
+					HUGETLB_RESERVE);
 	if (!inode)
 		goto out_free;
 
@@ -944,7 +954,8 @@ static int can_do_hugetlb_shm(void)
 			can_do_mlock());
 }
 
-struct file *hugetlb_file_setup(const char *name, size_t size)
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				unsigned long creat_flags)
 {
 	int error = -ENOMEM;
 	struct file *file;
@@ -955,11 +966,13 @@ struct file *hugetlb_file_setup(const char *name, size_t size)
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
-	if (!can_do_hugetlb_shm())
-		return ERR_PTR(-EPERM);
+	if (!(creat_flags & HUGETLB_PRIVATE_INODE)) {
+		if (!can_do_hugetlb_shm())
+			return ERR_PTR(-EPERM);
 
-	if (!user_shm_lock(size, current->user))
-		return ERR_PTR(-ENOMEM);
+		if (!user_shm_lock(size, current->user))
+			return ERR_PTR(-ENOMEM);
+	}
 
 	root = hugetlbfs_vfsmount->mnt_root;
 	quick_string.name = name;
@@ -971,13 +984,15 @@ struct file *hugetlb_file_setup(const char *name, size_t size)
 
 	error = -ENOSPC;
 	inode = hugetlbfs_get_inode(root->d_sb, current->fsuid,
-				current->fsgid, S_IFREG | S_IRWXUGO, 0);
+				current->fsgid, S_IFREG | S_IRWXUGO, 0,
+				creat_flags);
 	if (!inode)
 		goto out_dentry;
 
 	error = -ENOMEM;
-	if (hugetlb_reserve_pages(inode, 0,
-			size >> huge_page_shift(hstate_inode(inode)), NULL))
+	if ((creat_flags & HUGETLB_RESERVE) &&
+		(hugetlb_reserve_pages(inode, 0,
+			size >> huge_page_shift(hstate_inode(inode)), NULL)))
 		goto out_inode;
 
 	d_instantiate(dentry, inode);
@@ -998,7 +1013,8 @@ out_inode:
 out_dentry:
 	dput(dentry);
 out_shm_unlock:
-	user_shm_unlock(size, current->user);
+	if (!(creat_flags & HUGETLB_PRIVATE_INODE))
+		user_shm_unlock(size, current->user);
 	return ERR_PTR(error);
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index eed37d7..26ffed9 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -95,12 +95,20 @@ static inline unsigned long hugetlb_total_pages(void)
 #ifndef HPAGE_MASK
 #define HPAGE_MASK	PAGE_MASK		/* Keep the compiler happy */
 #define HPAGE_SIZE	PAGE_SIZE
+#endif
+
+#endif /* !CONFIG_HUGETLB_PAGE */
 
 /* to align the pointer to the (next) huge page boundary */
 #define HPAGE_ALIGN(addr)	ALIGN(addr, HPAGE_SIZE)
-#endif
 
-#endif /* !CONFIG_HUGETLB_PAGE */
+#define HUGETLB_PRIVATE_INODE	0x00000001UL	/* The file is being created on
+						 * the internal hugetlbfs mount
+						 * and is private to the
+						 * process */
+
+#define HUGETLB_RESERVE	0x00000002UL	/* Reserve the huge pages backed by the
+					 * new file */
 
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
@@ -125,6 +133,7 @@ struct hugetlbfs_sb_info {
 struct hugetlbfs_inode_info {
 	struct shared_policy policy;
 	struct inode vfs_inode;
+	unsigned long creat_flags;
 };
 
 static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
@@ -139,7 +148,8 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t);
+struct file *hugetlb_file_setup(const char *name, size_t,
+				unsigned long creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
 
@@ -161,7 +171,7 @@ static inline void set_file_hugepages(struct file *file)
 
 #define is_file_hugepages(file)		0
 #define set_file_hugepages(file)	BUG()
-#define hugetlb_file_setup(name,size)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(name,size,creat_flags)	ERR_PTR(-ENOSYS)
 
 #endif /* !CONFIG_HUGETLBFS */
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 2774bad..3b5849f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -365,7 +365,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
 		/* hugetlb_file_setup takes care of mlock user accounting */
-		file = hugetlb_file_setup(name, size);
+		file = hugetlb_file_setup(name, size, HUGETLB_RESERVE);
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
