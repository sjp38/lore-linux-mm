Date: Thu, 3 Jan 2008 01:55:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
In-Reply-To: <504e981185254a12282d.1199326157@v2.random>
Message-ID: <alpine.DEB.0.9999.0801030152540.25018@chino.kir.corp.google.com>
References: <504e981185254a12282d.1199326157@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> Don't wait tif-memdie tasks forever because they may be stuck in some kernel
> lock owned by some task that requires memory to exit the critical section.
> 

This increases the possibility that tasks will be needlessly killed in OOM 
conditions.  While the indefinite timeout is definitely not the ideal 
solution, it does have the advantage of preventing unnecessary kills.  The 
OOM synchronization is good, but it's not _that_ good: it doesn't ensure 
that the OOM killed task has fully exited before another invocation of the 
OOM killer happens.

So I think we're moving in a direction of requiring OOM killer timeouts 
and the only plausible way to do that is on a per-task level.  It would 
require another unsigned long addition to struct task_struct but would 
completely fix OOM killer deadlocks.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
