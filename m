Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9580C6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 17:50:13 -0500 (EST)
Date: Mon, 25 Feb 2013 14:50:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: remove MIGRATE_ISOLATE check in hotpath
Message-Id: <20130225145011.68e55812.akpm@linux-foundation.org>
In-Reply-To: <20130225021308.GA6498@blaptop>
References: <1358209006-18859-1-git-send-email-minchan@kernel.org>
	<20130115153625.96265439.akpm@linux-foundation.org>
	<20130225021308.GA6498@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>

On Mon, 25 Feb 2013 11:13:08 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > 
> > >
> > > ...
> > >
> > > @@ -683,7 +683,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
> > >  	zone->pages_scanned = 0;
> > >  
> > >  	__free_one_page(page, zone, order, migratetype);
> > > -	if (unlikely(migratetype != MIGRATE_ISOLATE))
> > > +	if (unlikely(!is_migrate_isolate(migratetype)))
> > >  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> > >  	spin_unlock(&zone->lock);
> > >  }
> > 
> > The code both before and after this patch is assuming that the
> > migratetype in free_one_page is likely to be MIGRATE_ISOLATE.  Seems
> > wrong.  If CONFIG_MEMORY_ISOLATION=n this ends up doing
> > if(unlikely(true)) which is harmless-but-amusing.
> 
> >From the beginning of [2139cbe627, cma: fix counting of isolated pages],
> it was wrong. We can't make sure it's very likely.
> If it is called by order-0 page free path, it is but if it is called by
> high order page free path, we can't.
> So I think it would be better to remove unlikley.

Order-0 pages surely preponderate, so I'd say that "likely" is the way
to go.

I don't recall anyone ever demonstrating that likely/unlikely actually
does anything useful.  It would be interesting to have a play around,
see if it actually does good things to the code generation.

I think someone (perhaps in or near Dave Jones?) once had a patch which
added counters to likely/unlikely, so the kernel can accumulate and
then report upon the hit/miss ratio at each site.  iirc, an alarmingly
large number of the sites were deoptimisations!

> They are trivial patch so send it now or send it after you release
> first mmotm after finishing merge window?

It's in mainline now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
