Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 273F56B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 15:37:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so63403002pfx.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:37:26 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10054.outbound.protection.outlook.com. [40.107.1.54])
        by mx.google.com with ESMTPS id j80si46522433pfa.194.2016.08.30.12.37.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 12:37:25 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
 <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com>
 <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com>
Date: Tue, 30 Aug 2016 15:37:02 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Viresh
 Kumar <viresh.kumar@linaro.org>, Ingo Molnar <mingo@kernel.org>, Steven
 Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On 8/30/2016 2:43 PM, Andy Lutomirski wrote:
> On Aug 30, 2016 10:02 AM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>> On 8/30/2016 12:30 PM, Andy Lutomirski wrote:
>>> On Tue, Aug 30, 2016 at 8:32 AM, Chris Metcalf <cmetcalf@mellanox.com> wrote:
>>>> The basic idea is just that we don't want to be at risk from the
>>>> dyntick getting enabled.  Similarly, we don't want to be at risk of a
>>>> later global IPI due to lru_add_drain stuff, for example.  And, we may
>>>> want to add additional stuff, like catching kernel TLB flushes and
>>>> deferring them when a remote core is in userspace.  To do all of this
>>>> kind of stuff, we need to run in the return to user path so we are
>>>> late enough to guarantee no further kernel things will happen to
>>>> perturb our carefully-arranged isolation state that includes dyntick
>>>> off, per-cpu lru cache empty, etc etc.
>>> None of the above should need to *loop*, though, AFAIK.
>> Ordering is a problem, though.
>>
>> We really want to run task isolation last, so we can guarantee that
>> all the isolation prerequisites are met (dynticks stopped, per-cpu lru
>> cache empty, etc).  But achieving that state can require enabling
>> interrupts - most obviously if we have to schedule, e.g. for vmstat
>> clearing or whatnot (see the cond_resched in refresh_cpu_vm_stats), or
>> just while waiting for that last dyntick interrupt to occur.  I'm also
>> not sure that even something as simple as draining the per-cpu lru
>> cache can be done holding interrupts disabled throughout - certainly
>> there's a !SMP code path there that just re-enables interrupts
>> unconditionally, which gives me pause.
>>
>> At any rate at that point you need to retest for signals, resched,
>> etc, all as usual, and then you need to recheck the task isolation
>> prerequisites once more.
>>
>> I may be missing something here, but it's really not obvious to me
>> that there's a way to do this without having task isolation integrated
>> into the usual return-to-userspace loop.
>>
> What if we did it the other way around: set a percpu flag saying
> "going quiescent; disallow new deferred work", then finish all
> existing work and return to userspace.  Then, on the next entry, clear
> that flag.  With the flag set, vmstat would just flush anything that
> it accumulates immediately, nothing would be added to the LRU list,
> etc.

This is an interesting idea!

However, there are a number of implementation ideas that make me
worry that it might be a trickier approach overall.

First, "on the next entry" hides a world of hurt in four simple words.
Some platforms (arm64 and tile, that I'm familiar with) have a common
chunk of code that always runs on every entry to the kernel.  It would
not be too hard to poke at the assembly and make those platforms
always run some task-isolation specific code on entry.  But x86 scares
me - there seem to be a whole lot of ways to get into the kernel, and
I'm not convinced there is a lot of shared macrology or whatever that
would make it straightforward to intercept all of them.

Then, there are the two actual subsystems in question.  It looks like
we could intercept LRU reasonably cleanly by hooking pagevec_add()
to return zero when we are in this "going quiescent" mode, and that
would keep the per-cpu vectors empty.  The vmstat stuff is a little
trickier since all the existing code is built around updating the per-cpu
stuff and then only later copying it off to the global state.  I suppose
we could add a test-and-flush at the end of every public API and not
worry about the implementation cost.

But it does seem like we are adding noticeable maintenance cost on
the mainline kernel to support task isolation by doing this.  My guess
is that it is easier to support the kind of "are you clean?" / "get clean"
APIs for subsystems, rather than weaving a whole set of "stay clean"
mechanism into each subsystem.

So to pop up a level, what is your actual concern about the existing
"do it in a loop" model?  The macrology currently in use means there
is zero cost if you don't configure TASK_ISOLATION, and the software
maintenance cost seems low since the idioms used for task isolation
in the loop are generally familiar to people reading that code.

> Also, this cond_resched stuff doesn't worry me too much at a
> fundamental level -- if we're really going quiescent, shouldn't we be
> able to arrange that there are no other schedulable tasks on the CPU
> in question?

We aren't currently planning to enforce things in the scheduler, so if
the application affinitizes another task on top of an existing task
isolation task, by default the task isolation task just dies. (Unless
it's using NOSIG mode, in which case it just ends up stuck in the
kernel trying to wait out the dyntick until you either kill it, or
re-affinitize the offending task.)  But I'm reluctant to guarantee
every possible way that you might (perhaps briefly) have some
schedulable task, and the current approach seems pretty robust if that
sort of thing happens.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
