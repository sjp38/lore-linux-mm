Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 166A76B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 04:15:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so50604764wme.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:15:30 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 186si6898687wmz.140.2016.08.10.01.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 01:15:28 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id q128so7991372wma.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:15:28 -0700 (PDT)
Date: Wed, 10 Aug 2016 17:14:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 1/5] mm/debug_pagealloc: clean-up guard page handling code
Message-ID: <20160810081453.GB573@swordfish>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470809784-11516-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

On (08/10/16 15:16), js1304@gmail.com wrote:
[..]
> -static inline void set_page_guard(struct zone *zone, struct page *page,
> +static inline bool set_page_guard(struct zone *zone, struct page *page,
>  				unsigned int order, int migratetype)
>  {
>  	struct page_ext *page_ext;
>  
>  	if (!debug_guardpage_enabled())
> -		return;
> +		return false;
> +
> +	if (order >= debug_guardpage_minorder())
> +		return false;
>  
>  	page_ext = lookup_page_ext(page);
>  	if (unlikely(!page_ext))
> -		return;
> +		return false;
>  
>  	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
>  
> @@ -656,6 +659,8 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
>  	set_page_private(page, order);
>  	/* Guard pages are not available for any usage */
>  	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
> +
> +	return true;
>  }
>  
>  static inline void clear_page_guard(struct zone *zone, struct page *page,
> @@ -678,8 +683,8 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>  }
>  #else
>  struct page_ext_operations debug_guardpage_ops = { NULL, };
> -static inline void set_page_guard(struct zone *zone, struct page *page,
> -				unsigned int order, int migratetype) {}
> +static inline bool set_page_guard(struct zone *zone, struct page *page,
> +			unsigned int order, int migratetype) { return false; }
>  static inline void clear_page_guard(struct zone *zone, struct page *page,
>  				unsigned int order, int migratetype) {}
>  #endif
> @@ -1650,18 +1655,15 @@ static inline void expand(struct zone *zone, struct page *page,
>  		size >>= 1;
>  		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
>  
> -		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
> -			debug_guardpage_enabled() &&
> -			high < debug_guardpage_minorder()) {
> -			/*
> -			 * Mark as guard pages (or page), that will allow to
> -			 * merge back to allocator when buddy will be freed.
> -			 * Corresponding page table entries will not be touched,
> -			 * pages will stay not present in virtual address space
> -			 */
> -			set_page_guard(zone, &page[size], high, migratetype);
> +		/*
> +		 * Mark as guard pages (or page), that will allow to
> +		 * merge back to allocator when buddy will be freed.
> +		 * Corresponding page table entries will not be touched,
> +		 * pages will stay not present in virtual address space
> +		 */
> +		if (set_page_guard(zone, &page[size], high, migratetype))
>  			continue;
> -		}

so previously IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) could have optimized out
the entire branch -- no set_page_guard() invocation and checks, right? but
now we would call set_page_guard() every time?

	-ss

> +
>  		list_add(&page[size].lru, &area->free_list[migratetype]);
>  		area->nr_free++;
>  		set_page_order(&page[size], high);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
