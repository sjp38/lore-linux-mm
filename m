Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5331E6B0150
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:54:52 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7QAfH8L003308
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 04:41:17 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7QAj0cL167744
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 04:45:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7QAj0pr011769
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 04:45:00 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 1/3] hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on the vfs internal mount
Date: Wed, 26 Aug 2009 11:44:51 +0100
Message-Id: <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1251282769.git.ebmunson@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1251282769.git.ebmunson@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are two means of creating mappings backed by huge pages:

        1. mmap() a file created on hugetlbfs
        2. Use shm which creates a file on an internal mount which essentially
           maps it MAP_SHARED

The internal mount is only used for shared mappings but there is very
little that stops it being used for private mappings. This patch extends
hugetlbfs_file_setup() to deal with the creation of files that will be
mapped MAP_PRIVATE on the internal hugetlbfs mount. This extended API is
used in a subsequent patch to implement the MAP_HUGETLB mmap() flag.

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>
---
 fs/hugetlbfs/inode.c    |   21 +++++++++++++++++----
 include/linux/hugetlb.h |   12 ++++++++++--
 ipc/shm.c               |    2 +-
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index cb88dac..5584d55 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -506,6 +506,13 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
+		/*
+		 * The policy is initialized here even if we are creating a
+		 * private inode because initialization simply creates an
+		 * an empty rb tree and calls spin_lock_init(), later when we
+		 * call mpol_free_shared_policy() it will just return because
+		 * the rb tree will still be empty.
+		 */
 		mpol_shared_policy_init(&info->policy, NULL);
 		switch (mode & S_IFMT) {
 		default:
@@ -930,13 +937,19 @@ static struct file_system_type hugetlbfs_fs_type = {
 
 static struct vfsmount *hugetlbfs_vfsmount;
 
-static int can_do_hugetlb_shm(void)
+static int can_do_hugetlb_shm(int creat_flags)
 {
-	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
+	if (creat_flags != HUGETLB_SHMFS_INODE)
+		return 0;
+	if (capable(CAP_IPC_LOCK))
+		return 1;
+	if (in_group_p(sysctl_hugetlb_shm_group))
+		return 1;
+	return 0;
 }
 
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
-						struct user_struct **user)
+				struct user_struct **user, int creat_flags)
 {
 	int error = -ENOMEM;
 	struct file *file;
@@ -948,7 +961,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
-	if (!can_do_hugetlb_shm()) {
+	if (!can_do_hugetlb_shm(creat_flags)) {
 		*user = current_user();
 		if (user_shm_lock(size, *user)) {
 			WARN_ONCE(1,
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 5cbc620..38bb552 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -110,6 +110,14 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
+enum {
+	/*
+	 * The file will be used as an shm file so shmfs accounting rules
+	 * apply
+	 */
+	HUGETLB_SHMFS_INODE     = 1,
+};
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
 	uid_t   uid;
@@ -148,7 +156,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, int acct,
-						struct user_struct **user);
+				struct user_struct **user, int creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
 
@@ -170,7 +178,7 @@ static inline void set_file_hugepages(struct file *file)
 
 #define is_file_hugepages(file)			0
 #define set_file_hugepages(file)		BUG()
-#define hugetlb_file_setup(name,size,acct,user)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(name,size,acct,user,creat)	ERR_PTR(-ENOSYS)
 
 #endif /* !CONFIG_HUGETLBFS */
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 1bc4701..5ba4962 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -370,7 +370,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 		if (shmflg & SHM_NORESERVE)
 			acctflag = VM_NORESERVE;
 		file = hugetlb_file_setup(name, size, acctflag,
-							&shp->mlock_user);
+					&shp->mlock_user, HUGETLB_SHMFS_INODE);
 	} else {
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
