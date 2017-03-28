Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBD372806CB
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:48:43 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 133so10517115itu.17
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:48:43 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id t12si2613663ite.96.2017.03.28.02.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:48:43 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id 190so12333973itm.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:48:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328065033.15966-2-takahiro.akashi@linaro.org>
References: <20170328064831.15894-1-takahiro.akashi@linaro.org> <20170328065033.15966-2-takahiro.akashi@linaro.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 28 Mar 2017 10:48:42 +0100
Message-ID: <CAKv+Gu-3tEu8LYv-jzn3G+LNcBff6fzPLF38nszx_botgD6_NA@mail.gmail.com>
Subject: Re: [PATCH v34 02/14] memblock: add memblock_cap_memory_range()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, James Morse <james.morse@arm.com>, Geoff Levand <geoff@infradead.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Dave Young <dyoung@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Pratyush Anand <panand@redhat.com>, Sameer Goel <sgoel@codeaurora.org>, David Woodhouse <dwmw2@infradead.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 28 March 2017 at 07:50, AKASHI Takahiro <takahiro.akashi@linaro.org> wrote:
> Add memblock_cap_memory_range() which will remove all the memblock regions
> except the memory range specified in the arguments. In addition, rework is
> done on memblock_mem_limit_remove_map() to re-implement it using
> memblock_cap_memory_range().
>
> This function, like memblock_mem_limit_remove_map(), will not remove
> memblocks with MEMMAP_NOMAP attribute as they may be mapped and accessed
> later as "device memory."
> See the commit a571d4eb55d8 ("mm/memblock.c: add new infrastructure to
> address the mem limit issue").
>
> This function is used, in a succeeding patch in the series of arm64 kdump
> suuport, to limit the range of usable memory, or System RAM, on crash dump
> kernel.
> (Please note that "mem=" parameter is of little use for this purpose.)
>
> Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
> Reviewed-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Dennis Chen <dennis.chen@arm.com>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 44 +++++++++++++++++++++++++++++---------------
>  2 files changed, 30 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index e82daffcfc44..4ce24a376262 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -336,6 +336,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> +void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  int memblock_is_map_memory(phys_addr_t addr);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 2f4ca8104ea4..b049c9b2dba8 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1543,11 +1543,37 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>                               (phys_addr_t)ULLONG_MAX);
>  }
>
> +void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> +{
> +       int start_rgn, end_rgn;
> +       int i, ret;
> +
> +       if (!size)
> +               return;
> +
> +       ret = memblock_isolate_range(&memblock.memory, base, size,
> +                                               &start_rgn, &end_rgn);
> +       if (ret)
> +               return;
> +
> +       /* remove all the MAP regions */
> +       for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> +               if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +                       memblock_remove_region(&memblock.memory, i);
> +
> +       for (i = start_rgn - 1; i >= 0; i--)
> +               if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +                       memblock_remove_region(&memblock.memory, i);
> +
> +       /* truncate the reserved regions */
> +       memblock_remove_range(&memblock.reserved, 0, base);
> +       memblock_remove_range(&memblock.reserved,
> +                       base + size, (phys_addr_t)ULLONG_MAX);
> +}
> +
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  {
> -       struct memblock_type *type = &memblock.memory;
>         phys_addr_t max_addr;
> -       int i, ret, start_rgn, end_rgn;
>
>         if (!limit)
>                 return;
> @@ -1558,19 +1584,7 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>         if (max_addr == (phys_addr_t)ULLONG_MAX)
>                 return;
>
> -       ret = memblock_isolate_range(type, max_addr, (phys_addr_t)ULLONG_MAX,
> -                               &start_rgn, &end_rgn);
> -       if (ret)
> -               return;
> -
> -       /* remove all the MAP regions above the limit */
> -       for (i = end_rgn - 1; i >= start_rgn; i--) {
> -               if (!memblock_is_nomap(&type->regions[i]))
> -                       memblock_remove_region(type, i);
> -       }
> -       /* truncate the reserved regions */
> -       memblock_remove_range(&memblock.reserved, max_addr,
> -                             (phys_addr_t)ULLONG_MAX);
> +       memblock_cap_memory_range(0, max_addr);
>  }
>
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
> --
> 2.11.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
