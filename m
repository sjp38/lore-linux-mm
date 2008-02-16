Message-ID: <47B6A2D3.8020703@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 10:46:11 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 8/8] slub: Make the order configurable for each slab cache
References: <20080215230811.635628223@sgi.com> <20080215230854.890557911@sgi.com>
In-Reply-To: <20080215230854.890557911@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Christoph Lameter wrote:
> Makes /sys/kernel/slab/<slabname>/order writable. The allocation
> order can then be changed dynamically during runtime.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slub.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> +static ssize_t order_store(struct kmem_cache *s,
> +				const char *buf, size_t length)
> +{
> +	int order = simple_strtoul(buf, NULL, 10);
> +
> +	if (order > slub_max_order)
> +		return -EINVAL;
> +
> +	s->order = order;
> +	calculate_sizes(s);
> +	return length;

I think we need to respect slub_min_order here as well and most 
importantly, check whether cache size allows the given order; otherwise 
calculate_sizes can end up with -1 set to s->order which makes the cache 
useless (and probably makes SLUB oops).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
