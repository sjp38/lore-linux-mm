Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07622280301
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 02:27:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d62so138402445pfb.13
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 23:27:53 -0700 (PDT)
Received: from out30-40.freemail.mail.aliyun.com (out30-40.freemail.mail.aliyun.com. [115.124.30.40])
        by mx.google.com with ESMTP id i9si8152200plk.574.2017.06.30.23.27.52
        for <linux-mm@kvack.org>;
        Fri, 30 Jun 2017 23:27:53 -0700 (PDT)
From: zbestahu@aliyun.com
Subject: [PATCH] mm: vmpressure: simplify pressure ratio calculation
Date: Sat,  1 Jul 2017 14:27:39 +0800
Message-Id: <1498890459-3983-1-git-send-email-zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Yue Hu <huyue2@coolpad.com>

From: Yue Hu <huyue2@coolpad.com>

The patch removes the needless scale in existing caluation, it
makes the calculation more simple and more effective.

Signed-off-by: Yue Hu <huyue2@coolpad.com>
---
 mm/vmpressure.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 6063581..174b2f0 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -111,7 +111,6 @@ static enum vmpressure_levels vmpressure_level(unsigned long pressure)
 static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 						    unsigned long reclaimed)
 {
-	unsigned long scale = scanned + reclaimed;
 	unsigned long pressure = 0;
 
 	/*
@@ -128,8 +127,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	 * scanned. This makes it possible to set desired reaction time
 	 * and serves as a ratelimit.
 	 */
-	pressure = scale - (reclaimed * scale / scanned);
-	pressure = pressure * 100 / scale;
+	pressure = (scanned - reclaimed) * 100 / scanned;
 
 out:
 	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
