Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD696B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 07:06:57 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so52230888pab.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 04:06:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ns1si65632394pbc.169.2015.10.08.04.06.56
        for <linux-mm@kvack.org>;
        Thu, 08 Oct 2015 04:06:56 -0700 (PDT)
Date: Thu, 8 Oct 2015 12:06:33 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
Message-ID: <20151008110633.GB7275@leverpostej>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
 <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, LKML <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Salter <msalter@redhat.com>, linux-efi@vger.kernel.org, leif.lindholm@arm.com

On Thu, Oct 08, 2015 at 01:36:09PM +0300, Andrey Ryabinin wrote:
> 2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> > On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
> >> As usual patches available in git
> >>       git://github.com/aryabinin/linux.git kasan/arm64v6
> >>
> >> Changes since v5:
> >>  - Rebase on top of 4.3-rc1
> >>  - Fixed EFI boot.
> >>  - Updated Doc/features/KASAN.
> >
> > I tried to merge these patches (apart from the x86 one which is already
> > merged) but it still doesn't boot on Juno as an EFI application.
> >
> 
> 4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
> ("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
> regions")
> It introduced sort() call in efi_get_virtmap().
> sort() is generic kernel function and it's instrumented, so we crash
> when KASAN tries to access shadow in sort().
> 
> [+CC efi some guys]
> 
> Comment in drivers/firmware/efi/libstub/Makefile says that EFI stub
> executes with MMU disabled:
>     # The stub may be linked into the kernel proper or into a separate
> boot binary,
>     # but in either case, it executes before the kernel does (with MMU
> disabled) so
>     # things like ftrace and stack-protector are likely to cause trouble if left
>     # enabled, even if doing so doesn't break the build.
> 
> But in arch/arm64/kernel/efi-entry.S:
> * We arrive here from the EFI boot manager with:
> *
> *    * CPU in little-endian mode
> *    * MMU on with identity-mapped RAM
> 
> So is MMU enabled in ARM64 efi-stub?

The stub is executed as an EFI application, which means that the MMU is
on, and the page tables are an idmap owned by the EFI implementation.

> If yes, we could solve this issue by mapping KASAN early shadow in efi stub.

As the page tables are owned by the implemenation and not the kernel, we
cannot alter them (at least not until we've called ExitBootServices(),
which happens relatively late).

Can we not build the stub without ASAN protections?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
