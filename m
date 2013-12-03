Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 695526B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 16:23:51 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id my13so6214369bkb.22
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 13:23:50 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ls2si2194552bkb.166.2013.12.03.13.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 13:23:50 -0800 (PST)
Date: Tue, 3 Dec 2013 16:23:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131203212338.GT3556@cmpxchg.org>
References: <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
 <20131203120454.GA12758@dhcp22.suse.cz>
 <20131203201713.GR3556@cmpxchg.org>
 <20131203210009.GA3764@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131203210009.GA3764@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, Dec 03, 2013 at 10:00:09PM +0100, Michal Hocko wrote:
> On Tue 03-12-13 15:17:13, Johannes Weiner wrote:
> > On Tue, Dec 03, 2013 at 01:04:54PM +0100, Michal Hocko wrote:
> > > On Mon 02-12-13 16:25:00, Johannes Weiner wrote:
> > > > On Mon, Dec 02, 2013 at 09:02:21PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > But we are not talking just about races here. What if the OOM is a
> > > > > result of an OOM action itself. E.g. a killed task faults a memory in
> > > > > while exiting and it hasn't freed its memory yet. Should we notify in
> > > > > such a case? What would an userspace OOM handler do (the in-kernel
> > > > > implementation has an advantage because it can check the tasks flags)?
> > > > 
> > > > We don't notify in such a case.  Every charge from a TIF_MEMDIE or
> > > > exiting task is bypassing the limit immediately.  Not even reclaim.
> > > 
> > > Not really. Assume a memcg is under OOM. A task is killed by
> > > userspace so we get into signal delivery code which clears
> > > fatal_signal_pending and the code goes on to exit but then it faults in.
> > > __mem_cgroup_try_charge will not see signal pending and TIF_MEMDIE is
> > > not set yet. OOM is still not resolved so we are back to square one.
> > 
> > Ah, that's a completely separate problem, though.  One issue I have
> > with these checks is that I never know which one are shortcuts and
> > micro optimizations and which one are functionally necessary.
> 
> That is why I asked for the changelog update to mention the fix as well
> (https://lkml.org/lkml/2013/11/18/161 resp.
> https://lkml.org/lkml/2013/11/18/142)
> 
> > > > > > So again, I don't see this patch is doing anything but blur the
> > > > > > current line and make notification less predictable. And, as someone
> > > > > > else in this thread already said, it's a uservisible change in
> > > > > > behavior and would break known tuning usecases.
> > > > > 
> > > > > I would like to understand how would such a tuning usecase work and how
> > > > > it would break with this change.
> > > > 
> > > > I would do test runs and with every run increase the size of the
> > > > workload until I get OOM notifications to know when the kernel has
> > > > been pushed beyond its limits and available memory + reclaim
> > > > capability can't keep up with the workload anymore.
> > > > 
> > > > Not informing me just because due to timing variance a random process
> > > > exits in the last moment would be flat out lying.  The machine is OOM.
> > > > Many reclaim cycles failing is a good predictor.  Last minute exit of
> > > > random task is not, it's happenstance and I don't want to rely on a
> > > > fluke like this to size my workload.
> > > 
> > > Such a metric would be inherently racy for the same reason. You simply
> > > cannot rely on not seeing OOMs because an exiting task managed to leave
> > > in time (after MEM_CGROUP_RECLAIM_RETRIES direct reclaim loops and
> > > before mem_cgroup_oom). Difference between in time and little bit too
> > > late is just too fragile to be useful IMO.
> > 
> > Are we saying the same thing?  Or did I misunderstand you?
> 
> yes we are and my point was that using such a metric doesn't make much
> sense. So arguing with reliability and possible regressions is a bit
> over-reaction. I was backing this patch because it has moved the check
> to a more appropriate place where it actually solves also another issue.
> 
> I was probably not clear enough about that.
> 
> > > > > Consider the above example. You would get 2 notification for the very
> > > > > same OOM condition.
> > > > > On the other hand if the encountered exiting task was just a race then
> > > > > we have two options basically. Either there are more tasks racing (and
> > > > > not all of them are exiting) or there is only one (all are exiting).
> > > > > We will not loose any notification in the first case because the flags
> > > > > are checked before mem_cgroup_oom_trylock and so one of tasks would lock
> > > > > and notify.
> > > > > The second case is more interesting. Userspace won't get notification
> > > > > but we also know that no action is required as the OOM will be resolved
> > > > > by itself. And now we should consider whether notification would do more
> > > > > good than harm. The tuning usecase would loose one event. Would such a
> > > > > rare situation skew the statistics so much? On the other hand a real OOM
> > > > > killer would do something which means something will be killed. I find
> > > > > the later much worse.
> > > > 
> > > > We already check in various places (sigh) for whether reclaim and
> > > > killing is still necessary.  What is the end game here?  An endless
> > > > loop right before the kill where we check if the kill is still
> > > > necessary?
> > > 
> > > The patch as is doesn't cover all the cases and ideally we should check
> > > that for OOM_SCAN_ABORT and later in oom_kill_process because they can
> > > back out as well if we want to have only-on-action notification. Such a
> > > solution would be too messy though.
> > 
> > There is never an only-on-action notification and there is no check to
> > cover all cases.  This is the fallacy I'm trying to point out.  All we
> > can do is pick a fairly predictable line and stick to it.
> 
> Yes, nothing will be 100% but drawing the line at the place where the
> kernel is going to _do_ something sounds like a quite a clear cut to
> me and a reasonable semantic. That something might be either killing
> something or putting somebody to sleep and wait for the userspace. That
> would be an ideal semantic IMHO. The code doesn't allow us to do so now
> unfortunately (without too much refactoring).
> 
> > > But as I've said. The primary reason I liked this change is because it
> > > solves the above mentioned OOM during exit issue and it also prevents
> > > from a pointless notification. I am perfectly fine with moving the
> > > check+set TIF_MEMDIE down so solve only the issue #1 and do not mess
> > > with notifications.
> > 
> > The notification is not pointless, we are OOM at the time we make the
> > decision.
> 
> We have clearly different opinions here. I do not consider temporal
> OOM conditions as significant enough.

As opposed to what, "permanent" OOM conditions? :-) I'm running out of
ways to phrase this...  The sampling window for OOM conditions is
completely arbitrary.  Right now it spans 5 reclaim cycles.  Adding a
last-second check for a random event right before the kill adds
nothing but noise.

> As the OOM itself is really hard to define and to be _agreed_ on I
> think we should be as practical as possible and provide the oom
> notification interface as comfortable to users as possible. And then
> we should balance cons and pros of notifying. I am still convinced
> that notifying less is better in general because I see OOM killer
> use cases.

If the sampling window is too small for you, then increase the number
of reclaim cycles as I proposed earlier.  It does exactly the same
thing but it's less invasive:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13b9d0f..6d308ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -67,7 +67,7 @@
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 EXPORT_SYMBOL(mem_cgroup_subsys);
 
-#define MEM_CGROUP_RECLAIM_RETRIES	5
+#define MEM_CGROUP_RECLAIM_RETRIES	6
 static struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #ifdef CONFIG_MEMCG_SWAP

Or just wait for every single task in the memcg to be stuck in the
charge path, then you know for sure that the OOM condition is
permanent.  Unless an external task kills one of them, of course...

> > > @@ -2266,6 +2266,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
> > >  		schedule();
> > >  		mem_cgroup_unmark_under_oom(memcg);
> > >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> > > +
> > > +		/* Userspace OOM handler cannot set TIF_MEMDIE to a target */
> > > +		if (memcg->oom_kill_disable) {
> > > +			if ((fatal_signal_pending(current) ||
> > > +						current->flags & PF_EXITING))
> > > +				set_thread_flag(TIF_MEMDIE);
> > > +		}
> > 
> > This is an entirely different change that I think makes sense.
> 
> OK, I will post the full patch after we settle with this one finally.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
