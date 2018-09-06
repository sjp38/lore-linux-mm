Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1F3B6B7887
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:24:24 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 20-v6so11254523itb.7
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:24:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3-v6sor2438804iop.330.2018.09.06.04.24.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 04:24:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
References: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 6 Sep 2018 13:24:22 +0200
Message-ID: <CAKv+Gu9u8RcrzSHdgXiqHS9HK1aSrjbPxVUSCP0DT4erAhx0pw@mail.gmail.com>
Subject: Re: [PATCH v11 0/3] remain and optimize memblock_next_valid_pfn on
 arm and arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On 22 August 2018 at 05:07, Jia He <hejianet@gmail.com> wrote:
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

OK so we can summarize the benefits of this series as follows:
- boot time on a virtual model of a Samurai CPU drops from 109 to 62 seconds
- boot time on a QDF2400 arm64 server with 96 GB of RAM drops by ~15
*milliseconds*

Google was not very helpful in figuring out what a Samurai CPU is and
why we should care about the boot time of Linux running on a virtual
model of it, and the 15 ms speedup is not that compelling either.

Apologies to Jia that it took 11 revisions to reach this conclusion,
but in /my/ opinion, tweaking the fragile memblock/pfn handling code
for this reason is totally unjustified, and we're better off
disregarding these patches.





> Patch 1 introduces new config to make codes more generic
> Patch 2 remains the memblock_next_valid_pfn on arm and arm64,this patch is
>         originated from b92df1de5
> Patch 3 optimizes the memblock_next_valid_pfn()
>
> Changelog:
> V11:- drop patch#4-6, refine the codes
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
> Jia He (3):
>   arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
>   mm: page_alloc: remain memblock_next_valid_pfn() on arm/arm64
>   mm: page_alloc: reduce unnecessary binary search in
>     memblock_next_valid_pfn
>
>  arch/arm/Kconfig       |  1 +
>  arch/arm64/Kconfig     |  1 +
>  include/linux/mmzone.h |  9 +++++++++
>  mm/Kconfig             |  3 +++
>  mm/memblock.c          | 51 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c        |  5 ++++-
>  6 files changed, 69 insertions(+), 1 deletion(-)
>
> --
> 1.8.3.1
>
