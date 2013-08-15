Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 93BC26B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 22:44:38 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id tp5so455927ieb.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:44:38 -0700 (PDT)
Date: Thu, 15 Aug 2013 11:44:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130815024427.GA2718@gmail.com>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814161642.GM2296@suse.de>
 <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
 <520C3DD2.8010905@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520C3DD2.8010905@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Xishi,

On Thu, Aug 15, 2013 at 10:32:50AM +0800, Xishi Qiu wrote:
> On 2013/8/15 2:00, Mel Gorman wrote:
> 
> >>> Even if the page is still page buddy, there is no guarantee that it's
> >>> the same page order as the first read. It could have be currently
> >>> merging with adjacent buddies for example. There is also a really
> >>> small race that a page was freed, allocated with some number stuffed
> >>> into page->private and freed again before the second PageBuddy check.
> >>> It's a bit of a hand grenade. How much of a performance benefit is there
> >>
> >> 1. Just worst case is skipping pageblock_nr_pages
> > 
> > No, the worst case is that page_order returns a number that is
> > completely garbage and low_pfn goes off the end of the zone
> > 
> >> 2. Race is really small
> >> 3. Higher order page allocation customer always have graceful fallback.
> >>
> 
> Hi Minchan, 
> I think in this case, we may get the wrong value from page_order(page).
> 
> 1. page is in page buddy
> 
> > if (PageBuddy(page)) {
> 
> 2. someone allocated the page, and set page->private to another value
> 
> > 	int nr_pages = (1 << page_order(page)) - 1;
> 
> 3. someone freed the page
> 
> > 	if (PageBuddy(page)) {
> 
> 4. we will skip wrong pages

So, what's the result by that?
As I said, it's just skipping (pageblock_nr_pages -1) at worst case
and the case you mentioned is right academically and I and Mel
already pointed out that. But how often could that happen in real
practice? I believe such is REALLY REALLY rare.
So, as Mel said, if you have some workloads to see the benefit
from this patch, I think we could accept the patch.
Could you try and respin with the number?
I guess big contigous memory range or memory-hotplug which are
full of free pages in embedded CPU which is rather slower than server
or desktop side could have benefit.

Thanks.

> 
> > 		nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES - 1);
> > 		low_pfn += nr_pages;
> > 		continue;
> > 	}
> > }
> > 
> > It's still race-prone meaning that it really should be backed by some
> > performance data justifying it.
> > 
> 
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
