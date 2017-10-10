Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 520FB6B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:35:04 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f202so7833458ioe.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:35:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d138sor557519itb.46.2017.10.10.08.35.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 08:35:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UsTCyueyuMGT8i6ZoX9CWwvE9GhJAWnsJsPhf1AY2Z4Q@mail.gmail.com>
References: <20171009150521.82775-1-glider@google.com> <20171009154610.GA22534@leverpostej>
 <CAG_fn=UsTCyueyuMGT8i6ZoX9CWwvE9GhJAWnsJsPhf1AY2Z4Q@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 10 Oct 2017 17:34:42 +0200
Message-ID: <CACT4Y+ZeYmOXK8P37+HkfYAavnSsnoMDYLP7MF6FL_VpnC6bZw@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 10, 2017 at 5:28 PM, 'Alexander Potapenko' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On Mon, Oct 9, 2017 at 8:46 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>> Hi,
>>
>> I look forward to using this! :)
>>
>> I just have afew comments below.
>>
>> On Mon, Oct 09, 2017 at 05:05:19PM +0200, Alexander Potapenko wrote:
>>> +/*
>>> + * Defines the format for the types of collected comparisons.
>>> + */
>>> +enum kcov_cmp_type {
>>> +     /*
>>> +      * LSB shows whether one of the arguments is a compile-time constant.
>>> +      */
>>> +     KCOV_CMP_CONST = 1,
>>> +     /*
>>> +      * Second and third LSBs contain the size of arguments (1/2/4/8 bytes).
>>> +      */
>>> +     KCOV_CMP_SIZE1 = 0,
>>> +     KCOV_CMP_SIZE2 = 2,
>>> +     KCOV_CMP_SIZE4 = 4,
>>> +     KCOV_CMP_SIZE8 = 6,
>>> +     KCOV_CMP_SIZE_MASK = 6,
>>> +};
>>
>> Given that LSB is meant to be OR-ed in, (and hence combinations of
>> values are meaningful) I don't think it makes sense for this to be an
>> enum. This would clearer as something like:
>>
>> /*
>>  * The format for the types of collected comparisons.
>>  *
>>  * Bit 0 shows whether one of the arguments is a compile-time constant.
>>  * Bits 1 & 2 contain log2 of the argument size, up to 8 bytes.
>>  */
>> #define KCOV_CMP_CONST          (1 << 0)
>> #define KCOV_CMP_SIZE(n)        ((n) << 1)
>> #define KCOV_CMP_MASK           KCOV_CMP_SIZE(3)
> Agreed.
>> ... I note that a few places in the kernel use a 128-bit type. Are
>> 128-bit comparisons not instrumented?
>>
>> [...]
>>
>>> +static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_struct *t)
>>> +{
>>> +     enum kcov_mode mode;
>>> +
>>> +     /*
>>> +      * We are interested in code coverage as a function of a syscall inputs,
>>> +      * so we ignore code executed in interrupts.
>>> +      */
>>> +     if (!t || !in_task())
>>> +             return false;
>>
>> This !t check can go, as with the one in __sanitizer_cov_trace_pc, since
>> t is always current, and therefore cannot be NULL.
> Ok.
>> IIRC there's a patch queued for that, which this may conflict with.
> Sorry, I don't quite understand what exactly is conflicting here.


This patch should be in mm tree:
https://patchwork.kernel.org/patch/9978383/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
