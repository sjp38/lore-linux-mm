Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB216B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 10:36:17 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6NENPXX030282
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:23:25 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6NEP0v5034522
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:25:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6NEOtRg006354
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:24:56 -0600
Date: Thu, 23 Jul 2009 09:24:54 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v17][PATCH 19/60] c/r: documentation
Message-ID: <20090723142454.GA10769@us.ibm.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-20-git-send-email-orenl@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248256822-23416-20-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@librato.com):
> +Security
> +========
> +
> +The main question is whether sys_checkpoint() and sys_restart()
> +require privileged or unprivileged operation.
> +
> +Early versions checked capable(CAP_SYS_ADMIN) assuming that we would
> +attempt to remove the need for privilege, so that all users could
> +safely use it. Arnd Bergmann pointed out that it'd make more sense to
> +let unprivileged users use them now, so that we'll be more careful
> +about the security as patches roll in.
> +
> +Checkpoint: the main concern is whether a task that performs the
> +checkpoint of another task has sufficient privileges to access its
> +state. We address this by requiring that the checkpointer task will be
> +able to ptrace the target task, by means of ptrace_may_access() with
> +read mode.

with access mode now, actually.

> +Restart: the main concern is that we may allow an unprivileged user to
> +feed the kernel with random data. To this end, the restart works in a
> +way that does not skip the usual security checks. Task credentials,
> +i.e. euid, reuid, and LSM security contexts currently come from the
> +caller, not the checkpoint image.  When restoration of credentials
> +becomes supported, then definitely the ability of the task that calls
> +sys_restore() to setresuid/setresgid to those values must be checked.

That is now possible, and this is done.

> +Keeping the restart procedure to operate within the limits of the
> +caller's credentials means that there various scenarios that cannot
> +be supported. For instance, a setuid program that opened a protected
> +log file and then dropped privileges will fail the restart, because
> +the user won't have enough credentials to reopen the file. In these
> +cases, we should probably treat restarting like inserting a kernel
> +module: surely the user can cause havoc by providing incorrect data,
> +but then again we must trust the root account.
> +
> +So that's why we don't want CAP_SYS_ADMIN required up-front. That way
> +we will be forced to more carefully review each of those features.
> +However, this can be controlled with a sysctl-variable.
> +
> +
> diff --git a/Documentation/checkpoint/usage.txt b/Documentation/checkpoint/usage.txt
> new file mode 100644
> index 0000000..ed34765
> --- /dev/null
> +++ b/Documentation/checkpoint/usage.txt
> @@ -0,0 +1,193 @@
> +
> +	      How to use Checkpoint-Restart
> +	=========================================
> +
> +
> +API
> +===
> +
> +The API consists of two new system calls:
> +
> +* int checkpoint(pid_t pid, int fd, unsigned long flag);
> +
> + Checkpoint a (sub-)container whose root task is identified by @pid,
> + to the open file indicated by @fd. @flags may be on or more of:
> +   - CHECKPOINT_SUBTREE : allow checkpoint of sub-container
> + (other value are not allowed).
> +
> + Returns: a positive checkpoint identifier (ckptid) upon success, 0 if
> + it returns from a restart, and -1 if an error occurs. The ckptid will
> + uniquely identify a checkpoint image, for as long as the checkpoint
> + is kept in the kernel (e.g. if one wishes to keep a checkpoint, or a
> + partial checkpoint, residing in kernel memory).
> +
> +* int sys_restart(pid_t pid, int fd, unsigned long flags);
> +
> + Restart a process hierarchy from a checkpoint image that is read from
> + the blob stored in the file indicated by @fd. The @flags' will have
> + future meaning (must be 0 for now). @pid indicates the root of the
> + hierarchy as seen in the coordinator's pid-namespace, and is expected
> + to be a child of the coordinator. (Note that this argument may mean
> + 'ckptid' to identify an in-kernel checkpoint image, with some @flags
> + in the future).
> +
> + Returns: -1 if an error occurs, 0 on success when restarting from a
> + "self" checkpoint, and return value of system call at the time of the
> + checkpoint when restarting from an "external" checkpoint.

Return value of the checkpointed (init) task's syscall at the time of
external checkpoint?  If so, what's the use for this, as opposed to
returning 0 as in the case of self-checkpoint?

> + TODO: upon successful "external" restart, the container will end up
> + in a frozen state.

Should clone_with_pids() be mentioned here?

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
