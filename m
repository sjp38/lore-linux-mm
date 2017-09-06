Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC942802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 04:10:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e64so5700456wmi.0
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 01:10:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o90si699605wmi.250.2017.09.06.01.10.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 01:10:25 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm/slub: don't use reserved memory for optimistic try
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1504672666-19682-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f3af7a0e-d04d-e47d-12c6-8e379d04265a@suse.cz>
Date: Wed, 6 Sep 2017 10:10:22 +0200
MIME-Version: 1.0
In-Reply-To: <1504672666-19682-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/06/2017 06:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> High-order atomic allocation is difficult to succeed since we cannot
> reclaim anything in this context. So, we reserves the pageblock for
> this kind of request.
> 
> In slub, we try to allocate higher-order page more than it actually
> needs in order to get the best performance. If this optimistic try is
> used with GFP_ATOMIC, alloc_flags will be set as ALLOC_HARDER and
> the pageblock reserved for high-order atomic allocation would be used.
> Moreover, this request would reserve the MIGRATE_HIGHATOMIC pageblock
> ,if succeed, to prepare further request. It would not be good to use
> MIGRATE_HIGHATOMIC pageblock in terms of fragmentation management
> since it unconditionally set a migratetype to request's migratetype
> when unreserving the pageblock without considering the migratetype of
> used pages in the pageblock.
> 
> This is not what we don't intend so fix it by unconditionally masking
> out __GFP_ATOMIC in order to not set ALLOC_HARDER.
> 
> And, it is also undesirable to use reserved memory for optimistic try
> so mask out __GFP_HIGH. This patch also adds __GFP_NOMEMALLOC since
> we don't want to use the reserved memory for optimistic try even if
> the user has PF_MEMALLOC flag.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/gfp.h | 1 +
>  mm/page_alloc.c     | 8 ++++++++
>  mm/slub.c           | 6 ++----
>  3 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f780718..1f5658e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -568,6 +568,7 @@ extern gfp_t gfp_allowed_mask;
>  
>  /* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
>  bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
> +gfp_t gfp_drop_reserves(gfp_t gfp_mask);
>  
>  extern void pm_restrict_gfp_mask(void);
>  extern void pm_restore_gfp_mask(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6dbc49e..0f34356 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3720,6 +3720,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	return !!__gfp_pfmemalloc_flags(gfp_mask);
>  }
>  
> +gfp_t gfp_drop_reserves(gfp_t gfp_mask)
> +{
> +	gfp_mask &= ~(__GFP_HIGH | __GFP_ATOMIC);
> +	gfp_mask |= __GFP_NOMEMALLOC;
> +
> +	return gfp_mask;
> +}
> +

I think it's wasteful to do a function call for this, inline definition
in header would be better (gfp_pfmemalloc_allowed() is different as it
relies on a rather heavyweight __gfp_pfmemalloc_flags().

>  /*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
> diff --git a/mm/slub.c b/mm/slub.c
> index 45f4a4b..3d75d30 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1579,10 +1579,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	 */
>  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
>  	if (oo_order(oo) > oo_order(s->min)) {
> -		if (alloc_gfp & __GFP_DIRECT_RECLAIM) {
> -			alloc_gfp |= __GFP_NOMEMALLOC;
> -			alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
> -		}
> +		alloc_gfp = gfp_drop_reserves(alloc_gfp);
> +		alloc_gfp &= ~__GFP_DIRECT_RECLAIM;
>  	}
>  
>  	page = alloc_slab_page(s, alloc_gfp, node, oo);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
