Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80F368E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 04:37:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so4739192edz.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 01:37:49 -0800 (PST)
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id d37si68312edb.381.2019.01.18.01.37.42
        for <linux-mm@kvack.org>;
        Fri, 18 Jan 2019 01:37:42 -0800 (PST)
Date: Fri, 18 Jan 2019 10:37:40 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: BUG: sleeping function called from invalid context at
 kernel/locking/mutex.c:908
Message-ID: <20190118093736.ypomka5wwxgtjui3@d104.suse.de>
References: <CABXGCsOLF48xC30CofbJQMkiRa7vS8pGKu8T0Drskc4QxLy24A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOLF48xC30CofbJQMkiRa7vS8pGKu8T0Drskc4QxLy24A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 18, 2019 at 02:21:58PM +0500, Mikhail Gavrilov wrote:
> Hi folks.
> 
> Starting from 5.0 rc1 every time after launch atop I see subject error message.
> 
> And this issue afle negatively impact on system performance.
> 
> Unclear on which subsystem it related but I hope here in mm list
> somebody help clarify what is happened.
> 
> Thanks.
> 
> Full dmesg also attached.
> 
> [ 2164.694709] BUG: sleeping function called from invalid context at
> kernel/locking/mutex.c:908
> [ 2164.694724] in_atomic(): 1, irqs_disabled(): 0, pid: 10498, name: atop

I have little knowledge about that, but i looks like it is because we are running
in atomic context (preemption disabled), and that is not allowed.

I think it is because igb_get_stats64() grabs a mutex and then calls igb_update_stats().
igb_update_stats() calls rcu_read_lock()-> __rcu_read_lock().
If !CONFIG_PREEMPT_RCU, __rcu_read_lock() disables preemption by preempt_disable().

Anyway, this does not look like a linux-mm issue.

> [ 2164.694729] 2 locks held by atop/10498:
> [ 2164.694732]  #0: 0000000061e564e5 (&p->lock){+.+.}, at: seq_read+0x41/0x430
> [ 2164.694753]  #1: 0000000081e34167 (rcu_read_lock){....}, at:
> dev_seq_start+0x5/0x120
> [ 2164.694762] CPU: 10 PID: 10498 Comm: atop Tainted: G         C
>   5.0.0-0.rc2.git1.2.fc30.x86_64 #1
> [ 2164.694765] Hardware name: System manufacturer System Product
> Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [ 2164.694768] Call Trace:
> [ 2164.694773]  dump_stack+0x85/0xc0
> [ 2164.694778]  ___might_sleep.cold.73+0xac/0xbc
> [ 2164.694783]  __mutex_lock+0x55/0x9a0
> [ 2164.694788]  ? seq_vprintf+0x30/0x50
> [ 2164.694792]  ? seq_printf+0x53/0x70
> [ 2164.694806]  ? igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694813]  igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694818]  dev_get_stats+0x5b/0xc0
> [ 2164.694822]  dev_seq_printf_stats+0x32/0xe0
> [ 2164.694836]  dev_seq_show+0x10/0x30
> [ 2164.694840]  seq_read+0x2fd/0x430
> [ 2164.694847]  proc_reg_read+0x39/0x60
> [ 2164.694852]  __vfs_read+0x36/0x1a0
> [ 2164.694861]  vfs_read+0x9f/0x160
> [ 2164.694866]  ksys_read+0x52/0xc0
> [ 2164.694872]  do_syscall_64+0x60/0x1f0
> [ 2164.694876]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 2164.694880] RIP: 0033:0x7fa0f51bd255
> [ 2164.694883] Code: fe ff ff 50 48 8d 3d 2a 03 0a 00 e8 35 01 02 00
> 0f 1f 44 00 00 f3 0f 1e fa 48 8d 05 c5 94 0d 00 8b 00 85 c0 75 0f 31
> c0 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5
> 53 89
> [ 2164.694886] RSP: 002b:00007ffe79288db8 EFLAGS: 00000246 ORIG_RAX:
> 0000000000000000
> [ 2164.694890] RAX: ffffffffffffffda RBX: 0000000000a55260 RCX: 00007fa0f51bd255
> [ 2164.694892] RDX: 0000000000000400 RSI: 0000000000a55490 RDI: 0000000000000004
> [ 2164.694895] RBP: 0000000000000d68 R08: 0000000000000001 R09: 0000000000000000
> [ 2164.694898] R10: 00007fa0f50a3740 R11: 0000000000000246 R12: 00007fa0f528d740
> [ 2164.694900] R13: 00007fa0f528e340 R14: 00000000000007ff R15: 0000000000a55260
> 
> 
> 
> --
> Best Regards,
> Mike Gavrilov.

> [    0.000000] Linux version 5.0.0-0.rc2.git1.2.fc30.x86_64 (mockbuild@f6c8869bddb94ca3a809fa78d9bc66cd) (gcc version 8.2.1 20190109 (Red Hat 8.2.1-7) (GCC)) #1 SMP Tue Jan 15 23:45:21 +05 2019
> [    0.000000] Command line: BOOT_IMAGE=(hd2,gpt2)/boot/vmlinuz-5.0.0-0.rc2.git1.2.fc30.x86_64 root=UUID=7788c3ba-4ec6-45c8-875b-4a6900af0621 ro resume=UUID=8ae7c2bb-85ca-44f9-b884-b114e058d538 rhgb mem_encrypt=off scsi_mod.use_blk_mq=1 log_buf_len=4M
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
> [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
> [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> [    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'compacted' format.
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000009cfffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000009d00000-0x0000000009ffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000000a000000-0x000000000a1fffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000a200000-0x000000000a209fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x000000000a20a000-0x000000000affffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000b000000-0x000000000b01ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x000000000b020000-0x00000000da043fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000da044000-0x00000000db540fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000db541000-0x00000000db568fff] ACPI data
> [    0.000000] BIOS-e820: [mem 0x00000000db569000-0x00000000dba19fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000dba1a000-0x00000000dc591fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000dc592000-0x00000000deffffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000df000000-0x00000000dfffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fd100000-0x00000000fdffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fea00000-0x00000000fea0ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feb80000-0x00000000fec01fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec10fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec30000-0x00000000fec30fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed40000-0x00000000fed44fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed8ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fedc2000-0x00000000fedcffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fedd4000-0x00000000fedd5fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000feefffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000081f37ffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] e820: update [mem 0xccb06018-0xccb17057] usable ==> usable
> [    0.000000] e820: update [mem 0xccb06018-0xccb17057] usable ==> usable
> [    0.000000] e820: update [mem 0xccaec018-0xccb05457] usable ==> usable
> [    0.000000] e820: update [mem 0xccaec018-0xccb05457] usable ==> usable
> [    0.000000] extended physical RAM map:
> [    0.000000] reserve setup_data: [mem 0x0000000000000000-0x000000000009ffff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000000a0000-0x00000000000fffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000000100000-0x0000000009cfffff] usable
> [    0.000000] reserve setup_data: [mem 0x0000000009d00000-0x0000000009ffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x000000000a000000-0x000000000a1fffff] usable
> [    0.000000] reserve setup_data: [mem 0x000000000a200000-0x000000000a209fff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x000000000a20a000-0x000000000affffff] usable
> [    0.000000] reserve setup_data: [mem 0x000000000b000000-0x000000000b01ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x000000000b020000-0x00000000ccaec017] usable
> [    0.000000] reserve setup_data: [mem 0x00000000ccaec018-0x00000000ccb05457] usable
> [    0.000000] reserve setup_data: [mem 0x00000000ccb05458-0x00000000ccb06017] usable
> [    0.000000] reserve setup_data: [mem 0x00000000ccb06018-0x00000000ccb17057] usable
> [    0.000000] reserve setup_data: [mem 0x00000000ccb17058-0x00000000da043fff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000da044000-0x00000000db540fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000db541000-0x00000000db568fff] ACPI data
> [    0.000000] reserve setup_data: [mem 0x00000000db569000-0x00000000dba19fff] ACPI NVS
> [    0.000000] reserve setup_data: [mem 0x00000000dba1a000-0x00000000dc591fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000dc592000-0x00000000deffffff] usable
> [    0.000000] reserve setup_data: [mem 0x00000000df000000-0x00000000dfffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fd100000-0x00000000fdffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fea00000-0x00000000fea0ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000feb80000-0x00000000fec01fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fec10000-0x00000000fec10fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fec30000-0x00000000fec30fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed00000-0x00000000fed00fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed40000-0x00000000fed44fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fed80000-0x00000000fed8ffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fedc2000-0x00000000fedcffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fedd4000-0x00000000fedd5fff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000fee00000-0x00000000feefffff] reserved
> [    0.000000] reserve setup_data: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] reserve setup_data: [mem 0x0000000100000000-0x000000081f37ffff] usable
> [    0.000000] efi: EFI v2.60 by American Megatrends
> [    0.000000] efi:  ACPI 2.0=0xdb549000  ACPI=0xdb549000  SMBIOS=0xdc455000  SMBIOS 3.0=0xdc454000  ESRT=0xd77d4b18  MEMATTR=0xd7578018 
> [    0.000000] secureboot: Secure boot disabled
> [    0.000000] SMBIOS 3.1.1 present.
> [    0.000000] DMI: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [    0.000000] tsc: Fast TSC calibration failed
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] last_pfn = 0x81f380 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF write-through
> [    0.000000]   C0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
> [    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
> [    0.000000]   2 base 0000C0000000 mask FFFFE0000000 write-back
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] TOM2: 0000000820000000 aka 33280M
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
> [    0.000000] e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
> [    0.000000] last_pfn = 0xdf000 max_arch_pfn = 0x400000000
> [    0.000000] esrt: Reserving ESRT space from 0x00000000d77d4b18 to 0x00000000d77d4b50.
> [    0.000000] check: Scanning 1 areas for low memory corruption
> [    0.000000] Base memory trampoline at [(____ptrval____)] 96000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] BRK [0x4bd401000, 0x4bd401fff] PGTABLE
> [    0.000000] BRK [0x4bd402000, 0x4bd402fff] PGTABLE
> [    0.000000] BRK [0x4bd403000, 0x4bd403fff] PGTABLE
> [    0.000000] BRK [0x4bd404000, 0x4bd404fff] PGTABLE
> [    0.000000] BRK [0x4bd405000, 0x4bd405fff] PGTABLE
> [    0.000000] BRK [0x4bd406000, 0x4bd406fff] PGTABLE
> [    0.000000] BRK [0x4bd407000, 0x4bd407fff] PGTABLE
> [    0.000000] BRK [0x4bd408000, 0x4bd408fff] PGTABLE
> [    0.000000] BRK [0x4bd409000, 0x4bd409fff] PGTABLE
> [    0.000000] BRK [0x4bd40a000, 0x4bd40afff] PGTABLE
> [    0.000000] BRK [0x4bd40b000, 0x4bd40bfff] PGTABLE
> [    0.000000] BRK [0x4bd40c000, 0x4bd40cfff] PGTABLE
> [    0.000000] printk: log_buf_len: 4194304 bytes
> [    0.000000] printk: early log buf free: 253112(96%)
> [    0.000000] RAMDISK: [mem 0x5b176000-0x5cce4fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000DB549000 000024 (v02 ALASKA)
> [    0.000000] ACPI: XSDT 0x00000000DB549098 0000A4 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FACP 0x00000000DB557490 000114 (v06 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI BIOS Warning (bug): Optional FADT field Pm2ControlBlock has valid Length but zero Address: 0x0000000000000000/0x1 (20181213/tbfadt-624)
> [    0.000000] ACPI: DSDT 0x00000000DB5491D0 00E2BC (v02 ALASKA A M I    01072009 INTL 20120913)
> [    0.000000] ACPI: FACS 0x00000000DBA02D80 000040
> [    0.000000] ACPI: APIC 0x00000000DB5575A8 0000DE (v03 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FPDT 0x00000000DB557688 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: FIDT 0x00000000DB5576D0 00009C (v01 ALASKA A M I    01072009 AMI  00010013)
> [    0.000000] ACPI: SSDT 0x00000000DB557770 008C98 (v02 AMD    AMD ALIB 00000002 MSFT 04000000)
> [    0.000000] ACPI: SSDT 0x00000000DB560408 002314 (v01 AMD    AMD CPU  00000001 AMD  00000001)
> [    0.000000] ACPI: CRAT 0x00000000DB562720 000F50 (v01 AMD    AMD CRAT 00000001 AMD  00000001)
> [    0.000000] ACPI: CDIT 0x00000000DB563670 000029 (v01 AMD    AMD CDIT 00000001 AMD  00000001)
> [    0.000000] ACPI: SSDT 0x00000000DB5636A0 002DA8 (v01 AMD    AMD AOD  00000001 INTL 20120913)
> [    0.000000] ACPI: MCFG 0x00000000DB566448 00003C (v01 ALASKA A M I    01072009 MSFT 00010013)
> [    0.000000] ACPI: SSDT 0x00000000DB5681A8 0000BF (v01 AMD    AMD PT   00001000 INTL 20120913)
> [    0.000000] ACPI: HPET 0x00000000DB5664E0 000038 (v01 ALASKA A M I    01072009 AMI  00000005)
> [    0.000000] ACPI: SSDT 0x00000000DB566518 000024 (v01 AMDFCH FCHZP    00001000 INTL 20120913)
> [    0.000000] ACPI: UEFI 0x00000000DB566540 000042 (v01                 00000000      00000000)
> [    0.000000] ACPI: IVRS 0x00000000DB566588 0000D0 (v02 AMD    AMD IVRS 00000001 AMD  00000000)
> [    0.000000] ACPI: SSDT 0x00000000DB566658 001B4E (v01 AMD    AmdTable 00000001 INTL 20120913)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000081f37ffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x81ef55000-0x81ef7ffff]
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000000081f37ffff]
> [    0.000000]   Device   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000009cfffff]
> [    0.000000]   node   0: [mem 0x000000000a000000-0x000000000a1fffff]
> [    0.000000]   node   0: [mem 0x000000000a20a000-0x000000000affffff]
> [    0.000000]   node   0: [mem 0x000000000b020000-0x00000000da043fff]
> [    0.000000]   node   0: [mem 0x00000000dc592000-0x00000000deffffff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x000000081f37ffff]
> [    0.000000] Zeroed struct page in unavailable ranges: 14553 pages
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000081f37ffff]
> [    0.000000] On node 0 totalpages: 8370855
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 26 pages reserved
> [    0.000000]   DMA zone: 3999 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 14047 pages used for memmap
> [    0.000000]   DMA32 zone: 898952 pages, LIFO batch:63
> [    0.000000]   Normal zone: 116686 pages used for memmap
> [    0.000000]   Normal zone: 7467904 pages, LIFO batch:63
> [    0.000000] ACPI: PM-Timer IO Port: 0x808
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
> [    0.000000] IOAPIC[0]: apic_id 17, version 33, address 0xfec00000, GSI 0-23
> [    0.000000] IOAPIC[1]: apic_id 18, version 33, address 0xfec01000, GSI 24-55
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x10228201 base: 0xfed00000
> [    0.000000] smpboot: Allowing 16 CPUs, 0 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x09d00000-0x09ffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0a200000-0x0a209fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0b000000-0x0b01ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xccaec000-0xccaecfff]
> [    0.000000] PM: Registered nosave memory: [mem 0xccb05000-0xccb05fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xccb06000-0xccb06fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xccb17000-0xccb17fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xda044000-0xdb540fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb541000-0xdb568fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdb569000-0xdba19fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdba1a000-0xdc591fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xdf000000-0xdfffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xf7ffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfd0fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfd100000-0xfdffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfe000000-0xfe9fffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfea00000-0xfea0ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfea10000-0xfeb7ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfeb80000-0xfec01fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec02000-0xfec0ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfec10fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec11000-0xfec2ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec30000-0xfec30fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfec31000-0xfecfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed00fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed01000-0xfed3ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed40000-0xfed44fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed45000-0xfed7ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed8ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfed90000-0xfedc1fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedc2000-0xfedcffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd0000-0xfedd3fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd4000-0xfedd5fff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfedd6000-0xfedfffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfeefffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xfef00000-0xfeffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
> [    0.000000] [mem 0xe0000000-0xf7ffffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
> [    0.000000] random: get_random_bytes called from start_kernel+0x9d/0x547 with crng_init=0
> [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:16 nr_cpu_ids:16 nr_node_ids:1
> [    0.000000] percpu: Embedded 494 pages/cpu @(____ptrval____) s1986560 r8192 d28672 u2097152
> [    0.000000] pcpu-alloc: s1986560 r8192 d28672 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
> [    0.000000] pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 [0] 12 [0] 13 [0] 14 [0] 15 
> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 8240032
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=(hd2,gpt2)/boot/vmlinuz-5.0.0-0.rc2.git1.2.fc30.x86_64 root=UUID=7788c3ba-4ec6-45c8-875b-4a6900af0621 ro resume=UUID=8ae7c2bb-85ca-44f9-b884-b114e058d538 rhgb mem_encrypt=off scsi_mod.use_blk_mq=1 log_buf_len=4M
> [    0.000000] Memory: 32693384K/33483420K available (14339K kernel code, 3223K rwdata, 4496K rodata, 4868K init, 18628K bss, 790036K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=16, Nodes=1
> [    0.000000] ftrace: allocating 39297 entries in 154 pages
> [    0.000000] Running RCU self tests
> [    0.000000] rcu: Hierarchical RCU implementation.
> [    0.000000] rcu: 	RCU lockdep checking is enabled.
> [    0.000000] rcu: 	RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=16.
> [    0.000000] rcu: 	RCU callback double-/use-after-free debug enabled.
> [    0.000000] 	Tasks RCU enabled.
> [    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 100 jiffies.
> [    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=16
> [    0.000000] NR_IRQS: 524544, nr_irqs: 1096, preallocated irqs: 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] printk: console [tty0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 7775 kB
> [    0.000000]  per task-struct memory footprint: 2688 bytes
> [    0.000000] kmemleak: Kernel memory leak detector disabled
> [    0.000000] ACPI: Core revision 20181213
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] APIC: Switch to symmetric I/O mode setup
> [    0.001000] Switched APIC routing to physical flat.
> [    0.001000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.009000] tsc: Unable to calibrate against PIT
> [    0.009000] tsc: using HPET reference calibration
> [    0.009000] tsc: Detected 3692.620 MHz processor
> [    0.000012] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x6a74336c1b6, max_idle_ns: 881590820646 ns
> [    0.000035] Calibrating delay loop (skipped), value calculated using timer frequency.. 7385.24 BogoMIPS (lpj=3692620)
> [    0.000049] pid_max: default: 32768 minimum: 301
> [    0.008038] ---[ User Space ]---
> [    0.008045] 0x0000000000000000-0x0000000000008000          32K     RW                     x  pte
> [    0.008058] 0x0000000000008000-0x000000000003f000         220K                               pte
> [    0.008070] 0x000000000003f000-0x0000000000040000           4K                               pte
> [    0.008082] 0x0000000000040000-0x00000000000a0000         384K     RW                     x  pte
> [    0.008096] 0x00000000000a0000-0x0000000000200000        1408K                               pte
> [    0.008108] 0x0000000000200000-0x0000000001000000          14M                               pmd
> [    0.008119] 0x0000000001000000-0x0000000001020000         128K                               pte
> [    0.008133] 0x0000000001020000-0x0000000001200000        1920K                               pte
> [    0.008147] 0x0000000001200000-0x0000000040000000        1006M                               pmd
> [    0.008158] 0x0000000040000000-0x00000000c0000000           2G                               pud
> [    0.008170] 0x00000000c0000000-0x00000000cce00000         206M                               pmd
> [    0.008183] 0x00000000cce00000-0x00000000ccf7e000        1528K                               pte
> [    0.008195] 0x00000000ccf7e000-0x00000000cd000000         520K     RW                     x  pte
> [    0.008208] 0x00000000cd000000-0x00000000d7600000         166M     RW         PSE         x  pmd
> [    0.008223] 0x00000000d7600000-0x00000000d77d5000        1876K     RW                     x  pte
> [    0.008235] 0x00000000d77d5000-0x00000000d7800000         172K                               pte
> [    0.008246] 0x00000000d7800000-0x00000000d8e00000          22M                               pmd
> [    0.008259] 0x00000000d8e00000-0x00000000d8f20000        1152K                               pte
> [    0.008272] 0x00000000d8f20000-0x00000000d9000000         896K                               pte
> [    0.008283] 0x00000000d9000000-0x00000000d9200000           2M                               pmd
> [    0.008295] 0x00000000d9200000-0x00000000d928d000         564K                               pte
> [    0.008308] 0x00000000d928d000-0x00000000d9400000        1484K                               pte
> [    0.008319] 0x00000000d9400000-0x00000000da000000          12M                               pmd
> [    0.008331] 0x00000000da000000-0x00000000da044000         272K                               pte
> [    0.008344] 0x00000000da044000-0x00000000da200000        1776K                               pte
> [    0.008355] 0x00000000da200000-0x00000000dba00000          24M                               pmd
> [    0.008367] 0x00000000dba00000-0x00000000dba1a000         104K                               pte
> [    0.008381] 0x00000000dba1a000-0x00000000dbc00000        1944K     RW                     NX pte
> [    0.008393] 0x00000000dbc00000-0x00000000dc400000           8M     RW         PSE         NX pmd
> [    0.008407] 0x00000000dc400000-0x00000000dc50b000        1068K     RW                     NX pte
> [    0.008419] 0x00000000dc50b000-0x00000000dc50e000          12K     ro                     x  pte
> [    0.008431] 0x00000000dc50e000-0x00000000dc513000          20K     RW                     NX pte
> [    0.008443] 0x00000000dc513000-0x00000000dc514000           4K     ro                     x  pte
> [    0.008456] 0x00000000dc514000-0x00000000dc518000          16K     RW                     NX pte
> [    0.008468] 0x00000000dc518000-0x00000000dc51c000          16K     ro                     x  pte
> [    0.008480] 0x00000000dc51c000-0x00000000dc521000          20K     RW                     NX pte
> [    0.008492] 0x00000000dc521000-0x00000000dc522000           4K     ro                     x  pte
> [    0.008505] 0x00000000dc522000-0x00000000dc526000          16K     RW                     NX pte
> [    0.008517] 0x00000000dc526000-0x00000000dc527000           4K     ro                     x  pte
> [    0.008529] 0x00000000dc527000-0x00000000dc52c000          20K     RW                     NX pte
> [    0.008541] 0x00000000dc52c000-0x00000000dc539000          52K     ro                     x  pte
> [    0.008554] 0x00000000dc539000-0x00000000dc540000          28K     RW                     NX pte
> [    0.008566] 0x00000000dc540000-0x00000000dc543000          12K     ro                     x  pte
> [    0.008578] 0x00000000dc543000-0x00000000dc549000          24K     RW                     NX pte
> [    0.008590] 0x00000000dc549000-0x00000000dc54a000           4K     ro                     x  pte
> [    0.009032] 0x00000000dc54a000-0x00000000dc54f000          20K     RW                     NX pte
> [    0.009044] 0x00000000dc54f000-0x00000000dc550000           4K     ro                     x  pte
> [    0.009056] 0x00000000dc550000-0x00000000dc555000          20K     RW                     NX pte
> [    0.009069] 0x00000000dc555000-0x00000000dc556000           4K     ro                     x  pte
> [    0.009081] 0x00000000dc556000-0x00000000dc55b000          20K     RW                     NX pte
> [    0.009093] 0x00000000dc55b000-0x00000000dc55c000           4K     ro                     x  pte
> [    0.009105] 0x00000000dc55c000-0x00000000dc561000          20K     RW                     NX pte
> [    0.009117] 0x00000000dc561000-0x00000000dc562000           4K     ro                     x  pte
> [    0.009130] 0x00000000dc562000-0x00000000dc567000          20K     RW                     NX pte
> [    0.009142] 0x00000000dc567000-0x00000000dc568000           4K     ro                     x  pte
> [    0.009154] 0x00000000dc568000-0x00000000dc56c000          16K     RW                     NX pte
> [    0.009166] 0x00000000dc56c000-0x00000000dc576000          40K     ro                     x  pte
> [    0.009179] 0x00000000dc576000-0x00000000dc57f000          36K     RW                     NX pte
> [    0.009191] 0x00000000dc57f000-0x00000000dc584000          20K     ro                     x  pte
> [    0.009203] 0x00000000dc584000-0x00000000dc589000          20K     RW                     NX pte
> [    0.009215] 0x00000000dc589000-0x00000000dc58d000          16K     ro                     x  pte
> [    0.009228] 0x00000000dc58d000-0x00000000dc592000          20K     RW                     NX pte
> [    0.009240] 0x00000000dc592000-0x00000000dc600000         440K                               pte
> [    0.009252] 0x00000000dc600000-0x00000000df000000          42M                               pmd
> [    0.009264] 0x00000000df000000-0x00000000f8000000         400M                               pmd
> [    0.009275] 0x00000000f8000000-0x00000000fc000000          64M     RW         PSE         x  pmd
> [    0.009287] 0x00000000fc000000-0x00000000fd000000          16M                               pmd
> [    0.009300] 0x00000000fd000000-0x00000000fd100000           1M                               pte
> [    0.009312] 0x00000000fd100000-0x00000000fd200000           1M     RW                     x  pte
> [    0.009325] 0x00000000fd200000-0x00000000fe000000          14M     RW         PSE         x  pmd
> [    0.009337] 0x00000000fe000000-0x00000000fea00000          10M                               pmd
> [    0.009348] 0x00000000fea00000-0x00000000fea10000          64K     RW                     x  pte
> [    0.009362] 0x00000000fea10000-0x00000000feb80000        1472K                               pte
> [    0.009374] 0x00000000feb80000-0x00000000fec02000         520K     RW                     x  pte
> [    0.009387] 0x00000000fec02000-0x00000000fec10000          56K                               pte
> [    0.009398] 0x00000000fec10000-0x00000000fec11000           4K     RW                     x  pte
> [    0.009410] 0x00000000fec11000-0x00000000fec30000         124K                               pte
> [    0.009421] 0x00000000fec30000-0x00000000fec31000           4K     RW                     x  pte
> [    0.009435] 0x00000000fec31000-0x00000000fed00000         828K                               pte
> [    0.009446] 0x00000000fed00000-0x00000000fed01000           4K     RW                     x  pte
> [    0.009458] 0x00000000fed01000-0x00000000fed40000         252K                               pte
> [    0.009469] 0x00000000fed40000-0x00000000fed45000          20K     RW                     x  pte
> [    0.009482] 0x00000000fed45000-0x00000000fed80000         236K                               pte
> [    0.009493] 0x00000000fed80000-0x00000000fed90000          64K     RW                     x  pte
> [    0.009506] 0x00000000fed90000-0x00000000fedc2000         200K                               pte
> [    0.009517] 0x00000000fedc2000-0x00000000fedd0000          56K     RW                     x  pte
> [    0.009529] 0x00000000fedd0000-0x00000000fedd4000          16K                               pte
> [    0.009540] 0x00000000fedd4000-0x00000000fedd6000           8K     RW                     x  pte
> [    0.009553] 0x00000000fedd6000-0x00000000fee00000         168K                               pte
> [    0.009565] 0x00000000fee00000-0x00000000fef00000           1M     RW                     x  pte
> [    0.009579] 0x00000000fef00000-0x00000000ff000000           1M                               pte
> [    0.009590] 0x00000000ff000000-0x0000000100000000          16M     RW         PSE         x  pmd
> [    0.009603] 0x0000000100000000-0x00000007c0000000          27G                               pud
> [    0.009616] 0x00000007c0000000-0x00000007fc800000         968M                               pmd
> [    0.009630] 0x00000007fc800000-0x00000007fc9c0000        1792K                               pte
> [    0.009641] 0x00000007fc9c0000-0x00000007fc9c2000           8K     RW                     NX pte
> [    0.009653] 0x00000007fc9c2000-0x00000007fca00000         248K                               pte
> [    0.009665] 0x00000007fca00000-0x0000000800000000          54M                               pmd
> [    0.009678] 0x0000000800000000-0x0000008000000000         480G                               pud
> [    0.009693] 0x0000008000000000-0xffff800000000000   17179737600G                               pgd
> [    0.009704] ---[ Kernel Space ]---
> [    0.009709] 0xffff800000000000-0xffff808000000000         512G                               pgd
> [    0.009720] ---[ LDT remap ]---
> [    0.009725] 0xffff808000000000-0xffff810000000000         512G                               pgd
> [    0.009736] ---[ Low Kernel Mapping ]---
> [    0.009742] 0xffff810000000000-0xffff818000000000         512G                               pgd
> [    0.009753] ---[ vmalloc() Area ]---
> [    0.009758] 0xffff818000000000-0xffff820000000000         512G                               pgd
> [    0.009769] ---[ Vmemmap ]---
> [    0.009774] 0xffff820000000000-0xffff998000000000       24064G                               pgd
> [    0.009786] 0xffff998000000000-0xffff999900000000         100G                               pud
> [    0.009800] 0xffff999900000000-0xffff999900200000           2M     RW                 GLB NX pte
> [    0.009813] 0xffff999900200000-0xffff999909c00000         154M     RW         PSE     GLB NX pmd
> [    0.009827] 0xffff999909c00000-0xffff999909d00000           1M     RW                 GLB NX pte
> [    0.009840] 0xffff999909d00000-0xffff999909e00000           1M                               pte
> [    0.009851] 0xffff999909e00000-0xffff99990a000000           2M                               pmd
> [    0.009863] 0xffff99990a000000-0xffff99990a200000           2M     RW         PSE     GLB NX pmd
> [    0.009875] 0xffff99990a200000-0xffff99990a20a000          40K                               pte
> [    0.009889] 0xffff99990a20a000-0xffff99990a400000        2008K     RW                 GLB NX pte
> [    0.009901] 0xffff99990a400000-0xffff99990b000000          12M     RW         PSE     GLB NX pmd
> [    0.009914] 0xffff99990b000000-0xffff99990b020000         128K                               pte
> [    0.009927] 0xffff99990b020000-0xffff99990b200000        1920K     RW                 GLB NX pte
> [    0.009942] 0xffff99990b200000-0xffff999940000000         846M     RW         PSE     GLB NX pmd
> [    0.009954] 0xffff999940000000-0xffff9999c0000000           2G     RW         PSE     GLB NX pud
> [    0.009967] 0xffff9999c0000000-0xffff9999da000000         416M     RW         PSE     GLB NX pmd
> [    0.009980] 0xffff9999da000000-0xffff9999da044000         272K     RW                 GLB NX pte
> [    0.009995] 0xffff9999da044000-0xffff9999da200000        1776K                               pte
> [    0.010006] 0xffff9999da200000-0xffff9999dc400000          34M                               pmd
> [    0.010019] 0xffff9999dc400000-0xffff9999dc592000        1608K                               pte
> [    0.010032] 0xffff9999dc592000-0xffff9999dc600000         440K     RW                 GLB NX pte
> [    0.010045] 0xffff9999dc600000-0xffff9999df000000          42M     RW         PSE     GLB NX pmd
> [    0.010058] 0xffff9999df000000-0xffff999a00000000         528M                               pmd
> [    0.010069] 0xffff999a00000000-0xffff99a100000000          28G     RW         PSE     GLB NX pud
> [    0.010083] 0xffff99a100000000-0xffff99a11f200000         498M     RW         PSE     GLB NX pmd
> [    0.010101] 0xffff99a11f200000-0xffff99a11f380000        1536K     RW                 GLB NX pte
> [    0.010116] 0xffff99a11f380000-0xffff99a11f400000         512K                               pte
> [    0.010129] 0xffff99a11f400000-0xffff99a140000000         524M                               pmd
> [    0.010142] 0xffff99a140000000-0xffff9a0000000000         379G                               pud
> [    0.010154] 0xffff9a0000000000-0xffffaa0000000000          16T                               pgd
> [    0.010166] 0xffffaa0000000000-0xffffaa0d00000000          52G                               pud
> [    0.010177] 0xffffaa0d00000000-0xffffaa0d00001000           4K     RW                 GLB NX pte
> [    0.010190] 0xffffaa0d00001000-0xffffaa0d00002000           4K                               pte
> [    0.010202] 0xffffaa0d00002000-0xffffaa0d00003000           4K     RW                 GLB NX pte
> [    0.010214] 0xffffaa0d00003000-0xffffaa0d00004000           4K                               pte
> [    0.010226] 0xffffaa0d00004000-0xffffaa0d00007000          12K     RW                 GLB NX pte
> [    0.010238] 0xffffaa0d00007000-0xffffaa0d00008000           4K                               pte
> [    0.010250] 0xffffaa0d00008000-0xffffaa0d0000a000           8K     RW                 GLB NX pte
> [    0.010262] 0xffffaa0d0000a000-0xffffaa0d0000b000           4K                               pte
> [    0.010274] 0xffffaa0d0000b000-0xffffaa0d0000c000           4K     RW                 GLB NX pte
> [    0.010286] 0xffffaa0d0000c000-0xffffaa0d0000d000           4K                               pte
> [    0.010298] 0xffffaa0d0000d000-0xffffaa0d0000e000           4K     RW     PCD         GLB NX pte
> [    0.010311] 0xffffaa0d0000e000-0xffffaa0d00010000           8K                               pte
> [    0.010322] 0xffffaa0d00010000-0xffffaa0d0001f000          60K     RW                 GLB NX pte
> [    0.010335] 0xffffaa0d0001f000-0xffffaa0d00020000           4K                               pte
> [    0.010346] 0xffffaa0d00020000-0xffffaa0d0002a000          40K     RW                 GLB NX pte
> [    0.010359] 0xffffaa0d0002a000-0xffffaa0d0002c000           8K                               pte
> [    0.010370] 0xffffaa0d0002c000-0xffffaa0d00030000          16K     RW                 GLB NX pte
> [    0.010383] 0xffffaa0d00030000-0xffffaa0d00034000          16K                               pte
> [    0.010395] 0xffffaa0d00034000-0xffffaa0d00037000          12K     RW                 GLB NX pte
> [    0.010408] 0xffffaa0d00037000-0xffffaa0d00080000         292K                               pte
> [    0.010420] 0xffffaa0d00080000-0xffffaa0d00100000         512K     RW     PCD         GLB NX pte
> [    0.010434] 0xffffaa0d00100000-0xffffaa0d00200000           1M                               pte
> [    0.010448] 0xffffaa0d00200000-0xffffaa0d40000000        1022M                               pmd
> [    0.010461] 0xffffaa0d40000000-0xffffaa8000000000         459G                               pud
> [    0.010474] 0xffffaa8000000000-0xffffe50000000000       59904G                               pgd
> [    0.010488] 0xffffe50000000000-0xffffe56880000000         418G                               pud
> [    0.010499] 0xffffe56880000000-0xffffe56883800000          56M     RW         PSE     GLB NX pmd
> [    0.010512] 0xffffe56883800000-0xffffe56884000000           8M                               pmd
> [    0.010525] 0xffffe56884000000-0xffffe568a0800000         456M     RW         PSE     GLB NX pmd
> [    0.010538] 0xffffe568a0800000-0xffffe568c0000000         504M                               pmd
> [    0.010550] 0xffffe568c0000000-0xffffe58000000000          93G                               pud
> [    0.010562] 0xffffe58000000000-0xfffffe0000000000       25088G                               pgd
> [    0.010574] ---[ CPU entry Area ]---
> [    0.010579] 0xfffffe0000000000-0xfffffe0000002000           8K     ro                 GLB NX pte
> [    0.010592] 0xfffffe0000002000-0xfffffe0000003000           4K     RW                 GLB NX pte
> [    0.010604] 0xfffffe0000003000-0xfffffe0000006000          12K     ro                 GLB NX pte
> [    0.010617] 0xfffffe0000006000-0xfffffe000000b000          20K     RW                 GLB NX pte
> [    0.010630] 0xfffffe000000b000-0xfffffe000002c000         132K                               pte
> [    0.010641] 0xfffffe000002c000-0xfffffe000002d000           4K     ro                 GLB NX pte
> [    0.010654] 0xfffffe000002d000-0xfffffe000002e000           4K     RW                 GLB NX pte
> [    0.010667] 0xfffffe000002e000-0xfffffe0000031000          12K     ro                 GLB NX pte
> [    0.010679] 0xfffffe0000031000-0xfffffe0000036000          20K     RW                 GLB NX pte
> [    0.010692] 0xfffffe0000036000-0xfffffe0000057000         132K                               pte
> [    0.010704] 0xfffffe0000057000-0xfffffe0000058000           4K     ro                 GLB NX pte
> [    0.010716] 0xfffffe0000058000-0xfffffe0000059000           4K     RW                 GLB NX pte
> [    0.010730] 0xfffffe0000059000-0xfffffe000005c000          12K     ro                 GLB NX pte
> [    0.010745] 0xfffffe000005c000-0xfffffe0000061000          20K     RW                 GLB NX pte
> [    0.010760] 0xfffffe0000061000-0xfffffe0000082000         132K                               pte
> [    0.010770] 0xfffffe0000082000-0xfffffe0000083000           4K     ro                 GLB NX pte
> [    0.010782] 0xfffffe0000083000-0xfffffe0000084000           4K     RW                 GLB NX pte
> [    0.010794] 0xfffffe0000084000-0xfffffe0000087000          12K     ro                 GLB NX pte
> [    0.010806] 0xfffffe0000087000-0xfffffe000008c000          20K     RW                 GLB NX pte
> [    0.010818] 0xfffffe000008c000-0xfffffe00000ad000         132K                               pte
> [    0.010829] 0xfffffe00000ad000-0xfffffe00000ae000           4K     ro                 GLB NX pte
> [    0.010841] 0xfffffe00000ae000-0xfffffe00000af000           4K     RW                 GLB NX pte
> [    0.010853] 0xfffffe00000af000-0xfffffe00000b2000          12K     ro                 GLB NX pte
> [    0.010865] 0xfffffe00000b2000-0xfffffe00000b7000          20K     RW                 GLB NX pte
> [    0.010877] 0xfffffe00000b7000-0xfffffe00000d8000         132K                               pte
> [    0.010888] 0xfffffe00000d8000-0xfffffe00000d9000           4K     ro                 GLB NX pte
> [    0.010900] 0xfffffe00000d9000-0xfffffe00000da000           4K     RW                 GLB NX pte
> [    0.010912] 0xfffffe00000da000-0xfffffe00000dd000          12K     ro                 GLB NX pte
> [    0.010924] 0xfffffe00000dd000-0xfffffe00000e2000          20K     RW                 GLB NX pte
> [    0.010936] 0xfffffe00000e2000-0xfffffe0000103000         132K                               pte
> [    0.010947] 0xfffffe0000103000-0xfffffe0000104000           4K     ro                 GLB NX pte
> [    0.010959] 0xfffffe0000104000-0xfffffe0000105000           4K     RW                 GLB NX pte
> [    0.010971] 0xfffffe0000105000-0xfffffe0000108000          12K     ro                 GLB NX pte
> [    0.010983] 0xfffffe0000108000-0xfffffe000010d000          20K     RW                 GLB NX pte
> [    0.010995] 0xfffffe000010d000-0xfffffe000012e000         132K                               pte
> [    0.011006] 0xfffffe000012e000-0xfffffe000012f000           4K     ro                 GLB NX pte
> [    0.011018] 0xfffffe000012f000-0xfffffe0000130000           4K     RW                 GLB NX pte
> [    0.011031] 0xfffffe0000130000-0xfffffe0000133000          12K     ro                 GLB NX pte
> [    0.011044] 0xfffffe0000133000-0xfffffe0000138000          20K     RW                 GLB NX pte
> [    0.011056] 0xfffffe0000138000-0xfffffe0000159000         132K                               pte
> [    0.011067] 0xfffffe0000159000-0xfffffe000015a000           4K     ro                 GLB NX pte
> [    0.011078] 0xfffffe000015a000-0xfffffe000015b000           4K     RW                 GLB NX pte
> [    0.011090] 0xfffffe000015b000-0xfffffe000015e000          12K     ro                 GLB NX pte
> [    0.011102] 0xfffffe000015e000-0xfffffe0000163000          20K     RW                 GLB NX pte
> [    0.011115] 0xfffffe0000163000-0xfffffe0000184000         132K                               pte
> [    0.011125] 0xfffffe0000184000-0xfffffe0000185000           4K     ro                 GLB NX pte
> [    0.011137] 0xfffffe0000185000-0xfffffe0000186000           4K     RW                 GLB NX pte
> [    0.011149] 0xfffffe0000186000-0xfffffe0000189000          12K     ro                 GLB NX pte
> [    0.011161] 0xfffffe0000189000-0xfffffe000018e000          20K     RW                 GLB NX pte
> [    0.011173] 0xfffffe000018e000-0xfffffe00001af000         132K                               pte
> [    0.011184] 0xfffffe00001af000-0xfffffe00001b0000           4K     ro                 GLB NX pte
> [    0.011196] 0xfffffe00001b0000-0xfffffe00001b1000           4K     RW                 GLB NX pte
> [    0.011208] 0xfffffe00001b1000-0xfffffe00001b4000          12K     ro                 GLB NX pte
> [    0.011220] 0xfffffe00001b4000-0xfffffe00001b9000          20K     RW                 GLB NX pte
> [    0.011232] 0xfffffe00001b9000-0xfffffe00001da000         132K                               pte
> [    0.011243] 0xfffffe00001da000-0xfffffe00001db000           4K     ro                 GLB NX pte
> [    0.011255] 0xfffffe00001db000-0xfffffe00001dc000           4K     RW                 GLB NX pte
> [    0.011267] 0xfffffe00001dc000-0xfffffe00001df000          12K     ro                 GLB NX pte
> [    0.011279] 0xfffffe00001df000-0xfffffe00001e4000          20K     RW                 GLB NX pte
> [    0.011291] 0xfffffe00001e4000-0xfffffe0000205000         132K                               pte
> [    0.011302] 0xfffffe0000205000-0xfffffe0000206000           4K     ro                 GLB NX pte
> [    0.011314] 0xfffffe0000206000-0xfffffe0000207000           4K     RW                 GLB NX pte
> [    0.011326] 0xfffffe0000207000-0xfffffe000020a000          12K     ro                 GLB NX pte
> [    0.011338] 0xfffffe000020a000-0xfffffe000020f000          20K     RW                 GLB NX pte
> [    0.011350] 0xfffffe000020f000-0xfffffe0000230000         132K                               pte
> [    0.011361] 0xfffffe0000230000-0xfffffe0000231000           4K     ro                 GLB NX pte
> [    0.011373] 0xfffffe0000231000-0xfffffe0000232000           4K     RW                 GLB NX pte
> [    0.011385] 0xfffffe0000232000-0xfffffe0000235000          12K     ro                 GLB NX pte
> [    0.011397] 0xfffffe0000235000-0xfffffe000023a000          20K     RW                 GLB NX pte
> [    0.011409] 0xfffffe000023a000-0xfffffe000025b000         132K                               pte
> [    0.011420] 0xfffffe000025b000-0xfffffe000025c000           4K     ro                 GLB NX pte
> [    0.011431] 0xfffffe000025c000-0xfffffe000025d000           4K     RW                 GLB NX pte
> [    0.011443] 0xfffffe000025d000-0xfffffe0000260000          12K     ro                 GLB NX pte
> [    0.011455] 0xfffffe0000260000-0xfffffe0000265000          20K     RW                 GLB NX pte
> [    0.011467] 0xfffffe0000265000-0xfffffe0000286000         132K                               pte
> [    0.011478] 0xfffffe0000286000-0xfffffe0000287000           4K     ro                 GLB NX pte
> [    0.011490] 0xfffffe0000287000-0xfffffe0000288000           4K     RW                 GLB NX pte
> [    0.011502] 0xfffffe0000288000-0xfffffe000028b000          12K     ro                 GLB NX pte
> [    0.011514] 0xfffffe000028b000-0xfffffe0000290000          20K     RW                 GLB NX pte
> [    0.011528] 0xfffffe0000290000-0xfffffe0000400000        1472K                               pte
> [    0.011541] 0xfffffe0000400000-0xfffffe0040000000        1020M                               pmd
> [    0.011554] 0xfffffe0040000000-0xfffffe8000000000         511G                               pud
> [    0.011565] 0xfffffe8000000000-0xffffff0000000000         512G                               pgd
> [    0.011576] ---[ ESPfix Area ]---
> [    0.011582] 0xffffff0000000000-0xffffff3b00000000         236G                               pud
> [    0.011593] 0xffffff3b00000000-0xffffff3b0000c000          48K                               pte
> [    0.011604] 0xffffff3b0000c000-0xffffff3b0000d000           4K     ro                 GLB NX pte
> [    0.011616] 0xffffff3b0000d000-0xffffff3b0001c000          60K                               pte
> [    0.011627] 0xffffff3b0001c000-0xffffff3b0001d000           4K     ro                 GLB NX pte
> [    0.011639] 0xffffff3b0001d000-0xffffff3b0002c000          60K                               pte
> [    0.011650] 0xffffff3b0002c000-0xffffff3b0002d000           4K     ro                 GLB NX pte
> [    0.011662] 0xffffff3b0002d000-0xffffff3b0003c000          60K                               pte
> [    0.011673] 0xffffff3b0003c000-0xffffff3b0003d000           4K     ro                 GLB NX pte
> [    0.011685] 0xffffff3b0003d000-0xffffff3b0004c000          60K                               pte
> [    0.011695] 0xffffff3b0004c000-0xffffff3b0004d000           4K     ro                 GLB NX pte
> [    0.011707] 0xffffff3b0004d000-0xffffff3b0005c000          60K                               pte
> [    0.011718] 0xffffff3b0005c000-0xffffff3b0005d000           4K     ro                 GLB NX pte
> [    0.011730] 0xffffff3b0005d000-0xffffff3b0006c000          60K                               pte
> [    0.011741] 0xffffff3b0006c000-0xffffff3b0006d000           4K     ro                 GLB NX pte
> [    0.011753] 0xffffff3b0006d000-0xffffff3b0007c000          60K                               pte
> [    0.019014] ... 131059 entries skipped ... 
> [    0.019020] ---[ EFI Runtime Services ]---
> [    0.019025] 0xffffffef00000000-0xfffffffec0000000          63G                               pud
> [    0.019033] 0xfffffffec0000000-0xfffffffee9000000         656M                               pmd
> [    0.019044] 0xfffffffee9000000-0xfffffffee9008000          32K     RW                     x  pte
> [    0.019056] 0xfffffffee9008000-0xfffffffee903f000         220K                               pte
> [    0.019067] 0xfffffffee903f000-0xfffffffee9040000           4K                               pte
> [    0.019078] 0xfffffffee9040000-0xfffffffee90a0000         384K     RW                     x  pte
> [    0.019092] 0xfffffffee90a0000-0xfffffffee9200000        1408K                               pte
> [    0.019103] 0xfffffffee9200000-0xfffffffee9220000         128K                               pte
> [    0.019116] 0xfffffffee9220000-0xfffffffee937e000        1400K                               pte
> [    0.019128] 0xfffffffee937e000-0xfffffffee9400000         520K     RW                     x  pte
> [    0.019140] 0xfffffffee9400000-0xfffffffef3a00000         166M     RW         PSE         x  pmd
> [    0.019155] 0xfffffffef3a00000-0xfffffffef3bd5000        1876K     RW                     x  pte
> [    0.019167] 0xfffffffef3bd5000-0xfffffffef3c00000         172K                               pte
> [    0.019178] 0xfffffffef3c00000-0xfffffffef5200000          22M                               pmd
> [    0.019190] 0xfffffffef5200000-0xfffffffef5320000        1152K                               pte
> [    0.019203] 0xfffffffef5320000-0xfffffffef548d000        1460K                               pte
> [    0.019216] 0xfffffffef548d000-0xfffffffef5600000        1484K                               pte
> [    0.019227] 0xfffffffef5600000-0xfffffffef6200000          12M                               pmd
> [    0.019238] 0xfffffffef6200000-0xfffffffef6244000         272K                               pte
> [    0.019252] 0xfffffffef6244000-0xfffffffef641a000        1880K                               pte
> [    0.019265] 0xfffffffef641a000-0xfffffffef6600000        1944K     RW                     NX pte
> [    0.019277] 0xfffffffef6600000-0xfffffffef6e00000           8M     RW         PSE         NX pmd
> [    0.019291] 0xfffffffef6e00000-0xfffffffef6f0b000        1068K     RW                     NX pte
> [    0.019302] 0xfffffffef6f0b000-0xfffffffef6f0e000          12K     ro                     x  pte
> [    0.019314] 0xfffffffef6f0e000-0xfffffffef6f13000          20K     RW                     NX pte
> [    0.019326] 0xfffffffef6f13000-0xfffffffef6f14000           4K     ro                     x  pte
> [    0.019338] 0xfffffffef6f14000-0xfffffffef6f18000          16K     RW                     NX pte
> [    0.019350] 0xfffffffef6f18000-0xfffffffef6f1c000          16K     ro                     x  pte
> [    0.019362] 0xfffffffef6f1c000-0xfffffffef6f21000          20K     RW                     NX pte
> [    0.019374] 0xfffffffef6f21000-0xfffffffef6f22000           4K     ro                     x  pte
> [    0.019386] 0xfffffffef6f22000-0xfffffffef6f26000          16K     RW                     NX pte
> [    0.019398] 0xfffffffef6f26000-0xfffffffef6f27000           4K     ro                     x  pte
> [    0.019410] 0xfffffffef6f27000-0xfffffffef6f2c000          20K     RW                     NX pte
> [    0.019422] 0xfffffffef6f2c000-0xfffffffef6f39000          52K     ro                     x  pte
> [    0.019434] 0xfffffffef6f39000-0xfffffffef6f40000          28K     RW                     NX pte
> [    0.019446] 0xfffffffef6f40000-0xfffffffef6f43000          12K     ro                     x  pte
> [    0.019458] 0xfffffffef6f43000-0xfffffffef6f49000          24K     RW                     NX pte
> [    0.019470] 0xfffffffef6f49000-0xfffffffef6f4a000           4K     ro                     x  pte
> [    0.019482] 0xfffffffef6f4a000-0xfffffffef6f4f000          20K     RW                     NX pte
> [    0.019494] 0xfffffffef6f4f000-0xfffffffef6f50000           4K     ro                     x  pte
> [    0.019506] 0xfffffffef6f50000-0xfffffffef6f55000          20K     RW                     NX pte
> [    0.019517] 0xfffffffef6f55000-0xfffffffef6f56000           4K     ro                     x  pte
> [    0.019529] 0xfffffffef6f56000-0xfffffffef6f5b000          20K     RW                     NX pte
> [    0.019541] 0xfffffffef6f5b000-0xfffffffef6f5c000           4K     ro                     x  pte
> [    0.019553] 0xfffffffef6f5c000-0xfffffffef6f61000          20K     RW                     NX pte
> [    0.019565] 0xfffffffef6f61000-0xfffffffef6f62000           4K     ro                     x  pte
> [    0.019577] 0xfffffffef6f62000-0xfffffffef6f67000          20K     RW                     NX pte
> [    0.019589] 0xfffffffef6f67000-0xfffffffef6f68000           4K     ro                     x  pte
> [    0.019601] 0xfffffffef6f68000-0xfffffffef6f6c000          16K     RW                     NX pte
> [    0.019613] 0xfffffffef6f6c000-0xfffffffef6f76000          40K     ro                     x  pte
> [    0.019625] 0xfffffffef6f76000-0xfffffffef6f7f000          36K     RW                     NX pte
> [    0.019637] 0xfffffffef6f7f000-0xfffffffef6f84000          20K     ro                     x  pte
> [    0.019649] 0xfffffffef6f84000-0xfffffffef6f89000          20K     RW                     NX pte
> [    0.019661] 0xfffffffef6f89000-0xfffffffef6f8d000          16K     ro                     x  pte
> [    0.019673] 0xfffffffef6f8d000-0xfffffffef6f92000          20K     RW                     NX pte
> [    0.019685] 0xfffffffef6f92000-0xfffffffef7000000         440K                               pte
> [    0.019696] 0xfffffffef7000000-0xfffffffef9a00000          42M                               pmd
> [    0.019707] 0xfffffffef9a00000-0xfffffffefda00000          64M     RW         PSE         x  pmd
> [    0.019721] 0xfffffffefda00000-0xfffffffefdb00000           1M                               pte
> [    0.019733] 0xfffffffefdb00000-0xfffffffefdc00000           1M     RW                     x  pte
> [    0.019745] 0xfffffffefdc00000-0xfffffffefea00000          14M     RW         PSE         x  pmd
> [    0.019758] 0xfffffffefea00000-0xfffffffefea10000          64K     RW                     x  pte
> [    0.019775] 0xfffffffefea10000-0xfffffffefeb80000        1472K                               pte
> [    0.019787] 0xfffffffefeb80000-0xfffffffefec02000         520K     RW                     x  pte
> [    0.019799] 0xfffffffefec02000-0xfffffffefec10000          56K                               pte
> [    0.019810] 0xfffffffefec10000-0xfffffffefec11000           4K     RW                     x  pte
> [    0.019822] 0xfffffffefec11000-0xfffffffefec30000         124K                               pte
> [    0.019833] 0xfffffffefec30000-0xfffffffefec31000           4K     RW                     x  pte
> [    0.019846] 0xfffffffefec31000-0xfffffffefed00000         828K                               pte
> [    0.019857] 0xfffffffefed00000-0xfffffffefed01000           4K     RW                     x  pte
> [    0.019870] 0xfffffffefed01000-0xfffffffefed40000         252K                               pte
> [    0.019881] 0xfffffffefed40000-0xfffffffefed45000          20K     RW                     x  pte
> [    0.019893] 0xfffffffefed45000-0xfffffffefed80000         236K                               pte
> [    0.019904] 0xfffffffefed80000-0xfffffffefed90000          64K     RW                     x  pte
> [    0.019916] 0xfffffffefed90000-0xfffffffefedc2000         200K                               pte
> [    0.019927] 0xfffffffefedc2000-0xfffffffefedd0000          56K     RW                     x  pte
> [    0.019939] 0xfffffffefedd0000-0xfffffffefedd4000          16K                               pte
> [    0.019950] 0xfffffffefedd4000-0xfffffffefedd6000           8K     RW                     x  pte
> [    0.019962] 0xfffffffefedd6000-0xfffffffefee00000         168K                               pte
> [    0.019975] 0xfffffffefee00000-0xfffffffefef00000           1M     RW                     x  pte
> [    0.019988] 0xfffffffefef00000-0xfffffffeff000000           1M                               pte
> [    0.019999] 0xfffffffeff000000-0xffffffff00000000          16M     RW         PSE         x  pmd
> [    0.020011] 0xffffffff00000000-0xffffffff80000000           2G                               pud
> [    0.020031] ---[ High Kernel Mapping ]---
> [    0.020037] 0xffffffff80000000-0xffffffff81000000          16M                               pmd
> [    0.020048] 0xffffffff81000000-0xffffffff84600000          54M     RW         PSE     GLB x  pmd
> [    0.020062] 0xffffffff84600000-0xffffffffc0000000         954M                               pmd
> [    0.020073] ---[ Modules ]---
> [    0.020080] 0xffffffffc0000000-0xffffffffff000000        1008M                               pmd
> [    0.020090] ---[ End Modules ]---
> [    0.020095] 0xffffffffff000000-0xffffffffff200000           2M                               pmd
> [    0.020111] 0xffffffffff200000-0xffffffffff576000        3544K                               pte
> [    0.020122] ---[ Fixmap Area ]---
> [    0.020128] 0xffffffffff576000-0xffffffffff5fa000         528K                               pte
> [    0.020139] 0xffffffffff5fa000-0xffffffffff5fd000          12K     RW PWT PCD         GLB NX pte
> [    0.020151] 0xffffffffff5fd000-0xffffffffff600000          12K                               pte
> [    0.020162] 0xffffffffff600000-0xffffffffff601000           4K USR ro                 GLB NX pte
> [    0.020176] 0xffffffffff601000-0xffffffffff800000        2044K                               pte
> [    0.020188] 0xffffffffff800000-0x0000000000000000           8M                               pmd
> [    0.020248] LSM: Security Framework initializing
> [    0.020255] Yama: becoming mindful.
> [    0.020267] SELinux:  Initializing.
> [    0.025486] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
> [    0.028048] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> [    0.028158] Mount-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.028245] Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.028698] mce: CPU supports 23 MCE banks
> [    0.028729] LVT offset 1 assigned for vector 0xf9
> [    0.028798] LVT offset 2 assigned for vector 0xf4
> [    0.028813] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 512
> [    0.028821] Last level dTLB entries: 4KB 1536, 2MB 1536, 4MB 768, 1GB 0
> [    0.028830] Spectre V2 : Mitigation: Full AMD retpoline
> [    0.028837] Spectre V2 : Spectre v2 / SpectreRSB mitigation: Filling RSB on context switch
> [    0.028852] Spectre V2 : mitigation: Enabling conditional Indirect Branch Prediction Barrier
> [    0.028862] Spectre V2 : User space: Vulnerable
> [    0.028871] Speculative Store Bypass: Mitigation: Speculative Store Bypass disabled via prctl and seccomp
> [    0.029060] Freeing SMP alternatives memory: 32K
> [    0.031030] smpboot: CPU0: AMD Ryzen 7 2700X Eight-Core Processor (family: 0x17, model: 0x8, stepping: 0x2)
> [    0.031030] Performance Events: Fam17h core perfctr, AMD PMU driver.
> [    0.031030] ... version:                0
> [    0.031030] ... bit width:              48
> [    0.031030] ... generic registers:      6
> [    0.031030] ... value mask:             0000ffffffffffff
> [    0.031030] ... max period:             00007fffffffffff
> [    0.031030] ... fixed-purpose events:   0
> [    0.031030] ... event mask:             000000000000003f
> [    0.031030] rcu: Hierarchical SRCU implementation.
> [    0.031030] random: crng done (trusting CPU's manufacturer)
> [    0.031119] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
> [    0.031422] smp: Bringing up secondary CPUs ...
> [    0.031689] x86: Booting SMP configuration:
> [    0.031703] .... node  #0, CPUs:        #1  #2  #3  #4  #5  #6  #7  #8  #9 #10 #11 #12 #13 #14 #15
> [    0.052128] smp: Brought up 1 node, 16 CPUs
> [    0.052128] smpboot: Max logical packages: 1
> [    0.052128] smpboot: Total of 16 processors activated (118163.84 BogoMIPS)
> [    0.055172] devtmpfs: initialized
> [    0.055172] x86/mm: Memory block size: 128MB
> [    0.061264] PM: Registering ACPI NVS region [mem 0x0a200000-0x0a209fff] (40960 bytes)
> [    0.061264] PM: Registering ACPI NVS region [mem 0xdb569000-0xdba19fff] (4919296 bytes)
> [    0.062880] DMA-API: preallocated 65548 debug entries
> [    0.062890] DMA-API: debugging enabled by kernel config
> [    0.062899] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
> [    0.062964] futex hash table entries: 4096 (order: 7, 524288 bytes)
> [    0.063948] pinctrl core: initialized pinctrl subsystem
> 
> [    0.063948] *************************************************************
> [    0.063948] **     NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE    **
> [    0.063948] **                                                         **
> [    0.063948] **  IOMMU DebugFS SUPPORT HAS BEEN ENABLED IN THIS KERNEL  **
> [    0.063948] **                                                         **
> [    0.063948] ** This means that this kernel is built to expose internal **
> [    0.063948] ** IOMMU data structures, which may compromise security on **
> [    0.063948] ** your system.                                            **
> [    0.063948] **                                                         **
> [    0.063948] ** If you see this message and you are not debugging the   **
> [    0.063948] ** kernel, report this immediately to your vendor!         **
> [    0.063948] **                                                         **
> [    0.063948] **     NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE    **
> [    0.063948] *************************************************************
> [    0.063948] RTC time: 03:36:43, date: 2019-01-18
> [    0.064027] NET: Registered protocol family 16
> [    0.064253] audit: initializing netlink subsys (disabled)
> [    0.065051] audit: type=2000 audit(1547782602.074:1): state=initialized audit_enabled=0 res=1
> [    0.065297] cpuidle: using governor menu
> [    0.065489] ACPI: bus type PCI registered
> [    0.065489] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    0.065489] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
> [    0.065489] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
> [    0.065489] PCI: Using configuration type 1 for base access
> [    0.070772] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
> [    0.070772] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
> [    0.071152] cryptd: max_cpu_qlen set to 1000
> [    0.071166] fbcon: Taking over console
> [    0.071247] ACPI: Added _OSI(Module Device)
> [    0.071254] ACPI: Added _OSI(Processor Device)
> [    0.071261] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.071267] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.071276] ACPI: Added _OSI(Linux-Dell-Video)
> [    0.071282] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
> [    0.071290] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
> [    0.102966] ACPI: 7 ACPI AML tables successfully acquired and loaded
> [    0.110053] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
> [    0.117477] ACPI: EC: EC started
> [    0.117491] ACPI: EC: interrupt blocked
> [    0.117839] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as first EC
> [    0.117848] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x2, EC_CMD/EC_SC=0x66, EC_DATA=0x62
> [    0.117859] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to handle transactions
> [    0.117869] ACPI: Interpreter enabled
> [    0.117902] ACPI: (supports S0 S3 S4 S5)
> [    0.117909] ACPI: Using IOAPIC for interrupt routing
> [    0.119155] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.119927] ACPI: Enabled 3 GPEs in block 00 to 1F
> [    0.145346] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.145365] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
> [    0.145828] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug SHPCHotplug PME LTR]
> [    0.146277] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
> [    0.146319] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
> [    0.147260] PCI host bridge to bus 0000:00
> [    0.147269] pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
> [    0.147278] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
> [    0.147287] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
> [    0.147296] pci_bus 0000:00: root bus resource [io  0x0d00-0xefff window]
> [    0.147306] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.147316] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff window]
> [    0.147326] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfec2ffff window]
> [    0.147336] pci_bus 0000:00: root bus resource [mem 0xfee00000-0xffffffff window]
> [    0.147347] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.147372] pci 0000:00:00.0: [1022:1450] type 00 class 0x060000
> [    0.147633] pci 0000:00:00.2: [1022:1451] type 00 class 0x080600
> [    0.147831] pci 0000:00:01.0: [1022:1452] type 00 class 0x060000
> [    0.147993] pci 0000:00:01.1: [1022:1453] type 01 class 0x060400
> [    0.148120] pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
> [    0.149270] pci 0000:00:01.3: [1022:1453] type 01 class 0x060400
> [    0.150035] pci 0000:00:01.3: enabling Extended Tags
> [    0.150130] pci 0000:00:01.3: PME# supported from D0 D3hot D3cold
> [    0.151264] pci 0000:00:02.0: [1022:1452] type 00 class 0x060000
> [    0.151437] pci 0000:00:03.0: [1022:1452] type 00 class 0x060000
> [    0.152069] pci 0000:00:03.1: [1022:1453] type 01 class 0x060400
> [    0.152587] pci 0000:00:03.1: PME# supported from D0 D3hot D3cold
> [    0.153240] pci 0000:00:04.0: [1022:1452] type 00 class 0x060000
> [    0.153416] pci 0000:00:07.0: [1022:1452] type 00 class 0x060000
> [    0.154055] pci 0000:00:07.1: [1022:1454] type 01 class 0x060400
> [    0.154505] pci 0000:00:07.1: enabling Extended Tags
> [    0.154597] pci 0000:00:07.1: PME# supported from D0 D3hot D3cold
> [    0.155264] pci 0000:00:08.0: [1022:1452] type 00 class 0x060000
> [    0.155420] pci 0000:00:08.1: [1022:1454] type 01 class 0x060400
> [    0.156035] pci 0000:00:08.1: enabling Extended Tags
> [    0.156128] pci 0000:00:08.1: PME# supported from D0 D3hot D3cold
> [    0.157294] pci 0000:00:14.0: [1022:790b] type 00 class 0x0c0500
> [    0.158089] pci 0000:00:14.3: [1022:790e] type 00 class 0x060100
> [    0.158402] pci 0000:00:18.0: [1022:1460] type 00 class 0x060000
> [    0.158544] pci 0000:00:18.1: [1022:1461] type 00 class 0x060000
> [    0.158687] pci 0000:00:18.2: [1022:1462] type 00 class 0x060000
> [    0.158830] pci 0000:00:18.3: [1022:1463] type 00 class 0x060000
> [    0.158975] pci 0000:00:18.4: [1022:1464] type 00 class 0x060000
> [    0.159123] pci 0000:00:18.5: [1022:1465] type 00 class 0x060000
> [    0.159266] pci 0000:00:18.6: [1022:1466] type 00 class 0x060000
> [    0.159411] pci 0000:00:18.7: [1022:1467] type 00 class 0x060000
> [    0.159666] pci 0000:01:00.0: [8086:2700] type 00 class 0x010802
> [    0.159686] pci 0000:01:00.0: reg 0x10: [mem 0xfe910000-0xfe913fff 64bit]
> [    0.159712] pci 0000:01:00.0: reg 0x30: [mem 0xfe900000-0xfe90ffff pref]
> [    0.159884] pci 0000:00:01.1: PCI bridge to [bus 01]
> [    0.159895] pci 0000:00:01.1:   bridge window [mem 0xfe900000-0xfe9fffff]
> [    0.160145] pci 0000:02:00.0: [1022:43d0] type 00 class 0x0c0330
> [    0.160168] pci 0000:02:00.0: reg 0x10: [mem 0xfe5a0000-0xfe5a7fff 64bit]
> [    0.160206] pci 0000:02:00.0: enabling Extended Tags
> [    0.160268] pci 0000:02:00.0: PME# supported from D3hot D3cold
> [    0.160393] pci 0000:02:00.1: [1022:43c8] type 00 class 0x010601
> [    0.160441] pci 0000:02:00.1: reg 0x24: [mem 0xfe580000-0xfe59ffff]
> [    0.160449] pci 0000:02:00.1: reg 0x30: [mem 0xfe500000-0xfe57ffff pref]
> [    0.160456] pci 0000:02:00.1: enabling Extended Tags
> [    0.160508] pci 0000:02:00.1: PME# supported from D3hot D3cold
> [    0.161105] pci 0000:02:00.2: [1022:43c6] type 01 class 0x060400
> [    0.161145] pci 0000:02:00.2: enabling Extended Tags
> [    0.161199] pci 0000:02:00.2: PME# supported from D3hot D3cold
> [    0.161339] pci 0000:00:01.3: PCI bridge to [bus 02-08]
> [    0.161349] pci 0000:00:01.3:   bridge window [io  0xc000-0xdfff]
> [    0.161352] pci 0000:00:01.3:   bridge window [mem 0xfe300000-0xfe5fffff]
> [    0.161576] pci 0000:03:00.0: [1022:43c7] type 01 class 0x060400
> [    0.161620] pci 0000:03:00.0: enabling Extended Tags
> [    0.161683] pci 0000:03:00.0: PME# supported from D3hot D3cold
> [    0.161822] pci 0000:03:01.0: [1022:43c7] type 01 class 0x060400
> [    0.161867] pci 0000:03:01.0: enabling Extended Tags
> [    0.161930] pci 0000:03:01.0: PME# supported from D3hot D3cold
> [    0.162078] pci 0000:03:02.0: [1022:43c7] type 01 class 0x060400
> [    0.162123] pci 0000:03:02.0: enabling Extended Tags
> [    0.162187] pci 0000:03:02.0: PME# supported from D3hot D3cold
> [    0.162328] pci 0000:03:03.0: [1022:43c7] type 01 class 0x060400
> [    0.162372] pci 0000:03:03.0: enabling Extended Tags
> [    0.162435] pci 0000:03:03.0: PME# supported from D3hot D3cold
> [    0.162574] pci 0000:03:04.0: [1022:43c7] type 01 class 0x060400
> [    0.162619] pci 0000:03:04.0: enabling Extended Tags
> [    0.162682] pci 0000:03:04.0: PME# supported from D3hot D3cold
> [    0.162841] pci 0000:02:00.2: PCI bridge to [bus 03-08]
> [    0.162853] pci 0000:02:00.2:   bridge window [io  0xc000-0xdfff]
> [    0.162856] pci 0000:02:00.2:   bridge window [mem 0xfe300000-0xfe4fffff]
> [    0.162975] pci 0000:04:00.0: [8086:1539] type 00 class 0x020000
> [    0.163022] pci 0000:04:00.0: reg 0x10: [mem 0xfe400000-0xfe41ffff]
> [    0.163060] pci 0000:04:00.0: reg 0x18: [io  0xd000-0xd01f]
> [    0.163078] pci 0000:04:00.0: reg 0x1c: [mem 0xfe420000-0xfe423fff]
> [    0.163261] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
> [    0.163460] pci 0000:03:00.0: PCI bridge to [bus 04]
> [    0.163471] pci 0000:03:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.163475] pci 0000:03:00.0:   bridge window [mem 0xfe400000-0xfe4fffff]
> [    0.163557] pci 0000:05:00.0: [10ec:b822] type 00 class 0x028000
> [    0.163601] pci 0000:05:00.0: reg 0x10: [io  0xc000-0xc0ff]
> [    0.163636] pci 0000:05:00.0: reg 0x18: [mem 0xfe300000-0xfe30ffff 64bit]
> [    0.163801] pci 0000:05:00.0: supports D1 D2
> [    0.163802] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.164012] pci 0000:03:01.0: PCI bridge to [bus 05]
> [    0.164024] pci 0000:03:01.0:   bridge window [io  0xc000-0xcfff]
> [    0.164027] pci 0000:03:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
> [    0.164087] pci 0000:03:02.0: PCI bridge to [bus 06]
> [    0.164175] pci 0000:03:03.0: PCI bridge to [bus 07]
> [    0.164260] pci 0000:03:04.0: PCI bridge to [bus 08]
> [    0.164604] pci 0000:09:00.0: [1022:1470] type 01 class 0x060400
> [    0.164625] pci 0000:09:00.0: reg 0x10: [mem 0xfe700000-0xfe703fff]
> [    0.164699] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
> [    0.164738] pci 0000:09:00.0: 63.008 Gb/s available PCIe bandwidth, limited by 8 GT/s x8 link at 0000:00:03.1 (capable of 126.016 Gb/s with 8 GT/s x16 link)
> [    0.164856] pci 0000:00:03.1: PCI bridge to [bus 09-0b]
> [    0.164866] pci 0000:00:03.1:   bridge window [io  0xe000-0xefff]
> [    0.164869] pci 0000:00:03.1:   bridge window [mem 0xfe600000-0xfe7fffff]
> [    0.164872] pci 0000:00:03.1:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.164927] pci 0000:0a:00.0: [1022:1471] type 01 class 0x060400
> [    0.165019] pci 0000:0a:00.0: PME# supported from D0 D3hot D3cold
> [    0.165138] pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
> [    0.165150] pci 0000:09:00.0:   bridge window [io  0xe000-0xefff]
> [    0.165153] pci 0000:09:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.165157] pci 0000:09:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.165210] pci 0000:0b:00.0: [1002:687f] type 00 class 0x030000
> [    0.165236] pci 0000:0b:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit pref]
> [    0.165247] pci 0000:0b:00.0: reg 0x18: [mem 0xf0000000-0xf01fffff 64bit pref]
> [    0.165254] pci 0000:0b:00.0: reg 0x20: [io  0xe000-0xe0ff]
> [    0.165261] pci 0000:0b:00.0: reg 0x24: [mem 0xfe600000-0xfe67ffff]
> [    0.165269] pci 0000:0b:00.0: reg 0x30: [mem 0xfe680000-0xfe69ffff pref]
> [    0.165290] pci 0000:0b:00.0: BAR 0: assigned to efifb
> [    0.165347] pci 0000:0b:00.0: PME# supported from D1 D2 D3hot D3cold
> [    0.165390] pci 0000:0b:00.0: 63.008 Gb/s available PCIe bandwidth, limited by 8 GT/s x8 link at 0000:00:03.1 (capable of 126.016 Gb/s with 8 GT/s x16 link)
> [    0.165471] pci 0000:0b:00.1: [1002:aaf8] type 00 class 0x040300
> [    0.165489] pci 0000:0b:00.1: reg 0x10: [mem 0xfe6a0000-0xfe6a3fff]
> [    0.165580] pci 0000:0b:00.1: PME# supported from D1 D2 D3hot D3cold
> [    0.165700] pci 0000:0a:00.0: PCI bridge to [bus 0b]
> [    0.165711] pci 0000:0a:00.0:   bridge window [io  0xe000-0xefff]
> [    0.165714] pci 0000:0a:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.165719] pci 0000:0a:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.166128] pci 0000:0c:00.0: [1022:145a] type 00 class 0x130000
> [    0.166158] pci 0000:0c:00.0: enabling Extended Tags
> [    0.166276] pci 0000:0c:00.2: [1022:1456] type 00 class 0x108000
> [    0.166292] pci 0000:0c:00.2: reg 0x18: [mem 0xfe100000-0xfe1fffff]
> [    0.166301] pci 0000:0c:00.2: reg 0x24: [mem 0xfe200000-0xfe201fff]
> [    0.166308] pci 0000:0c:00.2: enabling Extended Tags
> [    0.166450] pci 0000:0c:00.3: [1022:145f] type 00 class 0x0c0330
> [    0.166464] pci 0000:0c:00.3: reg 0x10: [mem 0xfe000000-0xfe0fffff 64bit]
> [    0.166487] pci 0000:0c:00.3: enabling Extended Tags
> [    0.166532] pci 0000:0c:00.3: PME# supported from D0 D3hot D3cold
> [    0.167142] pci 0000:00:07.1: PCI bridge to [bus 0c]
> [    0.167153] pci 0000:00:07.1:   bridge window [mem 0xfe000000-0xfe2fffff]
> [    0.167635] pci 0000:0d:00.0: [1022:1455] type 00 class 0x130000
> [    0.167667] pci 0000:0d:00.0: enabling Extended Tags
> [    0.167789] pci 0000:0d:00.2: [1022:7901] type 00 class 0x010601
> [    0.167821] pci 0000:0d:00.2: reg 0x24: [mem 0xfe808000-0xfe808fff]
> [    0.167829] pci 0000:0d:00.2: enabling Extended Tags
> [    0.167874] pci 0000:0d:00.2: PME# supported from D3hot D3cold
> [    0.167982] pci 0000:0d:00.3: [1022:1457] type 00 class 0x040300
> [    0.167993] pci 0000:0d:00.3: reg 0x10: [mem 0xfe800000-0xfe807fff]
> [    0.168015] pci 0000:0d:00.3: enabling Extended Tags
> [    0.168063] pci 0000:0d:00.3: PME# supported from D0 D3hot D3cold
> [    0.168177] pci 0000:00:08.1: PCI bridge to [bus 0d]
> [    0.168188] pci 0000:00:08.1:   bridge window [mem 0xfe800000-0xfe8fffff]
> [    0.168960] ACPI: PCI Interrupt Link [LNKA] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169098] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169214] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169347] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169471] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169575] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169680] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 5 7 10 11 14 15) *0
> [    0.169785] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 7 10 11 14 15) *0
> [    0.170926] ACPI: EC: interrupt unblocked
> [    0.170950] ACPI: EC: event unblocked
> [    0.170966] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x2, EC_CMD/EC_SC=0x66, EC_DATA=0x62
> [    0.170980] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to handle transactions and events
> [    0.171170] pci 0000:0b:00.0: vgaarb: setting as boot VGA device
> [    0.171170] pci 0000:0b:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
> [    0.171170] pci 0000:0b:00.0: vgaarb: bridge control possible
> [    0.171170] vgaarb: loaded
> [    0.171310] SCSI subsystem initialized
> [    0.171658] libata version 3.00 loaded.
> [    0.171658] ACPI: bus type USB registered
> [    0.171658] usbcore: registered new interface driver usbfs
> [    0.171658] usbcore: registered new interface driver hub
> [    0.171669] usbcore: registered new device driver usb
> [    0.172058] pps_core: LinuxPPS API ver. 1 registered
> [    0.172065] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.172079] PTP clock support registered
> [    0.172169] EDAC MC: Ver: 3.0.0
> [    0.172253] Registered efivars operations
> [    0.190383] PCI: Using ACPI for IRQ routing
> [    0.194660] PCI: pci_cache_line_size set to 64 bytes
> [    0.194738] e820: reserve RAM buffer [mem 0x09d00000-0x0bffffff]
> [    0.194746] e820: reserve RAM buffer [mem 0x0a200000-0x0bffffff]
> [    0.194748] e820: reserve RAM buffer [mem 0x0b000000-0x0bffffff]
> [    0.194749] e820: reserve RAM buffer [mem 0xccaec018-0xcfffffff]
> [    0.194751] e820: reserve RAM buffer [mem 0xccb06018-0xcfffffff]
> [    0.194752] e820: reserve RAM buffer [mem 0xda044000-0xdbffffff]
> [    0.194754] e820: reserve RAM buffer [mem 0xdf000000-0xdfffffff]
> [    0.194756] e820: reserve RAM buffer [mem 0x81f380000-0x81fffffff]
> [    0.195055] NetLabel: Initializing
> [    0.195062] NetLabel:  domain hash size = 128
> [    0.195068] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
> [    0.195102] NetLabel:  unlabeled traffic allowed by default
> [    0.195136] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> [    0.195136] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
> [    0.197131] clocksource: Switched to clocksource tsc-early
> [    0.232919] VFS: Disk quotas dquot_6.6.0
> [    0.232960] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    0.233120] pnp: PnP ACPI init
> [    0.233355] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
> [    0.233380] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
> [    0.233585] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.233899] system 00:02: [io  0x02a0-0x02af] has been reserved
> [    0.233909] system 00:02: [io  0x0230-0x023f] has been reserved
> [    0.233918] system 00:02: [io  0x0290-0x029f] has been reserved
> [    0.233930] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.234422] system 00:03: [io  0x04d0-0x04d1] has been reserved
> [    0.234432] system 00:03: [io  0x040b] has been reserved
> [    0.234440] system 00:03: [io  0x04d6] has been reserved
> [    0.234448] system 00:03: [io  0x0c00-0x0c01] has been reserved
> [    0.234457] system 00:03: [io  0x0c14] has been reserved
> [    0.234465] system 00:03: [io  0x0c50-0x0c51] has been reserved
> [    0.234473] system 00:03: [io  0x0c52] has been reserved
> [    0.234481] system 00:03: [io  0x0c6c] has been reserved
> [    0.234489] system 00:03: [io  0x0c6f] has been reserved
> [    0.234497] system 00:03: [io  0x0cd0-0x0cd1] has been reserved
> [    0.234506] system 00:03: [io  0x0cd2-0x0cd3] has been reserved
> [    0.234515] system 00:03: [io  0x0cd4-0x0cd5] has been reserved
> [    0.234523] system 00:03: [io  0x0cd6-0x0cd7] has been reserved
> [    0.234532] system 00:03: [io  0x0cd8-0x0cdf] has been reserved
> [    0.234540] system 00:03: [io  0x0800-0x089f] has been reserved
> [    0.234549] system 00:03: [io  0x0b00-0x0b0f] has been reserved
> [    0.234557] system 00:03: [io  0x0b20-0x0b3f] has been reserved
> [    0.234566] system 00:03: [io  0x0900-0x090f] has been reserved
> [    0.234574] system 00:03: [io  0x0910-0x091f] has been reserved
> [    0.234585] system 00:03: [mem 0xfec00000-0xfec00fff] could not be reserved
> [    0.234595] system 00:03: [mem 0xfec01000-0xfec01fff] could not be reserved
> [    0.234605] system 00:03: [mem 0xfedc0000-0xfedc0fff] has been reserved
> [    0.234614] system 00:03: [mem 0xfee00000-0xfee00fff] has been reserved
> [    0.234624] system 00:03: [mem 0xfed80000-0xfed8ffff] could not be reserved
> [    0.234634] system 00:03: [mem 0xfec10000-0xfec10fff] has been reserved
> [    0.234643] system 00:03: [mem 0xff000000-0xffffffff] has been reserved
> [    0.234656] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    0.235624] pnp: PnP ACPI: found 4 devices
> [    0.242948] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    0.243081] pci 0000:00:01.1: PCI bridge to [bus 01]
> [    0.243092] pci 0000:00:01.1:   bridge window [mem 0xfe900000-0xfe9fffff]
> [    0.243105] pci 0000:03:00.0: PCI bridge to [bus 04]
> [    0.243114] pci 0000:03:00.0:   bridge window [io  0xd000-0xdfff]
> [    0.243125] pci 0000:03:00.0:   bridge window [mem 0xfe400000-0xfe4fffff]
> [    0.243139] pci 0000:03:01.0: PCI bridge to [bus 05]
> [    0.243147] pci 0000:03:01.0:   bridge window [io  0xc000-0xcfff]
> [    0.243158] pci 0000:03:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
> [    0.243173] pci 0000:03:02.0: PCI bridge to [bus 06]
> [    0.243189] pci 0000:03:03.0: PCI bridge to [bus 07]
> [    0.243205] pci 0000:03:04.0: PCI bridge to [bus 08]
> [    0.243220] pci 0000:02:00.2: PCI bridge to [bus 03-08]
> [    0.243228] pci 0000:02:00.2:   bridge window [io  0xc000-0xdfff]
> [    0.243239] pci 0000:02:00.2:   bridge window [mem 0xfe300000-0xfe4fffff]
> [    0.243254] pci 0000:00:01.3: PCI bridge to [bus 02-08]
> [    0.243261] pci 0000:00:01.3:   bridge window [io  0xc000-0xdfff]
> [    0.243271] pci 0000:00:01.3:   bridge window [mem 0xfe300000-0xfe5fffff]
> [    0.243284] pci 0000:0a:00.0: PCI bridge to [bus 0b]
> [    0.243291] pci 0000:0a:00.0:   bridge window [io  0xe000-0xefff]
> [    0.243303] pci 0000:0a:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.243314] pci 0000:0a:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243328] pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
> [    0.243336] pci 0000:09:00.0:   bridge window [io  0xe000-0xefff]
> [    0.243346] pci 0000:09:00.0:   bridge window [mem 0xfe600000-0xfe6fffff]
> [    0.243357] pci 0000:09:00.0:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243371] pci 0000:00:03.1: PCI bridge to [bus 09-0b]
> [    0.243378] pci 0000:00:03.1:   bridge window [io  0xe000-0xefff]
> [    0.243388] pci 0000:00:03.1:   bridge window [mem 0xfe600000-0xfe7fffff]
> [    0.243398] pci 0000:00:03.1:   bridge window [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243410] pci 0000:00:07.1: PCI bridge to [bus 0c]
> [    0.243419] pci 0000:00:07.1:   bridge window [mem 0xfe000000-0xfe2fffff]
> [    0.243431] pci 0000:00:08.1: PCI bridge to [bus 0d]
> [    0.243440] pci 0000:00:08.1:   bridge window [mem 0xfe800000-0xfe8fffff]
> [    0.243452] pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
> [    0.243454] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
> [    0.243455] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df window]
> [    0.243457] pci_bus 0000:00: resource 7 [io  0x0d00-0xefff window]
> [    0.243458] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
> [    0.243460] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff window]
> [    0.243461] pci_bus 0000:00: resource 10 [mem 0xe0000000-0xfec2ffff window]
> [    0.243462] pci_bus 0000:00: resource 11 [mem 0xfee00000-0xffffffff window]
> [    0.243464] pci_bus 0000:01: resource 1 [mem 0xfe900000-0xfe9fffff]
> [    0.243465] pci_bus 0000:02: resource 0 [io  0xc000-0xdfff]
> [    0.243467] pci_bus 0000:02: resource 1 [mem 0xfe300000-0xfe5fffff]
> [    0.243468] pci_bus 0000:03: resource 0 [io  0xc000-0xdfff]
> [    0.243469] pci_bus 0000:03: resource 1 [mem 0xfe300000-0xfe4fffff]
> [    0.243471] pci_bus 0000:04: resource 0 [io  0xd000-0xdfff]
> [    0.243472] pci_bus 0000:04: resource 1 [mem 0xfe400000-0xfe4fffff]
> [    0.243474] pci_bus 0000:05: resource 0 [io  0xc000-0xcfff]
> [    0.243475] pci_bus 0000:05: resource 1 [mem 0xfe300000-0xfe3fffff]
> [    0.243477] pci_bus 0000:09: resource 0 [io  0xe000-0xefff]
> [    0.243478] pci_bus 0000:09: resource 1 [mem 0xfe600000-0xfe7fffff]
> [    0.243479] pci_bus 0000:09: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243481] pci_bus 0000:0a: resource 0 [io  0xe000-0xefff]
> [    0.243482] pci_bus 0000:0a: resource 1 [mem 0xfe600000-0xfe6fffff]
> [    0.243483] pci_bus 0000:0a: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243485] pci_bus 0000:0b: resource 0 [io  0xe000-0xefff]
> [    0.243486] pci_bus 0000:0b: resource 1 [mem 0xfe600000-0xfe6fffff]
> [    0.243488] pci_bus 0000:0b: resource 2 [mem 0xe0000000-0xf01fffff 64bit pref]
> [    0.243489] pci_bus 0000:0c: resource 1 [mem 0xfe000000-0xfe2fffff]
> [    0.243491] pci_bus 0000:0d: resource 1 [mem 0xfe800000-0xfe8fffff]
> [    0.243699] NET: Registered protocol family 2
> [    0.244208] tcp_listen_portaddr_hash hash table entries: 16384 (order: 8, 1441792 bytes)
> [    0.244585] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.245269] TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
> [    0.246051] TCP: Hash tables configured (established 262144 bind 65536)
> [    0.246437] UDP hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.247119] UDP-Lite hash table entries: 16384 (order: 9, 3145728 bytes)
> [    0.247683] NET: Registered protocol family 1
> [    0.247696] NET: Registered protocol family 44
> [    0.248113] pci 0000:0b:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
> [    0.248151] pci 0000:0b:00.1: Linked as a consumer to 0000:0b:00.0
> [    0.248545] PCI: CLS 64 bytes, default 64
> [    0.248705] Unpacking initramfs...
> [    0.596544] Freeing initrd memory: 28092K
> [    0.596655] AMD-Vi: IOMMU performance counters supported
> [    0.597147] iommu: Adding device 0000:00:01.0 to group 0
> [    0.597291] iommu: Adding device 0000:00:01.1 to group 1
> [    0.597462] iommu: Adding device 0000:00:01.3 to group 2
> [    0.597654] iommu: Adding device 0000:00:02.0 to group 3
> [    0.597868] iommu: Adding device 0000:00:03.0 to group 4
> [    0.598054] iommu: Adding device 0000:00:03.1 to group 5
> [    0.598210] iommu: Adding device 0000:00:04.0 to group 6
> [    0.598399] iommu: Adding device 0000:00:07.0 to group 7
> [    0.598583] iommu: Adding device 0000:00:07.1 to group 8
> [    0.598734] iommu: Adding device 0000:00:08.0 to group 9
> [    0.598922] iommu: Adding device 0000:00:08.1 to group 10
> [    0.599082] iommu: Adding device 0000:00:14.0 to group 11
> [    0.599121] iommu: Adding device 0000:00:14.3 to group 11
> [    0.599383] iommu: Adding device 0000:00:18.0 to group 12
> [    0.599422] iommu: Adding device 0000:00:18.1 to group 12
> [    0.599460] iommu: Adding device 0000:00:18.2 to group 12
> [    0.599495] iommu: Adding device 0000:00:18.3 to group 12
> [    0.599531] iommu: Adding device 0000:00:18.4 to group 12
> [    0.599567] iommu: Adding device 0000:00:18.5 to group 12
> [    0.599603] iommu: Adding device 0000:00:18.6 to group 12
> [    0.599641] iommu: Adding device 0000:00:18.7 to group 12
> [    0.599901] iommu: Adding device 0000:01:00.0 to group 13
> [    0.600091] iommu: Adding device 0000:02:00.0 to group 14
> [    0.600139] iommu: Adding device 0000:02:00.1 to group 14
> [    0.600183] iommu: Adding device 0000:02:00.2 to group 14
> [    0.600206] iommu: Adding device 0000:03:00.0 to group 14
> [    0.600232] iommu: Adding device 0000:03:01.0 to group 14
> [    0.600256] iommu: Adding device 0000:03:02.0 to group 14
> [    0.600281] iommu: Adding device 0000:03:03.0 to group 14
> [    0.600306] iommu: Adding device 0000:03:04.0 to group 14
> [    0.600336] iommu: Adding device 0000:04:00.0 to group 14
> [    0.600369] iommu: Adding device 0000:05:00.0 to group 14
> [    0.600555] iommu: Adding device 0000:09:00.0 to group 15
> [    0.600698] iommu: Adding device 0000:0a:00.0 to group 16
> [    0.600934] iommu: Adding device 0000:0b:00.0 to group 17
> [    0.601101] iommu: Using direct mapping for device 0000:0b:00.0
> [    0.601228] iommu: Adding device 0000:0b:00.1 to group 18
> [    0.601410] iommu: Adding device 0000:0c:00.0 to group 19
> [    0.601552] iommu: Adding device 0000:0c:00.2 to group 20
> [    0.601743] iommu: Adding device 0000:0c:00.3 to group 21
> [    0.601889] iommu: Adding device 0000:0d:00.0 to group 22
> [    0.602071] iommu: Adding device 0000:0d:00.2 to group 23
> [    0.602260] iommu: Adding device 0000:0d:00.3 to group 24
> [    0.602446] AMD-Vi: Found IOMMU at 0000:00:00.2 cap 0x40
> [    0.602456] AMD-Vi: Extended features (0xf77ef22294ada):
> [    0.602463]  PPR NX GT IA GA PC GA_vAPIC
> [    0.602471] AMD-Vi: Interrupt remapping enabled
> [    0.602477] AMD-Vi: Virtual APIC enabled
> [    0.602627] AMD-Vi: Lazy IO/TLB flushing enabled
> [    0.608651] amd_uncore: AMD NB counters detected
> [    0.608668] amd_uncore: AMD LLC counters detected
> [    0.609038] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
> [    0.611397] check: Scanning for low memory corruption every 60 seconds
> [    0.611745] cryptomgr_test (115) used greatest stack depth: 14496 bytes left
> [    0.613159] modprobe (116) used greatest stack depth: 13760 bytes left
> [    0.614368] Initialise system trusted keyrings
> [    0.614440] Key type blacklist registered
> [    0.614516] workingset: timestamp_bits=36 max_order=23 bucket_order=0
> [    0.618105] zbud: loaded
> [    0.619878] Platform Keyring initialized
> [    0.720608] cryptomgr_test (149) used greatest stack depth: 13696 bytes left
> [    0.730472] alg: No test for 842 (842-generic)
> [    0.731666] alg: No test for 842 (842-scomp)
> [    0.736559] cryptomgr_test (167) used greatest stack depth: 13536 bytes left
> [    0.767862] NET: Registered protocol family 38
> [    0.767886] Key type asymmetric registered
> [    0.767900] Asymmetric key parser 'x509' registered
> [    0.767930] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 242)
> [    0.768046] io scheduler mq-deadline registered
> [    0.768565] atomic64_test: passed for x86-64 platform with CX8 and with SSE
> [    0.769524] aer 0000:00:01.1:pcie002: AER enabled with IRQ 26
> [    0.770529] aer 0000:00:01.3:pcie002: AER enabled with IRQ 27
> [    0.771491] aer 0000:00:03.1:pcie002: AER enabled with IRQ 28
> [    0.772512] aer 0000:00:07.1:pcie002: AER enabled with IRQ 29
> [    0.774455] aer 0000:00:08.1:pcie002: AER enabled with IRQ 31
> [    0.776910] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [    0.776958] efifb: probing for efifb
> [    0.776977] efifb: No BGRT, not showing boot graphics
> [    0.776984] efifb: framebuffer at 0xe0000000, using 3072k, total 3072k
> [    0.776992] efifb: mode is 1024x768x32, linelength=4096, pages=1
> [    0.777000] efifb: scrolling: redraw
> [    0.777006] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
> [    0.777306] Console: switching to colour frame buffer device 128x48
> [    0.778279] fb0: EFI VGA frame buffer device
> [    0.778497] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
> [    0.778546] ACPI: Power Button [PWRB]
> [    0.778623] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [    0.778776] ACPI: Power Button [PWRF]
> [    0.778883] Monitor-Mwait will be used to enter C-1 state
> [    0.781617] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
> [    0.802567] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    0.806203] Non-volatile memory driver v1.3
> [    0.806262] Linux agpgart interface v0.103
> [    0.809296] ahci 0000:02:00.1: version 3.0
> [    0.809474] ahci 0000:02:00.1: SSS flag set, parallel bus scan disabled
> [    0.809548] ahci 0000:02:00.1: AHCI 0001.0301 32 slots 8 ports 6 Gbps 0xff impl SATA mode
> [    0.809574] ahci 0000:02:00.1: flags: 64bit ncq sntf stag pm led clo only pmp pio slum part sxs deso sadm sds apst 
> [    0.811034] scsi host0: ahci
> [    0.811341] scsi host1: ahci
> [    0.811514] scsi host2: ahci
> [    0.811689] scsi host3: ahci
> [    0.811867] scsi host4: ahci
> [    0.812044] scsi host5: ahci
> [    0.812208] scsi host6: ahci
> [    0.812382] scsi host7: ahci
> [    0.812488] ata1: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580100 irq 44
> [    0.812513] ata2: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580180 irq 44
> [    0.812537] ata3: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580200 irq 44
> [    0.812927] ata4: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580280 irq 44
> [    0.813304] ata5: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580300 irq 44
> [    0.813668] ata6: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580380 irq 44
> [    0.814034] ata7: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580400 irq 44
> [    0.814389] ata8: SATA max UDMA/133 abar m131072@0xfe580000 port 0xfe580480 irq 44
> [    0.814968] ahci 0000:0d:00.2: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
> [    0.815327] ahci 0000:0d:00.2: flags: 64bit ncq sntf ilck pm led clo only pmp fbs pio slum part 
> [    0.815934] scsi host8: ahci
> [    0.816366] ata9: SATA max UDMA/133 abar m4096@0xfe808000 port 0xfe808100 irq 46
> [    0.816882] libphy: Fixed MDIO Bus: probed
> [    0.817373] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    0.817736] ehci-pci: EHCI PCI platform driver
> [    0.818112] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    0.818480] ohci-pci: OHCI PCI platform driver
> [    0.818865] uhci_hcd: USB Universal Host Controller Interface driver
> [    0.819406] xhci_hcd 0000:02:00.0: xHCI Host Controller
> [    0.820034] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 1
> [    0.875811] xhci_hcd 0000:02:00.0: hcc params 0x0200ef81 hci version 0x110 quirks 0x0000000000000410
> [    0.877411] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 5.00
> [    0.877818] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.878211] usb usb1: Product: xHCI Host Controller
> [    0.878604] usb usb1: Manufacturer: Linux 5.0.0-0.rc2.git1.2.fc30.x86_64 xhci-hcd
> [    0.879003] usb usb1: SerialNumber: 0000:02:00.0
> [    0.879751] hub 1-0:1.0: USB hub found
> [    0.880221] hub 1-0:1.0: 14 ports detected
> [    0.915597] xhci_hcd 0000:02:00.0: xHCI Host Controller
> [    0.916117] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 2
> [    0.916509] xhci_hcd 0000:02:00.0: Host supports USB 3.10 Enhanced SuperSpeed
> [    0.916963] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
> [    0.917411] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 5.00
> [    0.917797] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.918180] usb usb2: Product: xHCI Host Controller
> [    0.918551] usb usb2: Manufacturer: Linux 5.0.0-0.rc2.git1.2.fc30.x86_64 xhci-hcd
> [    0.918936] usb usb2: SerialNumber: 0000:02:00.0
> [    0.919560] hub 2-0:1.0: USB hub found
> [    0.919991] hub 2-0:1.0: 8 ports detected
> [    0.939859] xhci_hcd 0000:0c:00.3: xHCI Host Controller
> [    0.940300] xhci_hcd 0000:0c:00.3: new USB bus registered, assigned bus number 3
> [    0.940783] xhci_hcd 0000:0c:00.3: hcc params 0x0270f665 hci version 0x100 quirks 0x0000000000000410
> [    0.941718] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 5.00
> [    0.942117] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.942518] usb usb3: Product: xHCI Host Controller
> [    0.942921] usb usb3: Manufacturer: Linux 5.0.0-0.rc2.git1.2.fc30.x86_64 xhci-hcd
> [    0.943344] usb usb3: SerialNumber: 0000:0c:00.3
> [    0.943961] hub 3-0:1.0: USB hub found
> [    0.944389] hub 3-0:1.0: 4 ports detected
> [    0.945161] xhci_hcd 0000:0c:00.3: xHCI Host Controller
> [    0.945642] xhci_hcd 0000:0c:00.3: new USB bus registered, assigned bus number 4
> [    0.946085] xhci_hcd 0000:0c:00.3: Host supports USB 3.0  SuperSpeed
> [    0.946552] usb usb4: We don't know the algorithms for LPM for this host, disabling LPM.
> [    0.947055] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 5.00
> [    0.947522] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    0.947994] usb usb4: Product: xHCI Host Controller
> [    0.948456] usb usb4: Manufacturer: Linux 5.0.0-0.rc2.git1.2.fc30.x86_64 xhci-hcd
> [    0.948925] usb usb4: SerialNumber: 0000:0c:00.3
> [    0.949567] hub 4-0:1.0: USB hub found
> [    0.950033] hub 4-0:1.0: 4 ports detected
> [    0.950873] usbcore: registered new interface driver usbserial_generic
> [    0.951354] usbserial: USB Serial support registered for generic
> [    0.951846] i8042: PNP: No PS/2 controller found.
> [    0.952367] mousedev: PS/2 mouse device common for all mice
> [    0.953131] rtc_cmos 00:01: RTC can wake from S4
> [    0.953920] rtc_cmos 00:01: registered as rtc0
> [    0.954361] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [    0.954940] device-mapper: uevent: version 1.0.3
> [    0.955497] device-mapper: ioctl: 4.39.0-ioctl (2018-04-03) initialised: dm-devel@redhat.com
> [    0.956436] hidraw: raw HID events driver (C) Jiri Kosina
> [    0.956941] usbcore: registered new interface driver usbhid
> [    0.957387] usbhid: USB HID core driver
> [    0.957981] drop_monitor: Initializing network drop monitor service
> [    0.958701] Initializing XFRM netlink socket
> [    0.959368] NET: Registered protocol family 10
> [    0.964051] Segment Routing with IPv6
> [    0.964506] mip6: Mobile IPv6
> [    0.964947] NET: Registered protocol family 17
> [    0.965448] start plist test
> [    0.966719] end plist test
> [    0.968736] RAS: Correctable Errors collector initialized.
> [    0.969247] microcode: CPU0: patch_level=0x0800820b
> [    0.969686] microcode: CPU1: patch_level=0x0800820b
> [    0.970118] microcode: CPU2: patch_level=0x0800820b
> [    0.970539] microcode: CPU3: patch_level=0x0800820b
> [    0.970947] microcode: CPU4: patch_level=0x0800820b
> [    0.971351] microcode: CPU5: patch_level=0x0800820b
> [    0.971747] microcode: CPU6: patch_level=0x0800820b
> [    0.972159] microcode: CPU7: patch_level=0x0800820b
> [    0.972590] microcode: CPU8: patch_level=0x0800820b
> [    0.972985] microcode: CPU9: patch_level=0x0800820b
> [    0.973356] microcode: CPU10: patch_level=0x0800820b
> [    0.973720] microcode: CPU11: patch_level=0x0800820b
> [    0.974074] microcode: CPU12: patch_level=0x0800820b
> [    0.974438] microcode: CPU13: patch_level=0x0800820b
> [    0.974790] microcode: CPU14: patch_level=0x0800820b
> [    0.975122] microcode: CPU15: patch_level=0x0800820b
> [    0.975484] microcode: Microcode Update Driver: v2.2.
> [    0.975509] AVX2 version of gcm_enc/dec engaged.
> [    0.976148] AES CTR mode by8 optimization enabled
> [    1.015621] sched_clock: Marking stable (1024582303, -8969870)->(1547955022, -532342589)
> [    1.016730] registered taskstats version 1
> [    1.017078] Loading compiled-in X.509 certificates
> [    1.038801] Loaded X.509 cert 'Fedora kernel signing key: 3fc468cc0ede23baa06ffa7ca2a50626dc8d6767'
> [    1.039252] zswap: loaded using pool lzo/zbud
> [    1.047349] Key type big_key registered
> [    1.051316] Key type encrypted registered
> [    1.052795] ima: No TPM chip found, activating TPM-bypass!
> [    1.053142] ima: Allocated hash algorithm: sha1
> [    1.053486] No architecture policies found
> [    1.054783]   Magic number: 3:218:614
> [    1.055181] acpi PNP0303:00: hash matches
> [    1.055642] rtc_cmos 00:01: setting system clock to 2019-01-18T03:36:44 UTC (1547782604)
> [    1.123324] ata1: SATA link down (SStatus 0 SControl 330)
> [    1.123905] ata9: SATA link down (SStatus 0 SControl 300)
> [    1.240049] usb 1-10: new full-speed USB device number 2 using xhci_hcd
> [    1.264044] usb 3-1: new high-speed USB device number 2 using xhci_hcd
> [    1.396995] usb 3-1: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    1.397339] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.397639] usb 3-1: Product: USB2.0 Hub
> [    1.397934] usb 3-1: Manufacturer: VIA Labs, Inc.
> [    1.430729] ata2: SATA link down (SStatus 0 SControl 330)
> [    1.459140] hub 3-1:1.0: USB hub found
> [    1.460116] hub 3-1:1.0: 4 ports detected
> [    1.547722] usb 4-1: new SuperSpeed Gen 1 USB device number 2 using xhci_hcd
> [    1.548205] usb 1-10: New USB device found, idVendor=0b05, idProduct=1872, bcdDevice= 2.00
> [    1.548673] usb 1-10: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    1.549146] usb 1-10: Product: AURA LED Controller
> [    1.549606] usb 1-10: Manufacturer: AsusTek Computer Inc.
> [    1.549989] usb 1-10: SerialNumber: 00000000001A
> [    1.561816] usb 2-2: new SuperSpeed Gen 1 USB device number 2 using xhci_hcd
> [    1.568633] hid-generic 0003:0B05:1872.0001: hiddev96,hidraw0: USB HID v1.11 Device [AsusTek Computer Inc. AURA LED Controller] on usb-0000:02:00.0-10/input0
> [    1.579419] usb 2-2: New USB device found, idVendor=152d, idProduct=9561, bcdDevice= 1.05
> [    1.579801] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=5
> [    1.580188] usb 2-2: Product: JMS56x Series
> [    1.580570] usb 2-2: Manufacturer: JMicron
> [    1.580958] usb 2-2: SerialNumber: 00000000000000000000
> [    1.622498] tsc: Refined TSC clocksource calibration: 3693.059 MHz
> [    1.623094] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x6a77744cfd5, max_idle_ns: 881590969987 ns
> [    1.623704] clocksource: Switched to clocksource tsc
> [    1.646000] usb 4-1: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    1.646464] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.646913] usb 4-1: Product: USB3.0 Hub
> [    1.647356] usb 4-1: Manufacturer: VIA Labs, Inc.
> [    1.666968] hub 4-1:1.0: USB hub found
> [    1.667768] hub 4-1:1.0: 4 ports detected
> [    1.690045] usb 1-12: new full-speed USB device number 3 using xhci_hcd
> [    1.741783] ata3: SATA link down (SStatus 0 SControl 330)
> [    1.784165] usb 4-3: new SuperSpeed Gen 1 USB device number 3 using xhci_hcd
> [    1.798006] usb 4-3: LPM exit latency is zeroed, disabling LPM.
> [    1.799525] usb 4-3: Int endpoint with wBytesPerInterval of 1024 in config 1 interface 4 altsetting 0 ep 135: setting to 262
> [    1.801378] usb 4-3: New USB device found, idVendor=07ca, idProduct=0553, bcdDevice= 3.08
> [    1.801841] usb 4-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    1.802310] usb 4-3: Product: Live Gamer Ultra-Video
> [    1.802770] usb 4-3: Manufacturer: AVerMedia
> [    1.803228] usb 4-3: SerialNumber: 5202584700069
> [    1.879049] usb 3-1.1: new high-speed USB device number 3 using xhci_hcd
> [    1.881866] hid-generic 0003:07CA:0553.0002: hiddev97,hidraw1: USB HID v1.11 Device [AVerMedia Live Gamer Ultra-Video] on usb-0000:0c:00.3-3/input4
> [    1.920271] usb 1-12: New USB device found, idVendor=0b05, idProduct=185c, bcdDevice= 1.10
> [    1.920758] usb 1-12: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    1.921267] usb 1-12: Product: Bluetooth Radio 
> [    1.921765] usb 1-12: Manufacturer: Realtek 
> [    1.922260] usb 1-12: SerialNumber: 00e04c000001
> [    1.978129] usb 3-1.1: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    1.978615] usb 3-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    1.979103] usb 3-1.1: Product: USB2.0 Hub
> [    1.979579] usb 3-1.1: Manufacturer: VIA Labs, Inc.
> [    2.034946] hub 3-1.1:1.0: USB hub found
> [    2.036007] hub 3-1.1:1.0: 4 ports detected
> [    2.051550] ata4: SATA link down (SStatus 0 SControl 330)
> [    2.110122] usb 4-1.1: new SuperSpeed Gen 1 USB device number 4 using xhci_hcd
> [    2.209127] usb 4-1.1: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.209608] usb 4-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.210088] usb 4-1.1: Product: USB3.0 Hub
> [    2.210549] usb 4-1.1: Manufacturer: VIA Labs, Inc.
> [    2.242980] hub 4-1.1:1.0: USB hub found
> [    2.243894] hub 4-1.1:1.0: 4 ports detected
> [    2.286083] usb 3-1.2: new full-speed USB device number 4 using xhci_hcd
> [    2.366682] ata5: SATA link down (SStatus 0 SControl 330)
> [    2.400399] usb 3-1.2: New USB device found, idVendor=0a12, idProduct=0001, bcdDevice=88.91
> [    2.400852] usb 3-1.2: New USB device strings: Mfr=0, Product=2, SerialNumber=0
> [    2.401304] usb 3-1.2: Product: CSR8510 A10
> [    2.499932] usb 4-1.3: new SuperSpeed Gen 1 USB device number 5 using xhci_hcd
> [    2.599004] usb 4-1.3: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    2.599479] usb 4-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.599929] usb 4-1.3: Product: USB3.0 Hub
> [    2.600363] usb 4-1.3: Manufacturer: VIA Labs, Inc.
> [    2.626834] hub 4-1.3:1.0: USB hub found
> [    2.627869] hub 4-1.3:1.0: 4 ports detected
> [    2.676099] usb 3-1.1.2: new full-speed USB device number 5 using xhci_hcd
> [    2.780760] usb 3-1.1.2: New USB device found, idVendor=046d, idProduct=c52b, bcdDevice=12.07
> [    2.781227] usb 3-1.1.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.781675] usb 3-1.1.2: Product: USB Receiver
> [    2.782118] usb 3-1.1.2: Manufacturer: Logitech
> [    2.830434] ata6: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
> [    2.834613] ata6.00: ATA-10: ST12000NE0007-2GT116, EN01, max UDMA/133
> [    2.835243] ata6.00: 23437770752 sectors, multi 16: LBA48 NCQ (depth 32), AA
> [    2.838411] ata6.00: configured for UDMA/133
> [    2.839628] scsi 5:0:0:0: Direct-Access     ATA      ST12000NE0007-2G EN01 PQ: 0 ANSI: 5
> [    2.840634] sd 5:0:0:0: [sda] 23437770752 512-byte logical blocks: (12.0 TB/10.9 TiB)
> [    2.840808] sd 5:0:0:0: Attached scsi generic sg0 type 0
> [    2.841124] sd 5:0:0:0: [sda] 4096-byte physical blocks
> [    2.842045] sd 5:0:0:0: [sda] Write Protect is off
> [    2.842492] sd 5:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    2.842513] sd 5:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    2.851075] usb 3-1.3: new high-speed USB device number 6 using xhci_hcd
> [    2.861597] sd 5:0:0:0: [sda] Attached SCSI disk
> [    2.965522] usb 3-1.3: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    2.965962] usb 3-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    2.966398] usb 3-1.3: Product: USB2.0 Hub
> [    2.966810] usb 3-1.3: Manufacturer: VIA Labs, Inc.
> [    3.026973] hub 3-1.3:1.0: USB hub found
> [    3.028010] hub 3-1.3:1.0: 4 ports detected
> [    3.068073] usb 4-1.4: new SuperSpeed Gen 1 USB device number 6 using xhci_hcd
> [    3.148104] ata7: SATA link down (SStatus 0 SControl 330)
> [    3.166256] usb 4-1.4: New USB device found, idVendor=2109, idProduct=0813, bcdDevice=90.11
> [    3.166699] usb 4-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.167135] usb 4-1.4: Product: USB3.0 Hub
> [    3.167557] usb 4-1.4: Manufacturer: VIA Labs, Inc.
> [    3.186922] hub 4-1.4:1.0: USB hub found
> [    3.187642] hub 4-1.4:1.0: 4 ports detected
> [    3.285423] usb 3-1.1.3: new low-speed USB device number 7 using xhci_hcd
> [    3.430742] usb 3-1.1.3: New USB device found, idVendor=046d, idProduct=c326, bcdDevice=79.00
> [    3.431190] usb 3-1.1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.431618] usb 3-1.1.3: Product: USB Keyboard
> [    3.432048] usb 3-1.1.3: Manufacturer: Logitech
> [    3.462944] ata8: SATA link down (SStatus 0 SControl 330)
> [    3.466829] Freeing unused decrypted memory: 2040K
> [    3.468408] Freeing unused kernel image memory: 4868K
> [    3.474248] Write protecting the kernel read-only data: 22528k
> [    3.476288] Freeing unused kernel image memory: 2036K
> [    3.477266] Freeing unused kernel image memory: 1648K
> [    3.483995] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    3.484394] rodata_test: all tests were successful
> [    3.484793] Run /init as init process
> [    3.501075] usb 3-1.4: new high-speed USB device number 8 using xhci_hcd
> [    3.514922] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.0/0003:046D:C326.0006/input/input2
> [    3.543925] systemd[1]: systemd 240 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    3.557077] systemd[1]: Detected architecture x86-64.
> [    3.557556] systemd[1]: Running in initial RAM disk.
> [    3.570480] hid-generic 0003:046D:C326.0006: input,hidraw2: USB HID v1.10 Keyboard [Logitech USB Keyboard] on usb-0000:0c:00.3-1.1.3/input0
> [    3.573251] systemd[1]: Set hostname to <localhost.localdomain>.
> [    3.574806] input: Logitech USB Keyboard Consumer Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.1/0003:046D:C326.0007/input/input3
> [    3.606633] usb 3-1.4: New USB device found, idVendor=2109, idProduct=2813, bcdDevice=90.11
> [    3.607224] usb 3-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.607769] usb 3-1.4: Product: USB2.0 Hub
> [    3.608310] usb 3-1.4: Manufacturer: VIA Labs, Inc.
> [    3.628151] input: Logitech USB Keyboard System Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.3/3-1.1.3:1.1/0003:046D:C326.0007/input/input4
> [    3.629420] hid-generic 0003:046D:C326.0007: input,hiddev98,hidraw3: USB HID v1.10 Device [Logitech USB Keyboard] on usb-0000:0c:00.3-1.1.3/input1
> [    3.640115] systemd[1]: Listening on Journal Audit Socket.
> [    3.641916] systemd[1]: Listening on Journal Socket.
> [    3.643719] systemd[1]: Listening on udev Control Socket.
> [    3.651250] systemd[1]: Starting Setup Virtual Console...
> [    3.653201] systemd[1]: Listening on Journal Socket (/dev/log).
> [    3.654789] systemd[1]: Reached target Slices.
> [    3.667063] hub 3-1.4:1.0: USB hub found
> [    3.667958] systemd-sysctl (381) used greatest stack depth: 13456 bytes left
> [    3.668008] hub 3-1.4:1.0: 4 ports detected
> [    3.683043] usb 3-1.3.3: new full-speed USB device number 9 using xhci_hcd
> [    3.693724] audit: type=1130 audit(1547782607.137:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.719492] audit: type=1130 audit(1547782607.163:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.720727] audit: type=1131 audit(1547782607.163:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.781257] usb 3-1.3.3: New USB device found, idVendor=054c, idProduct=09cc, bcdDevice= 1.00
> [    3.781886] usb 3-1.3.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    3.782762] usb 3-1.3.3: Product: Wireless Controller
> [    3.783510] usb 3-1.3.3: Manufacturer: Sony Interactive Entertainment
> [    3.788731] audit: type=1130 audit(1547782607.232:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.812418] dracut-cmdline (390) used greatest stack depth: 13416 bytes left
> [    3.814603] audit: type=1130 audit(1547782607.258:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.850557] audit: type=1130 audit(1547782607.294:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.870728] audit: type=1130 audit(1547782607.314:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    3.883495] input: Sony Interactive Entertainment Wireless Controller Touchpad as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.3/0003:054C:09CC.0008/input/input6
> [    3.885460] input: Sony Interactive Entertainment Wireless Controller Motion Sensors as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.3/0003:054C:09CC.0008/input/input7
> [    3.939131] input: Sony Interactive Entertainment Wireless Controller as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.3/3-1.3.3/3-1.3.3:1.3/0003:054C:09CC.0008/input/input5
> [    3.941080] sony 0003:054C:09CC.0008: input,hidraw4: USB HID v81.11 Gamepad [Sony Interactive Entertainment Wireless Controller] on usb-0000:0c:00.3-1.3.3/input3
> [    3.985046] usb 3-1.4.4: new high-speed USB device number 10 using xhci_hcd
> [    4.081380] usb 3-1.4.4: New USB device found, idVendor=8564, idProduct=1000, bcdDevice= a.00
> [    4.082131] usb 3-1.4.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [    4.082868] usb 3-1.4.4: Product: Mass Storage Device
> [    4.083609] usb 3-1.4.4: Manufacturer: JetFlash
> [    4.084346] usb 3-1.4.4: SerialNumber: 3988821812
> [    4.091408] usb-storage 3-1.4.4:1.0: USB Mass Storage device detected
> [    4.092845] scsi host9: usb-storage 3-1.4.4:1.0
> [    4.094241] usbcore: registered new interface driver usb-storage
> [    4.122360] scsi host10: uas
> [    4.124012] usbcore: registered new interface driver uas
> [    4.124815] scsi 10:0:0:0: Direct-Access     HGST HUH 721212ALE604     0105 PQ: 0 ANSI: 6
> [    4.127573] sd 10:0:0:0: Attached scsi generic sg1 type 0
> [    4.128449] sd 10:0:0:0: [sdb] 23437770752 512-byte logical blocks: (12.0 TB/10.9 TiB)
> [    4.130223] sd 10:0:0:0: [sdb] Write Protect is off
> [    4.130235] audit: type=1130 audit(1547782607.574:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    4.131373] sd 10:0:0:0: [sdb] Mode Sense: 67 00 10 08
> [    4.133703] sd 10:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO and FUA
> [    4.138614] acpi PNP0C14:01: duplicate WMI GUID 05901221-D566-11D1-B2F0-00A0C9062910 (first instance was on PNP0C14:00)
> [    4.141591] dca service started, version 1.12.1
> [    4.141855] sd 10:0:0:0: [sdb] Attached SCSI disk
> [    4.148006] nvme nvme0: pci function 0000:01:00.0
> [    4.157279] audit: type=1130 audit(1547782607.601:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=plymouth-start comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    4.160185] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
> [    4.161222] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    4.185086] logitech-djreceiver 0003:046D:C52B.0005: hiddev99,hidraw5: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:0c:00.3-1.1.2/input2
> [    4.190728] pps pps0: new PPS source ptp0
> [    4.191720] igb 0000:04:00.0: added PHC on eth0
> [    4.192712] igb 0000:04:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    4.193669] igb 0000:04:00.0: eth0: (PCIe:2.5Gb/s:Width x1) 4c:ed:fb:75:5b:ab
> [    4.194683] igb 0000:04:00.0: eth0: PBA No: FFFFFF-0FF
> [    4.195625] igb 0000:04:00.0: Using MSI-X interrupts. 2 rx queue(s), 2 tx queue(s)
> [    4.201022] AMD-Vi: AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
> [    4.227095] igb 0000:04:00.0 enp4s0: renamed from eth0
> [    4.238578] ata_id (557) used greatest stack depth: 13296 bytes left
> [    4.296053] input: Logitech Unifying Device. Wireless PID:4026 Keyboard as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.2/0003:046D:C52B.0005/0003:046D:4026.0009/input/input8
> [    4.298396] input: Logitech Unifying Device. Wireless PID:4026 Mouse as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.2/0003:046D:C52B.0005/0003:046D:4026.0009/input/input9
> [    4.299897] input: Logitech Unifying Device. Wireless PID:4026 Consumer Control as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.2/0003:046D:C52B.0005/0003:046D:4026.0009/input/input10
> [    4.301650] hid-generic 0003:046D:4026.0009: input,hidraw6: USB HID v1.11 Keyboard [Logitech Unifying Device. Wireless PID:4026] on usb-0000:0c:00.3-1.1.2:1
> [    4.362163] nvme nvme0: 16/0/0 default/read/poll queues
> [    4.366098]  nvme0n1: p1 p2 p3
> [    4.389688] [drm] amdgpu kernel modesetting enabled.
> [    4.390494] Parsing CRAT table with 1 nodes
> [    4.391150] Ignoring ACPI CRAT on non-APU system
> [    4.391784] Virtual CRAT table created for CPU
> [    4.392420] Parsing CRAT table with 1 nodes
> [    4.393057] Creating topology SYSFS entries
> [    4.393729] Topology: Add CPU node
> [    4.394339] Finished initializing topology
> [    4.395121] checking generic (e0000000 300000) vs hw (e0000000 10000000)
> [    4.395123] fb0: switching to amdgpudrmfb from EFI VGA
> [    4.395781] Console: switching to colour dummy device 80x25
> [    4.397956] [drm] initializing kernel modesetting (VEGA10 0x1002:0x687F 0x1458:0x2308 0xC1).
> [    4.398068] [drm] register mmio base: 0xFE600000
> [    4.398075] [drm] register mmio size: 524288
> [    4.398092] [drm] add ip block number 0 <soc15_common>
> [    4.398098] [drm] add ip block number 1 <gmc_v9_0>
> [    4.398105] [drm] add ip block number 2 <vega10_ih>
> [    4.398111] [drm] add ip block number 3 <psp>
> [    4.398116] [drm] add ip block number 4 <gfx_v9_0>
> [    4.398123] [drm] add ip block number 5 <sdma_v4_0>
> [    4.398129] [drm] add ip block number 6 <powerplay>
> [    4.398135] [drm] add ip block number 7 <dm>
> [    4.398141] [drm] add ip block number 8 <uvd_v7_0>
> [    4.398147] [drm] add ip block number 9 <vce_v4_0>
> [    4.398392] [drm] UVD(0) is enabled in VM mode
> [    4.398398] [drm] UVD(0) ENC is enabled in VM mode
> [    4.398404] [drm] VCE enabled in VM mode
> [    4.398464] amdgpu 0000:0b:00.0: No more image in the PCI ROM
> [    4.398487] ATOM BIOS: xxx-xxx-xxx
> [    4.398564] [drm] vm size is 262144 GB, 4 levels, block size is 9-bit, fragment size is 9-bit
> [    4.398581] amdgpu 0000:0b:00.0: VRAM: 8176M 0x000000F400000000 - 0x000000F5FEFFFFFF (8176M used)
> [    4.398592] amdgpu 0000:0b:00.0: GART: 512M 0x0000000000000000 - 0x000000001FFFFFFF
> [    4.398601] amdgpu 0000:0b:00.0: AGP: 267419648M 0x000000F800000000 - 0x0000FFFFFFFFFFFF
> [    4.398614] [drm] Detected VRAM RAM=8176M, BAR=256M
> [    4.398620] [drm] RAM width 2048bits HBM
> [    4.398998] [TTM] Zone  kernel: Available graphics memory: 16439748 kiB
> [    4.399028] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
> [    4.399048] [TTM] Initializing pool allocator
> [    4.399072] [TTM] Initializing DMA pool allocator
> [    4.399324] [drm] amdgpu: 8176M of VRAM memory ready
> [    4.399333] [drm] amdgpu: 8176M of GTT memory ready.
> [    4.399429] [drm] GART: num cpu pages 131072, num gpu pages 131072
> [    4.399599] [drm] PCIE GART of 512M enabled (table at 0x000000F400900000).
> [    4.402869] [drm] use_doorbell being set to: [true]
> [    4.402948] [drm] use_doorbell being set to: [true]
> [    4.403361] [drm] Found UVD firmware Version: 1.87 Family ID: 17
> [    4.403374] [drm] PSP loading UVD firmware
> [    4.404077] [drm] Found VCE firmware Version: 55.3 Binary ID: 4
> [    4.404093] [drm] PSP loading VCE firmware
> [    4.458356] PM: Image not found (code -22)
> [    4.553683] [drm] reserve 0x400000 from 0xf400d00000 for PSP TMR SIZE
> [    4.615005] input: Logitech T400 as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.2/0003:046D:C52B.0005/0003:046D:4026.0009/input/input14
> [    4.615782] logitech-hidpp-device 0003:046D:4026.0009: input,hidraw6: USB HID v1.11 Keyboard [Logitech T400] on usb-0000:0c:00.3-1.1.2:1
> [    4.643082] [drm] Display Core initialized with v3.2.08!
> [    4.676161] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
> [    4.676170] [drm] Driver supports precise vblank timestamp query.
> [    4.697484] [drm] UVD and UVD ENC initialized successfully.
> [    4.797975] [drm] VCE initialized successfully.
> [    4.801037] kfd kfd: Allocated 3969056 bytes on gart
> [    4.801085] Virtual CRAT table created for GPU
> [    4.801091] Parsing CRAT table with 1 nodes
> [    4.801119] Creating topology SYSFS entries
> [    4.801589] Topology: Add dGPU node [0x687f:0x1002]
> [    4.801989] kfd kfd: added device 1002:687f
> [    4.807496] [drm] fb mappable at 0xE1100000
> [    4.807551] [drm] vram apper at 0xE0000000
> [    4.807556] [drm] size 33177600
> [    4.807561] [drm] fb depth is 24
> [    4.807565] [drm]    pitch is 15360
> [    4.808194] fbcon: amdgpudrmfb (fb0) is primary device
> [    4.834126] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [    4.834132] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [    4.834134] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [    4.834136] pcieport 0000:00:03.1:    [12] Timeout               
> [    4.843852] Console: switching to colour frame buffer device 480x135
> [    4.869800] amdgpu 0000:0b:00.0: fb0: amdgpudrmfb frame buffer device
> [    4.879254] amdgpu 0000:0b:00.0: ring gfx uses VM inv eng 0 on hub 0
> [    4.879256] amdgpu 0000:0b:00.0: ring comp_1.0.0 uses VM inv eng 1 on hub 0
> [    4.879257] amdgpu 0000:0b:00.0: ring comp_1.1.0 uses VM inv eng 4 on hub 0
> [    4.879259] amdgpu 0000:0b:00.0: ring comp_1.2.0 uses VM inv eng 5 on hub 0
> [    4.879260] amdgpu 0000:0b:00.0: ring comp_1.3.0 uses VM inv eng 6 on hub 0
> [    4.879261] amdgpu 0000:0b:00.0: ring comp_1.0.1 uses VM inv eng 7 on hub 0
> [    4.879262] amdgpu 0000:0b:00.0: ring comp_1.1.1 uses VM inv eng 8 on hub 0
> [    4.879263] amdgpu 0000:0b:00.0: ring comp_1.2.1 uses VM inv eng 9 on hub 0
> [    4.879264] amdgpu 0000:0b:00.0: ring comp_1.3.1 uses VM inv eng 10 on hub 0
> [    4.879265] amdgpu 0000:0b:00.0: ring kiq_2.1.0 uses VM inv eng 11 on hub 0
> [    4.879266] amdgpu 0000:0b:00.0: ring sdma0 uses VM inv eng 0 on hub 1
> [    4.879267] amdgpu 0000:0b:00.0: ring sdma1 uses VM inv eng 1 on hub 1
> [    4.879268] amdgpu 0000:0b:00.0: ring uvd_0 uses VM inv eng 4 on hub 1
> [    4.879269] amdgpu 0000:0b:00.0: ring uvd_enc_0.0 uses VM inv eng 5 on hub 1
> [    4.879271] amdgpu 0000:0b:00.0: ring uvd_enc_0.1 uses VM inv eng 6 on hub 1
> [    4.879272] amdgpu 0000:0b:00.0: ring vce0 uses VM inv eng 7 on hub 1
> [    4.879273] amdgpu 0000:0b:00.0: ring vce1 uses VM inv eng 8 on hub 1
> [    4.879274] amdgpu 0000:0b:00.0: ring vce2 uses VM inv eng 9 on hub 1
> [    4.879350] [drm] ECC is not present.
> [    4.880048] [drm] Initialized amdgpu 3.27.0 20150101 for 0000:0b:00.0 on minor 0
> [    4.887781] setfont (587) used greatest stack depth: 12672 bytes left
> [    4.990857] EXT4-fs (nvme0n1p2): mounted filesystem with ordered data mode. Opts: (null)
> [    5.027693] systemd-fstab-g (603) used greatest stack depth: 12272 bytes left
> [    5.126543] kauditd_printk_skb: 4 callbacks suppressed
> [    5.126544] audit: type=1130 audit(1547782608.570:15): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.149598] audit: type=1130 audit(1547782608.593:16): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.149661] audit: type=1131 audit(1547782608.593:17): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.307512] audit: type=1130 audit(1547782608.751:18): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.324432] audit: type=1131 audit(1547782608.768:19): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.325752] audit: type=1131 audit(1547782608.769:20): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.327273] systemd-udevd (483) used greatest stack depth: 11952 bytes left
> [    5.327965] systemd-udevd (513) used greatest stack depth: 11544 bytes left
> [    5.328230] audit: type=1131 audit(1547782608.771:21): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.331176] audit: type=1131 audit(1547782608.775:22): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.332898] audit: type=1131 audit(1547782608.776:23): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.337608] audit: type=1130 audit(1547782608.781:24): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-cleanup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> [    5.446504] systemd-journald[384]: Received SIGTERM from PID 1 (systemd).
> [    5.499087] printk: systemd: 18 output lines suppressed due to ratelimiting
> [    5.946447] SELinux:  Class xdp_socket not defined in policy.
> [    5.946503] SELinux: the above unknown classes and permissions will be allowed
> [    5.946524] SELinux:  policy capability network_peer_controls=1
> [    5.946542] SELinux:  policy capability open_perms=1
> [    5.946556] SELinux:  policy capability extended_socket_class=1
> [    5.946573] SELinux:  policy capability always_check_network=0
> [    5.946589] SELinux:  policy capability cgroup_seclabel=1
> [    5.946605] SELinux:  policy capability nnp_nosuid_transition=1
> [    6.000085] systemd[1]: Successfully loaded SELinux policy in 462.710ms.
> [    6.045489] systemd[1]: Relabelled /dev, /dev/shm, /run, /sys/fs/cgroup in 32.115ms.
> [    6.047593] systemd[1]: systemd 240 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
> [    6.060087] systemd[1]: Detected architecture x86-64.
> [    6.061880] systemd[1]: Set hostname to <localhost.localdomain>.
> [    6.118380] systemd[1]: /usr/lib/systemd/system/auditd.service:12: PIDFile= references path below legacy directory /var/run/, updating /var/run/auditd.pid ??? /run/auditd.pid; please update the unit file accordingly.
> [    6.127664] systemd[1]: /usr/lib/systemd/system/gssproxy.service:9: PIDFile= references path below legacy directory /var/run/, updating /var/run/gssproxy.pid ??? /run/gssproxy.pid; please update the unit file accordingly.
> [    6.128396] systemd[1]: /usr/lib/systemd/system/rpc-statd.service:14: PIDFile= references path below legacy directory /var/run/, updating /var/run/rpc.statd.pid ??? /run/rpc.statd.pid; please update the unit file accordingly.
> [    6.130747] systemd[1]: /usr/lib/systemd/system/nfs-blkmap.service:10: PIDFile= references path below legacy directory /var/run/, updating /var/run/blkmapd.pid ??? /run/blkmapd.pid; please update the unit file accordingly.
> [    6.136141] systemd[1]: /usr/lib/systemd/system/chronyd.service:9: PIDFile= references path below legacy directory /var/run/, updating /var/run/chrony/chronyd.pid ??? /run/chrony/chronyd.pid; please update the unit file accordingly.
> [    6.143490] systemd[1]: /usr/lib/systemd/system/sssd.service:11: PIDFile= references path below legacy directory /var/run/, updating /var/run/sssd.pid ??? /run/sssd.pid; please update the unit file accordingly.
> [    6.144683] systemd[1]: /usr/lib/systemd/system/mdmonitor.service:6: PIDFile= references path below legacy directory /var/run/, updating /var/run/mdadm/mdadm.pid ??? /run/mdadm/mdadm.pid; please update the unit file accordingly.
> [    6.310360] EXT4-fs (nvme0n1p2): re-mounted. Opts: (null)
> [    6.349140] systemd-journald[696]: Received request to flush runtime journal from PID 1
> [    6.551322] acpi_cpufreq: overriding BIOS provided _PSD data
> [    6.678925] ccp 0000:0c:00.2: enabling device (0000 -> 0002)
> [    6.686990] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
> [    6.687049] piix4_smbus 0000:00:14.0: Using register 0x02 for SMBus port selection
> [    6.687136] ccp 0000:0c:00.2: ccp enabled
> [    6.687385] ccp 0000:0c:00.2: psp initialization failed
> [    6.687418] ccp 0000:0c:00.2: enabled
> [    6.691663] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver
> [    6.691882] sp5100-tco sp5100-tco: Using 0xfed80b00 for watchdog MMIO address
> [    6.691925] sp5100-tco sp5100-tco: Watchdog hardware is disabled
> [    6.739317] media: Linux media interface: v0.10
> [    6.739845] cfg80211: Loading compiled-in X.509 certificates for regulatory database
> [    6.740606] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
> [    6.742983] Bluetooth: Core ver 2.22
> [    6.743065] NET: Registered protocol family 31
> [    6.743089] Bluetooth: HCI device and connection manager initialized
> [    6.743177] Bluetooth: HCI socket layer initialized
> [    6.743206] Bluetooth: L2CAP socket layer initialized
> [    6.743263] Bluetooth: SCO socket layer initialized
> [    6.759366] usbcore: registered new interface driver btusb
> [    6.762049] videodev: Linux video capture interface: v2.00
> [    6.764287] Bluetooth: hci0: RTL: rtl: examining hci_ver=07 hci_rev=000b lmp_ver=07 lmp_subver=8822
> 
> [    6.767003] Bluetooth: hci0: RTL: rom_version status=0 version=2
> 
> [    6.767164] Bluetooth: hci0: RTL: rtl: loading rtl_bt/rtl8822b_fw.bin
> 
> [    6.768485] Bluetooth: hci0: RTL: rtl: loading rtl_bt/rtl8822b_config.bin
> 
> [    6.768756] Bluetooth: hci0: RTL: cfg_sz 14, total sz 20270
> 
> [    6.792995] uvcvideo: Unknown video format 30313050-0000-0010-8000-00aa00389b71
> [    6.793056] uvcvideo: Found UVC 1.00 device Live Gamer Ultra-Video (07ca:0553)
> [    6.795132] snd_hda_intel 0000:0b:00.1: Handle vga_switcheroo audio client
> [    6.796532] snd_hda_intel 0000:0d:00.3: enabling device (0000 -> 0002)
> [    6.809479] uvcvideo 4-3:1.0: Entity type for entity Extension 3 was not initialized!
> [    6.809543] uvcvideo 4-3:1.0: Entity type for entity Processing 2 was not initialized!
> [    6.809580] uvcvideo 4-3:1.0: Entity type for entity Camera 1 was not initialized!
> [    6.809844] input: Live Gamer Ultra-Video: Live Ga as /devices/pci0000:00/0000:00:07.1/0000:0c:00.3/usb4/4-3/4-3:1.0/input/input15
> [    6.812282] usbcore: registered new interface driver uvcvideo
> [    6.812321] USB Video Class driver (1.1.1)
> [    6.835638] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input16
> [    6.837640] input: HD-Audio Generic HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input17
> [    6.839421] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC1220: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:line
> [    6.841952] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
> [    6.844551] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
> [    6.847009] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
> [    6.848870] snd_hda_codec_realtek hdaudioC1D0:    inputs:
> [    6.849857] input: HD-Audio Generic HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input18
> [    6.851164] snd_hda_codec_realtek hdaudioC1D0:      Front Mic=0x19
> [    6.854258] input: HD-Audio Generic HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input19
> [    6.856049] snd_hda_codec_realtek hdaudioC1D0:      Rear Mic=0x18
> [    6.859264] input: HD-Audio Generic HDMI/DP,pcm=10 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input20
> [    6.860798] snd_hda_codec_realtek hdaudioC1D0:      Line=0x1a
> [    6.863989] input: HD-Audio Generic HDMI/DP,pcm=11 as /devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.1/sound/card0/input21
> [    6.868715] asus_wmi: ASUS WMI generic driver loaded
> [    6.874712] r8822be: module is from the staging directory, the quality is unknown, you have been warned.
> [    6.882263] asus_wmi: Initialization: 0x0
> [    6.882300] input: HD-Audio Generic Front Mic as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input22
> [    6.886078] asus_wmi: BIOS WMI version: 0.9
> [    6.889958] input: HD-Audio Generic Rear Mic as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input23
> [    6.891248] asus_wmi: SFUN value: 0x0
> [    6.897196] r8822be 0000:05:00.0: enabling device (0000 -> 0003)
> [    6.897281] input: HD-Audio Generic Line as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input24
> [    6.904273] input: HD-Audio Generic Line Out as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input25
> [    6.907903] input: HD-Audio Generic Front Headphone as /devices/pci0000:00/0000:00:08.1/0000:0d:00.3/sound/card1/input26
> [    6.908373] input: Eee PC WMI hotkeys as /devices/platform/eeepc-wmi/input/input27
> [    6.913889] asus_wmi: Number of fans: 1
> [    6.923339] r8822be: Using firmware rtlwifi/rtl8822befw.bin
> [    6.956572] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
> [    6.958491] r8822be: rtlwifi: wireless switch is on
> [    6.988730] kvm: Nested Virtualization enabled
> [    6.991068] kvm: Nested Paging enabled
> [    6.993762] SVM: Virtual VMLOAD VMSAVE supported
> [    6.993763] SVM: Virtual GIF supported
> [    7.004297] MCE: In-kernel MCE decoding enabled.
> [    7.010719] EDAC amd64: Node 0: DRAM ECC disabled.
> [    7.013469] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
>                 Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
>                 (Note that use of the override may cause unknown side effects.)
> [    7.027853] usbcore: registered new interface driver snd-usb-audio
> [    7.028416] r8822be 0000:05:00.0 wlp5s0: renamed from wlan0
> [    7.338323] Adding 67108860k swap on /dev/nvme0n1p3.  Priority:-2 extents:1 across:67108860k SSFS
> [    7.860710] EXT4-fs (sda): mounted filesystem with ordered data mode. Opts: (null)
> [    8.047585] RPC: Registered named UNIX socket transport module.
> [    8.049507] RPC: Registered udp transport module.
> [    8.051360] RPC: Registered tcp transport module.
> [    8.053346] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    8.286654] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> [    8.289651] Bluetooth: BNEP filters: protocol multicast
> [    8.289666] Bluetooth: BNEP socket layer initialized
> [    8.633928] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
> [    8.666549] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
> [    8.677188] IPv6: ADDRCONF(NETDEV_UP): wlp5s0: link is not ready
> [   10.186228] bridge: filtering via arp/ip/ip6tables is no longer available by default. Update your scripts to load br_netfilter if you need this.
> [   10.194541] tun: Universal TUN/TAP device driver, 1.6
> [   10.197539] virbr0: port 1(virbr0-nic) entered blocking state
> [   10.197550] virbr0: port 1(virbr0-nic) entered disabled state
> [   10.198454] device virbr0-nic entered promiscuous mode
> [   10.449149] virbr0: port 1(virbr0-nic) entered blocking state
> [   10.449204] virbr0: port 1(virbr0-nic) entered listening state
> [   10.521237] virbr0: port 1(virbr0-nic) entered disabled state
> [   11.740924] logitech-hidpp-device 0003:046D:4026.0009: HID++ 2.0 device connected.
> [   11.753558] igb 0000:04:00.0 enp4s0: igb: enp4s0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> [   11.862280] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becomes ready
> [   17.996230] Bluetooth: RFCOMM TTY layer initialized
> [   17.996238] Bluetooth: RFCOMM socket layer initialized
> [   17.996273] Bluetooth: RFCOMM ver 1.11
> [   19.063941] fuse init (API version 7.28)
> [   20.532457] rfkill: input handler disabled
> [   21.384613] SGI XFS with ACLs, security attributes, scrub, no debug enabled
> [   21.393353] XFS (sdb): Mounting V5 Filesystem
> [   21.484079] XFS (sdb): Ending clean mount
> [   23.739982] pool (2794) used greatest stack depth: 11328 bytes left
> [   26.448265] usb 3-1.4.4: reset high-speed USB device number 10 using xhci_hcd
> [   49.627472] io scheduler bfq registered
> [   62.376164] virbr0: port 2(vnet0) entered blocking state
> [   62.376171] virbr0: port 2(vnet0) entered disabled state
> [   62.376374] device vnet0 entered promiscuous mode
> [   62.377390] virbr0: port 2(vnet0) entered blocking state
> [   62.377397] virbr0: port 2(vnet0) entered listening state
> [   64.435482] virbr0: port 2(vnet0) entered learning state
> [   66.482947] virbr0: port 2(vnet0) entered forwarding state
> [   66.482954] virbr0: topology change detected, propagating
> [  250.819545] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [  250.819565] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [  250.819572] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [  250.819579] pcieport 0000:00:03.1:    [12] Timeout               
> [  390.383022] kworker/dying (252) used greatest stack depth: 11216 bytes left
> [  463.471473] TaskSchedulerFo (3677) used greatest stack depth: 10992 bytes left
> [  631.715941] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [  631.715960] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [  631.715969] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [  631.715977] pcieport 0000:00:03.1:    [12] Timeout               
> [  720.953608] retire_capture_urb: 47 callbacks suppressed
> [  837.001380] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [  837.001393] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [  837.001397] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [  837.001401] pcieport 0000:00:03.1:    [12] Timeout               
> [  903.895474] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [  903.895489] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [  903.895494] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [  903.895499] pcieport 0000:00:03.1:    [12] Timeout               
> [ 1115.366683] kworker/dying (256) used greatest stack depth: 10864 bytes left
> [ 1523.996113] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.027803] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.057489] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.096610] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.125583] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.174901] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.225859] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.254731] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.285136] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.341328] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.373071] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.401651] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.461636] xhci_hcd 0000:0c:00.3: ERROR unknown event type 37
> [ 1524.476433] logitech-hidpp-device 0003:046D:4026.0009: hidpp20_batterylevel_get_battery_capacity: received protocol error 0x09
> [ 1528.708659] perf: interrupt took too long (6244 > 2500), lowering kernel.perf_event_max_sample_rate to 32000
> [ 1549.960708] nf_conntrack: default automatic helper assignment has been turned off for security reasons and CT-based  firewall rule not found. Use the iptables CT target to attach helpers instead.
> [ 1649.206391] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 1649.206404] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 1649.206407] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 1649.206411] pcieport 0000:00:03.1:    [12] Timeout               
> [ 2013.763670] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 2013.763688] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 2013.763696] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 2013.763703] pcieport 0000:00:03.1:    [12] Timeout               
> [ 2038.806142] pcieport 0000:00:01.3: AER: Corrected error received: 0000:00:00.0
> [ 2038.806156] pcieport 0000:00:01.3: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Receiver ID)
> [ 2038.806162] pcieport 0000:00:01.3:   device [1022:1453] error status/mask=00000040/00006000
> [ 2038.806167] pcieport 0000:00:01.3:    [ 6] BadTLP                
> [ 2164.692364] Process accounting resumed
> 
> [ 2164.694421] =============================
> [ 2164.694425] WARNING: suspicious RCU usage
> [ 2164.694429] 5.0.0-0.rc2.git1.2.fc30.x86_64 #1 Tainted: G         C       
> [ 2164.694432] -----------------------------
> [ 2164.694436] include/linux/rcupdate.h:281 Illegal context switch in RCU read-side critical section!
> [ 2164.694438] 
>                other info that might help us debug this:
> 
> [ 2164.694442] 
>                rcu_scheduler_active = 2, debug_locks = 1
> [ 2164.694445] 2 locks held by atop/10498:
> [ 2164.694448]  #0: 0000000061e564e5 (&p->lock){+.+.}, at: seq_read+0x41/0x430
> [ 2164.694468]  #1: 0000000081e34167 (rcu_read_lock){....}, at: dev_seq_start+0x5/0x120
> [ 2164.694475] 
>                stack backtrace:
> [ 2164.694480] CPU: 10 PID: 10498 Comm: atop Tainted: G         C        5.0.0-0.rc2.git1.2.fc30.x86_64 #1
> [ 2164.694483] Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [ 2164.694486] Call Trace:
> [ 2164.694494]  dump_stack+0x85/0xc0
> [ 2164.694501]  ___might_sleep+0x100/0x180
> [ 2164.694508]  __mutex_lock+0x55/0x9a0
> [ 2164.694514]  ? seq_vprintf+0x30/0x50
> [ 2164.694518]  ? seq_printf+0x53/0x70
> [ 2164.694534]  ? igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694541]  igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694549]  dev_get_stats+0x5b/0xc0
> [ 2164.694553]  dev_seq_printf_stats+0x32/0xe0
> [ 2164.694568]  dev_seq_show+0x10/0x30
> [ 2164.694571]  seq_read+0x2fd/0x430
> [ 2164.694581]  proc_reg_read+0x39/0x60
> [ 2164.694587]  __vfs_read+0x36/0x1a0
> [ 2164.694597]  vfs_read+0x9f/0x160
> [ 2164.694602]  ksys_read+0x52/0xc0
> [ 2164.694609]  do_syscall_64+0x60/0x1f0
> [ 2164.694613]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 2164.694618] RIP: 0033:0x7fa0f51bd255
> [ 2164.694621] Code: fe ff ff 50 48 8d 3d 2a 03 0a 00 e8 35 01 02 00 0f 1f 44 00 00 f3 0f 1e fa 48 8d 05 c5 94 0d 00 8b 00 85 c0 75 0f 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89
> [ 2164.694625] RSP: 002b:00007ffe79288db8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> [ 2164.694629] RAX: ffffffffffffffda RBX: 0000000000a55260 RCX: 00007fa0f51bd255
> [ 2164.694632] RDX: 0000000000000400 RSI: 0000000000a55490 RDI: 0000000000000004
> [ 2164.694635] RBP: 0000000000000d68 R08: 0000000000000001 R09: 0000000000000000
> [ 2164.694638] R10: 00007fa0f50a3740 R11: 0000000000000246 R12: 00007fa0f528d740
> [ 2164.694641] R13: 00007fa0f528e340 R14: 00000000000007ff R15: 0000000000a55260
> [ 2164.694709] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:908
> [ 2164.694724] in_atomic(): 1, irqs_disabled(): 0, pid: 10498, name: atop
> [ 2164.694729] 2 locks held by atop/10498:
> [ 2164.694732]  #0: 0000000061e564e5 (&p->lock){+.+.}, at: seq_read+0x41/0x430
> [ 2164.694753]  #1: 0000000081e34167 (rcu_read_lock){....}, at: dev_seq_start+0x5/0x120
> [ 2164.694762] CPU: 10 PID: 10498 Comm: atop Tainted: G         C        5.0.0-0.rc2.git1.2.fc30.x86_64 #1
> [ 2164.694765] Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [ 2164.694768] Call Trace:
> [ 2164.694773]  dump_stack+0x85/0xc0
> [ 2164.694778]  ___might_sleep.cold.73+0xac/0xbc
> [ 2164.694783]  __mutex_lock+0x55/0x9a0
> [ 2164.694788]  ? seq_vprintf+0x30/0x50
> [ 2164.694792]  ? seq_printf+0x53/0x70
> [ 2164.694806]  ? igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694813]  igb_get_stats64+0x29/0x80 [igb]
> [ 2164.694818]  dev_get_stats+0x5b/0xc0
> [ 2164.694822]  dev_seq_printf_stats+0x32/0xe0
> [ 2164.694836]  dev_seq_show+0x10/0x30
> [ 2164.694840]  seq_read+0x2fd/0x430
> [ 2164.694847]  proc_reg_read+0x39/0x60
> [ 2164.694852]  __vfs_read+0x36/0x1a0
> [ 2164.694861]  vfs_read+0x9f/0x160
> [ 2164.694866]  ksys_read+0x52/0xc0
> [ 2164.694872]  do_syscall_64+0x60/0x1f0
> [ 2164.694876]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 2164.694880] RIP: 0033:0x7fa0f51bd255
> [ 2164.694883] Code: fe ff ff 50 48 8d 3d 2a 03 0a 00 e8 35 01 02 00 0f 1f 44 00 00 f3 0f 1e fa 48 8d 05 c5 94 0d 00 8b 00 85 c0 75 0f 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89
> [ 2164.694886] RSP: 002b:00007ffe79288db8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> [ 2164.694890] RAX: ffffffffffffffda RBX: 0000000000a55260 RCX: 00007fa0f51bd255
> [ 2164.694892] RDX: 0000000000000400 RSI: 0000000000a55490 RDI: 0000000000000004
> [ 2164.694895] RBP: 0000000000000d68 R08: 0000000000000001 R09: 0000000000000000
> [ 2164.694898] R10: 00007fa0f50a3740 R11: 0000000000000246 R12: 00007fa0f528d740
> [ 2164.694900] R13: 00007fa0f528e340 R14: 00000000000007ff R15: 0000000000a55260
> [ 2174.708811] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:908
> [ 2174.708818] in_atomic(): 1, irqs_disabled(): 0, pid: 10498, name: atop
> [ 2174.708821] 2 locks held by atop/10498:
> [ 2174.708823]  #0: 0000000002f7dd02 (&p->lock){+.+.}, at: seq_read+0x41/0x430
> [ 2174.708841]  #1: 0000000081e34167 (rcu_read_lock){....}, at: dev_seq_start+0x5/0x120
> [ 2174.708851] CPU: 10 PID: 10498 Comm: atop Tainted: G        WC        5.0.0-0.rc2.git1.2.fc30.x86_64 #1
> [ 2174.708854] Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [ 2174.708857] Call Trace:
> [ 2174.708864]  dump_stack+0x85/0xc0
> [ 2174.708870]  ___might_sleep.cold.73+0xac/0xbc
> [ 2174.708876]  __mutex_lock+0x55/0x9a0
> [ 2174.708882]  ? seq_vprintf+0x30/0x50
> [ 2174.708885]  ? seq_printf+0x53/0x70
> [ 2174.708899]  ? igb_get_stats64+0x29/0x80 [igb]
> [ 2174.708906]  igb_get_stats64+0x29/0x80 [igb]
> [ 2174.708912]  dev_get_stats+0x5b/0xc0
> [ 2174.708917]  dev_seq_printf_stats+0x32/0xe0
> [ 2174.708929]  dev_seq_show+0x10/0x30
> [ 2174.708932]  seq_read+0x2fd/0x430
> [ 2174.708940]  proc_reg_read+0x39/0x60
> [ 2174.708945]  __vfs_read+0x36/0x1a0
> [ 2174.708953]  vfs_read+0x9f/0x160
> [ 2174.708957]  ksys_read+0x52/0xc0
> [ 2174.708963]  do_syscall_64+0x60/0x1f0
> [ 2174.708967]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 2174.708971] RIP: 0033:0x7fa0f51bd255
> [ 2174.708975] Code: fe ff ff 50 48 8d 3d 2a 03 0a 00 e8 35 01 02 00 0f 1f 44 00 00 f3 0f 1e fa 48 8d 05 c5 94 0d 00 8b 00 85 c0 75 0f 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89
> [ 2174.708978] RSP: 002b:00007ffe792888d8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> [ 2174.708982] RAX: ffffffffffffffda RBX: 0000000000a55260 RCX: 00007fa0f51bd255
> [ 2174.708984] RDX: 0000000000000400 RSI: 0000000000c8a790 RDI: 0000000000000007
> [ 2174.708987] RBP: 0000000000000d68 R08: 0000000000000001 R09: 0000000000000000
> [ 2174.708989] R10: 00007fa0f50a3740 R11: 0000000000000246 R12: 00007fa0f528d740
> [ 2174.708992] R13: 00007fa0f528e340 R14: 00000000000003ff R15: 0000000000a55260
> [ 2184.709065] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:908
> [ 2184.709075] in_atomic(): 1, irqs_disabled(): 0, pid: 10498, name: atop
> [ 2184.709081] 2 locks held by atop/10498:
> [ 2184.709086]  #0: 000000006f0331ac (&p->lock){+.+.}, at: seq_read+0x41/0x430
> [ 2184.709100]  #1: 0000000081e34167 (rcu_read_lock){....}, at: dev_seq_start+0x5/0x120
> [ 2184.709115] CPU: 14 PID: 10498 Comm: atop Tainted: G        WC        5.0.0-0.rc2.git1.2.fc30.x86_64 #1
> [ 2184.709119] Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1103 11/16/2018
> [ 2184.709124] Call Trace:
> [ 2184.709137]  dump_stack+0x85/0xc0
> [ 2184.709146]  ___might_sleep.cold.73+0xac/0xbc
> [ 2184.709157]  __mutex_lock+0x55/0x9a0
> [ 2184.709167]  ? seq_vprintf+0x30/0x50
> [ 2184.709173]  ? seq_printf+0x53/0x70
> [ 2184.709195]  ? igb_get_stats64+0x29/0x80 [igb]
> [ 2184.709208]  igb_get_stats64+0x29/0x80 [igb]
> [ 2184.709219]  dev_get_stats+0x5b/0xc0
> [ 2184.709227]  dev_seq_printf_stats+0x32/0xe0
> [ 2184.709251]  dev_seq_show+0x10/0x30
> [ 2184.709257]  seq_read+0x2fd/0x430
> [ 2184.709271]  proc_reg_read+0x39/0x60
> [ 2184.709279]  __vfs_read+0x36/0x1a0
> [ 2184.709295]  vfs_read+0x9f/0x160
> [ 2184.709304]  ksys_read+0x52/0xc0
> [ 2184.709315]  do_syscall_64+0x60/0x1f0
> [ 2184.709322]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [ 2184.709329] RIP: 0033:0x7fa0f51bd255
> [ 2184.709335] Code: fe ff ff 50 48 8d 3d 2a 03 0a 00 e8 35 01 02 00 0f 1f 44 00 00 f3 0f 1e fa 48 8d 05 c5 94 0d 00 8b 00 85 c0 75 0f 31 c0 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89
> [ 2184.709340] RSP: 002b:00007ffe792888d8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> [ 2184.709347] RAX: ffffffffffffffda RBX: 0000000000a55260 RCX: 00007fa0f51bd255
> [ 2184.709352] RDX: 0000000000000400 RSI: 0000000000c8a790 RDI: 0000000000000007
> [ 2184.709357] RBP: 0000000000000d68 R08: 0000000000000001 R09: 0000000000000000
> [ 2184.709361] R10: 00007fa0f50a3740 R11: 0000000000000246 R12: 00007fa0f528d740
> [ 2184.709366] R13: 00007fa0f528e340 R14: 00000000000003ff R15: 0000000000a55260
> [ 2238.236048] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 2238.236063] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 2238.236069] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 2238.236074] pcieport 0000:00:03.1:    [12] Timeout               
> [ 2248.464427] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 2248.464445] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 2248.464450] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 2248.464453] pcieport 0000:00:03.1:    [12] Timeout               
> [ 2763.167173] pcieport 0000:00:01.3: AER: Corrected error received: 0000:00:00.0
> [ 2763.167183] pcieport 0000:00:01.3: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Receiver ID)
> [ 2763.167186] pcieport 0000:00:01.3:   device [1022:1453] error status/mask=00000040/00006000
> [ 2763.167189] pcieport 0000:00:01.3:    [ 6] BadTLP                
> [ 3944.208341] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 3944.208354] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 3944.208358] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 3944.208361] pcieport 0000:00:03.1:    [12] Timeout               
> [ 4018.324343] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 4018.324358] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 4018.324362] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 4018.324366] pcieport 0000:00:03.1:    [12] Timeout               
> [ 5016.087860] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 5016.087875] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 5016.087882] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 5016.087888] pcieport 0000:00:03.1:    [12] Timeout               
> [ 5119.287549] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 5119.287563] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 5119.287567] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 5119.287571] pcieport 0000:00:03.1:    [12] Timeout               
> [ 5373.612300] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 5373.612313] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 5373.612318] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 5373.612322] pcieport 0000:00:03.1:    [12] Timeout               
> [ 5514.186429] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 5514.186442] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 5514.186445] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 5514.186449] pcieport 0000:00:03.1:    [12] Timeout               
> [ 6395.645450] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 6395.645462] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 6395.645466] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 6395.645469] pcieport 0000:00:03.1:    [12] Timeout               
> [ 6903.253080] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 6903.253099] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 6903.253105] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 6903.253110] pcieport 0000:00:03.1:    [12] Timeout               
> [ 7545.216749] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 7545.216761] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 7545.216765] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 7545.216769] pcieport 0000:00:03.1:    [12] Timeout               
> [ 7826.653248] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 7826.653260] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 7826.653264] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 7826.653268] pcieport 0000:00:03.1:    [12] Timeout               
> [ 7842.372131] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 7842.372328] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 7842.372332] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 7842.372336] pcieport 0000:00:03.1:    [12] Timeout               
> [ 7941.573092] hrtimer: interrupt took 1433129 ns
> [ 8334.713416] pcieport 0000:00:03.1: AER: Corrected error received: 0000:00:00.0
> [ 8334.713429] pcieport 0000:00:03.1: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
> [ 8334.713435] pcieport 0000:00:03.1:   device [1022:1453] error status/mask=00001000/00006000
> [ 8334.713439] pcieport 0000:00:03.1:    [12] Timeout               


-- 
Oscar Salvador
SUSE L3
