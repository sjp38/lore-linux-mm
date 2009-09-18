Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B67B96B00DE
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:38:13 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8ICSFlQ015768
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:28:15 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8ICcD4B164148
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:38:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8ICcCol018453
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:38:13 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 1/7] hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on the vfs internal mount
Date: Fri, 18 Sep 2009 06:37:58 -0600
Message-Id: <0f28cb0d89a7b83f7edf92181c5d13422f5b009c.1253276847.git.ebmunson@us.ibm.com>
In-Reply-To: <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com>
References: <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, Eric B Munson <ebmunson@us.ibm.com>
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
 fs/hugetlbfs/inode.c    |   11 +++++++++--
 include/linux/hugetlb.h |   12 ++++++++++--
 ipc/shm.c               |    2 +-
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a93b885..c50853e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -507,6 +507,13 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
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
@@ -937,7 +944,7 @@ static int can_do_hugetlb_shm(void)
 }
 
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
-						struct user_struct **user)
+				struct user_struct **user, int creat_flags)
 {
 	int error = -ENOMEM;
 	struct file *file;
@@ -949,7 +956,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
-	if (!can_do_hugetlb_shm()) {
+	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
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
index 30162a5..9eb1488 100644
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
