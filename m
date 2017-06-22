Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 084536B0311
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:23:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so5053885wrd.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:23:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si1672825wrg.43.2017.06.22.07.23.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 07:23:34 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH 1/4] remove mapping from balance_dirty_pages*()
Date: Thu, 22 Jun 2017 17:23:21 +0300
Message-Id: <1498141404-18807-2-git-send-email-nborisov@suse.com>
In-Reply-To: <1498141404-18807-1-git-send-email-nborisov@suse.com>
References: <1498141404-18807-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk, Nikolay Borisov <nborisov@suse.com>

From: Josef Bacik <jbacik@fb.com>

The only reason we pass in the mapping is to get the inode in order to see if
writeback cgroups is enabled, and even then it only checks the bdi and a super
block flag.  balance_dirty_pages() doesn't even use the mapping.  Since
balance_dirty_pages*() works on a bdi level, just pass in the bdi and super
block directly so we can avoid using mapping.  This will allow us to still use
balance_dirty_pages for dirty metadata pages that are not backed by an
address_mapping.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---

Changes since previous posting [1]:

 - No functional/logic changes, just forwarded-ported to 4.12-rc6, as such 
 I've retained the acked-by and reviewed-by tags. 

 [1] https://patchwork.kernel.org/patch/9395201/

 drivers/mtd/devices/block2mtd.c | 12 ++++++++----
 fs/btrfs/disk-io.c              |  6 +++---
 fs/btrfs/file.c                 |  3 ++-
 fs/btrfs/ioctl.c                |  3 ++-
 fs/btrfs/relocation.c           |  3 ++-
 fs/buffer.c                     |  3 ++-
 fs/iomap.c                      |  6 ++++--
 fs/ntfs/attrib.c                | 10 +++++++---
 fs/ntfs/file.c                  |  4 ++--
 include/linux/backing-dev.h     | 29 +++++++++++++++++++++++------
 include/linux/writeback.h       |  3 ++-
 mm/filemap.c                    |  4 +++-
 mm/memory.c                     |  5 ++++-
 mm/page-writeback.c             | 15 +++++++--------
 14 files changed, 71 insertions(+), 35 deletions(-)

diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index 7c887f111a7d..7892d0b9fcb0 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -52,7 +52,8 @@ static struct page *page_read(struct address_space *mapping, int index)
 /* erase a specified part of the device */
 static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
 {
-	struct address_space *mapping = dev->blkdev->bd_inode->i_mapping;
+	struct inode *inode = dev->blkdev->bd_inode;
+	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 	int index = to >> PAGE_SHIFT;	// page index
 	int pages = len >> PAGE_SHIFT;
@@ -71,7 +72,8 @@ static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
 				memset(page_address(page), 0xff, PAGE_SIZE);
 				set_page_dirty(page);
 				unlock_page(page);
-				balance_dirty_pages_ratelimited(mapping);
+				balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+								inode->i_sb);
 				break;
 			}
 
@@ -141,7 +143,8 @@ static int _block2mtd_write(struct block2mtd_dev *dev, const u_char *buf,
 		loff_t to, size_t len, size_t *retlen)
 {
 	struct page *page;
-	struct address_space *mapping = dev->blkdev->bd_inode->i_mapping;
+	struct inode *inode = dev->blkdev->bd_inode;
+	struct address_space *mapping = inode->i_mapping;
 	int index = to >> PAGE_SHIFT;	// page index
 	int offset = to & ~PAGE_MASK;	// page offset
 	int cpylen;
@@ -162,7 +165,8 @@ static int _block2mtd_write(struct block2mtd_dev *dev, const u_char *buf,
 			memcpy(page_address(page) + offset, buf, cpylen);
 			set_page_dirty(page);
 			unlock_page(page);
-			balance_dirty_pages_ratelimited(mapping);
+			balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+							inode->i_sb);
 		}
 		put_page(page);
 
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 0ebd44135f1f..c6c6c498df73 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -4077,9 +4077,9 @@ static void __btrfs_btree_balance_dirty(struct btrfs_fs_info *fs_info,
 
 	ret = percpu_counter_compare(&fs_info->dirty_metadata_bytes,
 				     BTRFS_DIRTY_METADATA_THRESH);
-	if (ret > 0) {
-		balance_dirty_pages_ratelimited(fs_info->btree_inode->i_mapping);
-	}
+	if (ret > 0)
+		balance_dirty_pages_ratelimited(fs_info->sb->s_bdi,
+						fs_info->sb);
 }
 
 void btrfs_btree_balance_dirty(struct btrfs_fs_info *fs_info)
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index da1096eb1a40..34ea85a81084 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1780,7 +1780,8 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 
 		cond_resched();
 
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		if (dirty_pages < (fs_info->nodesize >> PAGE_SHIFT) + 1)
 			btrfs_btree_balance_dirty(fs_info);
 
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index e176375f374f..af204fe30904 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -1407,7 +1407,8 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		}
 
 		defrag_count += ret;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		inode_unlock(inode);
 
 		if (newer_than) {
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index d60df51959f7..30a4cf31fb25 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -3266,7 +3266,8 @@ static int relocate_file_extent_cluster(struct inode *inode,
 		put_page(page);
 
 		index++;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		btrfs_throttle(fs_info);
 	}
 	WARN_ON(nr != cluster->nr);
diff --git a/fs/buffer.c b/fs/buffer.c
index 161be58c5cb0..e012faeb6d5a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2425,7 +2425,8 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 		BUG_ON(err != len);
 		err = 0;
 
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 
 		if (unlikely(fatal_signal_pending(current))) {
 			err = -EINTR;
diff --git a/fs/iomap.c b/fs/iomap.c
index 4b10892967a5..5187624fc1ce 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -223,7 +223,8 @@ iomap_write_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		written += copied;
 		length -= copied;
 
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	} while (iov_iter_count(i) && length);
 
 	return written ? written : status;
@@ -305,7 +306,8 @@ iomap_dirty_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		written += status;
 		length -= status;
 
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	} while (length);
 
 	return written;
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index 44a39a099b54..0a8a39e08b7e 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -2493,6 +2493,7 @@ s64 ntfs_attr_extend_allocation(ntfs_inode *ni, s64 new_alloc_size,
 int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 {
 	ntfs_volume *vol = ni->vol;
+	struct inode *inode = VFS_I(ni);
 	struct address_space *mapping;
 	struct page *page;
 	u8 *kaddr;
@@ -2545,7 +2546,8 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		put_page(page);
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		cond_resched();
 		if (idx == end)
 			goto done;
@@ -2586,7 +2588,8 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		/* Finally unlock and release the page. */
 		unlock_page(page);
 		put_page(page);
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		cond_resched();
 	}
 	/* If there is a last partial page, need to do it the slow way. */
@@ -2603,7 +2606,8 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		put_page(page);
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		cond_resched();
 	}
 done:
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c4f68c338735..bbb2ef329222 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -276,7 +276,7 @@ static int ntfs_attr_extend_initialized(ntfs_inode *ni, const s64 new_init_size)
 		 * number of pages we read and make dirty in the case of sparse
 		 * files.
 		 */
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(vi), vi->i_sb);
 		cond_resched();
 	} while (++index < end_index);
 	read_lock_irqsave(&ni->size_lock, flags);
@@ -1913,7 +1913,7 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 		iov_iter_advance(i, copied);
 		pos += copied;
 		written += copied;
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(vi), vi->i_sb);
 		if (fatal_signal_pending(current)) {
 			status = -EINTR;
 			break;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e9c967b86054..bdedea9be0a6 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -241,8 +241,9 @@ void wb_blkcg_offline(struct blkcg *blkcg);
 int inode_congested(struct inode *inode, int cong_bits);
 
 /**
- * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
- * @inode: inode of interest
+ * bdi_cgwb_enabled - test wether cgroup writeback is enabled on a filesystem
+ * @bdi: the bdi we care about
+ * @sb: the super for the bdi
  *
  * cgroup writeback requires support from both the bdi and filesystem.
  * Also, both memcg and iocg have to be on the default hierarchy.  Test
@@ -251,15 +252,25 @@ int inode_congested(struct inode *inode, int cong_bits);
  * Note that the test result may change dynamically on the same inode
  * depending on how memcg and iocg are configured.
  */
-static inline bool inode_cgwb_enabled(struct inode *inode)
+static inline bool bdi_cgwb_enabled(struct backing_dev_info *bdi,
+				    struct super_block *sb)
 {
-	struct backing_dev_info *bdi = inode_to_bdi(inode);
-
 	return cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
 		cgroup_subsys_on_dfl(io_cgrp_subsys) &&
 		bdi_cap_account_dirty(bdi) &&
 		(bdi->capabilities & BDI_CAP_CGROUP_WRITEBACK) &&
-		(inode->i_sb->s_iflags & SB_I_CGROUPWB);
+		(sb->s_iflags & SB_I_CGROUPWB);
+}
+
+/**
+ * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
+ * @inode: inode of interest
+ *
+ * Does the inode have cgroup writeback support.
+ */
+static inline bool inode_cgwb_enabled(struct inode *inode)
+{
+	return bdi_cgwb_enabled(inode_to_bdi(inode), inode->i_sb);
 }
 
 /**
@@ -402,6 +413,12 @@ static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+static inline bool bdi_cgwb_enabled(struct backing_dev_info *bdi,
+				    struct super_block *sb)
+{
+	return false;
+}
+
 static inline bool inode_cgwb_enabled(struct inode *inode)
 {
 	return false;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index d5815794416c..343ac1954be1 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -376,7 +376,8 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 
 void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
-void balance_dirty_pages_ratelimited(struct address_space *mapping);
+void balance_dirty_pages_ratelimited(struct backing_dev_info *bdi,
+				     struct super_block *sb);
 bool wb_over_bg_thresh(struct bdi_writeback *wb);
 
 typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..73792e2c8e2f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2786,6 +2786,7 @@ ssize_t generic_perform_write(struct file *file,
 				struct iov_iter *i, loff_t pos)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	long status = 0;
 	ssize_t written = 0;
@@ -2859,7 +2860,8 @@ ssize_t generic_perform_write(struct file *file,
 		pos += copied;
 		written += copied;
 
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	} while (iov_iter_count(i));
 
 	return written ? written : status;
diff --git a/mm/memory.c b/mm/memory.c
index bb11c474857e..f76f07cbf620 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -68,6 +68,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/backing-dev.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2223,11 +2224,13 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
 	unlock_page(page);
 
 	if ((dirtied || page_mkwrite) && mapping) {
+		struct inode *inode = mapping->host;
 		/*
 		 * Some device drivers do not set page.mapping
 		 * but still dirty their pages
 		 */
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	}
 
 	if (!page_mkwrite)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b7451891959a..b96198926a1e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1559,8 +1559,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
  * If we're over `background_thresh' then the writeback threads are woken to
  * perform some writeout.
  */
-static void balance_dirty_pages(struct address_space *mapping,
-				struct bdi_writeback *wb,
+static void balance_dirty_pages(struct bdi_writeback *wb,
 				unsigned long pages_dirtied)
 {
 	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
@@ -1850,7 +1849,8 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
 
 /**
  * balance_dirty_pages_ratelimited - balance dirty memory state
- * @mapping: address_space which was dirtied
+ * @bdi: the bdi that was dirtied
+ * @sb: the super block that was dirtied
  *
  * Processes which are dirtying memory should call in here once for each page
  * which was newly dirtied.  The function will periodically check the system's
@@ -1861,10 +1861,9 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
  * limit we decrease the ratelimiting by a lot, to prevent individual processes
  * from overshooting the limit by (ratelimit_pages) each.
  */
-void balance_dirty_pages_ratelimited(struct address_space *mapping)
+void balance_dirty_pages_ratelimited(struct backing_dev_info *bdi,
+				     struct super_block *sb)
 {
-	struct inode *inode = mapping->host;
-	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct bdi_writeback *wb = NULL;
 	int ratelimit;
 	int *p;
@@ -1872,7 +1871,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	if (!bdi_cap_account_dirty(bdi))
 		return;
 
-	if (inode_cgwb_enabled(inode))
+	if (bdi_cgwb_enabled(bdi, sb))
 		wb = wb_get_create_current(bdi, GFP_KERNEL);
 	if (!wb)
 		wb = &bdi->wb;
@@ -1910,7 +1909,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	preempt_enable();
 
 	if (unlikely(current->nr_dirtied >= ratelimit))
-		balance_dirty_pages(mapping, wb, current->nr_dirtied);
+		balance_dirty_pages(wb, current->nr_dirtied);
 
 	wb_put(wb);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
