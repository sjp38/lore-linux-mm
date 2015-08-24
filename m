Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id A3B5B6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:02:54 -0400 (EDT)
Received: by obbhe7 with SMTP id he7so112237834obb.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:02:54 -0700 (PDT)
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com. [209.85.214.181])
        by mx.google.com with ESMTPS id f3si11341509obt.30.2015.08.24.06.02.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 06:02:53 -0700 (PDT)
Received: by obbfr1 with SMTP id fr1so111964233obb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:02:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55D497FC.9060506@gmail.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
	<55AE56DB.4040607@samsung.com>
	<CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
	<55AFD8D0.9020308@samsung.com>
	<CACRpkdaJVRuLTCh585rLEjua2TpnLsALhLdu0ma56TBA=C+EiQ@mail.gmail.com>
	<55D497FC.9060506@gmail.com>
Date: Mon, 24 Aug 2015 15:02:53 +0200
Message-ID: <CACRpkdYL7R+WKfGZwmM7NGqvY8Arc_B3ekbUhkr7VPbQzAdZVg@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Aug 19, 2015 at 4:51 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> On 08/19/2015 03:14 PM, Linus Walleij wrote:

>> Integrator/AP (ARMv5):
>>
>> This one mounted with an ARMv5 ARM926 tile. It boots nicely
>> (but takes forever) with KASan and run all test cases (!) just like
>> for the other platforms but before reaching userspace this happens:
>
> THREAD_SIZE hardcoded in act_mm macro.
>
> This hack should help:
>
> diff --git a/arch/arm/mm/proc-macros.S b/arch/arm/mm/proc-macros.S
> index c671f34..b1765f2 100644
> --- a/arch/arm/mm/proc-macros.S
> +++ b/arch/arm/mm/proc-macros.S
> @@ -32,6 +32,9 @@
>         .macro  act_mm, rd
>         bic     \rd, sp, #8128
>         bic     \rd, \rd, #63
> +#ifdef CONFIG_KASAN
> +       bic     \rd, \rd, #8192
> +#endif
>         ldr     \rd, [\rd, #TI_TASK]
>         ldr     \rd, [\rd, #TSK_ACTIVE_MM]
>         .endm

Yes this work, thanks! I now get to userspace.
Tested-by: Linus Walleij <linus.walleij@linaro.org>

I have compiled Trinity and running some stress on different boards.
The ARMv7 seems to rather die from random nasty stuff from the
syscall or OOM rather than any KASan-detected bugs, but I'll
keep hammering at it a big.

I have some odd patch I'll pass along.

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
