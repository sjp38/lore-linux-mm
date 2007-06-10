Date: Sun, 10 Jun 2007 20:17:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-ID: <20070610181700.GC7443@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466C36AE.3000101@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 10, 2007 at 01:36:46PM -0400, Rik van Riel wrote:
> Andrea Arcangeli wrote:
> 
> >-	else
> >+	nr_inactive = zone_page_state(zone, NR_INACTIVE) >> priority;
> >+	if (nr_inactive < sc->swap_cluster_max)
> > 		nr_inactive = 0;
> 
> This is a problem.
> 
> On workloads with lots of anonymous memory, for example
> running a very large JVM or simply stressing the system
> with AIM7, the inactive list can be very small.
> 
> If dozens (or even hundreds) of tasks get into the
> pageout code simultaneously, they will all spend a lot
> of time moving pages from the active to the inactive
> list, but they will not even try to free any of the
> (few) inactive pages the system has!
> 
> We have observed systems in stress tests that spent
> well over 10 minutes in shrink_active_list before
> the first call to shrink_inactive_list was made.
> 
> Your code looks like it could exacerbate that situation,
> by not having zone->nr_scan_inactive increment between
> calls.

If all tasks spend 10 minutes in shrink_active_list before the first
call to shrink_inactive_list that could mean you hit the race that I'm
just trying to fix with this very patch. (i.e. nr_*active going
totally huge because of the race triggering, and trashing over the few
pages left in the *active_list until the artificially boosted
nr_*active finally goes down to zero in all tasks that read it at the
unlucky time when it got huge) So my patch may actually fix your
situation completely if your trouble was nr_scan_active becoming huge
for no good reason, just because many tasks entered the VM at the same
time on big-SMP systems. Did you monitor the real sizes of the active
lists during those 10 min and compared it to the nr_active stored in
the stack?

Normally if the highest priority passes only calls into
shrink_active_list that's because the two lists needs rebalancing. But
I fail to see how it could ever take 10min for the first
shrink_inactive_list to trigger with my patch applied, while if it
happens in current vanilla that could be the race triggering, or
anyway something unrelated is going wrong in the VM.

Overall this code seems quite flakey in its current "racy" form, so I
doubt it can be allowed to live as-is. Infact even if we fix the race
with a slow-shared-lock in a fast path or if we only make sure not to
avoid exacerbate your situation with something a simple and lock-less
as "nr_active = min(sizeof_active_list, nr_scan_active)", I think it
would still wrong to do more work in the current tasks, if we've other
tasks helping us at the same time. We should do nothing more, nothing
less. So I think if we want those counters to avoid restarting from
zero at each priority step (what I understand is your worry), those
counters should be in the stack, task-local. That will still take into
account the previously not scanned "nr_inactive" value.

Not sure what's best. I've the feeling that introducing a task-local
*nr_active *nr_inactive counter shared by all priority steps, won't
move the VM needle much, but I sure wouldn't be against it. It will
change the balancing to be more fair, but in practice I don't expect
huge differences, there are only 12 steps anyway, very quickly the
inactive list should be shrunk even if the active list is huge.

I'm only generally against the current per-zone global and racy
approach without limits, so potentially exacerbating your situation
when nr_active becomes very huge despite the active list being very
small.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
