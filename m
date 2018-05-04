Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEC56B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:08:43 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id e95-v6so15487830otb.15
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:08:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6-v6sor8930349otp.105.2018.05.04.09.08.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 09:08:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <05b0fcf2-7670-101e-d4ab-1f656ff6b02f@gmail.com>
References: <1523431317-30612-1-git-send-email-hejianet@gmail.com> <05b0fcf2-7670-101e-d4ab-1f656ff6b02f@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Fri, 4 May 2018 18:08:40 +0200
Message-ID: <CACjP9X8bHmrxmd7ZPcfQq6Eq0Mzwmt0saOR3Ph53gp2n-dcKBQ@mail.gmail.com>
Subject: Re: [PATCH v8 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, May 4, 2018 at 4:45 AM, Jia He <hejianet@gmail.com> wrote:
> Ping
>
> Sorry if I am a little bit verbose, but it can speedup the arm64 booting
> time indeed.

I'm wondering, ain't simple enabling of config
DEFERRED_STRUCT_PAGE_INIT provide even better speed-up? If that is the
case then it seems like this series is not needed at all, right?
I am not sure why is this config optional. It looks like it could be
enabled by default or even unconditionally considering that with
commit c9e97a1997fb ("mm: initialize pages on demand during boot") the
deferred code is statically disabled after all the pages are
initialized.

--nX

>
> --
> Cheers,
> Jia
>
>
> On 4/11/2018 3:21 PM, Jia He Wrote:
>>
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") tried to optimize the loop in memmap_init_zone(). But
>> there is still some room for improvement.
>>
>> Patch 1 introduce new config to make codes more generic
>> Patch 2 remain the memblock_next_valid_pfn on arm and arm64
>> Patch 3 optimizes the memblock_next_valid_pfn()
>> Patch 4~6 optimizes the early_pfn_valid()
>>
>> As for the performance improvement, after this set, I can see the time
>> overhead of memmap_init() is reduced from 41313 us to 24389 us in my
>> armv8a server(QDF2400 with 96G memory).
>>
>> Without this patchset:
>> [  117.113677] before memmap_init
>> [  117.118195] after  memmap_init
>>>>>
>>>>> memmap_init takes 4518 us
>>
>> [  117.121446] before memmap_init
>> [  117.154992] after  memmap_init
>>>>>
>>>>> memmap_init takes 33546 us
>>
>> [  117.158241] before memmap_init
>> [  117.161490] after  memmap_init
>>>>>
>>>>> memmap_init takes 3249 us
>>>>> totally takes 41313 us
>>
>> With this patchset:
>> [  123.222962] before memmap_init
>> [  123.226819] after  memmap_init
>>>>>
>>>>> memmap_init takes 3857
>>
>> [  123.230070] before memmap_init
>> [  123.247354] after  memmap_init
>>>>>
>>>>> memmap_init takes 17284
>>
>> [  123.250604] before memmap_init
>> [  123.253852] after  memmap_init
>>>>>
>>>>> memmap_init takes 3248
>>>>> totally takes 24389 us
>>
>> Attached the memblock region information in my server.
>> [   86.956758] Zone ranges:
>> [   86.959452]   DMA      [mem 0x0000000000200000-0x00000000ffffffff]
>> [   86.966041]   Normal   [mem 0x0000000100000000-0x00000017ffffffff]
>> [   86.972631] Movable zone start for each node
>> [   86.977179] Early memory node ranges
>> [   86.980985]   node   0: [mem 0x0000000000200000-0x000000000021ffff]
>> [   86.987666]   node   0: [mem 0x0000000000820000-0x000000000307ffff]
>> [   86.994348]   node   0: [mem 0x0000000003080000-0x000000000308ffff]
>> [   87.001029]   node   0: [mem 0x0000000003090000-0x00000000031fffff]
>> [   87.007710]   node   0: [mem 0x0000000003200000-0x00000000033fffff]
>> [   87.014392]   node   0: [mem 0x0000000003410000-0x000000000563ffff]
>> [   87.021073]   node   0: [mem 0x0000000005640000-0x000000000567ffff]
>> [   87.027754]   node   0: [mem 0x0000000005680000-0x00000000056dffff]
>> [   87.034435]   node   0: [mem 0x00000000056e0000-0x00000000086fffff]
>> [   87.041117]   node   0: [mem 0x0000000008700000-0x000000000871ffff]
>> [   87.047798]   node   0: [mem 0x0000000008720000-0x000000000894ffff]
>> [   87.054479]   node   0: [mem 0x0000000008950000-0x0000000008baffff]
>> [   87.061161]   node   0: [mem 0x0000000008bb0000-0x0000000008bcffff]
>> [   87.067842]   node   0: [mem 0x0000000008bd0000-0x0000000008c4ffff]
>> [   87.074524]   node   0: [mem 0x0000000008c50000-0x0000000008e2ffff]
>> [   87.081205]   node   0: [mem 0x0000000008e30000-0x0000000008e4ffff]
>> [   87.087886]   node   0: [mem 0x0000000008e50000-0x0000000008fcffff]
>> [   87.094568]   node   0: [mem 0x0000000008fd0000-0x000000000910ffff]
>> [   87.101249]   node   0: [mem 0x0000000009110000-0x00000000092effff]
>> [   87.107930]   node   0: [mem 0x00000000092f0000-0x000000000930ffff]
>> [   87.114612]   node   0: [mem 0x0000000009310000-0x000000000963ffff]
>> [   87.121293]   node   0: [mem 0x0000000009640000-0x000000000e61ffff]
>> [   87.127975]   node   0: [mem 0x000000000e620000-0x000000000e64ffff]
>> [   87.134657]   node   0: [mem 0x000000000e650000-0x000000000fffffff]
>> [   87.141338]   node   0: [mem 0x0000000010800000-0x0000000017feffff]
>> [   87.148019]   node   0: [mem 0x000000001c000000-0x000000001c00ffff]
>> [   87.154701]   node   0: [mem 0x000000001c010000-0x000000001c7fffff]
>> [   87.161383]   node   0: [mem 0x000000001c810000-0x000000007efbffff]
>> [   87.168064]   node   0: [mem 0x000000007efc0000-0x000000007efdffff]
>> [   87.174746]   node   0: [mem 0x000000007efe0000-0x000000007efeffff]
>> [   87.181427]   node   0: [mem 0x000000007eff0000-0x000000007effffff]
>> [   87.188108]   node   0: [mem 0x000000007f000000-0x00000017ffffffff]
>> [   87.194791] Initmem setup node 0 [mem
>> 0x0000000000200000-0x00000017ffffffff]
>>
>> Changelog:
>> V8: - introduce new config and move generic code to early_pfn.h
>>      - optimize memblock_next_valid_pfn as suggested by Matthew Wilcox
>> V7: - fix i386 compilation error. refine the commit description
>> V6: - simplify the codes, move arm/arm64 common codes to one file.
>>      - refine patches as suggested by Danial Vacek and Ard Biesheuvel
>> V5: - further refining as suggested by Danial Vacek. Make codes
>>        arm/arm64 more arch specific
>> V4: - refine patches as suggested by Danial Vacek and Wei Yang
>>      - optimized on arm besides arm64
>> V3: - fix 2 issues reported by kbuild test robot
>> V2: - rebase to mmotm latest
>>      - remain memblock_next_valid_pfn on arm64
>>      - refine memblock_search_pfn_regions and pfn_valid_region
>>
>> Jia He (6):
>>    arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
>>    mm: page_alloc: remain memblock_next_valid_pfn() on arm/arm64
>>    arm: arm64: page_alloc: reduce unnecessary binary search in
>>      memblock_next_valid_pfn()
>>    mm/memblock: introduce memblock_search_pfn_regions()
>>    arm: arm64: introduce pfn_valid_region()
>>    mm: page_alloc: reduce unnecessary binary search in early_pfn_valid()
>>
>>   arch/arm/Kconfig          |  4 +++
>>   arch/arm/mm/init.c        |  1 +
>>   arch/arm64/Kconfig        |  4 +++
>>   arch/arm64/mm/init.c      |  1 +
>>   include/linux/early_pfn.h | 79
>> +++++++++++++++++++++++++++++++++++++++++++++++
>>   include/linux/memblock.h  |  2 ++
>>   include/linux/mmzone.h    | 18 ++++++++++-
>>   mm/Kconfig                |  3 ++
>>   mm/memblock.c             |  9 ++++++
>>   mm/page_alloc.c           |  5 ++-
>>   10 files changed, 124 insertions(+), 2 deletions(-)
>>   create mode 100644 include/linux/early_pfn.h
>>
>
