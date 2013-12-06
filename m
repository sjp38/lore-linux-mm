Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id B0F006B0037
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:50:29 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so176422eek.35
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:50:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si8795722eeo.142.2013.12.06.01.50.28
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 01:50:28 -0800 (PST)
Message-ID: <52A19DDF.9050608@suse.cz>
Date: Fri, 06 Dec 2013 10:50:23 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: Trace compaction begin and end
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz> <20131204143045.GZ11295@suse.de> <529F418D.3070108@suse.cz> <20131205090544.GF11295@suse.de>
In-Reply-To: <20131205090544.GF11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On 12/05/2013 10:05 AM, Mel Gorman wrote:
> On Wed, Dec 04, 2013 at 03:51:57PM +0100, Vlastimil Babka wrote:
>> On 12/04/2013 03:30 PM, Mel Gorman wrote:
>>> This patch adds two tracepoints for compaction begin and end of a zone. Using
>>> this it is possible to calculate how much time a workload is spending
>>> within compaction and potentially debug problems related to cached pfns
>>> for scanning.
>>
>> I guess for debugging pfns it would be also useful to print their
>> values also in mm_compaction_end.
>>
>
> What additional information would we get from it and what new
> conclusions could we draw? We could guess how much work the
> scanners did but the trace_mm_compaction_isolate_freepages and
> trace_mm_compaction_isolate_migratepages tracepoints already accurately
> tell us that. The scanner PFNs alone do not tell us if the cached pfns
> were updated and even if it did, the information can be changed by
> parallel resets so it would be hard to draw reasonable conclusions from
> the information. We could guess where compaction hotspots might be but
> without the skip information, we could not detect it accurately.  If we
> wanted to detect that accurately, the mm_compaction_isolate* tracepoints
> would be the one to update.

OK, I agree. I guess multiple compaction_begin events would hint at 
scanners being stuck anyway.

> I was primarily concerned about compaction time so I might be looking
> at this the wrong way but it feels like having the PFNs at the end of a
> compaction cycle would be of marginal benefit.
>
>>> In combination with the direct reclaim and slab trace points
>>> it should be possible to estimate most allocation-related overhead for
>>> a workload.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>> ---
>>>   include/trace/events/compaction.h | 42 +++++++++++++++++++++++++++++++++++++++
>>>   mm/compaction.c                   |  4 ++++
>>>   2 files changed, 46 insertions(+)
>>>
>>> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
>>> index fde1b3e..f4e115a 100644
>>> --- a/include/trace/events/compaction.h
>>> +++ b/include/trace/events/compaction.h
>>> @@ -67,6 +67,48 @@ TRACE_EVENT(mm_compaction_migratepages,
>>>   		__entry->nr_failed)
>>>   );
>>>
>>> +TRACE_EVENT(mm_compaction_begin,
>>> +	TP_PROTO(unsigned long zone_start, unsigned long migrate_start,
>>> +		unsigned long zone_end, unsigned long free_start),
>>> +
>>> +	TP_ARGS(zone_start, migrate_start, zone_end, free_start),
>>
>> IMHO a better order would be:
>>   zone_start, migrate_start, free_start, zone_end
>> (well especially in the TP_printk part anyway).
>>
>
> Ok, that would put them in PFN order which may be easier to visualise.
> I'll post a V2 with that change at least.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
