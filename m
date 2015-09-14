Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD0F6B0259
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:50:40 -0400 (EDT)
Received: by lbbmp1 with SMTP id mp1so67731520lbb.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:50:39 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id kz9si9790298lbc.20.2015.09.14.06.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:50:38 -0700 (PDT)
Received: by lbcjc2 with SMTP id jc2so67646159lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:50:38 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:50:36 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 1/3] zram: make max_zpage_size configurable
Message-Id: <20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

It makes sense to have control over what compression ratios are
ok to store pages uncompressed and what not. Moreover, if we end
up using zbud allocator for zram, any attempt to allocate a whole
page will fail, so we may want to avoid this as much as possible.

So, let's have max_zpage_size configurable as a module parameter.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 drivers/block/zram/zram_drv.c | 13 +++++++++++++
 drivers/block/zram/zram_drv.h | 16 ----------------
 2 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9fa15bb..6d9f1d1 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -42,6 +42,7 @@ static const char *default_compressor = "lzo";
 
 /* Module params (documentation at end) */
 static unsigned int num_devices = 1;
+static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
 
 static inline void deprecated_attr_warn(const char *name)
 {
@@ -1411,6 +1412,16 @@ static int __init zram_init(void)
 		return ret;
 	}
 
+	/*
+	 * max_zpage_size must be less than or equal to:
+	 * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
+	 * always return failure.
+	 */
+	if (max_zpage_size > PAGE_SIZE) {
+		pr_err("Invalid max_zpage_size %ld\n", max_zpage_size);
+		return -EINVAL;
+	}
+
 	zram_major = register_blkdev(0, "zram");
 	if (zram_major <= 0) {
 		pr_err("Unable to get major number\n");
@@ -1444,6 +1455,8 @@ module_exit(zram_exit);
 
 module_param(num_devices, uint, 0);
 MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
+module_param(max_zpage_size, ulong, 0);
+MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed pages");
 
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 8e92339..3a29c33 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -20,22 +20,6 @@
 
 #include "zcomp.h"
 
-/*-- Configurable parameters */
-
-/*
- * Pages that compress to size greater than this are stored
- * uncompressed in memory.
- */
-static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
-
-/*
- * NOTE: max_zpage_size must be less than or equal to:
- *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
- * always return failure.
- */
-
-/*-- End of configurable params */
-
 #define SECTOR_SHIFT		9
 #define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
 #define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
