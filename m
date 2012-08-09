Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 731D86B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 04:23:33 -0400 (EDT)
Date: Thu, 9 Aug 2012 09:23:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/5] mm: have order > 0 compaction start near a pageblock
 with free pages
Message-ID: <20120809082328.GC12690@suse.de>
References: <1344452924-24438-1-git-send-email-mgorman@suse.de>
 <1344452924-24438-6-git-send-email-mgorman@suse.de>
 <20120809001212.GB17835@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120809001212.GB17835@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 09:12:12AM +0900, Minchan Kim wrote:
> > <SNIP>
> > 
> > Second, it updates compact_cached_free_pfn in a more limited set of
> > circumstances.
> > 
> > If a scanner has wrapped, it updates compact_cached_free_pfn to the end
> > 	of the zone. When a wrapped scanner isolates a page, it updates
> > 	compact_cached_free_pfn to point to the highest pageblock it
> > 	can isolate pages from.
> 
> Okay until here.
> 

Great.

> > 
> > If a scanner has not wrapped when it has finished isolated pages it
> > 	checks if compact_cached_free_pfn is pointing to the end of the
> > 	zone. If so, the value is updated to point to the highest
> > 	pageblock that pages were isolated from. This value will not
> > 	be updated again until a free page scanner wraps and resets
> > 	compact_cached_free_pfn.
> 
> I tried to understand your intention of this part but unfortunately failed.
> By this part, the problem you mentioned could happen again?
> 

Potentially yes, I did say it still races in the changelog.

>  				    			C
>  Process A		M     S     			F
>  		|---------------------------------------|
>  Process B		M 	FS
>  
>  C is zone->compact_cached_free_pfn
>  S is cc->start_pfree_pfn
>  M is cc->migrate_pfn
>  F is cc->free_pfn
> 
> In this diagram, Process A has just reached its migrate scanner, wrapped
> around and updated compact_cached_free_pfn to end of the zone accordingly.
> 

Yes. Now that it has wrapped it updates the compact_cached_free_pfn
every loop of isolate_freepages here.

                if (isolated) {
                        high_pfn = max(high_pfn, pfn);

                        /*
                         * If the free scanner has wrapped, update
                         * compact_cached_free_pfn to point to the highest
                         * pageblock with free pages. This reduces excessive
                         * scanning of full pageblocks near the end of the
                         * zone
                         */
                        if (cc->order > 0 && cc->wrapped)
                                zone->compact_cached_free_pfn = high_pfn;
                }



> Simultaneously, Process B finishes isolating in a block and peek 
> compact_cached_free_pfn position and know it's end of the zone so
> update compact_cached_free_pfn to highest pageblock that pages were
> isolated from.
> 

Yes, they race at this point. One of two things happen here and I agree
that this is racy

1. Process A does another iteration of its loop and sets it back
2. Process A does not do another iteration of the loop, the cached_pfn
   is further along that it should. The next compacting process will
   wrap early and reset cached_pfn again but continue to scan the zone.

Either option is relatively harmless because in both cases the zone gets
scanned. In patch 4 it was possible that large portions of the zone were
frequently missed.

> Process A updates compact_cached_free_pfn to the highest pageblock which
> was set by process B because process A has wrapped. It ends up big jump
> without any scanning in process A.
> 

It recovers quickly and is nowhere near as severe as what patch 4
suffers from.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
