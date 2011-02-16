Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E6A858D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 10:44:15 -0500 (EST)
Date: Wed, 16 Feb 2011 09:43:04 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Improve drain pages performance on large systems
Message-ID: <20110216154303.GA27261@sgi.com>
References: <20110215223840.GA27420@sgi.com> <AANLkTim+rjN8GMwOV5MLeVjXaevHmCciAc5DwQXgiO62@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTim+rjN8GMwOV5MLeVjXaevHmCciAc5DwQXgiO62@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

On Wed, Feb 16, 2011 at 09:00:59AM +0900, Minchan Kim wrote:
> On Wed, Feb 16, 2011 at 7:38 AM, Jack Steiner <steiner@sgi.com> wrote:
> >
> > Heavy swapping within a cpuset causes frequent calls to drain_all_pages().
> > This sends IPIs to all cpus to free PCP pages. In most cases, there are
> > no pages to be freed on cpus outside of the swapping cpuset.
> >
> > Add checks to minimize locking and updates to potentially hot cachelines.
> > Before acquiring locks, do a quick check to see if any pages are in the PCP
> > queues. Exit if none.
> >
> > On a 128 node SGI UV system, this reduced the IPI overhead to cpus outside of the
> > swapping cpuset by 38% and improved time to run a pass of the swaping test
> > from 98 sec to 51 sec. These times are obviously test & configuration
> > dependent but the improvements are significant.
> >
> >
> > Signed-off-by: Jack Steiner <steiner@sgi.com>
> >
> > ---
> >  mm/page_alloc.c |   14 ++++++++++++++
> >  1 file changed, 14 insertions(+)
> >
> > Index: linux/mm/page_alloc.c
> > ===================================================================
> > --- linux.orig/mm/page_alloc.c  2011-02-15 16:28:36.165921713 -0600
> > +++ linux/mm/page_alloc.c       2011-02-15 16:29:43.085502487 -0600
> > @@ -592,10 +592,24 @@ static void free_pcppages_bulk(struct zo
> >        int batch_free = 0;
> >        int to_free = count;
> >
> > +       /*
> > +        * Quick scan of zones. If all are empty, there is nothing to do.
> > +        */
> > +       for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++) {
> > +               struct list_head *list;
> > +
> > +               list = &pcp->lists[migratetype];
> > +               if (!list_empty(list))
> > +                       break;
> > +       }
> > +       if (migratetype == MIGRATE_PCPTYPES)
> > +               return;
> > +
> >        spin_lock(&zone->lock);
> >        zone->all_unreclaimable = 0;
> >        zone->pages_scanned = 0;
> >
> > +       migratetype = 0;
> >        while (to_free) {
> >                struct page *page;
> >                struct list_head *list;
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> It does make sense to me.
> Although new code looks to be rather costly in small box, anyway we
> use the same logic  in while loop so cache would be hot. so cost would
> be little.
> 
> But how about this? This one never affect fast-critical path.

Yes. Much cleaner. And even better, as David points out it is already in the tree. 

I did my original testing on a 2.6.32 distro kernel & missed the fact that this was
recently fixed upstream. 

My patch from yesterday can be discarded.

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ff7e158..2dfb61a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1095,8 +1095,10 @@ static void drain_pages(unsigned int cpu)
>                 pset = per_cpu_ptr(zone->pageset, cpu);
> 
>                 pcp = &pset->pcp;
> -               free_pcppages_bulk(zone, pcp->count, pcp);
> -               pcp->count = 0;
> +               if (pcp->count > 0) {
> +                       free_pcppages_bulk(zone, pcp->count, pcp);
> +                       pcp->count = 0;
> +               }
>                 local_irq_restore(flags);
>         }
>  }
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
