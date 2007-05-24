From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:28:36 -0400
Message-Id: <20070524172836.13933.76264.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
References: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 2/8] Mapped File Policy: allocate shared policies as needed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Mapped File Policy 2/8 dynamically alloc shared policies

Against 2.6.22-rc2-mm1

Remove shared policy structs from shmem and hugetlbfs inode
info structs and dynamically allocate them as needed.  Generic
mmap()ed files will use this capability.

Make shared policy pointer in address_space dependent on
CONFIG_NUMA.  Access [get/set] via wrappers that also depend
on 'NUMA [to avoid excessive #ifdef in .c files].

Initialize shmem and hugetlbfs inode/address_space spolicy
pointer to null, unless superblock [mount] specifies a 
non-default policy.

set_policy() ops must create shared_policy struct from a new
kmem cache when a new policy is installed and no spolicy exists.
mpol_shared_policy_init() replaced with mpol_shared_policy_new()
to accomplish this.

shmem must create/initialize a shared_policy when inode
allocated if the tmpfs super-block/mount point specifies a
non-default policy.

mpol_free_shared_policy() must free the spolicy, if any, when
inode is destroyed.

	Note:  I considered referencing counting the shared
	policy, but I don't think this is necessary because
	they are always 1-for-1 to a given inode and are 
	only/always deleted when the inode is destroyed.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/hugetlbfs/inode.c          |   15 +++++++-------
 fs/inode.c                    |    1 
 include/linux/fs.h            |   20 +++++++++++++++++++
 include/linux/hugetlb.h       |    1 
 include/linux/shared_policy.h |   16 ++++++++-------
 include/linux/shmem_fs.h      |    1 
 mm/mempolicy.c                |   21 ++++++++++++++++++--
 mm/shmem.c                    |   44 +++++++++++++++++++++++++-----------------
 8 files changed, 84 insertions(+), 35 deletions(-)

Index: Linux/include/linux/shared_policy.h
===================================================================
--- Linux.orig/include/linux/shared_policy.h	2007-05-23 11:34:29.000000000 -0400
+++ Linux/include/linux/shared_policy.h	2007-05-23 11:34:36.000000000 -0400
@@ -1,6 +1,7 @@
 #ifndef _LINUX_SHARED_POLICY_H
 #define _LINUX_SHARED_POLICY_H 1
 
+#include <linux/fs.h>
 #include <linux/rbtree.h>
 
 /*
@@ -27,12 +28,12 @@ struct shared_policy {
 	spinlock_t lock;
 };
 
-void mpol_shared_policy_init(struct shared_policy *, int, nodemask_t *);
-int mpol_set_shared_policy(struct shared_policy *,
+extern struct shared_policy *mpol_shared_policy_new(int, nodemask_t *);
+extern int mpol_set_shared_policy(struct shared_policy *,
 				struct vm_area_struct *,
 				struct mempolicy *);
-void mpol_free_shared_policy(struct shared_policy *);
-struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
+extern void mpol_free_shared_policy(struct shared_policy *);
+extern struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
 					    unsigned long);
 
 #else /* !NUMA */
@@ -45,12 +46,12 @@ static inline int mpol_set_shared_policy
 {
 	return -EINVAL;
 }
-static inline void mpol_shared_policy_init(struct shared_policy *info,
-					int policy, nodemask_t *nodes)
+static inline struct shared_policy *mpol_shared_policy_new(int policy,
+					nodemask_t *nodes)
 {
 }
 
-static inline void mpol_free_shared_policy(struct shared_policy *p)
+static inline void mpol_free_shared_policy(struct shared_policy *sp)
 {
 }
 
@@ -59,6 +60,7 @@ mpol_shared_policy_lookup(struct shared_
 {
 	return NULL;
 }
+
 #endif
 
 #endif /* _LINUX_SHARED_POLICY_H */
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-05-23 11:34:29.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-05-23 11:34:36.000000000 -0400
@@ -99,6 +99,7 @@
 #define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
 
 static struct kmem_cache *policy_cache;
+static struct kmem_cache *sp_cache;
 static struct kmem_cache *sn_cache;
 
 #define PDprintk(fmt...)
@@ -1529,10 +1530,17 @@ restart:
 	return 0;
 }
 
-void mpol_shared_policy_init(struct shared_policy *sp, int policy,
+/*
+ * allocate and initialize a shared policy struct
+ */
+struct shared_policy *mpol_shared_policy_new(int policy,
 				nodemask_t *policy_nodes)
 {
+	struct shared_policy *sp;
 
+	sp = kmem_cache_alloc(sp_cache, GFP_KERNEL);
+	if (!sp)
+		return NULL;
 	sp->root = RB_ROOT;
 	spin_lock_init(&sp->lock);
 
@@ -1552,6 +1560,7 @@ void mpol_shared_policy_init(struct shar
 			mpol_free(newpol);
 		}
 	}
+	return sp;
 }
 
 int mpol_set_shared_policy(struct shared_policy *sp,
@@ -1583,8 +1592,11 @@ void mpol_free_shared_policy(struct shar
 	struct sp_node *n;
 	struct rb_node *next;
 
-	if (!sp->root.rb_node)
+	if (!sp || !sp->root.rb_node)
 		return;
+
+//TODO:   locking should be unnecessary as we're only called when
+//        destroying the inode
 	spin_lock(&sp->lock);
 	next = rb_first(&sp->root);
 	while (next) {
@@ -1595,6 +1607,7 @@ void mpol_free_shared_policy(struct shar
 		kmem_cache_free(sn_cache, n);
 	}
 	spin_unlock(&sp->lock);
+	kmem_cache_free(sp_cache, sp);
 }
 
 /* assumes fs == KERNEL_DS */
@@ -1604,6 +1617,10 @@ void __init numa_policy_init(void)
 					 sizeof(struct mempolicy),
 					 0, SLAB_PANIC, NULL, NULL);
 
+	sp_cache = kmem_cache_create("shared_policy",
+				     sizeof(struct shared_policy),
+				     0, SLAB_PANIC, NULL, NULL);
+
 	sn_cache = kmem_cache_create("shared_policy_node",
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL, NULL);
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-05-23 11:34:29.000000000 -0400
+++ Linux/mm/shmem.c	2007-05-23 11:34:36.000000000 -0400
@@ -962,7 +962,8 @@ redirty:
 }
 
 #ifdef CONFIG_NUMA
-static inline int shmem_parse_mpol(char *value, int *policy, nodemask_t *policy_nodes)
+static inline int shmem_parse_mpol(char *value, int *policy,
+				 nodemask_t *policy_nodes)
 {
 	char *nodelist = strchr(value, ':');
 	int err = 1;
@@ -1139,7 +1140,8 @@ repeat:
 				*type = VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
-			swappage = shmem_swapin(mapping->spolicy, swap, idx);
+			swappage = shmem_swapin(mapping_shared_policy(mapping),
+						swap, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
@@ -1252,8 +1254,8 @@ repeat:
 		if (!filepage) {
 			spin_unlock(&info->lock);
 			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
-						    mapping->spolicy,
-						    idx);
+				 		mapping_shared_policy(mapping),
+						idx);
 			if (!filepage) {
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
@@ -1333,18 +1335,27 @@ static struct page *shmem_fault(struct v
 #ifdef CONFIG_NUMA
 int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
 {
-	struct inode *i = vma->vm_file->f_path.dentry->d_inode;
-	return mpol_set_shared_policy(&SHMEM_I(i)->policy, vma, new);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct shared_policy *sp = mapping_shared_policy(mapping);
+
+	if (!sp) {
+		sp = mpol_shared_policy_new(MPOL_DEFAULT, NULL);
+		set_mapping_shared_policy(mapping, sp);
+	}
+	return mpol_set_shared_policy(sp, vma, new);
 }
 
 struct mempolicy *
 shmem_get_policy(struct vm_area_struct *vma, unsigned long addr)
 {
-	struct inode *i = vma->vm_file->f_path.dentry->d_inode;
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct shared_policy *sp = mapping_shared_policy(mapping);
 	unsigned long idx;
 
+	if (!sp)
+		return NULL;
 	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx);
+	return mpol_shared_policy_lookup(sp, idx);
 }
 #endif
 
@@ -1418,9 +1429,10 @@ shmem_get_inode(struct super_block *sb, 
 		case S_IFREG:
 			inode->i_op = &shmem_inode_operations;
 			inode->i_fop = &shmem_file_operations;
-			inode->i_mapping->spolicy = &info->policy;
-			mpol_shared_policy_init(inode->i_mapping->spolicy,
-					 sbinfo->policy, &sbinfo->policy_nodes);
+			if (sbinfo->policy != MPOL_DEFAULT)
+				set_mapping_shared_policy(inode->i_mapping,
+					mpol_shared_policy_new(sbinfo->policy,
+						 &sbinfo->policy_nodes));
 			break;
 		case S_IFDIR:
 			inc_nlink(inode);
@@ -1431,12 +1443,9 @@ shmem_get_inode(struct super_block *sb, 
 			break;
 		case S_IFLNK:
 			/*
-			 * Must not load anything in the rbtree,
-			 * mpol_free_shared_policy will not be called.
+			 * This case only exists so that we don't attempt
+			 * to call init_special_inode() for sym links.
 			 */
-			inode->i_mapping->spolicy = &info->policy;
-			mpol_shared_policy_init(inode->i_mapping->spolicy,
-					 MPOL_DEFAULT, NULL);
 			break;
 		}
 	} else if (sbinfo->max_inodes) {
@@ -2316,7 +2325,8 @@ static void shmem_destroy_inode(struct i
 {
 	if ((inode->i_mode & S_IFMT) == S_IFREG) {
 		/* only struct inode is valid if it's an inline symlink */
-		mpol_free_shared_policy(inode->i_mapping->spolicy);
+		mpol_free_shared_policy(
+				mapping_shared_policy(inode->i_mapping));
 	}
 	shmem_acl_destroy_inode(inode);
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
Index: Linux/fs/hugetlbfs/inode.c
===================================================================
--- Linux.orig/fs/hugetlbfs/inode.c	2007-05-23 11:34:29.000000000 -0400
+++ Linux/fs/hugetlbfs/inode.c	2007-05-23 11:34:36.000000000 -0400
@@ -350,7 +350,6 @@ static struct inode *hugetlbfs_get_inode
 
 	inode = new_inode(sb);
 	if (inode) {
-		struct hugetlbfs_inode_info *info;
 		inode->i_mode = mode;
 		inode->i_uid = uid;
 		inode->i_gid = gid;
@@ -359,10 +358,9 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
-		info = HUGETLBFS_I(inode);
-		inode->i_mapping->spolicy = &info->policy;
-		mpol_shared_policy_init(inode->i_mapping->spolicy,
-					 MPOL_DEFAULT, NULL);
+		/*
+		 * leave i_mapping->spolicy NULL [default policy]
+		 */
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -375,7 +373,10 @@ static struct inode *hugetlbfs_get_inode
 			inode->i_op = &hugetlbfs_dir_inode_operations;
 			inode->i_fop = &simple_dir_operations;
 
-			/* directory inodes start off with i_nlink == 2 (for "." entry) */
+			/*
+			 * directory inodes start off with i_nlink == 2
+			 * (for "." entry)
+			 */
 			inc_nlink(inode);
 			break;
 		case S_IFLNK:
@@ -542,7 +543,7 @@ static struct inode *hugetlbfs_alloc_ino
 static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
-	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	mpol_free_shared_policy(mapping_shared_policy(inode->i_mapping));
 	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
 }
 
Index: Linux/include/linux/hugetlb.h
===================================================================
--- Linux.orig/include/linux/hugetlb.h	2007-05-23 10:57:07.000000000 -0400
+++ Linux/include/linux/hugetlb.h	2007-05-23 11:34:36.000000000 -0400
@@ -149,7 +149,6 @@ struct hugetlbfs_sb_info {
 
 
 struct hugetlbfs_inode_info {
-	struct shared_policy policy;
 	struct inode vfs_inode;
 };
 
Index: Linux/include/linux/shmem_fs.h
===================================================================
--- Linux.orig/include/linux/shmem_fs.h	2007-04-25 23:08:32.000000000 -0400
+++ Linux/include/linux/shmem_fs.h	2007-05-23 11:34:36.000000000 -0400
@@ -14,7 +14,6 @@ struct shmem_inode_info {
 	unsigned long		alloced;	/* data pages alloced to file */
 	unsigned long		swapped;	/* subtotal assigned to swap */
 	unsigned long		next_index;	/* highest alloced index + 1 */
-	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct page		*i_indirect;	/* top indirect blocks page */
 	swp_entry_t		i_direct[SHMEM_NR_DIRECT]; /* first blocks */
 	struct list_head	swaplist;	/* chain of maybes on swap */
Index: Linux/fs/inode.c
===================================================================
--- Linux.orig/fs/inode.c	2007-05-23 10:57:02.000000000 -0400
+++ Linux/fs/inode.c	2007-05-23 11:34:37.000000000 -0400
@@ -163,6 +163,7 @@ static struct inode *alloc_inode(struct 
 			mapping->backing_dev_info = bdi;
 		}
 		inode->i_private = NULL;
+		set_mapping_shared_policy(mapping, NULL);
 		inode->i_mapping = mapping;
 	}
 	return inode;
Index: Linux/include/linux/fs.h
===================================================================
--- Linux.orig/include/linux/fs.h	2007-05-23 11:34:29.000000000 -0400
+++ Linux/include/linux/fs.h	2007-05-23 11:34:37.000000000 -0400
@@ -470,7 +470,9 @@ struct address_space {
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
 
+#ifdef CONFIG_NUMA
 	struct shared_policy	*spolicy;
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -478,6 +480,24 @@ struct address_space {
 	 * of struct page's "mapping" pointer be used for PAGE_MAPPING_ANON.
 	 */
 
+#ifdef CONFIG_NUMA
+static inline struct shared_policy *
+mapping_shared_policy(struct address_space *mapping)
+{
+	return mapping->spolicy;
+}
+
+static inline void set_mapping_shared_policy(struct address_space *mapping,
+						struct shared_policy *sp)
+{
+	mapping->spolicy = sp;
+}
+
+#else
+#define mapping_shared_policy(M) (NULL)
+#define set_mapping_shared_policy(M, SP)	/* nothing */
+#endif
+
 struct block_device {
 	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
 	struct inode *		bd_inode;	/* will die */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
