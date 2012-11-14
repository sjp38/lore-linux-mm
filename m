Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1419C6B00AB
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 16:44:21 -0500 (EST)
Date: Wed, 14 Nov 2012 22:43:40 +0100
From: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Subject: Re: [PATCH] Revert "mm: vmscan: scale number of pages reclaimed by
 reclaim/compaction based on failures"
Message-ID: <20121114224340.5f7cee78@fem.tu-ilmenau.de>
In-Reply-To: <20121109083637.GD8218@suse.de>
References: <5077434D.7080008@suse.cz>
	<50780F26.7070007@suse.cz>
	<20121012135726.GY29125@suse.de>
	<507BDD45.1070705@suse.cz>
	<20121015110937.GE29125@suse.de>
	<5093A3F4.8090108@redhat.com>
	<5093A631.5020209@suse.cz>
	<509422C3.1000803@suse.cz>
	<20121105142449.GI8218@suse.de>
	<20121106111554.1896c3f3@fem.tu-ilmenau.de>
	<20121109083637.GD8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zdenek Kabelac <zkabelac@redhat.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Jiri Slaby <jslaby@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Am Fri, 9 Nov 2012 08:36:37 +0000
schrieb Mel Gorman <mgorman@suse.de>:

> On Tue, Nov 06, 2012 at 11:15:54AM +0100, Johannes Hirte wrote:
> > Am Mon, 5 Nov 2012 14:24:49 +0000
> > schrieb Mel Gorman <mgorman@suse.de>:
> > 
> > > Jiri Slaby reported the following:
> > > 
> > > 	(It's an effective revert of "mm: vmscan: scale number of
> > > pages reclaimed by reclaim/compaction based on failures".) Given
> > > kswapd had hours of runtime in ps/top output yesterday in the
> > > morning and after the revert it's now 2 minutes in sum for the
> > > last 24h, I would say, it's gone.
> > > 
> > > The intention of the patch in question was to compensate for the
> > > loss of lumpy reclaim. Part of the reason lumpy reclaim worked is
> > > because it aggressively reclaimed pages and this patch was meant
> > > to be a sane compromise.
> > > 
> > > When compaction fails, it gets deferred and both compaction and
> > > reclaim/compaction is deferred avoid excessive reclaim. However,
> > > since commit c6543459 (mm: remove __GFP_NO_KSWAPD), kswapd is
> > > woken up each time and continues reclaiming which was not taken
> > > into account when the patch was developed.
> > > 
> > > Attempts to address the problem ended up just changing the shape
> > > of the problem instead of fixing it. The release window gets
> > > closer and while a THP allocation failing is not a major problem,
> > > kswapd chewing up a lot of CPU is. This patch reverts "mm:
> > > vmscan: scale number of pages reclaimed by reclaim/compaction
> > > based on failures" and will be revisited in the future.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/vmscan.c |   25 -------------------------
> > >  1 file changed, 25 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 2624edc..e081ee8 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1760,28 +1760,6 @@ static bool in_reclaim_compaction(struct
> > > scan_control *sc) return false;
> > >  }
> > >  
> > > -#ifdef CONFIG_COMPACTION
> > > -/*
> > > - * If compaction is deferred for sc->order then scale the number
> > > of pages
> > > - * reclaimed based on the number of consecutive allocation
> > > failures
> > > - */
> > > -static unsigned long scale_for_compaction(unsigned long
> > > pages_for_compaction,
> > > -			struct lruvec *lruvec, struct
> > > scan_control *sc) -{
> > > -	struct zone *zone = lruvec_zone(lruvec);
> > > -
> > > -	if (zone->compact_order_failed <= sc->order)
> > > -		pages_for_compaction <<=
> > > zone->compact_defer_shift;
> > > -	return pages_for_compaction;
> > > -}
> > > -#else
> > > -static unsigned long scale_for_compaction(unsigned long
> > > pages_for_compaction,
> > > -			struct lruvec *lruvec, struct
> > > scan_control *sc) -{
> > > -	return pages_for_compaction;
> > > -}
> > > -#endif
> > > -
> > >  /*
> > >   * Reclaim/compaction is used for high-order allocation
> > > requests. It reclaims
> > >   * order-0 pages before compacting the zone.
> > > should_continue_reclaim() returns @@ -1829,9 +1807,6 @@ static
> > > inline bool should_continue_reclaim(struct lruvec *lruvec,
> > >  	 * inactive lists are large enough, continue reclaiming
> > >  	 */
> > >  	pages_for_compaction = (2UL << sc->order);
> > > -
> > > -	pages_for_compaction =
> > > scale_for_compaction(pages_for_compaction,
> > > -						    lruvec, sc);
> > >  	inactive_lru_pages = get_lru_size(lruvec,
> > > LRU_INACTIVE_FILE); if (nr_swap_pages > 0)
> > >  		inactive_lru_pages += get_lru_size(lruvec,
> > > LRU_INACTIVE_ANON); --
> > 
> > Even with this patch I see kswapd0 very often on top. Much more than
> > with kernel 3.6.
> 
> How severe is the CPU usage? The higher usage can be explained by "mm:
> remove __GFP_NO_KSWAPD" which allows kswapd to compact memory to
> reduce the amount of time processes spend in compaction but will
> result in the CPU cost being incurred by kswapd.
> 
> Is it really high like the bug was reporting with high usage over long
> periods of time or do you just see it using 2-6% of CPU for short
> periods?

It is really high. I've seen with compile-jobs (make -j4 on dual
core) kswapd0 consuming at least 50% CPU most time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
