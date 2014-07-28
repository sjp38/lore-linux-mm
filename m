Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 15C846B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 04:52:04 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so4006620wiw.12
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 01:52:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ds3si12335906wib.51.2014.07.28.01.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 01:52:02 -0700 (PDT)
Message-ID: <53D60F31.4050504@suse.cz>
Date: Mon, 28 Jul 2014 10:52:01 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch] mm, thp: restructure thp avoidance of light synchronous
 migration
References: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/25/2014 12:41 AM, David Rientjes wrote:
> __GFP_NO_KSWAPD, once the way to determine if an allocation was for thp or not,
> has gained more users.  Their use is not necessarily wrong, they are trying to
> do a memory allocation that can easily fail without disturbing kswapd, so the
> bit has gained additional usecases.
>
> This restructures the check to determine whether MIGRATE_SYNC_LIGHT should be
> used for memory compaction in the page allocator.  Rather than testing solely
> for __GFP_NO_KSWAPD, test for all bits that must be set for thp allocations.
>
> This also moves the check to be done only after the page allocator is aborted
> for deferred or contended memory compaction since setting migration_mode for
> this case is pointless.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   mm/page_alloc.c | 17 +++++++++--------
>   1 file changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2616,14 +2616,6 @@ rebalance:
>   		goto got_pg;
>
>   	/*
> -	 * It can become very expensive to allocate transparent hugepages at
> -	 * fault, so use asynchronous memory compaction for THP unless it is
> -	 * khugepaged trying to collapse.
> -	 */
> -	if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
> -		migration_mode = MIGRATE_SYNC_LIGHT;
> -
> -	/*
>   	 * If compaction is deferred for high-order allocations, it is because
>   	 * sync compaction recently failed. In this is the case and the caller
>   	 * requested a movable allocation that does not heavily disrupt the
> @@ -2633,6 +2625,15 @@ rebalance:
>   						(gfp_mask & __GFP_NO_KSWAPD))
>   		goto nopage;
>
> +	/*
> +	 * It can become very expensive to allocate transparent hugepages at
> +	 * fault, so use asynchronous memory compaction for THP unless it is
> +	 * khugepaged trying to collapse.
> +	 */
> +	if ((gfp_mask & GFP_TRANSHUGE) != GFP_TRANSHUGE ||
> +						(current->flags & PF_KTHREAD))
> +		migration_mode = MIGRATE_SYNC_LIGHT;
> +

Looks like kind of a shotgun approach to me. A single __GFP_NO_KSWAPD 
bullet is no longer enough, so we use all the flags and hope for the 
best. It seems THP has so many flags it should be unique for now, but I 
wonder if there is a better way to say how much an allocation is willing 
to wait.

>   	/* Try direct reclaim and then allocating */
>   	page = __alloc_pages_direct_reclaim(gfp_mask, order,
>   					zonelist, high_zoneidx,
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
