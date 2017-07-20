Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 820596B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 04:04:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r123so1984268wmb.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:04:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si1874259wrf.473.2017.07.20.01.04.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 01:04:46 -0700 (PDT)
Subject: Re: [PATCH 9/9] mm, sparse, page_ext: drop ugly N_HIGH_MEMORY
 branches for allocations
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-10-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <759788e4-514c-96fb-205c-5d29ca189850@suse.cz>
Date: Thu, 20 Jul 2017 10:04:43 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-10-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, joonsoo kim <js1304@gmail.com>, Shaohua Li <shaohua.li@intel.com>

On 07/14/2017 10:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> f52407ce2dea ("memory hotplug: alloc page from other node in memory
> online") has introduced N_HIGH_MEMORY checks to only use NUMA aware
> allocations when there is some memory present because the respective
> node might not have any memory yet at the time and so it could fail
> or even OOM. Things have changed since then though. Zonelists are
> now always initialized before we do any allocations even for hotplug
> (see 959ecc48fc75 ("mm/memory_hotplug.c: fix building of node hotplug
> zonelist")). Therefore these checks are not really needed. In fact
> caller of the allocator should never care about whether the node is
> populated because that might change at any time.
> 
> Cc: Shaohua Li <shaohua.li@intel.com>
> Cc: joonsoo kim <js1304@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_ext.c       |  5 +----
>  mm/sparse-vmemmap.c | 11 +++--------
>  mm/sparse.c         | 10 +++-------
>  3 files changed, 7 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 88ccc044b09a..714ce79256c5 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -222,10 +222,7 @@ static void *__meminit alloc_page_ext(size_t size, int nid)
>  		return addr;
>  	}
>  
> -	if (node_state(nid, N_HIGH_MEMORY))
> -		addr = vzalloc_node(size, nid);
> -	else
> -		addr = vzalloc(size);
> +	addr = vzalloc_node(size, nid);
>  
>  	return addr;
>  }
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index c50b1a14d55e..d1a39b8051e0 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -54,14 +54,9 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
>  	if (slab_is_available()) {
>  		struct page *page;
>  
> -		if (node_state(node, N_HIGH_MEMORY))
> -			page = alloc_pages_node(
> -				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
> -				get_order(size));
> -		else
> -			page = alloc_pages(
> -				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
> -				get_order(size));
> +		page = alloc_pages_node(node,
> +			GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
> +			get_order(size));
>  		if (page)
>  			return page_address(page);
>  		return NULL;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 7b4be3fd5cac..a9783acf2bb9 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -65,14 +65,10 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
>  	unsigned long array_size = SECTIONS_PER_ROOT *
>  				   sizeof(struct mem_section);
>  
> -	if (slab_is_available()) {
> -		if (node_state(nid, N_HIGH_MEMORY))
> -			section = kzalloc_node(array_size, GFP_KERNEL, nid);
> -		else
> -			section = kzalloc(array_size, GFP_KERNEL);
> -	} else {
> +	if (slab_is_available())
> +		section = kzalloc_node(array_size, GFP_KERNEL, nid);
> +	else
>  		section = memblock_virt_alloc_node(array_size, nid);
> -	}
>  
>  	return section;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
