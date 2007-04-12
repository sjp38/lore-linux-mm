Subject: [PATCH 1/2] mm: remove destroy_dirty_buffers from invalidate_bdev()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain; charset=utf-8
Date: Thu, 12 Apr 2007 17:21:15 +0200
Message-Id: <1176391275.4114.8.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhao Forrest <forrest.zhao@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Remove the destroy_dirty_buffers argument from invalidate_bdev(), it hasn't
been used in 6 years (so akpm says).

find * -name \*.[ch] | xargs grep -l invalidate_bdev | 
while read file; do 
	quilt add $file; 
	sed -ie 's/invalidate_bdev(\([^,]*\),[^)]*)/invalidate_bdev(\1)/g' $file;
done

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ioctl.c               |    4 ++--
 drivers/block/amiflop.c     |    2 +-
 drivers/block/loop.c        |    4 ++--
 drivers/block/rd.c          |    2 +-
 drivers/cdrom/cdrom.c       |    2 +-
 drivers/md/md.c             |    2 +-
 fs/block_dev.c              |    4 ++--
 fs/buffer.c                 |    7 +------
 fs/dquot.c                  |    4 ++--
 fs/ext3/super.c             |    4 ++--
 fs/ext4/super.c             |    4 ++--
 fs/partitions/acorn.c       |    2 +-
 include/linux/buffer_head.h |    4 ++--
 13 files changed, 20 insertions(+), 25 deletions(-)

Index: linux-2.6/block/ioctl.c
===================================================================
--- linux-2.6.orig/block/ioctl.c	2007-04-03 13:58:02.000000000 +0200
+++ linux-2.6/block/ioctl.c	2007-04-12 15:24:29.000000000 +0200
@@ -80,7 +80,7 @@ static int blkpg_ioctl(struct block_devi
 			}
 			/* all seems OK */
 			fsync_bdev(bdevp);
-			invalidate_bdev(bdevp, 0);
+			invalidate_bdev(bdevp);
 
 			mutex_lock_nested(&bdev->bd_mutex, 1);
 			delete_partition(disk, part);
@@ -236,7 +236,7 @@ int blkdev_ioctl(struct inode *inode, st
 
 		lock_kernel();
 		fsync_bdev(bdev);
-		invalidate_bdev(bdev, 0);
+		invalidate_bdev(bdev);
 		unlock_kernel();
 		return 0;
 
Index: linux-2.6/drivers/block/amiflop.c
===================================================================
--- linux-2.6.orig/drivers/block/amiflop.c	2007-02-01 15:07:20.000000000 +0100
+++ linux-2.6/drivers/block/amiflop.c	2007-04-12 15:24:58.000000000 +0200
@@ -1480,7 +1480,7 @@ static int fd_ioctl(struct inode *inode,
 		break;
 	case FDFMTEND:
 		floppy_off(drive);
-		invalidate_bdev(inode->i_bdev, 0);
+		invalidate_bdev(inode->i_bdev);
 		break;
 	case FDGETPRM:
 		memset((void *)&getprm, 0, sizeof (getprm));
Index: linux-2.6/drivers/block/loop.c
===================================================================
--- linux-2.6.orig/drivers/block/loop.c	2007-04-03 13:58:02.000000000 +0200
+++ linux-2.6/drivers/block/loop.c	2007-04-12 15:24:58.000000000 +0200
@@ -840,7 +840,7 @@ out_clr:
 	lo->lo_backing_file = NULL;
 	lo->lo_flags = 0;
 	set_capacity(lo->lo_disk, 0);
-	invalidate_bdev(bdev, 0);
+	invalidate_bdev(bdev);
 	bd_set_size(bdev, 0);
 	mapping_set_gfp_mask(mapping, lo->old_gfp_mask);
 	lo->lo_state = Lo_unbound;
@@ -924,7 +924,7 @@ static int loop_clr_fd(struct loop_devic
 	memset(lo->lo_encrypt_key, 0, LO_KEY_SIZE);
 	memset(lo->lo_crypt_name, 0, LO_NAME_SIZE);
 	memset(lo->lo_file_name, 0, LO_NAME_SIZE);
-	invalidate_bdev(bdev, 0);
+	invalidate_bdev(bdev);
 	set_capacity(lo->lo_disk, 0);
 	bd_set_size(bdev, 0);
 	mapping_set_gfp_mask(filp->f_mapping, gfp);
Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c	2007-04-12 14:05:54.000000000 +0200
+++ linux-2.6/drivers/block/rd.c	2007-04-12 15:24:58.000000000 +0200
@@ -403,7 +403,7 @@ static void __exit rd_cleanup(void)
 		struct block_device *bdev = rd_bdev[i];
 		rd_bdev[i] = NULL;
 		if (bdev) {
-			invalidate_bdev(bdev, 1);
+			invalidate_bdev(bdev);
 			blkdev_put(bdev);
 		}
 		del_gendisk(rd_disks[i]);
Index: linux-2.6/drivers/cdrom/cdrom.c
===================================================================
--- linux-2.6.orig/drivers/cdrom/cdrom.c	2007-04-03 13:58:02.000000000 +0200
+++ linux-2.6/drivers/cdrom/cdrom.c	2007-04-12 15:24:29.000000000 +0200
@@ -2384,7 +2384,7 @@ static int cdrom_ioctl_reset(struct cdro
 		return -EACCES;
 	if (!CDROM_CAN(CDC_RESET))
 		return -ENOSYS;
-	invalidate_bdev(bdev, 0);
+	invalidate_bdev(bdev);
 	return cdi->ops->reset(cdi);
 }
 
Index: linux-2.6/drivers/md/md.c
===================================================================
--- linux-2.6.orig/drivers/md/md.c	2007-04-03 13:58:06.000000000 +0200
+++ linux-2.6/drivers/md/md.c	2007-04-12 15:24:59.000000000 +0200
@@ -3080,7 +3080,7 @@ static int do_md_run(mddev_t * mddev)
 		if (test_bit(Faulty, &rdev->flags))
 			continue;
 		sync_blockdev(rdev->bdev);
-		invalidate_bdev(rdev->bdev, 0);
+		invalidate_bdev(rdev->bdev);
 	}
 
 	md_probe(mddev->unit, NULL, NULL);
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c	2007-04-03 13:58:16.000000000 +0200
+++ linux-2.6/fs/block_dev.c	2007-04-12 15:25:18.000000000 +0200
@@ -61,7 +61,7 @@ static sector_t max_block(struct block_d
 /* Kill _all_ buffers, dirty or not.. */
 static void kill_bdev(struct block_device *bdev)
 {
-	invalidate_bdev(bdev, 1);
+	invalidate_bdev(bdev);
 	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
 }	
 
@@ -1484,7 +1484,7 @@ int __invalidate_device(struct block_dev
 		res = invalidate_inodes(sb);
 		drop_super(sb);
 	}
-	invalidate_bdev(bdev, 0);
+	invalidate_bdev(bdev);
 	return res;
 }
 EXPORT_SYMBOL(__invalidate_device);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-12 14:05:54.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-12 15:26:37.000000000 +0200
@@ -340,7 +340,7 @@ out:
    we think the disk contains more recent information than the buffercache.
    The update == 1 pass marks the buffers we need to update, the update == 2
    pass does the actual I/O. */
-void invalidate_bdev(struct block_device *bdev, int destroy_dirty_buffers)
+void invalidate_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
@@ -348,11 +348,6 @@ void invalidate_bdev(struct block_device
 		return;
 
 	invalidate_bh_lrus();
-	/*
-	 * FIXME: what about destroy_dirty_buffers?
-	 * We really want to use invalidate_inode_pages2() for
-	 * that, but not until that's cleaned up.
-	 */
 	invalidate_mapping_pages(mapping, 0, -1);
 }
 
Index: linux-2.6/fs/dquot.c
===================================================================
--- linux-2.6.orig/fs/dquot.c	2007-04-10 16:29:57.000000000 +0200
+++ linux-2.6/fs/dquot.c	2007-04-12 15:25:18.000000000 +0200
@@ -1437,7 +1437,7 @@ int vfs_quota_off(struct super_block *sb
 			mutex_unlock(&dqopt->dqonoff_mutex);
 		}
 	if (sb->s_bdev)
-		invalidate_bdev(sb->s_bdev, 0);
+		invalidate_bdev(sb->s_bdev);
 	return 0;
 }
 
@@ -1473,7 +1473,7 @@ static int vfs_quota_on_inode(struct ino
 	 * we see all the changes from userspace... */
 	write_inode_now(inode, 1);
 	/* And now flush the block cache so that kernel sees the changes */
-	invalidate_bdev(sb->s_bdev, 0);
+	invalidate_bdev(sb->s_bdev);
 	mutex_lock(&inode->i_mutex);
 	mutex_lock(&dqopt->dqonoff_mutex);
 	if (sb_has_quota_enabled(sb, type)) {
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/ext3/super.c	2007-04-12 15:25:18.000000000 +0200
@@ -420,7 +420,7 @@ static void ext3_put_super (struct super
 		dump_orphan_list(sb, sbi);
 	J_ASSERT(list_empty(&sbi->s_orphan));
 
-	invalidate_bdev(sb->s_bdev, 0);
+	invalidate_bdev(sb->s_bdev);
 	if (sbi->journal_bdev && sbi->journal_bdev != sb->s_bdev) {
 		/*
 		 * Invalidate the journal device's buffers.  We don't want them
@@ -428,7 +428,7 @@ static void ext3_put_super (struct super
 		 * hotswapped, and it breaks the `ro-after' testing code.
 		 */
 		sync_blockdev(sbi->journal_bdev);
-		invalidate_bdev(sbi->journal_bdev, 0);
+		invalidate_bdev(sbi->journal_bdev);
 		ext3_blkdev_remove(sbi);
 	}
 	sb->s_fs_info = NULL;
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/ext4/super.c	2007-04-12 15:25:18.000000000 +0200
@@ -472,7 +472,7 @@ static void ext4_put_super (struct super
 		dump_orphan_list(sb, sbi);
 	J_ASSERT(list_empty(&sbi->s_orphan));
 
-	invalidate_bdev(sb->s_bdev, 0);
+	invalidate_bdev(sb->s_bdev);
 	if (sbi->journal_bdev && sbi->journal_bdev != sb->s_bdev) {
 		/*
 		 * Invalidate the journal device's buffers.  We don't want them
@@ -480,7 +480,7 @@ static void ext4_put_super (struct super
 		 * hotswapped, and it breaks the `ro-after' testing code.
 		 */
 		sync_blockdev(sbi->journal_bdev);
-		invalidate_bdev(sbi->journal_bdev, 0);
+		invalidate_bdev(sbi->journal_bdev);
 		ext4_blkdev_remove(sbi);
 	}
 	sb->s_fs_info = NULL;
Index: linux-2.6/fs/partitions/acorn.c
===================================================================
--- linux-2.6.orig/fs/partitions/acorn.c	2006-07-31 13:07:30.000000000 +0200
+++ linux-2.6/fs/partitions/acorn.c	2007-04-12 15:25:18.000000000 +0200
@@ -271,7 +271,7 @@ adfspart_check_ADFS(struct parsed_partit
 		extern void xd_set_geometry(struct block_device *,
 			unsigned char, unsigned char, unsigned int);
 		xd_set_geometry(bdev, dr->secspertrack, heads, 1);
-		invalidate_bdev(bdev, 1);
+		invalidate_bdev(bdev);
 		truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
 	}
 #endif
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h	2007-04-03 13:58:27.000000000 +0200
+++ linux-2.6/include/linux/buffer_head.h	2007-04-12 15:25:39.000000000 +0200
@@ -165,7 +165,7 @@ int sync_mapping_buffers(struct address_
 void unmap_underlying_metadata(struct block_device *bdev, sector_t block);
 
 void mark_buffer_async_write(struct buffer_head *bh);
-void invalidate_bdev(struct block_device *, int);
+void invalidate_bdev(struct block_device *);
 int sync_blockdev(struct block_device *bdev);
 void __wait_on_buffer(struct buffer_head *);
 wait_queue_head_t *bh_waitq_head(struct buffer_head *bh);
@@ -315,7 +315,7 @@ static inline int inode_has_buffers(stru
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
-static inline void invalidate_bdev(struct block_device *bdev, int destroy_dirty_buffers) {}
+static inline void invalidate_bdev(struct block_device *bdev) {}
 
 
 #endif /* CONFIG_BLOCK */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
