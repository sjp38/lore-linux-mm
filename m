Message-ID: <47C7BEA8.4040906@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 10:13:28 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab cache
References: <20080229044803.482012397@sgi.com> <20080229044820.044485187@sgi.com>
In-Reply-To: <20080229044820.044485187@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Makes /sys/kernel/slab/<slabname>/order writable. The allocation
> order of a slab cache can then be changed dynamically during runtime.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

> @@ -3715,11 +3720,23 @@ static ssize_t objs_per_slab_show(struct
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

I think we either want to check that the order is big enough to hold one 
object for the given cache or add a comment explaining why it can never 
happen (page allocator pass-through).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
