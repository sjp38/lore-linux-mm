Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 915136B005D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 21:49:04 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH v2] mm/compaction : check the watermark when cc->order is -1
Date: Fri, 6 Jan 2012 10:50:01 +0800
Message-ID: <1325818201-1865-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, shijie8@gmail.com, Huang Shijie <b32955@freescale.com>

We get cc->order is -1 when user echos to /proc/sys/vm/compact_memory.
In this case, we should check that if we have enough pages for
the compaction in the zone.

If we do not check this, in our MX6Q board(arm), i ever observed
COMPACT_CLUSTER_MAX pages were compaction failed in per migrate_pages().
Thats mean we can not alloc any pages by the free scanner in the zone.

This patch checks the watermark to avoid this problem.
Tested this patch in the MX6Q board.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/compaction.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..bf8e8b2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -479,21 +479,21 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	unsigned long watermark;
 
 	/*
+	 * Watermarks for order-0 must be met for compaction.
+	 * During the migration, copies of pages need to be
+	 * allocated and for a short time, so the footprint is higher.
 	 * order == -1 is expected when compacting via
-	 * /proc/sys/vm/compact_memory
+	 * /proc/sys/vm/compact_memory.
 	 */
-	if (order == -1)
-		return COMPACT_CONTINUE;
+	watermark = low_wmark_pages(zone) +
+		((order == -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL << order));
 
-	/*
-	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
-	 * This is because during migration, copies of pages need to be
-	 * allocated and for a short time, the footprint is higher
-	 */
-	watermark = low_wmark_pages(zone) + (2UL << order);
 	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 		return COMPACT_SKIPPED;
 
+	if (order == -1)
+		return COMPACT_CONTINUE;
+
 	/*
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
-- 
1.7.3.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
