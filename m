Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C20D86B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:24:51 -0500 (EST)
Received: by pacej9 with SMTP id ej9so11456669pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 22:24:51 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id d7si690356pbu.76.2015.11.23.22.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 22:24:51 -0800 (PST)
Received: by padhx2 with SMTP id hx2so11513884pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 22:24:51 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/compaction: __compact_pgdat() code cleanuup
Date: Tue, 24 Nov 2015 15:24:42 +0900
Message-Id: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Yaowei Bai <bywxiaobai@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch uses is_via_compact_memory() to distinguish direct compaction.
And it also reduces indentation on compaction_defer_reset
by filtering failure case. There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index de3e1e7..2b1a15e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1658,14 +1658,17 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
+		if (!zone_watermark_ok(zone, cc->order,
+				low_wmark_pages(zone), 0, 0))
+			continue;
+
+		compaction_defer_reset(zone, cc->order, false);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
