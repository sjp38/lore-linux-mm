Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 567AE2806CB
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:47:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j63so10715750itb.9
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:47:40 -0700 (PDT)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id a16si3742302ioa.47.2017.03.28.02.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:47:39 -0700 (PDT)
Received: by mail-it0-x232.google.com with SMTP id 190so12310716itm.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:47:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328065033.15966-1-takahiro.akashi@linaro.org>
References: <20170328064831.15894-1-takahiro.akashi@linaro.org> <20170328065033.15966-1-takahiro.akashi@linaro.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 28 Mar 2017 10:47:38 +0100
Message-ID: <CAKv+Gu_Siy5ObfLjXKXk3qRKgB+QQ2ZtJtA0b8-qd8j4q5UhtA@mail.gmail.com>
Subject: Re: [PATCH v34 01/14] memblock: add memblock_clear_nomap()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, James Morse <james.morse@arm.com>, Geoff Levand <geoff@infradead.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Dave Young <dyoung@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Pratyush Anand <panand@redhat.com>, Sameer Goel <sgoel@codeaurora.org>, David Woodhouse <dwmw2@infradead.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 28 March 2017 at 07:50, AKASHI Takahiro <takahiro.akashi@linaro.org> wrote:
> This function, with a combination of memblock_mark_nomap(), will be used
> in a later kdump patch for arm64 when it temporarily isolates some range
> of memory from the other memory blocks in order to create a specific
> kernel mapping at boot time.
>
> Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 12 ++++++++++++
>  2 files changed, 13 insertions(+)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index bdfc65af4152..e82daffcfc44 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -93,6 +93,7 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
> +int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
>  ulong choose_memblock_flags(void);
>
>  /* Low level functions */
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 696f06d17c4e..2f4ca8104ea4 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -805,6 +805,18 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
>  }
>
>  /**
> + * memblock_clear_nomap - Clear flag MEMBLOCK_NOMAP for a specified region.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on success, -errno on failure.
> + */
> +int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
> +{
> +       return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
> +}
> +
> +/**
>   * __next_reserved_mem_region - next function for for_each_reserved_region()
>   * @idx: pointer to u64 loop variable
>   * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
> --
> 2.11.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
