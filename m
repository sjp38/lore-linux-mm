Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3620382F8F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:34:57 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so6218wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:34:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p10si159302wjo.3.2015.09.24.13.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:34:55 -0700 (PDT)
Date: Thu, 24 Sep 2015 16:34:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/10] mm, page_alloc: Use masks and shifts when
 converting GFP flags to migrate types
Message-ID: <20150924203445.GH3009@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442832762-7247-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 11:52:36AM +0100, Mel Gorman wrote:
> @@ -14,7 +14,7 @@ struct vm_area_struct;
>  #define ___GFP_HIGHMEM		0x02u
>  #define ___GFP_DMA32		0x04u
>  #define ___GFP_MOVABLE		0x08u
> -#define ___GFP_WAIT		0x10u
> +#define ___GFP_RECLAIMABLE	0x10u
>  #define ___GFP_HIGH		0x20u
>  #define ___GFP_IO		0x40u
>  #define ___GFP_FS		0x80u
> @@ -29,7 +29,7 @@ struct vm_area_struct;
>  #define ___GFP_NOMEMALLOC	0x10000u
>  #define ___GFP_HARDWALL		0x20000u
>  #define ___GFP_THISNODE		0x40000u
> -#define ___GFP_RECLAIMABLE	0x80000u
> +#define ___GFP_WAIT		0x80000u
>  #define ___GFP_NOACCOUNT	0x100000u
>  #define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_NO_KSWAPD	0x400000u
> @@ -126,6 +126,7 @@ struct vm_area_struct;
>  
>  /* This mask makes up all the page movable related flags */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> +#define GFP_MOVABLE_SHIFT 3

This connects the power-of-two gfp bits to the linear migrate type
enum, so shifting back and forth between them works only with up to
two items. A hypothetical ___GFP_FOOABLE would translate to 4, not
3. I'm not expecting new migratetypes to show up anytime soon, but
this implication does not make the code exactly robust and obvious.

> @@ -152,14 +153,15 @@ struct vm_area_struct;
>  /* Convert GFP flags to their corresponding migrate type */
>  static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>  {
> -	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> +	VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> +	BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
> +	BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
>  
>  	if (unlikely(page_group_by_mobility_disabled))
>  		return MIGRATE_UNMOVABLE;
>  
>  	/* Group based on mobility */
> -	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
> -		((gfp_flags & __GFP_RECLAIMABLE) != 0);
> +	return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;

I'm not sure the simplification of this line is worth the fragile
dependency between those two tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
