Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1CE96B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 14:11:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so3756071wml.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:11:39 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id a1si3514784wjm.175.2016.08.11.11.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 11:11:36 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id o80so700079wme.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:11:36 -0700 (PDT)
Date: Thu, 11 Aug 2016 20:11:33 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
Message-ID: <20160811181132.GD4214@lerouge>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 09, 2016 at 04:29:46PM -0400, Chris Metcalf wrote:
> +/*
> + * Each time we try to prepare for return to userspace in a process
> + * with task isolation enabled, we run this code to quiesce whatever
> + * subsystems we can readily quiesce to avoid later interrupts.
> + */
> +void task_isolation_enter(void)
> +{
> +	WARN_ON_ONCE(irqs_disabled());
> +
> +	/* Drain the pagevecs to avoid unnecessary IPI flushes later. */
> +	lru_add_drain();
> +
> +	/* Quieten the vmstat worker so it won't interrupt us. */
> +	quiet_vmstat_sync();

So, this is going to be called everytime we resume to userspace
while in task isolation mode, right?

Do we need to quiesce vmstat everytime before entering userspace?
I thought that vmstat only need to be offlined once and for all?

And how about lru?

> +
> +	/*
> +	 * Request rescheduling unless we are in full dynticks mode.
> +	 * We would eventually get pre-empted without this, and if
> +	 * there's another task waiting, it would run; but by
> +	 * explicitly requesting the reschedule, we may reduce the
> +	 * latency.  We could directly call schedule() here as well,
> +	 * but since our caller is the standard place where schedule()
> +	 * is called, we defer to the caller.
> +	 *
> +	 * A more substantive approach here would be to use a struct
> +	 * completion here explicitly, and complete it when we shut
> +	 * down dynticks, but since we presumably have nothing better
> +	 * to do on this core anyway, just spinning seems plausible.
> +	 */
> +	if (!tick_nohz_tick_stopped())
> +		set_tsk_need_resched(current);

Again, that won't help :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
