Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 803316B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 17:03:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so2533504oih.3
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 14:03:09 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id t199si828285oih.21.2017.09.01.14.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 14:03:08 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id f99so6850233ioi.3
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 14:03:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ac4c6a09-7697-ae98-907e-75fb26346352@suse.cz>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
 <adae04f0-73f4-7772-d056-9ed13122af0e@suse.cz> <20170831014048.GA24271@js1304-P5Q-DELUXE>
 <ac4c6a09-7697-ae98-907e-75fb26346352@suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 1 Sep 2017 14:03:06 -0700
Message-ID: <CAGXu5jKmA=cULZfNw4tN5=rwZ4-y2kxaia4Zc5d3t7X5dkmT3Q@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@lge.com

On Thu, Aug 31, 2017 at 4:32 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
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

Yeah, as Laura said, the idea is to make sure that a copy doesn't
exceed the bounds of the allocation (and that means a single page when
not __GFP_COMP nor CMA nor Reserved).

The trouble with this check, which I'd like see fixed, is that there
are portions of the kernel that make separate adjacent page
allocations and then copy across individual allocations in a single
usercopy. It's not clear to me if that is fixable just by adding
__GFP_COMP or not, though.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
