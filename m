Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 73E056B003D
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:24:54 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so2775114eak.25
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:24:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id u49si18360063eep.106.2013.12.11.02.24.53
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 02:24:53 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V2 6/6] mm: compaction: reset scanner positions immediately when they meet
Date: Wed, 11 Dec 2013 11:24:37 +0100
Message-Id: <1386757477-10333-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
References: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Cc: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index a3ee851..5f1c7ad 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -847,6 +847,10 @@ static int compact_finished(struct zone *zone,
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
+		/* Let the next compaction start anew. */
+		zone->compact_cached_migrate_pfn = zone->zone_start_pfn;
+		zone->compact_cached_free_pfn = zone_end_pfn(zone);
+
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
 		 * by kswapd when it goes to sleep. kswapd does not set the
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
