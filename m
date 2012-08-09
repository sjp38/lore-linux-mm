Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E41016B005D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 04:45:40 -0400 (EDT)
Date: Thu, 9 Aug 2012 17:47:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm: have order > 0 compaction start near a pageblock
 with free pages
Message-ID: <20120809084717.GC21033@bbox>
References: <1344452924-24438-1-git-send-email-mgorman@suse.de>
 <1344452924-24438-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344452924-24438-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 08:08:44PM +0100, Mel Gorman wrote:
> commit [7db8889a: mm: have order > 0 compaction start off where it left]
> introduced a caching mechanism to reduce the amount work the free page
> scanner does in compaction. However, it has a problem. Consider two process
> simultaneously scanning free pages
> 
> 				    			C
> Process A		M     S     			F
> 		|---------------------------------------|
> Process B		M 	FS
> 
> C is zone->compact_cached_free_pfn
> S is cc->start_pfree_pfn
> M is cc->migrate_pfn
> F is cc->free_pfn
> 
> In this diagram, Process A has just reached its migrate scanner, wrapped
> around and updated compact_cached_free_pfn accordingly.
> 
> Simultaneously, Process B finishes isolating in a block and updates
> compact_cached_free_pfn again to the location of its free scanner.
> 
> Process A moves to "end_of_zone - one_pageblock" and runs this check
> 
>                 if (cc->order > 0 && (!cc->wrapped ||
>                                       zone->compact_cached_free_pfn >
>                                       cc->start_free_pfn))
>                         pfn = min(pfn, zone->compact_cached_free_pfn);
> 
> compact_cached_free_pfn is above where it started so the free scanner skips
> almost the entire space it should have scanned. When there are multiple
> processes compacting it can end in a situation where the entire zone is
> not being scanned at all.  Further, it is possible for two processes to
> ping-pong update to compact_cached_free_pfn which is just random.
> 
> Overall, the end result wrecks allocation success rates.
> 
> There is not an obvious way around this problem without introducing new
> locking and state so this patch takes a different approach.
> 
> First, it gets rid of the skip logic because it's not clear that it matters
> if two free scanners happen to be in the same block but with racing updates
> it's too easy for it to skip over blocks it should not.
> 
> Second, it updates compact_cached_free_pfn in a more limited set of
> circumstances.
> 
> If a scanner has wrapped, it updates compact_cached_free_pfn to the end
> 	of the zone. When a wrapped scanner isolates a page, it updates
> 	compact_cached_free_pfn to point to the highest pageblock it
> 	can isolate pages from.
> 
> If a scanner has not wrapped when it has finished isolated pages it
> 	checks if compact_cached_free_pfn is pointing to the end of the
> 	zone. If so, the value is updated to point to the highest
> 	pageblock that pages were isolated from. This value will not
> 	be updated again until a free page scanner wraps and resets
> 	compact_cached_free_pfn.
> 
> This is not optimal and it can still race but the compact_cached_free_pfn
> will be pointing to or very near a pageblock with free pages.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
