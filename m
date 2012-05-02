Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D4E066B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 02:23:18 -0400 (EDT)
Date: Wed, 2 May 2012 08:23:09 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/5] mm: refault distance-based file cache sizing
Message-ID: <20120502062308.GN2536@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <1335861713-4573-6-git-send-email-hannes@cmpxchg.org>
 <20120502015741.GE22923@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120502015741.GE22923@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 02, 2012 at 03:57:41AM +0200, Andrea Arcangeli wrote:
> On Tue, May 01, 2012 at 10:41:53AM +0200, Johannes Weiner wrote:
> > frequently used active page.  Instead, for each refault with a
> > distance smaller than the size of the active list, we deactivate an
> 
> Shouldn't this be the size of active list + size of inactive list?
> 
> If the active list is 500M, inactive 500M and the new working set is
> 600M, the refault distance will be 600M, it won't be smaller than the
> size of the active list, and it won't deactivate the active list as it
> should and it won't be detected as working set.
> 
> Only the refault distance bigger than inactive+active should not
> deactivate the active list if I understand how this works correctly.

The refault distance is what's missing, not the full reuse frequency.
You ignore the 500M worth of inactive LRU time the page had in memory.
The distance in that scenario would be 100M, the time between eviction
and refault:

        +-----------------------------++-----------------------------+
        |                             ||                             |
        | inactive                    || active                      |
        +-----------------------------++-----------------------------+
+~~~~~~~------------------------------+
|                                     |
| new set                             |
+~~~~~~~------------------------------+
^       ^
|       |
|       eviction
refault

The ~~~'d part could fit into memory if the active list was 100M
smaller.

> > @@ -1726,6 +1728,11 @@ zonelist_scan:
> >  		if ((alloc_flags & ALLOC_CPUSET) &&
> >  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> >  				continue;
> > +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> > +		    current->refault_distance &&
> > +		    !workingset_zone_alloc(zone, current->refault_distance,
> > +					   &distance, &active))
> > +			continue;
> >  		/*
> >  		 * When allocating a page cache page for writing, we
> >  		 * want to get it from a zone that is within its dirty
> 
> It's a bit hard to see how this may not run oom prematurely if the
> distance is always bigger, this is just an implementation question and
> maybe I'm missing a fallback somewhere where we actually allocate
> memory from whatever place in case no place is ideal.

Sorry, this should be documented better.

The ALLOC_WMARK_LOW check makes sure this only applies in the
fastpath.  It will prepare reclaim with lruvec->shrink_active, then
wake up kswapd and retry the zonelist without this constraint.

> > +	/*
> > +	 * Lower zones may not even be full, and free pages are
> > +	 * potential inactive space, too.  But the dirty reserve is
> > +	 * not available to page cache due to lowmem reserves and the
> > +	 * kswapd watermark.  Don't include it.
> > +	 */
> > +	zone_free = zone_page_state(zone, NR_FREE_PAGES);
> > +	if (zone_free > zone->dirty_balance_reserve)
> > +		zone_free -= zone->dirty_balance_reserve;
> > +	else
> > +		zone_free = 0;
> 
> Maybe also remove the high wmark from the sum? It can be some hundred
> meg so it's better to take it into account, to have a more accurate
> math and locate the best zone that surely fits.
> 
> For the same reason it looks like the lowmem reserve should also be
> taken into account, on the full sum.

dirty_balance_reserve IS the sum of the high watermark and the biggest
lowmem reserve for a particular zone, see how it's calculated in
mm/page_alloc.c::calculate_totalreserve_pages().

nr_free - dirty_balance_reserve is the number of pages available to
page cache allocations without keeping kswapd alive or having to dip
into lowmem reserves.

Or did I misunderstand you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
