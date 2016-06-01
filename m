Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408516B0264
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 09:26:46 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so9879224lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:26:46 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 198si21157921wmw.2.2016.06.01.06.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 06:26:45 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so6793315wmg.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:26:44 -0700 (PDT)
Date: Wed, 1 Jun 2016 15:26:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 03/18] mm, page_alloc: don't retry initial attempt in
 slowpath
Message-ID: <20160601132643.GP26601@dhcp22.suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531130818.28724-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 31-05-16 15:08:03, Vlastimil Babka wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index da3a62a94b4a..9f83259a18a8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3367,10 +3367,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  	bool drained = false;
>  
>  	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
> -	if (unlikely(!(*did_some_progress)))
> -		return NULL;
>  
>  retry:
> +	/* We attempt even when no progress, as kswapd might have done some */
>  	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);

Is this really likely to happen, though? Sure we might have last few
reclaimable pages on the LRU lists but I am not sure this would make a
large difference then.

That being said, I do not think this is harmful but I find it a bit
weird to invoke a reclaim and then ignore the feedback... Will leave the
decision up to you but the original patch seemed neater.

>  
>  	/*
> @@ -3378,7 +3377,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  	 * pages are pinned on the per-cpu lists or in high alloc reserves.
>  	 * Shrink them them and try again
>  	 */
> -	if (!page && !drained) {
> +	if (!page && *did_some_progress && !drained) {
>  		unreserve_highatomic_pageblock(ac);
>  		drain_all_pages(NULL);
>  		drained = true;

I do not remember this in the previous version. Why shouldn't we
unreserve highatomic reserves when there was no progress?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
