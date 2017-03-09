Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9823A2808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:35:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so134330201pfx.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:35:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p91si7698509plb.87.2017.03.09.14.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 14:35:52 -0800 (PST)
Date: Thu, 9 Mar 2017 14:35:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Message-Id: <20170309143551.1e59d6f104c7e7abb87c3bce@linux-foundation.org>
In-Reply-To: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>, Alexander Polakov <apolyakov@beget.ru>

On Tue, 28 Feb 2017 10:21:48 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> This patch adds a watchdog which periodically reports number of memory
> allocating tasks, dying tasks and OOM victim tasks when some task is
> spending too long time inside __alloc_pages_slowpath(). This patch also
> serves as a hook for obtaining additional information using SystemTap
> (e.g. examine other variables using printk(), capture a crash dump by
> calling panic()) by triggering a callback only when a stall is detected.
> Ability to take administrator-controlled actions based on some threshold
> is a big advantage gained by introducing a state tracking.
> 
> Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> too long") was a great step for reducing possibility of silent hang up
> problem caused by memory allocation stalls [1]. However, there are
> reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> lockup problem) where this patch is more useful than that commit, for
> this patch can report possibly related tasks even if allocating tasks
> are unexpectedly blocked for so long. Regarding premature OOM killer
> invocation, tracepoints which can accumulate samples in short interval
> would be useful. But regarding too late to report allocation stalls,
> this patch which can capture all tasks (for reporting overall situation)
> in longer interval and act as a trigger (for accumulating short interval
> samples) would be useful.
> 
> ...
>
> +Build kernels with CONFIG_DETECT_HUNG_TASK=y and
> +CONFIG_DETECT_MEMALLOC_STALL_TASK=y.
> +
> +Default scan interval is configured by CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT.
> +Scan interval can be changed at run time by writing timeout in seconds to
> +/proc/sys/kernel/memalloc_task_warning_secs. Writing 0 disables this scan.

"seconds" seems needlessly coarse.  Maybe milliseconds?

> +Even if you disable this scan, information about last memory allocation
> +request is kept. That is, you will get some hint for understanding
> +last-minute behavior of the kernel when you analyze vmcore (or memory
> +snapshot of a virtualized machine).
> 
> ...
>
> +struct memalloc_info {
> +	/*
> +	 * 0: not doing __GFP_RECLAIM allocation.
> +	 * 1: doing non-recursive __GFP_RECLAIM allocation.
> +	 * 2: doing recursive __GFP_RECLAIM allocation.
> +	 */
> +	u8 valid;
> +	/*
> +	 * bit 0: Will be reported as OOM victim.
> +	 * bit 1: Will be reported as dying task.
> +	 * bit 2: Will be reported as stalling task.
> +	 * bit 3: Will be reported as exiting task.
> +	 * bit 7: Will be reported unconditionally.

Create enums for these rather than hard-coding magic numbers?

These values don't seem to be used anyway - as far as I can tell this
could be a simple boolean.

> +	 */
> +	u8 type;
> +	/* Index used for memalloc_in_flight[] counter. */
> +	u8 idx;
> +	/* For progress monitoring. */
> +	unsigned int sequence;
> +	/* Started time in jiffies as of valid == 1. */
> +	unsigned long start;
> +	/* Requested order and gfp flags as of valid == 1. */
> +	unsigned int order;
> +	gfp_t gfp;
> +};
> 
> ...
>
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +/*
> + * Zero means infinite timeout - no checking done:
> + */
> +unsigned long __read_mostly sysctl_memalloc_task_warning_secs =
> +	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
> +static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */

What locking protects `memalloc' from concurrent modifications and
holds it stable for readers?

> 
> ...
>
> +static noinline int check_memalloc_stalling_tasks(unsigned long timeout)
> +{
> +	char buf[256];
> +	struct task_struct *g, *p;
> +	unsigned long now;
> +	unsigned long expire;
> +	unsigned int sigkill_pending = 0;
> +	unsigned int exiting_tasks = 0;
> +	unsigned int memdie_pending = 0;
> +	unsigned int stalling_tasks = 0;
> +
> 
> ...
>
> +			goto restart_report;
> +	}
> +	rcu_read_unlock();
> +	preempt_enable_no_resched();
> +	cond_resched();

All the cond_resched()s in this function seem a bit random.

> +	/* Show memory information. (SysRq-m) */
> +	show_mem(0, NULL);
> +	/* Show workqueue state. */
> +	show_workqueue_state();
> +	/* Show lock information. (SysRq-d) */
> +	debug_show_all_locks();
> +	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
> +		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
> +		out_of_memory_count);
> +	return stalling_tasks;
> +}
> +#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
> +
>  static void check_hung_task(struct task_struct *t, unsigned long timeout)
>  {
>  	unsigned long switch_count = t->nvcsw + t->nivcsw;
> @@ -228,20 +429,36 @@ void reset_hung_task_detector(void)
>  static int watchdog(void *dummy)
>  {
>  	unsigned long hung_last_checked = jiffies;
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +	unsigned long stall_last_checked = hung_last_checked;
> +#endif
>  
>  	set_user_nice(current, 0);
>  
>  	for ( ; ; ) {
>  		unsigned long timeout = sysctl_hung_task_timeout_secs;
>  		long t = hung_timeout_jiffies(hung_last_checked, timeout);
> -
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +		unsigned long timeout2 = sysctl_memalloc_task_warning_secs;
> +		long t2 = memalloc_timeout_jiffies(stall_last_checked,
> +						   timeout2);

Confused.  Shouldn't timeout2 be converted from seconds to jiffies
before being passed to memalloc_timeout_jiffies()?

> +		if (t2 <= 0) {
> +			if (memalloc_maybe_stalling())
> +				check_memalloc_stalling_tasks(timeout2);
> +			stall_last_checked = jiffies;
> +			continue;
> +		}
> +#else
> +		long t2 = t;
> +#endif
> 
> ...
>
> +bool memalloc_maybe_stalling(void)
> +{
> +	int cpu;
> +	int sum = 0;
> +	const u8 idx = memalloc_active_index ^ 1;
> +
> +	for_each_possible_cpu(cpu)

Do we really need to do this for offlined and not-present CPUs?

> +		sum += per_cpu(memalloc_in_flight[idx], cpu);
> +	if (sum)
> +		return true;
> +	memalloc_active_index ^= 1;
> +	return false;
> +}
> +
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
