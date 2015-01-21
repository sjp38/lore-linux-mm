Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C90E06B006C
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:14:37 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so50760774pad.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:14:37 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ag17si7449445pac.113.2015.01.20.22.14.34
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:36 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 01/10] zram: avoid calling of zram_meta_free under init_lock
Date: Wed, 21 Jan 2015 15:14:17 +0900
Message-Id: <1421820866-26521-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1421820866-26521-1-git-send-email-minchan@kernel.org>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

We don't need to call zram_meta_free under init_lock.
What we need to prevent race is setting NULL into zram->meta
(ie, init_done). This patch does it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9250b3f..7e03d86 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -719,6 +719,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	}
 
 	meta = zram->meta;
+	zram->meta = NULL;
+
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
 		unsigned long handle = meta->table[index].handle;
@@ -731,8 +733,6 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	zcomp_destroy(zram->comp);
 	zram->max_comp_streams = 1;
 
-	zram_meta_free(zram->meta);
-	zram->meta = NULL;
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
 
@@ -741,6 +741,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		set_capacity(zram->disk, 0);
 
 	up_write(&zram->init_lock);
+	zram_meta_free(meta);
 
 	/*
 	 * Revalidate disk out of the init_lock to avoid lockdep splat.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
