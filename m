Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD696B00E9
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 22:21:23 -0500 (EST)
Message-ID: <49641F9B.9020803@cs.columbia.edu>
Date: Tue, 06 Jan 2009 22:20:59 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v12][PATCH 14/14] Restart multiple processes
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu> <1230542187-10434-15-git-send-email-orenl@cs.columbia.edu> <20090104201957.GA12725@us.ibm.com>
In-Reply-To: <20090104201957.GA12725@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl@cs.columbia.edu):
>> Restarting of multiple processes expects all restarting tasks to call
>> sys_restart(). Once inside the system call, each task will restart
>> itself at the same order that they were saved. The internals of the
>> syscall will take care of in-kernel synchronization bewteen tasks.

[...]

> Thanks, Oren.
> 
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> 
> with a few comments below.

Thanks for the comments.

[...]

>> +/* FIXME: this should be per container */
>> +DECLARE_WAIT_QUEUE_HEAD(cr_restart_waitq);
>> +
>> +static int do_restart_task(struct cr_ctx *ctx, pid_t pid)
> 
> Passing ctx in here, when it is always NULL, is just a bit
> confusing, and, since you goto out and cr_ctx_put(ctx) without
> initializing ctx, you make verifying that that's ok a step
> harder.
> 
> Do you intend to ever pass in non-NULL in later patches?

Yes; for instance I expect Andrey's create-tasks-in-kernel patch
(when ready) to eventually have each thread call do_restart_task().
I also liked the symmetry with do_restart_root()...

You are correct that it's confusing now, so I'll take it out.

> 
>> +{
>> +	struct task_struct *root_task;
>> +	int ret;
>> +
>> +	rcu_read_lock();
>> +	root_task = find_task_by_pid_ns(pid, current->nsproxy->pid_ns);
>> +	if (root_task)
>> +		get_task_struct(root_task);
>> +	rcu_read_unlock();
>> +
>> +	if (!root_task)
>> +		return -EINVAL;
>> +
>> +	/*
>> +	 * wait for container init to initialize the restart context, then
>> +	 * grab a reference to that context, and if we're the last task to
>> +	 * do it, notify the container init.
>> +	 */
>> +	ret = wait_event_interruptible(cr_restart_waitq,
>> +				       root_task->checkpoint_ctx);
> 
> Would seem more sensible to do the above using the ctx which
> you grabbed under task_lock(root_task) next.  Your whole
> locking of root_task->checkpoint_ctx seems haphazard (see below).

At this point 'root_task->checkpoint_ctx' may still be NULL if the
container init did not yet initialize it. That's why we first wait
for it to become non-NULL.

The code solves a coordination problem between the container init and
the other tasks, given that:
a) the order in which they call sys_restart() is unknown
b) the container init creates a 'ctx' that is to be used by everyone

The container init simply (1) allocates a shared 'ctx' and makes it
visible via 'root_task->chcekpoint_ctx', then waits for all tasks to
grab it (thus, be ready to restart), then initiates the restart chain,
and finally waits for all tasks to finish.

The other tasks, because of (a) and (b), may enter the kernel before
the container init completes its step (1). So they must first wait
for that 'ctx' to be available

> 
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	task_lock(root_task);
>> +	ctx = root_task->checkpoint_ctx;
>> +	if (ctx)
>> +		cr_ctx_get(ctx);
>> +	task_unlock(root_task);

So the other tasks work in two steps:
1) wait for the container init ->checkpoint_ctx (we don't know when !)
2) grab a reference to that 'ctx'

Step (2) ensures that our reference to 'ctx' is valid even if the
container init exits (due to error, signal etc). The last user of
the 'ctx' will be the one to actually free it.

I use the lock to protect against time-of-check to time-of-use race
(e.g.the container init may exit due to an error or a signal); the
container init also grabs the lock before clearing its ->checkpoint_ctx.

>> +
>> +	if (!ctx) {
>> +		ret = -EAGAIN;
>> +		goto out;
>> +	}
>> +
>> +	if (atomic_dec_and_test(&ctx->tasks_count))
>> +		complete(&ctx->complete);
>> +
>> +	/* wait for our turn, do the restore, and tell next task in line */
>> +	ret = cr_wait_task(ctx);
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_read_task(ctx);
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_next_task(ctx);
>> +
>> + out:
>> +	cr_ctx_put(ctx);
>> +	put_task_struct(root_task);
>> +	return ret;
>> +}
>> +
>> +static int cr_wait_all_tasks_start(struct cr_ctx *ctx)
>> +{
>> +	int ret;
>> +
>> +	if (ctx->pids_nr == 1)
>> +		return 0;
>> +
>> +	init_completion(&ctx->complete);
>> +	current->checkpoint_ctx = ctx;
>> +
>> +	wake_up_all(&cr_restart_waitq);
>> +
>> +	ret = wait_for_completion_interruptible(&ctx->complete);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	task_lock(current);
>> +	current->checkpoint_ctx = NULL;
>> +	task_unlock(current);
> 
> Who can you be racing with here?  All other tasks should have
> already dereferenced current->checkpoint_ctx.
> 
> If you want to always lock root_task around setting and
> reading of (root_task|current)->checkpoint_ctx, that's
> ok, but I think you can sufficiently argue that your
> completion is completely protecint readers from the sole
> writer.

Only lock around clearing and reading; setting is safe.

The completion is interruptible so that you can signal or kill
the container init if something goes wrong, e.g. bad checkpoint
image causes it to wait for non-existing processes forever.

At a second glance, the clearing of '->checkpoint_ctx' must
happen regardless of whether an error occurred, so the test for
'ret < 0' should follow (and not precede) it.

[...]

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
