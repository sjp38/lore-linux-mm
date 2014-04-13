Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4826B00B3
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:03 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so7488611pab.22
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:02 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tv5si7758437pbc.330.2014.04.13.16.00.02
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:02 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 6/7] brd: Add support for rw_page
Date: Sun, 13 Apr 2014 18:59:55 -0400
Message-Id: <9563a366f721fd188a9a95edd47a7e5041359df6.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 drivers/block/brd.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index e73b85c..807d3d5 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -360,6 +360,15 @@ out:
 	bio_endio(bio, err);
 }
 
+static int brd_rw_page(struct block_device *bdev, sector_t sector,
+		       struct page *page, int rw)
+{
+	struct brd_device *brd = bdev->bd_disk->private_data;
+	int err = brd_do_bvec(brd, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	page_endio(page, rw & WRITE, err);
+	return err;
+}
+
 #ifdef CONFIG_BLK_DEV_XIP
 static int brd_direct_access(struct block_device *bdev, sector_t sector,
 			void **kaddr, unsigned long *pfn)
@@ -419,6 +428,7 @@ static int brd_ioctl(struct block_device *bdev, fmode_t mode,
 
 static const struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
+	.rw_page =		brd_rw_page,
 	.ioctl =		brd_ioctl,
 #ifdef CONFIG_BLK_DEV_XIP
 	.direct_access =	brd_direct_access,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
