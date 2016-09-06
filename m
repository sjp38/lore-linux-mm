Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C12482F64
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:53:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so80468522wmz.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:53:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jg8si10102888wjb.4.2016.09.06.06.53.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:53:20 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/4] mm, compaction: make full priority ignore pageblock suitability
Date: Tue,  6 Sep 2016 15:52:58 +0200
Message-Id: <20160906135258.18335-5-vbabka@suse.cz>
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>

Several people have reported premature OOMs for order-2 allocations (stack)
due to OOM rework in 4.7. In the scenario (parallel kernel build and dd writing
to two drives) many pageblocks get marked as Unmovable and compaction free
scanner struggles to isolate free pages. Joonsoo Kim pointed out that the free
scanner skips pageblocks that are not movable to prevent filling them and
forcing non-movable allocations to fallback to other pageblocks. Such heuristic
makes sense to help prevent long-term fragmentation, but premature OOMs are
relatively more urgent problem. As a compromise, this patch disables the
heuristic only for the ultimate compaction priority.

Reported-by: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Reported-by: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reported-by: Olaf Hering <olaf@aepfle.de>
Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 11 ++++++++---
 mm/internal.h   |  1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 29f6c49dc9c2..86d4d0bbfc7c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -997,8 +997,12 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 #ifdef CONFIG_COMPACTION
 
 /* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+static bool suitable_migration_target(struct compact_control *cc,
+							struct page *page)
 {
+	if (cc->ignore_block_suitable)
+		return true;
+
 	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page)) {
 		/*
@@ -1083,7 +1087,7 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		if (!suitable_migration_target(cc, page))
 			continue;
 
 		/* If isolation recently failed, do not retry */
@@ -1656,7 +1660,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
 		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
-		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY)
+		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
+		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
diff --git a/mm/internal.h b/mm/internal.h
index 5214bf8e3171..537ac9951f5f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -178,6 +178,7 @@ struct compact_control {
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool ignore_block_suitable;	/* Scan blocks considered unsuitable */
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	int order;			/* order a direct compactor needs */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
