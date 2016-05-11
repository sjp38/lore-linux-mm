Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2996B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 08:48:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so83009373pfb.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:48:26 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id z6si9731184paa.60.2016.05.11.05.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 05:48:25 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id r187so4410098pfr.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 05:48:25 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] zram: introduce per-device debug_stat sysfs node
Date: Wed, 11 May 2016 22:45:53 +0900
Message-Id: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

debug_stat sysfs is read-only and represents various debugging
data that zram developers may need. This file is not meant to be
used by anyone else: its content is not documented and will change
any time w/o any notice. Therefore, the output of debug_stat file
contains a version string. To reduce the possibility of contusion,
etc. we would increase the version number every time we modify
the output.

At the moment this file exports only one value -- the number of
re-compressions, IOW, the number of times compression fast path
has failed; which is a temporarily stats, that we will be using
should any per-cpu regressions happen. It's excepted to go away.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/ABI/testing/sysfs-block-zram |  7 +++++++
 Documentation/blockdev/zram.txt            |  1 +
 drivers/block/zram/zram_drv.c              | 21 +++++++++++++++++++++
 drivers/block/zram/zram_drv.h              |  1 +
 4 files changed, 30 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index 2e69e83..740aada 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -166,3 +166,10 @@ Description:
 		The mm_stat file is read-only and represents device's mm
 		statistics (orig_data_size, compr_data_size, etc.) in a format
 		similar to block layer statistics file format.
+
+What:		/sys/block/zram<id>/debug_stat
+Date:		July 2016
+Contact:	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
+Description:
+		The debug_stat file is read-only and represents various
+		device's debugging info.
diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index d88f0c7..13100fb 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -172,6 +172,7 @@ mem_limit         RW    the maximum amount of memory ZRAM can use to store
 pages_compacted   RO    the number of pages freed during compaction
                         (available only via zram<id>/mm_stat node)
 compact           WO    trigger memory compaction
+debug_stat        RO    this file is used for zram debugging purposes
 
 WARNING
 =======
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 8fcfbeb..a629bd8d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -435,8 +435,26 @@ static ssize_t mm_stat_show(struct device *dev,
 	return ret;
 }
 
+static ssize_t debug_stat_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	unsigned int version = 1;
+	struct zram *zram = dev_to_zram(dev);
+	ssize_t ret;
+
+	down_read(&zram->init_lock);
+	ret = scnprintf(buf, PAGE_SIZE,
+			"version: %d\n%8llu\n",
+			version,
+			(u64)atomic64_read(&zram->stats.num_recompress));
+	up_read(&zram->init_lock);
+
+	return ret;
+}
+
 static DEVICE_ATTR_RO(io_stat);
 static DEVICE_ATTR_RO(mm_stat);
+static DEVICE_ATTR_RO(debug_stat);
 ZRAM_ATTR_RO(num_reads);
 ZRAM_ATTR_RO(num_writes);
 ZRAM_ATTR_RO(failed_reads);
@@ -719,6 +737,8 @@ compress_again:
 		zcomp_strm_release(zram->comp, zstrm);
 		zstrm = NULL;
 
+		atomic64_inc(&zram->stats.num_recompress);
+
 		handle = zs_malloc(meta->mem_pool, clen,
 				GFP_NOIO | __GFP_HIGHMEM);
 		if (handle)
@@ -1181,6 +1201,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_comp_algorithm.attr,
 	&dev_attr_io_stat.attr,
 	&dev_attr_mm_stat.attr,
+	&dev_attr_debug_stat.attr,
 	NULL,
 };
 
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 06b1636..1fb45f7 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -85,6 +85,7 @@ struct zram_stats {
 	atomic64_t zero_pages;		/* no. of zero filled pages */
 	atomic64_t pages_stored;	/* no. of pages currently stored */
 	atomic_long_t max_used_pages;	/* no. of maximum pages stored */
+	atomic64_t num_recompress;	/* no. of compression slow paths */
 };
 
 struct zram_meta {
-- 
2.8.2.372.g63a3502

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
