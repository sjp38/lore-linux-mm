Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C0B62600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 13:27:26 -0400 (EDT)
Received: by mail-fx0-f41.google.com with SMTP id 3so191513fxm.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 10:27:25 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 07/10] Increase compressed page size threshold
Date: Mon,  9 Aug 2010 22:56:53 +0530
Message-Id: <1281374816-904-8-git-send-email-ngupta@vflare.org>
In-Reply-To: <1281374816-904-1-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>
Cc: Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Compression takes much more time than decompression. So, its quite
wasteful in terms of both CPU cycles and memory usage to have a very
low compressed page size threshold and thereby storing such not-so-well
compressible pages as-is (uncompressed). So, increasing it from
PAGE_SIZE/2 to PAGE_SIZE/8*7. A low threshold was useful when we had
"backing swap" support where we could forward such pages to the backing
device (applicable only when zram was used as swap disk).

It is not yet configurable through sysfs but may be exported in future,
along with threshold for average compression ratio.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 drivers/staging/zram/zram_drv.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 65e512d..bcc51ea 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -47,7 +47,7 @@ static const unsigned default_disksize_perc_ram = 25;
  * Pages that compress to size greater than this are stored
  * uncompressed in memory.
  */
-static const unsigned max_zpage_size = PAGE_SIZE / 4 * 3;
+static const unsigned max_zpage_size = PAGE_SIZE / 8 * 7;
 
 /*
  * NOTE: max_zpage_size must be less than or equal to:
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
