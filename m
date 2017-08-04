Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7572028038D
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 20:14:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 41so2132828iop.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 17:14:51 -0700 (PDT)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id 41si295328ioq.6.2017.08.03.17.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 17:14:50 -0700 (PDT)
Received: by mail-it0-x22e.google.com with SMTP id 77so1016772itj.1
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 17:14:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1501795433-982645-12-git-send-email-pasha.tatashin@oracle.com>
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com> <1501795433-982645-12-git-send-email-pasha.tatashin@oracle.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 4 Aug 2017 01:14:49 +0100
Message-ID: <CAKv+Gu_V_T56qPS=c3kq73TLFwqpP4YHtggCrjGRmgW1itq3pQ@mail.gmail.com>
Subject: Re: [v5 11/15] arm64/kasan: explicitly zero kasan shadow memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, willy@infradead.org, mhocko@kernel.org

(+ arm64 maintainers)

Hi Pavel,

On 3 August 2017 at 22:23, Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> To optimize the performance of struct page initialization,
> vmemmap_populate() will no longer zero memory.
>
> We must explicitly zero the memory that is allocated by vmemmap_populate()
> for kasan, as this memory does not go through struct page initialization
> path.
>
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> ---
>  arch/arm64/mm/kasan_init.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 81f03959a4ab..a57104bc54b8 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -135,6 +135,31 @@ static void __init clear_pgds(unsigned long start,
>                 set_pgd(pgd_offset_k(start), __pgd(0));
>  }
>
> +/*
> + * Memory that was allocated by vmemmap_populate is not zeroed, so we must
> + * zero it here explicitly.
> + */
> +static void
> +zero_vemmap_populated_memory(void)

Typo here: vemmap -> vmemmap

> +{
> +       struct memblock_region *reg;
> +       u64 start, end;
> +
> +       for_each_memblock(memory, reg) {
> +               start = __phys_to_virt(reg->base);
> +               end = __phys_to_virt(reg->base + reg->size);
> +
> +               if (start >= end)

How would this ever be true? And why is it a stop condition?

> +                       break;
> +

Are you missing a couple of kasan_mem_to_shadow() calls here? I can't
believe your intention is to wipe all of DRAM.

> +               memset((void *)start, 0, end - start);
> +       }
> +
> +       start = (u64)kasan_mem_to_shadow(_stext);
> +       end = (u64)kasan_mem_to_shadow(_end);
> +       memset((void *)start, 0, end - start);
> +}
> +
>  void __init kasan_init(void)
>  {
>         u64 kimg_shadow_start, kimg_shadow_end;
> @@ -205,6 +230,13 @@ void __init kasan_init(void)
>                         pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
>
>         memset(kasan_zero_page, 0, PAGE_SIZE);
> +
> +       /*
> +        * vmemmap_populate does not zero the memory, so we need to zero it
> +        * explicitly
> +        */
> +       zero_vemmap_populated_memory();
> +
>         cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>
>         /* At this point kasan is fully initialized. Enable error messages */
> --
> 2.13.4
>

KASAN uses vmemmap_populate as a convenience: kasan has nothing to do
with vmemmap, but the function already existed and happened to do what
KASAN requires.

Given that that will no longer be the case, it would be far better to
stop using vmemmap_populate altogether, and clone it into a KASAN
specific version (with an appropriate name) with the zeroing folded
into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
