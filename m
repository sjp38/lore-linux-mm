Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 382A26B026E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 11:21:48 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id zc6so8652046lbb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 08:21:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10si27317126wjo.134.2016.06.06.08.21.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 08:21:46 -0700 (PDT)
Subject: Re: [PATCH v2 7/7] mm/page_alloc: introduce post allocation
 processing on page allocator
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <21ab870c-7470-bb28-d8db-4dba25077854@suse.cz>
Date: Mon, 6 Jun 2016 17:21:45 +0200
MIME-Version: 1.0
In-Reply-To: <1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> This patch is motivated from Hugh and Vlastimil's concern [1].
>
> There are two ways to get freepage from the allocator. One is using
> normal memory allocation API and the other is __isolate_free_page() which
> is internally used for compaction and pageblock isolation. Later usage is
> rather tricky since it doesn't do whole post allocation processing
> done by normal API.
>
> One problematic thing I already know is that poisoned page would not be
> checked if it is allocated by __isolate_free_page(). Perhaps, there would
> be more.
>
> We could add more debug logic for allocated page in the future and this
> separation would cause more problem. I'd like to fix this situation
> at this time. Solution is simple. This patch commonize some logic
> for newly allocated page and uses it on all sites. This will solve
> the problem.
>
> [1] http://marc.info/?i=alpine.LSU.2.11.1604270029350.7066%40eggly.anvils%3E
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Yes that's much better. Hopefully introducing a function call into 
prep_new_page() (or can compiler still inline it there?) doesn't impact 
the fast paths though.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c     |  8 +-------
>  mm/internal.h       |  2 ++
>  mm/page_alloc.c     | 22 +++++++++++++---------
>  mm/page_isolation.c |  4 +---
>  4 files changed, 17 insertions(+), 19 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6043ef8..e15d350 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -75,14 +75,8 @@ static void map_pages(struct list_head *list)
>
>  		order = page_private(page);
>  		nr_pages = 1 << order;
> -		set_page_private(page, 0);
> -		set_page_refcounted(page);
>
> -		arch_alloc_page(page, order);
> -		kernel_map_pages(page, nr_pages, 1);
> -		kasan_alloc_pages(page, order);
> -
> -		set_page_owner(page, order, __GFP_MOVABLE);
> +		post_alloc_hook(page, order, __GFP_MOVABLE);
>  		if (order)
>  			split_page(page, order);
>
> diff --git a/mm/internal.h b/mm/internal.h
> index b6ead95..420bbe3 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -153,6 +153,8 @@ extern int __isolate_free_page(struct page *page, unsigned int order);
>  extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
>  					unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned int order);
> +extern void post_alloc_hook(struct page *page, unsigned int order,
> +					gfp_t gfp_flags);
>  extern int user_min_free_kbytes;
>
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 616ada9..baa5999 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1722,6 +1722,18 @@ static bool check_new_pages(struct page *page, unsigned int order)
>  	return false;
>  }
>
> +void post_alloc_hook(struct page *page, unsigned int order, gfp_t gfp_flags)
> +{
> +	set_page_private(page, 0);
> +	set_page_refcounted(page);
> +
> +	arch_alloc_page(page, order);
> +	kernel_map_pages(page, 1 << order, 1);
> +	kernel_poison_pages(page, 1 << order, 1);
> +	kasan_alloc_pages(page, order);
> +	set_page_owner(page, order, gfp_flags);
> +}
> +
>  static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  							unsigned int alloc_flags)
>  {
> @@ -1734,13 +1746,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
>  			poisoned &= page_is_poisoned(p);
>  	}
>
> -	set_page_private(page, 0);
> -	set_page_refcounted(page);
> -
> -	arch_alloc_page(page, order);
> -	kernel_map_pages(page, 1 << order, 1);
> -	kernel_poison_pages(page, 1 << order, 1);
> -	kasan_alloc_pages(page, order);
> +	post_alloc_hook(page, order, gfp_flags);
>
>  	if (!free_pages_prezeroed(poisoned) && (gfp_flags & __GFP_ZERO))
>  		for (i = 0; i < (1 << order); i++)
> @@ -1749,8 +1755,6 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
>  	if (order && (gfp_flags & __GFP_COMP))
>  		prep_compound_page(page, order);
>
> -	set_page_owner(page, order, gfp_flags);
> -
>  	/*
>  	 * page is set pfmemalloc when ALLOC_NO_WATERMARKS was necessary to
>  	 * allocate the page. The expectation is that the caller is taking
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 927f5ee..4639163 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -128,9 +128,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	if (isolated_page) {
> -		kernel_map_pages(page, (1 << order), 1);
> -		set_page_refcounted(page);
> -		set_page_owner(page, order, __GFP_MOVABLE);
> +		post_alloc_hook(page, order, __GFP_MOVABLE);
>  		__free_pages(isolated_page, order);
>  	}
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
