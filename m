Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 824046B0010
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:22:16 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id z9-v6so11374772iom.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:22:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12-v6sor5222219jah.93.2018.07.31.06.22.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 06:22:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
References: <cover.1530018818.git.andreyknvl@google.com> <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com> <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
 <20180703173608.GF27243@arm.com> <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 31 Jul 2018 15:22:13 +0200
Message-ID: <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Wed, Jul 18, 2018 at 7:16 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Tue, Jul 3, 2018 at 7:36 PM, Will Deacon <will.deacon@arm.com> wrote:
>> Hmm, but elsewhere in this thread, Evgenii is motivating the need for this
>> patch set precisely because the lower overhead means it's suitable for
>> "near-production" use. So I don't think writing this off as a debugging
>> feature is the right approach, and we instead need to put effort into
>> analysing the impact of address tags on the kernel as a whole. Playing
>> whack-a-mole with subtle tag issues sounds like the worst possible outcome
>> for the long-term.
>
> I don't see a way to find cases where pointer tags would matter
> statically, so I've implemented the dynamic approach that I mentioned
> above. I've instrumented all pointer comparisons/subtractions in an
> LLVM compiler pass and used a kernel module that would print a bug
> report whenever two pointers with different tags are being
> compared/subtracted (ignoring comparisons with NULL pointers and with
> pointers obtained by casting an error code to a pointer type). Then I
> tried booting the kernel in QEMU and on an Odroid C2 board and I ran
> syzkaller overnight.
>
> This yielded the following results.
>
> ======
>
> The two places that look interesting are:
>
> is_vmalloc_addr in include/linux/mm.h (already mentioned by Catalin)
> is_kernel_rodata in mm/util.c
>
> Here we compare a pointer with some fixed untagged values to make sure
> that the pointer lies in a particular part of the kernel address
> space. Since KWHASAN doesn't add tags to pointers that belong to
> rodata or vmalloc regions, this should work as is. To make sure I've
> added debug checks to those two functions that check that the result
> doesn't change whether we operate on pointers with or without
> untagging.
>
> ======
>
> A few other cases that don't look that interesting:
>
> Comparing pointers to achieve unique sorting order of pointee objects
> (e.g. sorting locks addresses before performing a double lock):
>
> tty_ldisc_lock_pair_timeout in drivers/tty/tty_ldisc.c
> pipe_double_lock in fs/pipe.c
> unix_state_double_lock in net/unix/af_unix.c
> lock_two_nondirectories in fs/inode.c
> mutex_lock_double in kernel/events/core.c
>
> ep_cmp_ffd in fs/eventpoll.c
> fsnotify_compare_groups fs/notify/mark.c
>
> Nothing needs to be done here, since the tags embedded into pointers
> don't change, so the sorting order would still be unique.
>
> Check that a pointer belongs to some particular allocation:
>
> is_sibling_entry lib/radix-tree.c
> object_is_on_stack in include/linux/sched/task_stack.h
>
> Nothing needs to be here either, since two pointers can only belong to
> the same allocation if they have the same tag.
>
> ======
>
> Will, Catalin, WDYT?

ping
