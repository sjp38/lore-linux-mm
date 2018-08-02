Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95AD66B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:36:48 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m2-v6so1207348plt.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:36:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor380600plb.4.2018.08.02.04.36.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 04:36:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180802111031.yx3x6y5d5q6drq52@armageddon.cambridge.arm.com>
References: <cover.1530018818.git.andreyknvl@google.com> <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com> <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
 <20180703173608.GF27243@arm.com> <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
 <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
 <20180801163538.GA10800@arm.com> <CACT4Y+aZtph5qDsLzTDEgpQRz4_Vtg1DD-cB18qooi6D0bexDg@mail.gmail.com>
 <20180802111031.yx3x6y5d5q6drq52@armageddon.cambridge.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 2 Aug 2018 13:36:25 +0200
Message-ID: <CACT4Y+b0gkSQHUG67MbYZUTA_aZWs7EmJ2eUzOEPWdt9==ysdg@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 2, 2018 at 1:10 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Wed, Aug 01, 2018 at 06:52:09PM +0200, Dmitry Vyukov wrote:
>> On Wed, Aug 1, 2018 at 6:35 PM, Will Deacon <will.deacon@arm.com> wrote:
>> > On Tue, Jul 31, 2018 at 03:22:13PM +0200, Andrey Konovalov wrote:
>> >> On Wed, Jul 18, 2018 at 7:16 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> >> > On Tue, Jul 3, 2018 at 7:36 PM, Will Deacon <will.deacon@arm.com> wrote:
>> >> >> Hmm, but elsewhere in this thread, Evgenii is motivating the need for this
>> >> >> patch set precisely because the lower overhead means it's suitable for
>> >> >> "near-production" use. So I don't think writing this off as a debugging
>> >> >> feature is the right approach, and we instead need to put effort into
>> >> >> analysing the impact of address tags on the kernel as a whole. Playing
>> >> >> whack-a-mole with subtle tag issues sounds like the worst possible outcome
>> >> >> for the long-term.
>> >> >
>> >> > I don't see a way to find cases where pointer tags would matter
>> >> > statically, so I've implemented the dynamic approach that I mentioned
>> >> > above. I've instrumented all pointer comparisons/subtractions in an
>> >> > LLVM compiler pass and used a kernel module that would print a bug
>> >> > report whenever two pointers with different tags are being
>> >> > compared/subtracted (ignoring comparisons with NULL pointers and with
>> >> > pointers obtained by casting an error code to a pointer type). Then I
>> >> > tried booting the kernel in QEMU and on an Odroid C2 board and I ran
>> >> > syzkaller overnight.
>> >> >
>> >> > This yielded the following results.
>> >> >
>> >> > ======
>> >> >
>> >> > The two places that look interesting are:
>> >> >
>> >> > is_vmalloc_addr in include/linux/mm.h (already mentioned by Catalin)
>> >> > is_kernel_rodata in mm/util.c
>> >> >
>> >> > Here we compare a pointer with some fixed untagged values to make sure
>> >> > that the pointer lies in a particular part of the kernel address
>> >> > space. Since KWHASAN doesn't add tags to pointers that belong to
>> >> > rodata or vmalloc regions, this should work as is. To make sure I've
>> >> > added debug checks to those two functions that check that the result
>> >> > doesn't change whether we operate on pointers with or without
>> >> > untagging.
>> >> >
>> >> > ======
>> >> >
>> >> > A few other cases that don't look that interesting:
>> >> >
>> >> > Comparing pointers to achieve unique sorting order of pointee objects
>> >> > (e.g. sorting locks addresses before performing a double lock):
>> >> >
>> >> > tty_ldisc_lock_pair_timeout in drivers/tty/tty_ldisc.c
>> >> > pipe_double_lock in fs/pipe.c
>> >> > unix_state_double_lock in net/unix/af_unix.c
>> >> > lock_two_nondirectories in fs/inode.c
>> >> > mutex_lock_double in kernel/events/core.c
>> >> >
>> >> > ep_cmp_ffd in fs/eventpoll.c
>> >> > fsnotify_compare_groups fs/notify/mark.c
>> >> >
>> >> > Nothing needs to be done here, since the tags embedded into pointers
>> >> > don't change, so the sorting order would still be unique.
>> >> >
>> >> > Check that a pointer belongs to some particular allocation:
>> >> >
>> >> > is_sibling_entry lib/radix-tree.c
>> >> > object_is_on_stack in include/linux/sched/task_stack.h
>> >> >
>> >> > Nothing needs to be here either, since two pointers can only belong to
>> >> > the same allocation if they have the same tag.
>> >> >
>> >> > ======
>> >> >
>> >> > Will, Catalin, WDYT?
>> >>
>> >> ping
>> >
>> > Thanks for tracking these cases down and going through each of them. The
>> > obvious follow-up question is: how do we ensure that we keep on top of
>> > this in mainline? Are you going to repeat your experiment at every kernel
>> > release or every -rc or something else? I really can't see how we can
>> > maintain this in the long run, especially given that the coverage we have
>> > is only dynamic -- do you have an idea of how much coverage you're actually
>> > getting for, say, a defconfig+modules build?
>> >
>> > I'd really like to enable pointer tagging in the kernel, I'm just still
>> > failing to see how we can do it in a controlled manner where we can reason
>> > about the semantic changes using something other than a best-effort,
>> > case-by-case basis which is likely to be fragile and error-prone.
>> > Unfortunately, if that's all we have, then this gets relegated to a
>> > debug feature, which sort of defeats the point in my opinion.
>>
>> Well, in some cases there is no other way as resorting to dynamic testing.
>> How do we ensure that kernel does not dereference NULL pointers, does
>> not access objects after free or out of bounds?
>
> We should not confuse software bugs (like NULL pointer dereference) with
> unexpected software behaviour introduced by khwasan where pointers no
> longer represent only an address range (e.g. calling find_vmap_area())
> but rather an address and a tag.

These are also software bugs, not different from NULL derefs that we
do not detect statically.

> Parts of the kernel rely on pointers
> being just address ranges.
>
> It's the latter that we'd like to identify more easily and avoid subtle
> bugs or change in behaviour when running correctly written code.

You mean _previously_ correct code, now it's just incorrect code. Not
different from any other types of incorrect code, and we do have
thousands of types of incorrect code already, most of these types are
not detectable statically.

>> And, yes, it's
>> constant maintenance burden resolved via dynamic testing.
>> In some sense HWASAN is better in this regard because it's like, say,
>> LOCKDEP in this regard. It's enabled only when one does dynamic
>> testing and collect, analyze and fix everything that pops up. Any
>> false positives will fail loudly (as opposed to, say, silent memory
>> corruptions due to use-after-frees), so any false positives will be
>> just first things to fix during the tool application.
>
> Again, you are talking about the bugs that khwasan would discover. We
> don't deny its value and false positives are acceptable here.

I am talking about the same thing you are talking about. New crashes
of changes in behavior will also pop up and will need to be fixed.

> However, not untagging a pointer when converting to long may have
> side-effects in some cases and I consider these bugs introduced by the
> khwasan support rather than bugs in the original kernel code. Ideally
> we'd need some tooling on top of khwasan to detect such shortcomings but
> I'm not sure we can do this statically, as Andrey already mentioned. For
> __user pointers, things are slightly better as we can detect the
> conversion either with sparse (modified) or some LLVM changes.

I agree. Ideally we have strict static checking for this type of bugs.
Ideally we have it for all types of bugs. NULL derefs,
use-after-frees, or say confusion between a function returning 0/1 for
ok/failure with a function returning true/false. How do we detect that
statically? Nohow.

For example, LOCKDEP has the same problem. Previously correct code can
become incorrect and require finer-grained lock class annotations.
KMEMLEAK has the same problem: previously correct code that hides a
pointer may now need changes to unhide the pointer.

If somebody has a practical idea how to detect these statically, let's
do it. Otherwise let's go with the traditional solution to this --
dynamic testing. The patch series show that the problem is not a
disaster and we won't need to change just every line of kernel code.
