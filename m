Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2D36B0277
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i196so577627pgd.2
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p86si2906346pfd.295.2017.10.31.16.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:22 -0700 (PDT)
Subject: [PATCH 04/15] brd: remove dax support
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:21:57 -0700
Message-ID: <150949211688.24061.1197869674847507598.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jens Axboe <axboe@kernel.dk>, akpm@linux-foundation.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de

DAX support in brd is awkward because its backing page frames are
distinct from the ones provided by pmem, dcssblk, or axonram. We need
pfn_t_devmap() entries to fully support DAX, and the limited DAX support
for pfn_t_special() page frames is not interesting for brd when pmem is
already a superset of brd.  Lastly, brd is the only dax capable driver
that may sleep in its ->direct_access() implementation. So it causes a
global burden with no net gain of kernel functionality.

For all these reasons, remove DAX support.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/block/Kconfig |   12 ---------
 drivers/block/brd.c   |   65 -------------------------------------------------
 2 files changed, 77 deletions(-)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 2dfe99b328f8..da8bf0268ade 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -297,7 +297,6 @@ config BLK_DEV_SX8
 
 config BLK_DEV_RAM
 	tristate "RAM block device support"
-	select DAX if BLK_DEV_RAM_DAX
 	---help---
 	  Saying Y here will allow you to use a portion of your RAM memory as
 	  a block device, so that you can make file systems on it, read and
@@ -333,17 +332,6 @@ config BLK_DEV_RAM_SIZE
 	  The default value is 4096 kilobytes. Only change this if you know
 	  what you are doing.
 
-config BLK_DEV_RAM_DAX
-	bool "Support Direct Access (DAX) to RAM block devices"
-	depends on BLK_DEV_RAM && FS_DAX
-	default n
-	help
-	  Support filesystems using DAX to access RAM block devices.  This
-	  avoids double-buffering data in the page cache before copying it
-	  to the block device.  Answering Y will slightly enlarge the kernel,
-	  and will prevent RAM block device backing store memory from being
-	  allocated from highmem (only a problem for highmem systems).
-
 config CDROM_PKTCDVD
 	tristate "Packet writing on CD/DVD media (DEPRECATED)"
 	depends on !UML
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 2d7178f7754e..b2391bbd7e5a 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -20,11 +20,6 @@
 #include <linux/radix-tree.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-#include <linux/pfn_t.h>
-#include <linux/dax.h>
-#include <linux/uio.h>
-#endif
 
 #include <linux/uaccess.h>
 
@@ -44,9 +39,6 @@ struct brd_device {
 
 	struct request_queue	*brd_queue;
 	struct gendisk		*brd_disk;
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-	struct dax_device	*dax_dev;
-#endif
 	struct list_head	brd_list;
 
 	/*
@@ -112,9 +104,6 @@ static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
 	 * restriction might be able to be lifted.
 	 */
 	gfp_flags = GFP_NOIO | __GFP_ZERO;
-#ifndef CONFIG_BLK_DEV_RAM_DAX
-	gfp_flags |= __GFP_HIGHMEM;
-#endif
 	page = alloc_page(gfp_flags);
 	if (!page)
 		return NULL;
@@ -334,43 +323,6 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 	return err;
 }
 
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-static long __brd_direct_access(struct brd_device *brd, pgoff_t pgoff,
-		long nr_pages, void **kaddr, pfn_t *pfn)
-{
-	struct page *page;
-
-	if (!brd)
-		return -ENODEV;
-	page = brd_insert_page(brd, (sector_t)pgoff << PAGE_SECTORS_SHIFT);
-	if (!page)
-		return -ENOSPC;
-	*kaddr = page_address(page);
-	*pfn = page_to_pfn_t(page);
-
-	return 1;
-}
-
-static long brd_dax_direct_access(struct dax_device *dax_dev,
-		pgoff_t pgoff, long nr_pages, void **kaddr, pfn_t *pfn)
-{
-	struct brd_device *brd = dax_get_private(dax_dev);
-
-	return __brd_direct_access(brd, pgoff, nr_pages, kaddr, pfn);
-}
-
-static size_t brd_dax_copy_from_iter(struct dax_device *dax_dev, pgoff_t pgoff,
-		void *addr, size_t bytes, struct iov_iter *i)
-{
-	return copy_from_iter(addr, bytes, i);
-}
-
-static const struct dax_operations brd_dax_ops = {
-	.direct_access = brd_dax_direct_access,
-	.copy_from_iter = brd_dax_copy_from_iter,
-};
-#endif
-
 static const struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
 	.rw_page =		brd_rw_page,
@@ -450,21 +402,8 @@ static struct brd_device *brd_alloc(int i)
 	sprintf(disk->disk_name, "ram%d", i);
 	set_capacity(disk, rd_size * 2);
 
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-	queue_flag_set_unlocked(QUEUE_FLAG_DAX, brd->brd_queue);
-	brd->dax_dev = alloc_dax(brd, disk->disk_name, &brd_dax_ops);
-	if (!brd->dax_dev)
-		goto out_free_inode;
-#endif
-
-
 	return brd;
 
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-out_free_inode:
-	kill_dax(brd->dax_dev);
-	put_dax(brd->dax_dev);
-#endif
 out_free_queue:
 	blk_cleanup_queue(brd->brd_queue);
 out_free_dev:
@@ -504,10 +443,6 @@ static struct brd_device *brd_init_one(int i, bool *new)
 static void brd_del_one(struct brd_device *brd)
 {
 	list_del(&brd->brd_list);
-#ifdef CONFIG_BLK_DEV_RAM_DAX
-	kill_dax(brd->dax_dev);
-	put_dax(brd->dax_dev);
-#endif
 	del_gendisk(brd->brd_disk);
 	brd_free(brd);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
