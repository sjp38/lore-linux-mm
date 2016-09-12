Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34F616B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 13:41:27 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id x93so329661236ybh.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:41:27 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id g1si5688360vkh.11.2016.09.12.10.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 10:41:26 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id f76so146596790vke.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:41:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <440e20d1-441a-3228-6b37-6e71e9fce47c@mellanox.com>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com> <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com> <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com> <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
 <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com> <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
 <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com> <CALCETrX80akvpLNRQfJsDV560npSa33hSsUB5OYkAtnAn8R7Dg@mail.gmail.com>
 <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com> <CALCETrXrsZjMjdd1jACbrz8GMXQC5FmF8BbkHobmMCbG5GPN7w@mail.gmail.com>
 <440e20d1-441a-3228-6b37-6e71e9fce47c@mellanox.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 12 Sep 2016 10:41:05 -0700
Message-ID: <CALCETrV7n5Qs0Kkb-cwC3JWsngfR8hd+JrW87OvPCgRHmCdK8A@mail.gmail.com>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On Sep 9, 2016 1:40 PM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>
> On 9/2/2016 1:28 PM, Andy Lutomirski wrote:
>>
>> On Sep 2, 2016 7:04 AM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>>>
>>> On 8/30/2016 3:50 PM, Andy Lutomirski wrote:
>>>>
>>>> On Tue, Aug 30, 2016 at 12:37 PM, Chris Metcalf <cmetcalf@mellanox.com> wrote:
>>>>>
>>>>> On 8/30/2016 2:43 PM, Andy Lutomirski wrote:
>>>>>>
>>>>>> What if we did it the other way around: set a percpu flag saying
>>>>>> "going quiescent; disallow new deferred work", then finish all
>>>>>> existing work and return to userspace.  Then, on the next entry, clear
>>>>>> that flag.  With the flag set, vmstat would just flush anything that
>>>>>> it accumulates immediately, nothing would be added to the LRU list,
>>>>>> etc.
>>>>>
>>>>>
>>>>> This is an interesting idea!
>>>>>
>>>>> However, there are a number of implementation ideas that make me
>>>>> worry that it might be a trickier approach overall.
>>>>>
>>>>> First, "on the next entry" hides a world of hurt in four simple words.
>>>>> Some platforms (arm64 and tile, that I'm familiar with) have a common
>>>>> chunk of code that always runs on every entry to the kernel.  It would
>>>>> not be too hard to poke at the assembly and make those platforms
>>>>> always run some task-isolation specific code on entry.  But x86 scares
>>>>> me - there seem to be a whole lot of ways to get into the kernel, and
>>>>> I'm not convinced there is a lot of shared macrology or whatever that
>>>>> would make it straightforward to intercept all of them.
>>>>
>>>> Just use the context tracking entry hook.  It's 100% reliable.  The
>>>> relevant x86 function is enter_from_user_mode(), but I would just hook
>>>> into user_exit() in the common code.  (This code is had better be
>>>> reliable, because context tracking depends on it, and, if context
>>>> tracking doesn't work on a given arch, then isolation isn't going to
>>>> work regardless.
>>>
>>>
>>> This looks a lot cleaner than last time I looked at the x86 code. So yes, I think
>>> we could do an entry-point approach plausibly now.
>>>
>>> This is also good for when we want to look at deferring the kernel TLB flush,
>>> since it's the same mechanism that would be required for that.
>>>
>>>
>> There's at least one gotcha for the latter: NMIs aren't currently
>> guaranteed to go through context tracking.  Instead they use their own
>> RCU hooks.  Deferred TLB flushes can still be made to work, but a bit
>> more care will be needed.  I would probably approach it with an
>> additional NMI hook in the same places as rcu_nmi_enter() that does,
>> more or less:
>>
>> if (need_tlb_flush) flush();
>>
>> and then make sure that the normal exit hook looks like:
>>
>> if (need_tlb_flush) {
>>    flush();
>>    barrier(); /* An NMI must not see !need_tlb_flush if the TLB hasn't
>> been flushed */
>>    flush the TLB;
>> }
>
>
> This is a good point.  For now I will continue not trying to include the TLB flush
> in the current patch series, so I will sit on this until we're ready to do so.
>
>
>>>>> So to pop up a level, what is your actual concern about the existing
>>>>> "do it in a loop" model?  The macrology currently in use means there
>>>>> is zero cost if you don't configure TASK_ISOLATION, and the software
>>>>> maintenance cost seems low since the idioms used for task isolation
>>>>> in the loop are generally familiar to people reading that code.
>>>>
>>>> My concern is that it's not obvious to readers of the code that the
>>>> loop ever terminates.  It really ought to, but it's doing something
>>>> very odd.  Normally we can loop because we get scheduled out, but
>>>> actually blocking in the return-to-userspace path, especially blocking
>>>> on a condition that doesn't have a wakeup associated with it, is odd.
>>>
>>>
>>> True, although, comments :-)
>>>
>>> Regardless, though, this doesn't seem at all weird to me in the
>>> context of the vmstat and lru stuff, though.  It's exactly parallel to
>>> the fact that we loop around on checking need_resched and signal, and
>>> in some cases you could imagine multiple loops around when we schedule
>>> out and get a signal, so loop around again, and then another
>>> reschedule event happens during signal processing so we go around
>>> again, etc.  Eventually it settles down.  It's the same with the
>>> vmstat/lru stuff.
>>
>> Only kind of.
>>
>> When we say, effectively, while (need_resched()) schedule();, we're
>> not waiting for an event or condition per se.  We're runnable (in the
>> sense that userspace wants to run and we're not blocked on anything)
>> the entire time -- we're simply yielding to some other thread that is
>> also runnable.  So if that loop runs forever, it either means that
>> we're at low priority and we genuinely shouldn't be running or that
>> there's a scheduler bug.
>>
>> If, on the other hand, we say while (not quiesced) schedule(); (or
>> equivalent), we're saying that we're *not* really ready to run and
>> that we're waiting for some condition to change.  The condition in
>> question is fairly complicated and won't wake us when we are ready.  I
>> can also imagine the scheduler getting rather confused, since, as far
>> as the scheduler knows, we are runnable and we are supposed to be
>> running.
>
>
> So, how about a code structure like this?
>
> In the main return-to-userspace loop where we check TIF flags,
> we keep the notion of our TIF_TASK_ISOLATION flag that causes
> us to invoke a task_isolation_prepare() routine.  This routine
> does the following things:
>
> 1. As you suggested, set a new TIF bit (or equivalent) that says the
> system should no longer create deferred work on this core, and then
> flush any necessary already-deferred work (currently, the LRU cache
> and the vmstat stuff).  We never have to go flush the deferred work
> again during this task's return to userspace.  Note that this bit can
> only be set on a core marked for task isolation, so it can't be used
> for denial of service type attacks on normal cores that are trying to
> multitask normal Linux processes.

I think it can't be a TIF flag unless you can do the whole mess with
preemption off because, if you get preempted, other tasks on the CPU
won't see the flag.  You could do it with a percpu flag, I think.

>
> 2. Check if the dyntick is stopped, and if not, wait on a completion
> that will be set when it does stop.  This means we may schedule out at
> this point, but when we return, the deferred work stuff is still safe
> since your bit is still set, and in principle the dyn tick is
> stopped.
>
> Then, after we disable interrupts and re-read the thread-info flags,
> we check to see if the TIF_TASK_ISOLATION flag is the ONLY flag still
> set that would keep us in the loop.  This will always end up happening
> on each return to userspace, since the only thing that actually clears
> the bit is a prctl() call.  When that happens we know we are about to
> return to userspace, so we call task_isolation_ready(), which now has
> two things to do:

Would it perhaps be more straightforward to do the stuff before the
loop and not check TIF_TASK_ISOLATION in the loop?

>
> 1. We check that the dyntick is in fact stopped, since it's possible
> that a race condition led to it being somehow restarted by an interrupt.
> If it is not stopped, we go around the loop again so we can go back in
> to the completion discussed above and wait some more.  This may merit
> a WARN_ON or other notice since it seems like people aren't convinced
> there are things that could restart it, but honestly the dyntick stuff
> is complex enough that I think a belt-and-suspenders kind of test here
> at the last minute is just defensive programming.

Seems reasonable.  But maybe this could go after the loop and, if the
dyntick is back, it could be treated like any other kernel bug that
interrupts an isolated task?  That would preserve more of the existing
code structure.

If that works, it could go in user_enter().

>
> 2. Assuming it's stopped, we clear your bit at this point, and
> return "true" so the loop code knows to break out of the loop and do
> the actual return to userspace.  Clearing the bit at this point is
> better than waiting until we re-enter the kernel later, since it
> avoids having to figure out all the ways we actually can re-enter.
> With interrupts disabled, and this late in the return to userspace
> process, there's no way additional deferred work can be created.
>
>
>>>>>> Also, this cond_resched stuff doesn't worry me too much at a
>>>>>> fundamental level -- if we're really going quiescent, shouldn't we be
>>>>>> able to arrange that there are no other schedulable tasks on the CPU
>>>>>> in question?
>>>>>
>>>>> We aren't currently planning to enforce things in the scheduler, so if
>>>>> the application affinitizes another task on top of an existing task
>>>>> isolation task, by default the task isolation task just dies. (Unless
>>>>> it's using NOSIG mode, in which case it just ends up stuck in the
>>>>> kernel trying to wait out the dyntick until you either kill it, or
>>>>> re-affinitize the offending task.)  But I'm reluctant to guarantee
>>>>> every possible way that you might (perhaps briefly) have some
>>>>> schedulable task, and the current approach seems pretty robust if that
>>>>> sort of thing happens.
>>>>
>>>> This kind of waiting out the dyntick scares me.  Why is there ever a
>>>> dyntick that you're waiting out?  If quiescence is to be a supported
>>>> mainline feature, shouldn't the scheduler be integrated well enough
>>>> with it that you don't need to wait like this?
>>>
>>>
>>> Well, this is certainly the funkiest piece of the task isolation
>>> stuff.  The problem is that the dyntick stuff may, for example, need
>>> one more tick 4us from now (or whatever) just to close out the current
>>> RCU period.  We can't return to userspace until that happens.  So what
>>> else can we do when the task is ready to return to userspace?  We
>>> could punt into the idle task instead of waiting in this task, which
>>> was my earlier schedule_time() suggestion.  Do you think that's cleaner?
>>>
>> Unless I'm missing something (which is reasonably likely), couldn't
>> the isolation code just force or require rcu_nocbs on the isolated
>> CPUs to avoid this problem entirely.
>>
>> I admit I still don't understand why the RCU context tracking code
>> can't just run the callback right away instead of waiting however many
>> microseconds in general.  I feel like paulmck has explained it to me
>> at least once, but that doesn't mean I remember the answer.
>
>
> I admit I am not clear on this either.  However, since there are a
> bunch of reasons why the dyntick might run (not just LRU), I think
> fixing LRU may well not be enough to guarantee the dyntick
> turns off exactly when we'd like it to.
>
> And, with the structure proposed here, we can always come back
> and revisit this by just removing the code that does the completion
> waiting and replacing it with a call that just tells the dyntick to
> just stop immediately, once we're confident we can make that work.
>
> Then separately, we can also think about removing the code that
> re-checks dyntick being stopped as we are about to return to
> userspace with interrupts disabled, if we're convinced there's
> also no way for the dyntick to get restarted due to an interrupt
> being handled after we think the dyntick has been stopped.
> I'd argue always leaving a WARN_ON() there would be good, though.
>
>
> --
> Chris Metcalf, Mellanox Technologies
> http://www.mellanox.com
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
