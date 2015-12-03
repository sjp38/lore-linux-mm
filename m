Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BDF966B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 05:55:54 -0500 (EST)
Received: by ioc74 with SMTP id 74so76589003ioc.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:55:54 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id l23si12338257iod.19.2015.12.03.02.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 02:55:54 -0800 (PST)
Received: by igcph11 with SMTP id ph11so8268024igc.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:55:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
	<1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org>
Date: Thu, 3 Dec 2015 11:55:53 +0100
Message-ID: <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
Subject: Re: [PATCH v4 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Leif Lindholm <leif.lindholm@linaro.org>

On 30 November 2015 at 13:28, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> This introduces the MEMBLOCK_NOMAP attribute and the required plumbing
> to make it usable as an indicator that some parts of normal memory
> should not be covered by the kernel direct mapping. It is up to the
> arch to actually honor the attribute when laying out this mapping,
> but the memblock code itself is modified to disregard these regions
> for allocations and other general use.
>
> Cc: linux-mm@kvack.org
> Cc: Alexander Kuleshov <kuleshovmail@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  include/linux/memblock.h |  8 ++++++
>  mm/memblock.c            | 28 ++++++++++++++++++++
>  2 files changed, 36 insertions(+)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 24daf8fc4d7c..fec66f86eeff 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -25,6 +25,7 @@ enum {
>         MEMBLOCK_NONE           = 0x0,  /* No special request */
>         MEMBLOCK_HOTPLUG        = 0x1,  /* hotpluggable region */
>         MEMBLOCK_MIRROR         = 0x2,  /* mirrored region */
> +       MEMBLOCK_NOMAP          = 0x4,  /* don't add to kernel direct mapping */
>  };
>
>  struct memblock_region {
> @@ -82,6 +83,7 @@ bool memblock_overlaps_region(struct memblock_type *type,
>  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> +int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
>  ulong choose_memblock_flags(void);
>
>  /* Low level functions */
> @@ -184,6 +186,11 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
>         return m->flags & MEMBLOCK_MIRROR;
>  }
>
> +static inline bool memblock_is_nomap(struct memblock_region *m)
> +{
> +       return m->flags & MEMBLOCK_NOMAP;
> +}
> +
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
>                             unsigned long  *end_pfn);
> @@ -319,6 +326,7 @@ phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
>  int memblock_is_memory(phys_addr_t addr);
> +int memblock_is_map_memory(phys_addr_t addr);
>  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
>  int memblock_is_reserved(phys_addr_t addr);
>  bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d300f1329814..07ff069fef25 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -822,6 +822,17 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
>         return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
>  }
>
> +/**
> + * memblock_mark_nomap - Mark a memory region with flag MEMBLOCK_NOMAP.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on success, -errno on failure.
> + */
> +int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
> +{
> +       return memblock_setclr_flag(base, size, 1, MEMBLOCK_NOMAP);
> +}
>
>  /**
>   * __next_reserved_mem_region - next function for for_each_reserved_region()
> @@ -913,6 +924,10 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
>                 if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
>                         continue;
>
> +               /* skip nomap memory unless we were asked for it explicitly */
> +               if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
> +                       continue;
> +
>                 if (!type_b) {
>                         if (out_start)
>                                 *out_start = m_start;
> @@ -1022,6 +1037,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>                 if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
>                         continue;
>
> +               /* skip nomap memory unless we were asked for it explicitly */
> +               if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
> +                       continue;
> +
>                 if (!type_b) {
>                         if (out_start)
>                                 *out_start = m_start;
> @@ -1519,6 +1538,15 @@ int __init_memblock memblock_is_memory(phys_addr_t addr)
>         return memblock_search(&memblock.memory, addr) != -1;
>  }
>
> +int __init_memblock memblock_is_map_memory(phys_addr_t addr)
> +{
> +       int i = memblock_search(&memblock.memory, addr);
> +
> +       if (i == -1)
> +               return false;
> +       return !memblock_is_nomap(&memblock.memory.regions[i]);
> +}
> +
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
>                          unsigned long *start_pfn, unsigned long *end_pfn)

May I kindly ask team-mm/Andrew/Alexander to chime in here, and
indicate whether you are ok with this patch going in for 4.5? If so,
could you please provide your ack so the patch can be kept together
with the rest of the series, which depends on it?

I should note that this change should not affect any memblock users
that never set the MEMBLOCK_NOMAP flag, but please, if you see any
issues beyond 'this may conflict with other stuff we have queued for
4.5', please do let me know.

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
