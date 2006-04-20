Subject: [PATCH/RFC]  Page Cache Policy V0.0 3/5 alloc shared policies
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:47:44 -0400
Message-Id: <1145566064.10092.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Page Cache Policy V0.0 3/5 alloc shared policies

Dynamically allocate shared policy structs to inode, as needed.

Initialize shmem and hugetlbfs inode/address_space spolicy
pointer to null, unless superblock [mount] specifies a 
non-default policy.  Make mpol_shared_policy_lookup()
just return NULL if spolicy ptr is NULL.  This will be
treated as default policy [or fallback to task policy?].

set_policy() ops must create shared_policy struct from new
cache when a new policy is installed and no spolicy exists.
mpol_free_shared_policy() must free the spolicy when inode
is destroyed.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/include/linux/shared_policy.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/shared_policy.h	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/shared_policy.h	2006-04-20 14:19:14.000000000 -0400
@@ -27,12 +27,12 @@ struct shared_policy {
 	spinlock_t lock;
 };
 
-void mpol_shared_policy_init(struct shared_policy *, int, nodemask_t *);
-int mpol_set_shared_policy(struct shared_policy *,
+extern struct shared_policy *mpol_shared_policy_new(int, nodemask_t *);
+extern int mpol_set_shared_policy(struct shared_policy *,
 				struct vm_area_struct *,
 				unsigned long, unsigned long,
 				struct mempolicy *);
-void mpol_free_shared_policy(struct shared_policy *);
+extern void mpol_free_shared_policy(struct shared_policy **);
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
 					    unsigned long);
 
@@ -51,7 +51,7 @@ static inline void mpol_shared_policy_in
 {
 }
 
-static inline void mpol_free_shared_policy(struct shared_policy *p)
+static inline void mpol_free_shared_policy(struct shared_policy **p)
 {
 }
 
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-20 14:19:14.000000000 -0400
@@ -97,6 +97,7 @@
 #define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
 
 static struct kmem_cache *policy_cache;
+static struct kmem_cache *sp_cache;
 static struct kmem_cache *sn_cache;
 
 #define PDprintk(fmt...)
@@ -1511,10 +1512,14 @@ restart:
 	return 0;
 }
 
-void mpol_shared_policy_init(struct shared_policy *sp, int policy,
+struct shared_policy *mpol_shared_policy_new(int policy,
 				nodemask_t *policy_nodes)
 {
+	struct shared_policy *sp;
 
+	sp = kmem_cache_alloc(sp_cache, GFP_KERNEL);
+	if (!sp)
+		return NULL;
 	sp->root = RB_ROOT;
 	spin_lock_init(&sp->lock);
 
@@ -1535,6 +1540,7 @@ void mpol_shared_policy_init(struct shar
 			mpol_free(newpol);
 		}
 	}
+	return sp;
 }
 
 int mpol_set_shared_policy(struct shared_policy *sp,
@@ -1565,13 +1571,17 @@ int mpol_set_shared_policy(struct shared
 }
 
 /* Free a backing policy store on inode delete. */
-void mpol_free_shared_policy(struct shared_policy *sp)
+void mpol_free_shared_policy(struct shared_policy **spp)
 {
+	struct shared_policy *sp = *spp;
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
@@ -1582,6 +1592,8 @@ void mpol_free_shared_policy(struct shar
 		kmem_cache_free(sn_cache, n);
 	}
 	spin_unlock(&sp->lock);
+	kmem_cache_free(sp_cache, sp);
+	*spp = NULL;
 }
 
 /* assumes fs == KERNEL_DS */
@@ -1591,6 +1603,10 @@ void __init numa_policy_init(void)
 					 sizeof(struct mempolicy),
 					 0, SLAB_PANIC, NULL, NULL);
 
+	sp_cache = kmem_cache_create("shared_policy",
+				     sizeof(struct shared_policy),
+				     0, SLAB_PANIC, NULL, NULL);
+
 	sn_cache = kmem_cache_create("shared_policy_node",
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL, NULL);
Index: linux-2.6.17-rc1-mm2/mm/shmem.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/shmem.c	2006-04-20 14:18:12.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/shmem.c	2006-04-20 14:20:20.000000000 -0400
@@ -877,7 +877,8 @@ redirty:
 }
 
 #ifdef CONFIG_NUMA
-static inline int shmem_parse_mpol(char *value, int *policy, nodemask_t *policy_nodes)
+static inline int shmem_parse_mpol(char *value, int *policy,
+				 nodemask_t *policy_nodes)
 {
 	char *nodelist = strchr(value, ':');
 	int err = 1;
@@ -1294,15 +1295,24 @@ static int shmem_populate(struct vm_area
 int shmem_set_policy(struct vm_area_struct *vma, unsigned long start,
 			unsigned long end, struct mempolicy *new)
 {
-	return mpol_set_shared_policy(vma->vm_file->f_mapping->spolicy,
-					 vma, start, end, new);
+	struct shared_policy *sp = vma->vm_file->f_mapping->spolicy;
+
+	if (!sp) {
+		sp = mpol_shared_policy_new(MPOL_DEFAULT, NULL);
+		vma->vm_file->f_mapping->spolicy = sp;
+	}
+	return mpol_set_shared_policy(sp, vma, start, end, new);
 }
 
 struct mempolicy *
 shmem_get_policy(struct vm_area_struct *vma, unsigned long addr)
 {
-	return mpol_shared_policy_lookup(vma->vm_file->f_mapping->spolicy,
-		 vma_addr_to_pgoff(vma, addr, PAGE_SHIFT));
+	struct shared_policy *sp = vma->vm_file->f_mapping->spolicy;
+	if (!sp)
+		return NULL;
+
+	return mpol_shared_policy_lookup(sp,
+			 vma_addr_to_pgoff(vma, addr, PAGE_SHIFT));
 }
 #endif
 
@@ -1374,9 +1384,10 @@ shmem_get_inode(struct super_block *sb, 
 		case S_IFREG:
 			inode->i_op = &shmem_inode_operations;
 			inode->i_fop = &shmem_file_operations;
-			inode->i_mapping->spolicy = &info->policy;
-			mpol_shared_policy_init(inode->i_mapping->spolicy,
-					 sbinfo->policy, &sbinfo->policy_nodes);
+			if (sbinfo->policy != MPOL_DEFAULT)
+				inode->i_mapping->spolicy =
+					mpol_shared_policy_new(sbinfo->policy,
+							 &sbinfo->policy_nodes);
 			break;
 		case S_IFDIR:
 			inode->i_nlink++;
@@ -1385,15 +1396,6 @@ shmem_get_inode(struct super_block *sb, 
 			inode->i_op = &shmem_dir_inode_operations;
 			inode->i_fop = &simple_dir_operations;
 			break;
-		case S_IFLNK:
-			/*
-			 * Must not load anything in the rbtree,
-			 * mpol_free_shared_policy will not be called.
-			 */
-			inode->i_mapping->spolicy = &info->policy;
-			mpol_shared_policy_init(inode->i_mapping->spolicy,
-					 MPOL_DEFAULT, NULL);
-			break;
 		}
 	} else if (sbinfo->max_inodes) {
 		spin_lock(&sbinfo->stat_lock);
@@ -2135,7 +2137,7 @@ static void shmem_destroy_inode(struct i
 {
 	if ((inode->i_mode & S_IFMT) == S_IFREG) {
 		/* only struct inode is valid if it's an inline symlink */
-		mpol_free_shared_policy(inode->i_mapping->spolicy);
+		mpol_free_shared_policy(&inode->i_mapping->spolicy);
 	}
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
Index: linux-2.6.17-rc1-mm2/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/fs/hugetlbfs/inode.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/fs/hugetlbfs/inode.c	2006-04-20 14:19:14.000000000 -0400
@@ -357,7 +357,6 @@ static struct inode *hugetlbfs_get_inode
 
 	inode = new_inode(sb);
 	if (inode) {
-		struct hugetlbfs_inode_info *info;
 		inode->i_mode = mode;
 		inode->i_uid = uid;
 		inode->i_gid = gid;
@@ -366,8 +365,6 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-		info = HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -380,7 +377,10 @@ static struct inode *hugetlbfs_get_inode
 			inode->i_op = &hugetlbfs_dir_inode_operations;
 			inode->i_fop = &simple_dir_operations;
 
-			/* directory inodes start off with i_nlink == 2 (for "." entry) */
+			/*
+			 * directory inodes start off with i_nlink == 2
+			 * (for "." entry)
+			 */
 			inode->i_nlink++;
 			break;
 		case S_IFLNK:
@@ -545,7 +545,7 @@ static struct inode *hugetlbfs_alloc_ino
 static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
-	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	mpol_free_shared_policy(&inode->i_mapping->spolicy);
 	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
 }
 
Index: linux-2.6.17-rc1-mm2/include/linux/hugetlb.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/hugetlb.h	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/hugetlb.h	2006-04-20 14:19:14.000000000 -0400
@@ -138,7 +138,6 @@ struct hugetlbfs_sb_info {
 
 
 struct hugetlbfs_inode_info {
-	struct shared_policy policy;
 	/* Protected by the (global) hugetlb_lock */
 	unsigned long prereserved_hpages;
 	struct inode vfs_inode;
Index: linux-2.6.17-rc1-mm2/include/linux/shmem_fs.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/shmem_fs.h	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/shmem_fs.h	2006-04-20 14:19:14.000000000 -0400
@@ -14,7 +14,6 @@ struct shmem_inode_info {
 	unsigned long		alloced;	/* data pages alloced to file */
 	unsigned long		swapped;	/* subtotal assigned to swap */
 	unsigned long		next_index;	/* highest alloced index + 1 */
-	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct page		*i_indirect;	/* top indirect blocks page */
 	swp_entry_t		i_direct[SHMEM_NR_DIRECT]; /* first blocks */
 	struct list_head	swaplist;	/* chain of maybes on swap */
Index: linux-2.6.17-rc1-mm2/fs/inode.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/fs/inode.c	2006-04-20 14:13:48.000000000 -0400
+++ linux-2.6.17-rc1-mm2/fs/inode.c	2006-04-20 14:19:14.000000000 -0400
@@ -165,6 +165,8 @@ static struct inode *alloc_inode(struct 
 			mapping->backing_dev_info = bdi;
 		}
 		memset(&inode->u, 0, sizeof(inode->u));
+
+		mapping->spolicy = NULL;
 		inode->i_mapping = mapping;
 	}
 	return inode;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
