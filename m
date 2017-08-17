Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B71DC6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 03:40:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z91so5580653wrc.4
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 00:40:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si2259143wrf.252.2017.08.17.00.40.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Aug 2017 00:40:07 -0700 (PDT)
Date: Thu, 17 Aug 2017 09:40:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmalloc: Don't unconditonally use __GFP_HIGHMEM
Message-ID: <20170817074006.GC17781@dhcp22.suse.cz>
References: <20170816220705.31374-1-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816220705.31374-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-08-17 15:07:05, Laura Abbott wrote:
> Commit 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitly")
> added use of __GFP_HIGHMEM for allocations. vmalloc_32 may use
> GFP_DMA/GFP_DMA32 which does not play nice with __GFP_HIGHMEM
> and will drigger a BUG in gfp_zone. Only add __GFP_HIGHMEM if

s@drigger@trigger@

> we aren't using GFP_DMA/GFP_DMA32.
>
> Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1482249
> Fixes: 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitly")
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Sorry about that. My fault! I have completely missed that VM_BUG_ON.
I was double checking that GFP_DMA|__GFP_HIGHMEM works as inteded
which is the case because DMA has always a preference. I have reached
the same conclusion for GFP_DMA32 but now that I am looking at the
GFP_ZONE_TABLE again I was wrong because we would end up in ZONE_DMA
AFAICS because bit 1 wouldn't be set.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/vmalloc.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 8698c1c86c4d..a47e3894c775 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1671,7 +1671,10 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
>  	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> -	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
> +	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
> +	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
> +					0 :
> +					__GFP_HIGHMEM;
>  
>  	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> @@ -1679,7 +1682,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	area->nr_pages = nr_pages;
>  	/* Please note that the recursion is strictly bounded. */
>  	if (array_size > PAGE_SIZE) {
> -		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
> +		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
>  				PAGE_KERNEL, node, area->caller);
>  	} else {
>  		pages = kmalloc_node(array_size, nested_gfp, node);
> @@ -1700,9 +1703,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  		}
>  
>  		if (node == NUMA_NO_NODE)
> -			page = alloc_page(alloc_mask);
> +			page = alloc_page(alloc_mask|highmem_mask);
>  		else
> -			page = alloc_pages_node(node, alloc_mask, 0);
> +			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
>  
>  		if (unlikely(!page)) {
>  			/* Successfully allocated i pages, free them in __vunmap() */
> @@ -1710,7 +1713,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  			goto fail;
>  		}
>  		area->pages[i] = page;
> -		if (gfpflags_allow_blocking(gfp_mask))
> +		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
>  			cond_resched();
>  	}
>  
> -- 
> 2.13.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
