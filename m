Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0526B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 14:06:35 -0400 (EDT)
Date: Sun, 5 Sep 2010 19:06:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters
	after pages are placed on the free list
Message-ID: <20100905180619.GE8384@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-2-git-send-email-mel@csn.ul.ie> <20100903153859.52cd1b97.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100903153859.52cd1b97.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 03:38:59PM -0700, Andrew Morton wrote:
> On Fri,  3 Sep 2010 10:08:44 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -588,12 +588,12 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  {
> >  	int migratetype = 0;
> >  	int batch_free = 0;
> > +	int freed = count;
> >  
> >  	spin_lock(&zone->lock);
> >  	zone->all_unreclaimable = 0;
> >  	zone->pages_scanned = 0;
> >  
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> >  	while (count) {
> >  		struct page *page;
> >  		struct list_head *list;
> > @@ -621,6 +621,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> >  		} while (--count && --batch_free && !list_empty(list));
> >  	}
> > +	__mod_zone_page_state(zone, NR_FREE_PAGES, freed);
> >  	spin_unlock(&zone->lock);
> >  }
> >  
> 
> nit: this is why it's evil to modify the value of incoming args.  It's
> nicer to leave them alone and treat them as const across the lifetime
> of the callee.
> 

Ok, I can see the logic of that.

> Can I do this?
> 
> --- a/mm/page_alloc.c~mm-page-allocator-update-free-page-counters-after-pages-are-placed-on-the-free-list-fix
> +++ a/mm/page_alloc.c
> @@ -588,13 +588,13 @@ static void free_pcppages_bulk(struct zo
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> -	int freed = count;
> +	int to_free = count;
>  
>  	spin_lock(&zone->lock);
>  	zone->all_unreclaimable = 0;
>  	zone->pages_scanned = 0;
>  
> -	while (count) {
> +	while (to_free) {
>  		struct page *page;
>  		struct list_head *list;
>  
> @@ -619,9 +619,9 @@ static void free_pcppages_bulk(struct zo
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>  			__free_one_page(page, zone, 0, page_private(page));
>  			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> -		} while (--count && --batch_free && !list_empty(list));
> +		} while (--to_free && --batch_free && !list_empty(list));
>  	}
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, freed);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
>  	spin_unlock(&zone->lock);
>  }

Yes you can. I see no problem with this alteration.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
