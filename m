Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 370D38E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 08:09:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so2680759pfb.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 05:09:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q10si63940777pll.221.2019.01.08.05.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 Jan 2019 05:08:59 -0800 (PST)
Date: Tue, 8 Jan 2019 14:08:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190108130849.GF6808@hirez.programming.kicks-ass.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, hannes@cmpxchg.org

On Wed, Jan 02, 2019 at 01:51:01PM +0100, Vlastimil Babka wrote:

> > syz-executor0/8529 is trying to acquire lock:
> > 000000005e7fb829 (&pgdat->kswapd_wait){....}, at:  
> > __wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120
> 
> From the backtrace at the end of report I see it's coming from
> 
> >   wakeup_kswapd+0x5f0/0x930 mm/vmscan.c:3982
> >   steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2217
> 
> This wakeup_kswapd is new due to Mel's 1c30844d2dfe ("mm: reclaim small
> amounts of memory when an external fragmentation event occurs") so CC Mel.

Right; and I see Mel already has a fix for that.

> > the existing dependency chain (in reverse order) is:
> > 
> > -> #4 (&(&zone->lock)->rlock){-.-.}:
> >         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
> >         _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
> >         rmqueue mm/page_alloc.c:3082 [inline]
> >         get_page_from_freelist+0x9eb/0x52a0 mm/page_alloc.c:3491
> >         __alloc_pages_nodemask+0x4f3/0xde0 mm/page_alloc.c:4529
> >         __alloc_pages include/linux/gfp.h:473 [inline]
> >         alloc_page_interleave+0x25/0x1c0 mm/mempolicy.c:1988
> >         alloc_pages_current+0x1bf/0x210 mm/mempolicy.c:2104
> >         alloc_pages include/linux/gfp.h:509 [inline]
> >         depot_save_stack+0x3f1/0x470 lib/stackdepot.c:260
> >         save_stack+0xa9/0xd0 mm/kasan/common.c:79
> >         set_track mm/kasan/common.c:85 [inline]
> >         kasan_kmalloc+0xcb/0xd0 mm/kasan/common.c:482
> >         kasan_slab_alloc+0x12/0x20 mm/kasan/common.c:397
> >         kmem_cache_alloc+0x130/0x730 mm/slab.c:3541
> >         kmem_cache_zalloc include/linux/slab.h:731 [inline]
> >         fill_pool lib/debugobjects.c:134 [inline]
> >         __debug_object_init+0xbb8/0x1290 lib/debugobjects.c:379
> >         debug_object_init lib/debugobjects.c:431 [inline]
> >         debug_object_activate+0x323/0x600 lib/debugobjects.c:512
> >         debug_timer_activate kernel/time/timer.c:708 [inline]
> >         debug_activate kernel/time/timer.c:763 [inline]
> >         __mod_timer kernel/time/timer.c:1040 [inline]
> >         mod_timer kernel/time/timer.c:1101 [inline]
> >         add_timer+0x50e/0x1490 kernel/time/timer.c:1137
> >         __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
> >         queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
> >         queue_delayed_work include/linux/workqueue.h:527 [inline]
> >         schedule_delayed_work include/linux/workqueue.h:628 [inline]
> >         start_dirtytime_writeback+0x4e/0x53 fs/fs-writeback.c:2043
> >         do_one_initcall+0x145/0x957 init/main.c:889
> >         do_initcall_level init/main.c:957 [inline]
> >         do_initcalls init/main.c:965 [inline]
> >         do_basic_setup init/main.c:983 [inline]
> >         kernel_init_freeable+0x4c1/0x5af init/main.c:1136
> >         kernel_init+0x11/0x1ae init/main.c:1056
> >         ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> > 
> > -> #3 (&base->lock){-.-.}:

However I really, _really_ hate that dependency. We really should not
get memory allocations under rq->lock.

We seem to avoid this for the existing hrtimer usage, because of
hrtimer_init() doing: debug_init() -> debug_hrtimer_init() ->
debug_object_init().

But that isn't done for the (PSI) schedule_delayed_work() thing for some
raisin; even though: group_init() does INIT_DELAYED_WORK() ->
__INIT_DELAYED_WORK() -> __init_timer() -> init_timer_key() ->
debug_init() -> debug_timer_init() -> debug_object_init().

But _somehow_ that isn't doing it.

Now debug_object_activate() has this case:

	if (descr->is_static_object && descr->is_static_object(addr)) {
		debug_object_init()

which does an debug_object_init() for static allocations, which brings
us to:

  static DEFINE_PER_CPU(struct psi_group_cpu, system_group_pcpu);
  static struct psi_group psi_system = {

But that _should_ get initialized by psi_init(), which is called from
sched_init() which _should_ be waaay before do_basic_setup().

Something goes wobbly.. but I'm not seeing it.
