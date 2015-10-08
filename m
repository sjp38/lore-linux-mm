Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 979C46B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 06:36:10 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so19238680wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 03:36:10 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id az7si52245036wjb.136.2015.10.08.03.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 03:36:09 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so21779801wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 03:36:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
	<20151007100411.GG3069@e104818-lin.cambridge.arm.com>
Date: Thu, 8 Oct 2015 13:36:09 +0300
Message-ID: <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, LKML <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Mark Salter <msalter@redhat.com>, linux-efi@vger.kernel.org

2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
>> As usual patches available in git
>>       git://github.com/aryabinin/linux.git kasan/arm64v6
>>
>> Changes since v5:
>>  - Rebase on top of 4.3-rc1
>>  - Fixed EFI boot.
>>  - Updated Doc/features/KASAN.
>
> I tried to merge these patches (apart from the x86 one which is already
> merged) but it still doesn't boot on Juno as an EFI application.
>

4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
regions")
It introduced sort() call in efi_get_virtmap().
sort() is generic kernel function and it's instrumented, so we crash
when KASAN tries to access shadow in sort().

[+CC efi some guys]

Comment in drivers/firmware/efi/libstub/Makefile says that EFI stub
executes with MMU disabled:
    # The stub may be linked into the kernel proper or into a separate
boot binary,
    # but in either case, it executes before the kernel does (with MMU
disabled) so
    # things like ftrace and stack-protector are likely to cause trouble if left
    # enabled, even if doing so doesn't break the build.

But in arch/arm64/kernel/efi-entry.S:
* We arrive here from the EFI boot manager with:
*
*    * CPU in little-endian mode
*    * MMU on with identity-mapped RAM

So is MMU enabled in ARM64 efi-stub?
If yes, we could solve this issue by mapping KASAN early shadow in efi stub.

> --
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
