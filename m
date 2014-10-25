Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EAB7F6B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 05:27:12 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id et14so118991pad.1
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 02:27:12 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id b2si6195838pde.9.2014.10.25.02.27.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sat, 25 Oct 2014 02:27:12 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NDZ00IAOU9AFC50@mailout2.samsung.com> for
 linux-mm@kvack.org; Sat, 25 Oct 2014 18:27:10 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 2/2] zram: avoid NULL pointer access when reading mem_used_total
Date: Sat, 25 Oct 2014 17:26:31 +0800
Message-id: <000101cff035$d9f50480$8ddf0d80$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

There is a rare NULL pointer bug in mem_used_total_show() in concurrent
situation, like this:
zram is not initialized, process A is a mem_used_total reader which runs
periodicity, while process B try to init zram.

	process A 				process B
access meta, get a NULL value
						init zram, done
init_done() is true
access meta->mem_pool, get a NULL pointer BUG

This patch fixes this issue.
	
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 drivers/block/zram/zram_drv.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 64dd79a..2ffd7d8 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -99,11 +99,12 @@ static ssize_t mem_used_total_show(struct device *dev,
 {
 	u64 val = 0;
 	struct zram *zram = dev_to_zram(dev);
-	struct zram_meta *meta = zram->meta;
 
 	down_read(&zram->init_lock);
-	if (init_done(zram))
+	if (init_done(zram)) {
+		struct zram_meta *meta = zram->meta;
 		val = zs_get_total_pages(meta->mem_pool);
+	}
 	up_read(&zram->init_lock);
 
 	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
