Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CDD686B0072
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:04 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so41208104pdc.3
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:04 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id n11si42270329pdl.134.2015.06.24.17.42.54
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 02/10] mm/compaction: skip useless pfn for scanner's cached pfn
Date: Thu, 25 Jun 2015 09:45:13 +0900
Message-Id: <1435193121-25880-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Scanner's cached pfn is used to determine the start position of scanner
at next compaction run. Current cached pfn points the skipped pageblock
so we uselessly checks whether pageblock is valid for compaction and
skip-bit is set or not. If we set scanner's cached pfn to next pfn of
skipped pageblock, we don't need to do this check.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4397bf7..9c5d43c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -265,7 +265,6 @@ static void update_pageblock_skip(struct compact_control *cc,
 			unsigned long curr_pfn, bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
-	unsigned long pfn;
 
 	if (cc->ignore_skip_hint)
 		return;
@@ -285,18 +284,16 @@ static void update_pageblock_skip(struct compact_control *cc,
 
 	set_pageblock_skip(page);
 
-	pfn = page_to_pfn(page);
-
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
-		if (pfn > zone->compact_cached_migrate_pfn[0])
-			zone->compact_cached_migrate_pfn[0] = pfn;
+		if (end_pfn > zone->compact_cached_migrate_pfn[0])
+			zone->compact_cached_migrate_pfn[0] = end_pfn;
 		if (cc->mode != MIGRATE_ASYNC &&
-		    pfn > zone->compact_cached_migrate_pfn[1])
-			zone->compact_cached_migrate_pfn[1] = pfn;
+		    end_pfn > zone->compact_cached_migrate_pfn[1])
+			zone->compact_cached_migrate_pfn[1] = end_pfn;
 	} else {
-		if (pfn < zone->compact_cached_free_pfn)
-			zone->compact_cached_free_pfn = pfn;
+		if (start_pfn < zone->compact_cached_free_pfn)
+			zone->compact_cached_free_pfn = start_pfn;
 	}
 }
 #else
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
