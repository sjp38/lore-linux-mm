Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 62D626B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:39:46 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id tp5so6814737ieb.5
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:39:46 -0800 (PST)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id kz1si344129igb.41.2014.02.13.19.39.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 19:39:45 -0800 (PST)
Received: by mail-ie0-f174.google.com with SMTP id tp5so6814732ieb.5
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:39:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52FCEE74.9010602@redhat.com>
References: <000001cf2865$0aa2c0c0$1fe84240$%yang@samsung.com>
	<52FCEE74.9010602@redhat.com>
Date: Fri, 14 Feb 2014 11:39:45 +0800
Message-ID: <CAL1ERfPhWbKRGr50Jq61gJ90zYhpMFN+T1tPNxJm0e1n31mcag@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/vmscan: restore sc->gfp_mask after promoting it to __GFP_HIGHMEM
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Feb 14, 2014 at 12:10 AM, Rik van Riel <riel@redhat.com> wrote:
> On 02/12/2014 09:39 PM, Weijie Yang wrote:
>
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2298,14 +2298,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>>       unsigned long nr_soft_reclaimed;
>>       unsigned long nr_soft_scanned;
>>       bool aborted_reclaim = false;
>> +     bool promoted_mask = false;
>>
>>       /*
>>        * If the number of buffer_heads in the machine exceeds the maximum
>>        * allowed level, force direct reclaim to scan the highmem zone as
>>        * highmem pages could be pinning lowmem pages storing buffer_heads
>>        */
>> -     if (buffer_heads_over_limit)
>> +     if (buffer_heads_over_limit) {
>
> It took me a minute to figure out why you are doing things this way,
> so maybe this could use a comment, or maybe it could be done in a
> simpler way, by simply saving and restoring the original mask?
>                 orig_mask = sc->gfp_mask;

Yes, you are right. This simpler way is better. I will turn to it in
V2 resend patch.

Thanks!

>> +             promoted_mask = !(sc->gfp_mask & __GFP_HIGHMEM);
>>               sc->gfp_mask |= __GFP_HIGHMEM;
>> +     }
>>
>>       for_each_zone_zonelist_nodemask(zone, z, zonelist,
>>                                       gfp_zone(sc->gfp_mask), sc->nodemask) {
>> @@ -2354,6 +2357,9 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>>               shrink_zone(zone, sc);
>>       }
>>
>> +     if (promoted_mask)
>                 sc->gfp_mask = orig_mask;
>
>> +             sc->gfp_mask &= ~__GFP_HIGHMEM;
>> +
>>       return aborted_reclaim;
>>  }
>>
>>
>
>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
