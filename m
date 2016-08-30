Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A003B6B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 13:36:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s207so77429910oie.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:36:36 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0067.outbound.protection.outlook.com. [104.47.1.67])
        by mx.google.com with ESMTPS id f2si32058075otc.101.2016.08.30.10.36.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 10:36:22 -0700 (PDT)
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
 <20160811181132.GD4214@lerouge>
 <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
 <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
 <20160830005550.GB32720@lerouge>
 <69cbe2bd-3d39-b3ae-2ebc-6399125fc782@mellanox.com>
 <20160830171003.GA14200@lerouge>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <aea6b90e-4b43-302a-636f-36516f30f5d6@mellanox.com>
Date: Tue, 30 Aug 2016 13:36:00 -0400
MIME-Version: 1.0
In-Reply-To: <20160830171003.GA14200@lerouge>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/30/2016 1:10 PM, Frederic Weisbecker wrote:
> On Tue, Aug 30, 2016 at 11:41:36AM -0400, Chris Metcalf wrote:
>> On 8/29/2016 8:55 PM, Frederic Weisbecker wrote:
>>> On Mon, Aug 15, 2016 at 10:59:55AM -0400, Chris Metcalf wrote:
>>>> On 8/11/2016 2:50 PM, Christoph Lameter wrote:
>>>>> On Thu, 11 Aug 2016, Frederic Weisbecker wrote:
>>>>>
>>>>>> Do we need to quiesce vmstat everytime before entering userspace?
>>>>>> I thought that vmstat only need to be offlined once and for all?
>>>>> Once is sufficient after disabling the tick.
>>>> It's true that task_isolation_enter() is called every time before
>>>> returning to user space while task isolation is enabled.
>>>>
>>>> But once we enter the kernel again after returning from the initial
>>>> prctl() -- assuming we are in NOSIG mode so doing so is legal in the
>>>> first place -- almost anything can happen, certainly including
>>>> restarting the tick.  Thus, we have to make sure that normal quiescing
>>>> happens again before we return to userspace.
>>> Yes but we need to sort out what needs to be called only once on prctl().
>>>
>>> Once vmstat is quiesced, it's not going to need quiescing again even if we
>>> restart the tick.
>> That's true, but I really do like the idea of having a clean structure
>> where we verify all our prerequisites in task_isolation_ready(), and
>> have code to try to get things fixed up in task_isolation_enter().
>> If we start moving some things here and some things there, it gets
>> harder to manage.  I think by testing "!vmstat_idle()" in
>> task_isolation_enter() we are avoiding any substantial overhead.
> I think that making the code clearer on what needs to be done once for
> all on prctl() and what needs to be done on all actual syscall return
> is more important for readability.

We don't need to just do it on prctl(), though.  We also need to do
it whenever we have been in the kernel for another reason, which
can happen with NOSIG.  So we need to do this on the common return
to userspace path no matter what, right?  Or am I missing something?
It seems like if, for example, we do mmaps or page faults, then on return
to userspace, some of those counters will have been incremented and
we'll need to run the quiet_vmstat_sync() code.

>>>>>> +	if (!tick_nohz_tick_stopped())
>>>>>> +		set_tsk_need_resched(current);
>>>>>> Again, that won't help
>>>> It won't be better than spinning in a loop if there aren't any other
>>>> schedulable processes, but it won't be worse either.  If there is
>>>> another schedulable process, we at least will schedule it sooner than
>>>> if we just sat in a busy loop and waited for the scheduler to kick
>>>> us. But there's nothing else we can do anyway if we want to maintain
>>>> the guarantee that the dyn tick is stopped before return to userspace.
>>> I don't think it helps either way. If reschedule is pending, the current
>>> task already has TIF_RESCHED set.
>> See the other thread with Peter Z for the longer discussion of this.
>> At this point I'm leaning towards replacing the set_tsk_need_resched() with
>>
>>      set_current_state(TASK_INTERRUPTIBLE);
>>      schedule();
>>      __set_current_state(TASK_RUNNING);
> I don't see how that helps. What will wake the thread up except a signal?

The answer is that the scheduler will keep bringing us back to this
point (either after running another runnable task if there is one,
or else just returning to this point immediately without doing a
context switch), and we will then go around the "prepare exit to
userspace" loop and perhaps discover that enough time has gone
by that the last dyntick interrupt has triggered and the kernel has
quiesced the dynticks.  At that point we stop calling schedule()
over and over and can return normally to userspace.

It's very counter-intuitive to burn cpu time intentionally in the kernel.
I really don't see another way to resolve this, though.  I don't think
it would be safe, for example, to just promote the next dyntick to
running immediately (rather than waiting a few microseconds until
it is scheduled to go off).

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
