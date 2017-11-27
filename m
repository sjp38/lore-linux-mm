Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 286DE6B0253
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 20:40:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 199so21614434pgg.20
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 17:40:52 -0800 (PST)
Received: from mxhk.zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTPS id ay2si21865466plb.244.2017.11.26.17.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 17:40:51 -0800 (PST)
From: Jiang Biao <jiang.biao2@zte.com.cn>
Subject: [PATCH] mm/vmscan: make do_shrink_slab more robust.
Date: Mon, 27 Nov 2017 09:37:30 +0800
Message-Id: <1511746650-51945-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn, zhong.weidong@zte.com.cn

When running ltp stress test for 7*24 hours, the kernel occasionally
complains the following warning continuously,

mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
nr=-9222526086287711848
mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
nr=-9222420761333860545
mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
nr=-9222287677544280360
...

The tracing result shows the freeable(mb_cache_shrink_scan returns)
is -1, which causes the continuous accumulation and overflow of
total_scan.

This patch make do_shrink_slab more robust when
shrinker->count_objects return negative freeable.

Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb2f031..3ea28f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -323,7 +323,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	long scanned = 0, next_deferred;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
-	if (freeable == 0)
+	if (freeable <= 0)
 		return 0;
 
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
