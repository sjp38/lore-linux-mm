Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB9676B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:58:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so22705958pgn.7
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:58:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1si1685714pld.9.2017.10.03.05.58.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 05:58:00 -0700 (PDT)
Date: Tue, 3 Oct 2017 14:57:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 03/12] mm: deferred_init_memmap improvements
Message-ID: <20171003125754.2kuqzkstywg7axhd@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-4-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-4-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 20-09-17 16:17:05, Pavel Tatashin wrote:
> This patch fixes two issues in deferred_init_memmap
> 
> =====
> In deferred_init_memmap() where all deferred struct pages are initialized
> we have a check like this:
> 
> if (page->flags) {
> 	VM_BUG_ON(page_zone(page) != zone);
> 	goto free_range;
> }
> 
> This way we are checking if the current deferred page has already been
> initialized. It works, because memory for struct pages has been zeroed, and
> the only way flags are not zero if it went through __init_single_page()
> before.  But, once we change the current behavior and won't zero the memory
> in memblock allocator, we cannot trust anything inside "struct page"es
> until they are initialized. This patch fixes this.
> 
> The deferred_init_memmap() is re-written to loop through only free memory
> ranges provided by memblock.

Please be explicit that this is possible only because we discard
memblock data later after 3010f876500f ("mm: discard memblock data
later"). Also be more explicit how the new code works.

I like how the resulting code is more compact and smaller.
for_each_free_mem_range also looks more appropriate but I really detest
the DEFERRED_FREE thingy. Maybe we can handle all that in a single goto
section. I know this is not an art but manipulating variables from
macros is more error prone and much more ugly IMHO.

> =====
> This patch fixes another existing issue on systems that have holes in
> zones i.e CONFIG_HOLES_IN_ZONE is defined.
> 
> In for_each_mem_pfn_range() we have code like this:
> 
> if (!pfn_valid_within(pfn)
> 	goto free_range;
> 
> Note: 'page' is not set to NULL and is not incremented but 'pfn' advances.
> Thus means if deferred struct pages are enabled on systems with these kind
> of holes, linux would get memory corruptions. I have fixed this issue by
> defining a new macro that performs all the necessary operations when we
> free the current set of pages.

please do not use macros. Btw. this deserves its own fix. I suspect that
no CONFIG_HOLES_IN_ZONE arch enables DEFERRED_STRUCT_PAGE_INIT but
purely from the review point of view it should be its own patch.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> ---
>  mm/page_alloc.c | 161 +++++++++++++++++++++++++++-----------------------------
>  1 file changed, 78 insertions(+), 83 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c841af88836a..d132c801d2c1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1410,14 +1410,17 @@ void clear_zone_contiguous(struct zone *zone)
>  }
>  
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> -static void __init deferred_free_range(struct page *page,
> -					unsigned long pfn, int nr_pages)
> +static void __init deferred_free_range(unsigned long pfn,
> +				       unsigned long nr_pages)
>  {
> -	int i;
> +	struct page *page;
> +	unsigned long i;
>  
> -	if (!page)
> +	if (!nr_pages)
>  		return;
>  
> +	page = pfn_to_page(pfn);
> +
>  	/* Free a large naturally-aligned chunk if possible */
>  	if (nr_pages == pageblock_nr_pages &&
>  	    (pfn & (pageblock_nr_pages - 1)) == 0) {
> @@ -1443,19 +1446,82 @@ static inline void __init pgdat_init_report_one_done(void)
>  		complete(&pgdat_init_all_done_comp);
>  }
>  
> +#define DEFERRED_FREE(nr_free, free_base_pfn, page)			\
> +({									\
> +	unsigned long nr = (nr_free);					\
> +									\
> +	deferred_free_range((free_base_pfn), (nr));			\
> +	(free_base_pfn) = 0;						\
> +	(nr_free) = 0;							\
> +	page = NULL;							\
> +	nr;								\
> +})
> +
> +static unsigned long deferred_init_range(int nid, int zid, unsigned long pfn,
> +					 unsigned long end_pfn)
> +{
> +	struct mminit_pfnnid_cache nid_init_state = { };
> +	unsigned long nr_pgmask = pageblock_nr_pages - 1;
> +	unsigned long free_base_pfn = 0;
> +	unsigned long nr_pages = 0;
> +	unsigned long nr_free = 0;
> +	struct page *page = NULL;
> +
> +	for (; pfn < end_pfn; pfn++) {
> +		/*
> +		 * First we check if pfn is valid on architectures where it is
> +		 * possible to have holes within pageblock_nr_pages. On systems
> +		 * where it is not possible, this function is optimized out.
> +		 *
> +		 * Then, we check if a current large page is valid by only
> +		 * checking the validity of the head pfn.
> +		 *
> +		 * meminit_pfn_in_nid is checked on systems where pfns can
> +		 * interleave within a node: a pfn is between start and end
> +		 * of a node, but does not belong to this memory node.
> +		 *
> +		 * Finally, we minimize pfn page lookups and scheduler checks by
> +		 * performing it only once every pageblock_nr_pages.
> +		 */
> +		if (!pfn_valid_within(pfn)) {
> +			nr_pages += DEFERRED_FREE(nr_free, free_base_pfn, page);
> +		} else if (!(pfn & nr_pgmask) && !pfn_valid(pfn)) {
> +			nr_pages += DEFERRED_FREE(nr_free, free_base_pfn, page);
> +		} else if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
> +			nr_pages += DEFERRED_FREE(nr_free, free_base_pfn, page);
> +		} else if (page && (pfn & nr_pgmask)) {
> +			page++;
> +			__init_single_page(page, pfn, zid, nid);
> +			nr_free++;
> +		} else {
> +			nr_pages += DEFERRED_FREE(nr_free, free_base_pfn, page);
> +			page = pfn_to_page(pfn);
> +			__init_single_page(page, pfn, zid, nid);
> +			free_base_pfn = pfn;
> +			nr_free = 1;
> +			cond_resched();
> +		}
> +	}
> +	/* Free the last block of pages to allocator */
> +	nr_pages += DEFERRED_FREE(nr_free, free_base_pfn, page);
> +
> +	return nr_pages;
> +}
> +
>  /* Initialise remaining memory on a node */
>  static int __init deferred_init_memmap(void *data)
>  {
>  	pg_data_t *pgdat = data;
>  	int nid = pgdat->node_id;
> -	struct mminit_pfnnid_cache nid_init_state = { };
>  	unsigned long start = jiffies;
>  	unsigned long nr_pages = 0;
> -	unsigned long walk_start, walk_end;
> -	int i, zid;
> +	unsigned long spfn, epfn;
> +	phys_addr_t spa, epa;
> +	int zid;
>  	struct zone *zone;
>  	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
>  	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> +	u64 i;
>  
>  	if (first_init_pfn == ULONG_MAX) {
>  		pgdat_init_report_one_done();
> @@ -1477,83 +1543,12 @@ static int __init deferred_init_memmap(void *data)
>  		if (first_init_pfn < zone_end_pfn(zone))
>  			break;
>  	}
> +	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
>  
> -	for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
> -		unsigned long pfn, end_pfn;
> -		struct page *page = NULL;
> -		struct page *free_base_page = NULL;
> -		unsigned long free_base_pfn = 0;
> -		int nr_to_free = 0;
> -
> -		end_pfn = min(walk_end, zone_end_pfn(zone));
> -		pfn = first_init_pfn;
> -		if (pfn < walk_start)
> -			pfn = walk_start;
> -		if (pfn < zone->zone_start_pfn)
> -			pfn = zone->zone_start_pfn;
> -
> -		for (; pfn < end_pfn; pfn++) {
> -			if (!pfn_valid_within(pfn))
> -				goto free_range;
> -
> -			/*
> -			 * Ensure pfn_valid is checked every
> -			 * pageblock_nr_pages for memory holes
> -			 */
> -			if ((pfn & (pageblock_nr_pages - 1)) == 0) {
> -				if (!pfn_valid(pfn)) {
> -					page = NULL;
> -					goto free_range;
> -				}
> -			}
> -
> -			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
> -				page = NULL;
> -				goto free_range;
> -			}
> -
> -			/* Minimise pfn page lookups and scheduler checks */
> -			if (page && (pfn & (pageblock_nr_pages - 1)) != 0) {
> -				page++;
> -			} else {
> -				nr_pages += nr_to_free;
> -				deferred_free_range(free_base_page,
> -						free_base_pfn, nr_to_free);
> -				free_base_page = NULL;
> -				free_base_pfn = nr_to_free = 0;
> -
> -				page = pfn_to_page(pfn);
> -				cond_resched();
> -			}
> -
> -			if (page->flags) {
> -				VM_BUG_ON(page_zone(page) != zone);
> -				goto free_range;
> -			}
> -
> -			__init_single_page(page, pfn, zid, nid);
> -			if (!free_base_page) {
> -				free_base_page = page;
> -				free_base_pfn = pfn;
> -				nr_to_free = 0;
> -			}
> -			nr_to_free++;
> -
> -			/* Where possible, batch up pages for a single free */
> -			continue;
> -free_range:
> -			/* Free the current block of pages to allocator */
> -			nr_pages += nr_to_free;
> -			deferred_free_range(free_base_page, free_base_pfn,
> -								nr_to_free);
> -			free_base_page = NULL;
> -			free_base_pfn = nr_to_free = 0;
> -		}
> -		/* Free the last block of pages to allocator */
> -		nr_pages += nr_to_free;
> -		deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
> -
> -		first_init_pfn = max(end_pfn, first_init_pfn);
> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> +		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> +		nr_pages += deferred_init_range(nid, zid, spfn, epfn);
>  	}
>  
>  	/* Sanity check that the next zone really is unpopulated */
> -- 
> 2.14.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
