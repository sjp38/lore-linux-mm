Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 653D46B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 16:49:33 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id q77so39371119vka.7
        for <linux-mm@kvack.org>; Tue, 16 May 2017 13:49:33 -0700 (PDT)
Received: from mail-ua0-x22c.google.com (mail-ua0-x22c.google.com. [2607:f8b0:400c:c08::22c])
        by mx.google.com with ESMTPS id j21si167631uag.168.2017.05.16.13.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 13:49:31 -0700 (PDT)
Received: by mail-ua0-x22c.google.com with SMTP id e28so107732269uah.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 13:49:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170516062318.GC16015@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com> <20170516062318.GC16015@js1304-desktop>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 16 May 2017 13:49:10 -0700
Message-ID: <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Mon, May 15, 2017 at 11:23 PM, Joonsoo Kim <js1304@gmail.com> wrote:
>> >
>> > Hello, all.
>> >
>> > This is an attempt to recude memory consumption of KASAN. Please see
>> > following description to get the more information.
>> >
>> > 1. What is per-page shadow memory
>>
>> Hi Joonsoo,
>
> Hello, Dmitry.
>
>>
>> First I need to say that this is great work. I wanted KASAN to consume
>
> Thanks!
>
>> 1/8-th of _kernel_ memory rather than total physical memory for a long
>> time.
>>
>> However, this implementation does not work inline instrumentation. And
>> the inline instrumentation is the main mode for KASAN. Outline
>> instrumentation is merely a rudiment to support gcc 4.9, and it needs
>> to be removed as soon as we stop caring about gcc 4.9 (do we at all?
>> is it the current compiler in any distro? Ubuntu 12 has 4.8, Ubuntu 14
>> already has 5.4. And if you build gcc yourself or get a fresher
>> compiler from somewhere else, you hopefully get something better than
>> 4.9).
>
> Hmm... I don't think that outline instrumentation is something to be
> removed. In embedded world, there is a fixed partition table and
> enlarging the kernel binary would cause the problem. Changing that
> table is possible but is really uncomfortable thing for debugging
> something. So, I think that outline instrumentation has it's own merit.

Fair. Let's consider both as important.

> Anyway, I have missed inline instrumentation completely.
>
> I will attach the fix in the bottom. It doesn't look beautiful
> since it breaks layer design (some check will be done at report
> function). However, I think that it's a good trade-off.


I can confirm that inline works with that patch.

I can also confirm that it reduces memory usage. I've booted qemu with
2G ram and run some fixed workload. Before:
31853 dvyukov   20   0 3043200 765464  21312 S 366.0  4.7   2:39.53
qemu-system-x86
 7528 dvyukov   20   0 3043200 732444  21676 S 333.3  4.5   2:23.19
qemu-system-x86
After:
6192 dvyukov   20   0 3043200 394244  20636 S  17.9  2.4   2:32.95
qemu-system-x86
 6265 dvyukov   20   0 3043200 388860  21416 S 399.3  2.4   3:02.88
qemu-system-x86
 9005 dvyukov   20   0 3043200 383564  21220 S 397.1  2.3   2:35.33
qemu-system-x86

However, I see some very significant slowdowns with inline
instrumentation. I did 3 tests:
1. Boot speed, I measured time for a particular message to appear on
console. Before:
[    2.504652] random: crng init done
[    2.435861] random: crng init done
[    2.537135] random: crng init done
After:
[    7.263402] random: crng init done
[    7.263402] random: crng init done
[    7.174395] random: crng init done

That's ~3x slowdown.

2. I've run bench_readv benchmark:
https://raw.githubusercontent.com/google/sanitizers/master/address-sanitizer/kernel_buildbot/slave/bench_readv.c
as:
while true; do time ./bench_readv bench_readv 300000 1; done

Before:
sys 0m7.299s
sys 0m7.218s
sys 0m6.973s
sys 0m6.892s
sys 0m7.035s
sys 0m6.982s
sys 0m6.921s
sys 0m6.940s
sys 0m6.905s
sys 0m7.006s

After:
sys 0m8.141s
sys 0m8.077s
sys 0m8.067s
sys 0m8.116s
sys 0m8.128s
sys 0m8.115s
sys 0m8.108s
sys 0m8.326s
sys 0m8.529s
sys 0m8.164s
sys 0m8.380s

This is ~19% slowdown.

3. I've run bench_pipes benchmark:
https://raw.githubusercontent.com/google/sanitizers/master/address-sanitizer/kernel_buildbot/slave/bench_pipes.c
as:
while true; do time ./bench_pipes 10 10000 1; done

Before:
sys 0m5.393s
sys 0m6.178s
sys 0m5.909s
sys 0m6.024s
sys 0m5.874s
sys 0m5.737s
sys 0m5.826s
sys 0m5.664s
sys 0m5.758s
sys 0m5.421s
sys 0m5.444s
sys 0m5.479s
sys 0m5.461s
sys 0m5.417s

After:
sys 0m8.718s
sys 0m8.281s
sys 0m8.268s
sys 0m8.334s
sys 0m8.246s
sys 0m8.267s
sys 0m8.265s
sys 0m8.437s
sys 0m8.228s
sys 0m8.312s
sys 0m8.556s
sys 0m8.680s

This is ~52% slowdown.


This does not look acceptable to me. I would ready to pay for this,
say, 10% of performance. But it seems that this can have up to 2-4x
slowdown for some workloads.


Your use-case is embed devices where you care a lot about both code
size and memory consumption, right?

I see 2 possible ways forward:
1. Enable this new mode only for outline, but keep current scheme for
inline. Then outline will be "small but slow" type of configuration.
2. Somehow fix slowness (at least in inline mode).


> Mapping zero page to non-kernel memory could cause true-negative
> problem since we cannot flush the TLB in all cpus. We will read zero
> shadow value value in this case even if actual shadow value is not
> zero. This is one of the reason that black page is introduced in this
> patchset.

What does make your current patch work then?
Say we map a new shadow page, update the page shadow to say that there
is mapped shadow. Then another CPU loads the page shadow and then
loads from the newly mapped shadow. If we don't flush TLB, what makes
the second CPU see the newly mapped shadow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
