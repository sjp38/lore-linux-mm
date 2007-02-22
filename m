Date: Thu, 22 Feb 2007 00:58:24 -0800 (PST)
Message-Id: <20070222.005824.34601725.davem@davemloft.net>
Subject: Re: SLUB: The unqueued Slab allocator
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 21 Feb 2007 23:00:30 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_ZONE_DMA
> +static struct kmem_cache *kmalloc_caches_dma[KMALLOC_NR_CACHES];
> +#endif

Therefore.

> +static struct kmem_cache *get_slab(size_t size, gfp_t flags)
> +{
 ...
> +	s = kmalloc_caches_dma[index];
> +	if (s)
> +		return s;
> +
> +	/* Dynamically create dma cache */
> +	x = kmalloc(sizeof(struct kmem_cache), flags & ~(__GFP_DMA));
> +
> +	if (!x)
> +		panic("Unable to allocate memory for dma cache\n");
> +
> +#ifdef KMALLOC_EXTRA
> +	if (index <= KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW)
> +#endif
> +		realsize = 1 << index;
> +#ifdef KMALLOC_EXTRA
> +	else if (index == KMALLOC_EXTRAS)
> +		realsize = 96;
> +	else
> +		realsize = 192;
> +#endif
> +
> +	s = create_kmalloc_cache(x, "kmalloc_dma", realsize);
> +	kmalloc_caches_dma[index] = s;
> +	return s;
> +}

All of that logic needs to be protected by CONFIG_ZONE_DMA too.

I noticed this due to a build failure on sparc64 with this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
