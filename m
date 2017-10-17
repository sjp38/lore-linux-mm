Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA356B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 11:14:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z55so984069wrz.2
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:14:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f20si2067575edm.199.2017.10.17.08.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 08:14:15 -0700 (PDT)
Subject: Re: [PATCH v12 01/11] mm: deferred_init_memmap improvements
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-2-pasha.tatashin@oracle.com>
 <20171017114028.uyt63277md5tuc4j@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <dc43ac9d-8dff-d655-afd5-cb035a9f1a1a@oracle.com>
Date: Tue, 17 Oct 2017 11:13:19 -0400
MIME-Version: 1.0
In-Reply-To: <20171017114028.uyt63277md5tuc4j@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

> This really begs to have two patches... I will not insist though. I also
> suspect the code can be further simplified but again this is nothing to
> block this to go.

Perhaps "page" can be avoided in deferred_init_range(), as pfn is 
converted to page in deferred_free_range, but I have not studied it.

>   
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> 
> I do not see any obvious issues in the patch
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you very much!

Pavel

> 
>> ---
>>   mm/page_alloc.c | 168 ++++++++++++++++++++++++++++----------------------------
>>   1 file changed, 85 insertions(+), 83 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 77e4d3c5c57b..cdbd14829fd3 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1410,14 +1410,17 @@ void clear_zone_contiguous(struct zone *zone)
>>   }
>>   
>>   #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>> -static void __init deferred_free_range(struct page *page,
>> -					unsigned long pfn, int nr_pages)
>> +static void __init deferred_free_range(unsigned long pfn,
>> +				       unsigned long nr_pages)
>>   {
>> -	int i;
>> +	struct page *page;
>> +	unsigned long i;
>>   
>> -	if (!page)
>> +	if (!nr_pages)
>>   		return;
>>   
>> +	page = pfn_to_page(pfn);
>> +
>>   	/* Free a large naturally-aligned chunk if possible */
>>   	if (nr_pages == pageblock_nr_pages &&
>>   	    (pfn & (pageblock_nr_pages - 1)) == 0) {
>> @@ -1443,19 +1446,89 @@ static inline void __init pgdat_init_report_one_done(void)
>>   		complete(&pgdat_init_all_done_comp);
>>   }
>>   
>> +/*
>> + * Helper for deferred_init_range, free the given range, reset the counters, and
>> + * return number of pages freed.
>> + */
>> +static inline unsigned long __def_free(unsigned long *nr_free,
>> +				       unsigned long *free_base_pfn,
>> +				       struct page **page)
>> +{
>> +	unsigned long nr = *nr_free;
>> +
>> +	deferred_free_range(*free_base_pfn, nr);
>> +	*free_base_pfn = 0;
>> +	*nr_free = 0;
>> +	*page = NULL;
>> +
>> +	return nr;
>> +}
>> +
>> +static unsigned long deferred_init_range(int nid, int zid, unsigned long pfn,
>> +					 unsigned long end_pfn)
>> +{
>> +	struct mminit_pfnnid_cache nid_init_state = { };
>> +	unsigned long nr_pgmask = pageblock_nr_pages - 1;
>> +	unsigned long free_base_pfn = 0;
>> +	unsigned long nr_pages = 0;
>> +	unsigned long nr_free = 0;
>> +	struct page *page = NULL;
>> +
>> +	for (; pfn < end_pfn; pfn++) {
>> +		/*
>> +		 * First we check if pfn is valid on architectures where it is
>> +		 * possible to have holes within pageblock_nr_pages. On systems
>> +		 * where it is not possible, this function is optimized out.
>> +		 *
>> +		 * Then, we check if a current large page is valid by only
>> +		 * checking the validity of the head pfn.
>> +		 *
>> +		 * meminit_pfn_in_nid is checked on systems where pfns can
>> +		 * interleave within a node: a pfn is between start and end
>> +		 * of a node, but does not belong to this memory node.
>> +		 *
>> +		 * Finally, we minimize pfn page lookups and scheduler checks by
>> +		 * performing it only once every pageblock_nr_pages.
>> +		 */
>> +		if (!pfn_valid_within(pfn)) {
>> +			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>> +		} else if (!(pfn & nr_pgmask) && !pfn_valid(pfn)) {
>> +			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>> +		} else if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
>> +			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>> +		} else if (page && (pfn & nr_pgmask)) {
>> +			page++;
>> +			__init_single_page(page, pfn, zid, nid);
>> +			nr_free++;
>> +		} else {
>> +			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>> +			page = pfn_to_page(pfn);
>> +			__init_single_page(page, pfn, zid, nid);
>> +			free_base_pfn = pfn;
>> +			nr_free = 1;
>> +			cond_resched();
>> +		}
>> +	}
>> +	/* Free the last block of pages to allocator */
>> +	nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>> +
>> +	return nr_pages;
>> +}
>> +
>>   /* Initialise remaining memory on a node */
>>   static int __init deferred_init_memmap(void *data)
>>   {
>>   	pg_data_t *pgdat = data;
>>   	int nid = pgdat->node_id;
>> -	struct mminit_pfnnid_cache nid_init_state = { };
>>   	unsigned long start = jiffies;
>>   	unsigned long nr_pages = 0;
>> -	unsigned long walk_start, walk_end;
>> -	int i, zid;
>> +	unsigned long spfn, epfn;
>> +	phys_addr_t spa, epa;
>> +	int zid;
>>   	struct zone *zone;
>>   	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
>>   	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
>> +	u64 i;
>>   
>>   	if (first_init_pfn == ULONG_MAX) {
>>   		pgdat_init_report_one_done();
>> @@ -1477,83 +1550,12 @@ static int __init deferred_init_memmap(void *data)
>>   		if (first_init_pfn < zone_end_pfn(zone))
>>   			break;
>>   	}
>> +	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
>>   
>> -	for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
>> -		unsigned long pfn, end_pfn;
>> -		struct page *page = NULL;
>> -		struct page *free_base_page = NULL;
>> -		unsigned long free_base_pfn = 0;
>> -		int nr_to_free = 0;
>> -
>> -		end_pfn = min(walk_end, zone_end_pfn(zone));
>> -		pfn = first_init_pfn;
>> -		if (pfn < walk_start)
>> -			pfn = walk_start;
>> -		if (pfn < zone->zone_start_pfn)
>> -			pfn = zone->zone_start_pfn;
>> -
>> -		for (; pfn < end_pfn; pfn++) {
>> -			if (!pfn_valid_within(pfn))
>> -				goto free_range;
>> -
>> -			/*
>> -			 * Ensure pfn_valid is checked every
>> -			 * pageblock_nr_pages for memory holes
>> -			 */
>> -			if ((pfn & (pageblock_nr_pages - 1)) == 0) {
>> -				if (!pfn_valid(pfn)) {
>> -					page = NULL;
>> -					goto free_range;
>> -				}
>> -			}
>> -
>> -			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
>> -				page = NULL;
>> -				goto free_range;
>> -			}
>> -
>> -			/* Minimise pfn page lookups and scheduler checks */
>> -			if (page && (pfn & (pageblock_nr_pages - 1)) != 0) {
>> -				page++;
>> -			} else {
>> -				nr_pages += nr_to_free;
>> -				deferred_free_range(free_base_page,
>> -						free_base_pfn, nr_to_free);
>> -				free_base_page = NULL;
>> -				free_base_pfn = nr_to_free = 0;
>> -
>> -				page = pfn_to_page(pfn);
>> -				cond_resched();
>> -			}
>> -
>> -			if (page->flags) {
>> -				VM_BUG_ON(page_zone(page) != zone);
>> -				goto free_range;
>> -			}
>> -
>> -			__init_single_page(page, pfn, zid, nid);
>> -			if (!free_base_page) {
>> -				free_base_page = page;
>> -				free_base_pfn = pfn;
>> -				nr_to_free = 0;
>> -			}
>> -			nr_to_free++;
>> -
>> -			/* Where possible, batch up pages for a single free */
>> -			continue;
>> -free_range:
>> -			/* Free the current block of pages to allocator */
>> -			nr_pages += nr_to_free;
>> -			deferred_free_range(free_base_page, free_base_pfn,
>> -								nr_to_free);
>> -			free_base_page = NULL;
>> -			free_base_pfn = nr_to_free = 0;
>> -		}
>> -		/* Free the last block of pages to allocator */
>> -		nr_pages += nr_to_free;
>> -		deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
>> -
>> -		first_init_pfn = max(end_pfn, first_init_pfn);
>> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>> +		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
>> +		nr_pages += deferred_init_range(nid, zid, spfn, epfn);
>>   	}
>>   
>>   	/* Sanity check that the next zone really is unpopulated */
>> -- 
>> 2.14.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
