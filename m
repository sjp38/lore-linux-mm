Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC126B004D
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:24:54 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2751135eek.35
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:24:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id i1si18360929eev.89.2013.12.11.02.24.52
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 02:24:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V2 2/6] mm: compaction: encapsulate defer reset logic
Date: Wed, 11 Dec 2013 11:24:33 +0100
Message-Id: <1386757477-10333-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
References: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently there are several functions to manipulate the deferred compaction
state variables. The remaining case where the variables are touched directly
is when a successful allocation occurs in direct compaction, or is expected
to be successful in the future by kswapd. Here, the lowest order that is
expected to fail is updated, and in the case of successful allocation, the
deferred status and counter is reset completely.

Create a new function compaction_defer_reset() to encapsulate this
functionality and make it easier to understand the code. No functional change.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h | 16 ++++++++++++++++
 mm/compaction.c            |  9 ++++-----
 mm/page_alloc.c            |  5 +----
 3 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 091d72e..7e1c76e 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -62,6 +62,22 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return zone->compact_considered < defer_limit;
 }
 
+/*
+ * Update defer tracking counters after successful compaction of given order,
+ * which means an allocation either succeeded (alloc_success == true) or is
+ * expected to succeed.
+ */
+static inline void compaction_defer_reset(struct zone *zone, int order,
+		bool alloc_success)
+{
+	if (alloc_success) {
+		zone->compact_considered = 0;
+		zone->compact_defer_shift = 0;
+	}
+	if (order >= zone->compact_order_failed)
+		zone->compact_order_failed = order + 1;
+}
+
 /* Returns true if restarting compaction after many failures */
 static inline bool compaction_restarting(struct zone *zone, int order)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index bb50fd3..e431804 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1120,12 +1120,11 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 			compact_zone(zone, cc);
 
 		if (cc->order > 0) {
-			int ok = zone_watermark_ok(zone, cc->order,
-						low_wmark_pages(zone), 0, 0);
-			if (ok && cc->order >= zone->compact_order_failed)
-				zone->compact_order_failed = cc->order + 1;
+			if (zone_watermark_ok(zone, cc->order,
+						low_wmark_pages(zone), 0, 0))
+				compaction_defer_reset(zone, cc->order, false);
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (cc->sync)
 				defer_compaction(zone, cc->order);
 		}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 580a5f0..50c7f67 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2243,10 +2243,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				preferred_zone, migratetype);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
-			preferred_zone->compact_considered = 0;
-			preferred_zone->compact_defer_shift = 0;
-			if (order >= preferred_zone->compact_order_failed)
-				preferred_zone->compact_order_failed = order + 1;
+			compaction_defer_reset(preferred_zone, order, true);
 			count_vm_event(COMPACTSUCCESS);
 			return page;
 		}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
