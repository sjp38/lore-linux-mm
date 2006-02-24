Message-ID: <43FE4D45.2040209@jp.fujitsu.com>
Date: Fri, 24 Feb 2006 09:03:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory-layout-free zones (for review) [3/3]  fix	for_each_page_in_zone
References: <20060223180023.396d2cfe.kamezawa.hiroyu@jp.fujitsu.com> <1140718333.8697.69.camel@localhost.localdomain>
In-Reply-To: <1140718333.8697.69.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> I know we don't use this function _too_ much , but it would probably be
> nice to make it a little smarter than "i++".  We can be pretty sure, at
> least with SPARSEMEM that the granularity is larger than that.  We can
> probably leave it until it gets to be a real problem.
Yes, SPARSEMEM can skip PAGES_PER_SECTION pages if !pfn_valid()

> 
> I was also trying to think if a binary search is appropriate here.  I
> guess it depends on whether we allow the zones to have overlapping pfn
> ranges, which I _think_ is one of the goals from these patches.  Any
> thoughts?
> 
What I'm thinking of is to allow zones to have overlapping pfn ranges.
Showing benefit of it (by patch) is difficult now but I think it's sane
direction.

> Oh, and I noticed the "pgdat->zone_spanned_pages" bit.  Did you compile
> this? ;)
> 
No (>_<
>> +static inline struct page *next_page_in_zone(struct page *page,
>> +					     struct zone *zone)
>> +{
>> +	struct pglist_data *pgdat;
>> +	unsigned long start_pfn;
>> +	unsigned long i;
>> +
>> +	if (!populated_zone(zone))
>> +		return NULL;
>> +	pgdat = zone->zone_pgdat;
>> +	start_pfn = pgdat->node_start_pfn;
>> +	i = page_to_pfn(page) - start_pfn;
>> +
>> +	for (i = i + 1; i < pgdat->node_spanned_pages; i++) {
>> +		if (pfn_vlaid(start_pfn + i) && page_zone(page) == zone)
>> +			break;
>> +	}
>> +	if (i == pgdat->node_spanned_pages)
>> +		return NULL;
>> +	return pfn_to_page(start_pfn + i);
>> +}
> 
> Same comment, BTW, about code sharing.  Is it something we want to or
> can do with these?
> 
Hmm...I can't find it. I'll rewrite this code as out-of-line function and
add optimizaion by its memory_model, and do more cleanup.

I'll post these again to -mm before going lkml, and will do compile them in
the next time....

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
