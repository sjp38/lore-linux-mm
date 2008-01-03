Date: Thu, 3 Jan 2008 14:06:57 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
Message-ID: <20080103130656.GR30939@v2.random>
References: <504e981185254a12282d.1199326157@v2.random> <alpine.DEB.0.9999.0801030152540.25018@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0801030152540.25018@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 01:55:35AM -0800, David Rientjes wrote:
> On Thu, 3 Jan 2008, Andrea Arcangeli wrote:
> 
> > Don't wait tif-memdie tasks forever because they may be stuck in some kernel
> > lock owned by some task that requires memory to exit the critical section.
> > 
> 
> This increases the possibility that tasks will be needlessly killed in OOM 
> conditions.  While the indefinite timeout is definitely not the ideal 

Yes, and doing so it avoids the deadlock.

> solution, it does have the advantage of preventing unnecessary kills.  The 
> OOM synchronization is good, but it's not _that_ good: it doesn't ensure 
> that the OOM killed task has fully exited before another invocation of the 
> OOM killer happens.
> 
> So I think we're moving in a direction of requiring OOM killer timeouts 
> and the only plausible way to do that is on a per-task level.  It would 
> require another unsigned long addition to struct task_struct but would 
> completely fix OOM killer deadlocks.

Yes. That can be added incrementally in a later patch, it's a new
logic. In the meantime the deadlock is gone.

In practice there's a sort of timeout already, the oom-killing task
will schedule_timeout(1) with the zone-oom-lock hold, and all other
tasks trying to free memory (except the TIF_MEMDIE one) will also
schedule_timeout(1) inside the VM code. That tends to prevent spurious
kills already but it's far from a guarantee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
