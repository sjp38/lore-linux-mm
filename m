Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F197A6B0738
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:26:58 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so7025574qkd.0
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:26:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor5042607qkd.100.2018.11.09.15.26.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 15:26:57 -0800 (PST)
Date: Fri, 9 Nov 2018 18:26:54 -0500
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 3/7] mm: Implement new zone specific memblock
 iterator
Message-ID: <20181109232654.bi37bdkrqbogbdcx@xakep.localdomain>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <154145278071.30046.9022571960145979137.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154145278071.30046.9022571960145979137.stgit@ahduyck-desk1.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

> +/**
> + * for_each_free_mem_range_in_zone - iterate through zone specific free
> + * memblock areas
> + * @i: u64 used as loop variable
> + * @zone: zone in which all of the memory blocks reside
> + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + *
> + * Walks over free (memory && !reserved) areas of memblock in a specific
> + * zone. Available as soon as memblock is initialized.
> + */
> +#define for_each_free_mem_pfn_range_in_zone(i, zone, p_start, p_end)	\
> +	for (i = 0,							\
> +	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
> +	     i != (u64)ULLONG_MAX;					\
> +	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */

Use U64_MAX instead of ULLONG_MAX, and avoid u64 cast. I know other
places in this file use UULONG_MAX with cast, but I think U64_MAX is
better.

> +
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7df468c8ebc8..f1d1fbfd1ae7 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1239,6 +1239,69 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  	return 0;
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +/**
> + * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
> + *
> + * @idx: pointer to u64 loop variable
> + * @zone: zone in which all of the memory blocks reside
> + * @out_start: ptr to ulong for start pfn of the range, can be %NULL
> + * @out_end: ptr to ulong for end pfn of the range, can be %NULL
> + *
> + * This function is meant to be a zone/pfn specific wrapper for the
> + * for_each_mem_range type iterators. Specifically they are used in the
> + * deferred memory init routines and as such we were duplicating much of
> + * this logic throughout the code. So instead of having it in multiple
> + * locations it seemed like it would make more sense to centralize this to
> + * one new iterator that does everything they need.
> + */
> +void __init_memblock
> +__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
> +			     unsigned long *out_spfn, unsigned long *out_epfn)
> +{
> +	int zone_nid = zone_to_nid(zone);
> +	phys_addr_t spa, epa;
> +	int nid;
> +
> +	__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
> +			 &memblock.memory, &memblock.reserved,
> +			 &spa, &epa, &nid);
> +
> +	while (*idx != ULLONG_MAX) {

Ditto, use U64_MAX

> +		unsigned long epfn = PFN_DOWN(epa);
> +		unsigned long spfn = PFN_UP(spa);
> +
> +		/*
> +		 * Verify the end is at least past the start of the zone and
> +		 * that we have at least one PFN to initialize.
> +		 */
> +		if (zone->zone_start_pfn < epfn && spfn < epfn) {
> +			/* if we went too far just stop searching */
> +			if (zone_end_pfn(zone) <= spfn)
> +				break;

Set *idx = U64_MAX here, then break. This way after we are outside this
while loop idx is always equals to U64_MAX.

> +
> +			if (out_spfn)
> +				*out_spfn = max(zone->zone_start_pfn, spfn);
> +			if (out_epfn)
> +				*out_epfn = min(zone_end_pfn(zone), epfn);

Don't we need to verify after adjustment that out_spfn != out_epfn, so
there is at least one PFN to initialize?

The rest looks good. Once the above is fixed:

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

Thank you,
Pasha
