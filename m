Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EC939600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 13:27:19 -0400 (EDT)
Received: by mail-fx0-f41.google.com with SMTP id 3so191513fxm.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 10:27:18 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 06/10] Block discard support
Date: Mon,  9 Aug 2010 22:56:52 +0530
Message-Id: <1281374816-904-7-git-send-email-ngupta@vflare.org>
In-Reply-To: <1281374816-904-1-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>
Cc: Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The 'discard' bio discard request provides information to
zram disks regarding blocks which are no longer in use by
filesystem. This allows freeing memory allocated for such
blocks.

When zram devices are used as swap disks, we already have
a callback (block_device_operations->swap_slot_free_notify).
So, the discard support is useful only when used as generic
(non-swap) disk.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 drivers/staging/zram/zram_drv.c   |   25 +++++++++++++++++++++++++
 drivers/staging/zram/zram_sysfs.c |   11 +++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index efe9c93..0f9785f 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -420,6 +420,20 @@ out:
 	return 0;
 }
 
+static void zram_discard(struct zram *zram, struct bio *bio)
+{
+	size_t bytes = bio->bi_size;
+	sector_t sector = bio->bi_sector;
+
+	while (bytes >= PAGE_SIZE) {
+		zram_free_page(zram, sector >> SECTORS_PER_PAGE_SHIFT);
+		sector += PAGE_SIZE >> SECTOR_SHIFT;
+		bytes -= PAGE_SIZE;
+	}
+
+	bio_endio(bio, 0);
+}
+
 /*
  * Check if request is within bounds and page aligned.
  */
@@ -451,6 +465,12 @@ static int zram_make_request(struct request_queue *queue, struct bio *bio)
 		return 0;
 	}
 
+	if (unlikely(bio_rw_flagged(bio, BIO_RW_DISCARD))) {
+		zram_inc_stat(zram, ZRAM_STAT_DISCARD);
+		zram_discard(zram, bio);
+		return 0;
+	}
+
 	switch (bio_data_dir(bio)) {
 	case READ:
 		ret = zram_read(zram, bio);
@@ -606,6 +626,11 @@ static int create_device(struct zram *zram, int device_id)
 	blk_queue_io_min(zram->disk->queue, PAGE_SIZE);
 	blk_queue_io_opt(zram->disk->queue, PAGE_SIZE);
 
+	zram->disk->queue->limits.discard_granularity = PAGE_SIZE;
+	zram->disk->queue->limits.max_discard_sectors = UINT_MAX;
+	zram->disk->queue->limits.discard_zeroes_data = 1;
+	queue_flag_set_unlocked(QUEUE_FLAG_DISCARD, zram->queue);
+
 	add_disk(zram->disk);
 
 #ifdef CONFIG_SYSFS
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index 43bcdd4..74971c0 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -165,6 +165,15 @@ static ssize_t notify_free_show(struct device *dev,
 		zram_get_stat(zram, ZRAM_STAT_NOTIFY_FREE));
 }
 
+static ssize_t discard_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return sprintf(buf, "%llu\n",
+		zram_get_stat(zram, ZRAM_STAT_DISCARD));
+}
+
 static ssize_t zero_pages_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -215,6 +224,7 @@ static DEVICE_ATTR(num_reads, S_IRUGO, num_reads_show, NULL);
 static DEVICE_ATTR(num_writes, S_IRUGO, num_writes_show, NULL);
 static DEVICE_ATTR(invalid_io, S_IRUGO, invalid_io_show, NULL);
 static DEVICE_ATTR(notify_free, S_IRUGO, notify_free_show, NULL);
+static DEVICE_ATTR(discard, S_IRUGO, discard_show, NULL);
 static DEVICE_ATTR(zero_pages, S_IRUGO, zero_pages_show, NULL);
 static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
 static DEVICE_ATTR(compr_data_size, S_IRUGO, compr_data_size_show, NULL);
@@ -228,6 +238,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_num_writes.attr,
 	&dev_attr_invalid_io.attr,
 	&dev_attr_notify_free.attr,
+	&dev_attr_discard.attr,
 	&dev_attr_zero_pages.attr,
 	&dev_attr_orig_data_size.attr,
 	&dev_attr_compr_data_size.attr,
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
