Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4719E6B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:14:45 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so33761801pab.5
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:14:45 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id bw17si8418925pdb.34.2015.01.28.20.14.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 28 Jan 2015 20:14:44 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIX00H2J7SC5DD0@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Jan 2015 13:14:36 +0900 (KST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2] zram: free meta table in zram_meta_free
Date: Tue, 20 Jan 2015 07:43:47 +0800
Message-id: <1421711028-5553-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ganesh Mahendran <opensource.ganesh@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zram_meta_alloc() and zram_meta_free() are a pair.
In zram_meta_alloc(), meta table is allocated. So it it better to free
it in zram_meta_free().

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
v2: use zram->disksize to get num of pages - Sergey
---
 drivers/block/zram/zram_drv.c |   33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9250b3f..aa5a4c5 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -307,8 +307,21 @@ static inline int valid_io_request(struct zram *zram,
 	return 1;
 }
 
-static void zram_meta_free(struct zram_meta *meta)
+static void zram_meta_free(struct zram_meta *meta, u64 disksize)
 {
+	size_t num_pages = disksize >> PAGE_SHIFT;
+	size_t index;
+
+	/* Free all pages that are still in this zram device */
+	for (index = 0; index < num_pages; index++) {
+		unsigned long handle = meta->table[index].handle;
+
+		if (!handle)
+			continue;
+
+		zs_free(meta->mem_pool, handle);
+	}
+
 	zs_destroy_pool(meta->mem_pool);
 	vfree(meta->table);
 	kfree(meta);
@@ -706,9 +719,6 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 
 static void zram_reset_device(struct zram *zram, bool reset_capacity)
 {
-	size_t index;
-	struct zram_meta *meta;
-
 	down_write(&zram->init_lock);
 
 	zram->limit_pages = 0;
@@ -718,20 +728,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		return;
 	}
 
-	meta = zram->meta;
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = meta->table[index].handle;
-		if (!handle)
-			continue;
-
-		zs_free(meta->mem_pool, handle);
-	}
-
 	zcomp_destroy(zram->comp);
 	zram->max_comp_streams = 1;
-
-	zram_meta_free(zram->meta);
+	zram_meta_free(zram->meta, zram->disksize);
 	zram->meta = NULL;
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
@@ -803,7 +802,7 @@ out_destroy_comp:
 	up_write(&zram->init_lock);
 	zcomp_destroy(comp);
 out_free_meta:
-	zram_meta_free(meta);
+	zram_meta_free(meta, disksize);
 	return err;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
