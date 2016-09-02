Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEA86B0069
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 13:28:23 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x187so54940036vkx.2
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 10:28:23 -0700 (PDT)
Received: from mail-ua0-x231.google.com (mail-ua0-x231.google.com. [2607:f8b0:400c:c08::231])
        by mx.google.com with ESMTPS id x33si5165693uax.232.2016.09.02.10.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 10:28:21 -0700 (PDT)
Received: by mail-ua0-x231.google.com with SMTP id l94so183825085ual.0
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 10:28:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com> <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com> <20160830075854.GZ10153@twins.programming.kicks-ass.net>
 <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com> <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
 <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com> <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
 <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com> <CALCETrX80akvpLNRQfJsDV560npSa33hSsUB5OYkAtnAn8R7Dg@mail.gmail.com>
 <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 2 Sep 2016 10:28:00 -0700
Message-ID: <CALCETrXrsZjMjdd1jACbrz8GMXQC5FmF8BbkHobmMCbG5GPN7w@mail.gmail.com>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Linux API <linux-api@vger.kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Will Deacon <will.deacon@arm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On Sep 2, 2016 7:04 AM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
>
> On 8/30/2016 3:50 PM, Andy Lutomirski wrote:
>>
>> On Tue, Aug 30, 2016 at 12:37 PM, Chris Metcalf <cmetcalf@mellanox.com> wrote:
>>>
>>> On 8/30/2016 2:43 PM, Andy Lutomirski wrote:
>>>>
>>>> What if we did it the other way around: set a percpu flag saying
>>>> "going quiescent; disallow new deferred work", then finish all
>>>> existing work and return to userspace.  Then, on the next entry, clear
>>>> that flag.  With the flag set, vmstat would just flush anything that
>>>> it accumulates immediately, nothing would be added to the LRU list,
>>>> etc.
>>>
>>>
>>> This is an interesting idea!
>>>
>>> However, there are a number of implementation ideas that make me
>>> worry that it might be a trickier approach overall.
>>>
>>> First, "on the next entry" hides a world of hurt in four simple words.
>>> Some platforms (arm64 and tile, that I'm familiar with) have a common
>>> chunk of code that always runs on every entry to the kernel.  It would
>>> not be too hard to poke at the assembly and make those platforms
>>> always run some task-isolation specific code on entry.  But x86 scares
>>> me - there seem to be a whole lot of ways to get into the kernel, and
>>> I'm not convinced there is a lot of shared macrology or whatever that
>>> would make it straightforward to intercept all of them.
>>
>> Just use the context tracking entry hook.  It's 100% reliable.  The
>> relevant x86 function is enter_from_user_mode(), but I would just hook
>> into user_exit() in the common code.  (This code is had better be
>> reliable, because context tracking depends on it, and, if context
>> tracking doesn't work on a given arch, then isolation isn't going to
>> work regardless.
>
>
> This looks a lot cleaner than last time I looked at the x86 code. So yes, I think
> we could do an entry-point approach plausibly now.
>
> This is also good for when we want to look at deferring the kernel TLB flush,
> since it's the same mechanism that would be required for that.
>
>

There's at least one gotcha for the latter: NMIs aren't currently
guaranteed to go through context tracking.  Instead they use their own
RCU hooks.  Deferred TLB flushes can still be made to work, but a bit
more care will be needed.  I would probably approach it with an
additional NMI hook in the same places as rcu_nmi_enter() that does,
more or less:

if (need_tlb_flush) flush();

and then make sure that the normal exit hook looks like:

if (need_tlb_flush) {
  flush();
  barrier(); /* An NMI must not see !need_tlb_flush if the TLB hasn't
been flushed */
  flush the TLB;
}

>>> But it does seem like we are adding noticeable maintenance cost on
>>> the mainline kernel to support task isolation by doing this.  My guess
>>> is that it is easier to support the kind of "are you clean?" / "get clean"
>>> APIs for subsystems, rather than weaving a whole set of "stay clean"
>>> mechanism into each subsystem.
>>
>> My intuition is that it's the other way around.  For the mainline
>> kernel, having a nice clean well-integrated implementation is nicer
>> than having a bolted-on implementation that interacts in potentially
>> complicated ways.  Once quiescence support is in mainline, the size of
>> the diff or the degree to which it's scattered around is irrelevant
>> because it's not a diff any more.
>
>
> I'm not concerned with the size of the diff, just with the intrusiveness into
> the various subsystems.
>
> That said, code talks, so let me take a swing at doing it the way you suggest
> for vmstat/lru and we'll see what it looks like.

Thanks :)

>
>
>>> So to pop up a level, what is your actual concern about the existing
>>> "do it in a loop" model?  The macrology currently in use means there
>>> is zero cost if you don't configure TASK_ISOLATION, and the software
>>> maintenance cost seems low since the idioms used for task isolation
>>> in the loop are generally familiar to people reading that code.
>>
>> My concern is that it's not obvious to readers of the code that the
>> loop ever terminates.  It really ought to, but it's doing something
>> very odd.  Normally we can loop because we get scheduled out, but
>> actually blocking in the return-to-userspace path, especially blocking
>> on a condition that doesn't have a wakeup associated with it, is odd.
>
>
> True, although, comments :-)
>
> Regardless, though, this doesn't seem at all weird to me in the
> context of the vmstat and lru stuff, though.  It's exactly parallel to
> the fact that we loop around on checking need_resched and signal, and
> in some cases you could imagine multiple loops around when we schedule
> out and get a signal, so loop around again, and then another
> reschedule event happens during signal processing so we go around
> again, etc.  Eventually it settles down.  It's the same with the
> vmstat/lru stuff.

Only kind of.

When we say, effectively, while (need_resched()) schedule();, we're
not waiting for an event or condition per se.  We're runnable (in the
sense that userspace wants to run and we're not blocked on anything)
the entire time -- we're simply yielding to some other thread that is
also runnable.  So if that loop runs forever, it either means that
we're at low priority and we genuinely shouldn't be running or that
there's a scheduler bug.

If, on the other hand, we say while (not quiesced) schedule(); (or
equivalent), we're saying that we're *not* really ready to run and
that we're waiting for some condition to change.  The condition in
question is fairly complicated and won't wake us when we are ready.  I
can also imagine the scheduler getting rather confused, since, as far
as the scheduler knows, we are runnable and we are supposed to be
running.

>
>
>>>> Also, this cond_resched stuff doesn't worry me too much at a
>>>> fundamental level -- if we're really going quiescent, shouldn't we be
>>>> able to arrange that there are no other schedulable tasks on the CPU
>>>> in question?
>>>
>>> We aren't currently planning to enforce things in the scheduler, so if
>>> the application affinitizes another task on top of an existing task
>>> isolation task, by default the task isolation task just dies. (Unless
>>> it's using NOSIG mode, in which case it just ends up stuck in the
>>> kernel trying to wait out the dyntick until you either kill it, or
>>> re-affinitize the offending task.)  But I'm reluctant to guarantee
>>> every possible way that you might (perhaps briefly) have some
>>> schedulable task, and the current approach seems pretty robust if that
>>> sort of thing happens.
>>
>> This kind of waiting out the dyntick scares me.  Why is there ever a
>> dyntick that you're waiting out?  If quiescence is to be a supported
>> mainline feature, shouldn't the scheduler be integrated well enough
>> with it that you don't need to wait like this?
>
>
> Well, this is certainly the funkiest piece of the task isolation
> stuff.  The problem is that the dyntick stuff may, for example, need
> one more tick 4us from now (or whatever) just to close out the current
> RCU period.  We can't return to userspace until that happens.  So what
> else can we do when the task is ready to return to userspace?  We
> could punt into the idle task instead of waiting in this task, which
> was my earlier schedule_time() suggestion.  Do you think that's cleaner?
>

Unless I'm missing something (which is reasonably likely), couldn't
the isolation code just force or require rcu_nocbs on the isolated
CPUs to avoid this problem entirely.

I admit I still don't understand why the RCU context tracking code
can't just run the callback right away instead of waiting however many
microseconds in general.  I feel like paulmck has explained it to me
at least once, but that doesn't mean I remember the answer.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
