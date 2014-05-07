Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1586B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:23:03 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so506925eei.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:23:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o49si13140632eef.38.2014.05.07.02.23.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 02:23:01 -0700 (PDT)
Message-ID: <5369FB73.3080103@suse.cz>
Date: Wed, 07 May 2014 11:22:59 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: avoid rescanning pageblocks in isolate_freepages
References: <5363B854.3010401@suse.cz> <1399044475-3154-1-git-send-email-vbabka@suse.cz> <1399414778-xakujfb3@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1399414778-xakujfb3@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, gthelen@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com, cl@linux.com, Rik van Riel <riel@redhat.com>

On 05/07/2014 12:19 AM, Naoya Horiguchi wrote:
> On Fri, May 02, 2014 at 05:27:55PM +0200, Vlastimil Babka wrote:
>> The compaction free scanner in isolate_freepages() currently remembers PFN of
>> the highest pageblock where it successfully isolates, to be used as the
>> starting pageblock for the next invocation. The rationale behind this is that
>> page migration might return free pages to the allocator when migration fails
>> and we don't want to skip them if the compaction continues.
>>
>> Since migration now returns free pages back to compaction code where they can
>> be reused, this is no longer a concern. This patch changes isolate_freepages()
>> so that the PFN for restarting is updated with each pageblock where isolation
>> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
>> reduction of the pages scanned by the free scanner.
>>
>> Note that the somewhat similar functionality that records highest successful
>> pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache is
>> used when the whole compaction is restarted, not for multiple invocations of
>> the free scanner during single compaction.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> ---
>>   mm/compaction.c | 18 ++++++------------
>>   1 file changed, 6 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 873d7de..1967850 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -686,12 +686,6 @@ static void isolate_freepages(struct zone *zone,
>>   	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>
>>   	/*
>> -	 * If no pages are isolated, the block_start_pfn < low_pfn check
>> -	 * will kick in.
>> -	 */
>> -	next_free_pfn = 0;
>> -
>> -	/*
>>   	 * Isolate free pages until enough are available to migrate the
>>   	 * pages on cc->migratepages. We stop searching if the migrate
>>   	 * and free page scanners meet or enough free pages are isolated.
>> @@ -731,19 +725,19 @@ static void isolate_freepages(struct zone *zone,
>>   			continue;
>>
>>   		/* Found a block suitable for isolating free pages from */
>> +		next_free_pfn = block_start_pfn;
>>   		isolated = isolate_freepages_block(cc, block_start_pfn,
>>   					block_end_pfn, freelist, false);
>>   		nr_freepages += isolated;
>>
>>   		/*
>> -		 * Record the highest PFN we isolated pages from. When next
>> -		 * looking for free pages, the search will restart here as
>> -		 * page migration may have returned some pages to the allocator
>> +		 * Set a flag that we successfully isolated in this pageblock.
>> +		 * In the next loop iteration, zone->compact_cached_free_pfn
>> +		 * will not be updated and thus it will effectively contain the
>> +		 * highest pageblock we isolated pages from.
>>   		 */
>> -		if (isolated && next_free_pfn == 0) {
>> +		if (isolated)
>>   			cc->finished_update_free = true;
>> -			next_free_pfn = block_start_pfn;
>> -		}
>
> Why don't you completely remove next_free_pfn and update cc->free_pfn directly?

Hi,

well you could ask the same about the nr_freepages variable. For me 
personally local variable (now with a comment for next_free_pfn) looks 
more readable. The function currently received cleanup from several 
people (including me), so I wouldn't want to change it again, unless 
others also think it would be better. From compiler standpoint both 
variants should be the same I guess.

Vlastimil

> Thanks,
> Naoya Horiguchi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
