Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 369BA6B00AA
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 06:09:55 -0400 (EDT)
Date: Wed, 22 Apr 2009 11:09:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/25] Do not check for compound pages during the page
	allocator sanity checks
Message-ID: <20090422100958.GB10380@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-21-git-send-email-mel@csn.ul.ie> <20090422091456.626E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090422091456.626E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 09:20:40AM +0900, KOSAKI Motohiro wrote:
> > A number of sanity checks are made on each page allocation and free
> > including that the page count is zero. page_count() checks for
> > compound pages and checks the count of the head page if true. However,
> > in these paths, we do not care if the page is compound or not as the
> > count of each tail page should also be zero.
> > 
> > This patch makes two changes to the use of page_count() in the free path. It
> > converts one check of page_count() to a VM_BUG_ON() as the count should
> > have been unconditionally checked earlier in the free path. It also avoids
> > checking for compound pages.
> > 
> > [mel@csn.ul.ie: Wrote changelog]
> > Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> > ---
> >  mm/page_alloc.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index ec01d8f..376d848 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -425,7 +425,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
> >  		return 0;
> >  
> >  	if (PageBuddy(buddy) && page_order(buddy) == order) {
> > -		BUG_ON(page_count(buddy) != 0);
> > +		VM_BUG_ON(page_count(buddy) != 0);
> >  		return 1;
> >  	}
> >  	return 0;
> >
> 
> Looks good.
> 
> 
> > @@ -501,7 +501,7 @@ static inline int free_pages_check(struct page *page)
> >  {
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> > -		(page_count(page) != 0)  |
> > +		(atomic_read(&page->_count) != 0) |
> >  		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
> >  		bad_page(page);
> >  		return 1;
> > @@ -646,7 +646,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
> >  {
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> > -		(page_count(page) != 0)  |
> > +		(atomic_read(&page->_count) != 0)  |
> >  		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
> >  		bad_page(page);
> >  		return 1;
> 
> 
> inserting VM_BUG_ON(PageTail(page)) is better?
> 

We already go one further with

#define PAGE_FLAGS_CHECK_AT_PREP        ((1 << NR_PAGEFLAGS) - 1)

...

if (.... | (page->flags & PAGE_FLAGS_CHECK_AT_PREP))
	bad_page(page);

PG_tail is in PAGE_FLAGS_CHECK_AT_PREP so we're already checking for it
and calling bad_page() if set.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
