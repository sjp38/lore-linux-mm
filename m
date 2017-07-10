Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67E0B44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:55:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n6so131410273itc.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:55:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o134si6779777itb.93.2017.07.10.06.54.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:54:58 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
	<20170710132139.GJ19185@dhcp22.suse.cz>
In-Reply-To: <20170710132139.GJ19185@dhcp22.suse.cz>
Message-Id: <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
Date: Mon, 10 Jul 2017 22:54:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Sat 08-07-17 13:59:54, Tetsuo Handa wrote:
> [...]
> > Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
> > Michal Hocko wrote:
> > > On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > > > You are rejecting serialization under OOM without giving a chance to test
> > > > side effects of serialization under OOM at linux-next.git. I call such attitude
> > > > "speculation" which you never accept.
> > > 
> > > No I am rejecting abusing the lock for purpose it is not aimed for.
> > 
> > Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
> > Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
> > jumbled, there should be no reason you reject this lock.
> > 
> > If you don't like locks, can you instead accept below one?
> 
> No, seriously! Just think about what you are proposing. You are stalling
> and now you will stall _random_ tasks even more. Some of them for
> unbound amount of time because of inherent unfairness of cmpxchg.

The cause of stall when oom_lock is already held is that threads which failed to
hold oom_lock continue almost busy looping; schedule_timeout_uninterruptible(1) is
not sufficient when there are multiple threads doing the same thing, for direct
reclaim/compaction consumes a lot of CPU time.

What makes this situation worse is, since warn_alloc() periodically appends to
printk() buffer, the thread inside the OOM killer with oom_lock held can stall
forever due to cond_resched() from console_unlock() from printk().

Below change significantly reduces possibility of falling into printk() v.s. oom_lock
lockup problem, for the thread inside the OOM killer with oom_lock held no longer
blocks inside printk(). Though there still remains possibility of sleeping for
unexpectedly long at schedule_timeout_killable(1) with the oom_lock held.

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1051,8 +1051,10 @@ bool out_of_memory(struct oom_control *oc)
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL) {
+		preempt_disable();
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
+		preempt_enable_no_resched();
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.

I wish we could agree with applying this patch until printk-kthread can
work reliably...

> 
> If there is a _real_ problem it should be debugged and fixed. If this
> is a limitation of what printk can handle then we should think how to
> throttle it even more (e.g. does it make much sense to dump_stack when
> it hasn't changed since the last time?). If this is about dump_stack
> taking too long then we should look into it but we definitely should add
> a more on top.

The real problem is lack of CPU time for reclaiming memory when allocating
threads failed to hold oom_lock. And you are refusing to allow allocating
threads give CPU time to the thread holding oom_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
