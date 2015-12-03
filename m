Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2DB6B0259
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:48 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so63041152pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:48 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id uk9si10137796pac.166.2015.12.02.23.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:47 -0800 (PST)
Received: by pacej9 with SMTP id ej9so63228593pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:47 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 4/7] mm/compaction: update defer counter when allocation is expected to succeed
Date: Thu,  3 Dec 2015 16:11:18 +0900
Message-Id: <1449126681-19647-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's rather strange that compact_considered and compact_defer_shift aren't
updated but compact_order_failed is updated when allocation is expected
to succeed. Regardless actual allocation success, deferring for current
order will be disabled so it doesn't result in much difference to
compaction behaviour.

Moreover, in the past, there is a gap between expectation for allocation
succeess in compaction and actual success in page allocator. But, now,
this gap would be diminished due to providing classzone_idx and alloc_flags
to watermark check in compaction and changed watermark check criteria
for high-order allocation. Therfore, it's not a big problem to update
defer counter when allocation is expected to succeed. This change
will help to simplify defer logic.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h |  2 --
 mm/compaction.c            | 27 ++++++++-------------------
 mm/page_alloc.c            |  1 -
 3 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 359b07a..4761611 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -47,8 +47,6 @@ extern unsigned long compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx);
 
 extern bool compaction_deferred(struct zone *zone, int order);
-extern void compaction_defer_reset(struct zone *zone, int order,
-				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
 #else
diff --git a/mm/compaction.c b/mm/compaction.c
index f144494..67b8d90 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -158,18 +158,12 @@ bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
-/*
- * Update defer tracking counters after successful compaction of given order,
- * which means an allocation either succeeded (alloc_success == true) or is
- * expected to succeed.
- */
-void compaction_defer_reset(struct zone *zone, int order,
-		bool alloc_success)
+/* Update defer tracking counters after successful compaction of given order */
+static void compaction_defer_reset(struct zone *zone, int order)
 {
-	if (alloc_success) {
-		zone->compact_considered = 0;
-		zone->compact_defer_shift = 0;
-	}
+	zone->compact_considered = 0;
+	zone->compact_defer_shift = 0;
+
 	if (order >= zone->compact_order_failed)
 		zone->compact_order_failed = order + 1;
 
@@ -1568,13 +1562,8 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
 					ac->classzone_idx, alloc_flags)) {
-			/*
-			 * We think the allocation will succeed in this zone,
-			 * but it is not certain, hence the false. The caller
-			 * will repeat this with true if allocation indeed
-			 * succeeds in this zone.
-			 */
-			compaction_defer_reset(zone, order, false);
+			compaction_defer_reset(zone, order);
+
 			/*
 			 * It is possible that async compaction aborted due to
 			 * need_resched() and the watermarks were ok thanks to
@@ -1669,7 +1658,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 
 		if (zone_watermark_ok(zone, cc->order,
 				low_wmark_pages(zone), 0, 0))
-			compaction_defer_reset(zone, cc->order, false);
+			compaction_defer_reset(zone, cc->order);
 	}
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7002c66..f3605fd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2815,7 +2815,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		struct zone *zone = page_zone(page);
 
 		zone->compact_blockskip_flush = false;
-		compaction_defer_reset(zone, order, true);
 		count_vm_event(COMPACTSUCCESS);
 		return page;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
