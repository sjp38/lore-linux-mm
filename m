Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEC86B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 20:24:59 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ib6so196079711pad.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 17:24:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c69si152036pfj.224.2016.07.10.17.24.58
        for <linux-mm@kvack.org>;
        Sun, 10 Jul 2016 17:24:58 -0700 (PDT)
Date: Mon, 11 Jul 2016 09:26:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return
 value of PageMovable
Message-ID: <20160711002605.GD31817@bbox>
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
MIME-Version: 1.0
In-Reply-To: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Sat, Jul 09, 2016 at 11:55:04PM +0800, chengang@emindsoft.com.cn wrote:
> From: Chen Gang <chengang@emindsoft.com.cn>
> 
> For pure bool function's return value, bool is a little better more or
> less than int.
> 
> And return boolean result directly, since 'if' statement is also for
> boolean checking, and return boolean result, too.

I just wanted to consistent with other PageXXX flags functions, PageAnon,
PageMappingFlags which returns int rather than bool. Although I agree bool
is natural, I want to be consistent with others rather than breaking at
the moment.

Maybe if you feel it's really helpful, you might be able to handle all
of places I mentioned for better readability and keeping consistency.
But I doubt it's worth.

Thanks.

> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

> ---
>  include/linux/migrate.h | 4 ++--
>  mm/compaction.c         | 9 +++------
>  2 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index ae8d475..0e366f8 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -72,11 +72,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
>  #endif /* CONFIG_MIGRATION */
>  
>  #ifdef CONFIG_COMPACTION
> -extern int PageMovable(struct page *page);
> +extern bool PageMovable(struct page *page);
>  extern void __SetPageMovable(struct page *page, struct address_space *mapping);
>  extern void __ClearPageMovable(struct page *page);
>  #else
> -static inline int PageMovable(struct page *page) { return 0; };
> +static inline bool PageMovable(struct page *page) { return false; };
>  static inline void __SetPageMovable(struct page *page,
>  				struct address_space *mapping)
>  {
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0bd53fb..cfcfe88 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -95,19 +95,16 @@ static inline bool migrate_async_suitable(int migratetype)
>  
>  #ifdef CONFIG_COMPACTION
>  
> -int PageMovable(struct page *page)
> +bool PageMovable(struct page *page)
>  {
>  	struct address_space *mapping;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	if (!__PageMovable(page))
> -		return 0;
> +		return false;
>  
>  	mapping = page_mapping(page);
> -	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
> -		return 1;
> -
> -	return 0;
> +	return mapping && mapping->a_ops && mapping->a_ops->isolate_page;
>  }
>  EXPORT_SYMBOL(PageMovable);
>  
> -- 
> 1.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
