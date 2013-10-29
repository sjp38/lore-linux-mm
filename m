Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3FC6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 03:25:11 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so3120244pbc.16
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 00:25:10 -0700 (PDT)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id iu9si15051444pac.176.2013.10.29.00.25.08
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 00:25:10 -0700 (PDT)
Date: Tue, 29 Oct 2013 16:25:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <20131029072511.GA6030@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
 <20131029045430.GE17038@bbox>
 <CAGT3LeqEzMKeq5PYz+Dv-rCBsTuUAtttyvYZu4UYWsAkUn8urQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGT3LeqEzMKeq5PYz+Dv-rCBsTuUAtttyvYZu4UYWsAkUn8urQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Mingjun <zhang.mingjun@linaro.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Oct 29, 2013 at 03:00:09PM +0800, Zhang Mingjun wrote:
> On Tue, Oct 29, 2013 at 12:54 PM, Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hello,
> >
> > On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> > > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > >
> > > free_contig_range frees cma pages one by one and MIGRATE_CMA pages will
> > be
> > > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > > migration action when these pages reused by CMA.
> >
> > You are saying about the overhead but I'm not sure how much it is
> > because it wouldn't be frequent. Although it's frequent, migration is
> > already slow path and CMA migration is worse so I really wonder how much
> > pain is and how much this patch improve.
> >
> > Having said that, it makes CMA allocation policy consistent which
> > is that CMA migration type is last fallback to minimize number of migration
> > and code peice you are adding is already low hit path so that I think
> > it has no problem.
> >
> problem is when free_contig_range frees cma pages, page's migration type is
> MIGRATE_CMA!
> I don't know why free_contig_range free pages one by one, but in the end it
> calls free_hot_cold_page,
> so some of these MIGRATE_CMA pages will be used as MIGRATE_MOVEABLE, this
> break the CMA
> allocation policy and it's not the low hit path, it's really the hot path,
> in fact each time free_contig_range calls
> some of these CMA pages will stay on this pcp list.
> when filesytem needs a pagecache or page fault exception which alloc one
> page using alloc_pages(MOVABLE, 0)
> it will get the page from this pcp list, breaking the CMA fallback rules,
> that is CMA pages in pcp list using as
> page cache or annoymous page very easily.


It seems you misunderstood me. My English was poor?
I already said that I agree with you.
Your patch has no impact with hot path and makes CMA allocation policy
consistent so that there is no objection.

> 
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
> >
> > The concern is likely/unlikely usage is proper in this code peice.
> > If we don't use memory isolation, the code path is used for only
> > MIGRATE_RESERVE which is very rare allocation in normal workload.
> >
> > Even, in memory isolation environement, I'm not sure how many
> > CMA/HOTPLUG is used compared to normal alloc/free.
> > So, I think below is more proper?
> >
> > if (unlikely(migratetype >= MIGRATE_PCPTYPES)) {
> >         if (is_migrate_isolate(migratetype) || is_migrate_cma(migratetype))
> >
> > if CMA is enabled and alloc/free frequently, it will more likely
> migratetype >= MIGRATE_PCPTYPES

Until now, I didn't notice there is such workload. Do you have such real workload?
If so, we should change it with following as?

if (migratetype >= MIGRATE_PCPTYPES) {
        if (is_migrate_cma(migratetype) || unlikely(is_migrate_isolate(migratetype)))

Because assumption is you insist that there is lots of alloc/free for CMA.
But since we have had unlikely on memory-hotplug check, it would be less than CMA.



> 
> I know it's an another topic but I'd like to disucss it in this time because
> > we will forget such trivial thing later, again.
> >
> > }
> >
> > >                       free_one_page(zone, page, 0, migratetype);
> > >                       goto out;
> > >               }
> > > --
> > > 1.7.9.5
> > >
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
> >

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
