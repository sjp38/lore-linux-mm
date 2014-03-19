Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8605F6B0160
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 08:03:04 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so8739638pbb.26
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 05:03:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yp10si14824256pab.380.2014.03.19.05.03.02
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 05:03:03 -0700 (PDT)
Date: Wed, 19 Mar 2014 20:02:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [cpuidle] BUG: sleeping function called from invalid context at
 /c/kernel-tests/src/lkp/mm/vmalloc.c:74
Message-ID: <20140319120251.GC7277@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="YD3LsXFS42OYHhNZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pm@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org


--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

FYI, the below debug patch triggers a warning on cpuidle code path

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 3d693a5127e79e79da7c34dc0c776bc620697ce5
Author:     Andrew Morton <akpm@linux-foundation.org>
AuthorDate: Mon Mar 17 11:23:56 2014 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Mon Mar 17 11:23:56 2014 +1100

    mm-vmalloc-avoid-soft-lockup-warnings-when-vunmaping-large-ranges-fix
    
    add a might_sleep() to catch atomic callers more promptly
    
    Cc: David Vrabel <david.vrabel@citrix.com>
    Cc: Dietmar Hahn <dietmar.hahn@ts.fujitsu.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>


[   26.028136] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
[   26.040078] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/0
[   26.040080] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc6-next-20140317 #1
[   26.040081] Hardware name: Intel Corporation S5520UR/S5520UR, BIOS S5500.86B.01.00.0050.050620101605 05/06/2010
[   26.040083]  0000000000000000 ffff8801e9c06d00 ffffffff81a3ae8a ffffc90001870000
[   26.040084]  ffff8801e9c06d10 ffffffff81101256 ffff8801e9c06d88 ffffffff811b1540
[   26.040089]  ffffc90001870fff ffffc90001870fff 0000000000000001 000037008ddb0000
[   26.040089] Call Trace:
[   26.040094]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[   26.040098]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[   26.040101]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[   26.040102]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
[   26.040105]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
[   26.040106]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
[   26.040108]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
[   26.040110]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
[   26.040112]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
[   26.040113]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
[   26.040114]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
[   26.040118]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
[   26.040119]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
[   26.040120]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
[   26.040124]  <<EOE>>  <IRQ>  [<ffffffff8104e597>] intel_pmu_enable_all+0x4c/0x9b
[   26.040125]  [<ffffffff8104e607>] intel_pmu_nhm_enable_all+0x21/0x152
[   26.040127]  [<ffffffff81049b00>] x86_pmu_enable+0x134/0x273
[   26.040129]  [<ffffffff81176942>] perf_pmu_enable+0x22/0x24
[   26.040130]  [<ffffffff81048268>] x86_pmu_commit_txn+0x7b/0x98
[   26.040132]  [<ffffffff81112a66>] ? __wake_up+0x44/0x4b
[   26.040135]  [<ffffffff81579c81>] ? tty_wakeup+0x5b/0x60
[   26.040137]  [<ffffffff81593d02>] ? uart_write_wakeup+0x20/0x22
[   26.040139]  [<ffffffff81596c7d>] ? serial8250_tx_chars+0xd9/0x142
[   26.040140]  [<ffffffff81a42396>] ? _raw_spin_unlock_irqrestore+0x25/0x41
[   26.040141]  [<ffffffff81a4220b>] ? _raw_spin_lock_irqsave+0x25/0x56
[   26.040142]  [<ffffffff81a42396>] ? _raw_spin_unlock_irqrestore+0x25/0x41
[   26.040144]  [<ffffffff810fb494>] ? hrtimer_get_next_event+0x83/0x98
[   26.040145]  [<ffffffff81177ad6>] ? event_sched_in+0x133/0x143
[   26.040146]  [<ffffffff81177b79>] group_sched_in+0x93/0x13c
[   26.040149]  [<ffffffff8103edc7>] ? native_sched_clock+0x31/0x93
[   26.040150]  [<ffffffff81178a83>] __perf_event_enable+0x1ad/0x1ea
[   26.040151]  [<ffffffff81175275>] remote_function+0x17/0x40
[   26.040154]  [<ffffffff8113786f>] generic_smp_call_function_single_interrupt+0x74/0xdb
[   26.040156]  [<ffffffff8105bb9e>] smp_call_function_single_interrupt+0x27/0x36
[   26.040158]  [<ffffffff81a4ae32>] call_function_single_interrupt+0x72/0x80
[   26.040161]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
[   26.040162]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
[   26.040164]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
[   26.040165]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
[   26.040167]  [<ffffffff81a2ca43>] rest_init+0x87/0x89
[   26.040169]  [<ffffffff82353dda>] start_kernel+0x401/0x40c
[   26.040170]  [<ffffffff823537e7>] ? repair_env_string+0x58/0x58
[   26.040171]  [<ffffffff82353120>] ? early_idt_handlers+0x120/0x120
[   26.040173]  [<ffffffff823534a2>] x86_64_start_reservations+0x2a/0x2c
[   26.040174]  [<ffffffff823535df>] x86_64_start_kernel+0x13b/0x148
[   26.463198] perf interrupt took too long (2503 > 2500), lowering kernel.perf_event_max_sample_rate to 50000

Thanks,
Fengguang

--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
[    0.000000] Command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-ne04/cyclic_aim7-shell_rtns_1-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=1219 RESULT_ROOT=/lkp/result/lkp-ne04/micro/aim7/shell_rtns_1/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-ne04::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009a3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009a400-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000008c555fff] usable
[    0.000000] BIOS-e820: [mem 0x000000008c556000-0x000000008c628fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000008c629000-0x000000008c701fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000008c702000-0x000000008db01fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000008db02000-0x000000008f601fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000008f602000-0x000000008f64efff] reserved
[    0.000000] BIOS-e820: [mem 0x000000008f64f000-0x000000008f6e5fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000008f6e6000-0x000000008f6effff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000008f6f0000-0x000000008f6f1fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000008f6f2000-0x000000008f7cefff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000008f7cf000-0x000000008f7fffff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000008f800000-0x000000008fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000a0000000-0x00000000afffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fc000000-0x00000000fcffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000036fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.5 present.
[    0.000000] DMI: Intel Corporation S5520UR/S5520UR, BIOS S5500.86B.01.00.0050.050620101605 05/06/2010
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x370000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-DFFFF uncachable
[    0.000000]   E0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 base 0080000000 mask FFF0000000 write-back
[    0.000000]   2 base 0100000000 mask FF00000000 write-back
[    0.000000]   3 base 0200000000 mask FF00000000 write-back
[    0.000000]   4 base 0300000000 mask FFC0000000 write-back
[    0.000000]   5 base 0340000000 mask FFE0000000 write-back
[    0.000000]   6 base 0360000000 mask FFF0000000 write-back
[    0.000000]   7 base 00B0000000 mask FFFF000000 write-combining
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: last_pfn = 0x8c556 max_arch_pfn = 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [ffff8800000fdab0]
[    0.000000]   mpc: ef260-ef424
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000094000] 94000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0266b000, 0x0266bfff] PGTABLE
[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x36fe00000-0x36fffffff]
[    0.000000]  [mem 0x36fe00000-0x36fffffff] page 2M
[    0.000000] BRK [0x0266e000, 0x0266efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x36c000000-0x36fdfffff]
[    0.000000]  [mem 0x36c000000-0x36fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x300000000-0x36bffffff]
[    0.000000]  [mem 0x300000000-0x36bffffff] page 2M
[    0.000000] BRK [0x0266f000, 0x0266ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x8c555fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x8c3fffff] page 2M
[    0.000000]  [mem 0x8c400000-0x8c555fff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x2ffffffff]
[    0.000000]  [mem 0x100000000-0x2ffffffff] page 2M
[    0.000000] BRK [0x02670000, 0x02670fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x72fd1000-0x7fff4fff]
[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000008F7FD120 000094 (v01 INTEL  S5520UR  00000000      01000013)
[    0.000000] ACPI: FACP 0x000000008F7FB000 0000F4 (v04 INTEL  S5520UR  00000000 MSFT 0100000D)
[    0.000000] ACPI: DSDT 0x000000008F7F4000 00657E (v02 INTEL  S5520UR  00000003 MSFT 0100000D)
[    0.000000] ACPI: FACS 0x000000008F6F2000 000040
[    0.000000] ACPI: APIC 0x000000008F7F3000 0001A8 (v02 INTEL  S5520UR  00000000 MSFT 0100000D)
[    0.000000] ACPI: MCFG 0x000000008F7F2000 00003C (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
[    0.000000] ACPI: HPET 0x000000008F7F1000 000038 (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
[    0.000000] ACPI: SLIT 0x000000008F7F0000 000030 (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
[    0.000000] ACPI: SRAT 0x000000008F7EF000 000430 (v02 INTEL  S5520UR  00000001 MSFT 0100000D)
[    0.000000] ACPI: SPCR 0x000000008F7EE000 000050 (v01 INTEL  S5520UR  00000000 MSFT 0100000D)
[    0.000000] ACPI: WDDT 0x000000008F7ED000 000040 (v01 INTEL  S5520UR  00000000 MSFT 0100000D)
[    0.000000] ACPI: SSDT 0x000000008F7D2000 01AFC4 (v02 INTEL  SSDT  PM 00004000 INTL 20061109)
[    0.000000] ACPI: SSDT 0x000000008F7D1000 0001D8 (v02 INTEL  IPMI     00004000 INTL 20061109)
[    0.000000] ACPI: HEST 0x000000008F7D0000 0000A8 (v01 INTEL  S5520UR  00000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000008F7CF000 000030 (v01 INTEL  S5520UR  00000001 INTL 00000001)
[    0.000000] ACPI: ERST 0x000000008F6F1000 000230 (v01 INTEL  S5520UR  00000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000008F6F0000 000130 (v01 INTEL  S5520UR  00000001 INTL 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x10 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x12 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x14 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x16 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x11 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x13 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x15 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x17 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x8fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x1efffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x1f0000000-0x36fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x8fffffff] + [mem 0x100000000-0x1efffffff] -> [mem 0x00000000-0x1efffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1efffffff]
[    0.000000]   NODE_DATA [mem 0x1efffb000-0x1efffffff]
[    0.000000] Initmem setup node 1 [mem 0x1f0000000-0x36fffffff]
[    0.000000]   NODE_DATA [mem 0x36fff0000-0x36fff4fff]
[    0.000000]  [ffffea0000000000-ffffea0007bfffff] PMD -> [ffff8801e9e00000-ffff8801efdfffff] on node 0
[    0.000000]  [ffffea0007c00000-ffffea000dbfffff] PMD -> [ffff880369600000-ffff88036f5fffff] on node 1
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x36fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
[    0.000000]   node   0: [mem 0x00100000-0x8c555fff]
[    0.000000]   node   0: [mem 0x100000000-0x1efffffff]
[    0.000000]   node   1: [mem 0x1f0000000-0x36fffffff]
[    0.000000] On node 0 totalpages: 1557743
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3993 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 8918 pages used for memmap
[    0.000000]   DMA32 zone: 570710 pages, LIFO batch:31
[    0.000000]   Normal zone: 15360 pages used for memmap
[    0.000000]   Normal zone: 983040 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 1572864
[    0.000000]   Normal zone: 24576 pages used for memmap
[    0.000000]   Normal zone: 1572864 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x16] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x17] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec90000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec90000, GSI 24-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a401 base: 0xfed00000
[    0.000000] smpboot: Allowing 24 CPUs, 8 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec90000)
[    0.000000] nr_irqs_gsi: 64
[    0.000000] PM: Registered nosave memory: [mem 0x0009a000-0x0009afff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x8c556000-0x8c628fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8c629000-0x8c701fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8c702000-0x8db01fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8db02000-0x8f601fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f602000-0x8f64efff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f64f000-0x8f6e5fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f6e6000-0x8f6effff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f6f0000-0x8f6f1fff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f6f2000-0x8f7cefff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f7cf000-0x8f7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x8f800000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0x9fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xa0000000-0xafffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xb0000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfcffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfd000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
[    0.000000] e820: [mem 0xb0000000-0xfbffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:24 nr_node_ids:2
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff8801e9c00000 s81088 r8192 d21312 u131072
[    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 -- -- -- -- 
[    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 -- -- -- -- 
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 3081668
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-ne04/cyclic_aim7-shell_rtns_1-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=1219 RESULT_ROOT=/lkp/result/lkp-ne04/micro/aim7/shell_rtns_1/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-ne04::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 12020544K/12522428K available (10556K kernel code, 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 501884K reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=24, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=24.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=24
[    0.000000] NR_IRQS:33024 nr_irqs:1280 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 50331648 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Disabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2926.286 MHz processor
[    0.000007] Calibrating delay loop (skipped), value calculated using timer frequency.. 5852.57 BogoMIPS (lpj=11705144)
[    0.012121] pid_max: default: 32768 minimum: 301
[    0.017361] ACPI: Core revision 20140214
[    0.034734] ACPI: All ACPI Tables successfully acquired
[    0.041824] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
[    0.053317] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.062962] Mount-cache hash table entries: 256
[    0.068631] Initializing cgroup subsys memory
[    0.073883] Initializing cgroup subsys devices
[    0.079229] Initializing cgroup subsys freezer
[    0.084585] Initializing cgroup subsys blkio
[    0.089743] Initializing cgroup subsys perf_event
[    0.095387] Initializing cgroup subsys hugetlb
[    0.100764] CPU: Physical Processor ID: 0
[    0.105632] CPU: Processor Core ID: 0
[    0.110116] mce: CPU supports 9 MCE banks
[    0.114995] CPU0: Thermal monitoring enabled (TM1)
[    0.120744] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.120744] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.120744] tlb_flushall_shift: 6
[    0.138651] Freeing SMP alternatives memory: 44K (ffffffff824a6000 - ffffffff824b1000)
[    0.149256] ftrace: allocating 40687 entries in 159 pages
[    0.171521] Getting VERSION: 60015
[    0.175713] Getting VERSION: 60015
[    0.179897] Getting ID: 0
[    0.183204] Getting ID: 0
[    0.186515] Switched APIC routing to physical flat.
[    0.192357] enabled ExtINT on CPU#0
[    0.196972] ENABLING IO-APIC IRQs
[    0.201056] init IO_APIC IRQs
[    0.204748]  apic 8 pin 0 not connected
[    0.209419] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
[    0.218985] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
[    0.228549] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    0.238113] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    0.247677] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
[    0.257233] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
[    0.266800] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
[    0.276336] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    0.285881] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
[    0.295445] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
[    0.305196] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
[    0.314941] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
[    0.324695] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    0.334439] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
[    0.344168] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
[    0.353911]  apic 8 pin 16 not connected
[    0.358674]  apic 8 pin 17 not connected
[    0.363436]  apic 8 pin 18 not connected
[    0.368181]  apic 8 pin 19 not connected
[    0.372947]  apic 8 pin 20 not connected
[    0.377712]  apic 8 pin 21 not connected
[    0.382454]  apic 8 pin 22 not connected
[    0.387222]  apic 8 pin 23 not connected
[    0.391979]  apic 9 pin 0 not connected
[    0.396635]  apic 9 pin 1 not connected
[    0.401294]  apic 9 pin 2 not connected
[    0.405951]  apic 9 pin 3 not connected
[    0.410610]  apic 9 pin 4 not connected
[    0.415281]  apic 9 pin 5 not connected
[    0.419946]  apic 9 pin 6 not connected
[    0.424605]  apic 9 pin 7 not connected
[    0.429274]  apic 9 pin 8 not connected
[    0.433943]  apic 9 pin 9 not connected
[    0.438599]  apic 9 pin 10 not connected
[    0.443358]  apic 9 pin 11 not connected
[    0.448117]  apic 9 pin 12 not connected
[    0.452869]  apic 9 pin 13 not connected
[    0.457625]  apic 9 pin 14 not connected
[    0.462379]  apic 9 pin 15 not connected
[    0.467123]  apic 9 pin 16 not connected
[    0.471874]  apic 9 pin 17 not connected
[    0.476635]  apic 9 pin 18 not connected
[    0.481392]  apic 9 pin 19 not connected
[    0.486156]  apic 9 pin 20 not connected
[    0.490923]  apic 9 pin 21 not connected
[    0.495675]  apic 9 pin 22 not connected
[    0.500437]  apic 9 pin 23 not connected
[    0.505327] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.552103] smpboot: CPU0: Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz (fam: 06, model: 1a, stepping: 05)
[    0.564091] Using local APIC timer interrupts.
[    0.564091] calibrating APIC timer ...
[    0.679778] ... lapic delta = 831337
[    0.684156] ... PM-Timer delta = 357951
[    0.688827] ... PM-Timer result ok
[    0.693008] ..... delta 831337
[    0.696801] ..... mult: 35705652
[    0.700788] ..... calibration result: 532055
[    0.705942] ..... CPU clock speed is 2926.1202 MHz.
[    0.711780] ..... host bus clock speed is 133.0055 MHz.
[    0.718017] Performance Events: PEBS fmt1+, 16-deep LBR, Nehalem events, Intel PMU driver.
[    0.728236] perf_event_intel: CPU erratum AAJ80 worked around
[    0.735034] perf_event_intel: CPUID marked event: 'bus cycles' unavailable
[    0.743098] ... version:                3
[    0.747953] ... bit width:              48
[    0.752899] ... generic registers:      4
[    0.757757] ... value mask:             0000ffffffffffff
[    0.764075] ... max period:             000000007fffffff
[    0.770397] ... fixed-purpose events:   3
[    0.775260] ... event mask:             000000070000000f
[    0.783126] x86: Booting SMP configuration:
[    0.788188] .... node  #1, CPUs:        #1
[    0.803790] masked ExtINT on CPU#1
[    0.906153] 
[    0.908188] .... node  #0, CPUs:    #2
[    0.923337] masked ExtINT on CPU#2
[    0.929518] 
[    0.931558] .... node  #1, CPUs:    #3
[    0.946604] masked ExtINT on CPU#3
[    0.952758] 
[    0.954795] .... node  #0, CPUs:    #4
[    0.969940] masked ExtINT on CPU#4
[    0.976119] 
[    0.978159] .... node  #1, CPUs:    #5
[    0.993304] masked ExtINT on CPU#5
[    0.999456] 
[    1.001499] .... node  #0, CPUs:    #6
[    1.016648] masked ExtINT on CPU#6
[    1.022840] 
[    1.024880] .... node  #1, CPUs:    #7
[    1.040029] masked ExtINT on CPU#7
[    1.046175] 
[    1.048209] .... node  #0, CPUs:    #8
[    1.063356] masked ExtINT on CPU#8
[    1.069547] 
[    1.071590] .... node  #1, CPUs:    #9
[    1.086735] masked ExtINT on CPU#9
[    1.092887] 
[    1.094927] .... node  #0, CPUs:   #10
[    1.110073] masked ExtINT on CPU#10
[    1.116356] 
[    1.118388] .... node  #1, CPUs:   #11
[    1.133535] masked ExtINT on CPU#11
[    1.139786] 
[    1.141832] .... node  #0, CPUs:   #12
[    1.156977] masked ExtINT on CPU#12
[    1.163267] 
[    1.165308] .... node  #1, CPUs:   #13
[    1.180355] masked ExtINT on CPU#13
[    1.186608] 
[    1.188641] .... node  #0, CPUs:   #14
[    1.203787] masked ExtINT on CPU#14
[    1.210072] 
[    1.212118] .... node  #1, CPUs:   #15
[    1.227263] masked ExtINT on CPU#15
[    1.233460] x86: Booted up 2 nodes, 16 CPUs
[    1.238812] smpboot: Total of 16 processors activated (93640.05 BogoMIPS)
[    1.257876] devtmpfs: initialized
[    1.266075] PM: Registering ACPI NVS region [mem 0x8c556000-0x8c628fff] (864256 bytes)
[    1.275660] PM: Registering ACPI NVS region [mem 0x8c702000-0x8db01fff] (20971520 bytes)
[    1.285878] PM: Registering ACPI NVS region [mem 0x8f6e6000-0x8f6effff] (40960 bytes)
[    1.295333] PM: Registering ACPI NVS region [mem 0x8f6f2000-0x8f7cefff] (905216 bytes)
[    1.306147] xor: measuring software checksum speed
[    1.350115]    prefetch64-sse: 11886.000 MB/sec
[    1.394121]    generic_sse: 10480.000 MB/sec
[    1.399277] xor: using function: prefetch64-sse (11886.000 MB/sec)
[    1.406576] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    1.414696] NET: Registered protocol family 16
[    1.420534] cpuidle: using governor ladder
[    1.425490] cpuidle: using governor menu
[    1.430655] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    1.439830] ACPI: bus type PCI registered
[    1.444697] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.452338] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xa0000000-0xafffffff] (base 0xa0000000)
[    1.463454] PCI: MMCONFIG at [mem 0xa0000000-0xafffffff] reserved in E820
[    1.482592] PCI: Using configuration type 1 for base access
[    1.558153] raid6: sse2x1    7066 MB/s
[    1.630161] raid6: sse2x2    8408 MB/s
[    1.702174] raid6: sse2x4    9588 MB/s
[    1.706750] raid6: using algorithm sse2x4 (9588 MB/s)
[    1.712785] raid6: using ssse3x2 recovery algorithm
[    1.718676] ACPI: Added _OSI(Module Device)
[    1.723741] ACPI: Added _OSI(Processor Device)
[    1.729092] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.734738] ACPI: Added _OSI(Processor Aggregator Device)
[    1.762725] ACPI Error: Field [CPB3] at 96 exceeds Buffer [NULL] size 64 (bits) (20140214/dsopcode-236)
[    1.774070] ACPI Error: Method parse/execution failed [\_SB_._OSC] (Node ffff8801e983d1b8), AE_AML_BUFFER_LIMIT (20140214/psparse-536)
[    1.790428] ACPI: Interpreter enabled
[    1.794904] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
[    1.806051] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20140214/hwxface-580)
[    1.817196] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20140214/hwxface-580)
[    1.828362] ACPI: (supports S0 S1 S5)
[    1.832837] ACPI: Using IOAPIC for interrupt routing
[    1.838826] HEST: Table parsing has been initialized.
[    1.844852] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.868995] ACPI: \_PR_.CPUG: failed to get CPU APIC ID.
[    1.875311] ACPI: \_PR_.CPUH: failed to get CPU APIC ID.
[    1.881632] ACPI: \_PR_.CPUI: failed to get CPU APIC ID.
[    1.887948] ACPI: \_PR_.CPUJ: failed to get CPU APIC ID.
[    1.894268] ACPI: \_PR_.CPUK: failed to get CPU APIC ID.
[    1.900592] ACPI: \_PR_.CPUL: failed to get CPU APIC ID.
[    1.906923] ACPI: \_PR_.CPUM: failed to get CPU APIC ID.
[    1.913245] ACPI: \_PR_.CPUN: failed to get CPU APIC ID.
[    1.919770] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fd])
[    1.927073] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.937046] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
[    1.947057] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
[    1.961997] PCI host bridge to bus 0000:00
[    1.966961] pci_bus 0000:00: root bus resource [bus 00-fd]
[    1.973475] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.980758] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.988056] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    1.996129] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
[    2.004202] pci_bus 0000:00: root bus resource [mem 0xb0000000-0xfdffffff]
[    2.012289] pci 0000:00:00.0: [8086:3406] type 00 class 0x060000
[    2.019430] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    2.026729] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
[    2.033872] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    2.041122] pci 0000:00:01.0: System wakeup disabled by ACPI
[    2.047877] pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
[    2.055028] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    2.062268] pci 0000:00:03.0: System wakeup disabled by ACPI
[    2.069027] pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
[    2.076169] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    2.083423] pci 0000:00:05.0: System wakeup disabled by ACPI
[    2.090168] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
[    2.097322] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    2.104562] pci 0000:00:07.0: System wakeup disabled by ACPI
[    2.111325] pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
[    2.118460] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    2.125714] pci 0000:00:09.0: System wakeup disabled by ACPI
[    2.132457] pci 0000:00:0a.0: [8086:3411] type 01 class 0x060400
[    2.139606] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    2.146857] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    2.153613] pci 0000:00:10.0: [8086:3425] type 00 class 0x080000
[    2.160820] pci 0000:00:10.1: [8086:3426] type 00 class 0x080000
[    2.168030] pci 0000:00:11.0: [8086:3427] type 00 class 0x080000
[    2.175235] pci 0000:00:11.1: [8086:3428] type 00 class 0x080000
[    2.182446] pci 0000:00:13.0: [8086:342d] type 00 class 0x080020
[    2.189544] pci 0000:00:13.0: reg 0x10: [mem 0xb1a24000-0xb1a24fff]
[    2.196980] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
[    2.204252] pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
[    2.211471] pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
[    2.218681] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
[    2.225899] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
[    2.233090] pci 0000:00:15.0: [8086:342f] type 00 class 0x080020
[    2.240301] pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
[    2.247409] pci 0000:00:16.0: reg 0x10: [mem 0xb1a00000-0xb1a03fff 64bit]
[    2.255518] pci 0000:00:16.1: [8086:3431] type 00 class 0x088000
[    2.262627] pci 0000:00:16.1: reg 0x10: [mem 0xb1a04000-0xb1a07fff 64bit]
[    2.270724] pci 0000:00:16.2: [8086:3432] type 00 class 0x088000
[    2.277835] pci 0000:00:16.2: reg 0x10: [mem 0xb1a08000-0xb1a0bfff 64bit]
[    2.285938] pci 0000:00:16.3: [8086:3433] type 00 class 0x088000
[    2.293048] pci 0000:00:16.3: reg 0x10: [mem 0xb1a0c000-0xb1a0ffff 64bit]
[    2.301149] pci 0000:00:16.4: [8086:3429] type 00 class 0x088000
[    2.308259] pci 0000:00:16.4: reg 0x10: [mem 0xb1a10000-0xb1a13fff 64bit]
[    2.316363] pci 0000:00:16.5: [8086:342a] type 00 class 0x088000
[    2.323463] pci 0000:00:16.5: reg 0x10: [mem 0xb1a14000-0xb1a17fff 64bit]
[    2.331554] pci 0000:00:16.6: [8086:342b] type 00 class 0x088000
[    2.338668] pci 0000:00:16.6: reg 0x10: [mem 0xb1a18000-0xb1a1bfff 64bit]
[    2.346761] pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
[    2.353876] pci 0000:00:16.7: reg 0x10: [mem 0xb1a1c000-0xb1a1ffff 64bit]
[    2.361979] pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
[    2.369117] pci 0000:00:1a.0: reg 0x20: [io  0x20e0-0x20ff]
[    2.375836] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    2.382595] pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
[    2.389734] pci 0000:00:1a.1: reg 0x20: [io  0x20c0-0x20df]
[    2.396448] pci 0000:00:1a.1: System wakeup disabled by ACPI
[    2.403208] pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
[    2.410345] pci 0000:00:1a.2: reg 0x20: [io  0x20a0-0x20bf]
[    2.417043] pci 0000:00:1a.2: System wakeup disabled by ACPI
[    2.423808] pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
[    2.430915] pci 0000:00:1a.7: reg 0x10: [mem 0xb1a22000-0xb1a223ff]
[    2.438392] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    2.445654] pci 0000:00:1a.7: System wakeup disabled by ACPI
[    2.452416] pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
[    2.459572] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    2.466831] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    2.473577] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400
[    2.480744] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    2.487994] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    2.494752] pci 0000:00:1c.5: [8086:3a4a] type 01 class 0x060400
[    2.501906] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    2.509158] pci 0000:00:1c.5: System wakeup disabled by ACPI
[    2.515904] pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
[    2.523036] pci 0000:00:1d.0: reg 0x20: [io  0x2080-0x209f]
[    2.529740] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    2.536501] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
[    2.543642] pci 0000:00:1d.1: reg 0x20: [io  0x2060-0x207f]
[    2.550357] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    2.557114] pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
[    2.564251] pci 0000:00:1d.2: reg 0x20: [io  0x2040-0x205f]
[    2.570961] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    2.577728] pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
[    2.584845] pci 0000:00:1d.7: reg 0x10: [mem 0xb1a21000-0xb1a213ff]
[    2.592311] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    2.599573] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    2.606337] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    2.613521] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    2.620280] pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
[    2.627449] pci 0000:00:1f.0: can't claim BAR 13 [io  0x0400-0x047f]: address conflict with ACPI CPU throttle [??? 0x00000410-0x00000415 flags 0x80000000]
[    2.643625] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
[    2.651991] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 000f)
[    2.661151] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
[    2.670320] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0600 (mask 001f)
[    2.679607] pci 0000:00:1f.2: [8086:3a22] type 00 class 0x010601
[    2.686724] pci 0000:00:1f.2: reg 0x10: [io  0x2108-0x210f]
[    2.693351] pci 0000:00:1f.2: reg 0x14: [io  0x2114-0x2117]
[    2.699972] pci 0000:00:1f.2: reg 0x18: [io  0x2100-0x2107]
[    2.706596] pci 0000:00:1f.2: reg 0x1c: [io  0x2110-0x2113]
[    2.713221] pci 0000:00:1f.2: reg 0x20: [io  0x2020-0x203f]
[    2.719842] pci 0000:00:1f.2: reg 0x24: [mem 0xb1a20000-0xb1a207ff]
[    2.727278] pci 0000:00:1f.2: PME# supported from D3hot
[    2.733592] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
[    2.740704] pci 0000:00:1f.3: reg 0x10: [mem 0xb1a23000-0xb1a230ff 64bit]
[    2.748700] pci 0000:00:1f.3: reg 0x20: [io  0x2000-0x201f]
[    2.755479] pci 0000:01:00.0: [8086:10a7] type 00 class 0x020000
[    2.762587] pci 0000:01:00.0: reg 0x10: [mem 0xb1920000-0xb193ffff]
[    2.769983] pci 0000:01:00.0: reg 0x18: [io  0x1020-0x103f]
[    2.776595] pci 0000:01:00.0: reg 0x1c: [mem 0xb1944000-0xb1947fff]
[    2.784048] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[    2.791270] pci 0000:01:00.0: System wakeup disabled by ACPI
[    2.798035] pci 0000:01:00.1: [8086:10a7] type 00 class 0x020000
[    2.805147] pci 0000:01:00.1: reg 0x10: [mem 0xb1900000-0xb191ffff]
[    2.812555] pci 0000:01:00.1: reg 0x18: [io  0x1000-0x101f]
[    2.819175] pci 0000:01:00.1: reg 0x1c: [mem 0xb1940000-0xb1943fff]
[    2.826632] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[    2.833850] pci 0000:01:00.1: System wakeup disabled by ACPI
[    2.841326] pci 0000:00:01.0: PCI bridge to [bus 01]
[    2.847263] pci 0000:00:01.0:   bridge window [io  0x1000-0x1fff]
[    2.854455] pci 0000:00:01.0:   bridge window [mem 0xb1900000-0xb19fffff]
[    2.862464] pci 0000:00:03.0: PCI bridge to [bus 02]
[    2.868438] pci 0000:00:05.0: PCI bridge to [bus 03]
[    2.874418] pci 0000:00:07.0: PCI bridge to [bus 04]
[    2.880421] pci 0000:00:09.0: PCI bridge to [bus 05]
[    2.886403] pci 0000:00:0a.0: PCI bridge to [bus 06]
[    2.892400] pci 0000:00:1c.0: PCI bridge to [bus 07]
[    2.898324] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    2.905524] pci 0000:00:1c.0:   bridge window [mem 0xb1b00000-0xb1cfffff]
[    2.913503] pci 0000:00:1c.0:   bridge window [mem 0xb1d00000-0xb1efffff 64bit pref]
[    2.922938] pci 0000:08:00.0: [102b:0522] type 00 class 0x030000
[    2.930055] pci 0000:08:00.0: reg 0x10: [mem 0xb0000000-0xb0ffffff pref]
[    2.937950] pci 0000:08:00.0: reg 0x14: [mem 0xb1800000-0xb1803fff]
[    2.945345] pci 0000:08:00.0: reg 0x18: [mem 0xb1000000-0xb17fffff]
[    2.952770] pci 0000:08:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    2.966400] pci 0000:00:1c.4: PCI bridge to [bus 08]
[    2.972337] pci 0000:00:1c.4:   bridge window [io  0x4000-0x4fff]
[    2.979537] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
[    2.987520] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
[    2.996936] pci 0000:00:1c.5: PCI bridge to [bus 09]
[    3.002868] pci 0000:00:1c.5:   bridge window [io  0x5000-0x5fff]
[    3.010066] pci 0000:00:1c.5:   bridge window [mem 0xb1f00000-0xb20fffff]
[    3.018044] pci 0000:00:1c.5:   bridge window [mem 0xb2100000-0xb22fffff 64bit pref]
[    3.027462] pci 0000:00:1e.0: PCI bridge to [bus 0a] (subtractive decode)
[    3.035447] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    3.044990] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    3.054546] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    3.064886] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
[    3.075219] pci 0000:00:1e.0:   bridge window [mem 0xb0000000-0xfdffffff] (subtractive decode)
[    3.085579] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
[    3.102393] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
[    3.112087] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
[    3.121803] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
[    3.131517] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
[    3.141241] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    3.152359] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    3.163431] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    3.174526] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    3.185773] ACPI: Enabled 1 GPEs in block 00 to 3F
[    3.191812] vgaarb: device added: PCI:0000:08:00.0,decodes=io+mem,owns=io+mem,locks=none
[    3.201550] vgaarb: loaded
[    3.204957] vgaarb: bridge control possible 0000:08:00.0
[    3.211369] SCSI subsystem initialized
[    3.216013] libata version 3.00 loaded.
[    3.220733] ACPI: bus type USB registered
[    3.225619] usbcore: registered new interface driver usbfs
[    3.232143] usbcore: registered new interface driver hub
[    3.238488] usbcore: registered new device driver usb
[    3.244544] pps_core: LinuxPPS API ver. 1 registered
[    3.250471] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    3.261392] PTP clock support registered
[    3.266260] EDAC MC: Ver: 3.0.0
[    3.270307] PCI: Using ACPI for IRQ routing
[    3.280650] PCI: Discovered peer bus fe
[    3.285321] PCI: root bus fe: using default resources
[    3.291356] PCI: Probing PCI hardware (bus fe)
[    3.296724] PCI host bridge to bus 0000:fe
[    3.301680] pci_bus 0000:fe: root bus resource [io  0x0000-0xffff]
[    3.308967] pci_bus 0000:fe: root bus resource [mem 0x00000000-0xffffffffff]
[    3.317226] pci_bus 0000:fe: No busn resource found for root bus, will use [bus fe-ff]
[    3.326774] pci 0000:fe:00.0: [8086:2c40] type 00 class 0x060000
[    3.333930] pci 0000:fe:00.1: [8086:2c01] type 00 class 0x060000
[    3.341071] pci 0000:fe:02.0: [8086:2c10] type 00 class 0x060000
[    3.348222] pci 0000:fe:02.1: [8086:2c11] type 00 class 0x060000
[    3.355357] pci 0000:fe:02.4: [8086:2c14] type 00 class 0x060000
[    3.362508] pci 0000:fe:02.5: [8086:2c15] type 00 class 0x060000
[    3.369643] pci 0000:fe:03.0: [8086:2c18] type 00 class 0x060000
[    3.376793] pci 0000:fe:03.1: [8086:2c19] type 00 class 0x060000
[    3.383929] pci 0000:fe:03.2: [8086:2c1a] type 00 class 0x060000
[    3.391079] pci 0000:fe:03.4: [8086:2c1c] type 00 class 0x060000
[    3.398219] pci 0000:fe:04.0: [8086:2c20] type 00 class 0x060000
[    3.405368] pci 0000:fe:04.1: [8086:2c21] type 00 class 0x060000
[    3.412506] pci 0000:fe:04.2: [8086:2c22] type 00 class 0x060000
[    3.419656] pci 0000:fe:04.3: [8086:2c23] type 00 class 0x060000
[    3.426803] pci 0000:fe:05.0: [8086:2c28] type 00 class 0x060000
[    3.433954] pci 0000:fe:05.1: [8086:2c29] type 00 class 0x060000
[    3.441097] pci 0000:fe:05.2: [8086:2c2a] type 00 class 0x060000
[    3.448250] pci 0000:fe:05.3: [8086:2c2b] type 00 class 0x060000
[    3.455398] pci 0000:fe:06.0: [8086:2c30] type 00 class 0x060000
[    3.462549] pci 0000:fe:06.1: [8086:2c31] type 00 class 0x060000
[    3.469695] pci 0000:fe:06.2: [8086:2c32] type 00 class 0x060000
[    3.476846] pci 0000:fe:06.3: [8086:2c33] type 00 class 0x060000
[    3.484002] pci_bus 0000:fe: busn_res: [bus fe-ff] end is updated to fe
[    3.491790] PCI: Discovered peer bus ff
[    3.496457] PCI: root bus ff: using default resources
[    3.502480] PCI: Probing PCI hardware (bus ff)
[    3.507857] PCI host bridge to bus 0000:ff
[    3.512818] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[    3.520113] pci_bus 0000:ff: root bus resource [mem 0x00000000-0xffffffffff]
[    3.528387] pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
[    3.537953] pci 0000:ff:00.0: [8086:2c40] type 00 class 0x060000
[    3.545104] pci 0000:ff:00.1: [8086:2c01] type 00 class 0x060000
[    3.552244] pci 0000:ff:02.0: [8086:2c10] type 00 class 0x060000
[    3.559383] pci 0000:ff:02.1: [8086:2c11] type 00 class 0x060000
[    3.566532] pci 0000:ff:02.4: [8086:2c14] type 00 class 0x060000
[    3.573671] pci 0000:ff:02.5: [8086:2c15] type 00 class 0x060000
[    3.580815] pci 0000:ff:03.0: [8086:2c18] type 00 class 0x060000
[    3.587967] pci 0000:ff:03.1: [8086:2c19] type 00 class 0x060000
[    3.595113] pci 0000:ff:03.2: [8086:2c1a] type 00 class 0x060000
[    3.602257] pci 0000:ff:03.4: [8086:2c1c] type 00 class 0x060000
[    3.609404] pci 0000:ff:04.0: [8086:2c20] type 00 class 0x060000
[    3.616554] pci 0000:ff:04.1: [8086:2c21] type 00 class 0x060000
[    3.623704] pci 0000:ff:04.2: [8086:2c22] type 00 class 0x060000
[    3.630855] pci 0000:ff:04.3: [8086:2c23] type 00 class 0x060000
[    3.638006] pci 0000:ff:05.0: [8086:2c28] type 00 class 0x060000
[    3.645154] pci 0000:ff:05.1: [8086:2c29] type 00 class 0x060000
[    3.652305] pci 0000:ff:05.2: [8086:2c2a] type 00 class 0x060000
[    3.659451] pci 0000:ff:05.3: [8086:2c2b] type 00 class 0x060000
[    3.666591] pci 0000:ff:06.0: [8086:2c30] type 00 class 0x060000
[    3.673734] pci 0000:ff:06.1: [8086:2c31] type 00 class 0x060000
[    3.680882] pci 0000:ff:06.2: [8086:2c32] type 00 class 0x060000
[    3.688028] pci 0000:ff:06.3: [8086:2c33] type 00 class 0x060000
[    3.695185] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
[    3.702683] PCI: pci_cache_line_size set to 64 bytes
[    3.708728] e820: reserve RAM buffer [mem 0x0009a400-0x0009ffff]
[    3.715834] e820: reserve RAM buffer [mem 0x8c556000-0x8fffffff]
[    3.723467] HPET: 4 timers in total, 0 timers will be used for per-cpu timer
[    3.731742] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    3.738212] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    3.747984] Switched to clocksource hpet
[    3.752831] Could not create debugfs 'set_ftrace_filter' entry
[    3.759741] Could not create debugfs 'set_ftrace_notrace' entry
[    3.776586] pnp: PnP ACPI init
[    3.780402] ACPI: bus type PNP registered
[    3.785345] pnp 00:00: Plug and Play ACPI device, IDs PNP0003 (active)
[    3.793202] pnp 00:01: [dma 4]
[    3.797029] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    3.804733] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    3.814329] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    3.822025] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    3.831804] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    3.839524] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    3.847281] pnp 00:05: Plug and Play ACPI device, IDs PNP0103 (active)
[    3.855074] system 00:06: [io  0x0500-0x057f] could not be reserved
[    3.862467] system 00:06: [io  0x0400-0x047f] could not be reserved
[    3.869863] system 00:06: [io  0x0800-0x081f] has been reserved
[    3.876867] system 00:06: [io  0x0ca2-0x0ca3] has been reserved
[    3.883872] system 00:06: [io  0x0600-0x061f] has been reserved
[    3.890880] system 00:06: [io  0x0880-0x0883] has been reserved
[    3.897889] system 00:06: [io  0x0ca4-0x0ca5] has been reserved
[    3.904897] system 00:06: [mem 0xfed1c000-0xfed3fffe] could not be reserved
[    3.913063] system 00:06: [mem 0xff000000-0xffffffff] could not be reserved
[    3.921234] system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
[    3.929008] system 00:06: [mem 0xfe900000-0xfe90001f] has been reserved
[    3.936781] system 00:06: [mem 0xfea00000-0xfea0001f] has been reserved
[    3.944550] system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
[    3.952321] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.960410] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    3.970037] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
[    3.977829] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    3.987456] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    3.995197] pnp 00:09: Plug and Play ACPI device, IDs IPI0001 (active)
[    4.002931] pnp: PnP ACPI: found 10 devices
[    4.007983] ACPI: bus type PNP unregistered
[    4.019732] pci 0000:08:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    4.031589] pci 0000:00:1f.0: BAR 13: [io  0x0400-0x047f] has bogus alignment
[    4.039949] pci 0000:00:01.0: PCI bridge to [bus 01]
[    4.045891] pci 0000:00:01.0:   bridge window [io  0x1000-0x1fff]
[    4.053094] pci 0000:00:01.0:   bridge window [mem 0xb1900000-0xb19fffff]
[    4.061075] pci 0000:00:03.0: PCI bridge to [bus 02]
[    4.067020] pci 0000:00:05.0: PCI bridge to [bus 03]
[    4.072964] pci 0000:00:07.0: PCI bridge to [bus 04]
[    4.078892] pci 0000:00:09.0: PCI bridge to [bus 05]
[    4.084829] pci 0000:00:0a.0: PCI bridge to [bus 06]
[    4.090766] pci 0000:00:1c.0: PCI bridge to [bus 07]
[    4.096699] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    4.103893] pci 0000:00:1c.0:   bridge window [mem 0xb1b00000-0xb1cfffff]
[    4.111873] pci 0000:00:1c.0:   bridge window [mem 0xb1d00000-0xb1efffff 64bit pref]
[    4.121229] pci 0000:08:00.0: BAR 6: assigned [mem 0xb1810000-0xb181ffff pref]
[    4.130011] pci 0000:00:1c.4: PCI bridge to [bus 08]
[    4.135941] pci 0000:00:1c.4:   bridge window [io  0x4000-0x4fff]
[    4.143145] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
[    4.151112] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
[    4.160484] pci 0000:00:1c.5: PCI bridge to [bus 09]
[    4.166424] pci 0000:00:1c.5:   bridge window [io  0x5000-0x5fff]
[    4.173628] pci 0000:00:1c.5:   bridge window [mem 0xb1f00000-0xb20fffff]
[    4.181607] pci 0000:00:1c.5:   bridge window [mem 0xb2100000-0xb22fffff 64bit pref]
[    4.190958] pci 0000:00:1e.0: PCI bridge to [bus 0a]
[    4.196894] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    4.203510] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    4.210124] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    4.217522] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
[    4.224916] pci_bus 0000:00: resource 8 [mem 0xb0000000-0xfdffffff]
[    4.232312] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
[    4.238928] pci_bus 0000:01: resource 1 [mem 0xb1900000-0xb19fffff]
[    4.246317] pci_bus 0000:07: resource 0 [io  0x3000-0x3fff]
[    4.252933] pci_bus 0000:07: resource 1 [mem 0xb1b00000-0xb1cfffff]
[    4.260328] pci_bus 0000:07: resource 2 [mem 0xb1d00000-0xb1efffff 64bit pref]
[    4.277043] pci_bus 0000:08: resource 0 [io  0x4000-0x4fff]
[    4.283649] pci_bus 0000:08: resource 1 [mem 0xb1000000-0xb18fffff]
[    4.291034] pci_bus 0000:08: resource 2 [mem 0xb0000000-0xb0ffffff 64bit pref]
[    4.299807] pci_bus 0000:09: resource 0 [io  0x5000-0x5fff]
[    4.306418] pci_bus 0000:09: resource 1 [mem 0xb1f00000-0xb20fffff]
[    4.313811] pci_bus 0000:09: resource 2 [mem 0xb2100000-0xb22fffff 64bit pref]
[    4.322568] pci_bus 0000:0a: resource 4 [io  0x0000-0x0cf7]
[    4.329184] pci_bus 0000:0a: resource 5 [io  0x0d00-0xffff]
[    4.335792] pci_bus 0000:0a: resource 6 [mem 0x000a0000-0x000bffff]
[    4.343188] pci_bus 0000:0a: resource 7 [mem 0xfed40000-0xfedfffff]
[    4.350571] pci_bus 0000:0a: resource 8 [mem 0xb0000000-0xfdffffff]
[    4.357971] pci_bus 0000:fe: resource 4 [io  0x0000-0xffff]
[    4.364583] pci_bus 0000:fe: resource 5 [mem 0x00000000-0xffffffffff]
[    4.372175] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
[    4.378779] pci_bus 0000:ff: resource 5 [mem 0x00000000-0xffffffffff]
[    4.386412] NET: Registered protocol family 2
[    4.391891] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    4.401135] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    4.409183] TCP: Hash tables configured (established 131072 bind 65536)
[    4.416991] TCP: reno registered
[    4.420989] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    4.428251] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    4.436050] NET: Registered protocol family 1
[    4.441411] RPC: Registered named UNIX socket transport module.
[    4.448408] RPC: Registered udp transport module.
[    4.454049] RPC: Registered tcp transport module.
[    4.459688] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    4.520311] IOAPIC[0]: Set routing entry (8-19 -> 0x41 -> IRQ 19 Mode:1 Active:1 Dest:0)
[    4.530996] IOAPIC[0]: Set routing entry (8-16 -> 0x51 -> IRQ 16 Mode:1 Active:1 Dest:0)
[    4.541560] pci 0000:01:00.0: Disabling L0s
[    4.546610] pci 0000:01:00.0: can't disable ASPM; OS doesn't have ASPM control
[    4.555378] pci 0000:01:00.1: Disabling L0s
[    4.560426] pci 0000:01:00.1: can't disable ASPM; OS doesn't have ASPM control
[    4.569221] pci 0000:08:00.0: Boot video device
[    4.574699] PCI: CLS 64 bytes, default 64
[    4.579599] Trying to unpack rootfs image as initramfs...
[    8.232342] Freeing initrd memory: 213136K (ffff880072fd1000 - ffff88007fff5000)
[    8.241336] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    8.248935] software IO TLB [mem 0x88556000-0x8c556000] (64MB) mapped at [ffff880088556000-ffff88008c555fff]
[    8.261272] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work properly. Using workaround
[    8.272302] Scanning for low memory corruption every 60 seconds
[    8.280640] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
[    8.287978] PCLMULQDQ-NI instructions are not detected.
[    8.294209] AVX or AES-NI instructions are not detected.
[    8.300523] AVX instructions are not detected.
[    8.305873] AVX instructions are not detected.
[    8.311222] AVX instructions are not detected.
[    8.316568] AVX instructions are not detected.
[    8.322502] futex hash table entries: 8192 (order: 7, 524288 bytes)
[    8.352119] bounce pool size: 64 pages
[    8.356698] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    8.366371] VFS: Disk quotas dquot_6.5.2
[    8.371195] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    8.379668] NFS: Registering the id_resolver key type
[    8.385701] Key type id_resolver registered
[    8.390756] Key type id_legacy registered
[    8.395624] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    8.403504] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    8.411293] ROMFS MTD (C) 2007 Red Hat, Inc.
[    8.416517] fuse init (API version 7.22)
[    8.421421] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[    8.433300] msgmni has been set to 23893
[    8.440540] NET: Registered protocol family 38
[    8.445894] Key type asymmetric registered
[    8.450898] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    8.459919] io scheduler noop registered
[    8.464680] io scheduler deadline registered
[    8.469831] io scheduler cfq registered (default)
[    8.475788] IOAPIC[1]: Set routing entry (9-4 -> 0x61 -> IRQ 28 Mode:1 Active:1 Dest:0)
[    8.485476] pcieport 0000:00:01.0: irq 64 for MSI/MSI-X
[    8.491889] IOAPIC[1]: Set routing entry (9-0 -> 0x81 -> IRQ 24 Mode:1 Active:1 Dest:0)
[    8.501563] pcieport 0000:00:03.0: irq 65 for MSI/MSI-X
[    8.507972] IOAPIC[1]: Set routing entry (9-2 -> 0xa1 -> IRQ 26 Mode:1 Active:1 Dest:0)
[    8.517654] pcieport 0000:00:05.0: irq 66 for MSI/MSI-X
[    8.524049] IOAPIC[1]: Set routing entry (9-6 -> 0xc1 -> IRQ 30 Mode:1 Active:1 Dest:0)
[    8.533713] pcieport 0000:00:07.0: irq 67 for MSI/MSI-X
[    8.540111] IOAPIC[1]: Set routing entry (9-8 -> 0xe1 -> IRQ 32 Mode:1 Active:1 Dest:0)
[    8.549784] pcieport 0000:00:09.0: irq 68 for MSI/MSI-X
[    8.556187] IOAPIC[1]: Set routing entry (9-9 -> 0x42 -> IRQ 33 Mode:1 Active:1 Dest:0)
[    8.565868] pcieport 0000:00:0a.0: irq 69 for MSI/MSI-X
[    8.572308] pcieport 0000:00:1c.0: irq 70 for MSI/MSI-X
[    8.578763] pcieport 0000:00:1c.4: irq 71 for MSI/MSI-X
[    8.585190] IOAPIC[0]: Set routing entry (8-17 -> 0x82 -> IRQ 17 Mode:1 Active:1 Dest:0)
[    8.594965] pcieport 0000:00:1c.5: irq 72 for MSI/MSI-X
[    8.601314] aer 0000:00:01.0:pcie02: service driver aer loaded
[    8.608236] aer 0000:00:03.0:pcie02: service driver aer loaded
[    8.615159] aer 0000:00:05.0:pcie02: service driver aer loaded
[    8.622090] aer 0000:00:07.0:pcie02: service driver aer loaded
[    8.629028] aer 0000:00:09.0:pcie02: service driver aer loaded
[    8.635956] aer 0000:00:0a.0:pcie02: service driver aer loaded
[    8.642880] pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
[    8.651060] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    8.658748] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[    8.666433] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
[    8.674323] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[    8.682495] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[    8.690376] pcieport 0000:00:05.0: Signaling PME through PCIe PME interrupt
[    8.698542] pcie_pme 0000:00:05.0:pcie01: service driver pcie_pme loaded
[    8.706430] pcieport 0000:00:07.0: Signaling PME through PCIe PME interrupt
[    8.714594] pcie_pme 0000:00:07.0:pcie01: service driver pcie_pme loaded
[    8.722472] pcieport 0000:00:09.0: Signaling PME through PCIe PME interrupt
[    8.730643] pcie_pme 0000:00:09.0:pcie01: service driver pcie_pme loaded
[    8.738535] pcieport 0000:00:0a.0: Signaling PME through PCIe PME interrupt
[    8.746709] pcie_pme 0000:00:0a.0:pcie01: service driver pcie_pme loaded
[    8.754608] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[    8.762783] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[    8.770667] pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
[    8.778844] pci 0000:08:00.0: Signaling PME through PCIe PME interrupt
[    8.786531] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
[    8.794426] pcieport 0000:00:1c.5: Signaling PME through PCIe PME interrupt
[    8.802603] pcie_pme 0000:00:1c.5:pcie01: service driver pcie_pme loaded
[    8.810498] ioapic: probe of 0000:00:13.0 failed with error -22
[    8.817513] ioapic: probe of 0000:00:15.0 failed with error -22
[    8.824535] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    8.831200] pciehp 0000:00:1c.0:pcie04: Slot #1 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
[    8.843837] pciehp 0000:00:1c.0:pcie04: service driver pciehp loaded
[    8.851349] pciehp 0000:00:1c.4:pcie04: Slot #5 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
[    8.863973] pciehp 0000:00:1c.4:pcie04: service driver pciehp loaded
[    8.871474] pciehp 0000:00:1c.5:pcie04: Slot #6 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
[    8.884096] pciehp 0000:00:1c.5:pcie04: service driver pciehp loaded
[    8.891598] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    8.899376] intel_idle: MWAIT substates: 0x1120
[    8.904848] intel_idle: v0.4 model 0x1A
[    8.909513] intel_idle: lapic_timer_reliable_states 0x2
[    8.916415] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
[    8.926471] ACPI: Sleep Button [SLPB]
[    8.930996] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    8.939977] ACPI: Power Button [PWRF]
[    8.944534] ERST: Error Record Serialization Table (ERST) support is initialized.
[    8.953606] pstore: Registered erst as persistent store backend
[    8.960871] ghes_edac: This EDAC driver relies on BIOS to enumerate memory and get error reports.
[    8.971511] ghes_edac: Unfortunately, not all BIOSes reflect the memory layout correctly.
[    8.981356] ghes_edac: So, the end result of using this driver varies from vendor to vendor.
[    8.991507] ghes_edac: If you find incorrect reports, please contact your hardware vendor
[    9.001358] ghes_edac: to correct its BIOS.
[    9.006412] ghes_edac: This system has 12 DIMM sockets.
[    9.013136] EDAC MC0: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
[    9.024738] EDAC MC1: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
[    9.036452] GHES: APEI firmware first mode is enabled by WHEA _OSC.
[    9.043850] EINJ: Error INJection is initialized.
[    9.049581] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    9.077422] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    9.106753] 00:08: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[    9.116114] Non-volatile memory driver v1.3
[    9.123022] brd: module loaded
[    9.127705] loop: module loaded
[    9.139586] lkdtm: No crash points registered, enable through debugfs
[    9.147224] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0) (20140214/utaddress-258)
[    9.165708] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    9.177795] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000052f (\_SI_.SIOR) (20140214/utaddress-258)
[    9.196754] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    9.208856] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    9.216209] Loading iSCSI transport class v2.0-870.
[    9.222294] Adaptec aacraid driver 1.2-0[30300]-ms
[    9.228054] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    9.236082] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.02-k.
[    9.245964] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    9.254928] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    9.263130] megasas: 06.803.01.00-rc1 Mon. Mar. 10 17:00:00 PDT 2014
[    9.270634] tsc: Refined TSC clocksource calibration: 2926.329 MHz
[    9.277978] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    9.285198] RocketRAID 3xxx/4xxx Controller driver v1.8
[    9.291521] ahci 0000:00:1f.2: version 3.0
[    9.296615] IOAPIC[0]: Set routing entry (8-18 -> 0xa2 -> IRQ 18 Mode:1 Active:1 Dest:0)
[    9.306410] ahci 0000:00:1f.2: irq 73 for MSI/MSI-X
[    9.312284] ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0xa impl SATA mode
[    9.322042] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ccc 
[    9.331945] scsi0 : ahci
[    9.335298] scsi1 : ahci
[    9.338644] scsi2 : ahci
[    9.341995] scsi3 : ahci
[    9.345337] scsi4 : ahci
[    9.348663] scsi5 : ahci
[    9.351936] ata1: DUMMY
[    9.355056] ata2: SATA max UDMA/133 abar m2048@0xb1a20000 port 0xb1a20180 irq 73
[    9.364020] ata3: DUMMY
[    9.367129] ata4: SATA max UDMA/133 abar m2048@0xb1a20000 port 0xb1a20280 irq 73
[    9.376103] ata5: DUMMY
[    9.379215] ata6: DUMMY
[    9.382472] tun: Universal TUN/TAP device driver, 1.6
[    9.388544] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    9.396008] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[    9.404137] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    9.410568] Copyright (c) 2007 Atheros Corporation.
[    9.416536] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[    9.424430] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[    9.424430]   http://www.scyld.com/network/drivers.html
[    9.438949] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[    9.447066] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    9.454271] e100: Copyright(c) 1999-2006 Intel Corporation
[    9.460808] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    9.469085] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    9.475915] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    9.482830] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
[    9.489868] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
[    9.498048] igb: Copyright (c) 2007-2014 Intel Corporation.
[    9.504706] IOAPIC[1]: Set routing entry (9-16 -> 0xc2 -> IRQ 40 Mode:1 Active:1 Dest:0)
[    9.514676] igb 0000:01:00.0: irq 74 for MSI/MSI-X
[    9.520414] igb 0000:01:00.0: irq 75 for MSI/MSI-X
[    9.526149] igb 0000:01:00.0: irq 76 for MSI/MSI-X
[    9.531889] igb 0000:01:00.0: irq 77 for MSI/MSI-X
[    9.537633] igb 0000:01:00.0: irq 78 for MSI/MSI-X
[    9.543381] igb 0000:01:00.0: irq 79 for MSI/MSI-X
[    9.549125] igb 0000:01:00.0: irq 80 for MSI/MSI-X
[    9.554873] igb 0000:01:00.0: irq 81 for MSI/MSI-X
[    9.560616] igb 0000:01:00.0: irq 82 for MSI/MSI-X
[    9.566420] igb 0000:01:00.0: irq 74 for MSI/MSI-X
[    9.572167] igb 0000:01:00.0: irq 75 for MSI/MSI-X
[    9.577904] igb 0000:01:00.0: irq 76 for MSI/MSI-X
[    9.583644] igb 0000:01:00.0: irq 77 for MSI/MSI-X
[    9.589379] igb 0000:01:00.0: irq 78 for MSI/MSI-X
[    9.595113] igb 0000:01:00.0: irq 79 for MSI/MSI-X
[    9.600857] igb 0000:01:00.0: irq 80 for MSI/MSI-X
[    9.606597] igb 0000:01:00.0: irq 81 for MSI/MSI-X
[    9.612336] igb 0000:01:00.0: irq 82 for MSI/MSI-X
[    9.701321] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    9.708640] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    9.716144] ata2.00: ATA-8: ST3500514NS, SN11, max UDMA/133
[    9.722823] ata2.00: 976773168 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    9.730785] ata4.00: ATA-6: ST3120026AS, 3.00, max UDMA/133
[    9.737410] ata4.00: 234441648 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    9.746721] ata2.00: configured for UDMA/133
[    9.752035] ata4.00: configured for UDMA/133
[    9.752149] scsi 1:0:0:0: Direct-Access     ATA      ST3500514NS      SN11 PQ: 0 ANSI: 5
[    9.752406] sd 1:0:0:0: Attached scsi generic sg0 type 0
[    9.752451] sd 1:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    9.752481] sd 1:0:0:0: [sda] Write Protect is off
[    9.752482] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    9.752496] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    9.804936]  sda: sda1 sda2 sda3
[    9.805338] scsi 3:0:0:0: Direct-Access     ATA      ST3120026AS      3.00 PQ: 0 ANSI: 5
[    9.805507] sd 3:0:0:0: Attached scsi generic sg1 type 0
[    9.805534] sd 3:0:0:0: [sdb] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[    9.805567] sd 3:0:0:0: [sdb] Write Protect is off
[    9.805569] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    9.805585] sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    9.812014] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
[    9.812017] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:15:17:e6:9d:cc
[    9.812019] igb 0000:01:00.0: eth0: PBA No: Unknown
[    9.812023] igb 0000:01:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
[    9.812323] igb 0000:01:00.1: irq 83 for MSI/MSI-X
[    9.812328] igb 0000:01:00.1: irq 84 for MSI/MSI-X
[    9.812332] igb 0000:01:00.1: irq 85 for MSI/MSI-X
[    9.812336] igb 0000:01:00.1: irq 86 for MSI/MSI-X
[    9.812340] igb 0000:01:00.1: irq 87 for MSI/MSI-X
[    9.812344] igb 0000:01:00.1: irq 88 for MSI/MSI-X
[    9.812348] igb 0000:01:00.1: irq 89 for MSI/MSI-X
[    9.812352] igb 0000:01:00.1: irq 90 for MSI/MSI-X
[    9.812355] igb 0000:01:00.1: irq 91 for MSI/MSI-X
[    9.812408] igb 0000:01:00.1: irq 83 for MSI/MSI-X
[    9.812412] igb 0000:01:00.1: irq 84 for MSI/MSI-X
[    9.812415] igb 0000:01:00.1: irq 85 for MSI/MSI-X
[    9.812419] igb 0000:01:00.1: irq 86 for MSI/MSI-X
[    9.812423] igb 0000:01:00.1: irq 87 for MSI/MSI-X
[    9.812426] igb 0000:01:00.1: irq 88 for MSI/MSI-X
[    9.812430] igb 0000:01:00.1: irq 89 for MSI/MSI-X
[    9.812434] igb 0000:01:00.1: irq 90 for MSI/MSI-X
[    9.812437] igb 0000:01:00.1: irq 91 for MSI/MSI-X
[    9.826770]  sdb: sdb1 sdb2 sdb3
[    9.827075] sd 3:0:0:0: [sdb] Attached SCSI disk
[   10.001064] sd 1:0:0:0: [sda] Attached SCSI disk
[   10.001760] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
[   10.001761] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:15:17:e6:9d:cd
[   10.001763] igb 0000:01:00.1: eth1: PBA No: Unknown
[   10.001764] igb 0000:01:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
[   10.001786] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.19.1-k
[   10.001789] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[   10.001817] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   10.001818] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   10.001861] sky2: driver version 1.30
[   10.002072] usbcore: registered new interface driver catc
[   10.002087] usbcore: registered new interface driver kaweth
[   10.002088] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
[   10.002099] usbcore: registered new interface driver pegasus
[   10.002110] usbcore: registered new interface driver rtl8150
[   10.002128] usbcore: registered new interface driver asix
[   10.002139] usbcore: registered new interface driver ax88179_178a
[   10.002152] usbcore: registered new interface driver cdc_ether
[   10.002169] usbcore: registered new interface driver cdc_eem
[   10.002185] usbcore: registered new interface driver dm9601
[   10.002199] usbcore: registered new interface driver smsc75xx
[   10.002216] usbcore: registered new interface driver smsc95xx
[   10.002228] usbcore: registered new interface driver gl620a
[   10.002244] usbcore: registered new interface driver net1080
[   10.002259] usbcore: registered new interface driver plusb
[   10.002273] usbcore: registered new interface driver rndis_host
[   10.002284] usbcore: registered new interface driver cdc_subset
[   10.002296] usbcore: registered new interface driver zaurus
[   10.002310] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   10.002327] usbcore: registered new interface driver int51x1
[   10.002339] usbcore: registered new interface driver ipheth
[   10.002353] usbcore: registered new interface driver sierra_net
[   10.002373] usbcore: registered new interface driver cdc_ncm
[   10.002374] Fusion MPT base driver 3.04.20
[   10.002375] Copyright (c) 1999-2008 LSI Corporation
[   10.002382] Fusion MPT SPI Host driver 3.04.20
[   10.002401] Fusion MPT FC Host driver 3.04.20
[   10.002429] Fusion MPT SAS Host driver 3.04.20
[   10.002453] Fusion MPT misc device (ioctl) driver 3.04.20
[   10.002513] mptctl: Registered with Fusion MPT base driver
[   10.002516] mptctl: /dev/mptctl @ (major,minor=10,220)
[   10.002622] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   10.002625] ehci-pci: EHCI PCI platform driver
[   10.002806] ehci-pci 0000:00:1a.7: EHCI Host Controller
[   10.002856] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 1
[   10.002872] ehci-pci 0000:00:1a.7: debug port 1
[   10.006799] ehci-pci 0000:00:1a.7: cache line size of 64 is not supported
[   10.006814] ehci-pci 0000:00:1a.7: irq 19, io mem 0xb1a22000
[   10.017318] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[   10.017480] hub 1-0:1.0: USB hub found
[   10.017486] hub 1-0:1.0: 6 ports detected
[   10.017789] ehci-pci 0000:00:1d.7: EHCI Host Controller
[   10.017836] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 2
[   10.017851] ehci-pci 0000:00:1d.7: debug port 1
[   10.021752] ehci-pci 0000:00:1d.7: cache line size of 64 is not supported
[   10.021764] ehci-pci 0000:00:1d.7: irq 16, io mem 0xb1a21000
[   10.033321] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[   10.033609] hub 2-0:1.0: USB hub found
[   10.033614] hub 2-0:1.0: 6 ports detected
[   10.033779] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   10.033784] ohci-pci: OHCI PCI platform driver
[   10.033809] uhci_hcd: USB Universal Host Controller Interface driver
[   10.033957] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[   10.034042] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[   10.034051] uhci_hcd 0000:00:1a.0: detected 2 ports
[   10.034073] uhci_hcd 0000:00:1a.0: irq 19, io base 0x000020e0
[   10.034328] hub 3-0:1.0: USB hub found
[   10.034334] hub 3-0:1.0: 2 ports detected
[   10.034556] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[   10.034714] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[   10.034721] uhci_hcd 0000:00:1a.1: detected 2 ports
[   10.034743] uhci_hcd 0000:00:1a.1: irq 19, io base 0x000020c0
[   10.034918] hub 4-0:1.0: USB hub found
[   10.034924] hub 4-0:1.0: 2 ports detected
[   10.035154] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[   10.035276] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
[   10.035283] uhci_hcd 0000:00:1a.2: detected 2 ports
[   10.035305] uhci_hcd 0000:00:1a.2: irq 19, io base 0x000020a0
[   10.035469] hub 5-0:1.0: USB hub found
[   10.035473] hub 5-0:1.0: 2 ports detected
[   10.035703] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   10.035796] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
[   10.035803] uhci_hcd 0000:00:1d.0: detected 2 ports
[   10.035826] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00002080
[   10.036024] hub 6-0:1.0: USB hub found
[   10.036028] hub 6-0:1.0: 2 ports detected
[   10.036263] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   10.036348] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
[   10.036356] uhci_hcd 0000:00:1d.1: detected 2 ports
[   10.036378] uhci_hcd 0000:00:1d.1: irq 16, io base 0x00002060
[   10.036534] hub 7-0:1.0: USB hub found
[   10.036538] hub 7-0:1.0: 2 ports detected
[   10.036760] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   10.036840] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
[   10.036847] uhci_hcd 0000:00:1d.2: detected 2 ports
[   10.036868] uhci_hcd 0000:00:1d.2: irq 16, io base 0x00002040
[   10.037042] hub 8-0:1.0: USB hub found
[   10.037046] hub 8-0:1.0: 2 ports detected
[   10.037205] usbcore: registered new interface driver usb-storage
[   10.037220] usbcore: registered new interface driver ums-alauda
[   10.037237] usbcore: registered new interface driver ums-datafab
[   10.037251] usbcore: registered new interface driver ums-freecom
[   10.037268] usbcore: registered new interface driver ums-isd200
[   10.037279] usbcore: registered new interface driver ums-jumpshot
[   10.037292] usbcore: registered new interface driver ums-sddr09
[   10.037330] usbcore: registered new interface driver ums-sddr55
[   10.037341] usbcore: registered new interface driver ums-usbat
[   10.037363] usbcore: registered new interface driver usbtest
[   10.037426] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   11.074330] i8042: No controller found
[   11.078916] Switched to clocksource tsc
[   11.078996] mousedev: PS/2 mouse device common for all mice
[   11.079398] rtc_cmos 00:02: RTC can wake from S4
[   11.079621] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[   11.079654] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[   11.079679] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   11.079692] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   11.079700] iTCO_vendor_support: vendor-support=0
[   11.079815] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   11.079816] md: linear personality registered for level -1
[   11.079817] md: raid0 personality registered for level 0
[   11.079817] md: raid1 personality registered for level 1
[   11.079818] md: raid10 personality registered for level 10
[   11.079980] md: raid6 personality registered for level 6
[   11.079980] md: raid5 personality registered for level 5
[   11.079981] md: raid4 personality registered for level 4
[   11.079982] md: multipath personality registered for level -4
[   11.079983] md: faulty personality registered for level -5
[   11.080651] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
[   11.081284] device-mapper: multipath: version 1.7.0 loaded
[   11.081285] device-mapper: multipath round-robin: version 1.0.0 loaded
[   11.081303] device-mapper: cache-policy-mq: version 1.2.0 loaded
[   11.081304] device-mapper: cache cleaner: version 1.0.0 loaded
[   11.081390] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   11.081670] usbcore: registered new interface driver usbhid
[   11.081670] usbhid: USB HID core driver
[   11.081757] TCP: bic registered
[   11.081758] Initializing XFRM netlink socket
[   11.081901] NET: Registered protocol family 10
[   11.082122] sit: IPv6 over IPv4 tunneling driver
[   11.082250] NET: Registered protocol family 17
[   11.082267] 8021q: 802.1Q VLAN Support v1.8
[   11.083285] DCCP: Activated CCID 2 (TCP-like)
[   11.083293] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   11.083774] sctp: Hash tables configured (established 65536 bind 65536)
[   11.083857] tipc: Activated (version 2.0.0)
[   11.083902] NET: Registered protocol family 30
[   11.084006] tipc: Started in single node mode
[   11.084014] Key type dns_resolver registered
[   11.084922] 
[   11.084922] printing PIC contents
[   11.084926] ... PIC  IMR: ffff
[   11.084929] ... PIC  IRR: 0c21
[   11.084939] ... PIC  ISR: 0000
[   11.084942] ... PIC ELCR: 0e20
[   11.084991] printing local APIC contents on CPU#0/0:
[   11.084993] ... APIC ID:      00000000 (0)
[   11.084994] ... APIC VERSION: 00060015
[   11.084995] ... APIC TASKPRI: 00000000 (00)
[   11.084996] ... APIC PROCPRI: 00000000
[   11.084996] ... APIC LDR: 01000000
[   11.084997] ... APIC DFR: ffffffff
[   11.084998] ... APIC SPIV: 000001ff
[   11.084998] ... APIC ISR field:
[   11.085002] 0000000000000000000000000000000000000000000000000000000000000000
[   11.085003] ... APIC TMR field:
[   11.085006] 0000000000000000000200020000000000000000000000000000000000000000
[   11.085006] ... APIC IRR field:
[   11.085010] 0000000000000000000000000000000000000000000000000000000000000000
[   11.085010] ... APIC ESR: 00000000
[   11.085011] ... APIC ICR: 000000ef
[   11.085012] ... APIC ICR2: 12000000
[   11.085012] ... APIC LVTT: 000000ef
[   11.085013] ... APIC LVTPC: 00000400
[   11.085013] ... APIC LVT0: 00010700
[   11.085014] ... APIC LVT1: 00000400
[   11.085015] ... APIC LVTERR: 000000fe
[   11.085015] ... APIC TMICT: 7fffffff
[   11.085016] ... APIC TMCCT: 7fffff0b
[   11.085016] ... APIC TDCR: 00000003
[   11.085017] 
[   11.085018] number of MP IRQ sources: 15.
[   11.085019] number of IO-APIC #8 registers: 24.
[   11.085019] number of IO-APIC #9 registers: 24.
[   11.085020] testing the IO APIC.......................
[   11.085026] IO APIC #8......
[   11.085027] .... register #00: 08000000
[   11.085027] .......    : physical APIC id: 08
[   11.085028] .......    : Delivery Type: 0
[   11.085028] .......    : LTS          : 0
[   11.085028] .... register #01: 00170020
[   11.085029] .......     : max redirection entries: 17
[   11.085029] .......     : PRQ implemented: 0
[   11.085030] .......     : IO APIC version: 20
[   11.085030] .... IRQ redirection table:
[   11.085035] 1    0    0   0   0    0    0    00
[   11.085039] 0    0    0   0   0    0    0    31
[   11.085042] 0    0    0   0   0    0    0    30
[   11.085045] 0    0    0   0   0    0    0    33
[   11.085049] 0    0    0   0   0    0    0    34
[   11.085052] 0    0    0   0   0    0    0    35
[   11.085055] 0    0    0   0   0    0    0    36
[   11.085058] 0    0    0   0   0    0    0    37
[   11.085062] 0    0    0   0   0    0    0    38
[   11.085065] 0    1    0   0   0    0    0    39
[   11.085068] 0    0    0   0   0    0    0    3A
[   11.085072] 0    0    0   0   0    0    0    3B
[   11.085075] 0    0    0   0   0    0    0    3C
[   11.085078] 0    0    0   0   0    0    0    3D
[   11.085082] 0    0    0   0   0    0    0    3E
[   11.085086] 0    0    0   0   0    0    0    3F
[   11.085089] 0    1    0   1   0    0    0    51
[   11.085092] 1    1    0   1   0    0    0    82
[   11.085096] 1    1    0   1   0    0    0    A2
[   11.085099] 0    1    0   1   0    0    0    41
[   11.085102] 1    0    0   0   0    0    0    00
[   11.085106] 1    0    0   0   0    0    0    00
[   11.085109] 1    0    0   0   0    0    0    00
[   11.085112] 1    0    0   0   0    0    0    00
[   11.085116] IO APIC #9......
[   11.085116] .... register #00: 09000000
[   11.085116] .......    : physical APIC id: 09
[   11.085117] .......    : Delivery Type: 0
[   11.085117] .......    : LTS          : 0
[   11.085117] .... register #01: 00170020
[   11.085118] .......     : max redirection entries: 17
[   11.085118] .......     : PRQ implemented: 0
[   11.085118] .......     : IO APIC version: 20
[   11.085119] .... register #02: 00000000
[   11.085119] .......     : arbitration: 00
[   11.085120] .... register #03: 00000001
[   11.085120] .......     : Boot DT    : 1
[   11.085120] .... IRQ redirection table:
[   11.085123] 1    1    0   1   0    0    0    81
[   11.085125] 1    0    0   0   0    0    0    00
[   11.085128] 1    1    0   1   0    0    0    A1
[   11.085130] 1    0    0   0   0    0    0    00
[   11.085133] 1    1    0   1   0    0    0    61
[   11.085135] 1    0    0   0   0    0    0    00
[   11.085138] 1    1    0   1   0    0    0    C1
[   11.085140] 1    0    0   0   0    0    0    00
[   11.085142] 1    1    0   1   0    0    0    E1
[   11.085145] 1    1    0   1   0    0    0    42
[   11.085147] 1    0    0   0   0    0    0    00
[   11.085150] 1    0    0   0   0    0    0    00
[   11.085152] 1    0    0   0   0    0    0    00
[   11.085154] 1    0    0   0   0    0    0    00
[   11.085157] 1    0    0   0   0    0    0    00
[   11.085159] 1    0    0   0   0    0    0    00
[   11.085162] 1    1    0   1   0    0    0    C2
[   11.085164] 1    0    0   0   0    0    0    00
[   11.085166] 1    0    0   0   0    0    0    00
[   11.085169] 1    0    0   0   0    0    0    00
[   11.085171] 1    0    0   0   0    0    0    00
[   11.085174] 1    0    0   0   0    0    0    00
[   11.085176] 1    0    0   0   0    0    0    00
[   11.085178] 1    0    0   0   0    0    0    00
[   11.085179] IRQ to pin mappings:
[   11.085181] IRQ0 -> 0:2
[   11.085182] IRQ1 -> 0:1
[   11.085183] IRQ3 -> 0:3
[   11.085184] IRQ4 -> 0:4
[   11.085185] IRQ5 -> 0:5
[   11.085186] IRQ6 -> 0:6
[   11.085187] IRQ7 -> 0:7
[   11.085187] IRQ8 -> 0:8
[   11.085188] IRQ9 -> 0:9
[   11.085189] IRQ10 -> 0:10
[   11.085190] IRQ11 -> 0:11
[   11.085191] IRQ12 -> 0:12
[   11.085192] IRQ13 -> 0:13
[   11.085192] IRQ14 -> 0:14
[   11.085193] IRQ15 -> 0:15
[   11.085194] IRQ16 -> 0:16
[   11.085195] IRQ17 -> 0:17
[   11.085196] IRQ18 -> 0:18
[   11.085197] IRQ19 -> 0:19
[   11.085198] IRQ24 -> 1:0
[   11.085199] IRQ26 -> 1:2
[   11.085200] IRQ28 -> 1:4
[   11.085201] IRQ30 -> 1:6
[   11.085202] IRQ32 -> 1:8
[   11.085203] IRQ33 -> 1:9
[   11.085204] IRQ40 -> 1:16
[   11.085206] .................................... done.
[   11.085324] registered taskstats version 1
[   11.086283] Btrfs loaded
[   11.549873] usb 2-1: new high-speed USB device number 2 using ehci-pci
[   11.684671] usb-storage 2-1:1.0: USB Mass Storage device detected
[   11.685257] scsi6 : usb-storage 2-1:1.0
[   11.793854] usb 2-2: new high-speed USB device number 3 using ehci-pci
[   11.926510] hub 2-2:1.0: USB hub found
[   11.926585] hub 2-2:1.0: 4 ports detected
[   12.026334] rtc_cmos 00:02: setting system clock to 2014-03-17 20:43:39 UTC (1395089019)
[   12.036102] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   12.043199] EDD information not available.
[   12.142530] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   12.149439] 8021q: adding VLAN 0 to HW filter on device eth0
[   12.221886] usb 5-1: new full-speed USB device number 2 using uhci_hcd
[   12.234377] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   12.241278] 8021q: adding VLAN 0 to HW filter on device eth1
[   12.400101] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.0/0003:046B:FF10.0001/input/input2
[   12.417012] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input0
[   12.440058] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.1/0003:046B:FF10.0002/input/input3
[   12.456937] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input1
[   12.684199] scsi 6:0:0:0: CD-ROM            TEAC     DV-W28S-V        1.0A PQ: 0 ANSI: 0
[   12.694340] scsi 6:0:0:0: Attached scsi generic sg2 type 5
[   12.710034] usb 8-2: new low-speed USB device number 2 using uhci_hcd
[   13.003788] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.0/0003:04D9:1702.0003/input/input4
[   13.016911] hid-generic 0003:04D9:1702.0003: input: USB HID v1.10 Keyboard [  USB Keyboard] on usb-0000:00:1d.2-2/input0
[   13.081680] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.1/0003:04D9:1702.0004/input/input5
[   13.094843] hid-generic 0003:04D9:1702.0004: input: USB HID v1.10 Device [  USB Keyboard] on usb-0000:00:1d.2-2/input1
[   13.135800] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.2/0003:04D9:1702.0005/input/input6
[   13.149108] hid-generic 0003:04D9:1702.0005: input: USB HID v1.10 Mouse [  USB Keyboard] on usb-0000:00:1d.2-2/input2
[   14.182789] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[   14.198356] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   14.214290] Sending DHCP requests .., OK
[   17.050964] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.146
[   17.243278] IP-Config: Complete:
[   17.247367]      device=eth0, hwaddr=00:15:17:e6:9d:cc, ipaddr=192.168.1.146, mask=255.255.255.0, gw=192.168.1.1
[   17.259532]      host=lkp-ne04, domain=lkp.intel.com, nis-domain=(none)
[   17.267408]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
[   17.275068]      nameserver0=192.168.1.1
[   17.280583] PM: Hibernation image not present or could not be loaded.
[   17.291108] Freeing unused kernel memory: 1436K (ffffffff8233f000 - ffffffff824a6000)
[   17.300560] Write protecting the kernel read-only data: 18432k
[   17.313999] Freeing unused kernel memory: 1720K (ffff880001a52000 - ffff880001c00000)
[   17.328361] Freeing unused kernel memory: 1852K (ffff880002031000 - ffff880002200000)
[   17.539241] ipmi message handler version 39.2
[   17.545483] IPMI System Interface driver.
[   17.550393] ipmi_si: probing via ACPI
[   17.550430] ipmi_si 00:09: [io  0x0ca2] regsize 1 spacing 1 irq 0
[   17.550432] ipmi_si: Adding ACPI-specified kcs state machine
[   17.550458] ipmi_si: probing via SMBIOS
[   17.550460] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[   17.550461] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
[   17.550464] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[   17.601761] microcode: CPU0 sig=0x106a5, pf=0x1, revision=0x11
[   17.608631] microcode: CPU1 sig=0x106a5, pf=0x1, revision=0x11
[   17.608700] microcode: CPU2 sig=0x106a5, pf=0x1, revision=0x11
[   17.608715] microcode: CPU3 sig=0x106a5, pf=0x1, revision=0x11
[   17.608730] microcode: CPU4 sig=0x106a5, pf=0x1, revision=0x11
[   17.608752] microcode: CPU5 sig=0x106a5, pf=0x1, revision=0x11
[   17.608766] microcode: CPU6 sig=0x106a5, pf=0x1, revision=0x11
[   17.608841] microcode: CPU7 sig=0x106a5, pf=0x1, revision=0x11
[   17.608909] microcode: CPU8 sig=0x106a5, pf=0x1, revision=0x11
[   17.608946] microcode: CPU9 sig=0x106a5, pf=0x1, revision=0x11
[   17.609014] microcode: CPU10 sig=0x106a5, pf=0x1, revision=0x11
[   17.609061] microcode: CPU11 sig=0x106a5, pf=0x1, revision=0x11
[   17.609077] microcode: CPU12 sig=0x106a5, pf=0x1, revision=0x11
[   17.615884] microcode: CPU13 sig=0x106a5, pf=0x1, revision=0x11
[   17.616018] microcode: CPU14 sig=0x106a5, pf=0x1, revision=0x11
[   17.616064] microcode: CPU15 sig=0x106a5, pf=0x1, revision=0x11
[   17.616170] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   17.707713] ipmi_si 00:09: Found new BMC (man_id: 0x000157, prod_id: 0x003e, dev_id: 0x21)
[   17.707720] ipmi_si 00:09: IPMI kcs interface initialized
[   17.853494] random: nonblocking pool is initialized
[   17.885705] BTRFS: device fsid 3ce67776-66a6-4f9e-a297-eab37d032e1c devid 1 transid 6 /dev/sdb2
<6>[    0.000000] Initializing cgroup subsys cpuset
<6>[    0.000000] Initializing cgroup subsys cpu
<5>[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
<6>[    0.000000] Command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-ne04/cyclic_aim7-shell_rtns_1-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=1219 RESULT_ROOT=/lkp/result/lkp-ne04/micro/aim7/shell_rtns_1/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-ne04::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
<6>[    0.000000] e820: BIOS-provided physical RAM map:
<6>[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009a3ff] usable
<6>[    0.000000] BIOS-e820: [mem 0x000000000009a400-0x000000000009ffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000008c555fff] usable
<6>[    0.000000] BIOS-e820: [mem 0x000000008c556000-0x000000008c628fff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000008c629000-0x000000008c701fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000008c702000-0x000000008db01fff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000008db02000-0x000000008f601fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000008f602000-0x000000008f64efff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000008f64f000-0x000000008f6e5fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000008f6e6000-0x000000008f6effff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000008f6f0000-0x000000008f6f1fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000008f6f2000-0x000000008f7cefff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000008f7cf000-0x000000008f7fffff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000008f800000-0x000000008fffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000a0000000-0x00000000afffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fc000000-0x00000000fcffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000036fffffff] usable
<6>[    0.000000] bootconsole [earlyser0] enabled
<6>[    0.000000] NX (Execute Disable) protection: active
<6>[    0.000000] SMBIOS 2.5 present.
<7>[    0.000000] DMI: Intel Corporation S5520UR/S5520UR, BIOS S5500.86B.01.00.0050.050620101605 05/06/2010
<7>[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
<7>[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
<6>[    0.000000] No AGP bridge found
<6>[    0.000000] e820: last_pfn = 0x370000 max_arch_pfn = 0x400000000
<7>[    0.000000] MTRR default type: uncachable
<7>[    0.000000] MTRR fixed ranges enabled:
<7>[    0.000000]   00000-9FFFF write-back
<7>[    0.000000]   A0000-DFFFF uncachable
<7>[    0.000000]   E0000-FFFFF write-protect
<7>[    0.000000] MTRR variable ranges enabled:
<7>[    0.000000]   0 base 0000000000 mask FF80000000 write-back
<7>[    0.000000]   1 base 0080000000 mask FFF0000000 write-back
<7>[    0.000000]   2 base 0100000000 mask FF00000000 write-back
<7>[    0.000000]   3 base 0200000000 mask FF00000000 write-back
<7>[    0.000000]   4 base 0300000000 mask FFC0000000 write-back
<7>[    0.000000]   5 base 0340000000 mask FFE0000000 write-back
<7>[    0.000000]   6 base 0360000000 mask FFF0000000 write-back
<7>[    0.000000]   7 base 00B0000000 mask FFFF000000 write-combining
<6>[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
<6>[    0.000000] e820: last_pfn = 0x8c556 max_arch_pfn = 0x400000000
<4>[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
<4>[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
<4>[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
<6>[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [ffff8800000fdab0]
<4>[    0.000000]   mpc: ef260-ef424
<6>[    0.000000] Scanning 1 areas for low memory corruption
<7>[    0.000000] Base memory trampoline at [ffff880000094000] 94000 size 24576
<6>[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
<7>[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
<7>[    0.000000] BRK [0x0266b000, 0x0266bfff] PGTABLE
<7>[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
<7>[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
<6>[    0.000000] init_memory_mapping: [mem 0x36fe00000-0x36fffffff]
<7>[    0.000000]  [mem 0x36fe00000-0x36fffffff] page 2M
<7>[    0.000000] BRK [0x0266e000, 0x0266efff] PGTABLE
<6>[    0.000000] init_memory_mapping: [mem 0x36c000000-0x36fdfffff]
<7>[    0.000000]  [mem 0x36c000000-0x36fdfffff] page 2M
<6>[    0.000000] init_memory_mapping: [mem 0x300000000-0x36bffffff]
<7>[    0.000000]  [mem 0x300000000-0x36bffffff] page 2M
<7>[    0.000000] BRK [0x0266f000, 0x0266ffff] PGTABLE
<6>[    0.000000] init_memory_mapping: [mem 0x00100000-0x8c555fff]
<7>[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
<7>[    0.000000]  [mem 0x00200000-0x8c3fffff] page 2M
<7>[    0.000000]  [mem 0x8c400000-0x8c555fff] page 4k
<6>[    0.000000] init_memory_mapping: [mem 0x100000000-0x2ffffffff]
<7>[    0.000000]  [mem 0x100000000-0x2ffffffff] page 2M
<7>[    0.000000] BRK [0x02670000, 0x02670fff] PGTABLE
<6>[    0.000000] RAMDISK: [mem 0x72fd1000-0x7fff4fff]
<4>[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 INTEL )
<4>[    0.000000] ACPI: XSDT 0x000000008F7FD120 000094 (v01 INTEL  S5520UR  00000000      01000013)
<4>[    0.000000] ACPI: FACP 0x000000008F7FB000 0000F4 (v04 INTEL  S5520UR  00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: DSDT 0x000000008F7F4000 00657E (v02 INTEL  S5520UR  00000003 MSFT 0100000D)
<4>[    0.000000] ACPI: FACS 0x000000008F6F2000 000040
<4>[    0.000000] ACPI: APIC 0x000000008F7F3000 0001A8 (v02 INTEL  S5520UR  00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: MCFG 0x000000008F7F2000 00003C (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: HPET 0x000000008F7F1000 000038 (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SLIT 0x000000008F7F0000 000030 (v01 INTEL  S5520UR  00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SRAT 0x000000008F7EF000 000430 (v02 INTEL  S5520UR  00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SPCR 0x000000008F7EE000 000050 (v01 INTEL  S5520UR  00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: WDDT 0x000000008F7ED000 000040 (v01 INTEL  S5520UR  00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: SSDT 0x000000008F7D2000 01AFC4 (v02 INTEL  SSDT  PM 00004000 INTL 20061109)
<4>[    0.000000] ACPI: SSDT 0x000000008F7D1000 0001D8 (v02 INTEL  IPMI     00004000 INTL 20061109)
<4>[    0.000000] ACPI: HEST 0x000000008F7D0000 0000A8 (v01 INTEL  S5520UR  00000001 INTL 00000001)
<4>[    0.000000] ACPI: BERT 0x000000008F7CF000 000030 (v01 INTEL  S5520UR  00000001 INTL 00000001)
<4>[    0.000000] ACPI: ERST 0x000000008F6F1000 000230 (v01 INTEL  S5520UR  00000001 INTL 00000001)
<4>[    0.000000] ACPI: EINJ 0x000000008F6F0000 000130 (v01 INTEL  S5520UR  00000001 INTL 00000001)
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<4>[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x10 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x12 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x14 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x16 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x11 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x13 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x15 -> Node 1
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x17 -> Node 1
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x8fffffff]
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x1efffffff]
<6>[    0.000000] SRAT: Node 1 PXM 1 [mem 0x1f0000000-0x36fffffff]
<7>[    0.000000] NUMA: Initialized distance table, cnt=2
<6>[    0.000000] NUMA: Node 0 [mem 0x00000000-0x8fffffff] + [mem 0x100000000-0x1efffffff] -> [mem 0x00000000-0x1efffffff]
<6>[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1efffffff]
<6>[    0.000000]   NODE_DATA [mem 0x1efffb000-0x1efffffff]
<6>[    0.000000] Initmem setup node 1 [mem 0x1f0000000-0x36fffffff]
<6>[    0.000000]   NODE_DATA [mem 0x36fff0000-0x36fff4fff]
<7>[    0.000000]  [ffffea0000000000-ffffea0007bfffff] PMD -> [ffff8801e9e00000-ffff8801efdfffff] on node 0
<7>[    0.000000]  [ffffea0007c00000-ffffea000dbfffff] PMD -> [ffff880369600000-ffff88036f5fffff] on node 1
<4>[    0.000000] Zone ranges:
<4>[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
<4>[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
<4>[    0.000000]   Normal   [mem 0x100000000-0x36fffffff]
<4>[    0.000000] Movable zone start for each node
<4>[    0.000000] Early memory node ranges
<4>[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
<4>[    0.000000]   node   0: [mem 0x00100000-0x8c555fff]
<4>[    0.000000]   node   0: [mem 0x100000000-0x1efffffff]
<4>[    0.000000]   node   1: [mem 0x1f0000000-0x36fffffff]
<7>[    0.000000] On node 0 totalpages: 1557743
<7>[    0.000000]   DMA zone: 64 pages used for memmap
<7>[    0.000000]   DMA zone: 21 pages reserved
<7>[    0.000000]   DMA zone: 3993 pages, LIFO batch:0
<7>[    0.000000]   DMA32 zone: 8918 pages used for memmap
<7>[    0.000000]   DMA32 zone: 570710 pages, LIFO batch:31
<7>[    0.000000]   Normal zone: 15360 pages used for memmap
<7>[    0.000000]   Normal zone: 983040 pages, LIFO batch:31
<7>[    0.000000] On node 1 totalpages: 1572864
<7>[    0.000000]   Normal zone: 24576 pages used for memmap
<7>[    0.000000]   Normal zone: 1572864 pages, LIFO batch:31
<6>[    0.000000] ACPI: PM-Timer IO Port: 0x408
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<4>[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x10] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x12] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x16] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x01] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x11] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x03] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x13] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x05] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x15] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x07] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x17] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0xff] disabled)
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
<6>[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
<6>[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
<6>[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec90000] gsi_base[24])
<6>[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec90000, GSI 24-47
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
<4>[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
<7>[    0.000000] ACPI: IRQ0 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
<7>[    0.000000] ACPI: IRQ2 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
<7>[    0.000000] ACPI: IRQ9 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
<6>[    0.000000] Using ACPI (MADT) for SMP configuration information
<6>[    0.000000] ACPI: HPET id: 0x8086a401 base: 0xfed00000
<6>[    0.000000] smpboot: Allowing 24 CPUs, 8 hotplug CPUs
<4>[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
<4>[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec90000)
<7>[    0.000000] nr_irqs_gsi: 64
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009a000-0x0009afff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8c556000-0x8c628fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8c629000-0x8c701fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8c702000-0x8db01fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8db02000-0x8f601fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f602000-0x8f64efff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f64f000-0x8f6e5fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f6e6000-0x8f6effff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f6f0000-0x8f6f1fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f6f2000-0x8f7cefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f7cf000-0x8f7fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x8f800000-0x8fffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0x9fffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xa0000000-0xafffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xb0000000-0xfbffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfcffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfd000000-0xfed1bfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
<6>[    0.000000] e820: [mem 0xb0000000-0xfbffffff] available for PCI devices
<6>[    0.000000] Booting paravirtualized kernel on bare hardware
<6>[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:24 nr_node_ids:2
<6>[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff8801e9c00000 s81088 r8192 d21312 u131072
<7>[    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=1*2097152
<7>[    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 -- -- -- -- 
<7>[    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 -- -- -- -- 
<4>[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 3081668
<4>[    0.000000] Policy zone: Normal
<5>[    0.000000] Kernel command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-ne04/cyclic_aim7-shell_rtns_1-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=1219 RESULT_ROOT=/lkp/result/lkp-ne04/micro/aim7/shell_rtns_1/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-ne04::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
<6>[    0.000000] sysrq: sysrq always enabled.
<6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
<6>[    0.000000] Checking aperture...
<6>[    0.000000] No AGP bridge found
<4>[    0.000000] Memory: 12020544K/12522428K available (10556K kernel code, 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 501884K reserved)
<6>[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=24, Nodes=2
<6>[    0.000000] Hierarchical RCU implementation.
<6>[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
<6>[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=24.
<6>[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=24
<6>[    0.000000] NR_IRQS:33024 nr_irqs:1280 16
<6>[    0.000000] Console: colour VGA+ 80x25
<6>[    0.000000] console [tty0] enabled
<6>[    0.000000] bootconsole [earlyser0] disabled
<6>[    0.000000] console [ttyS0] enabled
<6>[    0.000000] allocated 50331648 bytes of page_cgroup
<6>[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
<6>[    0.000000] Disabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
<7>[    0.000000] hpet clockevent registered
<6>[    0.000000] tsc: Fast TSC calibration using PIT
<6>[    0.000000] tsc: Detected 2926.286 MHz processor
<6>[    0.000007] Calibrating delay loop (skipped), value calculated using timer frequency.. 5852.57 BogoMIPS (lpj=11705144)
<6>[    0.012121] pid_max: default: 32768 minimum: 301
<6>[    0.017361] ACPI: Core revision 20140214
<4>[    0.034734] ACPI: All ACPI Tables successfully acquired
<6>[    0.041824] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
<6>[    0.053317] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
<6>[    0.062962] Mount-cache hash table entries: 256
<6>[    0.068631] Initializing cgroup subsys memory
<6>[    0.073883] Initializing cgroup subsys devices
<6>[    0.079229] Initializing cgroup subsys freezer
<6>[    0.084585] Initializing cgroup subsys blkio
<6>[    0.089743] Initializing cgroup subsys perf_event
<6>[    0.095387] Initializing cgroup subsys hugetlb
<6>[    0.100764] CPU: Physical Processor ID: 0
<6>[    0.105632] CPU: Processor Core ID: 0
<6>[    0.110116] mce: CPU supports 9 MCE banks
<6>[    0.114995] CPU0: Thermal monitoring enabled (TM1)
<6>[    0.120744] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
<6>[    0.120744] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
<6>[    0.120744] tlb_flushall_shift: 6
<6>[    0.138651] Freeing SMP alternatives memory: 44K (ffffffff824a6000 - ffffffff824b1000)
<6>[    0.149256] ftrace: allocating 40687 entries in 159 pages
<4>[    0.171521] Getting VERSION: 60015
<4>[    0.175713] Getting VERSION: 60015
<4>[    0.179897] Getting ID: 0
<4>[    0.183204] Getting ID: 0
<6>[    0.186515] Switched APIC routing to physical flat.
<4>[    0.192357] enabled ExtINT on CPU#0
<4>[    0.196972] ENABLING IO-APIC IRQs
<7>[    0.201056] init IO_APIC IRQs
<7>[    0.204748]  apic 8 pin 0 not connected
<7>[    0.209419] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
<7>[    0.218985] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
<7>[    0.228549] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
<7>[    0.238113] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
<7>[    0.247677] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
<7>[    0.257233] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
<7>[    0.266800] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
<7>[    0.276336] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
<7>[    0.285881] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
<7>[    0.295445] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
<7>[    0.305196] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
<7>[    0.314941] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
<7>[    0.324695] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
<7>[    0.334439] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
<7>[    0.344168] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
<7>[    0.353911]  apic 8 pin 16 not connected
<7>[    0.358674]  apic 8 pin 17 not connected
<7>[    0.363436]  apic 8 pin 18 not connected
<7>[    0.368181]  apic 8 pin 19 not connected
<7>[    0.372947]  apic 8 pin 20 not connected
<7>[    0.377712]  apic 8 pin 21 not connected
<7>[    0.382454]  apic 8 pin 22 not connected
<7>[    0.387222]  apic 8 pin 23 not connected
<7>[    0.391979]  apic 9 pin 0 not connected
<7>[    0.396635]  apic 9 pin 1 not connected
<7>[    0.401294]  apic 9 pin 2 not connected
<7>[    0.405951]  apic 9 pin 3 not connected
<7>[    0.410610]  apic 9 pin 4 not connected
<7>[    0.415281]  apic 9 pin 5 not connected
<7>[    0.419946]  apic 9 pin 6 not connected
<7>[    0.424605]  apic 9 pin 7 not connected
<7>[    0.429274]  apic 9 pin 8 not connected
<7>[    0.433943]  apic 9 pin 9 not connected
<7>[    0.438599]  apic 9 pin 10 not connected
<7>[    0.443358]  apic 9 pin 11 not connected
<7>[    0.448117]  apic 9 pin 12 not connected
<7>[    0.452869]  apic 9 pin 13 not connected
<7>[    0.457625]  apic 9 pin 14 not connected
<7>[    0.462379]  apic 9 pin 15 not connected
<7>[    0.467123]  apic 9 pin 16 not connected
<7>[    0.471874]  apic 9 pin 17 not connected
<7>[    0.476635]  apic 9 pin 18 not connected
<7>[    0.481392]  apic 9 pin 19 not connected
<7>[    0.486156]  apic 9 pin 20 not connected
<7>[    0.490923]  apic 9 pin 21 not connected
<7>[    0.495675]  apic 9 pin 22 not connected
<7>[    0.500437]  apic 9 pin 23 not connected
<6>[    0.505327] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
<6>[    0.552103] smpboot: CPU0: Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz (fam: 06, model: 1a, stepping: 05)
<4>[    0.564091] Using local APIC timer interrupts.
<4>[    0.564091] calibrating APIC timer ...
<4>[    0.679778] ... lapic delta = 831337
<4>[    0.684156] ... PM-Timer delta = 357951
<4>[    0.688827] ... PM-Timer result ok
<4>[    0.693008] ..... delta 831337
<4>[    0.696801] ..... mult: 35705652
<4>[    0.700788] ..... calibration result: 532055
<4>[    0.705942] ..... CPU clock speed is 2926.1202 MHz.
<4>[    0.711780] ..... host bus clock speed is 133.0055 MHz.
<6>[    0.718017] Performance Events: PEBS fmt1+, 16-deep LBR, Nehalem events, Intel PMU driver.
<6>[    0.728236] perf_event_intel: CPU erratum AAJ80 worked around
<4>[    0.735034] perf_event_intel: CPUID marked event: 'bus cycles' unavailable
<6>[    0.743098] ... version:                3
<6>[    0.747953] ... bit width:              48
<6>[    0.752899] ... generic registers:      4
<6>[    0.757757] ... value mask:             0000ffffffffffff
<6>[    0.764075] ... max period:             000000007fffffff
<6>[    0.770397] ... fixed-purpose events:   3
<6>[    0.775260] ... event mask:             000000070000000f
<6>[    0.783126] x86: Booting SMP configuration:
<6>[    0.788188] .... node  #1, CPUs:        #1
<4>[    0.803790] masked ExtINT on CPU#1
<4>[    0.906153] 
<6>[    0.908188] .... node  #0, CPUs:    #2
<4>[    0.923337] masked ExtINT on CPU#2
<4>[    0.929518] 
<6>[    0.931558] .... node  #1, CPUs:    #3
<4>[    0.946604] masked ExtINT on CPU#3
<4>[    0.952758] 
<6>[    0.954795] .... node  #0, CPUs:    #4
<4>[    0.969940] masked ExtINT on CPU#4
<4>[    0.976119] 
<6>[    0.978159] .... node  #1, CPUs:    #5
<4>[    0.993304] masked ExtINT on CPU#5
<4>[    0.999456] 
<6>[    1.001499] .... node  #0, CPUs:    #6
<4>[    1.016648] masked ExtINT on CPU#6
<4>[    1.022840] 
<6>[    1.024880] .... node  #1, CPUs:    #7
<4>[    1.040029] masked ExtINT on CPU#7
<4>[    1.046175] 
<6>[    1.048209] .... node  #0, CPUs:    #8
<4>[    1.063356] masked ExtINT on CPU#8
<4>[    1.069547] 
<6>[    1.071590] .... node  #1, CPUs:    #9
<4>[    1.086735] masked ExtINT on CPU#9
<4>[    1.092887] 
<6>[    1.094927] .... node  #0, CPUs:   #10
<4>[    1.110073] masked ExtINT on CPU#10
<4>[    1.116356] 
<6>[    1.118388] .... node  #1, CPUs:   #11
<4>[    1.133535] masked ExtINT on CPU#11
<4>[    1.139786] 
<6>[    1.141832] .... node  #0, CPUs:   #12
<4>[    1.156977] masked ExtINT on CPU#12
<4>[    1.163267] 
<6>[    1.165308] .... node  #1, CPUs:   #13
<4>[    1.180355] masked ExtINT on CPU#13
<4>[    1.186608] 
<6>[    1.188641] .... node  #0, CPUs:   #14
<4>[    1.203787] masked ExtINT on CPU#14
<4>[    1.210072] 
<6>[    1.212118] .... node  #1, CPUs:   #15
<4>[    1.227263] masked ExtINT on CPU#15
<6>[    1.233460] x86: Booted up 2 nodes, 16 CPUs
<6>[    1.238812] smpboot: Total of 16 processors activated (93640.05 BogoMIPS)
<6>[    1.257876] devtmpfs: initialized
<6>[    1.266075] PM: Registering ACPI NVS region [mem 0x8c556000-0x8c628fff] (864256 bytes)
<6>[    1.275660] PM: Registering ACPI NVS region [mem 0x8c702000-0x8db01fff] (20971520 bytes)
<6>[    1.285878] PM: Registering ACPI NVS region [mem 0x8f6e6000-0x8f6effff] (40960 bytes)
<6>[    1.295333] PM: Registering ACPI NVS region [mem 0x8f6f2000-0x8f7cefff] (905216 bytes)
<6>[    1.306147] xor: measuring software checksum speed
<6>[    1.350115]    prefetch64-sse: 11886.000 MB/sec
<6>[    1.394121]    generic_sse: 10480.000 MB/sec
<6>[    1.399277] xor: using function: prefetch64-sse (11886.000 MB/sec)
<6>[    1.406576] atomic64 test passed for x86-64 platform with CX8 and with SSE
<6>[    1.414696] NET: Registered protocol family 16
<6>[    1.420534] cpuidle: using governor ladder
<6>[    1.425490] cpuidle: using governor menu
<6>[    1.430655] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
<6>[    1.439830] ACPI: bus type PCI registered
<6>[    1.444697] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
<6>[    1.452338] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xa0000000-0xafffffff] (base 0xa0000000)
<6>[    1.463454] PCI: MMCONFIG at [mem 0xa0000000-0xafffffff] reserved in E820
<6>[    1.482592] PCI: Using configuration type 1 for base access
<4>[    1.558153] raid6: sse2x1    7066 MB/s
<4>[    1.630161] raid6: sse2x2    8408 MB/s
<4>[    1.702174] raid6: sse2x4    9588 MB/s
<4>[    1.706750] raid6: using algorithm sse2x4 (9588 MB/s)
<4>[    1.712785] raid6: using ssse3x2 recovery algorithm
<6>[    1.718676] ACPI: Added _OSI(Module Device)
<6>[    1.723741] ACPI: Added _OSI(Processor Device)
<6>[    1.729092] ACPI: Added _OSI(3.0 _SCP Extensions)
<6>[    1.734738] ACPI: Added _OSI(Processor Aggregator Device)
<4>[    1.762725] ACPI Error: Field [CPB3] at 96 exceeds Buffer [NULL] size 64 (bits) (20140214/dsopcode-236)
<4>[    1.774070] ACPI Error: Method parse/execution failed [\_SB_._OSC] (Node ffff8801e983d1b8), AE_AML_BUFFER_LIMIT (20140214/psparse-536)
<6>[    1.790428] ACPI: Interpreter enabled
<4>[    1.794904] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
<4>[    1.806051] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20140214/hwxface-580)
<4>[    1.817196] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20140214/hwxface-580)
<6>[    1.828362] ACPI: (supports S0 S1 S5)
<6>[    1.832837] ACPI: Using IOAPIC for interrupt routing
<6>[    1.838826] HEST: Table parsing has been initialized.
<6>[    1.844852] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
<7>[    1.868995] ACPI: \_PR_.CPUG: failed to get CPU APIC ID.
<7>[    1.875311] ACPI: \_PR_.CPUH: failed to get CPU APIC ID.
<7>[    1.881632] ACPI: \_PR_.CPUI: failed to get CPU APIC ID.
<7>[    1.887948] ACPI: \_PR_.CPUJ: failed to get CPU APIC ID.
<7>[    1.894268] ACPI: \_PR_.CPUK: failed to get CPU APIC ID.
<7>[    1.900592] ACPI: \_PR_.CPUL: failed to get CPU APIC ID.
<7>[    1.906923] ACPI: \_PR_.CPUM: failed to get CPU APIC ID.
<7>[    1.913245] ACPI: \_PR_.CPUN: failed to get CPU APIC ID.
<6>[    1.919770] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fd])
<6>[    1.927073] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    1.937046] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
<6>[    1.947057] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
<6>[    1.961997] PCI host bridge to bus 0000:00
<6>[    1.966961] pci_bus 0000:00: root bus resource [bus 00-fd]
<6>[    1.973475] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
<6>[    1.980758] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
<6>[    1.988056] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
<6>[    1.996129] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
<6>[    2.004202] pci_bus 0000:00: root bus resource [mem 0xb0000000-0xfdffffff]
<7>[    2.012289] pci 0000:00:00.0: [8086:3406] type 00 class 0x060000
<7>[    2.019430] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
<7>[    2.026729] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
<7>[    2.033872] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
<6>[    2.041122] pci 0000:00:01.0: System wakeup disabled by ACPI
<7>[    2.047877] pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
<7>[    2.055028] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
<6>[    2.062268] pci 0000:00:03.0: System wakeup disabled by ACPI
<7>[    2.069027] pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
<7>[    2.076169] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
<6>[    2.083423] pci 0000:00:05.0: System wakeup disabled by ACPI
<7>[    2.090168] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
<7>[    2.097322] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
<6>[    2.104562] pci 0000:00:07.0: System wakeup disabled by ACPI
<7>[    2.111325] pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
<7>[    2.118460] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
<6>[    2.125714] pci 0000:00:09.0: System wakeup disabled by ACPI
<7>[    2.132457] pci 0000:00:0a.0: [8086:3411] type 01 class 0x060400
<7>[    2.139606] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
<6>[    2.146857] pci 0000:00:0a.0: System wakeup disabled by ACPI
<7>[    2.153613] pci 0000:00:10.0: [8086:3425] type 00 class 0x080000
<7>[    2.160820] pci 0000:00:10.1: [8086:3426] type 00 class 0x080000
<7>[    2.168030] pci 0000:00:11.0: [8086:3427] type 00 class 0x080000
<7>[    2.175235] pci 0000:00:11.1: [8086:3428] type 00 class 0x080000
<7>[    2.182446] pci 0000:00:13.0: [8086:342d] type 00 class 0x080020
<7>[    2.189544] pci 0000:00:13.0: reg 0x10: [mem 0xb1a24000-0xb1a24fff]
<7>[    2.196980] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
<7>[    2.204252] pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
<7>[    2.211471] pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
<7>[    2.218681] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
<7>[    2.225899] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
<7>[    2.233090] pci 0000:00:15.0: [8086:342f] type 00 class 0x080020
<7>[    2.240301] pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
<7>[    2.247409] pci 0000:00:16.0: reg 0x10: [mem 0xb1a00000-0xb1a03fff 64bit]
<7>[    2.255518] pci 0000:00:16.1: [8086:3431] type 00 class 0x088000
<7>[    2.262627] pci 0000:00:16.1: reg 0x10: [mem 0xb1a04000-0xb1a07fff 64bit]
<7>[    2.270724] pci 0000:00:16.2: [8086:3432] type 00 class 0x088000
<7>[    2.277835] pci 0000:00:16.2: reg 0x10: [mem 0xb1a08000-0xb1a0bfff 64bit]
<7>[    2.285938] pci 0000:00:16.3: [8086:3433] type 00 class 0x088000
<7>[    2.293048] pci 0000:00:16.3: reg 0x10: [mem 0xb1a0c000-0xb1a0ffff 64bit]
<7>[    2.301149] pci 0000:00:16.4: [8086:3429] type 00 class 0x088000
<7>[    2.308259] pci 0000:00:16.4: reg 0x10: [mem 0xb1a10000-0xb1a13fff 64bit]
<7>[    2.316363] pci 0000:00:16.5: [8086:342a] type 00 class 0x088000
<7>[    2.323463] pci 0000:00:16.5: reg 0x10: [mem 0xb1a14000-0xb1a17fff 64bit]
<7>[    2.331554] pci 0000:00:16.6: [8086:342b] type 00 class 0x088000
<7>[    2.338668] pci 0000:00:16.6: reg 0x10: [mem 0xb1a18000-0xb1a1bfff 64bit]
<7>[    2.346761] pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
<7>[    2.353876] pci 0000:00:16.7: reg 0x10: [mem 0xb1a1c000-0xb1a1ffff 64bit]
<7>[    2.361979] pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
<7>[    2.369117] pci 0000:00:1a.0: reg 0x20: [io  0x20e0-0x20ff]
<6>[    2.375836] pci 0000:00:1a.0: System wakeup disabled by ACPI
<7>[    2.382595] pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
<7>[    2.389734] pci 0000:00:1a.1: reg 0x20: [io  0x20c0-0x20df]
<6>[    2.396448] pci 0000:00:1a.1: System wakeup disabled by ACPI
<7>[    2.403208] pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
<7>[    2.410345] pci 0000:00:1a.2: reg 0x20: [io  0x20a0-0x20bf]
<6>[    2.417043] pci 0000:00:1a.2: System wakeup disabled by ACPI
<7>[    2.423808] pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
<7>[    2.430915] pci 0000:00:1a.7: reg 0x10: [mem 0xb1a22000-0xb1a223ff]
<7>[    2.438392] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
<6>[    2.445654] pci 0000:00:1a.7: System wakeup disabled by ACPI
<7>[    2.452416] pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
<7>[    2.459572] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
<6>[    2.466831] pci 0000:00:1c.0: System wakeup disabled by ACPI
<7>[    2.473577] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400
<7>[    2.480744] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
<6>[    2.487994] pci 0000:00:1c.4: System wakeup disabled by ACPI
<7>[    2.494752] pci 0000:00:1c.5: [8086:3a4a] type 01 class 0x060400
<7>[    2.501906] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
<6>[    2.509158] pci 0000:00:1c.5: System wakeup disabled by ACPI
<7>[    2.515904] pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
<7>[    2.523036] pci 0000:00:1d.0: reg 0x20: [io  0x2080-0x209f]
<6>[    2.529740] pci 0000:00:1d.0: System wakeup disabled by ACPI
<7>[    2.536501] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
<7>[    2.543642] pci 0000:00:1d.1: reg 0x20: [io  0x2060-0x207f]
<6>[    2.550357] pci 0000:00:1d.1: System wakeup disabled by ACPI
<7>[    2.557114] pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
<7>[    2.564251] pci 0000:00:1d.2: reg 0x20: [io  0x2040-0x205f]
<6>[    2.570961] pci 0000:00:1d.2: System wakeup disabled by ACPI
<7>[    2.577728] pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
<7>[    2.584845] pci 0000:00:1d.7: reg 0x10: [mem 0xb1a21000-0xb1a213ff]
<7>[    2.592311] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
<6>[    2.599573] pci 0000:00:1d.7: System wakeup disabled by ACPI
<7>[    2.606337] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
<6>[    2.613521] pci 0000:00:1e.0: System wakeup disabled by ACPI
<7>[    2.620280] pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
<6>[    2.627449] pci 0000:00:1f.0: can't claim BAR 13 [io  0x0400-0x047f]: address conflict with ACPI CPU throttle [??? 0x00000410-0x00000415 flags 0x80000000]
<6>[    2.643625] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
<6>[    2.651991] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 000f)
<6>[    2.661151] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
<6>[    2.670320] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0600 (mask 001f)
<7>[    2.679607] pci 0000:00:1f.2: [8086:3a22] type 00 class 0x010601
<7>[    2.686724] pci 0000:00:1f.2: reg 0x10: [io  0x2108-0x210f]
<7>[    2.693351] pci 0000:00:1f.2: reg 0x14: [io  0x2114-0x2117]
<7>[    2.699972] pci 0000:00:1f.2: reg 0x18: [io  0x2100-0x2107]
<7>[    2.706596] pci 0000:00:1f.2: reg 0x1c: [io  0x2110-0x2113]
<7>[    2.713221] pci 0000:00:1f.2: reg 0x20: [io  0x2020-0x203f]
<7>[    2.719842] pci 0000:00:1f.2: reg 0x24: [mem 0xb1a20000-0xb1a207ff]
<7>[    2.727278] pci 0000:00:1f.2: PME# supported from D3hot
<7>[    2.733592] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
<7>[    2.740704] pci 0000:00:1f.3: reg 0x10: [mem 0xb1a23000-0xb1a230ff 64bit]
<7>[    2.748700] pci 0000:00:1f.3: reg 0x20: [io  0x2000-0x201f]
<7>[    2.755479] pci 0000:01:00.0: [8086:10a7] type 00 class 0x020000
<7>[    2.762587] pci 0000:01:00.0: reg 0x10: [mem 0xb1920000-0xb193ffff]
<7>[    2.769983] pci 0000:01:00.0: reg 0x18: [io  0x1020-0x103f]
<7>[    2.776595] pci 0000:01:00.0: reg 0x1c: [mem 0xb1944000-0xb1947fff]
<7>[    2.784048] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
<6>[    2.791270] pci 0000:01:00.0: System wakeup disabled by ACPI
<7>[    2.798035] pci 0000:01:00.1: [8086:10a7] type 00 class 0x020000
<7>[    2.805147] pci 0000:01:00.1: reg 0x10: [mem 0xb1900000-0xb191ffff]
<7>[    2.812555] pci 0000:01:00.1: reg 0x18: [io  0x1000-0x101f]
<7>[    2.819175] pci 0000:01:00.1: reg 0x1c: [mem 0xb1940000-0xb1943fff]
<7>[    2.826632] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
<6>[    2.833850] pci 0000:01:00.1: System wakeup disabled by ACPI
<6>[    2.841326] pci 0000:00:01.0: PCI bridge to [bus 01]
<7>[    2.847263] pci 0000:00:01.0:   bridge window [io  0x1000-0x1fff]
<7>[    2.854455] pci 0000:00:01.0:   bridge window [mem 0xb1900000-0xb19fffff]
<6>[    2.862464] pci 0000:00:03.0: PCI bridge to [bus 02]
<6>[    2.868438] pci 0000:00:05.0: PCI bridge to [bus 03]
<6>[    2.874418] pci 0000:00:07.0: PCI bridge to [bus 04]
<6>[    2.880421] pci 0000:00:09.0: PCI bridge to [bus 05]
<6>[    2.886403] pci 0000:00:0a.0: PCI bridge to [bus 06]
<6>[    2.892400] pci 0000:00:1c.0: PCI bridge to [bus 07]
<7>[    2.898324] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
<7>[    2.905524] pci 0000:00:1c.0:   bridge window [mem 0xb1b00000-0xb1cfffff]
<7>[    2.913503] pci 0000:00:1c.0:   bridge window [mem 0xb1d00000-0xb1efffff 64bit pref]
<7>[    2.922938] pci 0000:08:00.0: [102b:0522] type 00 class 0x030000
<7>[    2.930055] pci 0000:08:00.0: reg 0x10: [mem 0xb0000000-0xb0ffffff pref]
<7>[    2.937950] pci 0000:08:00.0: reg 0x14: [mem 0xb1800000-0xb1803fff]
<7>[    2.945345] pci 0000:08:00.0: reg 0x18: [mem 0xb1000000-0xb17fffff]
<7>[    2.952770] pci 0000:08:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
<6>[    2.966400] pci 0000:00:1c.4: PCI bridge to [bus 08]
<7>[    2.972337] pci 0000:00:1c.4:   bridge window [io  0x4000-0x4fff]
<7>[    2.979537] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
<7>[    2.987520] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
<6>[    2.996936] pci 0000:00:1c.5: PCI bridge to [bus 09]
<7>[    3.002868] pci 0000:00:1c.5:   bridge window [io  0x5000-0x5fff]
<7>[    3.010066] pci 0000:00:1c.5:   bridge window [mem 0xb1f00000-0xb20fffff]
<7>[    3.018044] pci 0000:00:1c.5:   bridge window [mem 0xb2100000-0xb22fffff 64bit pref]
<6>[    3.027462] pci 0000:00:1e.0: PCI bridge to [bus 0a] (subtractive decode)
<7>[    3.035447] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
<7>[    3.044990] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
<7>[    3.054546] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
<7>[    3.064886] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
<7>[    3.075219] pci 0000:00:1e.0:   bridge window [mem 0xb0000000-0xfdffffff] (subtractive decode)
<6>[    3.085579] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
<6>[    3.102393] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
<6>[    3.112087] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
<6>[    3.121803] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
<6>[    3.131517] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
<6>[    3.141241] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<6>[    3.152359] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<6>[    3.163431] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<6>[    3.174526] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<4>[    3.185773] ACPI: Enabled 1 GPEs in block 00 to 3F
<6>[    3.191812] vgaarb: device added: PCI:0000:08:00.0,decodes=io+mem,owns=io+mem,locks=none
<6>[    3.201550] vgaarb: loaded
<6>[    3.204957] vgaarb: bridge control possible 0000:08:00.0
<5>[    3.211369] SCSI subsystem initialized
<7>[    3.216013] libata version 3.00 loaded.
<6>[    3.220733] ACPI: bus type USB registered
<6>[    3.225619] usbcore: registered new interface driver usbfs
<6>[    3.232143] usbcore: registered new interface driver hub
<6>[    3.238488] usbcore: registered new device driver usb
<6>[    3.244544] pps_core: LinuxPPS API ver. 1 registered
<6>[    3.250471] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
<6>[    3.261392] PTP clock support registered
<6>[    3.266260] EDAC MC: Ver: 3.0.0
<6>[    3.270307] PCI: Using ACPI for IRQ routing
<6>[    3.280650] PCI: Discovered peer bus fe
<7>[    3.285321] PCI: root bus fe: using default resources
<7>[    3.291356] PCI: Probing PCI hardware (bus fe)
<6>[    3.296724] PCI host bridge to bus 0000:fe
<6>[    3.301680] pci_bus 0000:fe: root bus resource [io  0x0000-0xffff]
<6>[    3.308967] pci_bus 0000:fe: root bus resource [mem 0x00000000-0xffffffffff]
<6>[    3.317226] pci_bus 0000:fe: No busn resource found for root bus, will use [bus fe-ff]
<7>[    3.326774] pci 0000:fe:00.0: [8086:2c40] type 00 class 0x060000
<7>[    3.333930] pci 0000:fe:00.1: [8086:2c01] type 00 class 0x060000
<7>[    3.341071] pci 0000:fe:02.0: [8086:2c10] type 00 class 0x060000
<7>[    3.348222] pci 0000:fe:02.1: [8086:2c11] type 00 class 0x060000
<7>[    3.355357] pci 0000:fe:02.4: [8086:2c14] type 00 class 0x060000
<7>[    3.362508] pci 0000:fe:02.5: [8086:2c15] type 00 class 0x060000
<7>[    3.369643] pci 0000:fe:03.0: [8086:2c18] type 00 class 0x060000
<7>[    3.376793] pci 0000:fe:03.1: [8086:2c19] type 00 class 0x060000
<7>[    3.383929] pci 0000:fe:03.2: [8086:2c1a] type 00 class 0x060000
<7>[    3.391079] pci 0000:fe:03.4: [8086:2c1c] type 00 class 0x060000
<7>[    3.398219] pci 0000:fe:04.0: [8086:2c20] type 00 class 0x060000
<7>[    3.405368] pci 0000:fe:04.1: [8086:2c21] type 00 class 0x060000
<7>[    3.412506] pci 0000:fe:04.2: [8086:2c22] type 00 class 0x060000
<7>[    3.419656] pci 0000:fe:04.3: [8086:2c23] type 00 class 0x060000
<7>[    3.426803] pci 0000:fe:05.0: [8086:2c28] type 00 class 0x060000
<7>[    3.433954] pci 0000:fe:05.1: [8086:2c29] type 00 class 0x060000
<7>[    3.441097] pci 0000:fe:05.2: [8086:2c2a] type 00 class 0x060000
<7>[    3.448250] pci 0000:fe:05.3: [8086:2c2b] type 00 class 0x060000
<7>[    3.455398] pci 0000:fe:06.0: [8086:2c30] type 00 class 0x060000
<7>[    3.462549] pci 0000:fe:06.1: [8086:2c31] type 00 class 0x060000
<7>[    3.469695] pci 0000:fe:06.2: [8086:2c32] type 00 class 0x060000
<7>[    3.476846] pci 0000:fe:06.3: [8086:2c33] type 00 class 0x060000
<7>[    3.484002] pci_bus 0000:fe: busn_res: [bus fe-ff] end is updated to fe
<6>[    3.491790] PCI: Discovered peer bus ff
<7>[    3.496457] PCI: root bus ff: using default resources
<7>[    3.502480] PCI: Probing PCI hardware (bus ff)
<6>[    3.507857] PCI host bridge to bus 0000:ff
<6>[    3.512818] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
<6>[    3.520113] pci_bus 0000:ff: root bus resource [mem 0x00000000-0xffffffffff]
<6>[    3.528387] pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
<7>[    3.537953] pci 0000:ff:00.0: [8086:2c40] type 00 class 0x060000
<7>[    3.545104] pci 0000:ff:00.1: [8086:2c01] type 00 class 0x060000
<7>[    3.552244] pci 0000:ff:02.0: [8086:2c10] type 00 class 0x060000
<7>[    3.559383] pci 0000:ff:02.1: [8086:2c11] type 00 class 0x060000
<7>[    3.566532] pci 0000:ff:02.4: [8086:2c14] type 00 class 0x060000
<7>[    3.573671] pci 0000:ff:02.5: [8086:2c15] type 00 class 0x060000
<7>[    3.580815] pci 0000:ff:03.0: [8086:2c18] type 00 class 0x060000
<7>[    3.587967] pci 0000:ff:03.1: [8086:2c19] type 00 class 0x060000
<7>[    3.595113] pci 0000:ff:03.2: [8086:2c1a] type 00 class 0x060000
<7>[    3.602257] pci 0000:ff:03.4: [8086:2c1c] type 00 class 0x060000
<7>[    3.609404] pci 0000:ff:04.0: [8086:2c20] type 00 class 0x060000
<7>[    3.616554] pci 0000:ff:04.1: [8086:2c21] type 00 class 0x060000
<7>[    3.623704] pci 0000:ff:04.2: [8086:2c22] type 00 class 0x060000
<7>[    3.630855] pci 0000:ff:04.3: [8086:2c23] type 00 class 0x060000
<7>[    3.638006] pci 0000:ff:05.0: [8086:2c28] type 00 class 0x060000
<7>[    3.645154] pci 0000:ff:05.1: [8086:2c29] type 00 class 0x060000
<7>[    3.652305] pci 0000:ff:05.2: [8086:2c2a] type 00 class 0x060000
<7>[    3.659451] pci 0000:ff:05.3: [8086:2c2b] type 00 class 0x060000
<7>[    3.666591] pci 0000:ff:06.0: [8086:2c30] type 00 class 0x060000
<7>[    3.673734] pci 0000:ff:06.1: [8086:2c31] type 00 class 0x060000
<7>[    3.680882] pci 0000:ff:06.2: [8086:2c32] type 00 class 0x060000
<7>[    3.688028] pci 0000:ff:06.3: [8086:2c33] type 00 class 0x060000
<7>[    3.695185] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
<7>[    3.702683] PCI: pci_cache_line_size set to 64 bytes
<7>[    3.708728] e820: reserve RAM buffer [mem 0x0009a400-0x0009ffff]
<7>[    3.715834] e820: reserve RAM buffer [mem 0x8c556000-0x8fffffff]
<6>[    3.723467] HPET: 4 timers in total, 0 timers will be used for per-cpu timer
<6>[    3.731742] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
<6>[    3.738212] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
<6>[    3.747984] Switched to clocksource hpet
<4>[    3.752831] Could not create debugfs 'set_ftrace_filter' entry
<4>[    3.759741] Could not create debugfs 'set_ftrace_notrace' entry
<6>[    3.776586] pnp: PnP ACPI init
<6>[    3.780402] ACPI: bus type PNP registered
<7>[    3.785345] pnp 00:00: Plug and Play ACPI device, IDs PNP0003 (active)
<7>[    3.793202] pnp 00:01: [dma 4]
<7>[    3.797029] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
<7>[    3.804733] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
<7>[    3.814329] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
<7>[    3.822025] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
<7>[    3.831804] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
<7>[    3.839524] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
<7>[    3.847281] pnp 00:05: Plug and Play ACPI device, IDs PNP0103 (active)
<6>[    3.855074] system 00:06: [io  0x0500-0x057f] could not be reserved
<6>[    3.862467] system 00:06: [io  0x0400-0x047f] could not be reserved
<6>[    3.869863] system 00:06: [io  0x0800-0x081f] has been reserved
<6>[    3.876867] system 00:06: [io  0x0ca2-0x0ca3] has been reserved
<6>[    3.883872] system 00:06: [io  0x0600-0x061f] has been reserved
<6>[    3.890880] system 00:06: [io  0x0880-0x0883] has been reserved
<6>[    3.897889] system 00:06: [io  0x0ca4-0x0ca5] has been reserved
<6>[    3.904897] system 00:06: [mem 0xfed1c000-0xfed3fffe] could not be reserved
<6>[    3.913063] system 00:06: [mem 0xff000000-0xffffffff] could not be reserved
<6>[    3.921234] system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
<6>[    3.929008] system 00:06: [mem 0xfe900000-0xfe90001f] has been reserved
<6>[    3.936781] system 00:06: [mem 0xfea00000-0xfea0001f] has been reserved
<6>[    3.944550] system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
<7>[    3.952321] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
<7>[    3.960410] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
<7>[    3.970037] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
<7>[    3.977829] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
<7>[    3.987456] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
<7>[    3.995197] pnp 00:09: Plug and Play ACPI device, IDs IPI0001 (active)
<6>[    4.002931] pnp: PnP ACPI: found 10 devices
<6>[    4.007983] ACPI: bus type PNP unregistered
<6>[    4.019732] pci 0000:08:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
<4>[    4.031589] pci 0000:00:1f.0: BAR 13: [io  0x0400-0x047f] has bogus alignment
<6>[    4.039949] pci 0000:00:01.0: PCI bridge to [bus 01]
<6>[    4.045891] pci 0000:00:01.0:   bridge window [io  0x1000-0x1fff]
<6>[    4.053094] pci 0000:00:01.0:   bridge window [mem 0xb1900000-0xb19fffff]
<6>[    4.061075] pci 0000:00:03.0: PCI bridge to [bus 02]
<6>[    4.067020] pci 0000:00:05.0: PCI bridge to [bus 03]
<6>[    4.072964] pci 0000:00:07.0: PCI bridge to [bus 04]
<6>[    4.078892] pci 0000:00:09.0: PCI bridge to [bus 05]
<6>[    4.084829] pci 0000:00:0a.0: PCI bridge to [bus 06]
<6>[    4.090766] pci 0000:00:1c.0: PCI bridge to [bus 07]
<6>[    4.096699] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
<6>[    4.103893] pci 0000:00:1c.0:   bridge window [mem 0xb1b00000-0xb1cfffff]
<6>[    4.111873] pci 0000:00:1c.0:   bridge window [mem 0xb1d00000-0xb1efffff 64bit pref]
<6>[    4.121229] pci 0000:08:00.0: BAR 6: assigned [mem 0xb1810000-0xb181ffff pref]
<6>[    4.130011] pci 0000:00:1c.4: PCI bridge to [bus 08]
<6>[    4.135941] pci 0000:00:1c.4:   bridge window [io  0x4000-0x4fff]
<6>[    4.143145] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
<6>[    4.151112] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
<6>[    4.160484] pci 0000:00:1c.5: PCI bridge to [bus 09]
<6>[    4.166424] pci 0000:00:1c.5:   bridge window [io  0x5000-0x5fff]
<6>[    4.173628] pci 0000:00:1c.5:   bridge window [mem 0xb1f00000-0xb20fffff]
<6>[    4.181607] pci 0000:00:1c.5:   bridge window [mem 0xb2100000-0xb22fffff 64bit pref]
<6>[    4.190958] pci 0000:00:1e.0: PCI bridge to [bus 0a]
<7>[    4.196894] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
<7>[    4.203510] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
<7>[    4.210124] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    4.217522] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
<7>[    4.224916] pci_bus 0000:00: resource 8 [mem 0xb0000000-0xfdffffff]
<7>[    4.232312] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
<7>[    4.238928] pci_bus 0000:01: resource 1 [mem 0xb1900000-0xb19fffff]
<7>[    4.246317] pci_bus 0000:07: resource 0 [io  0x3000-0x3fff]
<7>[    4.252933] pci_bus 0000:07: resource 1 [mem 0xb1b00000-0xb1cfffff]
<7>[    4.260328] pci_bus 0000:07: resource 2 [mem 0xb1d00000-0xb1efffff 64bit pref]
<7>[    4.277043] pci_bus 0000:08: resource 0 [io  0x4000-0x4fff]
<7>[    4.283649] pci_bus 0000:08: resource 1 [mem 0xb1000000-0xb18fffff]
<7>[    4.291034] pci_bus 0000:08: resource 2 [mem 0xb0000000-0xb0ffffff 64bit pref]
<7>[    4.299807] pci_bus 0000:09: resource 0 [io  0x5000-0x5fff]
<7>[    4.306418] pci_bus 0000:09: resource 1 [mem 0xb1f00000-0xb20fffff]
<7>[    4.313811] pci_bus 0000:09: resource 2 [mem 0xb2100000-0xb22fffff 64bit pref]
<7>[    4.322568] pci_bus 0000:0a: resource 4 [io  0x0000-0x0cf7]
<7>[    4.329184] pci_bus 0000:0a: resource 5 [io  0x0d00-0xffff]
<7>[    4.335792] pci_bus 0000:0a: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    4.343188] pci_bus 0000:0a: resource 7 [mem 0xfed40000-0xfedfffff]
<7>[    4.350571] pci_bus 0000:0a: resource 8 [mem 0xb0000000-0xfdffffff]
<7>[    4.357971] pci_bus 0000:fe: resource 4 [io  0x0000-0xffff]
<7>[    4.364583] pci_bus 0000:fe: resource 5 [mem 0x00000000-0xffffffffff]
<7>[    4.372175] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
<7>[    4.378779] pci_bus 0000:ff: resource 5 [mem 0x00000000-0xffffffffff]
<6>[    4.386412] NET: Registered protocol family 2
<6>[    4.391891] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
<6>[    4.401135] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
<6>[    4.409183] TCP: Hash tables configured (established 131072 bind 65536)
<6>[    4.416991] TCP: reno registered
<6>[    4.420989] UDP hash table entries: 8192 (order: 6, 262144 bytes)
<6>[    4.428251] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
<6>[    4.436050] NET: Registered protocol family 1
<6>[    4.441411] RPC: Registered named UNIX socket transport module.
<6>[    4.448408] RPC: Registered udp transport module.
<6>[    4.454049] RPC: Registered tcp transport module.
<6>[    4.459688] RPC: Registered tcp NFSv4.1 backchannel transport module.
<7>[    4.520311] IOAPIC[0]: Set routing entry (8-19 -> 0x41 -> IRQ 19 Mode:1 Active:1 Dest:0)
<7>[    4.530996] IOAPIC[0]: Set routing entry (8-16 -> 0x51 -> IRQ 16 Mode:1 Active:1 Dest:0)
<6>[    4.541560] pci 0000:01:00.0: Disabling L0s
<4>[    4.546610] pci 0000:01:00.0: can't disable ASPM; OS doesn't have ASPM control
<6>[    4.555378] pci 0000:01:00.1: Disabling L0s
<4>[    4.560426] pci 0000:01:00.1: can't disable ASPM; OS doesn't have ASPM control
<7>[    4.569221] pci 0000:08:00.0: Boot video device
<7>[    4.574699] PCI: CLS 64 bytes, default 64
<6>[    4.579599] Trying to unpack rootfs image as initramfs...
<6>[    8.232342] Freeing initrd memory: 213136K (ffff880072fd1000 - ffff88007fff5000)
<6>[    8.241336] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
<6>[    8.248935] software IO TLB [mem 0x88556000-0x8c556000] (64MB) mapped at [ffff880088556000-ffff88008c555fff]
<4>[    8.261272] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work properly. Using workaround
<6>[    8.272302] Scanning for low memory corruption every 60 seconds
<6>[    8.280640] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
<6>[    8.287978] PCLMULQDQ-NI instructions are not detected.
<6>[    8.294209] AVX or AES-NI instructions are not detected.
<6>[    8.300523] AVX instructions are not detected.
<6>[    8.305873] AVX instructions are not detected.
<6>[    8.311222] AVX instructions are not detected.
<6>[    8.316568] AVX instructions are not detected.
<6>[    8.322502] futex hash table entries: 8192 (order: 7, 524288 bytes)
<4>[    8.352119] bounce pool size: 64 pages
<6>[    8.356698] HugeTLB registered 2 MB page size, pre-allocated 0 pages
<5>[    8.366371] VFS: Disk quotas dquot_6.5.2
<4>[    8.371195] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
<5>[    8.379668] NFS: Registering the id_resolver key type
<5>[    8.385701] Key type id_resolver registered
<5>[    8.390756] Key type id_legacy registered
<6>[    8.395624] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
<6>[    8.403504] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
<6>[    8.411293] ROMFS MTD (C) 2007 Red Hat, Inc.
<6>[    8.416517] fuse init (API version 7.22)
<6>[    8.421421] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
<6>[    8.433300] msgmni has been set to 23893
<6>[    8.440540] NET: Registered protocol family 38
<5>[    8.445894] Key type asymmetric registered
<6>[    8.450898] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
<6>[    8.459919] io scheduler noop registered
<6>[    8.464680] io scheduler deadline registered
<6>[    8.469831] io scheduler cfq registered (default)
<7>[    8.475788] IOAPIC[1]: Set routing entry (9-4 -> 0x61 -> IRQ 28 Mode:1 Active:1 Dest:0)
<7>[    8.485476] pcieport 0000:00:01.0: irq 64 for MSI/MSI-X
<7>[    8.491889] IOAPIC[1]: Set routing entry (9-0 -> 0x81 -> IRQ 24 Mode:1 Active:1 Dest:0)
<7>[    8.501563] pcieport 0000:00:03.0: irq 65 for MSI/MSI-X
<7>[    8.507972] IOAPIC[1]: Set routing entry (9-2 -> 0xa1 -> IRQ 26 Mode:1 Active:1 Dest:0)
<7>[    8.517654] pcieport 0000:00:05.0: irq 66 for MSI/MSI-X
<7>[    8.524049] IOAPIC[1]: Set routing entry (9-6 -> 0xc1 -> IRQ 30 Mode:1 Active:1 Dest:0)
<7>[    8.533713] pcieport 0000:00:07.0: irq 67 for MSI/MSI-X
<7>[    8.540111] IOAPIC[1]: Set routing entry (9-8 -> 0xe1 -> IRQ 32 Mode:1 Active:1 Dest:0)
<7>[    8.549784] pcieport 0000:00:09.0: irq 68 for MSI/MSI-X
<7>[    8.556187] IOAPIC[1]: Set routing entry (9-9 -> 0x42 -> IRQ 33 Mode:1 Active:1 Dest:0)
<7>[    8.565868] pcieport 0000:00:0a.0: irq 69 for MSI/MSI-X
<7>[    8.572308] pcieport 0000:00:1c.0: irq 70 for MSI/MSI-X
<7>[    8.578763] pcieport 0000:00:1c.4: irq 71 for MSI/MSI-X
<7>[    8.585190] IOAPIC[0]: Set routing entry (8-17 -> 0x82 -> IRQ 17 Mode:1 Active:1 Dest:0)
<7>[    8.594965] pcieport 0000:00:1c.5: irq 72 for MSI/MSI-X
<7>[    8.601314] aer 0000:00:01.0:pcie02: service driver aer loaded
<7>[    8.608236] aer 0000:00:03.0:pcie02: service driver aer loaded
<7>[    8.615159] aer 0000:00:05.0:pcie02: service driver aer loaded
<7>[    8.622090] aer 0000:00:07.0:pcie02: service driver aer loaded
<7>[    8.629028] aer 0000:00:09.0:pcie02: service driver aer loaded
<7>[    8.635956] aer 0000:00:0a.0:pcie02: service driver aer loaded
<6>[    8.642880] pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
<6>[    8.651060] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
<6>[    8.658748] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
<7>[    8.666433] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
<6>[    8.674323] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
<7>[    8.682495] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
<6>[    8.690376] pcieport 0000:00:05.0: Signaling PME through PCIe PME interrupt
<7>[    8.698542] pcie_pme 0000:00:05.0:pcie01: service driver pcie_pme loaded
<6>[    8.706430] pcieport 0000:00:07.0: Signaling PME through PCIe PME interrupt
<7>[    8.714594] pcie_pme 0000:00:07.0:pcie01: service driver pcie_pme loaded
<6>[    8.722472] pcieport 0000:00:09.0: Signaling PME through PCIe PME interrupt
<7>[    8.730643] pcie_pme 0000:00:09.0:pcie01: service driver pcie_pme loaded
<6>[    8.738535] pcieport 0000:00:0a.0: Signaling PME through PCIe PME interrupt
<7>[    8.746709] pcie_pme 0000:00:0a.0:pcie01: service driver pcie_pme loaded
<6>[    8.754608] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
<7>[    8.762783] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
<6>[    8.770667] pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
<6>[    8.778844] pci 0000:08:00.0: Signaling PME through PCIe PME interrupt
<7>[    8.786531] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
<6>[    8.794426] pcieport 0000:00:1c.5: Signaling PME through PCIe PME interrupt
<7>[    8.802603] pcie_pme 0000:00:1c.5:pcie01: service driver pcie_pme loaded
<4>[    8.810498] ioapic: probe of 0000:00:13.0 failed with error -22
<4>[    8.817513] ioapic: probe of 0000:00:15.0 failed with error -22
<6>[    8.824535] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
<6>[    8.831200] pciehp 0000:00:1c.0:pcie04: Slot #1 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
<7>[    8.843837] pciehp 0000:00:1c.0:pcie04: service driver pciehp loaded
<6>[    8.851349] pciehp 0000:00:1c.4:pcie04: Slot #5 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
<7>[    8.863973] pciehp 0000:00:1c.4:pcie04: service driver pciehp loaded
<6>[    8.871474] pciehp 0000:00:1c.5:pcie04: Slot #6 AttnBtn- AttnInd- PwrInd- PwrCtrl- MRL- Interlock- NoCompl- LLActRep+
<7>[    8.884096] pciehp 0000:00:1c.5:pcie04: service driver pciehp loaded
<6>[    8.891598] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
<7>[    8.899376] intel_idle: MWAIT substates: 0x1120
<7>[    8.904848] intel_idle: v0.4 model 0x1A
<7>[    8.909513] intel_idle: lapic_timer_reliable_states 0x2
<6>[    8.916415] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
<6>[    8.926471] ACPI: Sleep Button [SLPB]
<6>[    8.930996] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
<6>[    8.939977] ACPI: Power Button [PWRF]
<6>[    8.944534] ERST: Error Record Serialization Table (ERST) support is initialized.
<6>[    8.953606] pstore: Registered erst as persistent store backend
<6>[    8.960871] ghes_edac: This EDAC driver relies on BIOS to enumerate memory and get error reports.
<6>[    8.971511] ghes_edac: Unfortunately, not all BIOSes reflect the memory layout correctly.
<6>[    8.981356] ghes_edac: So, the end result of using this driver varies from vendor to vendor.
<6>[    8.991507] ghes_edac: If you find incorrect reports, please contact your hardware vendor
<6>[    9.001358] ghes_edac: to correct its BIOS.
<6>[    9.006412] ghes_edac: This system has 12 DIMM sockets.
<6>[    9.013136] EDAC MC0: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
<6>[    9.024738] EDAC MC1: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
<6>[    9.036452] GHES: APEI firmware first mode is enabled by WHEA _OSC.
<6>[    9.043850] EINJ: Error INJection is initialized.
<6>[    9.049581] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
<6>[    9.077422] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
<6>[    9.106753] 00:08: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
<6>[    9.116114] Non-volatile memory driver v1.3
<6>[    9.123022] brd: module loaded
<6>[    9.127705] loop: module loaded
<6>[    9.139586] lkdtm: No crash points registered, enable through debugfs
<4>[    9.147224] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0) (20140214/utaddress-258)
<6>[    9.165708] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
<4>[    9.177795] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000052f (\_SI_.SIOR) (20140214/utaddress-258)
<6>[    9.196754] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
<4>[    9.208856] lpc_ich: Resource conflict(s) found affecting gpio_ich
<6>[    9.216209] Loading iSCSI transport class v2.0-870.
<6>[    9.222294] Adaptec aacraid driver 1.2-0[30300]-ms
<5>[    9.228054] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
<4>[    9.236082] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.02-k.
<6>[    9.245964] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
<6>[    9.254928] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
<6>[    9.263130] megasas: 06.803.01.00-rc1 Mon. Mar. 10 17:00:00 PDT 2014
<6>[    9.270634] tsc: Refined TSC clocksource calibration: 2926.329 MHz
<4>[    9.277978] GDT-HA: Storage RAID Controller Driver. Version: 3.05
<6>[    9.285198] RocketRAID 3xxx/4xxx Controller driver v1.8
<7>[    9.291521] ahci 0000:00:1f.2: version 3.0
<7>[    9.296615] IOAPIC[0]: Set routing entry (8-18 -> 0xa2 -> IRQ 18 Mode:1 Active:1 Dest:0)
<7>[    9.306410] ahci 0000:00:1f.2: irq 73 for MSI/MSI-X
<6>[    9.312284] ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0xa impl SATA mode
<6>[    9.322042] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ccc 
<6>[    9.331945] scsi0 : ahci
<6>[    9.335298] scsi1 : ahci
<6>[    9.338644] scsi2 : ahci
<6>[    9.341995] scsi3 : ahci
<6>[    9.345337] scsi4 : ahci
<6>[    9.348663] scsi5 : ahci
<6>[    9.351936] ata1: DUMMY
<6>[    9.355056] ata2: SATA max UDMA/133 abar m2048@0xb1a20000 port 0xb1a20180 irq 73
<6>[    9.364020] ata3: DUMMY
<6>[    9.367129] ata4: SATA max UDMA/133 abar m2048@0xb1a20000 port 0xb1a20280 irq 73
<6>[    9.376103] ata5: DUMMY
<6>[    9.379215] ata6: DUMMY
<6>[    9.382472] tun: Universal TUN/TAP device driver, 1.6
<6>[    9.388544] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
<6>[    9.396008] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
<6>[    9.404137] Atheros(R) L2 Ethernet Driver - version 2.2.3
<6>[    9.410568] Copyright (c) 2007 Atheros Corporation.
<6>[    9.416536] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
<4>[    9.424430] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
<4>[    9.424430]   http://www.scyld.com/network/drivers.html
<6>[    9.438949] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
<6>[    9.447066] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
<6>[    9.454271] e100: Copyright(c) 1999-2006 Intel Corporation
<6>[    9.460808] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
<6>[    9.469085] e1000: Copyright (c) 1999-2006 Intel Corporation.
<6>[    9.475915] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
<6>[    9.482830] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
<6>[    9.489868] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
<6>[    9.498048] igb: Copyright (c) 2007-2014 Intel Corporation.
<7>[    9.504706] IOAPIC[1]: Set routing entry (9-16 -> 0xc2 -> IRQ 40 Mode:1 Active:1 Dest:0)
<7>[    9.514676] igb 0000:01:00.0: irq 74 for MSI/MSI-X
<7>[    9.520414] igb 0000:01:00.0: irq 75 for MSI/MSI-X
<7>[    9.526149] igb 0000:01:00.0: irq 76 for MSI/MSI-X
<7>[    9.531889] igb 0000:01:00.0: irq 77 for MSI/MSI-X
<7>[    9.537633] igb 0000:01:00.0: irq 78 for MSI/MSI-X
<7>[    9.543381] igb 0000:01:00.0: irq 79 for MSI/MSI-X
<7>[    9.549125] igb 0000:01:00.0: irq 80 for MSI/MSI-X
<7>[    9.554873] igb 0000:01:00.0: irq 81 for MSI/MSI-X
<7>[    9.560616] igb 0000:01:00.0: irq 82 for MSI/MSI-X
<7>[    9.566420] igb 0000:01:00.0: irq 74 for MSI/MSI-X
<7>[    9.572167] igb 0000:01:00.0: irq 75 for MSI/MSI-X
<7>[    9.577904] igb 0000:01:00.0: irq 76 for MSI/MSI-X
<7>[    9.583644] igb 0000:01:00.0: irq 77 for MSI/MSI-X
<7>[    9.589379] igb 0000:01:00.0: irq 78 for MSI/MSI-X
<7>[    9.595113] igb 0000:01:00.0: irq 79 for MSI/MSI-X
<7>[    9.600857] igb 0000:01:00.0: irq 80 for MSI/MSI-X
<7>[    9.606597] igb 0000:01:00.0: irq 81 for MSI/MSI-X
<7>[    9.612336] igb 0000:01:00.0: irq 82 for MSI/MSI-X
<6>[    9.701321] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[    9.708640] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[    9.716144] ata2.00: ATA-8: ST3500514NS, SN11, max UDMA/133
<6>[    9.722823] ata2.00: 976773168 sectors, multi 0: LBA48 NCQ (depth 31/32)
<6>[    9.730785] ata4.00: ATA-6: ST3120026AS, 3.00, max UDMA/133
<6>[    9.737410] ata4.00: 234441648 sectors, multi 0: LBA48 NCQ (depth 31/32)
<6>[    9.746721] ata2.00: configured for UDMA/133
<6>[    9.752035] ata4.00: configured for UDMA/133
<5>[    9.752149] scsi 1:0:0:0: Direct-Access     ATA      ST3500514NS      SN11 PQ: 0 ANSI: 5
<5>[    9.752406] sd 1:0:0:0: Attached scsi generic sg0 type 0
<5>[    9.752451] sd 1:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
<5>[    9.752481] sd 1:0:0:0: [sda] Write Protect is off
<7>[    9.752482] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
<5>[    9.752496] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
<6>[    9.804936]  sda: sda1 sda2 sda3
<5>[    9.805338] scsi 3:0:0:0: Direct-Access     ATA      ST3120026AS      3.00 PQ: 0 ANSI: 5
<5>[    9.805507] sd 3:0:0:0: Attached scsi generic sg1 type 0
<5>[    9.805534] sd 3:0:0:0: [sdb] 234441648 512-byte logical blocks: (120 GB/111 GiB)
<5>[    9.805567] sd 3:0:0:0: [sdb] Write Protect is off
<7>[    9.805569] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
<5>[    9.805585] sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
<6>[    9.812014] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
<6>[    9.812017] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:15:17:e6:9d:cc
<6>[    9.812019] igb 0000:01:00.0: eth0: PBA No: Unknown
<6>[    9.812023] igb 0000:01:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
<7>[    9.812323] igb 0000:01:00.1: irq 83 for MSI/MSI-X
<7>[    9.812328] igb 0000:01:00.1: irq 84 for MSI/MSI-X
<7>[    9.812332] igb 0000:01:00.1: irq 85 for MSI/MSI-X
<7>[    9.812336] igb 0000:01:00.1: irq 86 for MSI/MSI-X
<7>[    9.812340] igb 0000:01:00.1: irq 87 for MSI/MSI-X
<7>[    9.812344] igb 0000:01:00.1: irq 88 for MSI/MSI-X
<7>[    9.812348] igb 0000:01:00.1: irq 89 for MSI/MSI-X
<7>[    9.812352] igb 0000:01:00.1: irq 90 for MSI/MSI-X
<7>[    9.812355] igb 0000:01:00.1: irq 91 for MSI/MSI-X
<7>[    9.812408] igb 0000:01:00.1: irq 83 for MSI/MSI-X
<7>[    9.812412] igb 0000:01:00.1: irq 84 for MSI/MSI-X
<7>[    9.812415] igb 0000:01:00.1: irq 85 for MSI/MSI-X
<7>[    9.812419] igb 0000:01:00.1: irq 86 for MSI/MSI-X
<7>[    9.812423] igb 0000:01:00.1: irq 87 for MSI/MSI-X
<7>[    9.812426] igb 0000:01:00.1: irq 88 for MSI/MSI-X
<7>[    9.812430] igb 0000:01:00.1: irq 89 for MSI/MSI-X
<7>[    9.812434] igb 0000:01:00.1: irq 90 for MSI/MSI-X
<7>[    9.812437] igb 0000:01:00.1: irq 91 for MSI/MSI-X
<6>[    9.826770]  sdb: sdb1 sdb2 sdb3
<5>[    9.827075] sd 3:0:0:0: [sdb] Attached SCSI disk
<5>[   10.001064] sd 1:0:0:0: [sda] Attached SCSI disk
<6>[   10.001760] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
<6>[   10.001761] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:15:17:e6:9d:cd
<6>[   10.001763] igb 0000:01:00.1: eth1: PBA No: Unknown
<6>[   10.001764] igb 0000:01:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
<6>[   10.001786] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.19.1-k
<6>[   10.001789] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
<6>[   10.001817] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
<6>[   10.001818] ixgb: Copyright (c) 1999-2008 Intel Corporation.
<6>[   10.001861] sky2: driver version 1.30
<6>[   10.002072] usbcore: registered new interface driver catc
<6>[   10.002087] usbcore: registered new interface driver kaweth
<6>[   10.002088] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
<6>[   10.002099] usbcore: registered new interface driver pegasus
<6>[   10.002110] usbcore: registered new interface driver rtl8150
<6>[   10.002128] usbcore: registered new interface driver asix
<6>[   10.002139] usbcore: registered new interface driver ax88179_178a
<6>[   10.002152] usbcore: registered new interface driver cdc_ether
<6>[   10.002169] usbcore: registered new interface driver cdc_eem
<6>[   10.002185] usbcore: registered new interface driver dm9601
<6>[   10.002199] usbcore: registered new interface driver smsc75xx
<6>[   10.002216] usbcore: registered new interface driver smsc95xx
<6>[   10.002228] usbcore: registered new interface driver gl620a
<6>[   10.002244] usbcore: registered new interface driver net1080
<6>[   10.002259] usbcore: registered new interface driver plusb
<6>[   10.002273] usbcore: registered new interface driver rndis_host
<6>[   10.002284] usbcore: registered new interface driver cdc_subset
<6>[   10.002296] usbcore: registered new interface driver zaurus
<6>[   10.002310] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
<6>[   10.002327] usbcore: registered new interface driver int51x1
<6>[   10.002339] usbcore: registered new interface driver ipheth
<6>[   10.002353] usbcore: registered new interface driver sierra_net
<6>[   10.002373] usbcore: registered new interface driver cdc_ncm
<6>[   10.002374] Fusion MPT base driver 3.04.20
<6>[   10.002375] Copyright (c) 1999-2008 LSI Corporation
<6>[   10.002382] Fusion MPT SPI Host driver 3.04.20
<6>[   10.002401] Fusion MPT FC Host driver 3.04.20
<6>[   10.002429] Fusion MPT SAS Host driver 3.04.20
<6>[   10.002453] Fusion MPT misc device (ioctl) driver 3.04.20
<6>[   10.002513] mptctl: Registered with Fusion MPT base driver
<6>[   10.002516] mptctl: /dev/mptctl @ (major,minor=10,220)
<6>[   10.002622] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
<6>[   10.002625] ehci-pci: EHCI PCI platform driver
<6>[   10.002806] ehci-pci 0000:00:1a.7: EHCI Host Controller
<6>[   10.002856] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 1
<6>[   10.002872] ehci-pci 0000:00:1a.7: debug port 1
<7>[   10.006799] ehci-pci 0000:00:1a.7: cache line size of 64 is not supported
<6>[   10.006814] ehci-pci 0000:00:1a.7: irq 19, io mem 0xb1a22000
<6>[   10.017318] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
<6>[   10.017480] hub 1-0:1.0: USB hub found
<6>[   10.017486] hub 1-0:1.0: 6 ports detected
<6>[   10.017789] ehci-pci 0000:00:1d.7: EHCI Host Controller
<6>[   10.017836] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 2
<6>[   10.017851] ehci-pci 0000:00:1d.7: debug port 1
<7>[   10.021752] ehci-pci 0000:00:1d.7: cache line size of 64 is not supported
<6>[   10.021764] ehci-pci 0000:00:1d.7: irq 16, io mem 0xb1a21000
<6>[   10.033321] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
<6>[   10.033609] hub 2-0:1.0: USB hub found
<6>[   10.033614] hub 2-0:1.0: 6 ports detected
<6>[   10.033779] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
<6>[   10.033784] ohci-pci: OHCI PCI platform driver
<6>[   10.033809] uhci_hcd: USB Universal Host Controller Interface driver
<6>[   10.033957] uhci_hcd 0000:00:1a.0: UHCI Host Controller
<6>[   10.034042] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
<6>[   10.034051] uhci_hcd 0000:00:1a.0: detected 2 ports
<6>[   10.034073] uhci_hcd 0000:00:1a.0: irq 19, io base 0x000020e0
<6>[   10.034328] hub 3-0:1.0: USB hub found
<6>[   10.034334] hub 3-0:1.0: 2 ports detected
<6>[   10.034556] uhci_hcd 0000:00:1a.1: UHCI Host Controller
<6>[   10.034714] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
<6>[   10.034721] uhci_hcd 0000:00:1a.1: detected 2 ports
<6>[   10.034743] uhci_hcd 0000:00:1a.1: irq 19, io base 0x000020c0
<6>[   10.034918] hub 4-0:1.0: USB hub found
<6>[   10.034924] hub 4-0:1.0: 2 ports detected
<6>[   10.035154] uhci_hcd 0000:00:1a.2: UHCI Host Controller
<6>[   10.035276] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
<6>[   10.035283] uhci_hcd 0000:00:1a.2: detected 2 ports
<6>[   10.035305] uhci_hcd 0000:00:1a.2: irq 19, io base 0x000020a0
<6>[   10.035469] hub 5-0:1.0: USB hub found
<6>[   10.035473] hub 5-0:1.0: 2 ports detected
<6>[   10.035703] uhci_hcd 0000:00:1d.0: UHCI Host Controller
<6>[   10.035796] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
<6>[   10.035803] uhci_hcd 0000:00:1d.0: detected 2 ports
<6>[   10.035826] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00002080
<6>[   10.036024] hub 6-0:1.0: USB hub found
<6>[   10.036028] hub 6-0:1.0: 2 ports detected
<6>[   10.036263] uhci_hcd 0000:00:1d.1: UHCI Host Controller
<6>[   10.036348] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
<6>[   10.036356] uhci_hcd 0000:00:1d.1: detected 2 ports
<6>[   10.036378] uhci_hcd 0000:00:1d.1: irq 16, io base 0x00002060
<6>[   10.036534] hub 7-0:1.0: USB hub found
<6>[   10.036538] hub 7-0:1.0: 2 ports detected
<6>[   10.036760] uhci_hcd 0000:00:1d.2: UHCI Host Controller
<6>[   10.036840] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
<6>[   10.036847] uhci_hcd 0000:00:1d.2: detected 2 ports
<6>[   10.036868] uhci_hcd 0000:00:1d.2: irq 16, io base 0x00002040
<6>[   10.037042] hub 8-0:1.0: USB hub found
<6>[   10.037046] hub 8-0:1.0: 2 ports detected
<6>[   10.037205] usbcore: registered new interface driver usb-storage
<6>[   10.037220] usbcore: registered new interface driver ums-alauda
<6>[   10.037237] usbcore: registered new interface driver ums-datafab
<6>[   10.037251] usbcore: registered new interface driver ums-freecom
<6>[   10.037268] usbcore: registered new interface driver ums-isd200
<6>[   10.037279] usbcore: registered new interface driver ums-jumpshot
<6>[   10.037292] usbcore: registered new interface driver ums-sddr09
<6>[   10.037330] usbcore: registered new interface driver ums-sddr55
<6>[   10.037341] usbcore: registered new interface driver ums-usbat
<6>[   10.037363] usbcore: registered new interface driver usbtest
<6>[   10.037426] i8042: PNP: No PS/2 controller found. Probing ports directly.
<3>[   11.074330] i8042: No controller found
<6>[   11.078916] Switched to clocksource tsc
<6>[   11.078996] mousedev: PS/2 mouse device common for all mice
<6>[   11.079398] rtc_cmos 00:02: RTC can wake from S4
<6>[   11.079621] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
<6>[   11.079654] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
<6>[   11.079679] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
<6>[   11.079692] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
<6>[   11.079700] iTCO_vendor_support: vendor-support=0
<6>[   11.079815] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
<6>[   11.079816] md: linear personality registered for level -1
<6>[   11.079817] md: raid0 personality registered for level 0
<6>[   11.079817] md: raid1 personality registered for level 1
<6>[   11.079818] md: raid10 personality registered for level 10
<6>[   11.079980] md: raid6 personality registered for level 6
<6>[   11.079980] md: raid5 personality registered for level 5
<6>[   11.079981] md: raid4 personality registered for level 4
<6>[   11.079982] md: multipath personality registered for level -4
<6>[   11.079983] md: faulty personality registered for level -5
<6>[   11.080651] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
<6>[   11.081284] device-mapper: multipath: version 1.7.0 loaded
<6>[   11.081285] device-mapper: multipath round-robin: version 1.0.0 loaded
<6>[   11.081303] device-mapper: cache-policy-mq: version 1.2.0 loaded
<6>[   11.081304] device-mapper: cache cleaner: version 1.0.0 loaded
<6>[   11.081390] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
<6>[   11.081670] usbcore: registered new interface driver usbhid
<6>[   11.081670] usbhid: USB HID core driver
<6>[   11.081757] TCP: bic registered
<6>[   11.081758] Initializing XFRM netlink socket
<6>[   11.081901] NET: Registered protocol family 10
<6>[   11.082122] sit: IPv6 over IPv4 tunneling driver
<6>[   11.082250] NET: Registered protocol family 17
<6>[   11.082267] 8021q: 802.1Q VLAN Support v1.8
<6>[   11.083285] DCCP: Activated CCID 2 (TCP-like)
<6>[   11.083293] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
<6>[   11.083774] sctp: Hash tables configured (established 65536 bind 65536)
<6>[   11.083857] tipc: Activated (version 2.0.0)
<6>[   11.083902] NET: Registered protocol family 30
<6>[   11.084006] tipc: Started in single node mode
<5>[   11.084014] Key type dns_resolver registered
<7>[   11.084922] 
<7>[   11.084922] printing PIC contents
<7>[   11.084926] ... PIC  IMR: ffff
<7>[   11.084929] ... PIC  IRR: 0c21
<7>[   11.084939] ... PIC  ISR: 0000
<7>[   11.084942] ... PIC ELCR: 0e20
<7>[   11.084991] printing local APIC contents on CPU#0/0:
<6>[   11.084993] ... APIC ID:      00000000 (0)
<6>[   11.084994] ... APIC VERSION: 00060015
<7>[   11.084995] ... APIC TASKPRI: 00000000 (00)
<7>[   11.084996] ... APIC PROCPRI: 00000000
<7>[   11.084996] ... APIC LDR: 01000000
<7>[   11.084997] ... APIC DFR: ffffffff
<7>[   11.084998] ... APIC SPIV: 000001ff
<7>[   11.084998] ... APIC ISR field:
<4>[   11.085002] 0000000000000000000000000000000000000000000000000000000000000000
<7>[   11.085003] ... APIC TMR field:
<4>[   11.085006] 0000000000000000000200020000000000000000000000000000000000000000
<7>[   11.085006] ... APIC IRR field:
<4>[   11.085010] 0000000000000000000000000000000000000000000000000000000000000000
<7>[   11.085010] ... APIC ESR: 00000000
<7>[   11.085011] ... APIC ICR: 000000ef
<7>[   11.085012] ... APIC ICR2: 12000000
<7>[   11.085012] ... APIC LVTT: 000000ef
<7>[   11.085013] ... APIC LVTPC: 00000400
<7>[   11.085013] ... APIC LVT0: 00010700
<7>[   11.085014] ... APIC LVT1: 00000400
<7>[   11.085015] ... APIC LVTERR: 000000fe
<7>[   11.085015] ... APIC TMICT: 7fffffff
<7>[   11.085016] ... APIC TMCCT: 7fffff0b
<7>[   11.085016] ... APIC TDCR: 00000003
<4>[   11.085017] 
<7>[   11.085018] number of MP IRQ sources: 15.
<7>[   11.085019] number of IO-APIC #8 registers: 24.
<7>[   11.085019] number of IO-APIC #9 registers: 24.
<6>[   11.085020] testing the IO APIC.......................
<7>[   11.085026] IO APIC #8......
<7>[   11.085027] .... register #00: 08000000
<7>[   11.085027] .......    : physical APIC id: 08
<7>[   11.085028] .......    : Delivery Type: 0
<7>[   11.085028] .......    : LTS          : 0
<7>[   11.085028] .... register #01: 00170020
<7>[   11.085029] .......     : max redirection entries: 17
<7>[   11.085029] .......     : PRQ implemented: 0
<7>[   11.085030] .......     : IO APIC version: 20
<7>[   11.085030] .... IRQ redirection table:
<4>[   11.085035] 1    0    0   0   0    0    0    00
<4>[   11.085039] 0    0    0   0   0    0    0    31
<4>[   11.085042] 0    0    0   0   0    0    0    30
<4>[   11.085045] 0    0    0   0   0    0    0    33
<4>[   11.085049] 0    0    0   0   0    0    0    34
<4>[   11.085052] 0    0    0   0   0    0    0    35
<4>[   11.085055] 0    0    0   0   0    0    0    36
<4>[   11.085058] 0    0    0   0   0    0    0    37
<4>[   11.085062] 0    0    0   0   0    0    0    38
<4>[   11.085065] 0    1    0   0   0    0    0    39
<4>[   11.085068] 0    0    0   0   0    0    0    3A
<4>[   11.085072] 0    0    0   0   0    0    0    3B
<4>[   11.085075] 0    0    0   0   0    0    0    3C
<4>[   11.085078] 0    0    0   0   0    0    0    3D
<4>[   11.085082] 0    0    0   0   0    0    0    3E
<4>[   11.085086] 0    0    0   0   0    0    0    3F
<4>[   11.085089] 0    1    0   1   0    0    0    51
<4>[   11.085092] 1    1    0   1   0    0    0    82
<4>[   11.085096] 1    1    0   1   0    0    0    A2
<4>[   11.085099] 0    1    0   1   0    0    0    41
<4>[   11.085102] 1    0    0   0   0    0    0    00
<4>[   11.085106] 1    0    0   0   0    0    0    00
<4>[   11.085109] 1    0    0   0   0    0    0    00
<4>[   11.085112] 1    0    0   0   0    0    0    00
<7>[   11.085116] IO APIC #9......
<7>[   11.085116] .... register #00: 09000000
<7>[   11.085116] .......    : physical APIC id: 09
<7>[   11.085117] .......    : Delivery Type: 0
<7>[   11.085117] .......    : LTS          : 0
<7>[   11.085117] .... register #01: 00170020
<7>[   11.085118] .......     : max redirection entries: 17
<7>[   11.085118] .......     : PRQ implemented: 0
<7>[   11.085118] .......     : IO APIC version: 20
<7>[   11.085119] .... register #02: 00000000
<7>[   11.085119] .......     : arbitration: 00
<7>[   11.085120] .... register #03: 00000001
<7>[   11.085120] .......     : Boot DT    : 1
<7>[   11.085120] .... IRQ redirection table:
<4>[   11.085123] 1    1    0   1   0    0    0    81
<4>[   11.085125] 1    0    0   0   0    0    0    00
<4>[   11.085128] 1    1    0   1   0    0    0    A1
<4>[   11.085130] 1    0    0   0   0    0    0    00
<4>[   11.085133] 1    1    0   1   0    0    0    61
<4>[   11.085135] 1    0    0   0   0    0    0    00
<4>[   11.085138] 1    1    0   1   0    0    0    C1
<4>[   11.085140] 1    0    0   0   0    0    0    00
<4>[   11.085142] 1    1    0   1   0    0    0    E1
<4>[   11.085145] 1    1    0   1   0    0    0    42
<4>[   11.085147] 1    0    0   0   0    0    0    00
<4>[   11.085150] 1    0    0   0   0    0    0    00
<4>[   11.085152] 1    0    0   0   0    0    0    00
<4>[   11.085154] 1    0    0   0   0    0    0    00
<4>[   11.085157] 1    0    0   0   0    0    0    00
<4>[   11.085159] 1    0    0   0   0    0    0    00
<4>[   11.085162] 1    1    0   1   0    0    0    C2
<4>[   11.085164] 1    0    0   0   0    0    0    00
<4>[   11.085166] 1    0    0   0   0    0    0    00
<4>[   11.085169] 1    0    0   0   0    0    0    00
<4>[   11.085171] 1    0    0   0   0    0    0    00
<4>[   11.085174] 1    0    0   0   0    0    0    00
<4>[   11.085176] 1    0    0   0   0    0    0    00
<4>[   11.085178] 1    0    0   0   0    0    0    00
<7>[   11.085179] IRQ to pin mappings:
<7>[   11.085181] IRQ0 -> 0:2
<7>[   11.085182] IRQ1 -> 0:1
<7>[   11.085183] IRQ3 -> 0:3
<7>[   11.085184] IRQ4 -> 0:4
<7>[   11.085185] IRQ5 -> 0:5
<7>[   11.085186] IRQ6 -> 0:6
<7>[   11.085187] IRQ7 -> 0:7
<7>[   11.085187] IRQ8 -> 0:8
<7>[   11.085188] IRQ9 -> 0:9
<7>[   11.085189] IRQ10 -> 0:10
<7>[   11.085190] IRQ11 -> 0:11
<7>[   11.085191] IRQ12 -> 0:12
<7>[   11.085192] IRQ13 -> 0:13
<7>[   11.085192] IRQ14 -> 0:14
<7>[   11.085193] IRQ15 -> 0:15
<7>[   11.085194] IRQ16 -> 0:16
<7>[   11.085195] IRQ17 -> 0:17
<7>[   11.085196] IRQ18 -> 0:18
<7>[   11.085197] IRQ19 -> 0:19
<7>[   11.085198] IRQ24 -> 1:0
<7>[   11.085199] IRQ26 -> 1:2
<7>[   11.085200] IRQ28 -> 1:4
<7>[   11.085201] IRQ30 -> 1:6
<7>[   11.085202] IRQ32 -> 1:8
<7>[   11.085203] IRQ33 -> 1:9
<7>[   11.085204] IRQ40 -> 1:16
<6>[   11.085206] .................................... done.
<6>[   11.085324] registered taskstats version 1
<6>[   11.086283] Btrfs loaded
<6>[   11.549873] usb 2-1: new high-speed USB device number 2 using ehci-pci
<6>[   11.684671] usb-storage 2-1:1.0: USB Mass Storage device detected
<6>[   11.685257] scsi6 : usb-storage 2-1:1.0
<6>[   11.793854] usb 2-2: new high-speed USB device number 3 using ehci-pci
<6>[   11.926510] hub 2-2:1.0: USB hub found
<6>[   11.926585] hub 2-2:1.0: 4 ports detected
<6>[   12.026334] rtc_cmos 00:02: setting system clock to 2014-03-17 20:43:39 UTC (1395089019)
<6>[   12.036102] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
<6>[   12.043199] EDD information not available.
<6>[   12.142530] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
<6>[   12.149439] 8021q: adding VLAN 0 to HW filter on device eth0
<6>[   12.221886] usb 5-1: new full-speed USB device number 2 using uhci_hcd
<6>[   12.234377] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
<6>[   12.241278] 8021q: adding VLAN 0 to HW filter on device eth1
<6>[   12.400101] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.0/0003:046B:FF10.0001/input/input2
<6>[   12.417012] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input0
<6>[   12.440058] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.1/0003:046B:FF10.0002/input/input3
<6>[   12.456937] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input1
<5>[   12.684199] scsi 6:0:0:0: CD-ROM            TEAC     DV-W28S-V        1.0A PQ: 0 ANSI: 0
<5>[   12.694340] scsi 6:0:0:0: Attached scsi generic sg2 type 5
<6>[   12.710034] usb 8-2: new low-speed USB device number 2 using uhci_hcd
<6>[   13.003788] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.0/0003:04D9:1702.0003/input/input4
<6>[   13.016911] hid-generic 0003:04D9:1702.0003: input: USB HID v1.10 Keyboard [  USB Keyboard] on usb-0000:00:1d.2-2/input0
<6>[   13.081680] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.1/0003:04D9:1702.0004/input/input5
<6>[   13.094843] hid-generic 0003:04D9:1702.0004: input: USB HID v1.10 Device [  USB Keyboard] on usb-0000:00:1d.2-2/input1
<6>[   13.135800] input:   USB Keyboard as /devices/pci0000:00/0000:00:1d.2/usb8/8-2/8-2:1.2/0003:04D9:1702.0005/input/input6
<6>[   13.149108] hid-generic 0003:04D9:1702.0005: input: USB HID v1.10 Mouse [  USB Keyboard] on usb-0000:00:1d.2-2/input2
<6>[   14.182789] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
<6>[   14.198356] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
<5>[   14.214290] Sending DHCP requests .., OK
<4>[   17.050964] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.146
<6>[   17.243278] IP-Config: Complete:
<6>[   17.247367]      device=eth0, hwaddr=00:15:17:e6:9d:cc, ipaddr=192.168.1.146, mask=255.255.255.0, gw=192.168.1.1
<6>[   17.259532]      host=lkp-ne04, domain=lkp.intel.com, nis-domain=(none)
<6>[   17.267408]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
<6>[   17.275068]      nameserver0=192.168.1.1
<7>[   17.280583] PM: Hibernation image not present or could not be loaded.
<6>[   17.291108] Freeing unused kernel memory: 1436K (ffffffff8233f000 - ffffffff824a6000)
<6>[   17.300560] Write protecting the kernel read-only data: 18432k
<6>[   17.313999] Freeing unused kernel memory: 1720K (ffff880001a52000 - ffff880001c00000)
<6>[   17.328361] Freeing unused kernel memory: 1852K (ffff880002031000 - ffff880002200000)
<6>[   17.539241] ipmi message handler version 39.2
<6>[   17.545483] IPMI System Interface driver.
<6>[   17.550393] ipmi_si: probing via ACPI
<6>[   17.550430] ipmi_si 00:09: [io  0x0ca2] regsize 1 spacing 1 irq 0
<6>[   17.550432] ipmi_si: Adding ACPI-specified kcs state machine
<6>[   17.550458] ipmi_si: probing via SMBIOS
<6>[   17.550460] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
<6>[   17.550461] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
<6>[   17.550464] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
<6>[   17.601761] microcode: CPU0 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608631] microcode: CPU1 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608700] microcode: CPU2 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608715] microcode: CPU3 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608730] microcode: CPU4 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608752] microcode: CPU5 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608766] microcode: CPU6 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608841] microcode: CPU7 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608909] microcode: CPU8 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.608946] microcode: CPU9 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.609014] microcode: CPU10 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.609061] microcode: CPU11 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.609077] microcode: CPU12 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.615884] microcode: CPU13 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.616018] microcode: CPU14 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.616064] microcode: CPU15 sig=0x106a5, pf=0x1, revision=0x11
<6>[   17.616170] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
<6>[   17.707713] ipmi_si 00:09: Found new BMC (man_id: 0x000157, prod_id: 0x003e, dev_id: 0x21)
<6>[   17.707720] ipmi_si 00:09: IPMI kcs interface initialized
<5>[   17.853494] random: nonblocking pool is initialized
<6>[   17.885705] BTRFS: device fsid 3ce67776-66a6-4f9e-a297-eab37d032e1c devid 1 transid 6 /dev/sdb2
<3>[   26.028136] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[   26.040078] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/0
<4>[   26.040080] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[   26.040081] Hardware name: Intel Corporation S5520UR/S5520UR, BIOS S5500.86B.01.00.0050.050620101605 05/06/2010
<4>[   26.040083]  0000000000000000 ffff8801e9c06d00 ffffffff81a3ae8a ffffc90001870000
<4>[   26.040084]  ffff8801e9c06d10 ffffffff81101256 ffff8801e9c06d88 ffffffff811b1540
<4>[   26.040089]  ffffc90001870fff ffffc90001870fff 0000000000000001 000037008ddb0000
<4>[   26.040089] Call Trace:
<4>[   26.040094]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[   26.040098]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[   26.040101]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[   26.040102]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[   26.040105]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[   26.040106]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[   26.040108]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[   26.040110]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[   26.040112]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[   26.040113]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[   26.040114]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[   26.040118]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[   26.040119]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[   26.040120]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[   26.040124]  <<EOE>>  <IRQ>  [<ffffffff8104e597>] intel_pmu_enable_all+0x4c/0x9b
<4>[   26.040125]  [<ffffffff8104e607>] intel_pmu_nhm_enable_all+0x21/0x152
<4>[   26.040127]  [<ffffffff81049b00>] x86_pmu_enable+0x134/0x273
<4>[   26.040129]  [<ffffffff81176942>] perf_pmu_enable+0x22/0x24
<4>[   26.040130]  [<ffffffff81048268>] x86_pmu_commit_txn+0x7b/0x98
<4>[   26.040132]  [<ffffffff81112a66>] ? __wake_up+0x44/0x4b
<4>[   26.040135]  [<ffffffff81579c81>] ? tty_wakeup+0x5b/0x60
<4>[   26.040137]  [<ffffffff81593d02>] ? uart_write_wakeup+0x20/0x22
<4>[   26.040139]  [<ffffffff81596c7d>] ? serial8250_tx_chars+0xd9/0x142
<4>[   26.040140]  [<ffffffff81a42396>] ? _raw_spin_unlock_irqrestore+0x25/0x41
<4>[   26.040141]  [<ffffffff81a4220b>] ? _raw_spin_lock_irqsave+0x25/0x56
<4>[   26.040142]  [<ffffffff81a42396>] ? _raw_spin_unlock_irqrestore+0x25/0x41
<4>[   26.040144]  [<ffffffff810fb494>] ? hrtimer_get_next_event+0x83/0x98
<4>[   26.040145]  [<ffffffff81177ad6>] ? event_sched_in+0x133/0x143
<4>[   26.040146]  [<ffffffff81177b79>] group_sched_in+0x93/0x13c
<4>[   26.040149]  [<ffffffff8103edc7>] ? native_sched_clock+0x31/0x93
<4>[   26.040150]  [<ffffffff81178a83>] __perf_event_enable+0x1ad/0x1ea
<4>[   26.040151]  [<ffffffff81175275>] remote_function+0x17/0x40
<4>[   26.040154]  [<ffffffff8113786f>] generic_smp_call_function_single_interrupt+0x74/0xdb
<4>[   26.040156]  [<ffffffff8105bb9e>] smp_call_function_single_interrupt+0x27/0x36
<4>[   26.040158]  [<ffffffff81a4ae32>] call_function_single_interrupt+0x72/0x80
<4>[   26.040161]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[   26.040162]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[   26.040164]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[   26.040165]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[   26.040167]  [<ffffffff81a2ca43>] rest_init+0x87/0x89
<4>[   26.040169]  [<ffffffff82353dda>] start_kernel+0x401/0x40c
<4>[   26.040170]  [<ffffffff823537e7>] ? repair_env_string+0x58/0x58
<4>[   26.040171]  [<ffffffff82353120>] ? early_idt_handlers+0x120/0x120
<4>[   26.040173]  [<ffffffff823534a2>] x86_64_start_reservations+0x2a/0x2c
<4>[   26.040174]  [<ffffffff823535df>] x86_64_start_kernel+0x13b/0x148
<4>[   26.463198] perf interrupt took too long (2503 > 2500), lowering kernel.perf_event_max_sample_rate to 50000

--YD3LsXFS42OYHhNZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
