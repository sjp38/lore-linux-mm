Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 489846B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 17:09:26 -0400 (EDT)
Date: Mon, 19 Apr 2010 14:09:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15783] New: slow dd and multiple
 "page allocation failure" messages
Message-Id: <20100419140948.0b748c69.akpm@linux-foundation.org>
In-Reply-To: <bug-15783-10286@https.bugzilla.kernel.org/>
References: <bug-15783-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, walter.haidinger@gmx.at
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Sigh.  This shouldn't happen.

I'm going to go ahead and assume that some earlier kernels didn't do
this :(

Is the writeout to /dev/sde1 slow right from the start, or does it
start out fast and later slow down?

`dd' isn't very efficient without the `bs' option - it reads and writes
in 512-byte chunks.   But that shouldn't be causing these problems.

On Wed, 14 Apr 2010 08:36:08 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15783
> 
>            Summary: slow dd and multiple "page allocation failure"
>                     messages
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.33.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: walter.haidinger@gmx.at
>         Regression: No
> 
> 
> There are some other bugzilla entries regarding "page allocation failure"
> messages, but for me the problem is reproducible:
> I've tried to zero-out a sata disk with 'dd if=/dev/zero of=/dev/sde1' over
> night and within about 5 hours over 100 "page allocation failure" messages"
> were logged.
> 
> Please note that 'dd if=/dev/zero of=/dev/sde1' IO throughput is reproducible
> _slow_, only about 10 (ten) MiB/s. In contrast, 'badblocks -w /dev/sde1' has 10
> times (>100 MiB/s). Odd. Btw, the harddisk (Seagate ST31500341AS) has no
> problems. sata_nv is the driver module used.
> 
> The system itself has 6 GiB RAM and idle most of the time. Especially no
> virtual machines or other memory hogs were/are currently running. Active memory
> is usually about 2 GiB (see /proc/meminfo below), leaving 4 for buffers/cache.
> Still a single dd can cause memory pressure?
> 
> One more to note: Swap-space is a dmcrypt LVM logical volume.
> 
> I'm adding the dmesg kernel message and some system info (lspci,lsmod) below.
> Please tell me if you need any additional info (kernel config, etc).
> 
> OS: openSUSE 11.2 x86_64 with custom 2.6.33.2 kernel compiled from mainline.
>     dd is version 7.1 from coreutils-7.1-3.2.x86_64 rpm.
> Hardware: Athlon X2 BE-2350 on a MSI MS-7250 motherboard
> 
> # dmesg 
> ...
> [800144.472687] swapper: page allocation failure. order:2, mode:0x4020
> [800144.472701] Pid: 0, comm: swapper Not tainted 2.6.33.2-vmhost64 #13
> [800144.472706] Call Trace:
> [800144.472710]  <IRQ>  [<ffffffff810a94dd>] __alloc_pages_nodemask+0x55d/0x650
> [800144.472726]  [<ffffffff81257348>] ? dev_alloc_skb+0x18/0x30
> [800144.472732]  [<ffffffff810a95e2>] __get_free_pages+0x12/0x50
> [800144.472739]  [<ffffffff810d6dbc>] __kmalloc_track_caller+0xdc/0xe0
> [800144.472745]  [<ffffffff8125660f>] __alloc_skb+0x6f/0x170
> [800144.472750]  [<ffffffff81257348>] dev_alloc_skb+0x18/0x30
> [800144.472782]  [<ffffffffa0232298>] nv_alloc_rx_optimized+0x198/0x260
> [forcedeth]
> [800144.472792]  [<ffffffffa0234033>] ? nv_rx_process_optimized+0xa3/0x2a0
> [forcedeth]
> [800144.472802]  [<ffffffffa0235956>] nv_napi_poll+0x86/0x600 [forcedeth]
> [800144.472809]  [<ffffffff812a3b7e>] ? tcp_send_probe0+0x7e/0x110
> [800144.472816]  [<ffffffff8125ecdb>] net_rx_action+0xdb/0x190
> [800144.472822]  [<ffffffff810491b6>] __do_softirq+0xa6/0x130
> [800144.472831]  [<ffffffffa02344bd>] ? nv_nic_irq_optimized+0x6d/0xa0
> [forcedeth]
> [800144.472840]  [<ffffffff81003c0c>] call_softirq+0x1c/0x30
> [800144.472845]  [<ffffffff81005ccd>] do_softirq+0x4d/0x80
> [800144.472850]  [<ffffffff81048ecd>] irq_exit+0x7d/0x90
> [800144.472855]  [<ffffffff810052c0>] do_IRQ+0x70/0xf0
> [800144.472861]  [<ffffffff812f6713>] ret_from_intr+0x0/0xa
> [800144.472865]  <EOI>  [<ffffffff8100b584>] ? default_idle+0x24/0x40
> [800144.472873]  [<ffffffff8100b6c3>] c1e_idle+0x83/0x100
> [800144.472879]  [<ffffffff8105eff5>] ? atomic_notifier_call_chain+0x15/0x20
> [800144.472886]  [<ffffffff81001e85>] cpu_idle+0xa5/0x100
> [800144.472893]  [<ffffffff812e40d4>] rest_init+0x74/0x80
> [800144.472899]  [<ffffffff81661b22>] start_kernel+0x3b3/0x3bf
> [800144.472905]  [<ffffffff81661123>] x86_64_start_reservations+0x120/0x124
> [800144.472910]  [<ffffffff81661208>] x86_64_start_kernel+0xe1/0xe8
> [800144.472915] Mem-Info:
> [800144.472918] DMA per-cpu:
> [800144.472922] CPU    0: hi:    0, btch:   1 usd:   0
> [800144.472926] CPU    1: hi:    0, btch:   1 usd:   0
> [800144.472930] DMA32 per-cpu:
> [800144.472934] CPU    0: hi:  186, btch:  31 usd:  45
> [800144.472938] CPU    1: hi:  186, btch:  31 usd:  41
> [800144.472942] Normal per-cpu:
> [800144.472945] CPU    0: hi:  186, btch:  31 usd: 174
> [800144.472949] CPU    1: hi:  186, btch:  31 usd: 161
> [800144.472956] active_anon:140610 inactive_anon:62465 isolated_anon:0
> [800144.472957]  active_file:389749 inactive_file:423491 isolated_file:0
> [800144.472959]  unevictable:0 dirty:46557 writeback:0 unstable:0
> [800144.472960]  free:61093 slab_reclaimable:113077 slab_unreclaimable:43152
> [800144.472961]  mapped:7423 shmem:2438 pagetables:5126 bounce:0
> [800144.472980] DMA free:15832kB min:160kB low:200kB high:240kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15272kB mlocked:0kB dirty:0kB
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
> kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
> pages_scanned:0 all_unreclaimable? yes
> [800144.472998] lowmem_reserve[]: 0 2872 6028 6028
> [800144.473008] DMA32 free:185784kB min:31144kB low:38928kB high:46716kB
> active_anon:76516kB inactive_anon:86588kB active_file:746584kB
> inactive_file:815404kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> present:2940960kB mlocked:0kB dirty:128756kB writeback:0kB mapped:3100kB
> shmem:48kB slab_reclaimable:367280kB slab_unreclaimable:114280kB
> kernel_stack:248kB pagetables:1220kB unstable:0kB bounce:0kB writeback_tmp:0kB
> pages_scanned:0 all_unreclaimable? no
> [800144.473028] lowmem_reserve[]: 0 0 3156 3156
> [800144.473037] Normal free:42756kB min:34224kB low:42780kB high:51336kB
> active_anon:485924kB inactive_anon:163272kB active_file:812412kB
> inactive_file:878560kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> present:3232000kB mlocked:0kB dirty:57472kB writeback:0kB mapped:26592kB
> shmem:9704kB slab_reclaimable:85028kB slab_unreclaimable:58320kB
> kernel_stack:4128kB pagetables:19284kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [800144.473057] lowmem_reserve[]: 0 0 0 0
> [800144.473062] DMA: 4*4kB 3*8kB 3*16kB 2*32kB 3*64kB 3*128kB 1*256kB 1*512kB
> 2*1024kB 2*2048kB 2*4096kB = 15832kB
> [800144.473075] DMA32: 45342*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB
> 0*512kB 0*1024kB 0*2048kB 1*4096kB = 185800kB
> [800144.473087] Normal: 9685*4kB 0*8kB 1*16kB 1*32kB 0*64kB 1*128kB 1*256kB
> 1*512kB 1*1024kB 1*2048kB 0*4096kB = 42756kB
> [800144.473100] 820255 total pagecache pages
> [800144.473103] 4556 pages in swap cache
> [800144.473108] Swap cache stats: add 27731, delete 23175, find 4074847/4075448
> [800144.473112] Free swap  = 10257060kB
> [800144.473116] Total swap = 10348392kB
> [800144.513770] 1572864 pages RAM
> [800144.513786] 43214 pages reserved
> [800144.513789] 933611 pages shared
> [800144.513792] 587054 pages non-shared
> 
> # grep "page allocation failure" /var/log/allmessages | tail -n 30
> Apr 14 06:41:32 vmhost kernel: [795264.472696] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 06:41:32 vmhost kernel: [795264.514764] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 06:48:57 vmhost kernel: [795709.282767] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 06:49:40 vmhost kernel: [795752.472794] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:00:51 vmhost kernel: [796423.473152] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:06:57 vmhost kernel: [796789.472681] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:09:45 vmhost kernel: [796956.780137] dd: page allocation failure.
> order:2, mode:0x4020
> Apr 14 07:12:02 vmhost kernel: [797094.472832] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:16:15 vmhost kernel: [797347.399274] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:16:15 vmhost kernel: [797347.439814] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:18:08 vmhost kernel: [797460.475082] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:23:13 vmhost kernel: [797765.475010] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:24:06 vmhost kernel: [797818.282571] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:24:14 vmhost kernel: [797826.474998] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:25:15 vmhost kernel: [797887.472741] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:26:16 vmhost kernel: [797948.472813] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:29:05 vmhost kernel: [798117.492686] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:29:06 vmhost kernel: [798117.538250] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:29:06 vmhost kernel: [798117.584141] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:29:19 vmhost kernel: [798131.472943] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:34:06 vmhost kernel: [798418.066793] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:37:27 vmhost kernel: [798619.472779] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:39:09 vmhost kernel: [798720.620177] nmbd: page allocation failure.
> order:2, mode:0x4020
> Apr 14 07:43:33 vmhost kernel: [798985.472759] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> Apr 14 07:44:09 vmhost kernel: [799021.350169] nmbd: page allocation failure.
> order:2, mode:0x4020
> Apr 14 07:56:46 vmhost kernel: [799778.472862] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 08:00:50 vmhost kernel: [800022.472689] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 08:00:50 vmhost kernel: [800022.512410] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 08:02:52 vmhost kernel: [800144.472687] swapper: page allocation
> failure. order:2, mode:0x4020
> Apr 14 08:11:00 vmhost kernel: [800632.472900] ksoftirqd/0: page allocation
> failure. order:2, mode:0x4020
> 
> #uname -a
> Linux vmhost.private 2.6.33.2-vmhost64 #13 SMP Sat Apr 3 13:59:32 CEST 2010
> x86_64 x86_64 x86_64 GNU/Linux
> 
> #cat /proc/meminfo 
> MemTotal:        6118600 kB
> MemFree:          229480 kB
> Buffers:         3073148 kB
> Cached:           262476 kB
> SwapCached:        18124 kB
> Active:          1900516 kB
> Inactive:        2243036 kB
> Active(anon):     569736 kB
> Inactive(anon):   248008 kB
> Active(file):    1330780 kB
> Inactive(file):  1995028 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:      10348392 kB
> SwapFree:       10255720 kB
> Dirty:            190724 kB
> Writeback:             0 kB
> AnonPages:        790712 kB
> Mapped:            33872 kB
> Shmem:              9752 kB
> Slab:             552152 kB
> SReclaimable:     378800 kB
> SUnreclaim:       173352 kB
> KernelStack:        4400 kB
> PageTables:        20760 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    13407692 kB
> Committed_AS:    1495296 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      288944 kB
> VmallocChunk:   34359412148 kB
> HardwareCorrupted:     0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:       10048 kB
> DirectMap2M:     6281216 kB
> 
> #lspci
> 00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a1)
> 00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a2)
> 00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a2)
> 00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1)
> 00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2)
> 00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1)
> 00:05.0 RAID bus controller: nVidia Corporation MCP55 SATA Controller (rev a2)
> 00:05.1 RAID bus controller: nVidia Corporation MCP55 SATA Controller (rev a2)
> 00:05.2 RAID bus controller: nVidia Corporation MCP55 SATA Controller (rev a2)
> 00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2)
> 00:06.1 Audio device: nVidia Corporation MCP55 High Definition Audio (rev a2)
> 00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
> 00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
> 00:0a.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:0b.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:0c.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:0d.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:0f.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2)
> 00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]
> HyperTransport Technology Configuration
> 00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address
> Map
> 00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM
> Controller
> 00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]
> Miscellaneous Control
> 01:00.0 Multimedia video controller: Internext Compression Inc iTVC16 (CX23416)
> MPEG-2 Encoder (rev 01)
> 01:01.0 Multimedia video controller: Internext Compression Inc iTVC16 (CX23416)
> MPEG-2 Encoder (rev 01)
> 01:02.0 Multimedia controller: Philips Semiconductors SAA7146 (rev 01)
> 05:00.0 Mass storage controller: Silicon Image, Inc. SiI 3132 Serial ATA Raid
> II Controller (rev 01)
> 07:00.0 VGA compatible controller: nVidia Corporation NV44 [GeForce 6200 LE]
> (rev a1)
> 
> -- 
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
