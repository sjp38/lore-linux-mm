Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57A4B6B00E3
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 05:48:43 -0500 (EST)
Date: Wed, 25 Feb 2009 11:48:39 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] mm: new address space calls
Message-ID: <20090225104839.GG22785@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is about the last change to generic code I need for fsblock.
Comments?

Introduce new address space operations sync and release, which can be used
by a filesystem to synchronize and release per-address_space private metadata.
They generalise sync_mapping_buffers, invalidate_inode_buffers, and
remove_inode_buffers calls, and get another step closer to divorcing
buffer heads from core mm/fs code.

---
 fs/block_dev.c              |    7 +++++++
 fs/buffer.c                 |   16 ++++++----------
 fs/fs-writeback.c           |   12 +++++++++---
 fs/inode.c                  |   37 +++++++++++++++++++++++++++++--------
 fs/super.c                  |    3 ++-
 include/linux/buffer_head.h |    2 --
 include/linux/fs.h          |   22 ++++++++++++++++++++++
 mm/filemap.c                |    1 +
 8 files changed, 76 insertions(+), 24 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -454,7 +454,7 @@ EXPORT_SYMBOL(mark_buffer_async_write);
  * written back and waited upon before fsync() returns.
  *
  * The functions mark_buffer_inode_dirty(), fsync_inode_buffers(),
- * inode_has_buffers() and invalidate_inode_buffers() are provided for the
+ * mapping_has_private() and invalidate_inode_buffers() are provided for the
  * management of a list of dependent buffers at ->i_mapping->private_list.
  *
  * Locking is a little subtle: try_to_free_buffers() will remove buffers
@@ -507,11 +507,6 @@ static void __remove_assoc_queue(struct
 	bh->b_assoc_map = NULL;
 }
 
-int inode_has_buffers(struct inode *inode)
-{
-	return !list_empty(&inode->i_data.private_list);
-}
-
 /*
  * osync is designed to support O_SYNC io.  It waits synchronously for
  * all already-submitted IO to complete, but does not queue any new
@@ -787,8 +782,9 @@ static int fsync_buffers_list(spinlock_t
  */
 void invalidate_inode_buffers(struct inode *inode)
 {
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	struct address_space *mapping = &inode->i_data;
+
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
@@ -808,10 +804,10 @@ EXPORT_SYMBOL(invalidate_inode_buffers);
  */
 int remove_inode_buffers(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
 	int ret = 1;
 
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -158,7 +158,6 @@ void end_buffer_write_sync(struct buffer
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
-int inode_has_buffers(struct inode *);
 void invalidate_inode_buffers(struct inode *);
 int remove_inode_buffers(struct inode *inode);
 int sync_mapping_buffers(struct address_space *mapping);
@@ -333,7 +332,6 @@ extern int __set_page_dirty_buffers(stru
 static inline void buffer_init(void) {}
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int sync_blockdev(struct block_device *bdev) { return 0; }
-static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2476,6 +2476,7 @@ int try_to_release_page(struct page *pag
 	if (PageWriteback(page))
 		return 0;
 
+	BUG_ON(!PagePrivate(page));
 	if (mapping && mapping->a_ops->releasepage)
 		return mapping->a_ops->releasepage(page, gfp_mask);
 	return try_to_free_buffers(page);
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -782,9 +782,15 @@ int generic_osync_inode(struct inode *in
 	if (what & OSYNC_DATA)
 		err = filemap_fdatawrite(mapping);
 	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
-		err2 = sync_mapping_buffers(mapping);
-		if (!err)
-			err = err2;
+		if (!mapping->a_ops->sync) {
+			err2 = sync_mapping_buffers(mapping);
+			if (!err)
+				err = err2;
+		} else {
+			err2 = mapping->a_ops->sync(mapping);
+			if (!err)
+				err = err2;
+		}
 	}
 	if (what & OSYNC_DATA) {
 		err2 = filemap_fdatawait(mapping);
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -208,7 +208,8 @@ static struct inode *alloc_inode(struct
 
 void destroy_inode(struct inode *inode) 
 {
-	BUG_ON(inode_has_buffers(inode));
+	BUG_ON(mapping_has_private(&inode->i_data));
+	BUG_ON(inode->i_data.nrpages);
 	security_inode_free(inode);
 	if (inode->i_sb->s_op->destroy_inode)
 		inode->i_sb->s_op->destroy_inode(inode);
@@ -277,10 +278,14 @@ void __iget(struct inode * inode)
  */
 void clear_inode(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	might_sleep();
-	invalidate_inode_buffers(inode);
+	if (!mapping->a_ops->release)
+		invalidate_inode_buffers(inode);
        
-	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(mapping_has_private(mapping));
+	BUG_ON(mapping->nrpages);
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
 	inode_sync_wait(inode);
@@ -343,6 +348,7 @@ static int invalidate_list(struct list_h
 	for (;;) {
 		struct list_head * tmp = next;
 		struct inode * inode;
+		struct address_space * mapping;
 
 		/*
 		 * We can reschedule here without worrying about the list's
@@ -356,7 +362,12 @@ static int invalidate_list(struct list_h
 		if (tmp == head)
 			break;
 		inode = list_entry(tmp, struct inode, i_sb_list);
-		invalidate_inode_buffers(inode);
+		mapping = &inode->i_data;
+		if (!mapping->a_ops->release)
+			invalidate_inode_buffers(inode);
+		else
+			mapping->a_ops->release(mapping, 1); /* XXX: should be done in fs? */
+		BUG_ON(mapping_has_private(mapping));
 		if (!atomic_read(&inode->i_count)) {
 			list_move(&inode->i_list, dispose);
 			inode->i_state |= I_FREEING;
@@ -399,13 +410,15 @@ EXPORT_SYMBOL(invalidate_inodes);
 
 static int can_unuse(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	if (inode->i_state)
 		return 0;
-	if (inode_has_buffers(inode))
+	if (mapping_has_private(mapping))
 		return 0;
 	if (atomic_read(&inode->i_count))
 		return 0;
-	if (inode->i_data.nrpages)
+	if (mapping->nrpages)
 		return 0;
 	return 1;
 }
@@ -434,6 +447,7 @@ static void prune_icache(int nr_to_scan)
 	spin_lock(&inode_lock);
 	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
 		struct inode *inode;
+		struct address_space *mapping;
 
 		if (list_empty(&inode_unused))
 			break;
@@ -444,10 +458,17 @@ static void prune_icache(int nr_to_scan)
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
-		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		mapping = &inode->i_data;
+		if (mapping_has_private(mapping) || mapping->nrpages) {
+			int ret;
+
 			__iget(inode);
 			spin_unlock(&inode_lock);
-			if (remove_inode_buffers(inode))
+			if (mapping->a_ops->release)
+				ret = mapping->a_ops->release(mapping, 0);
+			else
+				ret = remove_inode_buffers(inode);
+			if (ret)
 				reap += invalidate_mapping_pages(&inode->i_data,
 								0, -1);
 			iput(inode);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -531,6 +531,20 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+
+	/*
+	 * release_mapping releases any private data on the mapping so that
+	 * it may be reclaimed. Returns 1 on success or 0 on failure. Second
+	 * parameter 'force' causes dirty data to be invalidated. (XXX: could
+	 * have other flags like sync/async, etc).
+	 */
+	int (*release)(struct address_space *, int);
+
+	/*
+	 * sync writes back and waits for any private data on the mapping,
+	 * as a data consistency operation.
+	 */
+	int (*sync)(struct address_space *);
 };
 
 /*
@@ -616,6 +630,14 @@ struct block_device {
 int mapping_tagged(struct address_space *mapping, int tag);
 
 /*
+ * Does this mapping have anything on its private list?
+ */
+static inline int mapping_has_private(struct address_space *mapping)
+{
+	return !list_empty(&mapping->private_list);
+}
+
+/*
  * Might pages of this file be mapped into userspace?
  */
 static inline int mapping_mapped(struct address_space *mapping)
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
@@ -352,6 +352,11 @@ static int blkdev_write_end(struct file
 	return ret;
 }
 
+static void blkdev_invalidate_page(struct page *page, unsigned long offset)
+{
+	block_invalidatepage(page, offset);
+}
+
 /*
  * private llseek:
  * for a block special file file->f_path.dentry->d_inode->i_size is zero
@@ -1405,6 +1410,8 @@ static const struct address_space_operat
 	.writepages	= generic_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
+	.set_page_dirty	= __set_page_dirty_buffers,
+	.invalidatepage = blkdev_invalidate_page,
 };
 
 const struct file_operations def_blk_fops = {
Index: linux-2.6/fs/super.c
===================================================================
--- linux-2.6.orig/fs/super.c
+++ linux-2.6/fs/super.c
@@ -28,7 +28,7 @@
 #include <linux/blkdev.h>
 #include <linux/quotaops.h>
 #include <linux/namei.h>
-#include <linux/buffer_head.h>		/* for fsync_super() */
+#include <linux/fs.h>			/* for fsync_super() */
 #include <linux/mount.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
@@ -38,6 +38,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/buffer_head.h>		/* sync_blockdev */
 #include <linux/async.h>
 #include <asm/uaccess.h>
 #include "internal.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
