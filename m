Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB8AB6B0706
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 10:48:43 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so3639660qkb.23
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 07:48:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r32si307260qvj.117.2018.11.09.07.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 07:48:42 -0800 (PST)
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <1fcaa330-a4be-0f8a-7974-7b17f0ce01ad@redhat.com>
Date: Fri, 9 Nov 2018 10:48:39 -0500
MIME-Version: 1.0
In-Reply-To: <20181109080412.GC86700@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/09/2018 03:04 AM, Ingo Molnar wrote:
> * Waiman Long <longman@redhat.com> wrote:
>
>> The purpose of this patchset is to add a new class of locks called
>> terminal locks and converts some of the low level raw or regular
>> spinlocks to terminal locks. A terminal lock does not have forward
>> dependency and it won't allow a lock or unlock operation on another
>> lock. Two level nesting of terminal locks is allowed, though.
>>
>> Only spinlocks that are acquired with the _irq/_irqsave variants or
>> acquired in an IRQ disabled context should be classified as terminal
>> locks.
>>
>> Because of the restrictions on terminal locks, we can do simple checks=
 on
>> them without using the lockdep lock validation machinery. The advantag=
es
>> of making these changes are as follows:
>>
>>  1) The lockdep check will be faster for terminal locks without using
>>     the lock validation code.
>>  2) It saves table entries used by the validation code and hence make
>>     it harder to overflow those tables.
>>
>> In fact, it is possible to overflow some of the tables by running
>> a variety of different workloads on a debug kernel. I have seen bug
>> reports about exhausting MAX_LOCKDEP_KEYS, MAX_LOCKDEP_ENTRIES and
>> MAX_STACK_TRACE_ENTRIES. This patch will help to reduce the chance
>> of overflowing some of the tables.
>>
>> Performance wise, there was no statistically significant difference in=

>> performanace when doing a parallel kernel build on a debug kernel.
> Could you please measure a locking intense workload instead, such as:
>
>    $ perf stat --null --sync --repeat 10 perf bench sched messaging
>
> and profile which locks used there could be marked terminal, and measur=
e=20
> the before/after performance impact?

I will run the test. It will probably be done after the LPC next week.

>> Below were selected output lines from the lockdep_stats files of the
>> patched and unpatched kernels after bootup and running parallel kernel=

>> builds.
>>
>>   Item                     Unpatched kernel  Patched kernel  % Change
>>   ----                     ----------------  --------------  --------
>>   direct dependencies           9732             8994          -7.6%
>>   dependency chains            18776            17033          -9.3%
>>   dependency chain hlocks      76044            68419         -10.0%
>>   stack-trace entries         110403           104341          -5.5%
> That's pretty impressive!
>
>> There were some reductions in the size of the lockdep tables. They wer=
e
>> not significant, but it is still a good start to rein in the number of=

>> entries in those tables to make it harder to overflow them.
> Agreed.
>
> BTW., if you are interested in more radical approaches to optimize=20
> lockdep, we could also add a static checker via objtool driven call gra=
ph=20
> analysis, and mark those locks terminal that we can prove are terminal.=

>
> This would require the unified call graph of the kernel image and of al=
l=20
> modules to be examined in a final pass, but that's within the principal=
=20
> scope of objtool. (This 'final pass' could also be done during bootup, =
at=20
> least in initial versions.)
>
> Note that beyond marking it 'terminal' such a static analysis pass woul=
d=20
> also allow the detection of obvious locking bugs at the build (or boot)=
=20
> stage already - plus it would allow the disabling of lockdep for=20
> self-contained locks that don't interact with anything else.
>
> I.e. the static analysis pass would 'augment' lockdep and leave only=20
> those locks active for runtime lockdep tracking whose dependencies it=20
> cannot prove to be correct yet.

It is a pretty interesting idea to use objtool to scan for locks. The
list of locks that I marked as terminal in this patch was found by
looking at /proc/lockdep for those that only have backward dependencies,
but no forward dependency. I focused on those with a large number of BDs
and check the code to see if they could marked as terminal. This is a
rather labor intensive process and is subject to error. It would be nice
if it can be done by an automated tool. So I am going to look into that,
but it won't be part of this initial patchset, though.

I sent this patchset out to see if anyone has any objection to it. It
seems you don't have any objection to that. So I am going to move ahead
to do more testing and performance analysis.

Thanks,
Longman
