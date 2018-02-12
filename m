Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0CEB6B0068
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 11:16:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r15so8957472wrc.11
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:16:53 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id 65si3655812wrf.159.2018.02.12.08.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 08:16:51 -0800 (PST)
Date: Mon, 12 Feb 2018 17:16:40 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180212161640.GA30811@vmlxhi-102.adit-jv.com>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
 <20180124143545.31963-2-erosca@de.adit-jv.com>
 <20180129184746.GK21609@dhcp22.suse.cz>
 <20180203122422.GA11832@vmlxhi-102.adit-jv.com>
 <20180212150314.GG3443@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180212150314.GG3443@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

On Mon, Feb 12, 2018 at 04:03:14PM +0100, Michal Hocko wrote:
> On Sat 03-02-18 13:24:22, Eugeniu Rosca wrote:
> [...]
> > That said, I really hope this won't be the last comment in the thread
> > and appropriate suggestions will come on how to go forward.
> 
> Just to make sure we are on the same page. I was suggesting the
> following. The patch is slightly larger just because I move
> memblock_next_valid_pfn around which I find better than sprinkling
> ifdefs around. Please note I haven't tried to compile test this.

I got your point. So, I was wrong. You are not preferring v2 of this
patch, but suggest a new variant of it. For the record, I've also
build/boot-tested your variant with no issues. The reason I did not
make it my favorite is to allow reviewers to concentrate on what's
actually the essence of this change, i.e. relaxing the dependency of
memblock_next_valid_pfn() from HAVE_MEMBLOCK_NODE_MAP (which requires/
depends on NUMA) to HAVE_MEMBLOCK (which doesn't).

As I've said in some previous reply, I am open minded about which
variant is selected by MM people, since, from my point of view, all of
them do the same thing with variable degree of code readability.

For me it's not a problem to submit a new patch. I guess that a
prerequisite for this is to reach some agreement on what people think is
the best option, which I feel didn't occur yet.

Best regards,
Eugeniu.

> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 8be5077efb5f..0d3cb4c70858 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -187,7 +187,6 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
>  			    unsigned long  *end_pfn);
>  void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>  			  unsigned long *out_end_pfn, int *out_nid);
> -unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
>  
>  /**
>   * for_each_mem_pfn_range - early memory pfn range iterator
> @@ -204,6 +203,8 @@ unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
>  	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  
> +unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
> +
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 5a9ca2a1751b..8a627d4fa5b2 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1101,34 +1101,6 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
>  		*out_nid = r->nid;
>  }
>  
> -unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
> -						      unsigned long max_pfn)
> -{
> -	struct memblock_type *type = &memblock.memory;
> -	unsigned int right = type->cnt;
> -	unsigned int mid, left = 0;
> -	phys_addr_t addr = PFN_PHYS(pfn + 1);
> -
> -	do {
> -		mid = (right + left) / 2;
> -
> -		if (addr < type->regions[mid].base)
> -			right = mid;
> -		else if (addr >= (type->regions[mid].base +
> -				  type->regions[mid].size))
> -			left = mid + 1;
> -		else {
> -			/* addr is within the region, so pfn + 1 is valid */
> -			return min(pfn + 1, max_pfn);
> -		}
> -	} while (left < right);
> -
> -	if (right == type->cnt)
> -		return max_pfn;
> -	else
> -		return min(PHYS_PFN(type->regions[right].base), max_pfn);
> -}
> -
>  /**
>   * memblock_set_node - set node ID on memblock regions
>   * @base: base of area to set node ID for
> @@ -1160,6 +1132,34 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
> +						      unsigned long max_pfn)
> +{
> +	struct memblock_type *type = &memblock.memory;
> +	unsigned int right = type->cnt;
> +	unsigned int mid, left = 0;
> +	phys_addr_t addr = PFN_PHYS(pfn + 1);
> +
> +	do {
> +		mid = (right + left) / 2;
> +
> +		if (addr < type->regions[mid].base)
> +			right = mid;
> +		else if (addr >= (type->regions[mid].base +
> +				  type->regions[mid].size))
> +			left = mid + 1;
> +		else {
> +			/* addr is within the region, so pfn + 1 is valid */
> +			return min(pfn + 1, max_pfn);
> +		}
> +	} while (left < right);
> +
> +	if (right == type->cnt)
> +		return max_pfn;
> +	else
> +		return min(PHYS_PFN(type->regions[right].base), max_pfn);
> +}
> +
>  static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t start,
>  					phys_addr_t end, int nid, ulong flags)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e2b42f603b1a..b7968fd5736f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5352,14 +5352,13 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			goto not_early;
>  
>  		if (!early_pfn_valid(pfn)) {
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  			/*
>  			 * Skip to the pfn preceding the next valid one (or
>  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
>  			 * on our next iteration of the loop.
>  			 */
> -			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> -#endif
> +			if IS_ENABLED(HAVE_MEMBLOCK)
> +				pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
>  			continue;
>  		}
>  		if (!early_pfn_in_nid(pfn, nid))
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
