Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D5E2C6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 09:22:37 -0500 (EST)
Date: Thu, 20 Dec 2012 14:22:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: compaction: Do not accidentally skip pageblocks in the
 migrate scanner
Message-ID: <20121220142232.GA13367@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Compaction uses the ALIGN macro incorrectly with the migrate scanner by
adding pageblock_nr_pages to a PFN. It happened to work when initially
implemented as the starting PFN was also aligned but with caching restarts
and isolating in smaller chunks this is no longer always true. The impact is
that the migrate scanner scans outside its current pageblock. As pfn_valid()
is still checked properly it does not cause any failure and the impact
of the bug is that in some cases it will scan more than necessary when
it crosses a page boundary but by no more than COMPACT_CLUSTER_MAX. It
is highly unlikely this is even measurable but it's still wrong so this
patch addresses the problem.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..cad98f6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -630,8 +630,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		continue;
 
 next_pageblock:
-		low_pfn += pageblock_nr_pages;
-		low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
+		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
 		last_pageblock_nr = pageblock_nr;
 	}
 
@@ -802,7 +801,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
 
 	/* Only scan within a pageblock boundary */
-	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
+	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
 
 	/* Do not cross the free scanner or scan within a memory hole */
 	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
