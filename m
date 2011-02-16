Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3B38D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 22:01:47 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p1G31jtF030653
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:01:45 -0800
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe16.cbf.corp.google.com with ESMTP id p1G31cO3016421
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:01:43 -0800
Received: by pxi19 with SMTP id 19so111902pxi.1
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:01:38 -0800 (PST)
Date: Tue, 15 Feb 2011 19:01:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] - Improve drain pages performance on large systems
In-Reply-To: <AANLkTim+rjN8GMwOV5MLeVjXaevHmCciAc5DwQXgiO62@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1102151858580.19953@chino.kir.corp.google.com>
References: <20110215223840.GA27420@sgi.com> <AANLkTim+rjN8GMwOV5MLeVjXaevHmCciAc5DwQXgiO62@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-1485521709-1297825218=:19953"
Content-ID: <alpine.DEB.2.00.1102151900250.19953@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-1485521709-1297825218=:19953
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1102151900251.19953@chino.kir.corp.google.com>

On Wed, 16 Feb 2011, Minchan Kim wrote:

> > Index: linux/mm/page_alloc.c
> > ===================================================================
> > --- linux.orig/mm/page_alloc.c A 2011-02-15 16:28:36.165921713 -0600
> > +++ linux/mm/page_alloc.c A  A  A  2011-02-15 16:29:43.085502487 -0600
> > @@ -592,10 +592,24 @@ static void free_pcppages_bulk(struct zo
> > A  A  A  A int batch_free = 0;
> > A  A  A  A int to_free = count;
> >
> > + A  A  A  /*
> > + A  A  A  A * Quick scan of zones. If all are empty, there is nothing to do.
> > + A  A  A  A */
> > + A  A  A  for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++) {
> > + A  A  A  A  A  A  A  struct list_head *list;
> > +
> > + A  A  A  A  A  A  A  list = &pcp->lists[migratetype];
> > + A  A  A  A  A  A  A  if (!list_empty(list))
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  }
> > + A  A  A  if (migratetype == MIGRATE_PCPTYPES)
> > + A  A  A  A  A  A  A  return;
> > +
> > A  A  A  A spin_lock(&zone->lock);
> > A  A  A  A zone->all_unreclaimable = 0;
> > A  A  A  A zone->pages_scanned = 0;
> >
> > + A  A  A  migratetype = 0;
> > A  A  A  A while (to_free) {
> > A  A  A  A  A  A  A  A struct page *page;
> > A  A  A  A  A  A  A  A struct list_head *list;
> 
> It does make sense to me.
> Although new code looks to be rather costly in small box, anyway we
> use the same logic  in while loop so cache would be hot. so cost would
> be little.
> 

I was going to mention the implications for small machines as well, this 
doesn't look good for callers that know free_pcppages_bulk() will do 
something.

> But how about this? This one never affect fast-critical path.
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

Right, this is 2ff754fa upstream.  I'm wondering if Jack still sees the 
same problem since 2.6.38-rc3.
--531368966-1485521709-1297825218=:19953--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
