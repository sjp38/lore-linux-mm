Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E346F83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:41:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t127so241018989oie.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:41:18 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0064.outbound.protection.outlook.com. [104.47.0.64])
        by mx.google.com with ESMTPS id y46si4514020oty.67.2016.08.29.09.40.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 09:40:59 -0700 (PDT)
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
Date: Mon, 29 Aug 2016 12:40:32 -0400
MIME-Version: 1.0
In-Reply-To: <20160829163352.GV10153@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/29/2016 12:33 PM, Peter Zijlstra wrote:
> On Tue, Aug 16, 2016 at 05:19:27PM -0400, Chris Metcalf wrote:
>> +	/*
>> +	 * Request rescheduling unless we are in full dynticks mode.
>> +	 * We would eventually get pre-empted without this, and if
>> +	 * there's another task waiting, it would run; but by
>> +	 * explicitly requesting the reschedule, we may reduce the
>> +	 * latency.  We could directly call schedule() here as well,
>> +	 * but since our caller is the standard place where schedule()
>> +	 * is called, we defer to the caller.
>> +	 *
>> +	 * A more substantive approach here would be to use a struct
>> +	 * completion here explicitly, and complete it when we shut
>> +	 * down dynticks, but since we presumably have nothing better
>> +	 * to do on this core anyway, just spinning seems plausible.
>> +	 */
>> +	if (!tick_nohz_tick_stopped())
>> +		set_tsk_need_resched(current);
> This is broken.. and it would be really good if you don't actually need
> to do this.

Can you elaborate?  We clearly do want to wait until we are in full
dynticks mode before we return to userspace.

We could do it just in the prctl() syscall only, but then we lose the
ability to implement the NOSIG mode, which can be a convenience.

Even without that consideration, we really can't be sure we stay in
dynticks mode if we disable the dynamic tick, but then enable interrupts,
and end up taking an interrupt on the way back to userspace, and
it turns the tick back on.  That's why we do it here, where we know
interrupts will stay disabled until we get to userspace.

So if we are doing it here, what else can/should we do?  There really
shouldn't be any other tasks waiting to run at this point, so there's
not a heck of a lot else to do on this core.  We could just spin and
check need_resched and signal status manually instead, but that
seems kind of duplicative of code already done in our caller here.

So... thoughts?

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
