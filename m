Date: Thu, 3 Jan 2008 14:41:37 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 04 of 11] avoid selecting already killed tasks
Message-ID: <20080103134137.GT30939@v2.random>
References: <4cf8805b5695a8a3fb7c.1199326150@v2.random> <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 01:40:09AM -0800, David Rientjes wrote:
> On Thu, 3 Jan 2008, Andrea Arcangeli wrote:
> 
> > avoid selecting already killed tasks
> > 
> > If the killed task doesn't go away because it's waiting on some other
> > task who needs to allocate memory, to release the i_sem or some other
> > lock, we must fallback to killing some other task in order to kill the
> > original selected and already oomkilled task, but the logic that kills
> > the childs first, would deadlock, if the already oom-killed task was
> > actually the first child of the newly oom-killed task.
> > 
> 
> The problem is that this can cause the parent or one of its children to be 
> unnecessarily killed.

Well, the single fact I'm skipping over the TIF_MEMDIE tasks to
prevent deadlocks, allows for spurious oom killing again. Like you
said we can later add a per-task timeout so we wait only X seconds for
a certain TIF_MEMDIE task to quit before selecting another one.

But we got to ignore those TIF_MEMDIE tasks unfortunately, or we
deadlock, no matter if we're in select_bad_process, or in
oom_kill_process. Initially I didn't notice oom_kill_process had that
problem so I was then deadlocking despite select_bad_process was
selecting the parent that didn't have TIF_MEMDIE set (but the first
child already had it).

> Regardless of any OOM killer sychronization that we do, it is still 
> possible for the OOM killer to return after killing a task and then 
> another OOM situation be triggered on a subsequent allocation attempt 
> before the killed task has exited.  It's still marked as TIF_MEMDIE, so 
> your change will exempt it from being a target again and one of its 
> siblings or, worse, it's parent will be killed.

This is the risk of suprious oom killing yes. You got to choose
between a deadlock and risking a suprious oom killing. Even when you
add your 60second timeout in the task_struct between each new TIF_MEMDIE
bitflag set, you're still going to risk spurious oom killing...

The schedule_timeout in the oom killer and in the VM that I have in my
patchset combined with your very limited functionality of
zone-oom-lock (limited because it's gone by the time out_of_memory
returns and it currently can't take into account when the TIF_MEMDIE
task actually exited) in practice didn't generate suprious kills in my
testing. It may not be enough but it's a start...

> You can't guarantee that this couldn't have been prevented given 
> sufficient time for the exiting task to die, so this change introduces the 
> possibility that tasks will unnecessarily be killed to alleviate the OOM 
> condition.

Not just to 'alleviate' the oom condition, but to prevent a system crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
