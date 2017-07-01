Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 590FB2802FE
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 02:14:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 76so143896501pgh.11
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 23:14:03 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTP id q23si7228565pgc.114.2017.06.30.23.14.01
        for <linux-mm@kvack.org>;
        Fri, 30 Jun 2017 23:14:02 -0700 (PDT)
From: zbestahu@aliyun.com
Subject: [PATCH] mm: vmpressure: simplify pressure ratio calculation
Date: Sat,  1 Jul 2017 14:13:39 +0800
Message-Id: <1498889619-3933-1-git-send-email-zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yue Hu <huyue2@coolpad.com>

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
