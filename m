Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 10C836B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 16:29:44 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n6FKTbtY027248
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:29:37 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by zps36.corp.google.com with ESMTP id n6FKTZ32005655
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:29:35 -0700
Received: by pzk35 with SMTP id 35so2178173pzk.33
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:29:35 -0700 (PDT)
Date: Wed, 15 Jul 2009 13:29:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
 OOM killed exit the page allocator (resend)
In-Reply-To: <20090715104944.GC9267@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
References: <20090715104944.GC9267@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8902e7..5c98d02 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1547,6 +1547,14 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_NORETRY)
>  		return 0;
>  
> +	/* Do not loop if OOM-killed unless __GFP_NOFAIL is specified */
> +	if (test_thread_flag(TIF_MEMDIE)) {
> +		if (gfp_mask & __GFP_NOFAIL)
> +			WARN(1, "Potential infinite loop with __GFP_NOFAIL");
> +		else
> +			return 0;
> +	}
> +
>  	/*
>  	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
>  	 * means __GFP_NOFAIL, but that may not be true in other
> 

This only works for GFP_ATOMIC since the next iteration of the page 
allocator will (probably) fail reclaim and simply invoke the oom killer 
again, which will notice current has TIF_MEMDIE set and choose to do 
nothing, at which time the allocator simply loops again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
