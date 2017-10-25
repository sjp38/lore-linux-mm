Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93AE36B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:07:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so17117779pga.5
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 06:07:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t19si1583312plo.425.2017.10.25.06.07.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 06:07:41 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
	<201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
	<20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
	<201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
	<20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
In-Reply-To: <20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
Message-Id: <201710252115.JII86453.tFFSLHQOOOVMJF@I-love.SAKURA.ne.jp>
Date: Wed, 25 Oct 2017 21:15:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Wed 25-10-17 19:48:09, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > The OOM killer is the last hand break. At the time you hit the OOM
> > > condition your system is usually hard to use anyway. And that is why I
> > > do care to make this path deadlock free. I have mentioned multiple times
> > > that I find real life triggers much more important than artificial DoS
> > > like workloads which make your system unsuable long before you hit OOM
> > > killer.
> > 
> > Unable to invoke the OOM killer (i.e. OOM lockup) is worse than hand break injury.
> > 
> > If you do care to make this path deadlock free, you had better stop depending on
> > mutex_trylock(&oom_lock). Not only printk() from oom_kill_process() can trigger
> > deadlock due to console_sem versus oom_lock dependency but also
> 
> And this means that we have to fix printk. Completely silent oom path is
> out of question IMHO

We cannot fix printk() without giving enough CPU resource to printk().

I don't think "Completely silent oom path" can happen, for warn_alloc() is called
again when it is retried. But anyway, let's remove warn_alloc().

> 
> > schedule_timeout_killable(1) from out_of_memory() can also trigger deadlock
> > due to SCHED_IDLE versus !SCHED_IDLE dependency (like I suggested at 
> > http://lkml.kernel.org/r/201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp ).
> 
> You are still missing the point here. You do not really have to sleep to
> get preempted by high priority task here. Moreover sleep is done after
> we have killed the victim and the reaper can already start tearing down
> the memory. If you oversubscribe your system by high priority tasks you
> are screwed no matter what.
>  

Not possible yet. The OOM reaper is waiting for a thread sleeping at
schedule_timeout_killable(1) to release the oom_lock. If this patch
(alloc_pages_before_oomkill() etc.) is applied, the OOM reaper no longer
needs to wait for the oom_lock.

> > Despite you have said
> > 
> >   So let's agree to disagree about importance of the reliability
> >   warn_alloc. I see it as an improvement which doesn't really have to be
> >   perfect.
> 
> And I stand by this statement.
> 
> > at https://patchwork.kernel.org/patch/9381891/ , can we agree with killing
> > the synchronous allocation stall warning messages and start seeking for
> > asynchronous approach?
> 
> I've already said that I will not oppose removing it if regular
> workloads are tripping over it. Johannes had some real world examples
> AFAIR but didn't provide any details which we could use for the
> changelog. I wouldn't be entirely happy about that but the reality says
> that the printk infrastructure is not really prepared for extreme loads.

Yes, Johannes's case is a real world example. OK. Let's remove warn_alloc().
Removing warn_alloc() will also solve Mikulas Patocka's "mm: respect the
__GFP_NOWARN flag when warning about stalls" suggestion.

Johannes, can you provide details? (I wonder whether he can pick up meaningful
lines from "Tons and tons of allocation stall warnings followed by the soft
lock-ups." though...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
