Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D94D6B008A
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:37:24 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id e12so1501695fga.4
        for <linux-mm@kvack.org>; Wed, 27 May 2009 12:37:56 -0700 (PDT)
Date: Wed, 27 May 2009 23:37:58 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC v16][PATCH 23/43] c/r: restart multiple processes
Message-ID: <20090527193758.GC31930@x200.localdomain>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu> <1243445589-32388-24-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243445589-32388-24-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 01:32:49PM -0400, Oren Laadan wrote:
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
> Currently we ignore threads and zombies

Let's discuss threads and zombies.

1. Will zombie end up in a image?
2. If yes, how it will be restored. Will it be forked, call restart(2)
   and then somehow zombified inside kernel?
3. How thread group will be restored, will every thread be CLONE_THREAD'ed?
   What to do with exited thread group leaders, will they be forked, then
   CLONE_THREAD thread group?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
