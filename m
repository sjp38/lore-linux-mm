Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 981A36B0062
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:08:09 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 11 Jan 2012 23:38:06 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0BI81FP4239592
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 23:38:02 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0BI80vh011376
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 05:08:01 +1100
Message-ID: <4F0DCFFC.5040805@linux.vnet.ibm.com>
Date: Wed, 11 Jan 2012 23:37:56 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Several bugs in latest kernel
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Hi,
I was running the latest kernel and not doing anything in particular.
Eventually the machine locked up hard and due to my config setting
(panic on hard-lockup), I got a kernel panic.

Looks like there are several issues involved.

Here is the log:

[ 7314.423828] ------------[ cut here ]------------
[ 7314.427769] kernel BUG at mm/slab.c:3111!
[ 7314.427769] invalid opcode: 0000 [#1] SMP 
[ 7314.427769] CPU 3 
[ 7314.427769] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod bnx2 ioatdma tpm_tis tpm cdc_ether usbnet i2c_i801 iTCO_wdt mii i7core_edac i2c_core dca edac_core iTCO_vendor_support rtc_cmos tpm_bios shpchp pci_hotplug button pcspkr serio_raw sg uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 7314.427769] 
[ 7314.427769] Pid: 6699, comm: cron Tainted: G        W    3.2.0-0.0.0.28.36b5ec9-default #3 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 7314.427769] RIP: 0010:[<ffffffff8115bcf9>]  [<ffffffff8115bcf9>] cache_alloc_refill+0x1e9/0x290
[ 7314.427769] RSP: 0018:ffff8808c881bc48  EFLAGS: 00010046
[ 7314.427769] RAX: 000000000000000f RBX: ffff8808ca66b000 RCX: 0000000000000018
[ 7314.427769] RDX: ffff8808c7e2d040 RSI: ffff8808c8f60040 RDI: 0000000000000024
[ 7314.427769] RBP: ffff8808c881bc88 R08: ffff8808ff802510 R09: ffff8808ff802520
[ 7314.427769] R10: dead000000200200 R11: dead000000100100 R12: 0000000000000024
[ 7314.427769] R13: ffff8808ff800880 R14: ffff8808ff802500 R15: 0000000000000000
[ 7314.427769] FS:  00007fdcd8f54780(0000) GS:ffff8808ffcc0000(0000) knlGS:0000000000000000
[ 7314.427769] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7314.427769] CR2: ffffffffff600400 CR3: 00000008c6e95000 CR4: 00000000000006e0
[ 7314.427769] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 7314.427769] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 7314.427769] Process cron (pid: 6699, threadinfo ffff8808c881a000, task ffff8808c68a0380)
[ 7314.427769] Stack:
[ 7314.427769]  ffffffff81785cf1 00000000000412d0 ffff8808ff802540 ffff8808ff800880
[ 7314.427769]  ffff8808ff800880 0000000000000100 00000000000000d0 00000000000000d0
[ 7314.427769]  ffff8808c881bcd8 ffffffff8115c7e7 ffff8808c881bd26 ffffffff81230418
[ 7314.427769] Call Trace:
[ 7314.427769]  [<ffffffff8115c7e7>] __kmalloc+0x327/0x330
[ 7314.427769]  [<ffffffff81230418>] ? aa_get_name+0x58/0x100
[ 7314.427769]  [<ffffffff81230418>] aa_get_name+0x58/0x100
[ 7314.427769]  [<ffffffff8120c229>] ? cap_bprm_set_creds+0x239/0x2a0
[ 7314.427769]  [<ffffffff81230d92>] apparmor_bprm_set_creds+0x112/0x580
[ 7314.427769]  [<ffffffff8109b44e>] ? __lock_release+0x7e/0x170
[ 7314.427769]  [<ffffffff81131e2e>] ? might_fault+0x4e/0xa0
[ 7314.427769]  [<ffffffff8120cbae>] security_bprm_set_creds+0xe/0x10
[ 7314.427769]  [<ffffffff8117b48a>] prepare_binprm+0xca/0x140
[ 7314.427769]  [<ffffffff8117d624>] do_execve_common+0x204/0x320
[ 7314.427769]  [<ffffffff8117d7ca>] do_execve+0x3a/0x40
[ 7314.427769]  [<ffffffff8100b079>] sys_execve+0x49/0x70
[ 7314.427769]  [<ffffffff8149c0fc>] stub_execve+0x6c/0xc0
[ 7314.427769] Code: 08 49 89 76 10 eb a6 0f 1f 00 49 8b 76 20 41 c7 86 90 00 00 00 01 00 00 00 49 39 f1 74 97 8b 46 20 41 3b 45 18 0f 82 02 ff ff ff <0f> 0b eb fe 0f 1f 00 41 39 c4 41 89 c7 45 0f 46 fc e9 ab fe ff 
[ 7314.427769] RIP  [<ffffffff8115bcf9>] cache_alloc_refill+0x1e9/0x290
[ 7314.427769]  RSP <ffff8808c881bc48>
[ 7314.427769] ---[ end trace c15ebd724b0d27b5 ]---
[ 7314.427769] BUG: sleeping function called from invalid context at kernel/rwsem.c:21
[ 7314.427769] in_atomic(): 1, irqs_disabled(): 1, pid: 6699, name: cron
[ 7314.427769] INFO: lockdep is turned off.
[ 7314.427769] irq event stamp: 1056
[ 7314.427769] hardirqs last  enabled at (1055): [<ffffffff8115ca15>] kmem_cache_alloc+0x225/0x2d0
[ 7314.427769] hardirqs last disabled at (1056): [<ffffffff8115c567>] __kmalloc+0xa7/0x330
[ 7314.427769] softirqs last  enabled at (642): [<ffffffff8145e3d0>] unix_sock_destructor+0x80/0xf0
[ 7314.427769] softirqs last disabled at (640): [<ffffffff8145e3b9>] unix_sock_destructor+0x69/0xf0
[ 7314.427769] Pid: 6699, comm: cron Tainted: G      D W    3.2.0-0.0.0.28.36b5ec9-default #3
[ 7314.427769] Call Trace:
[ 7314.427769]  [<ffffffff81072992>] __might_sleep+0x152/0x1f0
[ 7314.427769]  [<ffffffff8149013f>] down_read+0x1f/0x60
[ 7314.427769]  [<ffffffff810550ff>] exit_signals+0x1f/0x140
[ 7314.427769]  [<ffffffff8106c411>] ? blocking_notifier_call_chain+0x11/0x20
[ 7314.427769]  [<ffffffff81042742>] do_exit+0xb2/0x480
[ 7314.427769]  [<ffffffff81493db4>] oops_end+0xe4/0xf0
[ 7314.427769]  [<ffffffff81005856>] die+0x56/0x90
[ 7314.427769]  [<ffffffff814937d8>] do_trap+0x148/0x160
[ 7314.427769]  [<ffffffff81496f91>] ? atomic_notifier_call_chain+0x11/0x20
[ 7314.427769]  [<ffffffff81003720>] do_invalid_op+0x90/0xb0
[ 7314.427769]  [<ffffffff8115bcf9>] ? cache_alloc_refill+0x1e9/0x290
[ 7314.427769]  [<ffffffff8109ad01>] ? __lock_acquire+0x301/0x520
[ 7314.427769]  [<ffffffff8127725d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 7314.427769]  [<ffffffff81492fe4>] ? restore_args+0x30/0x30
[ 7314.427769]  [<ffffffff8149ceeb>] invalid_op+0x1b/0x20
[ 7314.427769]  [<ffffffff8115bcf9>] ? cache_alloc_refill+0x1e9/0x290
[ 7314.427769]  [<ffffffff8115bb95>] ? cache_alloc_refill+0x85/0x290
[ 7314.427769]  [<ffffffff8115c7e7>] __kmalloc+0x327/0x330
[ 7314.427769]  [<ffffffff81230418>] ? aa_get_name+0x58/0x100
[ 7314.427769]  [<ffffffff81230418>] aa_get_name+0x58/0x100
[ 7314.427769]  [<ffffffff8120c229>] ? cap_bprm_set_creds+0x239/0x2a0
[ 7314.427769]  [<ffffffff81230d92>] apparmor_bprm_set_creds+0x112/0x580
[ 7314.427769]  [<ffffffff8109b44e>] ? __lock_release+0x7e/0x170
[ 7314.427769]  [<ffffffff81131e2e>] ? might_fault+0x4e/0xa0
[ 7314.427769]  [<ffffffff8120cbae>] security_bprm_set_creds+0xe/0x10
[ 7314.427769]  [<ffffffff8117b48a>] prepare_binprm+0xca/0x140
[ 7314.427769]  [<ffffffff8117d624>] do_execve_common+0x204/0x320
[ 7314.427769]  [<ffffffff8117d7ca>] do_execve+0x3a/0x40
[ 7314.427769]  [<ffffffff8100b079>] sys_execve+0x49/0x70
[ 7314.427769]  [<ffffffff8149c0fc>] stub_execve+0x6c/0xc0
[ 7314.427769] note: cron[6699] exited with preempt_count 1
[ 7314.981405] BUG: scheduling while atomic: cron/6699/0x10000002
[ 7314.987495] INFO: lockdep is turned off.
[ 7314.987497] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod bnx2 ioatdma tpm_tis tpm cdc_ether usbnet i2c_i801 iTCO_wdt mii i7core_edac i2c_core dca edac_core iTCO_vendor_support rtc_cmos tpm_bios shpchp pci_hotplug button pcspkr serio_raw sg uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 7314.987531] Pid: 6699, comm: cron Tainted: G      D W    3.2.0-0.0.0.28.36b5ec9-default #3
[ 7314.987533] Call Trace:
[ 7314.987538]  [<ffffffff81073157>] __schedule_bug+0x97/0xa0
[ 7314.987542]  [<ffffffff814910b5>] __schedule+0x705/0x9a0
[ 7314.987546]  [<ffffffff81492c76>] ? _raw_spin_unlock+0x26/0x40
[ 7314.987550]  [<ffffffff811336c4>] ? zap_pte_range+0x84/0x3b0
[ 7314.987554]  [<ffffffff811337f5>] ? zap_pte_range+0x1b5/0x3b0
[ 7314.987559]  [<ffffffff81496ef6>] ? __atomic_notifier_call_chain+0xa6/0x130
[ 7314.987564]  [<ffffffff81078af5>] __cond_resched+0x25/0x40
[ 7314.987567]  [<ffffffff814913dd>] _cond_resched+0x2d/0x40
[ 7314.987571]  [<ffffffff811342ce>] unmap_page_range+0x25e/0x300
[ 7314.987575]  [<ffffffff8113443c>] unmap_vmas+0xcc/0x150
[ 7314.987580]  [<ffffffff81139dbd>] exit_mmap+0x8d/0x120
[ 7314.987584]  [<ffffffff8103ffba>] ? exit_mm+0xfa/0x140
[ 7314.987587]  [<ffffffff8103ac3c>] mmput+0x6c/0x150
[ 7314.987591]  [<ffffffff8103ffca>] exit_mm+0x10a/0x140
[ 7314.987594]  [<ffffffff81492bab>] ? _raw_spin_unlock_irq+0x2b/0x50
[ 7314.987599]  [<ffffffff8130f413>] ? tty_audit_exit+0x23/0xa0
[ 7314.987603]  [<ffffffff810427e3>] do_exit+0x153/0x480
[ 7314.987606]  [<ffffffff81493db4>] oops_end+0xe4/0xf0
[ 7314.987610]  [<ffffffff81005856>] die+0x56/0x90
[ 7314.987613]  [<ffffffff814937d8>] do_trap+0x148/0x160
[ 7314.987617]  [<ffffffff81496f91>] ? atomic_notifier_call_chain+0x11/0x20
[ 7314.987622]  [<ffffffff81003720>] do_invalid_op+0x90/0xb0
[ 7314.987626]  [<ffffffff8115bcf9>] ? cache_alloc_refill+0x1e9/0x290
[ 7314.987630]  [<ffffffff8109ad01>] ? __lock_acquire+0x301/0x520
[ 7314.987634]  [<ffffffff8127725d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 7314.987638]  [<ffffffff81492fe4>] ? restore_args+0x30/0x30
[ 7314.987641]  [<ffffffff8149ceeb>] invalid_op+0x1b/0x20
[ 7314.987646]  [<ffffffff8115bcf9>] ? cache_alloc_refill+0x1e9/0x290
[ 7314.987650]  [<ffffffff8115bb95>] ? cache_alloc_refill+0x85/0x290
[ 7314.987654]  [<ffffffff8115c7e7>] __kmalloc+0x327/0x330
[ 7314.987658]  [<ffffffff81230418>] ? aa_get_name+0x58/0x100
[ 7314.987661]  [<ffffffff81230418>] aa_get_name+0x58/0x100
[ 7314.987665]  [<ffffffff8120c229>] ? cap_bprm_set_creds+0x239/0x2a0
[ 7314.987669]  [<ffffffff81230d92>] apparmor_bprm_set_creds+0x112/0x580
[ 7314.987673]  [<ffffffff8109b44e>] ? __lock_release+0x7e/0x170
[ 7314.987677]  [<ffffffff81131e2e>] ? might_fault+0x4e/0xa0
[ 7314.987681]  [<ffffffff8120cbae>] security_bprm_set_creds+0xe/0x10
[ 7314.987685]  [<ffffffff8117b48a>] prepare_binprm+0xca/0x140
[ 7314.987689]  [<ffffffff8117d624>] do_execve_common+0x204/0x320
[ 7314.987694]  [<ffffffff8117d7ca>] do_execve+0x3a/0x40
[ 7314.987697]  [<ffffffff8100b079>] sys_execve+0x49/0x70
[ 7314.987701]  [<ffffffff8149c0fc>] stub_execve+0x6c/0xc0
[ 7320.364127] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 13
[ 7320.364127] Pid: 85, comm: kworker/13:1 Tainted: G      D W    3.2.0-0.0.0.28.36b5ec9-default #3
[ 7320.364127] Call Trace:
[ 7320.364127]  <NMI>  [<ffffffff8148ecce>] panic+0x9f/0x1e5
[ 7320.364127]  [<ffffffff8107b875>] ? sched_clock_local+0x25/0x90
[ 7320.364127]  [<ffffffff810d2101>] watchdog_overflow_callback+0xb1/0xc0
[ 7320.364127]  [<ffffffff811008e5>] __perf_event_overflow+0xa5/0x2d0
[ 7320.364127]  [<ffffffff811042dc>] ? perf_event_update_userpage+0x3c/0x280
[ 7320.364127]  [<ffffffff81012c0f>] ? x86_perf_event_set_period+0xdf/0x170
[ 7320.364127]  [<ffffffff81100cf4>] perf_event_overflow+0x14/0x20
[ 7320.364127]  [<ffffffff81017ba3>] intel_pmu_handle_irq+0x173/0x350
[ 7320.364127]  [<ffffffff81494999>] perf_event_nmi_handler+0x19/0x20
[ 7320.364127]  [<ffffffff81493f4e>] nmi_handle+0xbe/0x1d0
[ 7320.364127]  [<ffffffff81493edb>] ? nmi_handle+0x4b/0x1d0
[ 7320.364127]  [<ffffffff814940c3>] default_do_nmi+0x63/0x270
[ 7320.364127]  [<ffffffff81494378>] do_nmi+0xa8/0xc0
[ 7320.364127]  [<ffffffff81493510>] nmi+0x20/0x39
[ 7320.364127]  [<ffffffff8100a850>] ? read_persistent_clock+0x30/0x30
[ 7320.364127]  <<EOE>>  [<ffffffff81275e08>] ? delay_tsc+0x78/0xd0
[ 7320.364127]  [<ffffffff81275e8a>] __delay+0xa/0x10
[ 7320.364127]  [<ffffffff8127d5ab>] do_raw_spin_lock+0xab/0x150
[ 7320.364127]  [<ffffffff814922d4>] _raw_spin_lock+0x44/0x50
[ 7320.364127]  [<ffffffff8115d680>] ? __drain_alien_cache+0x60/0x100
[ 7320.364127]  [<ffffffff8115d680>] __drain_alien_cache+0x60/0x100
[ 7320.364127]  [<ffffffff8115e262>] cache_reap+0x172/0x260
[ 7320.364127]  [<ffffffff8105ebdb>] process_one_work+0x1fb/0x4f0
[ 7320.364127]  [<ffffffff8105eb18>] ? process_one_work+0x138/0x4f0
[ 7320.364127]  [<ffffffff8105f970>] ? worker_thread+0x60/0x420
[ 7320.364127]  [<ffffffff8115e0f0>] ? drain_freelist+0xd0/0xd0
[ 7320.364127]  [<ffffffff8105fa93>] worker_thread+0x183/0x420
[ 7320.364127]  [<ffffffff8105f910>] ? manage_workers+0x120/0x120
[ 7320.364127]  [<ffffffff81064fee>] kthread+0x9e/0xb0
[ 7320.364127]  [<ffffffff8149d074>] kernel_thread_helper+0x4/0x10
[ 7320.364127]  [<ffffffff81492fb4>] ? retint_restore_args+0x13/0x13
[ 7320.364127]  [<ffffffff81064f50>] ? __init_kthread_worker+0x70/0x70
[ 7320.364127]  [<ffffffff8149d070>] ? gs_change+0x13/0x13


Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
