Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6913C6B0286
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:28:12 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id h191so12644760vke.3
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:28:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i10sor2297837uaa.35.2017.10.10.08.28.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 08:28:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009154610.GA22534@leverpostej>
References: <20171009150521.82775-1-glider@google.com> <20171009154610.GA22534@leverpostej>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 10 Oct 2017 17:28:10 +0200
Message-ID: <CAG_fn=UsTCyueyuMGT8i6ZoX9CWwvE9GhJAWnsJsPhf1AY2Z4Q@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 9, 2017 at 8:46 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> I look forward to using this! :)
>
> I just have afew comments below.
>
> On Mon, Oct 09, 2017 at 05:05:19PM +0200, Alexander Potapenko wrote:
>> +/*
>> + * Defines the format for the types of collected comparisons.
>> + */
>> +enum kcov_cmp_type {
>> +     /*
>> +      * LSB shows whether one of the arguments is a compile-time consta=
nt.
>> +      */
>> +     KCOV_CMP_CONST =3D 1,
>> +     /*
>> +      * Second and third LSBs contain the size of arguments (1/2/4/8 by=
tes).
>> +      */
>> +     KCOV_CMP_SIZE1 =3D 0,
>> +     KCOV_CMP_SIZE2 =3D 2,
>> +     KCOV_CMP_SIZE4 =3D 4,
>> +     KCOV_CMP_SIZE8 =3D 6,
>> +     KCOV_CMP_SIZE_MASK =3D 6,
>> +};
>
> Given that LSB is meant to be OR-ed in, (and hence combinations of
> values are meaningful) I don't think it makes sense for this to be an
> enum. This would clearer as something like:
>
> /*
>  * The format for the types of collected comparisons.
>  *
>  * Bit 0 shows whether one of the arguments is a compile-time constant.
>  * Bits 1 & 2 contain log2 of the argument size, up to 8 bytes.
>  */
> #define KCOV_CMP_CONST          (1 << 0)
> #define KCOV_CMP_SIZE(n)        ((n) << 1)
> #define KCOV_CMP_MASK           KCOV_CMP_SIZE(3)
Agreed.
> ... I note that a few places in the kernel use a 128-bit type. Are
> 128-bit comparisons not instrumented?
>
> [...]
>
>> +static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_str=
uct *t)
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
>
> This !t check can go, as with the one in __sanitizer_cov_trace_pc, since
> t is always current, and therefore cannot be NULL.
Ok.
> IIRC there's a patch queued for that, which this may conflict with.
Sorry, I don't quite understand what exactly is conflicting here.

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
> This would be simpler as:
>
>         return mode =3D=3D needed_mode;

Agreed.

> [...]
>
>> +     area =3D t->kcov_area;
>> +     /* The first 64-bit word is the number of subsequent PCs. */
>> +     pos =3D READ_ONCE(area[0]) + 1;
>> +     if (likely(pos < t->kcov_size)) {
>> +             area[pos] =3D ip;
>> +             WRITE_ONCE(area[0], pos);
>
> Not a new problem, but if the area for one thread is mmap'd, and read by
> another thread, these two writes could be seen out-of-order, since we
> don't have an smp_wmb() between them.
>
> I guess Syzkaller doesn't read the mmap'd kcov file from another thread?
(Dmitry answered this one already)
>>       }
>>  }
>>  EXPORT_SYMBOL(__sanitizer_cov_trace_pc);
>>
>> +#ifdef CONFIG_KCOV_ENABLE_COMPARISONS
>> +static void write_comp_data(u64 type, u64 arg1, u64 arg2, u64 ip)
>> +{
>> +     struct task_struct *t;
>> +     u64 *area;
>> +     u64 count, start_index, end_pos, max_pos;
>> +
>> +     t =3D current;
>> +     if (!check_kcov_mode(KCOV_MODE_TRACE_CMP, t))
>> +             return;
>> +
>> +#ifdef CONFIG_RANDOMIZE_BASE
>> +     ip -=3D kaslr_offset();
>> +#endif
>
> Given we have this in two places, it might make sense to have a helper
> like:
>
> unsigned long canonicalize_ip(unsigned long ip)
> {
> #ifdef CONFIG_RANDOMIZE_BASE
>         ip -=3D kaslr_offset();
> #endif
>         return ip;
> }
Done.
> ... to minimize the ifdeffery elsewhere.
>
>> +
>> +     /*
>> +      * We write all comparison arguments and types as u64.
>> +      * The buffer was allocated for t->kcov_size unsigned longs.
>> +      */
>> +     area =3D (u64 *)t->kcov_area;
>> +     max_pos =3D t->kcov_size * sizeof(unsigned long);
>> +
>> +     count =3D READ_ONCE(area[0]);
>> +
>> +     /* Every record is KCOV_WORDS_PER_CMP 64-bit words. */
>> +     start_index =3D 1 + count * KCOV_WORDS_PER_CMP;
>> +     end_pos =3D (start_index + KCOV_WORDS_PER_CMP) * sizeof(u64);
>> +     if (likely(end_pos <=3D max_pos)) {
>> +             area[start_index] =3D type;
>> +             area[start_index + 1] =3D arg1;
>> +             area[start_index + 2] =3D arg2;
>> +             area[start_index + 3] =3D ip;
>> +             WRITE_ONCE(area[0], count + 1);
>
> That ordering problem applies here, too.
>
> Thanks,
> Mark.



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
