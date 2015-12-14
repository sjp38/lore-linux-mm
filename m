Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EC99D6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:25:10 -0500 (EST)
Received: by pabur14 with SMTP id ur14so101461996pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:25:10 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fm5si7863690pab.89.2015.12.14.01.25.08
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 01:25:08 -0800 (PST)
Date: Mon, 14 Dec 2015 11:24:33 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm related crash
Message-ID: <20151214092433.GA90449@black.fi.intel.com>
References: <20151210154801.GA12007@lahna.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210154801.GA12007@lahna.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mika Westerberg <mika.westerberg@intel.com>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org

On Thu, Dec 10, 2015 at 05:48:01PM +0200, Mika Westerberg wrote:
> Hi Kirill,
> 
> I got following crash on my desktop machine while building swift. It
> reproduces pretty easily on 4.4-rc4.
> 
> Before it happens the ld process is killed by OOM killer. I attached the
> whole dmesg.
> 
> [  254.740603] page:ffffea00111c31c0 count:2 mapcount:0 mapping:          (null) index:0x0
> [  254.740636] flags: 0x5fff8000048028(uptodate|lru|swapcache|swapbacked)
> [  254.740655] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> [  254.740679] ------------[ cut here ]------------
> [  254.740690] kernel BUG at mm/memcontrol.c:5270!


Hm. I don't see how this can happen.

Hugh? Michal?

> [  254.740700] invalid opcode: 0000 [#1] SMP 
> [  254.740710] Modules linked in: fuse bridge stp llc ebtable_filter ebtables ip6table_filter ip6_tables pl2303 snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec x86_pkg_temp_thermal coretemp snd_hwdep kvm_intel snd_hda_core kvm snd_seq snd_seq_device snd_pcm iTCO_wdt iTCO_vendor_support mxm_wmi snd_timer irqbypass crct10dif_pclmul crc32_pclmul snd crc32c_intel joydev mei_me mei i2c_i801 shpchp lpc_ich soundcore mfd_core wmi i915 drm_kms_helper drm e1000e igb serio_raw dca ptp i2c_algo_bit pps_core i2c_core video
> [  254.740863] CPU: 1 PID: 1558 Comm: Xorg Tainted: G          I     4.4.0-rc4 #2
> [  254.740888] Hardware name: Gigabyte Technology Co., Ltd. Z87X-UD7 TH/Z87X-UD7 TH-CF, BIOS F4 03/18/2014
> [  254.740906] task: ffff88047907e800 ti: ffff880477a6c000 task.ti: ffff880477a6c000
> [  254.740921] RIP: 0010:[<ffffffff811f51a5>]  [<ffffffff811f51a5>] mem_cgroup_try_charge+0x125/0x1e0
> [  254.740943] RSP: 0000:ffff880477a6fc58  EFLAGS: 00010246
> [  254.740954] RAX: 0000000000000036 RBX: ffffea00111c31c0 RCX: 0000000000000036
> [  254.740968] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffff88048f24e120
> [  254.740981] RBP: ffff880477a6fc88 R08: 0000000000000000 R09: 0000000000000000
> [  254.740995] R10: 00000000006e2016 R11: 0000000000000001 R12: 00000000001b8805
> [  254.741009] R13: ffff880477a6fd08 R14: 00000000024200d2 R15: ffff880475fcdb00
> [  254.741026] FS:  00007f630133da00(0000) GS:ffff88048f240000(0000) knlGS:0000000000000000
> [  254.741045] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  254.741059] CR2: 00007f62f9209000 CR3: 00000000357ff000 CR4: 00000000001406e0
> [  254.741073] Stack:
> [  254.741078]  0000000000000000 ffff88044d844578 00000000001b8805 0000000000011000
> [  254.741100]  ffffea00111c31c0 00000000fffffffe ffff880477a6fd40 ffffffff811a07de
> [  254.741121]  00000000006e2016 ffff88047907e800 ffff880477a6fde0 ffff88047907e800
> [  254.741145] Call Trace:
> [  254.741155]  [<ffffffff811a07de>] shmem_getpage_gfp+0x6fe/0x810
> [  254.741168]  [<ffffffff811a0e9f>] shmem_fault+0x5f/0x1c0
> [  254.741180]  [<ffffffff811c1351>] ? page_add_file_rmap+0x51/0x60
> [  254.741194]  [<ffffffff811b275f>] __do_fault+0x3f/0xd0
> [  254.741205]  [<ffffffff811b64e7>] handle_mm_fault+0x4f7/0x17c0
> [  254.741218]  [<ffffffff810f95e0>] ? enqueue_hrtimer+0x40/0x70
> [  254.741232]  [<ffffffff81060578>] __do_page_fault+0x188/0x3e0
> [  254.741245]  [<ffffffff8112d1ed>] ? __audit_syscall_exit+0x1dd/0x260
> [  254.741259]  [<ffffffff810607f2>] do_page_fault+0x22/0x30
> [  254.741272]  [<ffffffff8170b938>] page_fault+0x28/0x30
> [  254.741283] Code: 41 f6 44 24 74 01 75 a0 49 8b 54 24 18 f6 c2 03 75 50 65 48 ff 0a eb 90 ba 01 00 00 00 eb d1 48 c7 c6 e0 10 a5 81 e8 ab b2 fb ff <0f> 0b 48 c7 c6 c0 10 a5 81 48 89 df e8 9a b2 fb ff 0f 0b 4c 89 
> [  254.741409] RIP  [<ffffffff811f51a5>] mem_cgroup_try_charge+0x125/0x1e0
> [  254.741425]  RSP <ffff880477a6fc58>
> [  254.741440] ---[ end trace 9ac0c620ae24f224 ]---

> [    0.000000] microcode: CPU0 microcode updated early to revision 0x1c, date = 2014-07-03
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Initializing cgroup subsys cpuacct
> [    0.000000] Linux version 4.4.0-rc4 (westeri@lahna) (gcc version 4.9.2 20150212 (Red Hat 4.9.2-6) (GCC) ) #2 SMP Mon Dec 7 13:26:17 EET 2015
> [    0.000000] Command line: BOOT_IMAGE=/vmlinuz-4.4.0-rc4 root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/swap vconsole.font=latarcyrheb-sun16 rd.lvm.lv=fedora/root rhgb
> [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x01: 'x87 floating point registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x02: 'SSE registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x04: 'AVX registers'
> [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
> [    0.000000] x86/fpu: Using 'eager' FPU context switches.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000005573efff] usable
> [    0.000000] BIOS-e820: [mem 0x000000005573f000-0x0000000055745fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000055746000-0x00000000567affff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000567b0000-0x0000000056d35fff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000056d36000-0x0000000069b32fff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000069b33000-0x0000000069d46fff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000069d47000-0x0000000069d87fff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000069d88000-0x0000000069e49fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000069e4a000-0x000000006affefff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000006afff000-0x000000006affffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000006b800000-0x000000006f9fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000048f5fffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.7 present.
> [    0.000000] DMI: Gigabyte Technology Co., Ltd. Z87X-UD7 TH/Z87X-UD7 TH-CF, BIOS F4 03/18/2014
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x48f600 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-D3FFF write-protect
> [    0.000000]   D4000-E7FFF uncachable
> [    0.000000]   E8000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0000000000 mask 7C00000000 write-back
> [    0.000000]   1 base 0400000000 mask 7F80000000 write-back
> [    0.000000]   2 base 0480000000 mask 7FF0000000 write-back
> [    0.000000]   3 base 0080000000 mask 7F80000000 uncachable
> [    0.000000]   4 base 0070000000 mask 7FF0000000 uncachable
> [    0.000000]   5 base 006C000000 mask 7FFC000000 uncachable
> [    0.000000]   6 base 006B800000 mask 7FFF800000 uncachable
> [    0.000000]   7 base 048F800000 mask 7FFF800000 uncachable
> [    0.000000]   8 base 048F600000 mask 7FFFE00000 uncachable
> [    0.000000]   9 disabled
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
> [    0.000000] e820: update [mem 0x6b800000-0xffffffff] usable ==> reserved
> [    0.000000] e820: last_pfn = 0x6b000 max_arch_pfn = 0x400000000
> [    0.000000] found SMP MP-table at [mem 0x000fd780-0x000fd78f] mapped at [ffff8800000fd780]
> [    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] BRK [0x02035000, 0x02035fff] PGTABLE
> [    0.000000] BRK [0x02036000, 0x02036fff] PGTABLE
> [    0.000000] BRK [0x02037000, 0x02037fff] PGTABLE
> [    0.000000] BRK [0x02038000, 0x02038fff] PGTABLE
> [    0.000000] BRK [0x02039000, 0x02039fff] PGTABLE
> [    0.000000] BRK [0x0203a000, 0x0203afff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x337d3000-0x35be1fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0490 000024 (v02 ALASKA)
> [    0.000000] ACPI: XSDT 0x0000000069E1F080 00007C (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FACP 0x0000000069E2B6A8 00010C (v05 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: DSDT 0x0000000069E1F190 00C518 (v02 ALASKA A M I    00000088 INTL 20091112)
> [    0.000000] ACPI: FACS 0x0000000069E48080 000040
> [    0.000000] ACPI: APIC 0x0000000069E2B7B8 000092 (v03 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FPDT 0x0000000069E2B850 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: SSDT 0x0000000069E2B898 000539 (v01 PmRef  Cpu0Ist  00003000 INTL 20051117)
> [    0.000000] ACPI: SSDT 0x0000000069E2BDD8 000AD8 (v01 PmRef  CpuPm    00003000 INTL 20051117)
> [    0.000000] ACPI: MCFG 0x0000000069E2C8B0 00003C (v01 ALASKA A M I    01072009 MSFT 00000097)
> [    0.000000] ACPI: HPET 0x0000000069E2C8F0 000038 (v01 ALASKA A M I    01072009 AMI. 00000005)
> [    0.000000] ACPI: SSDT 0x0000000069E2C928 00036D (v01 SataRe SataTabl 00001000 INTL 20091112)
> [    0.000000] ACPI: SSDT 0x0000000069E2CC98 003299 (v01 SaSsdt SaSsdt   00003000 INTL 20091112)
> [    0.000000] ACPI: DMAR 0x0000000069E2FF38 000090 (v01 INTEL  HSW      00000001 INTL 00000001)
> [    0.000000] ACPI: MATS 0x0000000069E2FFC8 000034 (v02 ALASKA A M I    00000002 w?x2 00000000)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000048f5fffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x48f5e9000-0x48f5fafff]
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000000048f5fffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009cfff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x000000005573efff]
> [    0.000000]   node   0: [mem 0x0000000055746000-0x00000000567affff]
> [    0.000000]   node   0: [mem 0x0000000056d36000-0x0000000069b32fff]
> [    0.000000]   node   0: [mem 0x0000000069d47000-0x0000000069d87fff]
> [    0.000000]   node   0: [mem 0x000000006afff000-0x000000006affffff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x000000048f5fffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000048f5fffff]
> [    0.000000] On node 0 totalpages: 4164484
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 21 pages reserved
> [    0.000000]   DMA zone: 3996 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 6680 pages used for memmap
> [    0.000000]   DMA32 zone: 427496 pages, LIFO batch:31
> [    0.000000]   Normal zone: 58328 pages used for memmap
> [    0.000000]   Normal zone: 3732992 pages, LIFO batch:31
> [    0.000000] Reserving Intel graphics stolen memory at 0x6ba00000-0x6f9fffff
> [    0.000000] ACPI: PM-Timer IO Port: 0x1808
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
> [    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
> [    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x5573f000-0x55745fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x567b0000-0x56d35fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x69b33000-0x69d46fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x69d88000-0x69e49fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x69e4a000-0x6affefff]
> [    0.000000] PM: Registered nosave memory: [mem 0x6b000000-0x6b7fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x6b800000-0x6f9fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x6fa00000-0xdfffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xefffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xf0000000-0xfebfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfecfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed03fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed04000-0xfed1bfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xfeffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
> [    0.000000] e820: [mem 0x6fa00000-0xdfffffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
> [    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:8 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 34 pages/cpu @ffff88048f200000 s98904 r8192 d32168 u262144
> [    0.000000] pcpu-alloc: s98904 r8192 d32168 u262144 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
> [    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 4099391
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.4.0-rc4 root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/swap vconsole.font=latarcyrheb-sun16 rd.lvm.lv=fedora/root rhgb
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: CPU: 0 PID: 0 at drivers/iommu/dmar.c:829 warn_invalid_dmar+0x79/0x90()
> [    0.000000] Your BIOS is broken; DMAR reported at address 0!
>                BIOS vendor: American Megatrends Inc.; Ver: F4; Product Version: To be filled by O.E.M.
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.4.0-rc4 #2
> [    0.000000] Hardware name: Gigabyte Technology Co., Ltd. Z87X-UD7 TH/Z87X-UD7 TH-CF, BIOS F4 03/18/2014
> [    0.000000]  ffffffff81abde93 ffffffff81c03d68 ffffffff8136a8cf ffffffff81c03db0
> [    0.000000]  ffffffff81c03da0 ffffffff810967a2 0000000000000000 ffffffff81a6d5f3
> [    0.000000]  ffffffff8203401c ffffffff82034058 ffffffff81c03fb0 ffffffff81c03e00
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff8136a8cf>] dump_stack+0x44/0x55
> [    0.000000]  [<ffffffff810967a2>] warn_slowpath_common+0x82/0xc0
> [    0.000000]  [<ffffffff81096874>] warn_slowpath_fmt_taint+0x44/0x50
> [    0.000000]  [<ffffffff81d95e57>] ? early_ioremap+0x13/0x15
> [    0.000000]  [<ffffffff81d769a7>] ? __acpi_map_table+0x13/0x18
> [    0.000000]  [<ffffffff81479399>] warn_invalid_dmar+0x79/0x90
> [    0.000000]  [<ffffffff81701bb9>] dmar_validate_one_drhd+0x99/0xc0
> [    0.000000]  [<ffffffff81479512>] dmar_walk_remapping_entries+0x82/0x1a0
> [    0.000000]  [<ffffffff81db0071>] detect_intel_iommu+0x52/0xd1
> [    0.000000]  [<ffffffff81701b20>] ? xen_swiotlb_init+0x480/0x480
> [    0.000000]  [<ffffffff81d6e3e3>] pci_iommu_alloc+0x4a/0x6c
> [    0.000000]  [<ffffffff81d7f22d>] mem_init+0xf/0x8a
> [    0.000000]  [<ffffffff81d63d31>] start_kernel+0x1fe/0x436
> [    0.000000]  [<ffffffff81d63120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81d634d7>] x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  [<ffffffff81d63614>] x86_64_start_kernel+0x13b/0x14a
> [    0.000000] ---[ end trace 9ac0c620ae24f222 ]---
> [    0.000000] Memory: 16274680K/16657936K available (7224K kernel code, 1315K rwdata, 3284K rodata, 1488K init, 1464K bss, 383256K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	Build-time adjustment of leaf fanout to 64.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=8.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=8
> [    0.000000] NR_IRQS:4352 nr_irqs:488 16
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.000000] tsc: Detected 3492.144 MHz processor
> [    0.000019] Calibrating delay loop (skipped), value calculated using timer frequency.. 6984.28 BogoMIPS (lpj=3492144)
> [    0.000151] pid_max: default: 32768 minimum: 301
> [    0.000218] ACPI: Core revision 20150930
> [    0.006701] ACPI: 5 ACPI AML tables successfully acquired and loaded
> [    0.006844] Security Framework initialized
> [    0.006908] SELinux:  Initializing.
> [    0.006976] SELinux:  Starting in permissive mode
> [    0.007645] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> [    0.009734] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
> [    0.010663] Mount-cache hash table entries: 32768 (order: 6, 262144 bytes)
> [    0.010743] Mountpoint-cache hash table entries: 32768 (order: 6, 262144 bytes)
> [    0.011741] Initializing cgroup subsys io
> [    0.011806] Initializing cgroup subsys memory
> [    0.011881] Initializing cgroup subsys devices
> [    0.011945] Initializing cgroup subsys freezer
> [    0.012009] Initializing cgroup subsys net_cls
> [    0.012074] Initializing cgroup subsys perf_event
> [    0.012139] Initializing cgroup subsys hugetlb
> [    0.012218] CPU: Physical Processor ID: 0
> [    0.012281] CPU: Processor Core ID: 0
> [    0.013053] mce: CPU supports 9 MCE banks
> [    0.013125] CPU0: Thermal monitoring enabled (TM1)
> [    0.013195] process: using mwait in idle threads
> [    0.013261] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
> [    0.013327] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
> [    0.013631] Freeing SMP alternatives memory: 28K (ffffffff81ebe000 - ffffffff81ec5000)
> [    0.015498] ftrace: allocating 28226 entries in 111 pages
> [    0.022980] DMAR: Host address width 39
> [    0.023043] DMAR: DRHD base: 0x00000000000000 flags: 0x1
> [    0.023109] DMAR: Parse DMAR table failure.
> [    0.023538] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.033607] TSC deadline timer enabled
> [    0.033609] smpboot: CPU0: Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz (family: 0x6, model: 0x3c, stepping: 0x3)
> [    0.033807] Performance Events: PEBS fmt2+, 16-deep LBR, Haswell events, full-width counters, Intel PMU driver.
> [    0.034054] ... version:                3
> [    0.034117] ... bit width:              48
> [    0.034180] ... generic registers:      4
> [    0.034243] ... value mask:             0000ffffffffffff
> [    0.034308] ... max period:             0000ffffffffffff
> [    0.034373] ... fixed-purpose events:   3
> [    0.034436] ... event mask:             000000070000000f
> [    0.034911] x86: Booting SMP configuration:
> [    0.034975] .... node  #0, CPUs:      #1
> [    0.036236] microcode: CPU1 microcode updated early to revision 0x1c, date = 2014-07-03
> [    0.039064] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
> [    0.039363]  #2
> [    0.040399] microcode: CPU2 microcode updated early to revision 0x1c, date = 2014-07-03
> [    0.043222]  #3
> [    0.044413] microcode: CPU3 microcode updated early to revision 0x1c, date = 2014-07-03
> [    0.047242]  #4 #5 #6 #7
> [    0.059760] x86: Booted up 1 node, 8 CPUs
> [    0.059883] smpboot: Total of 8 processors activated (55874.30 BogoMIPS)
> [    0.066121] devtmpfs: initialized
> [    0.068018] PM: Registering ACPI NVS region [mem 0x5573f000-0x55745fff] (28672 bytes)
> [    0.068118] PM: Registering ACPI NVS region [mem 0x69d88000-0x69e49fff] (794624 bytes)
> [    0.068276] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
> [    0.068432] atomic64_test: passed for x86-64 platform with CX8 and with SSE
> [    0.068501] pinctrl core: initialized pinctrl subsystem
> [    0.068599] RTC time: 14:24:06, date: 12/10/15
> [    0.069169] NET: Registered protocol family 16
> [    0.074026] cpuidle: using governor menu
> [    0.074123] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
> [    0.074221] ACPI: bus type PCI registered
> [    0.074285] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    0.074392] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
> [    0.074494] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
> [    0.074565] pmd_set_huge: Cannot satisfy [mem 0xe0000000-0xe0200000] with a huge-page mapping due to MTRR override.
> [    0.074850] PCI: Using configuration type 1 for base access
> [    0.075161] perf_event_intel: PMU erratum BJ122, BV98, HSD29 worked around, HT is on
> [    0.080215] ACPI: Added _OSI(Module Device)
> [    0.080279] ACPI: Added _OSI(Processor Device)
> [    0.080343] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.080407] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.082718] ACPI: Executed 1 blocks of module-level executable AML code
> [    0.084256] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
> [    0.084706] ACPI: Dynamic OEM Table Load:
> [    0.084826] ACPI: SSDT 0xFFFF88047CB54400 0003D3 (v01 PmRef  Cpu0Cst  00003001 INTL 20051117)
> [    0.085350] ACPI: Dynamic OEM Table Load:
> [    0.085469] ACPI: SSDT 0xFFFF88047CB42800 0005AA (v01 PmRef  ApIst    00003000 INTL 20051117)
> [    0.086011] ACPI: Dynamic OEM Table Load:
> [    0.086130] ACPI: SSDT 0xFFFF88047C43C200 000119 (v01 PmRef  ApCst    00003000 INTL 20051117)
> [    0.087261] ACPI: Interpreter enabled
> [    0.087328] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150930/hwxface-580)
> [    0.087485] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150930/hwxface-580)
> [    0.087649] ACPI: (supports S0 S3 S4 S5)
> [    0.087713] ACPI: Using IOAPIC for interrupt routing
> [    0.087791] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.092879] ACPI: Power Resource [FN00] (off)
> [    0.092985] ACPI: Power Resource [FN01] (off)
> [    0.093094] ACPI: Power Resource [FN02] (off)
> [    0.093198] ACPI: Power Resource [FN03] (off)
> [    0.093301] ACPI: Power Resource [FN04] (off)
> [    0.093786] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
> [    0.093855] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    0.094085] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug PME]
> [    0.094251] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
> [    0.094319] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using BIOS configuration
> [    0.094641] PCI host bridge to bus 0000:00
> [    0.094705] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> [    0.094774] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
> [    0.094842] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.094940] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff window]
> [    0.095039] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff window]
> [    0.095139] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff window]
> [    0.095237] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff window]
> [    0.095335] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff window]
> [    0.095434] pci_bus 0000:00: root bus resource [mem 0x6fa00000-0xfeafffff window]
> [    0.095533] pci_bus 0000:00: root bus resource [bus 00-fe]
> [    0.095602] pci 0000:00:00.0: [8086:0c00] type 00 class 0x060000
> [    0.095656] pci 0000:00:01.0: [8086:0c01] type 01 class 0x060400
> [    0.095679] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
> [    0.095729] pci 0000:00:01.0: System wakeup disabled by ACPI
> [    0.095818] pci 0000:00:02.0: [8086:0412] type 00 class 0x030000
> [    0.095827] pci 0000:00:02.0: reg 0x10: [mem 0xde400000-0xde7fffff 64bit]
> [    0.095831] pci 0000:00:02.0: reg 0x18: [mem 0x70000000-0x7fffffff 64bit pref]
> [    0.095834] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
> [    0.095881] pci 0000:00:03.0: [8086:0c0c] type 00 class 0x040300
> [    0.095888] pci 0000:00:03.0: reg 0x10: [mem 0xdef34000-0xdef37fff 64bit]
> [    0.095954] pci 0000:00:14.0: [8086:8c31] type 00 class 0x0c0330
> [    0.095975] pci 0000:00:14.0: reg 0x10: [mem 0xdef20000-0xdef2ffff 64bit]
> [    0.096015] pci 0000:00:14.0: PME# supported from D3hot D3cold
> [    0.096038] pci 0000:00:14.0: System wakeup disabled by ACPI
> [    0.096126] pci 0000:00:16.0: [8086:8c3a] type 00 class 0x078000
> [    0.096149] pci 0000:00:16.0: reg 0x10: [mem 0xdef3f000-0xdef3f00f 64bit]
> [    0.096192] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
> [    0.096240] pci 0000:00:19.0: [8086:153b] type 00 class 0x020000
> [    0.096259] pci 0000:00:19.0: reg 0x10: [mem 0xdef00000-0xdef1ffff]
> [    0.096265] pci 0000:00:19.0: reg 0x14: [mem 0xdef3d000-0xdef3dfff]
> [    0.096271] pci 0000:00:19.0: reg 0x18: [io  0xf080-0xf09f]
> [    0.096309] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
> [    0.096333] pci 0000:00:19.0: System wakeup disabled by ACPI
> [    0.096421] pci 0000:00:1a.0: [8086:8c2d] type 00 class 0x0c0320
> [    0.096444] pci 0000:00:1a.0: reg 0x10: [mem 0xdef3c000-0xdef3c3ff]
> [    0.096503] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
> [    0.096536] pci 0000:00:1a.0: System wakeup disabled by ACPI
> [    0.096624] pci 0000:00:1b.0: [8086:8c20] type 00 class 0x040300
> [    0.096644] pci 0000:00:1b.0: reg 0x10: [mem 0xdef30000-0xdef33fff 64bit]
> [    0.096691] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
> [    0.096716] pci 0000:00:1b.0: System wakeup disabled by ACPI
> [    0.096803] pci 0000:00:1c.0: [8086:8c10] type 01 class 0x060400
> [    0.096859] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> [    0.096904] pci 0000:00:1c.0: System wakeup disabled by ACPI
> [    0.096992] pci 0000:00:1c.4: [8086:8c18] type 01 class 0x060400
> [    0.097042] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
> [    0.097086] pci 0000:00:1c.4: System wakeup disabled by ACPI
> [    0.097175] pci 0000:00:1c.6: [8086:8c1c] type 01 class 0x060400
> [    0.097225] pci 0000:00:1c.6: PME# supported from D0 D3hot D3cold
> [    0.097268] pci 0000:00:1c.6: System wakeup disabled by ACPI
> [    0.097357] pci 0000:00:1d.0: [8086:8c26] type 00 class 0x0c0320
> [    0.097379] pci 0000:00:1d.0: reg 0x10: [mem 0xdef3b000-0xdef3b3ff]
> [    0.097439] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
> [    0.097471] pci 0000:00:1d.0: System wakeup disabled by ACPI
> [    0.097560] pci 0000:00:1f.0: [8086:8c44] type 00 class 0x060100
> [    0.097684] pci 0000:00:1f.2: [8086:8c02] type 00 class 0x010601
> [    0.097700] pci 0000:00:1f.2: reg 0x10: [io  0xf0d0-0xf0d7]
> [    0.097706] pci 0000:00:1f.2: reg 0x14: [io  0xf0c0-0xf0c3]
> [    0.097711] pci 0000:00:1f.2: reg 0x18: [io  0xf0b0-0xf0b7]
> [    0.097716] pci 0000:00:1f.2: reg 0x1c: [io  0xf0a0-0xf0a3]
> [    0.097722] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
> [    0.097727] pci 0000:00:1f.2: reg 0x24: [mem 0xdef3a000-0xdef3a7ff]
> [    0.097748] pci 0000:00:1f.2: PME# supported from D3hot
> [    0.097788] pci 0000:00:1f.3: [8086:8c22] type 00 class 0x0c0500
> [    0.097801] pci 0000:00:1f.3: reg 0x10: [mem 0xdef39000-0xdef390ff 64bit]
> [    0.097817] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
> [    0.097890] pci 0000:01:00.0: [10b5:8747] type 01 class 0x060400
> [    0.097904] pci 0000:01:00.0: reg 0x10: [mem 0xdee00000-0xdee3ffff]
> [    0.097942] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
> [    0.097959] pci 0000:01:00.0: System wakeup disabled by ACPI
> [    0.099160] pci 0000:00:01.0: PCI bridge to [bus 01-04]
> [    0.099227] pci 0000:00:01.0:   bridge window [mem 0xdee00000-0xdeefffff]
> [    0.099260] pci 0000:02:08.0: [10b5:8747] type 01 class 0x060400
> [    0.099312] pci 0000:02:08.0: PME# supported from D0 D3hot D3cold
> [    0.099350] pci 0000:02:10.0: [10b5:8747] type 01 class 0x060400
> [    0.099401] pci 0000:02:10.0: PME# supported from D0 D3hot D3cold
> [    0.099439] pci 0000:01:00.0: PCI bridge to [bus 02-04]
> [    0.099529] pci 0000:02:08.0: PCI bridge to [bus 03]
> [    0.150147] pci 0000:02:10.0: PCI bridge to [bus 04]
> [    0.150269] acpiphp: Slot [1] registered
> [    0.150334] pci 0000:00:1c.0: PCI bridge to [bus 05-6f]
> [    0.150403] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xde0fffff]
> [    0.150407] pci 0000:00:1c.0:   bridge window [mem 0x80000000-0xb9ffffff 64bit pref]
> [    0.150459] pci 0000:70:00.0: [1b4b:9230] type 00 class 0x010601
> [    0.150484] pci 0000:70:00.0: reg 0x10: [io  0xe050-0xe057]
> [    0.150492] pci 0000:70:00.0: reg 0x14: [io  0xe040-0xe043]
> [    0.150500] pci 0000:70:00.0: reg 0x18: [io  0xe030-0xe037]
> [    0.150509] pci 0000:70:00.0: reg 0x1c: [io  0xe020-0xe023]
> [    0.150517] pci 0000:70:00.0: reg 0x20: [io  0xe000-0xe01f]
> [    0.150525] pci 0000:70:00.0: reg 0x24: [mem 0xded10000-0xded107ff]
> [    0.150533] pci 0000:70:00.0: reg 0x30: [mem 0xded00000-0xded0ffff pref]
> [    0.150564] pci 0000:70:00.0: PME# supported from D3hot
> [    0.150586] pci 0000:70:00.0: System wakeup disabled by ACPI
> [    0.152175] pci 0000:00:1c.4: PCI bridge to [bus 70]
> [    0.152241] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
> [    0.152244] pci 0000:00:1c.4:   bridge window [mem 0xded00000-0xdedfffff]
> [    0.152298] pci 0000:71:00.0: [10b5:8605] type 01 class 0x060400
> [    0.152336] pci 0000:71:00.0: reg 0x10: [mem 0xdec00000-0xdec03fff]
> [    0.152434] pci 0000:71:00.0: supports D1 D2
> [    0.152435] pci 0000:71:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.152475] pci 0000:71:00.0: System wakeup disabled by ACPI
> [    0.154179] pci 0000:00:1c.6: PCI bridge to [bus 71-75]
> [    0.154246] pci 0000:00:1c.6:   bridge window [io  0xd000-0xdfff]
> [    0.154248] pci 0000:00:1c.6:   bridge window [mem 0xde800000-0xdecfffff]
> [    0.154312] pci 0000:72:01.0: [10b5:8605] type 01 class 0x060400
> [    0.154448] pci 0000:72:01.0: supports D1 D2
> [    0.154449] pci 0000:72:01.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.154514] pci 0000:72:02.0: [10b5:8605] type 01 class 0x060400
> [    0.154649] pci 0000:72:02.0: supports D1 D2
> [    0.154650] pci 0000:72:02.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.154715] pci 0000:72:03.0: [10b5:8605] type 01 class 0x060400
> [    0.154850] pci 0000:72:03.0: supports D1 D2
> [    0.154851] pci 0000:72:03.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.154940] pci 0000:71:00.0: PCI bridge to [bus 72-75]
> [    0.155012] pci 0000:71:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.155016] pci 0000:71:00.0:   bridge window [mem 0xde800000-0xdebfffff]
> [    0.155066] pci 0000:72:01.0: PCI bridge to [bus 73]
> [    0.155223] pci 0000:74:00.0: [8086:08b1] type 00 class 0x028000
> [    0.155306] pci 0000:74:00.0: reg 0x10: [mem 0xdeb00000-0xdeb01fff 64bit]
> [    0.155519] pci 0000:74:00.0: PME# supported from D0 D3hot D3cold
> [    0.157198] pci 0000:72:02.0: PCI bridge to [bus 74]
> [    0.157272] pci 0000:72:02.0:   bridge window [mem 0xdeb00000-0xdebfffff]
> [    0.157352] pci 0000:75:00.0: [8086:1533] type 00 class 0x020000
> [    0.157418] pci 0000:75:00.0: reg 0x10: [mem 0xde900000-0xde9fffff]
> [    0.157454] pci 0000:75:00.0: reg 0x18: [io  0xd000-0xd01f]
> [    0.157473] pci 0000:75:00.0: reg 0x1c: [mem 0xdea00000-0xdea03fff]
> [    0.157528] pci 0000:75:00.0: reg 0x30: [mem 0xde800000-0xde8fffff pref]
> [    0.157620] pci 0000:75:00.0: PME# supported from D0 D3hot D3cold
> [    0.159198] pci 0000:72:03.0: PCI bridge to [bus 75]
> [    0.159269] pci 0000:72:03.0:   bridge window [io  0xd000-0xdfff]
> [    0.159273] pci 0000:72:03.0:   bridge window [mem 0xde800000-0xdeafffff]
> [    0.159760] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
> [    0.160148] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14 15)
> [    0.160538] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
> [    0.160925] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
> [    0.161312] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 10 11 12 14 15)
> [    0.161698] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
> [    0.162170] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 10 11 12 14 15)
> [    0.162558] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 10 11 12 14 15)
> [    0.163105] ACPI: Enabled 5 GPEs in block 00 to 3F
> [    0.163278] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    0.163344] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    0.163445] vgaarb: loaded
> [    0.163506] vgaarb: bridge control possible 0000:00:02.0
> [    0.163610] SCSI subsystem initialized
> [    0.163691] libata version 3.00 loaded.
> [    0.163708] ACPI: bus type USB registered
> [    0.163781] usbcore: registered new interface driver usbfs
> [    0.163850] usbcore: registered new interface driver hub
> [    0.163926] usbcore: registered new device driver usb
> [    0.164029] PCI: Using ACPI for IRQ routing
> [    0.169280] PCI: pci_cache_line_size set to 64 bytes
> [    0.169336] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
> [    0.169337] e820: reserve RAM buffer [mem 0x5573f000-0x57ffffff]
> [    0.169338] e820: reserve RAM buffer [mem 0x567b0000-0x57ffffff]
> [    0.169339] e820: reserve RAM buffer [mem 0x69b33000-0x6bffffff]
> [    0.169339] e820: reserve RAM buffer [mem 0x69d88000-0x6bffffff]
> [    0.169340] e820: reserve RAM buffer [mem 0x6b000000-0x6bffffff]
> [    0.169341] e820: reserve RAM buffer [mem 0x48f600000-0x48fffffff]
> [    0.169407] NetLabel: Initializing
> [    0.169470] NetLabel:  domain hash size = 128
> [    0.169533] NetLabel:  protocols = UNLABELED CIPSOv4
> [    0.169605] NetLabel:  unlabeled traffic allowed by default
> [    0.169699] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
> [    0.170008] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
> [    0.172093] clocksource: Switched to clocksource hpet
> [    0.176114] pnp: PnP ACPI init
> [    0.176223] system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
> [    0.177017] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
> [    0.177111] system 00:01: [io  0x0680-0x069f] has been reserved
> [    0.177179] system 00:01: [io  0xffff] has been reserved
> [    0.177244] system 00:01: [io  0xffff] has been reserved
> [    0.177310] system 00:01: [io  0xffff] has been reserved
> [    0.177376] system 00:01: [io  0x1c00-0x1cfe] has been reserved
> [    0.177442] system 00:01: [io  0x1d00-0x1dfe] has been reserved
> [    0.177509] system 00:01: [io  0x1e00-0x1efe] has been reserved
> [    0.177575] system 00:01: [io  0x1f00-0x1ffe] has been reserved
> [    0.177642] system 00:01: [io  0x1800-0x18fe] could not be reserved
> [    0.177709] system 00:01: [io  0x164e-0x164f] has been reserved
> [    0.177776] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.177790] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.177818] system 00:03: [io  0x1854-0x1857] has been reserved
> [    0.177885] system 00:03: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
> [    0.177955] system 00:04: [io  0x0a00-0x0a0f] has been reserved
> [    0.178023] system 00:04: [io  0x0a30-0x0a3f] has been reserved
> [    0.178089] system 00:04: [io  0x0a20-0x0a2f] has been reserved
> [    0.178160] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.178307] pnp 00:05: [dma 0 disabled]
> [    0.178335] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    0.178366] system 00:06: [io  0x04d0-0x04d1] has been reserved
> [    0.178433] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.178696] system 00:07: [mem 0xfed1c000-0xfed1ffff] has been reserved
> [    0.178764] system 00:07: [mem 0xfed10000-0xfed17fff] has been reserved
> [    0.178832] system 00:07: [mem 0xfed18000-0xfed18fff] has been reserved
> [    0.178899] system 00:07: [mem 0xfed19000-0xfed19fff] has been reserved
> [    0.178967] system 00:07: [mem 0xe0000000-0xefffffff] has been reserved
> [    0.179035] system 00:07: [mem 0xfed20000-0xfed3ffff] has been reserved
> [    0.179107] system 00:07: [mem 0xfed90000-0xfed93fff] has been reserved
> [    0.179174] system 00:07: [mem 0xfed45000-0xfed8ffff] has been reserved
> [    0.179242] system 00:07: [mem 0xff000000-0xffffffff] has been reserved
> [    0.179310] system 00:07: [mem 0xfee00000-0xfeefffff] could not be reserved
> [    0.179378] system 00:07: [mem 0xdffef000-0xdffeffff] has been reserved
> [    0.179446] system 00:07: [mem 0xdfff0000-0xdfff0fff] has been reserved
> [    0.179514] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.179663] pnp: PnP ACPI: found 8 devices
> [    0.185292] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    0.185414] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus 05-6f] add_size 1000
> [    0.185429] pci 0000:72:01.0: bridge window [io  0x1000-0x0fff] to [bus 73] add_size 1000
> [    0.185431] pci 0000:72:01.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 73] add_size 200000 add_align 100000
> [    0.185432] pci 0000:72:01.0: bridge window [mem 0x00100000-0x000fffff] to [bus 73] add_size 200000 add_align 100000
> [    0.185461] pci 0000:72:01.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185462] pci 0000:72:01.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185463] pci 0000:71:00.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 72-75] add_size 200000 add_align 100000
> [    0.185468] pci 0000:71:00.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185469] pci 0000:71:00.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185471] pci 0000:00:1c.6: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 71-75] add_size 200000 add_align 100000
> [    0.185473] pci 0000:00:1c.6: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185474] pci 0000:00:1c.6: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.185475] pci 0000:00:1c.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
> [    0.185476] pci 0000:00:1c.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
> [    0.185481] pci 0000:00:1c.6: BAR 15: assigned [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.185580] pci 0000:00:1c.0: BAR 13: assigned [io  0x2000-0x2fff]
> [    0.185647] pci 0000:02:08.0: PCI bridge to [bus 03]
> [    0.185718] pci 0000:02:10.0: PCI bridge to [bus 04]
> [    0.185787] pci 0000:01:00.0: PCI bridge to [bus 02-04]
> [    0.185858] pci 0000:00:01.0: PCI bridge to [bus 01-04]
> [    0.185924] pci 0000:00:01.0:   bridge window [mem 0xdee00000-0xdeefffff]
> [    0.185994] pci 0000:00:1c.0: PCI bridge to [bus 05-6f]
> [    0.186059] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
> [    0.186131] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xde0fffff]
> [    0.186201] pci 0000:00:1c.0:   bridge window [mem 0x80000000-0xb9ffffff 64bit pref]
> [    0.186303] pci 0000:00:1c.4: PCI bridge to [bus 70]
> [    0.186368] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
> [    0.186437] pci 0000:00:1c.4:   bridge window [mem 0xded00000-0xdedfffff]
> [    0.186509] pci 0000:71:00.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.186510] pci 0000:71:00.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.186512] pci 0000:71:00.0: BAR 15: assigned [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.186612] pci 0000:72:01.0: res[14]=[mem 0x00100000-0x000fffff] res_to_dev_res add_size 200000 min_align 100000
> [    0.186612] pci 0000:72:01.0: res[14]=[mem 0x00100000-0x002fffff] res_to_dev_res add_size 200000 min_align 100000
> [    0.186614] pci 0000:72:01.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.186615] pci 0000:72:01.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
> [    0.186615] pci 0000:72:01.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
> [    0.186616] pci 0000:72:01.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
> [    0.186618] pci 0000:72:01.0: BAR 14: no space for [mem size 0x00200000]
> [    0.186685] pci 0000:72:01.0: BAR 14: failed to assign [mem size 0x00200000]
> [    0.186754] pci 0000:72:01.0: BAR 15: assigned [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.186853] pci 0000:72:01.0: BAR 13: no space for [io  size 0x1000]
> [    0.186919] pci 0000:72:01.0: BAR 13: failed to assign [io  size 0x1000]
> [    0.186987] pci 0000:72:01.0: BAR 14: no space for [mem size 0x00200000]
> [    0.187055] pci 0000:72:01.0: BAR 14: failed to assign [mem size 0x00200000]
> [    0.187126] pci 0000:72:01.0: BAR 13: no space for [io  size 0x1000]
> [    0.187193] pci 0000:72:01.0: BAR 13: failed to assign [io  size 0x1000]
> [    0.187260] pci 0000:72:01.0: PCI bridge to [bus 73]
> [    0.187333] pci 0000:72:01.0:   bridge window [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.187438] pci 0000:72:02.0: PCI bridge to [bus 74]
> [    0.187507] pci 0000:72:02.0:   bridge window [mem 0xdeb00000-0xdebfffff]
> [    0.187585] pci 0000:72:03.0: PCI bridge to [bus 75]
> [    0.187651] pci 0000:72:03.0:   bridge window [io  0xd000-0xdfff]
> [    0.187722] pci 0000:72:03.0:   bridge window [mem 0xde800000-0xdeafffff]
> [    0.187799] pci 0000:71:00.0: PCI bridge to [bus 72-75]
> [    0.187866] pci 0000:71:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.187937] pci 0000:71:00.0:   bridge window [mem 0xde800000-0xdebfffff]
> [    0.188008] pci 0000:71:00.0:   bridge window [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.188115] pci 0000:00:1c.6: PCI bridge to [bus 71-75]
> [    0.188181] pci 0000:00:1c.6:   bridge window [io  0xd000-0xdfff]
> [    0.188250] pci 0000:00:1c.6:   bridge window [mem 0xde800000-0xdecfffff]
> [    0.188319] pci 0000:00:1c.6:   bridge window [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.188421] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    0.188422] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
> [    0.188423] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
> [    0.188424] pci_bus 0000:00: resource 7 [mem 0x000d4000-0x000d7fff window]
> [    0.188425] pci_bus 0000:00: resource 8 [mem 0x000d8000-0x000dbfff window]
> [    0.188425] pci_bus 0000:00: resource 9 [mem 0x000dc000-0x000dffff window]
> [    0.188426] pci_bus 0000:00: resource 10 [mem 0x000e0000-0x000e3fff window]
> [    0.188427] pci_bus 0000:00: resource 11 [mem 0x000e4000-0x000e7fff window]
> [    0.188428] pci_bus 0000:00: resource 12 [mem 0x6fa00000-0xfeafffff window]
> [    0.188429] pci_bus 0000:01: resource 1 [mem 0xdee00000-0xdeefffff]
> [    0.188430] pci_bus 0000:05: resource 0 [io  0x2000-0x2fff]
> [    0.188431] pci_bus 0000:05: resource 1 [mem 0xc0000000-0xde0fffff]
> [    0.188432] pci_bus 0000:05: resource 2 [mem 0x80000000-0xb9ffffff 64bit pref]
> [    0.188432] pci_bus 0000:70: resource 0 [io  0xe000-0xefff]
> [    0.188433] pci_bus 0000:70: resource 1 [mem 0xded00000-0xdedfffff]
> [    0.188434] pci_bus 0000:71: resource 0 [io  0xd000-0xdfff]
> [    0.188435] pci_bus 0000:71: resource 1 [mem 0xde800000-0xdecfffff]
> [    0.188436] pci_bus 0000:71: resource 2 [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.188437] pci_bus 0000:72: resource 0 [io  0xd000-0xdfff]
> [    0.188437] pci_bus 0000:72: resource 1 [mem 0xde800000-0xdebfffff]
> [    0.188438] pci_bus 0000:72: resource 2 [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.188439] pci_bus 0000:73: resource 2 [mem 0x6fa00000-0x6fbfffff 64bit pref]
> [    0.188440] pci_bus 0000:74: resource 1 [mem 0xdeb00000-0xdebfffff]
> [    0.188441] pci_bus 0000:75: resource 0 [io  0xd000-0xdfff]
> [    0.188442] pci_bus 0000:75: resource 1 [mem 0xde800000-0xdeafffff]
> [    0.188464] NET: Registered protocol family 2
> [    0.188656] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> [    0.188891] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> [    0.189054] TCP: Hash tables configured (established 131072 bind 65536)
> [    0.189146] UDP hash table entries: 8192 (order: 6, 262144 bytes)
> [    0.189247] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
> [    0.189367] NET: Registered protocol family 1
> [    0.189439] pci 0000:00:02.0: Video device with shadowed ROM
> [    0.205123] PCI: CLS mismatch (64 != 128), using 64 bytes
> [    0.221151] Unpacking initramfs...
> [    0.616480] Freeing initrd memory: 36924K (ffff8800337d3000 - ffff880035be2000)
> [    0.616594] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> [    0.616662] software IO TLB [mem 0x65b33000-0x69b33000] (64MB) mapped at [ffff880065b33000-ffff880069b32fff]
> [    0.616811] RAPL PMU detected, API unit is 2^-32 Joules, 4 fixed counters 655360 ms ovfl timer
> [    0.616911] hw unit of domain pp0-core 2^-14 Joules
> [    0.616975] hw unit of domain package 2^-14 Joules
> [    0.617039] hw unit of domain dram 2^-14 Joules
> [    0.617111] hw unit of domain pp1-gpu 2^-14 Joules
> [    0.617723] futex hash table entries: 2048 (order: 5, 131072 bytes)
> [    0.617816] audit: initializing netlink subsys (disabled)
> [    0.617889] audit: type=2000 audit(1449757446.549:1): initialized
> [    0.618206] Initialise system trusted keyring
> [    0.618318] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [    0.619350] VFS: Disk quotas dquot_6.6.0
> [    0.619433] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    0.619736] Key type big_key registered
> [    0.619800] SELinux:  Registering netfilter hooks
> [    0.622104] NET: Registered protocol family 38
> [    0.622173] Key type asymmetric registered
> [    0.622237] Asymmetric key parser 'x509' registered
> [    0.622329] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
> [    0.622452] io scheduler noop registered
> [    0.622516] io scheduler deadline registered
> [    0.622599] io scheduler cfq registered (default)
> [    0.623863] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> [    0.623933] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
> [    0.624020] intel_idle: MWAIT substates: 0x42120
> [    0.624021] intel_idle: v0.4 model 0x3C
> [    0.624022] intel_idle: lapic_timer_reliable_states 0xffffffff
> [    0.624260] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
> [    0.624361] ACPI: Power Button [PWRB]
> [    0.624444] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [    0.624542] ACPI: Power Button [PWRF]
> [    0.625110] thermal LNXTHERM:00: registered as thermal_zone0
> [    0.625177] ACPI: Thermal Zone [TZ00] (28 C)
> [    0.625346] thermal LNXTHERM:01: registered as thermal_zone1
> [    0.625412] ACPI: Thermal Zone [TZ01] (30 C)
> [    0.625497] GHES: HEST is not enabled!
> [    0.625596] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    0.646224] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    0.646768] Non-volatile memory driver v1.3
> [    0.646848] Linux agpgart interface v0.103
> [    0.647378] ahci 0000:00:1f.2: version 3.0
> [    0.647459] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x29 impl SATA mode
> [    0.647559] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part ems apst 
> [    0.651551] scsi host0: ahci
> [    0.651773] scsi host1: ahci
> [    0.651898] scsi host2: ahci
> [    0.652030] scsi host3: ahci
> [    0.652176] scsi host4: ahci
> [    0.652308] scsi host5: ahci
> [    0.652400] ata1: SATA max UDMA/133 abar m2048@0xdef3a000 port 0xdef3a100 irq 32
> [    0.652498] ata2: DUMMY
> [    0.652559] ata3: DUMMY
> [    0.652620] ata4: SATA max UDMA/133 abar m2048@0xdef3a000 port 0xdef3a280 irq 32
> [    0.652718] ata5: DUMMY
> [    0.652779] ata6: SATA max UDMA/133 abar m2048@0xdef3a000 port 0xdef3a380 irq 32
> [    0.652969] ahci 0000:70:00.0: controller can do FBS, turning on CAP_FBS
> [    0.664121] ahci 0000:70:00.0: AHCI 0001.0200 32 slots 8 ports 6 Gbps 0xff impl SATA mode
> [    0.664221] ahci 0000:70:00.0: flags: 64bit ncq fbs pio 
> [    0.664719] scsi host6: ahci
> [    0.664850] scsi host7: ahci
> [    0.664990] scsi host8: ahci
> [    0.665134] scsi host9: ahci
> [    0.665274] scsi host10: ahci
> [    0.665414] scsi host11: ahci
> [    0.665554] scsi host12: ahci
> [    0.665692] scsi host13: ahci
> [    0.665788] ata7: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10100 irq 33
> [    0.665887] ata8: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10180 irq 33
> [    0.665985] ata9: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10200 irq 33
> [    0.666088] ata10: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10280 irq 33
> [    0.666187] ata11: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10300 irq 33
> [    0.666287] ata12: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10380 irq 33
> [    0.666386] ata13: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10400 irq 33
> [    0.666485] ata14: SATA max UDMA/133 abar m2048@0xded10000 port 0xded10480 irq 33
> [    0.666663] libphy: Fixed MDIO Bus: probed
> [    0.666904] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    0.667032] ehci-pci: EHCI PCI platform driver
> [    0.667882] ehci-pci 0000:00:1a.0: EHCI Host Controller
> [    0.667973] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
> [    0.668108] ehci-pci 0000:00:1a.0: debug port 2
> [    0.672086] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
> [    0.672091] ehci-pci 0000:00:1a.0: irq 16, io mem 0xdef3c000
> [    0.678067] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
> [    0.678151] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
> [    0.678219] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.678317] usb usb1: Product: EHCI Host Controller
> [    0.678382] usb usb1: Manufacturer: Linux 4.4.0-rc4 ehci_hcd
> [    0.678448] usb usb1: SerialNumber: 0000:00:1a.0
> [    0.678576] hub 1-0:1.0: USB hub found
> [    0.678641] hub 1-0:1.0: 2 ports detected
> [    0.678825] ehci-pci 0000:00:1d.0: EHCI Host Controller
> [    0.678913] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
> [    0.679019] ehci-pci 0000:00:1d.0: debug port 2
> [    0.682980] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
> [    0.682985] ehci-pci 0000:00:1d.0: irq 23, io mem 0xdef3b000
> [    0.688070] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
> [    0.688149] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
> [    0.688217] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.688315] usb usb2: Product: EHCI Host Controller
> [    0.688380] usb usb2: Manufacturer: Linux 4.4.0-rc4 ehci_hcd
> [    0.688446] usb usb2: SerialNumber: 0000:00:1d.0
> [    0.688567] hub 2-0:1.0: USB hub found
> [    0.688632] hub 2-0:1.0: 2 ports detected
> [    0.688759] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    0.688828] ohci-pci: OHCI PCI platform driver
> [    0.688899] uhci_hcd: USB Universal Host Controller Interface driver
> [    0.689024] xhci_hcd 0000:00:14.0: xHCI Host Controller
> [    0.689119] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
> [    0.690285] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x00009810
> [    0.690391] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
> [    0.690469] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
> [    0.690538] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.690636] usb usb3: Product: xHCI Host Controller
> [    0.690701] usb usb3: Manufacturer: Linux 4.4.0-rc4 xhci-hcd
> [    0.690767] usb usb3: SerialNumber: 0000:00:14.0
> [    0.690885] hub 3-0:1.0: USB hub found
> [    0.690960] hub 3-0:1.0: 14 ports detected
> [    0.692489] xhci_hcd 0000:00:14.0: xHCI Host Controller
> [    0.692573] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
> [    0.692692] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
> [    0.692760] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.692858] usb usb4: Product: xHCI Host Controller
> [    0.692923] usb usb4: Manufacturer: Linux 4.4.0-rc4 xhci-hcd
> [    0.692989] usb usb4: SerialNumber: 0000:00:14.0
> [    0.693110] hub 4-0:1.0: USB hub found
> [    0.693182] hub 4-0:1.0: 6 ports detected
> [    0.693919] usbcore: registered new interface driver usbserial
> [    0.693988] usbcore: registered new interface driver usbserial_generic
> [    0.694063] usbserial: USB Serial support registered for generic
> [    0.694144] i8042: PNP: No PS/2 controller found. Probing ports directly.
> [    0.694550] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    0.694617] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    0.694739] mousedev: PS/2 mouse device common for all mice
> [    0.694942] rtc_cmos 00:02: RTC can wake from S4
> [    0.695263] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
> [    0.695349] rtc_cmos 00:02: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
> [    0.695474] device-mapper: uevent: version 1.0.3
> [    0.695673] device-mapper: ioctl: 4.34.0-ioctl (2015-10-28) initialised: dm-devel@redhat.com
> [    0.695910] Intel P-state driver initializing.
> [    0.697076] hidraw: raw HID events driver (C) Jiri Kosina
> [    0.697461] usbcore: registered new interface driver usbhid
> [    0.697570] usbhid: USB HID core driver
> [    0.697782] drop_monitor: Initializing network drop monitor service
> [    0.698099] ip_tables: (C) 2000-2006 Netfilter Core Team
> [    0.698339] Initializing XFRM netlink socket
> [    0.698766] NET: Registered protocol family 10
> [    0.699343] mip6: Mobile IPv6
> [    0.699452] NET: Registered protocol family 17
> [    0.700221] microcode: CPU0 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.700373] microcode: CPU1 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.700528] microcode: CPU2 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.700685] microcode: CPU3 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.700818] microcode: CPU4 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.700974] microcode: CPU5 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.701105] microcode: CPU6 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.701260] microcode: CPU7 sig=0x306c3, pf=0x2, revision=0x1c
> [    0.701479] microcode: Microcode Update Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> [    0.701705] AVX2 version of gcm_enc/dec engaged.
> [    0.701812] AES CTR mode by8 optimization enabled
> [    0.746054] registered taskstats version 1
> [    0.746154] Loading compiled-in X.509 certificates
> [    0.747113] Loaded X.509 cert 'Build time autogenerated kernel key: f285d2e5fabfd5889c4db4f4121541d542f6a381'
> [    0.748091] zswap: default zpool zbud not available
> [    0.748165] zswap: pool creation failed
> [    0.748902]   Magic number: 11:646:434
> [    0.749135] rtc_cmos 00:02: setting system clock to 2015-12-10 14:24:07 UTC (1449757447)
> [    0.749317] PM: Hibernation image not present or could not be loaded.
> [    0.957090] ata4: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    0.957168] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    0.957496] ata1.00: ATA-9: INTEL SSDSC2BB480G4, D2010370, max UDMA/133
> [    0.957564] ata1.00: 937703088 sectors, multi 1: LBA48 NCQ (depth 31/32)
> [    0.957970] ata1.00: configured for UDMA/133
> [    0.958163] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> [    0.958265] scsi 0:0:0:0: Direct-Access     ATA      INTEL SSDSC2BB48 0370 PQ: 0 ANSI: 5
> [    0.958541] ata1.00: Enabling discard_zeroes_data
> [    0.958593] sd 0:0:0:0: Attached scsi generic sg0 type 0
> [    0.958836] sd 0:0:0:0: [sda] 937703088 512-byte logical blocks: (480 GB/447 GiB)
> [    0.958847] ata4.00: ATA-8: WDC WD5000AAKX-753CA0, 15.01H15, max UDMA/133
> [    0.958847] ata4.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
> [    0.959108] sd 0:0:0:0: [sda] 4096-byte physical blocks
> [    0.959360] sd 0:0:0:0: [sda] Write Protect is off
> [    0.959441] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    0.959462] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    0.959681] ata1.00: Enabling discard_zeroes_data
> [    0.960094]  sda: sda1 sda2
> [    0.960393] ata1.00: Enabling discard_zeroes_data
> [    0.960718] sd 0:0:0:0: [sda] Attached SCSI disk
> [    0.960750] ata4.00: configured for UDMA/133
> [    0.960842] ata6.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
> [    0.960843] ata6.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
> [    0.960844] ata6.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
> [    0.960901] scsi 3:0:0:0: Direct-Access     ATA      WDC WD5000AAKX-7 1H15 PQ: 0 ANSI: 5
> [    0.961001] sd 3:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB/465 GiB)
> [    0.961005] sd 3:0:0:0: Attached scsi generic sg1 type 0
> [    0.961083] sd 3:0:0:0: [sdb] Write Protect is off
> [    0.961084] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
> [    0.961145] sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    0.962357] ata6.00: ATAPI: ATAPI   iHAS124   W, HL0G, max UDMA/100
> [    0.964747] ata6.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
> [    0.964749] ata6.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
> [    0.964849] ata6.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
> [    0.966478] ata6.00: configured for UDMA/100
> [    0.967688] scsi 5:0:0:0: CD-ROM            ATAPI    iHAS124   W      HL0G PQ: 0 ANSI: 5
> [    0.971095] ata12: SATA link down (SStatus 0 SControl 300)
> [    0.972106] ata13: SATA link down (SStatus 0 SControl 300)
> [    0.972201] ata7: SATA link down (SStatus 0 SControl 300)
> [    0.972285] ata8: SATA link down (SStatus 0 SControl 300)
> [    0.972372] ata10: SATA link down (SStatus 0 SControl 300)
> [    0.973081] ata9: SATA link down (SStatus 0 SControl 300)
> [    0.974139] ata11: SATA link down (SStatus 0 SControl 300)
> [    0.974252] ata14: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> [    0.974416] ata14.00: ATAPI: MARVELL VIRTUALL, 1.09, max UDMA/66
> [    0.974650] ata14.00: configured for UDMA/66
> [    0.980075] usb 1-1: new high-speed USB device number 2 using ehci-pci
> [    0.990082] usb 2-1: new high-speed USB device number 2 using ehci-pci
> [    0.991667] sr 5:0:0:0: [sr0] scsi3-mmc drive: 188x/125x writer dvd-ram cd/rw xa/form2 cdda tray
> [    0.991767] cdrom: Uniform CD-ROM driver Revision: 3.20
> [    0.991989] sr 5:0:0:0: Attached scsi CD-ROM sr0
> [    0.992061] sr 5:0:0:0: Attached scsi generic sg2 type 5
> [    0.992656]  sdb: sdb1 sdb2 < sdb5 sdb6 >
> [    0.992677] scsi 13:0:0:0: Processor         Marvell  Console          1.01 PQ: 0 ANSI: 5
> [    0.993202] sd 3:0:0:0: [sdb] Attached SCSI disk
> [    0.995234] usb 4-5: new SuperSpeed USB device number 2 using xhci_hcd
> [    1.004108] ata14.00: exception Emask 0x0 SAct 0x0 SErr 0x0 action 0x6
> [    1.004175] ata14.00: irq_stat 0x40000001
> [    1.004241] ata14.00: cmd a0/01:00:00:00:01/00:00:00:00:00/a0 tag 2 dma 16640 in
>                         Inquiry 12 01 00 00 ff 00res 00/00:00:00:00:00/00:00:00:00:00/00 Emask 0x3 (HSM violation)
> [    1.004414] ata14: hard resetting link
> [    1.007738] usb 4-5: New USB device found, idVendor=045b, idProduct=0210
> [    1.007822] usb 4-5: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.009900] hub 4-5:1.0: USB hub found
> [    1.010193] hub 4-5:1.0: 4 ports detected
> [    1.045057] usb 3-9: new high-speed USB device number 2 using xhci_hcd
> [    1.094452] usb 1-1: New USB device found, idVendor=8087, idProduct=8008
> [    1.094535] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.094760] hub 1-1:1.0: USB hub found
> [    1.094971] hub 1-1:1.0: 6 ports detected
> [    1.104491] usb 2-1: New USB device found, idVendor=8087, idProduct=8000
> [    1.104559] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.104882] hub 2-1:1.0: USB hub found
> [    1.105116] hub 2-1:1.0: 8 ports detected
> [    1.114253] usb 4-6: new SuperSpeed USB device number 3 using xhci_hcd
> [    1.126978] usb 4-6: New USB device found, idVendor=045b, idProduct=0210
> [    1.127050] usb 4-6: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.129521] hub 4-6:1.0: USB hub found
> [    1.129882] hub 4-6:1.0: 4 ports detected
> [    1.210083] usb 3-9: New USB device found, idVendor=045b, idProduct=0209
> [    1.210152] usb 3-9: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.210693] hub 3-9:1.0: USB hub found
> [    1.210848] hub 3-9:1.0: 4 ports detected
> [    1.311076] ata14: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> [    1.311540] ata14.00: configured for UDMA/66
> [    1.311691] ata14: EH complete
> [    1.311836] scsi 13:0:0:0: Attached scsi generic sg3 type 3
> [    1.312633] Freeing unused kernel memory: 1488K (ffffffff81d4a000 - ffffffff81ebe000)
> [    1.312732] Write protecting the kernel read-only data: 12288k
> [    1.313124] Freeing unused kernel memory: 956K (ffff880001711000 - ffff880001800000)
> [    1.314429] Freeing unused kernel memory: 812K (ffff880001b35000 - ffff880001c00000)
> [    1.315945] random: systemd urandom read with 17 bits of entropy available
> [    1.317410] systemd[1]: systemd 222 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
> [    1.317666] systemd[1]: Detected architecture x86-64.
> [    1.317731] systemd[1]: Running in initial RAM disk.
> [    1.318130] systemd[1]: Set hostname to <lahna>.
> [    1.342849] systemd[1]: Created slice -.slice.
> [    1.342918] systemd[1]: Starting -.slice.
> [    1.343276] systemd[1]: Listening on udev Control Socket.
> [    1.343345] systemd[1]: Starting udev Control Socket.
> [    1.343658] systemd[1]: Listening on Journal Audit Socket.
> [    1.343727] systemd[1]: Starting Journal Audit Socket.
> [    1.344025] systemd[1]: Listening on Journal Socket.
> [    1.344143] systemd[1]: Starting Journal Socket.
> [    1.344425] systemd[1]: Listening on udev Kernel Socket.
> [    1.344493] systemd[1]: Starting udev Kernel Socket.
> [    1.344767] systemd[1]: Reached target Local File Systems.
> [    1.344834] systemd[1]: Starting Local File Systems.
> [    1.345163] systemd[1]: Reached target Swap.
> [    1.345229] systemd[1]: Starting Swap.
> [    1.345498] systemd[1]: Reached target Timers.
> [    1.345564] systemd[1]: Starting Timers.
> [    1.345867] systemd[1]: Created slice System Slice.
> [    1.345935] systemd[1]: Starting System Slice.
> [    1.346261] systemd[1]: Reached target Slices.
> [    1.346326] systemd[1]: Starting Slices.
> [    1.351119] systemd[1]: Starting Create list of required static device nodes for the current kernel...
> [    1.351427] systemd[1]: Started dracut ask for additional cmdline parameters.
> [    1.351770] systemd[1]: Starting dracut cmdline hook...
> [    1.352086] systemd[1]: Started Load Kernel Modules.
> [    1.352363] systemd[1]: Starting Apply Kernel Variables...
> [    1.352805] systemd[1]: Starting Setup Virtual Console...
> [    1.353383] systemd[1]: Listening on Journal Socket (/dev/log).
> [    1.353464] systemd[1]: Starting Journal Socket (/dev/log).
> [    1.353923] systemd[1]: Reached target Sockets.
> [    1.353999] systemd[1]: Starting Sockets.
> [    1.354377] systemd[1]: Starting Journal Service...
> [    1.355092] systemd[1]: Started Create list of required static device nodes for the current kernel.
> [    1.359066] systemd[1]: Started Apply Kernel Variables.
> [    1.359164] audit: type=1130 audit(1449757448.108:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.361336] systemd[1]: Starting Create Static Device Nodes in /dev...
> [    1.363279] systemd[1]: Started Setup Virtual Console.
> [    1.363374] audit: type=1130 audit(1449757448.112:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.363942] systemd[1]: Started Create Static Device Nodes in /dev.
> [    1.364041] usb 3-10: new high-speed USB device number 3 using xhci_hcd
> [    1.364048] audit: type=1130 audit(1449757448.113:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.380199] systemd[1]: Started Journal Service.
> [    1.380314] audit: type=1130 audit(1449757448.129:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.403381] audit: type=1130 audit(1449757448.152:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.428220] audit: type=1130 audit(1449757448.177:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.437527] audit: type=1130 audit(1449757448.186:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.467161] audit: type=1130 audit(1449757448.216:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.479112] pps_core: LinuxPPS API ver. 1 registered
> [    1.479194] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    1.483779] PTP clock support registered
> [    1.485841] dca service started, version 1.12.1
> [    1.511867] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.0-k
> [    1.511944] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    1.513729] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
> [    1.513809] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
> [    1.513978] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [    1.524909] [drm] Initialized drm 1.1.0 20060810
> [    1.534230] usb 3-10: New USB device found, idVendor=045b, idProduct=0209
> [    1.534307] usb 3-10: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.534804] hub 3-10:1.0: USB hub found
> [    1.534891] hub 3-10:1.0: 4 ports detected
> [    1.607036] usb 3-9.1: new low-speed USB device number 4 using xhci_hcd
> [    1.616034] tsc: Refined TSC clocksource calibration: 3491.912 MHz
> [    1.616115] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x3255787006b, max_idle_ns: 440795244845 ns
> [    1.649608] pps pps0: new PPS source ptp0
> [    1.649680] igb 0000:75:00.0: added PHC on eth0
> [    1.649751] igb 0000:75:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    1.649828] igb 0000:75:00.0: eth0: (PCIe:2.5Gb/s:Width x1) 74:d4:35:1b:fc:39
> [    1.649971] igb 0000:75:00.0: eth0: PBA No: 000200-000
> [    1.650077] igb 0000:75:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> [    1.650864] igb 0000:75:00.0 enp117s0: renamed from eth0
> [    1.682273] e1000e 0000:00:19.0 eth0: registered PHC clock
> [    1.682351] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) 74:d4:35:1b:fc:26
> [    1.682473] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
> [    1.682566] e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
> [    1.683373] e1000e 0000:00:19.0 eno1: renamed from eth0
> [    1.683474] [drm] Memory usable by graphics device = 2048M
> [    1.683580] [drm] Replacing VGA console driver
> [    1.684219] Console: switching to colour dummy device 80x25
> [    1.690772] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
> [    1.690776] [drm] Driver supports precise vblank timestamp query.
> [    1.690847] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
> [    1.697629] usb 3-9.1: New USB device found, idVendor=046d, idProduct=c31c
> [    1.697632] usb 3-9.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.697635] usb 3-9.1: Product: USB Keyboard
> [    1.697637] usb 3-9.1: Manufacturer: Logitech
> [    1.697705] usb 3-9.1: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
> [    1.697709] usb 3-9.1: ep 0x82 - rounding interval to 1024 microframes, ep desc says 2040 microframes
> [    1.703231] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-9/3-9.1/3-9.1:1.0/0003:046D:C31C.0001/input/input5
> [    1.754201] hid-generic 0003:046D:C31C.0001: input,hidraw0: USB HID v1.10 Keyboard [Logitech USB Keyboard] on usb-0000:00:14.0-9.1/input0
> [    1.761755] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-9/3-9.1/3-9.1:1.1/0003:046D:C31C.0002/input/input6
> [    1.763644] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
> [    1.763918] acpi device:70: registered as cooling_device5
> [    1.763958] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input7
> [    1.808061] usb 3-10.1: new high-speed USB device number 5 using xhci_hcd
> [    1.812206] hid-generic 0003:046D:C31C.0002: input,hidraw1: USB HID v1.10 Device [Logitech USB Keyboard] on usb-0000:00:14.0-9.1/input1
> [    1.812224] [drm] Initialized i915 1.6.0 20151010 for 0000:00:02.0 on minor 0
> [    1.837480] fbcon: inteldrmfb (fb0) is primary device
> [    1.898097] usb 3-10.1: New USB device found, idVendor=0409, idProduct=005a
> [    1.898098] usb 3-10.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> [    1.898492] hub 3-10.1:1.0: USB hub found
> [    1.898513] hub 3-10.1:1.0: 4 ports detected
> [    1.944450] Console: switching to colour frame buffer device 240x75
> [    1.947205] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
> [    1.972025] usb 3-10.2: new low-speed USB device number 6 using xhci_hcd
> [    2.002178] random: nonblocking pool is initialized
> [    2.037402] audit: type=1130 audit(1449757448.786:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    2.065364] usb 3-10.2: New USB device found, idVendor=046d, idProduct=c03d
> [    2.065400] usb 3-10.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.065415] usb 3-10.2: Product: USB-PS/2 Optical Mouse
> [    2.065426] usb 3-10.2: Manufacturer: Logitech
> [    2.065588] usb 3-10.2: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
> [    2.069384] input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:00/0000:00:14.0/usb3/3-10/3-10.2/3-10.2:1.0/0003:046D:C03D.0003/input/input8
> [    2.069724] hid-generic 0003:046D:C03D.0003: input,hidraw2: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:14.0-10.2/input0
> [    2.160218] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
> [    2.172986] usb 3-10.1.4: new full-speed USB device number 7 using xhci_hcd
> [    2.257989] usb 3-10.1.4: New USB device found, idVendor=0557, idProduct=2008
> [    2.257992] usb 3-10.1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.258009] usb 3-10.1.4: Product: USB-Serial Controller
> [    2.258010] usb 3-10.1.4: Manufacturer: Prolific Technology Inc.
> [    2.349647] systemd-journald[225]: Received SIGTERM from PID 1 (systemd).
> [    2.396733] SELinux:  Disabled at runtime.
> [    2.396745] SELinux:  Unregistering netfilter hooks
> [    2.518474] EXT4-fs (dm-1): re-mounted. Opts: (null)
> [    2.523694] systemd-journald[620]: File /var/log/journal/0254cb1991d24891a563675feaf636a3/system.journal corrupted or uncleanly shut down, renaming and replacing.
> [    2.553839] systemd-journald[620]: Received request to flush runtime journal from PID 1
> [    2.621784] clocksource: Switched to clocksource tsc
> [    2.622893] wmi: Mapper loaded
> [    2.646882] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [    2.651612] i801_smbus 0000:00:1f.3: enabling device (0001 -> 0003)
> [    2.651618] ACPI Warning: SystemIO range 0x000000000000F040-0x000000000000F05F conflicts with OpRegion 0x000000000000F040-0x000000000000F04F (\_SB_.PCI0.SBUS.SMBI) (20150930/utaddress-254)
> [    2.651621] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
> [    2.716546] iTCO_vendor_support: vendor-support=0
> [    2.722548] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
> [    2.722578] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
> [    2.813213] snd_hda_intel 0000:00:03.0: bound 0000:00:02.0 (ops i915_audio_component_bind_ops [i915])
> [    2.839515] snd_hda_codec_realtek hdaudioC1D2: autoconfig for ALC898: line_outs=3 (0x14/0x15/0x16/0x0/0x0) type:line
> [    2.839518] snd_hda_codec_realtek hdaudioC1D2:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
> [    2.839519] snd_hda_codec_realtek hdaudioC1D2:    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
> [    2.839520] snd_hda_codec_realtek hdaudioC1D2:    mono: mono_out=0x0
> [    2.839521] snd_hda_codec_realtek hdaudioC1D2:    dig-out=0x11/0x1e
> [    2.839521] snd_hda_codec_realtek hdaudioC1D2:    inputs:
> [    2.839523] snd_hda_codec_realtek hdaudioC1D2:      Front Mic=0x19
> [    2.839524] snd_hda_codec_realtek hdaudioC1D2:      Rear Mic=0x18
> [    2.839525] snd_hda_codec_realtek hdaudioC1D2:      Line=0x1a
> [    2.839526] snd_hda_codec_realtek hdaudioC1D2:    dig-in=0x1f
> [    2.839652] input: HDA Intel HDMI HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:03.0/sound/card0/input9
> [    2.839706] input: HDA Intel HDMI HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:03.0/sound/card0/input10
> [    2.839751] input: HDA Intel HDMI HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:03.0/sound/card0/input11
> [    2.840349] Adding 8200188k swap on /dev/mapper/fedora-swap.  Priority:-1 extents:1 across:8200188k SSFS
> [    2.848018] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
> [    2.854616] input: HDA Intel PCH Front Mic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input12
> [    2.854669] input: HDA Intel PCH Rear Mic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input13
> [    2.854714] input: HDA Intel PCH Line as /devices/pci0000:00/0000:00:1b.0/sound/card1/input14
> [    2.854759] input: HDA Intel PCH Line Out Front as /devices/pci0000:00/0000:00:1b.0/sound/card1/input15
> [    2.854802] input: HDA Intel PCH Line Out Surround as /devices/pci0000:00/0000:00:1b.0/sound/card1/input16
> [    2.854846] input: HDA Intel PCH Line Out CLFE as /devices/pci0000:00/0000:00:1b.0/sound/card1/input17
> [    2.854889] input: HDA Intel PCH Front Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card1/input18
> [    2.931952] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
> [    3.484731] EXT4-fs (sdb6): mounted filesystem with ordered data mode. Opts: (null)
> [    3.676865] usbcore: registered new interface driver pl2303
> [    3.676889] usbserial: USB Serial support registered for pl2303
> [    3.676918] pl2303 3-10.1.4:1.0: pl2303 converter detected
> [    3.679889] usb 3-10.1.4: pl2303 converter now attached to ttyUSB0
> [    4.098694] IPv6: ADDRCONF(NETDEV_UP): enp117s0: link is not ready
> [    4.343363] IPv6: ADDRCONF(NETDEV_UP): enp117s0: link is not ready
> [    4.344766] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
> [    4.546040] IPv6: ADDRCONF(NETDEV_UP): eno1: link is not ready
> [    4.640218] ip6_tables: (C) 2000-2006 Netfilter Core Team
> [    4.676116] Ebtables v2.0 registered
> [    4.767892] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this.
> [    4.971396] fuse init (API version 7.23)
> [   10.726298] e1000e: eno1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
> [   10.726344] IPv6: ADDRCONF(NETDEV_CHANGE): eno1: link becomes ready
> [   11.118245] systemd-journald[620]: File /var/log/journal/0254cb1991d24891a563675feaf636a3/user-1000.journal corrupted or uncleanly shut down, renaming and replacing.
> [  163.595475] ld invoked oom-killer: gfp_mask=0x24200ca, order=0, oom_score_adj=0
> [  163.596555] ld cpuset=/ mems_allowed=0
> [  163.597684] CPU: 3 PID: 4080 Comm: ld Tainted: G          I     4.4.0-rc4 #2
> [  163.598770] Hardware name: Gigabyte Technology Co., Ltd. Z87X-UD7 TH/Z87X-UD7 TH-CF, BIOS F4 03/18/2014
> [  163.599988]  0000000000000000 ffff88044a957a58 ffffffff8136a8cf ffff88044a957c30
> [  163.601027]  ffff88044a957ac0 ffffffff811f972e 01ff88048f2d7130 00000000ffffffff
> [  163.602174]  0000000000000000 0000000000000000 ffff88044a957b38 0000000000000206
> [  163.603228] Call Trace:
> [  163.604253]  [<ffffffff8136a8cf>] dump_stack+0x44/0x55
> [  163.605229]  [<ffffffff811f972e>] dump_header+0x59/0x1bf
> [  163.606372]  [<ffffffff81188ddc>] oom_kill_process+0x1fc/0x3b0
> [  163.607337]  [<ffffffff81189431>] out_of_memory+0x451/0x490
> [  163.608281]  [<ffffffff8118f355>] __alloc_pages_nodemask+0x9c5/0xaf0
> [  163.609223]  [<ffffffff811d8253>] alloc_pages_vma+0xb3/0x260
> [  163.610166]  [<ffffffff811c8d9c>] __read_swap_cache_async+0xec/0x140
> [  163.611110]  [<ffffffff811c8e07>] read_swap_cache_async+0x17/0x40
> [  163.612052]  [<ffffffff811c8f1e>] swapin_readahead+0xee/0x190
> [  163.613010]  [<ffffffff811b7240>] handle_mm_fault+0x1250/0x17c0
> [  163.613955]  [<ffffffff81060578>] __do_page_fault+0x188/0x3e0
> [  163.614885]  [<ffffffff8112d1ed>] ? __audit_syscall_exit+0x1dd/0x260
> [  163.615820]  [<ffffffff810607f2>] do_page_fault+0x22/0x30
> [  163.616748]  [<ffffffff8170b938>] page_fault+0x28/0x30
> [  163.617670] Mem-Info:
> [  163.618590] active_anon:3597145 inactive_anon:397633 isolated_anon:105
>                 active_file:128 inactive_file:1168 isolated_file:0
>                 unevictable:0 dirty:0 writeback:234 unstable:0
>                 slab_reclaimable:9476 slab_unreclaimable:7642
>                 mapped:407 shmem:247 pagetables:17294 bounce:0
>                 free:23031 free_pcp:337 free_cma:0
> [  163.624115] Node 0 DMA free:15884kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [  163.626131] lowmem_reserve[]: 0 1589 15913 15913
> [  163.627280] Node 0 DMA32 free:58900kB min:1604kB low:2004kB high:2404kB active_anon:1163596kB inactive_anon:388312kB active_file:44kB inactive_file:44kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1709984kB managed:1631080kB mlocked:0kB dirty:0kB writeback:0kB mapped:152kB shmem:148kB slab_reclaimable:3052kB slab_unreclaimable:2504kB kernel_stack:544kB pagetables:6704kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5616 all_unreclaimable? yes
> [  163.630995] lowmem_reserve[]: 0 0 14324 14324
> [  163.632076] Node 0 Normal free:14576kB min:14480kB low:18100kB high:21720kB active_anon:13225296kB inactive_anon:1202436kB active_file:1508kB inactive_file:5664kB unevictable:0kB isolated(anon):420kB isolated(file):0kB present:14931968kB managed:14667908kB mlocked:0kB dirty:0kB writeback:160kB mapped:3028kB shmem:840kB slab_reclaimable:34852kB slab_unreclaimable:28048kB kernel_stack:6112kB pagetables:62472kB unstable:0kB bounce:0kB free_pcp:1008kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:40448 all_unreclaimable? no
> [  163.635698] lowmem_reserve[]: 0 0 0 0
> [  163.636926] Node 0 DMA: 1*4kB (U) 1*8kB (U) 2*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB
> [  163.638108] Node 0 DMA32: 91*4kB (UME) 77*8kB (UE) 46*16kB (UME) 61*32kB (UME) 37*64kB (UME) 75*128kB (UME) 75*256kB (UME) 17*512kB (UME) 7*1024kB (ME) 2*2048kB (ME) 1*4096kB (M) = 58900kB
> [  163.639264] Node 0 Normal: 171*4kB (UME) 119*8kB (UE) 302*16kB (UME) 75*32kB (UME) 17*64kB (UM) 1*128kB (M) 1*256kB (M) 0*512kB 4*1024kB (M) 0*2048kB 0*4096kB = 14436kB
> [  163.640461] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [  163.641697] 6353 total pagecache pages
> [  163.642851] 3851 pages in swap cache
> [  163.644104] Swap cache stats: add 4095131, delete 4091398, find 895645/1195327
> [  163.645253] Free swap  = 0kB
> [  163.646416] Total swap = 8200188kB
> [  163.647588] 4164484 pages RAM
> [  163.648729] 0 pages HighMem/MovableOnly
> [  163.649869] 85762 pages reserved
> [  163.650981] 0 pages hwpoisoned
> [  163.652290] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [  163.653352] [  620]     0   620    11451      544      25       3       71             0 systemd-journal
> [  163.654451] [  655]     0   655    32310        0      30       3       99             0 lvmetad
> [  163.655445] [  676]     0   676    10734       12      25       3      284         -1000 systemd-udevd
> [  163.656428] [  866]     0   866    12268        0      24       3      103         -1000 auditd
> [  163.657388] [  881]     0   881    20058        0      10       3       45             0 audispd
> [  163.658364] [  882]     0   882    85376        0      70       3      417             0 ModemManager
> [  163.659285] [  883]     0   883    13049        1      31       3       86             0 sedispatch
> [  163.660244] [  887]     0   887     1095       21       8       3       17             0 rngd
> [  163.661179] [  891]    81   891    13980      230      32       3      133          -900 dbus-daemon
> [  163.662111] [  900]     0   900     4295       47      13       3       32             0 irqbalance
> [  163.663044] [  902]   172   902    48851        4      32       3       89             0 rtkit-daemon
> [  163.663989] [  903]     0   903     6112       58      18       3       36             0 systemd-logind
> [  163.664923] [  910]   996   910     5157       20      15       3       30             0 chronyd
> [  163.665934] [  911]     0   911    98076       83      44       3      569             0 accounts-daemon
> [  163.666859] [  916]    70   916    14168       30      31       3       80             0 avahi-daemon
> [  163.667781] [  918]     0   918     4225        0      14       4       82             0 alsactl
> [  163.668708] [  920]     0   920     1630        1       9       3       29             0 mcelog
> [  163.669625] [  941]    70   941    14168        0      30       3       97             0 avahi-daemon
> [  163.670550] [  943]     0   943   134043      308      79       3      243             0 NetworkManager
> [  163.671487] [  955]     0   955   108422        1      59       3      344             0 abrtd
> [  163.672596] [  962]   999   962   132850     1172      57       4     1332             0 polkitd
> [  163.673657] [  976]     0   976    20353        1      43       3      207         -1000 sshd
> [  163.674575] [  985]     0   985   162373        1     156       4     2105             0 libvirtd
> [  163.675501] [  989]     0   989    32115       16      18       3      133             0 crond
> [  163.676437] [  991]     0   991     5956        0      17       3       48             0 atd
> [  163.677338] [  995]     0   995   101904        1      50       4      254             0 gdm
> [  163.678274] [ 1001]     0  1001    92968        1      66       3      932             0 gdm-session-wor
> [  163.679181] [ 1005]    42  1005    11270        1      26       3      170             0 systemd
> [  163.680067] [ 1007]    42  1007    22811        0      46       3      505             0 (sd-pam)
> [  163.681034] [ 1010]    42  1010   112305        0      98       3      348             0 gdm-wayland-ses
> [  163.681939] [ 1012]    42  1012    13733        1      32       3      188             0 dbus-daemon
> [  163.682837] [ 1013]    42  1013   146214       35     110       3      932             0 gnome-session-b
> [  163.683769] [ 1021]    42  1021   392384     1785     285       5    10306             0 gnome-shell
> [  163.684656] [ 1042]     0  1042    89852       41      55       3      329             0 upowerd
> [  163.685539] [ 1078]     0  1078   298854      478     297       5      263             0 abrt-dump-journ
> [  163.686482] [ 1085]     0  1085   292730      319     353       4      278             0 abrt-dump-journ
> [  163.687392] [ 1101]     0  1101    18147        0      40       3      182             0 wpa_supplicant
> [  163.688293] [ 1131]    42  1131    95907        1      38       4      693             0 gvfsd
> [  163.689184] [ 1136]    42  1136    85866        0      32       4      693             0 gvfsd-fuse
> [  163.690079] [ 1151]    42  1151    76658       29     117       3     4993             0 Xwayland
> [  163.690982] [ 1162]    42  1162    84496        0      34       3      156             0 at-spi-bus-laun
> [  163.691891] [ 1167]    42  1167    13646        1      31       3      104             0 dbus-daemon
> [  163.692791] [ 1169]    42  1169    56297        0      45       4      207             0 at-spi2-registr
> [  163.693765] [ 1175]    42  1175   152266       65      90       4      697             0 pulseaudio
> [  163.694692] [ 1192]    42  1192   112234       24      37       3      595             0 ibus-daemon
> [  163.695567] [ 1196]    42  1196    92829        0      34       4      157             0 ibus-dconf
> [  163.696463] [ 1198]    42  1198   126643        1     129       3     1505             0 ibus-x11
> [  163.697341] [ 1209]     0  1209   130828      109     103       4      638             0 packagekitd
> [  163.698232] [ 1217]    42  1217   261636       79     196       4     1938             0 gnome-settings-
> [  163.699114] [ 1222]    42  1222   104361        0      53       4      368             0 gvfs-udisks2-vo
> [  163.699966] [ 1226]     0  1226    93653       54      47       3      443             0 udisksd
> [  163.700819] [ 1240]    42  1240    99070        0      44       4      243             0 gvfs-gphoto2-vo
> [  163.701605] [ 1245]    42  1245   119454        0      48       3      245             0 gvfs-afc-volume
> [  163.702384] [ 1251]    42  1251    91725        0      30       4      661             0 gvfs-goa-volume
> [  163.703119] [ 1255]    42  1255   186303       91     162       4     3155             0 goa-daemon
> [  163.703831] [ 1267]    42  1267   111411        0     114       4      475             0 goa-identity-se
> [  163.704527] [ 1269]    42  1269   100916      163      65       3      234             0 mission-control
> [  163.705205] [ 1272]    42  1272    96796        0      40       4      204             0 gvfs-mtp-volume
> [  163.705852] [ 1321]    42  1321    74379        1      31       4      158             0 ibus-engine-sim
> [  163.706469] [ 1362]   998  1362   103051        1      52       4      532             0 colord
> [  163.707081] [ 1401]     0  1401    96610        1      74       5     1619             0 gdm-session-wor
> [  163.707690] [ 1404]     0  1404    23375        1      47       3     3099             0 dhclient
> [  163.708259] [ 1448]  1000  1448    11270        1      28       3      176             0 systemd
> [  163.708815] [ 1450]  1000  1450    22805        0      46       3      500             0 (sd-pam)
> [  163.709374] [ 1552]  1000  1552   112309        0      95       4      348             0 gdm-x-session
> [  163.709914] [ 1558]  1000  1558    48645      217      88       4     1562             0 Xorg
> [  163.710446] [ 1622]  1000  1622    13674        1      30       3      122             0 dbus-daemon
> [  163.710971] [ 1627]  1000  1627    33101       33      18       3       52             0 dwm
> [  163.711551] [ 1649]  1000  1649    13471       11      29       3      133             0 ssh-agent
> [  163.712079] [ 1684]  1000  1684   142286       33     127       4     1394             0 gnome-screensav
> [  163.712599] [ 1685]  1000  1685    29378       28      13       3       27             0 update-titlebar
> [  163.713121] [ 1690]  1000  1690    84496        0      35       4      149             0 at-spi-bus-laun
> [  163.713660] [ 1695]  1000  1695    13646        1      31       3      101             0 dbus-daemon
> [  163.714186] [ 1697]  1000  1697    56304       28      46       3      670             0 at-spi2-registr
> [  163.714726] [ 1704]  1000  1704    95907        1      39       3      182             0 gvfsd
> [  163.715231] [ 1709]  1000  1709    85866        0      33       3      182             0 gvfsd-fuse
> [  163.715739] [ 1818]     0  1818    28579        0      10       3       31             0 agetty
> [  163.716239] [ 1866]     0  1866    30797        1      63       3      220             0 login
> [  163.716748] [ 1879]  1000  1879    30303        1      13       3      450             0 bash
> [  163.717281] [ 2034]  1000  2034    49402        1      48       3     1440             0 python
> [  163.717796] [ 2035]  1000  2035    29478        1      12       3      160             0 bash
> [  163.718300] [ 3653]  1000  3653    28019        0      56       4      310             0 cmake
> [  163.718817] [ 3654]  1000  3654    28648        1      12       3       99             0 gmake
> [  163.719315] [ 3657]  1000  3657    28776        1      11       3      214             0 gmake
> [  163.719807] [ 4047]  1000  4047    28733        1      11       4      184             0 gmake
> [  163.720295] [ 4048]  1000  4048    28736        1      11       3      187             0 gmake
> [  163.720784] [ 4049]  1000  4049    28733        1      11       4      184             0 gmake
> [  163.721262] [ 4050]  1000  4050    28731        1      11       3      182             0 gmake
> [  163.721739] [ 4052]  1000  4052    28769        1      11       3      198             0 gmake
> [  163.722250] [ 4054]  1000  4054    28775        1      11       3      227             0 gmake
> [  163.722734] [ 4062]  1000  4062    29378        0      12       3       56             0 sh
> [  163.723215] [ 4063]  1000  4063    27953        0      56       3      265             0 cmake
> [  163.723691] [ 4064]  1000  4064    29378        0      13       3       56             0 sh
> [  163.724163] [ 4065]  1000  4065    27953        0      55       3      265             0 cmake
> [  163.724627] [ 4066]  1000  4066    29378        0      12       3       57             0 sh
> [  163.725096] [ 4067]  1000  4067    27953        0      54       3      265             0 cmake
> [  163.725561] [ 4068]  1000  4068    29378        0      11       3       57             0 sh
> [  163.726019] [ 4069]  1000  4069    27953        0      58       3      265             0 cmake
> [  163.726487] [ 4070]  1000  4070    21230        0      39       3      828             0 clang++
> [  163.726974] [ 4071]  1000  4071    21230        0      38       4      827             0 clang++
> [  163.727431] [ 4072]  1000  4072    29378        0      12       3       57             0 sh
> [  163.727909] [ 4073]  1000  4073    27953        0      57       3      265             0 cmake
> [  163.728429] [ 4074]  1000  4074    29378        0      12       4       57             0 sh
> [  163.728890] [ 4075]  1000  4075    27953        0      54       3      267             0 cmake
> [  163.729339] [ 4076]  1000  4076    21230        0      38       3      825             0 clang++
> [  163.729797] [ 4077]  1000  4077    21230        0      39       3      828             0 clang++
> [  163.730232] [ 4078]  1000  4078    21230        0      39       3      827             0 clang++
> [  163.730678] [ 4079]  1000  4079    21230        0      39       3      830             0 clang++
> [  163.731112] [ 4080]  1000  4080  1029866   642712    1965       7   357093             0 ld
> [  163.731539] [ 4081]  1000  4081   921021   573029    1754       7   317933             0 ld
> [  163.731976] [ 4082]  1000  4082  1017558   622105    1943       7   365417             0 ld
> [  163.732430] [ 4083]  1000  4083  1035550   708847    1975       6   296676             0 ld
> [  163.733054] [ 4084]  1000  4084   893425   549633    1697       6   313762             0 ld
> [  163.733469] [ 4085]  1000  4085  1240475   890427    2375       8   318934             0 ld
> [  163.734020] [ 4476]  1000  4476    28044       18       9       3        0             0 sleep
> [  163.734435] Out of memory: Kill process 4085 (ld) score 197 or sacrifice child
> [  163.734869] Killed process 4085 (ld) total-vm:4961900kB, anon-rss:3561692kB, file-rss:16kB
> [  254.740603] page:ffffea00111c31c0 count:2 mapcount:0 mapping:          (null) index:0x0
> [  254.740636] flags: 0x5fff8000048028(uptodate|lru|swapcache|swapbacked)
> [  254.740655] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> [  254.740679] ------------[ cut here ]------------
> [  254.740690] kernel BUG at mm/memcontrol.c:5270!
> [  254.740700] invalid opcode: 0000 [#1] SMP 
> [  254.740710] Modules linked in: fuse bridge stp llc ebtable_filter ebtables ip6table_filter ip6_tables pl2303 snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec x86_pkg_temp_thermal coretemp snd_hwdep kvm_intel snd_hda_core kvm snd_seq snd_seq_device snd_pcm iTCO_wdt iTCO_vendor_support mxm_wmi snd_timer irqbypass crct10dif_pclmul crc32_pclmul snd crc32c_intel joydev mei_me mei i2c_i801 shpchp lpc_ich soundcore mfd_core wmi i915 drm_kms_helper drm e1000e igb serio_raw dca ptp i2c_algo_bit pps_core i2c_core video
> [  254.740863] CPU: 1 PID: 1558 Comm: Xorg Tainted: G          I     4.4.0-rc4 #2
> [  254.740888] Hardware name: Gigabyte Technology Co., Ltd. Z87X-UD7 TH/Z87X-UD7 TH-CF, BIOS F4 03/18/2014
> [  254.740906] task: ffff88047907e800 ti: ffff880477a6c000 task.ti: ffff880477a6c000
> [  254.740921] RIP: 0010:[<ffffffff811f51a5>]  [<ffffffff811f51a5>] mem_cgroup_try_charge+0x125/0x1e0
> [  254.740943] RSP: 0000:ffff880477a6fc58  EFLAGS: 00010246
> [  254.740954] RAX: 0000000000000036 RBX: ffffea00111c31c0 RCX: 0000000000000036
> [  254.740968] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffff88048f24e120
> [  254.740981] RBP: ffff880477a6fc88 R08: 0000000000000000 R09: 0000000000000000
> [  254.740995] R10: 00000000006e2016 R11: 0000000000000001 R12: 00000000001b8805
> [  254.741009] R13: ffff880477a6fd08 R14: 00000000024200d2 R15: ffff880475fcdb00
> [  254.741026] FS:  00007f630133da00(0000) GS:ffff88048f240000(0000) knlGS:0000000000000000
> [  254.741045] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  254.741059] CR2: 00007f62f9209000 CR3: 00000000357ff000 CR4: 00000000001406e0
> [  254.741073] Stack:
> [  254.741078]  0000000000000000 ffff88044d844578 00000000001b8805 0000000000011000
> [  254.741100]  ffffea00111c31c0 00000000fffffffe ffff880477a6fd40 ffffffff811a07de
> [  254.741121]  00000000006e2016 ffff88047907e800 ffff880477a6fde0 ffff88047907e800
> [  254.741145] Call Trace:
> [  254.741155]  [<ffffffff811a07de>] shmem_getpage_gfp+0x6fe/0x810
> [  254.741168]  [<ffffffff811a0e9f>] shmem_fault+0x5f/0x1c0
> [  254.741180]  [<ffffffff811c1351>] ? page_add_file_rmap+0x51/0x60
> [  254.741194]  [<ffffffff811b275f>] __do_fault+0x3f/0xd0
> [  254.741205]  [<ffffffff811b64e7>] handle_mm_fault+0x4f7/0x17c0
> [  254.741218]  [<ffffffff810f95e0>] ? enqueue_hrtimer+0x40/0x70
> [  254.741232]  [<ffffffff81060578>] __do_page_fault+0x188/0x3e0
> [  254.741245]  [<ffffffff8112d1ed>] ? __audit_syscall_exit+0x1dd/0x260
> [  254.741259]  [<ffffffff810607f2>] do_page_fault+0x22/0x30
> [  254.741272]  [<ffffffff8170b938>] page_fault+0x28/0x30
> [  254.741283] Code: 41 f6 44 24 74 01 75 a0 49 8b 54 24 18 f6 c2 03 75 50 65 48 ff 0a eb 90 ba 01 00 00 00 eb d1 48 c7 c6 e0 10 a5 81 e8 ab b2 fb ff <0f> 0b 48 c7 c6 c0 10 a5 81 48 89 df e8 9a b2 fb ff 0f 0b 4c 89 
> [  254.741409] RIP  [<ffffffff811f51a5>] mem_cgroup_try_charge+0x125/0x1e0
> [  254.741425]  RSP <ffff880477a6fc58>
> [  254.741440] ---[ end trace 9ac0c620ae24f224 ]---


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
