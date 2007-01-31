Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l0VKGfVM019368
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:41 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKGlmb549176
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:16:47 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKGlPY024695
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:16:47 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/6] hugetlb: share shmem_inode_info
Date: Wed, 31 Jan 2007 12:16:45 -0800
Message-Id: <20070131201645.13810.17592.stgit@localhost.localdomain>
In-Reply-To: <20070131201624.13810.45848.stgit@localhost.localdomain>
References: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

The definition of the inode_info struct is different between
hugetlbfs and shmem even though most of the code that operates on this
data is shared between the two.

Define hugetlbfs_inode_info in terms of shmem_inode_info which creates a
handy place to mark shm segments hugetlb (without the ugly file_operations
check).  Sharing this structure also goes a long way towards removing all
hugetlbfs special casing in the shm code (should that be desired in the
future).

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c     |    9 +++++----
 include/linux/hugetlb.h  |   11 ++++-------
 include/linux/shmem_fs.h |    1 +
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4f4cd13..bd54e7e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -346,7 +346,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 
 	inode = new_inode(sb);
 	if (inode) {
-		struct hugetlbfs_inode_info *info;
+		hugetlbfs_inode_info *info;
 		inode->i_mode = mode;
 		inode->i_uid = uid;
 		inode->i_gid = gid;
@@ -356,6 +356,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
+		memset(info, 0, offsetof(hugetlbfs_inode_info, vfs_inode));
 		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
 		default:
@@ -518,7 +519,7 @@ static struct kmem_cache *hugetlbfs_inode_cachep;
 static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 {
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(sb);
-	struct hugetlbfs_inode_info *p;
+	hugetlbfs_inode_info *p;
 
 	if (unlikely(!hugetlbfs_dec_free_inodes(sbinfo)))
 		return NULL;
@@ -547,7 +548,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 
 static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
-	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
+	hugetlbfs_inode_info *ei = (hugetlbfs_inode_info *)foo;
 
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
 	    SLAB_CTOR_CONSTRUCTOR)
@@ -798,7 +799,7 @@ static int __init init_hugetlbfs_fs(void)
 	struct vfsmount *vfsmount;
 
 	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
-					sizeof(struct hugetlbfs_inode_info),
+					sizeof(hugetlbfs_inode_info),
 					0, 0, init_once, NULL);
 	if (hugetlbfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a60995a..a184933 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -4,6 +4,7 @@
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
+#include <linux/shmem_fs.h>
 #include <asm/tlbflush.h>
 
 struct ctl_table;
@@ -144,15 +145,11 @@ struct hugetlbfs_sb_info {
 	spinlock_t	stat_lock;
 };
 
+typedef struct shmem_inode_info hugetlbfs_inode_info;
 
-struct hugetlbfs_inode_info {
-	struct shared_policy policy;
-	struct inode vfs_inode;
-};
-
-static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+static inline hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
 {
-	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+	return container_of(inode, hugetlbfs_inode_info, vfs_inode);
 }
 
 static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 3ea0b6e..23707f1 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -12,6 +12,7 @@
 #define SHMEM_PAGEIN	0x00000001
 #define SHMEM_TRUNCATE	0x00000002
 
+/* Hugetlbfs is now using this structure definition */
 struct shmem_inode_info {
 	spinlock_t		lock;
 	unsigned long		flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
