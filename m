Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E6506B02AB
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 08:34:23 -0400 (EDT)
Message-ID: <4C50233A.4090304@xs4all.nl>
Date: Wed, 28 Jul 2010 14:31:54 +0200
From: The Nimble Byte <tnimble@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [Bug 16415] New: Show_Memory/Shift-ScrollLock triggers "unable
 to handle kernel paging request at 00021c6e"
References: <bug-16415-27@https.bugzilla.kernel.org/> <20100722153443.e266b2d6.akpm@linux-foundation.org> <20100727125428.GY5300@csn.ul.ie>
In-Reply-To: <20100727125428.GY5300@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On 27/07/2010 14:54, Mel Gorman wrote
> BUG: unable to handle kernel paging request at 00021c6e
>
> I was unable to reproduce this on qemu at least (my test machines are
> all occupied). Test case was to force use of highmem (vmalloc=) and
> mount tmpfs with a swapfile in place. A heavy mix off dd writing to
> on-disk and tmpfs-files over the course of 15 minutes triggered nothing
> out of the ordinary. So, whatever is going on here, it's not immediately
> obvious and so I'm afraid I have to make wild stabs in the dark.
> Relevant people cc'd.
This bug (activating show_mem) can be reproduced without the dd on 
tmpfs. From a initial ramdisk containing only a shell, some libraries 
and the following init script:
: #!/bin/sh
: echo Loading....
: sleep 60

Pressing shift+scroll lock during the sleep generates an oops at the 
beginning of the show_mem function also. The issue does thereby not seem 
to be related to any of the kernel code compiled as modules. It pretty 
much rules out tmpfs itself.

> Theory 1
> --------
> Can we eliminate bad hardware as an option? What modules are loaded in this
> machine (lsmod and lspci -v)? Can memtest be run on this machine for a number
> of hours to eliminate bad memory as a possibility? I recognise that 2.6.12.6
> was fine on this machine but it's possible that 2.6.34.1 is stressing the
> machine more for some reason.
The kernel has been run on multiple hardware (similar (not fully 
identical) type though) and memtest86+ has been run for several hours 
without any trouble.

$ lspci -v
:00:00.0 Class 0600: 8086:27ac (rev 03)
:    Subsystem: 8086:27ac
:    Flags: bus master, fast devsel, latency 0
:    Capabilities: [e0] #09 [5109]
:
:00:02.0 Class 0300: 8086:27ae (rev 03)
:    Subsystem: 8086:27ae
:    Flags: bus master, fast devsel, latency 0, IRQ 16
:    Memory at fdf00000 (32-bit, non-prefetchable) [size=512K]
:    I/O ports at ff00 [size=8]
:    Memory at d0000000 (32-bit, prefetchable) [size=256M]
:    Memory at fdf80000 (32-bit, non-prefetchable) [size=256K]
:    Expansion ROM at <unassigned> [disabled]
:    Capabilities: [90] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable-
:    Capabilities: [d0] Power Management version 2
:
:00:1b.0 Class 0403: 8086:27d8 (rev 02)
:    Subsystem: 8086:27d8
:    Flags: bus master, fast devsel, latency 0, IRQ 32
:    Memory at fdff8000 (64-bit, non-prefetchable) [size=16K]
:    Capabilities: [50] Power Management version 2
:    Capabilities: [60] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable+
:    Capabilities: [70] #10 [0091]
:
:00:1c.0 Class 0604: 8086:27d0 (rev 02)
:    Flags: bus master, fast devsel, latency 0
:    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
:    I/O behind bridge: 0000b000-0000bfff
:    Memory behind bridge: fd800000-fd8fffff
:    Prefetchable memory behind bridge: 00000000fd500000-00000000fd500000
:    Capabilities: [40] #10 [0141]
:    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable+
:    Capabilities: [90] #0d [0000]
:    Capabilities: [a0] Power Management version 2
:
:00:1c.1 Class 0604: 8086:27d2 (rev 02)
:    Flags: bus master, fast devsel, latency 0
:    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
:    I/O behind bridge: 0000a000-0000afff
:    Memory behind bridge: fde00000-fdefffff
:    Prefetchable memory behind bridge: 00000000fdd00000-00000000fdd00000
:    Capabilities: [40] #10 [0141]
:    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable+
:    Capabilities: [90] #0d [0000]
:    Capabilities: [a0] Power Management version 2
:
:00:1c.2 Class 0604: 8086:27d4 (rev 02)
:    Flags: bus master, fast devsel, latency 0
:    Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
:    I/O behind bridge: 0000e000-0000efff
:    Memory behind bridge: fdc00000-fdcfffff
:    Prefetchable memory behind bridge: 00000000fdb00000-00000000fdb00000
:    Capabilities: [40] #10 [0141]
:    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable+
:    Capabilities: [90] #0d [0000]
:    Capabilities: [a0] Power Management version 2
:
:00:1c.3 Class 0604: 8086:27d6 (rev 02)
:    Flags: bus master, fast devsel, latency 0
:    Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
:    I/O behind bridge: 0000d000-0000dfff
:    Memory behind bridge: fda00000-fdafffff
:    Prefetchable memory behind bridge: 00000000fd900000-00000000fd900000
:    Capabilities: [40] #10 [0141]
:    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable+
:    Capabilities: [90] #0d [0000]
:    Capabilities: [a0] Power Management version 2
:
:00:1d.0 Class 0c03: 8086:27c8 (rev 02)
:    Subsystem: 8086:27c8
:    Flags: bus master, medium devsel, latency 0, IRQ 23
:    I/O ports at fe00 [size=32]
:
:00:1d.1 Class 0c03: 8086:27c9 (rev 02)
:    Subsystem: 8086:27c9
:    Flags: bus master, medium devsel, latency 0, IRQ 19
:    I/O ports at fd00 [size=32]
:
:00:1d.2 Class 0c03: 8086:27ca (rev 02)
:    Subsystem: 8086:27ca
:    Flags: bus master, medium devsel, latency 0, IRQ 18
:    I/O ports at fc00 [size=32]
:
:00:1d.3 Class 0c03: 8086:27cb (rev 02)
:    Subsystem: 8086:27cb
:    Flags: bus master, medium devsel, latency 0, IRQ 16
:    I/O ports at fb00 [size=32]
:
:00:1d.7 Class 0c03: 8086:27cc (rev 02) (prog-if 20)
:    Subsystem: 8086:27cc
:    Flags: bus master, medium devsel, latency 0, IRQ 23
:    Memory at fdfff000 (32-bit, non-prefetchable) [size=1K]
:    Capabilities: [50] Power Management version 2
:    Capabilities: [58] #0a [20a0]
:
:00:1e.0 Class 0604: 8086:2448 (rev e2) (prog-if 01)
:    Flags: bus master, fast devsel, latency 0
:    Bus: primary=00, secondary=05, subordinate=05, sec-latency=32
:    I/O behind bridge: 0000c000-0000cfff
:    Memory behind bridge: fd700000-fd7fffff
:    Prefetchable memory behind bridge: 00000000fd600000-00000000fd600000
:    Capabilities: [50] #0d [0000]
:
:00:1f.0 Class 0601: 8086:27b9 (rev 02)
:    Subsystem: 8086:27b9
:    Flags: bus master, medium devsel, latency 0
:    Capabilities: [e0] #09 [100c]
:
:00:1f.1 Class 0101: 8086:27df (rev 02) (prog-if 8a [Master SecP PriP])
:    Subsystem: 8086:27df
:    Flags: bus master, medium devsel, latency 0, IRQ 18
:    I/O ports at 01f0 [size=8]
:    I/O ports at 03f4
:    I/O ports at 0170 [size=8]
:    I/O ports at 0374
:    I/O ports at fa00 [size=16]
:
:00:1f.2 Class 0101: 8086:27c4 (rev 02) (prog-if 8f [Master SecP SecO 
PriP PriO])
:    Subsystem: 8086:27c4
:    Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 19
:    I/O ports at f900 [size=8]
:    I/O ports at f800 [size=4]
:    I/O ports at f700 [size=8]
:    I/O ports at f600 [size=4]
:    I/O ports at f500 [size=16]
:    Memory at fdffe000 (32-bit, non-prefetchable) [size=1K]
:    Capabilities: [70] Power Management version 2
:
:00:1f.3 Class 0c05: 8086:27da (rev 02)
:    Subsystem: 8086:27da
:    Flags: medium devsel, IRQ 19
:    I/O ports at 0500 [size=32]
:
:01:00.0 Class 0200: 8086:109a
:    Subsystem: 8086:0000
:    Flags: bus master, fast devsel, latency 0, IRQ 28
:    Memory at fd8e0000 (32-bit, non-prefetchable) [size=128K]
:    I/O ports at bf00 [size=32]
:    Capabilities: [c8] Power Management version 2
:    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable+
:    Capabilities: [e0] #10 [0001]
:
:02:00.0 Class 0200: 8086:109a
:    Subsystem: 8086:0000
:    Flags: bus master, fast devsel, latency 0, IRQ 29
:    Memory at fdee0000 (32-bit, non-prefetchable) [size=128K]
:    I/O ports at af00 [size=32]
:    Capabilities: [c8] Power Management version 2
:    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable+
:    Capabilities: [e0] #10 [0001]
:
:03:00.0 Class 0200: 8086:109a
:    Subsystem: 8086:0000
:    Flags: bus master, fast devsel, latency 0, IRQ 30
:    Memory at fdce0000 (32-bit, non-prefetchable) [size=128K]
:    I/O ports at ef00 [size=32]
:    Capabilities: [c8] Power Management version 2
:    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable+
:    Capabilities: [e0] #10 [0001]
:
:04:00.0 Class 0200: 8086:109a
:    Subsystem: 8086:0000
:    Flags: bus master, fast devsel, latency 0, IRQ 31
:    Memory at fdae0000 (32-bit, non-prefetchable) [size=128K]
:    I/O ports at df00 [size=32]
:    Capabilities: [c8] Power Management version 2
:    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable+
:    Capabilities: [e0] #10 [0001]

$ lsmod
:Module                  Size  Used by
:nf_nat_irc               950  0
:nf_nat_ftp              1136  0
:ipt_MASQUERADE          1200  0
:ipt_REJECT              1546  0
:ipt_REDIRECT             777  0
:xt_state                 894  2
:xt_limit                1097  0
:ipt_LOG                 3840  0
:iptable_nat             2876  1
:nf_nat                 12966  5 
nf_nat_irc,nf_nat_ftp,ipt_MASQUERADE,ipt_REDIRECT,iptable_nat
:iptable_mangle          1115  0
:iptable_filter          1114  1
:nf_conntrack_irc        3095  1 nf_nat_irc
:nf_conntrack_ftp        4557  1 nf_nat_ftp
:nf_conntrack_ipv4       8740  5 iptable_nat,nf_nat
:nf_conntrack           49060  9 
nf_nat_irc,nf_nat_ftp,ipt_MASQUERADE,xt_state,iptable_nat,nf_nat,nf_conntrack_irc,nf_conntrack_ftp,nf_conntrack_ipv4
:nf_defrag_ipv4           853  1 nf_conntrack_ipv4
:ip_tables               8425  3 iptable_nat,iptable_mangle,iptable_filter
:coretemp                3806  0
:snd_hda_codec_via      41668  1
:snd_hda_intel          17946  0
:snd_hda_codec          55665  2 snd_hda_codec_via,snd_hda_intel
:ehci_hcd               39532  0
:uhci_hcd               23218  0
:iTCO_wdt                8739  0
:snd_hwdep               4121  1 snd_hda_codec
:snd_pcm                55679  2 snd_hda_intel,snd_hda_codec
:snd_timer              14219  1 snd_pcm
:usbcore               122021  3 ehci_hcd,uhci_hcd
:e1000e                102961  0
:snd                    40194  6 
snd_hda_codec_via,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_timer
:soundcore               4734  1 snd
:snd_page_alloc          5755  2 snd_hda_intel,snd_pcm
:reiserfs              170135  0

> Theory 2
> --------
> To catch early mistakes in the memory model, can the machine be booted with
> mminit_loglevel=4 and CONFIG_DEBUG_VM set in .config? I am not optimistic
> this is where the problem is though. If we were making mistakes in early
> setup, I'd expect a large volume of bug reports on it.
>    
[    0.000000] Linux version 2.6.34.1 
(root@doeblin.development.xafax.nl) (gcc version 4.2.4) #26 SMP Wed Jul 
28 13:24:34 CEST 2010
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007f690000 (usable)
[    0.000000]  BIOS-e820: 000000007f690000 - 000000007f6e0000 (reserved)
[    0.000000]  BIOS-e820: 000000007f6e0000 - 000000007f6e3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007f6e3000 - 000000007f6f0000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007f6f0000 - 000000007f700000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.2 present.
[    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working 
around it.
[    0.000000] last_pfn = 0x7f690 max_arch_pfn = 0x1000000
[    0.000000] PAT not supported by CPU.
[    0.000000] found SMP MP-table at [c00f38d0] f38d0
[    0.000000] init_memory_mapping: 0000000000000000-0000000037bfe000
[    0.000000] RAMDISK: 37d29000 - 37ff0000
[    0.000000] Allocated new RAMDISK: 00493000 - 007596bb
[    0.000000] Move RAMDISK from 0000000037d29000 - 0000000037fef6ba to 
00493000 - 007596ba
[    0.000000] ACPI: RSDP 000f7c90 00014 (v00 IntelR)
[    0.000000] ACPI: RSDT 7f6e3000 00034 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: FACP 7f6e3080 00074 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: DSDT 7f6e3100 05122 (v01 INTELR AWRDACPI 00001000 
MSFT 03000000)
[    0.000000] ACPI: FACS 7f6e0000 00040
[    0.000000] ACPI: IDTS 7f6e82c0 00028 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: MCFG 7f6e8300 0003C (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: APIC 7f6e8240 00068 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] mminit::memory_register Entering add_active_range(0, 
0x10, 0x9f) 0 entries of 256 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 
0x100, 0x7f690) 1 entries of 256 used
[    0.000000] 1146MB HIGHMEM available.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00037bfe
[    0.000000]   HighMem  0x00037bfe -> 0x0007f690
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007f690
[    0.000000] mminit::pageflags_layout_widths Section 0 Node 0 Zone 2 
Flags 24
[    0.000000] mminit::pageflags_layout_shifts Section 0 Node 0 Zone 2
[    0.000000] mminit::pageflags_layout_offsets Section 0 Node 0 Zone 30
[    0.000000] mminit::pageflags_layout_zoneid Zone ID: 30 -> 32
[    0.000000] mminit::pageflags_layout_usage location: 32 -> 30 unused 
30 -> 24 flags 24 -> 0
[    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns 
16 -> 4096
[    0.000000] mminit::memmap_init Initialising map node 0 zone 1 pfns 
4096 -> 228350
[    0.000000] mminit::memmap_init Initialising map node 0 zone 2 pfns 
228350 -> 521872
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 1 hotplug CPUs
[    0.000000] Allocating PCI resources starting at 7f700000 (gap: 
7f700000:60900000)
[    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 
nr_node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @c2000000 s27348 r0 d21804 
u1048576
[    0.000000] pcpu-alloc: s27348 r0 d21804 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  
Total pages: 517681
[    0.000000] Kernel command line: version=1.8.1 root=LABEL=CFBoot ro 3 
console=ttyS0,115200 console=tty0 mminit_loglevel=4
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 
bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 
bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Subtract (46 early reservations)
[    0.000000]   #1 [0000001000 - 0000002000]   EX TRAMPOLINE
[    0.000000]   #2 [0000100000 - 000048df10]   TEXT DATA BSS
[    0.000000]   #3 [000048e000 - 00004920a6]             BRK
[    0.000000]   #4 [00000f38e0 - 0000100000]   BIOS reserved
[    0.000000]   #5 [00000f38d0 - 00000f38e0]    MP-table mpf
[    0.000000]   #6 [000009f800 - 00000f1ea4]   BIOS reserved
[    0.000000]   #7 [00000f201c - 00000f38d0]   BIOS reserved
[    0.000000]   #8 [00000f1ea4 - 00000f201c]    MP-table mpc
[    0.000000]   #9 [0000010000 - 0000011000]      TRAMPOLINE
[    0.000000]   #10 [0000011000 - 0000015000]     ACPI WAKEUP
[    0.000000]   #11 [0000015000 - 0000016000]         PGTABLE
[    0.000000]   #12 [0000493000 - 000075a000]     NEW RAMDISK
[    0.000000]   #13 [0001000000 - 0001001000]         BOOTMEM
[    0.000000]   #14 [0001001000 - 0001ff1000]         BOOTMEM
[    0.000000]   #15 [0001ff1000 - 0001ff1004]         BOOTMEM
[    0.000000]   #16 [0001ff1040 - 0001ff1100]         BOOTMEM
[    0.000000]   #17 [0001ff1100 - 0001ff1154]         BOOTMEM
[    0.000000]   #18 [0001ff1180 - 0001ff4180]         BOOTMEM
[    0.000000]   #19 [0001ff4180 - 0001ff41ec]         BOOTMEM
[    0.000000]   #20 [0001ff4200 - 0001ffa200]         BOOTMEM
[    0.000000]   #21 [0001ffa200 - 0001ffa22f]         BOOTMEM
[    0.000000]   #22 [0001ffa240 - 0001ffa3cc]         BOOTMEM
[    0.000000]   #23 [0001ffa400 - 0001ffa440]         BOOTMEM
[    0.000000]   #24 [0001ffa440 - 0001ffa480]         BOOTMEM
[    0.000000]   #25 [0001ffa480 - 0001ffa4c0]         BOOTMEM
[    0.000000]   #26 [0001ffa4c0 - 0001ffa500]         BOOTMEM
[    0.000000]   #27 [0001ffa500 - 0001ffa540]         BOOTMEM
[    0.000000]   #28 [0001ffa540 - 0001ffa580]         BOOTMEM
[    0.000000]   #29 [0001ffa580 - 0001ffa5c0]         BOOTMEM
[    0.000000]   #30 [0001ffa5c0 - 0001ffa600]         BOOTMEM
[    0.000000]   #31 [0001ffa600 - 0001ffa640]         BOOTMEM
[    0.000000]   #32 [0001ffa640 - 0001ffa680]         BOOTMEM
[    0.000000]   #33 [0001ffa680 - 0001ffa6d9]         BOOTMEM
[    0.000000]   #34 [0001ffa700 - 0001ffa759]         BOOTMEM
[    0.000000]   #35 [0002000000 - 000200c000]         BOOTMEM
[    0.000000]   #36 [0002100000 - 000210c000]         BOOTMEM
[    0.000000]   #37 [0001ffc780 - 0001ffc784]         BOOTMEM
[    0.000000]   #38 [0001ffc7c0 - 0001ffc7c4]         BOOTMEM
[    0.000000]   #39 [0001ffc800 - 0001ffc808]         BOOTMEM
[    0.000000]   #40 [0001ffc840 - 0001ffc848]         BOOTMEM
[    0.000000]   #41 [0001ffc880 - 0001ffc920]         BOOTMEM
[    0.000000]   #42 [0001ffc940 - 0001ffc988]         BOOTMEM
[    0.000000]   #43 [000200c000 - 0002010000]         BOOTMEM
[    0.000000]   #44 [0002010000 - 0002090000]         BOOTMEM
[    0.000000]   #45 [0002090000 - 00020d0000]         BOOTMEM
[    0.000000] Initializing HighMem for node 0 (00037bfe:0007f690)
[    0.000000] Memory: 2063260k/2087488k available (2167k kernel code, 
23776k reserved, 951k data, 332k init, 1174088k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff91000 - 0xfffff000   ( 440 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xf83fe000 - 0xffbfe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf7bfe000   ( 891 MB)
[    0.000000]       .init : 0xc130c000 - 0xc135f000   ( 332 kB)
[    0.000000]       .data : 0xc031dd65 - 0xc040bc80   ( 951 kB)
[    0.000000]       .text : 0xc0100000 - 0xc031dd65   (2167 kB)
[    0.000000] Checking if this processor honours the WP bit even in 
supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:320
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1862.032 MHz processor.
[    0.012006] Calibrating delay loop (skipped), value calculated using 
timer frequency.. 3724.06 BogoMIPS (lpj=7448128)
[    0.020230] Mount-cache hash table entries: 512
[    0.024359] mce: CPU supports 6 MCE banks
[    0.028015] CPU0: Thermal monitoring enabled (TM1)
[    0.032005] using mwait in idle threads.
[    0.036011] Performance Events: Core events, core PMU driver.
[    0.044004] ... version:                1
[    0.048003] ... bit width:              40
[    0.052003] ... generic registers:      2
[    0.056003] ... value mask:             000000ffffffffff
[    0.060003] ... max period:             000000007fffffff
[    0.064003] ... fixed-purpose events:   0
[    0.068003] ... event mask:             0000000000000003
[    0.072012] Checking 'hlt' instruction... OK.
[    0.092892] SMP alternatives: switching to UP code
[    0.102137] ACPI: Core revision 20100121
[    0.120095] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.124375] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.168897] CPU0: Intel(R) Celeron(R) M CPU        440  @ 1.86GHz 
stepping 0c
[    0.180000] Brought up 1 CPUs
[    0.180000] Total of 1 processors activated (3724.06 BogoMIPS).
[    0.180191] devtmpfs: initialized
[    0.184844] NET: Registered protocol family 16
[    0.188948] ACPI: bus type pci registered
[    0.192277] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.196027] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.200001] PCI: Using MMCONFIG for extended config space
[    0.204001] PCI: Using configuration type 1 for base access
[    0.219321] bio: create slab <bio-0> at 0
[    0.236806] ACPI: Interpreter enabled
[    0.240012] ACPI: (supports S0 S1 S5)
[    0.244368] ACPI: Using IOAPIC for interrupt routing
[    0.267171] ACPI: No dock devices found.
[    0.268050] PCI: Using host bridge windows from ACPI; if necessary, 
use "pci=nocrs" and report a bug
[    0.272197] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.276463] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.280010] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.284003] pci_root PNP0A08:00: host bridge window [mem 
0x000a0000-0x000bffff]
[    0.288003] pci_root PNP0A08:00: host bridge window [mem 
0x000c0000-0x000dffff]
[    0.292003] pci_root PNP0A08:00: host bridge window [mem 
0x7f750000-0xfebfffff]
[    0.297154] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by 
ICH6 ACPI/GPIO/TCO
[    0.300004] pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by 
ICH6 GPIO
[    0.304004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 
0800 (mask 003f)
[    0.308004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 
0290 (mask 0007)
[    0.312004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 
02f0 (mask 000f)
[    0.316557] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.320285] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.324284] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.328289] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.332102] pci 0000:00:1e.0: PCI bridge to [bus 05-05] (subtractive 
decode)
[    0.366590] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 *10 11 12 
14 15)
[    0.374452] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 7 9 10 11 12 
14 15)
[    0.382371] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12 
14 15)
[    0.390221] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 11 12 
14 *15)
[    0.398229] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.407493] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.412446] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.421932] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 *7 9 10 11 12 
14 15)
[    0.430149] vgaarb: device added: 
PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.432020] vgaarb: loaded
[    0.436626] SCSI subsystem initialized
[    0.440689] PCI: Using ACPI for IRQ routing
[    0.444644] HPET: 3 timers in total, 0 timers will be used for 
per-cpu timer
[    0.452035] Switching to clocksource tsc
[    0.456184] pnp: PnP ACPI init
[    0.459331] ACPI: bus type pnp registered
[    0.470105] pnp: PnP ACPI: found 13 devices
[    0.474404] ACPI: ACPI bus type pnp unregistered
[    0.479119] system 00:01: [io  0x04d0-0x04d1] has been reserved
[    0.485131] system 00:01: [io  0x0290-0x029f] has been reserved
[    0.491144] system 00:01: [io  0x0880-0x088f] has been reserved
[    0.497168] system 00:09: [io  0x0400-0x04bf] could not be reserved
[    0.503533] system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
[    0.510249] system 00:0c: [mem 0x000f0000-0x000fffff] could not be 
reserved
[    0.517301] system 00:0c: [mem 0x7f6e0000-0x7f6fffff] could not be 
reserved
[    0.524355] system 00:0c: [mem 0x00000000-0x0009ffff] could not be 
reserved
[    0.531411] system 00:0c: [mem 0x00100000-0x7f6dffff] could not be 
reserved
[    0.538463] system 00:0c: [mem 0xfec00000-0xfec00fff] could not be 
reserved
[    0.545518] system 00:0c: [mem 0xfed13000-0xfed1dfff] has been reserved
[    0.552218] system 00:0c: [mem 0xfed20000-0xfed8ffff] has been reserved
[    0.558925] system 00:0c: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.565632] system 00:0c: [mem 0xffb00000-0xffb7ffff] has been reserved
[    0.572341] system 00:0c: [mem 0xfff00000-0xffffffff] has been reserved
[    0.579050] system 00:0c: [mem 0x000e0000-0x000effff] has been reserved
[    0.621696] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.627020] pci 0000:00:1c.0:   bridge window [io  0xb000-0xbfff]
[    0.633210] pci 0000:00:1c.0:   bridge window [mem 0xfd800000-0xfd8fffff]
[    0.640087] pci 0000:00:1c.0:   bridge window [mem 
0xfd500000-0xfd5fffff 64bit pref]
[    0.647977] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.653294] pci 0000:00:1c.1:   bridge window [io  0xa000-0xafff]
[    0.659475] pci 0000:00:1c.1:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.666357] pci 0000:00:1c.1:   bridge window [mem 
0xfdd00000-0xfddfffff 64bit pref]
[    0.674245] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.679555] pci 0000:00:1c.2:   bridge window [io  0xe000-0xefff]
[    0.685745] pci 0000:00:1c.2:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.692625] pci 0000:00:1c.2:   bridge window [mem 
0xfdb00000-0xfdbfffff 64bit pref]
[    0.700513] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.705832] pci 0000:00:1c.3:   bridge window [io  0xd000-0xdfff]
[    0.712021] pci 0000:00:1c.3:   bridge window [mem 0xfda00000-0xfdafffff]
[    0.718903] pci 0000:00:1c.3:   bridge window [mem 
0xfd900000-0xfd9fffff 64bit pref]
[    0.726789] pci 0000:00:1e.0: PCI bridge to [bus 05-05]
[    0.732108] pci 0000:00:1e.0:   bridge window [io  0xc000-0xcfff]
[    0.738288] pci 0000:00:1e.0:   bridge window [mem 0xfd700000-0xfd7fffff]
[    0.745169] pci 0000:00:1e.0:   bridge window [mem 
0xfd600000-0xfd6fffff 64bit pref]
[    0.753064] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.759872] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.766673] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.773478] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.780438] NET: Registered protocol family 2
[    0.784978] IP route cache hash table entries: 32768 (order: 5, 
131072 bytes)
[    0.792486] TCP established hash table entries: 131072 (order: 8, 
1048576 bytes)
[    0.800788] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.807884] TCP: Hash tables configured (established 131072 bind 65536)
[    0.814599] TCP reno registered
[    0.817831] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.823856] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.830480] NET: Registered protocol family 1
[    0.835662] Trying to unpack rootfs image as initramfs...
[    0.946856] Freeing initrd memory: 2844k freed
[    0.955856] highmem bounce pool size: 64 pages
[    0.960863] msgmni has been set to 1742
[    0.964935] Block layer SCSI generic (bsg) driver version 0.4 loaded 
(major 253)
[    0.972479] io scheduler noop registered
[    0.976486] io scheduler deadline registered
[    0.980871] io scheduler cfq registered (default)
[    0.987915] pcieport 0000:00:1c.0: Requesting control of PCIe PME 
from ACPI BIOS
[    0.995467] pcieport 0000:00:1c.0: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.004485] pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
[    1.011277] pcieport 0000:00:1c.1: Requesting control of PCIe PME 
from ACPI BIOS
[    1.018814] pcieport 0000:00:1c.1: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.027827] pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
[    1.034624] pcieport 0000:00:1c.2: Requesting control of PCIe PME 
from ACPI BIOS
[    1.042161] pcieport 0000:00:1c.2: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.051176] pcie_pme: probe of 0000:00:1c.2:pcie01 failed with error -13
[    1.057972] pcieport 0000:00:1c.3: Requesting control of PCIe PME 
from ACPI BIOS
[    1.065508] pcieport 0000:00:1c.3: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.074522] pcie_pme: probe of 0000:00:1c.3:pcie01 failed with error -13
[    1.088016] isapnp: Scanning for PnP cards...
[    1.371961] Switched to NOHz mode on CPU #0
[    1.450179] isapnp: No Plug & Play device found
[    1.539158] Linux agpgart interface v0.103
[    1.543720] agpgart-intel 0000:00:00.0: Intel 945GME Chipset
[    1.549863] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    1.559170] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    1.566570] ipmi message handler version 39.2
[    1.571042] IPMI Watchdog: driver initialized
[    1.575491] Copyright (C) 2004 MontaVista Software - IPMI Powerdown 
via sys_reboot.
[    1.583285] Serial: 8250/16550 driver, 8 ports, IRQ sharing enabled
[    1.844141] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.104138] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.112152] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.118346] 00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.132969] brd: module loaded
[    2.136786] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) 
-> IRQ 18
[    2.144342] scsi0 : ata_piix
[    2.147544] scsi1 : ata_piix
[    2.151992] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xfa00 
irq 14
[    2.159058] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xfa08 
irq 15
[    2.166130] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    2.173364] ata_piix 0000:00:1f.2: MAP [ P0 P2 -- -- ]
[    2.332309] scsi2 : ata_piix
[    2.335447] scsi3 : ata_piix
[    2.339839] ata3: SATA max UDMA/133 cmd 0xf900 ctl 0xf800 bmdma 
0xf500 irq 19
[    2.347075] ata4: SATA max UDMA/133 cmd 0xf700 ctl 0xf600 bmdma 
0xf508 irq 19
[    2.354713] ata1.00: ATA-10: SanDisk SDCFB-256, HDX 2.15, max MWDMA2
[    2.361168] ata1.00: 501760 sectors, multi 0: LBA
[    2.366815] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    2.373089] PNP: PS/2 appears to have AUX port disabled, if this is 
incorrect please boot with i8042.nopnp
[    2.383237] ata1.00: configured for MWDMA2
[    2.387617] scsi 0:0:0:0: Direct-Access     ATA      SanDisk SDCFB-25 
HDX  PQ: 0 ANSI: 5
[    2.397131] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.402663] sd 0:0:0:0: [sda] 501760 512-byte logical blocks: (256 
MB/245 MiB)
[    2.410213] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.415996] sd 0:0:0:0: [sda] Write Protect is off
[    2.421265] mice: PS/2 mouse device common for all mice
[    2.426696] sd 0:0:0:0: [sda] Write cache: disabled, read cache: 
enabled, doesn't support DPO or FUA
[    2.436505] input: PC Speaker as /class/input/input0
[    2.441833]  sda:
[    2.443773] I2O subsystem v1.325
[    2.447399] i2o: max drivers = 8
[    2.450782]  sda1 sda2
[    2.454331] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.459128] rtc_cmos 00:03: RTC can wake from S4
[    2.464098] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    2.470325] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
[    2.476883] i2c /dev entries driver
[    2.480693] cpuidle: using governor ladder
[    2.484886] cpuidle: using governor menu
[    2.489274] TCP cubic registered
[    2.492601] NET: Registered protocol family 17
[    2.497141] Using IPI No-Shortcut mode
[    2.501150] input: AT Translated Set 2 keyboard as /class/input/input1
[    2.508568] rtc_cmos 00:03: setting system clock to 2010-07-28 
11:58:10 UTC (1280318290)
[    2.516814] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    2.522915] EDD information not available.
[    2.549277] ata3.01: ATA-8: FUJITSU MHY2060BH, 0000000C, max UDMA/100
[    2.555814] ata3.01: 117210240 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    2.576185] ata3.01: configured for UDMA/100
[    2.580692] scsi 2:0:1:0: Direct-Access     ATA      FUJITSU MHY2060B 
0000 PQ: 0 ANSI: 5
[    2.589387] sd 2:0:1:0: [sdb] 117210240 512-byte logical blocks: 
(60.0 GB/55.8 GiB)
[    2.597468] sd 2:0:1:0: Attached scsi generic sg1 type 0
[    2.603084] sd 2:0:1:0: [sdb] Write Protect is off
[    2.609094] sd 2:0:1:0: [sdb] Write cache: enabled, read cache: 
enabled, doesn't support DPO or FUA
[    2.618551]  sdb: sdb1
[    2.621878] sd 2:0:1:0: [sdb] Attached SCSI disk
[    2.626603] Freeing unused kernel memory: 332k freed
[    2.631867] Write protecting the kernel text: 2168k
[    2.636856] Write protecting the kernel read-only data: 768k
[    7.781473] input: Power Button as /class/input/input2
[    7.786940] ACPI: Power Button [PWRB]
[    7.790832] input: Sleep Button as /class/input/input3
[    7.796174] ACPI: Sleep Button [SLPB]
[    7.800101] input: Power Button as /class/input/input4
[    7.805427] ACPI: Power Button [PWRF]
[    8.079306] thermal LNXTHERM:00: registered as thermal_zone0
[    8.085126] ACPI: Thermal Zone [TZ00] (0 C)
[    8.205372] thermal LNXTHERM:02: registered as thermal_zone1
[    8.211167] ACPI: Thermal Zone [THRM] (40 C)
[    8.312267] ACPI: Fan [FAN] (on)
[    8.380517] usbcore: registered new interface driver usbfs
[    8.386203] usbcore: registered new interface driver hub
[    8.410155] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[    8.416185] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[    8.422329] e1000e 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> 
IRQ 16
[    8.429845] e1000e 0000:01:00.0: Disabling ASPM L0s
[    8.495118] iTCO_vendor_support: vendor-support=0
[    8.505284] i801_smbus 0000:00:1f.3: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    8.563396] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
[    8.569259] iTCO_wdt: Found a ICH7-M or ICH7-U TCO device (Version=2, 
TCOBASE=0x0460)
[    8.577435] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    8.690684] usbcore: registered new device driver usb
[    8.717787] uhci_hcd: USB Universal Host Controller Interface driver
[    8.724316] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) 
-> IRQ 23
[    8.731562] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    8.736919] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned 
bus number 1
[    8.744505] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fe00
[    8.750789] hub 1-0:1.0: USB hub found
[    8.754634] hub 1-0:1.0: 2 ports detected
[    8.758909] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    8.766149] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    8.771484] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned 
bus number 2
[    8.779054] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000fd00
[    8.785216] hub 2-0:1.0: USB hub found
[    8.789064] hub 2-0:1.0: 2 ports detected
[    8.793333] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) 
-> IRQ 18
[    8.800570] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    8.805898] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned 
bus number 3
[    8.813483] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000fc00
[    8.819639] hub 3-0:1.0: USB hub found
[    8.823486] hub 3-0:1.0: 2 ports detected
[    8.827765] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) 
-> IRQ 16
[    8.835022] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    8.840350] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned 
bus number 4
[    8.847931] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000fb00
[    8.854096] hub 4-0:1.0: USB hub found
[    8.857947] hub 4-0:1.0: 2 ports detected
[    8.870284] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    8.876913] Warning! ehci_hcd should always be loaded before uhci_hcd 
and ohci_hcd, not after
[    8.885618] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) 
-> IRQ 23
[    8.892874] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    8.898203] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned 
bus number 5
[    8.905802] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    8.912173] ehci_hcd 0000:00:1d.7: debug port 1
[    8.920686] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfdfff000
[    9.012922] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    9.019234] hub 5-0:1.0: USB hub found
[    9.023094] hub 5-0:1.0: 8 ports detected
[    9.038452] 0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:29
[    9.046006] 0000:01:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    9.052523] 0000:01:00.0: eth0: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    9.058827] e1000e 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> 
IRQ 17
[    9.066664] e1000e 0000:02:00.0: Disabling ASPM L0s
[    9.188605] 0000:02:00.0: eth1: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2a
[    9.196151] 0000:02:00.0: eth1: Intel(R) PRO/1000 Network Connection
[    9.202668] 0000:02:00.0: eth1: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    9.208978] e1000e 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> 
IRQ 18
[    9.216810] e1000e 0000:03:00.0: Disabling ASPM L0s
[    9.341096] 0000:03:00.0: eth2: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2b
[    9.348639] 0000:03:00.0: eth2: Intel(R) PRO/1000 Network Connection
[    9.355156] 0000:03:00.0: eth2: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    9.361461] e1000e 0000:04:00.0: PCI INT A -> GSI 19 (level, low) -> 
IRQ 19
[    9.369282] e1000e 0000:04:00.0: Disabling ASPM L0s
[    9.492688] 0000:04:00.0: eth3: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2c
[    9.500224] 0000:04:00.0: eth3: Intel(R) PRO/1000 Network Connection
[    9.506741] 0000:04:00.0: eth3: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[   11.810754] ip_tables: (C) 2000-2006 Netfilter Core Team
[   11.844566] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   11.850883] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. 
Please use
[   11.858426] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack 
module option or
[   11.866483] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[   17.178179] Mem-Info:
[   17.180590] DMA per-cpu:
[   17.182169] CPU    0: hi:    0, btch:   1 usd:   0
[   17.182169] Normal per-cpu:
[   17.182169] CPU    0: hi:  186, btch:  31 usd: 116
[   17.182169] HighMem per-cpu:
[   17.182169] CPU    0: hi:  186, btch:  31 usd:  71
[   17.182169] active_anon:935 inactive_anon:125 isolated_anon:0
[   17.182169]  active_file:1053 inactive_file:1801 isolated_file:0
[   17.182169]  unevictable:0 dirty:0 writeback:0 unstable:0
[   17.182169]  free:509562 slab_reclaimable:624 slab_unreclaimable:1463
[   17.182169]  mapped:621 shmem:203 pagetables:51 bounce:0
[   17.182169] DMA free:12248kB min:64kB low:80kB high:96kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   17.182169] lowmem_reserve[]: 0 869 2006 2006
[   17.182169] Normal free:867288kB min:3736kB low:4668kB high:5604kB 
active_anon:0kB inactive_anon:0kB active_file:568kB inactive_file:684kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:890008kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:2496kB slab_unreclaimable:5852kB kernel_stack:328kB 
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   17.182169] lowmem_reserve[]: 0 0 9100 9100
[   17.182169] HighMem free:1158712kB min:512kB low:1732kB high:2956kB 
active_anon:3740kB inactive_anon:500kB active_file:3644kB 
inactive_file:6520kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:1164912kB mlocked:0kB dirty:0kB writeback:0kB 
mapped:2484kB shmem:812kB slab_reclaimable:0kB slab_unreclaimable:0kB 
kernel_stack:0kB pagetables:204kB unstable:0kB bounce:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   17.182169] lowmem_reserve[]: 0 0 0 0
[   17.182169] DMA: 2*4kB 2*8kB 2*16kB 3*32kB 1*64kB 2*128kB 2*256kB 
0*512kB 1*1024kB 1*2048kB 2*4096kB = 12248kB
[   17.182169] Normal: 10*4kB 18*8kB 8*16kB 7*32kB 3*64kB 4*128kB 
3*256kB 2*512kB 2*1024kB 3*2048kB 209*4096kB = 867288kB
[   17.182169] HighMem: 2*4kB 2*8kB 4*16kB 5*32kB 3*64kB 1*128kB 4*256kB 
4*512kB 2*1024kB 1*2048kB 281*4096kB = 1158712kB
[   17.182169] 3057 total pagecache pages
[   17.182169] 0 pages in swap cache
[   17.182169] Swap cache stats: add 0, delete 0, find 0/0
[   17.182169] Free swap  = 0kB
[   17.182169] Total swap = 0kB
[   17.182169] BUG: unable to handle kernel paging request at 4c4fe4ad
[   17.182169] IP: [<c01d8a07>] show_mem+0xbf/0x15c
[   17.182169] *pdpt = 00000000368ed001 *pde = 0000000000000000
[   17.182169] Oops: 0000 [#1] SMP
[   17.182169] last sysfs file: /sys/kernel/uevent_seqnum
[   17.182169] Modules linked in: nf_nat_irc nf_nat_ftp ipt_MASQUERADE 
ipt_REJECT ipt_REDIRECT xt_state xt_limit ipt_LOG iptable_nat nf_nat 
iptable_mangle iptable_filter nf_conntrack_irc nf_conntrack_ftp 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables 
coretemp ehci_hcd uhci_hcd iTCO_wdt i2c_i801 iTCO_vendor_support e1000e 
usbcore fan thermal processor button evdev nls_iso8859_1
[   17.182169]
[   17.182169] Pid: 0, comm: swapper Not tainted 2.6.34.1 #26 
945GM/E-ITE8712/945GM/E-ITE8712
[   17.182169] EIP: 0060:[<c01d8a07>] EFLAGS: 00010002 CPU: 0
[   17.182169] EIP is at show_mem+0xbf/0x15c
[   17.182169] EAX: 4c4fe4a9 EBX: 00018580 ECX: 00000001 EDX: c130c000
[   17.182169] ESI: 00018570 EDI: c0407900 EBP: c03dfdc8 ESP: c03dfda8
[   17.182169]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   17.182169] Process swapper (pid: 0, ti=c03de000 task=c03edea0 
task.ti=c03de000)
[   17.182169] Stack:
[   17.182169]  00018570 0000147f 0000006d 00000000 00000000 f7409cd0 
00000046 c03ff203
[   17.182169] <0> c03dfdd0 c0232951 c03dfddc c0231e80 00000002 c03dfe10 
c023336b f6d34d88
[   17.182169] <0> 010200b4 f7409cd0 f7409cd0 00000001 00000001 00000000 
0000f203 f6ce33f0
[   17.182169] Call Trace:
[   17.182169]  [<c0232951>] ? fn_show_mem+0x8/0xa
[   17.182169]  [<c0231e80>] ? k_spec+0x33/0x36
[   17.182169]  [<c023336b>] ? kbd_event+0x515/0x57e
[   17.182169]  [<c02817e3>] ? input_pass_event+0x63/0x9e
[   17.182169]  [<c0282a62>] ? input_handle_event+0x357/0x360
[   17.182169]  [<c0283805>] ? input_event+0x4b/0x5e
[   17.182169]  [<c0286610>] ? atkbd_interrupt+0x45e/0x536
[   17.182169]  [<c027f02b>] ? serio_interrupt+0x30/0x66
[   17.182169]  [<c027fe6c>] ? i8042_interrupt+0x25e/0x271
[   17.182169]  [<c013d233>] ? sched_clock_tick+0x6d/0x72
[   17.182169]  [<c014c011>] ? handle_IRQ_event+0x24/0x9e
[   17.182169]  [<c014d952>] ? handle_edge_irq+0xb4/0x116
[   17.182169]  [<c010441e>] ? handle_irq+0x1a/0x24
[   17.182169]  [<c0103cc0>] ? do_IRQ+0x40/0x9b
[   17.182169]  [<c0102c29>] ? common_interrupt+0x29/0x30
[   17.182169]  [<c010868f>] ? mwait_idle+0x4c/0x52
[   17.182169]  [<c01018dc>] ? cpu_idle+0x44/0x5d
[   17.182169]  [<c030c8e6>] ? rest_init+0x62/0x64
[   17.182169]  [<c040c8a9>] ? start_kernel+0x29b/0x2a0
[   17.182169]  [<c040c0b3>] ? i386_start_kernel+0xb3/0xb8
[   17.182169] Code: c0 09 00 00 75 0c 83 3d e4 d7 47 c0 02 75 03 ff 45 
f0 f6 c5 04 74 05 ff 45 e4 eb 3d c1 e9 0f 83 e1 01 75 04 89 d0 eb 03 8b 
42 0c <8b> 40 04 48 75 05 ff 45 ec eb 23 85 c9 89 d0 74 03 8b 42 0c 8b
[   17.182169] EIP: [<c01d8a07>] show_mem+0xbf/0x15c SS:ESP 0068:c03dfda8
[   17.182169] CR2: 000000004c4fe4ad
[   17.182169] ---[ end trace 4ffc5fbb4005ae74 ]---
[   17.182169] Kernel panic - not syncing: Fatal exception in interrupt
[   17.182169] Pid: 0, comm: swapper Tainted: G      D    2.6.34.1 #26
[   17.182169] Call Trace:
[   17.182169]  [<c0129133>] panic+0x3e/0xa8
[   17.182169]  [<c0105093>] oops_end+0x6f/0x7d
[   17.182169]  [<c0119583>] no_context+0x153/0x15d
[   17.182169]  [<c0170982>] ? show_swap_cache_info+0x5e/0x62
[   17.182169]  [<c0119715>] __bad_area_nosemaphore+0xe5/0xed
[   17.182169]  [<c0119781>] bad_area_nosemaphore+0xd/0x10
[   17.182169]  [<c0119a0e>] do_page_fault+0x13c/0x2ea
[   17.182169]  [<c01198d2>] ? do_page_fault+0x0/0x2ea
[   17.182169]  [<c031d176>] error_code+0x66/0x6c
[   17.182169]  [<c01198d2>] ? do_page_fault+0x0/0x2ea
[   17.182169]  [<c01d8a07>] ? show_mem+0xbf/0x15c
[   17.182169]  [<c0232951>] fn_show_mem+0x8/0xa
[   17.182169]  [<c0231e80>] k_spec+0x33/0x36
[   17.182169]  [<c023336b>] kbd_event+0x515/0x57e
[   17.182169]  [<c02817e3>] input_pass_event+0x63/0x9e
[   17.182169]  [<c0282a62>] input_handle_event+0x357/0x360
[   17.182169]  [<c0283805>] input_event+0x4b/0x5e
[   17.182169]  [<c0286610>] atkbd_interrupt+0x45e/0x536
[   17.182169]  [<c027f02b>] serio_interrupt+0x30/0x66
[   17.182169]  [<c027fe6c>] i8042_interrupt+0x25e/0x271
[   17.182169]  [<c013d233>] ? sched_clock_tick+0x6d/0x72
[   17.182169]  [<c014c011>] handle_IRQ_event+0x24/0x9e
[   17.182169]  [<c014d952>] handle_edge_irq+0xb4/0x116
[   17.182169]  [<c010441e>] handle_irq+0x1a/0x24
[   17.182169]  [<c0103cc0>] do_IRQ+0x40/0x9b
[   17.182169]  [<c0102c29>] common_interrupt+0x29/0x30
[   17.182169]  [<c010868f>] ? mwait_idle+0x4c/0x52
[   17.182169]  [<c01018dc>] cpu_idle+0x44/0x5d
[   17.182169]  [<c030c8e6>] rest_init+0x62/0x64
[   17.182169]  [<c040c8a9>] start_kernel+0x29b/0x2a0
[   17.182169]  [<c040c0b3>] i386_start_kernel+0xb3/0xb8

> Theory 3
> --------
> I see this message early in boot
> Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.
>
> Is there any possibility that the wrong range of memory is being reserved
> and in fact the BIOS is screwing with the region of memory memmap is stored in?
Can't be fully ruled out indeed, since during memtest86+ no kernel with 
ACPI loaded has been loaded the BIOS may very well be less active or be 
inactive. And thus not showing any memory changes caused by BIOS RAM usage.
>
> Theory 4
> --------
>
> with the early boot changes, is there any possibility that bootmem used the
> low 64K? To test the theory, can the kernel be rebuilt with CONFIG_NO_BOOTMEM
> *not* set to use the older bootmem logic?
[    0.000000] Linux version 2.6.34.1 
(root@doeblin.development.xafax.nl) (gcc version 4.2.4) #27 SMP Wed Jul 
28 14:19:36 CEST 2010
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007f690000 (usable)
[    0.000000]  BIOS-e820: 000000007f690000 - 000000007f6e0000 (reserved)
[    0.000000]  BIOS-e820: 000000007f6e0000 - 000000007f6e3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007f6e3000 - 000000007f6f0000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007f6f0000 - 000000007f700000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.2 present.
[    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working 
around it.
[    0.000000] last_pfn = 0x7f690 max_arch_pfn = 0x1000000
[    0.000000] PAT not supported by CPU.
[    0.000000] found SMP MP-table at [c00f38d0] f38d0
[    0.000000] init_memory_mapping: 0000000000000000-0000000037bfe000
[    0.000000] RAMDISK: 37d29000 - 37ff0000
[    0.000000] Allocated new RAMDISK: 00494000 - 0075a6bb
[    0.000000] Move RAMDISK from 0000000037d29000 - 0000000037fef6ba to 
00494000 - 0075a6ba
[    0.000000] ACPI: RSDP 000f7c90 00014 (v00 IntelR)
[    0.000000] ACPI: RSDT 7f6e3000 00034 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: FACP 7f6e3080 00074 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: DSDT 7f6e3100 05122 (v01 INTELR AWRDACPI 00001000 
MSFT 03000000)
[    0.000000] ACPI: FACS 7f6e0000 00040
[    0.000000] ACPI: IDTS 7f6e82c0 00028 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: MCFG 7f6e8300 0003C (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] ACPI: APIC 7f6e8240 00068 (v01 IntelR AWRDACPI 42302E31 
AWRD 00000000)
[    0.000000] mminit::memory_register Entering add_active_range(0, 
0x10, 0x9f) 0 entries of 256 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 
0x100, 0x7f690) 1 entries of 256 used
[    0.000000] 1146MB HIGHMEM available.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000]   node 0 low ram: 00000000 - 37bfe000
[    0.000000]   node 0 bootmap 00016000 - 0001cf80
[    0.000000] (13/32 early reservations) ==> bootmem [0000000000 - 
0037bfe000]
[    0.000000]   #0 [0000001000 - 0000002000]    EX TRAMPOLINE ==> 
[0000001000 - 0000002000]
[    0.000000]   #1 [0000100000 - 000048ef10]    TEXT DATA BSS ==> 
[0000100000 - 000048ef10]
[    0.000000]   #2 [000048f000 - 00004930a6]              BRK ==> 
[000048f000 - 00004930a6]
[    0.000000]   #3 [00000f38e0 - 0000100000]    BIOS reserved ==> 
[00000f38e0 - 0000100000]
[    0.000000]   #4 [00000f38d0 - 00000f38e0]     MP-table mpf ==> 
[00000f38d0 - 00000f38e0]
[    0.000000]   #5 [000009f800 - 00000f1ea4]    BIOS reserved ==> 
[000009f800 - 00000f1ea4]
[    0.000000]   #6 [00000f201c - 00000f38d0]    BIOS reserved ==> 
[00000f201c - 00000f38d0]
[    0.000000]   #7 [00000f1ea4 - 00000f201c]     MP-table mpc ==> 
[00000f1ea4 - 00000f201c]
[    0.000000]   #8 [0000010000 - 0000011000]       TRAMPOLINE ==> 
[0000010000 - 0000011000]
[    0.000000]   #9 [0000011000 - 0000015000]      ACPI WAKEUP ==> 
[0000011000 - 0000015000]
[    0.000000]   #10 [0000015000 - 0000016000]          PGTABLE ==> 
[0000015000 - 0000016000]
[    0.000000]   #11 [0000494000 - 000075b000]      NEW RAMDISK ==> 
[0000494000 - 000075b000]
[    0.000000]   #12 [0000016000 - 000001d000]          BOOTMAP ==> 
[0000016000 - 000001d000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00037bfe
[    0.000000]   HighMem  0x00037bfe -> 0x0007f690
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007f690
[    0.000000] mminit::pageflags_layout_widths Section 0 Node 0 Zone 2 
Flags 24
[    0.000000] mminit::pageflags_layout_shifts Section 0 Node 0 Zone 2
[    0.000000] mminit::pageflags_layout_offsets Section 0 Node 0 Zone 30
[    0.000000] mminit::pageflags_layout_zoneid Zone ID: 30 -> 32
[    0.000000] mminit::pageflags_layout_usage location: 32 -> 30 unused 
30 -> 24 flags 24 -> 0
[    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns 
16 -> 4096
[    0.000000] mminit::memmap_init Initialising map node 0 zone 1 pfns 
4096 -> 228350
[    0.000000] mminit::memmap_init Initialising map node 0 zone 2 pfns 
228350 -> 521872
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 1 hotplug CPUs
[    0.000000] Allocating PCI resources starting at 7f700000 (gap: 
7f700000:60900000)
[    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 
nr_node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @c2000000 s27348 r0 d21804 
u1048576
[    0.000000] pcpu-alloc: s27348 r0 d21804 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  
Total pages: 517681
[    0.000000] Kernel command line: version=1.8.1 root=LABEL=CFBoot ro 3 
console=ttyS0,115200 console=tty0 mminit_loglevel=4
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 
bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 
bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00037bfe:0007f690)
[    0.000000] Memory: 2063248k/2087488k available (2167k kernel code, 
23788k reserved, 951k data, 336k init, 1174088k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff91000 - 0xfffff000   ( 440 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xf83fe000 - 0xffbfe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf7bfe000   ( 891 MB)
[    0.000000]       .init : 0xc130c000 - 0xc1360000   ( 336 kB)
[    0.000000]       .data : 0xc031dd85 - 0xc040bc80   ( 951 kB)
[    0.000000]       .text : 0xc0100000 - 0xc031dd85   (2167 kB)
[    0.000000] Checking if this processor honours the WP bit even in 
supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:320
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1862.070 MHz processor.
[    0.012005] Calibrating delay loop (skipped), value calculated using 
timer frequency.. 3724.14 BogoMIPS (lpj=7448280)
[    0.020230] Mount-cache hash table entries: 512
[    0.024355] mce: CPU supports 6 MCE banks
[    0.028015] CPU0: Thermal monitoring enabled (TM1)
[    0.032005] using mwait in idle threads.
[    0.036010] Performance Events: Core events, core PMU driver.
[    0.044004] ... version:                1
[    0.048003] ... bit width:              40
[    0.052003] ... generic registers:      2
[    0.056003] ... value mask:             000000ffffffffff
[    0.060003] ... max period:             000000007fffffff
[    0.064003] ... fixed-purpose events:   0
[    0.068003] ... event mask:             0000000000000003
[    0.072012] Checking 'hlt' instruction... OK.
[    0.092896] SMP alternatives: switching to UP code
[    0.102149] ACPI: Core revision 20100121
[    0.120095] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.124370] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.168875] CPU0: Intel(R) Celeron(R) M CPU        440  @ 1.86GHz 
stepping 0c
[    0.180000] Brought up 1 CPUs
[    0.180000] Total of 1 processors activated (3724.14 BogoMIPS).
[    0.180193] devtmpfs: initialized
[    0.184837] NET: Registered protocol family 16
[    0.188950] ACPI: bus type pci registered
[    0.192274] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.196027] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.200001] PCI: Using MMCONFIG for extended config space
[    0.204001] PCI: Using configuration type 1 for base access
[    0.219270] bio: create slab <bio-0> at 0
[    0.236735] ACPI: Interpreter enabled
[    0.240012] ACPI: (supports S0 S1 S5)
[    0.244360] ACPI: Using IOAPIC for interrupt routing
[    0.267044] ACPI: No dock devices found.
[    0.268052] PCI: Using host bridge windows from ACPI; if necessary, 
use "pci=nocrs" and report a bug
[    0.272197] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.276475] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.280010] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.284003] pci_root PNP0A08:00: host bridge window [mem 
0x000a0000-0x000bffff]
[    0.288003] pci_root PNP0A08:00: host bridge window [mem 
0x000c0000-0x000dffff]
[    0.292003] pci_root PNP0A08:00: host bridge window [mem 
0x7f750000-0xfebfffff]
[    0.297153] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by 
ICH6 ACPI/GPIO/TCO
[    0.300004] pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by 
ICH6 GPIO
[    0.304004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 
0800 (mask 003f)
[    0.308004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 
0290 (mask 0007)
[    0.312004] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 
02f0 (mask 000f)
[    0.316556] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.320283] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.324283] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.328287] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.332098] pci 0000:00:1e.0: PCI bridge to [bus 05-05] (subtractive 
decode)
[    0.369268] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 *10 11 12 
14 15)
[    0.377203] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 7 9 10 11 12 
14 15)
[    0.384901] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12 
14 15)
[    0.392886] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 11 12 
14 *15)
[    0.400982] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.409938] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.419183] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 7 9 10 11 12 
14 15) *0, disabled.
[    0.428440] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 *7 9 10 11 12 
14 15)
[    0.436763] vgaarb: device added: 
PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.440019] vgaarb: loaded
[    0.444522] SCSI subsystem initialized
[    0.448686] PCI: Using ACPI for IRQ routing
[    0.452646] HPET: 3 timers in total, 0 timers will be used for 
per-cpu timer
[    0.460034] Switching to clocksource tsc
[    0.464184] pnp: PnP ACPI init
[    0.467333] ACPI: bus type pnp registered
[    0.478073] pnp: PnP ACPI: found 13 devices
[    0.482374] ACPI: ACPI bus type pnp unregistered
[    0.487096] system 00:01: [io  0x04d0-0x04d1] has been reserved
[    0.493109] system 00:01: [io  0x0290-0x029f] has been reserved
[    0.499121] system 00:01: [io  0x0880-0x088f] has been reserved
[    0.505135] system 00:09: [io  0x0400-0x04bf] could not be reserved
[    0.511493] system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
[    0.518209] system 00:0c: [mem 0x000f0000-0x000fffff] could not be 
reserved
[    0.525260] system 00:0c: [mem 0x7f6e0000-0x7f6fffff] could not be 
reserved
[    0.532314] system 00:0c: [mem 0x00000000-0x0009ffff] could not be 
reserved
[    0.539370] system 00:0c: [mem 0x00100000-0x7f6dffff] could not be 
reserved
[    0.546422] system 00:0c: [mem 0xfec00000-0xfec00fff] could not be 
reserved
[    0.553478] system 00:0c: [mem 0xfed13000-0xfed1dfff] has been reserved
[    0.561209] system 00:0c: [mem 0xfed20000-0xfed8ffff] has been reserved
[    0.567914] system 00:0c: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.574614] system 00:0c: [mem 0xffb00000-0xffb7ffff] has been reserved
[    0.581323] system 00:0c: [mem 0xfff00000-0xffffffff] has been reserved
[    0.588030] system 00:0c: [mem 0x000e0000-0x000effff] has been reserved
[    0.630685] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.636008] pci 0000:00:1c.0:   bridge window [io  0xb000-0xbfff]
[    0.642197] pci 0000:00:1c.0:   bridge window [mem 0xfd800000-0xfd8fffff]
[    0.649078] pci 0000:00:1c.0:   bridge window [mem 
0xfd500000-0xfd5fffff 64bit pref]
[    0.656965] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.662283] pci 0000:00:1c.1:   bridge window [io  0xa000-0xafff]
[    0.668472] pci 0000:00:1c.1:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.675354] pci 0000:00:1c.1:   bridge window [mem 
0xfdd00000-0xfddfffff 64bit pref]
[    0.683241] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.688550] pci 0000:00:1c.2:   bridge window [io  0xe000-0xefff]
[    0.694732] pci 0000:00:1c.2:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.701611] pci 0000:00:1c.2:   bridge window [mem 
0xfdb00000-0xfdbfffff 64bit pref]
[    0.709491] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.714810] pci 0000:00:1c.3:   bridge window [io  0xd000-0xdfff]
[    0.720998] pci 0000:00:1c.3:   bridge window [mem 0xfda00000-0xfdafffff]
[    0.727880] pci 0000:00:1c.3:   bridge window [mem 
0xfd900000-0xfd9fffff 64bit pref]
[    0.735758] pci 0000:00:1e.0: PCI bridge to [bus 05-05]
[    0.741077] pci 0000:00:1e.0:   bridge window [io  0xc000-0xcfff]
[    0.747259] pci 0000:00:1e.0:   bridge window [mem 0xfd700000-0xfd7fffff]
[    0.754139] pci 0000:00:1e.0:   bridge window [mem 
0xfd600000-0xfd6fffff 64bit pref]
[    0.762040] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.768842] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.775643] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.782446] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.789401] NET: Registered protocol family 2
[    0.793937] IP route cache hash table entries: 32768 (order: 5, 
131072 bytes)
[    0.801429] TCP established hash table entries: 131072 (order: 8, 
1048576 bytes)
[    0.809719] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.816818] TCP: Hash tables configured (established 131072 bind 65536)
[    0.823532] TCP reno registered
[    0.826763] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.832779] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.839404] NET: Registered protocol family 1
[    0.844603] Trying to unpack rootfs image as initramfs...
[    0.955480] Freeing initrd memory: 2844k freed
[    0.964664] highmem bounce pool size: 64 pages
[    0.969476] msgmni has been set to 1742
[    0.973565] Block layer SCSI generic (bsg) driver version 0.4 loaded 
(major 253)
[    0.981101] io scheduler noop registered
[    0.985113] io scheduler deadline registered
[    0.989498] io scheduler cfq registered (default)
[    0.996554] pcieport 0000:00:1c.0: Requesting control of PCIe PME 
from ACPI BIOS
[    1.004136] pcieport 0000:00:1c.0: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.013151] pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
[    1.019946] pcieport 0000:00:1c.1: Requesting control of PCIe PME 
from ACPI BIOS
[    1.027483] pcieport 0000:00:1c.1: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.036494] pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
[    1.043292] pcieport 0000:00:1c.2: Requesting control of PCIe PME 
from ACPI BIOS
[    1.050828] pcieport 0000:00:1c.2: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.059841] pcie_pme: probe of 0000:00:1c.2:pcie01 failed with error -13
[    1.066640] pcieport 0000:00:1c.3: Requesting control of PCIe PME 
from ACPI BIOS
[    1.074168] pcieport 0000:00:1c.3: Failed to receive control of PCIe 
PME service: no _OSC support
[    1.083182] pcie_pme: probe of 0000:00:1c.3:pcie01 failed with error -13
[    1.096629] isapnp: Scanning for PnP cards...
[    1.363949] Switched to NOHz mode on CPU #0
[    1.456976] isapnp: No Plug & Play device found
[    1.545944] Linux agpgart interface v0.103
[    1.550622] agpgart-intel 0000:00:00.0: Intel 945GME Chipset
[    1.556722] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    1.566021] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    1.573422] ipmi message handler version 39.2
[    1.577889] IPMI Watchdog: driver initialized
[    1.582335] Copyright (C) 2004 MontaVista Software - IPMI Powerdown 
via sys_reboot.
[    1.590130] Serial: 8250/16550 driver, 8 ports, IRQ sharing enabled
[    1.852142] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.112139] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.120141] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.126333] 00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.140957] brd: module loaded
[    2.144773] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) 
-> IRQ 18
[    2.152333] scsi0 : ata_piix
[    2.155527] scsi1 : ata_piix
[    2.159963] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xfa00 
irq 14
[    2.167028] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xfa08 
irq 15
[    2.174106] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    2.181342] ata_piix 0000:00:1f.2: MAP [ P0 P2 -- -- ]
[    2.340302] scsi2 : ata_piix
[    2.343434] scsi3 : ata_piix
[    2.347822] ata3: SATA max UDMA/133 cmd 0xf900 ctl 0xf800 bmdma 
0xf500 irq 19
[    2.355060] ata4: SATA max UDMA/133 cmd 0xf700 ctl 0xf600 bmdma 
0xf508 irq 19
[    2.362707] ata1.00: ATA-10: SanDisk SDCFB-256, HDX 2.15, max MWDMA2
[    2.369158] ata1.00: 501760 sectors, multi 0: LBA
[    2.374799] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    2.381073] PNP: PS/2 appears to have AUX port disabled, if this is 
incorrect please boot with i8042.nopnp
[    2.391218] ata1.00: configured for MWDMA2
[    2.395597] scsi 0:0:0:0: Direct-Access     ATA      SanDisk SDCFB-25 
HDX  PQ: 0 ANSI: 5
[    2.405066] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.410584] sd 0:0:0:0: [sda] 501760 512-byte logical blocks: (256 
MB/245 MiB)
[    2.418134] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.423917] sd 0:0:0:0: [sda] Write Protect is off
[    2.429182] mice: PS/2 mouse device common for all mice
[    2.434605] sd 0:0:0:0: [sda] Write cache: disabled, read cache: 
enabled, doesn't support DPO or FUA
[    2.444409] input: PC Speaker as /class/input/input0
[    2.449738]  sda:
[    2.451675] I2O subsystem v1.325
[    2.455298] i2o: max drivers = 8
[    2.458688]  sda1 sda2
[    2.462221] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.467023] rtc_cmos 00:03: RTC can wake from S4
[    2.471995] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    2.478228] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
[    2.484786] i2c /dev entries driver
[    2.488736] input: AT Translated Set 2 keyboard as /class/input/input1
[    2.495409] cpuidle: using governor ladder
[    2.499604] cpuidle: using governor menu
[    2.503843] TCP cubic registered
[    2.507170] NET: Registered protocol family 17
[    2.511713] Using IPI No-Shortcut mode
[    2.516471] rtc_cmos 00:03: setting system clock to 2010-07-28 
12:24:46 UTC (1280319886)
[    2.524706] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    2.530799] EDD information not available.
[    2.557165] ata3.01: ATA-8: FUJITSU MHY2060BH, 0000000C, max UDMA/100
[    2.563735] ata3.01: 117210240 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    2.584184] ata3.01: configured for UDMA/100
[    2.588680] scsi 2:0:1:0: Direct-Access     ATA      FUJITSU MHY2060B 
0000 PQ: 0 ANSI: 5
[    2.597370] sd 2:0:1:0: [sdb] 117210240 512-byte logical blocks: 
(60.0 GB/55.8 GiB)
[    2.605446] sd 2:0:1:0: Attached scsi generic sg1 type 0
[    2.611052] sd 2:0:1:0: [sdb] Write Protect is off
[    2.616039] sd 2:0:1:0: [sdb] Write cache: enabled, read cache: 
enabled, doesn't support DPO or FUA
[    2.625494]  sdb: sdb1
[    2.628822] sd 2:0:1:0: [sdb] Attached SCSI disk
[    2.633543] Freeing unused kernel memory: 336k freed
[    2.638798] Write protecting the kernel text: 2168k
[    2.643785] Write protecting the kernel read-only data: 768k
[    7.809119] input: Power Button as /class/input/input2
[    7.814568] ACPI: Power Button [PWRB]
[    7.818460] input: Sleep Button as /class/input/input3
[    7.823788] ACPI: Sleep Button [SLPB]
[    7.827713] input: Power Button as /class/input/input4
[    7.833073] ACPI: Power Button [PWRF]
[    7.901480] thermal LNXTHERM:00: registered as thermal_zone0
[    7.907304] ACPI: Thermal Zone [TZ00] (0 C)
[    8.003149] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[    8.009178] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[    8.015324] e1000e 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> 
IRQ 16
[    8.022839] e1000e 0000:01:00.0: Disabling ASPM L0s
[    8.089334] thermal LNXTHERM:02: registered as thermal_zone1
[    8.095143] ACPI: Thermal Zone [THRM] (40 C)
[    8.344983] ACPI: Fan [FAN] (on)
[    8.418502] usbcore: registered new interface driver usbfs
[    8.424196] usbcore: registered new interface driver hub
[    8.463909] 0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:29
[    8.471470] 0000:01:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    8.477989] 0000:01:00.0: eth0: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    8.484299] e1000e 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> 
IRQ 17
[    8.492129] e1000e 0000:02:00.0: Disabling ASPM L0s
[    8.571089] iTCO_vendor_support: vendor-support=0
[    8.598343] i801_smbus 0000:00:1f.3: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    8.635100] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
[    8.640979] iTCO_wdt: Found a ICH7-M or ICH7-U TCO device (Version=2, 
TCOBASE=0x0460)
[    8.649145] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    8.746714] usbcore: registered new device driver usb
[    8.773972] uhci_hcd: USB Universal Host Controller Interface driver
[    8.780502] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) 
-> IRQ 23
[    8.787750] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    8.793115] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned 
bus number 1
[    8.800706] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fe00
[    8.806996] hub 1-0:1.0: USB hub found
[    8.810851] hub 1-0:1.0: 2 ports detected
[    8.815127] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) 
-> IRQ 19
[    8.822366] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    8.827701] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned 
bus number 2
[    8.835278] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000fd00
[    8.841449] hub 2-0:1.0: USB hub found
[    8.845303] hub 2-0:1.0: 2 ports detected
[    8.849570] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) 
-> IRQ 18
[    8.856817] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    8.862144] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned 
bus number 3
[    8.869732] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000fc00
[    8.875895] hub 3-0:1.0: USB hub found
[    8.879739] hub 3-0:1.0: 2 ports detected
[    8.884023] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) 
-> IRQ 16
[    8.891264] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    8.896592] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned 
bus number 4
[    8.904173] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000fb00
[    8.910329] hub 4-0:1.0: USB hub found
[    8.914179] hub 4-0:1.0: 2 ports detected
[    8.927536] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    8.934199] Warning! ehci_hcd should always be loaded before uhci_hcd 
and ohci_hcd, not after
[    8.942908] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) 
-> IRQ 23
[    8.950164] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    8.955494] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned 
bus number 5
[    8.963085] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    8.969455] ehci_hcd 0000:00:1d.7: debug port 1
[    8.977982] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfdfff000
[    9.085657] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    9.091979] hub 5-0:1.0: USB hub found
[    9.095830] hub 5-0:1.0: 8 ports detected
[    9.145112] 0000:02:00.0: eth1: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2a
[    9.152657] 0000:02:00.0: eth1: Intel(R) PRO/1000 Network Connection
[    9.159171] 0000:02:00.0: eth1: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    9.165482] e1000e 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> 
IRQ 18
[    9.173311] e1000e 0000:03:00.0: Disabling ASPM L0s
[    9.297100] 0000:03:00.0: eth2: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2b
[    9.304646] 0000:03:00.0: eth2: Intel(R) PRO/1000 Network Connection
[    9.311162] 0000:03:00.0: eth2: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[    9.317465] e1000e 0000:04:00.0: PCI INT A -> GSI 19 (level, low) -> 
IRQ 19
[    9.325278] e1000e 0000:04:00.0: Disabling ASPM L0s
[    9.449062] 0000:04:00.0: eth3: (PCI Express:2.5GB/s:Width x1) 
00:30:18:4c:58:2c
[    9.456608] 0000:04:00.0: eth3: Intel(R) PRO/1000 Network Connection
[    9.463126] 0000:04:00.0: eth3: MAC: 2, PHY: 2, PBA No: ffffff-0ff
[   11.762850] ip_tables: (C) 2000-2006 Netfilter Core Team
[   11.796076] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   11.802399] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. 
Please use
[   11.809934] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack 
module option or
[   11.817996] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[   19.430598] Mem-Info:
[   19.433022] DMA per-cpu:
[   19.434589] CPU    0: hi:    0, btch:   1 usd:   0
[   19.434589] Normal per-cpu:
[   19.434589] CPU    0: hi:  186, btch:  31 usd: 118
[   19.434589] HighMem per-cpu:
[   19.434589] CPU    0: hi:  186, btch:  31 usd:  72
[   19.434589] active_anon:936 inactive_anon:125 isolated_anon:0
[   19.434589]  active_file:1053 inactive_file:1801 isolated_file:0
[   19.434589]  unevictable:0 dirty:0 writeback:0 unstable:0
[   19.434589]  free:509563 slab_reclaimable:627 slab_unreclaimable:1455
[   19.434589]  mapped:621 shmem:203 pagetables:49 bounce:0
[   19.434589] DMA free:12244kB min:64kB low:80kB high:96kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   19.434589] lowmem_reserve[]: 0 869 2006 2006
[   19.434589] Normal free:867296kB min:3736kB low:4668kB high:5604kB 
active_anon:0kB inactive_anon:0kB active_file:568kB inactive_file:684kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:890008kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:2508kB slab_unreclaimable:5820kB kernel_stack:328kB 
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   19.434589] lowmem_reserve[]: 0 0 9100 9100
[   19.434589] HighMem free:1158712kB min:512kB low:1732kB high:2956kB 
active_anon:3744kB inactive_anon:500kB active_file:3644kB 
inactive_file:6520kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:1164912kB mlocked:0kB dirty:0kB writeback:0kB 
mapped:2484kB shmem:812kB slab_reclaimable:0kB slab_unreclaimable:0kB 
kernel_stack:0kB pagetables:196kB unstable:0kB bounce:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   19.434589] lowmem_reserve[]: 0 0 0 0
[   19.434589] DMA: 1*4kB 2*8kB 2*16kB 3*32kB 1*64kB 2*128kB 2*256kB 
0*512kB 1*1024kB 1*2048kB 2*4096kB = 12244kB
[   19.434589] Normal: 0*4kB 14*8kB 9*16kB 5*32kB 1*64kB 4*128kB 2*256kB 
3*512kB 2*1024kB 3*2048kB 209*4096kB = 867296kB
[   19.434589] HighMem: 2*4kB 12*8kB 11*16kB 3*32kB 3*64kB 2*128kB 
5*256kB 3*512kB 2*1024kB 1*2048kB 281*4096kB = 1158712kB
[   19.434589] 3057 total pagecache pages
[   19.434589] 0 pages in swap cache
[   19.434589] Swap cache stats: add 0, delete 0, find 0/0
[   19.434589] Free swap  = 0kB
[   19.434589] Total swap = 0kB
[   19.434589] BUG: unable to handle kernel paging request at 4c4fe4d8
[   19.434589] IP: [<c01d8a17>] show_mem+0xbf/0x15c
[   19.434589] *pdpt = 0000000036d4e001 *pde = 0000000000000000
[   19.434589] Oops: 0000 [#1] SMP
[   19.434589] last sysfs file: /sys/kernel/uevent_seqnum
[   19.434589] Modules linked in: nf_nat_irc nf_nat_ftp ipt_MASQUERADE 
ipt_REJECT ipt_REDIRECT xt_state xt_limit ipt_LOG iptable_nat nf_nat 
iptable_mangle iptable_filter nf_conntrack_irc nf_conntrack_ftp 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables 
coretemp ehci_hcd uhci_hcd iTCO_wdt i2c_i801 iTCO_vendor_support usbcore 
fan e1000e thermal button processor evdev nls_iso8859_1
[   19.434589]
[   19.434589] Pid: 0, comm: swapper Not tainted 2.6.34.1 #27 
945GM/E-ITE8712/945GM/E-ITE8712
[   19.434589] EIP: 0060:[<c01d8a17>] EFLAGS: 00010002 CPU: 0
[   19.434589] EIP is at show_mem+0xbf/0x15c
[   19.434589] EAX: 4c4fe4d4 EBX: 000185e4 ECX: 00000001 EDX: c130cc80
[   19.434589] ESI: 000185d4 EDI: c0407900 EBP: c03dfdc8 ESP: c03dfda8
[   19.434589]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   19.434589] Process swapper (pid: 0, ti=c03de000 task=c03edea0 
task.ti=c03de000)
[   19.434589] Stack:
[   19.434589]  000185d4 000014e1 0002d8c6 00000000 00000000 f7409cd0 
00000046 c03ff203
[   19.434589] <0> c03dfdd0 c0232949 c03dfddc c0231e78 00000002 c03dfe10 
c0233363 f6d34d88
[   19.434589] <0> 010200b4 f7409cd0 f7409cd0 00000001 00000001 00000000 
0000f203 f6cca3f0
[   19.434589] Call Trace:
[   19.434589]  [<c0232949>] ? fn_show_mem+0x8/0xa
[   19.434589]  [<c0231e78>] ? k_spec+0x33/0x36
[   19.434589]  [<c0233363>] ? kbd_event+0x515/0x57e
[   19.434589]  [<c02817ef>] ? input_pass_event+0x63/0x9e
[   19.434589]  [<c0282a6e>] ? input_handle_event+0x357/0x360
[   19.434589]  [<c0283811>] ? input_event+0x4b/0x5e
[   19.434589]  [<c028661c>] ? atkbd_interrupt+0x45e/0x536
[   19.434589]  [<c027f037>] ? serio_interrupt+0x30/0x66
[   19.434589]  [<c027fe78>] ? i8042_interrupt+0x25e/0x271
[   19.434589]  [<c01314d4>] ? do_timer+0x1b/0x1d
[   19.434589]  [<c014c01d>] ? handle_IRQ_event+0x24/0x9e
[   19.434589]  [<c014d95e>] ? handle_edge_irq+0xb4/0x116
[   19.434589]  [<c010441e>] ? handle_irq+0x1a/0x24
[   19.434589]  [<c0103cc0>] ? do_IRQ+0x40/0x9b
[   19.434589]  [<c0102c29>] ? common_interrupt+0x29/0x30
[   19.434589]  [<c010868f>] ? mwait_idle+0x4c/0x52
[   19.434589]  [<c01018dc>] ? cpu_idle+0x44/0x5d
[   19.434589]  [<c030c906>] ? rest_init+0x62/0x64
[   19.434589]  [<c040c8a9>] ? start_kernel+0x29b/0x2a0
[   19.434589]  [<c040c0b3>] ? i386_start_kernel+0xb3/0xb8
[   19.434589] Code: c0 09 00 00 75 0c 83 3d e8 e7 47 c0 02 75 03 ff 45 
f0 f6 c5 04 74 05 ff 45 e4 eb 3d c1 e9 0f 83 e1 01 75 04 89 d0 eb 03 8b 
42 0c <8b> 40 04 48 75 05 ff 45 ec eb 23 85 c9 89 d0 74 03 8b 42 0c 8b
[   19.434589] EIP: [<c01d8a17>] show_mem+0xbf/0x15c SS:ESP 0068:c03dfda8
[   19.434589] CR2: 000000004c4fe4d8
[   19.434589] ---[ end trace 5012c6e90b5dccc6 ]---
[   19.434589] Kernel panic - not syncing: Fatal exception in interrupt
[   19.434589] Pid: 0, comm: swapper Tainted: G      D    2.6.34.1 #27
[   19.434589] Call Trace:
[   19.434589]  [<c012912b>] panic+0x3e/0xa8
[   19.434589]  [<c0105093>] oops_end+0x6f/0x7d
[   19.434589]  [<c011957f>] no_context+0x153/0x15d
[   19.434589]  [<c017098e>] ? show_swap_cache_info+0x5e/0x62
[   19.434589]  [<c0119711>] __bad_area_nosemaphore+0xe5/0xed
[   19.434589]  [<c011977d>] bad_area_nosemaphore+0xd/0x10
[   19.434589]  [<c0119a0a>] do_page_fault+0x13c/0x2ea
[   19.434589]  [<c01198ce>] ? do_page_fault+0x0/0x2ea
[   19.434589]  [<c031d196>] error_code+0x66/0x6c
[   19.434589]  [<c01198ce>] ? do_page_fault+0x0/0x2ea
[   19.434589]  [<c01d8a17>] ? show_mem+0xbf/0x15c
[   19.434589]  [<c0232949>] fn_show_mem+0x8/0xa
[   19.434589]  [<c0231e78>] k_spec+0x33/0x36
[   19.434589]  [<c0233363>] kbd_event+0x515/0x57e
[   19.434589]  [<c02817ef>] input_pass_event+0x63/0x9e
[   19.434589]  [<c0282a6e>] input_handle_event+0x357/0x360
[   19.434589]  [<c0283811>] input_event+0x4b/0x5e
[   19.434589]  [<c028661c>] atkbd_interrupt+0x45e/0x536
[   19.434589]  [<c027f037>] serio_interrupt+0x30/0x66
[   19.434589]  [<c027fe78>] i8042_interrupt+0x25e/0x271
[   19.434589]  [<c01314d4>] ? do_timer+0x1b/0x1d
[   19.434589]  [<c014c01d>] handle_IRQ_event+0x24/0x9e
[   19.434589]  [<c014d95e>] handle_edge_irq+0xb4/0x116
[   19.434589]  [<c010441e>] handle_irq+0x1a/0x24
[   19.434589]  [<c0103cc0>] do_IRQ+0x40/0x9b
[   19.434589]  [<c0102c29>] common_interrupt+0x29/0x30
[   19.434589]  [<c010868f>] ? mwait_idle+0x4c/0x52
[   19.434589]  [<c01018dc>] cpu_idle+0x44/0x5d
[   19.434589]  [<c030c906>] rest_init+0x62/0x64
[   19.434589]  [<c040c8a9>] start_kernel+0x29b/0x2a0
[   19.434589]  [<c040c0b3>] i386_start_kernel+0xb3/0xb8

>
> Theory 5
> --------
> What are the consequences of the following message?
>
> pcieport 0000:00:1c.0: Requesting control of PCIe PME from ACPI BIOS
> pcieport 0000:00:1c.0: Failed to receive control of PCIe PME service: no _OSC support
> pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
> pcieport 0000:00:1c.1: Requesting control of PCIe PME from ACPI BIOS
> pcieport 0000:00:1c.1: Failed to receive control of PCIe PME service: no _OSC support
> pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
> pcieport 0000:00:1c.2: Requesting control of PCIe PME from ACPI BIOS
> pcieport 0000:00:1c.2: Failed to receive control of PCIe PME service: no _OSC support
> pcie_pme: probe of 0000:00:1c.2:pcie01 failed with error -13
> pcieport 0000:00:1c.3: Requesting control of PCIe PME from ACPI BIOS
> pcieport 0000:00:1c.3: Failed to receive control of PCIe PME service: no _OSC support
> pcie_pme: probe of 0000:00:1c.3:pcie01 failed with error -13
>
> Is there any possibility when this fails that the device is writing to
> some location in memory thinking the OS has taken proper control of it
> and reserved those physicaly address? (reaching I know, but have to
> eliminate it as a possibility)
Tried aerdriver.forceload=y without success. Suggestions welcome on how 
to rule this out.
> Sorry to spread the possibilities all over the place but without a local
> reproduction case, there isn't much to go on yet.
If it helps I can sent or attach the vmlinuz or even complete kernel 
build dir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
