Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDE2B6B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:42:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g28-v6so13367693edc.18
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 01:42:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q25-v6si9534820edi.5.2018.10.16.01.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 01:42:35 -0700 (PDT)
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a85917a2-199f-a2c1-da28-13f0420f0908@suse.cz>
Date: Tue, 16 Oct 2018 10:42:33 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/12/18 11:24 PM, David Rientjes wrote:
> The slab allocator has a heuristic that checks whether the internal
> fragmentation is satisfactory and, if not, increases cachep->gfporder to
> try to improve this.
> 
> If the amount of waste is the same at higher cachep->gfporder values,
> there is no significant benefit to allocating higher order memory.  There
> will be fewer calls to the page allocator, but each call will require
> zone->lock and finding the page of best fit from the per-zone free areas.
> 
> Instead, it is better to allocate order-0 memory if possible so that pages
> can be returned from the per-cpu pagesets (pcp).
> 
> There are two reasons to prefer this over allocating high order memory:
> 
>  - allocating from the pcp lists does not require a per-zone lock, and
> 
>  - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
>    that increases slab fragmentation across a zone.
> 
> We are particularly interested in the second point to eliminate cases
> where all other pages on a pageblock are movable (or free) and fallback to
> pageblocks of other migratetypes from the per-zone free areas causes
> high-order slab memory to be allocated from them rather than from free
> MIGRATE_UNMOVABLE pages on the pcp.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/slab.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1748,6 +1748,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  	for (gfporder = 0; gfporder <= KMALLOC_MAX_ORDER; gfporder++) {
>  		unsigned int num;
>  		size_t remainder;
> +		int order;
>  
>  		num = cache_estimate(gfporder, size, flags, &remainder);
>  		if (!num)
> @@ -1803,6 +1804,20 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  		 */
>  		if (left_over * 8 <= (PAGE_SIZE << gfporder))
>  			break;
> +
> +		/*
> +		 * If a higher gfporder would not reduce internal fragmentation,
> +		 * no need to continue.  The preference is to keep gfporder as
> +		 * small as possible so slab allocations can be served from
> +		 * MIGRATE_UNMOVABLE pcp lists to avoid stranding.
> +		 */
> +		for (order = gfporder + 1; order <= slab_max_order; order++) {
> +			cache_estimate(order, size, flags, &remainder);
> +			if (remainder < left_over)

I think this can be suboptimal when left_over is e.g. 500 for the lower
order and remainder is 800 for the higher order, so wasted memory per
page is lower, although the absolute value isn't. Can that happen?
Probably not for order-0 vs order-1 case, but for higher orders? In that
case left_order should be shifted left by (gfporder - order) in the
comparison?

> +				break;
> +		}
> +		if (order > slab_max_order)
> +			break;
>  	}
>  	return left_over;
>  }
> 
