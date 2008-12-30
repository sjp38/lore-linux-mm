Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 259746B0044
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 06:11:02 -0500 (EST)
Date: Tue, 30 Dec 2008 12:10:58 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation
Message-ID: <20081230111058.GB9268@wotan.suse.de>
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 30, 2008 at 07:55:47PM +0900, KOSAKI Motohiro wrote:
> 
> ok, wassim confirmed this patch works well.
> 
> 
> ==
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
> 
> Wassim Dagash reported following kswapd infinite loop problem.
> 
>   kswapd runs in some infinite loop trying to swap until order 10 of zone
>   highmem is OK, While zone higmem (as I understand) has nothing to do
>   with contiguous memory (cause there is no 1-1 mapping) which means
>   kswapd will continue to try to balance order 10 of zone highmem
>   forever (or until someone release a very large chunk of highmem).
> 
> He proposed remove contenious checking on highmem at all.
> However hugepage on highmem need contenious highmem page.
> 
> To add infinite loop stopper is simple and good.
> 
> 
> 
> Reported-by: wassim dagash <wassim.dagash@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks,

Reviewed-by: Nick Piggin <npiggin@suse.de>

> ---
>  mm/vmscan.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1872,6 +1872,17 @@ out:
>  
>  		try_to_freeze();
>  
> +		/*
> +		 * When highmem is very fragmented,
> +		 * alloc_pages(GFP_KERNEL, very-high-order) can cause
> +		 * infinite loop because zone_watermark_ok(highmem) failed.
> +		 * However, alloc_pages(GFP_KERNEL..) indicate highmem memory
> +		 * continuousness isn't necessary.
> +		 * Therefore we don't want contenious check at 2nd loop.
> +		 */
> +		if (nr_reclaimed < SWAP_CLUSTER_MAX)
> +			order = sc.order = 0;
> +
>  		goto loop_again;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
