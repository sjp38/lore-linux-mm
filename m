Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7857E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:51:35 -0400 (EDT)
Received: by wegp1 with SMTP id p1so75664026weg.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:51:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si2141269wib.51.2015.03.20.00.51.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 00:51:34 -0700 (PDT)
Message-ID: <550BD183.5020005@suse.cz>
Date: Fri, 20 Mar 2015 08:51:31 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm/compaction: initialize compaction information
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com> <550A8BA9.9040005@suse.cz> <550A8E31.4040304@lge.com> <550A9086.3080508@suse.cz> <550B5CD1.5010306@lge.com>
In-Reply-To: <550B5CD1.5010306@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/20/2015 12:33 AM, Gioh Kim wrote:
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 8c0d945..827ec06 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -1587,8 +1587,10 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>>>                    INIT_LIST_HEAD(&cc->freepages);
>>>                    INIT_LIST_HEAD(&cc->migratepages);
>>>
>>> -               if (cc->order == -1 || !compaction_deferred(zone, cc->order))
>>> +               if (cc->order == -1 || !compaction_deferred(zone, cc->order)) {
>>> +                       __reset_isolation_suitable(zone);
>>
>> This will also trigger reset when called from kswapd through compact_pgdat() and
>> !compaction_deferred() is true.
>> The reset should be restricted to cc->order == -1 which only happens from /proc
>> trigger.
>>
>>>                            compact_zone(zone, cc);
>>> +               }
>>>
>>>                    if (cc->order > 0) {
>>>                            if (zone_watermark_ok(zone, cc->order,
>>>
>>
>>
>
> I've not been familiar with compaction code.
> I think cc->order is -1 only if __compact_pgdat is called via /proc.

Yes that's what I meant.

> This is ugly but I don't have better solution.
> Do you have better idea?

It's not ugly IMHO. There are more tests for -1 like this, e.g. in
compaction_suitable(). Maybe just add some comment such as:

/*
  * When called via /proc/sys/vm/compact_memory make sure we compact
  * the whole zone regardless of cached scanner positions.
  */

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..5b4e255 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1587,6 +1587,9 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>                   INIT_LIST_HEAD(&cc->freepages);
>                   INIT_LIST_HEAD(&cc->migratepages);
>
> +               if (cc->order == -1)
> +                       __reset_isolation_suitable(zone);
> +
>                   if (cc->order == -1 || !compaction_deferred(zone, cc->order))
>                           compact_zone(zone, cc);
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
