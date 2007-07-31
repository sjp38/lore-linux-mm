Date: Wed, 1 Aug 2007 01:23:06 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: make swappiness safer to use
Message-ID: <20070731232306.GY6910@v2.random>
References: <20070731215228.GU6910@v2.random> <20070731160943.30e9c13a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731160943.30e9c13a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 31, 2007 at 04:09:43PM -0700, Andrew Morton wrote:
> On Tue, 31 Jul 2007 23:52:28 +0200
> Andrea Arcangeli <andrea@suse.de> wrote:
> 
> > I think the prev_priority can also be nuked since it wastes 4 bytes
> > per zone (that would be an incremental patch but I wait the
> > nr_scan_[in]active to be nuked first for similar reasons). Clearly
> > somebody at some point noticed how broken that thing was and they had
> > to add min(priority, prev_priority) to give it some reliability, but
> > they didn't go the last mile to nuke prev_priority too. Calculating
> > distress only in function of not-racy priority is correct and sure
> > more than enough without having to add randomness into the equation.
> 
> I don't recall seeing any such patch and I suspect it'd cause problems
> anyway.
> 
> If we were to base swap_tendency purely on sc->priority then the VM would
> incorrectly fail to deactivate mapped pages until the scanning had reached
> a sufficiently high (ie: low) scanning priority.
> 
> The net effect would be that each time some process runs
> shrink_active_list(), some pages would be incorrectly retained on the
> active list and after a while, the code wold start moving mapped pages down
> to the inactive list.
> 
> In fact, I think that was (effectively) the behaviour which we had in
> there, and it caused problems with some worklaod which Martin was looking
> at and things got better when we fixed it.
> 
> 
> Anyway, we can say more if we see the patch (or, more accurately, the
> analysis which comes with that patch).

My reasoning for prev_priority not being such a great feature is that
between the two, sc->priority is critically more important because its
being set for the current run, prev_priority is set later (in origin
only prev_priority was used as failsafe for the swappiness logic,
these days sc->priority is being mixed too because clearly
prev_priority alone was not enough). But my whole dislike for those
prev_* thinks is that they're all smp racey. So your beloved
prev_priority will go back to 12 if a new try_to_free_pages runs with
a different gfpmask and/or different order of allocation, screwing the
other task in the other CPU that is having such an hard time to find
unmapped pages to free because it has a strictier gfpmask (perhaps not
allowed to eat into dcache/icache) or bigger order (perhaps even
looping nearly forever thanks to the order <= PAGE_ALLOC_COSTLY_ORDER
check). So I've an hard time to appreciate the prev_priority thing,
because like the nr_scan_[in]active it's imperfect.

Comments like those also shows the whole imperfection:

	 /* Now that we've scanned all the zones at this priority level, note
	  * that level within the zone so that the next thread

that's a lie, I mean there's no such thing as next thread, all threads
may be running in parallel in multiple cpus, or they may be context
switching. The comment would be remotely correct if there was a big
global semaphore around the vm, which would never happen.

It's really the same category of the nr_scan_[in]active, and my
dislike for those things is exactly the same and motivated by mostly
the same reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
