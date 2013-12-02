Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2D16B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:02:25 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so12504773wgg.15
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:02:24 -0800 (PST)
Received: from mail-ea0-x22d.google.com (mail-ea0-x22d.google.com [2a00:1450:4013:c01::22d])
        by mx.google.com with ESMTPS id t2si3400365wiz.3.2013.12.02.12.02.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 12:02:24 -0800 (PST)
Received: by mail-ea0-f173.google.com with SMTP id g15so9489623eak.32
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:02:23 -0800 (PST)
Date: Mon, 2 Dec 2013 21:02:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131202200221.GC5524@dhcp22.suse.cz>
References: <20131113233419.GJ707@cmpxchg.org>
 <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131127163435.GA3556@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 27-11-13 11:34:36, Johannes Weiner wrote:
> On Tue, Nov 26, 2013 at 04:53:47PM -0800, David Rientjes wrote:
> > On Fri, 22 Nov 2013, Johannes Weiner wrote:
> > 
> > > But userspace in all likeliness DOES need to take action.
> > > 
> > > Reclaim is a really long process.  If 5 times doing 12 priority cycles
> > > and scanning thousands of pages is not enough to reclaim a single
> > > page, what does that say about the health of the memcg?
> > > 
> > > But more importantly, OOM handling is just inherently racy.  A task
> > > might receive the kill signal a split second *after* userspace was
> > > notified.  Or a task may exit voluntarily a split second after a
> > > victim was chosen and killed.
> > > 
> > 
> > That's not true even today without the userspace oom handling proposal 
> > currently being discussed if you have a memcg oom handler attached to a 
> > parent memcg with access to more memory than an oom child memcg.  The oom 
> > handler can disable the child memcg's oom killer with memory.oom_control 
> > and implement its own policy to deal with any notification of oom.
> 
> I was never implying the kernel handler.  All the races exist with
> userspace handling as well.
> 
> > This patch is required to ensure that in such a scenario that the oom 
> > handler sitting in the parent memcg only wakes up when it's required to 
> > intervene.
> 
> A task could receive an unrelated kill between the OOM notification
> and going to sleep to wait for userspace OOM handling.  Or another
> task could exit voluntarily between the notification and waitqueue
> entry, which would again be short-cut by the oom_recover of the exit
> uncharges.
> 
> oom:                           other tasks:
> check signal/exiting
>                                could exit or get killed here
> mem_cgroup_oom_trylock()
>                                could exit or get killed here
> mem_cgroup_oom_notify()
>                                could exit or get killed here
> if (userspace_handler)
>   sleep()                      could exit or get killed here
> else
>   oom_kill()
>                                could exit or get killed here
> 
> It does not matter where your signal/exiting check is, OOM
> notification can never be race free because OOM is just an arbitrary
> line we draw.  We have no idea what all the tasks are up to and how
> close they are to releasing memory.  Even if we freeze the whole group
> to handle tasks, it does not change the fact that the userspace OOM
> handler might kill one task and after the unfreeze another task
> immediately exits voluntarily or got a kill signal a split second
> after it was frozen.
> 
> You can't fix this.  We just have to draw the line somewhere and
> accept that in rare situations the OOM kill was unnecessary.

But we are not talking just about races here. What if the OOM is a
result of an OOM action itself. E.g. a killed task faults a memory in
while exiting and it hasn't freed its memory yet. Should we notify in
such a case? What would an userspace OOM handler do (the in-kernel
implementation has an advantage because it can check the tasks flags)?

> So again, I don't see this patch is doing anything but blur the
> current line and make notification less predictable. And, as someone
> else in this thread already said, it's a uservisible change in
> behavior and would break known tuning usecases.

I would like to understand how would such a tuning usecase work and how
it would break with this change.

Consider the above example. You would get 2 notification for the very
same OOM condition.
On the other hand if the encountered exiting task was just a race then
we have two options basically. Either there are more tasks racing (and
not all of them are exiting) or there is only one (all are exiting).
We will not loose any notification in the first case because the flags
are checked before mem_cgroup_oom_trylock and so one of tasks would lock
and notify.
The second case is more interesting. Userspace won't get notification
but we also know that no action is required as the OOM will be resolved
by itself. And now we should consider whether notification would do more
good than harm. The tuning usecase would loose one event. Would such a
rare situation skew the statistics so much? On the other hand a real OOM
killer would do something which means something will be killed. I find
the later much worse.

So all in all. I do agree with you that this path will never be race
free and without pointless OOM actions. I also agree that drawing the
line is hard. But I am more inclined to prevent from notification when
we already know that _no action_ is required because IMHO the vast
majority of oom listeners are there to _do_ an action which is mostly
deadly.

Finally if this is too controversial then I would at least like to see
the same check introduced before we go to sleep for oom_kill_disable
case because that is a real bug.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
