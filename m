Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 543416B025E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:24:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so282023303pfe.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:24:36 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id d27si5493720pfj.14.2016.04.17.07.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 07:24:35 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id i5so179907pag.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:24:35 -0700 (PDT)
Date: Mon, 18 Apr 2016 00:22:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3 09/16] zsmalloc: move struct zs_meta from mapping to
 freelist
Message-ID: <20160417152216.GD575@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-10-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-10-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello,

On (03/30/16 16:12), Minchan Kim wrote:
> For supporting migration from VM, we need to have address_space
> on every page so zsmalloc shouldn't use page->mapping. So,
> this patch moves zs_meta from mapping to freelist.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

a small get_zspage_meta() helper would make this patch shorter :)

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  mm/zsmalloc.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 807998462539..d4d33a819832 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -29,7 +29,7 @@
>   *		Look at size_class->huge.
>   *	page->lru: links together first pages of various zspages.
>   *		Basically forming list of zspages in a fullness group.
> - *	page->mapping: override by struct zs_meta
> + *	page->freelist: override by struct zs_meta
>   *
>   * Usage of struct page flags:
>   *	PG_private: identifies the first component page
> @@ -418,7 +418,7 @@ static int get_zspage_inuse(struct page *first_page)
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  
>  	return m->inuse;
>  }
> @@ -429,7 +429,7 @@ static void set_zspage_inuse(struct page *first_page, int val)
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	m->inuse = val;
>  }
>  
> @@ -439,7 +439,7 @@ static void mod_zspage_inuse(struct page *first_page, int val)
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	m->inuse += val;
>  }
>  
> @@ -449,7 +449,7 @@ static void set_freeobj(struct page *first_page, int idx)
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	m->freeobj = idx;
>  }
>  
> @@ -459,7 +459,7 @@ static unsigned long get_freeobj(struct page *first_page)
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	return m->freeobj;
>  }
>  
> @@ -471,7 +471,7 @@ static void get_zspage_mapping(struct page *first_page,
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	*fullness = m->fullness;
>  	*class_idx = m->class;
>  }
> @@ -484,7 +484,7 @@ static void set_zspage_mapping(struct page *first_page,
>  
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> -	m = (struct zs_meta *)&first_page->mapping;
> +	m = (struct zs_meta *)&first_page->freelist;
>  	m->fullness = fullness;
>  	m->class = class_idx;
>  }
> @@ -946,7 +946,6 @@ static void reset_page(struct page *page)
>  	clear_bit(PG_private, &page->flags);
>  	clear_bit(PG_private_2, &page->flags);
>  	set_page_private(page, 0);
> -	page->mapping = NULL;
>  	page->freelist = NULL;
>  }
>  
> @@ -1056,6 +1055,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>  
>  		INIT_LIST_HEAD(&page->lru);
>  		if (i == 0) {	/* first page */
> +			page->freelist = NULL;
>  			SetPagePrivate(page);
>  			set_page_private(page, 0);
>  			first_page = page;
> @@ -2068,9 +2068,9 @@ static int __init zs_init(void)
>  
>  	/*
>  	 * A zspage's a free object index, class index, fullness group,
> -	 * inuse object count are encoded in its (first)page->mapping
> +	 * inuse object count are encoded in its (first)page->freelist
>  	 * so sizeof(struct zs_meta) should be less than
> -	 * sizeof(page->mapping(i.e., unsigned long)).
> +	 * sizeof(page->freelist(i.e., void *)).
>  	 */
>  	BUILD_BUG_ON(sizeof(struct zs_meta) > sizeof(unsigned long));
>  
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
