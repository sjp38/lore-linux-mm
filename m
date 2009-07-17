Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 38AD06B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:41:05 -0400 (EDT)
Date: Fri, 17 Jul 2009 13:41:04 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
 OOM killed exit the page allocator (resend)
In-Reply-To: <alpine.DEB.2.00.0907170326400.18608@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0907171337290.3925@sister.anvils>
References: <20090715104944.GC9267@csn.ul.ie>
 <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
 <20090716110328.GB22499@csn.ul.ie> <alpine.DEB.2.00.0907161202500.27201@chino.kir.corp.google.com>
 <20090717092157.GA9835@csn.ul.ie> <alpine.DEB.2.00.0907170326400.18608@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009, David Rientjes wrote:
> On Fri, 17 Jul 2009, Mel Gorman wrote:
> 
> > Ok, lets go with this patch then. Thanks
> > 
> 
> Ok, thanks, I'll add that as your acked-by and I'll write a formal patch 
> description for it.
> 
> 
> mm: avoid endless looping for oom killed tasks
> 
> If a task is oom killed and still cannot find memory when trying with no 
> watermarks, it's better to fail the allocation attempt than to loop 
> endlessly.  Direct reclaim has already failed and the oom killer will be a 
> no-op since current has yet to die, so there is no other alternative for 
> allocations that are not __GFP_NOFAIL.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: David Rientjes <rientjes@google.com>

This works much better for me than earlier variants (I'm needing to worry
about OOM when KSM has a lot of pages to break COW on; but a large mlock
is a good test) - thanks.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1789,6 +1789,10 @@ rebalance:
>  	if (p->flags & PF_MEMALLOC)
>  		goto nopage;
>  
> +	/* Avoid allocations with no watermarks from looping endlessly */
> +	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +		goto nopage;
> +
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order,
>  					zonelist, high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
