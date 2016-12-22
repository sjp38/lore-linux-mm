Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 718036B03E6
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 19:36:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so338880804pfy.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:36:27 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 207si1205346pgh.10.2016.12.21.16.36.25
        for <linux-mm@kvack.org>;
        Wed, 21 Dec 2016 16:36:26 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 2/3] zram: revalidate disk under init_lock
Date: Thu, 22 Dec 2016 09:36:19 +0900
Message-Id: <1482366980-3782-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1482366980-3782-1-git-send-email-minchan@kernel.org>
References: <1482366980-3782-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "[4.7+]" <stable@vger.kernel.org>

[1] moved revalidate_disk call out of init_lock to avoid lockdep
false-positive splat. However, [2] remove init_lock in IO path
so there is no worry about lockdep splat. So, let's restore it.
This patch need to set BDI_CAP_STABLE_WRITES atomically in
next patch.

[1] b4c5c60920e3: zram: avoid lockdep splat by revalidate_disk
[2] 08eee69fcf6b: zram: remove init_lock in zram_make_request

Fixes: da9556a2367c ("zram: user per-cpu compression streams")
Cc: <stable@vger.kernel.org> [4.7+]
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 15f58ab44d0b..195376b4472b 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1095,14 +1095,8 @@ static ssize_t disksize_store(struct device *dev,
 	zram->comp = comp;
 	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	up_write(&zram->init_lock);
-
-	/*
-	 * Revalidate disk out of the init_lock to avoid lockdep splat.
-	 * It's okay because disk's capacity is protected by init_lock
-	 * so that revalidate_disk always sees up-to-date capacity.
-	 */
 	revalidate_disk(zram->disk);
+	up_write(&zram->init_lock);
 
 	return len;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
