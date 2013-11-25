Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2856B00BE
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:26:54 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so2025320bkb.34
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 06:26:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id cr5si9617622bkc.146.2013.11.25.06.26.53
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 06:26:53 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 5/5] mm: compaction: reset scanner positions immediately when they meet
Date: Mon, 25 Nov 2013 15:26:10 +0100
Message-Id: <1385389570-11393-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Compaction used to start its migrate and free page scaners at the zone's lowest
and highest pfn, respectively. Later, caching was introduced to remember the
scanners' progress across compaction attempts so that pageblocks are not
re-scanned uselessly. Additionally, pageblocks where isolation failed are
marked to be quickly skipped when encountered again in future compactions.

Currently, both the reset of cached pfn's and clearing of the pageblock skip
information for a zone is done in __reset_isolation_suitable(). This function
gets called when:
 - compaction is restarting after being deferred
 - compact_blockskip_flush flag is set in compact_finished() when the scanners
   meet (and not again cleared when direct compaction succeeds in allocation)
   and kswapd acts upon this flag before going to sleep

This behavior is suboptimal for several reasons:
 - when direct sync compaction is called after async compaction fails (in the
   allocation slowpath), it will effectively do nothing, unless kswapd
   happens to process the compact_blockskip_flush flag meanwhile. This is racy
   and goes against the purpose of sync compaction to more thoroughly retry
   the compaction of a zone where async compaction has failed.
   The restart-after-deferring path cannot help here as deferring happens only
   after the sync compaction fails. It is also done only for the preferred
   zone, while the compaction might be done for a fallback zone.
 - the mechanism of marking pageblock to be skipped has little value since the
   cached pfn's are reset only together with the pageblock skip flags. This
   effectively limits pageblock skip usage to parallel compactions.

This patch changes compact_finished() so that cached pfn's are reset
immediately when the scanners meet. Clearing pageblock skip flags is unchanged,
as well as the other situations where cached pfn's are reset. This allows the
sync-after-async compaction to retry pageblocks not marked as skipped, such as
blocks !MIGRATE_MOVABLE blocks that async compactions now skips without
marking them.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index f481193..2c2cc4a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -843,6 +843,10 @@ static int compact_finished(struct zone *zone,
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
+		/* Let the next compaction start anew. */
+		zone->compact_cached_migrate_pfn = zone->zone_start_pfn;
+	        zone->compact_cached_free_pfn = zone_end_pfn(zone);
+
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
 		 * by kswapd when it goes to sleep. kswapd does not set the
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
