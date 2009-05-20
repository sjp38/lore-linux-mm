Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9EA8B6B0088
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:40:55 -0400 (EDT)
Received: by pxi37 with SMTP id 37so398715pxi.12
        for <linux-mm@kvack.org>; Wed, 20 May 2009 03:41:33 -0700 (PDT)
Date: Wed, 20 May 2009 19:41:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] add inactive ratio calculation function of each
 zone
Message-Id: <20090520194121.535e8acc.minchan.kim@barrios-desktop>
In-Reply-To: <20090520103055.GB12433@csn.ul.ie>
References: <20090520161936.c86a0e38.minchan.kim@barrios-desktop>
	<20090520103055.GB12433@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 May 2009 11:30:56 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, May 20, 2009 at 04:19:36PM +0900, Minchan Kim wrote:
> > This patch divides setup_per_zone_inactive_ratio with
> > per zone inactive ratio calculaton.
> > 
> 
> Why? I'm guessing it's required by the next patch but a note here
> explaining why you need it would be nice.

OK. 

> The new function calculates the inactive ratio for one zone, not all zones,
> so a a more appropriate name would have been calculate_zone_inactive_ratio().

Indeed. I will modify function name with that. 

> Is the indenting for calculate_per_zone_inactive_ratio() in too far? It
> looks from the patch that it will be indented one tab too many.

Hmm. I can't understand your point due to my poor english. 
Could you explain more easily, please ?

> 
> > CC: Rik van Riel <riel@redhat.com>
> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  include/linux/mm.h |    1 +
> >  mm/page_alloc.c    |   14 +++++++++-----
> >  2 files changed, 10 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 1b2cb16..cede957 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1059,6 +1059,7 @@ extern void set_dma_reserve(unsigned long new_dma_reserve);
> >  extern void memmap_init_zone(unsigned long, int, unsigned long,
> >  				unsigned long, enum memmap_context);
> >  extern void setup_per_zone_wmark_min(void);
> > +extern void calculate_per_zone_inactive_ratio(struct zone* zone);
> >  extern void mem_init(void);
> >  extern void __init mmap_init(void);
> >  extern void show_mem(void);
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 273526b..4601ba0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4552,11 +4552,8 @@ void setup_per_zone_wmark_min(void)
> >   *    1TB     101        10GB
> >   *   10TB     320        32GB
> >   */
> > -static void __init setup_per_zone_inactive_ratio(void)
> > +void calculate_per_zone_inactive_ratio(struct zone* zone)
> >  {
> > -	struct zone *zone;
> > -
> > -	for_each_zone(zone) {
> >  		unsigned int gb, ratio;
> >  
> >  		/* Zone size in gigabytes */
> > @@ -4567,7 +4564,14 @@ static void __init setup_per_zone_inactive_ratio(void)
> >  			ratio = 1;
> >  
> >  		zone->inactive_ratio = ratio;
> > -	}
> > +}
> > +
> > +static void __init setup_per_zone_inactive_ratio(void)
> > +{
> > +	struct zone *zone;
> > +
> > +	for_each_zone(zone) 
> > +		calculate_per_zone_inactive_ratio(zone);
> >  }
> >  
> >  /*
> > -- 
> > 1.5.4.3
> > 
> > 
> > 
> > -- 
> > Kinds Regards
> > Minchan Kim
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
