Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id B3E696B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:24:53 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so2805390eei.0
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:24:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id i1si18314356eev.236.2013.12.11.02.24.52
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 02:24:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V2 3/6] mm: compaction: reset cached scanner pfn's before reading them
Date: Wed, 11 Dec 2013 11:24:34 +0100
Message-Id: <1386757477-10333-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
References: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Compaction caches pfn's for its migrate and free scanners to avoid scanning
the whole zone each time. In compact_zone(), the cached values are read to
set up initial values for the scanners. There are several situations when
these cached pfn's are reset to the first and last pfn of the zone,
respectively. One of these situations is when a compaction has been deferred
for a zone and is now being restarted during a direct compaction, which is also
done in compact_zone().

However, compact_zone() currently reads the cached pfn's *before* resetting
them. This means the reset doesn't affect the compaction that performs it, and
with good chance also subsequent compactions, as update_pageblock_skip() is
likely to be called and update the cached pfn's to those being processed.
Another chance for a successful reset is when a direct compaction detects that
migration and free scanners meet (which has its own problems addressed by
another patch) and sets update_pageblock_skip flag which kswapd uses to do the
reset because it goes to sleep.

This is clearly a bug that results in non-deterministic behavior, so this patch
moves the cached pfn reset to be performed *before* the values are read.

Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e431804..3313cc8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -943,6 +943,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 
 	/*
+	 * Clear pageblock skip if there were failures recently and compaction
+	 * is about to be retried after being deferred. kswapd does not do
+	 * this reset as it'll reset the cached information when going to sleep.
+	 */
+	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+		__reset_isolation_suitable(zone);
+
+	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
 	 * information on where the scanners should start but check that it
 	 * is initialised by ensuring the values are within zone boundaries.
@@ -958,14 +966,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
 	}
 
-	/*
-	 * Clear pageblock skip if there were failures recently and compaction
-	 * is about to be retried after being deferred. kswapd does not do
-	 * this reset as it'll reset the cached information when going to sleep.
-	 */
-	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
-		__reset_isolation_suitable(zone);
-
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn, cc->free_pfn, end_pfn);
 
 	migrate_prep_local();
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
