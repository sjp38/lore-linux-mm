Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFA490008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 02:21:36 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so4492106pdj.19
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 23:21:36 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id gi6si5788626pbd.102.2014.10.29.23.21.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 29 Oct 2014 23:21:35 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE800DZSUZWT260@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 30 Oct 2014 15:21:32 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] zram: avoid kunmap_atomic a NULL pointer
Date: Thu, 30 Oct 2014 14:20:31 +0800
Message-id: <000001cff409$bf7bfa50$3e73eef0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

zram could kunmap_atomic a NULL pointer in a rare situation:
a zram page become a full-zeroed page after a partial write io.
The current code doesn't handle this case and kunmap_atomic a
NULL porinter, which panic the kernel.

This patch fixes this issue.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 drivers/block/zram/zram_drv.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 2ad0b5b..3920ee4 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -560,7 +560,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	}
 
 	if (page_zero_filled(uncmem)) {
-		kunmap_atomic(user_mem);
+		if (user_mem)
+			kunmap_atomic(user_mem);
 		/* Free memory associated with this sector now. */
 		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
 		zram_free_page(zram, index);
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
