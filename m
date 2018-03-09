Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3CA6B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 10:17:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d85so1841477qke.11
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 07:17:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y130sor891608qka.119.2018.03.09.07.17.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 07:17:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180309145547.r25eis5ejy6d6xzu@lakrids.cambridge.arm.com>
References: <cover.1520600533.git.andreyknvl@google.com> <20180309145547.r25eis5ejy6d6xzu@lakrids.cambridge.arm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 9 Mar 2018 16:16:58 +0100
Message-ID: <CAMuHMdWtdYAVOvR=gffVu0T1vzEcKM4pqxRc6zWr=k3PykgwiA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/6] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Fri, Mar 9, 2018 at 3:55 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 09, 2018 at 03:01:58PM +0100, Andrey Konovalov wrote:
>> arm64 has a feature called Top Byte Ignore, which allows to embed pointer
>> tags into the top byte of each pointer. Userspace programs (such as
>> HWASan, a memory debugging tool [1]) might use this feature and pass
>> tagged user pointers to the kernel through syscalls or other interfaces.
>>
>> This patch makes a few of the kernel interfaces accept tagged user
>> pointers. The kernel is already able to handle user faults with tagged
>> pointers and has the untagged_addr macro, which this patchset reuses.
>>
>> We're not trying to cover all possible ways the kernel accepts user
>> pointers in one patchset, so this one should be considered as a start.
>> It would be nice to learn about the interfaces that I missed though.
>
> There are many ways that user pointers can be passed to the kernel, and
> I'm not sure that it's feasible to catch them all, especially as user
> pointers are often passed in data structures (e.g. iovecs) rather than
> direct syscall arguments.
>
> If we *really* want the kernel to support taking tagged addresses, anything
> with a __user annotation (or cast to something with a __user annotation)
> requires tag removal somewhere in the kernel.
>
> It looks like there are plenty uapi structures and syscalls to look at:
>
> [mark@lakrids:~/src/linux]% git grep __user -- include/uapi | wc -l
> 216
> [mark@lakrids:~/src/linux]% git grep __user | grep SYSCALL_DEFINE | wc -l
> 308
>
> ... in addition to special syscalls like ioctl which multiplex a number
> of operations with different arguments, where the tag stripping would
> have to occur elsewhere (e.g. in particular drivers).

Hence we definitely need good support from e.g. sparse to catch any errors
from happening.

So doing assignments to the same pointer variable like

     addr = untagged_addr(addr);

defeats any checking.

> I also wonder if we ever write any of these pointers back to userspace
> memory. If so, we have a nasty ABI problem, since we'll have to marshal
> the original tag along with the pointer, to ensure userspace pointer
> comparisons continue to work.

Oh, another can of worms...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
