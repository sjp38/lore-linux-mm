Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E10826B0039
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 03:54:38 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so9431429pad.7
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 00:54:36 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id bb14si25566971pdb.239.2014.08.19.00.54.31
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 00:54:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/4] zram: report maximum used memory
Date: Tue, 19 Aug 2014 16:54:47 +0900
Message-Id: <1408434887-16387-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1408434887-16387-1-git-send-email-minchan@kernel.org>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com, Minchan Kim <minchan@kernel.org>

Normally, zram user could get maximum memory usage zram consumed
via polling mem_used_total with sysfs in userspace.

But it has a critical problem because user can miss peak memory
usage during update inverval of polling. For avoiding that,
user should poll it with shorter interval(ie, 0.0000000001s)
with mlocking to avoid page fault delay when memory pressure
is heavy. It would be troublesome.

This patch adds new knob "mem_used_max" so user could see
the maximum memory usage easily via reading the knob and reset
it via "echo 0 > /sys/block/zram0/mem_used_max".

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/ABI/testing/sysfs-block-zram | 10 +++++
 Documentation/blockdev/zram.txt            |  1 +
 drivers/block/zram/zram_drv.c              | 60 +++++++++++++++++++++++++++++-
 drivers/block/zram/zram_drv.h              |  1 +
 4 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index 025331c19045..ffd1ea7443dd 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -120,6 +120,16 @@ Description:
 		statistic.
 		Unit: bytes
 
+What:		/sys/block/zram<id>/mem_used_max
+Date:		August 2014
+Contact:	Minchan Kim <minchan@kernel.org>
+Description:
+		The mem_used_max file is read/write and specifies the amount
+		of maximum memory zram have consumed to store compressed data.
+		For resetting the value, you should do "echo 0". Otherwise,
+		you could see -EINVAL.
+		Unit: bytes
+
 What:		/sys/block/zram<id>/mem_limit
 Date:		August 2014
 Contact:	Minchan Kim <minchan@kernel.org>
diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index 9f239ff8c444..3b2247c2d4cf 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -107,6 +107,7 @@ size of the disk when not in use so a huge zram is wasteful.
 		orig_data_size
 		compr_data_size
 		mem_used_total
+		mem_used_max
 
 8) Deactivate:
 	swapoff /dev/zram0
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index adc91c7ecaef..e4d44842a91d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -149,6 +149,40 @@ static ssize_t mem_limit_store(struct device *dev,
 	return len;
 }
 
+static ssize_t mem_used_max_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	u64 val = 0;
+	struct zram *zram = dev_to_zram(dev);
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		val = atomic64_read(&zram->stats.max_used_pages);
+	up_read(&zram->init_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
+}
+
+static ssize_t mem_used_max_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	u64 limit;
+	struct zram *zram = dev_to_zram(dev);
+	struct zram_meta *meta = zram->meta;
+
+	limit = memparse(buf, NULL);
+	if (0 != limit)
+		return -EINVAL;
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		atomic64_set(&zram->stats.max_used_pages,
+				zs_get_total_size(meta->mem_pool));
+	up_read(&zram->init_lock);
+
+	return len;
+}
+
 static ssize_t max_comp_streams_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
@@ -461,6 +495,26 @@ out_cleanup:
 	return ret;
 }
 
+static bool check_limit(struct zram *zram)
+{
+	unsigned long alloced_pages;
+	u64 old_max, cur_max;
+	struct zram_meta *meta = zram->meta;
+
+	do {
+		alloced_pages = zs_get_total_size(meta->mem_pool);
+		if (zram->limit_pages && alloced_pages > zram->limit_pages)
+			return false;
+
+		old_max = cur_max = atomic64_read(&zram->stats.max_used_pages);
+		if (alloced_pages > cur_max)
+			old_max = atomic64_cmpxchg(&zram->stats.max_used_pages,
+					cur_max, alloced_pages);
+	} while (old_max != cur_max);
+
+	return true;
+}
+
 static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			   int offset)
 {
@@ -541,8 +595,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		goto out;
 	}
 
-	if (zram->limit_pages &&
-		zs_get_total_size(meta->mem_pool) > zram->limit_pages) {
+	if (!check_limit(zram)) {
 		zs_free(meta->mem_pool, handle);
 		ret = -ENOMEM;
 		goto out;
@@ -897,6 +950,8 @@ static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
 static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
 static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
 		mem_limit_store);
+static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
+		mem_used_max_store);
 static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
 		max_comp_streams_show, max_comp_streams_store);
 static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
@@ -926,6 +981,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_compr_data_size.attr,
 	&dev_attr_mem_used_total.attr,
 	&dev_attr_mem_limit.attr,
+	&dev_attr_mem_used_max.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
 	NULL,
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b7aa9c21553f..29383312d543 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -90,6 +90,7 @@ struct zram_stats {
 	atomic64_t notify_free;	/* no. of swap slot free notifications */
 	atomic64_t zero_pages;		/* no. of zero filled pages */
 	atomic64_t pages_stored;	/* no. of pages currently stored */
+	atomic64_t max_used_pages;	/* no. of maximum pages stored */
 };
 
 struct zram_meta {
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
