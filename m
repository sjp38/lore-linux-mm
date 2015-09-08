Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id F3AC26B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 15:19:12 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so126829872wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 12:19:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t16si7747029wjr.209.2015.09.08.12.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 12:19:11 -0700 (PDT)
Subject: Re: [PATCH v3] mm/page_alloc: add a helper function to check page
 before alloc/free
References: <1440679917-3507-1-git-send-email-bywxiaobai@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55EF34AB.5040003@suse.cz>
Date: Tue, 8 Sep 2015 21:19:07 +0200
MIME-Version: 1.0
In-Reply-To: <1440679917-3507-1-git-send-email-bywxiaobai@163.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>, akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/27/2015 02:51 PM, Yaowei Bai wrote:
> The major portion of check_new_page() and free_pages_check() are same,
> introduce a helper function check_one_page() for simplification.
> 
> Change in v3:
> 	- add the missed __PG_HWPOISON check per Michal Hocko
> Change in v2:
> 	- use bad_flags as parameter directly per Michal Hocko
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  mm/page_alloc.c | 54 +++++++++++++++++++++++-------------------------------
>  1 file changed, 23 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b5240b..0c9c82a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -707,10 +707,9 @@ out:
>  	zone->free_area[order].nr_free++;
>  }
>  
> -static inline int free_pages_check(struct page *page)
> +static inline int check_one_page(struct page *page, unsigned long bad_flags)
>  {
>  	const char *bad_reason = NULL;
> -	unsigned long bad_flags = 0;
>  
>  	if (unlikely(page_mapcount(page)))
>  		bad_reason = "nonzero mapcount";
> @@ -718,9 +717,16 @@ static inline int free_pages_check(struct page *page)
>  		bad_reason = "non-NULL mapping";
>  	if (unlikely(atomic_read(&page->_count) != 0))
>  		bad_reason = "nonzero _count";
> -	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
> -		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
> -		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
> +	if (bad_flags == PAGE_FLAGS_CHECK_AT_PREP) {
> +		if (unlikely(page->flags & bad_flags))
> +			bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
> +		if (unlikely(page->flags & __PG_HWPOISON)) {
> +			bad_reason = "HWPoisoned (hardware-corrupted)";
> +			bad_flags = __PG_HWPOISON;
> +		}

Before, HWPOISON was checked first, which means that it had lower priority than
PAGE_FLAGS_CHECK_AT_PREP (counter-intuitively). I can see why you switched that
though. You could fix that by changing the second nested "if" to "else if", but
I guess it doesn't matter. The "priorities" don't seem to be carefuly sorted anyway.

bloat-o-meter looks favorably with my gcc, although there shouldn't be a real
reason for it, as the inlining didn't change:

add/remove: 1/1 grow/shrink: 1/1 up/down: 285/-336 (-51)
function                                     old     new   delta
bad_page                                       -     276    +276
get_page_from_freelist                      2521    2530      +9
free_pages_prepare                           745     667     -78
bad_page.part                                258       -    -258

With that,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> +	} else if (bad_flags == PAGE_FLAGS_CHECK_AT_FREE) {
> +		if (unlikely(page->flags & bad_flags))
> +			bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag set";
>  	}
>  #ifdef CONFIG_MEMCG
>  	if (unlikely(page->mem_cgroup))
> @@ -730,6 +736,17 @@ static inline int free_pages_check(struct page *page)
>  		bad_page(page, bad_reason, bad_flags);
>  		return 1;
>  	}
> +	return 0;
> +}
> +
> +static inline int free_pages_check(struct page *page)
> +{
> +	int ret = 0;
> +
> +	ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
> +	if (ret)
> +		return ret;
> +
>  	page_cpupid_reset_last(page);
>  	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
>  		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> @@ -1287,32 +1304,7 @@ static inline void expand(struct zone *zone, struct page *page,
>   */
>  static inline int check_new_page(struct page *page)
>  {
> -	const char *bad_reason = NULL;
> -	unsigned long bad_flags = 0;
> -
> -	if (unlikely(page_mapcount(page)))
> -		bad_reason = "nonzero mapcount";
> -	if (unlikely(page->mapping != NULL))
> -		bad_reason = "non-NULL mapping";
> -	if (unlikely(atomic_read(&page->_count) != 0))
> -		bad_reason = "nonzero _count";
> -	if (unlikely(page->flags & __PG_HWPOISON)) {
> -		bad_reason = "HWPoisoned (hardware-corrupted)";
> -		bad_flags = __PG_HWPOISON;
> -	}
> -	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
> -		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
> -		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
> -	}
> -#ifdef CONFIG_MEMCG
> -	if (unlikely(page->mem_cgroup))
> -		bad_reason = "page still charged to cgroup";
> -#endif
> -	if (unlikely(bad_reason)) {
> -		bad_page(page, bad_reason, bad_flags);
> -		return 1;
> -	}
> -	return 0;
> +	return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
>  }
>  
>  static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
