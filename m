Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A6B776B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 11:06:02 -0400 (EDT)
Date: Wed, 25 Apr 2012 16:05:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/16] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120425150556.GC15299@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
 <1334578624-23257-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1204231637390.17030@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204231637390.17030@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Mon, Apr 23, 2012 at 04:51:02PM -0700, David Rientjes wrote:
> On Mon, 16 Apr 2012, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 280eabe..0fa2c72 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1463,6 +1463,7 @@ failed:
> >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> >  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> > +#define ALLOC_PFMEMALLOC	0x80 /* Caller has PF_MEMALLOC set */
> >  
> >  #ifdef CONFIG_FAIL_PAGE_ALLOC
> >  
> > @@ -2208,16 +2209,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	} else if (unlikely(rt_task(current)) && !in_interrupt())
> >  		alloc_flags |= ALLOC_HARDER;
> >  
> > -	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> > -		if (!in_interrupt() &&
> > -		    ((current->flags & PF_MEMALLOC) ||
> > -		     unlikely(test_thread_flag(TIF_MEMDIE))))
> > +	if ((current->flags & PF_MEMALLOC) ||
> > +			unlikely(test_thread_flag(TIF_MEMDIE))) {
> > +		alloc_flags |= ALLOC_PFMEMALLOC;
> > +
> > +		if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  	}
> >  
> >  	return alloc_flags;
> >  }
> >  
> > +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > +{
> > +	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_PFMEMALLOC);
> > +}
> > +
> >  static inline struct page *
> >  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> > @@ -2407,8 +2414,16 @@ nopage:
> >  got_pg:
> >  	if (kmemcheck_enabled)
> >  		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
> > -	return page;
> >  
> > +	/*
> > +	 * page->pfmemalloc is set when the caller had PFMEMALLOC set or is
> > +	 * been OOM killed. The expectation is that the caller is taking
> > +	 * steps that will free more memory. The caller should avoid the
> > +	 * page being used for !PFMEMALLOC purposes.
> > +	 */
> > +	page->pfmemalloc = !!(alloc_flags & ALLOC_PFMEMALLOC);
> > +
> > +	return page;
> >  }
> >  
> >  /*
> 
> I think this is slightly inconsistent if the page allocation succeeded 
> without needing ALLOC_NO_WATERMARKS, meaning that page was allocated above 
> the min watermark.  That's possible if the slowpath's first call to 
> get_page_from_freelist() succeeds without needing  __alloc_pages_high_priority(). 
> So perhaps we need to do something like
> 
> 	got_pg_memalloc:
> 		...
> 		page->pfmemalloc = !!(alloc_flags & ALLOC_PFMEMALLOC);
> 	got_pg:
> 		if (kmemcheck_enabled)
> 			kmemcheck_pagealloc_alloc(page, order, gfp_mask);
> 		return page;
> 
> and use got_pg_memalloc everywhere we currently use got_pg other than the 
> when it succeeds with ALLOC_NO_WATERMARKS.
> 

In this path, we are under memory pressure and at least below the low
watermark. kswapd is woken up and should start reclaiming pages. The
calling process may enter direct reclaim. As we are paging out and some
of that could be over the network, the pages are preserved until the
paging is complete. The problem is that in the context of this patch,
ALLOC_NO_WATERMARK is not being set for the cases we need so what it
does at this point makes sense.

That said, I see your point. The changelog is inconsistent with what
the code is doing. I updated the desription to read "When this patch is
applied, pages allocated from below the low watermark are returned with
page->pfmemalloc set and it is up to the caller to determine how the page
should be protected."

You are also right in that the series as a whole is actually protecting pages
below the low watermark and not below the min watermark as stated. I'll add a
new patch that will be patch 6 in the series that only sets page->pfmemalloc
when ALLOC_NO_WATERMARKS is used and test that.

One could argue that the patch "mm: Introduce __GFP_MEMALLOC to allow access
to emergency reserves" should be updated but I think a separate patch will
be easier to review and also easier to revert if regressions are reported.

Well spotted and thanks for reviewing.

This is not tested but is this what you had in mind? It only sets
page->pfmemalloc if ALLOC_NO_WATERMARKS was necessary to satisfy the
allocation. To do that, ALLOC_NO_WATERMARKS has to be stripped from
__alloc_pages_direct_reclaim and friends but it should goto rebalanace later.

---8<---
mm: Only set page->pfmemalloc when ALLOC_NO_WATERMARKS was used

__alloc_pages_slowpath() is called when the number of free pages is below
the low watermark. If the caller is entitled to use ALLOC_NO_WATERMARKS
then the page will be marked page->pfmemalloc.  This protects more pages
than are strictly necessary as we only need to protect pages allocated
below the min watermark (the pfmemalloc reserves).

This patch only sets page->pfmemalloc when ALLOC_NO_WATERMARKS was
required to allocate the page.

[rientjes@google.com: David noticed the problem during review]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3738596..363ca90 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2043,8 +2043,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
-				alloc_flags, preferred_zone,
-				migratetype);
+				alloc_flags & ~ALLOC_NO_WATERMARKS,
+				preferred_zone, migratetype);
 		if (page) {
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;
@@ -2124,8 +2124,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
-					alloc_flags, preferred_zone,
-					migratetype);
+					alloc_flags & ~ALLOC_NO_WATERMARKS,
+					preferred_zone, migratetype);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2296,8 +2296,17 @@ rebalance:
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-		if (page)
+		if (page) {
+			/*
+			 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
+			 * necessary to allocate the page. The expectation is
+			 * that the caller is taking steps that will free more
+			 * memory. The caller should avoid the page being used
+			 * for !PFMEMALLOC purposes.
+			 */
+			page->pfmemalloc = true;
 			goto got_pg;
+		}
 	}
 
 	/* Atomic allocations - we can't balance anything */
@@ -2414,14 +2423,6 @@ nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 	return page;
 got_pg:
-	/*
-	 * page->pfmemalloc is set when the caller had PFMEMALLOC set, is
-	 * been OOM killed or specified __GFP_MEMALLOC. The expectation is
-	 * that the caller is taking steps that will free more memory. The
-	 * caller should avoid the page being used for !PFMEMALLOC purposes.
-	 */
-	page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
-
 	if (kmemcheck_enabled)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
