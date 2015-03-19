Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 902D06B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 05:02:02 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so111730416wib.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 02:02:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6si8016618wiw.114.2015.03.19.02.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 02:02:00 -0700 (PDT)
Message-ID: <550A9086.3080508@suse.cz>
Date: Thu, 19 Mar 2015 10:01:58 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm/compaction: initialize compaction information
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com> <550A8BA9.9040005@suse.cz> <550A8E31.4040304@lge.com>
In-Reply-To: <550A8E31.4040304@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/19/2015 09:52 AM, Gioh Kim wrote:
> 
> 
> 2015-03-19 i??i?? 5:41i?? Vlastimil Babka i?'(e??) i?' e,?:
>> On 03/19/2015 06:30 AM, Gioh Kim wrote:
>>
>> The code below this comment already does the initialization if the cached values
>> are outside zone boundaries (e.g. due to not being initialized). So if I go
>> through what your __reset_isolation_suitable(zone) call possibly fixes:
>>
>> - the code below comment should take care of zone->compact_cached_migrate_pfn
>> and zone->compact_cached_free_pfn.
>> - the value of zone->compact_blockskip_flush shouldn't affect whether compaction
>> is done.
>> - the state of pageblock_skip bits shouldn't matter for compaction via
>> /proc/sys... as that sets ignore_skip_hint = true
>>
>> It might be perhaps possible that the cached scanner positions are close to
>> meeting and compaction occurs but doesn't process much. That would be also true
>> if both were zero, but at least on my x86 system, lowest zone's start_pfn is 1
>> so that would be detected and corrected. Maybe it is zero on yours though? (ARM?).
> 
> YES, it is. As comment above, my platform is based on ARM.

Ah, I see.

> zone's start_pfn is 0.

OK, good to know that's possible. In that case it's clear that the proper
initialization doesn't happen, and __compact_finished() decides that scanners
have already met at pfn 0.

>>
>> So in any case, the problem should be identified in more detail so we know the
>> fix is not accidental. It could be also worthwile to always reset scanner
>> positions when doing a /proc triggered compaction, so it's not depending on what
>> happened before.
>>
> 
> Excuse my poor english.
> I cannot catch exactly what you want.
> Is this what you want? This resets the position if compaction is started via /proc.

Yes that's right, but..

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..827ec06 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1587,8 +1587,10 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>                  INIT_LIST_HEAD(&cc->freepages);
>                  INIT_LIST_HEAD(&cc->migratepages);
> 
> -               if (cc->order == -1 || !compaction_deferred(zone, cc->order))
> +               if (cc->order == -1 || !compaction_deferred(zone, cc->order)) {
> +                       __reset_isolation_suitable(zone);

This will also trigger reset when called from kswapd through compact_pgdat() and
!compaction_deferred() is true.
The reset should be restricted to cc->order == -1 which only happens from /proc
trigger.

>                          compact_zone(zone, cc);
> +               }
> 
>                  if (cc->order > 0) {
>                          if (zone_watermark_ok(zone, cc->order,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
