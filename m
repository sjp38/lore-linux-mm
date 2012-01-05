Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D0BA36B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 06:20:13 -0500 (EST)
Message-ID: <4F0587B0.8000006@freescale.com>
Date: Thu, 5 Jan 2012 19:21:20 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/compaction : check the watermark when cc->order is
 -1
References: <1325312323-13565-1-git-send-email-b32955@freescale.com> <20120105105308.GF28031@suse.de>
In-Reply-To: <20120105105308.GF28031@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org


> On Sat, Dec 31, 2011 at 02:18:43PM +0800, Huang Shijie wrote:
>> We get cc->order is -1 when user echos to /proc/sys/vm/compact_memory.
>> In this case, we should check that if we have enough pages for
>> the compaction in the zone.
>>
>> If we do not check this, in our MX6Q board(arm), i ever observed
>> COMPACT_CLUSTER_MAX pages were compaction failed in per migrate_pages().
>> That's mean we can not alloc any pages by the free scanner in the zone.
>>
>> This patch checks the watermark to avoid this problem.
>>
>> Signed-off-by: Huang Shijie<b32955@freescale.com>
>> ---
>>   mm/compaction.c |   14 ++++++++++++--
>>   1 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 899d956..0f12cc9 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -442,8 +442,13 @@ static int compact_finished(struct zone *zone,
>>   	 * order == -1 is expected when compacting via
>>   	 * /proc/sys/vm/compact_memory
>>   	 */
>> -	if (cc->order == -1)
>> +	if (cc->order == -1) {
>> +		/* Check if we have enough pages now. */
>> +		watermark = low_wmark_pages(zone) + COMPACT_CLUSTER_MAX * 2;
>> +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>> +			return COMPACT_SKIPPED;
>>   		return COMPACT_CONTINUE;
>> +	}
>>
> We already do the watermark check in compact_finished. Would moving
> the cc->order == -1 check below it not be functionally equivalent? This


Now, I think these code for compact_finish() is not needed. These lines 
can be removed.

The watermark check in the compaction_suitable() is enough to avoid the 
problem.


Huang Shijie

> would be preferable to duplicating the code for the watermark check.
>
> Same for the second check in your patch.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
