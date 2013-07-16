Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 72A2B6B003D
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:42:07 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/10] mm: zone_reclaim: compaction: reset before initializing the scan cursors
Date: Tue, 16 Jul 2013 15:41:48 +0200
Message-Id: <1373982114-19774-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

Correct the location where we reset the scan cursors, otherwise the
first iteration of compaction (after restarting it) will only do a
partial scan.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rafael Aquini <aquini@redhat.com>
---
 mm/compaction.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 525baaa..afaf692 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -934,6 +934,17 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 
 	/*
+	 * Clear pageblock skip if there were failures recently and
+	 * compaction is about to be retried after being
+	 * deferred. kswapd does not do this reset and it will wait
+	 * direct compaction to do so either when the cursor meets
+	 * after one compaction pass is complete or if compaction is
+	 * restarted after being deferred for a while.
+	 */
+	if ((compaction_restarting(zone, cc->order)) && !current_is_kswapd())
+		__reset_isolation_suitable(zone);
+
+	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
 	 * information on where the scanners should start but check that it
 	 * is initialised by ensuring the values are within zone boundaries.
@@ -949,14 +960,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
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
 	migrate_prep_local();
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
