Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE228E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:33:12 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so2453105edz.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:33:12 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id l16si5565225edv.432.2019.01.16.06.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 06:33:10 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 3102B1C29D4
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 14:33:10 +0000 (GMT)
Date: Wed, 16 Jan 2019 14:33:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/25] mm, compaction: Use free lists to quickly locate a
 migration source
Message-ID: <20190116143308.GE27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-12-mgorman@techsingularity.net>
 <f1e0e977-d901-776d-9a6a-799735ebd3bf@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f1e0e977-d901-776d-9a6a-799735ebd3bf@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Wed, Jan 16, 2019 at 02:15:10PM +0100, Vlastimil Babka wrote:
> > <SNIP>
> > +			if (free_pfn < high_pfn) {
> > +				update_fast_start_pfn(cc, free_pfn);
> > +
> > +				/*
> > +				 * Avoid if skipped recently. Move to the tail
> > +				 * of the list so it will not be found again
> > +				 * soon
> > +				 */
> > +				if (get_pageblock_skip(freepage)) {
> > +
> > +					if (list_is_last(freelist, &freepage->lru))
> > +						break;
> > +
> > +					nr_skipped++;
> > +					list_del(&freepage->lru);
> > +					list_add_tail(&freepage->lru, freelist);
> 
> Use list$_move_tail() instead of del+add ?

Yep, that will work fine.

> Also is this even safe inside
> list_for_each_entry() and not list_for_each_entry_safe()? I guess
> without the extra safe iterator, we moved freepage, which is our
> iterator, to the tail, so the for cycle will immediately end?

This is an oversight. In an earlier iteration, it always terminated
after a list adjustment. This was abandoned and I should have used the
safe variant after that to avoid an early termination. Will fix.

> Also is this moving of one page needed when you also have
> move_freelist_tail() to move everything we scanned at once?
> 
> 
> > +					if (nr_skipped > 2)
> > +						break;
> 
> Counting number of skips per order seems weird. What's the intention, is
> it not to encounter again a page that we already moved to tail? That
> could be solved differently, e.g. using only move_freelist_tail()?
> 

The intention was to avoid searching a full list of pages that are
marked for skipping and to instead bail early. However, the benefit may
be marginal when the full series is taken into account so rather than
defend it, I'll remove it and readd in isolation iff I have better
supporting data for it.

I'm not going to rely on move_freelist_tail() only because that is used
after a candidate is found and the list terminates where as I want to
continue searching the freelist if the block has been marked for skip.

> > +					continue;
> > +				}
> > +
> > +				/* Reorder to so a future search skips recent pages */
> > +				move_freelist_tail(freelist, freepage);
> > +
> > +				pfn = pageblock_start_pfn(free_pfn);
> > +				cc->fast_search_fail = 0;
> > +				set_pageblock_skip(freepage);
> 
> Hmm with pageblock skip bit set, we return to isolate_migratepages(),
> and there's isolation_suitable() check which tests the skip bit, so
> AFAICS in the end we skip the pageblock we found here?
> 

Hmm, yes. This partially "worked" because the linear scan would continue
after but it starts in the wrong place so the search cost was still
reduced.

> > +				break;
> > +			}
> > +
> > +			/*
> > +			 * If low PFNs are being found and discarded then
> > +			 * limit the scan as fast searching is finding
> > +			 * poor candidates.
> > +			 */
> 
> I wonder about the "low PFNs are being found and discarded" part. Maybe
> I'm missing it, but I don't see them being discarded above, this seems
> to be the first check against cc->migrate_pfn. With the min() part in
> update_fast_start_pfn(), does it mean we can actually go back and rescan
> (or skip thanks to skip bits, anyway) again pageblocks that we already
> scanned?
> 

Extremely poor phrasing. My mind was thinking in terms of discarding
unsuitable candidates as they were below the migration scanner and it
did not translate properly.

Based on your feedback, how does the following untested diff look?

diff --git a/mm/compaction.c b/mm/compaction.c
index 6f649a3bd256..ccc38af323ab 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1572,16 +1572,15 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 	     order--) {
 		struct free_area *area = &cc->zone->free_area[order];
 		struct list_head *freelist;
-		unsigned long nr_skipped = 0;
 		unsigned long flags;
-		struct page *freepage;
+		struct page *freepage, *tmp;
 
 		if (!area->nr_free)
 			continue;
 
 		spin_lock_irqsave(&cc->zone->lock, flags);
 		freelist = &area->free_list[MIGRATE_MOVABLE];
-		list_for_each_entry(freepage, freelist, lru) {
+		list_for_each_entry_safe(freepage, tmp, freelist, lru) {
 			unsigned long free_pfn;
 
 			nr_scanned++;
@@ -1593,15 +1592,10 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 				 * soon
 				 */
 				if (get_pageblock_skip(freepage)) {
-
 					if (list_is_last(freelist, &freepage->lru))
 						break;
 
-					nr_skipped++;
-					list_del(&freepage->lru);
-					list_add_tail(&freepage->lru, freelist);
-					if (nr_skipped > 2)
-						break;
+					list_move_tail(&freepage->lru, freelist);
 					continue;
 				}
 
@@ -1616,9 +1610,11 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 			}
 
 			/*
-			 * If low PFNs are being found and discarded then
-			 * limit the scan as fast searching is finding
-			 * poor candidates.
+			 * PFNs below the migrate scanner are not suitable as
+			 * it may result in pageblocks being rescanned that
+			 * not necessarily marked for skipping. Limit the
+			 * search if unsuitable candidates are being found
+			 * on the freelist.
 			 */
 			if (free_pfn < cc->migrate_pfn)
 				limit >>= 1;
@@ -1659,6 +1655,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
 		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+	bool fast_find_block;
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
@@ -1670,6 +1667,13 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	if (block_start_pfn < zone->zone_start_pfn)
 		block_start_pfn = zone->zone_start_pfn;
 
+	/*
+	 * fast_find_migrateblock marks a pageblock skipped so to avoid
+	 * the isolation_suitable check below, check whether the fast
+	 * search was successful.
+	 */
+	fast_find_block = low_pfn != cc->migrate_pfn && !cc->fast_search_fail;
+
 	/* Only scan within a pageblock boundary */
 	block_end_pfn = pageblock_end_pfn(low_pfn);
 
@@ -1678,6 +1682,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 * Do not cross the free scanner.
 	 */
 	for (; block_end_pfn <= cc->free_pfn;
+			fast_find_block = false,
 			low_pfn = block_end_pfn,
 			block_start_pfn = block_end_pfn,
 			block_end_pfn += pageblock_nr_pages) {
@@ -1703,7 +1708,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * not scan the same block.
 		 */
 		if (IS_ALIGNED(low_pfn, pageblock_nr_pages) &&
-		    !isolation_suitable(cc, page))
+		    !fast_find_block && !isolation_suitable(cc, page))
 			continue;
 
 		/*
