Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B6C6790008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:26:46 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gq15so4305772lab.29
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:26:46 -0700 (PDT)
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com. [209.85.217.174])
        by mx.google.com with ESMTPS id zk2si11813260lbb.51.2014.10.30.05.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 05:26:43 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id z11so2257770lbi.33
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:26:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141030120127.GC32589@arm.com>
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
	<20141030120127.GC32589@arm.com>
Date: Thu, 30 Oct 2014 13:26:42 +0100
Message-ID: <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
Subject: Re: [RFC V5 3/3] arm64:add bitrev.h file to support rbit instruction
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joe Perches <joe@perches.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 30 October 2014 13:01, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Oct 29, 2014 at 05:52:00AM +0000, Wang, Yalin wrote:
>> This patch add bitrev.h file to support rbit instruction,
>> so that we can do bitrev operation by hardware.
>> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
>> ---
>>  arch/arm64/Kconfig              |  1 +
>>  arch/arm64/include/asm/bitrev.h | 28 ++++++++++++++++++++++++++++
>>  2 files changed, 29 insertions(+)
>>  create mode 100644 arch/arm64/include/asm/bitrev.h
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 9532f8d..b1ec1dd 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -35,6 +35,7 @@ config ARM64
>>       select HANDLE_DOMAIN_IRQ
>>       select HARDIRQS_SW_RESEND
>>       select HAVE_ARCH_AUDITSYSCALL
>> +     select HAVE_ARCH_BITREVERSE
>>       select HAVE_ARCH_JUMP_LABEL
>>       select HAVE_ARCH_KGDB
>>       select HAVE_ARCH_TRACEHOOK
>> diff --git a/arch/arm64/include/asm/bitrev.h b/arch/arm64/include/asm/bitrev.h
>> new file mode 100644
>> index 0000000..292a5de
>> --- /dev/null
>> +++ b/arch/arm64/include/asm/bitrev.h
>> @@ -0,0 +1,28 @@
>> +#ifndef __ASM_ARM64_BITREV_H
>> +#define __ASM_ARM64_BITREV_H
>> +
>> +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
>> +{
>> +     if (__builtin_constant_p(x)) {
>> +             x = (x >> 16) | (x << 16);
>> +             x = ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
>> +             x = ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
>> +             x = ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
>> +             return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);
>
> Shouldn't this part be in the generic code?
>
>> +     }
>> +     __asm__ ("rbit %w0, %w1" : "=r" (x) : "r" (x));
>
> You can write this more neatly as:
>
>   asm ("rbit %w0, %w0" : "+r" (x));
>

This forces GCC to use the same register as input and output, which
doesn't necessarily result in the fastest code. (e.g., if the
un-bitrev()'ed value is reused again afterwards).
On the other hand, the original notation does allow GCC to use the
same register, but doesn't force it to, so I prefer the original one.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
