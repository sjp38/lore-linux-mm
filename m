Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2324F6B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:56:46 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so100928389lfw.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:56:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si4433572wmi.89.2016.08.23.09.56.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 09:56:44 -0700 (PDT)
Subject: Re: [PATCH] mm: page should be aligned with max_order
References: <1471961400-1536-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f7690e60-33d4-5fd9-f542-f62a97fef8d2@suse.cz>
Date: Tue, 23 Aug 2016 18:56:44 +0200
MIME-Version: 1.0
In-Reply-To: <1471961400-1536-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

On 23.8.2016 16:10, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> At present, page aligned with MAX_ORDER make no sense.

Is it a bug that manifests... how?

Does it make more sense with max_order? why?

I think we could just drop the page_idx masking and use pfn directly.
__find_buddy_index() only looks at the 1 << order bit. Then there are operations
such as (buddy_idx & page_idx) and (combined_idx - page_idx),
none of these should care about the bits higher than MAX_ORDER/max_order as the
subtraction cancels them out. That's also why the "mistake" you point out
doesn't result in a bug IMHO.

> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ff726f94..a178b1d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -786,7 +786,7 @@ static inline void __free_one_page(struct page *page,
>  	if (likely(!is_migrate_isolate(migratetype)))
>  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>  
> -	page_idx = pfn & ((1 << MAX_ORDER) - 1);
> +	page_idx = pfn & ((1 << max_order) - 1);
>  
>  	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
