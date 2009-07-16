Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A48316B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 15:14:18 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n6GJEJ5W009565
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 20:14:20 +0100
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by spaceape12.eur.corp.google.com with ESMTP id n6GJE4Vb010999
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:14:17 -0700
Received: by pxi5 with SMTP id 5so205884pxi.11
        for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:14:15 -0700 (PDT)
Date: Thu, 16 Jul 2009 12:14:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
 OOM killed exit the page allocator (resend)
In-Reply-To: <20090716110328.GB22499@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0907161202500.27201@chino.kir.corp.google.com>
References: <20090715104944.GC9267@csn.ul.ie> <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com> <20090716110328.GB22499@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4b8552e..b381a6b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1830,8 +1830,6 @@ rebalance:
>  			if (order > PAGE_ALLOC_COSTLY_ORDER &&
>  						!(gfp_mask & __GFP_NOFAIL))
>  				goto nopage;
> -
> -			goto restart;
>  		}
>  	}
>  
> 

This isn't right (and not only because it'll add a compiler warning 
because `restart' is now unused).

This would immediately fail any allocation that triggered the oom killer 
and ended up being selected that isn't __GFP_NOFAIL, even if it would have 
succeeded without even killing any task simply because it allocates 
without watermarks.

It will also, coupled with your earlier patch, inappropriately warn about 
an infinite loop with __GFP_NOFAIL even though it hasn't even attempted to 
loop once since that decision is now handled by should_alloc_retry().

The liklihood of such an infinite loop, considering only one thread per 
system (or cpuset) can be TIF_MEMDIE at a time, is very low.  I've never 
seen memory reserves completely depleted such that the next high-priority 
allocation wouldn't succeed so that current could handle its pending 
SIGKILL.

You get the same behavior with my patch, but are allowed to try the high 
priority allocation again for the attempt that triggered the oom killer 
(and not only subsequent ones).
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1789,6 +1789,10 @@ rebalance:
 	if (p->flags & PF_MEMALLOC)
 		goto nopage;
 
+	/* Avoid allocations with no watermarks from looping endlessly */
+	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+		goto nopage;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
