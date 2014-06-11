Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 08AF36B014F
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 07:41:43 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so479871wes.17
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:41:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hj5si21505994wib.52.2014.06.11.04.41.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 04:41:42 -0700 (PDT)
Message-ID: <53984074.8010000@suse.cz>
Date: Wed, 11 Jun 2014 13:41:40 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] mm, compaction: remember position within pageblock
 in free pages scanner
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-5-git-send-email-vbabka@suse.cz> <20140611021213.GF15630@bbox> <20140611081606.GB28258@js1304-P5Q-DELUXE>
In-Reply-To: <20140611081606.GB28258@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/11/2014 10:16 AM, Joonsoo Kim wrote:
> On Wed, Jun 11, 2014 at 11:12:13AM +0900, Minchan Kim wrote:
>> On Mon, Jun 09, 2014 at 11:26:17AM +0200, Vlastimil Babka wrote:
>>> Unlike the migration scanner, the free scanner remembers the beginning of the
>>> last scanned pageblock in cc->free_pfn. It might be therefore rescanning pages
>>> uselessly when called several times during single compaction. This might have
>>> been useful when pages were returned to the buddy allocator after a failed
>>> migration, but this is no longer the case.
>>>
>>> This patch changes the meaning of cc->free_pfn so that if it points to a
>>> middle of a pageblock, that pageblock is scanned only from cc->free_pfn to the
>>> end. isolate_freepages_block() will record the pfn of the last page it looked
>>> at, which is then used to update cc->free_pfn.
>>>
>>> In the mmtests stress-highalloc benchmark, this has resulted in lowering the
>>> ratio between pages scanned by both scanners, from 2.5 free pages per migrate
>>> page, to 2.25 free pages per migrate page, without affecting success rates.
>>>
>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Reviewed-by: Minchan Kim <minchan@kernel.org>
>>
>> Below is a nitpick.
>>
>>> Cc: Minchan Kim <minchan@kernel.org>
>>> Cc: Mel Gorman <mgorman@suse.de>
>>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> Cc: Michal Nazarewicz <mina86@mina86.com>
>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Cc: Christoph Lameter <cl@linux.com>
>>> Cc: Rik van Riel <riel@redhat.com>
>>> Cc: David Rientjes <rientjes@google.com>
>>> ---
>>>   mm/compaction.c | 33 ++++++++++++++++++++++++++++-----
>>>   1 file changed, 28 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 83f72bd..58dfaaa 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -297,7 +297,7 @@ static bool suitable_migration_target(struct page *page)
>>>    * (even though it may still end up isolating some pages).
>>>    */
>>>   static unsigned long isolate_freepages_block(struct compact_control *cc,
>>> -				unsigned long blockpfn,
>>> +				unsigned long *start_pfn,
>>>   				unsigned long end_pfn,
>>>   				struct list_head *freelist,
>>>   				bool strict)
>>> @@ -306,6 +306,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>>   	struct page *cursor, *valid_page = NULL;
>>>   	unsigned long flags;
>>>   	bool locked = false;
>>> +	unsigned long blockpfn = *start_pfn;
>>>
>>>   	cursor = pfn_to_page(blockpfn);
>>>
>>> @@ -314,6 +315,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>>   		int isolated, i;
>>>   		struct page *page = cursor;
>>>
>>> +		/* Record how far we have got within the block */
>>> +		*start_pfn = blockpfn;
>>> +
>>
>> Couldn't we move this out of the loop for just one store?

Ah, I get it now. Ignore my previous reply.

> Hello, Vlastimil.
>
> Moreover, start_pfn can't be updated to end pfn with this approach.
> Is it okay?

That's intentional, as end_pfn means the scanner would restart at the 
beginning of next pageblock. So I want to record last pfn *inside* the 
pageblock that was fully scanned. Note that there's a high change that 
fully scanning pageblock means that I haven't isolated enough and 
isolate_freepages() will advance to the previous pageblock anyway, and 
the recorded value will be overwritten. But still it's better to prevent 
this corner case.

So outside the loop, I would need to do:

*start_pfn = max(blockpfn, end_pfn - 1);

It looks a bit tricky but probably better than multiple assignments.

Thanks.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
