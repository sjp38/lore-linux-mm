Message-Id: <200405222207.i4MM7rr13202@mail.osdl.org>
Subject: [patch 25/57] numa api: Add shared memory support
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:23 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Add support to tmpfs and hugetlbfs to support NUMA API.  Shared memory is a
bit of a special case for NUMA policy.  Normally policy is associated to VMAs
or to processes, but for a shared memory segment you really want to share the
policy.  The core NUMA API has code for that, this patch adds the necessary
changes to tmpfs and hugetlbfs.

First it changes the custom swapping code in tmpfs to follow the policy set
via VMAs.

It is also useful to have a "backing store" of policy that saves the policy
even when nobody has the shared memory segment mapped.  This allows command
line tools to pre configure policy, which is then later used by programs.

Note that hugetlbfs needs more changes - it is also required to switch it to
lazy allocation, otherwise the prefault prevents mbind() from working.


---

 25-akpm/fs/hugetlbfs/inode.c     |   46 ++++++++++++++++-
 25-akpm/include/linux/hugetlb.h  |   13 ++++
 25-akpm/include/linux/shmem_fs.h |    2 
 25-akpm/ipc/shm.c                |    4 +
 25-akpm/mm/shmem.c               |  105 +++++++++++++++++++++++++++++++++++++--
 5 files changed, 165 insertions(+), 5 deletions(-)

diff -puN fs/hugetlbfs/inode.c~numa-api-shared-memory-support fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~numa-api-shared-memory-support	2004-05-22 14:56:25.532210040 -0700
+++ 25-akpm/fs/hugetlbfs/inode.c	2004-05-22 14:59:39.591708512 -0700
@@ -377,6 +377,7 @@ static struct inode *hugetlbfs_get_inode
 
 	inode = new_inode(sb);
 	if (inode) {
+		struct hugetlbfs_inode_info *info;
 		inode->i_mode = mode;
 		inode->i_uid = uid;
 		inode->i_gid = gid;
@@ -385,6 +386,8 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		info = HUGETLBFS_I(inode);
+		mpol_shared_policy_init(&info->policy);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -512,6 +515,33 @@ static void hugetlbfs_put_super(struct s
 	}
 }
 
+static kmem_cache_t *hugetlbfs_inode_cachep;
+
+static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
+{
+	struct hugetlbfs_inode_info *p;
+
+	p = kmem_cache_alloc(hugetlbfs_inode_cachep, SLAB_KERNEL);
+	if (!p)
+		return NULL;
+	return &p->vfs_inode;
+}
+
+static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+{
+	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
+
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
+	    SLAB_CTOR_CONSTRUCTOR)
+		inode_init_once(&ei->vfs_inode);
+}
+
+static void hugetlbfs_destroy_inode(struct inode *inode)
+{
+	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
+}
+
 static struct address_space_operations hugetlbfs_aops = {
 	.readpage	= hugetlbfs_readpage,
 	.prepare_write	= hugetlbfs_prepare_write,
@@ -543,6 +573,8 @@ static struct inode_operations hugetlbfs
 };
 
 static struct super_operations hugetlbfs_ops = {
+	.alloc_inode    = hugetlbfs_alloc_inode,
+	.destroy_inode  = hugetlbfs_destroy_inode,
 	.statfs		= hugetlbfs_statfs,
 	.drop_inode	= hugetlbfs_drop_inode,
 	.put_super	= hugetlbfs_put_super,
@@ -763,9 +795,16 @@ static int __init init_hugetlbfs_fs(void
 	int error;
 	struct vfsmount *vfsmount;
 
+	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
+					sizeof(struct hugetlbfs_inode_info),
+					0, SLAB_RECLAIM_ACCOUNT,
+					init_once, NULL);
+	if (hugetlbfs_inode_cachep == NULL)
+		return -ENOMEM;
+
 	error = register_filesystem(&hugetlbfs_fs_type);
 	if (error)
-		return error;
+		goto out;
 
 	vfsmount = kern_mount(&hugetlbfs_fs_type);
 
@@ -775,11 +814,16 @@ static int __init init_hugetlbfs_fs(void
 	}
 
 	error = PTR_ERR(vfsmount);
+
+ out:
+	if (error)
+		kmem_cache_destroy(hugetlbfs_inode_cachep);
 	return error;
 }
 
 static void __exit exit_hugetlbfs_fs(void)
 {
+	kmem_cache_destroy(hugetlbfs_inode_cachep);
 	unregister_filesystem(&hugetlbfs_fs_type);
 }
 
diff -puN include/linux/hugetlb.h~numa-api-shared-memory-support include/linux/hugetlb.h
--- 25/include/linux/hugetlb.h~numa-api-shared-memory-support	2004-05-22 14:56:25.533209888 -0700
+++ 25-akpm/include/linux/hugetlb.h	2004-05-22 14:56:25.542208520 -0700
@@ -3,6 +3,8 @@
 
 #ifdef CONFIG_HUGETLB_PAGE
 
+#include <linux/mempolicy.h>
+
 struct ctl_table;
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
@@ -104,6 +106,17 @@ struct hugetlbfs_sb_info {
 	spinlock_t	stat_lock;
 };
 
+
+struct hugetlbfs_inode_info {
+	struct shared_policy policy;
+	struct inode vfs_inode;
+};
+
+static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+{
+	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+}
+
 static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 {
 	return sb->s_fs_info;
diff -puN include/linux/shmem_fs.h~numa-api-shared-memory-support include/linux/shmem_fs.h
--- 25/include/linux/shmem_fs.h~numa-api-shared-memory-support	2004-05-22 14:56:25.535209584 -0700
+++ 25-akpm/include/linux/shmem_fs.h	2004-05-22 14:56:25.543208368 -0700
@@ -2,6 +2,7 @@
 #define __SHMEM_FS_H
 
 #include <linux/swap.h>
+#include <linux/mempolicy.h>
 
 /* inode in-kernel data */
 
@@ -15,6 +16,7 @@ struct shmem_inode_info {
 	unsigned long		alloced;    /* data pages allocated to file */
 	unsigned long		swapped;    /* subtotal assigned to swap */
 	unsigned long		flags;
+	struct shared_policy     policy;
 	struct list_head	list;
 	struct inode		vfs_inode;
 };
diff -puN ipc/shm.c~numa-api-shared-memory-support ipc/shm.c
--- 25/ipc/shm.c~numa-api-shared-memory-support	2004-05-22 14:56:25.536209432 -0700
+++ 25-akpm/ipc/shm.c	2004-05-22 14:56:25.543208368 -0700
@@ -163,6 +163,10 @@ static struct vm_operations_struct shm_v
 	.open	= shm_open,	/* callback for a new vm-area open */
 	.close	= shm_close,	/* callback for when the vm-area is released */
 	.nopage	= shmem_nopage,
+#ifdef CONFIG_NUMA
+	.set_policy = shmem_set_policy,
+	.get_policy = shmem_get_policy,
+#endif
 };
 
 static int newseg (key_t key, int shmflg, size_t size)
diff -puN mm/shmem.c~numa-api-shared-memory-support mm/shmem.c
--- 25/mm/shmem.c~numa-api-shared-memory-support	2004-05-22 14:56:25.538209128 -0700
+++ 25-akpm/mm/shmem.c	2004-05-22 14:59:40.413583568 -0700
@@ -8,6 +8,7 @@
  *		 2002 Red Hat Inc.
  * Copyright (C) 2002-2003 Hugh Dickins.
  * Copyright (C) 2002-2003 VERITAS Software Corporation.
+ * Copyright (C) 2004 Andi Kleen, SuSE Labs
  *
  * This file is released under the GPL.
  */
@@ -37,8 +38,10 @@
 #include <linux/vfs.h>
 #include <linux/blkdev.h>
 #include <linux/security.h>
+#include <linux/swapops.h>
 #include <asm/uaccess.h>
 #include <asm/div64.h>
+#include <asm/pgtable.h>
 
 /* This magic number is used in glibc for posix shared memory */
 #define TMPFS_MAGIC	0x01021994
@@ -783,6 +786,74 @@ redirty:
 	return WRITEPAGE_ACTIVATE;	/* Return with the page locked */
 }
 
+#ifdef CONFIG_NUMA
+static struct page *shmem_swapin_async(struct shared_policy *p,
+				       swp_entry_t entry, unsigned long idx)
+{
+	struct page *page;
+	struct vm_area_struct pvma;
+
+	/* Create a pseudo vma that just contains the policy */
+	memset(&pvma, 0, sizeof(struct vm_area_struct));
+	pvma.vm_end = PAGE_SIZE;
+	pvma.vm_pgoff = idx;
+	pvma.vm_policy = mpol_shared_policy_lookup(p, idx);
+	page = read_swap_cache_async(entry, &pvma, 0);
+	mpol_free(pvma.vm_policy);
+	return page;
+}
+
+struct page *shmem_swapin(struct shmem_inode_info *info, swp_entry_t entry,
+			  unsigned long idx)
+{
+	struct shared_policy *p = &info->policy;
+	int i, num;
+	struct page *page;
+	unsigned long offset;
+
+	num = valid_swaphandles(entry, &offset);
+	for (i = 0; i < num; offset++, i++) {
+		page = shmem_swapin_async(p,
+				swp_entry(swp_type(entry), offset), idx);
+		if (!page)
+			break;
+		page_cache_release(page);
+	}
+	lru_add_drain();	/* Push any new pages onto the LRU now */
+	return shmem_swapin_async(p, entry, idx);
+}
+
+static struct page *
+shmem_alloc_page(unsigned long gfp, struct shmem_inode_info *info,
+		 unsigned long idx)
+{
+	struct vm_area_struct pvma;
+	struct page *page;
+
+	memset(&pvma, 0, sizeof(struct vm_area_struct));
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	pvma.vm_pgoff = idx;
+	pvma.vm_end = PAGE_SIZE;
+	page = alloc_page_vma(gfp, &pvma, 0);
+	mpol_free(pvma.vm_policy);
+	return page;
+}
+#else
+static inline struct page *
+shmem_swapin(struct shmem_inode_info *info,swp_entry_t entry,unsigned long idx)
+{
+	swapin_readahead(entry, 0, NULL);
+	return read_swap_cache_async(entry, NULL, 0);
+}
+
+static inline struct page *
+shmem_alloc_page(unsigned long gfp,struct shmem_inode_info *info,
+				 unsigned long idx)
+{
+	return alloc_page(gfp);
+}
+#endif
+
 /*
  * shmem_getpage - either get the page from swap or allocate a new one
  *
@@ -790,7 +861,8 @@ redirty:
  * vm. If we swap it in we mark it dirty since we also free the swap
  * entry since a page cannot live in both the swap and page cache
  */
-static int shmem_getpage(struct inode *inode, unsigned long idx, struct page **pagep, enum sgp_type sgp, int *type)
+static int shmem_getpage(struct inode *inode, unsigned long idx,
+			struct page **pagep, enum sgp_type sgp, int *type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -840,8 +912,7 @@ repeat:
 			if (majmin == VM_FAULT_MINOR && type)
 				inc_page_state(pgmajfault);
 			majmin = VM_FAULT_MAJOR;
-			swapin_readahead(swap);
-			swappage = read_swap_cache_async(swap);
+			swappage = shmem_swapin(info, swap, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
@@ -946,7 +1017,9 @@ repeat:
 
 		if (!filepage) {
 			spin_unlock(&info->lock);
-			filepage = page_cache_alloc(mapping);
+			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
+						    info,
+						    idx);
 			if (!filepage) {
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_block(inode);
@@ -1069,6 +1142,24 @@ static int shmem_populate(struct vm_area
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
+{
+	struct inode *i = vma->vm_file->f_dentry->d_inode;
+	return mpol_set_shared_policy(&SHMEM_I(i)->policy, vma, new);
+}
+
+struct mempolicy *
+shmem_get_policy(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct inode *i = vma->vm_file->f_dentry->d_inode;
+	unsigned long idx;
+
+	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx);
+}
+#endif
+
 void shmem_lock(struct file *file, int lock)
 {
 	struct inode *inode = file->f_dentry->d_inode;
@@ -1117,6 +1208,7 @@ shmem_get_inode(struct super_block *sb, 
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
+ 		mpol_shared_policy_init(&info->policy);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -1792,6 +1884,7 @@ static struct inode *shmem_alloc_inode(s
 
 static void shmem_destroy_inode(struct inode *inode)
 {
+	mpol_free_shared_policy(&SHMEM_I(inode)->policy);
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
@@ -1876,6 +1969,10 @@ static struct super_operations shmem_ops
 static struct vm_operations_struct shmem_vm_ops = {
 	.nopage		= shmem_nopage,
 	.populate	= shmem_populate,
+#ifdef CONFIG_NUMA
+	.set_policy     = shmem_set_policy,
+	.get_policy     = shmem_get_policy,
+#endif
 };
 
 static struct super_block *shmem_get_sb(struct file_system_type *fs_type,

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
