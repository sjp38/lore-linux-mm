Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 146646B0011
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 02:56:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m3so13056684ioe.17
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 23:56:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a193sor6220314ioe.202.2018.04.01.23.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 23:56:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522636236-12625-2-git-send-email-hejianet@gmail.com>
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com> <1522636236-12625-2-git-send-email-hejianet@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 2 Apr 2018 08:55:59 +0200
Message-ID: <CAKv+Gu96_sC1Q6-w4O-AXFZzNnH1WoGwJfqvSR+Q_k_bZbrUGg@mail.gmail.com>
Subject: Re: [PATCH v5 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm and arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, Grygorii Strashko <grygorii.strashko@linaro.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On 2 April 2018 at 04:30, Jia He <hejianet@gmail.com> wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic bug. So Daniel Vacek reverted it later.
>
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
>
> On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines.
>
> And as verified by Eugeniu Rosca, arm can benifit from commit
> b92df1de5d28. So remain the memblock_next_valid_pfn on arm{,64} and move
> the related codes to arm64 arch directory.
>
> Suggested-by: Daniel Vacek <neelx@redhat.com>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>

Hello Jia,

Apologies for chiming in late.

If we are going to rearchitect this, I'd rather we change the loop in
memmap_init_zone() so that we skip to the next valid PFN directly
rather than skipping to the last invalid PFN so that the pfn++ in the
for () results in the next value. Can we replace the pfn++ there with
a function calls that defaults to 'return pfn + 1', but does the skip
for architectures that implement it?


> ---
>  arch/arm/include/asm/page.h   |  2 ++
>  arch/arm/mm/init.c            | 31 ++++++++++++++++++++++++++++++-
>  arch/arm64/include/asm/page.h |  2 ++
>  arch/arm64/mm/init.c          | 31 ++++++++++++++++++++++++++++++-
>  include/linux/mmzone.h        |  1 +
>  mm/page_alloc.c               |  4 +++-
>  6 files changed, 68 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
> index 4355f0e..489875c 100644
> --- a/arch/arm/include/asm/page.h
> +++ b/arch/arm/include/asm/page.h
> @@ -158,6 +158,8 @@ typedef struct page *pgtable_t;
>
>  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>  extern int pfn_valid(unsigned long);
> +extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
> +#define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn) - 1)
>  #endif
>
>  #include <asm/memory.h>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index a1f11a7..0fb85ca 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -198,7 +198,36 @@ int pfn_valid(unsigned long pfn)
>         return memblock_is_map_memory(__pfn_to_phys(pfn));
>  }
>  EXPORT_SYMBOL(pfn_valid);
> -#endif
> +
> +/* HAVE_MEMBLOCK is always enabled on arm */
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;
> +       unsigned int right = type->cnt;
> +       unsigned int mid, left = 0;
> +       phys_addr_t addr = PFN_PHYS(++pfn);
> +
> +       do {
> +               mid = (right + left) / 2;
> +
> +               if (addr < type->regions[mid].base)
> +                       right = mid;
> +               else if (addr >= (type->regions[mid].base +
> +                                 type->regions[mid].size))
> +                       left = mid + 1;
> +               else {
> +                       /* addr is within the region, so pfn is valid */
> +                       return pfn;
> +               }
> +       } while (left < right);
> +
> +       if (right == type->cnt)
> +               return -1UL;
> +       else
> +               return PHYS_PFN(type->regions[right].base);
> +}
> +EXPORT_SYMBOL(memblock_next_valid_pfn);
> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>
>  #ifndef CONFIG_SPARSEMEM
>  static void __init arm_memory_present(void)
> diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
> index 60d02c8..e57d3f2 100644
> --- a/arch/arm64/include/asm/page.h
> +++ b/arch/arm64/include/asm/page.h
> @@ -39,6 +39,8 @@ typedef struct page *pgtable_t;
>
>  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>  extern int pfn_valid(unsigned long);
> +extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
> +#define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn) - 1)
>  #endif
>
>  #include <asm/memory.h>
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 00e7b90..13e43ff 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -290,7 +290,36 @@ int pfn_valid(unsigned long pfn)
>         return memblock_is_map_memory(pfn << PAGE_SHIFT);
>  }
>  EXPORT_SYMBOL(pfn_valid);
> -#endif
> +
> +/* HAVE_MEMBLOCK is always enabled on arm64 */
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;
> +       unsigned int right = type->cnt;
> +       unsigned int mid, left = 0;
> +       phys_addr_t addr = PFN_PHYS(++pfn);
> +
> +       do {
> +               mid = (right + left) / 2;
> +
> +               if (addr < type->regions[mid].base)
> +                       right = mid;
> +               else if (addr >= (type->regions[mid].base +
> +                                 type->regions[mid].size))
> +                       left = mid + 1;
> +               else {
> +                       /* addr is within the region, so pfn is valid */
> +                       return pfn;
> +               }
> +       } while (left < right);
> +
> +       if (right == type->cnt)
> +               return -1UL;
> +       else
> +               return PHYS_PFN(type->regions[right].base);
> +}
> +EXPORT_SYMBOL(memblock_next_valid_pfn);
> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>
>  #ifndef CONFIG_SPARSEMEM
>  static void __init arm64_memory_present(void)
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d797716..f9c0c46 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1245,6 +1245,7 @@ static inline int pfn_valid(unsigned long pfn)
>                 return 0;
>         return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>  }
> +#define skip_to_last_invalid_pfn(pfn) (pfn)
>  #endif
>
>  static inline int pfn_present(unsigned long pfn)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c19f5ac..30f7d76 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5483,8 +5483,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                 if (context != MEMMAP_EARLY)
>                         goto not_early;
>
> -               if (!early_pfn_valid(pfn))
> +               if (!early_pfn_valid(pfn)) {
> +                       pfn = skip_to_last_invalid_pfn(pfn);
>                         continue;
> +               }
>                 if (!early_pfn_in_nid(pfn, nid))
>                         continue;
>                 if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
> --
> 2.7.4
>
