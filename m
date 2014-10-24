Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 63C9E6B0072
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 17:24:00 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so134549pad.11
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:24:00 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id jv2si5007668pbc.192.2014.10.24.14.23.58
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 14:23:59 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v12 20/20] brd: Rename XIP to DAX
Date: Fri, 24 Oct 2014 17:20:52 -0400
Message-Id: <1414185652-28663-21-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Since this is relating to FS_XIP, not KERNEL_XIP, it should be called
DAX instead of XIP.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 drivers/block/Kconfig | 13 +++++++------
 drivers/block/brd.c   | 14 +++++++-------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 014a1cf..1b8094d 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -393,14 +393,15 @@ config BLK_DEV_RAM_SIZE
 	  The default value is 4096 kilobytes. Only change this if you know
 	  what you are doing.
 
-config BLK_DEV_XIP
-	bool "Support XIP filesystems on RAM block device"
-	depends on BLK_DEV_RAM
+config BLK_DEV_RAM_DAX
+	bool "Support Direct Access (DAX) to RAM block devices"
+	depends on BLK_DEV_RAM && FS_DAX
 	default n
 	help
-	  Support XIP filesystems (such as ext2 with XIP support on) on
-	  top of block ram device. This will slightly enlarge the kernel, and
-	  will prevent RAM block device backing store memory from being
+	  Support filesystems using DAX to access RAM block devices.  This
+	  avoids double-buffering data in the page cache before copying it
+	  to the block device.  Answering Y will slightly enlarge the kernel,
+	  and will prevent RAM block device backing store memory from being
 	  allocated from highmem (only a problem for highmem systems).
 
 config CDROM_PKTCDVD
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 89e90ec..898b4f2 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -97,13 +97,13 @@ static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
 	 * Must use NOIO because we don't want to recurse back into the
 	 * block or filesystem layers from page reclaim.
 	 *
-	 * Cannot support XIP and highmem, because our ->direct_access
-	 * routine for XIP must return memory that is always addressable.
-	 * If XIP was reworked to use pfns and kmap throughout, this
+	 * Cannot support DAX and highmem, because our ->direct_access
+	 * routine for DAX must return memory that is always addressable.
+	 * If DAX was reworked to use pfns and kmap throughout, this
 	 * restriction might be able to be lifted.
 	 */
 	gfp_flags = GFP_NOIO | __GFP_ZERO;
-#ifndef CONFIG_BLK_DEV_XIP
+#ifndef CONFIG_BLK_DEV_RAM_DAX
 	gfp_flags |= __GFP_HIGHMEM;
 #endif
 	page = alloc_page(gfp_flags);
@@ -369,7 +369,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 	return err;
 }
 
-#ifdef CONFIG_BLK_DEV_XIP
+#ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
 			void **kaddr, unsigned long *pfn, long size)
 {
@@ -390,6 +390,8 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	 */
 	return PAGE_SIZE;
 }
+#else
+#define brd_direct_access NULL
 #endif
 
 static int brd_ioctl(struct block_device *bdev, fmode_t mode,
@@ -430,9 +432,7 @@ static const struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
 	.rw_page =		brd_rw_page,
 	.ioctl =		brd_ioctl,
-#ifdef CONFIG_BLK_DEV_XIP
 	.direct_access =	brd_direct_access,
-#endif
 };
 
 /*
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
