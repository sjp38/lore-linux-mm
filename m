Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E88E6B00B9
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:26:48 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so2062556bkj.10
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 06:26:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id un9si9614357bkb.219.2013.11.25.06.26.47
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 06:26:48 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/5] mm: compaction: encapsulate defer reset logic
Date: Mon, 25 Nov 2013 15:26:06 +0100
Message-Id: <1385389570-11393-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Currently there are several functions to manipulate the deferred compaction
state variables. The remaining case where the variables are touched directly
is when a successful allocation occurs in direct compaction, or is expected
to be successful in the future by kswapd. Here, the lowest order that is
expected to fail is updated, and in the case of direct compaction, the deferred
status is reset completely.

Create a new function compaction_defer_reset() to encapsulate this
functionality and make it easier to understand the code. No functional change.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h | 12 ++++++++++++
 mm/compaction.c            |  9 ++++-----
 mm/page_alloc.c            |  5 +----
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 091d72e..da39978 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -62,6 +62,18 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return zone->compact_considered < defer_limit;
 }
 
+/* Update defer tracking counters after successful allocation of given order */
+static inline void compaction_defer_reset(struct zone *zone, int order,
+		bool reset_shift)
+{
+	if (reset_shift) {
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
index 805165b..7c0073e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1116,12 +1116,11 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
