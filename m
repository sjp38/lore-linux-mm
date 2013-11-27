Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id AE9E96B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 16:51:24 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so5634440yha.9
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 13:51:24 -0800 (PST)
Received: from mail-yh0-x22a.google.com (mail-yh0-x22a.google.com [2607:f8b0:4002:c01::22a])
        by mx.google.com with ESMTPS id s46si29254168yhd.70.2013.11.27.13.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 13:51:23 -0800 (PST)
Received: by mail-yh0-f42.google.com with SMTP id z6so5580083yhz.15
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 13:51:23 -0800 (PST)
Date: Wed, 27 Nov 2013 13:51:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131127163435.GA3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271343250.9222@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com> <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org> <20131118165110.GE32623@dhcp22.suse.cz> <20131122165100.GN3556@cmpxchg.org> <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

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

A process may indeed exit immediately after a different process was oom 
killed.  A process may also free memory immediately after a process was 
oom killed.

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
> accept that in rare situations the OOM kill was unnecessary.  So
> again, I don't see this patch is doing anything but blur the current
> line and make notification less predictable.  And, as someone else in
> this thread already said, it's a uservisible change in behavior and
> would break known tuning usecases.
> 

The patch is drawing the line at "the kernel can no longer do anything to 
free memory", and that's the line where userspace should be notified or a 
process killed by the kernel.  Giving current access to memory reserves in 
the oom killer is an optimization so that all reclaim is exhausted prior 
to declaring that they are necessary, the kernel still has the ability to 
allow that process to exit and free memory.  This is the same as the oom 
notifiers within the kernel that free memory from s390 and powerpc archs: 
the kernel still has the ability to free memory.  If you wish to be 
notified that you've simply reached the memcg limit, for whatever reason, 
you can monitor memory.failcnt or register a memory threshold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
