Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 282476B006E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 00:58:32 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id fp1so6556960pdb.2
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 21:58:31 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pz1si611060pdb.159.2015.01.22.21.58.26
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 21:58:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] zram: protect zram->stat race with init_lock
Date: Fri, 23 Jan 2015 14:58:27 +0900
Message-Id: <1421992707-32658-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1421992707-32658-1-git-send-email-minchan@kernel.org>
References: <1421992707-32658-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

The zram->stat handling should be procted by init_lock.
Otherwise, user could see stale value from the stat.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---

I don't think it's stable material. The race is rare in real practice
and this stale stat value read is not a critical.

 drivers/block/zram/zram_drv.c | 37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0299d82275e7..53f176f590b0 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -48,8 +48,13 @@ static ssize_t name##_show(struct device *d,		\
 				struct device_attribute *attr, char *b)	\
 {									\
 	struct zram *zram = dev_to_zram(d);				\
-	return scnprintf(b, PAGE_SIZE, "%llu\n",			\
-		(u64)atomic64_read(&zram->stats.name));			\
+	u64 val = 0;							\
+									\
+	down_read(&zram->init_lock);					\
+	if (init_done(zram))						\
+		val = atomic64_read(&zram->stats.name);			\
+	up_read(&zram->init_lock);					\
+	return scnprintf(b, PAGE_SIZE, "%llu\n", val);			\
 }									\
 static DEVICE_ATTR_RO(name);
 
@@ -67,8 +72,14 @@ static ssize_t disksize_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
+	u64 val = 0;
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		val = zram->disksize;
+	up_read(&zram->init_lock);
 
-	return scnprintf(buf, PAGE_SIZE, "%llu\n", zram->disksize);
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
 }
 
 static ssize_t initstate_show(struct device *dev,
@@ -88,9 +99,14 @@ static ssize_t orig_data_size_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
+	u64 val = 0;
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		val = atomic64_read(&zram->stats.pages_stored) << PAGE_SHIFT;
+	up_read(&zram->init_lock);
 
-	return scnprintf(buf, PAGE_SIZE, "%llu\n",
-		(u64)(atomic64_read(&zram->stats.pages_stored)) << PAGE_SHIFT);
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
 }
 
 static ssize_t mem_used_total_show(struct device *dev,
@@ -957,10 +973,6 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	struct bio_vec bv;
 
 	zram = bdev->bd_disk->private_data;
-	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
-		atomic64_inc(&zram->stats.invalid_io);
-		return -EINVAL;
-	}
 
 	down_read(&zram->init_lock);
 	if (unlikely(!init_done(zram))) {
@@ -968,6 +980,13 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 		goto out_unlock;
 	}
 
+	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
+		atomic64_inc(&zram->stats.invalid_io);
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
+
 	index = sector >> SECTORS_PER_PAGE_SHIFT;
 	offset = sector & (SECTORS_PER_PAGE - 1) << SECTOR_SHIFT;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
