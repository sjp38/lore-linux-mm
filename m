Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3884C6B025F
	for <linux-mm@kvack.org>; Mon,  9 May 2016 04:07:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so364886383pfz.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 01:07:15 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id uq9si37436737pac.211.2016.05.09.01.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 01:07:14 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 145so15447057pfz.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 01:07:14 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 9 May 2016 17:07:07 +0900
Subject: Re: [PATCH] zsmalloc: fix zs_can_compact() integer overflow
Message-ID: <20160509080707.GB5434@blaptop>
References: <1462779333-7092-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462779333-7092-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "[4.3+]" <stable@vger.kernel.org>

Hello Sergey,

On Mon, May 09, 2016 at 04:35:33PM +0900, Sergey Senozhatsky wrote:
> zs_can_compact() has two race conditions in its core calculation:
> 
> unsigned long obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> 				zs_stat_get(class, OBJ_USED);
> 
> 1) classes are not locked, so the numbers of allocated and used
>    objects can change by the concurrent ops happening on other CPUs
> 2) shrinker invokes it from preemptible context
> 
> Depending on the circumstances, OBJ_ALLOCATED can become less
> than OBJ_USED, which can result in either very high or negative
> `total_scan' value calculated in do_shrink_slab().

So, do you see pr_err("shrink_slab: %pF negative objects xxxx)
in vmscan.c and skip shrinking?

It would be better to explain what's the result without this patch
and end-user effect for going -stable.

At least, I seem to see above pr_err but at that time if I remember
correctly but at that time I thought it was a bug I introduces in
development process. Since then, I cannot reproduce the symptom
until now. :)

Good catch!
Comment is below.

> 
> Take a pool stat snapshot and use it instead of racy zs_stat_get()
> calls.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: <stable@vger.kernel.org>        [4.3+]
> ---
>  mm/zsmalloc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 107ec06..1bc2a98 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -2262,10 +2262,13 @@ static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage)

It seems this patch is based on my old page migration work?
It's not go to the mainline yet but your patch which fixes the bug should
be supposed to go to the -stable. So, I hope this patch first.

Thanks.

>  static unsigned long zs_can_compact(struct size_class *class)
>  {
>  	unsigned long obj_wasted;
> +	unsigned long obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
> +	unsigned long obj_used = zs_stat_get(class, OBJ_USED);
>  
> -	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> -		zs_stat_get(class, OBJ_USED);
> +	if (obj_allocated <= obj_used)
> +		return 0;
>  
> +	obj_wasted = obj_allocated - obj_used;
>  	obj_wasted /= get_maxobj_per_zspage(class->size,
>  			class->pages_per_zspage);
>  
> -- 
> 2.8.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
