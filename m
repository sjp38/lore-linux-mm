Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1E7AB6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:19:44 -0400 (EDT)
Date: Wed, 11 Jul 2012 16:18:00 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm v3] mm: have order > 0 compaction start off where it
 left
Message-ID: <20120711161800.763dbef0@cuia.bos.redhat.com>
In-Reply-To: <4FF3F864.3000204@kernel.org>
References: <20120628135520.0c48b066@annuminas.surriel.com>
	<20120628135940.2c26ada9.akpm@linux-foundation.org>
	<4FECCB89.2050400@redhat.com>
	<20120628143546.d02d13f9.akpm@linux-foundation.org>
	<1341250950.16969.6.camel@lappy>
	<4FF2435F.2070302@redhat.com>
	<20120703101024.GG13141@csn.ul.ie>
	<20120703144808.4daa4244.akpm@linux-foundation.org>
	<4FF3ABA1.3070808@kernel.org>
	<20120704004219.47d0508d.akpm@linux-foundation.org>
	<4FF3F864.3000204@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

This patch makes the comment for cc->wrapped longer, explaining
what is really going on. It also incorporates the comment fix
pointed out by Minchan.

Additionally, Minchan found that, when no pages get isolated,
high_pte could be a value that is much lower than desired,
which might potentially cause compaction to skip a range of
pages.

Only assign zone->compact_cache_free_pfn if we actually
isolated free pages for compaction.

Split out the calculation to get the start of the last page
block in a zone into its own, commented function.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h |    2 +-
 mm/compaction.c        |   30 ++++++++++++++++++++++--------
 mm/internal.h          |    6 +++++-
 3 files changed, 28 insertions(+), 10 deletions(-)

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
index 2668b77..3812c3e 100644
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
@@ -569,6 +570,21 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
+/*
+ * Returns the start pfn of the laste page block in a zone.
+ * This is the starting point for full compaction of a zone.
+ * Compaction searches for free pages from the end of each zone,
+ * while isolate_freepages_block scans forward inside each page
+ * block.
+ */
+static unsigned long start_free_pfn(struct zone *zone)
+{
+	unsigned long free_pfn;
+	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	free_pfn &= ~(pageblock_nr_pages-1);
+	return free_pfn;
+}
+
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -587,10 +603,9 @@ static int compact_finished(struct zone *zone,
 	if (cc->free_pfn <= cc->migrate_pfn) {
 		if (cc->order > 0 && !cc->wrapped) {
 			/* We started partway through; restart at the end. */
-			unsigned long free_pfn;
-			free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-			free_pfn &= ~(pageblock_nr_pages-1);
+			unsigned long free_pfn = start_free_pfn(zone);
 			zone->compact_cached_free_pfn = free_pfn;
+			cc->free_pfn = free_pfn;
 			cc->wrapped = 1;
 			return COMPACT_CONTINUE;
 		}
@@ -703,8 +718,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		cc->start_free_pfn = cc->free_pfn;
 	} else {
 		/* Order == -1 starts at the end of the zone. */
-		cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
-		cc->free_pfn &= ~(pageblock_nr_pages-1);
+		cc->free_pfn = start_free_pfn(zone);
 	}
 
 	migrate_prep_local();
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
