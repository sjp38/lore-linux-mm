Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id D04746B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:07:04 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 9so9708034ykp.1
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 19:07:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e5si21528625yhd.104.2014.04.15.19.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 19:07:03 -0700 (PDT)
Message-ID: <534DE5C0.2000408@oracle.com>
Date: Tue, 15 Apr 2014 22:06:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: hangs in collapse_huge_page
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi all,

I often see hung task triggering in khugepaged within collapse_huge_page().

I've initially assumed the case may be that the guests are too loaded and
the warning occurs because of load, but after increasing the timeout to
1200 sec I still see the warning.

Here's what I get in the log, up to the point the guest reboots:

[ 2406.651012] INFO: task khugepaged:3562 blocked for more than 1200 seconds.
[ 2406.653331]       Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.656549] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2406.662008] khugepaged      D ffff88019fa1e4b8  5408  3562      2 0x00000000
[ 2406.663773]  ffff8803d6afbb08 0000000000000002 ffffffffb056e740 ffff8803d6b28000
[ 2406.666549]  ffff8803d6afbfd8 00000000001d79c0 00000000001d79c0 00000000001d79c0
[ 2406.669558]  ffff88019fac8000 ffff8803d6b28000 ffff8803d6afbaf8 ffff8803d6b28000
[ 2406.673316] Call Trace:
[ 2406.676062] ? _raw_spin_unlock_irq (arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[ 2406.678384] schedule (kernel/sched/core.c:2750)
[ 2406.680418] rwsem_down_write_failed (kernel/locking/rwsem-xadd.c:240)
[ 2406.683053] ? get_parent_ip (kernel/sched/core.c:2472)
[ 2406.684950] call_rwsem_down_write_failed (arch/x86/lib/rwsem.S:106)
[ 2406.686998] ? khugepaged_do_scan (arch/x86/include/asm/atomic.h:26 mm/huge_memory.c:1989 mm/huge_memory.c:2591 mm/huge_memory.c:2709)
[ 2406.689314] ? lock_contended (kernel/locking/lockdep.c:3734 kernel/locking/lockdep.c:3812)
[ 2406.691611] ? down_write (kernel/locking/rwsem.c:50 (discriminator 2))
[ 2406.693657] ? collapse_huge_page.isra.30 (arch/x86/include/asm/atomic.h:26 mm/huge_memory.c:1989 mm/huge_memory.c:2378)
[ 2406.696508] collapse_huge_page.isra.30 (arch/x86/include/asm/atomic.h:26 mm/huge_memory.c:1989 mm/huge_memory.c:2378)
[ 2406.699123] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 2406.701570] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 2406.704058] ? khugepaged_do_scan (include/linux/spinlock.h:343 mm/huge_memory.c:2533 mm/huge_memory.c:2629 mm/huge_memory.c:2709)
[ 2406.706517] ? get_parent_ip (kernel/sched/core.c:2472)
[ 2406.708746] khugepaged_do_scan (mm/huge_memory.c:2633 mm/huge_memory.c:2709)
[ 2406.711252] khugepaged (include/linux/freezer.h:64 mm/huge_memory.c:2722 mm/huge_memory.c:2747)
[ 2406.713333] ? bit_waitqueue (kernel/sched/wait.c:291)
[ 2406.715703] ? khugepaged_do_scan (mm/huge_memory.c:2739)
[ 2406.718031] kthread (kernel/kthread.c:210)
[ 2406.720004] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.722590] ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 2406.724780] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.727349] 1 lock held by khugepaged/3562:
[ 2406.728975] #0: (&mm->mmap_sem){++++++}, at: collapse_huge_page.isra.30 (arch/x86/include/asm/atomic.h:26 mm/huge_memory.c:1989 mm/huge_memory.c:2378)
[ 2406.733683] BUG: using __this_cpu_write() in preemptible [00000000] code: khungtaskd/3540
[ 2406.735837] caller is __this_cpu_preempt_check+0x13/0x20
[ 2406.737191] CPU: 21 PID: 3540 Comm: khungtaskd Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.739790]  ffffffffb17b99f5 ffff880436b5bd58 ffffffffb05223a7 0000000000000007
[ 2406.741834]  0000000000000015 ffff880436b5bd88 ffffffffadb306d9 00000000000004b0
[ 2406.744275]  00000000003ffecf 00000000000002cf ffff8803d6b28000 ffff880436b5bd98
[ 2406.746446] Call Trace:
[ 2406.747118] dump_stack (lib/dump_stack.c:52)
[ 2406.748927] check_preemption_disabled (arch/x86/include/asm/preempt.h:80 lib/smp_processor_id.c:49)
[ 2406.750736] __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 2406.752708] touch_softlockup_watchdog (kernel/watchdog.c:142)
[ 2406.754405] touch_nmi_watchdog (kernel/watchdog.c:170)
[ 2406.756063] watchdog (kernel/hung_task.c:122 kernel/hung_task.c:180 kernel/hung_task.c:236)
[ 2406.757444] ? watchdog (include/linux/rcupdate.h:800 kernel/hung_task.c:169 kernel/hung_task.c:236)
[ 2406.759472] ? reset_hung_task_detector (kernel/hung_task.c:224)
[ 2406.766326] kthread (kernel/kthread.c:210)
[ 2406.769513] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.773602] ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 2406.776132] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.778998] sending NMI to all CPUs:
[ 2406.781135] NMI backtrace for cpu 21
[ 2406.783323] CPU: 21 PID: 3540 Comm: khungtaskd Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.789592] task: ffff880436a88000 ti: ffff880436b5a000 task.ti: ffff880436b5a000
[ 2406.790928] RIP: native_write_msr_safe (arch/x86/include/asm/msr.h:95)
[ 2406.790928] RSP: 0018:ffff880436b5bd28  EFLAGS: 00000082
[ 2406.790928] RAX: 0000000000000400 RBX: 0000000000000015 RCX: 0000000000000830
[ 2406.790928] RDX: 0000000000000015 RSI: 0000000000000400 RDI: 0000000000000830
[ 2406.790928] RBP: ffff880436b5bd28 R08: ffffffffb30bc580 R09: 0000000000000000
[ 2406.790928] R10: 0000000000000001 R11: 3a73555043206c6c R12: ffffffffb30bc580
[ 2406.790928] R13: 0000000000000015 R14: 0000000000080000 R15: 000000000000b022
[ 2406.790928] FS:  0000000000000000(0000) GS:ffff880467000000(0000) knlGS:0000000000000000
[ 2406.790928] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.790928] CR2: 00007f07ed23d099 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.790928] Stack:
[ 2406.790928]  ffff880436b5bd88 ffffffffad0b3ac2 ffff880436b5bd98 0000000000000282
[ 2406.790928]  0000000000000002 0000000200000008 ffff880436b5bda8 0000000000002710
[ 2406.790928]  00000000003ffecf 00000000000002cf ffff8803d6b28000 ffff8803d6b28000
[ 2406.790928] Call Trace:
[ 2406.790928] __x2apic_send_IPI_mask (arch/x86/include/asm/paravirt.h:133 arch/x86/include/asm/apic.h:169 arch/x86/include/asm/x2apic.h:26 arch/x86/kernel/apic/x2apic_phys.c:52)
[ 2406.790928] x2apic_send_IPI_all (arch/x86/kernel/apic/x2apic_phys.c:77)
[ 2406.790928] arch_trigger_all_cpu_backtrace (include/linux/bitmap.h:265 include/linux/cpumask.h:443 arch/x86/kernel/apic/hw_nmi.c:54)
[ 2406.790928] watchdog (kernel/hung_task.c:124 kernel/hung_task.c:180 kernel/hung_task.c:236)
[ 2406.790928] ? watchdog (include/linux/rcupdate.h:800 kernel/hung_task.c:169 kernel/hung_task.c:236)
[ 2406.790928] ? reset_hung_task_detector (kernel/hung_task.c:224)
[ 2406.790928] kthread (kernel/kthread.c:210)
[ 2406.790928] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.790928] ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 2406.790928] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2406.790928] Code: 00 55 89 f9 48 89 e5 0f 32 31 ff 89 c0 48 c1 e2 20 89 3e 48 09 c2 5d 48 89 d0 c3 66 0f 1f 44 00 00 55 89 f0 89 f9 48 89 e5 0f 30 <31> c0 5d c3 66 90 55 89 f9 48 89 e5 0f 33 89 c0 48 c1 e2 20 5d
[ 2406.732546] NMI backtrace for cpu 2
[ 2406.790928] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 129.351 msecs
[ 2406.732546] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.732546] task: ffff8801ee8f8000 ti: ffff88002ad6e000 task.ti: ffff88002ad6e000
[ 2406.732546] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.732546] RSP: 0018:ffff88002ad6fe28  EFLAGS: 00000282
[ 2406.732546] RAX: ffff8801ee8f8000 RBX: ffff88002ad6ffd8 RCX: 0000000000000000
[ 2406.732546] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.732546] RBP: ffff88002ad6fe28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.732546] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.732546] R13: ffff88002ad6e000 R14: ffffffffb30bc580 R15: ffff88002ad6ffd8
[ 2406.732546] FS:  0000000000000000(0000) GS:ffff880095000000(0000) knlGS:0000000000000000
[ 2406.732546] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.732546] CR2: 00007f026359f170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.732546] Stack:
[ 2406.732546]  ffff88002ad6fe48 ffffffffad07c04d ffff88002ad6ffd8 0000000000000000
[ 2406.732546]  ffff88002ad6fe58 ffffffffad07cd4f ffff88002ad6fed8 ffffffffad1b73f5
[ 2406.732546]  0000000000000000 b14dfbbab381bb01 ffff88002ad6ffd8 000000000000f000
[ 2406.732546] Call Trace:
[ 2406.732546] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.732546] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.732546] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.732546] cpu_startup_entry (??:?)
[ 2406.732546] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.732546] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.726090] NMI backtrace for cpu 11
[ 2407.051480] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 269.944 msecs
[ 2406.726090] CPU: 11 PID: 0 Comm: swapper/11 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.726090] task: ffff88002ad88000 ti: ffff88002ad84000 task.ti: ffff88002ad84000
[ 2406.726090] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.726090] RSP: 0018:ffff88002ad85e28  EFLAGS: 00000282
[ 2406.726090] RAX: ffff88002ad88000 RBX: ffff88002ad85fd8 RCX: 0000000000000000
[ 2406.726090] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.726090] RBP: ffff88002ad85e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.726090] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.726090] R13: ffff88002ad84000 R14: ffffffffb30bc580 R15: ffff88002ad85fd8
[ 2406.726090] FS:  0000000000000000(0000) GS:ffff880285000000(0000) knlGS:0000000000000000
[ 2406.726090] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.726090] CR2: 00007f5b4d8d397a CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.726090] Stack:
[ 2406.726090]  ffff88002ad85e48 ffffffffad07c04d ffff88002ad85fd8 0000000000000000
[ 2406.726090]  ffff88002ad85e58 ffffffffad07cd4f ffff88002ad85ed8 ffffffffad1b73f5
[ 2406.726090]  0000000000000000 e0335f8592de6dea ffff88002ad85fd8 000000000000f000
[ 2406.726090] Call Trace:
[ 2406.726090] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.726090] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.726090] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.726090] cpu_startup_entry (??:?)
[ 2406.726090] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.726090] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.770400] NMI backtrace for cpu 4
[ 2407.227620] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 446.006 msecs
[ 2406.770400] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.770400] task: ffff880436910000 ti: ffff88002ad72000 task.ti: ffff88002ad72000
[ 2406.770400] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.770400] RSP: 0018:ffff88002ad73e28  EFLAGS: 00000282
[ 2406.770400] RAX: ffff880436910000 RBX: ffff88002ad73fd8 RCX: 0000000000000000
[ 2406.770400] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.770400] RBP: ffff88002ad73e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.770400] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.770400] R13: ffff88002ad72000 R14: ffffffffb30bc580 R15: ffff88002ad73fd8
[ 2406.770400] FS:  0000000000000000(0000) GS:ffff880127000000(0000) knlGS:0000000000000000
[ 2406.770400] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.770400] CR2: 00007f0e063095e0 CR3: 000000005e3c5000 CR4: 00000000000006a0
[ 2406.770400] Stack:
[ 2406.770400]  ffff88002ad73e48 ffffffffad07c04d ffff88002ad73fd8 0000000000000000
[ 2406.770400]  ffff88002ad73e58 ffffffffad07cd4f ffff88002ad73ed8 ffffffffad1b73f5
[ 2406.770400]  0000000000000000 78cea51f19eb6d9a ffff88002ad73fd8 000000000000f000
[ 2406.770400] Call Trace:
[ 2406.770400] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.770400] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.770400] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.770400] cpu_startup_entry (??:?)
[ 2406.770400] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.770400] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.770587] NMI backtrace for cpu 8
[ 2407.392169] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 610.715 msecs
[ 2406.770587] CPU: 8 PID: 0 Comm: swapper/8 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.770587] task: ffff880316910000 ti: ffff88002ad7e000 task.ti: ffff88002ad7e000
[ 2406.770587] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.770587] RSP: 0018:ffff88002ad7fe28  EFLAGS: 00000282
[ 2406.770587] RAX: ffff880316910000 RBX: ffff88002ad7ffd8 RCX: 0000000000000000
[ 2406.770587] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.770587] RBP: ffff88002ad7fe28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.770587] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.770587] R13: ffff88002ad7e000 R14: ffffffffb30bc580 R15: ffff88002ad7ffd8
[ 2406.770587] FS:  0000000000000000(0000) GS:ffff8801ef000000(0000) knlGS:0000000000000000
[ 2406.770587] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.770587] CR2: 00007fd82dbefb80 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.770587] Stack:
[ 2406.770587]  ffff88002ad7fe48 ffffffffad07c04d ffff88002ad7ffd8 0000000000000000
[ 2406.770587]  ffff88002ad7fe58 ffffffffad07cd4f ffff88002ad7fed8 ffffffffad1b73f5
[ 2406.770587]  0000000000000000 c37c456b12092c72 ffff88002ad7ffd8 000000000000f000
[ 2406.770587] Call Trace:
[ 2406.770587] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.770587] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.770587] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.770587] cpu_startup_entry (??:?)
[ 2406.770587] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.770587] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.776572] NMI backtrace for cpu 9
[ 2407.455680] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 674.457 msecs
[ 2406.776572] CPU: 9 PID: 0 Comm: swapper/9 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.776572] task: ffff880436918000 ti: ffff88002ad80000 task.ti: ffff88002ad80000
[ 2406.776572] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.776572] RSP: 0018:ffff88002ad81e28  EFLAGS: 00000282
[ 2406.776572] RAX: ffff880436918000 RBX: ffff88002ad81fd8 RCX: 0000000000000000
[ 2406.776572] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.776572] RBP: ffff88002ad81e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.776572] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.776572] R13: ffff88002ad80000 R14: ffffffffb30bc580 R15: ffff88002ad81fd8
[ 2406.776572] FS:  0000000000000000(0000) GS:ffff880220e00000(0000) knlGS:0000000000000000
[ 2406.776572] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.776572] CR2: 00007fd9fe85e099 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.776572] Stack:
[ 2406.776572]  ffff88002ad81e48 ffffffffad07c04d ffff88002ad81fd8 0000000000000000
[ 2406.776572]  ffff88002ad81e58 ffffffffad07cd4f ffff88002ad81ed8 ffffffffad1b73f5
[ 2406.776572]  0000000000000000 982768e623c64a41 ffff88002ad81fd8 000000000000f000
[ 2406.776572] Call Trace:
[ 2406.776572] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.776572] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.776572] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.776572] cpu_startup_entry (??:?)
[ 2406.776572] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.776572] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.773931] NMI backtrace for cpu 16
[ 2407.522960] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 741.709 msecs
[ 2406.773931] CPU: 16 PID: 0 Comm: swapper/16 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.773931] task: ffff880316920000 ti: ffff88002ad9a000 task.ti: ffff88002ad9a000
[ 2406.773931] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.773931] RSP: 0018:ffff88002ad9be28  EFLAGS: 00000282
[ 2406.773931] RAX: ffff880316920000 RBX: ffff88002ad9bfd8 RCX: 0000000000000000
[ 2406.773931] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.773931] RBP: ffff88002ad9be28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.773931] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.773931] R13: ffff88002ad9a000 R14: ffffffffb30bc580 R15: ffff88002ad9bfd8
[ 2406.773931] FS:  0000000000000000(0000) GS:ffff880377000000(0000) knlGS:0000000000000000
[ 2406.773931] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.773931] CR2: 00007faa2c8d59de CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.773931] Stack:
[ 2406.773931]  ffff88002ad9be48 ffffffffad07c04d ffff88002ad9bfd8 0000000000000000
[ 2406.773931]  ffff88002ad9be58 ffffffffad07cd4f ffff88002ad9bed8 ffffffffad1b73f5
[ 2406.773931]  0000000000000000 fc58c7b9f54f958d ffff88002ad9bfd8 000000000000f000
[ 2406.773931] Call Trace:
[ 2406.773931] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.773931] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.773931] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.773931] cpu_startup_entry (??:?)
[ 2406.773931] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.773931] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.791002] NMI backtrace for cpu 7
[ 2407.623400] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 842.127 msecs
[ 2406.791002] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.791002] task: ffff8801ee900000 ti: ffff88002ad7c000 task.ti: ffff88002ad7c000
[ 2406.791002] RIP: native_write_msr_safe (arch/x86/include/asm/msr.h:95)
[ 2406.791002] RSP: 0018:ffff88002ad7dcf8  EFLAGS: 00000046
[ 2406.791002] RAX: 000000007fffffff RBX: ffff8801bd00f040 RCX: 0000000000000838
[ 2406.791002] RDX: 0000000000000000 RSI: 000000007fffffff RDI: 0000000000000838
[ 2406.791002] RBP: ffff88002ad7dcf8 R08: 0000000000800000 R09: ffffffffffffffff
[ 2406.791002] R10: 00032cdb7c0be5d4 R11: 0000000000000000 R12: 00000007ff111e51
[ 2406.791002] R13: 0000000000000001 R14: 0000000000000001 R15: ffff8801bd1d0a40
[ 2406.791002] FS:  0000000000000000(0000) GS:ffff8801bd000000(0000) knlGS:0000000000000000
[ 2406.791002] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.791002] CR2: 00007f0c5de1e099 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.791002] Stack:
[ 2406.791002]  ffff88002ad7dd08 ffffffffad0b3831 ffff88002ad7dd18 ffffffffad0ac09d
[ 2406.791002]  ffff88002ad7dd48 ffffffffad1f6bca 0000000000000000 00000238653e3600
[ 2406.791002]  0000000000000001 0000000000000000 ffff88002ad7dd68 ffffffffad1f9600
[ 2406.791002] Call Trace:
[ 2406.791002] native_apic_msr_write (arch/x86/include/asm/paravirt.h:133 arch/x86/include/asm/apic.h:136)
[ 2406.791002] lapic_next_event (arch/x86/kernel/apic/apic.c:483)
[ 2406.791002] clockevents_program_event (kernel/time/clockevents.c:270)
[ 2406.791002] tick_program_event (kernel/time/tick-oneshot.c:32)
[ 2406.791002] hrtimer_force_reprogram (kernel/hrtimer.c:574)
[ 2406.791002] __remove_hrtimer (kernel/hrtimer.c:915)
[ 2406.791002] hrtimer_try_to_cancel (kernel/hrtimer.c:952 kernel/hrtimer.c:1078)
[ 2406.791002] hrtimer_cancel (kernel/hrtimer.c:1100)
[ 2406.791002] tick_nohz_restart (kernel/time/tick-sched.c:841)
[ 2406.791002] tick_nohz_idle_exit (kernel/time/tick-sched.c:879 include/linux/jump_label.h:105 include/linux/context_tracking_state.h:27 include/linux/vtime.h:22 kernel/time/tick-sched.c:887 kernel/time/tick-sched.c:929)
[ 2406.791002] cpu_idle_loop (kernel/sched/idle.c:241)
[ 2406.791002] cpu_startup_entry (??:?)
[ 2406.791002] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.791002] Code: 00 55 89 f9 48 89 e5 0f 32 31 ff 89 c0 48 c1 e2 20 89 3e 48 09 c2 5d 48 89 d0 c3 66 0f 1f 44 00 00 55 89 f0 89 f9 48 89 e5 0f 30 <31> c0 5d c3 66 90 55 89 f9 48 89 e5 0f 33 89 c0 48 c1 e2 20 5d
[ 2406.780287] NMI backtrace for cpu 10
[ 2406.791002] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1087.712 msecs
[ 2406.780287] CPU: 10 PID: 0 Comm: swapper/10 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.780287] task: ffff880556938000 ti: ffff88002ad82000 task.ti: ffff88002ad82000
[ 2406.780287] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.780287] RSP: 0018:ffff88002ad83e28  EFLAGS: 00000282
[ 2406.780287] RAX: ffff880556938000 RBX: ffff88002ad83fd8 RCX: 0000000000000000
[ 2406.780287] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.780287] RBP: ffff88002ad83e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.780287] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.780287] R13: ffff88002ad82000 R14: ffffffffb30bc580 R15: ffff88002ad83fd8
[ 2406.780287] FS:  0000000000000000(0000) GS:ffff880253000000(0000) knlGS:0000000000000000
[ 2406.780287] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.780287] CR2: 00007fb641e0d070 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.780287] Stack:
[ 2406.780287]  ffff88002ad83e48 ffffffffad07c04d ffff88002ad83fd8 0000000000000000
[ 2406.780287]  ffff88002ad83e58 ffffffffad07cd4f ffff88002ad83ed8 ffffffffad1b73f5
[ 2406.780287]  0000000000000000 9f3d8b5b532a750a ffff88002ad83fd8 000000000000f000
[ 2406.780287] Call Trace:
[ 2406.780287] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.780287] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.780287] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.780287] cpu_startup_entry (??:?)
[ 2406.780287] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.780287] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.790114] NMI backtrace for cpu 1
[ 2408.073317] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1291.403 msecs
[ 2406.790114] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.790114] task: ffff8800948f0000 ti: ffff88002ad6c000 task.ti: ffff88002ad6c000
[ 2406.790114] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.790114] RSP: 0018:ffff88002ad6de28  EFLAGS: 00000282
[ 2406.790114] RAX: ffff8800948f0000 RBX: ffff88002ad6dfd8 RCX: 0000000000000000
[ 2406.790114] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.790114] RBP: ffff88002ad6de28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.790114] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.790114] R13: ffff88002ad6c000 R14: ffffffffb30bc580 R15: ffff88002ad6dfd8
[ 2406.790114] FS:  0000000000000000(0000) GS:ffff880063000000(0000) knlGS:0000000000000000
[ 2406.790114] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.790114] CR2: 00007faa2c8d59de CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.790114] Stack:
[ 2406.790114]  ffff88002ad6de48 ffffffffad07c04d ffff88002ad6dfd8 0000000000000000
[ 2406.790114]  ffff88002ad6de58 ffffffffad07cd4f ffff88002ad6ded8 ffffffffad1b73f5
[ 2406.790114]  0000000000000000 070355202ebd0a66 ffff88002ad6dfd8 000000000000f000
[ 2406.790114] Call Trace:
[ 2406.790114] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.790114] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.790114] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.790114] cpu_startup_entry (??:?)
[ 2406.790114] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.790114] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.773449] NMI backtrace for cpu 12
[ 2408.114944] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1333.636 msecs
[ 2406.773449] CPU: 12 PID: 0 Comm: swapper/12 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.773449] task: ffff88002ad8b000 ti: ffff88002ad86000 task.ti: ffff88002ad86000
[ 2406.773449] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.773449] RSP: 0018:ffff88002ad87e28  EFLAGS: 00000282
[ 2406.773449] RAX: ffff88002ad8b000 RBX: ffff88002ad87fd8 RCX: 0000000000000000
[ 2406.773449] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.773449] RBP: ffff88002ad87e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.773449] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.773449] R13: ffff88002ad86000 R14: ffffffffb30bc580 R15: ffff88002ad87fd8
[ 2406.773449] FS:  0000000000000000(0000) GS:ffff8802b7000000(0000) knlGS:0000000000000000
[ 2406.773449] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.773449] CR2: 00007f5fae0ef170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.773449] Stack:
[ 2406.773449]  ffff88002ad87e48 ffffffffad07c04d ffff88002ad87fd8 0000000000000000
[ 2406.773449]  ffff88002ad87e58 ffffffffad07cd4f ffff88002ad87ed8 ffffffffad1b73f5
[ 2406.773449]  0000000000000000 c6410aa475d0509c ffff88002ad87fd8 000000000000f000
[ 2406.773449] Call Trace:
[ 2406.773449] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.773449] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.773449] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.773449] cpu_startup_entry (??:?)
[ 2406.773449] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.773449] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.783731] NMI backtrace for cpu 20
[ 2406.783731] CPU: 20 PID: 0 Comm: swapper/20 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.783731] task: ffff8802b6918000 ti: ffff88002adaa000 task.ti: ffff88002adaa000
[ 2406.783731] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.783731] RSP: 0018:ffff88002adabe28  EFLAGS: 00000282
[ 2406.783731] RAX: ffff8802b6918000 RBX: ffff88002adabfd8 RCX: 0000000000000000
[ 2406.783731] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.783731] RBP: ffff88002adabe28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.783731] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.783731] R13: ffff88002adaa000 R14: ffffffffb30bc580 R15: ffff88002adabfd8
[ 2406.783731] FS:  0000000000000000(0000) GS:ffff880437000000(0000) knlGS:0000000000000000
[ 2406.783731] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.783731] CR2: 00007f9fbf31f170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.783731] Stack:
[ 2406.783731]  ffff88002adabe48 ffffffffad07c04d ffff88002adabfd8 0000000000000000
[ 2406.783731]  ffff88002adabe58 ffffffffad07cd4f ffff88002adabed8 ffffffffad1b73f5
[ 2406.783731]  0000000000000000 ec4da5f4ddcd59c7 ffff88002adabfd8 000000000000f000
[ 2406.783731] Call Trace:
[ 2406.783731] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.783731] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.783731] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.783731] cpu_startup_entry (??:?)
[ 2406.783731] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.783731] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.780604] NMI backtrace for cpu 17
[ 2406.780604] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.780604] task: ffff880496920000 ti: ffff88002ad9c000 task.ti: ffff88002ad9c000
[ 2406.780604] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.780604] RSP: 0018:ffff88002ad9de28  EFLAGS: 00000282
[ 2406.780604] RAX: ffff880496920000 RBX: ffff88002ad9dfd8 RCX: 0000000000000000
[ 2406.780604] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.780604] RBP: ffff88002ad9de28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.780604] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.780604] R13: ffff88002ad9c000 R14: ffffffffb30bc580 R15: ffff88002ad9dfd8
[ 2406.780604] FS:  0000000000000000(0000) GS:ffff8803a7000000(0000) knlGS:0000000000000000
[ 2406.780604] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.780604] CR2: 00007f446d8cd170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.780604] Stack:
[ 2406.780604]  ffff88002ad9de48 ffffffffad07c04d ffff88002ad9dfd8 0000000000000000
[ 2406.780604]  ffff88002ad9de58 ffffffffad07cd4f ffff88002ad9ded8 ffffffffad1b73f5
[ 2406.780604]  0000000000000000 970676ae9739a05a ffff88002ad9dfd8 000000000000f000
[ 2406.780604] Call Trace:
[ 2406.780604] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.780604] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.780604] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.780604] cpu_startup_entry (??:?)
[ 2406.780604] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.780604] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.773106] NMI backtrace for cpu 18
[ 2406.773106] CPU: 18 PID: 0 Comm: swapper/18 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.773106] task: ffff880616928000 ti: ffff88002ad9e000 task.ti: ffff88002ad9e000
[ 2406.773106] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.773106] RSP: 0018:ffff88002ad9fe28  EFLAGS: 00000282
[ 2406.773106] RAX: ffff880616928000 RBX: ffff88002ad9ffd8 RCX: 0000000000000000
[ 2406.773106] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.773106] RBP: ffff88002ad9fe28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.773106] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.773106] R13: ffff88002ad9e000 R14: ffffffffb30bc580 R15: ffff88002ad9ffd8
[ 2406.773106] FS:  0000000000000000(0000) GS:ffff8803d7000000(0000) knlGS:0000000000000000
[ 2406.773106] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.773106] CR2: 00007f5b4d3ff099 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.773106] Stack:
[ 2406.773106]  ffff88002ad9fe48 ffffffffad07c04d ffff88002ad9ffd8 0000000000000000
[ 2406.773106]  ffff88002ad9fe58 ffffffffad07cd4f ffff88002ad9fed8 ffffffffad1b73f5
[ 2406.773106]  0000000000000000 ccdf3c6031d54cd1 ffff88002ad9ffd8 000000000000f000
[ 2406.773106] Call Trace:
[ 2406.773106] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.773106] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.773106] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.773106] cpu_startup_entry (??:?)
[ 2406.773106] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.773106] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.770609] NMI backtrace for cpu 13
[ 2406.770609] CPU: 13 PID: 0 Comm: swapper/13 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.770609] task: ffff8803d6928000 ti: ffff88002ad90000 task.ti: ffff88002ad90000
[ 2406.770609] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.770609] RSP: 0018:ffff88002ad91e28  EFLAGS: 00000282
[ 2406.770609] RAX: ffff8803d6928000 RBX: ffff88002ad91fd8 RCX: 0000000000000000
[ 2406.770609] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.770609] RBP: ffff88002ad91e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.770609] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.770609] R13: ffff88002ad90000 R14: ffffffffb30bc580 R15: ffff88002ad91fd8
[ 2406.770609] FS:  0000000000000000(0000) GS:ffff8802e7000000(0000) knlGS:0000000000000000
[ 2406.770609] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.770609] CR2: 00007f10cbecf070 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.770609] Stack:
[ 2406.770609]  ffff88002ad91e48 ffffffffad07c04d ffff88002ad91fd8 0000000000000000
[ 2406.770609]  ffff88002ad91e58 ffffffffad07cd4f ffff88002ad91ed8 ffffffffad1b73f5
[ 2406.770609]  0000000000000000 618f5836413e64b6 ffff88002ad91fd8 000000000000f000
[ 2406.770609] Call Trace:
[ 2406.770609] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.770609] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.770609] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.770609] cpu_startup_entry (??:?)
[ 2406.770609] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.770609] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.785234] NMI backtrace for cpu 19
[ 2406.785234] CPU: 19 PID: 0 Comm: swapper/19 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.785234] task: ffff88018a910000 ti: ffff88002ada8000 task.ti: ffff88002ada8000
[ 2406.785234] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.785234] RSP: 0018:ffff88002ada9e28  EFLAGS: 00000282
[ 2406.785234] RAX: ffff88018a910000 RBX: ffff88002ada9fd8 RCX: 0000000000000000
[ 2406.785234] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.785234] RBP: ffff88002ada9e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.785234] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.785234] R13: ffff88002ada8000 R14: ffffffffb30bc580 R15: ffff88002ada9fd8
[ 2406.785234] FS:  0000000000000000(0000) GS:ffff880407000000(0000) knlGS:0000000000000000
[ 2406.785234] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.785234] CR2: 00007f7bc2f1d099 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.785234] Stack:
[ 2406.785234]  ffff88002ada9e48 ffffffffad07c04d ffff88002ada9fd8 0000000000000000
[ 2406.785234]  ffff88002ada9e58 ffffffffad07cd4f ffff88002ada9ed8 ffffffffad1b73f5
[ 2406.785234]  0000000000000000 43f465af05da1bde ffff88002ada9fd8 000000000000f000
[ 2406.785234] Call Trace:
[ 2406.785234] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.785234] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.785234] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.785234] cpu_startup_entry (??:?)
[ 2406.785234] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.785234] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.722636] NMI backtrace for cpu 5
[ 2406.722636] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.722636] task: ffff880556930000 ti: ffff88002ad74000 task.ti: ffff88002ad74000
[ 2406.722636] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.722636] RSP: 0018:ffff88002ad75e28  EFLAGS: 00000282
[ 2406.722636] RAX: ffff880556930000 RBX: ffff88002ad75fd8 RCX: 0000000000000000
[ 2406.722636] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.722636] RBP: ffff88002ad75e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.722636] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.722636] R13: ffff88002ad74000 R14: ffffffffb30bc580 R15: ffff88002ad75fd8
[ 2406.722636] FS:  0000000000000000(0000) GS:ffff880158e00000(0000) knlGS:0000000000000000
[ 2406.722636] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.722636] CR2: 00007f9ba4e9f170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.722636] Stack:
[ 2406.722636]  ffff88002ad75e48 ffffffffad07c04d ffff88002ad75fd8 0000000000000000
[ 2406.722636]  ffff88002ad75e58 ffffffffad07cd4f ffff88002ad75ed8 ffffffffad1b73f5
[ 2406.722636]  0000000000000000 9a6095db8c2e6f9a ffff88002ad75fd8 000000000000f000
[ 2406.722636] Call Trace:
[ 2406.722636] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.722636] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.722636] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.722636] cpu_startup_entry (??:?)
[ 2406.722636] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.722636] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.780256] NMI backtrace for cpu 0
[ 2406.780256] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.780256] task: ffffffffb1e344c0 ti: ffffffffb1e00000 task.ti: ffffffffb1e00000
[ 2406.780256] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.780256] RSP: 0000:ffffffffb1e01e38  EFLAGS: 00000282
[ 2406.780256] RAX: ffffffffb1e344c0 RBX: ffffffffb1e01fd8 RCX: 0000000000000000
[ 2406.780256] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.780256] RBP: ffffffffb1e01e38 R08: 0000000000000000 R09: 0000000000000000
[ 2406.780256] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.780256] R13: ffffffffb1e00000 R14: ffffffffb30bc580 R15: ffffffffb1e01fd8
[ 2406.780256] FS:  0000000000000000(0000) GS:ffff88002be00000(0000) knlGS:0000000000000000
[ 2406.780256] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.780256] CR2: 00007f0e067fe821 CR3: 0000000031e2d000 CR4: 00000000000006b0
[ 2406.780256] Stack:
[ 2406.780256]  ffffffffb1e01e58 ffffffffad07c04d ffffffffb1e01fd8 0000000000000000
[ 2406.780256]  ffffffffb1e01e68 ffffffffad07cd4f ffffffffb1e01ee8 ffffffffad1b73f5
[ 2406.780256]  0000000000000000 d81b28d1e484efc7 ffffffffb1e01fd8 0000000000000002
[ 2406.780256] Call Trace:
[ 2406.780256] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.780256] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.780256] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.780256] cpu_startup_entry (??:?)
[ 2406.780256] rest_init (init/main.c:398)
[ 2406.780256] ? rest_init (init/main.c:373)
[ 2406.780256] start_kernel (init/main.c:653)
[ 2406.780256] ? repair_env_string (init/main.c:260)
[ 2406.780256] ? early_idt_handlers (arch/x86/kernel/head_64.S:340)
[ 2406.780256] x86_64_start_reservations (arch/x86/kernel/head64.c:194)
[ 2406.780256] x86_64_start_kernel (arch/x86/kernel/head64.c:183)
[ 2406.780256] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2406.790091] NMI backtrace for cpu 3
[ 2406.790091] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2406.790091] task: ffff880316908000 ti: ffff88002ad70000 task.ti: ffff88002ad70000
[ 2406.790091] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2406.790091] RSP: 0018:ffff88002ad71e28  EFLAGS: 00000282
[ 2406.790091] RAX: ffff880316908000 RBX: ffff88002ad71fd8 RCX: 0000000000000000
[ 2406.790091] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2406.790091] RBP: ffff88002ad71e28 R08: 0000000000000000 R09: 0000000000000000
[ 2406.790091] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2406.790091] R13: ffff88002ad70000 R14: ffffffffb30bc580 R15: ffff88002ad71fd8
[ 2406.790091] FS:  0000000000000000(0000) GS:ffff8800c7000000(0000) knlGS:0000000000000000
[ 2406.790091] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2406.790091] CR2: 00007fbb037b0334 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2406.790091] Stack:
[ 2406.790091]  ffff88002ad71e48 ffffffffad07c04d ffff88002ad71fd8 0000000000000000
[ 2406.790091]  ffff88002ad71e58 ffffffffad07cd4f ffff88002ad71ed8 ffffffffad1b73f5
[ 2406.790091]  0000000000000000 a42a8a608a0df9ca ffff88002ad71fd8 000000000000f000
[ 2406.790091] Call Trace:
[ 2406.790091] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2406.790091] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2406.790091] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2406.790091] cpu_startup_entry (??:?)
[ 2406.790091] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2406.790091] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2408.693358] NMI backtrace for cpu 15
[ 2408.693358] CPU: 15 PID: 0 Comm: swapper/15 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2408.722811] task: ffff88018a908000 ti: ffff88002ad98000 task.ti: ffff88002ad98000
[ 2408.722811] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2408.722811] RSP: 0018:ffff88002ad99e28  EFLAGS: 00000282
[ 2408.722811] RAX: ffff88018a908000 RBX: ffff88002ad99fd8 RCX: 0000000000000000
[ 2408.722811] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2408.722811] RBP: ffff88002ad99e28 R08: 0000000000000000 R09: 0000000000000000
[ 2408.722811] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2408.722811] R13: ffff88002ad98000 R14: ffffffffb30bc580 R15: ffff88002ad99fd8
[ 2408.722811] FS:  0000000000000000(0000) GS:ffff880347000000(0000) knlGS:0000000000000000
[ 2408.722811] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2408.722811] CR2: 00007f93c7ead070 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2408.722811] Stack:
[ 2408.722811]  ffff88002ad99e48 ffffffffad07c04d ffff88002ad99fd8 0000000000000000
[ 2408.722811]  ffff88002ad99e58 ffffffffad07cd4f ffff88002ad99ed8 ffffffffad1b73f5
[ 2408.722811]  0000000000000000 d415927b269676da ffff88002ad99fd8 000000000000f000
[ 2408.722811] Call Trace:
[ 2408.722811] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2408.722811] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2408.722811] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2408.722811] cpu_startup_entry (??:?)
[ 2408.722811] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2408.722811] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2408.722619] NMI backtrace for cpu 14
[ 2408.722619] CPU: 14 PID: 0 Comm: swapper/14 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2408.722619] task: ffff8805b6908000 ti: ffff88002ad92000 task.ti: ffff88002ad92000
[ 2408.722619] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2408.722619] RSP: 0018:ffff88002ad93e28  EFLAGS: 00000282
[ 2408.722619] RAX: ffff8805b6908000 RBX: ffff88002ad93fd8 RCX: 0000000000000000
[ 2408.722619] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2408.722619] RBP: ffff88002ad93e28 R08: 0000000000000000 R09: 0000000000000000
[ 2408.722619] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2408.722619] R13: ffff88002ad92000 R14: ffffffffb30bc580 R15: ffff88002ad93fd8
[ 2408.722619] FS:  0000000000000000(0000) GS:ffff880317000000(0000) knlGS:0000000000000000
[ 2408.722619] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2408.722619] CR2: 00007f30be8c9730 CR3: 0000000157401000 CR4: 00000000000006a0
[ 2408.722619] Stack:
[ 2408.722619]  ffff88002ad93e48 ffffffffad07c04d ffff88002ad93fd8 0000000000000000
[ 2408.722619]  ffff88002ad93e58 ffffffffad07cd4f ffff88002ad93ed8 ffffffffad1b73f5
[ 2408.722619]  0000000000000000 89f157ff9e713d03 ffff88002ad93fd8 000000000000f000
[ 2408.837217] Call Trace:
[ 2408.837217] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2408.837217] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2408.837217] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2408.837217] cpu_startup_entry (??:?)
[ 2408.837217] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2408.837217] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2408.691691] NMI backtrace for cpu 6
[ 2408.691691] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2408.691691] task: ffff8800948f8000 ti: ffff88002ad76000 task.ti: ffff88002ad76000
[ 2408.691691] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2408.691691] RSP: 0018:ffff88002ad77e28  EFLAGS: 00000282
[ 2408.691691] RAX: ffff8800948f8000 RBX: ffff88002ad77fd8 RCX: 0000000000000000
[ 2408.691691] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2408.691691] RBP: ffff88002ad77e28 R08: 0000000000000000 R09: 0000000000000000
[ 2408.691691] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2408.691691] R13: ffff88002ad76000 R14: ffffffffb30bc580 R15: ffff88002ad77fd8
[ 2408.691691] FS:  0000000000000000(0000) GS:ffff88018b000000(0000) knlGS:0000000000000000
[ 2408.691691] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2408.691691] CR2: 00007f1f306df170 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2408.691691] Stack:
[ 2408.691691]  ffff88002ad77e48 ffffffffad07c04d ffff88002ad77fd8 0000000000000000
[ 2408.691691]  ffff88002ad77e58 ffffffffad07cd4f ffff88002ad77ed8 ffffffffad1b73f5
[ 2408.691691]  0000000000000000 154a1c73da38ea65 ffff88002ad77fd8 000000000000f000
[ 2408.691691] Call Trace:
[ 2408.691691] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2408.691691] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2408.691691] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2408.691691] cpu_startup_entry (??:?)
[ 2408.691691] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2408.691691] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2408.696506] NMI backtrace for cpu 23
[ 2408.696506] CPU: 23 PID: 0 Comm: swapper/23 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2408.696506] task: ffff880616930000 ti: ffff88002adb0000 task.ti: ffff88002adb0000
[ 2408.696506] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2408.696506] RSP: 0018:ffff88002adb1e28  EFLAGS: 00000282
[ 2408.696506] RAX: ffff880616930000 RBX: ffff88002adb1fd8 RCX: 0000000000000000
[ 2408.696506] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2408.696506] RBP: ffff88002adb1e28 R08: 0000000000000000 R09: 0000000000000000
[ 2408.696506] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2408.696506] R13: ffff88002adb0000 R14: ffffffffb30bc580 R15: ffff88002adb1fd8
[ 2408.696506] FS:  0000000000000000(0000) GS:ffff8804c7000000(0000) knlGS:0000000000000000
[ 2408.696506] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2408.696506] CR2: 00007faa2c8d59de CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2408.696506] Stack:
[ 2408.696506]  ffff88002adb1e48 ffffffffad07c04d ffff88002adb1fd8 0000000000000000
[ 2408.696506]  ffff88002adb1e58 ffffffffad07cd4f ffff88002adb1ed8 ffffffffad1b73f5
[ 2408.696506]  0000000000000000 5f651cf4a238a6ff ffff88002adb1fd8 000000000000f000
[ 2408.696506] Call Trace:
[ 2408.696506] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2408.696506] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2408.696506] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2408.696506] cpu_startup_entry (??:?)
[ 2408.696506] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2408.696506] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2408.837579] NMI backtrace for cpu 22
[ 2408.837579] CPU: 22 PID: 0 Comm: swapper/22 Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2408.837579] task: ffff8804f6938000 ti: ffff88002adae000 task.ti: ffff88002adae000
[ 2408.837579] RIP: native_safe_halt (arch/x86/include/asm/irqflags.h:50)
[ 2408.837579] RSP: 0018:ffff88002adafe28  EFLAGS: 00000282
[ 2408.837579] RAX: ffff8804f6938000 RBX: ffff88002adaffd8 RCX: 0000000000000000
[ 2408.837579] RDX: 0000000000000000 RSI: ffffffffb1820b10 RDI: ffffffffb17b99f5
[ 2408.837579] RBP: ffff88002adafe28 R08: 0000000000000000 R09: 0000000000000000
[ 2408.837579] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[ 2408.837579] R13: ffff88002adae000 R14: ffffffffb30bc580 R15: ffff88002adaffd8
[ 2408.837579] FS:  0000000000000000(0000) GS:ffff880497000000(0000) knlGS:0000000000000000
[ 2408.837579] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2408.837579] CR2: 00007fffb3da2ff8 CR3: 0000000031e2d000 CR4: 00000000000006a0
[ 2408.837579] Stack:
[ 2408.837579]  ffff88002adafe48 ffffffffad07c04d ffff88002adaffd8 0000000000000000
[ 2408.837579]  ffff88002adafe58 ffffffffad07cd4f ffff88002adafed8 ffffffffad1b73f5
[ 2408.837579]  0000000000000000 21d4616f708a6f6a ffff88002adaffd8 000000000000f000
[ 2408.837579] Call Trace:
[ 2408.837579] default_idle (arch/x86/include/asm/paravirt.h:111 arch/x86/kernel/process.c:310)
[ 2408.837579] arch_cpu_idle (arch/x86/kernel/process.c:302)
[ 2408.837579] cpu_idle_loop (kernel/sched/idle.c:179 kernel/sched/idle.c:226)
[ 2408.837579] cpu_startup_entry (??:?)
[ 2408.837579] start_secondary (arch/x86/kernel/smpboot.c:267)
[ 2408.837579] Code: 00 00 00 00 00 55 48 89 e5 fa 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <5d> c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 5d c3 66 0f 1f 84
[ 2409.043054] Kernel panic - not syncing: hung_task: blocked tasks
[ 2409.046306] CPU: 21 PID: 3540 Comm: khungtaskd Not tainted 3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
[ 2409.050074]  00000000003ffecf ffff880436b5bd38 ffffffffb05223a7 0000000000000001
[ 2409.050074]  ffffffffb16caa40 ffff880436b5bdb8 ffffffffb0513f93 ffff880436b5bd58
[ 2409.050074]  0000000000000008 ffff880436b5bdc8 ffff880436b5bd68 0000000000001f15
[ 2409.050074] Call Trace:
[ 2409.050074] dump_stack (lib/dump_stack.c:52)
[ 2409.050074] panic (kernel/panic.c:117)
[ 2409.050074] watchdog (kernel/hung_task.c:124 kernel/hung_task.c:180 kernel/hung_task.c:236)
[ 2409.050074] ? watchdog (include/linux/rcupdate.h:800 kernel/hung_task.c:169 kernel/hung_task.c:236)
[ 2409.050074] ? reset_hung_task_detector (kernel/hung_task.c:224)
[ 2409.050074] kthread (kernel/kthread.c:210)
[ 2409.050074] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2409.050074] ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 2409.050074] ? kthread_create_on_node (kernel/kthread.c:176)
[ 2409.050074] Dumping ftrace buffer:
[ 2409.050074]    (ftrace buffer empty)
[ 2409.050074] Kernel Offset: 0x2c000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
