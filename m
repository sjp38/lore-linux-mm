Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78B9D6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 11:08:02 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y68so2482841qka.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 08:08:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z130sor3428123qka.2.2017.08.31.08.08.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 08:08:00 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
 <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz>
 <20170831014048.GA24271@js1304-P5Q-DELUXE>
 <ac4c6a09-7697-ae98-907e-75fb26346352@suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <f791c5d1-efe3-e0ec-9683-fe05f9137978@redhat.com>
Date: Thu, 31 Aug 2017 11:07:57 -0400
MIME-Version: 1.0
In-Reply-To: <ac4c6a09-7697-ae98-907e-75fb26346352@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Kees Cook <keescook@chromium.org>

On 08/31/2017 07:32 AM, Vlastimil Babka wrote:
> On 08/31/2017 03:40 AM, Joonsoo Kim wrote:
>> On Tue, Aug 29, 2017 at 11:16:18AM +0200, Vlastimil Babka wrote:
>>> On 08/24/2017 08:36 AM, js1304@gmail.com wrote:
>>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>>
>>>> 0. History
>>>>
>>>> This patchset is the follow-up of the discussion about the
>>>> "Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
>>>> is needed.
>>>>
>>>
>>> [...]
>>>
>>>>
>>>> [1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com
>>>> [2]: https://lkml.org/lkml/2014/10/15/623
>>>> [3]: http://www.spinics.net/lists/linux-mm/msg100562.html
>>>>
>>>> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>> The previous version has introduced ZONE_CMA, so I would think switching
>>> to ZONE_MOVABLE is enough to drop previous reviews. Perhaps most of the
>>> code involved is basically the same, though?
>>
>> Yes, most of the code involved is the same. I considered to drop
>> previous review tags but most of the code and concept is the same so I
>> decide to keep review tags. I should mention it in cover-letter but I
>> forgot to mention it. Sorry about that.
>>
>>> Anyway I checked the current patch and did some basic tests with qemu,
>>> so you can keep my ack.
>>
>> Thanks!
>>
>>>
>>> BTW, if we dropped NR_FREE_CMA_PAGES, could we also drop MIGRATE_CMA and
>>> related hooks? Is that counter really that useful as it works right now?
>>> It will decrease both by CMA allocations (which has to be explicitly
>>> freed) and by movable allocations (which can be migrated). What if only
>>> CMA alloc/release touched it?
>>
>> I think that NR_FREE_CMA_PAGES would not be as useful as previous. We
>> can remove it.
>>
>> However, removing MIGRATE_CMA has a problem. There is an usecase to
>> check if the page comes from the CMA area or not. See
>> check_page_span() in mm/usercopy.c. I can implement it differently by
>> iterating whole CMA area and finding the match, but I'm not sure it's
>> performance effect. I guess that it would be marginal.
> 
> +CC Kees Cook
> 
> Hmm, seems like this check is to make sure we don't copy from/to parts
> of kernel memory we're not supposed to? Then I believe checking that
> pages are in ZONE_MOVABLE should then give the same guarantees as
> MIGRATE_CMA.
> 

The check is to make sure we are copying only to a single page unless
that page is allocated with __GFP_COMP. CMA needs extra checks since
its allocations have nothing to do with compound page. Checking
ZONE_MOVABLE might cause us to miss some cases of copying to vanilla
ZONE_MOVABLE pages.

> BTW the comment says "Reject if range is entirely either Reserved or
> CMA" but the code does the opposite thing. I assume the comment is wrong?
> 

Yes, I think that needs clarification.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
