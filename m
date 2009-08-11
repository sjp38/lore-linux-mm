Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ACBD96B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:32 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7BMHOiY024060
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:17:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7BMDVwS254110
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7BMDUOY018815
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:30 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 1/3] hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on the vfs internal mount
Date: Tue, 11 Aug 2009 23:13:17 +0100
Message-Id: <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are two means of creating mappings backed by huge pages:

        1. mmap() a file created on hugetlbfs
        2. Use shm which creates a file on an internal mount which essentially
           maps it MAP_SHARED

The internal mount is only used for shared mappings but there is very
little that stops it being used for private mappings. This patch extends
hugetlbfs_file_setup() to deal with the creation of files that will be
mapped MAP_PRIVATE on the internal hugetlbfs mount. This extended API is
used in a subsequent patch to implement the MAP_LARGEPAGE mmap() flag.

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>
---
 fs/hugetlbfs/inode.c    |   22 ++++++++++++++++++----
 include/linux/hugetlb.h |   10 +++++++++-
 ipc/shm.c               |    3 ++-
 3 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 941c842..361f536 100644
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
@@ -930,12 +937,19 @@ static struct file_system_type hugetlbfs_fs_type = {
 
 static struct vfsmount *hugetlbfs_vfsmount;
 
-static int can_do_hugetlb_shm(void)
+static int can_do_hugetlb_shm(int creat_flags)
 {
-	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
+	if (!(creat_flags & HUGETLB_SHMFS_INODE))
+		return 0;
+	if (capable(CAP_IPC_LOCK))
+		return 1;
+	if (in_group_p(sysctl_hugetlb_shm_group))
+		return 1;
+	return 0;
 }
 
-struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
+struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
+				int creat_flags)
 {
 	int error = -ENOMEM;
 	int unlock_shm = 0;
@@ -948,7 +962,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
-	if (!can_do_hugetlb_shm()) {
+	if (!can_do_hugetlb_shm(creat_flags)) {
 		if (user_shm_lock(size, user)) {
 			unlock_shm = 1;
 			WARN_ONCE(1,
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2723513..78b6ddf 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -109,6 +109,14 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
+enum {
+	/*
+	 * The file will be used as an shm file so shmfs accounting rules
+	 * apply
+	 */
+	HUGETLB_SHMFS_INODE     = 0x01,
+};
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
 	uid_t   uid;
@@ -146,7 +154,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t, int);
+struct file *hugetlb_file_setup(const char *name, size_t, int, int);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 15dd238..801c68a 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -369,7 +369,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 		/* hugetlb_file_setup applies strict accounting */
 		if (shmflg & SHM_NORESERVE)
 			acctflag = VM_NORESERVE;
-		file = hugetlb_file_setup(name, size, acctflag);
+		file = hugetlb_file_setup(name, size, acctflag,
+					HUGETLB_SHMFS_INODE);
 		shp->mlock_user = current_user();
 	} else {
 		/*
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
