Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 719056B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 08:38:37 -0400 (EDT)
Date: Mon, 30 May 2011 14:38:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: fix special case -1 order check in compact_finished
Message-ID: <20110530123831.GG20166@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

56de7263 (mm: compaction: direct compact when a high-order allocation
fails) introduced a check for cc->order == -1 in compact_finished. We
should continue compacting in that case because the request came from
userspace and there is no particular order to compact for.

The check is, however, done after zone_watermark_ok which uses order as
a right hand argument for shifts. Not only watermark check is pointless
if we can break out without it but it also uses 1 << -1 which is not
well defined (at least from C standard). Let's move the -1 check above
zone_watermark_ok.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
---
 compaction.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)
Index: linus_tree/mm/compaction.c
===================================================================
--- linus_tree.orig/mm/compaction.c	2011-05-30 14:19:58.000000000 +0200
+++ linus_tree/mm/compaction.c	2011-05-30 14:20:40.000000000 +0200
@@ -420,13 +420,6 @@ static int compact_finished(struct zone
 	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;
 
-	/* Compaction run is not finished if the watermark is not met */
-	watermark = low_wmark_pages(zone);
-	watermark += (1 << cc->order);
-
-	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
-		return COMPACT_CONTINUE;
-
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -434,6 +427,13 @@ static int compact_finished(struct zone
 	if (cc->order == -1)
 		return COMPACT_CONTINUE;
 
+	/* Compaction run is not finished if the watermark is not met */
+	watermark = low_wmark_pages(zone);
+	watermark += (1 << cc->order);
+
+	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
+		return COMPACT_CONTINUE;
+
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		/* Job done if page is free of the right migratetype */
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
