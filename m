Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9D6B06B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 21:13:11 -0500 (EST)
Date: Mon, 25 Feb 2013 11:13:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: remove MIGRATE_ISOLATE check in hotpath
Message-ID: <20130225021308.GA6498@blaptop>
References: <1358209006-18859-1-git-send-email-minchan@kernel.org>
 <20130115153625.96265439.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130115153625.96265439.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>

Hi Andrew,

Sorry for late reply and I totally missed it. :(

On Tue, Jan 15, 2013 at 03:36:25PM -0800, Andrew Morton wrote:
> On Tue, 15 Jan 2013 09:16:46 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > Now mm several functions test MIGRATE_ISOLATE and some of those
> > are hotpath but MIGRATE_ISOLATE is used only if we enable
> > CONFIG_MEMORY_ISOLATION(ie, CMA, memory-hotplug and memory-failure)
> > which are not common config option. So let's not add unnecessary
> > overhead and code when we don't enable CONFIG_MEMORY_ISOLATION.
> 
> ugh.  Better than nothing, I guess.
> 
> There remain call sites which do open-coded
> 
> 	get_pageblock_migratetype(page) != MIGRATE_ISOLATE
> 
> (undo_isolate_page_range() is one).  Wanna clean these up as well?

Oops, Sure.

> 
> >
> > ...
> >
> > @@ -683,7 +683,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
> >  	zone->pages_scanned = 0;
> >  
> >  	__free_one_page(page, zone, order, migratetype);
> > -	if (unlikely(migratetype != MIGRATE_ISOLATE))
> > +	if (unlikely(!is_migrate_isolate(migratetype)))
> >  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> >  	spin_unlock(&zone->lock);
> >  }
> 
> The code both before and after this patch is assuming that the
> migratetype in free_one_page is likely to be MIGRATE_ISOLATE.  Seems
> wrong.  If CONFIG_MEMORY_ISOLATION=n this ends up doing
> if(unlikely(true)) which is harmless-but-amusing.

>From the beginning of [2139cbe627, cma: fix counting of isolated pages],
it was wrong. We can't make sure it's very likely.
If it is called by order-0 page free path, it is but if it is called by
high order page free path, we can't.
So I think it would be better to remove unlikley.

They are trivial patch so send it now or send it after you release
first mmotm after finishing merge window?

Andrew, Which is better?

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
