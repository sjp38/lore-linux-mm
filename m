Date: Mon, 7 Jan 2008 19:37:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
In-Reply-To: <200801081425.31515.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.0.9999.0801071929300.29897@chino.kir.corp.google.com>
References: <504e981185254a12282d.1199326157@v2.random> <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0801071751320.13505@chino.kir.corp.google.com> <200801081425.31515.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@cpushare.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Nick Piggin wrote:

> The problem is the global reserve. Once you have a kernel that doesn't
> need this handwavy global reserve for forward progress, a lot of little
> problems go away.
> 

I'm specifically talking about TIF_MEMDIE here which gives access to that 
global reserve.  In OOM situations there is no easy way to guarantee that 
a task will have enough memory to exit, but that is exactly what is needed 
to alleviate the condition.  Additionally, it is not guaranteed that a 
task that has been OOM killed and given access to the global reserve will 
exit after it has exhausted that reserve in its entirety.  That's when the 
system deadlocks.

So giving access to the global reserve to multiple tasks that share memory 
in at least one of their zones for simultaneous OOM killings is not a 
complete solution.  There should be a timeout on tasks when they are OOM 
killed; if they cannot exit for the duration of that period, they lose 
access to the reserves and only then is another task selected.

> > It should be given to a single 
> > OOM-killed task that will alleviate the OOM condition for the task that
> > called out_of_memory().
> 
> It should be, but that task you OOM may be blocking on another one that
> is waiting for memory, for example.
> 

And after the timeout that I'm proposing it, or another suitable 
candidate, will be killed instead.  The dependencies are beyond the scope 
of the OOM killer badness scoring but without giving tasks a short but 
reasonable period to exit and then opting to kill another task there will 
always exist the potential for deadlock.

> > That's only possible with my proposal of adding
> >
> > 	unsigned long oom_kill_jiffies;
> >
> > to struct task_struct.  We can't get away with a system-wide jiffies
> > variable, nor can we get away with per-cgroup, per-cpuset, or
> > per-mempolicy variable.  The only way to clear such a variable is in the
> > exit path (by checking test_thread_flag(tsk, TIF_MEMDIE) in do_exit()) and
> > fails miserably if there are simultaneous but zone-disjoint OOMs
> > occurring.
> 
> Why not just have a global frequency limit on OOM events. Then the panic
> has this delay factored in...
> 

Because OOM killing is going to become more and more frequent with the 
introduction of the memory controller which uses it as a mechanism to 
enforce its policy.  And a global frequency limit does not work well for 
parallel cpuset, mempolicy, or memory controller OOM events.  That is why 
it is currently serialized by the triggering task's zonelist and not 
globally.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
