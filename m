Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D842C6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:28:14 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7C7BC3EE0BB
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:28:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6243645DEAD
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A7E045DE9E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AE251DB8038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:28:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0CA1DB803E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:28:12 +0900 (JST)
Date: Wed, 7 Dec 2011 10:27:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom: add tracepoints for oom_score_adj
Message-Id: <20111207102707.4084120c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, dchinner@redhat.com

Sorry, I found a mistake...
I'll post updated one, again.

Thanks,
-Kame


On Wed, 7 Dec 2011 09:54:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From 28189e4622fd97324893a0b234183f64472a54d6 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 7 Dec 2011 09:58:16 +0900
> Subject: [PATCH] oom: trace point for oom_score_adj
> 
> oom_score_adj is set to prevent a task from being killed by OOM-Killer.
> Some daemons sets this value and their children inerit it sometimes.
> Because inheritance of oom_score_adj is done automatically, users
> can be confused at seeing the value and finds it's hard to debug.
> 
> This patch adds trace point for oom_score_adj. This adds 3 trace
> points. at
> 	- update oom_score_adj
> 	- fork()
> 	- rename task->comm(typically, exec())
> 
> Outputs will be following.
>    bash-2404  [006]   199.620841: oom_score_adj_update: task 2404[bash] updates oom_score_ad  j=-1000
>    bash-2404  [006]   205.861287: oom_score_adj_inherited: new_task=2442 oom_score_adj=-1000
>    su-2442  [003]   205.861761: oom_score_task_rename: rename task 2442[bash] to [su] oom_  score_adj=-1000
>    su-2442  [003]   205.866737: oom_score_adj_inherited: new_task=2444 oom_score_adj=-1000
>    bash-2444  [007]   205.868136: oom_score_task_rename: rename task 2444[su] to [bash] oom_  score_adj=-1000
>    bash-2444  [007]   205.870407: oom_score_adj_inherited: new_task=2445 oom_score_adj=-1000
>    bash-2445  [001]   205.870975: oom_score_adj_inherited: new_task=2446 oom_score_adj=-1000
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  fs/exec.c                  |    5 +++
>  fs/proc/base.c             |    3 ++
>  include/trace/events/oom.h |   80 ++++++++++++++++++++++++++++++++++++++++++++
>  kernel/fork.c              |    5 +++
>  mm/oom_kill.c              |    6 +++
>  5 files changed, 99 insertions(+), 0 deletions(-)
>  create mode 100644 include/trace/events/oom.h
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index ca141db..562a106 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -59,6 +59,8 @@
>  #include <asm/uaccess.h>
>  #include <asm/mmu_context.h>
>  #include <asm/tlb.h>
> +
> +#include <trace/events/oom.h>
>  #include "internal.h"
>  
>  int core_uses_pid;
> @@ -1054,6 +1056,9 @@ void set_task_comm(struct task_struct *tsk, char *buf)
>  {
>  	task_lock(tsk);
>  
> +	if (tsk->signal->oom_score_adj)
> +		trace_oom_score_task_rename(tsk, buf);
> +
>  	/*
>  	 * Threads may access current->comm without holding
>  	 * the task lock, so write the string carefully.
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 1050b1c..f201e64 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -87,6 +87,7 @@
>  #ifdef CONFIG_HARDWALL
>  #include <asm/hardwall.h>
>  #endif
> +#include <trace/events/oom.h>
>  #include "internal.h"
>  
>  /* NOTE:
> @@ -1166,6 +1167,7 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  	else
>  		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
>  								-OOM_DISABLE;
> +	trace_oom_score_adj_update(task);
>  err_sighand:
>  	unlock_task_sighand(task, &flags);
>  err_task_lock:
> @@ -1253,6 +1255,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
>  	task->signal->oom_score_adj = oom_score_adj;
>  	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
>  		task->signal->oom_score_adj_min = oom_score_adj;
> +	trace_oom_score_adj_update(task);
>  	/*
>  	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
>  	 * always attainable.
> diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
> new file mode 100644
> index 0000000..f5e6f55
> --- /dev/null
> +++ b/include/trace/events/oom.h
> @@ -0,0 +1,80 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM oom
> +
> +#if !defined(_TRACE_OOM_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_OOM_H
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(oom_score_adj_inherited,
> +
> +	TP_PROTO(struct task_struct *task),
> +	
> +	TP_ARGS(task),
> +
> +	TP_STRUCT__entry(
> +		__field(	pid_t,		newpid)
> +		__field(	  int,		oom_score_adj)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->newpid = task->pid;
> +		__entry->oom_score_adj = task->signal->oom_score_adj;
> +	),
> +
> +	TP_printk("new_task=%ld oom_score_adj=%d",
> +		__entry->newpid, __entry->oom_score_adj)
> +);
> +
> +TRACE_EVENT(oom_score_task_rename,
> +
> +	TP_PROTO(struct task_struct *task, char *comm),
> +
> +	TP_ARGS(task, comm),
> +
> +	TP_STRUCT__entry(
> +		__field(	pid_t,	 pid)
> +		__array(         char,   oldcomm,   TASK_COMM_LEN   )
> +		__array(         char,   newcomm,   TASK_COMM_LEN   )
> +		__field(	  int,   oom_score_adj)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = task->pid;
> +		 memcpy(__entry->oldcomm, task->comm, TASK_COMM_LEN);
> +		 memcpy(__entry->newcomm, comm, TASK_COMM_LEN);
> +		__entry->oom_score_adj = task->signal->oom_score_adj;
> +	),
> +
> +	TP_printk("rename task %ld[%s] to [%s] oom_score_adj=%d",
> +		__entry->pid, __entry->oldcomm, __entry->newcomm,
> +		__entry->oom_score_adj)
> +);
> +
> +TRACE_EVENT(oom_score_adj_update,
> +
> +	TP_PROTO(struct task_struct *task),
> +
> +	TP_ARGS(task),
> +
> +	TP_STRUCT__entry(
> +		__field(	pid_t,	pid)
> +		__array(	char,	comm,	TASK_COMM_LEN )
> +		__field(	 int,	oom_score_adj)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid = task->pid;
> +		memcpy(__entry->comm, task->comm, TASK_COMM_LEN);
> +		__entry->oom_score_adj = task->signal->oom_score_adj;
> +	),
> +
> +	TP_printk("task %ld[%s] updates oom_score_adj=%d",
> +		__entry->pid, __entry->comm, __entry->oom_score_adj)
> +);
> +
> +#endif
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> +
> +
> diff --git a/kernel/fork.c b/kernel/fork.c
> index e20518d..634aa84 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -76,6 +76,7 @@
>  #include <asm/tlbflush.h>
>  
>  #include <trace/events/sched.h>
> +#include <trace/events/oom.h>
>  
>  /*
>   * Protected counters by write_lock_irq(&tasklist_lock)
> @@ -1390,6 +1391,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	if (clone_flags & CLONE_THREAD)
>  		threadgroup_fork_read_unlock(current);
>  	perf_event_fork(p);
> +
> +	if (!(clone_flags & CLONE_THREAD) && p->signal->oom_score_adj)
> +		trace_oom_score_adj_inherited(p);
> +
>  	return p;
>  
>  bad_fork_free_pid:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e2e1402..46b6d0a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -33,6 +33,10 @@
>  #include <linux/security.h>
>  #include <linux/ptrace.h>
>  #include <linux/freezer.h>
> +#include <linux/ftrace.h>
> +
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/oom.h>
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> @@ -55,6 +59,7 @@ void compare_swap_oom_score_adj(int old_val, int new_val)
>  	spin_lock_irq(&sighand->siglock);
>  	if (current->signal->oom_score_adj == old_val)
>  		current->signal->oom_score_adj = new_val;
> +	trace_oom_score_adj_update(current);
>  	spin_unlock_irq(&sighand->siglock);
>  }
>  
> @@ -74,6 +79,7 @@ int test_set_oom_score_adj(int new_val)
>  	spin_lock_irq(&sighand->siglock);
>  	old_val = current->signal->oom_score_adj;
>  	current->signal->oom_score_adj = new_val;
> +	trace_oom_score_adj_update(current);
>  	spin_unlock_irq(&sighand->siglock);
>  
>  	return old_val;
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
