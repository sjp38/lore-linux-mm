Date: Thu, 3 Jan 2008 10:47:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 11] avoid selecting already killed tasks
In-Reply-To: <20080103134137.GT30939@v2.random>
Message-ID: <alpine.DEB.0.9999.0801031036110.27032@chino.kir.corp.google.com>
References: <4cf8805b5695a8a3fb7c.1199326150@v2.random> <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com> <20080103134137.GT30939@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> But we got to ignore those TIF_MEMDIE tasks unfortunately, or we
> deadlock, no matter if we're in select_bad_process, or in
> oom_kill_process. Initially I didn't notice oom_kill_process had that
> problem so I was then deadlocking despite select_bad_process was
> selecting the parent that didn't have TIF_MEMDIE set (but the first
> child already had it).
> 

Traditionally we've only allowed one thread in the entire system to have 
TIF_MEMDIE at a time because as you give access to memory reserves to more 
threads it becomes less of a help to exiting tasks.  So by OOM killing a 
sibling or parent you could be taking away more memory from the exiting 
task; hopefully it won't be noticeable and the sibling or parent will 
quickly exit.

Perhaps instead of killing additional tasks, we should only make the 
exemption if a TIF_MEMDIE task is TASK_UNINTERRUPTIBLE during the 
select_bad_process() scan.  I haven't personally witnessed any blocking in 
the exit path of an OOM killed task that doesn't leave it in D state and 
prevents it from dying.

> This is the risk of suprious oom killing yes. You got to choose
> between a deadlock and risking a suprious oom killing. Even when you
> add your 60second timeout in the task_struct between each new TIF_MEMDIE
> bitflag set, you're still going to risk spurious oom killing...
> 

The 60-second (or whatever time limit) timeout would almost certainly 
always target tasks stuck in D state.  Those tasks will probably never 
exit if the timeout expires no matter how many times it is OOM killed.  So 
the best alternative is to then take TIF_MEMDIE away from that task, 
reduce its timeslice, and never select it again for OOM kill.

If you agree with me that an addition to struct task_struct to keep the 
jiffies of the time it received TIF_MEMDIE is beneficial then it will 
obsolete this patch.

> The schedule_timeout in the oom killer and in the VM that I have in my
> patchset combined with your very limited functionality of
> zone-oom-lock (limited because it's gone by the time out_of_memory
> returns and it currently can't take into account when the TIF_MEMDIE
> task actually exited) in practice didn't generate suprious kills in my
> testing. It may not be enough but it's a start...
> 

The zone-oom-lock wasn't intended to necessarily prevent subsequent OOM 
kills of tasks, it was intended to serialize the OOM killer so that 
multiple entrants will not be killing additional tasks when one would have 
sufficed.

It was made on a per-zone level instead of a global level, as your 
approach did, to support cpusets and memory policy OOM killings.  With a 
global approach these OOM kills would have taken longer because you were 
serializing globally and the OOM killer was dealing with a zonelist that 
wouldn't necessarily have alleviated OOM conditions in other zones.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
