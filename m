Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 061796B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 00:58:27 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so6493264pad.7
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 21:58:26 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qn8si681422pab.101.2015.01.22.21.58.22
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 21:58:26 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] zram: free meta out of init_lock
Date: Fri, 23 Jan 2015 14:58:26 +0900
Message-Id: <1421992707-32658-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

We don't need to call zram_meta_free, zcomp_destroy and zs_free
under init_lock. What we need to prevent race with init_lock
in reset is setting NULL into zram->meta (ie, init_done).
This patch does it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9250b3f54a8f..0299d82275e7 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 {
 	size_t index;
 	struct zram_meta *meta;
+	struct zcomp *comp;
 
 	down_write(&zram->init_lock);
 
@@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	}
 
 	meta = zram->meta;
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = meta->table[index].handle;
-		if (!handle)
-			continue;
-
-		zs_free(meta->mem_pool, handle);
-	}
-
-	zcomp_destroy(zram->comp);
+	comp = zram->comp;
+	zram->meta = NULL;
 	zram->max_comp_streams = 1;
 
-	zram_meta_free(zram->meta);
-	zram->meta = NULL;
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
 
@@ -742,6 +733,19 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 
 	up_write(&zram->init_lock);
 
+	/* Free all pages that are still in this zram device */
+	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
+		unsigned long handle = meta->table[index].handle;
+
+		if (!handle)
+			continue;
+
+		zs_free(meta->mem_pool, handle);
+	}
+
+	zcomp_destroy(comp);
+	zram_meta_free(meta);
+
 	/*
 	 * Revalidate disk out of the init_lock to avoid lockdep splat.
 	 * It's okay because disk's capacity is protected by init_lock
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
