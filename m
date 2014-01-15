Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0096B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 14:48:58 -0500 (EST)
Received: by mail-gg0-f174.google.com with SMTP id g10so617360gga.19
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 11:48:58 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id j24si6615302yhb.96.2014.01.15.11.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 11:48:57 -0800 (PST)
Received: by mail-ob0-f180.google.com with SMTP id wm4so1646065obc.25
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 11:48:56 -0800 (PST)
Date: Wed, 15 Jan 2014 13:48:49 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zbud: use list_last_entry in zbud_reclaim_page()
 directly
Message-ID: <20140115194849.GA11176@cerebellum.variantweb.net>
References: <52D60CF9.3010609@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D60CF9.3010609@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, sjenning@linux.vnet.ibm.com

On Wed, Jan 15, 2014 at 12:22:17PM +0800, Jeff Liu wrote:
> From: Jie Liu <jeff.liu@oracle.com>
> 
> Get rid of the self defined list_tail_entry() helper and
> use list_last_entry() in zbud_reclaim_page() directly.
> 
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>

Good find :)

Acked-by: Seth Jennings <sjennings@variantweb.net>

> ---
>  mm/zbud.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 9451361..8ac1e97 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -360,9 +360,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  	spin_unlock(&pool->lock);
>  }
>  
> -#define list_tail_entry(ptr, type, member) \
> -	list_entry((ptr)->prev, type, member)
> -
>  /**
>   * zbud_reclaim_page() - evicts allocations from a pool page and frees it
>   * @pool:	pool from which a page will attempt to be evicted
> @@ -411,7 +408,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  		return -EINVAL;
>  	}
>  	for (i = 0; i < retries; i++) {
> -		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> +		zhdr = list_last_entry(&pool->lru, struct zbud_header, lru);
>  		list_del(&zhdr->lru);
>  		list_del(&zhdr->buddy);
>  		/* Protect zbud page against free */
> -- 
> 1.8.3.2
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
