Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA586B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 02:58:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so3580514pab.4
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 23:57:59 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id as3si1617949pbc.178.2014.04.09.23.57.58
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 23:57:59 -0700 (PDT)
Date: Thu, 10 Apr 2014 14:56:31 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [_PAGE_NUMA] kernel BUG at arch/x86/include/asm/pgtable.h:451!
Message-ID: <20140410065631.GC2132@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="v9Ux+11Zm5mwPlX6"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jet Chen <jet.chen@intel.com>


--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Mel,

I got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-numa-use-high-bit-v3r1

commit b1a008d57c41562cb9f3fe6159205f971483d66a
Author:     Mel Gorman <mgorman@suse.de>
AuthorDate: Mon Apr 7 10:25:12 2014 +0100
Commit:     Mel Gorman <mgorman@suse.de>
CommitDate: Tue Apr 8 10:17:19 2014 +0100

    x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
    
    _PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
    faults. Care is taken such that _PAGE_NUMA is used only in situations where
    the VMA flags distinguish between NUMA hinting faults and prot_none faults.
    Conceptually this is difficult and it has caused problems.
    
    Fundamentally, we only need the _PAGE_NUMA bit to tell the difference between
    an entry that is really unmapped and a page that is protected for NUMA
    hinting faults as if the PTE is not present then a fault will be trapped.
    
    Currently one of the software bits is used for identifying IO mappings and
    by Xen to track if it's a Xen PTE or a machine PFN.  This patch reuses the
    software bit for IOMAP for NUMA hinting faults with the expectation that
    the bit is not used for userspace addresses. Xen and NUMA balancing are
    now mutually exclusive in Kconfig.
    
    Signed-off-by: Mel Gorman <mgorman@suse.de>

+----------------------------------------------------------+------------+
|                                                          | b1a008d57c |
+----------------------------------------------------------+------------+
| boot_successes                                           | 0          |
| boot_failures                                            | 20         |
| kernel_BUG_at_arch/x86/include/asm/pgtable.h             | 20         |
| invalid_opcode                                           | 20         |
| EIP_is_at_spurious_fault                                 | 20         |
| Kernel_panic-not_syncing:Attempted_to_kill_the_idle_task | 20         |
| backtrace:error_code                                     | 20         |
| backtrace:mem_init                                       | 20         |
+----------------------------------------------------------+------------+

[    0.000000]       .text : 0x87c00000 - 0x8891c411   (13425 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...
[    0.000000] ------------[ cut here ]------------
[    0.000000] kernel BUG at arch/x86/include/asm/pgtable.h:451!
[    0.000000] invalid opcode: 0000 [#1] DEBUG_PAGEALLOC
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.14.0-00002-gb1a008d #380
[    0.000000] task: 88efe820 ti: 88efa000 task.ti: 88efa000
[    0.000000] EIP: 0060:[<87ca16ea>] EFLAGS: 00210002 CPU: 0
[    0.000000] EIP is at spurious_fault+0x12a/0x250
[    0.000000] EAX: 00000001 EBX: 00000001 ECX: 00000000 EDX: 00000000
[    0.000000] ESI: 00000003 EDI: 8948fa84 EBP: 88efbe70 ESP: 88efbe50
[    0.000000]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    0.000000] CR0: 8005003b CR2: ffea1000 CR3: 1148c000 CR4: 00000690
[    0.000000] Stack:
[    0.000000]  00000000 00000000 00000001 1148c161 8948cffc 00000001 ffea1000 00000003
[    0.000000]  88efbf04 87ca18ed 89053a50 89053a50 87d161cf 00000001 89053a40 00000001
[    0.000000]  890539f0 890539f0 00000001 890539e0 88efbeb0 88efe820 0000005c 00000000
[    0.000000] Call Trace:
[    0.000000]  [<87ca18ed>] __do_page_fault+0xdd/0x870
[    0.000000]  [<87d161cf>] ? console_unlock+0x41f/0x780
[    0.000000]  [<8891824d>] ? _raw_spin_unlock_irqrestore+0x6d/0x70
[    0.000000]  [<87d161f6>] ? console_unlock+0x446/0x780
[    0.000000]  [<8891824d>] ? _raw_spin_unlock_irqrestore+0x6d/0x70
[    0.000000]  [<87d0a226>] ? trace_hardirqs_off_caller+0x66/0xb0
[    0.000000]  [<87c9e230>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.000000]  [<87ca22f1>] do_page_fault+0x21/0x30
[    0.000000]  [<87c9e25e>] do_async_page_fault+0x2e/0x90
[    0.000000]  [<88919862>] error_code+0x6a/0x70
[    0.000000]  [<87ca007b>] ? perf_reg_value+0x9b/0x1a0
[    0.000000]  [<8890036e>] ? do_test_wp_bit+0x19/0x23
[    0.000000]  [<893ff0d8>] mem_init+0x1dc/0x23d
[    0.000000]  [<893e6000>] ? x86_cpu_to_apicid+0x9fa/0x9fa
[    0.000000]  [<893e6b5a>] start_kernel+0x1cf/0x47d
[    0.000000]  [<893e6674>] ? repair_env_string+0x99/0x99
[    0.000000]  [<893e63c7>] i386_start_kernel+0x175/0x178
[    0.000000] Code: 07 89 45 ec c1 e8 08 89 c3 b8 f0 4a 0f 89 83 e3 01 89 da e8 39 42 0d 00 8b 04 9d ac 71 15 89 40 85 db 89 04 9d ac 71 15 89 74 11 <0f> 0b 8b 55 f0 89 f0 e8 5a f0 ff ff e9 fc fe ff ff 31 c0 f7 45
[    0.000000] EIP: [<87ca16ea>] spurious_fault+0x12a/0x250 SS:ESP 0068:88efbe50
[    0.000000] ---[ end trace 05e0c07eb1c663a6 ]---
[    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!

git bisect start cc12f00ec1a594b08da422a968be635207aa381c 455c6fdbd219161bd09b1165f11699d6d73de11c --
git bisect  bad a92381a9275878a5b3a7ab82d62b7f80ee2a7cc6  # 01:42      0-     20  Merge 'balancenuma/mm-numa-use-high-bit-v3r1' into devel-f4-i386-201404100103
git bisect good 32c51c7b49778c2d2bb61ac9b0bb4872c7f066d2  # 01:51     20+      0  0day base guard for 'devel-f4-i386-201404100103'
git bisect good 41a3bfe0d363cb3949eebc20d563674edc412599  # 01:56     20+      1  Merge 'mlankhorst/master' into devel-f4-i386-201404100103
git bisect  bad 62251a838c47fc8aee402555d8c50475a7584669  # 02:00      0-     20  mm: Allow FOLL_NUMA on FOLL_FORCE
git bisect  bad b1a008d57c41562cb9f3fe6159205f971483d66a  # 02:03      0-     19  x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
git bisect good 71bca17d99b3609af44e343287598fb41dd67750  # 02:07     20+      0  x86: Require x86-64 for automatic NUMA balancing
# first bad commit: [b1a008d57c41562cb9f3fe6159205f971483d66a] x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
git bisect good 71bca17d99b3609af44e343287598fb41dd67750  # 02:10     60+      0  x86: Require x86-64 for automatic NUMA balancing
git bisect  bad cc12f00ec1a594b08da422a968be635207aa381c  # 02:10      0-     13  0day head guard for 'devel-f4-i386-201404100103'
git bisect good 39de65aa2c3eee901db020a4f1396998e09602a3  # 02:13     60+      0  Merge branch 'i2c/for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux
git bisect good 35e2933ca69ef1b8061e5aee090535410336e063  # 02:20     60+      0  Add linux-next specific files for 20140409


This script may reproduce the error.

-----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64 -cpu kvm64 -enable-kvm 
	-kernel $kernel
	-smp 2
	-m 256M
	-net nic,vlan=0,macaddr=00:00:00:00:00:00,model=virtio
	-net user,vlan=0
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-serial stdio
	-display none
	-monitor null
)

append=(
	debug
	sched_debug
	apic=debug
	ignore_loglevel
	sysrq_always_enabled
	panic=10
	prompt_ramdisk=0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
)

"${kvm[@]}" --append "${append[*]}"
-----------------------------------------------------------------------------

Thanks,
Fengguang

--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-f3-41:20140410020242:i386-randconfig-fd3-0410:3.14.0-00002-gb1a008d:380"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel
KASLR using RDTSC...

Decompressing Linux... Parsing ELF... Performing relocations... done.
Booting the kernel.
[    0.000000] Linux version 3.14.0-00002-gb1a008d (kbuild@f4) (gcc version=
 4.8.2 (Debian 4.8.2-18) ) #380 Thu Apr 10 02:02:17 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] initial memory mapped: [mem 0x00000000-0x11ffffff]
[    0.000000] Base memory trampoline at [7809b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 4k
[    0.000000] BRK [0x11a44000, 0x11a44fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13ffdfff] page 4k
[    0.000000] BRK [0x11a45000, 0x11a45fff] PGTABLE
[    0.000000] BRK [0x11a46000, 0x11a46fff] PGTABLE
[    0.000000] BRK [0x11a47000, 0x11a47fff] PGTABLE
[    0.000000] BRK [0x11a48000, 0x11a48fff] PGTABLE
[    0.000000] BRK [0x11a49000, 0x11a49fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 000fd950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 13ffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 13ffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 13ffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 13ffff40 000040
[    0.000000] ACPI: SSDT 13fff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 13fff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 13fff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x13ffdfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat 890e6000, node_mem_map 8a=
48b028
[    0.000000]   Normal zone: 800 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 81820 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 10f0e740
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81020
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kernel-tests/run-queue/kvm/i386-randconfig-fd3-0410/linux-deve=
l:devel-f4-i386-201404100103:b1a008d57c41562cb9f3fe6159205f971483d66a:bisec=
t-linux8/.vmlinuz-b1a008d57c41562cb9f3fe6159205f971483d66a-20140410020231-3=
-f3 branch=3Dlinux-devel/devel-f4-i386-201404100103 BOOT_IMAGE=3D/kernel/i3=
86-randconfig-fd3-0410/b1a008d57c41562cb9f3fe6159205f971483d66a/vmlinuz-3.1=
4.0-00002-gb1a008d drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 267668K/327280K available (13424K kernel code, 5041K=
 rwdata, 5996K rodata, 652K init, 5580K bss, 59612K reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa1000 - 0xfffff000   ( 376 kB)
[    0.000000]     vmalloc : 0x8c7fe000 - 0xfff9f000   (1847 MB)
[    0.000000]     lowmem  : 0x78000000 - 0x8bffe000   ( 319 MB)
[    0.000000]       .init : 0x893e6000 - 0x89489000   ( 652 kB)
[    0.000000]       .data : 0x8891c411 - 0x893e5600   (11044 kB)
[    0.000000]       .text : 0x87c00000 - 0x8891c411   (13425 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...
[    0.000000] ------------[ cut here ]------------
[    0.000000] kernel BUG at arch/x86/include/asm/pgtable.h:451!
[    0.000000] invalid opcode: 0000 [#1] DEBUG_PAGEALLOC
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.14.0-00002-gb1a008=
d #380
[    0.000000] task: 88efe820 ti: 88efa000 task.ti: 88efa000
[    0.000000] EIP: 0060:[<87ca16ea>] EFLAGS: 00210002 CPU: 0
[    0.000000] EIP is at spurious_fault+0x12a/0x250
[    0.000000] EAX: 00000001 EBX: 00000001 ECX: 00000000 EDX: 00000000
[    0.000000] ESI: 00000003 EDI: 8948fa84 EBP: 88efbe70 ESP: 88efbe50
[    0.000000]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    0.000000] CR0: 8005003b CR2: ffea1000 CR3: 1148c000 CR4: 00000690
[    0.000000] Stack:
[    0.000000]  00000000 00000000 00000001 1148c161 8948cffc 00000001 ffea1=
000 00000003
[    0.000000]  88efbf04 87ca18ed 89053a50 89053a50 87d161cf 00000001 89053=
a40 00000001
[    0.000000]  890539f0 890539f0 00000001 890539e0 88efbeb0 88efe820 00000=
05c 00000000
[    0.000000] Call Trace:
[    0.000000]  [<87ca18ed>] __do_page_fault+0xdd/0x870
[    0.000000]  [<87d161cf>] ? console_unlock+0x41f/0x780
[    0.000000]  [<8891824d>] ? _raw_spin_unlock_irqrestore+0x6d/0x70
[    0.000000]  [<87d161f6>] ? console_unlock+0x446/0x780
[    0.000000]  [<8891824d>] ? _raw_spin_unlock_irqrestore+0x6d/0x70
[    0.000000]  [<87d0a226>] ? trace_hardirqs_off_caller+0x66/0xb0
[    0.000000]  [<87c9e230>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.000000]  [<87ca22f1>] do_page_fault+0x21/0x30
[    0.000000]  [<87c9e25e>] do_async_page_fault+0x2e/0x90
[    0.000000]  [<88919862>] error_code+0x6a/0x70
[    0.000000]  [<87ca007b>] ? perf_reg_value+0x9b/0x1a0
[    0.000000]  [<8890036e>] ? do_test_wp_bit+0x19/0x23
[    0.000000]  [<893ff0d8>] mem_init+0x1dc/0x23d
[    0.000000]  [<893e6000>] ? x86_cpu_to_apicid+0x9fa/0x9fa
[    0.000000]  [<893e6b5a>] start_kernel+0x1cf/0x47d
[    0.000000]  [<893e6674>] ? repair_env_string+0x99/0x99
[    0.000000]  [<893e63c7>] i386_start_kernel+0x175/0x178
[    0.000000] Code: 07 89 45 ec c1 e8 08 89 c3 b8 f0 4a 0f 89 83 e3 01 89 =
da e8 39 42 0d 00 8b 04 9d ac 71 15 89 40 85 db 89 04 9d ac 71 15 89 74 11 =
<0f> 0b 8b 55 f0 89 f0 e8 5a f0 ff ff e9 fc fe ff ff 31 c0 f7 45
[    0.000000] EIP: [<87ca16ea>] spurious_fault+0x12a/0x250 SS:ESP 0068:88e=
fbe50
[    0.000000] ---[ end trace 05e0c07eb1c663a6 ]---
[    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!
[    0.000000] Rebooting in 10 seconds..
Elapsed time: 5
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-f=
d3-0410/b1a008d57c41562cb9f3fe6159205f971483d66a/vmlinuz-3.14.0-00002-gb1a0=
08d -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=3Dde=
bug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 so=
ftlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0=
,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tes=
ts/run-queue/kvm/i386-randconfig-fd3-0410/linux-devel:devel-f4-i386-2014041=
00103:b1a008d57c41562cb9f3fe6159205f971483d66a:bisect-linux8/.vmlinuz-b1a00=
8d57c41562cb9f3fe6159205f971483d66a-20140410020231-3-f3 branch=3Dlinux-deve=
l/devel-f4-i386-201404100103 BOOT_IMAGE=3D/kernel/i386-randconfig-fd3-0410/=
b1a008d57c41562cb9f3fe6159205f971483d66a/vmlinuz-3.14.0-00002-gb1a008d drbd=
=2Eminor_count=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m =
320 -smp 2 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp=
::9988-:22 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocal=
time -pidfile /dev/shm/kboot/pid-quantal-f3-41 -serial file:/dev/shm/kboot/=
serial-quantal-f3-41 -daemonize -display none -monitor null=20

--v9Ux+11Zm5mwPlX6
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="i386-randconfig-fd3-0410-cc12f00ec1a594b08da422a968be635207aa381c-kernel-BUG-at-107624.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgY2MxMmYwMC4uLiAwZGF5IGhlYWQgZ3VhcmQgZm9yICdkZXZlbC1m
NC1pMzg2LTIwMTQwNDEwMDEwMycKZ2l0IGNoZWNrb3V0IDQ1NWM2ZmRiZDIxOTE2MWJkMDli
MTE2NWYxMTY5OWQ2ZDczZGUxMWMKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9saW51eC1kZXZlbDpkZXZlbC1mNC1pMzg2LTIw
MTQwNDEwMDEwMzo0NTVjNmZkYmQyMTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2RlMTFjOmJp
c2VjdC1saW51eDgKCjIwMTQtMDQtMTAtMDE6MTU6NDEgNDU1YzZmZGJkMjE5MTYxYmQwOWIx
MTY1ZjExNjk5ZDZkNzNkZTExYyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tl
cm5lbC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAtNDU1YzZm
ZGJkMjE5MTYxYmQwOWIxMTY1ZjExNjk5ZDZkNzNkZTExYwpDaGVjayBmb3Iga2VybmVsIGlu
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzQ1NWM2ZmRiZDIxOTE2MWJkMDli
MTE2NWYxMTY5OWQ2ZDczZGUxMWMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVs
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC00NTVjNmZkYmQy
MTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2RlMTFjCndhaXRpbmcgZm9yIGNvbXBsZXRpb24g
b2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEw
LTQ1NWM2ZmRiZDIxOTE2MWJkMDliMTE2NWYxMTY5OWQ2ZDczZGUxMWMKa2VybmVsOiAva2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC80NTVjNmZkYmQyMTkxNjFiZDA5YjExNjVm
MTE2OTlkNmQ3M2RlMTFjL3ZtbGludXotMy4xNC4wCgoyMDE0LTA0LTEwLTAxOjMwOjQyIGRl
dGVjdGluZyBib290IHN0YXRlIC4uCTkJMjAgU1VDQ0VTUwoKYmlzZWN0OiBnb29kIGNvbW1p
dCA0NTVjNmZkYmQyMTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2RlMTFjCmdpdCBiaXNlY3Qg
c3RhcnQgY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYzNTIwN2FhMzgxYyA0NTVjNmZk
YmQyMTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2RlMTFjIC0tCi9jL2tlcm5lbC10ZXN0cy9s
aW5lYXItYmlzZWN0OiBbIi1iIiwgImNjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4YmU2MzUy
MDdhYTM4MWMiLCAiLWciLCAiNDU1YzZmZGJkMjE5MTYxYmQwOWIxMTY1ZjExNjk5ZDZkNzNk
ZTExYyIsICIvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIiwg
Ii9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QiXQpCaXNlY3Rpbmc6IDEwMjkgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDExIHN0ZXBzKQpbYTky
MzgxYTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNl0gTWVyZ2UgJ2JhbGFuY2Vu
dW1hL21tLW51bWEtdXNlLWhpZ2gtYml0LXYzcjEnIGludG8gZGV2ZWwtZjQtaTM4Ni0yMDE0
MDQxMDAxMDMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9saW51eC1kZXZl
bDpkZXZlbC1mNC1pMzg2LTIwMTQwNDEwMDEwMzphOTIzODFhOTI3NTg3OGE1YjNhN2FiODJk
NjJiN2Y4MGVlMmE3Y2M2OmJpc2VjdC1saW51eDgKCjIwMTQtMDQtMTAtMDE6MzI6NDMgYTky
MzgxYTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNiBjb21waWxpbmcKUXVldWVk
IGJ1aWxkIHRhc2sgdG8gL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25m
aWctZmQzLTA0MTAtYTkyMzgxYTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNgpD
aGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5
MjM4MWE5Mjc1ODc4YTViM2E3YWI4MmQ2MmI3ZjgwZWUyYTdjYzYKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1m
ZDMtMDQxMC1hOTIzODFhOTI3NTg3OGE1YjNhN2FiODJkNjJiN2Y4MGVlMmE3Y2M2CndhaXRp
bmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1y
YW5kY29uZmlnLWZkMy0wNDEwLWE5MjM4MWE5Mjc1ODc4YTViM2E3YWI4MmQ2MmI3ZjgwZWUy
YTdjYzYKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFh
OTI3NTg3OGE1YjNhN2FiODJkNjJiN2Y4MGVlMmE3Y2M2L3ZtbGludXotMy4xNC4wLTAwMDU1
LWdhOTIzODFhCgoyMDE0LTA0LTEwLTAxOjQxOjQzIGRldGVjdGluZyBib290IHN0YXRlIC4g
VEVTVCBGQUlMVVJFClsgICAgMC4wMDAwMDBdICAgICAgIC50ZXh0IDogMHg3YjAwMDAwMCAt
IDB4N2JjNjNiMDUgICAoMTI2ODYga0IpClsgICAgMC4wMDAwMDBdIENoZWNraW5nIGlmIHRo
aXMgcHJvY2Vzc29yIGhvbm91cnMgdGhlIFdQIGJpdCBldmVuIGluIHN1cGVydmlzb3IgbW9k
ZS4uLgpbICAgIDAuMDAwMDAwXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0t
LS0KWyAgICAwLjAwMDAwMF0ga2VybmVsIEJVRyBhdCBhcmNoL3g4Ni9pbmNsdWRlL2FzbS9w
Z3RhYmxlLmg6NDUxIQpbICAgIDAuMDAwMDAwXSBpbnZhbGlkIG9wY29kZTogMDAwMCBbIzFd
IERFQlVHX1BBR0VBTExPQwpbICAgIDAuMDAwMDAwXSBDUFU6IDAgUElEOiAwIENvbW06IHN3
YXBwZXIgTm90IHRhaW50ZWQgMy4xNC4wLTAwMDU1LWdhOTIzODFhICMzNzYKWyAgICAwLjAw
MDAwMF0gdGFzazogN2MyNDY4MjAgdGk6IDdjMjQyMDAwIHRhc2sudGk6IDdjMjQyMDAwClsg
ICAgMC4wMDAwMDBdIEVJUDogMDA2MDpbPDdiMDk3MmM5Pl0gRUZMQUdTOiAwMDIxMDAwMiBD
UFU6IDAKWyAgICAwLjAwMDAwMF0gRUlQIGlzIGF0IHNwdXJpb3VzX2ZhdWx0KzB4MTI2LzB4
MjQ0ClsgICAgMC4wMDAwMDBdIEVBWDogMDAwMDAwMDEgRUJYOiAwMDAwMDAwMSBFQ1g6IDAw
MDAwMDAwIEVEWDogMDAwMDAwMDAKWyAgICAwLjAwMDAwMF0gRVNJOiAwMDAwMDAwMyBFREk6
IDdjN2Q3YTg0IEVCUDogN2MyNDNlNzAgRVNQOiA3YzI0M2U1MApbICAgIDAuMDAwMDAwXSAg
RFM6IDAwN2IgRVM6IDAwN2IgRlM6IDAwMDAgR1M6IDAwZTAgU1M6IDAwNjgKWyAgICAwLjAw
MDAwMF0gQ1IwOiA4MDA1MDAzYiBDUjI6IGZmZWExMDAwIENSMzogMDQ3ZDQwMDAgQ1I0OiAw
MDAwMDY5MApbICAgIDAuMDAwMDAwXSBTdGFjazoKWyAgICAwLjAwMDAwMF0gIDAwMDAwMDAw
IDAwMDAwMDAwIDAwMDAwMDAxIDA0N2Q0MTYxIDdjN2Q0ZmZjIDAwMDAwMDAxIGZmZWExMDAw
IDAwMDAwMDAzClsgICAgMC4wMDAwMDBdICA3YzI0M2YwNCA3YjA5NzRjNCA3YzM5YmE1MCA3
YzM5YmE1MCA3YjEwNTBmMSAwMDAwMDAwMSA3YzM5YmE0MCAwMDAwMDAwMQpbICAgIDAuMDAw
MDAwXSAgN2MzOWI5ZjAgN2MzOWI5ZjAgMDAwMDAwMDEgN2MzOWI5ZTAgN2MyNDNlYjAgN2My
NDY4MjAgMDAwMDAwNWMgMDAwMDAwMDAKWyAgICAwLjAwMDAwMF0gQ2FsbCBUcmFjZToKWyAg
ICAwLjAwMDAwMF0gIFs8N2IwOTc0YzQ+XSBfX2RvX3BhZ2VfZmF1bHQrMHhkZC8weDg2Mgpb
ICAgIDAuMDAwMDAwXSAgWzw3YjEwNTBmMT5dID8gY29uc29sZV91bmxvY2srMHg0MDMvMHg3
MzcKWyAgICAwLjAwMDAwMF0gIFs8N2JjNWZhYzU+XSA/IF9yYXdfc3Bpbl91bmxvY2tfaXJx
cmVzdG9yZSsweDY3LzB4NjkKWyAgICAwLjAwMDAwMF0gIFs8N2IxMDUxMTg+XSA/IGNvbnNv
bGVfdW5sb2NrKzB4NDJhLzB4NzM3ClsgICAgMC4wMDAwMDBdICBbPDdiYzVmYWM1Pl0gPyBf
cmF3X3NwaW5fdW5sb2NrX2lycXJlc3RvcmUrMHg2Ny8weDY5ClsgICAgMC4wMDAwMDBdICBb
PDdiMGY5YzNjPl0gPyB0cmFjZV9oYXJkaXJxc19vZmZfY2FsbGVyKzB4NjMvMHhhMApbICAg
IDAuMDAwMDAwXSAgWzw3YjA5NDNlZD5dID8ga3ZtX3JlYWRfYW5kX3Jlc2V0X3BmX3JlYXNv
bisweDM5LzB4MzkKWyAgICAwLjAwMDAwMF0gIFs8N2IwOTdlYTA+XSBkb19wYWdlX2ZhdWx0
KzB4MjEvMHgyYgpbICAgIDAuMDAwMDAwXSAgWzw3YjA5NDQxYj5dIGRvX2FzeW5jX3BhZ2Vf
ZmF1bHQrMHgyZS8weDc0ClsgICAgMC4wMDAwMDBdICBbPDdiYzYwZmIyPl0gZXJyb3JfY29k
ZSsweDZhLzB4NzAKWyAgICAwLjAwMDAwMF0gIFs8N2IwOTAwN2I+XSA/IGFja19hcGljX2xl
dmVsKzB4NDgvMHg5NQpbICAgIDAuMDAwMDAwXSAgWzw3YmM0ODE5Nj5dID8gZG9fdGVzdF93
cF9iaXQrMHgxOS8weDIzClsgICAgMC4wMDAwMDBdICBbPDdjNzQ3MGQ4Pl0gbWVtX2luaXQr
MHgxZGMvMHgyM2QKWyAgICAwLjAwMDAwMF0gIFs8N2M3MmUwMDA+XSA/IHg4Nl9jcHVfdG9f
YXBpY2lkKzB4YTNhLzB4YTNhClsgICAgMC4wMDAwMDBdICBbPDdjNzJlYjVhPl0gc3RhcnRf
a2VybmVsKzB4MWNmLzB4NDdkClsgICAgMC4wMDAwMDBdICBbPDdjNzJlNjc0Pl0gPyByZXBh
aXJfZW52X3N0cmluZysweDk5LzB4OTkKWyAgICAwLjAwMDAwMF0gIFs8N2M3MmUzYzc+XSBp
Mzg2X3N0YXJ0X2tlcm5lbCsweDE3NS8weDE3OApbICAgIDAuMDAwMDAwXSBDb2RlOiAwNyA4
OSA0NSBlYyBjMSBlOCAwOCA4OSBjMyBiOCBmMCBjYSA0MyA3YyA4MyBlMyAwMSA4OSBkYSBl
OCAwZSA3NyAwYyAwMCA4YiAwNCA5ZCA5OCBmMSA0OSA3YyA0MCA4NSBkYiA4OSAwNCA5ZCA5
OCBmMSA0OSA3YyA3NCAxMSA8MGY+IDBiIDhiIDU1IGYwIDg5IGYwIGU4IDFlIGYxIGZmIGZm
IGU5IDAwIGZmIGZmIGZmIDMxIGMwIGY3IDQ1ClsgICAgMC4wMDAwMDBdIEVJUDogWzw3YjA5
NzJjOT5dIHNwdXJpb3VzX2ZhdWx0KzB4MTI2LzB4MjQ0IFNTOkVTUCAwMDY4OjdjMjQzZTUw
ClsgICAgMC4wMDAwMDBdIC0tLVsgZW5kIHRyYWNlIDA1ZTBjMDdlYjFjNjYzYTYgXS0tLQpb
ICAgIDAuMDAwMDAwXSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2luZzogQXR0ZW1wdGVkIHRv
IGtpbGwgdGhlIGlkbGUgdGFzayEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAv
YTkyMzgxYTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy15b2N0by1m
Mi00OjIwMTQwNDEwMDE0MTA1OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAw
NTUtZ2E5MjM4MWE6Mzc2Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4
MWE5Mjc1ODc4YTViM2E3YWI4MmQ2MmI3ZjgwZWUyYTdjYzYvZG1lc2ctcXVhbnRhbC1mMy0x
MDU6MjAxNDA0MTAwMTQxMTQ6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1
NS1nYTkyMzgxYTozNzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgx
YTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy1xdWFudGFsLWYzLTEy
NjoyMDE0MDQxMDAxNDExNjppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1
LWdhOTIzODFhOjM3Ngova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFh
OTI3NTg3OGE1YjNhN2FiODJkNjJiN2Y4MGVlMmE3Y2M2L2RtZXNnLXF1YW50YWwtZjMtNjA6
MjAxNDA0MTAwMTQxMDY6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1n
YTkyMzgxYTozNzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTky
NzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy1xdWFudGFsLWYzLTY3OjIw
MTQwNDEwMDE0MTExOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwNTUtZ2E5
MjM4MWE6Mzc2Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4MWE5Mjc1
ODc4YTViM2E3YWI4MmQ2MmI3ZjgwZWUyYTdjYzYvZG1lc2ctcXVhbnRhbC1sa3AtaWIwMy04
NjoyMDE0MDQxMDAxNDExMzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1
LWdhOTIzODFhOjM3Ngova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFh
OTI3NTg3OGE1YjNhN2FiODJkNjJiN2Y4MGVlMmE3Y2M2L2RtZXNnLXlvY3RvLWYyLTQyOjIw
MTQwNDEwMDE0MTEzOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwNTUtZ2E5
MjM4MWE6Mzc2Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4MWE5Mjc1
ODc4YTViM2E3YWI4MmQ2MmI3ZjgwZWUyYTdjYzYvZG1lc2cteW9jdG8tbGtwLWliMDQtNTY6
MjAxNDA0MTAwMTQxMTA6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1n
YTkyMzgxYTozNzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTky
NzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy15b2N0by1mMy0xMDk6MjAx
NDA0MTAwMTQxMTY6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1nYTky
MzgxYTozNzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTkyNzU4
NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy1xdWFudGFsLWYyLTg4OjIwMTQw
NDEwMDE0MTIzOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwNTUtZ2E5MjM4
MWE6Mzc2Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4MWE5Mjc1ODc4
YTViM2E3YWI4MmQ2MmI3ZjgwZWUyYTdjYzYvZG1lc2ctcXVhbnRhbC1mNC0xMTM6MjAxNDA0
MTAwMTQxMTk6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1nYTkyMzgx
YTozNzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTkyNzU4Nzhh
NWIzYTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy15b2N0by1mMi0zNDoyMDE0MDQxMDAx
NDEyMzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1LWdhOTIzODFhOjM3
Ngova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFhOTI3NTg3OGE1YjNh
N2FiODJkNjJiN2Y4MGVlMmE3Y2M2L2RtZXNnLXlvY3RvLWYzLTEwOToyMDE0MDQxMDAxNDEy
NjppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1LWdhOTIzODFhOjM3Ngov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFhOTI3NTg3OGE1YjNhN2Fi
ODJkNjJiN2Y4MGVlMmE3Y2M2L2RtZXNnLXlvY3RvLWYzLTYwOjIwMTQwNDEwMDE0MTIyOmkz
ODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwNTUtZ2E5MjM4MWE6Mzc2Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4MWE5Mjc1ODc4YTViM2E3YWI4MmQ2
MmI3ZjgwZWUyYTdjYzYvZG1lc2cteW9jdG8tbGtwLWliMDMtNDI6MjAxNDA0MTAwMTQxMTg6
aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1nYTkyMzgxYTozNzYKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTkyNzU4NzhhNWIzYTdhYjgy
ZDYyYjdmODBlZTJhN2NjNi9kbWVzZy15b2N0by1sa3AtaWIwNC01NjoyMDE0MDQxMDAxNDEx
OTppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1LWdhOTIzODFhOjM3Ngov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9hOTIzODFhOTI3NTg3OGE1YjNhN2Fi
ODJkNjJiN2Y4MGVlMmE3Y2M2L2RtZXNnLXF1YW50YWwtZjItMjc6MjAxNDA0MTAwMTQxMjc6
aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1nYTkyMzgxYTozNzYKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTkyNzU4NzhhNWIzYTdhYjgy
ZDYyYjdmODBlZTJhN2NjNi9kbWVzZy1xdWFudGFsLWxrcC1pYjA0LTU1OjIwMTQwNDEwMDE0
MTI4OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwNTUtZ2E5MjM4MWE6Mzc2
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2E5MjM4MWE5Mjc1ODc4YTViM2E3
YWI4MmQ2MmI3ZjgwZWUyYTdjYzYvZG1lc2cteW9jdG8tbGtwLWliMDMtNDI6MjAxNDA0MTAw
MTQxMjc6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDA1NS1nYTkyMzgxYToz
NzYKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYTkyMzgxYTkyNzU4NzhhNWIz
YTdhYjgyZDYyYjdmODBlZTJhN2NjNi9kbWVzZy15b2N0by1mMy02OToyMDE0MDQxMDAxNDEy
ODppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDU1LWdhOTIzODFhOjM3Ngow
OjIwOjIwIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA0LTEwIDAx
OjQyOjE0IFJFUEVBVCBDT1VOVDogMjAgICMgL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJp
c2VjdC8ucmVwZWF0G1swbQoKQmlzZWN0aW5nOiA1NSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgNiBzdGVwcykKWzMyYzUxYzdiNDk3NzhjMmQyYmI2MWFj
OWIwYmI0ODcyYzdmMDY2ZDJdIDBkYXkgYmFzZSBndWFyZCBmb3IgJ2RldmVsLWY0LWkzODYt
MjAxNDA0MTAwMTAzJwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290
LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdApscyAtYSAva2Vy
bmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2xpbnV4
LWRldmVsOmRldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzOjMyYzUxYzdiNDk3NzhjMmQyYmI2
MWFjOWIwYmI0ODcyYzdmMDY2ZDI6YmlzZWN0LWxpbnV4OAoKMjAxNC0wNC0xMC0wMTo0Mjox
NSAzMmM1MWM3YjQ5Nzc4YzJkMmJiNjFhYzliMGJiNDg3MmM3ZjA2NmQyIGNvbXBpbGluZwpR
dWV1ZWQgYnVpbGQgdGFzayB0byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFu
ZGNvbmZpZy1mZDMtMDQxMC0zMmM1MWM3YjQ5Nzc4YzJkMmJiNjFhYzliMGJiNDg3MmM3ZjA2
NmQyCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0
MTAvMzJjNTFjN2I0OTc3OGMyZDJiYjYxYWM5YjBiYjQ4NzJjN2YwNjZkMgp3YWl0aW5nIGZv
ciBjb21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29u
ZmlnLWZkMy0wNDEwLTMyYzUxYzdiNDk3NzhjMmQyYmI2MWFjOWIwYmI0ODcyYzdmMDY2ZDIK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy5p
Mzg2LXJhbmRjb25maWctZmQzLTA0MTAtMzJjNTFjN2I0OTc3OGMyZDJiYjYxYWM5YjBiYjQ4
NzJjN2YwNjZkMgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzMy
YzUxYzdiNDk3NzhjMmQyYmI2MWFjOWIwYmI0ODcyYzdmMDY2ZDIvdm1saW51ei0zLjE0LjAt
MDAwMDEtZzMyYzUxYzdiCgoyMDE0LTA0LTEwLTAxOjUwOjE1IGRldGVjdGluZyBib290IHN0
YXRlIC4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA1NCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgNiBzdGVwcykKWzQxYTNiZmUwZDM2M2NiMzk0OWVlYmMy
MGQ1NjM2NzRlZGM0MTI1OTldIE1lcmdlICdtbGFua2hvcnN0L21hc3RlcicgaW50byBkZXZl
bC1mNC1pMzg2LTIwMTQwNDEwMDEwMwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3Qt
dGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdAps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWZkMy0w
NDEwL2xpbnV4LWRldmVsOmRldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzOjQxYTNiZmUwZDM2
M2NiMzk0OWVlYmMyMGQ1NjM2NzRlZGM0MTI1OTk6YmlzZWN0LWxpbnV4OAoKMjAxNC0wNC0x
MC0wMTo1MToxNiA0MWEzYmZlMGQzNjNjYjM5NDllZWJjMjBkNTYzNjc0ZWRjNDEyNTk5IGNv
bXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVl
L2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC00MWEzYmZlMGQzNjNjYjM5NDllZWJjMjBkNTYz
Njc0ZWRjNDEyNTk5CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctZmQzLTA0MTAvNDFhM2JmZTBkMzYzY2IzOTQ5ZWViYzIwZDU2MzY3NGVkYzQxMjU5OQp3
YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUvaTM4
Ni1yYW5kY29uZmlnLWZkMy0wNDEwLTQxYTNiZmUwZDM2M2NiMzk0OWVlYmMyMGQ1NjM2NzRl
ZGM0MTI1OTkKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxk
LXF1ZXVlLy5pMzg2LXJhbmRjb25maWctZmQzLTA0MTAtNDFhM2JmZTBkMzYzY2IzOTQ5ZWVi
YzIwZDU2MzY3NGVkYzQxMjU5OQprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZk
My0wNDEwLzQxYTNiZmUwZDM2M2NiMzk0OWVlYmMyMGQ1NjM2NzRlZGM0MTI1OTkvdm1saW51
ei0zLjE0LjAtMDAwNDktZzQxYTNiZmUKCjIwMTQtMDQtMTAtMDE6NTM6MTYgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgLi4JNAkxNAkxOS4JMjAgU1VDQ0VTUwoKbGluZWFyLWJpc2VjdDogYmFk
IGJyYW5jaCBtYXkgYmUgYmFsYW5jZW51bWEvbW0tbnVtYS11c2UtaGlnaC1iaXQtdjNyMQps
aW5lYXItYmlzZWN0OiBoYW5kbGUgb3ZlciB0byBnaXQgYmlzZWN0CmxpbmVhci1iaXNlY3Q6
IGdpdCBiaXNlY3Qgc3RhcnQgYTkyMzgxYTkyNzU4NzhhNWIzYTdhYjgyZDYyYjdmODBlZTJh
N2NjNiA0MWEzYmZlMGQzNjNjYjM5NDllZWJjMjBkNTYzNjc0ZWRjNDEyNTk5IC0tClByZXZp
b3VzIEhFQUQgcG9zaXRpb24gd2FzIDQxYTNiZmUuLi4gTWVyZ2UgJ21sYW5raG9yc3QvbWFz
dGVyJyBpbnRvIGRldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzCkhFQUQgaXMgbm93IGF0IGVk
ZWEwZDAuLi4gaWE2NDoga2lsbCB0aHJlYWRfbWF0Y2hlcygpLCB1bmV4cG9ydCBwdHJhY2Vf
Y2hlY2tfYXR0YWNoKCkKQmlzZWN0aW5nOiAyIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0
ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbNjIyNTFhODM4YzQ3ZmM4YWVlNDAyNTU1ZDhj
NTA0NzVhNzU4NDY2OV0gbW06IEFsbG93IEZPTExfTlVNQSBvbiBGT0xMX0ZPUkNFCmxpbmVh
ci1iaXNlY3Q6IGdpdCBiaXNlY3QgcnVuIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdApydW5uaW5n
IC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10
ZXN0cy9saW51eDgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2xpbnV4LWRldmVsOmRldmVsLWY0LWkzODYt
MjAxNDA0MTAwMTAzOjYyMjUxYTgzOGM0N2ZjOGFlZTQwMjU1NWQ4YzUwNDc1YTc1ODQ2Njk6
YmlzZWN0LWxpbnV4OAoKMjAxNC0wNC0xMC0wMTo1Njo1OSA2MjI1MWE4MzhjNDdmYzhhZWU0
MDI1NTVkOGM1MDQ3NWE3NTg0NjY5IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAv
a2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC02MjI1
MWE4MzhjNDdmYzhhZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5CkNoZWNrIGZvciBrZXJuZWwg
aW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3ZmM4YWVl
NDAyNTU1ZDhjNTA0NzVhNzU4NDY2OQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rZXJu
ZWwtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLTYyMjUxYTgz
OGM0N2ZjOGFlZTQwMjU1NWQ4YzUwNDc1YTc1ODQ2NjkKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWctZmQzLTA0
MTAtNjIyNTFhODM4YzQ3ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OQprZXJuZWw6IC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzYyMjUxYTgzOGM0N2ZjOGFlZTQwMjU1
NWQ4YzUwNDc1YTc1ODQ2Njkvdm1saW51ei0zLjE0LjAtMDAwMDMtZzYyMjUxYTgKCjIwMTQt
MDQtMTAtMDE6NTk6NTkgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLiBURVNUIEZBSUxVUkUKWyAg
ICAwLjAwMDAwMF0gICAgICAgLnRleHQgOiAweDgzNDAwMDAwIC0gMHg4NDExYzNkMSAgICgx
MzQyNCBrQikKWyAgICAwLjAwMDAwMF0gQ2hlY2tpbmcgaWYgdGhpcyBwcm9jZXNzb3IgaG9u
b3VycyB0aGUgV1AgYml0IGV2ZW4gaW4gc3VwZXJ2aXNvciBtb2RlLi4uClsgICAgMC4wMDAw
MDBdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDAuMDAwMDAw
XSBrZXJuZWwgQlVHIGF0IGFyY2gveDg2L2luY2x1ZGUvYXNtL3BndGFibGUuaDo0NTEhClsg
ICAgMC4wMDAwMDBdIGludmFsaWQgb3Bjb2RlOiAwMDAwIFsjMV0gREVCVUdfUEFHRUFMTE9D
ClsgICAgMC4wMDAwMDBdIENQVTogMCBQSUQ6IDAgQ29tbTogc3dhcHBlciBOb3QgdGFpbnRl
ZCAzLjE0LjAtMDAwMDMtZzYyMjUxYTggIzEKWyAgICAwLjAwMDAwMF0gdGFzazogODQ3MDA4
MjAgdGk6IDg0NmZjMDAwIHRhc2sudGk6IDg0NmZjMDAwClsgICAgMC4wMDAwMDBdIEVJUDog
MDA2MDpbPDgzNGExNmVhPl0gRUZMQUdTOiAwMDIxMDAwMiBDUFU6IDAKWyAgICAwLjAwMDAw
MF0gRUlQIGlzIGF0IHNwdXJpb3VzX2ZhdWx0KzB4MTJhLzB4MjUwClsgICAgMC4wMDAwMDBd
IEVBWDogMDAwMDAwMDEgRUJYOiAwMDAwMDAwMSBFQ1g6IDAwMDAwMDAwIEVEWDogMDAwMDAw
MDAKWyAgICAwLjAwMDAwMF0gRVNJOiAwMDAwMDAwMyBFREk6IDg0YzkxYTg0IEVCUDogODQ2
ZmRlNzAgRVNQOiA4NDZmZGU1MApbICAgIDAuMDAwMDAwXSAgRFM6IDAwN2IgRVM6IDAwN2Ig
RlM6IDAwMDAgR1M6IDAwZTAgU1M6IDAwNjgKWyAgICAwLjAwMDAwMF0gQ1IwOiA4MDA1MDAz
YiBDUjI6IGZmZWExMDAwIENSMzogMGNjOGUwMDAgQ1I0OiAwMDAwMDY5MApbICAgIDAuMDAw
MDAwXSBTdGFjazoKWyAgICAwLjAwMDAwMF0gIDAwMDAwMDAwIDAwMDAwMDAwIDAwMDAwMDAx
IDBjYzhlMTYxIDg0YzhlZmZjIDAwMDAwMDAxIGZmZWExMDAwIDAwMDAwMDAzClsgICAgMC4w
MDAwMDBdICA4NDZmZGYwNCA4MzRhMThlZCA4NDg1NWE1MCA4NDg1NWE1MCA4MzUxNjFjZiAw
MDAwMDAwMSA4NDg1NWE0MCAwMDAwMDAwMQpbICAgIDAuMDAwMDAwXSAgODQ4NTU5ZjAgODQ4
NTU5ZjAgMDAwMDAwMDEgODQ4NTU5ZTAgODQ2ZmRlYjAgODQ3MDA4MjAgMDAwMDAwNWMgMDAw
MDAwMDAKWyAgICAwLjAwMDAwMF0gQ2FsbCBUcmFjZToKWyAgICAwLjAwMDAwMF0gIFs8ODM0
YTE4ZWQ+XSBfX2RvX3BhZ2VfZmF1bHQrMHhkZC8weDg3MApbICAgIDAuMDAwMDAwXSAgWzw4
MzUxNjFjZj5dID8gY29uc29sZV91bmxvY2srMHg0MWYvMHg3ODAKWyAgICAwLjAwMDAwMF0g
IFs8ODQxMTgyM2Q+XSA/IF9yYXdfc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSsweDZkLzB4NzAK
WyAgICAwLjAwMDAwMF0gIFs8ODM1MTYxZjY+XSA/IGNvbnNvbGVfdW5sb2NrKzB4NDQ2LzB4
NzgwClsgICAgMC4wMDAwMDBdICBbPDg0MTE4MjNkPl0gPyBfcmF3X3NwaW5fdW5sb2NrX2ly
cXJlc3RvcmUrMHg2ZC8weDcwClsgICAgMC4wMDAwMDBdICBbPDgzNTBhMjI2Pl0gPyB0cmFj
ZV9oYXJkaXJxc19vZmZfY2FsbGVyKzB4NjYvMHhiMApbICAgIDAuMDAwMDAwXSAgWzw4MzQ5
ZTIzMD5dID8ga3ZtX3JlYWRfYW5kX3Jlc2V0X3BmX3JlYXNvbisweDQwLzB4NDAKWyAgICAw
LjAwMDAwMF0gIFs8ODM0YTIyZjE+XSBkb19wYWdlX2ZhdWx0KzB4MjEvMHgzMApbICAgIDAu
MDAwMDAwXSAgWzw4MzQ5ZTI1ZT5dIGRvX2FzeW5jX3BhZ2VfZmF1bHQrMHgyZS8weDkwClsg
ICAgMC4wMDAwMDBdICBbPDg0MTE5ODUyPl0gZXJyb3JfY29kZSsweDZhLzB4NzAKWyAgICAw
LjAwMDAwMF0gIFs8ODM0YTAwN2I+XSA/IHBlcmZfcmVnX3ZhbHVlKzB4OWIvMHgxYTAKWyAg
ICAwLjAwMDAwMF0gIFs8ODQxMDAzNWU+XSA/IGRvX3Rlc3Rfd3BfYml0KzB4MTkvMHgyMwpb
ICAgIDAuMDAwMDAwXSAgWzw4NGMwMTBkOD5dIG1lbV9pbml0KzB4MWRjLzB4MjNkClsgICAg
MC4wMDAwMDBdICBbPDg0YmU4MDAwPl0gPyB4ODZfY3B1X3RvX2FwaWNpZCsweGEzYS8weGEz
YQpbICAgIDAuMDAwMDAwXSAgWzw4NGJlOGI1YT5dIHN0YXJ0X2tlcm5lbCsweDFjZi8weDQ3
ZApbICAgIDAuMDAwMDAwXSAgWzw4NGJlODY3ND5dID8gcmVwYWlyX2Vudl9zdHJpbmcrMHg5
OS8weDk5ClsgICAgMC4wMDAwMDBdICBbPDg0YmU4M2M3Pl0gaTM4Nl9zdGFydF9rZXJuZWwr
MHgxNzUvMHgxNzgKWyAgICAwLjAwMDAwMF0gQ29kZTogMDcgODkgNDUgZWMgYzEgZTggMDgg
ODkgYzMgYjggZjAgNmEgOGYgODQgODMgZTMgMDEgODkgZGEgZTggMzkgNDIgMGQgMDAgOGIg
MDQgOWQgYWMgOTEgOTUgODQgNDAgODUgZGIgODkgMDQgOWQgYWMgOTEgOTUgODQgNzQgMTEg
PDBmPiAwYiA4YiA1NSBmMCA4OSBmMCBlOCA1YSBmMCBmZiBmZiBlOSBmYyBmZSBmZiBmZiAz
MSBjMCBmNyA0NQpbICAgIDAuMDAwMDAwXSBFSVA6IFs8ODM0YTE2ZWE+XSBzcHVyaW91c19m
YXVsdCsweDEyYS8weDI1MCBTUzpFU1AgMDA2ODo4NDZmZGU1MApbICAgIDAuMDAwMDAwXSAt
LS1bIGVuZCB0cmFjZSAwNWUwYzA3ZWIxYzY2M2E2IF0tLS0KWyAgICAwLjAwMDAwMF0gS2Vy
bmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEF0dGVtcHRlZCB0byBraWxsIHRoZSBpZGxlIHRh
c2shCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzYyMjUxYTgzOGM0N2ZjOGFl
ZTQwMjU1NWQ4YzUwNDc1YTc1ODQ2NjkvZG1lc2cteW9jdG8tbGtwLWliMDMtMTE0OjIwMTQw
NDEwMDE1OTIyOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLWxrcC1pYjAzLTU4OjIwMTQw
NDEwMDE1OTIyOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLWxrcC1pYjA0LTEzOjIwMTQw
NDEwMDE1OTE4OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLWxrcC1pYjA0LTIwOjIwMTQw
NDEwMDE1OTE5OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLWxrcC1pYjA0LTQ1OjIwMTQw
NDEwMDE1OTE4OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLWxrcC1pYjA0LTY0OjIwMTQw
NDEwMDE1OTE5OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUx
YTg6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhh
ZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2RtZXNnLXlvY3RvLXNuYi0yNDoyMDE0MDQxMDAx
NTkyMTppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhhZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5L2Rt
ZXNnLXlvY3RvLXNuYi0yOjIwMTQwNDEwMDE1OTE5OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MDo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzYyMjUxYTgzOGM0N2ZjOGFl
ZTQwMjU1NWQ4YzUwNDc1YTc1ODQ2NjkvZG1lc2cteW9jdG8tc25iLTM4OjIwMTQwNDEwMDE1
OTIwOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWZkMy0wNDEwLzYyMjUxYTgzOGM0N2ZjOGFlZTQwMjU1NWQ4YzUwNDc1YTc1ODQ2NjkvZG1l
c2ctcXVhbnRhbC1sa3AtaWIwNC0xMjoyMDE0MDQxMDAxNTkyNDppMzg2LXJhbmRjb25maWct
ZmQzLTA0MTA6My4xNC4wLTAwMDAzLWc2MjI1MWE4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OS9k
bWVzZy1xdWFudGFsLWxrcC1pYjA0LTc4OjIwMTQwNDEwMDE1OTMwOmkzODYtcmFuZGNvbmZp
Zy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUxYTg6MQova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhhZWU0MDI1NTVkOGM1MDQ3NWE3NTg0NjY5
L2RtZXNnLXF1YW50YWwtc25iLTE6MjAxNDA0MTAwMTU5MjQ6aTM4Ni1yYW5kY29uZmlnLWZk
My0wNDEwOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3
ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OS9kbWVzZy15b2N0by1sa3AtaWIwMy0xNToy
MDE0MDQxMDAxNTkyMzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDAzLWc2
MjI1MWE4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3
ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OS9kbWVzZy15b2N0by1sa3AtaWIwMy0xNzoy
MDE0MDQxMDAxNTkyMzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDAzLWc2
MjI1MWE4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3
ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OS9kbWVzZy15b2N0by1sa3AtaWIwMy03MDoy
MDE0MDQxMDAxNTkyNTppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDAzLWc2
MjI1MWE4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3
ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2OS9kbWVzZy15b2N0by1zbmItMzM6MjAxNDA0
MTAwMTU5Mjc6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjoKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3ZmM4YWVlNDAyNTU1ZDhjNTA0NzVhNzU4NDY2
OS9kbWVzZy1xdWFudGFsLWxrcC1pYjAzLTE5OjIwMTQwNDEwMDE1OTM2OmkzODYtcmFuZGNv
bmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUxYTg6MQova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1mZDMtMDQxMC82MjI1MWE4MzhjNDdmYzhhZWU0MDI1NTVkOGM1MDQ3NWE3NTg0
NjY5L2RtZXNnLXF1YW50YWwtbGtwLWliMDMtNTI6MjAxNDA0MTAwMTU5MzQ6aTM4Ni1yYW5k
Y29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDAwMy1nNjIyNTFhODoxCi9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWZkMy0wNDEwLzYyMjUxYTgzOGM0N2ZjOGFlZTQwMjU1NWQ4YzUwNDc1YTc1
ODQ2NjkvZG1lc2ctcXVhbnRhbC1sa3AtaWIwMy03NjoyMDE0MDQxMDAxNTkzNjppMzg2LXJh
bmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDAzLWc2MjI1MWE4OjEKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctZmQzLTA0MTAvNjIyNTFhODM4YzQ3ZmM4YWVlNDAyNTU1ZDhjNTA0NzVh
NzU4NDY2OS9kbWVzZy1xdWFudGFsLWxrcC1pYjAzLTk3OjIwMTQwNDEwMDE1OTM0OmkzODYt
cmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDMtZzYyMjUxYTg6MQowOjIwOjIwIGFs
bF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA0LTEwIDAyOjAwOjMwIFJF
UEVBVCBDT1VOVDogMjAgICMgL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdC8ucmVw
ZWF0G1swbQoKQmlzZWN0aW5nOiAwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAxIHN0ZXApCltiMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0
ODNkNjZhXSB4ODY6IERlZmluZSBfUEFHRV9OVU1BIGJ5IHJldXNpbmcgc29mdHdhcmUgYml0
cyBvbiB0aGUgUE1EIGFuZCBQVEUgbGV2ZWxzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlz
ZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWct
ZmQzLTA0MTAvbGludXgtZGV2ZWw6ZGV2ZWwtZjQtaTM4Ni0yMDE0MDQxMDAxMDM6YjFhMDA4
ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YTpiaXNlY3QtbGludXg4CgoyMDE0
LTA0LTEwLTAyOjAwOjMxIGIxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2
NmEgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rZXJuZWwtdGVzdHMvYnVpbGQt
cXVldWUvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLWIxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2
MTU5MjA1Zjk3MTQ4M2Q2NmEKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1mZDMtMDQxMC9iMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNk
NjZhCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1
ZS9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAtYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTky
MDVmOTcxNDgzZDY2YQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMv
YnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC1iMWEwMDhkNTdjNDE1NjJj
YjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS92
bWxpbnV6LTMuMTQuMC0wMDAwMi1nYjFhMDA4ZAoKMjAxNC0wNC0xMC0wMjowMjozMSBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAuIFRFU1QgRkFJTFVSRQpbICAgIDAuMDAwMDAwXSAgICAgICAu
dGV4dCA6IDB4ODYyMDAwMDAgLSAweDg2ZjFjNDExICAgKDEzNDI1IGtCKQpbICAgIDAuMDAw
MDAwXSBDaGVja2luZyBpZiB0aGlzIHByb2Nlc3NvciBob25vdXJzIHRoZSBXUCBiaXQgZXZl
biBpbiBzdXBlcnZpc29yIG1vZGUuLi4KWyAgICAwLjAwMDAwMF0gLS0tLS0tLS0tLS0tWyBj
dXQgaGVyZSBdLS0tLS0tLS0tLS0tClsgICAgMC4wMDAwMDBdIGtlcm5lbCBCVUcgYXQgYXJj
aC94ODYvaW5jbHVkZS9hc20vcGd0YWJsZS5oOjQ1MSEKWyAgICAwLjAwMDAwMF0gaW52YWxp
ZCBvcGNvZGU6IDAwMDAgWyMxXSBERUJVR19QQUdFQUxMT0MKWyAgICAwLjAwMDAwMF0gQ1BV
OiAwIFBJRDogMCBDb21tOiBzd2FwcGVyIE5vdCB0YWludGVkIDMuMTQuMC0wMDAwMi1nYjFh
MDA4ZCAjMzgwClsgICAgMC4wMDAwMDBdIHRhc2s6IDg3NGZlODIwIHRpOiA4NzRmYTAwMCB0
YXNrLnRpOiA4NzRmYTAwMApbICAgIDAuMDAwMDAwXSBFSVA6IDAwNjA6Wzw4NjJhMTZlYT5d
IEVGTEFHUzogMDAyMTAwMDIgQ1BVOiAwClsgICAgMC4wMDAwMDBdIEVJUCBpcyBhdCBzcHVy
aW91c19mYXVsdCsweDEyYS8weDI1MApbICAgIDAuMDAwMDAwXSBFQVg6IDAwMDAwMDAxIEVC
WDogMDAwMDAwMDEgRUNYOiAwMDAwMDAwMCBFRFg6IDAwMDAwMDAwClsgICAgMC4wMDAwMDBd
IEVTSTogMDAwMDAwMDMgRURJOiA4N2E4ZmE4NCBFQlA6IDg3NGZiZTcwIEVTUDogODc0ZmJl
NTAKWyAgICAwLjAwMDAwMF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMDAwIEdTOiAwMGUw
IFNTOiAwMDY4ClsgICAgMC4wMDAwMDBdIENSMDogODAwNTAwM2IgQ1IyOiBmZmVhMTAwMCBD
UjM6IDBmYThjMDAwIENSNDogMDAwMDA2OTAKWyAgICAwLjAwMDAwMF0gU3RhY2s6ClsgICAg
MC4wMDAwMDBdICAwMDAwMDAwMCAwMDAwMDAwMCAwMDAwMDAwMSAwZmE4YzE2MSA4N2E4Y2Zm
YyAwMDAwMDAwMSBmZmVhMTAwMCAwMDAwMDAwMwpbICAgIDAuMDAwMDAwXSAgODc0ZmJmMDQg
ODYyYTE4ZWQgODc2NTNhNTAgODc2NTNhNTAgODYzMTYxY2YgMDAwMDAwMDEgODc2NTNhNDAg
MDAwMDAwMDEKWyAgICAwLjAwMDAwMF0gIDg3NjUzOWYwIDg3NjUzOWYwIDAwMDAwMDAxIDg3
NjUzOWUwIDg3NGZiZWIwIDg3NGZlODIwIDAwMDAwMDVjIDAwMDAwMDAwClsgICAgMC4wMDAw
MDBdIENhbGwgVHJhY2U6ClsgICAgMC4wMDAwMDBdICBbPDg2MmExOGVkPl0gX19kb19wYWdl
X2ZhdWx0KzB4ZGQvMHg4NzAKWyAgICAwLjAwMDAwMF0gIFs8ODYzMTYxY2Y+XSA/IGNvbnNv
bGVfdW5sb2NrKzB4NDFmLzB4NzgwClsgICAgMC4wMDAwMDBdICBbPDg2ZjE4MjRkPl0gPyBf
cmF3X3NwaW5fdW5sb2NrX2lycXJlc3RvcmUrMHg2ZC8weDcwClsgICAgMC4wMDAwMDBdICBb
PDg2MzE2MWY2Pl0gPyBjb25zb2xlX3VubG9jaysweDQ0Ni8weDc4MApbICAgIDAuMDAwMDAw
XSAgWzw4NmYxODI0ZD5dID8gX3Jhd19zcGluX3VubG9ja19pcnFyZXN0b3JlKzB4NmQvMHg3
MApbICAgIDAuMDAwMDAwXSAgWzw4NjMwYTIyNj5dID8gdHJhY2VfaGFyZGlycXNfb2ZmX2Nh
bGxlcisweDY2LzB4YjAKWyAgICAwLjAwMDAwMF0gIFs8ODYyOWUyMzA+XSA/IGt2bV9yZWFk
X2FuZF9yZXNldF9wZl9yZWFzb24rMHg0MC8weDQwClsgICAgMC4wMDAwMDBdICBbPDg2MmEy
MmYxPl0gZG9fcGFnZV9mYXVsdCsweDIxLzB4MzAKWyAgICAwLjAwMDAwMF0gIFs8ODYyOWUy
NWU+XSBkb19hc3luY19wYWdlX2ZhdWx0KzB4MmUvMHg5MApbICAgIDAuMDAwMDAwXSAgWzw4
NmYxOTg2Mj5dIGVycm9yX2NvZGUrMHg2YS8weDcwClsgICAgMC4wMDAwMDBdICBbPDg2MmEw
MDdiPl0gPyBwZXJmX3JlZ192YWx1ZSsweDliLzB4MWEwClsgICAgMC4wMDAwMDBdICBbPDg2
ZjAwMzZlPl0gPyBkb190ZXN0X3dwX2JpdCsweDE5LzB4MjMKWyAgICAwLjAwMDAwMF0gIFs8
ODc5ZmYwZDg+XSBtZW1faW5pdCsweDFkYy8weDIzZApbICAgIDAuMDAwMDAwXSAgWzw4Nzll
NjAwMD5dID8geDg2X2NwdV90b19hcGljaWQrMHg5ZmEvMHg5ZmEKWyAgICAwLjAwMDAwMF0g
IFs8ODc5ZTZiNWE+XSBzdGFydF9rZXJuZWwrMHgxY2YvMHg0N2QKWyAgICAwLjAwMDAwMF0g
IFs8ODc5ZTY2NzQ+XSA/IHJlcGFpcl9lbnZfc3RyaW5nKzB4OTkvMHg5OQpbICAgIDAuMDAw
MDAwXSAgWzw4NzllNjNjNz5dIGkzODZfc3RhcnRfa2VybmVsKzB4MTc1LzB4MTc4ClsgICAg
MC4wMDAwMDBdIENvZGU6IDA3IDg5IDQ1IGVjIGMxIGU4IDA4IDg5IGMzIGI4IGYwIDRhIDZm
IDg3IDgzIGUzIDAxIDg5IGRhIGU4IDM5IDQyIDBkIDAwIDhiIDA0IDlkIGFjIDcxIDc1IDg3
IDQwIDg1IGRiIDg5IDA0IDlkIGFjIDcxIDc1IDg3IDc0IDExIDwwZj4gMGIgOGIgNTUgZjAg
ODkgZjAgZTggNWEgZjAgZmYgZmYgZTkgZmMgZmUgZmYgZmYgMzEgYzAgZjcgNDUKWyAgICAw
LjAwMDAwMF0gRUlQOiBbPDg2MmExNmVhPl0gc3B1cmlvdXNfZmF1bHQrMHgxMmEvMHgyNTAg
U1M6RVNQIDAwNjg6ODc0ZmJlNTAKWyAgICAwLjAwMDAwMF0gLS0tWyBlbmQgdHJhY2UgMDVl
MGMwN2ViMWM2NjNhNiBdLS0tClsgICAgMC4wMDAwMDBdIEtlcm5lbCBwYW5pYyAtIG5vdCBz
eW5jaW5nOiBBdHRlbXB0ZWQgdG8ga2lsbCB0aGUgaWRsZSB0YXNrIQova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1mZDMtMDQxMC9iMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0
ODNkNjZhL2RtZXNnLXF1YW50YWwtZjItNjg6MjAxNDA0MTAwMjAyNDE6aTM4Ni1yYW5kY29u
ZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgz
ZDY2YS9kbWVzZy1xdWFudGFsLWYyLTk2OjIwMTQwNDEwMDIwMjQxOmkzODYtcmFuZGNvbmZp
Zy1mZDMtMDQxMDozLjE0LjAtMDAwMDItZ2IxYTAwOGQ6MzgwCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWZkMy0wNDEwL2IxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2
NmEvZG1lc2ctcXVhbnRhbC1mMy0xMTA6MjAxNDA0MTAwMjAyNDI6aTM4Ni1yYW5kY29uZmln
LWZkMy0wNDEwOjMuMTQuMC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2
YS9kbWVzZy1xdWFudGFsLWYzLTExODoyMDE0MDQxMDAyMDI0MjppMzg2LXJhbmRjb25maWct
ZmQzLTA0MTA6My4xNC4wLTAwMDAyLWdiMWEwMDhkOjM4MAova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1mZDMtMDQxMC9iMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZh
L2RtZXNnLXF1YW50YWwtZjMtMzE6MjAxNDA0MTAwMjAyNDI6aTM4Ni1yYW5kY29uZmlnLWZk
My0wNDEwOjMuMTQuMC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS9k
bWVzZy1xdWFudGFsLWYzLTQxOjIwMTQwNDEwMDIwMjQyOmkzODYtcmFuZGNvbmZpZy1mZDMt
MDQxMDozLjE0LjAtMDAwMDItZ2IxYTAwOGQ6MzgwCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWZkMy0wNDEwL2IxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2NmEvZG1l
c2cteW9jdG8tZjMtNjM6MjAxNDA0MTAwMjAyNDI6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEw
OjMuMTQuMC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQz
LTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS9kbWVzZy15
b2N0by1mNC0xNzoyMDE0MDQxMDAyMDI0MTppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4x
NC4wLTAwMDAyLWdiMWEwMDhkOjM4MAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MC9iMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhL2RtZXNnLXlvY3Rv
LWY0LTQzOjIwMTQwNDEwMDIwMjQxOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAt
MDAwMDItZ2IxYTAwOGQ6MzgwCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2Ix
YTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2NmEvZG1lc2cteW9jdG8tbGtw
LWliMDMtMzg6MjAxNDA0MTAwMjAyNDE6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQu
MC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAv
YjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS9kbWVzZy15b2N0by1s
a3AtaWIwMy04MDoyMDE0MDQxMDAyMDI0MTppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4x
NC4wLTAwMDAyLWdiMWEwMDhkOjM4MAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MC9iMWEwMDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhL2RtZXNnLXF1YW50
YWwtZjMtMzM6MjAxNDA0MTAwMjAyNDM6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQu
MC0wMDAwMi1nYjFhMDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAv
YjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS9kbWVzZy15b2N0by1m
My01NzoyMDE0MDQxMDAyMDI0MzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAw
MDAyLWdiMWEwMDhkOjM4MAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9iMWEw
MDhkNTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhL2RtZXNnLXlvY3RvLWYzLTU4
OjIwMTQwNDEwMDIwMjQyOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDAwMDIt
Z2IxYTAwOGQ6MzgwCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2IxYTAwOGQ1
N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2NmEvZG1lc2cteW9jdG8tZjQtODU6MjAx
NDA0MTAwMjAyNDI6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMuMTQuMC0wMDAwMi1nYjFh
MDA4ZDozODAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQx
NTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgzZDY2YS9kbWVzZy15b2N0by1sa3AtaWIwNC0yNDoy
MDE0MDQxMDAyMDI0MzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAwMDAyLWdi
MWEwMDhkOjM4MAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9iMWEwMDhkNTdj
NDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhL2RtZXNnLXF1YW50YWwtc25iLTE6MjAx
NDA0MTAwMjAyNDg6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctZmQzLTA0MTAvYjFhMDA4ZDU3YzQxNTYyY2I5ZjNmZTYxNTkyMDVmOTcxNDgz
ZDY2YS9kbWVzZy1xdWFudGFsLXNuYi0yMjoyMDE0MDQxMDAyMDI0ODppMzg2LXJhbmRjb25m
aWctZmQzLTA0MTA6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9iMWEwMDhk
NTdjNDE1NjJjYjlmM2ZlNjE1OTIwNWY5NzE0ODNkNjZhL2RtZXNnLXF1YW50YWwtc25iLTIz
OjIwMTQwNDEwMDIwMjQzOmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDo6CjA6MTk6MTkgYWxs
X2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQtMDQtMTAgMDI6MDM6MDIgUkVQ
RUFUIENPVU5UOiAyMCAgIyAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0Ly5yZXBl
YXQbWzBtCgpCaXNlY3Rpbmc6IDAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDAgc3RlcHMpCls3MWJjYTE3ZDk5YjM2MDlhZjQ0ZTM0MzI4NzU5OGZiNDFk
ZDY3NzUwXSB4ODY6IFJlcXVpcmUgeDg2LTY0IGZvciBhdXRvbWF0aWMgTlVNQSBiYWxhbmNp
bmcKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9y
dW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9saW51eC1kZXZlbDpkZXZl
bC1mNC1pMzg2LTIwMTQwNDEwMDEwMzo3MWJjYTE3ZDk5YjM2MDlhZjQ0ZTM0MzI4NzU5OGZi
NDFkZDY3NzUwOmJpc2VjdC1saW51eDgKCjIwMTQtMDQtMTAtMDI6MDM6MDMgNzFiY2ExN2Q5
OWIzNjA5YWY0NGUzNDMyODc1OThmYjQxZGQ2Nzc1MCBjb21waWxpbmcKUXVldWVkIGJ1aWxk
IHRhc2sgdG8gL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctZmQz
LTA0MTAtNzFiY2ExN2Q5OWIzNjA5YWY0NGUzNDMyODc1OThmYjQxZGQ2Nzc1MApDaGVjayBm
b3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzcxYmNhMTdk
OTliMzYwOWFmNDRlMzQzMjg3NTk4ZmI0MWRkNjc3NTAKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MC03MWJjYTE3ZDk5YjM2MDlhZjQ0ZTM0MzI4NzU5OGZiNDFkZDY3NzUwCndhaXRpbmcgZm9y
IGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29u
ZmlnLWZkMy0wNDEwLTcxYmNhMTdkOTliMzYwOWFmNDRlMzQzMjg3NTk4ZmI0MWRkNjc3NTAK
a2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC83MWJjYTE3ZDk5YjM2
MDlhZjQ0ZTM0MzI4NzU5OGZiNDFkZDY3NzUwL3ZtbGludXotMy4xNC4wLTAwMDAxLWc3MWJj
YTE3CgoyMDE0LTA0LTEwLTAyOjA1OjAzIGRldGVjdGluZyBib290IHN0YXRlIC4uCTEyCTIw
IFNVQ0NFU1MKCmIxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5MjA1Zjk3MTQ4M2Q2NmEgaXMg
dGhlIGZpcnN0IGJhZCBjb21taXQKY29tbWl0IGIxYTAwOGQ1N2M0MTU2MmNiOWYzZmU2MTU5
MjA1Zjk3MTQ4M2Q2NmEKQXV0aG9yOiBNZWwgR29ybWFuIDxtZ29ybWFuQHN1c2UuZGU+CkRh
dGU6ICAgTW9uIEFwciA3IDEwOjI1OjEyIDIwMTQgKzAxMDAKCiAgICB4ODY6IERlZmluZSBf
UEFHRV9OVU1BIGJ5IHJldXNpbmcgc29mdHdhcmUgYml0cyBvbiB0aGUgUE1EIGFuZCBQVEUg
bGV2ZWxzCiAgICAKICAgIF9QQUdFX05VTUEgaXMgY3VycmVudGx5IGFuIGFsaWFzIG9mIF9Q
Uk9UX1BST1ROT05FIHRvIHRyYXAgTlVNQSBoaW50aW5nCiAgICBmYXVsdHMuIENhcmUgaXMg
dGFrZW4gc3VjaCB0aGF0IF9QQUdFX05VTUEgaXMgdXNlZCBvbmx5IGluIHNpdHVhdGlvbnMg
d2hlcmUKICAgIHRoZSBWTUEgZmxhZ3MgZGlzdGluZ3Vpc2ggYmV0d2VlbiBOVU1BIGhpbnRp
bmcgZmF1bHRzIGFuZCBwcm90X25vbmUgZmF1bHRzLgogICAgQ29uY2VwdHVhbGx5IHRoaXMg
aXMgZGlmZmljdWx0IGFuZCBpdCBoYXMgY2F1c2VkIHByb2JsZW1zLgogICAgCiAgICBGdW5k
YW1lbnRhbGx5LCB3ZSBvbmx5IG5lZWQgdGhlIF9QQUdFX05VTUEgYml0IHRvIHRlbGwgdGhl
IGRpZmZlcmVuY2UgYmV0d2VlbgogICAgYW4gZW50cnkgdGhhdCBpcyByZWFsbHkgdW5tYXBw
ZWQgYW5kIGEgcGFnZSB0aGF0IGlzIHByb3RlY3RlZCBmb3IgTlVNQQogICAgaGludGluZyBm
YXVsdHMgYXMgaWYgdGhlIFBURSBpcyBub3QgcHJlc2VudCB0aGVuIGEgZmF1bHQgd2lsbCBi
ZSB0cmFwcGVkLgogICAgCiAgICBDdXJyZW50bHkgb25lIG9mIHRoZSBzb2Z0d2FyZSBiaXRz
IGlzIHVzZWQgZm9yIGlkZW50aWZ5aW5nIElPIG1hcHBpbmdzIGFuZAogICAgYnkgWGVuIHRv
IHRyYWNrIGlmIGl0J3MgYSBYZW4gUFRFIG9yIGEgbWFjaGluZSBQRk4uICBUaGlzIHBhdGNo
IHJldXNlcyB0aGUKICAgIHNvZnR3YXJlIGJpdCBmb3IgSU9NQVAgZm9yIE5VTUEgaGludGlu
ZyBmYXVsdHMgd2l0aCB0aGUgZXhwZWN0YXRpb24gdGhhdAogICAgdGhlIGJpdCBpcyBub3Qg
dXNlZCBmb3IgdXNlcnNwYWNlIGFkZHJlc3Nlcy4gWGVuIGFuZCBOVU1BIGJhbGFuY2luZyBh
cmUKICAgIG5vdyBtdXR1YWxseSBleGNsdXNpdmUgaW4gS2NvbmZpZy4KICAgIAogICAgU2ln
bmVkLW9mZi1ieTogTWVsIEdvcm1hbiA8bWdvcm1hbkBzdXNlLmRlPgoKOjA0MDAwMCAwNDAw
MDAgMTljMTZmOTM1MmUxOGMxMTg3NzMzNWY5NDU4YmM0ZDg2YTNiOWIxMCA1MTdiMmRkZmEx
ZTAwYTU4Mjk5ZDliZDVhYWJhNGM2OGRhNjJiNjg4IE0JYXJjaApiaXNlY3QgcnVuIHN1Y2Nl
c3MKSEVBRCBpcyBub3cgYXQgNzFiY2ExNy4uLiB4ODY6IFJlcXVpcmUgeDg2LTY0IGZvciBh
dXRvbWF0aWMgTlVNQSBiYWxhbmNpbmcKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUv
a3ZtL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9saW51eC1kZXZlbDpkZXZlbC1mNC1pMzg2
LTIwMTQwNDEwMDEwMzo3MWJjYTE3ZDk5YjM2MDlhZjQ0ZTM0MzI4NzU5OGZiNDFkZDY3NzUw
OmJpc2VjdC1saW51eDgKCjIwMTQtMDQtMTAtMDI6MDc6MDQgNzFiY2ExN2Q5OWIzNjA5YWY0
NGUzNDMyODc1OThmYjQxZGQ2Nzc1MCByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1m
ZDMtMDQxMC83MWJjYTE3ZDk5YjM2MDlhZjQ0ZTM0MzI4NzU5OGZiNDFkZDY3NzUwL3ZtbGlu
dXotMy4xNC4wLTAwMDAxLWc3MWJjYTE3CgoyMDE0LTA0LTEwLTAyOjA3OjA0IGRldGVjdGlu
ZyBib290IHN0YXRlIC4uLgkzNgk0OQk1OQk2MCBTVUNDRVNTCgpQcmV2aW91cyBIRUFEIHBv
c2l0aW9uIHdhcyA3MWJjYTE3Li4uIHg4NjogUmVxdWlyZSB4ODYtNjQgZm9yIGF1dG9tYXRp
YyBOVU1BIGJhbGFuY2luZwpIRUFEIGlzIG5vdyBhdCBjYzEyZjAwLi4uIDBkYXkgaGVhZCBn
dWFyZCBmb3IgJ2RldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzJwpscyAtYSAva2VybmVsLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2xpbnV4LWRldmVs
OmRldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzOmNjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4
YmU2MzUyMDdhYTM4MWM6YmlzZWN0LWxpbnV4OAogVEVTVCBGQUlMVVJFClsgICAgMC4wMDAw
MDBdICAgICAgIC50ZXh0IDogMHg4MzQwMDAwMCAtIDB4ODQwNjU0MDUgICAoMTI2OTMga0Ip
ClsgICAgMC4wMDAwMDBdIENoZWNraW5nIGlmIHRoaXMgcHJvY2Vzc29yIGhvbm91cnMgdGhl
IFdQIGJpdCBldmVuIGluIHN1cGVydmlzb3IgbW9kZS4uLgpbICAgIDAuMDAwMDAwXSAtLS0t
LS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICAwLjAwMDAwMF0ga2VybmVs
IEJVRyBhdCBhcmNoL3g4Ni9pbmNsdWRlL2FzbS9wZ3RhYmxlLmg6NDUxIQpbICAgIDAuMDAw
MDAwXSBpbnZhbGlkIG9wY29kZTogMDAwMCBbIzFdIERFQlVHX1BBR0VBTExPQwpbICAgIDAu
MDAwMDAwXSBDUFU6IDAgUElEOiAwIENvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNC4w
LTAxMDI5LWdjYzEyZjAwICMzNzIKWyAgICAwLjAwMDAwMF0gdGFzazogODQ2NDg4MjAgdGk6
IDg0NjQ0MDAwIHRhc2sudGk6IDg0NjQ0MDAwClsgICAgMC4wMDAwMDBdIEVJUDogMDA2MDpb
PDgzNDk3MmM5Pl0gRUZMQUdTOiAwMDIwMDAwMiBDUFU6IDAKWyAgICAwLjAwMDAwMF0gRUlQ
IGlzIGF0IHNwdXJpb3VzX2ZhdWx0KzB4MTI2LzB4MjQ0ClsgICAgMC4wMDAwMDBdIEVBWDog
MDAwMDAwMDEgRUJYOiAwMDAwMDAwMSBFQ1g6IDAwMDAwMDAwIEVEWDogMDAwMDAwMDAKWyAg
ICAwLjAwMDAwMF0gRVNJOiAwMDAwMDAwMyBFREk6IDg0YmQ5YTg0IEVCUDogODQ2NDVlN2Mg
RVNQOiA4NDY0NWU1YwpbICAgIDAuMDAwMDAwXSAgRFM6IDAwN2IgRVM6IDAwN2IgRlM6IDAw
MDAgR1M6IDAwZTAgU1M6IDAwNjgKWyAgICAwLjAwMDAwMF0gQ1IwOiA4MDA1MDAzYiBDUjI6
IGZmZWExMDAwIENSMzogMGNiZDYwMDAgQ1I0OiAwMDAwMDY5MApbICAgIDAuMDAwMDAwXSBE
UjA6IDAwMDAwMDAwIERSMTogMDAwMDAwMDAgRFIyOiAwMDAwMDAwMCBEUjM6IDAwMDAwMDAw
ClsgICAgMC4wMDAwMDBdIERSNjogMDAwMDAwMDAgRFI3OiAwMDAwMDAwMApbICAgIDAuMDAw
MDAwXSBTdGFjazoKWyAgICAwLjAwMDAwMF0gIDg1MGY1MjBhIDAwMDAwMDA2IDg1MGZmZmZm
IDBjYmQ2MTYxIDg0YmQ2ZmZjIDAwMDAwMDAxIGZmZWExMDAwIDAwMDAwMDAzClsgICAgMC4w
MDAwMDBdICA4NDY0NWYxMCA4MzQ5NzRjNCAwMDAwMDAwMSA4NDc5ZGE0MCAwMDAwMDAwMSA4
NDc5ZDlmMCA4NDc5ZDlmMCAwMDAwMDAwMQpbICAgIDAuMDAwMDAwXSAgODQ3OWQ5ZTAgODQ2
NDVlYjAgODM1MDAxNTQgMDAyMDAwNDYgODM0ZjlkYjUgODQ2NDg4MjAgMDAwMDAwNWMgMDAw
MDAwMDAKWyAgICAwLjAwMDAwMF0gQ2FsbCBUcmFjZToKWyAgICAwLjAwMDAwMF0gIFs8ODM0
OTc0YzQ+XSBfX2RvX3BhZ2VfZmF1bHQrMHhkZC8weDg2MgpbICAgIDAuMDAwMDAwXSAgWzw4
MzUwMDE1ND5dID8gZG9fcmF3X3NwaW5fdW5sb2NrKzB4YzkvMHgxMTEKWyAgICAwLjAwMDAw
MF0gIFs8ODM0ZjlkYjU+XSA/IHRyYWNlX2hhcmRpcnFzX29mZisweGIvMHhkClsgICAgMC4w
MDAwMDBdICBbPDgzNTA1MTE4Pl0gPyBjb25zb2xlX3VubG9jaysweDQyYS8weDczNwpbICAg
IDAuMDAwMDAwXSAgWzw4NDA2MTNkNT5dID8gX3Jhd19zcGluX3VubG9ja19pcnFyZXN0b3Jl
KzB4NjcvMHg2OQpbICAgIDAuMDAwMDAwXSAgWzw4MzRmOWMzYz5dID8gdHJhY2VfaGFyZGly
cXNfb2ZmX2NhbGxlcisweDYzLzB4YTAKWyAgICAwLjAwMDAwMF0gIFs8ODM0ZjljM2M+XSA/
IHRyYWNlX2hhcmRpcnFzX29mZl9jYWxsZXIrMHg2My8weGEwClsgICAgMC4wMDAwMDBdICBb
PDgzNDk3ZTdmPl0gPyB2bWFsbG9jX3N5bmNfYWxsKzB4MjM2LzB4MjM2ClsgICAgMC4wMDAw
MDBdICBbPDgzNDk3ZWEwPl0gZG9fcGFnZV9mYXVsdCsweDIxLzB4MmIKWyAgICAwLjAwMDAw
MF0gIFs8ODQwNjI4YzI+XSBlcnJvcl9jb2RlKzB4NmEvMHg3MApbICAgIDAuMDAwMDAwXSAg
Wzw4NDA0OWE2Nj5dID8gZG9fdGVzdF93cF9iaXQrMHgxOS8weDIzClsgICAgMC4wMDAwMDBd
ICBbPDg0YjQ5MGQ4Pl0gbWVtX2luaXQrMHgxZGMvMHgyM2QKWyAgICAwLjAwMDAwMF0gIFs8
ODRiMzAwMDA+XSA/IHg4Nl9jcHVfdG9fYXBpY2lkKzB4NzdhLzB4NzdhClsgICAgMC4wMDAw
MDBdICBbPDg0YjMwYjVhPl0gc3RhcnRfa2VybmVsKzB4MWNmLzB4NDdkClsgICAgMC4wMDAw
MDBdICBbPDg0YjMwNjc0Pl0gPyByZXBhaXJfZW52X3N0cmluZysweDk5LzB4OTkKWyAgICAw
LjAwMDAwMF0gIFs8ODRiMzAzYzc+XSBpMzg2X3N0YXJ0X2tlcm5lbCsweDE3NS8weDE3OApb
ICAgIDAuMDAwMDAwXSBDb2RlOiAwNyA4OSA0NSBlYyBjMSBlOCAwOCA4OSBjMyBiOCAzMCBl
OSA4MyA4NCA4MyBlMyAwMSA4OSBkYSBlOCAwZSA3NyAwYyAwMCA4YiAwNCA5ZCA1MCAxMCA4
YSA4NCA0MCA4NSBkYiA4OSAwNCA5ZCA1MCAxMCA4YSA4NCA3NCAxMSA8MGY+IDBiIDhiIDU1
IGYwIDg5IGYwIGU4IDFlIGYxIGZmIGZmIGU5IDAwIGZmIGZmIGZmIDMxIGMwIGY3IDQ1Clsg
ICAgMC4wMDAwMDBdIEVJUDogWzw4MzQ5NzJjOT5dIHNwdXJpb3VzX2ZhdWx0KzB4MTI2LzB4
MjQ0IFNTOkVTUCAwMDY4Ojg0NjQ1ZTVjClsgICAgMC4wMDAwMDBdIC0tLVsgZW5kIHRyYWNl
IDA1ZTBjMDdlYjFjNjYzYTYgXS0tLQpbICAgIDAuMDAwMDAwXSBLZXJuZWwgcGFuaWMgLSBu
b3Qgc3luY2luZzogQXR0ZW1wdGVkIHRvIGtpbGwgdGhlIGlkbGUgdGFzayEKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctZmQzLTA0MTAvY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYz
NTIwN2FhMzgxYy9kbWVzZy1xdWFudGFsLWYyLTg2OjIwMTQwNDEwMDExNTI4OmkzODYtcmFu
ZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDEwMjktZ2NjMTJmMDA6MzcyCi9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2NjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4YmU2MzUy
MDdhYTM4MWMvZG1lc2ctcXVhbnRhbC1sa3AtaWIwNC03MToyMDE0MDQxMDAxMTUyMTppMzg2
LXJhbmRjb25maWctZmQzLTA0MTA6My4xNC4wLTAxMDI5LWdjYzEyZjAwOjM3Mgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9jYzEyZjAwZWMxYTU5NGIwOGRhNDIyYTk2OGJl
NjM1MjA3YWEzODFjL2RtZXNnLXlvY3RvLWxrcC1pYjAzLTk1OjIwMTQwNDEwMDExNTI1Omkz
ODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0LjAtMDEwMjktZ2NjMTJmMDA6MzcyCi9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwL2NjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4
YmU2MzUyMDdhYTM4MWMvZG1lc2ctcXVhbnRhbC1pbm4tMjQ6MjAxNDA0MTAwMTE1MjI6aTM4
Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0
MTAvY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYzNTIwN2FhMzgxYy9kbWVzZy1xdWFu
dGFsLWxrcC1pYjAzLTQ6MjAxNDA0MTAwMTE0MDQ6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEw
OjMuMTQuMC0wMTAyOS1nY2MxMmYwMDozNzIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQz
LTA0MTAvY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYzNTIwN2FhMzgxYy9kbWVzZy1x
dWFudGFsLWYzLTExOToyMDE0MDQxMDAxMTUyMzppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6
My4xNC4wLTAxMDI5LWdjYzEyZjAwOjM3Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMt
MDQxMC9jYzEyZjAwZWMxYTU5NGIwOGRhNDIyYTk2OGJlNjM1MjA3YWEzODFjL2RtZXNnLXF1
YW50YWwtZjItODY6MjAxNDA0MTAwMTE1MTg6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwOjMu
MTQuMC0wMTAyOS1nY2MxMmYwMDozNzIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQzLTA0
MTAvY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYzNTIwN2FhMzgxYy9kbWVzZy1xdWFu
dGFsLWYzLTEyNjoyMDE0MDQxMDAxMTM1NDppMzg2LXJhbmRjb25maWctZmQzLTA0MTA6My4x
NC4wLTAxMDI5LWdjYzEyZjAwOjM3Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MC9jYzEyZjAwZWMxYTU5NGIwOGRhNDIyYTk2OGJlNjM1MjA3YWEzODFjL2RtZXNnLXF1YW50
YWwtZjMtMTI3OjIwMTQwNDEwMDExMzU0OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQxMDozLjE0
LjAtMDEwMjktZ2NjMTJmMDA6MzcyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEw
L2NjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4YmU2MzUyMDdhYTM4MWMvZG1lc2ctcXVhbnRh
bC1icmlja2xhbmQzLTIxOjIwMTQwNDEwMDExNTE5OmkzODYtcmFuZGNvbmZpZy1mZDMtMDQx
MDozLjE0LjAtMDEwMjktZ2NjMTJmMDA6MzcyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZk
My0wNDEwL2NjMTJmMDBlYzFhNTk0YjA4ZGE0MjJhOTY4YmU2MzUyMDdhYTM4MWMvZG1lc2ct
cXVhbnRhbC1mMy0xMjc6MjAxNDA0MTAwMTE1MjE6aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEw
OjMuMTQuMC0wMTAyOS1nY2MxMmYwMDozNzIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctZmQz
LTA0MTAvY2MxMmYwMGVjMWE1OTRiMDhkYTQyMmE5NjhiZTYzNTIwN2FhMzgxYy9kbWVzZy15
b2N0by1sa3AtaWIwMy0xNjoyMDE0MDQxMDAxMTUyNDppMzg2LXJhbmRjb25maWctZmQzLTA0
MTA6My4xNC4wLTAxMDI5LWdjYzEyZjAwOjM3Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1m
ZDMtMDQxMC9jYzEyZjAwZWMxYTU5NGIwOGRhNDIyYTk2OGJlNjM1MjA3YWEzODFjL2RtZXNn
LXlvY3RvLWxrcC1pYjAzLTEwOToyMDE0MDQxMDAxMTUyNTppMzg2LXJhbmRjb25maWctZmQz
LTA0MTA6My4xNC4wLTAxMDI5LWdjYzEyZjAwOjM3MgowOjEzOjEzIGFsbF9nb29kOmJhZDph
bGxfYmFkIGJvb3RzCgpIRUFEIGlzIG5vdyBhdCBjYzEyZjAwIDBkYXkgaGVhZCBndWFyZCBm
b3IgJ2RldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzJwoKPT09PT09PT09IHVwc3RyZWFtID09
PT09PT09PQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyBjYzEyZjAwLi4uIDBkYXkgaGVh
ZCBndWFyZCBmb3IgJ2RldmVsLWY0LWkzODYtMjAxNDA0MTAwMTAzJwpIRUFEIGlzIG5vdyBh
dCAzOWRlNjVhLi4uIE1lcmdlIGJyYW5jaCAnaTJjL2Zvci1uZXh0JyBvZiBnaXQ6Ly9naXQu
a2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvd3NhL2xpbnV4CmxzIC1hIC9r
ZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAvbGlu
dXM6bWFzdGVyOjM5ZGU2NWFhMmMzZWVlOTAxZGIwMjBhNGYxMzk2OTk4ZTA5NjAyYTM6Ymlz
ZWN0LWxpbnV4OAoKMjAxNC0wNC0xMC0wMjoxMDo0MiAzOWRlNjVhYTJjM2VlZTkwMWRiMDIw
YTRmMTM5Njk5OGUwOTYwMmEzIHJldXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWZkMy0w
NDEwLzM5ZGU2NWFhMmMzZWVlOTAxZGIwMjBhNGYxMzk2OTk4ZTA5NjAyYTMvdm1saW51ei0z
LjE0LjAtMTIyMzYtZzM5ZGU2NWEKCjIwMTQtMDQtMTAtMDI6MTA6NDIgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgLi4JNQk0OQk2MCBTVUNDRVNTCgoKPT09PT09PT09IGxpbnV4LW5leHQgPT09
PT09PT09ClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDM5ZGU2NWEuLi4gTWVyZ2UgYnJh
bmNoICdpMmMvZm9yLW5leHQnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGlu
dXgva2VybmVsL2dpdC93c2EvbGludXgKSEVBRCBpcyBub3cgYXQgMzVlMjkzMy4uLiBBZGQg
bGludXgtbmV4dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA0MDkKbHMgLWEgL2tlcm5lbC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC9uZXh0Om1hc3Rl
cjozNWUyOTMzY2E2OWVmMWI4MDYxZTVhZWUwOTA1MzU0MTAzMzZlMDYzOmJpc2VjdC1saW51
eDgKCjIwMTQtMDQtMTAtMDI6MTM6MTUgMzVlMjkzM2NhNjllZjFiODA2MWU1YWVlMDkwNTM1
NDEwMzM2ZTA2MyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tlcm5lbC10ZXN0
cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctZmQzLTA0MTAtMzVlMjkzM2NhNjllZjFi
ODA2MWU1YWVlMDkwNTM1NDEwMzM2ZTA2MwpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLzM1ZTI5MzNjYTY5ZWYxYjgwNjFlNWFlZTA5MDUz
NTQxMDMzNmUwNjMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1
aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1mZDMtMDQxMC0zNWUyOTMzY2E2OWVmMWI4MDYx
ZTVhZWUwOTA1MzU0MTAzMzZlMDYzCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5l
bC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29uZmlnLWZkMy0wNDEwLTM1ZTI5MzNj
YTY5ZWYxYjgwNjFlNWFlZTA5MDUzNTQxMDMzNmUwNjMKa2VybmVsOiAva2VybmVsL2kzODYt
cmFuZGNvbmZpZy1mZDMtMDQxMC8zNWUyOTMzY2E2OWVmMWI4MDYxZTVhZWUwOTA1MzU0MTAz
MzZlMDYzL3ZtbGludXotMy4xNC4wLW5leHQtMjAxNDA0MDkKCjIwMTQtMDQtMTAtMDI6MTc6
MTUgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4JMTEJNDQJNTkJNjAgU1VDQ0VTUwoK

--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-00002-gb1a008d"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.14.0 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_COMPILE_TEST=y
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y
# CONFIG_FHANDLE is not set
CONFIG_AUDIT=y
# CONFIG_AUDITSYSCALL is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_SCHED is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_MODULES is not set
# CONFIG_BLOCK is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
CONFIG_MPENTIUMM=y
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_UP_APIC=y
CONFIG_X86_UP_IOAPIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_VM86 is not set
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_MICROCODE_EARLY is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_2G_OPT=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x78000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_RANDOMIZE_BASE_MAX_OFFSET=0x20000000
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_ACPI=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_POWERNOW_K6 is not set
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
# CONFIG_X86_SPEEDSTEP_ICH is not set
# CONFIG_X86_SPEEDSTEP_SMI is not set
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=y
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_SCx200 is not set
CONFIG_OLPC=y
# CONFIG_OLPC_XO15_SCI is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
# CONFIG_IP_ROUTE_MULTIPATH is not set
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
# CONFIG_IP_PNP_DHCP is not set
# CONFIG_IP_PNP_BOOTP is not set
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
# CONFIG_IPV6 is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
# CONFIG_NF_CONNTRACK_MARK is not set
CONFIG_NF_CONNTRACK_SECMARK=y
# CONFIG_NF_CONNTRACK_EVENTS is not set
CONFIG_NF_CONNTRACK_TIMEOUT=y
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
# CONFIG_NF_CONNTRACK_FTP is not set
CONFIG_NF_CONNTRACK_H323=y
# CONFIG_NF_CONNTRACK_IRC is not set
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
# CONFIG_NF_CONNTRACK_SANE is not set
# CONFIG_NF_CONNTRACK_SIP is not set
# CONFIG_NF_CONNTRACK_TFTP is not set
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_CT_NETLINK_TIMEOUT=y
CONFIG_NF_CT_NETLINK_HELPER=y
CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
CONFIG_NETFILTER_SYNPROXY=y
CONFIG_NF_TABLES=y
# CONFIG_NFT_EXTHDR is not set
CONFIG_NFT_META=y
CONFIG_NFT_CT=y
CONFIG_NFT_RBTREE=y
# CONFIG_NFT_HASH is not set
CONFIG_NFT_COUNTER=y
# CONFIG_NFT_LOG is not set
CONFIG_NFT_LIMIT=y
# CONFIG_NFT_QUEUE is not set
# CONFIG_NFT_REJECT is not set
CONFIG_NFT_COMPAT=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
# CONFIG_NETFILTER_XT_CONNMARK is not set
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
# CONFIG_NETFILTER_XT_TARGET_CT is not set
CONFIG_NETFILTER_XT_TARGET_HMARK=y
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
# CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
CONFIG_NETFILTER_XT_MATCH_CGROUP=y
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set
# CONFIG_NETFILTER_XT_MATCH_CONNMARK is not set
# CONFIG_NETFILTER_XT_MATCH_CONNTRACK is not set
CONFIG_NETFILTER_XT_MATCH_CPU=y
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPCOMP=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
# CONFIG_NETFILTER_XT_MATCH_L2TP is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
# CONFIG_IP_SET_HASH_IPPORT is not set
# CONFIG_IP_SET_HASH_IPPORTIP is not set
# CONFIG_IP_SET_HASH_IPPORTNET is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
# CONFIG_IP_SET_HASH_NET is not set
CONFIG_IP_SET_HASH_NETNET=y
CONFIG_IP_SET_HASH_NETPORT=y
# CONFIG_IP_SET_HASH_NETIFACE is not set
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
# CONFIG_IP_VS_PROTO_UDP is not set
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
# CONFIG_IP_VS_DH is not set
# CONFIG_IP_VS_SH is not set
# CONFIG_IP_VS_SED is not set
# CONFIG_IP_VS_NQ is not set

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
# CONFIG_IP_VS_NFCT is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
# CONFIG_NF_CONNTRACK_IPV4 is not set
CONFIG_NF_TABLES_IPV4=y
# CONFIG_NFT_CHAIN_ROUTE_IPV4 is not set
# CONFIG_NFT_REJECT_IPV4 is not set
CONFIG_NF_TABLES_ARP=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_RPFILTER=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
# CONFIG_IP_NF_TARGET_REJECT is not set
CONFIG_IP_NF_TARGET_SYNPROXY=y
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_IP_NF_MANGLE is not set
CONFIG_IP_NF_RAW=y
# CONFIG_IP_NF_ARPTABLES is not set
# CONFIG_NF_TABLES_BRIDGE is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_L2TP_V3=y
# CONFIG_L2TP_IP is not set
CONFIG_L2TP_ETH=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
CONFIG_BATMAN_ADV_NC=y
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_HSR is not set
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_PID=y
CONFIG_MAC80211_RC_MINSTREL=y
# CONFIG_MAC80211_RC_MINSTREL_HT is not set
CONFIG_MAC80211_RC_DEFAULT_PID=y
# CONFIG_MAC80211_RC_DEFAULT_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT="pid"
CONFIG_MAC80211_MESH=y
# CONFIG_MAC80211_LEDS is not set
CONFIG_MAC80211_DEBUGFS=y
CONFIG_MAC80211_MESSAGE_TRACING=y
# CONFIG_MAC80211_DEBUG_MENU is not set
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_RFKILL_GPIO=y
# CONFIG_NET_9P is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
# CONFIG_CAIF_NETDEV is not set
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_OF_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
# CONFIG_MTD_PHYSMAP_OF is not set
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_PCMCIA is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH is not set
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_CS553X is not set
# CONFIG_MTD_NAND_NANDSIM is not set
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_SH_FLCTL=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_UBI is not set
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_OF_SELFTEST is not set
CONFIG_OF_PROMTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_TI_DAC7512 is not set
CONFIG_VMWARE_BALLOON=y
CONFIG_BMP085=y
# CONFIG_BMP085_I2C is not set
CONFIG_BMP085_SPI=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
# CONFIG_ARCNET_1051 is not set
# CONFIG_ARCNET_RAW is not set
# CONFIG_ARCNET_CAP is not set
# CONFIG_ARCNET_COM90xx is not set
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
# CONFIG_ARCNET_COM20020_PCI is not set
CONFIG_ARCNET_COM20020_CS=y

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
# CONFIG_CAIF_HSI is not set
# CONFIG_CAIF_VIRTIO is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
CONFIG_PCMCIA_NMCLAN=y
# CONFIG_NET_VENDOR_ARC is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
CONFIG_ARM_AT91_ETHER=y
CONFIG_MACB=y
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
CONFIG_PCMCIA_FMVJ18X=y
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
CONFIG_ENC28J60_WRITEVERIFY=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
# CONFIG_SH_ETH is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_NET_VENDOR_XIRCOM is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
# CONFIG_QSEMI_PHY is not set
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
# CONFIG_VITESSE_PHY is not set
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
# CONFIG_NATIONAL_PHY is not set
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
# CONFIG_MICREL_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
CONFIG_MDIO_BUS_MUX_MMIOREG=y
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PPP is not set
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
# CONFIG_USB_NET_CDC_EEM is not set
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SR9700=y
CONFIG_USB_NET_SR9800=y
# CONFIG_USB_NET_SMSC75XX is not set
# CONFIG_USB_NET_SMSC95XX is not set
CONFIG_USB_NET_GL620A=y
# CONFIG_USB_NET_NET1080 is not set
CONFIG_USB_NET_PLUSB=y
# CONFIG_USB_NET_MCS7830 is not set
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
# CONFIG_USB_AN2720 is not set
CONFIG_USB_BELKIN=y
# CONFIG_USB_ARMLINUX is not set
CONFIG_USB_EPSON2888=y
# CONFIG_USB_KC2190 is not set
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_NET_KALMIA=y
CONFIG_USB_NET_QMI_WWAN=y
CONFIG_USB_HSO=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
# CONFIG_USB_SIERRA_NET is not set
CONFIG_USB_VL600=y
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_HDLC is not set
# CONFIG_DLCI is not set
CONFIG_LAPBETHER=y
# CONFIG_X25_ASY is not set
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKEHARD is not set
# CONFIG_IEEE802154_FAKELB is not set
CONFIG_IEEE802154_AT86RF230=y
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_VMXNET3 is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
# CONFIG_CAPI_TRACE is not set
# CONFIG_ISDN_CAPI_CAPI20 is not set

#
# CAPI hardware drivers
#
# CONFIG_CAPI_AVM is not set
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=y
CONFIG_GIGASET_M105=y
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
CONFIG_MISDN=y
# CONFIG_MISDN_DSP is not set
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
# CONFIG_MISDN_HFCMULTI is not set
# CONFIG_MISDN_HFCUSB is not set
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
# CONFIG_MISDN_INFINEON is not set
# CONFIG_MISDN_W6692 is not set
# CONFIG_MISDN_NETJET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_SH_KEYSC=y
# CONFIG_KEYBOARD_STMPE is not set
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_KEYBOARD_CROS_EC=y
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
CONFIG_MOUSE_APPLETOUCH=y
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
CONFIG_MOUSE_SYNAPTICS_USB=y
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
# CONFIG_TABLET_USB_AIPTEK is not set
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
# CONFIG_TABLET_USB_WACOM is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
# CONFIG_INPUT_88PM80X_ONKEY is not set
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
CONFIG_INPUT_AD714X_SPI=y
CONFIG_INPUT_BMA150=y
CONFIG_INPUT_MAX8925_ONKEY=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
CONFIG_INPUT_GPIO_TILT_POLLED=y
CONFIG_INPUT_WISTRON_BTNS=y
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_CM109=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=y
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF50633_PMU=y
CONFIG_INPUT_PCF8574=y
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
CONFIG_INPUT_PCAP=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
# CONFIG_SERIO_OLPC_APSP is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CLPS711X=y
CONFIG_SERIAL_CLPS711X_CONSOLE=y
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_OF_PLATFORM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
CONFIG_SERIAL_IFX6X60=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
# CONFIG_SERIAL_XILINX_PS_UART_CONSOLE is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_ST_ASC=y
CONFIG_SERIAL_ST_ASC_CONSOLE=y
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_RIIC is not set
CONFIG_I2C_SH_MOBILE=y
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y
CONFIG_I2C_RCAR=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_ATMEL is not set
# CONFIG_SPI_BCM2835 is not set
CONFIG_SPI_BCM63XX_HSSPI=y
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_EP93XX is not set
CONFIG_SPI_GPIO=y
# CONFIG_SPI_IMX is not set
CONFIG_SPI_FSL_LIB=y
CONFIG_SPI_FSL_SPI=y
CONFIG_SPI_FSL_DSPI=y
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_TI_QSPI=y
CONFIG_SPI_OMAP_100K=y
CONFIG_SPI_ORION=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_SH=y
CONFIG_SPI_SH_HSPI=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
# CONFIG_SPI_TXX9 is not set
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_CLPS711X=y
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_GRGPIO=y

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_SX150X=y
# CONFIG_GPIO_STMPE is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y
CONFIG_GPIO_ADP5520=y
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_ADNP=y

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_SODAVILLE is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MCP23S08=y
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_74X164=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
# CONFIG_GPIO_KEMPLD is not set

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set
# CONFIG_GPIO_TPS65910 is not set
# CONFIG_GPIO_BCM_KONA is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_OLPC=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=y
# CONFIG_CHARGER_88PM860X is not set
CONFIG_CHARGER_PCF50633=y
# CONFIG_BATTERY_RX51 is not set
# CONFIG_CHARGER_ISP1704 is not set
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_MAX8997=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65090=y
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
# CONFIG_HWMON is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_RCAR_THERMAL=y
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
# CONFIG_MFD_CROS_EC_SPI is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_EZX_PCAP=y
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
CONFIG_STMPE_SPI=y
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_TWL4030_MADC=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
# CONFIG_REGULATOR_FIXED_VOLTAGE is not set
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65090 is not set
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_TPS6586X=y
# CONFIG_REGULATOR_TPS65910 is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_NET is not set
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
CONFIG_RC_DECODERS=y
CONFIG_LIRC=y
CONFIG_IR_LIRC_CODEC=y
# CONFIG_IR_NEC_DECODER is not set
CONFIG_IR_RC5_DECODER=y
# CONFIG_IR_RC6_DECODER is not set
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
# CONFIG_IR_RC5_SZ_DECODER is not set
CONFIG_IR_SANYO_DECODER=y
CONFIG_IR_MCE_KBD_DECODER=y
# CONFIG_RC_DEVICES is not set
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set
# CONFIG_RADIO_ADAPTERS is not set
# CONFIG_CYPRESS_FIRMWARE is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_VIDEO_IR_I2C=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SM501=y
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_LP8788=y
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_FB_SSD1307 is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
CONFIG_HID_APPLEIR=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
CONFIG_HID_HUION=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FUSBH200_HCD is not set
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_RENESAS_USBHS_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y
CONFIG_USB_RENESAS_USBHS=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
# CONFIG_USB_DWC3_OMAP is not set
# CONFIG_USB_DWC3_EXYNOS is not set
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_KEYSTONE=y

#
# Debugging features
#
# CONFIG_USB_DWC3_DEBUG is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
CONFIG_USB_SERIAL_ARK3116=y
# CONFIG_USB_SERIAL_BELKIN is not set
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
# CONFIG_USB_SERIAL_VISOR is not set
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
# CONFIG_USB_SERIAL_MOS7720 is not set
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MXUPORT=y
CONFIG_USB_SERIAL_NAVMAN=y
CONFIG_USB_SERIAL_PL2303=y
# CONFIG_USB_SERIAL_OTI6858 is not set
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
# CONFIG_USB_SERIAL_SAFE is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
# CONFIG_USB_SERIAL_XSENS_MT is not set
CONFIG_USB_SERIAL_WISHBONE=y
CONFIG_USB_SERIAL_ZTE=y
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_QT2 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HSIC_USB3503=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_OTG_FSM=y
CONFIG_KEYSTONE_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_OMAP_CONTROL_USB is not set
# CONFIG_OMAP_USB3 is not set
# CONFIG_AM335X_PHY_USB is not set
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_USB_ISP1301=y
# CONFIG_USB_RCAR_PHY is not set
CONFIG_USB_RCAR_GEN2_PHY=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
# CONFIG_USB_GADGET_VERBOSE is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FUSB300 is not set
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
CONFIG_USB_RENESAS_USBHS_UDC=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_U_ETHER=y
CONFIG_USB_F_NCM=y
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
CONFIG_USB_G_NCM=y
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_OMAP_HS=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SPI is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
# CONFIG_MMC_USHC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8788 is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_PCA9685=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_MAX8997 is not set
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8997=y
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_TWL4030 is not set
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_TPS65910=y
# CONFIG_RTC_DRV_RC5T583 is not set
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_RX4581 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_WM831X is not set
# CONFIG_RTC_DRV_WM8350 is not set
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_SNVS=y
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
CONFIG_RTC_DRV_HID_SENSOR_TIME=y
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_TIMB_DMA=y
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO1_RFKILL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_OF_EXTCON=y
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX8997=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7298=y
CONFIG_AD7476=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
CONFIG_EXYNOS_ADC=y
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1363=y
CONFIG_MCP320X=y
# CONFIG_MCP3422 is not set
# CONFIG_NAU7802 is not set
# CONFIG_TI_ADC081C is not set
CONFIG_TI_AM335X_ADC=y
CONFIG_TWL6030_GPADC=y

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
CONFIG_AD5449=y
CONFIG_AD5504=y
CONFIG_AD5624R_SPI=y
CONFIG_AD5686=y
CONFIG_AD5755=y
# CONFIG_AD5764 is not set
CONFIG_AD5791=y
# CONFIG_AD7303 is not set
CONFIG_MAX517=y
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
# CONFIG_ADIS16260 is not set
# CONFIG_ADXRS450 is not set
CONFIG_HID_SENSOR_GYRO_3D=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Humidity sensors
#
# CONFIG_DHT11 is not set

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
CONFIG_ADIS16480=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_APDS9300=y
# CONFIG_CM32181 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_HID_SENSOR_ALS=y
# CONFIG_SENSORS_LM3533 is not set
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
CONFIG_MPL3115=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y

#
# Temperature sensors
#
# CONFIG_TMP006 is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IRQCHIP=y
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
# CONFIG_PHY_EXYNOS_DP_VIDEO is not set
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ECRYPT_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
# CONFIG_JFFS2_FS_POSIX_ACL is not set
CONFIG_JFFS2_FS_SECURITY=y
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
# CONFIG_JFFS2_ZLIB is not set
# CONFIG_JFFS2_LZO is not set
# CONFIG_JFFS2_RTIME is not set
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
# CONFIG_JFFS2_CMODE_PRIORITY is not set
# CONFIG_JFFS2_CMODE_SIZE is not set
CONFIG_JFFS2_CMODE_FAVOURLZO=y
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_CEPH_FS=y
CONFIG_CEPH_FS_POSIX_ACL=y
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MMC_REQUEST=y
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
# CONFIG_FUNCTION_PROFILER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
# CONFIG_CRYPTO_NULL is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
# CONFIG_LGUEST is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_AUDIT_GENERIC=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y

--v9Ux+11Zm5mwPlX6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
