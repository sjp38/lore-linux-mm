Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEBA76B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:36:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f11so926418oih.7
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:36:15 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id j15si5327634oih.46.2017.08.07.11.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:36:14 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id 77so7674483itj.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:36:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com> <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 7 Aug 2017 11:36:13 -0700
Message-ID: <CAFKCwrjkonmdZ+WC9Vt_xSBgWrJLtQCN812fyxroNNpA-x4TZg@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: Kees Cook <keescook@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

MSan is 64-bit only and does not allow any mappings _outside_ of these regions:
000000000000 - 010000000000 app-1
510000000000 - 600000000000 app-2
700000000000 - 800000000000 app-3

https://github.com/google/sanitizers/issues/579

It sounds like the ELF_ET_DYN_BASE change should not break MSan.


On Mon, Aug 7, 2017 at 11:26 AM, Kostya Serebryany <kcc@google.com> wrote:
> +eugenis@ for msan
>
> On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook <keescook@google.com> wrote:
>>
>> On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
>> >
>> > https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f39fdbc5fab5
>> > breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
>> > about address space layout for substantial performance gains. There
>> > are multiple people complaining about this already:
>> > https://github.com/google/sanitizers/issues/837
>> > https://twitter.com/kayseesee/status/894594085608013825
>> > https://bugzilla.kernel.org/show_bug.cgi?id=196537
>> > AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
>> > expecting that non-pie binaries will be below 2GB and pie
>> > binaries/modules will be at 0x55 or 0x7f. This is not the first time
>> > kernel address space shuffling breaks sanitizers. The last one was the
>> > move to 0x55.
>>
>> What are the requirements for 32-bit and 64-bit memory layouts for
>> ASan currently, so we can adjust the ET_DYN base to work with existing
>> ASan?
>
>
>
> 64-bit asan shadow is 0x00007fff8000 - 0x10007fff8000
> 32-bit asan shadow is 0x20000000 - 0x40000000
>
>
> % cat dummy.c
> int main(){}
> % clang -fsanitize=address dummy.c && ASAN_OPTIONS=verbosity=1 ./a.out  2>&1
> | grep '||'
> || `[0x10007fff8000, 0x7fffffffffff]` || HighMem    ||
> || `[0x02008fff7000, 0x10007fff7fff]` || HighShadow ||
> || `[0x00008fff7000, 0x02008fff6fff]` || ShadowGap  ||
> || `[0x00007fff8000, 0x00008fff6fff]` || LowShadow  ||
> || `[0x000000000000, 0x00007fff7fff]` || LowMem     ||
> %
>
> % clang -fsanitize=address dummy.c -m32 && ASAN_OPTIONS=verbosity=1 ./a.out
> 2>&1 | grep '||'
> || `[0x40000000, 0xffffffff]` || HighMem    ||
> || `[0x28000000, 0x3fffffff]` || HighShadow ||
> || `[0x24000000, 0x27ffffff]` || ShadowGap  ||
> || `[0x20000000, 0x23ffffff]` || LowShadow  ||
> || `[0x00000000, 0x1fffffff]` || LowMem     ||
> %
>
>
>
>
>>
>>
>> I would note that on 64-bit the ELF_ET_DYN_BASE adjustment avoids the
>> entire 2GB space
>
>
> Correct, but sadly it overlaps with the asan shadow (see above)
>
>>
>> to stay out of the way of 32-bit address-using VMs,
>> for example.
>>
>> What ranges should be avoided currently? We need to balance this
>> against the need to keep the PIE away from a growing heap...
>
>
> See above.
>
>>
>>
>> > Is it possible to make this change less aggressive and keep the
>> > executable under 2GB?
>>
>> _Under_ 2GB? It's possible we're going to need some VM tunable to
>> adjust these things if we're facing incompatible requirements...
>>
>> ASan does seem especially fragile about these kinds of changes. Can
>> future versions of ASan be more dynamic about this?
>
>
> ASan already has the dynamic shadow as an option, and it's default mode
> on 64-bit windows, where the kernel is actively hostile to asan.
> On Linux, we could enable it by
>   clang -fsanitize=address -O dummy.cc -mllvm -asan-force-dynamic-shadow=1
> (not heavily tested though).
>
> The problem is that this comes at a cost that we are very reluctant to pay.
> Dynamic shadow means one extra load and one extra register stolen per
> function,
> which increases the CPU usage and code size.
>
>
>
> --kcc
>
>
>
>>
>>
>> -Kees
>>
>> --
>> Kees Cook
>> Pixel Security
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
