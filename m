Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 790496B03E7
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 19:36:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so604897721pgq.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:36:28 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w126si3838367pgb.135.2016.12.21.16.36.26
        for <linux-mm@kvack.org>;
        Wed, 21 Dec 2016 16:36:27 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 3/3] zram: support BDI_CAP_STABLE_WRITES
Date: Thu, 22 Dec 2016 09:36:20 +0900
Message-Id: <1482366980-3782-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1482366980-3782-1-git-send-email-minchan@kernel.org>
References: <1482366980-3782-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "[4.7+]" <stable@vger.kernel.org>

zram has used per-cpu stream feature from v4.7.
It aims for increasing cache hit ratio of scratch buffer for
compressing. Downside of that approach is that zram should ask
memory space for compressed page in per-cpu context which requires
stricted gfp flag which could be failed. If so, it retries to
allocate memory space out of per-cpu context so it could get memory
this time and compress the data again, copies it to the memory space.

In this scenario, zram assumes the data should never be changed
but it is not true without stable page support. So, If the data is
changed under us, zram can make buffer overrun so that zsmalloc
free object chain is broken so system goes crash like below
https://bugzilla.suse.com/show_bug.cgi?id=997574

This patch adds BDI_CAP_STABLE_WRITES to zram for declaring
"I am block device needing *stable write*".

Fixes: da9556a2367c ("zram: user per-cpu compression streams")
Cc: <stable@vger.kernel.org> [4.7+]
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
* from v3
 * add comment why we should set BDI_CAP_STABLE_WRITES again

 drivers/block/zram/zram_drv.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 195376b4472b..e5ab7d9e8c45 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -25,6 +25,7 @@
 #include <linux/genhd.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/backing-dev.h>
 #include <linux/string.h>
 #include <linux/vmalloc.h>
 #include <linux/err.h>
@@ -112,6 +113,14 @@ static inline bool is_partial_io(struct bio_vec *bvec)
 	return bvec->bv_len != PAGE_SIZE;
 }
 
+static void zram_revalidate_disk(struct zram *zram)
+{
+	revalidate_disk(zram->disk);
+	/* revalidate_disk reset the BDI_CAP_STABLE_WRITES so set again */
+	zram->disk->queue->backing_dev_info.capabilities |=
+		BDI_CAP_STABLE_WRITES;
+}
+
 /*
  * Check if request is within bounds and aligned on zram logical blocks.
  */
@@ -1095,7 +1104,7 @@ static ssize_t disksize_store(struct device *dev,
 	zram->comp = comp;
 	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	revalidate_disk(zram->disk);
+	zram_revalidate_disk(zram);
 	up_write(&zram->init_lock);
 
 	return len;
@@ -1143,7 +1152,7 @@ static ssize_t reset_store(struct device *dev,
 	/* Make sure all the pending I/O are finished */
 	fsync_bdev(bdev);
 	zram_reset_device(zram);
-	revalidate_disk(zram->disk);
+	zram_revalidate_disk(zram);
 	bdput(bdev);
 
 	mutex_lock(&bdev->bd_mutex);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
