Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2056B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 05:26:30 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2804887pdi.2
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 02:26:30 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id c6si6086860pdn.138.2014.10.25.02.26.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sat, 25 Oct 2014 02:26:29 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NDZ008UHU83FT70@mailout4.samsung.com> for
 linux-mm@kvack.org; Sat, 25 Oct 2014 18:26:27 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 1/2] zram: make max_used_pages reset work correctly
Date: Sat, 25 Oct 2014 17:25:11 +0800
Message-id: <000001cff035$c060dc60$41229520$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

The commit 461a8eee6a ("zram: report maximum used memory") introduces a new
knob "mem_used_max" in zram.stats sysfs, and wants to reset it via write 0
to the sysfs interface.

However, the current code cann't reset it correctly, so let's fix it.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 drivers/block/zram/zram_drv.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0e63e8a..64dd79a 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -173,7 +173,6 @@ static ssize_t mem_used_max_store(struct device *dev,
 	int err;
 	unsigned long val;
 	struct zram *zram = dev_to_zram(dev);
-	struct zram_meta *meta = zram->meta;
 
 	err = kstrtoul(buf, 10, &val);
 	if (err || val != 0)
@@ -181,8 +180,7 @@ static ssize_t mem_used_max_store(struct device *dev,
 
 	down_read(&zram->init_lock);
 	if (init_done(zram))
-		atomic_long_set(&zram->stats.max_used_pages,
-				zs_get_total_pages(meta->mem_pool));
+		atomic_long_set(&zram->stats.max_used_pages, 0);
 	up_read(&zram->init_lock);
 
 	return len;
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
