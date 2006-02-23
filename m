Message-ID: <43FE4915.50100@jp.fujitsu.com>
Date: Fri, 24 Feb 2006 08:45:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory-layout-free zones (for review) [1/3]	for_each_page_in_zone()
References: <20060223175643.a685dfb3.kamezawa.hiroyu@jp.fujitsu.com> <1140717824.8697.59.camel@localhost.localdomain>
In-Reply-To: <1140717824.8697.59.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2006-02-23 at 17:56 +0900, KAMEZAWA Hiroyuki wrote:
>> +/*
>> + *  These inline function for for_each_page_in_zone can work
>> + *  even if CONFIG_SPARSEMEM=y.
>> + */
>> +static inline struct page *first_page_in_zone(struct zone *zone)
>> +{
>> +	unsigned long start_pfn = zone->zone_start_pfn;
>> +	unsigned long i = 0;
>> +
>> +	if (!populated_zone(zone))
>> +		return NULL;
>> +
>> +	for (i = 0; i < zone->zone_spanned_pages; i++) {
>> +		if (pfn_valid(start_pfn + i))
>> +			break;
>> +	}
>> +	return pfn_to_page(start_pfn + i);
>> +}
> 
> Isn't this a little hefty of a function for an inline?
> 
Hmm...making this out-of-line and adding this to page_alloc.c or
mmzone.c(new) looks better. (Then, we can write the best function for
each memory-model.)


> Also, why would we _ever_ have a zone that didn't actually have a valid
> pfn at its start?  If there wasn't a valid pfn there, with no
> zone_mem_map, wouldn't we just bump up the start_pfn?
> 
This patch is just for cleanup for avoiding complicated big patch.

>> +static inline struct page *next_page_in_zone(struct page *page,
>> +					     struct zone *zone)
>> +{
>> +	unsigned long start_pfn = zone->zone_start_pfn;
>> +	unsigned long i = page_to_pfn(page) - start_pfn;
>> +
>> +	if (!populated_zone(zone))
>> +		return NULL;
>> +
>> +	for (i = i + 1; i < zone->zone_spanned_pages; i++) {
>> +		if (pfn_vlaid(start_pfn + i))
>> +			break;
>> +	}
>> +	if (i == zone->zone_spanned_pages)
>> +		return NULL;
>> +	return pfn_to_page(start_pfn + i);
>> +}
> 
> Seems like this should share code with the other function.  And the
> "vlaid" part looks a bit uncompilable. ;)
> 
yes....uncompilable....

Thanks,
-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
