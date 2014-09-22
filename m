Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 037D76B003B
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 20:02:45 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so3251354pdj.32
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 17:02:45 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id td1si13303519pbc.140.2014.09.21.17.02.41
        for <linux-mm@kvack.org>;
        Sun, 21 Sep 2014 17:02:43 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 5/5] zram: add fullness knob to control swap full
Date: Mon, 22 Sep 2014 09:03:11 +0900
Message-Id: <1411344191-2842-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1411344191-2842-1-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, Minchan Kim <minchan@kernel.org>

Some zram usecase could want lower fullness than default 80 to
avoid unnecessary swapout-and-fail-recover overhead.

A typical example is that mutliple swap with high piroirty
zram-swap and low priority HDD-swap so it could still enough
free swap space although one of swap devices is full(ie, zram).
It would be better to fail over to HDD-swap rather than failing
swap write to zram in this case.

This patch exports fullness to user so user can control it
via the knob.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++
 drivers/block/zram/zram_drv.c              | 38 +++++++++++++++++++++++++++++-
 drivers/block/zram/zram_drv.h              |  1 +
 3 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index b13dc993291f..817738d14061 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -138,3 +138,13 @@ Description:
 		amount of memory ZRAM can use to store the compressed data.  The
 		limit could be changed in run time and "0" means disable the
 		limit.  No limit is the initial state.  Unit: bytes
+
+What:		/sys/block/zram<id>/fullness
+Date:		August 2014
+Contact:	Minchan Kim <minchan@kernel.org>
+Description:
+		The fullness file is read/write and specifies how easily
+		zram become full state so if you set it to lower value,
+		zram can reach full state easily compared to higher value.
+		Curretnly, initial value is 80% but it could be changed.
+		Unit: Percentage
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 649cad9d0b1c..ec3656f6891d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -136,6 +136,37 @@ static ssize_t max_comp_streams_show(struct device *dev,
 	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
 }
 
+static ssize_t fullness_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	int val;
+	struct zram *zram = dev_to_zram(dev);
+
+	down_read(&zram->init_lock);
+	val = zram->fullness;
+	up_read(&zram->init_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
+}
+
+static ssize_t fullness_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	int err;
+	unsigned long val;
+	struct zram *zram = dev_to_zram(dev);
+
+	err = kstrtoul(buf, 10, &val);
+	if (err || val > 100)
+		return -EINVAL;
+
+	down_write(&zram->init_lock);
+	zram->fullness = val;
+	up_write(&zram->init_lock);
+
+	return len;
+}
+
 static ssize_t mem_limit_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -733,6 +764,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 
 	zram->limit_pages = 0;
 	atomic_set(&zram->alloc_fail, 0);
+	zram->fullness = ZRAM_FULLNESS_PERCENT;
 
 	if (!init_done(zram)) {
 		up_write(&zram->init_lock);
@@ -984,7 +1016,7 @@ static int zram_full(struct block_device *bdev, void *arg)
 		compr_pages = atomic64_read(&zram->stats.compr_data_size)
 					>> PAGE_SHIFT;
 		if ((100 * compr_pages / total_pages)
-			>= ZRAM_FULLNESS_PERCENT)
+			>= zram->fullness)
 			return 1;
 	}
 
@@ -1020,6 +1052,8 @@ static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
 static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
 static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
 		mem_limit_store);
+static DEVICE_ATTR(fullness, S_IRUGO | S_IWUSR, fullness_show,
+		fullness_store);
 static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
 		mem_used_max_store);
 static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
@@ -1051,6 +1085,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_compr_data_size.attr,
 	&dev_attr_mem_used_total.attr,
 	&dev_attr_mem_limit.attr,
+	&dev_attr_fullness.attr,
 	&dev_attr_mem_used_max.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
@@ -1132,6 +1167,7 @@ static int create_device(struct zram *zram, int device_id)
 	strlcpy(zram->compressor, default_compressor, sizeof(zram->compressor));
 	zram->meta = NULL;
 	zram->max_comp_streams = 1;
+	zram->fullness = ZRAM_FULLNESS_PERCENT;
 	return 0;
 
 out_free_disk:
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index fcf3176a9f15..6a9f383d0d78 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -119,6 +119,7 @@ struct zram {
 	 */
 	unsigned long limit_pages;
 
+	int fullness;
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
