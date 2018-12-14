Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAC9F8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:13:25 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so4982124pfi.19
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:13:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 187si4590392pfv.238.2018.12.14.10.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 10:13:24 -0800 (PST)
Date: Fri, 14 Dec 2018 10:13:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 2/4] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Message-ID: <20181214181322.GC10600@bombadil.infradead.org>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214180720.32040-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

On Fri, Dec 14, 2018 at 10:07:18AM -0800, Roman Gushchin wrote:
> alloc_vmap_area() is allocating memory for the vmap_area, and
> performing the actual lookup of the vm area and vmap_area
> initialization.
> 
> This prevents us from using a pre-allocated memory for the map_area
> structure, which can be used in some cases to minimize the number
> of required memory allocations.
> 
> Let's keep the memory allocation part in alloc_vmap_area() and
> separate everything else into init_vmap_area().

Oh good, I was considering doing something like this eventually.

> +++ b/mm/vmalloc.c
> @@ -395,16 +395,11 @@ static void purge_vmap_area_lazy(void);
>  
>  static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
>  
> -/*
> - * Allocate a region of KVA of the specified size and alignment, within the
> - * vstart and vend.
> - */
> -static struct vmap_area *alloc_vmap_area(unsigned long size,
> -				unsigned long align,
> -				unsigned long vstart, unsigned long vend,
> -				int node, gfp_t gfp_mask)
> +static int init_vmap_area(struct vmap_area *va, unsigned long size,
> +			  unsigned long align, unsigned long vstart,
> +			  unsigned long vend, int node, gfp_t gfp_mask)
>  {
> -	struct vmap_area *va;
> +

Why the blank line?

>  	struct rb_node *n;
>  	unsigned long addr;
>  	int purged = 0;
> @@ -416,11 +411,6 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  
>  	might_sleep();
>  
> -	va = kmalloc_node(sizeof(struct vmap_area),
> -			gfp_mask & GFP_RECLAIM_MASK, node);
> -	if (unlikely(!va))
> -		return ERR_PTR(-ENOMEM);
> -
>  	/*
>  	 * Only scan the relevant parts containing pointers to other objects
>  	 * to avoid false negatives.
> @@ -512,7 +502,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	BUG_ON(va->va_start < vstart);
>  	BUG_ON(va->va_end > vend);
>  
> -	return va;
> +	return 0;
>  
>  overflow:
>  	spin_unlock(&vmap_area_lock);
> @@ -534,10 +524,38 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
>  		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
>  			size);
> -	kfree(va);
> -	return ERR_PTR(-EBUSY);
> +
> +	return -EBUSY;
> +}
> +
> +/*
> + * Allocate a region of KVA of the specified size and alignment, within the
> + * vstart and vend.
> + */
> +static struct vmap_area *alloc_vmap_area(unsigned long size,
> +					 unsigned long align,
> +					 unsigned long vstart,
> +					 unsigned long vend,
> +					 int node, gfp_t gfp_mask)
> +{
> +	struct vmap_area *va;
> +	int ret;
> +
> +	va = kmalloc_node(sizeof(struct vmap_area),
> +			gfp_mask & GFP_RECLAIM_MASK, node);
> +	if (unlikely(!va))
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = init_vmap_area(va, size, align, vstart, vend, node, gfp_mask);
> +	if (ret) {
> +		kfree(va);
> +		return ERR_PTR(ret);
> +	}
> +
> +	return va;
>  }
>  
> +

Another spurious blank line?

With these two fixed,
Reviewed-by: Matthew Wilcox <willy@infradead.org>
