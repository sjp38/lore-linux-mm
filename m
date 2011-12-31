Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E586F6B004D
	for <linux-mm@kvack.org>; Sat, 31 Dec 2011 01:17:49 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH] mm/compaction : check the watermark when cc->order is -1
Date: Sat, 31 Dec 2011 14:18:43 +0800
Message-ID: <1325312323-13565-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Huang Shijie <b32955@freescale.com>

We get cc->order is -1 when user echos to /proc/sys/vm/compact_memory.
In this case, we should check that if we have enough pages for
the compaction in the zone.

If we do not check this, in our MX6Q board(arm), i ever observed
COMPACT_CLUSTER_MAX pages were compaction failed in per migrate_pages().
That's mean we can not alloc any pages by the free scanner in the zone.

This patch checks the watermark to avoid this problem.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/compaction.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..0f12cc9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -442,8 +442,13 @@ static int compact_finished(struct zone *zone,
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
 	 */
-	if (cc->order == -1)
+	if (cc->order == -1) {
+		/* Check if we have enough pages now. */
+		watermark = low_wmark_pages(zone) + COMPACT_CLUSTER_MAX * 2;
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			return COMPACT_SKIPPED;
 		return COMPACT_CONTINUE;
+	}
 
 	/* Compaction run is not finished if the watermark is not met */
 	watermark = low_wmark_pages(zone);
@@ -482,8 +487,13 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
 	 */
-	if (order == -1)
+	if (order == -1) {
+		/* Check if we have enough pages now. */
+		watermark = low_wmark_pages(zone) + COMPACT_CLUSTER_MAX * 2;
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			return COMPACT_SKIPPED;
 		return COMPACT_CONTINUE;
+	}
 
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
-- 
1.7.3.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
