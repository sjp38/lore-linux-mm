Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E12AB6B0037
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 20:26:52 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so13019392pad.35
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 17:26:52 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id mt7si21960840pbb.227.2014.08.20.17.26.49
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 17:26:51 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 3/4] zram: zram memory size limitation
Date: Thu, 21 Aug 2014 09:27:17 +0900
Message-Id: <1408580838-29236-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1408580838-29236-1-git-send-email-minchan@kernel.org>
References: <1408580838-29236-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com, Minchan Kim <minchan@kernel.org>

Since zram has no control feature to limit memory usage,
it makes hard to manage system memrory.

This patch adds new knob "mem_limit" via sysfs to set up the
a limit so that zram could fail allocation once it reaches
the limit.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/ABI/testing/sysfs-block-zram |  9 +++++++
 Documentation/blockdev/zram.txt            | 20 ++++++++++++---
 drivers/block/zram/zram_drv.c              | 41 ++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h              |  5 ++++
 4 files changed, 71 insertions(+), 4 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index 70ec992514d0..025331c19045 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -119,3 +119,12 @@ Description:
 		efficiency can be calculated using compr_data_size and this
 		statistic.
 		Unit: bytes
+
+What:		/sys/block/zram<id>/mem_limit
+Date:		August 2014
+Contact:	Minchan Kim <minchan@kernel.org>
+Description:
+		The mem_limit file is read/write and specifies the amount
+		of memory to be able to consume memory to store store
+		compressed data.
+		Unit: bytes
diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index 0595c3f56ccf..9f239ff8c444 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -74,14 +74,26 @@ There is little point creating a zram of greater than twice the size of memory
 since we expect a 2:1 compression ratio. Note that zram uses about 0.1% of the
 size of the disk when not in use so a huge zram is wasteful.
 
-5) Activate:
+5) Set memory limit: Optional
+	Set memory limit by writing the value to sysfs node 'mem_limit'.
+	The value can be either in bytes or you can use mem suffixes.
+	Examples:
+	    # limit /dev/zram0 with 50MB memory
+	    echo $((50*1024*1024)) > /sys/block/zram0/mem_limit
+
+	    # Using mem suffixes
+	    echo 256K > /sys/block/zram0/mem_limit
+	    echo 512M > /sys/block/zram0/mem_limit
+	    echo 1G > /sys/block/zram0/mem_limit
+
+6) Activate:
 	mkswap /dev/zram0
 	swapon /dev/zram0
 
 	mkfs.ext4 /dev/zram1
 	mount /dev/zram1 /tmp
 
-6) Stats:
+7) Stats:
 	Per-device statistics are exported as various nodes under
 	/sys/block/zram<id>/
 		disksize
@@ -96,11 +108,11 @@ size of the disk when not in use so a huge zram is wasteful.
 		compr_data_size
 		mem_used_total
 
-7) Deactivate:
+8) Deactivate:
 	swapoff /dev/zram0
 	umount /dev/zram1
 
-8) Reset:
+9) Reset:
 	Write any positive value to 'reset' sysfs node
 	echo 1 > /sys/block/zram0/reset
 	echo 1 > /sys/block/zram1/reset
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 302dd37bcea3..adc91c7ecaef 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -122,6 +122,33 @@ static ssize_t max_comp_streams_show(struct device *dev,
 	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
 }
 
+static ssize_t mem_limit_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	u64 val;
+	struct zram *zram = dev_to_zram(dev);
+
+	down_read(&zram->init_lock);
+	val = zram->limit_pages;
+	up_read(&zram->init_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
+}
+
+static ssize_t mem_limit_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	u64 limit;
+	struct zram *zram = dev_to_zram(dev);
+
+	limit = memparse(buf, NULL);
+	down_write(&zram->init_lock);
+	zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
+	up_write(&zram->init_lock);
+
+	return len;
+}
+
 static ssize_t max_comp_streams_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
@@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		ret = -ENOMEM;
 		goto out;
 	}
+
+	if (zram->limit_pages &&
+		zs_get_total_size(meta->mem_pool) > zram->limit_pages) {
+		zs_free(meta->mem_pool, handle);
+		ret = -ENOMEM;
+		goto out;
+	}
+
 	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
 
 	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
@@ -617,6 +652,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	struct zram_meta *meta;
 
 	down_write(&zram->init_lock);
+
+	zram->limit_pages = 0;
+
 	if (!init_done(zram)) {
 		up_write(&zram->init_lock);
 		return;
@@ -857,6 +895,8 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
 static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
 static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
 static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
+static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
+		mem_limit_store);
 static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
 		max_comp_streams_show, max_comp_streams_store);
 static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
@@ -885,6 +925,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_orig_data_size.attr,
 	&dev_attr_compr_data_size.attr,
 	&dev_attr_mem_used_total.attr,
+	&dev_attr_mem_limit.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
 	NULL,
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index e0f725c87cc6..b7aa9c21553f 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -112,6 +112,11 @@ struct zram {
 	u64 disksize;	/* bytes */
 	int max_comp_streams;
 	struct zram_stats stats;
+	/*
+	 * the number of pages zram can consume for storing compressed data
+	 */
+	unsigned long limit_pages;
+
 	char compressor[10];
 };
 #endif
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
