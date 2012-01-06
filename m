Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 30DAA6B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 01:06:37 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 6 Jan 2012 06:03:38 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q066208q3121338
	for <linux-mm@kvack.org>; Fri, 6 Jan 2012 17:02:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0666GIk030997
	for <linux-mm@kvack.org>; Fri, 6 Jan 2012 17:06:17 +1100
Message-ID: <4F068F53.50402@linux.vnet.ibm.com>
Date: Fri, 06 Jan 2012 11:36:11 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com> <1325499859-2262-8-git-send-email-gilad@benyossef.com> <4F033EC9.4050909@gmail.com> <20120105142017.GA27881@csn.ul.ie> <20120105144011.GU11810@n2100.arm.linux.org.uk> <20120105161739.GD27881@csn.ul.ie> <20120105163529.GA11810@n2100.arm.linux.org.uk> <20120105183504.GF2393@linux.vnet.ibm.com> <20120105222116.GF27881@csn.ul.ie>
In-Reply-To: <20120105222116.GF27881@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Greg KH <gregkh@suse.de>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On 01/06/2012 03:51 AM, Mel Gorman wrote:

> (Adding Greg to cc to see if he recalls seeing issues with sysfs dentry
> suffering from recursive locking recently)
> 
> On Thu, Jan 05, 2012 at 10:35:04AM -0800, Paul E. McKenney wrote:
>> On Thu, Jan 05, 2012 at 04:35:29PM +0000, Russell King - ARM Linux wrote:
>>> On Thu, Jan 05, 2012 at 04:17:39PM +0000, Mel Gorman wrote:
>>>> Link please?
>>>
>>> Forwarded, as its still in my mailbox.
>>>
>>>> I'm including a patch below under development that is
>>>> intended to only cope with the page allocator case under heavy memory
>>>> pressure. Currently it does not pass testing because eventually RCU
>>>> gets stalled with the following trace
>>>>
>>>> [ 1817.176001]  [<ffffffff810214d7>] arch_trigger_all_cpu_backtrace+0x87/0xa0
>>>> [ 1817.176001]  [<ffffffff810c4779>] __rcu_pending+0x149/0x260
>>>> [ 1817.176001]  [<ffffffff810c48ef>] rcu_check_callbacks+0x5f/0x110
>>>> [ 1817.176001]  [<ffffffff81068d7f>] update_process_times+0x3f/0x80
>>>> [ 1817.176001]  [<ffffffff8108c4eb>] tick_sched_timer+0x5b/0xc0
>>>> [ 1817.176001]  [<ffffffff8107f28e>] __run_hrtimer+0xbe/0x1a0
>>>> [ 1817.176001]  [<ffffffff8107f581>] hrtimer_interrupt+0xc1/0x1e0
>>>> [ 1817.176001]  [<ffffffff81020ef3>] smp_apic_timer_interrupt+0x63/0xa0
>>>> [ 1817.176001]  [<ffffffff81449073>] apic_timer_interrupt+0x13/0x20
>>>> [ 1817.176001]  [<ffffffff8116c135>] vfsmount_lock_local_lock+0x25/0x30
>>>> [ 1817.176001]  [<ffffffff8115c855>] path_init+0x2d5/0x370
>>>> [ 1817.176001]  [<ffffffff8115eecd>] path_lookupat+0x2d/0x620
>>>> [ 1817.176001]  [<ffffffff8115f4ef>] do_path_lookup+0x2f/0xd0
>>>> [ 1817.176001]  [<ffffffff811602af>] user_path_at_empty+0x9f/0xd0
>>>> [ 1817.176001]  [<ffffffff81154e7b>] vfs_fstatat+0x4b/0x90
>>>> [ 1817.176001]  [<ffffffff81154f4f>] sys_newlstat+0x1f/0x50
>>>> [ 1817.176001]  [<ffffffff81448692>] system_call_fastpath+0x16/0x1b
>>>>
>>>> It might be a separate bug, don't know for sure.
>>
> 
> I rebased the patch on top of 3.2 and tested again with a bunch of
> debugging options set (PROVE_RCU, PROVE_LOCKING etc). Same results. CPU
> hotplug is a lot more reliable and less likely to hang but eventually
> gets into trouble.
> 


Hi everyone,

I was running some CPU hotplug stress tests recently and found it to be
problematic too. Mel, I have some logs from those tests which appear very
relevant to the "IPI to offline CPU" issue that has been discussed in this
thread.

Kernel: 3.2-rc7
Here is the log: 
(Unfortunately I couldn't capture the log intact, due to some annoying
serial console issues, but I hope this log is good enough to analyze.)
  
[  907.825267] Booting Node 1 Processor 15 APIC 0x17
[  907.830117] smpboot cpu 15: start_ip = 97000
[  906.104006] Calibrating delay loop (skipped) already calibrated this CPU
[  907.860875] NMI watchdog enabled, takes one hw-pmu counter.
[  907.898899] Broke affinity for irq 81
[  907.904539] CPU 1 is now offline
[  907.912891] CPU 9 MCA banks CMCI:2 CMCI:3 CMCI:5
[  907.929462] CPU 2 is now offline
[  907.939573] CPU 10 MCA banks CMCI:2 CMCI:3 CMCI:5
[  907.969514] CPU 3 is now offline
[  907.978644] CPU 11 MCA banks CMCI:2 CMCI:3 CMCI:5
[  908.021903] Broke affinity for irq 74
[  908.024021] ------------[ cut here ]------------
[  908.024021] WARNING: at kernel/smp.c:258 generic_smp_call_function_single_interrupt+0x109/0x120()
[  908.024021] Hardware name: IBM System x -[7870C4Q]-
[  908.024021] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[  908.024021] Pid: 22076, comm: migration/4 Not tainted 3.2.0-rc7-0.0.0.28.36b5ec9-default #1
[  908.024021] Call Trace:
[  908.024021]  <IRQ>  [<ffffffff81099309>] ? generic_smp_call_function_single_interrupt+0x109/0x120
[  908.024021]  [<ffffffff8105441a>] warn_slowpath_common+0x7a/0xb0
[  908.024021]  [<ffffffff81054465>] warn_slowpath_null+0x15/0x20
[  908.024021]  [<ffffffff81099309>] generic_smp_call_function_single_interrupt+0x109/0x120
[  908.024021]  [<ffffffff8101ffa2>] smp_call_function_single_interrupt+0x22/0x40
[  908.024021]  [<ffffffff8146afb3>] call_function_single_interrupt+0x73/0x80
[  908.024021]  <EOI>  [<ffffffff810ba86a>] ? stop_machine_cpu_stop+0xda/0x130
[  908.024021]  [<ffffffff810ba790>] ? stop_one_cpu_nowait+0x50/0x50
[  908.024021]  [<ffffffff810ba4ea>] cpu_stopper_thread+0xba/0x180
[  908.024021]  [<ffffffff8146077f>] ? _raw_spin_unlock_irqrestore+0x3f/0x70
[  908.024021]  [<ffffffff810ba430>] ? res_counter_init+0x50/0x50
[  908.024021]  [<ffffffff8109141d>] ? trace_hardirqs_on_caller+0x12d/0x1b0
[  908.024021]  [<ffffffff810914ad>] ? trace_hardirqs_on+0xd/0x10
[  908.024021]  [<ffffffff810ba430>] ? res_counter_init+0x50/0x50
[  908.024021]  [<ffffffff81078cf6>] kthread+0x96/0xa0
[  908.024021]  [<ffffffff8146b444>] kernel_thread_helper+0x4/0x10
[  908.024021]  [<ffffffff81460ab4>] ? retint_restore_args+0x13/0x13
[  908.024021]  [<ffffffff81078c60>] ? __init_kthread_worker+0x70/0x70
[  908.024021]  [<ffffffff8146b440>] ? gs_change+0x13/0x13
[  908.024021] ---[ end trace f4c7a25be63a672a ]---
[  908.328208] CPU 4 is now offline
[  908.332730] CPU 5 MCA banks CMCI:6 CMCI:8
[  908.337074] CPU 12 MCA banks CMCI:2 CMCI:3 CMCI:5
[  908.349270] CPU 5 is now offline
[  908.353888] CPU 6 MCA banks CMCI:6 CMCI:8
[  908.376131] CPU 13 MCA banks CMCI:2 CMCI:3 CMCI:5
[  908.391939] CPU 6 is now offline
[  908.413193] CPU 7 MCA banks CMCI:6 CMCI:8
[  908.443245] CPU 14 MCA banks CMCI:2 CMCI:3 CMCI:5
[  908.475871] CPU 7 is now offline
[  908.481601] CPU 12 MCA banks CMCI:6 CMCI:8
[  908.485923] CPU 15 MCA banks CMCI:2 CMCI:3 CMCI:5
[  908.519889] CPU 8 is now offline
[  908.565926] CPU 9 is now offline
[  908.602874] CPU 10 is now offline
[  908.634696] CPU 11 is now offline
[  908.674735] CPU 12 is now offline
[  908.680343] CPU 13 MCA banks CMCI:6 CMCI:8
[  908.721887] CPU 13 is now offline
[  908.728086] CPU 14 MCA banks CMCI:6 CMCI:8
[  908.789105] CPU 14 is now offline
[  908.794969] CPU 15 MCA banks CMCI:6 CMCI:8
[  908.881878] CPU 15 is now offline
[  908.885301] lockdep: fixing up alternatives.
[  908.889663] SMP alternatives: switching to UP code
[  909.140900] lockdep: fixing up alternatives.
[  909.145281] SMP alternatives: switching to SMP code
[  909.153536] Booting Node 0 Processor 1 APIC 0x2
[  909.158157] smpboot cpu 1: start_ip = 97000
[  907.900022] Calibrating delay loop (skipped) already calibrated this CPU
[  909.181323] NMI watchdog enabled, takes one hw-pmu counter.
[  909.275696] lockdep: fixing up alternatives.
[  909.280106] Booting Node 0 Processor 2 APIC 0x4
[  909.280107] smpboot cpu 2: start_ip = 97000
[  907.928015] Calibrating delay loop (skipped) already calibrated this CPU
[  909.308538] NMI watchdog enabled, takes one hw-pmu counter.
[  909.376170] lockdep: fixing up alternatives.
[  909.380589] Booting Node 0 Processor 3 APIC 0x6
[ 1319.109486] Booting Node 1 Processor 14 APIC 0x15
[ 1319.114320] smpboot cpu 14: start_ip = 97000
[ 1318.456153] Calibrating delay loop (skipped) already calibrated this CPU
[ 1319.139762] NMI watchdog enabled, takes one hw-pmu counter.
[ 1319.150412] lockdep: fixing up alternatives.
[ 1319.155062] Booting Node 1 Processor 15 APIC 0x17
[ 1319.160165] smpboot cpu 15: start_ip = 97000
[ 1318.472003] Calibrating delay loop (skipped) already calibrated this CPU
[ 1319.188592] NMI watchdog enabled, takes one hw-pmu counter.
[ 1319.216529] CPU 1 is now offline
[ 1319.224915] CPU 9 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.240750] CPU 2 is now offline
[ 1319.256419] CPU 10 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.269161] CPU 3 is now offline
[ 1319.280258] CPU 11 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.293433] CPU 4 is now offline
[ 1319.298109] CPU 5 MCA banks CMCI:6 CMCI:8
[ 1319.312516] CPU 12 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.325377] CPU 5 is now offline
[ 1319.331679] CPU 6 MCA banks CMCI:6 CMCI:8
[ 1319.340437] CPU 13 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.352367] CPU 6 is now offline
[ 1319.357553] CPU 7 MCA banks CMCI:6 CMCI:8
[ 1319.372577] CPU 14 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.385997] CPU 7 is now offline
[ 1319.393018] CPU 12 MCA banks CMCI:6 CMCI:8
[ 1319.397604] CPU 15 MCA banks CMCI:2 CMCI:3 CMCI:5
[ 1319.409149] CPU 8 is now offline
[ 1319.428255] CPU 9 is now offline
[ 1319.450764] CPU 10 is now offline
[ 1319.474489] CPU 11 is now offline
[ 1319.496806] CPU 12 is now offline
[ 1319.502966] CPU 13 MCA banks CMCI:6 CMCI:8
[ 1319.511746] CPU 13 is now offline
[ 1347.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1347.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1347.148005] irq event stamp: 151225746
[ 1347.148005] hardirqs last  enabled at (151225745): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1347.148005] hardirqs last disabled at (151225746): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1347.148005] softirqs last  enabled at (151225744): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1347.148005] softirqs last disabled at (151225739): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1347.148005] CPU 14 
[ 1347.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1347.148005] 
[ 1347.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1347.148005] RIP: 0010:[<ffffffff81033de8>]  [<ffffffff81033de8>] flush_tlb_others_ipi+0x108/0x140
[ 1347.148005] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1347.148005] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1347.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1347.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1347.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1347.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1347.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1347.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1347.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1347.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1347.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1347.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1347.148005] Stack:
[ 1347.148005]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1347.148005]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1347.148005]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1347.148005] Call Trace:
[ 1347.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1347.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1347.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1347.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1347.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1347.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1347.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1347.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1347.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1347.148005] Code: 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 8b 35 00 4f 9b 00 <4c> 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 2e 0f 1f 84 00 00 
[ 1347.148005] Call Trace:
[ 1347.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1347.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1347.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1347.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1347.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1347.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1347.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1347.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1347.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1384.508005] INFO: rcu_sched detected stall on CPU 14 (t=16250 jiffies)
[ 1384.508007] sending NMI to all CPUs:
[ 1384.516014] INFO: rcu_sched detected stalls on CPUs/tasks: { 14} (detected by 15, t=16252 jiffies)
[ 1384.527400] NMI backtrace for cpu 0
[ 1384.528012] CPU 0 
[ 1384.528012] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1384.528012] 
[ 1384.528012] Pid: 24575, comm: cc1 Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1384.528012] RIP: 0033:[<00002abf6f4f7c48>]  [<00002abf6f4f7c48>] 0x2abf6f4f7c47
[ 1384.528012] RSP: 002b:00007fffa24587e8  EFLAGS: 00000206
[ 1384.528012] RAX: 000000000000002b RBX: 00007fffa24587f0 RCX: 0000000000000004
[ 1384.528012] RDX: 0000000000000000 RSI: 00002abf7029b714 RDI: 00007fffa24587f0
[ 1384.528012] RBP: 00007fffa2458860 R08: fffffffffffffffc R09: 00007fffa245892e
[ 1384.528012] R10: 00002abf6ee686c0 R11: 00002abf6f4fa1c6 R12: 0000000000000000
[ 1384.528012] R13: 00002abf7029b714 R14: 0000000000000002 R15: 00007fffa245892f
[ 1384.528012] FS:  00002abf6f7d87e0(0000) GS:ffff8808ffc00000(0000) knlGS:0000000000000000
[ 1384.528012] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1384.528012] CR2: 00002abf7029e000 CR3: 00000007fb3e4000 CR4: 00000000000006f0
[ 1384.528012] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1384.528012] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1384.528012] Process cc1 (pid: 24575, threadinfo ffff8807fb3ea000, task ffff8807fb3ed640)
[ 1384.528012] 
[ 1384.528012] Call Trace:
[ 1384.508007] NMI backtrace for cpu 14
[ 1384.508007] CPU 14 
[ 1384.508007] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1384.508007] 
[ 1384.508007] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1384.508007] RIP: 0010:[<ffffffff81258d62>]  [<ffffffff81258d62>] delay_tsc+0x42/0xa0
[ 1384.508007] RSP: 0000:ffff88117fd83d30  EFLAGS: 00000093
[ 1384.508007] RAX: 00000000000000d4 RBX: 00000000000470af RCX: ffffffff8ac50e81
[ 1384.508007] RDX: 000000008ac50e81 RSI: 000000000000000f RDI: 00000000000470af
[ 1384.508007] RBP: ffff88117fd83d68 R08: 0000000000000010 R09: ffffffff819e7660
[ 1384.508007] R10: 0000000000000000 R11: 0000000000000003 R12: 0000000000001000
[ 1384.508007] R13: 0000000000000002 R14: 000000000000000e R15: 000000000000000e
[ 1384.508007] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1384.508007] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1384.508007] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1384.508007] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1384.508007] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1384.508007] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1384.508007] Stack:
[ 1384.508007]  ffffffff8ac50dad 0000000e00000046 0000000000000000 0000000000001000
[ 1384.508007]  0000000000000002 000000000000cbc0 0000000000000002 ffff88117fd83d78
[ 1384.508007]  ffffffff81258e1f ffff88117fd83d98 ffffffff81021aaa 000000000000000f
[ 1384.508007] Call Trace:
[ 1384.508007]  <IRQ> 
[ 1384.508007]  [<ffffffff81258e1f>] __const_udelay+0x2f/0x40
[ 1384.508007]  [<ffffffff81021aaa>] native_safe_apic_wait_icr_idle+0x1a/0x50
[ 1384.508007]  [<ffffffff81021fbd>] default_send_IPI_mask_sequence_phys+0xdd/0x130
[ 1384.508007]  [<ffffffff81025094>] physflat_send_IPI_all+0x14/0x20
[ 1384.508007]  [<ffffffff81022097>] arch_trigger_all_cpu_backtrace+0x67/0xb0
[ 1384.508007]  [<ffffffff810cfca9>] __rcu_pending+0x119/0x280
[ 1384.508007]  [<ffffffff810cfeba>] rcu_check_callbacks+0xaa/0x1b0
[ 1384.508007]  [<ffffffff810643c1>] update_process_times+0x41/0x80
[ 1384.508007]  [<ffffffff8108b05f>] tick_sched_timer+0x5f/0xc0
[ 1384.508007]  [<ffffffff8108b000>] ? tick_nohz_handler+0x100/0x100
[ 1384.508007]  [<ffffffff8107d951>] __run_hrtimer+0xd1/0x1d0
[ 1384.508007]  [<ffffffff8107dc97>] hrtimer_interrupt+0xc7/0x1f0
[ 1384.508007]  [<ffffffff81021a34>] smp_apic_timer_interrupt+0x64/0xa0
[ 1384.508007]  [<ffffffff81469db3>] apic_timer_interrupt+0x73/0x80
[ 1384.508007]  <EOI> 
[ 1384.508007]  [<ffffffff81033de2>] ? flush_tlb_others_ipi+0x102/0x140
[ 1384.508007]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1384.508007]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1384.508007]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1384.508007]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1384.508007]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1384.508007]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1384.508007]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1384.508007]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1384.508007]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1384.508007]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1384.508007] Code: 34 25 b0 cb 00 00 66 66 90 0f ae e8 e8 e8 15 db ff 66 90 48 98 44 89 75 d4 48 89 45 c8 eb 1b 66 2e 0f 1f 84 00 00 00 00 00 f3 90 <65> 44 8b 3c 25 b0 cb 00 00 44 3b 7d d4 75 2b 66 66 90 0f ae e8 
[ 1384.508007] Call Trace:
[ 1384.508007]  <IRQ>  [<ffffffff81258e1f>] __const_udelay+0x2f/0x40
[ 1384.508007]  [<ffffffff81021aaa>] native_safe_apic_wait_icr_idle+0x1a/0x50
[ 1384.508007]  [<ffffffff81021fbd>] default_send_IPI_mask_sequence_phys+0xdd/0x130
[ 1384.508007]  [<ffffffff81025094>] physflat_send_IPI_all+0x14/0x20
[ 1384.508007]  [<ffffffff81022097>] arch_trigger_all_cpu_backtrace+0x67/0xb0
[ 1384.508007]  [<ffffffff810cfca9>] __rcu_pending+0x119/0x280
[ 1384.508007]  [<ffffffff810cfeba>] rcu_check_callbacks+0xaa/0x1b0
[ 1384.508007]  [<ffffffff810643c1>] update_process_times+0x41/0x80
[ 1384.508007]  [<ffffffff8108b05f>] tick_sched_timer+0x5f/0xc0
[ 1384.508007]  [<ffffffff8108b000>] ? tick_nohz_handler+0x100/0x100
[ 1384.508007]  [<ffffffff8107d951>] __run_hrtimer+0xd1/0x1d0
[ 1384.508007]  [<ffffffff8107dc97>] hrtimer_interrupt+0xc7/0x1f0
[ 1384.508007]  [<ffffffff81021a34>] smp_apic_timer_interrupt+0x64/0xa0
[ 1384.508007]  [<ffffffff81469db3>] apic_timer_interrupt+0x73/0x80
[ 1384.508007]  <EOI>  [<ffffffff81033de2>] ? flush_tlb_others_ipi+0x102/0x140
[ 1384.508007]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1384.508007]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1384.508007]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1384.508007]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1384.508007]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1384.508007]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1384.508007]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1384.508007]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1384.508007]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1384.508007]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1385.089722] NMI backtrace for cpu 15
[ 1385.089722] CPU 15 
[ 1385.089722] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1385.089722] 
[ 1385.089722] Pid: 24569, comm: sh Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1385.089722] RIP: 0033:[<00002b292b250c59>]  [<00002b292b250c59>] 0x2b292b250c58
[ 1385.089722] RSP: 002b:00007fff6bb94b70  EFLAGS: 00000202
[ 1385.089722] RAX: 00002b292b520580 RBX: 00000000006b0907 RCX: 00007fff6bb94c20
[ 1385.089722] RDX: 00007fff6bb94bd0 RSI: 00000000006b0907 RDI: 00007fff6bb94bd0
[ 1385.089722] RBP: 000000000000001b R08: 00000000006b0907 R09: 0000000000000001
[ 1385.089722] R10: 0000000000000000 R11: 00007fff6bb94c20 R12: 0000000000000000
[ 1385.089722] R13: 00000000006b0907 R14: 00007fff6bb94bd0 R15: 00002b292b76eba0
[ 1385.089722] FS:  00002b292b76eba0(0000) GS:ffff88117fdc0000(0000) knlGS:0000000000000000
[ 1385.089722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1385.089722] CR2: 00000000006b1110 CR3: 00000010a023d000 CR4: 00000000000006e0
[ 1385.089722] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1385.089722] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1385.089722] Process sh (pid: 24569, threadinfo ffff8810a0224000, task ffff8810a0220d40)
[ 1385.089722] 
[ 1385.089722] Call Trace:
[ 1411.146085] BUG: soft lockup - CPU#14 stuck for 23s! [udevd:1068]
[ 1411.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1411.148005] irq event stamp: 151367944
[ 1411.148005] hardirqs last  enabled at (151367943): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1411.148005] hardirqs last disabled at (151367944): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1411.148005] softirqs last  enabled at (151367942): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1411.148005] softirqs last disabled at (151367937): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1411.148005] CPU 14 
[ 1411.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1411.148005] 
[ 1411.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1411.148005] RIP: 0010:[<ffffffff81033de2>]  [<ffffffff81033de2>] flush_tlb_others_ipi+0x102/0x140
[ 1411.148005] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1411.148005] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1411.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1411.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1411.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1411.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1411.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1411.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1411.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1411.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1411.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1411.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1411.148005] Stack:
[ 1411.148005]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1411.148005]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1411.148005]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1411.148005] Call Trace:
[ 1411.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1411.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1411.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1411.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1411.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1411.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1411.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1411.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1411.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1411.148005] Code: c3 0f 1f 84 00 00 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 <8b> 35 00 4f 9b 00 4c 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 
[ 1411.148005] Call Trace:
[ 1411.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1411.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1411.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1411.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1411.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1411.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1411.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1411.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1411.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1439.146086] BUG: soft lockup - CPU#14 stuck for 23s! [udevd:1068]
[ 1439.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1439.148005] irq event stamp: 151430582
[ 1439.148005] hardirqs last  enabled at (151430581): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1439.148005] hardirqs last disabled at (151430582): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1439.148005] softirqs last  enabled at (151430580): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1439.148005] softirqs last disabled at (151430575): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1439.148005] CPU 14 
[ 1439.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1439.148005] 
[ 1439.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1439.148005] RIP: 0010:[<ffffffff8125b883>]  [<ffffffff8125b883>] __bitmap_empty+0x13/0x90
[ 1439.148005] RSP: 0000:ffff881147bfdc38  EFLAGS: 00000246
[ 1439.148005] RAX: 000000000000004f RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1439.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1439.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1439.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdba8
[ 1439.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1439.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1439.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1439.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1439.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1439.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1439.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1439.148005] Stack:
[ 1439.148005]  ffff881147bfdc78 ffffffff81033df0 ffff881147bfdcb8 ffff881146a20d80
[ 1439.148005]  00007fff56156db8 ffff881146a20de0 ffff88114739f818 ffff881147776ab0
[ 1439.148005]  ffff881147bfdc88 ffffffff81033e29 ffff881147bfdcb8 ffffffff81033f2a
[ 1439.148005] Call Trace:
[ 1439.148005]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1439.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1439.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1439.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1439.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1439.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1439.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1439.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1439.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1439.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1439.148005] Code: c7 45 b0 10 00 00 00 48 89 45 c0 e8 38 ff ff ff c9 c3 90 90 90 90 90 90 8d 46 3f 85 f6 41 89 f0 55 44 0f 48 c0 31 d2 41 c1 f8 06 <48> 89 e5 45 85 c0 7e 2a 31 d2 48 83 3f 00 48 89 f9 74 17 eb 60 
[ 1439.148005] Call Trace:
[ 1439.148005]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1439.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1439.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1439.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1439.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1439.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1439.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1439.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1439.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1439.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1467.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1467.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1467.148005] irq event stamp: 151493442
[ 1467.148005] hardirqs last  enabled at (151493441): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1467.148005] hardirqs last disabled at (151493442): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1467.148005] softirqs last  enabled at (151493440): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1467.148005] softirqs last disabled at (151493435): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1467.148005] CPU 14 
[ 1467.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1467.148005] 
[ 1467.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1467.148005] RIP: 0010:[<ffffffff81033de2>]  [<ffffffff81033de2>] flush_tlb_others_ipi+0x102/0x140
[ 1467.148005] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1467.148005] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1467.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1467.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1467.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1467.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1467.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1467.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1467.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1467.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1467.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1467.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1467.148005] Stack:
[ 1467.148005]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1467.148005]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1467.148005]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1467.148005] Call Trace:
[ 1467.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1467.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1467.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1467.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1467.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1467.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1467.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1467.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1467.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1467.148005] Code: c3 0f 1f 84 00 00 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 <8b> 35 00 4f 9b 00 4c 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 
[ 1467.148005] Call Trace:
[ 1467.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1467.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1467.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1467.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1467.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1467.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1467.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1467.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1467.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1495.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1495.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1495.148005] irq event stamp: 151556262
[ 1495.148005] hardirqs last  enabled at (151556261): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1495.148005] hardirqs last disabled at (151556262): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1495.148005] softirqs last  enabled at (151556260): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1495.148005] softirqs last disabled at (151556255): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1495.148005] CPU 14 
[ 1495.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1495.148005] 
[ 1495.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1495.148005] RIP: 0010:[<ffffffff81033de2>]  [<ffffffff81033de2>] flush_tlb_others_ipi+0x102/0x140
[ 1495.148005] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1495.148005] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1495.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1495.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1495.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1495.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1495.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1495.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1495.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1495.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1495.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1495.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1495.148005] Stack:
[ 1495.148005]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1495.148005]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1495.148005]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1495.148005] Call Trace:
[ 1495.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1495.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1495.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1495.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1495.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1495.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1495.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1495.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1495.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1495.148005] Code: c3 0f 1f 84 00 00 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 <8b> 35 00 4f 9b 00 4c 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 
[ 1495.148005] Call Trace:
[ 1495.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1495.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1495.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1495.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1495.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1495.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1495.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1495.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1495.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1523.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1523.148004] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1523.148004] irq event stamp: 151619118
[ 1523.148004] hardirqs last  enabled at (151619117): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1523.148004] hardirqs last disabled at (151619118): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1523.148004] softirqs last  enabled at (151619116): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1523.148004] softirqs last disabled at (151619111): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1523.148004] CPU 14 
[ 1523.148004] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1523.148004] 
[ 1523.148004] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1523.148004] RIP: 0010:[<ffffffff8125b8e7>]  [<ffffffff8125b8e7>] __bitmap_empty+0x77/0x90
[ 1523.148004] RSP: 0000:ffff881147bfdc38  EFLAGS: 00000216
[ 1523.148004] RAX: 000000000000ffff RBX: ffff881147bfdbb8 RCX: 0000000000000010
[ 1523.148004] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1523.148004] RBP: ffff881147bfdc38 R08: 0000000000000000 R09: 0000000000000000
[ 1523.148004] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfc000
[ 1523.148004] R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000000
[ 1523.148004] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1523.148004] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1523.148004] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1523.148004] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1523.148004] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1523.148004] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1523.148004] Stack:
[ 1523.148004]  ffff881147bfdc78 ffffffff81033df0 ffff881147bfdcb8 ffff881146a20d80
[ 1523.148004]  00007fff56156db8 ffff881146a20de0 ffff88114739f818 ffff881147776ab0
[ 1523.148004]  ffff881147bfdc88 ffffffff81033e29 ffff881147bfdcb8 ffffffff81033f2a
[ 1523.148004] Call Trace:
[ 1523.148004]  [<ffffffff81033df0>] flush_tlb_others_ipi+0x110/0x140
[ 1523.148004]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1523.148004]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1523.148004]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1523.148004]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1523.148004]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1523.148004]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1523.148004]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1523.148004]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1523.148004]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1523.148004] Code: 00 00 75 08 c9 c3 66 0f 1f 44 00 00 89 f0 48 63 d2 c1 f8 1f c1 e8 1a 8d 0c 06 83 e1 3f 29 c1 b8 01 00 00 00 48 d3 e0 48 83 e8 01 <48> 85 04 d7 c9 0f 94 c0 0f b6 c0 c3 0f 1f 44 00 00 31 c0 c9 c3 
[ 1523.148004] Call Trace:
[ 1523.148004]  [<ffffffff81033df0>] flush_tlb_others_ipi+0x110/0x140
[ 1523.148004]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1523.148004]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1523.148004]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1523.148004]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1523.148004]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1523.148004]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1523.148004]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1523.148004]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1523.148004]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1551.146087] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1551.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1551.148005] irq event stamp: 151681846
[ 1551.148005] hardirqs last  enabled at (151681845): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1551.148005] hardirqs last disabled at (151681846): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1551.148005] softirqs last  enabled at (151681844): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1551.148005] softirqs last disabled at (151681839): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1551.148005] CPU 14 
[ 1551.148005] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1551.148005] 
[ 1551.148005] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1551.148005] RIP: 0010:[<ffffffff81033de8>]  [<ffffffff81033de8>] flush_tlb_others_ipi+0x108/0x140
[ 1551.148005] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1551.148005] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1551.148005] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1551.148005] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1551.148005] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1551.148005] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1551.148005] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1551.148005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1551.148005] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1551.148005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1551.148005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1551.148005] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1551.148005] Stack:
[ 1551.148005]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1551.148005]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1551.148005]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1551.148005] Call Trace:
[ 1551.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1551.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1551.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1551.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1551.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1551.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1551.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1551.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1551.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1551.148005] Code: 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 8b 35 00 4f 9b 00 <4c> 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 2e 0f 1f 84 00 00 
[ 1551.148005] Call Trace:
[ 1551.148005]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1551.148005]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1551.148005]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1551.148005]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1551.148005]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1551.148005]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1551.148005]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1551.148005]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1551.148005]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1579.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1579.148003] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1579.148003] irq event stamp: 151744636
[ 1579.148003] hardirqs last  enabled at (151744635): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1579.148003] hardirqs last disabled at (151744636): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1579.148003] softirqs last  enabled at (151744634): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1579.148003] softirqs last disabled at (151744629): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1579.148003] CPU 14 
[ 1579.148003] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1579.148003] 
[ 1579.148003] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1579.148003] RIP: 0010:[<ffffffff8125b8f2>]  [<ffffffff8125b8f2>] __bitmap_empty+0x82/0x90
[ 1579.148003] RSP: 0000:ffff881147bfdc40  EFLAGS: 00000206
[ 1579.148003] RAX: 0000000000000000 RBX: ffffffff81460ab4 RCX: 0000000000000010
[ 1579.148003] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1579.148003] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1579.148003] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffff881147bfdbb8
[ 1579.148003] R13: ffff8808ca7e0c80 R14: ffff881147bfc000 R15: 0000000000000000
[ 1579.148003] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1579.148003] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1579.148003] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1579.148003] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1579.148003] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1579.148003] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1579.148003] Stack:
[ 1579.148003]  ffffffff81033df0 ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8
[ 1579.148003]  ffff881146a20de0 ffff88114739f818 ffff881147776ab0 ffff881147bfdc88
[ 1579.148003]  ffffffff81033e29 ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8
[ 1579.148003] Call Trace:
[ 1579.148003]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1579.148003]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1579.148003]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1579.148003]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1579.148003]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1579.148003]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1579.148003]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1579.148003]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1579.148003]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1579.148003]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1579.148003] Code: 00 89 f0 48 63 d2 c1 f8 1f c1 e8 1a 8d 0c 06 83 e1 3f 29 c1 b8 01 00 00 00 48 d3 e0 48 83 e8 01 48 85 04 d7 c9 0f 94 c0 0f b6 c0 <c3> 0f 1f 44 00 00 31 c0 c9 c3 0f 1f 40 00 8d 46 3f 85 f6 41 89 
[ 1579.148003] Call Trace:
[ 1579.148003]  [<ffffffff81033df0>] ? flush_tlb_others_ipi+0x110/0x140
[ 1579.148003]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1579.148003]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1579.148003]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1579.148003]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1579.148003]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1579.148003]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1579.148003]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1579.148003]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1579.148003]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1579.636006] INFO: rcu_sched detected stall on CPU 14 (t=65032 jiffies)
[ 1579.636006] sending NMI to all CPUs:
[ 1579.644010] INFO: rcu_sched detected stalls on CPUs/tasks: { 14} (detected by 0, t=65034 jiffies)
[ 1579.655327] NMI backtrace for cpu 0
[ 1579.656012] CPU 0 
[ 1579.656012] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1579.656012] 
[ 1579.656012] Pid: 9736, comm: make Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1579.656012] RIP: 0010:[<ffffffff810ffe52>]  [<ffffffff810ffe52>] generic_file_aio_read+0x62/0x280
[ 1579.656012] RSP: 0018:ffff8807ce195b10  EFLAGS: 00000292
[ 1579.656012] RAX: ffff8807ce190800 RBX: ffff8807ce195c38 RCX: ffff8807ce195ab0
[ 1579.656012] RDX: ffff8807ce195ac0 RSI: ffff8807ce195ab0 RDI: ffff8807ce195aa8
[ 1579.656012] RBP: ffff8807ce195b38 R08: 0000000000000040 R09: ffff8807ce1910b8
[ 1579.656012] R10: 0000000000000000 R11: 0000000000000002 R12: 0000000000000001
[ 1579.656012] R13: 00000000000001f8 R14: ffff8807ce18e6c0 R15: ffff8807ce195ad8
[ 1579.656012] FS:  00002b9180bbe700(0000) GS:ffff8808ffc00000(0000) knlGS:0000000000000000
[ 1579.656012] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1579.656012] CR2: 00002ae261975280 CR3: 0000001146873000 CR4: 00000000000006f0
[ 1579.656012] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1579.656012] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1579.656012] Process make (pid: 9736, threadinfo ffff8807ce194000, task ffff8807ce190800)
[ 1579.656012] Stack:
[ 1579.656012]  ffff8807ce195b48 ffff8807ce195c28 ffff8807ce18e6c0 ffff8807ce195ca0
[ 1579.656012]  ffff8807ce195f58 ffff8807ce195c58 ffffffff81160f79 ffff8807ce1910b8
[ 1579.656012]  ffff8807ce190800 0000000000000000 ffffffff00000001 ffff8807ce18e6c0
[ 1579.656012] Call Trace:
[ 1579.656012]  [<ffffffff81160f79>] do_sync_read+0xd9/0x120
[ 1579.656012]  [<ffffffff81221b1d>] ? common_file_perm+0x8d/0x110
[ 1579.656012]  [<ffffffff811fc373>] ? security_file_permission+0x93/0xa0
[ 1579.656012]  [<ffffffff81161658>] vfs_read+0xc8/0x130
[ 1579.656012]  [<ffffffff81168534>] kernel_read+0x44/0x60
[ 1579.656012]  [<ffffffff811b5aa3>] load_elf_binary+0x173/0x1060
[ 1579.656012]  [<ffffffff81092531>] ? __lock_acquire+0x301/0x520
[ 1579.656012]  [<ffffffff811695cc>] ? search_binary_handler+0xfc/0x360
[ 1579.656012]  [<ffffffff811b5930>] ? load_elf_interp+0x5e0/0x5e0
[ 1579.656012]  [<ffffffff811b5930>] ? load_elf_interp+0x5e0/0x5e0
[ 1579.656012]  [<ffffffff811695d6>] search_binary_handler+0x106/0x360
[ 1579.656012]  [<ffffffff8116951e>] ? search_binary_handler+0x4e/0x360
[ 1579.656012]  [<ffffffff81169d2d>] do_execve_common+0x27d/0x320
[ 1579.656012]  [<ffffffff81169e5a>] do_execve+0x3a/0x40
[ 1579.656012]  [<ffffffff8100aac9>] sys_execve+0x49/0x70
[ 1579.656012]  [<ffffffff8146972c>] stub_execve+0x6c/0xc0
[ 1579.656012] Code: c8 4c 8b 77 20 4c 89 e7 48 89 85 58 ff ff ff 48 c7 45 c8 00 00 00 00 e8 8d d8 ff ff 4c 63 e8 4d 85 ed 74 15 48 81 c4 88 00 00 00 <4c> 89 e8 5b 41 5c 41 5d 41 5e 41 5f c9 c3 48 8d bd 70 ff ff ff 
[ 1579.656012] Call Trace:
[ 1579.656012]  [<ffffffff81160f79>] do_sync_read+0xd9/0x120
[ 1579.656012]  [<ffffffff81221b1d>] ? common_file_perm+0x8d/0x110
[ 1579.656012]  [<ffffffff811fc373>] ? security_file_permission+0x93/0xa0
[ 1579.656012]  [<ffffffff81161658>] vfs_read+0xc8/0x130
[ 1579.656012]  [<ffffffff81168534>] kernel_read+0x44/0x60
[ 1579.656012]  [<ffffffff811b5aa3>] load_elf_binary+0x173/0x1060
[ 1579.656012]  [<ffffffff81092531>] ? __lock_acquire+0x301/0x520
[ 1579.656012]  [<ffffffff811695cc>] ? search_binary_handler+0xfc/0x360
[ 1579.656012]  [<ffffffff811b5930>] ? load_elf_interp+0x5e0/0x5e0
[ 1579.656012]  [<ffffffff811b5930>] ? load_elf_interp+0x5e0/0x5e0
[ 1579.656012]  [<ffffffff811695d6>] search_binary_handler+0x106/0x360
[ 1579.656012]  [<ffffffff8116951e>] ? search_binary_handler+0x4e/0x360
[ 1579.656012]  [<ffffffff81169d2d>] do_execve_common+0x27d/0x320
[ 1579.656012]  [<ffffffff81169e5a>] do_execve+0x3a/0x40
[ 1579.656012]  [<ffffffff8100aac9>] sys_execve+0x49/0x70
[ 1579.656012]  [<ffffffff8146972c>] stub_execve+0x6c/0xc0
[ 1579.636006] NMI backtrace for cpu 14
[ 1579.636006] CPU 14 
[ 1579.636006] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1579.636006] 
[ 1579.636006] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1579.636006] RIP: 0010:[<ffffffff81258d71>]  [<ffffffff81258d71>] delay_tsc+0x51/0xa0
[ 1579.636006] RSP: 0000:ffff88117fd83d30  EFLAGS: 00000046
[ 1579.636006] RAX: 0000000000000042 RBX: 00000000000470af RCX: ffffffffd032bab4
[ 1579.636006] RDX: 00000000d032bab4 RSI: 000000000000000f RDI: 00000000000470af
[ 1579.636006] RBP: ffff88117fd83d68 R08: 0000000000000010 R09: ffffffff819e7660
[ 1579.636006] R10: 0000000000000000 R11: 0000000000000003 R12: 0000000000001000
[ 1579.636006] R13: 0000000000000002 R14: 000000000000000e R15: 000000000000000e
[ 1579.636006] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1579.636006] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1579.636006] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1579.636006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1579.636006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1579.636006] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1579.636006] Stack:
[ 1579.636006]  ffffffffd032ba72 0000000e00000046 0000000000000000 0000000000001000
[ 1579.636006]  0000000000000002 000000000000cbc0 0000000000000002 ffff88117fd83d78
[ 1579.636006]  ffffffff81258e1f ffff88117fd83d98 ffffffff81021aaa 000000000000000f
[ 1579.636006] Call Trace:
[ 1579.636006]  <IRQ> 
[ 1579.636006]  [<ffffffff81258e1f>] __const_udelay+0x2f/0x40
[ 1579.636006]  [<ffffffff81021aaa>] native_safe_apic_wait_icr_idle+0x1a/0x50
[ 1579.636006]  [<ffffffff81021fbd>] default_send_IPI_mask_sequence_phys+0xdd/0x130
[ 1579.636006]  [<ffffffff81025094>] physflat_send_IPI_all+0x14/0x20
[ 1579.636006]  [<ffffffff81022097>] arch_trigger_all_cpu_backtrace+0x67/0xb0
[ 1579.636006]  [<ffffffff810cfca9>] __rcu_pending+0x119/0x280
[ 1579.636006]  [<ffffffff810cfeba>] rcu_check_callbacks+0xaa/0x1b0
[ 1579.636006]  [<ffffffff810643c1>] update_process_times+0x41/0x80
[ 1579.636006]  [<ffffffff8108b05f>] tick_sched_timer+0x5f/0xc0
[ 1579.636006]  [<ffffffff8108b000>] ? tick_nohz_handler+0x100/0x100
[ 1579.636006]  [<ffffffff8107d951>] __run_hrtimer+0xd1/0x1d0
[ 1579.636006]  [<ffffffff8107dc97>] hrtimer_interrupt+0xc7/0x1f0
[ 1579.636006]  [<ffffffff81021a34>] smp_apic_timer_interrupt+0x64/0xa0
[ 1579.636006]  [<ffffffff81469db3>] apic_timer_interrupt+0x73/0x80
[ 1579.636006]  <EOI> 
[ 1579.636006]  [<ffffffff8125b8eb>] ? __bitmap_empty+0x7b/0x90
[ 1579.636006]  [<ffffffff81033df0>] flush_tlb_others_ipi+0x110/0x140
[ 1579.636006]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1579.636006]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1579.636006]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1579.636006]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1579.636006]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1579.636006]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1579.636006]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1579.636006]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1579.636006]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1579.636006] Code: db ff 66 90 48 98 44 89 75 d4 48 89 45 c8 eb 1b 66 2e 0f 1f 84 00 00 00 00 00 f3 90 65 44 8b 3c 25 b0 cb 00 00 44 3b 7d d4 75 2b <66> 66 90 0f ae e8 e8 b4 15 db ff 66 90 48 63 c8 48 89 c8 48 2b 
[ 1579.636006] Call Trace:
[ 1579.636006]  <IRQ>  [<ffffffff81258e1f>] __const_udelay+0x2f/0x40
[ 1579.636006]  [<ffffffff81021aaa>] native_safe_apic_wait_icr_idle+0x1a/0x50
[ 1579.636006]  [<ffffffff81021fbd>] default_send_IPI_mask_sequence_phys+0xdd/0x130
[ 1579.636006]  [<ffffffff81025094>] physflat_send_IPI_all+0x14/0x20
[ 1579.636006]  [<ffffffff81022097>] arch_trigger_all_cpu_backtrace+0x67/0xb0
[ 1579.636006]  [<ffffffff810cfca9>] __rcu_pending+0x119/0x280
[ 1579.636006]  [<ffffffff810cfeba>] rcu_check_callbacks+0xaa/0x1b0
[ 1579.636006]  [<ffffffff810643c1>] update_process_times+0x41/0x80
[ 1579.636006]  [<ffffffff8108b05f>] tick_sched_timer+0x5f/0xc0
[ 1579.636006]  [<ffffffff8108b000>] ? tick_nohz_handler+0x100/0x100
[ 1579.636006]  [<ffffffff8107d951>] __run_hrtimer+0xd1/0x1d0
[ 1579.636006]  [<ffffffff8107dc97>] hrtimer_interrupt+0xc7/0x1f0
[ 1579.636006]  [<ffffffff81021a34>] smp_apic_timer_interrupt+0x64/0xa0
[ 1579.636006]  [<ffffffff81469db3>] apic_timer_interrupt+0x73/0x80
[ 1579.636006]  <EOI>  [<ffffffff8125b8eb>] ? __bitmap_empty+0x7b/0x90
[ 1579.636006]  [<ffffffff81033df0>] flush_tlb_others_ipi+0x110/0x140
[ 1579.636006]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1579.636006]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1579.636006]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1579.636006]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1579.636006]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1579.636006]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1579.636006]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1579.636006]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1579.636006]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1580.574143] NMI backtrace for cpu 15
[ 1580.576011] CPU 15 
[ 1580.576011] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1580.576011] 
[ 1580.576011] Pid: 9869, comm: sh Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1580.576011] RIP: 0010:[<ffffffff8125a1f4>]  [<ffffffff8125a1f4>] restore+0xe/0x3a
[ 1580.576011] RSP: 0000:ffff8810760aff00  EFLAGS: 00000006
[ 1580.576011] RAX: 0000000000000dbe RBX: 0000000000000000 RCX: 0000000000000000
[ 1580.576011] RDX: ffff8810760dcbc0 RSI: 000000000068cd50 RDI: ffffffff81460f06
[ 1580.576011] RBP: 00007fff2d19ee70 R08: 0000000000000000 R09: 0000000000000005
[ 1580.576011] R10: 0000000000478df0 R11: ffffffffffffffff R12: 000000000068cd50
[ 1580.576011] R13: 000000000068cd50 R14: 0000000000000030 R15: 000000000069ce00
[ 1580.576011] FS:  00002b28f9fc1ba0(0000) GS:ffff88117fdc0000(0000) knlGS:0000000000000000
[ 1580.576011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1580.576011] CR2: 000000000068c1e0 CR3: 000000107602d000 CR4: 00000000000006e0
[ 1580.576011] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1580.576011] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1580.576011] Process sh (pid: 9869, threadinfo ffff8810760ae000, task ffff8810760dcbc0)
[ 1580.576011] Stack:
[ 1580.576011]  ffffffffffffffff 0000000000478df0 0000000000000005 0000000000000000
[ 1580.576011]  0000000000477790 0000000000000000 0000000000000030 000000000068cd50
[ 1580.576011]  000000000068c1e0 ffffffff81460f06 ffffffff81460caf 000000000069ce00
[ 1580.576011] Call Trace:
[ 1580.576011]  [<ffffffff81460f06>] ? error_sti+0x5/0x6
[ 1580.576011]  [<ffffffff81460caf>] ? page_fault+0xf/0x30
[ 1580.576011] Code: 48 89 4c 24 28 48 89 44 24 20 4c 89 44 24 18 4c 89 4c 24 10 4c 89 54 24 08 4c 89 1c 24 4c 8b 1c 24 4c 8b 54 24 08 4c 8b 4c 24 10 <4c> 8b 44 24 18 48 8b 44 24 20 48 8b 4c 24 28 48 8b 54 24 30 48 
[ 1580.576011] Call Trace:
[ 1580.576011]  [<ffffffff81460f06>] ? error_sti+0x5/0x6
[ 1580.576011]  [<ffffffff81460caf>] ? page_fault+0xf/0x30
[ 1607.146085] BUG: soft lockup - CPU#14 stuck for 22s! [udevd:1068]
[ 1607.148003] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1607.148003] irq event stamp: 151806026
[ 1607.148003] hardirqs last  enabled at (151806025): [<ffffffff81460ab4>] restore_args+0x0/0x30
[ 1607.148003] hardirqs last disabled at (151806026): [<ffffffff81469dae>] apic_timer_interrupt+0x6e/0x80
[ 1607.148003] softirqs last  enabled at (151806024): [<ffffffff8105bc31>] __do_softirq+0x1a1/0x200
[ 1607.148003] softirqs last disabled at (151806019): [<ffffffff8146b53c>] call_softirq+0x1c/0x30
[ 1607.148003] CPU 14 
[ 1607.148003] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod usbhid i2c_i801 ioatdma i2c_core hid cdc_ether usbnet bnx2 serio_raw mii i7core_edac sg iTCO_wdt dca shpchp iTCO_vendor_support pcspkr mptctl edac_core rtc_cmos tpm_tis tpm tpm_bios button pci_hotplug uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
[ 1607.148003] 
[ 1607.148003] Pid: 1068, comm: udevd Tainted: G        W    3.2.0-rc7-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033     
[ 1607.148003] RIP: 0010:[<ffffffff81033de2>]  [<ffffffff81033de2>] flush_tlb_others_ipi+0x102/0x140
[ 1607.148003] RSP: 0000:ffff881147bfdc48  EFLAGS: 00000246
[ 1607.148003] RAX: 0000000000000000 RBX: 0000000000000002 RCX: 0000000000000010
[ 1607.148003] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffffffff81bbcfc8
[ 1607.148003] RBP: ffff881147bfdc78 R08: 0000000000000000 R09: 0000000000000000
[ 1607.148003] R10: 0000000000000002 R11: ffff8811475a8580 R12: ffffffff81460ab4
[ 1607.148003] R13: 000000000000000e R14: ffff881147bfdba8 R15: ffff8808ca7e0c80
[ 1607.148003] FS:  00007fbaa8d43780(0000) GS:ffff88117fd80000(0000) knlGS:0000000000000000
[ 1607.148003] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1607.148003] CR2: 00007fff56156db8 CR3: 00000011473a0000 CR4: 00000000000006e0
[ 1607.148003] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1607.148003] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1607.148003] Process udevd (pid: 1068, threadinfo ffff881147bfc000, task ffff881146fe96c0)
[ 1607.148003] Stack:
[ 1607.148003]  ffff881147bfdcb8 ffff881146a20d80 00007fff56156db8 ffff881146a20de0
[ 1607.148003]  ffff88114739f818 ffff881147776ab0 ffff881147bfdc88 ffffffff81033e29
[ 1607.148003]  ffff881147bfdcb8 ffffffff81033f2a ffff881146a20df8 0000000000000001
[ 1607.148003] Call Trace:
[ 1607.148003]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1607.148003]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1607.148003]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1607.148003]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1607.148003]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1607.148003]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1607.148003]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1607.148003]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1607.148003]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1607.148003] Code: c3 0f 1f 84 00 00 00 00 00 48 8b 05 91 14 9b 00 41 8d b7 cf 00 00 00 4c 89 e7 ff 90 d0 00 00 00 eb 09 0f 1f 80 00 00 00 00 f3 90 <8b> 35 00 4f 9b 00 4c 89 e7 e8 80 7a 22 00 85 c0 74 ec eb 84 66 
[ 1607.148003] Call Trace:
[ 1607.148003]  [<ffffffff81033e29>] native_flush_tlb_others+0x9/0x10
[ 1607.148003]  [<ffffffff81033f2a>] flush_tlb_page+0x5a/0xa0
[ 1607.148003]  [<ffffffff81032a4d>] ptep_set_access_flags+0x4d/0x70
[ 1607.148003]  [<ffffffff811268a9>] do_wp_page+0x469/0x7e0
[ 1607.148003]  [<ffffffff81127acd>] handle_pte_fault+0x19d/0x1e0
[ 1607.148003]  [<ffffffff81127c88>] handle_mm_fault+0x178/0x2e0
[ 1607.148003]  [<ffffffff81464315>] do_page_fault+0x1e5/0x490
[ 1607.148003]  [<ffffffff8125a17d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[ 1607.148003]  [<ffffffff81460cc5>] page_fault+0x25/0x30
[ 1607.553462] CPU 14 MCA banks CMCI:6 CMCI:8
[ 1607.562277] Broke affinity for irq 74
[ 1607.564339] Broke affinity for irq 80
[ 1607.570964] CPU 14 is now offline
[ 1607.576191] CPU 15 MCA banks CMCI:6 CMCI:8
[ 1607.582947] Broke affinity for irq 76
[ 1607.587820] CPU 15 is now offline
[ 1607.591275] lockdep: fixing up alternatives.
[ 1607.595716] SMP alternatives: switching to UP code
[ 1607.656141] lockdep: fixing up alternatives.
[ 1607.660614] SMP alternatives: switching to SMP code
[ 1607.669045] Booting Node 0 Processor 1 APIC 0x2
[ 1607.673721] smpboot cpu 1: start_ip = 97000
[ 1319.218635] Calibrating delay loop (skipped) already calibrated this CPU
[ 1607.697178] NMI watchdog enabled, takes one hw-pmu counter.
[ 1607.715459] lockdep: fixing up alternatives.
[ 1607.719911] Booting Node 0 Processor 2 APIC 0x4
[ 1607.724552] smpboot cpu 2: start_ip = 97000
[ 1319.242949] Calibrating delay loop (skipped) already calibrated this CPU
[ 1607.747636] NMI watchdog enabled, takes one hw-pmu counter.
[ 1607.760177] lockdep: fixing up alternatives.
[ 1607.764552] Booting Node 0 Processor 3 APIC 0x6
[ 1607.769178] smpboot cpu 3: start_ip = 97000
[ 1319.271602] Calibrating delay loop (skipped) already calibrated this CPU
[ 1607.792496] NMI watchdog enabled, takes one hw-pmu counter.
[ 1607.803598] lockdep: fixing up alternatives.


Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
