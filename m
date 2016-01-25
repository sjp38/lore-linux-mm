Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 588846B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:10:19 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id uo6so83095093pac.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:10:19 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 7si34007100pfi.90.2016.01.25.06.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 06:10:18 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm/page-writeback: fix dirty_ratelimit calculation
Date: Mon, 25 Jan 2016 17:11:11 +0300
Message-ID: <1453731071-21541-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <566594E2.3050306@odin.com>
References: <566594E2.3050306@odin.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

Calculation of dirty_ratelimit sometimes is not correct.
E.g. initial values of dirty_ratelimit == INIT_BW and step == 0,
lead to the following result:

   UBSAN: Undefined behaviour in ../mm/page-writeback.c:1286:7
   shift exponent 25600 is too large for 64-bit type 'long unsigned int'

The fix is straightforward - make step 0 if the shift exponent is too big.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/page-writeback.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 6fe7d15..d782cba 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1169,6 +1169,7 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	unsigned long balanced_dirty_ratelimit;
 	unsigned long step;
 	unsigned long x;
+	unsigned long shift;
 
 	/*
 	 * The dirty rate will match the writeout rate in long term, except
@@ -1293,11 +1294,11 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	 * rate itself is constantly fluctuating. So decrease the track speed
 	 * when it gets close to the target. Helps eliminate pointless tremors.
 	 */
-	step >>= dirty_ratelimit / (2 * step + 1);
-	/*
-	 * Limit the tracking speed to avoid overshooting.
-	 */
-	step = (step + 7) / 8;
+	shift = dirty_ratelimit / (2 * step + 1);
+	if (shift < BITS_PER_LONG)
+		step = DIV_ROUND_UP(step >> shift, 8);
+	else
+		step = 0;
 
 	if (dirty_ratelimit < balanced_dirty_ratelimit)
 		dirty_ratelimit += step;
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
