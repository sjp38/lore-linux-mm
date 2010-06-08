Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 835896B01ED
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg1RL012427
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:02 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 49B3345DE51
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2266345DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 06D511DB803F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AE311DB8038
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com>
Message-Id: <20100608194533.7657.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> This a complete rewrite of the oom killer's badness() heuristic which is
> used to determine which task to kill in oom conditions.  The goal is to
> make it as simple and predictable as possible so the results are better
> understood and we end up killing the task which will lead to the most
> memory freeing while still respecting the fine-tuning from userspace.
> 
> Instead of basing the heuristic on mm->total_vm for each task, the task's
> rss and swap space is used instead.  This is a better indication of the
> amount of memory that will be freeable if the oom killed task is chosen
> and subsequently exits.  This helps specifically in cases where KDE or
> GNOME is chosen for oom kill on desktop systems instead of a memory
> hogging task.
> 
> The baseline for the heuristic is a proportion of memory that each task is
> currently using in memory plus swap compared to the amount of "allowable"
> memory.  "Allowable," in this sense, means the system-wide resources for
> unconstrained oom conditions, the set of mempolicy nodes, the mems
> attached to current's cpuset, or a memory controller's limit.  The
> proportion is given on a scale of 0 (never kill) to 1000 (always kill),
> roughly meaning that if a task has a badness() score of 500 that the task
> consumes approximately 50% of allowable memory resident in RAM or in swap
> space.
> 
> The proportion is always relative to the amount of "allowable" memory and
> not the total amount of RAM systemwide so that mempolicies and cpusets may
> operate in isolation; they shall not need to know the true size of the
> machine on which they are running if they are bound to a specific set of
> nodes or mems, respectively.
> 
> Root tasks are given 3% extra memory just like __vm_enough_memory()
> provides in LSMs.  In the event of two tasks consuming similar amounts of
> memory, it is generally better to save root's task.
> 
> Because of the change in the badness() heuristic's baseline, it is also
> necessary to introduce a new user interface to tune it.  It's not possible
> to redefine the meaning of /proc/pid/oom_adj with a new scale since the
> ABI cannot be changed for backward compatability.  Instead, a new tunable,
> /proc/pid/oom_score_adj, is added that ranges from -1000 to +1000.  It may
> be used to polarize the heuristic such that certain tasks are never
> considered for oom kill while others may always be considered.  The value
> is added directly into the badness() score so a value of -500, for
> example, means to discount 50% of its memory consumption in comparison to
> other tasks either on the system, bound to the mempolicy, in the cpuset,
> or sharing the same memory controller.
> 
> /proc/pid/oom_adj is changed so that its meaning is rescaled into the
> units used by /proc/pid/oom_score_adj, and vice versa.  Changing one of
> these per-task tunables will rescale the value of the other to an
> equivalent meaning.  Although /proc/pid/oom_adj was originally defined as
> a bitshift on the badness score, it now shares the same linear growth as
> /proc/pid/oom_score_adj but with different granularity.  This is required
> so the ABI is not broken with userspace applications and allows oom_adj to
> be deprecated for future removal.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/filesystems/proc.txt |   94 ++++++++-----
>  fs/proc/base.c                     |   99 ++++++++++++-
>  include/linux/memcontrol.h         |    8 +
>  include/linux/oom.h                |   14 ++-
>  include/linux/sched.h              |    3 +-
>  kernel/fork.c                      |    1 +
>  mm/memcontrol.c                    |   18 +++
>  mm/oom_kill.c                      |  279 ++++++++++++++++--------------------
>  8 files changed, 316 insertions(+), 200 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -33,7 +33,8 @@ Table of Contents
>    2	Modifying System Parameters
>  
>    3	Per-Process Parameters
> -  3.1	/proc/<pid>/oom_adj - Adjust the oom-killer score
> +  3.1	/proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj - Adjust the oom-killer
> +								score
>    3.2	/proc/<pid>/oom_score - Display current oom-killer score
>    3.3	/proc/<pid>/io - Display the IO accounting fields
>    3.4	/proc/<pid>/coredump_filter - Core dump filtering settings
> @@ -1234,42 +1235,61 @@ of the kernel.
>  CHAPTER 3: PER-PROCESS PARAMETERS
>  ------------------------------------------------------------------------------
>  
> -3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
> -------------------------------------------------------
> -
> -This file can be used to adjust the score used to select which processes
> -should be killed in an  out-of-memory  situation.  Giving it a high score will
> -increase the likelihood of this process being killed by the oom-killer.  Valid
> -values are in the range -16 to +15, plus the special value -17, which disables
> -oom-killing altogether for this process.
> -
> -The process to be killed in an out-of-memory situation is selected among all others
> -based on its badness score. This value equals the original memory size of the process
> -and is then updated according to its CPU time (utime + stime) and the
> -run time (uptime - start time). The longer it runs the smaller is the score.
> -Badness score is divided by the square root of the CPU time and then by
> -the double square root of the run time.
> -
> -Swapped out tasks are killed first. Half of each child's memory size is added to
> -the parent's score if they do not share the same memory. Thus forking servers
> -are the prime candidates to be killed. Having only one 'hungry' child will make
> -parent less preferable than the child.
> -
> -/proc/<pid>/oom_score shows process' current badness score.
> -
> -The following heuristics are then applied:
> - * if the task was reniced, its score doubles
> - * superuser or direct hardware access tasks (CAP_SYS_ADMIN, CAP_SYS_RESOURCE
> - 	or CAP_SYS_RAWIO) have their score divided by 4
> - * if oom condition happened in one cpuset and checked process does not belong
> - 	to it, its score is divided by 8
> - * the resulting score is multiplied by two to the power of oom_adj, i.e.
> -	points <<= oom_adj when it is positive and
> -	points >>= -(oom_adj) otherwise
> -
> -The task with the highest badness score is then selected and its children
> -are killed, process itself will be killed in an OOM situation when it does
> -not have children or some of them disabled oom like described above.
> +3.1 /proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj- Adjust the oom-killer score
> +--------------------------------------------------------------------------------
> +
> +These file can be used to adjust the badness heuristic used to select which
> +process gets killed in out of memory conditions.
> +
> +The badness heuristic assigns a value to each candidate task ranging from 0
> +(never kill) to 1000 (always kill) to determine which process is targeted.  The
> +units are roughly a proportion along that range of allowed memory the process
> +may allocate from based on an estimation of its current memory and swap use.
> +For example, if a task is using all allowed memory, its badness score will be
> +1000.  If it is using half of its allowed memory, its score will be 500.
> +
> +There is an additional factor included in the badness score: root
> +processes are given 3% extra memory over other tasks.
> +
> +The amount of "allowed" memory depends on the context in which the oom killer
> +was called.  If it is due to the memory assigned to the allocating task's cpuset
> +being exhausted, the allowed memory represents the set of mems assigned to that
> +cpuset.  If it is due to a mempolicy's node(s) being exhausted, the allowed
> +memory represents the set of mempolicy nodes.  If it is due to a memory
> +limit (or swap limit) being reached, the allowed memory is that configured
> +limit.  Finally, if it is due to the entire system being out of memory, the
> +allowed memory represents all allocatable resources.
> +
> +The value of /proc/<pid>/oom_score_adj is added to the badness score before it
> +is used to determine which task to kill.  Acceptable values range from -1000
> +(OOM_SCORE_ADJ_MIN) to +1000 (OOM_SCORE_ADJ_MAX).  This allows userspace to
> +polarize the preference for oom killing either by always preferring a certain
> +task or completely disabling it.  The lowest possible value, -1000, is
> +equivalent to disabling oom killing entirely for that task since it will always
> +report a badness score of 0.
> +
> +Consequently, it is very simple for userspace to define the amount of memory to
> +consider for each task.  Setting a /proc/<pid>/oom_score_adj value of +500, for
> +example, is roughly equivalent to allowing the remainder of tasks sharing the
> +same system, cpuset, mempolicy, or memory controller resources to use at least
> +50% more memory.  A value of -500, on the other hand, would be roughly
> +equivalent to discounting 50% of the task's allowed memory from being considered
> +as scoring against the task.
> +
> +For backwards compatibility with previous kernels, /proc/<pid>/oom_adj may also
> +be used to tune the badness score.  Its acceptable values range from -16
> +(OOM_ADJUST_MIN) to +15 (OOM_ADJUST_MAX) and a special value of -17
> +(OOM_DISABLE) to disable oom killing entirely for that task.  Its value is
> +scaled linearly with /proc/<pid>/oom_score_adj.
> +
> +Writing to /proc/<pid>/oom_score_adj or /proc/<pid>/oom_adj will change the
> +other with its scaled value.
> +
> +Caveat: when a parent task is selected, the oom killer will sacrifice any first
> +generation children with seperate address spaces instead, if possible.  This
> +avoids servers and important system daemons from being killed and loses the
> +minimal amount of work.
> +
>  
>  3.2 /proc/<pid>/oom_score - Display current oom-killer score
>  -------------------------------------------------------------
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -63,6 +63,7 @@
>  #include <linux/namei.h>
>  #include <linux/mnt_namespace.h>
>  #include <linux/mm.h>
> +#include <linux/swap.h>
>  #include <linux/rcupdate.h>
>  #include <linux/kallsyms.h>
>  #include <linux/stacktrace.h>
> @@ -428,16 +429,18 @@ static const struct file_operations proc_lstats_operations = {
>  #endif
>  
>  /* The badness from the OOM killer */
> -unsigned long badness(struct task_struct *p, unsigned long uptime);
>  static int proc_oom_score(struct task_struct *task, char *buffer)
>  {
>  	unsigned long points = 0;
> -	struct timespec uptime;
>  
> -	do_posix_clock_monotonic_gettime(&uptime);
>  	read_lock(&tasklist_lock);
>  	if (pid_alive(task))
> -		points = badness(task, uptime.tv_sec);
> +		points = oom_badness(task->group_leader,
> +					global_page_state(NR_INACTIVE_ANON) +
> +					global_page_state(NR_ACTIVE_ANON) +
> +					global_page_state(NR_INACTIVE_FILE) +
> +					global_page_state(NR_ACTIVE_FILE) +
> +					total_swap_pages);

Sorry I can't ack this. again and again, I try to explain why this is wrong
(hopefully last)

1) incompatibility
   oom_score is one of ABI. then, we can't change this. from enduser view,
   this change is no merit. In general, an incompatibility is allowed on very
   limited situation such as that an end-user get much benefit than compatibility.
   In other word, old style ABI doesn't works fine from end user view.
   But, in this case, it isn't.

2) technically incorrect
   this math is not correct math. this is not represented "allowed memory".
   example, 1) this is not accumulated mlocked memory, but it can be freed
   task kill 2) SHM_LOCKED memory freeablility depend on IPC_RMID did or not.
   if not, task killing doesn't free SYSV IPC memory.
   In additon, 3) This normalization doesn't works on asymmetric numa. 
   total pages and oom are not related almostly. 4) scalability. if the 
   system 10TB memory, 1 point oom score mean 10GB memory consumption.
   it seems too rough. generically, a value suppression itself is evil for
   scalability software.

Then, we can't merge this our kernel. if your workload really need this,
we consider following simplest hook instead.

	if (badness_hook_fn)
		points = badness_hook_fn(p)
	else
		points = oom_badness(p);

Please implement your specific oom-score in your hook func.


>  	read_unlock(&tasklist_lock);
>  	return sprintf(buffer, "%lu\n", points);
>  }
> @@ -1042,7 +1045,15 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  	}
>  
>  	task->signal->oom_adj = oom_adjust;
> -
> +	/*
> +	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
> +	 * value is always attainable.
> +	 */
> +	if (task->signal->oom_adj == OOM_ADJUST_MAX)
> +		task->signal->oom_score_adj = OOM_SCORE_ADJ_MAX;
> +	else
> +		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
> +								-OOM_DISABLE;
>  	unlock_task_sighand(task, &flags);
>  	put_task_struct(task);

Generically, I wasn't against the feature for rare use-case. but sorry,
as far as I investigated, I haven't find any actual user. then, I don't
put ack, because my reviewing basically stand on 1) how much user use this
2) how strongly required this from an users 3) how much side effect is there
etc etc. not cool or not.
A zero user feature is basically out of scope of mine. please separate 
this feature, and discuss another reviewers (e.g. Nick, Kamezawa-san). 
If you can get one or more reviewer ack, I don't put objection.

I don't want dicuss this topic you anymore. I can't imazine I and you
reach to agree this.



> @@ -1055,6 +1066,82 @@ static const struct file_operations proc_oom_adjust_operations = {
>  	.llseek		= generic_file_llseek,
>  };
>  
> +static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
> +					size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
> +	char buffer[PROC_NUMBUF];
> +	int oom_score_adj = OOM_SCORE_ADJ_MIN;
> +	unsigned long flags;
> +	size_t len;
> +
> +	if (!task)
> +		return -ESRCH;
> +	if (lock_task_sighand(task, &flags)) {
> +		oom_score_adj = task->signal->oom_score_adj;
> +		unlock_task_sighand(task, &flags);
> +	}
> +	put_task_struct(task);
> +	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
> +	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> +}
> +
> +static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
> +					size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	char buffer[PROC_NUMBUF];
> +	unsigned long flags;
> +	long oom_score_adj;
> +	int err;
> +
> +	memset(buffer, 0, sizeof(buffer));
> +	if (count > sizeof(buffer) - 1)
> +		count = sizeof(buffer) - 1;
> +	if (copy_from_user(buffer, buf, count))
> +		return -EFAULT;
> +
> +	err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
> +	if (err)
> +		return -EINVAL;
> +	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
> +			oom_score_adj > OOM_SCORE_ADJ_MAX)
> +		return -EINVAL;
> +
> +	task = get_proc_task(file->f_path.dentry->d_inode);
> +	if (!task)
> +		return -ESRCH;
> +	if (!lock_task_sighand(task, &flags)) {
> +		put_task_struct(task);
> +		return -ESRCH;
> +	}
> +	if (oom_score_adj < task->signal->oom_score_adj &&
> +			!capable(CAP_SYS_RESOURCE)) {
> +		unlock_task_sighand(task, &flags);
> +		put_task_struct(task);
> +		return -EACCES;
> +	}
> +
> +	task->signal->oom_score_adj = oom_score_adj;
> +	/*
> +	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
> +	 * always attainable.
> +	 */
> +	if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +		task->signal->oom_adj = OOM_DISABLE;
> +	else
> +		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
> +							OOM_SCORE_ADJ_MAX;
> +	unlock_task_sighand(task, &flags);
> +	put_task_struct(task);
> +	return count;
> +}
> +
> +static const struct file_operations proc_oom_score_adj_operations = {
> +	.read		= oom_score_adj_read,
> +	.write		= oom_score_adj_write,
> +};
> +
>  #ifdef CONFIG_AUDITSYSCALL
>  #define TMPBUFLEN 21
>  static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
> @@ -2627,6 +2714,7 @@ static const struct pid_entry tgid_base_stuff[] = {
>  #endif
>  	INF("oom_score",  S_IRUGO, proc_oom_score),
>  	REG("oom_adj",    S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> +	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
>  #ifdef CONFIG_AUDITSYSCALL
>  	REG("loginuid",   S_IWUSR|S_IRUGO, proc_loginuid_operations),
>  	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
> @@ -2961,6 +3049,7 @@ static const struct pid_entry tid_base_stuff[] = {
>  #endif
>  	INF("oom_score", S_IRUGO, proc_oom_score),
>  	REG("oom_adj",   S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> +	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
>  #ifdef CONFIG_AUDITSYSCALL
>  	REG("loginuid",  S_IWUSR|S_IRUGO, proc_loginuid_operations),
>  	REG("sessionid",  S_IRUSR, proc_sessionid_operations),
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -130,6 +130,8 @@ void mem_cgroup_update_file_mapped(struct page *page, int val);
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
>  						int zid);
> +u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> @@ -309,6 +311,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  	return 0;
>  }
>  
> +static inline
> +u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -1,14 +1,24 @@
>  #ifndef __INCLUDE_LINUX_OOM_H
>  #define __INCLUDE_LINUX_OOM_H
>  
> -/* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
> +/*
> + * /proc/<pid>/oom_adj set to -17 protects from the oom-killer
> + */
>  #define OOM_DISABLE (-17)
>  /* inclusive */
>  #define OOM_ADJUST_MIN (-16)
>  #define OOM_ADJUST_MAX 15
>  
> +/*
> + * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
> + * pid.
> + */
> +#define OOM_SCORE_ADJ_MIN	(-1000)
> +#define OOM_SCORE_ADJ_MAX	1000
> +
>  #ifdef __KERNEL__
>  
> +#include <linux/sched.h>
>  #include <linux/types.h>
>  #include <linux/nodemask.h>
>  
> @@ -25,6 +35,8 @@ enum oom_constraint {
>  	CONSTRAINT_MEMCG,
>  };
>  
> +extern unsigned int oom_badness(struct task_struct *p,
> +					unsigned long totalpages);
>  extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -629,7 +629,8 @@ struct signal_struct {
>  	struct tty_audit_buf *tty_audit_buf;
>  #endif
>  
> -	int oom_adj;	/* OOM kill score adjustment (bit shift) */
> +	int oom_adj;		/* OOM kill score adjustment (bit shift) */
> +	int oom_score_adj;	/* OOM kill score adjustment */
>  };
>  
>  /* Context switch must be unlocked if interrupts are to be enabled */
> diff --git a/kernel/fork.c b/kernel/fork.c
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -899,6 +899,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
>  	tty_audit_fork(sig);
>  
>  	sig->oom_adj = current->signal->oom_adj;
> +	sig->oom_score_adj = current->signal->oom_score_adj;
>  
>  	return 0;
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1158,6 +1158,24 @@ static int mem_cgroup_count_children(struct mem_cgroup *mem)
>  }
>  
>  /*
> + * Return the memory (and swap, if configured) limit for a memcg.
> + */
> +u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> +{
> +	u64 limit;
> +	u64 memsw;
> +
> +	limit = res_counter_read_u64(&memcg->res, RES_LIMIT) +
> +			total_swap_pages;
> +	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> +	/*
> +	 * If memsw is finite and limits the amount of swap space available
> +	 * to this memcg, return that limit.
> +	 */
> +	return min(limit, memsw);
> +}
> +
> +/*
>   * Visit the first child (need not be the first child as per the ordering
>   * of the cgroup list, since we track last_scanned_child) of @mem and use
>   * that to reclaim free pages from.
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -4,6 +4,8 @@
>   *  Copyright (C)  1998,2000  Rik van Riel
>   *	Thanks go out to Claus Fischer for some serious inspiration and
>   *	for goading me into coding this file...
> + *  Copyright (C)  2010  Google, Inc.
> + *	Rewritten by David Rientjes

don't put it.



>   *
>   *  The routines in this file are used to kill a process when
>   *  we're seriously out of memory. This gets called from __alloc_pages()
> @@ -34,7 +36,6 @@ int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks = 1;
>  static DEFINE_SPINLOCK(zone_scan_lock);
> -/* #define DEBUG */
>  
>  /*
>   * Do all threads of the target process overlap our allowed nodes?
> @@ -84,139 +85,72 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
>  }
>  
>  /**
> - * badness - calculate a numeric value for how bad this task has been
> + * oom_badness - heuristic function to determine which candidate task to kill
>   * @p: task struct of which task we should calculate
> - * @uptime: current uptime in seconds
> + * @totalpages: total present RAM allowed for page allocation
>   *
> - * The formula used is relatively simple and documented inline in the
> - * function. The main rationale is that we want to select a good task
> - * to kill when we run out of memory.
> - *
> - * Good in this context means that:
> - * 1) we lose the minimum amount of work done
> - * 2) we recover a large amount of memory
> - * 3) we don't kill anything innocent of eating tons of memory
> - * 4) we want to kill the minimum amount of processes (one)
> - * 5) we try to kill the process the user expects us to kill, this
> - *    algorithm has been meticulously tuned to meet the principle
> - *    of least surprise ... (be careful when you change it)
> + * The heuristic for determining which task to kill is made to be as simple and
> + * predictable as possible.  The goal is to return the highest value for the
> + * task consuming the most memory to avoid subsequent oom failures.
>   */
> -
> -unsigned long badness(struct task_struct *p, unsigned long uptime)
> +unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
>  {
> -	unsigned long points, cpu_time, run_time;
> -	struct task_struct *child;
> -	struct task_struct *c, *t;
> -	int oom_adj = p->signal->oom_adj;
> -	struct task_cputime task_time;
> -	unsigned long utime;
> -	unsigned long stime;
> -
> -	if (oom_adj == OOM_DISABLE)
> -		return 0;
> +	int points;
>  
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 0;
>  
>  	/*
> -	 * The memory size of the process is the basis for the badness.
> -	 */
> -	points = p->mm->total_vm;
> -
> -	/*
> -	 * After this unlock we can no longer dereference local variable `mm'
> -	 */
> -	task_unlock(p);
> -
> -	/*
> -	 * swapoff can easily use up all memory, so kill those first.
> +	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> +	 * need to be executed for something that cannot be killed.
>  	 */
> -	if (p->flags & PF_OOM_ORIGIN)
> -		return ULONG_MAX;
> -
> -	/*
> -	 * Processes which fork a lot of child processes are likely
> -	 * a good choice. We add half the vmsize of the children if they
> -	 * have an own mm. This prevents forking servers to flood the
> -	 * machine with an endless amount of children. In case a single
> -	 * child is eating the vast majority of memory, adding only half
> -	 * to the parents will make the child our kill candidate of choice.
> -	 */
> -	t = p;
> -	do {
> -		list_for_each_entry(c, &t->children, sibling) {
> -			child = find_lock_task_mm(c);
> -			if (child) {
> -				if (child->mm != p->mm)
> -					points += child->mm->total_vm/2 + 1;
> -				task_unlock(child);
> -			}
> -		}
> -	} while_each_thread(p, t);
> +	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +		task_unlock(p);
> +		return 0;
> +	}
>  
>  	/*
> -	 * CPU time is in tens of seconds and run time is in thousands
> -         * of seconds. There is no particular reason for this other than
> -         * that it turned out to work very well in practice.
> +	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
> +	 * priority for oom killing.
>  	 */
> -	thread_group_cputime(p, &task_time);
> -	utime = cputime_to_jiffies(task_time.utime);
> -	stime = cputime_to_jiffies(task_time.stime);
> -	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
> -
> -
> -	if (uptime >= p->start_time.tv_sec)
> -		run_time = (uptime - p->start_time.tv_sec) >> 10;
> -	else
> -		run_time = 0;
> -
> -	if (cpu_time)
> -		points /= int_sqrt(cpu_time);
> -	if (run_time)
> -		points /= int_sqrt(int_sqrt(run_time));
> +	if (p->flags & PF_OOM_ORIGIN) {
> +		task_unlock(p);
> +		return 1000;
> +	}
>  
>  	/*
> -	 * Niced processes are most likely less important, so double
> -	 * their badness points.
> +	 * The memory controller may have a limit of 0 bytes, so avoid a divide
> +	 * by zero if necessary.
>  	 */
> -	if (task_nice(p) > 0)
> -		points *= 2;

You removed 
  - run time check
  - cpu time check
  - nice check

but no described the reason. reviewers are puzzled. How do we review
this though we don't get your point? please write

 - What benerit is there?
 - Why do you think no bad effect?
 - How confirm do you?


> +	if (!totalpages)
> +		totalpages = 1;
>  
>  	/*
> -	 * Superuser processes are usually more important, so we make it
> -	 * less likely that we kill those.
> +	 * The baseline for the badness score is the proportion of RAM that each
> +	 * task's rss and swap space use.
>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> -	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
> -		points /= 4;
> +	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
> +			totalpages;
> +	task_unlock(p);
>  
>  	/*
> -	 * We don't want to kill a process with direct hardware access.
> -	 * Not only could that mess up the hardware, but usually users
> -	 * tend to only have this flag set on applications they think
> -	 * of as important.
> +	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> +	 * implementation used by LSMs.
>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
> -		points /= 4;
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> +		points -= 30;


CAP_SYS_ADMIN seems no good idea. CAP_SYS_ADMIN imply admin's interactive
process. but killing interactive process only cause force logout. but
killing system daemon can makes more catastrophic disaster.


Last of all, I'll pulled this one. but only do cherry-pick.


>  
>  	/*
> -	 * Adjust the score by oom_adj.
> +	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
> +	 * either completely disable oom killing or always prefer a certain
> +	 * task.
>  	 */
> -	if (oom_adj) {
> -		if (oom_adj > 0) {
> -			if (!points)
> -				points = 1;
> -			points <<= oom_adj;
> -		} else
> -			points >>= -(oom_adj);
> -	}
> +	points += p->signal->oom_score_adj;
>  
> -#ifdef DEBUG
> -	printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
> -	p->pid, p->comm, points);
> -#endif
> -	return points;
> +	if (points < 0)
> +		return 0;
> +	return (points < 1000) ? points : 1000;
>  }
>  
>  /*
> @@ -224,12 +158,24 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>   */
>  #ifdef CONFIG_NUMA
>  static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -				    gfp_t gfp_mask, nodemask_t *nodemask)
> +				gfp_t gfp_mask, nodemask_t *nodemask,
> +				unsigned long *totalpages)
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	bool cpuset_limited = false;
> +	int nid;
>  
> +	/* Default to all anonymous memory, page cache, and swap */
> +	*totalpages = global_page_state(NR_INACTIVE_ANON) +
> +			global_page_state(NR_ACTIVE_ANON) +
> +			global_page_state(NR_INACTIVE_FILE) +
> +			global_page_state(NR_ACTIVE_FILE) +
> +			total_swap_pages;
> +
> +	if (!zonelist)
> +		return CONSTRAINT_NONE;
>  	/*
>  	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
>  	 * to kill current.We have to random task kill in this case.
> @@ -239,26 +185,47 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>  		return CONSTRAINT_NONE;
>  
>  	/*
> -	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> -	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> -	 * feature. mempolicy is an only user of nodemask here.
> -	 * check mempolicy's nodemask contains all N_HIGH_MEMORY
> +	 * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
> +	 * the page allocator means a mempolicy is in effect.  Cpuset policy
> +	 * is enforced in get_page_from_freelist().
>  	 */
> -	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
> +	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask)) {
> +		*totalpages = total_swap_pages;
> +		for_each_node_mask(nid, *nodemask)
> +			*totalpages += node_page_state(nid, NR_INACTIVE_ANON) +
> +					node_page_state(nid, NR_ACTIVE_ANON) +
> +					node_page_state(nid, NR_INACTIVE_FILE) +
> +					node_page_state(nid, NR_ACTIVE_FILE);
>  		return CONSTRAINT_MEMORY_POLICY;
> +	}
>  
>  	/* Check this allocation failure is caused by cpuset's wall function */
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  			high_zoneidx, nodemask)
>  		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> -			return CONSTRAINT_CPUSET;
> -
> +			cpuset_limited = true;
> +
> +	if (cpuset_limited) {
> +		*totalpages = total_swap_pages;
> +		for_each_node_mask(nid, cpuset_current_mems_allowed)
> +			*totalpages += node_page_state(nid, NR_INACTIVE_ANON) +
> +					node_page_state(nid, NR_ACTIVE_ANON) +
> +					node_page_state(nid, NR_INACTIVE_FILE) +
> +					node_page_state(nid, NR_ACTIVE_FILE);
> +		return CONSTRAINT_CPUSET;
> +	}
>  	return CONSTRAINT_NONE;
>  }
>  #else
>  static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -				gfp_t gfp_mask, nodemask_t *nodemask)
> +				gfp_t gfp_mask, nodemask_t *nodemask,
> +				unsigned long *totalpages)
>  {
> +	*totalpages = global_page_state(NR_INACTIVE_ANON) +
> +			global_page_state(NR_ACTIVE_ANON) +
> +			global_page_state(NR_INACTIVE_FILE) +
> +			global_page_state(NR_ACTIVE_FILE) +
> +			total_swap_pages;
>  	return CONSTRAINT_NONE;
>  }
>  #endif
> @@ -269,18 +236,16 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>   *
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
> -static struct task_struct *select_bad_process(unsigned long *ppoints,
> -		struct mem_cgroup *mem, enum oom_constraint constraint,
> -		const nodemask_t *mask)
> +static struct task_struct *select_bad_process(unsigned int *ppoints,
> +		unsigned long totalpages, struct mem_cgroup *mem,
> +		enum oom_constraint constraint, const nodemask_t *mask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *chosen = NULL;
> -	struct timespec uptime;
>  	*ppoints = 0;
>  
> -	do_posix_clock_monotonic_gettime(&uptime);
>  	for_each_process(p) {
> -		unsigned long points;
> +		unsigned int points;
>  
>  		/* skip the init task and kthreads */
>  		if (is_global_init(p) || (p->flags & PF_KTHREAD))
> @@ -319,14 +284,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  				return ERR_PTR(-1UL);
>  
>  			chosen = p;
> -			*ppoints = ULONG_MAX;
> +			*ppoints = 1000;
>  		}
>  
> -		if (p->signal->oom_adj == OOM_DISABLE)
> -			continue;
> -
> -		points = badness(p, uptime.tv_sec);
> -		if (points > *ppoints || !chosen) {
> +		points = oom_badness(p, totalpages);
> +		if (points > *ppoints) {
>  			chosen = p;
>  			*ppoints = points;
>  		}
> @@ -341,7 +303,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>   *
>   * Dumps the current memory state of all system tasks, excluding kernel threads.
>   * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
> - * score, and name.
> + * value, oom_score_adj value, and name.
>   *
>   * If the actual is non-NULL, only tasks that are a member of the mem_cgroup are
>   * shown.
> @@ -354,7 +316,7 @@ static void dump_tasks(const struct mem_cgroup *mem)
>  	struct task_struct *task;
>  
>  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
> -	       "name\n");
> +	       "oom_score_adj name\n");
>  	for_each_process(p) {
>  		/*
>  		 * We don't have is_global_init() check here, because the old
> @@ -376,10 +338,11 @@ static void dump_tasks(const struct mem_cgroup *mem)
>  			continue;
>  		}
>  
> -		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> +		pr_info("[%5d] %5d %5d %8lu %8lu %3d     %3d          %4d %s\n",
>  		       task->pid, __task_cred(task)->uid, task->tgid,
>  		       task->mm->total_vm, get_mm_rss(task->mm),
> -		       (int)task_cpu(task), task->signal->oom_adj, p->comm);
> +		       (int)task_cpu(task), task->signal->oom_adj,
> +		       task->signal->oom_score_adj, p->comm);
>  		task_unlock(task);
>  	}
>  }
> @@ -388,8 +351,9 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  							struct mem_cgroup *mem)
>  {
>  	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
> -		"oom_adj=%d\n",
> -		current->comm, gfp_mask, order, current->signal->oom_adj);
> +		"oom_adj=%d, oom_score_adj=%d\n",
> +		current->comm, gfp_mask, order, current->signal->oom_adj,
> +		current->signal->oom_score_adj);
>  	task_lock(current);
>  	cpuset_print_task_mems_allowed(current);
>  	task_unlock(current);
> @@ -404,7 +368,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  static int oom_kill_task(struct task_struct *p)
>  {
>  	p = find_lock_task_mm(p);
> -	if (!p || p->signal->oom_adj == OOM_DISABLE) {
> +	if (!p || p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
>  		task_unlock(p);
>  		return 1;
>  	}
> @@ -422,14 +386,13 @@ static int oom_kill_task(struct task_struct *p)
>  #undef K
>  
>  static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> -			    unsigned long points, struct mem_cgroup *mem,
> -			    const char *message)
> +			    unsigned int points, unsigned long totalpages,
> +			    struct mem_cgroup *mem, const char *message)
>  {
>  	struct task_struct *victim = p;
>  	struct task_struct *c;
>  	struct task_struct *t = p;
> -	unsigned long victim_points = 0;
> -	struct timespec uptime;
> +	unsigned int victim_points = 0;
>  
>  	if (printk_ratelimit())
>  		dump_header(p, gfp_mask, order, mem);
> @@ -443,13 +406,12 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		return 0;
>  	}
>  
> -	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> +	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
>  
>  	/* Try to sacrifice the worst child first */
> -	do_posix_clock_monotonic_gettime(&uptime);
>  	do {
> -		unsigned long cpoints;
> +		unsigned int cpoints;
>  
>  		list_for_each_entry(c, &t->children, sibling) {
>  			if (c->mm == p->mm)
> @@ -457,8 +419,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			if (mem && !task_in_mem_cgroup(c, mem))
>  				continue;
>  
> -			/* badness() returns 0 if the thread is unkillable */
> -			cpoints = badness(c, uptime.tv_sec);
> +			/*
> +			 * oom_badness() returns 0 if the thread is unkillable
> +			 */
> +			cpoints = oom_badness(c, totalpages);
>  			if (cpoints > victim_points) {
>  				victim = c;
>  				victim_points = cpoints;
> @@ -496,17 +460,19 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  {
> -	unsigned long points = 0;
> +	unsigned long limit;
> +	unsigned int points = 0;
>  	struct task_struct *p;
>  
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
> +	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem, CONSTRAINT_MEMCG, NULL);
> +	p = select_bad_process(&points, limit, mem, CONSTRAINT_MEMCG, NULL);
>  	if (!p || PTR_ERR(p) == -1UL)
>  		goto out;
>  
> -	if (oom_kill_process(p, gfp_mask, 0, points, mem,
> +	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
>  				"Memory cgroup out of memory"))
>  		goto retry;
>  out:
> @@ -619,22 +585,22 @@ static void clear_system_oom(void)
>  /*
>   * Must be called with tasklist_lock held for read.
>   */
> -static void __out_of_memory(gfp_t gfp_mask, int order,
> +static void __out_of_memory(gfp_t gfp_mask, int order, unsigned long totalpages,
>  			enum oom_constraint constraint, const nodemask_t *mask)
>  {
>  	struct task_struct *p;
> -	unsigned long points;
> +	unsigned int points;
>  
>  	if (sysctl_oom_kill_allocating_task)
> -		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
> -				"Out of memory (oom_kill_allocating_task)"))
> +		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
> +			NULL, "Out of memory (oom_kill_allocating_task)"))
>  			return;
>  retry:
>  	/*
>  	 * Rambo mode: Shoot down a process and hope it solves whatever
>  	 * issues we may have.
>  	 */
> -	p = select_bad_process(&points, NULL, constraint, mask);
> +	p = select_bad_process(&points, totalpages, NULL, constraint, mask);
>  
>  	if (PTR_ERR(p) == -1UL)
>  		return;
> @@ -646,7 +612,7 @@ retry:
>  		panic("Out of memory and no killable processes...\n");
>  	}
>  
> -	if (oom_kill_process(p, gfp_mask, order, points, NULL,
> +	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
>  			     "Out of memory"))
>  		goto retry;
>  }
> @@ -666,6 +632,7 @@ retry:
>  void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *nodemask)
>  {
> +	unsigned long totalpages;
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
> @@ -688,11 +655,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA) that may require different handling.
>  	 */
> -	if (zonelist)
> -		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
> +	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
> +						&totalpages);
>  	check_panic_on_oom(constraint, gfp_mask, order);
>  	read_lock(&tasklist_lock);
> -	__out_of_memory(gfp_mask, order, constraint, nodemask);
> +	__out_of_memory(gfp_mask, order, totalpages, constraint, nodemask);
>  	read_unlock(&tasklist_lock);
>  
>  	/*



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
