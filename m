Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03FBC6B026F
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 05:28:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t78-v6so6721774pfa.8
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 02:28:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7-v6sor2433445plo.52.2018.07.06.02.27.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 02:27:59 -0700 (PDT)
Subject: Re: [PATCH v10 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
References: <1530864860-7671-1-git-send-email-hejianet@gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <bd0a48b6-0a1d-79cc-0985-16a808aaf824@gmail.com>
Date: Fri, 6 Jul 2018 17:27:37 +0800
MIME-Version: 1.0
In-Reply-To: <1530864860-7671-1-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <jia.he@hxt-semitech.com>

Sorry for my mistake, I have to resend this set because I missed some
important maillists. Please ignore this thread.
Terribly sorry about it

Cheersi 1/4 ?
Jia

On 7/6/2018 4:14 PM, Jia He Wrote:
> From: Jia He <jia.he@hxt-semitech.com>
> 
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic bug. So Daniel Vacek reverted it later.
> 
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
> 
> More from what Daniel said:
> "On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines."
> 
> About the performance consideration:
> As said by James in b92df1de5,
> "I have tested this patch on a virtual model of a Samurai CPU with a
> sparse memory map.  The kernel boot time drops from 109 to 62 seconds."
> Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64.
> 
> Besides we can remain memblock_next_valid_pfn, there is still some room
> for improvement. After this set, I can see the time overhead of memmap_init
> is reduced from 27956us to 13537us in my armv8a server(QDF2400 with 96G
> memory, pagesize 64k). I believe arm server will benefit more if memory is
> larger than TBs
> 
> Patch 1 introduces new config to make codes more generic
> Patch 2 remains the memblock_next_valid_pfn on arm and arm64,this patch is
> 	originated from b92df1de5
> Patch 3 optimizes the memblock_next_valid_pfn()
> Patch 4~6 optimizes the early_pfn_valid()
> 
> Changelog:
> V10:- move codes to memblock.c, refine the performance consideration
> V9: - rebase to mmotm master, refine the log description. No major changes
> V8: - introduce new config and move generic code to early_pfn.h
>     - optimize memblock_next_valid_pfn as suggested by Matthew Wilcox
> V7: - fix i386 compilation error. refine the commit description
> V6: - simplify the codes, move arm/arm64 common codes to one file.
>     - refine patches as suggested by Danial Vacek and Ard Biesheuvel
> V5: - further refining as suggested by Danial Vacek. Make codes
>       arm/arm64 more arch specific
> V4: - refine patches as suggested by Danial Vacek and Wei Yang
>     - optimized on arm besides arm64
> V3: - fix 2 issues reported by kbuild test robot
> V2: - rebase to mmotm latest
>     - remain memblock_next_valid_pfn on arm64
>     - refine memblock_search_pfn_regions and pfn_valid_region
> 
> Jia He (6):
>   arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
>   mm: page_alloc: remain memblock_next_valid_pfn() on arm/arm64
>   mm: page_alloc: reduce unnecessary binary search in
>     memblock_next_valid_pfn()
>   mm/memblock: introduce memblock_search_pfn_regions()
>   mm/memblock: introduce pfn_valid_region()
>   mm: page_alloc: reduce unnecessary binary search in early_pfn_valid()
> 
>  arch/arm/Kconfig         |  4 +++
>  arch/arm64/Kconfig       |  4 +++
>  include/linux/memblock.h |  2 ++
>  include/linux/mmzone.h   | 16 +++++++++
>  mm/Kconfig               |  3 ++
>  mm/memblock.c            | 84 ++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c          |  5 ++-
>  7 files changed, 117 insertions(+), 1 deletion(-)
> 

-- 
Cheers,
Jia
