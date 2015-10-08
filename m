Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 45BDF6B0255
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:07:47 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so35489310wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:07:46 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id e9si54093977wjf.124.2015.10.08.09.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:07:46 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so32232206wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:07:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151008151144.GM17192@e104818-lin.cambridge.arm.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
	<20151007100411.GG3069@e104818-lin.cambridge.arm.com>
	<CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
	<20151008111144.GC7275@leverpostej>
	<56165228.8060201@gmail.com>
	<CAKv+Gu_v7J1BA+xFcowBrW05bRFs=_WFf_HCeCmWgdZVRo0eQw@mail.gmail.com>
	<20151008151144.GM17192@e104818-lin.cambridge.arm.com>
Date: Thu, 8 Oct 2015 19:07:45 +0300
Message-ID: <CAPAsAGxhcRtks40u3O29t=KMKkuLy4Pf8u8TeeBy2f2-MuSf+A@mail.gmail.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Yury <yury.norov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, Mark Salter <msalter@redhat.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Matt Fleming <matt.fleming@intel.com>

2015-10-08 18:11 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> On Thu, Oct 08, 2015 at 02:09:26PM +0200, Ard Biesheuvel wrote:
>> On 8 October 2015 at 13:23, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>> > On 10/08/2015 02:11 PM, Mark Rutland wrote:
>> >> On Thu, Oct 08, 2015 at 01:36:09PM +0300, Andrey Ryabinin wrote:
>> >>> 2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>> >>>> On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
>> >>>>> As usual patches available in git
>> >>>>>       git://github.com/aryabinin/linux.git kasan/arm64v6
>> >>>>>
>> >>>>> Changes since v5:
>> >>>>>  - Rebase on top of 4.3-rc1
>> >>>>>  - Fixed EFI boot.
>> >>>>>  - Updated Doc/features/KASAN.
>> >>>>
>> >>>> I tried to merge these patches (apart from the x86 one which is already
>> >>>> merged) but it still doesn't boot on Juno as an EFI application.
>> >>>>
>> >>>
>> >>> 4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
>> >>> ("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
>> >>> regions")
>> >>> It introduced sort() call in efi_get_virtmap().
>> >>> sort() is generic kernel function and it's instrumented, so we crash
>> >>> when KASAN tries to access shadow in sort().
>> >>
>> >> I believe this is solved by Ard's stub isolation series [1,2], which
>> >> will build a stub-specific copy of sort() and various other functions
>> >> (see the arm-deps in [2]).
>> >>
>> >> So long as the stub is not built with ASAN, that should work.
>> >
>> > Thanks, this should help, as we already build the stub without ASAN instrumentation.
>>
>> Indeed. I did not mention instrumentation in the commit log for those
>> patches, but obviously, something like KASAN instrumentation cannot be
>> tolerated in the stub since it makes assumptions about the memory
>> layout
>
> I'll review your latest EFI stub isolation patches and try Kasan again
> on top (most likely tomorrow).

You'd better wait for v7, because kasan patches will need some adjustment.
Since stub is isolated,  we need to handle memcpy vs __memcpy stuff the same
way as we do in x86. Now we also need to #undef memset/memcpy/memmove in ARM64
(just like this was done for x86).

But instead of spreading these #undef across various headers, I will
make a patch (most likely tomorrow)
which will get rid of these #undefs completely (the idea was described
here: https://lkml.org/lkml/2015/9/29/607)
And I'll will send v7 on top of that patch + Ard's work.


> Thanks.
>
> --
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
