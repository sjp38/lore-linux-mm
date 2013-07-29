Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id AC0A76B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:24:48 -0400 (EDT)
Date: Mon, 29 Jul 2013 18:24:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130729222439.GZ715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
 <20130729174820.GF3476@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130729174820.GF3476@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 29, 2013 at 07:48:21PM +0200, Andrea Arcangeli wrote:
> Hi Johannes,
> 
> On Fri, Jul 19, 2013 at 04:55:25PM -0400, Johannes Weiner wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index af1d956b..d938b67 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1879,6 +1879,14 @@ zonelist_scan:
> >  		if (alloc_flags & ALLOC_NO_WATERMARKS)
> >  			goto try_this_zone;
> >  		/*
> > +		 * Distribute pages in proportion to the individual
> > +		 * zone size to ensure fair page aging.  The zone a
> > +		 * page was allocated in should have no effect on the
> > +		 * time the page has in memory before being reclaimed.
> > +		 */
> > +		if (atomic_read(&zone->alloc_batch) <= 0)
> > +			continue;
> > +		/*
> >  		 * When allocating a page cache page for writing, we
> >  		 * want to get it from a zone that is within its dirty
> >  		 * limit, such that no single zone holds more than its
> 
> I rebased the zone_reclaim_mode and compaction fixes on top of the
> zone fair allocator (it applied without rejects, lucky) but the above
> breaks zone_reclaim_mode (it regress for pagecache too, which
> currently works), so then in turn my THP/compaction tests break too.

Ah yeah, we spill too eagerly to other nodes when we should try to
reclaim the local one first.

> zone_reclaim_mode isn't LRU-fair, and cannot be... (even migrating
> cache around nodes to try to keep LRU fariness would not be worth it,
> especially with ssds). But we can still increase the fairness within
> the zones of the current node (for those nodes that have more than 1
> zone).
> 
> I think to fix it we need an additional first pass of the fast path,
> and if alloc_batch is <= 0 for any zone in the current node, we then
> forbid allocating from the zones not in the current node (even if
> alloc_batch would allow it) during the first pass, only if
> zone_reclaim_mode is enabled. If first pass fails, we need to reset
> alloc_batch for all zones in the current node (and only in the current
> zone), goto zonelist_scan and continue as we do now.

How sensible are the various settings of zone_reclaim_mode and the way
zone reclaim is invoked right now?

zone_reclaim_mode == 1 tries to reclaim clean page cache in the
preferred zone before falling back to other zones.  Great, kswapd also
tries clean cache first and avoids writeout and swapping as long as
possible.  And if zone_reclaim() fails, kswapd has to be woken up
anyway because filling remote zones without reclaiming them is hardly
sustainable.  Using kswapd would have the advantage that it reclaims
the whole local node and not just the first zone in it, which would
make much more sense in the first place.

Same for zone_reclaim_mode at higher settings.

So could we cut all this short and just restrict any allocation with
zone_reclaim_mode != 0 to zones in reclaim distance, and if that
fails, wake kswapd and enter the slowpath? (ALLOC_WMARK_LOW marks the
fast path)

It would be even cooler to remove the zone_reclaim() call further
down, but that might be too much reliance on kswapd...

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f03d2f2..8ddf9ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1875,6 +1875,10 @@ zonelist_scan:
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (alloc_flags & ALLOC_NO_WATERMARKS)
 			goto try_this_zone;
+		if ((alloc_flags & ALLOC_WMARK_LOW) &&
+		    zone_reclaim_mode &&
+		    !zone_allows_reclaim(preferred_zone, zone))
+			continue;
 		/*
 		 * Distribute pages in proportion to the individual
 		 * zone size to ensure fair page aging.  The zone a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
