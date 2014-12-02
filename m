Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A35616B0072
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:15 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so12427130pac.11
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:15 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id qy3si31729464pab.12.2014.12.01.18.50.09
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 6/6] zram: support compaction
Date: Tue,  2 Dec 2014 11:49:47 +0900
Message-Id: <1417488587-28609-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

Now that zsmalloc supports compaction, zram can use it.
For the first step, this patch exports compact knob via sysfs
so user can do compaction via "echo 1 > /sys/block/zram0/compact".

Maybe, we need another knob to trigger compaction automatically
once the amount of fragment is higher than the ratio.

echo "fragment_ratio" > /sys/block/zram0/compact_based_on_the_ratio

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 24 ++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h |  1 +
 2 files changed, 25 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 976eab6f35b9..53c110b289fc 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -247,6 +247,26 @@ static ssize_t comp_algorithm_store(struct device *dev,
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
+	up_read(&zram->init_lock);
+	atomic64_add(nr_migrated, &zram->stats.num_migrated);
+	return len;
+}
+
 /* flag operations needs meta->tb_lock */
 static int zram_test_flag(struct zram_meta *meta, u32 index,
 			enum zram_pageflags flag)
@@ -1008,6 +1028,7 @@ static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
 		max_comp_streams_show, max_comp_streams_store);
 static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
 		comp_algorithm_show, comp_algorithm_store);
+static DEVICE_ATTR(compact, S_IWUSR, NULL, compact_store);
 
 ZRAM_ATTR_RO(num_reads);
 ZRAM_ATTR_RO(num_writes);
@@ -1017,6 +1038,7 @@ ZRAM_ATTR_RO(invalid_io);
 ZRAM_ATTR_RO(notify_free);
 ZRAM_ATTR_RO(zero_pages);
 ZRAM_ATTR_RO(compr_data_size);
+ZRAM_ATTR_RO(num_migrated);
 
 static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_disksize.attr,
@@ -1024,6 +1046,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_reset.attr,
 	&dev_attr_num_reads.attr,
 	&dev_attr_num_writes.attr,
+	&dev_attr_num_migrated.attr,
 	&dev_attr_failed_reads.attr,
 	&dev_attr_failed_writes.attr,
 	&dev_attr_invalid_io.attr,
@@ -1036,6 +1059,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_mem_used_max.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
+	&dev_attr_compact.attr,
 	NULL,
 };
 
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816b09ac..5e7a565808b9 100644
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
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
