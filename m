Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0446B0505
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:49:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u30so9312wrc.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:49:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si5650wra.76.2017.07.11.06.49.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 06:49:03 -0700 (PDT)
Date: Tue, 11 Jul 2017 15:49:00 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170711134900.GD11936@dhcp22.suse.cz>
References: <20170602071818.GA29840@dhcp22.suse.cz>
 <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
 <20170710132139.GJ19185@dhcp22.suse.cz>
 <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
 <20170710141428.GL19185@dhcp22.suse.cz>
 <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

On Tue 11-07-17 22:10:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 10-07-17 22:54:37, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Sat 08-07-17 13:59:54, Tetsuo Handa wrote:
> > > > [...]
> > > > > Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
> > > > > Michal Hocko wrote:
> > > > > > On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > > > > > > You are rejecting serialization under OOM without giving a chance to test
> > > > > > > side effects of serialization under OOM at linux-next.git. I call such attitude
> > > > > > > "speculation" which you never accept.
> > > > > > 
> > > > > > No I am rejecting abusing the lock for purpose it is not aimed for.
> > > > > 
> > > > > Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
> > > > > Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
> > > > > jumbled, there should be no reason you reject this lock.
> > > > > 
> > > > > If you don't like locks, can you instead accept below one?
> > > > 
> > > > No, seriously! Just think about what you are proposing. You are stalling
> > > > and now you will stall _random_ tasks even more. Some of them for
> > > > unbound amount of time because of inherent unfairness of cmpxchg.
> > > 
> > > The cause of stall when oom_lock is already held is that threads which failed to
> > > hold oom_lock continue almost busy looping; schedule_timeout_uninterruptible(1) is
> > > not sufficient when there are multiple threads doing the same thing, for direct
> > > reclaim/compaction consumes a lot of CPU time.
> > > 
> > > What makes this situation worse is, since warn_alloc() periodically appends to
> > > printk() buffer, the thread inside the OOM killer with oom_lock held can stall
> > > forever due to cond_resched() from console_unlock() from printk().
> > 
> > warn_alloc is just yet-another-user of printk. We might have many
> > others...
> 
> warn_alloc() is different from other users of printk() that printk() is called
> as long as oom_lock is already held by somebody else processing console_unlock().

So what exactly prevents any other caller of printk interfering while
the oom is ongoing?

> 
> >  
> > > Below change significantly reduces possibility of falling into printk() v.s. oom_lock
> > > lockup problem, for the thread inside the OOM killer with oom_lock held no longer
> > > blocks inside printk(). Though there still remains possibility of sleeping for
> > > unexpectedly long at schedule_timeout_killable(1) with the oom_lock held.
> > 
> > This just papers over the real problem.
> > 
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -1051,8 +1051,10 @@ bool out_of_memory(struct oom_control *oc)
> > >  		panic("Out of memory and no killable processes...\n");
> > >  	}
> > >  	if (oc->chosen && oc->chosen != (void *)-1UL) {
> > > +		preempt_disable();
> > >  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> > >  				 "Memory cgroup out of memory");
> > > +		preempt_enable_no_resched();
> > >  		/*
> > >  		 * Give the killed process a good chance to exit before trying
> > >  		 * to allocate memory again.
> > > 
> > > I wish we could agree with applying this patch until printk-kthread can
> > > work reliably...
> > 
> > And now you have introduced soft lockups most probably because
> > oom_kill_process can take some time... Or maybe even sleeping while
> > atomic warnings if some code path needs to sleep for whatever reason.
> > The real fix is make sure that printk doesn't take an arbitrary amount of
> > time.
> 
> The OOM killer is not permitted to wait for __GFP_DIRECT_RECLAIM allocations
> directly/indirectly (because it will cause recursion deadlock). Thus, even if
> some code path needs to sleep for some reason, that code path is not permitted to
> wait for __GFP_DIRECT_RECLAIM allocations directly/indirectly. Anyway, I can
> propose scattering preempt_disable()/preempt_enable_no_resched() around printk()
> rather than whole oom_kill_process(). You will just reject it as you have rejected
> in the past.

because you are trying to address a problem at a wrong layer. If there
is absolutely no way around it and printk is unfixable then we really
need a printk variant which will make sure that no excessive waiting
will be involved. Then we can replace all printk in the oom path with
this special printk.
 
[...]

> > You are trying to hammer this particular path but you should realize
> > that as long as printk can take an unbound amount of time then there are
> > many other land mines which need fixing. It is simply not feasible to go
> > after each and ever one of them and try to tweak them around. So please
> > stop proposing these random hacks and rather try to work with prink guys
> > to find solution for this long term printk limitation. OOM killer is a
> > good usecase to give this a priority.
> 
> Whatever approach we use for printk() not to take unbound amount of time
> (e.g. just enqueue to log_buf using per a thread flag), we might still take
> unbound amount of time if we allow cond_sched() (or whatever sleep some
> code path might need to use) with the oom_lock held. After all, the OOM killer
> is ignoring scheduling priority problem regardless of printk() lockup problem.
> 
> I don't have objection about making sure that printk() doesn't take an arbitrary
> amount of time. But the real fix is make sure that out_of_memory() doesn't take
> an arbitrary amount of time (i.e. don't allow cond_resched() etc. at all) unless
> there is cooperation from other allocating threads which failed to hold oom_lock.

As I've said out_of_memory is an expensive operation and as such it has
to be preemptible. Addressing this would require quite some work.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
