Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38F62280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 06:05:34 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n82so12517857oig.22
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 03:05:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u14si429020oie.167.2017.11.07.03.05.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 03:05:32 -0800 (PST)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to loadbalance console writes
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171102134515.6eef16de@gandalf.local.home>
	<201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
	<20171107014015.GA1822@jagdpanzerIV>
In-Reply-To: <20171107014015.GA1822@jagdpanzerIV>
Message-Id: <201711072005.HHD40129.LSFFOOFtVMQJOH@I-love.SAKURA.ne.jp>
Date: Tue, 7 Nov 2017 20:05:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky.work@gmail.com
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

Sergey Senozhatsky wrote:
> On (11/06/17 21:06), Tetsuo Handa wrote:
> > I tried your patch with warn_alloc() torture. It did not cause lockups.
> > But I felt that possibility of failing to flush last second messages (such
> > as SysRq-c or SysRq-b) to consoles has increased. Is this psychological?
> 
> do I understand it correctly that there are "lost messages"?

Messages that were not written to consoles.

It seems that due to warn_alloc() torture, messages added to logbuf by SysRq
were not printed. When printk() is storming, we can't expect last second
messages are printed to consoles.

> hm... wondering if this is a regression.

I wish that there is an API which allows waiting for printk() messages
to be flushed. That is, associate serial number to each printk() request,
and allow callers to know current serial number (i.e. number of messages
in the logbuf) and current completed number (i.e. number of messages written
to consoles) and compare like time_after(). That is.

  printk("Hello\n");
  printk("World\n");
  seq = get_printk_queued_seq();

and then

  while (get_printk_completed_seq() < seq)
    msleep(1); // if caller can wait unconditionally.

or

  while (get_printk_completed_seq() < seq && !fatal_signal_pending(current))
    msleep(1); // if caller can wait unless killed.

or

  now = jiffies;
  while (get_printk_completed_seq() < seq && time_before(jiffies, now + HZ))
    cpu_relax(); // if caller cannot schedule().

and so on, for watchdog kernel threads can try to wait for printk() to flush.



By the way, I got below lockdep splat. Too timing dependent to reproduce.
( http://I-love.SAKURA.ne.jp/tmp/serial-20171107.txt.xz )

[    8.631358] fbcon: svgadrmfb (fb0) is primary device
[    8.654303] Console: switching to colour frame buffer device 160x48
[    8.659706]
[    8.659707] ======================================================
[    8.659707] WARNING: possible circular locking dependency detected
[    8.659708] 4.14.0-rc8+ #312 Not tainted
[    8.659708] ------------------------------------------------------
[    8.659708] systemd-udevd/184 is trying to acquire lock:
[    8.659709]  (&(&par->dirty.lock)->rlock){....}, at: [<ffffffffc0212fe3>] vmw_fb_dirty_mark+0x33/0xf0 [vmwgfx]
[    8.659710]
[    8.659710] but task is already holding lock:
[    8.659711]  (console_owner){....}, at: [<ffffffff8d0d5c63>] console_unlock+0x173/0x5c0
[    8.659712]
[    8.659712] which lock already depends on the new lock.
[    8.659712]
[    8.659713]
[    8.659713] the existing dependency chain (in reverse order) is:
[    8.659713]
[    8.659713] -> #4 (console_owner){....}:
[    8.659715]        lock_acquire+0x6d/0x90
[    8.659715]        console_unlock+0x199/0x5c0
[    8.659715]        vprintk_emit+0x4e0/0x540
[    8.659715]        vprintk_default+0x1a/0x20
[    8.659716]        vprintk_func+0x22/0x60
[    8.659716]        printk+0x53/0x6a
[    8.659716]        start_kernel+0x6d/0x4c3
[    8.659717]        x86_64_start_reservations+0x24/0x26
[    8.659717]        x86_64_start_kernel+0x6f/0x72
[    8.659717]        verify_cpu+0x0/0xfb
[    8.659717]
[    8.659718] -> #3 (logbuf_lock){..-.}:
[    8.659719]        lock_acquire+0x6d/0x90
[    8.659719]        _raw_spin_lock+0x2c/0x40
[    8.659719]        vprintk_emit+0x7f/0x540
[    8.659720]        vprintk_deferred+0x1b/0x40
[    8.659720]        printk_deferred+0x53/0x6f
[    8.659720]        unwind_next_frame.part.6+0x1ed/0x200
[    8.659721]        unwind_next_frame+0x11/0x20
[    8.659721]        __save_stack_trace+0x7d/0xf0
[    8.659721]        save_stack_trace+0x16/0x20
[    8.659721]        set_track+0x6b/0x1a0
[    8.659722]        free_debug_processing+0xce/0x2aa
[    8.659722]        __slab_free+0x1eb/0x2c0
[    8.659722]        kmem_cache_free+0x19a/0x1e0
[    8.659723]        file_free_rcu+0x23/0x40
[    8.659723]        rcu_process_callbacks+0x2ed/0x5b0
[    8.659723]        __do_softirq+0xf2/0x21e
[    8.659724]        irq_exit+0xe7/0x100
[    8.659724]        smp_apic_timer_interrupt+0x56/0x90
[    8.659724]        apic_timer_interrupt+0xa7/0xb0
[    8.659724]        vmw_send_msg+0x91/0xc0 [vmwgfx]
[    8.659725]
[    8.659725] -> #2 (&(&n->list_lock)->rlock){-.-.}:
[    8.659726]        lock_acquire+0x6d/0x90
[    8.659726]        _raw_spin_lock+0x2c/0x40
[    8.659727]        get_partial_node.isra.87+0x44/0x2c0
[    8.659727]        ___slab_alloc+0x262/0x610
[    8.659727]        __slab_alloc+0x41/0x85
[    8.659727]        kmem_cache_alloc+0x18a/0x1d0
[    8.659728]        __debug_object_init+0x3e2/0x400
[    8.659728]        debug_object_activate+0x12d/0x200
[    8.659728]        add_timer+0x6f/0x1b0
[    8.659729]        __queue_delayed_work+0x5b/0xa0
[    8.659729]        queue_delayed_work_on+0x4f/0xa0
[    8.659729]        check_lifetime+0x194/0x2e0
[    8.659730]        process_one_work+0x1c1/0x3e0
[    8.659730]        worker_thread+0x45/0x3c0
[    8.659730]        kthread+0xff/0x140
[    8.659730]        ret_from_fork+0x2a/0x40
[    8.659731]
[    8.659731] -> #1 (&base->lock){..-.}:
[    8.659732]        lock_acquire+0x6d/0x90
[    8.659732]        _raw_spin_lock_irqsave+0x44/0x60
[    8.659732]        lock_timer_base+0x78/0xa0
[    8.659733]        add_timer+0x46/0x1b0
[    8.659733]        __queue_delayed_work+0x5b/0xa0
[    8.659733]        queue_delayed_work_on+0x4f/0xa0
[    8.659734]        vmw_fb_dirty_mark+0xe2/0xf0 [vmwgfx]
[    8.659734]        vmw_fb_set_par+0x361/0x5e0 [vmwgfx]
[    8.659734]        fbcon_init+0x4e6/0x570
[    8.659734]        visual_init+0xd1/0x130
[    8.659735]        do_bind_con_driver+0x132/0x300
[    8.659735]        do_take_over_console+0x101/0x170
[    8.659735]        do_fbcon_takeover+0x52/0xb0
[    8.659736]        fbcon_event_notify+0x604/0x750
[    8.659736]        notifier_call_chain+0x44/0x70
[    8.659736]        __blocking_notifier_call_chain+0x4e/0x70
[    8.659737]        blocking_notifier_call_chain+0x11/0x20
[    8.659737]        fb_notifier_call_chain+0x16/0x20
[    8.659737]        register_framebuffer+0x25d/0x350
[    8.659737]        vmw_fb_init+0x488/0x590 [vmwgfx]
[    8.659738]        vmw_driver_load+0x1065/0x1210 [vmwgfx]
[    8.659738]        drm_dev_register+0x145/0x1e0 [drm]
[    8.659738]        drm_get_pci_dev+0x9a/0x160 [drm]
[    8.659739]        vmw_probe+0x10/0x20 [vmwgfx]
[    8.659739]        local_pci_probe+0x40/0xa0
[    8.659739]        pci_device_probe+0x14f/0x1c0
[    8.659740]        driver_probe_device+0x2a1/0x460
[    8.659740]        __driver_attach+0xdc/0xe0
[    8.659740]        bus_for_each_dev+0x6e/0xc0
[    8.659740]        driver_attach+0x19/0x20
[    8.659741]        bus_add_driver+0x40/0x260
[    8.659741]        driver_register+0x5b/0xe0
[    8.659741]        __pci_register_driver+0x66/0x70
[    8.659742]        vmwgfx_init+0x28/0x1000 [vmwgfx]
[    8.659742]        do_one_initcall+0x4c/0x1a2
[    8.659742]        do_init_module+0x56/0x1f2
[    8.659743]        load_module+0x1148/0x1940
[    8.659743]        SYSC_finit_module+0xa9/0x100
[    8.659743]        SyS_finit_module+0x9/0x10
[    8.659743]        entry_SYSCALL_64_fastpath+0x1f/0xbe
[    8.659744]
[    8.659744] -> #0 (&(&par->dirty.lock)->rlock){....}:
[    8.659745]        __lock_acquire+0x12a8/0x1530
[    8.659745]        lock_acquire+0x6d/0x90
[    8.659746]        _raw_spin_lock_irqsave+0x44/0x60
[    8.659746]        vmw_fb_dirty_mark+0x33/0xf0 [vmwgfx]
[    8.659746]        vmw_fb_imageblit+0x2b/0x30 [vmwgfx]
[    8.659746]        soft_cursor+0x1ae/0x230
[    8.659747]        bit_cursor+0x5dd/0x610
[    8.659747]        fbcon_cursor+0x151/0x1c0
[    8.659747]        hide_cursor+0x23/0x90
[    8.659748]        vt_console_print+0x3ab/0x3e0
[    8.659748]        console_unlock+0x46c/0x5c0
[    8.659748]        register_framebuffer+0x273/0x350
[    8.659748]        vmw_fb_init+0x488/0x590 [vmwgfx]
[    8.659749]        vmw_driver_load+0x1065/0x1210 [vmwgfx]
[    8.659749]        drm_dev_register+0x145/0x1e0 [drm]
[    8.659749]        drm_get_pci_dev+0x9a/0x160 [drm]
[    8.659750]        vmw_probe+0x10/0x20 [vmwgfx]
[    8.659750]        local_pci_probe+0x40/0xa0
[    8.659750]        pci_device_probe+0x14f/0x1c0
[    8.659751]        driver_probe_device+0x2a1/0x460
[    8.659751]        __driver_attach+0xdc/0xe0
[    8.659751]        bus_for_each_dev+0x6e/0xc0
[    8.659752]        driver_attach+0x19/0x20
[    8.659752]        bus_add_driver+0x40/0x260
[    8.659752]        driver_register+0x5b/0xe0
[    8.659752]        __pci_register_driver+0x66/0x70
[    8.659753]        vmwgfx_init+0x28/0x1000 [vmwgfx]
[    8.659753]        do_one_initcall+0x4c/0x1a2
[    8.659753]        do_init_module+0x56/0x1f2
[    8.659754]        load_module+0x1148/0x1940
[    8.659754]        SYSC_finit_module+0xa9/0x100
[    8.659754]        SyS_finit_module+0x9/0x10
[    8.659755]        entry_SYSCALL_64_fastpath+0x1f/0xbe
[    8.659755]
[    8.659755] other info that might help us debug this:
[    8.659755]
[    8.659755] Chain exists of:
[    8.659756]   &(&par->dirty.lock)->rlock --> logbuf_lock --> console_owner
[    8.659757]
[    8.659757]  Possible unsafe locking scenario:
[    8.659758]
[    8.659758]        CPU0                    CPU1
[    8.659758]        ----                    ----
[    8.659758]   lock(console_owner);
[    8.659759]                                lock(logbuf_lock);
[    8.659760]                                lock(console_owner);
[    8.659761]   lock(&(&par->dirty.lock)->rlock);
[    8.659761]
[    8.659761]  *** DEADLOCK ***
[    8.659762]
[    8.659762] 7 locks held by systemd-udevd/184:
[    8.659762]  #0:  (&dev->mutex){....}, at: [<ffffffff8d46fbac>] __driver_attach+0x4c/0xe0
[    8.659763]  #1:  (&dev->mutex){....}, at: [<ffffffff8d46fbba>] __driver_attach+0x5a/0xe0
[    8.659764]  #2:  (drm_global_mutex){+.+.}, at: [<ffffffffc0144189>] drm_dev_register+0x29/0x1e0 [drm]
[    8.659765]  #3:  (registration_lock){+.+.}, at: [<ffffffff8d38d6a1>] register_framebuffer+0x31/0x350
[    8.659767]  #4:  (console_lock){+.+.}, at: [<ffffffff8d38d8ea>] register_framebuffer+0x27a/0x350
[    8.659768]  #5:  (console_owner){....}, at: [<ffffffff8d0d5c63>] console_unlock+0x173/0x5c0
[    8.659769]  #6:  (printing_lock){....}, at: [<ffffffff8d4226f1>] vt_console_print+0x71/0x3e0
[    8.659770]
[    8.659770] stack backtrace:
[    8.659770] CPU: 0 PID: 184 Comm: systemd-udevd Not tainted 4.14.0-rc8+ #312
[    8.659771] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[    8.659771] Call Trace:
[    8.659772]  dump_stack+0x85/0xc9
[    8.659772]  print_circular_bug.isra.40+0x1f9/0x207
[    8.659772]  __lock_acquire+0x12a8/0x1530
[    8.659772]  ? soft_cursor+0x1ae/0x230
[    8.659773]  lock_acquire+0x6d/0x90
[    8.659773]  ? vmw_fb_dirty_mark+0x33/0xf0 [vmwgfx]
[    8.659773]  _raw_spin_lock_irqsave+0x44/0x60
[    8.659774]  ? vmw_fb_dirty_mark+0x33/0xf0 [vmwgfx]
[    8.659774]  vmw_fb_dirty_mark+0x33/0xf0 [vmwgfx]
[    8.659774]  vmw_fb_imageblit+0x2b/0x30 [vmwgfx]
[    8.659774]  soft_cursor+0x1ae/0x230
[    8.659775]  bit_cursor+0x5dd/0x610
[    8.659775]  ? vsnprintf+0x221/0x580
[    8.659775]  fbcon_cursor+0x151/0x1c0
[    8.659776]  ? bit_clear+0x110/0x110
[    8.659776]  hide_cursor+0x23/0x90
[    8.659776]  vt_console_print+0x3ab/0x3e0
[    8.659776]  console_unlock+0x46c/0x5c0
[    8.659777]  ? console_unlock+0x173/0x5c0
[    8.659777]  register_framebuffer+0x273/0x350
[    8.659777]  vmw_fb_init+0x488/0x590 [vmwgfx]
[    8.659778]  vmw_driver_load+0x1065/0x1210 [vmwgfx]
[    8.659778]  drm_dev_register+0x145/0x1e0 [drm]
[    8.659778]  ? pci_enable_device_flags+0xe0/0x130
[    8.659778]  drm_get_pci_dev+0x9a/0x160 [drm]
[    8.659779]  vmw_probe+0x10/0x20 [vmwgfx]
[    8.659779]  local_pci_probe+0x40/0xa0
[    8.659779]  pci_device_probe+0x14f/0x1c0
[    8.659780]  driver_probe_device+0x2a1/0x460
[    8.659780]  __driver_attach+0xdc/0xe0
[    8.659780]  ? driver_probe_device+0x460/0x460
[    8.659780]  bus_for_each_dev+0x6e/0xc0
[    8.659781]  driver_attach+0x19/0x20
[    8.659781]  bus_add_driver+0x40/0x260
[    8.659781]  driver_register+0x5b/0xe0
[    8.659782]  __pci_register_driver+0x66/0x70
[    8.659782]  ? 0xffffffffc0249000
[    8.659782]  vmwgfx_init+0x28/0x1000 [vmwgfx]
[    8.659782]  ? 0xffffffffc0249000
[    8.659783]  do_one_initcall+0x4c/0x1a2
[    8.659783]  ? do_init_module+0x1d/0x1f2
[    8.659783]  ? kmem_cache_alloc+0x18a/0x1d0
[    8.659783]  do_init_module+0x56/0x1f2
[    8.659784]  load_module+0x1148/0x1940
[    8.659784]  ? __symbol_put+0x60/0x60
[    8.659784]  SYSC_finit_module+0xa9/0x100
[    8.659784]  SyS_finit_module+0x9/0x10
[    8.659785]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[    8.659785] RIP: 0033:0x7efea440f7f9
[    8.659785] RSP: 002b:00007fff881c9308 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
[    8.659786] RAX: ffffffffffffffda RBX: 00005640f0f495f0 RCX: 00007efea440f7f9
[    8.659787] RDX: 0000000000000000 RSI: 00007efea4d2c099 RDI: 0000000000000011
[    8.659787] RBP: 00007efea4d2c099
[    8.659788] Lost 2 message(s)!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
