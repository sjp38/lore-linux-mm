Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF8D56B0083
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 20:43:15 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wm4so372217obc.31
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 17:43:15 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id ns8si717423obc.35.2014.03.04.17.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 17:43:15 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 4 Mar 2014 18:43:14 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3429C3E40040
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 18:43:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s251hBmM10223912
	for <linux-mm@kvack.org>; Wed, 5 Mar 2014 02:43:11 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s251kfQs025816
	for <linux-mm@kvack.org>; Tue, 4 Mar 2014 18:46:42 -0700
Date: Tue, 4 Mar 2014 17:43:10 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU stalls when running out of memory on 3.14-rc4 w/ NFS and
 kernel threads priorities changed
Message-ID: <20140305014310.GC3334@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
 <1393980534.26794.147.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAGVrzcaekM51hme_tquaT6e22fV1_cocpn1kDUsYfFce=F+o4g@mail.gmail.com>
 <CAGVrzcbRycBy0w64R9pV=JG6M3aJeARbOnh-xRrumYzzVDgWGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGVrzcbRycBy0w64R9pV=JG6M3aJeARbOnh-xRrumYzzVDgWGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-nfs <linux-nfs@vger.kernel.org>, "trond.myklebust" <trond.myklebust@primarydata.com>, netdev <netdev@vger.kernel.org>

On Tue, Mar 04, 2014 at 05:16:27PM -0800, Florian Fainelli wrote:
> 2014-03-04 17:03 GMT-08:00 Florian Fainelli <f.fainelli@gmail.com>:
> > 2014-03-04 16:48 GMT-08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> >> On Tue, 2014-03-04 at 15:55 -0800, Florian Fainelli wrote:
> >>> Hi all,
> >>>
> >>> I am seeing the following RCU stalls messages appearing on an ARMv7
> >>> 4xCPUs system running 3.14-rc4:
> >>>
> >>> [   42.974327] INFO: rcu_sched detected stalls on CPUs/tasks:
> >>> [   42.979839]  (detected by 0, t=2102 jiffies, g=4294967082,
> >>> c=4294967081, q=516)
> >>> [   42.987169] INFO: Stall ended before state dump start
> >>>
> >>> this is happening under the following conditions:
> >>>
> >>> - the attached bumper.c binary alters various kernel thread priorities
> >>> based on the contents of bumpup.cfg and
> >>> - malloc_crazy is running from a NFS share
> >>> - malloc_crazy.c is running in a loop allocating chunks of memory but
> >>> never freeing it
> >>>
> >>> when the priorities are altered, instead of getting the OOM killer to
> >>> be invoked, the RCU stalls are happening. Taking NFS out of the
> >>> equation does not allow me to reproduce the problem even with the
> >>> priorities altered.
> >>>
> >>> This "problem" seems to have been there for quite a while now since I
> >>> was able to get 3.8.13 to trigger that bug as well, with a slightly
> >>> more detailed RCU debugging trace which points the finger at kswapd0.
> >>>
> >>> You should be able to get that reproduced under QEMU with the
> >>> Versatile Express platform emulating a Cortex A15 CPU and the attached
> >>> files.
> >>>
> >>> Any help or suggestions would be greatly appreciated. Thanks!
> >>
> >> Do you have a more complete trace, including stack traces ?
> >
> > Attatched is what I get out of SysRq-t, which is the only thing I have
> > (note that the kernel is built with CONFIG_RCU_CPU_STALL_INFO=y):
> 
> QEMU for Versatile Express w/ 2 CPUs yields something slightly
> different than the real HW platform this is happening with, but it
> does produce the RCU stall anyway:
> 
> [  125.762946] BUG: soft lockup - CPU#1 stuck for 53s! [malloc_crazy:91]

This soft-lockup condition can result in RCU CPU stall warnings.  Fix
the problem causing the soft lockup, and I bet that your RCU CPU stall
warnings go away.

							Thanx, Paul

> [  125.766841] Modules linked in:
> [  125.768389]
> [  125.769199] CPU: 1 PID: 91 Comm: malloc_crazy Not tainted 3.14.0-rc4 #39
> [  125.769883] task: edbded00 ti: c089c000 task.ti: c089c000
> [  125.771743] PC is at load_balance+0x4b0/0x760
> [  125.772069] LR is at cpumask_next_and+0x44/0x5c
> [  125.772387] pc : [<c004ff58>]    lr : [<c01db940>]    psr: 60000113
> [  125.772387] sp : c089db48  ip : 80000113  fp : edfd8cf4
> [  125.773128] r10: c0de871c  r9 : ed893840  r8 : 00000000
> [  125.773452] r7 : c0de8458  r6 : edfd8840  r5 : edfd8840  r4 : ed89389c
> [  125.773825] r3 : 000012d8  r2 : 80000113  r1 : 00000023  r0 : 00000000
> [  125.774332] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> [  125.774753] Control: 30c7387d  Table: 80835d40  DAC: 00000000
> [  125.775266] CPU: 1 PID: 91 Comm: malloc_test_bcm Not tainted 3.14.0-rc4 #39
> [  125.776392] [<c0015624>] (unwind_backtrace) from [<c00111a4>]
> (show_stack+0x10/0x14)
> [  125.777026] [<c00111a4>] (show_stack) from [<c04c1bd4>]
> (dump_stack+0x84/0x94)
> [  125.777429] [<c04c1bd4>] (dump_stack) from [<c007e7f0>]
> (watchdog_timer_fn+0x144/0x17c)
> [  125.777865] [<c007e7f0>] (watchdog_timer_fn) from [<c003f58c>]
> (__run_hrtimer.isra.32+0x54/0xe4)
> [  125.778333] [<c003f58c>] (__run_hrtimer.isra.32) from [<c003fea4>]
> (hrtimer_interrupt+0x11c/0x2d0)
> [  125.778814] [<c003fea4>] (hrtimer_interrupt) from [<c03c4f80>]
> (arch_timer_handler_virt+0x28/0x30)
> [  125.779297] [<c03c4f80>] (arch_timer_handler_virt) from
> [<c006280c>] (handle_percpu_devid_irq+0x6c/0x84)
> [  125.779734] [<c006280c>] (handle_percpu_devid_irq) from
> [<c005edec>] (generic_handle_irq+0x2c/0x3c)
> [  125.780145] [<c005edec>] (generic_handle_irq) from [<c000eb7c>]
> (handle_IRQ+0x40/0x90)
> [  125.780513] [<c000eb7c>] (handle_IRQ) from [<c0008568>]
> (gic_handle_irq+0x2c/0x5c)
> [  125.780867] [<c0008568>] (gic_handle_irq) from [<c0011d00>]
> (__irq_svc+0x40/0x50)
> [  125.781312] Exception stack(0xc089db00 to 0xc089db48)
> [  125.781787] db00: 00000000 00000023 80000113 000012d8 ed89389c
> edfd8840 edfd8840 c0de8458
> [  125.782234] db20: 00000000 ed893840 c0de871c edfd8cf4 80000113
> c089db48 c01db940 c004ff58
> [  125.782594] db40: 60000113 ffffffff
> [  125.782864] [<c0011d00>] (__irq_svc) from [<c004ff58>]
> (load_balance+0x4b0/0x760)
> [  125.783215] [<c004ff58>] (load_balance) from [<c005035c>]
> (rebalance_domains+0x154/0x284)
> [  125.783595] [<c005035c>] (rebalance_domains) from [<c00504c0>]
> (run_rebalance_domains+0x34/0x164)
> [  125.784000] [<c00504c0>] (run_rebalance_domains) from [<c0025aac>]
> (__do_softirq+0x110/0x24c)
> [  125.784388] [<c0025aac>] (__do_softirq) from [<c0025e6c>]
> (irq_exit+0xac/0xf4)
> [  125.784726] [<c0025e6c>] (irq_exit) from [<c000eb80>] (handle_IRQ+0x44/0x90)
> [  125.785059] [<c000eb80>] (handle_IRQ) from [<c0008568>]
> (gic_handle_irq+0x2c/0x5c)
> [  125.785412] [<c0008568>] (gic_handle_irq) from [<c0011d00>]
> (__irq_svc+0x40/0x50)
> [  125.785742] Exception stack(0xc089dcf8 to 0xc089dd40)
> [  125.785983] dce0:
>     ee4e38c0 00000000
> [  125.786360] dd00: 000200da 00000001 ee4e38a0 c0de2340 2d201000
> edfe3358 c05c0c18 00000001
> [  125.786737] dd20: c05c0c2c c0e1e180 00000000 c089dd40 c0086050
> c0086140 40000113 ffffffff
> [  125.787120] [<c0011d00>] (__irq_svc) from [<c0086140>]
> (get_page_from_freelist+0x2bc/0x638)
> [  125.787507] [<c0086140>] (get_page_from_freelist) from [<c0087018>]
> (__alloc_pages_nodemask+0x114/0x8f4)
> [  125.787949] [<c0087018>] (__alloc_pages_nodemask) from [<c00a20c8>]
> (handle_mm_fault+0x9f8/0xcdc)
> [  125.788357] [<c00a20c8>] (handle_mm_fault) from [<c001793c>]
> (do_page_fault+0x194/0x27c)
> [  125.788726] [<c001793c>] (do_page_fault) from [<c000844c>]
> (do_DataAbort+0x30/0x90)
> [  125.789080] [<c000844c>] (do_DataAbort) from [<c0011e34>]
> (__dabt_usr+0x34/0x40)
> [  125.789403] Exception stack(0xc089dfb0 to 0xc089dff8)
> [  125.789652] dfa0:                                     ae55e008
> 11111111 000dc000 ae582000
> [  125.790029] dfc0: be967d18 00000000 00008390 00000000 00000000
> 00000000 b6f29000 be967d04
> [  125.790404] dfe0: 11111111 be967ce8 00008550 b6e5ce48 20000010 ffffffff
> [  125.791282] BUG: soft lockup - CPU#0 stuck for 53s! [kworker/0:1:41]
> [  125.791710] Modules linked in:
> [  125.792046]
> [  125.792836] CPU: 0 PID: 41 Comm: kworker/0:1 Not tainted 3.14.0-rc4 #39
> [  125.793832] task: ed893840 ti: c0826000 task.ti: c0826000
> [  125.795257] PC is at finish_task_switch+0x40/0xec
> [  125.795562] LR is at __schedule+0x1fc/0x51c
> [  125.795856] pc : [<c0044724>]    lr : [<c04c3274>]    psr: 600f0013
> [  125.795856] sp : c0827ec8  ip : 00000000  fp : c0827edc
> [  125.796416] r10: eda56e00  r9 : c0deac28  r8 : 00000000
> [  125.796698] r7 : c0de871c  r6 : c0826020  r5 : ed893840  r4 : 00000001
> [  125.797028] r3 : eda56e00  r2 : 000012d7  r1 : ed854780  r0 : edfd8840
> [  125.797488] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
> Segment kernel
> [  125.797866] Control: 30c7387d  Table: 808353c0  DAC: fffffffd
> [  125.798321] CPU: 0 PID: 41 Comm: kworker/0:1 Not tainted 3.14.0-rc4 #39
> [  125.800604] [<c0015624>] (unwind_backtrace) from [<c00111a4>]
> (show_stack+0x10/0x14)
> [  125.801205] [<c00111a4>] (show_stack) from [<c04c1bd4>]
> (dump_stack+0x84/0x94)
> [  125.801786] [<c04c1bd4>] (dump_stack) from [<c007e7f0>]
> (watchdog_timer_fn+0x144/0x17c)
> [  125.802238] [<c007e7f0>] (watchdog_timer_fn) from [<c003f58c>]
> (__run_hrtimer.isra.32+0x54/0xe4)
> [  125.802679] [<c003f58c>] (__run_hrtimer.isra.32) from [<c003fea4>]
> (hrtimer_interrupt+0x11c/0x2d0)
> [  125.803108] [<c003fea4>] (hrtimer_interrupt) from [<c03c4f80>]
> (arch_timer_handler_virt+0x28/0x30)
> [  125.803530] [<c03c4f80>] (arch_timer_handler_virt) from
> [<c006280c>] (handle_percpu_devid_irq+0x6c/0x84)
> [  125.803965] [<c006280c>] (handle_percpu_devid_irq) from
> [<c005edec>] (generic_handle_irq+0x2c/0x3c)
> [  125.804380] [<c005edec>] (generic_handle_irq) from [<c000eb7c>]
> (handle_IRQ+0x40/0x90)
> [  125.804774] [<c000eb7c>] (handle_IRQ) from [<c0008568>]
> (gic_handle_irq+0x2c/0x5c)
> [  125.805181] [<c0008568>] (gic_handle_irq) from [<c0011d00>]
> (__irq_svc+0x40/0x50)
> [  125.805706] Exception stack(0xc0827e80 to 0xc0827ec8)
> [  125.806185] 7e80: edfd8840 ed854780 000012d7 eda56e00 00000001
> ed893840 c0826020 c0de871c
> [  125.806623] 7ea0: 00000000 c0deac28 eda56e00 c0827edc 00000000
> c0827ec8 c04c3274 c0044724
> [  125.807032] 7ec0: 600f0013 ffffffff
> [  125.807328] [<c0011d00>] (__irq_svc) from [<c0044724>]
> (finish_task_switch+0x40/0xec)
> [  125.807752] [<c0044724>] (finish_task_switch) from [<c04c3274>]
> (__schedule+0x1fc/0x51c)
> [  125.808175] [<c04c3274>] (__schedule) from [<c0037590>]
> (worker_thread+0x210/0x404)
> [  125.808570] [<c0037590>] (worker_thread) from [<c003cba0>]
> (kthread+0xd4/0xec)
> [  125.808952] [<c003cba0>] (kthread) from [<c000e338>]
> (ret_from_fork+0x14/0x3c)
> [  246.080014] INFO: rcu_sched detected stalls on CPUs/tasks:
> [  246.080611]  (detected by 0, t=6972 jiffies, g=4294967160,
> c=4294967159, q=127)
> [  246.081576] INFO: Stall ended before state dump start
> [  246.082510] BUG: soft lockup - CPU#1 stuck for 69s! [grep:93]
> [  246.082849] Modules linked in:
> [  246.083046]
> [  246.083179] CPU: 1 PID: 93 Comm: grep Not tainted 3.14.0-rc4 #39
> [  246.083548] task: edbdf480 ti: c09e6000 task.ti: c09e6000
> [  246.083897] PC is at rebalance_domains+0x0/0x284
> [  246.084154] LR is at run_rebalance_domains+0x34/0x164
> [  246.084430] pc : [<c0050208>]    lr : [<c00504c0>]    psr: 20000113
> [  246.084430] sp : c09e7ef8  ip : c0dde340  fp : 40000005
> [  246.084992] r10: 00000007  r9 : c0ddf840  r8 : c0ddf840
> [  246.085267] r7 : edfe0840  r6 : 00000100  r5 : c0de209c  r4 : 00000001
> [  246.085606] r3 : c005048c  r2 : 2d201000  r1 : 00000001  r0 : edfe0840
> [  246.085944] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> [  246.086315] Control: 30c7387d  Table: 808351c0  DAC: 00000000
> [  246.086626] CPU: 1 PID: 93 Comm: grep Not tainted 3.14.0-rc4 #39
> [  246.086992] [<c0015624>] (unwind_backtrace) from [<c00111a4>]
> (show_stack+0x10/0x14)
> [  246.087420] [<c00111a4>] (show_stack) from [<c04c1bd4>]
> (dump_stack+0x84/0x94)
> [  246.087825] [<c04c1bd4>] (dump_stack) from [<c007e7f0>]
> (watchdog_timer_fn+0x144/0x17c)
> [  246.088260] [<c007e7f0>] (watchdog_timer_fn) from [<c003f58c>]
> (__run_hrtimer.isra.32+0x54/0xe4)
> [  246.088726] [<c003f58c>] (__run_hrtimer.isra.32) from [<c003fea4>]
> (hrtimer_interrupt+0x11c/0x2d0)
> [  246.089190] [<c003fea4>] (hrtimer_interrupt) from [<c03c4f80>]
> (arch_timer_handler_virt+0x28/0x30)
> [  246.089670] [<c03c4f80>] (arch_timer_handler_virt) from
> [<c006280c>] (handle_percpu_devid_irq+0x6c/0x84)
> [  246.090155] [<c006280c>] (handle_percpu_devid_irq) from
> [<c005edec>] (generic_handle_irq+0x2c/0x3c)
> [  246.090822] [<c005edec>] (generic_handle_irq) from [<c000eb7c>]
> (handle_IRQ+0x40/0x90)
> [  246.091233] [<c000eb7c>] (handle_IRQ) from [<c0008568>]
> (gic_handle_irq+0x2c/0x5c)
> [  246.091631] [<c0008568>] (gic_handle_irq) from [<c0011d00>]
> (__irq_svc+0x40/0x50)
> [  246.092007] Exception stack(0xc09e7eb0 to 0xc09e7ef8)
> [  246.092291] 7ea0:                                     edfe0840
> 00000001 2d201000 c005048c
> [  246.092719] 7ec0: 00000001 c0de209c 00000100 edfe0840 c0ddf840
> c0ddf840 00000007 40000005
> [  246.093142] 7ee0: c0dde340 c09e7ef8 c00504c0 c0050208 20000113 ffffffff
> [  246.093647] [<c0011d00>] (__irq_svc) from [<c0050208>]
> (rebalance_domains+0x0/0x284)
> [  246.094422] [<c0050208>] (rebalance_domains) from [<c09e6028>] (0xc09e6028)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
