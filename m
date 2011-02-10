Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD858D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 04:36:13 -0500 (EST)
Date: Thu, 10 Feb 2011 09:35:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: batch-free pcp list if possible
Message-ID: <20110210093544.GA17873@csn.ul.ie>
References: <1297257677-12287-1-git-send-email-namhyung@gmail.com> <20110209123803.4bb6291c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110209123803.4bb6291c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Feb 09, 2011 at 12:38:03PM -0800, Andrew Morton wrote:
> On Wed,  9 Feb 2011 22:21:17 +0900
> Namhyung Kim <namhyung@gmail.com> wrote:
> 
> > free_pcppages_bulk() frees pages from pcp lists in a round-robin
> > fashion by keeping batch_free counter. But it doesn't need to spin
> > if there is only one non-empty list. This can be checked by
> > batch_free == MIGRATE_PCPTYPES.
> > 
> > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > ---
> >  mm/page_alloc.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a873e61e312e..470fb42e303c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -614,6 +614,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			list = &pcp->lists[migratetype];
> >  		} while (list_empty(list));
> >  
> > +		/* This is an only non-empty list. Free them all. */
> > +		if (batch_free == MIGRATE_PCPTYPES)
> > +			batch_free = to_free;
> > +
> >  		do {
> >  			page = list_entry(list->prev, struct page, lru);
> >  			/* must delete as __free_one_page list manipulates */
> 
> free_pcppages_bulk() hurts my brain.
> 

I vaguely recall trying to make it easier to understand. Each attempt
made it easier to read, but slower. At the time there were complaints
about the overhead of the page allocator so making it slower was not an
option. "Overhead" was what oprofile reported as the time spent in each
function.

> What is it actually trying to do, and why? It counts up the number of
> contiguous empty lists and then frees that number of pages from the
> first-encountered non-empty list and then advances onto the next list?
> 

Yes. This is potentially unfair because lists for one migratetype can get
drained heavier than others. However, checking empty lists was showing up as
a reasonably significant cost according to profiles for allocator-intensive
workloads. I *think* the workload I was using was netperf-based.

> What's the point in that?  What relationship does the number of
> contiguous empty lists have with the number of pages to free from one
> list?
> 

The point is to avoid excessive checking of empty lists. There is no
relationship between the number of empty lists and the size of the next
list. The size of the lists is related to the workload and the resulting
allocator/free pattern.

> The comment "This is so more pages are freed off fuller lists instead
> of spinning excessively around empty lists" makes no sense - the only
> way this can be true is if the code knows the number of elements on
> each list, and it doesn't know that.
> 

batch_free gets preserved if a list empties so if batch_free was 2 but
there was only 1 page on the next list, more pages are taken off a
larger list. We know what the total size of all the lists are so there
are always pages to find. You're right in that we don't know the size of
individual lists because space in the pcp structure is tight.

> Also, the covering comments over free_pcppages_bulk() regarding the
> pages_scanned counter and the "all pages pinned" logic appear to be out
> of date.  Or, alternatively, those comments do reflect the desired
> design, but we broke it.
> 

This comment is really old.... heh, you introduced it back in 2.5.49
apparently.

The comment is referring to the clearing of all_unreclaimable. By clearing it,
kswapd will scan that zone again and set all_unreclaimable back if necessary
and that is still valid.

More importantly, if there is another process in direct reclaim and it failed
to reclaim any pages, the clearing of all_unreclaimable will avoid the direct
reclaimer entering OOM.

The comment could be better but it doesn't look wrong, just not
particularly helpful.

> Methinks that free_pcppages_bulk() is an area ripe for simplification
> and clarification.
> 

Probably but any patch that simplifies it needs to be accompanied with
profiles of an allocator-intensive workload showing it's not worse as a result.

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
