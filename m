Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25FC06B00A2
	for <linux-mm@kvack.org>; Wed, 27 May 2009 18:32:17 -0400 (EDT)
Date: Wed, 27 May 2009 18:32:28 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [RFC v16][PATCH 19/43] c/r: external checkpoint of a task	other
 than ourself
In-Reply-To: <20090527211950.GA7855@x200.localdomain>
Message-ID: <Pine.LNX.4.64.0905271831030.7284@takamine.ncl.cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
 <1243445589-32388-20-git-send-email-orenl@cs.columbia.edu>
 <20090527211950.GA7855@x200.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009, Alexey Dobriyan wrote:

> On Wed, May 27, 2009 at 01:32:45PM -0400, Oren Laadan wrote:
> > Now we can do "external" checkpoint, i.e. act on another task.
> 
> > +static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
> > +{
> > +	if (t->state == TASK_DEAD) {
> > +		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
> > +		return -EAGAIN;
> > +	}
> > +
> > +	if (!ptrace_may_access(t, PTRACE_MODE_READ)) {
> > +		__ckpt_write_err(ctx, "access to task %d (%s) denied",
> > +				 task_pid_vnr(t), t->comm);
> > +		return -EPERM;
> > +	}
> > +
> > +	/* verify that the task is frozen (unless self) */
> > +	if (t != current && !frozen(t)) {
> > +		__ckpt_write_err(ctx, "task %d (%s) is not frozen",
> > +				 task_pid_vnr(t), t->comm);
> > +		return -EBUSY;
> > +	}
> > +
> > +	/* FIX: add support for ptraced tasks */
> > +	if (task_ptrace(t)) {
> > +		__ckpt_write_err(ctx, "task %d (%s) is ptraced",
> > +				 task_pid_vnr(t), t->comm);
> > +		return -EBUSY;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int get_container(struct ckpt_ctx *ctx, pid_t pid)
> > +{
> > +	struct task_struct *task = NULL;
> > +	struct nsproxy *nsproxy = NULL;
> > +	int ret;
> > +
> > +	ctx->root_pid = pid;
> > +
> > +	read_lock(&tasklist_lock);
> > +	task = find_task_by_vpid(pid);
> > +	if (task)
> > +		get_task_struct(task);
> > +	read_unlock(&tasklist_lock);
> > +
> > +	if (!task)
> > +		return -ESRCH;
> > +
> > +	ret = may_checkpoint_task(ctx, task);
> > +	if (ret) {
> > +		ckpt_write_err(ctx, NULL);
> > +		put_task_struct(task);
> > +		return ret;
> > +	}
> > +
> > +	rcu_read_lock();
> > +	nsproxy = task_nsproxy(task);
> > +	get_nsproxy(nsproxy);
> 
> Will oops if init is multi-threaded and thread group leader exited
> (nsproxy = NULL). I need to think what to do, too.


ood catch. Since all threads share same nsproxy (except those
who exits.. duh) we can test for this case, and get the nsproxy
from any of the other threads, something like this (untested):

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index afc7300..b303876 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -522,9 +522,33 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(task);
-	get_nsproxy(nsproxy);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
 	rcu_read_unlock();
 
+	/*
+	 * If we hit a zombie thread-group-leader, nsproxy will be NULL,
+	 * and we instead grab it from one of the other threads.
+	 */
+	if (!nsproxy) {
+		struct task_struct *p = next_thread(task);
+
+		BUG_ON(task->state != TASK_DEAD);
+		read_lock(&tasklist_lock);
+		while (p != task && !task_nsproxy(p))
+			p = next_thread(p);
+		nsproxy = get_nsproxy(p);
+		if (nsproxy)
+			get_nsproxy(nsproxy);
+		read_unlock(&tasklist_lock);
+	}
+
+	/* still not ... too bad ... */
+	if (!nsproxy) {
+		put_task_struct(task);
+		return -ESRCH;
+	}
+
 	ctx->root_task = task;
 	ctx->root_nsproxy = nsproxy;
 	ctx->root_init = is_container_init(task);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
