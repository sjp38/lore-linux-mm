Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32FB56B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:22:17 -0500 (EST)
Received: by padfa1 with SMTP id fa1so3630814pad.2
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:22:16 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rf11si10308420pdb.199.2015.02.16.21.22.15
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 21:22:16 -0800 (PST)
Date: Tue, 17 Feb 2015 14:24:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 07/16] mm/page_isolation: watch out zone range overlap
Message-ID: <20150217052446.GB15413@js1304-P5Q-DELUXE>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1423726340-4084-8-git-send-email-iamjoonsoo.kim@lge.com>
 <54DD9C48.90803@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54DD9C48.90803@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Feb 13, 2015 at 03:40:08PM +0900, Gioh Kim wrote:
> 
> > diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> > index c8778f7..883e78d 100644
> > --- a/mm/page_isolation.c
> > +++ b/mm/page_isolation.c
> > @@ -210,8 +210,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
> >    * Returns 1 if all pages in the range are isolated.
> >    */
> >   static int
> > -__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
> > -				  bool skip_hwpoisoned_pages)
> > +__test_page_isolated_in_pageblock(struct zone *zone, unsigned long pfn,
> > +			unsigned long end_pfn, bool skip_hwpoisoned_pages)
> >   {
> >   	struct page *page;
> >   
> > @@ -221,6 +221,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
> >   			continue;
> >   		}
> >   		page = pfn_to_page(pfn);
> > +		if (page_zone(page) != zone)
> > +			break;
> > +
> >   		if (PageBuddy(page)) {
> >   			/*
> >   			 * If race between isolatation and allocation happens,
> > @@ -281,7 +284,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
> >   	/* Check all pages are free or marked as ISOLATED */
> >   	zone = page_zone(page);
> >   	spin_lock_irqsave(&zone->lock, flags);
> > -	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
> > +	ret = __test_page_isolated_in_pageblock(zone, start_pfn, end_pfn,
> >   						skip_hwpoisoned_pages);
> >   	spin_unlock_irqrestore(&zone->lock, flags);
> >   	return ret ? 0 : -EBUSY;
> > 
> 
> What about checking zone at test_pages_isolated?
> It might be a little bit early and without locking zone.

Hello,

Will do in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
