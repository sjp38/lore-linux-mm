Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id EACB76B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 10:43:07 -0400 (EDT)
Received: by iofh134 with SMTP id h134so24661232iof.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:43:07 -0700 (PDT)
Received: from m12-12.163.com (m12-12.163.com. [220.181.12.12])
        by mx.google.com with ESMTP id f77si6604371iod.26.2015.09.09.07.43.00
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 07:43:05 -0700 (PDT)
Date: Wed, 9 Sep 2015 22:41:42 +0800
From: Yaowei Bai <bywxiaobai@163.com>
Subject: Re: [PATCH v3] mm/page_alloc: add a helper function to check page
 before alloc/free
Message-ID: <20150909144142.GA4934@bbox>
References: <1440679917-3507-1-git-send-email-bywxiaobai@163.com>
 <55EF34AB.5040003@suse.cz>
 <55F036AA.9040508@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55F036AA.9040508@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 09, 2015 at 03:39:54PM +0200, Vlastimil Babka wrote:
> On 09/08/2015 09:19 PM, Vlastimil Babka wrote:
> >bloat-o-meter looks favorably with my gcc, although there shouldn't be a real
> >reason for it, as the inlining didn't change:
> >
> >add/remove: 1/1 grow/shrink: 1/1 up/down: 285/-336 (-51)
> >function                                     old     new   delta
> >bad_page                                       -     276    +276
> >get_page_from_freelist                      2521    2530      +9
> >free_pages_prepare                           745     667     -78
> >bad_page.part                                258       -    -258
> >
> >With that,
> >
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> BTW, why do we do all these checks in non-DEBUG_VM builds? Are they
> so often hit nowadays? Shouldn't we check just for hwpoison in the
> non-debug case?

I personly think these checks are still needed in non-debug scenario so
we can still catch the bad page caused by a bug or other things in that
case.

> 
> Alternatively, I've considered creating a fast inline pre-check that
> calls a non-inline check-with-report:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0c9c82a..cff92f8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -707,7 +707,20 @@ static inline void __free_one_page(struct page *page,
>  	zone->free_area[order].nr_free++;
>  }
> 
> -static inline int check_one_page(struct page *page, unsigned long
> bad_flags)
> +static inline int check_one_page_fast(struct page *page, unsigned long
> +		bad_flags)
> +{
> +	return (page_mapcount(page)
> +			|| page->mapping != NULL
> +			|| atomic_read(&page->_count) != 0
> +			|| page->flags & bad_flags
> +#ifdef CONFIG_MEMCG
> +			|| page->mem_cgroup
> +#endif
> +			);
> +}
> +
> +static noinline int check_one_page(struct page *page, unsigned long
> bad_flags)
>  {
>  	const char *bad_reason = NULL;
> 
> @@ -743,9 +756,12 @@ static inline int free_pages_check(struct page *page)
>  {
>  	int ret = 0;
> 
> -	ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
> -	if (ret)
> -		return ret;
> +	ret = check_one_page_fast(page, PAGE_FLAGS_CHECK_AT_FREE);
> +	if (ret) {
> +		ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
> +		if (ret)
> +			return ret;
> +	}
> 
>  	page_cpupid_reset_last(page);
>  	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> @@ -1304,7 +1320,9 @@ static inline void expand(struct zone *zone,
> struct page *page,
>   */
>  static inline int check_new_page(struct page *page)
>  {
> -	return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
> +	if (check_one_page_fast(page, PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON))
> +		return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
> +	return 0;
>  }
> 
>  static int prep_new_page(struct page *page, unsigned int order,
> gfp_t gfp_flags,
> 
> ---

This looks good to me.

> 
> That shrinks the fast paths nicely:
> 
> add/remove: 1/1 grow/shrink: 0/2 up/down: 480/-498 (-18)
> function                                     old     new   delta
> check_one_page                                 -     480    +480
> get_page_from_freelist                      2530    2458     -72
> free_pages_prepare                           667     517    -150
> bad_page                                     276       -    -276
> 
> On top of that, the number of branches in the fast paths can be
> reduced if we use arithmetic OR to avoid the short-circuit boolean
> evaluation:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cff92f8..e8b42ba 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -710,12 +710,12 @@ static inline void __free_one_page(struct page *page,
>  static inline int check_one_page_fast(struct page *page, unsigned long
>  		bad_flags)
>  {
> -	return (page_mapcount(page)
> -			|| page->mapping != NULL
> -			|| atomic_read(&page->_count) != 0
> -			|| page->flags & bad_flags
> +	return ((unsigned long) page_mapcount(page)
> +			| (unsigned long) page->mapping
> +			| (unsigned long) atomic_read(&page->_count)
> +			| (page->flags & bad_flags)
>  #ifdef CONFIG_MEMCG
> -			|| page->mem_cgroup
> +			| (unsigned long) page->mem_cgroup
>  #endif
>  			);
>  }
> 
> That further reduces the fast paths, not much in bytes, but
> importantly in branches:
> 
> add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-51 (-51)
> function                                     old     new   delta
> get_page_from_freelist                      2458    2443     -15
> free_pages_prepare                           517     481     -36
> 
> But I can understand it's rather hackish, and maybe some
> architectures won't be happy with the extra unsigned long
> arithmetics. Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
