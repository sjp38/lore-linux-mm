Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 367776B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:25:11 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so5602292bkb.26
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:25:10 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yv6si19161434bkb.169.2013.12.02.13.25.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 13:25:09 -0800 (PST)
Date: Mon, 2 Dec 2013 16:25:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131202212500.GN22729@cmpxchg.org>
References: <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131202200221.GC5524@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Dec 02, 2013 at 09:02:21PM +0100, Michal Hocko wrote:
> On Wed 27-11-13 11:34:36, Johannes Weiner wrote:
> > On Tue, Nov 26, 2013 at 04:53:47PM -0800, David Rientjes wrote:
> > > On Fri, 22 Nov 2013, Johannes Weiner wrote:
> > > 
> > > > But userspace in all likeliness DOES need to take action.
> > > > 
> > > > Reclaim is a really long process.  If 5 times doing 12 priority cycles
> > > > and scanning thousands of pages is not enough to reclaim a single
> > > > page, what does that say about the health of the memcg?
> > > > 
> > > > But more importantly, OOM handling is just inherently racy.  A task
> > > > might receive the kill signal a split second *after* userspace was
> > > > notified.  Or a task may exit voluntarily a split second after a
> > > > victim was chosen and killed.
> > > > 
> > > 
> > > That's not true even today without the userspace oom handling proposal 
> > > currently being discussed if you have a memcg oom handler attached to a 
> > > parent memcg with access to more memory than an oom child memcg.  The oom 
> > > handler can disable the child memcg's oom killer with memory.oom_control 
> > > and implement its own policy to deal with any notification of oom.
> > 
> > I was never implying the kernel handler.  All the races exist with
> > userspace handling as well.
> > 
> > > This patch is required to ensure that in such a scenario that the oom 
> > > handler sitting in the parent memcg only wakes up when it's required to 
> > > intervene.
> > 
> > A task could receive an unrelated kill between the OOM notification
> > and going to sleep to wait for userspace OOM handling.  Or another
> > task could exit voluntarily between the notification and waitqueue
> > entry, which would again be short-cut by the oom_recover of the exit
> > uncharges.
> > 
> > oom:                           other tasks:
> > check signal/exiting
> >                                could exit or get killed here
> > mem_cgroup_oom_trylock()
> >                                could exit or get killed here
> > mem_cgroup_oom_notify()
> >                                could exit or get killed here
> > if (userspace_handler)
> >   sleep()                      could exit or get killed here
> > else
> >   oom_kill()
> >                                could exit or get killed here
> > 
> > It does not matter where your signal/exiting check is, OOM
> > notification can never be race free because OOM is just an arbitrary
> > line we draw.  We have no idea what all the tasks are up to and how
> > close they are to releasing memory.  Even if we freeze the whole group
> > to handle tasks, it does not change the fact that the userspace OOM
> > handler might kill one task and after the unfreeze another task
> > immediately exits voluntarily or got a kill signal a split second
> > after it was frozen.
> > 
> > You can't fix this.  We just have to draw the line somewhere and
> > accept that in rare situations the OOM kill was unnecessary.
> 
> But we are not talking just about races here. What if the OOM is a
> result of an OOM action itself. E.g. a killed task faults a memory in
> while exiting and it hasn't freed its memory yet. Should we notify in
> such a case? What would an userspace OOM handler do (the in-kernel
> implementation has an advantage because it can check the tasks flags)?

We don't notify in such a case.  Every charge from a TIF_MEMDIE or
exiting task is bypassing the limit immediately.  Not even reclaim.

> > So again, I don't see this patch is doing anything but blur the
> > current line and make notification less predictable. And, as someone
> > else in this thread already said, it's a uservisible change in
> > behavior and would break known tuning usecases.
> 
> I would like to understand how would such a tuning usecase work and how
> it would break with this change.

I would do test runs and with every run increase the size of the
workload until I get OOM notifications to know when the kernel has
been pushed beyond its limits and available memory + reclaim
capability can't keep up with the workload anymore.

Not informing me just because due to timing variance a random process
exits in the last moment would be flat out lying.  The machine is OOM.
Many reclaim cycles failing is a good predictor.  Last minute exit of
random task is not, it's happenstance and I don't want to rely on a
fluke like this to size my workload.

> Consider the above example. You would get 2 notification for the very
> same OOM condition.
> On the other hand if the encountered exiting task was just a race then
> we have two options basically. Either there are more tasks racing (and
> not all of them are exiting) or there is only one (all are exiting).
> We will not loose any notification in the first case because the flags
> are checked before mem_cgroup_oom_trylock and so one of tasks would lock
> and notify.
> The second case is more interesting. Userspace won't get notification
> but we also know that no action is required as the OOM will be resolved
> by itself. And now we should consider whether notification would do more
> good than harm. The tuning usecase would loose one event. Would such a
> rare situation skew the statistics so much? On the other hand a real OOM
> killer would do something which means something will be killed. I find
> the later much worse.

We already check in various places (sigh) for whether reclaim and
killing is still necessary.  What is the end game here?  An endless
loop right before the kill where we check if the kill is still
necessary?

You're not fixing this problem, so why make the notifications less
reliable?

> So all in all. I do agree with you that this path will never be race
> free and without pointless OOM actions. I also agree that drawing the
> line is hard. But I am more inclined to prevent from notification when
> we already know that _no action_ is required because IMHO the vast
> majority of oom listeners are there to _do_ an action which is mostly
> deadly.

If you want to push the machine so hard that active measures like
reclaim can't keep up and you rely on stupid timing like this to save
your sorry butt, then you'll just have to live with the
unpredictability of it.  You're going to eat kills that might have
been avoided last minute either way.  It's no excuse to plaster the MM
with TIF_MEMDIE checks and last-minute cgroup margin checks in the
weirdest locations.

Again, how likely is it anyway that the kill was truly skipped and not
just deferred?  Reclaim failing is a good indicator that you're in
trouble, a random task exiting in an ongoing workload does not say
much.  The machine could still be in trouble, so you just deferred the
inevitable, you didn't really avoid a kill.

At this point we are talking about OOM kill frequency and statistical
probability during apparently normal operations.  The OOM killer was
never written for that, it was supposed to be a last minute resort
that should not occur during normal operations and only if all SANE
measures to avoid it have failed.  99% of all users have no interest
in these micro-optimizations and we shouldn't clutter the code and
have unpredictable behavior without even a trace of data to show that
this is anything more than a placebo measure for one use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
