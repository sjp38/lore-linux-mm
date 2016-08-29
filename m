Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E61146B0264
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:54:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w136so730142oie.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:54:01 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50089.outbound.protection.outlook.com. [40.107.5.89])
        by mx.google.com with ESMTPS id v11si24894023oia.85.2016.08.29.09.53.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 09:53:47 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160829164809.GW10153@twins.programming.kicks-ass.net>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <ccd4a21a-8de5-38f0-5e78-1ad999755b7a@mellanox.com>
Date: Mon, 29 Aug 2016 12:53:30 -0400
MIME-Version: 1.0
In-Reply-To: <20160829164809.GW10153@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/29/2016 12:48 PM, Peter Zijlstra wrote:
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
>> Can you elaborate?
> Naked use of TIF_NEED_RESCHED like this is busted. There is more state
> that needs to be poked to keep things consistent / working.

Would it be cleaner to just replace the set_tsk_need_resched() call
with something like:

     set_current_state(TASK_INTERRUPTIBLE);
     schedule();
     __set_current_state(TASK_RUNNING);

or what would you recommend?

Or, as I said, just doing a busy loop here while testing to see
if need_resched or signal had been set?

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
