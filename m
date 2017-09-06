Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B10428042D
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 09:38:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p17so6228483wmd.3
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 06:38:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si1240742wmi.0.2017.09.06.06.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 06:38:50 -0700 (PDT)
Date: Wed, 6 Sep 2017 15:38:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
Message-ID: <20170906133842.md6gt76nt2z46fdz@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
 <cf8d0c4f-0e1e-14ee-8dae-a1f71099b887@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf8d0c4f-0e1e-14ee-8dae-a1f71099b887@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

[Sorry for the late reply]

On Thu 24-08-17 09:01:52, Vlastimil Babka wrote:
> On 08/23/2017 08:47 AM, Vlastimil Babka wrote:
> > On 07/24/2017 02:38 PM, Michal Hocko wrote:
> >>
> >> Do we need to duplicated a part of __set_page_owner? Can we pull out
> >> both owner and handle out __set_page_owner?
> > 
> > I wanted to avoid overhead in __set_page_owner() by introducing extra
> > shared function, but I'll check if that can be helped.
> 
> Ok, here's a -fix for that.
> 
> ----8<----
> >From b607d021d52c5f4b64874a7e738a62e3f0e5ddea Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 24 Aug 2017 08:39:58 +0200
> Subject: [PATCH] mm, page_owner: make init_pages_in_zone() faster-fix
> 
> Don't duplicate code of __set_page_owner(), per Michal Hocko.

Looks good. I assume Andrew will fold this into
mm-page_owner-make-init_pages_in_zone-faster.patch. Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_owner.c | 31 +++++++++++++------------------
>  1 file changed, 13 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 5aa21ca237d9..cd72a74d41a0 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -165,17 +165,13 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
>  	return handle;
>  }
>  
> -noinline void __set_page_owner(struct page *page, unsigned int order,
> -					gfp_t gfp_mask)
> +static inline void __set_page_owner_handle(struct page_ext *page_ext,
> +	depot_stack_handle_t handle, unsigned int order, gfp_t gfp_mask)
>  {
> -	struct page_ext *page_ext = lookup_page_ext(page);
>  	struct page_owner *page_owner;
>  
> -	if (unlikely(!page_ext))
> -		return;
> -
>  	page_owner = get_page_owner(page_ext);
> -	page_owner->handle = save_stack(gfp_mask);
> +	page_owner->handle = handle;
>  	page_owner->order = order;
>  	page_owner->gfp_mask = gfp_mask;
>  	page_owner->last_migrate_reason = -1;
> @@ -183,18 +179,17 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
>  	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
>  }
>  
> -static void __set_page_owner_init(struct page_ext *page_ext,
> -					depot_stack_handle_t handle)
> +noinline void __set_page_owner(struct page *page, unsigned int order,
> +					gfp_t gfp_mask)
>  {
> -	struct page_owner *page_owner;
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +	depot_stack_handle_t handle;
>  
> -	page_owner = get_page_owner(page_ext);
> -	page_owner->handle = handle;
> -	page_owner->order = 0;
> -	page_owner->gfp_mask = 0;
> -	page_owner->last_migrate_reason = -1;
> +	if (unlikely(!page_ext))
> +		return;
>  
> -	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
> +	handle = save_stack(gfp_mask);
> +	__set_page_owner_handle(page_ext, handle, order, gfp_mask);
>  }
>  
>  void __set_page_owner_migrate_reason(struct page *page, int reason)
> @@ -582,12 +577,12 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  			if (unlikely(!page_ext))
>  				continue;
>  
> -			/* Maybe overraping zone */
> +			/* Maybe overlaping zone */
>  			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
>  				continue;
>  
>  			/* Found early allocated page */
> -			__set_page_owner_init(page_ext, init_handle);
> +			__set_page_owner_handle(page_ext, init_handle, 0, 0);
>  			count++;
>  		}
>  	}
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
