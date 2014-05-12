Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1E62A6B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:28:17 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so4873848eei.0
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:28:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si10962291eel.119.2014.05.12.09.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 09:28:13 -0700 (PDT)
Date: Mon, 12 May 2014 18:28:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: mm,console: circular dependency between console_sem and zone lock
Message-ID: <20140512162811.GD3685@quack.suse.cz>
References: <536AE5DC.6070307@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536AE5DC.6070307@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Steven Rostedt <rostedt@goodmis.org>

On Wed 07-05-14 22:03:08, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew:
  Thanks for report. So the problem seems to be maginally valid but I'm not
100% sure whom to blame :). So printk() code calls up() which calls
try_to_wake_up() under console_sem.lock spinlock. That function can take
rq->lock which is all expected.

The next part of the chain is that during CPU initialization we call
__sched_fork() with rq->lock which calls into hrtimer_init() which can
allocate memory which creates a dependency rq->lock => zone.lock.rlock.

And memory management code calls printk() which zone.lock.rlock held which
closes the loop. Now I suspect the second link in the chain can happen only
while CPU is booting and might even happen only if some debug options are
enabled. But I don't really know scheduler code well enough. Steven?

								Honza

> [  262.793172] ======================================================
> [  262.794555] [ INFO: possible circular locking dependency detected ]
> [  262.796110] 3.15.0-rc4-next-20140507-sasha-00004-g14be78b-dirty #448 Tainted: G        W
> [  262.798430] -------------------------------------------------------
> [  262.799804] runtrin.sh/9791 is trying to acquire lock:
> [  262.801168] ((console_sem).lock){-.-...}, at: down_trylock (kernel/locking/semaphore.c:137)
> [  262.801216]
> [  262.801216] but task is already holding lock:
> [  262.801216] (&(&zone->lock)->rlock){-.-...}, at: __offline_isolated_pages (mm/page_alloc.c:6427)
> [  262.801216]
> [  262.801216] which lock already depends on the new lock.
> [  262.801216]
> [  262.801216]
> [  262.801216] the existing dependency chain (in reverse order) is:
> [  262.801216]
> -> #3 (&(&zone->lock)->rlock){-.-...}:
> [  262.801216] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [  262.801216] _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
> [  262.801216] get_page_from_freelist (mm/page_alloc.c:1574 mm/page_alloc.c:2033)
> [  262.801216] __alloc_pages_nodemask (mm/page_alloc.c:2728)
> [  262.801216] alloc_page_interleave (mm/mempolicy.c:1944)
> [  262.801216] alloc_pages_current (mm/mempolicy.c:2041)
> [  262.801216] new_slab (include/linux/gfp.h:337 mm/slub.c:1327 mm/slub.c:1356 mm/slub.c:1418)
> [  262.801216] __slab_alloc (mm/slub.c:2204 mm/slub.c:2364)
> [  262.801216] kmem_cache_alloc (mm/slub.c:2470 mm/slub.c:2481 mm/slub.c:2486)
> [  262.801216] __debug_object_init (lib/debugobjects.c:97 lib/debugobjects.c:311)
> [  262.801216] debug_object_init (lib/debugobjects.c:364)
> [  262.801216] hrtimer_init (kernel/hrtimer.c:437 include/linux/jump_label.h:105 include/trace/events/timer.h:130 kernel/hrtimer.c:482 kernel/hrtimer.c:1222)
> [  262.801216] __sched_fork (kernel/sched/core.c:1745)
> [  262.801216] init_idle (kernel/sched/core.c:4460)
> [  262.801216] fork_idle (kernel/fork.c:1565)
> [  262.801216] idle_threads_init (kernel/smpboot.c:54 kernel/smpboot.c:72)
> [  262.801216] smp_init (kernel/smp.c:535)
> [  262.801216] kernel_init_freeable (init/main.c:854 init/main.c:1007)
> [  262.801216] kernel_init (init/main.c:939)
> [  262.801216] ret_from_fork (arch/x86/kernel/entry_64.S:553)
> [  262.801216]
> -> #2 (&rq->lock){-.-.-.}:
> [  262.801216] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [  262.801216] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
> [  262.801216] wake_up_new_task (include/linux/sched.h:2873 kernel/sched/core.c:329 kernel/sched/core.c:2027)
> [  262.801216] do_fork (kernel/fork.c:1628)
> [  262.801216] kernel_thread (kernel/fork.c:1650)
> [  262.801216] rest_init (init/main.c:404)
> [  262.801216] start_kernel (init/main.c:683)
> [  262.801216] x86_64_start_reservations (arch/x86/kernel/head64.c:194)
> [  262.801216] x86_64_start_kernel (arch/x86/kernel/head64.c:183)
> [  262.801216]
> -> #1 (&p->pi_lock){-.-.-.}:
> [  262.801216] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [  262.801216] _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
> [  262.801216] try_to_wake_up (kernel/sched/core.c:1605)
> [  262.801216] wake_up_process (kernel/sched/core.c:1701 (discriminator 2))
> [  262.801216] __up.isra.0 (kernel/locking/semaphore.c:263)
> [  262.801216] up (kernel/locking/semaphore.c:186)
> [  262.801216] console_unlock (kernel/printk/printk.c:2230)
> [  262.801216] vprintk_emit (kernel/printk/printk.c:1746)
> [  262.801216] dev_vprintk_emit (drivers/base/core.c:2053 (discriminator 3))
> [  262.801216] dev_printk_emit (drivers/base/core.c:2068)
> [  262.801216] __dynamic_dev_dbg (lib/dynamic_debug.c:593)
> [  262.801216] pps_event (drivers/pps/kapi.c:204 (discriminator 1))
> [  262.801216] pps_ktimer_event (drivers/pps/clients/pps-ktimer.c:51)
> [  262.801216] call_timer_fn (kernel/timer.c:1140 include/linux/jump_label.h:105 include/trace/events/timer.h:106 kernel/timer.c:1141)
> [  262.801216] run_timer_softirq (include/linux/spinlock.h:328 kernel/timer.c:1213 kernel/timer.c:1403)
> [  262.801216] __do_softirq (kernel/softirq.c:269 include/linux/jump_label.h:105 include/trace/events/irq.h:126 kernel/softirq.c:270)
> [  262.801216] irq_exit (kernel/softirq.c:346 kernel/softirq.c:387)
> [  262.801216] smp_apic_timer_interrupt (arch/x86/include/asm/irq_regs.h:26 arch/x86/kernel/apic/apic.c:947)
> [  262.801216] apic_timer_interrupt (arch/x86/kernel/entry_64.S:1225)
> [  262.801216] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
> [  262.801216] arch_cpu_idle (arch/x86/kernel/process.c:302)
> [  262.801216] cpu_idle_loop (kernel/sched/idle.c:173 kernel/sched/idle.c:220)
> [  262.801216] cpu_startup_entry (??:?)
> [  262.801216] start_secondary (arch/x86/kernel/smpboot.c:274)
> [  262.801216]
> -> #0 ((console_sem).lock){-.-...}:
> [  262.801216] __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
> [  262.801216] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [  262.801216] _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
> [  262.801216] down_trylock (kernel/locking/semaphore.c:137)
> [  262.801216] __down_trylock_console_sem (kernel/printk/printk.c:108)
> [  262.801216] console_trylock (kernel/printk/printk.c:2070)
> [  262.801216] vprintk_emit (kernel/printk/printk.c:1445 kernel/printk/printk.c:1745)
> [  262.801216] printk (kernel/printk/printk.c:1813)
> [  262.801216] __offline_isolated_pages (mm/page_alloc.c:6450)
> [  262.801216] offline_isolated_pages_cb (mm/memory_hotplug.c:1415)
> [  262.801216] walk_system_ram_range (kernel/resource.c:389)
> [  262.801216] __offline_pages.constprop.22 (mm/memory_hotplug.c:1710)
> [  262.801216] offline_pages (mm/memory_hotplug.c:1756)
> [  262.801216] memory_subsys_offline (drivers/base/memory.c:267 drivers/base/memory.c:304)
> [  262.801216] device_offline (drivers/base/core.c:1429)
> [  262.801216] online_store (drivers/base/core.c:451 (discriminator 2))
> [  262.801216] dev_attr_store (drivers/base/core.c:138)
> [  262.801216] sysfs_kf_write (fs/sysfs/file.c:114)
> [  262.801216] kernfs_fop_write (fs/kernfs/file.c:295)
> [  262.801216] vfs_write (fs/read_write.c:532)
> [  262.801216] SyS_write (fs/read_write.c:584 fs/read_write.c:576)
> [  262.801216] tracesys (arch/x86/kernel/entry_64.S:746)
> [  262.801216]
> [  262.801216] other info that might help us debug this:
> [  262.801216]
> [  262.801216] Chain exists of:
> (console_sem).lock --> &rq->lock --> &(&zone->lock)->rlock
> 
> [  262.801216]  Possible unsafe locking scenario:
> [  262.801216]
> [  262.801216]        CPU0                    CPU1
> [  262.801216]        ----                    ----
> [  262.801216]   lock(&(&zone->lock)->rlock);
> [  262.801216]                                lock(&rq->lock);
> [  262.801216]                                lock(&(&zone->lock)->rlock);
> [  262.801216]   lock((console_sem).lock);
> [  262.801216]
> [  262.801216]  *** DEADLOCK ***
> [  262.801216]
> [  262.801216] 8 locks held by runtrin.sh/9791:
> [  262.801216] #0: (sb_writers#4){.+.+.+}, at: vfs_write (include/linux/fs.h:2252 fs/read_write.c:530)
> [  262.801216] #1: (&of->mutex){+.+.+.}, at: kernfs_fop_write (fs/kernfs/file.c:283)
> [  262.801216] #2: (s_active#28){.+.+.+}, at: kernfs_fop_write (fs/kernfs/file.c:283)
> [  262.801216] #3: (device_hotplug_lock){+.+.+.}, at: lock_device_hotplug_sysfs (drivers/base/core.c:67)
> [  262.801216] #4: (&dev->mutex){......}, at: device_offline (drivers/base/core.c:2128 drivers/base/core.c:1423)
> [  262.801216] #5: (mem_hotplug.lock){++++++}, at: mem_hotplug_begin (mm/memory_hotplug.c:107)
> [  262.801216] #6: (mem_hotplug.lock#2){+.+.+.}, at: mem_hotplug_begin (mm/memory_hotplug.c:113)
> [  262.801216] #7: (&(&zone->lock)->rlock){-.-...}, at: __offline_isolated_pages (mm/page_alloc.c:6427)
> [  262.801216]
> [  262.801216] stack backtrace:
> [  262.801216] CPU: 6 PID: 9791 Comm: runtrin.sh Tainted: G        W     3.15.0-rc4-next-20140507-sasha-00004-g14be78b-dirty #448
> [  262.801216]  ffffffff90d73c70 ffff8802c6c158c8 ffffffff8d539450 0000000000000004
> [  262.801216]  ffffffff90d6fe70 ffff8802c6c15918 ffffffff8d52bbe0 0000000000000008
> [  262.801216]  ffff8802c6c159a8 ffff8802c6c15918 ffff8802c879be78 ffff8802c879beb0
> [  262.801216] Call Trace:
> [  262.801216] dump_stack (lib/dump_stack.c:52)
> [  262.801216] print_circular_bug (kernel/locking/lockdep.c:1216)
> [  262.801216] __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
> [  262.801216] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
> [  262.801216] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [  262.801216] ? down_trylock (kernel/locking/semaphore.c:137)
> [  262.801216] ? _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:109 kernel/locking/spinlock.c:159)
> [  262.801216] _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
> [  262.801216] ? down_trylock (kernel/locking/semaphore.c:137)
> [  262.801216] down_trylock (kernel/locking/semaphore.c:137)
> [  262.801216] ? vprintk_emit (kernel/printk/printk.c:1445 kernel/printk/printk.c:1745)
> [  262.801216] __down_trylock_console_sem (kernel/printk/printk.c:108)
> [  262.801216] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  262.801216] console_trylock (kernel/printk/printk.c:2070)
> [  262.801216] vprintk_emit (kernel/printk/printk.c:1445 kernel/printk/printk.c:1745)
> [  262.801216] printk (kernel/printk/printk.c:1813)
> [  262.801216] ? __offline_isolated_pages (mm/page_alloc.c:6427)
> [  262.801216] __offline_isolated_pages (mm/page_alloc.c:6450)
> [  262.801216] offline_isolated_pages_cb (mm/memory_hotplug.c:1415)
> [  262.801216] walk_system_ram_range (kernel/resource.c:389)
> [  262.801216] ? check_pages_isolated_cb (mm/memory_hotplug.c:1412)
> [  262.801216] __offline_pages.constprop.22 (mm/memory_hotplug.c:1710)
> [  262.801216] ? mutex_lock_nested (arch/x86/include/asm/paravirt.h:809 kernel/locking/mutex.c:569 kernel/locking/mutex.c:587)
> [  262.801216] ? mutex_lock_nested (arch/x86/include/asm/preempt.h:98 kernel/locking/mutex.c:570 kernel/locking/mutex.c:587)
> [  262.801216] ? device_offline (drivers/base/core.c:2128 drivers/base/core.c:1423)
> [  262.801216] offline_pages (mm/memory_hotplug.c:1756)
> [  262.801216] memory_subsys_offline (drivers/base/memory.c:267 drivers/base/memory.c:304)
> [  262.801216] device_offline (drivers/base/core.c:1429)
> [  262.801216] online_store (drivers/base/core.c:451 (discriminator 2))
> [  262.801216] dev_attr_store (drivers/base/core.c:138)
> [  262.801216] sysfs_kf_write (fs/sysfs/file.c:114)
> [  262.801216] kernfs_fop_write (fs/kernfs/file.c:295)
> [  262.801216] vfs_write (fs/read_write.c:532)
> [  262.801216] SyS_write (fs/read_write.c:584 fs/read_write.c:576)
> [  262.801216] tracesys (arch/x86/kernel/entry_64.S:746)
> 
> 
> Thanks,
> Sasha
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
