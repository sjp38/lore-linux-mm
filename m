Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4A26B0038
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 01:13:45 -0500 (EST)
Received: by pfbg73 with SMTP id g73so62021768pfb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:13:45 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id wp13si1305032pac.180.2015.12.10.22.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 22:13:43 -0800 (PST)
Received: by pfbu66 with SMTP id u66so17075225pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:13:43 -0800 (PST)
Date: Fri, 11 Dec 2015 15:14:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: reorganize struct size_class to pack 4 bytes
 hole
Message-ID: <20151211061447.GA6950@swordfish>
References: <"000001d133d3$b75f09b0$261d1d10$@yang"@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <"000001d133d3$b75f09b0$261d1d10$@yang"@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, sergey.senozhatsky.work@gmail.com, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Cc linux-mm and linux-kernel

On (12/11/15 13:20), Weijie Yang wrote:
> 
> Reoder the pages_per_zspage field in struct size_class which can eliminate
> the 4 bytes hole between it and stats field.
> 

Looks good to me.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  mm/zsmalloc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 9f15bdd..e7414ce 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -213,10 +213,10 @@ struct size_class {
>  	int size;
>  	unsigned int index;
>  
> -	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> -	int pages_per_zspage;
>  	struct zs_size_stat stats;
>  
> +	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> +	int pages_per_zspage;
>  	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
>  	bool huge;
>  };


we also can re-order `struct zs_pool' -- `gfp_t flags' and `bool shrinker_enabled'
will be fine together.

I can send a separate patch of we can fold the one below.
I'm good either way.

---

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9f15bdd..2a3af25 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -246,19 +246,17 @@ struct zs_pool {
 
 	struct size_class **size_class;
 	struct kmem_cache *handle_cachep;
-
-	gfp_t flags;	/* allocation flags used when growing pool */
-	atomic_long_t pages_allocated;
-
 	struct zs_pool_stats stats;
-
-	/* Compact classes */
-	struct shrinker shrinker;
+	atomic_long_t pages_allocated;
+	/* allocation flags used when growing pool */
+	gfp_t flags;
 	/*
 	 * To signify that register_shrinker() was successful
 	 * and unregister_shrinker() will not Oops.
 	 */
 	bool shrinker_enabled;
+	/* Compact classes */
+	struct shrinker shrinker;
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
