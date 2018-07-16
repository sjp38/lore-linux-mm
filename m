Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C782A6B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:09:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y14-v6so3746572edo.21
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:09:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18-v6si7213851edj.406.2018.07.16.09.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 09:09:58 -0700 (PDT)
Date: Mon, 16 Jul 2018 18:09:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't do zero_resv_unavail if memmap is not allocated
Message-ID: <20180716160956.GW17280@dhcp22.suse.cz>
References: <20180716151630.770-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716151630.770-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org

On Mon 16-07-18 11:16:30, Pavel Tatashin wrote:
> Moving zero_resv_unavail before memmap_init_zone(), caused a regression on
> x86-32.
> 
> The cause is that we access struct pages before they are allocated when
> CONFIG_FLAT_NODE_MEM_MAP is used.
> 
> free_area_init_nodes()
>   zero_resv_unavail()
>     mm_zero_struct_page(pfn_to_page(pfn)); <- struct page is not alloced
>   free_area_init_node()
>     if CONFIG_FLAT_NODE_MEM_MAP
>       alloc_node_mem_map()
>         memblock_virt_alloc_node_nopanic() <- struct page alloced here
> 
> On the other hand memblock_virt_alloc_node_nopanic() zeroes all the memory
> that it returns, so we do not need to do zero_resv_unavail() here.

This all is subtle as hell and almost impossible to build a sane code on
top. Your patch sounds good as a stop gap fix but we really need
something resembling an actual design rather than ad-hoc hacks piled on
top of each other.

> Fixes: e181ae0c5db9 ("mm: zero unavailable pages before memmap init")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h | 2 +-
>  mm/page_alloc.c    | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9ffe380..3982c83fdcbf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2132,7 +2132,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
>  					struct mminit_pfnnid_cache *state);
>  #endif
>  
> -#ifdef CONFIG_HAVE_MEMBLOCK
> +#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
>  void zero_resv_unavail(void);
>  #else
>  static inline void zero_resv_unavail(void) {}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d800d61ddb7..a790ef4be74e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6383,7 +6383,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  	free_area_init_core(pgdat);
>  }
>  
> -#ifdef CONFIG_HAVE_MEMBLOCK
> +#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
>  /*
>   * Only struct pages that are backed by physical memory are zeroed and
>   * initialized by going through __init_single_page(). But, there are some
> @@ -6421,7 +6421,7 @@ void __paginginit zero_resv_unavail(void)
>  	if (pgcnt)
>  		pr_info("Reserved but unavailable: %lld pages", pgcnt);
>  }
> -#endif /* CONFIG_HAVE_MEMBLOCK */
> +#endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  
> -- 
> 2.18.0
> 

-- 
Michal Hocko
SUSE Labs
