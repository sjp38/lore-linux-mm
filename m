Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4992A6B0075
	for <linux-mm@kvack.org>; Thu, 28 May 2015 23:24:36 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so39131332pac.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 20:24:36 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id l14si6465076pdn.60.2015.05.28.20.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 May 2015 20:24:35 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NP300B6MDGWOH70@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 29 May 2015 12:24:32 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] zram: clear disk io accounting when reset zram device
Date: Fri, 29 May 2015 11:23:24 +0800
Message-id: <"000001d099be$fae6cc90$f0b465b0$@yang"@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, sergey.senozhatsky.work@gmail.com, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch clears zram disk io accounting when reset the zram device,
if don't do this, the residual io accounting stat will affect the
diskstat in the next zram active cycle.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 drivers/block/zram/zram_drv.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 8dcbced..6e134f4 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -805,7 +805,9 @@ static void zram_reset_device(struct zram *zram)
 	memset(&zram->stats, 0, sizeof(zram->stats));
 	zram->disksize = 0;
 	zram->max_comp_streams = 1;
+
 	set_capacity(zram->disk, 0);
+	part_stat_set_all(&zram->disk->part0, 0);
 
 	up_write(&zram->init_lock);
 	/* I/O operation under all of CPU are done so let's free */
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
