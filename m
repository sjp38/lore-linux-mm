Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2FD36B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 07:09:20 -0400 (EDT)
Date: Mon, 22 Jun 2009 12:09:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Re: Performance degradation seen after using one list for
	hot/cold pages.
Message-ID: <20090622110931.GC3981@csn.ul.ie>
References: <4268941.50031245667360535.JavaMail.weblogic@epml20>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4268941.50031245667360535.JavaMail.weblogic@epml20>
Sender: owner-linux-mm@kvack.org
To: NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 10:42:40AM +0000, NARAYANAN GOPALAKRISHNAN wrote:
> Hi,
>  
> We had also tried this patch and it fixes the issue. The read/write performance is regained.
> The patch looks OK.
> 
> Can this be merged? 
> 

Not just yet. Is there any chance you could provide a simple test program
using AIO read and tell me what filesystem you are based on please? I'd
like to at least look at identifying when the readahead is happening due to
aio_read() and using page_cache_alloc() instead of page_cache_alloc_cold()
in that case. It would avoid adding a branch to the page allocator itself.

> ------- Original Message -------
> Sender : Mel Gorman<mel@csn.ul.ie>
> Date   : Jun 22, 2009 15:06 (GMT+05:00)
> Title  : Re: Performance degradation seen after using one list for hot/cold	pages.
> 
> On Mon, Jun 22, 2009 at 04:41:47PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 22 Jun 2009 11:20:14 +0530
> > Narayanan Gopalakrishnan <narayanan.g@samsung.com> wrote:
> > 
> > > Hi,
> > > 
> > > We are facing a performance degradation of 2 MBps in kernels 2.6.25 and
> > > above.
> > > We were able to zero on the fact that the exact patch that has affected us
> > > is this
> > > (http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdi
> > > ff;h=3dfa5721f12c3d5a441448086bee156887daa961), that changes to have one
> > > list for hot/cold pages. 
> > > 
> > > We see the at the block driver the pages we get are not contiguous hence the
> > > number of LLD requests we are making have increased which is the cause of
> > > this problem.
> > > 
> > > The page allocation in our case is called from aio_read and hence it always
> > > calls page_cache_alloc_cold(mapping) from readahead.
> > > 
> > > We have found a hack for this that is, removing the __GFP_COLD macro when
> > > __page_cache_alloc()is called helps us to regain the performance as we see
> > > contiguous pages in block driver.
> > > 
> > > Has anyone faced this problem or can give a possible solution for this?
> > > 
> 
> I&#39;ve seen this problem before. In the 2.6.24 timeframe, performance degradation
> of IO was reported when I broke the property of the buddy allocator that
> returns contiguous pages in some cases. IIRC, some IO devices can automatically
> merge requests if the pages happen to be physically contiguous.
> 
> > > Our target is OMAP2430 custom board with 128MB RAM.
> > > 
> > Added some CCs.
> > 
> > My understanding is this: 
> > 
> > Assume A,B,C,D are pfn of continuous pages. (B=A+1, C=A+2, D=A+3)
> > 
> > 1) When there are 2 lists for hot and cold pages, pcp list is constracted in
> >    following order after rmqueue_bulk().
> > 
> >    pcp_list[cold] (next) <-> A <-> B <-> C <-> D <-(prev) pcp_list[cold]
> > 
> >    The pages are drained from "next" and pages were given in sequence of
> >    A, B, C, D...
> > 
> > 2) Now, pcp list is constracted as following after  rmqueue_bulk()
> > 
> >     pcp_list (next) <-> A <-> B <-> C <-> D <-> (prev) pcp_list
> > 
> >    When __GFP_COLD, the page is drained via "prev" and sequence of given pages
> >    is D,C,B,A...
> > 
> >    Then, removing __GFP_COLD allows you to allocate pages in sequence of
> >    A, B, C, D.
> > 
> > Looking into page_alloc.c::rmqueue_bulk(),
> >  871     /*
> >  872      * Split buddy pages returned by expand() are received here
> >  873      * in physical page order. The page is added to the callers and
> >  874      * list and the list head then moves forward. From the callers
> >  875      * perspective, the linked list is ordered by page number in
> >  876      * some conditions. This is useful for IO devices that can
> >  877      * merge IO requests if the physical pages are ordered
> >  878      * properly.
> >  879      */
> > 
> > Order of pfn is taken into account but doesn&#39;t work well for __GFP_COLD
> > allocation. (works well for not __GFP_COLD allocation.)
> > Using 2 lists again or modify current behavior ?
> > 
> 
> This analysis looks spot-on. The lack of physical contiguity is what is
> critical, not that the pages are hot or cold in cache. I think it would be
> overkill to reintroduce two separate lists to preserve the ordering in
> that case. How about something like the following?
> 
> ==== CUT HERE ====
> [PATCH] page-allocator: Preserve PFN ordering when __GFP_COLD is set
> 
> The page allocator tries to preserve contiguous PFN ordering when returning
> pages such that repeated callers to the allocator have a strong chance of
> getting physically contiguous pages, particularly when external fragmentation
> is low. However, of the bulk of the allocations have __GFP_COLD set as
> they are due to aio_read() for example, then the PFNs are in reverse PFN
> order. This can cause performance degration when used with IO
> controllers that could have merged the requests.
> 
> This patch attempts to preserve the contiguous ordering of PFNs for
> users of __GFP_COLD.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  mm/page_alloc.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a5f3c27..9cd32c8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -882,7 +882,7 @@ retry_reserve:
>   */
>  static int rmqueue_bulk(struct zone *zone, unsigned int order, 
>              unsigned long count, struct list_head *list,
> -            int migratetype)
> +            int migratetype, int cold)
>  {
>      int i;
>      
> @@ -901,7 +901,10 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>           * merge IO requests if the physical pages are ordered
>           * properly.
>           */
> -        list_add(&page->lru, list);
> +        if (likely(cold == 0))
> +            list_add(&page->lru, list);
> +        else
> +            list_add_tail(&page->lru, list);
>          set_page_private(page, migratetype);
>          list = &page->lru;
>      }
> @@ -1119,7 +1122,8 @@ again:
>          local_irq_save(flags);
>          if (!pcp->count) {
>              pcp->count = rmqueue_bulk(zone, 0,
> -                    pcp->batch, &pcp->list, migratetype);
> +                    pcp->batch, &pcp->list,
> +                    migratetype, cold);
>              if (unlikely(!pcp->count))
>                  goto failed;
>          }
> @@ -1138,7 +1142,8 @@ again:
>          /* Allocate more to the pcp list if necessary */
>          if (unlikely(&page->lru == &pcp->list)) {
>              pcp->count += rmqueue_bulk(zone, 0,
> -                    pcp->batch, &pcp->list, migratetype);
> +                    pcp->batch, &pcp->list,
> +                    migratetype, cold);
>              page = list_entry(pcp->list.next, struct page, lru);
>          }
>  
> 
> --
> To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don&#39;t email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
>  
>  
> Narayanan Gopalakrishnan
> Memory Solutions Division,
> Samsung India Software Operations,
> Phone: (91) 80-41819999 Extn: 5148
> Mobile: 91-93410-42022
>  
>  
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
