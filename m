Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 631A16B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:32:07 -0400 (EDT)
Received: by lbwr8 with SMTP id r8so73959942lbw.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:32:06 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id jf7si497859lbc.131.2015.10.09.02.32.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 02:32:06 -0700 (PDT)
Received: by lbbwt4 with SMTP id wt4so74424991lbb.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:32:05 -0700 (PDT)
Subject: Re: [PATCH v6 0/6] KASAN for arm64
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
 <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
 <20151008111144.GC7275@leverpostej> <56165228.8060201@gmail.com>
 <CAKv+Gu_v7J1BA+xFcowBrW05bRFs=_WFf_HCeCmWgdZVRo0eQw@mail.gmail.com>
 <20151008151144.GM17192@e104818-lin.cambridge.arm.com>
 <CAPAsAGxhcRtks40u3O29t=KMKkuLy4Pf8u8TeeBy2f2-MuSf+A@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <561789A2.5050601@gmail.com>
Date: Fri, 9 Oct 2015 12:32:18 +0300
MIME-Version: 1.0
In-Reply-To: <CAPAsAGxhcRtks40u3O29t=KMKkuLy4Pf8u8TeeBy2f2-MuSf+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Yury <yury.norov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, Mark Salter <msalter@redhat.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Matt Fleming <matt.fleming@intel.com>

On 10/08/2015 07:07 PM, Andrey Ryabinin wrote:
> 2015-10-08 18:11 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>> On Thu, Oct 08, 2015 at 02:09:26PM +0200, Ard Biesheuvel wrote:
>>> On 8 October 2015 at 13:23, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>>>> On 10/08/2015 02:11 PM, Mark Rutland wrote:
>>>>> On Thu, Oct 08, 2015 at 01:36:09PM +0300, Andrey Ryabinin wrote:
>>>>>> 2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>>>>>>> On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
>>>>>>>> As usual patches available in git
>>>>>>>>       git://github.com/aryabinin/linux.git kasan/arm64v6
>>>>>>>>
>>>>>>>> Changes since v5:
>>>>>>>>  - Rebase on top of 4.3-rc1
>>>>>>>>  - Fixed EFI boot.
>>>>>>>>  - Updated Doc/features/KASAN.
>>>>>>>
>>>>>>> I tried to merge these patches (apart from the x86 one which is already
>>>>>>> merged) but it still doesn't boot on Juno as an EFI application.
>>>>>>>
>>>>>>
>>>>>> 4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
>>>>>> ("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
>>>>>> regions")
>>>>>> It introduced sort() call in efi_get_virtmap().
>>>>>> sort() is generic kernel function and it's instrumented, so we crash
>>>>>> when KASAN tries to access shadow in sort().
>>>>>
>>>>> I believe this is solved by Ard's stub isolation series [1,2], which
>>>>> will build a stub-specific copy of sort() and various other functions
>>>>> (see the arm-deps in [2]).
>>>>>
>>>>> So long as the stub is not built with ASAN, that should work.
>>>>
>>>> Thanks, this should help, as we already build the stub without ASAN instrumentation.
>>>
>>> Indeed. I did not mention instrumentation in the commit log for those
>>> patches, but obviously, something like KASAN instrumentation cannot be
>>> tolerated in the stub since it makes assumptions about the memory
>>> layout
>>
>> I'll review your latest EFI stub isolation patches and try Kasan again
>> on top (most likely tomorrow).
> 
> You'd better wait for v7, because kasan patches will need some adjustment.
> Since stub is isolated,  we need to handle memcpy vs __memcpy stuff the same
> way as we do in x86. Now we also need to #undef memset/memcpy/memmove in ARM64
> (just like this was done for x86).
> 

Hm, I was wrong, we don't need that.

I thought the EFI stub isolation patches create a copy of mem*() functions in the stub,
but they are just create aliases with __efistub_ prefix.

We only need to create some more aliases for KASAN.
The following patch on top of the EFI stub isolation series works for me.


Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
---
 arch/arm64/kernel/image.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/kernel/image.h b/arch/arm64/kernel/image.h
index e083af0..6eb8fee 100644
--- a/arch/arm64/kernel/image.h
+++ b/arch/arm64/kernel/image.h
@@ -80,6 +80,12 @@ __efistub_strcmp		= __pi_strcmp;
 __efistub_strncmp		= __pi_strncmp;
 __efistub___flush_dcache_area	= __pi___flush_dcache_area;
 
+#ifdef CONFIG_KASAN
+__efistub___memcpy		= __pi_memcpy;
+__efistub___memmove		= __pi_memmove;
+__efistub___memset		= __pi_memset;
+#endif
+
 __efistub__text			= _text;
 __efistub__end			= _end;
 __efistub__edata		= _edata;
-- 
2.4.9






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
