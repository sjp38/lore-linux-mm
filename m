Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id C7E4E6B0038
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:54:59 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 9so8709816ykp.19
        for <linux-mm@kvack.org>; Wed, 28 May 2014 11:54:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d59si33163920yhj.35.2014.05.28.11.54.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 11:54:59 -0700 (PDT)
Date: Wed, 28 May 2014 14:54:45 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] gpu/drm/ttm: Use mutex_lock_killable() for shrinker
 functions.
Message-ID: <20140528185445.GA23122@phenom.dumpdata.com>
References: <201405192339.JIJ04144.FHQFVFOtOSLJOM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.00.1405200140010.20503@skynet.skynet.ie>
 <201405210030.HBD65663.FFLVHOFMSJOtOQ@I-love.SAKURA.ne.jp>
 <201405242322.AID86423.HOMLQJOtFFVOSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201405242322.AID86423.HOMLQJOtFFVOSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Sat, May 24, 2014 at 11:22:09PM +0900, Tetsuo Handa wrote:
> Hello.
> 
> I tried to test whether it is OK (from point of view of reentrant) to use
> mutex_lock() or mutex_lock_killable() inside shrinker functions when shrinker
> functions do memory allocation, for drivers/gpu/drm/ttm/ttm_page_alloc_dma.c is
> doing memory allocation with mutex lock held inside ttm_dma_pool_shrink_scan().
> 
> If I compile a test module shown below which mimics extreme case of what
> ttm_dma_pool_shrink_scan() will do

And ttm_pool_shrink_scan.

> 
> ---------- test.c start ----------
> #include <linux/module.h>
> #include <linux/sched.h>
> #include <linux/slab.h>
> #include <linux/mm.h>
> 
> static DEFINE_MUTEX(lock);
> 
> static unsigned long shrink_test_count(struct shrinker *shrinker, struct shrink_control *sc)
> {
>         if (mutex_lock_killable(&lock)) {
>                 printk(KERN_WARNING "Process %u (%s) gave up waiting for mutex"
>                        "\n", current->pid, current->comm);
>                 return 0;
>         }
>         mutex_unlock(&lock);
>         return 1;
> }
> 
> static unsigned long shrink_test_scan(struct shrinker *shrinker, struct shrink_control *sc)
> {
>         LIST_HEAD(list);
>         int i = 0;
>         if (mutex_lock_killable(&lock)) {
>                 printk(KERN_WARNING "Process %u (%s) gave up waiting for mutex"
>                        "\n", current->pid, current->comm);
>                 return 0;
>         }
>         while (1) {
>                 struct list_head *l = kmalloc(PAGE_SIZE, sc->gfp_mask);
>                 if (!l)
>                         break;
>                 list_add_tail(l, &list);
>                 i++;
>         }
>         printk(KERN_WARNING "Process %u (%s) allocated %u pages\n",
>                current->pid, current->comm, i);
>         while (i--) {
>                 struct list_head *l = list.next;
>                 list_del(l);
>                 kfree(l);
>         }
>         mutex_unlock(&lock);
>         return 1;
> }
> 
> static struct shrinker recursive_shrinker = {
>         .count_objects = shrink_test_count,
>         .scan_objects = shrink_test_scan,
>         .seeks = DEFAULT_SEEKS,
> };
> 
> static int __init recursive_shrinker_init(void)
> {
>         register_shrinker(&recursive_shrinker);
>         return 0;
> }
> 
> static void recursive_shrinker_exit(void)
> {
>         unregister_shrinker(&recursive_shrinker);
> }
> 
> module_init(recursive_shrinker_init);
> module_exit(recursive_shrinker_exit);
> MODULE_LICENSE("GPL");
> ---------- test.c end ----------
> 
> and load the test module and do
> 
>   # echo 3 > /proc/sys/vm/drop_caches
> 
> the system stalls with 0% CPU usage because of mutex deadlock
> (with prior lockdep warning).
> 
> Is this because wrong gfp flags are passed to kmalloc() ? Is this because
> the test module's shrinker functions return wrong values? Is this because
> doing memory allocation with mutex held inside shrinker functions is
> forbidden? Can anybody tell me what is wrong with my test module?

What is the sc->gfp_flags? What if you use GFP_ATOMIC?

In regards to the lockdep warning below it looks like
> 
> Regards.
> 
> [   48.077353] 
> [   48.077999] =================================
> [   48.080023] [ INFO: inconsistent lock state ]
> [   48.080023] 3.15.0-rc6-00190-g1ee1cea #203 Tainted: G           OE
> [   48.080023] ---------------------------------
> [   48.080023] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> [   48.086745] kswapd0/784 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [   48.086745]  (lock#2){+.+.?.}, at: [<e0861022>] shrink_test_count+0x12/0x60 [test]
> [   48.086745] {RECLAIM_FS-ON-W} state was registered at:


You have the scenario you described below, that is:

shrink_test_scan	
	mutex_lock_killable()
		-> kmalloc
			-> shrink_test_count
				mutex_lock_killable()

And 'mutex_lock_killable' is the same (in at least this context)
the same as 'mutex_lock'. In other words, your second 'mutex_lock'
is going to spin - which is a deadlock.

Perhaps a way of not getting in this scenario is:

 1). Try to take the mutex (ie, one that won't spin if it can't
     get it).

 2). Use the GFP_ATOMIC in the shrinker so that we never
     end up calling ourselves in case of memory pressure

?

> [   48.086745]   [<c1089c18>] mark_held_locks+0x68/0x90
> [   48.086745]   [<c1089cda>] lockdep_trace_alloc+0x9a/0xe0
> [   48.086745]   [<c110b7f3>] kmem_cache_alloc+0x23/0x170
> [   48.086745]   [<e08610aa>] shrink_test_scan+0x3a/0xf90 [test]
> [   48.086745]   [<c10e59be>] shrink_slab_node+0x13e/0x1d0
> [   48.086745]   [<c10e6911>] shrink_slab+0x61/0xe0
> [   48.086745]   [<c115f849>] drop_caches_sysctl_handler+0x69/0xf0
> [   48.086745]   [<c117275a>] proc_sys_call_handler+0x6a/0xa0
> [   48.086745]   [<c11727aa>] proc_sys_write+0x1a/0x20
> [   48.086745]   [<c1110ac0>] vfs_write+0xa0/0x190
> [   48.086745]   [<c1110ca6>] SyS_write+0x56/0xc0
> [   48.086745]   [<c15201d6>] syscall_call+0x7/0xb
> [   48.086745] irq event stamp: 39
> [   48.086745] hardirqs last  enabled at (39): [<c10f3480>] count_shadow_nodes+0x20/0x40
> [   48.086745] hardirqs last disabled at (38): [<c10f346c>] count_shadow_nodes+0xc/0x40
> [   48.086745] softirqs last  enabled at (0): [<c1040627>] copy_process+0x2e7/0x1400
> [   48.086745] softirqs last disabled at (0): [<  (null)>]   (null)
> [   48.086745] 
> [   48.086745] other info that might help us debug this:
> [   48.086745]  Possible unsafe locking scenario:
> [   48.086745] 
> [   48.086745]        CPU0
> [   48.086745]        ----
> [   48.086745]   lock(lock#2);
> [   48.086745]   <Interrupt>
> [   48.086745]     lock(lock#2);
> [   48.086745] 
> [   48.086745]  *** DEADLOCK ***
> [   48.086745] 
> [   48.086745] 1 lock held by kswapd0/784:
> [   48.086745]  #0:  (shrinker_rwsem){++++.+}, at: [<c10e68da>] shrink_slab+0x2a/0xe0
> [   48.086745] 
> [   48.086745] stack backtrace:
> [   48.086745] CPU: 1 PID: 784 Comm: kswapd0 Tainted: G           OE 3.15.0-rc6-00190-g1ee1cea #203
> [   48.086745] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
> [   48.086745]  c1ab9c20 dd187c94 c151a48f dd184250 dd187cd0 c1088f33 c165aa02 c165ac9d
> [   48.086745]  00000310 00000000 00000000 00000000 00000000 00000001 00000001 c165ac9d
> [   48.086745]  dd1847dc 0000000a 00000008 dd187cfc c1089ae1 00000008 000001b8 31a0987d
> [   48.086745] Call Trace:
> [   48.086745]  [<c151a48f>] dump_stack+0x48/0x61
> [   48.086745]  [<c1088f33>] print_usage_bug+0x1f3/0x250
> [   48.086745]  [<c1089ae1>] mark_lock+0x331/0x400
> [   48.086745]  [<c1088f90>] ? print_usage_bug+0x250/0x250
> [   48.086745]  [<c108a583>] __lock_acquire+0x283/0x1640
> [   48.086745]  [<c108b9bb>] lock_acquire+0x7b/0xa0
> [   48.086745]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   48.086745]  [<c151c544>] mutex_lock_killable_nested+0x64/0x3e0
> [   48.086745]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   48.086745]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   48.086745]  [<c11119f1>] ? put_super+0x21/0x30
> [   48.086745]  [<e0861022>] shrink_test_count+0x12/0x60 [test]
> [   48.086745]  [<c10e58ae>] shrink_slab_node+0x2e/0x1d0
> [   48.086745]  [<c10e68da>] ? shrink_slab+0x2a/0xe0
> [   48.086745]  [<c10e6911>] shrink_slab+0x61/0xe0
> [   48.086745]  [<c10e8416>] kswapd+0x5f6/0x8e0
> [   48.086745]  [<c1062e0f>] kthread+0xaf/0xd0
> [   48.086745]  [<c10e7e20>] ? try_to_free_pages+0x540/0x540
> [   48.086745]  [<c108a08b>] ? trace_hardirqs_on+0xb/0x10
> [   48.086745]  [<c1525d41>] ret_from_kernel_thread+0x21/0x30
> [   48.086745]  [<c1062d60>] ? __init_kthread_worker+0x60/0x60
> 
> [   77.958388] SysRq : Show State
> [   77.959377]   task                PC stack   pid father
> [   77.960803] bash            D dfa6ae80  5068     1      0 0x00000000
> [   77.962348]  ded35c30 00000046 dfa6ae90 dfa6ae80 322a9328 00000000 00000000 0000000b
> [   77.962348]  ded32010 c191c8c0 ded34008 32319d5a 0000000b c191c8c0 32319d5a 0000000b
> [   77.962348]  ded32010 00000001 ded35c04 3230ea9d 0000000b e0863060 ded325c4 ded32010
> [   77.962348] Call Trace:
> [   77.962348]  [<c1073ab7>] ? local_clock+0x17/0x30
> [   77.962348]  [<c151b41e>] schedule+0x1e/0x60
> [   77.962348]  [<c151b6df>] schedule_preempt_disabled+0xf/0x20
> [   77.962348]  [<c151c63f>] mutex_lock_killable_nested+0x15f/0x3e0
> [   77.962348]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<e0861022>] shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<c10e58ae>] shrink_slab_node+0x2e/0x1d0
> [   77.962348]  [<c10e68da>] ? shrink_slab+0x2a/0xe0
> [   77.962348]  [<c10e6911>] shrink_slab+0x61/0xe0
> [   77.962348]  [<c10e7b48>] try_to_free_pages+0x268/0x540
> [   77.962348]  [<c10df529>] __alloc_pages_nodemask+0x3e9/0x720
> [   77.962348]  [<c110bcbd>] cache_alloc_refill+0x37d/0x720
> [   77.962348]  [<e08610aa>] ? shrink_test_scan+0x3a/0xf90 [test]
> [   77.962348]  [<c110b902>] kmem_cache_alloc+0x132/0x170
> [   77.962348]  [<e08610aa>] ? shrink_test_scan+0x3a/0xf90 [test]
> [   77.962348]  [<e08610aa>] shrink_test_scan+0x3a/0xf90 [test]
> [   77.962348]  [<c151c4d8>] ? mutex_unlock+0x8/0x10
> [   77.962348]  [<c10e59be>] shrink_slab_node+0x13e/0x1d0
> [   77.962348]  [<c10e68da>] ? shrink_slab+0x2a/0xe0
> [   77.962348]  [<c10e6911>] shrink_slab+0x61/0xe0
> [   77.962348]  [<c115f849>] drop_caches_sysctl_handler+0x69/0xf0
> [   77.962348]  [<c151fe6d>] ? _raw_spin_unlock+0x1d/0x30
> [   77.962348]  [<c117275a>] proc_sys_call_handler+0x6a/0xa0
> [   77.962348]  [<c11727aa>] proc_sys_write+0x1a/0x20
> [   77.962348]  [<c1110ac0>] vfs_write+0xa0/0x190
> [   77.962348]  [<c1172790>] ? proc_sys_call_handler+0xa0/0xa0
> [   77.962348]  [<c112d0fd>] ? __fdget+0xd/0x10
> [   77.962348]  [<c1110ca6>] SyS_write+0x56/0xc0
> [   77.962348]  [<c15201d6>] syscall_call+0x7/0xb
> 
> [   77.962348] kswapd0         D 00000246  6200   784      2 0x00000000
> [   77.962348]  dd187d9c 00000046 c109d091 00000246 00000086 00000000 00000246 dd184250
> [   77.962348]  dd184250 c191c8c0 dd186008 318e2084 0000000b c191c8c0 37e97ef1 0000000b
> [   77.962348]  dd184250 dd184250 dd187d70 c10880aa dd187dac 00000000 0000007b ffffffff
> [   77.962348] Call Trace:
> [   77.962348]  [<c109d091>] ? rcu_irq_exit+0x71/0xc0
> [   77.962348]  [<c10880aa>] ? print_lock_contention_bug+0x1a/0xf0
> [   77.962348]  [<c151b41e>] schedule+0x1e/0x60
> [   77.962348]  [<c151b6df>] schedule_preempt_disabled+0xf/0x20
> [   77.962348]  [<c151c63f>] mutex_lock_killable_nested+0x15f/0x3e0
> [   77.962348]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<e0861022>] ? shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<e0861022>] shrink_test_count+0x12/0x60 [test]
> [   77.962348]  [<c10e58ae>] shrink_slab_node+0x2e/0x1d0
> [   77.962348]  [<c10e68da>] ? shrink_slab+0x2a/0xe0
> [   77.962348]  [<c10e6911>] shrink_slab+0x61/0xe0
> [   77.962348]  [<c10e8416>] kswapd+0x5f6/0x8e0
> [   77.962348]  [<c1062e0f>] kthread+0xaf/0xd0
> [   77.962348]  [<c10e7e20>] ? try_to_free_pages+0x540/0x540
> [   77.962348]  [<c108a08b>] ? trace_hardirqs_on+0xb/0x10
> [   77.962348]  [<c1525d41>] ret_from_kernel_thread+0x21/0x30
> [   77.962348]  [<c1062d60>] ? __init_kthread_worker+0x60/0x60
> 
> Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > From e314a1a1583e585d062dfc30c8aad8bf5380510b Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Mon, 19 May 2014 18:43:21 +0900
> > > Subject: [PATCH] gpu/drm/ttm: Use mutex_lock_killable() for shrinker functions.
> > > 
> > > I can observe that RHEL7 environment stalls with 100% CPU usage when a
> > > certain type of memory pressure is given. While the shrinker functions
> > > are called by shrink_slab() before the OOM killer is triggered, the stall
> > > lasts for many minutes.
> > > 
> > > I added debug printk() and observed that many threads are blocked for more
> > > than 10 seconds at ttm_dma_pool_shrink_count()/ttm_dma_pool_shrink_scan()
> > > functions. Since the kswapd can call these functions later, the current
> > > thread can return from these functions as soon as chosen by the OOM killer.
> > > 
> > > This patch changes "mutex_lock();" to "if (mutex_lock_killable()) return ...;"
> > > so that any threads can promptly give up. (By the way, as far as I tested,
> > > changing to "if (!mutex_trylock()) return ...;" likely shortens the duration
> > > of stall. Maybe we don't need to wait for mutex if someone is already calling
> > > these functions.)
> > > 
> > 
> > While discussing about XFS problem, I got a question. Is it OK (from point
> > of view of reentrant) to use mutex_lock() or mutex_lock_killable() inside
> > shrinker's entry point functions? Can senario shown below possible?
> > 
> > (1) kswapd is doing memory reclaim which does not need to hold mutex.
> > 
> > (2) Someone in GFP_KERNEL context (not kswapd) calls
> >     ttm_dma_pool_shrink_count() and then calls ttm_dma_pool_shrink_scan()
> >     from direct reclaim path.
> > 
> > (3) Inside ttm_dma_pool_shrink_scan(), GFP_KERNEL allocation is issued
> >     while mutex is held by the someone.
> > 
> > (4) GFP_KERNEL allocation cannot be completed immediately due to memory
> >     pressure.
> > 
> > (5) kswapd calls ttm_dma_pool_shrink_count() which need to hold mutex.
> > 
> > (6) Inside ttm_dma_pool_shrink_count(), kswapd is blocked waiting for
> >     mutex held by the someone, and the someone is waiting for GFP_KERNEL
> >     allocation to complete, but GFP_KERNEL allocation cannot be completed
> >     until mutex held by the someone is released?

Ewww. Perhaps if we used GFP_ATOMIC for the array allocation we do in
ttm_dma_page_pool_free and ttm_page_pool_free?

That would avoid the 4) problem.
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
