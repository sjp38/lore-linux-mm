From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH 2/2] Updating ctime and mtime at syncing
Date: Tue, 15 Jan 2008 19:02:45 +0300
Message-Id: <1200412978699-git-send-email-salikhmetov@gmail.com>
In-Reply-To: <12004129652397-git-send-email-salikhmetov@gmail.com>
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

Changes for updating the ctime and mtime fields for memory-mapped files:

1) new flag triggering update of the inode data;
2) new field in the address_space structure for saving modification time;
3) new function to update ctime and mtime for block device files;
4) new helper function to update ctime and mtime when needed;
5) updating time stamps for mapped files in sys_msync() and do_fsync();
6) implementing the feature of auto-updating ctime and mtime;
7) account for the case of retouching an already-dirtied page.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
---
 fs/buffer.c             |    3 ++
 fs/fs-writeback.c       |    2 +
 fs/inode.c              |   53 ++++++++++++++++++++++++++++++++++-----------
 fs/sync.c               |    2 +
 include/linux/fs.h      |   13 ++++++++++-
 include/linux/pagemap.h |    3 +-
 mm/mmap.c               |    3 ++
 mm/msync.c              |   29 ++++++++++++++++--------
 mm/page-writeback.c     |   54 +++++++++++++++++++++++++---------------------
 9 files changed, 112 insertions(+), 50 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7249e01..3967aa7 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -701,6 +701,9 @@ static int __set_page_dirty(struct page *page,
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
+	mapping->mtime = CURRENT_TIME;
+	set_bit(AS_MCTIME, &mapping->flags);
+
 	if (TestSetPageDirty(page))
 		return 0;
 
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 300324b..affd291 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -243,6 +243,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
 
 	spin_unlock(&inode_lock);
 
+	mapping_update_time(mapping);
+
 	ret = do_writepages(mapping, wbc);
 
 	/* Don't write the inode if only I_DIRTY_PAGES was set */
diff --git a/fs/inode.c b/fs/inode.c
index ed35383..5997046 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1243,8 +1243,9 @@ void touch_atime(struct vfsmount *mnt, struct dentry *dentry)
 EXPORT_SYMBOL(touch_atime);
 
 /**
- *	file_update_time	-	update mtime and ctime time
- *	@file: file accessed
+ *	inode_update_time	-	update mtime and ctime time
+ *	@inode: inode accessed
+ *	@ts: time when inode was accessed
  *
  *	Update the mtime and ctime members of an inode and mark the inode
  *	for writeback.  Note that this function is meant exclusively for
@@ -1253,11 +1254,8 @@ EXPORT_SYMBOL(touch_atime);
  *	S_NOCTIME inode flag, e.g. for network filesystem where these
  *	timestamps are handled by the server.
  */
-
-void file_update_time(struct file *file)
+void inode_update_time(struct inode *inode, struct timespec *ts)
 {
-	struct inode *inode = file->f_path.dentry->d_inode;
-	struct timespec now;
 	int sync_it = 0;
 
 	if (IS_NOCMTIME(inode))
@@ -1265,22 +1263,52 @@ void file_update_time(struct file *file)
 	if (IS_RDONLY(inode))
 		return;
 
-	now = current_fs_time(inode->i_sb);
-	if (!timespec_equal(&inode->i_mtime, &now)) {
-		inode->i_mtime = now;
+	if (timespec_compare(&inode->i_mtime, ts) < 0) {
+		inode->i_mtime = *ts;
 		sync_it = 1;
 	}
 
-	if (!timespec_equal(&inode->i_ctime, &now)) {
-		inode->i_ctime = now;
+	if (timespec_compare(&inode->i_ctime, ts) < 0) {
+		inode->i_ctime = *ts;
 		sync_it = 1;
 	}
 
 	if (sync_it)
 		mark_inode_dirty_sync(inode);
 }
+EXPORT_SYMBOL(inode_update_time);
+
+/*
+ * Update the ctime and mtime stamps for memory-mapped block device files.
+ */
+static void bd_inode_update_time(struct inode *inode, struct timespec *ts)
+{
+	struct block_device *bdev = inode->i_bdev;
+	struct list_head *p;
+
+	if (bdev == NULL)
+		return;
+
+	mutex_lock(&bdev->bd_mutex);
+	list_for_each(p, &bdev->bd_inodes) {
+		inode = list_entry(p, struct inode, i_devices);
+		inode_update_time(inode, ts);
+	}
+	mutex_unlock(&bdev->bd_mutex);
+}
 
-EXPORT_SYMBOL(file_update_time);
+/*
+ * Update the ctime and mtime stamps after checking if they are to be updated.
+ */
+void mapping_update_time(struct address_space *mapping)
+{
+	if (test_and_clear_bit(AS_MCTIME, &mapping->flags)) {
+		if (S_ISBLK(mapping->host->i_mode))
+			bd_inode_update_time(mapping->host, &mapping->mtime);
+		else
+			inode_update_time(mapping->host, &mapping->mtime);
+	}
+}
 
 int inode_needs_sync(struct inode *inode)
 {
@@ -1290,7 +1318,6 @@ int inode_needs_sync(struct inode *inode)
 		return 1;
 	return 0;
 }
-
 EXPORT_SYMBOL(inode_needs_sync);
 
 int inode_wait(void *word)
diff --git a/fs/sync.c b/fs/sync.c
index 7cd005e..5561464 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -87,6 +87,8 @@ long do_fsync(struct file *file, int datasync)
 		goto out;
 	}
 
+	mapping_update_time(mapping);
+
 	ret = filemap_fdatawrite(mapping);
 
 	/*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b3ec4a4..f0d3ced 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -511,6 +511,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+	struct timespec		mtime;		/* modification time */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -1977,7 +1978,17 @@ extern int buffer_migrate_page(struct address_space *,
 extern int inode_change_ok(struct inode *, struct iattr *);
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
-extern void file_update_time(struct file *file);
+extern void inode_update_time(struct inode *, struct timespec *);
+
+static inline void file_update_time(struct file *file)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct timespec ts = current_fs_time(inode->i_sb);
+
+	inode_update_time(inode, &ts);
+}
+
+extern void mapping_update_time(struct address_space *);
 
 static inline ino_t parent_ino(struct dentry *dentry)
 {
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index db8a410..bf0f9e7 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -17,8 +17,9 @@
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
  * allocation mode flags.
  */
-#define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
+#define AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_MCTIME	(__GFP_BITS_SHIFT + 2)	/* mtime and ctime to update */
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index 15678aa..f659733 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -210,9 +210,12 @@ void unlink_file_vma(struct vm_area_struct *vma)
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
+
 		spin_lock(&mapping->i_mmap_lock);
 		__remove_shared_vm_struct(vma, file, mapping);
 		spin_unlock(&mapping->i_mmap_lock);
+
+		mapping_update_time(mapping);
 	}
 }
 
diff --git a/mm/msync.c b/mm/msync.c
index 3270caa..80ca1cc 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -5,6 +5,7 @@
  * Copyright (C) 1994-1999  Linus Torvalds
  *
  * Massive code cleanup.
+ * Updating the ctime and mtime stamps for memory-mapped files.
  * Copyright (C) 2008 Anton Salikhmetov <salikhmetov@gmail.com>
  */
 
@@ -22,6 +23,10 @@
  * Nor does it mark the relevant pages dirty (it used to up to 2.6.17).
  * Now it doesn't do anything, since dirty pages are properly tracked.
  *
+ * The msync() system call updates the ctime and mtime fields for
+ * the mapped file when called with the MS_SYNC or MS_ASYNC flags
+ * according to the POSIX standard.
+ *
  * The application may now run fsync() to
  * write out the dirty pages and wait on the writeout and check the result.
  * Or the application may run fadvise(FADV_DONTNEED) against the fd to start
@@ -78,16 +83,20 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 		start = vma->vm_end;
 
 		file = vma->vm_file;
-		if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
-			get_file(file);
-			up_read(&mm->mmap_sem);
-			error = do_fsync(file, 0);
-			fput(file);
-			if (error)
-				return error;
-			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, start);
-			continue;
+		if (file && (vma->vm_flags & VM_SHARED)) {
+			if (flags & MS_ASYNC)
+				mapping_update_time(file->f_mapping);
+			if (flags & MS_SYNC) {
+				get_file(file);
+				up_read(&mm->mmap_sem);
+				error = do_fsync(file, 0);
+				fput(file);
+				if (error)
+					return error;
+				down_read(&mm->mmap_sem);
+				vma = find_vma(mm, start);
+				continue;
+			}
 		}
 
 		vma = vma->vm_next;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3d3848f..53d0e34 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -997,35 +997,39 @@ int __set_page_dirty_no_writeback(struct page *page)
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
-	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page_mapping(page);
-		struct address_space *mapping2;
+	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping2;
 
-		if (!mapping)
-			return 1;
+	if (!mapping)
+		return 1;
 
-		write_lock_irq(&mapping->tree_lock);
-		mapping2 = page_mapping(page);
-		if (mapping2) { /* Race with truncate? */
-			BUG_ON(mapping2 != mapping);
-			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
-			if (mapping_cap_account_dirty(mapping)) {
-				__inc_zone_page_state(page, NR_FILE_DIRTY);
-				__inc_bdi_stat(mapping->backing_dev_info,
-						BDI_RECLAIMABLE);
-				task_io_account_write(PAGE_CACHE_SIZE);
-			}
-			radix_tree_tag_set(&mapping->page_tree,
-				page_index(page), PAGECACHE_TAG_DIRTY);
-		}
-		write_unlock_irq(&mapping->tree_lock);
-		if (mapping->host) {
-			/* !PageAnon && !swapper_space */
-			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	mapping->mtime = CURRENT_TIME;
+	set_bit(AS_MCTIME, &mapping->flags);
+
+	if (TestSetPageDirty(page))
+		return 0;
+
+	write_lock_irq(&mapping->tree_lock);
+	mapping2 = page_mapping(page);
+	if (mapping2) {
+		/* Race with truncate? */
+		BUG_ON(mapping2 != mapping);
+		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
+		if (mapping_cap_account_dirty(mapping)) {
+			__inc_zone_page_state(page, NR_FILE_DIRTY);
+			__inc_bdi_stat(mapping->backing_dev_info,
+					BDI_RECLAIMABLE);
+			task_io_account_write(PAGE_CACHE_SIZE);
 		}
-		return 1;
+		radix_tree_tag_set(&mapping->page_tree,
+				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
-	return 0;
+	write_unlock_irq(&mapping->tree_lock);
+
+	if (mapping->host)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	return 1;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
