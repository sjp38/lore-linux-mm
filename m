Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3206B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:01:33 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so18259969igc.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:01:33 -0700 (PDT)
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com. [209.85.213.182])
        by mx.google.com with ESMTPS id c24si32450587ioj.38.2015.10.08.09.01.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:01:32 -0700 (PDT)
Received: by igxx6 with SMTP id x6so16021456igx.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:01:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151008151144.GM17192@e104818-lin.cambridge.arm.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
	<20151007100411.GG3069@e104818-lin.cambridge.arm.com>
	<CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
	<20151008111144.GC7275@leverpostej>
	<56165228.8060201@gmail.com>
	<CAKv+Gu_v7J1BA+xFcowBrW05bRFs=_WFf_HCeCmWgdZVRo0eQw@mail.gmail.com>
	<20151008151144.GM17192@e104818-lin.cambridge.arm.com>
Date: Thu, 8 Oct 2015 18:01:32 +0200
Message-ID: <CAKv+Gu-qn-1SLy6HopaVb1h2Lfp0pXC4sAm0yQum18tsEFw81w@mail.gmail.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Matt Fleming <matt.fleming@intel.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Yury <yury.norov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, Mark Salter <msalter@redhat.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

(+ Matt)

On 8 October 2015 at 17:11, Catalin Marinas <catalin.marinas@arm.com> wrote:
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
>

OK.

If you (and Matt) are ok with those, I'd like to spin a new version
that only adds strcmp(). We need that in a separate series that only
touches libstub, so with strcmp() added, we are completely independent
in terms of merging order.

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
