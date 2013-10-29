Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 05F7F6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 08:27:20 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id z10so3769193pdj.5
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 05:27:20 -0700 (PDT)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id qk4si15729786pac.235.2013.10.29.05.27.18
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 05:27:19 -0700 (PDT)
Date: Tue, 29 Oct 2013 12:27:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <20131029122708.GD2400@suse.de>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
 <20131029093322.GA2400@suse.de>
 <CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Mingjun <zhang.mingjun@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

On Tue, Oct 29, 2013 at 07:49:30PM +0800, Zhang Mingjun wrote:
> On Tue, Oct 29, 2013 at 5:33 PM, Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> > > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > >
> > > free_contig_range frees cma pages one by one and MIGRATE_CMA pages will
> > be
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
> > > @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int
> > cold)
> > >        * excessively into the page allocator
> > >        */
> > >       if (migratetype >= MIGRATE_PCPTYPES) {
> > > -             if (unlikely(is_migrate_isolate(migratetype))) {
> > > +             if (unlikely(is_migrate_isolate(migratetype))
> > > +                     || is_migrate_cma(migratetype))
> > >                       free_one_page(zone, page, 0, migratetype);
> > >                       goto out;
> >
> > This slightly impacts the page allocator free path for a marginal gain
> > on CMA which are relatively rare allocations. There is no obvious
> > benefit to this patch as I expect CMA allocations to flush the PCP lists
> >
> how about keeping the migrate type of CMA page block as MIGRATE_ISOLATED
> after
> the alloc_contig_range , and undo_isolate_page_range at the end of
> free_contig_range?

It would move the cost to the CMA paths so I would complain less. Bear
in mind as well that forcing everything to go through free_one_page()
means that every free goes through the zone lock. I doubt you have any
machine large enough but it is possible for simultaneous CMA allocations
to now contend on the zone lock that would have been previously fine.
Hence, I'm interesting in knowing the underlying cause of the problem you
are experiencing.

> of course, it will waste the memory outside of the alloc range but in the
> pageblocks.
> 

I would hope/expect that the loss would only last for the duration of
the allocation attempt and a small amount of memory.

> > when a range of pages have been isolated and migrated. Is there any
> > measurable benefit to this patch?
> >
> after applying this patch, the video player on my platform works more
> fluent,

fluent almost always refers to ones command of a spoken language. I do
not see how a video player can be fluent in anything. What is measurably
better?

For example, are allocations faster? If so, why? What cost from another
path is removed as a result of this patch? If the cost is in the PCP
flush then can it be checked if the PCP flush was unnecessary and called
unconditionally even though all the pages were freed already? We had
problems in the past where drain_all_pages() or similar were called
unnecessarily causing long sync stalls related to IPIs. I'm wondering if
we are seeing a similar problem here.

Maybe the problem is the complete opposite. Are allocations failing
because there are PCP pages in the way? In that case, it real fix might
be to insert a PCP flush if the allocation is failing due to per-cpu
pages.

> and the driver of video decoder on my test platform using cma alloc/free
> frequently.
> 

CMA allocations are almost never used outside of these contexts. While I
appreciate that embedded use is important I'm reluctant to see an impact
in fast paths unless there is a good reason for every other use case. I
also am a bit unhappy to see CMA allocations making the zone->lock
hotter than necessary even if no embedded use case it likely to
experience the problem in the short-term.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
