Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F15069003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:13 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142009589pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id jg9si595200pac.170.2015.08.25.18.33.12
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:13 -0700 (PDT)
Subject: [PATCH v2 1/9] dax: drop size parameter to ->direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:30 -0400
Message-ID: <20150826012729.8851.66729.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

None of the implementations currently use it.  The common
bdev_direct_access() entry point handles all the size checks before
calling ->direct_access().

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/sysdev/axonram.c |    2 +-
 drivers/block/brd.c           |    6 +-----
 drivers/nvdimm/pmem.c         |    2 +-
 drivers/s390/block/dcssblk.c  |    4 ++--
 fs/block_dev.c                |    2 +-
 include/linux/blkdev.h        |    2 +-
 6 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index a2be2a66dab6..4419c84ac15a 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -141,7 +141,7 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
  */
 static long
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       void __pmem **kaddr, unsigned long *pfn, long size)
+		       void __pmem **kaddr, unsigned long *pfn)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index c96402fd1560..03c45c41bdfa 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -371,7 +371,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **kaddr, unsigned long *pfn, long size)
+			void __pmem **kaddr, unsigned long *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -384,10 +384,6 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = (void __pmem *)page_address(page);
 	*pfn = page_to_pfn(page);
 
-	/*
-	 * TODO: If size > PAGE_SIZE, we could look to see if the next page in
-	 * the file happens to be mapped to the next page of physical RAM.
-	 */
 	return PAGE_SIZE;
 }
 #else
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index f3b629779266..3b5b9cb758b6 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -92,7 +92,7 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 }
 
 static long pmem_direct_access(struct block_device *bdev, sector_t sector,
-		      void __pmem **kaddr, unsigned long *pfn, long size)
+		      void __pmem **kaddr, unsigned long *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	size_t offset = sector << 9;
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 2c5a397b9f3e..8c027a9e4e8a 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -29,7 +29,7 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
 static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
 static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-			 void __pmem **kaddr, unsigned long *pfn, long size);
+			 void __pmem **kaddr, unsigned long *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -879,7 +879,7 @@ fail:
 
 static long
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			void __pmem **kaddr, unsigned long *pfn, long size)
+			void __pmem **kaddr, unsigned long *pfn)
 {
 	struct dcssblk_dev_info *dev_info;
 	unsigned long offset, dev_sz;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 2345a9870e2c..3831e5691b32 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -462,7 +462,7 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
 	sector += get_start_sect(bdev);
 	if (sector % (PAGE_SIZE / 512))
 		return -EINVAL;
-	avail = ops->direct_access(bdev, sector, addr, pfn, size);
+	avail = ops->direct_access(bdev, sector, addr, pfn);
 	if (!avail)
 		return -ERANGE;
 	return min(avail, size);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index c401ecdff9cb..c22064f326b2 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1556,7 +1556,7 @@ struct block_device_operations {
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	long (*direct_access)(struct block_device *, sector_t, void __pmem **,
-			unsigned long *pfn, long size);
+			unsigned long *pfn);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
