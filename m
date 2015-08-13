Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 39A606B0256
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:06:58 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so27512725pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:06:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r4si1305437pdr.193.2015.08.12.20.06.57
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:06:57 -0700 (PDT)
Subject: [PATCH v5 3/5] dax: drop size parameter to ->direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:01:14 -0400
Message-ID: <20150813030114.36703.27957.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

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
index ee90db17b097..e8657d3bc588 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -141,7 +141,7 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
  */
 static long
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       void **kaddr, unsigned long *pfn, long size)
+		       void **kaddr, unsigned long *pfn)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 64ab4951e9d6..41528857c70d 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -371,7 +371,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
-			void **kaddr, unsigned long *pfn, long size)
+			void **kaddr, unsigned long *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -384,10 +384,6 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = page_address(page);
 	*pfn = page_to_pfn(page);
 
-	/*
-	 * TODO: If size > PAGE_SIZE, we could look to see if the next page in
-	 * the file happens to be mapped to the next page of physical RAM.
-	 */
 	return PAGE_SIZE;
 }
 #else
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index eb7552d939e1..5e019a6942ce 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -92,7 +92,7 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 }
 
 static long pmem_direct_access(struct block_device *bdev, sector_t sector,
-			      void **kaddr, unsigned long *pfn, long size)
+			      void **kaddr, unsigned long *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	size_t offset = sector << 9;
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index da212813f2d5..2f1734ba0e22 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -29,7 +29,7 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
 static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
 static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-				 void **kaddr, unsigned long *pfn, long size);
+				 void **kaddr, unsigned long *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -879,7 +879,7 @@ fail:
 
 static long
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			void **kaddr, unsigned long *pfn, long size)
+			void **kaddr, unsigned long *pfn)
 {
 	struct dcssblk_dev_info *dev_info;
 	unsigned long offset, dev_sz;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 198243717da5..3a8ac7edfbf4 100644
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
index d4068c17d0df..ff47d5498133 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1556,7 +1556,7 @@ struct block_device_operations {
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	long (*direct_access)(struct block_device *, sector_t,
-					void **, unsigned long *pfn, long size);
+					void **, unsigned long *pfn);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
