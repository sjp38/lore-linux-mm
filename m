Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF73C6B026A
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:15:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j201so13374790ioj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:15:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z2sor2973899iti.80.2017.10.09.11.15.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 11:15:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009154610.GA22534@leverpostej>
References: <20171009150521.82775-1-glider@google.com> <20171009154610.GA22534@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 Oct 2017 20:15:10 +0200
Message-ID: <CACT4Y+Y_79MQVHg--92AJFk3_9XoLgaM2zF3zK5ErfnH-zNcPw@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, andreyknvl <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 9, 2017 at 5:46 PM, Mark Rutland <mark.rutland@arm.com> wrote:
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
>> +      * LSB shows whether one of the arguments is a compile-time constant.
>> +      */
>> +     KCOV_CMP_CONST = 1,
>> +     /*
>> +      * Second and third LSBs contain the size of arguments (1/2/4/8 bytes).
>> +      */
>> +     KCOV_CMP_SIZE1 = 0,
>> +     KCOV_CMP_SIZE2 = 2,
>> +     KCOV_CMP_SIZE4 = 4,
>> +     KCOV_CMP_SIZE8 = 6,
>> +     KCOV_CMP_SIZE_MASK = 6,
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
>
> ... I note that a few places in the kernel use a 128-bit type. Are
> 128-bit comparisons not instrumented?

Yes, they are not instrumented.
How many are there? Can you give some examples?



>> +static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_struct *t)
>> +{
>> +     enum kcov_mode mode;
>> +
>> +     /*
>> +      * We are interested in code coverage as a function of a syscall inputs,
>> +      * so we ignore code executed in interrupts.
>> +      */
>> +     if (!t || !in_task())
>> +             return false;
>
> This !t check can go, as with the one in __sanitizer_cov_trace_pc, since
> t is always current, and therefore cannot be NULL.
>
> IIRC there's a patch queued for that, which this may conflict with.
>
>> +     mode = READ_ONCE(t->kcov_mode);
>> +     /*
>> +      * There is some code that runs in interrupts but for which
>> +      * in_interrupt() returns false (e.g. preempt_schedule_irq()).
>> +      * READ_ONCE()/barrier() effectively provides load-acquire wrt
>> +      * interrupts, there are paired barrier()/WRITE_ONCE() in
>> +      * kcov_ioctl_locked().
>> +      */
>> +     barrier();
>> +     if (mode != needed_mode)
>> +             return false;
>> +     return true;
>
> This would be simpler as:
>
>         return mode == needed_mode;
>
> [...]
>
>> +     area = t->kcov_area;
>> +     /* The first 64-bit word is the number of subsequent PCs. */
>> +     pos = READ_ONCE(area[0]) + 1;
>> +     if (likely(pos < t->kcov_size)) {
>> +             area[pos] = ip;
>> +             WRITE_ONCE(area[0], pos);
>
> Not a new problem, but if the area for one thread is mmap'd, and read by
> another thread, these two writes could be seen out-of-order, since we
> don't have an smp_wmb() between them.
>
> I guess Syzkaller doesn't read the mmap'd kcov file from another thread?


Yes, that's the intention. If you read coverage from another thread,
you can't know coverage from what exactly you read. So the usage
pattern is:

reset coverage;
do something;
read coverage;



>
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
>> +     t = current;
>> +     if (!check_kcov_mode(KCOV_MODE_TRACE_CMP, t))
>> +             return;
>> +
>> +#ifdef CONFIG_RANDOMIZE_BASE
>> +     ip -= kaslr_offset();
>> +#endif
>
> Given we have this in two places, it might make sense to have a helper
> like:
>
> unsigned long canonicalize_ip(unsigned long ip)
> {
> #ifdef CONFIG_RANDOMIZE_BASE
>         ip -= kaslr_offset();
> #endif
>         return ip;
> }
>
> ... to minimize the ifdeffery elsewhere.
>
>> +
>> +     /*
>> +      * We write all comparison arguments and types as u64.
>> +      * The buffer was allocated for t->kcov_size unsigned longs.
>> +      */
>> +     area = (u64 *)t->kcov_area;
>> +     max_pos = t->kcov_size * sizeof(unsigned long);
>> +
>> +     count = READ_ONCE(area[0]);
>> +
>> +     /* Every record is KCOV_WORDS_PER_CMP 64-bit words. */
>> +     start_index = 1 + count * KCOV_WORDS_PER_CMP;
>> +     end_pos = (start_index + KCOV_WORDS_PER_CMP) * sizeof(u64);
>> +     if (likely(end_pos <= max_pos)) {
>> +             area[start_index] = type;
>> +             area[start_index + 1] = arg1;
>> +             area[start_index + 2] = arg2;
>> +             area[start_index + 3] = ip;
>> +             WRITE_ONCE(area[0], count + 1);
>
> That ordering problem applies here, too.
>
> Thanks,
> Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
