Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0156B06DB
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 12:34:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r29so17613509pfi.7
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 09:34:20 -0700 (PDT)
Received: from mail-pg0-f52.google.com (mail-pg0-f52.google.com. [74.125.83.52])
        by mx.google.com with ESMTPS id g3si21298416pgc.266.2017.08.03.09.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 09:34:19 -0700 (PDT)
Received: by mail-pg0-f52.google.com with SMTP id l64so8194826pge.5
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 09:34:19 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH v2] zram: Rework copy of compressor name in comp_algorithm_store()
Date: Thu,  3 Aug 2017 09:33:50 -0700
Message-Id: <20170803163350.45245-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>, Nick Desaulniers <ndesaulniers@google.com>, Matthias Kaehlcke <mka@chromium.org>

comp_algorithm_store() passes the size of the source buffer to strlcpy()
instead of the destination buffer size. Make it explicit that the two
buffers have the same size and use strcpy() instead of strlcpy().
The latter can be done safely since the function ensures that the string
in the source buffer is terminated.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
Changes in v2:
- make destination buffer explicitly of the same size as source buffer
- use strcpy() instead of strlcpy()
- updated subject and commit message

 drivers/block/zram/zram_drv.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 856d5dc02451..3b1b6340ba13 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -308,7 +308,7 @@ static ssize_t comp_algorithm_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
 	struct zram *zram = dev_to_zram(dev);
-	char compressor[CRYPTO_MAX_ALG_NAME];
+	char compressor[ARRAY_SIZE(zram->compressor)];
 	size_t sz;
 
 	strlcpy(compressor, buf, sizeof(compressor));
@@ -327,7 +327,7 @@ static ssize_t comp_algorithm_store(struct device *dev,
 		return -EBUSY;
 	}
 
-	strlcpy(zram->compressor, compressor, sizeof(compressor));
+	strcpy(zram->compressor, compressor);
 	up_write(&zram->init_lock);
 	return len;
 }
-- 
2.14.0.rc1.383.gd1ce394fe2-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
