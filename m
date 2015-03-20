Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D52566B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:55:19 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so97547829pdn.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 21:55:19 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id wy1si6930834pab.171.2015.03.19.21.55.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 21:55:18 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so97330889pdb.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 21:55:18 -0700 (PDT)
Date: Fri, 20 Mar 2015 13:55:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm/zsmalloc.c: count in handle's size when calculating
 pages_per_zspage
Message-ID: <20150320045509.GA11582@blaptop>
References: <430707086.362221426765159948.JavaMail.weblogic@epmlwas05d>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <430707086.362221426765159948.JavaMail.weblogic@epmlwas05d>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghao Xie <yinghao.xie@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, Mar 19, 2015 at 11:39:20AM +0000, Yinghao Xie wrote:
> From 159d74b5a8f3d0f07e18ddad74b7025cf17dcc69 Mon Sep 17 00:00:00 2001
> From: Yinghao Xie <yinghao.xie@sumsung.com>
> Date: Thu, 19 Mar 2015 19:32:25 +0800
> Subject: [PATCH] mm/zsmalloc.c: count in handle's size when calculating
>  size_class's pages_per_zspage
> 
> 1. Fix wastage calculation;
> 2. Indirect handle introduced extra ZS_HANDLE_SIZE size for each object,it's transparent
>    for upper function, but a size_class's total objects will changed:
>    take the 43rd class which class_size = 32 + 43 * 16 = 720 as example:
> 	4096 * 1 % 720 = 496
> 	4096 * 2 % 720 = 272
> 	4096 * 3 % 720 = 48 
> 	4096 * 4 %720 = 544
>    after handle introduced,class_size + ZS_HANDLE_SIZE (4 on 32bit) = 724
> 	4096 * 1 % 724 = 476
> 	4096 * 2 % 724 = 228
> 	4096 * 3 % 724 = 704
> 	4096 * 4 % 724 = 456
>     Clearly, ZS_HANDLE_SIZE should be considered when calculating pages_per_zspage;

Zsmalloc adds ZS_SIZE_HANDLE to size user passed before getting size_class so
we don't need to change size_class to calculate optimal pages for zspage.

> 
> 3. in get_size_class_index(), min(zs_size_classes - 1, idx) insures a huge class's
>    index <= zs_size_classes - 1, so it's no need to check again;

Sorry, I don't get it, either.

> 
> Signed-off-by: Yinghao Xie <yinghao.xie@sumsung.com>
> ---
>  mm/zsmalloc.c |   15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 461243e..64c379b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -760,7 +760,8 @@ out:
>   * to form a zspage for each size class. This is important
>   * to reduce wastage due to unusable space left at end of
>   * each zspage which is given as:
> - *	wastage = Zp - Zp % size_class
> + *	wastage = Zp % (class_size + ZS_HANDLE_SIZE)
> + *	usage = Zp - wastage
>   * where Zp = zspage size = k * PAGE_SIZE where k = 1, 2, ...
>   *
>   * For example, for size class of 3/8 * PAGE_SIZE, we should
> @@ -773,6 +774,9 @@ static int get_pages_per_zspage(int class_size)
>  	/* zspage order which gives maximum used size per KB */
>  	int max_usedpc_order = 1;
>  
> +	if (class_size > ZS_MAX_ALLOC_SIZE)
> +		class_size = ZS_MAX_ALLOC_SIZE;
> +
>  	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
>  		int zspage_size;
>  		int waste, usedpc;
> @@ -1426,11 +1430,6 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  	/* extra space in chunk to keep the handle */
>  	size += ZS_HANDLE_SIZE;
>  	class = pool->size_class[get_size_class_index(size)];
> -	/* In huge class size, we store the handle into first_page->private */
> -	if (class->huge) {
> -		size -= ZS_HANDLE_SIZE;
> -		class = pool->size_class[get_size_class_index(size)];
> -	}
>  
>  	spin_lock(&class->lock);
>  	first_page = find_get_zspage(class);
> @@ -1856,9 +1855,7 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
>  		struct size_class *class;
>  
>  		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> -		if (size > ZS_MAX_ALLOC_SIZE)
> -			size = ZS_MAX_ALLOC_SIZE;
> -		pages_per_zspage = get_pages_per_zspage(size);
> +		pages_per_zspage = get_pages_per_zspage(size + ZS_HANDLE_SIZE);
>  
>  		/*
>  		 * size_class is used for normal zsmalloc operation such
> -- 
> 1.7.9.5

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
