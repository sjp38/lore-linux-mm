Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E16E6B0069
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 13:00:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so222620201pfb.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 10:00:02 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00083.outbound.protection.outlook.com. [40.107.0.83])
        by mx.google.com with ESMTPS id hp2si20826143pad.61.2016.09.30.10.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 10:00:01 -0700 (PDT)
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
Message-ID: <aa0cf4eb-7da5-dfe1-45b2-f2a80969b706@mellanox.com>
Date: Fri, 30 Sep 2016 12:59:33 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Ingo
 Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Zijlstra <peterz@infradead.org>

On 8/30/2016 2:43 PM, Andy Lutomirski wrote:
> On Aug 30, 2016 10:02 AM, "Chris Metcalf" <cmetcalf@mellanox.com> wrote:
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
> What if we did it the other way around: set a percpu flag saying
> "going quiescent; disallow new deferred work", then finish all
> existing work and return to userspace.  Then, on the next entry, clear
> that flag.  With the flag set, vmstat would just flush anything that
> it accumulates immediately, nothing would be added to the LRU list,
> etc.

Thinking about this some more, I was struck by an even simpler way
to approach this.  What if we just said that on task isolation cores, no
kernel subsystem should do something that would require a future
interruption?  So vmstat would just always sync immediately on task
isolation cores, the mm subsystem wouldn't use per-cpu LRU stuff on
task isolation cores, etc.  That way we don't have to worry about the
status of those things as we are returning to userspace for a task
isolation process, since it's just always kept "pristine".

The task-isolation setting per-core is not user-customizable, and the
task-stealing scheduler doesn't even run there, so it's not like any
processes will land there and be in a position to complain about the
performance overhead of having no deferred work being created...

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
