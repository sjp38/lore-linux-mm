Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 64EA56B005A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 07:03:30 -0400 (EDT)
Date: Thu, 16 Jul 2009 12:03:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
	OOM killed exit the page allocator (resend)
Message-ID: <20090716110328.GB22499@csn.ul.ie>
References: <20090715104944.GC9267@csn.ul.ie> <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 15, 2009 at 01:29:33PM -0700, David Rientjes wrote:
> On Wed, 15 Jul 2009, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f8902e7..5c98d02 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1547,6 +1547,14 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_NORETRY)
> >  		return 0;
> >  
> > +	/* Do not loop if OOM-killed unless __GFP_NOFAIL is specified */
> > +	if (test_thread_flag(TIF_MEMDIE)) {
> > +		if (gfp_mask & __GFP_NOFAIL)
> > +			WARN(1, "Potential infinite loop with __GFP_NOFAIL");
> > +		else
> > +			return 0;
> > +	}
> > +
> >  	/*
> >  	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> >  	 * means __GFP_NOFAIL, but that may not be true in other
> > 
> 
> This only works for GFP_ATOMIC since the next iteration of the page 
> allocator will (probably) fail reclaim and simply invoke the oom killer 
> again,

GFP_ATOMIC should not be calling the OOM killer. It has already
exited. Immeditely after an OOM kill, I would expect the allocation to
succeed. However, in the event that the task selected for OOM killing is
the current one and no other task exits, it could loop.

> which will notice current has TIF_MEMDIE set and choose to do 
> nothing, at which time the allocator simply loops again.
> 

So, we should unconditionally check if we should loop again whether we
have OOM killed or not which the following should do.

==== CUT HERE ====
page-allocator: Check after an OOM kill if the allocator should loop

Currently, the allocator loops unconditionally after an OOM kill on the
assumption that the allocation will succeed. However, if the task
selected for OOM-kill is the current task, it could in theory loop
forever and always entering the OOM killer. This patch checks as normal
after an OOM kill if the allocator should loop again.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
-- 
 mm/page_alloc.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4b8552e..b381a6b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1830,8 +1830,6 @@ rebalance:
 			if (order > PAGE_ALLOC_COSTLY_ORDER &&
 						!(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-
-			goto restart;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
