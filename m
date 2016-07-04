Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13F076B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 20:02:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so362894361pfx.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 17:02:37 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id yp3si884162pac.27.2016.07.03.17.02.35
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 17:02:36 -0700 (PDT)
Date: Mon, 4 Jul 2016 09:03:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/8] mm/zsmalloc: avoid calculate max objects of zspage
 twice
Message-ID: <20160704000317.GD19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-5-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-5-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:03PM +0800, Ganesh Mahendran wrote:
> Currently, if a class can not be merged, the max objects of zspage
> in that class may be calculated twice.
> 
> This patch calculate max objects of zspage at the begin, and pass
> the value to can_merge() to decide whether the class can be merged.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 50283b1..2690914 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1362,16 +1362,14 @@ static void init_zs_size_classes(void)
>  	zs_size_classes = nr;
>  }
>  
> -static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
> +static bool can_merge(struct size_class *prev, int pages_per_zspage,
> +					int objs_per_zspage)
>  {
> -	if (prev->pages_per_zspage != pages_per_zspage)
> -		return false;
> -
> -	if (prev->objs_per_zspage
> -		!= get_maxobj_per_zspage(size, pages_per_zspage))
> -		return false;
> +	if (prev->pages_per_zspage == pages_per_zspage &&
> +		prev->objs_per_zspage == objs_per_zspage)
> +		return true;
>  
> -	return true;
> +	return false;
>  }
>  
>  static bool zspage_full(struct size_class *class, struct zspage *zspage)
> @@ -2460,6 +2458,7 @@ struct zs_pool *zs_create_pool(const char *name)
>  	for (i = zs_size_classes - 1; i >= 0; i--) {
>  		int size;
>  		int pages_per_zspage;
> +		int objs_per_zspage;
>  		struct size_class *class;
>  		int fullness = 0;
>  
> @@ -2467,6 +2466,7 @@ struct zs_pool *zs_create_pool(const char *name)
>  		if (size > ZS_MAX_ALLOC_SIZE)
>  			size = ZS_MAX_ALLOC_SIZE;
>  		pages_per_zspage = get_pages_per_zspage(size);
> +		objs_per_zspage = get_maxobj_per_zspage(size, pages_per_zspage);

So, user of get_maxobj_per_zspage is only here? If so, let's remove
get_maxobj_per_zspage to prevent misuse in future. Instead, use open code
here.


>  
>  		/*
>  		 * size_class is used for normal zsmalloc operation such
> @@ -2478,7 +2478,7 @@ struct zs_pool *zs_create_pool(const char *name)
>  		 * previous size_class if possible.
>  		 */
>  		if (prev_class) {
> -			if (can_merge(prev_class, size, pages_per_zspage)) {
> +			if (can_merge(prev_class, pages_per_zspage, objs_per_zspage)) {
>  				pool->size_class[i] = prev_class;
>  				continue;
>  			}
> @@ -2491,8 +2491,7 @@ struct zs_pool *zs_create_pool(const char *name)
>  		class->size = size;
>  		class->index = i;
>  		class->pages_per_zspage = pages_per_zspage;
> -		class->objs_per_zspage = get_maxobj_per_zspage(class->size,
> -							class->pages_per_zspage);
> +		class->objs_per_zspage = objs_per_zspage;
>  		spin_lock_init(&class->lock);
>  		pool->size_class[i] = class;
>  		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
