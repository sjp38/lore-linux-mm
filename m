Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E7A4690008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:01:38 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so5335272pad.11
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:01:38 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id gh6si6479142pac.73.2014.10.30.05.01.37
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 05:01:37 -0700 (PDT)
Date: Thu, 30 Oct 2014 12:01:27 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC V5 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <20141030120127.GC32589@arm.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Rob Herring' <robherring2@gmail.com>, 'Joe Perches' <joe@perches.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Wed, Oct 29, 2014 at 05:52:00AM +0000, Wang, Yalin wrote:
> This patch add bitrev.h file to support rbit instruction,
> so that we can do bitrev operation by hardware.
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm64/Kconfig              |  1 +
>  arch/arm64/include/asm/bitrev.h | 28 ++++++++++++++++++++++++++++
>  2 files changed, 29 insertions(+)
>  create mode 100644 arch/arm64/include/asm/bitrev.h
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 9532f8d..b1ec1dd 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -35,6 +35,7 @@ config ARM64
>  	select HANDLE_DOMAIN_IRQ
>  	select HARDIRQS_SW_RESEND
>  	select HAVE_ARCH_AUDITSYSCALL
> +	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_TRACEHOOK
> diff --git a/arch/arm64/include/asm/bitrev.h b/arch/arm64/include/asm/bitrev.h
> new file mode 100644
> index 0000000..292a5de
> --- /dev/null
> +++ b/arch/arm64/include/asm/bitrev.h
> @@ -0,0 +1,28 @@
> +#ifndef __ASM_ARM64_BITREV_H
> +#define __ASM_ARM64_BITREV_H
> +
> +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
> +{
> +	if (__builtin_constant_p(x)) {
> +		x = (x >> 16) | (x << 16);
> +		x = ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
> +		x = ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
> +		x = ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
> +		return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);

Shouldn't this part be in the generic code?

> +	}
> +	__asm__ ("rbit %w0, %w1" : "=r" (x) : "r" (x));

You can write this more neatly as:

  asm ("rbit %w0, %w0" : "+r" (x));

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
