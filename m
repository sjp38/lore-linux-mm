Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AFD906B0031
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 00:19:51 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so11700716pab.25
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:19:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id dg5si13861631pbc.265.2014.04.16.21.19.47
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 21:19:48 -0700 (PDT)
Date: Thu, 17 Apr 2014 12:19:26 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [x86] BUG: Bad page map in process usemem  pte:310103e3c
 pmd:7b3c2a067
Message-ID: <20140417041926.GA11592@localhost>
References: <1397572876-1610-1-git-send-email-mgorman@suse.de>
 <1397572876-1610-4-git-send-email-mgorman@suse.de>
 <20140417041122.GA9183@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140417041122.GA9183@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Sorry this is found in the old mm-numa-use-high-bit-v3r2 branch.
I'll verify it in the new branch.

On Thu, Apr 17, 2014 at 12:11:22PM +0800, Fengguang Wu wrote:
> 
> Mel,
> 
> I noticed the below BUG dmesgs, they can be reproduce reasonably easily.
> 
> test case: brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand
> 
> [  380.836690] BUG: Bad page map in process usemem  pte:310103e3c pmd:7b3c2a067
> [  380.844622] addr:00007f7e9408a000 vm_flags:000000d1 anon_vma:          (null) mapping:ffff8807d5ce8ae0 index:454c75
> [  380.856396] vma->vm_ops->fault: filemap_fault+0x0/0x394
> [  380.862326] vma->vm_file->f_op->mmap: xfs_file_mmap+0x0/0x2a
> [  380.868705] CPU: 47 PID: 7372 Comm: usemem Not tainted 3.14.0-wl-03657-ge014c34 #1
> [  380.877243] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
> [  380.888916]  0000000000000000 ffff8807cd3dbc98 ffffffff819bd4c4 00007f7e9408a000
> [  380.897581]  ffff8807cd3dbce0 ffffffff811a66d7 0000000843354067 0000000310103e3c
> [  380.906096]  0000000000000000 ffff8808419cfb50 ffffea000d4747c0 0000000000000000
> [  380.914549] Call Trace:
> [  380.917340]  [<ffffffff819bd4c4>] dump_stack+0x4d/0x66
> [  380.923160]  [<ffffffff811a66d7>] print_bad_pte+0x215/0x231
> [  380.929475]  [<ffffffff811a776e>] vm_normal_page+0x43/0x77
> [  380.935679]  [<ffffffff811a7c08>] unmap_single_vma+0x466/0x7bb
> [  380.942263]  [<ffffffff811a8e3f>] unmap_vmas+0x55/0x81
> [  380.948098]  [<ffffffff811afca5>] exit_mmap+0x76/0x12c
> [  380.953952]  [<ffffffff810dba5b>] mmput+0x74/0x109
> [  380.959358]  [<ffffffff810e0351>] do_exit+0x395/0x99b
> [  380.965073]  [<ffffffff8148d1b7>] ? trace_hardirqs_off_thunk+0x3a/0x6c
> [  380.972449]  [<ffffffff810e09d1>] do_group_exit+0x44/0xac
> [  380.978522]  [<ffffffff810e0a4d>] SyS_exit_group+0x14/0x14
> [  380.984686]  [<ffffffff819cc1e9>] system_call_fastpath+0x16/0x1b
> [  380.991444] Disabling lock debugging due to kernel taint
> 
> Thanks,
> Fengguang

> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.14.0-wl-03657-ge014c34 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-18) ) #1 SMP Thu Apr 10 12:55:29 CST 2014
> [    0.000000] Command line: user=lkp job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/vmlinuz-3.14.0-wl-03657-ge014c34 kconfig=x86_64-lkp commit=e014c34aeeea53bf253a7395906f6be7894485fc initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 bm_initrd=/lkp/benchmarks/vm-scalability.cgz modules_initrd=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/modules.cgz max_uptime=2217 RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/0 ip=::::brickland2::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009dfff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000006509ffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000650a0000-0x0000000065375fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000065376000-0x0000000065a6afff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000065a6b000-0x0000000065b29fff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x0000000065b2a000-0x0000000065df7fff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000065df8000-0x0000000066df7fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000066df8000-0x000000007abcefff] usable
> [    0.000000] BIOS-e820: [mem 0x000000007abcf000-0x000000007accefff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7ebfff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x000000007b7ec000-0x000000007b7fffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.7 present.
> [    0.000000] DMI: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] No AGP bridge found
> [    0.000000] e820: last_pfn = 0x2080000 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: write-back
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-DFFFF write-protect
> [    0.000000]   E0000-FFFFF uncachable
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
> [    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
> [    0.000000]   2 base 00007C000000 mask 3FFFFC000000 uncachable
> [    0.000000]   3 base 00007FC00000 mask 3FFFFFC00000 uncachable
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000]   8 disabled
> [    0.000000]   9 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
> [    0.000000] e820: last_pfn = 0x7b800 max_arch_pfn = 0x400000000
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] Scan for SMP in [mem 0x0009d000-0x0009d3ff]
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] BRK [0x0245d000, 0x0245dfff] PGTABLE
> [    0.000000] BRK [0x0245e000, 0x0245efff] PGTABLE
> [    0.000000] BRK [0x0245f000, 0x0245ffff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
> [    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
> [    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
> [    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
> [    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x6509ffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x64ffffff] page 2M
> [    0.000000]  [mem 0x65000000-0x6509ffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x65376000-0x65a6afff]
> [    0.000000]  [mem 0x65376000-0x653fffff] page 4k
> [    0.000000]  [mem 0x65400000-0x659fffff] page 2M
> [    0.000000]  [mem 0x65a00000-0x65a6afff] page 4k
> [    0.000000] BRK [0x02460000, 0x02460fff] PGTABLE
> [    0.000000] BRK [0x02461000, 0x02461fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x65b2a000-0x65df7fff]
> [    0.000000]  [mem 0x65b2a000-0x65df7fff] page 4k
> [    0.000000] BRK [0x02462000, 0x02462fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x66df8000-0x7abcefff]
> [    0.000000]  [mem 0x66df8000-0x66dfffff] page 4k
> [    0.000000]  [mem 0x66e00000-0x7a9fffff] page 2M
> [    0.000000]  [mem 0x7aa00000-0x7abcefff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x7b7ec000-0x7b7fffff]
> [    0.000000]  [mem 0x7b7ec000-0x7b7fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
> [    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
> [    0.000000] RAMDISK: [mem 0x6d9c6000-0x7abcefff]
> [    0.000000] ACPI: RSDP 00000000000f0410 000024 (v02 INTEL )
> [    0.000000] ACPI: XSDT 000000007b7ea0e8 0000AC (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: FACP 000000007b7e7000 0000F4 (v04 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: DSDT 000000007b7b9000 022FFB (v02 INTEL  TIANO    00000003 MSFT 01000013)
> [    0.000000] ACPI: FACS 000000007ae78000 000040
> [    0.000000] ACPI: TCPA 000000007b7e9000 000064 (v02 INTEL  BRICKLAN 06222004 INTL 20121004)
> [    0.000000] ACPI: BDAT 000000007b7e8000 000030 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: HPET 000000007b7e6000 000038 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: APIC 000000007b7e5000 00085C (v03 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: MCFG 000000007b7e4000 00003C (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: MSCT 000000007b7e3000 000090 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: PCCT 000000007b7e2000 0000AC (v01 INTEL  TIANO    00000002 MSFT 01000013)
> [    0.000000] ACPI: PMCT 000000007b7e1000 000060 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: RASF 000000007b7e0000 000030 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SLIT 000000007b7df000 00003C (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SRAT 000000007b7de000 000E30 (v03 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SVOS 000000007b7dd000 000032 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: WDDT 000000007b7dc000 000040 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: SSDT 0000000065a6b000 0BEF1B (v02  INTEL SSDT  PM 00004000 INTL 20090521)
> [    0.000000] ACPI: SSDT 000000007b7b8000 00008B (v02  INTEL SpsNvs   00000002 INTL 20090521)
> [    0.000000] ACPI: SPCR 000000007b7b7000 000050 (v01                 00000000      00000000)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
> [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x18 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1a -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1c -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x36 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x38 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3a -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3c -> Node 1
> [    0.000000] SRAT: PXM 2 -> APIC 0x40 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x42 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x44 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x46 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x48 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4a -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4c -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4e -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x50 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x52 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x54 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x56 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x58 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5a -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5c -> Node 2
> [    0.000000] SRAT: PXM 3 -> APIC 0x60 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x62 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x64 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x66 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x68 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6a -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6c -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6e -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x70 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x72 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x74 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x76 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x78 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7a -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7c -> Node 3
> [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x19 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1b -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1d -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x37 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x39 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3b -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3d -> Node 1
> [    0.000000] SRAT: PXM 2 -> APIC 0x41 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x43 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x45 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x47 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x49 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4b -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4d -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4f -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x51 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x53 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x55 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x57 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x59 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5b -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5d -> Node 2
> [    0.000000] SRAT: PXM 3 -> APIC 0x61 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x63 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x65 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x67 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x69 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6b -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6d -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6f -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x71 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x73 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x75 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x77 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x79 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7b -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7d -> Node 3
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
> [    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
> [    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
> [    0.000000] NUMA: Initialized distance table, cnt=4
> [    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x87fffffff] -> [mem 0x00000000-0x87fffffff]
> [    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
> [    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
> [    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
> [    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
> [    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
> [    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
> [    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
> [    0.000000]   NODE_DATA [mem 0x207fff5000-0x207fff9fff]
> [    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe00000-ffff88087fdfffff] on node 0
> [    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe00000-ffff88107fdfffff] on node 1
> [    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe00000-ffff88187fdfffff] on node 2
> [    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f600000-ffff88207f5fffff] on node 3
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
> [    0.000000]   node   0: [mem 0x00100000-0x6509ffff]
> [    0.000000]   node   0: [mem 0x65376000-0x65a6afff]
> [    0.000000]   node   0: [mem 0x65b2a000-0x65df7fff]
> [    0.000000]   node   0: [mem 0x66df8000-0x7abcefff]
> [    0.000000]   node   0: [mem 0x7b7ec000-0x7b7fffff]
> [    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
> [    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
> [    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
> [    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
> [    0.000000] On node 0 totalpages: 8361963
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 23 pages reserved
> [    0.000000]   DMA zone: 3997 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 7714 pages used for memmap
> [    0.000000]   DMA32 zone: 493646 pages, LIFO batch:31
> [    0.000000]   Normal zone: 122880 pages used for memmap
> [    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
> [    0.000000] On node 1 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] On node 2 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] On node 3 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] ACPI: PM-Timer IO Port: 0x408
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x10] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x12] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x14] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x16] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x18] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x1a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x1c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0x20] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0x22] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0x24] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0x26] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0x28] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0x2a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0x2c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0x2e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x50] lapic_id[0x30] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x52] lapic_id[0x32] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x54] lapic_id[0x34] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x56] lapic_id[0x36] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x58] lapic_id[0x38] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5a] lapic_id[0x3a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5c] lapic_id[0x3c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x80] lapic_id[0x40] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x82] lapic_id[0x42] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x84] lapic_id[0x44] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x86] lapic_id[0x46] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x88] lapic_id[0x48] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8a] lapic_id[0x4a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8c] lapic_id[0x4c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8e] lapic_id[0x4e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x90] lapic_id[0x50] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x92] lapic_id[0x52] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x94] lapic_id[0x54] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x96] lapic_id[0x56] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x98] lapic_id[0x58] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9a] lapic_id[0x5a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9c] lapic_id[0x5c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc0] lapic_id[0x60] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc2] lapic_id[0x62] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc4] lapic_id[0x64] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc6] lapic_id[0x66] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc8] lapic_id[0x68] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xca] lapic_id[0x6a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcc] lapic_id[0x6c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xce] lapic_id[0x6e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd0] lapic_id[0x70] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd2] lapic_id[0x72] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd4] lapic_id[0x74] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd6] lapic_id[0x76] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd8] lapic_id[0x78] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xda] lapic_id[0x7a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdc] lapic_id[0x7c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x11] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x13] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x15] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x17] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x19] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x1b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x1d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0x21] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0x23] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0x25] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0x27] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0x29] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0x2b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0x2d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0x2f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x51] lapic_id[0x31] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x53] lapic_id[0x33] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x55] lapic_id[0x35] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x57] lapic_id[0x37] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x59] lapic_id[0x39] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5b] lapic_id[0x3b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5d] lapic_id[0x3d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x81] lapic_id[0x41] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x83] lapic_id[0x43] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x85] lapic_id[0x45] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x87] lapic_id[0x47] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x89] lapic_id[0x49] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8b] lapic_id[0x4b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8d] lapic_id[0x4d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8f] lapic_id[0x4f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x91] lapic_id[0x51] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x93] lapic_id[0x53] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x95] lapic_id[0x55] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x97] lapic_id[0x57] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x99] lapic_id[0x59] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9b] lapic_id[0x5b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9d] lapic_id[0x5d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc1] lapic_id[0x61] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc3] lapic_id[0x63] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc5] lapic_id[0x65] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc7] lapic_id[0x67] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc9] lapic_id[0x69] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcb] lapic_id[0x6b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcd] lapic_id[0x6d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcf] lapic_id[0x6f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd1] lapic_id[0x71] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd3] lapic_id[0x73] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd5] lapic_id[0x75] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd7] lapic_id[0x77] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd9] lapic_id[0x79] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdb] lapic_id[0x7b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdd] lapic_id[0x7d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
> [    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
> [    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec40000] gsi_base[48])
> [    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 48-71
> [    0.000000] ACPI: IOAPIC (id[0x0b] address[0xfec80000] gsi_base[72])
> [    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec80000, GSI 72-95
> [    0.000000] ACPI: IOAPIC (id[0x0c] address[0xfecc0000] gsi_base[96])
> [    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfecc0000, GSI 96-119
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
> [    0.000000] smpboot: Allowing 144 CPUs, 24 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
> [    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
> [    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec40000)
> [    0.000000] mapped IOAPIC to ffffffffff5ef000 (fec80000)
> [    0.000000] mapped IOAPIC to ffffffffff5ee000 (fecc0000)
> [    0.000000] nr_irqs_gsi: 136
> [    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x650a0000-0x65375fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x65a6b000-0x65b29fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x65df8000-0x66df7fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7abcf000-0x7accefff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7ebfff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
> [    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:144 nr_node_ids:4
> [    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192 d21312 u131072
> [    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 060 
> [    0.000000] pcpu-alloc: [0] 061 062 063 064 065 066 067 068 069 070 071 072 073 074 120 124 
> [    0.000000] pcpu-alloc: [0] 128 132 136 140 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [1] 015 016 017 018 019 020 021 022 023 024 025 026 027 028 029 075 
> [    0.000000] pcpu-alloc: [1] 076 077 078 079 080 081 082 083 084 085 086 087 088 089 121 125 
> [    0.000000] pcpu-alloc: [1] 129 133 137 141 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [2] 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 090 
> [    0.000000] pcpu-alloc: [2] 091 092 093 094 095 096 097 098 099 100 101 102 103 104 122 126 
> [    0.000000] pcpu-alloc: [2] 130 134 138 142 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [3] 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 105 
> [    0.000000] pcpu-alloc: [3] 106 107 108 109 110 111 112 113 114 115 116 117 118 119 123 127 
> [    0.000000] pcpu-alloc: [3] 131 135 139 143 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 33003890
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: user=lkp job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/vmlinuz-3.14.0-wl-03657-ge014c34 kconfig=x86_64-lkp commit=e014c34aeeea53bf253a7395906f6be7894485fc initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 bm_initrd=/lkp/benchmarks/vm-scalability.cgz modules_initrd=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/modules.cgz max_uptime=2217 RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/0 ip=::::brickland2::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
> [    0.000000] Checking aperture...
> [    0.000000] No AGP bridge found
> [    0.000000] Memory: 131695632K/134111148K available (10053K kernel code, 1241K rwdata, 4184K rodata, 1424K init, 1744K bss, 2415516K reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=144, Nodes=4
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=144.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=144
> [    0.000000] NR_IRQS:33024 nr_irqs:3464 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.14.0-wl-03657-ge014c34 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-18) ) #1 SMP Thu Apr 10 12:55:29 CST 2014
> [    0.000000] Command line: user=lkp job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/vmlinuz-3.14.0-wl-03657-ge014c34 kconfig=x86_64-lkp commit=e014c34aeeea53bf253a7395906f6be7894485fc initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 bm_initrd=/lkp/benchmarks/vm-scalability.cgz modules_initrd=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/modules.cgz max_uptime=2217 RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/0 ip=::::brickland2::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009dfff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000006509ffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000650a0000-0x0000000065375fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000065376000-0x0000000065a6afff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000065a6b000-0x0000000065b29fff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x0000000065b2a000-0x0000000065df7fff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000065df8000-0x0000000066df7fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x0000000066df8000-0x000000007abcefff] usable
> [    0.000000] BIOS-e820: [mem 0x000000007abcf000-0x000000007accefff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7ebfff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x000000007b7ec000-0x000000007b7fffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.7 present.
> [    0.000000] DMI: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] No AGP bridge found
> [    0.000000] e820: last_pfn = 0x2080000 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: write-back
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-DFFFF write-protect
> [    0.000000]   E0000-FFFFF uncachable
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
> [    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
> [    0.000000]   2 base 00007C000000 mask 3FFFFC000000 uncachable
> [    0.000000]   3 base 00007FC00000 mask 3FFFFFC00000 uncachable
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000]   8 disabled
> [    0.000000]   9 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
> [    0.000000] e820: last_pfn = 0x7b800 max_arch_pfn = 0x400000000
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] Scan for SMP in [mem 0x0009d000-0x0009d3ff]
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] BRK [0x0245d000, 0x0245dfff] PGTABLE
> [    0.000000] BRK [0x0245e000, 0x0245efff] PGTABLE
> [    0.000000] BRK [0x0245f000, 0x0245ffff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
> [    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
> [    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
> [    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
> [    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x6509ffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x64ffffff] page 2M
> [    0.000000]  [mem 0x65000000-0x6509ffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x65376000-0x65a6afff]
> [    0.000000]  [mem 0x65376000-0x653fffff] page 4k
> [    0.000000]  [mem 0x65400000-0x659fffff] page 2M
> [    0.000000]  [mem 0x65a00000-0x65a6afff] page 4k
> [    0.000000] BRK [0x02460000, 0x02460fff] PGTABLE
> [    0.000000] BRK [0x02461000, 0x02461fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x65b2a000-0x65df7fff]
> [    0.000000]  [mem 0x65b2a000-0x65df7fff] page 4k
> [    0.000000] BRK [0x02462000, 0x02462fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x66df8000-0x7abcefff]
> [    0.000000]  [mem 0x66df8000-0x66dfffff] page 4k
> [    0.000000]  [mem 0x66e00000-0x7a9fffff] page 2M
> [    0.000000]  [mem 0x7aa00000-0x7abcefff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x7b7ec000-0x7b7fffff]
> [    0.000000]  [mem 0x7b7ec000-0x7b7fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
> [    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
> [    0.000000] RAMDISK: [mem 0x6d9c6000-0x7abcefff]
> [    0.000000] ACPI: RSDP 00000000000f0410 000024 (v02 INTEL )
> [    0.000000] ACPI: XSDT 000000007b7ea0e8 0000AC (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: FACP 000000007b7e7000 0000F4 (v04 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: DSDT 000000007b7b9000 022FFB (v02 INTEL  TIANO    00000003 MSFT 01000013)
> [    0.000000] ACPI: FACS 000000007ae78000 000040
> [    0.000000] ACPI: TCPA 000000007b7e9000 000064 (v02 INTEL  BRICKLAN 06222004 INTL 20121004)
> [    0.000000] ACPI: BDAT 000000007b7e8000 000030 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: HPET 000000007b7e6000 000038 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: APIC 000000007b7e5000 00085C (v03 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: MCFG 000000007b7e4000 00003C (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: MSCT 000000007b7e3000 000090 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: PCCT 000000007b7e2000 0000AC (v01 INTEL  TIANO    00000002 MSFT 01000013)
> [    0.000000] ACPI: PMCT 000000007b7e1000 000060 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: RASF 000000007b7e0000 000030 (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SLIT 000000007b7df000 00003C (v01 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SRAT 000000007b7de000 000E30 (v03 INTEL  TIANO    00000001 MSFT 01000013)
> [    0.000000] ACPI: SVOS 000000007b7dd000 000032 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: WDDT 000000007b7dc000 000040 (v01 INTEL  TIANO    00000000 MSFT 01000013)
> [    0.000000] ACPI: SSDT 0000000065a6b000 0BEF1B (v02  INTEL SSDT  PM 00004000 INTL 20090521)
> [    0.000000] ACPI: SSDT 000000007b7b8000 00008B (v02  INTEL SpsNvs   00000002 INTL 20090521)
> [    0.000000] ACPI: SPCR 000000007b7b7000 000050 (v01                 00000000      00000000)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
> [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x18 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1a -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1c -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x36 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x38 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3a -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3c -> Node 1
> [    0.000000] SRAT: PXM 2 -> APIC 0x40 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x42 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x44 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x46 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x48 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4a -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4c -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4e -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x50 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x52 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x54 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x56 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x58 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5a -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5c -> Node 2
> [    0.000000] SRAT: PXM 3 -> APIC 0x60 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x62 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x64 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x66 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x68 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6a -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6c -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6e -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x70 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x72 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x74 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x76 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x78 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7a -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7c -> Node 3
> [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x19 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1b -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x1d -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x37 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x39 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3b -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x3d -> Node 1
> [    0.000000] SRAT: PXM 2 -> APIC 0x41 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x43 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x45 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x47 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x49 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4b -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4d -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x4f -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x51 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x53 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x55 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x57 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x59 -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5b -> Node 2
> [    0.000000] SRAT: PXM 2 -> APIC 0x5d -> Node 2
> [    0.000000] SRAT: PXM 3 -> APIC 0x61 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x63 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x65 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x67 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x69 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6b -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6d -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x6f -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x71 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x73 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x75 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x77 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x79 -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7b -> Node 3
> [    0.000000] SRAT: PXM 3 -> APIC 0x7d -> Node 3
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
> [    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
> [    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
> [    0.000000] NUMA: Initialized distance table, cnt=4
> [    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x87fffffff] -> [mem 0x00000000-0x87fffffff]
> [    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
> [    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
> [    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
> [    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
> [    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
> [    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
> [    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
> [    0.000000]   NODE_DATA [mem 0x207fff5000-0x207fff9fff]
> [    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe00000-ffff88087fdfffff] on node 0
> [    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe00000-ffff88107fdfffff] on node 1
> [    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe00000-ffff88187fdfffff] on node 2
> [    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f600000-ffff88207f5fffff] on node 3
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
> [    0.000000]   node   0: [mem 0x00100000-0x6509ffff]
> [    0.000000]   node   0: [mem 0x65376000-0x65a6afff]
> [    0.000000]   node   0: [mem 0x65b2a000-0x65df7fff]
> [    0.000000]   node   0: [mem 0x66df8000-0x7abcefff]
> [    0.000000]   node   0: [mem 0x7b7ec000-0x7b7fffff]
> [    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
> [    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
> [    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
> [    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
> [    0.000000] On node 0 totalpages: 8361963
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 23 pages reserved
> [    0.000000]   DMA zone: 3997 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 7714 pages used for memmap
> [    0.000000]   DMA32 zone: 493646 pages, LIFO batch:31
> [    0.000000]   Normal zone: 122880 pages used for memmap
> [    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
> [    0.000000] On node 1 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] On node 2 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] On node 3 totalpages: 8388608
> [    0.000000]   Normal zone: 131072 pages used for memmap
> [    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
> [    0.000000] ACPI: PM-Timer IO Port: 0x408
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x10] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x12] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x14] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x16] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x18] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x1a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x1c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0x20] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0x22] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0x24] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0x26] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0x28] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0x2a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0x2c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0x2e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x50] lapic_id[0x30] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x52] lapic_id[0x32] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x54] lapic_id[0x34] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x56] lapic_id[0x36] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x58] lapic_id[0x38] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5a] lapic_id[0x3a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5c] lapic_id[0x3c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x80] lapic_id[0x40] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x82] lapic_id[0x42] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x84] lapic_id[0x44] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x86] lapic_id[0x46] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x88] lapic_id[0x48] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8a] lapic_id[0x4a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8c] lapic_id[0x4c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8e] lapic_id[0x4e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x90] lapic_id[0x50] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x92] lapic_id[0x52] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x94] lapic_id[0x54] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x96] lapic_id[0x56] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x98] lapic_id[0x58] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9a] lapic_id[0x5a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9c] lapic_id[0x5c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc0] lapic_id[0x60] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc2] lapic_id[0x62] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc4] lapic_id[0x64] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc6] lapic_id[0x66] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc8] lapic_id[0x68] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xca] lapic_id[0x6a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcc] lapic_id[0x6c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xce] lapic_id[0x6e] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd0] lapic_id[0x70] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd2] lapic_id[0x72] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd4] lapic_id[0x74] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd6] lapic_id[0x76] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd8] lapic_id[0x78] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xda] lapic_id[0x7a] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdc] lapic_id[0x7c] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x11] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x13] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x15] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x17] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x19] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x1b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x1d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0x21] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0x23] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0x25] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0x27] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0x29] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0x2b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0x2d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0x2f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x51] lapic_id[0x31] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x53] lapic_id[0x33] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x55] lapic_id[0x35] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x57] lapic_id[0x37] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x59] lapic_id[0x39] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5b] lapic_id[0x3b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x5d] lapic_id[0x3d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x81] lapic_id[0x41] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x83] lapic_id[0x43] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x85] lapic_id[0x45] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x87] lapic_id[0x47] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x89] lapic_id[0x49] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8b] lapic_id[0x4b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8d] lapic_id[0x4d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x8f] lapic_id[0x4f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x91] lapic_id[0x51] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x93] lapic_id[0x53] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x95] lapic_id[0x55] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x97] lapic_id[0x57] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x99] lapic_id[0x59] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9b] lapic_id[0x5b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x9d] lapic_id[0x5d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc1] lapic_id[0x61] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc3] lapic_id[0x63] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc5] lapic_id[0x65] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc7] lapic_id[0x67] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xc9] lapic_id[0x69] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcb] lapic_id[0x6b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcd] lapic_id[0x6d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xcf] lapic_id[0x6f] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd1] lapic_id[0x71] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd3] lapic_id[0x73] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd5] lapic_id[0x75] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd7] lapic_id[0x77] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xd9] lapic_id[0x79] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdb] lapic_id[0x7b] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xdd] lapic_id[0x7d] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
> [    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
> [    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec40000] gsi_base[48])
> [    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 48-71
> [    0.000000] ACPI: IOAPIC (id[0x0b] address[0xfec80000] gsi_base[72])
> [    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec80000, GSI 72-95
> [    0.000000] ACPI: IOAPIC (id[0x0c] address[0xfecc0000] gsi_base[96])
> [    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfecc0000, GSI 96-119
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
> [    0.000000] smpboot: Allowing 144 CPUs, 24 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
> [    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
> [    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec40000)
> [    0.000000] mapped IOAPIC to ffffffffff5ef000 (fec80000)
> [    0.000000] mapped IOAPIC to ffffffffff5ee000 (fecc0000)
> [    0.000000] nr_irqs_gsi: 136
> [    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x650a0000-0x65375fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x65a6b000-0x65b29fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x65df8000-0x66df7fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7abcf000-0x7accefff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7ebfff]
> [    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
> [    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:144 nr_node_ids:4
> [    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192 d21312 u131072
> [    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 060 
> [    0.000000] pcpu-alloc: [0] 061 062 063 064 065 066 067 068 069 070 071 072 073 074 120 124 
> [    0.000000] pcpu-alloc: [0] 128 132 136 140 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [1] 015 016 017 018 019 020 021 022 023 024 025 026 027 028 029 075 
> [    0.000000] pcpu-alloc: [1] 076 077 078 079 080 081 082 083 084 085 086 087 088 089 121 125 
> [    0.000000] pcpu-alloc: [1] 129 133 137 141 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [2] 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 090 
> [    0.000000] pcpu-alloc: [2] 091 092 093 094 095 096 097 098 099 100 101 102 103 104 122 126 
> [    0.000000] pcpu-alloc: [2] 130 134 138 142 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] pcpu-alloc: [3] 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 105 
> [    0.000000] pcpu-alloc: [3] 106 107 108 109 110 111 112 113 114 115 116 117 118 119 123 127 
> [    0.000000] pcpu-alloc: [3] 131 135 139 143 --- --- --- --- --- --- --- --- --- --- --- --- 
> [    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 33003890
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: user=lkp job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/vmlinuz-3.14.0-wl-03657-ge014c34 kconfig=x86_64-lkp commit=e014c34aeeea53bf253a7395906f6be7894485fc initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 bm_initrd=/lkp/benchmarks/vm-scalability.cgz modules_initrd=/kernel/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/modules.cgz max_uptime=2217 RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/0 ip=::::brickland2::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
> [    0.000000] Checking aperture...
> [    0.000000] No AGP bridge found
> [    0.000000] Memory: 131695632K/134111148K available (10053K kernel code, 1241K rwdata, 4184K rodata, 1424K init, 1744K bss, 2415516K reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=144, Nodes=4
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=144.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=144
> [    0.000000] NR_IRQS:33024 nr_irqs:3464 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] allocated 536870912 bytes of page_cgroup
> [    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
> [    0.000000] Disabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.000000] tsc: Detected 2800.133 MHz processor
> [    0.000184] Calibrating delay loop (skipped), value calculated using timer frequency.. 5600.26 BogoMIPS (lpj=11200532)
> [    0.012201] pid_max: default: 147456 minimum: 1152
> [    0.017651] ACPI: Core revision 20131218
> [    0.294851] ACPI: All ACPI Tables successfully acquired
> [    0.339875] Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
> [    0.495994] Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
> [    0.568970] Mount-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.577503] Mountpoint-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.590953] Initializing cgroup subsys memory
> [    0.596010] Initializing cgroup subsys devices
> [    0.601000] Initializing cgroup subsys freezer
> [    0.605985] Initializing cgroup subsys blkio
> [    0.610756] Initializing cgroup subsys perf_event
> [    0.616046] Initializing cgroup subsys hugetlb
> [    0.621457] CPU: Physical Processor ID: 0
> [    0.625959] CPU: Processor Core ID: 0
> [    0.633370] mce: CPU supports 32 MCE banks
> [    0.638144] CPU0: Thermal LVT vector (0xfa) already installed
> [    0.644666] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
> [    0.644666] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
> [    0.644666] tlb_flushall_shift: 6
> [    0.662187] Freeing SMP alternatives memory: 40K (ffffffff8229c000 - ffffffff822a6000)
> [    0.678005] ftrace: allocating 39110 entries in 153 pages
> [    0.760033] Getting VERSION: 1060015
> [    0.764055] Getting VERSION: 1060015
> [    0.768050] Getting ID: 0
> [    0.770981] Getting ID: 0
> [    0.773914] Switched APIC routing to physical flat.
> [    0.779364] masked ExtINT on CPU#0
> [    0.785032] ENABLING IO-APIC IRQs
> [    0.788733] init IO_APIC IRQs
> [    0.792080]  apic 8 pin 0 not connected
> [    0.796376] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
> [    0.805265] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
> [    0.814152] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
> [    0.823072] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
> [    0.831925] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
> [    0.840809] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
> [    0.849692] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
> [    0.858574] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
> [    0.867457] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
> [    0.876341] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
> [    0.885433] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
> [    0.894525] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
> [    0.903619] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
> [    0.912681] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
> [    0.921773] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
> [    0.930833]  apic 8 pin 16 not connected
> [    0.935246]  apic 8 pin 17 not connected
> [    0.939630]  apic 8 pin 18 not connected
> [    0.944048]  apic 8 pin 19 not connected
> [    0.948432]  apic 8 pin 20 not connected
> [    0.952851]  apic 8 pin 21 not connected
> [    0.957234]  apic 8 pin 22 not connected
> [    0.961653]  apic 8 pin 23 not connected
> [    0.966037]  apic 9 pin 0 not connected
> [    0.970367]  apic 9 pin 1 not connected
> [    0.974661]  apic 9 pin 2 not connected
> [    0.978956]  apic 9 pin 3 not connected
> [    0.983250]  apic 9 pin 4 not connected
> [    0.987545]  apic 9 pin 5 not connected
> [    0.991837]  apic 9 pin 6 not connected
> [    0.996130]  apic 9 pin 7 not connected
> [    1.000422]  apic 9 pin 8 not connected
> [    1.004714]  apic 9 pin 9 not connected
> [    1.009006]  apic 9 pin 10 not connected
> [    1.013389]  apic 9 pin 11 not connected
> [    1.017802]  apic 9 pin 12 not connected
> [    1.022185]  apic 9 pin 13 not connected
> [    1.026598]  apic 9 pin 14 not connected
> [    1.030981]  apic 9 pin 15 not connected
> [    1.035397]  apic 9 pin 16 not connected
> [    1.039780]  apic 9 pin 17 not connected
> [    1.044193]  apic 9 pin 18 not connected
> [    1.048576]  apic 9 pin 19 not connected
> [    1.052989]  apic 9 pin 20 not connected
> [    1.057373]  apic 9 pin 21 not connected
> [    1.061791]  apic 9 pin 22 not connected
> [    1.066174]  apic 9 pin 23 not connected
> [    1.070587]  apic 10 pin 0 not connected
> [    1.074971]  apic 10 pin 1 not connected
> [    1.079390]  apic 10 pin 2 not connected
> [    1.083774]  apic 10 pin 3 not connected
> [    1.088193]  apic 10 pin 4 not connected
> [    1.092576]  apic 10 pin 5 not connected
> [    1.096994]  apic 10 pin 6 not connected
> [    1.101378]  apic 10 pin 7 not connected
> [    1.105797]  apic 10 pin 8 not connected
> [    1.110180]  apic 10 pin 9 not connected
> [    1.114598]  apic 10 pin 10 not connected
> [    1.119101]  apic 10 pin 11 not connected
> [    1.123603]  apic 10 pin 12 not connected
> [    1.128106]  apic 10 pin 13 not connected
> [    1.132611]  apic 10 pin 14 not connected
> [    1.137114]  apic 10 pin 15 not connected
> [    1.141617]  apic 10 pin 16 not connected
> [    1.146120]  apic 10 pin 17 not connected
> [    1.150624]  apic 10 pin 18 not connected
> [    1.155128]  apic 10 pin 19 not connected
> [    1.159632]  apic 10 pin 20 not connected
> [    1.164135]  apic 10 pin 21 not connected
> [    1.168615]  apic 10 pin 22 not connected
> [    1.173118]  apic 10 pin 23 not connected
> [    1.177620]  apic 11 pin 0 not connected
> [    1.182001]  apic 11 pin 1 not connected
> [    1.186385]  apic 11 pin 2 not connected
> [    1.190803]  apic 11 pin 3 not connected
> [    1.195187]  apic 11 pin 4 not connected
> [    1.199604]  apic 11 pin 5 not connected
> [    1.203988]  apic 11 pin 6 not connected
> [    1.208400]  apic 11 pin 7 not connected
> [    1.212784]  apic 11 pin 8 not connected
> [    1.217196]  apic 11 pin 9 not connected
> [    1.221579]  apic 11 pin 10 not connected
> [    1.226082]  apic 11 pin 11 not connected
> [    1.230584]  apic 11 pin 12 not connected
> [    1.235088]  apic 11 pin 13 not connected
> [    1.239590]  apic 11 pin 14 not connected
> [    1.244070]  apic 11 pin 15 not connected
> [    1.248573]  apic 11 pin 16 not connected
> [    1.253098]  apic 11 pin 17 not connected
> [    1.257602]  apic 11 pin 18 not connected
> [    1.262105]  apic 11 pin 19 not connected
> [    1.266609]  apic 11 pin 20 not connected
> [    1.271112]  apic 11 pin 21 not connected
> [    1.275615]  apic 11 pin 22 not connected
> [    1.280095]  apic 11 pin 23 not connected
> [    1.284597]  apic 12 pin 0 not connected
> [    1.289017]  apic 12 pin 1 not connected
> [    1.293400]  apic 12 pin 2 not connected
> [    1.297812]  apic 12 pin 3 not connected
> [    1.302196]  apic 12 pin 4 not connected
> [    1.306608]  apic 12 pin 5 not connected
> [    1.310992]  apic 12 pin 6 not connected
> [    1.315404]  apic 12 pin 7 not connected
> [    1.319788]  apic 12 pin 8 not connected
> [    1.324206]  apic 12 pin 9 not connected
> [    1.328590]  apic 12 pin 10 not connected
> [    1.333094]  apic 12 pin 11 not connected
> [    1.337596]  apic 12 pin 12 not connected
> [    1.342100]  apic 12 pin 13 not connected
> [    1.346605]  apic 12 pin 14 not connected
> [    1.351108]  apic 12 pin 15 not connected
> [    1.355613]  apic 12 pin 16 not connected
> [    1.360115]  apic 12 pin 17 not connected
> [    1.364594]  apic 12 pin 18 not connected
> [    1.369098]  apic 12 pin 19 not connected
> [    1.373600]  apic 12 pin 20 not connected
> [    1.378104]  apic 12 pin 21 not connected
> [    1.382608]  apic 12 pin 22 not connected
> [    1.387111]  apic 12 pin 23 not connected
> [    1.391816] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    1.438454] smpboot: CPU0: Intel(R) Xeon(R) CPU E7-4890 V2 @ 2.80GHz (fam: 06, model: 3e, stepping: 07)
> [    1.449011] TSC deadline timer enabled
> [    1.453371] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
> [    1.465005] ... version:                3
> [    1.469508] ... bit width:              48
> [    1.474099] ... generic registers:      4
> [    1.478602] ... value mask:             0000ffffffffffff
> [    1.484555] ... max period:             0000ffffffffffff
> [    1.490506] ... fixed-purpose events:   3
> [    1.495008] ... event mask:             000000070000000f
> [    1.515706] x86: Booting SMP configuration:
> [    1.520419] .... node  #0, CPUs:          #1
> [    1.547155] masked ExtINT on CPU#1
> [    1.554818] CPU1: Thermal LVT vector (0xfa) already installed
> [    1.564318]    #2
> [    1.579430] masked ExtINT on CPU#2
> [    1.587145] CPU2: Thermal LVT vector (0xfa) already installed
> [    1.596549]    #3
> [    1.611649] masked ExtINT on CPU#3
> [    1.619391] CPU3: Thermal LVT vector (0xfa) already installed
> [    1.628814]    #4
> [    1.643892] masked ExtINT on CPU#4
> [    1.651617] CPU4: Thermal LVT vector (0xfa) already installed
> [    1.661082]    #5
> [    1.676229] masked ExtINT on CPU#5
> [    1.684235] CPU5: Thermal LVT vector (0xfa) already installed
> [    1.693678]    #6
> [    1.708812] masked ExtINT on CPU#6
> [    1.716602] CPU6: Thermal LVT vector (0xfa) already installed
> [    1.726247]    #7
> [    1.741388] masked ExtINT on CPU#7
> [    1.749191] CPU7: Thermal LVT vector (0xfa) already installed
> [    1.758696]    #8
> [    1.773865] masked ExtINT on CPU#8
> [    1.781585] CPU8: Thermal LVT vector (0xfa) already installed
> [    1.791087]    #9
> [    1.806171] masked ExtINT on CPU#9
> [    1.813903] CPU9: Thermal LVT vector (0xfa) already installed
> [    1.823475]   #10
> [    1.838434] masked ExtINT on CPU#10
> [    1.846305] CPU10: Thermal LVT vector (0xfa) already installed
> [    1.855884]   #11
> [    1.870894] masked ExtINT on CPU#11
> [    1.878615] CPU11: Thermal LVT vector (0xfa) already installed
> [    1.888380]   #12
> [    1.903327] masked ExtINT on CPU#12
> [    1.911037] CPU12: Thermal LVT vector (0xfa) already installed
> [    1.920615]   #13
> [    1.935589] masked ExtINT on CPU#13
> [    1.943224] CPU13: Thermal LVT vector (0xfa) already installed
> [    1.952914]   #14
> [    1.967898] masked ExtINT on CPU#14
> [    1.975533] CPU14: Thermal LVT vector (0xfa) already installed
> [    1.985349] 
> [    1.987047] .... node  #1, CPUs:    #15
> [    2.009821] masked ExtINT on CPU#15
> [    2.017495] CPU15: Thermal LVT vector (0xfa) already installed
> [    2.123187] TSC synchronization [CPU#0 -> CPU#15]:
> [    2.128541] Measured 23632 cycles TSC warp between CPUs, turning off TSC clock.
> [    2.136714] tsc: Marking TSC unstable due to check_tsc_sync_source failed
> [    1.152008]   #16
> [    0.004000] masked ExtINT on CPU#16
> [    0.004000] CPU16: Thermal LVT vector (0xfa) already installed
> [    1.182698]   #17
> [    0.004000] masked ExtINT on CPU#17
> [    0.004000] CPU17: Thermal LVT vector (0xfa) already installed
> [    1.212112]   #18
> [    0.004000] masked ExtINT on CPU#18
> [    0.004000] CPU18: Thermal LVT vector (0xfa) already installed
> [    1.242212]   #19
> [    0.004000] masked ExtINT on CPU#19
> [    0.004000] CPU19: Thermal LVT vector (0xfa) already installed
> [    1.272086]   #20
> [    0.004000] masked ExtINT on CPU#20
> [    0.004000] CPU20: Thermal LVT vector (0xfa) already installed
> [    1.302545]   #21
> [    0.004000] masked ExtINT on CPU#21
> [    0.004000] CPU21: Thermal LVT vector (0xfa) already installed
> [    1.332205]   #22
> [    0.004000] masked ExtINT on CPU#22
> [    0.004000] CPU22: Thermal LVT vector (0xfa) already installed
> [    1.362420]   #23
> [    0.004000] masked ExtINT on CPU#23
> [    0.004000] CPU23: Thermal LVT vector (0xfa) already installed
> [    1.392179]   #24
> [    0.004000] masked ExtINT on CPU#24
> [    0.004000] CPU24: Thermal LVT vector (0xfa) already installed
> [    1.422256]   #25
> [    0.004000] masked ExtINT on CPU#25
> [    0.004000] CPU25: Thermal LVT vector (0xfa) already installed
> [    1.452000]   #26
> [    0.004000] masked ExtINT on CPU#26
> [    0.004000] CPU26: Thermal LVT vector (0xfa) already installed
> [    1.479888]   #27
> [    0.004000] masked ExtINT on CPU#27
> [    0.004000] CPU27: Thermal LVT vector (0xfa) already installed
> [    1.507873]   #28
> [    0.004000] masked ExtINT on CPU#28
> [    0.004000] CPU28: Thermal LVT vector (0xfa) already installed
> [    1.535767]   #29
> [    0.004000] masked ExtINT on CPU#29
> [    0.004000] CPU29: Thermal LVT vector (0xfa) already installed
> [    1.563847] 
> [    1.564004] .... node  #2, CPUs:    #30
> [    0.004000] masked ExtINT on CPU#30
> [    0.004000] CPU30: Thermal LVT vector (0xfa) already installed
> [    1.676763]   #31
> [    0.004000] masked ExtINT on CPU#31
> [    0.004000] CPU31: Thermal LVT vector (0xfa) already installed
> [    1.706835]   #32
> [    0.004000] masked ExtINT on CPU#32
> [    0.004000] CPU32: Thermal LVT vector (0xfa) already installed
> [    1.736052]   #33
> [    0.004000] masked ExtINT on CPU#33
> [    0.004000] CPU33: Thermal LVT vector (0xfa) already installed
> [    1.766167]   #34
> [    0.004000] masked ExtINT on CPU#34
> [    0.004000] CPU34: Thermal LVT vector (0xfa) already installed
> [    1.796130]   #35
> [    0.004000] masked ExtINT on CPU#35
> [    0.004000] CPU35: Thermal LVT vector (0xfa) already installed
> [    1.826460]   #36
> [    0.004000] masked ExtINT on CPU#36
> [    0.004000] CPU36: Thermal LVT vector (0xfa) already installed
> [    1.856221]   #37
> [    0.004000] masked ExtINT on CPU#37
> [    0.004000] CPU37: Thermal LVT vector (0xfa) already installed
> [    1.886336]   #38
> [    0.004000] masked ExtINT on CPU#38
> [    0.004000] CPU38: Thermal LVT vector (0xfa) already installed
> [    1.916125]   #39
> [    0.004000] masked ExtINT on CPU#39
> [    0.004000] CPU39: Thermal LVT vector (0xfa) already installed
> [    1.946211]   #40
> [    0.004000] masked ExtINT on CPU#40
> [    0.004000] CPU40: Thermal LVT vector (0xfa) already installed
> [    1.975966]   #41
> [    0.004000] masked ExtINT on CPU#41
> [    0.004000] CPU41: Thermal LVT vector (0xfa) already installed
> [    2.003956]   #42
> [    0.004000] masked ExtINT on CPU#42
> [    0.004000] CPU42: Thermal LVT vector (0xfa) already installed
> [    2.031846]   #43
> [    0.004000] masked ExtINT on CPU#43
> [    0.004000] CPU43: Thermal LVT vector (0xfa) already installed
> [    2.059748]   #44
> [    0.004000] masked ExtINT on CPU#44
> [    0.004000] CPU44: Thermal LVT vector (0xfa) already installed
> [    2.087964] 
> [    2.088003] .... node  #3, CPUs:    #45
> [    0.004000] masked ExtINT on CPU#45
> [    0.004000] CPU45: Thermal LVT vector (0xfa) already installed
> [    2.204676]   #46
> [    0.004000] masked ExtINT on CPU#46
> [    0.004000] CPU46: Thermal LVT vector (0xfa) already installed
> [    2.234637]   #47
> [    0.004000] masked ExtINT on CPU#47
> [    0.004000] CPU47: Thermal LVT vector (0xfa) already installed
> [    2.264164]   #48
> [    0.004000] masked ExtINT on CPU#48
> [    0.004000] CPU48: Thermal LVT vector (0xfa) already installed
> [    2.294198]   #49
> [    0.004000] masked ExtINT on CPU#49
> [    0.004000] CPU49: Thermal LVT vector (0xfa) already installed
> [    2.324067]   #50
> [    0.004000] masked ExtINT on CPU#50
> [    0.004000] CPU50: Thermal LVT vector (0xfa) already installed
> [    2.354499]   #51
> [    0.004000] masked ExtINT on CPU#51
> [    0.004000] CPU51: Thermal LVT vector (0xfa) already installed
> [    2.384202]   #52
> [    0.004000] masked ExtINT on CPU#52
> [    0.004000] CPU52: Thermal LVT vector (0xfa) already installed
> [    2.414292]   #53
> [    0.004000] masked ExtINT on CPU#53
> [    0.004000] CPU53: Thermal LVT vector (0xfa) already installed
> [    2.444059]   #54
> [    0.004000] masked ExtINT on CPU#54
> [    0.004000] CPU54: Thermal LVT vector (0xfa) already installed
> [    2.474208]   #55
> [    0.004000] masked ExtINT on CPU#55
> [    0.004000] CPU55: Thermal LVT vector (0xfa) already installed
> [    2.504042]   #56
> [    0.004000] masked ExtINT on CPU#56
> [    0.004000] CPU56: Thermal LVT vector (0xfa) already installed
> [    2.533866]   #57
> [    0.004000] masked ExtINT on CPU#57
> [    0.004000] CPU57: Thermal LVT vector (0xfa) already installed
> [    2.563736]   #58
> [    0.004000] masked ExtINT on CPU#58
> [    0.004000] CPU58: Thermal LVT vector (0xfa) already installed
> [    2.591842]   #59
> [    0.004000] masked ExtINT on CPU#59
> [    0.004000] CPU59: Thermal LVT vector (0xfa) already installed
> [    2.619784] 
> [    2.620003] .... node  #0, CPUs:    #60
> [    0.004000] masked ExtINT on CPU#60
> [    0.004000] CPU60: Thermal LVT vector (0xfa) already installed
> [    2.651962]   #61
> [    0.004000] masked ExtINT on CPU#61
> [    0.004000] CPU61: Thermal LVT vector (0xfa) already installed
> [    2.680333]   #62
> [    0.004000] masked ExtINT on CPU#62
> [    0.004000] CPU62: Thermal LVT vector (0xfa) already installed
> [    2.710750]   #63
> [    0.004000] masked ExtINT on CPU#63
> [    0.004000] CPU63: Thermal LVT vector (0xfa) already installed
> [    2.740430]   #64
> [    0.004000] masked ExtINT on CPU#64
> [    0.004000] CPU64: Thermal LVT vector (0xfa) already installed
> [    2.770904]   #65
> [    0.004000] masked ExtINT on CPU#65
> [    0.004000] CPU65: Thermal LVT vector (0xfa) already installed
> [    2.800809]   #66
> [    0.004000] masked ExtINT on CPU#66
> [    0.004000] CPU66: Thermal LVT vector (0xfa) already installed
> [    2.831387]   #67
> [    0.004000] masked ExtINT on CPU#67
> [    0.004000] CPU67: Thermal LVT vector (0xfa) already installed
> [    2.860542]   #68
> [    0.004000] masked ExtINT on CPU#68
> [    0.004000] CPU68: Thermal LVT vector (0xfa) already installed
> [    2.891042]   #69
> [    0.004000] masked ExtINT on CPU#69
> [    0.004000] CPU69: Thermal LVT vector (0xfa) already installed
> [    2.920503]   #70
> [    0.004000] masked ExtINT on CPU#70
> [    0.004000] CPU70: Thermal LVT vector (0xfa) already installed
> [    2.950882]   #71
> [    0.004000] masked ExtINT on CPU#71
> [    0.004000] CPU71: Thermal LVT vector (0xfa) already installed
> [    2.980318]   #72
> [    0.004000] masked ExtINT on CPU#72
> [    0.004000] CPU72: Thermal LVT vector (0xfa) already installed
> [    3.010464]   #73
> [    0.004000] masked ExtINT on CPU#73
> [    0.004000] CPU73: Thermal LVT vector (0xfa) already installed
> [    3.040259]   #74
> [    0.004000] masked ExtINT on CPU#74
> [    0.004000] CPU74: Thermal LVT vector (0xfa) already installed
> [    3.070532] 
> [    3.072003] .... node  #1, CPUs:    #75
> [    0.004000] masked ExtINT on CPU#75
> [    0.004000] CPU75: Thermal LVT vector (0xfa) already installed
> [    3.103997]   #76
> [    0.004000] masked ExtINT on CPU#76
> [    0.004000] CPU76: Thermal LVT vector (0xfa) already installed
> [    3.132203]   #77
> [    0.004000] masked ExtINT on CPU#77
> [    0.004000] CPU77: Thermal LVT vector (0xfa) already installed
> [    3.162292]   #78
> [    0.004000] masked ExtINT on CPU#78
> [    0.004000] CPU78: Thermal LVT vector (0xfa) already installed
> [    3.192153]   #79
> [    0.004000] masked ExtINT on CPU#79
> [    0.004000] CPU79: Thermal LVT vector (0xfa) already installed
> [    3.222245]   #80
> [    0.004000] masked ExtINT on CPU#80
> [    0.004000] CPU80: Thermal LVT vector (0xfa) already installed
> [    3.252529]   #81
> [    0.004000] masked ExtINT on CPU#81
> [    0.004000] CPU81: Thermal LVT vector (0xfa) already installed
> [    3.282709]   #82
> [    0.004000] masked ExtINT on CPU#82
> [    0.004000] CPU82: Thermal LVT vector (0xfa) already installed
> [    3.312210]   #83
> [    0.004000] masked ExtINT on CPU#83
> [    0.004000] CPU83: Thermal LVT vector (0xfa) already installed
> [    3.342287]   #84
> [    0.004000] masked ExtINT on CPU#84
> [    0.004000] CPU84: Thermal LVT vector (0xfa) already installed
> [    3.372200]   #85
> [    0.004000] masked ExtINT on CPU#85
> [    0.004000] CPU85: Thermal LVT vector (0xfa) already installed
> [    3.402129]   #86
> [    0.004000] masked ExtINT on CPU#86
> [    0.004000] CPU86: Thermal LVT vector (0xfa) already installed
> [    3.432027]   #87
> [    0.004000] masked ExtINT on CPU#87
> [    0.004000] CPU87: Thermal LVT vector (0xfa) already installed
> [    3.461852]   #88
> [    0.004000] masked ExtINT on CPU#88
> [    0.004000] CPU88: Thermal LVT vector (0xfa) already installed
> [    3.491620]   #89
> [    0.004000] masked ExtINT on CPU#89
> [    0.004000] CPU89: Thermal LVT vector (0xfa) already installed
> [    3.519844] 
> [    3.520003] .... node  #2, CPUs:    #90
> [    0.004000] masked ExtINT on CPU#90
> [    0.004000] CPU90: Thermal LVT vector (0xfa) already installed
> [    3.552040]   #91
> [    0.004000] masked ExtINT on CPU#91
> [    0.004000] CPU91: Thermal LVT vector (0xfa) already installed
> [    3.581972]   #92
> [    0.004000] masked ExtINT on CPU#92
> [    0.004000] CPU92: Thermal LVT vector (0xfa) already installed
> [    3.612125]   #93
> [    0.004000] masked ExtINT on CPU#93
> [    0.004000] CPU93: Thermal LVT vector (0xfa) already installed
> [    3.642168]   #94
> [    0.004000] masked ExtINT on CPU#94
> [    0.004000] CPU94: Thermal LVT vector (0xfa) already installed
> [    3.672197]   #95
> [    0.004000] masked ExtINT on CPU#95
> [    0.004000] CPU95: Thermal LVT vector (0xfa) already installed
> [    3.702630]   #96
> [    0.004000] masked ExtINT on CPU#96
> [    0.004000] CPU96: Thermal LVT vector (0xfa) already installed
> [    3.732204]   #97
> [    0.004000] masked ExtINT on CPU#97
> [    0.004000] CPU97: Thermal LVT vector (0xfa) already installed
> [    3.762377]   #98
> [    0.004000] masked ExtINT on CPU#98
> [    0.004000] CPU98: Thermal LVT vector (0xfa) already installed
> [    3.792131]   #99
> [    0.004000] masked ExtINT on CPU#99
> [    0.004000] CPU99: Thermal LVT vector (0xfa) already installed
> [    3.822205]  #100
> [    0.004000] masked ExtINT on CPU#100
> [    0.004000] CPU100: Thermal LVT vector (0xfa) already installed
> [    3.852283]  #101
> [    0.004000] masked ExtINT on CPU#101
> [    0.004000] CPU101: Thermal LVT vector (0xfa) already installed
> [    3.882301]  #102
> [    0.004000] masked ExtINT on CPU#102
> [    0.004000] CPU102: Thermal LVT vector (0xfa) already installed
> [    3.912114]  #103
> [    0.004000] masked ExtINT on CPU#103
> [    0.004000] CPU103: Thermal LVT vector (0xfa) already installed
> [    3.942119]  #104
> [    0.004000] masked ExtINT on CPU#104
> [    0.004000] CPU104: Thermal LVT vector (0xfa) already installed
> [    3.972033] 
> [    3.973699] .... node  #3, CPUs:   #105
> [    0.004000] masked ExtINT on CPU#105
> [    0.004000] CPU105: Thermal LVT vector (0xfa) already installed
> [    4.004747]  #106
> [    0.004000] masked ExtINT on CPU#106
> [    0.004000] CPU106: Thermal LVT vector (0xfa) already installed
> [    4.035033]  #107
> [    0.004000] masked ExtINT on CPU#107
> [    0.004000] CPU107: Thermal LVT vector (0xfa) already installed
> [    4.064248]  #108
> [    0.004000] masked ExtINT on CPU#108
> [    0.004000] CPU108: Thermal LVT vector (0xfa) already installed
> [    4.094579]  #109
> [    0.004000] masked ExtINT on CPU#109
> [    0.004000] CPU109: Thermal LVT vector (0xfa) already installed
> [    4.124256]  #110
> [    0.004000] masked ExtINT on CPU#110
> [    0.004000] CPU110: Thermal LVT vector (0xfa) already installed
> [    4.154950]  #111
> [    0.004000] masked ExtINT on CPU#111
> [    0.004000] CPU111: Thermal LVT vector (0xfa) already installed
> [    4.184455]  #112
> [    0.004000] masked ExtINT on CPU#112
> [    0.004000] CPU112: Thermal LVT vector (0xfa) already installed
> [    4.214758]  #113
> [    0.004000] masked ExtINT on CPU#113
> [    0.004000] CPU113: Thermal LVT vector (0xfa) already installed
> [    4.244408]  #114
> [    0.004000] masked ExtINT on CPU#114
> [    0.004000] CPU114: Thermal LVT vector (0xfa) already installed
> [    4.274748]  #115
> [    0.004000] masked ExtINT on CPU#115
> [    0.004000] CPU115: Thermal LVT vector (0xfa) already installed
> [    4.304255]  #116
> [    0.004000] masked ExtINT on CPU#116
> [    0.004000] CPU116: Thermal LVT vector (0xfa) already installed
> [    4.334414]  #117
> [    0.004000] masked ExtINT on CPU#117
> [    0.004000] CPU117: Thermal LVT vector (0xfa) already installed
> [    4.364080]  #118
> [    0.004000] masked ExtINT on CPU#118
> [    0.004000] CPU118: Thermal LVT vector (0xfa) already installed
> [    4.394090]  #119
> [    0.004000] masked ExtINT on CPU#119
> [    0.004000] CPU119: Thermal LVT vector (0xfa) already installed
> [    4.423703] x86: Booted up 4 nodes, 120 CPUs
> [    4.424030] smpboot: Total of 120 processors activated (674281.26 BogoMIPS)
> [    4.445643] devtmpfs: initialized
> [    4.528501] PM: Registering ACPI NVS region [mem 0x650a0000-0x65375fff] (2973696 bytes)
> [    4.532266] PM: Registering ACPI NVS region [mem 0x65df8000-0x66df7fff] (16777216 bytes)
> [    4.537235] PM: Registering ACPI NVS region [mem 0x7accf000-0x7b6fefff] (10682368 bytes)
> [    4.549953] xor: automatically using best checksumming function:
> [    4.592004]    avx       :  4053.000 MB/sec
> [    4.596129] atomic64 test passed for x86-64 platform with CX8 and with SSE
> [    4.600724] NET: Registered protocol family 16
> [    4.608054] cpuidle: using governor ladder
> [    4.612008] cpuidle: using governor menu
> [    4.618595] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
> [    4.620004] ACPI: bus type PCI registered
> [    4.624004] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    4.628132] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
> [    4.632007] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
> [    4.714256] PCI: Using configuration type 1 for base access
> [    4.801432] bio: create slab <bio-0> at 0
> [    4.872049] raid6: sse2x1    1187 MB/s
> [    4.944032] raid6: sse2x2    1532 MB/s
> [    5.016008] raid6: sse2x4    2039 MB/s
> [    5.020003] raid6: using algorithm sse2x4 (2039 MB/s)
> [    5.024003] raid6: using ssse3x2 recovery algorithm
> [    5.029935] ACPI: Added _OSI(Module Device)
> [    5.032009] ACPI: Added _OSI(Processor Device)
> [    5.036003] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    5.040004] ACPI: Added _OSI(Processor Aggregator Device)
> [    5.583687] ACPI Error: Field [CPB3] at 96 exceeds Buffer [NULL] size 64 (bits) (20131218/dsopcode-236)
> [    5.590587] ACPI Error: Method parse/execution failed [\_SB_._OSC] (Node ffff88105f403c80), AE_AML_BUFFER_LIMIT (20131218/psparse-536)
> [    5.738714] ACPI: Interpreter enabled
> [    5.740066] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20131218/hwxface-580)
> [    5.748005] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20131218/hwxface-580)
> [    5.756037] ACPI: (supports S0 S1 S4 S5)
> [    5.760003] ACPI: Using IOAPIC for interrupt routing
> [    5.764164] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    5.781684] ACPI: No dock devices found.
> [    6.028435] ACPI: PCI Root Bridge [UNC3] (domain 0000 [bus ff])
> [    6.036036] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    6.044011] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    6.052174] PCI host bridge to bus 0000:ff
> [    6.056008] pci_bus 0000:ff: root bus resource [bus ff]
> [    6.064050] pci 0000:ff:08.0: [8086:0e80] type 00 class 0x088000
> [    6.072289] pci 0000:ff:08.2: [8086:0e32] type 00 class 0x110100
> [    6.080016] pci 0000:ff:08.3: [8086:0e83] type 00 class 0x088000
> [    6.084287] pci 0000:ff:08.4: [8086:0e84] type 00 class 0x088000
> [    6.092257] pci 0000:ff:09.0: [8086:0e90] type 00 class 0x088000
> [    6.100253] pci 0000:ff:09.2: [8086:0e33] type 00 class 0x110100
> [    6.108114] pci 0000:ff:09.3: [8086:0e93] type 00 class 0x088000
> [    6.112334] pci 0000:ff:09.4: [8086:0e94] type 00 class 0x088000
> [    6.120286] pci 0000:ff:0a.0: [8086:0ec0] type 00 class 0x088000
> [    6.128225] pci 0000:ff:0a.1: [8086:0ec1] type 00 class 0x088000
> [    6.136210] pci 0000:ff:0a.2: [8086:0ec2] type 00 class 0x088000
> [    6.140221] pci 0000:ff:0a.3: [8086:0ec3] type 00 class 0x088000
> [    6.148210] pci 0000:ff:0b.0: [8086:0e1e] type 00 class 0x088000
> [    6.156254] pci 0000:ff:0b.3: [8086:0e1f] type 00 class 0x088000
> [    6.164208] pci 0000:ff:0c.0: [8086:0ee0] type 00 class 0x088000
> [    6.168245] pci 0000:ff:0c.1: [8086:0ee2] type 00 class 0x088000
> [    6.176214] pci 0000:ff:0c.2: [8086:0ee4] type 00 class 0x088000
> [    6.184220] pci 0000:ff:0c.3: [8086:0ee6] type 00 class 0x088000
> [    6.192217] pci 0000:ff:0c.4: [8086:0ee8] type 00 class 0x088000
> [    6.200112] pci 0000:ff:0c.5: [8086:0eea] type 00 class 0x088000
> [    6.204253] pci 0000:ff:0c.6: [8086:0eec] type 00 class 0x088000
> [    6.212289] pci 0000:ff:0c.7: [8086:0eee] type 00 class 0x088000
> [    6.220211] pci 0000:ff:0d.0: [8086:0ee1] type 00 class 0x088000
> [    6.228215] pci 0000:ff:0d.1: [8086:0ee3] type 00 class 0x088000
> [    6.232216] pci 0000:ff:0d.2: [8086:0ee5] type 00 class 0x088000
> [    6.240208] pci 0000:ff:0d.3: [8086:0ee7] type 00 class 0x088000
> [    6.248224] pci 0000:ff:0d.4: [8086:0ee9] type 00 class 0x088000
> [    6.256223] pci 0000:ff:0d.5: [8086:0eeb] type 00 class 0x088000
> [    6.260221] pci 0000:ff:0d.6: [8086:0eed] type 00 class 0x088000
> [    6.268207] pci 0000:ff:0e.0: [8086:0ea0] type 00 class 0x088000
> [    6.276246] pci 0000:ff:0e.1: [8086:0e30] type 00 class 0x110100
> [    6.284213] pci 0000:ff:0f.0: [8086:0ea8] type 00 class 0x088000
> [    6.292047] pci 0000:ff:0f.1: [8086:0e71] type 00 class 0x088000
> [    6.296305] pci 0000:ff:0f.2: [8086:0eaa] type 00 class 0x088000
> [    6.304333] pci 0000:ff:0f.3: [8086:0eab] type 00 class 0x088000
> [    6.312256] pci 0000:ff:0f.4: [8086:0eac] type 00 class 0x088000
> [    6.320264] pci 0000:ff:0f.5: [8086:0ead] type 00 class 0x088000
> [    6.324256] pci 0000:ff:10.0: [8086:0eb0] type 00 class 0x088000
> [    6.332262] pci 0000:ff:10.1: [8086:0eb1] type 00 class 0x088000
> [    6.340252] pci 0000:ff:10.2: [8086:0eb2] type 00 class 0x088000
> [    6.348292] pci 0000:ff:10.3: [8086:0eb3] type 00 class 0x088000
> [    6.356039] pci 0000:ff:10.4: [8086:0eb4] type 00 class 0x088000
> [    6.360290] pci 0000:ff:10.5: [8086:0eb5] type 00 class 0x088000
> [    6.368254] pci 0000:ff:10.6: [8086:0eb6] type 00 class 0x088000
> [    6.376267] pci 0000:ff:10.7: [8086:0eb7] type 00 class 0x088000
> [    6.384257] pci 0000:ff:11.0: [8086:0ef8] type 00 class 0x088000
> [    6.388263] pci 0000:ff:13.0: [8086:0e1d] type 00 class 0x088000
> [    6.396209] pci 0000:ff:13.1: [8086:0e34] type 00 class 0x110100
> [    6.404246] pci 0000:ff:13.4: [8086:0e81] type 00 class 0x088000
> [    6.412208] pci 0000:ff:13.5: [8086:0e36] type 00 class 0x110100
> [    6.420013] pci 0000:ff:13.6: [8086:0e37] type 00 class 0x110100
> [    6.424210] pci 0000:ff:16.0: [8086:0ec8] type 00 class 0x088000
> [    6.432221] pci 0000:ff:16.1: [8086:0ec9] type 00 class 0x088000
> [    6.440212] pci 0000:ff:16.2: [8086:0eca] type 00 class 0x088000
> [    6.448090] pci 0000:ff:18.0: [8086:0e40] type 00 class 0x088000
> [    6.452257] pci 0000:ff:18.2: [8086:0e3a] type 00 class 0x110100
> [    6.460252] pci 0000:ff:18.3: [8086:0e43] type 00 class 0x088000
> [    6.468252] pci 0000:ff:18.4: [8086:0e44] type 00 class 0x088000
> [    6.476258] pci 0000:ff:1c.0: [8086:0e60] type 00 class 0x088000
> [    6.480251] pci 0000:ff:1c.1: [8086:0e38] type 00 class 0x110100
> [    6.488219] pci 0000:ff:1d.0: [8086:0e68] type 00 class 0x088000
> [    6.496294] pci 0000:ff:1d.1: [8086:0e79] type 00 class 0x088000
> [    6.504255] pci 0000:ff:1d.2: [8086:0e6a] type 00 class 0x088000
> [    6.512057] pci 0000:ff:1d.3: [8086:0e6b] type 00 class 0x088000
> [    6.516306] pci 0000:ff:1d.4: [8086:0e6c] type 00 class 0x088000
> [    6.524331] pci 0000:ff:1d.5: [8086:0e6d] type 00 class 0x088000
> [    6.532257] pci 0000:ff:1e.0: [8086:0ef0] type 00 class 0x088000
> [    6.540291] pci 0000:ff:1e.1: [8086:0ef1] type 00 class 0x088000
> [    6.544257] pci 0000:ff:1e.2: [8086:0ef2] type 00 class 0x088000
> [    6.552303] pci 0000:ff:1e.3: [8086:0ef3] type 00 class 0x088000
> [    6.560255] pci 0000:ff:1e.4: [8086:0ef4] type 00 class 0x088000
> [    6.568288] pci 0000:ff:1e.5: [8086:0ef5] type 00 class 0x088000
> [    6.576090] pci 0000:ff:1e.6: [8086:0ef6] type 00 class 0x088000
> [    6.580336] pci 0000:ff:1e.7: [8086:0ef7] type 00 class 0x088000
> [    6.588296] pci 0000:ff:1f.0: [8086:0ed8] type 00 class 0x088000
> [    6.596303] pci 0000:ff:1f.1: [8086:0ed9] type 00 class 0x088000
> [    6.604257] pci 0000:ff:1f.4: [8086:0edc] type 00 class 0x088000
> [    6.608267] pci 0000:ff:1f.5: [8086:0edd] type 00 class 0x088000
> [    6.616255] pci 0000:ff:1f.6: [8086:0ede] type 00 class 0x088000
> [    6.624263] pci 0000:ff:1f.7: [8086:0edf] type 00 class 0x088000
> [    6.632261] ACPI: PCI Root Bridge [UNC2] (domain 0000 [bus bf])
> [    6.636011] acpi PNP0A03:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    6.648011] acpi PNP0A03:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    6.656199] PCI host bridge to bus 0000:bf
> [    6.660007] pci_bus 0000:bf: root bus resource [bus bf]
> [    6.664042] pci 0000:bf:08.0: [8086:0e80] type 00 class 0x088000
> [    6.672213] pci 0000:bf:08.2: [8086:0e32] type 00 class 0x110100
> [    6.680249] pci 0000:bf:08.3: [8086:0e83] type 00 class 0x088000
> [    6.688081] pci 0000:bf:08.4: [8086:0e84] type 00 class 0x088000
> [    6.692337] pci 0000:bf:09.0: [8086:0e90] type 00 class 0x088000
> [    6.700256] pci 0000:bf:09.2: [8086:0e33] type 00 class 0x110100
> [    6.708256] pci 0000:bf:09.3: [8086:0e93] type 00 class 0x088000
> [    6.716275] pci 0000:bf:09.4: [8086:0e94] type 00 class 0x088000
> [    6.720294] pci 0000:bf:0a.0: [8086:0ec0] type 00 class 0x088000
> [    6.728213] pci 0000:bf:0a.1: [8086:0ec1] type 00 class 0x088000
> [    6.736215] pci 0000:bf:0a.2: [8086:0ec2] type 00 class 0x088000
> [    6.744208] pci 0000:bf:0a.3: [8086:0ec3] type 00 class 0x088000
> [    6.748210] pci 0000:bf:0b.0: [8086:0e1e] type 00 class 0x088000
> [    6.756250] pci 0000:bf:0b.3: [8086:0e1f] type 00 class 0x088000
> [    6.764207] pci 0000:bf:0c.0: [8086:0ee0] type 00 class 0x088000
> [    6.772220] pci 0000:bf:0c.1: [8086:0ee2] type 00 class 0x088000
> [    6.780088] pci 0000:bf:0c.2: [8086:0ee4] type 00 class 0x088000
> [    6.784262] pci 0000:bf:0c.3: [8086:0ee6] type 00 class 0x088000
> [    6.792256] pci 0000:bf:0c.4: [8086:0ee8] type 00 class 0x088000
> [    6.800249] pci 0000:bf:0c.5: [8086:0eea] type 00 class 0x088000
> [    6.808212] pci 0000:bf:0c.6: [8086:0eec] type 00 class 0x088000
> [    6.812215] pci 0000:bf:0c.7: [8086:0eee] type 00 class 0x088000
> [    6.820212] pci 0000:bf:0d.0: [8086:0ee1] type 00 class 0x088000
> [    6.828223] pci 0000:bf:0d.1: [8086:0ee3] type 00 class 0x088000
> [    6.836219] pci 0000:bf:0d.2: [8086:0ee5] type 00 class 0x088000
> [    6.840223] pci 0000:bf:0d.3: [8086:0ee7] type 00 class 0x088000
> [    6.848210] pci 0000:bf:0d.4: [8086:0ee9] type 00 class 0x088000
> [    6.856221] pci 0000:bf:0d.5: [8086:0eeb] type 00 class 0x088000
> [    6.864211] pci 0000:bf:0d.6: [8086:0eed] type 00 class 0x088000
> [    6.868252] pci 0000:bf:0e.0: [8086:0ea0] type 00 class 0x088000
> [    6.876244] pci 0000:bf:0e.1: [8086:0e30] type 00 class 0x110100
> [    6.884257] pci 0000:bf:0f.0: [8086:0ea8] type 00 class 0x088000
> [    6.892260] pci 0000:bf:0f.1: [8086:0e71] type 00 class 0x088000
> [    6.900099] pci 0000:bf:0f.2: [8086:0eaa] type 00 class 0x088000
> [    6.904296] pci 0000:bf:0f.3: [8086:0eab] type 00 class 0x088000
> [    6.912287] pci 0000:bf:0f.4: [8086:0eac] type 00 class 0x088000
> [    6.920257] pci 0000:bf:0f.5: [8086:0ead] type 00 class 0x088000
> [    6.928268] pci 0000:bf:10.0: [8086:0eb0] type 00 class 0x088000
> [    6.932257] pci 0000:bf:10.1: [8086:0eb1] type 00 class 0x088000
> [    6.940263] pci 0000:bf:10.2: [8086:0eb2] type 00 class 0x088000
> [    6.948262] pci 0000:bf:10.3: [8086:0eb3] type 00 class 0x088000
> [    6.956259] pci 0000:bf:10.4: [8086:0eb4] type 00 class 0x088000
> [    6.964057] pci 0000:bf:10.5: [8086:0eb5] type 00 class 0x088000
> [    6.968336] pci 0000:bf:10.6: [8086:0eb6] type 00 class 0x088000
> [    6.976298] pci 0000:bf:10.7: [8086:0eb7] type 00 class 0x088000
> [    6.984332] pci 0000:bf:11.0: [8086:0ef8] type 00 class 0x088000
> [    6.992298] pci 0000:bf:13.0: [8086:0e1d] type 00 class 0x088000
> [    6.996209] pci 0000:bf:13.1: [8086:0e34] type 00 class 0x110100
> [    7.004252] pci 0000:bf:13.4: [8086:0e81] type 00 class 0x088000
> [    7.012211] pci 0000:bf:13.5: [8086:0e36] type 00 class 0x110100
> [    7.020248] pci 0000:bf:13.6: [8086:0e37] type 00 class 0x110100
> [    7.024209] pci 0000:bf:16.0: [8086:0ec8] type 00 class 0x088000
> [    7.032252] pci 0000:bf:16.1: [8086:0ec9] type 00 class 0x088000
> [    7.040210] pci 0000:bf:16.2: [8086:0eca] type 00 class 0x088000
> [    7.048247] pci 0000:bf:18.0: [8086:0e40] type 00 class 0x088000
> [    7.056089] pci 0000:bf:18.2: [8086:0e3a] type 00 class 0x110100
> [    7.060300] pci 0000:bf:18.3: [8086:0e43] type 00 class 0x088000
> [    7.068337] pci 0000:bf:18.4: [8086:0e44] type 00 class 0x088000
> [    7.076295] pci 0000:bf:1c.0: [8086:0e60] type 00 class 0x088000
> [    7.084217] pci 0000:bf:1c.1: [8086:0e38] type 00 class 0x110100
> [    7.088257] pci 0000:bf:1d.0: [8086:0e68] type 00 class 0x088000
> [    7.096256] pci 0000:bf:1d.1: [8086:0e79] type 00 class 0x088000
> [    7.104292] pci 0000:bf:1d.2: [8086:0e6a] type 00 class 0x088000
> [    7.112256] pci 0000:bf:1d.3: [8086:0e6b] type 00 class 0x088000
> [    7.120085] pci 0000:bf:1d.4: [8086:0e6c] type 00 class 0x088000
> [    7.124329] pci 0000:bf:1d.5: [8086:0e6d] type 00 class 0x088000
> [    7.132334] pci 0000:bf:1e.0: [8086:0ef0] type 00 class 0x088000
> [    7.140297] pci 0000:bf:1e.1: [8086:0ef1] type 00 class 0x088000
> [    7.148293] pci 0000:bf:1e.2: [8086:0ef2] type 00 class 0x088000
> [    7.152258] pci 0000:bf:1e.3: [8086:0ef3] type 00 class 0x088000
> [    7.160291] pci 0000:bf:1e.4: [8086:0ef4] type 00 class 0x088000
> [    7.168293] pci 0000:bf:1e.5: [8086:0ef5] type 00 class 0x088000
> [    7.176304] pci 0000:bf:1e.6: [8086:0ef6] type 00 class 0x088000
> [    7.184090] pci 0000:bf:1e.7: [8086:0ef7] type 00 class 0x088000
> [    7.188333] pci 0000:bf:1f.0: [8086:0ed8] type 00 class 0x088000
> [    7.196305] pci 0000:bf:1f.1: [8086:0ed9] type 00 class 0x088000
> [    7.204335] pci 0000:bf:1f.4: [8086:0edc] type 00 class 0x088000
> [    7.212255] pci 0000:bf:1f.5: [8086:0edd] type 00 class 0x088000
> [    7.216292] pci 0000:bf:1f.6: [8086:0ede] type 00 class 0x088000
> [    7.224255] pci 0000:bf:1f.7: [8086:0edf] type 00 class 0x088000
> [    7.232260] ACPI: PCI Root Bridge [UNC1] (domain 0000 [bus 7f])
> [    7.240014] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    7.248033] acpi PNP0A03:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    7.256181] PCI host bridge to bus 0000:7f
> [    7.260007] pci_bus 0000:7f: root bus resource [bus 7f]
> [    7.268042] pci 0000:7f:08.0: [8086:0e80] type 00 class 0x088000
> [    7.272214] pci 0000:7f:08.2: [8086:0e32] type 00 class 0x110100
> [    7.280249] pci 0000:7f:08.3: [8086:0e83] type 00 class 0x088000
> [    7.288255] pci 0000:7f:08.4: [8086:0e84] type 00 class 0x088000
> [    7.296290] pci 0000:7f:09.0: [8086:0e90] type 00 class 0x088000
> [    7.300215] pci 0000:7f:09.2: [8086:0e33] type 00 class 0x110100
> [    7.308249] pci 0000:7f:09.3: [8086:0e93] type 00 class 0x088000
> [    7.316250] pci 0000:7f:09.4: [8086:0e94] type 00 class 0x088000
> [    7.324301] pci 0000:7f:0a.0: [8086:0ec0] type 00 class 0x088000
> [    7.332011] pci 0000:7f:0a.1: [8086:0ec1] type 00 class 0x088000
> [    7.336261] pci 0000:7f:0a.2: [8086:0ec2] type 00 class 0x088000
> [    7.344211] pci 0000:7f:0a.3: [8086:0ec3] type 00 class 0x088000
> [    7.352252] pci 0000:7f:0b.0: [8086:0e1e] type 00 class 0x088000
> [    7.360077] pci 0000:7f:0b.3: [8086:0e1f] type 00 class 0x088000
> [    7.364262] pci 0000:7f:0c.0: [8086:0ee0] type 00 class 0x088000
> [    7.372254] pci 0000:7f:0c.1: [8086:0ee2] type 00 class 0x088000
> [    7.380293] pci 0000:7f:0c.2: [8086:0ee4] type 00 class 0x088000
> [    7.388265] pci 0000:7f:0c.3: [8086:0ee6] type 00 class 0x088000
> [    7.392254] pci 0000:7f:0c.4: [8086:0ee8] type 00 class 0x088000
> [    7.400212] pci 0000:7f:0c.5: [8086:0eea] type 00 class 0x088000
> [    7.408220] pci 0000:7f:0c.6: [8086:0eec] type 00 class 0x088000
> [    7.416212] pci 0000:7f:0c.7: [8086:0eee] type 00 class 0x088000
> [    7.420223] pci 0000:7f:0d.0: [8086:0ee1] type 00 class 0x088000
> [    7.428212] pci 0000:7f:0d.1: [8086:0ee3] type 00 class 0x088000
> [    7.436250] pci 0000:7f:0d.2: [8086:0ee5] type 00 class 0x088000
> [    7.444213] pci 0000:7f:0d.3: [8086:0ee7] type 00 class 0x088000
> [    7.452057] pci 0000:7f:0d.4: [8086:0ee9] type 00 class 0x088000
> [    7.456252] pci 0000:7f:0d.5: [8086:0eeb] type 00 class 0x088000
> [    7.464292] pci 0000:7f:0d.6: [8086:0eed] type 00 class 0x088000
> [    7.472214] pci 0000:7f:0e.0: [8086:0ea0] type 00 class 0x088000
> [    7.480261] pci 0000:7f:0e.1: [8086:0e30] type 00 class 0x110100
> [    7.484257] pci 0000:7f:0f.0: [8086:0ea8] type 00 class 0x088000
> [    7.492259] pci 0000:7f:0f.1: [8086:0e71] type 00 class 0x088000
> [    7.500290] pci 0000:7f:0f.2: [8086:0eaa] type 00 class 0x088000
> [    7.508257] pci 0000:7f:0f.3: [8086:0eab] type 00 class 0x088000
> [    7.512291] pci 0000:7f:0f.4: [8086:0eac] type 00 class 0x088000
> [    7.520258] pci 0000:7f:0f.5: [8086:0ead] type 00 class 0x088000
> [    7.528293] pci 0000:7f:10.0: [8086:0eb0] type 00 class 0x088000
> [    7.536254] pci 0000:7f:10.1: [8086:0eb1] type 00 class 0x088000
> [    7.544078] pci 0000:7f:10.2: [8086:0eb2] type 00 class 0x088000
> [    7.548337] pci 0000:7f:10.3: [8086:0eb3] type 00 class 0x088000
> [    7.556331] pci 0000:7f:10.4: [8086:0eb4] type 00 class 0x088000
> [    7.564256] pci 0000:7f:10.5: [8086:0eb5] type 00 class 0x088000
> [    7.572292] pci 0000:7f:10.6: [8086:0eb6] type 00 class 0x088000
> [    7.576257] pci 0000:7f:10.7: [8086:0eb7] type 00 class 0x088000
> [    7.584291] pci 0000:7f:11.0: [8086:0ef8] type 00 class 0x088000
> [    7.592254] pci 0000:7f:13.0: [8086:0e1d] type 00 class 0x088000
> [    7.600253] pci 0000:7f:13.1: [8086:0e34] type 00 class 0x110100
> [    7.608091] pci 0000:7f:13.4: [8086:0e81] type 00 class 0x088000
> [    7.612294] pci 0000:7f:13.5: [8086:0e36] type 00 class 0x110100
> [    7.620253] pci 0000:7f:13.6: [8086:0e37] type 00 class 0x110100
> [    7.628264] pci 0000:7f:16.0: [8086:0ec8] type 00 class 0x088000
> [    7.636215] pci 0000:7f:16.1: [8086:0ec9] type 00 class 0x088000
> [    7.640250] pci 0000:7f:16.2: [8086:0eca] type 00 class 0x088000
> [    7.648215] pci 0000:7f:18.0: [8086:0e40] type 00 class 0x088000
> [    7.656253] pci 0000:7f:18.2: [8086:0e3a] type 00 class 0x110100
> [    7.664218] pci 0000:7f:18.3: [8086:0e43] type 00 class 0x088000
> [    7.668291] pci 0000:7f:18.4: [8086:0e44] type 00 class 0x088000
> [    7.676255] pci 0000:7f:1c.0: [8086:0e60] type 00 class 0x088000
> [    7.684256] pci 0000:7f:1c.1: [8086:0e38] type 00 class 0x110100
> [    7.692219] pci 0000:7f:1d.0: [8086:0e68] type 00 class 0x088000
> [    7.700091] pci 0000:7f:1d.1: [8086:0e79] type 00 class 0x088000
> [    7.704297] pci 0000:7f:1d.2: [8086:0e6a] type 00 class 0x088000
> [    7.712336] pci 0000:7f:1d.3: [8086:0e6b] type 00 class 0x088000
> [    7.720260] pci 0000:7f:1d.4: [8086:0e6c] type 00 class 0x088000
> [    7.728295] pci 0000:7f:1d.5: [8086:0e6d] type 00 class 0x088000
> [    7.732257] pci 0000:7f:1e.0: [8086:0ef0] type 00 class 0x088000
> [    7.740261] pci 0000:7f:1e.1: [8086:0ef1] type 00 class 0x088000
> [    7.748293] pci 0000:7f:1e.2: [8086:0ef2] type 00 class 0x088000
> [    7.756254] pci 0000:7f:1e.3: [8086:0ef3] type 00 class 0x088000
> [    7.764054] pci 0000:7f:1e.4: [8086:0ef4] type 00 class 0x088000
> [    7.768303] pci 0000:7f:1e.5: [8086:0ef5] type 00 class 0x088000
> [    7.776332] pci 0000:7f:1e.6: [8086:0ef6] type 00 class 0x088000
> [    7.784333] pci 0000:7f:1e.7: [8086:0ef7] type 00 class 0x088000
> [    7.792293] pci 0000:7f:1f.0: [8086:0ed8] type 00 class 0x088000
> [    7.796257] pci 0000:7f:1f.1: [8086:0ed9] type 00 class 0x088000
> [    7.804299] pci 0000:7f:1f.4: [8086:0edc] type 00 class 0x088000
> [    7.812255] pci 0000:7f:1f.5: [8086:0edd] type 00 class 0x088000
> [    7.820295] pci 0000:7f:1f.6: [8086:0ede] type 00 class 0x088000
> [    7.828253] pci 0000:7f:1f.7: [8086:0edf] type 00 class 0x088000
> [    7.832302] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus 3f])
> [    7.840014] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    7.848010] acpi PNP0A03:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    7.856190] PCI host bridge to bus 0000:3f
> [    7.860006] pci_bus 0000:3f: root bus resource [bus 3f]
> [    7.868044] pci 0000:3f:08.0: [8086:0e80] type 00 class 0x088000
> [    7.876249] pci 0000:3f:08.2: [8086:0e32] type 00 class 0x110100
> [    7.880210] pci 0000:3f:08.3: [8086:0e83] type 00 class 0x088000
> [    7.888264] pci 0000:3f:08.4: [8086:0e84] type 00 class 0x088000
> [    7.896253] pci 0000:3f:09.0: [8086:0e90] type 00 class 0x088000
> [    7.904222] pci 0000:3f:09.2: [8086:0e33] type 00 class 0x110100
> [    7.912055] pci 0000:3f:09.3: [8086:0e93] type 00 class 0x088000
> [    7.916332] pci 0000:3f:09.4: [8086:0e94] type 00 class 0x088000
> [    7.924258] pci 0000:3f:0a.0: [8086:0ec0] type 00 class 0x088000
> [    7.932221] pci 0000:3f:0a.1: [8086:0ec1] type 00 class 0x088000
> [    7.940211] pci 0000:3f:0a.2: [8086:0ec2] type 00 class 0x088000
> [    7.944220] pci 0000:3f:0a.3: [8086:0ec3] type 00 class 0x088000
> [    7.952211] pci 0000:3f:0b.0: [8086:0e1e] type 00 class 0x088000
> [    7.960242] pci 0000:3f:0b.3: [8086:0e1f] type 00 class 0x088000
> [    7.968204] pci 0000:3f:0c.0: [8086:0ee0] type 00 class 0x088000
> [    7.972245] pci 0000:3f:0c.1: [8086:0ee2] type 00 class 0x088000
> [    7.980217] pci 0000:3f:0c.2: [8086:0ee4] type 00 class 0x088000
> [    7.988216] pci 0000:3f:0c.3: [8086:0ee6] type 00 class 0x088000
> [    7.996233] pci 0000:3f:0c.4: [8086:0ee8] type 00 class 0x088000
> [    8.000184] pci 0000:3f:0c.5: [8086:0eea] type 00 class 0x088000
> [    8.008222] pci 0000:3f:0c.6: [8086:0eec] type 00 class 0x088000
> [    8.016210] pci 0000:3f:0c.7: [8086:0eee] type 00 class 0x088000
> [    8.024219] pci 0000:3f:0d.0: [8086:0ee1] type 00 class 0x088000
> [    8.028215] pci 0000:3f:0d.1: [8086:0ee3] type 00 class 0x088000
> [    8.036221] pci 0000:3f:0d.2: [8086:0ee5] type 00 class 0x088000
> [    8.044211] pci 0000:3f:0d.3: [8086:0ee7] type 00 class 0x088000
> [    8.052214] pci 0000:3f:0d.4: [8086:0ee9] type 00 class 0x088000
> [    8.060057] pci 0000:3f:0d.5: [8086:0eeb] type 00 class 0x088000
> [    8.064264] pci 0000:3f:0d.6: [8086:0eed] type 00 class 0x088000
> [    8.072208] pci 0000:3f:0e.0: [8086:0ea0] type 00 class 0x088000
> [    8.080252] pci 0000:3f:0e.1: [8086:0e30] type 00 class 0x110100
> [    8.088216] pci 0000:3f:0f.0: [8086:0ea8] type 00 class 0x088000
> [    8.092292] pci 0000:3f:0f.1: [8086:0e71] type 00 class 0x088000
> [    8.100263] pci 0000:3f:0f.2: [8086:0eaa] type 00 class 0x088000
> [    8.108284] pci 0000:3f:0f.3: [8086:0eab] type 00 class 0x088000
> [    8.116247] pci 0000:3f:0f.4: [8086:0eac] type 00 class 0x088000
> [    8.120264] pci 0000:3f:0f.5: [8086:0ead] type 00 class 0x088000
> [    8.128254] pci 0000:3f:10.0: [8086:0eb0] type 00 class 0x088000
> [    8.136291] pci 0000:3f:10.1: [8086:0eb1] type 00 class 0x088000
> [    8.144249] pci 0000:3f:10.2: [8086:0eb2] type 00 class 0x088000
> [    8.152079] pci 0000:3f:10.3: [8086:0eb3] type 00 class 0x088000
> [    8.156298] pci 0000:3f:10.4: [8086:0eb4] type 00 class 0x088000
> [    8.164331] pci 0000:3f:10.5: [8086:0eb5] type 00 class 0x088000
> [    8.172250] pci 0000:3f:10.6: [8086:0eb6] type 00 class 0x088000
> [    8.180289] pci 0000:3f:10.7: [8086:0eb7] type 00 class 0x088000
> [    8.184247] pci 0000:3f:11.0: [8086:0ef8] type 00 class 0x088000
> [    8.192288] pci 0000:3f:13.0: [8086:0e1d] type 00 class 0x088000
> [    8.200205] pci 0000:3f:13.1: [8086:0e34] type 00 class 0x110100
> [    8.208252] pci 0000:3f:13.4: [8086:0e81] type 00 class 0x088000
> [    8.216041] pci 0000:3f:13.5: [8086:0e36] type 00 class 0x110100
> [    8.220295] pci 0000:3f:13.6: [8086:0e37] type 00 class 0x110100
> [    8.228249] pci 0000:3f:16.0: [8086:0ec8] type 00 class 0x088000
> [    8.236257] pci 0000:3f:16.1: [8086:0ec9] type 00 class 0x088000
> [    8.244055] pci 0000:3f:16.2: [8086:0eca] type 00 class 0x088000
> [    8.248259] pci 0000:3f:18.0: [8086:0e40] type 00 class 0x088000
> [    8.256298] pci 0000:3f:18.2: [8086:0e3a] type 00 class 0x110100
> [    8.264260] pci 0000:3f:18.3: [8086:0e43] type 00 class 0x088000
> [    8.272302] pci 0000:3f:18.4: [8086:0e44] type 00 class 0x088000
> [    8.276287] pci 0000:3f:1c.0: [8086:0e60] type 00 class 0x088000
> [    8.284252] pci 0000:3f:1c.1: [8086:0e38] type 00 class 0x110100
> [    8.292219] pci 0000:3f:1d.0: [8086:0e68] type 00 class 0x088000
> [    8.300290] pci 0000:3f:1d.1: [8086:0e79] type 00 class 0x088000
> [    8.308041] pci 0000:3f:1d.2: [8086:0e6a] type 00 class 0x088000
> [    8.312332] pci 0000:3f:1d.3: [8086:0e6b] type 00 class 0x088000
> [    8.320329] pci 0000:3f:1d.4: [8086:0e6c] type 00 class 0x088000
> [    8.328308] pci 0000:3f:1d.5: [8086:0e6d] type 00 class 0x088000
> [    8.336290] pci 0000:3f:1e.0: [8086:0ef0] type 00 class 0x088000
> [    8.340264] pci 0000:3f:1e.1: [8086:0ef1] type 00 class 0x088000
> [    8.348249] pci 0000:3f:1e.2: [8086:0ef2] type 00 class 0x088000
> [    8.356290] pci 0000:3f:1e.3: [8086:0ef3] type 00 class 0x088000
> [    8.364250] pci 0000:3f:1e.4: [8086:0ef4] type 00 class 0x088000
> [    8.368259] pci 0000:3f:1e.5: [8086:0ef5] type 00 class 0x088000
> [    8.376254] pci 0000:3f:1e.6: [8086:0ef6] type 00 class 0x088000
> [    8.384293] pci 0000:3f:1e.7: [8086:0ef7] type 00 class 0x088000
> [    8.392250] pci 0000:3f:1f.0: [8086:0ed8] type 00 class 0x088000
> [    8.400057] pci 0000:3f:1f.1: [8086:0ed9] type 00 class 0x088000
> [    8.404290] pci 0000:3f:1f.4: [8086:0edc] type 00 class 0x088000
> [    8.412303] pci 0000:3f:1f.5: [8086:0edd] type 00 class 0x088000
> [    8.420249] pci 0000:3f:1f.6: [8086:0ede] type 00 class 0x088000
> [    8.428288] pci 0000:3f:1f.7: [8086:0edf] type 00 class 0x088000
> [    8.553697] ACPI: PCI Root Bridge [IIO0] (domain 0000 [bus 00-3e])
> [    8.564035] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    8.572451] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug]
> [    8.580381] acpi PNP0A08:00: _OSC: OS now controls [PME AER PCIeCapability]
> [    8.589429] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
> [    8.605135] PCI host bridge to bus 0000:00
> [    8.608008] pci_bus 0000:00: root bus resource [bus 00-3e]
> [    8.616005] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
> [    8.620004] pci_bus 0000:00: root bus resource [io  0x1000-0x3fff]
> [    8.628004] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
> [    8.636004] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
> [    8.644031] pci_bus 0000:00: root bus resource [mem 0x90000000-0xabffbfff]
> [    8.652005] pci_bus 0000:00: root bus resource [mem 0x380000000000-0x381fffffffff]
> [    8.660042] pci 0000:00:00.0: [8086:0e00] type 00 class 0x060000
> [    8.668204] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
> [    8.676056] pci 0000:00:02.0: [8086:0e04] type 01 class 0x060400
> [    8.680248] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
> [    8.688259] pci 0000:00:02.0: System wakeup disabled by ACPI
> [    8.696233] pci 0000:00:03.0: [8086:0e08] type 01 class 0x060400
> [    8.700218] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
> [    8.708254] pci 0000:00:03.0: System wakeup disabled by ACPI
> [    8.716244] pci 0000:00:03.2: [8086:0e0a] type 01 class 0x060400
> [    8.724248] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
> [    8.728257] pci 0000:00:03.2: System wakeup disabled by ACPI
> [    8.736211] pci 0000:00:03.3: [8086:0e0b] type 01 class 0x060400
> [    8.744245] pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
> [    8.748255] pci 0000:00:03.3: System wakeup disabled by ACPI
> [    8.756175] pci 0000:00:05.0: [8086:0e28] type 00 class 0x088000
> [    8.764556] pci 0000:00:05.1: [8086:0e29] type 00 class 0x088000
> [    8.772587] pci 0000:00:05.2: [8086:0e2a] type 00 class 0x088000
> [    8.780086] pci 0000:00:05.4: [8086:0e2c] type 00 class 0x080020
> [    8.784081] pci 0000:00:05.4: reg 0x10: [mem 0x93406000-0x93406fff]
> [    8.792581] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
> [    8.800291] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
> [    8.808461] pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
> [    8.816078] pci 0000:00:1a.0: reg 0x10: [mem 0x93402000-0x934023ff]
> [    8.820258] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
> [    8.828456] pci 0000:00:1c.0: [8086:1d10] type 01 class 0x060400
> [    8.836301] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> [    8.844290] pci 0000:00:1c.0: System wakeup disabled by ACPI
> [    8.848203] pci 0000:00:1c.7: [8086:1d1e] type 01 class 0x060400
> [    8.856249] pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
> [    8.864260] pci 0000:00:1c.7: System wakeup disabled by ACPI
> [    8.868221] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
> [    8.876054] pci 0000:00:1d.0: reg 0x10: [mem 0x93401000-0x934013ff]
> [    8.884258] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
> [    8.892419] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
> [    8.900378] pci 0000:00:1e.0: System wakeup disabled by ACPI
> [    8.904133] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
> [    8.912644] pci 0000:00:1f.2: [8086:1d02] type 00 class 0x010601
> [    8.920053] pci 0000:00:1f.2: reg 0x10: [io  0x2058-0x205f]
> [    8.924036] pci 0000:00:1f.2: reg 0x14: [io  0x207c-0x207f]
> [    8.932013] pci 0000:00:1f.2: reg 0x18: [io  0x2040-0x2047]
> [    8.936013] pci 0000:00:1f.2: reg 0x1c: [io  0x2048-0x204b]
> [    8.944036] pci 0000:00:1f.2: reg 0x20: [io  0x2020-0x203f]
> [    8.952036] pci 0000:00:1f.2: reg 0x24: [mem 0x93400000-0x934007ff]
> [    8.956136] pci 0000:00:1f.2: PME# supported from D3hot
> [    8.964414] pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
> [    8.972047] pci 0000:00:1f.3: reg 0x10: [mem 0x381ffff00000-0x381ffff000ff 64bit]
> [    8.980077] pci 0000:00:1f.3: reg 0x20: [io  0x2000-0x201f]
> [    8.988595] acpiphp: Slot [8] registered
> [    8.992171] pci 0000:01:00.0: [1000:0087] type 00 class 0x010700
> [    8.996038] pci 0000:01:00.0: reg 0x10: [io  0x1000-0x10ff]
> [    9.004015] pci 0000:01:00.0: reg 0x14: [mem 0x93340000-0x9334ffff 64bit]
> [    9.012037] pci 0000:01:00.0: reg 0x1c: [mem 0x93300000-0x9333ffff 64bit]
> [    9.020040] pci 0000:01:00.0: reg 0x30: [mem 0xfff00000-0xffffffff pref]
> [    9.028128] pci 0000:01:00.0: supports D1 D2
> [    9.032266] pci 0000:00:02.0: PCI bridge to [bus 01]
> [    9.036032] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
> [    9.044008] pci 0000:00:02.0:   bridge window [mem 0x93300000-0x933fffff]
> [    9.052009] pci 0000:00:02.0:   bridge window [mem 0x90000000-0x900fffff 64bit pref]
> [    9.060535] acpiphp: Slot [2] registered
> [    9.064128] pci 0000:00:03.0: PCI bridge to [bus 02]
> [    9.072540] acpiphp: Slot [1] registered
> [    9.076172] pci 0000:03:00.0: [8086:1528] type 00 class 0x020000
> [    9.084045] pci 0000:03:00.0: reg 0x10: [mem 0x92c00000-0x92dfffff 64bit pref]
> [    9.092078] pci 0000:03:00.0: reg 0x20: [mem 0x92e04000-0x92e07fff 64bit pref]
> [    9.100013] pci 0000:03:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
> [    9.108133] pci 0000:03:00.0: PME# supported from D0 D3hot
> [    9.112083] pci 0000:03:00.0: reg 0x184: [mem 0x93100000-0x93103fff 64bit]
> [    9.120042] pci 0000:03:00.0: reg 0x190: [mem 0x93200000-0x93203fff 64bit]
> [    9.128257] pci 0000:03:00.1: [8086:1528] type 00 class 0x020000
> [    9.136044] pci 0000:03:00.1: reg 0x10: [mem 0x92a00000-0x92bfffff 64bit pref]
> [    9.144078] pci 0000:03:00.1: reg 0x20: [mem 0x92e00000-0x92e03fff 64bit pref]
> [    9.152014] pci 0000:03:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
> [    9.160135] pci 0000:03:00.1: PME# supported from D0 D3hot
> [    9.168080] pci 0000:03:00.1: reg 0x184: [mem 0x92f00000-0x92f03fff 64bit]
> [    9.172042] pci 0000:03:00.1: reg 0x190: [mem 0x93000000-0x93003fff 64bit]
> [    9.188043] pci 0000:00:03.2: PCI bridge to [bus 03-04]
> [    9.196014] pci 0000:00:03.2:   bridge window [mem 0x92f00000-0x932fffff]
> [    9.204032] pci 0000:00:03.2:   bridge window [mem 0x92a00000-0x92efffff 64bit pref]
> [    9.212599] acpiphp: Slot [0] registered
> [    9.216125] pci 0000:00:03.3: PCI bridge to [bus 05]
> [    9.224287] pci 0000:00:11.0: PCI bridge to [bus 06]
> [    9.228300] pci 0000:00:1c.0: PCI bridge to [bus 07]
> [    9.236262] pci 0000:08:00.0: [102b:0522] type 00 class 0x030000
> [    9.240055] pci 0000:08:00.0: reg 0x10: [mem 0x91000000-0x91ffffff pref]
> [    9.248045] pci 0000:08:00.0: reg 0x14: [mem 0x92800000-0x92803fff]
> [    9.256045] pci 0000:08:00.0: reg 0x18: [mem 0x92000000-0x927fffff]
> [    9.264166] pci 0000:08:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
> [    9.272506] pci 0000:00:1c.7: PCI bridge to [bus 08]
> [    9.276035] pci 0000:00:1c.7:   bridge window [mem 0x92000000-0x928fffff]
> [    9.284011] pci 0000:00:1c.7:   bridge window [mem 0x91000000-0x91ffffff 64bit pref]
> [    9.292157] pci 0000:00:1e.0: PCI bridge to [bus 09] (subtractive decode)
> [    9.300039] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
> [    9.308004] pci 0000:00:1e.0:   bridge window [io  0x1000-0x3fff] (subtractive decode)
> [    9.320028] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
> [    9.328004] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
> [    9.336004] pci 0000:00:1e.0:   bridge window [mem 0x90000000-0xabffbfff] (subtractive decode)
> [    9.348004] pci 0000:00:1e.0:   bridge window [mem 0x380000000000-0x381fffffffff] (subtractive decode)
> [    9.356130] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
> [    9.364542] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.376389] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.384413] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.396409] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.404382] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.416385] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.424382] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.436386] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    9.444812] ACPI: PCI Root Bridge [IIO1] (domain 0000 [bus 40-7e])
> [    9.452010] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    9.460010] acpi PNP0A08:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    9.468547] PCI host bridge to bus 0000:40
> [    9.472032] pci_bus 0000:40: root bus resource [bus 40-7e]
> [    9.480006] pci_bus 0000:40: root bus resource [io  0x4000-0x7fff]
> [    9.488004] pci_bus 0000:40: root bus resource [mem 0xac000000-0xc7ffbfff]
> [    9.496004] pci_bus 0000:40: root bus resource [mem 0x382000000000-0x383fffffffff]
> [    9.504049] pci 0000:40:02.0: [8086:0e04] type 01 class 0x060400
> [    9.508256] pci 0000:40:02.0: PME# supported from D0 D3hot D3cold
> [    9.516173] pci 0000:40:02.0: System wakeup disabled by ACPI
> [    9.524165] pci 0000:40:02.2: [8086:0e06] type 01 class 0x060400
> [    9.532253] pci 0000:40:02.2: PME# supported from D0 D3hot D3cold
> [    9.536169] pci 0000:40:02.2: System wakeup disabled by ACPI
> [    9.544205] pci 0000:40:03.0: [8086:0e08] type 01 class 0x060400
> [    9.552250] pci 0000:40:03.0: PME# supported from D0 D3hot D3cold
> [    9.556167] pci 0000:40:03.0: System wakeup disabled by ACPI
> [    9.564174] pci 0000:40:05.0: [8086:0e28] type 00 class 0x088000
> [    9.572417] pci 0000:40:05.1: [8086:0e29] type 00 class 0x088000
> [    9.580504] pci 0000:40:05.2: [8086:0e2a] type 00 class 0x088000
> [    9.588085] pci 0000:40:05.4: [8086:0e2c] type 00 class 0x080020
> [    9.592041] pci 0000:40:05.4: reg 0x10: [mem 0xac000000-0xac000fff]
> [    9.600545] acpiphp: Slot [5] registered
> [    9.608133] pci 0000:40:02.0: PCI bridge to [bus 41]
> [    9.612032] pci 0000:40:02.0:   bridge window [io  0x4000-0x4fff]
> [    9.620007] pci 0000:40:02.0:   bridge window [mem 0xac100000-0xac2fffff]
> [    9.628010] pci 0000:40:02.0:   bridge window [mem 0xac300000-0xac4fffff 64bit pref]
> [    9.636546] acpiphp: Slot [7] registered
> [    9.640140] pci 0000:40:02.2: PCI bridge to [bus 42]
> [    9.644008] pci 0000:40:02.2:   bridge window [io  0x5000-0x5fff]
> [    9.652007] pci 0000:40:02.2:   bridge window [mem 0xac500000-0xac6fffff]
> [    9.660009] pci 0000:40:02.2:   bridge window [mem 0xac700000-0xac8fffff 64bit pref]
> [    9.668515] acpiphp: Slot [6] registered
> [    9.676130] pci 0000:40:03.0: PCI bridge to [bus 43]
> [    9.680415] ACPI: PCI Root Bridge [IIO2] (domain 0000 [bus 80-be])
> [    9.688032] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    9.696010] acpi PNP0A08:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    9.704087] acpi PNP0A08:02: ignoring host bridge window [io  0x4558-0xffff] (conflicts with PCI Bus 0000:40 [io  0x4000-0x7fff])
> [    9.716546] PCI host bridge to bus 0000:80
> [    9.724007] pci_bus 0000:80: root bus resource [bus 80-be]
> [    9.728005] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xe3ffbfff]
> [    9.736028] pci_bus 0000:80: root bus resource [mem 0x384000000000-0x385fffffffff]
> [    9.744048] pci 0000:80:02.0: [8086:0e04] type 01 class 0x060400
> [    9.752254] pci 0000:80:02.0: PME# supported from D0 D3hot D3cold
> [    9.760181] pci 0000:80:02.0: System wakeup disabled by ACPI
> [    9.764173] pci 0000:80:02.2: [8086:0e06] type 01 class 0x060400
> [    9.772279] pci 0000:80:02.2: PME# supported from D0 D3hot D3cold
> [    9.780171] pci 0000:80:02.2: System wakeup disabled by ACPI
> [    9.784174] pci 0000:80:03.0: [8086:0e08] type 01 class 0x060400
> [    9.792224] pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
> [    9.800169] pci 0000:80:03.0: System wakeup disabled by ACPI
> [    9.804162] pci 0000:80:05.0: [8086:0e28] type 00 class 0x088000
> [    9.812433] pci 0000:80:05.1: [8086:0e29] type 00 class 0x088000
> [    9.820463] pci 0000:80:05.2: [8086:0e2a] type 00 class 0x088000
> [    9.828422] pci 0000:80:05.4: [8086:0e2c] type 00 class 0x080020
> [    9.836041] pci 0000:80:05.4: reg 0x10: [mem 0xc8000000-0xc8000fff]
> [    9.844561] acpiphp: Slot [4] registered
> [    9.848129] pci 0000:80:02.0: PCI bridge to [bus 81]
> [    9.852508] acpiphp: Slot [3] registered
> [    9.860129] pci 0000:80:02.2: PCI bridge to [bus 82]
> [    9.864515] acpiphp: Slot [9] registered
> [    9.868130] pci 0000:80:03.0: PCI bridge to [bus 83]
> [    9.876389] ACPI: PCI Root Bridge [IIO3] (domain 0000 [bus c0-fe])
> [    9.884032] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    9.892032] acpi PNP0A08:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    9.900545] PCI host bridge to bus 0000:c0
> [    9.904007] pci_bus 0000:c0: root bus resource [bus c0-fe]
> [    9.912005] pci_bus 0000:c0: root bus resource [io  0xc000-0xffff]
> [    9.916004] pci_bus 0000:c0: root bus resource [mem 0xe4000000-0xfbffbfff]
> [    9.924028] pci_bus 0000:c0: root bus resource [mem 0x386000000000-0x387fffffffff]
> [    9.932048] pci 0000:c0:02.0: [8086:0e04] type 01 class 0x060400
> [    9.940279] pci 0000:c0:02.0: PME# supported from D0 D3hot D3cold
> [    9.948172] pci 0000:c0:02.0: System wakeup disabled by ACPI
> [    9.952171] pci 0000:c0:02.2: [8086:0e06] type 01 class 0x060400
> [    9.960257] pci 0000:c0:02.2: PME# supported from D0 D3hot D3cold
> [    9.968171] pci 0000:c0:02.2: System wakeup disabled by ACPI
> [    9.976134] pci 0000:c0:03.0: [8086:0e08] type 01 class 0x060400
> [    9.980246] pci 0000:c0:03.0: PME# supported from D0 D3hot D3cold
> [    9.988182] pci 0000:c0:03.0: System wakeup disabled by ACPI
> [    9.996135] pci 0000:c0:05.0: [8086:0e28] type 00 class 0x088000
> [   10.004090] pci 0000:c0:05.1: [8086:0e29] type 00 class 0x088000
> [   10.008507] pci 0000:c0:05.2: [8086:0e2a] type 00 class 0x088000
> [   10.016474] pci 0000:c0:05.4: [8086:0e2c] type 00 class 0x080020
> [   10.024044] pci 0000:c0:05.4: reg 0x10: [mem 0xe4000000-0xe4000fff]
> [   10.032556] acpiphp: Slot [12] registered
> [   10.036163] pci 0000:c0:02.0: PCI bridge to [bus c1]
> [   10.044009] pci 0000:c0:02.0:   bridge window [io  0xc000-0xcfff]
> [   10.048007] pci 0000:c0:02.0:   bridge window [mem 0xe4100000-0xe42fffff]
> [   10.056011] pci 0000:c0:02.0:   bridge window [mem 0xe4300000-0xe44fffff 64bit pref]
> [   10.068056] acpiphp: Slot [10] registered
> [   10.072134] pci 0000:c0:02.2: PCI bridge to [bus c2]
> [   10.076031] pci 0000:c0:02.2:   bridge window [io  0xd000-0xdfff]
> [   10.084007] pci 0000:c0:02.2:   bridge window [mem 0xe4500000-0xe46fffff]
> [   10.092009] pci 0000:c0:02.2:   bridge window [mem 0xe4700000-0xe48fffff 64bit pref]
> [   10.100551] acpiphp: Slot [11] registered
> [   10.104136] pci 0000:c0:03.0: PCI bridge to [bus c3]
> [   10.112503] ACPI: Enabled 3 GPEs in block 00 to 3F
> [   10.120594] vgaarb: device added: PCI:0000:08:00.0,decodes=io+mem,owns=io+mem,locks=none
> [   10.128048] vgaarb: loaded
> [   10.131115] vgaarb: bridge control possible 0000:08:00.0
> [   10.136579] SCSI subsystem initialized
> [   10.145047] libata version 3.00 loaded.
> [   10.148173] ACPI: bus type USB registered
> [   10.152116] usbcore: registered new interface driver usbfs
> [   10.160090] usbcore: registered new interface driver hub
> [   10.168124] usbcore: registered new device driver usb
> [   10.172208] pps_core: LinuxPPS API ver. 1 registered
> [   10.180058] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [   10.188087] PTP clock support registered
> [   10.197017] EDAC MC: Ver: 3.0.0
> [   10.201764] PCI: Using ACPI for IRQ routing
> [   10.220642] PCI: pci_cache_line_size set to 64 bytes
> [   10.225930] e820: reserve RAM buffer [mem 0x0009e000-0x0009ffff]
> [   10.232006] e820: reserve RAM buffer [mem 0x650a0000-0x67ffffff]
> [   10.240007] e820: reserve RAM buffer [mem 0x65a6b000-0x67ffffff]
> [   10.248026] e820: reserve RAM buffer [mem 0x65df8000-0x67ffffff]
> [   10.252003] e820: reserve RAM buffer [mem 0x7abcf000-0x7bffffff]
> [   10.260004] e820: reserve RAM buffer [mem 0x7b800000-0x7bffffff]
> [   10.270683] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
> [   10.278591] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
> [   10.288157] Switched to clocksource hpet
> [   10.351559] pnp: PnP ACPI init
> [   10.355064] ACPI: bus type PNP registered
> [   10.404626] pnp 00:00: Plug and Play ACPI device, IDs PNP0c80 (active)
> [   10.456538] pnp 00:01: Plug and Play ACPI device, IDs PNP0c80 (active)
> [   10.508486] pnp 00:02: Plug and Play ACPI device, IDs PNP0c80 (active)
> [   10.560339] pnp 00:03: Plug and Play ACPI device, IDs PNP0c80 (active)
> [   10.568479] pnp 00:04: Plug and Play ACPI device, IDs PNP0003 (active)
> [   10.576909] pnp 00:05: [dma 4]
> [   10.580741] pnp 00:05: Plug and Play ACPI device, IDs PNP0200 (active)
> [   10.588136] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
> [   10.597344] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
> [   10.604730] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
> [   10.614113] pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 (active)
> [   10.621754] pnp 00:08: Plug and Play ACPI device, IDs PNP0800 (active)
> [   10.629562] pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
> [   10.638151] system 00:0a: [io  0x0500-0x053f] has been reserved
> [   10.644797] system 00:0a: [io  0x0400-0x047f] could not be reserved
> [   10.651826] system 00:0a: [io  0x0540-0x057f] has been reserved
> [   10.658442] system 00:0a: [io  0x0600-0x061f] has been reserved
> [   10.665094] system 00:0a: [io  0x0ca0-0x0ca5] has been reserved
> [   10.671741] system 00:0a: [io  0x0880-0x0883] has been reserved
> [   10.678392] system 00:0a: [io  0x0800-0x081f] has been reserved
> [   10.685044] system 00:0a: [mem 0xfed1c000-0xfed3ffff] could not be reserved
> [   10.692869] system 00:0a: [mem 0xfed45000-0xfed8bfff] has been reserved
> [   10.700308] system 00:0a: [mem 0xff000000-0xffffffff] could not be reserved
> [   10.708104] system 00:0a: [mem 0xfee00000-0xfeefffff] has been reserved
> [   10.715545] system 00:0a: [mem 0xfed12000-0xfed1200f] has been reserved
> [   10.722958] system 00:0a: [mem 0xfed12010-0xfed1201f] has been reserved
> [   10.730397] system 00:0a: [mem 0xfed1b000-0xfed1bfff] has been reserved
> [   10.737816] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
> [   10.745871] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
> [   10.755213] pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
> [   10.762931] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
> [   10.772273] pnp 00:0c: Plug and Play ACPI device, IDs PNP0501 (active)
> [   10.780119] pnp 00:0d: Plug and Play ACPI device, IDs IPI0001 (active)
> [   10.789501] pnp: PnP ACPI: found 14 devices
> [   10.794209] ACPI: bus type PNP unregistered
> [   10.825280] pci 0000:01:00.0: no compatible bridge window for [mem 0xfff00000-0xffffffff pref]
> [   10.834950] pci 0000:03:00.0: no compatible bridge window for [mem 0xfff80000-0xffffffff pref]
> [   10.844614] pci 0000:03:00.1: no compatible bridge window for [mem 0xfff80000-0xffffffff pref]
> [   10.854278] pci 0000:08:00.0: no compatible bridge window for [mem 0xffff0000-0xffffffff pref]
> [   10.864647] pci 0000:01:00.0: BAR 6: assigned [mem 0x90000000-0x900fffff pref]
> [   10.872762] pci 0000:00:02.0: PCI bridge to [bus 01]
> [   10.878357] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
> [   10.885232] pci 0000:00:02.0:   bridge window [mem 0x93300000-0x933fffff]
> [   10.892845] pci 0000:00:02.0:   bridge window [mem 0x90000000-0x900fffff 64bit pref]
> [   10.901552] pci 0000:00:03.0: PCI bridge to [bus 02]
> [   10.907175] pci 0000:03:00.0: BAR 6: assigned [mem 0x92e80000-0x92efffff pref]
> [   10.915295] pci 0000:03:00.1: BAR 6: can't assign mem pref (size 0x80000)
> [   10.922932] pci 0000:00:03.2: PCI bridge to [bus 03-04]
> [   10.928815] pci 0000:00:03.2:   bridge window [mem 0x92f00000-0x932fffff]
> [   10.936431] pci 0000:00:03.2:   bridge window [mem 0x92a00000-0x92efffff 64bit pref]
> [   10.945130] pci 0000:00:03.3: PCI bridge to [bus 05]
> [   10.950752] pci 0000:00:11.0: PCI bridge to [bus 06]
> [   10.956345] pci 0000:00:1c.0: PCI bridge to [bus 07]
> [   10.961982] pci 0000:08:00.0: BAR 6: assigned [mem 0x92810000-0x9281ffff pref]
> [   10.970099] pci 0000:00:1c.7: PCI bridge to [bus 08]
> [   10.975694] pci 0000:00:1c.7:   bridge window [mem 0x92000000-0x928fffff]
> [   10.983332] pci 0000:00:1c.7:   bridge window [mem 0x91000000-0x91ffffff 64bit pref]
> [   10.992033] pci 0000:00:1e.0: PCI bridge to [bus 09]
> [   10.997626] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
> [   11.003893] pci_bus 0000:00: resource 5 [io  0x1000-0x3fff]
> [   11.010156] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
> [   11.017177] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
> [   11.024230] pci_bus 0000:00: resource 8 [mem 0x90000000-0xabffbfff]
> [   11.031258] pci_bus 0000:00: resource 9 [mem 0x380000000000-0x381fffffffff]
> [   11.039072] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
> [   11.045334] pci_bus 0000:01: resource 1 [mem 0x93300000-0x933fffff]
> [   11.052387] pci_bus 0000:01: resource 2 [mem 0x90000000-0x900fffff 64bit pref]
> [   11.060474] pci_bus 0000:03: resource 1 [mem 0x92f00000-0x932fffff]
> [   11.067526] pci_bus 0000:03: resource 2 [mem 0x92a00000-0x92efffff 64bit pref]
> [   11.075606] pci_bus 0000:08: resource 1 [mem 0x92000000-0x928fffff]
> [   11.082657] pci_bus 0000:08: resource 2 [mem 0x91000000-0x91ffffff 64bit pref]
> [   11.090740] pci_bus 0000:09: resource 4 [io  0x0000-0x0cf7]
> [   11.097003] pci_bus 0000:09: resource 5 [io  0x1000-0x3fff]
> [   11.103264] pci_bus 0000:09: resource 6 [mem 0x000a0000-0x000bffff]
> [   11.110316] pci_bus 0000:09: resource 7 [mem 0xfed40000-0xfedfffff]
> [   11.117344] pci_bus 0000:09: resource 8 [mem 0x90000000-0xabffbfff]
> [   11.124397] pci_bus 0000:09: resource 9 [mem 0x380000000000-0x381fffffffff]
> [   11.132260] pci 0000:40:02.0: PCI bridge to [bus 41]
> [   11.137820] pci 0000:40:02.0:   bridge window [io  0x4000-0x4fff]
> [   11.144674] pci 0000:40:02.0:   bridge window [mem 0xac100000-0xac2fffff]
> [   11.152312] pci 0000:40:02.0:   bridge window [mem 0xac300000-0xac4fffff 64bit pref]
> [   11.161004] pci 0000:40:02.2: PCI bridge to [bus 42]
> [   11.166571] pci 0000:40:02.2:   bridge window [io  0x5000-0x5fff]
> [   11.173425] pci 0000:40:02.2:   bridge window [mem 0xac500000-0xac6fffff]
> [   11.181032] pci 0000:40:02.2:   bridge window [mem 0xac700000-0xac8fffff 64bit pref]
> [   11.189759] pci 0000:40:03.0: PCI bridge to [bus 43]
> [   11.195355] pci_bus 0000:40: resource 4 [io  0x4000-0x7fff]
> [   11.201585] pci_bus 0000:40: resource 5 [mem 0xac000000-0xc7ffbfff]
> [   11.208638] pci_bus 0000:40: resource 6 [mem 0x382000000000-0x383fffffffff]
> [   11.216421] pci_bus 0000:41: resource 0 [io  0x4000-0x4fff]
> [   11.222679] pci_bus 0000:41: resource 1 [mem 0xac100000-0xac2fffff]
> [   11.229730] pci_bus 0000:41: resource 2 [mem 0xac300000-0xac4fffff 64bit pref]
> [   11.237810] pci_bus 0000:42: resource 0 [io  0x5000-0x5fff]
> [   11.244072] pci_bus 0000:42: resource 1 [mem 0xac500000-0xac6fffff]
> [   11.251122] pci_bus 0000:42: resource 2 [mem 0xac700000-0xac8fffff 64bit pref]
> [   11.259273] pci 0000:80:02.0: PCI bridge to [bus 81]
> [   11.264863] pci 0000:80:02.2: PCI bridge to [bus 82]
> [   11.270451] pci 0000:80:03.0: PCI bridge to [bus 83]
> [   11.276042] pci_bus 0000:80: resource 4 [mem 0xc8000000-0xe3ffbfff]
> [   11.283070] pci_bus 0000:80: resource 5 [mem 0x384000000000-0x385fffffffff]
> [   11.290962] pci 0000:c0:02.0: PCI bridge to [bus c1]
> [   11.296523] pci 0000:c0:02.0:   bridge window [io  0xc000-0xcfff]
> [   11.303376] pci 0000:c0:02.0:   bridge window [mem 0xe4100000-0xe42fffff]
> [   11.311013] pci 0000:c0:02.0:   bridge window [mem 0xe4300000-0xe44fffff 64bit pref]
> [   11.319708] pci 0000:c0:02.2: PCI bridge to [bus c2]
> [   11.325269] pci 0000:c0:02.2:   bridge window [io  0xd000-0xdfff]
> [   11.332124] pci 0000:c0:02.2:   bridge window [mem 0xe4500000-0xe46fffff]
> [   11.339760] pci 0000:c0:02.2:   bridge window [mem 0xe4700000-0xe48fffff 64bit pref]
> [   11.348452] pci 0000:c0:03.0: PCI bridge to [bus c3]
> [   11.354049] pci_bus 0000:c0: resource 4 [io  0xc000-0xffff]
> [   11.360303] pci_bus 0000:c0: resource 5 [mem 0xe4000000-0xfbffbfff]
> [   11.367333] pci_bus 0000:c0: resource 6 [mem 0x386000000000-0x387fffffffff]
> [   11.375148] pci_bus 0000:c1: resource 0 [io  0xc000-0xcfff]
> [   11.381414] pci_bus 0000:c1: resource 1 [mem 0xe4100000-0xe42fffff]
> [   11.388465] pci_bus 0000:c1: resource 2 [mem 0xe4300000-0xe44fffff 64bit pref]
> [   11.396544] pci_bus 0000:c2: resource 0 [io  0xd000-0xdfff]
> [   11.402809] pci_bus 0000:c2: resource 1 [mem 0xe4500000-0xe46fffff]
> [   11.409861] pci_bus 0000:c2: resource 2 [mem 0xe4700000-0xe48fffff 64bit pref]
> [   11.418439] NET: Registered protocol family 2
> [   11.427119] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
> [   11.439098] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> [   11.447364] TCP: Hash tables configured (established 524288 bind 65536)
> [   11.455003] TCP: reno registered
> [   11.459387] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
> [   11.468575] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
> [   11.479672] NET: Registered protocol family 1
> [   11.486059] RPC: Registered named UNIX socket transport module.
> [   11.492731] RPC: Registered udp transport module.
> [   11.497992] RPC: Registered tcp transport module.
> [   11.503289] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [   11.564581] IOAPIC[0]: Set routing entry (8-16 -> 0x41 -> IRQ 16 Mode:1 Active:1 Dest:0)
> [   11.574502] IOAPIC[0]: Set routing entry (8-23 -> 0x51 -> IRQ 23 Mode:1 Active:1 Dest:0)
> [   11.584068] pci 0000:08:00.0: Boot video device
> [   11.589287] PCI: CLS 64 bytes, default 64
> [   11.593986] Trying to unpack rootfs image as initramfs...
> [   30.255226] Freeing initrd memory: 215076K (ffff88006d9c6000 - ffff88007abcf000)
> [   30.263580] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> [   30.270807] software IO TLB [mem 0x699c6000-0x6d9c6000] (64MB) mapped at [ffff8800699c6000-ffff88006d9c5fff]
> [   30.331777] RAPL PMU detected, hw unit 2^-16 Joules, API unit is 2^-32 Joules, 3 fixed counters 163840 ms ovfl timer
> [   30.405664] Scanning for low memory corruption every 60 seconds
> [   30.417601] AVX version of gcm_enc/dec engaged.
> [   30.426124] sha1_ssse3: Using AVX optimized SHA-1 implementation
> [   30.469958] futex hash table entries: 65536 (order: 10, 4194304 bytes)
> [   30.601524] bounce pool size: 64 pages
> [   30.605755] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [   30.630304] VFS: Disk quotas dquot_6.5.2
> [   30.635414] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [   30.652458] NFS: Registering the id_resolver key type
> [   30.658198] Key type id_resolver registered
> [   30.662922] Key type id_legacy registered
> [   30.667443] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> [   30.674987] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [   30.685768] ROMFS MTD (C) 2007 Red Hat, Inc.
> [   30.691193] fuse init (API version 7.22)
> [   30.697003] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
> [   30.714281] msgmni has been set to 32768
> [   30.733248] NET: Registered protocol family 38
> [   30.738269] Key type asymmetric registered
> [   30.743415] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
> [   30.752929] io scheduler noop registered
> [   30.757327] io scheduler deadline registered
> [   30.762172] io scheduler cfq registered (default)
> [   30.770661] IOAPIC[1]: Set routing entry (9-23 -> 0x61 -> IRQ 47 Mode:1 Active:1 Dest:0)
> [   30.779991] pcieport 0000:00:02.0: irq 136 for MSI/MSI-X
> [   30.787035] pcieport 0000:00:03.0: irq 137 for MSI/MSI-X
> [   30.794143] pcieport 0000:00:03.2: irq 138 for MSI/MSI-X
> [   30.801138] pcieport 0000:00:03.3: irq 139 for MSI/MSI-X
> [   30.808143] IOAPIC[0]: Set routing entry (8-19 -> 0xb1 -> IRQ 19 Mode:1 Active:1 Dest:0)
> [   30.817341] pcieport 0000:00:11.0: irq 140 for MSI/MSI-X
> [   30.824415] pcieport 0000:00:1c.0: irq 141 for MSI/MSI-X
> [   30.831281] pcieport 0000:00:1c.7: irq 142 for MSI/MSI-X
> [   30.838104] IOAPIC[2]: Set routing entry (10-23 -> 0x22 -> IRQ 71 Mode:1 Active:1 Dest:0)
> [   30.848527] IOAPIC[3]: Set routing entry (11-23 -> 0x42 -> IRQ 95 Mode:1 Active:1 Dest:0)
> [   30.858926] IOAPIC[4]: Set routing entry (12-23 -> 0x52 -> IRQ 119 Mode:1 Active:1 Dest:0)
> [   30.869391] aer 0000:00:02.0:pcie02: service driver aer loaded
> [   30.876096] aer 0000:00:03.0:pcie02: service driver aer loaded
> [   30.882752] aer 0000:00:03.2:pcie02: service driver aer loaded
> [   30.889384] aer 0000:00:03.3:pcie02: service driver aer loaded
> [   30.896048] aer 0000:00:11.0:pcie02: service driver aer loaded
> [   30.902846] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
> [   30.910685] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
> [   30.918024] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
> [   30.925571] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
> [   30.933407] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
> [   30.940933] pcieport 0000:00:03.2: Signaling PME through PCIe PME interrupt
> [   30.948761] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
> [   30.956067] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
> [   30.963414] pcie_pme 0000:00:03.2:pcie01: service driver pcie_pme loaded
> [   30.970963] pcieport 0000:00:03.3: Signaling PME through PCIe PME interrupt
> [   30.978793] pcie_pme 0000:00:03.3:pcie01: service driver pcie_pme loaded
> [   30.986343] pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
> [   30.994152] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
> [   31.001740] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
> [   31.009550] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
> [   31.017133] pcieport 0000:00:1c.7: Signaling PME through PCIe PME interrupt
> [   31.024915] pci 0000:08:00.0: Signaling PME through PCIe PME interrupt
> [   31.032258] pcie_pme 0000:00:1c.7:pcie01: service driver pcie_pme loaded
> [   31.040093] ioapic: probe of 0000:00:05.4 failed with error -22
> [   31.046794] ioapic: probe of 0000:40:05.4 failed with error -22
> [   31.053435] ioapic: probe of 0000:80:05.4 failed with error -22
> [   31.060128] ioapic: probe of 0000:c0:05.4 failed with error -22
> [   31.066923] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> [   31.073670] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
> [   31.081103] intel_idle: MWAIT substates: 0x1120
> [   31.086208] intel_idle: v0.4 model 0x3E
> [   31.090517] intel_idle: lapic_timer_reliable_states 0xffffffff
> [   31.115280] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input0
> [   31.124477] ACPI: Sleep Button [SLPB]
> [   31.128944] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [   31.137256] ACPI: Power Button [PWRF]
> [   31.142840] GHES: HEST is not enabled!
> [   31.148197] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [   31.207274] 00:0c: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
> [   31.220383] Non-volatile memory driver v1.3
> [   31.245651] brd: module loaded
> [   31.257659] loop: module loaded
> [   31.262792] lkdtm: No crash points registered, enable through debugfs
> [   31.271456] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0) (20131218/utaddress-258)
> [   31.288960] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
> [   31.300355] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x000000000000052c-0x000000000000052d (\GPIV) (20131218/utaddress-258)
> [   31.317742] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
> [   31.329428] lpc_ich: Resource conflict(s) found affecting gpio_ich
> [   31.337779] Loading iSCSI transport class v2.0-870.
> [   31.347254] Adaptec aacraid driver 1.2-0[30200]-ms
> [   31.353272] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
> [   31.361670] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.06.00.12-k.
> [   31.371510] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
> [   31.380128] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
> [   31.388368] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
> [   31.396268] GDT-HA: Storage RAID Controller Driver. Version: 3.05
> [   31.403538] RocketRAID 3xxx/4xxx Controller driver v1.8
> [   31.411440] ahci 0000:00:1f.2: version 3.0
> [   31.416734] ahci 0000:00:1f.2: irq 143 for MSI/MSI-X
> [   31.422605] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x10 impl SATA mode
> [   31.431772] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
> [   31.446217] scsi0 : ahci
> [   31.450036] scsi1 : ahci
> [   31.453811] scsi2 : ahci
> [   31.457589] scsi3 : ahci
> [   31.461374] scsi4 : ahci
> [   31.465192] scsi5 : ahci
> [   31.468636] ata1: DUMMY
> [   31.471370] ata2: DUMMY
> [   31.474110] ata3: DUMMY
> [   31.476883] ata4: DUMMY
> [   31.479620] ata5: SATA max UDMA/133 abar m2048@0x93400000 port 0x93400300 irq 143
> [   31.487992] ata6: DUMMY
> [   31.494454] tun: Universal TUN/TAP device driver, 1.6
> [   31.500189] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [   31.508753] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
> [   31.517256] Atheros(R) L2 Ethernet Driver - version 2.2.3
> [   31.523343] Copyright (c) 2007 Atheros Corporation.
> [   31.530906] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
> [   31.538850] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
> [   31.538850]   http://www.scyld.com/network/drivers.html
> [   31.553773] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
> [   31.562220] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
> [   31.569076] e100: Copyright(c) 1999-2006 Intel Corporation
> [   31.575880] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
> [   31.583789] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [   31.590965] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
> [   31.597532] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
> [   31.604844] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
> [   31.612667] igb: Copyright (c) 2007-2014 Intel Corporation.
> [   31.619516] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.19.1-k
> [   31.628221] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
> [   31.635268] IOAPIC[1]: Set routing entry (9-21 -> 0x72 -> IRQ 45 Mode:1 Active:1 Dest:0)
> [   31.808206] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> [   31.817151] ata5.00: ATAPI: TEAC    DV-W28S-W, 1.0A, max UDMA/100
> [   31.826068] ata5.00: configured for UDMA/100
> [   31.833853] scsi 4:0:0:0: CD-ROM            TEAC     DV-W28S-W        1.0A PQ: 0 ANSI: 5
> [   31.844390] scsi 4:0:0:0: Attached scsi generic sg0 type 5
> [   32.063768] ixgbe 0000:03:00.0: irq 144 for MSI/MSI-X
> [   32.069520] ixgbe 0000:03:00.0: irq 145 for MSI/MSI-X
> [   32.075238] ixgbe 0000:03:00.0: irq 146 for MSI/MSI-X
> [   32.080931] ixgbe 0000:03:00.0: irq 147 for MSI/MSI-X
> [   32.086652] ixgbe 0000:03:00.0: irq 148 for MSI/MSI-X
> [   32.092404] ixgbe 0000:03:00.0: irq 149 for MSI/MSI-X
> [   32.098121] ixgbe 0000:03:00.0: irq 150 for MSI/MSI-X
> [   32.103816] ixgbe 0000:03:00.0: irq 151 for MSI/MSI-X
> [   32.109563] ixgbe 0000:03:00.0: irq 152 for MSI/MSI-X
> [   32.115258] ixgbe 0000:03:00.0: irq 153 for MSI/MSI-X
> [   32.120977] ixgbe 0000:03:00.0: irq 154 for MSI/MSI-X
> [   32.126699] ixgbe 0000:03:00.0: irq 155 for MSI/MSI-X
> [   32.132417] ixgbe 0000:03:00.0: irq 156 for MSI/MSI-X
> [   32.138134] ixgbe 0000:03:00.0: irq 157 for MSI/MSI-X
> [   32.143856] ixgbe 0000:03:00.0: irq 158 for MSI/MSI-X
> [   32.149572] ixgbe 0000:03:00.0: irq 159 for MSI/MSI-X
> [   32.155292] ixgbe 0000:03:00.0: irq 160 for MSI/MSI-X
> [   32.161017] ixgbe 0000:03:00.0: irq 161 for MSI/MSI-X
> [   32.166733] ixgbe 0000:03:00.0: irq 162 for MSI/MSI-X
> [   32.172451] ixgbe 0000:03:00.0: irq 163 for MSI/MSI-X
> [   32.178249] ixgbe 0000:03:00.0: irq 164 for MSI/MSI-X
> [   32.183964] ixgbe 0000:03:00.0: irq 165 for MSI/MSI-X
> [   32.189680] ixgbe 0000:03:00.0: irq 166 for MSI/MSI-X
> [   32.195372] ixgbe 0000:03:00.0: irq 167 for MSI/MSI-X
> [   32.201091] ixgbe 0000:03:00.0: irq 168 for MSI/MSI-X
> [   32.206812] ixgbe 0000:03:00.0: irq 169 for MSI/MSI-X
> [   32.212533] ixgbe 0000:03:00.0: irq 170 for MSI/MSI-X
> [   32.218251] ixgbe 0000:03:00.0: irq 171 for MSI/MSI-X
> [   32.224043] ixgbe 0000:03:00.0: irq 172 for MSI/MSI-X
> [   32.229759] ixgbe 0000:03:00.0: irq 173 for MSI/MSI-X
> [   32.235452] ixgbe 0000:03:00.0: irq 174 for MSI/MSI-X
> [   32.241170] ixgbe 0000:03:00.0: irq 175 for MSI/MSI-X
> [   32.246889] ixgbe 0000:03:00.0: irq 176 for MSI/MSI-X
> [   32.252608] ixgbe 0000:03:00.0: irq 177 for MSI/MSI-X
> [   32.258326] ixgbe 0000:03:00.0: irq 178 for MSI/MSI-X
> [   32.264050] ixgbe 0000:03:00.0: irq 179 for MSI/MSI-X
> [   32.269840] ixgbe 0000:03:00.0: irq 180 for MSI/MSI-X
> [   32.275567] ixgbe 0000:03:00.0: irq 181 for MSI/MSI-X
> [   32.281285] ixgbe 0000:03:00.0: irq 182 for MSI/MSI-X
> [   32.287003] ixgbe 0000:03:00.0: irq 183 for MSI/MSI-X
> [   32.292722] ixgbe 0000:03:00.0: irq 184 for MSI/MSI-X
> [   32.298441] ixgbe 0000:03:00.0: irq 185 for MSI/MSI-X
> [   32.304187] ixgbe 0000:03:00.0: irq 186 for MSI/MSI-X
> [   32.309880] ixgbe 0000:03:00.0: irq 187 for MSI/MSI-X
> [   32.315602] ixgbe 0000:03:00.0: irq 188 for MSI/MSI-X
> [   32.321319] ixgbe 0000:03:00.0: irq 189 for MSI/MSI-X
> [   32.327037] ixgbe 0000:03:00.0: irq 190 for MSI/MSI-X
> [   32.332787] ixgbe 0000:03:00.0: irq 191 for MSI/MSI-X
> [   32.338589] ixgbe 0000:03:00.0: irq 192 for MSI/MSI-X
> [   32.344305] ixgbe 0000:03:00.0: irq 193 for MSI/MSI-X
> [   32.349998] ixgbe 0000:03:00.0: irq 194 for MSI/MSI-X
> [   32.355716] ixgbe 0000:03:00.0: irq 195 for MSI/MSI-X
> [   32.361508] ixgbe 0000:03:00.0: irq 196 for MSI/MSI-X
> [   32.367226] ixgbe 0000:03:00.0: irq 197 for MSI/MSI-X
> [   32.372918] ixgbe 0000:03:00.0: irq 198 for MSI/MSI-X
> [   32.378638] ixgbe 0000:03:00.0: irq 199 for MSI/MSI-X
> [   32.384360] ixgbe 0000:03:00.0: irq 200 for MSI/MSI-X
> [   32.390081] ixgbe 0000:03:00.0: irq 201 for MSI/MSI-X
> [   32.395802] ixgbe 0000:03:00.0: irq 202 for MSI/MSI-X
> [   32.401520] ixgbe 0000:03:00.0: irq 203 for MSI/MSI-X
> [   32.407238] ixgbe 0000:03:00.0: irq 204 for MSI/MSI-X
> [   32.412958] ixgbe 0000:03:00.0: irq 205 for MSI/MSI-X
> [   32.418675] ixgbe 0000:03:00.0: irq 206 for MSI/MSI-X
> [   32.424393] ixgbe 0000:03:00.0: irq 207 for MSI/MSI-X
> [   32.430735] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
> [   32.500831] ixgbe 0000:03:00.0: PCI Express bandwidth of 16GT/s available
> [   32.508491] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x4, Encoding Loss:20%)
> [   32.677994] ixgbe 0000:03:00.0: MAC: 3, PHY: 3, PBA No: G36748-004
> [   32.684978] ixgbe 0000:03:00.0: a0:36:9f:0e:f0:c8
> [   32.857330] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
> [   32.865005] IOAPIC[1]: Set routing entry (9-18 -> 0xc7 -> IRQ 42 Mode:1 Active:1 Dest:0)
> [   33.291988] ixgbe 0000:03:00.1: irq 208 for MSI/MSI-X
> [   33.297763] ixgbe 0000:03:00.1: irq 209 for MSI/MSI-X
> [   33.303550] ixgbe 0000:03:00.1: irq 210 for MSI/MSI-X
> [   33.309292] ixgbe 0000:03:00.1: irq 211 for MSI/MSI-X
> [   33.315032] ixgbe 0000:03:00.1: irq 212 for MSI/MSI-X
> [   33.320770] ixgbe 0000:03:00.1: irq 213 for MSI/MSI-X
> [   33.326510] ixgbe 0000:03:00.1: irq 214 for MSI/MSI-X
> [   33.332249] ixgbe 0000:03:00.1: irq 215 for MSI/MSI-X
> [   33.337990] ixgbe 0000:03:00.1: irq 216 for MSI/MSI-X
> [   33.343727] ixgbe 0000:03:00.1: irq 217 for MSI/MSI-X
> [   33.349466] ixgbe 0000:03:00.1: irq 218 for MSI/MSI-X
> [   33.355205] ixgbe 0000:03:00.1: irq 219 for MSI/MSI-X
> [   33.360942] ixgbe 0000:03:00.1: irq 220 for MSI/MSI-X
> [   33.366682] ixgbe 0000:03:00.1: irq 221 for MSI/MSI-X
> [   33.372421] ixgbe 0000:03:00.1: irq 222 for MSI/MSI-X
> [   33.378160] ixgbe 0000:03:00.1: irq 223 for MSI/MSI-X
> [   33.383897] ixgbe 0000:03:00.1: irq 224 for MSI/MSI-X
> [   33.389634] ixgbe 0000:03:00.1: irq 225 for MSI/MSI-X
> [   33.395448] ixgbe 0000:03:00.1: irq 226 for MSI/MSI-X
> [   33.401181] ixgbe 0000:03:00.1: irq 227 for MSI/MSI-X
> [   33.406920] ixgbe 0000:03:00.1: irq 228 for MSI/MSI-X
> [   33.412655] ixgbe 0000:03:00.1: irq 229 for MSI/MSI-X
> [   33.418362] ixgbe 0000:03:00.1: irq 230 for MSI/MSI-X
> [   33.424101] ixgbe 0000:03:00.1: irq 231 for MSI/MSI-X
> [   33.429841] ixgbe 0000:03:00.1: irq 232 for MSI/MSI-X
> [   33.435582] ixgbe 0000:03:00.1: irq 233 for MSI/MSI-X
> [   33.441322] ixgbe 0000:03:00.1: irq 234 for MSI/MSI-X
> [   33.447062] ixgbe 0000:03:00.1: irq 235 for MSI/MSI-X
> [   33.452799] ixgbe 0000:03:00.1: irq 236 for MSI/MSI-X
> [   33.458538] ixgbe 0000:03:00.1: irq 237 for MSI/MSI-X
> [   33.464275] ixgbe 0000:03:00.1: irq 238 for MSI/MSI-X
> [   33.470014] ixgbe 0000:03:00.1: irq 239 for MSI/MSI-X
> [   33.475751] ixgbe 0000:03:00.1: irq 240 for MSI/MSI-X
> [   33.481491] ixgbe 0000:03:00.1: irq 241 for MSI/MSI-X
> [   33.487305] ixgbe 0000:03:00.1: irq 242 for MSI/MSI-X
> [   33.493013] ixgbe 0000:03:00.1: irq 243 for MSI/MSI-X
> [   33.498754] ixgbe 0000:03:00.1: irq 244 for MSI/MSI-X
> [   33.504493] ixgbe 0000:03:00.1: irq 245 for MSI/MSI-X
> [   33.510266] ixgbe 0000:03:00.1: irq 246 for MSI/MSI-X
> [   33.515972] ixgbe 0000:03:00.1: irq 247 for MSI/MSI-X
> [   33.521710] ixgbe 0000:03:00.1: irq 248 for MSI/MSI-X
> [   33.527447] ixgbe 0000:03:00.1: irq 249 for MSI/MSI-X
> [   33.533211] ixgbe 0000:03:00.1: irq 250 for MSI/MSI-X
> [   33.538949] ixgbe 0000:03:00.1: irq 251 for MSI/MSI-X
> [   33.544665] ixgbe 0000:03:00.1: irq 252 for MSI/MSI-X
> [   33.550403] ixgbe 0000:03:00.1: irq 253 for MSI/MSI-X
> [   33.556142] ixgbe 0000:03:00.1: irq 254 for MSI/MSI-X
> [   33.561905] ixgbe 0000:03:00.1: irq 255 for MSI/MSI-X
> [   33.567644] ixgbe 0000:03:00.1: irq 256 for MSI/MSI-X
> [   33.573362] ixgbe 0000:03:00.1: irq 257 for MSI/MSI-X
> [   33.579175] ixgbe 0000:03:00.1: irq 258 for MSI/MSI-X
> [   33.584884] ixgbe 0000:03:00.1: irq 259 for MSI/MSI-X
> [   33.590624] ixgbe 0000:03:00.1: irq 260 for MSI/MSI-X
> [   33.596364] ixgbe 0000:03:00.1: irq 261 for MSI/MSI-X
> [   33.602104] ixgbe 0000:03:00.1: irq 262 for MSI/MSI-X
> [   33.607843] ixgbe 0000:03:00.1: irq 263 for MSI/MSI-X
> [   33.613581] ixgbe 0000:03:00.1: irq 264 for MSI/MSI-X
> [   33.619318] ixgbe 0000:03:00.1: irq 265 for MSI/MSI-X
> [   33.625100] ixgbe 0000:03:00.1: irq 266 for MSI/MSI-X
> [   33.630840] ixgbe 0000:03:00.1: irq 267 for MSI/MSI-X
> [   33.636546] ixgbe 0000:03:00.1: irq 268 for MSI/MSI-X
> [   33.642284] ixgbe 0000:03:00.1: irq 269 for MSI/MSI-X
> [   33.648054] ixgbe 0000:03:00.1: irq 270 for MSI/MSI-X
> [   33.653763] ixgbe 0000:03:00.1: irq 271 for MSI/MSI-X
> [   33.660046] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
> [   33.730133] ixgbe 0000:03:00.1: PCI Express bandwidth of 16GT/s available
> [   33.737778] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x4, Encoding Loss:20%)
> [   33.907312] ixgbe 0000:03:00.1: MAC: 3, PHY: 3, PBA No: G36748-004
> [   33.914276] ixgbe 0000:03:00.1: a0:36:9f:0e:f0:ca
> [   34.085877] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
> [   34.093600] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
> [   34.101649] ixgb: Copyright (c) 1999-2008 Intel Corporation.
> [   34.108694] sky2: driver version 1.30
> [   34.116397] usbcore: registered new interface driver catc
> [   34.122852] usbcore: registered new interface driver kaweth
> [   34.129130] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
> [   34.137843] usbcore: registered new interface driver pegasus
> [   34.144867] usbcore: registered new interface driver rtl8150
> [   34.151726] usbcore: registered new interface driver asix
> [   34.158335] usbcore: registered new interface driver ax88179_178a
> [   34.165684] usbcore: registered new interface driver cdc_ether
> [   34.172761] usbcore: registered new interface driver cdc_eem
> [   34.179616] usbcore: registered new interface driver dm9601
> [   34.186362] usbcore: registered new interface driver smsc75xx
> [   34.193194] usbcore: registered new interface driver smsc95xx
> [   34.200108] usbcore: registered new interface driver gl620a
> [   34.206769] usbcore: registered new interface driver net1080
> [   34.213511] usbcore: registered new interface driver plusb
> [   34.220090] usbcore: registered new interface driver rndis_host
> [   34.227087] usbcore: registered new interface driver cdc_subset
> [   34.234207] usbcore: registered new interface driver zaurus
> [   34.240832] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
> [   34.249557] usbcore: registered new interface driver int51x1
> [   34.256344] usbcore: registered new interface driver ipheth
> [   34.262960] usbcore: registered new interface driver sierra_net
> [   34.270000] usbcore: registered new interface driver cdc_ncm
> [   34.276372] Fusion MPT base driver 3.04.20
> [   34.280972] Copyright (c) 1999-2008 LSI Corporation
> [   34.286506] Fusion MPT SPI Host driver 3.04.20
> [   34.292022] Fusion MPT FC Host driver 3.04.20
> [   34.297497] Fusion MPT SAS Host driver 3.04.20
> [   34.303015] Fusion MPT misc device (ioctl) driver 3.04.20
> [   34.309691] mptctl: Registered with Fusion MPT base driver
> [   34.315865] mptctl: /dev/mptctl @ (major,minor=10,220)
> [   34.322953] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [   34.330326] ehci-pci: EHCI PCI platform driver
> [   34.336313] ehci-pci 0000:00:1a.0: EHCI Host Controller
> [   34.342827] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
> [   34.351211] ehci-pci 0000:00:1a.0: debug port 2
> [   34.360264] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
> [   34.367944] ehci-pci 0000:00:1a.0: irq 16, io mem 0x93402000
> [   34.384112] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
> [   34.392283] hub 1-0:1.0: USB hub found
> [   34.396576] hub 1-0:1.0: 2 ports detected
> [   34.402427] ehci-pci 0000:00:1d.0: EHCI Host Controller
> [   34.408914] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
> [   34.417235] ehci-pci 0000:00:1d.0: debug port 2
> [   34.426354] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
> [   34.434005] ehci-pci 0000:00:1d.0: irq 23, io mem 0x93401000
> [   34.452105] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
> [   34.460181] hub 2-0:1.0: USB hub found
> [   34.464451] hub 2-0:1.0: 2 ports detected
> [   34.470048] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [   34.477017] ohci-pci: OHCI PCI platform driver
> [   34.482588] uhci_hcd: USB Universal Host Controller Interface driver
> [   34.490712] usbcore: registered new interface driver usb-storage
> [   34.497884] usbcore: registered new interface driver ums-alauda
> [   34.505192] usbcore: registered new interface driver ums-datafab
> [   34.512475] usbcore: registered new interface driver ums-freecom
> [   34.519640] usbcore: registered new interface driver ums-isd200
> [   34.526799] usbcore: registered new interface driver ums-jumpshot
> [   34.534113] usbcore: registered new interface driver ums-sddr09
> [   34.541277] usbcore: registered new interface driver ums-sddr55
> [   34.548363] usbcore: registered new interface driver ums-usbat
> [   34.555379] usbcore: registered new interface driver usbtest
> [   34.562862] i8042: PNP: No PS/2 controller found. Probing ports directly.
> [   35.184460] i8042: Can't read CTR while initializing i8042
> [   35.190667] i8042: probe of i8042 failed with error -5
> [   35.197589] mousedev: PS/2 mouse device common for all mice
> [   35.205750] rtc_cmos 00:06: RTC can wake from S4
> [   35.211748] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
> [   35.218697] rtc_cmos 00:06: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [   35.228135] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
> [   35.234497] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
> [   35.243916] iTCO_vendor_support: vendor-support=0
> [   35.250035] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
> [   35.262429] md: linear personality registered for level -1
> [   35.268561] md: raid0 personality registered for level 0
> [   35.274543] md: raid1 personality registered for level 1
> [   35.280506] md: raid10 personality registered for level 10
> [   35.287064] md: raid6 personality registered for level 6
> [   35.293027] md: raid5 personality registered for level 5
> [   35.299012] md: raid4 personality registered for level 4
> [   35.300230] usb 1-1: new high-speed USB device number 2 using ehci-pci
> [   35.312303] md: multipath personality registered for level -4
> [   35.318767] md: faulty personality registered for level -5
> [   35.328619] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
> [   35.339861] device-mapper: multipath: version 1.6.0 loaded
> [   35.346024] device-mapper: multipath round-robin: version 1.0.0 loaded
> [   35.353412] device-mapper: cache-policy-mq: version 1.2.0 loaded
> [   35.360164] device-mapper: cache cleaner: version 1.0.0 loaded
> [   35.367330] Intel P-state driver initializing.
> [   35.372426] Intel pstate controlling: cpu 0
> [   35.377141] Intel pstate controlling: cpu 1
> [   35.381831] Intel pstate controlling: cpu 2
> [   35.386528] Intel pstate controlling: cpu 3
> [   35.391240] Intel pstate controlling: cpu 4
> [   35.395938] Intel pstate controlling: cpu 5
> [   35.400634] Intel pstate controlling: cpu 6
> [   35.405321] Intel pstate controlling: cpu 7
> [   35.410009] Intel pstate controlling: cpu 8
> [   35.414722] Intel pstate controlling: cpu 9
> [   35.419423] Intel pstate controlling: cpu 10
> [   35.424220] Intel pstate controlling: cpu 11
> [   35.429012] Intel pstate controlling: cpu 12
> [   35.433798] Intel pstate controlling: cpu 13
> [   35.437498] hub 1-1:1.0: USB hub found
> [   35.437625] hub 1-1:1.0: 6 ports detected
> [   35.447276] Intel pstate controlling: cpu 14
> [   35.452069] Intel pstate controlling: cpu 15
> [   35.456859] Intel pstate controlling: cpu 16
> [   35.461656] Intel pstate controlling: cpu 17
> [   35.466447] Intel pstate controlling: cpu 18
> [   35.471255] Intel pstate controlling: cpu 19
> [   35.476054] Intel pstate controlling: cpu 20
> [   35.480847] Intel pstate controlling: cpu 21
> [   35.485638] Intel pstate controlling: cpu 22
> [   35.490486] Intel pstate controlling: cpu 23
> [   35.495287] Intel pstate controlling: cpu 24
> [   35.500136] Intel pstate controlling: cpu 25
> [   35.504947] Intel pstate controlling: cpu 26
> [   35.509741] Intel pstate controlling: cpu 27
> [   35.514575] Intel pstate controlling: cpu 28
> [   35.519368] Intel pstate controlling: cpu 29
> [   35.524219] Intel pstate controlling: cpu 30
> [   35.529030] Intel pstate controlling: cpu 31
> [   35.533822] Intel pstate controlling: cpu 32
> [   35.538658] Intel pstate controlling: cpu 33
> [   35.543455] Intel pstate controlling: cpu 34
> [   35.548256] usb 2-1: new high-speed USB device number 2 using ehci-pci
> [   35.548309] Intel pstate controlling: cpu 35
> [   35.548372] Intel pstate controlling: cpu 36
> [   35.548393] Intel pstate controlling: cpu 37
> [   35.548415] Intel pstate controlling: cpu 38
> [   35.548436] Intel pstate controlling: cpu 39
> [   35.548470] Intel pstate controlling: cpu 40
> [   35.548490] Intel pstate controlling: cpu 41
> [   35.548520] Intel pstate controlling: cpu 42
> [   35.548541] Intel pstate controlling: cpu 43
> [   35.548562] Intel pstate controlling: cpu 44
> [   35.548583] Intel pstate controlling: cpu 45
> [   35.548617] Intel pstate controlling: cpu 46
> [   35.548638] Intel pstate controlling: cpu 47
> [   35.548659] Intel pstate controlling: cpu 48
> [   35.548679] Intel pstate controlling: cpu 49
> [   35.548700] Intel pstate controlling: cpu 50
> [   35.548734] Intel pstate controlling: cpu 51
> [   35.548755] Intel pstate controlling: cpu 52
> [   35.548786] Intel pstate controlling: cpu 53
> [   35.548806] Intel pstate controlling: cpu 54
> [   35.548847] Intel pstate controlling: cpu 55
> [   35.548881] Intel pstate controlling: cpu 56
> [   35.548902] Intel pstate controlling: cpu 57
> [   35.548922] Intel pstate controlling: cpu 58
> [   35.548943] Intel pstate controlling: cpu 59
> [   35.548964] Intel pstate controlling: cpu 60
> [   35.548998] Intel pstate controlling: cpu 61
> [   35.549018] Intel pstate controlling: cpu 62
> [   35.549039] Intel pstate controlling: cpu 63
> [   35.549061] Intel pstate controlling: cpu 64
> [   35.549082] Intel pstate controlling: cpu 65
> [   35.549116] Intel pstate controlling: cpu 66
> [   35.549137] Intel pstate controlling: cpu 67
> [   35.549158] Intel pstate controlling: cpu 68
> [   35.549180] Intel pstate controlling: cpu 69
> [   35.549201] Intel pstate controlling: cpu 70
> [   35.549223] Intel pstate controlling: cpu 71
> [   35.549257] Intel pstate controlling: cpu 72
> [   35.549277] Intel pstate controlling: cpu 73
> [   35.549298] Intel pstate controlling: cpu 74
> [   35.549320] Intel pstate controlling: cpu 75
> [   35.549340] Intel pstate controlling: cpu 76
> [   35.549374] Intel pstate controlling: cpu 77
> [   35.549395] Intel pstate controlling: cpu 78
> [   35.549415] Intel pstate controlling: cpu 79
> [   35.549437] Intel pstate controlling: cpu 80
> [   35.549458] Intel pstate controlling: cpu 81
> [   35.549493] Intel pstate controlling: cpu 82
> [   35.549514] Intel pstate controlling: cpu 83
> [   35.549535] Intel pstate controlling: cpu 84
> [   35.549557] Intel pstate controlling: cpu 85
> [   35.549578] Intel pstate controlling: cpu 86
> [   35.549629] Intel pstate controlling: cpu 87
> [   35.549652] Intel pstate controlling: cpu 88
> [   35.549672] Intel pstate controlling: cpu 89
> [   35.549694] Intel pstate controlling: cpu 90
> [   35.549716] Intel pstate controlling: cpu 91
> [   35.549736] Intel pstate controlling: cpu 92
> [   35.549771] Intel pstate controlling: cpu 93
> [   35.549792] Intel pstate controlling: cpu 94
> [   35.549813] Intel pstate controlling: cpu 95
> [   35.549834] Intel pstate controlling: cpu 96
> [   35.549854] Intel pstate controlling: cpu 97
> [   35.549888] Intel pstate controlling: cpu 98
> [   35.549910] Intel pstate controlling: cpu 99
> [   35.549932] Intel pstate controlling: cpu 100
> [   35.549953] Intel pstate controlling: cpu 101
> [   35.549974] Intel pstate controlling: cpu 102
> [   35.550008] Intel pstate controlling: cpu 103
> [   35.550030] Intel pstate controlling: cpu 104
> [   35.550051] Intel pstate controlling: cpu 105
> [   35.550074] Intel pstate controlling: cpu 106
> [   35.550096] Intel pstate controlling: cpu 107
> [   35.550131] Intel pstate controlling: cpu 108
> [   35.550152] Intel pstate controlling: cpu 109
> [   35.550173] Intel pstate controlling: cpu 110
> [   35.550195] Intel pstate controlling: cpu 111
> [   35.550216] Intel pstate controlling: cpu 112
> [   35.550237] Intel pstate controlling: cpu 113
> [   35.550271] Intel pstate controlling: cpu 114
> [   35.550293] Intel pstate controlling: cpu 115
> [   35.550315] Intel pstate controlling: cpu 116
> [   35.550337] Intel pstate controlling: cpu 117
> [   35.550358] Intel pstate controlling: cpu 118
> [   35.550410] Intel pstate controlling: cpu 119
> [   35.550858] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
> [   35.552939] usbcore: registered new interface driver usbhid
> [   35.552939] usbhid: USB HID core driver
> [   35.553143] TCP: bic registered
> [   35.553145] Initializing XFRM netlink socket
> [   35.553758] NET: Registered protocol family 10
> [   35.555911] sit: IPv6 over IPv4 tunneling driver
> [   35.556594] NET: Registered protocol family 17
> [   35.556622] 8021q: 802.1Q VLAN Support v1.8
> [   35.558784] DCCP: Activated CCID 2 (TCP-like)
> [   35.558793] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
> [   35.560126] sctp: Hash tables configured (established 65536 bind 65536)
> [   35.560626] tipc: Activated (version 2.0.0)
> [   35.560877] NET: Registered protocol family 30
> [   35.561011] tipc: Started in single node mode
> [   35.561036] Key type dns_resolver registered
> [   35.586090] 
> [   35.586090] printing PIC contents
> [   35.586096] ... PIC  IMR: ffff
> [   35.586122] ... PIC  IRR: 0c00
> [   35.586132] ... PIC  ISR: 0000
> [   35.586136] ... PIC ELCR: 0e00
> [   35.586198] printing local APIC contents on CPU#0/0:
> [   35.586200] ... APIC ID:      00000000 (0)
> [   35.586201] ... APIC VERSION: 01060015
> [   35.586202] ... APIC TASKPRI: 00000000 (00)
> [   35.586203] ... APIC PROCPRI: 00000000
> [   35.586227] ... APIC LDR: 01000000
> [   35.586228] ... APIC DFR: ffffffff
> [   35.586229] ... APIC SPIV: 000001ff
> [   35.586229] ... APIC ISR field:
> [   35.586235] 0000000000000000000000000000000000000000000000000000000000000000
> [   35.586235] ... APIC TMR field:
> [   35.586239] 0000000000000000000200020000000000000000000000000000000000000000
> [   35.586240] ... APIC IRR field:
> [   35.586244] 0000000000000000000000000000000000000000000000000000000000000000
> [   35.586245] ... APIC ESR: 00000000
> [   35.586269] ... APIC ICR: 000000fd
> [   35.586270] ... APIC ICR2: 2a000000
> [   35.586271] ... APIC LVTT: 000400ef
> [   35.586272] ... APIC LVTPC: 00000400
> [   35.586272] ... APIC LVT0: 00010700
> [   35.586273] ... APIC LVT1: 00000400
> [   35.586274] ... APIC LVTERR: 000000fe
> [   35.586275] ... APIC TMICT: 00000000
> [   35.586276] ... APIC TMCCT: 00000000
> [   35.586277] ... APIC TDCR: 00000000
> [   35.586277] 
> [   35.586289] number of MP IRQ sources: 15.
> [   35.586291] number of IO-APIC #8 registers: 24.
> [   35.586292] number of IO-APIC #9 registers: 24.
> [   35.586293] number of IO-APIC #10 registers: 24.
> [   35.586294] number of IO-APIC #11 registers: 24.
> [   35.586295] number of IO-APIC #12 registers: 24.
> [   35.586296] testing the IO APIC.......................
> [   35.586304] IO APIC #8......
> [   35.586305] .... register #00: 08000000
> [   35.586329] .......    : physical APIC id: 08
> [   35.586330] .......    : Delivery Type: 0
> [   35.586331] .......    : LTS          : 0
> [   35.586332] .... register #01: 00170020
> [   35.586333] .......     : max redirection entries: 17
> [   35.586334] .......     : PRQ implemented: 0
> [   35.586335] .......     : IO APIC version: 20
> [   35.586336] .... IRQ redirection table:
> [   35.586341] 1    0    0   0   0    0    0    00
> [   35.586347] 0    0    0   0   0    0    0    31
> [   35.586375] 0    0    0   0   0    0    0    30
> [   35.586380] 0    0    0   0   0    0    0    33
> [   35.586385] 0    0    0   0   0    0    0    34
> [   35.586391] 0    0    0   0   0    0    0    35
> [   35.586418] 0    0    0   0   0    0    0    36
> [   35.586423] 0    0    0   0   0    0    0    37
> [   35.586428] 0    0    0   0   0    0    0    38
> [   35.586457] 0    1    0   0   0    0    0    39
> [   35.586462] 0    0    0   0   0    0    0    3A
> [   35.586467] 0    0    0   0   0    0    0    3B
> [   35.586471] 0    0    0   0   0    0    0    3C
> [   35.586501] 0    0    0   0   0    0    0    3D
> [   35.586505] 0    0    0   0   0    0    0    3E
> [   35.586510] 0    0    0   0   0    0    0    3F
> [   35.586515] 0    1    0   1   0    0    0    41
> [   35.586543] 1    0    0   0   0    0    0    00
> [   35.586547] 1    0    0   0   0    0    0    00
> [   35.586552] 1    1    0   1   0    0    0    B1
> [   35.586557] 1    0    0   0   0    0    0    00
> [   35.586585] 1    0    0   0   0    0    0    00
> [   35.586590] 1    0    0   0   0    0    0    00
> [   35.586595] 0    1    0   1   0    0    0    51
> [   35.586598] IO APIC #9......
> [   35.586599] .... register #00: 09000000
> [   35.586600] .......    : physical APIC id: 09
> [   35.586624] .......    : Delivery Type: 0
> [   35.586625] .......    : LTS          : 0
> [   35.586626] .... register #01: 00170020
> [   35.586627] .......     : max redirection entries: 17
> [   35.586627] .......     : PRQ implemented: 0
> [   35.586628] .......     : IO APIC version: 20
> [   35.586629] .... register #02: 00000000
> [   35.586630] .......     : arbitration: 00
> [   35.586631] .... register #03: 00000001
> [   35.586631] .......     : Boot DT    : 1
> [   35.586632] .... IRQ redirection table:
> [   35.586636] 1    0    0   0   0    0    0    00
> [   35.586639] 1    0    0   0   0    0    0    00
> [   35.586665] 1    0    0   0   0    0    0    00
> [   35.586669] 1    0    0   0   0    0    0    00
> [   35.586672] 1    0    0   0   0    0    0    00
> [   35.586675] 1    0    0   0   0    0    0    00
> [   35.586679] 1    0    0   0   0    0    0    00
> [   35.586682] 1    0    0   0   0    0    0    00
> [   35.586708] 1    0    0   0   0    0    0    00
> [   35.586712] 1    0    0   0   0    0    0    00
> [   35.586715] 1    0    0   0   0    0    0    00
> [   35.586718] 1    0    0   0   0    0    0    00
> [   35.586722] 1    0    0   0   0    0    0    00
> [   35.586725] 1    0    0   0   0    0    0    00
> [   35.586751] 1    0    0   0   0    0    0    00
> [   35.586754] 1    0    0   0   0    0    0    00
> [   35.586758] 1    0    0   0   0    0    0    00
> [   35.586761] 1    0    0   0   0    0    0    00
> [   35.586764] 1    1    0   1   0    0    0    C7
> [   35.586768] 1    0    0   0   0    0    0    00
> [   35.586794] 1    0    0   0   0    0    0    00
> [   35.586797] 1    1    0   1   0    0    0    72
> [   35.586801] 1    0    0   0   0    0    0    00
> [   35.586804] 1    1    0   1   0    0    0    61
> [   35.586807] IO APIC #10......
> [   35.586808] .... register #00: 0A000000
> [   35.586809] .......    : physical APIC id: 0A
> [   35.586810] .......    : Delivery Type: 0
> [   35.586834] .......    : LTS          : 0
> [   35.586835] .... register #01: 00170020
> [   35.586836] .......     : max redirection entries: 17
> [   35.586837] .......     : PRQ implemented: 0
> [   35.586838] .......     : IO APIC version: 20
> [   35.586839] .... register #02: 00000000
> [   35.586840] .......     : arbitration: 00
> [   35.586840] .... register #03: 00000001
> [   35.586841] .......     : Boot DT    : 1
> [   35.586842] .... IRQ redirection table:
> [   35.586845] 1    0    0   0   0    0    0    00
> [   35.586848] 1    0    0   0   0    0    0    00
> [   35.586851] 1    0    0   0   0    0    0    00
> [   35.586877] 1    0    0   0   0    0    0    00
> [   35.586880] 1    0    0   0   0    0    0    00
> [   35.586883] 1    0    0   0   0    0    0    00
> [   35.586886] 1    0    0   0   0    0    0    00
> [   35.586889] 1    0    0   0   0    0    0    00
> [   35.586891] 1    0    0   0   0    0    0    00
> [   35.586918] 1    0    0   0   0    0    0    00
> [   35.586921] 1    0    0   0   0    0    0    00
> [   35.586924] 1    0    0   0   0    0    0    00
> [   35.586927] 1    0    0   0   0    0    0    00
> [   35.586930] 1    0    0   0   0    0    0    00
> [   35.586933] 1    0    0   0   0    0    0    00
> [   35.586935] 1    0    0   0   0    0    0    00
> [   35.586961] 1    0    0   0   0    0    0    00
> [   35.586964] 1    0    0   0   0    0    0    00
> [   35.586967] 1    0    0   0   0    0    0    00
> [   35.586970] 1    0    0   0   0    0    0    00
> [   35.586973] 1    0    0   0   0    0    0    00
> [   35.586976] 1    0    0   0   0    0    0    00
> [   35.587002] 1    0    0   0   0    0    0    00
> [   35.587005] 1    1    0   1   0    0    0    22
> [   35.587009] IO APIC #11......
> [   35.587010] .... register #00: 0B000000
> [   35.587010] .......    : physical APIC id: 0B
> [   35.587011] .......    : Delivery Type: 0
> [   35.587012] .......    : LTS          : 0
> [   35.587012] .... register #01: 00170020
> [   35.587013] .......     : max redirection entries: 17
> [   35.587014] .......     : PRQ implemented: 0
> [   35.587015] .......     : IO APIC version: 20
> [   35.587015] .... register #02: 00000000
> [   35.587016] .......     : arbitration: 00
> [   35.587017] .... register #03: 00000001
> [   35.587018] .......     : Boot DT    : 1
> [   35.587018] .... IRQ redirection table:
> [   35.587045] 1    0    0   0   0    0    0    00
> [   35.587048] 1    0    0   0   0    0    0    00
> [   35.587051] 1    0    0   0   0    0    0    00
> [   35.587054] 1    0    0   0   0    0    0    00
> [   35.587058] 1    0    0   0   0    0    0    00
> [   35.587061] 1    0    0   0   0    0    0    00
> [   35.587087] 1    0    0   0   0    0    0    00
> [   35.587090] 1    0    0   0   0    0    0    00
> [   35.587093] 1    0    0   0   0    0    0    00
> [   35.587096] 1    0    0   0   0    0    0    00
> [   35.587100] 1    0    0   0   0    0    0    00
> [   35.587103] 1    0    0   0   0    0    0    00
> [   35.587129] 1    0    0   0   0    0    0    00
> [   35.587132] 1    0    0   0   0    0    0    00
> [   35.587135] 1    0    0   0   0    0    0    00
> [   35.587138] 1    0    0   0   0    0    0    00
> [   35.587142] 1    0    0   0   0    0    0    00
> [   35.587145] 1    0    0   0   0    0    0    00
> [   35.587171] 1    0    0   0   0    0    0    00
> [   35.587174] 1    0    0   0   0    0    0    00
> [   35.587177] 1    0    0   0   0    0    0    00
> [   35.587180] 1    0    0   0   0    0    0    00
> [   35.587184] 1    0    0   0   0    0    0    00
> [   35.587187] 1    1    0   1   0    0    0    42
> [   35.587213] IO APIC #12......
> [   35.587214] .... register #00: 0C000000
> [   35.587215] .......    : physical APIC id: 0C
> [   35.587216] .......    : Delivery Type: 0
> [   35.587217] .......    : LTS          : 0
> [   35.587217] .... register #01: 00170020
> [   35.587219] .......     : max redirection entries: 17
> [   35.587219] .......     : PRQ implemented: 0
> [   35.587220] .......     : IO APIC version: 20
> [   35.587221] .... register #02: 00000000
> [   35.587222] .......     : arbitration: 00
> [   35.587223] .... register #03: 00000001
> [   35.587224] .......     : Boot DT    : 1
> [   35.587224] .... IRQ redirection table:
> [   35.587228] 1    0    0   0   0    0    0    00
> [   35.587254] 1    0    0   0   0    0    0    00
> [   35.587258] 1    0    0   0   0    0    0    00
> [   35.587261] 1    0    0   0   0    0    0    00
> [   35.587265] 1    0    0   0   0    0    0    00
> [   35.587268] 1    0    0   0   0    0    0    00
> [   35.587271] 1    0    0   0   0    0    0    00
> [   35.587297] 1    0    0   0   0    0    0    00
> [   35.587300] 1    0    0   0   0    0    0    00
> [   35.587304] 1    0    0   0   0    0    0    00
> [   35.587307] 1    0    0   0   0    0    0    00
> [   35.587310] 1    0    0   0   0    0    0    00
> [   35.587314] 1    0    0   0   0    0    0    00
> [   35.587340] 1    0    0   0   0    0    0    00
> [   35.587343] 1    0    0   0   0    0    0    00
> [   35.587346] 1    0    0   0   0    0    0    00
> [   35.587349] 1    0    0   0   0    0    0    00
> [   35.587353] 1    0    0   0   0    0    0    00
> [   35.587356] 1    0    0   0   0    0    0    00
> [   35.587383] 1    0    0   0   0    0    0    00
> [   35.587386] 1    0    0   0   0    0    0    00
> [   35.587389] 1    0    0   0   0    0    0    00
> [   35.587392] 1    0    0   0   0    0    0    00
> [   35.587396] 1    1    0   1   0    0    0    52
> [   35.587396] IRQ to pin mappings:
> [   35.587423] IRQ0 -> 0:2
> [   35.587425] IRQ1 -> 0:1
> [   35.587427] IRQ3 -> 0:3
> [   35.587429] IRQ4 -> 0:4
> [   35.587431] IRQ5 -> 0:5
> [   35.587433] IRQ6 -> 0:6
> [   35.587435] IRQ7 -> 0:7
> [   35.587436] IRQ8 -> 0:8
> [   35.587438] IRQ9 -> 0:9
> [   35.587439] IRQ10 -> 0:10
> [   35.587464] IRQ11 -> 0:11
> [   35.587466] IRQ12 -> 0:12
> [   35.587468] IRQ13 -> 0:13
> [   35.587469] IRQ14 -> 0:14
> [   35.587471] IRQ15 -> 0:15
> [   35.587473] IRQ16 -> 0:16
> [   35.587475] IRQ19 -> 0:19
> [   35.587477] IRQ23 -> 0:23
> [   35.587478] IRQ42 -> 1:18
> [   35.587480] IRQ45 -> 1:21
> [   35.587482] IRQ47 -> 1:23
> [   35.587507] IRQ71 -> 2:23
> [   35.587509] IRQ95 -> 3:23
> [   35.587510] IRQ119 -> 4:23
> [   35.587518] .................................... done.
> [   35.588280] registered taskstats version 1
> [   37.204348] rtc_cmos 00:06: setting system clock to 2014-04-10 19:29:58 UTC (1397158198)
> [   37.213454] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
> [   37.220238] EDD information not available.
> [   37.338191] hub 2-1:1.0: USB hub found
> [   37.342560] hub 2-1:1.0: 8 ports detected
> [   37.530168] pps pps0: new PPS source ptp0
> [   37.534725] ixgbe 0000:03:00.0: registered PHC device on eth0
> [   37.620300] usb 2-1.2: new full-speed USB device number 3 using ehci-pci
> [   37.722674] hub 2-1.2:1.0: USB hub found
> [   37.727405] hub 2-1.2:1.0: 4 ports detected
> [   37.804305] usb 2-1.4: new full-speed USB device number 4 using ehci-pci
> [   37.926025] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:046B:FF10.0001/input/input2
> [   37.943162] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.0-1.4/input0
> [   37.947907] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   37.947931] 8021q: adding VLAN 0 to HW filter on device eth0
> [   37.975059] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.1/0003:046B:FF10.0002/input/input3
> [   37.992422] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.0-1.4/input1
> [   38.080286] usb 2-1.2.1: new low-speed USB device number 5 using ehci-pci
> [   38.254278] pps pps1: new PPS source ptp1
> [   38.258845] ixgbe 0000:03:00.1: registered PHC device on eth1
> [   38.270346] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.0/0003:0557:2261.0003/input/input4
> [   38.287602] hid-generic 0003:0557:2261.0003: input: USB HID v1.00 Keyboard [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/input0
> [   38.326747] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.1/0003:0557:2261.0004/input/input5
> [   38.343955] hid-generic 0003:0557:2261.0004: input: USB HID v1.00 Device [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/input1
> [   38.380331] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.2/0003:0557:2261.0005/input/input6
> [   38.398295] hid-generic 0003:0557:2261.0005: input: USB HID v1.10 Mouse [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/input2
> [   38.674809] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
> [   38.681394] 8021q: adding VLAN 0 to HW filter on device eth1
> [   41.383100] ixgbe 0000:03:00.1 eth1: NIC Link is Up 1 Gbps, Flow Control: RX/TX
> [   41.397343] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> [   41.412134] Sending DHCP requests ., OK
> [   42.044141] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.178
> [   42.055314] ixgbe 0000:03:00.0: removed PHC on eth0
> [   42.494592] IP-Config: Complete:
> [   42.498294]      device=eth1, hwaddr=a0:36:9f:0e:f0:ca, ipaddr=192.168.1.178, mask=255.255.255.0, gw=192.168.1.1
> [   42.509712]      host=brickland2, domain=lkp.intel.com, nis-domain=(none)
> [   42.517345]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
> [   42.524858]      nameserver0=192.168.1.1
> [   42.529524] PM: Hibernation image not present or could not be loaded.
> [   42.543163] Freeing unused kernel memory: 1424K (ffffffff82138000 - ffffffff8229c000)
> [   42.551964] Write protecting the kernel read-only data: 16384k
> [   42.562744] Freeing unused kernel memory: 176K (ffff8800019d4000 - ffff880001a00000)
> [   42.591601] Freeing unused kernel memory: 1960K (ffff880001e16000 - ffff880002000000)
> [   43.616063] ipmi message handler version 39.2
> [   43.627732] IPMI System Interface driver.
> [   43.632730] ipmi_si: probing via ACPI
> [   43.638902] ipmi_si 00:0d: [io  0x0ca2-0x0ca3] regsize 1 spacing 1 irq 0
> [   43.646444] ipmi_si: Adding ACPI-specified kcs state machine
> [   43.652886] ipmi_si: probing via SMBIOS
> [   43.657224] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
> [   43.663878] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
> [   43.672511] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
> [   43.714510] mpt2sas version 16.100.00.00 loaded
> [   43.721180] scsi6 : Fusion MPT SAS Host
> [   43.732202] IOAPIC[1]: Set routing entry (9-8 -> 0x5d -> IRQ 32 Mode:1 Active:1 Dest:0)
> [   43.741303] mpt2sas0: 64 BIT PCI BUS DMA ADDRESSING SUPPORTED, total mem (131914308 kB)
> [   43.750346] mpt2sas 0000:01:00.0: irq 272 for MSI/MSI-X
> [   43.756234] mpt2sas 0000:01:00.0: irq 273 for MSI/MSI-X
> [   43.762091] mpt2sas 0000:01:00.0: irq 274 for MSI/MSI-X
> [   43.767999] mpt2sas 0000:01:00.0: irq 275 for MSI/MSI-X
> [   43.773883] mpt2sas 0000:01:00.0: irq 276 for MSI/MSI-X
> [   43.779794] mpt2sas 0000:01:00.0: irq 277 for MSI/MSI-X
> [   43.785711] mpt2sas 0000:01:00.0: irq 278 for MSI/MSI-X
> [   43.791638] mpt2sas 0000:01:00.0: irq 279 for MSI/MSI-X
> [   43.797556] mpt2sas 0000:01:00.0: irq 280 for MSI/MSI-X
> [   43.803505] mpt2sas 0000:01:00.0: irq 281 for MSI/MSI-X
> [   43.809457] mpt2sas 0000:01:00.0: irq 282 for MSI/MSI-X
> [   43.815379] mpt2sas 0000:01:00.0: irq 283 for MSI/MSI-X
> [   43.821321] mpt2sas 0000:01:00.0: irq 284 for MSI/MSI-X
> [   43.827272] mpt2sas 0000:01:00.0: irq 285 for MSI/MSI-X
> [   43.827848] ipmi_si 00:0d: Found new BMC (man_id: 0x000157, prod_id: 0x0063, dev_id: 0x21)
> [   43.827863] ipmi_si 00:0d: IPMI kcs interface initialized
> [   43.848507] mpt2sas 0000:01:00.0: irq 286 for MSI/MSI-X
> [   43.854466] mpt2sas 0000:01:00.0: irq 287 for MSI/MSI-X
> [   43.861045] mpt2sas0-msix0: PCI-MSI-X enabled: IRQ 272
> [   43.866837] mpt2sas0-msix1: PCI-MSI-X enabled: IRQ 273
> [   43.872627] mpt2sas0-msix2: PCI-MSI-X enabled: IRQ 274
> [   43.878415] mpt2sas0-msix3: PCI-MSI-X enabled: IRQ 275
> [   43.884216] mpt2sas0-msix4: PCI-MSI-X enabled: IRQ 276
> [   43.889987] mpt2sas0-msix5: PCI-MSI-X enabled: IRQ 277
> [   43.895764] mpt2sas0-msix6: PCI-MSI-X enabled: IRQ 278
> [   43.901551] mpt2sas0-msix7: PCI-MSI-X enabled: IRQ 279
> [   43.907352] mpt2sas0-msix8: PCI-MSI-X enabled: IRQ 280
> [   43.913099] mpt2sas0-msix9: PCI-MSI-X enabled: IRQ 281
> [   43.918880] mpt2sas0-msix10: PCI-MSI-X enabled: IRQ 282
> [   43.924771] mpt2sas0-msix11: PCI-MSI-X enabled: IRQ 283
> [   43.930637] mpt2sas0-msix12: PCI-MSI-X enabled: IRQ 284
> [   43.936482] mpt2sas0-msix13: PCI-MSI-X enabled: IRQ 285
> [   43.942357] mpt2sas0-msix14: PCI-MSI-X enabled: IRQ 286
> [   43.948243] mpt2sas0-msix15: PCI-MSI-X enabled: IRQ 287
> [   43.954145] mpt2sas0: iomem(0x0000000093340000), mapped(0xffffc9001e3e0000), size(65536)
> [   43.963236] mpt2sas0: ioport(0x0000000000001000), size(256)
> [   43.970336] microcode: CPU0 sig=0x306e7, pf=0x80, revision=0x0
> [   43.977089] microcode: CPU1 sig=0x306e7, pf=0x80, revision=0x0
> [   43.983715] microcode: CPU2 sig=0x306e7, pf=0x80, revision=0x0
> [   43.990461] microcode: CPU3 sig=0x306e7, pf=0x80, revision=0x0
> [   43.997127] microcode: CPU4 sig=0x306e7, pf=0x80, revision=0x0
> [   44.003790] microcode: CPU5 sig=0x306e7, pf=0x80, revision=0x0
> [   44.010452] microcode: CPU6 sig=0x306e7, pf=0x80, revision=0x0
> [   44.017117] microcode: CPU7 sig=0x306e7, pf=0x80, revision=0x0
> [   44.023771] microcode: CPU8 sig=0x306e7, pf=0x80, revision=0x0
> [   44.030415] microcode: CPU9 sig=0x306e7, pf=0x80, revision=0x0
> [   44.037101] microcode: CPU10 sig=0x306e7, pf=0x80, revision=0x0
> [   44.043884] microcode: CPU11 sig=0x306e7, pf=0x80, revision=0x0
> [   44.050632] microcode: CPU12 sig=0x306e7, pf=0x80, revision=0x0
> [   44.057402] microcode: CPU13 sig=0x306e7, pf=0x80, revision=0x0
> [   44.064162] microcode: CPU14 sig=0x306e7, pf=0x80, revision=0x0
> [   44.070908] microcode: CPU15 sig=0x306e7, pf=0x80, revision=0x0
> [   44.077704] microcode: CPU16 sig=0x306e7, pf=0x80, revision=0x0
> [   44.084449] microcode: CPU17 sig=0x306e7, pf=0x80, revision=0x0
> [   44.091154] microcode: CPU18 sig=0x306e7, pf=0x80, revision=0x0
> [   44.097868] microcode: CPU19 sig=0x306e7, pf=0x80, revision=0x0
> [   44.104649] microcode: CPU20 sig=0x306e7, pf=0x80, revision=0x0
> [   44.111402] microcode: CPU21 sig=0x306e7, pf=0x80, revision=0x0
> [   44.118195] microcode: CPU22 sig=0x306e7, pf=0x80, revision=0x0
> [   44.124971] microcode: CPU23 sig=0x306e7, pf=0x80, revision=0x0
> [   44.131729] microcode: CPU24 sig=0x306e7, pf=0x80, revision=0x0
> [   44.138488] microcode: CPU25 sig=0x306e7, pf=0x80, revision=0x0
> [   44.145262] microcode: CPU26 sig=0x306e7, pf=0x80, revision=0x0
> [   44.152023] microcode: CPU27 sig=0x306e7, pf=0x80, revision=0x0
> [   44.158780] microcode: CPU28 sig=0x306e7, pf=0x80, revision=0x0
> [   44.165562] microcode: CPU29 sig=0x306e7, pf=0x80, revision=0x0
> [   44.172371] microcode: CPU30 sig=0x306e7, pf=0x80, revision=0x0
> [   44.179133] microcode: CPU31 sig=0x306e7, pf=0x80, revision=0x0
> [   44.185895] microcode: CPU32 sig=0x306e7, pf=0x80, revision=0x0
> [   44.192673] microcode: CPU33 sig=0x306e7, pf=0x80, revision=0x0
> [   44.199444] microcode: CPU34 sig=0x306e7, pf=0x80, revision=0x0
> [   44.206219] microcode: CPU35 sig=0x306e7, pf=0x80, revision=0x0
> [   44.212980] microcode: CPU36 sig=0x306e7, pf=0x80, revision=0x0
> [   44.219698] microcode: CPU37 sig=0x306e7, pf=0x80, revision=0x0
> [   44.226502] microcode: CPU38 sig=0x306e7, pf=0x80, revision=0x0
> [   44.233229] microcode: CPU39 sig=0x306e7, pf=0x80, revision=0x0
> [   44.240270] microcode: CPU40 sig=0x306e7, pf=0x80, revision=0x0
> [   44.246956] microcode: CPU41 sig=0x306e7, pf=0x80, revision=0x0
> [   44.253672] microcode: CPU42 sig=0x306e7, pf=0x80, revision=0x0
> [   44.260435] microcode: CPU43 sig=0x306e7, pf=0x80, revision=0x0
> [   44.267471] microcode: CPU44 sig=0x306e7, pf=0x80, revision=0x0
> [   44.274363] microcode: CPU45 sig=0x306e7, pf=0x80, revision=0x0
> [   44.281114] microcode: CPU46 sig=0x306e7, pf=0x80, revision=0x0
> [   44.287892] microcode: CPU47 sig=0x306e7, pf=0x80, revision=0x0
> [   44.294654] microcode: CPU48 sig=0x306e7, pf=0x80, revision=0x0
> [   44.301399] microcode: CPU49 sig=0x306e7, pf=0x80, revision=0x0
> [   44.308174] microcode: CPU50 sig=0x306e7, pf=0x80, revision=0x0
> [   44.314964] microcode: CPU51 sig=0x306e7, pf=0x80, revision=0x0
> [   44.321711] microcode: CPU52 sig=0x306e7, pf=0x80, revision=0x0
> [   44.328457] microcode: CPU53 sig=0x306e7, pf=0x80, revision=0x0
> [   44.335204] microcode: CPU54 sig=0x306e7, pf=0x80, revision=0x0
> [   44.341950] microcode: CPU55 sig=0x306e7, pf=0x80, revision=0x0
> [   44.348702] microcode: CPU56 sig=0x306e7, pf=0x80, revision=0x0
> [   44.355528] microcode: CPU57 sig=0x306e7, pf=0x80, revision=0x0
> [   44.362275] microcode: CPU58 sig=0x306e7, pf=0x80, revision=0x0
> [   44.369051] microcode: CPU59 sig=0x306e7, pf=0x80, revision=0x0
> [   44.375794] microcode: CPU60 sig=0x306e7, pf=0x80, revision=0x0
> [   44.382547] microcode: CPU61 sig=0x306e7, pf=0x80, revision=0x0
> [   44.389258] microcode: CPU62 sig=0x306e7, pf=0x80, revision=0x0
> [   44.395957] microcode: CPU63 sig=0x306e7, pf=0x80, revision=0x0
> [   44.402697] microcode: CPU64 sig=0x306e7, pf=0x80, revision=0x0
> [   44.409457] microcode: CPU65 sig=0x306e7, pf=0x80, revision=0x0
> [   44.416217] microcode: CPU66 sig=0x306e7, pf=0x80, revision=0x0
> [   44.422963] microcode: CPU67 sig=0x306e7, pf=0x80, revision=0x0
> [   44.429820] microcode: CPU68 sig=0x306e7, pf=0x80, revision=0x0
> [   44.436599] microcode: CPU69 sig=0x306e7, pf=0x80, revision=0x0
> [   44.443381] microcode: CPU70 sig=0x306e7, pf=0x80, revision=0x0
> [   44.450126] microcode: CPU71 sig=0x306e7, pf=0x80, revision=0x0
> [   44.456908] microcode: CPU72 sig=0x306e7, pf=0x80, revision=0x0
> [   44.463670] microcode: CPU73 sig=0x306e7, pf=0x80, revision=0x0
> [   44.470417] microcode: CPU74 sig=0x306e7, pf=0x80, revision=0x0
> [   44.475047] mpt2sas0: Allocated physical memory: size(7101 kB)
> [   44.475049] mpt2sas0: Current Controller Queue Depth(2811), Max Controller Queue Depth(3072)
> [   44.475050] mpt2sas0: Scatter Gather Elements per IO(128)
> [   44.499151] microcode: CPU75 sig=0x306e7, pf=0x80, revision=0x0
> [   44.505883] microcode: CPU76 sig=0x306e7, pf=0x80, revision=0x0
> [   44.512624] microcode: CPU77 sig=0x306e7, pf=0x80, revision=0x0
> [   44.519387] microcode: CPU78 sig=0x306e7, pf=0x80, revision=0x0
> [   44.526163] microcode: CPU79 sig=0x306e7, pf=0x80, revision=0x0
> [   44.532938] microcode: CPU80 sig=0x306e7, pf=0x80, revision=0x0
> [   44.539687] microcode: CPU81 sig=0x306e7, pf=0x80, revision=0x0
> [   44.546419] microcode: CPU82 sig=0x306e7, pf=0x80, revision=0x0
> [   44.553167] microcode: CPU83 sig=0x306e7, pf=0x80, revision=0x0
> [   44.559950] microcode: CPU84 sig=0x306e7, pf=0x80, revision=0x0
> [   44.566697] microcode: CPU85 sig=0x306e7, pf=0x80, revision=0x0
> [   44.573451] microcode: CPU86 sig=0x306e7, pf=0x80, revision=0x0
> [   44.580196] microcode: CPU87 sig=0x306e7, pf=0x80, revision=0x0
> [   44.586974] microcode: CPU88 sig=0x306e7, pf=0x80, revision=0x0
> [   44.593713] microcode: CPU89 sig=0x306e7, pf=0x80, revision=0x0
> [   44.600523] microcode: CPU90 sig=0x306e7, pf=0x80, revision=0x0
> [   44.607288] microcode: CPU91 sig=0x306e7, pf=0x80, revision=0x0
> [   44.614033] microcode: CPU92 sig=0x306e7, pf=0x80, revision=0x0
> [   44.620800] microcode: CPU93 sig=0x306e7, pf=0x80, revision=0x0
> [   44.627541] microcode: CPU94 sig=0x306e7, pf=0x80, revision=0x0
> [   44.634311] microcode: CPU95 sig=0x306e7, pf=0x80, revision=0x0
> [   44.641060] microcode: CPU96 sig=0x306e7, pf=0x80, revision=0x0
> [   44.647813] microcode: CPU97 sig=0x306e7, pf=0x80, revision=0x0
> [   44.654561] microcode: CPU98 sig=0x306e7, pf=0x80, revision=0x0
> [   44.661304] microcode: CPU99 sig=0x306e7, pf=0x80, revision=0x0
> [   44.668304] microcode: CPU100 sig=0x306e7, pf=0x80, revision=0x0
> [   44.675164] microcode: CPU101 sig=0x306e7, pf=0x80, revision=0x0
> [   44.682035] microcode: CPU102 sig=0x306e7, pf=0x80, revision=0x0
> [   44.688874] microcode: CPU103 sig=0x306e7, pf=0x80, revision=0x0
> [   44.695739] microcode: CPU104 sig=0x306e7, pf=0x80, revision=0x0
> [   44.702636] microcode: CPU105 sig=0x306e7, pf=0x80, revision=0x0
> [   44.708900] mpt2sas0: LSISAS2308: FWVersion(15.00.00.00), ChipRevision(0x05), BiosVersion(07.29.01.00)
> [   44.708931] mpt2sas0: Protocol=(Initiator), Capabilities=(Raid,TLR,EEDP,Snapshot Buffer,Diag Trace Buffer,Task Set Full,NCQ)
> [   44.709152] mpt2sas0: sending port enable !!
> [   44.737258] microcode: CPU106 sig=0x306e7, pf=0x80, revision=0x0
> [   44.744138] microcode: CPU107 sig=0x306e7, pf=0x80, revision=0x0
> [   44.751000] microcode: CPU108 sig=0x306e7, pf=0x80, revision=0x0
> [   44.757842] microcode: CPU109 sig=0x306e7, pf=0x80, revision=0x0
> [   44.764666] microcode: CPU110 sig=0x306e7, pf=0x80, revision=0x0
> [   44.771543] microcode: CPU111 sig=0x306e7, pf=0x80, revision=0x0
> [   44.778399] microcode: CPU112 sig=0x306e7, pf=0x80, revision=0x0
> [   44.785273] microcode: CPU113 sig=0x306e7, pf=0x80, revision=0x0
> [   44.792146] microcode: CPU114 sig=0x306e7, pf=0x80, revision=0x0
> [   44.798998] microcode: CPU115 sig=0x306e7, pf=0x80, revision=0x0
> [   44.805839] microcode: CPU116 sig=0x306e7, pf=0x80, revision=0x0
> [   44.812697] microcode: CPU117 sig=0x306e7, pf=0x80, revision=0x0
> [   44.819570] microcode: CPU118 sig=0x306e7, pf=0x80, revision=0x0
> [   44.826434] microcode: CPU119 sig=0x306e7, pf=0x80, revision=0x0
> [   44.833717] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> [   46.288265] mpt2sas0: host_add: handle(0x0001), sas_addr(0x500605b005c34b20), phys(8)
> [   52.408147] mpt2sas0: port enable: SUCCESS
> [   52.413665] scsi 6:1:0:0: Direct-Access     LSI      Logical Volume   3000 PQ: 0 ANSI: 6
> [   52.423137] scsi 6:1:0:0: RAID0: handle(0x011e), wwid(0x0d900f640c63339a), pd_count(2), type(SSP)
> [   52.433103] scsi 6:1:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
> [   52.445568] scsi 6:0:0:0: Direct-Access     SEAGATE  ST9300653SS      0004 PQ: 0 ANSI: 6
> [   52.454883] scsi 6:0:0:0: SSP: handle(0x0009), sas_addr(0x5000c50067b47751), phy(2), device_name(0x5000c50067b47750)
> [   52.458871] scsi 6:0:0:0: SSP: enclosure_logical_id(0x500605b005c34b20), slot(1)
> [   52.474975] scsi 6:0:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
> [   52.488372] scsi 6:0:1:0: Direct-Access     SEAGATE  ST9300653SS      0004 PQ: 0 ANSI: 6
> [   52.497685] scsi 6:0:1:0: SSP: handle(0x000a), sas_addr(0x5000c50067b4697d), phy(3), device_name(0x5000c50067b4697c)
> [   52.501672] scsi 6:0:1:0: SSP: enclosure_logical_id(0x500605b005c34b20), slot(0)
> [   52.517769] scsi 6:0:1:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
> [   52.530014] sd 6:1:0:0: [sda] 1167966208 512-byte logical blocks: (597 GB/556 GiB)
> [   52.530258] sd 6:1:0:0: Attached scsi generic sg1 type 0
> [   52.531378] scsi 6:0:0:0: Attached scsi generic sg2 type 0
> [   52.532385] scsi 6:0:1:0: Attached scsi generic sg3 type 0
> [   52.556749] sd 6:1:0:0: [sda] 4096-byte physical blocks
> [   52.564334] sd 6:1:0:0: [sda] Write Protect is off
> [   52.569732] sd 6:1:0:0: [sda] Mode Sense: 03 00 00 08
> [   52.575433] sd 6:1:0:0: [sda] No Caching mode page found
> [   52.581419] sd 6:1:0:0: [sda] Assuming drive cache: write through
> [   52.589337] sd 6:1:0:0: [sda] No Caching mode page found
> [   52.595328] sd 6:1:0:0: [sda] Assuming drive cache: write through
> [   52.607279]  sda: sda1 sda2 sda3
> [   52.613035] sd 6:1:0:0: [sda] No Caching mode page found
> [   52.619053] sd 6:1:0:0: [sda] Assuming drive cache: write through
> [   52.626006] sd 6:1:0:0: [sda] Attached SCSI disk
> [   54.427566] random: vgscan urandom read with 119 bits of entropy available
> [   54.476567] random: nonblocking pool is initialized
> 
> ==> /lkp/lkp/src/tmp/run_log <==
> Kernel tests: Boot OK!
> PATH=/sbin:/usr/sbin:/bin:/usr/bin
> 
> ==> /lkp/lkp/src/tmp/err_log <==
> 
> ==> /lkp/lkp/src/tmp/run_log <==
> downloading latest lkp src code
> Kernel tests: Boot OK 2!
> /lkp/lkp/src/bin/run-lkp
> LKP_SRC_DIR=/lkp/lkp/src
> RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand/x86_64-lkp/e014c34aeeea53bf253a7395906f6be7894485fc/0
> job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml
> run-job /lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-mmap-read-rand-HEAD-e014c34aeeea53bf253a7395906f6be7894485fc.yaml
> run: /lkp/lkp/src/monitors/wrapper perf-profile	{}
> run: /lkp/lkp/src/setup/runtime 300s	{}
> run: pre-test
> run: /lkp/lkp/src/monitors/event/wait pre-test	{}
> run: /lkp/lkp/src/monitors/wrapper uptime	{}
> run: /lkp/lkp/src/monitors/wrapper iostat	{}
> run: /lkp/lkp/src/monitors/wrapper vmstat	{}
> run: /lkp/lkp/src/monitors/wrapper numa-numastat	{}
> run: /lkp/lkp/src/monitors/wrapper numa-vmstat	{}
> run: /lkp/lkp/src/monitors/wrapper numa-meminfo	{}
> run: /lkp/lkp/src/monitors/wrapper proc-vmstat	{}
> run: /lkp/lkp/src/monitors/wrapper meminfo	{}
> run: /lkp/lkp/src/monitors/wrapper slabinfo	{}
> run: /lkp/lkp/src/monitors/wrapper interrupts	{}
> run: /lkp/lkp/src/monitors/wrapper lock_stat	{}
> run: /lkp/lkp/src/monitors/wrapper latency_stats	{}
> run: /lkp/lkp/src/monitors/wrapper softirqs	{}
> run: /lkp/lkp/src/monitors/wrapper bdi_dev_mapping	{}
> run: /lkp/lkp/src/monitors/wrapper pmeter	{}
> run: /lkp/lkp/src/monitors/wrapper diskstats	{}
> run: /lkp/lkp/src/monitors/wrapper zoneinfo	{}
> run: /lkp/lkp/src/monitors/wrapper energy	{}
> run: /lkp/lkp/src/monitors/wrapper cpuidle	{}
> run: /lkp/lkp/src/monitors/wrapper turbostat	{}
> run: /usr/bin/time -v -o /lkp/lkp/src/tmp/time /lkp/lkp/src/tests/micro/wrapper vm-scalability	{"test"=>"lru-file-mmap-read-rand"}
> [   66.015432] XFS (loop0): Mounting Filesystem
> [   66.033080] XFS (loop0): Ending clean mount
> perf interrupt took too long (5177 > 2500), lowering kernel.perf_event_max_sample_rate to 25000
> [  184.288215] perf interrupt took too long (9589 > 5000), lowering kernel.perf_event_max_sample_rate to 25000
> [  184.300137] perf interrupt took too long (10119 > 10000), lowering kernel.perf_event_max_sample_rate to 12500
> [  185.547222] perf interrupt took too long (20045 > 20000), lowering kernel.perf_event_max_sample_rate to 6250
> [  380.836690] BUG: Bad page map in process usemem  pte:310103e3c pmd:7b3c2a067
> [  380.844622] addr:00007f7e9408a000 vm_flags:000000d1 anon_vma:          (null) mapping:ffff8807d5ce8ae0 index:454c75
> [  380.856396] vma->vm_ops->fault: filemap_fault+0x0/0x394
> [  380.862326] vma->vm_file->f_op->mmap: xfs_file_mmap+0x0/0x2a
> [  380.868705] CPU: 47 PID: 7372 Comm: usemem Not tainted 3.14.0-wl-03657-ge014c34 #1
> [  380.877243] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
> [  380.888916]  0000000000000000 ffff8807cd3dbc98 ffffffff819bd4c4 00007f7e9408a000
> [  380.897581]  ffff8807cd3dbce0 ffffffff811a66d7 0000000843354067 0000000310103e3c
> [  380.906096]  0000000000000000 ffff8808419cfb50 ffffea000d4747c0 0000000000000000
> [  380.914549] Call Trace:
> [  380.917340]  [<ffffffff819bd4c4>] dump_stack+0x4d/0x66
> [  380.923160]  [<ffffffff811a66d7>] print_bad_pte+0x215/0x231
> [  380.929475]  [<ffffffff811a776e>] vm_normal_page+0x43/0x77
> [  380.935679]  [<ffffffff811a7c08>] unmap_single_vma+0x466/0x7bb
> [  380.942263]  [<ffffffff811a8e3f>] unmap_vmas+0x55/0x81
> [  380.948098]  [<ffffffff811afca5>] exit_mmap+0x76/0x12c
> [  380.953952]  [<ffffffff810dba5b>] mmput+0x74/0x109
> [  380.959358]  [<ffffffff810e0351>] do_exit+0x395/0x99b
> [  380.965073]  [<ffffffff8148d1b7>] ? trace_hardirqs_off_thunk+0x3a/0x6c
> [  380.972449]  [<ffffffff810e09d1>] do_group_exit+0x44/0xac
> [  380.978522]  [<ffffffff810e0a4d>] SyS_exit_group+0x14/0x14
> [  380.984686]  [<ffffffff819cc1e9>] system_call_fastpath+0x16/0x1b
> [  380.991444] Disabling lock debugging due to kernel taint
> [  381.224210] BUG: Bad page map in process usemem  pte:210203e3c pmd:1003df3067
> [  381.232280] addr:00007f4260980000 vm_flags:000000d1 anon_vma:          (null) mapping:ffff8808447182e0 index:20bb5f
> [  381.244010] vma->vm_ops->fault: filemap_fault+0x0/0x394
> [  381.250073] vma->vm_file->f_op->mmap: xfs_file_mmap+0x0/0x2a
> [  381.256435] CPU: 8 PID: 6840 Comm: usemem Tainted: G    B        3.14.0-wl-03657-ge014c34 #1
> [  381.265918] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
> [  381.277559]  0000000000000000 ffff880841861c98 ffffffff819bd4c4 00007f4260980000
> [  381.286024]  ffff880841861ce0 ffffffff811a66d7 000000103d09d067 0000000210203e3c
> [  381.294422]  0000000000000000 ffff882042ba8ac8 ffffea0037f14380 0000000000000000
> [  381.302833] Call Trace:
> [  381.305615]  [<ffffffff819bd4c4>] dump_stack+0x4d/0x66
> [  381.311438]  [<ffffffff811a66d7>] print_bad_pte+0x215/0x231
> [  381.317700]  [<ffffffff811a776e>] vm_normal_page+0x43/0x77
> [  381.323889]  [<ffffffff811a7c08>] unmap_single_vma+0x466/0x7bb
> [  381.324853] BUG: Bad rss-counter state mm:ffff8807d6b98780 idx:0 val:1
> [  381.337800]  [<ffffffff811a8e3f>] unmap_vmas+0x55/0x81
> [  381.343599]  [<ffffffff811afca5>] exit_mmap+0x76/0x12c
> [  381.349380]  [<ffffffff810dba5b>] mmput+0x74/0x109
> [  381.354814]  [<ffffffff810e0351>] do_exit+0x395/0x99b
> [  381.360510]  [<ffffffff8148d1b7>] ? trace_hardirqs_off_thunk+0x3a/0x6c
> [  381.367867]  [<ffffffff810e09d1>] do_group_exit+0x44/0xac
> [  381.373960]  [<ffffffff810e0a4d>] SyS_exit_group+0x14/0x14
> [  381.380153]  [<ffffffff819cc1e9>] system_call_fastpath+0x16/0x1b
> [  543.848231] BUG: Bad rss-counter state mm:ffff8810445bda00 idx:0 val:1
> geting new job...
> downloading kernel image ...
> downloading initrds ...
> kexecing...
> kexec -l /tmp//kernel/x86_64-lkp/v3.14/vmlinuz-3.14.0 --initrd=/tmp/initrd-20812 --append="user=lkp job=/lkp/scheduled/brickland2/cyclic_vm-scalability-300s-lru-file-readonce-BASE-v3.14.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/v3.14/vmlinuz-3.14.0 kconfig=x86_64-lkp commit=v3.14 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 bm_initrd=/lkp/benchmarks/vm-scalability.cgz modules_initrd=/kernel/x86_64-lkp/455c6fdbd219161bd09b1165f11699d6d73de11c/modules.cgz max_uptime=1939 RESULT_ROOT=/lkp/result/brickland2/micro/vm-scalability/300s-lru-file-readonce/x86_64-lkp/455c6fdbd219161bd09b1165f11699d6d73de11c/5 ip=::::brickland2::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal"
> [  627.510750] ixgbe 0000:03:00.1: removed PHC on eth1
> [  627.955477] kvm: exiting hardware virtualization
> [  627.998955] IPMI message handler: Event queue full, discarding incoming events
> [  628.097167] mpt2sas0: IR shutdown (sending)
> [  628.102069] mpt2sas0: IR shutdown (complete): ioc_status(0x0000), loginfo(0x00000000)
> [  628.111068] mpt2sas0: sending diag reset !!
> [  629.184111] mpt2sas0: diag reset: SUCCESS
> Starting new kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
