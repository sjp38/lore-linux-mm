Date: Thu, 3 Jan 2008 20:54:33 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 04 of 11] avoid selecting already killed tasks
Message-ID: <20080103195433.GW30939@v2.random>
References: <4cf8805b5695a8a3fb7c.1199326150@v2.random> <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com> <20080103134137.GT30939@v2.random> <alpine.DEB.0.9999.0801031036110.27032@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0801031036110.27032@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 10:47:33AM -0800, David Rientjes wrote:
> Traditionally we've only allowed one thread in the entire system to have 
> TIF_MEMDIE at a time because as you give access to memory reserves to more 
> threads it becomes less of a help to exiting tasks.  So by OOM killing a 
> sibling or parent you could be taking away more memory from the exiting 
> task; hopefully it won't be noticeable and the sibling or parent will 
> quickly exit.

In theory no memory allocation should be required in do_exit.... in
practice sometime it can happen, but the PF_MEMALLOC pool is available
and can be emptied way before the first task has been killed, and the
potential eaters of the PF_MEMALLOC pool are much heavier users than
the do_exit path, so I doubt worrying about the memory reserves by the
time TIF_MEMDIE has been set is a valid concern.

> Perhaps instead of killing additional tasks, we should only make the 
> exemption if a TIF_MEMDIE task is TASK_UNINTERRUPTIBLE during the 
> select_bad_process() scan.  I haven't personally witnessed any blocking in 
> the exit path of an OOM killed task that doesn't leave it in D state and 
> prevents it from dying.

Initially I did this. But there are places where the task is
INTERRUPTIBLE too (like the ones I introduced). I felt it a bit weak.

> The 60-second (or whatever time limit) timeout would almost certainly 
> always target tasks stuck in D state.  Those tasks will probably never 

yes.

> exit if the timeout expires no matter how many times it is OOM killed.  So 

yes.

> the best alternative is to then take TIF_MEMDIE away from that task, 
> reduce its timeslice, and never select it again for OOM kill.

The TIF_MEMDIE undoing isn't a big deal. Sigkilling undoing is more
interesting.

> If you agree with me that an addition to struct task_struct to keep the 
> jiffies of the time it received TIF_MEMDIE is beneficial then it will 
> obsolete this patch.

I tried to prioritize and reduce and simplify the amount of stuff to
push to the minimum to be stable, but certainly I'd like to take the
more complex approach too, yet I'd keep it at the end to keep the
priority high on preventing the crash with small changes. I was being
more complex originally with a global timeout, still simpler than your
per-task timeout, and yet it wasn't merged as style changes
to such code bitrotten the patchset I guess.

> The zone-oom-lock wasn't intended to necessarily prevent subsequent OOM 
> kills of tasks, it was intended to serialize the OOM killer so that 
> multiple entrants will not be killing additional tasks when one would have 
> sufficed.

I know. I introduced the semaphore myself for this reason. But I also
had additional feedback coming from do_exit which is missing now...

> It was made on a per-zone level instead of a global level, as your 
> approach did, to support cpusets and memory policy OOM killings.  With a 
> global approach these OOM kills would have taken longer because you were 
> serializing globally and the OOM killer was dealing with a zonelist that 
> wouldn't necessarily have alleviated OOM conditions in other zones.

I know, scaling oom killing in parallel in numa is nicer but in
practice oom is rare and should never happen... so my global approach
wasn't that different ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
