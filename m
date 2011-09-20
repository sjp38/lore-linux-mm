Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CD5D79000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 13:53:06 -0400 (EDT)
Message-ID: <4E78D2DF.7090805@fastmail.fm>
Date: Tue, 20 Sep 2011 19:52:31 +0200
From: Anders Eriksson <aeriksson@fastmail.fm>
MIME-Version: 1.0
Subject: Re: 3.0.3 oops, mm related?
References: <4E77A1F6.9030508@fastmail.fm> <201109192305.23480.rjw@sisk.pl>
In-Reply-To: <201109192305.23480.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>

Here's a gdb run.

On 09/19/11 23:05, Rafael J. Wysocki wrote:
> On Monday, September 19, 2011, Anders Eriksson wrote:
> > kdump produced this oops dump for me. Not sure what triggered it.
>
> Apparently, a NULL pointer deref in usb_hcd_irq() after a resume
> from suspend.
>
> Can you check (using gdb) what code corresponds to
> usb_hcd_irq+0x3 in your kernel?
>  
gdb /usr/src/linux/drivers/usb/core/hcd.o
GNU gdb (Gentoo 7.2 p1) 7.2
Copyright (C) 2010 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later
<http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-pc-linux-gnu".
For bug reporting instructions, please see:
<http://bugs.gentoo.org/>...
Reading symbols from /usr/src/linux-git/drivers/usb/core/hcd.o...(no
debugging symbols found)...done.
(gdb) disassemble usb_hcd_irq
Dump of assembler code for function usb_hcd_irq:
   0x0000000000000907 <+0>:     push   %rbp
   0x0000000000000908 <+1>:     push   %rbx
   0x0000000000000909 <+2>:     mov    %rsi,%rbx
   0x000000000000090c <+5>:     sub    $0x8,%rsp
   0x0000000000000910 <+9>:     pushfq
   0x0000000000000911 <+10>:    pop    %rbp
   0x0000000000000912 <+11>:    cli   
   0x0000000000000913 <+12>:    mov    0x100(%rsi),%rax
   0x000000000000091a <+19>:    test   $0x40,%al
   0x000000000000091c <+21>:    jne    0x956 <usb_hcd_irq+79>
   0x000000000000091e <+23>:    test   $0x1,%al
   0x0000000000000920 <+25>:    je     0x956 <usb_hcd_irq+79>
   0x0000000000000922 <+27>:    mov    0xf8(%rsi),%rax
   0x0000000000000929 <+34>:    mov    %rsi,%rdi
   0x000000000000092c <+37>:    callq  *0x18(%rax)
   0x000000000000092f <+40>:    test   %eax,%eax
   0x0000000000000931 <+42>:    je     0x956 <usb_hcd_irq+79>
   0x0000000000000933 <+44>:    lock orb $0x2,0x100(%rbx)
   0x000000000000093b <+52>:    mov    0x138(%rbx),%rdx
   0x0000000000000942 <+59>:    mov    $0x1,%eax
   0x0000000000000947 <+64>:    test   %rdx,%rdx
   0x000000000000094a <+67>:    je     0x958 <usb_hcd_irq+81>
   0x000000000000094c <+69>:    lock orb $0x2,0x100(%rdx)
   0x0000000000000954 <+77>:    jmp    0x958 <usb_hcd_irq+81>
   0x0000000000000956 <+79>:    xor    %eax,%eax
   0x0000000000000958 <+81>:    push   %rbp
   0x0000000000000959 <+82>:    popfq 
   0x000000000000095a <+83>:    pop    %r11
   0x000000000000095c <+85>:    pop    %rbx
   0x000000000000095d <+86>:    pop    %rbp
   0x000000000000095e <+87>:    retq  
End of assembler dump.




> > <6>[    0.000000] Initializing cgroup subsys cpuset
> > <6>[    0.000000] Initializing cgroup subsys cpu
> > <5>[    0.000000] Linux version 3.0.3-dirty (root@tv) (gcc version 4.4.5
> > (Gentoo 4.4.5 p1.2, pie-0.4.5) ) #37 SMP PREEMPT Mon Aug 22 08:54:35
> > CEST 2011
> > <6>[    0.000000] Command line: root=/dev/sda3 hpet=disable crashkernel=128M
> > <6>[    0.000000] KERNEL supported cpus:
> > <6>[    0.000000]   AMD AuthenticAMD
> > <6>[    0.000000] BIOS-provided physical RAM map:
> > <6>[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
> > <6>[    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
> > <6>[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
> > <6>[    0.000000]  BIOS-e820: 0000000000100000 - 0000000077ee0000 (usable)
> > <6>[    0.000000]  BIOS-e820: 0000000077ee0000 - 0000000077ee3000 (ACPI NVS)
> > <6>[    0.000000]  BIOS-e820: 0000000077ee3000 - 0000000077ef0000 (ACPI
> > data)
> > <6>[    0.000000]  BIOS-e820: 0000000077ef0000 - 0000000077f00000 (reserved)
> > <6>[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
> > <6>[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
> > <6>[    0.000000] NX (Execute Disable) protection: active
> > <6>[    0.000000] DMI 2.4 present.
> > <7>[    0.000000] DMI: System manufacturer System Product Name/M2A-VM
> > HDMI, BIOS ASUS M2A-VM HDMI ACPI BIOS Revision 2201 10/22/2008
> > <7>[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
> > (usable) ==> (reserved)
> > <7>[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000
> > (usable)
> > <6>[    0.000000] No AGP bridge found
> > <6>[    0.000000] last_pfn = 0x77ee0 max_arch_pfn = 0x400000000
> > <7>[    0.000000] MTRR default type: uncachable
> > <7>[    0.000000] MTRR fixed ranges enabled:
> > <7>[    0.000000]   00000-9FFFF write-back
> > <7>[    0.000000]   A0000-BFFFF uncachable
> > <7>[    0.000000]   C0000-C7FFF write-protect
> > <7>[    0.000000]   C8000-FFFFF uncachable
> > <7>[    0.000000] MTRR variable ranges enabled:
> > <7>[    0.000000]   0 base 0000000000 mask FFC0000000 write-back
> > <7>[    0.000000]   1 base 0040000000 mask FFE0000000 write-back
> > <7>[    0.000000]   2 base 0060000000 mask FFF0000000 write-back
> > <7>[    0.000000]   3 base 0070000000 mask FFF8000000 write-back
> > <7>[    0.000000]   4 base 0077F00000 mask FFFFF00000 uncachable
> > <7>[    0.000000]   5 disabled
> > <7>[    0.000000]   6 disabled
> > <7>[    0.000000]   7 disabled
> > <6>[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
> > 0x7010600070106
> > <6>[    0.000000] found SMP MP-table at [ffff8800000f6560] f6560
> > <7>[    0.000000] initial memory mapped : 0 - 20000000
> > <7>[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000
> > size 20480
> > <6>[    0.000000] init_memory_mapping: 0000000000000000-0000000077ee0000
> > <7>[    0.000000]  0000000000 - 0077e00000 page 2M
> > <7>[    0.000000]  0077e00000 - 0077ee0000 page 4k
> > <7>[    0.000000] kernel direct mapping tables up to 77ee0000 @
> > 77edc000-77ee0000
> > <6>[    0.000000] Reserving 128MB of memory at 768MB for crashkernel
> > (System RAM: 1918MB)
> > <4>[    0.000000] ACPI: RSDP 00000000000f8210 00024 (v02 ATI   )
> > <4>[    0.000000] ACPI: XSDT 0000000077ee3100 00044 (v01 ATI    ASUSACPI
> > 42302E31 AWRD 00000000)
> > <4>[    0.000000] ACPI: FACP 0000000077ee8500 000F4 (v03 ATI    ASUSACPI
> > 42302E31 AWRD 00000000)
> > <4>[    0.000000] ACPI: DSDT 0000000077ee3280 05210 (v01 ATI    ASUSACPI
> > 00001000 MSFT 03000000)
> > <4>[    0.000000] ACPI: FACS 0000000077ee0000 00040
> > <4>[    0.000000] ACPI: SSDT 0000000077ee8740 002CC (v01 PTLTD  POWERNOW
> > 00000001  LTP 00000001)
> > <4>[    0.000000] ACPI: MCFG 0000000077ee8b00 0003C (v01 ATI    ASUSACPI
> > 42302E31 AWRD 00000000)
> > <4>[    0.000000] ACPI: APIC 0000000077ee8640 00084 (v01 ATI    ASUSACPI
> > 42302E31 AWRD 00000000)
> > <7>[    0.000000] ACPI: Local APIC address 0xfee00000
> > <7>[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD ->
> > [ffff880075800000-ffff8800773fffff] on node 0
> > <4>[    0.000000] Zone PFN ranges:
> > <4>[    0.000000]   DMA      0x00000010 -> 0x00001000
> > <4>[    0.000000]   DMA32    0x00001000 -> 0x00100000
> > <4>[    0.000000]   Normal   empty
> > <4>[    0.000000] Movable zone start PFN for each node
> > <4>[    0.000000] early_node_map[2] active PFN ranges
> > <4>[    0.000000]     0: 0x00000010 -> 0x0000009f
> > <4>[    0.000000]     0: 0x00000100 -> 0x00077ee0
> > <7>[    0.000000] On node 0 totalpages: 491119
> > <7>[    0.000000]   DMA zone: 56 pages used for memmap
> > <7>[    0.000000]   DMA zone: 5 pages reserved
> > <7>[    0.000000]   DMA zone: 3922 pages, LIFO batch:0
> > <7>[    0.000000]   DMA32 zone: 6661 pages used for memmap
> > <7>[    0.000000]   DMA32 zone: 480475 pages, LIFO batch:31
> > <6>[    0.000000] Detected use of extended apic ids on hypertransport bus
> > <6>[    0.000000] ACPI: PM-Timer IO Port: 0x4008
> > <7>[    0.000000] ACPI: Local APIC address 0xfee00000
> > <6>[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> > <6>[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> > <6>[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
> > <6>[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
> > <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> > <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> > <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
> > <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
> > <6>[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
> > <6>[    0.000000] IOAPIC[0]: apic_id 4, version 33, address 0xfec00000,
> > GSI 0-23
> > <6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> > <6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> > <7>[    0.000000] ACPI: IRQ0 used by override.
> > <7>[    0.000000] ACPI: IRQ2 used by override.
> > <7>[    0.000000] ACPI: IRQ9 used by override.
> > <6>[    0.000000] Using ACPI (MADT) for SMP configuration information
> > <6>[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
> > <7>[    0.000000] nr_irqs_gsi: 40
> > <6>[    0.000000] PM: Registered nosave memory: 000000000009f000 -
> > 00000000000a0000
> > <6>[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
> > 00000000000f0000
> > <6>[    0.000000] PM: Registered nosave memory: 00000000000f0000 -
> > 0000000000100000
> > <6>[    0.000000] Allocating PCI resources starting at 77f00000 (gap:
> > 77f00000:68100000)
> > <6>[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4
> > nr_node_ids:1
> > <6>[    0.000000] PERCPU: Embedded 24 pages/cpu @ffff880077c00000 s68800
> > r8192 d21312 u524288
> > <7>[    0.000000] pcpu-alloc: s68800 r8192 d21312 u524288 alloc=1*2097152
> > <7>[    0.000000] pcpu-alloc: [0] 0 1 2 3
> > <4>[    0.000000] Built 1 zonelists in Zone order, mobility grouping
> > on.  Total pages: 484397
> > <5>[    0.000000] Kernel command line: root=/dev/sda3 hpet=disable
> > crashkernel=128M
> > <6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> > <6>[    0.000000] Dentry cache hash table entries: 262144 (order: 9,
> > 2097152 bytes)
> > <6>[    0.000000] Inode-cache hash table entries: 131072 (order: 8,
> > 1048576 bytes)
> > <6>[    0.000000] Checking aperture...
> > <6>[    0.000000] No AGP bridge found
> > <6>[    0.000000] Node 0: aperture @ 266000000 size 32 MB
> > <6>[    0.000000] Aperture beyond 4GB. Ignoring.
> > <6>[    0.000000] Memory: 1792880k/1964928k available (4899k kernel
> > code, 452k absent, 171596k reserved, 2346k data, 464k init)
> > <6>[    0.000000] Preemptible hierarchical RCU implementation.
> > <6>[    0.000000]       CONFIG_RCU_FANOUT set to non-default value of 32
> > <6>[    0.000000] NR_IRQS:384
> > <6>[    0.000000] Console: colour VGA+ 80x25
> > <6>[    0.000000] console [tty0] enabled
> > <6>[    0.000000] allocated 15728640 bytes of page_cgroup
> > <6>[    0.000000] please try 'cgroup_disable=memory' option if you don't
> > want memory cgroups
> > <4>[    0.000000] Fast TSC calibration using PIT
> > <4>[    0.000000] Detected 2799.546 MHz processor.
> > <6>[    0.000000] Marking TSC unstable due to TSCs unsynchronized
> > <6>[    0.002039] Calibrating delay loop (skipped), value calculated
> > using timer frequency.. 5599.09 BogoMIPS (lpj=2799546)
> > <6>[    0.002109] pid_max: default: 32768 minimum: 301
> > <6>[    0.002204] Mount-cache hash table entries: 256
> > <6>[    0.002392] Initializing cgroup subsys cpuacct
> > <6>[    0.002435] Initializing cgroup subsys memory
> > <6>[    0.002480] Initializing cgroup subsys devices
> > <6>[    0.002515] Initializing cgroup subsys freezer
> > <6>[    0.002549] Initializing cgroup subsys blkio
> > <7>[    0.003019] tseg: 0077f00000
> > <6>[    0.003021] CPU: Physical Processor ID: 0
> > <6>[    0.003056] CPU: Processor Core ID: 0
> > <6>[    0.003090] mce: CPU supports 5 MCE banks
> > <6>[    0.003132] using AMD E400 aware idle routine
> > <6>[    0.003198] ACPI: Core revision 20110413
> > <6>[    0.005568] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> > <6>[    0.016152] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 5600+
> > stepping 03
> > <6>[    0.016998] Performance Events: AMD PMU driver.
> > <6>[    0.016998] ... version:                0
> > <6>[    0.016998] ... bit width:              48
> > <6>[    0.016998] ... generic registers:      4
> > <6>[    0.016998] ... value mask:             0000ffffffffffff
> > <6>[    0.016998] ... max period:             00007fffffffffff
> > <6>[    0.016998] ... fixed-purpose events:   0
> > <6>[    0.016998] ... event mask:             000000000000000f
> > <6>[    0.028011] Booting Node   0, Processors  #1
> > <7>[    0.028073] smpboot cpu 1: start_ip = 9a000
> > <6>[    0.099035] Brought up 2 CPUs
> > <6>[    0.099070] Total of 2 processors activated (11197.89 BogoMIPS).
> > <6>[    0.099465] PM: Registering ACPI NVS region at 77ee0000 (12288 bytes)
> > <6>[    0.099465] NET: Registered protocol family 16
> > <7>[    0.100024] node 0 link 0: io port [c000, ffff]
> > <6>[    0.100024] TOM: 0000000080000000 aka 2048M
> > <7>[    0.100043] node 0 link 0: mmio [a0000, bffff]
> > <7>[    0.100046] node 0 link 0: mmio [80000000, dfffffff]
> > <7>[    0.100048] node 0 link 0: mmio [f0000000, fe02ffff]
> > <7>[    0.100051] node 0 link 0: mmio [e0000000, e03fffff]
> > <7>[    0.100053] bus: [00, 03] on node 0 link 0
> > <7>[    0.100056] bus: 00 index 0 [io  0x0000-0xffff]
> > <7>[    0.100058] bus: 00 index 1 [mem 0x000a0000-0x000bffff]
> > <7>[    0.100060] bus: 00 index 2 [mem 0x80000000-0xefffffff]
> > <7>[    0.100062] bus: 00 index 3 [mem 0xf0000000-0xfcffffffff]
> > <6>[    0.100069] ACPI: bus type pci registered
> > <6>[    0.100113] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
> > 0xe0000000-0xefffffff] (base 0xe0000000)
> > <6>[    0.100113] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved
> > in E820
> > <6>[    0.116130] PCI: Using configuration type 1 for base access
> > <6>[    0.121108] bio: create slab <bio-0> at 0
> > <7>[    0.122550] ACPI: EC: Look up EC in DSDT
> > <6>[    0.125943] ACPI: Interpreter enabled
> > <6>[    0.125981] ACPI: (supports S0 S1 S3 S4 S5)
> > <6>[    0.126152] ACPI: Using IOAPIC for interrupt routing
> > <6>[    0.130214] ACPI: No dock devices found.
> > <6>[    0.130214] HEST: Table not found.
> > <6>[    0.130991] PCI: Using host bridge windows from ACPI; if
> > necessary, use "pci=nocrs" and report a bug
> > <6>[    0.131081] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> > <6>[    0.131147] pci_root PNP0A03:00: host bridge window [io 
> > 0x0000-0x0cf7]
> > <6>[    0.131147] pci_root PNP0A03:00: host bridge window [io 
> > 0x0d00-0xffff]
> > <6>[    0.131147] pci_root PNP0A03:00: host bridge window [mem
> > 0x000a0000-0x000bffff]
> > <6>[    0.131182] pci_root PNP0A03:00: host bridge window [mem
> > 0x000c0000-0x000dffff]
> > <6>[    0.131221] pci_root PNP0A03:00: host bridge window [mem
> > 0x80000000-0xfebfffff]
> > <7>[    0.131269] pci 0000:00:00.0: [1002:7910] type 0 class 0x000600
> > <7>[    0.131294] pci 0000:00:01.0: [1002:7912] type 1 class 0x000604
> > <7>[    0.131325] pci 0000:00:07.0: [1002:7917] type 1 class 0x000604
> > <7>[    0.131345] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
> > <7>[    0.131348] pci 0000:00:07.0: PME# disabled
> > <7>[    0.131377] pci 0000:00:12.0: [1002:4380] type 0 class 0x000101
> > <7>[    0.131394] pci 0000:00:12.0: reg 10: [io  0xff00-0xff07]
> > <7>[    0.131404] pci 0000:00:12.0: reg 14: [io  0xfe00-0xfe03]
> > <7>[    0.131414] pci 0000:00:12.0: reg 18: [io  0xfd00-0xfd07]
> > <7>[    0.131424] pci 0000:00:12.0: reg 1c: [io  0xfc00-0xfc03]
> > <7>[    0.131434] pci 0000:00:12.0: reg 20: [io  0xfb00-0xfb0f]
> > <7>[    0.131444] pci 0000:00:12.0: reg 24: [mem 0xfe02f000-0xfe02f3ff]
> > <6>[    0.131465] pci 0000:00:12.0: set SATA to AHCI mode
> > <7>[    0.131527] pci 0000:00:13.0: [1002:4387] type 0 class 0x000c03
> > <7>[    0.131541] pci 0000:00:13.0: reg 10: [mem 0xfe02e000-0xfe02efff]
> > <7>[    0.131605] pci 0000:00:13.1: [1002:4388] type 0 class 0x000c03
> > <7>[    0.131619] pci 0000:00:13.1: reg 10: [mem 0xfe02d000-0xfe02dfff]
> > <7>[    0.131685] pci 0000:00:13.2: [1002:4389] type 0 class 0x000c03
> > <7>[    0.131698] pci 0000:00:13.2: reg 10: [mem 0xfe02c000-0xfe02cfff]
> > <7>[    0.131763] pci 0000:00:13.3: [1002:438a] type 0 class 0x000c03
> > <7>[    0.131776] pci 0000:00:13.3: reg 10: [mem 0xfe02b000-0xfe02bfff]
> > <7>[    0.132031] pci 0000:00:13.4: [1002:438b] type 0 class 0x000c03
> > <7>[    0.132045] pci 0000:00:13.4: reg 10: [mem 0xfe02a000-0xfe02afff]
> > <7>[    0.132115] pci 0000:00:13.5: [1002:4386] type 0 class 0x000c03
> > <7>[    0.132135] pci 0000:00:13.5: reg 10: [mem 0xfe029000-0xfe0290ff]
> > <7>[    0.132205] pci 0000:00:13.5: supports D1 D2
> > <7>[    0.132208] pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
> > <7>[    0.132212] pci 0000:00:13.5: PME# disabled
> > <7>[    0.132233] pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
> > <7>[    0.132256] pci 0000:00:14.0: reg 10: [io  0x0b00-0x0b0f]
> > <7>[    0.132332] pci 0000:00:14.1: [1002:438c] type 0 class 0x000101
> > <7>[    0.132346] pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
> > <7>[    0.132356] pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
> > <7>[    0.132366] pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
> > <7>[    0.132376] pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
> > <7>[    0.132386] pci 0000:00:14.1: reg 20: [io  0xf900-0xf90f]
> > <7>[    0.132423] pci 0000:00:14.2: [1002:4383] type 0 class 0x000403
> > <7>[    0.132445] pci 0000:00:14.2: reg 10: [mem 0xfe020000-0xfe023fff
> > 64bit]
> > <7>[    0.132503] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
> > <7>[    0.132507] pci 0000:00:14.2: PME# disabled
> > <7>[    0.132522] pci 0000:00:14.3: [1002:438d] type 0 class 0x000601
> > <7>[    0.132595] pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
> > <7>[    0.132640] pci 0000:00:18.0: [1022:1100] type 0 class 0x000600
> > <7>[    0.132655] pci 0000:00:18.1: [1022:1101] type 0 class 0x000600
> > <7>[    0.132668] pci 0000:00:18.2: [1022:1102] type 0 class 0x000600
> > <7>[    0.132681] pci 0000:00:18.3: [1022:1103] type 0 class 0x000600
> > <7>[    0.132720] pci 0000:01:05.0: [1002:791e] type 0 class 0x000300
> > <7>[    0.132728] pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff
> > 64bit pref]
> > <7>[    0.132734] pci 0000:01:05.0: reg 18: [mem 0xfdbe0000-0xfdbeffff
> > 64bit]
> > <7>[    0.132738] pci 0000:01:05.0: reg 20: [io  0xde00-0xdeff]
> > <7>[    0.132742] pci 0000:01:05.0: reg 24: [mem 0xfda00000-0xfdafffff]
> > <7>[    0.132753] pci 0000:01:05.0: supports D1 D2
> > <7>[    0.132762] pci 0000:01:05.2: [1002:7919] type 0 class 0x000403
> > <7>[    0.132770] pci 0000:01:05.2: reg 10: [mem 0xfdbfc000-0xfdbfffff
> > 64bit]
> > <6>[    0.132800] pci 0000:00:01.0: PCI bridge to [bus 01-01]
> > <7>[    0.132837] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
> > <7>[    0.132840] pci 0000:00:01.0:   bridge window [mem
> > 0xfda00000-0xfdbfffff]
> > <7>[    0.132844] pci 0000:00:01.0:   bridge window [mem
> > 0xf0000000-0xf7ffffff 64bit pref]
> > <7>[    0.132883] pci 0000:02:00.0: [10ec:8168] type 0 class 0x000200
> > <7>[    0.132897] pci 0000:02:00.0: reg 10: [io  0xee00-0xeeff]
> > <7>[    0.132921] pci 0000:02:00.0: reg 18: [mem 0xfdfff000-0xfdffffff
> > 64bit]
> > <7>[    0.132949] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
> > <7>[    0.133007] pci 0000:02:00.0: supports D1 D2
> > <7>[    0.133008] pci 0000:02:00.0: PME# supported from D1 D2 D3hot D3cold
> > <7>[    0.133013] pci 0000:02:00.0: PME# disabled
> > <6>[    0.133027] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe
> > device.  You can enable it with 'pcie_aspm=force'
> > <6>[    0.133073] pci 0000:00:07.0: PCI bridge to [bus 02-02]
> > <7>[    0.133110] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
> > <7>[    0.133113] pci 0000:00:07.0:   bridge window [mem
> > 0xfdf00000-0xfdffffff]
> > <7>[    0.133116] pci 0000:00:07.0:   bridge window [mem
> > 0xfdc00000-0xfdcfffff 64bit pref]
> > <7>[    0.133151] pci 0000:03:06.0: [1131:7133] type 0 class 0x000480
> > <7>[    0.133173] pci 0000:03:06.0: reg 10: [mem 0xfdeff000-0xfdeff7ff]
> > <7>[    0.133260] pci 0000:03:06.0: supports D1 D2
> > <7>[    0.133284] pci 0000:03:07.0: [1106:3044] type 0 class 0x000c00
> > <7>[    0.133307] pci 0000:03:07.0: reg 10: [mem 0xfdefe000-0xfdefe7ff]
> > <7>[    0.133320] pci 0000:03:07.0: reg 14: [io  0xcf00-0xcf7f]
> > <7>[    0.133401] pci 0000:03:07.0: supports D2
> > <7>[    0.133402] pci 0000:03:07.0: PME# supported from D2 D3hot D3cold
> > <7>[    0.133408] pci 0000:03:07.0: PME# disabled
> > <6>[    0.133452] pci 0000:00:14.4: PCI bridge to [bus 03-03]
> > (subtractive decode)
> > <7>[    0.133490] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
> > <7>[    0.133495] pci 0000:00:14.4:   bridge window [mem
> > 0xfde00000-0xfdefffff]
> > <7>[    0.133499] pci 0000:00:14.4:   bridge window [mem
> > 0xfdd00000-0xfddfffff pref]
> > <7>[    0.133502] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7]
> > (subtractive decode)
> > <7>[    0.133504] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff]
> > (subtractive decode)
> > <7>[    0.133507] pci 0000:00:14.4:   bridge window [mem
> > 0x000a0000-0x000bffff] (subtractive decode)
> > <7>[    0.133509] pci 0000:00:14.4:   bridge window [mem
> > 0x000c0000-0x000dffff] (subtractive decode)
> > <7>[    0.133512] pci 0000:00:14.4:   bridge window [mem
> > 0x80000000-0xfebfffff] (subtractive decode)
> > <7>[    0.133522] pci_bus 0000:00: on NUMA node 0
> > <7>[    0.133525] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> > <7>[    0.133673] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
> > <7>[    0.133740] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE7._PRT]
> > <7>[    0.133765] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
> > <6>[    0.133794]  pci0000:00: Requesting ACPI _OSC control (0x1d)
> > <6>[    0.133830]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND),
> > returned control mask: 0x1d
> > <6>[    0.133869] ACPI _OSC control for PCIe not granted, disabling ASPM
> > <6>[    0.146517] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.147321] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.147709] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.148081] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.148469] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.148856] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.149257] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 10 *11)
> > <6>[    0.149581] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 10 11)
> > *0, disabled.
> > <6>[    0.150017] vgaarb: device added:
> > PCI:0000:01:05.0,decodes=io+mem,owns=io+mem,locks=none
> > <6>[    0.150048] vgaarb: loaded
> > <6>[    0.150081] vgaarb: bridge control possible 0000:01:05.0
> > <5>[    0.150196] SCSI subsystem initialized
> > <7>[    0.150196] libata version 3.00 loaded.
> > <6>[    0.150196] usbcore: registered new interface driver usbfs
> > <6>[    0.150196] usbcore: registered new interface driver hub
> > <6>[    0.150196] usbcore: registered new device driver usb
> > <6>[    0.151009] Advanced Linux Sound Architecture Driver Version 1.0.24.
> > <6>[    0.151045] PCI: Using ACPI for IRQ routing
> > <7>[    0.159993] PCI: pci_cache_line_size set to 64 bytes
> > <7>[    0.160072] reserve RAM buffer: 000000000009f000 - 000000000009ffff
> > <7>[    0.160075] reserve RAM buffer: 0000000077ee0000 - 0000000077ffffff
> > <6>[    0.160095] Bluetooth: Core ver 2.16
> > <6>[    0.160095] NET: Registered protocol family 31
> > <6>[    0.160095] Bluetooth: HCI device and connection manager initialized
> > <6>[    0.160095] Bluetooth: HCI socket layer initialized
> > <6>[    0.160105] Bluetooth: L2CAP socket layer initialized
> > <6>[    0.160144] Bluetooth: SCO socket layer initialized
> > <6>[    0.160144] pnp: PnP ACPI init
> > <6>[    0.160144] ACPI: bus type pnp registered
> > <7>[    0.160199] pnp 00:00: [bus 00-ff]
> > <7>[    0.160202] pnp 00:00: [io  0x0cf8-0x0cff]
> > <7>[    0.160204] pnp 00:00: [io  0x0000-0x0cf7 window]
> > <7>[    0.160207] pnp 00:00: [io  0x0d00-0xffff window]
> > <7>[    0.160209] pnp 00:00: [mem 0x000a0000-0x000bffff window]
> > <7>[    0.160211] pnp 00:00: [mem 0x000c0000-0x000dffff window]
> > <7>[    0.160213] pnp 00:00: [mem 0x80000000-0xfebfffff window]
> > <7>[    0.161015] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
> > <7>[    0.161064] pnp 00:01: [io  0x4100-0x411f]
> > <7>[    0.161066] pnp 00:01: [io  0x0228-0x022f]
> > <7>[    0.161068] pnp 00:01: [io  0x040b]
> > <7>[    0.161070] pnp 00:01: [io  0x04d6]
> > <7>[    0.161072] pnp 00:01: [io  0x0c00-0x0c01]
> > <7>[    0.161074] pnp 00:01: [io  0x0c14]
> > <7>[    0.161076] pnp 00:01: [io  0x0c50-0x0c52]
> > <7>[    0.161078] pnp 00:01: [io  0x0c6c-0x0c6d]
> > <7>[    0.161079] pnp 00:01: [io  0x0c6f]
> > <7>[    0.161081] pnp 00:01: [io  0x0cd0-0x0cd1]
> > <7>[    0.161083] pnp 00:01: [io  0x0cd2-0x0cd3]
> > <7>[    0.161087] pnp 00:01: [io  0x0cd4-0x0cdf]
> > <7>[    0.161089] pnp 00:01: [io  0x4000-0x40fe]
> > <7>[    0.161091] pnp 00:01: [io  0x4210-0x4217]
> > <7>[    0.161093] pnp 00:01: [io  0x0b10-0x0b1f]
> > <7>[    0.161095] pnp 00:01: [mem 0x00000000-0x00000fff window]
> > <7>[    0.161097] pnp 00:01: [mem 0xfee00400-0xfee00fff window]
> > <4>[    0.161131] pnp 00:01: disabling [mem 0x00000000-0x00000fff
> > window] because it overlaps 0000:02:00.0 BAR 6 [mem
> > 0x00000000-0x0001ffff pref]
> > <6>[    0.161198] system 00:01: [io  0x4100-0x411f] has been reserved
> > <6>[    0.161198] system 00:01: [io  0x0228-0x022f] has been reserved
> > <6>[    0.161198] system 00:01: [io  0x040b] has been reserved
> > <6>[    0.161198] system 00:01: [io  0x04d6] has been reserved
> > <6>[    0.163988] system 00:01: [io  0x0c00-0x0c01] has been reserved
> > <6>[    0.164023] system 00:01: [io  0x0c14] has been reserved
> > <6>[    0.164058] system 00:01: [io  0x0c50-0x0c52] has been reserved
> > <6>[    0.164094] system 00:01: [io  0x0c6c-0x0c6d] has been reserved
> > <6>[    0.164129] system 00:01: [io  0x0c6f] has been reserved
> > <6>[    0.164164] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
> > <6>[    0.164199] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
> > <6>[    0.164235] system 00:01: [io  0x0cd4-0x0cdf] has been reserved
> > <6>[    0.164270] system 00:01: [io  0x4000-0x40fe] has been reserved
> > <6>[    0.164306] system 00:01: [io  0x4210-0x4217] has been reserved
> > <6>[    0.164342] system 00:01: [io  0x0b10-0x0b1f] has been reserved
> > <6>[    0.164378] system 00:01: [mem 0xfee00400-0xfee00fff window] has
> > been reserved
> > <7>[    0.164418] system 00:01: Plug and Play ACPI device, IDs PNP0c02
> > (active)
> > <7>[    0.164505] pnp 00:02: [dma 4]
> > <7>[    0.164507] pnp 00:02: [io  0x0000-0x000f]
> > <7>[    0.164509] pnp 00:02: [io  0x0080-0x0090]
> > <7>[    0.164511] pnp 00:02: [io  0x0094-0x009f]
> > <7>[    0.164513] pnp 00:02: [io  0x00c0-0x00df]
> > <7>[    0.164538] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
> > <7>[    0.164538] pnp 00:03: [io  0x0070-0x0073]
> > <7>[    0.164538] pnp 00:03: [irq 8]
> > <7>[    0.164538] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
> > <7>[    0.164538] pnp 00:04: [io  0x0061]
> > <7>[    0.164538] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
> > <7>[    0.164538] pnp 00:05: [io  0x00f0-0x00ff]
> > <7>[    0.164538] pnp 00:05: [irq 13]
> > <7>[    0.164997] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
> > <7>[    0.165014] pnp 00:06: [io  0x0010-0x001f]
> > <7>[    0.165015] pnp 00:06: [io  0x0022-0x003f]
> > <7>[    0.165017] pnp 00:06: [io  0x0044-0x005f]
> > <7>[    0.165019] pnp 00:06: [io  0x0062-0x0063]
> > <7>[    0.165021] pnp 00:06: [io  0x0065-0x006f]
> > <7>[    0.165023] pnp 00:06: [io  0x0074-0x007f]
> > <7>[    0.165025] pnp 00:06: [io  0x0091-0x0093]
> > <7>[    0.165027] pnp 00:06: [io  0x00a2-0x00bf]
> > <7>[    0.165029] pnp 00:06: [io  0x00e0-0x00ef]
> > <7>[    0.165031] pnp 00:06: [io  0x04d0-0x04d1]
> > <7>[    0.165033] pnp 00:06: [io  0x0220-0x0225]
> > <6>[    0.165080] system 00:06: [io  0x04d0-0x04d1] has been reserved
> > <6>[    0.165080] system 00:06: [io  0x0220-0x0225] has been reserved
> > <7>[    0.165080] system 00:06: Plug and Play ACPI device, IDs PNP0c02
> > (active)
> > <7>[    0.165195] pnp 00:07: [io  0x03f0-0x03f5]
> > <7>[    0.165197] pnp 00:07: [io  0x03f7]
> > <7>[    0.165206] pnp 00:07: [irq 6]
> > <7>[    0.165208] pnp 00:07: [dma 2]
> > <7>[    0.165252] pnp 00:07: Plug and Play ACPI device, IDs PNP0700 (active)
> > <7>[    0.165252] pnp 00:08: [io  0x03f8-0x03ff]
> > <7>[    0.165252] pnp 00:08: [irq 4]
> > <7>[    0.165252] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
> > <7>[    0.165252] pnp 00:09: [io  0x0378-0x037f]
> > <7>[    0.165253] pnp 00:09: [irq 7]
> > <7>[    0.165301] pnp 00:09: Plug and Play ACPI device, IDs PNP0400 (active)
> > <7>[    0.166061] pnp 00:0a: [mem 0xe0000000-0xefffffff]
> > <6>[    0.166105] system 00:0a: [mem 0xe0000000-0xefffffff] has been
> > reserved
> > <7>[    0.166105] system 00:0a: Plug and Play ACPI device, IDs PNP0c02
> > (active)
> > <7>[    0.166157] pnp 00:0b: [mem 0x000cd600-0x000cffff]
> > <7>[    0.166159] pnp 00:0b: [mem 0x000f0000-0x000f7fff]
> > <7>[    0.166161] pnp 00:0b: [mem 0x000f8000-0x000fbfff]
> > <7>[    0.166163] pnp 00:0b: [mem 0x000fc000-0x000fffff]
> > <7>[    0.166165] pnp 00:0b: [mem 0x77ef0000-0x77feffff]
> > <7>[    0.166167] pnp 00:0b: [mem 0xfed00000-0xfed000ff]
> > <7>[    0.166171] pnp 00:0b: [mem 0x77ee0000-0x77efffff]
> > <7>[    0.166173] pnp 00:0b: [mem 0xffff0000-0xffffffff]
> > <7>[    0.166175] pnp 00:0b: [mem 0x00000000-0x0009ffff]
> > <7>[    0.166177] pnp 00:0b: [mem 0x00100000-0x77edffff]
> > <7>[    0.166180] pnp 00:0b: [mem 0x77ff0000-0x7ffeffff]
> > <7>[    0.166182] pnp 00:0b: [mem 0xfec00000-0xfec00fff]
> > <7>[    0.166184] pnp 00:0b: [mem 0xfee00000-0xfee00fff]
> > <7>[    0.166186] pnp 00:0b: [mem 0xfff80000-0xfffeffff]
> > <6>[    0.166237] system 00:0b: [mem 0x000cd600-0x000cffff] has been
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0x000f0000-0x000f7fff] could not be
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0x000f8000-0x000fbfff] could not be
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0x000fc000-0x000fffff] could not be
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0x77ef0000-0x77feffff] could not be
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0xfed00000-0xfed000ff] has been
> > reserved
> > <6>[    0.166237] system 00:0b: [mem 0x77ee0000-0x77efffff] could not be
> > reserved
> > <6>[    0.166251] system 00:0b: [mem 0xffff0000-0xffffffff] has been
> > reserved
> > <6>[    0.166288] system 00:0b: [mem 0x00000000-0x0009ffff] could not be
> > reserved
> > <6>[    0.166324] system 00:0b: [mem 0x00100000-0x77edffff] could not be
> > reserved
> > <6>[    0.166360] system 00:0b: [mem 0x77ff0000-0x7ffeffff] could not be
> > reserved
> > <6>[    0.166396] system 00:0b: [mem 0xfec00000-0xfec00fff] could not be
> > reserved
> > <6>[    0.166432] system 00:0b: [mem 0xfee00000-0xfee00fff] could not be
> > reserved
> > <6>[    0.166468] system 00:0b: [mem 0xfff80000-0xfffeffff] has been
> > reserved
> > <7>[    0.166504] system 00:0b: Plug and Play ACPI device, IDs PNP0c01
> > (active)
> > <6>[    0.166511] pnp: PnP ACPI: found 12 devices
> > <6>[    0.166545] ACPI: ACPI bus type pnp unregistered
> > <6>[    0.174647] Switching to clocksource acpi_pm
> > <7>[    0.174723] PCI: max bus depth: 1 pci_try_num: 2
> > <6>[    0.174741] pci 0000:00:01.0: PCI bridge to [bus 01-01]
> > <6>[    0.174777] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
> > <6>[    0.174814] pci 0000:00:01.0:   bridge window [mem
> > 0xfda00000-0xfdbfffff]
> > <6>[    0.174850] pci 0000:00:01.0:   bridge window [mem
> > 0xf0000000-0xf7ffffff 64bit pref]
> > <6>[    0.174894] pci 0000:02:00.0: BAR 6: assigned [mem
> > 0xfdc00000-0xfdc1ffff pref]
> > <6>[    0.174933] pci 0000:00:07.0: PCI bridge to [bus 02-02]
> > <6>[    0.174690] Switched to NOHz mode on CPU #0
> > <6>[    0.174933] Switched to NOHz mode on CPU #1
> > <6>[    0.174933] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
> > <6>[    0.174933] pci 0000:00:07.0:   bridge window [mem
> > 0xfdf00000-0xfdffffff]
> > <6>[    0.174933] pci 0000:00:07.0:   bridge window [mem
> > 0xfdc00000-0xfdcfffff 64bit pref]
> > <6>[    0.174933] pci 0000:00:14.4: PCI bridge to [bus 03-03]
> > <6>[    0.174933] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
> > <6>[    0.174933] pci 0000:00:14.4:   bridge window [mem
> > 0xfde00000-0xfdefffff]
> > <6>[    0.174933] pci 0000:00:14.4:   bridge window [mem
> > 0xfdd00000-0xfddfffff pref]
> > <7>[    0.174933] pci 0000:00:07.0: setting latency timer to 64
> > <7>[    0.174933] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
> > <7>[    0.174933] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
> > <7>[    0.174933] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
> > <7>[    0.174933] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000dffff]
> > <7>[    0.174933] pci_bus 0000:00: resource 8 [mem 0x80000000-0xfebfffff]
> > <7>[    0.174933] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
> > <7>[    0.174933] pci_bus 0000:01: resource 1 [mem 0xfda00000-0xfdbfffff]
> > <7>[    0.174933] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff
> > 64bit pref]
> > <7>[    0.174933] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
> > <7>[    0.174933] pci_bus 0000:02: resource 1 [mem 0xfdf00000-0xfdffffff]
> > <7>[    0.174933] pci_bus 0000:02: resource 2 [mem 0xfdc00000-0xfdcfffff
> > 64bit pref]
> > <7>[    0.174933] pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
> > <7>[    0.174933] pci_bus 0000:03: resource 1 [mem 0xfde00000-0xfdefffff]
> > <7>[    0.174933] pci_bus 0000:03: resource 2 [mem 0xfdd00000-0xfddfffff
> > pref]
> > <7>[    0.174933] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
> > <7>[    0.174933] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
> > <7>[    0.174933] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
> > <7>[    0.174933] pci_bus 0000:03: resource 7 [mem 0x000c0000-0x000dffff]
> > <7>[    0.174933] pci_bus 0000:03: resource 8 [mem 0x80000000-0xfebfffff]
> > <6>[    0.174933] NET: Registered protocol family 2
> > <6>[    0.174933] IP route cache hash table entries: 65536 (order: 7,
> > 524288 bytes)
> > <6>[    0.175314] TCP established hash table entries: 262144 (order: 10,
> > 4194304 bytes)
> > <6>[    0.177783] TCP bind hash table entries: 65536 (order: 8, 1048576
> > bytes)
> > <6>[    0.178410] TCP: Hash tables configured (established 262144 bind
> > 65536)
> > <6>[    0.178446] TCP reno registered
> > <6>[    0.178482] UDP hash table entries: 1024 (order: 3, 32768 bytes)
> > <6>[    0.178534] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
> > <6>[    0.178723] NET: Registered protocol family 1
> > <6>[    0.178863] RPC: Registered named UNIX socket transport module.
> > <6>[    0.178900] RPC: Registered udp transport module.
> > <6>[    0.178934] RPC: Registered tcp transport module.
> > <6>[    0.178969] RPC: Registered tcp NFSv4.1 backchannel transport module.
> > <7>[    0.385043] pci 0000:01:05.0: Boot video device
> > <7>[    0.385055] PCI: CLS 32 bytes, default 64
> > <6>[    0.386163] audit: initializing netlink socket (disabled)
> > <5>[    0.386207] type=2000 audit(1316374513.386:1): initialized
> > <6>[    0.393104] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> > <6>[    0.393446] msgmni has been set to 3501
> > <6>[    0.393892] Block layer SCSI generic (bsg) driver version 0.4
> > loaded (major 253)
> > <6>[    0.393933] io scheduler noop registered
> > <6>[    0.393986] io scheduler cfq registered (default)
> > <7>[    0.394179] pcieport 0000:00:07.0: setting latency timer to 64
> > <7>[    0.394205] pcieport 0000:00:07.0: irq 40 for MSI/MSI-X
> > <6>[    0.394864] input: Power Button as
> > /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
> > <6>[    0.394909] ACPI: Power Button [PWRB]
> > <6>[    0.395047] input: Power Button as
> > /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> > <6>[    0.395087] ACPI: Power Button [PWRF]
> > <6>[    0.395230] ACPI: Fan [FAN] (on)
> > <7>[    0.395360] ACPI: acpi_idle registered with cpuidle
> > <4>[    0.396661] ACPI Warning: For \_TZ_.THRM._PSL: Return Package has
> > no elements (empty) (20110413/nspredef-456)
> > <3>[    0.396763] ACPI: [Package] has zero elements (ffff8800742f1f40)
> > <4>[    0.396798] ACPI: Invalid passive threshold
> > <6>[    0.396978] thermal LNXTHERM:00: registered as thermal_zone0
> > <6>[    0.397047] ACPI: Thermal Zone [THRM] (40 C)
> > <6>[    0.397129] ERST: Table is not found!
> > <6>[    0.397250] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> > <6>[    0.417954] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> > <6>[    0.496800] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> > <6>[    0.508337] [drm] Initialized drm 1.1.0 20060810
> > <6>[    0.508423] [drm] radeon defaulting to kernel modesetting.
> > <6>[    0.508459] [drm] radeon kernel modesetting enabled.
> > <6>[    0.508545] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
> > -> IRQ 18
> > <6>[    0.508762] [drm] initializing kernel modesetting (RS690
> > 0x1002:0x791E 0x1043:0x826D).
> > <6>[    0.508817] [drm] register mmio base: 0xFDBE0000
> > <6>[    0.508852] [drm] register mmio size: 65536
> > <6>[    0.510386] ATOM BIOS: ATI
> > <6>[    0.510436] radeon 0000:01:05.0: VRAM: 128M 0x0000000078000000 -
> > 0x000000007FFFFFFF (128M used)
> > <6>[    0.510476] radeon 0000:01:05.0: GTT: 512M 0x0000000080000000 -
> > 0x000000009FFFFFFF
> > <6>[    0.510516] [drm] Supports vblank timestamp caching Rev 1
> > (10.10.2010).
> > <6>[    0.510552] [drm] Driver supports precise vblank timestamp query.
> > <6>[    0.510611] [drm] radeon: irq initialized.
> > <6>[    0.511162] [drm] Detected VRAM RAM=128M, BAR=128M
> > <6>[    0.511202] [drm] RAM width 128bits DDR
> > <6>[    0.511317] [TTM] Zone  kernel: Available graphics memory: 896440 kiB.
> > <6>[    0.511356] [TTM] Initializing pool allocator.
> > <6>[    0.511416] [drm] radeon: 128M of VRAM memory ready
> > <6>[    0.511451] [drm] radeon: 512M of GTT memory ready.
> > <6>[    0.511487] [drm] GART: num cpu pages 131072, num gpu pages 131072
> > <6>[    0.515340] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
> > <6>[    0.521223] radeon 0000:01:05.0: WB enabled
> > <6>[    0.521358] [drm] Loading RS690/RS740 Microcode
> > <6>[    0.521544] [drm] radeon: ring at 0x0000000080001000
> > <6>[    0.521595] [drm] ring test succeeded in 1 usecs
> > <6>[    0.521725] [drm] radeon: ib pool ready.
> > <6>[    0.521771] [drm] ib test succeeded in 0 usecs
> > <7>[    0.521809] failed to evaluate ATIF got AE_BAD_PARAMETER
> > <6>[    0.522489] [drm] Radeon Display Connectors
> > <6>[    0.522524] [drm] Connector 0:
> > <6>[    0.522557] [drm]   VGA
> > <6>[    0.522591] [drm]   DDC: 0x7e50 0x7e40 0x7e54 0x7e44 0x7e58 0x7e48
> > 0x7e5c 0x7e4c
> > <6>[    0.522629] [drm]   Encoders:
> > <6>[    0.522662] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
> > <6>[    0.522696] [drm] Connector 1:
> > <6>[    0.522729] [drm]   S-video
> > <6>[    0.522762] [drm]   Encoders:
> > <6>[    0.522795] [drm]     TV1: INTERNAL_KLDSCP_DAC1
> > <6>[    0.522829] [drm] Connector 2:
> > <6>[    0.522862] [drm]   HDMI-A
> > <6>[    0.522895] [drm]   HPD2
> > <6>[    0.522929] [drm]   DDC: 0x7e40 0x7e60 0x7e44 0x7e64 0x7e48 0x7e68
> > 0x7e4c 0x7e6c
> > <6>[    0.522967] [drm]   Encoders:
> > <6>[    0.523016] [drm]     DFP2: INTERNAL_DDI
> > <6>[    0.523049] [drm] Connector 3:
> > <6>[    0.523082] [drm]   DVI-D
> > <6>[    0.523116] [drm]   DDC: 0x7e40 0x7e50 0x7e44 0x7e54 0x7e48 0x7e58
> > 0x7e4c 0x7e5c
> > <6>[    0.523154] [drm]   Encoders:
> > <6>[    0.523187] [drm]     DFP3: INTERNAL_LVTM1
> > <6>[    0.574522] [drm] Radeon display connector VGA-1: Found valid EDID
> > <6>[    0.675501] [drm] Radeon display connector HDMI-A-1: Found valid EDID
> > <6>[    0.685115] [drm] Radeon display connector DVI-D-1: No monitor
> > connected or invalid EDID
> > <6>[    0.933839] [drm] fb mappable at 0xF0040000
> > <6>[    0.933905] [drm] vram apper at 0xF0000000
> > <6>[    0.933938] [drm] size 8294400
> > <6>[    0.933972] [drm] fb depth is 24
> > <6>[    0.934014] [drm]    pitch is 7680
> > <6>[    0.934131] fbcon: radeondrmfb (fb0) is primary device
> > <6>[    0.962975] Console: switching to colour frame buffer device 240x67
> > <6>[    0.972371] fb0: radeondrmfb frame buffer device
> > <6>[    0.972410] drm: registered panic notifier
> > <6>[    0.972440] [drm] Initialized radeon 2.10.0 20080528 for
> > 0000:01:05.0 on minor 0
> > <6>[    0.974922] brd: module loaded
> > <6>[    0.976129] loop: module loaded
> > <6>[    0.976212] Uniform Multi-Platform E-IDE driver
> > <6>[    0.976392] ide-gd driver 1.18
> > <7>[    0.976659] ahci 0000:00:12.0: version 3.0
> > <6>[    0.976682] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
> > IRQ 22
> > <4>[    0.976746] ahci 0000:00:12.0: ASUS M2A-VM: enabling 64bit DMA
> > <6>[    0.976894] ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3
> > Gbps 0xf impl SATA mode
> > <6>[    0.976948] ahci 0000:00:12.0: flags: 64bit ncq sntf ilck pm led
> > clo pmp pio slum part ccc
> > <6>[    0.978388] scsi0 : ahci
> > <6>[    0.978657] scsi1 : ahci
> > <6>[    0.978850] scsi2 : ahci
> > <6>[    0.979043] scsi3 : ahci
> > <6>[    0.979251] ata1: SATA max UDMA/133 abar m1024@0xfe02f000 port
> > 0xfe02f100 irq 22
> > <6>[    0.979311] ata2: SATA max UDMA/133 abar m1024@0xfe02f000 port
> > 0xfe02f180 irq 22
> > <6>[    0.979371] ata3: SATA max UDMA/133 abar m1024@0xfe02f000 port
> > 0xfe02f200 irq 22
> > <6>[    0.979430] ata4: SATA max UDMA/133 abar m1024@0xfe02f000 port
> > 0xfe02f280 irq 22
> > <6>[    0.979764] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > <6>[    0.979841] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)
> > -> IRQ 19
> > <7>[    0.979922] r8169 0000:02:00.0: setting latency timer to 64
> > <7>[    0.979974] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
> > <6>[    0.980235] r8169 0000:02:00.0: eth0: RTL8168b/8111b at
> > 0xffffc9000000c000, 00:1b:fc:89:fa:a2, XID 18000000 IRQ 41
> > <6>[    0.980386] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> > <6>[    0.980467] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
> > low) -> IRQ 19
> > <6>[    0.980535] ehci_hcd 0000:00:13.5: EHCI Host Controller
> > <6>[    0.980580] ehci_hcd 0000:00:13.5: new USB bus registered,
> > assigned bus number 1
> > <6>[    0.980660] ehci_hcd 0000:00:13.5: applying AMD SB600/SB700 USB
> > freeze workaround
> > <6>[    0.980729] ehci_hcd 0000:00:13.5: debug port 1
> > <6>[    0.980795] ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
> > <6>[    0.986023] ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00
> > <6>[    0.986250] hub 1-0:1.0: USB hub found
> > <6>[    0.986283] hub 1-0:1.0: 10 ports detected
> > <6>[    0.986444] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> > <6>[    0.986509] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[    0.986569] ohci_hcd 0000:00:13.0: OHCI Host Controller
> > <6>[    0.986610] ohci_hcd 0000:00:13.0: new USB bus registered,
> > assigned bus number 2
> > <6>[    0.986695] ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
> > <6>[    1.041189] hub 2-0:1.0: USB hub found
> > <6>[    1.041222] hub 2-0:1.0: 2 ports detected
> > <6>[    1.041307] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[    1.041366] ohci_hcd 0000:00:13.1: OHCI Host Controller
> > <6>[    1.041408] ohci_hcd 0000:00:13.1: new USB bus registered,
> > assigned bus number 3
> > <6>[    1.043218] ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
> > <6>[    1.099184] hub 3-0:1.0: USB hub found
> > <6>[    1.100980] hub 3-0:1.0: 2 ports detected
> > <6>[    1.102820] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[    1.104652] ohci_hcd 0000:00:13.2: OHCI Host Controller
> > <6>[    1.106404] ohci_hcd 0000:00:13.2: new USB bus registered,
> > assigned bus number 4
> > <6>[    1.108236] ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
> > <6>[    1.165198] hub 4-0:1.0: USB hub found
> > <6>[    1.167032] hub 4-0:1.0: 2 ports detected
> > <6>[    1.168884] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[    1.170721] ohci_hcd 0000:00:13.3: OHCI Host Controller
> > <6>[    1.172563] ohci_hcd 0000:00:13.3: new USB bus registered,
> > assigned bus number 5
> > <6>[    1.174331] ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
> > <6>[    1.231189] hub 5-0:1.0: USB hub found
> > <6>[    1.232980] hub 5-0:1.0: 2 ports detected
> > <6>[    1.234800] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[    1.236628] ohci_hcd 0000:00:13.4: OHCI Host Controller
> > <6>[    1.238457] ohci_hcd 0000:00:13.4: new USB bus registered,
> > assigned bus number 6
> > <6>[    1.240300] ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe02a000
> > <6>[    1.297187] hub 6-0:1.0: USB hub found
> > <6>[    1.298966] hub 6-0:1.0: 2 ports detected
> > <6>[    1.301069] i8042: PNP: No PS/2 controller found. Probing ports
> > directly.
> > <6>[    1.303316] serio: i8042 KBD port at 0x60,0x64 irq 1
> > <6>[    1.305153] serio: i8042 AUX port at 0x60,0x64 irq 12
> > <6>[    1.307032] mousedev: PS/2 mouse device common for all mice
> > <4>[    1.309117] k8temp 0000:00:18.3: Temperature readouts might be
> > wrong - check erratum #141
> > <6>[    1.310999] md: linear personality registered for level -1
> > <6>[    1.312854] device-mapper: uevent: version 1.0.3
> > <6>[    1.314739] device-mapper: ioctl: 4.20.0-ioctl (2011-02-02)
> > initialised: dm-devel@redhat.com
> > <6>[    1.316569] Bluetooth: Generic Bluetooth USB driver ver 0.6
> > <6>[    1.318439] usbcore: registered new interface driver btusb
> > <6>[    1.320251] cpuidle: using governor ladder
> > <6>[    1.322080] cpuidle: using governor menu
> > <6>[    1.324308] ALSA device list:
> > <6>[    1.326177]   No soundcards found.
> > <6>[    1.327923] TCP cubic registered
> > <6>[    1.329757] NET: Registered protocol family 17
> > <6>[    1.331657] Bluetooth: RFCOMM TTY layer initialized
> > <6>[    1.333581] Bluetooth: RFCOMM socket layer initialized
> > <6>[    1.335458] Bluetooth: RFCOMM ver 1.11
> > <6>[    1.337296] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> > <6>[    1.339102] Bluetooth: BNEP filters: protocol multicast
> > <6>[    1.340805] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
> > <3>[    1.439021] ata2: softreset failed (device not ready)
> > <4>[    1.440767] ata2: applying SB600 PMP SRST workaround and retrying
> > <3>[    1.442560] ata4: softreset failed (device not ready)
> > <4>[    1.444252] ata4: applying SB600 PMP SRST workaround and retrying
> > <3>[    1.446052] ata1: softreset failed (device not ready)
> > <4>[    1.447873] ata1: applying SB600 PMP SRST workaround and retrying
> > <3>[    1.449704] ata3: softreset failed (device not ready)
> > <4>[    1.451614] ata3: applying SB600 PMP SRST workaround and retrying
> > <6>[    1.570017] usb 3-2: new full speed USB device number 2 using ohci_hcd
> > <6>[    1.606033] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[    1.607842] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[    1.609683] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> > <6>[    1.611455] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[    1.613286] ata4.00: ATAPI: TSSTcorp CDDVDW SH-S203P, SB00, max
> > UDMA/100
> > <6>[    1.615096] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.617016] ata2.00: ATA-8: WDC WD15EADS-00P8B0, 01.00A01, max
> > UDMA/133
> > <6>[    1.618805] ata2.00: 2930277168 sectors, multi 1: LBA48 NCQ (depth
> > 31/32), AA
> > <6>[    1.620598] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.622392] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-11, max UDMA7
> > <6>[    1.624159] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth
> > 31/32), AA
> > <6>[    1.625979] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.628308] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.630140] ata4.00: configured for UDMA/100
> > <6>[    1.632082] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.633901] ata1.00: configured for UDMA/133
> > <6>[    1.635707] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.637549] ata2.00: configured for UDMA/133
> > <6>[    1.644223] ata3.00: ATA-8: WDC WD3200BEVT-00ZCT0, 11.01A11, max
> > UDMA/133
> > <6>[    1.646082] ata3.00: 625142448 sectors, multi 1: LBA48 NCQ (depth
> > 31/32), AA
> > <5>[    1.646224] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG
> > HD501LJ  CR10 PQ: 0 ANSI: 5
> > <6>[    1.649806] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <5>[    1.651903] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks:
> > (500 GB/465 GiB)
> > <6>[    1.652618] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[    1.652620] ata3.00: configured for UDMA/133
> > <5>[    1.657496] sd 0:0:0:0: [sda] Write Protect is off
> > <5>[    1.657524] scsi 1:0:0:0: Direct-Access     ATA      WDC
> > WD15EADS-00P 01.0 PQ: 0 ANSI: 5
> > <7>[    1.661219] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> > <5>[    1.661238] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
> > enabled, doesn't support DPO or FUA
> > <5>[    1.661388] sd 1:0:0:0: [sdb] 2930277168 512-byte logical blocks:
> > (1.50 TB/1.36 TiB)
> > <5>[    1.661419] sd 1:0:0:0: [sdb] Write Protect is off
> > <7>[    1.661422] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
> > <5>[    1.661436] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
> > enabled, doesn't support DPO or FUA
> > <5>[    1.669349] scsi 2:0:0:0: Direct-Access     ATA      WDC
> > WD3200BEVT-0 11.0 PQ: 0 ANSI: 5
> > <5>[    1.671527] sd 2:0:0:0: [sdc] 625142448 512-byte logical blocks:
> > (320 GB/298 GiB)
> > <5>[    1.673606] sd 2:0:0:0: [sdc] Write Protect is off
> > <5>[    1.673828] scsi 3:0:0:0: CD-ROM            TSSTcorp CDDVDW
> > SH-S203P  SB00 PQ: 0 ANSI: 5
> > <4>[    1.676196] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw
> > xa/form2 cdda tray
> > <6>[    1.676198] cdrom: Uniform CD-ROM driver Revision: 3.20
> > <7>[    1.676313] sr 3:0:0:0: Attached scsi CD-ROM sr0
> > <6>[    1.679780]  sda: sda1 sda2 sda3 sda4
> > <6>[    1.683344]  sdb: sdb1 sdb2 sdb3 sdb4
> > <5>[    1.683535] sd 0:0:0:0: [sda] Attached SCSI disk
> > <7>[    1.683545] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
> > <5>[    1.683561] sd 2:0:0:0: [sdc] Write cache: enabled, read cache:
> > enabled, doesn't support DPO or FUA
> > <5>[    1.689674] sd 1:0:0:0: [sdb] Attached SCSI disk
> > <6>[    1.748675]  sdc: sdc1 sdc2 sdc3 sdc4 < sdc5 sdc6 sdc7 sdc8 >
> > <5>[    1.751473] sd 2:0:0:0: [sdc] Attached SCSI disk
> > <3>[    1.753929] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
> > <6>[    1.756034] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core
> > Processor 5600+ (2 cpu cores) (version 2.20.00)
> > <6>[    1.758126] powernow-k8: fid 0x14 (2800 MHz), vid 0x8
> > <6>[    1.760103] powernow-k8: fid 0x12 (2600 MHz), vid 0xa
> > <6>[    1.762173] powernow-k8: fid 0x10 (2400 MHz), vid 0xc
> > <6>[    1.764224] powernow-k8: fid 0xe (2200 MHz), vid 0xe
> > <6>[    1.766280] powernow-k8: fid 0xc (2000 MHz), vid 0x10
> > <6>[    1.768317] powernow-k8: fid 0xa (1800 MHz), vid 0x10
> > <6>[    1.770357] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
> > <6>[    1.772504] md: Skipping autodetection of RAID arrays.
> > (raid=autodetect will force)
> > <6>[    1.794375] EXT3-fs (sda3): recovery required on readonly filesystem
> > <6>[    1.796428] EXT3-fs (sda3): write access will be enabled during
> > recovery
> > <6>[    1.805899] EXT3-fs: barriers not enabled
> > <6>[    1.824514] kjournald starting.  Commit interval 5 seconds
> > <6>[    1.824595] EXT3-fs (sda3): recovery complete
> > <6>[    1.835108] EXT3-fs (sda3): mounted filesystem with writeback data
> > mode
> > <6>[    1.840311] VFS: Mounted root (ext3 filesystem) readonly on device
> > 8:3.
> > <6>[    1.845604] Freeing unused kernel memory: 464k freed
> > <6>[    1.868037] usb 5-1: new low speed USB device number 2 using ohci_hcd
> > <6>[    6.958459] udev[1059]: starting version 164
> > <6>[    7.174260] atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev
> > 0x00)
> > <6>[    7.174277] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[    7.174295] atiixp 0000:00:14.1: not 100% native mode: will probe
> > irqs later
> > <6>[    7.174303]     ide0: BM-DMA at 0xf900-0xf907
> > <7>[    7.174310] Probing IDE interface ide0...
> > <6>[    7.323529] input: PC Speaker as /devices/platform/pcspkr/input/input2
> > <6>[    7.427754] rtc_cmos 00:03: RTC can wake from S4
> > <6>[    7.427992] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> > <6>[    7.428080] rtc0: alarms up to one month, 242 bytes nvram
> > <6>[    7.462953] Linux video capture interface: v2.00
> > <5>[    7.540836] sd 0:0:0:0: Attached scsi generic sg0 type 0
> > <5>[    7.540922] sd 1:0:0:0: Attached scsi generic sg1 type 0
> > <5>[    7.541000] sd 2:0:0:0: Attached scsi generic sg2 type 0
> > <5>[    7.541097] sr 3:0:0:0: Attached scsi generic sg3 type 5
> > <6>[    7.687199] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> > <6>[    7.687388] piix4_smbus 0000:00:14.0: SMBus Host Controller at
> > 0xb00, revision 0
> > <6>[    7.764840] input: iMON Panel, Knob and Mouse(15c2:ffdc) as
> > /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/input/input3
> > <6>[    7.772293] IR NEC protocol handler initialized
> > <6>[    7.785025] imon 5-1:1.0: 0xffdc iMON VFD, MCE IR (id 0x9e)
> > <6>[    7.843023] Registered IR keymap rc-imon-mce
> > <6>[    7.843293] input: iMON Remote (15c2:ffdc) as
> > /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0/input4
> > <6>[    7.843388] rc0: iMON Remote (15c2:ffdc) as
> > /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0
> > <6>[    7.857208] imon 5-1:1.0: iMON device (15c2:ffdc, intf0) on
> > usb<5:2> initialized
> > <6>[    7.857254] usbcore: registered new interface driver imon
> > <6>[    7.911900] saa7130/34: v4l2 driver version 0.2.16 loaded
> > <6>[    7.912064] saa7134 0000:03:06.0: PCI INT A -> GSI 21 (level, low)
> > -> IRQ 21
> > <6>[    7.912078] saa7133[0]: found at 0000:03:06.0, rev: 209, irq: 21,
> > latency: 64, mmio: 0xfdeff000
> > <6>[    7.912094] saa7133[0]: subsystem: 11bd:002f, board: Pinnacle PCTV
> > 310i [card=101,autodetected]
> > <6>[    7.912145] saa7133[0]: board init: gpio is 600e000
> > <6>[    7.931260] IT8716 SuperIO detected.
> > <6>[    7.932094] parport_pc 00:09: reported by Plug and Play ACPI
> > <6>[    7.932134] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
> > <4>[    8.015378] saa7133[0]: i2c eeprom read error (err=-5)
> > <6>[    8.129842] IR RC5(x) protocol handler initialized
> > <6>[    8.180277] IR RC6 protocol handler initialized
> > <4>[    8.180688] i2c-core: driver [tuner] using legacy suspend method
> > <4>[    8.180697] i2c-core: driver [tuner] using legacy resume method
> > <6>[    8.302205] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[    8.454573] IR JVC protocol handler initialized
> > <6>[    8.486162] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
> > low) -> IRQ 19
> > <7>[    8.486241] HDA Intel 0000:01:05.2: irq 42 for MSI/MSI-X
> > <6>[    8.490533] IR Sony protocol handler initialized
> > <6>[    8.514675] lirc_dev: IR Remote Control driver registered, major 252
> > <6>[    8.523937] IR LIRC bridge handler initialized
> > <6>[    8.551033] tuner 5-004b: Tuner -1 found with type(s) Radio TV.
> > <6>[    8.586028] tda829x 5-004b: setting tuner address to 61
> > <6>[    8.627490] tda829x 5-004b: ANDERS: setting switch_addr. was 0x00,
> > new 0x4b
> > <6>[    8.627499] tda829x 5-004b: ANDERS: new 0x61
> > <6>[    8.633026] tda829x 5-004b: type set to tda8290+75a
> > <4>[   11.493010] hda-intel: azx_get_response timeout, switching to
> > polling mode: last cmd=0x000f0000
> > <6>[   11.623087] saa7133[0]: registered device video0 [v4l2]
> > <6>[   11.623130] saa7133[0]: registered device vbi0
> > <6>[   11.623168] saa7133[0]: registered device radio0
> > <6>[   11.644660] dvb_init() allocating 1 frontend
> > <6>[   11.690027] DVB: registering new adapter (saa7133[0])
> > <4>[   11.690032] DVB: registering adapter 0 frontend 0 (Philips
> > TDA10046H DVB-T)...
> > <6>[   11.756020] tda1004x: setting up plls for 48MHz sampling clock
> > <4>[   12.494013] hda-intel: No response from codec, disabling MSI: last
> > cmd=0x000f0000
> > <4>[   13.495013] hda-intel: Codec #0 probe error; disabling it...
> > <3>[   13.909022] tda1004x: timeout waiting for DSP ready
> > <6>[   13.919019] tda1004x: found firmware revision 0 -- invalid
> > <6>[   13.919022] tda1004x: trying to boot from eeprom
> > <3>[   15.606012] hda_intel: azx_get_response timeout, switching to
> > single_cmd mode: last cmd=0x00070503
> > <3>[   15.607796] hda-codec: No codec parser is available
> > <6>[   15.877023] tda1004x: found firmware revision 0 -- invalid
> > <6>[   15.877031] tda1004x: waiting for firmware upload...
> > <3>[   15.953447] tda1004x: no firmware upload (timeout or file not found?)
> > <4>[   15.953453] tda1004x: firmware upload failed
> > <6>[   16.078174] saa7134 ALSA driver for DMA sound loaded
> > <6>[   16.078229] saa7133[0]/alsa: saa7133[0] at 0xfdeff000 irq 21
> > registered as card -1
> > <6>[   41.755581] EXT3-fs (sda3): using internal journal
> > <6>[   41.937882] EXT3-fs: barriers not enabled
> > <6>[   41.940227] kjournald starting.  Commit interval 5 seconds
> > <6>[   41.940590] EXT3-fs (sda1): using internal journal
> > <6>[   41.940602] EXT3-fs (sda1): mounted filesystem with writeback data
> > mode
> > <6>[   41.962540] EXT3-fs: barriers not enabled
> > <6>[   41.975332] kjournald starting.  Commit interval 5 seconds
> > <6>[   41.975652] EXT3-fs (dm-1): using internal journal
> > <6>[   41.975660] EXT3-fs (dm-1): mounted filesystem with writeback data
> > mode
> > <6>[   42.063644] EXT3-fs: barriers not enabled
> > <6>[   42.072233] kjournald starting.  Commit interval 5 seconds
> > <6>[   42.072551] EXT3-fs (dm-2): using internal journal
> > <6>[   42.072560] EXT3-fs (dm-2): mounted filesystem with writeback data
> > mode
> > <6>[   42.085164] EXT3-fs: barriers not enabled
> > <6>[   42.096892] kjournald starting.  Commit interval 5 seconds
> > <6>[   42.097760] EXT3-fs (dm-3): using internal journal
> > <6>[   42.097770] EXT3-fs (dm-3): mounted filesystem with writeback data
> > mode
> > <6>[   42.169929] EXT4-fs (dm-4): mounted filesystem with ordered data
> > mode. Opts: (null)
> > <6>[   42.328528] EXT4-fs (dm-7): mounted filesystem with ordered data
> > mode. Opts: (null)
> > <6>[   42.373537] EXT3-fs: barriers not enabled
> > <6>[   42.384316] kjournald starting.  Commit interval 5 seconds
> > <6>[   42.384600] EXT3-fs (dm-5): using internal journal
> > <6>[   42.384609] EXT3-fs (dm-5): mounted filesystem with writeback data
> > mode
> > <6>[   42.445883] EXT4-fs (dm-6): mounted filesystem with ordered data
> > mode. Opts: (null)
> > <6>[   42.502352] EXT4-fs (dm-0): mounted filesystem without journal.
> > Opts: (null)
> > <6>[   45.270924] Adding 10490440k swap on /dev/sda2.  Priority:-1
> > extents:1 across:10490440k
> > <6>[   45.769865] r8169 0000:02:00.0: eth0: link down
> > <6>[   47.667834] r8169 0000:02:00.0: eth0: link up
> > <6>[  203.678895] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  203.680952] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  203.680962] ata1.00: configured for UDMA/133
> > <6>[  203.680970] ata1: EH complete
> > <6>[  203.913278] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  203.917159] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  203.917168] ata2.00: configured for UDMA/133
> > <6>[  203.917175] ata2: EH complete
> > <6>[  204.328701] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  204.329712] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  204.329719] ata3.00: configured for UDMA/133
> > <6>[  204.329727] ata3: EH complete
> > <6>[  204.523207] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> > <6>[  204.530096] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> > <6>[  204.545240] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> > <6>[  204.552795] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> > <6>[  205.178334] PM: Syncing filesystems ... done.
> > <4>[  205.258426] Freezing user space processes ... (elapsed 0.01
> > seconds) done.
> > <4>[  205.269022] Freezing remaining freezable tasks ... (elapsed 0.01
> > seconds) done.
> > <4>[  205.280037] Suspending console(s) (use no_console_suspend to debug)
> > <5>[  205.280470] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
> > <5>[  205.280510] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
> > <5>[  205.280590] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> > <5>[  205.280656] sd 1:0:0:0: [sdb] Stopping disk
> > <5>[  205.280661] sd 2:0:0:0: [sdc] Stopping disk
> > <6>[  205.280816] parport_pc 00:09: disabled
> > <6>[  205.280883] serial 00:08: disabled
> > <6>[  205.280909] serial 00:08: wake-up capability disabled by ACPI
> > <7>[  205.281312] ACPI handle has no context!
> > <6>[  205.281480] r8169 0000:02:00.0: eth0: link down
> > <6>[  205.283177] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
> > <6>[  205.283212] ehci_hcd 0000:00:13.5: PCI INT D disabled
> > <6>[  205.283223] ohci_hcd 0000:00:13.4: PCI INT C disabled
> > <6>[  205.283254] ohci_hcd 0000:00:13.2: PCI INT C disabled
> > <6>[  205.283283] ohci_hcd 0000:00:13.0: PCI INT A disabled
> > <6>[  205.291041] ohci_hcd 0000:00:13.3: PCI INT B disabled
> > <6>[  205.293036] ohci_hcd 0000:00:13.1: PCI INT B disabled
> > <5>[  205.309953] sd 0:0:0:0: [sda] Stopping disk
> > <6>[  205.316796] radeon 0000:01:05.0: PCI INT A disabled
> > <6>[  205.382024] HDA Intel 0000:01:05.2: PCI INT B disabled
> > <7>[  205.382034] ACPI handle has no context!
> > <6>[  205.384100] HDA Intel 0000:00:14.2: PCI INT A disabled
> > <6>[  205.974363] ahci 0000:00:12.0: PCI INT A disabled
> > <6>[  205.974389] PM: suspend of devices complete after 694.074 msecs
> > <7>[  205.974615] r8169 0000:02:00.0: PME# enabled
> > <6>[  205.974624] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
> > <6>[  205.996148] PM: late suspend of devices complete after 21.754 msecs
> > <6>[  205.996347] ACPI: Preparing to enter system sleep state S3
> > <6>[  205.996427] PM: Saving platform NVS memory
> > <4>[  205.996457] Disabling non-boot CPUs ...
> > <6>[  205.997834] CPU 1 is now offline
> > <6>[  205.998251] ACPI: Low-level resume complete
> > <6>[  205.998251] PM: Restoring platform NVS memory
> > <6>[  205.998251] Enabling non-boot CPUs ...
> > <6>[  206.000486] Booting Node 0 Processor 1 APIC 0x1
> > <7>[  206.000488] smpboot cpu 1: start_ip = 9a000
> > <6>[  206.071328] CPU1 is up
> > <6>[  206.071556] ACPI: Waking up from system sleep state S3
> > <7>[  206.071680] pci 0000:00:00.0: restoring config space at offset 0x3
> > (was 0x0, writing 0x4000)
> > <7>[  206.071703] pcieport 0000:00:07.0: restoring config space at
> > offset 0x1 (was 0x100007, writing 0x100407)
> > <7>[  206.071738] ahci 0000:00:12.0: restoring config space at offset
> > 0x2 (was 0x1018f00, writing 0x1060100)
> > <6>[  206.071755] ahci 0000:00:12.0: set SATA to AHCI mode
> > <7>[  206.071777] ohci_hcd 0000:00:13.0: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[  206.071803] ohci_hcd 0000:00:13.1: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[  206.071829] ohci_hcd 0000:00:13.2: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[  206.071855] ohci_hcd 0000:00:13.3: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[  206.071881] ohci_hcd 0000:00:13.4: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[  206.071913] ehci_hcd 0000:00:13.5: restoring config space at
> > offset 0x1 (was 0x2b00000, writing 0x2b00013)
> > <7>[  206.072021] HDA Intel 0000:00:14.2: restoring config space at
> > offset 0x1 (was 0x4100006, writing 0x4100002)
> > <6>[  206.072027] Switched to NOHz mode on CPU #1
> > <7>[  206.072103] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0xf (was 0x200, writing 0x20a)
> > <7>[  206.072109] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x4 (was 0x4, writing 0xfdbfc004)
> > <7>[  206.072112] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x3 (was 0x0, writing 0x4008)
> > <7>[  206.072115] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x1 (was 0x100000, writing 0x100002)
> > <7>[  206.072138] r8169 0000:02:00.0: restoring config space at offset
> > 0xf (was 0x100, writing 0x10a)
> > <7>[  206.072152] r8169 0000:02:00.0: restoring config space at offset
> > 0x6 (was 0x4, writing 0xfdfff004)
> > <7>[  206.072157] r8169 0000:02:00.0: restoring config space at offset
> > 0x4 (was 0x1, writing 0xee01)
> > <7>[  206.072162] r8169 0000:02:00.0: restoring config space at offset
> > 0x3 (was 0x0, writing 0x8)
> > <7>[  206.072168] r8169 0000:02:00.0: restoring config space at offset
> > 0x1 (was 0x100000, writing 0x100407)
> > <7>[  206.072209] saa7134 0000:03:06.0: restoring config space at offset
> > 0xf (was 0x2054017b, writing 0x205401ff)
> > <7>[  206.072230] saa7134 0000:03:06.0: restoring config space at offset
> > 0x4 (was 0x0, writing 0xfdeff000)
> > <7>[  206.072235] saa7134 0000:03:06.0: restoring config space at offset
> > 0x3 (was 0xcd00, writing 0x4000)
> > <7>[  206.072242] saa7134 0000:03:06.0: restoring config space at offset
> > 0x1 (was 0x2900000, writing 0x2900006)
> > <7>[  206.072264] pci 0000:03:07.0: restoring config space at offset 0xf
> > (was 0x200001ff, writing 0x2000010b)
> > <7>[  206.072284] pci 0000:03:07.0: restoring config space at offset 0x5
> > (was 0x1, writing 0xcf01)
> > <7>[  206.072290] pci 0000:03:07.0: restoring config space at offset 0x4
> > (was 0xfdeff000, writing 0xfdefe000)
> > <7>[  206.072295] pci 0000:03:07.0: restoring config space at offset 0x3
> > (was 0x4000, writing 0x4008)
> > <7>[  206.072302] pci 0000:03:07.0: restoring config space at offset 0x1
> > (was 0x2100006, writing 0x2100007)
> > <6>[  206.072442] PM: early resume of devices complete after 0.787 msecs
> > <6>[  206.072599] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
> > IRQ 22
> > <6>[  206.072670] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
> > -> IRQ 18
> > <6>[  206.072730] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
> > low) -> IRQ 19
> > <6>[  206.072794] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[  206.072847] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[  206.072851] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[  206.072870] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[  206.072883] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[  206.072897] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
> > low) -> IRQ 19
> > <6>[  206.072934] saa7133[0]: board init: gpio is 600e000
> > <6>[  206.072951] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
> > <7>[  206.072956] r8169 0000:02:00.0: PME# disabled
> > <5>[  206.073028] sd 0:0:0:0: [sda] Starting disk
> > <5>[  206.073067] sd 1:0:0:0: [sdb] Starting disk
> > <5>[  206.073097] sd 2:0:0:0: [sdc] Starting disk
> > <6>[  206.074033] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[  206.074046] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[  206.074469] serial 00:08: activated
> > <6>[  206.074772] parport_pc 00:09: activated
> > <6>[  206.079074] r8169 0000:02:00.0: eth0: link down
> > <6>[  206.160028] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
> > <6>[  206.166059] radeon 0000:01:05.0: WB enabled
> > <6>[  206.166072] [drm] radeon: ring at 0x0000000080001000
> > <6>[  206.166092] [drm] ring test succeeded in 1 usecs
> > <6>[  206.166102] [drm] ib test succeeded in 0 usecs
> > <6>[  206.316024] usb 3-2: reset full speed USB device number 2 using
> > ohci_hcd
> > <4>[  206.469919] btusb 3-2:1.0: no reset_resume for driver btusb?
> > <4>[  206.469921] btusb 3-2:1.1: no reset_resume for driver btusb?
> > <3>[  206.532015] ata4: softreset failed (device not ready)
> > <4>[  206.532018] ata4: applying SB600 PMP SRST workaround and retrying
> > <6>[  206.687032] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> > <6>[  206.688553] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  206.731100] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  206.731103] ata4.00: configured for UDMA/100
> > <6>[  207.783243] r8169 0000:02:00.0: eth0: link up
> > <3>[  209.184023] ata3: softreset failed (device not ready)
> > <4>[  209.184026] ata3: applying SB600 PMP SRST workaround and retrying
> > <6>[  209.339024] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[  209.369662] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  209.370622] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  209.370624] ata3.00: configured for UDMA/133
> > <3>[  213.774015] ata1: softreset failed (device not ready)
> > <4>[  213.774017] ata1: applying SB600 PMP SRST workaround and retrying
> > <6>[  213.929032] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[  213.931017] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  213.933047] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  213.933050] ata1.00: configured for UDMA/133
> > <3>[  214.642028] ata2: softreset failed (device not ready)
> > <4>[  214.642030] ata2: applying SB600 PMP SRST workaround and retrying
> > <6>[  214.797027] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[  216.505430] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  216.508803] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  216.508805] ata2.00: configured for UDMA/133
> > <6>[  217.503047] PM: resume of devices complete after 11430.526 msecs
> > <4>[  217.503413] Restarting tasks ... done.
> > <6>[  217.806383] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  217.808438] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  217.808445] ata1.00: configured for UDMA/133
> > <6>[  217.808452] ata1: EH complete
> > <6>[  218.091813] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  218.095202] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  218.095211] ata2.00: configured for UDMA/133
> > <6>[  218.095218] ata2: EH complete
> > <6>[  218.512110] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  218.513141] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[  218.513158] ata3.00: configured for UDMA/133
> > <6>[  218.513177] ata3: EH complete
> > <6>[  218.605404] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> > <6>[  218.612182] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> > <6>[  218.627577] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> > <6>[  218.634463] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> > <6>[13990.570974] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.573451] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.573460] ata1.00: configured for UDMA/133
> > <6>[13990.573468] ata1: EH complete
> > <6>[13990.819528] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.823928] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.823936] ata2.00: configured for UDMA/133
> > <6>[13990.823943] ata2: EH complete
> > <6>[13990.886678] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.887693] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13990.887701] ata3.00: configured for UDMA/133
> > <6>[13990.887708] ata3: EH complete
> > <6>[13991.140951] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> > <6>[13991.148423] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> > <6>[13991.161902] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> > <6>[13991.169068] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> > <6>[13991.650833] PM: Syncing filesystems ... done.
> > <4>[13991.788480] Freezing user space processes ...
> > <3>[13991.793014] imon:send_packet: task interrupted
> > <3>[13991.798014] imon:send_packet: task interrupted
> > <4>[13991.810018] (elapsed 0.02 seconds) done.
> > <4>[13991.810020] Freezing remaining freezable tasks ... (elapsed 0.01
> > seconds) done.
> > <4>[13991.821034] Suspending console(s) (use no_console_suspend to debug)
> > <5>[13991.852176] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
> > <5>[13991.852229] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
> > <5>[13991.852272] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> > <5>[13991.852353] sd 2:0:0:0: [sdc] Stopping disk
> > <5>[13991.852358] sd 1:0:0:0: [sdb] Stopping disk
> > <6>[13991.852409] parport_pc 00:09: disabled
> > <6>[13991.852487] serial 00:08: disabled
> > <6>[13991.852511] serial 00:08: wake-up capability disabled by ACPI
> > <7>[13991.852615] ACPI handle has no context!
> > <6>[13991.852672] HDA Intel 0000:01:05.2: PCI INT B disabled
> > <7>[13991.852683] ACPI handle has no context!
> > <6>[13991.853072] r8169 0000:02:00.0: eth0: link down
> > <6>[13991.854632] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
> > <6>[13991.854665] ehci_hcd 0000:00:13.5: PCI INT D disabled
> > <6>[13991.854675] ohci_hcd 0000:00:13.4: PCI INT C disabled
> > <6>[13991.854698] ohci_hcd 0000:00:13.2: PCI INT C disabled
> > <6>[13991.854723] ohci_hcd 0000:00:13.0: PCI INT A disabled
> > <6>[13991.863051] ohci_hcd 0000:00:13.3: PCI INT B disabled
> > <6>[13991.865036] ohci_hcd 0000:00:13.1: PCI INT B disabled
> > <5>[13991.868645] sd 0:0:0:0: [sda] Stopping disk
> > <6>[13991.883330] radeon 0000:01:05.0: PCI INT A disabled
> > <6>[13991.955068] HDA Intel 0000:00:14.2: PCI INT A disabled
> > <6>[13992.544689] ahci 0000:00:12.0: PCI INT A disabled
> > <6>[13992.544709] PM: suspend of devices complete after 723.386 msecs
> > <7>[13992.544965] r8169 0000:02:00.0: PME# enabled
> > <6>[13992.544974] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
> > <6>[13992.566165] PM: late suspend of devices complete after 21.451 msecs
> > <6>[13992.566445] ACPI: Preparing to enter system sleep state S3
> > <6>[13992.566524] PM: Saving platform NVS memory
> > <4>[13992.566554] Disabling non-boot CPUs ...
> > <6>[13992.567938] CPU 1 is now offline
> > <6>[13992.568322] ACPI: Low-level resume complete
> > <6>[13992.568322] PM: Restoring platform NVS memory
> > <6>[13992.568322] Enabling non-boot CPUs ...
> > <6>[13992.570562] Booting Node 0 Processor 1 APIC 0x1
> > <7>[13992.570563] smpboot cpu 1: start_ip = 9a000
> > <6>[13992.641269] CPU1 is up
> > <6>[13992.641492] ACPI: Waking up from system sleep state S3
> > <7>[13992.641597] pci 0000:00:00.0: restoring config space at offset 0x3
> > (was 0x0, writing 0x4000)
> > <7>[13992.641621] pcieport 0000:00:07.0: restoring config space at
> > offset 0x1 (was 0x100007, writing 0x100407)
> > <7>[13992.641655] ahci 0000:00:12.0: restoring config space at offset
> > 0x2 (was 0x1018f00, writing 0x1060100)
> > <6>[13992.641673] ahci 0000:00:12.0: set SATA to AHCI mode
> > <7>[13992.641695] ohci_hcd 0000:00:13.0: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[13992.641721] ohci_hcd 0000:00:13.1: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[13992.641746] ohci_hcd 0000:00:13.2: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[13992.641771] ohci_hcd 0000:00:13.3: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[13992.641797] ohci_hcd 0000:00:13.4: restoring config space at
> > offset 0x1 (was 0x2a00007, writing 0x2a00003)
> > <7>[13992.641829] ehci_hcd 0000:00:13.5: restoring config space at
> > offset 0x1 (was 0x2b00000, writing 0x2b00013)
> > <7>[13992.641913] HDA Intel 0000:00:14.2: restoring config space at
> > offset 0x1 (was 0x4100006, writing 0x4100002)
> > <7>[13992.641993] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0xf (was 0x200, writing 0x20a)
> > <7>[13992.641999] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x4 (was 0x4, writing 0xfdbfc004)
> > <6>[13992.642028] Switched to NOHz mode on CPU #1
> > <7>[13992.642032] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x3 (was 0x0, writing 0x4008)
> > <7>[13992.642035] HDA Intel 0000:01:05.2: restoring config space at
> > offset 0x1 (was 0x100000, writing 0x100002)
> > <7>[13992.642058] r8169 0000:02:00.0: restoring config space at offset
> > 0xf (was 0x100, writing 0x10a)
> > <7>[13992.642072] r8169 0000:02:00.0: restoring config space at offset
> > 0x6 (was 0x4, writing 0xfdfff004)
> > <7>[13992.642078] r8169 0000:02:00.0: restoring config space at offset
> > 0x4 (was 0x1, writing 0xee01)
> > <7>[13992.642082] r8169 0000:02:00.0: restoring config space at offset
> > 0x3 (was 0x0, writing 0x8)
> > <7>[13992.642088] r8169 0000:02:00.0: restoring config space at offset
> > 0x1 (was 0x100000, writing 0x100407)
> > <7>[13992.642130] saa7134 0000:03:06.0: restoring config space at offset
> > 0xf (was 0x2054017b, writing 0x205401ff)
> > <7>[13992.642151] saa7134 0000:03:06.0: restoring config space at offset
> > 0x4 (was 0x0, writing 0xfdeff000)
> > <7>[13992.642156] saa7134 0000:03:06.0: restoring config space at offset
> > 0x3 (was 0xcd00, writing 0x4000)
> > <7>[13992.642163] saa7134 0000:03:06.0: restoring config space at offset
> > 0x1 (was 0x2900000, writing 0x2900006)
> > <7>[13992.642185] pci 0000:03:07.0: restoring config space at offset 0xf
> > (was 0x200001ff, writing 0x2000010b)
> > <7>[13992.642205] pci 0000:03:07.0: restoring config space at offset 0x5
> > (was 0x1, writing 0xcf01)
> > <7>[13992.642210] pci 0000:03:07.0: restoring config space at offset 0x4
> > (was 0xfdeff000, writing 0xfdefe000)
> > <7>[13992.642216] pci 0000:03:07.0: restoring config space at offset 0x3
> > (was 0x4000, writing 0x4008)
> > <7>[13992.642223] pci 0000:03:07.0: restoring config space at offset 0x1
> > (was 0x2100006, writing 0x2100007)
> > <6>[13992.642365] PM: early resume of devices complete after 0.794 msecs
> > <6>[13992.642490] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
> > IRQ 22
> > <6>[13992.642553] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[13992.642578] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[13992.642635] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[13992.642656] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
> > low) -> IRQ 17
> > <6>[13992.642672] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
> > low) -> IRQ 18
> > <6>[13992.642683] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
> > low) -> IRQ 19
> > <6>[13992.642696] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[13992.642708] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
> > low) -> IRQ 16
> > <6>[13992.642745] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
> > -> IRQ 18
> > <6>[13992.642750] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
> > low) -> IRQ 19
> > <6>[13992.642769] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
> > <7>[13992.642775] r8169 0000:02:00.0: PME# disabled
> > <6>[13992.643139] serial 00:08: activated
> > <6>[13992.643431] parport_pc 00:09: activated
> > <6>[13992.643483] saa7133[0]: board init: gpio is 600e000
> > <5>[13992.643690] sd 0:0:0:0: [sda] Starting disk
> > <5>[13992.643731] sd 1:0:0:0: [sdb] Starting disk
> > <5>[13992.643764] sd 2:0:0:0: [sdc] Starting disk
> > <6>[13992.649072] r8169 0000:02:00.0: eth0: link down
> > <6>[13992.730027] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
> > <6>[13992.736224] radeon 0000:01:05.0: WB enabled
> > <6>[13992.736257] [drm] radeon: ring at 0x0000000080001000
> > <6>[13992.736275] [drm] ring test succeeded in 1 usecs
> > <6>[13992.736292] [drm] ib test succeeded in 0 usecs
> > <6>[13992.885014] usb 3-2: reset full speed USB device number 2 using
> > ohci_hcd
> > <4>[13993.037904] btusb 3-2:1.0: no reset_resume for driver btusb?
> > <4>[13993.037906] btusb 3-2:1.1: no reset_resume for driver btusb?
> > <3>[13993.103027] ata4: softreset failed (device not ready)
> > <4>[13993.103030] ata4: applying SB600 PMP SRST workaround and retrying
> > <6>[13993.258026] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> > <6>[13993.258986] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13993.301531] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13993.301534] ata4.00: configured for UDMA/100
> > <6>[13994.394988] r8169 0000:02:00.0: eth0: link up
> > <3>[13995.805018] ata3: softreset failed (device not ready)
> > <4>[13995.805021] ata3: applying SB600 PMP SRST workaround and retrying
> > <6>[13995.960033] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[13995.990710] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13995.991668] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[13995.991670] ata3.00: configured for UDMA/133
> > <3>[14000.395016] ata1: softreset failed (device not ready)
> > <4>[14000.395019] ata1: applying SB600 PMP SRST workaround and retrying
> > <6>[14000.550024] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[14000.552018] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14000.554049] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14000.554051] ata1.00: configured for UDMA/133
> > <3>[14001.211018] ata2: softreset failed (device not ready)
> > <4>[14001.211021] ata2: applying SB600 PMP SRST workaround and retrying
> > <6>[14001.366037] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> > <6>[14003.070942] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14003.074337] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14003.074339] ata2.00: configured for UDMA/133
> > <6>[14004.069046] PM: resume of devices complete after 11426.606 msecs
> > <4>[14004.069403] Restarting tasks ... done.
> > <6>[14004.407337] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14004.409365] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14004.409368] ata1.00: configured for UDMA/133
> > <6>[14004.409373] ata1: EH complete
> > <6>[14004.705354] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14004.708749] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14004.708757] ata2.00: configured for UDMA/133
> > <6>[14004.708763] ata2: EH complete
> > <6>[14005.155257] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14005.156333] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> > <6>[14005.156336] ata3.00: configured for UDMA/133
> > <6>[14005.156341] ata3: EH complete
> > <6>[14005.225567] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> > <6>[14005.228495] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> > <6>[14005.236372] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> > <6>[14005.239412] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> > <1>[14166.454185] BUG: unable to handle kernel paging request at
> > ffffffff88317734
> > <1>[14166.454328] IP: [<ffffffff81397cfe>] usb_hcd_irq+0x3/0x58
> > <4>[14166.454432] PGD 16c7067 PUD 16cb063 PMD 0
> > <0>[14166.454522] Oops: 0000 [#1] PREEMPT SMP
> > <4>[14166.454608] CPU 0
> > <4>[14166.454645] Modules linked in: saa7134_alsa tda1004x saa7134_dvb
> > videobuf_dvb dvb_core ir_kbd_i2c tda827x tda8290 ir_lirc_codec lirc_dev
> > ir_sony_decoder snd_hda_codec_realtek ir_jvc_decoder snd_hda_intel
> > snd_hda_codec tuner ir_rc6_decoder ir_rc5_decoder parport_pc saa7134
> > rc_imon_mce ir_nec_decoder imon parport rc_core snd_hwdep sg
> > videobuf_dma_sg videobuf_core v4l2_common videodev rtc_cmos i2c_piix4
> > asus_atk0110 pcspkr v4l2_compat_ioctl32 tveeprom atiixp
> > <4>[14166.455155]
> > <4>[14166.455155] Pid: 0, comm: swapper Not tainted 3.0.3-dirty #37
> > System manufacturer System Product Name/M2A-VM HDMI
> > <4>[14166.455155] RIP: 0010:[<ffffffff81397cfe>]  [<ffffffff81397cfe>]
> > usb_hcd_irq+0x3/0x58
> > <4>[14166.455155] RSP: 0018:ffff880077c03ee0  EFLAGS: 00010096
> > <4>[14166.455155] RAX: 0000000000000000 RBX: ffff8800737797c0 RCX:
> > ffff880077c00000
> > <4>[14166.455155] RDX: 0000000000000000 RSI: ffff880073771000 RDI:
> > 0000000000000011
> > <4>[14166.455155] RBP: ffffffff816ad340 R08: 0000000000000000 R09:
> > 0000000000000000
> > <4>[14166.455155] R10: 0000000000000000 R11: 00000ce26247d7b8 R12:
> > 0000000000000000
> > <4>[14166.455155] R13: 0000000000000011 R14: 0000000000000000 R15:
> > 0000000000000000
> > <4>[14166.455155] FS:  00007fe1c1951700(0000) GS:ffff880077c00000(0000)
> > knlGS:0000000000000000
> > <4>[14166.455155] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > <4>[14166.455155] CR2: ffffffff88317734 CR3: 0000000073213000 CR4:
> > 00000000000006f0
> > <4>[14166.455155] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000
> > <4>[14166.455155] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > 0000000000000400
> > <4>[14166.455155] Process swapper (pid: 0, threadinfo ffffffff816aa000,
> > task ffffffff816cd020)
> > <0>[14166.455155] Stack:
> > <4>[14166.455155]  ffffffff810735f9 ffff880077c0c9c0 ffffffff816ad340
> > ffffffff816ad3bc
> > <4>[14166.455155]  ffff8800737797c0 ffffffff816abea8 0000000000000000
> > 0000000000000000
> > <4>[14166.455155]  ffffffff8107371e ffffffff816abea8 ffffffff81049bb3
> > ffffffff816ad340
> > <0>[14166.455155] Call Trace:
> > <0>[14166.455155]  <IRQ>
> > <4>[14166.455155]  [<ffffffff810735f9>] ? handle_irq_event_percpu+0x26/0x117
> > <4>[14166.455155]  [<ffffffff8107371e>] ? handle_irq_event+0x34/0x52
> > <4>[14166.455155]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
> > <4>[14166.455155]  [<ffffffff81075500>] ? handle_fasteoi_irq+0x78/0x9c
> > <4>[14166.455155]  [<ffffffff81003f32>] ? handle_irq+0x17/0x1d
> > <4>[14166.455155]  [<ffffffff8100381e>] ? do_IRQ+0x45/0xaa
> > <4>[14166.455155]  [<ffffffff814c4913>] ? common_interrupt+0x13/0x13
> > <0>[14166.455155]  <EOI>
> > <4>[14166.455155]  [<ffffffff81008c8c>] ? default_idle+0x20/0x34
> > <4>[14166.455155]  [<ffffffff81008de8>] ? amd_e400_idle+0xe3/0xe7
> > <4>[14166.455155]  [<ffffffff81001d62>] ? cpu_idle+0x56/0x93
> > <4>[14166.455155]  [<ffffffff8172697d>] ? start_kernel+0x354/0x35f
> > <4>[14166.455155]  [<ffffffff8172619e>] ? x86_64_start_kernel+0xea/0xee
> > <0>[14166.455155] Code: 89 3a 76 3e 89 3f 76 39 89 37 75 35 89 35 75 3b
> > 88 40 76 3b 88 3a 76 39 88 35 76 39 88 3d 76 37 89 36 76 39 88 39 76 3e
> > 89 41 76
> > <39>[14166.459639]  88 34 77 31 88 31 78 30 87 2f 79 2d 84 2b 7b 2a 83
> > 2a 7c 2d
> > <1>[14166.459639] RIP  [<ffffffff81397cfe>] usb_hcd_irq+0x3/0x58
> > <4>[14166.459639]  RSP <ffff880077c03ee0>
> > <0>[14166.459639] CR2: ffffffff88317734

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
