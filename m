Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFF56B04E1
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 09:49:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v109so7062893wrc.5
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 06:49:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b34si2598006wra.5.2017.09.06.06.49.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 06:49:13 -0700 (PDT)
Date: Wed, 6 Sep 2017 15:49:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
Message-ID: <20170906134908.xv7esjffv2xmpbq4@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
 <45813564-2342-fc8d-d31a-f4b68a724325@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45813564-2342-fc8d-d31a-f4b68a724325@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Thu 31-08-17 09:55:25, Vlastimil Babka wrote:
> On 08/23/2017 08:47 AM, Vlastimil Babka wrote:
> > On 07/24/2017 02:38 PM, Michal Hocko wrote:
> >> On Thu 20-07-17 15:40:26, Vlastimil Babka wrote:
> >>> In init_pages_in_zone() we currently use the generic set_page_owner() function
> >>> to initialize page_owner info for early allocated pages. This means we
> >>> needlessly do lookup_page_ext() twice for each page, and more importantly
> >>> save_stack(), which has to unwind the stack and find the corresponding stack
> >>> depot handle. Because the stack is always the same for the initialization,
> >>> unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
> >>> repeated lookup_page_ext().
> >>
> >> Yes this looks like an improvement but I have to admit that I do not
> >> really get why we even do save_stack at all here. Those pages might
> >> got allocated from anywhere so we could very well provide a statically
> >> allocated "fake" stack trace, no?
> > 
> > We could, but it's much simpler to do it this way than try to extend
> > stack depot/stack saving to support creating such fakes. Would it be
> > worth the effort?
> 
> Ah, I've noticed we already do this for the dummy (prevent recursion)
> stack and failure stack. So here you go. It will also make the fake
> stack more obvious after "[PATCH 2/2] mm, page_owner: Skip unnecessary
> stack_trace entries" is merged, which would otherwise remove
> init_page_owner() from the stack.

Yes this is what I've had in mind.

> ----8<----
> >From 9804a5e62fc768e12b86fd4a3184e692c59ebfd1 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 31 Aug 2017 09:46:46 +0200
> Subject: [PATCH] mm, page_owner: make init_pages_in_zone() faster-fix2
> 
> Create statically allocated fake stack trace for early allocated pages, per
> Michal Hocko.

Yes this looks good to me. I am just wondering why we need 3 different
fake stacks. I do not see any code that would special case them when
dumping traces. Maybe this can be done on top?
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_owner.c | 30 +++++++++++++++---------------
>  1 file changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 54d49fc8035e..262503f3ea66 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -30,6 +30,7 @@ DEFINE_STATIC_KEY_FALSE(page_owner_inited);
>  
>  static depot_stack_handle_t dummy_handle;
>  static depot_stack_handle_t failure_handle;
> +static depot_stack_handle_t early_handle;
>  
>  static void init_early_allocated_pages(void);
>  
> @@ -53,7 +54,7 @@ static bool need_page_owner(void)
>  	return true;
>  }
>  
> -static noinline void register_dummy_stack(void)
> +static __always_inline depot_stack_handle_t create_dummy_stack(void)
>  {
>  	unsigned long entries[4];
>  	struct stack_trace dummy;
> @@ -64,21 +65,22 @@ static noinline void register_dummy_stack(void)
>  	dummy.skip = 0;
>  
>  	save_stack_trace(&dummy);
> -	dummy_handle = depot_save_stack(&dummy, GFP_KERNEL);
> +	return depot_save_stack(&dummy, GFP_KERNEL);
>  }
>  
> -static noinline void register_failure_stack(void)
> +static noinline void register_dummy_stack(void)
>  {
> -	unsigned long entries[4];
> -	struct stack_trace failure;
> +	dummy_handle = create_dummy_stack();
> +}
>  
> -	failure.nr_entries = 0;
> -	failure.max_entries = ARRAY_SIZE(entries);
> -	failure.entries = &entries[0];
> -	failure.skip = 0;
> +static noinline void register_failure_stack(void)
> +{
> +	failure_handle = create_dummy_stack();
> +}
>  
> -	save_stack_trace(&failure);
> -	failure_handle = depot_save_stack(&failure, GFP_KERNEL);
> +static noinline void register_early_stack(void)
> +{
> +	early_handle = create_dummy_stack();
>  }
>  
>  static void init_page_owner(void)
> @@ -88,6 +90,7 @@ static void init_page_owner(void)
>  
>  	register_dummy_stack();
>  	register_failure_stack();
> +	register_early_stack();
>  	static_branch_enable(&page_owner_inited);
>  	init_early_allocated_pages();
>  }
> @@ -529,13 +532,10 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
>  	unsigned long end_pfn = pfn + zone->spanned_pages;
>  	unsigned long count = 0;
> -	depot_stack_handle_t init_handle;
>  
>  	/* Scan block by block. First and last block may be incomplete */
>  	pfn = zone->zone_start_pfn;
>  
> -	init_handle = save_stack(0);
> -
>  	/*
>  	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
>  	 * a zone boundary, it will be double counted between zones. This does
> @@ -588,7 +588,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  				continue;
>  
>  			/* Found early allocated page */
> -			__set_page_owner_handle(page_ext, init_handle, 0, 0);
> +			__set_page_owner_handle(page_ext, early_handle, 0, 0);
>  			count++;
>  		}
>  		cond_resched();
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
