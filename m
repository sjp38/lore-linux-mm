Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 79ABC6B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 10:05:40 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id rd3so243850pab.37
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 07:05:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id lk4si6527399pab.391.2014.04.29.07.05.29
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 07:05:30 -0700 (PDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] mm / dmapool: re-use devres_release() to free resources
Date: Tue, 29 Apr 2014 17:04:32 +0300
Message-Id: <1398780272-8644-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Instead of calling an additional routine in dmam_pool_destroy() rely on what
dmam_pool_release() is doing.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 mm/dmapool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index c69781e..513cbd7 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -508,7 +508,6 @@ void dmam_pool_destroy(struct dma_pool *pool)
 {
 	struct device *dev = pool->dev;
 
-	WARN_ON(devres_destroy(dev, dmam_pool_release, dmam_pool_match, pool));
-	dma_pool_destroy(pool);
+	WARN_ON(devres_release(dev, dmam_pool_release, dmam_pool_match, pool));
 }
 EXPORT_SYMBOL(dmam_pool_destroy);
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
