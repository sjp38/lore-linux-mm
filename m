Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 451646B026B
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 05:56:03 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id l40so579120uah.2
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:56:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u40sor2374804uaf.186.2017.10.11.02.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 02:56:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZeYmOXK8P37+HkfYAavnSsnoMDYLP7MF6FL_VpnC6bZw@mail.gmail.com>
References: <20171009150521.82775-1-glider@google.com> <20171009154610.GA22534@leverpostej>
 <CAG_fn=UsTCyueyuMGT8i6ZoX9CWwvE9GhJAWnsJsPhf1AY2Z4Q@mail.gmail.com> <CACT4Y+ZeYmOXK8P37+HkfYAavnSsnoMDYLP7MF6FL_VpnC6bZw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 11 Oct 2017 11:56:01 +0200
Message-ID: <CAG_fn=XwnAoZHtwLEOkysKNY+WPkzz1gCi1ZwN9JbYKQinqnNA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 10, 2017 at 5:34 PM, 'Dmitry Vyukov' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On Tue, Oct 10, 2017 at 5:28 PM, 'Alexander Potapenko' via syzkaller
> <syzkaller@googlegroups.com> wrote:
>> On Mon, Oct 9, 2017 at 8:46 AM, Mark Rutland <mark.rutland@arm.com> wrot=
e:
>>> Hi,
>>>
>>> I look forward to using this! :)
>>>
>>> I just have afew comments below.
>>>
>>> On Mon, Oct 09, 2017 at 05:05:19PM +0200, Alexander Potapenko wrote:
>>>> +/*
>>>> + * Defines the format for the types of collected comparisons.
>>>> + */
>>>> +enum kcov_cmp_type {
>>>> +     /*
>>>> +      * LSB shows whether one of the arguments is a compile-time cons=
tant.
>>>> +      */
>>>> +     KCOV_CMP_CONST =3D 1,
>>>> +     /*
>>>> +      * Second and third LSBs contain the size of arguments (1/2/4/8 =
bytes).
>>>> +      */
>>>> +     KCOV_CMP_SIZE1 =3D 0,
>>>> +     KCOV_CMP_SIZE2 =3D 2,
>>>> +     KCOV_CMP_SIZE4 =3D 4,
>>>> +     KCOV_CMP_SIZE8 =3D 6,
>>>> +     KCOV_CMP_SIZE_MASK =3D 6,
>>>> +};
>>>
>>> Given that LSB is meant to be OR-ed in, (and hence combinations of
>>> values are meaningful) I don't think it makes sense for this to be an
>>> enum. This would clearer as something like:
>>>
>>> /*
>>>  * The format for the types of collected comparisons.
>>>  *
>>>  * Bit 0 shows whether one of the arguments is a compile-time constant.
>>>  * Bits 1 & 2 contain log2 of the argument size, up to 8 bytes.
>>>  */
>>> #define KCOV_CMP_CONST          (1 << 0)
>>> #define KCOV_CMP_SIZE(n)        ((n) << 1)
>>> #define KCOV_CMP_MASK           KCOV_CMP_SIZE(3)
>> Agreed.
>>> ... I note that a few places in the kernel use a 128-bit type. Are
>>> 128-bit comparisons not instrumented?
>>>
>>> [...]
>>>
>>>> +static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_s=
truct *t)
>>>> +{
>>>> +     enum kcov_mode mode;
>>>> +
>>>> +     /*
>>>> +      * We are interested in code coverage as a function of a syscall=
 inputs,
>>>> +      * so we ignore code executed in interrupts.
>>>> +      */
>>>> +     if (!t || !in_task())
>>>> +             return false;
>>>
>>> This !t check can go, as with the one in __sanitizer_cov_trace_pc, sinc=
e
>>> t is always current, and therefore cannot be NULL.
>> Ok.
>>> IIRC there's a patch queued for that, which this may conflict with.
>> Sorry, I don't quite understand what exactly is conflicting here.
>
>
> This patch should be in mm tree:
> https://patchwork.kernel.org/patch/9978383/
Ok, I've rebased on top of it, see v4.
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
