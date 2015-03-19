Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6596B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:52:05 -0400 (EDT)
Received: by ignm3 with SMTP id m3so6820521ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:52:05 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id w10si1531777pas.114.2015.03.19.01.52.03
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 01:52:04 -0700 (PDT)
Message-ID: <550A8E31.4040304@lge.com>
Date: Thu, 19 Mar 2015 17:52:01 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm/compaction: initialize compaction information
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com> <550A8BA9.9040005@suse.cz>
In-Reply-To: <550A8BA9.9040005@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com



2015-03-19 i??i?? 5:41i?? Vlastimil Babka i?'(e??) i?' e,?:
> On 03/19/2015 06:30 AM, Gioh Kim wrote:
>> I tried to start compaction via /proc/sys/vm/compact_memory
>> as soon as I turned on my ARM-based platform.
>> But the compaction didn't start.
>> I found some variables in struct zone are not initalized.
>>
>> I think zone->compact_cached_free_pfn and some cache values for compaction
>> are initalized when the kernel starts compaction, not via
>> /proc/sys/vm/compact_memory.
>> If my guess is correct, an initialization are needed for that case.
>>
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> ---
>>   mm/compaction.c |    8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 8c0d945..944a9cc 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1299,6 +1299,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>>   		__reset_isolation_suitable(zone);
>>
>>   	/*
>> +	 * If this is activated by /proc/sys/vm/compact_memory
>> +	 * and the first try, cached information for compaction is not
>> +	 * initialized.
>> +	 */
>> +	if (cc->order == -1 && zone->compact_cached_free_pfn == 0)
>> +		__reset_isolation_suitable(zone);
>> +
>> +	/*
>>   	 * Setup to move all movable pages to the end of the zone. Used cached
>>   	 * information on where the scanners should start but check that it
>>   	 * is initialised by ensuring the values are within zone boundaries.
>
> The code below this comment already does the initialization if the cached values
> are outside zone boundaries (e.g. due to not being initialized). So if I go
> through what your __reset_isolation_suitable(zone) call possibly fixes:
>
> - the code below comment should take care of zone->compact_cached_migrate_pfn
> and zone->compact_cached_free_pfn.
> - the value of zone->compact_blockskip_flush shouldn't affect whether compaction
> is done.
> - the state of pageblock_skip bits shouldn't matter for compaction via
> /proc/sys... as that sets ignore_skip_hint = true
>
> It might be perhaps possible that the cached scanner positions are close to
> meeting and compaction occurs but doesn't process much. That would be also true
> if both were zero, but at least on my x86 system, lowest zone's start_pfn is 1
> so that would be detected and corrected. Maybe it is zero on yours though? (ARM?).

YES, it is. As comment above, my platform is based on ARM.
zone's start_pfn is 0.

>
> So in any case, the problem should be identified in more detail so we know the
> fix is not accidental. It could be also worthwile to always reset scanner
> positions when doing a /proc triggered compaction, so it's not depending on what
> happened before.
>

Excuse my poor english.
I cannot catch exactly what you want.
Is this what you want? This resets the position if compaction is started via /proc.


diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..827ec06 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1587,8 +1587,10 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
                 INIT_LIST_HEAD(&cc->freepages);
                 INIT_LIST_HEAD(&cc->migratepages);

-               if (cc->order == -1 || !compaction_deferred(zone, cc->order))
+               if (cc->order == -1 || !compaction_deferred(zone, cc->order)) {
+                       __reset_isolation_suitable(zone);
                         compact_zone(zone, cc);
+               }

                 if (cc->order > 0) {
                         if (zone_watermark_ok(zone, cc->order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
