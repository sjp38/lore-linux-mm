Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD746B0096
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so55640195pdb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:46 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id b7si8754523pbu.178.2015.05.29.08.06.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:45 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so62710205pab.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:45 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 09/10] zram: remove `num_migrated' from zram_stats
Date: Sat, 30 May 2015 00:05:27 +0900
Message-Id: <1432911928-14654-10-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

drop zram's copy of `num_migrated' objects and use zs_pool's
zs_get_num_migrated() instead.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c | 12 ++++++------
 drivers/block/zram/zram_drv.h |  1 -
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 28f6e46..31e45b4 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -385,7 +385,6 @@ static ssize_t comp_algorithm_store(struct device *dev,
 static ssize_t compact_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
-	unsigned long nr_migrated;
 	struct zram *zram = dev_to_zram(dev);
 	struct zram_meta *meta;
 
@@ -396,8 +395,7 @@ static ssize_t compact_store(struct device *dev,
 	}
 
 	meta = zram->meta;
-	nr_migrated = zs_compact(meta->mem_pool);
-	atomic64_add(nr_migrated, &zram->stats.num_migrated);
+	zs_compact(meta->mem_pool);
 	up_read(&zram->init_lock);
 
 	return len;
@@ -425,13 +423,15 @@ static ssize_t mm_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
-	u64 orig_size, mem_used = 0;
+	u64 orig_size, mem_used = 0, num_migrated = 0;
 	long max_used;
 	ssize_t ret;
 
 	down_read(&zram->init_lock);
-	if (init_done(zram))
+	if (init_done(zram)) {
 		mem_used = zs_get_total_pages(zram->meta->mem_pool);
+		num_migrated = zs_get_num_migrated(zram->meta->mem_pool);
+	}
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
 	max_used = atomic_long_read(&zram->stats.max_used_pages);
@@ -444,7 +444,7 @@ static ssize_t mm_stat_show(struct device *dev,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.zero_pages),
-			(u64)atomic64_read(&zram->stats.num_migrated));
+			num_migrated);
 	up_read(&zram->init_lock);
 
 	return ret;
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 6dbe2df..8e92339 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -78,7 +78,6 @@ struct zram_stats {
 	atomic64_t compr_data_size;	/* compressed size of pages stored */
 	atomic64_t num_reads;	/* failed + successful */
 	atomic64_t num_writes;	/* --do-- */
-	atomic64_t num_migrated;	/* no. of migrated object */
 	atomic64_t failed_reads;	/* can happen when memory is too low */
 	atomic64_t failed_writes;	/* can happen when memory is too low */
 	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
