Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB146B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:04:24 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s199so4127155vke.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:04:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k4sor3657558vkg.7.2017.08.30.12.04.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 12:04:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170830182357.GD32493@leverpostej>
References: <cover.1504109849.git.dvyukov@google.com> <663c2a30de845dd13cf3cf64c3dfd437295d5ce2.1504109849.git.dvyukov@google.com>
 <20170830182357.GD32493@leverpostej>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 30 Aug 2017 21:04:21 +0200
Message-ID: <CAG_fn=VaptX5n2Vpgin_Gsxxb5Eztzft-_YeROh9J3U6URXRYg@mail.gmail.com>
Subject: Re: [PATCH 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Victor Chibotaru <tchibo@google.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller <syzkaller@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 30, 2017 at 8:23 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> On Wed, Aug 30, 2017 at 06:23:29PM +0200, Dmitry Vyukov wrote:
>> From: Victor Chibotaru <tchibo@google.com>
>>
>> Enables kcov to collect comparison operands from instrumented code.
>> This is done by using Clang's -fsanitize=3Dtrace-cmp instrumentation
>> (currently not available for GCC).
Hi Mark,

> What's needed to build the kernel with Clang these days?
Shameless plug: https://github.com/ramosian-glider/clang-kernel-build
We are currently one patch away from booting the Clang-built kernel on x86.
The patch in my repo is far from perfect, Josh Poimboeuf has a better
one at https://git.kernel.org/pub/scm/linux/kernel/git/jpoimboe/linux.git/l=
og/?h=3DASM_CALL

> I was under the impression that it still wasn't possible to build arm64
> with clang due to a number of missing features (e.g. the %a assembler
> output template).
Sorry, I haven't experimented with ARM much. Nick Desaulniers or Greg
Hackmann should know the details, I'll ask them.
I think the current status is "almost there".
>> The comparison operands help a lot in fuzz testing. E.g. they are
>> used in Syzkaller to cover the interiors of conditional statements
>> with way less attempts and thus make previously unreachable code
>> reachable.
>>
>> To allow separate collection of coverage and comparison operands two
>> different work modes are implemented. Mode selection is now done via
>> a KCOV_ENABLE ioctl call with corresponding argument value.
>>
>> Signed-off-by: Victor Chibotaru <tchibo@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Alexander Popov <alex.popov@linux.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Vegard Nossum <vegard.nossum@oracle.com>
>> Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
>> Cc: syzkaller@googlegroups.com
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>> Clang instrumentation:
>> https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
>
> How stable is this?
>
> The comment at the end says "This interface is a subject to change."
>
> [...]
>
>> diff --git a/kernel/kcov.c b/kernel/kcov.c
>> index cd771993f96f..2abce5dfa2df 100644
>> --- a/kernel/kcov.c
>> +++ b/kernel/kcov.c
>> @@ -21,13 +21,21 @@
>>  #include <linux/kcov.h>
>>  #include <asm/setup.h>
>>
>> +/* Number of words written per one comparison. */
>> +#define KCOV_WORDS_PER_CMP 3
>
> Could you please expand the comment to cover what a "word" is?
>
> Generally, "word" is an ambiguous term, and it's used inconsitently in
> this file as of this patch. For comparison coverage, a "word" is assumed
> to always be 64-bit, (which makes sxense given 64-bit comparisons), but
> for branch coverage a "word" refers to an unsigned long, which would be
> 32-bit on a 32-bit platform.
>
> [...]
>
>> +static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_str=
uct *t)
>
> Perhaps kcov_mode_is_active()?
>
> That would better describe what is being checked.
>
>> +{
>> +     enum kcov_mode mode;
>> +
>> +     /*
>> +      * We are interested in code coverage as a function of a syscall i=
nputs,
>> +      * so we ignore code executed in interrupts.
>> +      */
>> +     if (!t || !in_task())
>> +             return false;
>> +     mode =3D READ_ONCE(t->kcov_mode);
>> +     /*
>> +      * There is some code that runs in interrupts but for which
>> +      * in_interrupt() returns false (e.g. preempt_schedule_irq()).
>> +      * READ_ONCE()/barrier() effectively provides load-acquire wrt
>> +      * interrupts, there are paired barrier()/WRITE_ONCE() in
>> +      * kcov_ioctl_locked().
>> +      */
>> +     barrier();
>> +     if (mode !=3D needed_mode)
>> +             return false;
>> +     return true;
>
> This would be simlper as:
>
>         barrier();
>         return mode =3D=3D needed_mode;
>
> [...]
>
>> +#ifdef CONFIG_KCOV_ENABLE_COMPARISONS
>> +static void write_comp_data(u64 type, u64 arg1, u64 arg2)
>> +{
>> +     struct task_struct *t;
>> +     u64 *area;
>> +     u64 count, start_index, end_pos, max_pos;
>> +
>> +     t =3D current;
>> +     if (!check_kcov_mode(KCOV_MODE_TRACE_CMP, t))
>> +             return;
>> +
>> +     /*
>> +      * We write all comparison arguments and types as u64.
>> +      * The buffer was allocated for t->kcov_size unsigned longs.
>> +      */
>> +     area =3D (u64 *)t->kcov_area;
>> +     max_pos =3D t->kcov_size * sizeof(unsigned long);
>
> Perhaps it would make more sense for k->kcov_size to be in bytes, if
> different options will have differing record sizes?
>
>> +
>> +     count =3D READ_ONCE(area[0]);
>> +
>> +     /* Every record is KCOV_WORDS_PER_CMP words. */
>
> As above, please be explicit about what a "word" is, or avoid using
> "word" terminology.
>
> Thanks,
> Mark.
>
> --
> You received this message because you are subscribed to the Google Groups=
 "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
