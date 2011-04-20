Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 49C5F8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 12:33:05 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110420174027.4631.A69D9226@jp.fujitsu.com>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com>
	 <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	 <20110420174027.4631.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 11:32:58 -0500
Message-ID: <1303317178.2587.30.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, 2011-04-20 at 17:40 +0900, KOSAKI Motohiro wrote:
> > > btw, x86 don't have an issue. Probably it's a reason why this issue was neglected
> > > long time.
> > >
> > > arch/x86/Kconfig
> > > -------------------------------------
> > > config ARCH_DISCONTIGMEM_ENABLE
> > >        def_bool y
> > >        depends on NUMA && X86_32
> > 
> > That part makes me think the best option is to make parisc do
> > CONFIG_NUMA as well regardless of the historical intent was.
> > 
> >                         Pekka
> 
> This?

I'm afraid it doesn't boot (it's another slub crash):

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.39-rc3+ (jejb@ion) (gcc version 4.2.4 (Debian 4.2.4-6)) #30 SMP Wed Apr 20 08:52:23 PDT 2011
[    0.000000] unwind_init: start = 0x4057a000, end = 0x405b0e80, entries = 14056
[    0.000000] WARNING: Out of order unwind entry! 000000004057b470 and 000000004057b480
[    0.000000] WARNING: Out of order unwind entry! 000000004057b480 and 000000004057b490
[    0.000000] WARNING: Out of order unwind entry! 000000004057c160 and 000000004057c170
[    0.000000] WARNING: Out of order unwind entry! 000000004057c170 and 000000004057c180
[    0.000000] FP[0] enabled: Rev 1 Model 20
[    0.000000] The 64-bit Kernel has started...
[    0.000000] bootconsole [ttyB0] enabled
[    0.000000] Initialized PDC Console for debugging.
[    0.000000] Determining PDC firmware type: 64 bit PAT.
[    0.000000] model 00008870 00000491 00000000 00000002 3e0505e7352af710 100000f0 00000008 000000b2 000000b2
[    0.000000] vers  00000301
[    0.000000] CPUID vers 20 rev 4 (0x00000284)
[    0.000000] capabilities 0x35
[    0.000000] model 9000/800/rp3440  
[    0.000000] parisc_cache_init: Only equivalent aliasing supported!
[    0.000000] Memory Ranges:
[    0.000000]  0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
[    0.000000]  1) Start 0x0000004040000000 End 0x000000407fdfffff Size   1022 MB
[    0.000000] Total Memory: 2046 MB
[    0.000000] initrd: 7f390000-7ffedaa1
[    0.000000] initrd: reserving 3f390000-3ffedaa1 (mem_max 7fe00000)
[    0.000000] PERCPU: Embedded 10 pages/cpu @00000000418f5000 s12288 r8192 d20480 u40960
[    0.000000] SMP: bootstrap CPU ID is 0
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 258560
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:  root=/dev/sda3 panic=5 console=ttyS1 palo_kernel=1/vmlinux-test
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Memory: 2042228k/2095104k available (3849k kernel code, 52876k reserved, 1661k data, 324k init)
[    0.000000] virtual kernel memory layout:
[    0.000000]     vmalloc : 0x0000000000008000 - 0x000000003f000000   (1007 MB)
[    0.000000]     memory  : 0x0000000040000000 - 0x00000040bfe00000   (264190 MB)
[    0.000000]       .init : 0x000000004077c000 - 0x00000000407cd000   ( 324 kB)
[    0.000000]       .data : 0x00000000404c2518 - 0x0000000040661920   (1661 kB)
[    0.000000]       .text : 0x0000000040100000 - 0x00000000404c2518   (3849 kB)
[    0.000000] SLUB: Genslabs=11, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=8
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:128
[    0.000000] Console: colour dummy device 160x64
[    0.000000] numa_policy_init: interleaving failed
[    0.000000] Calibrating delay loop... 1594.36 BogoMIPS (lpj=3188736)
[    0.048000] pid_max: default: 32768 minimum: 301
[    0.048000] Security Framework initialized
[    0.048000] SELinux:  Disabled at boot.
[    0.060000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.072000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.076000] Mount-cache hash table entries: 256
[    0.076000] Initializing cgroup subsys ns
[    0.076000] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[    0.080000] Initializing cgroup subsys cpuacct
[    0.092000] Initializing cgroup subsys devices
[    0.092000] Initializing cgroup subsys freezer
[    0.100000] Initializing cgroup subsys net_cls
[    0.100000] Initializing cgroup subsys blkio
[    0.200000] Backtrace:
[    0.200000]  [<000000004021c938>] add_partial+0x28/0x98
[    0.200000]  [<000000004021faa0>] __slab_free+0x1d0/0x1d8
[    0.200000]  [<000000004021fd04>] kmem_cache_free+0xc4/0x128
[    0.200000]  [<000000004033bf9c>] ida_get_new_above+0x21c/0x2c0
[    0.200000]  [<00000000402a8980>] sysfs_new_dirent+0xd0/0x238
[    0.200000]  [<00000000402a974c>] create_dir+0x5c/0x168
[    0.200000]  [<00000000402a9ab0>] sysfs_create_dir+0x98/0x128
[    0.200000]  [<000000004033d6c4>] kobject_add_internal+0x114/0x258
[    0.200000]  [<000000004033d9ac>] kobject_add_varg+0x7c/0xa0
[    0.200000]  [<000000004033df20>] kobject_add+0x50/0x90
[    0.200000]  [<000000004033dfb4>] kobject_create_and_add+0x54/0xc8
[    0.200000]  [<00000000407862a0>] cgroup_init+0x138/0x1f0
[    0.200000]  [<000000004077ce50>] start_kernel+0x5a0/0x840
[    0.200000]  [<000000004011fa3c>] start_parisc+0xa4/0xb8
[    0.200000]  [<00000000404bb034>] packet_ioctl+0x16c/0x208
[    0.200000]  [<000000004049ac30>] ip_mroute_setsockopt+0x260/0xf20
[    0.200000] 
[    0.200000] 
[    0.200000] Kernel Fault: Code=26 regs=00000000405bca80 (Addr=0000000000000000)
[    0.200000] 
[    0.200000]      YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
[    0.200000] PSW: 00001000000001001111001000001110 Not tainted
[    0.200000] r00-03  000000ff0804f20e 0000000040778360 000000004021c938 0000000000000000
[    0.200000] r04-07  0000000040754b60 0000000000000001 00000000418b1440 000000007ec01280
[    0.200000] r08-11  0000000000000000 00000000405f7380 00000000000003c0 000000007fffffff
[    0.200000] r12-15  00000000405bc7d8 00000000405f7398 00000000405bc6e8 00000000000041ed
[    0.200000] r16-19  00000000f0d00b0c 0000000000000000 0000000000000000 0000000000000000
[    0.200000] r20-23  000000000800000e 0000000000000001 00000000f0000000 000000004033bf9c
[    0.200000] r24-27  0000000000000001 00000000418b1440 0000000000000000 0000000040754b60
[    0.200000] r28-31  000000007ec08000 00000000405bca50 00000000405bca80 000000000000001d
[    0.200000] sr00-03  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.200000] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.200000] 
[    0.200000] IASQ: 0000000000000000 0000000000000000 IAOQ: 000000004011c0f0 000000004011c0f4
[    0.200000]  IIR: 0f4015dc    ISR: 0000000000000000  IOR: 0000000000000000
[    0.200000]  CPU:        0   CR30: 00000000405bc000 CR31: fffffff0f0e098e0
[    0.200000]  ORIG_R28: 0000000000000100
[    0.200000]  IAOQ[0]: _raw_spin_lock+0x0/0x20
[    0.200000]  IAOQ[1]: _raw_spin_lock+0x4/0x20
[    0.200000]  RP(r2): add_partial+0x28/0x98
[    0.200000] Backtrace:
[    0.200000]  [<000000004021c938>] add_partial+0x28/0x98
[    0.200000]  [<000000004021faa0>] __slab_free+0x1d0/0x1d8
[    0.200000]  [<000000004021fd04>] kmem_cache_free+0xc4/0x128
[    0.200000]  [<000000004033bf9c>] ida_get_new_above+0x21c/0x2c0
[    0.200000]  [<00000000402a8980>] sysfs_new_dirent+0xd0/0x238
[    0.200000]  [<00000000402a974c>] create_dir+0x5c/0x168
[    0.200000]  [<00000000402a9ab0>] sysfs_create_dir+0x98/0x128
[    0.200000]  [<000000004033d6c4>] kobject_add_internal+0x114/0x258
[    0.200000]  [<000000004033d9ac>] kobject_add_varg+0x7c/0xa0
[    0.200000]  [<000000004033df20>] kobject_add+0x50/0x90
[    0.200000]  [<000000004033dfb4>] kobject_create_and_add+0x54/0xc8
[    0.200000]  [<00000000407862a0>] cgroup_init+0x138/0x1f0
[    0.200000]  [<000000004077ce50>] start_kernel+0x5a0/0x840
[    0.200000]  [<000000004011fa3c>] start_parisc+0xa4/0xb8
[    0.200000]  [<00000000404bb034>] packet_ioctl+0x16c/0x208
[    0.200000]  [<000000004049ac30>] ip_mroute_setsockopt+0x260/0xf20
[    0.200000] 
[    0.200000] Kernel panic - not syncing: Kernel Fault
[    0.200000] Backtrace:
[    0.200000]  [<000000004011fec4>] show_stack+0x14/0x20
[    0.200000]  [<000000004011fee8>] dump_stack+0x18/0x28
[    0.200000]  [<000000004015a9a4>] panic+0xd4/0x368
[    0.200000]  [<0000000040120564>] parisc_terminate+0x14c/0x170
[    0.200000]  [<0000000040120adc>] handle_interruption+0x2ac/0x8f8
[    0.200000]  [<000000004011c0f0>] _raw_spin_lock+0x0/0x20
[    0.200000] 
[    0.200000] Rebooting in 5 seconds..

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
