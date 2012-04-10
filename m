Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4B3DF6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 06:38:38 -0400 (EDT)
Date: Tue, 10 Apr 2012 11:38:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: compaction: try harder to isolate free pages
Message-ID: <20120410103833.GE3789@suse.de>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
 <1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, Apr 05, 2012 at 06:32:12PM +0200, Bartlomiej Zolnierkiewicz wrote:
> In isolate_freepages() check each page in a pageblock
> instead of checking only first pages of pageblock_nr_pages
> intervals (suitable_migration_target(page) is called before
> isolate_freepages_block() so if page is "unsuitable" whole
> pageblock_nr_pages pages will be ommited from the check).
> It greatly improves possibility of finding free pages to
> isolate during compaction_alloc() phase.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/compaction.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d9ebebe..bc77135 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -65,7 +65,7 @@ static unsigned long isolate_freepages_block(struct zone *zone,
>  
>  	/* Get the last PFN we should scan for free pages at */
>  	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> -	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
> +	end_pfn = min(blockpfn + 1, zone_end_pfn);
>  
>  	/* Find the first usable PFN in the block to initialse page cursor */
>  	for (; blockpfn < end_pfn; blockpfn++) {

This changes the meaning of the function significantly. Before your
patch it isolates all the free pages within a block. After your change
it is isolating a single page and the function name should be updated to
reflect that. Of greater concern is that isolate_freepages()
is now calling suitable_migration_target() for every page scanned
calling get_pageblock_migratetype() every time which is slow. Worse, you
are now acquiring the zone lock for every page scanned which is slower
again.

I think the bug you are accidentally fixing is related to how high_pfn
is updated inside that loop. The intent is that when free pages are
isolated that the next scan started from the same place as page
migration may have released those pages again. As it gets updated every
time a page is isolated the scanner is moving faster than it should.

Try this;

diff --git a/mm/compaction.c b/mm/compaction.c
index 74a8c82..177e161 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -139,6 +139,7 @@ static void isolate_freepages(struct zone *zone,
 	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
+	bool first_isolation = true;
 
 	/*
 	 * Initialise the free scanner. The starting point is where we last
@@ -201,8 +202,10 @@ static void isolate_freepages(struct zone *zone,
 		 * looking for free pages, the search will restart here as
 		 * page migration may have returned some pages to the allocator
 		 */
-		if (isolated)
+		if (isolated && first_isolation) {
+			first_isolation = false;
 			high_pfn = max(high_pfn, pfn);
+		}
 	}
 
 	/* split_free_page does not map the pages */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
