Date: Sun, 24 Jun 2007 03:46:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/3] block_dev: convert to fsblock
Message-ID: <20070624014654.GC17609@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert block_dev mostly to fsblocks.

---
 fs/block_dev.c              |  204 +++++++++++++++++++++++++++++++++++++++-----
 fs/buffer.c                 |  113 ++----------------------
 fs/super.c                  |    2 
 include/linux/buffer_head.h |    9 -
 include/linux/fs.h          |   29 ++++++
 5 files changed, 225 insertions(+), 132 deletions(-)

Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
@@ -16,7 +16,9 @@
 #include <linux/blkdev.h>
 #include <linux/module.h>
 #include <linux/blkpg.h>
+#include <linux/fsblock.h>
 #include <linux/buffer_head.h>
+#include <linux/pagevec.h>
 #include <linux/writeback.h>
 #include <linux/mpage.h>
 #include <linux/mount.h>
@@ -61,14 +63,14 @@ static void kill_bdev(struct block_devic
 {
 	if (bdev->bd_inode->i_mapping->nrpages == 0)
 		return;
-	invalidate_bh_lrus();
+	invalidate_bh_lrus(); /* XXX: this can go when buffers goes */
 	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
 }	
 
 int set_blocksize(struct block_device *bdev, int size)
 {
 	/* Size must be a power of two, and between 512 and PAGE_SIZE */
-	if (size > PAGE_SIZE || size < 512 || !is_power_of_2(size))
+	if (size < 512 || !is_power_of_2(size))
 		return -EINVAL;
 
 	/* Size cannot be smaller than the size supported by the device */
@@ -92,7 +94,7 @@ int sb_set_blocksize(struct super_block 
 	if (set_blocksize(sb->s_bdev, size))
 		return 0;
 	/* If we get here, we know size is power of two
-	 * and it's value is between 512 and PAGE_SIZE */
+	 * and it's value is >= 512 */
 	sb->s_blocksize = size;
 	sb->s_blocksize_bits = blksize_bits(size);
 	return sb->s_blocksize;
@@ -112,19 +114,12 @@ EXPORT_SYMBOL(sb_min_blocksize);
 
 static int
 blkdev_get_block(struct inode *inode, sector_t iblock,
-		struct buffer_head *bh, int create)
+                struct buffer_head *bh, int create)
 {
 	if (iblock >= max_block(I_BDEV(inode))) {
 		if (create)
 			return -EIO;
-
-		/*
-		 * for reads, we're just trying to fill a partial page.
-		 * return a hole, they will have to call get_block again
-		 * before they can fill it, and they will get -EIO at that
-		 * time
-		 */
-		return 0;
+                return 0;
 	}
 	bh->b_bdev = I_BDEV(inode);
 	bh->b_blocknr = iblock;
@@ -132,6 +127,66 @@ blkdev_get_block(struct inode *inode, se
 	return 0;
 }
 
+static int blkdev_insert_mapping(struct address_space *mapping, loff_t off,
+					size_t len, int create)
+{
+	sector_t blocknr;
+	struct inode *inode = mapping->host;
+	pgoff_t next, end;
+	struct pagevec pvec;
+	int ret = 0;
+
+	pagevec_init(&pvec, 0);
+	next = off >> PAGE_CACHE_SHIFT;
+	end = (off + len) >> PAGE_CACHE_SHIFT;
+	blocknr = off >> inode->i_blkbits;
+	while (next <= end && pagevec_lookup(&pvec, mapping, next,
+				min(end - next, (pgoff_t)PAGEVEC_SIZE))) {
+		unsigned int i;
+
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct fsblock *block;
+			struct page *page = pvec.pages[i];
+
+			BUG_ON(page->index != next);
+			BUG_ON(blocknr != pgoff_sector(next, inode->i_blkbits));
+			BUG_ON(!PageLocked(page));
+
+			if (blocknr >= max_block(I_BDEV(inode))) {
+				if (create)
+					ret = -ENOMEM;
+
+				/*
+				 * for reads, we're just trying to fill a
+				 * partial page.  return a hole, they will
+				 * have to call in again before they can fill
+				 * it, and they will get -EIO at that time
+				 */
+				continue; /* xxx: could be smarter, stop now */
+			}
+
+			block = page_blocks(page);
+			if (fsblock_subpage(block)) {
+				struct fsblock *b;
+				for_each_block(block, b) {
+					if (!test_bit(BL_mapped, &b->flags))
+						map_fsblock(b, blocknr);
+					blocknr++;
+				}
+			} else {
+				if (!test_bit(BL_mapped, &block->flags))
+					map_fsblock(block, blocknr);
+				blocknr++;
+			}
+			next++;
+		}
+		pagevec_release(&pvec);
+	}
+
+	return ret;
+}
+
+#if 0
 static int
 blkdev_get_blocks(struct inode *inode, sector_t iblock,
 		struct buffer_head *bh, int create)
@@ -170,6 +225,7 @@ blkdev_direct_IO(int rw, struct kiocb *i
 	return blockdev_direct_IO_no_locking(rw, iocb, inode, I_BDEV(inode),
 				iov, offset, nr_segs, blkdev_get_blocks, NULL);
 }
+#endif
 
 #if 0
 static int blk_end_aio(struct bio *bio, unsigned int bytes_done, int error)
@@ -368,24 +424,127 @@ backout:
 }
 #endif
 
+/*
+ * Write out and wait upon all the dirty data associated with a block
+ * device via its mapping.  Does not take the superblock lock.
+ */
+int sync_blockdev(struct block_device *bdev)
+{
+	int ret = 0;
+
+	if (bdev)
+		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
+	return ret;
+}
+EXPORT_SYMBOL(sync_blockdev);
+
+/*
+ * Write out and wait upon all dirty data associated with this
+ * device.   Filesystem data as well as the underlying block
+ * device.  Takes the superblock lock.
+ */
+int fsync_bdev(struct block_device *bdev)
+{
+	struct super_block *sb = get_super(bdev);
+	if (sb) {
+		int res = fsync_super(sb);
+		drop_super(sb);
+		return res;
+	}
+	return sync_blockdev(bdev);
+}
+
+/**
+ * freeze_bdev  --  lock a filesystem and force it into a consistent state
+ * @bdev:	blockdevice to lock
+ *
+ * This takes the block device bd_mount_mutex to make sure no new mounts
+ * happen on bdev until thaw_bdev() is called.
+ * If a superblock is found on this device, we take the s_umount semaphore
+ * on it to make sure nobody unmounts until the snapshot creation is done.
+ */
+struct super_block *freeze_bdev(struct block_device *bdev)
+{
+	struct super_block *sb;
+
+	down(&bdev->bd_mount_sem);
+	sb = get_super(bdev);
+	if (sb && !(sb->s_flags & MS_RDONLY)) {
+		sb->s_frozen = SB_FREEZE_WRITE;
+		smp_wmb();
+
+		__fsync_super(sb);
+
+		sb->s_frozen = SB_FREEZE_TRANS;
+		smp_wmb();
+
+		sync_blockdev(sb->s_bdev);
+
+		if (sb->s_op->write_super_lockfs)
+			sb->s_op->write_super_lockfs(sb);
+	}
+
+	sync_blockdev(bdev);
+	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
+}
+EXPORT_SYMBOL(freeze_bdev);
+
+/**
+ * thaw_bdev  -- unlock filesystem
+ * @bdev:	blockdevice to unlock
+ * @sb:		associated superblock
+ *
+ * Unlocks the filesystem and marks it writeable again after freeze_bdev().
+ */
+void thaw_bdev(struct block_device *bdev, struct super_block *sb)
+{
+	if (sb) {
+		BUG_ON(sb->s_bdev != bdev);
+
+		if (sb->s_op->unlockfs)
+			sb->s_op->unlockfs(sb);
+		sb->s_frozen = SB_UNFROZEN;
+		smp_wmb();
+		wake_up(&sb->s_wait_unfrozen);
+		drop_super(sb);
+	}
+
+	up(&bdev->bd_mount_sem);
+}
+EXPORT_SYMBOL(thaw_bdev);
+
 static int blkdev_writepage(struct page *page, struct writeback_control *wbc)
 {
-	return block_write_full_page(page, blkdev_get_block, wbc);
+	if (PagePrivate(page))
+		return block_write_full_page(page, blkdev_get_block, wbc);
+	return fsblock_write_page(page, blkdev_insert_mapping, wbc);
 }
 
 static int blkdev_readpage(struct file * file, struct page * page)
 {
-	return block_read_full_page(page, blkdev_get_block);
+	return fsblock_read_page(page, blkdev_insert_mapping);
 }
 
 static int blkdev_prepare_write(struct file *file, struct page *page, unsigned from, unsigned to)
 {
-	return block_prepare_write(page, from, to, blkdev_get_block);
+	if (PagePrivate(page))
+		return block_prepare_write(page, from, to, blkdev_get_block);
+	return fsblock_prepare_write(page, from, to, blkdev_insert_mapping);
 }
 
 static int blkdev_commit_write(struct file *file, struct page *page, unsigned from, unsigned to)
 {
-	return block_commit_write(page, from, to);
+	if (PagePrivate(page))
+		return generic_commit_write(file, page, from, to);
+	return fsblock_commit_write(file, page, from, to);
+}
+
+static void blkdev_invalidate_page(struct page *page, unsigned long offset)
+{
+	if (PagePrivate(page))
+		block_invalidatepage(page, offset);
+	else
+		fsblock_invalidate_page(page, offset);
 }
 
 /*
@@ -840,7 +999,7 @@ static void free_bd_holder(struct bd_hol
 /**
  * find_bd_holder - find matching struct bd_holder from the block device
  *
- * @bdev:	struct block device to be searched
+ * @bdev:	struct fsblock device to be searched
  * @bo:		target struct bd_holder
  *
  * Returns matching entry with @bo in @bdev->bd_holder_list.
@@ -1272,6 +1431,10 @@ static int __blkdev_put(struct block_dev
 		bdev->bd_part_count--;
 
 	if (!--bdev->bd_openers) {
+		/*
+		 * XXX: This could go away when block dev and inode
+		 * mappings are in sync?
+		 */
 		sync_blockdev(bdev);
 		kill_bdev(bdev);
 	}
@@ -1325,11 +1488,14 @@ static long block_ioctl(struct file *fil
 const struct address_space_operations def_blk_aops = {
 	.readpage	= blkdev_readpage,
 	.writepage	= blkdev_writepage,
-	.sync_page	= block_sync_page,
+//	.sync_page	= block_sync_page, /* xxx: gone w/ explicit plugging */
 	.prepare_write	= blkdev_prepare_write,
 	.commit_write	= blkdev_commit_write,
 	.writepages	= generic_writepages,
-	.direct_IO	= blkdev_direct_IO,
+//	.direct_IO	= blkdev_direct_IO,
+	.set_page_dirty	= fsblock_set_page_dirty,
+	.invalidatepage = blkdev_invalidate_page,
+	/* XXX: .sync */
 };
 
 const struct file_operations def_blk_fops = {
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -147,95 +147,6 @@ void end_buffer_write_sync(struct buffer
 }
 
 /*
- * Write out and wait upon all the dirty data associated with a block
- * device via its mapping.  Does not take the superblock lock.
- */
-int sync_blockdev(struct block_device *bdev)
-{
-	int ret = 0;
-
-	if (bdev)
-		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
-	return ret;
-}
-EXPORT_SYMBOL(sync_blockdev);
-
-/*
- * Write out and wait upon all dirty data associated with this
- * device.   Filesystem data as well as the underlying block
- * device.  Takes the superblock lock.
- */
-int fsync_bdev(struct block_device *bdev)
-{
-	struct super_block *sb = get_super(bdev);
-	if (sb) {
-		int res = fsync_super(sb);
-		drop_super(sb);
-		return res;
-	}
-	return sync_blockdev(bdev);
-}
-
-/**
- * freeze_bdev  --  lock a filesystem and force it into a consistent state
- * @bdev:	blockdevice to lock
- *
- * This takes the block device bd_mount_sem to make sure no new mounts
- * happen on bdev until thaw_bdev() is called.
- * If a superblock is found on this device, we take the s_umount semaphore
- * on it to make sure nobody unmounts until the snapshot creation is done.
- */
-struct super_block *freeze_bdev(struct block_device *bdev)
-{
-	struct super_block *sb;
-
-	down(&bdev->bd_mount_sem);
-	sb = get_super(bdev);
-	if (sb && !(sb->s_flags & MS_RDONLY)) {
-		sb->s_frozen = SB_FREEZE_WRITE;
-		smp_wmb();
-
-		__fsync_super(sb);
-
-		sb->s_frozen = SB_FREEZE_TRANS;
-		smp_wmb();
-
-		sync_blockdev(sb->s_bdev);
-
-		if (sb->s_op->write_super_lockfs)
-			sb->s_op->write_super_lockfs(sb);
-	}
-
-	sync_blockdev(bdev);
-	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
-}
-EXPORT_SYMBOL(freeze_bdev);
-
-/**
- * thaw_bdev  -- unlock filesystem
- * @bdev:	blockdevice to unlock
- * @sb:		associated superblock
- *
- * Unlocks the filesystem and marks it writeable again after freeze_bdev().
- */
-void thaw_bdev(struct block_device *bdev, struct super_block *sb)
-{
-	if (sb) {
-		BUG_ON(sb->s_bdev != bdev);
-
-		if (sb->s_op->unlockfs)
-			sb->s_op->unlockfs(sb);
-		sb->s_frozen = SB_UNFROZEN;
-		smp_wmb();
-		wake_up(&sb->s_wait_unfrozen);
-		drop_super(sb);
-	}
-
-	up(&bdev->bd_mount_sem);
-}
-EXPORT_SYMBOL(thaw_bdev);
-
-/*
  * Various filesystems appear to want __find_get_block to be non-blocking.
  * But it's the page lock which protects the buffers.  To get around this,
  * we get exclusion from try_to_free_buffers with the blockdev mapping's
@@ -574,11 +485,6 @@ static inline void __remove_assoc_queue(
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
@@ -818,8 +724,9 @@ static int fsync_buffers_list(spinlock_t
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
 
@@ -838,10 +745,10 @@ void invalidate_inode_buffers(struct ino
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
 
@@ -990,7 +897,7 @@ grow_dev_page(struct block_device *bdev,
 	BUG_ON(!PageLocked(page));
 
 	if (PageBlocks(page)) {
-		if (try_to_free_blocks(page))
+		if (!try_to_free_blocks(page))
 			return NULL;
 	}
 
@@ -1603,7 +1510,7 @@ static int __block_write_full_page(struc
 
 	if (!page_has_buffers(page)) {
 		if (PageBlocks(page)) {
-			if (try_to_free_blocks(page))
+			if (!try_to_free_blocks(page))
 				return -EBUSY;
 		}
 		create_empty_buffers(page, blocksize,
@@ -1769,7 +1676,7 @@ static int __block_prepare_write(struct 
 	blocksize = 1 << inode->i_blkbits;
 	if (!page_has_buffers(page)) {
 		if (PageBlocks(page)) {
-			if (try_to_free_blocks(page))
+			if (!try_to_free_blocks(page))
 				return -EBUSY;
 		}
 		create_empty_buffers(page, blocksize, 0);
@@ -1928,7 +1835,7 @@ int block_read_full_page(struct page *pa
 	blocksize = 1 << inode->i_blkbits;
 	if (!page_has_buffers(page)) {
 		if (PageBlocks(page)) {
-			if (try_to_free_blocks(page))
+			if (!try_to_free_blocks(page))
 				return -EBUSY;
 		}
 		create_empty_buffers(page, blocksize, 0);
@@ -2497,7 +2404,7 @@ int block_truncate_page(struct address_s
 
 	if (!page_has_buffers(page)) {
 		if (PageBlocks(page)) {
-			if (try_to_free_blocks(page))
+			if (!try_to_free_blocks(page))
 				return -EBUSY;
 		}
 		create_empty_buffers(page, blocksize, 0);
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
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -158,22 +158,14 @@ void end_buffer_write_sync(struct buffer
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
-int inode_has_buffers(struct inode *);
 void invalidate_inode_buffers(struct inode *);
 int remove_inode_buffers(struct inode *inode);
 int sync_mapping_buffers(struct address_space *mapping);
 void unmap_underlying_metadata(struct block_device *bdev, sector_t block);
 
 void mark_buffer_async_write(struct buffer_head *bh);
-void invalidate_bdev(struct block_device *);
-int sync_blockdev(struct block_device *bdev);
 void __wait_on_buffer(struct buffer_head *);
 wait_queue_head_t *bh_waitq_head(struct buffer_head *bh);
-int fsync_bdev(struct block_device *);
-struct super_block *freeze_bdev(struct block_device *);
-void thaw_bdev(struct block_device *, struct super_block *);
-int fsync_super(struct super_block *);
-int fsync_no_super(struct block_device *);
 struct buffer_head *__find_get_block(struct block_device *bdev, sector_t block,
 			unsigned size);
 struct buffer_head *__getblk(struct block_device *bdev, sector_t block,
@@ -317,7 +309,6 @@ extern int __set_page_dirty_buffers(stru
 static inline void buffer_init(void) {}
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int sync_blockdev(struct block_device *bdev) { return 0; }
-static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -430,6 +430,20 @@ struct address_space_operations {
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
 	int (*launder_page) (struct page *);
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
 
 struct backing_dev_info;
@@ -497,6 +511,14 @@ struct block_device {
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
@@ -1503,6 +1525,13 @@ extern void bd_forget(struct inode *inod
 extern void bdput(struct block_device *);
 extern struct block_device *open_by_devnum(dev_t, unsigned);
 extern const struct address_space_operations def_blk_aops;
+void invalidate_bdev(struct block_device *);
+int sync_blockdev(struct block_device *bdev);
+struct super_block *freeze_bdev(struct block_device *);
+void thaw_bdev(struct block_device *, struct super_block *);
+int fsync_bdev(struct block_device *);
+int fsync_super(struct super_block *);
+int fsync_no_super(struct block_device *);
 #else
 static inline void bd_forget(struct inode *inode) {}
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
