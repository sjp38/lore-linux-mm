Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f79.google.com (mail-vb0-f79.google.com [209.85.212.79])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2456B0035
	for <linux-mm@kvack.org>; Sat, 16 Nov 2013 09:44:16 -0500 (EST)
Received: by mail-vb0-f79.google.com with SMTP id o19so4364vbm.2
        for <linux-mm@kvack.org>; Sat, 16 Nov 2013 06:44:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.202])
        by mx.google.com with SMTP id m9si1608214pba.23.2013.11.13.16.00.52
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 16:00:54 -0800 (PST)
Date: Wed, 13 Nov 2013 19:00:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom killed
Message-ID: <20131114000043.GK707@cmpxchg.org>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
 <20131113152412.GH707@cmpxchg.org>
 <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 13, 2013 at 02:16:04PM -0800, David Rientjes wrote:
> On Wed, 13 Nov 2013, Johannes Weiner wrote:
> 
> > > The oom killer is only invoked when reclaim has already failed and it
> > > only kills processes if the victim is also oom.  In other words, the oom
> > > killer does not select victims when a process tries to allocate from a
> > > disjoint cpuset or allocate DMA memory, for example.
> > > 
> > > Therefore, it's pointless for an oom killed process to continue
> > > attempting to reclaim memory in a loop when it has been granted access to
> > > memory reserves.  It can simply return to the page allocator and allocate
> > > memory.
> > 
> > On the other hand, finishing reclaim of 32 pages should not be a
> > problem.
> > 
> 
> The reclaim will fail, the only reason current has TIF_MEMDIE set is 
> because reclaim has completely failed.

...for somebody else.

> > > If there is a very large number of processes trying to reclaim memory,
> > > the cond_resched() in shrink_slab() becomes troublesome since it always
> > > forces a schedule to other processes also trying to reclaim memory.
> > > Compounded by many reclaim loops, it is possible for a process to sit in
> > > do_try_to_free_pages() for a very long time when reclaim is pointless and
> > > it could allocate if it just returned to the page allocator.
> > 
> > "Very large number of processes"
> > 
> > "sit in do_try_to_free_pages() for a very long time"
> > 
> > Can you quantify this a bit more?
> > 
> 
> I have seen kernel logs where ~700 processes are stuck in direct reclaim 
> simultaneously or scanning the tasklist in the oom killer only to defer 
> because it finds a process that has already been oom killed as is stuck in 
> do_try_to_free_pages() making very slow progress because of the number of 
> processes trying to reclaim.
>
> I haven't quantified how long the oom killed process sits in 
> do_try_to_free_pages() as a result of needlessly looping trying to reclaim 
> memory that will ultimately fail.
> 
> When the kernel oom kills something in a system oom condition, we hope 
> that it will exit quickly because otherwise every other memory allocator 
> comes to a grinding halt for as long as it takes to free memory.
> 
> > And how common are OOM kills on your setups that you need to optimize
> > them on this level?
> > 
> 
> Very common, the sum of our top-level memcg hardlimits exceeds the amount 
> of memory on the system and we very frequently encounter system conditions 
> as a regular event.
> 
> > It sounds like your problem could be solved by having cond_resched()
> > not schedule away from TIF_MEMDIE processes, which would be much
> > preferable to oom-killed checks in random places.
> > 
> 
> I don't know of any other "random places" other than when the oom killed 
> process is sitting in reclaim before it is selected as the victim.  Once 
> it returns to the page allocator, it will immediately allocate and then be 
> able to handle its pending SIGKILL.  The one spot identified where it is 
> absolutely pointless to spin is in reclaim since it is virtually 
> guaranteed to fail.  This patch fixes that issue.

No, this applies to every other operation that does not immediately
lead to the task exiting or which creates more system load.  Readahead
would be another example.  They're all pointless and you could do
without all of them at this point, but I'm not okay with putting these
checks in random places that happen to bother you right now.  It's not
a proper solution to the problem.

Is it a good idea to let ~700 processes simultaneously go into direct
global reclaim?

The victim aborting reclaim still leaves you with ~699 processes
spinning in reclaim that should instead just retry the allocation as
well.  What about them?

The situation your setups seem to get in frequently is bananas, don't
micro optimize this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
