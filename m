Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 805376B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 03:03:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so8397227wml.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:03:24 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j73si1096243wmj.93.2016.08.12.00.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 00:03:20 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id i138so1189657wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:03:19 -0700 (PDT)
Received: from xps.localnet ([91.234.176.247])
        by smtp.gmail.com with ESMTPSA id wc3sm6064717wjc.47.2016.08.12.00.03.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Aug 2016 00:03:16 -0700 (PDT)
From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Subject: 4.7.0, cp -al causes OOM
Date: Fri, 12 Aug 2016 09:01:41 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201608120901.41463.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-ext4@vger.kernel.org
Cc: linux-mm@vger.kernel.org


Hello.

I have a system with 4x2TB SATA disks, split into few partitions. Celeron G=
530,
8GB of ram, 20GB of swap. It's just basic system (so syslog,
cron, udevd, irqbalance) + my cp tests and nothing more. kernel 4.7.0

There is software raid 5 partition on sd[abcd]4 and ext4 created with -T ne=
ws
option.

Using deadline I/O scheduler.

=46or testing I have 400GB of tiny files on it (about 6.4mln inodes) in myd=
ir.
I did "cp -al mydir copy{1,2,...,10}" 10x in parallel and that ended up
with 5 of cp being killed by OOM while other 5x finished.

Even two in parallel seem to be enough for OOM to kick in:
rm -rf copy1; cp -al mydir copy1
rm -rf copy2; cp -al mydir copy2

I would expect 8GB of ram to be enough for just rm/cp. Ideas?

Note that I first tested the same thing with xfs (hence you can see " task =
xfsaild/md2:661 blocked
for more than 120 seconds." and xfs related stacktraces in dmesg) and 10x c=
p managed to finish
without OOM. Later I did test with ext4 which caused OOMs. I guess it is pr=
obably not some generic
memory management problem but that's only my guess.

dmesg:
[    0.000000] Linux version 4.7.0-1 (builder@ymir-builder) (gcc version 5.=
4.0 20160603 (release) (PLD-Linux) ) #1 SMP Sun Jul 31 22:37:26 CEST 2016
[    0.000000] Command line: BOOT_IMAGE=3D/boot/vmlinuz-4.7.0-1 root=3D/dev=
/md1 ro panic=3D300
[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point=
 registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.000000] x86/fpu: Enabled xstate features 0x3, context size is 576 by=
tes, using 'standard' format.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009dbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000dafcffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000dafd0000-0x00000000dafd2fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000dafd3000-0x00000000dafeffff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000daff0000-0x00000000daffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000f4000000-0x00000000f7ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000021fdfffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H61M-S2V-B3, =
BIOS F4 05/25/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x21fe00 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CCFFF write-protect
[    0.000000]   CD000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-through
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   2 base 0DC000000 mask FFC000000 uncachable
[    0.000000]   3 base 0DB800000 mask FFF800000 uncachable
[    0.000000]   4 base 100000000 mask F00000000 write-back
[    0.000000]   5 base 200000000 mask FE0000000 write-back
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT=
 =20
[    0.000000] e820: update [mem 0xdb800000-0xffffffff] usable =3D=3D> rese=
rved
[    0.000000] e820: last_pfn =3D 0xdafd0 max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f57e0-0x000f57ef] mapped at =
[ffff8800000f57e0]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
[    0.000000] reserving inaccessible SNB gfx pages
[    0.000000] BRK [0x01fa5000, 0x01fa5fff] PGTABLE
[    0.000000] BRK [0x01fa6000, 0x01fa6fff] PGTABLE
[    0.000000] BRK [0x01fa7000, 0x01fa7fff] PGTABLE
[    0.000000] BRK [0x01fa8000, 0x01fa8fff] PGTABLE
[    0.000000] BRK [0x01fa9000, 0x01fa9fff] PGTABLE
[    0.000000] BRK [0x01faa000, 0x01faafff] PGTABLE
[    0.000000] RAMDISK: [mem 0x37b8d000-0x37dbdfff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6F30 000014 (v00 GBT   )
[    0.000000] ACPI: RSDT 0x00000000DAFD3040 000048 (v01 GBT    GBTUACPI 42=
302E31 GBTU 01010101)
[    0.000000] ACPI: FACP 0x00000000DAFD3100 000074 (v01 GBT    GBTUACPI 42=
302E31 GBTU 01010101)
[    0.000000] ACPI: DSDT 0x00000000DAFD31C0 0049C2 (v01 GBT    GBTUACPI 00=
001000 MSFT 04000000)
[    0.000000] ACPI: FACS 0x00000000DAFD0000 000040
[    0.000000] ACPI: HPET 0x00000000DAFD7D00 000038 (v01 GBT    GBTUACPI 42=
302E31 GBTU 00000098)
[    0.000000] ACPI: MCFG 0x00000000DAFD7D80 00003C (v01 GBT    GBTUACPI 42=
302E31 GBTU 01010101)
[    0.000000] ACPI: ASPT 0x00000000DAFD7E00 000034 (v07 GBT    PerfTune 31=
2E3042 UTBG 01010101)
[    0.000000] ACPI: SSPT 0x00000000DAFD7E40 0022EC (v01 GBT    SsptHead 31=
2E3042 UTBG 01010101)
[    0.000000] ACPI: EUDS 0x00000000DAFDA130 0000C0 (v01 GBT             00=
000000      00000000)
[    0.000000] ACPI: TAMG 0x00000000DAFDA1F0 000442 (v01 GBT    GBT   B0 54=
55312E BG?? 45240101)
[    0.000000] ACPI: APIC 0x00000000DAFD7C00 0000BC (v01 GBT    GBTUACPI 42=
302E31 GBTU 01010101)
[    0.000000] ACPI: SSDT 0x00000000DAFDA640 000D24 (v01 INTEL  PPM RCM  80=
000001 INTL 20061109)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000021fdfffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x21fdf6000-0x21fdf9fff]
[    0.000000] cma: Reserved 16 MiB at 0x000000021ec00000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000021fdfffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009cfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000dafcffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000021fdfffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000021fdff=
fff]
[    0.000000] On node 0 totalpages: 2076012
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 156 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 13952 pages used for memmap
[    0.000000]   DMA32 zone: 892880 pages, LIFO batch:31
[    0.000000]   Normal zone: 18424 pages used for memmap
[    0.000000]   Normal zone: 1179136 pages, LIFO batch:31
[    0.000000] Reserving Intel graphics stolen memory at 0xdba00000-0xdf9ff=
fff
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 6 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xdafd0000-0xdafd2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdafd3000-0xdafeffff]
[    0.000000] PM: Registered nosave memory: [mem 0xdaff0000-0xdaffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xdb000000-0xdb9fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xdba00000-0xdf9fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xdfa00000-0xf3ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf4000000-0xf7ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xffffffff]
[    0.000000] e820: [mem 0xdfa00000-0xf3ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:8 n=
r_node_ids:1
[    0.000000] percpu: Embedded 33 pages/cpu @ffff88021ea00000 s98072 r8192=
 d28904 u262144
[    0.000000] pcpu-alloc: s98072 r8192 d28904 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7=20
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 2043416
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-4.7.0-1 root=
=3D/dev/md1 ro panic=3D300
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 8070264K/8304048K available (6535K kernel code, 973K=
 rwdata, 2576K rodata, 1344K init, 1376K bss, 217400K reserved, 16384K cma-=
reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D8, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000]  RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D8.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=
=3D8
[    0.000000] NR_IRQS:33024 nr_irqs:488 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2394.649 MHz processor
[    0.000028] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 4791.85 BogoMIPS (lpj=3D7982163)
[    0.000108] pid_max: default: 32768 minimum: 301
[    0.000151] ACPI: Core revision 20160422
[    0.002622] ACPI: 2 ACPI AML tables successfully acquired and loaded

[    0.002736] Security Framework initialized
[    0.002783] Yama: becoming mindful.
[    0.002824] AppArmor: AppArmor disabled by boot time parameter
[    0.003342] Dentry cache hash table entries: 1048576 (order: 11, 8388608=
 bytes)
[    0.005035] Inode-cache hash table entries: 524288 (order: 10, 4194304 b=
ytes)
[    0.005809] Mount-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.005862] Mountpoint-cache hash table entries: 16384 (order: 5, 131072=
 bytes)
[    0.006171] CPU: Physical Processor ID: 0
[    0.006209] CPU: Processor Core ID: 0
[    0.006249] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.006290] ENERGY_PERF_BIAS: View and update with x86_energy_perf_polic=
y(8)
[    0.006333] mce: CPU supports 7 MCE banks
[    0.006377] CPU0: Thermal monitoring enabled (TM1)
[    0.006424] process: using mwait in idle threads
[    0.006464] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[    0.006504] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.006972] Freeing SMP alternatives memory: 24K (ffffffff81e45000 - fff=
fffff81e4b000)
[    0.009060] ftrace: allocating 26534 entries in 104 pages
[    0.022297] smpboot: Max logical packages: 4
[    0.022340] smpboot: APIC(0) Converting physical 0 to logical package 0
[    0.022788] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
=2D1
[    0.055834] TSC deadline timer enabled
[    0.055837] smpboot: CPU0: Intel(R) Celeron(R) CPU G530 @ 2.40GHz (famil=
y: 0x6, model: 0x2a, stepping: 0x7)
[    0.055954] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge eve=
nts, full-width counters, Intel PMU driver.
[    0.056130] core: PEBS disabled due to CPU errata, please upgrade microc=
ode
[    0.056174] ... version:                3
[    0.056211] ... bit width:              48
[    0.056248] ... generic registers:      8
[    0.056285] ... value mask:             0000ffffffffffff
[    0.056324] ... max period:             0000ffffffffffff
[    0.056363] ... fixed-purpose events:   3
[    0.056401] ... event mask:             00000007000000ff
[    0.056751] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.056907] x86: Booting SMP configuration:
[    0.056945] .... node  #0, CPUs:      #1
[    0.141256] x86: Booted up 1 node, 2 CPUs
[    0.141328] ----------------
[    0.141363] | NMI testsuite:
[    0.141398] --------------------
[    0.141434]   remote IPI:  ok  |
[    0.149269]    local IPI:  ok  |
[    0.169212] --------------------
[    0.169263] Good, all   2 testcases passed! |
[    0.169301] ---------------------------------
[    0.169340] smpboot: Total of 2 processors activated (9583.70 BogoMIPS)
[    0.170676] devtmpfs: initialized
[    0.170779] x86/mm: Memory block size: 128MB
[    0.174609] evm: security.selinux
[    0.174646] evm: security.SMACK64
[    0.174682] evm: security.SMACK64EXEC
[    0.174719] evm: security.SMACK64TRANSMUTE
[    0.174757] evm: security.SMACK64MMAP
[    0.174794] evm: security.capability
[    0.174870] PM: Registering ACPI NVS region [mem 0xdafd0000-0xdafd2fff] =
(12288 bytes)
[    0.174972] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 6370867519511994 ns
[    0.175099] prandom: seed boundary self test passed
[    0.175661] prandom: 100 self tests passed
[    0.176400] pinctrl core: initialized pinctrl subsystem
[    0.176622] NET: Registered protocol family 16
[    0.184590] cpuidle: using governor ladder
[    0.197927] cpuidle: using governor menu
[    0.197980] PCCT header not found.
[    0.198033] ACPI: bus type PCI registered
[    0.198071] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.198166] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf4000000=
=2D0xf7ffffff] (base 0xf4000000)
[    0.198225] PCI: MMCONFIG at [mem 0xf4000000-0xf7ffffff] reserved in E820
[    0.198272] pmd_set_huge: Cannot satisfy [mem 0xf4000000-0xf4200000] wit=
h a huge-page mapping due to MTRR override.
[    0.198411] PCI: Using configuration type 1 for base access
[    0.198633] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.198646] core: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT=
 off
[    0.211412] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.211634] ACPI: Added _OSI(Module Device)
[    0.211672] ACPI: Added _OSI(Processor Device)
[    0.211710] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.211749] ACPI: Added _OSI(Processor Aggregator Device)
[    0.214528] ACPI: Interpreter enabled
[    0.214580] ACPI: (supports S0 S3 S4 S5)
[    0.214618] ACPI: Using IOAPIC for interrupt routing
[    0.214675] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.218200] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3f])
[    0.218245] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    0.218303] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.218530] PCI host bridge to bus 0000:00
[    0.218569] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.218612] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.218654] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.218708] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dfff=
f window]
[    0.218763] pci_bus 0000:00: root bus resource [mem 0xdfa00000-0xfebffff=
f window]
[    0.218818] pci_bus 0000:00: root bus resource [bus 00-3f]
[    0.218864] pci 0000:00:00.0: [8086:0100] type 00 class 0x060000
[    0.218950] pci 0000:00:02.0: [8086:0102] type 00 class 0x030000
[    0.218960] pci 0000:00:02.0: reg 0x10: [mem 0xfb800000-0xfbbfffff 64bit]
[    0.218966] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64bit=
 pref]
[    0.218971] pci 0000:00:02.0: reg 0x20: [io  0xff00-0xff3f]
[    0.219073] pci 0000:00:16.0: [8086:1c3a] type 00 class 0x078000
[    0.219093] pci 0000:00:16.0: reg 0x10: [mem 0xfbfff000-0xfbfff00f 64bit]
[    0.219168] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.219250] pci 0000:00:1a.0: [8086:1c2d] type 00 class 0x0c0320
[    0.219268] pci 0000:00:1a.0: reg 0x10: [mem 0xfbffe000-0xfbffe3ff]
[    0.219354] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.219394] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.219472] pci 0000:00:1b.0: [8086:1c20] type 00 class 0x040300
[    0.219488] pci 0000:00:1b.0: reg 0x10: [mem 0xfbff4000-0xfbff7fff 64bit]
[    0.219562] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.219603] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    0.219680] pci 0000:00:1c.0: [8086:1c10] type 01 class 0x060400
[    0.219751] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.219792] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.219870] pci 0000:00:1c.4: [8086:1c18] type 01 class 0x060400
[    0.219947] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.219988] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    0.220067] pci 0000:00:1d.0: [8086:1c26] type 00 class 0x0c0320
[    0.220085] pci 0000:00:1d.0: reg 0x10: [mem 0xfbffd000-0xfbffd3ff]
[    0.220170] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.220208] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.220280] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.220361] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.220436] pci 0000:00:1f.0: [8086:1c5c] type 00 class 0x060100
[    0.220602] pci 0000:00:1f.2: [8086:1c02] type 00 class 0x010601
[    0.220617] pci 0000:00:1f.2: reg 0x10: [io  0xfe00-0xfe07]
[    0.220624] pci 0000:00:1f.2: reg 0x14: [io  0xfd00-0xfd03]
[    0.220632] pci 0000:00:1f.2: reg 0x18: [io  0xfc00-0xfc07]
[    0.220639] pci 0000:00:1f.2: reg 0x1c: [io  0xfb00-0xfb03]
[    0.220647] pci 0000:00:1f.2: reg 0x20: [io  0xfa00-0xfa1f]
[    0.220654] pci 0000:00:1f.2: reg 0x24: [mem 0xfbffc000-0xfbffc7ff]
[    0.220695] pci 0000:00:1f.2: PME# supported from D3hot
[    0.220761] pci 0000:00:1f.3: [8086:1c22] type 00 class 0x0c0500
[    0.220776] pci 0000:00:1f.3: reg 0x10: [mem 0xfbffb000-0xfbffb0ff 64bit]
[    0.220797] pci 0000:00:1f.3: reg 0x20: [io  0x0500-0x051f]
[    0.220914] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.221020] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
[    0.221043] pci 0000:02:00.0: reg 0x10: [io  0xee00-0xeeff]
[    0.221078] pci 0000:02:00.0: reg 0x18: [mem 0xfbeff000-0xfbefffff 64bit=
 pref]
[    0.221100] pci 0000:02:00.0: reg 0x20: [mem 0xfbef8000-0xfbefbfff 64bit=
 pref]
[    0.221210] pci 0000:02:00.0: supports D1 D2
[    0.221212] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.225938] pci 0000:00:1c.4: PCI bridge to [bus 02]
[    0.225993] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
[    0.226001] pci 0000:00:1c.4:   bridge window [mem 0xfbe00000-0xfbefffff=
 64bit pref]
[    0.226068] pci 0000:00:1e.0: PCI bridge to [bus 03] (subtractive decode)
[    0.226119] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7 window]=
 (subtractive decode)
[    0.226120] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff window]=
 (subtractive decode)
[    0.226122] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff=
 window] (subtractive decode)
[    0.226124] pci 0000:00:1e.0:   bridge window [mem 0x000c0000-0x000dffff=
 window] (subtractive decode)
[    0.226125] pci 0000:00:1e.0:   bridge window [mem 0xdfa00000-0xfebfffff=
 window] (subtractive decode)
[    0.226634] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 *10 11 12 =
14 15)
[    0.226978] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    0.227360] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10 11 12 =
14 15)
[    0.227702] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.228042] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    0.228423] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    0.228805] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 10 11 *12 =
14 15)
[    0.229146] ACPI: PCI Interrupt Link [LNK1] (IRQs *3 4 5 6 7 9 10 11 12 =
14 15)
[    0.229539] ACPI: Enabled 1 GPEs in block 00 to 3F
[    0.229693] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.229734] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.229791] vgaarb: loaded
[    0.229826] vgaarb: bridge control possible 0000:00:02.0
[    0.229984] PCI: Using ACPI for IRQ routing
[    0.231581] PCI: pci_cache_line_size set to 64 bytes
[    0.231614] e820: reserve RAM buffer [mem 0x0009dc00-0x0009ffff]
[    0.231616] e820: reserve RAM buffer [mem 0xdafd0000-0xdbffffff]
[    0.231618] e820: reserve RAM buffer [mem 0x21fe00000-0x21fffffff]
[    0.231713] NetLabel: Initializing
[    0.231750] NetLabel:  domain hash size =3D 128
[    0.231787] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    0.231837] NetLabel:  unlabeled traffic allowed by default
[    0.231918] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.232132] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.234184] amd_nb: Cannot enumerate AMD northbridges
[    0.234231] clocksource: Switched to clocksource hpet
[    0.239457] VFS: Disk quotas dquot_6.6.0
[    0.239516] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    0.239635] pnp: PnP ACPI init
[    0.239813] system 00:00: [io  0x04d0-0x04d1] has been reserved
[    0.239855] system 00:00: [io  0x0290-0x029f] has been reserved
[    0.239896] system 00:00: [io  0x0800-0x087f] has been reserved
[    0.239937] system 00:00: [io  0x0290-0x0294] has been reserved
[    0.239978] system 00:00: [io  0x0880-0x088f] has been reserved
[    0.240021] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.240083] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.240320] pnp 00:02: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.240493] pnp 00:03: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.240577] pnp 00:04: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.240622] system 00:05: [io  0x0400-0x04cf] has been reserved
[    0.240664] system 00:05: [io  0x04d2-0x04ff] has been reserved
[    0.240706] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.240736] system 00:06: [io  0x1000-0x107f] has been reserved
[    0.240777] system 00:06: [io  0x1080-0x10ff] has been reserved
[    0.240818] system 00:06: [io  0x1100-0x117f] has been reserved
[    0.240859] system 00:06: [io  0x1180-0x11ff] has been reserved
[    0.240914] system 00:06: Plug and Play ACPI device, IDs ICD0001 PNP0c02=
 (active)
[    0.241069] system 00:07: [io  0x0454-0x0457] has been reserved
[    0.241112] system 00:07: Plug and Play ACPI device, IDs INT3f0d PNP0c02=
 (active)
[    0.241146] system 00:08: [mem 0xf4000000-0xf7ffffff] has been reserved
[    0.241189] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.241355] system 00:09: [mem 0x000d2000-0x000d3fff] has been reserved
[    0.241398] system 00:09: [mem 0x000f0000-0x000f7fff] could not be reser=
ved
[    0.241440] system 00:09: [mem 0x000f8000-0x000fbfff] could not be reser=
ved
[    0.241483] system 00:09: [mem 0x000fc000-0x000fffff] could not be reser=
ved
[    0.241526] system 00:09: [mem 0xdafd0000-0xdafdffff] could not be reser=
ved
[    0.241569] system 00:09: [mem 0x00000000-0x0009ffff] could not be reser=
ved
[    0.241611] system 00:09: [mem 0x00100000-0xdafcffff] could not be reser=
ved
[    0.241654] system 00:09: [mem 0xdafe0000-0xdafeffff] could not be reser=
ved
[    0.241697] system 00:09: [mem 0xfec00000-0xfec00fff] could not be reser=
ved
[    0.241740] system 00:09: [mem 0xfed10000-0xfed1dfff] has been reserved
[    0.241782] system 00:09: [mem 0xfed20000-0xfed8ffff] has been reserved
[    0.241824] system 00:09: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.241866] system 00:09: [mem 0xffb00000-0xffb7ffff] has been reserved
[    0.241909] system 00:09: [mem 0xfff00000-0xffffffff] has been reserved
[    0.241951] system 00:09: [mem 0x000e0000-0x000effff] has been reserved
[    0.241994] system 00:09: [mem 0x20000000-0x201fffff] could not be reser=
ved
[    0.242037] system 00:09: [mem 0x40000000-0x400fffff] could not be reser=
ved
[    0.242080] system 00:09: [mem 0xdb000000-0xdf9fffff] could not be reser=
ved
[    0.242123] system 00:09: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.242129] pnp: PnP ACPI: found 10 devices
[    0.248212] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, m=
ax_idle_ns: 2085701024 ns
[    0.248283] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus =
01] add_size 1000
[    0.248286] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 6=
4bit pref] to [bus 01] add_size 200000 add_align 100000
[    0.248289] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff] =
to [bus 01] add_size 200000 add_align 100000
[    0.248305] pci 0000:00:1c.0: res[14]=3D[mem 0x00100000-0x000fffff] res_=
to_dev_res add_size 200000 min_align 100000
[    0.248307] pci 0000:00:1c.0: res[14]=3D[mem 0x00100000-0x002fffff] res_=
to_dev_res add_size 200000 min_align 100000
[    0.248309] pci 0000:00:1c.0: res[15]=3D[mem 0x00100000-0x000fffff 64bit=
 pref] res_to_dev_res add_size 200000 min_align 100000
[    0.248311] pci 0000:00:1c.0: res[15]=3D[mem 0x00100000-0x002fffff 64bit=
 pref] res_to_dev_res add_size 200000 min_align 100000
[    0.248313] pci 0000:00:1c.0: res[13]=3D[io  0x1000-0x0fff] res_to_dev_r=
es add_size 1000 min_align 1000
[    0.248315] pci 0000:00:1c.0: res[13]=3D[io  0x1000-0x1fff] res_to_dev_r=
es add_size 1000 min_align 1000
[    0.248320] pci 0000:00:1c.0: BAR 14: assigned [mem 0xdfa00000-0xdfbffff=
f]
[    0.248365] pci 0000:00:1c.0: BAR 15: assigned [mem 0xdfc00000-0xdfdffff=
f 64bit pref]
[    0.248421] pci 0000:00:1c.0: BAR 13: assigned [io  0x2000-0x2fff]
[    0.248463] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.248504] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
[    0.248549] pci 0000:00:1c.0:   bridge window [mem 0xdfa00000-0xdfbfffff]
[    0.248593] pci 0000:00:1c.0:   bridge window [mem 0xdfc00000-0xdfdfffff=
 64bit pref]
[    0.248653] pci 0000:00:1c.4: PCI bridge to [bus 02]
[    0.248693] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
[    0.248739] pci 0000:00:1c.4:   bridge window [mem 0xfbe00000-0xfbefffff=
 64bit pref]
[    0.248799] pci 0000:00:1e.0: PCI bridge to [bus 03]
[    0.248848] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.248849] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.248851] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    0.248853] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000dffff windo=
w]
[    0.248854] pci_bus 0000:00: resource 8 [mem 0xdfa00000-0xfebfffff windo=
w]
[    0.248856] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    0.248858] pci_bus 0000:01: resource 1 [mem 0xdfa00000-0xdfbfffff]
[    0.248859] pci_bus 0000:01: resource 2 [mem 0xdfc00000-0xdfdfffff 64bit=
 pref]
[    0.248861] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
[    0.248862] pci_bus 0000:02: resource 2 [mem 0xfbe00000-0xfbefffff 64bit=
 pref]
[    0.248864] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7 window]
[    0.248866] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff window]
[    0.248867] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    0.248869] pci_bus 0000:03: resource 7 [mem 0x000c0000-0x000dffff windo=
w]
[    0.248871] pci_bus 0000:03: resource 8 [mem 0xdfa00000-0xfebfffff windo=
w]
[    0.248897] NET: Registered protocol family 2
[    0.249103] TCP established hash table entries: 65536 (order: 7, 524288 =
bytes)
[    0.249289] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.249473] TCP: Hash tables configured (established 65536 bind 65536)
[    0.249549] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.249619] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.249733] NET: Registered protocol family 1
[    0.249796] pci 0000:00:02.0: BIOS left Intel GPU interrupts enabled; di=
sabling
[    0.249866] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x0=
00c0000-0x000dffff]
[    0.274330] PCI: CLS 4 bytes, default 64
[    0.274379] Trying to unpack rootfs image as initramfs...
[    0.521391] Freeing initrd memory: 2244K (ffff880037b8d000 - ffff880037d=
be000)
[    0.521451] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.521494] software IO TLB [mem 0xd6fd0000-0xdafd0000] (64MB) mapped at=
 [ffff8800d6fd0000-ffff8800dafcffff]
[    0.521634] Scanning for low memory corruption every 60 seconds
[    0.521963] futex hash table entries: 2048 (order: 5, 131072 bytes)
[    0.522031] audit: initializing netlink subsys (disabled)
[    0.522085] audit: type=3D2000 audit(1470753990.513:1): initialized
[    0.522388] Initialise system trusted keyrings
[    0.522503] workingset: timestamp_bits=3D38 max_order=3D21 bucket_order=
=3D0
[    0.524323] romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
[    0.524433] Key type big_key registered
[    0.524695] Key type asymmetric registered
[    0.524734] Asymmetric key parser 'x509' registered
[    0.524805] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 248)
[    0.524879] io scheduler noop registered
[    0.524917] io scheduler deadline registered
[    0.524982] io scheduler cfq registered (default)
[    0.525094] pcieport 0000:00:1c.0: enabling device (0000 -> 0003)
[    0.525382] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.525427] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.525510] intel_idle: MWAIT substates: 0x1120
[    0.525511] intel_idle: v0.4.1 model 0x2A
[    0.525579] intel_idle: lapic_timer_reliable_states 0xffffffff
[    0.525861] GHES: HEST is not enabled!
[    0.534232] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.554918] 00:02: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    0.555452] Linux agpgart interface v0.103
[    0.557938] brd: module loaded
[    0.558026] libphy: Fixed MDIO Bus: probed
[    0.558091] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    0.558133] i8042: PNP: PS/2 appears to have AUX port disabled, if this =
is incorrect please boot with i8042.nopnp
[    0.558321] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.558444] mousedev: PS/2 mouse device common for all mice
[    0.558521] rtc_cmos 00:01: RTC can wake from S4
[    0.559373] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    0.559437] rtc_cmos 00:01: alarms up to one month, 242 bytes nvram, hpe=
t irqs
[    0.559502] intel_pstate: Intel P-state driver initializing
[    0.559611] ledtrig-cpu: registered to indicate activity on CPUs
[    0.559888] drop_monitor: Initializing network drop monitor service
[    0.560231] NET: Registered protocol family 10
[    0.560507] mip6: Mobile IPv6
[    0.560550] NET: Registered protocol family 17
[    0.560769] microcode: CPU0 sig=3D0x206a7, pf=3D0x2, revision=3D0x14
[    0.560825] microcode: CPU1 sig=3D0x206a7, pf=3D0x2, revision=3D0x14
[    0.560934] microcode: Microcode Update Driver: v2.01 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    0.561158] registered taskstats version 1
[    0.561586] Loading compiled-in X.509 certificates
[    0.561723] zswap: default zpool zbud not available
[    0.561769] zswap: pool creation failed
[    0.562139] Key type encrypted registered
[    0.562184] evm: HMAC attrs: 0x1
[    0.562515] rtc_cmos 00:01: setting system clock to 2016-08-09 14:46:31 =
UTC (1470753991)
[    0.562702] Unable to open file: /etc/keys/x509_evm.der (-2)
[    0.564624] Freeing unused kernel memory: 1344K (ffffffff81cf5000 - ffff=
ffff81e45000)
[    0.564725] Write protecting the kernel read-only data: 12288k
[    0.565374] Freeing unused kernel memory: 1640K (ffff880001666000 - ffff=
880001800000)
[    0.570863] Freeing unused kernel memory: 1520K (ffff880001a84000 - ffff=
880001c00000)
[    0.579324] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[    0.580060] geninitrd/12757 starting
[    0.583776] SCSI subsystem initialized
[    0.585084] libata version 3.00 loaded.
[    0.585159] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input0
[    0.586118] ahci 0000:00:1f.2: version 3.0
[    0.586270] ahci 0000:00:1f.2: SSS flag set, parallel bus scan disabled
[    0.596432] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 3 Gbps 0x=
33 impl SATA mode
[    0.596491] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp=
 pio slum part ems apst=20
[    0.614783] scsi host0: ahci
[    0.614979] scsi host1: ahci
[    0.615163] scsi host2: ahci
[    0.615346] scsi host3: ahci
[    0.615474] scsi host4: ahci
[    0.615583] scsi host5: ahci
[    0.615657] ata1: SATA max UDMA/133 abar m2048@0xfbffc000 port 0xfbffc10=
0 irq 24
[    0.615713] ata2: SATA max UDMA/133 abar m2048@0xfbffc000 port 0xfbffc18=
0 irq 24
[    0.615767] ata3: DUMMY
[    0.615802] ata4: DUMMY
[    0.615838] ata5: SATA max UDMA/133 abar m2048@0xfbffc000 port 0xfbffc30=
0 irq 24
[    0.615893] ata6: SATA max UDMA/133 abar m2048@0xfbffc000 port 0xfbffc38=
0 irq 24
[    1.077562] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.081866] ata1.00: ATA-8: WDC WD2003FYYS-02W0B1, 01.01D02, max UDMA/133
[    1.081911] ata1.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32=
), AA
[    1.086874] ata1.00: configured for UDMA/133
[    1.087094] scsi 0:0:0:0: Direct-Access     ATA      WDC WD2003FYYS-0 1D=
02 PQ: 0 ANSI: 5
[    1.524214] tsc: Refined TSC clocksource calibration: 2394.560 MHz
[    1.524270] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x228=
4248580e, max_idle_ns: 440795288736 ns
[    1.574216] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.578666] ata2.00: ATA-8: WDC WD2003FYYS-02W0B0, 01.01D01, max UDMA/133
[    1.578723] ata2.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32=
), AA
[    1.583674] ata2.00: configured for UDMA/133
[    1.583982] scsi 1:0:0:0: Direct-Access     ATA      WDC WD2003FYYS-0 1D=
01 PQ: 0 ANSI: 5
[    2.070865] ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.071861] ata5.00: ATA-8: WDC WD2000FYYZ-01UL1B1, 01.01K02, max UDMA/1=
33
[    2.071919] ata5.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32=
), AA
[    2.072953] ata5.00: configured for UDMA/133
[    2.073218] scsi 4:0:0:0: Direct-Access     ATA      WDC WD2000FYYZ-0 1K=
02 PQ: 0 ANSI: 5
[    2.524361] clocksource: Switched to clocksource tsc
[    2.560843] ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.562330] ata6.00: ATA-8: WDC WD2000FYYZ-01UL1B2, 01.01K03, max UDMA/1=
33
[    2.562388] ata6.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32=
), AA
[    2.563417] ata6.00: configured for UDMA/133
[    2.563700] scsi 5:0:0:0: Direct-Access     ATA      WDC WD2000FYYZ-0 1K=
03 PQ: 0 ANSI: 5
[    2.589052] md: raid1 personality registered for level 1
[    2.589604] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 =
TB/1.82 TiB)
[    2.589685] sd 4:0:0:0: [sdc] 3907029168 512-byte logical blocks: (2.00 =
TB/1.82 TiB)
[    2.589698] sd 5:0:0:0: [sdd] 3907029168 512-byte logical blocks: (2.00 =
TB/1.82 TiB)
[    2.589728] sd 5:0:0:0: [sdd] Write Protect is off
[    2.589730] sd 5:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[    2.589743] sd 5:0:0:0: [sdd] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    2.589898] sd 0:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00 =
TB/1.82 TiB)
[    2.589921] sd 4:0:0:0: [sdc] Write Protect is off
[    2.589922] sd 4:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    2.589935] sd 4:0:0:0: [sdc] Write cache: disabled, read cache: enabled=
, doesn't support DPO or FUA
[    2.590077] sd 1:0:0:0: [sdb] Write Protect is off
[    2.590079] sd 0:0:0:0: [sda] Write Protect is off
[    2.590081] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.590093] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    2.590212] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    2.590231] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    2.595368]  sda: sda1 sda2 sda3 sda4
[    2.595789] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.599262]  sdb: sdb1 sdb2 sdb3 sdb4
[    2.599584] sd 1:0:0:0: [sdb] Attached SCSI disk
[    2.601530]  sdd: sdd1 sdd2 sdd3 sdd4
[    2.601935] sd 5:0:0:0: [sdd] Attached SCSI disk
[    2.609757]  sdc: sdc1 sdc2 sdc3 sdc4
[    2.610181] sd 4:0:0:0: [sdc] Attached SCSI disk
[    2.615544] SGI XFS with ACLs, security attributes, no debug enabled
[    2.618522] random: udevd urandom read with 39 bits of entropy available
[    2.927351] md: md1 stopped.
[    2.929554] md: bind<sdb2>
[    2.929705] md: bind<sdc2>
[    2.929854] md: bind<sdd2>
[    2.930015] md: bind<sda2>
[    2.930173] md/raid1:md1: active with 4 out of 4 mirrors
[    2.930236] md1: detected capacity change from 0 to 107374116864
[    2.950519] XFS (md1): Mounting V4 Filesystem
[    2.970496] random: nonblocking pool is initialized
[    3.108969] XFS (md1): Ending clean mount
[    3.109574] geninitrd/12757 switching root
[    4.134739] ACPI Warning: SystemIO range 0x0000000000000428-0x0000000000=
00042F conflicts with OpRegion 0x000000000000042C-0x000000000000042D (\GP2C=
) (20160422/utaddress-255)
[    4.134745] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[    4.134770] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    4.135007] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    4.161695] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0C:00/input/input1
[    4.161700] ACPI: Power Button [PWRB]
[    4.162365] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input2
[    4.162369] ACPI: Power Button [PWRF]
[    4.193268] FUJITSU Extended Socket Network Device Driver - version 1.1 =
=2D Copyright (c) 2015 FUJITSU LIMITED
[    4.194217] ACPI: bus type USB registered
[    4.194242] usbcore: registered new interface driver usbfs
[    4.194253] usbcore: registered new interface driver hub
[    4.194275] usbcore: registered new device driver usb
[    4.213186] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.223414] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    4.223426] r8169 0000:02:00.0: can't disable ASPM; OS doesn't have ASPM=
 control
[    4.227863] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at 0xffffc90000e=
4c000, 50:e5:49:2e:26:1c, XID 0c900800 IRQ 26
[    4.227867] r8169 0000:02:00.0 eth0: jumbo features [frames: 9200 bytes,=
 tx checksumming: ko]
[    4.228434] ehci-pci: EHCI PCI platform driver
[    4.228568] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    4.228577] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus =
number 1
[    4.228591] ehci-pci 0000:00:1a.0: debug port 2
[    4.232533] ehci-pci 0000:00:1a.0: cache line size of 4 is not supported
[    4.233452] parport_pc 00:03: reported by Plug and Play ACPI
[    4.233517] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    4.235804] ehci-pci 0000:00:1a.0: irq 18, io mem 0xfbffe000
[    4.244159] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    4.244209] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    4.244211] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    4.244213] usb usb1: Product: EHCI Host Controller
[    4.244215] usb usb1: Manufacturer: Linux 4.7.0-1 ehci_hcd
[    4.244216] usb usb1: SerialNumber: 0000:00:1a.0
[    4.244361] hub 1-0:1.0: USB hub found
[    4.244367] hub 1-0:1.0: 2 ports detected
[    4.244976] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    4.245038] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus =
number 2
[    4.245052] ehci-pci 0000:00:1d.0: debug port 2
[    4.249133] ehci-pci 0000:00:1d.0: cache line size of 4 is not supported
[    4.253302] ehci-pci 0000:00:1d.0: irq 23, io mem 0xfbffd000
[    4.260788] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    4.260837] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    4.260839] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    4.260841] usb usb2: Product: EHCI Host Controller
[    4.260843] usb usb2: Manufacturer: Linux 4.7.0-1 ehci_hcd
[    4.260844] usb usb2: SerialNumber: 0000:00:1d.0
[    4.261169] hub 2-0:1.0: USB hub found
[    4.261176] hub 2-0:1.0: 2 ports detected
[    4.280005] input: PC Speaker as /devices/platform/pcspkr/input/input3
[    4.293472] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    4.336346] RAPL PMU: API unit is 2^-32 Joules, 3 fixed counters, 163840=
 ms ovfl timer
[    4.336349] RAPL PMU: hw unit of domain pp0-core 2^-16 Joules
[    4.336350] RAPL PMU: hw unit of domain package 2^-16 Joules
[    4.336351] RAPL PMU: hw unit of domain pp1-gpu 2^-16 Joules
[    4.385979] iTCO_vendor_support: vendor-support=3D0
[    4.387151] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    4.387184] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by=
 hardware/BIOS
[    4.405264] gpio_ich: GPIO from 436 to 511 on gpio_ich
[    4.418770] ppdev: user-space parallel port driver
[    4.550753] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    4.567419] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    4.635396] intel_rapl: Found RAPL domain package
[    4.635399] intel_rapl: Found RAPL domain core
[    4.635401] intel_rapl: Found RAPL domain uncore
[    4.674501] usb 1-1: New USB device found, idVendor=3D8087, idProduct=3D=
0024
[    4.674516] usb 1-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[    4.674768] hub 1-1:1.0: USB hub found
[    4.674826] hub 1-1:1.0: 4 ports detected
[    4.691116] usb 2-1: New USB device found, idVendor=3D8087, idProduct=3D=
0024
[    4.691121] usb 2-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[    4.691485] hub 2-1:1.0: USB hub found
[    4.691575] hub 2-1:1.0: 6 ports detected
[    7.230760] floppy0: no floppy controllers found
[    7.230770] work still pending
[    7.590833] md: md0 stopped.
[    7.592227] md: bind<sdb1>
[    7.592341] md: bind<sdc1>
[    7.592436] md: bind<sdd1>
[    7.592548] md: bind<sda1>
[    7.606940] md: raid0 personality registered for level 0
[    7.607181] md/raid0:md0: md_size is 41910272 sectors.
[    7.607183] md: RAID0 configuration for md0 - 1 zone
[    7.607185] md: zone0=3D[sda1/sdb1/sdc1/sdd1]
[    7.607190]       zone-offset=3D         0KB, device-offset=3D         0=
KB, size=3D  20955136KB
[    7.607202] md0: detected capacity change from 0 to 21458059264
[    7.623793] md: md2 stopped.
[    7.625564] md: bind<sdb3>
[    7.625669] md: bind<sdc3>
[    7.625770] md: bind<sdd3>
[    7.625940] md: bind<sda3>
[    7.703961] raid6: sse2x1   gen()  6399 MB/s
[    7.760620] raid6: sse2x1   xor()  5012 MB/s
[    7.817286] raid6: sse2x2   gen()  7973 MB/s
[    7.873952] raid6: sse2x2   xor()  5801 MB/s
[    7.930615] raid6: sse2x4   gen()  9242 MB/s
[    7.987279] raid6: sse2x4   xor()  6960 MB/s
[    7.987281] raid6: using algorithm sse2x4 gen() 9242 MB/s
[    7.987282] raid6: .... xor() 6960 MB/s, rmw enabled
[    7.987283] raid6: using ssse3x2 recovery algorithm
[    7.987962] async_tx: api initialized (async)
[    7.988621] xor: measuring software checksum speed
[    8.020609]    prefetch64-sse: 13413.600 MB/sec
[    8.053941]    generic_sse: 12324.000 MB/sec
[    8.053942] xor: using function: prefetch64-sse (13413.600 MB/sec)
[    8.063069] md: raid6 personality registered for level 6
[    8.063073] md: raid5 personality registered for level 5
[    8.063074] md: raid4 personality registered for level 4
[    8.063392] md/raid:md2: device sda3 operational as raid disk 0
[    8.063394] md/raid:md2: device sdd3 operational as raid disk 3
[    8.063395] md/raid:md2: device sdc3 operational as raid disk 2
[    8.063397] md/raid:md2: device sdb3 operational as raid disk 1
[    8.063688] md/raid:md2: allocated 4374kB
[    8.064389] md/raid:md2: raid level 5 active with 4 out of 4 devices, al=
gorithm 2
[    8.064391] RAID conf printout:
[    8.064393]  --- level:5 rd:4 wd:4
[    8.064394]  disk 0, o:1, dev:sda3
[    8.064396]  disk 1, o:1, dev:sdb3
[    8.064397]  disk 2, o:1, dev:sdc3
[    8.064399]  disk 3, o:1, dev:sdd3
[    8.064531] created bitmap (7 pages) for device md2
[    8.064742] md2: bitmap initialized from disk: read 1 pages, set 0 of 14=
078 bits
[    8.072817] md2: detected capacity change from 0 to 2834275762176
[    8.106570] md: md3 stopped.
[    8.109279] md: bind<sdb4>
[    8.109393] md: bind<sdc4>
[    8.109490] md: bind<sdd4>
[    8.109609] md: bind<sda4>
[    8.111468] md/raid:md3: device sda4 operational as raid disk 0
[    8.111471] md/raid:md3: device sdd4 operational as raid disk 3
[    8.111472] md/raid:md3: device sdc4 operational as raid disk 2
[    8.111474] md/raid:md3: device sdb4 operational as raid disk 1
[    8.111711] md/raid:md3: allocated 4374kB
[    8.111735] md/raid:md3: raid level 5 active with 4 out of 4 devices, al=
gorithm 2
[    8.111736] RAID conf printout:
[    8.111737]  --- level:5 rd:4 wd:4
[    8.111739]  disk 0, o:1, dev:sda4
[    8.111740]  disk 1, o:1, dev:sdb4
[    8.111741]  disk 2, o:1, dev:sdc4
[    8.111742]  disk 3, o:1, dev:sdd4
[    8.111855] created bitmap (7 pages) for device md3
[    8.112053] md3: bitmap initialized from disk: read 1 pages, set 0 of 14=
047 bits
[    8.128615] md3: detected capacity change from 0 to 2827883642880
[    8.171727] XFS (md2): Mounting V4 Filesystem
[    8.398760] XFS (md2): Ending clean mount
[    8.698346] EXT4-fs (md3): mounted filesystem with ordered data mode. Op=
ts: (null)
[    9.581802] Adding 20955132k swap on /dev/md0.  Priority:-1 extents:1 ac=
ross:20955132k FS
[   10.149348] r8169 0000:02:00.0 eth0: link down
[   10.149351] r8169 0000:02:00.0 eth0: link down
[   10.149406] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   12.308938] r8169 0000:02:00.0 eth0: link up
[   12.308949] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

[started testing with xfs]

[ 3480.077485] INFO: task kworker/1:0H:1249 blocked for more than 120 secon=
ds.
[ 3480.077490]       Not tainted 4.7.0-1 #1
[ 3480.077491] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[ 3480.077492] kworker/1:0H    D ffff88011edfbae8     0  1249      2 0x0000=
0000
[ 3480.077528] Workqueue: xfs-log/md2 xfs_log_worker [xfs]
[ 3480.077531]  ffff88011edfbae8 ffff880215553fc0 ffffffff8104b2e5 ffff8801=
1edfc000
[ 3480.077533]  ffff88011edfbc70 0000000000000000 7fffffffffffffff ffff8802=
15553fc0
[ 3480.077535]  ffff88011edfbb00 ffffffff816598e5 0000000000000002 ffff8801=
1edfbbb0
[ 3480.077537] Call Trace:
[ 3480.077544]  [<ffffffff8104b2e5>] ? default_send_IPI_single+0x35/0x40
[ 3480.077547]  [<ffffffff816598e5>] schedule+0x35/0x80
[ 3480.077549]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[ 3480.077553]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[ 3480.077555]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[ 3480.077558]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[ 3480.077559]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[ 3480.077562]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[ 3480.077565]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[ 3480.077567]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[ 3480.077588]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[ 3480.077596]  [<ffffffffc000ab9f>] ? scsi_request_fn+0x3f/0x660 [scsi_mod]
[ 3480.077616]  [<ffffffffc0149dc4>] ? xlog_state_do_callback+0x2a4/0x2c0 [=
xfs]
[ 3480.077635]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[ 3480.077637]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[ 3480.077655]  [<ffffffffc014be64>] ? xfs_log_worker+0x24/0x50 [xfs]
[ 3480.077672]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[ 3480.077689]  [<ffffffffc014be64>] xfs_log_worker+0x24/0x50 [xfs]
[ 3480.077691]  [<ffffffff8108e2d5>] process_one_work+0x155/0x470
[ 3480.077694]  [<ffffffff8108e63b>] worker_thread+0x4b/0x4f0
[ 3480.077696]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[ 3480.077698]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[ 3480.077700]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[ 3480.077702]  [<ffffffff81094538>] kthread+0xd8/0xf0
[ 3480.077705]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[ 3480.077707]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[ 3480.077710] INFO: task rm:1275 blocked for more than 120 seconds.
[ 3480.077711]       Not tainted 4.7.0-1 #1
[ 3480.077712] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[ 3480.077713] rm              D ffff8801118576e8     0  1275   1189 0x0000=
0000
[ 3480.077715]  ffff8801118576e8 ffff880037e3b300 ffffffff8104b2e5 ffff8801=
11858000
[ 3480.077717]  ffff880111857870 0000000000000000 7fffffffffffffff ffff8800=
37e3b300
[ 3480.077719]  ffff880111857700 ffffffff816598e5 0000000000000002 ffff8801=
118577b0
[ 3480.077721] Call Trace:
[ 3480.077724]  [<ffffffff8104b2e5>] ? default_send_IPI_single+0x35/0x40
[ 3480.077726]  [<ffffffff816598e5>] schedule+0x35/0x80
[ 3480.077728]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[ 3480.077730]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[ 3480.077732]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[ 3480.077734]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[ 3480.077736]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[ 3480.077738]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[ 3480.077740]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[ 3480.077742]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[ 3480.077761]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[ 3480.077777]  [<ffffffffc0100dba>] ? xfs_btree_updkey+0x8a/0xc0 [xfs]
[ 3480.077793]  [<ffffffffc0100c0d>] ? xfs_btree_is_lastrec+0x5d/0x70 [xfs]
[ 3480.077811]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[ 3480.077830]  [<ffffffffc01298bb>] ? xfs_buf_lock+0xeb/0xf0 [xfs]
[ 3480.077847]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[ 3480.077866]  [<ffffffffc0129a10>] ? _xfs_buf_find+0x150/0x320 [xfs]
[ 3480.077883]  [<ffffffffc01298bb>] xfs_buf_lock+0xeb/0xf0 [xfs]
[ 3480.077901]  [<ffffffffc0129a10>] _xfs_buf_find+0x150/0x320 [xfs]
[ 3480.077918]  [<ffffffffc0129cfa>] xfs_buf_get_map+0x2a/0x1d0 [xfs]
[ 3480.077933]  [<ffffffffc00e9d6a>] ? xfs_free_ag_extent+0x2ca/0x760 [xfs]
[ 3480.077954]  [<ffffffffc0158608>] xfs_trans_get_buf_map+0x108/0x190 [xfs]
[ 3480.077970]  [<ffffffffc010210f>] xfs_btree_get_bufs+0x5f/0x80 [xfs]
[ 3480.077985]  [<ffffffffc00ec061>] xfs_alloc_fix_freelist+0x231/0x3e0 [xf=
s]
[ 3480.078004]  [<ffffffffc0146b03>] ? xfs_trans_free_item_desc+0x33/0x40 [=
xfs]
[ 3480.078022]  [<ffffffffc0147620>] ? xfs_trans_free_items+0x80/0xb0 [xfs]
[ 3480.078026]  [<ffffffff8133bc1d>] ? radix_tree_lookup+0xd/0x10
[ 3480.078044]  [<ffffffffc011f7ca>] ? xfs_perag_get+0x2a/0xb0 [xfs]
[ 3480.078059]  [<ffffffffc00ec9b4>] xfs_free_extent+0x94/0x120 [xfs]
[ 3480.078080]  [<ffffffffc0159166>] xfs_trans_free_extent+0x26/0x60 [xfs]
[ 3480.078098]  [<ffffffffc0126437>] xfs_bmap_finish+0x117/0x140 [xfs]
[ 3480.078118]  [<ffffffffc013d93e>] xfs_itruncate_extents+0xfe/0x220 [xfs]
[ 3480.078137]  [<ffffffffc013db0d>] xfs_inactive_truncate+0xad/0x100 [xfs]
[ 3480.078155]  [<ffffffffc013e0b2>] xfs_inactive+0x102/0x120 [xfs]
[ 3480.078174]  [<ffffffffc0143718>] xfs_fs_destroy_inode+0x98/0x190 [xfs]
[ 3480.078177]  [<ffffffff8121e55b>] destroy_inode+0x3b/0x60
[ 3480.078179]  [<ffffffff8121e6a9>] evict+0x129/0x190
[ 3480.078181]  [<ffffffff8121ef28>] iput+0x1b8/0x240
[ 3480.078184]  [<ffffffff81213669>] do_unlinkat+0x199/0x2d0
[ 3480.078187]  [<ffffffff81213fbb>] SyS_unlinkat+0x1b/0x30
[ 3480.078189]  [<ffffffff8165d1b6>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[10124.041862] perf: interrupt took too long (2507 > 2500), lowering kernel=
=2Eperf_event_max_sample_rate to 79500
[13357.017542] perf: interrupt took too long (3134 > 3133), lowering kernel=
=2Eperf_event_max_sample_rate to 63600
[56878.087309] INFO: task xfsaild/md2:661 blocked for more than 120 seconds.
[56878.087313]       Not tainted 4.7.0-1 #1
[56878.087314] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[56878.087315] xfsaild/md2     D ffff8800d68b3ae8     0   661      2 0x0000=
0000
[56878.087320]  ffff8800d68b3ae8 ffff8800d6b19980 ffff88021ea56db0 ffff8800=
d68b4000
[56878.087322]  ffff8800d68b3c70 0000000000000000 7fffffffffffffff ffff8800=
d6b19980
[56878.087325]  ffff8800d68b3b00 ffffffff816598e5 0000000000000002 ffff8800=
d68b3bb0
[56878.087327] Call Trace:
[56878.087334]  [<ffffffff816598e5>] schedule+0x35/0x80
[56878.087337]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[56878.087339]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[56878.087342]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[56878.087345]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[56878.087347]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[56878.087350]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[56878.087352]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[56878.087386]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[56878.087389]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[56878.087392]  [<ffffffff810dc92e>] ? try_to_del_timer_sync+0x5e/0x90
[56878.087413]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[56878.087415]  [<ffffffff810dc3c0>] ? init_timer_key+0xb0/0xb0
[56878.087435]  [<ffffffffc01574f4>] ? xfsaild+0x184/0x740 [xfs]
[56878.087455]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[56878.087474]  [<ffffffffc01574f4>] xfsaild+0x184/0x740 [xfs]
[56878.087493]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[56878.087511]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[56878.087513]  [<ffffffff81094538>] kthread+0xd8/0xf0
[56878.087516]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[56878.087518]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[56878.087525] INFO: task kworker/1:1H:1917 blocked for more than 120 secon=
ds.
[56878.087527]       Not tainted 4.7.0-1 #1
[56878.087528] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[56878.087529] kworker/1:1H    D ffff8801843cbae8     0  1917      2 0x0000=
0000
[56878.087550] Workqueue: xfs-log/md2 xfs_log_worker [xfs]
[56878.087551]  ffff8801843cbae8 ffff8800d6b1f2c0 ffff880214739a00 ffff8801=
843cc000
[56878.087553]  ffff8801843cbc70 0000000000000000 7fffffffffffffff ffff8800=
d6b1f2c0
[56878.087555]  ffff8801843cbb00 ffffffff816598e5 0000000000000002 ffff8801=
843cbbb0
[56878.087557] Call Trace:
[56878.087560]  [<ffffffff816598e5>] schedule+0x35/0x80
[56878.087562]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[56878.087564]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[56878.087566]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[56878.087568]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[56878.087570]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[56878.087572]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[56878.087574]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[56878.087576]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[56878.087595]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[56878.087603]  [<ffffffffc000ab9f>] ? scsi_request_fn+0x3f/0x660 [scsi_mod]
[56878.087623]  [<ffffffffc0149dc4>] ? xlog_state_do_callback+0x2a4/0x2c0 [=
xfs]
[56878.087641]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[56878.087644]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[56878.087661]  [<ffffffffc014be64>] ? xfs_log_worker+0x24/0x50 [xfs]
[56878.087678]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[56878.087695]  [<ffffffffc014be64>] xfs_log_worker+0x24/0x50 [xfs]
[56878.087698]  [<ffffffff8108e2d5>] process_one_work+0x155/0x470
[56878.087700]  [<ffffffff8108e63b>] worker_thread+0x4b/0x4f0
[56878.087702]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[56878.087704]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[56878.087706]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[56878.087708]  [<ffffffff81094538>] kthread+0xd8/0xf0
[56878.087711]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[56878.087713]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[57238.073850] INFO: task kworker/1:1H:1917 blocked for more than 120 secon=
ds.
[57238.073854]       Not tainted 4.7.0-1 #1
[57238.073855] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57238.073857] kworker/1:1H    D ffff8801843cbae8     0  1917      2 0x0000=
0000
[57238.073894] Workqueue: xfs-log/md2 xfs_log_worker [xfs]
[57238.073896]  ffff8801843cbae8 ffff8800d6b1f2c0 ffff880214739a00 ffff8801=
843cc000
[57238.073899]  ffff8801843cbc70 0000000000000000 7fffffffffffffff ffff8800=
d6b1f2c0
[57238.073901]  ffff8801843cbb00 ffffffff816598e5 0000000000000002 ffff8801=
843cbbb0
[57238.073903] Call Trace:
[57238.073909]  [<ffffffff816598e5>] schedule+0x35/0x80
[57238.073912]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[57238.073916]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[57238.073918]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[57238.073920]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[57238.073922]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[57238.073924]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[57238.073927]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[57238.073929]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[57238.073951]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[57238.073960]  [<ffffffffc000ab9f>] ? scsi_request_fn+0x3f/0x660 [scsi_mod]
[57238.073981]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[57238.073983]  [<ffffffff810aa26c>] ? dequeue_task_fair+0x54c/0x9c0
[57238.073985]  [<ffffffff810aa8d5>] ? put_prev_entity+0x35/0x880
[57238.073987]  [<ffffffff810b096f>] ? pick_next_task_fair+0x10f/0x4c0
[57238.074006]  [<ffffffffc014be64>] ? xfs_log_worker+0x24/0x50 [xfs]
[57238.074023]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[57238.074041]  [<ffffffffc014be64>] xfs_log_worker+0x24/0x50 [xfs]
[57238.074043]  [<ffffffff8108e2d5>] process_one_work+0x155/0x470
[57238.074046]  [<ffffffff8108e63b>] worker_thread+0x4b/0x4f0
[57238.074048]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[57238.074050]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[57238.074052]  [<ffffffff8108e5f0>] ? process_one_work+0x470/0x470
[57238.074054]  [<ffffffff81094538>] kthread+0xd8/0xf0
[57238.074057]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[57238.074059]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[57534.200562] perf: interrupt took too long (3920 > 3917), lowering kernel=
=2Eperf_event_max_sample_rate to 51000
[57598.060403] INFO: task xfsaild/md2:661 blocked for more than 120 seconds.
[57598.060407]       Not tainted 4.7.0-1 #1
[57598.060408] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57598.060410] xfsaild/md2     D ffff8800d68b3ae8     0   661      2 0x0000=
0000
[57598.060414]  ffff8800d68b3ae8 ffff8800d6b19980 ffff880214739a00 ffff8800=
d68b4000
[57598.060417]  ffff8800d68b3c70 0000000000000000 7fffffffffffffff ffff8800=
d6b19980
[57598.060419]  ffff8800d68b3b00 ffffffff816598e5 0000000000000002 ffff8800=
d68b3bb0
[57598.060421] Call Trace:
[57598.060428]  [<ffffffff816598e5>] schedule+0x35/0x80
[57598.060431]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[57598.060434]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[57598.060436]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[57598.060439]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[57598.060441]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[57598.060443]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[57598.060446]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[57598.060448]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[57598.060479]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[57598.060482]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[57598.060502]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[57598.060505]  [<ffffffff810dc3c0>] ? init_timer_key+0xb0/0xb0
[57598.060525]  [<ffffffffc01574f4>] ? xfsaild+0x184/0x740 [xfs]
[57598.060544]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[57598.060563]  [<ffffffffc01574f4>] xfsaild+0x184/0x740 [xfs]
[57598.060581]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[57598.060599]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[57598.060601]  [<ffffffff81094538>] kthread+0xd8/0xf0
[57598.060604]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[57598.060606]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[57718.055905] INFO: task xfsaild/md2:661 blocked for more than 120 seconds.
[57718.055920]       Not tainted 4.7.0-1 #1
[57718.055921] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57718.055922] xfsaild/md2     D ffff8800d68b3ae8     0   661      2 0x0000=
0000
[57718.055926]  ffff8800d68b3ae8 ffff8800d6b19980 ffff880214739a00 ffff8800=
d68b4000
[57718.055929]  ffff8800d68b3c70 0000000000000000 7fffffffffffffff ffff8800=
d6b19980
[57718.055931]  ffff8800d68b3b00 ffffffff816598e5 0000000000000002 ffff8800=
d68b3bb0
[57718.055933] Call Trace:
[57718.055941]  [<ffffffff816598e5>] schedule+0x35/0x80
[57718.055944]  [<ffffffff8165c49c>] schedule_timeout+0x1ec/0x250
[57718.055947]  [<ffffffff8109dc80>] ? check_preempt_curr+0x80/0x90
[57718.055949]  [<ffffffff8109dca9>] ? ttwu_do_wakeup+0x19/0xe0
[57718.055951]  [<ffffffff8165a336>] wait_for_common+0xc6/0x1a0
[57718.055953]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[57718.055956]  [<ffffffff8165a42d>] wait_for_completion+0x1d/0x20
[57718.055958]  [<ffffffff8108d601>] flush_work+0x111/0x1c0
[57718.055961]  [<ffffffff8108b570>] ? flush_workqueue_prep_pwqs+0x1a0/0x1a0
[57718.055994]  [<ffffffffc014da47>] xlog_cil_force_lsn+0x87/0x1f0 [xfs]
[57718.055996]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[57718.056017]  [<ffffffffc014bb85>] _xfs_log_force+0x85/0x2a0 [xfs]
[57718.056019]  [<ffffffff810dc3c0>] ? init_timer_key+0xb0/0xb0
[57718.056039]  [<ffffffffc01574f4>] ? xfsaild+0x184/0x740 [xfs]
[57718.056058]  [<ffffffffc014bdcc>] xfs_log_force+0x2c/0xa0 [xfs]
[57718.056077]  [<ffffffffc01574f4>] xfsaild+0x184/0x740 [xfs]
[57718.056096]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[57718.056113]  [<ffffffffc0157370>] ? xfs_trans_ail_cursor_first+0x90/0x90=
 [xfs]
[57718.056116]  [<ffffffff81094538>] kthread+0xd8/0xf0
[57718.056119]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[57718.056121]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[57718.056125] INFO: task cp:1684 blocked for more than 120 seconds.
[57718.056126]       Not tainted 4.7.0-1 #1
[57718.056127] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57718.056128] cp              D ffff880090ec3c68     0  1684   1189 0x0000=
0000
[57718.056130]  ffff880090ec3c68 ffff88021473b300 0000000000071240 ffff8800=
90ec4000
[57718.056133]  ffff8801d81cb170 ffff8802147039c0 0000000000071240 00000000=
00000023
[57718.056135]  ffff880090ec3c80 ffffffff816598e5 ffff880214703800 ffff8800=
90ec3cc8
[57718.056137] Call Trace:
[57718.056139]  [<ffffffff816598e5>] schedule+0x35/0x80
[57718.056158]  [<ffffffffc0148bf2>] xlog_grant_head_wait+0xb2/0x1d0 [xfs]
[57718.056176]  [<ffffffffc0148da4>] xlog_grant_head_check+0x94/0xf0 [xfs]
[57718.056194]  [<ffffffffc014c63e>] xfs_log_reserve+0xce/0x1e0 [xfs]
[57718.056213]  [<ffffffffc0146a6c>] xfs_trans_reserve+0x16c/0x1d0 [xfs]
[57718.056232]  [<ffffffffc0147cd9>] xfs_trans_alloc+0xb9/0x130 [xfs]
[57718.056251]  [<ffffffffc013d689>] xfs_link+0x129/0x2e0 [xfs]
[57718.056254]  [<ffffffff81219df7>] ? _d_rehash+0x37/0x40
[57718.056256]  [<ffffffff8121a0ba>] ? d_add+0x16a/0x180
[57718.056275]  [<ffffffffc0138c16>] xfs_vn_link+0x66/0xb0 [xfs]
[57718.056278]  [<ffffffff8120e952>] vfs_link+0x1d2/0x2a0
[57718.056280]  [<ffffffff812143b8>] SyS_linkat+0x298/0x2f0
[57718.056283]  [<ffffffff8165d1b6>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[57718.056285] INFO: task cp:1705 blocked for more than 120 seconds.
[57718.056286]       Not tainted 4.7.0-1 #1
[57718.056287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57718.056288] cp              D ffff880211537c68     0  1705   1685 0x0000=
0000
[57718.056290]  ffff880211537c68 ffff880214551980 0000000000071240 ffff8802=
11538000
[57718.056292]  ffff880062512da8 ffff8802147039c0 0000000000071240 00000000=
00000023
[57718.056294]  ffff880211537c80 ffffffff816598e5 ffff880214703800 ffff8802=
11537cc8
[57718.056296] Call Trace:
[57718.056298]  [<ffffffff816598e5>] schedule+0x35/0x80
[57718.056317]  [<ffffffffc0148bf2>] xlog_grant_head_wait+0xb2/0x1d0 [xfs]
[57718.056334]  [<ffffffffc0148da4>] xlog_grant_head_check+0x94/0xf0 [xfs]
[57718.056352]  [<ffffffffc014c63e>] xfs_log_reserve+0xce/0x1e0 [xfs]
[57718.056371]  [<ffffffffc0146a6c>] xfs_trans_reserve+0x16c/0x1d0 [xfs]
[57718.056388]  [<ffffffffc0147cd9>] xfs_trans_alloc+0xb9/0x130 [xfs]
[57718.056408]  [<ffffffffc013d689>] xfs_link+0x129/0x2e0 [xfs]
[57718.056410]  [<ffffffff81219df7>] ? _d_rehash+0x37/0x40
[57718.056411]  [<ffffffff8121a0ba>] ? d_add+0x16a/0x180
[57718.056431]  [<ffffffffc0138c16>] xfs_vn_link+0x66/0xb0 [xfs]
[57718.056433]  [<ffffffff8120e952>] vfs_link+0x1d2/0x2a0
[57718.056435]  [<ffffffff812143b8>] SyS_linkat+0x298/0x2f0
[57718.056438]  [<ffffffff8165d1b6>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[57718.056440] INFO: task cp:1726 blocked for more than 120 seconds.
[57718.056441]       Not tainted 4.7.0-1 #1
[57718.056442] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[57718.056443] cp              D ffff8801c543fc68     0  1726   1706 0x0000=
0000
[57718.056445]  ffff8801c543fc68 ffff880214aba640 0000000000071240 ffff8801=
c5440000
[57718.056447]  ffff880062512000 ffff8802147039c0 0000000000071240 00000000=
00000023
[57718.056449]  ffff8801c543fc80 ffffffff816598e5 ffff880214703800 ffff8801=
c543fcc8
[57718.056451] Call Trace:
[57718.056453]  [<ffffffff816598e5>] schedule+0x35/0x80
[57718.056471]  [<ffffffffc0148bf2>] xlog_grant_head_wait+0xb2/0x1d0 [xfs]
[57718.056488]  [<ffffffffc0148da4>] xlog_grant_head_check+0x94/0xf0 [xfs]
[57718.056506]  [<ffffffffc014c63e>] xfs_log_reserve+0xce/0x1e0 [xfs]
[57718.056524]  [<ffffffffc0146a6c>] xfs_trans_reserve+0x16c/0x1d0 [xfs]
[57718.056541]  [<ffffffffc0147cd9>] xfs_trans_alloc+0xb9/0x130 [xfs]
[57718.056560]  [<ffffffffc013d689>] xfs_link+0x129/0x2e0 [xfs]
[57718.056562]  [<ffffffff81219df7>] ? _d_rehash+0x37/0x40
[57718.056564]  [<ffffffff8121a0ba>] ? d_add+0x16a/0x180
[57718.056583]  [<ffffffffc0138c16>] xfs_vn_link+0x66/0xb0 [xfs]
[57718.056586]  [<ffffffff8120e952>] vfs_link+0x1d2/0x2a0
[57718.056587]  [<ffffffff812143b8>] SyS_linkat+0x298/0x2f0
[57718.056590]  [<ffffffff8165d1b6>] entry_SYSCALL_64_fastpath+0x1e/0xa8


[somewhere in middle started testing on ext4, stopped on xfs]

[87259.568301] bash invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL_ACC=
OUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[87259.568304] bash cpuset=3D/ mems_allowed=3D0
[87259.568309] CPU: 1 PID: 2238 Comm: bash Not tainted 4.7.0-1 #1
[87259.568311] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H61=
M-S2V-B3, BIOS F4 05/25/2011
[87259.568312]  0000000000000286 00000000971cca7c ffff880102fabb40 ffffffff=
81335d0e
[87259.568315]  ffff880102fabd28 ffff880214739980 ffff880102fabbb0 ffffffff=
811ffa2f
[87259.568317]  0000000000000000 ffff88021ea5a748 0000000100000000 ffff8800=
37eb0cc0
[87259.568319] Call Trace:
[87259.568326]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[87259.568329]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[87259.568334]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[87259.568337]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[87259.568339]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[87259.568341]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[87259.568344]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[87259.568348]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[87259.568351]  [<ffffffff811dff4d>] ? kmem_cache_alloc+0x1bd/0x1d0
[87259.568353]  [<ffffffff8120513c>] ? get_empty_filp+0x5c/0x1c0
[87259.568356]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[87259.568358]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[87259.568361]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[87259.568364]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[87259.568365] Mem-Info:
[87259.568369] active_anon:439065 inactive_anon:146385 isolated_anon:0
                active_file:201920 inactive_file:122369 isolated_file:0
                unevictable:0 dirty:26675 writeback:0 unstable:0
                slab_reclaimable:966564 slab_unreclaimable:79528
                mapped:2236 shmem:1 pagetables:1759 bounce:0
                free:30651 free_pcp:0 free_cma:0
[87259.568372] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB activ=
e_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:=
0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[87259.568378] lowmem_reserve[]: 0 3405 7866 7866
[87259.568380] Node 0 DMA32 free:57976kB min:29148kB low:36432kB high:43716=
kB active_anon:794476kB inactive_anon:264828kB active_file:213280kB inactiv=
e_file:87136kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:42012kB writeback:0kB=
 mapped:2240kB shmem:0kB slab_reclaimable:1908884kB slab_unreclaimable:1255=
60kB kernel_stack:928kB pagetables:2548kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:12 all_unreclaimable? no
[87259.568386] lowmem_reserve[]: 0 0 4460 4460
[87259.568388] Node 0 Normal free:49268kB min:38304kB low:47880kB high:5745=
6kB active_anon:961784kB inactive_anon:320712kB active_file:594400kB inacti=
ve_file:402340kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:64688kB writeback:0kB=
 mapped:6704kB shmem:4kB slab_reclaimable:1957372kB slab_unreclaimable:1925=
52kB kernel_stack:1584kB pagetables:4488kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[87259.568393] lowmem_reserve[]: 0 0 0 0
[87259.568395] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB=
 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[87259.568403] Node 0 DMA32: 11467*4kB (UME) 1525*8kB (UME) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 58068kB
[87259.568411] Node 0 Normal: 9927*4kB (UMEH) 1119*8kB (UMH) 19*16kB (H) 8*=
32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D =
49348kB
[87259.568420] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D2048kB
[87259.568421] 324490 total pagecache pages
[87259.568422] 140 pages in swap cache
[87259.568424] Swap cache stats: add 1604711, delete 1604571, find 800418/9=
61568
[87259.568425] Free swap  =3D 20943644kB
[87259.568426] Total swap =3D 20955132kB
[87259.568427] 2076012 pages RAM
[87259.568428] 0 pages HighMem/MovableOnly
[87259.568428] 52657 pages reserved
[87259.568429] 4096 pages cma reserved
[87259.568430] 0 pages hwpoisoned
[87259.568431] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapen=
ts oom_score_adj name
[87259.568435] [  429]     0   429    10643       69      21       3      3=
42         -1000 udevd
[87259.568438] [  802]     0   802     4826       22      14       3       =
35             0 irqbalance
[87259.568440] [  995]     0   995     6743        2      16       3       =
69             0 syslog-ng
[87259.568442] [  996]     0   996   123139      519      45       4      3=
69             0 syslog-ng
[87259.568444] [ 1027]     0  1027    15794      217      34       3      1=
45         -1000 sshd
[87259.568445] [ 1071]     0  1071    35627      203      17       4      1=
25             0 crond
[87259.568447] [ 1107]     0  1107    31552        0      10       3       =
22             0 mingetty
[87259.568449] [ 1108]     0  1108    31552        0      10       4       =
22             0 mingetty
[87259.568451] [ 1109]     0  1109    31552        0      10       3       =
21             0 mingetty
[87259.568452] [ 1147]     0  1147    36183      506      20       3      1=
35             0 tmux
[87259.568454] [ 1189]     0  1189    34030       73      16       3      1=
05             0 bash
[87259.568456] [ 1685]     0  1685    34030       73      16       3      1=
07             0 bash
[87259.568458] [ 1706]     0  1706    34030       80      16       3      1=
05             0 bash
[87259.568459] [ 1727]     0  1727    34030       47      15       3      1=
11             0 bash
[87259.568461] [ 1747]     0  1747    34030       75      15       3      1=
04             0 bash
[87259.568463] [ 1767]     0  1767    34030       80      14       3      1=
04             0 bash
[87259.568464] [ 1787]     0  1787    34030       79      17       3      1=
05             0 bash
[87259.568466] [ 1807]     0  1807    34030       53      15       3      1=
09             0 bash
[87259.568468] [ 1827]     0  1827    34030       71      17       3      1=
10             0 bash
[87259.568469] [ 1847]     0  1847    34030       75      16       3      1=
03             0 bash
[87259.568471] [ 2168]     0  2168    93321    58592     132       4       =
39             0 cp
[87259.568473] [ 2175]     0  2175    93321    58587     131       3       =
46             0 cp
[87259.568475] [ 2178]     0  2178    93321    58592     132       3       =
39             0 cp
[87259.568477] [ 2180]     0  2180    93321    58590     133       3       =
40             0 cp
[87259.568478] [ 2182]     0  2182    93321    58588     132       3       =
43             0 cp
[87259.568480] [ 2184]     0  2184    93321    58577     131       4       =
47             0 cp
[87259.568482] [ 2186]     0  2186    93321    58585     132       3       =
40             0 cp
[87259.568484] [ 2188]     0  2188    93321    58593     132       3       =
35             0 cp
[87259.568485] [ 2190]     0  2190    93321    58599     133       3       =
36             0 cp
[87259.568487] [ 2192]     0  2192    93321    58598     131       3       =
37             0 cp
[87259.568489] [ 2234]     0  2234    26919     1590      58       3       =
 0             0 sshd
[87259.568491] [ 2238]     0  2238    34073      885      16       3       =
 0             0 bash
[87259.568492] Out of memory: Kill process 2190 (cp) score 7 or sacrifice c=
hild
[87259.568496] Killed process 2190 (cp) total-vm:373284kB, anon-rss:233932k=
B, file-rss:464kB, shmem-rss:0kB
[87259.586976] oom_reaper: reaped process 2190 (cp), now anon-rss:0kB, file=
=2Drss:0kB, shmem-rss:0kB
[99888.398968] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL=
_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[99888.398972] kthreadd cpuset=3D/ mems_allowed=3D0
[99888.398977] CPU: 0 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[99888.398978] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H61=
M-S2V-B3, BIOS F4 05/25/2011
[99888.398980]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 ffffffff=
81335d0e
[99888.398983]  ffff88021555fcf8 ffff880037e3b300 ffff88021555fb80 ffffffff=
811ffa2f
[99888.398985]  0000000000000000 ffff88021ea1a748 0000000100000000 ffff8802=
15550cc0
[99888.398987] Call Trace:
[99888.398994]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[99888.398997]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[99888.399001]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[99888.399004]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[99888.399006]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[99888.399008]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[99888.399011]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[99888.399014]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[99888.399017]  [<ffffffff810a6051>] ? set_next_entity+0x71/0x920
[99888.399020]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[99888.399022]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[99888.399024]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[99888.399026]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[99888.399028]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[99888.399030]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[99888.399033]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[99888.399035]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[99888.399036] Mem-Info:
[99888.399040] active_anon:195818 inactive_anon:195891 isolated_anon:0
                active_file:294335 inactive_file:23747 isolated_file:0
                unevictable:0 dirty:38741 writeback:2 unstable:0
                slab_reclaimable:1079860 slab_unreclaimable:157162
                mapped:675 shmem:1 pagetables:1625 bounce:0
                free:34472 free_pcp:0 free_cma:0
[99888.399044] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB activ=
e_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:=
0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[99888.399049] lowmem_reserve[]: 0 3405 7866 7866
[99888.399052] Node 0 DMA32 free:71868kB min:29148kB low:36432kB high:43716=
kB active_anon:288580kB inactive_anon:288628kB active_file:487756kB inactiv=
e_file:40308kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:60916kB writeback:0kB=
 mapped:968kB shmem:0kB slab_reclaimable:2012792kB slab_unreclaimable:25732=
0kB kernel_stack:928kB pagetables:2344kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:88 all_unreclaimable? no
[99888.399057] lowmem_reserve[]: 0 0 4460 4460
[99888.399059] Node 0 Normal free:50660kB min:38304kB low:47880kB high:5745=
6kB active_anon:494692kB inactive_anon:494936kB active_file:689584kB inacti=
ve_file:54680kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:94048kB writeback:8kB=
 mapped:1732kB shmem:4kB slab_reclaimable:2306648kB slab_unreclaimable:3713=
28kB kernel_stack:1520kB pagetables:4156kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:100 all_unreclaimable? no
[99888.399064] lowmem_reserve[]: 0 0 0 0
[99888.399066] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB=
 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[99888.399075] Node 0 DMA32: 14370*4kB (UME) 1809*8kB (UM) 0*16kB 0*32kB 0*=
64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 71952kB
[99888.399082] Node 0 Normal: 12172*4kB (UMEH) 165*8kB (UMEH) 23*16kB (H) 9=
*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=
 50792kB
[99888.399091] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D2048kB
[99888.399092] 322587 total pagecache pages
[99888.399094] 4439 pages in swap cache
[99888.399095] Swap cache stats: add 1744522, delete 1740083, find 800596/9=
61835
[99888.399096] Free swap  =3D 20385372kB
[99888.399097] Total swap =3D 20955132kB
[99888.399098] 2076012 pages RAM
[99888.399099] 0 pages HighMem/MovableOnly
[99888.399100] 52657 pages reserved
[99888.399101] 4096 pages cma reserved
[99888.399102] 0 pages hwpoisoned
[99888.399103] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapen=
ts oom_score_adj name
[99888.399107] [  429]     0   429    10643       67      21       3      3=
42         -1000 udevd
[99888.399109] [  802]     0   802     4826       22      14       3       =
35             0 irqbalance
[99888.399111] [  995]     0   995     6743        2      16       3       =
69             0 syslog-ng
[99888.399113] [  996]     0   996   139523      399      46       4      3=
32             0 syslog-ng
[99888.399115] [ 1027]     0  1027    15794       65      34       3      1=
45         -1000 sshd
[99888.399117] [ 1071]     0  1071    35627      215      17       4      1=
23             0 crond
[99888.399119] [ 1107]     0  1107    31552        0      10       3       =
22             0 mingetty
[99888.399120] [ 1108]     0  1108    31552        0      10       4       =
22             0 mingetty
[99888.399122] [ 1109]     0  1109    31552        0      10       3       =
21             0 mingetty
[99888.399124] [ 1147]     0  1147    36183      240      20       3      1=
35             0 tmux
[99888.399126] [ 1189]     0  1189    34030       68      16       3      1=
07             0 bash
[99888.399128] [ 1685]     0  1685    34030       70      16       3      1=
07             0 bash
[99888.399129] [ 1706]     0  1706    34030       76      16       3      1=
05             0 bash
[99888.399131] [ 1727]     0  1727    34030       43      15       3      1=
11             0 bash
[99888.399133] [ 1747]     0  1747    34030       71      15       3      1=
04             0 bash
[99888.399135] [ 1767]     0  1767    34030       76      14       3      1=
04             0 bash
[99888.399136] [ 1787]     0  1787    34030       76      17       3      1=
05             0 bash
[99888.399138] [ 1807]     0  1807    34067      295      15       3       =
47             0 bash
[99888.399140] [ 1827]     0  1827    34030       67      17       3      1=
10             0 bash
[99888.399141] [ 1847]     0  1847    34030       71      16       3      1=
03             0 bash
[99888.399143] [ 2168]     0  2168    93321    42988     132       4    156=
11             0 cp
[99888.399145] [ 2175]     0  2175    93321    43050     131       3    155=
49             0 cp
[99888.399147] [ 2178]     0  2178    93321    43034     132       3    155=
65             0 cp
[99888.399148] [ 2180]     0  2180    93321    43008     133       3    155=
91             0 cp
[99888.399150] [ 2182]     0  2182    93321    42950     132       3    156=
49             0 cp
[99888.399152] [ 2184]     0  2184    93321    43131     131       4    154=
65             0 cp
[99888.399154] [ 2186]     0  2186    93321    43037     132       3    155=
60             0 cp
[99888.399155] [ 2188]     0  2188    93321    43070     132       3    155=
28             0 cp
[99888.399157] [ 2192]     0  2192    93321    43072     131       3    155=
27             0 cp
[99888.399159] [ 2311]     0  2311    26920      740      57       3       =
 0             0 sshd
[99888.399161] [ 2315]     0  2315    34030      421      15       3       =
 0             0 bash
[99888.399163] Out of memory: Kill process 2180 (cp) score 7 or sacrifice c=
hild
[99888.399167] Killed process 2180 (cp) total-vm:373284kB, anon-rss:171708k=
B, file-rss:324kB, shmem-rss:0kB
[99888.416476] oom_reaper: reaped process 2180 (cp), now anon-rss:0kB, file=
=2Drss:0kB, shmem-rss:0kB
[103315.505488] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[103315.505492] kthreadd cpuset=3D/ mems_allowed=3D0
[103315.505496] CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[103315.505498] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[103315.505500]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[103315.505502]  ffff88021555fcf8 ffff880037dccc80 ffff88021555fb80 fffffff=
f811ffa2f
[103315.505504]  0000000000000000 ffff88021ea5a738 0000000100000000 ffff880=
215550cc0
[103315.505507] Call Trace:
[103315.505513]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[103315.505517]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[103315.505521]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[103315.505524]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[103315.505526]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[103315.505528]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[103315.505531]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[103315.505534]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[103315.505537]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[103315.505540]  [<ffffffff810b0b66>] ? pick_next_task_fair+0x306/0x4c0
[103315.505542]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[103315.505544]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[103315.505546]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[103315.505548]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[103315.505551]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[103315.505553]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[103315.505554] Mem-Info:
[103315.505559] active_anon:154510 inactive_anon:154514 isolated_anon:0
                 active_file:317774 inactive_file:43364 isolated_file:0
                 unevictable:0 dirty:11801 writeback:5212 unstable:0
                 slab_reclaimable:1112194 slab_unreclaimable:166028
                 mapped:1069 shmem:0 pagetables:1420 bounce:0
                 free:31143 free_pcp:0 free_cma:1
[103315.505562] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[103315.505567] lowmem_reserve[]: 0 3405 7866 7866
[103315.505570] Node 0 DMA32 free:59152kB min:29148kB low:36432kB high:4371=
6kB active_anon:222416kB inactive_anon:222416kB active_file:526844kB inacti=
ve_file:71144kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:18500kB writeback:866=
8kB mapped:1276kB shmem:0kB slab_reclaimable:2066852kB slab_unreclaimable:2=
77200kB kernel_stack:880kB pagetables:2056kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[103315.505575] lowmem_reserve[]: 0 0 4460 4460
[103315.505577] Node 0 Normal free:50060kB min:38304kB low:47880kB high:574=
56kB active_anon:395624kB inactive_anon:395640kB active_file:744252kB inact=
ive_file:102312kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:4716544kB managed:4583644kB mlocked:0kB dirty:28=
704kB writeback:12180kB mapped:3000kB shmem:0kB slab_reclaimable:2381924kB =
slab_unreclaimable:386912kB kernel_stack:1536kB=20
pagetables:3624kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_c=
ma:4kB writeback_tmp:0kB pages_scanned:72 all_unreclaimable? no
[103315.505582] lowmem_reserve[]: 0 0 0 0
[103315.505585] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[103315.505593] Node 0 DMA32: 11422*4kB (UME) 1701*8kB (UME) 0*16kB 0*32kB =
0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 59296kB
[103315.505600] Node 0 Normal: 12073*4kB (UMEHC) 134*8kB (UMEH) 23*16kB (H)=
 9*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 50148kB
[103315.505609] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[103315.505610] 362829 total pagecache pages
[103315.505612] 1683 pages in swap cache
[103315.505613] Swap cache stats: add 1781379, delete 1779696, find 800685/=
962025
[103315.505614] Free swap  =3D 20301020kB
[103315.505615] Total swap =3D 20955132kB
[103315.505616] 2076012 pages RAM
[103315.505617] 0 pages HighMem/MovableOnly
[103315.505618] 52657 pages reserved
[103315.505619] 4096 pages cma reserved
[103315.505620] 0 pages hwpoisoned
[103315.505620] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[103315.505625] [  429]     0   429    10643       68      21       3      =
341         -1000 udevd
[103315.505627] [  802]     0   802     4826       23      14       3      =
 34             0 irqbalance
[103315.505629] [  995]     0   995     6743        3      16       3      =
 68             0 syslog-ng
[103315.505631] [  996]     0   996   139523      403      46       4      =
331             0 syslog-ng
[103315.505633] [ 1027]     0  1027    15794       63      34       3      =
144         -1000 sshd
[103315.505635] [ 1071]     0  1071    35627      215      17       4      =
123             0 crond
[103315.505637] [ 1107]     0  1107    31552        0      10       3      =
 21             0 mingetty
[103315.505638] [ 1108]     0  1108    31552        0      10       4      =
 21             0 mingetty
[103315.505640] [ 1109]     0  1109    31552        0      10       3      =
 20             0 mingetty
[103315.505642] [ 1147]     0  1147    36183      543      20       3      =
123             0 tmux
[103315.505644] [ 1189]     0  1189    34030       69      16       3      =
106             0 bash
[103315.505645] [ 1685]     0  1685    34030       71      16       3      =
106             0 bash
[103315.505662] [ 1706]     0  1706    34067      516      16       3      =
 54             0 bash
[103315.505664] [ 1727]     0  1727    34030       43      15       3      =
110             0 bash
[103315.505666] [ 1747]     0  1747    34030       72      15       3      =
103             0 bash
[103315.505668] [ 1767]     0  1767    34030       77      14       3      =
103             0 bash
[103315.505669] [ 1787]     0  1787    34030       77      17       3      =
104             0 bash
[103315.505671] [ 1807]     0  1807    34067      295      15       3      =
 47             0 bash
[103315.505673] [ 1827]     0  1827    34030       67      17       3      =
109             0 bash
[103315.505674] [ 1847]     0  1847    34030       72      16       3      =
102             0 bash
[103315.505676] [ 2168]     0  2168    93321    38614     132       4    19=
985             0 cp
[103315.505678] [ 2175]     0  2175    93321    37966     131       3    20=
633             0 cp
[103315.505680] [ 2178]     0  2178    93321    38102     132       3    20=
497             0 cp
[103315.505682] [ 2182]     0  2182    93321    38600     132       3    19=
999             0 cp
[103315.505683] [ 2184]     0  2184    93321    38795     131       4    19=
801             0 cp
[103315.505685] [ 2186]     0  2186    93321    38546     132       3    20=
051             0 cp
[103315.505687] [ 2188]     0  2188    93321    38707     132       3    19=
891             0 cp
[103315.505689] [ 2192]     0  2192    93321    38282     131       3    20=
317             0 cp
[103315.505691] Out of memory: Kill process 2168 (cp) score 7 or sacrifice =
child
[103315.505695] Killed process 2168 (cp) total-vm:373284kB, anon-rss:154132=
kB, file-rss:324kB, shmem-rss:0kB
[103315.520030] oom_reaper: reaped process 2168 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[104400.507608] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[104400.507612] kthreadd cpuset=3D/ mems_allowed=3D0
[104400.507617] CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[104400.507618] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[104400.507620]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[104400.507623]  ffff88021555fcf8 ffff880037e06600 ffff88021555fb80 fffffff=
f811ffa2f
[104400.507625]  0000000000000000 00000000006ecfba ffff880214ab8cc0 ffff880=
21555fbe0
[104400.507628] Call Trace:
[104400.507634]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[104400.507638]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[104400.507642]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[104400.507645]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[104400.507647]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[104400.507649]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[104400.507652]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[104400.507655]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[104400.507657]  [<ffffffff810a704c>] ? select_task_rq_fair+0x33c/0x6f0
[104400.507661]  [<ffffffff8102ed89>] ? sched_clock+0x9/0x10
[104400.507663]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[104400.507666]  [<ffffffff810b096f>] ? pick_next_task_fair+0x10f/0x4c0
[104400.507668]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[104400.507670]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[104400.507672]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[104400.507674]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[104400.507677]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[104400.507679]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[104400.507680] Mem-Info:
[104400.507684] active_anon:129371 inactive_anon:129450 isolated_anon:0
                 active_file:316704 inactive_file:55666 isolated_file:0
                 unevictable:0 dirty:29991 writeback:0 unstable:0
                 slab_reclaimable:1145618 slab_unreclaimable:171545
                 mapped:1064 shmem:0 pagetables:1288 bounce:0
                 free:31319 free_pcp:0 free_cma:0
[104400.507688] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[104400.507693] lowmem_reserve[]: 0 3405 7866 7866
[104400.507696] Node 0 DMA32 free:60480kB min:29148kB low:36432kB high:4371=
6kB active_anon:188336kB inactive_anon:188448kB active_file:518148kB inacti=
ve_file:92412kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:46972kB writeback:0kB=
 mapped:1284kB shmem:0kB slab_reclaimable:2115820kB slab_unreclaimable:2829=
64kB kernel_stack:832kB pagetables:1800kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:92 all_unreclaimable? no
[104400.507701] lowmem_reserve[]: 0 0 4460 4460
[104400.507703] Node 0 Normal free:49436kB min:38304kB low:47880kB high:574=
56kB active_anon:329148kB inactive_anon:329352kB active_file:748668kB inact=
ive_file:130252kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:4716544kB managed:4583644kB mlocked:0kB dirty:72=
992kB writeback:0kB mapped:2972kB shmem:0kB slab_reclaimable:2466652kB slab=
_unreclaimable:403216kB kernel_stack:1536kB pagetables:3352kB=20
unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_t=
mp:0kB pages_scanned:0 all_unreclaimable? no
[104400.507708] lowmem_reserve[]: 0 0 0 0
[104400.507710] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[104400.507718] Node 0 DMA32: 11384*4kB (UME) 1886*8kB (UME) 0*16kB 0*32kB =
0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 60624kB
[104400.507726] Node 0 Normal: 11072*4kB (UMEHC) 560*8kB (UMEH) 23*16kB (H)=
 9*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 49552kB
[104400.507735] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[104400.507736] 374745 total pagecache pages
[104400.507737] 2357 pages in swap cache
[104400.507739] Swap cache stats: add 1793838, delete 1791481, find 800745/=
962143
[104400.507740] Free swap  =3D 20331560kB
[104400.507741] Total swap =3D 20955132kB
[104400.507742] 2076012 pages RAM
[104400.507743] 0 pages HighMem/MovableOnly
[104400.507743] 52657 pages reserved
[104400.507744] 4096 pages cma reserved
[104400.507745] 0 pages hwpoisoned
[104400.507746] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[104400.507750] [  429]     0   429    10643       67      21       3      =
341         -1000 udevd
[104400.507753] [  802]     0   802     4826       23      14       3      =
 34             0 irqbalance
[104400.507755] [  995]     0   995     6743        3      16       3      =
 68             0 syslog-ng
[104400.507757] [  996]     0   996   139523      399      46       4      =
331             0 syslog-ng
[104400.507759] [ 1027]     0  1027    15794       60      34       3      =
144         -1000 sshd
[104400.507761] [ 1071]     0  1071    35627      202      17       4      =
123             0 crond
[104400.507762] [ 1107]     0  1107    31552        0      10       3      =
 21             0 mingetty
[104400.507764] [ 1108]     0  1108    31552        0      10       4      =
 21             0 mingetty
[104400.507766] [ 1109]     0  1109    31552        0      10       3      =
 20             0 mingetty
[104400.507768] [ 1147]     0  1147    36183      533      20       3      =
123             0 tmux
[104400.507769] [ 1189]     0  1189    34030       68      16       3      =
106             0 bash
[104400.507771] [ 1685]     0  1685    34030       70      16       3      =
106             0 bash
[104400.507773] [ 1706]     0  1706    34067      515      16       3      =
 54             0 bash
[104400.507775] [ 1727]     0  1727    34030       42      15       3      =
110             0 bash
[104400.507776] [ 1747]     0  1747    34030       71      15       3      =
103             0 bash
[104400.507778] [ 1767]     0  1767    34030       76      14       3      =
103             0 bash
[104400.507780] [ 1787]     0  1787    34030       76      17       3      =
104             0 bash
[104400.507781] [ 1807]     0  1807    34067      293      15       3      =
 48             0 bash
[104400.507783] [ 1827]     0  1827    34030       66      17       3      =
109             0 bash
[104400.507785] [ 1847]     0  1847    34067      555      16       3      =
 52             0 bash
[104400.507787] [ 2175]     0  2175    93321    36122     131       3    22=
476             0 cp
[104400.507789] [ 2178]     0  2178    93321    36304     132       3    22=
294             0 cp
[104400.507790] [ 2182]     0  2182    93321    36798     132       3    21=
800             0 cp
[104400.507792] [ 2184]     0  2184    93321    37010     131       4    21=
585             0 cp
[104400.507794] [ 2186]     0  2186    93321    36757     132       3    21=
839             0 cp
[104400.507796] [ 2188]     0  2188    93321    37023     132       3    21=
574             0 cp
[104400.507797] [ 2192]     0  2192    93321    36581     131       3    22=
017             0 cp
[104400.507799] Out of memory: Kill process 2182 (cp) score 7 or sacrifice =
child
[104400.507803] Killed process 2182 (cp) total-vm:373284kB, anon-rss:146876=
kB, file-rss:316kB, shmem-rss:0kB
[104400.524060] oom_reaper: reaped process 2182 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[114824.060307] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[114824.060311] kthreadd cpuset=3D/ mems_allowed=3D0
[114824.060316] CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[114824.060317] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[114824.060320]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[114824.060322]  ffff88021555fcf8 ffff880037e05940 ffff88021555fb80 fffffff=
f811ffa2f
[114824.060325]  0000000000000000 ffff88021ea5a758 0000000100000000 ffff880=
215550cc0
[114824.060327] Call Trace:
[114824.060333]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[114824.060337]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[114824.060341]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[114824.060344]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[114824.060346]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[114824.060348]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[114824.060351]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[114824.060355]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[114824.060357]  [<ffffffff810a6f5a>] ? select_task_rq_fair+0x24a/0x6f0
[114824.060359]  [<ffffffff810a6051>] ? set_next_entity+0x71/0x920
[114824.060361]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[114824.060363]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[114824.060366]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[114824.060368]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[114824.060370]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[114824.060372]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[114824.060374]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[114824.060376]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[114824.060378] Mem-Info:
[114824.060403] active_anon:170168 inactive_anon:170168 isolated_anon:0
                 active_file:192892 inactive_file:133384 isolated_file:0
                 unevictable:0 dirty:37109 writeback:1 unstable:0
                 slab_reclaimable:1176088 slab_unreclaimable:109598
                 mapped:1142 shmem:1 pagetables:1229 bounce:0
                 free:30263 free_pcp:0 free_cma:0
[114824.060407] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[114824.060412] lowmem_reserve[]: 0 3405 7866 7866
[114824.060415] Node 0 DMA32 free:56812kB min:29148kB low:36432kB high:4371=
6kB active_anon:280300kB inactive_anon:280300kB active_file:267644kB inacti=
ve_file:110600kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:3571520kB managed:3494416kB mlocked:0kB dirty:58=
252kB writeback:4kB mapped:936kB shmem:4kB slab_reclaimable:2278424kB slab_=
unreclaimable:177192kB kernel_stack:848kB pagetables:1684kB=20
unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_t=
mp:0kB pages_scanned:104 all_unreclaimable? no
[114824.060420] lowmem_reserve[]: 0 0 4460 4460
[114824.060423] Node 0 Normal free:48880kB min:38304kB low:47880kB high:574=
56kB active_anon:400372kB inactive_anon:400372kB active_file:503924kB inact=
ive_file:422936kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:4716544kB managed:4583644kB mlocked:0kB dirty:90=
184kB writeback:0kB mapped:3632kB shmem:0kB slab_reclaimable:2425928kB slab=
_unreclaimable:261200kB kernel_stack:1568kB pagetables:3232kB=20
unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_t=
mp:0kB pages_scanned:0 all_unreclaimable? no
[114824.060428] lowmem_reserve[]: 0 0 0 0
[114824.060430] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[114824.060438] Node 0 DMA32: 11003*4kB (UME) 1614*8kB (UME) 0*16kB 0*32kB =
0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 56924kB
[114824.060446] Node 0 Normal: 9279*4kB (UMEH) 1414*8kB (UMEH) 9*16kB (H) 9=
*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=
 48988kB
[114824.060455] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[114824.060456] 326440 total pagecache pages
[114824.060457] 164 pages in swap cache
[114824.060459] Swap cache stats: add 2003186, delete 2003022, find 956629/=
1271347
[114824.060460] Free swap  =3D 20898976kB
[114824.060461] Total swap =3D 20955132kB
[114824.060462] 2076012 pages RAM
[114824.060463] 0 pages HighMem/MovableOnly
[114824.060464] 52657 pages reserved
[114824.060465] 4096 pages cma reserved
[114824.060465] 0 pages hwpoisoned
[114824.060466] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[114824.060470] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[114824.060473] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[114824.060475] [  995]     0   995     6743        2      16       3      =
 69             0 syslog-ng
[114824.060477] [  996]     0   996   139523      498      46       4      =
388             0 syslog-ng
[114824.060479] [ 1027]     0  1027    15794       31      34       3      =
165         -1000 sshd
[114824.060481] [ 1071]     0  1071    35627      100      17       4      =
134             0 crond
[114824.060483] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[114824.060485] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[114824.060487] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[114824.060488] [ 1147]     0  1147    36183      513      20       3      =
129             0 tmux
[114824.060490] [ 1189]     0  1189    34030       67      16       3      =
107             0 bash
[114824.060492] [ 1685]     0  1685    34030       69      16       3      =
107             0 bash
[114824.060493] [ 1706]     0  1706    34067        0      16       3      =
120             0 bash
[114824.060495] [ 1727]     0  1727    34067       66      15       3      =
114             0 bash
[114824.060497] [ 1747]     0  1747    34030       70      15       3      =
104             0 bash
[114824.060499] [ 1767]     0  1767    34030       75      14       3      =
104             0 bash
[114824.060501] [ 1787]     0  1787    34030       75      17       3      =
105             0 bash
[114824.060503] [ 1807]     0  1807    34067       43      15       3      =
110             0 bash
[114824.060504] [ 1827]     0  1827    34030       66      17       3      =
110             0 bash
[114824.060506] [ 1847]     0  1847    34067       14      16       3      =
116             0 bash
[114824.060508] [ 2175]     0  2175    93321    56767     131       3     1=
857             0 cp
[114824.060510] [ 2178]     0  2178    93321    56747     132       3     1=
881             0 cp
[114824.060512] [ 2184]     0  2184    93321    56765     131       4     1=
857             0 cp
[114824.060514] [ 2186]     0  2186    93321    56701     132       3     1=
922             0 cp
[114824.060515] [ 2188]     0  2188    93321    56760     132       3     1=
867             0 cp
[114824.060517] [ 2192]     0  2192    93321    56736     131       3     1=
887             0 cp
[114824.060519] [ 2523]     0  2523    26953      160      57       3      =
229             0 sshd
[114824.060521] [ 2527]     0  2527    34030      560      16       3      =
 33             0 bash
[114824.060523] Out of memory: Kill process 2178 (cp) score 7 or sacrifice =
child
[114824.060527] Killed process 2178 (cp) total-vm:373284kB, anon-rss:226548=
kB, file-rss:440kB, shmem-rss:0kB
[114824.079281] oom_reaper: reaped process 2178 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[151216.490600] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[151216.490604] kthreadd cpuset=3D/ mems_allowed=3D0
[151216.490610] CPU: 0 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[151216.490611] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[151216.490613]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[151216.490616]  ffff88021555fcf8 ffff8802157c72c0 ffff88021555fb80 fffffff=
f811ffa2f
[151216.490619]  0000000000000000 ffff88021ea1a738 0000000100000000 ffff880=
215550cc0
[151216.490621] Call Trace:
[151216.490630]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[151216.490634]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[151216.490638]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[151216.490642]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[151216.490645]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[151216.490647]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[151216.490651]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[151216.490655]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[151216.490657]  [<ffffffff810a6f5a>] ? select_task_rq_fair+0x24a/0x6f0
[151216.490660]  [<ffffffff810a6051>] ? set_next_entity+0x71/0x920
[151216.490663]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[151216.490666]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[151216.490669]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[151216.490671]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[151216.490674]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[151216.490676]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[151216.490679]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[151216.490682]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[151216.490683] Mem-Info:
[151216.490688] active_anon:253 inactive_anon:4920 isolated_anon:0
                 active_file:539341 inactive_file:179851 isolated_file:26
                 unevictable:0 dirty:17113 writeback:0 unstable:0
                 slab_reclaimable:1219251 slab_unreclaimable:7744
                 mapped:961 shmem:0 pagetables:437 bounce:0
                 free:32148 free_pcp:26 free_cma:0
[151216.490691] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[151216.490697] lowmem_reserve[]: 0 3405 7866 7866
[151216.490700] Node 0 DMA32 free:63024kB min:29148kB low:36432kB high:4371=
6kB active_anon:844kB inactive_anon:5516kB active_file:835900kB inactive_fi=
le:278828kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:26288kB writeback:0kB=
 mapped:1100kB shmem:0kB slab_reclaimable:2259972kB slab_unreclaimable:1251=
6kB kernel_stack:800kB pagetables:456kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[151216.490705] lowmem_reserve[]: 0 0 4460 4460
[151216.490707] Node 0 Normal free:50208kB min:38304kB low:47880kB high:574=
56kB active_anon:168kB inactive_anon:14164kB active_file:1321464kB inactive=
_file:440576kB unevictable:0kB isolated(anon):0kB isolated(file):104kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:42164kB writeback:0kB=
 mapped:2744kB shmem:0kB slab_reclaimable:2617032kB slab_unreclaimable:1846=
0kB kernel_stack:1552kB pagetables:1292kB unstable:0kB=20
bounce:0kB free_pcp:104kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB page=
s_scanned:0 all_unreclaimable? no
[151216.490712] lowmem_reserve[]: 0 0 0 0
[151216.490715] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[151216.490723] Node 0 DMA32: 15436*4kB (UME) 161*8kB (UME) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 63032kB
[151216.490731] Node 0 Normal: 11971*4kB (UMEH) 214*8kB (UMEH) 30*16kB (H) =
10*32kB (H) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 5=
0396kB
[151216.490740] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[151216.490741] 719449 total pagecache pages
[151216.490742] 231 pages in swap cache
[151216.490744] Swap cache stats: add 2387015, delete 2386784, find 1154236=
/1660746
[151216.490745] Free swap  =3D 20945800kB
[151216.490746] Total swap =3D 20955132kB
[151216.490747] 2076012 pages RAM
[151216.490748] 0 pages HighMem/MovableOnly
[151216.490749] 52657 pages reserved
[151216.490750] 4096 pages cma reserved
[151216.490751] 0 pages hwpoisoned
[151216.490752] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[151216.490758] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[151216.490761] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[151216.490764] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[151216.490766] [  996]     0   996   139523      220      46       4      =
381             0 syslog-ng
[151216.490768] [ 1027]     0  1027    15794      110      34       3      =
139         -1000 sshd
[151216.490770] [ 1071]     0  1071    35627       96      17       4      =
127             0 crond
[151216.490772] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[151216.490774] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[151216.490776] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[151216.490778] [ 1147]     0  1147    36183      105      20       3      =
126             0 tmux
[151216.490780] [ 1189]     0  1189    34067       58      16       3      =
 67             0 bash
[151216.490782] [ 1685]     0  1685    34030       43      16       3      =
 91             0 bash
[151216.490784] [ 1706]     0  1706    34067      146      16       3      =
 60             0 bash
[151216.490786] [ 1727]     0  1727    34067      154      15       3      =
 46             0 bash
[151216.490788] [ 1747]     0  1747    34030       29      15       3      =
 91             0 bash
[151216.490790] [ 1767]     0  1767    34030       98      14       3      =
 84             0 bash
[151216.490792] [ 1787]     0  1787    34030        0      17       3      =
105             0 bash
[151216.490793] [ 1807]     0  1807    34067      332      15       3      =
 39             0 bash
[151216.490795] [ 1827]     0  1827    34030       97      17       3      =
 81             0 bash
[151216.490797] [ 1847]     0  1847    34067      111      16       3      =
 74             0 bash
[151216.490799] [ 2873]     0  2873    32428     1006      12       3      =
  8             0 rm
[151216.490801] [ 2875]     0  2875    33138     1688      16       3      =
  0             0 rm
[151216.490803] [ 2876]     0  2876    32428     1011      13       4      =
  0             0 rm
[151216.490804] [ 2877]     0  2877    32428      907      12       3      =
105             0 rm
[151216.490807] [ 2938]     0  2938    35025      642      17       3      =
  0             0 cp
[151216.490808] Out of memory: Kill process 2875 (rm) score 0 or sacrifice =
child
[151216.490812] Killed process 2875 (rm) total-vm:132552kB, anon-rss:6372kB=
, file-rss:380kB, shmem-rss:0kB
[156354.563329] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[156354.563332] kthreadd cpuset=3D/ mems_allowed=3D0
[156354.563337] CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[156354.563339] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[156354.563341]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[156354.563344]  ffff88021555fcf8 ffff880037eb3300 ffff88021555fb80 fffffff=
f811ffa2f
[156354.563346]  0000000000000000 ffff88021ea5a758 0000000100000000 ffff880=
215550cc0
[156354.563348] Call Trace:
[156354.563355]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[156354.563358]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[156354.563362]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[156354.563365]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[156354.563367]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[156354.563369]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[156354.563372]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[156354.563375]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[156354.563378]  [<ffffffff810a704c>] ? select_task_rq_fair+0x33c/0x6f0
[156354.563380]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[156354.563383]  [<ffffffff810b096f>] ? pick_next_task_fair+0x10f/0x4c0
[156354.563385]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[156354.563387]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[156354.563389]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[156354.563391]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[156354.563394]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[156354.563396]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[156354.563397] Mem-Info:
[156354.563401] active_anon:146316 inactive_anon:146321 isolated_anon:0
                 active_file:158155 inactive_file:76229 isolated_file:0
                 unevictable:0 dirty:28542 writeback:1 unstable:0
                 slab_reclaimable:1325181 slab_unreclaimable:101640
                 mapped:628 shmem:0 pagetables:1028 bounce:0
                 free:32305 free_pcp:0 free_cma:0
[156354.563405] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[156354.563410] lowmem_reserve[]: 0 3405 7866 7866
[156354.563413] Node 0 DMA32 free:64560kB min:29148kB low:36432kB high:4371=
6kB active_anon:230256kB inactive_anon:230256kB active_file:216580kB inacti=
ve_file:88052kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:37252kB writeback:0kB=
 mapped:1088kB shmem:0kB slab_reclaimable:2485012kB slab_unreclaimable:1431=
08kB kernel_stack:816kB pagetables:1380kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[156354.563418] lowmem_reserve[]: 0 0 4460 4460
[156354.563420] Node 0 Normal free:49300kB min:38304kB low:47880kB high:574=
56kB active_anon:355008kB inactive_anon:355028kB active_file:416040kB inact=
ive_file:216864kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:4716544kB managed:4583644kB mlocked:0kB dirty:76=
916kB writeback:4kB mapped:1424kB shmem:0kB slab_reclaimable:2815712kB slab=
_unreclaimable:263452kB kernel_stack:1536kB pagetables:2732kB=20
unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_t=
mp:0kB pages_scanned:36 all_unreclaimable? no
[156354.563425] lowmem_reserve[]: 0 0 0 0
[156354.563428] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[156354.563436] Node 0 DMA32: 11826*4kB (UME) 2177*8kB (UM) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 64720kB
[156354.563443] Node 0 Normal: 11655*4kB (UMEH) 216*8kB (UMEH) 33*16kB (H) =
15*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 49484kB
[156354.563452] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[156354.563453] 234502 total pagecache pages
[156354.563455] 99 pages in swap cache
[156354.563456] Swap cache stats: add 2399563, delete 2399464, find 1160423=
/1672484
[156354.563457] Free swap  =3D 20944064kB
[156354.563458] Total swap =3D 20955132kB
[156354.563459] 2076012 pages RAM
[156354.563460] 0 pages HighMem/MovableOnly
[156354.563461] 52657 pages reserved
[156354.563462] 4096 pages cma reserved
[156354.563463] 0 pages hwpoisoned
[156354.563464] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[156354.563468] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[156354.563471] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[156354.563473] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[156354.563475] [  996]     0   996   139523      543      46       4      =
393             0 syslog-ng
[156354.563477] [ 1027]     0  1027    15794        0      34       3      =
169         -1000 sshd
[156354.563479] [ 1071]     0  1071    35627      258      17       4      =
123             0 crond
[156354.563481] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[156354.563482] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[156354.563484] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[156354.563486] [ 1147]     0  1147    36183       26      20       3      =
205             0 tmux
[156354.563488] [ 1189]     0  1189    34067       41      16       3      =
112             0 bash
[156354.563489] [ 1685]     0  1685    34030       14      16       3      =
110             0 bash
[156354.563491] [ 1706]     0  1706    34067        0      16       3      =
113             0 bash
[156354.563493] [ 1727]     0  1727    34067        0      15       3      =
110             0 bash
[156354.563494] [ 1747]     0  1747    34030        0      15       3      =
108             0 bash
[156354.563496] [ 1767]     0  1767    34030       59      14       3      =
104             0 bash
[156354.563498] [ 1787]     0  1787    34030        0      17       3      =
122             0 bash
[156354.563500] [ 1807]     0  1807    34067       73      15       3      =
108             0 bash
[156354.563501] [ 1827]     0  1827    34030       44      17       3      =
104             0 bash
[156354.563503] [ 1847]     0  1847    34067       77      16       3      =
102             0 bash
[156354.563505] [ 2938]     0  2938    93321    58582     132       4      =
 38             0 cp
[156354.563507] [ 2940]     0  2940    93321    58586     131       3      =
 37             0 cp
[156354.563509] [ 2946]     0  2946    93321    58582     133       4      =
 42             0 cp
[156354.563510] [ 2950]     0  2950    93321    58568     133       3      =
 53             0 cp
[156354.563512] [ 2961]     0  2961    93321    58597     132       3      =
 25             0 cp
[156354.563514] Out of memory: Kill process 2946 (cp) score 7 or sacrifice =
child
[156354.563518] Killed process 2946 (cp) total-vm:373284kB, anon-rss:233908=
kB, file-rss:420kB, shmem-rss:0kB
[156354.579077] oom_reaper: reaped process 2946 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[161685.857568] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[161685.857571] kthreadd cpuset=3D/ mems_allowed=3D0
[161685.857576] CPU: 0 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[161685.857578] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[161685.857579]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[161685.857582]  ffff88021555fcf8 ffff880215552640 ffff88021555fb80 fffffff=
f811ffa2f
[161685.857584]  0000000000000000 ffff88021ea1a738 0000000100000000 ffff880=
215550cc0
[161685.857586] Call Trace:
[161685.857593]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[161685.857596]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[161685.857600]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[161685.857603]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[161685.857605]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[161685.857608]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[161685.857610]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[161685.857614]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[161685.857616]  [<ffffffff810a6051>] ? set_next_entity+0x71/0x920
[161685.857619]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[161685.857621]  [<ffffffff810b0c26>] ? pick_next_task_fair+0x3c6/0x4c0
[161685.857623]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[161685.857625]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[161685.857627]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[161685.857629]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[161685.857632]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[161685.857634]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[161685.857635] Mem-Info:
[161685.857640] active_anon:99816 inactive_anon:99848 isolated_anon:0
                 active_file:218925 inactive_file:46196 isolated_file:0
                 unevictable:0 dirty:32511 writeback:1 unstable:0
                 slab_reclaimable:1357983 slab_unreclaimable:128520
                 mapped:882 shmem:0 pagetables:895 bounce:0
                 free:33388 free_pcp:0 free_cma:0
[161685.857643] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[161685.857648] lowmem_reserve[]: 0 3405 7866 7866
[161685.857651] Node 0 DMA32 free:67404kB min:29148kB low:36432kB high:4371=
6kB active_anon:153436kB inactive_anon:153440kB active_file:308352kB inacti=
ve_file:74200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:44768kB writeback:0kB=
 mapped:992kB shmem:0kB slab_reclaimable:2515164kB slab_unreclaimable:18482=
0kB kernel_stack:800kB pagetables:1128kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[161685.857656] lowmem_reserve[]: 0 0 4460 4460
[161685.857658] Node 0 Normal free:50788kB min:38304kB low:47880kB high:574=
56kB active_anon:245828kB inactive_anon:245952kB active_file:567348kB inact=
ive_file:110584kB unevictable:0kB isolated(anon):0kB=20
isolated(file):0kB present:4716544kB managed:4583644kB mlocked:0kB dirty:85=
276kB writeback:4kB mapped:2536kB shmem:0kB slab_reclaimable:2916768kB slab=
_unreclaimable:329260kB kernel_stack:1536kB pagetables:2452kB=20
unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_t=
mp:0kB pages_scanned:16 all_unreclaimable? no
[161685.857663] lowmem_reserve[]: 0 0 0 0
[161685.857665] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[161685.857674] Node 0 DMA32: 11830*4kB (UME) 2525*8kB (UME) 0*16kB 0*32kB =
0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 67520kB
[161685.857681] Node 0 Normal: 12104*4kB (UMEH) 160*8kB (UMEH) 35*16kB (H) =
15*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 50864kB
[161685.857690] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[161685.857691] 267802 total pagecache pages
[161685.857692] 2654 pages in swap cache
[161685.857694] Swap cache stats: add 2436802, delete 2434148, find 1160526=
/1672666
[161685.857695] Free swap  =3D 20795896kB
[161685.857696] Total swap =3D 20955132kB
[161685.857697] 2076012 pages RAM
[161685.857698] 0 pages HighMem/MovableOnly
[161685.857699] 52657 pages reserved
[161685.857699] 4096 pages cma reserved
[161685.857700] 0 pages hwpoisoned
[161685.857701] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[161685.857705] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[161685.857708] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[161685.857710] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[161685.857712] [  996]     0   996   139523      501      46       4      =
388             0 syslog-ng
[161685.857714] [ 1027]     0  1027    15794        0      34       3      =
169         -1000 sshd
[161685.857716] [ 1071]     0  1071    35627      258      17       4      =
123             0 crond
[161685.857718] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[161685.857719] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[161685.857721] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[161685.857723] [ 1147]     0  1147    36183      188      20       3      =
177             0 tmux
[161685.857725] [ 1189]     0  1189    34067       41      16       3      =
112             0 bash
[161685.857726] [ 1685]     0  1685    34030       14      16       3      =
110             0 bash
[161685.857728] [ 1706]     0  1706    34067      382      16       3      =
 65             0 bash
[161685.857730] [ 1727]     0  1727    34067        0      15       3      =
110             0 bash
[161685.857732] [ 1747]     0  1747    34030        0      15       3      =
108             0 bash
[161685.857733] [ 1767]     0  1767    34030       59      14       3      =
104             0 bash
[161685.857735] [ 1787]     0  1787    34030        0      17       3      =
122             0 bash
[161685.857737] [ 1807]     0  1807    34067       72      15       3      =
108             0 bash
[161685.857738] [ 1827]     0  1827    34030       44      17       3      =
104             0 bash
[161685.857740] [ 1847]     0  1847    34067       71      16       3      =
108             0 bash
[161685.857742] [ 2938]     0  2938    93321    46086     132       4    12=
515             0 cp
[161685.857744] [ 2940]     0  2940    93321    46198     131       3    12=
406             0 cp
[161685.857746] [ 2950]     0  2950    93321    46250     133       3    12=
352             0 cp
[161685.857748] [ 2961]     0  2961    93321    58576     132       3      =
 27             0 cp
[161685.857749] Out of memory: Kill process 2961 (cp) score 7 or sacrifice =
child
[161685.857753] Killed process 2961 (cp) total-vm:373284kB, anon-rss:233968=
kB, file-rss:336kB, shmem-rss:0kB
[161685.873174] oom_reaper: reaped process 2961 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[183319.644491] syslog-ng invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERN=
EL_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[183319.644495] syslog-ng cpuset=3D/ mems_allowed=3D0
[183319.644499] CPU: 0 PID: 996 Comm: syslog-ng Not tainted 4.7.0-1 #1
[183319.644501] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[183319.644503]  0000000000000286 0000000095b6fb50 ffff8800d579bb40 fffffff=
f81335d0e
[183319.644505]  ffff8800d579bd28 ffff880214abbfc0 ffff8800d579bbb0 fffffff=
f811ffa2f
[183319.644508]  0000000000000000 ffff88021ea1a758 0000000100000000 ffff880=
21473bfc0
[183319.644510] Call Trace:
[183319.644516]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[183319.644519]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[183319.644524]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[183319.644527]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[183319.644528]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[183319.644531]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[183319.644534]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[183319.644537]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[183319.644541]  [<ffffffff81249750>] ? ep_ptable_queue_proc+0xa0/0xa0
[183319.644543]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[183319.644546]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[183319.644548]  [<ffffffff81249ab7>] ? ep_remove+0xa7/0xc0
[183319.644550]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[183319.644553]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[183319.644555]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[183319.644558]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[183319.644560]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[183319.644562] Mem-Info:
[183319.644566] active_anon:364 inactive_anon:412 isolated_anon:0
                 active_file:331582 inactive_file:169068 isolated_file:0
                 unevictable:0 dirty:0 writeback:0 unstable:0
                 slab_reclaimable:1423339 slab_unreclaimable:28200
                 mapped:2105 shmem:1 pagetables:458 bounce:0
                 free:34717 free_pcp:0 free_cma:0
[183319.644569] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[183319.644575] lowmem_reserve[]: 0 3405 7866 7866
[183319.644577] Node 0 DMA32 free:66448kB min:29148kB low:36432kB high:4371=
6kB active_anon:512kB inactive_anon:628kB active_file:347984kB inactive_fil=
e:348056kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:0kB writeback:0kB map=
ped:3556kB shmem:0kB slab_reclaimable:2652812kB slab_unreclaimable:41156kB =
kernel_stack:800kB pagetables:500kB unstable:0kB bounce:0kB=20
free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 a=
ll_unreclaimable? no
[183319.644582] lowmem_reserve[]: 0 0 4460 4460
[183319.644585] Node 0 Normal free:57060kB min:38304kB low:47880kB high:574=
56kB active_anon:944kB inactive_anon:1020kB active_file:978344kB inactive_f=
ile:328216kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:0kB writeback:0kB map=
ped:4864kB shmem:4kB slab_reclaimable:3040544kB slab_unreclaimable:71644kB =
kernel_stack:1504kB pagetables:1332kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:84 all_unreclaimable? no
[183319.644590] lowmem_reserve[]: 0 0 0 0
[183319.644592] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[183319.644600] Node 0 DMA32: 16591*4kB (UME) 22*8kB (UME) 0*16kB 0*32kB 0*=
64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 66540kB
[183319.644607] Node 0 Normal: 13567*4kB (UMEH) 200*8kB (UMH) 28*16kB (H) 1=
9*32kB (H) 4*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 57180kB
[183319.644616] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[183319.644617] 500819 total pagecache pages
[183319.644619] 165 pages in swap cache
[183319.644620] Swap cache stats: add 2625078, delete 2624913, find 1269576=
/1887152
[183319.644621] Free swap  =3D 20945520kB
[183319.644622] Total swap =3D 20955132kB
[183319.644623] 2076012 pages RAM
[183319.644624] 0 pages HighMem/MovableOnly
[183319.644625] 52657 pages reserved
[183319.644626] 4096 pages cma reserved
[183319.644627] 0 pages hwpoisoned
[183319.644628] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[183319.644632] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[183319.644634] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[183319.644636] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[183319.644638] [  996]     0   996   139523      286      46       4      =
401             0 syslog-ng
[183319.644640] [ 1027]     0  1027    15794      266      34       3      =
140         -1000 sshd
[183319.644642] [ 1071]     0  1071    35627      158      17       4      =
123             0 crond
[183319.644644] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[183319.644646] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[183319.644647] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[183319.644649] [ 1147]     0  1147    36183      184      20       3      =
173             0 tmux
[183319.644651] [ 1189]     0  1189    34067      282      16       3      =
 77             0 bash
[183319.644653] [ 1685]     0  1685    34030       13      16       3      =
110             0 bash
[183319.644654] [ 1706]     0  1706    34067        5      16       3      =
117             0 bash
[183319.644656] [ 1727]     0  1727    34067      388      15       3      =
 64             0 bash
[183319.644658] [ 1747]     0  1747    34030        0      15       3      =
108             0 bash
[183319.644660] [ 1767]     0  1767    34030       58      14       3      =
104             0 bash
[183319.644661] [ 1787]     0  1787    34030        0      17       3      =
122             0 bash
[183319.644663] [ 1807]     0  1807    34067      344      15       3      =
 67             0 bash
[183319.644665] [ 1827]     0  1827    34030       43      17       3      =
104             0 bash
[183319.644666] [ 1847]     0  1847    34067       24      16       3      =
114             0 bash
[183319.644669] [ 3174]     0  3174    26584     1574      55       3      =
  0             0 sshd
[183319.644671] [ 3175]    40  3175    16130     1077      36       3      =
  0             0 sshd
[183319.644672] Out of memory: Kill process 3174 (sshd) score 0 or sacrific=
e child
[183319.644679] Killed process 3175 (sshd) total-vm:64520kB, anon-rss:728kB=
, file-rss:3580kB, shmem-rss:0kB
[183322.306535] bash invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL_AC=
COUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[183322.306539] bash cpuset=3D/ mems_allowed=3D0
[183322.306544] CPU: 1 PID: 3180 Comm: bash Not tainted 4.7.0-1 #1
[183322.306546] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[183322.306547]  0000000000000286 00000000c19c5dff ffff88012abd7b40 fffffff=
f81335d0e
[183322.306550]  ffff88012abd7d28 ffff880214abbfc0 ffff88012abd7bb0 fffffff=
f811ffa2f
[183322.306552]  0000000000000000 ffff88021ea5a738 0000000100000000 ffff880=
214abd940
[183322.306555] Call Trace:
[183322.306561]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[183322.306564]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[183322.306568]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[183322.306571]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[183322.306573]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[183322.306576]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[183322.306578]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[183322.306582]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[183322.306585]  [<ffffffff812129f6>] ? getname_flags+0x56/0x1f0
[183322.306588]  [<ffffffff811dff4d>] ? kmem_cache_alloc+0x1bd/0x1d0
[183322.306591]  [<ffffffff8120513c>] ? get_empty_filp+0x5c/0x1c0
[183322.306593]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[183322.306596]  [<ffffffff810846d6>] ? __set_current_blocked+0x36/0x50
[183322.306598]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[183322.306601]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[183322.306604]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[183322.306606] Mem-Info:
[183322.306610] active_anon:314 inactive_anon:486 isolated_anon:0
                 active_file:331446 inactive_file:167911 isolated_file:0
                 unevictable:0 dirty:4 writeback:0 unstable:0
                 slab_reclaimable:1423168 slab_unreclaimable:27810
                 mapped:2134 shmem:0 pagetables:410 bounce:0
                 free:36577 free_pcp:0 free_cma:0
[183322.306613] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[183322.306618] lowmem_reserve[]: 0 3405 7866 7866
[183322.306621] Node 0 DMA32 free:71020kB min:29148kB low:36432kB high:4371=
6kB active_anon:0kB inactive_anon:556kB active_file:347784kB inactive_file:=
345244kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:0kB writeback:0kB map=
ped:3200kB shmem:0kB slab_reclaimable:2652128kB slab_unreclaimable:41140kB =
kernel_stack:784kB pagetables:360kB unstable:0kB bounce:0kB=20
free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 a=
ll_unreclaimable? no
[183322.306626] lowmem_reserve[]: 0 0 4460 4460
[183322.306628] Node 0 Normal free:59928kB min:38304kB low:47880kB high:574=
56kB active_anon:1256kB inactive_anon:1388kB active_file:978000kB inactive_=
file:326400kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:16kB writeback:0kB ma=
pped:5336kB shmem:0kB slab_reclaimable:3040544kB slab_unreclaimable:70100kB=
 kernel_stack:1520kB pagetables:1280kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:76 all_unreclaimable? no
[183322.306633] lowmem_reserve[]: 0 0 0 0
[183322.306635] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[183322.306644] Node 0 DMA32: 17405*4kB (UME) 180*8kB (UME) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 71060kB
[183322.306651] Node 0 Normal: 14534*4kB (UMEH) 69*8kB (UEH) 28*16kB (H) 19=
*32kB (H) 4*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=
 60000kB
[183322.306660] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[183322.306661] 499586 total pagecache pages
[183322.306663] 167 pages in swap cache
[183322.306664] Swap cache stats: add 2625086, delete 2624919, find 1269591=
/1887175
[183322.306665] Free swap  =3D 20945544kB
[183322.306666] Total swap =3D 20955132kB
[183322.306667] 2076012 pages RAM
[183322.306668] 0 pages HighMem/MovableOnly
[183322.306669] 52657 pages reserved
[183322.306670] 4096 pages cma reserved
[183322.306670] 0 pages hwpoisoned
[183322.306671] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[183322.306675] [  429]     0   429    10643       66      21       3      =
342         -1000 udevd
[183322.306678] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[183322.306680] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[183322.306682] [  996]     0   996   139523      508      46       4      =
386             0 syslog-ng
[183322.306684] [ 1027]     0  1027    15794      266      34       3      =
140         -1000 sshd
[183322.306686] [ 1071]     0  1071    35627      158      17       4      =
123             0 crond
[183322.306688] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[183322.306689] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[183322.306691] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[183322.306693] [ 1147]     0  1147    36183      184      20       3      =
173             0 tmux
[183322.306695] [ 1189]     0  1189    34067      282      16       3      =
 77             0 bash
[183322.306696] [ 1685]     0  1685    34030       13      16       3      =
110             0 bash
[183322.306698] [ 1706]     0  1706    34067        5      16       3      =
117             0 bash
[183322.306700] [ 1727]     0  1727    34067      388      15       3      =
 64             0 bash
[183322.306701] [ 1747]     0  1747    34030        0      15       3      =
108             0 bash
[183322.306703] [ 1767]     0  1767    34030       58      14       3      =
104             0 bash
[183322.306705] [ 1787]     0  1787    34030        0      17       3      =
122             0 bash
[183322.306707] [ 1807]     0  1807    34067      344      15       3      =
 67             0 bash
[183322.306708] [ 1827]     0  1827    34030       43      17       3      =
104             0 bash
[183322.306710] [ 1847]     0  1847    34067       24      16       3      =
114             0 bash
[183322.306712] [ 3178]     0  3178    26920     1625      54       3      =
  0             0 sshd
[183322.306714] [ 3180]     0  3180    33997      701      16       3      =
  0             0 bash
[183322.306715] Out of memory: Kill process 3178 (sshd) score 0 or sacrific=
e child
[183322.306719] Killed process 3180 (bash) total-vm:135988kB, anon-rss:204k=
B, file-rss:2600kB, shmem-rss:0kB
[196998.003984] kthreadd invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNE=
L_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[196998.003987] kthreadd cpuset=3D/ mems_allowed=3D0
[196998.003992] CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.7.0-1 #1
[196998.003994] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[196998.003996]  0000000000000286 00000000bb05bfd8 ffff88021555fb10 fffffff=
f81335d0e
[196998.003998]  ffff88021555fcf8 ffff88004732f2c0 ffff88021555fb80 fffffff=
f811ffa2f
[196998.004000]  0000000000000000 ffff88021ea5a758 0000000100000000 ffff880=
215550cc0
[196998.004003] Call Trace:
[196998.004009]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[196998.004013]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[196998.004017]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[196998.004020]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[196998.004022]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[196998.004024]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[196998.004027]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[196998.004030]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[196998.004033]  [<ffffffff810a704c>] ? select_task_rq_fair+0x33c/0x6f0
[196998.004035]  [<ffffffff8102ed89>] ? sched_clock+0x9/0x10
[196998.004038]  [<ffffffff81094460>] ? kthread_worker_fn+0x180/0x180
[196998.004041]  [<ffffffff810b096f>] ? pick_next_task_fair+0x10f/0x4c0
[196998.004043]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[196998.004045]  [<ffffffff8165945f>] ? __schedule+0x25f/0x6b0
[196998.004047]  [<ffffffff810745e9>] kernel_thread+0x29/0x30
[196998.004049]  [<ffffffff81094caa>] kthreadd+0x14a/0x190
[196998.004052]  [<ffffffff8165d3df>] ret_from_fork+0x1f/0x40
[196998.004054]  [<ffffffff81094b60>] ? kthread_create_on_cpu+0x60/0x60
[196998.004055] Mem-Info:
[196998.004059] active_anon:27769 inactive_anon:27832 isolated_anon:0
                 active_file:167299 inactive_file:114464 isolated_file:21
                 unevictable:0 dirty:27442 writeback:2 unstable:0
                 slab_reclaimable:1551651 slab_unreclaimable:71283
                 mapped:225 shmem:0 pagetables:499 bounce:0
                 free:32282 free_pcp:0 free_cma:0
[196998.004062] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[196998.004068] lowmem_reserve[]: 0 3405 7866 7866
[196998.004070] Node 0 DMA32 free:63212kB min:29148kB low:36432kB high:4371=
6kB active_anon:29140kB inactive_anon:29184kB active_file:224444kB inactive=
_file:95844kB unevictable:0kB isolated(anon):0kB isolated(file):84kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:38796kB writeback:4kB=
 mapped:60kB shmem:0kB slab_reclaimable:2918384kB slab_unreclaimable:101488=
kB kernel_stack:832kB pagetables:480kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[196998.004076] lowmem_reserve[]: 0 0 4460 4460
[196998.004078] Node 0 Normal free:50556kB min:38304kB low:47880kB high:574=
56kB active_anon:81936kB inactive_anon:82144kB active_file:444752kB inactiv=
e_file:362012kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:70972kB writeback:4kB=
 mapped:840kB shmem:0kB slab_reclaimable:3288220kB slab_unreclaimable:18364=
4kB kernel_stack:1456kB pagetables:1516kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[196998.004083] lowmem_reserve[]: 0 0 0 0
[196998.004085] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[196998.004093] Node 0 DMA32: 12340*4kB (UME) 1735*8kB (UME) 0*16kB 0*32kB =
0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 63240kB
[196998.004101] Node 0 Normal: 11863*4kB (UMEH) 357*8kB (UMEH) 1*16kB (H) 6=
*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=
 50644kB
[196998.004110] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[196998.004111] 282122 total pagecache pages
[196998.004112] 298 pages in swap cache
[196998.004114] Swap cache stats: add 2636158, delete 2635860, find 1273435=
/1893973
[196998.004115] Free swap  =3D 20931400kB
[196998.004116] Total swap =3D 20955132kB
[196998.004117] 2076012 pages RAM
[196998.004118] 0 pages HighMem/MovableOnly
[196998.004118] 52657 pages reserved
[196998.004119] 4096 pages cma reserved
[196998.004120] 0 pages hwpoisoned
[196998.004121] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[196998.004125] [  429]     0   429    10643       64      21       3      =
342         -1000 udevd
[196998.004128] [  802]     0   802     4826       22      14       3      =
 35             0 irqbalance
[196998.004129] [  995]     0   995     6743        0      16       3      =
 71             0 syslog-ng
[196998.004131] [  996]     0   996   139523      239      46       4      =
388             0 syslog-ng
[196998.004133] [ 1071]     0  1071    35627       71      17       4      =
123             0 crond
[196998.004135] [ 1107]     0  1107    31552        0      10       3      =
 22             0 mingetty
[196998.004137] [ 1108]     0  1108    31552        0      10       4      =
 22             0 mingetty
[196998.004139] [ 1109]     0  1109    31552        0      10       3      =
 21             0 mingetty
[196998.004141] [ 1147]     0  1147    36183       92      20       3      =
158             0 tmux
[196998.004161] [ 1189]     0  1189    34067       59      16       3      =
102             0 bash
[196998.004163] [ 1685]     0  1685    34030       11      16       3      =
110             0 bash
[196998.004165] [ 1706]     0  1706    34067        0      16       3      =
119             0 bash
[196998.004167] [ 1727]     0  1727    34067        0      15       3      =
122             0 bash
[196998.004169] [ 1747]     0  1747    34030        0      15       3      =
119             0 bash
[196998.004170] [ 1767]     0  1767    34030       56      14       3      =
104             0 bash
[196998.004172] [ 1787]     0  1787    34030        0      17       3      =
122             0 bash
[196998.004174] [ 1807]     0  1807    34067        6      15       3      =
116             0 bash
[196998.004175] [ 1827]     0  1827    34030       41      17       3      =
104             0 bash
[196998.004177] [ 1847]     0  1847    34067       20      16       3      =
114             0 bash
[196998.004179] [ 3346]     0  3346    15794        8      34       3      =
171         -1000 sshd
[196998.004181] [ 3488]     0  3488    93321    55219     132       3     3=
408             0 cp
[196998.004183] Out of memory: Kill process 3488 (cp) score 7 or sacrifice =
child
[196998.004187] Killed process 3488 (cp) total-vm:373284kB, anon-rss:220444=
kB, file-rss:432kB, shmem-rss:0kB
[196998.022475] oom_reaper: reaped process 3488 (cp), now anon-rss:0kB, fil=
e-rss:0kB, shmem-rss:0kB
[227560.585604] bash invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL_AC=
COUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[227560.585607] bash cpuset=3D/ mems_allowed=3D0
[227560.585612] CPU: 1 PID: 3613 Comm: bash Not tainted 4.7.0-1 #1
[227560.585614] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[227560.585616]  0000000000000286 00000000607a702a ffff880006fe7b40 fffffff=
f81335d0e
[227560.585619]  ffff880006fe7d28 ffff880214abb300 ffff880006fe7bb0 fffffff=
f811ffa2f
[227560.585621]  0000000000000000 ffff88021ea5a748 0000000100000000 ffff880=
2140add00
[227560.585623] Call Trace:
[227560.585630]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[227560.585634]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[227560.585638]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[227560.585641]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[227560.585643]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[227560.585645]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[227560.585648]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[227560.585651]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[227560.585654]  [<ffffffff8121dc30>] ? alloc_inode+0x50/0x90
[227560.585657]  [<ffffffff811dff4d>] ? kmem_cache_alloc+0x1bd/0x1d0
[227560.585660]  [<ffffffff8120513c>] ? get_empty_filp+0x5c/0x1c0
[227560.585662]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[227560.585665]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[227560.585668]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[227560.585671]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[227560.585672] Mem-Info:
[227560.585677] active_anon:22 inactive_anon:1645 isolated_anon:0
                 active_file:321749 inactive_file:130489 isolated_file:0
                 unevictable:0 dirty:3122 writeback:0 unstable:0
                 slab_reclaimable:1359525 slab_unreclaimable:35970
                 mapped:2103 shmem:1 pagetables:450 bounce:0
                 free:142299 free_pcp:0 free_cma:0
[227560.585680] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[227560.585685] lowmem_reserve[]: 0 3405 7866 7866
[227560.585688] Node 0 DMA32 free:258344kB min:29148kB low:36432kB high:437=
16kB active_anon:8kB inactive_anon:3144kB active_file:336848kB inactive_fil=
e:242292kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:5724kB writeback:0kB =
mapped:2012kB shmem:4kB slab_reclaimable:2569352kB slab_unreclaimable:50284=
kB kernel_stack:800kB pagetables:536kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[227560.585693] lowmem_reserve[]: 0 0 4460 4460
[227560.585696] Node 0 Normal free:295492kB min:38304kB low:47880kB high:57=
456kB active_anon:80kB inactive_anon:3436kB active_file:950148kB inactive_f=
ile:279664kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:6764kB writeback:0kB =
mapped:6400kB shmem:0kB slab_reclaimable:2868748kB slab_unreclaimable:93596=
kB kernel_stack:1520kB pagetables:1264kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[227560.585700] lowmem_reserve[]: 0 0 0 0
[227560.585703] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[227560.585711] Node 0 DMA32: 57979*4kB (UME) 3314*8kB (UM) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 258428kB
[227560.585718] Node 0 Normal: 73720*4kB (UMEH) 39*8kB (UEH) 1*16kB (H) 6*3=
2kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 2=
95528kB
[227560.585727] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[227560.585728] 452405 total pagecache pages
[227560.585730] 154 pages in swap cache
[227560.585731] Swap cache stats: add 2636486, delete 2636332, find 1273830=
/1894562
[227560.585732] Free swap  =3D 20945120kB
[227560.585733] Total swap =3D 20955132kB
[227560.585734] 2076012 pages RAM
[227560.585735] 0 pages HighMem/MovableOnly
[227560.585736] 52657 pages reserved
[227560.585737] 4096 pages cma reserved
[227560.585738] 0 pages hwpoisoned
[227560.585739] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[227560.585743] [  429]     0   429    10643       65      21       3      =
341         -1000 udevd
[227560.585745] [  802]     0   802     4826       23      14       3      =
 34             0 irqbalance
[227560.585747] [  995]     0   995     6743        1      16       3      =
 70             0 syslog-ng
[227560.585749] [  996]     0   996   139523      398      46       4      =
378             0 syslog-ng
[227560.585751] [ 1071]     0  1071    35627      226      17       4      =
123             0 crond
[227560.585753] [ 1107]     0  1107    31552        0      10       3      =
 21             0 mingetty
[227560.585755] [ 1108]     0  1108    31552        0      10       4      =
 21             0 mingetty
[227560.585756] [ 1109]     0  1109    31552        0      10       3      =
 20             0 mingetty
[227560.585758] [ 1147]     0  1147    36183      515      20       3      =
119             0 tmux
[227560.585760] [ 1189]     0  1189    34067      266      16       3      =
 72             0 bash
[227560.585762] [ 1685]     0  1685    34030       11      16       3      =
109             0 bash
[227560.585763] [ 1706]     0  1706    34067        0      16       3      =
118             0 bash
[227560.585765] [ 1727]     0  1727    34067        0      15       3      =
121             0 bash
[227560.585767] [ 1747]     0  1747    34030        0      15       3      =
118             0 bash
[227560.585768] [ 1767]     0  1767    34030       57      14       3      =
103             0 bash
[227560.585770] [ 1787]     0  1787    34030        0      17       3      =
121             0 bash
[227560.585772] [ 1807]     0  1807    34067        6      15       3      =
115             0 bash
[227560.585773] [ 1827]     0  1827    34030       42      17       3      =
103             0 bash
[227560.585775] [ 1847]     0  1847    34067      477      16       3      =
 47             0 bash
[227560.585777] [ 3346]     0  3346    15794      184      34       3      =
150         -1000 sshd
[227560.585779] [ 3610]     0  3610    26965     1533      56       3      =
112             0 sshd
[227560.585781] [ 3613]     0  3613    34030      804      14       4      =
  0             0 bash
[227560.585783] [ 3633]     0  3633    32428     1248      13       3      =
  0             0 rm
[227560.585784] Out of memory: Kill process 3610 (sshd) score 0 or sacrific=
e child
[227560.585788] Killed process 3613 (bash) total-vm:136120kB, anon-rss:388k=
B, file-rss:2828kB, shmem-rss:0kB
[227560.585927] oom_reaper: reaped process 3613 (bash), now anon-rss:0kB, f=
ile-rss:0kB, shmem-rss:0kB
[227602.942493] syslog-ng invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERN=
EL_ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[227602.942498] syslog-ng cpuset=3D/ mems_allowed=3D0
[227602.942503] CPU: 0 PID: 996 Comm: syslog-ng Not tainted 4.7.0-1 #1
[227602.942504] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[227602.942506]  0000000000000286 0000000095b6fb50 ffff8800d579bb40 fffffff=
f81335d0e
[227602.942509]  ffff8800d579bd28 ffff880037eb6600 ffff8800d579bbb0 fffffff=
f811ffa2f
[227602.942511]  0000000000000000 ffff88021ea1a748 0000000100000000 ffff880=
21473bfc0
[227602.942513] Call Trace:
[227602.942520]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[227602.942523]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[227602.942528]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[227602.942531]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[227602.942532]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[227602.942535]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[227602.942538]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[227602.942541]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[227602.942544]  [<ffffffff81249750>] ? ep_ptable_queue_proc+0xa0/0xa0
[227602.942546]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[227602.942548]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[227602.942550]  [<ffffffff81249ab7>] ? ep_remove+0xa7/0xc0
[227602.942553]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[227602.942556]  [<ffffffff8109eb80>] ? wake_up_q+0x70/0x70
[227602.942558]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[227602.942561]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[227602.942563]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[227602.942565] Mem-Info:
[227602.942569] active_anon:344 inactive_anon:1389 isolated_anon:0
                 active_file:346948 inactive_file:130926 isolated_file:0
                 unevictable:0 dirty:4845 writeback:0 unstable:0
                 slab_reclaimable:1357809 slab_unreclaimable:35888
                 mapped:2183 shmem:1 pagetables:454 bounce:0
                 free:118378 free_pcp:0 free_cma:0
[227602.942572] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[227602.942577] lowmem_reserve[]: 0 3405 7866 7866
[227602.942580] Node 0 DMA32 free:223952kB min:29148kB low:36432kB high:437=
16kB active_anon:588kB inactive_anon:2648kB active_file:376992kB inactive_f=
ile:240668kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:6528kB writeback:0kB =
mapped:1984kB shmem:4kB slab_reclaimable:2565156kB slab_unreclaimable:50316=
kB kernel_stack:816kB pagetables:508kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:12 all_unreclaimable? no
[227602.942585] lowmem_reserve[]: 0 0 4460 4460
[227602.942588] Node 0 Normal free:234200kB min:38304kB low:47880kB high:57=
456kB active_anon:788kB inactive_anon:2908kB active_file:1010800kB inactive=
_file:283036kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:12852kB writeback:0kB=
 mapped:6748kB shmem:0kB slab_reclaimable:2866080kB slab_unreclaimable:9323=
6kB kernel_stack:1520kB pagetables:1308kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:4 all_unreclaimable? no
[227602.942592] lowmem_reserve[]: 0 0 0 0
[227602.942595] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[227602.942603] Node 0 DMA32: 55729*4kB (UME) 133*8kB (UE) 0*16kB 0*32kB 0*=
64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 223980kB
[227602.942610] Node 0 Normal: 58366*4kB (UMEH) 58*8kB (UMEH) 1*16kB (H) 6*=
32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D =
234264kB
[227602.942619] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[227602.942620] 478051 total pagecache pages
[227602.942622] 159 pages in swap cache
[227602.942623] Swap cache stats: add 2636525, delete 2636366, find 1273870=
/1894641
[227602.942624] Free swap  =3D 20945576kB
[227602.942625] Total swap =3D 20955132kB
[227602.942626] 2076012 pages RAM
[227602.942627] 0 pages HighMem/MovableOnly
[227602.942628] 52657 pages reserved
[227602.942629] 4096 pages cma reserved
[227602.942630] 0 pages hwpoisoned
[227602.942631] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[227602.942635] [  429]     0   429    10643       65      21       3      =
341         -1000 udevd
[227602.942637] [  802]     0   802     4826       23      14       3      =
 34             0 irqbalance
[227602.942639] [  995]     0   995     6743        1      16       3      =
 70             0 syslog-ng
[227602.942641] [  996]     0   996   139523      399      46       4      =
377             0 syslog-ng
[227602.942643] [ 1071]     0  1071    35627      226      17       4      =
123             0 crond
[227602.942645] [ 1107]     0  1107    31552        0      10       3      =
 21             0 mingetty
[227602.942647] [ 1108]     0  1108    31552        0      10       4      =
 21             0 mingetty
[227602.942648] [ 1109]     0  1109    31552        0      10       3      =
 20             0 mingetty
[227602.942650] [ 1147]     0  1147    36183      515      20       3      =
119             0 tmux
[227602.942652] [ 1189]     0  1189    34067      266      16       3      =
 72             0 bash
[227602.942654] [ 1685]     0  1685    34030       11      16       3      =
109             0 bash
[227602.942656] [ 1706]     0  1706    34067        0      16       3      =
118             0 bash
[227602.942657] [ 1727]     0  1727    34067        0      15       3      =
121             0 bash
[227602.942659] [ 1747]     0  1747    34030        0      15       3      =
118             0 bash
[227602.942661] [ 1767]     0  1767    34030       57      14       3      =
103             0 bash
[227602.942662] [ 1787]     0  1787    34030        0      17       3      =
121             0 bash
[227602.942664] [ 1807]     0  1807    34067        6      15       3      =
115             0 bash
[227602.942666] [ 1827]     0  1827    34030       42      17       3      =
103             0 bash
[227602.942667] [ 1847]     0  1847    34067      477      16       3      =
 47             0 bash
[227602.942669] [ 3346]     0  3346    15794      184      34       3      =
150         -1000 sshd
[227602.942671] [ 3633]     0  3633    32428     1248      13       3      =
  0             0 rm
[227602.942673] [ 3649]     0  3649    26921     1564      57       3      =
  0             0 sshd
[227602.942675] [ 3651]     0  3651    34030      885      17       3      =
  0             0 bash
[227602.942676] Out of memory: Kill process 3649 (sshd) score 0 or sacrific=
e child
[227602.942685] Killed process 3651 (bash) total-vm:136120kB, anon-rss:400k=
B, file-rss:3140kB, shmem-rss:0kB
[227638.033269] bash invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL_AC=
COUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
[227638.033273] bash cpuset=3D/ mems_allowed=3D0
[227638.033278] CPU: 1 PID: 3675 Comm: bash Not tainted 4.7.0-1 #1
[227638.033279] Hardware name: Gigabyte Technology Co., Ltd. H61M-S2V-B3/H6=
1M-S2V-B3, BIOS F4 05/25/2011
[227638.033281]  0000000000000286 00000000c0abce5f ffff880077b57b40 fffffff=
f81335d0e
[227638.033284]  ffff880077b57d28 ffff880037eb6600 ffff880077b57bb0 fffffff=
f811ffa2f
[227638.033286]  0000000000000000 ffff88021ea5a748 0000000100000000 ffff880=
037eb5940
[227638.033288] Call Trace:
[227638.033295]  [<ffffffff81335d0e>] dump_stack+0x63/0x85
[227638.033298]  [<ffffffff811ffa2f>] dump_header+0x5f/0x1d4
[227638.033302]  [<ffffffff8165cdde>] ? _raw_spin_unlock_irqrestore+0xe/0x10
[227638.033305]  [<ffffffff8118141f>] oom_kill_process+0x32f/0x420
[227638.033307]  [<ffffffff81181723>] out_of_memory+0x1c3/0x470
[227638.033310]  [<ffffffff81186f4f>] __alloc_pages_nodemask+0xeff/0xf40
[227638.033312]  [<ffffffff811872ef>] alloc_kmem_pages_node+0x4f/0xd0
[227638.033316]  [<ffffffff81072856>] copy_process.part.8+0x136/0x1a00
[227638.033319]  [<ffffffff811dff4d>] ? kmem_cache_alloc+0x1bd/0x1d0
[227638.033322]  [<ffffffff8120513c>] ? get_empty_filp+0x5c/0x1c0
[227638.033324]  [<ffffffff81074307>] _do_fork+0xd7/0x390
[227638.033326]  [<ffffffff81074669>] SyS_clone+0x19/0x20
[227638.033329]  [<ffffffff81003c9e>] do_syscall_64+0x5e/0xc0
[227638.033332]  [<ffffffff8165d265>] entry_SYSCALL64_slow_path+0x25/0x25
[227638.033333] Mem-Info:
[227638.033337] active_anon:346 inactive_anon:1389 isolated_anon:0
                 active_file:355762 inactive_file:136599 isolated_file:0
                 unevictable:0 dirty:1464 writeback:0 unstable:0
                 slab_reclaimable:1390326 slab_unreclaimable:35451
                 mapped:2192 shmem:1 pagetables:453 bounce:0
                 free:71741 free_pcp:0 free_cma:0
[227638.033340] Node 0 DMA free:15360kB min:128kB low:160kB high:192kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15984kB=20
managed:15360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB sl=
ab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB u=
nstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB=20
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[227638.033346] lowmem_reserve[]: 0 3405 7866 7866
[227638.033348] Node 0 DMA32 free:222588kB min:29148kB low:36432kB high:437=
16kB active_anon:260kB inactive_anon:2648kB active_file:374864kB inactive_f=
ile:241260kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3571520kB managed:3494416kB mlocked:0kB dirty:1664kB writeback:0kB =
mapped:2008kB shmem:4kB slab_reclaimable:2568480kB slab_unreclaimable:50320=
kB kernel_stack:832kB pagetables:424kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:12 all_unreclaimable? no
[227638.033354] lowmem_reserve[]: 0 0 4460 4460
[227638.033356] Node 0 Normal free:49016kB min:38304kB low:47880kB high:574=
56kB active_anon:1124kB inactive_anon:2908kB active_file:1048184kB inactive=
_file:305136kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:4716544kB managed:4583644kB mlocked:0kB dirty:4192kB writeback:0kB =
mapped:6760kB shmem:0kB slab_reclaimable:2992824kB slab_unreclaimable:91484=
kB kernel_stack:1520kB pagetables:1388kB unstable:0kB=20
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
[227638.033361] lowmem_reserve[]: 0 0 0 0
[227638.033363] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256k=
B 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 15360kB
[227638.033371] Node 0 DMA32: 55311*4kB (UME) 170*8kB (UME) 0*16kB 0*32kB 0=
*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 222604kB
[227638.033378] Node 0 Normal: 12049*4kB (UMEH) 79*8kB (UMH) 1*16kB (H) 6*3=
2kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 4=
9164kB
[227638.033388] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[227638.033389] 492558 total pagecache pages
[227638.033390] 159 pages in swap cache
[227638.033391] Swap cache stats: add 2636526, delete 2636367, find 1273877=
/1894649
[227638.033392] Free swap  =3D 20945580kB
[227638.033393] Total swap =3D 20955132kB
[227638.033394] 2076012 pages RAM
[227638.033395] 0 pages HighMem/MovableOnly
[227638.033396] 52657 pages reserved
[227638.033397] 4096 pages cma reserved
[227638.033398] 0 pages hwpoisoned
[227638.033399] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swape=
nts oom_score_adj name
[227638.033403] [  429]     0   429    10643       65      21       3      =
341         -1000 udevd
[227638.033405] [  802]     0   802     4826       23      14       3      =
 34             0 irqbalance
[227638.033407] [  995]     0   995     6743        1      16       3      =
 70             0 syslog-ng
[227638.033409] [  996]     0   996   139523      400      46       4      =
376             0 syslog-ng
[227638.033411] [ 1071]     0  1071    35627      226      17       4      =
123             0 crond
[227638.033413] [ 1107]     0  1107    31552        0      10       3      =
 21             0 mingetty
[227638.033415] [ 1108]     0  1108    31552        0      10       4      =
 21             0 mingetty
[227638.033416] [ 1109]     0  1109    31552        0      10       3      =
 20             0 mingetty
[227638.033418] [ 1147]     0  1147    36183      515      20       3      =
119             0 tmux
[227638.033420] [ 1189]     0  1189    34067      266      16       3      =
 72             0 bash
[227638.033422] [ 1685]     0  1685    34030       11      16       3      =
109             0 bash
[227638.033423] [ 1706]     0  1706    34067        0      16       3      =
118             0 bash
[227638.033425] [ 1727]     0  1727    34067        0      15       3      =
121             0 bash
[227638.033427] [ 1747]     0  1747    34030        0      15       3      =
118             0 bash
[227638.033428] [ 1767]     0  1767    34030       57      14       3      =
103             0 bash
[227638.033430] [ 1787]     0  1787    34030        0      17       3      =
121             0 bash
[227638.033432] [ 1807]     0  1807    34067        6      15       3      =
115             0 bash
[227638.033433] [ 1827]     0  1827    34030       42      17       3      =
103             0 bash
[227638.033435] [ 1847]     0  1847    34067      477      16       3      =
 47             0 bash
[227638.033437] [ 3346]     0  3346    15794      293      34       3      =
135         -1000 sshd
[227638.033439] [ 3633]     0  3633    32428     1248      13       3      =
  0             0 rm
[227638.033441] [ 3673]     0  3673    26919     1588      58       3      =
  0             0 sshd
[227638.033442] [ 3675]     0  3675    34030      882      15       4      =
  0             0 bash
[227638.033444] Out of memory: Kill process 3673 (sshd) score 0 or sacrific=
e child
[227638.033448] Killed process 3675 (bash) total-vm:136120kB, anon-rss:396k=
B, file-rss:3132kB, shmem-rss:0kB
[227638.033605] oom_reaper: reaped process 3675 (bash), now anon-rss:0kB, f=
ile-rss:0kB, shmem-rss:0kB

# cat /proc/mdstat=20
Personalities : [raid1] [raid0] [raid6] [raid5] [raid4]=20
md3 : active raid5 sda4[0] sdd4[4] sdc4[2] sdb4[1]
      2761605120 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [U=
UUU]
      bitmap: 5/7 pages [20KB], 65536KB chunk

md2 : active raid5 sda3[0] sdd3[4] sdc3[2] sdb3[1]
      2767847424 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [U=
UUU]
      bitmap: 0/7 pages [0KB], 65536KB chunk

md0 : active raid0 sda1[0] sdd1[3] sdc1[2] sdb1[1]
      20955136 blocks super 1.2 512k chunks
     =20
md1 : active raid1 sda2[0] sdd2[3] sdc2[2] sdb2[1]
      104857536 blocks [4/4] [UUUU]
     =20
unused devices: <none>


slabtop while rm -rf copy1; cp -al mydir copy1 is in progress
(one such command, the other was killed by OOM)

# slabtop -o  =20
 Active / Total Objects (% used)    : 9285348 / 9335241 (99.5%)
 Active / Total Slabs (% used)      : 1328832 / 1328832 (100.0%)
 Active / Total Caches (% used)     : 81 / 115 (70.4%)
 Active / Total Size (% used)       : 4810034.71K / 4833748.06K (99.5%)
 Minimum / Average / Maximum Object : 0.01K / 0.52K / 18.50K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
4211382 4211274  99%    0.19K 200542       21    802168K dentry
3665007 3662369  99%    1.05K 1097181       30  35109792K ext4_inode_cache
509652 503798  98%    0.10K  13068       39     52272K buffer_head
411570 402060  97%    0.04K   4035      102     16140K ext4_extent_status
219904 219904 100%    0.06K   3436       64     13744K kmalloc-64
 71442  71001  99%    0.09K   1701       42      6804K kmalloc-96
 68803  50961  74%    0.57K   2563       28     41008K radix_tree_node
 26486  26486 100%    0.12K    779       34      3116K jbd2_journal_head
 24140  24140 100%    0.12K    710       34      2840K kernfs_node_cache
 21084  21084 100%    0.14K    753       28      3012K ext4_groupinfo_4k
 16422  16083  97%    0.19K    782       21      3128K kmalloc-192
 12292  11512  93%    0.56K    439       28      7024K inode_cache
  7553   4612  61%    1.66K    453       19     14496K raid5-md2
  6304   5233  83%    0.12K    197       32       788K kmalloc-128
  5632   5632 100%    0.01K     11      512        44K kmalloc-8
  4746    713  15%    0.38K    226       21      1808K mnt_cache
  4165   4165 100%    0.05K     49       85       196K ftrace_event_field
  3840   3840 100%    0.02K     15      256        60K kmalloc-16
  3766   2566  68%    0.94K    514       34     16448K xfs_inode
  3666   2887  78%    0.15K    141       26       564K xfs_ili
  3072   3072 100%    0.03K     24      128        96K jbd2_revoke_record_s
  2624   2624 100%    0.06K     41       64       164K anon_vma_chain
  2432   2432 100%    0.06K     38       64       152K ext4_io_end
  2368   1586  66%    0.25K     74       32       592K kmalloc-256
  2286   2286 100%    0.65K     96       24      1536K shmem_inode_cache
  2221   2221 100%    0.62K    215       25      3440K proc_inode_cache
  2142   2142 100%    0.04K     21      102        84K Acpi-Namespace
  2048   2048 100%    0.03K     16      128        64K kmalloc-32
  1887   1887 100%    0.08K     37       51       148K anon_vma
  1840   1840 100%    0.20K     92       20       368K vm_area_struct
  1794   1794 100%    0.09K     39       46       156K trace_event_file
  1680   1680 100%    0.07K     30       56       120K Acpi-Operand
  1656   1140  68%    0.50K     63       32      1008K kmalloc-512
  1604   1255  78%    1.00K     72       32      2304K kmalloc-1024
   966    966 100%    0.19K     46       21       184K cred_jar
   792    704  88%    0.18K     36       22       144K xfs_log_ticket
   430    333  77%    2.00K     33       16      1056K kmalloc-2048
   420    280  66%    0.23K     12       35        96K cfq_queue
   375    282  75%    0.31K     15       25       120K bio-1
   340    340 100%    0.02K      2      170         8K numa_policy
   308    308 100%    0.56K     11       28       176K skbuff_fclone_cache


config:
#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0 Kernel Configuration
#
CONFIG_64BIT=3Dy
CONFIG_X86_64=3Dy
CONFIG_X86=3Dy
CONFIG_INSTRUCTION_DECODER=3Dy
CONFIG_OUTPUT_FORMAT=3D"elf64-x86-64"
CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_MMU=3Dy
CONFIG_ARCH_MMAP_RND_BITS_MIN=3D28
CONFIG_ARCH_MMAP_RND_BITS_MAX=3D32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=3D8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=3D16
CONFIG_NEED_DMA_MAP_STATE=3Dy
CONFIG_NEED_SG_DMA_LENGTH=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_BUG=3Dy
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_ARCH_HAS_CPU_RELAX=3Dy
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=3Dy
CONFIG_ARCH_WANT_GENERAL_HUGETLB=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_AUDIT_ARCH=3Dy
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
CONFIG_HAVE_INTEL_TXT=3Dy
CONFIG_X86_64_SMP=3Dy
CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-rdi -fcall-saved-rsi -fcall-save=
d-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fc=
all-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=3Dy
CONFIG_FIX_EARLYCON_MEM=3Dy
CONFIG_DEBUG_RODATA=3Dy
CONFIG_PGTABLE_LEVELS=3D4
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=3Dy
CONFIG_BUILDTIME_EXTABLE_SORT=3Dy

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=3D32
CONFIG_CROSS_COMPILE=3D""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=3D"-1"
CONFIG_LOCALVERSION_AUTO=3Dy
CONFIG_HAVE_KERNEL_GZIP=3Dy
CONFIG_HAVE_KERNEL_BZIP2=3Dy
CONFIG_HAVE_KERNEL_LZMA=3Dy
CONFIG_HAVE_KERNEL_XZ=3Dy
CONFIG_HAVE_KERNEL_LZO=3Dy
CONFIG_HAVE_KERNEL_LZ4=3Dy
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=3Dy
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME=3D"(none)"
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_POSIX_MQUEUE=3Dy
CONFIG_POSIX_MQUEUE_SYSCTL=3Dy
CONFIG_CROSS_MEMORY_ATTACH=3Dy
CONFIG_FHANDLE=3Dy
CONFIG_USELIB=3Dy
CONFIG_AUDIT=3Dy
CONFIG_HAVE_ARCH_AUDITSYSCALL=3Dy
CONFIG_AUDITSYSCALL=3Dy
CONFIG_AUDIT_WATCH=3Dy
CONFIG_AUDIT_TREE=3Dy

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_GENERIC_IRQ_SHOW=3Dy
CONFIG_GENERIC_PENDING_IRQ=3Dy
CONFIG_GENERIC_IRQ_CHIP=3Dy
CONFIG_IRQ_DOMAIN=3Dy
CONFIG_IRQ_DOMAIN_HIERARCHY=3Dy
CONFIG_GENERIC_MSI_IRQ=3Dy
CONFIG_GENERIC_MSI_IRQ_DOMAIN=3Dy
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=3Dy
CONFIG_SPARSE_IRQ=3Dy
CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=3Dy
CONFIG_GENERIC_TIME_VSYSCALL=3Dy
CONFIG_GENERIC_CLOCKEVENTS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=3Dy
CONFIG_GENERIC_CMOS_UPDATE=3Dy

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=3Dy
CONFIG_NO_HZ_COMMON=3Dy
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=3Dy
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=3Dy
CONFIG_HIGH_RES_TIMERS=3Dy

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=3Dy
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=3Dy
CONFIG_BSD_PROCESS_ACCT_V3=3Dy
CONFIG_TASKSTATS=3Dy
CONFIG_TASK_DELAY_ACCT=3Dy
CONFIG_TASK_XACCT=3Dy
CONFIG_TASK_IO_ACCOUNTING=3Dy

#
# RCU Subsystem
#
CONFIG_TREE_RCU=3Dy
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=3Dy
CONFIG_TASKS_RCU=3Dy
CONFIG_RCU_STALL_COMMON=3Dy
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=3Dy
CONFIG_IKCONFIG=3Dm
CONFIG_IKCONFIG_PROC=3Dy
CONFIG_LOG_BUF_SHIFT=3D18
CONFIG_LOG_CPU_MAX_BUF_SHIFT=3D12
CONFIG_NMI_LOG_BUF_SHIFT=3D13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=3Dy
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=3Dy
CONFIG_ARCH_SUPPORTS_INT128=3Dy
CONFIG_NUMA_BALANCING=3Dy
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=3Dy
CONFIG_CGROUPS=3Dy
CONFIG_PAGE_COUNTER=3Dy
CONFIG_MEMCG=3Dy
CONFIG_MEMCG_SWAP=3Dy
CONFIG_MEMCG_SWAP_ENABLED=3Dy
CONFIG_BLK_CGROUP=3Dy
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=3Dy
CONFIG_CGROUP_SCHED=3Dy
CONFIG_FAIR_GROUP_SCHED=3Dy
CONFIG_CFS_BANDWIDTH=3Dy
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=3Dy
CONFIG_CGROUP_FREEZER=3Dy
CONFIG_CGROUP_HUGETLB=3Dy
CONFIG_CPUSETS=3Dy
# CONFIG_PROC_PID_CPUSET is not set
CONFIG_CGROUP_DEVICE=3Dy
CONFIG_CGROUP_CPUACCT=3Dy
CONFIG_CGROUP_PERF=3Dy
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=3Dy
CONFIG_UTS_NS=3Dy
CONFIG_IPC_NS=3Dy
CONFIG_USER_NS=3Dy
CONFIG_PID_NS=3Dy
CONFIG_NET_NS=3Dy
CONFIG_SCHED_AUTOGROUP=3Dy
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=3Dy
CONFIG_BLK_DEV_INITRD=3Dy
CONFIG_INITRAMFS_SOURCE=3D""
CONFIG_RD_GZIP=3Dy
CONFIG_RD_BZIP2=3Dy
CONFIG_RD_LZMA=3Dy
CONFIG_RD_XZ=3Dy
CONFIG_RD_LZO=3Dy
CONFIG_RD_LZ4=3Dy
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=3Dy
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=3Dy
CONFIG_ANON_INODES=3Dy
CONFIG_HAVE_UID16=3Dy
CONFIG_SYSCTL_EXCEPTION_TRACE=3Dy
CONFIG_HAVE_PCSPKR_PLATFORM=3Dy
CONFIG_BPF=3Dy
# CONFIG_EXPERT is not set
CONFIG_UID16=3Dy
CONFIG_MULTIUSER=3Dy
CONFIG_SGETMASK_SYSCALL=3Dy
CONFIG_SYSFS_SYSCALL=3Dy
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=3Dy
CONFIG_KALLSYMS_ALL=3Dy
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=3Dy
CONFIG_KALLSYMS_BASE_RELATIVE=3Dy
CONFIG_PRINTK=3Dy
CONFIG_PRINTK_NMI=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_PCSPKR_PLATFORM=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_TIMERFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_BPF_SYSCALL=3Dy
CONFIG_SHMEM=3Dy
CONFIG_AIO=3Dy
CONFIG_ADVISE_SYSCALLS=3Dy
CONFIG_USERFAULTFD=3Dy
CONFIG_PCI_QUIRKS=3Dy
CONFIG_MEMBARRIER=3Dy
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=3Dy

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=3Dy
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_SLUB_DEBUG=3Dy
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=3Dy
CONFIG_SLUB_CPU_PARTIAL=3Dy
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=3Dy
CONFIG_TRACEPOINTS=3Dy
CONFIG_KEXEC_CORE=3Dy
CONFIG_OPROFILE=3Dm
CONFIG_OPROFILE_EVENT_MULTIPLEX=3Dy
CONFIG_HAVE_OPROFILE=3Dy
CONFIG_OPROFILE_NMI_TIMER=3Dy
CONFIG_KPROBES=3Dy
CONFIG_JUMP_LABEL=3Dy
CONFIG_STATIC_KEYS_SELFTEST=3Dy
CONFIG_OPTPROBES=3Dy
CONFIG_KPROBES_ON_FTRACE=3Dy
CONFIG_UPROBES=3Dy
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
CONFIG_ARCH_USE_BUILTIN_BSWAP=3Dy
CONFIG_KRETPROBES=3Dy
CONFIG_USER_RETURN_NOTIFIER=3Dy
CONFIG_HAVE_IOREMAP_PROT=3Dy
CONFIG_HAVE_KPROBES=3Dy
CONFIG_HAVE_KRETPROBES=3Dy
CONFIG_HAVE_OPTPROBES=3Dy
CONFIG_HAVE_KPROBES_ON_FTRACE=3Dy
CONFIG_HAVE_NMI=3Dy
CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
CONFIG_HAVE_DMA_CONTIGUOUS=3Dy
CONFIG_GENERIC_SMP_IDLE_THREAD=3Dy
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=3Dy
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
CONFIG_HAVE_CLK=3Dy
CONFIG_HAVE_DMA_API_DEBUG=3Dy
CONFIG_HAVE_HW_BREAKPOINT=3Dy
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
CONFIG_HAVE_PERF_REGS=3Dy
CONFIG_HAVE_PERF_USER_STACK_DUMP=3Dy
CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=3Dy
CONFIG_HAVE_CMPXCHG_LOCAL=3Dy
CONFIG_HAVE_CMPXCHG_DOUBLE=3Dy
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=3Dy
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=3Dy
CONFIG_HAVE_ARCH_SECCOMP_FILTER=3Dy
CONFIG_SECCOMP_FILTER=3Dy
CONFIG_HAVE_CC_STACKPROTECTOR=3Dy
CONFIG_CC_STACKPROTECTOR=3Dy
# CONFIG_CC_STACKPROTECTOR_NONE is not set
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
CONFIG_CC_STACKPROTECTOR_STRONG=3Dy
CONFIG_HAVE_CONTEXT_TRACKING=3Dy
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=3Dy
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=3Dy
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=3Dy
CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy
CONFIG_HAVE_ARCH_SOFT_DIRTY=3Dy
CONFIG_MODULES_USE_ELF_RELA=3Dy
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=3Dy
CONFIG_ARCH_HAS_ELF_RANDOMIZE=3Dy
CONFIG_HAVE_ARCH_MMAP_RND_BITS=3Dy
CONFIG_HAVE_EXIT_THREAD=3Dy
CONFIG_ARCH_MMAP_RND_BITS=3D28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=3Dy
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=3D8
CONFIG_HAVE_COPY_THREAD_TLS=3Dy
CONFIG_HAVE_STACK_VALIDATION=3Dy
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_OLD_SIGSUSPEND3=3Dy
CONFIG_COMPAT_OLD_SIGACTION=3Dy
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=3Dy
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=3Dy
CONFIG_RT_MUTEXES=3Dy
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
CONFIG_MODULE_FORCE_LOAD=3Dy
CONFIG_MODULE_UNLOAD=3Dy
CONFIG_MODULE_FORCE_UNLOAD=3Dy
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_MODULE_COMPRESS=3Dy
# CONFIG_MODULE_COMPRESS_GZIP is not set
CONFIG_MODULE_COMPRESS_XZ=3Dy
CONFIG_MODULES_TREE_LOOKUP=3Dy
CONFIG_BLOCK=3Dy
CONFIG_BLK_DEV_BSG=3Dy
CONFIG_BLK_DEV_BSGLIB=3Dy
CONFIG_BLK_DEV_INTEGRITY=3Dy
CONFIG_BLK_DEV_THROTTLING=3Dy
CONFIG_BLK_CMDLINE_PARSER=3Dy

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=3Dy
CONFIG_ACORN_PARTITION=3Dy
CONFIG_ACORN_PARTITION_CUMANA=3Dy
CONFIG_ACORN_PARTITION_EESOX=3Dy
CONFIG_ACORN_PARTITION_ICS=3Dy
CONFIG_ACORN_PARTITION_ADFS=3Dy
CONFIG_ACORN_PARTITION_POWERTEC=3Dy
CONFIG_ACORN_PARTITION_RISCIX=3Dy
CONFIG_AIX_PARTITION=3Dy
CONFIG_OSF_PARTITION=3Dy
CONFIG_AMIGA_PARTITION=3Dy
CONFIG_ATARI_PARTITION=3Dy
CONFIG_MAC_PARTITION=3Dy
CONFIG_MSDOS_PARTITION=3Dy
CONFIG_BSD_DISKLABEL=3Dy
CONFIG_MINIX_SUBPARTITION=3Dy
CONFIG_SOLARIS_X86_PARTITION=3Dy
CONFIG_UNIXWARE_DISKLABEL=3Dy
CONFIG_LDM_PARTITION=3Dy
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=3Dy
CONFIG_ULTRIX_PARTITION=3Dy
CONFIG_SUN_PARTITION=3Dy
CONFIG_KARMA_PARTITION=3Dy
CONFIG_EFI_PARTITION=3Dy
CONFIG_SYSV68_PARTITION=3Dy
CONFIG_CMDLINE_PARTITION=3Dy
CONFIG_BLOCK_COMPAT=3Dy

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
CONFIG_IOSCHED_DEADLINE=3Dy
CONFIG_IOSCHED_CFQ=3Dy
CONFIG_CFQ_GROUP_IOSCHED=3Dy
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=3Dy
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"cfq"
CONFIG_PREEMPT_NOTIFIERS=3Dy
CONFIG_PADATA=3Dy
CONFIG_ASN1=3Dy
CONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy
CONFIG_INLINE_READ_UNLOCK=3Dy
CONFIG_INLINE_READ_UNLOCK_IRQ=3Dy
CONFIG_INLINE_WRITE_UNLOCK=3Dy
CONFIG_INLINE_WRITE_UNLOCK_IRQ=3Dy
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=3Dy
CONFIG_MUTEX_SPIN_ON_OWNER=3Dy
CONFIG_RWSEM_SPIN_ON_OWNER=3Dy
CONFIG_LOCK_SPIN_ON_OWNER=3Dy
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=3Dy
CONFIG_QUEUED_SPINLOCKS=3Dy
CONFIG_ARCH_USE_QUEUED_RWLOCKS=3Dy
CONFIG_QUEUED_RWLOCKS=3Dy
CONFIG_FREEZER=3Dy

#
# Processor type and features
#
CONFIG_ZONE_DMA=3Dy
CONFIG_SMP=3Dy
CONFIG_X86_FEATURE_NAMES=3Dy
CONFIG_X86_FAST_FEATURE_TESTS=3Dy
CONFIG_X86_X2APIC=3Dy
CONFIG_X86_MPPARSE=3Dy
CONFIG_GOLDFISH=3Dy
CONFIG_X86_EXTENDED_PLATFORM=3Dy
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
# CONFIG_X86_UV is not set
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=3Dy
CONFIG_X86_AMD_PLATFORM_DEVICE=3Dy
CONFIG_IOSF_MBI=3Dy
CONFIG_IOSF_MBI_DEBUG=3Dy
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=3Dy
CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
CONFIG_HYPERVISOR_GUEST=3Dy
CONFIG_PARAVIRT=3Dy
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_XEN=3Dy
CONFIG_XEN_DOM0=3Dy
CONFIG_XEN_PVHVM=3Dy
CONFIG_XEN_512GB=3Dy
CONFIG_XEN_SAVE_RESTORE=3Dy
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_XEN_PVH=3Dy
CONFIG_KVM_GUEST=3Dy
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=3Dy
CONFIG_PARAVIRT_CLOCK=3Dy
CONFIG_NO_BOOTMEM=3Dy
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=3Dy
CONFIG_X86_INTERNODE_CACHE_SHIFT=3D6
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_TSC=3Dy
CONFIG_X86_CMPXCHG64=3Dy
CONFIG_X86_CMOV=3Dy
CONFIG_X86_MINIMUM_CPU_FAMILY=3D64
CONFIG_X86_DEBUGCTLMSR=3Dy
CONFIG_CPU_SUP_INTEL=3Dy
CONFIG_CPU_SUP_AMD=3Dy
CONFIG_CPU_SUP_CENTAUR=3Dy
CONFIG_HPET_TIMER=3Dy
CONFIG_HPET_EMULATE_RTC=3Dy
CONFIG_DMI=3Dy
CONFIG_GART_IOMMU=3Dy
CONFIG_CALGARY_IOMMU=3Dy
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=3Dy
CONFIG_SWIOTLB=3Dy
CONFIG_IOMMU_HELPER=3Dy
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=3D512
CONFIG_SCHED_SMT=3Dy
CONFIG_SCHED_MC=3Dy
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=3Dy
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=3Dy
CONFIG_X86_MCE=3Dy
CONFIG_X86_MCE_INTEL=3Dy
CONFIG_X86_MCE_AMD=3Dy
CONFIG_X86_MCE_THRESHOLD=3Dy
CONFIG_X86_MCE_INJECT=3Dm
CONFIG_X86_THERMAL_VECTOR=3Dy

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=3Dm
CONFIG_PERF_EVENTS_INTEL_RAPL=3Dm
CONFIG_PERF_EVENTS_INTEL_CSTATE=3Dm
CONFIG_PERF_EVENTS_AMD_POWER=3Dm
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=3Dy
CONFIG_X86_ESPFIX64=3Dy
CONFIG_X86_VSYSCALL_EMULATION=3Dy
CONFIG_I8K=3Dm
CONFIG_MICROCODE=3Dy
CONFIG_MICROCODE_INTEL=3Dy
CONFIG_MICROCODE_AMD=3Dy
CONFIG_MICROCODE_OLD_INTERFACE=3Dy
CONFIG_X86_MSR=3Dm
CONFIG_X86_CPUID=3Dm
CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy
CONFIG_X86_DIRECT_GBPAGES=3Dy
CONFIG_NUMA=3Dy
# CONFIG_AMD_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=3Dy
CONFIG_NODES_SPAN_OTHER_NODES=3Dy
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=3D6
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy
CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
# CONFIG_ARCH_MEMORY_PROBE is not set
CONFIG_ARCH_PROC_KCORE_TEXT=3Dy
CONFIG_ILLEGAL_POINTER_VALUE=3D0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=3Dy
CONFIG_SPARSEMEM_MANUAL=3Dy
CONFIG_SPARSEMEM=3Dy
CONFIG_NEED_MULTIPLE_NODES=3Dy
CONFIG_HAVE_MEMORY_PRESENT=3Dy
CONFIG_SPARSEMEM_EXTREME=3Dy
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=3Dy
CONFIG_SPARSEMEM_VMEMMAP=3Dy
CONFIG_HAVE_MEMBLOCK=3Dy
CONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy
CONFIG_ARCH_DISCARD_MEMBLOCK=3Dy
CONFIG_MEMORY_ISOLATION=3Dy
CONFIG_MOVABLE_NODE=3Dy
CONFIG_HAVE_BOOTMEM_INFO_NODE=3Dy
CONFIG_MEMORY_HOTPLUG=3Dy
CONFIG_MEMORY_HOTPLUG_SPARSE=3Dy
CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=3Dy
CONFIG_MEMORY_HOTREMOVE=3Dy
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=3Dy
CONFIG_MEMORY_BALLOON=3Dy
CONFIG_BALLOON_COMPACTION=3Dy
CONFIG_COMPACTION=3Dy
CONFIG_MIGRATION=3Dy
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=3Dy
CONFIG_PHYS_ADDR_T_64BIT=3Dy
CONFIG_BOUNCE=3Dy
CONFIG_VIRT_TO_BUS=3Dy
CONFIG_MMU_NOTIFIER=3Dy
CONFIG_KSM=3Dy
CONFIG_DEFAULT_MMAP_MIN_ADDR=3D65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=3Dy
CONFIG_MEMORY_FAILURE=3Dy
CONFIG_HWPOISON_INJECT=3Dm
CONFIG_TRANSPARENT_HUGEPAGE=3Dy
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=3Dy
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CLEANCACHE=3Dy
CONFIG_FRONTSWAP=3Dy
CONFIG_CMA=3Dy
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=3D7
CONFIG_ZSWAP=3Dy
CONFIG_ZPOOL=3Dy
CONFIG_ZBUD=3Dm
CONFIG_Z3FOLD=3Dm
CONFIG_ZSMALLOC=3Dy
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=3Dy
CONFIG_GENERIC_EARLY_IOREMAP=3Dy
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=3Dy
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=3Dy
CONFIG_FRAME_VECTOR=3Dy
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=3Dy
CONFIG_ARCH_HAS_PKEYS=3Dy
CONFIG_X86_PMEM_LEGACY_DEVICE=3Dy
CONFIG_X86_PMEM_LEGACY=3Dy
CONFIG_X86_CHECK_BIOS_CORRUPTION=3Dy
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=3Dy
CONFIG_X86_RESERVE_LOW=3D64
CONFIG_MTRR=3Dy
CONFIG_MTRR_SANITIZER=3Dy
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=3D0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=3D1
CONFIG_X86_PAT=3Dy
CONFIG_ARCH_USES_PG_UNCACHED=3Dy
CONFIG_ARCH_RANDOM=3Dy
CONFIG_X86_SMAP=3Dy
CONFIG_X86_INTEL_MPX=3Dy
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=3Dy
CONFIG_EFI=3Dy
CONFIG_EFI_STUB=3Dy
CONFIG_EFI_MIXED=3Dy
CONFIG_SECCOMP=3Dy
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=3Dy
# CONFIG_HZ_1000 is not set
CONFIG_HZ=3D300
CONFIG_SCHED_HRTICK=3Dy
CONFIG_KEXEC=3Dy
CONFIG_KEXEC_FILE=3Dy
# CONFIG_KEXEC_VERIFY_SIG is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_KEXEC_JUMP=3Dy
CONFIG_PHYSICAL_START=3D0x1000000
CONFIG_RELOCATABLE=3Dy
CONFIG_RANDOMIZE_BASE=3Dy
CONFIG_X86_NEED_RELOCS=3Dy
CONFIG_PHYSICAL_ALIGN=3D0x1000000
CONFIG_HOTPLUG_CPU=3Dy
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=3Dy
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=3Dy
CONFIG_HAVE_LIVEPATCH=3Dy
CONFIG_LIVEPATCH=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=3Dy
CONFIG_USE_PERCPU_NUMA_NODE_ID=3Dy

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=3Dy
CONFIG_SUSPEND=3Dy
CONFIG_SUSPEND_FREEZER=3Dy
CONFIG_HIBERNATE_CALLBACKS=3Dy
CONFIG_HIBERNATION=3Dy
CONFIG_PM_STD_PARTITION=3D""
CONFIG_PM_SLEEP=3Dy
CONFIG_PM_SLEEP_SMP=3Dy
CONFIG_PM_AUTOSLEEP=3Dy
CONFIG_PM_WAKELOCKS=3Dy
CONFIG_PM_WAKELOCKS_LIMIT=3D100
CONFIG_PM_WAKELOCKS_GC=3Dy
CONFIG_PM=3Dy
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=3Dy
CONFIG_PM_GENERIC_DOMAINS=3Dy
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_PM_GENERIC_DOMAINS_SLEEP=3Dy
CONFIG_ACPI=3Dy
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=3Dy
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=3Dy
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=3Dy
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_PROCFS_POWER=3Dy
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=3Dy
CONFIG_ACPI_EC_DEBUGFS=3Dm
CONFIG_ACPI_AC=3Dm
CONFIG_ACPI_BATTERY=3Dm
CONFIG_ACPI_BUTTON=3Dm
CONFIG_ACPI_VIDEO=3Dm
CONFIG_ACPI_FAN=3Dm
CONFIG_ACPI_DOCK=3Dy
CONFIG_ACPI_CPU_FREQ_PSS=3Dy
CONFIG_ACPI_PROCESSOR_IDLE=3Dy
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_IPMI=3Dm
CONFIG_ACPI_HOTPLUG_CPU=3Dy
CONFIG_ACPI_PROCESSOR_AGGREGATOR=3Dm
CONFIG_ACPI_THERMAL=3Dm
CONFIG_ACPI_NUMA=3Dy
CONFIG_ACPI_CUSTOM_DSDT_FILE=3D""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_TABLE_UPGRADE=3Dy
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=3Dy
CONFIG_X86_PM_TIMER=3Dy
CONFIG_ACPI_CONTAINER=3Dy
CONFIG_ACPI_HOTPLUG_MEMORY=3Dy
CONFIG_ACPI_HOTPLUG_IOAPIC=3Dy
CONFIG_ACPI_SBS=3Dm
CONFIG_ACPI_HED=3Dy
CONFIG_ACPI_CUSTOM_METHOD=3Dm
CONFIG_ACPI_BGRT=3Dy
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=3Dm
CONFIG_HAVE_ACPI_APEI=3Dy
CONFIG_HAVE_ACPI_APEI_NMI=3Dy
CONFIG_ACPI_APEI=3Dy
CONFIG_ACPI_APEI_GHES=3Dy
CONFIG_ACPI_APEI_PCIEAER=3Dy
CONFIG_ACPI_APEI_MEMORY_FAILURE=3Dy
CONFIG_ACPI_APEI_EINJ=3Dm
CONFIG_ACPI_APEI_ERST_DEBUG=3Dm
CONFIG_ACPI_EXTLOG=3Dm
CONFIG_PMIC_OPREGION=3Dy
CONFIG_SFI=3Dy

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_GOV_ATTR_SET=3Dy
CONFIG_CPU_FREQ_GOV_COMMON=3Dy
CONFIG_CPU_FREQ_STAT=3Dm
CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dm
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dm
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dm
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dm
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=3Dm

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=3Dy
CONFIG_X86_PCC_CPUFREQ=3Dm
CONFIG_X86_ACPI_CPUFREQ=3Dm
CONFIG_X86_ACPI_CPUFREQ_CPB=3Dy
CONFIG_X86_POWERNOW_K8=3Dm
CONFIG_X86_AMD_FREQ_SENSITIVITY=3Dm
CONFIG_X86_SPEEDSTEP_CENTRINO=3Dm
CONFIG_X86_P4_CLOCKMOD=3Dm

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=3Dm

#
# CPU Idle
#
CONFIG_CPU_IDLE=3Dy
CONFIG_CPU_IDLE_GOV_LADDER=3Dy
CONFIG_CPU_IDLE_GOV_MENU=3Dy
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=3Dy

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=3Dy
CONFIG_I7300_IDLE=3Dm

#
# Bus options (PCI etc.)
#
CONFIG_PCI=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_MMCONFIG=3Dy
CONFIG_PCI_XEN=3Dy
CONFIG_PCI_DOMAINS=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_HOTPLUG_PCI_PCIE=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_PCIE_ECRC=3Dy
CONFIG_PCIEAER_INJECT=3Dm
CONFIG_PCIEASPM=3Dy
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=3Dy
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=3Dy
CONFIG_PCIE_DPC=3Dm
CONFIG_PCI_BUS_ADDR_T_64BIT=3Dy
CONFIG_PCI_MSI=3Dy
CONFIG_PCI_MSI_IRQ_DOMAIN=3Dy
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=3Dy
CONFIG_PCI_STUB=3Dm
CONFIG_XEN_PCIDEV_FRONTEND=3Dm
CONFIG_HT_IRQ=3Dy
CONFIG_PCI_ATS=3Dy
CONFIG_PCI_IOV=3Dy
CONFIG_PCI_PRI=3Dy
CONFIG_PCI_PASID=3Dy
CONFIG_PCI_LABEL=3Dy
CONFIG_PCI_HYPERV=3Dm
CONFIG_HOTPLUG_PCI=3Dy
CONFIG_HOTPLUG_PCI_ACPI=3Dy
CONFIG_HOTPLUG_PCI_ACPI_IBM=3Dm
CONFIG_HOTPLUG_PCI_CPCI=3Dy
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=3Dm
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=3Dm
CONFIG_HOTPLUG_PCI_SHPC=3Dm

#
# PCI host controller drivers
#
CONFIG_PCIE_DW_PLAT=3Dy
CONFIG_PCIE_DW=3Dy
CONFIG_ISA_DMA_API=3Dy
CONFIG_AMD_NB=3Dy
CONFIG_PCCARD=3Dm
CONFIG_PCMCIA=3Dm
CONFIG_PCMCIA_LOAD_CIS=3Dy
CONFIG_CARDBUS=3Dy

#
# PC-card bridges
#
CONFIG_YENTA=3Dm
CONFIG_YENTA_O2=3Dy
CONFIG_YENTA_RICOH=3Dy
CONFIG_YENTA_TI=3Dy
CONFIG_YENTA_ENE_TUNE=3Dy
CONFIG_YENTA_TOSHIBA=3Dy
CONFIG_PD6729=3Dm
CONFIG_I82092=3Dm
CONFIG_PCCARD_NONSTATIC=3Dy
CONFIG_RAPIDIO=3Dy
CONFIG_RAPIDIO_TSI721=3Dy
CONFIG_RAPIDIO_DISC_TIMEOUT=3D30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=3Dy
CONFIG_RAPIDIO_DMA_ENGINE=3Dy
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=3Dm
CONFIG_RAPIDIO_MPORT_CDEV=3Dm

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=3Dy
CONFIG_RAPIDIO_CPS_XX=3Dy
CONFIG_RAPIDIO_TSI568=3Dy
CONFIG_RAPIDIO_CPS_GEN2=3Dy
CONFIG_X86_SYSFB=3Dy

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_COMPAT_BINFMT_ELF=3Dy
CONFIG_ELFCORE=3Dy
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=3Dy
CONFIG_BINFMT_SCRIPT=3Dy
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=3Dm
CONFIG_COREDUMP=3Dy
CONFIG_IA32_EMULATION=3Dy
CONFIG_IA32_AOUT=3Dy
CONFIG_X86_X32=3Dy
CONFIG_COMPAT=3Dy
CONFIG_COMPAT_FOR_U64_ALIGNMENT=3Dy
CONFIG_SYSVIPC_COMPAT=3Dy
CONFIG_KEYS_COMPAT=3Dy
CONFIG_X86_DEV_DMA_OPS=3Dy
CONFIG_PMC_ATOM=3Dy
CONFIG_VMD=3Dm
CONFIG_NET=3Dy
CONFIG_COMPAT_NETLINK_MESSAGES=3Dy
CONFIG_NET_INGRESS=3Dy
CONFIG_NET_EGRESS=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
CONFIG_PACKET_DIAG=3Dm
CONFIG_UNIX=3Dy
CONFIG_UNIX_DIAG=3Dm
CONFIG_XFRM=3Dy
CONFIG_XFRM_ALGO=3Dm
CONFIG_XFRM_USER=3Dm
CONFIG_XFRM_SUB_POLICY=3Dy
CONFIG_XFRM_MIGRATE=3Dy
CONFIG_XFRM_STATISTICS=3Dy
CONFIG_XFRM_IPCOMP=3Dm
CONFIG_NET_KEY=3Dm
CONFIG_NET_KEY_MIGRATE=3Dy
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
CONFIG_IP_ADVANCED_ROUTER=3Dy
CONFIG_IP_FIB_TRIE_STATS=3Dy
CONFIG_IP_MULTIPLE_TABLES=3Dy
CONFIG_IP_ROUTE_MULTIPATH=3Dy
CONFIG_IP_ROUTE_VERBOSE=3Dy
CONFIG_IP_ROUTE_CLASSID=3Dy
CONFIG_IP_PNP=3Dy
CONFIG_IP_PNP_DHCP=3Dy
CONFIG_IP_PNP_BOOTP=3Dy
CONFIG_IP_PNP_RARP=3Dy
CONFIG_NET_IPIP=3Dm
CONFIG_NET_IPGRE_DEMUX=3Dm
CONFIG_NET_IP_TUNNEL=3Dm
CONFIG_NET_IPGRE=3Dm
CONFIG_NET_IPGRE_BROADCAST=3Dy
CONFIG_IP_MROUTE=3Dy
CONFIG_IP_MROUTE_MULTIPLE_TABLES=3Dy
CONFIG_IP_PIMSM_V1=3Dy
CONFIG_IP_PIMSM_V2=3Dy
CONFIG_SYN_COOKIES=3Dy
CONFIG_NET_IPVTI=3Dm
CONFIG_NET_UDP_TUNNEL=3Dm
CONFIG_NET_FOU=3Dm
CONFIG_NET_FOU_IP_TUNNELS=3Dy
CONFIG_INET_AH=3Dm
CONFIG_INET_ESP=3Dm
CONFIG_INET_IPCOMP=3Dm
CONFIG_INET_XFRM_TUNNEL=3Dm
CONFIG_INET_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_TRANSPORT=3Dm
CONFIG_INET_XFRM_MODE_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_BEET=3Dm
CONFIG_INET_DIAG=3Dm
CONFIG_INET_TCP_DIAG=3Dm
CONFIG_INET_UDP_DIAG=3Dm
CONFIG_INET_DIAG_DESTROY=3Dy
CONFIG_TCP_CONG_ADVANCED=3Dy
CONFIG_TCP_CONG_BIC=3Dm
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_TCP_CONG_WESTWOOD=3Dm
CONFIG_TCP_CONG_HTCP=3Dm
CONFIG_TCP_CONG_HSTCP=3Dm
CONFIG_TCP_CONG_HYBLA=3Dm
CONFIG_TCP_CONG_VEGAS=3Dm
CONFIG_TCP_CONG_SCALABLE=3Dm
CONFIG_TCP_CONG_LP=3Dm
CONFIG_TCP_CONG_VENO=3Dm
CONFIG_TCP_CONG_YEAH=3Dm
CONFIG_TCP_CONG_ILLINOIS=3Dm
CONFIG_TCP_CONG_DCTCP=3Dm
CONFIG_TCP_CONG_CDG=3Dm
CONFIG_DEFAULT_CUBIC=3Dy
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
CONFIG_TCP_MD5SIG=3Dy
CONFIG_IPV6=3Dy
CONFIG_IPV6_ROUTER_PREF=3Dy
CONFIG_IPV6_ROUTE_INFO=3Dy
CONFIG_IPV6_OPTIMISTIC_DAD=3Dy
CONFIG_INET6_AH=3Dm
CONFIG_INET6_ESP=3Dm
CONFIG_INET6_IPCOMP=3Dm
CONFIG_IPV6_MIP6=3Dy
CONFIG_IPV6_ILA=3Dm
CONFIG_INET6_XFRM_TUNNEL=3Dm
CONFIG_INET6_TUNNEL=3Dm
CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dm
CONFIG_INET6_XFRM_MODE_TUNNEL=3Dm
CONFIG_INET6_XFRM_MODE_BEET=3Dm
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=3Dm
CONFIG_IPV6_VTI=3Dm
CONFIG_IPV6_SIT=3Dm
CONFIG_IPV6_SIT_6RD=3Dy
CONFIG_IPV6_NDISC_NODETYPE=3Dy
CONFIG_IPV6_TUNNEL=3Dm
CONFIG_IPV6_GRE=3Dm
CONFIG_IPV6_FOU=3Dm
CONFIG_IPV6_FOU_TUNNEL=3Dm
CONFIG_IPV6_MULTIPLE_TABLES=3Dy
CONFIG_IPV6_SUBTREES=3Dy
CONFIG_IPV6_MROUTE=3Dy
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=3Dy
CONFIG_IPV6_PIMSM_V2=3Dy
CONFIG_NETLABEL=3Dy
CONFIG_NETWORK_SECMARK=3Dy
CONFIG_NET_PTP_CLASSIFY=3Dy
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=3Dy
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=3Dy
CONFIG_BRIDGE_NETFILTER=3Dm

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=3Dy
CONFIG_NETFILTER_NETLINK=3Dm
CONFIG_NETFILTER_NETLINK_ACCT=3Dm
CONFIG_NETFILTER_NETLINK_QUEUE=3Dm
CONFIG_NETFILTER_NETLINK_LOG=3Dm
CONFIG_NF_CONNTRACK=3Dm
CONFIG_NF_LOG_COMMON=3Dm
CONFIG_NF_CONNTRACK_MARK=3Dy
CONFIG_NF_CONNTRACK_SECMARK=3Dy
CONFIG_NF_CONNTRACK_ZONES=3Dy
# CONFIG_NF_CONNTRACK_PROCFS is not set
CONFIG_NF_CONNTRACK_EVENTS=3Dy
CONFIG_NF_CONNTRACK_TIMEOUT=3Dy
CONFIG_NF_CONNTRACK_TIMESTAMP=3Dy
CONFIG_NF_CONNTRACK_LABELS=3Dy
CONFIG_NF_CT_PROTO_DCCP=3Dm
CONFIG_NF_CT_PROTO_GRE=3Dm
CONFIG_NF_CT_PROTO_SCTP=3Dm
CONFIG_NF_CT_PROTO_UDPLITE=3Dm
CONFIG_NF_CONNTRACK_AMANDA=3Dm
CONFIG_NF_CONNTRACK_FTP=3Dm
CONFIG_NF_CONNTRACK_H323=3Dm
CONFIG_NF_CONNTRACK_IRC=3Dm
CONFIG_NF_CONNTRACK_BROADCAST=3Dm
CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dm
CONFIG_NF_CONNTRACK_SNMP=3Dm
CONFIG_NF_CONNTRACK_PPTP=3Dm
CONFIG_NF_CONNTRACK_SANE=3Dm
CONFIG_NF_CONNTRACK_SIP=3Dm
CONFIG_NF_CONNTRACK_TFTP=3Dm
CONFIG_NF_CT_NETLINK=3Dm
CONFIG_NF_CT_NETLINK_TIMEOUT=3Dm
CONFIG_NF_CT_NETLINK_HELPER=3Dm
CONFIG_NETFILTER_NETLINK_GLUE_CT=3Dy
CONFIG_NF_NAT=3Dm
CONFIG_NF_NAT_NEEDED=3Dy
CONFIG_NF_NAT_PROTO_DCCP=3Dm
CONFIG_NF_NAT_PROTO_UDPLITE=3Dm
CONFIG_NF_NAT_PROTO_SCTP=3Dm
CONFIG_NF_NAT_AMANDA=3Dm
CONFIG_NF_NAT_FTP=3Dm
CONFIG_NF_NAT_IRC=3Dm
CONFIG_NF_NAT_SIP=3Dm
CONFIG_NF_NAT_TFTP=3Dm
CONFIG_NF_NAT_REDIRECT=3Dm
CONFIG_NETFILTER_SYNPROXY=3Dm
CONFIG_NF_TABLES=3Dm
CONFIG_NF_TABLES_INET=3Dm
CONFIG_NF_TABLES_NETDEV=3Dm
CONFIG_NFT_EXTHDR=3Dm
CONFIG_NFT_META=3Dm
CONFIG_NFT_CT=3Dm
CONFIG_NFT_RBTREE=3Dm
CONFIG_NFT_HASH=3Dm
CONFIG_NFT_COUNTER=3Dm
CONFIG_NFT_LOG=3Dm
CONFIG_NFT_LIMIT=3Dm
CONFIG_NFT_MASQ=3Dm
CONFIG_NFT_REDIR=3Dm
CONFIG_NFT_NAT=3Dm
CONFIG_NFT_QUEUE=3Dm
CONFIG_NFT_REJECT=3Dm
CONFIG_NFT_REJECT_INET=3Dm
CONFIG_NFT_COMPAT=3Dm
CONFIG_NF_DUP_NETDEV=3Dm
CONFIG_NFT_DUP_NETDEV=3Dm
CONFIG_NFT_FWD_NETDEV=3Dm
CONFIG_NETFILTER_XTABLES=3Dm

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=3Dm
CONFIG_NETFILTER_XT_CONNMARK=3Dm
CONFIG_NETFILTER_XT_SET=3Dm

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=3Dm
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=3Dm
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dm
CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_CT=3Dm
CONFIG_NETFILTER_XT_TARGET_DSCP=3Dm
CONFIG_NETFILTER_XT_TARGET_HL=3Dm
CONFIG_NETFILTER_XT_TARGET_HMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=3Dm
CONFIG_NETFILTER_XT_TARGET_LED=3Dm
CONFIG_NETFILTER_XT_TARGET_LOG=3Dm
CONFIG_NETFILTER_XT_TARGET_IMQ=3Dm
CONFIG_NETFILTER_XT_TARGET_MARK=3Dm
CONFIG_NETFILTER_XT_NAT=3Dm
CONFIG_NETFILTER_XT_TARGET_NETMAP=3Dm
CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dm
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dm
CONFIG_NETFILTER_XT_TARGET_NOTRACK=3Dm
CONFIG_NETFILTER_XT_TARGET_RATEEST=3Dm
CONFIG_NETFILTER_XT_TARGET_REDIRECT=3Dm
CONFIG_NETFILTER_XT_TARGET_TEE=3Dm
CONFIG_NETFILTER_XT_TARGET_TPROXY=3Dm
CONFIG_NETFILTER_XT_TARGET_TRACE=3Dm
CONFIG_NETFILTER_XT_TARGET_SECMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=3Dm

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=3Dm
CONFIG_NETFILTER_XT_MATCH_BPF=3Dm
CONFIG_NETFILTER_XT_MATCH_CGROUP=3Dm
CONFIG_NETFILTER_XT_MATCH_CLUSTER=3Dm
CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
CONFIG_NETFILTER_XT_MATCH_CPU=3Dm
CONFIG_NETFILTER_XT_MATCH_DCCP=3Dm
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=3Dm
CONFIG_NETFILTER_XT_MATCH_DSCP=3Dm
CONFIG_NETFILTER_XT_MATCH_ECN=3Dm
CONFIG_NETFILTER_XT_MATCH_ESP=3Dm
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
CONFIG_NETFILTER_XT_MATCH_HL=3Dm
CONFIG_NETFILTER_XT_MATCH_IPCOMP=3Dm
CONFIG_NETFILTER_XT_MATCH_IPRANGE=3Dm
CONFIG_NETFILTER_XT_MATCH_IPVS=3Dm
CONFIG_NETFILTER_XT_MATCH_L2TP=3Dm
CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dm
CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_MAC=3Dm
CONFIG_NETFILTER_XT_MATCH_MARK=3Dm
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dm
CONFIG_NETFILTER_XT_MATCH_NFACCT=3Dm
CONFIG_NETFILTER_XT_MATCH_OSF=3Dm
CONFIG_NETFILTER_XT_MATCH_OWNER=3Dm
CONFIG_NETFILTER_XT_MATCH_POLICY=3Dm
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dm
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dm
CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
CONFIG_NETFILTER_XT_MATCH_RATEEST=3Dm
CONFIG_NETFILTER_XT_MATCH_REALM=3Dm
CONFIG_NETFILTER_XT_MATCH_RECENT=3Dm
CONFIG_NETFILTER_XT_MATCH_SCTP=3Dm
CONFIG_NETFILTER_XT_MATCH_SOCKET=3Dm
CONFIG_NETFILTER_XT_MATCH_STATE=3Dm
CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
CONFIG_NETFILTER_XT_MATCH_STRING=3Dm
CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dm
CONFIG_NETFILTER_XT_MATCH_TIME=3Dm
CONFIG_NETFILTER_XT_MATCH_U32=3Dm
CONFIG_IP_SET=3Dm
CONFIG_IP_SET_MAX=3D256
CONFIG_IP_SET_BITMAP_IP=3Dm
CONFIG_IP_SET_BITMAP_IPMAC=3Dm
CONFIG_IP_SET_BITMAP_PORT=3Dm
CONFIG_IP_SET_HASH_IP=3Dm
CONFIG_IP_SET_HASH_IPMARK=3Dm
CONFIG_IP_SET_HASH_IPPORT=3Dm
CONFIG_IP_SET_HASH_IPPORTIP=3Dm
CONFIG_IP_SET_HASH_IPPORTNET=3Dm
CONFIG_IP_SET_HASH_MAC=3Dm
CONFIG_IP_SET_HASH_NETPORTNET=3Dm
CONFIG_IP_SET_HASH_NET=3Dm
CONFIG_IP_SET_HASH_NETNET=3Dm
CONFIG_IP_SET_HASH_NETPORT=3Dm
CONFIG_IP_SET_HASH_NETIFACE=3Dm
CONFIG_IP_SET_LIST_SET=3Dm
CONFIG_IP_VS=3Dm
CONFIG_IP_VS_IPV6=3Dy
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=3D12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=3Dy
CONFIG_IP_VS_PROTO_UDP=3Dy
CONFIG_IP_VS_PROTO_AH_ESP=3Dy
CONFIG_IP_VS_PROTO_ESP=3Dy
CONFIG_IP_VS_PROTO_AH=3Dy
CONFIG_IP_VS_PROTO_SCTP=3Dy

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=3Dm
CONFIG_IP_VS_WRR=3Dm
CONFIG_IP_VS_LC=3Dm
CONFIG_IP_VS_WLC=3Dm
CONFIG_IP_VS_FO=3Dm
CONFIG_IP_VS_OVF=3Dm
CONFIG_IP_VS_LBLC=3Dm
CONFIG_IP_VS_LBLCR=3Dm
CONFIG_IP_VS_DH=3Dm
CONFIG_IP_VS_SH=3Dm
CONFIG_IP_VS_SED=3Dm
CONFIG_IP_VS_NQ=3Dm

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=3D8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=3Dm
CONFIG_IP_VS_NFCT=3Dy
CONFIG_IP_VS_PE_SIP=3Dm

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=3Dm
CONFIG_NF_CONNTRACK_IPV4=3Dm
CONFIG_NF_TABLES_IPV4=3Dm
CONFIG_NFT_CHAIN_ROUTE_IPV4=3Dm
CONFIG_NFT_REJECT_IPV4=3Dm
CONFIG_NFT_DUP_IPV4=3Dm
CONFIG_NF_TABLES_ARP=3Dm
CONFIG_NF_DUP_IPV4=3Dm
CONFIG_NF_LOG_ARP=3Dm
CONFIG_NF_LOG_IPV4=3Dm
CONFIG_NF_REJECT_IPV4=3Dm
CONFIG_NF_NAT_IPV4=3Dm
CONFIG_NFT_CHAIN_NAT_IPV4=3Dm
CONFIG_NF_NAT_MASQUERADE_IPV4=3Dm
CONFIG_NFT_MASQ_IPV4=3Dm
CONFIG_NFT_REDIR_IPV4=3Dm
CONFIG_NF_NAT_SNMP_BASIC=3Dm
CONFIG_NF_NAT_PROTO_GRE=3Dm
CONFIG_NF_NAT_PPTP=3Dm
CONFIG_NF_NAT_H323=3Dm
CONFIG_IP_NF_IPTABLES=3Dm
CONFIG_IP_NF_MATCH_AH=3Dm
CONFIG_IP_NF_MATCH_ECN=3Dm
CONFIG_IP_NF_MATCH_RPFILTER=3Dm
CONFIG_IP_NF_MATCH_TTL=3Dm
CONFIG_IP_NF_FILTER=3Dm
CONFIG_IP_NF_TARGET_REJECT=3Dm
CONFIG_IP_NF_TARGET_SYNPROXY=3Dm
CONFIG_IP_NF_NAT=3Dm
CONFIG_IP_NF_TARGET_MASQUERADE=3Dm
CONFIG_IP_NF_TARGET_NETMAP=3Dm
CONFIG_IP_NF_TARGET_REDIRECT=3Dm
CONFIG_IP_NF_MANGLE=3Dm
CONFIG_IP_NF_TARGET_CLUSTERIP=3Dm
CONFIG_IP_NF_TARGET_ECN=3Dm
CONFIG_IP_NF_TARGET_TTL=3Dm
CONFIG_IP_NF_RAW=3Dm
CONFIG_IP_NF_SECURITY=3Dm
CONFIG_IP_NF_ARPTABLES=3Dm
CONFIG_IP_NF_ARPFILTER=3Dm
CONFIG_IP_NF_ARP_MANGLE=3Dm
CONFIG_IP_NF_TARGET_IPV4OPTSSTRIP=3Dm

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=3Dm
CONFIG_NF_CONNTRACK_IPV6=3Dm
CONFIG_NF_TABLES_IPV6=3Dm
CONFIG_NFT_CHAIN_ROUTE_IPV6=3Dm
CONFIG_NFT_REJECT_IPV6=3Dm
CONFIG_NFT_DUP_IPV6=3Dm
CONFIG_NF_DUP_IPV6=3Dm
CONFIG_NF_REJECT_IPV6=3Dm
CONFIG_NF_LOG_IPV6=3Dm
CONFIG_NF_NAT_IPV6=3Dm
CONFIG_NFT_CHAIN_NAT_IPV6=3Dm
CONFIG_NF_NAT_MASQUERADE_IPV6=3Dm
CONFIG_NFT_MASQ_IPV6=3Dm
CONFIG_NFT_REDIR_IPV6=3Dm
CONFIG_IP6_NF_IPTABLES=3Dm
CONFIG_IP6_NF_MATCH_AH=3Dm
CONFIG_IP6_NF_MATCH_EUI64=3Dm
CONFIG_IP6_NF_MATCH_FRAG=3Dm
CONFIG_IP6_NF_MATCH_OPTS=3Dm
CONFIG_IP6_NF_MATCH_HL=3Dm
CONFIG_IP6_NF_MATCH_IPV6HEADER=3Dm
CONFIG_IP6_NF_MATCH_MH=3Dm
CONFIG_IP6_NF_MATCH_RPFILTER=3Dm
CONFIG_IP6_NF_MATCH_RT=3Dm
CONFIG_IP6_NF_TARGET_HL=3Dm
CONFIG_IP6_NF_FILTER=3Dm
CONFIG_IP6_NF_TARGET_REJECT=3Dm
CONFIG_IP6_NF_TARGET_SYNPROXY=3Dm
CONFIG_IP6_NF_MANGLE=3Dm
CONFIG_IP6_NF_RAW=3Dm
CONFIG_IP6_NF_SECURITY=3Dm
CONFIG_IP6_NF_NAT=3Dm
CONFIG_IP6_NF_TARGET_MASQUERADE=3Dm
CONFIG_IP6_NF_TARGET_NPT=3Dm

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=3Dm
CONFIG_NF_TABLES_BRIDGE=3Dm
CONFIG_NFT_BRIDGE_META=3Dm
CONFIG_NFT_BRIDGE_REJECT=3Dm
CONFIG_NF_LOG_BRIDGE=3Dm
CONFIG_BRIDGE_NF_EBTABLES=3Dm
CONFIG_BRIDGE_EBT_BROUTE=3Dm
CONFIG_BRIDGE_EBT_T_FILTER=3Dm
CONFIG_BRIDGE_EBT_T_NAT=3Dm
CONFIG_BRIDGE_EBT_802_3=3Dm
CONFIG_BRIDGE_EBT_AMONG=3Dm
CONFIG_BRIDGE_EBT_ARP=3Dm
CONFIG_BRIDGE_EBT_IP=3Dm
CONFIG_BRIDGE_EBT_IP6=3Dm
CONFIG_BRIDGE_EBT_LIMIT=3Dm
CONFIG_BRIDGE_EBT_MARK=3Dm
CONFIG_BRIDGE_EBT_PKTTYPE=3Dm
CONFIG_BRIDGE_EBT_STP=3Dm
CONFIG_BRIDGE_EBT_VLAN=3Dm
CONFIG_BRIDGE_EBT_ARPREPLY=3Dm
CONFIG_BRIDGE_EBT_DNAT=3Dm
CONFIG_BRIDGE_EBT_MARK_T=3Dm
CONFIG_BRIDGE_EBT_REDIRECT=3Dm
CONFIG_BRIDGE_EBT_SNAT=3Dm
CONFIG_BRIDGE_EBT_LOG=3Dm
CONFIG_BRIDGE_EBT_NFLOG=3Dm
CONFIG_IP_DCCP=3Dm
CONFIG_INET_DCCP_DIAG=3Dm

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=3Dy
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=3Dy

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_NET_DCCPPROBE=3Dm
CONFIG_IP_SCTP=3Dm
CONFIG_NET_SCTPPROBE=3Dm
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=3Dy
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=3Dy
CONFIG_SCTP_COOKIE_HMAC_SHA1=3Dy
CONFIG_INET_SCTP_DIAG=3Dm
CONFIG_RDS=3Dm
CONFIG_RDS_RDMA=3Dm
CONFIG_RDS_TCP=3Dm
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=3Dm
CONFIG_TIPC_MEDIA_IB=3Dy
CONFIG_TIPC_MEDIA_UDP=3Dy
CONFIG_ATM=3Dm
CONFIG_ATM_CLIP=3Dm
CONFIG_ATM_CLIP_NO_ICMP=3Dy
CONFIG_ATM_LANE=3Dm
CONFIG_ATM_MPOA=3Dm
CONFIG_ATM_BR2684=3Dm
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=3Dm
CONFIG_L2TP_DEBUGFS=3Dm
CONFIG_L2TP_V3=3Dy
CONFIG_L2TP_IP=3Dm
CONFIG_L2TP_ETH=3Dm
CONFIG_STP=3Dm
CONFIG_GARP=3Dm
CONFIG_MRP=3Dm
CONFIG_BRIDGE=3Dm
CONFIG_BRIDGE_IGMP_SNOOPING=3Dy
CONFIG_BRIDGE_VLAN_FILTERING=3Dy
CONFIG_HAVE_NET_DSA=3Dy
CONFIG_NET_DSA=3Dy
CONFIG_NET_DSA_TAG_BRCM=3Dy
CONFIG_NET_DSA_TAG_EDSA=3Dy
CONFIG_NET_DSA_TAG_TRAILER=3Dy
CONFIG_VLAN_8021Q=3Dm
CONFIG_VLAN_8021Q_GVRP=3Dy
CONFIG_VLAN_8021Q_MVRP=3Dy
CONFIG_DECNET=3Dm
CONFIG_DECNET_ROUTER=3Dy
CONFIG_LLC=3Dm
CONFIG_LLC2=3Dm
CONFIG_IPX=3Dm
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=3Dm
CONFIG_DEV_APPLETALK=3Dm
CONFIG_IPDDP=3Dm
CONFIG_IPDDP_ENCAP=3Dy
CONFIG_X25=3Dm
CONFIG_LAPB=3Dm
CONFIG_PHONET=3Dm
CONFIG_6LOWPAN=3Dm
CONFIG_6LOWPAN_DEBUGFS=3Dy
CONFIG_6LOWPAN_NHC=3Dm
CONFIG_6LOWPAN_NHC_DEST=3Dm
CONFIG_6LOWPAN_NHC_FRAGMENT=3Dm
CONFIG_6LOWPAN_NHC_HOP=3Dm
CONFIG_6LOWPAN_NHC_IPV6=3Dm
CONFIG_6LOWPAN_NHC_MOBILITY=3Dm
CONFIG_6LOWPAN_NHC_ROUTING=3Dm
CONFIG_6LOWPAN_NHC_UDP=3Dm
CONFIG_6LOWPAN_GHC_EXT_HDR_HOP=3Dm
CONFIG_6LOWPAN_GHC_UDP=3Dm
CONFIG_6LOWPAN_GHC_ICMPV6=3Dm
CONFIG_6LOWPAN_GHC_EXT_HDR_DEST=3Dm
CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=3Dm
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=3Dm
CONFIG_IEEE802154=3Dm
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=3Dy
CONFIG_IEEE802154_SOCKET=3Dm
CONFIG_IEEE802154_6LOWPAN=3Dm
CONFIG_MAC802154=3Dm
CONFIG_NET_SCHED=3Dy

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=3Dm
CONFIG_NET_SCH_HTB=3Dm
CONFIG_NET_SCH_HFSC=3Dm
CONFIG_NET_SCH_ATM=3Dm
CONFIG_NET_SCH_PRIO=3Dm
CONFIG_NET_SCH_MULTIQ=3Dm
CONFIG_NET_SCH_RED=3Dm
CONFIG_NET_SCH_SFB=3Dm
CONFIG_NET_SCH_SFQ=3Dm
CONFIG_NET_SCH_ESFQ=3Dm
CONFIG_NET_SCH_ESFQ_NFCT=3Dy
CONFIG_NET_SCH_TEQL=3Dm
CONFIG_NET_SCH_TBF=3Dm
CONFIG_NET_SCH_GRED=3Dm
CONFIG_NET_SCH_DSMARK=3Dm
CONFIG_NET_SCH_NETEM=3Dm
CONFIG_NET_SCH_DRR=3Dm
CONFIG_NET_SCH_MQPRIO=3Dm
CONFIG_NET_SCH_CHOKE=3Dm
CONFIG_NET_SCH_QFQ=3Dm
CONFIG_NET_SCH_CODEL=3Dm
CONFIG_NET_SCH_FQ_CODEL=3Dm
CONFIG_NET_SCH_FQ=3Dm
CONFIG_NET_SCH_HHF=3Dm
CONFIG_NET_SCH_PIE=3Dm
CONFIG_NET_SCH_INGRESS=3Dm
CONFIG_NET_SCH_PLUG=3Dm

#
# Classification
#
CONFIG_NET_CLS=3Dy
CONFIG_NET_CLS_BASIC=3Dm
CONFIG_NET_CLS_TCINDEX=3Dm
CONFIG_NET_CLS_ROUTE4=3Dm
CONFIG_NET_CLS_FW=3Dm
CONFIG_NET_CLS_U32=3Dm
CONFIG_CLS_U32_PERF=3Dy
CONFIG_CLS_U32_MARK=3Dy
CONFIG_NET_CLS_RSVP=3Dm
CONFIG_NET_CLS_RSVP6=3Dm
CONFIG_NET_CLS_FLOW=3Dm
CONFIG_NET_CLS_CGROUP=3Dy
CONFIG_NET_CLS_BPF=3Dm
CONFIG_NET_CLS_FLOWER=3Dm
CONFIG_NET_EMATCH=3Dy
CONFIG_NET_EMATCH_STACK=3D32
CONFIG_NET_EMATCH_CMP=3Dm
CONFIG_NET_EMATCH_NBYTE=3Dm
CONFIG_NET_EMATCH_U32=3Dm
CONFIG_NET_EMATCH_META=3Dm
CONFIG_NET_EMATCH_TEXT=3Dm
CONFIG_NET_EMATCH_CANID=3Dm
CONFIG_NET_EMATCH_IPSET=3Dm
CONFIG_NET_CLS_ACT=3Dy
CONFIG_NET_ACT_POLICE=3Dm
CONFIG_NET_ACT_GACT=3Dm
CONFIG_GACT_PROB=3Dy
CONFIG_NET_ACT_MIRRED=3Dm
CONFIG_NET_ACT_IPT=3Dm
CONFIG_NET_ACT_NAT=3Dm
CONFIG_NET_ACT_PEDIT=3Dm
CONFIG_NET_ACT_SIMP=3Dm
CONFIG_NET_ACT_SKBEDIT=3Dm
CONFIG_NET_ACT_CSUM=3Dm
CONFIG_NET_ACT_VLAN=3Dm
CONFIG_NET_ACT_BPF=3Dm
CONFIG_NET_ACT_CONNMARK=3Dm
CONFIG_NET_ACT_IFE=3Dm
CONFIG_NET_IFE_SKBMARK=3Dm
CONFIG_NET_IFE_SKBPRIO=3Dm
CONFIG_NET_CLS_IND=3Dy
CONFIG_NET_SCH_FIFO=3Dy
CONFIG_DCB=3Dy
CONFIG_DNS_RESOLVER=3Dm
CONFIG_BATMAN_ADV=3Dm
CONFIG_BATMAN_ADV_BATMAN_V=3Dy
CONFIG_BATMAN_ADV_BLA=3Dy
CONFIG_BATMAN_ADV_DAT=3Dy
CONFIG_BATMAN_ADV_NC=3Dy
CONFIG_BATMAN_ADV_MCAST=3Dy
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=3Dm
CONFIG_OPENVSWITCH_GRE=3Dm
CONFIG_OPENVSWITCH_VXLAN=3Dm
CONFIG_OPENVSWITCH_GENEVE=3Dm
CONFIG_VSOCKETS=3Dm
CONFIG_VMWARE_VMCI_VSOCKETS=3Dm
CONFIG_NETLINK_DIAG=3Dm
CONFIG_MPLS=3Dy
CONFIG_NET_MPLS_GSO=3Dm
CONFIG_MPLS_ROUTING=3Dm
CONFIG_MPLS_IPTUNNEL=3Dm
CONFIG_HSR=3Dm
CONFIG_NET_SWITCHDEV=3Dy
CONFIG_NET_L3_MASTER_DEV=3Dy
CONFIG_RPS=3Dy
CONFIG_RFS_ACCEL=3Dy
CONFIG_XPS=3Dy
CONFIG_SOCK_CGROUP_DATA=3Dy
CONFIG_CGROUP_NET_PRIO=3Dy
CONFIG_CGROUP_NET_CLASSID=3Dy
CONFIG_NET_RX_BUSY_POLL=3Dy
CONFIG_BQL=3Dy
CONFIG_BPF_JIT=3Dy
CONFIG_NET_FLOW_LIMIT=3Dy

#
# Network testing
#
CONFIG_NET_PKTGEN=3Dm
CONFIG_NET_TCPPROBE=3Dm
CONFIG_NET_DROP_MONITOR=3Dy
CONFIG_HAMRADIO=3Dy

#
# Packet Radio protocols
#
CONFIG_AX25=3Dm
CONFIG_AX25_DAMA_SLAVE=3Dy
CONFIG_NETROM=3Dm
CONFIG_ROSE=3Dm

#
# AX.25 network device drivers
#
CONFIG_MKISS=3Dm
CONFIG_6PACK=3Dm
CONFIG_BPQETHER=3Dm
CONFIG_BAYCOM_SER_FDX=3Dm
CONFIG_BAYCOM_SER_HDX=3Dm
CONFIG_BAYCOM_PAR=3Dm
CONFIG_YAM=3Dm
CONFIG_CAN=3Dm
CONFIG_CAN_RAW=3Dm
CONFIG_CAN_BCM=3Dm
CONFIG_CAN_GW=3Dm

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=3Dm
CONFIG_CAN_SLCAN=3Dm
CONFIG_CAN_DEV=3Dm
CONFIG_CAN_CALC_BITTIMING=3Dy
CONFIG_CAN_LEDS=3Dy
CONFIG_CAN_JANZ_ICAN3=3Dm
CONFIG_CAN_C_CAN=3Dm
CONFIG_CAN_C_CAN_PLATFORM=3Dm
CONFIG_CAN_C_CAN_PCI=3Dm
CONFIG_CAN_CC770=3Dm
CONFIG_CAN_CC770_ISA=3Dm
CONFIG_CAN_CC770_PLATFORM=3Dm
CONFIG_CAN_IFI_CANFD=3Dm
CONFIG_CAN_M_CAN=3Dm
CONFIG_CAN_SJA1000=3Dm
CONFIG_CAN_SJA1000_ISA=3Dm
CONFIG_CAN_SJA1000_PLATFORM=3Dm
CONFIG_CAN_EMS_PCMCIA=3Dm
CONFIG_CAN_EMS_PCI=3Dm
CONFIG_CAN_PEAK_PCMCIA=3Dm
CONFIG_CAN_PEAK_PCI=3Dm
CONFIG_CAN_PEAK_PCIEC=3Dy
CONFIG_CAN_KVASER_PCI=3Dm
CONFIG_CAN_PLX_PCI=3Dm
CONFIG_CAN_SOFTING=3Dm
CONFIG_CAN_SOFTING_CS=3Dm

#
# CAN SPI interfaces
#
CONFIG_CAN_MCP251X=3Dm

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=3Dm
CONFIG_CAN_ESD_USB2=3Dm
CONFIG_CAN_GS_USB=3Dm
CONFIG_CAN_KVASER_USB=3Dm
CONFIG_CAN_PEAK_USB=3Dm
CONFIG_CAN_8DEV_USB=3Dm
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=3Dm

#
# IrDA protocols
#
CONFIG_IRLAN=3Dm
CONFIG_IRNET=3Dm
CONFIG_IRCOMM=3Dm
CONFIG_IRDA_ULTRA=3Dy

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=3Dy
CONFIG_IRDA_FAST_RR=3Dy
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=3Dm

#
# Dongle support
#
CONFIG_DONGLE=3Dy
CONFIG_ESI_DONGLE=3Dm
CONFIG_ACTISYS_DONGLE=3Dm
CONFIG_TEKRAM_DONGLE=3Dm
CONFIG_TOIM3232_DONGLE=3Dm
CONFIG_LITELINK_DONGLE=3Dm
CONFIG_MA600_DONGLE=3Dm
CONFIG_GIRBIL_DONGLE=3Dm
CONFIG_MCP2120_DONGLE=3Dm
CONFIG_OLD_BELKIN_DONGLE=3Dm
CONFIG_ACT200L_DONGLE=3Dm
CONFIG_KINGSUN_DONGLE=3Dm
CONFIG_KSDAZZLE_DONGLE=3Dm
CONFIG_KS959_DONGLE=3Dm

#
# FIR device drivers
#
CONFIG_USB_IRDA=3Dm
CONFIG_SIGMATEL_FIR=3Dm
CONFIG_NSC_FIR=3Dm
CONFIG_WINBOND_FIR=3Dm
CONFIG_SMC_IRCC_FIR=3Dm
CONFIG_ALI_FIR=3Dm
CONFIG_VLSI_FIR=3Dm
CONFIG_VIA_FIR=3Dm
CONFIG_MCS_FIR=3Dm
CONFIG_BT=3Dm
CONFIG_BT_BREDR=3Dy
CONFIG_BT_RFCOMM=3Dm
CONFIG_BT_RFCOMM_TTY=3Dy
CONFIG_BT_BNEP=3Dm
CONFIG_BT_BNEP_MC_FILTER=3Dy
CONFIG_BT_BNEP_PROTO_FILTER=3Dy
CONFIG_BT_CMTP=3Dm
CONFIG_BT_HIDP=3Dm
CONFIG_BT_HS=3Dy
CONFIG_BT_LE=3Dy
CONFIG_BT_6LOWPAN=3Dm
CONFIG_BT_LEDS=3Dy
# CONFIG_BT_SELFTEST is not set
# CONFIG_BT_DEBUGFS is not set

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=3Dm
CONFIG_BT_BCM=3Dm
CONFIG_BT_RTL=3Dm
CONFIG_BT_QCA=3Dm
CONFIG_BT_HCIBTUSB=3Dm
CONFIG_BT_HCIBTUSB_BCM=3Dy
CONFIG_BT_HCIBTUSB_RTL=3Dy
CONFIG_BT_HCIBTSDIO=3Dm
CONFIG_BT_HCIUART=3Dm
CONFIG_BT_HCIUART_H4=3Dy
CONFIG_BT_HCIUART_BCSP=3Dy
CONFIG_BT_HCIUART_ATH3K=3Dy
CONFIG_BT_HCIUART_LL=3Dy
CONFIG_BT_HCIUART_3WIRE=3Dy
CONFIG_BT_HCIUART_INTEL=3Dy
CONFIG_BT_HCIUART_BCM=3Dy
CONFIG_BT_HCIUART_QCA=3Dy
CONFIG_BT_HCIUART_AG6XX=3Dy
CONFIG_BT_HCIBCM203X=3Dm
CONFIG_BT_HCIBPA10X=3Dm
CONFIG_BT_HCIBFUSB=3Dm
CONFIG_BT_HCIDTL1=3Dm
CONFIG_BT_HCIBT3C=3Dm
CONFIG_BT_HCIBLUECARD=3Dm
CONFIG_BT_HCIBTUART=3Dm
CONFIG_BT_HCIVHCI=3Dm
CONFIG_BT_MRVL=3Dm
CONFIG_BT_MRVL_SDIO=3Dm
CONFIG_BT_ATH3K=3Dm
CONFIG_BT_WILINK=3Dm
CONFIG_AF_RXRPC=3Dm
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=3Dy
CONFIG_AF_KCM=3Dm
CONFIG_FIB_RULES=3Dy
CONFIG_WIRELESS=3Dy
CONFIG_WIRELESS_EXT=3Dy
CONFIG_WEXT_CORE=3Dy
CONFIG_WEXT_PROC=3Dy
CONFIG_WEXT_SPY=3Dy
CONFIG_WEXT_PRIV=3Dy
CONFIG_CFG80211=3Dm
CONFIG_NL80211_TESTMODE=3Dy
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
CONFIG_CFG80211_DEFAULT_PS=3Dy
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=3Dy
CONFIG_CFG80211_WEXT=3Dy
CONFIG_CFG80211_WEXT_EXPORT=3Dy
CONFIG_LIB80211=3Dm
CONFIG_LIB80211_CRYPT_WEP=3Dm
CONFIG_LIB80211_CRYPT_CCMP=3Dm
CONFIG_LIB80211_CRYPT_TKIP=3Dm
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=3Dm
CONFIG_MAC80211_HAS_RC=3Dy
CONFIG_MAC80211_RC_MINSTREL=3Dy
CONFIG_MAC80211_RC_MINSTREL_HT=3Dy
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=3Dy
CONFIG_MAC80211_RC_DEFAULT=3D"minstrel_ht"
CONFIG_MAC80211_MESH=3Dy
CONFIG_MAC80211_LEDS=3Dy
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=3D0
CONFIG_WIMAX=3Dm
CONFIG_WIMAX_DEBUG_LEVEL=3D8
CONFIG_RFKILL=3Dm
CONFIG_RFKILL_LEDS=3Dy
CONFIG_RFKILL_INPUT=3Dy
CONFIG_RFKILL_REGULATOR=3Dm
CONFIG_RFKILL_GPIO=3Dm
CONFIG_NET_9P=3Dm
CONFIG_NET_9P_VIRTIO=3Dm
CONFIG_NET_9P_RDMA=3Dm
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=3Dm
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=3Dm
CONFIG_CAIF_USB=3Dm
CONFIG_CEPH_LIB=3Dm
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=3Dy
CONFIG_NFC=3Dm
CONFIG_NFC_DIGITAL=3Dm
CONFIG_NFC_NCI=3Dm
CONFIG_NFC_NCI_SPI=3Dm
CONFIG_NFC_NCI_UART=3Dm
CONFIG_NFC_HCI=3Dm
CONFIG_NFC_SHDLC=3Dy

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_WILINK=3Dm
CONFIG_NFC_TRF7970A=3Dm
CONFIG_NFC_MEI_PHY=3Dm
CONFIG_NFC_SIM=3Dm
CONFIG_NFC_PORT100=3Dm
CONFIG_NFC_FDP=3Dm
CONFIG_NFC_FDP_I2C=3Dm
CONFIG_NFC_PN544=3Dm
CONFIG_NFC_PN544_I2C=3Dm
CONFIG_NFC_PN544_MEI=3Dm
CONFIG_NFC_PN533=3Dm
CONFIG_NFC_PN533_USB=3Dm
CONFIG_NFC_PN533_I2C=3Dm
CONFIG_NFC_MICROREAD=3Dm
CONFIG_NFC_MICROREAD_I2C=3Dm
CONFIG_NFC_MICROREAD_MEI=3Dm
CONFIG_NFC_MRVL=3Dm
CONFIG_NFC_MRVL_USB=3Dm
CONFIG_NFC_MRVL_UART=3Dm
CONFIG_NFC_MRVL_I2C=3Dm
CONFIG_NFC_MRVL_SPI=3Dm
CONFIG_NFC_ST21NFCA=3Dm
CONFIG_NFC_ST21NFCA_I2C=3Dm
CONFIG_NFC_ST_NCI=3Dm
CONFIG_NFC_ST_NCI_I2C=3Dm
CONFIG_NFC_ST_NCI_SPI=3Dm
CONFIG_NFC_NXP_NCI=3Dm
CONFIG_NFC_NXP_NCI_I2C=3Dm
CONFIG_NFC_S3FWRN5=3Dm
CONFIG_NFC_S3FWRN5_I2C=3Dm
CONFIG_NFC_ST95HF=3Dm
CONFIG_LWTUNNEL=3Dy
CONFIG_DST_CACHE=3Dy
CONFIG_NET_DEVLINK=3Dm
CONFIG_MAY_USE_DEVLINK=3Dm
CONFIG_HAVE_EBPF_JIT=3Dy

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=3Dy
CONFIG_UEVENT_HELPER_PATH=3D""
CONFIG_DEVTMPFS=3Dy
CONFIG_DEVTMPFS_MOUNT=3Dy
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
CONFIG_FW_LOADER=3Dy
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=3D""
CONFIG_FW_LOADER_USER_HELPER=3Dy
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=3Dy
CONFIG_ALLOW_DEV_COREDUMP=3Dy
CONFIG_DEV_COREDUMP=3Dy
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=3Dy
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=3Dy
CONFIG_REGMAP=3Dy
CONFIG_REGMAP_I2C=3Dm
CONFIG_REGMAP_SPI=3Dy
CONFIG_REGMAP_SPMI=3Dm
CONFIG_REGMAP_MMIO=3Dy
CONFIG_REGMAP_IRQ=3Dy
CONFIG_DMA_SHARED_BUFFER=3Dy
# CONFIG_FENCE_TRACE is not set
CONFIG_DMA_CMA=3Dy

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=3D16
CONFIG_CMA_SIZE_SEL_MBYTES=3Dy
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=3D8

#
# Bus devices
#
CONFIG_CONNECTOR=3Dy
CONFIG_PROC_EVENTS=3Dy
CONFIG_MTD=3Dm
CONFIG_MTD_TESTS=3Dm
CONFIG_MTD_REDBOOT_PARTS=3Dm
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=3D-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=3Dy
CONFIG_MTD_REDBOOT_PARTS_READONLY=3Dy
CONFIG_MTD_CMDLINE_PARTS=3Dm
CONFIG_MTD_AR7_PARTS=3Dm

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=3Dm
CONFIG_MTD_BLOCK=3Dm
CONFIG_MTD_BLOCK_RO=3Dm
CONFIG_FTL=3Dm
CONFIG_NFTL=3Dm
CONFIG_NFTL_RW=3Dy
CONFIG_INFTL=3Dm
CONFIG_RFD_FTL=3Dm
CONFIG_SSFDC=3Dm
CONFIG_SM_FTL=3Dm
CONFIG_MTD_OOPS=3Dm
CONFIG_MTD_SWAP=3Dm
CONFIG_MTD_PARTITIONED_MASTER=3Dy

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=3Dm
CONFIG_MTD_JEDECPROBE=3Dm
CONFIG_MTD_GEN_PROBE=3Dm
CONFIG_MTD_CFI_ADV_OPTIONS=3Dy
CONFIG_MTD_CFI_NOSWAP=3Dy
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy
CONFIG_MTD_MAP_BANK_WIDTH_2=3Dy
CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=3Dy
CONFIG_MTD_CFI_I2=3Dy
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_OTP=3Dy
CONFIG_MTD_CFI_INTELEXT=3Dm
CONFIG_MTD_CFI_AMDSTD=3Dm
CONFIG_MTD_CFI_STAA=3Dm
CONFIG_MTD_CFI_UTIL=3Dm
CONFIG_MTD_RAM=3Dm
CONFIG_MTD_ROM=3Dm
CONFIG_MTD_ABSENT=3Dm

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=3Dy
CONFIG_MTD_PHYSMAP=3Dm
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_SBC_GXX=3Dm
CONFIG_MTD_AMD76XROM=3Dm
CONFIG_MTD_ICHXROM=3Dm
CONFIG_MTD_ESB2ROM=3Dm
CONFIG_MTD_CK804XROM=3Dm
CONFIG_MTD_SCB2_FLASH=3Dm
CONFIG_MTD_NETtel=3Dm
CONFIG_MTD_L440GX=3Dm
CONFIG_MTD_PCI=3Dm
CONFIG_MTD_PCMCIA=3Dm
CONFIG_MTD_PCMCIA_ANONYMOUS=3Dy
CONFIG_MTD_GPIO_ADDR=3Dm
CONFIG_MTD_INTEL_VR_NOR=3Dm
CONFIG_MTD_PLATRAM=3Dm
CONFIG_MTD_LATCH_ADDR=3Dm

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=3Dm
CONFIG_MTD_PMC551_BUGFIX=3Dy
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=3Dm
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=3Dy
CONFIG_MTD_DATAFLASH_OTP=3Dy
CONFIG_MTD_M25P80=3Dm
CONFIG_MTD_SST25L=3Dm
CONFIG_MTD_SLRAM=3Dm
CONFIG_MTD_PHRAM=3Dm
CONFIG_MTD_MTDRAM=3Dm
CONFIG_MTDRAM_TOTAL_SIZE=3D4096
CONFIG_MTDRAM_ERASE_SIZE=3D128
CONFIG_MTD_BLOCK2MTD=3Dm

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=3Dm
CONFIG_BCH_CONST_M=3D14
CONFIG_BCH_CONST_T=3D4
CONFIG_MTD_NAND_ECC=3Dm
CONFIG_MTD_NAND_ECC_SMC=3Dy
CONFIG_MTD_NAND=3Dm
CONFIG_MTD_NAND_BCH=3Dm
CONFIG_MTD_NAND_ECC_BCH=3Dy
CONFIG_MTD_SM_COMMON=3Dm
CONFIG_MTD_NAND_DENALI=3Dm
CONFIG_MTD_NAND_DENALI_PCI=3Dm
CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=3D0xFF108018
CONFIG_MTD_NAND_GPIO=3Dm
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=3Dm
CONFIG_MTD_NAND_RICOH=3Dm
CONFIG_MTD_NAND_DISKONCHIP=3Dm
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=3D0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=3Dy
CONFIG_MTD_NAND_DOCG4=3Dm
CONFIG_MTD_NAND_CAFE=3Dm
CONFIG_MTD_NAND_NANDSIM=3Dm
CONFIG_MTD_NAND_PLATFORM=3Dm
CONFIG_MTD_NAND_HISI504=3Dm
CONFIG_MTD_ONENAND=3Dm
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=3Dm
CONFIG_MTD_ONENAND_OTP=3Dy
CONFIG_MTD_ONENAND_2X_PROGRAM=3Dy

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=3Dm
CONFIG_MTD_QINFO_PROBE=3Dm
CONFIG_MTD_SPI_NOR=3Dm
CONFIG_MTD_MT81xx_NOR=3Dm
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=3Dy
CONFIG_MTD_UBI=3Dm
CONFIG_MTD_UBI_WL_THRESHOLD=3D4096
CONFIG_MTD_UBI_BEB_LIMIT=3D20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_MTD_UBI_BLOCK=3Dy
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=3Dy
CONFIG_PARPORT=3Dm
CONFIG_PARPORT_PC=3Dm
CONFIG_PARPORT_SERIAL=3Dm
CONFIG_PARPORT_PC_FIFO=3Dy
CONFIG_PARPORT_PC_SUPERIO=3Dy
CONFIG_PARPORT_PC_PCMCIA=3Dm
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=3Dm
CONFIG_PARPORT_1284=3Dy
CONFIG_PARPORT_NOT_PC=3Dy
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy
CONFIG_BLK_DEV=3Dy
CONFIG_BLK_DEV_NULL_BLK=3Dm
CONFIG_BLK_DEV_FD=3Dm
CONFIG_PARIDE=3Dm

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=3Dm
CONFIG_PARIDE_PCD=3Dm
CONFIG_PARIDE_PF=3Dm
CONFIG_PARIDE_PT=3Dm
CONFIG_PARIDE_PG=3Dm

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=3Dm
CONFIG_PARIDE_BPCK=3Dm
CONFIG_PARIDE_COMM=3Dm
CONFIG_PARIDE_DSTR=3Dm
CONFIG_PARIDE_FIT2=3Dm
CONFIG_PARIDE_FIT3=3Dm
CONFIG_PARIDE_EPAT=3Dm
CONFIG_PARIDE_EPATC8=3Dy
CONFIG_PARIDE_EPIA=3Dm
CONFIG_PARIDE_FRIQ=3Dm
CONFIG_PARIDE_FRPW=3Dm
CONFIG_PARIDE_KBIC=3Dm
CONFIG_PARIDE_KTTI=3Dm
CONFIG_PARIDE_ON20=3Dm
CONFIG_PARIDE_ON26=3Dm
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=3Dm
CONFIG_ZRAM=3Dm
CONFIG_ZRAM_LZ4_COMPRESS=3Dy
CONFIG_BLK_CPQ_CISS_DA=3Dm
CONFIG_CISS_SCSI_TAPE=3Dy
CONFIG_BLK_DEV_DAC960=3Dm
CONFIG_BLK_DEV_UMEM=3Dm
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=3Dm
CONFIG_BLK_DEV_LOOP_MIN_COUNT=3D8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
CONFIG_BLK_DEV_DRBD=3Dm
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=3Dm
CONFIG_BLK_DEV_SKD=3Dm
CONFIG_BLK_DEV_OSD=3Dm
CONFIG_BLK_DEV_SX8=3Dm
CONFIG_BLK_DEV_RAM=3Dy
CONFIG_BLK_DEV_RAM_COUNT=3D16
CONFIG_BLK_DEV_RAM_SIZE=3D16384
CONFIG_BLK_DEV_RAM_DAX=3Dy
CONFIG_CDROM_PKTCDVD=3Dm
CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
CONFIG_CDROM_PKTCDVD_WCACHE=3Dy
CONFIG_ATA_OVER_ETH=3Dm
CONFIG_XEN_BLKDEV_FRONTEND=3Dm
CONFIG_XEN_BLKDEV_BACKEND=3Dm
CONFIG_VIRTIO_BLK=3Dm
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=3Dm
CONFIG_BLK_DEV_RSXX=3Dm
CONFIG_NVME_CORE=3Dm
CONFIG_BLK_DEV_NVME=3Dm
CONFIG_BLK_DEV_NVME_SCSI=3Dy

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=3Dm
CONFIG_AD525X_DPOT=3Dm
CONFIG_AD525X_DPOT_I2C=3Dm
CONFIG_AD525X_DPOT_SPI=3Dm
CONFIG_DUMMY_IRQ=3Dm
CONFIG_IBM_ASM=3Dm
CONFIG_PHANTOM=3Dm
CONFIG_SGI_IOC4=3Dm
CONFIG_TIFM_CORE=3Dm
CONFIG_TIFM_7XX1=3Dm
CONFIG_ICS932S401=3Dm
CONFIG_ENCLOSURE_SERVICES=3Dm
CONFIG_HP_ILO=3Dm
CONFIG_APDS9802ALS=3Dm
CONFIG_ISL29003=3Dm
CONFIG_ISL29020=3Dm
CONFIG_SENSORS_TSL2550=3Dm
CONFIG_SENSORS_BH1780=3Dm
CONFIG_SENSORS_BH1770=3Dm
CONFIG_SENSORS_APDS990X=3Dm
CONFIG_HMC6352=3Dm
CONFIG_DS1682=3Dm
CONFIG_TI_DAC7512=3Dm
CONFIG_VMWARE_BALLOON=3Dm
CONFIG_BMP085=3Dm
CONFIG_BMP085_I2C=3Dm
CONFIG_BMP085_SPI=3Dm
CONFIG_USB_SWITCH_FSA9480=3Dm
CONFIG_LATTICE_ECP3_CONFIG=3Dm
# CONFIG_SRAM is not set
CONFIG_PANEL=3Dm
CONFIG_PANEL_PARPORT=3D0
CONFIG_PANEL_PROFILE=3D5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_C2PORT=3Dm
CONFIG_C2PORT_DURAMAR_2150=3Dm

#
# EEPROM support
#
CONFIG_EEPROM_AT24=3Dm
CONFIG_EEPROM_AT25=3Dm
CONFIG_EEPROM_LEGACY=3Dm
CONFIG_EEPROM_MAX6875=3Dm
CONFIG_EEPROM_93CX6=3Dm
CONFIG_EEPROM_93XX46=3Dm
CONFIG_CB710_CORE=3Dm
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=3Dy

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=3Dm
CONFIG_SENSORS_LIS3_I2C=3Dm

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=3Dm
CONFIG_INTEL_MEI=3Dm
CONFIG_INTEL_MEI_ME=3Dm
CONFIG_INTEL_MEI_TXE=3Dm
CONFIG_VMWARE_VMCI=3Dm

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=3Dm

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=3Dm

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=3Dm

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=3Dm

#
# Intel MIC Card Driver
#
CONFIG_INTEL_MIC_CARD=3Dm

#
# SCIF Driver
#
CONFIG_SCIF=3Dm

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#
CONFIG_MIC_COSM=3Dm

#
# VOP Driver
#
CONFIG_VOP=3Dm
CONFIG_GENWQE=3Dm
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=3D0
CONFIG_ECHO=3Dm
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=3Dy
CONFIG_IDE=3Dm

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=3Dy
CONFIG_IDE_TIMINGS=3Dy
CONFIG_IDE_ATAPI=3Dy
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=3Dm
CONFIG_IDE_GD_ATA=3Dy
CONFIG_IDE_GD_ATAPI=3Dy
CONFIG_BLK_DEV_IDECS=3Dm
CONFIG_BLK_DEV_DELKIN=3Dm
CONFIG_BLK_DEV_IDECD=3Dm
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=3Dy
CONFIG_BLK_DEV_IDETAPE=3Dm
CONFIG_BLK_DEV_IDEACPI=3Dy
CONFIG_IDE_TASK_IOCTL=3Dy
CONFIG_IDE_PROC_FS=3Dy

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=3Dm
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=3Dm
CONFIG_BLK_DEV_IDEDMA_SFF=3Dy

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=3Dy
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=3Dm
CONFIG_BLK_DEV_OPTI621=3Dm
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
CONFIG_BLK_DEV_AEC62XX=3Dm
CONFIG_BLK_DEV_ALI15X3=3Dm
CONFIG_BLK_DEV_AMD74XX=3Dm
CONFIG_BLK_DEV_ATIIXP=3Dm
CONFIG_BLK_DEV_CMD64X=3Dm
CONFIG_BLK_DEV_TRIFLEX=3Dm
CONFIG_BLK_DEV_HPT366=3Dm
CONFIG_BLK_DEV_JMICRON=3Dm
CONFIG_BLK_DEV_PIIX=3Dm
CONFIG_BLK_DEV_IT8172=3Dm
CONFIG_BLK_DEV_IT8213=3Dm
CONFIG_BLK_DEV_IT821X=3Dm
CONFIG_BLK_DEV_NS87415=3Dm
CONFIG_BLK_DEV_PDC202XX_OLD=3Dm
CONFIG_BLK_DEV_PDC202XX_NEW=3Dm
CONFIG_BLK_DEV_SVWKS=3Dm
CONFIG_BLK_DEV_SIIMAGE=3Dm
CONFIG_BLK_DEV_SIS5513=3Dm
CONFIG_BLK_DEV_SLC90E66=3Dm
CONFIG_BLK_DEV_TRM290=3Dm
CONFIG_BLK_DEV_VIA82CXXX=3Dm
CONFIG_BLK_DEV_TC86C001=3Dm
CONFIG_BLK_DEV_IDEDMA=3Dy

#
# SCSI device support
#
CONFIG_SCSI_MOD=3Dm
CONFIG_RAID_ATTRS=3Dm
CONFIG_SCSI=3Dm
CONFIG_SCSI_DMA=3Dy
CONFIG_SCSI_NETLINK=3Dy
CONFIG_SCSI_MQ_DEFAULT=3Dy
CONFIG_SCSI_PROC_FS=3Dy

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dm
CONFIG_CHR_DEV_ST=3Dm
CONFIG_CHR_DEV_OSST=3Dm
CONFIG_BLK_DEV_SR=3Dm
CONFIG_BLK_DEV_SR_VENDOR=3Dy
CONFIG_CHR_DEV_SG=3Dm
CONFIG_CHR_DEV_SCH=3Dm
CONFIG_SCSI_ENCLOSURE=3Dm
CONFIG_SCSI_CONSTANTS=3Dy
CONFIG_SCSI_LOGGING=3Dy
CONFIG_SCSI_SCAN_ASYNC=3Dy

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=3Dm
CONFIG_SCSI_FC_ATTRS=3Dm
CONFIG_SCSI_ISCSI_ATTRS=3Dm
CONFIG_SCSI_SAS_ATTRS=3Dm
CONFIG_SCSI_SAS_LIBSAS=3Dm
CONFIG_SCSI_SAS_ATA=3Dy
CONFIG_SCSI_SAS_HOST_SMP=3Dy
CONFIG_SCSI_SRP_ATTRS=3Dm
CONFIG_SCSI_LOWLEVEL=3Dy
CONFIG_ISCSI_TCP=3Dm
CONFIG_ISCSI_BOOT_SYSFS=3Dm
CONFIG_SCSI_CXGB3_ISCSI=3Dm
CONFIG_SCSI_CXGB4_ISCSI=3Dm
CONFIG_SCSI_BNX2_ISCSI=3Dm
CONFIG_SCSI_BNX2X_FCOE=3Dm
CONFIG_BE2ISCSI=3Dm
CONFIG_BLK_DEV_3W_XXXX_RAID=3Dm
CONFIG_SCSI_HPSA=3Dm
CONFIG_SCSI_3W_9XXX=3Dm
CONFIG_SCSI_3W_SAS=3Dm
CONFIG_SCSI_ACARD=3Dm
CONFIG_SCSI_AACRAID=3Dm
CONFIG_SCSI_AIC7XXX=3Dm
CONFIG_AIC7XXX_CMDS_PER_DEVICE=3D253
CONFIG_AIC7XXX_RESET_DELAY_MS=3D15000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=3D0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=3Dy
CONFIG_SCSI_AIC79XX=3Dm
CONFIG_AIC79XX_CMDS_PER_DEVICE=3D253
CONFIG_AIC79XX_RESET_DELAY_MS=3D15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=3D0
CONFIG_AIC79XX_REG_PRETTY_PRINT=3Dy
CONFIG_SCSI_AIC94XX=3Dm
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=3Dm
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=3Dy
CONFIG_SCSI_MVUMI=3Dm
CONFIG_SCSI_DPT_I2O=3Dm
CONFIG_SCSI_ADVANSYS=3Dm
CONFIG_SCSI_ARCMSR=3Dm
CONFIG_SCSI_ESAS2R=3Dm
CONFIG_MEGARAID_NEWGEN=3Dy
CONFIG_MEGARAID_MM=3Dm
CONFIG_MEGARAID_MAILBOX=3Dm
CONFIG_MEGARAID_LEGACY=3Dm
CONFIG_MEGARAID_SAS=3Dm
CONFIG_SCSI_MPT3SAS=3Dm
CONFIG_SCSI_MPT2SAS_MAX_SGE=3D128
CONFIG_SCSI_MPT3SAS_MAX_SGE=3D128
CONFIG_SCSI_MPT2SAS=3Dm
CONFIG_SCSI_UFSHCD=3Dm
CONFIG_SCSI_UFSHCD_PCI=3Dm
CONFIG_SCSI_UFSHCD_PLATFORM=3Dm
CONFIG_SCSI_HPTIOP=3Dm
CONFIG_SCSI_BUSLOGIC=3Dm
CONFIG_SCSI_FLASHPOINT=3Dy
CONFIG_VMWARE_PVSCSI=3Dm
CONFIG_XEN_SCSI_FRONTEND=3Dm
CONFIG_HYPERV_STORAGE=3Dm
CONFIG_LIBFC=3Dm
CONFIG_LIBFCOE=3Dm
CONFIG_FCOE=3Dm
CONFIG_FCOE_FNIC=3Dm
CONFIG_SCSI_SNIC=3Dm
CONFIG_SCSI_SNIC_DEBUG_FS=3Dy
CONFIG_SCSI_DMX3191D=3Dm
CONFIG_SCSI_EATA=3Dm
CONFIG_SCSI_EATA_TAGGED_QUEUE=3Dy
CONFIG_SCSI_EATA_LINKED_COMMANDS=3Dy
CONFIG_SCSI_EATA_MAX_TAGS=3D62
CONFIG_SCSI_FUTURE_DOMAIN=3Dm
CONFIG_SCSI_GDTH=3Dm
CONFIG_SCSI_ISCI=3Dm
CONFIG_SCSI_IPS=3Dm
CONFIG_SCSI_INITIO=3Dm
CONFIG_SCSI_INIA100=3Dm
CONFIG_SCSI_PPA=3Dm
CONFIG_SCSI_IMM=3Dm
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=3Dm
CONFIG_SCSI_SYM53C8XX_2=3Dm
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=3D1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=3D16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=3D256
CONFIG_SCSI_SYM53C8XX_MMIO=3Dy
CONFIG_SCSI_IPR=3Dm
CONFIG_SCSI_IPR_TRACE=3Dy
CONFIG_SCSI_IPR_DUMP=3Dy
CONFIG_SCSI_QLOGIC_1280=3Dm
CONFIG_SCSI_QLA_FC=3Dm
CONFIG_TCM_QLA2XXX=3Dm
# CONFIG_TCM_QLA2XXX_DEBUG is not set
CONFIG_SCSI_QLA_ISCSI=3Dm
CONFIG_SCSI_LPFC=3Dm
# CONFIG_SCSI_LPFC_DEBUG_FS is not set
CONFIG_SCSI_DC395x=3Dm
CONFIG_SCSI_AM53C974=3Dm
CONFIG_SCSI_WD719X=3Dm
CONFIG_SCSI_DEBUG=3Dm
CONFIG_SCSI_PMCRAID=3Dm
CONFIG_SCSI_PM8001=3Dm
CONFIG_SCSI_BFA_FC=3Dm
CONFIG_SCSI_VIRTIO=3Dm
CONFIG_SCSI_CHELSIO_FCOE=3Dm
CONFIG_SCSI_LOWLEVEL_PCMCIA=3Dy
CONFIG_PCMCIA_AHA152X=3Dm
CONFIG_PCMCIA_FDOMAIN=3Dm
CONFIG_PCMCIA_QLOGIC=3Dm
CONFIG_PCMCIA_SYM53C500=3Dm
CONFIG_SCSI_DH=3Dy
CONFIG_SCSI_DH_RDAC=3Dm
CONFIG_SCSI_DH_HP_SW=3Dm
CONFIG_SCSI_DH_EMC=3Dm
CONFIG_SCSI_DH_ALUA=3Dm
CONFIG_SCSI_OSD_INITIATOR=3Dm
CONFIG_SCSI_OSD_ULD=3Dm
CONFIG_SCSI_OSD_DPRINT_SENSE=3D1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=3Dm
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=3Dy
CONFIG_ATA_ACPI=3Dy
CONFIG_SATA_ZPODD=3Dy
CONFIG_SATA_PMP=3Dy

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=3Dm
CONFIG_SATA_AHCI_PLATFORM=3Dm
CONFIG_SATA_INIC162X=3Dm
CONFIG_SATA_ACARD_AHCI=3Dm
CONFIG_SATA_SIL24=3Dm
CONFIG_ATA_SFF=3Dy

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=3Dm
CONFIG_SATA_QSTOR=3Dm
CONFIG_SATA_SX4=3Dm
CONFIG_ATA_BMDMA=3Dy

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=3Dm
CONFIG_SATA_DWC=3Dm
CONFIG_SATA_DWC_OLD_DMA=3Dy
# CONFIG_SATA_DWC_DEBUG is not set
CONFIG_SATA_MV=3Dm
CONFIG_SATA_NV=3Dm
CONFIG_SATA_PROMISE=3Dm
CONFIG_SATA_SIL=3Dm
CONFIG_SATA_SIS=3Dm
CONFIG_SATA_SVW=3Dm
CONFIG_SATA_ULI=3Dm
CONFIG_SATA_VIA=3Dm
CONFIG_SATA_VITESSE=3Dm

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=3Dm
CONFIG_PATA_AMD=3Dm
CONFIG_PATA_ARTOP=3Dm
CONFIG_PATA_ATIIXP=3Dm
CONFIG_PATA_ATP867X=3Dm
CONFIG_PATA_CMD64X=3Dm
CONFIG_PATA_CYPRESS=3Dm
CONFIG_PATA_EFAR=3Dm
CONFIG_PATA_HPT366=3Dm
CONFIG_PATA_HPT37X=3Dm
CONFIG_PATA_HPT3X2N=3Dm
CONFIG_PATA_HPT3X3=3Dm
CONFIG_PATA_HPT3X3_DMA=3Dy
CONFIG_PATA_IT8213=3Dm
CONFIG_PATA_IT821X=3Dm
CONFIG_PATA_JMICRON=3Dm
CONFIG_PATA_MARVELL=3Dm
CONFIG_PATA_NETCELL=3Dm
CONFIG_PATA_NINJA32=3Dm
CONFIG_PATA_NS87415=3Dm
CONFIG_PATA_OLDPIIX=3Dm
CONFIG_PATA_OPTIDMA=3Dm
CONFIG_PATA_PDC2027X=3Dm
CONFIG_PATA_PDC_OLD=3Dm
CONFIG_PATA_RADISYS=3Dm
CONFIG_PATA_RDC=3Dm
CONFIG_PATA_SCH=3Dm
CONFIG_PATA_SERVERWORKS=3Dm
CONFIG_PATA_SIL680=3Dm
CONFIG_PATA_SIS=3Dm
CONFIG_PATA_TOSHIBA=3Dm
CONFIG_PATA_TRIFLEX=3Dm
CONFIG_PATA_VIA=3Dm
CONFIG_PATA_WINBOND=3Dm

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=3Dm
CONFIG_PATA_MPIIX=3Dm
CONFIG_PATA_NS87410=3Dm
CONFIG_PATA_OPTI=3Dm
CONFIG_PATA_PCMCIA=3Dm
CONFIG_PATA_RZ1000=3Dm

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=3Dm
CONFIG_ATA_GENERIC=3Dm
CONFIG_PATA_LEGACY=3Dm
CONFIG_MD=3Dy
CONFIG_BLK_DEV_MD=3Dm
CONFIG_MD_LINEAR=3Dm
CONFIG_MD_RAID0=3Dm
CONFIG_MD_RAID1=3Dm
CONFIG_MD_RAID10=3Dm
CONFIG_MD_RAID456=3Dm
CONFIG_MD_MULTIPATH=3Dm
CONFIG_MD_FAULTY=3Dm
CONFIG_MD_CLUSTER=3Dm
CONFIG_BCACHE=3Dm
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM_BUILTIN=3Dy
CONFIG_BLK_DEV_DM=3Dm
CONFIG_DM_MQ_DEFAULT=3Dy
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=3Dm
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
CONFIG_DM_BIO_PRISON=3Dm
CONFIG_DM_PERSISTENT_DATA=3Dm
CONFIG_DM_CRYPT=3Dm
CONFIG_DM_SNAPSHOT=3Dm
CONFIG_DM_THIN_PROVISIONING=3Dm
CONFIG_DM_CACHE=3Dm
CONFIG_DM_CACHE_SMQ=3Dm
CONFIG_DM_CACHE_CLEANER=3Dm
CONFIG_DM_ERA=3Dm
CONFIG_DM_MIRROR=3Dm
CONFIG_DM_LOG_USERSPACE=3Dm
CONFIG_DM_RAID=3Dm
CONFIG_DM_ZERO=3Dm
CONFIG_DM_MULTIPATH=3Dm
CONFIG_DM_MULTIPATH_QL=3Dm
CONFIG_DM_MULTIPATH_ST=3Dm
CONFIG_DM_DELAY=3Dm
CONFIG_DM_UEVENT=3Dy
CONFIG_DM_FLAKEY=3Dm
CONFIG_DM_VERITY=3Dm
CONFIG_DM_VERITY_FEC=3Dy
CONFIG_DM_SWITCH=3Dm
CONFIG_DM_LOG_WRITES=3Dm
CONFIG_TARGET_CORE=3Dm
CONFIG_TCM_IBLOCK=3Dm
CONFIG_TCM_FILEIO=3Dm
CONFIG_TCM_PSCSI=3Dm
CONFIG_TCM_USER2=3Dm
CONFIG_LOOPBACK_TARGET=3Dm
CONFIG_TCM_FC=3Dm
CONFIG_ISCSI_TARGET=3Dm
CONFIG_ISCSI_TARGET_CXGB4=3Dm
CONFIG_SBP_TARGET=3Dm
CONFIG_FUSION=3Dy
CONFIG_FUSION_SPI=3Dm
CONFIG_FUSION_FC=3Dm
CONFIG_FUSION_SAS=3Dm
CONFIG_FUSION_MAX_SGE=3D40
CONFIG_FUSION_CTL=3Dm
CONFIG_FUSION_LAN=3Dm
CONFIG_FUSION_LOGGING=3Dy

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=3Dm
CONFIG_FIREWIRE_OHCI=3Dm
CONFIG_FIREWIRE_SBP2=3Dm
CONFIG_FIREWIRE_NET=3Dm
CONFIG_FIREWIRE_NOSY=3Dm
CONFIG_MACINTOSH_DRIVERS=3Dy
CONFIG_MAC_EMUMOUSEBTN=3Dy
CONFIG_NETDEVICES=3Dy
CONFIG_MII=3Dm
CONFIG_NET_CORE=3Dy
CONFIG_BONDING=3Dm
CONFIG_DUMMY=3Dm
CONFIG_EQUALIZER=3Dm
CONFIG_NET_FC=3Dy
CONFIG_IFB=3Dm
CONFIG_NET_TEAM=3Dm
CONFIG_NET_TEAM_MODE_BROADCAST=3Dm
CONFIG_NET_TEAM_MODE_ROUNDROBIN=3Dm
CONFIG_NET_TEAM_MODE_RANDOM=3Dm
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=3Dm
CONFIG_NET_TEAM_MODE_LOADBALANCE=3Dm
CONFIG_MACVLAN=3Dm
CONFIG_MACVTAP=3Dm
CONFIG_IPVLAN=3Dm
CONFIG_VXLAN=3Dm
CONFIG_GENEVE=3Dm
CONFIG_GTP=3Dm
CONFIG_MACSEC=3Dm
CONFIG_NETCONSOLE=3Dm
CONFIG_NETCONSOLE_DYNAMIC=3Dy
CONFIG_NETPOLL=3Dy
CONFIG_NET_POLL_CONTROLLER=3Dy
CONFIG_NTB_NETDEV=3Dm
CONFIG_RIONET=3Dm
CONFIG_RIONET_TX_SIZE=3D128
CONFIG_RIONET_RX_SIZE=3D128
CONFIG_IMQ=3Dm
# CONFIG_IMQ_BEHAVIOR_AA is not set
CONFIG_IMQ_BEHAVIOR_AB=3Dy
# CONFIG_IMQ_BEHAVIOR_BA is not set
# CONFIG_IMQ_BEHAVIOR_BB is not set
CONFIG_IMQ_NUM_DEVS=3D2
CONFIG_TUN=3Dm
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=3Dm
CONFIG_VIRTIO_NET=3Dm
CONFIG_NLMON=3Dm
CONFIG_NET_VRF=3Dm
CONFIG_SUNGEM_PHY=3Dm
CONFIG_ARCNET=3Dm
CONFIG_ARCNET_1201=3Dm
CONFIG_ARCNET_1051=3Dm
CONFIG_ARCNET_RAW=3Dm
CONFIG_ARCNET_CAP=3Dm
CONFIG_ARCNET_COM90xx=3Dm
CONFIG_ARCNET_COM90xxIO=3Dm
CONFIG_ARCNET_RIM_I=3Dm
CONFIG_ARCNET_COM20020=3Dm
CONFIG_ARCNET_COM20020_PCI=3Dm
CONFIG_ARCNET_COM20020_CS=3Dm
CONFIG_ATM_DRIVERS=3Dy
CONFIG_ATM_DD=3Dm
CONFIG_ATM_DUMMY=3Dm
CONFIG_ATM_TCP=3Dm
CONFIG_ATM_LANAI=3Dm
CONFIG_ATM_ENI=3Dm
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=3Dm
CONFIG_ATM_ZATM=3Dm
# CONFIG_ATM_ZATM_DEBUG is not set
CONFIG_ATM_NICSTAR=3Dm
CONFIG_ATM_NICSTAR_USE_SUNI=3Dy
CONFIG_ATM_NICSTAR_USE_IDT77105=3Dy
CONFIG_ATM_IDT77252=3Dm
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=3Dy
CONFIG_ATM_AMBASSADOR=3Dm
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=3Dm
# CONFIG_ATM_HORIZON_DEBUG is not set
CONFIG_ATM_IA=3Dm
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=3Dm
CONFIG_ATM_FORE200E_USE_TASKLET=3Dy
CONFIG_ATM_FORE200E_TX_RETRY=3D16
CONFIG_ATM_FORE200E_DEBUG=3D0
CONFIG_ATM_HE=3Dm
CONFIG_ATM_HE_USE_SUNI=3Dy
CONFIG_ATM_SOLOS=3Dm

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=3Dm
CONFIG_CAIF_SPI_SLAVE=3Dm
CONFIG_CAIF_SPI_SYNC=3Dy
CONFIG_CAIF_HSI=3Dm
CONFIG_CAIF_VIRTIO=3Dm
CONFIG_VHOST_NET=3Dm
CONFIG_VHOST_SCSI=3Dm
CONFIG_VHOST_RING=3Dm
CONFIG_VHOST=3Dm
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6060=3Dy
CONFIG_NET_DSA_MV88E6XXX=3Dm
CONFIG_NET_DSA_BCM_SF2=3Dm
CONFIG_ETHERNET=3Dy
CONFIG_MDIO=3Dm
CONFIG_NET_VENDOR_3COM=3Dy
CONFIG_PCMCIA_3C574=3Dm
CONFIG_PCMCIA_3C589=3Dm
CONFIG_VORTEX=3Dm
CONFIG_TYPHOON=3Dm
CONFIG_NET_VENDOR_ADAPTEC=3Dy
CONFIG_ADAPTEC_STARFIRE=3Dm
CONFIG_NET_VENDOR_AGERE=3Dy
CONFIG_ET131X=3Dm
CONFIG_NET_VENDOR_ALTEON=3Dy
CONFIG_ACENIC=3Dm
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_ALTERA_TSE=3Dm
CONFIG_NET_VENDOR_AMD=3Dy
CONFIG_AMD8111_ETH=3Dm
CONFIG_PCNET32=3Dm
CONFIG_PCMCIA_NMCLAN=3Dm
CONFIG_NET_VENDOR_ARC=3Dy
CONFIG_NET_VENDOR_ATHEROS=3Dy
CONFIG_ATL2=3Dm
CONFIG_ATL1=3Dm
CONFIG_ATL1E=3Dm
CONFIG_ATL1C=3Dm
CONFIG_ALX=3Dm
CONFIG_NET_VENDOR_AURORA=3Dy
CONFIG_AURORA_NB8800=3Dm
CONFIG_NET_CADENCE=3Dy
CONFIG_MACB=3Dm
CONFIG_NET_VENDOR_BROADCOM=3Dy
CONFIG_B44=3Dm
CONFIG_B44_PCI_AUTOSELECT=3Dy
CONFIG_B44_PCICORE_AUTOSELECT=3Dy
CONFIG_B44_PCI=3Dy
CONFIG_BCMGENET=3Dm
CONFIG_BNX2=3Dm
CONFIG_CNIC=3Dm
CONFIG_TIGON3=3Dm
CONFIG_BNX2X=3Dm
CONFIG_BNX2X_SRIOV=3Dy
CONFIG_BNX2X_VXLAN=3Dy
CONFIG_BNX2X_GENEVE=3Dy
CONFIG_BNXT=3Dm
CONFIG_BNXT_SRIOV=3Dy
CONFIG_NET_VENDOR_BROCADE=3Dy
CONFIG_BNA=3Dm
CONFIG_NET_VENDOR_CAVIUM=3Dy
CONFIG_THUNDER_NIC_PF=3Dm
CONFIG_THUNDER_NIC_VF=3Dm
CONFIG_THUNDER_NIC_BGX=3Dm
CONFIG_LIQUIDIO=3Dm
CONFIG_NET_VENDOR_CHELSIO=3Dy
CONFIG_CHELSIO_T1=3Dm
CONFIG_CHELSIO_T1_1G=3Dy
CONFIG_CHELSIO_T3=3Dm
CONFIG_CHELSIO_T4=3Dm
CONFIG_CHELSIO_T4_DCB=3Dy
CONFIG_CHELSIO_T4_UWIRE=3Dy
CONFIG_CHELSIO_T4_FCOE=3Dy
CONFIG_CHELSIO_T4VF=3Dm
CONFIG_NET_VENDOR_CISCO=3Dy
CONFIG_ENIC=3Dm
CONFIG_CX_ECAT=3Dm
CONFIG_DNET=3Dm
CONFIG_NET_VENDOR_DEC=3Dy
CONFIG_NET_TULIP=3Dy
CONFIG_DE2104X=3Dm
CONFIG_DE2104X_DSL=3D0
CONFIG_TULIP=3Dm
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=3Dy
CONFIG_TULIP_NAPI_HW_MITIGATION=3Dy
CONFIG_DE4X5=3Dm
CONFIG_WINBOND_840=3Dm
CONFIG_DM9102=3Dm
CONFIG_ULI526X=3Dm
CONFIG_PCMCIA_XIRCOM=3Dm
CONFIG_NET_VENDOR_DLINK=3Dy
CONFIG_DL2K=3Dm
CONFIG_SUNDANCE=3Dm
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=3Dy
CONFIG_BE2NET=3Dm
CONFIG_BE2NET_HWMON=3Dy
CONFIG_BE2NET_VXLAN=3Dy
CONFIG_NET_VENDOR_EZCHIP=3Dy
CONFIG_NET_VENDOR_EXAR=3Dy
CONFIG_S2IO=3Dm
CONFIG_VXGE=3Dm
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=3Dy
CONFIG_PCMCIA_FMVJ18X=3Dm
CONFIG_NET_VENDOR_HP=3Dy
CONFIG_HP100=3Dm
CONFIG_NET_VENDOR_INTEL=3Dy
CONFIG_E100=3Dm
CONFIG_E1000=3Dm
CONFIG_E1000E=3Dm
CONFIG_E1000E_HWTS=3Dy
CONFIG_IGB=3Dm
CONFIG_IGB_HWMON=3Dy
CONFIG_IGB_DCA=3Dy
CONFIG_IGBVF=3Dm
CONFIG_IXGB=3Dm
CONFIG_IXGBE=3Dm
CONFIG_IXGBE_VXLAN=3Dy
CONFIG_IXGBE_HWMON=3Dy
CONFIG_IXGBE_DCA=3Dy
CONFIG_IXGBE_DCB=3Dy
CONFIG_IXGBEVF=3Dm
CONFIG_I40E=3Dm
CONFIG_I40E_VXLAN=3Dy
CONFIG_I40E_GENEVE=3Dy
CONFIG_I40E_DCB=3Dy
CONFIG_I40E_FCOE=3Dy
CONFIG_I40EVF=3Dm
CONFIG_FM10K=3Dm
CONFIG_FM10K_VXLAN=3Dy
CONFIG_NET_VENDOR_I825XX=3Dy
CONFIG_JME=3Dm
CONFIG_NET_VENDOR_MARVELL=3Dy
CONFIG_MVMDIO=3Dm
# CONFIG_MVNETA_BM is not set
CONFIG_SKGE=3Dm
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKGE_GENESIS=3Dy
CONFIG_SKY2=3Dm
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=3Dy
CONFIG_MLX4_EN=3Dm
CONFIG_MLX4_EN_DCB=3Dy
CONFIG_MLX4_EN_VXLAN=3Dy
CONFIG_MLX4_CORE=3Dm
CONFIG_MLX4_DEBUG=3Dy
CONFIG_MLX5_CORE=3Dm
CONFIG_MLX5_CORE_EN=3Dy
CONFIG_MLX5_CORE_EN_DCB=3Dy
CONFIG_MLXSW_CORE=3Dm
CONFIG_MLXSW_CORE_HWMON=3Dy
CONFIG_MLXSW_PCI=3Dm
CONFIG_MLXSW_SWITCHX2=3Dm
CONFIG_MLXSW_SPECTRUM=3Dm
CONFIG_MLXSW_SPECTRUM_DCB=3Dy
CONFIG_NET_VENDOR_MICREL=3Dy
CONFIG_KS8842=3Dm
CONFIG_KS8851=3Dm
CONFIG_KS8851_MLL=3Dm
CONFIG_KSZ884X_PCI=3Dm
CONFIG_NET_VENDOR_MICROCHIP=3Dy
CONFIG_ENC28J60=3Dm
# CONFIG_ENC28J60_WRITEVERIFY is not set
CONFIG_ENCX24J600=3Dm
CONFIG_NET_VENDOR_MYRI=3Dy
CONFIG_MYRI10GE=3Dm
CONFIG_MYRI10GE_DCA=3Dy
CONFIG_FEALNX=3Dm
CONFIG_NET_VENDOR_NATSEMI=3Dy
CONFIG_NATSEMI=3Dm
CONFIG_NS83820=3Dm
CONFIG_NET_VENDOR_NETRONOME=3Dy
CONFIG_NFP_NETVF=3Dm
CONFIG_NFP_NET_DEBUG=3Dy
CONFIG_NET_VENDOR_8390=3Dy
CONFIG_PCMCIA_AXNET=3Dm
CONFIG_NE2K_PCI=3Dm
CONFIG_PCMCIA_PCNET=3Dm
CONFIG_NET_VENDOR_NVIDIA=3Dy
CONFIG_FORCEDETH=3Dm
CONFIG_NET_VENDOR_OKI=3Dy
CONFIG_ETHOC=3Dm
CONFIG_NET_PACKET_ENGINE=3Dy
CONFIG_HAMACHI=3Dm
CONFIG_YELLOWFIN=3Dm
CONFIG_NET_VENDOR_QLOGIC=3Dy
CONFIG_QLA3XXX=3Dm
CONFIG_QLCNIC=3Dm
CONFIG_QLCNIC_SRIOV=3Dy
CONFIG_QLCNIC_DCB=3Dy
CONFIG_QLCNIC_VXLAN=3Dy
CONFIG_QLCNIC_HWMON=3Dy
CONFIG_QLGE=3Dm
CONFIG_NETXEN_NIC=3Dm
CONFIG_QED=3Dm
CONFIG_QED_SRIOV=3Dy
CONFIG_QEDE=3Dm
CONFIG_QEDE_VXLAN=3Dy
CONFIG_QEDE_GENEVE=3Dy
CONFIG_NET_VENDOR_QUALCOMM=3Dy
CONFIG_NET_VENDOR_REALTEK=3Dy
CONFIG_ATP=3Dm
CONFIG_8139CP=3Dm
CONFIG_8139TOO=3Dm
# CONFIG_8139TOO_PIO is not set
CONFIG_8139TOO_TUNE_TWISTER=3Dy
CONFIG_8139TOO_8129=3Dy
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=3Dm
CONFIG_NET_VENDOR_RENESAS=3Dy
CONFIG_NET_VENDOR_RDC=3Dy
CONFIG_R6040=3Dm
CONFIG_NET_VENDOR_ROCKER=3Dy
CONFIG_ROCKER=3Dm
CONFIG_NET_VENDOR_SAMSUNG=3Dy
CONFIG_SXGBE_ETH=3Dm
CONFIG_NET_VENDOR_SEEQ=3Dy
CONFIG_NET_VENDOR_SILAN=3Dy
CONFIG_SC92031=3Dm
CONFIG_NET_VENDOR_SIS=3Dy
CONFIG_SIS900=3Dm
CONFIG_SIS190=3Dm
CONFIG_SFC=3Dm
CONFIG_SFC_MTD=3Dy
CONFIG_SFC_MCDI_MON=3Dy
CONFIG_SFC_SRIOV=3Dy
CONFIG_SFC_MCDI_LOGGING=3Dy
CONFIG_NET_VENDOR_SMSC=3Dy
CONFIG_PCMCIA_SMC91C92=3Dm
CONFIG_EPIC100=3Dm
CONFIG_SMSC911X=3Dm
# CONFIG_SMSC911X_ARCH_HOOKS is not set
CONFIG_SMSC9420=3Dm
CONFIG_NET_VENDOR_STMICRO=3Dy
CONFIG_STMMAC_ETH=3Dm
# CONFIG_STMMAC_PLATFORM is not set
# CONFIG_STMMAC_PCI is not set
CONFIG_NET_VENDOR_SUN=3Dy
CONFIG_HAPPYMEAL=3Dm
CONFIG_SUNGEM=3Dm
CONFIG_CASSINI=3Dm
CONFIG_NIU=3Dm
CONFIG_NET_VENDOR_SYNOPSYS=3Dy
CONFIG_NET_VENDOR_TEHUTI=3Dy
CONFIG_TEHUTI=3Dm
CONFIG_NET_VENDOR_TI=3Dy
CONFIG_TI_CPSW_ALE=3Dm
CONFIG_TLAN=3Dm
CONFIG_NET_VENDOR_VIA=3Dy
CONFIG_VIA_RHINE=3Dm
CONFIG_VIA_RHINE_MMIO=3Dy
CONFIG_VIA_VELOCITY=3Dm
CONFIG_NET_VENDOR_WIZNET=3Dy
CONFIG_WIZNET_W5100=3Dm
CONFIG_WIZNET_W5300=3Dm
# CONFIG_WIZNET_BUS_DIRECT is not set
# CONFIG_WIZNET_BUS_INDIRECT is not set
CONFIG_WIZNET_BUS_ANY=3Dy
CONFIG_WIZNET_W5100_SPI=3Dm
CONFIG_NET_VENDOR_XIRCOM=3Dy
CONFIG_PCMCIA_XIRC2PS=3Dm
CONFIG_FDDI=3Dy
CONFIG_DEFXX=3Dm
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=3Dm
CONFIG_HIPPI=3Dy
CONFIG_ROADRUNNER=3Dm
# CONFIG_ROADRUNNER_LARGE_RINGS is not set
CONFIG_NET_SB1000=3Dm
CONFIG_PHYLIB=3Dy

#
# MII PHY device drivers
#
CONFIG_AQUANTIA_PHY=3Dm
CONFIG_AT803X_PHY=3Dm
CONFIG_AMD_PHY=3Dm
CONFIG_MARVELL_PHY=3Dm
CONFIG_DAVICOM_PHY=3Dm
CONFIG_QSEMI_PHY=3Dm
CONFIG_LXT_PHY=3Dm
CONFIG_CICADA_PHY=3Dm
CONFIG_VITESSE_PHY=3Dm
CONFIG_TERANETICS_PHY=3Dm
CONFIG_SMSC_PHY=3Dm
CONFIG_BCM_NET_PHYLIB=3Dm
CONFIG_BROADCOM_PHY=3Dm
CONFIG_BCM7XXX_PHY=3Dm
CONFIG_BCM87XX_PHY=3Dm
CONFIG_ICPLUS_PHY=3Dm
CONFIG_REALTEK_PHY=3Dm
CONFIG_NATIONAL_PHY=3Dm
CONFIG_STE10XP=3Dm
CONFIG_LSI_ET1011C_PHY=3Dm
CONFIG_MICREL_PHY=3Dm
CONFIG_DP83848_PHY=3Dm
CONFIG_DP83867_PHY=3Dm
CONFIG_MICROCHIP_PHY=3Dm
CONFIG_FIXED_PHY=3Dy
CONFIG_MDIO_BITBANG=3Dm
CONFIG_MDIO_GPIO=3Dm
CONFIG_MDIO_CAVIUM=3Dm
CONFIG_MDIO_OCTEON=3Dm
CONFIG_MDIO_THUNDER=3Dm
CONFIG_MDIO_BCM_UNIMAC=3Dm
CONFIG_MICREL_KS8995MA=3Dm
CONFIG_PLIP=3Dm
CONFIG_PPP=3Dm
CONFIG_PPP_BSDCOMP=3Dm
CONFIG_PPP_DEFLATE=3Dm
CONFIG_PPP_FILTER=3Dy
CONFIG_PPP_MPPE=3Dm
CONFIG_PPP_MULTILINK=3Dy
CONFIG_PPPOATM=3Dm
CONFIG_PPPOE=3Dm
CONFIG_PPTP=3Dm
CONFIG_PPPOL2TP=3Dm
CONFIG_PPP_ASYNC=3Dm
CONFIG_PPP_SYNC_TTY=3Dm
CONFIG_SLIP=3Dm
CONFIG_SLHC=3Dm
CONFIG_SLIP_COMPRESSED=3Dy
CONFIG_SLIP_SMART=3Dy
CONFIG_SLIP_MODE_SLIP6=3Dy

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_USB_NET_DRIVERS=3Dm
CONFIG_USB_CATC=3Dm
CONFIG_USB_KAWETH=3Dm
CONFIG_USB_PEGASUS=3Dm
CONFIG_USB_RTL8150=3Dm
CONFIG_USB_RTL8152=3Dm
CONFIG_USB_LAN78XX=3Dm
CONFIG_USB_USBNET=3Dm
CONFIG_USB_NET_AX8817X=3Dm
CONFIG_USB_NET_AX88179_178A=3Dm
CONFIG_USB_NET_CDCETHER=3Dm
CONFIG_USB_NET_CDC_EEM=3Dm
CONFIG_USB_NET_CDC_NCM=3Dm
CONFIG_USB_NET_HUAWEI_CDC_NCM=3Dm
CONFIG_USB_NET_CDC_MBIM=3Dm
CONFIG_USB_NET_DM9601=3Dm
CONFIG_USB_NET_SR9700=3Dm
CONFIG_USB_NET_SR9800=3Dm
CONFIG_USB_NET_SMSC75XX=3Dm
CONFIG_USB_NET_SMSC95XX=3Dm
CONFIG_USB_NET_GL620A=3Dm
CONFIG_USB_NET_NET1080=3Dm
CONFIG_USB_NET_PLUSB=3Dm
CONFIG_USB_NET_MCS7830=3Dm
CONFIG_USB_NET_RNDIS_HOST=3Dm
CONFIG_USB_NET_CDC_SUBSET_ENABLE=3Dm
CONFIG_USB_NET_CDC_SUBSET=3Dm
CONFIG_USB_ALI_M5632=3Dy
CONFIG_USB_AN2720=3Dy
CONFIG_USB_BELKIN=3Dy
CONFIG_USB_ARMLINUX=3Dy
CONFIG_USB_EPSON2888=3Dy
CONFIG_USB_KC2190=3Dy
CONFIG_USB_NET_ZAURUS=3Dm
CONFIG_USB_NET_CX82310_ETH=3Dm
CONFIG_USB_NET_KALMIA=3Dm
CONFIG_USB_NET_QMI_WWAN=3Dm
CONFIG_USB_HSO=3Dm
CONFIG_USB_NET_INT51X1=3Dm
CONFIG_USB_CDC_PHONET=3Dm
CONFIG_USB_IPHETH=3Dm
CONFIG_USB_SIERRA_NET=3Dm
CONFIG_USB_VL600=3Dm
CONFIG_USB_NET_CH9200=3Dm
CONFIG_WLAN=3Dy
CONFIG_WLAN_VENDOR_ADMTEK=3Dy
CONFIG_ADM8211=3Dm
CONFIG_ATH_COMMON=3Dm
CONFIG_WLAN_VENDOR_ATH=3Dy
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=3Dm
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=3Dy
CONFIG_ATH9K_HW=3Dm
CONFIG_ATH9K_COMMON=3Dm
CONFIG_ATH9K_BTCOEX_SUPPORT=3Dy
CONFIG_ATH9K=3Dm
CONFIG_ATH9K_PCI=3Dy
CONFIG_ATH9K_AHB=3Dy
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_DYNACK=3Dy
CONFIG_ATH9K_WOW=3Dy
CONFIG_ATH9K_RFKILL=3Dy
CONFIG_ATH9K_CHANNEL_CONTEXT=3Dy
CONFIG_ATH9K_PCOEM=3Dy
CONFIG_ATH9K_HTC=3Dm
CONFIG_ATH9K_HTC_DEBUGFS=3Dy
CONFIG_ATH9K_HWRNG=3Dy
CONFIG_CARL9170=3Dm
CONFIG_CARL9170_LEDS=3Dy
CONFIG_CARL9170_WPC=3Dy
CONFIG_CARL9170_HWRNG=3Dy
CONFIG_ATH6KL=3Dm
CONFIG_ATH6KL_SDIO=3Dm
CONFIG_ATH6KL_USB=3Dm
# CONFIG_ATH6KL_DEBUG is not set
CONFIG_ATH6KL_TRACING=3Dy
CONFIG_AR5523=3Dm
CONFIG_WIL6210=3Dm
CONFIG_WIL6210_ISR_COR=3Dy
CONFIG_WIL6210_TRACING=3Dy
CONFIG_ATH10K=3Dm
CONFIG_ATH10K_PCI=3Dm
# CONFIG_ATH10K_DEBUG is not set
# CONFIG_ATH10K_DEBUGFS is not set
# CONFIG_ATH10K_TRACING is not set
CONFIG_WCN36XX=3Dm
# CONFIG_WCN36XX_DEBUGFS is not set
CONFIG_WLAN_VENDOR_ATMEL=3Dy
CONFIG_ATMEL=3Dm
CONFIG_PCI_ATMEL=3Dm
CONFIG_PCMCIA_ATMEL=3Dm
CONFIG_AT76C50X_USB=3Dm
CONFIG_WLAN_VENDOR_BROADCOM=3Dy
CONFIG_B43=3Dm
CONFIG_B43_BCMA=3Dy
CONFIG_B43_SSB=3Dy
CONFIG_B43_BUSES_BCMA_AND_SSB=3Dy
# CONFIG_B43_BUSES_BCMA is not set
# CONFIG_B43_BUSES_SSB is not set
CONFIG_B43_PCI_AUTOSELECT=3Dy
CONFIG_B43_PCICORE_AUTOSELECT=3Dy
CONFIG_B43_SDIO=3Dy
CONFIG_B43_BCMA_PIO=3Dy
CONFIG_B43_PIO=3Dy
CONFIG_B43_PHY_G=3Dy
CONFIG_B43_PHY_N=3Dy
CONFIG_B43_PHY_LP=3Dy
CONFIG_B43_PHY_HT=3Dy
CONFIG_B43_LEDS=3Dy
CONFIG_B43_HWRNG=3Dy
# CONFIG_B43_DEBUG is not set
CONFIG_B43LEGACY=3Dm
CONFIG_B43LEGACY_PCI_AUTOSELECT=3Dy
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=3Dy
CONFIG_B43LEGACY_LEDS=3Dy
CONFIG_B43LEGACY_HWRNG=3Dy
# CONFIG_B43LEGACY_DEBUG is not set
CONFIG_B43LEGACY_DMA=3Dy
CONFIG_B43LEGACY_PIO=3Dy
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=3Dy
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=3Dm
CONFIG_BRCMSMAC=3Dm
CONFIG_BRCMFMAC=3Dm
CONFIG_BRCMFMAC_PROTO_BCDC=3Dy
CONFIG_BRCMFMAC_PROTO_MSGBUF=3Dy
CONFIG_BRCMFMAC_SDIO=3Dy
CONFIG_BRCMFMAC_USB=3Dy
CONFIG_BRCMFMAC_PCIE=3Dy
CONFIG_BRCM_TRACING=3Dy
# CONFIG_BRCMDBG is not set
CONFIG_WLAN_VENDOR_CISCO=3Dy
CONFIG_AIRO=3Dm
CONFIG_AIRO_CS=3Dm
CONFIG_WLAN_VENDOR_INTEL=3Dy
CONFIG_IPW2100=3Dm
CONFIG_IPW2100_MONITOR=3Dy
# CONFIG_IPW2100_DEBUG is not set
CONFIG_IPW2200=3Dm
CONFIG_IPW2200_MONITOR=3Dy
CONFIG_IPW2200_RADIOTAP=3Dy
CONFIG_IPW2200_PROMISCUOUS=3Dy
CONFIG_IPW2200_QOS=3Dy
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=3Dm
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLEGACY=3Dm
CONFIG_IWL4965=3Dm
CONFIG_IWL3945=3Dm

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_IWLWIFI=3Dm
CONFIG_IWLWIFI_LEDS=3Dy
CONFIG_IWLDVM=3Dm
CONFIG_IWLMVM=3Dm
CONFIG_IWLWIFI_OPMODE_MODULAR=3Dy
CONFIG_IWLWIFI_BCAST_FILTERING=3Dy
CONFIG_IWLWIFI_PCIE_RTPM=3Dy

#
# Debugging Options
#
CONFIG_IWLWIFI_DEBUG=3Dy
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_WLAN_VENDOR_INTERSIL=3Dy
CONFIG_HOSTAP=3Dm
CONFIG_HOSTAP_FIRMWARE=3Dy
CONFIG_HOSTAP_FIRMWARE_NVRAM=3Dy
CONFIG_HOSTAP_PLX=3Dm
CONFIG_HOSTAP_PCI=3Dm
CONFIG_HOSTAP_CS=3Dm
CONFIG_HERMES=3Dm
CONFIG_HERMES_PRISM=3Dy
CONFIG_HERMES_CACHE_FW_ON_INIT=3Dy
CONFIG_PLX_HERMES=3Dm
CONFIG_TMD_HERMES=3Dm
CONFIG_NORTEL_HERMES=3Dm
CONFIG_PCI_HERMES=3Dm
CONFIG_PCMCIA_HERMES=3Dm
CONFIG_PCMCIA_SPECTRUM=3Dm
CONFIG_ORINOCO_USB=3Dm
CONFIG_P54_COMMON=3Dm
CONFIG_P54_USB=3Dm
CONFIG_P54_PCI=3Dm
CONFIG_P54_SPI=3Dm
CONFIG_P54_SPI_DEFAULT_EEPROM=3Dy
CONFIG_P54_LEDS=3Dy
CONFIG_PRISM54=3Dm
CONFIG_WLAN_VENDOR_MARVELL=3Dy
CONFIG_LIBERTAS=3Dm
CONFIG_LIBERTAS_USB=3Dm
CONFIG_LIBERTAS_CS=3Dm
CONFIG_LIBERTAS_SDIO=3Dm
CONFIG_LIBERTAS_SPI=3Dm
# CONFIG_LIBERTAS_DEBUG is not set
CONFIG_LIBERTAS_MESH=3Dy
CONFIG_LIBERTAS_THINFIRM=3Dm
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=3Dm
CONFIG_MWIFIEX=3Dm
CONFIG_MWIFIEX_SDIO=3Dm
CONFIG_MWIFIEX_PCIE=3Dm
CONFIG_MWIFIEX_USB=3Dm
CONFIG_MWL8K=3Dm
CONFIG_WLAN_VENDOR_MEDIATEK=3Dy
CONFIG_MT7601U=3Dm
CONFIG_WLAN_VENDOR_RALINK=3Dy
CONFIG_RT2X00=3Dm
CONFIG_RT2400PCI=3Dm
CONFIG_RT2500PCI=3Dm
CONFIG_RT61PCI=3Dm
CONFIG_RT2800PCI=3Dm
CONFIG_RT2800PCI_RT33XX=3Dy
CONFIG_RT2800PCI_RT35XX=3Dy
CONFIG_RT2800PCI_RT53XX=3Dy
CONFIG_RT2800PCI_RT3290=3Dy
CONFIG_RT2500USB=3Dm
CONFIG_RT73USB=3Dm
CONFIG_RT2800USB=3Dm
CONFIG_RT2800USB_RT33XX=3Dy
CONFIG_RT2800USB_RT35XX=3Dy
CONFIG_RT2800USB_RT3573=3Dy
CONFIG_RT2800USB_RT53XX=3Dy
CONFIG_RT2800USB_RT55XX=3Dy
CONFIG_RT2800USB_UNKNOWN=3Dy
CONFIG_RT2800_LIB=3Dm
CONFIG_RT2800_LIB_MMIO=3Dm
CONFIG_RT2X00_LIB_MMIO=3Dm
CONFIG_RT2X00_LIB_PCI=3Dm
CONFIG_RT2X00_LIB_USB=3Dm
CONFIG_RT2X00_LIB=3Dm
CONFIG_RT2X00_LIB_FIRMWARE=3Dy
CONFIG_RT2X00_LIB_CRYPTO=3Dy
CONFIG_RT2X00_LIB_LEDS=3Dy
# CONFIG_RT2X00_DEBUG is not set
CONFIG_WLAN_VENDOR_REALTEK=3Dy
CONFIG_RTL8180=3Dm
CONFIG_RTL8187=3Dm
CONFIG_RTL8187_LEDS=3Dy
CONFIG_RTL_CARDS=3Dm
CONFIG_RTL8192CE=3Dm
CONFIG_RTL8192SE=3Dm
CONFIG_RTL8192DE=3Dm
CONFIG_RTL8723AE=3Dm
CONFIG_RTL8723BE=3Dm
CONFIG_RTL8188EE=3Dm
CONFIG_RTL8192EE=3Dm
CONFIG_RTL8821AE=3Dm
CONFIG_RTL8192CU=3Dm
CONFIG_RTLWIFI=3Dm
CONFIG_RTLWIFI_PCI=3Dm
CONFIG_RTLWIFI_USB=3Dm
# CONFIG_RTLWIFI_DEBUG is not set
CONFIG_RTL8192C_COMMON=3Dm
CONFIG_RTL8723_COMMON=3Dm
CONFIG_RTLBTCOEXIST=3Dm
CONFIG_RTL8XXXU=3Dm
CONFIG_RTL8XXXU_UNTESTED=3Dy
CONFIG_WLAN_VENDOR_RSI=3Dy
CONFIG_RSI_91X=3Dm
CONFIG_RSI_DEBUGFS=3Dy
CONFIG_RSI_SDIO=3Dm
CONFIG_RSI_USB=3Dm
CONFIG_WLAN_VENDOR_ST=3Dy
CONFIG_CW1200=3Dm
CONFIG_CW1200_WLAN_SDIO=3Dm
CONFIG_CW1200_WLAN_SPI=3Dm
CONFIG_WLAN_VENDOR_TI=3Dy
CONFIG_WL1251=3Dm
CONFIG_WL1251_SPI=3Dm
CONFIG_WL1251_SDIO=3Dm
CONFIG_WL12XX=3Dm
CONFIG_WL18XX=3Dm
CONFIG_WLCORE=3Dm
CONFIG_WLCORE_SDIO=3Dm
CONFIG_WILINK_PLATFORM_DATA=3Dy
CONFIG_WLAN_VENDOR_ZYDAS=3Dy
CONFIG_USB_ZD1201=3Dm
CONFIG_ZD1211RW=3Dm
# CONFIG_ZD1211RW_DEBUG is not set
CONFIG_PCMCIA_RAYCS=3Dm
CONFIG_PCMCIA_WL3501=3Dm
CONFIG_MAC80211_HWSIM=3Dm
CONFIG_USB_NET_RNDIS_WLAN=3Dm

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=3Dm
CONFIG_WIMAX_I2400M_USB=3Dm
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=3D8
CONFIG_WAN=3Dy
CONFIG_LANMEDIA=3Dm
CONFIG_HDLC=3Dm
CONFIG_HDLC_RAW=3Dm
CONFIG_HDLC_RAW_ETH=3Dm
CONFIG_HDLC_CISCO=3Dm
CONFIG_HDLC_FR=3Dm
CONFIG_HDLC_PPP=3Dm
CONFIG_HDLC_X25=3Dm
CONFIG_PCI200SYN=3Dm
CONFIG_WANXL=3Dm
CONFIG_PC300TOO=3Dm
CONFIG_FARSYNC=3Dm
CONFIG_DSCC4=3Dm
CONFIG_DSCC4_PCISYNC=3Dy
CONFIG_DSCC4_PCI_RST=3Dy
CONFIG_DLCI=3Dm
CONFIG_DLCI_MAX=3D8
CONFIG_LAPBETHER=3Dm
CONFIG_X25_ASY=3Dm
CONFIG_SBNI=3Dm
CONFIG_SBNI_MULTILINE=3Dy
CONFIG_IEEE802154_DRIVERS=3Dm
CONFIG_IEEE802154_FAKELB=3Dm
CONFIG_IEEE802154_AT86RF230=3Dm
# CONFIG_IEEE802154_AT86RF230_DEBUGFS is not set
CONFIG_IEEE802154_MRF24J40=3Dm
CONFIG_IEEE802154_CC2520=3Dm
CONFIG_IEEE802154_ATUSB=3Dm
CONFIG_IEEE802154_ADF7242=3Dm
CONFIG_XEN_NETDEV_FRONTEND=3Dm
CONFIG_XEN_NETDEV_BACKEND=3Dm
CONFIG_VMXNET3=3Dm
CONFIG_FUJITSU_ES=3Dm
CONFIG_HYPERV_NET=3Dm
CONFIG_ISDN=3Dy
CONFIG_ISDN_I4L=3Dm
CONFIG_ISDN_PPP=3Dy
CONFIG_ISDN_PPP_VJ=3Dy
CONFIG_ISDN_MPP=3Dy
CONFIG_IPPP_FILTER=3Dy
CONFIG_ISDN_PPP_BSDCOMP=3Dm
CONFIG_ISDN_AUDIO=3Dy
CONFIG_ISDN_TTY_FAX=3Dy
CONFIG_ISDN_X25=3Dy

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=3Dm

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set
CONFIG_ISDN_CAPI=3Dm
CONFIG_CAPI_TRACE=3Dy
CONFIG_ISDN_CAPI_CAPI20=3Dm
CONFIG_ISDN_CAPI_MIDDLEWARE=3Dy
CONFIG_ISDN_CAPI_CAPIDRV=3Dm
CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE=3Dy

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=3Dy
CONFIG_ISDN_DRV_AVMB1_B1PCI=3Dm
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=3Dy
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=3Dm
CONFIG_ISDN_DRV_AVMB1_AVM_CS=3Dm
CONFIG_ISDN_DRV_AVMB1_T1PCI=3Dm
CONFIG_ISDN_DRV_AVMB1_C4=3Dm
CONFIG_CAPI_EICON=3Dy
CONFIG_ISDN_DIVAS=3Dm
CONFIG_ISDN_DIVAS_BRIPCI=3Dy
CONFIG_ISDN_DIVAS_PRIPCI=3Dy
CONFIG_ISDN_DIVAS_DIVACAPI=3Dm
CONFIG_ISDN_DIVAS_USERIDI=3Dm
CONFIG_ISDN_DIVAS_MAINT=3Dm
CONFIG_ISDN_DRV_GIGASET=3Dm
CONFIG_GIGASET_CAPI=3Dy
# CONFIG_GIGASET_I4L is not set
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=3Dm
CONFIG_GIGASET_M105=3Dm
CONFIG_GIGASET_M101=3Dm
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=3Dm
CONFIG_HYSDN_CAPI=3Dy
CONFIG_MISDN=3Dm
CONFIG_MISDN_DSP=3Dm
CONFIG_MISDN_L1OIP=3Dm

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=3Dm
CONFIG_MISDN_HFCMULTI=3Dm
CONFIG_MISDN_HFCUSB=3Dm
CONFIG_MISDN_AVMFRITZ=3Dm
CONFIG_MISDN_SPEEDFAX=3Dm
CONFIG_MISDN_INFINEON=3Dm
CONFIG_MISDN_W6692=3Dm
CONFIG_MISDN_NETJET=3Dm
CONFIG_MISDN_IPAC=3Dm
CONFIG_MISDN_ISAR=3Dm
CONFIG_ISDN_HDLC=3Dm
CONFIG_NVM=3Dy
# CONFIG_NVM_DEBUG is not set
CONFIG_NVM_GENNVM=3Dm
CONFIG_NVM_RRPC=3Dm

#
# Input device support
#
CONFIG_INPUT=3Dy
CONFIG_INPUT_LEDS=3Dm
CONFIG_INPUT_FF_MEMLESS=3Dm
CONFIG_INPUT_POLLDEV=3Dm
CONFIG_INPUT_SPARSEKMAP=3Dm
CONFIG_INPUT_MATRIXKMAP=3Dm

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
CONFIG_INPUT_JOYDEV=3Dm
CONFIG_INPUT_EVDEV=3Dm
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ADP5588=3Dm
CONFIG_KEYBOARD_ADP5589=3Dm
CONFIG_KEYBOARD_ATKBD=3Dy
CONFIG_KEYBOARD_QT1070=3Dm
CONFIG_KEYBOARD_QT2160=3Dm
CONFIG_KEYBOARD_LKKBD=3Dm
CONFIG_KEYBOARD_GPIO=3Dm
CONFIG_KEYBOARD_GPIO_POLLED=3Dm
CONFIG_KEYBOARD_TCA6416=3Dm
CONFIG_KEYBOARD_TCA8418=3Dm
CONFIG_KEYBOARD_MATRIX=3Dm
CONFIG_KEYBOARD_LM8323=3Dm
CONFIG_KEYBOARD_LM8333=3Dm
CONFIG_KEYBOARD_MAX7359=3Dm
CONFIG_KEYBOARD_MCS=3Dm
CONFIG_KEYBOARD_MPR121=3Dm
CONFIG_KEYBOARD_NEWTON=3Dm
CONFIG_KEYBOARD_OPENCORES=3Dm
CONFIG_KEYBOARD_SAMSUNG=3Dm
CONFIG_KEYBOARD_GOLDFISH_EVENTS=3Dm
CONFIG_KEYBOARD_STOWAWAY=3Dm
CONFIG_KEYBOARD_SUNKBD=3Dm
CONFIG_KEYBOARD_XTKBD=3Dm
CONFIG_KEYBOARD_CROS_EC=3Dm
CONFIG_INPUT_MOUSE=3Dy
CONFIG_MOUSE_PS2=3Dm
CONFIG_MOUSE_PS2_ALPS=3Dy
CONFIG_MOUSE_PS2_BYD=3Dy
CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
CONFIG_MOUSE_PS2_CYPRESS=3Dy
CONFIG_MOUSE_PS2_LIFEBOOK=3Dy
CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
CONFIG_MOUSE_PS2_ELANTECH=3Dy
CONFIG_MOUSE_PS2_SENTELIC=3Dy
CONFIG_MOUSE_PS2_TOUCHKIT=3Dy
CONFIG_MOUSE_PS2_FOCALTECH=3Dy
CONFIG_MOUSE_PS2_VMMOUSE=3Dy
CONFIG_MOUSE_SERIAL=3Dm
CONFIG_MOUSE_APPLETOUCH=3Dm
CONFIG_MOUSE_BCM5974=3Dm
CONFIG_MOUSE_CYAPA=3Dm
CONFIG_MOUSE_ELAN_I2C=3Dm
CONFIG_MOUSE_ELAN_I2C_I2C=3Dy
CONFIG_MOUSE_ELAN_I2C_SMBUS=3Dy
CONFIG_MOUSE_VSXXXAA=3Dm
CONFIG_MOUSE_GPIO=3Dm
CONFIG_MOUSE_SYNAPTICS_I2C=3Dm
CONFIG_MOUSE_SYNAPTICS_USB=3Dm
CONFIG_INPUT_JOYSTICK=3Dy
CONFIG_JOYSTICK_ANALOG=3Dm
CONFIG_JOYSTICK_A3D=3Dm
CONFIG_JOYSTICK_ADI=3Dm
CONFIG_JOYSTICK_COBRA=3Dm
CONFIG_JOYSTICK_GF2K=3Dm
CONFIG_JOYSTICK_GRIP=3Dm
CONFIG_JOYSTICK_GRIP_MP=3Dm
CONFIG_JOYSTICK_GUILLEMOT=3Dm
CONFIG_JOYSTICK_INTERACT=3Dm
CONFIG_JOYSTICK_SIDEWINDER=3Dm
CONFIG_JOYSTICK_TMDC=3Dm
CONFIG_JOYSTICK_IFORCE=3Dm
CONFIG_JOYSTICK_IFORCE_USB=3Dy
CONFIG_JOYSTICK_IFORCE_232=3Dy
CONFIG_JOYSTICK_WARRIOR=3Dm
CONFIG_JOYSTICK_MAGELLAN=3Dm
CONFIG_JOYSTICK_SPACEORB=3Dm
CONFIG_JOYSTICK_SPACEBALL=3Dm
CONFIG_JOYSTICK_STINGER=3Dm
CONFIG_JOYSTICK_TWIDJOY=3Dm
CONFIG_JOYSTICK_ZHENHUA=3Dm
CONFIG_JOYSTICK_DB9=3Dm
CONFIG_JOYSTICK_GAMECON=3Dm
CONFIG_JOYSTICK_TURBOGRAFX=3Dm
CONFIG_JOYSTICK_AS5011=3Dm
CONFIG_JOYSTICK_JOYDUMP=3Dm
CONFIG_JOYSTICK_XPAD=3Dm
CONFIG_JOYSTICK_XPAD_FF=3Dy
CONFIG_JOYSTICK_XPAD_LEDS=3Dy
CONFIG_JOYSTICK_WALKERA0701=3Dm
CONFIG_INPUT_TABLET=3Dy
CONFIG_TABLET_USB_ACECAD=3Dm
CONFIG_TABLET_USB_AIPTEK=3Dm
CONFIG_TABLET_USB_GTCO=3Dm
CONFIG_TABLET_USB_HANWANG=3Dm
CONFIG_TABLET_USB_KBTAB=3Dm
CONFIG_TABLET_SERIAL_WACOM4=3Dm
CONFIG_INPUT_TOUCHSCREEN=3Dy
CONFIG_TOUCHSCREEN_PROPERTIES=3Dy
CONFIG_TOUCHSCREEN_ADS7846=3Dm
CONFIG_TOUCHSCREEN_AD7877=3Dm
CONFIG_TOUCHSCREEN_AD7879=3Dm
CONFIG_TOUCHSCREEN_AD7879_I2C=3Dm
CONFIG_TOUCHSCREEN_AD7879_SPI=3Dm
CONFIG_TOUCHSCREEN_ATMEL_MXT=3Dm
CONFIG_TOUCHSCREEN_AUO_PIXCIR=3Dm
CONFIG_TOUCHSCREEN_BU21013=3Dm
CONFIG_TOUCHSCREEN_CY8CTMG110=3Dm
CONFIG_TOUCHSCREEN_CYTTSP_CORE=3Dm
CONFIG_TOUCHSCREEN_CYTTSP_I2C=3Dm
CONFIG_TOUCHSCREEN_CYTTSP_SPI=3Dm
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=3Dm
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=3Dm
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=3Dm
CONFIG_TOUCHSCREEN_DA9052=3Dm
CONFIG_TOUCHSCREEN_DYNAPRO=3Dm
CONFIG_TOUCHSCREEN_HAMPSHIRE=3Dm
CONFIG_TOUCHSCREEN_EETI=3Dm
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=3Dm
CONFIG_TOUCHSCREEN_FT6236=3Dm
CONFIG_TOUCHSCREEN_FUJITSU=3Dm
CONFIG_TOUCHSCREEN_GOODIX=3Dm
CONFIG_TOUCHSCREEN_ILI210X=3Dm
CONFIG_TOUCHSCREEN_GUNZE=3Dm
CONFIG_TOUCHSCREEN_ELAN=3Dm
CONFIG_TOUCHSCREEN_ELO=3Dm
CONFIG_TOUCHSCREEN_WACOM_W8001=3Dm
CONFIG_TOUCHSCREEN_WACOM_I2C=3Dm
CONFIG_TOUCHSCREEN_MAX11801=3Dm
CONFIG_TOUCHSCREEN_MCS5000=3Dm
CONFIG_TOUCHSCREEN_MMS114=3Dm
CONFIG_TOUCHSCREEN_MELFAS_MIP4=3Dm
CONFIG_TOUCHSCREEN_MTOUCH=3Dm
CONFIG_TOUCHSCREEN_INEXIO=3Dm
CONFIG_TOUCHSCREEN_MK712=3Dm
CONFIG_TOUCHSCREEN_PENMOUNT=3Dm
CONFIG_TOUCHSCREEN_EDT_FT5X06=3Dm
CONFIG_TOUCHSCREEN_TOUCHRIGHT=3Dm
CONFIG_TOUCHSCREEN_TOUCHWIN=3Dm
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=3Dm
CONFIG_TOUCHSCREEN_UCB1400=3Dm
CONFIG_TOUCHSCREEN_PIXCIR=3Dm
CONFIG_TOUCHSCREEN_WDT87XX_I2C=3Dm
CONFIG_TOUCHSCREEN_WM831X=3Dm
CONFIG_TOUCHSCREEN_WM97XX=3Dm
CONFIG_TOUCHSCREEN_WM9705=3Dy
CONFIG_TOUCHSCREEN_WM9712=3Dy
CONFIG_TOUCHSCREEN_WM9713=3Dy
CONFIG_TOUCHSCREEN_USB_COMPOSITE=3Dm
CONFIG_TOUCHSCREEN_MC13783=3Dm
CONFIG_TOUCHSCREEN_USB_EGALAX=3Dy
CONFIG_TOUCHSCREEN_USB_PANJIT=3Dy
CONFIG_TOUCHSCREEN_USB_3M=3Dy
CONFIG_TOUCHSCREEN_USB_ITM=3Dy
CONFIG_TOUCHSCREEN_USB_ETURBO=3Dy
CONFIG_TOUCHSCREEN_USB_GUNZE=3Dy
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=3Dy
CONFIG_TOUCHSCREEN_USB_IRTOUCH=3Dy
CONFIG_TOUCHSCREEN_USB_IDEALTEK=3Dy
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=3Dy
CONFIG_TOUCHSCREEN_USB_GOTOP=3Dy
CONFIG_TOUCHSCREEN_USB_JASTEC=3Dy
CONFIG_TOUCHSCREEN_USB_ELO=3Dy
CONFIG_TOUCHSCREEN_USB_E2I=3Dy
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=3Dy
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=3Dy
CONFIG_TOUCHSCREEN_USB_NEXIO=3Dy
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=3Dy
CONFIG_TOUCHSCREEN_TOUCHIT213=3Dm
CONFIG_TOUCHSCREEN_TSC_SERIO=3Dm
CONFIG_TOUCHSCREEN_TSC200X_CORE=3Dm
CONFIG_TOUCHSCREEN_TSC2004=3Dm
CONFIG_TOUCHSCREEN_TSC2005=3Dm
CONFIG_TOUCHSCREEN_TSC2007=3Dm
CONFIG_TOUCHSCREEN_PCAP=3Dm
CONFIG_TOUCHSCREEN_ST1232=3Dm
CONFIG_TOUCHSCREEN_SUR40=3Dm
CONFIG_TOUCHSCREEN_SX8654=3Dm
CONFIG_TOUCHSCREEN_TPS6507X=3Dm
CONFIG_TOUCHSCREEN_ZFORCE=3Dm
CONFIG_TOUCHSCREEN_ROHM_BU21023=3Dm
CONFIG_INPUT_MISC=3Dy
CONFIG_INPUT_88PM80X_ONKEY=3Dm
CONFIG_INPUT_AD714X=3Dm
CONFIG_INPUT_AD714X_I2C=3Dm
CONFIG_INPUT_AD714X_SPI=3Dm
CONFIG_INPUT_ARIZONA_HAPTICS=3Dm
CONFIG_INPUT_BMA150=3Dm
CONFIG_INPUT_E3X0_BUTTON=3Dm
CONFIG_INPUT_PCSPKR=3Dm
CONFIG_INPUT_MAX77693_HAPTIC=3Dm
CONFIG_INPUT_MC13783_PWRBUTTON=3Dm
CONFIG_INPUT_MMA8450=3Dm
CONFIG_INPUT_MPU3050=3Dm
CONFIG_INPUT_APANEL=3Dm
CONFIG_INPUT_GP2A=3Dm
CONFIG_INPUT_GPIO_BEEPER=3Dm
CONFIG_INPUT_GPIO_TILT_POLLED=3Dm
CONFIG_INPUT_ATLAS_BTNS=3Dm
CONFIG_INPUT_ATI_REMOTE2=3Dm
CONFIG_INPUT_KEYSPAN_REMOTE=3Dm
CONFIG_INPUT_KXTJ9=3Dm
CONFIG_INPUT_KXTJ9_POLLED_MODE=3Dy
CONFIG_INPUT_POWERMATE=3Dm
CONFIG_INPUT_YEALINK=3Dm
CONFIG_INPUT_CM109=3Dm
CONFIG_INPUT_REGULATOR_HAPTIC=3Dm
CONFIG_INPUT_RETU_PWRBUTTON=3Dm
CONFIG_INPUT_TPS65218_PWRBUTTON=3Dm
CONFIG_INPUT_AXP20X_PEK=3Dm
CONFIG_INPUT_UINPUT=3Dm
CONFIG_INPUT_PCF50633_PMU=3Dm
CONFIG_INPUT_PCF8574=3Dm
CONFIG_INPUT_PWM_BEEPER=3Dm
CONFIG_INPUT_GPIO_ROTARY_ENCODER=3Dm
CONFIG_INPUT_DA9052_ONKEY=3Dm
CONFIG_INPUT_DA9063_ONKEY=3Dm
CONFIG_INPUT_WM831X_ON=3Dm
CONFIG_INPUT_PCAP=3Dm
CONFIG_INPUT_ADXL34X=3Dm
CONFIG_INPUT_ADXL34X_I2C=3Dm
CONFIG_INPUT_ADXL34X_SPI=3Dm
CONFIG_INPUT_IMS_PCU=3Dm
CONFIG_INPUT_CMA3000=3Dm
CONFIG_INPUT_CMA3000_I2C=3Dm
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=3Dm
CONFIG_INPUT_IDEAPAD_SLIDEBAR=3Dm
CONFIG_INPUT_SOC_BUTTON_ARRAY=3Dm
CONFIG_INPUT_DRV260X_HAPTICS=3Dm
CONFIG_INPUT_DRV2665_HAPTICS=3Dm
CONFIG_INPUT_DRV2667_HAPTICS=3Dm
CONFIG_RMI4_CORE=3Dm
CONFIG_RMI4_I2C=3Dm
CONFIG_RMI4_SPI=3Dm
CONFIG_RMI4_2D_SENSOR=3Dy
CONFIG_RMI4_F11=3Dy
CONFIG_RMI4_F12=3Dy
CONFIG_RMI4_F30=3Dy

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
CONFIG_SERIO_SERPORT=3Dm
CONFIG_SERIO_CT82C710=3Dm
CONFIG_SERIO_PARKBD=3Dm
CONFIG_SERIO_PCIPS2=3Dm
CONFIG_SERIO_LIBPS2=3Dy
CONFIG_SERIO_RAW=3Dm
CONFIG_SERIO_ALTERA_PS2=3Dm
CONFIG_SERIO_PS2MULT=3Dm
CONFIG_SERIO_ARC_PS2=3Dm
CONFIG_HYPERV_KEYBOARD=3Dm
CONFIG_USERIO=3Dm
CONFIG_GAMEPORT=3Dm
CONFIG_GAMEPORT_NS558=3Dm
CONFIG_GAMEPORT_L4=3Dm
CONFIG_GAMEPORT_EMU10K1=3Dm
CONFIG_GAMEPORT_FM801=3Dm

#
# Character devices
#
CONFIG_TTY=3Dy
CONFIG_VT=3Dy
CONFIG_CONSOLE_TRANSLATIONS=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_VT_CONSOLE_SLEEP=3Dy
CONFIG_HW_CONSOLE=3Dy
CONFIG_VT_HW_CONSOLE_BINDING=3Dy
CONFIG_UNIX98_PTYS=3Dy
CONFIG_LEGACY_PTYS=3Dy
CONFIG_LEGACY_PTY_COUNT=3D256
CONFIG_SERIAL_NONSTANDARD=3Dy
CONFIG_ROCKETPORT=3Dm
CONFIG_CYCLADES=3Dm
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=3Dm
CONFIG_MOXA_SMARTIO=3Dm
CONFIG_SYNCLINK=3Dm
CONFIG_SYNCLINKMP=3Dm
CONFIG_SYNCLINK_GT=3Dm
CONFIG_NOZOMI=3Dm
CONFIG_ISI=3Dm
CONFIG_N_HDLC=3Dm
CONFIG_N_GSM=3Dm
CONFIG_TRACE_ROUTER=3Dm
CONFIG_TRACE_SINK=3Dm
CONFIG_GOLDFISH_TTY=3Dm
CONFIG_DEVMEM=3Dy
CONFIG_DEVKMEM=3Dy

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=3Dy
CONFIG_SERIAL_8250=3Dy
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=3Dy
CONFIG_SERIAL_8250_PNP=3Dy
CONFIG_SERIAL_8250_FINTEK=3Dy
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_SERIAL_8250_DMA=3Dy
CONFIG_SERIAL_8250_PCI=3Dy
CONFIG_SERIAL_8250_CS=3Dm
CONFIG_SERIAL_8250_NR_UARTS=3D8
CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
CONFIG_SERIAL_8250_EXTENDED=3Dy
CONFIG_SERIAL_8250_MANY_PORTS=3Dy
CONFIG_SERIAL_8250_SHARE_IRQ=3Dy
CONFIG_SERIAL_8250_DETECT_IRQ=3Dy
CONFIG_SERIAL_8250_RSA=3Dy
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=3Dm
CONFIG_SERIAL_8250_RT288X=3Dy
CONFIG_SERIAL_8250_MID=3Dy
CONFIG_SERIAL_8250_MOXA=3Dm

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_KGDB_NMI is not set
CONFIG_SERIAL_MAX3100=3Dm
CONFIG_SERIAL_MAX310X=3Dy
CONFIG_SERIAL_UARTLITE=3Dm
CONFIG_SERIAL_CORE=3Dy
CONFIG_SERIAL_CORE_CONSOLE=3Dy
CONFIG_CONSOLE_POLL=3Dy
CONFIG_SERIAL_JSM=3Dm
CONFIG_SERIAL_SCCNXP=3Dm
CONFIG_SERIAL_SC16IS7XX_CORE=3Dm
CONFIG_SERIAL_SC16IS7XX=3Dm
CONFIG_SERIAL_SC16IS7XX_I2C=3Dy
CONFIG_SERIAL_SC16IS7XX_SPI=3Dy
CONFIG_SERIAL_ALTERA_JTAGUART=3Dm
CONFIG_SERIAL_ALTERA_UART=3Dm
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=3D4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=3D115200
CONFIG_SERIAL_IFX6X60=3Dm
CONFIG_SERIAL_ARC=3Dm
CONFIG_SERIAL_ARC_NR_PORTS=3D1
CONFIG_SERIAL_RP2=3Dm
CONFIG_SERIAL_RP2_NR_UARTS=3D32
CONFIG_SERIAL_FSL_LPUART=3Dm
CONFIG_SERIAL_MEN_Z135=3Dm
CONFIG_PRINTER=3Dm
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=3Dm
CONFIG_HVC_DRIVER=3Dy
CONFIG_HVC_IRQ=3Dy
CONFIG_HVC_XEN=3Dy
CONFIG_HVC_XEN_FRONTEND=3Dy
CONFIG_VIRTIO_CONSOLE=3Dm
CONFIG_IPMI_HANDLER=3Dm
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=3Dm
CONFIG_IPMI_SI=3Dm
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
CONFIG_IPMI_SSIF=3Dm
CONFIG_IPMI_WATCHDOG=3Dm
CONFIG_IPMI_POWEROFF=3Dm
CONFIG_HW_RANDOM=3Dm
CONFIG_HW_RANDOM_TIMERIOMEM=3Dm
CONFIG_HW_RANDOM_INTEL=3Dm
CONFIG_HW_RANDOM_AMD=3Dm
CONFIG_HW_RANDOM_VIA=3Dm
CONFIG_HW_RANDOM_VIRTIO=3Dm
CONFIG_HW_RANDOM_TPM=3Dm
CONFIG_NVRAM=3Dm
CONFIG_R3964=3Dm
CONFIG_APPLICOM=3Dm

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=3Dm
CONFIG_CARDMAN_4000=3Dm
CONFIG_CARDMAN_4040=3Dm
CONFIG_IPWIRELESS=3Dm
CONFIG_MWAVE=3Dm
CONFIG_RAW_DRIVER=3Dm
CONFIG_MAX_RAW_DEVS=3D1024
CONFIG_HPET=3Dy
CONFIG_HPET_MMAP=3Dy
CONFIG_HPET_MMAP_DEFAULT=3Dy
CONFIG_HANGCHECK_TIMER=3Dm
CONFIG_TCG_TPM=3Dy
CONFIG_TCG_TIS=3Dy
CONFIG_TCG_TIS_I2C_ATMEL=3Dm
CONFIG_TCG_TIS_I2C_INFINEON=3Dm
CONFIG_TCG_TIS_I2C_NUVOTON=3Dm
CONFIG_TCG_NSC=3Dm
CONFIG_TCG_ATMEL=3Dm
CONFIG_TCG_INFINEON=3Dm
CONFIG_TCG_XEN=3Dm
CONFIG_TCG_CRB=3Dm
CONFIG_TCG_TIS_ST33ZP24=3Dm
CONFIG_TCG_TIS_ST33ZP24_I2C=3Dm
CONFIG_TCG_TIS_ST33ZP24_SPI=3Dm
CONFIG_TELCLOCK=3Dm
CONFIG_DEVPORT=3Dy
CONFIG_XILLYBUS=3Dm
CONFIG_XILLYBUS_PCIE=3Dm

#
# I2C support
#
CONFIG_I2C=3Dm
CONFIG_I2C_BOARDINFO=3Dy
CONFIG_I2C_COMPAT=3Dy
CONFIG_I2C_CHARDEV=3Dm
CONFIG_I2C_MUX=3Dm

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=3Dm
CONFIG_I2C_MUX_PCA9541=3Dm
CONFIG_I2C_MUX_PCA954x=3Dm
CONFIG_I2C_MUX_PINCTRL=3Dm
CONFIG_I2C_MUX_REG=3Dm
CONFIG_I2C_HELPER_AUTO=3Dy
CONFIG_I2C_SMBUS=3Dm
CONFIG_I2C_ALGOBIT=3Dm
CONFIG_I2C_ALGOPCA=3Dm

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=3Dm
CONFIG_I2C_ALI1563=3Dm
CONFIG_I2C_ALI15X3=3Dm
CONFIG_I2C_AMD756=3Dm
CONFIG_I2C_AMD756_S4882=3Dm
CONFIG_I2C_AMD8111=3Dm
CONFIG_I2C_I801=3Dm
CONFIG_I2C_ISCH=3Dm
CONFIG_I2C_ISMT=3Dm
CONFIG_I2C_PIIX4=3Dm
CONFIG_I2C_NFORCE2=3Dm
CONFIG_I2C_NFORCE2_S4985=3Dm
CONFIG_I2C_SIS5595=3Dm
CONFIG_I2C_SIS630=3Dm
CONFIG_I2C_SIS96X=3Dm
CONFIG_I2C_VIA=3Dm
CONFIG_I2C_VIAPRO=3Dm

#
# ACPI drivers
#
CONFIG_I2C_SCMI=3Dm

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=3Dm
CONFIG_I2C_DESIGNWARE_CORE=3Dm
CONFIG_I2C_DESIGNWARE_PLATFORM=3Dm
CONFIG_I2C_DESIGNWARE_PCI=3Dm
CONFIG_I2C_DESIGNWARE_BAYTRAIL=3Dy
CONFIG_I2C_EMEV2=3Dm
CONFIG_I2C_GPIO=3Dm
CONFIG_I2C_KEMPLD=3Dm
CONFIG_I2C_OCORES=3Dm
CONFIG_I2C_PCA_PLATFORM=3Dm
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=3Dm
CONFIG_I2C_XILINX=3Dm

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=3Dm
CONFIG_I2C_DLN2=3Dm
CONFIG_I2C_PARPORT=3Dm
CONFIG_I2C_PARPORT_LIGHT=3Dm
CONFIG_I2C_ROBOTFUZZ_OSIF=3Dm
CONFIG_I2C_TAOS_EVM=3Dm
CONFIG_I2C_TINY_USB=3Dm
CONFIG_I2C_VIPERBOARD=3Dm

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=3Dm
CONFIG_I2C_STUB=3Dm
CONFIG_I2C_SLAVE=3Dy
CONFIG_I2C_SLAVE_EEPROM=3Dm
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=3Dy
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=3Dy

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=3Dm
CONFIG_SPI_AXI_SPI_ENGINE=3Dm
CONFIG_SPI_BITBANG=3Dm
CONFIG_SPI_BUTTERFLY=3Dm
CONFIG_SPI_CADENCE=3Dm
CONFIG_SPI_DESIGNWARE=3Dy
CONFIG_SPI_DW_PCI=3Dm
CONFIG_SPI_DW_MID_DMA=3Dy
CONFIG_SPI_DW_MMIO=3Dm
CONFIG_SPI_DLN2=3Dm
CONFIG_SPI_GPIO=3Dm
CONFIG_SPI_LM70_LLP=3Dm
CONFIG_SPI_OC_TINY=3Dm
CONFIG_SPI_PXA2XX=3Dm
CONFIG_SPI_PXA2XX_PCI=3Dm
CONFIG_SPI_ROCKCHIP=3Dm
CONFIG_SPI_SC18IS602=3Dm
CONFIG_SPI_XCOMM=3Dm
CONFIG_SPI_XILINX=3Dm
CONFIG_SPI_ZYNQMP_GQSPI=3Dm

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=3Dm
CONFIG_SPI_LOOPBACK_TEST=3Dm
CONFIG_SPI_TLE62X0=3Dm
CONFIG_SPMI=3Dm
CONFIG_HSI=3Dm
CONFIG_HSI_BOARDINFO=3Dy

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=3Dm

#
# PPS support
#
CONFIG_PPS=3Dm
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=3Dm
CONFIG_PPS_CLIENT_LDISC=3Dm
CONFIG_PPS_CLIENT_PARPORT=3Dm
CONFIG_PPS_CLIENT_GPIO=3Dm

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=3Dm

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PINCTRL=3Dy

#
# Pin controllers
#
CONFIG_PINMUX=3Dy
CONFIG_PINCONF=3Dy
CONFIG_GENERIC_PINCONF=3Dy
# CONFIG_DEBUG_PINCTRL is not set
CONFIG_PINCTRL_AMD=3Dy
CONFIG_PINCTRL_BAYTRAIL=3Dy
CONFIG_PINCTRL_CHERRYVIEW=3Dm
CONFIG_PINCTRL_INTEL=3Dm
CONFIG_PINCTRL_BROXTON=3Dm
CONFIG_PINCTRL_SUNRISEPOINT=3Dm
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
CONFIG_GPIOLIB=3Dy
CONFIG_GPIO_DEVRES=3Dy
CONFIG_GPIO_ACPI=3Dy
CONFIG_GPIOLIB_IRQCHIP=3Dy
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=3Dy
CONFIG_GPIO_GENERIC=3Dm
CONFIG_GPIO_MAX730X=3Dm

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=3Dm
CONFIG_GPIO_DWAPB=3Dm
CONFIG_GPIO_GENERIC_PLATFORM=3Dm
CONFIG_GPIO_ICH=3Dm
CONFIG_GPIO_LYNXPOINT=3Dy
CONFIG_GPIO_MENZ127=3Dm
CONFIG_GPIO_VX855=3Dm
CONFIG_GPIO_ZX=3Dy

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=3Dm
CONFIG_GPIO_IT87=3Dm
CONFIG_GPIO_SCH=3Dm
CONFIG_GPIO_SCH311X=3Dm

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=3Dm
CONFIG_GPIO_MAX7300=3Dm
CONFIG_GPIO_MAX732X=3Dm
CONFIG_GPIO_PCA953X=3Dm
CONFIG_GPIO_PCF857X=3Dm
CONFIG_GPIO_TPIC2810=3Dm

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=3Dm
CONFIG_GPIO_DA9052=3Dm
CONFIG_GPIO_DLN2=3Dm
CONFIG_GPIO_JANZ_TTL=3Dm
CONFIG_GPIO_KEMPLD=3Dm
CONFIG_GPIO_LP3943=3Dm
CONFIG_GPIO_TPS65086=3Dm
CONFIG_GPIO_TPS65218=3Dm
CONFIG_GPIO_TPS65912=3Dm
CONFIG_GPIO_UCB1400=3Dm
CONFIG_GPIO_WM831X=3Dm
CONFIG_GPIO_WM8994=3Dm

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=3Dm
CONFIG_GPIO_INTEL_MID=3Dy
CONFIG_GPIO_ML_IOH=3Dm
CONFIG_GPIO_RDC321X=3Dm

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=3Dm
CONFIG_GPIO_MC33880=3Dm
CONFIG_GPIO_PISOSR=3Dm

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=3Dm

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=3Dm
CONFIG_W1=3Dm
CONFIG_W1_CON=3Dy

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=3Dm
CONFIG_W1_MASTER_DS2490=3Dm
CONFIG_W1_MASTER_DS2482=3Dm
CONFIG_W1_MASTER_DS1WM=3Dm
CONFIG_W1_MASTER_GPIO=3Dm

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=3Dm
CONFIG_W1_SLAVE_SMEM=3Dm
CONFIG_W1_SLAVE_DS2408=3Dm
CONFIG_W1_SLAVE_DS2408_READBACK=3Dy
CONFIG_W1_SLAVE_DS2413=3Dm
CONFIG_W1_SLAVE_DS2406=3Dm
CONFIG_W1_SLAVE_DS2423=3Dm
CONFIG_W1_SLAVE_DS2431=3Dm
CONFIG_W1_SLAVE_DS2433=3Dm
CONFIG_W1_SLAVE_DS2433_CRC=3Dy
CONFIG_W1_SLAVE_DS2760=3Dm
CONFIG_W1_SLAVE_DS2780=3Dm
CONFIG_W1_SLAVE_DS2781=3Dm
CONFIG_W1_SLAVE_DS28E04=3Dm
CONFIG_W1_SLAVE_BQ27000=3Dm
CONFIG_POWER_SUPPLY=3Dy
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=3Dm
CONFIG_GENERIC_ADC_BATTERY=3Dm
CONFIG_WM831X_BACKUP=3Dm
CONFIG_WM831X_POWER=3Dm
CONFIG_TEST_POWER=3Dm
CONFIG_BATTERY_DS2760=3Dm
CONFIG_BATTERY_DS2780=3Dm
CONFIG_BATTERY_DS2781=3Dm
CONFIG_BATTERY_DS2782=3Dm
CONFIG_BATTERY_SBS=3Dm
CONFIG_BATTERY_BQ27XXX=3Dm
CONFIG_BATTERY_BQ27XXX_I2C=3Dm
CONFIG_BATTERY_DA9052=3Dm
CONFIG_CHARGER_DA9150=3Dm
CONFIG_BATTERY_DA9150=3Dm
CONFIG_AXP288_CHARGER=3Dm
CONFIG_AXP288_FUEL_GAUGE=3Dm
CONFIG_BATTERY_MAX17040=3Dm
CONFIG_BATTERY_MAX17042=3Dm
CONFIG_CHARGER_PCF50633=3Dm
CONFIG_CHARGER_ISP1704=3Dm
CONFIG_CHARGER_MAX8903=3Dm
CONFIG_CHARGER_LP8727=3Dm
CONFIG_CHARGER_GPIO=3Dm
CONFIG_CHARGER_MANAGER=3Dy
CONFIG_CHARGER_MAX77693=3Dm
CONFIG_CHARGER_BQ2415X=3Dm
CONFIG_CHARGER_BQ24190=3Dm
CONFIG_CHARGER_BQ24257=3Dm
CONFIG_CHARGER_BQ24735=3Dm
CONFIG_CHARGER_BQ25890=3Dm
CONFIG_CHARGER_SMB347=3Dm
CONFIG_CHARGER_TPS65217=3Dm
CONFIG_BATTERY_GAUGE_LTC2941=3Dm
CONFIG_BATTERY_GOLDFISH=3Dm
CONFIG_BATTERY_RT5033=3Dm
CONFIG_CHARGER_RT9455=3Dm
CONFIG_AXP20X_POWER=3Dm
CONFIG_POWER_RESET=3Dy
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_AVS=3Dy
CONFIG_HWMON=3Dm
CONFIG_HWMON_VID=3Dm
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=3Dm
CONFIG_SENSORS_ABITUGURU3=3Dm
CONFIG_SENSORS_AD7314=3Dm
CONFIG_SENSORS_AD7414=3Dm
CONFIG_SENSORS_AD7418=3Dm
CONFIG_SENSORS_ADM1021=3Dm
CONFIG_SENSORS_ADM1025=3Dm
CONFIG_SENSORS_ADM1026=3Dm
CONFIG_SENSORS_ADM1029=3Dm
CONFIG_SENSORS_ADM1031=3Dm
CONFIG_SENSORS_ADM9240=3Dm
CONFIG_SENSORS_ADT7X10=3Dm
CONFIG_SENSORS_ADT7310=3Dm
CONFIG_SENSORS_ADT7410=3Dm
CONFIG_SENSORS_ADT7411=3Dm
CONFIG_SENSORS_ADT7462=3Dm
CONFIG_SENSORS_ADT7470=3Dm
CONFIG_SENSORS_ADT7475=3Dm
CONFIG_SENSORS_ASC7621=3Dm
CONFIG_SENSORS_K8TEMP=3Dm
CONFIG_SENSORS_K10TEMP=3Dm
CONFIG_SENSORS_FAM15H_POWER=3Dm
CONFIG_SENSORS_APPLESMC=3Dm
CONFIG_SENSORS_ASB100=3Dm
CONFIG_SENSORS_ATXP1=3Dm
CONFIG_SENSORS_DS620=3Dm
CONFIG_SENSORS_DS1621=3Dm
CONFIG_SENSORS_DELL_SMM=3Dm
CONFIG_SENSORS_DA9052_ADC=3Dm
CONFIG_SENSORS_I5K_AMB=3Dm
CONFIG_SENSORS_F71805F=3Dm
CONFIG_SENSORS_F71882FG=3Dm
CONFIG_SENSORS_F75375S=3Dm
CONFIG_SENSORS_MC13783_ADC=3Dm
CONFIG_SENSORS_FSCHMD=3Dm
CONFIG_SENSORS_GL518SM=3Dm
CONFIG_SENSORS_GL520SM=3Dm
CONFIG_SENSORS_G760A=3Dm
CONFIG_SENSORS_G762=3Dm
CONFIG_SENSORS_GPIO_FAN=3Dm
CONFIG_SENSORS_HIH6130=3Dm
CONFIG_SENSORS_IBMAEM=3Dm
CONFIG_SENSORS_IBMPEX=3Dm
CONFIG_SENSORS_IIO_HWMON=3Dm
CONFIG_SENSORS_I5500=3Dm
CONFIG_SENSORS_CORETEMP=3Dm
CONFIG_SENSORS_IT87=3Dm
CONFIG_SENSORS_JC42=3Dm
CONFIG_SENSORS_POWR1220=3Dm
CONFIG_SENSORS_LINEAGE=3Dm
CONFIG_SENSORS_LTC2945=3Dm
CONFIG_SENSORS_LTC2990=3Dm
CONFIG_SENSORS_LTC4151=3Dm
CONFIG_SENSORS_LTC4215=3Dm
CONFIG_SENSORS_LTC4222=3Dm
CONFIG_SENSORS_LTC4245=3Dm
CONFIG_SENSORS_LTC4260=3Dm
CONFIG_SENSORS_LTC4261=3Dm
CONFIG_SENSORS_MAX1111=3Dm
CONFIG_SENSORS_MAX16065=3Dm
CONFIG_SENSORS_MAX1619=3Dm
CONFIG_SENSORS_MAX1668=3Dm
CONFIG_SENSORS_MAX197=3Dm
CONFIG_SENSORS_MAX31722=3Dm
CONFIG_SENSORS_MAX6639=3Dm
CONFIG_SENSORS_MAX6642=3Dm
CONFIG_SENSORS_MAX6650=3Dm
CONFIG_SENSORS_MAX6697=3Dm
CONFIG_SENSORS_MAX31790=3Dm
CONFIG_SENSORS_MCP3021=3Dm
CONFIG_SENSORS_MENF21BMC_HWMON=3Dm
CONFIG_SENSORS_ADCXX=3Dm
CONFIG_SENSORS_LM63=3Dm
CONFIG_SENSORS_LM70=3Dm
CONFIG_SENSORS_LM73=3Dm
CONFIG_SENSORS_LM75=3Dm
CONFIG_SENSORS_LM77=3Dm
CONFIG_SENSORS_LM78=3Dm
CONFIG_SENSORS_LM80=3Dm
CONFIG_SENSORS_LM83=3Dm
CONFIG_SENSORS_LM85=3Dm
CONFIG_SENSORS_LM87=3Dm
CONFIG_SENSORS_LM90=3Dm
CONFIG_SENSORS_LM92=3Dm
CONFIG_SENSORS_LM93=3Dm
CONFIG_SENSORS_LM95234=3Dm
CONFIG_SENSORS_LM95241=3Dm
CONFIG_SENSORS_LM95245=3Dm
CONFIG_SENSORS_PC87360=3Dm
CONFIG_SENSORS_PC87427=3Dm
CONFIG_SENSORS_NTC_THERMISTOR=3Dm
CONFIG_SENSORS_NCT6683=3Dm
CONFIG_SENSORS_NCT6775=3Dm
CONFIG_SENSORS_NCT7802=3Dm
CONFIG_SENSORS_NCT7904=3Dm
CONFIG_SENSORS_PCF8591=3Dm
CONFIG_PMBUS=3Dm
CONFIG_SENSORS_PMBUS=3Dm
CONFIG_SENSORS_ADM1275=3Dm
CONFIG_SENSORS_LM25066=3Dm
CONFIG_SENSORS_LTC2978=3Dm
CONFIG_SENSORS_LTC2978_REGULATOR=3Dy
CONFIG_SENSORS_LTC3815=3Dm
CONFIG_SENSORS_MAX16064=3Dm
CONFIG_SENSORS_MAX20751=3Dm
CONFIG_SENSORS_MAX34440=3Dm
CONFIG_SENSORS_MAX8688=3Dm
CONFIG_SENSORS_TPS40422=3Dm
CONFIG_SENSORS_UCD9000=3Dm
CONFIG_SENSORS_UCD9200=3Dm
CONFIG_SENSORS_ZL6100=3Dm
CONFIG_SENSORS_SHT15=3Dm
CONFIG_SENSORS_SHT21=3Dm
CONFIG_SENSORS_SHTC1=3Dm
CONFIG_SENSORS_SIS5595=3Dm
CONFIG_SENSORS_DME1737=3Dm
CONFIG_SENSORS_EMC1403=3Dm
CONFIG_SENSORS_EMC2103=3Dm
CONFIG_SENSORS_EMC6W201=3Dm
CONFIG_SENSORS_SMSC47M1=3Dm
CONFIG_SENSORS_SMSC47M192=3Dm
CONFIG_SENSORS_SMSC47B397=3Dm
CONFIG_SENSORS_SCH56XX_COMMON=3Dm
CONFIG_SENSORS_SCH5627=3Dm
CONFIG_SENSORS_SCH5636=3Dm
CONFIG_SENSORS_SMM665=3Dm
CONFIG_SENSORS_ADC128D818=3Dm
CONFIG_SENSORS_ADS1015=3Dm
CONFIG_SENSORS_ADS7828=3Dm
CONFIG_SENSORS_ADS7871=3Dm
CONFIG_SENSORS_AMC6821=3Dm
CONFIG_SENSORS_INA209=3Dm
CONFIG_SENSORS_INA2XX=3Dm
CONFIG_SENSORS_TC74=3Dm
CONFIG_SENSORS_THMC50=3Dm
CONFIG_SENSORS_TMP102=3Dm
CONFIG_SENSORS_TMP103=3Dm
CONFIG_SENSORS_TMP401=3Dm
CONFIG_SENSORS_TMP421=3Dm
CONFIG_SENSORS_VIA_CPUTEMP=3Dm
CONFIG_SENSORS_VIA686A=3Dm
CONFIG_SENSORS_VT1211=3Dm
CONFIG_SENSORS_VT8231=3Dm
CONFIG_SENSORS_W83781D=3Dm
CONFIG_SENSORS_W83791D=3Dm
CONFIG_SENSORS_W83792D=3Dm
CONFIG_SENSORS_W83793=3Dm
CONFIG_SENSORS_W83795=3Dm
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=3Dm
CONFIG_SENSORS_W83L786NG=3Dm
CONFIG_SENSORS_W83627HF=3Dm
CONFIG_SENSORS_W83627EHF=3Dm
CONFIG_SENSORS_WM831X=3Dm

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=3Dm
CONFIG_SENSORS_ATK0110=3Dm
CONFIG_THERMAL=3Dy
CONFIG_THERMAL_WRITABLE_TRIPS=3Dy
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=3Dy
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=3Dy
CONFIG_THERMAL_GOV_STEP_WISE=3Dy
CONFIG_THERMAL_GOV_BANG_BANG=3Dy
CONFIG_THERMAL_GOV_USER_SPACE=3Dy
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=3Dy
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=3Dm
CONFIG_X86_PKG_TEMP_THERMAL=3Dm
CONFIG_INTEL_SOC_DTS_IOSF_CORE=3Dm
CONFIG_INTEL_SOC_DTS_THERMAL=3Dm

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=3Dm
CONFIG_ACPI_THERMAL_REL=3Dm
CONFIG_INT3406_THERMAL=3Dm
CONFIG_INTEL_PCH_THERMAL=3Dm
CONFIG_GENERIC_ADC_THERMAL=3Dm
CONFIG_WATCHDOG=3Dy
CONFIG_WATCHDOG_CORE=3Dy
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_SYSFS=3Dy

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=3Dm
CONFIG_DA9052_WATCHDOG=3Dm
CONFIG_DA9063_WATCHDOG=3Dm
CONFIG_DA9062_WATCHDOG=3Dm
CONFIG_MENF21BMC_WATCHDOG=3Dm
CONFIG_WM831X_WATCHDOG=3Dm
CONFIG_XILINX_WATCHDOG=3Dm
CONFIG_ZIIRAVE_WATCHDOG=3Dm
CONFIG_CADENCE_WATCHDOG=3Dm
CONFIG_DW_WATCHDOG=3Dm
CONFIG_RN5T618_WATCHDOG=3Dm
CONFIG_MAX63XX_WATCHDOG=3Dm
CONFIG_RETU_WATCHDOG=3Dm
CONFIG_ACQUIRE_WDT=3Dm
CONFIG_ADVANTECH_WDT=3Dm
CONFIG_ALIM1535_WDT=3Dm
CONFIG_ALIM7101_WDT=3Dm
CONFIG_F71808E_WDT=3Dm
CONFIG_SP5100_TCO=3Dm
CONFIG_SBC_FITPC2_WATCHDOG=3Dm
CONFIG_EUROTECH_WDT=3Dm
CONFIG_IB700_WDT=3Dm
CONFIG_IBMASR=3Dm
CONFIG_WAFER_WDT=3Dm
CONFIG_I6300ESB_WDT=3Dm
CONFIG_IE6XX_WDT=3Dm
CONFIG_ITCO_WDT=3Dm
CONFIG_ITCO_VENDOR_SUPPORT=3Dy
CONFIG_IT8712F_WDT=3Dm
CONFIG_IT87_WDT=3Dm
CONFIG_HP_WATCHDOG=3Dm
CONFIG_KEMPLD_WDT=3Dm
CONFIG_HPWDT_NMI_DECODING=3Dy
CONFIG_SC1200_WDT=3Dm
CONFIG_PC87413_WDT=3Dm
CONFIG_NV_TCO=3Dm
CONFIG_60XX_WDT=3Dm
CONFIG_CPU5_WDT=3Dm
CONFIG_SMSC_SCH311X_WDT=3Dm
CONFIG_SMSC37B787_WDT=3Dm
CONFIG_VIA_WDT=3Dm
CONFIG_W83627HF_WDT=3Dm
CONFIG_W83877F_WDT=3Dm
CONFIG_W83977F_WDT=3Dm
CONFIG_MACHZ_WDT=3Dm
CONFIG_SBC_EPX_C3_WATCHDOG=3Dm
CONFIG_INTEL_MEI_WDT=3Dm
CONFIG_NI903X_WDT=3Dm
CONFIG_MEN_A21_WDT=3Dm
CONFIG_XEN_WDT=3Dm

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=3Dm
CONFIG_WDTPCI=3Dm

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=3Dm
CONFIG_SSB_POSSIBLE=3Dy

#
# Sonics Silicon Backplane
#
CONFIG_SSB=3Dm
CONFIG_SSB_SPROM=3Dy
CONFIG_SSB_BLOCKIO=3Dy
CONFIG_SSB_PCIHOST_POSSIBLE=3Dy
CONFIG_SSB_PCIHOST=3Dy
CONFIG_SSB_B43_PCI_BRIDGE=3Dy
CONFIG_SSB_PCMCIAHOST_POSSIBLE=3Dy
CONFIG_SSB_PCMCIAHOST=3Dy
CONFIG_SSB_SDIOHOST_POSSIBLE=3Dy
CONFIG_SSB_SDIOHOST=3Dy
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=3Dy
CONFIG_SSB_DRIVER_PCICORE=3Dy
CONFIG_SSB_DRIVER_GPIO=3Dy
CONFIG_BCMA_POSSIBLE=3Dy

#
# Broadcom specific AMBA
#
CONFIG_BCMA=3Dm
CONFIG_BCMA_BLOCKIO=3Dy
CONFIG_BCMA_HOST_PCI_POSSIBLE=3Dy
CONFIG_BCMA_HOST_PCI=3Dy
CONFIG_BCMA_HOST_SOC=3Dy
CONFIG_BCMA_DRIVER_PCI=3Dy
CONFIG_BCMA_DRIVER_GMAC_CMN=3Dy
CONFIG_BCMA_DRIVER_GPIO=3Dy
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=3Dy
CONFIG_MFD_BCM590XX=3Dm
CONFIG_MFD_AXP20X=3Dm
CONFIG_MFD_AXP20X_I2C=3Dm
CONFIG_MFD_CROS_EC=3Dm
CONFIG_MFD_CROS_EC_I2C=3Dm
CONFIG_MFD_CROS_EC_SPI=3Dm
CONFIG_PMIC_DA9052=3Dy
CONFIG_MFD_DA9052_SPI=3Dy
CONFIG_MFD_DA9062=3Dm
CONFIG_MFD_DA9063=3Dm
CONFIG_MFD_DA9150=3Dm
CONFIG_MFD_DLN2=3Dm
CONFIG_MFD_MC13XXX=3Dm
CONFIG_MFD_MC13XXX_SPI=3Dm
CONFIG_MFD_MC13XXX_I2C=3Dm
CONFIG_HTC_PASIC3=3Dm
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=3Dm
CONFIG_LPC_ICH=3Dm
CONFIG_LPC_SCH=3Dm
CONFIG_MFD_INTEL_LPSS=3Dm
CONFIG_MFD_INTEL_LPSS_ACPI=3Dm
CONFIG_MFD_INTEL_LPSS_PCI=3Dm
CONFIG_MFD_JANZ_CMODIO=3Dm
CONFIG_MFD_KEMPLD=3Dm
CONFIG_MFD_88PM800=3Dm
CONFIG_MFD_88PM805=3Dm
CONFIG_MFD_MAX77693=3Dm
CONFIG_MFD_MAX8907=3Dm
CONFIG_MFD_MT6397=3Dm
CONFIG_MFD_MENF21BMC=3Dm
CONFIG_EZX_PCAP=3Dy
CONFIG_MFD_VIPERBOARD=3Dm
CONFIG_MFD_RETU=3Dm
CONFIG_MFD_PCF50633=3Dm
CONFIG_PCF50633_ADC=3Dm
CONFIG_PCF50633_GPIO=3Dm
CONFIG_UCB1400_CORE=3Dm
CONFIG_MFD_RDC321X=3Dm
CONFIG_MFD_RTSX_PCI=3Dm
CONFIG_MFD_RT5033=3Dm
CONFIG_MFD_RTSX_USB=3Dm
CONFIG_MFD_RN5T618=3Dm
CONFIG_MFD_SI476X_CORE=3Dm
CONFIG_MFD_SM501=3Dm
CONFIG_MFD_SM501_GPIO=3Dy
CONFIG_MFD_SKY81452=3Dm
CONFIG_ABX500_CORE=3Dy
CONFIG_MFD_SYSCON=3Dy
CONFIG_MFD_TI_AM335X_TSCADC=3Dm
CONFIG_MFD_LP3943=3Dm
CONFIG_TPS6105X=3Dm
CONFIG_TPS65010=3Dm
CONFIG_TPS6507X=3Dm
CONFIG_MFD_TPS65086=3Dm
CONFIG_MFD_TPS65217=3Dm
CONFIG_MFD_TPS65218=3Dm
CONFIG_MFD_TPS65912=3Dy
CONFIG_MFD_TPS65912_I2C=3Dm
CONFIG_MFD_TPS65912_SPI=3Dy
CONFIG_MFD_WL1273_CORE=3Dm
CONFIG_MFD_LM3533=3Dm
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=3Dm
CONFIG_MFD_ARIZONA=3Dy
CONFIG_MFD_ARIZONA_I2C=3Dm
CONFIG_MFD_ARIZONA_SPI=3Dm
CONFIG_MFD_CS47L24=3Dy
CONFIG_MFD_WM5102=3Dy
CONFIG_MFD_WM5110=3Dy
CONFIG_MFD_WM8997=3Dy
CONFIG_MFD_WM8998=3Dy
CONFIG_MFD_WM831X=3Dy
CONFIG_MFD_WM831X_SPI=3Dy
CONFIG_MFD_WM8994=3Dm
CONFIG_REGULATOR=3Dy
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=3Dm
CONFIG_REGULATOR_VIRTUAL_CONSUMER=3Dm
CONFIG_REGULATOR_USERSPACE_CONSUMER=3Dm
CONFIG_REGULATOR_88PM800=3Dm
CONFIG_REGULATOR_ACT8865=3Dm
CONFIG_REGULATOR_AD5398=3Dm
CONFIG_REGULATOR_ANATOP=3Dm
CONFIG_REGULATOR_ARIZONA=3Dm
CONFIG_REGULATOR_AXP20X=3Dm
CONFIG_REGULATOR_BCM590XX=3Dm
CONFIG_REGULATOR_DA9052=3Dm
CONFIG_REGULATOR_DA9062=3Dm
CONFIG_REGULATOR_DA9063=3Dm
CONFIG_REGULATOR_DA9210=3Dm
CONFIG_REGULATOR_DA9211=3Dm
CONFIG_REGULATOR_FAN53555=3Dm
CONFIG_REGULATOR_GPIO=3Dm
CONFIG_REGULATOR_ISL9305=3Dm
CONFIG_REGULATOR_ISL6271A=3Dm
CONFIG_REGULATOR_LP3971=3Dm
CONFIG_REGULATOR_LP3972=3Dm
CONFIG_REGULATOR_LP872X=3Dm
CONFIG_REGULATOR_LP8755=3Dm
CONFIG_REGULATOR_LTC3589=3Dm
CONFIG_REGULATOR_MAX1586=3Dm
CONFIG_REGULATOR_MAX8649=3Dm
CONFIG_REGULATOR_MAX8660=3Dm
CONFIG_REGULATOR_MAX8907=3Dm
CONFIG_REGULATOR_MAX8952=3Dm
CONFIG_REGULATOR_MAX77693=3Dm
CONFIG_REGULATOR_MC13XXX_CORE=3Dm
CONFIG_REGULATOR_MC13783=3Dm
CONFIG_REGULATOR_MC13892=3Dm
CONFIG_REGULATOR_MT6311=3Dm
CONFIG_REGULATOR_MT6397=3Dm
CONFIG_REGULATOR_PCAP=3Dm
CONFIG_REGULATOR_PCF50633=3Dm
CONFIG_REGULATOR_PFUZE100=3Dm
CONFIG_REGULATOR_PV88060=3Dm
CONFIG_REGULATOR_PV88080=3Dm
CONFIG_REGULATOR_PV88090=3Dm
CONFIG_REGULATOR_PWM=3Dm
CONFIG_REGULATOR_QCOM_SPMI=3Dm
CONFIG_REGULATOR_RN5T618=3Dm
CONFIG_REGULATOR_RT5033=3Dm
CONFIG_REGULATOR_SKY81452=3Dm
CONFIG_REGULATOR_TPS51632=3Dm
CONFIG_REGULATOR_TPS6105X=3Dm
CONFIG_REGULATOR_TPS62360=3Dm
CONFIG_REGULATOR_TPS65023=3Dm
CONFIG_REGULATOR_TPS6507X=3Dm
CONFIG_REGULATOR_TPS65086=3Dm
CONFIG_REGULATOR_TPS65217=3Dm
CONFIG_REGULATOR_TPS6524X=3Dm
CONFIG_REGULATOR_TPS65912=3Dm
CONFIG_REGULATOR_WM831X=3Dm
CONFIG_REGULATOR_WM8994=3Dm
CONFIG_MEDIA_SUPPORT=3Dm

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=3Dy
CONFIG_MEDIA_ANALOG_TV_SUPPORT=3Dy
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=3Dy
CONFIG_MEDIA_RADIO_SUPPORT=3Dy
CONFIG_MEDIA_SDR_SUPPORT=3Dy
CONFIG_MEDIA_RC_SUPPORT=3Dy
CONFIG_MEDIA_CONTROLLER=3Dy
CONFIG_MEDIA_CONTROLLER_DVB=3Dy
CONFIG_VIDEO_DEV=3Dm
CONFIG_VIDEO_V4L2_SUBDEV_API=3Dy
CONFIG_VIDEO_V4L2=3Dm
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=3Dm
CONFIG_V4L2_MEM2MEM_DEV=3Dm
CONFIG_V4L2_FLASH_LED_CLASS=3Dm
CONFIG_VIDEOBUF_GEN=3Dm
CONFIG_VIDEOBUF_DMA_SG=3Dm
CONFIG_VIDEOBUF_VMALLOC=3Dm
CONFIG_VIDEOBUF_DVB=3Dm
CONFIG_VIDEOBUF2_CORE=3Dm
CONFIG_VIDEOBUF2_MEMOPS=3Dm
CONFIG_VIDEOBUF2_DMA_CONTIG=3Dm
CONFIG_VIDEOBUF2_VMALLOC=3Dm
CONFIG_VIDEOBUF2_DMA_SG=3Dm
CONFIG_VIDEOBUF2_DVB=3Dm
CONFIG_DVB_CORE=3Dm
CONFIG_DVB_NET=3Dy
CONFIG_TTPCI_EEPROM=3Dm
CONFIG_DVB_MAX_ADAPTERS=3D8
CONFIG_DVB_DYNAMIC_MINORS=3Dy

#
# Media drivers
#
CONFIG_RC_CORE=3Dm
CONFIG_RC_MAP=3Dm
CONFIG_RC_DECODERS=3Dy
CONFIG_LIRC=3Dm
CONFIG_IR_LIRC_CODEC=3Dm
CONFIG_IR_NEC_DECODER=3Dm
CONFIG_IR_RC5_DECODER=3Dm
CONFIG_IR_RC6_DECODER=3Dm
CONFIG_IR_JVC_DECODER=3Dm
CONFIG_IR_SONY_DECODER=3Dm
CONFIG_IR_SANYO_DECODER=3Dm
CONFIG_IR_SHARP_DECODER=3Dm
CONFIG_IR_MCE_KBD_DECODER=3Dm
CONFIG_IR_XMP_DECODER=3Dm
CONFIG_RC_DEVICES=3Dy
CONFIG_RC_ATI_REMOTE=3Dm
CONFIG_IR_ENE=3Dm
CONFIG_IR_HIX5HD2=3Dm
CONFIG_IR_IMON=3Dm
CONFIG_IR_MCEUSB=3Dm
CONFIG_IR_ITE_CIR=3Dm
CONFIG_IR_FINTEK=3Dm
CONFIG_IR_NUVOTON=3Dm
CONFIG_IR_REDRAT3=3Dm
CONFIG_IR_STREAMZAP=3Dm
CONFIG_IR_WINBOND_CIR=3Dm
CONFIG_IR_IGORPLUGUSB=3Dm
CONFIG_IR_IGUANA=3Dm
CONFIG_IR_TTUSBIR=3Dm
CONFIG_RC_LOOPBACK=3Dm
CONFIG_IR_GPIO_CIR=3Dm
CONFIG_MEDIA_USB_SUPPORT=3Dy

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=3Dm
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=3Dy
CONFIG_USB_GSPCA=3Dm
CONFIG_USB_M5602=3Dm
CONFIG_USB_STV06XX=3Dm
CONFIG_USB_GL860=3Dm
CONFIG_USB_GSPCA_BENQ=3Dm
CONFIG_USB_GSPCA_CONEX=3Dm
CONFIG_USB_GSPCA_CPIA1=3Dm
CONFIG_USB_GSPCA_DTCS033=3Dm
CONFIG_USB_GSPCA_ETOMS=3Dm
CONFIG_USB_GSPCA_FINEPIX=3Dm
CONFIG_USB_GSPCA_JEILINJ=3Dm
CONFIG_USB_GSPCA_JL2005BCD=3Dm
CONFIG_USB_GSPCA_KINECT=3Dm
CONFIG_USB_GSPCA_KONICA=3Dm
CONFIG_USB_GSPCA_MARS=3Dm
CONFIG_USB_GSPCA_MR97310A=3Dm
CONFIG_USB_GSPCA_NW80X=3Dm
CONFIG_USB_GSPCA_OV519=3Dm
CONFIG_USB_GSPCA_OV534=3Dm
CONFIG_USB_GSPCA_OV534_9=3Dm
CONFIG_USB_GSPCA_PAC207=3Dm
CONFIG_USB_GSPCA_PAC7302=3Dm
CONFIG_USB_GSPCA_PAC7311=3Dm
CONFIG_USB_GSPCA_SE401=3Dm
CONFIG_USB_GSPCA_SN9C2028=3Dm
CONFIG_USB_GSPCA_SN9C20X=3Dm
CONFIG_USB_GSPCA_SONIXB=3Dm
CONFIG_USB_GSPCA_SONIXJ=3Dm
CONFIG_USB_GSPCA_SPCA500=3Dm
CONFIG_USB_GSPCA_SPCA501=3Dm
CONFIG_USB_GSPCA_SPCA505=3Dm
CONFIG_USB_GSPCA_SPCA506=3Dm
CONFIG_USB_GSPCA_SPCA508=3Dm
CONFIG_USB_GSPCA_SPCA561=3Dm
CONFIG_USB_GSPCA_SPCA1528=3Dm
CONFIG_USB_GSPCA_SQ905=3Dm
CONFIG_USB_GSPCA_SQ905C=3Dm
CONFIG_USB_GSPCA_SQ930X=3Dm
CONFIG_USB_GSPCA_STK014=3Dm
CONFIG_USB_GSPCA_STK1135=3Dm
CONFIG_USB_GSPCA_STV0680=3Dm
CONFIG_USB_GSPCA_SUNPLUS=3Dm
CONFIG_USB_GSPCA_T613=3Dm
CONFIG_USB_GSPCA_TOPRO=3Dm
CONFIG_USB_GSPCA_TOUPTEK=3Dm
CONFIG_USB_GSPCA_TV8532=3Dm
CONFIG_USB_GSPCA_VC032X=3Dm
CONFIG_USB_GSPCA_VICAM=3Dm
CONFIG_USB_GSPCA_XIRLINK_CIT=3Dm
CONFIG_USB_GSPCA_ZC3XX=3Dm
CONFIG_USB_PWC=3Dm
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=3Dy
CONFIG_VIDEO_CPIA2=3Dm
CONFIG_USB_ZR364XX=3Dm
CONFIG_USB_STKWEBCAM=3Dm
CONFIG_USB_S2255=3Dm
CONFIG_VIDEO_USBTV=3Dm

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=3Dm
CONFIG_VIDEO_PVRUSB2_SYSFS=3Dy
CONFIG_VIDEO_PVRUSB2_DVB=3Dy
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=3Dm
CONFIG_VIDEO_USBVISION=3Dm
CONFIG_VIDEO_STK1160_COMMON=3Dm
CONFIG_VIDEO_STK1160_AC97=3Dy
CONFIG_VIDEO_STK1160=3Dm
CONFIG_VIDEO_GO7007=3Dm
CONFIG_VIDEO_GO7007_USB=3Dm
CONFIG_VIDEO_GO7007_LOADER=3Dm
CONFIG_VIDEO_GO7007_USB_S2250_BOARD=3Dm

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=3Dm
CONFIG_VIDEO_AU0828_V4L2=3Dy
CONFIG_VIDEO_AU0828_RC=3Dy
CONFIG_VIDEO_CX231XX=3Dm
CONFIG_VIDEO_CX231XX_RC=3Dy
CONFIG_VIDEO_CX231XX_ALSA=3Dm
CONFIG_VIDEO_CX231XX_DVB=3Dm
CONFIG_VIDEO_TM6000=3Dm
CONFIG_VIDEO_TM6000_ALSA=3Dm
CONFIG_VIDEO_TM6000_DVB=3Dm

#
# Digital TV USB devices
#
CONFIG_DVB_USB=3Dm
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_A800=3Dm
CONFIG_DVB_USB_DIBUSB_MB=3Dm
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=3Dm
CONFIG_DVB_USB_DIB0700=3Dm
CONFIG_DVB_USB_UMT_010=3Dm
CONFIG_DVB_USB_CXUSB=3Dm
CONFIG_DVB_USB_M920X=3Dm
CONFIG_DVB_USB_DIGITV=3Dm
CONFIG_DVB_USB_VP7045=3Dm
CONFIG_DVB_USB_VP702X=3Dm
CONFIG_DVB_USB_GP8PSK=3Dm
CONFIG_DVB_USB_NOVA_T_USB2=3Dm
CONFIG_DVB_USB_TTUSB2=3Dm
CONFIG_DVB_USB_DTT200U=3Dm
CONFIG_DVB_USB_OPERA1=3Dm
CONFIG_DVB_USB_AF9005=3Dm
CONFIG_DVB_USB_AF9005_REMOTE=3Dm
CONFIG_DVB_USB_PCTV452E=3Dm
CONFIG_DVB_USB_DW2102=3Dm
CONFIG_DVB_USB_CINERGY_T2=3Dm
CONFIG_DVB_USB_DTV5100=3Dm
CONFIG_DVB_USB_FRIIO=3Dm
CONFIG_DVB_USB_AZ6027=3Dm
CONFIG_DVB_USB_TECHNISAT_USB2=3Dm
CONFIG_DVB_USB_V2=3Dm
CONFIG_DVB_USB_AF9015=3Dm
CONFIG_DVB_USB_AF9035=3Dm
CONFIG_DVB_USB_ANYSEE=3Dm
CONFIG_DVB_USB_AU6610=3Dm
CONFIG_DVB_USB_AZ6007=3Dm
CONFIG_DVB_USB_CE6230=3Dm
CONFIG_DVB_USB_EC168=3Dm
CONFIG_DVB_USB_GL861=3Dm
CONFIG_DVB_USB_LME2510=3Dm
CONFIG_DVB_USB_MXL111SF=3Dm
CONFIG_DVB_USB_RTL28XXU=3Dm
CONFIG_DVB_USB_DVBSKY=3Dm
CONFIG_DVB_TTUSB_BUDGET=3Dm
CONFIG_DVB_TTUSB_DEC=3Dm
CONFIG_SMS_USB_DRV=3Dm
CONFIG_DVB_B2C2_FLEXCOP_USB=3Dm
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
CONFIG_DVB_AS102=3Dm

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=3Dm
CONFIG_VIDEO_EM28XX_V4L2=3Dm
CONFIG_VIDEO_EM28XX_ALSA=3Dm
CONFIG_VIDEO_EM28XX_DVB=3Dm
CONFIG_VIDEO_EM28XX_RC=3Dm

#
# Software defined radio USB devices
#
CONFIG_USB_AIRSPY=3Dm
CONFIG_USB_HACKRF=3Dm
CONFIG_USB_MSI2500=3Dm
CONFIG_MEDIA_PCI_SUPPORT=3Dy

#
# Media capture support
#
CONFIG_VIDEO_MEYE=3Dm
CONFIG_VIDEO_SOLO6X10=3Dm
CONFIG_VIDEO_TW68=3Dm
CONFIG_VIDEO_TW686X=3Dm
CONFIG_VIDEO_ZORAN=3Dm
CONFIG_VIDEO_ZORAN_DC30=3Dm
CONFIG_VIDEO_ZORAN_ZR36060=3Dm
CONFIG_VIDEO_ZORAN_BUZ=3Dm
CONFIG_VIDEO_ZORAN_DC10=3Dm
CONFIG_VIDEO_ZORAN_LML33=3Dm
CONFIG_VIDEO_ZORAN_LML33R10=3Dm
CONFIG_VIDEO_ZORAN_AVS6EYES=3Dm

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=3Dm
CONFIG_VIDEO_IVTV_ALSA=3Dm
CONFIG_VIDEO_FB_IVTV=3Dm
CONFIG_VIDEO_HEXIUM_GEMINI=3Dm
CONFIG_VIDEO_HEXIUM_ORION=3Dm
CONFIG_VIDEO_MXB=3Dm
CONFIG_VIDEO_DT3155=3Dm

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=3Dm
CONFIG_VIDEO_CX18_ALSA=3Dm
CONFIG_VIDEO_CX23885=3Dm
CONFIG_MEDIA_ALTERA_CI=3Dm
CONFIG_VIDEO_CX25821=3Dm
CONFIG_VIDEO_CX25821_ALSA=3Dm
CONFIG_VIDEO_CX88=3Dm
CONFIG_VIDEO_CX88_ALSA=3Dm
CONFIG_VIDEO_CX88_BLACKBIRD=3Dm
CONFIG_VIDEO_CX88_DVB=3Dm
CONFIG_VIDEO_CX88_ENABLE_VP3054=3Dy
CONFIG_VIDEO_CX88_VP3054=3Dm
CONFIG_VIDEO_CX88_MPEG=3Dm
CONFIG_VIDEO_BT848=3Dm
CONFIG_DVB_BT8XX=3Dm
CONFIG_VIDEO_SAA7134=3Dm
CONFIG_VIDEO_SAA7134_ALSA=3Dm
CONFIG_VIDEO_SAA7134_RC=3Dy
CONFIG_VIDEO_SAA7134_DVB=3Dm
CONFIG_VIDEO_SAA7134_GO7007=3Dm
CONFIG_VIDEO_SAA7164=3Dm
CONFIG_VIDEO_COBALT=3Dm

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=3Dy
CONFIG_DVB_AV7110=3Dm
CONFIG_DVB_AV7110_OSD=3Dy
CONFIG_DVB_BUDGET_CORE=3Dm
CONFIG_DVB_BUDGET=3Dm
CONFIG_DVB_BUDGET_CI=3Dm
CONFIG_DVB_BUDGET_AV=3Dm
CONFIG_DVB_BUDGET_PATCH=3Dm
CONFIG_DVB_B2C2_FLEXCOP_PCI=3Dm
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=3Dm
CONFIG_DVB_DM1105=3Dm
CONFIG_DVB_PT1=3Dm
CONFIG_DVB_PT3=3Dm
CONFIG_MANTIS_CORE=3Dm
CONFIG_DVB_MANTIS=3Dm
CONFIG_DVB_HOPPER=3Dm
CONFIG_DVB_NGENE=3Dm
CONFIG_DVB_DDBRIDGE=3Dm
CONFIG_DVB_SMIPCIE=3Dm
CONFIG_DVB_NETUP_UNIDVB=3Dm
CONFIG_V4L_PLATFORM_DRIVERS=3Dy
CONFIG_VIDEO_CAFE_CCIC=3Dm
CONFIG_VIDEO_VIA_CAMERA=3Dm
CONFIG_SOC_CAMERA=3Dm
CONFIG_SOC_CAMERA_PLATFORM=3Dm
CONFIG_V4L_MEM2MEM_DRIVERS=3Dy
CONFIG_VIDEO_MEM2MEM_DEINTERLACE=3Dm
CONFIG_VIDEO_SH_VEU=3Dm
# CONFIG_V4L_TEST_DRIVERS is not set
CONFIG_DVB_PLATFORM_DRIVERS=3Dy

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=3Dm
CONFIG_RADIO_ADAPTERS=3Dy
CONFIG_RADIO_TEA575X=3Dm
CONFIG_RADIO_SI470X=3Dy
CONFIG_USB_SI470X=3Dm
CONFIG_I2C_SI470X=3Dm
CONFIG_RADIO_SI4713=3Dm
CONFIG_USB_SI4713=3Dm
CONFIG_PLATFORM_SI4713=3Dm
CONFIG_I2C_SI4713=3Dm
CONFIG_RADIO_SI476X=3Dm
CONFIG_USB_MR800=3Dm
CONFIG_USB_DSBR=3Dm
CONFIG_RADIO_MAXIRADIO=3Dm
CONFIG_RADIO_SHARK=3Dm
CONFIG_RADIO_SHARK2=3Dm
CONFIG_USB_KEENE=3Dm
CONFIG_USB_RAREMONO=3Dm
CONFIG_USB_MA901=3Dm
CONFIG_RADIO_TEA5764=3Dm
CONFIG_RADIO_SAA7706H=3Dm
CONFIG_RADIO_TEF6862=3Dm
CONFIG_RADIO_WL1273=3Dm

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_RADIO_WL128X=3Dm

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=3Dm
CONFIG_DVB_FIREDTV_INPUT=3Dy
CONFIG_MEDIA_COMMON_OPTIONS=3Dy

#
# common driver options
#
CONFIG_VIDEO_CX2341X=3Dm
CONFIG_VIDEO_TVEEPROM=3Dm
CONFIG_CYPRESS_FIRMWARE=3Dm
CONFIG_DVB_B2C2_FLEXCOP=3Dm
CONFIG_VIDEO_SAA7146=3Dm
CONFIG_VIDEO_SAA7146_VV=3Dm
CONFIG_SMS_SIANO_MDTV=3Dm
CONFIG_SMS_SIANO_RC=3Dy
CONFIG_SMS_SIANO_DEBUGFS=3Dy

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=3Dy
CONFIG_MEDIA_ATTACH=3Dy
CONFIG_VIDEO_IR_I2C=3Dm

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=3Dm
CONFIG_VIDEO_TDA7432=3Dm
CONFIG_VIDEO_TDA9840=3Dm
CONFIG_VIDEO_TEA6415C=3Dm
CONFIG_VIDEO_TEA6420=3Dm
CONFIG_VIDEO_MSP3400=3Dm
CONFIG_VIDEO_CS3308=3Dm
CONFIG_VIDEO_CS5345=3Dm
CONFIG_VIDEO_CS53L32A=3Dm
CONFIG_VIDEO_UDA1342=3Dm
CONFIG_VIDEO_WM8775=3Dm
CONFIG_VIDEO_WM8739=3Dm
CONFIG_VIDEO_VP27SMPX=3Dm
CONFIG_VIDEO_SONY_BTF_MPX=3Dm

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=3Dm

#
# Video decoders
#
CONFIG_VIDEO_ADV7604=3Dm
CONFIG_VIDEO_ADV7842=3Dm
CONFIG_VIDEO_BT819=3Dm
CONFIG_VIDEO_BT856=3Dm
CONFIG_VIDEO_BT866=3Dm
CONFIG_VIDEO_KS0127=3Dm
CONFIG_VIDEO_SAA7110=3Dm
CONFIG_VIDEO_SAA711X=3Dm
CONFIG_VIDEO_TVP5150=3Dm
CONFIG_VIDEO_TW2804=3Dm
CONFIG_VIDEO_TW9903=3Dm
CONFIG_VIDEO_TW9906=3Dm
CONFIG_VIDEO_VPX3220=3Dm

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=3Dm
CONFIG_VIDEO_CX25840=3Dm

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=3Dm
CONFIG_VIDEO_SAA7185=3Dm
CONFIG_VIDEO_ADV7170=3Dm
CONFIG_VIDEO_ADV7175=3Dm
CONFIG_VIDEO_ADV7511=3Dm

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=3Dm
CONFIG_VIDEO_OV7670=3Dm
CONFIG_VIDEO_MT9V011=3Dm

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=3Dm
CONFIG_VIDEO_UPD64083=3Dm

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=3Dm

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=3Dm

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
CONFIG_SOC_CAMERA_IMX074=3Dm
CONFIG_SOC_CAMERA_MT9M001=3Dm
CONFIG_SOC_CAMERA_MT9M111=3Dm
CONFIG_SOC_CAMERA_MT9T031=3Dm
CONFIG_SOC_CAMERA_MT9T112=3Dm
CONFIG_SOC_CAMERA_MT9V022=3Dm
CONFIG_SOC_CAMERA_OV2640=3Dm
CONFIG_SOC_CAMERA_OV5642=3Dm
CONFIG_SOC_CAMERA_OV6650=3Dm
CONFIG_SOC_CAMERA_OV772X=3Dm
CONFIG_SOC_CAMERA_OV9640=3Dm
CONFIG_SOC_CAMERA_OV9740=3Dm
CONFIG_SOC_CAMERA_RJ54N1=3Dm
CONFIG_SOC_CAMERA_TW9910=3Dm
CONFIG_MEDIA_TUNER=3Dm
CONFIG_MEDIA_TUNER_SIMPLE=3Dm
CONFIG_MEDIA_TUNER_TDA8290=3Dm
CONFIG_MEDIA_TUNER_TDA827X=3Dm
CONFIG_MEDIA_TUNER_TDA18271=3Dm
CONFIG_MEDIA_TUNER_TDA9887=3Dm
CONFIG_MEDIA_TUNER_TEA5761=3Dm
CONFIG_MEDIA_TUNER_TEA5767=3Dm
CONFIG_MEDIA_TUNER_MSI001=3Dm
CONFIG_MEDIA_TUNER_MT20XX=3Dm
CONFIG_MEDIA_TUNER_MT2060=3Dm
CONFIG_MEDIA_TUNER_MT2063=3Dm
CONFIG_MEDIA_TUNER_MT2266=3Dm
CONFIG_MEDIA_TUNER_MT2131=3Dm
CONFIG_MEDIA_TUNER_QT1010=3Dm
CONFIG_MEDIA_TUNER_XC2028=3Dm
CONFIG_MEDIA_TUNER_XC5000=3Dm
CONFIG_MEDIA_TUNER_XC4000=3Dm
CONFIG_MEDIA_TUNER_MXL5005S=3Dm
CONFIG_MEDIA_TUNER_MXL5007T=3Dm
CONFIG_MEDIA_TUNER_MC44S803=3Dm
CONFIG_MEDIA_TUNER_MAX2165=3Dm
CONFIG_MEDIA_TUNER_TDA18218=3Dm
CONFIG_MEDIA_TUNER_FC0011=3Dm
CONFIG_MEDIA_TUNER_FC0012=3Dm
CONFIG_MEDIA_TUNER_FC0013=3Dm
CONFIG_MEDIA_TUNER_TDA18212=3Dm
CONFIG_MEDIA_TUNER_E4000=3Dm
CONFIG_MEDIA_TUNER_FC2580=3Dm
CONFIG_MEDIA_TUNER_M88RS6000T=3Dm
CONFIG_MEDIA_TUNER_TUA9001=3Dm
CONFIG_MEDIA_TUNER_SI2157=3Dm
CONFIG_MEDIA_TUNER_IT913X=3Dm
CONFIG_MEDIA_TUNER_R820T=3Dm
CONFIG_MEDIA_TUNER_MXL301RF=3Dm
CONFIG_MEDIA_TUNER_QM1D1C0042=3Dm

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=3Dm
CONFIG_DVB_STB6100=3Dm
CONFIG_DVB_STV090x=3Dm
CONFIG_DVB_STV6110x=3Dm
CONFIG_DVB_M88DS3103=3Dm

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=3Dm
CONFIG_DVB_TDA18271C2DD=3Dm
CONFIG_DVB_SI2165=3Dm

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=3Dm
CONFIG_DVB_CX24123=3Dm
CONFIG_DVB_MT312=3Dm
CONFIG_DVB_ZL10036=3Dm
CONFIG_DVB_ZL10039=3Dm
CONFIG_DVB_S5H1420=3Dm
CONFIG_DVB_STV0288=3Dm
CONFIG_DVB_STB6000=3Dm
CONFIG_DVB_STV0299=3Dm
CONFIG_DVB_STV6110=3Dm
CONFIG_DVB_STV0900=3Dm
CONFIG_DVB_TDA8083=3Dm
CONFIG_DVB_TDA10086=3Dm
CONFIG_DVB_TDA8261=3Dm
CONFIG_DVB_VES1X93=3Dm
CONFIG_DVB_TUNER_ITD1000=3Dm
CONFIG_DVB_TUNER_CX24113=3Dm
CONFIG_DVB_TDA826X=3Dm
CONFIG_DVB_TUA6100=3Dm
CONFIG_DVB_CX24116=3Dm
CONFIG_DVB_CX24117=3Dm
CONFIG_DVB_CX24120=3Dm
CONFIG_DVB_SI21XX=3Dm
CONFIG_DVB_TS2020=3Dm
CONFIG_DVB_DS3000=3Dm
CONFIG_DVB_MB86A16=3Dm
CONFIG_DVB_TDA10071=3Dm

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=3Dm
CONFIG_DVB_SP887X=3Dm
CONFIG_DVB_CX22700=3Dm
CONFIG_DVB_CX22702=3Dm
CONFIG_DVB_DRXD=3Dm
CONFIG_DVB_L64781=3Dm
CONFIG_DVB_TDA1004X=3Dm
CONFIG_DVB_NXT6000=3Dm
CONFIG_DVB_MT352=3Dm
CONFIG_DVB_ZL10353=3Dm
CONFIG_DVB_DIB3000MB=3Dm
CONFIG_DVB_DIB3000MC=3Dm
CONFIG_DVB_DIB7000M=3Dm
CONFIG_DVB_DIB7000P=3Dm
CONFIG_DVB_TDA10048=3Dm
CONFIG_DVB_AF9013=3Dm
CONFIG_DVB_EC100=3Dm
CONFIG_DVB_STV0367=3Dm
CONFIG_DVB_CXD2820R=3Dm
CONFIG_DVB_CXD2841ER=3Dm
CONFIG_DVB_RTL2830=3Dm
CONFIG_DVB_RTL2832=3Dm
CONFIG_DVB_RTL2832_SDR=3Dm
CONFIG_DVB_SI2168=3Dm
CONFIG_DVB_AS102_FE=3Dm

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=3Dm
CONFIG_DVB_TDA10021=3Dm
CONFIG_DVB_TDA10023=3Dm
CONFIG_DVB_STV0297=3Dm

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=3Dm
CONFIG_DVB_OR51211=3Dm
CONFIG_DVB_OR51132=3Dm
CONFIG_DVB_BCM3510=3Dm
CONFIG_DVB_LGDT330X=3Dm
CONFIG_DVB_LGDT3305=3Dm
CONFIG_DVB_LGDT3306A=3Dm
CONFIG_DVB_LG2160=3Dm
CONFIG_DVB_S5H1409=3Dm
CONFIG_DVB_AU8522=3Dm
CONFIG_DVB_AU8522_DTV=3Dm
CONFIG_DVB_AU8522_V4L=3Dm
CONFIG_DVB_S5H1411=3Dm

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=3Dm
CONFIG_DVB_DIB8000=3Dm
CONFIG_DVB_MB86A20S=3Dm

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=3Dm

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=3Dm
CONFIG_DVB_TUNER_DIB0070=3Dm
CONFIG_DVB_TUNER_DIB0090=3Dm

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=3Dm
CONFIG_DVB_LNBH25=3Dm
CONFIG_DVB_LNBP21=3Dm
CONFIG_DVB_LNBP22=3Dm
CONFIG_DVB_ISL6405=3Dm
CONFIG_DVB_ISL6421=3Dm
CONFIG_DVB_ISL6423=3Dm
CONFIG_DVB_A8293=3Dm
CONFIG_DVB_SP2=3Dm
CONFIG_DVB_LGS8GXX=3Dm
CONFIG_DVB_ATBM8830=3Dm
CONFIG_DVB_TDA665x=3Dm
CONFIG_DVB_IX2505V=3Dm
CONFIG_DVB_M88RS2000=3Dm
CONFIG_DVB_AF9033=3Dm
CONFIG_DVB_HORUS3A=3Dm
CONFIG_DVB_ASCOT2E=3Dm

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=3Dy
CONFIG_AGP_AMD64=3Dy
CONFIG_AGP_INTEL=3Dm
CONFIG_AGP_SIS=3Dm
CONFIG_AGP_VIA=3Dm
CONFIG_INTEL_GTT=3Dm
CONFIG_VGA_ARB=3Dy
CONFIG_VGA_ARB_MAX_GPUS=3D16
CONFIG_VGA_SWITCHEROO=3Dy
CONFIG_DRM=3Dm
CONFIG_DRM_MIPI_DSI=3Dy
CONFIG_DRM_DP_AUX_CHARDEV=3Dy
CONFIG_DRM_KMS_HELPER=3Dm
CONFIG_DRM_KMS_FB_HELPER=3Dy
CONFIG_DRM_FBDEV_EMULATION=3Dy
CONFIG_DRM_LOAD_EDID_FIRMWARE=3Dy
CONFIG_DRM_TTM=3Dm

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=3Dm
CONFIG_DRM_I2C_CH7006=3Dm
CONFIG_DRM_I2C_SIL164=3Dm
CONFIG_DRM_I2C_NXP_TDA998X=3Dm
CONFIG_DRM_TDFX=3Dm
CONFIG_DRM_R128=3Dm
CONFIG_DRM_RADEON=3Dm
CONFIG_DRM_RADEON_USERPTR=3Dy
CONFIG_DRM_AMDGPU=3Dm
CONFIG_DRM_AMDGPU_CIK=3Dy
CONFIG_DRM_AMDGPU_USERPTR=3Dy
# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set
CONFIG_DRM_AMD_POWERPLAY=3Dy

#
# ACP (Audio CoProcessor) Configuration
#
CONFIG_DRM_AMD_ACP=3Dy
CONFIG_DRM_NOUVEAU=3Dm
CONFIG_NOUVEAU_DEBUG=3D5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3D3
CONFIG_DRM_NOUVEAU_BACKLIGHT=3Dy
CONFIG_DRM_I810=3Dm
CONFIG_DRM_I915=3Dm
CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT=3Dy
CONFIG_DRM_I915_USERPTR=3Dy
CONFIG_DRM_MGA=3Dm
CONFIG_DRM_SIS=3Dm
CONFIG_DRM_VIA=3Dm
CONFIG_DRM_SAVAGE=3Dm
CONFIG_DRM_VGEM=3Dm
CONFIG_DRM_VMWGFX=3Dm
CONFIG_DRM_VMWGFX_FBCON=3Dy
CONFIG_DRM_GMA500=3Dm
CONFIG_DRM_GMA600=3Dy
CONFIG_DRM_GMA3600=3Dy
CONFIG_DRM_UDL=3Dm
CONFIG_DRM_AST=3Dm
CONFIG_DRM_MGAG200=3Dm
CONFIG_DRM_CIRRUS_QEMU=3Dm
CONFIG_DRM_QXL=3Dm
CONFIG_DRM_BOCHS=3Dm
CONFIG_DRM_VIRTIO_GPU=3Dm
CONFIG_DRM_PANEL=3Dy

#
# Display Panels
#
CONFIG_DRM_BRIDGE=3Dy

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=3Dm
CONFIG_HSA_AMD=3Dm

#
# Frame buffer Devices
#
CONFIG_FB=3Dy
CONFIG_FIRMWARE_EDID=3Dy
CONFIG_FB_CMDLINE=3Dy
CONFIG_FB_NOTIFY=3Dy
CONFIG_FB_DDC=3Dm
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=3Dy
CONFIG_FB_CFB_COPYAREA=3Dy
CONFIG_FB_CFB_IMAGEBLIT=3Dy
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=3Dm
CONFIG_FB_SYS_COPYAREA=3Dm
CONFIG_FB_SYS_IMAGEBLIT=3Dm
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=3Dm
CONFIG_FB_DEFERRED_IO=3Dy
CONFIG_FB_HECUBA=3Dm
CONFIG_FB_SVGALIB=3Dm
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=3Dy
CONFIG_FB_MODE_HELPERS=3Dy
CONFIG_FB_TILEBLITTING=3Dy

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=3Dm
CONFIG_FB_PM2=3Dm
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=3Dm
CONFIG_FB_CYBER2000_DDC=3Dy
CONFIG_FB_ARC=3Dm
CONFIG_FB_ASILIANT=3Dy
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=3Dm
CONFIG_FB_UVESA=3Dm
# CONFIG_FB_VESA is not set
CONFIG_FB_EFI=3Dy
CONFIG_FB_N411=3Dm
CONFIG_FB_HGA=3Dm
CONFIG_FB_OPENCORES=3Dm
CONFIG_FB_S1D13XXX=3Dm
CONFIG_FB_NVIDIA=3Dm
CONFIG_FB_NVIDIA_I2C=3Dy
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=3Dy
CONFIG_FB_RIVA=3Dm
CONFIG_FB_RIVA_I2C=3Dy
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=3Dy
CONFIG_FB_I740=3Dm
CONFIG_FB_LE80578=3Dm
CONFIG_FB_CARILLO_RANCH=3Dm
CONFIG_FB_MATROX=3Dm
CONFIG_FB_MATROX_MILLENIUM=3Dy
CONFIG_FB_MATROX_MYSTIQUE=3Dy
CONFIG_FB_MATROX_G=3Dy
CONFIG_FB_MATROX_I2C=3Dm
CONFIG_FB_MATROX_MAVEN=3Dm
CONFIG_FB_RADEON=3Dm
CONFIG_FB_RADEON_I2C=3Dy
CONFIG_FB_RADEON_BACKLIGHT=3Dy
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=3Dm
CONFIG_FB_ATY128_BACKLIGHT=3Dy
CONFIG_FB_ATY=3Dm
CONFIG_FB_ATY_CT=3Dy
CONFIG_FB_ATY_GENERIC_LCD=3Dy
CONFIG_FB_ATY_GX=3Dy
CONFIG_FB_ATY_BACKLIGHT=3Dy
CONFIG_FB_S3=3Dm
CONFIG_FB_S3_DDC=3Dy
CONFIG_FB_SAVAGE=3Dm
CONFIG_FB_SAVAGE_I2C=3Dy
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=3Dm
CONFIG_FB_SIS_300=3Dy
CONFIG_FB_SIS_315=3Dy
CONFIG_FB_VIA=3Dm
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=3Dy
CONFIG_FB_NEOMAGIC=3Dm
CONFIG_FB_KYRO=3Dm
CONFIG_FB_3DFX=3Dm
CONFIG_FB_3DFX_ACCEL=3Dy
CONFIG_FB_3DFX_I2C=3Dy
CONFIG_FB_VOODOO1=3Dm
CONFIG_FB_VT8623=3Dm
CONFIG_FB_TRIDENT=3Dm
CONFIG_FB_ARK=3Dm
CONFIG_FB_PM3=3Dm
CONFIG_FB_CARMINE=3Dm
CONFIG_FB_CARMINE_DRAM_EVAL=3Dy
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_SM501=3Dm
CONFIG_FB_SMSCUFX=3Dm
CONFIG_FB_UDL=3Dm
CONFIG_FB_IBM_GXT4500=3Dm
CONFIG_FB_GOLDFISH=3Dm
# CONFIG_FB_VIRTUAL is not set
CONFIG_XEN_FBDEV_FRONTEND=3Dm
CONFIG_FB_METRONOME=3Dm
CONFIG_FB_MB862XX=3Dm
CONFIG_FB_MB862XX_PCI_GDC=3Dy
CONFIG_FB_MB862XX_I2C=3Dy
CONFIG_FB_BROADSHEET=3Dm
CONFIG_FB_AUO_K190X=3Dm
CONFIG_FB_AUO_K1900=3Dm
CONFIG_FB_AUO_K1901=3Dm
CONFIG_FB_HYPERV=3Dm
CONFIG_FB_SIMPLE=3Dy
CONFIG_FB_SM712=3Dm
CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
CONFIG_LCD_CLASS_DEVICE=3Dm
CONFIG_LCD_L4F00242T03=3Dm
CONFIG_LCD_LMS283GF05=3Dm
CONFIG_LCD_LTV350QV=3Dm
CONFIG_LCD_ILI922X=3Dm
CONFIG_LCD_ILI9320=3Dm
CONFIG_LCD_TDO24M=3Dm
CONFIG_LCD_VGG2432A4=3Dm
CONFIG_LCD_PLATFORM=3Dm
CONFIG_LCD_S6E63M0=3Dm
CONFIG_LCD_LD9040=3Dm
CONFIG_LCD_AMS369FG06=3Dm
CONFIG_LCD_LMS501KF03=3Dm
CONFIG_LCD_HX8357=3Dm
CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
CONFIG_BACKLIGHT_GENERIC=3Dm
CONFIG_BACKLIGHT_LM3533=3Dm
CONFIG_BACKLIGHT_CARILLO_RANCH=3Dm
CONFIG_BACKLIGHT_PWM=3Dm
CONFIG_BACKLIGHT_DA9052=3Dm
CONFIG_BACKLIGHT_APPLE=3Dm
CONFIG_BACKLIGHT_PM8941_WLED=3Dm
CONFIG_BACKLIGHT_SAHARA=3Dm
CONFIG_BACKLIGHT_WM831X=3Dm
CONFIG_BACKLIGHT_ADP8860=3Dm
CONFIG_BACKLIGHT_ADP8870=3Dm
CONFIG_BACKLIGHT_PCF50633=3Dm
CONFIG_BACKLIGHT_LM3630A=3Dm
CONFIG_BACKLIGHT_LM3639=3Dm
CONFIG_BACKLIGHT_LP855X=3Dm
CONFIG_BACKLIGHT_SKY81452=3Dm
CONFIG_BACKLIGHT_TPS65217=3Dm
CONFIG_BACKLIGHT_GPIO=3Dm
CONFIG_BACKLIGHT_LV5207LP=3Dm
CONFIG_BACKLIGHT_BD6107=3Dm
CONFIG_VGASTATE=3Dm
CONFIG_HDMI=3Dy

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_DUMMY_CONSOLE_COLUMNS=3D80
CONFIG_DUMMY_CONSOLE_ROWS=3D25
CONFIG_FRAMEBUFFER_CONSOLE=3Dy
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=3Dy
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=3Dy
# CONFIG_LOGO is not set
CONFIG_SOUND=3Dm
CONFIG_SOUND_OSS_CORE=3Dy
CONFIG_SOUND_OSS_CORE_PRECLAIM=3Dy
CONFIG_SND=3Dm
CONFIG_SND_TIMER=3Dm
CONFIG_SND_PCM=3Dm
CONFIG_SND_PCM_ELD=3Dy
CONFIG_SND_DMAENGINE_PCM=3Dm
CONFIG_SND_HWDEP=3Dm
CONFIG_SND_RAWMIDI=3Dm
CONFIG_SND_COMPRESS_OFFLOAD=3Dm
CONFIG_SND_JACK=3Dy
CONFIG_SND_JACK_INPUT_DEV=3Dy
CONFIG_SND_SEQUENCER=3Dm
CONFIG_SND_SEQ_DUMMY=3Dm
CONFIG_SND_OSSEMUL=3Dy
CONFIG_SND_MIXER_OSS=3Dm
CONFIG_SND_PCM_OSS=3Dm
CONFIG_SND_PCM_OSS_PLUGINS=3Dy
CONFIG_SND_PCM_TIMER=3Dy
CONFIG_SND_SEQUENCER_OSS=3Dy
CONFIG_SND_HRTIMER=3Dm
CONFIG_SND_SEQ_HRTIMER_DEFAULT=3Dy
CONFIG_SND_DYNAMIC_MINORS=3Dy
CONFIG_SND_MAX_CARDS=3D32
CONFIG_SND_SUPPORT_OLD_API=3Dy
CONFIG_SND_PROC_FS=3Dy
CONFIG_SND_VERBOSE_PROCFS=3Dy
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=3Dy
CONFIG_SND_DMA_SGBUF=3Dy
CONFIG_SND_RAWMIDI_SEQ=3Dm
CONFIG_SND_OPL3_LIB_SEQ=3Dm
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=3Dm
CONFIG_SND_MPU401_UART=3Dm
CONFIG_SND_OPL3_LIB=3Dm
CONFIG_SND_VX_LIB=3Dm
CONFIG_SND_AC97_CODEC=3Dm
CONFIG_SND_DRIVERS=3Dy
CONFIG_SND_PCSP=3Dm
CONFIG_SND_DUMMY=3Dm
CONFIG_SND_ALOOP=3Dm
CONFIG_SND_VIRMIDI=3Dm
CONFIG_SND_MTPAV=3Dm
CONFIG_SND_MTS64=3Dm
CONFIG_SND_SERIAL_U16550=3Dm
CONFIG_SND_MPU401=3Dm
CONFIG_SND_PORTMAN2X4=3Dm
CONFIG_SND_AC97_POWER_SAVE=3Dy
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=3D0
CONFIG_SND_SB_COMMON=3Dm
CONFIG_SND_PCI=3Dy
CONFIG_SND_AD1889=3Dm
CONFIG_SND_ALS300=3Dm
CONFIG_SND_ALS4000=3Dm
CONFIG_SND_ALI5451=3Dm
CONFIG_SND_ASIHPI=3Dm
CONFIG_SND_ATIIXP=3Dm
CONFIG_SND_ATIIXP_MODEM=3Dm
CONFIG_SND_AU8810=3Dm
CONFIG_SND_AU8820=3Dm
CONFIG_SND_AU8830=3Dm
CONFIG_SND_AW2=3Dm
CONFIG_SND_AZT3328=3Dm
CONFIG_SND_BT87X=3Dm
CONFIG_SND_BT87X_OVERCLOCK=3Dy
CONFIG_SND_CA0106=3Dm
CONFIG_SND_CMIPCI=3Dm
CONFIG_SND_OXYGEN_LIB=3Dm
CONFIG_SND_OXYGEN=3Dm
CONFIG_SND_CS4281=3Dm
CONFIG_SND_CS46XX=3Dm
CONFIG_SND_CS46XX_NEW_DSP=3Dy
CONFIG_SND_CTXFI=3Dm
CONFIG_SND_DARLA20=3Dm
CONFIG_SND_GINA20=3Dm
CONFIG_SND_LAYLA20=3Dm
CONFIG_SND_DARLA24=3Dm
CONFIG_SND_GINA24=3Dm
CONFIG_SND_LAYLA24=3Dm
CONFIG_SND_MONA=3Dm
CONFIG_SND_MIA=3Dm
CONFIG_SND_ECHO3G=3Dm
CONFIG_SND_INDIGO=3Dm
CONFIG_SND_INDIGOIO=3Dm
CONFIG_SND_INDIGODJ=3Dm
CONFIG_SND_INDIGOIOX=3Dm
CONFIG_SND_INDIGODJX=3Dm
CONFIG_SND_EMU10K1=3Dm
CONFIG_SND_EMU10K1X=3Dm
CONFIG_SND_ENS1370=3Dm
CONFIG_SND_ENS1371=3Dm
CONFIG_SND_ES1938=3Dm
CONFIG_SND_ES1968=3Dm
CONFIG_SND_ES1968_INPUT=3Dy
CONFIG_SND_ES1968_RADIO=3Dy
CONFIG_SND_FM801=3Dm
CONFIG_SND_FM801_TEA575X_BOOL=3Dy
CONFIG_SND_HDSP=3Dm
CONFIG_SND_HDSPM=3Dm
CONFIG_SND_ICE1712=3Dm
CONFIG_SND_ICE1724=3Dm
CONFIG_SND_INTEL8X0=3Dm
CONFIG_SND_INTEL8X0M=3Dm
CONFIG_SND_KORG1212=3Dm
CONFIG_SND_LOLA=3Dm
CONFIG_SND_LX6464ES=3Dm
CONFIG_SND_MAESTRO3=3Dm
CONFIG_SND_MAESTRO3_INPUT=3Dy
CONFIG_SND_MIXART=3Dm
CONFIG_SND_NM256=3Dm
CONFIG_SND_PCXHR=3Dm
CONFIG_SND_RIPTIDE=3Dm
CONFIG_SND_RME32=3Dm
CONFIG_SND_RME96=3Dm
CONFIG_SND_RME9652=3Dm
CONFIG_SND_SONICVIBES=3Dm
CONFIG_SND_TRIDENT=3Dm
CONFIG_SND_VIA82XX=3Dm
CONFIG_SND_VIA82XX_MODEM=3Dm
CONFIG_SND_VIRTUOSO=3Dm
CONFIG_SND_VX222=3Dm
CONFIG_SND_YMFPCI=3Dm

#
# HD-Audio
#
CONFIG_SND_HDA=3Dm
CONFIG_SND_HDA_INTEL=3Dm
CONFIG_SND_HDA_HWDEP=3Dy
CONFIG_SND_HDA_RECONFIG=3Dy
CONFIG_SND_HDA_INPUT_BEEP=3Dy
CONFIG_SND_HDA_INPUT_BEEP_MODE=3D1
CONFIG_SND_HDA_PATCH_LOADER=3Dy
CONFIG_SND_HDA_CODEC_REALTEK=3Dm
CONFIG_SND_HDA_CODEC_ANALOG=3Dm
CONFIG_SND_HDA_CODEC_SIGMATEL=3Dm
CONFIG_SND_HDA_CODEC_VIA=3Dm
CONFIG_SND_HDA_CODEC_HDMI=3Dm
CONFIG_SND_HDA_CODEC_CIRRUS=3Dm
CONFIG_SND_HDA_CODEC_CONEXANT=3Dm
CONFIG_SND_HDA_CODEC_CA0110=3Dm
CONFIG_SND_HDA_CODEC_CA0132=3Dm
CONFIG_SND_HDA_CODEC_CA0132_DSP=3Dy
CONFIG_SND_HDA_CODEC_CMEDIA=3Dm
CONFIG_SND_HDA_CODEC_SI3054=3Dm
CONFIG_SND_HDA_GENERIC=3Dm
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=3D300
CONFIG_SND_HDA_CORE=3Dm
CONFIG_SND_HDA_DSP_LOADER=3Dy
CONFIG_SND_HDA_I915=3Dy
CONFIG_SND_HDA_EXT_CORE=3Dm
CONFIG_SND_HDA_PREALLOC_SIZE=3D2048
CONFIG_SND_SPI=3Dy
CONFIG_SND_USB=3Dy
CONFIG_SND_USB_AUDIO=3Dm
CONFIG_SND_USB_UA101=3Dm
CONFIG_SND_USB_USX2Y=3Dm
CONFIG_SND_USB_CAIAQ=3Dm
CONFIG_SND_USB_CAIAQ_INPUT=3Dy
CONFIG_SND_USB_US122L=3Dm
CONFIG_SND_USB_6FIRE=3Dm
CONFIG_SND_USB_HIFACE=3Dm
CONFIG_SND_BCD2000=3Dm
CONFIG_SND_USB_LINE6=3Dm
CONFIG_SND_USB_POD=3Dm
CONFIG_SND_USB_PODHD=3Dm
CONFIG_SND_USB_TONEPORT=3Dm
CONFIG_SND_USB_VARIAX=3Dm
CONFIG_SND_FIREWIRE=3Dy
CONFIG_SND_FIREWIRE_LIB=3Dm
CONFIG_SND_DICE=3Dm
CONFIG_SND_OXFW=3Dm
CONFIG_SND_ISIGHT=3Dm
CONFIG_SND_FIREWORKS=3Dm
CONFIG_SND_BEBOB=3Dm
CONFIG_SND_FIREWIRE_DIGI00X=3Dm
CONFIG_SND_FIREWIRE_TASCAM=3Dm
CONFIG_SND_PCMCIA=3Dy
CONFIG_SND_VXPOCKET=3Dm
CONFIG_SND_PDAUDIOCF=3Dm
CONFIG_SND_SOC=3Dm
CONFIG_SND_SOC_AC97_BUS=3Dy
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=3Dy
CONFIG_SND_SOC_COMPRESS=3Dy
CONFIG_SND_SOC_TOPOLOGY=3Dy
CONFIG_SND_SOC_AMD_ACP=3Dm
CONFIG_SND_ATMEL_SOC=3Dm
CONFIG_SND_DESIGNWARE_I2S=3Dm

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=3Dm
CONFIG_SND_SOC_FSL_SAI=3Dm
CONFIG_SND_SOC_FSL_SSI=3Dm
CONFIG_SND_SOC_FSL_SPDIF=3Dm
CONFIG_SND_SOC_FSL_ESAI=3Dm
CONFIG_SND_SOC_IMX_AUDMUX=3Dm
CONFIG_SND_SOC_IMG=3Dy
CONFIG_SND_SOC_IMG_I2S_IN=3Dm
CONFIG_SND_SOC_IMG_I2S_OUT=3Dm
CONFIG_SND_SOC_IMG_PARALLEL_OUT=3Dm
CONFIG_SND_SOC_IMG_SPDIF_IN=3Dm
CONFIG_SND_SOC_IMG_SPDIF_OUT=3Dm
CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC=3Dm
CONFIG_SND_SST_MFLD_PLATFORM=3Dm
CONFIG_SND_SST_IPC=3Dm
CONFIG_SND_SST_IPC_ACPI=3Dm
CONFIG_SND_SOC_INTEL_SST=3Dm
CONFIG_SND_SOC_INTEL_SST_ACPI=3Dm
CONFIG_SND_SOC_INTEL_SST_MATCH=3Dm
CONFIG_SND_SOC_INTEL_BXT_RT298_MACH=3Dm
CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH=3Dm
CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH=3Dm
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5672_MACH=3Dm
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5645_MACH=3Dm
CONFIG_SND_SOC_INTEL_CHT_BSW_MAX98090_TI_MACH=3Dm
CONFIG_SND_SOC_INTEL_SKYLAKE=3Dm
CONFIG_SND_SOC_INTEL_SKL_RT286_MACH=3Dm
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_SSM4567_MACH=3Dm
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_MAX98357A_MACH=3Dm

#
# Allwinner SoC Audio support
#
CONFIG_SND_SUN4I_CODEC=3Dm
CONFIG_SND_SOC_XTFPGA_I2S=3Dm
CONFIG_SND_SOC_I2C_AND_SPI=3Dm

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=3Dm
CONFIG_SND_SOC_ADAU1701=3Dm
CONFIG_SND_SOC_AK4104=3Dm
CONFIG_SND_SOC_AK4554=3Dm
CONFIG_SND_SOC_AK4613=3Dm
CONFIG_SND_SOC_AK4642=3Dm
CONFIG_SND_SOC_AK5386=3Dm
CONFIG_SND_SOC_ALC5623=3Dm
CONFIG_SND_SOC_CS35L32=3Dm
CONFIG_SND_SOC_CS42L51=3Dm
CONFIG_SND_SOC_CS42L51_I2C=3Dm
CONFIG_SND_SOC_CS42L52=3Dm
CONFIG_SND_SOC_CS42L56=3Dm
CONFIG_SND_SOC_CS42L73=3Dm
CONFIG_SND_SOC_CS4265=3Dm
CONFIG_SND_SOC_CS4270=3Dm
CONFIG_SND_SOC_CS4271=3Dm
CONFIG_SND_SOC_CS4271_I2C=3Dm
CONFIG_SND_SOC_CS4271_SPI=3Dm
CONFIG_SND_SOC_CS42XX8=3Dm
CONFIG_SND_SOC_CS42XX8_I2C=3Dm
CONFIG_SND_SOC_CS4349=3Dm
CONFIG_SND_SOC_DMIC=3Dm
CONFIG_SND_SOC_ES8328=3Dm
CONFIG_SND_SOC_GTM601=3Dm
CONFIG_SND_SOC_HDAC_HDMI=3Dm
CONFIG_SND_SOC_INNO_RK3036=3Dm
CONFIG_SND_SOC_MAX98090=3Dm
CONFIG_SND_SOC_MAX98357A=3Dm
CONFIG_SND_SOC_PCM1681=3Dm
CONFIG_SND_SOC_PCM179X=3Dm
CONFIG_SND_SOC_PCM179X_I2C=3Dm
CONFIG_SND_SOC_PCM179X_SPI=3Dm
CONFIG_SND_SOC_PCM3168A=3Dm
CONFIG_SND_SOC_PCM3168A_I2C=3Dm
CONFIG_SND_SOC_PCM3168A_SPI=3Dm
CONFIG_SND_SOC_PCM512x=3Dm
CONFIG_SND_SOC_PCM512x_I2C=3Dm
CONFIG_SND_SOC_PCM512x_SPI=3Dm
CONFIG_SND_SOC_RL6231=3Dm
CONFIG_SND_SOC_RL6347A=3Dm
CONFIG_SND_SOC_RT286=3Dm
CONFIG_SND_SOC_RT298=3Dm
CONFIG_SND_SOC_RT5616=3Dm
CONFIG_SND_SOC_RT5631=3Dm
CONFIG_SND_SOC_RT5640=3Dm
CONFIG_SND_SOC_RT5645=3Dm
CONFIG_SND_SOC_RT5651=3Dm
CONFIG_SND_SOC_RT5670=3Dm
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=3Dm
CONFIG_SND_SOC_SI476X=3Dm
CONFIG_SND_SOC_SIGMADSP=3Dm
CONFIG_SND_SOC_SIGMADSP_I2C=3Dm
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=3Dm
CONFIG_SND_SOC_SPDIF=3Dm
CONFIG_SND_SOC_SSM2602=3Dm
CONFIG_SND_SOC_SSM2602_SPI=3Dm
CONFIG_SND_SOC_SSM2602_I2C=3Dm
CONFIG_SND_SOC_SSM4567=3Dm
CONFIG_SND_SOC_STA32X=3Dm
CONFIG_SND_SOC_STA350=3Dm
CONFIG_SND_SOC_STI_SAS=3Dm
CONFIG_SND_SOC_TAS2552=3Dm
CONFIG_SND_SOC_TAS5086=3Dm
CONFIG_SND_SOC_TAS571X=3Dm
CONFIG_SND_SOC_TAS5720=3Dm
CONFIG_SND_SOC_TFA9879=3Dm
CONFIG_SND_SOC_TLV320AIC23=3Dm
CONFIG_SND_SOC_TLV320AIC23_I2C=3Dm
CONFIG_SND_SOC_TLV320AIC23_SPI=3Dm
CONFIG_SND_SOC_TLV320AIC31XX=3Dm
CONFIG_SND_SOC_TLV320AIC3X=3Dm
CONFIG_SND_SOC_TS3A227E=3Dm
CONFIG_SND_SOC_WM8510=3Dm
CONFIG_SND_SOC_WM8523=3Dm
CONFIG_SND_SOC_WM8580=3Dm
CONFIG_SND_SOC_WM8711=3Dm
CONFIG_SND_SOC_WM8728=3Dm
CONFIG_SND_SOC_WM8731=3Dm
CONFIG_SND_SOC_WM8737=3Dm
CONFIG_SND_SOC_WM8741=3Dm
CONFIG_SND_SOC_WM8750=3Dm
CONFIG_SND_SOC_WM8753=3Dm
CONFIG_SND_SOC_WM8770=3Dm
CONFIG_SND_SOC_WM8776=3Dm
CONFIG_SND_SOC_WM8804=3Dm
CONFIG_SND_SOC_WM8804_I2C=3Dm
CONFIG_SND_SOC_WM8804_SPI=3Dm
CONFIG_SND_SOC_WM8903=3Dm
CONFIG_SND_SOC_WM8960=3Dm
CONFIG_SND_SOC_WM8962=3Dm
CONFIG_SND_SOC_WM8974=3Dm
CONFIG_SND_SOC_WM8978=3Dm
CONFIG_SND_SOC_NAU8825=3Dm
CONFIG_SND_SOC_TPA6130A2=3Dm
CONFIG_SND_SIMPLE_CARD=3Dm
CONFIG_SOUND_PRIME=3Dm
CONFIG_SOUND_OSS=3Dm
# CONFIG_SOUND_TRACEINIT is not set
# CONFIG_SOUND_DMAP is not set
CONFIG_SOUND_VMIDI=3Dm
# CONFIG_SOUND_TRIX is not set
# CONFIG_SOUND_MSS is not set
# CONFIG_SOUND_MPU401 is not set
# CONFIG_SOUND_PAS is not set
# CONFIG_SOUND_PSS is not set
# CONFIG_SOUND_SB is not set
CONFIG_SOUND_YM3812=3Dm
# CONFIG_SOUND_UART6850 is not set
# CONFIG_SOUND_AEDSP16 is not set
CONFIG_AC97_BUS=3Dm

#
# HID support
#
CONFIG_HID=3Dm
CONFIG_HID_BATTERY_STRENGTH=3Dy
CONFIG_HIDRAW=3Dy
CONFIG_UHID=3Dm
CONFIG_HID_GENERIC=3Dm

#
# Special HID drivers
#
CONFIG_HID_A4TECH=3Dm
CONFIG_HID_ACRUX=3Dm
CONFIG_HID_ACRUX_FF=3Dy
CONFIG_HID_APPLE=3Dm
CONFIG_HID_APPLEIR=3Dm
CONFIG_HID_ASUS=3Dm
CONFIG_HID_AUREAL=3Dm
CONFIG_HID_BELKIN=3Dm
CONFIG_HID_BETOP_FF=3Dm
CONFIG_HID_CHERRY=3Dm
CONFIG_HID_CHICONY=3Dm
CONFIG_HID_CORSAIR=3Dm
CONFIG_HID_PRODIKEYS=3Dm
CONFIG_HID_CMEDIA=3Dm
CONFIG_HID_CP2112=3Dm
CONFIG_HID_CYPRESS=3Dm
CONFIG_HID_DRAGONRISE=3Dm
CONFIG_DRAGONRISE_FF=3Dy
CONFIG_HID_EMS_FF=3Dm
CONFIG_HID_ELECOM=3Dm
CONFIG_HID_ELO=3Dm
CONFIG_HID_EZKEY=3Dm
CONFIG_HID_GEMBIRD=3Dm
CONFIG_HID_GFRM=3Dm
CONFIG_HID_HOLTEK=3Dm
CONFIG_HOLTEK_FF=3Dy
CONFIG_HID_GT683R=3Dm
CONFIG_HID_KEYTOUCH=3Dm
CONFIG_HID_KYE=3Dm
CONFIG_HID_UCLOGIC=3Dm
CONFIG_HID_WALTOP=3Dm
CONFIG_HID_GYRATION=3Dm
CONFIG_HID_ICADE=3Dm
CONFIG_HID_TWINHAN=3Dm
CONFIG_HID_KENSINGTON=3Dm
CONFIG_HID_LCPOWER=3Dm
CONFIG_HID_LENOVO=3Dm
CONFIG_HID_LOGITECH=3Dm
CONFIG_HID_LOGITECH_DJ=3Dm
CONFIG_HID_LOGITECH_HIDPP=3Dm
CONFIG_LOGITECH_FF=3Dy
CONFIG_LOGIRUMBLEPAD2_FF=3Dy
CONFIG_LOGIG940_FF=3Dy
CONFIG_LOGIWHEELS_FF=3Dy
CONFIG_HID_MAGICMOUSE=3Dm
CONFIG_HID_MICROSOFT=3Dm
CONFIG_HID_MONTEREY=3Dm
CONFIG_HID_MULTITOUCH=3Dm
CONFIG_HID_NTRIG=3Dm
CONFIG_HID_ORTEK=3Dm
CONFIG_HID_PANTHERLORD=3Dm
CONFIG_PANTHERLORD_FF=3Dy
CONFIG_HID_PENMOUNT=3Dm
CONFIG_HID_PETALYNX=3Dm
CONFIG_HID_PICOLCD=3Dm
CONFIG_HID_PICOLCD_FB=3Dy
CONFIG_HID_PICOLCD_BACKLIGHT=3Dy
CONFIG_HID_PICOLCD_LCD=3Dy
CONFIG_HID_PICOLCD_LEDS=3Dy
CONFIG_HID_PICOLCD_CIR=3Dy
CONFIG_HID_PLANTRONICS=3Dm
CONFIG_HID_PRIMAX=3Dm
CONFIG_HID_ROCCAT=3Dm
CONFIG_HID_SAITEK=3Dm
CONFIG_HID_SAMSUNG=3Dm
CONFIG_HID_SONY=3Dm
CONFIG_SONY_FF=3Dy
CONFIG_HID_SPEEDLINK=3Dm
CONFIG_HID_STEELSERIES=3Dm
CONFIG_HID_SUNPLUS=3Dm
CONFIG_HID_RMI=3Dm
CONFIG_HID_GREENASIA=3Dm
CONFIG_GREENASIA_FF=3Dy
CONFIG_HID_HYPERV_MOUSE=3Dm
CONFIG_HID_SMARTJOYPLUS=3Dm
CONFIG_SMARTJOYPLUS_FF=3Dy
CONFIG_HID_TIVO=3Dm
CONFIG_HID_TOPSEED=3Dm
CONFIG_HID_THINGM=3Dm
CONFIG_HID_THRUSTMASTER=3Dm
CONFIG_THRUSTMASTER_FF=3Dy
CONFIG_HID_WACOM=3Dm
CONFIG_HID_WIIMOTE=3Dm
CONFIG_HID_XINMO=3Dm
CONFIG_HID_ZEROPLUS=3Dm
CONFIG_ZEROPLUS_FF=3Dy
CONFIG_HID_ZYDACRON=3Dm
CONFIG_HID_SENSOR_HUB=3Dm
CONFIG_HID_SENSOR_CUSTOM_SENSOR=3Dm

#
# USB HID support
#
CONFIG_USB_HID=3Dm
CONFIG_HID_PID=3Dy
CONFIG_USB_HIDDEV=3Dy

#
# I2C HID support
#
CONFIG_I2C_HID=3Dm
CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_COMMON=3Dm
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB=3Dm
CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=3Dy
CONFIG_USB_DYNAMIC_MINORS=3Dy
CONFIG_USB_OTG=3Dy
CONFIG_USB_OTG_WHITELIST=3Dy
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_OTG_FSM=3Dm
CONFIG_USB_ULPI_BUS=3Dm
CONFIG_USB_MON=3Dm
CONFIG_USB_WUSB=3Dm
CONFIG_USB_WUSB_CBAF=3Dm
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=3Dm
CONFIG_USB_XHCI_HCD=3Dm
CONFIG_USB_XHCI_PCI=3Dm
CONFIG_USB_XHCI_PLATFORM=3Dm
CONFIG_USB_EHCI_HCD=3Dm
CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
CONFIG_USB_EHCI_TT_NEWSCHED=3Dy
CONFIG_USB_EHCI_PCI=3Dm
CONFIG_USB_EHCI_HCD_PLATFORM=3Dm
CONFIG_USB_OXU210HP_HCD=3Dm
CONFIG_USB_ISP116X_HCD=3Dm
CONFIG_USB_ISP1362_HCD=3Dm
CONFIG_USB_FOTG210_HCD=3Dm
CONFIG_USB_MAX3421_HCD=3Dm
CONFIG_USB_OHCI_HCD=3Dm
CONFIG_USB_OHCI_HCD_PCI=3Dm
CONFIG_USB_OHCI_HCD_SSB=3Dy
CONFIG_USB_OHCI_HCD_PLATFORM=3Dm
CONFIG_USB_UHCI_HCD=3Dm
CONFIG_USB_U132_HCD=3Dm
CONFIG_USB_SL811_HCD=3Dm
CONFIG_USB_SL811_HCD_ISO=3Dy
CONFIG_USB_SL811_CS=3Dm
CONFIG_USB_R8A66597_HCD=3Dm
CONFIG_USB_WHCI_HCD=3Dm
CONFIG_USB_HWA_HCD=3Dm
CONFIG_USB_HCD_BCMA=3Dm
CONFIG_USB_HCD_SSB=3Dm
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=3Dm
CONFIG_USB_PRINTER=3Dm
CONFIG_USB_WDM=3Dm
CONFIG_USB_TMC=3Dm

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=3Dm
CONFIG_REALTEK_AUTOPM=3Dy
CONFIG_USB_STORAGE_DATAFAB=3Dm
CONFIG_USB_STORAGE_FREECOM=3Dm
CONFIG_USB_STORAGE_ISD200=3Dm
CONFIG_USB_STORAGE_USBAT=3Dm
CONFIG_USB_STORAGE_SDDR09=3Dm
CONFIG_USB_STORAGE_SDDR55=3Dm
CONFIG_USB_STORAGE_JUMPSHOT=3Dm
CONFIG_USB_STORAGE_ALAUDA=3Dm
CONFIG_USB_STORAGE_ONETOUCH=3Dm
CONFIG_USB_STORAGE_KARMA=3Dm
CONFIG_USB_STORAGE_CYPRESS_ATACB=3Dm
CONFIG_USB_STORAGE_ENE_UB6250=3Dm
CONFIG_USB_UAS=3Dm

#
# USB Imaging devices
#
CONFIG_USB_MDC800=3Dm
CONFIG_USB_MICROTEK=3Dm
CONFIG_USBIP_CORE=3Dm
CONFIG_USBIP_VHCI_HCD=3Dm
CONFIG_USBIP_HOST=3Dm
CONFIG_USBIP_VUDC=3Dm
# CONFIG_USBIP_DEBUG is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=3Dm
CONFIG_USB_DWC3_ULPI=3Dy
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=3Dy

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=3Dm
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=3Dm
CONFIG_USB_CHIPIDEA_PCI=3Dm
CONFIG_USB_CHIPIDEA_UDC=3Dy
CONFIG_USB_CHIPIDEA_HOST=3Dy
CONFIG_USB_ISP1760=3Dm
CONFIG_USB_ISP1760_HCD=3Dy
CONFIG_USB_ISP1761_UDC=3Dy
# CONFIG_USB_ISP1760_HOST_ROLE is not set
# CONFIG_USB_ISP1760_GADGET_ROLE is not set
CONFIG_USB_ISP1760_DUAL_ROLE=3Dy

#
# USB port drivers
#
CONFIG_USB_USS720=3Dm
CONFIG_USB_SERIAL=3Dm
CONFIG_USB_SERIAL_GENERIC=3Dy
CONFIG_USB_SERIAL_SIMPLE=3Dm
CONFIG_USB_SERIAL_AIRCABLE=3Dm
CONFIG_USB_SERIAL_ARK3116=3Dm
CONFIG_USB_SERIAL_BELKIN=3Dm
CONFIG_USB_SERIAL_CH341=3Dm
CONFIG_USB_SERIAL_WHITEHEAT=3Dm
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=3Dm
CONFIG_USB_SERIAL_CP210X=3Dm
CONFIG_USB_SERIAL_CYPRESS_M8=3Dm
CONFIG_USB_SERIAL_EMPEG=3Dm
CONFIG_USB_SERIAL_FTDI_SIO=3Dm
CONFIG_USB_SERIAL_VISOR=3Dm
CONFIG_USB_SERIAL_IPAQ=3Dm
CONFIG_USB_SERIAL_IR=3Dm
CONFIG_USB_SERIAL_EDGEPORT=3Dm
CONFIG_USB_SERIAL_EDGEPORT_TI=3Dm
CONFIG_USB_SERIAL_F81232=3Dm
CONFIG_USB_SERIAL_GARMIN=3Dm
CONFIG_USB_SERIAL_IPW=3Dm
CONFIG_USB_SERIAL_IUU=3Dm
CONFIG_USB_SERIAL_KEYSPAN_PDA=3Dm
CONFIG_USB_SERIAL_KEYSPAN=3Dm
CONFIG_USB_SERIAL_KLSI=3Dm
CONFIG_USB_SERIAL_KOBIL_SCT=3Dm
CONFIG_USB_SERIAL_MCT_U232=3Dm
CONFIG_USB_SERIAL_METRO=3Dm
CONFIG_USB_SERIAL_MOS7720=3Dm
CONFIG_USB_SERIAL_MOS7715_PARPORT=3Dy
CONFIG_USB_SERIAL_MOS7840=3Dm
CONFIG_USB_SERIAL_MXUPORT=3Dm
CONFIG_USB_SERIAL_NAVMAN=3Dm
CONFIG_USB_SERIAL_PL2303=3Dm
CONFIG_USB_SERIAL_OTI6858=3Dm
CONFIG_USB_SERIAL_QCAUX=3Dm
CONFIG_USB_SERIAL_QUALCOMM=3Dm
CONFIG_USB_SERIAL_SPCP8X5=3Dm
CONFIG_USB_SERIAL_SAFE=3Dm
CONFIG_USB_SERIAL_SAFE_PADDED=3Dy
CONFIG_USB_SERIAL_SIERRAWIRELESS=3Dm
CONFIG_USB_SERIAL_SYMBOL=3Dm
CONFIG_USB_SERIAL_TI=3Dm
CONFIG_USB_SERIAL_CYBERJACK=3Dm
CONFIG_USB_SERIAL_XIRCOM=3Dm
CONFIG_USB_SERIAL_WWAN=3Dm
CONFIG_USB_SERIAL_OPTION=3Dm
CONFIG_USB_SERIAL_OMNINET=3Dm
CONFIG_USB_SERIAL_OPTICON=3Dm
CONFIG_USB_SERIAL_XSENS_MT=3Dm
CONFIG_USB_SERIAL_WISHBONE=3Dm
CONFIG_USB_SERIAL_SSU100=3Dm
CONFIG_USB_SERIAL_QT2=3Dm
CONFIG_USB_SERIAL_DEBUG=3Dm

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=3Dm
CONFIG_USB_EMI26=3Dm
CONFIG_USB_ADUTUX=3Dm
CONFIG_USB_SEVSEG=3Dm
CONFIG_USB_RIO500=3Dm
CONFIG_USB_LEGOTOWER=3Dm
CONFIG_USB_LCD=3Dm
CONFIG_USB_LED=3Dm
CONFIG_USB_CYPRESS_CY7C63=3Dm
CONFIG_USB_CYTHERM=3Dm
CONFIG_USB_IDMOUSE=3Dm
CONFIG_USB_FTDI_ELAN=3Dm
CONFIG_USB_APPLEDISPLAY=3Dm
CONFIG_USB_SISUSBVGA=3Dm
CONFIG_USB_SISUSBVGA_CON=3Dy
CONFIG_USB_LD=3Dm
CONFIG_USB_TRANCEVIBRATOR=3Dm
CONFIG_USB_IOWARRIOR=3Dm
CONFIG_USB_TEST=3Dm
CONFIG_USB_EHSET_TEST_FIXTURE=3Dm
CONFIG_USB_ISIGHTFW=3Dm
CONFIG_USB_YUREX=3Dm
CONFIG_USB_EZUSB_FX2=3Dm
CONFIG_USB_HSIC_USB3503=3Dm
CONFIG_USB_LINK_LAYER_TEST=3Dm
CONFIG_USB_CHAOSKEY=3Dm
CONFIG_UCSI=3Dm
CONFIG_USB_ATM=3Dm
CONFIG_USB_SPEEDTOUCH=3Dm
CONFIG_USB_CXACRU=3Dm
CONFIG_USB_UEAGLEATM=3Dm
CONFIG_USB_XUSBATM=3Dm

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=3Dy
CONFIG_NOP_USB_XCEIV=3Dm
CONFIG_USB_GPIO_VBUS=3Dm
CONFIG_TAHVO_USB=3Dm
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
CONFIG_USB_ISP1301=3Dm
CONFIG_USB_GADGET=3Dm
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=3D2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=3D2
CONFIG_U_SERIAL_CONSOLE=3Dy

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=3Dm
CONFIG_USB_GR_UDC=3Dm
CONFIG_USB_R8A66597=3Dm
# CONFIG_USB_PXA27X is not set
CONFIG_USB_MV_UDC=3Dm
CONFIG_USB_MV_U3D=3Dm
CONFIG_USB_M66592=3Dm
CONFIG_USB_BDC_UDC=3Dm

#
# Platform Support
#
CONFIG_USB_BDC_PCI=3Dm
CONFIG_USB_AMD5536UDC=3Dm
CONFIG_USB_NET2272=3Dm
CONFIG_USB_NET2272_DMA=3Dy
CONFIG_USB_NET2280=3Dm
CONFIG_USB_GOKU=3Dm
CONFIG_USB_EG20T=3Dm
CONFIG_USB_DUMMY_HCD=3Dm
CONFIG_USB_LIBCOMPOSITE=3Dm
CONFIG_USB_F_ACM=3Dm
CONFIG_USB_F_SS_LB=3Dm
CONFIG_USB_U_SERIAL=3Dm
CONFIG_USB_U_ETHER=3Dm
CONFIG_USB_F_SERIAL=3Dm
CONFIG_USB_F_OBEX=3Dm
CONFIG_USB_F_NCM=3Dm
CONFIG_USB_F_ECM=3Dm
CONFIG_USB_F_PHONET=3Dm
CONFIG_USB_F_EEM=3Dm
CONFIG_USB_F_SUBSET=3Dm
CONFIG_USB_F_RNDIS=3Dm
CONFIG_USB_F_MASS_STORAGE=3Dm
CONFIG_USB_F_FS=3Dm
CONFIG_USB_F_UAC1=3Dm
CONFIG_USB_F_UAC2=3Dm
CONFIG_USB_F_UVC=3Dm
CONFIG_USB_F_MIDI=3Dm
CONFIG_USB_F_HID=3Dm
CONFIG_USB_F_PRINTER=3Dm
CONFIG_USB_F_TCM=3Dm
CONFIG_USB_CONFIGFS=3Dm
CONFIG_USB_CONFIGFS_SERIAL=3Dy
CONFIG_USB_CONFIGFS_ACM=3Dy
CONFIG_USB_CONFIGFS_OBEX=3Dy
CONFIG_USB_CONFIGFS_NCM=3Dy
CONFIG_USB_CONFIGFS_ECM=3Dy
CONFIG_USB_CONFIGFS_ECM_SUBSET=3Dy
CONFIG_USB_CONFIGFS_RNDIS=3Dy
CONFIG_USB_CONFIGFS_EEM=3Dy
CONFIG_USB_CONFIGFS_PHONET=3Dy
CONFIG_USB_CONFIGFS_MASS_STORAGE=3Dy
CONFIG_USB_CONFIGFS_F_LB_SS=3Dy
CONFIG_USB_CONFIGFS_F_FS=3Dy
CONFIG_USB_CONFIGFS_F_UAC1=3Dy
CONFIG_USB_CONFIGFS_F_UAC2=3Dy
CONFIG_USB_CONFIGFS_F_MIDI=3Dy
CONFIG_USB_CONFIGFS_F_HID=3Dy
CONFIG_USB_CONFIGFS_F_UVC=3Dy
CONFIG_USB_CONFIGFS_F_PRINTER=3Dy
CONFIG_USB_CONFIGFS_F_TCM=3Dy
CONFIG_USB_ZERO=3Dm
# CONFIG_USB_ZERO_HNPTEST is not set
CONFIG_USB_AUDIO=3Dm
CONFIG_GADGET_UAC1=3Dy
CONFIG_USB_ETH=3Dm
CONFIG_USB_ETH_RNDIS=3Dy
CONFIG_USB_ETH_EEM=3Dy
CONFIG_USB_G_NCM=3Dm
CONFIG_USB_GADGETFS=3Dm
CONFIG_USB_FUNCTIONFS=3Dm
CONFIG_USB_FUNCTIONFS_ETH=3Dy
CONFIG_USB_FUNCTIONFS_RNDIS=3Dy
CONFIG_USB_FUNCTIONFS_GENERIC=3Dy
CONFIG_USB_MASS_STORAGE=3Dm
CONFIG_USB_GADGET_TARGET=3Dm
CONFIG_USB_G_SERIAL=3Dm
CONFIG_USB_MIDI_GADGET=3Dm
CONFIG_USB_G_PRINTER=3Dm
CONFIG_USB_CDC_COMPOSITE=3Dm
CONFIG_USB_G_NOKIA=3Dm
CONFIG_USB_G_ACM_MS=3Dm
CONFIG_USB_G_MULTI=3Dm
CONFIG_USB_G_MULTI_RNDIS=3Dy
CONFIG_USB_G_MULTI_CDC=3Dy
CONFIG_USB_G_HID=3Dm
CONFIG_USB_G_DBGP=3Dm
CONFIG_USB_G_DBGP_PRINTK=3Dy
# CONFIG_USB_G_DBGP_SERIAL is not set
CONFIG_USB_G_WEBCAM=3Dm
CONFIG_USB_LED_TRIG=3Dy
CONFIG_UWB=3Dm
CONFIG_UWB_HWA=3Dm
CONFIG_UWB_WHCI=3Dm
CONFIG_UWB_I1480U=3Dm
CONFIG_MMC=3Dm
# CONFIG_MMC_DEBUG is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=3Dm
CONFIG_MMC_BLOCK_MINORS=3D8
CONFIG_MMC_BLOCK_BOUNCE=3Dy
CONFIG_SDIO_UART=3Dm
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=3Dm
CONFIG_MMC_SDHCI_PCI=3Dm
CONFIG_MMC_RICOH_MMC=3Dy
CONFIG_MMC_SDHCI_ACPI=3Dm
CONFIG_MMC_SDHCI_PLTFM=3Dm
CONFIG_MMC_WBSD=3Dm
CONFIG_MMC_TIFM_SD=3Dm
CONFIG_MMC_GOLDFISH=3Dm
CONFIG_MMC_SPI=3Dm
CONFIG_MMC_SDRICOH_CS=3Dm
CONFIG_MMC_CB710=3Dm
CONFIG_MMC_VIA_SDMMC=3Dm
CONFIG_MMC_VUB300=3Dm
CONFIG_MMC_USHC=3Dm
CONFIG_MMC_USDHI6ROL0=3Dm
CONFIG_MMC_REALTEK_PCI=3Dm
CONFIG_MMC_REALTEK_USB=3Dm
CONFIG_MMC_TOSHIBA_PCI=3Dm
CONFIG_MMC_MTK=3Dm
CONFIG_MEMSTICK=3Dm
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=3Dm
CONFIG_MS_BLOCK=3Dm

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=3Dm
CONFIG_MEMSTICK_JMICRON_38X=3Dm
CONFIG_MEMSTICK_R592=3Dm
CONFIG_MEMSTICK_REALTEK_PCI=3Dm
CONFIG_MEMSTICK_REALTEK_USB=3Dm
CONFIG_NEW_LEDS=3Dy
CONFIG_LEDS_CLASS=3Dy
CONFIG_LEDS_CLASS_FLASH=3Dm

#
# LED drivers
#
CONFIG_LEDS_LM3530=3Dm
CONFIG_LEDS_LM3533=3Dm
CONFIG_LEDS_LM3642=3Dm
CONFIG_LEDS_PCA9532=3Dm
CONFIG_LEDS_PCA9532_GPIO=3Dy
CONFIG_LEDS_GPIO=3Dm
CONFIG_LEDS_LP3944=3Dm
CONFIG_LEDS_LP55XX_COMMON=3Dm
CONFIG_LEDS_LP5521=3Dm
CONFIG_LEDS_LP5523=3Dm
CONFIG_LEDS_LP5562=3Dm
CONFIG_LEDS_LP8501=3Dm
CONFIG_LEDS_LP8860=3Dm
CONFIG_LEDS_CLEVO_MAIL=3Dm
CONFIG_LEDS_PCA955X=3Dm
CONFIG_LEDS_PCA963X=3Dm
CONFIG_LEDS_WM831X_STATUS=3Dm
CONFIG_LEDS_DA9052=3Dm
CONFIG_LEDS_DAC124S085=3Dm
CONFIG_LEDS_PWM=3Dm
CONFIG_LEDS_REGULATOR=3Dm
CONFIG_LEDS_BD2802=3Dm
CONFIG_LEDS_INTEL_SS4200=3Dm
CONFIG_LEDS_LT3593=3Dm
CONFIG_LEDS_DELL_NETBOOKS=3Dm
CONFIG_LEDS_MC13783=3Dm
CONFIG_LEDS_TCA6507=3Dm
CONFIG_LEDS_TLC591XX=3Dm
CONFIG_LEDS_LM355x=3Dm
CONFIG_LEDS_MENF21BMC=3Dm

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THI=
NGM)
#
CONFIG_LEDS_BLINKM=3Dm

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=3Dy
CONFIG_LEDS_TRIGGER_TIMER=3Dm
CONFIG_LEDS_TRIGGER_ONESHOT=3Dm
CONFIG_LEDS_TRIGGER_IDE_DISK=3Dy
CONFIG_LEDS_TRIGGER_MTD=3Dy
CONFIG_LEDS_TRIGGER_HEARTBEAT=3Dm
CONFIG_LEDS_TRIGGER_BACKLIGHT=3Dm
CONFIG_LEDS_TRIGGER_CPU=3Dy
CONFIG_LEDS_TRIGGER_GPIO=3Dm
CONFIG_LEDS_TRIGGER_DEFAULT_ON=3Dm

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=3Dm
CONFIG_LEDS_TRIGGER_CAMERA=3Dm
CONFIG_LEDS_TRIGGER_PANIC=3Dy
CONFIG_ACCESSIBILITY=3Dy
CONFIG_A11Y_BRAILLE_CONSOLE=3Dy
CONFIG_INFINIBAND=3Dm
CONFIG_INFINIBAND_USER_MAD=3Dm
CONFIG_INFINIBAND_USER_ACCESS=3Dm
CONFIG_INFINIBAND_USER_MEM=3Dy
CONFIG_INFINIBAND_ON_DEMAND_PAGING=3Dy
CONFIG_INFINIBAND_ADDR_TRANS=3Dy
CONFIG_INFINIBAND_ADDR_TRANS_CONFIGFS=3Dy
CONFIG_INFINIBAND_MTHCA=3Dm
CONFIG_INFINIBAND_MTHCA_DEBUG=3Dy
CONFIG_INFINIBAND_QIB=3Dm
CONFIG_INFINIBAND_QIB_DCA=3Dy
CONFIG_INFINIBAND_CXGB3=3Dm
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=3Dm
CONFIG_INFINIBAND_I40IW=3Dm
CONFIG_MLX4_INFINIBAND=3Dm
CONFIG_MLX5_INFINIBAND=3Dm
CONFIG_INFINIBAND_NES=3Dm
# CONFIG_INFINIBAND_NES_DEBUG is not set
CONFIG_INFINIBAND_OCRDMA=3Dm
CONFIG_INFINIBAND_USNIC=3Dm
CONFIG_INFINIBAND_IPOIB=3Dm
# CONFIG_INFINIBAND_IPOIB_CM is not set
CONFIG_INFINIBAND_IPOIB_DEBUG=3Dy
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=3Dm
CONFIG_INFINIBAND_SRPT=3Dm
CONFIG_INFINIBAND_ISER=3Dm
CONFIG_INFINIBAND_ISERT=3Dm
CONFIG_INFINIBAND_RDMAVT=3Dm
CONFIG_INFINIBAND_HFI1=3Dm
# CONFIG_HFI1_DEBUG_SDMA_ORDER is not set
CONFIG_HFI1_VERBS_31BIT_PSN=3Dy
# CONFIG_SDMA_VERBOSITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=3Dy
CONFIG_EDAC_SUPPORT=3Dy
CONFIG_EDAC=3Dy
CONFIG_EDAC_LEGACY_SYSFS=3Dy
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=3Dm
CONFIG_EDAC_MM_EDAC=3Dm
CONFIG_EDAC_AMD64=3Dm
CONFIG_EDAC_AMD64_ERROR_INJECTION=3Dy
CONFIG_EDAC_E752X=3Dm
CONFIG_EDAC_I82975X=3Dm
CONFIG_EDAC_I3000=3Dm
CONFIG_EDAC_I3200=3Dm
CONFIG_EDAC_IE31200=3Dm
CONFIG_EDAC_X38=3Dm
CONFIG_EDAC_I5400=3Dm
CONFIG_EDAC_I7CORE=3Dm
CONFIG_EDAC_I5000=3Dm
CONFIG_EDAC_I5100=3Dm
CONFIG_EDAC_I7300=3Dm
CONFIG_EDAC_SBRIDGE=3Dm
CONFIG_RTC_LIB=3Dy
CONFIG_RTC_CLASS=3Dy
CONFIG_RTC_HCTOSYS=3Dy
CONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"
CONFIG_RTC_SYSTOHC=3Dy
CONFIG_RTC_SYSTOHC_DEVICE=3D"rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=3Dy
CONFIG_RTC_INTF_PROC=3Dy
CONFIG_RTC_INTF_DEV=3Dy
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=3Dm

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=3Dm
CONFIG_RTC_DRV_ABB5ZES3=3Dm
CONFIG_RTC_DRV_ABX80X=3Dm
CONFIG_RTC_DRV_DS1307=3Dm
CONFIG_RTC_DRV_DS1307_HWMON=3Dy
CONFIG_RTC_DRV_DS1374=3Dm
CONFIG_RTC_DRV_DS1374_WDT=3Dy
CONFIG_RTC_DRV_DS1672=3Dm
CONFIG_RTC_DRV_MAX6900=3Dm
CONFIG_RTC_DRV_MAX8907=3Dm
CONFIG_RTC_DRV_RS5C372=3Dm
CONFIG_RTC_DRV_ISL1208=3Dm
CONFIG_RTC_DRV_ISL12022=3Dm
CONFIG_RTC_DRV_ISL12057=3Dm
CONFIG_RTC_DRV_X1205=3Dm
CONFIG_RTC_DRV_PCF8523=3Dm
CONFIG_RTC_DRV_PCF85063=3Dm
CONFIG_RTC_DRV_PCF8563=3Dm
CONFIG_RTC_DRV_PCF8583=3Dm
CONFIG_RTC_DRV_M41T80=3Dm
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=3Dm
CONFIG_RTC_DRV_S35390A=3Dm
CONFIG_RTC_DRV_FM3130=3Dm
CONFIG_RTC_DRV_RX8010=3Dm
CONFIG_RTC_DRV_RX8581=3Dm
CONFIG_RTC_DRV_RX8025=3Dm
CONFIG_RTC_DRV_EM3027=3Dm
CONFIG_RTC_DRV_RV8803=3Dm

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=3Dm
CONFIG_RTC_DRV_M41T94=3Dm
CONFIG_RTC_DRV_DS1302=3Dm
CONFIG_RTC_DRV_DS1305=3Dm
CONFIG_RTC_DRV_DS1343=3Dm
CONFIG_RTC_DRV_DS1347=3Dm
CONFIG_RTC_DRV_DS1390=3Dm
CONFIG_RTC_DRV_R9701=3Dm
CONFIG_RTC_DRV_RX4581=3Dm
CONFIG_RTC_DRV_RX6110=3Dm
CONFIG_RTC_DRV_RS5C348=3Dm
CONFIG_RTC_DRV_MAX6902=3Dm
CONFIG_RTC_DRV_PCF2123=3Dm
CONFIG_RTC_DRV_MCP795=3Dm
CONFIG_RTC_I2C_AND_SPI=3Dm

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=3Dm
CONFIG_RTC_DRV_PCF2127=3Dm
CONFIG_RTC_DRV_RV3029C2=3Dm
CONFIG_RTC_DRV_RV3029_HWMON=3Dy

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=3Dy
CONFIG_RTC_DRV_DS1286=3Dm
CONFIG_RTC_DRV_DS1511=3Dm
CONFIG_RTC_DRV_DS1553=3Dm
CONFIG_RTC_DRV_DS1685_FAMILY=3Dm
CONFIG_RTC_DRV_DS1685=3Dy
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
CONFIG_RTC_DS1685_SYSFS_REGS=3Dy
CONFIG_RTC_DRV_DS1742=3Dm
CONFIG_RTC_DRV_DS2404=3Dm
CONFIG_RTC_DRV_DA9052=3Dm
CONFIG_RTC_DRV_DA9063=3Dm
CONFIG_RTC_DRV_STK17TA8=3Dm
CONFIG_RTC_DRV_M48T86=3Dm
CONFIG_RTC_DRV_M48T35=3Dm
CONFIG_RTC_DRV_M48T59=3Dm
CONFIG_RTC_DRV_MSM6242=3Dm
CONFIG_RTC_DRV_BQ4802=3Dm
CONFIG_RTC_DRV_RP5C01=3Dm
CONFIG_RTC_DRV_V3020=3Dm
CONFIG_RTC_DRV_WM831X=3Dm
CONFIG_RTC_DRV_PCF50633=3Dm

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=3Dm
CONFIG_RTC_DRV_MC13XXX=3Dm
CONFIG_RTC_DRV_MT6397=3Dm

#
# HID Sensor RTC drivers
#
CONFIG_RTC_DRV_HID_SENSOR_TIME=3Dm
CONFIG_DMADEVICES=3Dy
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=3Dy
CONFIG_DMA_VIRTUAL_CHANNELS=3Dy
CONFIG_DMA_ACPI=3Dy
CONFIG_INTEL_IDMA64=3Dm
CONFIG_INTEL_IOATDMA=3Dm
CONFIG_INTEL_MIC_X100_DMA=3Dm
CONFIG_QCOM_HIDMA_MGMT=3Dm
CONFIG_QCOM_HIDMA=3Dm
CONFIG_DW_DMAC_CORE=3Dm
CONFIG_DW_DMAC=3Dm
CONFIG_DW_DMAC_PCI=3Dm
CONFIG_HSU_DMA=3Dy

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=3Dy
# CONFIG_DMATEST is not set
CONFIG_DMA_ENGINE_RAID=3Dy

#
# DMABUF options
#
CONFIG_SYNC_FILE=3Dy
CONFIG_DCA=3Dm
CONFIG_AUXDISPLAY=3Dy
CONFIG_KS0108=3Dm
CONFIG_KS0108_PORT=3D0x378
CONFIG_KS0108_DELAY=3D2
CONFIG_CFAG12864B=3Dm
CONFIG_CFAG12864B_RATE=3D20
CONFIG_UIO=3Dm
CONFIG_UIO_CIF=3Dm
CONFIG_UIO_PDRV_GENIRQ=3Dm
CONFIG_UIO_DMEM_GENIRQ=3Dm
CONFIG_UIO_AEC=3Dm
CONFIG_UIO_SERCOS3=3Dm
CONFIG_UIO_PCI_GENERIC=3Dm
CONFIG_UIO_NETX=3Dm
CONFIG_UIO_PRUSS=3Dm
CONFIG_UIO_MF624=3Dm
CONFIG_VFIO_IOMMU_TYPE1=3Dm
CONFIG_VFIO_VIRQFD=3Dm
CONFIG_VFIO=3Dm
CONFIG_VFIO_NOIOMMU=3Dy
CONFIG_VFIO_PCI=3Dm
CONFIG_VFIO_PCI_VGA=3Dy
CONFIG_VFIO_PCI_MMAP=3Dy
CONFIG_VFIO_PCI_INTX=3Dy
CONFIG_VFIO_PCI_IGD=3Dy
CONFIG_IRQ_BYPASS_MANAGER=3Dm
CONFIG_VIRT_DRIVERS=3Dy
CONFIG_VIRTIO=3Dm

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=3Dm
CONFIG_VIRTIO_PCI_LEGACY=3Dy
CONFIG_VIRTIO_BALLOON=3Dm
CONFIG_VIRTIO_INPUT=3Dm
CONFIG_VIRTIO_MMIO=3Dm
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=3Dy

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=3Dm
CONFIG_HYPERV_UTILS=3Dm
CONFIG_HYPERV_BALLOON=3Dm

#
# Xen driver support
#
CONFIG_XEN_BALLOON=3Dy
CONFIG_XEN_SELFBALLOONING=3Dy
CONFIG_XEN_BALLOON_MEMORY_HOTPLUG=3Dy
CONFIG_XEN_BALLOON_MEMORY_HOTPLUG_LIMIT=3D512
CONFIG_XEN_SCRUB_PAGES=3Dy
CONFIG_XEN_DEV_EVTCHN=3Dm
CONFIG_XEN_BACKEND=3Dy
CONFIG_XENFS=3Dm
CONFIG_XEN_COMPAT_XENFS=3Dy
CONFIG_XEN_SYS_HYPERVISOR=3Dy
CONFIG_XEN_XENBUS_FRONTEND=3Dy
CONFIG_XEN_GNTDEV=3Dm
CONFIG_XEN_GRANT_DEV_ALLOC=3Dm
CONFIG_SWIOTLB_XEN=3Dy
CONFIG_XEN_TMEM=3Dm
CONFIG_XEN_PCIDEV_BACKEND=3Dm
CONFIG_XEN_SCSI_BACKEND=3Dm
CONFIG_XEN_PRIVCMD=3Dm
CONFIG_XEN_ACPI_PROCESSOR=3Dm
CONFIG_XEN_MCE_LOG=3Dy
CONFIG_XEN_HAVE_PVMMU=3Dy
CONFIG_XEN_EFI=3Dy
CONFIG_XEN_AUTO_XLATE=3Dy
CONFIG_XEN_ACPI=3Dy
CONFIG_XEN_SYMS=3Dy
CONFIG_XEN_HAVE_VPMU=3Dy
CONFIG_STAGING=3Dy
CONFIG_SLICOSS=3Dm
CONFIG_PRISM2_USB=3Dm
CONFIG_COMEDI=3Dm
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=3D2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=3D20480
CONFIG_COMEDI_MISC_DRIVERS=3Dy
CONFIG_COMEDI_BOND=3Dm
CONFIG_COMEDI_TEST=3Dm
CONFIG_COMEDI_PARPORT=3Dm
CONFIG_COMEDI_SERIAL2002=3Dm
CONFIG_COMEDI_ISA_DRIVERS=3Dy
CONFIG_COMEDI_PCL711=3Dm
CONFIG_COMEDI_PCL724=3Dm
CONFIG_COMEDI_PCL726=3Dm
CONFIG_COMEDI_PCL730=3Dm
CONFIG_COMEDI_PCL812=3Dm
CONFIG_COMEDI_PCL816=3Dm
CONFIG_COMEDI_PCL818=3Dm
CONFIG_COMEDI_PCM3724=3Dm
CONFIG_COMEDI_AMPLC_DIO200_ISA=3Dm
CONFIG_COMEDI_AMPLC_PC236_ISA=3Dm
CONFIG_COMEDI_AMPLC_PC263_ISA=3Dm
CONFIG_COMEDI_RTI800=3Dm
CONFIG_COMEDI_RTI802=3Dm
CONFIG_COMEDI_DAC02=3Dm
CONFIG_COMEDI_DAS16M1=3Dm
CONFIG_COMEDI_DAS08_ISA=3Dm
CONFIG_COMEDI_DAS16=3Dm
CONFIG_COMEDI_DAS800=3Dm
CONFIG_COMEDI_DAS1800=3Dm
CONFIG_COMEDI_DAS6402=3Dm
CONFIG_COMEDI_DT2801=3Dm
CONFIG_COMEDI_DT2811=3Dm
CONFIG_COMEDI_DT2814=3Dm
CONFIG_COMEDI_DT2815=3Dm
CONFIG_COMEDI_DT2817=3Dm
CONFIG_COMEDI_DT282X=3Dm
CONFIG_COMEDI_DMM32AT=3Dm
CONFIG_COMEDI_FL512=3Dm
CONFIG_COMEDI_AIO_AIO12_8=3Dm
CONFIG_COMEDI_AIO_IIRO_16=3Dm
CONFIG_COMEDI_II_PCI20KC=3Dm
CONFIG_COMEDI_C6XDIGIO=3Dm
CONFIG_COMEDI_MPC624=3Dm
CONFIG_COMEDI_ADQ12B=3Dm
CONFIG_COMEDI_NI_AT_A2150=3Dm
CONFIG_COMEDI_NI_AT_AO=3Dm
CONFIG_COMEDI_NI_ATMIO=3Dm
CONFIG_COMEDI_NI_ATMIO16D=3Dm
CONFIG_COMEDI_NI_LABPC_ISA=3Dm
CONFIG_COMEDI_PCMAD=3Dm
CONFIG_COMEDI_PCMDA12=3Dm
CONFIG_COMEDI_PCMMIO=3Dm
CONFIG_COMEDI_PCMUIO=3Dm
CONFIG_COMEDI_MULTIQ3=3Dm
CONFIG_COMEDI_S526=3Dm
CONFIG_COMEDI_PCI_DRIVERS=3Dm
CONFIG_COMEDI_8255_PCI=3Dm
CONFIG_COMEDI_ADDI_WATCHDOG=3Dm
CONFIG_COMEDI_ADDI_APCI_1032=3Dm
CONFIG_COMEDI_ADDI_APCI_1500=3Dm
CONFIG_COMEDI_ADDI_APCI_1516=3Dm
CONFIG_COMEDI_ADDI_APCI_1564=3Dm
CONFIG_COMEDI_ADDI_APCI_16XX=3Dm
CONFIG_COMEDI_ADDI_APCI_2032=3Dm
CONFIG_COMEDI_ADDI_APCI_2200=3Dm
CONFIG_COMEDI_ADDI_APCI_3120=3Dm
CONFIG_COMEDI_ADDI_APCI_3501=3Dm
CONFIG_COMEDI_ADDI_APCI_3XXX=3Dm
CONFIG_COMEDI_ADL_PCI6208=3Dm
CONFIG_COMEDI_ADL_PCI7X3X=3Dm
CONFIG_COMEDI_ADL_PCI8164=3Dm
CONFIG_COMEDI_ADL_PCI9111=3Dm
CONFIG_COMEDI_ADL_PCI9118=3Dm
CONFIG_COMEDI_ADV_PCI1710=3Dm
CONFIG_COMEDI_ADV_PCI1720=3Dm
CONFIG_COMEDI_ADV_PCI1723=3Dm
CONFIG_COMEDI_ADV_PCI1724=3Dm
CONFIG_COMEDI_ADV_PCI1760=3Dm
CONFIG_COMEDI_ADV_PCI_DIO=3Dm
CONFIG_COMEDI_AMPLC_DIO200_PCI=3Dm
CONFIG_COMEDI_AMPLC_PC236_PCI=3Dm
CONFIG_COMEDI_AMPLC_PC263_PCI=3Dm
CONFIG_COMEDI_AMPLC_PCI224=3Dm
CONFIG_COMEDI_AMPLC_PCI230=3Dm
CONFIG_COMEDI_CONTEC_PCI_DIO=3Dm
CONFIG_COMEDI_DAS08_PCI=3Dm
CONFIG_COMEDI_DT3000=3Dm
CONFIG_COMEDI_DYNA_PCI10XX=3Dm
CONFIG_COMEDI_GSC_HPDI=3Dm
CONFIG_COMEDI_MF6X4=3Dm
CONFIG_COMEDI_ICP_MULTI=3Dm
CONFIG_COMEDI_DAQBOARD2000=3Dm
CONFIG_COMEDI_JR3_PCI=3Dm
CONFIG_COMEDI_KE_COUNTER=3Dm
CONFIG_COMEDI_CB_PCIDAS64=3Dm
CONFIG_COMEDI_CB_PCIDAS=3Dm
CONFIG_COMEDI_CB_PCIDDA=3Dm
CONFIG_COMEDI_CB_PCIMDAS=3Dm
CONFIG_COMEDI_CB_PCIMDDA=3Dm
CONFIG_COMEDI_ME4000=3Dm
CONFIG_COMEDI_ME_DAQ=3Dm
CONFIG_COMEDI_NI_6527=3Dm
CONFIG_COMEDI_NI_65XX=3Dm
CONFIG_COMEDI_NI_660X=3Dm
CONFIG_COMEDI_NI_670X=3Dm
CONFIG_COMEDI_NI_LABPC_PCI=3Dm
CONFIG_COMEDI_NI_PCIDIO=3Dm
CONFIG_COMEDI_NI_PCIMIO=3Dm
CONFIG_COMEDI_RTD520=3Dm
CONFIG_COMEDI_S626=3Dm
CONFIG_COMEDI_MITE=3Dm
CONFIG_COMEDI_NI_TIOCMD=3Dm
CONFIG_COMEDI_PCMCIA_DRIVERS=3Dm
CONFIG_COMEDI_CB_DAS16_CS=3Dm
CONFIG_COMEDI_DAS08_CS=3Dm
CONFIG_COMEDI_NI_DAQ_700_CS=3Dm
CONFIG_COMEDI_NI_DAQ_DIO24_CS=3Dm
CONFIG_COMEDI_NI_LABPC_CS=3Dm
CONFIG_COMEDI_NI_MIO_CS=3Dm
CONFIG_COMEDI_QUATECH_DAQP_CS=3Dm
CONFIG_COMEDI_USB_DRIVERS=3Dm
CONFIG_COMEDI_DT9812=3Dm
CONFIG_COMEDI_NI_USB6501=3Dm
CONFIG_COMEDI_USBDUX=3Dm
CONFIG_COMEDI_USBDUXFAST=3Dm
CONFIG_COMEDI_USBDUXSIGMA=3Dm
CONFIG_COMEDI_VMK80XX=3Dm
CONFIG_COMEDI_8254=3Dm
CONFIG_COMEDI_8255=3Dm
CONFIG_COMEDI_8255_SA=3Dm
CONFIG_COMEDI_KCOMEDILIB=3Dm
CONFIG_COMEDI_AMPLC_DIO200=3Dm
CONFIG_COMEDI_AMPLC_PC236=3Dm
CONFIG_COMEDI_DAS08=3Dm
CONFIG_COMEDI_ISADMA=3Dm
CONFIG_COMEDI_NI_LABPC=3Dm
CONFIG_COMEDI_NI_LABPC_ISADMA=3Dm
CONFIG_COMEDI_NI_TIO=3Dm
CONFIG_RTL8192U=3Dm
CONFIG_RTLLIB=3Dm
CONFIG_RTLLIB_CRYPTO_CCMP=3Dm
CONFIG_RTLLIB_CRYPTO_TKIP=3Dm
CONFIG_RTLLIB_CRYPTO_WEP=3Dm
CONFIG_RTL8192E=3Dm
CONFIG_R8712U=3Dm
CONFIG_R8188EU=3Dm
CONFIG_88EU_AP_MODE=3Dy
CONFIG_R8723AU=3Dm
CONFIG_8723AU_AP_MODE=3Dy
CONFIG_8723AU_BT_COEXIST=3Dy
CONFIG_RTS5208=3Dm
CONFIG_VT6655=3Dm
CONFIG_VT6656=3Dm

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=3Dm
CONFIG_ADIS16203=3Dm
CONFIG_ADIS16209=3Dm
CONFIG_ADIS16240=3Dm
CONFIG_LIS3L02DQ=3Dm
CONFIG_SCA3000=3Dm

#
# Analog to digital converters
#
CONFIG_AD7606=3Dm
CONFIG_AD7606_IFACE_PARALLEL=3Dm
CONFIG_AD7606_IFACE_SPI=3Dm
CONFIG_AD7780=3Dm
CONFIG_AD7816=3Dm
CONFIG_AD7192=3Dm
CONFIG_AD7280=3Dm

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=3Dm
CONFIG_ADT7316_SPI=3Dm
CONFIG_ADT7316_I2C=3Dm

#
# Capacitance to digital converters
#
CONFIG_AD7150=3Dm
CONFIG_AD7152=3Dm
CONFIG_AD7746=3Dm

#
# Direct Digital Synthesis
#
CONFIG_AD9832=3Dm
CONFIG_AD9834=3Dm

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=3Dm

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=3Dm

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=3Dm
CONFIG_SENSORS_ISL29028=3Dm
CONFIG_TSL2583=3Dm
CONFIG_TSL2x7x=3Dm

#
# Active energy metering IC
#
CONFIG_ADE7753=3Dm
CONFIG_ADE7754=3Dm
CONFIG_ADE7758=3Dm
CONFIG_ADE7759=3Dm
CONFIG_ADE7854=3Dm
CONFIG_ADE7854_I2C=3Dm
CONFIG_ADE7854_SPI=3Dm

#
# Resolver to digital converters
#
CONFIG_AD2S90=3Dm
CONFIG_AD2S1200=3Dm
CONFIG_AD2S1210=3Dm

#
# Triggers - standalone
#
CONFIG_FB_SM750=3Dm
CONFIG_FB_XGI=3Dm

#
# Speakup console speech
#
CONFIG_SPEAKUP=3Dm
CONFIG_SPEAKUP_SYNTH_ACNTSA=3Dm
CONFIG_SPEAKUP_SYNTH_APOLLO=3Dm
CONFIG_SPEAKUP_SYNTH_AUDPTR=3Dm
CONFIG_SPEAKUP_SYNTH_BNS=3Dm
CONFIG_SPEAKUP_SYNTH_DECTLK=3Dm
CONFIG_SPEAKUP_SYNTH_DECEXT=3Dm
CONFIG_SPEAKUP_SYNTH_LTLK=3Dm
CONFIG_SPEAKUP_SYNTH_SOFT=3Dm
CONFIG_SPEAKUP_SYNTH_SPKOUT=3Dm
CONFIG_SPEAKUP_SYNTH_TXPRT=3Dm
CONFIG_SPEAKUP_SYNTH_DUMMY=3Dm
CONFIG_STAGING_MEDIA=3Dy
CONFIG_I2C_BCM2048=3Dm
CONFIG_DVB_CXD2099=3Dm
CONFIG_DVB_MN88472=3Dm
CONFIG_LIRC_STAGING=3Dy
CONFIG_LIRC_BT829=3Dm
CONFIG_LIRC_IMON=3Dm
CONFIG_LIRC_PARALLEL=3Dm
CONFIG_LIRC_SASEM=3Dm
CONFIG_LIRC_SERIAL=3Dm
CONFIG_LIRC_SERIAL_TRANSMITTER=3Dy
CONFIG_LIRC_SIR=3Dm
CONFIG_LIRC_ZILOG=3Dm

#
# Android
#
CONFIG_LTE_GDM724X=3Dm
CONFIG_FIREWIRE_SERIAL=3Dm
CONFIG_FWTTY_MAX_TOTAL_PORTS=3D64
CONFIG_FWTTY_MAX_CARD_PORTS=3D32
CONFIG_GOLDFISH_AUDIO=3Dm
CONFIG_MTD_GOLDFISH_NAND=3Dm
CONFIG_MTD_SPINAND_MT29F=3Dm
CONFIG_MTD_SPINAND_ONDIEECC=3Dy
CONFIG_LNET=3Dm
CONFIG_LNET_MAX_PAYLOAD=3D1048576
CONFIG_LNET_SELFTEST=3Dm
CONFIG_LNET_XPRT_IB=3Dm
CONFIG_LUSTRE_FS=3Dm
CONFIG_LUSTRE_OBD_MAX_IOCTL_BUFFER=3D8192
# CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is not set
CONFIG_LUSTRE_LLITE_LLOOP=3Dm
CONFIG_DGNC=3Dm
CONFIG_GS_FPGABOOT=3Dm
CONFIG_CRYPTO_SKEIN=3Dy
CONFIG_UNISYSSPAR=3Dy
CONFIG_UNISYS_VISORBUS=3Dm
CONFIG_UNISYS_VISORNIC=3Dm
CONFIG_UNISYS_VISORINPUT=3Dm
CONFIG_UNISYS_VISORHBA=3Dm
CONFIG_FB_TFT=3Dm
CONFIG_FB_TFT_AGM1264K_FL=3Dm
CONFIG_FB_TFT_BD663474=3Dm
CONFIG_FB_TFT_HX8340BN=3Dm
CONFIG_FB_TFT_HX8347D=3Dm
CONFIG_FB_TFT_HX8353D=3Dm
CONFIG_FB_TFT_HX8357D=3Dm
CONFIG_FB_TFT_ILI9163=3Dm
CONFIG_FB_TFT_ILI9320=3Dm
CONFIG_FB_TFT_ILI9325=3Dm
CONFIG_FB_TFT_ILI9340=3Dm
CONFIG_FB_TFT_ILI9341=3Dm
CONFIG_FB_TFT_ILI9481=3Dm
CONFIG_FB_TFT_ILI9486=3Dm
CONFIG_FB_TFT_PCD8544=3Dm
CONFIG_FB_TFT_RA8875=3Dm
CONFIG_FB_TFT_S6D02A1=3Dm
CONFIG_FB_TFT_S6D1121=3Dm
CONFIG_FB_TFT_SSD1289=3Dm
CONFIG_FB_TFT_SSD1305=3Dm
CONFIG_FB_TFT_SSD1306=3Dm
CONFIG_FB_TFT_SSD1325=3Dm
CONFIG_FB_TFT_SSD1331=3Dm
CONFIG_FB_TFT_SSD1351=3Dm
CONFIG_FB_TFT_ST7735R=3Dm
CONFIG_FB_TFT_ST7789V=3Dm
CONFIG_FB_TFT_TINYLCD=3Dm
CONFIG_FB_TFT_TLS8204=3Dm
CONFIG_FB_TFT_UC1611=3Dm
CONFIG_FB_TFT_UC1701=3Dm
CONFIG_FB_TFT_UPD161704=3Dm
CONFIG_FB_TFT_WATTEROTT=3Dm
CONFIG_FB_FLEX=3Dm
CONFIG_FB_TFT_FBTFT_DEVICE=3Dm
CONFIG_WILC1000=3Dm
CONFIG_WILC1000_SDIO=3Dm
# CONFIG_WILC1000_SPI is not set
CONFIG_WILC1000_HW_OOB_INTR=3Dy
CONFIG_MOST=3Dm
CONFIG_MOSTCORE=3Dm
CONFIG_AIM_CDEV=3Dm
CONFIG_AIM_NETWORK=3Dm
CONFIG_AIM_SOUND=3Dm
CONFIG_AIM_V4L2=3Dm
CONFIG_HDM_DIM2=3Dm
CONFIG_HDM_I2C=3Dm
CONFIG_HDM_USB=3Dm

#
# Old ISDN4Linux (deprecated)
#
CONFIG_X86_PLATFORM_DEVICES=3Dy
CONFIG_ACER_WMI=3Dm
CONFIG_ACERHDF=3Dm
CONFIG_ALIENWARE_WMI=3Dm
CONFIG_ASUS_LAPTOP=3Dm
CONFIG_DELL_SMBIOS=3Dm
CONFIG_DELL_LAPTOP=3Dm
CONFIG_DELL_WMI=3Dm
CONFIG_DELL_WMI_AIO=3Dm
CONFIG_DELL_SMO8800=3Dm
CONFIG_DELL_RBTN=3Dm
CONFIG_FUJITSU_LAPTOP=3Dm
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
CONFIG_FUJITSU_TABLET=3Dm
CONFIG_AMILO_RFKILL=3Dm
CONFIG_HP_ACCEL=3Dm
CONFIG_HP_WIRELESS=3Dm
CONFIG_HP_WMI=3Dm
CONFIG_MSI_LAPTOP=3Dm
CONFIG_PANASONIC_LAPTOP=3Dm
CONFIG_COMPAL_LAPTOP=3Dm
CONFIG_SONY_LAPTOP=3Dm
CONFIG_SONYPI_COMPAT=3Dy
CONFIG_IDEAPAD_LAPTOP=3Dm
CONFIG_THINKPAD_ACPI=3Dm
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=3Dy
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=3Dy
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=3Dy
CONFIG_SENSORS_HDAPS=3Dm
CONFIG_INTEL_MENLOW=3Dm
CONFIG_EEEPC_LAPTOP=3Dm
CONFIG_ASUS_WMI=3Dm
CONFIG_ASUS_NB_WMI=3Dm
CONFIG_EEEPC_WMI=3Dm
CONFIG_ASUS_WIRELESS=3Dm
CONFIG_ACPI_WMI=3Dm
CONFIG_MSI_WMI=3Dm
CONFIG_TOPSTAR_LAPTOP=3Dm
CONFIG_ACPI_TOSHIBA=3Dm
CONFIG_TOSHIBA_BT_RFKILL=3Dm
CONFIG_TOSHIBA_HAPS=3Dm
CONFIG_TOSHIBA_WMI=3Dm
CONFIG_ACPI_CMPC=3Dm
CONFIG_INTEL_HID_EVENT=3Dm
CONFIG_INTEL_IPS=3Dm
CONFIG_INTEL_PMC_CORE=3Dy
CONFIG_IBM_RTL=3Dm
CONFIG_SAMSUNG_LAPTOP=3Dm
CONFIG_MXM_WMI=3Dm
CONFIG_INTEL_OAKTRAIL=3Dm
CONFIG_SAMSUNG_Q10=3Dm
CONFIG_APPLE_GMUX=3Dm
CONFIG_INTEL_RST=3Dm
CONFIG_INTEL_SMARTCONNECT=3Dm
CONFIG_PVPANIC=3Dm
CONFIG_INTEL_PMC_IPC=3Dm
CONFIG_SURFACE_PRO3_BUTTON=3Dm
CONFIG_INTEL_PUNIT_IPC=3Dm
CONFIG_INTEL_TELEMETRY=3Dm
CONFIG_GOLDFISH_BUS=3Dy
CONFIG_GOLDFISH_PIPE=3Dm
CONFIG_CHROME_PLATFORMS=3Dy
CONFIG_CHROMEOS_LAPTOP=3Dm
CONFIG_CHROMEOS_PSTORE=3Dm
CONFIG_CROS_EC_CHARDEV=3Dm
CONFIG_CROS_EC_LPC=3Dm
CONFIG_CROS_EC_PROTO=3Dy
CONFIG_CROS_KBD_LED_BACKLIGHT=3Dm
CONFIG_CLKDEV_LOOKUP=3Dy
CONFIG_HAVE_CLK_PREPARE=3Dy
CONFIG_COMMON_CLK=3Dy

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=3Dm
CONFIG_COMMON_CLK_SI5351=3Dm
CONFIG_COMMON_CLK_CDCE706=3Dm
CONFIG_COMMON_CLK_CS2000_CP=3Dm
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PWM=3Dm
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_COMMON_CLK_OXNAS is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=3Dy
CONFIG_I8253_LOCK=3Dy
CONFIG_CLKBLD_I8253=3Dy
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=3Dy
CONFIG_PCC=3Dy
CONFIG_ALTERA_MBOX=3Dm
CONFIG_IOMMU_API=3Dy
CONFIG_IOMMU_SUPPORT=3Dy

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=3Dy
CONFIG_AMD_IOMMU=3Dy
CONFIG_AMD_IOMMU_V2=3Dm
CONFIG_DMAR_TABLE=3Dy
CONFIG_INTEL_IOMMU=3Dy
CONFIG_INTEL_IOMMU_SVM=3Dy
CONFIG_INTEL_IOMMU_DEFAULT_ON=3Dy
CONFIG_INTEL_IOMMU_FLOPPY_WA=3Dy
CONFIG_IRQ_REMAP=3Dy

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=3Dm
CONFIG_STE_MODEM_RPROC=3Dm

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=3Dy
CONFIG_PM_DEVFREQ=3Dy

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=3Dy
CONFIG_DEVFREQ_GOV_PERFORMANCE=3Dy
CONFIG_DEVFREQ_GOV_POWERSAVE=3Dy
CONFIG_DEVFREQ_GOV_USERSPACE=3Dy
CONFIG_DEVFREQ_GOV_PASSIVE=3Dm

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=3Dy
CONFIG_EXTCON=3Dy

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=3Dm
CONFIG_EXTCON_ARIZONA=3Dm
CONFIG_EXTCON_AXP288=3Dm
CONFIG_EXTCON_GPIO=3Dm
CONFIG_EXTCON_MAX3355=3Dm
CONFIG_EXTCON_MAX77693=3Dm
CONFIG_EXTCON_RT8973A=3Dm
CONFIG_EXTCON_SM5502=3Dm
CONFIG_EXTCON_USB_GPIO=3Dm
CONFIG_MEMORY=3Dy
CONFIG_IIO=3Dm
CONFIG_IIO_BUFFER=3Dy
CONFIG_IIO_BUFFER_CB=3Dm
CONFIG_IIO_KFIFO_BUF=3Dm
CONFIG_IIO_TRIGGERED_BUFFER=3Dm
CONFIG_IIO_CONFIGFS=3Dm
CONFIG_IIO_TRIGGER=3Dy
CONFIG_IIO_CONSUMERS_PER_TRIGGER=3D2
CONFIG_IIO_SW_TRIGGER=3Dm
CONFIG_IIO_TRIGGERED_EVENT=3Dm

#
# Accelerometers
#
CONFIG_BMA180=3Dm
CONFIG_BMC150_ACCEL=3Dm
CONFIG_BMC150_ACCEL_I2C=3Dm
CONFIG_BMC150_ACCEL_SPI=3Dm
CONFIG_HID_SENSOR_ACCEL_3D=3Dm
CONFIG_IIO_ST_ACCEL_3AXIS=3Dm
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=3Dm
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=3Dm
CONFIG_KXSD9=3Dm
CONFIG_KXCJK1013=3Dm
CONFIG_MMA7455=3Dm
CONFIG_MMA7455_I2C=3Dm
CONFIG_MMA7455_SPI=3Dm
CONFIG_MMA8452=3Dm
CONFIG_MMA9551_CORE=3Dm
CONFIG_MMA9551=3Dm
CONFIG_MMA9553=3Dm
CONFIG_MXC4005=3Dm
CONFIG_MXC6255=3Dm
CONFIG_STK8312=3Dm
CONFIG_STK8BA50=3Dm

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=3Dm
CONFIG_AD7266=3Dm
CONFIG_AD7291=3Dm
CONFIG_AD7298=3Dm
CONFIG_AD7476=3Dm
CONFIG_AD7791=3Dm
CONFIG_AD7793=3Dm
CONFIG_AD7887=3Dm
CONFIG_AD7923=3Dm
CONFIG_AD799X=3Dm
CONFIG_AXP288_ADC=3Dm
CONFIG_CC10001_ADC=3Dm
CONFIG_DA9150_GPADC=3Dm
CONFIG_HI8435=3Dm
CONFIG_INA2XX_ADC=3Dm
CONFIG_MAX1027=3Dm
CONFIG_MAX1363=3Dm
CONFIG_MCP320X=3Dm
CONFIG_MCP3422=3Dm
CONFIG_MEN_Z188_ADC=3Dm
CONFIG_NAU7802=3Dm
CONFIG_QCOM_SPMI_IADC=3Dm
CONFIG_QCOM_SPMI_VADC=3Dm
CONFIG_TI_ADC081C=3Dm
CONFIG_TI_ADC0832=3Dm
CONFIG_TI_ADC128S052=3Dm
CONFIG_TI_ADS1015=3Dm
CONFIG_TI_AM335X_ADC=3Dm
CONFIG_VIPERBOARD_ADC=3Dm

#
# Amplifiers
#
CONFIG_AD8366=3Dm

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=3Dm
CONFIG_IAQCORE=3Dm
CONFIG_VZ89X=3Dm

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=3Dm
CONFIG_HID_SENSOR_IIO_TRIGGER=3Dm
CONFIG_IIO_MS_SENSORS_I2C=3Dm

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=3Dm
CONFIG_IIO_SSP_SENSORHUB=3Dm
CONFIG_IIO_ST_SENSORS_I2C=3Dm
CONFIG_IIO_ST_SENSORS_SPI=3Dm
CONFIG_IIO_ST_SENSORS_CORE=3Dm

#
# Digital to analog converters
#
CONFIG_AD5064=3Dm
CONFIG_AD5360=3Dm
CONFIG_AD5380=3Dm
CONFIG_AD5421=3Dm
CONFIG_AD5446=3Dm
CONFIG_AD5449=3Dm
CONFIG_AD5592R_BASE=3Dm
CONFIG_AD5592R=3Dm
CONFIG_AD5593R=3Dm
CONFIG_AD5504=3Dm
CONFIG_AD5624R_SPI=3Dm
CONFIG_AD5686=3Dm
CONFIG_AD5755=3Dm
CONFIG_AD5761=3Dm
CONFIG_AD5764=3Dm
CONFIG_AD5791=3Dm
CONFIG_AD7303=3Dm
CONFIG_M62332=3Dm
CONFIG_MAX517=3Dm
CONFIG_MCP4725=3Dm
CONFIG_MCP4922=3Dm

#
# IIO dummy driver
#
CONFIG_IIO_DUMMY_EVGEN=3Dm
CONFIG_IIO_SIMPLE_DUMMY=3Dm
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=3Dy
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=3Dy

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=3Dm

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=3Dm

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=3Dm
CONFIG_ADIS16130=3Dm
CONFIG_ADIS16136=3Dm
CONFIG_ADIS16260=3Dm
CONFIG_ADXRS450=3Dm
CONFIG_BMG160=3Dm
CONFIG_BMG160_I2C=3Dm
CONFIG_BMG160_SPI=3Dm
CONFIG_HID_SENSOR_GYRO_3D=3Dm
CONFIG_IIO_ST_GYRO_3AXIS=3Dm
CONFIG_IIO_ST_GYRO_I2C_3AXIS=3Dm
CONFIG_IIO_ST_GYRO_SPI_3AXIS=3Dm
CONFIG_ITG3200=3Dm

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=3Dm
CONFIG_AFE4404=3Dm
CONFIG_MAX30100=3Dm

#
# Humidity sensors
#
CONFIG_AM2315=3Dm
CONFIG_DHT11=3Dm
CONFIG_HDC100X=3Dm
CONFIG_HTU21=3Dm
CONFIG_SI7005=3Dm
CONFIG_SI7020=3Dm

#
# Inertial measurement units
#
CONFIG_ADIS16400=3Dm
CONFIG_ADIS16480=3Dm
CONFIG_BMI160=3Dm
CONFIG_BMI160_I2C=3Dm
CONFIG_BMI160_SPI=3Dm
CONFIG_KMX61=3Dm
CONFIG_INV_MPU6050_IIO=3Dm
CONFIG_INV_MPU6050_I2C=3Dm
CONFIG_INV_MPU6050_SPI=3Dm
CONFIG_IIO_ADIS_LIB=3Dm
CONFIG_IIO_ADIS_LIB_BUFFER=3Dy

#
# Light sensors
#
CONFIG_ACPI_ALS=3Dm
CONFIG_ADJD_S311=3Dm
CONFIG_AL3320A=3Dm
CONFIG_APDS9300=3Dm
CONFIG_APDS9960=3Dm
CONFIG_BH1750=3Dm
CONFIG_BH1780=3Dm
CONFIG_CM32181=3Dm
CONFIG_CM3232=3Dm
CONFIG_CM3323=3Dm
CONFIG_CM36651=3Dm
CONFIG_GP2AP020A00F=3Dm
CONFIG_ISL29125=3Dm
CONFIG_HID_SENSOR_ALS=3Dm
CONFIG_HID_SENSOR_PROX=3Dm
CONFIG_JSA1212=3Dm
CONFIG_RPR0521=3Dm
CONFIG_SENSORS_LM3533=3Dm
CONFIG_LTR501=3Dm
CONFIG_MAX44000=3Dm
CONFIG_OPT3001=3Dm
CONFIG_PA12203001=3Dm
CONFIG_STK3310=3Dm
CONFIG_TCS3414=3Dm
CONFIG_TCS3472=3Dm
CONFIG_SENSORS_TSL2563=3Dm
CONFIG_TSL4531=3Dm
CONFIG_US5182D=3Dm
CONFIG_VCNL4000=3Dm
CONFIG_VEML6070=3Dm

#
# Magnetometer sensors
#
CONFIG_AK8975=3Dm
CONFIG_AK09911=3Dm
CONFIG_BMC150_MAGN=3Dm
CONFIG_BMC150_MAGN_I2C=3Dm
CONFIG_BMC150_MAGN_SPI=3Dm
CONFIG_MAG3110=3Dm
CONFIG_HID_SENSOR_MAGNETOMETER_3D=3Dm
CONFIG_MMC35240=3Dm
CONFIG_IIO_ST_MAGN_3AXIS=3Dm
CONFIG_IIO_ST_MAGN_I2C_3AXIS=3Dm
CONFIG_IIO_ST_MAGN_SPI_3AXIS=3Dm
CONFIG_SENSORS_HMC5843=3Dm
CONFIG_SENSORS_HMC5843_I2C=3Dm
CONFIG_SENSORS_HMC5843_SPI=3Dm

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=3Dm
CONFIG_HID_SENSOR_DEVICE_ROTATION=3Dm

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=3Dm
CONFIG_IIO_INTERRUPT_TRIGGER=3Dm
CONFIG_IIO_SYSFS_TRIGGER=3Dm

#
# Digital potentiometers
#
CONFIG_DS1803=3Dm
CONFIG_MCP4131=3Dm
CONFIG_MCP4531=3Dm
CONFIG_TPL0102=3Dm

#
# Pressure sensors
#
CONFIG_HID_SENSOR_PRESS=3Dm
CONFIG_HP03=3Dm
CONFIG_MPL115=3Dm
CONFIG_MPL115_I2C=3Dm
CONFIG_MPL115_SPI=3Dm
CONFIG_MPL3115=3Dm
CONFIG_MS5611=3Dm
CONFIG_MS5611_I2C=3Dm
CONFIG_MS5611_SPI=3Dm
CONFIG_MS5637=3Dm
CONFIG_IIO_ST_PRESS=3Dm
CONFIG_IIO_ST_PRESS_I2C=3Dm
CONFIG_IIO_ST_PRESS_SPI=3Dm
CONFIG_T5403=3Dm
CONFIG_HP206C=3Dm

#
# Lightning sensors
#
CONFIG_AS3935=3Dm

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=3Dm
CONFIG_SX9500=3Dm

#
# Temperature sensors
#
CONFIG_MLX90614=3Dm
CONFIG_TMP006=3Dm
CONFIG_TSYS01=3Dm
CONFIG_TSYS02D=3Dm
CONFIG_NTB=3Dm
CONFIG_NTB_AMD=3Dm
CONFIG_NTB_INTEL=3Dm
CONFIG_NTB_PINGPONG=3Dm
CONFIG_NTB_TOOL=3Dm
CONFIG_NTB_PERF=3Dm
CONFIG_NTB_TRANSPORT=3Dm
CONFIG_VME_BUS=3Dy

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=3Dm
CONFIG_VME_TSI148=3Dm

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=3Dm

#
# VME Device Drivers
#
CONFIG_VME_USER=3Dm
CONFIG_VME_PIO2=3Dm
CONFIG_PWM=3Dy
CONFIG_PWM_SYSFS=3Dy
CONFIG_PWM_LP3943=3Dm
CONFIG_PWM_LPSS=3Dm
CONFIG_PWM_LPSS_PCI=3Dm
CONFIG_PWM_LPSS_PLATFORM=3Dm
CONFIG_PWM_PCA9685=3Dm
CONFIG_ARM_GIC_MAX_NR=3D1
CONFIG_IPACK_BUS=3Dm
CONFIG_BOARD_TPCI200=3Dm
CONFIG_SERIAL_IPOCTAL=3Dm
CONFIG_RESET_CONTROLLER=3Dy
CONFIG_FMC=3Dm
CONFIG_FMC_FAKEDEV=3Dm
CONFIG_FMC_TRIVIAL=3Dm
CONFIG_FMC_WRITE_EEPROM=3Dm
CONFIG_FMC_CHARDEV=3Dm

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=3Dy
CONFIG_PHY_PXA_28NM_HSIC=3Dm
CONFIG_PHY_PXA_28NM_USB2=3Dm
CONFIG_BCM_KONA_USB2_PHY=3Dm
CONFIG_PHY_TUSB1210=3Dm
CONFIG_POWERCAP=3Dy
CONFIG_INTEL_RAPL=3Dm
CONFIG_MCB=3Dm
CONFIG_MCB_PCI=3Dm

#
# Performance monitor support
#
CONFIG_RAS=3Dy
CONFIG_MCE_AMD_INJ=3Dm
CONFIG_THUNDERBOLT=3Dm

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=3Dy
CONFIG_BLK_DEV_PMEM=3Dm
CONFIG_ND_BLK=3Dm
CONFIG_ND_CLAIM=3Dy
CONFIG_ND_BTT=3Dm
CONFIG_BTT=3Dy
CONFIG_DEV_DAX=3Dm
CONFIG_NVMEM=3Dm
CONFIG_STM=3Dm
# CONFIG_STM_DUMMY is not set
CONFIG_STM_SOURCE_CONSOLE=3Dm
CONFIG_STM_SOURCE_HEARTBEAT=3Dm
CONFIG_INTEL_TH=3Dm
CONFIG_INTEL_TH_PCI=3Dm
CONFIG_INTEL_TH_GTH=3Dm
CONFIG_INTEL_TH_STH=3Dm
CONFIG_INTEL_TH_MSU=3Dm
CONFIG_INTEL_TH_PTI=3Dm
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=3Dm
CONFIG_FPGA_MGR_ZYNQ_FPGA=3Dm

#
# Firmware Drivers
#
CONFIG_EDD=3Dm
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=3Dy
CONFIG_DELL_RBU=3Dm
CONFIG_DCDBAS=3Dm
CONFIG_DMIID=3Dy
CONFIG_DMI_SYSFS=3Dm
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=3Dy
CONFIG_ISCSI_IBFT_FIND=3Dy
CONFIG_ISCSI_IBFT=3Dm
CONFIG_FW_CFG_SYSFS=3Dm
CONFIG_FW_CFG_SYSFS_CMDLINE=3Dy
CONFIG_GOOGLE_FIRMWARE=3Dy

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_SMI=3Dm
CONFIG_GOOGLE_MEMCONSOLE=3Dm

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=3Dm
CONFIG_EFI_ESRT=3Dy
CONFIG_EFI_VARS_PSTORE=3Dm
# CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE is not set
CONFIG_EFI_RUNTIME_MAP=3Dy
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=3Dy
CONFIG_EFI_BOOTLOADER_CONTROL=3Dm
CONFIG_EFI_CAPSULE_LOADER=3Dm
CONFIG_UEFI_CPER=3Dy

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=3Dy
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=3Dm
CONFIG_EXT4_USE_FOR_EXT2=3Dy
CONFIG_EXT4_FS_POSIX_ACL=3Dy
CONFIG_EXT4_FS_SECURITY=3Dy
CONFIG_EXT4_ENCRYPTION=3Dm
CONFIG_EXT4_FS_ENCRYPTION=3Dy
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=3Dm
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=3Dm
CONFIG_REISERFS_FS=3Dm
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=3Dy
CONFIG_REISERFS_FS_XATTR=3Dy
CONFIG_REISERFS_FS_POSIX_ACL=3Dy
CONFIG_REISERFS_FS_SECURITY=3Dy
CONFIG_JFS_FS=3Dm
CONFIG_JFS_POSIX_ACL=3Dy
CONFIG_JFS_SECURITY=3Dy
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=3Dy
CONFIG_XFS_FS=3Dm
CONFIG_XFS_QUOTA=3Dy
CONFIG_XFS_POSIX_ACL=3Dy
# CONFIG_XFS_RT is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=3Dm
CONFIG_GFS2_FS_LOCKING_DLM=3Dy
CONFIG_OCFS2_FS=3Dm
CONFIG_OCFS2_FS_O2CB=3Dm
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=3Dm
CONFIG_OCFS2_FS_STATS=3Dy
CONFIG_OCFS2_DEBUG_MASKLOG=3Dy
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=3Dm
CONFIG_BTRFS_FS_POSIX_ACL=3Dy
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
CONFIG_BTRFS_FS_RUN_SANITY_TESTS=3Dy
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=3Dm
CONFIG_F2FS_FS=3Dm
CONFIG_F2FS_STAT_FS=3Dy
CONFIG_F2FS_FS_XATTR=3Dy
CONFIG_F2FS_FS_POSIX_ACL=3Dy
CONFIG_F2FS_FS_SECURITY=3Dy
CONFIG_F2FS_CHECK_FS=3Dy
CONFIG_F2FS_FS_ENCRYPTION=3Dy
CONFIG_F2FS_IO_TRACE=3Dy
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=3Dy
CONFIG_FS_POSIX_ACL=3Dy
CONFIG_EXPORTFS=3Dy
CONFIG_FILE_LOCKING=3Dy
CONFIG_MANDATORY_FILE_LOCKING=3Dy
CONFIG_FS_ENCRYPTION=3Dm
CONFIG_FSNOTIFY=3Dy
CONFIG_DNOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
CONFIG_FANOTIFY=3Dy
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=3Dy
CONFIG_QUOTA=3Dy
CONFIG_QUOTA_NETLINK_INTERFACE=3Dy
CONFIG_PRINT_QUOTA_WARNING=3Dy
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=3Dm
CONFIG_QFMT_V1=3Dm
CONFIG_QFMT_V2=3Dm
CONFIG_QUOTACTL=3Dy
CONFIG_QUOTACTL_COMPAT=3Dy
CONFIG_AUTOFS4_FS=3Dm
CONFIG_FUSE_FS=3Dm
CONFIG_CUSE=3Dm
CONFIG_OVERLAY_FS=3Dm

#
# Caches
#
CONFIG_FSCACHE=3Dm
CONFIG_FSCACHE_STATS=3Dy
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=3Dm
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dm
CONFIG_JOLIET=3Dy
CONFIG_ZISOFS=3Dy
CONFIG_UDF_FS=3Dm
CONFIG_UDF_NLS=3Dy

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dm
CONFIG_MSDOS_FS=3Dm
CONFIG_VFAT_FS=3Dm
CONFIG_FAT_DEFAULT_CODEPAGE=3D437
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=3Dy
CONFIG_NTFS_FS=3Dm
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=3Dy

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_PROC_PAGE_MONITOR=3Dy
CONFIG_PROC_CHILDREN=3Dy
CONFIG_KERNFS=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
CONFIG_TMPFS_POSIX_ACL=3Dy
CONFIG_TMPFS_XATTR=3Dy
CONFIG_HUGETLBFS=3Dy
CONFIG_HUGETLB_PAGE=3Dy
CONFIG_CONFIGFS_FS=3Dm
CONFIG_EFIVAR_FS=3Dm
CONFIG_MISC_FILESYSTEMS=3Dy
CONFIG_ORANGEFS_FS=3Dm
CONFIG_ADFS_FS=3Dm
CONFIG_ADFS_FS_RW=3Dy
CONFIG_AFFS_FS=3Dm
CONFIG_ECRYPT_FS=3Dm
CONFIG_ECRYPT_FS_MESSAGING=3Dy
CONFIG_HFS_FS=3Dm
CONFIG_HFSPLUS_FS=3Dm
CONFIG_HFSPLUS_FS_POSIX_ACL=3Dy
CONFIG_BEFS_FS=3Dm
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=3Dm
CONFIG_EFS_FS=3Dm
CONFIG_JFFS2_FS=3Dm
CONFIG_JFFS2_FS_DEBUG=3D0
CONFIG_JFFS2_FS_WRITEBUFFER=3Dy
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=3Dy
CONFIG_JFFS2_FS_XATTR=3Dy
CONFIG_JFFS2_FS_POSIX_ACL=3Dy
CONFIG_JFFS2_FS_SECURITY=3Dy
CONFIG_JFFS2_COMPRESSION_OPTIONS=3Dy
CONFIG_JFFS2_ZLIB=3Dy
CONFIG_JFFS2_LZO=3Dy
CONFIG_JFFS2_RTIME=3Dy
CONFIG_JFFS2_RUBIN=3Dy
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=3Dy
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=3Dm
CONFIG_UBIFS_FS_ADVANCED_COMPR=3Dy
CONFIG_UBIFS_FS_LZO=3Dy
CONFIG_UBIFS_FS_ZLIB=3Dy
CONFIG_UBIFS_ATIME_SUPPORT=3Dy
CONFIG_LOGFS=3Dm
CONFIG_CRAMFS=3Dm
CONFIG_SQUASHFS=3Dm
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=3Dy
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=3Dy
CONFIG_SQUASHFS_XATTR=3Dy
CONFIG_SQUASHFS_ZLIB=3Dy
CONFIG_SQUASHFS_LZ4=3Dy
CONFIG_SQUASHFS_LZO=3Dy
CONFIG_SQUASHFS_XZ=3Dy
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=3Dy
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3D3
CONFIG_VXFS_FS=3Dm
CONFIG_MINIX_FS=3Dm
CONFIG_OMFS_FS=3Dm
CONFIG_HPFS_FS=3Dm
CONFIG_QNX4FS_FS=3Dm
CONFIG_QNX6FS_FS=3Dm
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=3Dy
CONFIG_ROMFS_BACKED_BY_BLOCK=3Dy
CONFIG_ROMFS_ON_BLOCK=3Dy
CONFIG_PSTORE=3Dy
CONFIG_PSTORE_CONSOLE=3Dy
CONFIG_PSTORE_PMSG=3Dy
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=3Dm
CONFIG_SYSV_FS=3Dm
CONFIG_UFS_FS=3Dm
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=3Dm
# CONFIG_EXOFS_DEBUG is not set
CONFIG_AUFS_FS=3Dm
# CONFIG_AUFS_BRANCH_MAX_127 is not set
CONFIG_AUFS_BRANCH_MAX_511=3Dy
# CONFIG_AUFS_BRANCH_MAX_1023 is not set
# CONFIG_AUFS_BRANCH_MAX_32767 is not set
CONFIG_AUFS_SBILIST=3Dy
CONFIG_AUFS_HNOTIFY=3Dy
CONFIG_AUFS_HFSNOTIFY=3Dy
CONFIG_AUFS_EXPORT=3Dy
CONFIG_AUFS_INO_T_64=3Dy
CONFIG_AUFS_XATTR=3Dy
CONFIG_AUFS_FHSM=3Dy
CONFIG_AUFS_RDU=3Dy
CONFIG_AUFS_SHWH=3Dy
CONFIG_AUFS_BR_RAMFS=3Dy
CONFIG_AUFS_BR_FUSE=3Dy
CONFIG_AUFS_POLL=3Dy
CONFIG_AUFS_BR_HFSPLUS=3Dy
CONFIG_AUFS_BDEV_LOOP=3Dy
# CONFIG_AUFS_DEBUG is not set
CONFIG_ORE=3Dm
CONFIG_NETWORK_FILESYSTEMS=3Dy
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V2=3Dm
CONFIG_NFS_V3=3Dm
CONFIG_NFS_V3_ACL=3Dy
CONFIG_NFS_V4=3Dm
CONFIG_NFS_SWAP=3Dy
# CONFIG_NFS_V4_1 is not set
CONFIG_NFS_FSCACHE=3Dy
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=3Dy
CONFIG_NFS_DEBUG=3Dy
CONFIG_NFSD=3Dm
CONFIG_NFSD_V2_ACL=3Dy
CONFIG_NFSD_V3=3Dy
CONFIG_NFSD_V3_ACL=3Dy
CONFIG_NFSD_V4=3Dy
CONFIG_NFSD_PNFS=3Dy
CONFIG_NFSD_BLOCKLAYOUT=3Dy
CONFIG_NFSD_SCSILAYOUT=3Dy
CONFIG_NFSD_V4_SECURITY_LABEL=3Dy
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=3Dm
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_NFS_ACL_SUPPORT=3Dm
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
CONFIG_SUNRPC_SWAP=3Dy
CONFIG_RPCSEC_GSS_KRB5=3Dm
CONFIG_SUNRPC_DEBUG=3Dy
CONFIG_SUNRPC_XPRT_RDMA=3Dm
CONFIG_CEPH_FS=3Dm
CONFIG_CEPH_FSCACHE=3Dy
CONFIG_CEPH_FS_POSIX_ACL=3Dy
CONFIG_CIFS=3Dm
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=3Dy
CONFIG_CIFS_UPCALL=3Dy
CONFIG_CIFS_XATTR=3Dy
CONFIG_CIFS_POSIX=3Dy
CONFIG_CIFS_ACL=3Dy
CONFIG_CIFS_DEBUG=3Dy
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DFS_UPCALL is not set
CONFIG_CIFS_SMB2=3Dy
CONFIG_CIFS_SMB311=3Dy
CONFIG_CIFS_FSCACHE=3Dy
CONFIG_NCP_FS=3Dm
CONFIG_NCPFS_PACKET_SIGNING=3Dy
CONFIG_NCPFS_IOCTL_LOCKING=3Dy
CONFIG_NCPFS_STRONG=3Dy
CONFIG_NCPFS_NFS_NS=3Dy
CONFIG_NCPFS_OS2_NS=3Dy
CONFIG_NCPFS_SMALLDOS=3Dy
CONFIG_NCPFS_NLS=3Dy
CONFIG_NCPFS_EXTRAS=3Dy
CONFIG_CODA_FS=3Dm
CONFIG_AFS_FS=3Dm
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=3Dy
CONFIG_9P_FS=3Dm
CONFIG_9P_FSCACHE=3Dy
CONFIG_9P_FS_POSIX_ACL=3Dy
CONFIG_9P_FS_SECURITY=3Dy
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
CONFIG_NLS_CODEPAGE_437=3Dm
CONFIG_NLS_CODEPAGE_737=3Dm
CONFIG_NLS_CODEPAGE_775=3Dm
CONFIG_NLS_CODEPAGE_850=3Dm
CONFIG_NLS_CODEPAGE_852=3Dm
CONFIG_NLS_CODEPAGE_855=3Dm
CONFIG_NLS_CODEPAGE_857=3Dm
CONFIG_NLS_CODEPAGE_860=3Dm
CONFIG_NLS_CODEPAGE_861=3Dm
CONFIG_NLS_CODEPAGE_862=3Dm
CONFIG_NLS_CODEPAGE_863=3Dm
CONFIG_NLS_CODEPAGE_864=3Dm
CONFIG_NLS_CODEPAGE_865=3Dm
CONFIG_NLS_CODEPAGE_866=3Dm
CONFIG_NLS_CODEPAGE_869=3Dm
CONFIG_NLS_CODEPAGE_936=3Dm
CONFIG_NLS_CODEPAGE_950=3Dm
CONFIG_NLS_CODEPAGE_932=3Dm
CONFIG_NLS_CODEPAGE_949=3Dm
CONFIG_NLS_CODEPAGE_874=3Dm
CONFIG_NLS_ISO8859_8=3Dm
CONFIG_NLS_CODEPAGE_1250=3Dm
CONFIG_NLS_CODEPAGE_1251=3Dm
CONFIG_NLS_ASCII=3Dm
CONFIG_NLS_ISO8859_1=3Dm
CONFIG_NLS_ISO8859_2=3Dm
CONFIG_NLS_ISO8859_3=3Dm
CONFIG_NLS_ISO8859_4=3Dm
CONFIG_NLS_ISO8859_5=3Dm
CONFIG_NLS_ISO8859_6=3Dm
CONFIG_NLS_ISO8859_7=3Dm
CONFIG_NLS_ISO8859_9=3Dm
CONFIG_NLS_ISO8859_13=3Dm
CONFIG_NLS_ISO8859_14=3Dm
CONFIG_NLS_ISO8859_15=3Dm
CONFIG_NLS_KOI8_R=3Dm
CONFIG_NLS_KOI8_U=3Dm
CONFIG_NLS_MAC_ROMAN=3Dm
CONFIG_NLS_MAC_CELTIC=3Dm
CONFIG_NLS_MAC_CENTEURO=3Dm
CONFIG_NLS_MAC_CROATIAN=3Dm
CONFIG_NLS_MAC_CYRILLIC=3Dm
CONFIG_NLS_MAC_GAELIC=3Dm
CONFIG_NLS_MAC_GREEK=3Dm
CONFIG_NLS_MAC_ICELAND=3Dm
CONFIG_NLS_MAC_INUIT=3Dm
CONFIG_NLS_MAC_ROMANIAN=3Dm
CONFIG_NLS_MAC_TURKISH=3Dm
CONFIG_NLS_UTF8=3Dm
CONFIG_DLM=3Dm
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=3Dy
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=3D4
CONFIG_BOOT_PRINTK_DELAY=3Dy
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=3Dy
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_INFO_SPLIT=3Dy
CONFIG_DEBUG_INFO_DWARF4=3Dy
CONFIG_GDB_SCRIPTS=3Dy
CONFIG_ENABLE_WARN_DEPRECATED=3Dy
CONFIG_ENABLE_MUST_CHECK=3Dy
CONFIG_FRAME_WARN=3D2048
CONFIG_STRIP_ASM_SYMS=3Dy
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=3Dy
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=3Dy
CONFIG_HEADERS_CHECK=3Dy
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=3Dy
CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
CONFIG_FRAME_POINTER=3Dy
# CONFIG_STACK_VALIDATION is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=3Dy
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=3D0x1
CONFIG_DEBUG_KERNEL=3Dy

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=3Dy
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=3Dm
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=3Dy
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
CONFIG_HAVE_ARCH_KASAN=3Dy
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=3Dy
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=3Dy
CONFIG_HARDLOCKUP_DETECTOR=3Dy
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=3D0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=3D0
CONFIG_DETECT_HUNG_TASK=3Dy
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=3D120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=3D0
CONFIG_WQ_WATCHDOG=3Dy
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=3D0
CONFIG_PANIC_TIMEOUT=3D180
# CONFIG_SCHED_DEBUG is not set
CONFIG_SCHED_INFO=3Dy
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=3Dy
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_TIMER_STATS=3Dy

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=3Dm
CONFIG_STACKTRACE=3Dy
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=3Dy
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=3Dm
CONFIG_RCU_PERF_TEST=3Dm
CONFIG_RCU_TORTURE_TEST=3Dm
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=3D60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=3Dm
CONFIG_CPU_NOTIFIER_ERROR_INJECT=3Dm
CONFIG_PM_NOTIFIER_ERROR_INJECT=3Dm
CONFIG_NETDEV_NOTIFIER_ERROR_INJECT=3Dm
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=3Dy
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=3Dy
CONFIG_NOP_TRACER=3Dy
CONFIG_HAVE_FUNCTION_TRACER=3Dy
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy
CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=3Dy
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
CONFIG_HAVE_FENTRY=3Dy
CONFIG_HAVE_C_RECORDMCOUNT=3Dy
CONFIG_TRACER_MAX_TRACE=3Dy
CONFIG_TRACE_CLOCK=3Dy
CONFIG_RING_BUFFER=3Dy
CONFIG_EVENT_TRACING=3Dy
CONFIG_CONTEXT_SWITCH_TRACER=3Dy
CONFIG_RING_BUFFER_ALLOW_SWAP=3Dy
CONFIG_TRACING=3Dy
CONFIG_GENERIC_TRACER=3Dy
CONFIG_TRACING_SUPPORT=3Dy
CONFIG_FTRACE=3Dy
CONFIG_FUNCTION_TRACER=3Dy
CONFIG_FUNCTION_GRAPH_TRACER=3Dy
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=3Dy
CONFIG_FTRACE_SYSCALLS=3Dy
CONFIG_TRACER_SNAPSHOT=3Dy
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=3Dy
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=3Dy
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_KPROBE_EVENT=3Dy
CONFIG_UPROBE_EVENT=3Dy
CONFIG_BPF_EVENTS=3Dy
CONFIG_PROBE_EVENTS=3Dy
CONFIG_DYNAMIC_FTRACE=3Dy
CONFIG_DYNAMIC_FTRACE_WITH_REGS=3Dy
CONFIG_FUNCTION_PROFILER=3Dy
CONFIG_FTRACE_MCOUNT_RECORD=3Dy
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=3Dm
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_ENUM_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=3Dy

#
# Runtime Testing
#
CONFIG_LKDTM=3Dm
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
CONFIG_BACKTRACE_SELF_TEST=3Dm
CONFIG_RBTREE_TEST=3Dm
CONFIG_INTERVAL_TREE_TEST=3Dm
CONFIG_PERCPU_TEST=3Dm
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_ASYNC_RAID6_TEST=3Dm
CONFIG_TEST_HEXDUMP=3Dm
CONFIG_TEST_STRING_HELPERS=3Dm
CONFIG_TEST_KSTRTOX=3Dm
CONFIG_TEST_PRINTF=3Dm
CONFIG_TEST_BITMAP=3Dm
CONFIG_TEST_UUID=3Dm
# CONFIG_TEST_RHASHTABLE is not set
CONFIG_TEST_HASH=3Dm
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_LKM is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
CONFIG_TEST_FIRMWARE=3Dm
CONFIG_TEST_UDELAY=3Dm
# CONFIG_MEMTEST is not set
CONFIG_TEST_STATIC_KEYS=3Dm
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=3Dy
CONFIG_KGDB=3Dy
CONFIG_KGDB_SERIAL_CONSOLE=3Dy
CONFIG_KGDB_TESTS=3Dy
# CONFIG_KGDB_TESTS_ON_BOOT is not set
# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
CONFIG_KGDB_KDB=3Dy
CONFIG_KDB_DEFAULT_ENABLE=3D0x0
CONFIG_KDB_KEYBOARD=3Dy
CONFIG_KDB_CONTINUE_CATASTROPHIC=3D0
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=3Dy
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=3Dy
CONFIG_STRICT_DEVMEM=3Dy
CONFIG_IO_STRICT_DEVMEM=3Dy
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=3Dy
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_EFI is not set
CONFIG_X86_PTDUMP_CORE=3Dy
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=3Dy
CONFIG_DEBUG_SET_MODULE_RONX=3Dy
CONFIG_DEBUG_NX_TEST=3Dm
CONFIG_DOUBLEFAULT=3Dy
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=3D0
CONFIG_IO_DELAY_TYPE_0XED=3D1
CONFIG_IO_DELAY_TYPE_UDELAY=3D2
CONFIG_IO_DELAY_TYPE_NONE=3D3
CONFIG_IO_DELAY_0X80=3Dy
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=3Dy
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=3Dm

#
# Security options
#
CONFIG_KEYS=3Dy
CONFIG_PERSISTENT_KEYRINGS=3Dy
CONFIG_BIG_KEYS=3Dy
CONFIG_TRUSTED_KEYS=3Dm
CONFIG_ENCRYPTED_KEYS=3Dy
CONFIG_KEY_DH_OPERATIONS=3Dy
CONFIG_SECURITY_DMESG_RESTRICT=3Dy
CONFIG_SECURITY=3Dy
CONFIG_SECURITYFS=3Dy
CONFIG_SECURITY_NETWORK=3Dy
CONFIG_SECURITY_NETWORK_XFRM=3Dy
CONFIG_SECURITY_PATH=3Dy
CONFIG_INTEL_TXT=3Dy
CONFIG_LSM_MMAP_MIN_ADDR=3D65536
CONFIG_SECURITY_SELINUX=3Dy
CONFIG_SECURITY_SELINUX_BOOTPARAM=3Dy
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=3D0
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=3Dy
# CONFIG_SECURITY_SELINUX_AVC_STATS is not set
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=3D1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_SMACK=3Dy
CONFIG_SECURITY_SMACK_BRINGUP=3Dy
CONFIG_SECURITY_SMACK_NETFILTER=3Dy
CONFIG_SECURITY_TOMOYO=3Dy
CONFIG_SECURITY_TOMOYO_MAX_ACCEPT_ENTRY=3D2048
CONFIG_SECURITY_TOMOYO_MAX_AUDIT_LOG=3D1024
# CONFIG_SECURITY_TOMOYO_OMIT_USERSPACE_LOADER is not set
CONFIG_SECURITY_TOMOYO_POLICY_LOADER=3D"/sbin/tomoyo-init"
CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER=3D"/sbin/init"
CONFIG_SECURITY_APPARMOR=3Dy
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=3D1
CONFIG_SECURITY_APPARMOR_HASH=3Dy
# CONFIG_SECURITY_LOADPIN is not set
CONFIG_SECURITY_YAMA=3Dy
CONFIG_INTEGRITY=3Dy
CONFIG_INTEGRITY_SIGNATURE=3Dy
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=3Dy
CONFIG_INTEGRITY_TRUSTED_KEYRING=3Dy
CONFIG_INTEGRITY_AUDIT=3Dy
# CONFIG_IMA is not set
# CONFIG_IMA_KEYRINGS_PERMIT_SIGNED_BY_BUILTIN_OR_SECONDARY is not set
CONFIG_EVM=3Dy
CONFIG_EVM_ATTR_FSUUID=3Dy
CONFIG_EVM_EXTRA_SMACK_XATTRS=3Dy
CONFIG_EVM_LOAD_X509=3Dy
CONFIG_EVM_X509_PATH=3D"/etc/keys/x509_evm.der"
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_SMACK is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
CONFIG_DEFAULT_SECURITY_DAC=3Dy
CONFIG_DEFAULT_SECURITY=3D""
CONFIG_XOR_BLOCKS=3Dm
CONFIG_ASYNC_CORE=3Dm
CONFIG_ASYNC_MEMCPY=3Dm
CONFIG_ASYNC_XOR=3Dm
CONFIG_ASYNC_PQ=3Dm
CONFIG_ASYNC_RAID6_RECOV=3Dm
CONFIG_CRYPTO=3Dy

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=3Dy
CONFIG_CRYPTO_ALGAPI2=3Dy
CONFIG_CRYPTO_AEAD=3Dm
CONFIG_CRYPTO_AEAD2=3Dy
CONFIG_CRYPTO_BLKCIPHER=3Dy
CONFIG_CRYPTO_BLKCIPHER2=3Dy
CONFIG_CRYPTO_HASH=3Dy
CONFIG_CRYPTO_HASH2=3Dy
CONFIG_CRYPTO_RNG=3Dy
CONFIG_CRYPTO_RNG2=3Dy
CONFIG_CRYPTO_RNG_DEFAULT=3Dm
CONFIG_CRYPTO_AKCIPHER2=3Dy
CONFIG_CRYPTO_AKCIPHER=3Dy
CONFIG_CRYPTO_RSA=3Dy
CONFIG_CRYPTO_MANAGER=3Dy
CONFIG_CRYPTO_MANAGER2=3Dy
CONFIG_CRYPTO_USER=3Dm
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=3Dy
CONFIG_CRYPTO_GF128MUL=3Dm
CONFIG_CRYPTO_NULL=3Dm
CONFIG_CRYPTO_NULL2=3Dy
CONFIG_CRYPTO_PCRYPT=3Dm
CONFIG_CRYPTO_WORKQUEUE=3Dy
CONFIG_CRYPTO_CRYPTD=3Dm
CONFIG_CRYPTO_MCRYPTD=3Dm
CONFIG_CRYPTO_AUTHENC=3Dm
CONFIG_CRYPTO_TEST=3Dm
CONFIG_CRYPTO_ABLK_HELPER=3Dm
CONFIG_CRYPTO_GLUE_HELPER_X86=3Dm

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=3Dm
CONFIG_CRYPTO_GCM=3Dm
CONFIG_CRYPTO_CHACHA20POLY1305=3Dm
CONFIG_CRYPTO_SEQIV=3Dm
CONFIG_CRYPTO_ECHAINIV=3Dm

#
# Block modes
#
CONFIG_CRYPTO_CBC=3Dy
CONFIG_CRYPTO_CTR=3Dm
CONFIG_CRYPTO_CTS=3Dm
CONFIG_CRYPTO_ECB=3Dy
CONFIG_CRYPTO_LRW=3Dm
CONFIG_CRYPTO_PCBC=3Dm
CONFIG_CRYPTO_XTS=3Dm
CONFIG_CRYPTO_KEYWRAP=3Dm

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=3Dm
CONFIG_CRYPTO_HMAC=3Dy
CONFIG_CRYPTO_XCBC=3Dm
CONFIG_CRYPTO_VMAC=3Dm

#
# Digest
#
CONFIG_CRYPTO_CRC32C=3Dm
CONFIG_CRYPTO_CRC32C_INTEL=3Dm
CONFIG_CRYPTO_CRC32=3Dm
CONFIG_CRYPTO_CRC32_PCLMUL=3Dm
CONFIG_CRYPTO_CRCT10DIF=3Dy
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=3Dm
CONFIG_CRYPTO_GHASH=3Dm
CONFIG_CRYPTO_POLY1305=3Dm
CONFIG_CRYPTO_POLY1305_X86_64=3Dm
CONFIG_CRYPTO_MD4=3Dm
CONFIG_CRYPTO_MD5=3Dy
CONFIG_CRYPTO_MICHAEL_MIC=3Dm
CONFIG_CRYPTO_RMD128=3Dm
CONFIG_CRYPTO_RMD160=3Dm
CONFIG_CRYPTO_RMD256=3Dm
CONFIG_CRYPTO_RMD320=3Dm
CONFIG_CRYPTO_SHA1=3Dy
CONFIG_CRYPTO_SHA1_SSSE3=3Dm
CONFIG_CRYPTO_SHA256_SSSE3=3Dm
CONFIG_CRYPTO_SHA512_SSSE3=3Dm
CONFIG_CRYPTO_SHA1_MB=3Dm
CONFIG_CRYPTO_SHA256=3Dy
CONFIG_CRYPTO_SHA512=3Dm
CONFIG_CRYPTO_TGR192=3Dm
CONFIG_CRYPTO_WP512=3Dm
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=3Dm

#
# Ciphers
#
CONFIG_CRYPTO_AES=3Dy
CONFIG_CRYPTO_AES_X86_64=3Dm
CONFIG_CRYPTO_AES_NI_INTEL=3Dm
CONFIG_CRYPTO_ANUBIS=3Dm
CONFIG_CRYPTO_ARC4=3Dm
CONFIG_CRYPTO_BLOWFISH=3Dm
CONFIG_CRYPTO_BLOWFISH_COMMON=3Dm
CONFIG_CRYPTO_BLOWFISH_X86_64=3Dm
CONFIG_CRYPTO_CAMELLIA=3Dm
CONFIG_CRYPTO_CAMELLIA_X86_64=3Dm
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=3Dm
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=3Dm
CONFIG_CRYPTO_CAST_COMMON=3Dm
CONFIG_CRYPTO_CAST5=3Dm
CONFIG_CRYPTO_CAST5_AVX_X86_64=3Dm
CONFIG_CRYPTO_CAST6=3Dm
CONFIG_CRYPTO_CAST6_AVX_X86_64=3Dm
CONFIG_CRYPTO_DES=3Dm
CONFIG_CRYPTO_DES3_EDE_X86_64=3Dm
CONFIG_CRYPTO_FCRYPT=3Dm
CONFIG_CRYPTO_KHAZAD=3Dm
CONFIG_CRYPTO_SALSA20=3Dm
CONFIG_CRYPTO_SALSA20_X86_64=3Dm
CONFIG_CRYPTO_CHACHA20=3Dm
CONFIG_CRYPTO_CHACHA20_X86_64=3Dm
CONFIG_CRYPTO_SEED=3Dm
CONFIG_CRYPTO_SERPENT=3Dm
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=3Dm
CONFIG_CRYPTO_SERPENT_AVX_X86_64=3Dm
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=3Dm
CONFIG_CRYPTO_TEA=3Dm
CONFIG_CRYPTO_TWOFISH=3Dm
CONFIG_CRYPTO_TWOFISH_COMMON=3Dm
CONFIG_CRYPTO_TWOFISH_X86_64=3Dm
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=3Dm
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=3Dm

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=3Dm
CONFIG_CRYPTO_LZO=3Dy
CONFIG_CRYPTO_842=3Dm
CONFIG_CRYPTO_LZ4=3Dm
CONFIG_CRYPTO_LZ4HC=3Dm

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=3Dm
CONFIG_CRYPTO_DRBG_MENU=3Dm
CONFIG_CRYPTO_DRBG_HMAC=3Dy
CONFIG_CRYPTO_DRBG_HASH=3Dy
CONFIG_CRYPTO_DRBG_CTR=3Dy
CONFIG_CRYPTO_DRBG=3Dm
CONFIG_CRYPTO_JITTERENTROPY=3Dm
CONFIG_CRYPTO_USER_API=3Dm
CONFIG_CRYPTO_USER_API_HASH=3Dm
CONFIG_CRYPTO_USER_API_SKCIPHER=3Dm
CONFIG_CRYPTO_USER_API_RNG=3Dm
CONFIG_CRYPTO_USER_API_AEAD=3Dm
CONFIG_CRYPTO_HASH_INFO=3Dy
CONFIG_CRYPTO_HW=3Dy
CONFIG_CRYPTO_DEV_PADLOCK=3Dm
CONFIG_CRYPTO_DEV_PADLOCK_AES=3Dm
CONFIG_CRYPTO_DEV_PADLOCK_SHA=3Dm
CONFIG_CRYPTO_DEV_CCP=3Dy
CONFIG_CRYPTO_DEV_CCP_DD=3Dm
CONFIG_CRYPTO_DEV_CCP_CRYPTO=3Dm
CONFIG_CRYPTO_DEV_QAT=3Dm
CONFIG_CRYPTO_DEV_QAT_DH895xCC=3Dm
CONFIG_CRYPTO_DEV_QAT_C3XXX=3Dm
CONFIG_CRYPTO_DEV_QAT_C62X=3Dm
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=3Dm
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=3Dm
CONFIG_CRYPTO_DEV_QAT_C62XVF=3Dm
CONFIG_ASYMMETRIC_KEY_TYPE=3Dy
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=3Dy
CONFIG_X509_CERTIFICATE_PARSER=3Dy
CONFIG_PKCS7_MESSAGE_PARSER=3Dm

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=3Dy
CONFIG_SYSTEM_TRUSTED_KEYS=3D""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=3Dy
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=3D4096
CONFIG_SECONDARY_TRUSTED_KEYRING=3Dy
CONFIG_HAVE_KVM=3Dy
CONFIG_HAVE_KVM_IRQCHIP=3Dy
CONFIG_HAVE_KVM_IRQFD=3Dy
CONFIG_HAVE_KVM_IRQ_ROUTING=3Dy
CONFIG_HAVE_KVM_EVENTFD=3Dy
CONFIG_KVM_APIC_ARCHITECTURE=3Dy
CONFIG_KVM_MMIO=3Dy
CONFIG_KVM_ASYNC_PF=3Dy
CONFIG_HAVE_KVM_MSI=3Dy
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=3Dy
CONFIG_KVM_VFIO=3Dy
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=3Dy
CONFIG_KVM_COMPAT=3Dy
CONFIG_HAVE_KVM_IRQ_BYPASS=3Dy
CONFIG_VIRTUALIZATION=3Dy
CONFIG_KVM=3Dm
CONFIG_KVM_INTEL=3Dm
CONFIG_KVM_AMD=3Dm
CONFIG_KVM_MMU_AUDIT=3Dy
CONFIG_KVM_DEVICE_ASSIGNMENT=3Dy
CONFIG_BINARY_PRINTF=3Dy

#
# Library routines
#
CONFIG_RAID6_PQ=3Dm
CONFIG_BITREVERSE=3Dy
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=3Dy
CONFIG_GENERIC_STRNCPY_FROM_USER=3Dy
CONFIG_GENERIC_STRNLEN_USER=3Dy
CONFIG_GENERIC_NET_UTILS=3Dy
CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
CONFIG_GENERIC_PCI_IOMAP=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_GENERIC_IO=3Dy
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=3Dy
CONFIG_ARCH_HAS_FAST_MULTIPLIER=3Dy
CONFIG_CRC_CCITT=3Dm
CONFIG_CRC16=3Dm
CONFIG_CRC_T10DIF=3Dy
CONFIG_CRC_ITU_T=3Dm
CONFIG_CRC32=3Dy
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=3Dy
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=3Dm
CONFIG_LIBCRC32C=3Dm
CONFIG_CRC8=3Dm
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=3Dy
CONFIG_842_COMPRESS=3Dm
CONFIG_842_DECOMPRESS=3Dm
CONFIG_ZLIB_INFLATE=3Dy
CONFIG_ZLIB_DEFLATE=3Dy
CONFIG_LZO_COMPRESS=3Dy
CONFIG_LZO_DECOMPRESS=3Dy
CONFIG_LZ4_COMPRESS=3Dm
CONFIG_LZ4HC_COMPRESS=3Dm
CONFIG_LZ4_DECOMPRESS=3Dy
CONFIG_XZ_DEC=3Dy
CONFIG_XZ_DEC_X86=3Dy
CONFIG_XZ_DEC_POWERPC=3Dy
CONFIG_XZ_DEC_IA64=3Dy
CONFIG_XZ_DEC_ARM=3Dy
CONFIG_XZ_DEC_ARMTHUMB=3Dy
CONFIG_XZ_DEC_SPARC=3Dy
CONFIG_XZ_DEC_BCJ=3Dy
CONFIG_XZ_DEC_TEST=3Dm
CONFIG_DECOMPRESS_GZIP=3Dy
CONFIG_DECOMPRESS_BZIP2=3Dy
CONFIG_DECOMPRESS_LZMA=3Dy
CONFIG_DECOMPRESS_XZ=3Dy
CONFIG_DECOMPRESS_LZO=3Dy
CONFIG_DECOMPRESS_LZ4=3Dy
CONFIG_GENERIC_ALLOCATOR=3Dy
CONFIG_REED_SOLOMON=3Dm
CONFIG_REED_SOLOMON_ENC8=3Dy
CONFIG_REED_SOLOMON_DEC8=3Dy
CONFIG_REED_SOLOMON_DEC16=3Dy
CONFIG_BCH=3Dm
CONFIG_BCH_CONST_PARAMS=3Dy
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dm
CONFIG_TEXTSEARCH_BM=3Dm
CONFIG_TEXTSEARCH_FSM=3Dm
CONFIG_BTREE=3Dy
CONFIG_INTERVAL_TREE=3Dy
CONFIG_RADIX_TREE_MULTIORDER=3Dy
CONFIG_ASSOCIATIVE_ARRAY=3Dy
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT_MAP=3Dy
CONFIG_HAS_DMA=3Dy
CONFIG_CHECK_SIGNATURE=3Dy
CONFIG_CPU_RMAP=3Dy
CONFIG_DQL=3Dy
CONFIG_GLOB=3Dy
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=3Dy
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=3Dy
CONFIG_LRU_CACHE=3Dm
CONFIG_CLZ_TAB=3Dy
CONFIG_CORDIC=3Dm
CONFIG_DDR=3Dy
CONFIG_IRQ_POLL=3Dy
CONFIG_MPILIB=3Dy
CONFIG_SIGNATURE=3Dy
CONFIG_OID_REGISTRY=3Dy
CONFIG_UCS2_STRING=3Dy
CONFIG_FONT_SUPPORT=3Dy
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=3Dy
CONFIG_FONT_8x16=3Dy
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=3Dy
CONFIG_ARCH_HAS_SG_CHAIN=3Dy
CONFIG_ARCH_HAS_PMEM_API=3Dy
CONFIG_ARCH_HAS_MMIO_FLUSH=3Dy


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
