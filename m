Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3B086B53E6
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:11:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so2223493pfr.6
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:11:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z186si2552280pgd.90.2018.11.29.10.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 10:11:26 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wATI4GpJ108190
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:11:25 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p2k9udhgj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:11:25 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 29 Nov 2018 18:11:22 -0000
Date: Thu, 29 Nov 2018 20:11:15 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2] mm/memblock: skip kmemleak for kasan_init()
References: <1543442925-17794-1-git-send-email-cai@gmx.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543442925-17794-1-git-send-email-cai@gmx.us>
Message-Id: <20181129181114.GB4295@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@gmx.us>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, mhocko@suse.com, rppt@linux.ibm.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 28, 2018 at 05:08:45PM -0500, Qian Cai wrote:
> Kmemleak does not play well with KASAN (tested on both HPE Apollo 70 and
> Huawei TaiShan 2280 aarch64 servers).
> 
> After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early
> log buffer went from something like 280 to 260000 which caused kmemleak
> disabled and crash dump memory reservation failed. The multitude of
> kmemleak_alloc() calls is from nested loops while KASAN is setting up
> full memory mappings, so let early kmemleak allocations skip those
> memblock_alloc_internal() calls came from kasan_init() given that those
> early KASAN memory mappings should not reference to other memory.
> Hence, no kmemleak false positives.
> 
> kasan_init
>   kasan_map_populate [1]
>     kasan_pgd_populate [2]
>       kasan_pud_populate [3]
>         kasan_pmd_populate [4]
>           kasan_pte_populate [5]
>             kasan_alloc_zeroed_page
>               memblock_alloc_try_nid
>                 memblock_alloc_internal
>                   kmemleak_alloc
> 
> [1] for_each_memblock(memory, reg)
> [2] while (pgdp++, addr = next, addr != end)
> [3] while (pudp++, addr = next, addr != end && pud_none(READ_ONCE(*pudp)))
> [4] while (pmdp++, addr = next, addr != end && pmd_none(READ_ONCE(*pmdp)))
> [5] while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)))
> 
> Signed-off-by: Qian Cai <cai@gmx.us>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com> # memblock parts

> ---
> 
> Changes since v1:
> * only skip memblock_alloc_internal() calls came from kasan_int().
> 
>  arch/arm64/mm/kasan_init.c |  2 +-
>  include/linux/memblock.h   |  1 +
>  mm/memblock.c              | 19 +++++++++++--------
>  3 files changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 63527e5..fcb2ca3 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -39,7 +39,7 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int node)
>  {
>  	void *p = memblock_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
>  					      __pa(MAX_DMA_ADDRESS),
> -					      MEMBLOCK_ALLOC_ACCESSIBLE, node);
> +					      MEMBLOCK_ALLOC_KASAN, node);
>  	return __pa(p);
>  }
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index aee299a..3ef3086 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -320,6 +320,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
>  /* Flags for memblock allocation APIs */
>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
> +#define MEMBLOCK_ALLOC_KASAN		1
> 
>  /* We are using top down, so it is safe to use 0 here */
>  #define MEMBLOCK_LOW_LIMIT 0
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae..abb9f7f 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -262,7 +262,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>  	phys_addr_t kernel_end, ret;
> 
>  	/* pump up @end */
> -	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> +	if (end == MEMBLOCK_ALLOC_ACCESSIBLE ||
> +	    end == MEMBLOCK_ALLOC_KASAN)
>  		end = memblock.current_limit;
> 
>  	/* avoid allocating the first page */
> @@ -1412,13 +1413,15 @@ static void * __init memblock_alloc_internal(
>  done:
>  	ptr = phys_to_virt(alloc);
> 
> -	/*
> -	 * The min_count is set to 0 so that bootmem allocated blocks
> -	 * are never reported as leaks. This is because many of these blocks
> -	 * are only referred via the physical address which is not
> -	 * looked up by kmemleak.
> -	 */
> -	kmemleak_alloc(ptr, size, 0, 0);
> +	/* Skip kmemleak for kasan_init() due to high volume. */
> +	if (max_addr != MEMBLOCK_ALLOC_KASAN)
> +		/*
> +		 * The min_count is set to 0 so that bootmem allocated
> +		 * blocks are never reported as leaks. This is because many
> +		 * of these blocks are only referred via the physical
> +		 * address which is not looked up by kmemleak.
> +		 */
> +		kmemleak_alloc(ptr, size, 0, 0);
> 
>  	return ptr;
>  }
> -- 
> 1.8.3.1
> 

-- 
Sincerely yours,
Mike.
