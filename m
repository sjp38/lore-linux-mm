Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 107796B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:14:37 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id x13so5119713qcv.22
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:14:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si2528919qas.50.2014.09.25.07.14.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 07:14:36 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:14:25 -0400
From: Dave Jones <davej@redhat.com>
Subject: watchdog kicked in while shrinking inactive list.
Message-ID: <20140925141425.GA21702@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, fweisbec@gmail.com

Got this on a box that had been fuzzing for 12 hours or so.
There's also some timer stuff going on htere, so cc'ing the usual suspects.

Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 3
CPU: 3 PID: 16759 Comm: trinity-c25 Not tainted 3.17.0-rc6+ #59
 0000000000000000 00000000ff743b71 ffff880244e06c00 ffffffffa1818ac4
 ffffffffa1c633c0 ffff880244e06c80 ffffffffa18130a3 ffff880200000010
 ffff880244e06c90 ffff880244e06c30 00000000ff743b71 ffffffffa117ead5
Call Trace:
 <NMI>  [<ffffffffa1818ac4>] dump_stack+0x4e/0x7a
 [<ffffffffa18130a3>] panic+0xd7/0x20a
 [<ffffffffa117ead5>] ? __perf_event_header__init_id+0xe5/0xf0
 [<ffffffffa1146220>] ? restart_watchdog_hrtimer+0x50/0x50
 [<ffffffffa1146338>] watchdog_overflow_callback+0x118/0x120
 [<ffffffffa118792c>] __perf_event_overflow+0xac/0x350
 [<ffffffffa1019ece>] ? x86_perf_event_set_period+0xde/0x150
 [<ffffffffa1188844>] perf_event_overflow+0x14/0x20
 [<ffffffffa101fc26>] intel_pmu_handle_irq+0x206/0x410
 [<ffffffffa1018d2b>] perf_event_nmi_handler+0x2b/0x50
 [<ffffffffa1007752>] nmi_handle+0xd2/0x3b0
 [<ffffffffa1007685>] ? nmi_handle+0x5/0x3b0
 [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
 [<ffffffffa1007c62>] default_do_nmi+0x72/0x1c0
 [<ffffffffa1007e68>] do_nmi+0xb8/0xf0
 [<ffffffffa18268aa>] end_repeat_nmi+0x1e/0x2e
 [<ffffffffa10f95f8>] ? hrtimer_try_to_cancel+0x58/0x1f0
 [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
 [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
 [<ffffffffa10f95f8>] ? hrtimer_try_to_cancel+0x58/0x1f0
 [<ffffffffa10d103d>] ? lock_release+0x1d/0x300
 <<EOE>>  <IRQ>  [<ffffffffa1823ac4>] _raw_spin_unlock_irqrestore+0x24/0x70
 [<ffffffffa10f95f8>] hrtimer_try_to_cancel+0x58/0x1f0
 [<ffffffffa10f97aa>] hrtimer_cancel+0x1a/0x30
 [<ffffffffa110a0e7>] tick_nohz_restart+0x17/0x90
 [<ffffffffa110af38>] __tick_nohz_full_check+0xc8/0xe0
 [<ffffffffa110af5e>] nohz_full_kick_work_func+0xe/0x10
 [<ffffffffa117c9bf>] irq_work_run_list+0x4f/0x70
 [<ffffffffa117ca0a>] irq_work_run+0x2a/0x60
 [<ffffffffa10f82eb>] update_process_times+0x5b/0x70
 [<ffffffffa1109dc5>] tick_sched_handle.isra.21+0x25/0x60
 [<ffffffffa110a0b1>] tick_sched_timer+0x41/0x60
 [<ffffffffa10f8c71>] __run_hrtimer+0x81/0x480
 [<ffffffffa110a070>] ? tick_sched_do_timer+0x90/0x90
 [<ffffffffa10f9b27>] hrtimer_interrupt+0x107/0x260
 [<ffffffffa10331a4>] local_apic_timer_interrupt+0x34/0x60
 [<ffffffffa182734f>] smp_apic_timer_interrupt+0x3f/0x60
 [<ffffffffa182576f>] apic_timer_interrupt+0x6f/0x80
 <EOI>  [<ffffffffa1823b42>] ? _raw_spin_unlock_irq+0x32/0x60
 [<ffffffffa11a795b>] shrink_inactive_list+0x1cb/0x620
 [<ffffffffa11a8663>] shrink_lruvec+0x563/0x6b0
 [<ffffffffa119720f>] ? zone_watermark_ok+0x1f/0x30
 [<ffffffffa11a87fe>] shrink_zone+0x4e/0x130
 [<ffffffffa11a905f>] shrink_zones.constprop.63+0x20f/0x410
 [<ffffffffa11a93bb>] try_to_free_pages+0x15b/0x3e0
 [<ffffffffa119bacb>] __alloc_pages_nodemask+0x7eb/0xc20
 [<ffffffffa11e3756>] alloc_pages_current+0x106/0x1e0
 [<ffffffffa11ec905>] ? new_slab+0x2b5/0x390
 [<ffffffffa11ec905>] new_slab+0x2b5/0x390
 [<ffffffffa1817152>] __slab_alloc+0x348/0x56f
 [<ffffffffa11f2116>] ? kmem_cache_alloc+0x256/0x330
 [<ffffffffa16b31dd>] ? sock_alloc_inode+0x1d/0xc0
 [<ffffffffa10cb687>] ? __lock_is_held+0x57/0x80
 [<ffffffffa16b31dd>] ? sock_alloc_inode+0x1d/0xc0
 [<ffffffffa11f2116>] kmem_cache_alloc+0x256/0x330
 [<ffffffffa16b31dd>] sock_alloc_inode+0x1d/0xc0
 [<ffffffffa1223c4d>] alloc_inode+0x1d/0xa0
 [<ffffffffa1225df1>] new_inode_pseudo+0x11/0x60
 [<ffffffffa16b2dac>] sock_alloc+0x1c/0x90
 [<ffffffffa16b3c4d>] sock_create_lite+0x4d/0x90
 [<ffffffffa1709d71>] __netlink_kernel_create+0x71/0x280
 [<ffffffffa16ed337>] diag_net_init+0x47/0x80
 [<ffffffffa16ed2b0>] ? diag_net_exit+0x30/0x30
 [<ffffffffa16c85f1>] ops_init+0x41/0x190
 [<ffffffffa16c87c3>] setup_net+0x83/0x140
 [<ffffffffa16c8d7e>] copy_net_ns+0x7e/0x130
 [<ffffffffa109f279>] create_new_namespaces+0xf9/0x190
 [<ffffffffa109f5fa>] unshare_nsproxy_namespaces+0x5a/0xc0
 [<ffffffffa1077883>] SyS_unshare+0x173/0x330
 [<ffffffffa1824a24>] tracesys+0xdd/0xe2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
