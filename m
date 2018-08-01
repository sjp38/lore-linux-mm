Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 077586B026A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 12:35:40 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m197-v6so17121450oig.18
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 09:35:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 128-v6si11307907oif.171.2018.08.01.09.35.38
        for <linux-mm@kvack.org>;
        Wed, 01 Aug 2018 09:35:38 -0700 (PDT)
Date: Wed, 1 Aug 2018 17:35:39 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180801163538.GA10800@arm.com>
References: <cover.1530018818.git.andreyknvl@google.com>
 <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com>
 <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
 <20180703173608.GF27243@arm.com>
 <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
 <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Martin <Dave.Martin@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

Hi Andrey,

On Tue, Jul 31, 2018 at 03:22:13PM +0200, Andrey Konovalov wrote:
> On Wed, Jul 18, 2018 at 7:16 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > On Tue, Jul 3, 2018 at 7:36 PM, Will Deacon <will.deacon@arm.com> wrote:
> >> Hmm, but elsewhere in this thread, Evgenii is motivating the need for this
> >> patch set precisely because the lower overhead means it's suitable for
> >> "near-production" use. So I don't think writing this off as a debugging
> >> feature is the right approach, and we instead need to put effort into
> >> analysing the impact of address tags on the kernel as a whole. Playing
> >> whack-a-mole with subtle tag issues sounds like the worst possible outcome
> >> for the long-term.
> >
> > I don't see a way to find cases where pointer tags would matter
> > statically, so I've implemented the dynamic approach that I mentioned
> > above. I've instrumented all pointer comparisons/subtractions in an
> > LLVM compiler pass and used a kernel module that would print a bug
> > report whenever two pointers with different tags are being
> > compared/subtracted (ignoring comparisons with NULL pointers and with
> > pointers obtained by casting an error code to a pointer type). Then I
> > tried booting the kernel in QEMU and on an Odroid C2 board and I ran
> > syzkaller overnight.
> >
> > This yielded the following results.
> >
> > ======
> >
> > The two places that look interesting are:
> >
> > is_vmalloc_addr in include/linux/mm.h (already mentioned by Catalin)
> > is_kernel_rodata in mm/util.c
> >
> > Here we compare a pointer with some fixed untagged values to make sure
> > that the pointer lies in a particular part of the kernel address
> > space. Since KWHASAN doesn't add tags to pointers that belong to
> > rodata or vmalloc regions, this should work as is. To make sure I've
> > added debug checks to those two functions that check that the result
> > doesn't change whether we operate on pointers with or without
> > untagging.
> >
> > ======
> >
> > A few other cases that don't look that interesting:
> >
> > Comparing pointers to achieve unique sorting order of pointee objects
> > (e.g. sorting locks addresses before performing a double lock):
> >
> > tty_ldisc_lock_pair_timeout in drivers/tty/tty_ldisc.c
> > pipe_double_lock in fs/pipe.c
> > unix_state_double_lock in net/unix/af_unix.c
> > lock_two_nondirectories in fs/inode.c
> > mutex_lock_double in kernel/events/core.c
> >
> > ep_cmp_ffd in fs/eventpoll.c
> > fsnotify_compare_groups fs/notify/mark.c
> >
> > Nothing needs to be done here, since the tags embedded into pointers
> > don't change, so the sorting order would still be unique.
> >
> > Check that a pointer belongs to some particular allocation:
> >
> > is_sibling_entry lib/radix-tree.c
> > object_is_on_stack in include/linux/sched/task_stack.h
> >
> > Nothing needs to be here either, since two pointers can only belong to
> > the same allocation if they have the same tag.
> >
> > ======
> >
> > Will, Catalin, WDYT?
> 
> ping

Thanks for tracking these cases down and going through each of them. The
obvious follow-up question is: how do we ensure that we keep on top of
this in mainline? Are you going to repeat your experiment at every kernel
release or every -rc or something else? I really can't see how we can
maintain this in the long run, especially given that the coverage we have
is only dynamic -- do you have an idea of how much coverage you're actually
getting for, say, a defconfig+modules build?

I'd really like to enable pointer tagging in the kernel, I'm just still
failing to see how we can do it in a controlled manner where we can reason
about the semantic changes using something other than a best-effort,
case-by-case basis which is likely to be fragile and error-prone.
Unfortunately, if that's all we have, then this gets relegated to a
debug feature, which sort of defeats the point in my opinion.

Will
