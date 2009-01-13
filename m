Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C99C56B004F
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 23:54:36 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 9so5071817qwj.44
        for <linux-mm@kvack.org>; Mon, 12 Jan 2009 20:54:32 -0800 (PST)
Message-ID: <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com>
Date: Mon, 12 Jan 2009 23:54:32 -0500
From: "Bryan Donlan" <bdonlan@gmail.com>
Subject: Re: OOPS and panic on 2.6.29-rc1 on xen-x86
In-Reply-To: <20090112172613.GA8746@shion.is.fushizen.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090112172613.GA8746@shion.is.fushizen.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xensource.com, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 12, 2009 at 12:26 PM, Bryan Donlan <bdonlan@gmail.com> wrote:
> [resending with log/config inline as my previous message seems to have
>  been eaten by vger's spam filters]
>
> Hi,
>
> After testing 2.6.29-rc1 on xen-x86 with a btrfs root filesystem, I
> got the OOPS quoted below and a hard freeze shortly after boot.
> Boot messages and config are attached.
>
> This is on a test system, so I'd be happy to test any patches.
>
> Thanks,
>
> Bryan Donlan

I've bisected the bug in question, and the faulty commit appears to be:
commit e97a630eb0f5b8b380fd67504de6cedebb489003
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Jan 6 14:39:19 2009 -0800

    mm: vmalloc use mutex for purge

    The vmalloc purge lock can be a mutex so we can sleep while a purge is
    going on (purge involves a global kernel TLB invalidate, so it can take
    quite a while).

    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

The bug is easily reproducable by a kernel build on -j4 - it will
generally OOPS and panic before the build completes.
Also, I've tested it with ext3, and it still occurs, so it seems
unrelated to btrfs at least :)

>
> ------------[ cut here ]------------
> Kernel BUG at c05ef80d [verbose debug info unavailable]
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/block/xvdc/size
> Modules linked in:
>
> Pid: 0, comm: swapper Not tainted (2.6.29-rc1 #6)
> EIP: 0061:[<c05ef80d>] EFLAGS: 00010087 CPU: 2
> EIP is at schedule+0x7cd/0x950
> EAX: d5aeca80 EBX: 00000002 ECX: 00000000 EDX: d4cb9a40
> ESI: c12f5600 EDI: d4cb9a40 EBP: d6033fa4 ESP: d6033ef4
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0069
> Process swapper (pid: 0, ti=d6032000 task=d6020b70 task.ti=d6032000)
> Stack:
>  000d85bc 00000000 000186a0 00000000 0dd11410 c0105417 c12efe00 0dc367c3
>  00000011 c0105d46 d5a5d310 deadbeef d4cb9a40 c07cc600 c05f1340 c12e0060
>  deadbeef d6020b70 d6020d08 00000002 c014377d 00000000 c12f5600 00002c22
> Call Trace:
>  [<c0105417>] xen_force_evtchn_callback+0x17/0x30
>  [<c0105d46>] check_events+0x8/0x12
>  [<c05f1340>] _spin_unlock_irqrestore+0x20/0x40
>  [<c014377d>] hrtimer_start_range_ns+0x12d/0x2e0
>  [<c014c4f6>] tick_nohz_restart_sched_tick+0x146/0x160
>  [<c0107485>] cpu_idle+0xa5/0xc0
>
> Code: e8 79 6c b1 ff 90 8b 45 a4 e8 20 6a b3 ff 89 f0 e8 d9 1a 00 00
> e9 67 fd ff ff 8d 74 26 00 e8 0b 1d 00 00 8d 76 00 e9 7e f8 ff ff <0f>
> 0b 90 eb fd 8d b6 00 00 00 00 85 ff 8d b6 00 00 00 00 75 11
>
> EIP: [<c05ef80d>] schedule+0x7cd/0x950 SS:ESP 0069:d6033ef4
>
> ---[ end trace 4dda895500d0b401 ]---
>
> Kernel panic - not syncing: Attempted to kill the idle task!
>
> ------------[ cut here ]------------
> WARNING: at kernel/smp.c:299 smp_call_function_many+0x1de/0x240()
> Modules linked in:
> Pid: 0, comm: swapper Tainted: G      D    2.6.29-rc1 #6
> Call Trace:
>  [<c012b4a7>] warn_slowpath+0x87/0xe0
>  [<c014469a>] atomic_notifier_call_chain+0x1a/0x20
>  [<c045728f>] vt_console_print+0x23f/0x330
>  [<c0105417>] xen_force_evtchn_callback+0x17/0x30
>  [<c0105d46>] check_events+0x8/0x12
>  [<c0105caf>] xen_restore_fl_direct_end+0x0/0x1
>  [<c05f1340>] _spin_unlock_irqrestore+0x20/0x40
>  [<c0105400>] xen_force_evtchn_callback+0x0/0x30
>  [<c0105d46>] check_events+0x8/0x12
>  [<c0105caf>] xen_restore_fl_direct_end+0x0/0x1
>  [<c012c0b1>] vprintk+0x1b1/0x370
>  [<c0105d46>] check_events+0x8/0x12
>  [<c0105417>] xen_force_evtchn_callback+0x17/0x30
>  [<c0105d46>] check_events+0x8/0x12
>  [<c014fcee>] smp_call_function_many+0x1de/0x240
>  [<c0106030>] stop_self+0x0/0x30
>  [<c012bc71>] release_console_sem+0x191/0x1e0
>  [<c01095e0>] do_invalid_op+0x0/0xa0
>  [<c014fd6e>] smp_call_function+0x1e/0x30
>  [<c05eeb95>] panic+0x4a/0xec
>  [<c012edda>] do_exit+0x6ea/0x800
>  [<c0105caf>] xen_restore_fl_direct_end+0x0/0x1
>  [<c05f1340>] _spin_unlock_irqrestore+0x20/0x40
>  [<c01095e0>] do_invalid_op+0x0/0xa0
>  [<c05eec4e>] printk+0x17/0x1b
>  [<c01095e0>] do_invalid_op+0x0/0xa0
>  [<c010b7a9>] oops_end+0x99/0xa0
>  [<c010965f>] do_invalid_op+0x7f/0xa0
>  [<c05ef80d>] schedule+0x7cd/0x950
>  [<c01434fb>] hrtimer_get_next_event+0x10b/0x120
>  [<c0118665>] pvclock_clocksource_read+0x55/0xc0
>  [<c0118665>] pvclock_clocksource_read+0x55/0xc0
>  [<c0105be1>] xen_sched_clock+0x21/0x90
>  [<c0105b82>] xen_vcpuop_set_next_event+0x42/0x80
>  [<c014528b>] __update_sched_clock+0x2b/0x1a0
>  [<c05f160a>] error_code+0x72/0x78
>  [<c014007b>] finish_wait+0x2b/0x70
>  [<c05ef80d>] schedule+0x7cd/0x950
>  [<c0105417>] xen_force_evtchn_callback+0x17/0x30
>  [<c0105d46>] check_events+0x8/0x12
>  [<c05f1340>] _spin_unlock_irqrestore+0x20/0x40
>  [<c014377d>] hrtimer_start_range_ns+0x12d/0x2e0
>  [<c014c4f6>] tick_nohz_restart_sched_tick+0x146/0x160
>  [<c0107485>] cpu_idle+0xa5/0xc0
>
> ---[ end trace 4dda895500d0b402 ]---
>
> boot messages:
>
> imklog 3.18.6, log source = /proc/kmsg started.
> Reserving virtual address space above 0xf5800000
> Linux version 2.6.29-rc1 (root@teppei) (gcc version 4.3.2 (Debian 4.3.2-1) ) #6 SMP Sun Jan 11 23:31:59 UTC 2009
> KERNEL supported cpus:
>  Intel GenuineIntel
>  AMD AuthenticAMD
> BIOS-provided physical RAM map:
> Xen: 0000000000000000 - 00000000000a0000 (usable)
> Xen: 00000000000a0000 - 0000000000100000 (reserved)
> Xen: 0000000000100000 - 0000000000813000 (usable)
> Xen: 0000000000813000 - 0000000000870000 (reserved)
> Xen: 0000000000870000 - 0000000016800000 (usable)
> DMI not present or invalid.
> last_pfn = 0x16800 max_arch_pfn = 0x1000000
> kernel direct mapping tables up to 16800000 @ 878000-930000
> NX (Execute Disable) protection: active
> 0MB HIGHMEM available.
> 360MB LOWMEM available.
>  mapped low ram: 0 - 16800000
>  low ram: 00000000 - 16800000
>  bootmap 00002000 - 00004d00
> (7 early reservations) ==> bootmem [0000000000 - 0016800000]
>  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
>  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
>  #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
>  #3 [0000100000 - 0000812fdc]    TEXT DATA BSS ==> [0000100000 - 0000812fdc]
>  #4 [0000870000 - 0000878000]    INIT_PG_TABLE ==> [0000870000 - 0000878000]
>  #5 [0000878000 - 0000924000]          PGTABLE ==> [0000878000 - 0000924000]
>  #6 [0000002000 - 0000005000]          BOOTMAP ==> [0000002000 - 0000005000]
> Zone PFN ranges:
>  DMA      0x00000000 -> 0x00001000
>  Normal   0x00001000 -> 0x00016800
>  HighMem  0x00016800 -> 0x00016800
> Movable zone start PFN for each node
> early_node_map[3] active PFN ranges
>   0: 0x00000000 -> 0x000000a0
>   0: 0x00000100 -> 0x00000813
>   0: 0x00000870 -> 0x00016800
> On node 0 totalpages: 91971
> free_area_init_node: node 0, pgdat c0737d00, node_mem_map c1000000
>  DMA zone: 32 pages used for memmap
>  DMA zone: 0 pages reserved
>  DMA zone: 3875 pages, LIFO batch:0
>  Normal zone: 688 pages used for memmap
>  Normal zone: 87376 pages, LIFO batch:15
> SMP: Allowing 4 CPUs, 0 hotplug CPUs
> Local APIC disabled by BIOS -- you can enable it with "lapic"
> Allocating PCI resources starting at 20000000 (gap: 16800000:e9800000)
> NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:4 nr_node_ids:1
> PERCPU: Allocating 49152 bytes of per cpu data
> trying to map vcpu_info 0 at c12d5020, mfn 5dbb32, offset 32
> cpu 0 using vcpu_info at c12d5020
> trying to map vcpu_info 1 at c12e1020, mfn 5dbb26, offset 32
> cpu 1 using vcpu_info at c12e1020
> trying to map vcpu_info 2 at c12ed020, mfn 5dbb1a, offset 32
> cpu 2 using vcpu_info at c12ed020
> trying to map vcpu_info 3 at c12f9020, mfn 5dbb0e, offset 32
> cpu 3 using vcpu_info at c12f9020
> Xen: using vcpu_info placement
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 91251
> Kernel command line: root=/dev/xvdb ro
> Enabling fast FPU save and restore... done.
> Enabling unmasked SIMD FPU exception support... done.
> Initializing CPU#0
> PID hash table entries: 2048 (order: 11, 8192 bytes)
> Detected 2500.090 MHz processor.
> Console: colour dummy device 80x25
> console [tty0] enabled
> console [hvc0] enabled
> Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> Memory: 356192k/368640k available (5065k kernel code, 11464k reserved, 1486k data, 376k init, 0k highmem)
> virtual kernel memory layout:
>   fixmap  : 0xf56e9000 - 0xf57ff000   (1112 kB)
>   pkmap   : 0xf5200000 - 0xf5400000   (2048 kB)
>   vmalloc : 0xd7000000 - 0xf51fe000   ( 481 MB)
>   lowmem  : 0xc0000000 - 0xd6800000   ( 360 MB)
>     .init : 0xc076f000 - 0xc07cd000   ( 376 kB)
>     .data : 0xc05f2436 - 0xc0765cac   (1486 kB)
>     .text : 0xc0100000 - 0xc05f2436   (5065 kB)
> Checking if this processor honours the WP bit even in supervisor mode...Ok.
> SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
> Xen: using vcpuop timer interface
> installing Xen timer for CPU 0
> Calibrating delay loop (skipped), value calculated using timer frequency.. 5000.18 BogoMIPS (lpj=2500090)
> Security Framework initialized
> Mount-cache hash table entries: 512
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 6144K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 3
> Freeing SMP alternatives: 24k freed
> cpu 0 spinlock event irq 1
> installing Xen timer for CPU 1
> cpu 1 spinlock event irq 7
> Initializing CPU#1
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 6144K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 3
> installing Xen timer for CPU 2
> cpu 2 spinlock event irq 13
> Initializing CPU#2
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 6144K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 3
> installing Xen timer for CPU 3
> cpu 3 spinlock event irq 19
> Initializing CPU#3
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 6144K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 3
> Brought up 4 CPUs
> net_namespace: 948 bytes
> Booting paravirtualized kernel on Xen
> Xen version: 3.3.1-rc1-pre (preserve-AD)
> xor: automatically using best checksumming function: pIII_sse
>  pIII_sse  :  1304.000 MB/sec
> xor: using function: pIII_sse (1304.000 MB/sec)
> Grant table initialized
> NET: Registered protocol family 16
> bio: create slab <bio-0> at 0
> Switched to high resolution mode on CPU 0
> Switched to high resolution mode on CPU 1
> NET: Registered protocol family 2
> Switched to high resolution mode on CPU 2
> Switched to high resolution mode on CPU 3
> IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
> TCP established hash table entries: 16384 (order: 5, 131072 bytes)
> TCP bind hash table entries: 16384 (order: 5, 131072 bytes)
> TCP: Hash tables configured (established 16384 bind 16384)
> TCP reno registered
> NET: Registered protocol family 1
> platform rtc_cmos: registered platform RTC device (no PNP device found)
> audit: initializing netlink socket (disabled)
> type=2000 audit(1231741980.237:1): initialized
> VFS: Disk quotas dquot_6.5.2
> Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> DLM (built Jan 11 2009 23:09:06) installed
> squashfs: version 4.0 (2009/01/03) Phillip Lougher
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> fuse init (API version 7.11)
> JFS: nTxBlock = 2784, nTxLock = 22277
> SGI XFS with ACLs, security attributes, no debug enabled
> SGI XFS Quota Management subsystem
> Btrfs loaded
> msgmni has been set to 696
> alg: No test for cipher_null (cipher_null-generic)
> alg: No test for digest_null (digest_null-generic)
> alg: No test for compress_null (compress_null-generic)
> alg: No test for fcrypt (fcrypt-generic)
> alg: No test for stdrng (krng)
> alg: No test for stdrng (ansi_cprng)
> async_tx: api initialized (sync-only)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> brd: module loaded
> loop: module loaded
> nbd: registered device at major 43
> blkfront: xvda: barriers enabled
> PPP generic driver version 2.4.2
> xvda:<6>PPP Deflate Compression module registered
> PPP BSD Compression module registered
> PPP MPPE Compression module registered
> SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
> CSLIP: code copyright 1989 Regents of the University of California.
> SLIP linefill/keepalive option.
> Initialising Xen virtual ethernet driver.
> unknown partition table
> tun: Universal TUN/TAP device driver, 1.6
> tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> blkfront: xvdb: barriers enabled
> i8042.c: No controller found.
> xvdb:<6>mice: PS/2 mouse device common for all mice
> md: linear personality registered for level -1
> md: raid0 personality registered for level 0
> md: raid1 personality registered for level 1
> raid6: int32x1    972 MB/s
> raid6: int32x2    914 MB/s
> raid6: int32x4    820 MB/s
> raid6: int32x8    714 MB/s
> raid6: mmxx1     2660 MB/s
> raid6: mmxx2     2953 MB/s
> raid6: sse1x1    1464 MB/s
> raid6: sse1x2    2789 MB/s
> raid6: sse2x1    2292 MB/s
> raid6: sse2x2    4746 MB/s
> raid6: using algorithm sse2x2 (4746 MB/s)
> md: raid6 personality registered for level 6
> md: raid5 personality registered for level 5
> md: raid4 personality registered for level 4
> md: multipath personality registered for level -4
> unknown partition table
> device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
> padlock: VIA PadLock not detected.
> padlock: VIA PadLock Hash Engine not detected.
> GACT probability NOT on
> u32 classifier
>   Performance counters on
>   Actions configured
> Netfilter messages via NETLINK v0.30.
> nf_conntrack version 0.5.0 (5760 buckets, 23040 max)
> blkfront: xvdc: barriers enabled
> CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
> nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or
> sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
> IPv4 over IPv4 tunneling driver
> xvdc:<6>GRE over IPv4 tunneling driver
> ip_tables: (C) 2000-2006 Netfilter Core Team
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 10
> lo: Disabled Privacy Extensions
> tunl0: Disabled Privacy Extensions
> ip6_tables: (C) 2000-2006 Netfilter Core Team
> IPv6 over IPv4 tunneling driver
> sit0: Disabled Privacy Extensions
> ip6tnl0: Disabled Privacy Extensions
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> Bridge firewalling registered
> Ebtables v2.0 registered
> ebt_ulog: out of memory trying to call netlink_kernel_create
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> All bugs added by David S. Miller <davem@redhat.com>
> SCTP: Hash tables configured (established 16384 bind 16384)
> IO APIC resources could be not be allocated.
> Using IPI Shortcut mode
> registered taskstats version 1
> unknown partition table
> XENBUS: Device with no driver: device/console/0
> md: Waiting for all devices to be available before autodetect
> md: If you don't use raid, use raid=noautodetect
> md: Autodetecting RAID arrays.
> md: Scanned 0 and added 0 devices.
> md: autorun ...
> md: ... autorun DONE.
> UDF-fs: No partition found (1)
> device fsid 1a4017a58ca6c2cb-8a6af1960616e788 <6>devid 1 transid 22067 /dev/root
> VFS: Mounted root (btrfs filesystem) readonly on device 0:12.
> Freeing unused kernel memory: 376k freed
> Adding 262136k swap on /dev/xvdc.  Priority:-1 extents:1 across:262136k SS
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on xvda, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> warning: `ntpd' uses 32-bit capabilities (legacy support in use)
> eth0: no IPv6 routers present
>
> kernel config:
>
> #
> # Automatically generated make config: don't edit
> # Linux kernel version: 2.6.29-rc1
> # Sun Jan 11 23:31:27 2009
> #
> # CONFIG_64BIT is not set
> CONFIG_X86_32=y
> # CONFIG_X86_64 is not set
> CONFIG_X86=y
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
> CONFIG_GENERIC_TIME=y
> CONFIG_GENERIC_CMOS_UPDATE=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_FAST_CMPXCHG_LOCAL=y
> CONFIG_MMU=y
> CONFIG_ZONE_DMA=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> # CONFIG_GENERIC_TIME_VSYSCALL is not set
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_DEFAULT_IDLE=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> # CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> # CONFIG_ZONE_DMA32 is not set
> CONFIG_ARCH_POPULATES_NODE_MAP=y
> # CONFIG_AUDIT_ARCH is not set
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_GENERIC_PENDING_IRQ=y
> CONFIG_X86_SMP=y
> CONFIG_USE_GENERIC_SMP_HELPERS=y
> CONFIG_X86_32_SMP=y
> CONFIG_X86_HT=y
> CONFIG_X86_BIOS_REBOOT=y
> CONFIG_X86_TRAMPOLINE=y
> CONFIG_KTIME_SCALAR=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
>
> #
> # General setup
> #
> CONFIG_EXPERIMENTAL=y
> CONFIG_LOCK_KERNEL=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_LOCALVERSION=""
> CONFIG_LOCALVERSION_AUTO=y
> CONFIG_SWAP=y
> CONFIG_SYSVIPC=y
> CONFIG_SYSVIPC_SYSCTL=y
> CONFIG_POSIX_MQUEUE=y
> CONFIG_BSD_PROCESS_ACCT=y
> # CONFIG_BSD_PROCESS_ACCT_V3 is not set
> CONFIG_TASKSTATS=y
> CONFIG_TASK_DELAY_ACCT=y
> CONFIG_TASK_XACCT=y
> CONFIG_TASK_IO_ACCOUNTING=y
> CONFIG_AUDIT=y
> CONFIG_AUDITSYSCALL=y
> CONFIG_AUDIT_TREE=y
> CONFIG_IKCONFIG=y
> CONFIG_IKCONFIG_PROC=y
> CONFIG_LOG_BUF_SHIFT=14
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> CONFIG_GROUP_SCHED=y
> CONFIG_FAIR_GROUP_SCHED=y
> CONFIG_RT_GROUP_SCHED=y
> CONFIG_USER_SCHED=y
> # CONFIG_CGROUP_SCHED is not set
>
> #
> # Control Group support
> #
> # CONFIG_CGROUPS is not set
> CONFIG_SYSFS_DEPRECATED=y
> CONFIG_SYSFS_DEPRECATED_V2=y
> # CONFIG_RELAY is not set
> CONFIG_NAMESPACES=y
> CONFIG_UTS_NS=y
> CONFIG_IPC_NS=y
> # CONFIG_USER_NS is not set
> # CONFIG_PID_NS is not set
> CONFIG_BLK_DEV_INITRD=y
> CONFIG_INITRAMFS_SOURCE=""
> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> CONFIG_SYSCTL=y
> CONFIG_EMBEDDED=y
> CONFIG_UID16=y
> CONFIG_SYSCTL_SYSCALL=y
> CONFIG_KALLSYMS=y
> # CONFIG_KALLSYMS_EXTRA_PASS is not set
> CONFIG_HOTPLUG=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> # CONFIG_PCSPKR_PLATFORM is not set
> # CONFIG_COMPAT_BRK is not set
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_ANON_INODES=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_AIO=y
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_SLUB_DEBUG=y
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_SLOB is not set
> # CONFIG_PROFILING is not set
> CONFIG_HAVE_OPROFILE=y
> # CONFIG_KPROBES is not set
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> CONFIG_HAVE_IOREMAP_PROT=y
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> CONFIG_HAVE_ARCH_TRACEHOOK=y
> CONFIG_HAVE_GENERIC_DMA_COHERENT=y
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> CONFIG_BASE_SMALL=0
> CONFIG_MODULES=y
> CONFIG_MODULE_FORCE_LOAD=y
> CONFIG_MODULE_UNLOAD=y
> # CONFIG_MODULE_FORCE_UNLOAD is not set
> CONFIG_MODVERSIONS=y
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> CONFIG_STOP_MACHINE=y
> CONFIG_BLOCK=y
> # CONFIG_LBD is not set
> # CONFIG_BLK_DEV_IO_TRACE is not set
> # CONFIG_BLK_DEV_BSG is not set
> # CONFIG_BLK_DEV_INTEGRITY is not set
>
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=y
> CONFIG_IOSCHED_AS=y
> CONFIG_IOSCHED_DEADLINE=y
> CONFIG_IOSCHED_CFQ=y
> # CONFIG_DEFAULT_AS is not set
> # CONFIG_DEFAULT_DEADLINE is not set
> CONFIG_DEFAULT_CFQ=y
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED="cfq"
> CONFIG_CLASSIC_RCU=y
> # CONFIG_TREE_RCU is not set
> # CONFIG_PREEMPT_RCU is not set
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_PREEMPT_RCU_TRACE is not set
> # CONFIG_FREEZER is not set
>
> #
> # Processor type and features
> #
> CONFIG_TICK_ONESHOT=y
> CONFIG_NO_HZ=y
> CONFIG_HIGH_RES_TIMERS=y
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> CONFIG_SMP=y
> CONFIG_X86_FIND_SMP_CONFIG=y
> CONFIG_X86_MPPARSE=y
> CONFIG_X86_PC=y
> # CONFIG_X86_ELAN is not set
> # CONFIG_X86_VOYAGER is not set
> # CONFIG_X86_GENERICARCH is not set
> # CONFIG_X86_VSMP is not set
> # CONFIG_X86_RDC321X is not set
> # CONFIG_SCHED_OMIT_FRAME_POINTER is not set
> CONFIG_PARAVIRT_GUEST=y
> CONFIG_XEN=y
> CONFIG_XEN_MAX_DOMAIN_MEMORY=24
> # CONFIG_VMI is not set
> # CONFIG_KVM_CLOCK is not set
> # CONFIG_KVM_GUEST is not set
> CONFIG_PARAVIRT=y
> CONFIG_PARAVIRT_CLOCK=y
> # CONFIG_MEMTEST is not set
> # CONFIG_M386 is not set
> # CONFIG_M486 is not set
> # CONFIG_M586 is not set
> # CONFIG_M586TSC is not set
> # CONFIG_M586MMX is not set
> # CONFIG_M686 is not set
> # CONFIG_MPENTIUMII is not set
> # CONFIG_MPENTIUMIII is not set
> # CONFIG_MPENTIUMM is not set
> CONFIG_MPENTIUM4=y
> # CONFIG_MK6 is not set
> # CONFIG_MK7 is not set
> # CONFIG_MK8 is not set
> # CONFIG_MCRUSOE is not set
> # CONFIG_MEFFICEON is not set
> # CONFIG_MWINCHIPC6 is not set
> # CONFIG_MWINCHIP3D is not set
> # CONFIG_MGEODEGX1 is not set
> # CONFIG_MGEODE_LX is not set
> # CONFIG_MCYRIXIII is not set
> # CONFIG_MVIAC3_2 is not set
> # CONFIG_MVIAC7 is not set
> # CONFIG_MPSC is not set
> # CONFIG_MCORE2 is not set
> # CONFIG_GENERIC_CPU is not set
> CONFIG_X86_GENERIC=y
> CONFIG_X86_CPU=y
> CONFIG_X86_CMPXCHG=y
> CONFIG_X86_L1_CACHE_SHIFT=7
> CONFIG_X86_XADD=y
> CONFIG_X86_WP_WORKS_OK=y
> CONFIG_X86_INVLPG=y
> CONFIG_X86_BSWAP=y
> CONFIG_X86_POPAD_OK=y
> CONFIG_X86_INTEL_USERCOPY=y
> CONFIG_X86_USE_PPRO_CHECKSUM=y
> CONFIG_X86_TSC=y
> CONFIG_X86_CMPXCHG64=y
> CONFIG_X86_CMOV=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=4
> CONFIG_X86_DEBUGCTLMSR=y
> CONFIG_PROCESSOR_SELECT=y
> CONFIG_CPU_SUP_INTEL=y
> # CONFIG_CPU_SUP_CYRIX_32 is not set
> CONFIG_CPU_SUP_AMD=y
> # CONFIG_CPU_SUP_CENTAUR_32 is not set
> # CONFIG_CPU_SUP_TRANSMETA_32 is not set
> # CONFIG_CPU_SUP_UMC_32 is not set
> CONFIG_X86_DS=y
> CONFIG_X86_PTRACE_BTS=y
> CONFIG_HPET_TIMER=y
> CONFIG_DMI=y
> # CONFIG_IOMMU_HELPER is not set
> # CONFIG_IOMMU_API is not set
> CONFIG_NR_CPUS=16
> # CONFIG_SCHED_SMT is not set
> CONFIG_SCHED_MC=y
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_X86_LOCAL_APIC=y
> CONFIG_X86_IO_APIC=y
> # CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
> # CONFIG_X86_MCE is not set
> # CONFIG_VM86 is not set
> # CONFIG_TOSHIBA is not set
> # CONFIG_I8K is not set
> # CONFIG_X86_REBOOTFIXUPS is not set
> # CONFIG_MICROCODE is not set
> # CONFIG_X86_MSR is not set
> # CONFIG_X86_CPUID is not set
> # CONFIG_NOHIGHMEM is not set
> # CONFIG_HIGHMEM4G is not set
> CONFIG_HIGHMEM64G=y
> CONFIG_VMSPLIT_3G=y
> # CONFIG_VMSPLIT_3G_OPT is not set
> # CONFIG_VMSPLIT_2G is not set
> # CONFIG_VMSPLIT_2G_OPT is not set
> # CONFIG_VMSPLIT_1G is not set
> CONFIG_PAGE_OFFSET=0xC0000000
> CONFIG_HIGHMEM=y
> CONFIG_X86_PAE=y
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> CONFIG_ARCH_FLATMEM_ENABLE=y
> CONFIG_ARCH_SPARSEMEM_ENABLE=y
> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_FLATMEM_MANUAL=y
> # CONFIG_DISCONTIGMEM_MANUAL is not set
> # CONFIG_SPARSEMEM_MANUAL is not set
> CONFIG_FLATMEM=y
> CONFIG_FLAT_NODE_MEM_MAP=y
> CONFIG_SPARSEMEM_STATIC=y
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_SPLIT_PTLOCK_CPUS=4
> CONFIG_PHYS_ADDR_T_64BIT=y
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> CONFIG_UNEVICTABLE_LRU=y
> # CONFIG_HIGHPTE is not set
> # CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
> # CONFIG_X86_RESERVE_LOW_64K is not set
> # CONFIG_MATH_EMULATION is not set
> # CONFIG_MTRR is not set
> CONFIG_SECCOMP=y
> # CONFIG_HZ_100 is not set
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> CONFIG_HZ_1000=y
> CONFIG_HZ=1000
> CONFIG_SCHED_HRTICK=y
> # CONFIG_KEXEC is not set
> # CONFIG_CRASH_DUMP is not set
> CONFIG_PHYSICAL_START=0x100000
> # CONFIG_RELOCATABLE is not set
> CONFIG_PHYSICAL_ALIGN=0x100000
> # CONFIG_HOTPLUG_CPU is not set
> CONFIG_COMPAT_VDSO=y
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
>
> #
> # Power management and ACPI options
> #
> # CONFIG_PM is not set
>
> #
> # CPU Frequency scaling
> #
> # CONFIG_CPU_FREQ is not set
> # CONFIG_CPU_IDLE is not set
>
> #
> # Bus options (PCI etc.)
> #
> # CONFIG_PCI is not set
> # CONFIG_ARCH_SUPPORTS_MSI is not set
> CONFIG_ISA_DMA_API=y
> # CONFIG_ISA is not set
> # CONFIG_MCA is not set
> # CONFIG_SCx200 is not set
> # CONFIG_OLPC is not set
> # CONFIG_PCCARD is not set
>
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=y
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> CONFIG_HAVE_AOUT=y
> CONFIG_BINFMT_AOUT=y
> CONFIG_BINFMT_MISC=y
> CONFIG_HAVE_ATOMIC_IOMAP=y
> CONFIG_NET=y
>
> #
> # Networking options
> #
> # CONFIG_NET_NS is not set
> CONFIG_COMPAT_NET_DEV_OPS=y
> CONFIG_PACKET=y
> CONFIG_PACKET_MMAP=y
> CONFIG_UNIX=y
> CONFIG_XFRM=y
> CONFIG_XFRM_USER=y
> # CONFIG_XFRM_SUB_POLICY is not set
> # CONFIG_XFRM_MIGRATE is not set
> # CONFIG_XFRM_STATISTICS is not set
> CONFIG_XFRM_IPCOMP=y
> CONFIG_NET_KEY=y
> # CONFIG_NET_KEY_MIGRATE is not set
> CONFIG_INET=y
> CONFIG_IP_MULTICAST=y
> CONFIG_IP_ADVANCED_ROUTER=y
> CONFIG_ASK_IP_FIB_HASH=y
> # CONFIG_IP_FIB_TRIE is not set
> CONFIG_IP_FIB_HASH=y
> CONFIG_IP_MULTIPLE_TABLES=y
> CONFIG_IP_ROUTE_MULTIPATH=y
> CONFIG_IP_ROUTE_VERBOSE=y
> CONFIG_IP_PNP=y
> CONFIG_IP_PNP_DHCP=y
> CONFIG_IP_PNP_BOOTP=y
> CONFIG_IP_PNP_RARP=y
> CONFIG_NET_IPIP=y
> CONFIG_NET_IPGRE=y
> CONFIG_NET_IPGRE_BROADCAST=y
> CONFIG_IP_MROUTE=y
> CONFIG_IP_PIMSM_V1=y
> CONFIG_IP_PIMSM_V2=y
> # CONFIG_ARPD is not set
> CONFIG_SYN_COOKIES=y
> CONFIG_INET_AH=y
> CONFIG_INET_ESP=y
> CONFIG_INET_IPCOMP=y
> CONFIG_INET_XFRM_TUNNEL=y
> CONFIG_INET_TUNNEL=y
> CONFIG_INET_XFRM_MODE_TRANSPORT=y
> CONFIG_INET_XFRM_MODE_TUNNEL=y
> CONFIG_INET_XFRM_MODE_BEET=y
> CONFIG_INET_LRO=y
> CONFIG_INET_DIAG=y
> CONFIG_INET_TCP_DIAG=y
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_DEFAULT_TCP_CONG="cubic"
> # CONFIG_TCP_MD5SIG is not set
> CONFIG_IPV6=y
> CONFIG_IPV6_PRIVACY=y
> # CONFIG_IPV6_ROUTER_PREF is not set
> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
> CONFIG_INET6_AH=y
> CONFIG_INET6_ESP=y
> CONFIG_INET6_IPCOMP=y
> # CONFIG_IPV6_MIP6 is not set
> CONFIG_INET6_XFRM_TUNNEL=y
> CONFIG_INET6_TUNNEL=y
> CONFIG_INET6_XFRM_MODE_TRANSPORT=y
> CONFIG_INET6_XFRM_MODE_TUNNEL=y
> CONFIG_INET6_XFRM_MODE_BEET=y
> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
> CONFIG_IPV6_SIT=y
> CONFIG_IPV6_NDISC_NODETYPE=y
> CONFIG_IPV6_TUNNEL=y
> # CONFIG_IPV6_MULTIPLE_TABLES is not set
> # CONFIG_IPV6_MROUTE is not set
> # CONFIG_NETLABEL is not set
> CONFIG_NETWORK_SECMARK=y
> CONFIG_NETFILTER=y
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=y
> CONFIG_BRIDGE_NETFILTER=y
>
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=y
> CONFIG_NETFILTER_NETLINK_QUEUE=y
> CONFIG_NETFILTER_NETLINK_LOG=y
> CONFIG_NF_CONNTRACK=y
> CONFIG_NF_CT_ACCT=y
> CONFIG_NF_CONNTRACK_MARK=y
> CONFIG_NF_CONNTRACK_SECMARK=y
> # CONFIG_NF_CONNTRACK_EVENTS is not set
> # CONFIG_NF_CT_PROTO_DCCP is not set
> CONFIG_NF_CT_PROTO_GRE=y
> # CONFIG_NF_CT_PROTO_SCTP is not set
> # CONFIG_NF_CT_PROTO_UDPLITE is not set
> # CONFIG_NF_CONNTRACK_AMANDA is not set
> CONFIG_NF_CONNTRACK_FTP=y
> # CONFIG_NF_CONNTRACK_H323 is not set
> CONFIG_NF_CONNTRACK_IRC=y
> # CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
> CONFIG_NF_CONNTRACK_PPTP=y
> # CONFIG_NF_CONNTRACK_SANE is not set
> CONFIG_NF_CONNTRACK_SIP=y
> # CONFIG_NF_CONNTRACK_TFTP is not set
> # CONFIG_NF_CT_NETLINK is not set
> # CONFIG_NETFILTER_TPROXY is not set
> CONFIG_NETFILTER_XTABLES=y
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
> CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
> # CONFIG_NETFILTER_XT_TARGET_DSCP is not set
> CONFIG_NETFILTER_XT_TARGET_MARK=y
> CONFIG_NETFILTER_XT_TARGET_NFLOG=y
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
> CONFIG_NETFILTER_XT_TARGET_RATEEST=y
> CONFIG_NETFILTER_XT_TARGET_TRACE=y
> CONFIG_NETFILTER_XT_TARGET_SECMARK=y
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
> # CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set
> CONFIG_NETFILTER_XT_MATCH_COMMENT=y
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
> # CONFIG_NETFILTER_XT_MATCH_DCCP is not set
> # CONFIG_NETFILTER_XT_MATCH_DSCP is not set
> CONFIG_NETFILTER_XT_MATCH_ESP=y
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
> CONFIG_NETFILTER_XT_MATCH_HELPER=y
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
> CONFIG_NETFILTER_XT_MATCH_LENGTH=y
> CONFIG_NETFILTER_XT_MATCH_LIMIT=y
> CONFIG_NETFILTER_XT_MATCH_MAC=y
> CONFIG_NETFILTER_XT_MATCH_MARK=y
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
> CONFIG_NETFILTER_XT_MATCH_OWNER=y
> CONFIG_NETFILTER_XT_MATCH_POLICY=y
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
> CONFIG_NETFILTER_XT_MATCH_QUOTA=y
> CONFIG_NETFILTER_XT_MATCH_RATEEST=y
> CONFIG_NETFILTER_XT_MATCH_REALM=y
> CONFIG_NETFILTER_XT_MATCH_RECENT=y
> # CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT is not set
> CONFIG_NETFILTER_XT_MATCH_SCTP=y
> CONFIG_NETFILTER_XT_MATCH_STATE=y
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
> CONFIG_NETFILTER_XT_MATCH_STRING=y
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
> CONFIG_NETFILTER_XT_MATCH_TIME=y
> CONFIG_NETFILTER_XT_MATCH_U32=y
> # CONFIG_IP_VS is not set
>
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=y
> CONFIG_NF_CONNTRACK_IPV4=y
> CONFIG_NF_CONNTRACK_PROC_COMPAT=y
> CONFIG_IP_NF_QUEUE=y
> CONFIG_IP_NF_IPTABLES=y
> CONFIG_IP_NF_MATCH_ADDRTYPE=y
> CONFIG_IP_NF_MATCH_AH=y
> CONFIG_IP_NF_MATCH_ECN=y
> CONFIG_IP_NF_MATCH_TTL=y
> CONFIG_IP_NF_FILTER=y
> CONFIG_IP_NF_TARGET_REJECT=y
> CONFIG_IP_NF_TARGET_LOG=y
> CONFIG_IP_NF_TARGET_ULOG=y
> CONFIG_NF_NAT=y
> CONFIG_NF_NAT_NEEDED=y
> CONFIG_IP_NF_TARGET_MASQUERADE=y
> # CONFIG_IP_NF_TARGET_NETMAP is not set
> CONFIG_IP_NF_TARGET_REDIRECT=y
> # CONFIG_NF_NAT_SNMP_BASIC is not set
> CONFIG_NF_NAT_PROTO_GRE=y
> CONFIG_NF_NAT_FTP=y
> CONFIG_NF_NAT_IRC=y
> # CONFIG_NF_NAT_TFTP is not set
> # CONFIG_NF_NAT_AMANDA is not set
> CONFIG_NF_NAT_PPTP=y
> # CONFIG_NF_NAT_H323 is not set
> CONFIG_NF_NAT_SIP=y
> CONFIG_IP_NF_MANGLE=y
> # CONFIG_IP_NF_TARGET_CLUSTERIP is not set
> CONFIG_IP_NF_TARGET_ECN=y
> CONFIG_IP_NF_TARGET_TTL=y
> CONFIG_IP_NF_RAW=y
> CONFIG_IP_NF_SECURITY=y
> # CONFIG_IP_NF_ARPTABLES is not set
>
> #
> # IPv6: Netfilter Configuration
> #
> CONFIG_NF_CONNTRACK_IPV6=y
> CONFIG_IP6_NF_QUEUE=y
> CONFIG_IP6_NF_IPTABLES=y
> CONFIG_IP6_NF_MATCH_AH=y
> CONFIG_IP6_NF_MATCH_EUI64=y
> CONFIG_IP6_NF_MATCH_FRAG=y
> CONFIG_IP6_NF_MATCH_OPTS=y
> CONFIG_IP6_NF_MATCH_HL=y
> CONFIG_IP6_NF_MATCH_IPV6HEADER=y
> # CONFIG_IP6_NF_MATCH_MH is not set
> CONFIG_IP6_NF_MATCH_RT=y
> CONFIG_IP6_NF_TARGET_LOG=y
> CONFIG_IP6_NF_FILTER=y
> CONFIG_IP6_NF_TARGET_REJECT=y
> CONFIG_IP6_NF_MANGLE=y
> CONFIG_IP6_NF_TARGET_HL=y
> CONFIG_IP6_NF_RAW=y
> CONFIG_IP6_NF_SECURITY=y
> CONFIG_BRIDGE_NF_EBTABLES=y
> CONFIG_BRIDGE_EBT_BROUTE=y
> CONFIG_BRIDGE_EBT_T_FILTER=y
> CONFIG_BRIDGE_EBT_T_NAT=y
> CONFIG_BRIDGE_EBT_802_3=y
> CONFIG_BRIDGE_EBT_AMONG=y
> CONFIG_BRIDGE_EBT_ARP=y
> CONFIG_BRIDGE_EBT_IP=y
> CONFIG_BRIDGE_EBT_IP6=y
> CONFIG_BRIDGE_EBT_LIMIT=y
> CONFIG_BRIDGE_EBT_MARK=y
> CONFIG_BRIDGE_EBT_PKTTYPE=y
> CONFIG_BRIDGE_EBT_STP=y
> CONFIG_BRIDGE_EBT_VLAN=y
> CONFIG_BRIDGE_EBT_ARPREPLY=y
> CONFIG_BRIDGE_EBT_DNAT=y
> CONFIG_BRIDGE_EBT_MARK_T=y
> CONFIG_BRIDGE_EBT_REDIRECT=y
> CONFIG_BRIDGE_EBT_SNAT=y
> CONFIG_BRIDGE_EBT_LOG=y
> CONFIG_BRIDGE_EBT_ULOG=y
> CONFIG_BRIDGE_EBT_NFLOG=y
> # CONFIG_IP_DCCP is not set
> CONFIG_IP_SCTP=y
> # CONFIG_SCTP_DBG_MSG is not set
> # CONFIG_SCTP_DBG_OBJCNT is not set
> # CONFIG_SCTP_HMAC_NONE is not set
> # CONFIG_SCTP_HMAC_SHA1 is not set
> CONFIG_SCTP_HMAC_MD5=y
> # CONFIG_TIPC is not set
> # CONFIG_ATM is not set
> CONFIG_STP=y
> CONFIG_BRIDGE=y
> # CONFIG_NET_DSA is not set
> CONFIG_VLAN_8021Q=y
> # CONFIG_VLAN_8021Q_GVRP is not set
> # CONFIG_DECNET is not set
> CONFIG_LLC=y
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_ECONET is not set
> # CONFIG_WAN_ROUTER is not set
> CONFIG_NET_SCHED=y
>
> #
> # Queueing/Scheduling
> #
> CONFIG_NET_SCH_CBQ=y
> CONFIG_NET_SCH_HTB=y
> CONFIG_NET_SCH_HFSC=y
> CONFIG_NET_SCH_PRIO=y
> # CONFIG_NET_SCH_MULTIQ is not set
> CONFIG_NET_SCH_RED=y
> CONFIG_NET_SCH_SFQ=y
> CONFIG_NET_SCH_TEQL=y
> CONFIG_NET_SCH_TBF=y
> CONFIG_NET_SCH_GRED=y
> CONFIG_NET_SCH_DSMARK=y
> # CONFIG_NET_SCH_NETEM is not set
> # CONFIG_NET_SCH_DRR is not set
> CONFIG_NET_SCH_INGRESS=y
>
> #
> # Classification
> #
> CONFIG_NET_CLS=y
> CONFIG_NET_CLS_BASIC=y
> CONFIG_NET_CLS_TCINDEX=y
> CONFIG_NET_CLS_ROUTE4=y
> CONFIG_NET_CLS_ROUTE=y
> CONFIG_NET_CLS_FW=y
> CONFIG_NET_CLS_U32=y
> CONFIG_CLS_U32_PERF=y
> CONFIG_CLS_U32_MARK=y
> CONFIG_NET_CLS_RSVP=y
> CONFIG_NET_CLS_RSVP6=y
> CONFIG_NET_CLS_FLOW=y
> CONFIG_NET_EMATCH=y
> CONFIG_NET_EMATCH_STACK=32
> CONFIG_NET_EMATCH_CMP=y
> CONFIG_NET_EMATCH_NBYTE=y
> CONFIG_NET_EMATCH_U32=y
> CONFIG_NET_EMATCH_META=y
> # CONFIG_NET_EMATCH_TEXT is not set
> CONFIG_NET_CLS_ACT=y
> CONFIG_NET_ACT_POLICE=y
> CONFIG_NET_ACT_GACT=y
> # CONFIG_GACT_PROB is not set
> # CONFIG_NET_ACT_MIRRED is not set
> CONFIG_NET_ACT_IPT=y
> CONFIG_NET_ACT_NAT=y
> # CONFIG_NET_ACT_PEDIT is not set
> # CONFIG_NET_ACT_SIMP is not set
> CONFIG_NET_ACT_SKBEDIT=y
> # CONFIG_NET_CLS_IND is not set
> CONFIG_NET_SCH_FIFO=y
> # CONFIG_DCB is not set
>
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> # CONFIG_AF_RXRPC is not set
> # CONFIG_PHONET is not set
> CONFIG_FIB_RULES=y
> # CONFIG_WIRELESS is not set
> # CONFIG_WIMAX is not set
> # CONFIG_RFKILL is not set
> # CONFIG_NET_9P is not set
>
> #
> # Device Drivers
> #
>
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> CONFIG_STANDALONE=y
> CONFIG_PREVENT_FIRMWARE_BUILD=y
> # CONFIG_FW_LOADER is not set
> # CONFIG_SYS_HYPERVISOR is not set
> CONFIG_CONNECTOR=y
> CONFIG_PROC_EVENTS=y
> # CONFIG_MTD is not set
> # CONFIG_PARPORT is not set
> CONFIG_BLK_DEV=y
> # CONFIG_BLK_DEV_FD is not set
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=y
> CONFIG_BLK_DEV_CRYPTOLOOP=y
> CONFIG_BLK_DEV_NBD=y
> CONFIG_BLK_DEV_RAM=y
> CONFIG_BLK_DEV_RAM_COUNT=16
> CONFIG_BLK_DEV_RAM_SIZE=4096
> # CONFIG_BLK_DEV_XIP is not set
> # CONFIG_CDROM_PKTCDVD is not set
> # CONFIG_ATA_OVER_ETH is not set
> CONFIG_XEN_BLKDEV_FRONTEND=y
> # CONFIG_BLK_DEV_HD is not set
> # CONFIG_MISC_DEVICES is not set
> CONFIG_HAVE_IDE=y
> # CONFIG_IDE is not set
>
> #
> # SCSI device support
> #
> CONFIG_RAID_ATTRS=y
> # CONFIG_SCSI is not set
> # CONFIG_SCSI_DMA is not set
> # CONFIG_SCSI_NETLINK is not set
> # CONFIG_ATA is not set
> CONFIG_MD=y
> CONFIG_BLK_DEV_MD=y
> CONFIG_MD_AUTODETECT=y
> CONFIG_MD_LINEAR=y
> CONFIG_MD_RAID0=y
> CONFIG_MD_RAID1=y
> # CONFIG_MD_RAID10 is not set
> CONFIG_MD_RAID456=y
> # CONFIG_MD_RAID5_RESHAPE is not set
> CONFIG_MD_MULTIPATH=y
> # CONFIG_MD_FAULTY is not set
> CONFIG_BLK_DEV_DM=y
> # CONFIG_DM_DEBUG is not set
> CONFIG_DM_CRYPT=y
> CONFIG_DM_SNAPSHOT=y
> CONFIG_DM_MIRROR=y
> # CONFIG_DM_ZERO is not set
> # CONFIG_DM_MULTIPATH is not set
> # CONFIG_DM_DELAY is not set
> # CONFIG_DM_UEVENT is not set
> # CONFIG_MACINTOSH_DRIVERS is not set
> CONFIG_NETDEVICES=y
> # CONFIG_IFB is not set
> CONFIG_DUMMY=y
> # CONFIG_BONDING is not set
> # CONFIG_MACVLAN is not set
> # CONFIG_EQUALIZER is not set
> CONFIG_TUN=y
> # CONFIG_VETH is not set
> # CONFIG_NET_ETHERNET is not set
> CONFIG_NETDEV_1000=y
> CONFIG_NETDEV_10000=y
>
> #
> # Wireless LAN
> #
> # CONFIG_WLAN_PRE80211 is not set
> # CONFIG_WLAN_80211 is not set
> # CONFIG_IWLWIFI_LEDS is not set
>
> #
> # Enable WiMAX (Networking options) to see the WiMAX drivers
> #
> # CONFIG_WAN is not set
> CONFIG_XEN_NETDEV_FRONTEND=y
> CONFIG_PPP=y
> # CONFIG_PPP_MULTILINK is not set
> CONFIG_PPP_FILTER=y
> CONFIG_PPP_ASYNC=y
> CONFIG_PPP_SYNC_TTY=y
> CONFIG_PPP_DEFLATE=y
> CONFIG_PPP_BSDCOMP=y
> CONFIG_PPP_MPPE=y
> # CONFIG_PPPOE is not set
> # CONFIG_PPPOL2TP is not set
> CONFIG_SLIP=y
> CONFIG_SLIP_COMPRESSED=y
> CONFIG_SLHC=y
> CONFIG_SLIP_SMART=y
> CONFIG_SLIP_MODE_SLIP6=y
> # CONFIG_NETCONSOLE is not set
> # CONFIG_NETPOLL is not set
> # CONFIG_NET_POLL_CONTROLLER is not set
> # CONFIG_ISDN is not set
> # CONFIG_PHONE is not set
>
> #
> # Input device support
> #
> CONFIG_INPUT=y
> # CONFIG_INPUT_FF_MEMLESS is not set
> # CONFIG_INPUT_POLLDEV is not set
>
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=y
> CONFIG_INPUT_MOUSEDEV_PSAUX=y
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> # CONFIG_INPUT_JOYDEV is not set
> # CONFIG_INPUT_EVDEV is not set
> # CONFIG_INPUT_EVBUG is not set
>
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=y
> CONFIG_KEYBOARD_ATKBD=y
> # CONFIG_KEYBOARD_SUNKBD is not set
> # CONFIG_KEYBOARD_LKKBD is not set
> # CONFIG_KEYBOARD_XTKBD is not set
> # CONFIG_KEYBOARD_NEWTON is not set
> # CONFIG_KEYBOARD_STOWAWAY is not set
> CONFIG_INPUT_MOUSE=y
> CONFIG_MOUSE_PS2=y
> CONFIG_MOUSE_PS2_ALPS=y
> CONFIG_MOUSE_PS2_LOGIPS2PP=y
> CONFIG_MOUSE_PS2_SYNAPTICS=y
> CONFIG_MOUSE_PS2_LIFEBOOK=y
> CONFIG_MOUSE_PS2_TRACKPOINT=y
> # CONFIG_MOUSE_PS2_ELANTECH is not set
> # CONFIG_MOUSE_PS2_TOUCHKIT is not set
> # CONFIG_MOUSE_SERIAL is not set
> # CONFIG_MOUSE_VSXXXAA is not set
> # CONFIG_INPUT_JOYSTICK is not set
> # CONFIG_INPUT_TABLET is not set
> # CONFIG_INPUT_TOUCHSCREEN is not set
> # CONFIG_INPUT_MISC is not set
>
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> CONFIG_SERIO_SERPORT=y
> # CONFIG_SERIO_CT82C710 is not set
> CONFIG_SERIO_LIBPS2=y
> # CONFIG_SERIO_RAW is not set
> # CONFIG_GAMEPORT is not set
>
> #
> # Character devices
> #
> CONFIG_VT=y
> CONFIG_CONSOLE_TRANSLATIONS=y
> CONFIG_VT_CONSOLE=y
> CONFIG_HW_CONSOLE=y
> # CONFIG_VT_HW_CONSOLE_BINDING is not set
> # CONFIG_DEVKMEM is not set
> # CONFIG_SERIAL_NONSTANDARD is not set
>
> #
> # Serial drivers
> #
> # CONFIG_SERIAL_8250 is not set
> CONFIG_FIX_EARLYCON_MEM=y
>
> #
> # Non-8250 serial port support
> #
> CONFIG_UNIX98_PTYS=y
> # CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
> CONFIG_LEGACY_PTYS=y
> CONFIG_LEGACY_PTY_COUNT=256
> CONFIG_HVC_DRIVER=y
> CONFIG_HVC_IRQ=y
> CONFIG_HVC_XEN=y
> # CONFIG_IPMI_HANDLER is not set
> # CONFIG_HW_RANDOM is not set
> # CONFIG_NVRAM is not set
> # CONFIG_R3964 is not set
> # CONFIG_MWAVE is not set
> # CONFIG_PC8736x_GPIO is not set
> # CONFIG_NSC_GPIO is not set
> # CONFIG_CS5535_GPIO is not set
> # CONFIG_RAW_DRIVER is not set
> # CONFIG_HANGCHECK_TIMER is not set
> # CONFIG_TCG_TPM is not set
> # CONFIG_TELCLOCK is not set
> # CONFIG_I2C is not set
> # CONFIG_SPI is not set
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
> # CONFIG_GPIOLIB is not set
> # CONFIG_W1 is not set
> # CONFIG_POWER_SUPPLY is not set
> # CONFIG_HWMON is not set
> # CONFIG_THERMAL is not set
> # CONFIG_THERMAL_HWMON is not set
> # CONFIG_WATCHDOG is not set
> CONFIG_SSB_POSSIBLE=y
>
> #
> # Sonics Silicon Backplane
> #
> # CONFIG_SSB is not set
>
> #
> # Multifunction device drivers
> #
> # CONFIG_MFD_CORE is not set
> # CONFIG_MFD_SM501 is not set
> # CONFIG_HTC_PASIC3 is not set
> # CONFIG_MFD_TMIO is not set
> # CONFIG_REGULATOR is not set
>
> #
> # Multimedia devices
> #
>
> #
> # Multimedia core support
> #
> # CONFIG_VIDEO_DEV is not set
> # CONFIG_DVB_CORE is not set
> # CONFIG_VIDEO_MEDIA is not set
>
> #
> # Multimedia drivers
> #
> # CONFIG_DAB is not set
>
> #
> # Graphics support
> #
> # CONFIG_VGASTATE is not set
> # CONFIG_VIDEO_OUTPUT_CONTROL is not set
> # CONFIG_FB is not set
> # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
>
> #
> # Display device support
> #
> # CONFIG_DISPLAY_SUPPORT is not set
>
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=y
> # CONFIG_VGACON_SOFT_SCROLLBACK is not set
> CONFIG_DUMMY_CONSOLE=y
> # CONFIG_SOUND is not set
> # CONFIG_HID_SUPPORT is not set
> # CONFIG_USB_SUPPORT is not set
> # CONFIG_MMC is not set
> # CONFIG_MEMSTICK is not set
> # CONFIG_NEW_LEDS is not set
> # CONFIG_ACCESSIBILITY is not set
> # CONFIG_EDAC is not set
> CONFIG_RTC_LIB=y
> CONFIG_RTC_CLASS=y
> # CONFIG_RTC_HCTOSYS is not set
> # CONFIG_RTC_DEBUG is not set
>
> #
> # RTC interfaces
> #
> # CONFIG_RTC_INTF_SYSFS is not set
> # CONFIG_RTC_INTF_PROC is not set
> # CONFIG_RTC_INTF_DEV is not set
> # CONFIG_RTC_DRV_TEST is not set
>
> #
> # SPI RTC drivers
> #
>
> #
> # Platform RTC drivers
> #
> # CONFIG_RTC_DRV_CMOS is not set
> # CONFIG_RTC_DRV_DS1286 is not set
> # CONFIG_RTC_DRV_DS1511 is not set
> # CONFIG_RTC_DRV_DS1553 is not set
> # CONFIG_RTC_DRV_DS1742 is not set
> # CONFIG_RTC_DRV_STK17TA8 is not set
> # CONFIG_RTC_DRV_M48T86 is not set
> # CONFIG_RTC_DRV_M48T35 is not set
> # CONFIG_RTC_DRV_M48T59 is not set
> # CONFIG_RTC_DRV_BQ4802 is not set
> # CONFIG_RTC_DRV_V3020 is not set
>
> #
> # on-CPU RTC drivers
> #
> CONFIG_UIO=y
> CONFIG_UIO_PDRV=y
> CONFIG_UIO_PDRV_GENIRQ=y
> # CONFIG_UIO_SMX is not set
> # CONFIG_UIO_SERCOS3 is not set
> # CONFIG_XEN_BALLOON is not set
> CONFIG_XENFS=y
> CONFIG_XEN_COMPAT_XENFS=y
> # CONFIG_STAGING is not set
> CONFIG_X86_PLATFORM_DEVICES=y
>
> #
> # Firmware Drivers
> #
> # CONFIG_EDD is not set
> # CONFIG_FIRMWARE_MEMMAP is not set
> # CONFIG_DELL_RBU is not set
> # CONFIG_DCDBAS is not set
> CONFIG_DMIID=y
> # CONFIG_ISCSI_IBFT_FIND is not set
>
> #
> # File systems
> #
> CONFIG_EXT2_FS=y
> CONFIG_EXT2_FS_XATTR=y
> CONFIG_EXT2_FS_POSIX_ACL=y
> CONFIG_EXT2_FS_SECURITY=y
> # CONFIG_EXT2_FS_XIP is not set
> CONFIG_EXT3_FS=y
> CONFIG_EXT3_FS_XATTR=y
> CONFIG_EXT3_FS_POSIX_ACL=y
> CONFIG_EXT3_FS_SECURITY=y
> CONFIG_EXT4_FS=y
> # CONFIG_EXT4DEV_COMPAT is not set
> CONFIG_EXT4_FS_XATTR=y
> CONFIG_EXT4_FS_POSIX_ACL=y
> CONFIG_EXT4_FS_SECURITY=y
> CONFIG_JBD=y
> CONFIG_JBD2=y
> CONFIG_FS_MBCACHE=y
> CONFIG_REISERFS_FS=y
> # CONFIG_REISERFS_CHECK is not set
> CONFIG_REISERFS_PROC_INFO=y
> CONFIG_REISERFS_FS_XATTR=y
> CONFIG_REISERFS_FS_POSIX_ACL=y
> CONFIG_REISERFS_FS_SECURITY=y
> CONFIG_JFS_FS=y
> CONFIG_JFS_POSIX_ACL=y
> CONFIG_JFS_SECURITY=y
> # CONFIG_JFS_DEBUG is not set
> CONFIG_JFS_STATISTICS=y
> CONFIG_FS_POSIX_ACL=y
> CONFIG_FILE_LOCKING=y
> CONFIG_XFS_FS=y
> CONFIG_XFS_QUOTA=y
> CONFIG_XFS_POSIX_ACL=y
> # CONFIG_XFS_RT is not set
> # CONFIG_XFS_DEBUG is not set
> # CONFIG_OCFS2_FS is not set
> CONFIG_BTRFS_FS=y
> CONFIG_DNOTIFY=y
> CONFIG_INOTIFY=y
> CONFIG_INOTIFY_USER=y
> CONFIG_QUOTA=y
> CONFIG_QUOTA_NETLINK_INTERFACE=y
> CONFIG_PRINT_QUOTA_WARNING=y
> CONFIG_QUOTA_TREE=y
> CONFIG_QFMT_V1=y
> CONFIG_QFMT_V2=y
> CONFIG_QUOTACTL=y
> CONFIG_AUTOFS_FS=y
> CONFIG_AUTOFS4_FS=y
> CONFIG_FUSE_FS=y
>
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=y
> CONFIG_JOLIET=y
> CONFIG_ZISOFS=y
> CONFIG_UDF_FS=y
> CONFIG_UDF_NLS=y
>
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=y
> CONFIG_MSDOS_FS=y
> CONFIG_VFAT_FS=y
> CONFIG_FAT_DEFAULT_CODEPAGE=437
> CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
> # CONFIG_NTFS_FS is not set
>
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=y
> CONFIG_PROC_KCORE=y
> CONFIG_PROC_SYSCTL=y
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SYSFS=y
> CONFIG_TMPFS=y
> # CONFIG_TMPFS_POSIX_ACL is not set
> # CONFIG_HUGETLBFS is not set
> # CONFIG_HUGETLB_PAGE is not set
> CONFIG_CONFIGFS_FS=y
> CONFIG_MISC_FILESYSTEMS=y
> # CONFIG_ADFS_FS is not set
> # CONFIG_AFFS_FS is not set
> CONFIG_ECRYPT_FS=y
> # CONFIG_HFS_FS is not set
> # CONFIG_HFSPLUS_FS is not set
> # CONFIG_BEFS_FS is not set
> # CONFIG_BFS_FS is not set
> # CONFIG_EFS_FS is not set
> CONFIG_CRAMFS=y
> CONFIG_SQUASHFS=y
> # CONFIG_SQUASHFS_EMBEDDED is not set
> CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
> # CONFIG_VXFS_FS is not set
> CONFIG_MINIX_FS=y
> # CONFIG_OMFS_FS is not set
> # CONFIG_HPFS_FS is not set
> # CONFIG_QNX4FS_FS is not set
> CONFIG_ROMFS_FS=y
> # CONFIG_SYSV_FS is not set
> # CONFIG_UFS_FS is not set
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> # CONFIG_NFS_V4 is not set
> # CONFIG_ROOT_NFS is not set
> CONFIG_NFSD=y
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> # CONFIG_NFSD_V4 is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_EXPORTFS=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> # CONFIG_SUNRPC_REGISTER_V4 is not set
> # CONFIG_RPCSEC_GSS_KRB5 is not set
> # CONFIG_RPCSEC_GSS_SPKM3 is not set
> CONFIG_SMB_FS=y
> CONFIG_SMB_NLS_DEFAULT=y
> CONFIG_SMB_NLS_REMOTE="cp437"
> # CONFIG_CIFS is not set
> # CONFIG_NCP_FS is not set
> # CONFIG_CODA_FS is not set
> # CONFIG_AFS_FS is not set
>
> #
> # Partition Types
> #
> # CONFIG_PARTITION_ADVANCED is not set
> CONFIG_MSDOS_PARTITION=y
> CONFIG_NLS=y
> CONFIG_NLS_DEFAULT="iso8859-1"
> CONFIG_NLS_CODEPAGE_437=y
> # CONFIG_NLS_CODEPAGE_737 is not set
> # CONFIG_NLS_CODEPAGE_775 is not set
> CONFIG_NLS_CODEPAGE_850=y
> # CONFIG_NLS_CODEPAGE_852 is not set
> # CONFIG_NLS_CODEPAGE_855 is not set
> # CONFIG_NLS_CODEPAGE_857 is not set
> # CONFIG_NLS_CODEPAGE_860 is not set
> # CONFIG_NLS_CODEPAGE_861 is not set
> # CONFIG_NLS_CODEPAGE_862 is not set
> # CONFIG_NLS_CODEPAGE_863 is not set
> # CONFIG_NLS_CODEPAGE_864 is not set
> # CONFIG_NLS_CODEPAGE_865 is not set
> # CONFIG_NLS_CODEPAGE_866 is not set
> # CONFIG_NLS_CODEPAGE_869 is not set
> # CONFIG_NLS_CODEPAGE_936 is not set
> # CONFIG_NLS_CODEPAGE_950 is not set
> # CONFIG_NLS_CODEPAGE_932 is not set
> # CONFIG_NLS_CODEPAGE_949 is not set
> # CONFIG_NLS_CODEPAGE_874 is not set
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> # CONFIG_NLS_CODEPAGE_1251 is not set
> CONFIG_NLS_ASCII=y
> CONFIG_NLS_ISO8859_1=y
> # CONFIG_NLS_ISO8859_2 is not set
> # CONFIG_NLS_ISO8859_3 is not set
> # CONFIG_NLS_ISO8859_4 is not set
> # CONFIG_NLS_ISO8859_5 is not set
> # CONFIG_NLS_ISO8859_6 is not set
> # CONFIG_NLS_ISO8859_7 is not set
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> # CONFIG_NLS_ISO8859_14 is not set
> # CONFIG_NLS_ISO8859_15 is not set
> CONFIG_NLS_KOI8_R=y
> # CONFIG_NLS_KOI8_U is not set
> CONFIG_NLS_UTF8=y
> CONFIG_DLM=y
> # CONFIG_DLM_DEBUG is not set
>
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> # CONFIG_PRINTK_TIME is not set
> CONFIG_ENABLE_WARN_DEPRECATED=y
> # CONFIG_ENABLE_MUST_CHECK is not set
> CONFIG_FRAME_WARN=1024
> CONFIG_MAGIC_SYSRQ=y
> # CONFIG_UNUSED_SYMBOLS is not set
> # CONFIG_DEBUG_FS is not set
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_KERNEL is not set
> # CONFIG_SLUB_DEBUG_ON is not set
> CONFIG_SLUB_STATS=y
> # CONFIG_DEBUG_BUGVERBOSE is not set
> CONFIG_DEBUG_MEMORY_INIT=y
> # CONFIG_RCU_CPU_STALL_DETECTOR is not set
> # CONFIG_LATENCYTOP is not set
> CONFIG_SYSCTL_SYSCALL_CHECK=y
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_HW_BRANCH_TRACER=y
>
> #
> # Tracers
> #
> # CONFIG_SYSPROF_TRACER is not set
> # CONFIG_HW_BRANCH_TRACER is not set
> # CONFIG_DYNAMIC_PRINTK_DEBUG is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=y
> CONFIG_STRICT_DEVMEM=y
> CONFIG_X86_VERBOSE_BOOTUP=y
> CONFIG_EARLY_PRINTK=y
> # CONFIG_4KSTACKS is not set
> CONFIG_DOUBLEFAULT=y
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> CONFIG_IO_DELAY_0X80=y
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=0
> # CONFIG_OPTIMIZE_INLINING is not set
>
> #
> # Security options
> #
> CONFIG_KEYS=y
> # CONFIG_KEYS_DEBUG_PROC_KEYS is not set
> CONFIG_SECURITY=y
> # CONFIG_SECURITYFS is not set
> CONFIG_SECURITY_NETWORK=y
> CONFIG_SECURITY_NETWORK_XFRM=y
> # CONFIG_SECURITY_PATH is not set
> # CONFIG_SECURITY_FILE_CAPABILITIES is not set
> CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
> # CONFIG_SECURITY_SELINUX is not set
> CONFIG_XOR_BLOCKS=y
> CONFIG_ASYNC_CORE=y
> CONFIG_ASYNC_MEMCPY=y
> CONFIG_ASYNC_XOR=y
> CONFIG_CRYPTO=y
>
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_FIPS=y
> CONFIG_CRYPTO_ALGAPI=y
> CONFIG_CRYPTO_ALGAPI2=y
> CONFIG_CRYPTO_AEAD=y
> CONFIG_CRYPTO_AEAD2=y
> CONFIG_CRYPTO_BLKCIPHER=y
> CONFIG_CRYPTO_BLKCIPHER2=y
> CONFIG_CRYPTO_HASH=y
> CONFIG_CRYPTO_HASH2=y
> CONFIG_CRYPTO_RNG=y
> CONFIG_CRYPTO_RNG2=y
> CONFIG_CRYPTO_MANAGER=y
> CONFIG_CRYPTO_MANAGER2=y
> CONFIG_CRYPTO_GF128MUL=y
> CONFIG_CRYPTO_NULL=y
> # CONFIG_CRYPTO_CRYPTD is not set
> CONFIG_CRYPTO_AUTHENC=y
> # CONFIG_CRYPTO_TEST is not set
>
> #
> # Authenticated Encryption with Associated Data
> #
> CONFIG_CRYPTO_CCM=y
> CONFIG_CRYPTO_GCM=y
> CONFIG_CRYPTO_SEQIV=y
>
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=y
> CONFIG_CRYPTO_CTR=y
> CONFIG_CRYPTO_CTS=y
> CONFIG_CRYPTO_ECB=y
> CONFIG_CRYPTO_LRW=y
> CONFIG_CRYPTO_PCBC=y
> # CONFIG_CRYPTO_XTS is not set
>
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=y
> CONFIG_CRYPTO_XCBC=y
>
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=y
> CONFIG_CRYPTO_CRC32C_INTEL=y
> CONFIG_CRYPTO_MD4=y
> CONFIG_CRYPTO_MD5=y
> CONFIG_CRYPTO_MICHAEL_MIC=y
> CONFIG_CRYPTO_RMD128=y
> CONFIG_CRYPTO_RMD160=y
> CONFIG_CRYPTO_RMD256=y
> CONFIG_CRYPTO_RMD320=y
> CONFIG_CRYPTO_SHA1=y
> CONFIG_CRYPTO_SHA256=y
> CONFIG_CRYPTO_SHA512=y
> CONFIG_CRYPTO_TGR192=y
> CONFIG_CRYPTO_WP512=y
>
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=y
> # CONFIG_CRYPTO_AES_586 is not set
> CONFIG_CRYPTO_ANUBIS=y
> CONFIG_CRYPTO_ARC4=y
> CONFIG_CRYPTO_BLOWFISH=y
> CONFIG_CRYPTO_CAMELLIA=y
> CONFIG_CRYPTO_CAST5=y
> CONFIG_CRYPTO_CAST6=y
> CONFIG_CRYPTO_DES=y
> CONFIG_CRYPTO_FCRYPT=y
> CONFIG_CRYPTO_KHAZAD=y
> # CONFIG_CRYPTO_SALSA20 is not set
> # CONFIG_CRYPTO_SALSA20_586 is not set
> CONFIG_CRYPTO_SEED=y
> CONFIG_CRYPTO_SERPENT=y
> CONFIG_CRYPTO_TEA=y
> CONFIG_CRYPTO_TWOFISH=y
> CONFIG_CRYPTO_TWOFISH_COMMON=y
> CONFIG_CRYPTO_TWOFISH_586=y
>
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=y
> CONFIG_CRYPTO_LZO=y
>
> #
> # Random Number Generation
> #
> CONFIG_CRYPTO_ANSI_CPRNG=y
> CONFIG_CRYPTO_HW=y
> CONFIG_CRYPTO_DEV_PADLOCK=y
> CONFIG_CRYPTO_DEV_PADLOCK_AES=y
> CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
> CONFIG_HAVE_KVM=y
> CONFIG_VIRTUALIZATION=y
> # CONFIG_VIRTIO_BALLOON is not set
>
> #
> # Library routines
> #
> CONFIG_BITREVERSE=y
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_FIND_NEXT_BIT=y
> CONFIG_GENERIC_FIND_LAST_BIT=y
> CONFIG_CRC_CCITT=y
> CONFIG_CRC16=y
> CONFIG_CRC_T10DIF=y
> CONFIG_CRC_ITU_T=y
> CONFIG_CRC32=y
> CONFIG_CRC7=y
> CONFIG_LIBCRC32C=y
> CONFIG_AUDIT_GENERIC=y
> CONFIG_ZLIB_INFLATE=y
> CONFIG_ZLIB_DEFLATE=y
> CONFIG_LZO_COMPRESS=y
> CONFIG_LZO_DECOMPRESS=y
> CONFIG_TEXTSEARCH=y
> CONFIG_TEXTSEARCH_KMP=y
> CONFIG_TEXTSEARCH_BM=y
> CONFIG_TEXTSEARCH_FSM=y
> CONFIG_PLIST=y
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
