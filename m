Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68E2E6B04FF
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:11:02 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id p135so26549745ita.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:11:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d184si1419213ite.112.2017.07.11.06.10.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 06:11:00 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170602071818.GA29840@dhcp22.suse.cz>
	<201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
	<20170710132139.GJ19185@dhcp22.suse.cz>
	<201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
	<20170710141428.GL19185@dhcp22.suse.cz>
In-Reply-To: <20170710141428.GL19185@dhcp22.suse.cz>
Message-Id: <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
Date: Tue, 11 Jul 2017 22:10:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> On Mon 10-07-17 22:54:37, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sat 08-07-17 13:59:54, Tetsuo Handa wrote:
> > > [...]
> > > > Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
> > > > Michal Hocko wrote:
> > > > > On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > > > > > You are rejecting serialization under OOM without giving a chance to test
> > > > > > side effects of serialization under OOM at linux-next.git. I call such attitude
> > > > > > "speculation" which you never accept.
> > > > > 
> > > > > No I am rejecting abusing the lock for purpose it is not aimed for.
> > > > 
> > > > Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
> > > > Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
> > > > jumbled, there should be no reason you reject this lock.
> > > > 
> > > > If you don't like locks, can you instead accept below one?
> > > 
> > > No, seriously! Just think about what you are proposing. You are stalling
> > > and now you will stall _random_ tasks even more. Some of them for
> > > unbound amount of time because of inherent unfairness of cmpxchg.
> > 
> > The cause of stall when oom_lock is already held is that threads which failed to
> > hold oom_lock continue almost busy looping; schedule_timeout_uninterruptible(1) is
> > not sufficient when there are multiple threads doing the same thing, for direct
> > reclaim/compaction consumes a lot of CPU time.
> > 
> > What makes this situation worse is, since warn_alloc() periodically appends to
> > printk() buffer, the thread inside the OOM killer with oom_lock held can stall
> > forever due to cond_resched() from console_unlock() from printk().
> 
> warn_alloc is just yet-another-user of printk. We might have many
> others...

warn_alloc() is different from other users of printk() that printk() is called
as long as oom_lock is already held by somebody else processing console_unlock().

>  
> > Below change significantly reduces possibility of falling into printk() v.s. oom_lock
> > lockup problem, for the thread inside the OOM killer with oom_lock held no longer
> > blocks inside printk(). Though there still remains possibility of sleeping for
> > unexpectedly long at schedule_timeout_killable(1) with the oom_lock held.
> 
> This just papers over the real problem.
> 
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -1051,8 +1051,10 @@ bool out_of_memory(struct oom_control *oc)
> >  		panic("Out of memory and no killable processes...\n");
> >  	}
> >  	if (oc->chosen && oc->chosen != (void *)-1UL) {
> > +		preempt_disable();
> >  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> >  				 "Memory cgroup out of memory");
> > +		preempt_enable_no_resched();
> >  		/*
> >  		 * Give the killed process a good chance to exit before trying
> >  		 * to allocate memory again.
> > 
> > I wish we could agree with applying this patch until printk-kthread can
> > work reliably...
> 
> And now you have introduced soft lockups most probably because
> oom_kill_process can take some time... Or maybe even sleeping while
> atomic warnings if some code path needs to sleep for whatever reason.
> The real fix is make sure that printk doesn't take an arbitrary amount of
> time.

The OOM killer is not permitted to wait for __GFP_DIRECT_RECLAIM allocations
directly/indirectly (because it will cause recursion deadlock). Thus, even if
some code path needs to sleep for some reason, that code path is not permitted to
wait for __GFP_DIRECT_RECLAIM allocations directly/indirectly. Anyway, I can
propose scattering preempt_disable()/preempt_enable_no_resched() around printk()
rather than whole oom_kill_process(). You will just reject it as you have rejected
in the past.

Using a reproducer and a patch to disable warn_alloc() at
http://lkml.kernel.org/r/201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp ,
you will find that calling cond_resched() (from console_unlock() from printk())
can cause a delay of nearly one minute, and it can cause a delay of nearly 5 minutes
to complete one out_of_memory() call. Notice that the reproducer is using not so
insane number of threads (only 10 children). (It will become a DoS if 100 children
or 1024 children.)

----------------------------------------
[  589.570344] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[  602.792064] idle-priority cpuset=/ mems_allowed=0
[  602.794185] CPU: 0 PID: 9833 Comm: idle-priority Not tainted 4.12.0-next-20170711+ #628
[  602.796870] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  602.800102] Call Trace:
[  602.801685]  dump_stack+0x67/0x9e
[  602.803444]  dump_header+0x9d/0x3fa
[  602.805227]  ? trace_hardirqs_on+0xd/0x10
[  602.807106]  oom_kill_process+0x226/0x650
[  602.809002]  out_of_memory+0x136/0x560
[  602.810822]  ? out_of_memory+0x206/0x560
[  602.812688]  __alloc_pages_nodemask+0xcd2/0xe50
[  602.814676]  alloc_pages_vma+0x76/0x1a0
[  602.816519]  __handle_mm_fault+0xdff/0x1180
[  602.818416]  ? native_sched_clock+0x36/0xa0
[  602.820322]  handle_mm_fault+0x186/0x360
[  602.822170]  ? handle_mm_fault+0x44/0x360
[  602.824009]  __do_page_fault+0x1da/0x510
[  602.825808]  do_page_fault+0x21/0x70
[  602.827501]  page_fault+0x22/0x30
[  602.829121] RIP: 0033:0x4008b8
[  602.830657] RSP: 002b:00007ffc7f1b2070 EFLAGS: 00010206
[  602.832602] RAX: 00000000d2d29000 RBX: 0000000100000000 RCX: 00007f2a8e4debd0
[  602.834911] RDX: 0000000000000000 RSI: 0000000000400ae0 RDI: 0000000000000004
[  602.837212] RBP: 00007f288e5ea010 R08: 0000000000000000 R09: 0000000000021000
[  602.839481] R10: 00007ffc7f1b1df0 R11: 0000000000000246 R12: 0000000000000006
[  602.841712] R13: 00007f288e5ea010 R14: 0000000000000000 R15: 0000000000000000
[  602.843964] Mem-Info:
[  660.641313] active_anon:871821 inactive_anon:4422 isolated_anon:0
[  660.641313]  active_file:0 inactive_file:1 isolated_file:0
[  660.641313]  unevictable:0 dirty:0 writeback:0 unstable:0
[  660.641313]  slab_reclaimable:0 slab_unreclaimable:0
[  660.641313]  mapped:555 shmem:6257 pagetables:3184 bounce:0
[  660.641313]  free:21377 free_pcp:188 free_cma:0
[  660.735954] Node 0 active_anon:3487284kB inactive_anon:17688kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2220kB dirty:0kB writeback:0kB shmem:25028kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3198976kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  681.835092] Node 0 DMA free:14780kB min:288kB low:360kB high:432kB active_anon:1092kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  702.374011] lowmem_reserve[]: 0 2688 3624 3624
[  707.583447] Node 0 DMA32 free:53556kB min:49908kB low:62384kB high:74860kB active_anon:2698264kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  729.520428] lowmem_reserve[]: 0 0 936 936
[  734.700444] Node 0 Normal free:17204kB min:17384kB low:21728kB high:26072kB active_anon:787928kB inactive_anon:17688kB active_file:0kB inactive_file:4kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:3072kB pagetables:12736kB bounce:0kB free_pcp:752kB local_pcp:120kB free_cma:0kB
[  760.567618] lowmem_reserve[]: 0 0 0 0
[  765.855466] Node 0 DMA: 1*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (M) 2*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14780kB
[  780.375573] Node 0 DMA32: 7*4kB (UM) 5*8kB (UM) 7*16kB (UM) 6*32kB (U) 5*64kB (UM) 1*128kB (M) 4*256kB (M) 5*512kB (UM) 2*1024kB (M) 1*2048kB (U) 11*4096kB (UM) = 53556kB
[  795.846001] Node 0 Normal: 103*4kB (UM) 21*8kB (UM) 90*16kB (UME) 101*32kB (ME) 43*64kB (UME) 16*128kB (UE) 6*256kB (E) 1*512kB (U) 5*1024kB (UM) 0*2048kB 0*4096kB = 17220kB
[  812.472579] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  821.375279] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  830.344875] 6258 total pagecache pages
[  836.012842] 0 pages in swap cache
[  841.786993] Swap cache stats: add 0, delete 0, find 0/0
[  848.324422] Free swap  = 0kB
[  853.617092] Total swap = 0kB
[  858.757287] 1048445 pages RAM
[  864.079999] 0 pages HighMem/MovableOnly
[  869.764325] 116531 pages reserved
[  875.162601] 0 pages hwpoisoned
[  880.350179] Out of memory: Kill process 9833 (idle-priority) score 928 or sacrifice child
[  888.751868] Killed process 9835 (normal-priority) total-vm:4360kB, anon-rss:96kB, file-rss:0kB, shmem-rss:0kB
----------------------------------------

> 
> You are trying to hammer this particular path but you should realize
> that as long as printk can take an unbound amount of time then there are
> many other land mines which need fixing. It is simply not feasible to go
> after each and ever one of them and try to tweak them around. So please
> stop proposing these random hacks and rather try to work with prink guys
> to find solution for this long term printk limitation. OOM killer is a
> good usecase to give this a priority.

Whatever approach we use for printk() not to take unbound amount of time
(e.g. just enqueue to log_buf using per a thread flag), we might still take
unbound amount of time if we allow cond_sched() (or whatever sleep some
code path might need to use) with the oom_lock held. After all, the OOM killer
is ignoring scheduling priority problem regardless of printk() lockup problem.

I don't have objection about making sure that printk() doesn't take an arbitrary
amount of time. But the real fix is make sure that out_of_memory() doesn't take
an arbitrary amount of time (i.e. don't allow cond_resched() etc. at all) unless
there is cooperation from other allocating threads which failed to hold oom_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
