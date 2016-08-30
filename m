Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83D186B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:32:49 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w136so71642239oie.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:32:49 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40064.outbound.protection.outlook.com. [40.107.4.64])
        by mx.google.com with ESMTPS id i40si31474869otb.222.2016.08.30.08.32.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 08:32:38 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160830075854.GZ10153@twins.programming.kicks-ass.net>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
Date: Tue, 30 Aug 2016 11:32:16 -0400
MIME-Version: 1.0
In-Reply-To: <20160830075854.GZ10153@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/30/2016 3:58 AM, Peter Zijlstra wrote:
> On Mon, Aug 29, 2016 at 12:40:32PM -0400, Chris Metcalf wrote:
>> On 8/29/2016 12:33 PM, Peter Zijlstra wrote:
>>> On Tue, Aug 16, 2016 at 05:19:27PM -0400, Chris Metcalf wrote:
>>>> +	/*
>>>> +	 * Request rescheduling unless we are in full dynticks mode.
>>>> +	 * We would eventually get pre-empted without this, and if
>>>> +	 * there's another task waiting, it would run; but by
>>>> +	 * explicitly requesting the reschedule, we may reduce the
>>>> +	 * latency.  We could directly call schedule() here as well,
>>>> +	 * but since our caller is the standard place where schedule()
>>>> +	 * is called, we defer to the caller.
>>>> +	 *
>>>> +	 * A more substantive approach here would be to use a struct
>>>> +	 * completion here explicitly, and complete it when we shut
>>>> +	 * down dynticks, but since we presumably have nothing better
>>>> +	 * to do on this core anyway, just spinning seems plausible.
>>>> +	 */
>>>> +	if (!tick_nohz_tick_stopped())
>>>> +		set_tsk_need_resched(current);
>>> This is broken.. and it would be really good if you don't actually need
>>> to do this.
>> Can you elaborate?  We clearly do want to wait until we are in full
>> dynticks mode before we return to userspace.
>>
>> We could do it just in the prctl() syscall only, but then we lose the
>> ability to implement the NOSIG mode, which can be a convenience.
> So this isn't spelled out anywhere. Why does this need to be in the
> return to user path?

I'm not sure where this should be spelled out, to be honest.  I guess
I can add some commentary to the commit message explaining this part.

The basic idea is just that we don't want to be at risk from the
dyntick getting enabled.  Similarly, we don't want to be at risk of a
later global IPI due to lru_add_drain stuff, for example.  And, we may
want to add additional stuff, like catching kernel TLB flushes and
deferring them when a remote core is in userspace.  To do all of this
kind of stuff, we need to run in the return to user path so we are
late enough to guarantee no further kernel things will happen to
perturb our carefully-arranged isolation state that includes dyntick
off, per-cpu lru cache empty, etc etc.

>> Even without that consideration, we really can't be sure we stay in
>> dynticks mode if we disable the dynamic tick, but then enable interrupts,
>> and end up taking an interrupt on the way back to userspace, and
>> it turns the tick back on.  That's why we do it here, where we know
>> interrupts will stay disabled until we get to userspace.
> But but but.. task_isolation_enter() is explicitly ran with IRQs
> _enabled_!! It even WARNs if they're disabled.

Yes, true!  But if you pop up to the caller, the key thing is the
task_isolation_ready() routine where we are invoked with interrupts
disabled, and we confirm that all our criteria are met (including
tick_nohz_tick_stopped), and then leave interrupts disabled as we
return from there onwards to userspace.

The task_isolation_enter() code just does its best-faith attempt to
make sure all these criteria are met, just like all the other TIF_xxx
flag tests do in exit_to_usermode_loop() on x86, like scheduling,
delivering signals, etc.  As you know, we might run that code, go
around the loop, and discover that the TIF flag has been re-set, and
we have to run the code again before all of that stuff has "quiesced".
The isolation code uses that same model; the only difference is that
we clear the TIF flag manually in the loop by checking
task_isolation_ready().

>> So if we are doing it here, what else can/should we do?  There really
>> shouldn't be any other tasks waiting to run at this point, so there's
>> not a heck of a lot else to do on this core.  We could just spin and
>> check need_resched and signal status manually instead, but that
>> seems kind of duplicative of code already done in our caller here.
> What !? I really don't get this, what are you waiting for? Why is
> rescheduling making things better.

We need to wait for the last dyntick to fire before we can return to
userspace.  There are plenty of options as to what we can do in the
meanwhile.

1. Try to schedule().  Good luck with that in practice, since a
userspace process that has enabled task isolation is going to be alone
on its core unless something pretty broken is happening on the system.
But, at least folks understand the idiom of scheduling out while you wait.

2. Another variant of that: set up a wait completion and have the
dynticks code complete it when the tick turns off.  But this adds
complexity to option 1, and really doesn't buy us much in practice
that I can see.

3. Just admit that we are likely alone on the core, and just burn
cycles in a busy loop waiting for that last tick to fire.  Obviously
if we do this we also need to test for signals and resched so the core
remains responsive.  We can either do this in a loop just by spinning
explicitly, or I could literally just remove the line in the current
patchset that sets TIF_NEED_RESCHED, at which point we busy-wait by
just going around and around in exit_to_usermode_loop().  The only
flaw here is that we don't mark the task explicitly as TASK_INTERRUPTIBLE
while we are doing this - and that's probably worth doing.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
