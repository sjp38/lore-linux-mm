Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5366B0075
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:14:54 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so50843895pad.1
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:14:54 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id up2si7319818pac.178.2015.01.20.22.14.37
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:38 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 08/10] zram: support compaction
Date: Wed, 21 Jan 2015 15:14:24 +0900
Message-Id: <1421820866-26521-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1421820866-26521-1-git-send-email-minchan@kernel.org>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

Now that zsmalloc supports compaction, zram can use it.
For the first step, this patch exports compact knob via sysfs
so user can do compaction via "echo 1 > /sys/block/zram0/compact".

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/ABI/testing/sysfs-block-zram |  8 ++++++++
 drivers/block/zram/zram_drv.c              | 25 +++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h              |  1 +
 3 files changed, 34 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index a6148ea..91ad707 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -141,3 +141,11 @@ Description:
 		amount of memory ZRAM can use to store the compressed data.  The
 		limit could be changed in run time and "0" means disable the
 		limit.  No limit is the initial state.  Unit: bytes
+
+What:		/sys/block/zram<id>/compact
+Date:		August 2015
+Contact:	Minchan Kim <minchan@kernel.org>
+Description:
+		The compact file is write-only and trigger compaction for
+		allocator zrm uses. The allocator moves some objects so that
+		it could free fragment space.
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 7e03d86..7ac8dae 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -246,6 +246,27 @@ static ssize_t comp_algorithm_store(struct device *dev,
 	return len;
 }
 
+static ssize_t compact_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	unsigned long nr_migrated;
+	struct zram *zram = dev_to_zram(dev);
+	struct zram_meta *meta;
+
+	down_read(&zram->init_lock);
+	if (!init_done(zram)) {
+		up_read(&zram->init_lock);
+		return -EINVAL;
+	}
+
+	meta = zram->meta;
+	nr_migrated = zs_compact(meta->mem_pool);
+	atomic64_add(nr_migrated, &zram->stats.num_migrated);
+	up_read(&zram->init_lock);
+
+	return len;
+}
+
 /* flag operations needs meta->tb_lock */
 static int zram_test_flag(struct zram_meta *meta, u32 index,
 			enum zram_pageflags flag)
@@ -994,6 +1015,7 @@ static const struct block_device_operations zram_devops = {
 	.owner = THIS_MODULE
 };
 
+static DEVICE_ATTR_WO(compact);
 static DEVICE_ATTR_RW(disksize);
 static DEVICE_ATTR_RO(initstate);
 static DEVICE_ATTR_WO(reset);
@@ -1012,6 +1034,7 @@ ZRAM_ATTR_RO(invalid_io);
 ZRAM_ATTR_RO(notify_free);
 ZRAM_ATTR_RO(zero_pages);
 ZRAM_ATTR_RO(compr_data_size);
+ZRAM_ATTR_RO(num_migrated);
 
 static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_disksize.attr,
@@ -1021,6 +1044,8 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_num_writes.attr,
 	&dev_attr_failed_reads.attr,
 	&dev_attr_failed_writes.attr,
+	&dev_attr_num_migrated.attr,
+	&dev_attr_compact.attr,
 	&dev_attr_invalid_io.attr,
 	&dev_attr_notify_free.attr,
 	&dev_attr_zero_pages.attr,
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816..5e7a565 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -84,6 +84,7 @@ struct zram_stats {
 	atomic64_t compr_data_size;	/* compressed size of pages stored */
 	atomic64_t num_reads;	/* failed + successful */
 	atomic64_t num_writes;	/* --do-- */
+	atomic64_t num_migrated;	/* no. of migrated object */
 	atomic64_t failed_reads;	/* can happen when memory is too low */
 	atomic64_t failed_writes;	/* can happen when memory is too low */
 	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
