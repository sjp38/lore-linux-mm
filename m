Date: Thu, 3 Jan 2008 12:49:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 11] avoid selecting already killed tasks
In-Reply-To: <20080103195433.GW30939@v2.random>
Message-ID: <alpine.DEB.0.9999.0801031242430.18054@chino.kir.corp.google.com>
References: <4cf8805b5695a8a3fb7c.1199326150@v2.random> <alpine.DEB.0.9999.0801030134130.25018@chino.kir.corp.google.com> <20080103134137.GT30939@v2.random> <alpine.DEB.0.9999.0801031036110.27032@chino.kir.corp.google.com>
 <20080103195433.GW30939@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> In theory no memory allocation should be required in do_exit.... in
> practice sometime it can happen, but the PF_MEMALLOC pool is available
> and can be emptied way before the first task has been killed, and the
> potential eaters of the PF_MEMALLOC pool are much heavier users than
> the do_exit path, so I doubt worrying about the memory reserves by the
> time TIF_MEMDIE has been set is a valid concern.
> 

Ok.

> > the best alternative is to then take TIF_MEMDIE away from that task, 
> > reduce its timeslice, and never select it again for OOM kill.
> 
> The TIF_MEMDIE undoing isn't a big deal. Sigkilling undoing is more
> interesting.
> 

Well, that doesn't matter either if the task is stuck in D state forever.  
I was thinking that reducing the timeslice to 1 would be beneficial, 
however, for the remainder of the system's uptime since the task will have 
received the HZ timeslice when killed by the OOM killer.

> I tried to prioritize and reduce and simplify the amount of stuff to
> push to the minimum to be stable, but certainly I'd like to take the
> more complex approach too, yet I'd keep it at the end to keep the
> priority high on preventing the crash with small changes. I was being
> more complex originally with a global timeout, still simpler than your
> per-task timeout, and yet it wasn't merged as style changes
> to such code bitrotten the patchset I guess.
> 

Ok.

The global timeout would require the jiffies to be stored when the SIGKILL 
is issued and cleared in the exit path with a test_tsk_thread_flag(p, 
TIF_MEMDIE) check.  Unfortunately that doesn't work because, as you said, 
it is possible for more than one thread to have TIF_MEMDIE.  So there 
would be no way to catch tasks stuck in D state that have been OOM killed 
to be exempted from making the entire OOM killer a no-op.

> > It was made on a per-zone level instead of a global level, as your 
> > approach did, to support cpusets and memory policy OOM killings.  With a 
> > global approach these OOM kills would have taken longer because you were 
> > serializing globally and the OOM killer was dealing with a zonelist that 
> > wouldn't necessarily have alleviated OOM conditions in other zones.
> 
> I know, scaling oom killing in parallel in numa is nicer but in
> practice oom is rare and should never happen... so my global approach
> wasn't that different ;)
> 

It's becoming much more popular since the memory controller work that is 
based on cgroups uses OOM killing as a mechanism, in part, for enforcing 
its policy.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
