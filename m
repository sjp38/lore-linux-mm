Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A251F6B025A
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:51 -0500 (EST)
Received: by pacej9 with SMTP id ej9so63229845pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:51 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id r6si10112071pap.176.2015.12.02.23.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:50 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so63041976pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:50 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 5/7] mm/compaction: respect compaction order when updating defer counter
Date: Thu,  3 Dec 2015 16:11:19 +0900
Message-Id: <1449126681-19647-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It doesn't make sense that we reset defer counter
in compaction_defer_reset() when compaction request under the order of
compact_order_failed succeed. Fix it.

And, it does make sense that giving enough chance for updated failed
order compaction before deferring. Change it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 67b8d90..1a75a6e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -126,11 +126,14 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
  */
 static void defer_compaction(struct zone *zone, int order)
 {
-	zone->compact_considered = 0;
-	zone->compact_defer_shift++;
-
-	if (order < zone->compact_order_failed)
+	if (order < zone->compact_order_failed) {
+		zone->compact_considered = 0;
+		zone->compact_defer_shift = 0;
 		zone->compact_order_failed = order;
+	} else {
+		zone->compact_considered = 0;
+		zone->compact_defer_shift++;
+	}
 
 	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
 		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
@@ -161,11 +164,11 @@ bool compaction_deferred(struct zone *zone, int order)
 /* Update defer tracking counters after successful compaction of given order */
 static void compaction_defer_reset(struct zone *zone, int order)
 {
-	zone->compact_considered = 0;
-	zone->compact_defer_shift = 0;
-
-	if (order >= zone->compact_order_failed)
+	if (order >= zone->compact_order_failed) {
+		zone->compact_considered = 0;
+		zone->compact_defer_shift = 0;
 		zone->compact_order_failed = order + 1;
+	}
 
 	trace_mm_compaction_defer_reset(zone, order);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
