Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 54BFB6B0283
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 06:36:29 -0400 (EDT)
Received: by oige126 with SMTP id e126so123452012oig.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 03:36:29 -0700 (PDT)
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com. [209.85.218.53])
        by mx.google.com with ESMTPS id f71si4479993oib.58.2015.07.21.03.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 03:36:28 -0700 (PDT)
Received: by oige126 with SMTP id e126so123451890oig.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 03:36:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
Date: Tue, 21 Jul 2015 12:36:27 +0200
Message-ID: <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jun 17, 2015 at 11:32 PM, Andrey Ryabinin
<ryabinin.a.a@gmail.com> wrote:
> 2015-06-13 18:25 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>>
>> On Fri, Jun 12, 2015 at 8:14 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>> > 2015-06-11 16:39 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>> >> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> >>
>> >>> This patch adds arch specific code for kernel address sanitizer
>> >>> (see Documentation/kasan.txt).
>> >>
>> >> I looked closer at this again ... I am trying to get KASan up for
>> >> ARM(32) with some tricks and hacks.
>> >>
>> >
>> > I have some patches for that. They still need some polishing, but works for me.
>> > I could share after I get back to office on Tuesday.
>>
>> OK! I'd be happy to test!
>>
>
> I've pushed it here : git://github.com/aryabinin/linux.git kasan/arm_v0
>
> It far from ready. Firstly I've tried it only in qemu and it works.

Hm what QEMU model are you using? I tried to test it with Versatile
(the most common) and it kinda boots and hangs:

Memory: 106116K/131072K available (3067K kernel code, 166K rwdata,
864K rodata, 3072K init, 130K bss, 24956K reserved, 0K cma-reserved)
Virtual kernel memory layout:
    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
    kasan   : 0x9f000000 - 0xbf000000   ( 512 MB)
    vmalloc : 0xc8800000 - 0xff000000   ( 872 MB)
(...)

Looks correct, no highmem on this beast.

Then I get this.

Unable to handle kernel NULL pointer dereference at virtual address 00000130
pgd = c5ea8000
[00000130] *pgd=00000000
Internal error: Oops: 5 [#1] ARM
Modules linked in:
CPU: 0 PID: 19 Comm: modprobe Not tainted 4.1.0-rc8+ #7
Hardware name: ARM-Versatile (Device Tree Support)
task: c5e0b5a0 ti: c5ea0000 task.ti: c5ea0000
PC is at v4wbi_flush_user_tlb_range+0x10/0x4c
LR is at move_page_tables+0x218/0x308
pc : [<c001e870>]    lr : [<c008f230>]    psr: 20000153
sp : c5ea7df0  ip : c5e8c000  fp : ff8ec000
r10: 00bf334f  r9 : c5ead3b0  r8 : 9e8ec000
r7 : 00000001  r6 : 00002000  r5 : 9f000000  r4 : 9effe000
r3 : 00000000  r2 : c5e8a000  r1 : 9f000000  r0 : 9effe000
Flags: nzCv  IRQs on  FIQs off  Mode SVC_32  ISA ARM  Segment user
Control: 00093177  Table: 05ea8000  DAC: 00000015
Process modprobe (pid: 19, stack limit = 0xc5ea0190)
Stack: (0xc5ea7df0 to 0xc5ea8000)
7de0:                                     00000000 9f000000 c5e8a000 00000000
7e00: 00000000 00000000 c5e8a000 9effe000 000000c0 c5e8a000 c68c5700 9e8ec000
7e20: c5e8c034 9effe000 9e8ea000 9f000000 00002000 c00a9384 00002000 00000000
7e40: c5e8c000 00000000 00000000 c5e8a000 00000000 00000000 00000000 00000000
7e60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
7e80: c5e870e0 5e5e8830 c0701808 00000013 c5ea7ec0 c5eac000 c5e870e0 c5e26140
7ea0: c68c5700 00000000 c5ea7ec0 c5eac000 c5e870e0 c6a2d8c0 00000001 c00e4530
7ec0: c68c5700 00000080 c5df2480 9f000000 00000000 c5ea0000 0000000a c00a99ec
7ee0: 00000017 c5ea7ef4 00000000 00000000 00000000 c7f10e60 c0377bc0 c0bf3f99
7f00: 0000000f 00000000 00000000 c00a9c28 9efff000 c06fa2c8 c68c5700 c06f9eb8
7f20: 00000001 fffffff8 c68c5700 00000000 00000001 c00a9770 c5e0b5a0 00000013
7f40: c5e87ee0 c06ef0c8 c6a60000 c00aabd0 c5e8c034 00000000 00000000 c5e0b790
7f60: c06e8190 c5ddcc60 c5d4c300 0000003f ffffffff 00000000 00000000 00000000
7f80: 00000000 c00aad00 00000000 00000000 00000000 c0030f48 c5d4c300 c0030e54
7fa0: 00000000 00000000 00000000 c0014960 00000000 00000000 00000000 00000000
7fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
7fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[<c001e870>] (v4wbi_flush_user_tlb_range) from [<00000000>] (  (null))
Code: e592c020 e3cd3d7f e3c3303f e593300c (e5933130)
---[ end trace b3c4eba35670ba77 ]---

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
