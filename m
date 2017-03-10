Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 007FB280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:13:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r141so7742777ita.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 03:13:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z132si2682114iod.184.2017.03.10.03.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 03:13:03 -0800 (PST)
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170309143551.1e59d6f104c7e7abb87c3bce@linux-foundation.org>
In-Reply-To: <20170309143551.1e59d6f104c7e7abb87c3bce@linux-foundation.org>
Message-Id: <201703102012.JDG69214.FVMFHJOOtSLQOF@I-love.SAKURA.ne.jp>
Date: Fri, 10 Mar 2017 20:12:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

Andrew Morton wrote:
> On Tue, 28 Feb 2017 10:21:48 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > This patch adds a watchdog which periodically reports number of memory
> > allocating tasks, dying tasks and OOM victim tasks when some task is
> > spending too long time inside __alloc_pages_slowpath(). This patch also
> > serves as a hook for obtaining additional information using SystemTap
> > (e.g. examine other variables using printk(), capture a crash dump by
> > calling panic()) by triggering a callback only when a stall is detected.
> > Ability to take administrator-controlled actions based on some threshold
> > is a big advantage gained by introducing a state tracking.
> > 
> > Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> > too long") was a great step for reducing possibility of silent hang up
> > problem caused by memory allocation stalls [1]. However, there are
> > reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> > [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> > lockup problem) where this patch is more useful than that commit, for
> > this patch can report possibly related tasks even if allocating tasks
> > are unexpectedly blocked for so long. Regarding premature OOM killer
> > invocation, tracepoints which can accumulate samples in short interval
> > would be useful. But regarding too late to report allocation stalls,
> > this patch which can capture all tasks (for reporting overall situation)
> > in longer interval and act as a trigger (for accumulating short interval
> > samples) would be useful.
> > 
> > ...
> >
> > +Build kernels with CONFIG_DETECT_HUNG_TASK=y and
> > +CONFIG_DETECT_MEMALLOC_STALL_TASK=y.
> > +
> > +Default scan interval is configured by CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT.
> > +Scan interval can be changed at run time by writing timeout in seconds to
> > +/proc/sys/kernel/memalloc_task_warning_secs. Writing 0 disables this scan.
> 
> "seconds" seems needlessly coarse.  Maybe milliseconds?

I can change it to milliseconds although I don't think someone wants to
set e.g. 3500 milliseconds. This timeout is "more than ... seconds" and
actual alert takes longer than this timeout, as with check_hung_task().

> 
> > +Even if you disable this scan, information about last memory allocation
> > +request is kept. That is, you will get some hint for understanding
> > +last-minute behavior of the kernel when you analyze vmcore (or memory
> > +snapshot of a virtualized machine).
> > 
> > ...
> >
> > +struct memalloc_info {
> > +	/*
> > +	 * 0: not doing __GFP_RECLAIM allocation.
> > +	 * 1: doing non-recursive __GFP_RECLAIM allocation.
> > +	 * 2: doing recursive __GFP_RECLAIM allocation.
> > +	 */
> > +	u8 valid;
> > +	/*
> > +	 * bit 0: Will be reported as OOM victim.
> > +	 * bit 1: Will be reported as dying task.
> > +	 * bit 2: Will be reported as stalling task.
> > +	 * bit 3: Will be reported as exiting task.
> > +	 * bit 7: Will be reported unconditionally.
> 
> Create enums for these rather than hard-coding magic numbers?

Sure.

> 
> These values don't seem to be used anyway - as far as I can tell this
> could be a simple boolean.

These values are used in the following switch.

+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			type |= 1;
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			type |= 2;
+			sigkill_pending++;
+		}
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			type |= 8;
+			exiting_tasks++;
+		}
+		if (is_stalling_task(p, expire)) {
+			type |= 4;
+			stalling_tasks++;
+		}
+		if (p->flags & PF_KSWAPD)
+			type |= 128;
+		p->memalloc.type = type;

Since writing logs to consoles stored by printk() is a slow operation,
we will need to add some delays for avoiding logs being dropped. But
we can't sleep while we are traversing the tasklist whereas tasks used
as a cursor can go away while we are sleeping with rcu_lock_break().
Thus, kmallocwd marks whether and how each thread should be reported
in the first round without sleeping, and reports threads which should be
reported in the second round. The second round sleeps and can complete
without duplicates/skips because p->memalloc.type remembers whether p
should be reported.

This approach can be as well used for check_hung_uninterruptible_tasks()
for avoiding RCU stall warnings, avoiding hung tasks being skipped due to
"goto unlock;" and eliminating the need to call touch_nmi_watchdog().
We can mark whether each thread should be reported as hung in the first
round, and report threads which should be reported as hung in the second
round. Such changes are outside of this patch's scope.

> 
> > +	 */
> > +	u8 type;
> > +	/* Index used for memalloc_in_flight[] counter. */
> > +	u8 idx;
> > +	/* For progress monitoring. */
> > +	unsigned int sequence;
> > +	/* Started time in jiffies as of valid == 1. */
> > +	unsigned long start;
> > +	/* Requested order and gfp flags as of valid == 1. */
> > +	unsigned int order;
> > +	gfp_t gfp;
> > +};
> > 
> > ...
> >
> > +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> > +/*
> > + * Zero means infinite timeout - no checking done:
> > + */
> > +unsigned long __read_mostly sysctl_memalloc_task_warning_secs =
> > +	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
> > +static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
> 
> What locking protects `memalloc' from concurrent modifications and
> holds it stable for readers?

No locking is needed because only khungtaskd kernel thread accesses
this variable.

> 
> > 
> > ...
> >
> > +static noinline int check_memalloc_stalling_tasks(unsigned long timeout)
> > +{
> > +	char buf[256];
> > +	struct task_struct *g, *p;
> > +	unsigned long now;
> > +	unsigned long expire;
> > +	unsigned int sigkill_pending = 0;
> > +	unsigned int exiting_tasks = 0;
> > +	unsigned int memdie_pending = 0;
> > +	unsigned int stalling_tasks = 0;
> > +
> > 
> > ...
> >
> > +			goto restart_report;
> > +	}
> > +	rcu_read_unlock();
> > +	preempt_enable_no_resched();
> > +	cond_resched();
> 
> All the cond_resched()s in this function seem a bit random.

This function is trying to be as safe as possible; try to yield CPU time
whenever possible because printing stall warnings is not so urgent enough
to block other high priority threads. Since khungtaskd kernel thread is
not SCHED_IDLE priority, we can expect that stall warnings will be
printed eventually (unless a runaway by realtime threads occurs).

> 
> > +	/* Show memory information. (SysRq-m) */
> > +	show_mem(0, NULL);
> > +	/* Show workqueue state. */
> > +	show_workqueue_state();
> > +	/* Show lock information. (SysRq-d) */
> > +	debug_show_all_locks();
> > +	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
> > +		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
> > +		out_of_memory_count);
> > +	return stalling_tasks;
> > +}
> > +#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
> > +
> >  static void check_hung_task(struct task_struct *t, unsigned long timeout)
> >  {
> >  	unsigned long switch_count = t->nvcsw + t->nivcsw;
> > @@ -228,20 +429,36 @@ void reset_hung_task_detector(void)
> >  static int watchdog(void *dummy)
> >  {
> >  	unsigned long hung_last_checked = jiffies;
> > +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> > +	unsigned long stall_last_checked = hung_last_checked;
> > +#endif
> >  
> >  	set_user_nice(current, 0);
> >  
> >  	for ( ; ; ) {
> >  		unsigned long timeout = sysctl_hung_task_timeout_secs;
> >  		long t = hung_timeout_jiffies(hung_last_checked, timeout);
> > -
> > +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> > +		unsigned long timeout2 = sysctl_memalloc_task_warning_secs;
> > +		long t2 = memalloc_timeout_jiffies(stall_last_checked,
> > +						   timeout2);
> 
> Confused.  Shouldn't timeout2 be converted from seconds to jiffies
> before being passed to memalloc_timeout_jiffies()?

timeout2 is converted from seconds to jiffies by memalloc_timeout_jiffies()
as with timeout is converted from seconds to jiffies by hung_timeout_jiffies().

+static long memalloc_timeout_jiffies(unsigned long last_checked, long timeout)
+{
+	/* timeout of 0 will disable the watchdog */
+	return timeout ? last_checked - jiffies + timeout * HZ :
+		MAX_SCHEDULE_TIMEOUT;
+}

static long hung_timeout_jiffies(unsigned long last_checked,
                                 unsigned long timeout)
{
	/* timeout of 0 will disable the watchdog */
	return timeout ? last_checked - jiffies + timeout * HZ :
		MAX_SCHEDULE_TIMEOUT;
}

We can rename and share hung_timeout_jiffies() for both timeouts
if kmallocwd is acceptable.

> 
> > +		if (t2 <= 0) {
> > +			if (memalloc_maybe_stalling())
> > +				check_memalloc_stalling_tasks(timeout2);
> > +			stall_last_checked = jiffies;
> > +			continue;
> > +		}
> > +#else
> > +		long t2 = t;
> > +#endif
> > 
> > ...
> >
> > +bool memalloc_maybe_stalling(void)
> > +{
> > +	int cpu;
> > +	int sum = 0;
> > +	const u8 idx = memalloc_active_index ^ 1;
> > +
> > +	for_each_possible_cpu(cpu)
> 
> Do we really need to do this for offlined and not-present CPUs?

I just did not want to touch other files within this patch because
I'm not familiar with CPU online/offline handling and want to split
non-essential parts to followup patches.

I assume that a CPU can become offline when someone entered into
__alloc_pages_slowpath() using that CPU. We can update kmallocwd
not to check offlined and not-present CPUs by adding hooks for
resetting memalloc_in_flight counter of a CPU going offline.

> 
> > +		sum += per_cpu(memalloc_in_flight[idx], cpu);
> > +	if (sum)
> > +		return true;
> > +	memalloc_active_index ^= 1;
> > +	return false;
> > +}
> > +
> > 
> > ...
> >
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
