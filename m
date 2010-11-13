From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [BUG 2.6.27-rc1] find_busiest_group() LOCKUP
Date: Sat, 13 Nov 2010 16:40:18 +0800
Message-ID: <20101113084018.GA23098@localhost>
References: <20101111100628.GA24728@localhost>
 <1289478978.2084.74.camel@laptop>
 <20101111124015.GA9706@localhost>
 <1289480656.2084.80.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PHBez-00032K-S1
	for glkm-linux-mm-2@m.gmane.org; Sat, 13 Nov 2010 09:40:35 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 969628D0001
	for <linux-mm@kvack.org>; Sat, 13 Nov 2010 03:40:26 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1289480656.2084.80.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Nikanth Karthikesan <knikanth@suse.de>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-hotplug@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, Nov 11, 2010 at 09:04:16PM +0800, Peter Zijlstra wrote:
> On Thu, 2010-11-11 at 20:40 +0800, Wu Fengguang wrote:
> > On Thu, Nov 11, 2010 at 08:36:18PM +0800, Peter Zijlstra wrote:
> > > On Thu, 2010-11-11 at 18:06 +0800, Wu Fengguang wrote:
> > > > 
> > > > I run into this kernel panic since 2.6.27-rc1.  2.6.36 boots OK.
> > > > It's not yet fixed in 2.6.37-rc1-next-20101110. I can conveniently
> > > > test any debug patches.
> > > > 
> > > Happen to have a .config handy? I've never seen this..
> > 
> > Here it is. 
> 
> When I boot that .config and use the sched_debug boot param I get lots
> of interesting stuff:
> 
> [    1.187507] CPU0 attaching sched-domain:
> [    1.191431]  domain 0: span 0-5 level MC
> [    1.195373]   groups: 0 1 2 3 4 5
> [    1.198812] ERROR: parent span is not a superset of domain->span
> [    1.204813]   domain 1: span 0-4,6 level CPU
> [    1.209100] ERROR: domain->groups does not contain CPU0
> [    1.214324]    groups: 5 (cpu_power = 6144) 7 (cpu_power = 2048)
> [    1.220417] ERROR: groups don't span domain->span
> [    1.225118]    domain 2: span 0-7 level NODE
> [    1.229403]     groups:
> [    1.231868] ERROR: domain->cpu_power not set
> 
> 
> Looks like something is totally screwy there and we start the
> load-balancer before we actually build the sched domain tree or
> something silly like that.
> 
> Will try and figure out how the heck that's happening, Ingo any clue?

It's back to normal on 2.6.37-rc1 when reverting commit 50f2d7f682f9
("x86, numa: Assign CPUs to nodes in round-robin manner on fake NUMA").

The interesting part is, the commit was introduced in 
2.6.36-rc7..2.6.36, however 2.6.36 boots OK, while 2.6.37-rc1 panics.

Thanks,
Fengguang
---

Here is the boot log for 2.6.37-rc1 and
2.6.37-rc1+revert-50f2d7f682f9.

[    0.000000] console [ttyS0] enabled, bootconsole disabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] allocated 62914560 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] ODEBUG: 15 of 15 active objects replaced
[    0.000000] hpet clockevent registered
[    0.001000] Fast TSC calibration using PIT
[    0.002000] Detected 2666.944 MHz processor.
[    0.000009] Calibrating delay loop (skipped), value calculated using timer frequency.. 5333.88 BogoMIPS (lpj=2666944)
[    0.010803] pid_max: default: 32768 minimum: 301
[    0.018268] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.028595] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.036480] Mount-cache hash table entries: 256
[    0.041352] Initializing cgroup subsys debug
[    0.045726] Initializing cgroup subsys ns
[    0.049827] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[    0.058842] Initializing cgroup subsys cpuacct
[    0.063380] Initializing cgroup subsys memory
[    0.067858] Initializing cgroup subsys devices
[    0.072392] Initializing cgroup subsys freezer
[    0.076962] CPU: Physical Processor ID: 0
[    0.081060] CPU: Processor Core ID: 0
[    0.084814] mce: CPU supports 9 MCE banks
[    0.088929] CPU0: Thermal monitoring enabled (TM1)
[    0.093821] using mwait in idle threads.
[    0.097838] Performance Events: PEBS fmt1+, Nehalem events, Intel PMU driver.
[    0.105200] ... version:                3
[    0.109299] ... bit width:              48
[    0.113484] ... generic registers:      4
[    0.117582] ... value mask:             0000ffffffffffff
[    0.122978] ... max period:             000000007fffffff
[    0.128372] ... fixed-purpose events:   3
[    0.132466] ... event mask:             000000070000000f
[    0.138858] ACPI: Core revision 20101013
[    0.162577] ftrace: allocating 24175 entries in 95 pages
[    0.177764] Setting APIC routing to flat
[    0.182283] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.198348] CPU0: Genuine Intel(R) CPU             000  @ 2.67GHz stepping 04
[    0.312090] lockdep: fixing up alternatives.
[    0.317093] Booting Node   0, Processors  #1lockdep: fixing up alternatives.
[    0.416923]  #2lockdep: fixing up alternatives.
[    0.513685]  #3lockdep: fixing up alternatives.
[    0.610397]  #4lockdep: fixing up alternatives.
[    0.707147]  Ok.
[    0.709075] Booting Node   1, Processors  #5lockdep: fixing up alternatives.
[    0.808884]  Ok.
[    0.810815] Booting Node   0, Processors  #6lockdep: fixing up alternatives.
[    0.910610]  Ok.
[    0.912540] Booting Node   1, Processors  #7 Ok.
[    1.007299] Brought up 8 CPUs
[    1.010357] Total of 8 processors activated (42661.82 BogoMIPS).
[    1.016489] Testing NMI watchdog ... OK.
[    1.044458] CPU0 attaching sched-domain:
[    1.048473]  domain 0: span 0-3 level MC
[    1.052528]   groups: 0 1 2 3
[    1.055786]   domain 1: span 0-4,6 level CPU
[    1.060184]    groups: 0-3 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.066832] ERROR: repeated CPUs
[    1.070147]
[    1.071736] ERROR: groups don't span domain->span
[    1.076522]    domain 2: span 0-7 level NODE
[    1.080924]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.087842] CPU1 attaching sched-domain:
[    1.091859]  domain 0: span 0-3 level MC
[    1.095904]   groups: 1 2 3 0
[    1.099168]   domain 1: span 0-4,6 level CPU
[    1.103574]    groups: 0-3 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.110236] ERROR: repeated CPUs
[    1.113550]
[    1.115134] ERROR: groups don't span domain->span
[    1.119925]    domain 2: span 0-7 level NODE
[    1.124331]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.131252] CPU2 attaching sched-domain:
[    1.135256]  domain 0: span 0-3 level MC
[    1.139313]   groups: 2 3 0 1
[    1.142566]   domain 1: span 0-4,6 level CPU
[    1.146965]    groups: 0-3 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.153597] ERROR: repeated CPUs
[    1.156910]
[    1.158493] ERROR: groups don't span domain->span
[    1.163283]    domain 2: span 0-7 level NODE
[    1.167688]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.174586] CPU3 attaching sched-domain:
[    1.178593]  domain 0: span 0-3 level MC
[    1.182651]   groups: 3 0 1 2
[    1.185905]   domain 1: span 0-4,6 level CPU
[    1.190308]    groups: 0-3 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.196965] ERROR: repeated CPUs
[    1.200277]
[    1.201857] ERROR: groups don't span domain->span
[    1.206647]    domain 2: span 0-7 level NODE
[    1.211045]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.217955] CPU4 attaching sched-domain:
[    1.221960]  domain 0: span 4-7 level MC
[    1.226018]   groups: 4 5 6 7
[    1.229261] ERROR: parent span is not a superset of domain->span
[    1.235346]   domain 1: span 0-4,6 level CPU
[    1.239745] ERROR: domain->groups does not contain CPU4
[    1.245052]    groups: 5,7 (cpu_power = 4096)
[    1.249623] ERROR: groups don't span domain->span
[    1.254413]    domain 2: span 0-7 level NODE
[    1.258816]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.265730] CPU5 attaching sched-domain:
[    1.269737]  domain 0: span 4-7 level MC
[    1.273786]   groups: 5 6 7 4
[    1.277038] ERROR: parent span is not a superset of domain->span
[    1.283126]   domain 1: span 5,7 level CPU
[    1.287362]    groups: 5,7 (cpu_power = 4096)
[    1.291933]    domain 2: span 0-7 level NODE
[    1.296335]     groups: 5,7 (cpu_power = 4096) 0-4,6 (cpu_power = 4096)
[    1.304845] CPU6 attaching sched-domain:
[    1.308855]  domain 0: span 4-7 level MC
[    1.312913]   groups: 6 7 4 5
[    1.316162] ERROR: parent span is not a superset of domain->span
[    1.322252]   domain 1: span 0-4,6 level CPU
[    1.326661] ERROR: domain->groups does not contain CPU6
[    1.331972]    groups: 5,7 (cpu_power = 4096)
[    1.336560] ERROR: groups don't span domain->span
[    1.341352]    domain 2: span 0-7 level NODE
[    1.345755]     groups: 0-4,6 (cpu_power = 4096) 5,7 (cpu_power = 4096)
[    1.352664] CPU7 attaching sched-domain:
[    1.356679]  domain 0: span 4-7 level MC
[    1.360736]   groups: 7 4 5 6
[    1.363976] ERROR: parent span is not a superset of domain->span
[    1.370064]   domain 1: span 5,7 level CPU
[    1.374295]    groups: 5,7 (cpu_power = 4096)
[    1.378861]    domain 2: span 0-7 level NODE
[    1.383260]     groups: 5,7 (cpu_power = 4096) 0-4,6 (cpu_power = 4096)
[    6.527397] BUG: NMI Watchdog detected LOCKUP on CPU0, ip ffffffff8136b420, registers:
[    6.535490] CPU 0
[    6.537345] Modules linked in:
[    6.540795]
[    6.542371] Pid: 1, comm: swapper Tainted: G        W   2.6.37-rc1 #108 X8DTN/X8DTN
[    6.550167] RIP: 0010:[<ffffffff8136b420>]  [<ffffffff8136b420>] find_next_bit+0x90/0x180
[    6.558520] RSP: 0018:ffff8801b966d830  EFLAGS: 00000006
[    6.563914] RAX: 0000000000000080 RBX: ffffffff821b1860 RCX: 0000000000000003
[    6.571124] RDX: 0000000000000001 RSI: ffffffffffffffff RDI: 0000000000000008
[    6.578335] RBP: ffff8801b966d830 R08: ffff8800bac0e410 R09: 0000000000000000
[    6.585544] R10: 0000000000000003 R11: 0000000000000000 R12: ffff8800bac0e410
[    6.592753] R13: ffff8800ba40de48 R14: 00000000001d2d00 R15: 0000000000000005
[    6.599966] FS:  0000000000000000(0000) GS:ffff8800ba400000(0000) knlGS:0000000000000000
[    6.608190] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    6.614016] CR2: 0000000000000000 CR3: 0000000001ee1000 CR4: 00000000000006f0
[    6.621228] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    6.628438] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    6.635647] Process swapper (pid: 1, threadinfo ffff8801b966c000, task ffff8800b3778000)
[    6.643877] Stack:
[    6.645976]  ffff8801b966d860 ffffffff8136ab33 0000000000000000 ffff8801b966daec
[    6.653682]  00000000001d2d00 ffff8800ba40de48 ffff8801b966da30 ffffffff810a994d
[    6.661366]  ffff8801b966d890 ffff8801b966d9d0 0000000000000005 ffff8801bfbd2d00
[    6.669052] Call Trace:
[    6.671584]  [<ffffffff8136ab33>] cpumask_next_and+0x73/0x90
[    6.677323]  [<ffffffff810a994d>] find_busiest_group+0x2ed/0x1480
[    6.683495]  [<ffffffff810929ed>] ? __phys_addr+0x5d/0x120
[    6.689062]  [<ffffffff810b2614>] load_balance+0xe4/0xcb0
[    6.694541]  [<ffffffff810b0b54>] ? dequeue_task_fair+0x1f4/0x250
[    6.700715]  [<ffffffff8199be1d>] schedule+0xb0d/0x14b0
[    6.706020]  [<ffffffff810cc60e>] ? __sysctl_head_next+0x19e/0x1a0
[    6.712283]  [<ffffffff8199d29d>] schedule_timeout+0x50d/0x570
[    6.718192]  [<ffffffff8110b9bc>] ? print_lock_contention_bug+0x2c/0x110
[    6.724973]  [<ffffffff810af7a1>] ? get_parent_ip+0x11/0x90
[    6.730621]  [<ffffffff819a7c7d>] ? sub_preempt_count+0x12d/0x1f0
[    6.736795]  [<ffffffff8199b0cb>] wait_for_common+0x16b/0x290
[    6.742621]  [<ffffffff810b4950>] ? default_wake_function+0x0/0x20
[    6.748886]  [<ffffffff8199b30d>] wait_for_completion+0x1d/0x20
[    6.754894]  [<ffffffff810efdfb>] kthread_create+0x9b/0x150
[    6.760549]  [<ffffffff810e8310>] ? rescuer_thread+0x0/0x2a0
[    6.766291]  [<ffffffff81202078>] ? __kmalloc_node+0x2b8/0x340
[    6.772203]  [<ffffffff810e7d5a>] __alloc_workqueue_key+0x27a/0x830
[    6.778550]  [<ffffffff8263b23f>] cpuset_init_smp+0x56/0x8c
[    6.784202]  [<ffffffff8261d148>] kernel_init+0x17a/0x27c
[    6.789680]  [<ffffffff81051a24>] kernel_thread_helper+0x4/0x10
[    6.795680]  [<ffffffff819a2bd4>] ? restore_args+0x0/0x30
[    6.801159]  [<ffffffff8261cfce>] ? kernel_init+0x0/0x27c
[    6.806640]  [<ffffffff81051a20>] ? kernel_thread_helper+0x0/0x10
[    6.812812] Code: ff 89 d1 48 89 f0 48 d3 e0 48 89 c2 49 8b 00 48 21 d0 31 d2 48 83 ff 3f 0f 96 c2 48 63 ca 48 83 c1 02 48 83 04 cd 88 20 1b 82 01 <85> d2 0f 85 d0 00 00 00 31 d2 48 85 c0 0f 95 c2 48 63 ca 48 83
[    6.834439] ---[ end trace 4eaa2a86a8e2da23 ]---
[    6.839140] Kernel panic - not syncing: Non maskable interrupt
[    6.845052] Pid: 1, comm: swapper Tainted: G      D W   2.6.37-rc1 #108
[    6.851738] Call Trace:
[    6.854270]  <NMI>  [<ffffffff8136b420>] ? find_next_bit+0x90/0x180
[    6.860658]  [<ffffffff8199ac70>] panic+0xb1/0x222
[    6.865533]  [<ffffffff8136b420>] ? find_next_bit+0x90/0x180
[    6.871274]  [<ffffffff819a43c3>] die_nmi+0x153/0x180
[    6.876409]  [<ffffffff819a5009>] nmi_watchdog_tick+0x219/0x270
[    6.882411]  [<ffffffff819a38ba>] do_nmi+0x2fa/0x490
[    6.887455]  [<ffffffff819a3130>] nmi+0x20/0x39
[    6.892074]  [<ffffffff8136b420>] ? find_next_bit+0x90/0x180
[    6.897813]  <<EOE>>  [<ffffffff8136ab33>] cpumask_next_and+0x73/0x90
[    6.904372]  [<ffffffff810a994d>] find_busiest_group+0x2ed/0x1480
[    6.910548]  [<ffffffff810929ed>] ? __phys_addr+0x5d/0x120
[    6.916115]  [<ffffffff810b2614>] load_balance+0xe4/0xcb0
[    6.921595]  [<ffffffff810b0b54>] ? dequeue_task_fair+0x1f4/0x250
[    6.927769]  [<ffffffff8199be1d>] schedule+0xb0d/0x14b0
[    6.933077]  [<ffffffff810cc60e>] ? __sysctl_head_next+0x19e/0x1a0
[    6.939336]  [<ffffffff8199d29d>] schedule_timeout+0x50d/0x570
[    6.945247]  [<ffffffff8110b9bc>] ? print_lock_contention_bug+0x2c/0x110
[    6.952027]  [<ffffffff810af7a1>] ? get_parent_ip+0x11/0x90
[    6.957675]  [<ffffffff819a7c7d>] ? sub_preempt_count+0x12d/0x1f0
[    6.963850]  [<ffffffff8199b0cb>] wait_for_common+0x16b/0x290
[    6.969676]  [<ffffffff810b4950>] ? default_wake_function+0x0/0x20
[    6.975934]  [<ffffffff8199b30d>] wait_for_completion+0x1d/0x20
[    6.981935]  [<ffffffff810efdfb>] kthread_create+0x9b/0x150
[    6.987585]  [<ffffffff810e8310>] ? rescuer_thread+0x0/0x2a0
[    6.993326]  [<ffffffff81202078>] ? __kmalloc_node+0x2b8/0x340
[    6.999239]  [<ffffffff810e7d5a>] __alloc_workqueue_key+0x27a/0x830
[    7.005586]  [<ffffffff8263b23f>] cpuset_init_smp+0x56/0x8c
[    7.011236]  [<ffffffff8261d148>] kernel_init+0x17a/0x27c
[    7.016717]  [<ffffffff81051a24>] kernel_thread_helper+0x4/0x10
[    7.022717]  [<ffffffff819a2bd4>] ? restore_args+0x0/0x30
[    7.028197]  [<ffffffff8261cfce>] ? kernel_init+0x0/0x27c
[    7.033676]  [<ffffffff81051a20>] ? kernel_thread_helper+0x0/0x10
[    8.131629] Rebooting in 10 seconds..

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Linux version 2.6.37-rc1+ (wfg@bee) (gcc version 4.5.0 (GCC) ) #107 SMP PREEMPT Sat Nov 13 15:43:33 CST 2010
[    0.000000] Command line: ip=::::wfg-ne02::dhcp netconsole=@:/eth0,6666@10.239.51.110/00:30:48:fe:19:94 panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=tty0 console=ttyS0,115200 earlyprintk=vga bisect-reboot sched_debug nfsroot=10.239.51.240:/nfsroot/wfg,tcp,v3,rsize=524288,wsize=524288 rw BOOT_IMAGE=x86_64/vmlinuz
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d800 (usable)
[    0.000000]  BIOS-e820: 000000000009d800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000bf341000 (usable)
[    0.000000]  BIOS-e820: 00000000bf341000 - 00000000bf3c2000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf3c2000 - 00000000bf3c3000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000bf3c3000 - 00000000bf3d4000 (reserved)
[    0.000000]  BIOS-e820: 00000000bf3d4000 - 00000000bf3d5000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf3d5000 - 00000000bf3e6000 (reserved)
[    0.000000]  BIOS-e820: 00000000bf3e6000 - 00000000bf3e9000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf3e9000 - 00000000bf447000 (reserved)
[    0.000000]  BIOS-e820: 00000000bf447000 - 00000000bf452000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000bf452000 - 00000000bf45d000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf45d000 - 00000000bf47b000 (reserved)
[    0.000000]  BIOS-e820: 00000000bf47b000 - 00000000bf67e000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf67e000 - 00000000bf800000 (usable)
[    0.000000]  BIOS-e820: 00000000c0000000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 00000001c0000000 (usable)
[    0.000000] bootconsole [earlyvga0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: X8DTN/X8DTN, BIOS 4.6.3 03/05/2009
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] last_pfn = 0x1c0000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FE00000000 write-back
[    0.000000]   1 base 01C0000000 mask FFC0000000 uncachable
[    0.000000]   2 base 00C0000000 mask FFC0000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000c0000000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0xbf800 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [ffff8800000fdf20] fdf20
[    0.000000] Scanning 0 areas for low memory corruption
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000bf800000
[    0.000000]  0000000000 - 00bf800000 page 4k
[    0.000000] kernel direct mapping tables up to bf800000 @ 1fa00000-20000000
[    0.000000] init_memory_mapping: 0000000100000000-00000001c0000000
[    0.000000]  0100000000 - 01c0000000 page 4k
[    0.000000] kernel direct mapping tables up to 1c0000000 @ be539000-bf341000
[    0.000000] ACPI: RSDP 00000000000f03f0 00024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 00000000bf450e18 0007C (v01 ALASKA    A M I 06222004 MSFT 00010013)
[    0.000000] ACPI: FACP 00000000bf44fd98 000F4 (v04 ALASKA    A M I 06222004 MSFT 00010013)
[    0.000000] ACPI Warning: 32/64 FACS address mismatch in FADT - two FACS tables! (20101013/tbfadt-369)
[    0.000000] ACPI Warning: 32/64X FACS address mismatch in FADT - 0xBF459F40/0x00000000BF45AE40, using 32 (20101013/tbfadt-486)
[    0.000000] ACPI: DSDT 00000000bf448018 069B4 (v01 ALASKA    A M I 00000001 INTL 20051117)
[    0.000000] ACPI: FACS 00000000bf459f40 00040
[    0.000000] ACPI: APIC 00000000bf44fc18 000E4 (v02 ALASKA    A M I 06222004 MSFT 00010013)
[    0.000000] ACPI: MCFG 00000000bf451f18 0003C (v01 A M I  OEMMCFG  06222004 MSFT 00000097)
[    0.000000] ACPI: SRAT 00000000bf447c18 003B0 (v01 A M I  AMI SRAT 00000000 AMI. 00000000)
[    0.000000] ACPI: SLIT 00000000bf451e98 00030 (v01 A M I  AMI SLIT 00000000 AMI. 00000000)
[    0.000000] ACPI: HPET 00000000bf451e18 00038 (v01 A M I  ICH7HPET 06222004 AMI. 00000003)
[    0.000000] ACPI: EINJ 00000000bf44fa98 00130 (v01    AMI AMI EINJ 00000000      00000000)
[    0.000000] ACPI: ERST 00000000bf3c2c98 00210 (v01  AMIER AMI ERST 00000000      00000000)
[    0.000000] ACPI: HEST 00000000bf3c2f18 000A8 (v01    AMI AMI HEST 00000000      00000000)
[    0.000000] ACPI: BERT 00000000bf451d98 00030 (v01    AMI AMI BERT 00000000      00000000)
[    0.000000] ACPI: DMAR 00000000bf450d18 000C0 (v01 A M I   OEMDMAR 00000001 INTL 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] ACPI: [SRAT:0x00] ignored 8 entries of 16 found
[    0.000000] SRAT: Node 0 PXM 0 0-c0000000
[    0.000000] SRAT: Node 1 PXM 1 100000000-1c0000000
[    0.000000] NUMA: Using 32 for the hash shift.
[    0.000000] Initmem setup node 0 0000000000000000-00000000c0000000
[    0.000000]   NODE_DATA [00000000bf33c000 - 00000000bf340fff]
[    0.000000] Initmem setup node 1 0000000100000000-00000001c0000000
[    0.000000]   NODE_DATA [00000001bfffa000 - 00000001bfffefff]
[    0.000000]  [ffffea0000000000-ffffea00029fffff] PMD -> [ffff8800bb000000-ffff8800bd9fffff] on node 0
[    0.000000]  [ffffea0003800000-ffffea00061fffff] PMD -> [ffff8801bce00000-ffff8801bf7fffff] on node 1
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x001c0000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[4] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009d
[    0.000000]     0: 0x00000100 -> 0x000bf341
[    0.000000]     0: 0x000bf67e -> 0x000bf800
[    0.000000]     1: 0x00100000 -> 0x001c0000
[    0.000000] On node 0 totalpages: 783440
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3919 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 10668 pages used for memmap
[    0.000000]   DMA32 zone: 768791 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 786432
[    0.000000]   Normal zone: 10752 pages used for memmap
[    0.000000]   Normal zone: 775680 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x16] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 8/0x1 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x03] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 9/0x3 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x05] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 10/0x5 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x07] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 11/0x7 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x11] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 12/0x11 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x13] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 13/0x13 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x15] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 14/0x15 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x17] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 8 reached.  Processor 15/0x17 ignored.
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 2, version 32, address 0xfec01000, GSI 24-47
[    0.000000] ACPI: IOAPIC (id[0x03] address[0xfec02000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 3, version 32, address 0xfec02000, GSI 48-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] 16 Processors exceeds NR_CPUS limit of 8
[    0.000000] SMP: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 88
[    0.000000] Allocating PCI resources starting at d0000000 (gap: d0000000:2ed1c000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:2
[    0.000000] PERCPU: Embedded 475 pages/cpu @ffff8800ba400000 s1915520 r8192 d21888 u2097152
[    0.000000] pcpu-alloc: s1915520 r8192 d21888 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 [0] 4 [0] 6 [1] 5 [1] 7
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 1548390
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: ip=::::wfg-ne02::dhcp netconsole=@:/eth0,6666@10.239.51.110/00:30:48:fe:19:94 panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=tty0 console=ttyS0,115200 earlyprintk=vga bisect-reboot sched_debug nfsroot=10.239.51.240:/nfsroot/wfg,tcp,v3,rsize=524288,wsize=524288 rw BOOT_IMAGE=x86_64/vmlinuz
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Memory: 6064376k/7340032k available (9918k kernel code, 1060544k absent, 215112k reserved, 10845k data, 2720k init)
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: at /home/wfg/cc/linux-2.6/kernel/lockdep.c:2481 lockdep_trace_alloc+0xed/0x100()
[    0.000000] Hardware name: X8DTN
[    0.000000] Modules linked in:
[    0.000000] Pid: 0, comm: swapper Not tainted 2.6.37-rc1+ #107
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff810bc51d>] warn_slowpath_common+0xad/0xf0
[    0.000000]  [<ffffffff810bc57a>] warn_slowpath_null+0x1a/0x20
[    0.000000]  [<ffffffff8110debd>] lockdep_trace_alloc+0xed/0x100
[    0.000000]  [<ffffffff81201df0>] __kmalloc_node+0x30/0x340
[    0.000000]  [<ffffffff8110abf8>] ? lock_release_holdtime+0xb8/0x160
[    0.000000]  [<ffffffff811d0b5a>] pcpu_mem_alloc+0x16a/0x1b0
[    0.000000]  [<ffffffff82641c0b>] percpu_init_late+0x48/0xc2
[    0.000000]  [<ffffffff8261cd2f>] start_kernel+0x1d4/0x473
[    0.000000]  [<ffffffff8261c35c>] x86_64_start_reservations+0x163/0x167
[    0.000000]  [<ffffffff8261c498>] x86_64_start_kernel+0x138/0x147
[    0.000000] ---[ end trace 4eaa2a86a8e2da22 ]---
[    0.000000] Preemptable hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000]  Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:4352 nr_irqs:1560 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled, bootconsole disabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] allocated 62914560 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] ODEBUG: 15 of 15 active objects replaced
[    0.000000] hpet clockevent registered
[    0.001000] Fast TSC calibration using PIT
[    0.002000] Detected 2666.698 MHz processor.
[    0.000009] Calibrating delay loop (skipped), value calculated using timer frequency.. 5333.39 BogoMIPS (lpj=2666698)
[    0.010802] pid_max: default: 32768 minimum: 301
[    0.018237] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.028510] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.036412] Mount-cache hash table entries: 256
[    0.041291] Initializing cgroup subsys debug
[    0.045654] Initializing cgroup subsys ns
[    0.049758] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[    0.058780] Initializing cgroup subsys cpuacct
[    0.063318] Initializing cgroup subsys memory
[    0.067796] Initializing cgroup subsys devices
[    0.072332] Initializing cgroup subsys freezer
[    0.076901] CPU: Physical Processor ID: 0
[    0.080999] CPU: Processor Core ID: 0
[    0.084751] mce: CPU supports 9 MCE banks
[    0.088867] CPU0: Thermal monitoring enabled (TM1)
[    0.093758] using mwait in idle threads.
[    0.097768] Performance Events: PEBS fmt1+, Nehalem events, Intel PMU driver.
[    0.105129] ... version:                3
[    0.109229] ... bit width:              48
[    0.113414] ... generic registers:      4
[    0.117511] ... value mask:             0000ffffffffffff
[    0.122907] ... max period:             000000007fffffff
[    0.128301] ... fixed-purpose events:   3
[    0.132397] ... event mask:             000000070000000f
[    0.138788] ACPI: Core revision 20101013
[    0.162590] ftrace: allocating 24175 entries in 95 pages
[    0.177775] Setting APIC routing to flat
[    0.182300] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.198364] CPU0: Genuine Intel(R) CPU             000  @ 2.67GHz stepping 04
[    0.312090] lockdep: fixing up alternatives.
[    0.317093] Booting Node   0, Processors  #1lockdep: fixing up alternatives.
[    0.416922]  #2lockdep: fixing up alternatives.
[    0.513686]  #3lockdep: fixing up alternatives.
[    0.610396]  #4lockdep: fixing up alternatives.
[    0.707154]  Ok.
[    0.709083] Booting Node   1, Processors  #5lockdep: fixing up alternatives.
[    0.808881]  Ok.
[    0.810811] Booting Node   0, Processors  #6lockdep: fixing up alternatives.
[    0.910600]  Ok.
[    0.912534] Booting Node   1, Processors  #7 Ok.
[    1.007340] Brought up 8 CPUs
[    1.010410] Total of 8 processors activated (42661.07 BogoMIPS).
[    1.016551] Testing NMI watchdog ... OK.
[    1.044445] CPU0 attaching sched-domain:
[    1.048472]  domain 0: span 0-3 level MC
[    1.052526]   groups: 0 1 2 3
[    1.055773]   domain 1: span 0-7 level CPU
[    1.060004]    groups: 0-3 (cpu_power = 4096) 4-7 (cpu_power = 4096)
[    1.066650]    domain 2: span 0-7 level NODE
[    1.071053]     groups: 0-7 (cpu_power = 8192)
[    1.075721] CPU1 attaching sched-domain:
[    1.079734]  domain 0: span 0-3 level MC
[    1.083793]   groups: 1 2 3 0
[    1.087055]   domain 1: span 0-7 level CPU
[    1.091285]    groups: 0-3 (cpu_power = 4096) 4-7 (cpu_power = 4096)
[    1.097946]    domain 2: span 0-7 level NODE
[    1.102350]     groups: 0-7 (cpu_power = 8192)
[    1.107017] CPU2 attaching sched-domain:
[    1.111027]  domain 0: span 0-3 level MC
[    1.115083]   groups: 2 3 0 1
[    1.118342]   domain 1: span 0-7 level CPU
[    1.122576]    groups: 0-3 (cpu_power = 4096) 4-7 (cpu_power = 4096)
[    1.129236]    domain 2: span 0-7 level NODE
[    1.133637]     groups: 0-7 (cpu_power = 8192)
[    1.138287] CPU3 attaching sched-domain:
[    1.142291]  domain 0: span 0-3 level MC
[    1.146351]   groups: 3 0 1 2
[    1.149620]   domain 1: span 0-7 level CPU
[    1.153847]    groups: 0-3 (cpu_power = 4096) 4-7 (cpu_power = 4096)
[    1.160478]    domain 2: span 0-7 level NODE
[    1.164875]     groups: 0-7 (cpu_power = 8192)
[    1.169528] CPU4 attaching sched-domain:
[    1.173536]  domain 0: span 4-7 level MC
[    1.177598]   groups: 4 5 6 7
[    1.180855]   domain 1: span 0-7 level CPU
[    1.185085]    groups: 4-7 (cpu_power = 4096) 0-3 (cpu_power = 4096)
[    1.191742]    domain 2: span 0-7 level NODE
[    1.196141]     groups: 0-7 (cpu_power = 8192)
[    1.200802] CPU5 attaching sched-domain:
[    1.204810]  domain 0: span 4-7 level MC
[    1.208866]   groups: 5 6 7 4
[    1.212127]   domain 1: span 0-7 level CPU
[    1.216344]    groups: 4-7 (cpu_power = 4096) 0-3 (cpu_power = 4096)
[    1.222994]    domain 2: span 0-7 level NODE
[    1.227390]     groups: 0-7 (cpu_power = 8192)
[    1.232046] CPU6 attaching sched-domain:
[    1.236048]  domain 0: span 4-7 level MC
[    1.240101]   groups: 6 7 4 5
[    1.243351]   domain 1: span 0-7 level CPU
[    1.247578]    groups: 4-7 (cpu_power = 4096) 0-3 (cpu_power = 4096)
[    1.254234]    domain 2: span 0-7 level NODE
[    1.258641]     groups: 0-7 (cpu_power = 8192)
[    1.263295] CPU7 attaching sched-domain:
[    1.267301]  domain 0: span 4-7 level MC
[    1.271358]   groups: 7 4 5 6
[    1.274612]   domain 1: span 0-7 level CPU
[    1.278846]    groups: 4-7 (cpu_power = 4096) 0-3 (cpu_power = 4096)
[    1.285512]    domain 2: span 0-7 level NODE
[    1.289918]     groups: 0-7 (cpu_power = 8192)
[    1.295424] kworker/u:0 used greatest stack depth: 6256 bytes left
[    1.302280] kworker/u:0 used greatest stack depth: 6184 bytes left
[    1.317245] Time: 15:51:42  Date: 11/13/10
[    1.321521] NET: Registered protocol family 16
[    1.327993] ACPI: bus type pci registered
[    1.332658] dca service started, version 1.12.1
[    1.337487] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xc0000000-0xcfffffff] (base 0xc0000000)
[    1.346935] PCI: MMCONFIG at [mem 0xc0000000-0xcfffffff] reserved in E820
[    1.427371] PCI: Using configuration type 1 for base access
[    1.484975] ACPI: EC: Look up EC in DSDT
[    1.491094] \_SB_:_OSC evaluation returned wrong type
[    1.496235] _OSC request data:1 6
[    1.504473] ACPI: Executed 1 blocks of module-level executable AML code
[    1.543125] ACPI: SSDT 00000000bf453018 01054 (v01    AMI      IST 00000001 MSFT 03000001)
[    1.555525] ACPI: Dynamic OEM Table Load:
[    1.559708] ACPI: SSDT           (null) 01054 (v01    AMI      IST 00000001 MSFT 03000001)
[    1.575161] ACPI: Interpreter enabled
[    1.578917] ACPI: (supports S0 S5)
[    1.582520] ACPI: Using IOAPIC for interrupt routing
[    1.593032] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    1.646988] ACPI: No dock devices found.
[    1.651004] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.661221] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.668265] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    1.674964] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    1.681660] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    1.689118] pci_root PNP0A08:00: host bridge window [mem 0xc0000000-0xffffffff]
[    1.696583] pci 0000:00:00.0: [8086:3400] type 0 class 0x000600
[    1.702642] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    1.708824] pci 0000:00:00.0: PME# disabled
[    1.713132] pci 0000:00:01.0: [8086:3408] type 1 class 0x000604
[    1.719196] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    1.725373] pci 0000:00:01.0: PME# disabled
[    1.729669] pci 0000:00:02.0: [8086:3409] type 1 class 0x000604
[    1.735731] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    1.741920] pci 0000:00:02.0: PME# disabled
[    1.746219] pci 0000:00:03.0: [8086:340a] type 1 class 0x000604
[    1.752279] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    1.758457] pci 0000:00:03.0: PME# disabled
[    1.762755] pci 0000:00:04.0: [8086:340b] type 1 class 0x000604
[    1.768822] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    1.775005] pci 0000:00:04.0: PME# disabled
[    1.779303] pci 0000:00:05.0: [8086:340c] type 1 class 0x000604
[    1.785363] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    1.791539] pci 0000:00:05.0: PME# disabled
[    1.795835] pci 0000:00:06.0: [8086:340d] type 1 class 0x000604
[    1.801897] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    1.808081] pci 0000:00:06.0: PME# disabled
[    1.812376] pci 0000:00:07.0: [8086:340e] type 1 class 0x000604
[    1.818434] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    1.824615] pci 0000:00:07.0: PME# disabled
[    1.828908] pci 0000:00:08.0: [8086:340f] type 1 class 0x000604
[    1.834977] pci 0000:00:08.0: PME# supported from D0 D3hot D3cold
[    1.841162] pci 0000:00:08.0: PME# disabled
[    1.845459] pci 0000:00:09.0: [8086:3410] type 1 class 0x000604
[    1.851517] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    1.857694] pci 0000:00:09.0: PME# disabled
[    1.861989] pci 0000:00:0a.0: [8086:3411] type 1 class 0x000604
[    1.868058] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    1.874241] pci 0000:00:0a.0: PME# disabled
[    1.878545] pci 0000:00:13.0: [8086:342d] type 0 class 0x000800
[    1.884565] pci 0000:00:13.0: reg 10: [mem 0xfbf03000-0xfbf03fff]
[    1.890793] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
[    1.896971] pci 0000:00:13.0: PME# disabled
[    1.901261] pci 0000:00:14.0: [8086:342e] type 0 class 0x000800
[    1.907348] pci 0000:00:14.1: [8086:3422] type 0 class 0x000800
[    1.913434] pci 0000:00:14.2: [8086:3423] type 0 class 0x000800
[    1.919518] pci 0000:00:14.3: [8086:3438] type 0 class 0x000800
[    1.925598] pci 0000:00:16.0: [8086:3430] type 0 class 0x000880
[    1.931613] pci 0000:00:16.0: reg 10: [mem 0xfffff1c000-0xfffff1ffff 64bit]
[    1.938735] pci 0000:00:16.1: [8086:3431] type 0 class 0x000880
[    1.944753] pci 0000:00:16.1: reg 10: [mem 0xfffff18000-0xfffff1bfff 64bit]
[    1.951874] pci 0000:00:16.2: [8086:3432] type 0 class 0x000880
[    1.957893] pci 0000:00:16.2: reg 10: [mem 0xfffff14000-0xfffff17fff 64bit]
[    1.965014] pci 0000:00:16.3: [8086:3433] type 0 class 0x000880
[    1.971031] pci 0000:00:16.3: reg 10: [mem 0xfffff10000-0xfffff13fff 64bit]
[    1.978153] pci 0000:00:16.4: [8086:3429] type 0 class 0x000880
[    1.984182] pci 0000:00:16.4: reg 10: [mem 0xfffff0c000-0xfffff0ffff 64bit]
[    1.991332] pci 0000:00:16.5: [8086:342a] type 0 class 0x000880
[    1.997358] pci 0000:00:16.5: reg 10: [mem 0xfffff08000-0xfffff0bfff 64bit]
[    2.004477] pci 0000:00:16.6: [8086:342b] type 0 class 0x000880
[    2.010496] pci 0000:00:16.6: reg 10: [mem 0xfffff04000-0xfffff07fff 64bit]
[    2.017618] pci 0000:00:16.7: [8086:342c] type 0 class 0x000880
[    2.023636] pci 0000:00:16.7: reg 10: [mem 0xfffff00000-0xfffff03fff 64bit]
[    2.030761] pci 0000:00:1a.0: [8086:3a37] type 0 class 0x000c03
[    2.036815] pci 0000:00:1a.0: reg 20: [io  0xf0c0-0xf0df]
[    2.042374] pci 0000:00:1a.2: [8086:3a39] type 0 class 0x000c03
[    2.048432] pci 0000:00:1a.2: reg 20: [io  0xf0a0-0xf0bf]
[    2.053987] pci 0000:00:1a.7: [8086:3a3c] type 0 class 0x000c03
[    2.060012] pci 0000:00:1a.7: reg 10: [mem 0xfbf02000-0xfbf023ff]
[    2.066271] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    2.072456] pci 0000:00:1a.7: PME# disabled
[    2.076757] pci 0000:00:1c.0: [8086:3a40] type 1 class 0x000604
[    2.082826] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    2.089000] pci 0000:00:1c.0: PME# disabled
[    2.093301] pci 0000:00:1c.4: [8086:3a48] type 1 class 0x000604
[    2.099377] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    2.105555] pci 0000:00:1c.4: PME# disabled
[    2.109860] pci 0000:00:1d.0: [8086:3a34] type 0 class 0x000c03
[    2.115920] pci 0000:00:1d.0: reg 20: [io  0xf080-0xf09f]
[    2.121474] pci 0000:00:1d.1: [8086:3a35] type 0 class 0x000c03
[    2.127535] pci 0000:00:1d.1: reg 20: [io  0xf060-0xf07f]
[    2.133070] pci 0000:00:1d.2: [8086:3a36] type 0 class 0x000c03
[    2.139124] pci 0000:00:1d.2: reg 20: [io  0xf040-0xf05f]
[    2.144673] pci 0000:00:1d.7: [8086:3a3a] type 0 class 0x000c03
[    2.150704] pci 0000:00:1d.7: reg 10: [mem 0xfbf01000-0xfbf013ff]
[    2.156970] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    2.163142] pci 0000:00:1d.7: PME# disabled
[    2.167433] pci 0000:00:1e.0: [8086:244e] type 1 class 0x000604
[    2.173522] pci 0000:00:1f.0: [8086:3a16] type 0 class 0x000601
[    2.179636] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by ICH6 ACPI/GPIO/TCO
[    2.187710] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
[    2.194921] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0600 (mask 00ff)
[    2.202646] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0290 (mask 001f)
[    2.210357] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0ca0 (mask 000f)
[    2.218116] pci 0000:00:1f.2: [8086:3a22] type 0 class 0x000106
[    2.224140] pci 0000:00:1f.2: reg 10: [io  0xf110-0xf117]
[    2.229633] pci 0000:00:1f.2: reg 14: [io  0xf100-0xf103]
[    2.235124] pci 0000:00:1f.2: reg 18: [io  0xf0f0-0xf0f7]
[    2.240628] pci 0000:00:1f.2: reg 1c: [io  0xf0e0-0xf0e3]
[    2.246118] pci 0000:00:1f.2: reg 20: [io  0xf020-0xf03f]
[    2.251608] pci 0000:00:1f.2: reg 24: [mem 0xfbf00000-0xfbf007ff]
[    2.257823] pci 0000:00:1f.2: PME# supported from D3hot
[    2.263132] pci 0000:00:1f.2: PME# disabled
[    2.267419] pci 0000:00:1f.3: [8086:3a30] type 0 class 0x000c05
[    2.273436] pci 0000:00:1f.3: reg 10: [mem 0xfffff20000-0xfffff200ff 64bit]
[    2.280506] pci 0000:00:1f.3: reg 20: [io  0xf000-0xf01f]
[    2.286085] pci 0000:01:00.0: [8086:10c9] type 0 class 0x000200
[    2.292107] pci 0000:01:00.0: reg 10: [mem 0xfb9a0000-0xfb9bffff]
[    2.298291] pci 0000:01:00.0: reg 14: [mem 0xfb980000-0xfb99ffff]
[    2.304476] pci 0000:01:00.0: reg 18: [io  0xe020-0xe03f]
[    2.309966] pci 0000:01:00.0: reg 1c: [mem 0xfba44000-0xfba47fff]
[    2.316167] pci 0000:01:00.0: reg 30: [mem 0xfb960000-0xfb97ffff pref]
[    2.322816] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[    2.328999] pci 0000:01:00.0: PME# disabled
[    2.333314] pci 0000:01:00.1: [8086:10c9] type 0 class 0x000200
[    2.339327] pci 0000:01:00.1: reg 10: [mem 0xfb940000-0xfb95ffff]
[    2.345512] pci 0000:01:00.1: reg 14: [mem 0xfb920000-0xfb93ffff]
[    2.351691] pci 0000:01:00.1: reg 18: [io  0xe000-0xe01f]
[    2.357183] pci 0000:01:00.1: reg 1c: [mem 0xfba40000-0xfba43fff]
[    2.363381] pci 0000:01:00.1: reg 30: [mem 0xfb900000-0xfb91ffff pref]
[    2.370020] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[    2.376203] pci 0000:01:00.1: PME# disabled
[    2.380493] pci 0000:00:01.0: PCI bridge to [bus 01-02]
[    2.385806] pci 0000:00:01.0:   bridge window [io  0xe000-0xefff]
[    2.391989] pci 0000:00:01.0:   bridge window [mem 0xfb900000-0xfbafffff]
[    2.398872] pci 0000:00:01.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.407236] pci 0000:00:02.0: PCI bridge to [bus 03-03]
[    2.412550] pci 0000:00:02.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.419674] pci 0000:00:02.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.427568] pci 0000:00:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.436056] pci 0000:04:00.0: [8086:10f1] type 0 class 0x000200
[    2.442140] pci 0000:04:00.0: reg 10: [mem 0xfbea0000-0xfbebffff]
[    2.448387] pci 0000:04:00.0: reg 14: [mem 0xfbe40000-0xfbe7ffff]
[    2.454636] pci 0000:04:00.0: reg 18: [io  0xd020-0xd03f]
[    2.460193] pci 0000:04:00.0: reg 1c: [mem 0xfbec4000-0xfbec7fff]
[    2.466491] pci 0000:04:00.0: PME# supported from D0 D3hot
[    2.472135] pci 0000:04:00.0: PME# disabled
[    2.476502] pci 0000:04:00.1: [8086:10f1] type 0 class 0x000200
[    2.482580] pci 0000:04:00.1: reg 10: [mem 0xfbe80000-0xfbe9ffff]
[    2.488839] pci 0000:04:00.1: reg 14: [mem 0xfbe00000-0xfbe3ffff]
[    2.495100] pci 0000:04:00.1: reg 18: [io  0xd000-0xd01f]
[    2.500660] pci 0000:04:00.1: reg 1c: [mem 0xfbec0000-0xfbec3fff]
[    2.506963] pci 0000:04:00.1: PME# supported from D0 D3hot
[    2.512601] pci 0000:04:00.1: PME# disabled
[    2.516954] pci 0000:00:03.0: PCI bridge to [bus 04-04]
[    2.522266] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    2.528450] pci 0000:00:03.0:   bridge window [mem 0xfbe00000-0xfbefffff]
[    2.535324] pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.545273] pci 0000:00:04.0: PCI bridge to [bus 05-05]
[    2.550585] pci 0000:00:04.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.557719] pci 0000:00:04.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.565612] pci 0000:00:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.573980] pci 0000:00:05.0: PCI bridge to [bus 06-06]
[    2.579294] pci 0000:00:05.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.586428] pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.594327] pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.602695] pci 0000:00:06.0: PCI bridge to [bus 07-07]
[    2.608009] pci 0000:00:06.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.615137] pci 0000:00:06.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.623028] pci 0000:00:06.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.631409] pci 0000:00:07.0: PCI bridge to [bus 08-08]
[    2.636716] pci 0000:00:07.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.643842] pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.651735] pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.660101] pci 0000:00:08.0: PCI bridge to [bus 09-09]
[    2.665408] pci 0000:00:08.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.672533] pci 0000:00:08.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.680433] pci 0000:00:08.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.688823] pci 0000:0a:00.0: [8086:0329] type 1 class 0x000604
[    2.694841] pci 0000:0a:00.0: PXH quirk detected; SHPC device MSI disabled
[    2.701852] pci 0000:0a:00.0: PME# supported from D0 D3hot D3cold
[    2.708028] pci 0000:0a:00.0: PME# disabled
[    2.712334] pci 0000:0a:00.2: [8086:032a] type 1 class 0x000604
[    2.718376] pci 0000:0a:00.2: PXH quirk detected; SHPC device MSI disabled
[    2.725409] pci 0000:0a:00.2: PME# supported from D0 D3hot D3cold
[    2.731591] pci 0000:0a:00.2: PME# disabled
[    2.735883] pci 0000:00:09.0: PCI bridge to [bus 0a-0c]
[    2.741192] pci 0000:00:09.0:   bridge window [io  0xc000-0xcfff]
[    2.747368] pci 0000:00:09.0:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    2.754242] pci 0000:00:09.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.762650] pci 0000:0a:00.0: PCI bridge to [bus 0b-0b]
[    2.767967] pci 0000:0a:00.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.775102] pci 0000:0a:00.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.782992] pci 0000:0a:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.791373] pci 0000:0c:01.0: [8086:1229] type 0 class 0x000200
[    2.797391] pci 0000:0c:01.0: reg 10: [mem 0xfbd20000-0xfbd20fff]
[    2.803580] pci 0000:0c:01.0: reg 14: [io  0xc000-0xc03f]
[    2.809068] pci 0000:0c:01.0: reg 18: [mem 0xfbd00000-0xfbd1ffff]
[    2.815296] pci 0000:0c:01.0: supports D1 D2
[    2.819656] pci 0000:0c:01.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.826352] pci 0000:0c:01.0: PME# disabled
[    2.830678] pci 0000:0a:00.2: PCI bridge to [bus 0c-0c]
[    2.835987] pci 0000:0a:00.2:   bridge window [io  0xc000-0xcfff]
[    2.842160] pci 0000:0a:00.2:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    2.849027] pci 0000:0a:00.2:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.857403] pci 0000:00:0a.0: PCI bridge to [bus 0d-0d]
[    2.862719] pci 0000:00:0a.0:   bridge window [io  0xf000-0x0000] (disabled)
[    2.869851] pci 0000:00:0a.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    2.877751] pci 0000:00:0a.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.886138] pci 0000:0e:00.0: [1000:0058] type 0 class 0x000100
[    2.892157] pci 0000:0e:00.0: reg 10: [io  0xb000-0xb0ff]
[    2.897659] pci 0000:0e:00.0: reg 14: [mem 0xfb810000-0xfb813fff 64bit]
[    2.904371] pci 0000:0e:00.0: reg 1c: [mem 0xfb800000-0xfb80ffff 64bit]
[    2.911085] pci 0000:0e:00.0: reg 30: [mem 0xfb600000-0xfb7fffff pref]
[    2.917730] pci 0000:0e:00.0: supports D1 D2
[    2.922107] pci 0000:00:1c.0: PCI bridge to [bus 0e-0e]
[    2.927420] pci 0000:00:1c.0:   bridge window [io  0xb000-0xbfff]
[    2.933596] pci 0000:00:1c.0:   bridge window [mem 0xfb600000-0xfb8fffff]
[    2.940471] pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    2.948865] pci 0000:0f:00.0: [197b:2368] type 0 class 0x000101
[    2.954888] pci 0000:0f:00.0: reg 10: [io  0xa040-0xa047]
[    2.960387] pci 0000:0f:00.0: reg 14: [io  0xa030-0xa033]
[    2.965885] pci 0000:0f:00.0: reg 18: [io  0xa020-0xa027]
[    2.971381] pci 0000:0f:00.0: reg 1c: [io  0xa010-0xa013]
[    2.976880] pci 0000:0f:00.0: reg 20: [io  0xa000-0xa00f]
[    2.982391] pci 0000:0f:00.0: reg 30: [mem 0xfbc00000-0xfbc0ffff pref]
[    2.989066] pci 0000:00:1c.4: PCI bridge to [bus 0f-0f]
[    2.994381] pci 0000:00:1c.4:   bridge window [io  0xa000-0xafff]
[    3.000561] pci 0000:00:1c.4:   bridge window [mem 0xfbc00000-0xfbcfffff]
[    3.007440] pci 0000:00:1c.4:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    3.015814] pci 0000:10:01.0: [1002:515e] type 0 class 0x000300
[    3.021850] pci 0000:10:01.0: reg 10: [mem 0xf0000000-0xf7ffffff pref]
[    3.028465] pci 0000:10:01.0: reg 14: [io  0x9000-0x90ff]
[    3.033964] pci 0000:10:01.0: reg 18: [mem 0xfbb20000-0xfbb2ffff]
[    3.040183] pci 0000:10:01.0: reg 30: [mem 0xfbb00000-0xfbb1ffff pref]
[    3.046816] pci 0000:10:01.0: supports D1 D2
[    3.051227] pci 0000:00:1e.0: PCI bridge to [bus 10-10] (subtractive decode)
[    3.058359] pci 0000:00:1e.0:   bridge window [io  0x9000-0x9fff]
[    3.064537] pci 0000:00:1e.0:   bridge window [mem 0xfbb00000-0xfbbfffff]
[    3.071405] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
[    3.079294] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    3.087359] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    3.095422] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    3.104174] pci 0000:00:1e.0:   bridge window [mem 0xc0000000-0xffffffff] (subtractive decode)
[    3.113012] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    3.120459] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[    3.127262] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
[    3.133891] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
[    3.140599] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9._PRT]
[    3.147263] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9.PXHB._PRT]
[    3.154348] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9.PXHA._PRT]
[    3.253743] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    3.261335] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 *11 12 14 15)
[    3.268924] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 10 11 12 14 15)
[    3.276575] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    3.284137] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0
[    3.291941] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0
[    3.299732] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 11 12 14 15) *0
[    3.307508] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14 15)
[    3.316098] vgaarb: device added: PCI:0000:10:01.0,decodes=io+mem,owns=io+mem,locks=none
[    3.324340] vgaarb: loaded
[    3.328105] usbcore: registered new interface driver usbfs
[    3.334051] usbcore: registered new interface driver hub
[    3.339667] usbcore: registered new device driver usb
[    3.346564] wmi: Mapper loaded
[    3.349874] Advanced Linux Sound Architecture Driver Version 1.0.23.
[    3.356312] PCI: Using ACPI for IRQ routing
[    3.360578] PCI: pci_cache_line_size set to 64 bytes
[    3.365722] pci 0000:00:16.0: no compatible bridge window for [mem 0xfffff1c000-0xfffff1ffff 64bit]
[    3.374914] pci 0000:00:16.1: no compatible bridge window for [mem 0xfffff18000-0xfffff1bfff 64bit]
[    3.384101] pci 0000:00:16.2: no compatible bridge window for [mem 0xfffff14000-0xfffff17fff 64bit]
[    3.393289] pci 0000:00:16.3: no compatible bridge window for [mem 0xfffff10000-0xfffff13fff 64bit]
[    3.402480] pci 0000:00:16.4: no compatible bridge window for [mem 0xfffff0c000-0xfffff0ffff 64bit]
[    3.411669] pci 0000:00:16.5: no compatible bridge window for [mem 0xfffff08000-0xfffff0bfff 64bit]
[    3.420871] pci 0000:00:16.6: no compatible bridge window for [mem 0xfffff04000-0xfffff07fff 64bit]
[    3.430065] pci 0000:00:16.7: no compatible bridge window for [mem 0xfffff00000-0xfffff03fff 64bit]
[    3.439297] pci 0000:00:1f.3: no compatible bridge window for [mem 0xfffff20000-0xfffff200ff 64bit]
[    3.448741] reserve RAM buffer: 000000000009d800 - 000000000009ffff
[    3.454942] reserve RAM buffer: 00000000bf341000 - 00000000bfffffff
[    3.461430] reserve RAM buffer: 00000000bf800000 - 00000000bfffffff
[    3.468870] HPET: 4 timers in total, 0 timers will be used for per-cpu timer
[    3.476280] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    3.481716] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    3.496981] Switching to clocksource tsc
[    3.501724] Warning: could not register all branches stats
[    3.507305] Warning: could not register annotated branches stats
[    3.547612] pnp: PnP ACPI init
[    3.550794] ACPI: bus type pnp registered
[    3.555137] pnp 00:00: [bus 00-ff]
[    3.558632] pnp 00:00: [io  0x0cf8-0x0cff]
[    3.562814] pnp 00:00: [io  0x0000-0x0cf7 window]
[    3.567603] pnp 00:00: [io  0x0d00-0xffff window]
[    3.572391] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    3.577874] pnp 00:00: [mem 0x00000000 window]
[    3.582401] pnp 00:00: [mem 0xc0000000-0xffffffff window]
[    3.588318] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    3.595734] pnp 00:01: [mem 0xfc000000-0xfcffffff]
[    3.600614] pnp 00:01: [mem 0xfd000000-0xfdffffff]
[    3.605498] pnp 00:01: [mem 0xfe000000-0xfe9fffff]
[    3.610384] pnp 00:01: [mem 0xfea00000-0xfea0001f]
[    3.615266] pnp 00:01: [mem 0xfeb00000-0xfebfffff]
[    3.620150] pnp 00:01: [mem 0xfed00400-0xfed3ffff]
[    3.625034] pnp 00:01: [mem 0xfed45000-0xfedfffff]
[    3.631939] pnp 00:01: Plug and Play ACPI device, IDs PNP0c01 (active)
[    3.639872] pnp 00:02: [io  0x0000-0xffffffffffffffff disabled]
[    3.645879] pnp 00:02: [io  0x0290-0x029f]
[    3.650067] pnp 00:02: [io  0x0000-0xffffffffffffffff disabled]
[    3.656077] pnp 00:02: [io  0x0000-0xffffffffffffffff disabled]
[    3.662088] pnp 00:02: [io  0x0000-0xffffffffffffffff disabled]
[    3.668552] pnp 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.675257] pnp 00:03: [io  0x0060]
[    3.678844] pnp 00:03: [io  0x0064]
[    3.682439] pnp 00:03: [irq 1]
[    3.685911] pnp 00:03: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
[    3.693439] pnp 00:04: [irq 12]
[    3.696978] pnp 00:04: Plug and Play ACPI device, IDs PNP0f03 PNP0f13 (active)
[    3.706133] pnp 00:05: [io  0x03f8-0x03ff]
[    3.710325] pnp 00:05: [irq 4]
[    3.713471] pnp 00:05: [dma 0 disabled]
[    3.717764] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    3.729668] pnp 00:06: [io  0x02f8-0x02ff]
[    3.733864] pnp 00:06: [irq 3]
[    3.737010] pnp 00:06: [dma 0 disabled]
[    3.741311] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    3.750489] pnp 00:07: [dma 4]
[    3.753643] pnp 00:07: [io  0x0000-0x000f]
[    3.757829] pnp 00:07: [io  0x0081-0x0083]
[    3.762019] pnp 00:07: [io  0x0087]
[    3.765597] pnp 00:07: [io  0x0089-0x008b]
[    3.769783] pnp 00:07: [io  0x008f]
[    3.773363] pnp 00:07: [io  0x00c0-0x00df]
[    3.777882] pnp 00:07: Plug and Play ACPI device, IDs PNP0200 (active)
[    3.784538] pnp 00:08: [io  0x0070-0x0071]
[    3.788728] pnp 00:08: [irq 8]
[    3.792218] pnp 00:08: Plug and Play ACPI device, IDs PNP0b00 (active)
[    3.798859] pnp 00:09: [io  0x0061]
[    3.802771] pnp 00:09: Plug and Play ACPI device, IDs PNP0800 (active)
[    3.809456] pnp 00:0a: [io  0x0010-0x001f]
[    3.813645] pnp 00:0a: [io  0x0022-0x003f]
[    3.817837] pnp 00:0a: [io  0x0044-0x005f]
[    3.822019] pnp 00:0a: [io  0x0062-0x0063]
[    3.826224] pnp 00:0a: [io  0x0065-0x006f]
[    3.830414] pnp 00:0a: [io  0x0072-0x007f]
[    3.834597] pnp 00:0a: [io  0x0080]
[    3.838180] pnp 00:0a: [io  0x0084-0x0086]
[    3.842363] pnp 00:0a: [io  0x0088]
[    3.845942] pnp 00:0a: [io  0x008c-0x008e]
[    3.850126] pnp 00:0a: [io  0x0090-0x009f]
[    3.854311] pnp 00:0a: [io  0x00a2-0x00bf]
[    3.858495] pnp 00:0a: [io  0x00e0-0x00ef]
[    3.862678] pnp 00:0a: [io  0x04d0-0x04d1]
[    3.867459] pnp 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.874134] pnp 00:0b: [io  0x00f0-0x00ff]
[    3.878327] pnp 00:0b: [irq 13]
[    3.881899] pnp 00:0b: Plug and Play ACPI device, IDs PNP0c04 (active)
[    3.889375] pnp 00:0c: [io  0x0400-0x047f]
[    3.893564] pnp 00:0c: [io  0x1180-0x119f]
[    3.897755] pnp 00:0c: [io  0x0500-0x057f]
[    3.901947] pnp 00:0c: [mem 0xfed1c000-0xfed1ffff]
[    3.906831] pnp 00:0c: [mem 0xfec00000-0xfecfffff]
[    3.911719] pnp 00:0c: [mem 0xff000000-0xffffffff]
[    3.916939] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
[    3.924229] pnp 00:0d: [mem 0xfed00000-0xfed003ff]
[    3.929572] pnp 00:0d: Plug and Play ACPI device, IDs PNP0103 (active)
[    3.936868] pnp: PnP ACPI: found 14 devices
[    3.941143] ACPI: ACPI bus type pnp unregistered
[    3.945869] system 00:01: [mem 0xfc000000-0xfcffffff] has been reserved
[    3.952577] system 00:01: [mem 0xfd000000-0xfdffffff] has been reserved
[    3.959275] system 00:01: [mem 0xfe000000-0xfe9fffff] has been reserved
[    3.965974] system 00:01: [mem 0xfea00000-0xfea0001f] has been reserved
[    3.972676] system 00:01: [mem 0xfeb00000-0xfebfffff] has been reserved
[    3.979378] system 00:01: [mem 0xfed00400-0xfed3ffff] could not be reserved
[    3.986421] system 00:01: [mem 0xfed45000-0xfedfffff] has been reserved
[    3.993128] system 00:02: [io  0x0290-0x029f] has been reserved
[    3.999138] system 00:0a: [io  0x04d0-0x04d1] has been reserved
[    4.005152] system 00:0c: [io  0x0400-0x047f] has been reserved
[    4.011151] system 00:0c: [io  0x1180-0x119f] has been reserved
[    4.017152] system 00:0c: [io  0x0500-0x057f] could not be reserved
[    4.023508] system 00:0c: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    4.030207] system 00:0c: [mem 0xfec00000-0xfecfffff] could not be reserved
[    4.037251] system 00:0c: [mem 0xff000000-0xffffffff] has been reserved
[    4.074338] pci 0000:00:1c.0: BAR 9: assigned [mem 0xfee00000-0xfeffffff 64bit pref]
[    4.082237] pci 0000:00:1c.4: BAR 9: assigned [mem 0xfb400000-0xfb5fffff 64bit pref]
[    4.090134] pci 0000:00:16.0: BAR 0: assigned [mem 0xfed40000-0xfed43fff 64bit]
[    4.097599] pci 0000:00:16.0: BAR 0: set to [mem 0xfed40000-0xfed43fff 64bit] (PCI address [0xfed40000-0xfed43fff])
[    4.108183] pci 0000:00:16.1: BAR 0: assigned [mem 0xfed3c000-0xfed3ffff 64bit]
[    4.115651] pci 0000:00:16.1: BAR 0: set to [mem 0xfed3c000-0xfed3ffff 64bit] (PCI address [0xfed3c000-0xfed3ffff])
[    4.126231] pci 0000:00:16.2: BAR 0: assigned [mem 0xfed38000-0xfed3bfff 64bit]
[    4.133694] pci 0000:00:16.2: BAR 0: set to [mem 0xfed38000-0xfed3bfff 64bit] (PCI address [0xfed38000-0xfed3bfff])
[    4.144263] pci 0000:00:16.3: BAR 0: assigned [mem 0xfed34000-0xfed37fff 64bit]
[    4.151719] pci 0000:00:16.3: BAR 0: set to [mem 0xfed34000-0xfed37fff 64bit] (PCI address [0xfed34000-0xfed37fff])
[    4.162297] pci 0000:00:16.4: BAR 0: assigned [mem 0xfed30000-0xfed33fff 64bit]
[    4.169751] pci 0000:00:16.4: BAR 0: set to [mem 0xfed30000-0xfed33fff 64bit] (PCI address [0xfed30000-0xfed33fff])
[    4.180328] pci 0000:00:16.5: BAR 0: assigned [mem 0xfed2c000-0xfed2ffff 64bit]
[    4.187786] pci 0000:00:16.5: BAR 0: set to [mem 0xfed2c000-0xfed2ffff 64bit] (PCI address [0xfed2c000-0xfed2ffff])
[    4.198361] pci 0000:00:16.6: BAR 0: assigned [mem 0xfed28000-0xfed2bfff 64bit]
[    4.205816] pci 0000:00:16.6: BAR 0: set to [mem 0xfed28000-0xfed2bfff 64bit] (PCI address [0xfed28000-0xfed2bfff])
[    4.216394] pci 0000:00:16.7: BAR 0: assigned [mem 0xfed24000-0xfed27fff 64bit]
[    4.223849] pci 0000:00:16.7: BAR 0: set to [mem 0xfed24000-0xfed27fff 64bit] (PCI address [0xfed24000-0xfed27fff])
[    4.234426] pci 0000:00:1f.3: BAR 0: assigned [mem 0xfed44f00-0xfed44fff 64bit]
[    4.241883] pci 0000:00:1f.3: BAR 0: set to [mem 0xfed44f00-0xfed44fff 64bit] (PCI address [0xfed44f00-0xfed44fff])
[    4.252456] pci 0000:00:01.0: PCI bridge to [bus 01-02]
[    4.257764] pci 0000:00:01.0:   bridge window [io  0xe000-0xefff]
[    4.263941] pci 0000:00:01.0:   bridge window [mem 0xfb900000-0xfbafffff]
[    4.270813] pci 0000:00:01.0:   bridge window [mem pref disabled]
[    4.276994] pci 0000:00:02.0: PCI bridge to [bus 03-03]
[    4.282304] pci 0000:00:02.0:   bridge window [io  disabled]
[    4.288047] pci 0000:00:02.0:   bridge window [mem disabled]
[    4.293788] pci 0000:00:02.0:   bridge window [mem pref disabled]
[    4.299963] pci 0000:00:03.0: PCI bridge to [bus 04-04]
[    4.305275] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    4.311454] pci 0000:00:03.0:   bridge window [mem 0xfbe00000-0xfbefffff]
[    4.318324] pci 0000:00:03.0:   bridge window [mem pref disabled]
[    4.324505] pci 0000:00:04.0: PCI bridge to [bus 05-05]
[    4.329814] pci 0000:00:04.0:   bridge window [io  disabled]
[    4.335558] pci 0000:00:04.0:   bridge window [mem disabled]
[    4.341296] pci 0000:00:04.0:   bridge window [mem pref disabled]
[    4.347473] pci 0000:00:05.0: PCI bridge to [bus 06-06]
[    4.352782] pci 0000:00:05.0:   bridge window [io  disabled]
[    4.358527] pci 0000:00:05.0:   bridge window [mem disabled]
[    4.364265] pci 0000:00:05.0:   bridge window [mem pref disabled]
[    4.370442] pci 0000:00:06.0: PCI bridge to [bus 07-07]
[    4.375751] pci 0000:00:06.0:   bridge window [io  disabled]
[    4.381495] pci 0000:00:06.0:   bridge window [mem disabled]
[    4.387233] pci 0000:00:06.0:   bridge window [mem pref disabled]
[    4.393408] pci 0000:00:07.0: PCI bridge to [bus 08-08]
[    4.398720] pci 0000:00:07.0:   bridge window [io  disabled]
[    4.404464] pci 0000:00:07.0:   bridge window [mem disabled]
[    4.410209] pci 0000:00:07.0:   bridge window [mem pref disabled]
[    4.416386] pci 0000:00:08.0: PCI bridge to [bus 09-09]
[    4.421698] pci 0000:00:08.0:   bridge window [io  disabled]
[    4.427440] pci 0000:00:08.0:   bridge window [mem disabled]
[    4.433180] pci 0000:00:08.0:   bridge window [mem pref disabled]
[    4.439353] pci 0000:0a:00.0: PCI bridge to [bus 0b-0b]
[    4.444665] pci 0000:0a:00.0:   bridge window [io  disabled]
[    4.450407] pci 0000:0a:00.0:   bridge window [mem disabled]
[    4.456147] pci 0000:0a:00.0:   bridge window [mem pref disabled]
[    4.462323] pci 0000:0a:00.2: PCI bridge to [bus 0c-0c]
[    4.467635] pci 0000:0a:00.2:   bridge window [io  0xc000-0xcfff]
[    4.473809] pci 0000:0a:00.2:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    4.480674] pci 0000:0a:00.2:   bridge window [mem pref disabled]
[    4.486855] pci 0000:00:09.0: PCI bridge to [bus 0a-0c]
[    4.492165] pci 0000:00:09.0:   bridge window [io  0xc000-0xcfff]
[    4.498341] pci 0000:00:09.0:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    4.505207] pci 0000:00:09.0:   bridge window [mem pref disabled]
[    4.511390] pci 0000:00:0a.0: PCI bridge to [bus 0d-0d]
[    4.516697] pci 0000:00:0a.0:   bridge window [io  disabled]
[    4.522448] pci 0000:00:0a.0:   bridge window [mem disabled]
[    4.528189] pci 0000:00:0a.0:   bridge window [mem pref disabled]
[    4.534369] pci 0000:00:1c.0: PCI bridge to [bus 0e-0e]
[    4.539676] pci 0000:00:1c.0:   bridge window [io  0xb000-0xbfff]
[    4.545853] pci 0000:00:1c.0:   bridge window [mem 0xfb600000-0xfb8fffff]
[    4.552725] pci 0000:00:1c.0:   bridge window [mem 0xfee00000-0xfeffffff 64bit pref]
[    4.560619] pci 0000:00:1c.4: PCI bridge to [bus 0f-0f]
[    4.565929] pci 0000:00:1c.4:   bridge window [io  0xa000-0xafff]
[    4.572108] pci 0000:00:1c.4:   bridge window [mem 0xfbc00000-0xfbcfffff]
[    4.578978] pci 0000:00:1c.4:   bridge window [mem 0xfb400000-0xfb5fffff 64bit pref]
[    4.586871] pci 0000:00:1e.0: PCI bridge to [bus 10-10]
[    4.592183] pci 0000:00:1e.0:   bridge window [io  0x9000-0x9fff]
[    4.599941] pci 0000:00:1e.0:   bridge window [mem 0xfbb00000-0xfbbfffff]
[    4.606812] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
[    4.614725] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.621509] pci 0000:00:01.0: setting latency timer to 64
[    4.626999] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.633785] pci 0000:00:02.0: setting latency timer to 64
[    4.639275] pci 0000:00:03.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.646058] pci 0000:00:03.0: setting latency timer to 64
[    4.651550] pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.658334] pci 0000:00:04.0: setting latency timer to 64
[    4.663826] pci 0000:00:05.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.670610] pci 0000:00:05.0: setting latency timer to 64
[    4.676102] pci 0000:00:06.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.682885] pci 0000:00:06.0: setting latency timer to 64
[    4.688376] pci 0000:00:07.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.695161] pci 0000:00:07.0: setting latency timer to 64
[    4.700652] pci 0000:00:08.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.707434] pci 0000:00:08.0: setting latency timer to 64
[    4.712925] pci 0000:00:09.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.719709] pci 0000:00:09.0: setting latency timer to 64
[    4.725203] pci 0000:0a:00.0: setting latency timer to 64
[    4.730691] pci 0000:0a:00.2: setting latency timer to 64
[    4.736180] pci 0000:00:0a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.742963] pci 0000:00:0a.0: setting latency timer to 64
[    4.748462] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    4.755247] pci 0000:00:1c.0: setting latency timer to 64
[    4.760739] pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    4.767522] pci 0000:00:1c.4: setting latency timer to 64
[    4.773013] pci 0000:00:1e.0: setting latency timer to 64
[    4.778498] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    4.784149] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    4.789802] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    4.796147] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xffffffff]
[    4.802493] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    4.808146] pci_bus 0000:01: resource 1 [mem 0xfb900000-0xfbafffff]
[    4.814492] pci_bus 0000:04: resource 0 [io  0xd000-0xdfff]
[    4.820143] pci_bus 0000:04: resource 1 [mem 0xfbe00000-0xfbefffff]
[    4.826490] pci_bus 0000:0a: resource 0 [io  0xc000-0xcfff]
[    4.832143] pci_bus 0000:0a: resource 1 [mem 0xfbd00000-0xfbdfffff]
[    4.838488] pci_bus 0000:0c: resource 0 [io  0xc000-0xcfff]
[    4.844142] pci_bus 0000:0c: resource 1 [mem 0xfbd00000-0xfbdfffff]
[    4.850486] pci_bus 0000:0e: resource 0 [io  0xb000-0xbfff]
[    4.856139] pci_bus 0000:0e: resource 1 [mem 0xfb600000-0xfb8fffff]
[    4.862485] pci_bus 0000:0e: resource 2 [mem 0xfee00000-0xfeffffff 64bit pref]
[    4.869849] pci_bus 0000:0f: resource 0 [io  0xa000-0xafff]
[    4.875503] pci_bus 0000:0f: resource 1 [mem 0xfbc00000-0xfbcfffff]
[    4.881848] pci_bus 0000:0f: resource 2 [mem 0xfb400000-0xfb5fffff 64bit pref]
[    4.889212] pci_bus 0000:10: resource 0 [io  0x9000-0x9fff]
[    4.894865] pci_bus 0000:10: resource 1 [mem 0xfbb00000-0xfbbfffff]
[    4.901212] pci_bus 0000:10: resource 2 [mem 0xf0000000-0xf7ffffff 64bit pref]
[    4.908576] pci_bus 0000:10: resource 4 [io  0x0000-0x0cf7]
[    4.914230] pci_bus 0000:10: resource 5 [io  0x0d00-0xffff]
[    4.919882] pci_bus 0000:10: resource 6 [mem 0x000a0000-0x000bffff]
[    4.926229] pci_bus 0000:10: resource 7 [mem 0xc0000000-0xffffffff]
[    4.932613] NET: Registered protocol family 2
[    4.937857] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    4.948731] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    4.959418] TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
[    4.968018] TCP: Hash tables configured (established 524288 bind 65536)
[    4.974722] TCP reno registered
[    4.978250] UDP hash table entries: 4096 (order: 7, 786432 bytes)
[    4.984913] UDP-Lite hash table entries: 4096 (order: 7, 786432 bytes)
[    4.991997] NET: Registered protocol family 1
[    4.996963] RPC: Registered udp transport module.
[    5.001766] RPC: Registered tcp transport module.
[    5.006560] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    5.013180] pci 0000:00:1a.0: uhci_check_and_reset_hc: legsup = 0x0f30
[    5.019794] pci 0000:00:1a.0: Performing full reset
[    5.024772] pci 0000:00:1a.2: uhci_check_and_reset_hc: legsup = 0x0030
[    5.031381] pci 0000:00:1a.2: Performing full reset
[    5.036416] pci 0000:00:1a.7: EHCI: BIOS handoff
[    6.138220] pci 0000:00:1a.7: EHCI: BIOS handoff failed (BIOS bug?) 01010001
[    6.145523] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x1f30
[    6.152136] pci 0000:00:1d.0: Performing full reset
[    6.157115] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x0030
[    6.163722] pci 0000:00:1d.1: Performing full reset
[    6.168699] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x0030
[    6.175306] pci 0000:00:1d.2: Performing full reset
[    6.180326] pci 0000:00:1d.7: EHCI: BIOS handoff
[    7.281248] pci 0000:00:1d.7: EHCI: BIOS handoff failed (BIOS bug?) 01010001
[    7.288562] pci 0000:04:00.0: Disabling L0s
[    7.292903] pci 0000:04:00.1: Disabling L0s
[    7.297360] pci 0000:10:01.0: Boot video device
[    7.301985] PCI: CLS 64 bytes, default 64
[    7.306231] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    7.312756] Placing 64MB software IO TLB between ffff8800b6400000 - ffff8800ba400000
[    7.320644] software IO TLB at phys 0xb6400000 - 0xba400000
[    7.342342] Machine check injector initialized
[    7.354261] microcode: CPU0 sig=0x106a4, pf=0x1, revision=0x7
[    7.360108] microcode: CPU1 sig=0x106a4, pf=0x1, revision=0x7
[    7.365946] microcode: CPU2 sig=0x106a4, pf=0x1, revision=0x7
[    7.371784] microcode: CPU3 sig=0x106a4, pf=0x1, revision=0x7
[    7.377629] microcode: CPU4 sig=0x106a4, pf=0x1, revision=0x7
[    7.383473] microcode: CPU5 sig=0x106a4, pf=0x1, revision=0x7
[    7.389325] microcode: CPU6 sig=0x106a4, pf=0x1, revision=0x7
[    7.395168] microcode: CPU7 sig=0x106a4, pf=0x1, revision=0x7
[    7.401232] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    7.410166] Scanning for low memory corruption every 60 seconds
[    7.419890] Initializing RT-Tester: OK
[    7.423893] audit: initializing netlink socket (disabled)
[    7.429412] type=2000 audit(1289663505.419:1): initialized
[    7.443609] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    7.451474] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    7.461716] fuse init (API version 7.15)
[    7.466113] msgmni has been set to 11844
[    7.475102] pcieport 0000:00:01.0: ACPI _OSC control granted for 0x1c
[    7.481645] pcieport 0000:00:01.0: setting latency timer to 64
[    7.487629] pcieport 0000:00:01.0: irq 88 for MSI/MSI-X
[    7.495372] pcieport 0000:00:02.0: ACPI _OSC control granted for 0x1c
[    7.501914] pcieport 0000:00:02.0: setting latency timer to 64
[    7.507877] pcieport 0000:00:02.0: irq 89 for MSI/MSI-X
[    7.515446] pcieport 0000:00:03.0: ACPI _OSC control granted for 0x1c
[    7.521988] pcieport 0000:00:03.0: setting latency timer to 64
[    7.527949] pcieport 0000:00:03.0: irq 90 for MSI/MSI-X
[    7.535820] pcieport 0000:00:04.0: ACPI _OSC control granted for 0x1c
[    7.542362] pcieport 0000:00:04.0: setting latency timer to 64
[    7.548325] pcieport 0000:00:04.0: irq 91 for MSI/MSI-X
[    7.556268] pcieport 0000:00:05.0: ACPI _OSC control granted for 0x1c
[    7.562807] pcieport 0000:00:05.0: setting latency timer to 64
[    7.568769] pcieport 0000:00:05.0: irq 92 for MSI/MSI-X
[    7.576314] pcieport 0000:00:06.0: ACPI _OSC control granted for 0x1c
[    7.582854] pcieport 0000:00:06.0: setting latency timer to 64
[    7.588814] pcieport 0000:00:06.0: irq 93 for MSI/MSI-X
[    7.596595] pcieport 0000:00:07.0: ACPI _OSC control granted for 0x1c
[    7.603131] pcieport 0000:00:07.0: setting latency timer to 64
[    7.609094] pcieport 0000:00:07.0: irq 94 for MSI/MSI-X
[    7.616908] pcieport 0000:00:08.0: ACPI _OSC control granted for 0x1c
[    7.623452] pcieport 0000:00:08.0: setting latency timer to 64
[    7.629427] pcieport 0000:00:08.0: irq 95 for MSI/MSI-X
[    7.637440] pcieport 0000:00:09.0: ACPI _OSC control granted for 0x1c
[    7.643979] pcieport 0000:00:09.0: setting latency timer to 64
[    7.649939] pcieport 0000:00:09.0: irq 96 for MSI/MSI-X
[    7.657878] pcieport 0000:00:0a.0: ACPI _OSC control granted for 0x1c
[    7.664413] pcieport 0000:00:0a.0: setting latency timer to 64
[    7.670373] pcieport 0000:00:0a.0: irq 97 for MSI/MSI-X
[    7.678006] pcieport 0000:00:1c.0: ACPI _OSC control granted for 0x1c
[    7.684543] pcieport 0000:00:1c.0: setting latency timer to 64
[    7.690511] pcieport 0000:00:1c.0: irq 98 for MSI/MSI-X
[    7.698084] pcieport 0000:00:1c.4: ACPI _OSC control granted for 0x1c
[    7.704625] pcieport 0000:00:1c.4: setting latency timer to 64
[    7.710590] pcieport 0000:00:1c.4: irq 99 for MSI/MSI-X
[    7.717162] aer 0000:00:01.0:pcie02: service driver aer loaded
[    7.723231] aer 0000:00:02.0:pcie02: service driver aer loaded
[    7.729207] aer 0000:00:03.0:pcie02: service driver aer loaded
[    7.735192] aer 0000:00:04.0:pcie02: service driver aer loaded
[    7.741233] aer 0000:00:05.0:pcie02: service driver aer loaded
[    7.747283] aer 0000:00:06.0:pcie02: service driver aer loaded
[    7.753268] aer 0000:00:07.0:pcie02: service driver aer loaded
[    7.759306] aer 0000:00:08.0:pcie02: service driver aer loaded
[    7.765282] aer 0000:00:09.0:pcie02: service driver aer loaded
[    7.771331] aer 0000:00:0a.0:pcie02: service driver aer loaded
[    7.777600] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    7.785406] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input0
[    7.793739] ACPI: Sleep Button [SLPB]
[    7.798028] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    7.806361] ACPI: Power Button [PWRB]
[    7.810635] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    7.818189] ACPI: Power Button [PWRF]
[    7.823600] ACPI: acpi_idle registered with cpuidle
[    7.830039] Monitor-Mwait will be used to enter C-3 state
[    7.835629] Monitor-Mwait will be used to enter C-3 state
[    8.102297] Initializing Nozomi driver 2.1d (build date: Nov 13 2010 15:41:18)
[    8.112978] Non-volatile memory driver v1.3
[    8.118028] Linux agpgart interface v0.103
[    8.122456] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    8.131563] Hangcheck: Using getrawmonotonic().
[    8.136406] [drm] Initialized drm 1.1.0 20060810
[    8.142698] [drm:i915_init] *ERROR* drm/i915 can't work without intel_agp module!
[    8.150331] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    8.177560] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.220294] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    8.296315] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.338448] 00:06: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    8.373599] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k6-NAPI
[    8.380730] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    8.386801] e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
[    8.392801] e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
[    8.399145] Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
[    8.405838] Copyright (c) 2007-2009 Intel Corporation.
[    8.411119] igb 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    8.417920] igb 0000:01:00.0: setting latency timer to 64
[    8.423755] igb 0000:01:00.0: irq 100 for MSI/MSI-X
[    8.428724] igb 0000:01:00.0: irq 101 for MSI/MSI-X
[    8.433694] igb 0000:01:00.0: irq 102 for MSI/MSI-X
[    8.438664] igb 0000:01:00.0: irq 103 for MSI/MSI-X
[    8.443634] igb 0000:01:00.0: irq 104 for MSI/MSI-X
[    8.448602] igb 0000:01:00.0: irq 105 for MSI/MSI-X
[    8.453575] igb 0000:01:00.0: irq 106 for MSI/MSI-X
[    8.458544] igb 0000:01:00.0: irq 107 for MSI/MSI-X
[    8.463515] igb 0000:01:00.0: irq 108 for MSI/MSI-X
[    8.648228] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
[    8.655190] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:30:48:c6:8a:aa
[    8.662480] igb 0000:01:00.0: eth0: PBA No: 0010ff-0ff
[    8.667699] igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    8.675435] igb 0000:01:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    8.682229] igb 0000:01:00.1: setting latency timer to 64
[    8.688014] igb 0000:01:00.1: irq 109 for MSI/MSI-X
[    8.692982] igb 0000:01:00.1: irq 110 for MSI/MSI-X
[    8.697965] igb 0000:01:00.1: irq 111 for MSI/MSI-X
[    8.702930] igb 0000:01:00.1: irq 112 for MSI/MSI-X
[    8.707901] igb 0000:01:00.1: irq 113 for MSI/MSI-X
[    8.712870] igb 0000:01:00.1: irq 114 for MSI/MSI-X
[    8.717842] igb 0000:01:00.1: irq 115 for MSI/MSI-X
[    8.722813] igb 0000:01:00.1: irq 116 for MSI/MSI-X
[    8.727793] igb 0000:01:00.1: irq 117 for MSI/MSI-X
[    8.902004] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
[    8.908963] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:30:48:c6:8a:ab
[    8.916255] igb 0000:01:00.1: eth1: PBA No: 0010ff-0ff
[    8.921482] igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    8.929385] Intel(R) Virtual Function Network Driver - version 1.0.0-k0
[    8.936087] Copyright (c) 2009 Intel Corporation.
[    8.941107] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.84-k2
[    8.949087] ixgbe: Copyright (c) 1999-2010 Intel Corporation.
[    8.955030] ixgbe 0000:04:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    8.962063] ixgbe 0000:04:00.0: setting latency timer to 64
[    9.038167] ixgbe 0000:04:00.0: irq 118 for MSI/MSI-X
[    9.043316] ixgbe 0000:04:00.0: irq 119 for MSI/MSI-X
[    9.048457] ixgbe 0000:04:00.0: irq 120 for MSI/MSI-X
[    9.053601] ixgbe 0000:04:00.0: irq 121 for MSI/MSI-X
[    9.058743] ixgbe 0000:04:00.0: irq 122 for MSI/MSI-X
[    9.063886] ixgbe 0000:04:00.0: irq 123 for MSI/MSI-X
[    9.069028] ixgbe 0000:04:00.0: irq 124 for MSI/MSI-X
[    9.074173] ixgbe 0000:04:00.0: irq 125 for MSI/MSI-X
[    9.079316] ixgbe 0000:04:00.0: irq 126 for MSI/MSI-X
[    9.085550] ixgbe 0000:04:00.0: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    9.094030] ixgbe 0000:04:00.0: (PCI Express:2.5Gb/s:Width x8) 00:1b:21:29:17:d5
[    9.101711] ixgbe 0000:04:00.0: MAC: 1, PHY: 5, PBA No: e27462-006
[    9.111660] ixgbe 0000:04:00.0: Intel(R) 10 Gigabit Network Connection
[    9.118364] ixgbe 0000:04:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    9.125398] ixgbe 0000:04:00.1: setting latency timer to 64
[   10.168222] ixgbe 0000:04:00.1: irq 127 for MSI/MSI-X
[   10.173370] ixgbe 0000:04:00.1: irq 128 for MSI/MSI-X
[   10.178508] ixgbe 0000:04:00.1: irq 129 for MSI/MSI-X
[   10.183652] ixgbe 0000:04:00.1: irq 130 for MSI/MSI-X
[   10.188794] ixgbe 0000:04:00.1: irq 131 for MSI/MSI-X
[   10.193938] ixgbe 0000:04:00.1: irq 132 for MSI/MSI-X
[   10.199081] ixgbe 0000:04:00.1: irq 133 for MSI/MSI-X
[   10.204224] ixgbe 0000:04:00.1: irq 134 for MSI/MSI-X
[   10.209367] ixgbe 0000:04:00.1: irq 135 for MSI/MSI-X
[   10.215865] ixgbe 0000:04:00.1: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[   10.224339] ixgbe 0000:04:00.1: (PCI Express:2.5Gb/s:Width x8) 00:1b:21:29:17:d4
[   10.232023] ixgbe 0000:04:00.1: MAC: 1, PHY: 5, PBA No: e27462-006
[   10.242236] ixgbe 0000:04:00.1: Intel(R) 10 Gigabit Network Connection
[   10.249051] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   10.256265] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   10.264356] jme: JMicron JMC2XX ethernet driver version 1.0.7
[   10.270399] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   10.276577] e100: Copyright(c) 1999-2006 Intel Corporation
[   10.282224] e100 0000:0c:01.0: PCI INT A -> GSI 48 (level, low) -> IRQ 48
[   10.317354] e100 0000:0c:01.0: PME# disabled
[   10.323369] e100 0000:0c:01.0: eth4: addr 0xfbd20000, irq 48, MAC addr 00:02:b3:b7:a9:b0
[   10.333149] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   10.341410] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.2.6 (Oct 12, 2010)
[   10.349682] sky2: driver version 1.28
[   10.357547] tun: Universal TUN/TAP device driver, 1.6
[   10.362683] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   10.370328] usbcore: registered new interface driver catc
[   10.375814] catc: v2.8:CATC EL1210A NetMate USB Ethernet driver
[   10.382233] usbcore: registered new interface driver kaweth
[   10.387890] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[   10.395954] usbcore: registered new interface driver pegasus
[   10.401703] rtl8150: v0.6.2 (2004/08/27):rtl8150 based usb-ethernet driver
[   10.409313] usbcore: registered new interface driver rtl8150
[   10.415263] usbcore: registered new interface driver asix
[   10.420933] usbcore: registered new interface driver cdc_ether
[   10.427302] usbcore: registered new interface driver cdc_eem
[   10.433911] usbcore: registered new interface driver dm9601
[   10.439765] usbcore: registered new interface driver smsc75xx
[   10.445992] usbcore: registered new interface driver smsc95xx
[   10.452776] usbcore: registered new interface driver gl620a
[   10.458627] usbcore: registered new interface driver net1080
[   10.464562] usbcore: registered new interface driver plusb
[   10.470524] usbcore: registered new interface driver rndis_host
[   10.476729] usbcore: registered new interface driver cdc_subset
[   10.482953] usbcore: registered new interface driver zaurus
[   10.489506] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   10.497247] usbcore: registered new interface driver int51x1
[   10.502994] netconsole: local port 6665
[   10.506919] netconsole: local IP 10.0.0.0
[   10.511021] netconsole: interface 'eth0'
[   10.515040] netconsole: remote port 6666
[   10.519062] netconsole: remote IP 10.239.51.110
[   10.523686] netconsole: remote ethernet address 00:30:48:fe:19:94
[   10.529866] netconsole: device eth0 not up yet, forcing it
[   12.806421] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[   19.340932] console [netcon0] enabled
[   19.344939] netconsole: network logging started
[   19.350474] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   19.357095] ehci_hcd: block sizes: qh 104 qtd 96 itd 192 sitd 96
[   19.363264] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   19.370518] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[   19.376439] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[   19.381820] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file 'devices'
[   19.389721] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   19.397275] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[   19.408727] ehci_hcd 0000:00:1a.7: reset hcs_params 0x103206 dbg=1 cc=3 pcc=2 ordered !ppc ports=6
[   19.417839] ehci_hcd 0000:00:1a.7: reset hcc_params 16871 thresh 7 uframes 1024 64 bit addr hw prefetch
[   19.427414] ehci_hcd 0000:00:1a.7: debug port 1
[   19.432034] ehci_hcd 0000:00:1a.7: reset command 0080012 (park)=0 ithresh=8 Periodic period=1024 Reset HALT
[   19.445801] ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
[   19.452671] ehci_hcd 0000:00:1a.7: supports USB remote wakeup
[   19.458783] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbf02000
[   19.464530] ehci_hcd 0000:00:1a.7: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[   19.477515] ehci_hcd 0000:00:1a.7: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[   19.491511] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[   19.497442] usb usb1: default language 0x0409
[   19.501905] usb usb1: udev 1, busnum 1, minor = 0
[   19.506693] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   19.513561] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.520932] usb usb1: Product: EHCI Host Controller
[   19.525901] usb usb1: Manufacturer: Linux 2.6.37-rc1+ ehci_hcd
[   19.531816] usb usb1: SerialNumber: 0000:00:1a.7
[   19.537495] usb usb1: usb_probe_device
[   19.541587] usb usb1: configuration #1 chosen from 1 choice
[   19.547505] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[   19.554121] hub 1-0:1.0: usb_probe_interface
[   19.558729] hub 1-0:1.0: usb_probe_interface - got id
[   19.564114] hub 1-0:1.0: USB hub found
[   19.567968] hub 1-0:1.0: 6 ports detected
[   19.572073] hub 1-0:1.0: standalone hub
[   19.576005] hub 1-0:1.0: no power switching (usb 1.0)
[   19.581142] hub 1-0:1.0: individual port over-current protection
[   19.587243] hub 1-0:1.0: power on to power good time: 20ms
[   19.592819] hub 1-0:1.0: local power source is good
[   19.597783] hub 1-0:1.0: trying to enable port power on non-switchable hub
[   19.605114] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   19.613136] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[   19.620397] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[   19.626320] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   19.631640] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '002'
[   19.639185] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[   19.650095] ehci_hcd 0000:00:1d.7: reset hcs_params 0x103206 dbg=1 cc=3 pcc=2 ordered !ppc ports=6
[   19.659207] ehci_hcd 0000:00:1d.7: reset hcc_params 16871 thresh 7 uframes 1024 64 bit addr hw prefetch
[   19.668779] ehci_hcd 0000:00:1d.7: debug port 1
[   19.673404] ehci_hcd 0000:00:1d.7: reset command 0080012 (park)=0 ithresh=8 Periodic period=1024 Reset HALT
[   19.687183] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[   19.694056] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
[   19.699917] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbf01000
[   19.705731] ehci_hcd 0000:00:1a.7: GetStatus port:4 status 001030 0  ACK POWER sig=se0 OCC OC
[   19.714656] ehci_hcd 0000:00:1d.7: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[   19.714660] ehci_hcd 0000:00:1a.7: GetStatus port:6 status 001030 0  ACK POWER sig=se0 OCC OC
[   19.714704] hub 1-0:1.0: state 7 ports 6 chg 0000 evt 0000
[   19.714933] hub 1-0:1.0: state 7 ports 6 chg 0000 evt 0050
[   19.714943] ehci_hcd 0000:00:1a.7: GetStatus port:4 status 001030 0  ACK POWER sig=se0 OCC OC
[   19.714949] hub 1-0:1.0: over-current change on port 4
[   19.714959] hub 1-0:1.0: trying to enable port power on non-switchable hub
[   19.768270] ehci_hcd 0000:00:1d.7: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[   19.781760] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[   19.788781] usb usb2: default language 0x0409
[   19.794317] usb usb2: udev 1, busnum 2, minor = 128
[   19.799524] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[   19.806643] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.814256] usb usb2: Product: EHCI Host Controller
[   19.815966] ehci_hcd 0000:00:1a.7: GetStatus port:6 status 001030 0  ACK POWER sig=se0 OCC OC
[   19.815975] hub 1-0:1.0: over-current change on port 6
[   19.816258] hub 1-0:1.0: trying to enable port power on non-switchable hub
[   19.841010] usb usb2: Manufacturer: Linux 2.6.37-rc1+ ehci_hcd
[   19.847174] usb usb2: SerialNumber: 0000:00:1d.7
[   19.853021] usb usb2: usb_probe_device
[   19.856867] usb usb2: configuration #1 chosen from 1 choice
[   19.862567] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[   19.870559] hub 2-0:1.0: usb_probe_interface
[   19.874926] hub 2-0:1.0: usb_probe_interface - got id
[   19.880068] hub 2-0:1.0: USB hub found
[   19.883921] hub 2-0:1.0: 6 ports detected
[   19.888027] hub 2-0:1.0: standalone hub
[   19.891960] hub 2-0:1.0: no power switching (usb 1.0)
[   19.897104] hub 2-0:1.0: individual port over-current protection
[   19.903202] hub 2-0:1.0: power on to power good time: 20ms
[   19.908780] hub 2-0:1.0: local power source is good
[   19.913750] hub 2-0:1.0: trying to enable port power on non-switchable hub
[   19.921079] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   19.929285] uhci_hcd: USB Universal Host Controller Interface driver
[   19.935796] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   19.943030] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[   19.948958] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[   19.954281] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '003'
[   19.961833] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[   19.973256] uhci_hcd 0000:00:1a.0: detected 2 ports
[   19.978235] uhci_hcd 0000:00:1a.0: uhci_check_and_reset_hc: cmd = 0x0000
[   19.985018] uhci_hcd 0000:00:1a.0: Performing full reset
[   19.990429] uhci_hcd 0000:00:1a.0: supports USB remote wakeup
[   19.996294] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000f0c0
[   20.002206] usb usb3: default language 0x0409
[   20.006670] usb usb3: udev 1, busnum 3, minor = 256
[   20.011632] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[   20.018506] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   20.025890] ehci_hcd 0000:00:1d.7: GetStatus port:1 status 001803 0  ACK POWER sig=j CSC CONNECT
[   20.035069] hub 2-0:1.0: port 1: status 0501 change 0001
[   20.040509] usb usb3: Product: UHCI Host Controller
[   20.045473] usb usb3: Manufacturer: Linux 2.6.37-rc1+ uhci_hcd
[   20.051389] usb usb3: SerialNumber: 0000:00:1a.0
[   20.056995] usb usb3: usb_probe_device
[   20.060849] usb usb3: configuration #1 chosen from 1 choice
[   20.066522] usb usb3: adding 3-0:1.0 (config #1, interface 0)
[   20.072882] hub 3-0:1.0: usb_probe_interface
[   20.077248] hub 3-0:1.0: usb_probe_interface - got id
[   20.082391] hub 3-0:1.0: USB hub found
[   20.086244] hub 3-0:1.0: 2 ports detected
[   20.090350] hub 3-0:1.0: standalone hub
[   20.094280] hub 3-0:1.0: no power switching (usb 1.0)
[   20.099418] hub 3-0:1.0: individual port over-current protection
[   20.105514] hub 3-0:1.0: power on to power good time: 2ms
[   20.111009] hub 3-0:1.0: local power source is good
[   20.115977] hub 3-0:1.0: trying to enable port power on non-switchable hub
[   20.123284] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   20.130946] ehci_hcd 0000:00:1a.7: HS companion for 0000:00:1a.0
[   20.137102] uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[   20.144579] hub 2-0:1.0: state 7 ports 6 chg 0002 evt 0000
[   20.144604] uhci_hcd 0000:00:1a.2: setting latency timer to 64
[   20.144608] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[   20.144941] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '004'
[   20.144950] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 4
[   20.176440] hub 2-0:1.0: port 1, status 0501, change 0000, 480 Mb/s
[   20.183708] uhci_hcd 0000:00:1a.2: detected 2 ports
[   20.188681] uhci_hcd 0000:00:1a.2: uhci_check_and_reset_hc: cmd = 0x0000
[   20.195466] uhci_hcd 0000:00:1a.2: Performing full reset
[   20.200876] uhci_hcd 0000:00:1a.2: supports USB remote wakeup
[   20.206739] uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000f0a0
[   20.212652] usb usb4: default language 0x0409
[   20.217120] usb usb4: udev 1, busnum 4, minor = 384
[   20.222087] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[   20.228979] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   20.233849] ehci_hcd 0000:00:1d.7: port 1 full speed --> companion
[   20.233854] ehci_hcd 0000:00:1d.7: GetStatus port:1 status 003801 0  ACK POWER OWNER sig=j CONNECT
[   20.233861] hub 2-0:1.0: port 1 not reset yet, waiting 50ms
[   20.257359] usb usb4: Product: UHCI Host Controller
[   20.262330] usb usb4: Manufacturer: Linux 2.6.37-rc1+ uhci_hcd
[   20.268249] usb usb4: SerialNumber: 0000:00:1a.2
[   20.274094] usb usb4: usb_probe_device
[   20.277945] usb usb4: configuration #1 chosen from 1 choice
[   20.283619] usb usb4: adding 4-0:1.0 (config #1, interface 0)
[   20.284476] ehci_hcd 0000:00:1d.7: GetStatus port:1 status 003002 0  ACK POWER OWNER sig=se0 CSC
[   20.284512] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   20.284516] hub 2-0:1.0: state 7 ports 6 chg 0000 evt 0002
[   20.310272] hub 4-0:1.0: usb_probe_interface
[   20.314640] hub 4-0:1.0: usb_probe_interface - got id
[   20.319782] hub 4-0:1.0: USB hub found
[   20.323634] hub 4-0:1.0: 2 ports detected
[   20.327743] hub 4-0:1.0: standalone hub
[   20.331673] hub 4-0:1.0: no power switching (usb 1.0)
[   20.336812] hub 4-0:1.0: individual port over-current protection
[   20.342908] hub 4-0:1.0: power on to power good time: 2ms
[   20.348402] hub 4-0:1.0: local power source is good
[   20.353369] hub 4-0:1.0: trying to enable port power on non-switchable hub
[   20.360368] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   20.368335] ehci_hcd 0000:00:1a.7: HS companion for 0000:00:1a.2
[   20.374485] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[   20.381709] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[   20.387629] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   20.392951] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '005'
[   20.400519] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
[   20.411117] uhci_hcd 0000:00:1d.0: detected 2 ports
[   20.416091] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
[   20.422876] uhci_hcd 0000:00:1d.0: Performing full reset
[   20.428285] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
[   20.434146] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000f080
[   20.440045] usb usb5: default language 0x0409
[   20.444509] usb usb5: udev 1, busnum 5, minor = 512
[   20.449478] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[   20.456345] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   20.463744] usb usb5: Product: UHCI Host Controller
[   20.463749] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   20.474271] usb usb5: Manufacturer: Linux 2.6.37-rc1+ uhci_hcd
[   20.480189] usb usb5: SerialNumber: 0000:00:1d.0
[   20.485828] usb usb5: usb_probe_device
[   20.489671] usb usb5: configuration #1 chosen from 1 choice
[   20.495346] usb usb5: adding 5-0:1.0 (config #1, interface 0)
[   20.501711] hub 5-0:1.0: usb_probe_interface
[   20.506080] hub 5-0:1.0: usb_probe_interface - got id
[   20.511223] hub 5-0:1.0: USB hub found
[   20.515073] hub 5-0:1.0: 2 ports detected
[   20.519171] hub 5-0:1.0: standalone hub
[   20.523104] hub 5-0:1.0: no power switching (usb 1.0)
[   20.528249] hub 5-0:1.0: individual port over-current protection
[   20.534346] hub 5-0:1.0: power on to power good time: 2ms
[   20.539841] hub 5-0:1.0: local power source is good
[   20.544809] hub 5-0:1.0: trying to enable port power on non-switchable hub
[   20.551808] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   20.559982] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.0
[   20.566124] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[   20.573347] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[   20.579269] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   20.584592] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '006'
[   20.592145] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
[   20.603617] uhci_hcd 0000:00:1d.1: detected 2 ports
[   20.608594] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd = 0x0000
[   20.615376] uhci_hcd 0000:00:1d.1: Performing full reset
[   20.620787] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
[   20.626632] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000f060
[   20.633652] usb usb6: default language 0x0409
[   20.639191] usb usb6: udev 1, busnum 6, minor = 640
[   20.644403] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[   20.651805] uhci_hcd 0000:00:1d.0: port 1 portsc 009b,00
[   20.657214] hub 5-0:1.0: port 1: status 0101 change 0003
[   20.663717] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   20.671330] usb usb6: Product: UHCI Host Controller
[   20.676554] usb usb6: Manufacturer: Linux 2.6.37-rc1+ uhci_hcd
[   20.682879] usb usb6: SerialNumber: 0000:00:1d.1
[   20.688691] usb usb6: usb_probe_device
[   20.692538] usb usb6: configuration #1 chosen from 1 choice
[   20.698214] usb usb6: adding 6-0:1.0 (config #1, interface 0)
[   20.704602] hub 6-0:1.0: usb_probe_interface
[   20.708971] hub 6-0:1.0: usb_probe_interface - got id
[   20.714116] hub 6-0:1.0: USB hub found
[   20.717968] hub 6-0:1.0: 2 ports detected
[   20.722075] hub 6-0:1.0: standalone hub
[   20.726006] hub 6-0:1.0: no power switching (usb 1.0)
[   20.731152] hub 6-0:1.0: individual port over-current protection
[   20.737255] hub 6-0:1.0: power on to power good time: 2ms
[   20.742749] hub 6-0:1.0: local power source is good
[   20.747712] hub 6-0:1.0: trying to enable port power on non-switchable hub
[   20.755269] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   20.762935] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.1
[   20.769293] hub 5-0:1.0: state 7 ports 2 chg 0002 evt 0000
[   20.769645] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   20.769675] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[   20.769680] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   20.769692] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '007'
[   20.769701] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
[   20.809947] hub 5-0:1.0: port 1, status 0101, change 0000, 12 Mb/s
[   20.817061] uhci_hcd 0000:00:1d.2: detected 2 ports
[   20.822041] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd = 0x0000
[   20.828825] uhci_hcd 0000:00:1d.2: Performing full reset
[   20.834235] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
[   20.840080] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000f040
[   20.845977] usb usb7: default language 0x0409
[   20.850441] usb usb7: udev 1, busnum 7, minor = 768
[   20.855427] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[   20.862295] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   20.869668] usb usb7: Product: UHCI Host Controller
[   20.874635] usb usb7: Manufacturer: Linux 2.6.37-rc1+ uhci_hcd
[   20.880549] usb usb7: SerialNumber: 0000:00:1d.2
[   20.885902] usb usb7: usb_probe_device
[   20.889996] usb usb7: configuration #1 chosen from 1 choice
[   20.895914] usb usb7: adding 7-0:1.0 (config #1, interface 0)
[   20.902526] hub 7-0:1.0: usb_probe_interface
[   20.907139] hub 7-0:1.0: usb_probe_interface - got id
[   20.912524] hub 7-0:1.0: USB hub found
[   20.916617] hub 7-0:1.0: 2 ports detected
[   20.917825] usb 5-1: new full speed USB device using uhci_hcd and address 2
[   20.928037] hub 7-0:1.0: standalone hub
[   20.931968] hub 7-0:1.0: no power switching (usb 1.0)
[   20.937114] hub 7-0:1.0: individual port over-current protection
[   20.943210] hub 7-0:1.0: power on to power good time: 2ms
[   20.948709] hub 7-0:1.0: local power source is good
[   20.953672] hub 7-0:1.0: trying to enable port power on non-switchable hub
[   20.960987] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '001'
[   20.968967] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.2
[   20.976106] usbcore: registered new interface driver libusual
[   20.986318] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
[   20.996674] serio: i8042 KBD port at 0x60,0x64 irq 1
[   21.001745] serio: i8042 AUX port at 0x60,0x64 irq 12
[   21.008634] mice: PS/2 mouse device common for all mice
[   21.018775] rtc_cmos 00:08: RTC can wake from S4
[   21.027853] rtc_cmos 00:08: rtc core: registered rtc_cmos as rtc0
[   21.034312] rtc0: alarms up to one year, y3k, 114 bytes nvram, hpet irqs
[   21.039494] usb 5-1: ep0 maxpacket = 8
[   21.046217] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
[   21.052632] iTCO_wdt: Found a ICH10R TCO device (Version=2, TCOBASE=0x0460)
[   21.057480] usb 5-1: udev 2, busnum 5, minor = 513
[   21.057485] usb 5-1: New USB device found, idVendor=0557, idProduct=8021
[   21.057491] usb 5-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[   21.058814] usb 5-1: usb_probe_device
[   21.058821] usb 5-1: configuration #1 chosen from 1 choice
[   21.061470] usb 5-1: adding 5-1:1.0 (config #1, interface 0)
[   21.062090] hub 5-1:1.0: usb_probe_interface
[   21.062093] hub 5-1:1.0: usb_probe_interface - got id
[   21.062098] hub 5-1:1.0: USB hub found
[   21.063461] hub 5-1:1.0: 4 ports detected
[   21.063465] hub 5-1:1.0: standalone hub
[   21.063469] hub 5-1:1.0: individual port power switching
[   21.063473] hub 5-1:1.0: individual port over-current protection
[   21.063477] hub 5-1:1.0: power on to power good time: 100ms
[   21.065451] hub 5-1:1.0: local power source is good
[   21.065457] hub 5-1:1.0: enabling power on all ports
[   21.069826] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '002'
[   21.069908] hub 6-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   21.069914] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[   21.069934] hub 7-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   21.167447] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[   21.171176] hub 5-1:1.0: port 1: status 0301 change 0001
[   21.177155] usb usb3: suspend_rh (auto-stop)
[   21.183293] iTCO_vendor_support: vendor-support=0
[   21.188111] SoftDog: cannot register miscdev on minor=130 (err=-16)
[   21.206709] cpuidle: using governor ladder
[   21.227400] cpuidle: using governor menu
[   21.231435] ioatdma: Intel(R) QuickData Technology Driver 4.00
[   21.237475] ioatdma 0000:00:16.0: can't derive routing for PCI INT A
[   21.243965] ioatdma 0000:00:16.0: PCI INT A: no GSI
[   21.249081] ioatdma 0000:00:16.0: setting latency timer to 64
[   21.255245] ioatdma 0000:00:16.0: irq 136 for MSI/MSI-X
[   21.274919] uhci_hcd 0000:00:1d.0: reserve dev 2 ep81-INT, period 128, phase 0, 12 us
[   21.283183] hub 5-1:1.0: state 7 ports 4 chg 0002 evt 0000
[   21.289870] hub 5-1:1.0: port 1, status 0301, change 0000, 1.5 Mb/s
[   21.361737] igb 0000:01:00.0: DCA enabled
[   21.362692] usb 5-1.1: new low speed USB device using uhci_hcd and address 3
[   21.373237] igb 0000:01:00.1: DCA enabled
[   21.377420] ioatdma 0000:00:16.1: can't derive routing for PCI INT B
[   21.383882] ioatdma 0000:00:16.1: PCI INT B: no GSI
[   21.388951] ioatdma 0000:00:16.1: setting latency timer to 64
[   21.394826] ioatdma 0000:00:16.1: (31) exceeds max supported channels (4)
[   21.426476] usb usb4: suspend_rh (auto-stop)
[   21.499336] usb 5-1.1: skipped 1 descriptor after interface
[   21.505016] usb 5-1.1: skipped 1 descriptor after interface
[   21.510694] usb 5-1.1: skipped 1 descriptor after interface
[   21.523260] usb 5-1.1: default language 0x0409
[   21.558171] usb 5-1.1: udev 3, busnum 5, minor = 514
[   21.563240] usb 5-1.1: New USB device found, idVendor=0557, idProduct=2261
[   21.570213] usb 5-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[   21.577677] usb 5-1.1: Product: CS1716A V1.0.098
[   21.582384] usb 5-1.1: Manufacturer: ATEN International Co. Ltd
[   21.589438] usb 5-1.1: usb_probe_device
[   21.593374] usb 5-1.1: configuration #1 chosen from 1 choice
[   21.602020] ioatdma 0000:00:16.1: channel enumeration error
[   21.603088] usb 5-1.1: adding 5-1.1:1.0 (config #1, interface 0)
[   21.604167] usb 5-1.1: adding 5-1.1:1.1 (config #1, interface 1)
[   21.604795] kworker/u:0 used greatest stack depth: 6080 bytes left
[   21.604947] usb 5-1.1: adding 5-1.1:1.2 (config #1, interface 2)
[   21.606058] /home/wfg/cc/linux-2.6/drivers/usb/core/inode.c: creating file '003'
[   21.606460] hub 5-1:1.0: state 7 ports 4 chg 0000 evt 0002
[   21.645371] ioatdma 0000:00:16.1: Intel(R) I/OAT DMA Engine init failed
[   21.652203] ioatdma 0000:00:16.1: can't derive routing for PCI INT B
[   21.658711] ioatdma 0000:00:16.2: can't derive routing for PCI INT C
[   21.665182] ioatdma 0000:00:16.2: PCI INT C: no GSI
[   21.670372] ioatdma 0000:00:16.2: setting latency timer to 64
[   21.676266] ioatdma 0000:00:16.2: (31) exceeds max supported channels (4)
[   21.883272] ioatdma 0000:00:16.2: channel enumeration error
[   21.888939] ioatdma 0000:00:16.2: Intel(R) I/OAT DMA Engine init failed
[   21.895720] ioatdma 0000:00:16.2: can't derive routing for PCI INT C
[   21.902192] ioatdma 0000:00:16.3: can't derive routing for PCI INT D
[   21.908634] ioatdma 0000:00:16.3: PCI INT D: no GSI
[   21.913733] ioatdma 0000:00:16.3: setting latency timer to 64
[   21.919591] ioatdma 0000:00:16.3: (31) exceeds max supported channels (4)
[   21.926491] usb usb6: suspend_rh (auto-stop)
[   22.126640] ioatdma 0000:00:16.3: channel enumeration error
[   22.132312] ioatdma 0000:00:16.3: Intel(R) I/OAT DMA Engine init failed
[   22.139106] ioatdma 0000:00:16.3: can't derive routing for PCI INT D
[   22.145592] ioatdma 0000:00:16.4: can't derive routing for PCI INT A
[   22.152035] ioatdma 0000:00:16.4: PCI INT A: no GSI
[   22.157134] ioatdma 0000:00:16.4: setting latency timer to 64
[   22.163062] ioatdma 0000:00:16.4: can't derive routing for PCI INT A
[   22.169547] ioatdma 0000:00:16.5: can't derive routing for PCI INT B
[   22.175995] ioatdma 0000:00:16.5: PCI INT B: no GSI
[   22.176024] usb usb7: suspend_rh (auto-stop)
[   22.185358]
[   22.187028] ioatdma 0000:00:16.5: setting latency timer to 64
[   22.192886] ioatdma 0000:00:16.5: (31) exceeds max supported channels (4)
[   22.399930] ioatdma 0000:00:16.5: channel enumeration error
[   22.405595] ioatdma 0000:00:16.5: Intel(R) I/OAT DMA Engine init failed
[   22.412384] ioatdma 0000:00:16.5: can't derive routing for PCI INT B
[   22.418859] ioatdma 0000:00:16.6: can't derive routing for PCI INT C
[   22.425308] ioatdma 0000:00:16.6: PCI INT C: no GSI
[   22.430408] ioatdma 0000:00:16.6: setting latency timer to 64
[   22.436268] ioatdma 0000:00:16.6: (31) exceeds max supported channels (4)
[   22.643297] ioatdma 0000:00:16.6: channel enumeration error
[   22.648960] ioatdma 0000:00:16.6: Intel(R) I/OAT DMA Engine init failed
[   22.655730] ioatdma 0000:00:16.6: can't derive routing for PCI INT C
[   22.662198] ioatdma 0000:00:16.7: can't derive routing for PCI INT D
[   22.668654] ioatdma 0000:00:16.7: PCI INT D: no GSI
[   22.673799] ioatdma 0000:00:16.7: setting latency timer to 64
[   22.679660] ioatdma 0000:00:16.7: (31) exceeds max supported channels (4)
[   22.886665] ioatdma 0000:00:16.7: channel enumeration error
[   22.892337] ioatdma 0000:00:16.7: Intel(R) I/OAT DMA Engine init failed
[   22.899118] ioatdma 0000:00:16.7: can't derive routing for PCI INT D
[   22.907392] usbhid 5-1.1:1.0: usb_probe_interface
[   22.912201] usbhid 5-1.1:1.0: usb_probe_interface - got id
[   22.948539] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1.1/5-1.1:1.0/input/input3
[   22.961004] uhci_hcd 0000:00:1d.0: reserve dev 3 ep81-INT, period 8, phase 4, 118 us
[   22.969568] generic-usb 0003:0557:2261.0001: input: USB HID v1.00 Keyboard [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.1/input0
[   22.983292] usbhid 5-1.1:1.1: usb_probe_interface
[   22.988102] usbhid 5-1.1:1.1: usb_probe_interface - got id
[   23.028396] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1.1/5-1.1:1.1/input/input4
[   23.040819] uhci_hcd 0000:00:1d.0: reserve dev 3 ep82-INT, period 8, phase 4, 118 us
[   23.049614] generic-usb 0003:0557:2261.0002: input: USB HID v1.00 Device [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.1/input1
[   23.063162] usbhid 5-1.1:1.2: usb_probe_interface
[   23.067965] usbhid 5-1.1:1.2: usb_probe_interface - got id
[   23.095384] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1.1/5-1.1:1.2/input/input5
[   23.108980] generic-usb 0003:0557:2261.0003: input: USB HID v1.10 Mouse [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.1/input2
[   23.123341] usbcore: registered new interface driver usbhid
[   23.129016] usbhid: USB HID core driver
[   23.134580] dell-wmi: No known WMI GUID found
[   23.139050] acer-wmi: Acer Laptop ACPI-WMI Extras
[   23.143862] acer-wmi: No or unsupported WMI interface, unable to load
[   23.154304] ALSA device list:
[   23.157388]   No soundcards found.
[   23.161430] oprofile: using NMI interrupt.
[   23.165674] netem: version 1.2
[   23.168833] Netfilter messages via NETLINK v0.30.
[   23.173688] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   23.180517] ctnetlink v0.93: registering with nfnetlink.
[   23.185975] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
[   23.193029] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   23.200315] xt_time: kernel timezone is -0000
[   23.206425] ip_tables: (C) 2000-2006 Netfilter Core Team
[   23.212506] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   23.219035] arp_tables: (C) 2002 David S. Miller
[   23.224138] TCP bic registered
[   23.227546] TCP cubic registered
[   23.231126] TCP westwood registered
[   23.234963] TCP highspeed registered
[   23.238889] TCP hybla registered
[   23.242464] TCP htcp registered
[   23.245961] TCP vegas registered
[   23.249545] TCP veno registered
[   23.253040] TCP scalable registered
[   23.256878] TCP lp registered
[   23.260195] TCP yeah registered
[   23.263690] TCP illinois registered
[   23.267528] Initializing XFRM netlink socket
[   23.272177] NET: Registered protocol family 17
[   23.277239] NET: Registered protocol family 15
[   23.281871] Bridge firewalling registered
[   23.285989] Ebtables v2.0 registered
[   23.309105] registered taskstats version 1
[   23.316236]   Magic number: 2:936:891
[   23.320092] tty ptyy1: hash matches
[   23.323862] rtc_cmos 00:08: setting system clock to 2010-11-13 15:52:04 UTC (1289663524)
[   25.361318] Sending DHCP requests ., OK
[   25.378225] IP-Config: Got DHCP answer from 192.168.1.209, my address is 192.168.1.31
[   26.736524] IP-Config: Complete:
[   26.739782]      device=eth0, addr=192.168.1.31, mask=255.255.255.0, gw=192.168.1.1,
[   26.747939]      host=lkp-ne02, domain=tsp.org, nis-domain=(none),
[   26.754311]      bootserver=192.168.1.209, rootserver=10.239.51.240, rootpath=
[   26.785639] VFS: Mounted root (nfs filesystem) on device 0:14.
[   26.791842] debug: unmapping init memory ffffffff82448000..ffffffff826f0000
INIT: version 2.86 booting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
