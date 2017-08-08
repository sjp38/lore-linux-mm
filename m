Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 789C66B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:50:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so26238196pgs.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:50:34 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 60si455520plb.982.2017.08.07.23.50.32
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 23:50:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 1/6] bdi: introduce BDI_CAP_SYNC
Date: Tue,  8 Aug 2017 15:50:19 +0900
Message-Id: <1502175024-28338-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1502175024-28338-1-git-send-email-minchan@kernel.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

By discussion[1], we will replace rw_page devices with on-stack-bio.
For such super-fast devices to be detected, this patch introduces
BDI_CAP_SYNC which means synchronous IO would be more efficient for
asnychronous IO and uses the flags to brd, zram, btt and pmem.

[1] lkml.kernel.org/r/<20170728165604.10455-1-ross.zwisler@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/brd.c           | 2 ++
 drivers/block/zram/zram_drv.c | 2 +-
 drivers/nvdimm/btt.c          | 2 ++
 drivers/nvdimm/pmem.c         | 2 ++
 include/linux/backing-dev.h   | 7 +++++++
 5 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 293250582f00..97d4e1679de7 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -20,6 +20,7 @@
 #include <linux/radix-tree.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
+#include <linux/backing-dev.h>
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 #include <linux/pfn_t.h>
 #include <linux/dax.h>
@@ -436,6 +437,7 @@ static struct brd_device *brd_alloc(int i)
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	sprintf(disk->disk_name, "ram%d", i);
 	set_capacity(disk, rd_size * 2);
+	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNC;
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 	queue_flag_set_unlocked(QUEUE_FLAG_DAX, brd->brd_queue);
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index bbbc2f230b8e..3eda88d0ca95 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1577,7 +1577,7 @@ static int zram_add(void)
 		blk_queue_max_write_zeroes_sectors(zram->disk->queue, UINT_MAX);
 
 	zram->disk->queue->backing_dev_info->capabilities |=
-					BDI_CAP_STABLE_WRITES;
+				(BDI_CAP_STABLE_WRITES | BDI_CAP_SYNC);
 	add_disk(zram->disk);
 
 	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index e10d3300b64c..16f60351e4fd 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -23,6 +23,7 @@
 #include <linux/ndctl.h>
 #include <linux/fs.h>
 #include <linux/nd.h>
+#include <linux/backing-dev.h>
 #include "btt.h"
 #include "nd.h"
 
@@ -1273,6 +1274,7 @@ static int btt_blk_init(struct btt *btt)
 	btt->btt_disk->private_data = btt;
 	btt->btt_disk->queue = btt->btt_queue;
 	btt->btt_disk->flags = GENHD_FL_EXT_DEVT;
+	btt->btt_disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNC;
 
 	blk_queue_make_request(btt->btt_queue, btt_make_request);
 	blk_queue_logical_block_size(btt->btt_queue, btt->sector_size);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index b5f04559a497..e1704099b5cc 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -31,6 +31,7 @@
 #include <linux/uio.h>
 #include <linux/dax.h>
 #include <linux/nd.h>
+#include <linux/backing-dev.h>
 #include "pmem.h"
 #include "pfn.h"
 #include "nd.h"
@@ -379,6 +380,7 @@ static int pmem_attach_disk(struct device *dev,
 	disk->fops		= &pmem_fops;
 	disk->queue		= q;
 	disk->flags		= GENHD_FL_EXT_DEVT;
+	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNC;
 	nvdimm_namespace_disk_name(ndns, disk->disk_name);
 	set_capacity(disk, (pmem->size - pmem->pfn_pad - pmem->data_offset)
 			/ 512);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 854e1bdd0b2a..397ee71763d7 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -123,6 +123,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
  *
  * BDI_CAP_CGROUP_WRITEBACK: Supports cgroup-aware writeback.
+ * BDI_CAP_SYNC: Device is so fast that asynchronous IO would be inefficient.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
@@ -130,6 +131,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_STABLE_WRITES	0x00000008
 #define BDI_CAP_STRICTLIMIT	0x00000010
 #define BDI_CAP_CGROUP_WRITEBACK 0x00000020
+#define BDI_CAP_SYNC		0x00000040
 
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
@@ -177,6 +179,11 @@ long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos);
 
+static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
+{
+	return bdi->capabilities & BDI_CAP_SYNC;
+}
+
 static inline bool bdi_cap_stable_pages_required(struct backing_dev_info *bdi)
 {
 	return bdi->capabilities & BDI_CAP_STABLE_WRITES;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
