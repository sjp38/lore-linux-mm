From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:52:30 -0400
Message-Id: <20070625195230.21210.80475.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 1/11] Shared Policy: move shared policy to inode/mapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Policy Infrstructure 1/11 move shared policy to inode/mapping

Against 2.6.22-rc4-mm2

This patch starts the process of cleaning the shmem shared
[mem]policy infrastructure for use with hugetlb shmem segments
and eventually, I hope, for use with generic mmap()ed files.

1) add a struct shared_policy pointer to struct address_space
   This effectively adds it to each inode in i_data.  get_policy
   vma ops will locate this via vma->vm_file->f_mapping->spolicy.
   Modify [temporarily] mpol_shared_policy_init() to initialize
   via a shared policy pointer.

	A subsequent patch will make this struct dependent
	on CONFIG_NUMA so as not to burden systems that
	don't use numa.  At that point all accesses to
	spolicy will also be made dependent on 'NUMA via
	wrapper functions/macros.  I didn't do that in this
	patch because I'd just have to change the wrappers
	in the next patch where I dynamically alloc shared
	policies.

2) create a shared_policy.h header and move the shared policy
   support from mempolicy.h to shared_policy.h.

3) modify mpol_shared_policy_lookup() to return NULL if
   spolicy pointer contains NULL.  get_vma_policy() will
   substitute the process policy, if any, else the default
   policy.

4) modify shmem, the only existing user of shared policy
   infrastructure, to work with changes above.  At this
   point, just use the shared_policy embedded in the shmem
   inode info struct.  A later patch will dynamically
   allocate the struct when needed.

   Actually, hugetlbfs inodes also contain a shared policy, but
   the vma's get|set_policy ops are not hooked up.  This patch
   modifies hugetlbfs_get_inode() to initialize the shared
   policy struct embedded in its info struct via the i_mapping's
   spolicy pointer.  A later patch will "hook up" hugetlb
   mappings to the get|set_policy ops.

5) some miscellaneous cleanup to use "sp" for shared policy
   in routines that take it as an arg.  Prior use of "info"
   seemed misleading, and use of "p" was just plain 
   inconsistent.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/hugetlbfs/inode.c          |    4 +-
 include/linux/fs.h            |    3 +
 include/linux/mempolicy.h     |   54 -----------------------------------
 include/linux/shared_policy.h |   64 ++++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c                |   27 +++++++++--------
 mm/shmem.c                    |   38 ++++++++++++------------
 6 files changed, 104 insertions(+), 86 deletions(-)

Index: Linux/include/linux/fs.h
===================================================================
--- Linux.orig/include/linux/fs.h	2007-06-22 13:07:48.000000000 -0400
+++ Linux/include/linux/fs.h	2007-06-22 13:10:30.000000000 -0400
@@ -523,9 +523,12 @@ struct address_space {
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
 	struct backing_dev_info *backing_dev_info; /* device readahead, etc */
+
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+
+	struct shared_policy	*spolicy;
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-06-22 13:07:48.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-06-22 13:10:30.000000000 -0400
@@ -30,12 +30,12 @@
 
 #include <linux/mmzone.h>
 #include <linux/slab.h>
-#include <linux/rbtree.h>
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
 
 struct vm_area_struct;
 struct mm_struct;
+#include <linux/shared_policy.h>
 
 #ifdef CONFIG_NUMA
 
@@ -113,34 +113,6 @@ static inline int mpol_equal(struct memp
 
 #define mpol_set_vma_default(vma) ((vma)->vm_policy = NULL)
 
-/*
- * Tree of shared policies for a shared memory region.
- * Maintain the policies in a pseudo mm that contains vmas. The vmas
- * carry the policy. As a special twist the pseudo mm is indexed in pages, not
- * bytes, so that we can work with shared memory segments bigger than
- * unsigned long.
- */
-
-struct sp_node {
-	struct rb_node nd;
-	unsigned long start, end;
-	struct mempolicy *policy;
-};
-
-struct shared_policy {
-	struct rb_root root;
-	spinlock_t lock;
-};
-
-void mpol_shared_policy_init(struct shared_policy *info, int policy,
-				nodemask_t *nodes);
-int mpol_set_shared_policy(struct shared_policy *info,
-				struct vm_area_struct *vma,
-				struct mempolicy *new);
-void mpol_free_shared_policy(struct shared_policy *p);
-struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
-					    unsigned long idx);
-
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *new);
@@ -192,30 +164,6 @@ static inline struct mempolicy *mpol_cop
 	return NULL;
 }
 
-struct shared_policy {};
-
-static inline int mpol_set_shared_policy(struct shared_policy *info,
-					struct vm_area_struct *vma,
-					struct mempolicy *new)
-{
-	return -EINVAL;
-}
-
-static inline void mpol_shared_policy_init(struct shared_policy *info,
-					int policy, nodemask_t *nodes)
-{
-}
-
-static inline void mpol_free_shared_policy(struct shared_policy *p)
-{
-}
-
-static inline struct mempolicy *
-mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
-{
-	return NULL;
-}
-
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
 
Index: Linux/include/linux/shared_policy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ Linux/include/linux/shared_policy.h	2007-06-22 13:10:30.000000000 -0400
@@ -0,0 +1,64 @@
+#ifndef _LINUX_SHARED_POLICY_H
+#define _LINUX_SHARED_POLICY_H 1
+
+#include <linux/rbtree.h>
+
+/*
+ * Tree of shared policies for a shared memory regions and memory
+ * mapped files.
+TODO:  wean the low level shared policies from the notion of vmas.
+       just use inode, offset, length
+ * Maintain the policies in a pseudo mm that contains vmas. The vmas
+ * carry the policy. As a special twist the pseudo mm is indexed in pages, not
+ * bytes, so that we can work with shared memory segments bigger than
+ * unsigned long.
+ */
+
+#ifdef CONFIG_NUMA
+
+struct sp_node {
+	struct rb_node nd;
+	unsigned long start, end;
+	struct mempolicy *policy;
+};
+
+struct shared_policy {
+	struct rb_root root;
+	spinlock_t lock;	/* protects rb tree */
+};
+
+void mpol_shared_policy_init(struct shared_policy *, int, nodemask_t *);
+int mpol_set_shared_policy(struct shared_policy *,
+				struct vm_area_struct *,
+				struct mempolicy *);
+void mpol_free_shared_policy(struct shared_policy *);
+struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
+					    unsigned long);
+
+#else /* !NUMA */
+
+struct shared_policy {};
+
+static inline int mpol_set_shared_policy(struct shared_policy *info,
+					struct vm_area_struct *vma,
+					struct mempolicy *new)
+{
+	return -EINVAL;
+}
+static inline void mpol_shared_policy_init(struct shared_policy *info,
+					int policy, nodemask_t *nodes)
+{
+}
+
+static inline void mpol_free_shared_policy(struct shared_policy *p)
+{
+}
+
+static inline struct mempolicy *
+mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
+{
+	return NULL;
+}
+#endif
+
+#endif /* _LINUX_SHARED_POLICY_H */
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-22 13:07:48.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-22 13:10:30.000000000 -0400
@@ -1446,7 +1446,7 @@ mpol_shared_policy_lookup(struct shared_
 	struct mempolicy *pol = NULL;
 	struct sp_node *sn;
 
-	if (!sp->root.rb_node)
+	if (!sp || !sp->root.rb_node)
 		return NULL;
 	spin_lock(&sp->lock);
 	sn = sp_lookup(sp, idx, idx+1);
@@ -1528,11 +1528,12 @@ restart:
 	return 0;
 }
 
-void mpol_shared_policy_init(struct shared_policy *info, int policy,
+void mpol_shared_policy_init(struct shared_policy *sp, int policy,
 				nodemask_t *policy_nodes)
 {
-	info->root = RB_ROOT;
-	spin_lock_init(&info->lock);
+
+	sp->root = RB_ROOT;
+	spin_lock_init(&sp->lock);
 
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
@@ -1546,13 +1547,13 @@ void mpol_shared_policy_init(struct shar
 			memset(&pvma, 0, sizeof(struct vm_area_struct));
 			/* Policy covers entire file */
 			pvma.vm_end = TASK_SIZE;
-			mpol_set_shared_policy(info, &pvma, newpol);
+			mpol_set_shared_policy(sp, &pvma, newpol);
 			mpol_free(newpol);
 		}
 	}
 }
 
-int mpol_set_shared_policy(struct shared_policy *info,
+int mpol_set_shared_policy(struct shared_policy *sp,
 			struct vm_area_struct *vma, struct mempolicy *npol)
 {
 	int err;
@@ -1569,30 +1570,30 @@ int mpol_set_shared_policy(struct shared
 		if (!new)
 			return -ENOMEM;
 	}
-	err = shared_policy_replace(info, vma->vm_pgoff, vma->vm_pgoff+sz, new);
+	err = shared_policy_replace(sp, vma->vm_pgoff, vma->vm_pgoff+sz, new);
 	if (err && new)
 		kmem_cache_free(sn_cache, new);
 	return err;
 }
 
 /* Free a backing policy store on inode delete. */
-void mpol_free_shared_policy(struct shared_policy *p)
+void mpol_free_shared_policy(struct shared_policy *sp)
 {
 	struct sp_node *n;
 	struct rb_node *next;
 
-	if (!p->root.rb_node)
+	if (!sp->root.rb_node)
 		return;
-	spin_lock(&p->lock);
-	next = rb_first(&p->root);
+	spin_lock(&sp->lock);
+	next = rb_first(&sp->root);
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
-		rb_erase(&n->nd, &p->root);
+		rb_erase(&n->nd, &sp->root);
 		mpol_free(n->policy);
 		kmem_cache_free(sn_cache, n);
 	}
-	spin_unlock(&p->lock);
+	spin_unlock(&sp->lock);
 }
 
 int mpol_parse_options(char *value, int *policy, nodemask_t *policy_nodes)
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-06-22 13:07:48.000000000 -0400
+++ Linux/mm/shmem.c	2007-06-22 13:10:30.000000000 -0400
@@ -962,7 +962,7 @@ redirty:
 }
 
 #ifdef CONFIG_NUMA
-static struct page *shmem_swapin_async(struct shared_policy *p,
+static struct page *shmem_swapin_async(struct shared_policy *sp,
 				       swp_entry_t entry, unsigned long idx)
 {
 	struct page *page;
@@ -972,41 +972,39 @@ static struct page *shmem_swapin_async(s
 	memset(&pvma, 0, sizeof(struct vm_area_struct));
 	pvma.vm_end = PAGE_SIZE;
 	pvma.vm_pgoff = idx;
-	pvma.vm_policy = mpol_shared_policy_lookup(p, idx);
+	pvma.vm_policy = mpol_shared_policy_lookup(sp, idx);
 	page = read_swap_cache_async(entry, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
 
-struct page *shmem_swapin(struct shmem_inode_info *info, swp_entry_t entry,
-			  unsigned long idx)
+struct page *shmem_swapin(struct shared_policy *sp, swp_entry_t entry,
+				unsigned long idx)
 {
-	struct shared_policy *p = &info->policy;
 	int i, num;
 	struct page *page;
 	unsigned long offset;
 
 	num = valid_swaphandles(entry, &offset);
 	for (i = 0; i < num; offset++, i++) {
-		page = shmem_swapin_async(p,
+		page = shmem_swapin_async(sp,
 				swp_entry(swp_type(entry), offset), idx);
 		if (!page)
 			break;
 		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
-	return shmem_swapin_async(p, entry, idx);
+	return shmem_swapin_async(sp, entry, idx);
 }
 
 static struct page *
-shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
-		 unsigned long idx)
+shmem_alloc_page(gfp_t gfp, struct shared_policy *sp, unsigned long idx)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
 
 	memset(&pvma, 0, sizeof(struct vm_area_struct));
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	pvma.vm_policy = mpol_shared_policy_lookup(sp, idx);
 	pvma.vm_pgoff = idx;
 	pvma.vm_end = PAGE_SIZE;
 	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
@@ -1015,14 +1013,14 @@ shmem_alloc_page(gfp_t gfp, struct shmem
 }
 #else
 static inline struct page *
-shmem_swapin(struct shmem_inode_info *info,swp_entry_t entry,unsigned long idx)
+shmem_swapin(void *sp, swp_entry_t entry, unsigned long idx)
 {
 	swapin_readahead(entry, 0, NULL);
 	return read_swap_cache_async(entry, NULL, 0);
 }
 
 static inline struct page *
-shmem_alloc_page(gfp_t gfp,struct shmem_inode_info *info, unsigned long idx)
+shmem_alloc_page(gfp_t gfp, void *sp, unsigned long idx)
 {
 	return alloc_page(gfp | __GFP_ZERO);
 }
@@ -1091,7 +1089,7 @@ repeat:
 				*type = VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
-			swappage = shmem_swapin(info, swap, idx);
+			swappage = shmem_swapin(mapping->spolicy, swap, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
@@ -1204,7 +1202,7 @@ repeat:
 		if (!filepage) {
 			spin_unlock(&info->lock);
 			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
-						    info,
+						    mapping->spolicy,
 						    idx);
 			if (!filepage) {
 				shmem_unacct_blocks(info->flags, 1);
@@ -1370,8 +1368,9 @@ shmem_get_inode(struct super_block *sb, 
 		case S_IFREG:
 			inode->i_op = &shmem_inode_operations;
 			inode->i_fop = &shmem_file_operations;
-			mpol_shared_policy_init(&info->policy, sbinfo->policy,
-							&sbinfo->policy_nodes);
+			inode->i_mapping->spolicy = &info->policy;
+			mpol_shared_policy_init(inode->i_mapping->spolicy,
+					 sbinfo->policy, &sbinfo->policy_nodes);
 			break;
 		case S_IFDIR:
 			inc_nlink(inode);
@@ -1385,8 +1384,9 @@ shmem_get_inode(struct super_block *sb, 
 			 * Must not load anything in the rbtree,
 			 * mpol_free_shared_policy will not be called.
 			 */
-			mpol_shared_policy_init(&info->policy, MPOL_DEFAULT,
-						NULL);
+			inode->i_mapping->spolicy = &info->policy;
+			mpol_shared_policy_init(inode->i_mapping->spolicy,
+					 MPOL_DEFAULT, NULL);
 			break;
 		}
 	} else if (sbinfo->max_inodes) {
@@ -2287,7 +2287,7 @@ static void shmem_destroy_inode(struct i
 {
 	if ((inode->i_mode & S_IFMT) == S_IFREG) {
 		/* only struct inode is valid if it's an inline symlink */
-		mpol_free_shared_policy(&SHMEM_I(inode)->policy);
+		mpol_free_shared_policy(inode->i_mapping->spolicy);
 	}
 	shmem_acl_destroy_inode(inode);
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
Index: Linux/fs/hugetlbfs/inode.c
===================================================================
--- Linux.orig/fs/hugetlbfs/inode.c	2007-06-22 13:07:48.000000000 -0400
+++ Linux/fs/hugetlbfs/inode.c	2007-06-22 13:10:30.000000000 -0400
@@ -364,7 +364,9 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
+		inode->i_mapping->spolicy = &info->policy;
+		mpol_shared_policy_init(inode->i_mapping->spolicy,
+					 MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
