Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 405FE440860
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:03:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so3990218wrc.8
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 02:03:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l133si1673577wmg.133.2017.07.12.02.03.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 02:03:45 -0700 (PDT)
Date: Wed, 12 Jul 2017 11:03:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmemmap, memory_hotplug: fallback to base pages for vmmap
Message-ID: <20170712090341.GE28912@dhcp22.suse.cz>
References: <20170711134204.20545-1-mhocko@kernel.org>
 <20170711142558.GE11936@dhcp22.suse.cz>
 <20170711172623.GB961@cmpxchg.org>
 <20170711212544.GA25122@dhcp22.suse.cz>
 <20170711214541.GA11141@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711214541.GA11141@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cristopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 11-07-17 17:45:41, Johannes Weiner wrote:
[...]
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index a56c3989f773..efd3f48c667c 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -52,18 +52,24 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
>  {
>  	/* If the main allocator is up use that, fallback to bootmem. */
>  	if (slab_is_available()) {
> +		unsigned int order;
> +		static int warned;
>  		struct page *page;
> +		gfp_t gfp_mask;
>  
> +		order = get_order(size);
> +		gfp_mask = GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT|__GFP_NOWARN;

why not do
		gfp_mask = GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT;
		if (warned)
			gfp_mask |= __GFP_NOWARN;

and get the actual allocation warning from the allocation context. Then
we can keep the warning vmemmap_populate_hugepages because that would be
more descriptive that what is going on.

Btw. __GFP_REPEAT has been replaced by __GFP_RETRY_MAYFAIL in mmotm
tree.

>  		if (node_state(node, N_HIGH_MEMORY))
> -			page = alloc_pages_node(
> -				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
> -				get_order(size));
> +			page = alloc_pages_node(node, gfp_mask, size);
>  		else
> -			page = alloc_pages(
> -				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
> -				get_order(size));
> +			page = alloc_pages(gfp_mask, size);
>  		if (page)
>  			return page_address(page);
> +		if (!warned) {
> +			warn_alloc(gfp_mask, NULL,
> +				   "vmemmap alloc failure: order:%u", order);
> +			warned = 1;
> +		}
>  		return NULL;
>  	} else
>  		return __earlyonly_bootmem_alloc(node, size, size,

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
