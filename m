Date: Sun, 30 Dec 2007 17:32:05 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: PROBLEM: BUG: null pointer deref., segfaults
Message-ID: <20071231003204.GX11638@parisc-linux.org>
References: <1171260095.20071231000600@freemail.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1171260095.20071231000600@freemail.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erno Kovacs <erno.kovacs@freemail.hu>
Cc: linux-ide@vger.kernel.org, jgarzik@pobox.com, linux-scsi@vger.kernel.org, bzolnier@gmail.com, James.Bottomley@SteelEye.com, axboe@kernel.dk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>From the backtrace, this doesn't seem to be a scsi or ide problem.
It might be a block-layer bug, or a VM problem.  I've cc'd the VM people
to see what they think.

On Mon, Dec 31, 2007 at 12:06:00AM +0100, Erno Kovacs wrote:
> [1.] One line summary of the problem:
> 
> using dd on a broken hdd causes kernel NULL pointer dereference
> 
> 
> [2.] Full description of the problem/report:
> 
> I have a broken hdd (unreadable sector). While dd-ing it into another same size hdd, 
> I get kernel-level error. First time it is a NULL pointer dereference then a few minutes
> later its a BUG in mm/slab.c, no IO operation anymore shown by iostat, and dd gets 
> kernel-space process (shown as [dd] by ps). System becomes unstable, processes get 
> segfaulted, even reboot is unoperational.
> 
> Dmesg output:
> BUG: unable to handle kernel NULL pointer dereference at virtual address 0000002a
>  printing eip:
> c016b8ce
> *pde = 00000000
> Oops: 0002 [#1]
> Modules linked in: ac battery dm_crypt dm_snapshot dm_mirror dm_mod joydev tsdev usbhid sd_mod fan rtc evdev thermal processor button psmouse 
> 
> serio_raw pcspkr via_agp agpgart i2c_viapro ehci_hcd hpt366 uhci_hcd i2c_core usbcore sata_sil
> CPU:    0
> EIP:    0060:[<c016b8ce>]    Not tainted VLI
> EFLAGS: 00010213   (2.6.23.12 #1)
> EIP is at drop_buffers+0x5a/0xd5
> eax: 0000002e   ebx: d6e300f0   ecx: 00000026   edx: d6e30118
> esi: c126e140   edi: d6e300f0   ebp: d6e300f0   esp: c149bdd8
> ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
> Process kswapd0 (pid: 163, ti=c149a000 task=dff6f030 task.ti=c149a000)
> Stack: 00000000 c1274860 c1117260 df1152fc c149be00 c126e140 00000000 00000001
>        c149bf84 c016b987 00000000 c126e140 df1152fc c0141f72 0000043e 00000011
>        00000000 c149bf14 01000020 00000000 00000004 00000004 00000001 c12dc440
> Call Trace:
>  [<c016b987>] try_to_free_buffers+0x3e/0x6c
>  [<c0141f72>] shrink_page_list+0x414/0x4fc
>  [<c01415a7>] isolate_lru_pages+0x44/0x17f
>  [<c0142128>] shrink_inactive_list+0xce/0x265
>  [<c0117f98>] check_preempt_curr_fair+0x52/0x56
>  [<c014237d>] shrink_zone+0xbe/0xe2
>  [<c014278d>] kswapd+0x251/0x3b8
>  [<c0127a69>] autoremove_wake_function+0x0/0x35
>  [<c014253c>] kswapd+0x0/0x3b8
>  [<c0127913>] kthread+0x36/0x5b
>  [<c01278dd>] kthread+0x0/0x5b
>  [<c010468f>] kernel_thread_helper+0x7/0x10
>  =======================
> Code: 14 8b 02 83 e0 06 0b 42 34 74 07 31 c0 e9 8c 00 00 00 8b 52 04 39 fa 75 d5 89 fb 8b 4b 28 8d 53 28 8b 6b 04 39 d1 74 53 8b 42 04 <89> 41 04 89 
> 
> 08 89 52 04 83 7b 30 00 89 53 28 75 29 c7 44 24 0c
> EIP: [<c016b8ce>] drop_buffers+0x5a/0xd5 SS:ESP 0068:c149bdd8
> 
> then later 
> 
> ------------[ cut here ]------------
> kernel BUG at mm/slab.c:2983!
> invalid opcode: 0000 [#2]
> Modules linked in: ac battery dm_crypt dm_snapshot dm_mirror dm_mod joydev tsdev usbhid sd_mod fan rtc evdev thermal processor button psmouse 
> 
> serio_raw pcspkr via_agp agpgart i2c_viapro ehci_hcd hpt366 uhci_hcd i2c_core usbcore sata_sil
> CPU:    0
> EIP:    0060:[<c01501fc>]    Tainted: G      D VLI
> EFLAGS: 00010046   (2.6.23.12 #1)
> EIP is at cache_alloc_refill+0xe0/0x3ec
> eax: 00000043   ebx: 00000020   ecx: dffe7da0   edx: dffe7da0
> esi: d4686000   edi: dffedd20   ebp: dffe9200   esp: de49dcc8
> ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> Process dd (pid: 1888, ti=de49c000 task=df7dd030 task.ti=de49c000)
> Stack: 00000043 00008050 dffe7da0 00000000 0000001a c0262880 d67d79e0 c013d8d3
>        c016b777 c1126900 dffe7da0 00000282 00008050 c01500e2 c1126900 00000000
>        00000000 00001000 c016b75d c1126900 c016bda5 00000001 c1126900 fffff000
> Call Trace:
>  [<c0262880>] submit_bio+0xa5/0xac
>  [<c013d8d3>] mempool_alloc+0x1c/0x93
>  [<c016b777>] alloc_buffer_head+0x2a/0x2e
>  [<c01500e2>] kmem_cache_alloc+0x2b/0x65
>  [<c016b75d>] alloc_buffer_head+0x10/0x2e
>  [<c016bda5>] alloc_page_buffers+0x2d/0xbb
>  [<c016be43>] create_empty_buffers+0x10/0x6b
>  [<c016dce5>] block_read_full_page+0x40/0x296
>  [<c017014f>] blkdev_get_block+0x0/0x42
>  [<c014054f>] __do_page_cache_readahead+0x16c/0x1bf
>  [<c0140714>] ondemand_readahead+0x48/0xf1
>  [<c013bbf8>] do_generic_mapping_read+0x10d/0x3c8
>  [<c013d2ca>] generic_file_aio_read+0x12d/0x159
>  [<c013b5b7>] file_read_actor+0x0/0xca
>  [<c01528a4>] do_sync_read+0xc6/0x109
>  [<c0139bbe>] handle_IRQ_event+0x1a/0x3f
>  [<c0127a69>] autoremove_wake_function+0x0/0x35
>  [<c012d12a>] clockevents_program_event+0x9c/0xa3
>  [<c01527de>] do_sync_read+0x0/0x109
>  [<c01530bb>] vfs_read+0xa6/0x128
>  [<c01533db>] sys_read+0x41/0x67
>  [<c0103afe>] sysenter_past_esp+0x5f/0x85
>  =======================
> Code: be 00 00 00 8b 37 39 fe 75 15 8b 77 10 8d 47 10 c7 47 30 01 00 00 00 39 c6 0f 84 9a 00 00 00 8b 54 24 08 8b 42 1c 39 46 10 72 2d <0f> 0b eb fe 
> 
> 8b 44 24 08 8b 5e 14 8b 4d 00 8b 50 10 8b 04 24 0f
> EIP: [<c01501fc>] cache_alloc_refill+0xe0/0x3ec SS:ESP 0068:de49dcc8
> 
> 
> 
> [3.] Keywords (i.e., modules, networking, kernel):
> 
> dd null pointer dereference segfault
> 
> 
> [4.] Kernel version (from /proc/version):
> 
> Linux version 2.6.23.12 (root@xxx) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 Thu Dec 27 13:22:18 CET 2007
> 
> 
> [5.] Output of Oops.. message (if applicable) with symbolic information 
>      resolved (see Documentation/oops-tracing.txt)
> 
> sorry:)
> 
> 
> [6.] A small shell script or example program which triggers the
>      problem (if possible)
> 
> dd if=/dev/sdd of=/dev/sdb bs=65536
> where sdd is the broken hdd and sdb is a working one with the same size
> 
> 
> [7.] Environment
> [7.1.] Software (add the output of the ver_linux script here)
> 
> Linux ttm 2.6.23.12 #1 Thu Dec 27 13:22:18 CET 2007 i686 GNU/Linux
> 
> Gnu C                  4.1.2
> Gnu make               3.81
> binutils               2.17
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.3-pre2
> e2fsprogs              1.40-WIP
> xfsprogs               2.8.11
> Linux C Library        3.6
> Dynamic linker (ldd)   2.3.6
> Procps                 3.2.7
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               5.97
> udev                   105
> Modules Loaded         ac battery dm_crypt dm_snapshot dm_mirror dm_mod joydev tsdev usbhid sd_mod fan rtc evdev thermal processor button psmouse 
> 
> serio_raw pcspkr via_agp agpgart i2c_viapro ehci_hcd hpt366 uhci_hcd i2c_core usbcore sata_sil
> 
> 
> [7.2.] Processor information (from /proc/cpuinfo):
> 
> processor       : 0
> vendor_id       : AuthenticAMD
> cpu family      : 6
> model           : 8
> model name      : AMD Duron(tm) processor
> stepping        : 1
> cpu MHz         : 1800.908
> cache size      : 64 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 1
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow ts
> bogomips        : 3604.56
> clflush size    : 32
> 
> 
> [7.3.] Module information (from /proc/modules):
> 
> ac 5764 0 - Live 0xe08a6000
> battery 12424 0 - Live 0xe0a09000
> dm_crypt 13064 0 - Live 0xe09bc000
> dm_snapshot 16800 0 - Live 0xe09a4000
> dm_mirror 20480 0 - Live 0xe090e000
> dm_mod 51136 3 dm_crypt,dm_snapshot,dm_mirror, Live 0xe09ae000
> joydev 9920 0 - Live 0xe08b1000
> tsdev 8384 0 - Live 0xe090a000
> usbhid 26496 0 - Live 0xe091c000
> sd_mod 27408 0 - Live 0xe0914000
> fan 5252 0 - Live 0xe0907000
> i2c_viapro 8340 0 - Live 0xe08f8000
> ehci_hcd 29964 0 - Live 0xe08fe000
> rtc 11672 0 - Live 0xe08de000
> evdev 9600 0 - Live 0xe08f0000
> pcspkr 2944 0 - Live 0xe08a9000
> hpt366 15488 0 [permanent], Live 0xe08d9000
> uhci_hcd 22028 0 - Live 0xe08e9000
> i2c_core 23568 1 i2c_viapro, Live 0xe08e2000
> thermal 15644 0 - Live 0xe08ac000
> processor 27056 1 thermal, Live 0xe08d1000
> sata_sil 11016 0 - Live 0xe086d000
> psmouse 36112 0 - Live 0xe08b5000
> serio_raw 6660 0 - Live 0xe087a000
> via_agp 10240 1 - Live 0xe085e000
> agpgart 31024 1 via_agp, Live 0xe0871000
> button 8464 0 - Live 0xe0862000
> usbcore 127384 4 usbhid,ehci_hcd,uhci_hcd, Live 0xe0885000
> 
> 
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-006f : keyboard
> 0070-0077 : rtc
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:11.1
>   0170-0177 : ide1
> 01f0-01f7 : 0000:00:11.1
>   01f0-01f7 : ide0
> 0376-0376 : 0000:00:11.1
>   0376-0376 : ide1
> 03c0-03df : vga+
> 03f6-03f6 : 0000:00:11.1
>   03f6-03f6 : ide0
> 0cf8-0cff : PCI conf1
> 4000-4003 : ACPI PM1a_EVT_BLK
> 4008-400b : ACPI PM_TMR
> 4010-4015 : ACPI CPU throttle
> 4020-4023 : ACPI GPE0_BLK
> 40f0-40f1 : ACPI PM1a_CNT_BLK
> 5000-5007 : vt596_smbus
> 8000-8007 : 0000:00:08.0
> 8400-8403 : 0000:00:08.0
> 8800-8807 : 0000:00:08.0
> 8c00-8c03 : 0000:00:08.0
> 9000-900f : 0000:00:08.0
> 9400-9407 : 0000:00:09.0
> 9800-9803 : 0000:00:09.0
> 9c00-9c07 : 0000:00:09.0
> a000-a003 : 0000:00:09.0
> a400-a40f : 0000:00:09.0
> a800-a8ff : 0000:00:0f.0
>   a800-a8ff : 8139too
> ac00-ac1f : 0000:00:10.0
>   ac00-ac1f : uhci_hcd
> b000-b01f : 0000:00:10.1
>   b000-b01f : uhci_hcd
> b400-b40f : 0000:00:11.1
>   b400-b407 : ide0
>   b408-b40f : ide1
> b800-b81f : 0000:00:11.2
>   b800-b81f : uhci_hcd
> bc00-bc1f : 0000:00:11.3
>   bc00-bc1f : uhci_hcd
> c000-c0ff : 0000:00:11.5
> c400-c407 : 0000:00:13.0
>   c400-c407 : ide2
> c800-c803 : 0000:00:13.0
>   c802-c802 : ide2
> cc00-cc07 : 0000:00:13.0
> d000-d003 : 0000:00:13.0
> d400-d4ff : 0000:00:13.0
>   d400-d407 : ide2
>   d408-d40f : ide3
>   d410-d4ff : HPT374
> d800-d807 : 0000:00:13.1
> dc00-dc03 : 0000:00:13.1
> e000-e007 : 0000:00:13.1
>   e000-e007 : ide5
> e400-e403 : 0000:00:13.1
>   e402-e402 : ide5
> e800-e8ff : 0000:00:13.1
>   e800-e807 : ide4
>   e808-e80f : ide5
>   e810-e8ff : HPT374
> 
> 
> 00000000-0009fbff : System RAM
>   00000000-00000000 : Crash kernel
> 0009fc00-0009ffff : reserved
> 000a0000-000bffff : Video RAM area
> 000c0000-000c7fff : Video ROM
> 000c8000-000cbfff : pnp 00:00
> 000d0000-000d3fff : Adapter ROM
> 000d4000-000d87ff : Adapter ROM
> 000d9000-000dcbff : Adapter ROM
> 000dcc00-000dffff : pnp 00:00
> 000f0000-000fffff : System ROM
> 00100000-1ffeffff : System RAM
>   00100000-0036f839 : Kernel code
>   0036f83a-00449e9b : Kernel data
> 1fff0000-1fff2fff : ACPI Non-volatile Storage
> 1fff3000-1fffffff : ACPI Tables
> 30000000-3007ffff : 0000:00:08.0
> 30080000-300fffff : 0000:00:09.0
> 30100000-3011ffff : 0000:00:13.0
> 30120000-3012ffff : 0000:00:0b.0
> 30130000-3013ffff : 0000:00:0f.0
> e0000000-e3ffffff : 0000:00:00.0
> e4000000-e7ffffff : 0000:00:0b.0
> e9000000-e9003fff : 0000:00:0d.0
> e9004000-e90041ff : 0000:00:08.0
>   e9004000-e90041ff : sata_sil
> e9005000-e90057ff : 0000:00:0d.0
> e9006000-e90061ff : 0000:00:09.0
>   e9006000-e90061ff : sata_sil
> e9007000-e90070ff : 0000:00:0f.0
>   e9007000-e90070ff : 8139too
> e9008000-e90080ff : 0000:00:10.2
>   e9008000-e90080ff : ehci_hcd
> fec00000-fec00fff : reserved
> fee00000-fee00fff : reserved
> ffff0000-ffffffff : reserved
> 
> 
> 
> 
> [7.5.] PCI information ('lspci -vvv' as root)
> 
> 00:00.0 Host bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/333]
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Region 0: Memory at e0000000 (32-bit, prefetchable) [size=64M]
>         Capabilities: [a0] AGP version 2.0
>                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW- AGP3- Rate=x1,x2
>                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/333 AGP] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: fff00000-000fffff
>         Prefetchable memory behind bridge: fff00000-000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:08.0 RAID bus controller: Silicon Image, Inc. Adaptec AAR-1210SA SATA HostRAID Controller (rev 02) (prog-if 01)
>         Subsystem: Adaptec Unknown device 0240
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 7
>         Region 0: I/O ports at 8000 [size=8]
>         Region 1: I/O ports at 8400 [size=4]
>         Region 2: I/O ports at 8800 [size=8]
>         Region 3: I/O ports at 8c00 [size=4]
>         Region 4: I/O ports at 9000 [size=16]
>         Region 5: Memory at e9004000 (32-bit, non-prefetchable) [size=512]
>         [virtual] Expansion ROM at 30000000 [disabled] [size=512K]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 
> 00:09.0 RAID bus controller: Silicon Image, Inc. SiI 3512 [SATALink/SATARaid] Serial ATA Controller (rev 01)
>         Subsystem: Silicon Image, Inc. SiI 3512 SATARaid Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 11
>         Region 0: I/O ports at 9400 [size=8]
>         Region 1: I/O ports at 9800 [size=4]
>         Region 2: I/O ports at 9c00 [size=8]
>         Region 3: I/O ports at a000 [size=4]
>         Region 4: I/O ports at a400 [size=16]
>         Region 5: Memory at e9006000 (32-bit, non-prefetchable) [size=512]
>         [virtual] Expansion ROM at 30080000 [disabled] [size=512K]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 
> 00:0b.0 VGA compatible controller: S3 Inc. 86c764/765 [Trio32/64/64V+] (rev 54) (prog-if 00 [VGA])
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin A routed to IRQ 3
>         Region 0: Memory at e4000000 (32-bit, non-prefetchable) [size=64M]
>         [virtual] Expansion ROM at 30120000 [disabled] [size=64K]
> 
> 00:0d.0 FireWire (IEEE 1394): Texas Instruments TSB43AB23 IEEE-1394a-2000 Controller (PHY/Link) (prog-if 10 [OHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (500ns min, 1000ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 7
>         Region 0: Memory at e9005000 (32-bit, non-prefetchable) [size=2K]
>         Region 1: Memory at e9000000 (32-bit, non-prefetchable) [size=16K]
>         Capabilities: [44] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0f.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
>         Subsystem: ABIT Computer Corp. Unknown device 8139
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (8000ns min, 16000ns max)
>         Interrupt: pin A routed to IRQ 11
>         Region 0: I/O ports at a800 [size=256]
>         Region 1: Memory at e9007000 (32-bit, non-prefetchable) [size=256]
>         [virtual] Expansion ROM at 30130000 [disabled] [size=64K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 50) (prog-if 00 [UHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 3
>         Region 4: I/O ports at ac00 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 50) (prog-if 00 [UHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin B routed to IRQ 7
>         Region 4: I/O ports at b000 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:10.2 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 51) (prog-if 20 [EHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 64 bytes
>         Interrupt: pin C routed to IRQ 10
>         Region 0: Memory at e9008000 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.0 ISA bridge: VIA Technologies, Inc. VT8233A ISA Bridge
>         Subsystem: VIA Technologies, Inc. VT8233A ISA Bridge
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
>         Subsystem: VIA Technologies, Inc. VT82C586/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32
>         Interrupt: pin A routed to IRQ 11
>         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=8]
>         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=1]
>         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=8]
>         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [size=1]
>         Region 4: I/O ports at b400 [size=16]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 23) (prog-if 00 [UHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin D routed to IRQ 3
>         Region 4: I/O ports at b800 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 23) (prog-if 00 [UHCI])
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, Cache Line Size: 32 bytes
>         Interrupt: pin D routed to IRQ 3
>         Region 4: I/O ports at bc00 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.5 Multimedia audio controller: VIA Technologies, Inc. VT8233/A/8235/8237 AC97 Audio Controller (rev 40)
>         Subsystem: ABIT Computer Corp. Unknown device 7405
>         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin C routed to IRQ 10
>         Region 0: I/O ports at c000 [size=256]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:13.0 RAID bus controller: Triones Technologies, Inc. HPT374 (rev 07)
>         Subsystem: Triones Technologies, Inc. Unknown device 0001
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 120 (2000ns min, 2000ns max)
>         Interrupt: pin A routed to IRQ 10
>         Region 0: I/O ports at c400 [size=8]
>         Region 1: I/O ports at c800 [size=4]
>         Region 2: I/O ports at cc00 [size=8]
>         Region 3: I/O ports at d000 [size=4]
>         Region 4: I/O ports at d400 [size=256]
>         [virtual] Expansion ROM at 30100000 [disabled] [size=128K]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:13.1 RAID bus controller: Triones Technologies, Inc. HPT374 (rev 07)
>         Subsystem: Triones Technologies, Inc. Unknown device 0001
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 120 (2000ns min, 2000ns max)
>         Interrupt: pin A routed to IRQ 10
>         Region 0: I/O ports at d800 [size=8]
>         Region 1: I/O ports at dc00 [size=4]
>         Region 2: I/O ports at e000 [size=8]
>         Region 3: I/O ports at e400 [size=4]
>         Region 4: I/O ports at e800 [size=256]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 
> [7.6.] SCSI information (from /proc/scsi/scsi)
> 
> Attached devices:
> Host: scsi0 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: SAMSUNG HD501LJ  Rev: CR10
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> Host: scsi1 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: SAMSUNG HD501LJ  Rev: CR10
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> Host: scsi2 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: SAMSUNG HD501LJ  Rev: CR10
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> Host: scsi3 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: SAMSUNG HD501LJ  Rev: CR10
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> 
> 
> [7.7.] Other information that might be relevant to the problem
>        (please look in /proc and include all information that you
>        think to be relevant):
> [X.] Other notes, patches, fixes, workarounds:
> 
> debian etch, no grsec or other kernel/userland patches. Basic system.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
