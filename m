Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A83EF6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:29:21 -0400 (EDT)
Date: Tue, 17 Sep 2013 21:29:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:53425553
 pmd:075f4067
Message-ID: <20130917132910.GA16186@localhost>
References: <20130916084752.GC11479@localhost>
 <52372349.6030308@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <52372349.6030308@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Vlastimil,

On Mon, Sep 16, 2013 at 05:27:05PM +0200, Vlastimil Babka wrote:
> On 09/16/2013 10:47 AM, Fengguang Wu wrote:
> > Greetings,
> > 
> > I got the below dmesg and the first bad commit is
> > 
> > commit 7a8010cd36273ff5f6fea5201ef9232f30cebbd9
> > Author: Vlastimil Babka <vbabka@suse.cz>
> > Date:   Wed Sep 11 14:22:35 2013 -0700
> > 
> >     mm: munlock: manual pte walk in fast path instead of follow_page_mask()
> >     
>  
> > 
> > [   56.020577] BUG: Bad page map in process killall5  pte:53425553 pmd:075f4067
> > [   56.022578] addr:08800000 vm_flags:00100073 anon_vma:7f5f6f00 mapping:  (null) index:8800
> > [   56.025276] CPU: 0 PID: 101 Comm: killall5 Not tainted 3.11.0-09272-g666a584 #52
> > 
> 
> Hello,
> 
> the stacktrace points clearly to the code added by the patch (function __munlock_pagevec_fill),
> no question about that. However, the addresses that are reported by print_bad_pte() in the logs
> (08800000 and 0a000000) are both on the page table boundary (note this is x86_32 without PAE)
> and should never appear inside the while loop of the function (and be passed to vm_normal_page()).
> This could only happen if pmd_addr_end() failed to prevent crossing the page table boundary and
> I just cannot see how that could occur without some variables being corrupted :/
> 
> Also, some of the failures during bisect were not due to this bug, but a WARNING for
> list_add corruption which hopefully is not related to munlock. While it is probably a far stretch,
> some kind of memory corruption could also lead to the erroneous behavior of the munlock code.
> 
> Can you therefore please retest with the bisected patch reverted (patch below) to see if the other
> WARNING still occurs and can be dealt with separately, so there are not potentially two bugs to
> be chased at the same time?

Yes there seems to be one more bug, the attached dmesg is for the
kernel with your patch reverted. I'm trying to bisect the other bug
now.

Thanks,
Fengguang

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-xian-9:20130916101717:3.11.0-rc3-00230-g5bbd533:8"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Linux version 3.11.0-09421-g14f83d4 (wfg@bee) (gcc version 4=
=2E8.1 (Debian 4.8.1-3) ) #337 SMP Mon Sep 16 10:13:47 CST 2013
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   UMC UMC UMC UMC
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x01ffffff]
[    0.000000] Base memory trampoline at [7809b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0f800000-0x0fbfffff]
[    0.000000]  [mem 0x0f800000-0x0fbfffff] page 4k
[    0.000000] BRK [0x0197e000, 0x0197efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0f7fffff]
[    0.000000]  [mem 0x08000000-0x0f7fffff] page 4k
[    0.000000] BRK [0x0197f000, 0x0197ffff] PGTABLE
[    0.000000] BRK [0x01980000, 0x01980fff] PGTABLE
[    0.000000] BRK [0x01981000, 0x01981fff] PGTABLE
[    0.000000] BRK [0x01982000, 0x01982fff] PGTABLE
[    0.000000] BRK [0x01983000, 0x01983fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128092(97%)
[    0.000000] RAMDISK: [mem 0x0fce4000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 00034 (v01 BOCHS  BXPCRSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACP 0fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC=
 00000001)
[    0.000000] ACPI: DSDT 0fffe490 011A9 (v01   BXPC   BXDSDT 00000001 INTL=
 20100528)
[    0.000000] ACPI: FACS 0fffff40 00040
[    0.000000] ACPI: SSDT 0ffff7a0 00796 (v01 BOCHS  BXPCSSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: APIC 0ffff680 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC=
 00000001)
[    0.000000] ACPI: HPET 0ffff640 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC=
 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   Normal zone: 640 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffff9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @87c04000 s27136 r0 d22016 u49=
152
[    0.000000] pcpu-alloc: s27136 r0 d22016 u49152 alloc=3D12*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr fc06640
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64796
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3D=
debug dynamic_printk sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 co=
nsole=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kernel-tests/run-queue/kvm/i386-randconfig-i002-0912/linus:master:14f83=
d4c02fa126fd699570429a0bb888e12ddf7:bisect-mm/.vmlinuz-14f83d4c02fa126fd699=
570429a0bb888e12ddf7-20130916101451-2992-xian branch=3Dlinus/master  BOOT_I=
MAGE=3D/kernel/i386-randconfig-i002-0912/14f83d4c02fa126fd699570429a0bb888e=
12ddf7/vmlinuz-3.11.0-09421-g14f83d4
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 237384K/261744K available (2125K kernel code, 196K r=
wdata, 1180K rodata, 304K init, 5860K bss, 24360K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6d000 - 0xfffff000   (1608 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0x887fe000 - 0xff7fe000   (1904 MB)
[    0.000000]     lowmem  : 0x78000000 - 0x87ffe000   ( 255 MB)
[    0.000000]       .init : 0x7936e000 - 0x793ba000   ( 304 kB)
[    0.000000]       .data : 0x7921394e - 0x7936d2c0   (1382 kB)
[    0.000000]       .text : 0x79000000 - 0x7921394e   (2126 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] SLUB: HWalign=3D128, Order=3D0-3, MinObjects=3D0, CPUs=3D2, =
Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:56 16
[    0.000000] CPU 0 irqstacks, hard=3D78096000 soft=3D78080000
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ODEBUG: 11 of 11 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2892.994 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value.. 5785.98 Bogo=
MIPS (lpj=3D28929940)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] Security Framework initialized
[    0.020000] Yama: becoming mindful.
[    0.020000] Mount-cache hash table entries: 512
[    0.020000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] tlb_flushall_shift: 6
[    0.020331] debug: unmapping init [mem 0x793ba000-0x793bcfff]
[    0.024038] ACPI: Core revision 20130725
[    0.026596] ACPI: All ACPI Tables successfully acquired
[    0.027722] Getting VERSION: 50014
[    0.028194] Getting VERSION: 50014
[    0.028644] Getting ID: 0
[    0.029013] Getting ID: f000000
[    0.030016] Getting LVT0: 8700
[    0.030440] Getting LVT1: 8400
[    0.030847] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.031656] enabled ExtINT on CPU#0
[    0.033542] ENABLING IO-APIC IRQs
[    0.033993] init IO_APIC IRQs
[    0.034417]  apic 0 pin 0 not connected
[    0.034946] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.036000] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.037048] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.038099] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.039149] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.040039] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.041091] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.042116] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.043141] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.044171] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.045222] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.050032] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.051091] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.052144] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.053189] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.054220]  apic 0 pin 16 not connected
[    0.054708]  apic 0 pin 17 not connected
[    0.055182]  apic 0 pin 18 not connected
[    0.055671]  apic 0 pin 19 not connected
[    0.056157]  apic 0 pin 20 not connected
[    0.056666]  apic 0 pin 21 not connected
[    0.057167]  apic 0 pin 22 not connected
[    0.057678]  apic 0 pin 23 not connected
[    0.058346] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.059438] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.061221] Using local APIC timer interrupts.
[    0.061221] calibrating APIC timer ...
[    0.070000] ... lapic delta =3D 8749394
[    0.070000] ... PM-Timer delta =3D 501114
[    0.070000] APIC calibration not consistent with PM-Timer: 139ms instead=
 of 100ms
[    0.070000] APIC delta adjusted to PM-Timer: 6249836 (8749394)
[    0.070000] TSC delta adjusted to PM-Timer: 289299095 (405001276)
[    0.070000] ..... delta 6249836
[    0.070000] ..... mult: 268428412
[    0.070000] ..... calibration result: 9999737
[    0.070000] ..... CPU clock speed is 2892.9909 MHz.
[    0.070000] ..... host bus clock speed is 999.9737 MHz.
[    0.070091] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.072763] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.077952] SMP alternatives: lockdep: fixing up alternatives
[    0.079063] CPU 1 irqstacks, hard=3D78108000 soft=3D7810a000
[    0.080000] smpboot: Booting Node   0, Processors  #1 OK
[    0.010000] Initializing CPU#1
[    0.020000] kvm-clock: cpu 1, msr 0:fffd041, secondary cpu clock
[    0.020000] masked ExtINT on CPU#1
[    0.130177] Brought up 2 CPUs
[    0.130112] KVM setup async PF for cpu 1
[    0.130112] kvm-stealtime: cpu 1, msr fc12640
[    0.131616] smpboot: Total of 2 processors activated (11571.97 BogoMIPS)
[    0.150502] devtmpfs: initialized
[    0.152240] regulator-dummy: no parameters
[    0.160040] NET: Registered protocol family 16
[    0.160936] cpuidle: using governor menu
[    0.161811] ACPI: bus type PCI registered
[    0.162390] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.164566] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.164566] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.164566] ACPI: Added _OSI(Module Device)
[    0.164566] ACPI: Added _OSI(Processor Device)
[    0.164566] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.164566] ACPI: Added _OSI(Processor Aggregator Device)
[    0.170588] ACPI: EC: Look up EC in DSDT
[    0.175428] ACPI: Interpreter enabled
[    0.175899] ACPI: (supports S0 S5)
[    0.176390] ACPI: Using IOAPIC for interrupt routing
[    0.180041] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.210623] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.211414] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.212910] PCI host bridge to bus 0000:00
[    0.213430] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.220007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.220757] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.221511] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.222345] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.223270] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.224691] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.230216] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.241242] pci 0000:00:01.1: reg 0x20: [io  0xc1e0-0xc1ef]
[    0.243926] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.245110] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.245988] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.250485] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.260014] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.262654] pci 0000:00:02.0: reg 0x14: [mem 0xfebe0000-0xfebe0fff]
[    0.272986] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    0.274192] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.280889] pci 0000:00:03.0: reg 0x10: [io  0xc1c0-0xc1df]
[    0.283309] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    0.302575] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    0.310567] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.313094] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.315607] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.333087] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    0.334355] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.336822] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    0.339266] pci 0000:00:05.0: reg 0x14: [mem 0xfebe2000-0xfebe2fff]
[    0.349038] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.351628] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.353860] pci 0000:00:06.0: reg 0x14: [mem 0xfebe3000-0xfebe3fff]
[    0.363190] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.365865] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.368200] pci 0000:00:07.0: reg 0x14: [mem 0xfebe4000-0xfebe4fff]
[    0.377731] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.380008] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    0.382441] pci 0000:00:08.0: reg 0x14: [mem 0xfebe5000-0xfebe5fff]
[    0.403191] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.405728] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    0.408131] pci 0000:00:09.0: reg 0x14: [mem 0xfebe6000-0xfebe6fff]
[    0.416834] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.420008] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.422442] pci 0000:00:0a.0: reg 0x14: [mem 0xfebe7000-0xfebe7fff]
[    0.431300] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.432860] pci 0000:00:0b.0: reg 0x10: [mem 0xfebe8000-0xfebe800f]
[    0.439285] pci_bus 0000:00: on NUMA node 0
[    0.441280] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.442292] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.443290] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.444284] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.445190] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.446771] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.447420] ACPI: \_SB_.PCI0: notify handler is installed
[    0.448257] Found 1 acpi root devices
[    0.449020] pps_core: LinuxPPS API ver. 1 registered
[    0.450005] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.451115] PCI: Using ACPI for IRQ routing
[    0.451630] PCI: pci_cache_line_size set to 64 bytes
[    0.452492] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.453225] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.454727] Switched to clocksource kvm-clock
[    0.454727] pnp: PnP ACPI init
[    0.454727] ACPI: bus type PNP registered
[    0.454727] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.454727] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.454727] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.455258] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.456121] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.457226] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.458120] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.459161] pnp 00:03: [dma 2]
[    0.459619] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.460546] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.461694] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.462656] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.463808] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.465082] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.466203] pnp: PnP ACPI: found 7 devices
[    0.466774] ACPI: bus type PNP unregistered
[    0.521504] PM-Timer running at invalid rate: 130% of normal - aborting.
[    0.522459] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.523185] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.523913] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.524722] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.525559] NET: Registered protocol family 1
[    0.526137] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.526922] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.527691] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.528523] pci 0000:00:02.0: Boot video device
[    0.529214] PCI: CLS 0 bytes, default 64
[    0.529995] Unpacking initramfs...
[    0.796334] debug: unmapping init [mem 0x87ce4000-0x87feffff]
[    0.797768] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    0.798504] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    0.799705] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    0.800961] Scanning for low memory corruption every 60 seconds
[    0.821664] NatSemi SCx200 Driver
[    0.824155] Initializing RT-Tester: OK
[    0.831137] crc32: CRC_LE_BITS =3D 32, CRC_BE BITS =3D 32
[    0.831873] crc32: self tests passed, processed 225944 bytes in 277454 n=
sec
[    0.833097] crc32c: CRC_LE_BITS =3D 32
[    0.833597] crc32c: self tests passed, processed 225944 bytes in 138491 =
nsec
[    0.834798] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.835568] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver =
version: 0.1
[    0.836606] cpcihp_generic: not configured, disabling.
[    0.837342] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    0.838285] ipmi message handler version 39.2
[    0.838893] ipmi device interface
[    0.839420] IPMI Watchdog: driver initialized
[    0.840328] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    0.841392] ACPI: Power Button [PWRF]
[    0.898620] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.941834] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    0.943909] Non-volatile memory driver v1.3
[    0.944469] toshiba: not a supported Toshiba laptop
[    0.945088] nsc_gpio initializing
[    0.945744] dummy-irq: no IRQ given.  Use irq=3DN
[    0.946374] Phantom Linux Driver, version n0.9.8, init OK
[    0.947353] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    0.949393] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.962201] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.963419] mousedev: PS/2 mouse device common for all mice
[    0.964970] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    0.966524] rtc_cmos 00:00: RTC can wake from S4
[    0.967401] rtc (null): alarm rollover: day
[    0.968772] rtc rtc0: rtc_cmos: dev (254:0)
[    0.969329] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    0.970351] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    0.972165] Driver for 1-wire Dallas network protocol.
[    0.972981] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    0.974487] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    0.975759] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    0.976592] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    0.977542] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    0.978395] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[    0.979247] pc87413_wdt: Version 1.1 at io 0x2E
[    0.979836] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    0.980721] sbc7240_wdt: I/O address 0x0443 already in use
[    0.991583] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    0.992613] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    0.993803] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    0.995477]=20
[    0.995477] printing PIC contents
[    0.996107] ... PIC  IMR: ffff
[    0.996509] ... PIC  IRR: 1113
[    0.996918] ... PIC  ISR: 0000
[    0.997320] ... PIC ELCR: 0c00
[    0.997754] printing local APIC contents on CPU#0/0:
[    0.998398] ... APIC ID:      00000000 (0)
[    0.998925] ... APIC VERSION: 00050014
[    0.999402] ... APIC TASKPRI: 00000000 (00)
[    0.999941] ... APIC PROCPRI: 00000000
[    1.000437] ... APIC LDR: 01000000
[    1.000880] ... APIC DFR: ffffffff
[    1.001318] ... APIC SPIV: 000001ff
[    1.001880] ... APIC ISR field:
[    1.002445] 000000000000000000000000000000000000000000000000000000000000=
0000
[    1.003590] ... APIC TMR field:
[    1.003998] 000000000200000000000000000000000000000000000000000000000000=
0000
[    1.005063] ... APIC IRR field:
[    1.005479] 000000000000000000000000000000000000000000000000000000002000=
8000
[    1.006558] ... APIC ESR: 00000000
[    1.006999] ... APIC ICR: 000008fd
[    1.007444] ... APIC ICR2: 02000000
[    1.007742] ... APIC LVTT: 000000ef
[    1.007742] ... APIC LVTPC: 00010000
[    1.007742] ... APIC LVT0: 00010700
[    1.007742] ... APIC LVT1: 00000400
[    1.007742] ... APIC LVTERR: 000000fe
[    1.007742] ... APIC TMICT: 00098426
[    1.007742] ... APIC TMCCT: 00000000
[    1.007742] ... APIC TDCR: 00000003
[    1.007742]=20
[    1.022044] number of MP IRQ sources: 15.
[    1.022576] number of IO-APIC #0 registers: 24.
[    1.023150] testing the IO APIC.......................
[    1.023829] IO APIC #0......
[    1.024205] .... register #00: 00000000
[    1.024700] .......    : physical APIC id: 00
[    1.025256] .......    : Delivery Type: 0
[    1.025775] .......    : LTS          : 0
[    1.026282] .... register #01: 00170011
[    1.026783] .......     : max redirection entries: 17
[    1.027427] .......     : PRQ implemented: 0
[    1.027970] .......     : IO APIC version: 11
[    1.028530] .... register #02: 00000000
[    1.029019] .......     : arbitration: 00
[    1.029536] .... IRQ redirection table:
[    1.030112] 1    0    0   0   0    0    0    00
[    1.030717] 0    0    0   0   0    1    1    31
[    1.031307] 0    0    0   0   0    1    1    30
[    1.032228] 0    0    0   0   0    1    1    33
[    1.032829] 1    0    0   0   0    1    1    34
[    1.033429] 1    1    0   0   0    1    1    35
[    1.034028] 0    0    0   0   0    1    1    36
[    1.034637] 0    0    0   0   0    1    1    37
[    1.035225] 0    0    0   0   0    1    1    38
[    1.035832] 0    1    0   0   0    1    1    39
[    1.036435] 1    1    0   0   0    1    1    3A
[    1.037028] 1    1    0   0   0    1    1    3B
[    1.037627] 0    0    0   0   0    1    1    3C
[    1.038215] 0    0    0   0   0    1    1    3D
[    1.038811] 0    0    0   0   0    1    1    3E
[    1.039402] 0    0    0   0   0    1    1    3F
[    1.040000] 1    0    0   0   0    0    0    00
[    1.040641] 1    0    0   0   0    0    0    00
[    1.041240] 1    0    0   0   0    0    0    00
[    1.041974] 1    0    0   0   0    0    0    00
[    1.042612] 1    0    0   0   0    0    0    00
[    1.043205] 1    0    0   0   0    0    0    00
[    1.043804] 1    0    0   0   0    0    0    00
[    1.044395] 1    0    0   0   0    0    0    00
[    1.044983] IRQ to pin mappings:
[    1.045411] IRQ0 -> 0:2
[    1.045771] IRQ1 -> 0:1
[    1.046128] IRQ3 -> 0:3
[    1.046492] IRQ4 -> 0:4
[    1.046847] IRQ5 -> 0:5
[    1.047202] IRQ6 -> 0:6
[    1.047565] IRQ7 -> 0:7
[    1.047920] IRQ8 -> 0:8
[    1.048275] IRQ9 -> 0:9
[    1.048642] IRQ10 -> 0:10
[    1.049020] IRQ11 -> 0:11
[    1.049397] IRQ12 -> 0:12
[    1.049784] IRQ13 -> 0:13
[    1.050182] IRQ14 -> 0:14
[    1.050568] IRQ15 -> 0:15
[    1.050943] .................................... done.
[    1.051635] Using IPI No-Shortcut mode
[    1.052515] IMA: No TPM chip found, activating TPM-bypass!
[    1.054458] rtc_cmos 00:00: setting system clock to 2013-09-16 02:17:04 =
UTC (1379297824)
[    1.055740] Unregister pv shared memory for cpu 0
[    1.059164] CPU 0 is now offline
[    1.060952] debug: unmapping init [mem 0x7936e000-0x793b9fff]
[    1.061778] Write protecting the kernel text: 2128k
[    1.062430] Write protecting the kernel read-only data: 1184k

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: No such file or directory

Please wait: booting...
Starting udev
/etc/rcS.d/S03udev: line 72: /proc/sys/kernel/hotplug: No such file or dire=
ctory
error initializing inotify
error sending message: Connection refused
error sending message: Connection refused
Starting Bootlog daemon: bootlogd: cannot find console device 4:64 under /d=
ev
bootlogd.
Configuring network interfaces... ifconfig: socket: Address family not supp=
orted by protocol
done.
hwclock: can't open '/dev/misc/rtc': No such file or directory
Running postinst /etc/rpm-postinsts/100...
/etc/init.d/modutils.sh: line 21: depmod: command not found
[    1.661615] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input2
[    1.790196] tsc: Refined TSC clocksource calibration: 2892.982 MHz
[    2.040093] ------------[ cut here ]------------
[    2.040725] WARNING: CPU: 1 PID: 9 at /c/wfg/mm/lib/list_debug.c:33 __li=
st_add+0x6c/0xae()
[    2.041778] list_add corruption. prev->next should be next (78100520), b=
ut was   (null). (prev=3D7818e170).
[    2.042981] Modules linked in:
[    2.043394] CPU: 1 PID: 9 Comm: rcu_sched Not tainted 3.11.0-09421-g14f8=
3d4 #337
[    2.044330]  00000000 00000000 78067df4 7920d59b 78067e34 78067e24 79030=
ed2 792f2e66
[    2.045476]  78067e50 00000009 792f2e4b 00000021 79106d72 79106d72 7818e=
170 78100520
[    2.046602]  78067ea0 78067e3c 79030f17 00000009 78067e34 792f2e66 78067=
e50 78067e68
[    2.047719] Call Trace:
[    2.048038]  [<7920d59b>] dump_stack+0x4b/0x66
[    2.048725]  [<79030ed2>] warn_slowpath_common+0x74/0x8b
[    2.049407]  [<79106d72>] ? __list_add+0x6c/0xae
[    2.049998]  [<79106d72>] ? __list_add+0x6c/0xae
[    2.050034]  [<79030f17>] warn_slowpath_fmt+0x2e/0x30
[    2.050034]  [<79106d72>] __list_add+0x6c/0xae
[    2.050034]  [<790371b1>] __internal_add_timer+0x8a/0x8e
[    2.050034]  [<790371c3>] internal_add_timer+0xe/0x26
[    2.050034]  [<7920dda6>] schedule_timeout+0x126/0x16e
[    2.050034]  [<7903727d>] ? cascade+0x5a/0x5a
[    2.050034]  [<7907bf13>] rcu_gp_kthread+0x299/0x467
[    2.050034]  [<7904612b>] ? abort_exclusive_wait+0x63/0x63
[    2.050034]  [<7907bc7a>] ? rcu_gp_fqs+0x6a/0x6a
[    2.050034]  [<79045985>] kthread+0x95/0x9a
[    2.050034]  [<79040000>] ? destroy_workqueue+0x4f/0x179
[    2.050034]  [<79212a7b>] ret_from_kernel_thread+0x1b/0x30
[    2.050034]  [<790458f0>] ? kthread_stop+0x4e/0x4e
[    2.050034] ---[ end trace 33feb15476a27131 ]---
[    2.059632] BUG: unable to handle kernel NULL pointer dereference at 000=
00004
[    2.060586] IP: [<7903746f>] run_timer_softirq+0x115/0x19c
[    2.061313] *pde =3D 00000000=20
[    2.061740] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[    2.062377] Modules linked in:
[    2.062805] CPU: 1 PID: 9 Comm: rcu_sched Tainted: G        W    3.11.0-=
09421-g14f83d4 #337
[    2.063868] task: 7804cd80 ti: 78066000 task.ti: 78066000
[    2.064561] EIP: 0060:[<7903746f>] EFLAGS: 00010002 CPU: 1
[    2.065263] EIP is at run_timer_softirq+0x115/0x19c
[    2.065895] EAX: 78067dcc EBX: 78100000 ECX: 7804cd80 EDX: 00000000
[    2.066701] ESI: 7818e040 EDI: 00000000 EBP: 78067de0 ESP: 78067dac
[    2.067504]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    2.068257] CR0: 8005003b CR2: 00000004 CR3: 0d9a7000 CR4: 00000690
[    2.069080] Stack:
[    2.069349]  7804cd80 7903431d ffff8b9e 78100a30 78100830 78067dcc 00000=
000 00000000
[    2.069616]  7818e040 78067ea0 00000001 78066000 7933e084 78067e24 79034=
34d 78067e14
[    2.069616]  790505dc 00000000 00000046 78067e1c 79062931 00000001 00000=
001 0000000a
[    2.069616] Call Trace:
[    2.069616]  [<7903431d>] ? __do_softirq+0x7b/0x165
[    2.069616]  [<7903434d>] __do_softirq+0xab/0x165
[    2.069616]  [<790505dc>] ? sched_clock_cpu+0x109/0x121
[    2.069616]  [<79062931>] ? tick_nohz_handler+0xcd/0xd9
[    2.069616]  [<7903451c>] irq_exit+0x56/0x91
[    2.069616]  [<7901ec24>] smp_apic_timer_interrupt+0x33/0x3d
[    2.069616]  [<792125f9>] apic_timer_interrupt+0x39/0x40
[    2.069616]  [<79211a22>] ? _raw_spin_unlock_irqrestore+0x3d/0x4f
[    2.069616]  [<7920ddb2>] schedule_timeout+0x132/0x16e
[    2.069616]  [<7903727d>] ? cascade+0x5a/0x5a
[    2.069616]  [<7907bf13>] rcu_gp_kthread+0x299/0x467
[    2.069616]  [<7904612b>] ? abort_exclusive_wait+0x63/0x63
[    2.069616]  [<7907bc7a>] ? rcu_gp_fqs+0x6a/0x6a
[    2.069616]  [<79045985>] kthread+0x95/0x9a
[    2.069616]  [<79040000>] ? destroy_workqueue+0x4f/0x179
[    2.069616]  [<79212a7b>] ret_from_kernel_thread+0x1b/0x30
[    2.069616]  [<790458f0>] ? kthread_stop+0x4e/0x4e
[    2.069616] Code: e0 01 89 44 24 08 8d 46 24 89 44 24 04 89 f0 89 3c 24 =
e8 d3 bf 02 00 ba 38 bc 34 79 89 f0 89 73 20 e8 47 01 0d 00 8b 16 8b 46 04 =
<89> 42 04 89 10 f6 46 0c 01 c7 06 00 00 00 00 c7 46 04 00 02 20
[    2.069616] EIP: [<7903746f>] run_timer_softirq+0x115/0x19c SS:ESP 0068:=
78067dac
[    2.069616] CR2: 0000000000000004
[    2.069616] ---[ end trace 33feb15476a27132 ]---
[    2.069616] Kernel panic - not syncing: Fatal exception in interrupt
[    2.069616] Rebooting in 10 seconds..
BUG: kernel boot crashed
Elapsed time: 15
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /tmp//kernel/i386-randcon=
fig-i002-0912/14f83d4c02fa126fd699570429a0bb888e12ddf7/vmlinuz-3.11.0-09421=
-g14f83d4-25979 -append 'hung_task_panic=3D1 rcutree.rcu_cpu_stall_timeout=
=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dyna=
mic_printk sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 console=3Dtt=
yS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-=
tests/run-queue/kvm/i386-randconfig-i002-0912/linus:master:14f83d4c02fa126f=
d699570429a0bb888e12ddf7:bisect-mm/.vmlinuz-14f83d4c02fa126fd699570429a0bb8=
88e12ddf7-20130916101451-2992-xian branch=3Dlinus/master  BOOT_IMAGE=3D/ker=
nel/i386-randconfig-i002-0912/14f83d4c02fa126fd699570429a0bb888e12ddf7/vmli=
nuz-3.11.0-09421-g14f83d4'  -initrd /kernel-tests/initrd/yocto-minimal-i386=
=2Ecgz -m 256M -smp 2 -net nic,vlan=3D0,macaddr=3D00:00:00:00:00:00,model=
=3Dvirtio -net user,vlan=3D0,hostfwd=3Dtcp::30075-:22 -net nic,vlan=3D1,mod=
el=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300es=
b -drive file=3D/fs/LABEL=3DKVM/disk0-xian-25979,media=3Ddisk,if=3Dvirtio -=
drive file=3D/fs/LABEL=3DKVM/disk1-xian-25979,media=3Ddisk,if=3Dvirtio -dri=
ve file=3D/fs/LABEL=3DKVM/disk2-xian-25979,media=3Ddisk,if=3Dvirtio -drive =
file=3D/fs/LABEL=3DKVM/disk3-xian-25979,media=3Ddisk,if=3Dvirtio -drive fil=
e=3D/fs/LABEL=3DKVM/disk4-xian-25979,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/LABEL=3DKVM/disk5-xian-25979,media=3Ddisk,if=3Dvirtio -pidfile /dev/=
shm/kboot/pid-xian-lkp-25979 -serial file:/dev/shm/kboot/serial-xian-lkp-25=
979 -daemonize -display none -monitor null=20

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
