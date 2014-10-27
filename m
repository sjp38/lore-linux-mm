Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 299C66B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 22:04:25 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so4455837pab.40
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 19:04:24 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id rj8si9259448pdb.192.2014.10.26.19.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 26 Oct 2014 19:04:24 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE2002CIZ399B30@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 11:04:21 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] zram: avoid NULL pointer access in concurrent situation
Date: Mon, 27 Oct 2014 10:03:19 +0800
Message-id: <000001cff18a$52d70d80$f8852880$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

There is a rare NULL pointer bug in mem_used_total_show() and
mem_used_max_store() in concurrent situation, like this:

zram is not initialized, process A is a mem_used_total reader which runs
periodically, while process B try to init zram.

	process A 				process B
access meta, get a NULL value
						init zram, done
init_done() is true
access meta->mem_pool, get a NULL pointer BUG

This patch fixes this issue.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0e63e8a..2ad0b5b 100644
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
@@ -173,16 +174,17 @@ static ssize_t mem_used_max_store(struct device *dev,
 	int err;
 	unsigned long val;
 	struct zram *zram = dev_to_zram(dev);
-	struct zram_meta *meta = zram->meta;
 
 	err = kstrtoul(buf, 10, &val);
 	if (err || val != 0)
 		return -EINVAL;
 
 	down_read(&zram->init_lock);
-	if (init_done(zram))
+	if (init_done(zram)) {
+		struct zram_meta *meta = zram->meta;
 		atomic_long_set(&zram->stats.max_used_pages,
 				zs_get_total_pages(meta->mem_pool));
+	}
 	up_read(&zram->init_lock);
 
 	return len;
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
