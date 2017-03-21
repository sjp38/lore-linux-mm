Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADAB56B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 17:42:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so330750314pfj.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:42:08 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id 2si22641052pla.204.2017.03.21.14.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 14:42:07 -0700 (PDT)
Date: Tue, 21 Mar 2017 14:23:51 -0700
In-Reply-To: <20170321211648.xcgwigbv37ktxofx@angband.pl>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com> <20170321211648.xcgwigbv37ktxofx@angband.pl>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <D1FD1484-E113-4B53-8ED5-E5B34BAECC53@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>, Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On March 21, 2017 2:16:48 PM PDT, Adam Borowski <kilobyte@angband=2Epl> wro=
te:
>On Tue, Mar 21, 2017 at 08:47:11PM +0300, Dmitry Safonov wrote:
>> After my changes to mmap(), its code now relies on the bitness of
>> performing syscall=2E According to that, it chooses the base of
>allocation:
>> mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall=2E
>> It was done by:
>>   commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()")=2E
>>=20
>> The code afterwards relies on in_compat_syscall() returning true for
>> 32-bit syscalls=2E It's usually so while we're in context of
>application
>> that does 32-bit syscalls=2E But during exec() it is not valid for x32
>ELF=2E
>> The reason is that the application hasn't yet done any syscall, so
>x32
>> bit has not being set=2E
>> That results in -ENOMEM for x32 ELF files as there fired BAD_ADDR()
>> in elf_map(), that is called from do_execve()->load_elf_binary()=2E
>> For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag=2E
>>=20
>> Set x32 bit before first return to userspace, during setting
>personality
>> at exec()=2E This way we can rely on in_compat_syscall() during exec()=
=2E
>> Do also the reverse: drop x32 syscall bit at SET_PERSONALITY for
>64-bits=2E
>>=20
>> Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()")
>
>Tested:
>with bash:x32, mksh:amd64, posh:i386, zsh:armhf (binfmt:qemu),
>fork+exec
>works for every parent-child combination=2E
>
>Contrary to my naive initial reading of your fix, mixing syscalls from
>a
>process of the wrong ABI also works as it did before=2E  While using a
>glibc
>wrapper will call the right version, x32 processes calling amd64
>syscalls is
>surprisingly common -- this brings seccomp joy=2E
>
>I've attached a freestanding test case for write() and mmap(); it's
>freestanding asm as most of you don't have an x32 toolchain at hand,
>sorry
>for unfriendly error messages=2E
>
>So with these two patches:
>x86/tls: Forcibly set the accessed bit in TLS segments
>x86/mm: set x32 syscall bit in SET_PERSONALITY()
>everything appears to be fine=2E

What userspace is that?  Is this syscall(3) (ab)users or incorrectly porte=
d to x32 software?
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
