Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E76A6B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:39:07 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n67-v6so3776477otn.0
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:39:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l125sor1922801oia.233.2018.03.15.08.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 08:39:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <049a38e2-c446-85f4-656c-91d4e5bb1c0d@gmail.com>
References: <20180313224240.25295-1-neelx@redhat.com> <049a38e2-c446-85f4-656c-91d4e5bb1c0d@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 15 Mar 2018 16:39:04 +0100
Message-ID: <CACjP9X_01nuv86WeETjOFgNYQkvUFaE8089yX9fgq9uB8zpPTQ@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Sudeep Holla <sudeep.holla@arm.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Thu, Mar 15, 2018 at 3:08 PM, Jia He <hejianet@gmail.com> wrote:
> Hi Daniel
>
>
>
> On 3/14/2018 6:42 AM, Daniel Vacek Wrote:
>>
>> On some architectures (reported on arm64) commit 864b75f9d6b01
>> ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
>> causes a boot hang. This patch fixes the hang making sure the alignment
>> never steps back.
>>
>> Link:
>> http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
>> Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock
>> alignment")
>> Signed-off-by: Daniel Vacek <neelx@redhat.com>
>> Tested-by: Sudeep Holla <sudeep.holla@arm.com>
>> Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Paul Burton <paul.burton@imgtec.com>
>> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: <stable@vger.kernel.org>
>> ---
>>   mm/page_alloc.c | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3d974cb2a1a1..e033a6895c6f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size,
>> int nid, unsigned long zone,
>>                          * is not. move_freepages_block() can shift ahead
>> of
>>                          * the valid region but still depends on correct
>> page
>>                          * metadata.
>> +                        * Also make sure we never step back.
>>                          */
>> -                       pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>> +                       unsigned long next_pfn;
>> +
>> +                       next_pfn = (memblock_next_valid_pfn(pfn, end_pfn)
>> &
>>                                         ~(pageblock_nr_pages-1)) - 1;
>> +                       if (next_pfn > pfn)
>> +                               pfn = next_pfn;
>
> It didn't resolve the booting hang issue in my arm64 server.
> what if memblock_next_valid_pfn(pfn, end_pfn) is 32 and pageblock_nr_pages
> is 8196?
> Thus, next_pfn will be (unsigned long)-1 and be larger than pfn.
> So still there is an infinite loop here.

Hi Jia,

Yeah, looks like another uncovered case. Noone reported this so far.
Anyways upstream reverted all this for now and we're discussing the
right approach here.

In any case thanks for this report. Can you share something like below
from your machine?

   Booting Linux on physical CPU 0x0000000000 [0x410fd034]
   Linux version 4.16.0-rc5-00004-gfc6eabbbf8ef-dirty (ard@dogfood) ...
   Machine model: Socionext Developer Box
   earlycon: pl11 at MMIO 0x000000002a400000 (options '')
   bootconsole [pl11] enabled
   efi: Getting EFI parameters from FDT:
   efi: EFI v2.70 by Linaro
   efi:  SMBIOS 3.0=0xff580000  ESRT=0xf9948198  MEMATTR=0xf83b1a98
RNG=0xff7ac898
   random: fast init done
   efi: seeding entropy pool
   esrt: Reserving ESRT space from 0x00000000f9948198 to 0x00000000f99481d0.
   cma: Reserved 16 MiB at 0x00000000fd800000
   NUMA: No NUMA configuration found
   NUMA: Faking a node at [mem 0x0000000000000000-0x0000000fffffffff]
   NUMA: NODE_DATA [mem 0xffffd8d80-0xffffda87f]
   Zone ranges:
     DMA32    [mem 0x0000000080000000-0x00000000ffffffff]
     Normal   [mem 0x0000000100000000-0x0000000fffffffff]
   Movable zone start for each node
   Early memory node ranges
     node   0: [mem 0x0000000080000000-0x00000000febeffff]
     node   0: [mem 0x00000000febf0000-0x00000000fefcffff]
     node   0: [mem 0x00000000fefd0000-0x00000000ff43ffff]
     node   0: [mem 0x00000000ff440000-0x00000000ff7affff]
     node   0: [mem 0x00000000ff7b0000-0x00000000ffffffff]
     node   0: [mem 0x0000000880000000-0x0000000fffffffff]
   Initmem setup node 0 [mem 0x0000000080000000-0x0000000fffffffff]


Thank you.

--nX

> Cheers,
> Jia He
>>
>>   #endif
>>                         continue;
>>                 }
>
>
> --
> Cheers,
> Jia
>
