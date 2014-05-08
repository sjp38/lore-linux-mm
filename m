Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2434B6B00B4
	for <linux-mm@kvack.org>; Wed,  7 May 2014 21:19:16 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id z10so1730707pdj.14
        for <linux-mm@kvack.org>; Wed, 07 May 2014 18:19:15 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id fm5si2145686pbc.120.2014.05.07.18.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 18:19:15 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so1739608pdj.8
        for <linux-mm@kvack.org>; Wed, 07 May 2014 18:19:15 -0700 (PDT)
Date: Wed, 7 May 2014 18:19:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 05/10] slab: factor out initialization of arracy
 cache
In-Reply-To: <1399442780-28748-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1405071818060.5305@chino.kir.corp.google.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com> <1399442780-28748-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 7 May 2014, Joonsoo Kim wrote:

> Factor out initialization of array cache to use it in following patch.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

s/arracy/array/ in patch title.

> diff --git a/mm/slab.c b/mm/slab.c
> index 7647728..755fb57 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -741,13 +741,8 @@ static void start_cpu_timer(int cpu)
>  	}
>  }
>  
> -static struct array_cache *alloc_arraycache(int node, int entries,
> -					    int batchcount, gfp_t gfp)
> +static void init_arraycache(struct array_cache *ac, int limit, int batch)
>  {
> -	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
> -	struct array_cache *nc = NULL;
> -
> -	nc = kmalloc_node(memsize, gfp, node);
>  	/*
>  	 * The array_cache structures contain pointers to free object.
>  	 * However, when such objects are allocated or transferred to another
> @@ -755,15 +750,25 @@ static struct array_cache *alloc_arraycache(int node, int entries,
>  	 * valid references during a kmemleak scan. Therefore, kmemleak must
>  	 * not scan such objects.
>  	 */
> -	kmemleak_no_scan(nc);
> -	if (nc) {
> -		nc->avail = 0;
> -		nc->limit = entries;
> -		nc->batchcount = batchcount;
> -		nc->touched = 0;
> -		spin_lock_init(&nc->lock);
> +	kmemleak_no_scan(ac);
> +	if (ac) {
> +		ac->avail = 0;
> +		ac->limit = limit;
> +		ac->batchcount = batch;
> +		ac->touched = 0;
> +		spin_lock_init(&ac->lock);
>  	}
> -	return nc;
> +}
> +
> +static struct array_cache *alloc_arraycache(int node, int entries,
> +					    int batchcount, gfp_t gfp)
> +{
> +	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);

const?

> +	struct array_cache *ac = NULL;
> +
> +	ac = kmalloc_node(memsize, gfp, node);

I thought nc meant node cache, but I agree that ac is clearer.

> +	init_arraycache(ac, entries, batchcount);
> +	return ac;
>  }
>  
>  static inline bool is_slab_pfmemalloc(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
