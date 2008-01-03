Date: Thu, 3 Jan 2008 14:29:46 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 07 of 11] don't depend on PF_EXITING tasks to go away
Message-ID: <20080103132946.GS30939@v2.random>
References: <686a1129469a1bad9674.1199326153@v2.random> <alpine.DEB.0.9999.0801030140290.25018@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0801030140290.25018@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 01:52:26AM -0800, David Rientjes wrote:
> That's partially incorrect; it's possible that the PF_EXITING task does 
> have TIF_MEMDIE since the OOM killer synchronization does not guarantee 
> that a killed task has fully exited before a subsequent OOM killer 
> invocation occurs.

With an oom killer invocation normally PF_EXITING will be set after
TIF_MEMDIE.

Here we deal with the case of one task exiting because the C code
invokes exit(2) but TIF_MEMDIE isn't set. And then the system goes oom.

> So what's going to happen here is that either the PF_EXITING task is 
> current (the OOM-triggering task) and is immediately going to be chosen 
> for OOM kill or the OOM killer is going to become a no-op and wait for the 
> OOM condition to be alleviated in some other manner.

IIRC the system reached OOM after the PF_EXITING task invoked exit_mm
but before the task was reaped from the tasklist because the parent
couldn't yet run waitpid() (the parent is stuck in the global oom
condition). Like you said the oom killer become a noop and the system
crashed.

> We're unconcerned about the former because it will be chosen for OOM kill 
> and will receive the TIF_MEMDIE exemption.

Yes.

> The latter is more interesting and seems to be what you're targeting in 
> your changelog: exiting tasks that have encountered an OOM condition that 

Yes.

> blocks them from continuing.  But if that's the case, we still need to 
> free some memory from somewhere so the only natural thing to do is OOM 
> kill another task.

Yes we need to kill another task, the PF_EXITING task already run
exit_mm _before_ the oom condition triggered.

>  That's precisely what the current code is doing:  

Really the oom killer is currently doing this:

       if (p->flags & PF_EXITING) {
  	    if (p != current)
	         return ERR_PTR(-1UL);
	    chosen = p;
	    *ppoints = ULONG_MAX;
       }

This means if there's a PF_EXITING task that isn't the current task
(it can't be the current task because it's not runnable anymore by the
scheduler by time the system is oom, do_exit already scheduled), the
oom killer will forever try to kill that PF_EXITING task that can't
run and can't release any further memory because it quit by itself
_before_ the oom condition triggered. I seem to recall I reproduced
this with my current testcase...

> causing the OOM killer to become a no-op for the current case (the 
> already exiting task) and freeing memory by waiting for another system 
> OOM, which is guaranteed to happen.  That's sound logic since it doesn't 
> do any good to OOM kill an already exiting task.

depends if the PF_EXITING task has already run exit_mm or not. If it
didn't it does good. If it did it doesn't good.

> So my suggestion would be to allow the non-OOM-triggering candidate task 
> to be considered as a target instead of simply returning ERR_PTR(-1UL):
> 
> 	if (p->flags & PF_EXITING && p == current &&
> 	    !test_tsk_thread_flag(p, TIF_MEMDIE)) {
> 		chosen = p;
> 		**points = ULONG_MAX;
> 	}

Yes this is a workable option. In practice adding the above or not,
won't make difference 99% of the time. Removing the "return
ERR_PTR(-1UL)" is about not deadlocking 1% of the time. From my point
of view as long as mainline stops deadlocking and I can close bugzilla
I'm fine. I'm totally flexible about adding any wish like above ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
