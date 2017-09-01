Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9436F6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 03:31:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p37so2987698wrc.5
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 00:31:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si1520221wmi.106.2017.09.01.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 00:31:46 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
 <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz>
 <20170831014048.GA24271@js1304-P5Q-DELUXE>
 <ac4c6a09-7697-ae98-907e-75fb26346352@suse.cz>
 <f791c5d1-efe3-e0ec-9683-fe05f9137978@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <61029e90-2835-8195-3682-442d469fed39@suse.cz>
Date: Fri, 1 Sep 2017 09:31:43 +0200
MIME-Version: 1.0
In-Reply-To: <f791c5d1-efe3-e0ec-9683-fe05f9137978@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Kees Cook <keescook@chromium.org>

On 08/31/2017 05:07 PM, Laura Abbott wrote:
> On 08/31/2017 07:32 AM, Vlastimil Babka wrote:
>> On 08/31/2017 03:40 AM, Joonsoo Kim wrote:
>>> On Tue, Aug 29, 2017 at 11:16:18AM +0200, Vlastimil Babka wrote:
>>>>
>>>> BTW, if we dropped NR_FREE_CMA_PAGES, could we also drop MIGRATE_CMA and
>>>> related hooks? Is that counter really that useful as it works right now?
>>>> It will decrease both by CMA allocations (which has to be explicitly
>>>> freed) and by movable allocations (which can be migrated). What if only
>>>> CMA alloc/release touched it?
>>>
>>> I think that NR_FREE_CMA_PAGES would not be as useful as previous. We
>>> can remove it.
>>>
>>> However, removing MIGRATE_CMA has a problem. There is an usecase to
>>> check if the page comes from the CMA area or not. See
>>> check_page_span() in mm/usercopy.c. I can implement it differently by
>>> iterating whole CMA area and finding the match, but I'm not sure it's
>>> performance effect. I guess that it would be marginal.
>>
>> +CC Kees Cook
>>
>> Hmm, seems like this check is to make sure we don't copy from/to parts
>> of kernel memory we're not supposed to? Then I believe checking that
>> pages are in ZONE_MOVABLE should then give the same guarantees as
>> MIGRATE_CMA.
>>
> 
> The check is to make sure we are copying only to a single page unless
> that page is allocated with __GFP_COMP. CMA needs extra checks since
> its allocations have nothing to do with compound page. Checking
> ZONE_MOVABLE might cause us to miss some cases of copying to vanilla
> ZONE_MOVABLE pages.

How big problem is that? ZONE_MOVABLE should not contain kernel pages,
so from the kernel protection side we are OK? I expect there's another
check somewhere that the pages are not userspace, as that would be
unexpected on a wrong side of copy_to/from_user, no?

Also you can already miss some cases with the is_migrate_cma check,
because pages might be in the CMA pageblocks but not be allocated by CMA
itself - movable pages allocation can fallback here.

>> BTW the comment says "Reject if range is entirely either Reserved or
>> CMA" but the code does the opposite thing. I assume the comment is wrong?
>>
> 
> Yes, I think that needs clarification.
> 
> Thanks,
> Laura
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
