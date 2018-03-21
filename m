Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E298F6B0024
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:14:16 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b201-v6so2421338oih.2
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:14:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o15-v6sor1491652otj.327.2018.03.21.03.14.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 03:14:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1521619796-3846-2-git-send-email-hejianet@gmail.com>
References: <1521619796-3846-1-git-send-email-hejianet@gmail.com> <1521619796-3846-2-git-send-email-hejianet@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Wed, 21 Mar 2018 11:14:14 +0100
Message-ID: <CACjP9X92M3izDD-1s1vY6n6Hx3mxqNqeM4f+T3RNnBo8kjP4Qg@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: page_alloc: reduce unnecessary binary search in memblock_next_valid_pfn()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Wed, Mar 21, 2018 at 9:09 AM, Jia He <hejianet@gmail.com> wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But there is
> still some room for improvement. E.g. if pfn and pfn+1 are in the same
> memblock region, we can simply pfn++ instead of doing the binary search
> in memblock_next_valid_pfn.

There is a revert-mm-page_alloc-skip-over-regions-of-invalid-pfns-where-possible.patch
in -mm reverting b92df1de5d289c0b as it is fundamentally wrong by
design causing system panics on some machines with rare but still
valid mappings. Basically it skips valid pfns which are outside of
usable memory ranges (outside of memblock memory regions).

So I guess if you want to optimize boot up time, you would have to
come up with different solution in memmap_init_zone. Most likely using
mem sections instead of memblock. Sorry.

--nX

> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  include/linux/memblock.h |  3 +--
>  mm/memblock.c            | 23 +++++++++++++++++++----
>  mm/page_alloc.c          |  3 ++-
>  3 files changed, 22 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index b7aa3ff..9471db4 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -203,8 +203,7 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>              i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>
> -unsigned long memblock_next_valid_pfn(unsigned long pfn);
> -
> +unsigned long memblock_next_valid_pfn(unsigned long pfn, int *last_idx);
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index c87924d..a9e8da4 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1133,13 +1133,26 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>
> -unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
> +                                                       int *last_idx)
>  {
>         struct memblock_type *type = &memblock.memory;
>         unsigned int right = type->cnt;
>         unsigned int mid, left = 0;
> +       unsigned long start_pfn, end_pfn;
>         phys_addr_t addr = PFN_PHYS(++pfn);
>
> +       /* fast path, return pfh+1 if next pfn is in the same region */
> +       if (*last_idx != -1) {
> +               start_pfn = PFN_DOWN(type->regions[*last_idx].base);
> +               end_pfn = PFN_DOWN(type->regions[*last_idx].base +
> +                               type->regions[*last_idx].size);
> +
> +               if (pfn < end_pfn && pfn > start_pfn)
> +                       return pfn;
> +       }
> +
> +       /* slow path, do the binary searching */
>         do {
>                 mid = (right + left) / 2;
>
> @@ -1149,15 +1162,17 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>                                   type->regions[mid].size))
>                         left = mid + 1;
>                 else {
> -                       /* addr is within the region, so pfn is valid */
> +                       *last_idx = mid;
>                         return pfn;
>                 }
>         } while (left < right);
>
>         if (right == type->cnt)
>                 return -1UL;
> -       else
> -               return PHYS_PFN(type->regions[right].base);
> +
> +       *last_idx = right;
> +
> +       return PHYS_PFN(type->regions[*last_idx].base);
>  }
>
>  static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3899209..f28c62c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5456,6 +5456,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>         unsigned long end_pfn = start_pfn + size;
>         pg_data_t *pgdat = NODE_DATA(nid);
>         unsigned long pfn;
> +       int idx = -1;
>         unsigned long nr_initialised = 0;
>         struct page *page;
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> @@ -5487,7 +5488,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                          * end_pfn), such that we hit a valid pfn (or end_pfn)
>                          * on our next iteration of the loop.
>                          */
> -                       pfn = memblock_next_valid_pfn(pfn) - 1;
> +                       pfn = memblock_next_valid_pfn(pfn, &idx) - 1;
>  #endif
>                         continue;
>                 }
> --
> 2.7.4
>
