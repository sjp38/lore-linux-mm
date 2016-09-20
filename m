Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E241F6B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:58:23 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y6so24579533lff.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:58:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id fy6si28442135wjb.192.2016.09.20.13.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:58:20 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 1/4] remove mapping from balance_dirty_pages*()
Date: Tue, 20 Sep 2016 16:57:45 -0400
Message-ID: <1474405068-27841-2-git-send-email-jbacik@fb.com>
In-Reply-To: <1474405068-27841-1-git-send-email-jbacik@fb.com>
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

The only reason we pass in the mapping is to get the inode in order to see if
writeback cgroups is enabled, and even then it only checks the bdi and a super
block flag.  balance_dirty_pages() doesn't even use the mapping.  Since
balance_dirty_pages*() works on a bdi level, just pass in the bdi and super
block directly so we can avoid using mapping.  This will allow us to still use
balance_dirty_pages for dirty metadata pages that are not backed by an
address_mapping.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 drivers/mtd/devices/block2mtd.c | 12 ++++++++----
 fs/btrfs/disk-io.c              |  4 ++--
 fs/btrfs/file.c                 |  3 ++-
 fs/btrfs/ioctl.c                |  3 ++-
 fs/btrfs/relocation.c           |  3 ++-
 fs/buffer.c                     |  3 ++-
 fs/iomap.c                      |  3 ++-
 fs/ntfs/attrib.c                | 10 +++++++---
 fs/ntfs/file.c                  |  4 ++--
 include/linux/backing-dev.h     | 29 +++++++++++++++++++++++------
 include/linux/writeback.h       |  3 ++-
 mm/filemap.c                    |  4 +++-
 mm/memory.c                     |  9 +++++++--
 mm/page-writeback.c             | 15 +++++++--------
 14 files changed, 71 insertions(+), 34 deletions(-)

diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index 7c887f1..7892d0b 100644
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
index 87dad55..4034ad6 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -4024,8 +4024,8 @@ static void __btrfs_btree_balance_dirty(struct btrfs_root *root,
 	ret = percpu_counter_compare(&root->fs_info->dirty_metadata_bytes,
 				     BTRFS_DIRTY_METADATA_THRESH);
 	if (ret > 0) {
-		balance_dirty_pages_ratelimited(
-				   root->fs_info->btree_inode->i_mapping);
+		balance_dirty_pages_ratelimited(&root->fs_info->bdi,
+						root->fs_info->sb);
 	}
 }
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 9404121..f060b08 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1686,7 +1686,8 @@ again:
 
 		cond_resched();
 
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		if (dirty_pages < (root->nodesize >> PAGE_SHIFT) + 1)
 			btrfs_btree_balance_dirty(root);
 
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 14ed1e9..a222bad 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -1410,7 +1410,8 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		}
 
 		defrag_count += ret;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		inode_unlock(inode);
 
 		if (newer_than) {
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index b26a5ae..6e194a5 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -3202,7 +3202,8 @@ static int relocate_file_extent_cluster(struct inode *inode,
 		put_page(page);
 
 		index++;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 		btrfs_throttle(BTRFS_I(inode)->root);
 	}
 	WARN_ON(nr != cluster->nr);
diff --git a/fs/buffer.c b/fs/buffer.c
index 9c8eb9b..9bbe30d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2386,7 +2386,8 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 		BUG_ON(err != len);
 		err = 0;
 
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 
 		if (unlikely(fatal_signal_pending(current))) {
 			err = -EINTR;
diff --git a/fs/iomap.c b/fs/iomap.c
index 48141b8..937e266 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -226,7 +226,8 @@ again:
 		written += copied;
 		length -= copied;
 
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	} while (iov_iter_count(i) && length);
 
 	return written ? written : status;
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index 44a39a0..0a8a39e 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -2493,6 +2493,7 @@ conv_err_out:
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
index f548629..66082eb 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -276,7 +276,7 @@ do_non_resident_extend:
 		 * number of pages we read and make dirty in the case of sparse
 		 * files.
 		 */
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(vi), vi->i_sb);
 		cond_resched();
 	} while (++index < end_index);
 	read_lock_irqsave(&ni->size_lock, flags);
@@ -1914,7 +1914,7 @@ again:
 		iov_iter_advance(i, copied);
 		pos += copied;
 		written += copied;
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(vi), vi->i_sb);
 		if (fatal_signal_pending(current)) {
 			status = -EINTR;
 			break;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 491a917..089acf6 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -252,8 +252,9 @@ void wb_blkcg_offline(struct blkcg *blkcg);
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
@@ -262,15 +263,25 @@ int inode_congested(struct inode *inode, int cong_bits);
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
@@ -413,6 +424,12 @@ static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
 
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
index fc1e16c..256ffc3 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -364,7 +364,8 @@ unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 
 void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
 void page_writeback_init(void);
-void balance_dirty_pages_ratelimited(struct address_space *mapping);
+void balance_dirty_pages_ratelimited(struct backing_dev_info *bdi,
+				     struct super_block *sb);
 bool wb_over_bg_thresh(struct bdi_writeback *wb);
 
 typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
diff --git a/mm/filemap.c b/mm/filemap.c
index 3083ded..abb0e98 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2667,6 +2667,7 @@ ssize_t generic_perform_write(struct file *file,
 				struct iov_iter *i, loff_t pos)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	long status = 0;
 	ssize_t written = 0;
@@ -2746,7 +2747,8 @@ again:
 		pos += copied;
 		written += copied;
 
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	} while (iov_iter_count(i));
 
 	return written ? written : status;
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d..d43e73b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -64,6 +64,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/backing-dev.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2105,11 +2106,13 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 		put_page(page);
 
 		if ((dirtied || page_mkwrite) && mapping) {
+			struct inode *inode = mapping->host;
 			/*
 			 * Some device drivers do not set page.mapping
 			 * but still dirty their pages
 			 */
-			balance_dirty_pages_ratelimited(mapping);
+			balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+							inode->i_sb);
 		}
 
 		if (!page_mkwrite)
@@ -3291,11 +3294,13 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
 	mapping = page_rmapping(fault_page);
 	unlock_page(fault_page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
+		struct inode *inode = mapping->host;
 		/*
 		 * Some device drivers do not set page.mapping but still
 		 * dirty their pages
 		 */
-		balance_dirty_pages_ratelimited(mapping);
+		balance_dirty_pages_ratelimited(inode_to_bdi(inode),
+						inode->i_sb);
 	}
 
 	if (!vma->vm_ops->page_mkwrite)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f4cd7d8..121a6e3 100644
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
@@ -1849,7 +1848,8 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
 
 /**
  * balance_dirty_pages_ratelimited - balance dirty memory state
- * @mapping: address_space which was dirtied
+ * @bdi: the bdi that was dirtied
+ * @sb: the super block that was dirtied
  *
  * Processes which are dirtying memory should call in here once for each page
  * which was newly dirtied.  The function will periodically check the system's
@@ -1860,10 +1860,9 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
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
@@ -1871,7 +1870,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	if (!bdi_cap_account_dirty(bdi))
 		return;
 
-	if (inode_cgwb_enabled(inode))
+	if (bdi_cgwb_enabled(bdi, sb))
 		wb = wb_get_create_current(bdi, GFP_KERNEL);
 	if (!wb)
 		wb = &bdi->wb;
@@ -1909,7 +1908,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
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
