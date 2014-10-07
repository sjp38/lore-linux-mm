Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 32C536B0073
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:02 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so9595517wgg.8
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si14557122wie.69.2014.10.07.08.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/5] mm, compaction: always update cached scanner positions
Date: Tue,  7 Oct 2014 17:33:38 +0200
Message-Id: <1412696019-21761-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Compaction caches the migration and free scanner positions between compaction
invocations, so that the whole zone gets eventually scanned and there is no
bias towards the initial scanner positions at the beginning/end of the zone.

The cached positions are continuously updated as scanners progress and the
updating stops as soon as a page is successfully isolated. The reasoning
behind this is that a pageblock where isolation succeeded is likely to succeed
again in near future and it should be worth revisiting it.

However, the downside is that potentially many pages are rescanned without
successful isolation. At worst, there might be a page where isolation from LRU
succeeds but migration fails (potentially always). So upon encountering this
page, cached position would always stop being updated for no good reason.
It might have been useful to let such page be rescanned with sync compaction
after async one failed, but this is now handled by caching scanner position
for async and sync mode separately since commit 35979ef33931 ("mm, compaction:
add per-zone migration pfn cache for async compaction").

After this patch, cached positions are updated unconditionally. In
stress-highalloc benchmark, this has decreased the numbers of scanned pages
by few percent, without affecting allocation success rates.

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
 mm/compaction.c | 14 --------------
 mm/internal.h   |  5 -----
 2 files changed, 19 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9107588..8fa888d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -195,16 +195,12 @@ static void update_pageblock_skip(struct compact_control *cc,
 
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
-		if (cc->finished_update_migrate)
-			return;
 		if (pfn > zone->compact_cached_migrate_pfn[0])
 			zone->compact_cached_migrate_pfn[0] = pfn;
 		if (cc->mode != MIGRATE_ASYNC &&
 		    pfn > zone->compact_cached_migrate_pfn[1])
 			zone->compact_cached_migrate_pfn[1] = pfn;
 	} else {
-		if (cc->finished_update_free)
-			return;
 		if (pfn < zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = pfn;
 	}
@@ -705,7 +701,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 
 isolate_success:
-		cc->finished_update_migrate = true;
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
@@ -876,15 +871,6 @@ static void isolate_freepages(struct compact_control *cc)
 				block_start_pfn - pageblock_nr_pages;
 
 		/*
-		 * Set a flag that we successfully isolated in this pageblock.
-		 * In the next loop iteration, zone->compact_cached_free_pfn
-		 * will not be updated and thus it will effectively contain the
-		 * highest pageblock we isolated pages from.
-		 */
-		if (isolated)
-			cc->finished_update_free = true;
-
-		/*
 		 * isolate_freepages_block() might have aborted due to async
 		 * compaction being contended
 		 */
diff --git a/mm/internal.h b/mm/internal.h
index 3cc9b0a..4928beb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -136,11 +136,6 @@ struct compact_control {
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
-	bool finished_update_free;	/* True when the zone cached pfns are
-					 * no longer being updated
-					 */
-	bool finished_update_migrate;
-
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const int alloc_flags;		/* alloc flags of a direct compactor */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
