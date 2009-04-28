Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07FF26B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:26:59 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:27:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/22] Cleanup and optimise the page allocator V7
Message-ID: <20090428102719.GA23540@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240819119.2567.884.camel@ymzhang> <20090427143845.GC912@csn.ul.ie> <1240883957.2567.886.camel@ymzhang>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240883957.2567.886.camel@ymzhang>
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 09:59:17AM +0800, Zhang, Yanmin wrote:
> On Mon, 2009-04-27 at 15:38 +0100, Mel Gorman wrote:
> > On Mon, Apr 27, 2009 at 03:58:39PM +0800, Zhang, Yanmin wrote:
> > > On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> > > > Here is V7 of the cleanup and optimisation of the page allocator and
> > > > it should be ready for wider testing. Please consider a possibility for
> > > > merging as a Pass 1 at making the page allocator faster. Other passes will
> > > > occur later when this one has had a bit of exercise. This patchset is based
> > > > on mmotm-2009-04-17 and I've tested it successfully on a small number of
> > > > machines.
> > > We ran some performance benchmarks against V7 patch on top of 2.6.30-rc3.
> > > It seems some counters in kernel are incorrect after we run some ffsb (disk I/O benchmark)
> > > and swap-cp (a simple swap memory testing by cp on tmpfs). Free memory is bigger than
> > > total memory.
> > > 
> > 
> > oops. Can you try this patch please?
> > 
> > ==== CUT HERE ====
> > 
> > Properly account for freed pages in free_pages_bulk() and when allocating high-order pages in buffered_rmqueue()
> > 
> > free_pages_bulk() updates the number of free pages in the zone but it is
> > assuming that the pages being freed are order-0. While this is currently
> > always true, it's wrong to assume the order is 0. This patch fixes the
> > problem.
> > 
> > buffered_rmqueue() is not updating NR_FREE_PAGES when allocating pages with
> > __rmqueue(). This means that any high-order allocation will appear to increase
> > the number of free pages leading to the situation where free pages appears to
> > exceed available RAM. This patch accounts for those allocated pages properly.
> > 
> > This is a candidate fix to the patch
> > page-allocator-update-nr_free_pages-only-as-necessary.patch. It has yet to be
> > verified as fixing a problem where the free pages count is getting corrupted.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 3db5f57..dd69593 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -545,7 +545,7 @@ static void free_pages_bulk(struct zone *zone, int count,
> >  	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> >  	zone->pages_scanned = 0;
> >  
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> > +	__mod_zone_page_state(zone, NR_FREE_PAGES, count << order);
> >  	while (count--) {
> >  		struct page *page;
> >  
> > @@ -1151,6 +1151,7 @@ again:
> >  	} else {
> >  		spin_lock_irqsave(&zone->lock, flags);
> >  		page = __rmqueue(zone, order, migratetype);
> > +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> Here 'i' should be 1?

1UL even. Not sure how I managed to send a version with 'i' after a build +
boot test.

> 
> >  		spin_unlock(&zone->lock);
> >  		if (!page)
> >  			goto failed;
>
> I ran a cp kernel source files and swap-cp workload and didn't find
> bad counter now.
> 

I'm assuming you mean that it worked with s/i/1/. I'll send out an updated
version.

Thanks a lot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
