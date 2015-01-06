Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 041BF6B0103
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:54 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id dc16so16676420qab.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:53 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com. [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id e5si65275062qcm.34.2015.01.06.11.29.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:46 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id n4so16670660qaq.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:45 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 13/16] writeback: separate out include/linux/backing-dev-defs.h
Date: Tue,  6 Jan 2015 14:29:14 -0500
Message-Id: <1420572557-11572-14-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>

With the planned cgroup writeback support, backing-dev related
declarations will be more widely used across block and cgroup;
unfortunately, including backing-dev.h from include/linux/blkdev.h
makes cyclic include dependency quite likely.

This patch separates out backing-dev-defs.h which only has the
essential definitions and updates blkdev.h to include it.  c files
which need access to more backing-dev details now include
backing-dev.h directly.  This takes backing-dev.h off the common
include dependency chain making it a lot easier to use it across block
and cgroup.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
---
 block/blk-integrity.c            |   1 +
 block/blk-sysfs.c                |   1 +
 block/bounce.c                   |   1 +
 block/genhd.c                    |   1 +
 drivers/block/drbd/drbd_int.h    |   1 +
 drivers/block/pktcdvd.c          |   1 +
 drivers/char/raw.c               |   1 +
 drivers/md/bcache/request.c      |   1 +
 drivers/md/dm.h                  |   1 +
 drivers/md/md.h                  |   1 +
 drivers/mtd/devices/block2mtd.c  |   1 +
 fs/block_dev.c                   |   1 +
 fs/ext4/extents.c                |   1 +
 fs/ext4/mballoc.c                |   1 +
 fs/f2fs/segment.h                |   1 +
 fs/hfs/super.c                   |   1 +
 fs/hfsplus/super.c               |   1 +
 fs/nfs/filelayout/filelayout.c   |   1 +
 fs/reiserfs/super.c              |   1 +
 fs/ufs/super.c                   |   1 +
 include/linux/backing-dev-defs.h | 105 +++++++++++++++++++++++++++++++++++++++
 include/linux/backing-dev.h      | 100 +------------------------------------
 include/linux/blkdev.h           |   2 +-
 mm/madvise.c                     |   1 +
 24 files changed, 128 insertions(+), 100 deletions(-)
 create mode 100644 include/linux/backing-dev-defs.h

diff --git a/block/blk-integrity.c b/block/blk-integrity.c
index 79ffb48..f548b64 100644
--- a/block/blk-integrity.c
+++ b/block/blk-integrity.c
@@ -21,6 +21,7 @@
  */
 
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/mempool.h>
 #include <linux/bio.h>
 #include <linux/scatterlist.h>
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 4286580..b722e68 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -6,6 +6,7 @@
 #include <linux/module.h>
 #include <linux/bio.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/blktrace_api.h>
 #include <linux/blk-mq.h>
 #include <linux/blk-cgroup.h>
diff --git a/block/bounce.c b/block/bounce.c
index ab21ba2..c616a60 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/init.h>
 #include <linux/hash.h>
 #include <linux/highmem.h>
diff --git a/block/genhd.c b/block/genhd.c
index 64600e9..81cc7c6 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -8,6 +8,7 @@
 #include <linux/kdev_t.h>
 #include <linux/kernel.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/init.h>
 #include <linux/spinlock.h>
 #include <linux/proc_fs.h>
diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
index b905e98..efd19c2 100644
--- a/drivers/block/drbd/drbd_int.h
+++ b/drivers/block/drbd/drbd_int.h
@@ -38,6 +38,7 @@
 #include <linux/mutex.h>
 #include <linux/major.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/genhd.h>
 #include <linux/idr.h>
 #include <net/tcp.h>
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index 09e628da..4c20c22 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -61,6 +61,7 @@
 #include <linux/freezer.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/backing-dev.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_ioctl.h>
 #include <scsi/scsi.h>
diff --git a/drivers/char/raw.c b/drivers/char/raw.c
index a24891b..4a3cfd7 100644
--- a/drivers/char/raw.c
+++ b/drivers/char/raw.c
@@ -12,6 +12,7 @@
 #include <linux/fs.h>
 #include <linux/major.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/module.h>
 #include <linux/raw.h>
 #include <linux/capability.h>
diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
index ab43fad..9c083b9 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/hash.h>
 #include <linux/random.h>
+#include <linux/backing-dev.h>
 
 #include <trace/events/bcache.h>
 
diff --git a/drivers/md/dm.h b/drivers/md/dm.h
index 59f53e7..ae4a3ca 100644
--- a/drivers/md/dm.h
+++ b/drivers/md/dm.h
@@ -14,6 +14,7 @@
 #include <linux/device-mapper.h>
 #include <linux/list.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/hdreg.h>
 #include <linux/completion.h>
 #include <linux/kobject.h>
diff --git a/drivers/md/md.h b/drivers/md/md.h
index 03cec5b..684b7ff 100644
--- a/drivers/md/md.h
+++ b/drivers/md/md.h
@@ -16,6 +16,7 @@
 #define _MD_MD_H
 
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/kobject.h>
 #include <linux/list.h>
 #include <linux/mm.h>
diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index 66f0405..e22e40f 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/bio.h>
 #include <linux/pagemap.h>
 #include <linux/list.h>
diff --git a/fs/block_dev.c b/fs/block_dev.c
index b48c41b..0413d3f 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -14,6 +14,7 @@
 #include <linux/device_cgroup.h>
 #include <linux/highmem.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/module.h>
 #include <linux/blkpg.h>
 #include <linux/magic.h>
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index bed4308..21a7bcb 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -39,6 +39,7 @@
 #include <linux/slab.h>
 #include <asm/uaccess.h>
 #include <linux/fiemap.h>
+#include <linux/backing-dev.h>
 #include "ext4_jbd2.h"
 #include "ext4_extents.h"
 #include "xattr.h"
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 8d1e602..440987c 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -26,6 +26,7 @@
 #include <linux/log2.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/backing-dev.h>
 #include <trace/events/ext4.h>
 
 #ifdef CONFIG_EXT4_DEBUG
diff --git a/fs/f2fs/segment.h b/fs/f2fs/segment.h
index 76a5361..f112ec0 100644
--- a/fs/f2fs/segment.h
+++ b/fs/f2fs/segment.h
@@ -9,6 +9,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 
 /* constant macro */
 #define NULL_SEGNO			((unsigned int)(~0))
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index eee7206..55c03b9 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -14,6 +14,7 @@
 
 #include <linux/module.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/nls.h>
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 593af2f..7302d96 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
 #include <linux/vfs.h>
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 4336678..a6209cd 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -32,6 +32,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/module.h>
+#include <linux/backing-dev.h>
 
 #include <linux/sunrpc/metrics.h>
 
diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 71fbbe3..badcf7b 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -21,6 +21,7 @@
 #include "xattr.h"
 #include <linux/init.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
 #include <linux/exportfs.h>
 #include <linux/quotaops.h>
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index e515e99..ecb793e 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -80,6 +80,7 @@
 #include <linux/stat.h>
 #include <linux/string.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/init.h>
 #include <linux/parser.h>
 #include <linux/buffer_head.h>
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
new file mode 100644
index 0000000..2874d83
--- /dev/null
+++ b/include/linux/backing-dev-defs.h
@@ -0,0 +1,105 @@
+#ifndef __LINUX_BACKING_DEV_DEFS_H
+#define __LINUX_BACKING_DEV_DEFS_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/percpu_counter.h>
+#include <linux/flex_proportions.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+
+struct page;
+struct device;
+struct dentry;
+
+/*
+ * Bits in bdi_writeback.state
+ */
+enum wb_state {
+	WB_async_congested,	/* The async (write) queue is getting full */
+	WB_sync_congested,	/* The sync queue is getting full */
+	WB_registered,		/* bdi_register() was done */
+	WB_writeback_running,	/* Writeback is in progress */
+};
+
+typedef int (congested_fn)(void *, int);
+
+enum wb_stat_item {
+	WB_RECLAIMABLE,
+	WB_WRITEBACK,
+	WB_DIRTIED,
+	WB_WRITTEN,
+	NR_WB_STAT_ITEMS
+};
+
+#define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
+
+struct bdi_writeback {
+	struct backing_dev_info *bdi;	/* our parent bdi */
+
+	unsigned long state;		/* Always use atomic bitops on this */
+	unsigned long last_old_flush;	/* last old data flush */
+
+	struct list_head b_dirty;	/* dirty inodes */
+	struct list_head b_io;		/* parked for writeback */
+	struct list_head b_more_io;	/* parked for more writeback */
+	spinlock_t list_lock;		/* protects the b_* lists */
+
+	struct percpu_counter stat[NR_WB_STAT_ITEMS];
+
+	unsigned long bw_time_stamp;	/* last time write bw is updated */
+	unsigned long dirtied_stamp;
+	unsigned long written_stamp;	/* pages written at bw_time_stamp */
+	unsigned long write_bandwidth;	/* the estimated write bandwidth */
+	unsigned long avg_write_bandwidth; /* further smoothed write bw */
+
+	/*
+	 * The base dirty throttle rate, re-calculated on every 200ms.
+	 * All the bdi tasks' dirty rate will be curbed under it.
+	 * @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit
+	 * in small steps and is much more smooth/stable than the latter.
+	 */
+	unsigned long dirty_ratelimit;
+	unsigned long balanced_dirty_ratelimit;
+
+	struct fprop_local_percpu completions;
+	int dirty_exceeded;
+
+	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
+	struct list_head work_list;
+	struct delayed_work dwork;	/* work item used for writeback */
+};
+
+struct backing_dev_info {
+	struct list_head bdi_list;
+	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
+	unsigned int capabilities; /* Device capabilities */
+	congested_fn *congested_fn; /* Function pointer if device is md/dm */
+	void *congested_data;	/* Pointer to aux data for congested func */
+
+	char *name;
+
+	unsigned int min_ratio;
+	unsigned int max_ratio, max_prop_frac;
+
+	struct bdi_writeback wb;  /* default writeback info for this bdi */
+
+	struct device *dev;
+
+	struct timer_list laptop_mode_wb_timer;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *debug_dir;
+	struct dentry *debug_stats;
+#endif
+};
+
+enum {
+	BLK_RW_ASYNC	= 0,
+	BLK_RW_SYNC	= 1,
+};
+
+void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
+void set_bdi_congested(struct backing_dev_info *bdi, int sync);
+
+#endif	/* __LINUX_BACKING_DEV_DEFS_H */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 6aba0d3..918f5c9 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -8,103 +8,12 @@
 #ifndef _LINUX_BACKING_DEV_H
 #define _LINUX_BACKING_DEV_H
 
-#include <linux/percpu_counter.h>
-#include <linux/log2.h>
-#include <linux/flex_proportions.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
-#include <linux/timer.h>
 #include <linux/writeback.h>
-#include <linux/atomic.h>
-#include <linux/sysctl.h>
-#include <linux/workqueue.h>
 
-struct page;
-struct device;
-struct dentry;
-
-/*
- * Bits in bdi_writeback.state
- */
-enum wb_state {
-	WB_async_congested,	/* The async (write) queue is getting full */
-	WB_sync_congested,	/* The sync queue is getting full */
-	WB_registered,		/* bdi_register() was done */
-	WB_writeback_running,	/* Writeback is in progress */
-};
-
-typedef int (congested_fn)(void *, int);
-
-enum wb_stat_item {
-	WB_RECLAIMABLE,
-	WB_WRITEBACK,
-	WB_DIRTIED,
-	WB_WRITTEN,
-	NR_WB_STAT_ITEMS
-};
-
-#define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
-
-struct bdi_writeback {
-	struct backing_dev_info *bdi;	/* our parent bdi */
-
-	unsigned long state;		/* Always use atomic bitops on this */
-	unsigned long last_old_flush;	/* last old data flush */
-
-	struct list_head b_dirty;	/* dirty inodes */
-	struct list_head b_io;		/* parked for writeback */
-	struct list_head b_more_io;	/* parked for more writeback */
-	spinlock_t list_lock;		/* protects the b_* lists */
-
-	struct percpu_counter stat[NR_WB_STAT_ITEMS];
-
-	unsigned long bw_time_stamp;	/* last time write bw is updated */
-	unsigned long dirtied_stamp;
-	unsigned long written_stamp;	/* pages written at bw_time_stamp */
-	unsigned long write_bandwidth;	/* the estimated write bandwidth */
-	unsigned long avg_write_bandwidth; /* further smoothed write bw */
-
-	/*
-	 * The base dirty throttle rate, re-calculated on every 200ms.
-	 * All the bdi tasks' dirty rate will be curbed under it.
-	 * @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit
-	 * in small steps and is much more smooth/stable than the latter.
-	 */
-	unsigned long dirty_ratelimit;
-	unsigned long balanced_dirty_ratelimit;
-
-	struct fprop_local_percpu completions;
-	int dirty_exceeded;
-
-	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
-	struct list_head work_list;
-	struct delayed_work dwork;	/* work item used for writeback */
-};
-
-struct backing_dev_info {
-	struct list_head bdi_list;
-	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
-	unsigned int capabilities; /* Device capabilities */
-	congested_fn *congested_fn; /* Function pointer if device is md/dm */
-	void *congested_data;	/* Pointer to aux data for congested func */
-
-	char *name;
-
-	unsigned int min_ratio;
-	unsigned int max_ratio, max_prop_frac;
-
-	struct bdi_writeback wb;  /* default writeback info for this bdi */
-
-	struct device *dev;
-
-	struct timer_list laptop_mode_wb_timer;
-
-#ifdef CONFIG_DEBUG_FS
-	struct dentry *debug_dir;
-	struct dentry *debug_stats;
-#endif
-};
+#include <linux/backing-dev-defs.h>
 
 int __must_check bdi_init(struct backing_dev_info *bdi);
 void bdi_destroy(struct backing_dev_info *bdi);
@@ -291,13 +200,6 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
 				  (1 << WB_async_congested));
 }
 
-enum {
-	BLK_RW_ASYNC	= 0,
-	BLK_RW_SYNC	= 1,
-};
-
-void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
-void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
 long wait_iff_congested(struct zone *zone, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 7dca161..fc980a6 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -12,7 +12,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/pagemap.h>
-#include <linux/backing-dev.h>
+#include <linux/backing-dev-defs.h>
 #include <linux/wait.h>
 #include <linux/mempool.h>
 #include <linux/bio.h>
diff --git a/mm/madvise.c b/mm/madvise.c
index 6fc9b82..1edaffc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -17,6 +17,7 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
