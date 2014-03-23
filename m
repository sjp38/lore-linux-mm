Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A7A106B010D
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:24 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so4504117pab.18
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f1si7623998pbn.16.2014.03.23.12.09.22
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:22 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 22/22] brd: Rename XIP to DAX
Date: Sun, 23 Mar 2014 15:08:48 -0400
Message-Id: <7fd74703525f4077ed7c2b273ce6d082b03f0b61.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Since this is relating to FS_XIP, not KERNEL_XIP, it should be called
DAX instead of XIP.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 drivers/block/Kconfig | 13 +++++++------
 drivers/block/brd.c   | 14 +++++++-------
 fs/Kconfig            |  4 ++--
 3 files changed, 16 insertions(+), 15 deletions(-)

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
index 00da60d..619e0e0 100644
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
@@ -360,7 +360,7 @@ out:
 	bio_endio(bio, err);
 }
 
-#ifdef CONFIG_BLK_DEV_XIP
+#ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
 			void **kaddr, unsigned long *pfn, long size)
 {
@@ -383,6 +383,8 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	 * file is mapped to the next page of physical RAM */
 	return PAGE_SIZE;
 }
+#else
+#define brd_direct_access NULL
 #endif
 
 static int brd_ioctl(struct block_device *bdev, fmode_t mode,
@@ -422,9 +424,7 @@ static int brd_ioctl(struct block_device *bdev, fmode_t mode,
 static const struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
 	.ioctl =		brd_ioctl,
-#ifdef CONFIG_BLK_DEV_XIP
 	.direct_access =	brd_direct_access,
-#endif
 };
 
 /*
diff --git a/fs/Kconfig b/fs/Kconfig
index 620ab73..376bd0a 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -34,7 +34,7 @@ source "fs/btrfs/Kconfig"
 source "fs/nilfs2/Kconfig"
 
 config FS_DAX
-	bool "Direct Access support"
+	bool "Direct Access (DAX) support"
 	depends on MMU
 	help
 	  Direct Access (DAX) can be used on memory-backed block devices.
@@ -45,7 +45,7 @@ config FS_DAX
 
 	  If you do not have a block device that is capable of using this,
 	  or if unsure, say N.  Saying Y will increase the size of the kernel
-	  by about 2kB.
+	  by about 5kB.
 
 endif # BLOCK
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
