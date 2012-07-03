Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id EA8226B0093
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 16:13:39 -0400 (EDT)
Date: Tue, 3 Jul 2012 16:13:04 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] mm: minor fixes for compaction
Message-ID: <20120703161304.7734fbef@annuminas.surriel.com>
In-Reply-To: <4FECE844.2050803@kernel.org>
References: <20120628135520.0c48b066@annuminas.surriel.com>
	<4FECE844.2050803@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com

This patch makes the comment for cc->wrapped longer, explaining
what is really going on. It also incorporates the comment fix
pointed out by Minchan.

Additionally, Minchan found that, when no pages get isolated,
high_pte could be a value that is much lower than desired,
which might potentially cause compaction to skip a range of
pages.

Only assign zone->compact_cache_free_pfn if we actually
isolated free pages for compaction.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
This does not address the one bit in Minchan's review that I am not sure about...

 include/linux/mmzone.h |    2 +-
 mm/compaction.c        |    7 ++++---
 mm/internal.h          |    6 +++++-
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e629594..e957fa1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -370,7 +370,7 @@ struct zone {
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
-	/* pfn where the last order > 0 compaction isolated free pages */
+	/* pfn where the last incremental compaction isolated free pages */
 	unsigned long		compact_cached_free_pfn;
 #endif
 #ifdef CONFIG_MEMORY_HOTPLUG
diff --git a/mm/compaction.c b/mm/compaction.c
index 2668b77..2867166 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -472,10 +472,11 @@ static void isolate_freepages(struct zone *zone,
 		 * looking for free pages, the search will restart here as
 		 * page migration may have returned some pages to the allocator
 		 */
-		if (isolated)
+		if (isolated) {
 			high_pfn = max(high_pfn, pfn);
-		if (cc->order > 0)
-			zone->compact_cached_free_pfn = high_pfn;
+			if (cc->order > 0)
+				zone->compact_cached_free_pfn = high_pfn;
+		}
 	}
 
 	/* split_free_page does not map the pages */
diff --git a/mm/internal.h b/mm/internal.h
index 0b72461..da6b9b2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -121,7 +121,11 @@ struct compact_control {
 	unsigned long start_free_pfn;	/* where we started the search */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
-	bool wrapped;			/* Last round for order>0 compaction */
+	bool wrapped;			/* Order > 0 compactions are
+					   incremental, once free_pfn
+					   and migrate_pfn meet, we restart
+					   from the top of the zone;
+					   remember we wrapped around. */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
