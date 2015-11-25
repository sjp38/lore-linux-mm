Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 417696B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:26:36 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so45637112pac.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:26:36 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id qp8si31551847pac.135.2015.11.24.21.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 21:26:35 -0800 (PST)
Received: by pacej9 with SMTP id ej9so45674942pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:26:35 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2] mm/compaction: __compact_pgdat() code cleanuup
Date: Wed, 25 Nov 2015 14:26:12 +0900
Message-Id: <1448429172-24961-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Yaowei Bai <bywxiaobai@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch uses is_via_compact_memory() to distinguish direct compaction.
And it also reduces indentation on compaction_defer_reset
by filtering failure case. There is no functional change.

Acked-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index de3e1e7..01b1e5e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1658,14 +1658,15 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 				!compaction_deferred(zone, cc->order))
 			compact_zone(zone, cc);
 
-		if (cc->order > 0) {
-			if (zone_watermark_ok(zone, cc->order,
-						low_wmark_pages(zone), 0, 0))
-				compaction_defer_reset(zone, cc->order, false);
-		}
-
 		VM_BUG_ON(!list_empty(&cc->freepages));
 		VM_BUG_ON(!list_empty(&cc->migratepages));
+
+		if (is_via_compact_memory(cc->order))
+			continue;
+
+		if (zone_watermark_ok(zone, cc->order,
+				low_wmark_pages(zone), 0, 0))
+			compaction_defer_reset(zone, cc->order, false);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
