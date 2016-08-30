Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0781A6B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:42:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s207so67902312oie.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:42:14 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0078.outbound.protection.outlook.com. [104.47.1.78])
        by mx.google.com with ESMTPS id s33si11959685ots.51.2016.08.30.08.41.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 08:41:58 -0700 (PDT)
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
 <20160811181132.GD4214@lerouge>
 <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
 <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
 <20160830005550.GB32720@lerouge>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <69cbe2bd-3d39-b3ae-2ebc-6399125fc782@mellanox.com>
Date: Tue, 30 Aug 2016 11:41:36 -0400
MIME-Version: 1.0
In-Reply-To: <20160830005550.GB32720@lerouge>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/29/2016 8:55 PM, Frederic Weisbecker wrote:
> On Mon, Aug 15, 2016 at 10:59:55AM -0400, Chris Metcalf wrote:
>> On 8/11/2016 2:50 PM, Christoph Lameter wrote:
>>> On Thu, 11 Aug 2016, Frederic Weisbecker wrote:
>>>
>>>> Do we need to quiesce vmstat everytime before entering userspace?
>>>> I thought that vmstat only need to be offlined once and for all?
>>> Once is sufficient after disabling the tick.
>> It's true that task_isolation_enter() is called every time before
>> returning to user space while task isolation is enabled.
>>
>> But once we enter the kernel again after returning from the initial
>> prctl() -- assuming we are in NOSIG mode so doing so is legal in the
>> first place -- almost anything can happen, certainly including
>> restarting the tick.  Thus, we have to make sure that normal quiescing
>> happens again before we return to userspace.
> Yes but we need to sort out what needs to be called only once on prctl().
>
> Once vmstat is quiesced, it's not going to need quiescing again even if we
> restart the tick.

That's true, but I really do like the idea of having a clean structure
where we verify all our prerequisites in task_isolation_ready(), and
have code to try to get things fixed up in task_isolation_enter().
If we start moving some things here and some things there, it gets
harder to manage.  I think by testing "!vmstat_idle()" in
task_isolation_enter() we are avoiding any substantial overhead.

I think it would be clearer to rename task_isolation_enter()
to task_isolation_prepare(); it might be less confusing.

Remember too that in general, we really don't need to think about
return-to-userspace as a hot path for task isolation, unlike how we
think about it all the rest of the time.  So it makes sense to
prioritize keeping things clean from a software development
perspective first, and high-performance only secondarily.

>> The thing to remember is that this is only relevant if the user has
>> explicitly requested the NOSIG behavior from task isolation, which we
>> don't really expect to be the default - we are implicitly encouraging
>> use of the default semantics of "you can't enter the kernel again
>> until you turn off isolation".
> That's right. Although NOSIG is the only thing we can afford as long as
> we drag around the 1Hz.

True enough.  Hopefully we'll finish sorting that out soon enough.

>>>> +	if (!tick_nohz_tick_stopped())
>>>> +		set_tsk_need_resched(current);
>>>> Again, that won't help
>> It won't be better than spinning in a loop if there aren't any other
>> schedulable processes, but it won't be worse either.  If there is
>> another schedulable process, we at least will schedule it sooner than
>> if we just sat in a busy loop and waited for the scheduler to kick
>> us. But there's nothing else we can do anyway if we want to maintain
>> the guarantee that the dyn tick is stopped before return to userspace.
> I don't think it helps either way. If reschedule is pending, the current
> task already has TIF_RESCHED set.

See the other thread with Peter Z for the longer discussion of this.
At this point I'm leaning towards replacing the set_tsk_need_resched() with

     set_current_state(TASK_INTERRUPTIBLE);
     schedule();
     __set_current_state(TASK_RUNNING);

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
