Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E781F6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 00:29:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e80so4780814oig.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 21:29:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t72si51292789ioe.52.2016.06.01.21.29.16
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 21:29:17 -0700 (PDT)
Date: Thu, 2 Jun 2016 13:29:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Why __alloc_contig_migrate_range calls migrate_prep() at first?
Message-ID: <20160602042916.GB3024@bbox>
References: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
 <20160601074010.GO19976@bbox>
 <231748d4-6d9b-85d9-6796-e4625582e148@foxmail.com>
 <20160602022242.GB9133@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160602022242.GB9133@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Wang Sheng-Hui <shhuiw@foxmail.com>, akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jun 02, 2016 at 11:22:43AM +0900, Joonsoo Kim wrote:
> On Thu, Jun 02, 2016 at 09:19:19AM +0800, Wang Sheng-Hui wrote:
> > 
> > 
> > On 6/1/2016 3:40 PM, Minchan Kim wrote:
> > > On Wed, Jun 01, 2016 at 11:42:29AM +0800, Wang Sheng-Hui wrote:
> > >> Dear,
> > >>
> > >> Sorry to trouble you.
> > >>
> > >> I noticed cma_alloc would turn to  __alloc_contig_migrate_range for allocating pages.
> > >> But  __alloc_contig_migrate_range calls  migrate_prep() at first, even if the requested page
> > >> is single and free, lru_add_drain_all still run (called by  migrate_prep())?
> > >>
> > >> Image a large chunk of free contig pages for CMA, various drivers may request a single page from
> > >> the CMA area, we'll get  lru_add_drain_all run for each page.
> > >>
> > >> Should we detect if the required pages are free before migrate_prep(), or detect at least for single 
> > >> page allocation?
> > > That makes sense to me.
> > >
> > > How about calling migrate_prep once migrate_pages fails in the first trial?
> > 
> > Minchan,
> > 
> > I tried your patch in my env, and the number of calling migrate_prep() dropped a lot.
> > 
> > In my case, CMA reserved 512MB, and the linux will call migrate_prep() 40~ times during bootup,
> > most are single page allocation request to CMA.
> > With your patch, migrate_prep() is not called for the single pages allocation requests as the free
> > pages in CMA area is enough.
> > 
> > Will you please push the patch to upstream?
> 
> It is not correct.
> 
> migrate_prep() is called to move lru pages in lruvec to LRU. In
> isolate_migratepages_range(), non LRU pages are just skipped so if
> page is on the lruvec it will not be isolated and error isn't returned.
> So, "if (ret) migrate_prep()" will not be called and we can't catch
> the page in lruvec.

Ah,, true. Thanks for correcting.

Simple fix is to remove migrate_prep in there and retry if test_pages_isolated
found migration is failed at least once.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7da8310b86e9..e0aa4a9b573d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7294,8 +7294,6 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 	unsigned int tries = 0;
 	int ret = 0;
 
-	migrate_prep();
-
 	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
@@ -7355,6 +7353,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	unsigned long outer_start, outer_end;
 	unsigned int order;
 	int ret = 0;
+	bool lru_flushed = false;
 
 	struct compact_control cc = {
 		.nr_migratepages = 0,
@@ -7395,6 +7394,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		return ret;
 
+again:
 	/*
 	 * In case of -EBUSY, we'd like to know which page causes problem.
 	 * So, just fall through. We will check it in test_pages_isolated().
@@ -7448,6 +7448,11 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
+		if (!lru_flushed) {
+			lru_flushed = true;
+			goto again;
+		}
+
 		pr_info("%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
 		ret = -EBUSY;


> 
> Anyway, better optimization for your case should be done in higher
> level. See following patch. It removes useless pageblock isolation and migration
> if possible. In fact, even we can do better than below by inroducing
> alloc_contig_range() light mode that skip migrate_prep() and other high cost things
> but it needs more surgery. I will revisit it soon.

Yes, there are many rooms to be improved in cma_alloc and I remember
a few years ago, some guys(maybe, graphic) complained cma_alloc for small order page
is really slow so it would be really worth to do.

I'm looking forward to seeing that.

> 
> Thanks.
> 
> ----------->8---------------
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1a7f110..4af3665 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7314,6 +7314,51 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
>                                 pageblock_nr_pages));
>  }
>  
> +static int alloc_contig_range_fast(unsigned long start, unsigned long end, struct compact_control *cc)
> +{
> +       unsigned int order;
> +       unsigned long outer_start, outer_end;
> +       int ret = 0;
> +
> +       order = 0;
> +       outer_start = start;
> +       while (!PageBuddy(pfn_to_page(outer_start))) {
> +               if (++order >= MAX_ORDER) {
> +                       outer_start = start;
> +                       break;
> +               }
> +               outer_start &= ~0UL << order;
> +       }
> +
> +       if (outer_start != start) {
> +               order = page_order(pfn_to_page(outer_start));
> +
> +               /*
> +                * outer_start page could be small order buddy page and
> +                * it doesn't include start page. Adjust outer_start
> +                * in this case to report failed page properly
> +                * on tracepoint in test_pages_isolated()
> +                */
> +               if (outer_start + (1UL << order) <= start)
> +                       outer_start = start;
> +       }
> +
> +       /* Grab isolated pages from freelists. */
> +       outer_end = isolate_freepages_range(cc, outer_start, end);
> +       if (!outer_end) {
> +               ret = -EBUSY;
> +               goto done;
> +       }
> +
> +       if (start != outer_start)
> +               free_contig_range(outer_start, start - outer_start);
> +       if (end != outer_end)
> +               free_contig_range(end, outer_end - end);
> +
> +done:
> +       return ret;
> +}
> +
>  /* [start, end) must belong to a single zone. */
>  static int __alloc_contig_migrate_range(struct compact_control *cc,
>                                         unsigned long start, unsigned long end)
> @@ -7390,6 +7435,9 @@ int alloc_contig_range(unsigned long start, unsigned long end)
>         };
>         INIT_LIST_HEAD(&cc.migratepages);
>  
> +       if (!alloc_contig_range_fast(start, end, &cc))
> +               return 0;
> +
>         /*
>          * What we do here is we mark all pageblocks in range as
>          * MIGRATE_ISOLATE.  Because pageblock and max order pages may
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
