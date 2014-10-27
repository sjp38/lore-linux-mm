Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3743D6B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 06:49:11 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so5418536pdi.17
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:49:10 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id se6si10316928pac.1.2014.10.27.03.49.09
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 03:49:10 -0700 (PDT)
Date: Mon, 27 Oct 2014 10:48:48 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC V3] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <20141027104848.GD8768@arm.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18259@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18259@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>

On Mon, Oct 27, 2014 at 08:02:08AM +0000, Wang, Yalin wrote:
> this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
> so that we can use arm/arm64 rbit instruction to do bitrev operation
> by hardware.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/Kconfig                |  1 +
>  arch/arm/include/asm/bitrev.h   | 28 ++++++++++++++++++++++++++++
>  arch/arm64/Kconfig              |  1 +
>  arch/arm64/include/asm/bitrev.h | 28 ++++++++++++++++++++++++++++
>  include/linux/bitrev.h          |  9 +++++++++
>  lib/Kconfig                     |  9 +++++++++
>  lib/bitrev.c                    |  2 ++
>  7 files changed, 78 insertions(+)
>  create mode 100644 arch/arm/include/asm/bitrev.h
>  create mode 100644 arch/arm64/include/asm/bitrev.h
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 89c4b5c..426cbcc 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -16,6 +16,7 @@ config ARM
>  	select DCACHE_WORD_ACCESS if HAVE_EFFICIENT_UNALIGNED_ACCESS
>  	select GENERIC_ALLOCATOR
>  	select GENERIC_ATOMIC64 if (CPU_V7M || CPU_V6 || !CPU_32v6K || !AEABI)
> +	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
>  	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
>  	select GENERIC_IDLE_POLL_SETUP
>  	select GENERIC_IRQ_PROBE
> diff --git a/arch/arm/include/asm/bitrev.h b/arch/arm/include/asm/bitrev.h
> new file mode 100644
> index 0000000..c21a5f4
> --- /dev/null
> +++ b/arch/arm/include/asm/bitrev.h
> @@ -0,0 +1,28 @@
> +#ifndef __ASM_ARM_BITREV_H
> +#define __ASM_ARM_BITREV_H
> +
> +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
> +{
> +	if (__builtin_constant_p(x)) {
> +		x = (x >> 16) | (x << 16);
> +		x = ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
> +		x = ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
> +		x = ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
> +		return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);
> +	}
> +	__asm__ ("rbit %0, %1" : "=r" (x) : "r" (x));

I think you need to use %w0 and %w1 here, otherwise you bit-reverse the
64-bit register.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
