Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D26586B0006
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 19:00:42 -0500 (EST)
Date: Tue, 26 Feb 2013 09:00:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: remove MIGRATE_ISOLATE check in hotpath
Message-ID: <20130226000040.GA17802@blaptop>
References: <1358209006-18859-1-git-send-email-minchan@kernel.org>
 <20130115153625.96265439.akpm@linux-foundation.org>
 <20130225021308.GA6498@blaptop>
 <20130225145011.68e55812.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130225145011.68e55812.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>

On Mon, Feb 25, 2013 at 02:50:11PM -0800, Andrew Morton wrote:
> On Mon, 25 Feb 2013 11:13:08 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > > 
> > > >
> > > > ...
> > > >
> > > > @@ -683,7 +683,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
> > > >  	zone->pages_scanned = 0;
> > > >  
> > > >  	__free_one_page(page, zone, order, migratetype);
> > > > -	if (unlikely(migratetype != MIGRATE_ISOLATE))
> > > > +	if (unlikely(!is_migrate_isolate(migratetype)))
> > > >  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> > > >  	spin_unlock(&zone->lock);
> > > >  }
> > > 
> > > The code both before and after this patch is assuming that the
> > > migratetype in free_one_page is likely to be MIGRATE_ISOLATE.  Seems
> > > wrong.  If CONFIG_MEMORY_ISOLATION=n this ends up doing
> > > if(unlikely(true)) which is harmless-but-amusing.
> > 
> > >From the beginning of [2139cbe627, cma: fix counting of isolated pages],
> > it was wrong. We can't make sure it's very likely.
> > If it is called by order-0 page free path, it is but if it is called by
> > high order page free path, we can't.
> > So I think it would be better to remove unlikley.
> 
> Order-0 pages surely preponderate, so I'd say that "likely" is the way
> to go.

Okay then, let's rule out high order allocation.
Firstly, let's look CONFIG_MEMORY_ISOLATION=y case.
In case of order-0, free_hot_cold_page calls free_one_page very unlikely.

void free_hot_cold_page ()
{
        ...
        if (migratetype >= MIGRATE_PCPTYPES) {
                if (unlikely(is_migrate_isolate(migratetype))) {
                        free_one_page(zone, page, 0, migratetype);
                        goto out;
                }
        ...
}

So, if free_one_page is called for order-0 page, it's for only MIGRATE_ISOLATE.
So unlikely(!is_migrate_isolate(migratetype)) in free_one_page does make sense
to me.

In case of CONFIG_MEMORY_ISOLATION=n case, below is_migrate_isolate is always
false so it could be compiled out so free_one_page is called only
for high order page free path. So if you don't mind high order free path
hitting on likely/unlikely, I think current code doesn't have any problem.

 if (migratetype >= MIGRATE_PCPTYPES) {
                if (unlikely(is_migrate_isolate(migratetype))) { ==> always false
                        free_one_page(zone, page, 0, migratetype);
                        goto out;
                }

In summary, if you don't care of high order free path, there is no problem.

> 
> I don't recall anyone ever demonstrating that likely/unlikely actually
> does anything useful.  It would be interesting to have a play around,
> see if it actually does good things to the code generation.

Yes. especially about page alloc/free path. 

> 
> I think someone (perhaps in or near Dave Jones?) once had a patch which
> added counters to likely/unlikely, so the kernel can accumulate and
> then report upon the hit/miss ratio at each site.  iirc, an alarmingly
> large number of the sites were deoptimisations!

It seems you mean "Branch Profiling (Trace likely/unlikely profiler)" made by
Steven Rostedt. Anyway, it's a rather troublesome job and needs many workload
but worthy. Will queue it up to my future TODO. :)

> 
> > They are trivial patch so send it now or send it after you release
> > first mmotm after finishing merge window?
> 
> It's in mainline now.

I will send fix about only undo_isolate_page_range if you don't object my
above opinion.

Thanks.

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
