Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 20D136B0257
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 10:31:56 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fl4so134643289pad.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:31:56 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id i76si41783729pfj.182.2016.03.02.07.31.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 07:31:54 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id w128so91268515pfb.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:31:54 -0800 (PST)
Date: Thu, 3 Mar 2016 00:29:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160302152951.GA544@swordfish>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302140419.GA614@swordfish>
 <201603030002.JID60482.MOFFFOQVtJSLHO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603030002.JID60482.MOFFFOQVtJSLHO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, pmladek@suse.com, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org

On (03/03/16 00:02), Tetsuo Handa wrote:
> > On (03/02/16 21:01), Tetsuo Handa wrote:
> > > I'm trying to dump information of all threads which might be relevant
> > > to stalling inside memory allocator. But it seems to me that since this
> > > patch changed to allow calling cond_resched() from printk() if it is
> > > safe to do so, it is now possible that the thread which invoked the OOM
> > > killer can sleep for minutes with the oom_lock mutex held when my dump is
> > > in progress. I want to release oom_lock mutex as soon as possible so
> > > that other threads can call out_of_memory() to get TIF_MEMDIE and exit
> > > their allocations.
> > 
> > correct, otherwise chances are that you will softlockup or RCU stall
> > the system -- console_unlock() does not stop until the printk logbuf
> > has data in it (which can be appended concurrently from other CPUs).
> 
> Did you mean:
> 
>   console_unlock() does not stop until the printk logbuf has no more data
>   in it (but data can be appended to the logbuf concurrently from other CPUs).
> 

yes, I did. sorry for the misleading/wrong wording.

schematically:

CPU0                                    CPU1 - CPUX
printk
 preempt_disable
  console_lock                          printk only add data to logbuf
                                        printk
  console_unlock()                      printk
   while (logbuf not empty)              ...
    call_console_drivers()              printk
  up console_sem
preempt_enable                          printk
                                         preempt_disable
                                          console_lock     #on CPU1
                                          console_unlock
                                           while (logbuf not empty)
                                            ...

and so on.

so that's why in some cases (when there is a concurrent task (or tasks)
doing printk() more of less frequently) doing something like:

= printk in softirg/IRQ
= or spin_lock; printk; spin_unlock
= or preempt_disable; printk; preempt_enable
= or rcu_read_lock; printk; rcu_read_unlock
= or local irq save; printk; local irq restore
= etc.

can lead to negative consequences -- console_unlock() only cares about
the data it can print. cond_resched() cannot fix all of the cases above,
Jan Kara's patch set can.

if you say that you can guarantee that printk will not loop for too long
(sorry, I haven't looked yet at the code you have attached) then yes,
preempt_disable or rcu read lock should do the trick for you.

	-ss

[..]
> > several questions,
> > do you use some sort of oom-kill reproducer? ... the problem with printk
> > is that you never know which once of the CPUs will do the printing job at
> > the end; any guess there is highly unreliable. but, assuming that you have
> > executed that oom-kill reproducer many times before the patch in question
> > do you have any rough numbers to compare how many seconds it used to take
> > to dump_stack all of the tasks?
> 
> Yes, I'm using a stress tester which creates thousands of threads
> (shown below). My dump (shown bottom) is intended for finding bugs
> in corner cases and is written to wait for a bit for each thread
> so that my dump shall not hold RCU lock for too long even if there
> are thousands of threads to dump.
> 
> (This is just an example. There are many different versions.)
> ----------------------------------------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <signal.h>
> #include <sched.h>
> #include <sys/prctl.h>
> 
> static char stop = 0;
> static int fd = EOF;
> 
> static void sigcld_handler(int unused)
> {
> 	stop = 1;
> }
> 
> static int memory_eater(void *unused)
> {
> 	char *buf = NULL;
> 	unsigned long size = 0;
> 	char c;
> 	read(fd, &c, 1);
> 	while (1) {
> 		char *tmp = realloc(buf, size + 4096);
> 		if (!tmp)
> 			break;
> 		buf = tmp;
> 		buf[size] = 0;
> 		size += 4096;
> 	}
> 	pause();
> 	return 0;
> }
> 
> int main(int argc, char *argv[])
> {
> 	int pipe_fd[2] = { EOF, EOF };
> 	char *buf = NULL;
> 	unsigned long size;
> 	int i;
> 	if (chdir("/tmp"))
> 		return 1;
> 	if (pipe(pipe_fd))
> 		return 1;
> 	fd = pipe_fd[0];
> 	signal(SIGCLD, sigcld_handler);
> 	for (i = 0; i < 1024; i++) {
> 		if (fork() == 0) {
> 			char *stack = malloc(4096);
> 			char from[128] = { };
> 			char to[128] = { };
> 			const pid_t pid = getpid();
> 			unsigned char prev = 0;
> 			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
> 			write(fd, "1000", 4);
> 			close(fd);
> 			close(pipe_fd[1]);
> 			snprintf(from, sizeof(from), "tgid=%u", pid);
> 			prctl(PR_SET_NAME, (unsigned long) from, 0, 0, 0);
> 			srand(pid);
> 			sleep(2);
> 			snprintf(from, sizeof(from), "file.%u-0", pid);
> 			fd = open(from, O_WRONLY | O_CREAT, 0600);
> 			if (fd == EOF)
> 				_exit(1);
> 			if (clone(memory_eater, stack + 4096, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
> 				_exit(1);
> 			while (1) {
> 				const unsigned char next = rand();
> 				snprintf(from, sizeof(from), "file.%u-%u", pid, prev);
> 				snprintf(to, sizeof(to), "file.%u-%u", pid, next);
> 				prev = next;
> 				rename(from, to);
> 				write(fd, "", 1);
> 			}
> 			_exit(0);
> 		}
> 	}
> 	close(pipe_fd[0]);
> 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> 		char *cp = realloc(buf, size);
> 		if (!cp) {
> 			size >>= 1;
> 			break;
> 		}
> 		buf = cp;
> 	}
> 	sleep(4);
> 	close(pipe_fd[1]);
> 	/* Will cause OOM due to overcommit */
> 	for (i = 0; i < size; i += 4096) {
> 		buf[i] = 0;
> 		if (stop)
> 			break;
> 	}
> 	pause();
> 	return 0;
> }
> ----------------------------------------
> 
> (This is today's version. I'm trying to somehow avoid
> "** XXX printk messages dropped **" messages.)
> ----------------------------------------
> diff --git a/include/linux/console.h b/include/linux/console.h
> index ea731af..11e936c 100644
> --- a/include/linux/console.h
> +++ b/include/linux/console.h
> @@ -147,6 +147,7 @@ extern int unregister_console(struct console *);
>  extern struct console *console_drivers;
>  extern void console_lock(void);
>  extern int console_trylock(void);
> +extern void wait_console_flushed(unsigned long timeout);
>  extern void console_unlock(void);
>  extern void console_conditional_schedule(void);
>  extern void console_unblank(void);
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 45993b8..5647c5a 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -113,6 +113,16 @@ static inline bool task_will_free_mem(struct task_struct *task)
>  		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
>  }
>  
> +extern unsigned int out_of_memory_count;
> +extern unsigned int no_out_of_memory_count;
> +
> +static inline void set_memalloc_location(const u8 location)
> +{
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +	current->memalloc.known_locations = location;
> +#endif
> +}
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 0b44fbc..ae21ab2 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1393,6 +1393,31 @@ struct tlbflush_unmap_batch {
>  	bool writable;
>  };
>  
> +struct memalloc_info {
> +	/* For locking and progress monitoring. */
> +	unsigned int sequence;
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
> +	 */
> +	u8 type;
> +	u8 known_locations; /* to reduce amount of traces */
> +	/* Started time in jiffies as of valid == 1. */
> +	unsigned long start;
> +	/* Requested order and gfp flags as of valid == 1. */
> +	unsigned int order;
> +	gfp_t gfp;
> +};
> +
>  struct task_struct {
>  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
>  	void *stack;
> @@ -1855,6 +1880,9 @@ struct task_struct {
>  #ifdef CONFIG_MMU
>  	struct list_head oom_reaper_list;
>  #endif
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +	struct memalloc_info memalloc;
> +#endif
>  /* CPU-specific state of this task */
>  	struct thread_struct thread;
>  /*
> diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
> index 22db1e6..7f2c230 100644
> --- a/include/linux/sched/sysctl.h
> +++ b/include/linux/sched/sysctl.h
> @@ -9,6 +9,9 @@ extern int sysctl_hung_task_warnings;
>  extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
>  					 void __user *buffer,
>  					 size_t *lenp, loff_t *ppos);
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +extern unsigned long sysctl_memalloc_task_timeout_secs;
> +#endif
>  #else
>  /* Avoid need for ifdefs elsewhere in the code */
>  enum { sysctl_hung_task_timeout_secs = 0 };
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d277e83..e7789ef 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1425,6 +1425,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	p->sequential_io_avg	= 0;
>  #endif
>  
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +	p->memalloc.sequence = 0;
> +#endif
> +
>  	/* Perform scheduler related setup. Assign this task to a CPU. */
>  	retval = sched_fork(clone_flags, p);
>  	if (retval)
> diff --git a/kernel/hung_task.c b/kernel/hung_task.c
> index d234022..13ad212 100644
> --- a/kernel/hung_task.c
> +++ b/kernel/hung_task.c
> @@ -16,6 +16,8 @@
>  #include <linux/export.h>
>  #include <linux/sysctl.h>
>  #include <linux/utsname.h>
> +#include <linux/oom.h> /* out_of_memory_count */
> +#include <linux/console.h> /* wait_console_flushed() */
>  #include <trace/events/sched.h>
>  
>  /*
> @@ -72,6 +74,248 @@ static struct notifier_block panic_block = {
>  	.notifier_call = hung_task_panic,
>  };
>  
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +/*
> + * Zero means infinite timeout - no checking done:
> + */
> +unsigned long __read_mostly sysctl_memalloc_task_timeout_secs =
> +	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
> +static struct memalloc_info memalloc; /* Filled by is_stalling_task(). */
> +
> +static long memalloc_timeout_jiffies(unsigned long last_checked, long timeout)
> +{
> +	struct task_struct *g, *p;
> +	long t;
> +	unsigned long delta;
> +
> +	/* timeout of 0 will disable the watchdog */
> +	if (!timeout)
> +		return MAX_SCHEDULE_TIMEOUT;
> +	/* At least wait for timeout duration. */
> +	t = last_checked - jiffies + timeout * HZ;
> +	if (t > 0)
> +		return t;
> +	/* Calculate how long to wait more. */
> +	t = timeout * HZ;
> +	delta = t - jiffies;
> +
> +	/*
> +	 * We might see outdated values in "struct memalloc_info" here.
> +	 * We will recheck later using is_stalling_task().
> +	 */
> +	preempt_disable();
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		if (likely(!p->memalloc.valid))
> +			continue;
> +		t = min_t(long, t, p->memalloc.start + delta);
> +		if (unlikely(t <= 0))
> +			goto stalling;
> +	}
> + stalling:
> +	rcu_read_unlock();
> +	preempt_enable();
> +	return t;
> +}
> +
> +/**
> + * is_stalling_task - Check and copy a task's memalloc variable.
> + *
> + * @task:   A task to check.
> + * @expire: Timeout in jiffies.
> + *
> + * Returns true if a task is stalling, false otherwise.
> + */
> +static bool is_stalling_task(const struct task_struct *task,
> +			     const unsigned long expire)
> +{
> +	const struct memalloc_info *m = &task->memalloc;
> +
> +	/*
> +	 * If start_memalloc_timer() is updating "struct memalloc_info" now,
> +	 * we can ignore it because timeout jiffies cannot be expired as soon
> +	 * as updating it completes.
> +	 */
> +	if (!m->valid || (m->sequence & 1))
> +		return false;
> +	smp_rmb(); /* Block start_memalloc_timer(). */
> +	memalloc.start = m->start;
> +	memalloc.order = m->order;
> +	memalloc.gfp = m->gfp;
> +	smp_rmb(); /* Unblock start_memalloc_timer(). */
> +	memalloc.sequence = m->sequence;
> +	/*
> +	 * If start_memalloc_timer() started updating it while we read it,
> +	 * we can ignore it for the same reason.
> +	 */
> +	if (!m->valid || (memalloc.sequence & 1))
> +		return false;
> +	/* This is a valid "struct memalloc_info". Check for timeout. */
> +	return time_after_eq(expire, memalloc.start);
> +}
> +
> +/* Check for memory allocation stalls. */
> +static void check_memalloc_stalling_tasks(unsigned long timeout)
> +{
> +	char buf[256];
> +	struct task_struct *g, *p;
> +	unsigned long now;
> +	unsigned long expire;
> +	unsigned int sigkill_pending;
> +	unsigned int exiting_tasks;
> +	unsigned int memdie_pending;
> +	unsigned int stalling_tasks;
> +
> +	cond_resched();
> +	now = jiffies;
> +	/*
> +	 * Report tasks that stalled for more than half of timeout duration
> +	 * because such tasks might be correlated with tasks that already
> +	 * stalled for full timeout duration.
> +	 */
> +	expire = now - timeout * (HZ / 2);
> +	/* Count stalling tasks, dying and victim tasks. */
> +	sigkill_pending = 0;
> +	exiting_tasks = 0;
> +	memdie_pending = 0;
> +	stalling_tasks = 0;
> +	preempt_disable();
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		u8 type = 0;
> +
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			type |= 1;
> +			memdie_pending++;
> +		}
> +		if (fatal_signal_pending(p)) {
> +			type |= 2;
> +			sigkill_pending++;
> +		}
> +		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
> +			type |= 8;
> +			exiting_tasks++;
> +		}
> +		if (is_stalling_task(p, expire)) {
> +			type |= 4;
> +			stalling_tasks++;
> +		}
> +		if (p->flags & PF_KSWAPD)
> +			type |= 128;
> +		p->memalloc.type = type;
> +	}
> +	rcu_read_unlock();
> +	preempt_enable_no_resched();
> +	if (!stalling_tasks)
> +		return;
> +	wait_console_flushed(HZ);
> +	cond_resched();
> +	/* Report stalling tasks, dying and victim tasks. */
> +	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u/%u\n",
> +		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending, out_of_memory_count,
> +		no_out_of_memory_count);
> +	cond_resched();
> +	sigkill_pending = 0;
> +	exiting_tasks = 0;
> +	memdie_pending = 0;
> +	stalling_tasks = 0;
> +	preempt_disable();
> +	rcu_read_lock();
> + restart_report:
> +	for_each_process_thread(g, p) {
> +		bool can_cont;
> +		u8 type;
> +
> +		if (likely(!p->memalloc.type))
> +			continue;
> +		p->memalloc.type = 0;
> +		/* Recheck in case state changed meanwhile. */
> +		type = 0;
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			type |= 1;
> +			memdie_pending++;
> +		}
> +		if (fatal_signal_pending(p)) {
> +			type |= 2;
> +			sigkill_pending++;
> +		}
> +		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
> +			type |= 8;
> +			exiting_tasks++;
> +		}
> +		if (is_stalling_task(p, expire)) {
> +			type |= 4;
> +			stalling_tasks++;
> +			snprintf(buf, sizeof(buf),
> +				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
> +				 memalloc.sequence >> 1, memalloc.gfp, &memalloc.gfp,
> +				 memalloc.order, now - memalloc.start);
> +		} else {
> +			buf[0] = '\0';
> +		}
> +		if (p->flags & PF_KSWAPD)
> +			type |= 128;
> +		if (unlikely(!type))
> +			continue;
> +		/*
> +		 * Victim tasks get pending SIGKILL removed before arriving at
> +		 * do_exit(). Therefore, print " exiting" instead for " dying".
> +		 */
> +		pr_warn("MemAlloc: %s(%u) flags=0x%x switches=%lu%s%s%s%s%s\n", p->comm,
> +			p->pid, p->flags, p->nvcsw + p->nivcsw, buf,
> +			(p->state & TASK_UNINTERRUPTIBLE) ?
> +			" uninterruptible" : "",
> +			(type & 8) ? " exiting" : "",
> +			(type & 2) ? " dying" : "",
> +			(type & 1) ? " victim" : "");
> +		switch (p->memalloc.known_locations) {
> +		case 1:
> +			pr_warn("Call Trace: looping inside shrink_inactive_list()\n");
> +			break;
> +		case 2:
> +			pr_warn("Call Trace: waiting for oom_lock\n");
> +			break;
> +		default:
> +			sched_show_task(p);
> +		}
> +		/*
> +		 * Since there could be thousands of tasks to report, we always
> +		 * call cond_resched() after each report, in order to avoid RCU
> +		 * stalls.
> +		 *
> +		 * Since not yet reported tasks have p->memalloc.type > 0, we
> +		 * can simply restart this loop in case "g" or "p" went away.
> +		 */
> +		get_task_struct(g);
> +		get_task_struct(p);
> +		rcu_read_unlock();
> +		preempt_enable_no_resched();
> +		wait_console_flushed(HZ / 10);
> +		cond_resched();
> +		preempt_disable();
> +		rcu_read_lock();
> +		can_cont = pid_alive(g) && pid_alive(p);
> +		put_task_struct(p);
> +		put_task_struct(g);
> +		if (!can_cont)
> +			goto restart_report;
> +	}
> +	rcu_read_unlock();
> +	preempt_enable_no_resched();
> +	cond_resched();
> +	/* Show memory information. (SysRq-m) */
> +	show_mem(0);
> +	/* Show workqueue state. */
> +	show_workqueue_state();
> +	/* Show lock information. (SysRq-d) */
> +	debug_show_all_locks();
> +	wait_console_flushed(HZ / 10);
> +	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u/%u\n",
> +		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending, out_of_memory_count,
> +		no_out_of_memory_count);
> +}
> +#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
> +
>  static void check_hung_task(struct task_struct *t, unsigned long timeout)
>  {
>  	unsigned long switch_count = t->nvcsw + t->nivcsw;
> @@ -227,20 +471,35 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detector);
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
> +		unsigned long timeout2 = sysctl_memalloc_task_timeout_secs;
> +		long t2 = memalloc_timeout_jiffies(stall_last_checked,
> +						   timeout2);
> +
> +		if (t2 <= 0) {
> +			check_memalloc_stalling_tasks(timeout2);
> +			stall_last_checked = jiffies;
> +			continue;
> +		}
> +#else
> +		long t2 = t;
> +#endif
>  		if (t <= 0) {
>  			if (!atomic_xchg(&reset_hung_task, 0))
>  				check_hung_uninterruptible_tasks(timeout);
>  			hung_last_checked = jiffies;
>  			continue;
>  		}
> -		schedule_timeout_interruptible(t);
> +		schedule_timeout_interruptible(min(t, t2));
>  	}
>  
>  	return 0;
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 9917f69..2eb60df 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -121,6 +121,15 @@ static int __down_trylock_console_sem(unsigned long ip)
>  	up(&console_sem);\
>  } while (0)
>  
> +static int __down_timeout_console_sem(unsigned long timeout, unsigned long ip)
> +{
> +	if (down_timeout(&console_sem, timeout))
> +		return 1;
> +	mutex_acquire(&console_lock_dep_map, 0, 1, ip);
> +	return 0;
> +}
> +#define down_timeout_console_sem(timeout) __down_timeout_console_sem((timeout), _RET_IP_)
> +
>  /*
>   * This is used for debugging the mess that is the VT code by
>   * keeping track if we have the console semaphore held. It's
> @@ -2125,6 +2134,21 @@ int console_trylock(void)
>  }
>  EXPORT_SYMBOL(console_trylock);
>  
> +void wait_console_flushed(unsigned long timeout)
> +{
> +	might_sleep();
> +
> +	if (down_timeout_console_sem(timeout))
> +		return;
> +	if (console_suspended) {
> +		up_console_sem();
> +		return;
> +	}
> +	console_locked = 1;
> +	console_may_schedule = 1;
> +	console_unlock();
> +}
> +
>  int is_console_locked(void)
>  {
>  	return console_locked;
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 96ec234..8bc1c5b 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1073,6 +1073,16 @@ static struct ctl_table kern_table[] = {
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &neg_one,
>  	},
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +	{
> +		.procname	= "memalloc_task_timeout_secs",
> +		.data		= &sysctl_memalloc_task_timeout_secs,
> +		.maxlen		= sizeof(unsigned long),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dohung_task_timeout_secs,
> +		.extra2		= &hung_task_timeout_max,
> +	},
> +#endif
>  #endif
>  #ifdef CONFIG_COMPAT
>  	{
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 4a8bfe2..8bbc655 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -864,6 +864,30 @@ config WQ_WATCHDOG
>  	  state.  This can be configured through kernel parameter
>  	  "workqueue.watchdog_thresh" and its sysfs counterpart.
>  
> +config DETECT_MEMALLOC_STALL_TASK
> +	bool "Detect tasks stalling inside memory allocator"
> +	default n
> +	depends on DETECT_HUNG_TASK
> +	help
> +	  This option emits warning messages and traces when memory
> +	  allocation requests are stalling, in order to catch unexplained
> +	  hangups/reboots caused by memory allocation stalls.
> +
> +config DEFAULT_MEMALLOC_TASK_TIMEOUT
> +	int "Default timeout for stalling task detection (in seconds)"
> +	depends on DETECT_MEMALLOC_STALL_TASK
> +	default 10
> +	help
> +	  This option controls the default timeout (in seconds) used
> +	  to determine when a task has become non-responsive and should
> +	  be considered stalling inside memory allocator.
> +
> +	  It can be adjusted at runtime via the kernel.memalloc_task_timeout_secs
> +	  sysctl or by writing a value to
> +	  /proc/sys/kernel/memalloc_task_timeout_secs.
> +
> +	  A timeout of 0 disables the check. The default is 10 seconds.
> +
>  endmenu # "Debug lockups and hangs"
>  
>  config PANIC_ON_OOPS
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5d5eca9..bb5ea86 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -44,6 +44,8 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/oom.h>
>  
> +unsigned int out_of_memory_count;
> +
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks = 1;
> @@ -855,6 +857,7 @@ bool out_of_memory(struct oom_control *oc)
>  	unsigned int uninitialized_var(points);
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
> +	out_of_memory_count++;
>  	if (oom_killer_disabled)
>  		return false;
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1993894..1529ccf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2806,6 +2806,8 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
>  		show_mem(filter);
>  }
>  
> +unsigned int no_out_of_memory_count;
> +
>  static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	const struct alloc_context *ac, unsigned long *did_some_progress)
> @@ -2826,7 +2828,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	if (!mutex_trylock(&oom_lock)) {
>  		*did_some_progress = 1;
> +		set_memalloc_location(2);
>  		schedule_timeout_uninterruptible(1);
> +		set_memalloc_location(0);
>  		return NULL;
>  	}
>  
> @@ -2862,6 +2866,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			 * enter a quiescent state during suspend.
>  			 */
>  			*did_some_progress = !oom_killer_disabled;
> +			no_out_of_memory_count++;
>  			goto out;
>  		}
>  		if (pm_suspended_storage())
> @@ -3399,6 +3404,37 @@ got_pg:
>  	return page;
>  }
>  
> +#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
> +static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
> +{
> +	struct memalloc_info *m = &current->memalloc;
> +
> +	/* We don't check for stalls for !__GFP_RECLAIM allocations. */
> +	if (!(gfp_mask & __GFP_RECLAIM))
> +		return;
> +	/* We don't check for stalls for nested __GFP_RECLAIM allocations */
> +	if (!m->valid) {
> +		m->sequence++;
> +		smp_wmb(); /* Block is_stalling_task(). */
> +		m->start = jiffies;
> +		m->order = order;
> +		m->gfp = gfp_mask;
> +		smp_wmb(); /* Unblock is_stalling_task(). */
> +		m->sequence++;
> +	}
> +	m->valid++;
> +}
> +
> +static void stop_memalloc_timer(const gfp_t gfp_mask)
> +{
> +	if (gfp_mask & __GFP_RECLAIM)
> +		current->memalloc.valid--;
> +}
> +#else
> +#define start_memalloc_timer(gfp_mask, order) do { } while (0)
> +#define stop_memalloc_timer(gfp_mask) do { } while (0)
> +#endif
> +
>  /*
>   * This is the 'heart' of the zoned buddy allocator.
>   */
> @@ -3466,7 +3502,9 @@ retry_cpuset:
>  		alloc_mask = memalloc_noio_flags(gfp_mask);
>  		ac.spread_dirty_pages = false;
>  
> +		start_memalloc_timer(alloc_mask, order);
>  		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
> +		stop_memalloc_timer(alloc_mask);
>  	}
>  
>  	if (kmemcheck_enabled && page)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 39e90e2..1231dcf 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1581,14 +1581,31 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	unsigned char counter = 0;
>  
> +	set_memalloc_location(1);
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
> -		if (fatal_signal_pending(current))
> +		if (fatal_signal_pending(current)) {
> +			set_memalloc_location(0);
>  			return SWAP_CLUSTER_MAX;
> +		}
> +		if (!++counter) {
> +			if (file)
> +				printk(KERN_WARNING "zone=%s NR_INACTIVE_FILE=%lu NR_ISOLATED_FILE=%lu\n",
> +				       zone->name,
> +				       zone_page_state(zone, NR_INACTIVE_FILE),
> +				       zone_page_state(zone, NR_ISOLATED_FILE));
> +			else
> +				printk(KERN_WARNING "zone=%s NR_INACTIVE_ANON=%lu NR_ISOLATED_ANON=%lu\n",
> +				       zone->name,
> +				       zone_page_state(zone, NR_INACTIVE_ANON),
> +				       zone_page_state(zone, NR_ISOLATED_ANON));
> +		}
>  	}
> +	set_memalloc_location(0);
>  
>  	lru_add_drain();
>  
> ----------------------------------------
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
