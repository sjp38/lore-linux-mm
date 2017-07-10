Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8E144084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:14:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 77so24610185wrb.11
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:14:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l82si6781146wmb.156.2017.07.10.07.14.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 07:14:29 -0700 (PDT)
Date: Mon, 10 Jul 2017 16:14:28 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170710141428.GL19185@dhcp22.suse.cz>
References: <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
 <20170710132139.GJ19185@dhcp22.suse.cz>
 <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Mon 10-07-17 22:54:37, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 08-07-17 13:59:54, Tetsuo Handa wrote:
> > [...]
> > > Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
> > > Michal Hocko wrote:
> > > > On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > > > > You are rejecting serialization under OOM without giving a chance to test
> > > > > side effects of serialization under OOM at linux-next.git. I call such attitude
> > > > > "speculation" which you never accept.
> > > > 
> > > > No I am rejecting abusing the lock for purpose it is not aimed for.
> > > 
> > > Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
> > > Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
> > > jumbled, there should be no reason you reject this lock.
> > > 
> > > If you don't like locks, can you instead accept below one?
> > 
> > No, seriously! Just think about what you are proposing. You are stalling
> > and now you will stall _random_ tasks even more. Some of them for
> > unbound amount of time because of inherent unfairness of cmpxchg.
> 
> The cause of stall when oom_lock is already held is that threads which failed to
> hold oom_lock continue almost busy looping; schedule_timeout_uninterruptible(1) is
> not sufficient when there are multiple threads doing the same thing, for direct
> reclaim/compaction consumes a lot of CPU time.
> 
> What makes this situation worse is, since warn_alloc() periodically appends to
> printk() buffer, the thread inside the OOM killer with oom_lock held can stall
> forever due to cond_resched() from console_unlock() from printk().

warn_alloc is just yet-another-user of printk. We might have many
others...
 
> Below change significantly reduces possibility of falling into printk() v.s. oom_lock
> lockup problem, for the thread inside the OOM killer with oom_lock held no longer
> blocks inside printk(). Though there still remains possibility of sleeping for
> unexpectedly long at schedule_timeout_killable(1) with the oom_lock held.

This just papers over the real problem.

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1051,8 +1051,10 @@ bool out_of_memory(struct oom_control *oc)
>  		panic("Out of memory and no killable processes...\n");
>  	}
>  	if (oc->chosen && oc->chosen != (void *)-1UL) {
> +		preempt_disable();
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>  				 "Memory cgroup out of memory");
> +		preempt_enable_no_resched();
>  		/*
>  		 * Give the killed process a good chance to exit before trying
>  		 * to allocate memory again.
> 
> I wish we could agree with applying this patch until printk-kthread can
> work reliably...

And now you have introduced soft lockups most probably because
oom_kill_process can take some time... Or maybe even sleeping while
atomic warnings if some code path needs to sleep for whatever reason.
The real fix is make sure that printk doesn't take an arbitrary amount of
time.

You are trying to hammer this particular path but you should realize
that as long as printk can take an unbound amount of time then there are
many other land mines which need fixing. It is simply not feasible to go
after each and ever one of them and try to tweak them around. So please
stop proposing these random hacks and rather try to work with prink guys
to find solution for this long term printk limitation. OOM killer is a
good usecase to give this a priority.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
