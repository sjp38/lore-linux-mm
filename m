Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4180E6B0083
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:56:29 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:56:28 -0700 (PDT)
Subject: [PATCH 03/16] mm/shmem: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:25 +0400
Message-ID: <20120321065625.13852.77078.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h       |    2 +-
 include/linux/shmem_fs.h |    5 ++--
 mm/shmem.c               |   54 +++++++++++++++++++++++++---------------------
 3 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 96f335c..be35c2f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -882,7 +882,7 @@ extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
 
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags);
+struct file *shmem_file_setup(const char *name, loff_t size, vm_flags_t);
 int shmem_zero_setup(struct vm_area_struct *);
 
 extern int can_do_mlock(void);
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 79ab255..db46104 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -10,7 +10,7 @@
 
 struct shmem_inode_info {
 	spinlock_t		lock;
-	unsigned long		flags;
+	vm_flags_t		vm_flags;
 	unsigned long		alloced;	/* data pages alloced to file */
 	union {
 		unsigned long	swapped;	/* subtotal assigned to swap */
@@ -44,8 +44,7 @@ static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
  */
 extern int shmem_init(void);
 extern int shmem_fill_super(struct super_block *sb, void *data, int silent);
-extern struct file *shmem_file_setup(const char *name,
-					loff_t size, unsigned long flags);
+extern struct file *shmem_file_setup(const char *name, loff_t size, vm_flags_t);
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern void shmem_unlock_mapping(struct address_space *mapping);
diff --git a/mm/shmem.c b/mm/shmem.c
index f99ff3e..38a3d7a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -124,15 +124,15 @@ static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
  * (unless MAP_NORESERVE and sysctl_overcommit_memory <= 1),
  * consistent with the pre-accounting of private mappings ...
  */
-static inline int shmem_acct_size(unsigned long flags, loff_t size)
+static inline int shmem_acct_size(vm_flags_t vm_flags, loff_t size)
 {
-	return (flags & VM_NORESERVE) ?
+	return (vm_flags & VM_NORESERVE) ?
 		0 : security_vm_enough_memory_mm(current->mm, VM_ACCT(size));
 }
 
-static inline void shmem_unacct_size(unsigned long flags, loff_t size)
+static inline void shmem_unacct_size(vm_flags_t vm_flags, loff_t size)
 {
-	if (!(flags & VM_NORESERVE))
+	if (!(vm_flags & VM_NORESERVE))
 		vm_unacct_memory(VM_ACCT(size));
 }
 
@@ -142,15 +142,15 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
-static inline int shmem_acct_block(unsigned long flags)
+static inline int shmem_acct_block(vm_flags_t vm_flags)
 {
-	return (flags & VM_NORESERVE) ?
+	return (vm_flags & VM_NORESERVE) ?
 		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
 }
 
-static inline void shmem_unacct_blocks(unsigned long flags, long pages)
+static inline void shmem_unacct_blocks(vm_flags_t vm_flags, long pages)
 {
-	if (flags & VM_NORESERVE)
+	if (vm_flags & VM_NORESERVE)
 		vm_unacct_memory(pages * VM_ACCT(PAGE_CACHE_SIZE));
 }
 
@@ -219,7 +219,7 @@ static void shmem_recalc_inode(struct inode *inode)
 			percpu_counter_add(&sbinfo->used_blocks, -freed);
 		info->alloced -= freed;
 		inode->i_blocks -= freed * BLOCKS_PER_PAGE;
-		shmem_unacct_blocks(info->flags, freed);
+		shmem_unacct_blocks(info->vm_flags, freed);
 	}
 }
 
@@ -580,7 +580,7 @@ static void shmem_evict_inode(struct inode *inode)
 	struct shmem_xattr *xattr, *nxattr;
 
 	if (inode->i_mapping->a_ops == &shmem_aops) {
-		shmem_unacct_size(info->flags, inode->i_size);
+		shmem_unacct_size(info->vm_flags, inode->i_size);
 		inode->i_size = 0;
 		shmem_truncate_range(inode, 0, (loff_t)-1);
 		if (!list_empty(&info->swaplist)) {
@@ -711,7 +711,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	index = page->index;
 	inode = mapping->host;
 	info = SHMEM_I(inode);
-	if (info->flags & VM_LOCKED)
+	if (info->vm_flags & VM_LOCKED)
 		goto redirty;
 	if (!total_swap_pages)
 		goto redirty;
@@ -956,7 +956,7 @@ repeat:
 		swap_free(swap);
 
 	} else {
-		if (shmem_acct_block(info->flags)) {
+		if (shmem_acct_block(info->vm_flags)) {
 			error = -ENOSPC;
 			goto failed;
 		}
@@ -1022,7 +1022,7 @@ decused:
 	if (sbinfo->max_blocks)
 		percpu_counter_add(&sbinfo->used_blocks, -1);
 unacct:
-	shmem_unacct_blocks(info->flags, 1);
+	shmem_unacct_blocks(info->vm_flags, 1);
 failed:
 	if (swap.val && error != -EINVAL) {
 		struct page *test = find_get_page(mapping, index);
@@ -1090,15 +1090,15 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 	int retval = -ENOMEM;
 
 	spin_lock(&info->lock);
-	if (lock && !(info->flags & VM_LOCKED)) {
+	if (lock && !(info->vm_flags & VM_LOCKED)) {
 		if (!user_shm_lock(inode->i_size, user))
 			goto out_nomem;
-		info->flags |= VM_LOCKED;
+		info->vm_flags |= VM_LOCKED;
 		mapping_set_unevictable(file->f_mapping);
 	}
-	if (!lock && (info->flags & VM_LOCKED) && user) {
+	if (!lock && (info->vm_flags & VM_LOCKED) && user) {
 		user_shm_unlock(inode->i_size, user);
-		info->flags &= ~VM_LOCKED;
+		info->vm_flags &= ~VM_LOCKED;
 		mapping_clear_unevictable(file->f_mapping);
 	}
 	retval = 0;
@@ -1116,8 +1116,9 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static struct inode *shmem_get_inode(struct super_block *sb, const struct inode *dir,
-				     umode_t mode, dev_t dev, unsigned long flags)
+static struct inode *
+shmem_get_inode(struct super_block *sb, const struct inode *dir,
+		umode_t mode, dev_t dev, vm_flags_t vm_flags)
 {
 	struct inode *inode;
 	struct shmem_inode_info *info;
@@ -1137,7 +1138,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
-		info->flags = flags & VM_NORESERVE;
+		info->vm_flags = vm_flags & VM_NORESERVE;
 		INIT_LIST_HEAD(&info->swaplist);
 		INIT_LIST_HEAD(&info->xattr_list);
 		cache_no_acl(inode);
@@ -2534,7 +2535,8 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
 #define shmem_vm_ops				generic_file_vm_ops
 #define shmem_file_operations			ramfs_file_operations
-#define shmem_get_inode(sb, dir, mode, dev, flags)	ramfs_get_inode(sb, dir, mode, dev)
+#define shmem_get_inode(sb, dir, mode, dev, vm_flags)	\
+	ramfs_get_inode(sb, dir, mode, dev)
 #define shmem_acct_size(flags, size)		0
 #define shmem_unacct_size(flags, size)		do {} while (0)
 
@@ -2548,7 +2550,8 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
  * @size: size to be set for the file
  * @flags: VM_NORESERVE suppresses pre-accounting of the entire object size
  */
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags)
+struct file *
+shmem_file_setup(const char *name, loff_t size, vm_flags_t vm_flags)
 {
 	int error;
 	struct file *file;
@@ -2563,7 +2566,7 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 	if (size < 0 || size > MAX_LFS_FILESIZE)
 		return ERR_PTR(-EINVAL);
 
-	if (shmem_acct_size(flags, size))
+	if (shmem_acct_size(vm_flags, size))
 		return ERR_PTR(-ENOMEM);
 
 	error = -ENOMEM;
@@ -2577,7 +2580,8 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 	path.mnt = mntget(shm_mnt);
 
 	error = -ENOSPC;
-	inode = shmem_get_inode(root->d_sb, NULL, S_IFREG | S_IRWXUGO, 0, flags);
+	inode = shmem_get_inode(root->d_sb, NULL, S_IFREG | S_IRWXUGO,
+				0, vm_flags);
 	if (!inode)
 		goto put_dentry;
 
@@ -2601,7 +2605,7 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 put_dentry:
 	path_put(&path);
 put_memory:
-	shmem_unacct_size(flags, size);
+	shmem_unacct_size(vm_flags, size);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
