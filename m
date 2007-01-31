Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0VKGwgl018557
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:58 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKGw3p284450
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKGwNC009737
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:58 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/6] Use inode_info to annotate hugetlbfs shm segments
Date: Wed, 31 Jan 2007 12:16:56 -0800
Message-Id: <20070131201656.13810.85086.stgit@localhost.localdomain>
In-Reply-To: <20070131201624.13810.45848.stgit@localhost.localdomain>
References: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

Now that hugetlbfs and shmem share the same inode_info struct, add a
SHMEM_flag to mark the hugetlb shm segments as special.  We can then check
that flag (rather than using file_operations) for hugetlb special cases.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c     |    1 +
 include/linux/shmem_fs.h |   10 ++++++++++
 ipc/shm.c                |   12 ++++++------
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index bd54e7e..c95dc47 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -357,6 +357,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
 		memset(info, 0, offsetof(hugetlbfs_inode_info, vfs_inode));
+		info->flags |= SHMEM_HUGETLBFS;
 		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
 		default:
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 23707f1..c6ae0c8 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -3,6 +3,7 @@
 
 #include <linux/swap.h>
 #include <linux/mempolicy.h>
+#include <linux/shm.h>
 
 /* inode in-kernel data */
 
@@ -11,6 +12,7 @@
 /* These info->flags are used to handle pagein/truncate races efficiently */
 #define SHMEM_PAGEIN	0x00000001
 #define SHMEM_TRUNCATE	0x00000002
+#define SHMEM_HUGETLBFS	0x00000004 /* Backed by hugetlbfs */
 
 /* Hugetlbfs is now using this structure definition */
 struct shmem_inode_info {
@@ -45,6 +47,14 @@ static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 	return container_of(inode, struct shmem_inode_info, vfs_inode);
 }
 
+static inline int is_shm_hugetlbfs(struct shmid_kernel *shp)
+{
+	struct shmem_inode_info *info;
+
+	info = SHMEM_I(shp->shm_file->f_path.dentry->d_inode);
+	return info->flags & SHMEM_HUGETLBFS;
+}
+
 #ifdef CONFIG_TMPFS_POSIX_ACL
 int shmem_permission(struct inode *, int, struct nameidata *);
 int shmem_acl_init(struct inode *, struct inode *);
diff --git a/ipc/shm.c b/ipc/shm.c
index f8e10a2..6054b16 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -184,7 +184,7 @@ static void shm_destroy(struct ipc_namespace *ns, struct shmid_kernel *shp)
 	ns->shm_tot -= (shp->shm_segsz + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	shm_rmid(ns, shp->id);
 	shm_unlock(shp);
-	if (!is_file_hugepages(shp->shm_file))
+	if (!is_shm_hugetlbfs(shp))
 		shmem_lock(shp->shm_file, 0, shp->mlock_user);
 	else
 		user_shm_unlock(shp->shm_file->f_path.dentry->d_inode->i_size,
@@ -497,7 +497,7 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
 
 		inode = shp->shm_file->f_path.dentry->d_inode;
 
-		if (is_file_hugepages(shp->shm_file)) {
+		if (is_shm_hugetlbfs(shp)) {
 			struct address_space *mapping = inode->i_mapping;
 			*rss += (HPAGE_SIZE/PAGE_SIZE)*mapping->nrpages;
 		} else {
@@ -607,7 +607,7 @@ asmlinkage long sys_shmctl (int shmid, int cmd, struct shmid_ds __user *buf)
 		tbuf.shm_ctime	= shp->shm_ctim;
 		tbuf.shm_cpid	= shp->shm_cprid;
 		tbuf.shm_lpid	= shp->shm_lprid;
-		if (!is_file_hugepages(shp->shm_file))
+		if (!is_shm_hugetlbfs(shp))
 			tbuf.shm_nattch	= shp->shm_nattch;
 		else
 			tbuf.shm_nattch = file_count(shp->shm_file) - 1;
@@ -650,14 +650,14 @@ asmlinkage long sys_shmctl (int shmid, int cmd, struct shmid_ds __user *buf)
 		
 		if(cmd==SHM_LOCK) {
 			struct user_struct * user = current->user;
-			if (!is_file_hugepages(shp->shm_file)) {
+			if (!is_shm_hugetlbfs(shp)) {
 				err = shmem_lock(shp->shm_file, 1, user);
 				if (!err) {
 					shp->shm_perm.mode |= SHM_LOCKED;
 					shp->mlock_user = user;
 				}
 			}
-		} else if (!is_file_hugepages(shp->shm_file)) {
+		} else if (!is_shm_hugetlbfs(shp)) {
 			shmem_lock(shp->shm_file, 0, shp->mlock_user);
 			shp->shm_perm.mode &= ~SHM_LOCKED;
 			shp->mlock_user = NULL;
@@ -1004,7 +1004,7 @@ static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 			  shp->shm_segsz,
 			  shp->shm_cprid,
 			  shp->shm_lprid,
-			  is_file_hugepages(shp->shm_file) ? (file_count(shp->shm_file) - 1) : shp->shm_nattch,
+			  is_shm_hugetlbfs(shp) ? (file_count(shp->shm_file) - 1) : shp->shm_nattch,
 			  shp->shm_perm.uid,
 			  shp->shm_perm.gid,
 			  shp->shm_perm.cuid,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
