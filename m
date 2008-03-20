Subject: Re: [patch 8/9] slub: Make the order configurable for each slab
	cache
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20080317230529.701336582@sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230529.701336582@sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Thu, 20 Mar 2008 13:53:29 +0800
Message-Id: <1205992409.14496.48.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 16:05 -0700, Christoph Lameter wrote:
> plain text document attachment
> (0008-slub-Make-the-order-configurable-for-each-slab-cach.patch)
> Makes /sys/kernel/slab/<slabname>/order writable. The allocation
> order of a slab cache can then be changed dynamically during runtime.
> This can be used to override the objects per slabs value establisheed
> with the slub_min_objects setting that was manually specified or
> calculated on bootup.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  mm/slub.c |   30 +++++++++++++++++++++++-------
>  1 file changed, 23 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-03-17 15:38:16.337702541 -0700
> +++ linux-2.6/mm/slub.c	2008-03-17 15:49:47.791302447 -0700
> @@ -2146,7 +2146,7 @@ static int init_kmem_cache_nodes(struct 
>   * calculate_sizes() determines the order and the distribution of data within
>   * a slab object.
>   */
> -static int calculate_sizes(struct kmem_cache *s)
> +static int calculate_sizes(struct kmem_cache *s, int forced_order)
Is there any race between calculate_sizes and allocate_slab?
calculate_sizes sets s->order and s->objects, while allocate_slab uses them.

For example, change order from 5 to 2.

Step\thread	|	Thread 1		|	Thread 2
--------------------------------------------------------------------------------------------
1		|	allocate_slab           |
		|	fetch the old s->order  |
--------------------------------------------------------------------------------------------
2		|				|	calculate_sizes
		|				|	changes s->order=2
--------------------------------------------------------------------------------------------
3		|				|	calculate_sizes
		|				|	changes s->objects=8
--------------------------------------------------------------------------------------------
4		|	allocate_slab           |
		|	fetchs s->objects to	|
		|	page->objects;          |

Just before calculate_sizes changes s->order to a smaller value,
allocate_slab might fetch the old s->order to call alloc_pages successfully. Then, before
allocate_slab fetch s->objects, calculate_sizes changes it to a smaller value

It could be resolved by fetch s->order in allocate_slab firstly and calculate
page->objects lately instead of fetching s->objects.

>  {
>  	unsigned long flags = s->flags;
>  	unsigned long size = s->objsize;
> @@ -2235,7 +2235,11 @@ static int calculate_sizes(struct kmem_c
>  	size = ALIGN(size, align);
>  	s->size = size;
>  
> -	s->order = calculate_order(size);
> +	if (forced_order >= 0)
> +		s->order = forced_order;
> +	else
> +		s->order = calculate_order(size);
> +
>  	if (s->order < 0)
>  		return 0;
>  
> @@ -2271,7 +2275,7 @@ static int kmem_cache_open(struct kmem_c
>  	s->align = align;
>  	s->flags = kmem_cache_flags(size, flags, name, ctor);
>  
> -	if (!calculate_sizes(s))
> +	if (!calculate_sizes(s, -1))
>  		goto error;
>  
>  	s->refcount = 1;
> @@ -3727,11 +3731,23 @@ static ssize_t objs_per_slab_show(struct
>  }
>  SLAB_ATTR_RO(objs_per_slab);
>  
> +static ssize_t order_store(struct kmem_cache *s,
> +				const char *buf, size_t length)
> +{
> +	int order = simple_strtoul(buf, NULL, 10);
> +
> +	if (order > slub_max_order || order < slub_min_order)
> +		return -EINVAL;
> +
> +	calculate_sizes(s, order);
> +	return length;
> +}
> +
>  static ssize_t order_show(struct kmem_cache *s, char *buf)
>  {
>  	return sprintf(buf, "%d\n", s->order);
>  }
> -SLAB_ATTR_RO(order);
> +SLAB_ATTR(order);
>  
>  static ssize_t ctor_show(struct kmem_cache *s, char *buf)
>  {
> @@ -3865,7 +3881,7 @@ static ssize_t red_zone_store(struct kme
>  	s->flags &= ~SLAB_RED_ZONE;
>  	if (buf[0] == '1')
>  		s->flags |= SLAB_RED_ZONE;
> -	calculate_sizes(s);
> +	calculate_sizes(s, -1);
>  	return length;
>  }
>  SLAB_ATTR(red_zone);
> @@ -3884,7 +3900,7 @@ static ssize_t poison_store(struct kmem_
>  	s->flags &= ~SLAB_POISON;
>  	if (buf[0] == '1')
>  		s->flags |= SLAB_POISON;
> -	calculate_sizes(s);
> +	calculate_sizes(s, -1);
>  	return length;
>  }
>  SLAB_ATTR(poison);
> @@ -3903,7 +3919,7 @@ static ssize_t store_user_store(struct k
>  	s->flags &= ~SLAB_STORE_USER;
>  	if (buf[0] == '1')
>  		s->flags |= SLAB_STORE_USER;
> -	calculate_sizes(s);
> +	calculate_sizes(s, -1);
>  	return length;
>  }
>  SLAB_ATTR(store_user);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
