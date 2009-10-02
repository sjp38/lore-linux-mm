Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A6D5660021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 14:31:51 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n92IOoEY020871
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 14:24:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n92IVlwI231710
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 14:31:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n92ISQm9015100
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 14:28:27 -0400
Date: Fri, 2 Oct 2009 13:31:45 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091002183145.GA4908@austin.ibm.com>
References: <20091001195311.GA16667@austin.ibm.com> <4AC520B5.9080600@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AC520B5.9080600@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

* Nathan Fontenot (nfont@austin.ibm.com) wrote:
> Robert Jennings wrote:
>> Memory balloon drivers can allocate a large amount of memory which
>> is not movable but could be freed to accommodate memory hotplug remove.
>>
>> Prior to calling the memory hotplug notifier chain the memory in the
>> pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
>> isolation will not proceed, causing the memory removal for that page
>> range to fail.
>>
>> Rather than immediately failing pageblock isolation if the the
>> migrateteype is not MIGRATE_MOVABLE, this patch checks if all of the
>> pages in the pageblock are owned by a registered balloon driver using a
>> notifier chain.  If all of the non-movable pages are owned by a balloon,
>> they can be freed later through the memory notifier chain and the range
>> can still be isolated in set_migratetype_isolate().
>>
>> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
>>
>> ---
>>  drivers/base/memory.c  |   19 +++++++++++++++++++
>>  include/linux/memory.h |   22 ++++++++++++++++++++++
>>  mm/page_alloc.c        |   49 +++++++++++++++++++++++++++++++++++++++++--------
>>  3 files changed, 82 insertions(+), 8 deletions(-)
>>
<snip>
>> Index: b/mm/page_alloc.c
>> ===================================================================
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -48,6 +48,7 @@
>>  #include <linux/page_cgroup.h>
>>  #include <linux/debugobjects.h>
>>  #include <linux/kmemleak.h>
>> +#include <linux/memory.h>
>>  #include <trace/events/kmem.h>
>>   #include <asm/tlbflush.h>
>> @@ -4985,23 +4986,55 @@ void set_pageblock_flags_group(struct pa
>>  int set_migratetype_isolate(struct page *page)
>>  {
>>  	struct zone *zone;
>> -	unsigned long flags;
>> +	unsigned long flags, pfn, iter;
>> +	long immobile = 0;
>> +	struct memory_isolate_notify arg;
>> +	int notifier_ret;
>>  	int ret = -EBUSY;
>>  	int zone_idx;
>>   	zone = page_zone(page);
>>  	zone_idx = zone_idx(zone);
>> +
>> +	pfn = page_to_pfn(page);
>> +	arg.start_addr = (unsigned long)page_address(page);
>> +	arg.nr_pages = pageblock_nr_pages;
>> +	arg.pages_found = 0;
>> +
>>  	spin_lock_irqsave(&zone->lock, flags);
>>  	/*
>>  	 * In future, more migrate types will be able to be isolation target.
>>  	 */
>> -	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
>> -	    zone_idx != ZONE_MOVABLE)
>> -		goto out;
>> -	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>> -	move_freepages_block(zone, page, MIGRATE_ISOLATE);
>> -	ret = 0;
>> -out:
>> +	do {
>> +		if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE &&
>> +		    zone_idx == ZONE_MOVABLE) {
>> +			ret = 0;
>> +			break;
>> +		}
>> +
>> +		/*
>> +		 * If all of the pages in a zone are used by a balloon,
>> +		 * the range can be still be isolated.  The balloon will
>> +		 * free these pages from the memory notifier chain.
>> +		 */
>> +		notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
>> +		notifier_ret = notifier_to_errno(ret);
>
> Should this be
>
> 		notifier_ret = notifier_to_errno(notifier_ret);
>
> -Nathan

I'll correct this.  Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
