Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7D96B009B
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 04:30:40 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8L8UX6G000631
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:00:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8L8UWbd2637946
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:00:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8L8UW2q030209
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 18:30:32 +1000
Message-ID: <4AB739A6.5060807@in.ibm.com>
Date: Mon, 21 Sep 2009 14:00:30 +0530
From: Sachin Sant <sachinp@in.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi> <4AB6508C.4070602@kernel.org>
In-Reply-To: <4AB6508C.4070602@kernel.org>
Content-Type: multipart/mixed;
 boundary="------------050707050505020208000000"
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050707050505020208000000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tejun Heo wrote:
> Pekka Enberg wrote:
>   
>> Tejun Heo wrote:
>>     
>>> Pekka Enberg wrote:
>>>       
>>>> On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>>>>         
>>>>> SLQB used a seemingly nice hack to allocate per-node data for the
>>>>> statically
>>>>> initialised caches. Unfortunately, due to some unknown per-cpu
>>>>> optimisation, these regions are being reused by something else as the
>>>>> per-node data is getting randomly scrambled. This patch fixes the
>>>>> problem but it's not fully understood *why* it fixes the problem at the
>>>>> moment.
>>>>>           
>>>> Ouch, that sounds bad. I guess it's architecture specific bug as x86
>>>> works ok? Lets CC Tejun.
>>>>         
>>> Is the corruption being seen on ppc or s390?
>>>       
>> On ppc.
>>     
>
> Can you please post full dmesg showing the corruption?  Also, if you
> apply the attached patch, does the added BUG_ON() trigger?
>   
I applied the three patches from Mel and one from Tejun.
With these patches applied the machine boots past
the original reported SLQB problem, but then hangs
just after printing these messages.

<6>ehea: eth0: Physical port up
<7>irq: irq 33539 on host null mapped to virtual irq 259
<6>ehea: External switch port is backup port
<7>irq: irq 33540 on host null mapped to virtual irq 260
<6>NET: Registered protocol family 10
^^^^^^ Hangs at this point.

Tejun, the above hang looks exactly the same as the one
i have reported here :

http://lists.ozlabs.org/pipermail/linuxppc-dev/2009-September/075791.html

This particular hang was bisected to the following patch

powerpc64: convert to dynamic percpu allocator

This hang can be recreated without SLQB. So i think this is a different
problem. 

I have attached the complete dmesg log here.

Thanks
-Sachin


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------


--------------050707050505020208000000
Content-Type: text/plain;
 name="dmesg-log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg-log"

0:mon> dl
<4>Crash kernel location must be 0x2000000
<6>Reserving 256MB of memory at 32MB for crashkernel (System RAM: 4096MB)
<6>Phyp-dump disabled at boot time
<6>Using pSeries machine description
<7>Page orders: linear mapping = 16, virtual = 16, io = 12
<6>Using 1TB segments
<4>Found initrd at 0xc000000003400000:0xc000000003bcc407
<6>bootconsole [udbg0] enabled
<6>Partition configured for 2 cpus.
<6>CPU maps initialized for 2 threads per core
<7> (thread shift is 1)
<4>Starting Linux PPC64 #2 SMP Mon Sep 21 13:38:58 IST 2009
<4>-----------------------------------------------------
<4>ppc64_pft_size                = 0x1a
<4>physicalMemorySize            = 0x100000000
<4>htab_hash_mask                = 0x7ffff
<4>-----------------------------------------------------
<6>Initializing cgroup subsys cpuset
<6>Initializing cgroup subsys cpu
<5>Linux version 2.6.31-next-20090918 (root@mpower6lp5) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #2 SMP Mon Sep 21 13:38:58 IST 2009
<4>[boot]0012 Setup Arch
<7>Node 0 Memory:
<7>Node 2 Memory: 0x0-0xe0000000
<7>Node 3 Memory: 0xe0000000-0x100000000
<4>EEH: No capable adapters found
<6>PPC64 nvram contains 15360 bytes
<7>Using shared processor idle loop
<4>Zone PFN ranges:
<4>  DMA      0x00000000 -> 0x00010000
<4>  Normal   0x00010000 -> 0x00010000
<4>Movable zone start PFN for each node
<4>early_node_map[2] active PFN ranges
<4>    2: 0x00000000 -> 0x0000e000
<4>    3: 0x0000e000 -> 0x00010000
<4>Could not find start_pfn for node 0
<7>On node 0 totalpages: 0
<7>On node 2 totalpages: 57344
<7>  DMA zone: 56 pages used for memmap
<7>  DMA zone: 0 pages reserved
<7>  DMA zone: 57288 pages, LIFO batch:1
<7>On node 3 totalpages: 8192
<7>  DMA zone: 8 pages used for memmap
<7>  DMA zone: 0 pages reserved
<7>  DMA zone: 8184 pages, LIFO batch:0
<4>[boot]0015 Setup Done
<6>PERCPU: Embedded 2 pages/cpu @c000000001100000 s98568 r0 d32504 u524288
<7>pcpu-alloc: s98568 r0 d32504 u524288 alloc=1*1048576
<7>pcpu-alloc: [0] 0 1 
<4>Built 3 zonelists in Node order, mobility grouping on.  Total pages: 65472
<4>Policy zone: DMA
<5>Kernel command line: root=/dev/sda3 sysrq=8 insmod=sym53c8xx insmod=ipr crashkernel=512M-:256M  
<4>PID hash table entries: 4096 (order: 12, 32768 bytes)
<4>freeing bootmem node 2
<4>freeing bootmem node 3
<6>Memory: 3897728k/4194304k available (9024k kernel code, 296576k reserved, 2880k data, 4310k bss, 576k init)
<6>Hierarchical RCU implementation.
<6>RCU-based detection of stalled CPUs is enabled.
<6>NR_IRQS:512
<4>[boot]0020 XICS Init
<4>[boot]0021 XICS Done
<7>pic: no ISA interrupt controller
<7>time_init: decrementer frequency = 512.000000 MHz
<7>time_init: processor frequency   = 4704.000000 MHz
<6>clocksource: timebase mult[7d0000] shift[22] registered
<7>clockevent: decrementer mult[83126e97] shift[32] cpu[0]
<4>Console: colour dummy device 80x25
<6>console [hvc0] enabled, bootconsole disabled
<6>allocated 2621440 bytes of page_cgroup
<6>please try 'cgroup_disable=memory' option if you don't want memory cgroups
<6>Security Framework initialized
<6>SELinux:  Disabled at boot.
<6>Dentry cache hash table entries: 524288 (order: 6, 4194304 bytes)
<6>Inode-cache hash table entries: 262144 (order: 5, 2097152 bytes)
<4>Mount-cache hash table entries: 4096
<6>Initializing cgroup subsys ns
<6>Initializing cgroup subsys cpuacct
<6>Initializing cgroup subsys memory
<6>Initializing cgroup subsys devices
<6>Initializing cgroup subsys freezer
<7>irq: irq 2 on host null mapped to virtual irq 16
<6>Testing tracer nop: PASSED
<7>clockevent: decrementer mult[83126e97] shift[32] cpu[1]
<4>Processor 1 found.
<6>Brought up 2 CPUs
<7>Node 0 CPUs: 0-1
<7>Node 2 CPUs:
<7>Node 3 CPUs:
<7>CPU0 attaching sched-domain:
<7> domain 0: span 0-1 level SIBLING
<7>  groups: 0 (cpu_power = 589) 1 (cpu_power = 589)
<7>  domain 1: span 0-1 level CPU
<7>   groups: 0-1 (cpu_power = 1178)
<7>CPU1 attaching sched-domain:
<7> domain 0: span 0-1 level SIBLING
<7>  groups: 1 (cpu_power = 589) 0 (cpu_power = 589)
<7>  domain 1: span 0-1 level CPU
<7>   groups: 0-1 (cpu_power = 1178)
<6>NET: Registered protocol family 16
<6>IBM eBus Device Driver
<6>POWER6 performance monitor hardware support registered
<6>PCI: Probing PCI hardware
<7>PCI: Probing PCI hardware done
<4>bio: create slab <bio-0> at 0
<6>vgaarb: loaded
<6>usbcore: registered new interface driver usbfs
<6>usbcore: registered new interface driver hub
<6>usbcore: registered new device driver usb
<6>Switching to clocksource timebase
<6>NET: Registered protocol family 2
<6>IP route cache hash table entries: 32768 (order: 2, 262144 bytes)
<7>Switched to high resolution mode on CPU 0
<6>TCP established hash table entries: 131072 (order: 5, 2097152 bytes)
<6>TCP bind hash table entries: 65536 (order: 5, 2097152 bytes)
<6>TCP: Hash tables configured (established 131072 bind 65536)
<6>TCP reno registered
<6>NET: Registered protocol family 1
<6>Unpacking initramfs...
<7>Switched to high resolution mode on CPU 1
<7>irq: irq 655360 on host null mapped to virtual irq 17
<7>irq: irq 655367 on host null mapped to virtual irq 18
<6>IOMMU table initialized, virtual merging enabled
<7>irq: irq 589825 on host null mapped to virtual irq 19
<7>RTAS daemon started
<6>audit: initializing netlink socket (disabled)
<5>type=2000 audit(1253520704.210:1): initialized
<6>Kprobe smoke test started
<6>Kprobe smoke test passed successfully
<6>Testing tracer sched_switch: PASSED
<6>HugeTLB registered 16 MB page size, pre-allocated 0 pages
<6>HugeTLB registered 16 GB page size, pre-allocated 0 pages
<5>VFS: Disk quotas dquot_6.5.2
<4>Dquot-cache hash table entries: 8192 (order 0, 65536 bytes)
<6>msgmni has been set to 7612
<6>alg: No test for stdrng (krng)
<6>Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
<6>io scheduler noop registered
<6>io scheduler anticipatory registered
<6>io scheduler deadline registered
<6>io scheduler cfq registered (default)
<6>pci_hotplug: PCI Hot Plug PCI Core version: 0.5
<6>rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
<7>vio_register_driver: driver hvc_console registering
<7>HVSI: registered 0 devices
<6>Generic RTC Driver v1.07
<6>Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
<6>pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
<6>input: Macintosh mouse button emulation as /devices/virtual/input/input0
<6>Uniform Multi-Platform E-IDE driver
<6>ide-gd driver 1.18
<6>IBM eHEA ethernet device driver (Release EHEA_0102)
<7>irq: irq 590088 on host null mapped to virtual irq 264
<6>ehea: eth0: Jumbo frames are disabled
<6>ehea: eth0 -> logical port id #2
<6>ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
<6>ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
<6>mice: PS/2 mouse device common for all mice
<6>EDAC MC: Ver: 2.1.0 Sep 21 2009
<6>usbcore: registered new interface driver hiddev
<6>usbcore: registered new interface driver usbhid
<6>usbhid: v2.6:USB HID core driver
<6>TCP cubic registered
<6>NET: Registered protocol family 15
<7>Running feature fixup self-tests ...
<7>Running MSI bitmap self-tests ...
<4>registered taskstats version 1
<6>Running tests on trace events:
<6>Testing event skb_copy_datagram_iovec: OK
<6>Testing event kfree_skb: OK
<6>Testing event block_remap: OK
<6>Testing event block_split: OK
<6>Testing event block_unplug_io: OK
<6>Testing event block_unplug_timer: OK
<6>Testing event block_plug: OK
<6>Testing event block_sleeprq: OK
<6>Testing event block_getrq: OK
<6>Testing event block_bio_queue: OK
<6>Testing event block_bio_frontmerge: OK
<6>Testing event block_bio_backmerge: OK
<6>Testing event block_bio_complete: OK
<6>Testing event block_bio_bounce: OK
<6>Testing event block_rq_complete: OK
<6>Testing event block_rq_requeue: OK
<6>Testing event block_rq_issue: OK
<6>Testing event block_rq_insert: OK
<6>Testing event block_rq_abort: OK
<6>Testing event jbd2_submit_inode_data: OK
<6>Testing event jbd2_end_commit: OK
<6>Testing event jbd2_commit_logging: OK
<6>Testing event jbd2_commit_flushing: OK
<6>Testing event jbd2_commit_locking: OK
<6>Testing event jbd2_start_commit: OK
<6>Testing event jbd2_checkpoint: OK
<6>Testing event ext4_alloc_da_blocks: OK
<6>Testing event ext4_sync_fs: OK
<6>Testing event ext4_sync_file: OK
<6>Testing event ext4_free_blocks: OK
<6>Testing event ext4_allocate_blocks: OK
<6>Testing event ext4_request_blocks: OK
<6>Testing event ext4_mb_discard_preallocations: OK
<6>Testing event ext4_discard_preallocations: OK
<6>Testing event ext4_mb_release_group_pa: OK
<6>Testing event ext4_mb_release_inode_pa: OK
<6>Testing event ext4_mb_new_group_pa: OK
<6>Testing event ext4_mb_new_inode_pa: OK
<6>Testing event ext4_discard_blocks: OK
<6>Testing event ext4_da_write_end: OK
<6>Testing event ext4_da_write_begin: OK
<6>Testing event ext4_da_writepages_result: OK
<6>Testing event ext4_da_write_pages: OK
<6>Testing event ext4_da_writepages: OK
<6>Testing event ext4_writepage: OK
<6>Testing event ext4_journalled_write_end: OK
<6>Testing event ext4_writeback_write_end: OK
<6>Testing event ext4_ordered_write_end: OK
<6>Testing event ext4_write_begin: OK
<6>Testing event ext4_allocate_inode: OK
<6>Testing event ext4_request_inode: OK
<6>Testing event ext4_free_inode: OK
<6>Testing event kmem_cache_free: OK
<6>Testing event kfree: OK
<6>Testing event kmem_cache_alloc_node: OK
<6>Testing event kmalloc_node: OK
<6>Testing event kmem_cache_alloc: OK
<6>Testing event kmalloc: OK
<6>Testing event module_request: OK
<6>Testing event module_put: OK
<6>Testing event module_get: OK
<6>Testing event module_free: OK
<6>Testing event module_load: OK
<6>Testing event workqueue_destruction: OK
<6>Testing event workqueue_creation: OK
<6>Testing event workqueue_execution: OK
<6>Testing event workqueue_insertion: OK
<6>Testing event itimer_expire: OK
<6>Testing event itimer_state: OK
<6>Testing event hrtimer_cancel: OK
<6>Testing event hrtimer_expire_exit: OK
<6>Testing event hrtimer_expire_entry: OK
<6>Testing event hrtimer_start: OK
<6>Testing event hrtimer_init: OK
<6>Testing event timer_cancel: OK
<6>Testing event timer_expire_exit: OK
<6>Testing event timer_expire_entry: OK
<6>Testing event timer_start: OK
<6>Testing event timer_init: OK
<6>Testing event softirq_exit: OK
<6>Testing event softirq_entry: OK
<6>Testing event irq_handler_exit: OK
<6>Testing event irq_handler_entry: OK
<6>Testing event sched_switch: OK
<6>Testing event sched_stat_iowait: OK
<6>Testing event sched_stat_sleep: OK
<6>Testing event sched_stat_runtime: OK
<6>Testing event sched_stat_wait: OK
<6>Testing event sched_signal_send: OK
<6>Testing event sched_process_fork: OK
<6>Testing event sched_process_wait: OK
<6>Testing event sched_process_exit: OK
<6>Testing event sched_process_free: OK
<6>Testing event sched_migrate_task: OK
<6>Testing event sched_wakeup_new: OK
<6>Testing event sched_wakeup: OK
<6>Testing event sched_wait_task: OK
<6>Testing event sched_kthread_stop_ret: OK
<6>Testing event sched_kthread_stop: OK
<6>Running tests on trace event systems:
<6>Testing event system skb: OK
<6>Testing event system block: OK
<6>Testing event system jbd2: OK
<6>Testing event system ext4: OK
<6>Testing event system kmem: OK
<6>Testing event system module: OK
<6>Testing event system workqueue: OK
<6>Testing event system timer: OK
<6>Testing event system irq: OK
<6>Testing event system sched: OK
<6>Running tests on all trace events:
<6>Testing all events: OK
<4>Freeing unused kernel memory: 576k freed
<6>SysRq : Changing Loglevel
<4>Loglevel set to 8
<5>SCSI subsystem initialized
<7>vio_register_driver: driver ibmvscsi registering
<6>ibmvscsi 30000007: SRP_VERSION: 16.a
<6>scsi0 : IBM POWER Virtual SCSI Adapter 1.5.8
<6>ibmvscsi 30000007: partner initialization complete
<6>ibmvscsi 30000007: host srp version: 16.a, host partition VIO Server (1), OS 3, max io 1048576
<6>ibmvscsi 30000007: Client reserve enabled
<6>ibmvscsi 30000007: sent SRP login
<6>ibmvscsi 30000007: SRP_LOGIN succeeded
<5>scsi 0:0:1:0: Direct-Access     AIX      VDASD            0001 PQ: 0 ANSI: 3
<5>scsi 0:0:2:0: CD-ROM            AIX      VOPTA                 PQ: 0 ANSI: 4
<6>udevd version 128 started
<5>sd 0:0:1:0: [sda] 146800640 512-byte logical blocks: (75.1 GB/70.0 GiB)
<5>sd 0:0:1:0: [sda] Write Protect is off
<7>sd 0:0:1:0: [sda] Mode Sense: 17 00 00 08
<5>sd 0:0:1:0: [sda] Cache data unavailable
<3>sd 0:0:1:0: [sda] Assuming drive cache: write through
<5>sd 0:0:1:0: [sda] Cache data unavailable
<3>sd 0:0:1:0: [sda] Assuming drive cache: write through
<6> sda: sda1 sda2 sda3
<5>sd 0:0:1:0: [sda] Cache data unavailable
<3>sd 0:0:1:0: [sda] Assuming drive cache: write through
<5>sd 0:0:1:0: [sda] Attached SCSI disk
<6>kjournald starting.  Commit interval 5 seconds
<6>EXT3 FS on sda3, internal journal
<6>EXT3-fs: mounted filesystem with writeback data mode.
<6>udevd version 128 started
<5>sd 0:0:1:0: Attached scsi generic sg0 type 0
<5>scsi 0:0:2:0: Attached scsi generic sg1 type 5
<4>sr0: scsi-1 drive
<6>Uniform CD-ROM driver Revision: 3.20
<7>sr 0:0:2:0: Attached scsi CD-ROM sr0
<6>Adding 2096320k swap on /dev/sda2.  Priority:-1 extents:1 across:2096320k 
<6>device-mapper: uevent: version 1.0.3
<6>device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
<6>loop: module loaded
<6>fuse init (API version 7.13)
<6>ehea: eth0: Physical port up
<7>irq: irq 33539 on host null mapped to virtual irq 259
<6>ehea: External switch port is backup port
<7>irq: irq 33540 on host null mapped to virtual irq 260
<6>NET: Registered protocol family 10
<3>INFO: RCU detected CPU 0 stall (t=1000 jiffies)
0:mon> e
cpu 0x0: Vector: 501 (Hardware Interrupt) at [c0000000bb1c36f0]
    pc: c000000000043140: .memset+0x60/0xfc
    lr: c00000000016a0ac: .pcpu_alloc+0x710/0x910
    sp: c0000000bb1c3970
   msr: 8000000000009032
  current = 0xc0000000bb1b0800
  paca    = 0xc000000000bb2600
    pid   = 1960, comm = modprobe
0:mon> t
[link register   ] c00000000016a0ac .pcpu_alloc+0x710/0x910
[c0000000bb1c3970] c00000000016a048 .pcpu_alloc+0x6ac/0x910 (unreliable)
[c0000000bb1c3a90] c00000000057c584 .snmp_mib_init+0x34/0x9c
[c0000000bb1c3b20] d0000000023de9a0 .ipv6_add_dev+0x174/0x384 [ipv6]
[c0000000bb1c3bc0] d00000000240a960 .addrconf_init+0x6c/0x194 [ipv6]
[c0000000bb1c3c50] d00000000240a730 .inet6_init+0x1bc/0x34c [ipv6]
[c0000000bb1c3ce0] c0000000000097a4 .do_one_initcall+0x88/0x1bc
[c0000000bb1c3d90] c0000000000d4d44 .SyS_init_module+0x118/0x28c
[c0000000bb1c3e30] c0000000000085b4 syscall_exit+0x0/0x40
--- Exception: c01 (System Call) at 00000fff8486b568
SP (fffd1e3bce0) is in userspace
0:mon>

--------------050707050505020208000000--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
