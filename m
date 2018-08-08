Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B63AB6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:01:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g5-v6so683700edp.1
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:01:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y19-v6si750817edm.267.2018.08.08.02.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 02:01:27 -0700 (PDT)
Subject: Re: [4.18 rc7] BUG: sleeping function called from invalid context at
 mm/slab.h:421
References: <CABXGCsNAjrwat-Fv6GQXq8uSC6uj=ke87RJt42syrfFi0vQUmg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz>
Date: Wed, 8 Aug 2018 11:01:25 +0200
MIME-Version: 1.0
In-Reply-To: <CABXGCsNAjrwat-Fv6GQXq8uSC6uj=ke87RJt42syrfFi0vQUmg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org, Petr Mladek <pmladek@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On 08/08/2018 05:50 AM, Mikhail Gavrilov wrote:
> Hi guys.
> I am catched new bug.
> Can anyone look?

fbcon_startup() calls kzalloc(sizeof(struct fbcon_ops), GFP_KERNEL) so
it tells slab it can sleep. The problem must be higher in the stack,
CCing printk people.

> [226995.988988] BUG: sleeping function called from invalid context at
> mm/slab.h:421
> [226995.988988] in_atomic(): 1, irqs_disabled(): 1, pid: 22658, name: gsd-rfkill
> [226995.988989] INFO: lockdep is turned off.
> [226995.988989] irq event stamp: 0
> [226995.988990] hardirqs last  enabled at (0): [<0000000000000000>]
>        (null)
> [226995.988991] hardirqs last disabled at (0): [<ffffffffa00b6b4a>]
> copy_process.part.32+0x72a/0x1e60
> [226995.988991] softirqs last  enabled at (0): [<ffffffffa00b6b4a>]
> copy_process.part.32+0x72a/0x1e60
> [226995.988992] softirqs last disabled at (0): [<0000000000000000>]
>        (null)
> [226995.988993] CPU: 6 PID: 22658 Comm: gsd-rfkill Tainted: G        W
>         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [226995.988993] Hardware name: Gigabyte Technology Co., Ltd.
> Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [226995.988994] Call Trace:
> [226995.988994]  dump_stack+0x85/0xc0
> [226995.988995]  ___might_sleep.cold.72+0xac/0xbc
> [226995.988995]  kmem_cache_alloc_trace+0x202/0x2f0
> [226995.988996]  ? fbcon_startup+0xae/0x300
> [226995.988996]  fbcon_startup+0xae/0x300
> [226995.988997]  do_take_over_console+0x6d/0x180
> [226995.988997]  do_fbcon_takeover+0x58/0xb0
> [226995.988997]  fbcon_output_notifier.cold.35+0x5/0x23
> [226995.988998]  notifier_call_chain+0x39/0x90
> [226995.988999]  vt_console_print+0x363/0x420
> [226995.988999]  console_unlock+0x422/0x610
> [226995.988999]  vprintk_emit+0x268/0x540
> [226995.989000]  printk+0x58/0x6f
> [226995.989000]  rfkill_fop_release.cold.16+0xc/0x11 [rfkill]
> [226995.989001]  __fput+0xc7/0x250
> [226995.989001]  task_work_run+0xa1/0xd0
> [226995.989002]  exit_to_usermode_loop+0xd8/0xe0
> [226995.989002]  do_syscall_64+0x1df/0x1f0
> [226995.989003]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [226995.989003] RIP: 0033:0x7f56ca6a157f
> [226995.989004] Code: 00 0f 05 48 3d 00 f0 ff ff 77 40 c3 0f 1f 80 00
> 00 00 00 53 89 fb 48 83 ec 10 e8 ec c6 01 00 89 df 89 c2 b8 03 00 00
> 00 0f 05 <48> 3d 00 f0 ff ff 77 2b 89 d7 89 44 24 0c e8 2e c7 01 00 8b
> 44 24
> [226995.989027] RSP: 002b:00007fff7cb47db0 EFLAGS: 00000293 ORIG_RAX:
> 0000000000000003
> [226995.989028] RAX: 0000000000000000 RBX: 0000000000000009 RCX:
> 00007f56ca6a157f
> [226995.989029] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> 0000000000000009
> [226995.989029] RBP: 0000000000000000 R08: 0000000000000013 R09:
> 000055cf4fc30b80
> [226995.989030] R10: 000055cf4fc04d70 R11: 0000000000000293 R12:
> 000055cf4fc27450
> [226995.989030] R13: 000055cf4fc0f040 R14: 000055cf4fc32da0 R15:
> 00007fff7cb47e20
> 
> 
> 
> 
> --
> Best Regards,
> Mike Gavrilov.
> 
> 
> dmesg.txt
> 
> 
> [    0.000000] microcode: microcode updated early to revision 0x24, date = 2018-01-21
> [    0.000000] Linux version 4.18.0-0.rc7.git1.1.fc29.x86_64 (mockbuild@bkernel02.phx2.fedoraproject.org) (gcc version 8.1.1 20180712 (Red Hat 8.1.1-5) (GCC)) #1 SMP Wed Aug 1 16:46:20 UTC 2018
> [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.18.0-0.rc7.git1.1.fc29.x86_64 root=UUID=39a0294f-c142-4c51-a296-e353eb7dc769 ro resume=UUID=c9fe1762-52ba-4754-89c2-3f66f5b8a2ed rhgb quiet LANG=en_US.UTF-8
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
> [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000057fff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000000058000-0x0000000000058fff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000059000-0x000000000009efff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009f000-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bd69efff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000bd69f000-0x00000000bd6a5fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000bd6a6000-0x00000000be17bfff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000be17c000-0x00000000be6d4fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000be6d5000-0x00000000db487fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000db488000-0x00000000db8e8fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000db8e9000-0x00000000db931fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000db932000-0x00000000db9edfff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000db9ee000-0x00000000df7fefff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000df7ff000-0x00000000df7fffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000081effffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] e820: update [mem 0xbd350018-0xbd360857] usable ==> usable
> [    0.000000] e820: update [mem 0xbd350018-0xbd360857] usable ==> usable
> [    0.000000] e820: update [mem 0xbd336018-0xbd34f457] usable ==> usable
> [    0.000000] e820: update [mem 0xbd336018-0xbd34f457] usable ==> usable
> [    0.000000] extended physical RAM map:
> [    0.000000] reserve setup_data: [mem 0x0000000000000000-0x0000000000057fff] usable
> [    0.000000] reserve setup_data: [mem 0x0000000000058000-0x0000000000058fff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000000059000-0x000000000009efff] usable
> [    0.000000] reserve setup_data: [mem 0x000000000009f000-0x000000000009ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000000100000-0x00000000bd336017] usable
> [    0.000000] reserve setup_data: [mem 0x00000000bd336018-0x00000000bd34f457] usable
> [    0.000000] reserve setup_data: [mem 0x00000000bd34f458-0x00000000bd350017] usable
> [    0.000000] reserve setup_data: [mem 0x00000000bd350018-0x00000000bd360857] usable
> [    0.000000] reserve setup_data: [mem 0x00000000bd360858-0x00000000bd69efff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000bd69f000-0x00000000bd6a5fff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x00000000bd6a6000-0x00000000be17bfff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000be17c000-0x00000000be6d4fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000be6d5000-0x00000000db487fff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000db488000-0x00000000db8e8fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000db8e9000-0x00000000db931fff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000db932000-0x00000000db9edfff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x00000000db9ee000-0x00000000df7fefff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000df7ff000-0x00000000df7fffff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000100000000-0x000000081effffff] usable
> [    0.000000] efi: EFI v2.31 by American Megatrends
> [    0.000000] efi:  ACPI=0xdb9ba000  ACPI 2.0=0xdb9ba000  SMBIOS=0xf04c0  MPS=0xfd450 
> [    0.000000] secureboot: Secure boot disabled
> [    0.000000] SMBIOS 2.7 present.
> [    0.000000] DMI: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] last_pfn = 0x81f000 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-CFFFF write-protect
> [    0.000000]   D0000-DFFFF uncachable
> [    0.000000]   E0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0000000000 mask 7800000000 write-back
> [    0.000000]   1 base 0800000000 mask 7FF0000000 write-back
> [    0.000000]   2 base 0810000000 mask 7FF8000000 write-back
> [    0.000000]   3 base 0818000000 mask 7FFC000000 write-back
> [    0.000000]   4 base 081C000000 mask 7FFE000000 write-back
> [    0.000000]   5 base 081E000000 mask 7FFF000000 write-back
> [    0.000000]   6 base 00E0000000 mask 7FE0000000 uncachable
> [    0.000000]   7 disabled
> [    0.000000]   8 disabled
> [    0.000000]   9 disabled
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
> [    0.000000] e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
> [    0.000000] last_pfn = 0xdf800 max_arch_pfn = 0x400000000
> [    0.000000] found SMP MP-table at [mem 0x000fd750-0x000fd75f] mapped at [(____ptrval____)]
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] Base memory trampoline at [(____ptrval____)] 97000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] BRK [0x74c244000, 0x74c244fff] PGTABLE
> [    0.000000] BRK [0x74c245000, 0x74c245fff] PGTABLE
> [    0.000000] BRK [0x74c246000, 0x74c246fff] PGTABLE
> [    0.000000] BRK [0x74c247000, 0x74c247fff] PGTABLE
> [    0.000000] BRK [0x74c248000, 0x74c248fff] PGTABLE
> [    0.000000] BRK [0x74c249000, 0x74c249fff] PGTABLE
> [    0.000000] BRK [0x74c24a000, 0x74c24afff] PGTABLE
> [    0.000000] BRK [0x74c24b000, 0x74c24bfff] PGTABLE
> [    0.000000] BRK [0x74c24c000, 0x74c24cfff] PGTABLE
> [    0.000000] BRK [0x74c24d000, 0x74c24dfff] PGTABLE
> [    0.000000] BRK [0x74c24e000, 0x74c24efff] PGTABLE
> [    0.000000] BRK [0x74c24f000, 0x74c24ffff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x3b383000-0x3cd8efff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000DB9BA000 000024 (v02 ALASKA)
> [    0.000000] ACPI: XSDT 0x00000000DB9BA080 00007C (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FACP 0x00000000DB9C6E20 00010C (v05 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: DSDT 0x00000000DB9BA190 00CC8D (v02 ALASKA A M I    00000088 INTL 20091112)
> [    0.000000] ACPI: FACS 0x00000000DB9EC080 000040
> [    0.000000] ACPI: APIC 0x00000000DB9C6F30 000092 (v03 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FPDT 0x00000000DB9C6FC8 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: SSDT 0x00000000DB9C7010 000539 (v01 PmRef  Cpu0Ist  00003000 INTL 20120711)
> [    0.000000] ACPI: SSDT 0x00000000DB9C7550 000AD8 (v01 PmRef  CpuPm    00003000 INTL 20120711)
> [    0.000000] ACPI: SSDT 0x00000000DB9C8028 0001C7 (v01 PmRef  LakeTiny 00003000 INTL 20120711)
> [    0.000000] ACPI: MCFG 0x00000000DB9C81F0 00003C (v01 ALASKA A M I    01072009 MSFT 00000097)
> [    0.000000] ACPI: HPET 0x00000000DB9C8230 000038 (v01 ALASKA A M I    01072009 AMI. 00000005)
> [    0.000000] ACPI: SSDT 0x00000000DB9C8268 00036D (v01 SataRe SataTabl 00001000 INTL 20120711)
> [    0.000000] ACPI: SSDT 0x00000000DB9C85D8 0034E1 (v01 SaSsdt SaSsdt   00003000 INTL 20091112)
> [    0.000000] ACPI: DMAR 0x00000000DB9CBAC0 000070 (v01 INTEL  HSW      00000001 INTL 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000081effffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x81efd4000-0x81effefff]
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000000081effffff]
> [    0.000000]   Device   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x0000000000057fff]
> [    0.000000]   node   0: [mem 0x0000000000059000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bd69efff]
> [    0.000000]   node   0: [mem 0x00000000bd6a6000-0x00000000be17bfff]
> [    0.000000]   node   0: [mem 0x00000000be6d5000-0x00000000db487fff]
> [    0.000000]   node   0: [mem 0x00000000db8e9000-0x00000000db931fff]
> [    0.000000]   node   0: [mem 0x00000000df7ff000-0x00000000df7fffff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x000000081effffff]
> [    0.000000] Reserved but unavailable: 20721 pages
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000081effffff]
> [    0.000000] On node 0 totalpages: 8363791
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 24 pages reserved
> [    0.000000]   DMA zone: 3997 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 13950 pages used for memmap
> [    0.000000]   DMA32 zone: 892786 pages, LIFO batch:31
> [    0.000000]   Normal zone: 116672 pages used for memmap
> [    0.000000]   Normal zone: 7467008 pages, LIFO batch:31
> [    0.000000] ACPI: PM-Timer IO Port: 0x1808
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
> [    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
> [    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x00058000-0x00058fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbd336000-0xbd336fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbd34f000-0xbd34ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbd350000-0xbd350fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbd360000-0xbd360fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbd69f000-0xbd6a5fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xbe17c000-0xbe6d4fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb488000-0xdb8e8fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb932000-0xdb9edfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb9ee000-0xdf7fefff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdf800000-0xf7ffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfecfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed03fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed04000-0xfed1bfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xfeffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
> [    0.000000] [mem 0xdf800000-0xf7ffffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
> [    0.000000] random: get_random_bytes called from start_kernel+0x9d/0x587 with crng_init=0
> [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
> [    0.000000] percpu: Embedded 494 pages/cpu @(____ptrval____) s1986560 r8192 d28672 u2097152
> [    0.000000] pcpu-alloc: s1986560 r8192 d28672 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 [0] 4 [0] 5 [0] 6 [0] 7 
> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 8233081
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.18.0-0.rc7.git1.1.fc29.x86_64 root=UUID=39a0294f-c142-4c51-a296-e353eb7dc769 ro resume=UUID=c9fe1762-52ba-4754-89c2-3f66f5b8a2ed rhgb quiet LANG=en_US.UTF-8
> [    0.000000] Memory: 32537560K/33455164K available (14348K kernel code, 3811K rwdata, 4420K rodata, 4824K init, 16396K bss, 917604K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
> [    0.000000] Kernel/User page tables isolation: enabled
> [    0.000000] ftrace: allocating 38393 entries in 150 pages
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU lockdep checking is enabled.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=8.
> [    0.000000] 	RCU callback double-/use-after-free debug enabled.
> [    0.000000] 	Tasks RCU enabled.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=8
> [    0.000000] NR_IRQS: 524544, nr_irqs: 488, preallocated irqs: 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 7903 kB
> [    0.000000]  per task-struct memory footprint: 2688 bytes
> [    0.000000] kmemleak: Kernel memory leak detector disabled
> [    0.000000] ACPI: Core revision 20180531
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] APIC: Switch to symmetric I/O mode setup
> [    0.000000] DMAR: Host address width 39
> [    0.000000] DMAR: DRHD base: 0x000000fed90000 flags: 0x1
> [    0.000000] DMAR: dmar0: reg_base_addr fed90000 ver 1:0 cap d2008c20660462 ecap f010da
> [    0.000000] DMAR: RMRR base: 0x000000df683000 end: 0x000000df691fff
> [    0.000000] DMAR-IR: IOAPIC id 8 under DRHD base  0xfed90000 IOMMU 0
> [    0.000000] DMAR-IR: HPET id 0 under DRHD base 0xfed90000
> [    0.000000] DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
> [    0.000000] DMAR-IR: Enabled IRQ remapping in x2apic mode
> [    0.000000] x2apic enabled
> [    0.000000] Switched APIC routing to cluster x2apic.
> [    0.000000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.005000] tsc: Fast TSC calibration using PIT
> [    0.006000] tsc: Detected 3392.299 MHz processor
> [    0.006000] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x30e5e400a52, max_idle_ns: 440795286932 ns
> [    0.006000] Calibrating delay loop (skipped), value calculated using timer frequency.. 6784.59 BogoMIPS (lpj=3392299)
> [    0.006000] pid_max: default: 32768 minimum: 301
> [    0.006000] ---[ User Space ]---
> [    0.006000] 0x0000000000000000-0x0000000000008000          32K     RW                     x  pte
> [    0.006000] 0x0000000000008000-0x000000000005f000         348K                               pte
> [    0.006000] 0x000000000005f000-0x000000000009f000         256K     RW                     x  pte
> [    0.006000] 0x000000000009f000-0x0000000000200000        1412K                               pte
> [    0.006000] 0x0000000000200000-0x0000000040000000        1022M                               pmd
> [    0.006000] 0x0000000040000000-0x0000000080000000           1G                               pud
> [    0.006000] 0x0000000080000000-0x00000000bd600000         982M                               pmd
> [    0.006000] 0x00000000bd600000-0x00000000bd6a6000         664K                               pte
> [    0.006000] 0x00000000bd6a6000-0x00000000bda00000        3432K     RW                     x  pte
> [    0.006000] 0x00000000bda00000-0x00000000be000000           6M     RW         PSE         x  pmd
> [    0.006000] 0x00000000be000000-0x00000000be200000           2M     RW                     x  pte
> [    0.006000] 0x00000000be200000-0x00000000be600000           4M     RW         PSE         x  pmd
> [    0.006000] 0x00000000be600000-0x00000000be710000        1088K     RW                     x  pte
> [    0.006000] 0x00000000be710000-0x00000000be800000         960K                               pte
> [    0.006000] 0x00000000be800000-0x00000000cc600000         222M                               pmd
> [    0.006000] 0x00000000cc600000-0x00000000cc703000        1036K                               pte
> [    0.006000] 0x00000000cc703000-0x00000000cc745000         264K     RW                     x  pte
> [    0.006000] 0x00000000cc745000-0x00000000cc755000          64K                               pte
> [    0.006000] 0x00000000cc755000-0x00000000cc788000         204K     RW                     x  pte
> [    0.006000] 0x00000000cc788000-0x00000000cc795000          52K                               pte
> [    0.006000] 0x00000000cc795000-0x00000000cc7f3000         376K     RW                     x  pte
> [    0.006000] 0x00000000cc7f3000-0x00000000cc80c000         100K                               pte
> [    0.006000] 0x00000000cc80c000-0x00000000cc866000         360K     RW                     x  pte
> [    0.006000] 0x00000000cc866000-0x00000000cc87c000          88K                               pte
> [    0.006000] 0x00000000cc87c000-0x00000000cc8ec000         448K     RW                     x  pte
> [    0.006000] 0x00000000cc8ec000-0x00000000cc91d000         196K                               pte
> [    0.006000] 0x00000000cc91d000-0x00000000cc993000         472K     RW                     x  pte
> [    0.006000] 0x00000000cc993000-0x00000000cc9c1000         184K                               pte
> [    0.006000] 0x00000000cc9c1000-0x00000000cc9dd000         112K     RW                     x  pte
> [    0.006000] 0x00000000cc9dd000-0x00000000ccaca000         948K                               pte
> [    0.006000] 0x00000000ccaca000-0x00000000ccacd000          12K     RW                     x  pte
> [    0.006000] 0x00000000ccacd000-0x00000000ccad4000          28K                               pte
> [    0.006000] 0x00000000ccad4000-0x00000000ccad5000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccad5000-0x00000000ccaf7000         136K                               pte
> [    0.006000] 0x00000000ccaf7000-0x00000000ccaf8000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccaf8000-0x00000000ccc03000        1068K                               pte
> [    0.006000] 0x00000000ccc03000-0x00000000ccc04000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccc04000-0x00000000ccc05000           4K                               pte
> [    0.006000] 0x00000000ccc05000-0x00000000ccc2e000         164K     RW                     x  pte
> [    0.006000] 0x00000000ccc2e000-0x00000000ccc5a000         176K                               pte
> [    0.006000] 0x00000000ccc5a000-0x00000000ccc5b000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccc5b000-0x00000000ccc94000         228K                               pte
> [    0.006000] 0x00000000ccc94000-0x00000000ccc95000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccc95000-0x00000000cccec000         348K                               pte
> [    0.006000] 0x00000000cccec000-0x00000000ccced000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccced000-0x00000000ccd33000         280K                               pte
> [    0.006000] 0x00000000ccd33000-0x00000000ccd34000           4K     RW                     x  pte
> [    0.006000] 0x00000000ccd34000-0x00000000ccda7000         460K                               pte
> [    0.006000] 0x00000000ccda7000-0x00000000cce4d000         664K     RW                     x  pte
> [    0.006000] 0x00000000cce4d000-0x00000000cce94000         284K                               pte
> [    0.006000] 0x00000000cce94000-0x00000000cce98000          16K     RW                     x  pte
> [    0.006000] 0x00000000cce98000-0x00000000ccfd1000        1252K                               pte
> [    0.006000] 0x00000000ccfd1000-0x00000000ccffa000         164K     RW                     x  pte
> [    0.006000] 0x00000000ccffa000-0x00000000cd0af000         724K                               pte
> [    0.006000] 0x00000000cd0af000-0x00000000cd188000         868K     RW                     x  pte
> [    0.006000] 0x00000000cd188000-0x00000000cd217000         572K                               pte
> [    0.006000] 0x00000000cd217000-0x00000000cd2a0000         548K     RW                     x  pte
> [    0.006000] 0x00000000cd2a0000-0x00000000cd2b0000          64K                               pte
> [    0.006000] 0x00000000cd2b0000-0x00000000cd2e4000         208K     RW                     x  pte
> [    0.006000] 0x00000000cd2e4000-0x00000000cd2f1000          52K                               pte
> [    0.006000] 0x00000000cd2f1000-0x00000000cd34e000         372K     RW                     x  pte
> [    0.006000] 0x00000000cd34e000-0x00000000cd367000         100K                               pte
> [    0.006000] 0x00000000cd367000-0x00000000cd3c1000         360K     RW                     x  pte
> [    0.006000] 0x00000000cd3c1000-0x00000000cd3d7000          88K                               pte
> [    0.006000] 0x00000000cd3d7000-0x00000000cd4f0000        1124K     RW                     x  pte
> [    0.006000] 0x00000000cd4f0000-0x00000000cd51e000         184K                               pte
> [    0.006000] 0x00000000cd51e000-0x00000000cd53d000         124K     RW                     x  pte
> [    0.006000] 0x00000000cd53d000-0x00000000cd54e000          68K                               pte
> [    0.006000] 0x00000000cd54e000-0x00000000cd5b1000         396K     RW                     x  pte
> [    0.006000] 0x00000000cd5b1000-0x00000000cd5cc000         108K                               pte
> [    0.006000] 0x00000000cd5cc000-0x00000000cd674000         672K     RW                     x  pte
> [    0.006000] 0x00000000cd674000-0x00000000cd684000          64K                               pte
> [    0.006000] 0x00000000cd684000-0x00000000cd6b7000         204K     RW                     x  pte
> [    0.006000] 0x00000000cd6b7000-0x00000000cd6c4000          52K                               pte
> [    0.006000] 0x00000000cd6c4000-0x00000000cd721000         372K     RW                     x  pte
> [    0.006000] 0x00000000cd721000-0x00000000cd73a000         100K                               pte
> [    0.006000] 0x00000000cd73a000-0x00000000cd794000         360K     RW                     x  pte
> [    0.006000] 0x00000000cd794000-0x00000000cd7aa000          88K                               pte
> [    0.006000] 0x00000000cd7aa000-0x00000000cd81a000         448K     RW                     x  pte
> [    0.007009] 0x00000000cd81a000-0x00000000cd84b000         196K                               pte
> [    0.007014] 0x00000000cd84b000-0x00000000cd8c1000         472K     RW                     x  pte
> [    0.007025] 0x00000000cd8c1000-0x00000000cd8c8000          28K                               pte
> [    0.007032] 0x00000000cd8c8000-0x00000000cda3f000        1500K     RW                     x  pte
> [    0.007043] 0x00000000cda3f000-0x00000000cda42000          12K                               pte
> [    0.007049] 0x00000000cda42000-0x00000000cdb60000        1144K     RW                     x  pte
> [    0.007060] 0x00000000cdb60000-0x00000000cdb69000          36K                               pte
> [    0.007068] 0x00000000cdb69000-0x00000000cdd72000        2084K     RW                     x  pte
> [    0.007079] 0x00000000cdd72000-0x00000000cdd75000          12K                               pte
> [    0.007085] 0x00000000cdd75000-0x00000000cdeb9000        1296K     RW                     x  pte
> [    0.007096] 0x00000000cdeb9000-0x00000000cdec2000          36K                               pte
> [    0.007101] 0x00000000cdec2000-0x00000000cdf2b000         420K     RW                     x  pte
> [    0.007112] 0x00000000cdf2b000-0x00000000cdf34000          36K                               pte
> [    0.007117] 0x00000000cdf34000-0x00000000cdfb1000         500K     RW                     x  pte
> [    0.007129] 0x00000000cdfb1000-0x00000000cdfb4000          12K                               pte
> [    0.007134] 0x00000000cdfb4000-0x00000000ce059000         660K     RW                     x  pte
> [    0.007145] 0x00000000ce059000-0x00000000ce05e000          20K                               pte
> [    0.007151] 0x00000000ce05e000-0x00000000ce17e000        1152K     RW                     x  pte
> [    0.007162] 0x00000000ce17e000-0x00000000ce17f000           4K                               pte
> [    0.007169] 0x00000000ce17f000-0x00000000ce331000        1736K     RW                     x  pte
> [    0.007181] 0x00000000ce331000-0x00000000ce33a000          36K                               pte
> [    0.007186] 0x00000000ce33a000-0x00000000ce3b6000         496K     RW                     x  pte
> [    0.007197] 0x00000000ce3b6000-0x00000000ce3b9000          12K                               pte
> [    0.007202] 0x00000000ce3b9000-0x00000000ce45d000         656K     RW                     x  pte
> [    0.007213] 0x00000000ce45d000-0x00000000ce465000          32K                               pte
> [    0.007220] 0x00000000ce465000-0x00000000ce5bc000        1372K     RW                     x  pte
> [    0.007231] 0x00000000ce5bc000-0x00000000ce5c6000          40K                               pte
> [    0.007236] 0x00000000ce5c6000-0x00000000ce649000         524K     RW                     x  pte
> [    0.007247] 0x00000000ce649000-0x00000000ce64c000          12K                               pte
> [    0.007252] 0x00000000ce64c000-0x00000000ce652000          24K     RW                     x  pte
> [    0.007263] 0x00000000ce652000-0x00000000ce65a000          32K                               pte
> [    0.007268] 0x00000000ce65a000-0x00000000ce727000         820K     RW                     x  pte
> [    0.007280] 0x00000000ce727000-0x00000000ce72c000          20K                               pte
> [    0.007284] 0x00000000ce72c000-0x00000000ce731000          20K     RW                     x  pte
> [    0.007295] 0x00000000ce731000-0x00000000ce737000          24K                               pte
> [    0.007300] 0x00000000ce737000-0x00000000ce73c000          20K     RW                     x  pte
> [    0.007311] 0x00000000ce73c000-0x00000000ce746000          40K                               pte
> [    0.007316] 0x00000000ce746000-0x00000000ce800000         744K     RW                     x  pte
> [    0.007328] 0x00000000ce800000-0x00000000cf000000           8M     RW         PSE         x  pmd
> [    0.007339] 0x00000000cf000000-0x00000000cf02d000         180K     RW                     x  pte
> [    0.007351] 0x00000000cf02d000-0x00000000cf031000          16K                               pte
> [    0.007357] 0x00000000cf031000-0x00000000cf200000        1852K     RW                     x  pte
> [    0.007369] 0x00000000cf200000-0x00000000d8800000         150M     RW         PSE         x  pmd
> [    0.007381] 0x00000000d8800000-0x00000000d8872000         456K     RW                     x  pte
> [    0.007392] 0x00000000d8872000-0x00000000d8875000          12K                               pte
> [    0.007397] 0x00000000d8875000-0x00000000d887e000          36K     RW                     x  pte
> [    0.007408] 0x00000000d887e000-0x00000000d8881000          12K                               pte
> [    0.007412] 0x00000000d8881000-0x00000000d8889000          32K     RW                     x  pte
> [    0.007423] 0x00000000d8889000-0x00000000d888c000          12K                               pte
> [    0.007428] 0x00000000d888c000-0x00000000d8895000          36K     RW                     x  pte
> [    0.007439] 0x00000000d8895000-0x00000000d8898000          12K                               pte
> [    0.007445] 0x00000000d8898000-0x00000000d8a00000        1440K     RW                     x  pte
> [    0.007457] 0x00000000d8a00000-0x00000000da400000          26M     RW         PSE         x  pmd
> [    0.007469] 0x00000000da400000-0x00000000da503000        1036K     RW                     x  pte
> [    0.007482] 0x00000000da503000-0x00000000da600000        1012K                               pte
> [    0.007487] 0x00000000da600000-0x00000000db000000          10M                               pmd
> [    0.007493] 0x00000000db000000-0x00000000db191000        1604K                               pte
> [    0.007498] 0x00000000db191000-0x00000000db200000         444K     RW                     x  pte
> [    0.007509] 0x00000000db200000-0x00000000db400000           2M     RW         PSE         x  pmd
> [    0.007521] 0x00000000db400000-0x00000000db488000         544K     RW                     x  pte
> [    0.007535] 0x00000000db488000-0x00000000db600000        1504K                               pte
> [    0.007539] 0x00000000db600000-0x00000000db800000           2M                               pmd
> [    0.007546] 0x00000000db800000-0x00000000db9ee000        1976K                               pte
> [    0.007551] 0x00000000db9ee000-0x00000000dba00000          72K     RW                     x  pte
> [    0.007562] 0x00000000dba00000-0x00000000df600000          60M     RW         PSE         x  pmd
> [    0.007576] 0x00000000df600000-0x00000000df800000           2M     RW                     x  pte
> [    0.007588] 0x00000000df800000-0x00000000f8000000         392M                               pmd
> [    0.007593] 0x00000000f8000000-0x00000000fc000000          64M     RW     PCD PSE         x  pmd
> [    0.007604] 0x00000000fc000000-0x00000000fec00000          44M                               pmd
> [    0.007608] 0x00000000fec00000-0x00000000fec01000           4K     RW     PCD             x  pte
> [    0.007621] 0x00000000fec01000-0x00000000fed00000        1020K                               pte
> [    0.007626] 0x00000000fed00000-0x00000000fed04000          16K     RW     PCD             x  pte
> [    0.007637] 0x00000000fed04000-0x00000000fed1c000          96K                               pte
> [    0.007641] 0x00000000fed1c000-0x00000000fed20000          16K     RW     PCD             x  pte
> [    0.007654] 0x00000000fed20000-0x00000000fee00000         896K                               pte
> [    0.007658] 0x00000000fee00000-0x00000000fee01000           4K     RW     PCD             x  pte
> [    0.007672] 0x00000000fee01000-0x00000000ff000000        2044K                               pte
> [    0.007677] 0x00000000ff000000-0x0000000100000000          16M     RW     PCD PSE         x  pmd
> [    0.007688] 0x0000000100000000-0x00000007c0000000          27G                               pud
> [    0.007694] 0x00000007c0000000-0x00000007fd000000         976M                               pmd
> [    0.007701] 0x00000007fd000000-0x00000007fd17a000        1512K                               pte
> [    0.007705] 0x00000007fd17a000-0x00000007fd17c000           8K     RW                     NX pte
> [    0.007717] 0x00000007fd17c000-0x00000007fd200000         528K                               pte
> [    0.007722] 0x00000007fd200000-0x0000000800000000          46M                               pmd
> [    0.007728] 0x0000000800000000-0x0000008000000000         480G                               pud
> [    0.007736] 0x0000008000000000-0xffff800000000000   17179737600G                               pgd
> [    0.007740] ---[ Kernel Space ]---
> [    0.007742] 0xffff800000000000-0xffff808000000000         512G                               pgd
> [    0.007746] ---[ Low Kernel Mapping ]---
> [    0.007747] 0xffff808000000000-0xffff810000000000         512G                               pgd
> [    0.007752] ---[ vmalloc() Area ]---
> [    0.007753] 0xffff810000000000-0xffff818000000000         512G                               pgd
> [    0.007757] ---[ Vmemmap ]---
> [    0.007759] 0xffff818000000000-0xffff8d8000000000          12T                               pgd
> [    0.007764] 0xffff8d8000000000-0xffff8dc300000000         268G                               pud
> [    0.007771] 0xffff8dc300000000-0xffff8dc300200000           2M     RW                     NX pte
> [    0.007785] 0xffff8dc300200000-0xffff8dc340000000        1022M     RW         PSE         NX pmd
> [    0.007796] 0xffff8dc340000000-0xffff8dc380000000           1G     RW         PSE         NX pud
> [    0.007810] 0xffff8dc380000000-0xffff8dc3bd600000         982M     RW         PSE         NX pmd
> [    0.007822] 0xffff8dc3bd600000-0xffff8dc3bd69f000         636K     RW                     NX pte
> [    0.007833] 0xffff8dc3bd69f000-0xffff8dc3bd6a6000          28K                               pte
> [    0.007839] 0xffff8dc3bd6a6000-0xffff8dc3bd800000        1384K     RW                     NX pte
> [    0.007851] 0xffff8dc3bd800000-0xffff8dc3be000000           8M     RW         PSE         NX pmd
> [    0.007864] 0xffff8dc3be000000-0xffff8dc3be17c000        1520K     RW                     NX pte
> [    0.007876] 0xffff8dc3be17c000-0xffff8dc3be200000         528K                               pte
> [    0.007881] 0xffff8dc3be200000-0xffff8dc3be600000           4M                               pmd
> [    0.007886] 0xffff8dc3be600000-0xffff8dc3be6d5000         852K                               pte
> [    0.007892] 0xffff8dc3be6d5000-0xffff8dc3be800000        1196K     RW                     NX pte
> [    0.007904] 0xffff8dc3be800000-0xffff8dc3db400000         460M     RW         PSE         NX pmd
> [    0.007916] 0xffff8dc3db400000-0xffff8dc3db488000         544K     RW                     NX pte
> [    0.007930] 0xffff8dc3db488000-0xffff8dc3db600000        1504K                               pte
> [    0.007934] 0xffff8dc3db600000-0xffff8dc3db800000           2M                               pmd
> [    0.007940] 0xffff8dc3db800000-0xffff8dc3db8e9000         932K                               pte
> [    0.007945] 0xffff8dc3db8e9000-0xffff8dc3db932000         292K     RW                     NX pte
> [    0.007957] 0xffff8dc3db932000-0xffff8dc3dba00000         824K                               pte
> [    0.007962] 0xffff8dc3dba00000-0xffff8dc3df600000          60M                               pmd
> [    0.007969] 0xffff8dc3df600000-0xffff8dc3df7ff000        2044K                               pte
> [    0.007973] 0xffff8dc3df7ff000-0xffff8dc3df800000           4K     RW                     NX pte
> [    0.007986] 0xffff8dc3df800000-0xffff8dc400000000         520M                               pmd
> [    0.007990] 0xffff8dc400000000-0xffff8dcb00000000          28G     RW         PSE         NX pud
> [    0.008007] 0xffff8dcb00000000-0xffff8dcb1f000000         496M     RW         PSE         NX pmd
> [    0.008019] 0xffff8dcb1f000000-0xffff8dcb40000000         528M                               pmd
> [    0.008024] 0xffff8dcb40000000-0xffff8e0000000000         211G                               pud
> [    0.008029] 0xffff8e0000000000-0xffffb50000000000          39T                               pgd
> [    0.008034] 0xffffb50000000000-0xffffb51ac0000000         107G                               pud
> [    0.008038] 0xffffb51ac0000000-0xffffb51ac0001000           4K     RW                     NX pte
> [    0.008050] 0xffffb51ac0001000-0xffffb51ac0002000           4K                               pte
> [    0.008054] 0xffffb51ac0002000-0xffffb51ac0003000           4K     RW                     NX pte
> [    0.008065] 0xffffb51ac0003000-0xffffb51ac0004000           4K                               pte
> [    0.008070] 0xffffb51ac0004000-0xffffb51ac0006000           8K     RW                     NX pte
> [    0.008081] 0xffffb51ac0006000-0xffffb51ac0008000           8K                               pte
> [    0.008085] 0xffffb51ac0008000-0xffffb51ac000a000           8K     RW                     NX pte
> [    0.008097] 0xffffb51ac000a000-0xffffb51ac000b000           4K                               pte
> [    0.008101] 0xffffb51ac000b000-0xffffb51ac000c000           4K     RW     PCD             NX pte
> [    0.008112] 0xffffb51ac000c000-0xffffb51ac000d000           4K                               pte
> [    0.008117] 0xffffb51ac000d000-0xffffb51ac000e000           4K     RW     PCD             NX pte
> [    0.008128] 0xffffb51ac000e000-0xffffb51ac0010000           8K                               pte
> [    0.008132] 0xffffb51ac0010000-0xffffb51ac001d000          52K     RW                     NX pte
> [    0.008144] 0xffffb51ac001d000-0xffffb51ac0020000          12K                               pte
> [    0.008148] 0xffffb51ac0020000-0xffffb51ac0024000          16K     RW                     NX pte
> [    0.008162] 0xffffb51ac0024000-0xffffb51ac0200000        1904K                               pte
> [    0.008168] 0xffffb51ac0200000-0xffffb51b00000000        1022M                               pmd
> [    0.008174] 0xffffb51b00000000-0xffffb58000000000         404G                               pud
> [    0.008180] 0xffffb58000000000-0xffffe68000000000          49T                               pgd
> [    0.008184] 0xffffe68000000000-0xffffe68f80000000          62G                               pud
> [    0.008189] 0xffffe68f80000000-0xffffe68f83800000          56M     RW         PSE         NX pmd
> [    0.008200] 0xffffe68f83800000-0xffffe68f84000000           8M                               pmd
> [    0.008205] 0xffffe68f84000000-0xffffe68fa0800000         456M     RW         PSE         NX pmd
> [    0.008218] 0xffffe68fa0800000-0xffffe68fc0000000         504M                               pmd
> [    0.008223] 0xffffe68fc0000000-0xffffe70000000000         449G                               pud
> [    0.008228] 0xffffe70000000000-0xfffffe0000000000          23T                               pgd
> [    0.008233] ---[ CPU entry Area ]---
> [    0.008234] 0xfffffe0000000000-0xfffffe0000001000           4K     ro                 GLB NX pte
> [    0.008245] ---[ LDT remap ]---
> [    0.008246] 0xfffffe0000001000-0xfffffe0000002000           4K     ro                 GLB NX pte
> [    0.008258] 0xfffffe0000002000-0xfffffe0000003000           4K     RW                 GLB NX pte
> [    0.008269] 0xfffffe0000003000-0xfffffe0000006000          12K     ro                 GLB NX pte
> [    0.008280] 0xfffffe0000006000-0xfffffe0000007000           4K     ro                 GLB x  pte
> [    0.008292] 0xfffffe0000007000-0xfffffe000000d000          24K     RW                 GLB NX pte
> [    0.008303] 0xfffffe000000d000-0xfffffe000002d000         128K                               pte
> [    0.008307] 0xfffffe000002d000-0xfffffe000002e000           4K     ro                 GLB NX pte
> [    0.008319] 0xfffffe000002e000-0xfffffe000002f000           4K     RW                 GLB NX pte
> [    0.008330] 0xfffffe000002f000-0xfffffe0000032000          12K     ro                 GLB NX pte
> [    0.008341] 0xfffffe0000032000-0xfffffe0000033000           4K     ro                 GLB x  pte
> [    0.008352] 0xfffffe0000033000-0xfffffe0000039000          24K     RW                 GLB NX pte
> [    0.008364] 0xfffffe0000039000-0xfffffe0000059000         128K                               pte
> [    0.008368] 0xfffffe0000059000-0xfffffe000005a000           4K     ro                 GLB NX pte
> [    0.008380] 0xfffffe000005a000-0xfffffe000005b000           4K     RW                 GLB NX pte
> [    0.008391] 0xfffffe000005b000-0xfffffe000005e000          12K     ro                 GLB NX pte
> [    0.008402] 0xfffffe000005e000-0xfffffe000005f000           4K     ro                 GLB x  pte
> [    0.008413] 0xfffffe000005f000-0xfffffe0000065000          24K     RW                 GLB NX pte
> [    0.008425] 0xfffffe0000065000-0xfffffe0000085000         128K                               pte
> [    0.008429] 0xfffffe0000085000-0xfffffe0000086000           4K     ro                 GLB NX pte
> [    0.008441] 0xfffffe0000086000-0xfffffe0000087000           4K     RW                 GLB NX pte
> [    0.008452] 0xfffffe0000087000-0xfffffe000008a000          12K     ro                 GLB NX pte
> [    0.008463] 0xfffffe000008a000-0xfffffe000008b000           4K     ro                 GLB x  pte
> [    0.008474] 0xfffffe000008b000-0xfffffe0000091000          24K     RW                 GLB NX pte
> [    0.008486] 0xfffffe0000091000-0xfffffe00000b1000         128K                               pte
> [    0.008490] 0xfffffe00000b1000-0xfffffe00000b2000           4K     ro                 GLB NX pte
> [    0.008502] 0xfffffe00000b2000-0xfffffe00000b3000           4K     RW                 GLB NX pte
> [    0.008513] 0xfffffe00000b3000-0xfffffe00000b6000          12K     ro                 GLB NX pte
> [    0.008524] 0xfffffe00000b6000-0xfffffe00000b7000           4K     ro                 GLB x  pte
> [    0.008535] 0xfffffe00000b7000-0xfffffe00000bd000          24K     RW                 GLB NX pte
> [    0.008547] 0xfffffe00000bd000-0xfffffe00000dd000         128K                               pte
> [    0.008551] 0xfffffe00000dd000-0xfffffe00000de000           4K     ro                 GLB NX pte
> [    0.008562] 0xfffffe00000de000-0xfffffe00000df000           4K     RW                 GLB NX pte
> [    0.008574] 0xfffffe00000df000-0xfffffe00000e2000          12K     ro                 GLB NX pte
> [    0.008585] 0xfffffe00000e2000-0xfffffe00000e3000           4K     ro                 GLB x  pte
> [    0.008596] 0xfffffe00000e3000-0xfffffe00000e9000          24K     RW                 GLB NX pte
> [    0.008608] 0xfffffe00000e9000-0xfffffe0000109000         128K                               pte
> [    0.008612] 0xfffffe0000109000-0xfffffe000010a000           4K     ro                 GLB NX pte
> [    0.008623] 0xfffffe000010a000-0xfffffe000010b000           4K     RW                 GLB NX pte
> [    0.008635] 0xfffffe000010b000-0xfffffe000010e000          12K     ro                 GLB NX pte
> [    0.008646] 0xfffffe000010e000-0xfffffe000010f000           4K     ro                 GLB x  pte
> [    0.008657] 0xfffffe000010f000-0xfffffe0000115000          24K     RW                 GLB NX pte
> [    0.008669] 0xfffffe0000115000-0xfffffe0000135000         128K                               pte
> [    0.008673] 0xfffffe0000135000-0xfffffe0000136000           4K     ro                 GLB NX pte
> [    0.008684] 0xfffffe0000136000-0xfffffe0000137000           4K     RW                 GLB NX pte
> [    0.008696] 0xfffffe0000137000-0xfffffe000013a000          12K     ro                 GLB NX pte
> [    0.008707] 0xfffffe000013a000-0xfffffe000013b000           4K     ro                 GLB x  pte
> [    0.008718] 0xfffffe000013b000-0xfffffe0000141000          24K     RW                 GLB NX pte
> [    0.008730] 0xfffffe0000141000-0xfffffe0000161000         128K                               pte
> [    0.008735] 0xfffffe0000161000-0xfffffe0000200000         636K                               pte
> [    0.008741] 0xfffffe0000200000-0xfffffe0040000000        1022M                               pmd
> [    0.008747] 0xfffffe0040000000-0xfffffe8000000000         511G                               pud
> [    0.008752] 0xfffffe8000000000-0xffffff0000000000         512G                               pgd
> [    0.008756] ---[ ESPfix Area ]---
> [    0.008758] 0xffffff0000000000-0xffffff3b00000000         236G                               pud
> [    0.008762] 0xffffff3b00000000-0xffffff3b00005000          20K                               pte
> [    0.008767] 0xffffff3b00005000-0xffffff3b00006000           4K     ro                 GLB NX pte
> [    0.008778] 0xffffff3b00006000-0xffffff3b00015000          60K                               pte
> [    0.008782] 0xffffff3b00015000-0xffffff3b00016000           4K     ro                 GLB NX pte
> [    0.008794] 0xffffff3b00016000-0xffffff3b00025000          60K                               pte
> [    0.008798] 0xffffff3b00025000-0xffffff3b00026000           4K     ro                 GLB NX pte
> [    0.008809] 0xffffff3b00026000-0xffffff3b00035000          60K                               pte
> [    0.008814] 0xffffff3b00035000-0xffffff3b00036000           4K     ro                 GLB NX pte
> [    0.008825] 0xffffff3b00036000-0xffffff3b00045000          60K                               pte
> [    0.008830] 0xffffff3b00045000-0xffffff3b00046000           4K     ro                 GLB NX pte
> [    0.008841] 0xffffff3b00046000-0xffffff3b00055000          60K                               pte
> [    0.008845] 0xffffff3b00055000-0xffffff3b00056000           4K     ro                 GLB NX pte
> [    0.008857] 0xffffff3b00056000-0xffffff3b00065000          60K                               pte
> [    0.008861] 0xffffff3b00065000-0xffffff3b00066000           4K     ro                 GLB NX pte
> [    0.008994] 0xffffff3b00066000-0xffffff3b00075000          60K                               pte
> [    0.015788] ... 131059 entries skipped ... 
> [    0.015789] ---[ EFI Runtime Services ]---
> [    0.015790] 0xffffffef00000000-0xfffffffec0000000          63G                               pud
> [    0.015796] 0xfffffffec0000000-0xfffffffee7800000         632M                               pmd
> [    0.015800] 0xfffffffee7800000-0xfffffffee7808000          32K     RW                     x  pte
> [    0.015812] 0xfffffffee7808000-0xfffffffee785f000         348K                               pte
> [    0.015817] 0xfffffffee785f000-0xfffffffee789f000         256K     RW                     x  pte
> [    0.015828] 0xfffffffee789f000-0xfffffffee78a6000          28K                               pte
> [    0.015837] 0xfffffffee78a6000-0xfffffffee7c00000        3432K     RW                     x  pte
> [    0.015849] 0xfffffffee7c00000-0xfffffffee8200000           6M     RW         PSE         x  pmd
> [    0.015863] 0xfffffffee8200000-0xfffffffee8400000           2M     RW                     x  pte
> [    0.015874] 0xfffffffee8400000-0xfffffffee8800000           4M     RW         PSE         x  pmd
> [    0.015887] 0xfffffffee8800000-0xfffffffee8910000        1088K     RW                     x  pte
> [    0.015901] 0xfffffffee8910000-0xfffffffee8b03000        1996K                               pte
> [    0.015906] 0xfffffffee8b03000-0xfffffffee8b45000         264K     RW                     x  pte
> [    0.015917] 0xfffffffee8b45000-0xfffffffee8b55000          64K                               pte
> [    0.015922] 0xfffffffee8b55000-0xfffffffee8b88000         204K     RW                     x  pte
> [    0.015933] 0xfffffffee8b88000-0xfffffffee8b95000          52K                               pte
> [    0.015938] 0xfffffffee8b95000-0xfffffffee8bf3000         376K     RW                     x  pte
> [    0.015949] 0xfffffffee8bf3000-0xfffffffee8c0c000         100K                               pte
> [    0.015954] 0xfffffffee8c0c000-0xfffffffee8c66000         360K     RW                     x  pte
> [    0.015966] 0xfffffffee8c66000-0xfffffffee8c7c000          88K                               pte
> [    0.015970] 0xfffffffee8c7c000-0xfffffffee8cec000         448K     RW                     x  pte
> [    0.015982] 0xfffffffee8cec000-0xfffffffee8d1d000         196K                               pte
> [    0.015987] 0xfffffffee8d1d000-0xfffffffee8d93000         472K     RW                     x  pte
> [    0.016001] 0xfffffffee8d93000-0xfffffffee8dc1000         184K                               pte
> [    0.016006] 0xfffffffee8dc1000-0xfffffffee8ddd000         112K     RW                     x  pte
> [    0.016018] 0xfffffffee8ddd000-0xfffffffee8eca000         948K                               pte
> [    0.016023] 0xfffffffee8eca000-0xfffffffee8ecd000          12K     RW                     x  pte
> [    0.016034] 0xfffffffee8ecd000-0xfffffffee8ed4000          28K                               pte
> [    0.016039] 0xfffffffee8ed4000-0xfffffffee8ed5000           4K     RW                     x  pte
> [    0.016050] 0xfffffffee8ed5000-0xfffffffee8ef7000         136K                               pte
> [    0.016054] 0xfffffffee8ef7000-0xfffffffee8ef8000           4K     RW                     x  pte
> [    0.016067] 0xfffffffee8ef8000-0xfffffffee9003000        1068K                               pte
> [    0.016071] 0xfffffffee9003000-0xfffffffee9004000           4K     RW                     x  pte
> [    0.016083] 0xfffffffee9004000-0xfffffffee9005000           4K                               pte
> [    0.016087] 0xfffffffee9005000-0xfffffffee902e000         164K     RW                     x  pte
> [    0.016099] 0xfffffffee902e000-0xfffffffee905a000         176K                               pte
> [    0.016103] 0xfffffffee905a000-0xfffffffee905b000           4K     RW                     x  pte
> [    0.016115] 0xfffffffee905b000-0xfffffffee9094000         228K                               pte
> [    0.016119] 0xfffffffee9094000-0xfffffffee9095000           4K     RW                     x  pte
> [    0.016131] 0xfffffffee9095000-0xfffffffee90ec000         348K                               pte
> [    0.016135] 0xfffffffee90ec000-0xfffffffee90ed000           4K     RW                     x  pte
> [    0.016147] 0xfffffffee90ed000-0xfffffffee9133000         280K                               pte
> [    0.016151] 0xfffffffee9133000-0xfffffffee9134000           4K     RW                     x  pte
> [    0.016163] 0xfffffffee9134000-0xfffffffee91a7000         460K                               pte
> [    0.016168] 0xfffffffee91a7000-0xfffffffee924d000         664K     RW                     x  pte
> [    0.016180] 0xfffffffee924d000-0xfffffffee9294000         284K                               pte
> [    0.016184] 0xfffffffee9294000-0xfffffffee9298000          16K     RW                     x  pte
> [    0.016197] 0xfffffffee9298000-0xfffffffee93d1000        1252K                               pte
> [    0.016202] 0xfffffffee93d1000-0xfffffffee93fa000         164K     RW                     x  pte
> [    0.016214] 0xfffffffee93fa000-0xfffffffee94af000         724K                               pte
> [    0.016220] 0xfffffffee94af000-0xfffffffee9588000         868K     RW                     x  pte
> [    0.016232] 0xfffffffee9588000-0xfffffffee9617000         572K                               pte
> [    0.016237] 0xfffffffee9617000-0xfffffffee96a0000         548K     RW                     x  pte
> [    0.016248] 0xfffffffee96a0000-0xfffffffee96b0000          64K                               pte
> [    0.016253] 0xfffffffee96b0000-0xfffffffee96e4000         208K     RW                     x  pte
> [    0.016264] 0xfffffffee96e4000-0xfffffffee96f1000          52K                               pte
> [    0.016269] 0xfffffffee96f1000-0xfffffffee974e000         372K     RW                     x  pte
> [    0.016281] 0xfffffffee974e000-0xfffffffee9767000         100K                               pte
> [    0.016285] 0xfffffffee9767000-0xfffffffee97c1000         360K     RW                     x  pte
> [    0.016297] 0xfffffffee97c1000-0xfffffffee97d7000          88K                               pte
> [    0.016303] 0xfffffffee97d7000-0xfffffffee98f0000        1124K     RW                     x  pte
> [    0.016314] 0xfffffffee98f0000-0xfffffffee991e000         184K                               pte
> [    0.016319] 0xfffffffee991e000-0xfffffffee993d000         124K     RW                     x  pte
> [    0.016330] 0xfffffffee993d000-0xfffffffee994e000          68K                               pte
> [    0.016335] 0xfffffffee994e000-0xfffffffee99b1000         396K     RW                     x  pte
> [    0.016346] 0xfffffffee99b1000-0xfffffffee99cc000         108K                               pte
> [    0.016352] 0xfffffffee99cc000-0xfffffffee9a74000         672K     RW                     x  pte
> [    0.016363] 0xfffffffee9a74000-0xfffffffee9a84000          64K                               pte
> [    0.016368] 0xfffffffee9a84000-0xfffffffee9ab7000         204K     RW                     x  pte
> [    0.016379] 0xfffffffee9ab7000-0xfffffffee9ac4000          52K                               pte
> [    0.016384] 0xfffffffee9ac4000-0xfffffffee9b21000         372K     RW                     x  pte
> [    0.016395] 0xfffffffee9b21000-0xfffffffee9b3a000         100K                               pte
> [    0.016400] 0xfffffffee9b3a000-0xfffffffee9b94000         360K     RW                     x  pte
> [    0.016411] 0xfffffffee9b94000-0xfffffffee9baa000          88K                               pte
> [    0.016416] 0xfffffffee9baa000-0xfffffffee9c1a000         448K     RW                     x  pte
> [    0.016428] 0xfffffffee9c1a000-0xfffffffee9c4b000         196K                               pte
> [    0.016433] 0xfffffffee9c4b000-0xfffffffee9cc1000         472K     RW                     x  pte
> [    0.016444] 0xfffffffee9cc1000-0xfffffffee9cc8000          28K                               pte
> [    0.016451] 0xfffffffee9cc8000-0xfffffffee9e3f000        1500K     RW                     x  pte
> [    0.016462] 0xfffffffee9e3f000-0xfffffffee9e42000          12K                               pte
> [    0.016468] 0xfffffffee9e42000-0xfffffffee9f60000        1144K     RW                     x  pte
> [    0.016479] 0xfffffffee9f60000-0xfffffffee9f69000          36K                               pte
> [    0.016487] 0xfffffffee9f69000-0xfffffffeea172000        2084K     RW                     x  pte
> [    0.016498] 0xfffffffeea172000-0xfffffffeea175000          12K                               pte
> [    0.016504] 0xfffffffeea175000-0xfffffffeea2b9000        1296K     RW                     x  pte
> [    0.016515] 0xfffffffeea2b9000-0xfffffffeea2c2000          36K                               pte
> [    0.016520] 0xfffffffeea2c2000-0xfffffffeea32b000         420K     RW                     x  pte
> [    0.016531] 0xfffffffeea32b000-0xfffffffeea334000          36K                               pte
> [    0.016536] 0xfffffffeea334000-0xfffffffeea3b1000         500K     RW                     x  pte
> [    0.016548] 0xfffffffeea3b1000-0xfffffffeea3b4000          12K                               pte
> [    0.016553] 0xfffffffeea3b4000-0xfffffffeea459000         660K     RW                     x  pte
> [    0.016564] 0xfffffffeea459000-0xfffffffeea45e000          20K                               pte
> [    0.016570] 0xfffffffeea45e000-0xfffffffeea57e000        1152K     RW                     x  pte
> [    0.016582] 0xfffffffeea57e000-0xfffffffeea57f000           4K                               pte
> [    0.016588] 0xfffffffeea57f000-0xfffffffeea731000        1736K     RW                     x  pte
> [    0.016600] 0xfffffffeea731000-0xfffffffeea73a000          36K                               pte
> [    0.016605] 0xfffffffeea73a000-0xfffffffeea7b6000         496K     RW                     x  pte
> [    0.016616] 0xfffffffeea7b6000-0xfffffffeea7b9000          12K                               pte
> [    0.016621] 0xfffffffeea7b9000-0xfffffffeea85d000         656K     RW                     x  pte
> [    0.016633] 0xfffffffeea85d000-0xfffffffeea865000          32K                               pte
> [    0.016639] 0xfffffffeea865000-0xfffffffeea9bc000        1372K     RW                     x  pte
> [    0.016650] 0xfffffffeea9bc000-0xfffffffeea9c6000          40K                               pte
> [    0.016655] 0xfffffffeea9c6000-0xfffffffeeaa49000         524K     RW                     x  pte
> [    0.016666] 0xfffffffeeaa49000-0xfffffffeeaa4c000          12K                               pte
> [    0.016671] 0xfffffffeeaa4c000-0xfffffffeeaa52000          24K     RW                     x  pte
> [    0.016682] 0xfffffffeeaa52000-0xfffffffeeaa5a000          32K                               pte
> [    0.016688] 0xfffffffeeaa5a000-0xfffffffeeab27000         820K     RW                     x  pte
> [    0.016699] 0xfffffffeeab27000-0xfffffffeeab2c000          20K                               pte
> [    0.016703] 0xfffffffeeab2c000-0xfffffffeeab31000          20K     RW                     x  pte
> [    0.016715] 0xfffffffeeab31000-0xfffffffeeab37000          24K                               pte
> [    0.016719] 0xfffffffeeab37000-0xfffffffeeab3c000          20K     RW                     x  pte
> [    0.016730] 0xfffffffeeab3c000-0xfffffffeeab46000          40K                               pte
> [    0.016736] 0xfffffffeeab46000-0xfffffffeeac00000         744K     RW                     x  pte
> [    0.016747] 0xfffffffeeac00000-0xfffffffeeb400000           8M     RW         PSE         x  pmd
> [    0.016758] 0xfffffffeeb400000-0xfffffffeeb42d000         180K     RW                     x  pte
> [    0.016770] 0xfffffffeeb42d000-0xfffffffeeb431000          16K                               pte
> [    0.016777] 0xfffffffeeb431000-0xfffffffeeb600000        1852K     RW                     x  pte
> [    0.016788] 0xfffffffeeb600000-0xfffffffef4c00000         150M     RW         PSE         x  pmd
> [    0.016800] 0xfffffffef4c00000-0xfffffffef4c72000         456K     RW                     x  pte
> [    0.016811] 0xfffffffef4c72000-0xfffffffef4c75000          12K                               pte
> [    0.016816] 0xfffffffef4c75000-0xfffffffef4c7e000          36K     RW                     x  pte
> [    0.016827] 0xfffffffef4c7e000-0xfffffffef4c81000          12K                               pte
> [    0.016831] 0xfffffffef4c81000-0xfffffffef4c89000          32K     RW                     x  pte
> [    0.016843] 0xfffffffef4c89000-0xfffffffef4c8c000          12K                               pte
> [    0.016847] 0xfffffffef4c8c000-0xfffffffef4c95000          36K     RW                     x  pte
> [    0.016858] 0xfffffffef4c95000-0xfffffffef4c98000          12K                               pte
> [    0.016865] 0xfffffffef4c98000-0xfffffffef4e00000        1440K     RW                     x  pte
> [    0.016876] 0xfffffffef4e00000-0xfffffffef6800000          26M     RW         PSE         x  pmd
> [    0.016889] 0xfffffffef6800000-0xfffffffef6903000        1036K     RW                     x  pte
> [    0.016901] 0xfffffffef6903000-0xfffffffef6991000         568K                               pte
> [    0.016906] 0xfffffffef6991000-0xfffffffef6a00000         444K     RW                     x  pte
> [    0.016917] 0xfffffffef6a00000-0xfffffffef6c00000           2M     RW         PSE         x  pmd
> [    0.016929] 0xfffffffef6c00000-0xfffffffef6c88000         544K     RW                     x  pte
> [    0.016942] 0xfffffffef6c88000-0xfffffffef6dee000        1432K                               pte
> [    0.016947] 0xfffffffef6dee000-0xfffffffef6e00000          72K     RW                     x  pte
> [    0.016958] 0xfffffffef6e00000-0xfffffffefaa00000          60M     RW         PSE         x  pmd
> [    0.016972] 0xfffffffefaa00000-0xfffffffefac00000           2M     RW                     x  pte
> [    0.016984] 0xfffffffefac00000-0xfffffffefec00000          64M     RW     PCD PSE         x  pmd
> [    0.016995] 0xfffffffefec00000-0xfffffffefec01000           4K     RW     PCD             x  pte
> [    0.017011] 0xfffffffefec01000-0xfffffffefed00000        1020K                               pte
> [    0.017015] 0xfffffffefed00000-0xfffffffefed04000          16K     RW     PCD             x  pte
> [    0.017026] 0xfffffffefed04000-0xfffffffefed1c000          96K                               pte
> [    0.017031] 0xfffffffefed1c000-0xfffffffefed20000          16K     RW     PCD             x  pte
> [    0.017043] 0xfffffffefed20000-0xfffffffefee00000         896K                               pte
> [    0.017048] 0xfffffffefee00000-0xfffffffefee01000           4K     RW     PCD             x  pte
> [    0.017062] 0xfffffffefee01000-0xfffffffeff000000        2044K                               pte
> [    0.017066] 0xfffffffeff000000-0xffffffff00000000          16M     RW     PCD PSE         x  pmd
> [    0.017078] 0xffffffff00000000-0xffffffff80000000           2G                               pud
> [    0.017082] ---[ High Kernel Mapping ]---
> [    0.017084] 0xffffffff80000000-0xffffffffa0000000         512M                               pmd
> [    0.017089] 0xffffffffa0000000-0xffffffffa0c00000          12M     RW         PSE         x  pmd
> [    0.017100] 0xffffffffa0c00000-0xffffffffa0e00000           2M     RW         PSE     GLB x  pmd
> [    0.017111] 0xffffffffa0e00000-0xffffffffa3400000          38M     RW         PSE         x  pmd
> [    0.017123] 0xffffffffa3400000-0xffffffffc0000000         460M                               pmd
> [    0.017128] ---[ Modules ]---
> [    0.017131] 0xffffffffc0000000-0xffffffffff000000        1008M                               pmd
> [    0.017135] ---[ End Modules ]---
> [    0.017136] 0xffffffffff000000-0xffffffffff200000           2M                               pmd
> [    0.017146] 0xffffffffff200000-0xffffffffff576000        3544K                               pte
> [    0.017150] ---[ Fixmap Area ]---
> [    0.017152] 0xffffffffff576000-0xffffffffff5fb000         532K                               pte
> [    0.017156] 0xffffffffff5fb000-0xffffffffff5fd000           8K     RW PWT PCD             NX pte
> [    0.017168] 0xffffffffff5fd000-0xffffffffff600000          12K                               pte
> [    0.017172] 0xffffffffff600000-0xffffffffff601000           4K USR ro                     NX pte
> [    0.017186] 0xffffffffff601000-0xffffffffff800000        2044K                               pte
> [    0.017191] 0xffffffffff800000-0x0000000000000000           8M                               pmd
> [    0.017230] Security Framework initialized
> [    0.017232] Yama: becoming mindful.
> [    0.017240] SELinux:  Initializing.
> [    0.017274] SELinux:  Starting in permissive mode
> [    0.023595] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
> [    0.026913] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> [    0.027036] Mount-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.027137] Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.027568] CPU: Physical Processor ID: 0
> [    0.027570] CPU: Processor Core ID: 0
> [    0.027576] mce: CPU supports 9 MCE banks
> [    0.027588] CPU0: Thermal monitoring enabled (TM1)
> [    0.027601] process: using mwait in idle threads
> [    0.027604] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
> [    0.027605] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
> [    0.027607] Spectre V2 : Mitigation: Full generic retpoline
> [    0.027608] Spectre V2 : Spectre v2 mitigation: Enabling Indirect Branch Prediction Barrier
> [    0.027609] Spectre V2 : Enabling Restricted Speculation for firmware calls
> [    0.027611] Speculative Store Bypass: Vulnerable
> [    0.030208] Freeing SMP alternatives memory: 28K
> [    0.058143] TSC deadline timer enabled
> [    0.058149] smpboot: CPU0: Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz (family: 0x6, model: 0x3c, stepping: 0x3)
> [    0.058425] Performance Events: PEBS fmt2+, Haswell events, 16-deep LBR, full-width counters, Intel PMU driver.
> [    0.058463] ... version:                3
> [    0.058465] ... bit width:              48
> [    0.058466] ... generic registers:      4
> [    0.058467] ... value mask:             0000ffffffffffff
> [    0.058469] ... max period:             00007fffffffffff
> [    0.058470] ... fixed-purpose events:   3
> [    0.058471] ... event mask:             000000070000000f
> [    0.058582] Hierarchical SRCU implementation.
> [    0.059674] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
> [    0.059721] smp: Bringing up secondary CPUs ...
> [    0.060022] x86: Booting SMP configuration:
> [    0.060027] .... node  #0, CPUs:      #1 #2 #3 #4 #5 #6 #7
> [    0.067658] smp: Brought up 1 node, 8 CPUs
> [    0.067658] smpboot: Max logical packages: 1
> [    0.067658] smpboot: Total of 8 processors activated (54276.78 BogoMIPS)
> [    0.069142] devtmpfs: initialized
> [    0.069142] x86/mm: Memory block size: 128MB
> [    0.076695] PM: Registering ACPI NVS region [mem 0xbd69f000-0xbd6a5fff] (28672 bytes)
> [    0.076695] PM: Registering ACPI NVS region [mem 0xdb932000-0xdb9edfff] (770048 bytes)
> [    0.096160] DMA-API: preallocated 65536 debug entries
> [    0.096161] DMA-API: debugging enabled by kernel config
> [    0.096164] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
> [    0.096198] futex hash table entries: 2048 (order: 6, 262144 bytes)
> [    0.096447] pinctrl core: initialized pinctrl subsystem
> [    0.096741] RTC time: 12:04:36, date: 08/05/18
> [    0.097387] NET: Registered protocol family 16
> [    0.097644] audit: initializing netlink subsys (disabled)
> [    0.097695] audit: type=2000 audit(1533470676.097:1): state=initialized audit_enabled=0 res=1
> [    0.097695] cpuidle: using governor menu
> [    0.098092] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
> [    0.098100] ACPI: bus type PCI registered
> [    0.098102] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    0.098228] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
> [    0.098232] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
> [    0.098239] pmd_set_huge: Cannot satisfy [mem 0xf8000000-0xf8200000] with a huge-page mapping due to MTRR override.
> [    0.098306] PCI: Using configuration type 1 for base access
> [    0.098356] core: PMU erratum BJ122, BV98, HSD29 worked around, HT is on
> [    0.104115] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
> [    0.104115] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
> [    0.104357] cryptd: max_cpu_qlen set to 1000
> [    0.104357] ACPI: Added _OSI(Module Device)
> [    0.104357] ACPI: Added _OSI(Processor Device)
> [    0.104357] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.104357] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.104357] ACPI: Added _OSI(Linux-Dell-Video)
> [    0.126697] ACPI: 6 ACPI AML tables successfully acquired and loaded
> [    0.138663] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
> [    0.140718] ACPI: Dynamic OEM Table Load:
> [    0.140730] ACPI: SSDT 0xFFFF8DCAF8577C00 0003D3 (v01 PmRef  Cpu0Cst  00003001 INTL 20120711)
> [    0.141703] ACPI: Dynamic OEM Table Load:
> [    0.141715] ACPI: SSDT 0xFFFF8DCAF84E8800 0005AA (v01 PmRef  ApIst    00003000 INTL 20120711)
> [    0.142936] ACPI: Dynamic OEM Table Load:
> [    0.142946] ACPI: SSDT 0xFFFF8DCAF8458C00 000119 (v01 PmRef  ApCst    00003000 INTL 20120711)
> [    0.148630] ACPI: Interpreter enabled
> [    0.148675] ACPI: (supports S0 S3 S4 S5)
> [    0.148677] ACPI: Using IOAPIC for interrupt routing
> [    0.148726] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.149815] ACPI: Enabled 7 GPEs in block 00 to 3F
> [    0.178256] ACPI: Power Resource [FN00] (off)
> [    0.178519] ACPI: Power Resource [FN01] (off)
> [    0.178747] ACPI: Power Resource [FN02] (off)
> [    0.178975] ACPI: Power Resource [FN03] (off)
> [    0.179209] ACPI: Power Resource [FN04] (off)
> [    0.182015] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
> [    0.182022] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    0.182589] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug SHPCHotplug PME]
> [    0.183072] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability LTR]
> [    0.183074] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using BIOS configuration
> [    0.184417] PCI host bridge to bus 0000:00
> [    0.184420] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> [    0.184423] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
> [    0.184425] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.184427] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d3fff window]
> [    0.184428] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff window]
> [    0.184430] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff window]
> [    0.184432] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff window]
> [    0.184434] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfeafffff window]
> [    0.184436] pci_bus 0000:00: root bus resource [bus 00-3e]
> [    0.184458] pci 0000:00:00.0: [8086:0c00] type 00 class 0x060000
> [    0.184715] pci 0000:00:14.0: [8086:8c31] type 00 class 0x0c0330
> [    0.184736] pci 0000:00:14.0: reg 0x10: [mem 0xf7f00000-0xf7f0ffff 64bit]
> [    0.184802] pci 0000:00:14.0: PME# supported from D3hot D3cold
> [    0.185064] pci 0000:00:16.0: [8086:8c3a] type 00 class 0x078000
> [    0.185087] pci 0000:00:16.0: reg 0x10: [mem 0xf7f18000-0xf7f1800f 64bit]
> [    0.185156] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
> [    0.185359] pci 0000:00:1b.0: [8086:8c20] type 00 class 0x040300
> [    0.185378] pci 0000:00:1b.0: reg 0x10: [mem 0xf7f10000-0xf7f13fff 64bit]
> [    0.185444] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
> [    0.185643] pci 0000:00:1c.0: [8086:8c10] type 01 class 0x060400
> [    0.185722] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> [    0.186059] pci 0000:00:1c.2: [8086:8c14] type 01 class 0x060400
> [    0.186140] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
> [    0.186472] pci 0000:00:1c.3: [8086:8c16] type 01 class 0x060400
> [    0.186552] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
> [    0.186878] pci 0000:00:1c.4: [8086:8c18] type 01 class 0x060400
> [    0.186958] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
> [    0.187296] pci 0000:00:1f.0: [8086:8c44] type 00 class 0x060100
> [    0.187590] pci 0000:00:1f.2: [8086:8c02] type 00 class 0x010601
> [    0.187607] pci 0000:00:1f.2: reg 0x10: [io  0xf070-0xf077]
> [    0.187614] pci 0000:00:1f.2: reg 0x14: [io  0xf060-0xf063]
> [    0.187622] pci 0000:00:1f.2: reg 0x18: [io  0xf050-0xf057]
> [    0.187629] pci 0000:00:1f.2: reg 0x1c: [io  0xf040-0xf043]
> [    0.187636] pci 0000:00:1f.2: reg 0x20: [io  0xf020-0xf03f]
> [    0.187644] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f16000-0xf7f167ff]
> [    0.187684] pci 0000:00:1f.2: PME# supported from D3hot
> [    0.187877] pci 0000:00:1f.3: [8086:8c22] type 00 class 0x0c0500
> [    0.187895] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f15000-0xf7f150ff 64bit]
> [    0.187915] pci 0000:00:1f.3: reg 0x20: [io  0xf000-0xf01f]
> [    0.188277] acpiphp: Slot [1] registered
> [    0.188284] pci 0000:00:1c.0: PCI bridge to [bus 01]
> [    0.188410] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
> [    0.188440] pci 0000:02:00.0: reg 0x10: [io  0xe000-0xe0ff]
> [    0.188469] pci 0000:02:00.0: reg 0x18: [mem 0xf7e00000-0xf7e00fff 64bit]
> [    0.188488] pci 0000:02:00.0: reg 0x20: [mem 0xf0300000-0xf0303fff 64bit pref]
> [    0.188593] pci 0000:02:00.0: supports D1 D2
> [    0.188595] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.188771] pci 0000:00:1c.2: PCI bridge to [bus 02]
> [    0.188774] pci 0000:00:1c.2:   bridge window [io  0xe000-0xefff]
> [    0.188778] pci 0000:00:1c.2:   bridge window [mem 0xf7e00000-0xf7efffff]
> [    0.188783] pci 0000:00:1c.2:   bridge window [mem 0xf0300000-0xf03fffff 64bit pref]
> [    0.188901] pci 0000:03:00.0: [8086:244e] type 01 class 0x060401
> [    0.189043] pci 0000:03:00.0: supports D1 D2
> [    0.189045] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.189156] pci 0000:00:1c.3: PCI bridge to [bus 03-04]
> [    0.189205] pci_bus 0000:04: extended config space not accessible
> [    0.189317] pci 0000:03:00.0: PCI bridge to [bus 04] (subtractive decode)
> [    0.189467] pci 0000:05:00.0: [1022:1470] type 01 class 0x060400
> [    0.189501] pci 0000:05:00.0: reg 0x10: [mem 0xf7d00000-0xf7d03fff]
> [    0.189537] pci 0000:05:00.0: enabling Extended Tags
> [    0.189632] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
> [    0.189809] pci 0000:00:1c.4: PCI bridge to [bus 05-07]
> [    0.189813] pci 0000:00:1c.4:   bridge window [io  0xd000-0xdfff]
> [    0.189816] pci 0000:00:1c.4:   bridge window [mem 0xf7c00000-0xf7dfffff]
> [    0.189821] pci 0000:00:1c.4:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.189911] pci 0000:06:00.0: [1022:1471] type 01 class 0x060400
> [    0.189977] pci 0000:06:00.0: enabling Extended Tags
> [    0.190066] pci 0000:06:00.0: PME# supported from D0 D3hot D3cold
> [    0.190221] pci 0000:05:00.0: PCI bridge to [bus 06-07]
> [    0.190228] pci 0000:05:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.190233] pci 0000:05:00.0:   bridge window [mem 0xf7c00000-0xf7cfffff]
> [    0.190240] pci 0000:05:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.190318] pci 0000:07:00.0: [1002:687f] type 00 class 0x030000
> [    0.190360] pci 0000:07:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit pref]
> [    0.190377] pci 0000:07:00.0: reg 0x18: [mem 0xf0000000-0xf01fffff 64bit pref]
> [    0.190389] pci 0000:07:00.0: reg 0x20: [io  0xd000-0xd0ff]
> [    0.190400] pci 0000:07:00.0: reg 0x24: [mem 0xf7c00000-0xf7c7ffff]
> [    0.190412] pci 0000:07:00.0: reg 0x30: [mem 0xf7c80000-0xf7c9ffff pref]
> [    0.190422] pci 0000:07:00.0: enabling Extended Tags
> [    0.190449] pci 0000:07:00.0: BAR 0: assigned to efifb
> [    0.190531] pci 0000:07:00.0: PME# supported from D1 D2 D3hot D3cold
> [    0.190666] pci 0000:07:00.1: [1002:aaf8] type 00 class 0x040300
> [    0.190696] pci 0000:07:00.1: reg 0x10: [mem 0xf7ca0000-0xf7ca3fff]
> [    0.190763] pci 0000:07:00.1: enabling Extended Tags
> [    0.190847] pci 0000:07:00.1: PME# supported from D1 D2 D3hot D3cold
> [    0.191012] pci 0000:06:00.0: PCI bridge to [bus 07]
> [    0.191019] pci 0000:06:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.191024] pci 0000:06:00.0:   bridge window [mem 0xf7c00000-0xf7cfffff]
> [    0.191031] pci 0000:06:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.193343] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
> [    0.193500] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14 15)
> [    0.193655] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
> [    0.193807] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
> [    0.193958] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
> [    0.194119] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
> [    0.194273] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 10 11 12 14 15)
> [    0.194424] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
> [    0.195521] pci 0000:07:00.0: vgaarb: setting as boot VGA device
> [    0.195521] pci 0000:07:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
> [    0.195521] pci 0000:07:00.0: vgaarb: bridge control possible
> [    0.195521] vgaarb: loaded
> [    0.195521] SCSI subsystem initialized
> [    0.195521] libata version 3.00 loaded.
> [    0.195521] ACPI: bus type USB registered
> [    0.195521] usbcore: registered new interface driver usbfs
> [    0.195521] usbcore: registered new interface driver hub
> [    0.196009] usbcore: registered new device driver usb
> [    0.196052] pps_core: LinuxPPS API ver. 1 registered
> [    0.196053] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.196058] PTP clock support registered
> [    0.196259] EDAC MC: Ver: 3.0.0
> [    0.196259] Registered efivars operations
> [    0.199740] PCI: Using ACPI for IRQ routing
> [    0.201173] PCI: pci_cache_line_size set to 64 bytes
> [    0.201223] e820: reserve RAM buffer [mem 0x00058000-0x0005ffff]
> [    0.201231] e820: reserve RAM buffer [mem 0x0009f000-0x0009ffff]
> [    0.201233] e820: reserve RAM buffer [mem 0xbd336018-0xbfffffff]
> [    0.201235] e820: reserve RAM buffer [mem 0xbd350018-0xbfffffff]
> [    0.201238] e820: reserve RAM buffer [mem 0xbd69f000-0xbfffffff]
> [    0.201240] e820: reserve RAM buffer [mem 0xbe17c000-0xbfffffff]
> [    0.201242] e820: reserve RAM buffer [mem 0xdb488000-0xdbffffff]
> [    0.201244] e820: reserve RAM buffer [mem 0xdb932000-0xdbffffff]
> [    0.201246] e820: reserve RAM buffer [mem 0xdf800000-0xdfffffff]
> [    0.201248] e820: reserve RAM buffer [mem 0x81f000000-0x81fffffff]
> [    0.201562] NetLabel: Initializing
> [    0.201564] NetLabel:  domain hash size = 128
> [    0.201565] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
> [    0.201595] NetLabel:  unlabeled traffic allowed by default
> [    0.201628] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
> [    0.201628] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
> [    0.203059] clocksource: Switched to clocksource tsc-early
> [    0.246972] VFS: Disk quotas dquot_6.6.0
> [    0.247013] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    0.247193] pnp: PnP ACPI init
> [    0.247382] system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
> [    0.247401] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
> [    0.247836] system 00:01: [io  0x0680-0x069f] has been reserved
> [    0.247839] system 00:01: [io  0xffff] has been reserved
> [    0.247842] system 00:01: [io  0xffff] has been reserved
> [    0.247844] system 00:01: [io  0xffff] has been reserved
> [    0.247847] system 00:01: [io  0x1c00-0x1cfe] has been reserved
> [    0.247849] system 00:01: [io  0x1d00-0x1dfe] has been reserved
> [    0.247852] system 00:01: [io  0x1e00-0x1efe] has been reserved
> [    0.247854] system 00:01: [io  0x1f00-0x1ffe] has been reserved
> [    0.247857] system 00:01: [io  0x1800-0x18fe] has been reserved
> [    0.247859] system 00:01: [io  0x164e-0x164f] has been reserved
> [    0.247867] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.247919] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.248044] system 00:03: [io  0x1854-0x1857] has been reserved
> [    0.248052] system 00:03: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
> [    0.248362] system 00:04: [io  0x0a00-0x0a0f] has been reserved
> [    0.248365] system 00:04: [io  0x0a30-0x0a3f] has been reserved
> [    0.248368] system 00:04: [io  0x0a20-0x0a2f] has been reserved
> [    0.248375] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.248967] pnp 00:05: [dma 0 disabled]
> [    0.249041] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    0.249824] pnp 00:06: [dma 3]
> [    0.250094] pnp 00:06: Plug and Play ACPI device, IDs PNP0401 (active)
> [    0.250204] system 00:07: [io  0x04d0-0x04d1] has been reserved
> [    0.250211] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.251265] system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
> [    0.251268] system 00:08: [mem 0xfed10000-0xfed17fff] has been reserved
> [    0.251271] system 00:08: [mem 0xfed18000-0xfed18fff] has been reserved
> [    0.251273] system 00:08: [mem 0xfed19000-0xfed19fff] has been reserved
> [    0.251276] system 00:08: [mem 0xf8000000-0xfbffffff] has been reserved
> [    0.251278] system 00:08: [mem 0xfed20000-0xfed3ffff] has been reserved
> [    0.251283] system 00:08: [mem 0xfed90000-0xfed93fff] could not be reserved
> [    0.251285] system 00:08: [mem 0xfed45000-0xfed8ffff] has been reserved
> [    0.251288] system 00:08: [mem 0xff000000-0xffffffff] has been reserved
> [    0.251291] system 00:08: [mem 0xfee00000-0xfeefffff] could not be reserved
> [    0.251294] system 00:08: [mem 0xf7fee000-0xf7feefff] has been reserved
> [    0.251296] system 00:08: [mem 0xf7fd0000-0xf7fdffff] has been reserved
> [    0.251303] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.251923] pnp: PnP ACPI: found 9 devices
> [    0.259866] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    0.260024] pci 0000:00:1c.0: PCI bridge to [bus 01]
> [    0.260034] pci 0000:00:1c.2: PCI bridge to [bus 02]
> [    0.260037] pci 0000:00:1c.2:   bridge window [io  0xe000-0xefff]
> [    0.260041] pci 0000:00:1c.2:   bridge window [mem 0xf7e00000-0xf7efffff]
> [    0.260045] pci 0000:00:1c.2:   bridge window [mem 0xf0300000-0xf03fffff 64bit pref]
> [    0.260050] pci 0000:03:00.0: PCI bridge to [bus 04]
> [    0.260071] pci 0000:00:1c.3: PCI bridge to [bus 03-04]
> [    0.260081] pci 0000:06:00.0: PCI bridge to [bus 07]
> [    0.260084] pci 0000:06:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.260090] pci 0000:06:00.0:   bridge window [mem 0xf7c00000-0xf7cfffff]
> [    0.260094] pci 0000:06:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260101] pci 0000:05:00.0: PCI bridge to [bus 06-07]
> [    0.260104] pci 0000:05:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.260110] pci 0000:05:00.0:   bridge window [mem 0xf7c00000-0xf7cfffff]
> [    0.260115] pci 0000:05:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260122] pci 0000:00:1c.4: PCI bridge to [bus 05-07]
> [    0.260125] pci 0000:00:1c.4:   bridge window [io  0xd000-0xdfff]
> [    0.260129] pci 0000:00:1c.4:   bridge window [mem 0xf7c00000-0xf7dfffff]
> [    0.260132] pci 0000:00:1c.4:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260138] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    0.260140] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
> [    0.260142] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
> [    0.260144] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff window]
> [    0.260145] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff window]
> [    0.260147] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff window]
> [    0.260149] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff window]
> [    0.260151] pci_bus 0000:00: resource 11 [mem 0xe0000000-0xfeafffff window]
> [    0.260153] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
> [    0.260154] pci_bus 0000:02: resource 1 [mem 0xf7e00000-0xf7efffff]
> [    0.260156] pci_bus 0000:02: resource 2 [mem 0xf0300000-0xf03fffff 64bit pref]
> [    0.260158] pci_bus 0000:05: resource 0 [io  0xd000-0xdfff]
> [    0.260159] pci_bus 0000:05: resource 1 [mem 0xf7c00000-0xf7dfffff]
> [    0.260161] pci_bus 0000:05: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260163] pci_bus 0000:06: resource 0 [io  0xd000-0xdfff]
> [    0.260165] pci_bus 0000:06: resource 1 [mem 0xf7c00000-0xf7cfffff]
> [    0.260166] pci_bus 0000:06: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260168] pci_bus 0000:07: resource 0 [io  0xd000-0xdfff]
> [    0.260170] pci_bus 0000:07: resource 1 [mem 0xf7c00000-0xf7cfffff]
> [    0.260171] pci_bus 0000:07: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.260451] NET: Registered protocol family 2
> [    0.265703] tcp_listen_portaddr_hash hash table entries: 16384 (order: 8, 1441792 bytes)
> [    0.266250] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.266987] TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
> [    0.268205] TCP: Hash tables configured (established 262144 bind 65536)
> [    0.268620] UDP hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.269572] UDP-Lite hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.270288] NET: Registered protocol family 1
> [    0.270946] pci 0000:07:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
> [    0.270971] pci 0000:07:00.1: Linked as a consumer to 0000:07:00.0
> [    0.270996] PCI: CLS 64 bytes, default 64
> [    0.271238] Unpacking initramfs...
> [    0.607081] Freeing initrd memory: 26672K
> [    0.613086] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> [    0.613089] software IO TLB [mem 0xc8703000-0xcc703000] (64MB) mapped at [(____ptrval____)-(____ptrval____)]
> [    0.614743] Scanning for low memory corruption every 60 seconds
> [    0.615044] cryptomgr_test (78) used greatest stack depth: 14472 bytes left
> [    0.616026] Initialise system trusted keyrings
> [    0.616098] Key type blacklist registered
> [    0.616158] workingset: timestamp_bits=36 max_order=23 bucket_order=0
> [    0.620372] zbud: loaded
> [    0.621630] pstore: using deflate compression
> [    0.621780] SELinux:  Registering netfilter hooks
> [    0.724284] cryptomgr_test (82) used greatest stack depth: 13864 bytes left
> [    0.727961] cryptomgr_test (95) used greatest stack depth: 13800 bytes left
> [    0.729020] alg: No test for 842 (842-generic)
> [    0.729061] alg: No test for 842 (842-scomp)
> [    0.732711] cryptomgr_test (107) used greatest stack depth: 13784 bytes left
> [    0.732812] cryptomgr_test (101) used greatest stack depth: 13016 bytes left
> [    0.737384] NET: Registered protocol family 38
> [    0.737401] Key type asymmetric registered
> [    0.737410] Asymmetric key parser 'x509' registered
> [    0.737492] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
> [    0.737581] io scheduler noop registered
> [    0.737583] io scheduler deadline registered
> [    0.737645] io scheduler cfq registered (default)
> [    0.737647] io scheduler mq-deadline registered
> [    0.738184] atomic64_test: passed for x86-64 platform with CX8 and with SSE
> [    0.740108] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [    0.740151] efifb: probing for efifb
> [    0.740168] efifb: No BGRT, not showing boot graphics
> [    0.740170] efifb: framebuffer at 0xe0000000, using 3072k, total 3072k
> [    0.740171] efifb: mode is 1024x768x32, linelength=4096, pages=1
> [    0.740172] efifb: scrolling: redraw
> [    0.740174] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
> [    0.740343] fbcon: Deferring console take-over
> [    0.740351] fb0: EFI VGA frame buffer device
> [    0.740365] intel_idle: MWAIT substates: 0x42120
> [    0.740366] intel_idle: v0.4.1 model 0x3C
> [    0.741152] intel_idle: lapic_timer_reliable_states 0xffffffff
> [    0.741416] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
> [    0.741553] ACPI: Power Button [PWRB]
> [    0.741634] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [    0.741656] ACPI: Power Button [PWRF]
> [    0.744207] thermal LNXTHERM:00: registered as thermal_zone0
> [    0.744209] ACPI: Thermal Zone [TZ00] (28 C)
> [    0.744917] thermal LNXTHERM:01: registered as thermal_zone1
> [    0.744919] ACPI: Thermal Zone [TZ01] (30 C)
> [    0.745264] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
> [    0.765867] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    0.770884] Non-volatile memory driver v1.3
> [    0.770938] Linux agpgart interface v0.103
> [    0.772682] ahci 0000:00:1f.2: version 3.0
> [    0.772994] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x2c impl SATA mode
> [    0.772997] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part ems apst 
> [    0.781822] scsi host0: ahci
> [    0.782305] scsi host1: ahci
> [    0.782535] scsi host2: ahci
> [    0.782783] scsi host3: ahci
> [    0.782956] scsi host4: ahci
> [    0.783209] scsi host5: ahci
> [    0.783299] ata1: DUMMY
> [    0.783301] ata2: DUMMY
> [    0.783303] ata3: SATA max UDMA/133 abar m2048@0xf7f16000 port 0xf7f16200 irq 27
> [    0.783305] ata4: SATA max UDMA/133 abar m2048@0xf7f16000 port 0xf7f16280 irq 27
> [    0.783306] ata5: DUMMY
> [    0.783308] ata6: SATA max UDMA/133 abar m2048@0xf7f16000 port 0xf7f16380 irq 27
> [    0.783599] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    0.783616] ehci-pci: EHCI PCI platform driver
> [    0.783638] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    0.783644] ohci-pci: OHCI PCI platform driver
> [    0.783661] uhci_hcd: USB Universal Host Controller Interface driver
> [    0.783957] xhci_hcd 0000:00:14.0: xHCI Host Controller
> [    0.784208] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 1
> [    0.785367] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x0000000000009810
> [    0.785372] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
> [    0.786065] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 4.18
> [    0.786069] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.786071] usb usb1: Product: xHCI Host Controller
> [    0.786072] usb usb1: Manufacturer: Linux 4.18.0-0.rc7.git1.1.fc29.x86_64 xhci-hcd
> [    0.786074] usb usb1: SerialNumber: 0000:00:14.0
> [    0.786579] hub 1-0:1.0: USB hub found
> [    0.786683] hub 1-0:1.0: 14 ports detected
> [    0.794671] xhci_hcd 0000:00:14.0: xHCI Host Controller
> [    0.794818] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
> [    0.794823] xhci_hcd 0000:00:14.0: Host supports USB 3.0  SuperSpeed
> [    0.794920] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 4.18
> [    0.794925] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.794926] usb usb2: Product: xHCI Host Controller
> [    0.794928] usb usb2: Manufacturer: Linux 4.18.0-0.rc7.git1.1.fc29.x86_64 xhci-hcd
> [    0.794930] usb usb2: SerialNumber: 0000:00:14.0
> [    0.795287] hub 2-0:1.0: USB hub found
> [    0.795332] hub 2-0:1.0: 6 ports detected
> [    0.796944] usbcore: registered new interface driver usbserial_generic
> [    0.796976] usbserial: USB Serial support registered for generic
> [    0.797039] i8042: PNP: No PS/2 controller found.
> [    0.797157] mousedev: PS/2 mouse device common for all mice
> [    0.797465] rtc_cmos 00:02: RTC can wake from S4
> [    0.797706] rtc_cmos 00:02: registered as rtc0
> [    0.797708] rtc_cmos 00:02: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
> [    0.797800] device-mapper: uevent: version 1.0.3
> [    0.797943] device-mapper: ioctl: 4.39.0-ioctl (2018-04-03) initialised: dm-devel@redhat.com
> [    0.798145] intel_pstate: Intel P-state driver initializing
> [    0.801949] hidraw: raw HID events driver (C) Jiri Kosina
> [    0.802289] usbcore: registered new interface driver usbhid
> [    0.802295] usbhid: USB HID core driver
> [    0.802936] drop_monitor: Initializing network drop monitor service
> [    0.803879] Initializing XFRM netlink socket
> [    0.805178] NET: Registered protocol family 10
> [    0.814855] Segment Routing with IPv6
> [    0.814880] mip6: Mobile IPv6
> [    0.814902] NET: Registered protocol family 17
> [    0.814976] start plist test
> [    0.816376] end plist test
> [    0.817447] RAS: Correctable Errors collector initialized.
> [    0.817562] microcode: sig=0x306c3, pf=0x2, revision=0x24
> [    0.817770] microcode: Microcode Update Driver: v2.2.
> [    0.817794] AVX2 version of gcm_enc/dec engaged.
> [    0.817796] AES CTR mode by8 optimization enabled
> [    0.842354] sched_clock: Marking stable (842347301, 0)->(843545256, -1197955)
> [    0.842847] registered taskstats version 1
> [    0.842869] Loading compiled-in X.509 certificates
> [    0.869911] Loaded X.509 cert 'Fedora kernel signing key: 7f7797e76bbda3c532ea82bad06b61825b3fe9e7'
> [    0.870707] zswap: loaded using pool lzo/zbud
> [    0.877091] Key type big_key registered
> [    0.880089] Key type encrypted registered
> [    0.880149] ima: No TPM chip found, activating TPM-bypass! (rc=-19)
> [    0.880162] ima: Allocated hash algorithm: sha1
> [    0.881692]   Magic number: 14:172:76
> [    0.881747] memory memory233: hash matches
> [    0.881839] rtc_cmos 00:02: setting system clock to 2018-08-05 12:04:37 UTC (1533470677)
> [    1.096519] ata6: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    1.096603] ata3: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    1.096651] ata4: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    1.100435] ata6.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
> [    1.100446] ata6.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
> [    1.100456] ata6.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
> [    1.100668] ata6.00: ATA-8: OCZ-VECTOR150, 1.2, max UDMA/133
> [    1.100677] ata6.00: 468862128 sectors, multi 1: LBA48 NCQ (depth 32), AA
> [    1.104755] ata6.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
> [    1.104775] ata6.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
> [    1.104780] ata6.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
> [    1.104919] ata6.00: configured for UDMA/133
> [    1.108040] ata4.00: ATA-9: HGST HUH721212ALE604, LEGNW3D0, max UDMA/133
> [    1.108045] ata4.00: 23437770752 sectors, multi 16: LBA48 NCQ (depth 32), AA
> [    1.114057] usb 1-9: new high-speed USB device number 2 using xhci_hcd
> [    1.118943] ata4.00: configured for UDMA/133
> [    1.182561] ata3.00: NCQ Send/Recv Log not supported
> [    1.182565] ata3.00: ATA-9: ST4000NM0033-9ZM170, SN06, max UDMA/133
> [    1.182570] ata3.00: 7814037168 sectors, multi 16: LBA48 NCQ (depth 32), AA
> [    1.184283] ata3.00: NCQ Send/Recv Log not supported
> [    1.184291] ata3.00: configured for UDMA/133
> [    1.185762] scsi 2:0:0:0: Direct-Access     ATA      ST4000NM0033-9ZM SN06 PQ: 0 ANSI: 5
> [    1.187444] sd 2:0:0:0: Attached scsi generic sg0 type 0
> [    1.187551] sd 2:0:0:0: [sda] 7814037168 512-byte logical blocks: (4.00 TB/3.64 TiB)
> [    1.187649] sd 2:0:0:0: [sda] Write Protect is off
> [    1.187655] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    1.187802] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    1.188736] scsi 3:0:0:0: Direct-Access     ATA      HGST HUH721212AL W3D0 PQ: 0 ANSI: 5
> [    1.189636] sd 3:0:0:0: Attached scsi generic sg1 type 0
> [    1.189799] sd 3:0:0:0: [sdb] 23437770752 512-byte logical blocks: (12.0 TB/10.9 TiB)
> [    1.189805] sd 3:0:0:0: [sdb] 4096-byte physical blocks
> [    1.189892] sd 3:0:0:0: [sdb] Write Protect is off
> [    1.189899] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
> [    1.190091] sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    1.190706] scsi 5:0:0:0: Direct-Access     ATA      OCZ-VECTOR150    1.2  PQ: 0 ANSI: 5
> [    1.191676] sd 5:0:0:0: Attached scsi generic sg2 type 0
> [    1.192046] sd 5:0:0:0: [sdc] 468862128 512-byte logical blocks: (240 GB/224 GiB)
> [    1.192137] sd 5:0:0:0: [sdc] Write Protect is off
> [    1.192143] sd 5:0:0:0: [sdc] Mode Sense: 00 3a 00 00
> [    1.192264] sd 5:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    1.195599]  sdc: sdc1 sdc2 sdc3
> [    1.196815] sd 5:0:0:0: [sdc] Attached SCSI disk
> [    1.201916] sd 2:0:0:0: [sda] Attached SCSI disk
> [    1.203859] sd 3:0:0:0: [sdb] Attached SCSI disk
> [    1.241627] usb 1-9: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    1.241633] usb 1-9: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.241635] usb 1-9: Product: USB2.0 Hub
> [    1.241638] usb 1-9: Manufacturer: VIA Labs, Inc.
> [    1.242685] hub 1-9:1.0: USB hub found
> [    1.243509] hub 1-9:1.0: 4 ports detected
> [    1.272761] Freeing unused kernel memory: 4824K
> [    1.282071] Write protecting the kernel read-only data: 22528k
> [    1.283697] Freeing unused kernel memory: 2028K
> [    1.286960] Freeing unused kernel memory: 1724K
> [    1.294449] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    1.294451] x86/mm: Checking user space page tables
> [    1.299695] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    1.299698] rodata_test: all tests were successful
> [    1.325595] systemd[1]: systemd 239 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    1.338266] systemd[1]: Detected architecture x86-64.
> [    1.338270] systemd[1]: Running in initial RAM disk.
> [    1.342180] systemd[1]: Set hostname to <localhost.localdomain>.
> [    1.395313] usb 2-5: new SuperSpeed Gen 1 USB device number 2 using xhci_hcd
> [    1.420723] random: systemd: uninitialized urandom read (16 bytes read)
> [    1.420738] systemd[1]: Reached target Timers.
> [    1.420870] random: systemd: uninitialized urandom read (16 bytes read)
> [    1.420993] systemd[1]: Listening on Journal Audit Socket.
> [    1.421056] random: systemd: uninitialized urandom read (16 bytes read)
> [    1.421266] systemd[1]: Listening on Journal Socket.
> [    1.421417] systemd[1]: Listening on Journal Socket (/dev/log).
> [    1.424489] systemd[1]: Created slice system-systemd\x2dhibernate\x2dresume.slice.
> [    1.426581] systemd[1]: Starting dracut cmdline hook...
> [    1.458374] audit: type=1130 audit(1533470678.075:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.460146] audit: type=1130 audit(1533470678.077:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.492001] usb 2-5: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    1.492026] usb 2-5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.492029] usb 2-5: Product: USB3.0 Hub
> [    1.492032] usb 2-5: Manufacturer: VIA Labs, Inc.
> [    1.494749] hub 2-5:1.0: USB hub found
> [    1.494872] hub 2-5:1.0: 4 ports detected
> [    1.514283] audit: type=1130 audit(1533470678.131:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.514290] audit: type=1131 audit(1533470678.131:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.537791] audit: type=1130 audit(1533470678.154:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.543058] audit: type=1130 audit(1533470678.160:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.584905] audit: type=1130 audit(1533470678.201:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.604070] usb 1-10: new low-speed USB device number 3 using xhci_hcd
> [    1.613401] audit: type=1130 audit(1533470678.230:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.631139] tsc: Refined TSC clocksource calibration: 3392.143 MHz
> [    1.631157] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x30e5505274d, max_idle_ns: 440795301362 ns
> [    1.631275] clocksource: Switched to clocksource tsc
> [    1.736210] usb 1-10: New USB device found, idVendor=0925, idProduct=1234, bcdDevice= 0.01
> [    1.736213] usb 1-10: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.736215] usb 1-10: Product: UPS USB MON V1.4
> [    1.736216] usb 1-10: Manufacturer: A?a??
> [    1.741479] hid-generic 0003:0925:1234.0001: hiddev96,hidraw0: USB HID v1.00 Device [A?a?? UPS USB MON V1.4] on usb-0000:00:14.0-10/input0
> [    1.808034] usb 1-9.1: new high-speed USB device number 4 using xhci_hcd
> [    1.881600] audit: type=1130 audit(1533470678.498:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    1.900197] usb 1-9.1: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    1.900211] usb 1-9.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.900214] usb 1-9.1: Product: USB2.0 Hub
> [    1.900217] usb 1-9.1: Manufacturer: VIA Labs, Inc.
> [    1.901408] hub 1-9.1:1.0: USB hub found
> [    1.902195] hub 1-9.1:1.0: 4 ports detected
> [    1.913486] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.913505] r8169 0000:02:00.0: can't disable ASPM; OS doesn't have ASPM control
> [    1.914675] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl, 94:de:80:6b:dd:24, XID 2c900800, IRQ 29
> [    1.914679] r8169 0000:02:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
> [    1.969064] random: fast init done
> [    2.000902] r8169 0000:02:00.0 enp2s0: renamed from eth0
> [    2.004418] usb 2-5.1: new SuperSpeed Gen 1 USB device number 3 using xhci_hcd
> [    2.103788] usb 2-5.1: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.103792] usb 2-5.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.103794] usb 2-5.1: Product: USB3.0 Hub
> [    2.103795] usb 2-5.1: Manufacturer: VIA Labs, Inc.
> [    2.129249] hub 2-5.1:1.0: USB hub found
> [    2.129485] hub 2-5.1:1.0: 4 ports detected
> [    2.133217] [drm] amdgpu kernel modesetting enabled.
> [    2.136441] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
> [    2.136444] AMD IOMMUv2 functionality not available on this system
> [    2.148363] CRAT table not found
> [    2.148367] Virtual CRAT table created for CPU
> [    2.148370] Parsing CRAT table with 1 nodes
> [    2.148405] Creating topology SYSFS entries
> [    2.148458] Topology: Add CPU node
> [    2.148459] Finished initializing topology
> [    2.148575] kfd kfd: Initialized module
> [    2.149260] checking generic (e0000000 300000) vs hw (e0000000 10000000)
> [    2.149263] fb: switching to amdgpudrmfb from EFI VGA
> [    2.154491] [drm] initializing kernel modesetting (VEGA10 0x1002:0x687F 0x1002:0x0B36 0xC3).
> [    2.154569] [drm] register mmio base: 0xF7C00000
> [    2.154570] [drm] register mmio size: 524288
> [    2.154585] [drm] probing gen 2 caps for device 1022:1471 = 700d03/e
> [    2.154587] [drm] probing mlw for device 1022:1471 = 700d03
> [    2.154591] [drm] add ip block number 0 <soc15_common>
> [    2.154592] [drm] add ip block number 1 <gmc_v9_0>
> [    2.154593] [drm] add ip block number 2 <vega10_ih>
> [    2.154594] [drm] add ip block number 3 <psp>
> [    2.154596] [drm] add ip block number 4 <powerplay>
> [    2.154597] [drm] add ip block number 5 <dm>
> [    2.154598] [drm] add ip block number 6 <gfx_v9_0>
> [    2.154600] [drm] add ip block number 7 <sdma_v4_0>
> [    2.154601] [drm] add ip block number 8 <uvd_v7_0>
> [    2.154602] [drm] add ip block number 9 <vce_v4_0>
> [    2.154779] [drm] UVD(0) is enabled in VM mode
> [    2.154780] [drm] UVD(0) ENC is enabled in VM mode
> [    2.154782] [drm] VCE enabled in VM mode
> [    2.154828] resource sanity check: requesting [mem 0x000c0000-0x000dffff], which spans more than PCI Bus 0000:00 [mem 0x000d0000-0x000d3fff window]
> [    2.154835] caller pci_map_rom+0x58/0xe0 mapping multiple BARs
> [    2.154837] amdgpu 0000:07:00.0: Invalid PCI ROM header signature: expecting 0xaa55, got 0xffff
> [    2.154866] ATOM BIOS: 113-D0500300-102
> [    2.154944] [drm] vm size is 262144 GB, 4 levels, block size is 9-bit, fragment size is 9-bit
> [    2.154953] amdgpu 0000:07:00.0: VRAM: 8176M 0x000000F400000000 - 0x000000F5FEFFFFFF (8176M used)
> [    2.154954] amdgpu 0000:07:00.0: GTT: 512M 0x000000F600000000 - 0x000000F61FFFFFFF
> [    2.154959] [drm] Detected VRAM RAM=8176M, BAR=256M
> [    2.154961] [drm] RAM width 2048bits HBM
> [    2.155335] [TTM] Zone  kernel: Available graphics memory: 16402842 kiB
> [    2.155341] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
> [    2.155342] [TTM] Initializing pool allocator
> [    2.155361] [TTM] Initializing DMA pool allocator
> [    2.155848] [drm] amdgpu: 8176M of VRAM memory ready
> [    2.155852] [drm] amdgpu: 8176M of GTT memory ready.
> [    2.155900] [drm] GART: num cpu pages 131072, num gpu pages 131072
> [    2.156111] [drm] PCIE GART of 512M enabled (table at 0x000000F400900000).
> [    2.159832] [drm] use_doorbell being set to: [true]
> [    2.159916] [drm] use_doorbell being set to: [true]
> [    2.160214] [drm] Found UVD firmware Version: 1.87 Family ID: 17
> [    2.160222] [drm] PSP loading UVD firmware
> [    2.162348] [drm] Found VCE firmware Version: 53.45 Binary ID: 4
> [    2.162360] [drm] PSP loading VCE firmware
> [    2.262067] PM: Image not found (code -22)
> [    2.312431] usb 1-9.2: new high-speed USB device number 5 using xhci_hcd
> [    2.404728] usb 1-9.2: New USB device found, idVendor=8564, idProduct=1000, bcdDevice= a.00
> [    2.404731] usb 1-9.2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    2.404734] usb 1-9.2: Product: Mass Storage Device
> [    2.404736] usb 1-9.2: Manufacturer: JetFlash
> [    2.404738] usb 1-9.2: SerialNumber: 3988821812
> [    2.480018] usb 1-9.1.3: new full-speed USB device number 6 using xhci_hcd
> [    2.489048] [drm] Display Core initialized with v3.1.44!
> [    2.548622] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
> [    2.548623] [drm] Driver supports precise vblank timestamp query.
> [    2.569780] usb 1-9.1.3: New USB device found, idVendor=054c, idProduct=09cc, bcdDevice= 1.00
> [    2.569783] usb 1-9.1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.569786] usb 1-9.1.3: Product: Wireless Controller
> [    2.569788] usb 1-9.1.3: Manufacturer: Sony Interactive Entertainment
> [    2.571980] [drm] UVD and UVD ENC initialized successfully.
> [    2.672548] [drm] VCE initialized successfully.
> [    2.674283] usb 2-5.3: new SuperSpeed Gen 1 USB device number 4 using xhci_hcd
> [    2.677391] kfd kfd: Allocated 3969056 bytes on gart
> [    2.677424] Virtual CRAT table created for GPU
> [    2.677425] Parsing CRAT table with 1 nodes
> [    2.677452] Creating topology SYSFS entries
> [    2.677914] Topology: Add dGPU node [0x687f:0x1002]
> [    2.678219] kfd kfd: added device 1002:687f
> [    2.682103] [drm] fb mappable at 0xE1000000
> [    2.682124] [drm] vram apper at 0xE0000000
> [    2.682125] [drm] size 33177600
> [    2.682127] [drm] fb depth is 24
> [    2.682128] [drm]    pitch is 15360
> [    2.682549] fbcon: amdgpudrmfb (fb0) is primary device
> [    2.682553] fbcon: Deferring console take-over
> [    2.682559] amdgpu 0000:07:00.0: fb0: amdgpudrmfb frame buffer device
> [    2.692326] amdgpu 0000:07:00.0: ring 0(gfx) uses VM inv eng 4 on hub 0
> [    2.692329] amdgpu 0000:07:00.0: ring 1(comp_1.0.0) uses VM inv eng 5 on hub 0
> [    2.692332] amdgpu 0000:07:00.0: ring 2(comp_1.1.0) uses VM inv eng 6 on hub 0
> [    2.692334] amdgpu 0000:07:00.0: ring 3(comp_1.2.0) uses VM inv eng 7 on hub 0
> [    2.692337] amdgpu 0000:07:00.0: ring 4(comp_1.3.0) uses VM inv eng 8 on hub 0
> [    2.692339] amdgpu 0000:07:00.0: ring 5(comp_1.0.1) uses VM inv eng 9 on hub 0
> [    2.692342] amdgpu 0000:07:00.0: ring 6(comp_1.1.1) uses VM inv eng 10 on hub 0
> [    2.692344] amdgpu 0000:07:00.0: ring 7(comp_1.2.1) uses VM inv eng 11 on hub 0
> [    2.692347] amdgpu 0000:07:00.0: ring 8(comp_1.3.1) uses VM inv eng 12 on hub 0
> [    2.692349] amdgpu 0000:07:00.0: ring 9(kiq_2.1.0) uses VM inv eng 13 on hub 0
> [    2.692351] amdgpu 0000:07:00.0: ring 10(sdma0) uses VM inv eng 4 on hub 1
> [    2.692354] amdgpu 0000:07:00.0: ring 11(sdma1) uses VM inv eng 5 on hub 1
> [    2.692356] amdgpu 0000:07:00.0: ring 12(uvd<0>) uses VM inv eng 6 on hub 1
> [    2.692359] amdgpu 0000:07:00.0: ring 13(uvd_enc0<0>) uses VM inv eng 7 on hub 1
> [    2.692361] amdgpu 0000:07:00.0: ring 14(uvd_enc1<0>) uses VM inv eng 8 on hub 1
> [    2.692364] amdgpu 0000:07:00.0: ring 15(vce0) uses VM inv eng 9 on hub 1
> [    2.692366] amdgpu 0000:07:00.0: ring 16(vce1) uses VM inv eng 10 on hub 1
> [    2.692369] amdgpu 0000:07:00.0: ring 17(vce2) uses VM inv eng 11 on hub 1
> [    2.692479] [drm] ECC is not present.
> [    2.693517] [drm] Initialized amdgpu 3.26.0 20150101 for 0000:07:00.0 on minor 0
> [    2.771052] usb 2-5.3: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.771056] usb 2-5.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.771059] usb 2-5.3: Product: USB3.0 Hub
> [    2.771062] usb 2-5.3: Manufacturer: VIA Labs, Inc.
> [    2.773817] hub 2-5.3:1.0: USB hub found
> [    2.773962] hub 2-5.3:1.0: 4 ports detected
> [    2.846050] usb 1-9.3: new high-speed USB device number 7 using xhci_hcd
> [    2.938848] usb 1-9.3: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    2.938852] usb 1-9.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.938855] usb 1-9.3: Product: USB2.0 Hub
> [    2.938857] usb 1-9.3: Manufacturer: VIA Labs, Inc.
> [    2.940252] hub 1-9.3:1.0: USB hub found
> [    2.941047] hub 1-9.3:1.0: 4 ports detected
> [    3.043358] usb 2-5.4: new SuperSpeed Gen 1 USB device number 5 using xhci_hcd
> [    3.139924] usb 2-5.4: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    3.139927] usb 2-5.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.139930] usb 2-5.4: Product: USB3.0 Hub
> [    3.139933] usb 2-5.4: Manufacturer: VIA Labs, Inc.
> [    3.143072] hub 2-5.4:1.0: USB hub found
> [    3.143241] hub 2-5.4:1.0: 4 ports detected
> [    3.216047] usb 1-9.4: new high-speed USB device number 8 using xhci_hcd
> [    3.306664] usb 1-9.4: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    3.306668] usb 1-9.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.306670] usb 1-9.4: Product: USB2.0 Hub
> [    3.306673] usb 1-9.4: Manufacturer: VIA Labs, Inc.
> [    3.307987] hub 1-9.4:1.0: USB hub found
> [    3.308818] hub 1-9.4:1.0: 4 ports detected
> [    3.330648] usb-storage 1-9.2:1.0: USB Mass Storage device detected
> [    3.331070] scsi host6: usb-storage 1-9.2:1.0
> [    3.331438] usbcore: registered new interface driver usb-storage
> [    3.333687] usbcore: registered new interface driver uas
> [    3.334358] input: Sony Interactive Entertainment Wireless Controller Touchpad as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.1/1-9.1.3/1-9.1.3:1.3/0003:054C:09CC.0002/input/input3
> [    3.334829] input: Sony Interactive Entertainment Wireless Controller Motion Sensors as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.1/1-9.1.3/1-9.1.3:1.3/0003:054C:09CC.0002/input/input4
> [    3.387156] input: Sony Interactive Entertainment Wireless Controller as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.1/1-9.1.3/1-9.1.3:1.3/0003:054C:09CC.0002/input/input2
> [    3.387726] sony 0003:054C:09CC.0002: input,hidraw1: USB HID v81.11 Gamepad [Sony Interactive Entertainment Wireless Controller] on usb-0000:00:14.0-9.1.3/input3
> [    3.402040] systemd-udevd (390) used greatest stack depth: 12968 bytes left
> [    3.402862] systemd-udevd (387) used greatest stack depth: 12936 bytes left
> [    3.403084] systemd-udevd (382) used greatest stack depth: 11736 bytes left
> [    3.465850] EXT4-fs (sdc1): mounted filesystem with ordered data mode. Opts: (null)
> [    3.579005] random: crng init done
> [    3.579025] random: 7 urandom warning(s) missed due to ratelimiting
> [    3.646045] usb 1-9.4.2: new low-speed USB device number 9 using xhci_hcd
> [    3.784131] usb 1-9.4.2: New USB device found, idVendor=046d, idProduct=c326, bcdDevice=79.00
> [    3.784136] usb 1-9.4.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.784140] usb 1-9.4.2: Product: USB Keyboard
> [    3.784143] usb 1-9.4.2: Manufacturer: Logitech
> [    3.796509] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.2/1-9.4.2:1.0/0003:046D:C326.0003/input/input5
> [    3.848759] hid-generic 0003:046D:C326.0003: input,hidraw2: USB HID v1.10 Keyboard [Logitech USB Keyboard] on usb-0000:00:14.0-9.4.2/input0
> [    3.853270] input: Logitech USB Keyboard Consumer Control as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.2/1-9.4.2:1.1/0003:046D:C326.0004/input/input6
> [    3.906257] input: Logitech USB Keyboard System Control as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.2/1-9.4.2:1.1/0003:046D:C326.0004/input/input7
> [    3.906632] hid-generic 0003:046D:C326.0004: input,hiddev97,hidraw3: USB HID v1.10 Device [Logitech USB Keyboard] on usb-0000:00:14.0-9.4.2/input1
> [    3.984051] usb 1-9.4.3: new full-speed USB device number 10 using xhci_hcd
> [    4.008402] systemd-journald[257]: Received SIGTERM from PID 1 (systemd).
> [    4.069567] systemd: 17 output lines suppressed due to ratelimiting
> [    4.090017] usb 1-9.4.3: New USB device found, idVendor=0a12, idProduct=0001, bcdDevice=88.91
> [    4.090020] usb 1-9.4.3: New USB device strings: Mfr=0, Product=2, SerialNumber=0
> [    4.090022] usb 1-9.4.3: Product: CSR8510 A10
> [    4.177043] usb 1-9.4.4: new full-speed USB device number 11 using xhci_hcd
> [    4.222768] SELinux: 32768 avtab hash slots, 114945 rules.
> [    4.257774] SELinux: 32768 avtab hash slots, 114945 rules.
> [    4.269402] usb 1-9.4.4: New USB device found, idVendor=046d, idProduct=c52b, bcdDevice=12.07
> [    4.269405] usb 1-9.4.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    4.269407] usb 1-9.4.4: Product: USB Receiver
> [    4.269409] usb 1-9.4.4: Manufacturer: Logitech
> [    4.384259] scsi 6:0:0:0: Direct-Access     JetFlash Transcend 32GB   1.00 PQ: 0 ANSI: 5
> [    4.385254] sd 6:0:0:0: Attached scsi generic sg3 type 0
> [    4.385475] sd 6:0:0:0: [sdd] 61741056 512-byte logical blocks: (31.6 GB/29.4 GiB)
> [    4.385629] sd 6:0:0:0: [sdd] Write Protect is off
> [    4.385632] sd 6:0:0:0: [sdd] Mode Sense: 23 00 00 00
> [    4.385754] sd 6:0:0:0: [sdd] Write cache: disabled, read cache: disabled, doesn't support DPO or FUA
> [    4.387388]  sdd: sdd1 sdd2 sdd3
> [    4.388879] sd 6:0:0:0: [sdd] Attached SCSI removable disk
> [    4.700250] SELinux:  8 users, 14 roles, 5126 types, 322 bools, 1 sens, 1024 cats
> [    4.700255] SELinux:  130 classes, 114945 rules
> [    4.710873] SELinux:  Class xdp_socket not defined in policy.
> [    4.710875] SELinux: the above unknown classes and permissions will be allowed
> [    4.710881] SELinux:  policy capability network_peer_controls=1
> [    4.710882] SELinux:  policy capability open_perms=1
> [    4.710883] SELinux:  policy capability extended_socket_class=1
> [    4.710884] SELinux:  policy capability always_check_network=0
> [    4.710886] SELinux:  policy capability cgroup_seclabel=1
> [    4.710887] SELinux:  policy capability nnp_nosuid_transition=1
> [    4.710888] SELinux:  Completing initialization.
> [    4.710889] SELinux:  Setting up existing superblocks.
> [    4.933781] systemd[1]: Successfully loaded SELinux policy in 744.994ms.
> [    4.985561] systemd[1]: Relabelled /dev, /run and /sys/fs/cgroup in 33.694ms.
> [    4.988744] systemd[1]: systemd 239 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    5.001271] systemd[1]: Detected architecture x86-64.
> [    5.002491] systemd[1]: Set hostname to <localhost.localdomain>.
> [    5.220928] kauditd_printk_skb: 37 callbacks suppressed
> [    5.220929] audit: type=1130 audit(1533470681.837:48): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.220936] audit: type=1131 audit(1533470681.837:49): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.223051] systemd[1]: Stopped Switch Root.
> [    5.223276] audit: type=1130 audit(1533470681.840:50): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.223283] audit: type=1131 audit(1533470681.840:51): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.223666] systemd[1]: systemd-journald.service: Service has no hold-off time (RestartSec=0), scheduling restart.
> [    5.223718] systemd[1]: systemd-journald.service: Scheduled restart job, restart counter is at 1.
> [    5.223744] systemd[1]: Stopped Journal Service.
> [    5.223769] audit: type=1130 audit(1533470681.840:52): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.223789] audit: type=1131 audit(1533470681.840:53): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.226483] systemd[1]: Starting Journal Service...
> [    5.227939] systemd[1]: Created slice Virtual Machine and Container Slice.
> [    5.231906] systemd[1]: Listening on LVM2 metadata daemon socket.
> [    5.246340] audit: type=1305 audit(1533470681.863:54): audit_enabled=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:syslogd_t:s0 res=1
> [    5.283626] EXT4-fs (sdc1): re-mounted. Opts: (null)
> [    5.300046] audit: type=1130 audit(1533470681.916:55): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.307483] audit: type=1130 audit(1533470681.924:56): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=kmod-static-nodes comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.316883] audit: type=1130 audit(1533470681.933:57): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-remount-fs comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.328484] Adding 62494716k swap on /dev/sdc2.  Priority:-2 extents:1 across:62494716k SSFS
> [    5.371631] systemd-journald[538]: Received request to flush runtime journal from PID 1
> [    5.684019] parport_pc 00:06: reported by Plug and Play ACPI
> [    5.684243] parport0: PC-style at 0x378 (0x778), irq 5 [PCSPP,TRISTATE,EPP]
> [    5.792499] i801_smbus 0000:00:1f.3: enabling device (0001 -> 0003)
> [    5.792790] i801_smbus 0000:00:1f.3: SPD Write Disable is set
> [    5.792826] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
> [    5.832221] logitech-djreceiver 0003:046D:C52B.0007: hiddev98,hidraw4: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:14.0-9.4.4/input2
> [    5.853694] snd_hda_intel 0000:00:1b.0: enabling device (0000 -> 0002)
> [    5.855279] snd_hda_intel 0000:07:00.1: Handle vga_switcheroo audio client
> [    5.888037] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input8
> [    5.888618] input: HD-Audio Generic HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input9
> [    5.889263] input: HD-Audio Generic HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input10
> [    5.889524] input: HD-Audio Generic HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input11
> [    5.889918] usbcore: registered new interface driver snd-usb-audio
> [    5.890076] input: HD-Audio Generic HDMI/DP,pcm=10 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input12
> [    5.890386] input: HD-Audio Generic HDMI/DP,pcm=11 as /devices/pci0000:00/0000:00:1c.4/0000:05:00.0/0000:06:00.0/0000:07:00.1/sound/card2/input13
> [    5.890822] snd_hda_codec_realtek hdaudioC1D2: autoconfig for ALC892: line_outs=4 (0x14/0x15/0x16/0x17/0x0) type:line
> [    5.890827] snd_hda_codec_realtek hdaudioC1D2:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
> [    5.890830] snd_hda_codec_realtek hdaudioC1D2:    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
> [    5.890833] snd_hda_codec_realtek hdaudioC1D2:    mono: mono_out=0x0
> [    5.890835] snd_hda_codec_realtek hdaudioC1D2:    dig-out=0x11/0x0
> [    5.890838] snd_hda_codec_realtek hdaudioC1D2:    inputs:
> [    5.890843] snd_hda_codec_realtek hdaudioC1D2:      Front Mic=0x19
> [    5.890847] snd_hda_codec_realtek hdaudioC1D2:      Rear Mic=0x18
> [    5.890850] snd_hda_codec_realtek hdaudioC1D2:      Line=0x1a
> [    5.892869] Bluetooth: Core ver 2.22
> [    5.892928] NET: Registered protocol family 31
> [    5.892930] Bluetooth: HCI device and connection manager initialized
> [    5.892970] Bluetooth: HCI socket layer initialized
> [    5.892978] Bluetooth: L2CAP socket layer initialized
> [    5.893052] Bluetooth: SCO socket layer initialized
> [    5.908369] input: HDA Intel PCH Front Mic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input14
> [    5.908627] input: HDA Intel PCH Rear Mic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input15
> [    5.908929] input: HDA Intel PCH Line as /devices/pci0000:00/0000:00:1b.0/sound/card1/input16
> [    5.909405] input: HDA Intel PCH Line Out Front as /devices/pci0000:00/0000:00:1b.0/sound/card1/input17
> [    5.909656] input: HDA Intel PCH Line Out Surround as /devices/pci0000:00/0000:00:1b.0/sound/card1/input18
> [    5.909898] input: HDA Intel PCH Line Out CLFE as /devices/pci0000:00/0000:00:1b.0/sound/card1/input19
> [    5.910195] input: HDA Intel PCH Line Out Side as /devices/pci0000:00/0000:00:1b.0/sound/card1/input20
> [    5.910444] input: HDA Intel PCH Front Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card1/input21
> [    5.910709] snd_hda_intel 0000:00:1b.0: device 1458:a002 is on the power_save blacklist, forcing power_save to 0
> [    5.921690] usbcore: registered new interface driver btusb
> [    5.942344] input: Logitech Unifying Device. Wireless PID:4026 Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.4/1-9.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input22
> [    5.942926] input: Logitech Unifying Device. Wireless PID:4026 Mouse as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.4/1-9.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input23
> [    5.943690] input: Logitech Unifying Device. Wireless PID:4026 Consumer Control as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.4/1-9.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input24
> [    5.943847] input: Logitech Unifying Device. Wireless PID:4026 Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.4/1-9.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input29
> [    5.945044] hid-generic 0003:046D:4026.0008: input,hidraw5: USB HID v1.11 Keyboard [Logitech Unifying Device. Wireless PID:4026] on usb-0000:00:14.0-9.4.4:1
> [    5.954875] RAPL PMU: API unit is 2^-32 Joules, 4 fixed counters, 655360 ms ovfl timer
> [    5.954878] RAPL PMU: hw unit of domain pp0-core 2^-14 Joules
> [    5.954880] RAPL PMU: hw unit of domain package 2^-14 Joules
> [    5.954882] RAPL PMU: hw unit of domain dram 2^-14 Joules
> [    5.954884] RAPL PMU: hw unit of domain pp1-gpu 2^-14 Joules
> [    6.083332] iTCO_vendor_support: vendor-support=0
> [    6.083635] ppdev: user-space parallel port driver
> [    6.085403] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
> [    6.085466] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
> [    6.088107] gpio_ich: GPIO from 436 to 511 on gpio_ich
> [    6.245090] intel_rapl: Found RAPL domain package
> [    6.245111] intel_rapl: Found RAPL domain core
> [    6.245113] intel_rapl: Found RAPL domain dram
> [    6.328969] input: Logitech T400 as /devices/pci0000:00/0000:00:14.0/usb1/1-9/1-9.4/1-9.4.4/1-9.4.4:1.2/0003:046D:C52B.0007/0003:046D:4026.0008/input/input34
> [    6.330176] logitech-hidpp-device 0003:046D:4026.0008: input,hidraw5: USB HID v1.11 Keyboard [Logitech T400] on usb-0000:00:14.0-9.4.4:1
> [    6.694429] SGI XFS with ACLs, security attributes, scrub, no debug enabled
> [    6.701781] XFS (sdb): Mounting V5 Filesystem
> [    6.823325] XFS (sdb): Ending clean mount
> [    7.139779] RPC: Registered named UNIX socket transport module.
> [    7.139786] RPC: Registered udp transport module.
> [    7.139787] RPC: Registered tcp transport module.
> [    7.139788] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    7.370037] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> [    7.370041] Bluetooth: BNEP filters: protocol multicast
> [    7.370055] Bluetooth: BNEP socket layer initialized
> [    8.182638] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not ready
> [    8.304471] r8169 0000:02:00.0 enp2s0: link down
> [    8.304555] r8169 0000:02:00.0 enp2s0: link down
> [    8.304684] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not ready
> [    8.304808] bridge: filtering via arp/ip/ip6tables is no longer available by default. Update your scripts to load br_netfilter if you need this.
> [   10.705583] r8169 0000:02:00.0 enp2s0: link up
> [   10.705609] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becomes ready
> [   17.140782] logitech-hidpp-device 0003:046D:4026.0008: HID++ 2.0 device connected.
> [   32.050660] Bluetooth: RFCOMM TTY layer initialized
> [   32.050675] Bluetooth: RFCOMM socket layer initialized
> [   32.050719] Bluetooth: RFCOMM ver 1.11
> [   34.413359] fuse init (API version 7.27)
> [   40.562871] rfkill: input handler disabled
> [   42.272301] pool (2344) used greatest stack depth: 11320 bytes left
> [   42.701283] ISO 9660 Extensions: Microsoft Joliet Level 3
> [   42.704062] ISO 9660 Extensions: Microsoft Joliet Level 3
> [   42.710375] ISO 9660 Extensions: RRIP_1991A
> [   64.930766] tracker-extract (2229) used greatest stack depth: 11176 bytes left
> [  465.911281] TaskSchedulerFo (3362) used greatest stack depth: 11112 bytes left
> [  491.743600] TaskSchedulerFo (3364) used greatest stack depth: 11032 bytes left
> [  507.733884] nf_conntrack: default automatic helper assignment has been turned off for security reasons and CT-based  firewall rule not found. Use the iptables CT target to attach helpers instead.
> [  660.384586] kworker/dying (155) used greatest stack depth: 10888 bytes left
> [  699.910094] device enp2s0 entered promiscuous mode
> [ 1098.658964] kworker/dying (7) used greatest stack depth: 10712 bytes left
> [ 1843.488301] perf: interrupt took too long (2510 > 2500), lowering kernel.perf_event_max_sample_rate to 79000
> [ 2819.896469] perf: interrupt took too long (3138 > 3137), lowering kernel.perf_event_max_sample_rate to 63000
> [ 6120.247124] perf: interrupt took too long (3923 > 3922), lowering kernel.perf_event_max_sample_rate to 50000
> 
> [ 6829.212232] ============================================
> [ 6829.212234] WARNING: possible recursive locking detected
> [ 6829.212236] 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 Not tainted
> [ 6829.212237] --------------------------------------------
> [ 6829.212239] kworker/u17:2/28441 is trying to acquire lock:
> [ 6829.212242] 000000004025b723 (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212260] 
>                but task is already holding lock:
> [ 6829.212262] 000000004cb71eef (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: l2cap_sock_new_connection_cb+0x18/0xa0 [bluetooth]
> [ 6829.212278] 
>                other info that might help us debug this:
> [ 6829.212279]  Possible unsafe locking scenario:
> 
> [ 6829.212281]        CPU0
> [ 6829.212282]        ----
> [ 6829.212284]   lock(sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP);
> [ 6829.212286]   lock(sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP);
> [ 6829.212288] 
>                 *** DEADLOCK ***
> 
> [ 6829.212290]  May be due to missing lock nesting notation
> 
> [ 6829.212293] 5 locks held by kworker/u17:2/28441:
> [ 6829.212294]  #0: 000000009af6a4dc ((wq_completion)"%s"hdev->name#2){+.+.}, at: process_one_work+0x1f3/0x650
> [ 6829.212301]  #1: 000000006f7488f4 ((work_completion)(&hdev->rx_work)){+.+.}, at: process_one_work+0x1f3/0x650
> [ 6829.212306]  #2: 000000003dba8333 (&conn->chan_lock){+.+.}, at: l2cap_connect+0x8f/0x5a0 [bluetooth]
> [ 6829.212321]  #3: 00000000aaa813b9 (&chan->lock/2){+.+.}, at: l2cap_connect+0xa9/0x5a0 [bluetooth]
> [ 6829.212335]  #4: 000000004cb71eef (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: l2cap_sock_new_connection_cb+0x18/0xa0 [bluetooth]
> [ 6829.212350] 
>                stack backtrace:
> [ 6829.212354] CPU: 6 PID: 28441 Comm: kworker/u17:2 Not tainted 4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [ 6829.212355] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [ 6829.212365] Workqueue: hci0 hci_rx_work [bluetooth]
> [ 6829.212367] Call Trace:
> [ 6829.212373]  dump_stack+0x85/0xc0
> [ 6829.212377]  __lock_acquire.cold.64+0x158/0x227
> [ 6829.212381]  ? mark_held_locks+0x57/0x80
> [ 6829.212384]  lock_acquire+0x9e/0x1b0
> [ 6829.212394]  ? bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212398]  lock_sock_nested+0x72/0xa0
> [ 6829.212407]  ? bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212417]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212429]  l2cap_sock_new_connection_cb+0x5d/0xa0 [bluetooth]
> [ 6829.212441]  l2cap_connect+0x110/0x5a0 [bluetooth]
> [ 6829.212454]  ? l2cap_recv_frame+0x6d0/0x2cb0 [bluetooth]
> [ 6829.212458]  ? __mutex_unlock_slowpath+0x4b/0x2b0
> [ 6829.212470]  l2cap_recv_frame+0x6e8/0x2cb0 [bluetooth]
> [ 6829.212474]  ? __mutex_unlock_slowpath+0x4b/0x2b0
> [ 6829.212484]  hci_rx_work+0x1c6/0x5d0 [bluetooth]
> [ 6829.212488]  process_one_work+0x27d/0x650
> [ 6829.212492]  worker_thread+0x3c/0x390
> [ 6829.212494]  ? process_one_work+0x650/0x650
> [ 6829.212498]  kthread+0x120/0x140
> [ 6829.212501]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 6829.212504]  ret_from_fork+0x3a/0x50
> [ 6829.285343] BUG: sleeping function called from invalid context at net/core/sock.c:2833
> [ 6829.285349] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, name: krfcommd
> [ 6829.285351] INFO: lockdep is turned off.
> [ 6829.285355] CPU: 6 PID: 1743 Comm: krfcommd Not tainted 4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [ 6829.285358] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [ 6829.285360] Call Trace:
> [ 6829.285368]  dump_stack+0x85/0xc0
> [ 6829.285373]  ___might_sleep.cold.72+0xac/0xbc
> [ 6829.285378]  lock_sock_nested+0x29/0xa0
> [ 6829.285394]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.285401]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [ 6829.285406]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [ 6829.285411]  ? do_wait_intr_irq+0xb0/0xb0
> [ 6829.285416]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [ 6829.285419]  kthread+0x120/0x140
> [ 6829.285422]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 6829.285426]  ret_from_fork+0x3a/0x50
> [ 6829.476282] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input35
> [ 7273.090391] show_signal_msg: 23 callbacks suppressed
> [ 7273.090393] CFileWriterThre[29422]: segfault at 7f078bfe7240 ip 00007f079137843c sp 00007f078bb8dcf0 error 4 in steamclient.so[7f0790880000+14d2000]
> [ 7273.090404] Code: 89 df ff d2 8b 45 00 83 f8 02 0f 84 9e 00 00 00 83 f8 03 0f 84 55 05 00 00 83 f8 01 74 48 31 ed 4d 85 e4 74 11 48 85 db 74 0c <48> 8b 03 4c 89 e6 48 89 df ff 50 10 48 8b b4 24 e8 00 00 00 64 48 
> [ 7755.656023] rfkill: input handler enabled
> [ 7773.439895] rfkill: input handler disabled
> [ 8075.232946] BUG: sleeping function called from invalid context at net/core/sock.c:2833
> [ 8075.232951] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, name: krfcommd
> [ 8075.232952] INFO: lockdep is turned off.
> [ 8075.232956] CPU: 5 PID: 1743 Comm: krfcommd Tainted: G        W         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [ 8075.232957] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [ 8075.232959] Call Trace:
> [ 8075.232965]  dump_stack+0x85/0xc0
> [ 8075.232969]  ___might_sleep.cold.72+0xac/0xbc
> [ 8075.232973]  lock_sock_nested+0x29/0xa0
> [ 8075.232987]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 8075.232992]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [ 8075.232997]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [ 8075.233001]  ? do_wait_intr_irq+0xb0/0xb0
> [ 8075.233005]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [ 8075.233008]  kthread+0x120/0x140
> [ 8075.233011]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 8075.233014]  ret_from_fork+0x3a/0x50
> [ 8075.413187] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input36
> [13538.300352] steam[4385]: segfault at 0 ip 00000000eabc32d9 sp 00000000ffdca1b0 error 4 in vgui2_s.so[eab26000+292000]
> [13538.300365] Code: 74 03 00 00 00 00 00 00 c7 44 24 08 02 00 00 00 c7 44 24 04 10 00 00 00 c7 04 24 44 ac 00 00 e8 1d 40 fb ff 89 86 74 03 00 00 <8b> 00 8b 78 10 e8 3d 1a fb ff 8b 86 74 03 00 00 dd 5c 24 04 89 04 
> [14324.004275] pool[443]: segfault at 0 ip 00007f53e2399556 sp 00007f53ceffcc40 error 4 in libnssutil3.so[7f53e2395000+12000]
> [14324.004286] Code: d8 5b 5d 41 5c c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 f3 0f 1e fa 41 54 41 bc ff ff ff ff 55 53 48 89 fb e8 7a bc ff ff <48> 8b 3b 48 89 c5 e8 9f c1 ff ff 48 8b 43 38 48 39 c5 75 23 eb 2d 
> [14324.007764] rfkill: input handler enabled
> [14348.933385] rfkill: input handler disabled
> [15930.680376] DMA-API: debugging out of memory - disabling
> [16087.451698] vaapi-queue:src (10166) used greatest stack depth: 10616 bytes left
> [19689.192082] BUG: sleeping function called from invalid context at net/core/sock.c:2833
> [19689.192087] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, name: krfcommd
> [19689.192089] INFO: lockdep is turned off.
> [19689.192093] CPU: 6 PID: 1743 Comm: krfcommd Tainted: G        W         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [19689.192096] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [19689.192098] Call Trace:
> [19689.192106]  dump_stack+0x85/0xc0
> [19689.192112]  ___might_sleep.cold.72+0xac/0xbc
> [19689.192117]  lock_sock_nested+0x29/0xa0
> [19689.192142]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [19689.192150]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [19689.192157]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [19689.192163]  ? do_wait_intr_irq+0xb0/0xb0
> [19689.192179]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [19689.192183]  kthread+0x120/0x140
> [19689.192186]  ? kthread_create_worker_on_cpu+0x70/0x70
> [19689.192190]  ret_from_fork+0x3a/0x50
> [19689.377451] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input37
> [19946.455495] rfkill: input handler enabled
> [19966.489134] rfkill: input handler disabled
> [20371.084577] CIPCServer::Thr[29850]: segfault at 5 ip 00000000f002ec03 sp 00000000e5cfec50 error 4 in libdbus-1.so.3.5.8[f000f000+47000]
> [20371.084591] Code: d2 89 10 75 08 89 04 24 e8 8a b7 00 00 83 c4 18 5b c3 90 8d 74 26 00 83 ec 1c 8b 44 24 20 89 74 24 14 8b 4c 24 24 89 7c 24 18 <8b> 50 04 8b 78 14 01 d1 85 ff 89 48 04 74 17 8b 70 0c 39 f2 7d 1f 
> [20372.813679] steamwebhelper[29837]: segfault at 6b0 ip 000000000049031c sp 00007ffd41bd3470 error 4 in steamwebhelper[400000+333000]
> [20372.813691] Code: bf 98 05 00 00 00 75 0c 89 b7 c4 03 00 00 89 97 c8 03 00 00 c3 90 90 90 90 90 90 90 90 90 41 57 41 56 53 48 83 ec 10 49 89 fe <49> 8b 9e b0 06 00 00 48 85 db 0f 84 81 00 00 00 48 8b 03 4c 8b b8 
> [48395.917191] kworker/dying (13925) used greatest stack depth: 9816 bytes left
> [49435.796659] kworker/dying (30763) used greatest stack depth: 9592 bytes left
> [101633.137766] tun: Universal TUN/TAP device driver, 1.6
> [108262.958035] loop: module loaded
> [108263.324790] UDF-fs: warning (device loop0): udf_load_vrs: No anchor found
> [108263.324795] UDF-fs: Scanning with blocksize 512 failed
> [108263.325195] UDF-fs: warning (device loop0): udf_load_vrs: No anchor found
> [108263.325197] UDF-fs: Scanning with blocksize 1024 failed
> [108263.325843] UDF-fs: INFO Mounting volume 'ME_PS3_336965', timestamp 2008/09/30 04:46 (1000)
> [108278.327052] UDF-fs: warning (device loop1): udf_load_vrs: No anchor found
> [108278.327056] UDF-fs: Scanning with blocksize 512 failed
> [108278.327959] UDF-fs: warning (device loop1): udf_load_vrs: No anchor found
> [108278.327964] UDF-fs: Scanning with blocksize 1024 failed
> [108278.328375] UDF-fs: INFO Mounting volume 'ME_PS3_336965', timestamp 2008/09/30 04:46 (1000)
> [197828.263878] Process accounting resumed
> [206825.014374] transmission-gt[32305]: segfault at 1a ip 0000559f3b4471c2 sp 00007f3a3a0079b0 error 4 in transmission-gtk[559f3b3ca000+80000]
> [206825.014403] Code: a2 00 00 00 0f 1f 40 00 48 8b 93 58 02 00 00 0f b7 c5 48 8b b3 50 02 00 00 48 85 d2 74 7c 48 21 f0 4c 8b 24 c2 4d 85 e4 74 70 <41> f7 44 24 18 ff ff ff 7f 74 08 41 80 7c 24 1b 00 79 5d 49 8b 74 
> [209754.091961] kworker/dying (16179) used greatest stack depth: 9464 bytes left
> [213932.029658] kworker/dying (4941) used greatest stack depth: 9360 bytes left
> [214530.048415] kworker/dying (28133) used greatest stack depth: 9312 bytes left
> [218826.772499] kworker/dying (8339) used greatest stack depth: 9240 bytes left
> [219100.716606] mmap: Chrome_ChildIOT (10675): VmData 4295569408 exceed data ulimit 4294967296. Update limits or use boot option ignore_rlimit_data.
> [220325.915586] kworker/dying (856) used greatest stack depth: 8904 bytes left
> [226995.988782] rfkill: input handler enabled
> [226995.988987] fbcon: Taking over console
> [226995.988988] BUG: sleeping function called from invalid context at mm/slab.h:421
> [226995.988988] in_atomic(): 1, irqs_disabled(): 1, pid: 22658, name: gsd-rfkill
> [226995.988989] INFO: lockdep is turned off.
> [226995.988989] irq event stamp: 0
> [226995.988990] hardirqs last  enabled at (0): [<0000000000000000>]           (null)
> [226995.988991] hardirqs last disabled at (0): [<ffffffffa00b6b4a>] copy_process.part.32+0x72a/0x1e60
> [226995.988991] softirqs last  enabled at (0): [<ffffffffa00b6b4a>] copy_process.part.32+0x72a/0x1e60
> [226995.988992] softirqs last disabled at (0): [<0000000000000000>]           (null)
> [226995.988993] CPU: 6 PID: 22658 Comm: gsd-rfkill Tainted: G        W         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [226995.988993] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [226995.988994] Call Trace:
> [226995.988994]  dump_stack+0x85/0xc0
> [226995.988995]  ___might_sleep.cold.72+0xac/0xbc
> [226995.988995]  kmem_cache_alloc_trace+0x202/0x2f0
> [226995.988996]  ? fbcon_startup+0xae/0x300
> [226995.988996]  fbcon_startup+0xae/0x300
> [226995.988997]  do_take_over_console+0x6d/0x180
> [226995.988997]  do_fbcon_takeover+0x58/0xb0
> [226995.988997]  fbcon_output_notifier.cold.35+0x5/0x23
> [226995.988998]  notifier_call_chain+0x39/0x90
> [226995.988999]  vt_console_print+0x363/0x420
> [226995.988999]  console_unlock+0x422/0x610
> [226995.988999]  vprintk_emit+0x268/0x540
> [226995.989000]  printk+0x58/0x6f
> [226995.989000]  rfkill_fop_release.cold.16+0xc/0x11 [rfkill]
> [226995.989001]  __fput+0xc7/0x250
> [226995.989001]  task_work_run+0xa1/0xd0
> [226995.989002]  exit_to_usermode_loop+0xd8/0xe0
> [226995.989002]  do_syscall_64+0x1df/0x1f0
> [226995.989003]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [226995.989003] RIP: 0033:0x7f56ca6a157f
> [226995.989004] Code: 00 0f 05 48 3d 00 f0 ff ff 77 40 c3 0f 1f 80 00 00 00 00 53 89 fb 48 83 ec 10 e8 ec c6 01 00 89 df 89 c2 b8 03 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 2b 89 d7 89 44 24 0c e8 2e c7 01 00 8b 44 24 
> [226995.989027] RSP: 002b:00007fff7cb47db0 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
> [226995.989028] RAX: 0000000000000000 RBX: 0000000000000009 RCX: 00007f56ca6a157f
> [226995.989029] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000009
> [226995.989029] RBP: 0000000000000000 R08: 0000000000000013 R09: 000055cf4fc30b80
> [226995.989030] R10: 000055cf4fc04d70 R11: 0000000000000293 R12: 000055cf4fc27450
> [226995.989030] R13: 000055cf4fc0f040 R14: 000055cf4fc32da0 R15: 00007fff7cb47e20
> [226996.025117] BUG: scheduling while atomic: gsd-rfkill/22658/0x00000003
> [226996.025124] INFO: lockdep is turned off.
> [226996.025127] Modules linked in:
> [226996.025130]  udf
> [226996.025133]  crc_itu_t
> [226996.025136]  loop
> [226996.025139]  tun
> [226996.025141]  uinput
> [226996.025144]  macvtap
> [226996.025146]  macvlan
> [226996.025149]  tap
> [226996.025151]  nls_utf8
> [226996.025154]  isofs
> [226996.025157]  fuse
> [226996.025159]  rfcomm
> [226996.025162]  devlink
> [226996.025165]  nf_conntrack_netbios_ns
> [226996.025167]  nf_conntrack_broadcast
> [226996.025170]  xt_CT
> [226996.025172]  ip6t_rpfilter
> [226996.025175]  ip6t_REJECT
> [226996.025177]  nf_reject_ipv6
> [226996.025180]  xt_conntrack
> [226996.025182]  ip_set
> [226996.025185]  nfnetlink
> [226996.025187]  ebtable_nat
> [226996.025190]  ebtable_broute
> [226996.025193]  bridge
> [226996.025195]  stp
> [226996.025198]  llc
> [226996.025200]  ip6table_nat
> [226996.025203]  nf_conntrack_ipv6
> [226996.025205]  nf_defrag_ipv6
> [226996.025208]  nf_nat_ipv6
> [226996.025210]  ip6table_mangle
> [226996.025213]  ip6table_raw
> [226996.025215]  ip6table_security
> [226996.025218]  iptable_nat
> [226996.025220]  nf_conntrack_ipv4
> [226996.025223]  nf_defrag_ipv4
> [226996.025226]  nf_nat_ipv4
> [226996.025228]  nf_nat
> [226996.025231]  nf_conntrack
> [226996.025234]  iptable_mangle
> [226996.025237]  iptable_raw
> [226996.025239]  iptable_security
> [226996.025242]  ebtable_filter
> [226996.025244]  ebtables
> [226996.025247]  ip6table_filter
> [226996.025249]  ip6_tables
> [226996.025252]  cmac
> [226996.025255]  bnep
> [226996.025257]  sunrpc
> [226996.025259]  xfs
> [226996.025262]  vfat
> [226996.025265]  fat
> [226996.025267]  libcrc32c
> [226996.025270]  intel_rapl
> [226996.025273]  hid_logitech_hidpp
> [226996.025275]  x86_pkg_temp_thermal
> [226996.025278]  intel_powerclamp
> [226996.025280]  coretemp
> [226996.025283]  kvm_intel
> [226996.025285]  kvm
> [226996.025288]  gpio_ich
> [226996.025290]  iTCO_wdt
> [226996.025293]  iTCO_vendor_support
> [226996.025295]  ppdev
> [226996.025298]  irqbypass
> [226996.025301]  morus1280_avx2
> [226996.025303]  morus1280_sse2
> [226996.025306]  morus1280_glue
> [226996.025308]  morus640_sse2
> [226996.025311]  morus640_glue
> [226996.025313]  aegis256_aesni
> [226996.025316]  aegis128l_aesni
> [226996.025319]  aegis128_aesni
> [226996.025321]  crct10dif_pclmul
> [226996.025324]  crc32_pclmul
> [226996.025327]  ghash_clmulni_intel
> [226996.025329]  intel_cstate
> [226996.025332]  intel_uncore
> [226996.025335]  intel_rapl_perf
> [226996.025338]  btusb
> [226996.025340]  btrtl
> [226996.025343]  btbcm
> [226996.025345]  btintel
> [226996.025348]  snd_hda_codec_realtek
> [226996.025351]  bluetooth
> [226996.025354]  snd_hda_codec_hdmi
> [226996.025356]  snd_hda_codec_generic
> [226996.025359]  joydev
> [226996.025362]  snd_hda_intel
> [226996.025365]  snd_usb_audio
> [226996.025367]  snd_hda_codec
> [226996.025370]  hid_logitech_dj
> [226996.025373]  ecdh_generic
> [226996.025376]  snd_usbmidi_lib
> [226996.025379]  snd_hda_core
> [226996.025382]  rfkill
> [226996.025384]  snd_rawmidi
> [226996.025387]  snd_hwdep
> [226996.025390]  snd_seq
> [226996.025393]  snd_seq_device
> [226996.025395]  i2c_i801
> [226996.025398]  snd_pcm
> [226996.025400]  snd_timer
> [226996.025403]  snd
> [226996.025405]  mei_me
> [226996.025408]  mei
> [226996.025411]  lpc_ich
> [226996.025413]  soundcore
> [226996.025416]  parport_pc
> [226996.025418]  pcc_cpufreq
> [226996.025421]  parport
> [226996.025423]  video
> [226996.025426]  binfmt_misc
> [226996.025429]  uas
> [226996.025432]  hid_sony
> [226996.025434]  ff_memless
> [226996.025437]  usb_storage
> [226996.025440]  amdkfd
> [226996.025442]  amd_iommu_v2
> [226996.025445]  amdgpu
> [226996.025447]  chash
> [226996.025450]  i2c_algo_bit
> [226996.025452]  gpu_sched
> [226996.025455]  drm_kms_helper
> [226996.025458]  ttm
> [226996.025460]  drm
> [226996.025463]  crc32c_intel
> [226996.025466]  r8169
> [226996.025468]  mii
> [226996.025700] CPU: 6 PID: 22658 Comm: gsd-rfkill Tainted: G        W         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [226996.025701] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [226996.025701] Call Trace:
> [226996.025702]  dump_stack+0x85/0xc0
> [226996.025702]  __schedule_bug.cold.70+0x58/0x71
> [226996.025703]  __schedule+0x81c/0xb00
> [226996.025703]  schedule+0x2f/0x90
> [226996.025704]  schedule_timeout+0x1d4/0x520
> [226996.025704]  ? __next_timer_interrupt+0xc0/0xc0
> [226996.025705]  ? wait_for_completion_timeout+0x112/0x1a0
> [226996.025705]  wait_for_completion_timeout+0x13a/0x1a0
> [226996.025706]  ? wake_up_q+0x70/0x70
> [226996.025706]  drm_atomic_helper_wait_for_flip_done+0x6b/0x90 [drm_kms_helper]
> [226996.025707]  amdgpu_dm_atomic_commit_tail+0xc8d/0xd80 [amdgpu]
> [226996.025707]  commit_tail+0x3d/0x70 [drm_kms_helper]
> [226996.025708]  drm_atomic_helper_commit+0xdf/0x150 [drm_kms_helper]
> [226996.025708]  restore_fbdev_mode_atomic+0x1b1/0x220 [drm_kms_helper]
> [226996.025709]  drm_fb_helper_restore_fbdev_mode_unlocked+0x47/0x90 [drm_kms_helper]
> [226996.025709]  drm_fb_helper_set_par+0x29/0x50 [drm_kms_helper]
> [226996.025710]  fbcon_init+0x495/0x610
> [226996.025710]  visual_init+0xd5/0x130
> [226996.025711]  do_bind_con_driver+0x1dd/0x2b0
> [226996.025711]  do_take_over_console+0x120/0x180
> [226996.025712]  do_fbcon_takeover+0x58/0xb0
> [226996.025712]  fbcon_output_notifier.cold.35+0x5/0x23
> [226996.025713]  notifier_call_chain+0x39/0x90
> [226996.025713]  vt_console_print+0x363/0x420
> [226996.025713]  console_unlock+0x422/0x610
> [226996.025714]  vprintk_emit+0x268/0x540
> [226996.025714]  printk+0x58/0x6f
> [226996.025715]  rfkill_fop_release.cold.16+0xc/0x11 [rfkill]
> [226996.025715]  __fput+0xc7/0x250
> [226996.025716]  task_work_run+0xa1/0xd0
> [226996.025716]  exit_to_usermode_loop+0xd8/0xe0
> [226996.025717]  do_syscall_64+0x1df/0x1f0
> [226996.025717]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [226996.025718] RIP: 0033:0x7f56ca6a157f
> [226996.025718] Code: 00 0f 05 48 3d 00 f0 ff ff 77 40 c3 0f 1f 80 00 00 00 00 53 89 fb 48 83 ec 10 e8 ec c6 01 00 89 df 89 c2 b8 03 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 2b 89 d7 89 44 24 0c e8 2e c7 01 00 8b 44 24 
> [226996.025743] RSP: 002b:00007fff7cb47db0 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
> [226996.025744] RAX: 0000000000000000 RBX: 0000000000000009 RCX: 00007f56ca6a157f
> [226996.025745] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000009
> [226996.025746] RBP: 0000000000000000 R08: 0000000000000013 R09: 000055cf4fc30b80
> [226996.025746] R10: 000055cf4fc04d70 R11: 0000000000000293 R12: 000055cf4fc27450
> [226996.025747] R13: 000055cf4fc0f040 R14: 000055cf4fc32da0 R15: 00007fff7cb47e20
> [226996.039041] Console: switching to colour frame buffer device 480x135
> [226996.170123] BUG: scheduling while atomic: gsd-rfkill/22658/0x7fffffff
> [226996.170138] INFO: lockdep is turned off.
> [226996.170141] Modules linked in:
> [226996.170145]  udf
> [226996.170147]  crc_itu_t
> [226996.170150]  loop
> [226996.170153]  tun
> [226996.170155]  uinput
> [226996.170158]  macvtap
> [226996.170161]  macvlan
> [226996.170164]  tap
> [226996.170166]  nls_utf8
> [226996.170170]  isofs
> [226996.170172]  fuse
> [226996.170175]  rfcomm
> [226996.170178]  devlink
> [226996.170181]  nf_conntrack_netbios_ns
> [226996.170183]  nf_conntrack_broadcast
> [226996.170186]  xt_CT
> [226996.170189]  ip6t_rpfilter
> [226996.170191]  ip6t_REJECT
> [226996.170194]  nf_reject_ipv6
> [226996.170196]  xt_conntrack
> [226996.170199]  ip_set
> [226996.170202]  nfnetlink
> [226996.170204]  ebtable_nat
> [226996.170207]  ebtable_broute
> [226996.170210]  bridge
> [226996.170212]  stp
> [226996.170216]  llc
> [226996.170219]  ip6table_nat
> [226996.170222]  nf_conntrack_ipv6
> [226996.170225]  nf_defrag_ipv6
> [226996.170227]  nf_nat_ipv6
> [226996.170230]  ip6table_mangle
> [226996.170233]  ip6table_raw
> [226996.170240]  ip6table_security
> [226996.170249]  iptable_nat
> [226996.170252]  nf_conntrack_ipv4
> [226996.170255]  nf_defrag_ipv4
> [226996.170258]  nf_nat_ipv4
> [226996.170260]  nf_nat
> [226996.170263]  nf_conntrack
> [226996.170266]  iptable_mangle
> [226996.170269]  iptable_raw
> [226996.170271]  iptable_security
> [226996.170274]  ebtable_filter
> [226996.170277]  ebtables
> [226996.170280]  ip6table_filter
> [226996.170282]  ip6_tables
> [226996.170285]  cmac
> [226996.170288]  bnep
> [226996.170290]  sunrpc
> [226996.170293]  xfs
> [226996.170296]  vfat
> [226996.170298]  fat
> [226996.170301]  libcrc32c
> [226996.170304]  intel_rapl
> [226996.170307]  hid_logitech_hidpp
> [226996.170310]  x86_pkg_temp_thermal
> [226996.170313]  intel_powerclamp
> [226996.170316]  coretemp
> [226996.170318]  kvm_intel
> [226996.170321]  kvm
> [226996.170324]  gpio_ich
> [226996.170327]  iTCO_wdt
> [226996.170329]  iTCO_vendor_support
> [226996.170332]  ppdev
> [226996.170335]  irqbypass
> [226996.170338]  morus1280_avx2
> [226996.170341]  morus1280_sse2
> [226996.170344]  morus1280_glue
> [226996.170347]  morus640_sse2
> [226996.170349]  morus640_glue
> [226996.170352]  aegis256_aesni
> [226996.170355]  aegis128l_aesni
> [226996.170358]  aegis128_aesni
> [226996.170360]  crct10dif_pclmul
> [226996.170363]  crc32_pclmul
> [226996.170366]  ghash_clmulni_intel
> [226996.170369]  intel_cstate
> [226996.170371]  intel_uncore
> [226996.170374]  intel_rapl_perf
> [226996.170377]  btusb
> [226996.170379]  btrtl
> [226996.170382]  btbcm
> [226996.170385]  btintel
> [226996.170387]  snd_hda_codec_realtek
> [226996.170390]  bluetooth
> [226996.170393]  snd_hda_codec_hdmi
> [226996.170395]  snd_hda_codec_generic
> [226996.170398]  joydev
> [226996.170401]  snd_hda_intel
> [226996.170404]  snd_usb_audio
> [226996.170406]  snd_hda_codec
> [226996.170409]  hid_logitech_dj
> [226996.170412]  ecdh_generic
> [226996.170415]  snd_usbmidi_lib
> [226996.170417]  snd_hda_core
> [226996.170420]  rfkill
> [226996.170423]  snd_rawmidi
> [226996.170425]  snd_hwdep
> [226996.170428]  snd_seq
> [226996.170430]  snd_seq_device
> [226996.170433]  i2c_i801
> [226996.170436]  snd_pcm
> [226996.170439]  snd_timer
> [226996.170442]  snd
> [226996.170444]  mei_me
> [226996.170447]  mei
> [226996.170449]  lpc_ich
> [226996.170452]  soundcore
> [226996.170455]  parport_pc
> [226996.170457]  pcc_cpufreq
> [226996.170460]  parport
> [226996.170462]  video
> [226996.170465]  binfmt_misc
> [226996.170468]  uas
> [226996.170470]  hid_sony
> [226996.170473]  ff_memless
> [226996.170476]  usb_storage
> [226996.170479]  amdkfd
> [226996.170482]  amd_iommu_v2
> [226996.170484]  amdgpu
> [226996.170487]  chash
> [226996.170490]  i2c_algo_bit
> [226996.170493]  gpu_sched
> [226996.170496]  drm_kms_helper
> [226996.170499]  ttm
> [226996.170502]  drm
> [226996.170504]  crc32c_intel
> [226996.170507]  r8169
> [226996.170510]  mii
> [226996.170573] CPU: 7 PID: 22658 Comm: gsd-rfkill Tainted: G        W         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> [226996.170574] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [226996.170574] Call Trace:
> [226996.170575]  dump_stack+0x85/0xc0
> [226996.170575]  __schedule_bug.cold.70+0x58/0x71
> [226996.170576]  __schedule+0x81c/0xb00
> [226996.170576]  ? task_work_run+0x88/0xd0
> [226996.170577]  schedule+0x2f/0x90
> [226996.170577]  exit_to_usermode_loop+0x61/0xe0
> [226996.170578]  do_syscall_64+0x1df/0x1f0
> [226996.170578]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [226996.170579] RIP: 0033:0x7f56ca6a157f
> [226996.170579] Code: 00 0f 05 48 3d 00 f0 ff ff 77 40 c3 0f 1f 80 00 00 00 00 53 89 fb 48 83 ec 10 e8 ec c6 01 00 89 df 89 c2 b8 03 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 2b 89 d7 89 44 24 0c e8 2e c7 01 00 8b 44 24 
> [226996.170603] RSP: 002b:00007fff7cb47db0 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
> [226996.170604] RAX: 0000000000000000 RBX: 0000000000000009 RCX: 00007f56ca6a157f
> [226996.170605] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000009
> [226996.170606] RBP: 0000000000000000 R08: 0000000000000013 R09: 000055cf4fc30b80
> [226996.170606] R10: 000055cf4fc04d70 R11: 0000000000000293 R12: 000055cf4fc27450
> [226996.170607] R13: 000055cf4fc0f040 R14: 000055cf4fc32da0 R15: 00007fff7cb47e20
> [227155.740621] rfkill: input handler disabled
> 
