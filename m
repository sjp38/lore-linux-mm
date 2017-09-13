Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D77636B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 00:19:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x78so23590425pff.7
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 21:19:02 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 97si9872770plc.265.2017.09.12.21.19.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 21:19:01 -0700 (PDT)
Message-ID: <1505276066.15586.11.camel@intel.com>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Date: Tue, 12 Sep 2017 21:14:26 -0700
In-Reply-To: <1505244724.4482.78.camel@intel.com>
References: <cover.1498751203.git.luto@kernel.org>
	 <CALBSrqDW6pGjHxOmzfnkY_KoNeH6F=pTb8-tJ8r-zbu4prw9HQ@mail.gmail.com>
	 <1505244724.4482.78.camel@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, nadav.amit@gmail.com, riel@redhat.com, "Hansen, Dave" <dave.hansen@intel.com>, arjan@linux.intel.com, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "Shankar,
 Ravi V" <ravi.v.shankar@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>, mingo@kernel.org

> 
> 
> Hi Andy,
> 
> I have booted Linus's tree (8fac2f96ab86b0e14ec4e42851e21e9b518bdc55) on
> Skylake server and noticed that it reboots automatically.
> 
> When I booted the same kernel with command line arg "nopcid" it works
> fine. Please find below a snippet of dmesg. Please let me know if you
> need more info to debug.
> 
> [    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.13.0+
> root=UUID=3b8e9636-6e23-4785-a4e2-5954bfe86fd9 ro console=tty0
> console=ttyS0,115200n8
> [    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
> [    0.000000] log_buf_len total cpu_extra contributions: 258048 bytes
> [    0.000000] log_buf_len min size: 262144 bytes
> [    0.000000] log_buf_len: 524288 bytes
> [    0.000000] early log buf free: 212560(81%)
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: CPU: 0 PID: 0 at arch/x86/mm/tlb.c:245
> initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.13.0+ #5
> [    0.000000] task: ffffffff8960f480 task.stack: ffffffff89600000
> [    0.000000] RIP: 0010:initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.000000] RSP: 0000:ffffffff89603e60 EFLAGS: 00010046
> [    0.000000] RAX: 00000000000406b0 RBX: ffff9f1700a17880 RCX:
> ffffffff8965de60
> [    0.000000] RDX: 0000008383a0a000 RSI: 000000000960a000 RDI:
> 0000008383a0a000
> [    0.000000] RBP: ffffffff89603e60 R08: 0000000000000000 R09:
> 0000ffffffffffff
> [    0.000000] R10: ffffffff89603ee8 R11: ffffffff0000ffff R12:
> 0000000000000000
> [    0.000000] R13: ffff9f1700a0c3e0 R14: ffffffff8960f480 R15:
> 0000000000000000
> [    0.000000] FS:  0000000000000000(0000) GS:ffff9f1700a00000(0000)
> knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffff9fa7bffff000 CR3: 0000008383a0a000 CR4:
> 00000000000406b0
> [    0.000000] Call Trace:
> [    0.000000]  cpu_init+0x206/0x4f0
> [    0.000000]  ? __set_pte_vaddr+0x1d/0x30
> [    0.000000]  trap_init+0x3e/0x50
> [    0.000000]  ? trap_init+0x3e/0x50
> [    0.000000]  start_kernel+0x1e2/0x3f2
> [    0.000000]  x86_64_start_reservations+0x24/0x26
> [    0.000000]  x86_64_start_kernel+0x6f/0x72
> [    0.000000]  secondary_startup_64+0xa5/0xa5
> [    0.000000] Code: de 00 48 01 f0 48 39 c7 0f 85 92 00 00 00 48 8b 05
> ee e2 ee 00 a9 00 00 02 00 74 11 65 48 8b 05 8b 9d 7c 77 a9 00 00 02 00
> 75 02 <0f> ff 48 81 e2 00 f0 ff ff 0f 22 da 65 66 c7 05 66 9d 7c 77 00 
> [    0.000000] ---[ end trace c258f2d278fe031f ]---
> [    0.000000] Memory: 791050356K/803934656K available (9585K kernel
> code, 1313K rwdata, 3000K rodata, 1176K init, 680K bss, 12884300K
> reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=64,
> Nodes=4
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU event tracing is enabled.
> [    0.000000] NR_IRQS: 4352, nr_irqs: 3928, preallocated irqs: 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles:
> 0xffffffff, max_idle_ns: 79635855245 ns
> [    0.001000] tsc: Detected 2000.000 MHz processor
> [    0.002000] Calibrating delay loop (skipped), value calculated using
> timer frequency.. 4000.00 BogoMIPS (lpj=2000000)
> [    0.003003] pid_max: default: 65536 minimum: 512
> [    0.004030] ACPI: Core revision 20170728
> [    0.091853] ACPI: 6 ACPI AML tables successfully acquired and loaded
> [    0.094143] Security Framework initialized
> [    0.095004] SELinux:  Initializing.
> [    0.145612] Dentry cache hash table entries: 33554432 (order: 16,
> 268435456 bytes)
> [    0.170544] Inode-cache hash table entries: 16777216 (order: 15,
> 134217728 bytes)
> [    0.172699] Mount-cache hash table entries: 524288 (order: 10,
> 4194304 bytes)
> [    0.174441] Mountpoint-cache hash table entries: 524288 (order: 10,
> 4194304 bytes)
> [    0.176351] CPU: Physical Processor ID: 0
> [    0.177003] CPU: Processor Core ID: 0
> [    0.178007] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
> [    0.179003] ENERGY_PERF_BIAS: View and update with
> x86_energy_perf_policy(8)
> [    0.180013] mce: CPU supports 20 MCE banks
> [    0.181018] CPU0: Thermal monitoring enabled (TM1)
> [    0.182057] process: using mwait in idle threads
> [    0.183005] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8
> [    0.184003] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4
> [    0.185223] Freeing SMP alternatives memory: 36K
> [    0.193912] smpboot: Max logical packages: 8
> [    0.194017] Switched APIC routing to physical flat.
> [    0.196496] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.206252] smpboot: CPU0: Intel(R) Xeon(R) Platinum 8164 CPU @
> 2.00GHz (family: 0x6, model: 0x55, stepping: 0x4)
> [    0.207131] Performance Events: PEBS fmt3+, Skylake events, 32-deep
> LBR, full-width counters, Intel PMU driver.
> [    0.208003] ... version:                4
> [    0.209001] ... bit width:              48
> [    0.210001] ... generic registers:      4
> [    0.211001] ... value mask:             0000ffffffffffff
> [    0.212001] ... max period:             00007fffffffffff
> [    0.213001] ... fixed-purpose events:   3
> [    0.214001] ... event mask:             000000070000000f
> [    0.215078] Hierarchical SRCU implementation.
> [    0.216867] smp: Bringing up secondary CPUs ...
> [    0.217085] x86: Booting SMP configuration:
> [    0.218001] .... node  #0, CPUs:        #1
> [    0.001000] ------------[ cut here ]------------
> [    0.001000] WARNING: CPU: 1 PID: 0 at arch/x86/mm/tlb.c:245
> initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.001000] Modules linked in:
> [    0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W
> 4.13.0+ #5
> [    0.001000] task: ffff9f16fa393e40 task.stack: ffffaf0e98afc000
> [    0.001000] RIP: 0010:initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.001000] RSP: 0000:ffffaf0e98affeb0 EFLAGS: 00010046
> [    0.001000] RAX: 00000000000000a0 RBX: ffff9f1700a57880 RCX:
> ffffffff8965de60
> [    0.001000] RDX: 0000008383a0a000 RSI: 000000000960a000 RDI:
> 0000008383a0a000
> [    0.001000] RBP: ffffaf0e98affeb0 R08: 0000000000000000 R09:
> 0000000000000000
> [    0.001000] R10: ffffaf0e98affe78 R11: ffffaf0e98affdb6 R12:
> 0000000000000001
> [    0.001000] R13: ffff9f1700a4c3e0 R14: ffff9f16fa393e40 R15:
> 0000000000000001
> [    0.001000] FS:  0000000000000000(0000) GS:ffff9f1700a40000(0000)
> knlGS:0000000000000000
> [    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.001000] CR2: 0000000000000000 CR3: 0000008383a0a000 CR4:
> 00000000000000a0
> [    0.001000] invalid opcode: 0000 [#1] SMP
> [    0.001000] Modules linked in:
> [    0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W
> 4.13.0+ #5
> [    0.001000] task: ffff9f16fa393e40 task.stack: ffffaf0e98afc000
> [    0.001000] RIP: 0010:__show_regs+0x255/0x290
> [    0.001000] RSP: 0000:ffffaf0e98affbc0 EFLAGS: 00010002
> [    0.001000] RAX: 0000000000000018 RBX: 0000000000000000 RCX:
> 0000000000000000
> [    0.001000] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffffff898a978c
> [    0.001000] RBP: ffffaf0e98affc10 R08: 0000000000000001 R09:
> 0000000000000373
> [    0.001000] R10: ffffffff8884fb8c R11: ffffffff898ab7cd R12:
> 00000000ffff0ff0
> [    0.001000] R13: 0000000000000400 R14: ffff9f1700a40000 R15:
> 0000000000000000
> [    0.001000] FS:  0000000000000000(0000) GS:ffff9f1700a40000(0000)
> knlGS:0000000000000000
> [    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.001000] CR2: 0000000000000000 CR3: 0000008383a0a000 CR4:
> 00000000000000a0

Hi All,

Since I didn't find conversation between Andy and myself on the mailing
list, I wanted to keep this thread updated. So, sorry! for spamming your
inbox if it's a duplicate.

Andy has asked me to try a patch that's already in his git repo and it
fixes the issue.

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=x86/fixes&id=cb88ae619b4c3d832d224f2c641849dc02aed864


Regards,
Sai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
