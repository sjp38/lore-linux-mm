Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA206B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:49:11 -0400 (EDT)
Date: Wed, 2 Jun 2010 14:49:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: vmap area cache
Message-Id: <20100602144905.aa613dec.akpm@linux-foundation.org>
In-Reply-To: <20100531080757.GE9453@laptop>
References: <20100531080757.GE9453@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010 18:07:57 +1000
Nick Piggin <npiggin@suse.de> wrote:

> Hi Andrew,
> 
> Could you put this in your tree? It could do with a bit more testing. I
> will update you with updates or results from Steven.
> 
> Thanks,
> Nick
> --
> 
> Provide a free area cache for the vmalloc virtual address allocator, based
> on the approach taken in the user virtual memory allocator.
> 
> This reduces the number of rbtree operations and linear traversals over
> the vmap extents to find a free area. The lazy vmap flushing makes this problem
> worse because because freed but not yet flushed vmaps tend to build up in
> the address space between flushes.
> 
> Steven noticed a performance problem with GFS2. Results are as follows...
> 
> 
> 

changelog got truncated - the "results" and the signoff are missing.

> --- linux-2.6.orig/mm/vmalloc.c
> +++ linux-2.6/mm/vmalloc.c
> @@ -262,8 +262,14 @@ struct vmap_area {
>  };
>  
>  static DEFINE_SPINLOCK(vmap_area_lock);
> -static struct rb_root vmap_area_root = RB_ROOT;
>  static LIST_HEAD(vmap_area_list);
> +static struct rb_root vmap_area_root = RB_ROOT;
> +
> +static struct rb_node *free_vmap_cache;
> +static unsigned long cached_hole_size;
> +static unsigned long cached_start;
> +static unsigned long cached_align;
> +
>  static unsigned long vmap_area_pcpu_hole;
>  
>  static struct vmap_area *__find_vmap_area(unsigned long addr)
> @@ -332,9 +338,11 @@ static struct vmap_area *alloc_vmap_area
>  	struct rb_node *n;
>  	unsigned long addr;
>  	int purged = 0;
> +	struct vmap_area *first;
>  
>  	BUG_ON(!size);
>  	BUG_ON(size & ~PAGE_MASK);
> +	BUG_ON(!is_power_of_2(align));

Worried.  How do we know this won't trigger?

>  	va = kmalloc_node(sizeof(struct vmap_area),
>  			gfp_mask & GFP_RECLAIM_MASK, node);
> @@ -342,17 +350,39 @@ static struct vmap_area *alloc_vmap_area
>  		return ERR_PTR(-ENOMEM);
>  
>  retry:
> -	addr = ALIGN(vstart, align);
> -
>  	spin_lock(&vmap_area_lock);
> -	if (addr + size - 1 < addr)
> -		goto overflow;
> +	/* invalidate cache if we have more permissive parameters */
> +	if (!free_vmap_cache ||
> +			size <= cached_hole_size ||
> +			vstart < cached_start ||
> +			align < cached_align) {
> +nocache:
> +		cached_hole_size = 0;
> +		free_vmap_cache = NULL;
> +	}
> +	/* record if we encounter less permissive parameters */
> +	cached_start = vstart;
> +	cached_align = align;
> +
> +	/* find starting point for our search */
> +	if (free_vmap_cache) {
> +		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> +		addr = ALIGN(first->va_end + PAGE_SIZE, align);
> +		if (addr < vstart)
> +			goto nocache;
> +		if (addr + size - 1 < addr)
> +			goto overflow;

Some comments attached to the `if' tests would make it easier to
understand what's going on.

> +
> +	} else {
> +		addr = ALIGN(vstart, align);
> +		if (addr + size - 1 < addr)
> +			goto overflow;
> -	/* XXX: could have a last_hole cache */
> -	n = vmap_area_root.rb_node;
> -	if (n) {
> -		struct vmap_area *first = NULL;
> +		n = vmap_area_root.rb_node;
> +		if (!n)
> +			goto found;
>  
> +		first = NULL;
>  		do {
>  			struct vmap_area *tmp;
>  			tmp = rb_entry(n, struct vmap_area, rb_node);

this?

--- a/mm/vmalloc.c~mm-vmap-area-cache-fix
+++ a/mm/vmalloc.c
@@ -265,6 +265,7 @@ static DEFINE_SPINLOCK(vmap_area_lock);
 static LIST_HEAD(vmap_area_list);
 static struct rb_root vmap_area_root = RB_ROOT;
 
+/* The vmap cache globals are protected by vmap_area_lock */
 static struct rb_node *free_vmap_cache;
 static unsigned long cached_hole_size;
 static unsigned long cached_start;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
