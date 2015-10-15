Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 266396B0254
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 22:26:38 -0400 (EDT)
Received: by pacao1 with SMTP id ao1so6991887pac.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 19:26:37 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id sm7si17865113pac.65.2015.10.14.19.26.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 19:26:37 -0700 (PDT)
Received: by pabws5 with SMTP id ws5so7819860pab.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 19:26:37 -0700 (PDT)
Date: Thu, 15 Oct 2015 11:29:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: don't test shrinker_enabled in
 zs_shrinker_count()
Message-ID: <20151015022928.GB2840@bbox>
References: <1444787879-5428-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444787879-5428-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Oct 14, 2015 at 10:57:59AM +0900, Sergey Senozhatsky wrote:
> We don't let user to disable shrinker in zsmalloc (once
> it's been enabled), so no need to check ->shrinker_enabled
> in zs_shrinker_count(), at the moment at least.

I'm in favor of removing shrinker disable feature with this patch(
although we didn't implement it yet) because if there is some problem
of compaction, we should reveal and fix it without hiding with the
feature.

One thing I want is if we decide it, let's remove all things
about shrinker_enabled(ie, variable).
If we might need it later, we could introduce it easily.

Thanks.

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 7ad5e54..8ba247d 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1822,9 +1822,6 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
>  	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
>  			shrinker);
>  
> -	if (!pool->shrinker_enabled)
> -		return 0;
> -
>  	for (i = zs_size_classes - 1; i >= 0; i--) {
>  		class = pool->size_class[i];
>  		if (!class)
> -- 
> 2.6.1.134.g4b1fd35
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
