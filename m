Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 69F536B005C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 01:33:27 -0400 (EDT)
Date: Thu, 6 Jun 2013 01:33:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130606053315.GB9406@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 05, 2013 at 09:10:51PM -0700, David Rientjes wrote:
> On Wed, 5 Jun 2013, Johannes Weiner wrote:
> 
> > The memcg OOM handling is incredibly fragile because once a memcg goes
> > OOM, one task (kernel or userspace) is responsible for resolving the
> > situation.
> 
> Not sure what this means.  Are you referring to the case where the memcg 
> is disabled from oom killing and we're relying on a userspace handler and 
> it may be caught on the waitqueue itself?  Otherwise, are you referring to 
> the task as eventually being the only one that takes the hierarchy oom 
> lock and calls mem_cgroup_out_of_memory()?  I don't think you can make a 
> case for the latter since the one that calls mem_cgroup_out_of_memory() 
> should return and call memcg_wakeup_oom().  We obviously don't want to do 
> any memory allocations in this path.

If the killing task or one of the sleeping tasks is holding a lock
that the selected victim needs in order to exit no progress can be
made.

The report we had a few months ago was that a task held the i_mutex
when trying to charge a page cache page and then invoked the OOM
handler and looped on CHARGE_RETRY.  Meanwhile, the selected victim
was just entering truncate() and now stuck waiting for the i_mutex.

I'll add this scenario to the changelog, hopefully it will make the
rest a little clearer.

> > Every other task that gets caught trying to charge memory
> > gets stuck in a waitqueue while potentially holding various filesystem
> > and mm locks on which the OOM handling task may now deadlock.
> > 
> 
> What locks?  The oom killer quite extensively needs task_lock() but we 
> shouldn't be calling it in the case where we hold this since its a 
> spinlock and mem_cgroup_do_charge() never gets to the point of handling 
> the oom.
> 
> Again, are you referring only to a userspace handler here?

No.  The OOM path (does not matter if user task or kernel) is
currently entered from the charge context, which may hold filesystem
and mm locks (look who charges page cache pages e.g.) and they are not
released until the situation is resolved because the task either loops
inside __mem_cgroup_try_charge() on CHARGE_RETRY or is stuck in the
waitqueue.

And waiting for anybody else to make progress while holding mmap_sem,
i_mutex etc. is the problem.

> > Do two things:
> > 
> > 1. When OOMing in a system call (buffered IO and friends), invoke the
> >    OOM killer but just return -ENOMEM, never sleep.  Userspace should
> >    be able to handle this.
> > 
> 
> The sleep should never occur for any significant duration currently, the 
> current implementation ensures one process calls 
> mem_cgroup_out_of_memory() while all others sit on a waitqueue until that 
> process returns from the oom killer and then they all wakeup again so the 
> killed process may exit and all others can retry their allocations now 
> that something has been killed.  If that process hasn't exited yet, the 
> next process that locks the memcg oom hierarchy will see the killed 
> process with TIF_MEMDIE and the oom killer is deferred.  So this sleep is 
> very temporary already, I don't see why you're trying to make it faster 
> while another thread finds a candidate task, it works quite well already.

It's not the amount of time slept on average, it's that going to sleep
in this context may deadlock the killing or the killed task.  I don't
see where you read "making it faster", but I'm trying to make it just
slightly faster than a deadlock.

> > 2. When OOMing in a page fault and somebody else is handling the
> >    situation, do not sleep directly in the charging code.  Instead,
> >    remember the OOMing memcg in the task struct and then fully unwind
> >    the page fault stack first before going to sleep.
> > 
> 
> Are you trying to address a situation here where the memcg oom handler 
> takes too long to work?  We've quite extensively tried to improve that, 
> especially by reducing its dependency on tasklist_lock which is contended 
> from the writeside in the exit path and by only iterating processes that 
> are attached to that memcg hierarchy and not all processes on the system 
> like before.  I don't see the issue with scheduling other oom processes 
> while one is doing mem_cgroup_out_of_memory().  (I would if the oom killer 
> required things like mm->mmap_sem, but obviously it doesn't for reasons 
> not related to memcg.)

I really don't see where you read "performance optimization" in this
changelog, the very first paragraph mentions "very fragile" and "may
deadlock".

> > While reworking the OOM routine, also remove a needless OOM waitqueue
> > wakeup when invoking the killer.  Only uncharges and limit increases,
> > things that actually change the memory situation, should do wakeups.
> > 
> 
> It's not needless at all, it's vitally required!  The oom killed process 
> needs to be removed from the waitqueue and scheduled now with TIF_MEMDIE 
> that the memcg oom killer provided so the allocation succeeds in the page 
> allocator and memcg bypasses the charge so it can exit.

The OOM killer sets TIF_MEMDIE and then sends a fatal signal to the
victim.  That reliably wakes it up, doesn't it?

> Exactly what problem are you trying to address with this patch?  I don't 
> see any description of the user-visible effects or a specific xample of 
> the scenario you're trying to address here.

I'll add the example scenarios.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
