Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 983B4280244
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 05:46:34 -0400 (EDT)
Received: by padck2 with SMTP id ck2so16101722pad.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:34 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id r11si18536272pdj.220.2015.07.11.02.46.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 02:46:33 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so65099582pdr.2
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:33 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/3] zram: make compact a read-write sysfs node
Date: Sat, 11 Jul 2015 18:45:31 +0900
Message-Id: <1436607932-7116-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Change zram's `compact' sysfs node to be a read-write attribute.
Write triggers zsmalloc compaction, just as before, read returns
the number of pages that zsmalloc can potentially compact.

User space now has a chance to estimate possible compaction memory
savings and avoid unnecessary compactions.

Example:

  if [ `cat /sys/block/zram<id>/compact` -gt 10 ]; then
      echo 1 > /sys/block/zram<id>/compact;
  fi

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/ABI/testing/sysfs-block-zram |  7 ++++---
 Documentation/blockdev/zram.txt            |  4 +++-
 drivers/block/zram/zram_drv.c              | 16 +++++++++++++++-
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
index 2e69e83..0093998 100644
--- a/Documentation/ABI/testing/sysfs-block-zram
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -146,9 +146,10 @@ What:		/sys/block/zram<id>/compact
 Date:		August 2015
 Contact:	Minchan Kim <minchan@kernel.org>
 Description:
-		The compact file is write-only and trigger compaction for
-		allocator zrm uses. The allocator moves some objects so that
-		it could free fragment space.
+		The compact file is read/write. Write triggers underlying
+		allocator's memory compaction, which may result in memory
+		savings. Read returns the number of pages that compaction
+		can potentially (but not guaranteed to) free.
 
 What:		/sys/block/zram<id>/io_stat
 Date:		August 2015
diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index 62435bb..1854f62 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -146,7 +146,9 @@ mem_limit         RW    the maximum amount of memory ZRAM can use to store
                         the compressed data
 pages_compacted   RO    the number of pages freed during compaction
                         (available only via zram<id>/mm_stat node)
-compact           WO    trigger memory compaction
+compact           RW    write triggers memory compaction, read shows how many
+                        pages can potentially (but not necessarily will) be
+                        compacted
 
 WARNING
 =======
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index f5ef9e0..def9b8a 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -404,6 +404,20 @@ static ssize_t compact_store(struct device *dev,
 	return len;
 }
 
+static ssize_t compact_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+	unsigned long num_pages = 0;
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		num_pages = zs_pages_to_compact(zram->meta->mem_pool);
+	up_read(&zram->init_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", num_pages);
+}
+
 static ssize_t io_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -1145,7 +1159,7 @@ static const struct block_device_operations zram_devops = {
 	.owner = THIS_MODULE
 };
 
-static DEVICE_ATTR_WO(compact);
+static DEVICE_ATTR_RW(compact);
 static DEVICE_ATTR_RW(disksize);
 static DEVICE_ATTR_RO(initstate);
 static DEVICE_ATTR_WO(reset);
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
