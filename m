Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4680E6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 04:36:45 -0400 (EDT)
Subject: [PATCH]compaction: checks correct fragmentation index
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Jun 2011 16:36:41 +0800
Message-ID: <1307435801.15392.64.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>

fragmentation_index() returns -1000 when the allocation might succeed
This doesn't match the comment and code in compaction_suitable(). I
thought compaction_suitable should return COMPACT_PARTIAL in -1000
case, because in this case allocation could succeed depending on
watermarks.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..59b0c4b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -480,7 +480,8 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
 	 *
-	 * index of -1 implies allocations might succeed dependingon watermarks
+	 * index of -1000 implies allocations might succeed depending on
+	 * watermarks
 	 * index towards 0 implies failure is due to lack of memory
 	 * index towards 1000 implies failure is due to fragmentation
 	 *
@@ -490,7 +491,8 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
 		return COMPACT_SKIPPED;
 
-	if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0))
+	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
+	    0, 0))
 		return COMPACT_PARTIAL;
 
 	return COMPACT_CONTINUE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
