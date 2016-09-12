Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6E1C6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:25:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id o7so325588474oif.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 12:25:25 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40059.outbound.protection.outlook.com. [40.107.4.59])
        by mx.google.com with ESMTPS id k26si11262438otb.44.2016.09.12.12.25.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 12:25:24 -0700 (PDT)
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
 <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com>
 <CALCETrX80akvpLNRQfJsDV560npSa33hSsUB5OYkAtnAn8R7Dg@mail.gmail.com>
 <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com>
 <CALCETrXrsZjMjdd1jACbrz8GMXQC5FmF8BbkHobmMCbG5GPN7w@mail.gmail.com>
 <440e20d1-441a-3228-6b37-6e71e9fce47c@mellanox.com>
 <CALCETrV7n5Qs0Kkb-cwC3JWsngfR8hd+JrW87OvPCgRHmCdK8A@mail.gmail.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <84b47c50-6f1b-dcdb-c90e-471d1b4adbac@mellanox.com>
Date: Mon, 12 Sep 2016 15:25:04 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrV7n5Qs0Kkb-cwC3JWsngfR8hd+JrW87OvPCgRHmCdK8A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Viresh
 Kumar <viresh.kumar@linaro.org>, Ingo Molnar <mingo@kernel.org>, Steven
 Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On 9/12/2016 1:41 PM, Andy Lutomirski wrote:
> On Sep 9, 2016 1:40 PM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>> On 9/2/2016 1:28 PM, Andy Lutomirski wrote:
>>> On Sep 2, 2016 7:04 AM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>>>> On 8/30/2016 3:50 PM, Andy Lutomirski wrote:
>>>>> On Tue, Aug 30, 2016 at 12:37 PM, Chris Metcalf <cmetcalf@mellanox.com> wrote:
>>>>>> So to pop up a level, what is your actual concern about the existing
>>>>>> "do it in a loop" model?  The macrology currently in use means there
>>>>>> is zero cost if you don't configure TASK_ISOLATION, and the software
>>>>>> maintenance cost seems low since the idioms used for task isolation
>>>>>> in the loop are generally familiar to people reading that code.
>>>>> My concern is that it's not obvious to readers of the code that the
>>>>> loop ever terminates.  It really ought to, but it's doing something
>>>>> very odd.  Normally we can loop because we get scheduled out, but
>>>>> actually blocking in the return-to-userspace path, especially blocking
>>>>> on a condition that doesn't have a wakeup associated with it, is odd.
>>>>
>>>> True, although, comments :-)
>>>>
>>>> Regardless, though, this doesn't seem at all weird to me in the
>>>> context of the vmstat and lru stuff, though.  It's exactly parallel to
>>>> the fact that we loop around on checking need_resched and signal, and
>>>> in some cases you could imagine multiple loops around when we schedule
>>>> out and get a signal, so loop around again, and then another
>>>> reschedule event happens during signal processing so we go around
>>>> again, etc.  Eventually it settles down.  It's the same with the
>>>> vmstat/lru stuff.
>>> Only kind of.
>>>
>>> When we say, effectively, while (need_resched()) schedule();, we're
>>> not waiting for an event or condition per se.  We're runnable (in the
>>> sense that userspace wants to run and we're not blocked on anything)
>>> the entire time -- we're simply yielding to some other thread that is
>>> also runnable.  So if that loop runs forever, it either means that
>>> we're at low priority and we genuinely shouldn't be running or that
>>> there's a scheduler bug.
>>>
>>> If, on the other hand, we say while (not quiesced) schedule(); (or
>>> equivalent), we're saying that we're *not* really ready to run and
>>> that we're waiting for some condition to change.  The condition in
>>> question is fairly complicated and won't wake us when we are ready.  I
>>> can also imagine the scheduler getting rather confused, since, as far
>>> as the scheduler knows, we are runnable and we are supposed to be
>>> running.
>>
>> So, how about a code structure like this?
>>
>> In the main return-to-userspace loop where we check TIF flags,
>> we keep the notion of our TIF_TASK_ISOLATION flag that causes
>> us to invoke a task_isolation_prepare() routine.  This routine
>> does the following things:
>>
>> 1. As you suggested, set a new TIF bit (or equivalent) that says the
>> system should no longer create deferred work on this core, and then
>> flush any necessary already-deferred work (currently, the LRU cache
>> and the vmstat stuff).  We never have to go flush the deferred work
>> again during this task's return to userspace.  Note that this bit can
>> only be set on a core marked for task isolation, so it can't be used
>> for denial of service type attacks on normal cores that are trying to
>> multitask normal Linux processes.
> I think it can't be a TIF flag unless you can do the whole mess with
> preemption off because, if you get preempted, other tasks on the CPU
> won't see the flag.  You could do it with a percpu flag, I think.

Yes, a percpu flag - you're right.  I think it will make sense for this to
be a flag declared in linux/isolation.h which can be read by vmstat, LRU, etc.

>> 2. Check if the dyntick is stopped, and if not, wait on a completion
>> that will be set when it does stop.  This means we may schedule out at
>> this point, but when we return, the deferred work stuff is still safe
>> since your bit is still set, and in principle the dyn tick is
>> stopped.
>>
>> Then, after we disable interrupts and re-read the thread-info flags,
>> we check to see if the TIF_TASK_ISOLATION flag is the ONLY flag still
>> set that would keep us in the loop.  This will always end up happening
>> on each return to userspace, since the only thing that actually clears
>> the bit is a prctl() call.  When that happens we know we are about to
>> return to userspace, so we call task_isolation_ready(), which now has
>> two things to do:
> Would it perhaps be more straightforward to do the stuff before the
> loop and not check TIF_TASK_ISOLATION in the loop?

We can certainly play around with just not looping in this case, but
in particular I can imagine an isolated task entering the kernel and
then doing something that requires scheduling a kernel task.  We'd
clearly like that other task to run before the isolated task returns to
userspace.  But then, that other task might do something to re-enable
the dyntick.  That's why we'd like to recheck that dyntick is off in
the loop after each potential call to schedule().

>> 1. We check that the dyntick is in fact stopped, since it's possible
>> that a race condition led to it being somehow restarted by an interrupt.
>> If it is not stopped, we go around the loop again so we can go back in
>> to the completion discussed above and wait some more.  This may merit
>> a WARN_ON or other notice since it seems like people aren't convinced
>> there are things that could restart it, but honestly the dyntick stuff
>> is complex enough that I think a belt-and-suspenders kind of test here
>> at the last minute is just defensive programming.
> Seems reasonable.  But maybe this could go after the loop and, if the
> dyntick is back, it could be treated like any other kernel bug that
> interrupts an isolated task?  That would preserve more of the existing
> code structure.

Well, we can certainly try it that way.  If I move it out and my testing
doesn't trigger the bug, that's at least an initial sign that it might be
OK.  But I worry/suspect that it will trip up at some point in some use
case and we'll have to fix it at that point.

> If that works, it could go in user_enter().

Presumably with trace_user_enter() and vtime_user_enter()
in __context_tracking_enter()?

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
