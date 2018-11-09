Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEE716B06B0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 03:04:16 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f3-v6so1170410wme.9
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 00:04:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15-v6sor4804083wrr.16.2018.11.09.00.04.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 00:04:15 -0800 (PST)
Date: Fri, 9 Nov 2018 09:04:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
Message-ID: <20181109080412.GC86700@gmail.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Waiman Long <longman@redhat.com> wrote:

> The purpose of this patchset is to add a new class of locks called
> terminal locks and converts some of the low level raw or regular
> spinlocks to terminal locks. A terminal lock does not have forward
> dependency and it won't allow a lock or unlock operation on another
> lock. Two level nesting of terminal locks is allowed, though.
> 
> Only spinlocks that are acquired with the _irq/_irqsave variants or
> acquired in an IRQ disabled context should be classified as terminal
> locks.
> 
> Because of the restrictions on terminal locks, we can do simple checks on
> them without using the lockdep lock validation machinery. The advantages
> of making these changes are as follows:
> 
>  1) The lockdep check will be faster for terminal locks without using
>     the lock validation code.
>  2) It saves table entries used by the validation code and hence make
>     it harder to overflow those tables.
> 
> In fact, it is possible to overflow some of the tables by running
> a variety of different workloads on a debug kernel. I have seen bug
> reports about exhausting MAX_LOCKDEP_KEYS, MAX_LOCKDEP_ENTRIES and
> MAX_STACK_TRACE_ENTRIES. This patch will help to reduce the chance
> of overflowing some of the tables.
> 
> Performance wise, there was no statistically significant difference in
> performanace when doing a parallel kernel build on a debug kernel.

Could you please measure a locking intense workload instead, such as:

   $ perf stat --null --sync --repeat 10 perf bench sched messaging

and profile which locks used there could be marked terminal, and measure 
the before/after performance impact?

> Below were selected output lines from the lockdep_stats files of the
> patched and unpatched kernels after bootup and running parallel kernel
> builds.
> 
>   Item                     Unpatched kernel  Patched kernel  % Change
>   ----                     ----------------  --------------  --------
>   direct dependencies           9732             8994          -7.6%
>   dependency chains            18776            17033          -9.3%
>   dependency chain hlocks      76044            68419         -10.0%
>   stack-trace entries         110403           104341          -5.5%

That's pretty impressive!

> There were some reductions in the size of the lockdep tables. They were
> not significant, but it is still a good start to rein in the number of
> entries in those tables to make it harder to overflow them.

Agreed.

BTW., if you are interested in more radical approaches to optimize 
lockdep, we could also add a static checker via objtool driven call graph 
analysis, and mark those locks terminal that we can prove are terminal.

This would require the unified call graph of the kernel image and of all 
modules to be examined in a final pass, but that's within the principal 
scope of objtool. (This 'final pass' could also be done during bootup, at 
least in initial versions.)

Note that beyond marking it 'terminal' such a static analysis pass would 
also allow the detection of obvious locking bugs at the build (or boot) 
stage already - plus it would allow the disabling of lockdep for 
self-contained locks that don't interact with anything else.

I.e. the static analysis pass would 'augment' lockdep and leave only 
those locks active for runtime lockdep tracking whose dependencies it 
cannot prove to be correct yet.

Thanks,

	Ingo
