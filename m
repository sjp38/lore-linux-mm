Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A80D58308E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 03:59:04 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w136so41266152oie.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:59:04 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id s199si3930708itb.65.2016.08.30.00.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 00:59:03 -0700 (PDT)
Date: Tue, 30 Aug 2016 09:58:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Message-ID: <20160830075854.GZ10153@twins.programming.kicks-ass.net>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 29, 2016 at 12:40:32PM -0400, Chris Metcalf wrote:
> On 8/29/2016 12:33 PM, Peter Zijlstra wrote:
> >On Tue, Aug 16, 2016 at 05:19:27PM -0400, Chris Metcalf wrote:
> >>+	/*
> >>+	 * Request rescheduling unless we are in full dynticks mode.
> >>+	 * We would eventually get pre-empted without this, and if
> >>+	 * there's another task waiting, it would run; but by
> >>+	 * explicitly requesting the reschedule, we may reduce the
> >>+	 * latency.  We could directly call schedule() here as well,
> >>+	 * but since our caller is the standard place where schedule()
> >>+	 * is called, we defer to the caller.
> >>+	 *
> >>+	 * A more substantive approach here would be to use a struct
> >>+	 * completion here explicitly, and complete it when we shut
> >>+	 * down dynticks, but since we presumably have nothing better
> >>+	 * to do on this core anyway, just spinning seems plausible.
> >>+	 */
> >>+	if (!tick_nohz_tick_stopped())
> >>+		set_tsk_need_resched(current);
> >This is broken.. and it would be really good if you don't actually need
> >to do this.
> 
> Can you elaborate?  We clearly do want to wait until we are in full
> dynticks mode before we return to userspace.
> 
> We could do it just in the prctl() syscall only, but then we lose the
> ability to implement the NOSIG mode, which can be a convenience.

So this isn't spelled out anywhere. Why does this need to be in the
return to user path?

> Even without that consideration, we really can't be sure we stay in
> dynticks mode if we disable the dynamic tick, but then enable interrupts,
> and end up taking an interrupt on the way back to userspace, and
> it turns the tick back on.  That's why we do it here, where we know
> interrupts will stay disabled until we get to userspace.

But but but.. task_isolation_enter() is explicitly ran with IRQs
_enabled_!! It even WARNs if they're disabled.

> So if we are doing it here, what else can/should we do?  There really
> shouldn't be any other tasks waiting to run at this point, so there's
> not a heck of a lot else to do on this core.  We could just spin and
> check need_resched and signal status manually instead, but that
> seems kind of duplicative of code already done in our caller here.

What !? I really don't get this, what are you waiting for? Why is
rescheduling making things better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
