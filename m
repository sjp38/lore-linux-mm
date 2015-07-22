Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 589D56B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 11:49:47 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so69644102pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:49:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o5si4721674pdl.184.2015.07.22.08.49.46
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 08:49:46 -0700 (PDT)
Date: Wed, 22 Jul 2015 16:49:41 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 4/5] arm64: add KASAN support
Message-ID: <20150722154941.GE16627@e104818-lin.cambridge.arm.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-5-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437561037-31995-5-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 22, 2015 at 01:30:36PM +0300, Andrey Ryabinin wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 318175f..61ebb7c 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -46,6 +46,7 @@ config ARM64
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
> +	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
> @@ -122,6 +123,22 @@ config GENERIC_CSUM
>  config GENERIC_CALIBRATE_DELAY
>  	def_bool y
>  
> +config KASAN_SHADOW_OFFSET
> +	hex
> +	depends on KASAN
> +	default 0xdfff200000000000 if ARM64_VA_BITS_48
> +	default 0xdffffc8000000000 if ARM64_VA_BITS_42
> +	default 0xdfffff9000000000 if ARM64_VA_BITS_39
> +	help
> +	  This value used to address to corresponding shadow address

"This value is used to map an address to the corresponding shadow
address..." (unless you meant something else but the above doesn't read
well).

> +	  by the following formula:
> +	      shadow_addr = (address >> 3) + KASAN_SHADOW_OFFSET;
> +
> +	  (1 << 61) shadow addresses - [KASAN_SHADOW_OFFSET,KASAN_SHADOW_END]
> +	  cover all 64-bits of virtual addresses. So KASAN_SHADOW_OFFSET
> +	  should satisfy the following equation:
> +	      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)

I think we should generate KASAN_SHADOW_OFFSET in the Makefile directly
using some awk snippet/script (we are going to get a 47-bit VA as well
with 16KB page configuration):

---------8<-----------------
#!/bin/awk -f

BEGIN {
	# 32-bit arithmetics
	va_bits = ARGV[1] - 32
	va_start = and(0xffffffff, lshift(0xffffffff, va_bits))
	shadow_end = va_start + lshift(1, va_bits - 3)
	shadow_offset = shadow_end - lshift(1, 64 - 3 - 32)
	printf("0x%x00000000\n", shadow_offset)
}
-------8<-----------------


Otherwise the code looks fine.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
