Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B866D900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 04:21:17 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so829801wgh.23
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:21:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ww2si481200wjc.29.2014.06.12.01.21.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 01:21:16 -0700 (PDT)
Message-ID: <539962EC.20901@suse.cz>
Date: Thu, 12 Jun 2014 10:21:00 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 09/10] mm, compaction: try to capture the just-created
 high-order freepage
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-9-git-send-email-vbabka@suse.cz> <53986E31.7090500@suse.cz> <20140612022011.GB12415@bbox>
In-Reply-To: <20140612022011.GB12415@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/12/2014 04:20 AM, Minchan Kim wrote:
> On Wed, Jun 11, 2014 at 04:56:49PM +0200, Vlastimil Babka wrote:
>> On 06/09/2014 11:26 AM, Vlastimil Babka wrote:
>>> Compaction uses watermark checking to determine if it succeeded in creating
>>> a high-order free page. My testing has shown that this is quite racy and it
>>> can happen that watermark checking in compaction succeeds, and moments later
>>> the watermark checking in page allocation fails, even though the number of
>>> free pages has increased meanwhile.
>>>
>>> It should be more reliable if direct compaction captured the high-order free
>>> page as soon as it detects it, and pass it back to allocation. This would
>>> also reduce the window for somebody else to allocate the free page.
>>>
>>> This has been already implemented by 1fb3f8ca0e92 ("mm: compaction: capture a
>>> suitable high-order page immediately when it is made available"), but later
>>> reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
>>> high-order page") due to flaws.
>>>
>>> This patch differs from the previous attempt in two aspects:
>>>
>>> 1) The previous patch scanned free lists to capture the page. In this patch,
>>>      only the cc->order aligned block that the migration scanner just finished
>>>      is considered, but only if pages were actually isolated for migration in
>>>      that block. Tracking cc->order aligned blocks also has benefits for the
>>>      following patch that skips blocks where non-migratable pages were found.
>>>
>
> Generally I like this.

Thanks.

>>> 2) In this patch, the isolated free page is allocated through extending
>>>      get_page_from_freelist() and buffered_rmqueue(). This ensures that it gets
>>>      all operations such as prep_new_page() and page->pfmemalloc setting that
>>>      was missing in the previous attempt, zone statistics are updated etc.
>>>
>
> But this part is problem.
> Capturing is not common but you are adding more overhead in hotpath for rare cases
> where even they are ok to fail so it's not a good deal.
> In such case, We have no choice but to do things you mentioned (ex,statistics,
> prep_new_page, pfmemalloc) manually in __alloc_pages_direct_compact.

OK, I will try.

>>> Evaluation is pending.
>>
>> Uh, so if anyone wants to test it, here's a fixed version, as initial evaluation
>> showed it does not actually capture anything (which should not affect patch 10/10
>> though) and debugging this took a while.
>>
>> - for pageblock_order (i.e. THP), capture was never attempted, as the for cycle
>>    in isolate_migratepages_range() has ended right before the
>>    low_pfn == next_capture_pfn check
>> - lru_add_drain() has to be done before pcplists drain. This made a big difference
>>    (~50 successful captures -> ~1300 successful captures)
>>    Note that __alloc_pages_direct_compact() is missing lru_add_drain() as well, and
>>    all the existing watermark-based compaction termination decisions (which happen
>>    before the drain in __alloc_pages_direct_compact()) don't do any draining at all.
>>
>> -----8<-----
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Wed, 28 May 2014 17:05:18 +0200
>> Subject: [PATCH fixed 09/10] mm, compaction: try to capture the just-created
>>   high-order freepage
>>
>> Compaction uses watermark checking to determine if it succeeded in creating
>> a high-order free page. My testing has shown that this is quite racy and it
>> can happen that watermark checking in compaction succeeds, and moments later
>> the watermark checking in page allocation fails, even though the number of
>> free pages has increased meanwhile.
>>
>> It should be more reliable if direct compaction captured the high-order free
>> page as soon as it detects it, and pass it back to allocation. This would
>> also reduce the window for somebody else to allocate the free page.
>>
>> This has been already implemented by 1fb3f8ca0e92 ("mm: compaction: capture a
>> suitable high-order page immediately when it is made available"), but later
>> reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
>> high-order page") due to flaws.
>>
>> This patch differs from the previous attempt in two aspects:
>>
>> 1) The previous patch scanned free lists to capture the page. In this patch,
>>     only the cc->order aligned block that the migration scanner just finished
>>     is considered, but only if pages were actually isolated for migration in
>>     that block. Tracking cc->order aligned blocks also has benefits for the
>>     following patch that skips blocks where non-migratable pages were found.
>>
>> 2) In this patch, the isolated free page is allocated through extending
>>     get_page_from_freelist() and buffered_rmqueue(). This ensures that it gets
>>     all operations such as prep_new_page() and page->pfmemalloc setting that
>>     was missing in the previous attempt, zone statistics are updated etc.
>>
>> Evaluation is pending.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: David Rientjes <rientjes@google.com>
>> ---
>>   include/linux/compaction.h |   5 ++-
>>   mm/compaction.c            | 103 +++++++++++++++++++++++++++++++++++++++++++--
>>   mm/internal.h              |   2 +
>>   mm/page_alloc.c            |  69 ++++++++++++++++++++++++------
>>   4 files changed, 161 insertions(+), 18 deletions(-)
>>
>> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
>> index 01e3132..69579f5 100644
>> --- a/include/linux/compaction.h
>> +++ b/include/linux/compaction.h
>> @@ -10,6 +10,8 @@
>>   #define COMPACT_PARTIAL		2
>>   /* The full zone was compacted */
>>   #define COMPACT_COMPLETE	3
>> +/* Captured a high-order free page in direct compaction */
>> +#define COMPACT_CAPTURED	4
>>
>>   #ifdef CONFIG_COMPACTION
>>   extern int sysctl_compact_memory;
>> @@ -22,7 +24,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>>   extern int fragmentation_index(struct zone *zone, unsigned int order);
>>   extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>>   			int order, gfp_t gfp_mask, nodemask_t *mask,
>> -			enum migrate_mode mode, bool *contended);
>> +			enum migrate_mode mode, bool *contended,
>> +			struct page **captured_page);
>>   extern void compact_pgdat(pg_data_t *pgdat, int order);
>>   extern void reset_isolation_suitable(pg_data_t *pgdat);
>>   extern unsigned long compaction_suitable(struct zone *zone, int order);
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index d1e30ba..2988758 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -541,6 +541,16 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>   	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
>>   					ISOLATE_ASYNC_MIGRATE : 0) |
>>   				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
>> +	unsigned long capture_pfn = 0;   /* current candidate for capturing */
>> +	unsigned long next_capture_pfn = 0; /* next candidate for capturing */
>> +
>> +	if (cc->order > PAGE_ALLOC_COSTLY_ORDER
>> +		&& gfpflags_to_migratetype(cc->gfp_mask) == MIGRATE_MOVABLE
>> +			&& cc->order <= pageblock_order) {
>
> You sent with RFC mark so I will not review detailed thing but just design stuff.
>
> Why does capture work for limited high-order range?

I thought the overhead of maintaining the pfn's and trying the capture 
would be a bad tradeoff for low-order compactions which I suppose have a 
good chance of succeeding even without capture. But I admit I don't have 
data to support this yet.

> Direct compaction is really costly operation for the process and he did it
> at the cost of his resource(ie, timeslice) so anyone try to do direct compaction
> deserves to have a precious result regardless of order.
> Another question: Why couldn't the capture work for only MIGRATE_CMA?

CMA allocations don't go through standard direct compaction. They also 
use memory isolation to prevent parallel activity from stealing the 
pages freed by compaction. And importantly they set cc->order = -1, as 
the goal is not to compact a single high-order page, but arbitrary long 
range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
