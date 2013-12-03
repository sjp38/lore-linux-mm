Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8182B6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 07:05:00 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so419931eek.15
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 04:05:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si2733198eeo.235.2013.12.03.04.04.56
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 04:04:56 -0800 (PST)
Date: Tue, 3 Dec 2013 13:04:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131203120454.GA12758@dhcp22.suse.cz>
References: <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131202212500.GN22729@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 02-12-13 16:25:00, Johannes Weiner wrote:
> On Mon, Dec 02, 2013 at 09:02:21PM +0100, Michal Hocko wrote:
[...]
> > But we are not talking just about races here. What if the OOM is a
> > result of an OOM action itself. E.g. a killed task faults a memory in
> > while exiting and it hasn't freed its memory yet. Should we notify in
> > such a case? What would an userspace OOM handler do (the in-kernel
> > implementation has an advantage because it can check the tasks flags)?
> 
> We don't notify in such a case.  Every charge from a TIF_MEMDIE or
> exiting task is bypassing the limit immediately.  Not even reclaim.

Not really. Assume a memcg is under OOM. A task is killed by
userspace so we get into signal delivery code which clears
fatal_signal_pending and the code goes on to exit but then it faults in.
__mem_cgroup_try_charge will not see signal pending and TIF_MEMDIE is
not set yet. OOM is still not resolved so we are back to square one.
 
> > > So again, I don't see this patch is doing anything but blur the
> > > current line and make notification less predictable. And, as someone
> > > else in this thread already said, it's a uservisible change in
> > > behavior and would break known tuning usecases.
> > 
> > I would like to understand how would such a tuning usecase work and how
> > it would break with this change.
> 
> I would do test runs and with every run increase the size of the
> workload until I get OOM notifications to know when the kernel has
> been pushed beyond its limits and available memory + reclaim
> capability can't keep up with the workload anymore.
> 
> Not informing me just because due to timing variance a random process
> exits in the last moment would be flat out lying.  The machine is OOM.
> Many reclaim cycles failing is a good predictor.  Last minute exit of
> random task is not, it's happenstance and I don't want to rely on a
> fluke like this to size my workload.

Such a metric would be inherently racy for the same reason. You simply
cannot rely on not seeing OOMs because an exiting task managed to leave
in time (after MEM_CGROUP_RECLAIM_RETRIES direct reclaim loops and
before mem_cgroup_oom). Difference between in time and little bit too
late is just too fragile to be useful IMO.

> > Consider the above example. You would get 2 notification for the very
> > same OOM condition.
> > On the other hand if the encountered exiting task was just a race then
> > we have two options basically. Either there are more tasks racing (and
> > not all of them are exiting) or there is only one (all are exiting).
> > We will not loose any notification in the first case because the flags
> > are checked before mem_cgroup_oom_trylock and so one of tasks would lock
> > and notify.
> > The second case is more interesting. Userspace won't get notification
> > but we also know that no action is required as the OOM will be resolved
> > by itself. And now we should consider whether notification would do more
> > good than harm. The tuning usecase would loose one event. Would such a
> > rare situation skew the statistics so much? On the other hand a real OOM
> > killer would do something which means something will be killed. I find
> > the later much worse.
> 
> We already check in various places (sigh) for whether reclaim and
> killing is still necessary.  What is the end game here?  An endless
> loop right before the kill where we check if the kill is still
> necessary?

The patch as is doesn't cover all the cases and ideally we should check
that for OOM_SCAN_ABORT and later in oom_kill_process because they can
back out as well if we want to have only-on-action notification. Such a
solution would be too messy though.

But as I've said. The primary reason I liked this change is because it
solves the above mentioned OOM during exit issue and it also prevents
from a pointless notification. I am perfectly fine with moving the
check+set TIF_MEMDIE down so solve only the issue #1 and do not mess
with notifications.

> You're not fixing this problem, so why make the notifications less
> reliable?

I am still not seeing why it is less reliable. The notification is
inherently racy so you cannot rely on any simple metrics based on their
count (at least not in general).

> > So all in all. I do agree with you that this path will never be race
> > free and without pointless OOM actions. I also agree that drawing the
> > line is hard. But I am more inclined to prevent from notification when
> > we already know that _no action_ is required because IMHO the vast
> > majority of oom listeners are there to _do_ an action which is mostly
> > deadly.
> 
> If you want to push the machine so hard that active measures like
> reclaim can't keep up and you rely on stupid timing like this to save
> your sorry butt, then you'll just have to live with the
> unpredictability of it.  You're going to eat kills that might have
> been avoided last minute either way.  It's no excuse to plaster the MM
> with TIF_MEMDIE checks and last-minute cgroup margin checks in the
> weirdest locations.

Yes I do not agree with putting TIF_MEMDIE checks all over the place and
we should reduce their number to minimum. It is fair to say that the
patch didn't add a new check. It just has moved it to cover both
in-kernel and user space oom paths. That was a bonus I liked. To be
honest I do not see the notification side effect as a big deal as those
are racy anyway and I would rather see fewer of them than more
(especially when it is clear that nothing is to be done).

> Again, how likely is it anyway that the kill was truly skipped and not
> just deferred?  Reclaim failing is a good indicator that you're in
> trouble, a random task exiting in an ongoing workload does not say
> much.  The machine could still be in trouble, so you just deferred the
> inevitable, you didn't really avoid a kill.
> 
> At this point we are talking about OOM kill frequency and statistical
> probability during apparently normal operations.  The OOM killer was
> never written for that, it was supposed to be a last minute resort
> that should not occur during normal operations and only if all SANE
> measures to avoid it have failed.  99% of all users have no interest
> in these micro-optimizations and we shouldn't clutter the code and
> have unpredictable behavior without even a trace of data to show that
> this is anything more than a placebo measure for one use case.

OK, as it seems that the notification part is too controversial, how
would you like the following? It reverts the notification part and still
solves the fault on exit path. I will prepare the full patch with the
changelog if this looks reasonable:
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 28c9221b74ea..f44fe7e65a98 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1783,6 +1783,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
 
+	/*
+	 * If current has a pending SIGKILL or is exiting, then automatically
+	 * select it.  The goal is to allow it to allocate so that it may
+	 * quickly exit and free its memory.
+	 */
+	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
+		set_thread_flag(TIF_MEMDIE);
+		goto cleanup;
+	}
+
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
 	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
@@ -2233,16 +2243,6 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	if (!handle)
 		goto cleanup;
 
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-		set_thread_flag(TIF_MEMDIE);
-		goto cleanup;
-	}
-
 	owait.memcg = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
@@ -2266,6 +2266,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
 		schedule();
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
+
+		/* Userspace OOM handler cannot set TIF_MEMDIE to a target */
+		if (memcg->oom_kill_disable) {
+			if ((fatal_signal_pending(current) ||
+						current->flags & PF_EXITING))
+				set_thread_flag(TIF_MEMDIE);
+		}
 	}
 
 	if (locked) {

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
