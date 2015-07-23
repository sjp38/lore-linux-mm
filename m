Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9F86B0262
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:17:04 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so153523056pdj.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:17:04 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id b1si6215016pat.26.2015.07.22.22.17.02
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 22:17:03 -0700 (PDT)
Date: Thu, 23 Jul 2015 14:21:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_owner: set correct gfp_mask on page_owner
Message-ID: <20150723052128.GB4449@js1304-P5Q-DELUXE>
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20150716000613.GE988@bgram>
 <55ACDB3B.8010607@suse.cz>
 <20150720115352.GA13474@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150720115352.GA13474@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, all.

On Mon, Jul 20, 2015 at 08:54:13PM +0900, Minchan Kim wrote:
> On Mon, Jul 20, 2015 at 01:27:55PM +0200, Vlastimil Babka wrote:
> > On 07/16/2015 02:06 AM, Minchan Kim wrote:
> > >On Wed, Jul 15, 2015 at 03:33:59PM +0900, Joonsoo Kim wrote:
> > >>@@ -2003,7 +2005,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
> > >>  	zone->free_area[order].nr_free--;
> > >>  	rmv_page_order(page);
> > >>
> > >>-	set_page_owner(page, order, 0);
> > >>+	set_page_owner(page, order, __GFP_MOVABLE);
> > >
> > >It seems the reason why  __GFP_MOVABLE is okay is that __isolate_free_page
> > >works on a free page on MIGRATE_MOVABLE|MIGRATE_CMA's pageblock. But if we
> > >break the assumption in future, here is broken again?
> > 
> > I didn't study the page owner code yet and I'm catching up after
> > vacation, but I share your concern. But I don't think the
> > correctness depends on the pageblock we are isolating from. I think
> > the assumption is that the isolated freepage will be used as a
> > target for migration, and that only movable pages can be
> > successfully migrated (but also CMA pages, and that information can
> > be lost?). However there are also efforts to allow migrate e.g.
> > driver pages that won't be marked as movable. And I'm not sure which
> > migratetype are balloon pages which already have special migration
> > code.

FYI, migratetype of ballon pages is also MIGRATE_MOVABLE if balloon
compaction is enabled.

> I am one of people who want to migrate driver pages from compaction
> from zram point of view so I agree with you.
> However, If I make zram support migratepages, I will use __GFP_MOVABLE.
> So, I'm not sure there is any special driver that it can support migrate
> via migratepage but it doesn't set __GFP_MOVABLE.
> 
> Having said that, I support your opinion because __GFP_MOVABLE is not
> only gfp mask for allocating so we should take care of complete gfp
> mask from original page.

Ah... In this patch, I've solved the issue very narrowly. It works for
me to get correct fragmentation information but not generally correct.
It's my mistake.

There is another information like as stack trace so I should take care
of it, too. I will handle it in migration function.

> 
> > 
> > So what I would think (without knowing all details) that the page
> > owner info should be transferred during page migration with all the
> > other flags, and shouldn't concern __isolate_free_page() at all?
> > 
> 
> I agree.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
