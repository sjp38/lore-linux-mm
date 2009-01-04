Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF0976B00D3
	for <linux-mm@kvack.org>; Sun,  4 Jan 2009 15:20:01 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n04KHlij028400
	for <linux-mm@kvack.org>; Sun, 4 Jan 2009 13:17:47 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n04KK0en210334
	for <linux-mm@kvack.org>; Sun, 4 Jan 2009 13:20:00 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n04KJxFc023765
	for <linux-mm@kvack.org>; Sun, 4 Jan 2009 13:20:00 -0700
Date: Sun, 4 Jan 2009 14:19:57 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v12][PATCH 14/14] Restart multiple processes
Message-ID: <20090104201957.GA12725@us.ibm.com>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu> <1230542187-10434-15-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1230542187-10434-15-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Restarting of multiple processes expects all restarting tasks to call
> sys_restart(). Once inside the system call, each task will restart
> itself at the same order that they were saved. The internals of the
> syscall will take care of in-kernel synchronization bewteen tasks.
> 
> This patch does _not_ create the task tree in the kernel. Instead it
> assumes that all tasks are created in some way and then invoke the
> restart syscall. You can use the userspace mktree.c program to do
> that.
> 
> The init task (*) has a special role: it allocates the restart context
> (ctx), and coordinates the operation. In particular, it first waits
> until all participating tasks enter the kernel, and provides them the
> common restart context. Once everyone in ready, it begins to restart
> itself.
> 
> In contrast, the other tasks enter the kernel, locate the init task (*)
> and grab its restart context, and then wait for their turn to restore.
> 
> When a task (init or not) completes its restart, it hands the control
> over to the next in line, by waking that task.
> 
> An array of pids (the one saved during the checkpoint) is used to
> synchronize the operation. The first task in the array is the init
> task (*). The restart context (ctx) maintain a "current position" in
> the array, which indicates which task is currently active. Once the
> currently active task completes its own restart, it increments that
> position and wakes up the next task.
> 
> Restart assumes that userspace provides meaningful data, otherwise
> it's garbage-in-garbage-out. In this case, the syscall may block
> indefinitely, but in TASK_INTERRUPTIBLE, so the user can ctrl-c or
> otherwise kill the stray restarting tasks.
> 
> In terms of security, restart runs as the user the invokes it, so it
> will not allow a user to do more than is otherwise permitted by the
> usual system semantics and policy.
> 
> Currently we ignore threads and zombies, as well as session ids.
> Add support for multiple processes
> 
> (*) For containers, restart should be called inside a fresh container
> by the init task of that container. However, it is also possible to
> restart applications not necessarily inside a container, and without
> restoring the original pids of the processes (that is, provided that
> the application can tolerate such behavior). This is useful to allow
> multi-process restart of tasks not isolated inside a container, and
> also for debugging.
> 
> Changelog[v12]:
>   - Replace obsolete cr_debug() with pr_debug()
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

Thanks, Oren.

Acked-by: Serge Hallyn <serue@us.ibm.com>

with a few comments below.

> ---
>  checkpoint/restart.c       |  214 +++++++++++++++++++++++++++++++++++++++++++-
>  checkpoint/sys.c           |   34 ++++++--
>  include/linux/checkpoint.h |   23 ++++-
>  include/linux/sched.h      |    1 +
>  4 files changed, 258 insertions(+), 14 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 0c46abf..6b4cd75 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -10,6 +10,7 @@
> 
>  #include <linux/version.h>
>  #include <linux/sched.h>
> +#include <linux/wait.h>
>  #include <linux/file.h>
>  #include <linux/magic.h>
>  #include <linux/checkpoint.h>
> @@ -276,30 +277,235 @@ static int cr_read_task(struct cr_ctx *ctx)
>  	return ret;
>  }
> 
> +/* cr_read_tree - read the tasks tree into the checkpoint context */
> +static int cr_read_tree(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_tree *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int parent, size, ret = -EINVAL;
> +
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TREE);
> +	if (parent < 0) {
> +		ret = parent;
> +		goto out;
> +	} else if (parent != 0)
> +		goto out;
> +
> +	if (hh->tasks_nr < 0)
> +		goto out;
> +
> +	ctx->pids_nr = hh->tasks_nr;
> +	size = sizeof(*ctx->pids_arr) * ctx->pids_nr;
> +	if (size < 0)		/* overflow ? */
> +		goto out;
> +
> +	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
> +	if (!ctx->pids_arr) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +	ret = cr_kread(ctx, ctx->pids_arr, size);
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return ret;
> +}
> +
> +static int cr_wait_task(struct cr_ctx *ctx)
> +{
> +	pid_t pid = task_pid_vnr(current);
> +
> +	pr_debug("pid %d waiting\n", pid);
> +	return wait_event_interruptible(ctx->waitq, ctx->pids_active == pid);
> +}
> +
> +static int cr_next_task(struct cr_ctx *ctx)
> +{
> +	struct task_struct *tsk;
> +
> +	ctx->pids_pos++;
> +
> +	pr_debug("pids_pos %d %d\n", ctx->pids_pos, ctx->pids_nr);
> +	if (ctx->pids_pos == ctx->pids_nr) {
> +		complete(&ctx->complete);
> +		return 0;
> +	}
> +
> +	ctx->pids_active = ctx->pids_arr[ctx->pids_pos].vpid;
> +
> +	pr_debug("pids_next %d\n", ctx->pids_active);
> +
> +	rcu_read_lock();
> +	tsk = find_task_by_pid_ns(ctx->pids_active, ctx->root_nsproxy->pid_ns);
> +	if (tsk)
> +		wake_up_process(tsk);
> +	rcu_read_unlock();
> +
> +	if (!tsk) {
> +		ctx->pids_err = -ESRCH;
> +		complete(&ctx->complete);
> +		return -ESRCH;
> +	}
> +
> +	return 0;
> +}
> +
> +/* FIXME: this should be per container */
> +DECLARE_WAIT_QUEUE_HEAD(cr_restart_waitq);
> +
> +static int do_restart_task(struct cr_ctx *ctx, pid_t pid)

Passing ctx in here, when it is always NULL, is just a bit
confusing, and, since you goto out and cr_ctx_put(ctx) without
initializing ctx, you make verifying that that's ok a step
harder.

Do you intend to ever pass in non-NULL in later patches?

> +{
> +	struct task_struct *root_task;
> +	int ret;
> +
> +	rcu_read_lock();
> +	root_task = find_task_by_pid_ns(pid, current->nsproxy->pid_ns);
> +	if (root_task)
> +		get_task_struct(root_task);
> +	rcu_read_unlock();
> +
> +	if (!root_task)
> +		return -EINVAL;
> +
> +	/*
> +	 * wait for container init to initialize the restart context, then
> +	 * grab a reference to that context, and if we're the last task to
> +	 * do it, notify the container init.
> +	 */
> +	ret = wait_event_interruptible(cr_restart_waitq,
> +				       root_task->checkpoint_ctx);

Would seem more sensible to do the above using the ctx which
you grabbed under task_lock(root_task) next.  Your whole
locking of root_task->checkpoint_ctx seems haphazard (see below).

> +	if (ret < 0)
> +		goto out;
> +
> +	task_lock(root_task);
> +	ctx = root_task->checkpoint_ctx;
> +	if (ctx)
> +		cr_ctx_get(ctx);
> +	task_unlock(root_task);
> +
> +	if (!ctx) {
> +		ret = -EAGAIN;
> +		goto out;
> +	}
> +
> +	if (atomic_dec_and_test(&ctx->tasks_count))
> +		complete(&ctx->complete);
> +
> +	/* wait for our turn, do the restore, and tell next task in line */
> +	ret = cr_wait_task(ctx);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_task(ctx);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_next_task(ctx);
> +
> + out:
> +	cr_ctx_put(ctx);
> +	put_task_struct(root_task);
> +	return ret;
> +}
> +
> +static int cr_wait_all_tasks_start(struct cr_ctx *ctx)
> +{
> +	int ret;
> +
> +	if (ctx->pids_nr == 1)
> +		return 0;
> +
> +	init_completion(&ctx->complete);
> +	current->checkpoint_ctx = ctx;
> +
> +	wake_up_all(&cr_restart_waitq);
> +
> +	ret = wait_for_completion_interruptible(&ctx->complete);
> +	if (ret < 0)
> +		return ret;
> +
> +	task_lock(current);
> +	current->checkpoint_ctx = NULL;
> +	task_unlock(current);

Who can you be racing with here?  All other tasks should have
already dereferenced current->checkpoint_ctx.

If you want to always lock root_task around setting and
reading of (root_task|current)->checkpoint_ctx, that's
ok, but I think you can sufficiently argue that your
completion is completely protecint readers from the sole
writer.

> +
> +	return 0;
> +}
> +
> +static int cr_wait_all_tasks_finish(struct cr_ctx *ctx)
> +{
> +	int ret;
> +
> +	if (ctx->pids_nr == 1)
> +		return 0;
> +
> +	init_completion(&ctx->complete);
> +
> +	ret = cr_next_task(ctx);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = wait_for_completion_interruptible(&ctx->complete);
> +	if (ret < 0)
> +		return ret;
> +
> +	return 0;
> +}
> +
>  /* setup restart-specific parts of ctx */
>  static int cr_ctx_restart(struct cr_ctx *ctx, pid_t pid)
>  {
> +	ctx->root_pid = pid;
> +	ctx->root_task = current;
> +	ctx->root_nsproxy = current->nsproxy;
> +
> +	get_task_struct(ctx->root_task);
> +	get_nsproxy(ctx->root_nsproxy);
> +
> +	atomic_set(&ctx->tasks_count, ctx->pids_nr - 1);
> +
>  	return 0;
>  }
> 
> -int do_restart(struct cr_ctx *ctx, pid_t pid)
> +static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
>  {
>  	int ret;
> 
> +	ret = cr_read_head(ctx);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_tree(ctx);
> +	if (ret < 0)
> +		goto out;
> +
>  	ret = cr_ctx_restart(ctx, pid);
>  	if (ret < 0)
>  		goto out;
> -	ret = cr_read_head(ctx);
> +
> +	/* wait for all other tasks to enter do_restart_task() */
> +	ret = cr_wait_all_tasks_start(ctx);
>  	if (ret < 0)
>  		goto out;
> +
>  	ret = cr_read_task(ctx);
>  	if (ret < 0)
>  		goto out;
> -	ret = cr_read_tail(ctx);
> +
> +	/* wait for all other tasks to complete do_restart_task() */
> +	ret = cr_wait_all_tasks_finish(ctx);
>  	if (ret < 0)
>  		goto out;
> 
> -	/* on success, adjust the return value if needed [TODO] */
> +	ret = cr_read_tail(ctx);
> +
>   out:
>  	return ret;
>  }
> +
> +int do_restart(struct cr_ctx *ctx, pid_t pid)
> +{
> +	int ret;
> +
> +	if (ctx)
> +		ret = do_restart_root(ctx, pid);
> +	else
> +		ret = do_restart_task(ctx, pid);
> +
> +	/* on success, adjust the return value if needed [TODO] */
> +	return ret;
> +}
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 0436ef3..f26b0c6 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -167,6 +167,8 @@ static void cr_task_arr_free(struct cr_ctx *ctx)
> 
>  static void cr_ctx_free(struct cr_ctx *ctx)
>  {
> +	BUG_ON(atomic_read(&ctx->refcount));
> +
>  	if (ctx->file)
>  		fput(ctx->file);
> 
> @@ -185,6 +187,8 @@ static void cr_ctx_free(struct cr_ctx *ctx)
>  	if (ctx->root_task)
>  		put_task_struct(ctx->root_task);
> 
> +	kfree(ctx->pids_arr);
> +
>  	kfree(ctx);
>  }
> 
> @@ -199,8 +203,10 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
> 
>  	ctx->flags = flags;
> 
> +	atomic_set(&ctx->refcount, 0);
>  	INIT_LIST_HEAD(&ctx->pgarr_list);
>  	INIT_LIST_HEAD(&ctx->pgarr_pool);
> +	init_waitqueue_head(&ctx->waitq);
> 
>  	err = -EBADF;
>  	ctx->file = fget(fd);
> @@ -215,6 +221,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
>  	if (cr_objhash_alloc(ctx) < 0)
>  		goto err;
> 
> +	atomic_inc(&ctx->refcount);
>  	return ctx;
> 
>   err:
> @@ -222,6 +229,17 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
>  	return ERR_PTR(err);
>  }
> 
> +void cr_ctx_get(struct cr_ctx *ctx)
> +{
> +	atomic_inc(&ctx->refcount);
> +}
> +
> +void cr_ctx_put(struct cr_ctx *ctx)
> +{
> +	if (ctx && atomic_dec_and_test(&ctx->refcount))
> +		cr_ctx_free(ctx);
> +}
> +
>  /**
>   * sys_checkpoint - checkpoint a container
>   * @pid: pid of the container init(1) process
> @@ -249,7 +267,7 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>  	if (!ret)
>  		ret = ctx->crid;
> 
> -	cr_ctx_free(ctx);
> +	cr_ctx_put(ctx);
>  	return ret;
>  }
> 
> @@ -264,7 +282,7 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>   */
>  asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
>  {
> -	struct cr_ctx *ctx;
> +	struct cr_ctx *ctx = NULL;
>  	pid_t pid;
>  	int ret;
> 
> @@ -272,15 +290,17 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
>  	if (flags)
>  		return -EINVAL;
> 
> -	ctx = cr_ctx_alloc(fd, flags | CR_CTX_RSTR);
> -	if (IS_ERR(ctx))
> -		return PTR_ERR(ctx);
> -
>  	/* FIXME: for now, we use 'crid' as a pid */
>  	pid = (pid_t) crid;
> 
> +	if (pid == task_pid_vnr(current))
> +		ctx = cr_ctx_alloc(fd, flags | CR_CTX_RSTR);
> +
> +	if (IS_ERR(ctx))
> +		return PTR_ERR(ctx);
> +
>  	ret = do_restart(ctx, pid);
> 
> -	cr_ctx_free(ctx);
> +	cr_ctx_put(ctx);
>  	return ret;
>  }
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 86fcec9..041bd4d 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -13,10 +13,11 @@
>  #include <linux/fs.h>
>  #include <linux/path.h>
>  #include <linux/sched.h>
> +#include <asm/atomic.h>
> 
>  #ifdef CONFIG_CHECKPOINT_RESTART
> 
> -#define CR_VERSION  2
> +#define CR_VERSION  3
> 
>  struct cr_ctx {
>  	int crid;		/* unique checkpoint id */
> @@ -34,8 +35,7 @@ struct cr_ctx {
>  	void *hbuf;		/* temporary buffer for headers */
>  	int hpos;		/* position in headers buffer */
> 
> -	struct task_struct **tasks_arr;	/* array of all tasks in container */
> -	int tasks_nr;			/* size of tasks array */
> +	atomic_t refcount;
> 
>  	struct cr_objhash *objhash;	/* hash for shared objects */
> 
> @@ -43,6 +43,20 @@ struct cr_ctx {
>  	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
> 
>  	struct path fs_mnt;	/* container root (FIXME) */
> +
> +	/* [multi-process checkpoint] */
> +	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
> +	int tasks_nr;                   /* size of tasks array */
> +
> +	/* [multi-process restart] */
> +	struct cr_hdr_pids *pids_arr;	/* array of all pids [restart] */
> +	int pids_nr;			/* size of pids array */
> +	int pids_pos;			/* position pids array */
> +	int pids_err;			/* error occured ? */
> +	pid_t pids_active;		/* pid of (next) active task */
> +	atomic_t tasks_count;		/* sync of restarting tasks */

'sync of restarting tasks' for 3 vars suggests one or two or three
might benefit from more detailed comment  :)

> +	struct completion complete;	/* sync of restarting tasks */
> +	wait_queue_head_t waitq;	/* sync of restarting tasks */
>  };
> 
>  /* cr_ctx: flags */
> @@ -55,6 +69,9 @@ extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
>  extern void *cr_hbuf_get(struct cr_ctx *ctx, int n);
>  extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
> 
> +extern void cr_ctx_get(struct cr_ctx *ctx);
> +extern void cr_ctx_put(struct cr_ctx *ctx);
> +
>  /* shared objects handling */
> 
>  enum {
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index faa2ec6..0150e90 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1359,6 +1359,7 @@ struct task_struct {
> 
>  #ifdef CONFIG_CHECKPOINT_RESTART
>  	atomic_t may_checkpoint;
> +	struct cr_ctx *checkpoint_ctx;
>  #endif
>  };
> 
> -- 
> 1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
