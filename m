Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 572526B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:25:08 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so11620226pgi.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:25:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor7105314pgk.42.2018.11.14.14.25.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 14:25:07 -0800 (PST)
Date: Wed, 14 Nov 2018 14:25:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Suppress the sparse warning ./include/linux/slab.h:332:43:
 warning: dubious: x & !y
In-Reply-To: <20181109022801.29979-1-dagostinelli@gmail.com>
Message-ID: <alpine.DEB.2.21.1811141424130.212061@chino.kir.corp.google.com>
References: <20181109022801.29979-1-dagostinelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darryl T. Agostinelli" <dagostinelli@gmail.com>
Cc: linux-mm@kvack.org, cl@linux.com, bvanassche@acm.org, akpm@linux-foundation.org, penberg@kernel.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org

On Thu, 8 Nov 2018, Darryl T. Agostinelli wrote:

> Signed-off-by: Darryl T. Agostinelli <dagostinelli@gmail.com>
> ---
>  include/linux/slab.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 918f374e7156..883b7f56bf35 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -317,6 +317,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  	int is_dma = 0;
>  	int type_dma = 0;
>  	int is_reclaimable;
> +	int y;
>  
>  #ifdef CONFIG_ZONE_DMA
>  	is_dma = !!(flags & __GFP_DMA);
> @@ -329,7 +330,10 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>  	 */
> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +
> +	y = (is_reclaimable & (is_dma == 0 ? 1 : 0));
> +
> +	return type_dma + y * KMALLOC_RECLAIM;
>  }
>  
>  /*

I agree with you that the function as written is less than pretty :)  How 
does the assembly change as a result of this code change, however?  This 
will be in the kmalloc() path so impacting the assembly to fix a sparse 
warning may not be warranted.
