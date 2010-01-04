Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8096C600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:46:42 -0500 (EST)
Date: Mon, 4 Jan 2010 11:46:09 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as
 necessary
In-Reply-To: <20100104095820.GA6373@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001041143550.7191@router.home>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com> <20100104122138.f54b7659.minchan.kim@barrios-desktop> <20100104144332.96A2.A69D9226@jp.fujitsu.com> <20100104095820.GA6373@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010, Mel Gorman wrote:

> > Why can't we write following? __mod_zone_page_state() only require irq
> > disabling, it doesn't need spin lock. I think.

Correct.

> > commit f2260e6b (page allocator: update NR_FREE_PAGES only as necessary)
> > made one minor regression.
> > if __rmqueue() was failed, NR_FREE_PAGES stat go wrong. this patch fixes
> > it.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Huang Shijie <shijie8@gmail.com>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 11ae66e..ecf75a1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1227,10 +1227,10 @@ again:
> >  		}
> >  		spin_lock_irqsave(&zone->lock, flags);
> >  		page = __rmqueue(zone, order, migratetype);
> > -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
> >  		spin_unlock(&zone->lock);
> >  		if (!page)
> >  			goto failed;
> > +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
> >  	}
> >
> >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
