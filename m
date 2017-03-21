Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE3026B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 18:07:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n55so791471wrn.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:07:54 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id k42si29688566wre.305.2017.03.21.15.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 15:07:53 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id g10so24418632wrg.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:07:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321211648.xcgwigbv37ktxofx@angband.pl>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com> <20170321211648.xcgwigbv37ktxofx@angband.pl>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Wed, 22 Mar 2017 01:07:32 +0300
Message-ID: <CAJwJo6ZBBkeMd5a5ZceXZ__+BxRMUTY18YpVn1RAb3hXJP5Mnw@mail.gmail.com>
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

2017-03-22 0:16 GMT+03:00 Adam Borowski <kilobyte@angband.pl>:
> On Tue, Mar 21, 2017 at 08:47:11PM +0300, Dmitry Safonov wrote:
>> After my changes to mmap(), its code now relies on the bitness of
>> performing syscall. According to that, it chooses the base of allocation:
>> mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
>> It was done by:
>>   commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()").
>>
>> The code afterwards relies on in_compat_syscall() returning true for
>> 32-bit syscalls. It's usually so while we're in context of application
>> that does 32-bit syscalls. But during exec() it is not valid for x32 ELF.
>> The reason is that the application hasn't yet done any syscall, so x32
>> bit has not being set.
>> That results in -ENOMEM for x32 ELF files as there fired BAD_ADDR()
>> in elf_map(), that is called from do_execve()->load_elf_binary().
>> For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.
>>
>> Set x32 bit before first return to userspace, during setting personality
>> at exec(). This way we can rely on in_compat_syscall() during exec().
>> Do also the reverse: drop x32 syscall bit at SET_PERSONALITY for 64-bits.
>>
>> Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()")
>
> Tested:
> with bash:x32, mksh:amd64, posh:i386, zsh:armhf (binfmt:qemu), fork+exec
> works for every parent-child combination.
>
> Contrary to my naive initial reading of your fix, mixing syscalls from a
> process of the wrong ABI also works as it did before.  While using a glibc
> wrapper will call the right version, x32 processes calling amd64 syscalls is
> surprisingly common -- this brings seccomp joy.

JFI: x32 mmap() syscall in 64 ELF should work even better - it has returned
addresses over 4Gb in ia32 mmap()s, so I expect it did the same in x32 top-down
allocation. (I guess you've mentioned the fixes-for patch).
So the thing to check not also that mmap() returned address, but at least
verify-dereference it with `mov' e.g. (or better - to parse /proc/self/maps)

> I've attached a freestanding test case for write() and mmap(); it's
> freestanding asm as most of you don't have an x32 toolchain at hand, sorry
> for unfriendly error messages.
>
> So with these two patches:
> x86/tls: Forcibly set the accessed bit in TLS segments
> x86/mm: set x32 syscall bit in SET_PERSONALITY()
> everything appears to be fine.

Big thanks for the testing work, Adam!

-- 
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
