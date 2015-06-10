Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id CF6516B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:33:20 -0400 (EDT)
Received: by wgme6 with SMTP id e6so31054137wgm.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:33:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si8533678wij.21.2015.06.10.02.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:33:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/6] mm, compaction: more robust check for scanners meeting
Date: Wed, 10 Jun 2015 11:32:29 +0200
Message-Id: <1433928754-966-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1433928754-966-1-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Compaction should finish when the migration and free scanner meet, i.e. they
reach the same pageblock. Currently however, the test in compact_finished()
simply just compares the exact pfns, which may yield a false negative when the
free scanner position is in the middle of a pageblock and the migration scanner
reaches the beginning of the same pageblock.

This hasn't been a problem until commit e14c720efdd7 ("mm, compaction: remember
position within pageblock in free pages scanner") allowed the free scanner
position to be in the middle of a pageblock between invocations.  The hot-fix
1d5bfe1ffb5b ("mm, compaction: prevent infinite loop in compact_zone")
prevented the issue by adding a special check in the migration scanner to
satisfy the current detection of scanners meeting.

However, the proper fix is to make the detection more robust. This patch
introduces the compact_scanners_met() function that returns true when the free
scanner position is in the same or lower pageblock than the migration scanner.
The special case in isolate_migratepages() introduced by 1d5bfe1ffb5b is
removed.

Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 16e1b57..d46aaeb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -902,6 +902,16 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
+ * Test whether the free scanner has reached the same or lower pageblock than
+ * the migration scanner, and compaction should thus terminate.
+ */
+static inline bool compact_scanners_met(struct compact_control *cc)
+{
+	return (cc->free_pfn >> pageblock_order)
+		<= (cc->migrate_pfn >> pageblock_order);
+}
+
+/*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
@@ -1131,12 +1141,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	}
 
 	acct_isolated(zone, cc);
-	/*
-	 * Record where migration scanner will be restarted. If we end up in
-	 * the same pageblock as the free scanner, make the scanners fully
-	 * meet so that compact_finished() terminates compaction.
-	 */
-	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
+	/* Record where migration scanner will be restarted. */
+	cc->migrate_pfn = low_pfn;
 
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
@@ -1151,7 +1157,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_PARTIAL;
 
 	/* Compaction run completes if the migrate and free scanner meet */
-	if (cc->free_pfn <= cc->migrate_pfn) {
+	if (compact_scanners_met(cc)) {
 		/* Let the next compaction start anew. */
 		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
 		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
@@ -1380,7 +1386,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			 * migrate_pages() may return -ENOMEM when scanners meet
 			 * and we want compact_finished() to detect it
 			 */
-			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
+			if (err == -ENOMEM && !compact_scanners_met(cc)) {
 				ret = COMPACT_PARTIAL;
 				goto out;
 			}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
