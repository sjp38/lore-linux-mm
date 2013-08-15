Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 401256B0037
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 00:24:55 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so333540pbc.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 21:24:54 -0700 (PDT)
Date: Thu, 15 Aug 2013 13:24:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130815042434.GA3139@gmail.com>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814161642.GM2296@suse.de>
 <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
 <520C3DD2.8010905@huawei.com>
 <20130815024427.GA2718@gmail.com>
 <520C4EFF.8040305@huawei.com>
 <20130815041736.GA2592@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815041736.GA2592@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 01:17:55PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Thu, Aug 15, 2013 at 11:46:07AM +0800, Xishi Qiu wrote:
> > On 2013/8/15 10:44, Minchan Kim wrote:
> > 
> > > Hi Xishi,
> > > 
> > > On Thu, Aug 15, 2013 at 10:32:50AM +0800, Xishi Qiu wrote:
> > >> On 2013/8/15 2:00, Mel Gorman wrote:
> > >>
> > >>>>> Even if the page is still page buddy, there is no guarantee that it's
> > >>>>> the same page order as the first read. It could have be currently
> > >>>>> merging with adjacent buddies for example. There is also a really
> > >>>>> small race that a page was freed, allocated with some number stuffed
> > >>>>> into page->private and freed again before the second PageBuddy check.
> > >>>>> It's a bit of a hand grenade. How much of a performance benefit is there
> > >>>>
> > >>>> 1. Just worst case is skipping pageblock_nr_pages
> > >>>
> > >>> No, the worst case is that page_order returns a number that is
> > >>> completely garbage and low_pfn goes off the end of the zone
> > >>>
> > >>>> 2. Race is really small
> > >>>> 3. Higher order page allocation customer always have graceful fallback.
> > >>>>
> > >>
> > >> Hi Minchan, 
> > >> I think in this case, we may get the wrong value from page_order(page).
> > >>
> > >> 1. page is in page buddy
> > >>
> > >>> if (PageBuddy(page)) {
> > >>
> > >> 2. someone allocated the page, and set page->private to another value
> > >>
> > >>> 	int nr_pages = (1 << page_order(page)) - 1;
> > >>
> > >> 3. someone freed the page
> > >>
> > >>> 	if (PageBuddy(page)) {
> > >>
> > >> 4. we will skip wrong pages
> > > 
> > > So, what's the result by that?
> > > As I said, it's just skipping (pageblock_nr_pages -1) at worst case
> > 
> > Hi Minchan,
> > I mean if the private is set to a large number, it will skip 2^private 
> > pages, not (pageblock_nr_pages -1). I find somewhere will use page->private, 
> > such as fs. Here is the comment about parivate.
> > /* Mapping-private opaque data:
> >  * usually used for buffer_heads
> >  * if PagePrivate set; used for
> >  * swp_entry_t if PageSwapCache;
> >  * indicates order in the buddy
> >  * system if PG_buddy is set.
> >  */
> 
> Please read full thread in detail.
> 
> Mel suggested following as
> 
> if (PageBuddy(page)) {
>         int nr_pages = (1 << page_order(page)) - 1;
>         if (PageBuddy(page)) {
>                 nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES - 1);
>                 low_pfn += nr_pages;
>                 continue;
>         }
> }
> 
> min(nr_pages, xxx) removes your concern but I think Mel's version
> isn't right. It should be aligned with pageblock boundary so I 
> suggested following.
> 
> if (PageBuddy(page)) {
> #ifdef CONFIG_MEMORY_ISOLATION
> 	unsigned long order = page_order(page);
> 	if (PageBuddy(page)) {
> 		low_pfn += (1 << order) - 1;
> 		low_pfn = min(low_pfn, end_pfn);
> 	}
> #endif
> 	continue;
> }
> 
> so worst case is (pageblock_nr_pages - 1).
> but we don't need to add CONFIG_MEMORY_ISOLATION so my suggestion
> is following as.
> 
> if (PageBuddy(page)) {
> 	unsigned long order = page_order(page);
> 	if (PageBuddy(page)) {
> 		low_pfn += (1 << order) - 1;
> 		low_pfn = min(low_pfn, end_pfn);

Maybe it should be low_pfn = min(low_pfn, end_pfn - 1).


> 	}
> 	continue;
> }
> 
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
