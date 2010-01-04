Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED2D600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 04:58:33 -0500 (EST)
Date: Mon, 4 Jan 2010 09:58:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as
	necessary
Message-ID: <20100104095820.GA6373@csn.ul.ie>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com> <20100104122138.f54b7659.minchan.kim@barrios-desktop> <20100104144332.96A2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100104144332.96A2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 04, 2010 at 02:52:36PM +0900, KOSAKI Motohiro wrote:
> > Hi, Huang. 
> > 
> > On Mon,  4 Jan 2010 10:22:10 +0800
> > Huang Shijie <shijie8@gmail.com> wrote:
> > 
> > > When the `page' returned by __rmqueue() is NULL, the origin code
> > > still adds -(1 << order) to zone's NR_FREE_PAGES item.
> > > 
> > > The patch fixes it.
> > > 
> > > Signed-off-by: Huang Shijie <shijie8@gmail.com>
> > > ---
> > >  mm/page_alloc.c |   10 +++++++---
> > >  1 files changed, 7 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 4e9f5cc..620921d 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1222,10 +1222,14 @@ again:
> > >  		}
> > >  		spin_lock_irqsave(&zone->lock, flags);
> > >  		page = __rmqueue(zone, order, migratetype);
> > > -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
> > > -		spin_unlock(&zone->lock);
> > > -		if (!page)
> > > +		if (likely(page)) {
> > > +			__mod_zone_page_state(zone, NR_FREE_PAGES,
> > > +						-(1 << order));
> > > +			spin_unlock(&zone->lock);
> > > +		} else {
> > > +			spin_unlock(&zone->lock);
> > >  			goto failed;
> > > +		}
> > >  	}
> > >  
> > >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> > 
> > I think it's not desirable to add new branch in hot-path even though
> > we could avoid that. 
> > 
> > How about this?
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4e4b5b3..87976ad 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1244,6 +1244,9 @@ again:
> >         return page;
> >  
> >  failed:
> > +       spin_lock(&zone->lock);
> > +       __mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> > +       spin_unlock(&zone->lock);
> >         local_irq_restore(flags);
> >         put_cpu();
> >         return NULL;
> 
> Why can't we write following? __mod_zone_page_state() only require irq
> disabling, it doesn't need spin lock. I think.
> 

Adding Christoph to be sure but yes, as this is a per-cpu variable it
should be safe to update with __mod_zone_page_state() as long as
interrupts and preempt are disabled. If true, then this is a neater fix
and is also needed for -stable 2.6.31 and 2.6.32.

Well spotted and thanks.

> From 72011ff2b0bba6544ae35c6ee52715c8c824a34b Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Mon, 4 Jan 2010 14:38:20 +0900
> Subject: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
> 
> commit f2260e6b (page allocator: update NR_FREE_PAGES only as necessary)
> made one minor regression.
> if __rmqueue() was failed, NR_FREE_PAGES stat go wrong. this patch fixes
> it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Huang Shijie <shijie8@gmail.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 11ae66e..ecf75a1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1227,10 +1227,10 @@ again:
>  		}
>  		spin_lock_irqsave(&zone->lock, flags);
>  		page = __rmqueue(zone, order, migratetype);
> -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  		spin_unlock(&zone->lock);
>  		if (!page)
>  			goto failed;
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  	}
>  
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> -- 
> 1.6.5.2
> 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
