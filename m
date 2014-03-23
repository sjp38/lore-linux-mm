Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id D43546B00A3
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 09:52:01 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id lx4so4379883iec.38
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 06:52:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id py2si10286242igc.34.2014.03.23.06.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 06:52:01 -0700 (PDT)
Message-ID: <532EE6E4.8070903@oracle.com>
Date: Sun, 23 Mar 2014 09:51:32 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kswapd/kernfs possible deadlock
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>, Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Hi all,

While fuzzing with trinity inside KVM tools guest running latest -next kernel
I've stumbled on the following:

[ 1336.998827] ======================================================
[ 1337.000394] [ INFO: possible circular locking dependency detected ]
[ 1337.001425] 3.14.0-rc7-next-20140321-sasha-00018-g0516fe6-dirty #265 Tainted: G        W
[ 1337.001964] -------------------------------------------------------
[ 1337.001964] trinity-c24/33631 is trying to acquire lock:
[ 1337.001964]  (&pgdat->kswapd_wait){..-.-.}, at: __wake_up (kernel/sched/wait.c:94)
[ 1337.001964]
[ 1337.001964] but task is already holding lock:
[ 1337.001964]  (&(&n->list_lock)->rlock){-.-.-.}, at: list_locations (mm/slub.c:4159)
[ 1337.001964]
[ 1337.001964] which lock already depends on the new lock.
[ 1337.001964]
[ 1337.001964]
[ 1337.001964] the existing dependency chain (in reverse order) is:
[ 1337.001964]
-> #3 (&(&n->list_lock)->rlock){-.-.-.}:
[ 1337.001964]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1337.001964]        _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 1337.001964]        get_partial_node.isra.35 (mm/slub.c:1623)
[ 1337.001964]        __slab_alloc (mm/slub.c:1725 mm/slub.c:2193 mm/slub.c:2359)
[ 1337.001964]        kmem_cache_alloc (mm/slub.c:2465 mm/slub.c:2476 mm/slub.c:2481)
[ 1337.001964]        __debug_object_init (lib/debugobjects.c:97 lib/debugobjects.c:311)
[ 1337.001964]        debug_object_init (lib/debugobjects.c:364)
[ 1337.001964]        hrtimer_init (kernel/hrtimer.c:432 include/linux/jump_label.h:105 include/trace/events/timer.h:130 kernel/hrtimer.c:477 kernel/hrtimer.c:1199)
[ 1337.001964]        __sched_fork (kernel/sched/core.c:1732)
[ 1337.001964]        init_idle (kernel/sched/core.c:4483)
[ 1337.001964]        fork_idle (kernel/fork.c:1566)
[ 1337.001964]        idle_threads_init (kernel/smpboot.c:54 kernel/smpboot.c:72)
[ 1337.001964]        smp_init (kernel/smp.c:493)
[ 1337.001964]        kernel_init_freeable (init/main.c:757 init/main.c:910)
[ 1337.001964]        kernel_init (init/main.c:842)
[ 1337.001964]        ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 1337.001964]
-> #2 (&rq->lock){-.-.-.}:
[ 1337.001964]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1337.001964]        _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 1337.001964]        wake_up_new_task (include/linux/sched.h:2884 kernel/sched/core.c:313 kernel/sched/core.c:2014)
[ 1337.001964]        do_fork (kernel/fork.c:1627)
[ 1337.001964]        kernel_thread (kernel/fork.c:1647)
[ 1337.001964]        rest_init (init/main.c:383)
[ 1337.001964]        start_kernel (init/main.c:653)
[ 1337.001964]        x86_64_start_reservations (arch/x86/kernel/head64.c:194)
[ 1337.001964]        x86_64_start_kernel (arch/x86/kernel/head64.c:183)
[ 1337.001964]
-> #1 (&p->pi_lock){-.-.-.}:
[ 1337.001964]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1337.001964]        _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
[ 1337.001964]        try_to_wake_up (kernel/sched/core.c:1592)
[ 1337.001964]        default_wake_function (kernel/sched/core.c:2846)
[ 1337.001964]        autoremove_wake_function (kernel/sched/wait.c:294)
[ 1337.001964]        __wake_up_common (kernel/sched/wait.c:72)
[ 1337.001964]        __wake_up (include/linux/spinlock.h:358 kernel/sched/wait.c:95)
[ 1337.001964]        wakeup_kswapd (mm/vmscan.c:3328)
[ 1337.001964]        __alloc_pages_slowpath (mm/page_alloc.c:2429 mm/page_alloc.c:2530)
[ 1337.001964]        __alloc_pages_nodemask (mm/page_alloc.c:2767)
[ 1337.001964]        alloc_pages_current (mm/mempolicy.c:2055)
[ 1337.001964]        __vmalloc_node_range (include/linux/gfp.h:339 mm/vmalloc.c:1594 mm/vmalloc.c:1650)
[ 1337.001964]        __vmalloc_node (mm/vmalloc.c:1696)
[ 1337.001964]        vmalloc (mm/vmalloc.c:1725)
[ 1337.001964]        SyS_init_module (kernel/module.c:2508 kernel/module.c:3342 kernel/module.c:3330)
[ 1337.001964]        tracesys (arch/x86/kernel/entry_64.S:749)
[ 1337.001964]
-> #0 (&pgdat->kswapd_wait){..-.-.}:
[ 1337.001964]        __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
[ 1337.001964]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1337.001964]        _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
[ 1337.001964]        __wake_up (kernel/sched/wait.c:94)
[ 1337.001964]        wakeup_kswapd (mm/vmscan.c:3328)
[ 1337.001964]        __alloc_pages_slowpath (mm/page_alloc.c:2429 mm/page_alloc.c:2530)
[ 1337.001964]        __alloc_pages_nodemask (mm/page_alloc.c:2767)
[ 1337.001964]        alloc_pages_current (mm/mempolicy.c:2055)
[ 1337.001964]        __get_free_pages (mm/page_alloc.c:2804)
[ 1337.001964]        alloc_loc_track (mm/slub.c:4030)
[ 1337.001964]        process_slab (mm/slub.c:4096 mm/slub.c:4130)
[ 1337.001964]        list_locations (mm/slub.c:4160)
[ 1337.001964]        alloc_calls_show (mm/slub.c:4765)
[ 1337.001964]        slab_attr_show (mm/slub.c:5011)
[ 1337.001964]        sysfs_kf_seq_show (fs/sysfs/file.c:63)
[ 1337.001964]        kernfs_seq_show (fs/kernfs/file.c:155)
[ 1337.001964]        seq_read (fs/seq_file.c:223)
[ 1337.001964]        kernfs_fop_read (fs/kernfs/file.c:230)
[ 1337.001964]        vfs_read (fs/read_write.c:408)
[ 1337.001964]        SyS_read (fs/read_write.c:519 fs/read_write.c:511)
[ 1337.001964]        tracesys (arch/x86/kernel/entry_64.S:749)
[ 1337.001964]
[ 1337.001964] other info that might help us debug this:
[ 1337.001964]
[ 1337.001964] Chain exists of:
&pgdat->kswapd_wait --> &rq->lock --> &(&n->list_lock)->rlock

[ 1337.001964]  Possible unsafe locking scenario:
[ 1337.001964]
[ 1337.001964]        CPU0                    CPU1
[ 1337.001964]        ----                    ----
[ 1337.001964]   lock(&(&n->list_lock)->rlock);
[ 1337.001964]                                lock(&rq->lock);
[ 1337.001964]                                lock(&(&n->list_lock)->rlock);
[ 1337.001964]   lock(&pgdat->kswapd_wait);
[ 1337.001964]
[ 1337.001964]  *** DEADLOCK ***
[ 1337.001964]
[ 1337.001964] 5 locks held by trinity-c24/33631:
[ 1337.001964]  #0:  (&f->f_pos_lock){+.+.+.}, at: __fdget_pos (fs/file.c:736)
[ 1337.001964]  #1:  (&p->lock){+.+.+.}, at: seq_read (fs/seq_file.c:175)
[ 1337.001964]  #2:  (&of->mutex){+.+.+.}, at: kernfs_seq_start (fs/kernfs/file.c:99)
[ 1337.001964]  #3:  (s_active#87){++++.+}, at: kernfs_seq_start (fs/kernfs/file.c:99)
[ 1337.001964]  #4:  (&(&n->list_lock)->rlock){-.-.-.}, at: list_locations (mm/slub.c:4159)
[ 1337.001964]
[ 1337.001964] stack backtrace:
[ 1337.001964] CPU: 24 PID: 33631 Comm: trinity-c24 Tainted: G        W     3.14.0-rc7-next-20140321-sasha-00018-g0516fe6-dirty #265
[ 1337.001964]  ffffffff87972190 ffff88032f1d37e8 ffffffff844b0f37 0000000000000000
[ 1337.001964]  ffffffff879d65d0 ffff88032f1d3838 ffffffff844a398b 0000000000000005
[ 1337.001964]  ffff88032f1d38c8 ffff88032f1d3838 ffff8803462f8dd0 ffff8803462f8e08
[ 1337.001964] Call Trace:
[ 1337.001964]  dump_stack (lib/dump_stack.c:52)
[ 1337.001964]  print_circular_bug (kernel/locking/lockdep.c:1216)
[ 1337.001964]  __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
[ 1337.001964]  ? __bfs (kernel/locking/lockdep.c:1030)
[ 1337.001964]  lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1337.001964]  ? __wake_up (kernel/sched/wait.c:94)
[ 1337.001964]  ? _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:109 kernel/locking/spinlock.c:159)
[ 1337.001964]  _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
[ 1337.001964]  ? __wake_up (kernel/sched/wait.c:94)
[ 1337.001964]  ? zone_watermark_ok_safe (mm/page_alloc.c:1741)
[ 1337.001964]  __wake_up (kernel/sched/wait.c:94)
[ 1337.001964]  wakeup_kswapd (mm/vmscan.c:3328)
[ 1337.001964]  __alloc_pages_slowpath (mm/page_alloc.c:2429 mm/page_alloc.c:2530)
[ 1337.001964]  ? get_page_from_freelist (mm/page_alloc.c:1940)
[ 1337.001964]  ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[ 1337.001964]  ? sched_clock_local (kernel/sched/clock.c:214)
[ 1337.001964]  __alloc_pages_nodemask (mm/page_alloc.c:2767)
[ 1337.001964]  alloc_pages_current (mm/mempolicy.c:2055)
[ 1337.001964]  ? __get_free_pages (mm/page_alloc.c:2804)
[ 1337.001964]  ? get_parent_ip (kernel/sched/core.c:2472)
[ 1337.001964]  __get_free_pages (mm/page_alloc.c:2804)
[ 1337.001964]  alloc_loc_track (mm/slub.c:4030)
[ 1337.001964]  process_slab (mm/slub.c:4096 mm/slub.c:4130)
[ 1337.001964]  ? list_locations (mm/slub.c:4159)
[ 1337.001964]  list_locations (mm/slub.c:4160)
[ 1337.001964]  alloc_calls_show (mm/slub.c:4765)
[ 1337.001964]  slab_attr_show (mm/slub.c:5011)
[ 1337.001964]  sysfs_kf_seq_show (fs/sysfs/file.c:63)
[ 1337.001964]  kernfs_seq_show (fs/kernfs/file.c:155)
[ 1337.001964]  seq_read (fs/seq_file.c:223)
[ 1337.001964]  kernfs_fop_read (fs/kernfs/file.c:230)
[ 1337.001964]  vfs_read (fs/read_write.c:408)
[ 1337.001964]  SyS_read (fs/read_write.c:519 fs/read_write.c:511)
[ 1337.001964]  tracesys (arch/x86/kernel/entry_64.S:749)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
