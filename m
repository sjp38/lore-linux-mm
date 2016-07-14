Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71AB56B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:22:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so58722681wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:22:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o64si34413421wmb.29.2016.07.14.08.22.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 08:22:26 -0700 (PDT)
Subject: Re: [PATCH 3/4] mm, page_alloc: fix dirtyable highmem calculation
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-4-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1e5938cd-0e03-6cb9-4d5f-fee94fc1479e@suse.cz>
Date: Thu, 14 Jul 2016 17:22:25 +0200
MIME-Version: 1.0
In-Reply-To: <1468404004-5085-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 07/13/2016 12:00 PM, Mel Gorman wrote:
> From: Minchan Kim <minchan@kernel.org>
>
> Note from Mel: This may optionally be considered a fix to the mmotm patch
> 	mm-page_alloc-consider-dirtyable-memory-in-terms-of-nodes.patch
> 	but if so, please preserve credit for Minchan.
>
> When I tested vmscale in mmtest in 32bit, I found the benchmark was slow
> down 0.5 times.
>
>                 base        node
>                    1    global-1
> User           12.98       16.04
> System        147.61      166.42
> Elapsed        26.48       38.08
>
> With vmstat, I found IO wait avg is much increased compared to base.
>
> The reason was highmem_dirtyable_memory accumulates free pages and
> highmem_file_pages from HIGHMEM to MOVABLE zones which was wrong. With
> that, dirth_thresh in throtlle_vm_write is always 0 so that it calls
> congestion_wait frequently if writeback starts.
>
> With this patch, it is much recovered.
>
>                 base        node          fi
>                    1    global-1         fix
> User           12.98       16.04       13.78
> System        147.61      166.42      143.92
> Elapsed        26.48       38.08       29.64
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Just some nitpicks:

> ---
>  mm/page-writeback.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0bca2376bd42..7b41d1290783 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -307,27 +307,31 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
>  {
>  #ifdef CONFIG_HIGHMEM
>  	int node;
> -	unsigned long x = 0;
> +	unsigned long x;
>  	int i;
> -	unsigned long dirtyable = atomic_read(&highmem_file_pages);
> +	unsigned long dirtyable = 0;

This wasn't necessary?

>
>  	for_each_node_state(node, N_HIGH_MEMORY) {
>  		for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
>  			struct zone *z;
> +			unsigned long nr_pages;
>
>  			if (!is_highmem_idx(i))
>  				continue;
>
>  			z = &NODE_DATA(node)->node_zones[i];
> -			dirtyable += zone_page_state(z, NR_FREE_PAGES);
> +			if (!populated_zone(z))
> +				continue;
>
> +			nr_pages = zone_page_state(z, NR_FREE_PAGES);
>  			/* watch for underflows */
> -			dirtyable -= min(dirtyable, high_wmark_pages(z));
> -
> -			x += dirtyable;
> +			nr_pages -= min(nr_pages, high_wmark_pages(z));
> +			dirtyable += nr_pages;
>  		}
>  	}
>
> +	x = dirtyable + atomic_read(&highmem_file_pages);

And then this addition wouldn't be necessary. BTW I think we could also 
ditch the "x" variable and just use the "dirtyable" for the rest of the 
function.

> +
>  	/*
>  	 * Unreclaimable memory (kernel memory or anonymous memory
>  	 * without swap) can bring down the dirtyable pages below
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
