Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB576B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 13:02:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so55913210pfg.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:02:47 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0070.outbound.protection.outlook.com. [104.47.0.70])
        by mx.google.com with ESMTPS id or6si45998157pab.77.2016.08.30.10.02.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 10:02:42 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com>
Date: Tue, 30 Aug 2016 13:02:20 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 8/30/2016 12:30 PM, Andy Lutomirski wrote:
> On Tue, Aug 30, 2016 at 8:32 AM, Chris Metcalf <cmetcalf@mellanox.com> wrote:
>> On 8/30/2016 3:58 AM, Peter Zijlstra wrote:
>>> On Mon, Aug 29, 2016 at 12:40:32PM -0400, Chris Metcalf wrote:
>>>> On 8/29/2016 12:33 PM, Peter Zijlstra wrote:
>>>>> On Tue, Aug 16, 2016 at 05:19:27PM -0400, Chris Metcalf wrote:
>>>>>> +       /*
>>>>>> +        * Request rescheduling unless we are in full dynticks mode.
>>>>>> +        * We would eventually get pre-empted without this, and if
>>>>>> +        * there's another task waiting, it would run; but by
>>>>>> +        * explicitly requesting the reschedule, we may reduce the
>>>>>> +        * latency.  We could directly call schedule() here as well,
>>>>>> +        * but since our caller is the standard place where schedule()
>>>>>> +        * is called, we defer to the caller.
>>>>>> +        *
>>>>>> +        * A more substantive approach here would be to use a struct
>>>>>> +        * completion here explicitly, and complete it when we shut
>>>>>> +        * down dynticks, but since we presumably have nothing better
>>>>>> +        * to do on this core anyway, just spinning seems plausible.
>>>>>> +        */
>>>>>> +       if (!tick_nohz_tick_stopped())
>>>>>> +               set_tsk_need_resched(current);
>>>>> This is broken.. and it would be really good if you don't actually need
>>>>> to do this.
>>>> Can you elaborate?  We clearly do want to wait until we are in full
>>>> dynticks mode before we return to userspace.
>>>>
>>>> We could do it just in the prctl() syscall only, but then we lose the
>>>> ability to implement the NOSIG mode, which can be a convenience.
>>> So this isn't spelled out anywhere. Why does this need to be in the
>>> return to user path?
>>
>> I'm not sure where this should be spelled out, to be honest.  I guess
>> I can add some commentary to the commit message explaining this part.
>>
>> The basic idea is just that we don't want to be at risk from the
>> dyntick getting enabled.  Similarly, we don't want to be at risk of a
>> later global IPI due to lru_add_drain stuff, for example.  And, we may
>> want to add additional stuff, like catching kernel TLB flushes and
>> deferring them when a remote core is in userspace.  To do all of this
>> kind of stuff, we need to run in the return to user path so we are
>> late enough to guarantee no further kernel things will happen to
>> perturb our carefully-arranged isolation state that includes dyntick
>> off, per-cpu lru cache empty, etc etc.
> None of the above should need to *loop*, though, AFAIK.

Ordering is a problem, though.

We really want to run task isolation last, so we can guarantee that
all the isolation prerequisites are met (dynticks stopped, per-cpu lru
cache empty, etc).  But achieving that state can require enabling
interrupts - most obviously if we have to schedule, e.g. for vmstat
clearing or whatnot (see the cond_resched in refresh_cpu_vm_stats), or
just while waiting for that last dyntick interrupt to occur.  I'm also
not sure that even something as simple as draining the per-cpu lru
cache can be done holding interrupts disabled throughout - certainly
there's a !SMP code path there that just re-enables interrupts
unconditionally, which gives me pause.

At any rate at that point you need to retest for signals, resched,
etc, all as usual, and then you need to recheck the task isolation
prerequisites once more.

I may be missing something here, but it's really not obvious to me
that there's a way to do this without having task isolation integrated
into the usual return-to-userspace loop.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
