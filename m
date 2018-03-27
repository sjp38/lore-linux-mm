Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1FFA6B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 13:51:57 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id w43-v6so14203447otd.1
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:51:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor670505otf.145.2018.03.27.10.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 10:51:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522033340-6575-6-git-send-email-hejianet@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com> <1522033340-6575-6-git-send-email-hejianet@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Tue, 27 Mar 2018 19:51:56 +0200
Message-ID: <CACjP9X_MNrL_4VdR+oMVb4nAfwAmWrUy-cK88V_i0ft71S2bJA@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] mm: page_alloc: reduce unnecessary binary search
 in early_pfn_valid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Mon, Mar 26, 2018 at 5:02 AM, Jia He <hejianet@gmail.com> wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But there is
> still some room for improvement. E.g. in early_pfn_valid(), if pfn and
> pfn+1 are in the same memblock region, we can record the last returned
> memblock region index and check check pfn++ is still in the same region.
>
> Currently it only improve the performance on arm64 and will have no
> impact on other arches.
>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  arch/x86/include/asm/mmzone_32.h |  2 +-
>  include/linux/mmzone.h           | 12 +++++++++---
>  mm/page_alloc.c                  |  2 +-
>  3 files changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
> index 73d8dd1..329d3ba 100644
> --- a/arch/x86/include/asm/mmzone_32.h
> +++ b/arch/x86/include/asm/mmzone_32.h
> @@ -49,7 +49,7 @@ static inline int pfn_valid(int pfn)
>         return 0;
>  }
>
> -#define early_pfn_valid(pfn)   pfn_valid((pfn))
> +#define early_pfn_valid(pfn, last_region_idx)  pfn_valid((pfn))
>
>  #endif /* CONFIG_DISCONTIGMEM */
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d797716..3a686af 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1267,9 +1267,15 @@ static inline int pfn_present(unsigned long pfn)
>  })
>  #else
>  #define pfn_to_nid(pfn)                (0)
> -#endif
> +#endif /*CONFIG_NUMA*/
> +
> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
> +#define early_pfn_valid(pfn, last_region_idx) \
> +                               pfn_valid_region(pfn, last_region_idx)
> +#else
> +#define early_pfn_valid(pfn, last_region_idx)  pfn_valid(pfn)
> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>
> -#define early_pfn_valid(pfn)   pfn_valid(pfn)
>  void sparse_init(void);
>  #else
>  #define sparse_init()  do {} while (0)
> @@ -1288,7 +1294,7 @@ struct mminit_pfnnid_cache {
>  };
>
>  #ifndef early_pfn_valid
> -#define early_pfn_valid(pfn)   (1)
> +#define early_pfn_valid(pfn, last_region_idx)  (1)
>  #endif
>
>  void memory_present(int nid, unsigned long start, unsigned long end);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0bb0274..debccf3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5484,7 +5484,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                 if (context != MEMMAP_EARLY)
>                         goto not_early;
>
> -               if (!early_pfn_valid(pfn)) {
> +               if (!early_pfn_valid(pfn, &idx)) {
>  #if (defined CONFIG_HAVE_MEMBLOCK) && (defined CONFIG_HAVE_ARCH_PFN_VALID)
>                         /*
>                          * Skip to the pfn preceding the next valid one (or
> --
> 2.7.4
>

Hmm, what about making index global variable instead of changing all
the prototypes? Similar to early_pfnnid_cache for example. Something
like:

#ifdef CONFIG_HAVE_ARCH_PFN_VALID
extern int early_region_idx __meminitdata;
#define early_pfn_valid(pfn) \
                               pfn_valid_region(pfn, &early_region_idx)
#else
#define early_pfn_valid(pfn)  pfn_valid(pfn)
#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/

And move this to arch/arm64/include/asm/page.h ?

--nX
