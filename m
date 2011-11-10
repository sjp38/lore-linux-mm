Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43BE96B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:00:40 -0500 (EST)
Date: Thu, 10 Nov 2011 15:00:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111110140037.GV5075@redhat.com>
References: <20111110100616.GD3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111110100616.GD3083@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 10, 2011 at 10:06:16AM +0000, Mel Gorman wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 963c5de..cddc2d0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2213,7 +2213,13 @@ rebalance:
>  					sync_migration);
>  	if (page)
>  		goto got_pg;
> -	sync_migration = true;
> +
> +	/*
> +	 * Do not use sync migration for transparent hugepage allocations as
> +	 * it could stall writing back pages which is far worse than simply
> +	 * failing to promote a page.
> +	 */
> +	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD);
>  
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order,

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
