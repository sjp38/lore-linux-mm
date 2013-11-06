Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEA46B00C0
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 01:42:35 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp8so2504925pbb.31
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 22:42:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.139])
        by mx.google.com with SMTP id ll9si16328260pab.298.2013.11.05.22.42.31
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 22:42:32 -0800 (PST)
Date: Wed, 6 Nov 2013 15:43:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <20131106064302.GC30958@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
 <20131029093322.GA2400@suse.de>
 <20131105134448.7677d6febbfff4721373be4b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105134448.7677d6febbfff4721373be4b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, zhang.mingjun@linaro.org, m.szyprowski@samsung.com, haojian.zhuang@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>

Hello Andrew,

On Tue, Nov 05, 2013 at 01:44:48PM -0800, Andrew Morton wrote:
> On Tue, 29 Oct 2013 09:33:23 +0000 Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> > > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > > 
> > > free_contig_range frees cma pages one by one and MIGRATE_CMA pages will be
> > > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > > migration action when these pages reused by CMA.
> > > 
> > > Signed-off-by: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > > ---
> > >  mm/page_alloc.c |    3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 0ee638f..84b9d84 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int cold)
> > >  	 * excessively into the page allocator
> > >  	 */
> > >  	if (migratetype >= MIGRATE_PCPTYPES) {
> > > -		if (unlikely(is_migrate_isolate(migratetype))) {
> > > +		if (unlikely(is_migrate_isolate(migratetype))
> > > +			|| is_migrate_cma(migratetype))
> > >  			free_one_page(zone, page, 0, migratetype);
> > >  			goto out;
> > 
> > This slightly impacts the page allocator free path for a marginal gain
> > on CMA which are relatively rare allocations. There is no obvious
> > benefit to this patch as I expect CMA allocations to flush the PCP lists
> > when a range of pages have been isolated and migrated. Is there any
> > measurable benefit to this patch?
> 
> The added overhead is pretty small - just a comparison of a local with
> a constant.  And that cost is not incurred for MIGRATE_UNMOVABLE,
> MIGRATE_RECLAIMABLE and MIGRATE_MOVABLE, which are the common cases
> (yes?).

True but bloat code might affect icache so we should be careful.
And what Mel has a concern is about zone->lock, which would be more contended.
I agree his opinion.

In addition, I think the gain is marginal because normally CMA is big range
so free_contig_range in dma release path will fill per_cpu_pages with freed pages
easily so it could drain per_cpu_pages frequently so race which steal page from
per_cpu_pages is not big, I guess.

Morever, we could change free_contig_range with batch_free_page which would
be useful for other cases if they want to free many number of pages
all at once.

The bottom line is we need *number and real scenario* for that.

If it's really needed, after merging this patch, we could enhance it with
batch_free_page so we could solve Mel's concern, too.

> 
> This thread is a bit straggly and inconclusive, but it sounds to me
> that the benefit to CMA users is quite large and the cost to others is
> small, so I'm inclined to run with the original patch.  Someone stop me
> if that's wrong.

I want you to stop until we see the number.

> 
> (we could speed up some of the migratetype tests if the MIGRATE_foo
> constants were converted to bitfields.  The above test becomes "if
> (migratetype & (MIGRATE_CMA|MIGRATE_ISOLATE))").
> 
> (why is is_migrate_cma() implemented as a macro in mmzone.h while
> is_migrate_isolate() is an inline in page-isolation.h?)

Just preference?
I like inline than macro and that's why is_migrate_isolate was inline.

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
