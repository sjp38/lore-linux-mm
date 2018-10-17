Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 669D96B0273
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:42:50 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b202-v6so18259894oii.23
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:42:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e69-v6si8713823oih.240.2018.10.17.09.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 09:42:48 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9HGff1o003821
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:42:47 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n67xttku0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:42:47 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 17 Oct 2018 17:42:44 +0100
Date: Wed, 17 Oct 2018 19:42:33 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [mm PATCH v3 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202709.2171.75580.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015202709.2171.75580.stgit@localhost.localdomain>
Message-Id: <20181017164233.GA7553@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Mon, Oct 15, 2018 at 01:27:09PM -0700, Alexander Duyck wrote:
> This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.
> 
> This iterator will take care of making sure a given memory range provided
> is in fact contained within a zone. It takes are of all the bounds checking
> we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
> it should help to speed up the search a bit by iterating until the end of a
> range is greater than the start of the zone pfn range, and will exit
> completely if the start is beyond the end of the zone.
> 
> This patch adds yet another iterator called
> for_each_free_mem_range_in_zone_from and then uses it to support
> initializing and freeing pages in groups no larger than MAX_ORDER_NR_PAGES.
> By doing this we can greatly improve the cache locality of the pages while
> we do several loops over them in the init and freeing process.
> 
> We are able to tighten the loops as a result since we only really need the
> checks for first_init_pfn in our first iteration and after that we can
> assume that all future values will be greater than this. So I have added a
> function called deferred_init_mem_pfn_range_in_zone that primes the
> iterators and if it fails we can just exit.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  include/linux/memblock.h |   58 +++++++++++++++
>  mm/memblock.c            |   63 ++++++++++++++++
>  mm/page_alloc.c          |  176 ++++++++++++++++++++++++++++++++--------------
>  3 files changed, 242 insertions(+), 55 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index aee299a6aa76..d62b95dba94e 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -178,6 +178,25 @@ void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
>  			      p_start, p_end, p_nid))
> 
>  /**
> + * for_each_mem_range - iterate through memblock areas from type_a and not

nit: for_each_mem_range_from

> + * included in type_b. Or just type_a if type_b is NULL.
> + * @i: u64 used as loop variable
> + * @type_a: ptr to memblock_type to iterate
> + * @type_b: ptr to memblock_type which excludes from the iteration
> + * @nid: node selector, %NUMA_NO_NODE for all nodes
> + * @flags: pick from blocks based on memory attributes
> + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + * @p_nid: ptr to int for nid of the range, can be %NULL
> + */
> +#define for_each_mem_range_from(i, type_a, type_b, nid, flags,		\
> +			   p_start, p_end, p_nid)			\
> +	for (i = 0, __next_mem_range(&i, nid, flags, type_a, type_b,	\
> +				     p_start, p_end, p_nid);		\
> +	     i != (u64)ULLONG_MAX;					\
> +	     __next_mem_range(&i, nid, flags, type_a, type_b,		\
> +			      p_start, p_end, p_nid))
> +/**
>   * for_each_mem_range_rev - reverse iterate through memblock areas from
>   * type_a and not included in type_b. Or just type_a if type_b is NULL.
>   * @i: u64 used as loop variable
> @@ -248,6 +267,45 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>  	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> 
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
> +				  unsigned long *out_spfn,
> +				  unsigned long *out_epfn);
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
> +
> +/**
> + * for_each_free_mem_range_in_zone_from - iterate through zone specific
> + * free memblock areas from a given point
> + * @i: u64 used as loop variable
> + * @zone: zone in which all of the memory blocks reside
> + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + *
> + * Walks over free (memory && !reserved) areas of memblock in a specific
> + * zone, continuing from current position. Available as soon as memblock is
> + * initialized.
> + */
> +#define for_each_free_mem_pfn_range_in_zone_from(i, zone, p_start, p_end) \
> +	for (; i != (u64)ULLONG_MAX;					  \
> +	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
> +
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> +
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 5fefc70253ee..dc6e28e7f869 100644
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
> +
> +			if (out_spfn)
> +				*out_spfn = max(zone->zone_start_pfn, spfn);
> +			if (out_epfn)
> +				*out_epfn = min(zone_end_pfn(zone), epfn);
> +
> +			return;
> +		}
> +
> +		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
> +				 &memblock.memory, &memblock.reserved,
> +				 &spa, &epa, &nid);
> +	}
> +
> +	/* signal end of iteration */
> +	*idx = ULLONG_MAX;
> +	if (out_spfn)
> +		*out_spfn = ULONG_MAX;
> +	if (out_epfn)
> +		*out_epfn = 0;
> +}
> +
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> 
>  #ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
>  unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a766a15fad81..20e9eb35d75d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1512,19 +1512,103 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
>  	return (nr_pages);
>  }
> 
> +/*
> + * This function is meant to pre-load the iterator for the zone init.
> + * Specifically it walks through the ranges until we are caught up to the
> + * first_init_pfn value and exits there. If we never encounter the value we
> + * return false indicating there are no valid ranges left.
> + */
> +static bool __init
> +deferred_init_mem_pfn_range_in_zone(u64 *i, struct zone *zone,
> +				    unsigned long *spfn, unsigned long *epfn,
> +				    unsigned long first_init_pfn)
> +{
> +	u64 j;
> +
> +	/*
> +	 * Start out by walking through the ranges in this zone that have
> +	 * already been initialized. We don't need to do anything with them
> +	 * so we just need to flush them out of the system.
> +	 */
> +	for_each_free_mem_pfn_range_in_zone(j, zone, spfn, epfn) {
> +		if (*epfn <= first_init_pfn)
> +			continue;
> +		if (*spfn < first_init_pfn)
> +			*spfn = first_init_pfn;
> +		*i = j;
> +		return true;
> +	}
> +
> +	return false;
> +}
> +
> +/*
> + * Initialize and free pages. We do it in two loops: first we initialize
> + * struct page, than free to buddy allocator, because while we are
> + * freeing pages we can access pages that are ahead (computing buddy
> + * page in __free_one_page()).
> + *
> + * In order to try and keep some memory in the cache we have the loop
> + * broken along max page order boundaries. This way we will not cause
> + * any issues with the buddy page computation.
> + */
> +static unsigned long __init
> +deferred_init_maxorder(u64 *i, struct zone *zone, unsigned long *start_pfn,
> +		       unsigned long *end_pfn)
> +{
> +	unsigned long mo_pfn = ALIGN(*start_pfn + 1, MAX_ORDER_NR_PAGES);
> +	unsigned long spfn = *start_pfn, epfn = *end_pfn;
> +	unsigned long nr_pages = 0;
> +	u64 j = *i;
> +
> +	/* First we loop through and initialize the page values */
> +	for_each_free_mem_pfn_range_in_zone_from(j, zone, &spfn, &epfn) {
> +		unsigned long t;
> +
> +		if (mo_pfn <= spfn)
> +			break;
> +
> +		t = min(mo_pfn, epfn);
> +		nr_pages += deferred_init_pages(zone, spfn, t);
> +
> +		if (mo_pfn <= epfn)
> +			break;
> +	}
> +
> +	/* Reset values and now loop through freeing pages as needed */
> +	j = *i;
> +
> +	for_each_free_mem_pfn_range_in_zone_from(j, zone, start_pfn, end_pfn) {
> +		unsigned long t;
> +
> +		if (mo_pfn <= *start_pfn)
> +			break;
> +
> +		t = min(mo_pfn, *end_pfn);
> +		deferred_free_pages(*start_pfn, t);
> +		*start_pfn = t;
> +
> +		if (mo_pfn < *end_pfn)
> +			break;
> +	}
> +
> +	/* Store our current values to be reused on the next iteration */
> +	*i = j;
> +
> +	return nr_pages;
> +}
> +
>  /* Initialise remaining memory on a node */
>  static int __init deferred_init_memmap(void *data)
>  {
>  	pg_data_t *pgdat = data;
> -	int nid = pgdat->node_id;
> +	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> +	unsigned long spfn = 0, epfn = 0, nr_pages = 0;
> +	unsigned long first_init_pfn, flags;
>  	unsigned long start = jiffies;
> -	unsigned long nr_pages = 0;
> -	unsigned long spfn, epfn, first_init_pfn, flags;
> -	phys_addr_t spa, epa;
> -	int zid;
>  	struct zone *zone;
> -	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
>  	u64 i;
> +	int zid;
> 
>  	/* Bind memory initialisation thread to a local node if possible */
>  	if (!cpumask_empty(cpumask))
> @@ -1549,31 +1633,30 @@ static int __init deferred_init_memmap(void *data)
>  		if (first_init_pfn < zone_end_pfn(zone))
>  			break;
>  	}
> -	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
> +
> +	/* If the zone is empty somebody else may have cleared out the zone */
> +	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
> +						 first_init_pfn)) {
> +		pgdat_resize_unlock(pgdat, &flags);
> +		pgdat_init_report_one_done();
> +		return 0;
> +	}
> 
>  	/*
> -	 * Initialize and free pages. We do it in two loops: first we initialize
> -	 * struct page, than free to buddy allocator, because while we are
> -	 * freeing pages we can access pages that are ahead (computing buddy
> -	 * page in __free_one_page()).
> +	 * Initialize and free pages in MAX_ORDER sized increments so
> +	 * that we can avoid introducing any issues with the buddy
> +	 * allocator.
>  	 */
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> -		nr_pages += deferred_init_pages(zone, spfn, epfn);
> -	}
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> -		deferred_free_pages(spfn, epfn);
> -	}
> +	while (spfn < epfn)
> +		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
> +
>  	pgdat_resize_unlock(pgdat, &flags);
> 
>  	/* Sanity check that the next zone really is unpopulated */
>  	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
> 
> -	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
> -					jiffies_to_msecs(jiffies - start));
> +	pr_info("node %d initialised, %lu pages in %ums\n",
> +		pgdat->node_id,	nr_pages, jiffies_to_msecs(jiffies - start));
> 
>  	pgdat_init_report_one_done();
>  	return 0;
> @@ -1604,14 +1687,11 @@ static int __init deferred_init_memmap(void *data)
>  static noinline bool __init
>  deferred_grow_zone(struct zone *zone, unsigned int order)
>  {
> -	int zid = zone_idx(zone);
> -	int nid = zone_to_nid(zone);
> -	pg_data_t *pgdat = NODE_DATA(nid);
>  	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
> -	unsigned long nr_pages = 0;
> -	unsigned long first_init_pfn, spfn, epfn, t, flags;
> +	pg_data_t *pgdat = zone->zone_pgdat;
>  	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
> -	phys_addr_t spa, epa;
> +	unsigned long spfn, epfn, flags;
> +	unsigned long nr_pages = 0;
>  	u64 i;
> 
>  	/* Only the last zone may have deferred pages */
> @@ -1640,37 +1720,23 @@ static int __init deferred_init_memmap(void *data)
>  		return true;
>  	}
> 
> -	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
> -
> -	if (first_init_pfn >= pgdat_end_pfn(pgdat)) {
> +	/* If the zone is empty somebody else may have cleared out the zone */
> +	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
> +						 first_deferred_pfn)) {
>  		pgdat_resize_unlock(pgdat, &flags);
> -		return false;
> +		return true;
>  	}
> 
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> -
> -		while (spfn < epfn && nr_pages < nr_pages_needed) {
> -			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
> -			first_deferred_pfn = min(t, epfn);
> -			nr_pages += deferred_init_pages(zone, spfn,
> -							first_deferred_pfn);
> -			spfn = first_deferred_pfn;
> -		}
> -
> -		if (nr_pages >= nr_pages_needed)
> -			break;
> +	/*
> +	 * Initialize and free pages in MAX_ORDER sized increments so
> +	 * that we can avoid introducing any issues with the buddy
> +	 * allocator.
> +	 */
> +	while (spfn < epfn && nr_pages < nr_pages_needed) {
> +		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
> +		first_deferred_pfn = spfn;
>  	}
> 
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
> -		deferred_free_pages(spfn, epfn);
> -
> -		if (first_deferred_pfn == epfn)
> -			break;
> -	}
>  	pgdat->first_deferred_pfn = first_deferred_pfn;
>  	pgdat_resize_unlock(pgdat, &flags);
> 
> 

-- 
Sincerely yours,
Mike.
