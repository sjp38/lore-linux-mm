Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id C27986B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 12:06:59 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so2358608veb.16
        for <linux-mm@kvack.org>; Fri, 30 May 2014 09:06:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s27si8653422yhi.159.2014.05.30.09.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 May 2014 09:06:59 -0700 (PDT)
Date: Fri, 30 May 2014 12:06:42 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] gpu/drm/ttm: Use mutex_lock_killable() for shrinker
 functions.
Message-ID: <20140530160641.GC3621@localhost.localdomain>
References: <201405192339.JIJ04144.FHQFVFOtOSLJOM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.00.1405200140010.20503@skynet.skynet.ie>
 <201405210030.HBD65663.FFLVHOFMSJOtOQ@I-love.SAKURA.ne.jp>
 <201405242322.AID86423.HOMLQJOtFFVOSF@I-love.SAKURA.ne.jp>
 <20140528185445.GA23122@phenom.dumpdata.com>
 <201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Thu, May 29, 2014 at 06:47:49AM +0900, Tetsuo Handa wrote:
> Konrad Rzeszutek Wilk wrote:
> > On Sat, May 24, 2014 at 11:22:09PM +0900, Tetsuo Handa wrote:
> > > Hello.
> > > 
> > > I tried to test whether it is OK (from point of view of reentrant) to use
> > > mutex_lock() or mutex_lock_killable() inside shrinker functions when shrinker
> > > functions do memory allocation, for drivers/gpu/drm/ttm/ttm_page_alloc_dma.c is
> > > doing memory allocation with mutex lock held inside ttm_dma_pool_shrink_scan().
> > > 
> > > If I compile a test module shown below which mimics extreme case of what
> > > ttm_dma_pool_shrink_scan() will do
> > 
> > And ttm_pool_shrink_scan.
> 
> I don't know why but ttm_pool_shrink_scan() does not take mutex.
> 
> > > and load the test module and do
> > > 
> > >   # echo 3 > /proc/sys/vm/drop_caches
> > > 
> > > the system stalls with 0% CPU usage because of mutex deadlock
> > > (with prior lockdep warning).
> > > 
> > > Is this because wrong gfp flags are passed to kmalloc() ? Is this because
> > > the test module's shrinker functions return wrong values? Is this because
> > > doing memory allocation with mutex held inside shrinker functions is
> > > forbidden? Can anybody tell me what is wrong with my test module?
> > 
> > What is the sc->gfp_flags? What if you use GFP_ATOMIC?
> > 
> I didn't check it but at least I'm sure that __GFP_WAIT bit is set.
> Thus, GFP_ATOMIC or GFP_NOWAIT will solve this problem.
> 
> > In regards to the lockdep warning below it looks like
> > > 
> > > Regards.
> > > 
> > > [   48.077353] 
> > > [   48.077999] =================================
> > > [   48.080023] [ INFO: inconsistent lock state ]
> > > [   48.080023] 3.15.0-rc6-00190-g1ee1cea #203 Tainted: G           OE
> > > [   48.080023] ---------------------------------
> > > [   48.080023] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> > > [   48.086745] kswapd0/784 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > [   48.086745]  (lock#2){+.+.?.}, at: [<e0861022>] shrink_test_count+0x12/0x60 [test]
> > > [   48.086745] {RECLAIM_FS-ON-W} state was registered at:
> > 
> > 
> > You have the scenario you described below, that is:
> > 
> > shrink_test_scan	
> > 	mutex_lock_killable()
> > 		-> kmalloc
> > 			-> shrink_test_count
> > 				mutex_lock_killable()
> > 
> > And 'mutex_lock_killable' is the same (in at least this context)
> > the same as 'mutex_lock'. In other words, your second 'mutex_lock'
> > is going to spin - which is a deadlock.
> > 
> > Perhaps a way of not getting in this scenario is:
> > 
> >  1). Try to take the mutex (ie, one that won't spin if it can't
> >      get it).
> > 
> >  2). Use the GFP_ATOMIC in the shrinker so that we never
> >      end up calling ourselves in case of memory pressure
> > 
> > ?
> 
> Yes, I think so as well.
> 
> > > > > This patch changes "mutex_lock();" to "if (mutex_lock_killable()) return ...;"
> > > > > so that any threads can promptly give up. (By the way, as far as I tested,
> > > > > changing to "if (!mutex_trylock()) return ...;" likely shortens the duration
> > > > > of stall. Maybe we don't need to wait for mutex if someone is already calling
> > > > > these functions.)
> > > > > 
> > > > 
> > > > While discussing about XFS problem, I got a question. Is it OK (from point
> > > > of view of reentrant) to use mutex_lock() or mutex_lock_killable() inside
> > > > shrinker's entry point functions? Can senario shown below possible?
> > > > 
> > > > (1) kswapd is doing memory reclaim which does not need to hold mutex.
> > > > 
> > > > (2) Someone in GFP_KERNEL context (not kswapd) calls
> > > >     ttm_dma_pool_shrink_count() and then calls ttm_dma_pool_shrink_scan()
> > > >     from direct reclaim path.
> > > > 
> > > > (3) Inside ttm_dma_pool_shrink_scan(), GFP_KERNEL allocation is issued
> > > >     while mutex is held by the someone.
> > > > 
> > > > (4) GFP_KERNEL allocation cannot be completed immediately due to memory
> > > >     pressure.
> > > > 
> > > > (5) kswapd calls ttm_dma_pool_shrink_count() which need to hold mutex.
> > > > 
> > > > (6) Inside ttm_dma_pool_shrink_count(), kswapd is blocked waiting for
> > > >     mutex held by the someone, and the someone is waiting for GFP_KERNEL
> > > >     allocation to complete, but GFP_KERNEL allocation cannot be completed
> > > >     until mutex held by the someone is released?
> > 
> > Ewww. Perhaps if we used GFP_ATOMIC for the array allocation we do in
> > ttm_dma_page_pool_free and ttm_page_pool_free?
> > 
> > That would avoid the 4) problem.
> 
> Right. Which approach ("use GFP_ATOMIC or GFP_NOWAIT" / "use !mutex_trylock()")
> do you prefer? I'll create RHBZ entry for RHEL7 kernel as non count/scan
> version has the same problem.

I am not sure why you need an RHBZ - as the patches that go upstream
don't need an RHBZ.

I think the combination of mutex_trylock and GFP_ATOMIC would suffice.

Thank you!
> 
> ---------- test.c start ----------
> #include <linux/module.h>
> #include <linux/sched.h>
> #include <linux/slab.h>
> #include <linux/mm.h>
> 
> static int shrink_test(struct shrinker *shrinker, struct shrink_control *sc)
> {
> 	static DEFINE_MUTEX(lock);
> 	LIST_HEAD(list);
> 	int i = 0;
> 	if (mutex_lock_killable(&lock)) {
> 		printk(KERN_WARNING "Process %u (%s) gave up waiting for mutex"
> 		       "\n", current->pid, current->comm);
> 		return 0;
> 	}
> 	while (1) {
> 		struct list_head *l = kmalloc(PAGE_SIZE, sc->gfp_mask);
> 		if (!l)
> 			break;
> 		list_add_tail(l, &list);
> 		i++;
> 	}
> 	printk(KERN_WARNING "Process %u (%s) allocated %u pages\n",
> 	       current->pid, current->comm, i);
> 	while (i--) {
> 		struct list_head *l = list.next;
> 		list_del(l);
> 		kfree(l);
> 	}
> 	mutex_unlock(&lock);
> 	return 0;
> }
> 
> static struct shrinker recursive_shrinker = {
> 	.shrink = shrink_test,
> 	.seeks = DEFAULT_SEEKS,
> };
> 
> static int __init recursive_shrinker_init(void)
> {
> 	register_shrinker(&recursive_shrinker);
> 	return 0;
> }
> 
> module_init(recursive_shrinker_init);
> MODULE_LICENSE("GPL");
> ---------- test.c end ----------
> 
> [ 1263.179725] 
> [ 1263.180756] =================================
> [ 1263.182322] [ INFO: inconsistent lock state ]
> [ 1263.183920] 3.10.0-121.el7.x86_64.debug #1 Tainted: GF          O--------------  
> [ 1263.186162] ---------------------------------
> [ 1263.187742] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> [ 1263.189788] kswapd0/105 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [ 1263.191523]  (lock#3){+.+.?.}, at: [<ffffffffa0563040>] shrink_test+0x40/0x140 [test]
> [ 1263.194053] {RECLAIM_FS-ON-W} state was registered at:
> [ 1263.195848]   [<ffffffff810ea759>] mark_held_locks+0xb9/0x140
> [ 1263.197758]   [<ffffffff810ecb6a>] lockdep_trace_alloc+0x7a/0xe0
> [ 1263.199718]   [<ffffffff811db9d3>] kmem_cache_alloc_trace+0x33/0x340
> [ 1263.201809]   [<ffffffffa0563061>] shrink_test+0x61/0x140 [test]
> [ 1263.203662]   [<ffffffff81194a99>] shrink_slab+0xb9/0x4d0
> [ 1263.205378]   [<ffffffff81265403>] drop_caches_sysctl_handler+0xc3/0x120
> [ 1263.207352]   [<ffffffff8127dab4>] proc_sys_call_handler+0xe4/0x110
> [ 1263.209238]   [<ffffffff8127daf4>] proc_sys_write+0x14/0x20
> [ 1263.210972]   [<ffffffff811fd1a0>] vfs_write+0xc0/0x1f0
> [ 1263.212658]   [<ffffffff811fdc1b>] SyS_write+0x5b/0xb0
> [ 1263.214301]   [<ffffffff816bd899>] system_call_fastpath+0x16/0x1b
> [ 1263.216172] irq event stamp: 37
> [ 1263.217406] hardirqs last  enabled at (37): [<ffffffff816b2f9c>] _raw_spin_unlock_irq+0x2c/0x50
> [ 1263.219753] hardirqs last disabled at (36): [<ffffffff816b2dff>] _raw_spin_lock_irq+0x1f/0x90
> [ 1263.222052] softirqs last  enabled at (0): [<ffffffff8106aa25>] copy_process.part.22+0x665/0x1750
> [ 1263.224414] softirqs last disabled at (0): [<          (null)>]           (null)
> [ 1263.226492] 
> [ 1263.226492] other info that might help us debug this:
> [ 1263.228920]  Possible unsafe locking scenario:
> [ 1263.228920] 
> [ 1263.231192]        CPU0
> [ 1263.232223]        ----
> [ 1263.233280]   lock(lock#3);
> [ 1263.234435]   <Interrupt>
> [ 1263.235489]     lock(lock#3);
> [ 1263.236708] 
> [ 1263.236708]  *** DEADLOCK ***
> [ 1263.236708] 
> [ 1263.239358] 1 lock held by kswapd0/105:
> [ 1263.240593]  #0:  (shrinker_rwsem){++++.+}, at: [<ffffffff81194a1c>] shrink_slab+0x3c/0x4d0
> [ 1263.242894] 
> [ 1263.242894] stack backtrace:
> [ 1263.244792] CPU: 1 PID: 105 Comm: kswapd0 Tainted: GF          O--------------   3.10.0-121.el7.x86_64.debug #1
> [ 1263.247230] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [ 1263.249747]  ffff880036708000 000000004c6ef89a ffff8800367039c8 ffffffff816a981c
> [ 1263.251849]  ffff880036703a18 ffffffff816a3ac5 0000000000000000 ffff880000000001
> [ 1263.253956]  ffffffff00000001 000000000000000a ffff880036708000 ffffffff810e88a0
> [ 1263.256314] Call Trace:
> [ 1263.257365]  [<ffffffff816a981c>] dump_stack+0x19/0x1b
> [ 1263.258921]  [<ffffffff816a3ac5>] print_usage_bug+0x1f7/0x208
> [ 1263.260591]  [<ffffffff810e88a0>] ? check_usage_backwards+0x1b0/0x1b0
> [ 1263.262379]  [<ffffffff810ea61d>] mark_lock+0x21d/0x2a0
> [ 1263.263898]  [<ffffffff810eb30a>] __lock_acquire+0x52a/0xb60
> [ 1263.265562]  [<ffffffff810232c9>] ? sched_clock+0x9/0x10
> [ 1263.267148]  [<ffffffff810b7c75>] ? sched_clock_cpu+0xb5/0x100
> [ 1263.268802]  [<ffffffff810ec132>] lock_acquire+0xa2/0x1f0
> [ 1263.270378]  [<ffffffffa0563040>] ? shrink_test+0x40/0x140 [test]
> [ 1263.272072]  [<ffffffff816ae859>] mutex_lock_killable_nested+0x99/0x5d0
> [ 1263.273900]  [<ffffffffa0563040>] ? shrink_test+0x40/0x140 [test]
> [ 1263.275610]  [<ffffffffa0563040>] ? shrink_test+0x40/0x140 [test]
> [ 1263.277305]  [<ffffffffa0563040>] shrink_test+0x40/0x140 [test]
> [ 1263.278970]  [<ffffffff81194a99>] shrink_slab+0xb9/0x4d0
> [ 1263.280501]  [<ffffffff811991b9>] balance_pgdat+0x4e9/0x620
> [ 1263.282135]  [<ffffffff811994a3>] kswapd+0x1b3/0x640
> [ 1263.283604]  [<ffffffff8109f3c0>] ? wake_up_bit+0x30/0x30
> [ 1263.285166]  [<ffffffff811992f0>] ? balance_pgdat+0x620/0x620
> [ 1263.286798]  [<ffffffff8109e0cd>] kthread+0xed/0x100
> [ 1263.288286]  [<ffffffff8109dfe0>] ? insert_kthread_work+0x80/0x80
> [ 1263.289973]  [<ffffffff816bd7ec>] ret_from_fork+0x7c/0xb0
> [ 1263.291535]  [<ffffffff8109dfe0>] ? insert_kthread_work+0x80/0x80

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
