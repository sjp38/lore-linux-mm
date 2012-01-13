Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 882E76B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 21:29:56 -0500 (EST)
Message-ID: <4F0F9770.10004@freescale.com>
Date: Fri, 13 Jan 2012 10:31:12 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : check the watermark when cc->order
 is -1
References: <1325818201-1865-1-git-send-email-b32955@freescale.com> <4F0E76BE.1070806@freescale.com> <20120112120530.GJ4118@suse.de>
In-Reply-To: <20120112120530.GJ4118@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

Hi,
> On Thu, Jan 12, 2012 at 01:59:26PM +0800, Huang Shijie wrote:
>> ?? 2012??01??06?? 10:50, Huang Shijie ????:
>>> We get cc->order is -1 when user echos to /proc/sys/vm/compact_memory.
>>> In this case, we should check that if we have enough pages for
>>> the compaction in the zone.
>>>
>>> If we do not check this, in our MX6Q board(arm), i ever observed
>>> COMPACT_CLUSTER_MAX pages were compaction failed in per migrate_pages().
>>> Thats mean we can not alloc any pages by the free scanner in the zone.
>>>
>>> This patch checks the watermark to avoid this problem.
>>> Tested this patch in the MX6Q board.
>>>
>>> Signed-off-by: Huang Shijie<b32955@freescale.com>
>>> ---
>>>   mm/compaction.c |   18 +++++++++---------
>>>   1 files changed, 9 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 899d956..bf8e8b2 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -479,21 +479,21 @@ unsigned long compaction_suitable(struct zone *zone, int order)
>>>   	unsigned long watermark;
>>>
>>>   	/*
>>> +	 * Watermarks for order-0 must be met for compaction.
>>> +	 * During the migration, copies of pages need to be
>>> +	 * allocated and for a short time, so the footprint is higher.
>>>   	 * order == -1 is expected when compacting via
>>> -	 * /proc/sys/vm/compact_memory
>>> +	 * /proc/sys/vm/compact_memory.
>>>   	 */
>>> -	if (order == -1)
>>> -		return COMPACT_CONTINUE;
>>> +	watermark = low_wmark_pages(zone) +
>>> +		((order == -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL<<  order));
>>>
>>> -	/*
>>> -	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
>>> -	 * This is because during migration, copies of pages need to be
>>> -	 * allocated and for a short time, the footprint is higher
>>> -	 */
>>> -	watermark = low_wmark_pages(zone) + (2UL<<  order);
>>>   	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>>>   		return COMPACT_SKIPPED;
>>>
>>> +	if (order == -1)
>>> +		return COMPACT_CONTINUE;
>>> +
>>>   	/*
>>>   	 * fragmentation index determines if allocation failures are due to
>>>   	 * low memory or external fragmentation
>> Is this patch meaningless?
>> I really think this patch is useful when the zone is nearly full.
>>
> Code wise the patch is fine. One reason why it fell off my radar is
> because you mangled the comments for no apparent reason. Specifically,
> after your patch is applied the code looks like this
>
>          /*
>           * Watermarks for order-0 must be met for compaction.
>           * During the migration, copies of pages need to be
>           * allocated and for a short time, so the footprint is higher.
>           * order == -1 is expected when compacting via
>           * /proc/sys/vm/compact_memory.
>           */
>          watermark = low_wmark_pages(zone) +
>                  ((order == -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL<<  order));
"order == -1" first appears here.
>          if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>                  return COMPACT_SKIPPED;
>
>          if (order == -1)
>                  return COMPACT_CONTINUE;
>
> The comment about "order == -1" is no longer with the code it refers
If I keep the comment here, someone may wonder why the `order == -1` 
firstly appears above.

I just want to keep the comment where it firstly appears. Don't you 
think it's right?

> to. I did not get at the time why the patch was not
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 899d956..c96139a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -479,13 +479,6 @@ unsigned long compaction_suitable(struct zone *zone, int order)
>   	unsigned long watermark;
>
>   	/*
> -	 * order == -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> -	 */
> -	if (order == -1)
> -		return COMPACT_CONTINUE;
> -
> -	/*
>   	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
>   	 * This is because during migration, copies of pages need to be
>   	 * allocated and for a short time, the footprint is higher
> @@ -495,6 +488,13 @@ unsigned long compaction_suitable(struct zone *zone, int order)
>   		return COMPACT_SKIPPED;
>
>   	/*
> +	 * order == -1 is expected when compacting via
> +	 * /proc/sys/vm/compact_memory
> +	 */
> +	if (order == -1)
> +		return COMPACT_CONTINUE;
> +
> +	/*
>   	 * fragmentation index determines if allocation failures are due to
>   	 * low memory or external fragmentation
>   	 *
>
> Later I for about this patch in the midst of other bug investigations.
>
> The changelog was also a bit rough but as the change should be fairly
> straight forward, it did not concern me as much.
>
thanks. I will improve the log.

Huang Shijie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
