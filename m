Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E9E416B00BA
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 22:32:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6U2Wuls024598
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Jul 2009 11:32:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC2B345DE4F
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 11:32:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBEF145DE63
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 11:32:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 500981DB8040
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 11:32:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4CACE38001
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 11:32:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
Message-Id: <20090730090855.E415.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 30 Jul 2009 11:32:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

NAK this. I explain the reason at below.


> It's helpful to be able to specify an oom_adj value for newly forked
> children that do not share memory with the parent.
> 
> Before making oom_adj values a characteristic of a task's mm in
> 2ff05b2b4eac2e63d345fc731ea151a060247f53, it was possible to change the
> oom_adj value of a vfork() child prior to execve() without implicitly
> changing the oom_adj value of the parent.  With the new behavior, the
> oom_adj values of both threads would change since they represent the same
> memory.
> 
> That change was necessary to fix an oom killer livelock which would occur
> when a child would be selected for oom kill prior to execve() and the
> task could not be killed because it shared memory with an OOM_DISABLE
> parent.  In fact, only the most negative (most immune) oom_adj value for
> all threads sharing the same memory would actually be used by the oom
> killer, leaving inconsistencies amongst all other threads having
> different oom_adj values (and, thus, incorrectly exported
> /proc/pid/oom_score values).
> 
> This patch adds a new per-process parameter: /proc/pid/oom_adj_child.

nit: per-thread.

> This defaults to mirror the value of /proc/pid/oom_adj but may be changed
> so that mm's initialized by their children are preferred over the parent
> by the oom killer.  Setting oom_adj_child to be less (i.e. more immune)
> than the task's oom_adj value itself is governed by the CAP_SYS_RESOURCE
> capability.
> 
> When a mm is initialized, the initial oom_adj value will be set to the
> parent's oom_adj_child.  This allows tasks to elevate the oom_adj value
> of a vfork'd child prior to execve() before the execution actually takes
> place.
> 
> Furthermore, /proc/pid/oom_adj_child is inherited from the task that
> forked it.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Paul Menage <menage@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/filesystems/proc.txt |   38 ++++++++++++++++----
>  fs/proc/base.c                     |   68 ++++++++++++++++++++++++++++++++++++
>  include/linux/sched.h              |    1 +
>  kernel/fork.c                      |    3 +-
>  4 files changed, 101 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -34,10 +34,11 @@ Table of Contents
>  
>    3	Per-Process Parameters
>    3.1	/proc/<pid>/oom_adj - Adjust the oom-killer score
> -  3.2	/proc/<pid>/oom_score - Display current oom-killer score
> -  3.3	/proc/<pid>/io - Display the IO accounting fields
> -  3.4	/proc/<pid>/coredump_filter - Core dump filtering settings
> -  3.5	/proc/<pid>/mountinfo - Information about mounts
> +  3.2	/proc/<pid>/oom_adj_child - Change default oom_adj for children
> +  3.3	/proc/<pid>/oom_score - Display current oom-killer score
> +  3.4	/proc/<pid>/io - Display the IO accounting fields
> +  3.5	/proc/<pid>/coredump_filter - Core dump filtering settings
> +  3.6	/proc/<pid>/mountinfo - Information about mounts
>  
>  
>  ------------------------------------------------------------------------------
> @@ -1206,7 +1207,28 @@ The task with the highest badness score is then selected and its children
>  are killed, process itself will be killed in an OOM situation when it does
>  not have children or some of them disabled oom like described above.
>  
> -3.2 /proc/<pid>/oom_score - Display current oom-killer score
> +
> +3.2 /proc/<pid>/oom_adj_child - Change default oom_adj for children
> +-------------------------------------------------------------------
> +
> +This file can be used to change the default oom_adj value for children when a
> +new mm is initialized.  The oom_adj value for a child's mm is typically the
> +task's oom_adj value itself, however this value can be altered by writing to
> +this file.
> +
> +This is particularly helpful when a child is vfork'd and its mm following exec
> +should have a higher priority oom_adj value than its parent.  The new mm will
> +default to oom_adj_child of the parent task.
> +
> +oom_adj_child will mirror oom_adj whenever the latter changes for all tasks
> +that share its memory.  This avoids having to set both values when simply
> +tuning oom_adj and that value should be inherited by all children.
> +
> +Setting oom_adj_child to be more immune than the task's mm itself (i.e. less
> +than oom_adj) is governed by the CAP_SYS_RESOURCE capability.
> +
> +
> +3.3 /proc/<pid>/oom_score - Display current oom-killer score
>  -------------------------------------------------------------
>  
>  This file can be used to check the current score used by the oom-killer is for
> @@ -1214,7 +1236,7 @@ any given <pid>. Use it together with /proc/<pid>/oom_adj to tune which
>  process should be killed in an out-of-memory situation.
>  
>  
> -3.3  /proc/<pid>/io - Display the IO accounting fields
> +3.4  /proc/<pid>/io - Display the IO accounting fields
>  -------------------------------------------------------
>  
>  This file contains IO statistics for each running process
> @@ -1316,7 +1338,7 @@ those 64-bit counters, process A could see an intermediate result.
>  More information about this can be found within the taskstats documentation in
>  Documentation/accounting.
>  
> -3.4 /proc/<pid>/coredump_filter - Core dump filtering settings
> +3.5 /proc/<pid>/coredump_filter - Core dump filtering settings
>  ---------------------------------------------------------------
>  When a process is dumped, all anonymous memory is written to a core file as
>  long as the size of the core file isn't limited. But sometimes we don't want
> @@ -1360,7 +1382,7 @@ For example:
>    $ echo 0x7 > /proc/self/coredump_filter
>    $ ./some_program
>  
> -3.5	/proc/<pid>/mountinfo - Information about mounts
> +3.6	/proc/<pid>/mountinfo - Information about mounts
>  --------------------------------------------------------
>  
>  This file contains lines of the form:
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1023,6 +1023,7 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  				size_t count, loff_t *ppos)
>  {
>  	struct task_struct *task;
> +	struct task_struct *g, *p;
>  	char buffer[PROC_NUMBUF], *end;
>  	int oom_adjust;
>  
> @@ -1051,6 +1052,12 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
>  		put_task_struct(task);
>  		return -EACCES;
>  	}
> +	read_lock(&tasklist_lock);
> +	do_each_thread(g, p) {
> +		if (p->mm && p->mm == task->mm)
> +			p->oom_adj_child = oom_adjust;
> +	} while_each_thread(g, p);
> +	read_unlock(&tasklist_lock);
>  	task->mm->oom_adj = oom_adjust;
>  	task_unlock(task);
>  	put_task_struct(task);
> @@ -1064,6 +1071,65 @@ static const struct file_operations proc_oom_adjust_operations = {
>  	.write		= oom_adjust_write,
>  };
>  
> +static ssize_t oom_adj_child_read(struct file *file, char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
> +	char buffer[PROC_NUMBUF];
> +	size_t len;
> +	int oom_adj_child;
> +
> +	if (!task)
> +		return -ESRCH;
> +	oom_adj_child = task->oom_adj_child;
> +	put_task_struct(task);
> +
> +	len = snprintf(buffer, sizeof(buffer), "%i\n", oom_adj_child);
> +
> +	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> +}
> +
> +static ssize_t oom_adj_child_write(struct file *file, const char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	char buffer[PROC_NUMBUF], *end;
> +	int oom_adj_child;
> +
> +	memset(buffer, 0, sizeof(buffer));
> +	if (count > sizeof(buffer) - 1)
> +		count = sizeof(buffer) - 1;
> +	if (copy_from_user(buffer, buf, count))
> +		return -EFAULT;
> +	oom_adj_child = simple_strtol(buffer, &end, 0);
> +	if ((oom_adj_child < OOM_ADJUST_MIN ||
> +	     oom_adj_child > OOM_ADJUST_MAX) && oom_adj_child != OOM_DISABLE)
> +		return -EINVAL;
> +	if (*end == '\n')
> +		end++;
> +	task = get_proc_task(file->f_path.dentry->d_inode);
> +	if (!task)
> +		return -ESRCH;
> +	task_lock(task);
> +	if (task->mm && oom_adj_child < task->mm->oom_adj &&
> +	    !capable(CAP_SYS_RESOURCE)) {
> +		task_unlock(task);
> +		put_task_struct(task);
> +		return -EINVAL;
> +	}
> +	task_unlock(task);
> +	task->oom_adj_child = oom_adj_child;
> +	put_task_struct(task);
> +	if (end - buffer == 0)
> +		return -EIO;
> +	return end - buffer;
> +}
> +
> +static const struct file_operations proc_oom_adj_child_operations = {
> +	.read		= oom_adj_child_read,
> +	.write		= oom_adj_child_write,
> +};
> +
>  #ifdef CONFIG_AUDITSYSCALL
>  #define TMPBUFLEN 21
>  static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
> @@ -2548,6 +2614,7 @@ static const struct pid_entry tgid_base_stuff[] = {
>  #endif
>  	INF("oom_score",  S_IRUGO, proc_oom_score),
>  	REG("oom_adj",    S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> +	REG("oom_adj_child",	S_IRUGO|S_IWUSR, proc_oom_adj_child_operations),
>  #ifdef CONFIG_AUDITSYSCALL
>  	REG("loginuid",   S_IWUSR|S_IRUGO, proc_loginuid_operations),
>  	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
> @@ -2886,6 +2953,7 @@ static const struct pid_entry tid_base_stuff[] = {
>  #endif
>  	INF("oom_score", S_IRUGO, proc_oom_score),
>  	REG("oom_adj",   S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
> +	REG("oom_adj_child",	S_IRUGO|S_IWUSR, proc_oom_adj_child_operations),
>  #ifdef CONFIG_AUDITSYSCALL
>  	REG("loginuid",  S_IWUSR|S_IRUGO, proc_loginuid_operations),
>  	REG("sessionid",  S_IRUSR, proc_sessionid_operations),
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1198,6 +1198,7 @@ struct task_struct {
>  	 * a short time
>  	 */
>  	unsigned char fpu_counter;
> +	s8 oom_adj_child;	/* Default child OOM-kill score adjustment */
>  #ifdef CONFIG_BLK_DEV_IO_TRACE
>  	unsigned int btrace_seq;
>  #endif
> diff --git a/kernel/fork.c b/kernel/fork.c
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -426,7 +426,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
>  	init_rwsem(&mm->mmap_sem);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
> -	mm->oom_adj = (current->mm) ? current->mm->oom_adj : 0;
> +	mm->oom_adj = p->oom_adj_child;

This code doesn't fix anything.
mm->oom_adj assignment still change vfork() parent process oom_adj value.
(Again, vfork() parent and child use the same mm)

IOW, in vfork case, oom_adj_child parameter doesn't only change child oom_adj,
but also parent oom_adj value.
IOW, oom_adj_child is NOT child effective parameter.


>  	mm->core_state = NULL;
>  	mm->nr_ptes = 0;
>  	set_mm_counter(mm, file_rss, 0);
> @@ -679,6 +679,7 @@ good_mm:
>  
>  	tsk->mm = mm;
>  	tsk->active_mm = mm;
> +	tsk->oom_adj_child = mm->oom_adj;
>  	return 0;
>  
>  fail_nomem:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
