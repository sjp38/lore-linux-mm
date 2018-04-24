Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 223636B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z20so14218056pfn.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y21si15065091pfi.195.2018.04.24.16.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:43:10 -0700 (PDT)
Subject: [PATCH v9 2/9] mm,
 dax: enable filesystems to trigger dev_pagemap ->page_free callbacks
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:13 -0700
Message-ID: <152461279341.17530.15922380333372355441.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Jan Kara <jack@suse.cz>, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.orgjack@suse.czhch@lst.de

In order to resolve collisions between filesystem operations and DMA to
DAX mapped pages we need a callback when DMA completes. With a callback
we can hold off filesystem operations while DMA is in-flight and then
resume those operations when the last put_page() occurs on a DMA page.

Recall that the 'struct page' entries for DAX memory are created with
devm_memremap_pages(). That routine arranges for the pages to be
allocated, but never onlined, so a DAX page is DMA-idle when its
reference count reaches one.

Also recall that the HMM sub-system added infrastructure to trap the
page-idle (2-to-1 reference count) transition of the pages allocated by
devm_memremap_pages() and trigger a callback via the 'struct
dev_pagemap' associated with the page range. Whereas the HMM callbacks
are going to a device driver to manage bounce pages in device-memory in
the filesystem-dax case we will call back to filesystem specified
callback.

Since the callback is not known at devm_memremap_pages() time we arrange
for the filesystem to install it at mount time. No functional changes
are expected as this only registers a nop handler for the ->page_free()
event for device-mapped pages.

Cc: Michal Hocko <mhocko@suse.com>
Reviewed-by: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c   |   21 +++++++++++----------
 drivers/nvdimm/pmem.c |    3 ++-
 fs/ext2/super.c       |    6 +++---
 fs/ext4/super.c       |    6 +++---
 fs/xfs/xfs_super.c    |   20 ++++++++++----------
 include/linux/dax.h   |   14 ++++++++------
 6 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index e62a64b9c9fb..e4864f319e16 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -63,16 +63,6 @@ int bdev_dax_pgoff(struct block_device *bdev, sector_t sector, size_t size,
 }
 EXPORT_SYMBOL(bdev_dax_pgoff);
 
-#if IS_ENABLED(CONFIG_FS_DAX)
-struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
-{
-	if (!blk_queue_dax(bdev->bd_queue))
-		return NULL;
-	return fs_dax_get_by_host(bdev->bd_disk->disk_name);
-}
-EXPORT_SYMBOL_GPL(fs_dax_get_by_bdev);
-#endif
-
 /**
  * __bdev_dax_supported() - Check if the device supports dax for filesystem
  * @sb: The superblock of the device
@@ -575,6 +565,17 @@ struct dax_device *alloc_dax(void *private, const char *__host,
 }
 EXPORT_SYMBOL_GPL(alloc_dax);
 
+struct dax_device *alloc_dax_devmap(void *private, const char *host,
+		const struct dax_operations *ops, struct dev_pagemap *pgmap)
+{
+	struct dax_device *dax_dev = alloc_dax(private, host, ops);
+
+	if (dax_dev)
+		dax_dev->pgmap = pgmap;
+	return dax_dev;
+}
+EXPORT_SYMBOL_GPL(alloc_dax_devmap);
+
 void put_dax(struct dax_device *dax_dev)
 {
 	if (!dax_dev)
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 9d714926ecf5..fc1a1ab25e9e 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -408,7 +408,8 @@ static int pmem_attach_disk(struct device *dev,
 	nvdimm_badblocks_populate(nd_region, &pmem->bb, &bb_res);
 	disk->bb = &pmem->bb;
 
-	dax_dev = alloc_dax(pmem, disk->disk_name, &pmem_dax_ops);
+	dax_dev = alloc_dax_devmap(pmem, disk->disk_name, &pmem_dax_ops,
+			&pmem->pgmap);
 	if (!dax_dev) {
 		put_disk(disk);
 		return -ENOMEM;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index de1694512f1f..421c7d4bed39 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -172,7 +172,7 @@ static void ext2_put_super (struct super_block * sb)
 	brelse (sbi->s_sbh);
 	sb->s_fs_info = NULL;
 	kfree(sbi->s_blockgroup_lock);
-	fs_put_dax(sbi->s_daxdev);
+	fs_dax_release(sbi->s_daxdev, sb);
 	kfree(sbi);
 }
 
@@ -817,7 +817,7 @@ static unsigned long descriptor_loc(struct super_block *sb,
 
 static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct dax_device *dax_dev = fs_dax_get_by_bdev(sb->s_bdev);
+	struct dax_device *dax_dev = fs_dax_claim_bdev(sb->s_bdev, sb);
 	struct buffer_head * bh;
 	struct ext2_sb_info * sbi;
 	struct ext2_super_block * es;
@@ -1213,7 +1213,7 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 	kfree(sbi->s_blockgroup_lock);
 	kfree(sbi);
 failed:
-	fs_put_dax(dax_dev);
+	fs_dax_release(dax_dev, sb);
 	return ret;
 }
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 185f7e61f4cf..3e5d0f9e8772 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -954,7 +954,7 @@ static void ext4_put_super(struct super_block *sb)
 	if (sbi->s_chksum_driver)
 		crypto_free_shash(sbi->s_chksum_driver);
 	kfree(sbi->s_blockgroup_lock);
-	fs_put_dax(sbi->s_daxdev);
+	fs_dax_release(sbi->s_daxdev, sb);
 	kfree(sbi);
 }
 
@@ -3407,7 +3407,7 @@ static void ext4_set_resv_clusters(struct super_block *sb)
 
 static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct dax_device *dax_dev = fs_dax_get_by_bdev(sb->s_bdev);
+	struct dax_device *dax_dev = fs_dax_claim_bdev(sb->s_bdev, sb);
 	char *orig_data = kstrdup(data, GFP_KERNEL);
 	struct buffer_head *bh;
 	struct ext4_super_block *es = NULL;
@@ -4429,7 +4429,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 out_free_base:
 	kfree(sbi);
 	kfree(orig_data);
-	fs_put_dax(dax_dev);
+	fs_dax_release(dax_dev, sb);
 	return err ? err : ret;
 }
 
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index d71424052917..f53f8a47a526 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -724,7 +724,7 @@ xfs_close_devices(
 
 		xfs_free_buftarg(mp->m_logdev_targp);
 		xfs_blkdev_put(logdev);
-		fs_put_dax(dax_logdev);
+		fs_dax_release(dax_logdev, mp);
 	}
 	if (mp->m_rtdev_targp) {
 		struct block_device *rtdev = mp->m_rtdev_targp->bt_bdev;
@@ -732,10 +732,10 @@ xfs_close_devices(
 
 		xfs_free_buftarg(mp->m_rtdev_targp);
 		xfs_blkdev_put(rtdev);
-		fs_put_dax(dax_rtdev);
+		fs_dax_release(dax_rtdev, mp);
 	}
 	xfs_free_buftarg(mp->m_ddev_targp);
-	fs_put_dax(dax_ddev);
+	fs_dax_release(dax_ddev, mp);
 }
 
 /*
@@ -753,9 +753,9 @@ xfs_open_devices(
 	struct xfs_mount	*mp)
 {
 	struct block_device	*ddev = mp->m_super->s_bdev;
-	struct dax_device	*dax_ddev = fs_dax_get_by_bdev(ddev);
-	struct dax_device	*dax_logdev = NULL, *dax_rtdev = NULL;
+	struct dax_device	*dax_ddev = fs_dax_claim_bdev(ddev, mp);
 	struct block_device	*logdev = NULL, *rtdev = NULL;
+	struct dax_device	*dax_logdev = NULL, *dax_rtdev = NULL;
 	int			error;
 
 	/*
@@ -765,7 +765,7 @@ xfs_open_devices(
 		error = xfs_blkdev_get(mp, mp->m_logname, &logdev);
 		if (error)
 			goto out;
-		dax_logdev = fs_dax_get_by_bdev(logdev);
+		dax_logdev = fs_dax_claim_bdev(logdev, mp);
 	}
 
 	if (mp->m_rtname) {
@@ -779,7 +779,7 @@ xfs_open_devices(
 			error = -EINVAL;
 			goto out_close_rtdev;
 		}
-		dax_rtdev = fs_dax_get_by_bdev(rtdev);
+		dax_rtdev = fs_dax_claim_bdev(rtdev, mp);
 	}
 
 	/*
@@ -813,14 +813,14 @@ xfs_open_devices(
 	xfs_free_buftarg(mp->m_ddev_targp);
  out_close_rtdev:
 	xfs_blkdev_put(rtdev);
-	fs_put_dax(dax_rtdev);
+	fs_dax_release(dax_rtdev, mp);
  out_close_logdev:
 	if (logdev && logdev != ddev) {
 		xfs_blkdev_put(logdev);
-		fs_put_dax(dax_logdev);
+		fs_dax_release(dax_logdev, mp);
 	}
  out:
-	fs_put_dax(dax_ddev);
+	fs_dax_release(dax_ddev, mp);
 	return error;
 }
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index af02f93c943a..fe322d67856e 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -33,6 +33,8 @@ extern struct attribute_group dax_attribute_group;
 struct dax_device *dax_get_by_host(const char *host);
 struct dax_device *alloc_dax(void *private, const char *host,
 		const struct dax_operations *ops);
+struct dax_device *alloc_dax_devmap(void *private, const char *host,
+		const struct dax_operations *ops, struct dev_pagemap *pgmap);
 void put_dax(struct dax_device *dax_dev);
 void kill_dax(struct dax_device *dax_dev);
 void dax_write_cache(struct dax_device *dax_dev, bool wc);
@@ -51,6 +53,12 @@ static inline struct dax_device *alloc_dax(void *private, const char *host,
 	 */
 	return NULL;
 }
+static inline struct dax_device *alloc_dax_devmap(void *private,
+		const char *host, const struct dax_operations *ops,
+		struct dev_pagemap *pgmap)
+{
+	return NULL;
+}
 static inline void put_dax(struct dax_device *dax_dev)
 {
 }
@@ -85,7 +93,6 @@ static inline void fs_put_dax(struct dax_device *dax_dev)
 	put_dax(dax_dev);
 }
 
-struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev);
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
 struct dax_device *fs_dax_claim(struct dax_device *dax_dev, void *owner);
@@ -123,11 +130,6 @@ static inline void fs_put_dax(struct dax_device *dax_dev)
 {
 }
 
-static inline struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
-{
-	return NULL;
-}
-
 static inline int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc)
 {
