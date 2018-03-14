Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5596B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:50:55 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e4so2933095iof.7
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:50:55 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n77si544660ioi.244.2018.03.14.07.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 07:50:54 -0700 (PDT)
Subject: Re: [PATCH 10/16] mm: remove obsolete alloc_remap()
References: <20180314143529.1456168-1-arnd@arndb.de>
 <20180314143958.1548568-1-arnd@arndb.de>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <83b23320-e9de-a0cf-144c-1b60b9b7002a@oracle.com>
Date: Wed, 14 Mar 2018 10:50:35 -0400
MIME-Version: 1.0
In-Reply-To: <20180314143958.1548568-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Petr Tesarik <ptesarik@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org

Hi Arnd,

I like this cleanup, but arch/tile (which is afaik Orphaned but still in the gate) has:

HAVE_ARCH_ALLOC_REMAP set to yes:

arch/tile/Kconfig
 config HAVE_ARCH_ALLOC_REMAP
         def_bool y

Define in arch/tile/kernel/setup.c:
void *__init alloc_remap(int nid, unsigned long size)
{
        int pages = node_end_pfn[nid] - node_start_pfn[nid];
        void *map = pfn_to_kaddr(node_memmap_pfn[nid]);
        BUG_ON(size != pages * sizeof(struct page));
        memset(map, 0, size);
        return map; 
}

Thank you,
Pavel

On 03/14/2018 10:39 AM, Arnd Bergmann wrote:
> Tile was the only remaining architecture to implement alloc_remap(),
> and since that is being removed, there is no point in keeping this
> function.
> 
> Removing all callers simplifies the mem_map handling.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/bootmem.h |  9 ---------
>  mm/page_alloc.c         |  5 +----
>  mm/sparse.c             | 15 ---------------
>  3 files changed, 1 insertion(+), 28 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index a53063e9d7d8..7942a96b1a9d 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -364,15 +364,6 @@ static inline void __init memblock_free_late(
>  }
>  #endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
>  
> -#ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
> -extern void *alloc_remap(int nid, unsigned long size);
> -#else
> -static inline void *alloc_remap(int nid, unsigned long size)
> -{
> -	return NULL;
> -}
> -#endif /* CONFIG_HAVE_ARCH_ALLOC_REMAP */
> -
>  extern void *alloc_large_system_hash(const char *tablename,
>  				     unsigned long bucketsize,
>  				     unsigned long numentries,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cb416723538f..484e21062228 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6199,10 +6199,7 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
>  		end = pgdat_end_pfn(pgdat);
>  		end = ALIGN(end, MAX_ORDER_NR_PAGES);
>  		size =  (end - start) * sizeof(struct page);
> -		map = alloc_remap(pgdat->node_id, size);
> -		if (!map)
> -			map = memblock_virt_alloc_node_nopanic(size,
> -							       pgdat->node_id);
> +		map = memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
>  		pgdat->node_mem_map = map + offset;
>  	}
>  	pr_debug("%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 7af5e7a92528..65bb52599f90 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -427,10 +427,6 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
>  	struct page *map;
>  	unsigned long size;
>  
> -	map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
> -	if (map)
> -		return map;
> -
>  	size = PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
>  	map = memblock_virt_alloc_try_nid(size,
>  					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> @@ -446,17 +442,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  	unsigned long pnum;
>  	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
>  
> -	map = alloc_remap(nodeid, size * map_count);
> -	if (map) {
> -		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> -			if (!present_section_nr(pnum))
> -				continue;
> -			map_map[pnum] = map;
> -			map += size;
> -		}
> -		return;
> -	}
> -
>  	size = PAGE_ALIGN(size);
>  	map = memblock_virt_alloc_try_nid_raw(size * map_count,
>  					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> 
