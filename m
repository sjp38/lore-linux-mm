Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id D68506B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:34:07 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id p10so8635428wes.2
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:34:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr10si17726199wib.21.2014.08.11.05.34.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 05:34:06 -0700 (PDT)
Message-ID: <53E8B83D.1070004@suse.cz>
Date: Mon, 11 Aug 2014 14:34:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone allocation
 policy
References: <1404893588-21371-1-git-send-email-mgorman@suse.de> <1404893588-21371-7-git-send-email-mgorman@suse.de> <53E4EC53.1050904@suse.cz> <20140811121241.GD7970@suse.de>
In-Reply-To: <20140811121241.GD7970@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On 08/11/2014 02:12 PM, Mel Gorman wrote:
> On Fri, Aug 08, 2014 at 05:27:15PM +0200, Vlastimil Babka wrote:
>> On 07/09/2014 10:13 AM, Mel Gorman wrote:
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -1604,6 +1604,9 @@ again:
>>>   	}
>>>
>>>   	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
>>
>> This can underflow zero, right?
>>
>
> Yes, because of per-cpu accounting drift.

I meant mainly because of order > 0.

>>> +	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
>>
>> AFAICS, zone_page_state will correct negative values to zero only for
>> CONFIG_SMP. Won't this check be broken on !CONFIG_SMP?
>>
>
> On !CONFIG_SMP how can there be per-cpu accounting drift that would make
> that counter negative?

Well original code used "if (zone_page_state(zone, NR_ALLOC_BATCH) <= 
0)" elsewhere, that you are replacing with zone_is_fair_depleted check. 
I assumed it's because it can get negative due to order > 0. I might 
have not looked thoroughly enough but it seems to me there's nothing 
that would prevent it, such as skipping a zone because its remaining 
batch is lower than 1 << order.
So I think the check should be "<= 0" to be safe.

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
