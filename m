Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3F336002CC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 08:08:59 -0400 (EDT)
Date: Wed, 26 May 2010 14:08:55 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526120855.GA30912@lst.de>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526114950.GK23411@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 01:49:50PM +0200, Jens Axboe wrote:
> Oops yes, you need to revert the parent too. But nevermind, I think I
> see the issue. Can you try the below (go back to -git again)?

This one crashes during mount of the first XFS fs in a really strange
way:

[   44.897741] XFS mounting filesystem vdb6
[   45.188094] BUG: unable to handle kernel paging request at 6b6b6b6b
[   45.190150] IP: [<6b6b6b6b>] 0x6b6b6b6b
[   45.191531] *pde = 00000000 
[   45.192055] Oops: 0010 [#1] SMP 
[   45.192055] last sysfs file: /sys/devices/virtual/net/lo/operstate
[   45.192055] Modules linked in:
[   45.192055] 
[   45.192055] Pid: 1216, comm: udevd Not tainted 2.6.34 #123 /Bochs
[   45.192055] EIP: 0060:[<6b6b6b6b>] EFLAGS: 00010202 CPU: 0
[   45.192055] EIP is at 0x6b6b6b6b
[   45.192055] EAX: f5c501e8 EBX: c2144120 ECX: 00000000 EDX: f5c501e8
[   45.192055] ESI: f3ebbe9c EDI: 00000001 EBP: f6fdfab0 ESP: f6fdfa8c
[   45.192055]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   45.192055] Process udevd (pid: 1216, ti=f6fde000 task=f6fe2d70
task.ti=f6fde000)
[   45.192055] Stack:
[   45.192055]  c01b3e0c 00000296 f6fe2d70 f3ebbe9c c2144138 c0c50e00
00000001 00000024
[   45.192055] <0> 00000009 f6fdfab8 c01b4060 f6fdfb00 c016a828 c01862a4
856a5530 0000000a
[   45.192055] <0> 856aedde 0000000a c2003f84 c0c2ea24 0000000a 00000000
0000000a 00000000
[   45.192055] Call Trace:
[   45.192055]  [<c01b3e0c>] ? __rcu_process_callbacks+0x10c/0x340
[   45.192055]  [<c01b4060>] ? rcu_process_callbacks+0x20/0x40
[   45.192055]  [<c016a828>] ? __do_softirq+0x98/0x1c0
[   45.192055]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.192055]  [<c016a9b5>] ? do_softirq+0x65/0x70
[   45.192055]  [<c016ab3d>] ? irq_exit+0x6d/0x80
[   45.192055]  [<c01467c6>] ? smp_apic_timer_interrupt+0x56/0x90
[   45.192055]  [<c06c06a4>] ? trace_hardirqs_off_thunk+0xc/0x18
[   45.192055]  [<c08ff5ef>] ? apic_timer_interrupt+0x2f/0x34
[   45.192055]  [<c0196aaa>] ? lock_release+0xca/0x220
[   45.192055]  [<c08fef66>] ? _raw_spin_unlock+0x16/0x20
[   45.192055]  [<c088a551>] ? unix_peer_get+0x31/0x40
[   45.192055]  [<c088b527>] ? unix_dgram_poll+0xd7/0x160
[   45.192055]  [<c080d582>] ? sock_poll+0x12/0x20
[   45.192055]  [<c0215d53>] ? do_sys_poll+0x223/0x480
[   45.192055]  [<c0215a00>] ? __pollwait+0x0/0xd0
[   45.192055]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.192055]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.192055]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.192055]  [<c0135898>] ? sched_clock+0x8/0x10
[   45.192055]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.192055]  [<c01864a9>] ? sched_clock_cpu+0x129/0x180
[   45.192055]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.192055]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.192055]  [<c014e5f7>] ? kvm_clock_read+0x17/0x20
[   45.192055]  [<c0135898>] ? sched_clock+0x8/0x10
[   45.192055]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.192055]  [<c01864a9>] ? sched_clock_cpu+0x129/0x180
[   45.192055]  [<c01955c3>] ? __lock_acquire+0x2f3/0x1310
[   45.192055]  [<c019162b>] ? trace_hardirqs_off+0xb/0x10
[   45.192055]  [<c018656d>] ? cpu_clock+0x6d/0x70
[   45.192055]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.192055]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.192055]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.192055]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.192055]  [<c014e5f7>] ? kvm_clock_read+0x17/0x20
[   45.192055]  [<c01898cb>] ? ktime_get_ts+0xdb/0x110
[   45.192055]  [<c0215234>] ? poll_select_set_timeout+0x64/0x70
[   45.192055]  [<c0216124>] ? sys_poll+0x54/0xb0
[   45.192055]  [<c013075c>] ? sysenter_do_call+0x12/0x3c
[   45.192055] Code:  Bad EIP value.
[   45.192055] EIP: [<6b6b6b6b>] 0x6b6b6b6b SS:ESP 0068:f6fdfa8c
[   45.192055] CR2: 000000006b6b6b6b
[   45.290509] ---[ end trace 09bdcdca6b9734ca ]---
[   45.291988] Kernel panic - not syncing: Fatal exception in interrupt
[   45.293915] Pid: 1216, comm: udevd Tainted: G      D     2.6.34 #123
[   45.295793] Call Trace:
[   45.296864]  [<c08fc07d>] ? printk+0x28/0x2a
[   45.298206]  [<c08fbfd8>] panic+0x42/0xbf
[   45.299515]  [<c09002f5>] oops_end+0xc5/0xd0
[   45.300972]  [<c015051e>] no_context+0xbe/0x150
[   45.302375]  [<c0150640>] __bad_area_nosemaphore+0x90/0x130
[   45.304218]  [<c0902196>] ? do_page_fault+0x226/0x430
[   45.305779]  [<c01506f2>] bad_area_nosemaphore+0x12/0x20
[   45.307345]  [<c09022f1>] do_page_fault+0x381/0x430
[   45.308949]  [<c018656d>] ? cpu_clock+0x6d/0x70
[   45.310344]  [<c08fef25>] ? _raw_spin_unlock_irqrestore+0x35/0x60
[   45.312154]  [<c0901f70>] ? do_page_fault+0x0/0x430
[   45.313663]  [<c08ff797>] error_code+0x6b/0x70
[   45.315095]  [<c0901f70>] ? do_page_fault+0x0/0x430
[   45.316690]  [<c01b3e0c>] ? __rcu_process_callbacks+0x10c/0x340
[   45.318380]  [<c01b4060>] rcu_process_callbacks+0x20/0x40
[   45.319999]  [<c016a828>] __do_softirq+0x98/0x1c0
[   45.321583]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.323300]  [<c016a9b5>] do_softirq+0x65/0x70
[   45.324809]  [<c016ab3d>] irq_exit+0x6d/0x80
[   45.326213]  [<c01467c6>] smp_apic_timer_interrupt+0x56/0x90
[   45.336186]  [<c06c06a4>] ? trace_hardirqs_off_thunk+0xc/0x18
[   45.337865]  [<c08ff5ef>] apic_timer_interrupt+0x2f/0x34
[   45.339440]  [<c0196aaa>] ? lock_release+0xca/0x220
[   45.341016]  [<c08fef66>] _raw_spin_unlock+0x16/0x20
[   45.342623]  [<c088a551>] unix_peer_get+0x31/0x40
[   45.344207]  [<c088b527>] unix_dgram_poll+0xd7/0x160
[   45.345741]  [<c080d582>] sock_poll+0x12/0x20
[   45.347107]  [<c0215d53>] do_sys_poll+0x223/0x480
[   45.348694]  [<c0215a00>] ? __pollwait+0x0/0xd0
[   45.350108]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.351504]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.352963]  [<c0215ad0>] ? pollwake+0x0/0x60
[   45.354335]  [<c0135898>] ? sched_clock+0x8/0x10
[   45.355835]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.357514]  [<c01864a9>] ? sched_clock_cpu+0x129/0x180
[   45.359075]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.360894]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.362683]  [<c014e5f7>] ? kvm_clock_read+0x17/0x20
[   45.364486]  [<c0135898>] ? sched_clock+0x8/0x10
[   45.365935]  [<c01862a4>] ? sched_clock_local+0xa4/0x180
[   45.367566]  [<c01864a9>] ? sched_clock_cpu+0x129/0x180
[   45.370936]  [<c01955c3>] ? __lock_acquire+0x2f3/0x1310
[   45.372679]  [<c019162b>] ? trace_hardirqs_off+0xb/0x10
[   45.374250]  [<c018656d>] ? cpu_clock+0x6d/0x70
[   45.375722]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.377291]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.378802]  [<c01e8936>] ? might_fault+0x46/0xa0
[   45.380367]  [<c014f1f5>] ? pvclock_clocksource_read+0xf5/0x190
[   45.382137]  [<c014e5f7>] ? kvm_clock_read+0x17/0x20
[   45.383851]  [<c01898cb>] ? ktime_get_ts+0xdb/0x110
[   45.385464]  [<c0215234>] ? poll_select_set_timeout+0x64/0x70
[   45.387150]  [<c0216124>] sys_poll+0x54/0xb0
[   45.388611]  [<c013075c>] sysenter_do_call+0x12/0x3c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
