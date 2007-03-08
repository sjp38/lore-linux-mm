Date: Thu, 8 Mar 2007 10:54:59 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Christoph Lameter wrote:

> [PATCH] SLUB The unqueued slab allocator v4
>

Hi Christoph,

I shoved these patches through a few tests on x86, x86_64, ia64 and ppc64 
last night to see how they got on. I enabled slub_debug to catch any 
suprises that may be creeping about.

The results are mixed.

On x86_64, it completed successfully and looked reliable. There was a 5% 
performance loss on kernbench and aim9 figures were way down. However, 
with slub_debug enabled, I would expect that so it's not a fair comparison 
performance wise. I'll rerun the tests without debug and see what it looks 
like if you're interested and do not think it's too early to worry about 
performance instead of clarity. This is what I have for bl6-13 (machine 
appears on test.kernel.org so additional details are there).

KernBench Comparison
--------------------
                           2.6.21-rc2-mm2-clean 2.6.21-rc2-mm2-list-based 
%diff
User   CPU time                          84.32                     86.03     -2.03%
System CPU time                          32.97                     38.21    -15.89%
Total  CPU time                         117.29                    124.24     -5.93%
Elapsed    time                          34.95                     37.31     -6.75%

AIM9 Comparison
---------------
                  2.6.21-rc2-mm2-clean  2.6.21-rc2-mm2-list-based
  1 creat-clo                160706.55                   62918.54  -97788.01 -60.85% File Creations and Closes/second
  2 page_test                190371.67                  204050.99   13679.32  7.19% System Allocations & Pages/second
  3 brk_test                2320679.89                 1923512.75 -397167.14 -17.11% System Memory Allocations/second
  4 jmp_test               16391869.38                16380353.27  -11516.11 -0.07% Non-local gotos/second
  5 signal_test              492234.63                  235710.71 -256523.92 -52.11% Signal Traps/second
  6 exec_test                   232.26                     220.88     -11.38 -4.90% Program Loads/second
  7 fork_test                  4514.25                    3609.40    -904.85 -20.04% Task Creations/second
  8 link_test                 53639.76                   26925.91 -26713.85  -49.80% Link/Unlink Pairs/second


IA64 (machine not visible on TKO) curiously did not exhibit the same 
problems on kernbench for Total CPU time which is very unexpected but you 
can see the System CPU times. The AIM9 figures were a bit of an upset but 
again, I blame slub_debug being enabled

KernBench Comparison
--------------------
                           2.6.21-rc2-mm2-clean 2.6.21-rc2-mm2-list-based      %diff
User   CPU time                        1084.64                   1033.46      4.72%
System CPU time                          73.38                     84.14    -14.66%
Total  CPU time                        1158.02                    1117.6      3.49%
Elapsed    time                         307.00                    291.29      5.12%

AIM9 Comparison
---------------
                  2.6.21-rc2-mm2-clean  2.6.21-rc2-mm2-list-based
  1 creat-clo                425460.75                  137709.84 -287750.91 -67.63% File Creations and Closes/second
  2 page_test               2097119.26                 2373083.49  275964.23 13.16% System Allocations & Pages/second
  3 brk_test                7008395.33                 3787961.51 -3220433.82 -45.95% System Memory Allocations/second
  4 jmp_test               12226295.31                12254744.03   28448.72  0.23% Non-local gotos/second
  5 signal_test             1271126.28                  334357.29 -936768.99 -73.70% Signal Traps/second
  6 exec_test                   395.54                     349.00     -46.54 -11.77% Program Loads/second
  7 fork_test                 13218.23                    8822.93   -4395.30 -33.25% Task Creations/second
  8 link_test                 64776.04                    7410.75  -57365.29 -88.56% Link/Unlink Pairs/second

(as an aside, the succes rates for high-order allocations are lower with 
SLUB. Again, I blame slub_debug. I know that enabling SLAB_DEBUG has 
similar effects because of red-zoning and the like)

Now, the bad news. This exploded on ppc64. It started going wrong early in 
the boot process and got worse. I haven't looked closely as to why yet as 
there is other stuff on my plate but I've included a console log that 
might be some use to you. If you think you have a fix for it, feel free to 
send it on and I'll give it a test.


Config file read, 1024 bytes
Welcome
Welcome to yaboot version 1.3.12
Enter "help" to get some basic usage information
boot: autobench
Please wait, loading kernel...
    Elf64 kernel loaded...
Loading ramdisk...
ramdisk loaded at 02400000, size: 1648 Kbytes
OF stdout device is: /vdevice/vty@30000000
Hypertas detected, assuming LPAR !
command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1173335344 loglevel=8 slub_debug 
memory layout at init:
   alloc_bottom : 000000000259c000
   alloc_top    : 0000000008000000
   alloc_top_hi : 0000000100000000
   rmo_top      : 0000000008000000
   ram_top      : 0000000100000000
Looking for displays
instantiating rtas at 0x00000000077d9000 ... done
0000000000000000 : boot cpu     0000000000000000
0000000000000002 : starting cpu hw idx 0000000000000002... done
copying OF device tree ...
Building dt strings...
Building dt structure...
Device tree strings 0x000000000269d000 -> 0x000000000269e1d9
Device tree struct  0x000000000269f000 -> 0x00000000026a7000
Calling quiesce ...
returning from prom_init
Partition configured for 4 cpus.
Starting Linux PPC64 #1 SMP Wed Mar 7 22:23:06 PST 2007
-----------------------------------------------------
ppc64_pft_size                = 0x1a
physicalMemorySize            = 0x100000000
ppc64_caches.dcache_line_size = 0x80
ppc64_caches.icache_line_size = 0x80
htab_address                  = 0x0000000000000000
htab_hash_mask                = 0x7ffff
-----------------------------------------------------
Linux version 2.6.21-rc2-mm2-autokern1 (root@gekko-lp1) (gcc version 4.0.3 20051201 (prerelease) (Debian 4.0.2-5)) #1 SMP Wed Mar 7 22:23:06 PST 2007
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Zone PFN ranges:
   DMA             0 ->  1048576
   Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
     0:        0 ->  1048576
[boot]0015 Setup Done
Built 1 zonelists.  Total pages: 1034240
Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1173335344 loglevel=8 slub_debug 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 238.059000 MHz
time_init: processor frequency   = 1904.472000 MHz
Using pSeries machine description
Page orders: linear mapping = 24, virtual = 12, io = 12
Found initrd at 0xc000000002400000:0xc00000000259c000
Partition configured for 4 cpus.
Starting Linux PPC64 #1 SMP Wed Mar 7 22:23:06 PST 2007
-----------------------------------------------------
ppc64_pft_size                = 0x1a
physicalMemorySize            = 0x100000000
ppc64_caches.dcache_line_size = 0x80
ppc64_caches.icache_line_size = 0x80
htab_address                  = 0x0000000000000000
htab_hash_mask                = 0x7ffff
-----------------------------------------------------
Linux version 2.6.21-rc2-mm2-autokern1 (root@gekko-lp1) (gcc version 4.0.3 20051201 (prerelease) (Debian 4.0.2-5)) #1 SMP Wed Mar 7 22:23:06 PST 2007
[boot]0012 Setup Arch
Entering add_active_range(0, 0, 32768) 0 entries of 256 used
Entering add_active_range(0, 32768, 65536) 1 entries of 256 used
Entering add_active_range(0, 65536, 98304) 1 entries of 256 used
Entering add_active_range(0, 98304, 131072) 1 entries of 256 used
Entering add_active_range(0, 131072, 163840) 1 entries of 256 used
Entering add_active_range(0, 163840, 196608) 1 entries of 256 used
Entering add_active_range(0, 196608, 229376) 1 entries of 256 used
Entering add_active_range(0, 229376, 262144) 1 entries of 256 used
Entering add_active_range(0, 262144, 294912) 1 entries of 256 used
Entering add_active_range(0, 294912, 327680) 1 entries of 256 used
Entering add_active_range(0, 327680, 360448) 1 entries of 256 used
Entering add_active_range(0, 360448, 393216) 1 entries of 256 used
Entering add_active_range(0, 393216, 425984) 1 entries of 256 used
Entering add_active_range(0, 425984, 458752) 1 entries of 256 used
Entering add_active_range(0, 458752, 491520) 1 entries of 256 used
Entering add_active_range(0, 491520, 524288) 1 entries of 256 used
Entering add_active_range(0, 524288, 557056) 1 entries of 256 used
Entering add_active_range(0, 557056, 589824) 1 entries of 256 used
Entering add_active_range(0, 589824, 622592) 1 entries of 256 used
Entering add_active_range(0, 622592, 655360) 1 entries of 256 used
Entering add_active_range(0, 655360, 688128) 1 entries of 256 used
Entering add_active_range(0, 688128, 720896) 1 entries of 256 used
Entering add_active_range(0, 720896, 753664) 1 entries of 256 used
Entering add_active_range(0, 753664, 786432) 1 entries of 256 used
Entering add_active_range(0, 786432, 819200) 1 entries of 256 used
Entering add_active_range(0, 819200, 851968) 1 entries of 256 used
Entering add_active_range(0, 851968, 884736) 1 entries of 256 used
Entering add_active_range(0, 884736, 917504) 1 entries of 256 used
Entering add_active_range(0, 917504, 950272) 1 entries of 256 used
Entering add_active_range(0, 950272, 983040) 1 entries of 256 used
Entering add_active_range(0, 983040, 1015808) 1 entries of 256 used
Entering add_active_range(0, 1015808, 1048576) 1 entries of 256 used
Node 0 Memory: 0x0-0x100000000
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Using dedicated idle loop
sizeof(struct page) = 56
Zone PFN ranges:
   DMA             0 ->  1048576
   Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
     0:        0 ->  1048576
On node 0 totalpages: 1048576
   DMA zone: 14336 pages used for memmap
   DMA zone: 0 pages reserved
   DMA zone: 1034240 pages, LIFO batch:31
   Normal zone: 0 pages used for memmap
   Movable zone: 0 pages used for memmap
[boot]0015 Setup Done
Built 1 zonelists.  Total pages: 1034240
Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1173335344 loglevel=8 slub_debug 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 238.059000 MHz
time_init: processor frequency   = 1904.472000 MHz
Console: colour dummy device 80x25
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 0
Memory: 4113864k/4194304k available (4672k kernel code, 80440k reserved, 988k data, 576k bss, 252k init)
SLUB V4: General Slabs=9, HW alignment=128, Processors=4, Nodes=16
Calibrating delay loop... 475.13 BogoMIPS (lpj=950272)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 256
Processor 1 found.
Processor 2 found.
Processor 3 found.
Brought up 4 CPUs
Node 0 CPUs: 0-3
mm/memory.c:111: bad pud c0000000050e4480.
could not vmalloc 20971520 bytes for cache!
migration_cost=0,1000
*** SLUB: Redzone Inactive check fails in kmalloc-64@c0000000050de0f0 Slab c000000000756090
     offset=240 flags=5000000000c7 inuse=3 freelist=c0000000050de0f0
   Bytes b4 c0000000050de0e0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
     Object c0000000050de0f0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
     Object c0000000050de100:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
     Object c0000000050de110:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
     Object c0000000050de120:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
    Redzone c0000000050de130:  00 00 00 00 00 00 00 00                         ........ 
FreePointer c0000000050de138: 0000000000000000
Call Trace:
[C00000000506B9D0] [C000000000011188] .show_stack+0x6c/0x1a0 (unreliable)
[C00000000506BA70] [C0000000000CB9BC] .object_err+0x1bc/0x1e8
[C00000000506BB10] [C0000000000CBB3C] .check_object+0x154/0x23c
[C00000000506BBB0] [C0000000000CCFB0] .alloc_object_checks+0xc0/0x154
[C00000000506BC40] [C0000000000CD600] .kmem_cache_alloc+0xc8/0x4a8
[C00000000506BD00] [C0000000000CD9FC] .kmem_cache_zalloc+0x1c/0x50
[C00000000506BD90] [C000000000070334] .__create_workqueue+0x48/0x1b8
[C00000000506BE40] [C00000000046C36C] .helper_init+0x24/0x54
[C00000000506BEC0] [C000000000451B7C] .init+0x1c4/0x2f8
[C00000000506BF90] [C0000000000275D0] .kernel_thread+0x4c/0x68
NET: Registered protocol family 16
PCI: Probing PCI hardware
IOMMU table initialized, virtual merging enabled
mapping IO 3fe00600000 -> d000080000000000, size: 100000
PCI: Probing PCI hardware done
Registering pmac pic with sysfs...
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 524288 (order: 11, 12582912 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
checking if image is initramfs...it isn't (bad gzip magic numbers); looks like an initrd
Freeing initrd memory: 1648k freed
vio_bus_init: processing c0000000ffffe3a0
vio_bus_init: processing c0000000ffffe558
vio_bus_init: processing c0000000ffffe9f8
vio_bus_init: processing c0000000ffffeb30
vio_bus_init: processing c0000000ffffec88
scan-log-dump not implemented on this system
RTAS daemon started
RTAS: event: 1, Type: Platform Error, Severity: 2
audit: initializing netlink socket (disabled)
audit(1173335571.256:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
JFS: nTxBlock = 8192, nTxLock = 65536
SELinux:  Registering netfilter hooks
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
rpaphp: Slot [0000:00:02.2](PCI location=U7879.001.DQD0T7T-P1-C4) registered
vio_register_driver: driver hvc_console registering
------------[ cut here ]------------
Badness at mm/slub.c:1701
Call Trace:
[C00000000506B730] [C000000000011188] .show_stack+0x6c/0x1a0 (unreliable)
[C00000000506B7D0] [C0000000001EE9F4] .report_bug+0x94/0xe8
[C00000000506B860] [C00000000038C85C] .program_check_exception+0x16c/0x5f4
[C00000000506B930] [C0000000000046F4] program_check_common+0xf4/0x100
--- Exception: 700 at .get_slab+0xbc/0x18c
     LR = .__kmalloc+0x28/0x104
[C00000000506BC20] [C00000000506BCC0] 0xc00000000506bcc0 (unreliable)
[C00000000506BCD0] [C0000000000CE2EC] .__kmalloc+0x28/0x104
[C00000000506BD60] [C00000000022E724] .tty_register_driver+0x5c/0x23c
[C00000000506BE10] [C000000000477910] .hvsi_init+0x154/0x1b4
[C00000000506BEC0] [C000000000451B7C] .init+0x1c4/0x2f8
[C00000000506BF90] [C0000000000275D0] .kernel_thread+0x4c/0x68
HVSI: registered 0 devices
Generic RTC Driver v1.07
[drm] Initialized drm 1.1.0 20060810
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ide-floppy driver 0.99.newide
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
mice: PS/2 mouse device common for all mice
async_tx: api initialized (sync-only)
xor: measuring software checksumming speed
    8regs     :  6524.000 MB/sec
    8regs_prefetch:  4997.000 MB/sec
    32regs    :  6994.000 MB/sec
    32regs_prefetch:  4985.000 MB/sec
xor: using function: 32regs (6994.000 MB/sec)
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
RAMDISK: cramfs filesystem found at block 0
RAMDISK: Loading 1648KiB [1 disk] into ram disk... |/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-done.
VFS: Mounted root (cramfs filesystem) readonly.
mm/memory.c:111: bad pud c000000005a0ad80.
mm/memory.c:111: bad pud c000000005a0b200.
mm/memory.c:111: bad pud c000000005a0a480.
mm/memory.c:111: bad pud c000000005a0b680.
mm/memory.c:111: bad pud c000000005a0a900.
mm/memory.c:111: bad pud c000000005a0bb00.
mm/memory.c:111: bad pud c000000005762900.
mm/memory.c:111: bad pud c000000005762480.
------------[ cut here ]------------
kernel BUG at mm/mmap.c:1999!
cpu 0x3: Vector: 700 (Program Check) at [c00000000576b430]
     pc: c0000000000b37d4: .exit_mmap+0x150/0x178
     lr: c0000000000b37b8: .exit_mmap+0x134/0x178
     sp: c00000000576b6b0
    msr: 8000000000029032
   current = 0xc000000005177680
   paca    = 0xc0000000004a5280
     pid   = 235, comm = linuxrc
kernel BUG at mm/mmap.c:1999!
------------[ cut here ]------------
Badness at arch/powerpc/kernel/entry_64.S:651
Call Trace:
[C00000000576A720] [C000000000011188] .show_stack+0x6c/0x1a0 (unreliable)
[C00000000576A7C0] [C0000000001EE9F4] .report_bug+0x94/0xe8
[C00000000576A850] [C00000000038C85C] .program_check_exception+0x16c/0x5f4
[C00000000576A920] [C0000000000046F4] program_check_common+0xf4/0x100
--- Exception: 700 at .enter_rtas+0xa0/0x10c
     LR = .xmon_core+0x580/0x920
[C00000000576AC10] [C00000000004DCD4] .xmon_printf+0x64/0x7c (unreliable)
[C00000000576ADF0] [C00000000004D118] .xmon_core+0x580/0x920
[C00000000576AF80] [C00000000004D700] .xmon+0x30/0x40
[C00000000576B150] [C000000000025D0C] .die+0x50/0x1b8
[C00000000576B1E0] [C0000000000260AC] ._exception+0x40/0x134
[C00000000576B2F0] [C00000000038CCA8] .program_check_exception+0x5b8/0x5f4
[C00000000576B3C0] [C0000000000046F4] program_check_common+0xf4/0x100
--- Exception: 700 at .exit_mmap+0x150/0x178
     LR = .exit_mmap+0x134/0x178
[C00000000576B760] [C0000000000574FC] .mmput+0x78/0x170
[C00000000576B800] [C00000000005C968] .exit_mm+0x128/0x148
[C00000000576B890] [C00000000005E8E4] .do_exit+0x274/0x958
[C00000000576B940] [C00000000005F09C] .sys_exit_group+0x0/0x8
[C00000000576B9D0] [C00000000006AC0C] .get_signal_to_deliver+0x678/0x700
[C00000000576BB60] [C00000000000F2E0] .do_signal32+0x7c/0x818
[C00000000576BCD0] [C000000000017BB8] .do_signal+0x4c/0x8b8
[C00000000576BE30] [C000000000008CE8] do_work+0x28/0x2c
enter ? for help
[c00000000576b760] c0000000000574fc .mmput+0x78/0x170
[c00000000576b800] c00000000005c968 .exit_mm+0x128/0x148
[c00000000576b890] c00000000005e8e4 .do_exit+0x274/0x958
[c00000000576b940] c00000000005f09c .sys_exit_group+0x0/0x8
[c00000000576b9d0] c00000000006ac0c .get_signal_to_deliver+0x678/0x700
[c00000000576bb60] c00000000000f2e0 .do_signal32+0x7c/0x818
[c00000000576bcd0] c000000000017bb8 .do_signal+0x4c/0x8b8
[c00000000576be30] c000000000008ce8 do_work+0x28/0x2c
--- Exception: 300 (Data Access) at 000000000ff36f8c
SP (ffb5f8a0) is in userspace
3:mon>-- 0:conmux-control -- time-stamp -- Mar/07/07 22:35:07 --
-- 0:conmux-control -- time-stamp -- Mar/07/07 22:49:34 --
(bot:conmon-payload) disconnected

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
