Date: Thu, 3 Jan 2008 01:52:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 07 of 11] don't depend on PF_EXITING tasks to go away
In-Reply-To: <686a1129469a1bad9674.1199326153@v2.random>
Message-ID: <alpine.DEB.0.9999.0801030140290.25018@chino.kir.corp.google.com>
References: <686a1129469a1bad9674.1199326153@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> A PF_EXITING task don't have TIF_MEMDIE set so it might get stuck in
> memory allocations without access to the PF_MEMALLOC pool (said that
> ideally do_exit would better not require memory allocations, especially
> not before calling exit_mm). The same way we raise its privilege to
> TIF_MEMDIE if it's the current task, we should do it even if it's not
> the current task to speedup oom killing.
> 

That's partially incorrect; it's possible that the PF_EXITING task does 
have TIF_MEMDIE since the OOM killer synchronization does not guarantee 
that a killed task has fully exited before a subsequent OOM killer 
invocation occurs.

So what's going to happen here is that either the PF_EXITING task is 
current (the OOM-triggering task) and is immediately going to be chosen 
for OOM kill or the OOM killer is going to become a no-op and wait for the 
OOM condition to be alleviated in some other manner.

We're unconcerned about the former because it will be chosen for OOM kill 
and will receive the TIF_MEMDIE exemption.

The latter is more interesting and seems to be what you're targeting in 
your changelog: exiting tasks that have encountered an OOM condition that 
blocks them from continuing.  But if that's the case, we still need to 
free some memory from somewhere so the only natural thing to do is OOM 
kill another task.  That's precisely what the current code is doing:  
causing the OOM killer to become a no-op for the current case (the 
already exiting task) and freeing memory by waiting for another system 
OOM, which is guaranteed to happen.  That's sound logic since it doesn't 
do any good to OOM kill an already exiting task.

So my suggestion would be to allow the non-OOM-triggering candidate task 
to be considered as a target instead of simply returning ERR_PTR(-1UL):

	if (p->flags & PF_EXITING && p == current &&
	    !test_tsk_thread_flag(p, TIF_MEMDIE)) {
		chosen = p;
		**points = ULONG_MAX;
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
