Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 087226B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:59:29 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so77844794igb.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:59:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id lq5si6449827igb.63.2015.07.27.08.59.28
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 08:59:28 -0700 (PDT)
Date: Mon, 27 Jul 2015 16:59:23 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v4 5/7] arm64: add KASAN support
Message-ID: <20150727155922.GB350@e104818-lin.cambridge.arm.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-6-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437756119-12817-6-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Fri, Jul 24, 2015 at 07:41:57PM +0300, Andrey Ryabinin wrote:
> diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
> index 4d2a925..2cacf55 100644
> --- a/arch/arm64/Makefile
> +++ b/arch/arm64/Makefile
> @@ -40,6 +40,12 @@ else
>  TEXT_OFFSET := 0x00080000
>  endif
>  
> +# KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - 3)) - (1 << 61)
> +KASAN_SHADOW_OFFSET := $(shell printf "0x%x\n" $$(( \
> +			(-1 << $(CONFIG_ARM64_VA_BITS)) \
> +			+ (1 << ($(CONFIG_ARM64_VA_BITS) - 3)) \
> +			- (1 << (64 - 3)) )) )

Does this work with any POSIX shell? Do we always have a 64-bit type?
As I wasn't sure about this, I suggested awk (or perl).

> +static void __init clear_pgds(unsigned long start,
> +			unsigned long end)
> +{
> +	/*
> +	 * Remove references to kasan page tables from
> +	 * swapper_pg_dir. pgd_clear() can't be used
> +	 * here because it's nop on 2,3-level pagetable setups
> +	 */
> +	for (; start && start < end; start += PGDIR_SIZE)
> +		set_pgd(pgd_offset_k(start), __pgd(0));
> +}

I don't think we need the "start" check, just "start < end". Do you
expect a start == 0 (or overflow)?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
