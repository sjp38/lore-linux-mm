Date: Thu, 3 Jan 2008 01:40:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 11] avoid selecting already killed tasks
In-Reply-To: <4cf8805b5695a8a3fb7c.1199326150@v2.random>
Message-ID: <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com>
References: <4cf8805b5695a8a3fb7c.1199326150@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> avoid selecting already killed tasks
> 
> If the killed task doesn't go away because it's waiting on some other
> task who needs to allocate memory, to release the i_sem or some other
> lock, we must fallback to killing some other task in order to kill the
> original selected and already oomkilled task, but the logic that kills
> the childs first, would deadlock, if the already oom-killed task was
> actually the first child of the newly oom-killed task.
> 

The problem is that this can cause the parent or one of its children to be 
unnecessarily killed.

Regardless of any OOM killer sychronization that we do, it is still 
possible for the OOM killer to return after killing a task and then 
another OOM situation be triggered on a subsequent allocation attempt 
before the killed task has exited.  It's still marked as TIF_MEMDIE, so 
your change will exempt it from being a target again and one of its 
siblings or, worse, it's parent will be killed.

You can't guarantee that this couldn't have been prevented given 
sufficient time for the exiting task to die, so this change introduces the 
possibility that tasks will unnecessarily be killed to alleviate the OOM 
condition.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
