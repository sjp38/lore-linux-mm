Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C72896B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:06:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b10-v6so4779804wrf.3
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:06:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1si2419442edb.210.2018.04.19.04.06.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 04:06:31 -0700 (PDT)
Subject: Re: [PATCH v3 04/14] mm: Switch s_mem and slab_cache in struct page
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-5-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <635be88e-c361-1773-eff7-9921de503566@suse.cz>
Date: Thu, 19 Apr 2018 13:06:30 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-5-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>

More rationale? Such as "This will allow us to ... later in the series"?

> slub now needs to set page->mapping to NULL as it frees the page, just
> like slab does.

I wonder if they should be touching the mapping field, and rather not
the slab_cache field, with a comment why it has to be NULLed?

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 4 ++--
>  mm/slub.c                | 1 +
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 41828fb34860..e97a310a6abe 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -83,7 +83,7 @@ struct page {
>  		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
>  		struct address_space *mapping;
>  
> -		void *s_mem;			/* slab first object */
> +		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
>  		atomic_t compound_mapcount;	/* first tail page */
>  		/* page_deferred_list().next	 -- second tail page */
>  	};
> @@ -194,7 +194,7 @@ struct page {
>  		spinlock_t ptl;
>  #endif
>  #endif
> -		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> +		void *s_mem;			/* slab first object */
>  	};
>  
>  #ifdef CONFIG_MEMCG
> diff --git a/mm/slub.c b/mm/slub.c
> index 099925cf456a..27b6ba1c116a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1690,6 +1690,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  	__ClearPageSlab(page);
>  
>  	page_mapcount_reset(page);
> +	page->mapping = NULL;
>  	if (current->reclaim_state)
>  		current->reclaim_state->reclaimed_slab += pages;
>  	memcg_uncharge_slab(page, order, s);
> 
