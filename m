Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0056B0009
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 20:45:46 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m6-v6so4007569pln.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 17:45:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s1-v6sor2494668plr.79.2018.03.15.17.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 17:45:44 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
References: <20180313224240.25295-1-neelx@redhat.com>
 <049a38e2-c446-85f4-656c-91d4e5bb1c0d@gmail.com>
 <CACjP9X_01nuv86WeETjOFgNYQkvUFaE8089yX9fgq9uB8zpPTQ@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <b391f698-5619-4946-bac7-5ba39628335e@gmail.com>
Date: Fri, 16 Mar 2018 08:45:32 +0800
MIME-Version: 1.0
In-Reply-To: <CACjP9X_01nuv86WeETjOFgNYQkvUFaE8089yX9fgq9uB8zpPTQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Sudeep Holla <sudeep.holla@arm.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>



On 3/15/2018 11:39 PM, Daniel Vacek Wrote:
> On Thu, Mar 15, 2018 at 3:08 PM, Jia He <hejianet@gmail.com> wrote:
>> Hi Daniel
>>
>>
>>
>> On 3/14/2018 6:42 AM, Daniel Vacek Wrote:
>>> On some architectures (reported on arm64) commit 864b75f9d6b01
>>> ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
>>> causes a boot hang. This patch fixes the hang making sure the alignment
>>> never steps back.
>>>
>>> Link:
>>> http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
>>> Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock
>>> alignment")
>>> Signed-off-by: Daniel Vacek <neelx@redhat.com>
>>> Tested-by: Sudeep Holla <sudeep.holla@arm.com>
>>> Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Paul Burton <paul.burton@imgtec.com>
>>> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: <stable@vger.kernel.org>
>>> ---
>>>    mm/page_alloc.c | 7 ++++++-
>>>    1 file changed, 6 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 3d974cb2a1a1..e033a6895c6f 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size,
>>> int nid, unsigned long zone,
>>>                           * is not. move_freepages_block() can shift ahead
>>> of
>>>                           * the valid region but still depends on correct
>>> page
>>>                           * metadata.
>>> +                        * Also make sure we never step back.
>>>                           */
>>> -                       pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>>> +                       unsigned long next_pfn;
>>> +
>>> +                       next_pfn = (memblock_next_valid_pfn(pfn, end_pfn)
>>> &
>>>                                          ~(pageblock_nr_pages-1)) - 1;
>>> +                       if (next_pfn > pfn)
>>> +                               pfn = next_pfn;
>> It didn't resolve the booting hang issue in my arm64 server.
>> what if memblock_next_valid_pfn(pfn, end_pfn) is 32 and pageblock_nr_pages
>> is 8196?
>> Thus, next_pfn will be (unsigned long)-1 and be larger than pfn.
>> So still there is an infinite loop here.
> Hi Jia,
>
> Yeah, looks like another uncovered case. Noone reported this so far.
> Anyways upstream reverted all this for now and we're discussing the
> right approach here.
>
> In any case thanks for this report. Can you share something like below
> from your machine?
sure.
[A A A  0.000000] NUMA: Faking a node at [mem 
0x0000000000000000-0x00000017ffffffff]
[A A A  0.000000] NUMA: NODE_DATA [mem 0x17ffffcb80-0x17ffffffff]
[A A A  0.000000] Zone ranges:
[A A A  0.000000]A A  DMA32A A A  [mem 0x0000000000200000-0x00000000ffffffff]
[A A A  0.000000]A A  NormalA A  [mem 0x0000000100000000-0x00000017ffffffff]
[A A A  0.000000] Movable zone start for each node
[A A A  0.000000] Early memory node ranges
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000000200000-0x000000000021ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000000820000-0x000000000307ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000003080000-0x000000000308ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000003090000-0x00000000031fffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000003200000-0x00000000033fffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000003410000-0x000000000563ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000005640000-0x000000000567ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000005680000-0x00000000056dffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x00000000056e0000-0x00000000086fffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008700000-0x000000000871ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008720000-0x000000000894ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008950000-0x0000000008baffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008bb0000-0x0000000008bcffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008bd0000-0x0000000008c4ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008c50000-0x0000000008e2ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008e30000-0x0000000008e4ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008e50000-0x0000000008fcffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000008fd0000-0x000000000910ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000009110000-0x00000000092effff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x00000000092f0000-0x000000000930ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000009310000-0x000000000963ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000009640000-0x000000000e61ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000000e620000-0x000000000e64ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000000e650000-0x000000000fffffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x0000000010800000-0x0000000017feffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000001c000000-0x000000001c00ffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000001c010000-0x000000001c7fffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000001c810000-0x000000007efbffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000007efc0000-0x000000007efdffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000007efe0000-0x000000007efeffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000007eff0000-0x000000007effffff]
[A A A  0.000000]A A  nodeA A  0: [mem 0x000000007f000000-0x00000017ffffffff]
[A A A  0.000000] Initmem setup node 0 [mem 
0x0000000000200000-0x00000017ffffffff]

-- 
Cheers,
Jia
