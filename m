Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C60006B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 00:22:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p190so5171231qkc.17
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 21:22:21 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w2-v6si1825579qtn.260.2018.04.22.21.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Apr 2018 21:22:20 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: add find_alloc_contig_pages() interface
References: <20180417020915.11786-1-mike.kravetz@oracle.com>
 <20180417020915.11786-3-mike.kravetz@oracle.com>
 <20180423000943.GO17484@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fc28bcb7-8f9a-e841-0fdf-8636523ebc2a@oracle.com>
Date: Sun, 22 Apr 2018 21:22:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180423000943.GO17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Reinette Chatre <reinette.chatre@intel.com>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/22/2018 05:09 PM, Michal Hocko wrote:
> On Mon 16-04-18 19:09:14, Mike Kravetz wrote:
> [...]
>> @@ -2010,9 +2011,13 @@ static __always_inline struct page *__rmqueue_cma_fallback(struct zone *zone,
>>  {
>>  	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
>>  }
>> +#define contig_alloc_migratetype_ok(migratetype) \
>> +	((migratetype) == MIGRATE_CMA || (migratetype) == MIGRATE_MOVABLE)
>>  #else
>>  static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
>>  					unsigned int order) { return NULL; }
>> +#define contig_alloc_migratetype_ok(migratetype) \
>> +	((migratetype) == MIGRATE_MOVABLE)
>>  #endif
>>  
>>  /*
>> @@ -7822,6 +7827,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>  	};
>>  	INIT_LIST_HEAD(&cc.migratepages);
>>  
>> +	if (!contig_alloc_migratetype_ok(migratetype))
>> +		return -EINVAL;
>> +
>>
>>  	/*
>>  	 * What we do here is we mark all pageblocks in range as
>>  	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
>> @@ -7912,8 +7920,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>  
>>  	/* Make sure the range is really isolated. */
>>  	if (test_pages_isolated(outer_start, end, false)) {
>> -		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>> -			__func__, outer_start, end);
>> +		if (!(migratetype == MIGRATE_MOVABLE)) /* only print for CMA */
>> +			pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>> +				__func__, outer_start, end);
>>  		ret = -EBUSY;
>>  		goto done;
>>  	}
> 
> This probably belongs to a separate patch. I would be tempted to say
> that we should get rid of this migratetype thingy altogether. I confess
> I have forgot everything about why this is required actually but it is
> ugly as hell. Not your fault of course.
> 
>> @@ -7949,6 +7958,82 @@ void free_contig_range(unsigned long pfn, unsigned long nr_pages)
>>  	}
>>  	WARN(count != 0, "%ld pages are still in use!\n", count);
>>  }
>> +
>> +static bool contig_pfn_range_valid(struct zone *z, unsigned long start_pfn,
>> +					unsigned long nr_pages)
>> +{
>> +	unsigned long i, end_pfn = start_pfn + nr_pages;
>> +	struct page *page;
>> +
>> +	for (i = start_pfn; i < end_pfn; i++) {
>> +		if (!pfn_valid(i))
>> +			return false;
>> +
>> +		page = pfn_to_page(i);
> 
> It believe we want pfn_to_online_page here. The old giga pages code is
> buggy in that regard but nothing really critical because the
> alloc_contig_range will notice that.

Ok

> Also do we want to check other usual suspects? E.g. PageReserved? And
> generally migrateable pages if page count > 0. Or do we want to leave
> everything to the alloc_contig_range?

I think you proposed something like the above with limited checking at
some time in the past.  In my testing, allocations were more likely to
succeed if we did limited testing here and let alloc_contig_range take
a shot at migration/allocation.  There really are two ways to approach
this, do as much checking up front or let it be handled by alloc_contig_range.

>> +
>> +		if (page_zone(page) != z)
>> +			return false;
>> +
>> +	}
>> +
>> +	return true;
>> +}
>> +
>> +/**
>> + * find_alloc_contig_pages() -- attempt to find and allocate a contiguous
>> + *				range of pages
>> + * @order:	number of pages
>> + * @gfp:	gfp mask used to limit search as well as during compaction
>> + * @nid:	target node
>> + * @nodemask:	mask of other possible nodes
>> + *
>> + * Pages can be freed with a call to free_contig_pages(), or by manually
>> + * calling __free_page() for each page allocated.
>> + *
>> + * Return: pointer to 'order' pages on success, or NULL if not successful.
>> + */
>> +struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp,
>> +					int nid, nodemask_t *nodemask)
> 
> Vlastimil asked about this but I would even say that we do not want to
> make this order based. Why would we want to restrict the api to 2^order
> sizes in the first place? What if somebody wants to allocate 123 pages?

After Vlastimil's question and again here, I realized that this routine
has a HUGE gap.  For allocation sizes less than MAX_ORDER, it should be
using the traditional paga allocation routines.  It is only when allocation
size is greater than MAX_ORDER that we need to call into alloc_contig_range.

Unless I am missing something, calls to alloc_contig range need to have
a size that is a multiple of page block.  This is because isolation needs
to take place at a page block level.  We can easily 'round up' and release
excess pages.

Using number of pages instead of order makes sense.   I will rewrite with
this in mind as well as taking the other issues into account.

> 
>> +{
>> +	unsigned long pfn, nr_pages, flags;
>> +	struct page *ret_page = NULL;
>> +	struct zonelist *zonelist;
>> +	struct zoneref *z;
>> +	struct zone *zone;
>> +	int rc;
>> +
>> +	nr_pages = 1 << order;
>> +	zonelist = node_zonelist(nid, gfp);
>> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp),
>> +					nodemask) {
>> +		spin_lock_irqsave(&zone->lock, flags);
>> +		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
>> +		while (zone_spans_pfn(zone, pfn + nr_pages - 1)) {
>> +			if (contig_pfn_range_valid(zone, pfn, nr_pages)) {
>> +				spin_unlock_irqrestore(&zone->lock, flags);
> 
> I know that the giga page allocation does use the zone lock but why? I
> suspect it wants to stabilize zone_start_pfn but zone lock doesn't do
> that.
> 

I am not sure.  As you suspected, this was copied from the giga page
allocation code.  I'll look into it.

>> +
>> +				rc = alloc_contig_range(pfn, pfn + nr_pages,
>> +							MIGRATE_MOVABLE, gfp);
>> +				if (!rc) {
>> +					ret_page = pfn_to_page(pfn);
>> +					return ret_page;
>> +				}
>> +				spin_lock_irqsave(&zone->lock, flags);
>> +			}
>> +			pfn += nr_pages;
>> +		}
>> +		spin_unlock_irqrestore(&zone->lock, flags);
>> +	}
> 
> Other than that this API looks much saner than alloc_contig_range. We
> still need to sort out some details (e.g. alignment) but it should be an
> improvement.

Ok, I will continue to refine.  We now have at least one immediate use
case for this type of functionality.

-- 
Mike Kravetz
