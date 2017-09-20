Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB7B6B0260
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 01:43:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so3119206pfj.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 22:43:35 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j67si2522996pfk.420.2017.09.19.22.43.33
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 22:43:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/4] bdi: introduce BDI_CAP_SYNCHRONOUS_IO
Date: Wed, 20 Sep 2017 14:43:23 +0900
Message-Id: <1505886205-9671-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1505886205-9671-1-git-send-email-minchan@kernel.org>
References: <1505886205-9671-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Minchan Kim <minchan@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

By discussion[1], someday we will remove rw_page function. If so, we need
something to detect such super-fast storage which synchronous IO operation
like current rw_page is always win.

This patch introduces BDI_CAP_SYNCHRONOUS_IO to indicate such devices.
With it, we could use various optimization techniques.

[1] lkml.kernel.org/r/<20170728165604.10455-1-ross.zwisler@linux.intel.com>

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/brd.c           | 2 ++
 drivers/block/zram/zram_drv.c | 2 +-
 drivers/nvdimm/btt.c          | 3 +++
 drivers/nvdimm/pmem.c         | 2 ++
 include/linux/backing-dev.h   | 8 ++++++++
 5 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index bbd0d186cfc0..1fdb736aa882 100644
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
@@ -449,6 +450,7 @@ static struct brd_device *brd_alloc(int i)
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	sprintf(disk->disk_name, "ram%d", i);
 	set_capacity(disk, rd_size * 2);
+	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNCHRONOUS_IO;
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 	queue_flag_set_unlocked(QUEUE_FLAG_DAX, brd->brd_queue);
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 98ef1a8389b0..23172641fc01 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1556,7 +1556,7 @@ static int zram_add(void)
 		blk_queue_max_write_zeroes_sectors(zram->disk->queue, UINT_MAX);
 
 	zram->disk->queue->backing_dev_info->capabilities |=
-					BDI_CAP_STABLE_WRITES;
+			(BDI_CAP_STABLE_WRITES | BDI_CAP_SYNCHRONOUS_IO);
 	add_disk(zram->disk);
 
 	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index d5612bd1cc81..e949e3302af4 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -23,6 +23,7 @@
 #include <linux/ndctl.h>
 #include <linux/fs.h>
 #include <linux/nd.h>
+#include <linux/backing-dev.h>
 #include "btt.h"
 #include "nd.h"
 
@@ -1402,6 +1403,8 @@ static int btt_blk_init(struct btt *btt)
 	btt->btt_disk->private_data = btt;
 	btt->btt_disk->queue = btt->btt_queue;
 	btt->btt_disk->flags = GENHD_FL_EXT_DEVT;
+	btt->btt_disk->queue->backing_dev_info->capabilities |=
+			BDI_CAP_SYNCHRONOUS_IO;
 
 	blk_queue_make_request(btt->btt_queue, btt_make_request);
 	blk_queue_logical_block_size(btt->btt_queue, btt->sector_size);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 39dfd7affa31..7fbc5c5dc8e1 100644
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
@@ -394,6 +395,7 @@ static int pmem_attach_disk(struct device *dev,
 	disk->fops		= &pmem_fops;
 	disk->queue		= q;
 	disk->flags		= GENHD_FL_EXT_DEVT;
+	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNCHRONOUS_IO;
 	nvdimm_namespace_disk_name(ndns, disk->disk_name);
 	set_capacity(disk, (pmem->size - pmem->pfn_pad - pmem->data_offset)
 			/ 512);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 854e1bdd0b2a..cd41617c6594 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -123,6 +123,8 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
  *
  * BDI_CAP_CGROUP_WRITEBACK: Supports cgroup-aware writeback.
+ * BDI_CAP_SYNCHRONOUS_IO: Device is so fast that asynchronous IO would be
+ *			   inefficient.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
@@ -130,6 +132,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_STABLE_WRITES	0x00000008
 #define BDI_CAP_STRICTLIMIT	0x00000010
 #define BDI_CAP_CGROUP_WRITEBACK 0x00000020
+#define BDI_CAP_SYNCHRONOUS_IO	0x00000040
 
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
@@ -177,6 +180,11 @@ long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos);
 
+static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
+{
+	return bdi->capabilities & BDI_CAP_SYNCHRONOUS_IO;
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
