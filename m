Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD536B0083
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:48:31 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p5EAmQ2h016523
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:48:26 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by kpbe17.cbf.corp.google.com with ESMTP id p5EAmO8i027467
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:48:24 -0700
Received: by pwi6 with SMTP id 6so2917557pwi.32
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:48:24 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:48:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/12] tmpfs: miscellaneous trivial cleanups
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106140345080.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

While it's at its least, make a number of boring nitpicky cleanups to
shmem.c, mostly for consistency of variable naming.  Things like "swap"
instead of "entry", "pgoff_t index" instead of "unsigned long idx".

And since everything else here is prefixed "shmem_",
better change init_tmpfs() to shmem_init().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/shmem_fs.h |    2 
 init/main.c              |    2 
 mm/shmem.c               |  216 ++++++++++++++++++-------------------
 3 files changed, 109 insertions(+), 111 deletions(-)

--- linux.orig/include/linux/shmem_fs.h	2011-06-13 13:27:59.634657055 -0700
+++ linux/include/linux/shmem_fs.h	2011-06-13 13:28:25.822786909 -0700
@@ -47,7 +47,7 @@ static inline struct shmem_inode_info *S
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
-extern int init_tmpfs(void);
+extern int shmem_init(void);
 extern int shmem_fill_super(struct super_block *sb, void *data, int silent);
 extern struct file *shmem_file_setup(const char *name,
 					loff_t size, unsigned long flags);
--- linux.orig/init/main.c	2011-06-13 13:26:07.386100444 -0700
+++ linux/init/main.c	2011-06-13 13:28:25.822786909 -0700
@@ -714,7 +714,7 @@ static void __init do_basic_setup(void)
 {
 	cpuset_init_smp();
 	usermodehelper_init();
-	init_tmpfs();
+	shmem_init();
 	driver_init();
 	init_irq_proc();
 	do_ctors();
--- linux.orig/mm/shmem.c	2011-06-13 13:27:59.634657055 -0700
+++ linux/mm/shmem.c	2011-06-13 13:28:25.822786909 -0700
@@ -28,7 +28,6 @@
 #include <linux/file.h>
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/percpu_counter.h>
 #include <linux/swap.h>
 
 static struct vfsmount *shm_mnt;
@@ -51,6 +50,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/shmem_fs.h>
 #include <linux/writeback.h>
 #include <linux/blkdev.h>
+#include <linux/percpu_counter.h>
 #include <linux/splice.h>
 #include <linux/security.h>
 #include <linux/swapops.h>
@@ -63,7 +63,6 @@ static struct vfsmount *shm_mnt;
 #include <linux/magic.h>
 
 #include <asm/uaccess.h>
-#include <asm/div64.h>
 #include <asm/pgtable.h>
 
 #define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
@@ -201,7 +200,7 @@ static void shmem_free_inode(struct supe
 }
 
 /**
- * shmem_recalc_inode - recalculate the size of an inode
+ * shmem_recalc_inode - recalculate the block usage of an inode
  * @inode: inode to recalc
  *
  * We have to calculate the free blocks since the mm can drop
@@ -356,19 +355,20 @@ static void shmem_evict_inode(struct ino
 	end_writeback(inode);
 }
 
-static int shmem_unuse_inode(struct shmem_inode_info *info, swp_entry_t entry, struct page *page)
+static int shmem_unuse_inode(struct shmem_inode_info *info,
+			     swp_entry_t swap, struct page *page)
 {
 	struct address_space *mapping = info->vfs_inode.i_mapping;
-	unsigned long idx;
+	pgoff_t index;
 	int error;
 
-	for (idx = 0; idx < SHMEM_NR_DIRECT; idx++)
-		if (shmem_get_swap(info, idx).val == entry.val)
+	for (index = 0; index < SHMEM_NR_DIRECT; index++)
+		if (shmem_get_swap(info, index).val == swap.val)
 			goto found;
 	return 0;
 found:
 	spin_lock(&info->lock);
-	if (shmem_get_swap(info, idx).val != entry.val) {
+	if (shmem_get_swap(info, index).val != swap.val) {
 		spin_unlock(&info->lock);
 		return 0;
 	}
@@ -387,15 +387,15 @@ found:
 	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
 	 * beneath us (pagelock doesn't help until the page is in pagecache).
 	 */
-	error = add_to_page_cache_locked(page, mapping, idx, GFP_NOWAIT);
+	error = add_to_page_cache_locked(page, mapping, index, GFP_NOWAIT);
 	/* which does mem_cgroup_uncharge_cache_page on error */
 
 	if (error != -ENOMEM) {
 		delete_from_swap_cache(page);
 		set_page_dirty(page);
-		shmem_put_swap(info, idx, (swp_entry_t){0});
+		shmem_put_swap(info, index, (swp_entry_t){0});
 		info->swapped--;
-		swap_free(entry);
+		swap_free(swap);
 		error = 1;	/* not an error, but entry was found */
 	}
 	spin_unlock(&info->lock);
@@ -405,9 +405,9 @@ found:
 /*
  * shmem_unuse() search for an eventually swapped out shmem page.
  */
-int shmem_unuse(swp_entry_t entry, struct page *page)
+int shmem_unuse(swp_entry_t swap, struct page *page)
 {
-	struct list_head *p, *next;
+	struct list_head *this, *next;
 	struct shmem_inode_info *info;
 	int found = 0;
 	int error;
@@ -432,8 +432,8 @@ int shmem_unuse(swp_entry_t entry, struc
 	radix_tree_preload_end();
 
 	mutex_lock(&shmem_swaplist_mutex);
-	list_for_each_safe(p, next, &shmem_swaplist) {
-		info = list_entry(p, struct shmem_inode_info, swaplist);
+	list_for_each_safe(this, next, &shmem_swaplist) {
+		info = list_entry(this, struct shmem_inode_info, swaplist);
 		if (!info->swapped) {
 			spin_lock(&info->lock);
 			if (!info->swapped)
@@ -441,7 +441,7 @@ int shmem_unuse(swp_entry_t entry, struc
 			spin_unlock(&info->lock);
 		}
 		if (info->swapped)
-			found = shmem_unuse_inode(info, entry, page);
+			found = shmem_unuse_inode(info, swap, page);
 		cond_resched();
 		if (found)
 			break;
@@ -467,7 +467,7 @@ static int shmem_writepage(struct page *
 	struct shmem_inode_info *info;
 	swp_entry_t swap, oswap;
 	struct address_space *mapping;
-	unsigned long index;
+	pgoff_t index;
 	struct inode *inode;
 
 	BUG_ON(!PageLocked(page));
@@ -577,35 +577,33 @@ static struct mempolicy *shmem_get_sbmpo
 }
 #endif /* CONFIG_TMPFS */
 
-static struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
+			struct shmem_inode_info *info, pgoff_t index)
 {
 	struct mempolicy mpol, *spol;
 	struct vm_area_struct pvma;
-	struct page *page;
 
 	spol = mpol_cond_copy(&mpol,
-				mpol_shared_policy_lookup(&info->policy, idx));
+			mpol_shared_policy_lookup(&info->policy, index));
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
-	pvma.vm_pgoff = idx;
+	pvma.vm_pgoff = index;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
-	page = swapin_readahead(entry, gfp, &pvma, 0);
-	return page;
+	return swapin_readahead(swap, gfp, &pvma, 0);
 }
 
 static struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+			struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
-	pvma.vm_pgoff = idx;
+	pvma.vm_pgoff = index;
 	pvma.vm_ops = NULL;
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
 	/*
 	 * alloc_page_vma() will drop the shared policy reference
@@ -614,19 +612,19 @@ static struct page *shmem_alloc_page(gfp
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *p)
+static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 }
 #endif /* CONFIG_TMPFS */
 
-static inline struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+static inline struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
+			struct shmem_inode_info *info, pgoff_t index)
 {
-	return swapin_readahead(entry, gfp, NULL, 0);
+	return swapin_readahead(swap, gfp, NULL, 0);
 }
 
 static inline struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+			struct shmem_inode_info *info, pgoff_t index)
 {
 	return alloc_page(gfp);
 }
@@ -646,7 +644,7 @@ static inline struct mempolicy *shmem_ge
  * vm. If we swap it in we mark it dirty since we also free the swap
  * entry since a page cannot live in both the swap and page cache
  */
-static int shmem_getpage_gfp(struct inode *inode, pgoff_t idx,
+static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
@@ -657,10 +655,10 @@ static int shmem_getpage_gfp(struct inod
 	swp_entry_t swap;
 	int error;
 
-	if (idx > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
+	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
 repeat:
-	page = find_lock_page(mapping, idx);
+	page = find_lock_page(mapping, index);
 	if (page) {
 		/*
 		 * Once we can get the page lock, it must be uptodate:
@@ -681,7 +679,7 @@ repeat:
 	radix_tree_preload_end();
 
 	if (sgp != SGP_READ && !prealloc_page) {
-		prealloc_page = shmem_alloc_page(gfp, info, idx);
+		prealloc_page = shmem_alloc_page(gfp, info, index);
 		if (prealloc_page) {
 			SetPageSwapBacked(prealloc_page);
 			if (mem_cgroup_cache_charge(prealloc_page,
@@ -694,7 +692,7 @@ repeat:
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
-	swap = shmem_get_swap(info, idx);
+	swap = shmem_get_swap(info, index);
 	if (swap.val) {
 		/* Look it up and read it in.. */
 		page = lookup_swap_cache(swap);
@@ -703,9 +701,9 @@ repeat:
 			/* here we actually do the io */
 			if (fault_type)
 				*fault_type |= VM_FAULT_MAJOR;
-			page = shmem_swapin(swap, gfp, info, idx);
+			page = shmem_swapin(swap, gfp, info, index);
 			if (!page) {
-				swp_entry_t nswap = shmem_get_swap(info, idx);
+				swp_entry_t nswap = shmem_get_swap(info, index);
 				if (nswap.val == swap.val) {
 					error = -ENOMEM;
 					goto out;
@@ -740,7 +738,7 @@ repeat:
 		}
 
 		error = add_to_page_cache_locked(page, mapping,
-						 idx, GFP_NOWAIT);
+						 index, GFP_NOWAIT);
 		if (error) {
 			spin_unlock(&info->lock);
 			if (error == -ENOMEM) {
@@ -762,14 +760,14 @@ repeat:
 		}
 
 		delete_from_swap_cache(page);
-		shmem_put_swap(info, idx, (swp_entry_t){0});
+		shmem_put_swap(info, index, (swp_entry_t){0});
 		info->swapped--;
 		spin_unlock(&info->lock);
 		set_page_dirty(page);
 		swap_free(swap);
 
 	} else if (sgp == SGP_READ) {
-		page = find_get_page(mapping, idx);
+		page = find_get_page(mapping, index);
 		if (page && !trylock_page(page)) {
 			spin_unlock(&info->lock);
 			wait_on_page_locked(page);
@@ -793,12 +791,12 @@ repeat:
 		page = prealloc_page;
 		prealloc_page = NULL;
 
-		swap = shmem_get_swap(info, idx);
+		swap = shmem_get_swap(info, index);
 		if (swap.val)
 			mem_cgroup_uncharge_cache_page(page);
 		else
 			error = add_to_page_cache_lru(page, mapping,
-						idx, GFP_NOWAIT);
+						index, GFP_NOWAIT);
 		/*
 		 * At add_to_page_cache_lru() failure,
 		 * uncharge will be done automatically.
@@ -841,7 +839,7 @@ nospace:
 	 * but must also avoid reporting a spurious ENOSPC while working on a
 	 * full tmpfs.
 	 */
-	page = find_get_page(mapping, idx);
+	page = find_get_page(mapping, index);
 	spin_unlock(&info->lock);
 	if (page) {
 		page_cache_release(page);
@@ -872,20 +870,20 @@ static int shmem_fault(struct vm_area_st
 }
 
 #ifdef CONFIG_NUMA
-static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
+static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *mpol)
 {
-	struct inode *i = vma->vm_file->f_path.dentry->d_inode;
-	return mpol_set_shared_policy(&SHMEM_I(i)->policy, vma, new);
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	return mpol_set_shared_policy(&SHMEM_I(inode)->policy, vma, mpol);
 }
 
 static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 					  unsigned long addr)
 {
-	struct inode *i = vma->vm_file->f_path.dentry->d_inode;
-	unsigned long idx;
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	pgoff_t index;
 
-	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx);
+	index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy, index);
 }
 #endif
 
@@ -1016,7 +1014,8 @@ static void do_shmem_file_read(struct fi
 {
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct address_space *mapping = inode->i_mapping;
-	unsigned long index, offset;
+	pgoff_t index;
+	unsigned long offset;
 	enum sgp_type sgp = SGP_READ;
 
 	/*
@@ -1032,7 +1031,8 @@ static void do_shmem_file_read(struct fi
 
 	for (;;) {
 		struct page *page = NULL;
-		unsigned long end_index, nr, ret;
+		pgoff_t end_index;
+		unsigned long nr, ret;
 		loff_t i_size = i_size_read(inode);
 
 		end_index = i_size >> PAGE_CACHE_SHIFT;
@@ -1270,8 +1270,9 @@ static int shmem_statfs(struct dentry *d
 	buf->f_namelen = NAME_MAX;
 	if (sbinfo->max_blocks) {
 		buf->f_blocks = sbinfo->max_blocks;
-		buf->f_bavail = buf->f_bfree =
-				sbinfo->max_blocks - percpu_counter_sum(&sbinfo->used_blocks);
+		buf->f_bavail =
+		buf->f_bfree  = sbinfo->max_blocks -
+				percpu_counter_sum(&sbinfo->used_blocks);
 	}
 	if (sbinfo->max_inodes) {
 		buf->f_files = sbinfo->max_inodes;
@@ -1480,8 +1481,8 @@ static void *shmem_follow_link_inline(st
 static void *shmem_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct page *page = NULL;
-	int res = shmem_getpage(dentry->d_inode, 0, &page, SGP_READ, NULL);
-	nd_set_link(nd, res ? ERR_PTR(res) : kmap(page));
+	int error = shmem_getpage(dentry->d_inode, 0, &page, SGP_READ, NULL);
+	nd_set_link(nd, error ? ERR_PTR(error) : kmap(page));
 	if (page)
 		unlock_page(page);
 	return page;
@@ -1592,7 +1593,6 @@ out:
 	return err;
 }
 
-
 static const struct xattr_handler *shmem_xattr_handlers[] = {
 #ifdef CONFIG_TMPFS_POSIX_ACL
 	&generic_acl_access_handler,
@@ -2052,14 +2052,14 @@ static struct kmem_cache *shmem_inode_ca
 
 static struct inode *shmem_alloc_inode(struct super_block *sb)
 {
-	struct shmem_inode_info *p;
-	p = (struct shmem_inode_info *)kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
-	if (!p)
+	struct shmem_inode_info *info;
+	info = kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
+	if (!info)
 		return NULL;
-	return &p->vfs_inode;
+	return &info->vfs_inode;
 }
 
-static void shmem_i_callback(struct rcu_head *head)
+static void shmem_destroy_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
 	INIT_LIST_HEAD(&inode->i_dentry);
@@ -2072,25 +2072,24 @@ static void shmem_destroy_inode(struct i
 		/* only struct inode is valid if it's an inline symlink */
 		mpol_free_shared_policy(&SHMEM_I(inode)->policy);
 	}
-	call_rcu(&inode->i_rcu, shmem_i_callback);
+	call_rcu(&inode->i_rcu, shmem_destroy_callback);
 }
 
-static void init_once(void *foo)
+static void shmem_init_inode(void *foo)
 {
-	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
-
-	inode_init_once(&p->vfs_inode);
+	struct shmem_inode_info *info = foo;
+	inode_init_once(&info->vfs_inode);
 }
 
-static int init_inodecache(void)
+static int shmem_init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
 				sizeof(struct shmem_inode_info),
-				0, SLAB_PANIC, init_once);
+				0, SLAB_PANIC, shmem_init_inode);
 	return 0;
 }
 
-static void destroy_inodecache(void)
+static void shmem_destroy_inodecache(void)
 {
 	kmem_cache_destroy(shmem_inode_cachep);
 }
@@ -2193,21 +2192,20 @@ static const struct vm_operations_struct
 #endif
 };
 
-
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
 	return mount_nodev(fs_type, flags, data, shmem_fill_super);
 }
 
-static struct file_system_type tmpfs_fs_type = {
+static struct file_system_type shmem_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "tmpfs",
 	.mount		= shmem_mount,
 	.kill_sb	= kill_litter_super,
 };
 
-int __init init_tmpfs(void)
+int __init shmem_init(void)
 {
 	int error;
 
@@ -2215,18 +2213,18 @@ int __init init_tmpfs(void)
 	if (error)
 		goto out4;
 
-	error = init_inodecache();
+	error = shmem_init_inodecache();
 	if (error)
 		goto out3;
 
-	error = register_filesystem(&tmpfs_fs_type);
+	error = register_filesystem(&shmem_fs_type);
 	if (error) {
 		printk(KERN_ERR "Could not register tmpfs\n");
 		goto out2;
 	}
 
-	shm_mnt = vfs_kern_mount(&tmpfs_fs_type, MS_NOUSER,
-				tmpfs_fs_type.name, NULL);
+	shm_mnt = vfs_kern_mount(&shmem_fs_type, MS_NOUSER,
+				 shmem_fs_type.name, NULL);
 	if (IS_ERR(shm_mnt)) {
 		error = PTR_ERR(shm_mnt);
 		printk(KERN_ERR "Could not kern_mount tmpfs\n");
@@ -2235,9 +2233,9 @@ int __init init_tmpfs(void)
 	return 0;
 
 out1:
-	unregister_filesystem(&tmpfs_fs_type);
+	unregister_filesystem(&shmem_fs_type);
 out2:
-	destroy_inodecache();
+	shmem_destroy_inodecache();
 out3:
 	bdi_destroy(&shmem_backing_dev_info);
 out4:
@@ -2247,37 +2245,37 @@ out4:
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /**
- * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
+ * mem_cgroup_get_shmem_target - find page or swap assigned to the shmem file
  * @inode: the inode to be searched
- * @pgoff: the offset to be searched
+ * @index: the page offset to be searched
  * @pagep: the pointer for the found page to be stored
- * @ent: the pointer for the found swap entry to be stored
+ * @swapp: the pointer for the found swap entry to be stored
  *
  * If a page is found, refcount of it is incremented. Callers should handle
  * these refcount.
  */
-void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
-					struct page **pagep, swp_entry_t *ent)
+void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t index,
+				 struct page **pagep, swp_entry_t *swapp)
 {
-	swp_entry_t entry = { .val = 0 };
-	struct page *page = NULL;
 	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct page *page = NULL;
+	swp_entry_t swap = {0};
 
-	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
+	if ((index << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		goto out;
 
 	spin_lock(&info->lock);
 #ifdef CONFIG_SWAP
-	entry = shmem_get_swap(info, pgoff);
-	if (entry.val)
-		page = find_get_page(&swapper_space, entry.val);
+	swap = shmem_get_swap(info, index);
+	if (swap.val)
+		page = find_get_page(&swapper_space, swap.val);
 	else
 #endif
-		page = find_get_page(inode->i_mapping, pgoff);
+		page = find_get_page(inode->i_mapping, index);
 	spin_unlock(&info->lock);
 out:
 	*pagep = page;
-	*ent = entry;
+	*swapp = swap;
 }
 #endif
 
@@ -2294,23 +2292,23 @@ out:
 
 #include <linux/ramfs.h>
 
-static struct file_system_type tmpfs_fs_type = {
+static struct file_system_type shmem_fs_type = {
 	.name		= "tmpfs",
 	.mount		= ramfs_mount,
 	.kill_sb	= kill_litter_super,
 };
 
-int __init init_tmpfs(void)
+int __init shmem_init(void)
 {
-	BUG_ON(register_filesystem(&tmpfs_fs_type) != 0);
+	BUG_ON(register_filesystem(&shmem_fs_type) != 0);
 
-	shm_mnt = kern_mount(&tmpfs_fs_type);
+	shm_mnt = kern_mount(&shmem_fs_type);
 	BUG_ON(IS_ERR(shm_mnt));
 
 	return 0;
 }
 
-int shmem_unuse(swp_entry_t entry, struct page *page)
+int shmem_unuse(swp_entry_t swap, struct page *page)
 {
 	return 0;
 }
@@ -2320,34 +2318,34 @@ int shmem_lock(struct file *file, int lo
 	return 0;
 }
 
-void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end)
+void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
-	truncate_inode_pages_range(inode->i_mapping, start, end);
+	truncate_inode_pages_range(inode->i_mapping, lstart, lend);
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /**
- * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
+ * mem_cgroup_get_shmem_target - find page or swap assigned to the shmem file
  * @inode: the inode to be searched
- * @pgoff: the offset to be searched
+ * @index: the page offset to be searched
  * @pagep: the pointer for the found page to be stored
- * @ent: the pointer for the found swap entry to be stored
+ * @swapp: the pointer for the found swap entry to be stored
  *
  * If a page is found, refcount of it is incremented. Callers should handle
  * these refcount.
  */
-void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
-					struct page **pagep, swp_entry_t *ent)
+void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t index,
+				 struct page **pagep, swp_entry_t *swapp)
 {
 	struct page *page = NULL;
 
-	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
+	if ((index << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		goto out;
-	page = find_get_page(inode->i_mapping, pgoff);
+	page = find_get_page(inode->i_mapping, index);
 out:
 	*pagep = page;
-	*ent = (swp_entry_t){ .val = 0 };
+	*swapp = (swp_entry_t){0};
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
