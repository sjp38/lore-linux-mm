Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC9996B0292
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 21:29:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a142so3580379oii.5
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 18:29:30 -0700 (PDT)
Received: from out30-5.freemail.mail.aliyun.com (out30-5.freemail.mail.aliyun.com. [115.124.30.5])
        by mx.google.com with ESMTP id 72si3151851oii.89.2017.07.07.18.29.28
        for <linux-mm@kvack.org>;
        Fri, 07 Jul 2017 18:29:29 -0700 (PDT)
From: zbestahu@aliyun.com
Subject: [PATCH] mm/page_alloc.c: improve allocation fast path
Date: Sat,  8 Jul 2017 09:28:39 +0800
Message-Id: <1499477319-1395-1-git-send-email-zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, minchan@kernel.org
Cc: linux-mm@kvack.org, Yue Hu <huyue2@coolpad.com>

From: Yue Hu <huyue2@coolpad.com>

We currently is taking time to check if the watermark is safe when
alloc_flags is setting with ALLOC_NO_WATERMARK in slowpath, the check
to alloc_flags is faster check which should be first check option
compared to the slow check of watermark, it could benefit to urgency
allocation request in slowpath, it also almost has no effect for
allocation with successful watermark check.

Signed-off-by: Yue Hu <huyue2@coolpad.com>
---
 mm/page_alloc.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07efbc3..f1ba0e37 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3014,16 +3014,16 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 			}
 		}
 
+		/* Checked here to keep the fast path fast */
+		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
+		if (alloc_flags & ALLOC_NO_WATERMARKS)
+			goto try_this_zone;
+
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_fast(zone, order, mark,
 				       ac_classzone_idx(ac), alloc_flags)) {
 			int ret;
 
-			/* Checked here to keep the fast path fast */
-			BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-			if (alloc_flags & ALLOC_NO_WATERMARKS)
-				goto try_this_zone;
-
 			if (node_reclaim_mode == 0 ||
 			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
