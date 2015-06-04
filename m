Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 29A51900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:14:20 -0400 (EDT)
Received: by padj3 with SMTP id j3so19974827pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:14:19 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ca15si3755574pdb.31.2015.06.03.20.14.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:14:19 -0700 (PDT)
Received: by payr10 with SMTP id r10so20050922pay.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:14:19 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:14:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 04/10] zsmalloc: cosmetic compaction code adjustments
Message-ID: <20150604031412.GF2241@blaptop>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-5-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432911928-14654-5-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sat, May 30, 2015 at 12:05:22AM +0900, Sergey Senozhatsky wrote:
> change zs_object_copy() argument order to be (DST, SRC) rather
> than (SRC, DST). copy/move functions usually have (to, from)
> arguments order.

Yeb,

> 
> rename alloc_target_page() to isolate_target_page(). this
> function doesn't allocate anything, it isolates target page,
> pretty much like isolate_source_page().

The reason I named it as alloc_target_page is I had a plan to
alloc new page which might be helpful sometime but I cannot
think of any benefit now so I follow your your patch.

> 
> tweak __zs_compact() comment.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  mm/zsmalloc.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 9ef6f15..fa72a81 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1469,7 +1469,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
>  }
>  EXPORT_SYMBOL_GPL(zs_free);
>  
> -static void zs_object_copy(unsigned long src, unsigned long dst,
> +static void zs_object_copy(unsigned long dst, unsigned long src,
>  				struct size_class *class)
>  {
>  	struct page *s_page, *d_page;
> @@ -1610,7 +1610,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  
>  		used_obj = handle_to_obj(handle);
>  		free_obj = obj_malloc(d_page, class, handle);
> -		zs_object_copy(used_obj, free_obj, class);
> +		zs_object_copy(free_obj, used_obj, class);
>  		index++;
>  		record_obj(handle, free_obj);
>  		unpin_tag(handle);
> @@ -1626,7 +1626,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  	return ret;
>  }
>  
> -static struct page *alloc_target_page(struct size_class *class)
> +static struct page *isolate_target_page(struct size_class *class)
>  {
>  	int i;
>  	struct page *page;
> @@ -1714,11 +1714,11 @@ static unsigned long __zs_compact(struct zs_pool *pool,
>  		cc.index = 0;
>  		cc.s_page = src_page;
>  
> -		while ((dst_page = alloc_target_page(class))) {
> +		while ((dst_page = isolate_target_page(class))) {
>  			cc.d_page = dst_page;
>  			/*
> -			 * If there is no more space in dst_page, try to
> -			 * allocate another zspage.
> +			 * If there is no more space in dst_page, resched
> +			 * and see if anyone had allocated another zspage.
>  			 */
>  			if (!migrate_zspage(pool, class, &cc))
>  				break;
> -- 
> 2.4.2.337.gfae46aa
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
