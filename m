Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B79F26B0273
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:29:07 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so579749pgd.0
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:29:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t21si2933999pfe.104.2017.10.31.16.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:29:06 -0700 (PDT)
Subject: [PATCH 12/15] mm,
 dax: enable filesystems to trigger page-idle callbacks
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:40 -0700
Message-ID: <150949216078.24061.1875240167277688258.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

Towards solving DAX-DMA vs truncate arrange for filesystems to set up a
page-idle callback when they mount a dax_device.

No functional changes are expected as this only registers a nop handler
for the ->page_free() event for device-mapped pages.

Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c      |   80 ++++++++++++++++++++++++++++++++++++++++------
 drivers/nvdimm/pmem.c    |   13 +++++++
 fs/ext2/super.c          |    6 ++-
 fs/ext4/super.c          |    6 ++-
 fs/xfs/xfs_super.c       |   20 ++++++------
 include/linux/dax.h      |   17 +++++-----
 include/linux/memremap.h |    6 +++
 kernel/memremap.c        |    1 +
 8 files changed, 113 insertions(+), 36 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 3ccb064d200d..193e0cd8d90c 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -29,6 +29,7 @@ static struct vfsmount *dax_mnt;
 static DEFINE_IDA(dax_minor_ida);
 static struct kmem_cache *dax_cache __read_mostly;
 static struct super_block *dax_superblock __read_mostly;
+DEFINE_MUTEX(devmap_lock);
 
 #define DAX_HASH_SIZE (PAGE_SIZE / sizeof(struct hlist_head))
 static struct hlist_head dax_host_list[DAX_HASH_SIZE];
@@ -62,16 +63,6 @@ int bdev_dax_pgoff(struct block_device *bdev, sector_t sector, size_t size,
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
@@ -169,9 +160,65 @@ struct dax_device {
 	const char *host;
 	void *private;
 	unsigned long flags;
+	struct dev_pagemap *pgmap;
 	const struct dax_operations *ops;
 };
 
+#if IS_ENABLED(CONFIG_FS_DAX)
+static void generic_dax_pagefree(struct page *page, void *data)
+{
+}
+
+struct dax_device *fs_dax_claim_bdev(struct block_device *bdev, void *owner)
+{
+	struct dax_device *dax_dev;
+	struct dev_pagemap *pgmap;
+
+	if (!blk_queue_dax(bdev->bd_queue))
+		return NULL;
+	dax_dev = fs_dax_get_by_host(bdev->bd_disk->disk_name);
+	if (!dax_dev->pgmap)
+		return dax_dev;
+	pgmap = dax_dev->pgmap;
+
+	mutex_lock(&devmap_lock);
+	if ((pgmap->data && pgmap->data != owner) || pgmap->page_free
+			|| pgmap->page_fault
+			|| pgmap->type != MEMORY_DEVICE_HOST) {
+		put_dax(dax_dev);
+		mutex_unlock(&devmap_lock);
+		return NULL;
+	}
+
+	pgmap->type = MEMORY_DEVICE_FS_DAX;
+	pgmap->page_free = generic_dax_pagefree;
+	pgmap->data = owner;
+	mutex_unlock(&devmap_lock);
+
+	return dax_dev;
+}
+EXPORT_SYMBOL_GPL(fs_dax_claim_bdev);
+
+void fs_dax_release(struct dax_device *dax_dev, void *owner)
+{
+	struct dev_pagemap *pgmap = dax_dev ? dax_dev->pgmap : NULL;
+
+	put_dax(dax_dev);
+	if (!pgmap)
+		return;
+	if (!pgmap->data)
+		return;
+
+	mutex_lock(&devmap_lock);
+	WARN_ON(pgmap->data != owner);
+	pgmap->type = MEMORY_DEVICE_HOST;
+	pgmap->page_free = NULL;
+	pgmap->data = NULL;
+	mutex_unlock(&devmap_lock);
+}
+EXPORT_SYMBOL_GPL(fs_dax_release);
+#endif
+
 static ssize_t write_cache_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -502,10 +549,23 @@ struct dax_device *alloc_dax(void *private, const char *__host,
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
 		return;
+	put_dev_pagemap(dax_dev->pgmap);
+	dax_dev->pgmap = NULL;
 	iput(&dax_dev->inode);
 }
 EXPORT_SYMBOL_GPL(put_dax);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 39dfd7affa31..9f36a2193eb6 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -300,6 +300,7 @@ static int pmem_attach_disk(struct device *dev,
 	struct vmem_altmap __altmap, *altmap = NULL;
 	int nid = dev_to_node(dev), fua, wbc;
 	struct resource *res = &nsio->res;
+	struct dev_pagemap *pgmap = NULL;
 	struct nd_pfn *nd_pfn = NULL;
 	struct dax_device *dax_dev;
 	struct nd_pfn_sb *pfn_sb;
@@ -358,14 +359,24 @@ static int pmem_attach_disk(struct device *dev,
 		pmem->pfn_flags |= PFN_MAP;
 		res = &pfn_res; /* for badblocks populate */
 		res->start += pmem->data_offset;
+		pgmap = get_dev_pagemap(PHYS_PFN(virt_to_phys(addr)), NULL);
+		if (!pgmap)
+			return -ENOMEM;
 	} else if (pmem_should_map_pages(dev)) {
 		addr = devm_memremap_pages(dev, &nsio->res,
 				&q->q_usage_counter, NULL);
 		pmem->pfn_flags |= PFN_MAP;
+		pgmap = get_dev_pagemap(PHYS_PFN(virt_to_phys(addr)), NULL);
+		if (!pgmap)
+			return -ENOMEM;
 	} else
 		addr = devm_memremap(dev, pmem->phys_addr,
 				pmem->size, ARCH_MEMREMAP_PMEM);
 
+
+	/* we still hold a reference until the driver is unloaded */
+	put_dev_pagemap(pgmap);
+
 	/*
 	 * At release time the queue must be frozen before
 	 * devm_memremap_pages is unwound
@@ -402,7 +413,7 @@ static int pmem_attach_disk(struct device *dev,
 	nvdimm_badblocks_populate(nd_region, &pmem->bb, res);
 	disk->bb = &pmem->bb;
 
-	dax_dev = alloc_dax(pmem, disk->disk_name, &pmem_dax_ops);
+	dax_dev = alloc_dax_devmap(pmem, disk->disk_name, &pmem_dax_ops, pgmap);
 	if (!dax_dev) {
 		put_disk(disk);
 		return -ENOMEM;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 1458706bd2ec..884784acd9fd 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -171,7 +171,7 @@ static void ext2_put_super (struct super_block * sb)
 	brelse (sbi->s_sbh);
 	sb->s_fs_info = NULL;
 	kfree(sbi->s_blockgroup_lock);
-	fs_put_dax(sbi->s_daxdev);
+	fs_dax_release(sbi->s_daxdev, sb);
 	kfree(sbi);
 }
 
@@ -814,7 +814,7 @@ static unsigned long descriptor_loc(struct super_block *sb,
 
 static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct dax_device *dax_dev = fs_dax_get_by_bdev(sb->s_bdev);
+	struct dax_device *dax_dev = fs_dax_claim_bdev(sb->s_bdev, sb);
 	struct buffer_head * bh;
 	struct ext2_sb_info * sbi;
 	struct ext2_super_block * es;
@@ -1202,7 +1202,7 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 	kfree(sbi->s_blockgroup_lock);
 	kfree(sbi);
 failed:
-	fs_put_dax(dax_dev);
+	fs_dax_release(dax_dev, sb);
 	return ret;
 }
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index b104096fce9e..f27355f41616 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -950,7 +950,7 @@ static void ext4_put_super(struct super_block *sb)
 	if (sbi->s_chksum_driver)
 		crypto_free_shash(sbi->s_chksum_driver);
 	kfree(sbi->s_blockgroup_lock);
-	fs_put_dax(sbi->s_daxdev);
+	fs_dax_release(sbi->s_daxdev, sb);
 	kfree(sbi);
 }
 
@@ -3397,7 +3397,7 @@ static void ext4_set_resv_clusters(struct super_block *sb)
 
 static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct dax_device *dax_dev = fs_dax_get_by_bdev(sb->s_bdev);
+	struct dax_device *dax_dev = fs_dax_claim_bdev(sb->s_bdev, sb);
 	char *orig_data = kstrdup(data, GFP_KERNEL);
 	struct buffer_head *bh;
 	struct ext4_super_block *es = NULL;
@@ -4400,7 +4400,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 out_free_base:
 	kfree(sbi);
 	kfree(orig_data);
-	fs_put_dax(dax_dev);
+	fs_dax_release(dax_dev, sb);
 	return err ? err : ret;
 }
 
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 584cf2d573ba..fdc4785a5c85 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -722,7 +722,7 @@ xfs_close_devices(
 
 		xfs_free_buftarg(mp, mp->m_logdev_targp);
 		xfs_blkdev_put(logdev);
-		fs_put_dax(dax_logdev);
+		fs_dax_release(dax_logdev, mp);
 	}
 	if (mp->m_rtdev_targp) {
 		struct block_device *rtdev = mp->m_rtdev_targp->bt_bdev;
@@ -730,10 +730,10 @@ xfs_close_devices(
 
 		xfs_free_buftarg(mp, mp->m_rtdev_targp);
 		xfs_blkdev_put(rtdev);
-		fs_put_dax(dax_rtdev);
+		fs_dax_release(dax_rtdev, mp);
 	}
 	xfs_free_buftarg(mp, mp->m_ddev_targp);
-	fs_put_dax(dax_ddev);
+	fs_dax_release(dax_ddev, mp);
 }
 
 /*
@@ -751,9 +751,9 @@ xfs_open_devices(
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
@@ -763,7 +763,7 @@ xfs_open_devices(
 		error = xfs_blkdev_get(mp, mp->m_logname, &logdev);
 		if (error)
 			goto out;
-		dax_logdev = fs_dax_get_by_bdev(logdev);
+		dax_logdev = fs_dax_claim_bdev(logdev, mp);
 	}
 
 	if (mp->m_rtname) {
@@ -777,7 +777,7 @@ xfs_open_devices(
 			error = -EINVAL;
 			goto out_close_rtdev;
 		}
-		dax_rtdev = fs_dax_get_by_bdev(rtdev);
+		dax_rtdev = fs_dax_claim_bdev(rtdev, mp);
 	}
 
 	/*
@@ -811,14 +811,14 @@ xfs_open_devices(
 	xfs_free_buftarg(mp, mp->m_ddev_targp);
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
index 122197124b9d..ea21ebfd1889 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -50,12 +50,8 @@ static inline struct dax_device *fs_dax_get_by_host(const char *host)
 	return dax_get_by_host(host);
 }
 
-static inline void fs_put_dax(struct dax_device *dax_dev)
-{
-	put_dax(dax_dev);
-}
-
-struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev);
+struct dax_device *fs_dax_claim_bdev(struct block_device *bdev, void *owner);
+void fs_dax_release(struct dax_device *dax_dev, void *owner);
 #else
 static inline int bdev_dax_supported(struct super_block *sb, int blocksize)
 {
@@ -67,13 +63,14 @@ static inline struct dax_device *fs_dax_get_by_host(const char *host)
 	return NULL;
 }
 
-static inline void fs_put_dax(struct dax_device *dax_dev)
+static inline struct dax_device *fs_dax_claim_bdev(struct block_device *bdev,
+		void *owner)
 {
+	return NULL;
 }
 
-static inline struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
+static inline void fs_dax_release(struct dax_device *dax_dev, void *owner)
 {
-	return NULL;
 }
 #endif
 
@@ -81,6 +78,8 @@ int dax_read_lock(void);
 void dax_read_unlock(int id);
 struct dax_device *alloc_dax(void *private, const char *host,
 		const struct dax_operations *ops);
+struct dax_device *alloc_dax_devmap(void *private, const char *host,
+		const struct dax_operations *ops, struct dev_pagemap *pgmap);
 bool dax_alive(struct dax_device *dax_dev);
 void kill_dax(struct dax_device *dax_dev);
 void *dax_get_private(struct dax_device *dax_dev);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 79f8ba7c3894..39d2de3f744b 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -64,11 +64,17 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * driver can hotplug the device memory using ZONE_DEVICE and with that memory
  * type. Any page of a process can be migrated to such memory. However no one
  * should be allow to pin such memory so that it can always be evicted.
+ *
+ * MEMORY_DEVICE_FS_DAX:
+ * MEMORY_DEVICE_HOST memory that is being managed by a filesystem. The
+ * filesystem needs page idle callbacks to coordinate direct-I/O + DMA
+ * (get_user_pages) vs truncate.
  */
 enum memory_type {
 	MEMORY_DEVICE_HOST = 0,
 	MEMORY_DEVICE_PRIVATE,
 	MEMORY_DEVICE_PUBLIC,
+	MEMORY_DEVICE_FS_DAX,
 };
 
 /*
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 403ab9cdb949..bf61cfa89c7d 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -323,6 +323,7 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	page_map = radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
 	return page_map ? &page_map->pgmap : NULL;
 }
+EXPORT_SYMBOL_GPL(find_dev_pagemap);
 
 /**
  * devm_memremap_pages - remap and provide memmap backing for the given resource

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
