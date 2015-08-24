Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 32F006B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:47:50 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so45964200wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:47:49 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id f5si20723266wiz.82.2015.08.24.03.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:47:48 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so67893039wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:47:48 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:47:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm/page_alloc: add a helper function to check page
 before alloc/free
Message-ID: <20150824104745.GJ17078@dhcp22.suse.cz>
References: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
 <1440229212-8737-2-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440229212-8737-2-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 22-08-15 15:40:11, Yaowei Bai wrote:
> The major portion of check_new_page() and free_pages_check() are same,
> introduce a helper function check_one_page() for readablity.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  mm/page_alloc.c | 54 +++++++++++++++++++++++-------------------------------
>  1 file changed, 23 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c22b133..a0839de 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -707,7 +707,7 @@ out:
>  	zone->free_area[order].nr_free++;
>  }
>  
> -static inline int free_pages_check(struct page *page)
> +static inline int check_one_page(struct page *page, bool free)
>  {
>  	const char *bad_reason = NULL;
>  	unsigned long bad_flags = 0;
> @@ -718,10 +718,16 @@ static inline int free_pages_check(struct page *page)
>  		bad_reason = "non-NULL mapping";
>  	if (unlikely(atomic_read(&page->_count) != 0))
>  		bad_reason = "nonzero _count";
> -	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
> -		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
> -		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
> -	}
> +	if (free)
> +		if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
> +			bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
> +			bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
> +		}
> +	else
> +		if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
> +			bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
> +			bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
> +		}

Wouldn't it be easier to simply give bad_flags as another parameter?

>  #ifdef CONFIG_MEMCG
>  	if (unlikely(page->mem_cgroup))
>  		bad_reason = "page still charged to cgroup";
> @@ -730,6 +736,17 @@ static inline int free_pages_check(struct page *page)
>  		bad_page(page, bad_reason, bad_flags);
>  		return 1;
>  	}
> +	return 0;
> +}
> +
> +static inline int free_pages_check(struct page *page)
> +{
> +	int ret=0;
> +
> +	ret=check_one_page(page, true);
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
> +	return check_one_page(page, false);
>  }
>  
>  static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
